// mentl-runner — the wasmtime embed that replaces the wasmtime CLI for Mentl
// modules (Hβ.ops.wasmtime-runner-migration steps 2–3), and the host half of
// the medium's Process seam (Hβ.ops.runner-is-the-process-handler).
//
// Every emitted Mentl module needs the engine to accept a SHARED memory +
// tail calls. The memory's SHAPE follows the module's own proof: a
// thread-free module DEFINES and exports its memory (self-contained; no
// thread-spawn import at all); a spawning module IMPORTS it (the
// wasi-threads convention) and re-exports it for the p1 ABI. For the
// spawning shape this binary supplies what wasmtime 47's CLI deleted
// (-S threads=y): the imported shared memory is created at its declared
// type and linked under the import's own module/name (so every instance —
// root and spawned — reads ONE image), and `wasi.thread-spawn` is
// registered by hand: allocate a thread id, std::thread::spawn a fresh
// instance of the SAME module in a fresh Store over that memory, call its
// exported wasi_thread_start(tid, start_arg).
//
// THE EXEC SEAM. WASI has no exec, so the wheel's `mentl run` and its
// in-process test battery could compile a program but never execute it —
// a bash shim assembled and ran the WAT, one process per program. The
// runner IS the executor: the guest streams the WAT it emits through
// `mentl_host.wat_write(ptr, len)` exactly as it streams bytes to an fd,
// and `mentl_host.exec(argv_ptr, argv_len) -> exit` compiles that text to a
// module (wasmtime reads WAT directly — no assembler step), instantiates
// it in a fresh Store over its own memory with the parent's preopens and
// the NUL-joined argv the guest handed over, runs `_start`, and returns the
// program's exit code (a trap is 134, the code the micro battery banks).
// The parent's own memory is never touched after the read: the child is
// a separate instance, so a child that proc_exits returns HERE as a value
// instead of ending the runner — that is what makes a 149-program battery
// one process. A child's SPAWNED THREAD keeps wasi-threads semantics
// (proc_exit or a trap on any thread ends the process): those are
// process-wide by that convention, and a battery member that dies on a
// worker thread dies loudly rather than silently.
//
// CLI contract (argv-compatible with the wt_run subset of the wasmtime CLI):
//   mentl-runner run [-W v] [-S v] [-D v] [--dir h[::g]] [--env K=V] \
//                    <module.wasm|.wat> [guest argv...]
// -W/-S/-D values are parsed and ignored (threads + tail-call are always on);
// stdin/stdout/stderr pass through; exit code = guest exit code; a trap exits
// 134 (the wasmtime CLI's trap status, banked by the micro battery).

use wasmtime::{Result, bail, format_err};
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::{Arc, OnceLock};
use wasmtime::{Caller, Config, Engine, Extern, ExternType, Linker, Module, SharedMemory, Store};
use wasmtime_wasi::p1::WasiP1Ctx;
use wasmtime_wasi::{DirPerms, FilePerms, I32Exit, WasiCtxBuilder};

// wasi-threads: a spawned thread id is positive and stays below 2^29 so it
// packs beside the wait/notify sentinel values.
const MAX_TID: i32 = 0x1FFF_FFFF;

#[derive(Clone)]
struct RunSpec {
    argv: Vec<String>,
    preopens: Vec<(String, String)>,
    envs: Vec<(String, String)>,
}

struct Host {
    wasi: WasiP1Ctx,
    threads: Arc<ThreadCtx>,
    // The exec seam's stream: every `mentl_host.wat_write` appends here, and
    // `mentl_host.exec` takes the whole text as the child module. It lives
    // in the HOST, not the guest image, because the guest's emit phase resets
    // its regions per function — a collecting sink inside the image would
    // read reset segments (the scope law at wat_to_string's declaration).
    wat: Vec<u8>,
}

struct ThreadCtx {
    engine: Engine,
    module: Module,
    // The linker is completed (WASI + thread-spawn + any shared-memory
    // import) before the first guest instruction runs, so every spawn reads
    // it initialized; OnceLock breaks the build-order knot (the linker's
    // memory definition needs a Store<Host>, and Host carries this ctx).
    linker: OnceLock<Linker<Host>>,
    spec: RunSpec,
    next_tid: AtomicI32,
}

impl ThreadCtx {
    fn spawn(self: &Arc<Self>, start_arg: i32) -> i32 {
        let tid = self.next_tid.fetch_add(1, Ordering::SeqCst);
        if !(1..=MAX_TID).contains(&tid) {
            return -1;
        }
        let ctx = self.clone();
        let spawned = std::thread::Builder::new()
            .name(format!("wasi-thread-{tid}"))
            .spawn(move || {
                let host = Host {
                    wasi: build_wasi(&ctx.spec),
                    threads: ctx.clone(),
                    wat: Vec::new(),
                };
                let mut store = Store::new(&ctx.engine, host);
                let linker = ctx
                    .linker
                    .get()
                    .expect("linker is completed before any guest code runs");
                let instance = match linker.instantiate(&mut store, &ctx.module) {
                    Ok(i) => i,
                    Err(e) => {
                        eprintln!("mentl-runner: wasi-thread-{tid} instantiation: {e:?}");
                        std::process::exit(134);
                    }
                };
                let entry = match instance
                    .get_typed_func::<(i32, i32), ()>(&mut store, "wasi_thread_start")
                {
                    Ok(f) => f,
                    Err(e) => {
                        eprintln!("mentl-runner: wasi-thread-{tid}: {e:?}");
                        std::process::exit(134);
                    }
                };
                if let Err(e) = entry.call(&mut store, (tid, start_arg)) {
                    // wasi-threads semantics: proc_exit from any thread exits
                    // the process; a trap in any thread terminates all.
                    if let Some(exit) = e.downcast_ref::<I32Exit>() {
                        std::process::exit(exit.0);
                    }
                    eprintln!("mentl-runner: wasi-thread-{tid} trapped: {e:?}");
                    std::process::exit(134);
                }
            });
        match spawned {
            Ok(_) => tid,
            Err(_) => -1,
        }
    }
}

fn build_wasi(spec: &RunSpec) -> WasiP1Ctx {
    let mut b = WasiCtxBuilder::new();
    b.inherit_stdio();
    b.args(&spec.argv);
    b.envs(&spec.envs);
    for (host, guest) in &spec.preopens {
        if let Err(e) = b.preopened_dir(host, guest, DirPerms::all(), FilePerms::all()) {
            eprintln!("mentl-runner: --dir {host}::{guest}: {e}");
            std::process::exit(1);
        }
    }
    b.build_p1()
}

// A byte range of the CALLER's linear memory, copied out. A Mentl module's
// memory is shared (defined or imported), so the read goes through the
// UnsafeCell view; a plain memory is read through the store. The copy is the
// whole point: the child is instantiated from host-owned bytes, and the
// parent's image is never referenced again.
fn read_guest_bytes(caller: &mut Caller<'_, Host>, ptr: i32, len: i32) -> Result<Vec<u8>> {
    let (start, n) = (ptr as u32 as usize, len as u32 as usize);
    match caller.get_export("memory") {
        Some(Extern::SharedMemory(sm)) => {
            let data = sm.data();
            if start.checked_add(n).map_or(true, |end| end > data.len()) {
                bail!("mentl_host: guest range {start}+{n} is outside memory");
            }
            Ok(data[start..start + n]
                .iter()
                .map(|c| unsafe { *c.get() })
                .collect())
        }
        Some(Extern::Memory(m)) => {
            let data = m.data(&*caller);
            if start.checked_add(n).map_or(true, |end| end > data.len()) {
                bail!("mentl_host: guest range {start}+{n} is outside memory");
            }
            Ok(data[start..start + n].to_vec())
        }
        _ => bail!("mentl_host: the guest exports no memory"),
    }
}

// The linker every instance is built from: the p1 host, wasi-threads'
// spawn, and the two ops of the exec seam. Shared-memory imports are
// defined per module (they need the module's declared type) in link_and_run.
fn make_linker(engine: &Engine) -> Result<Linker<Host>> {
    let mut linker: Linker<Host> = Linker::new(engine);
    wasmtime_wasi::p1::add_to_linker_sync(&mut linker, |h: &mut Host| &mut h.wasi)?;
    linker.func_wrap(
        "wasi",
        "thread-spawn",
        |caller: Caller<'_, Host>, start_arg: i32| -> i32 {
            let ctx = caller.data().threads.clone();
            ctx.spawn(start_arg)
        },
    )?;
    linker.func_wrap(
        "mentl_host",
        "wat_write",
        |mut caller: Caller<'_, Host>, ptr: i32, len: i32| -> Result<()> {
            let bytes = read_guest_bytes(&mut caller, ptr, len)?;
            caller.data_mut().wat.extend_from_slice(&bytes);
            Ok(())
        },
    )?;
    linker.func_wrap(
        "mentl_host",
        "exec",
        |mut caller: Caller<'_, Host>, argv_ptr: i32, argv_len: i32| -> Result<i32> {
            let argv_bytes = read_guest_bytes(&mut caller, argv_ptr, argv_len)?;
            let wat = std::mem::take(&mut caller.data_mut().wat);
            let engine = caller.data().threads.engine.clone();
            let mut spec = caller.data().threads.spec.clone();
            spec.argv = argv_bytes
                .split(|b| *b == 0)
                .filter(|a| !a.is_empty())
                .map(|a| String::from_utf8_lossy(a).into_owned())
                .collect();
            if spec.argv.is_empty() {
                spec.argv.push("mentl-exec".to_string());
            }
            let module = match Module::new(&engine, &wat) {
                Ok(m) => m,
                Err(e) => {
                    eprintln!("mentl_host.exec: the streamed module does not assemble: {e:?}");
                    return Ok(1);
                }
            };
            Ok(match link_and_run(&engine, module, spec) {
                Ok(code) => code,
                Err(e) => exit_status_of(&e),
            })
        },
    )?;
    Ok(linker)
}

// A guest trap surfaces as an error; the wasmtime CLI maps traps to exit
// 134 (128+SIGABRT) and the micro battery banks that number, so the runner
// speaks the same status — for the root instance and for an exec'd child.
fn exit_status_of(e: &wasmtime::Error) -> i32 {
    if e.downcast_ref::<wasmtime::Trap>().is_some() {
        134
    } else {
        eprintln!("Error: {e:?}");
        1
    }
}

// One module, run to completion in its own Store: the root instance of
// `mentl-runner run`, or a child of `mentl_host.exec`. Both shapes are the
// same fn because they ARE the same thing — an instance over its own memory
// with its own WASI context and its own thread family.
fn link_and_run(engine: &Engine, module: Module, spec: RunSpec) -> Result<i32> {
    let mut linker = make_linker(engine)?;
    let ctx = Arc::new(ThreadCtx {
        engine: engine.clone(),
        module: module.clone(),
        linker: OnceLock::new(),
        spec,
        next_tid: AtomicI32::new(1),
    });
    let host = Host {
        wasi: build_wasi(&ctx.spec),
        threads: ctx.clone(),
        wat: Vec::new(),
    };
    let mut store = Store::new(engine, host);

    // A module following the wasi-threads convention IMPORTS its shared
    // memory; create one at the exact declared type and link it under the
    // import's own module/name so every instance (main + spawned) shares
    // it. Mentl's emit uses exactly this shape for a spawning module; for
    // a thread-free module (defined memory, no imports here) the loop is
    // a no-op and each run owns its self-contained memory.
    for import in module.imports() {
        if let ExternType::Memory(mt) = import.ty() {
            if !mt.is_shared() {
                bail!(
                    "memory import {}.{} is not shared; the runner only links shared memories",
                    import.module(),
                    import.name()
                );
            }
            let mem = SharedMemory::new(engine, mt)?;
            linker.define(&mut store, import.module(), import.name(), mem)?;
        }
    }

    ctx.linker
        .set(linker.clone())
        .map_err(|_| format_err!("linker initialized twice"))?;

    let instance = linker.instantiate(&mut store, &module)?;
    let start = instance.get_typed_func::<(), ()>(&mut store, "_start")?;
    match start.call(&mut store, ()) {
        Ok(()) => Ok(0),
        Err(e) => {
            if let Some(exit) = e.downcast_ref::<I32Exit>() {
                Ok(exit.0)
            } else {
                Err(e)
            }
        }
    }
}

struct Cli {
    spec: RunSpec,
    module_path: String,
}

fn parse_cli() -> Result<Cli> {
    let mut args = std::env::args().skip(1);
    match args.next().as_deref() {
        Some("run") => {}
        other => bail!("usage: mentl-runner run [flags] <module.wasm> [args...] (got {other:?})"),
    }
    let mut preopens = Vec::new();
    let mut envs = Vec::new();
    let mut module_path: Option<String> = None;
    while let Some(a) = args.next() {
        match a.as_str() {
            // engine/CLI tuning flags from wt-env.sh — the runner always
            // enables threads + tail-call, so the values are consumed and
            // dropped (a joined form like -Wthreads=y is self-contained).
            "-W" | "-S" | "-D" => {
                args.next()
                    .ok_or_else(|| format_err!("{a} expects a value"))?;
            }
            _ if a.starts_with("-W") || a.starts_with("-S") || a.starts_with("-D") => {}
            "--dir" => {
                let v = args.next().ok_or_else(|| format_err!("--dir expects a value"))?;
                let (host, guest) = match v.split_once("::") {
                    Some((h, g)) => (h.to_string(), g.to_string()),
                    None => (v.clone(), v.clone()),
                };
                preopens.push((host, guest));
            }
            "--env" => {
                let v = args.next().ok_or_else(|| format_err!("--env expects a value"))?;
                let (k, val) = v
                    .split_once('=')
                    .ok_or_else(|| format_err!("--env expects K=V, got {v}"))?;
                envs.push((k.to_string(), val.to_string()));
            }
            _ if a.starts_with('-') && module_path.is_none() => {
                bail!("unknown flag before module: {a}");
            }
            _ => {
                module_path = Some(a);
                break;
            }
        }
    }
    let module_path = module_path.ok_or_else(|| format_err!("no module path given"))?;
    // Everything after the module is guest argv; argv[0] is the module path
    // as given (the wasmtime CLI convention the mentl shim relies on).
    let mut argv = vec![module_path.clone()];
    argv.extend(args);
    Ok(Cli {
        spec: RunSpec {
            argv,
            preopens,
            envs,
        },
        module_path,
    })
}

fn main() {
    let code = match run() {
        Ok(code) => code,
        Err(e) => exit_status_of(&e),
    };
    std::process::exit(code);
}

fn run() -> Result<i32> {
    let cli = parse_cli()?;

    let mut config = Config::new();
    config.wasm_threads(true);
    // 43+ splits shared-memory support out of the threads proposal switch
    // (the same split wt-env.sh probes at the CLI as -W shared-memory=y).
    config.shared_memory(true);
    config.wasm_tail_call(true);
    let engine = Engine::new(&config)?;

    // Module::from_file reads a binary OR the text form — the same reader
    // exec uses on the streamed WAT, so `mentl-runner run x.wat` is legal.
    let module = Module::from_file(&engine, &cli.module_path)
        .map_err(|e| e.context(format!("loading {}", cli.module_path)))?;
    link_and_run(&engine, module, cli.spec)
}
