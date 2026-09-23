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
// THE SOCKET SEAM (Hβ.ops.runner-owns-the-p1-socket). The listening verbs
// (`mentl session`, `mentl space`) speak WASI preview1's legacy socket
// protocol — a preopened listener found by probing the fd table, then
// poll_oneoff / sock_accept / fd_read / fd_write / fd_close on it (lib/net.mn)
// — which wasmtime's CLI served through `-S tcplisten=` up to 36 and
// wasmtime-wasi 47 does not implement at all (sock_accept is "not
// implemented"; the CLI dropped the flag). The CLI could not carry the
// wheel past that either way: a wheel that performs the exec seam imports
// `mentl_host`, which no CLI defines (`-W unknown-imports-trap` is applied
// after the wasi-threads shim has already instantiated, measured on 36.0.2).
// So the runner owns the sockets: `-S tcplisten=ADDR` binds a listener and
// RESERVES its fd as one more preopen slot (the guest's table stays
// positional, dirs first then the listener, exactly the shape the wheel
// probes). The five socket-facing p1 ops reach the guest through a
// TRAMPOLINE module the runner writes and instantiates beside the guest:
// it imports the guest's shared memory, re-exports it as "memory", and each
// of its five functions asks the runner's socket seam (`mentl_sock.*`, -1 =
// not a socket) before falling back to wasmtime-wasi's own definition. The
// trampoline exists because a host function calling another host function
// has no calling wasm frame, and the adapter finds guest memory through
// that frame ("missing required memory export", measured on the first
// file read through a direct host-to-host forward). Only a run with a
// listener gets the trampoline; every other run links the plain adapter.
// The listener is nonblocking so the wheel's probe reads EAGAIN exactly as
// it did on the CLI; a poll on it accepts and parks the connection for the
// sock_accept that follows; connections block in the read itself, so a
// poll on one is already-ready.
//
// CLI contract (argv-compatible with the wt_run subset of the wasmtime CLI):
//   mentl-runner run [-W v] [-S v] [-D v] [--dir h[::g]] [--env K=V] \
//                    <module.wasm|.wat> [guest argv...]
// -W/-D values are parsed and ignored (threads + tail-call are always on);
// -S tcplisten=ADDR binds the listening socket, other -S values are ignored;
// stdin/stdout/stderr pass through; exit code = guest exit code, whatever
// its value; a trap exits 134 (the wasmtime CLI's trap status, banked by
// the micro battery).

use wasmtime::{Result, bail, format_err};
use std::collections::HashMap;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::{Arc, Mutex, OnceLock};
use wasmtime::{
    Caller, Config, Engine, Extern, ExternType, Linker, MemoryType, Module, SharedMemory, Store,
};
use wasmtime_wasi::p1::WasiP1Ctx;
use wasmtime_wasi::{DirPerms, FilePerms, I32Exit, WasiCtxBuilder};

// wasi-threads: a spawned thread id is positive and stays below 2^29 so it
// packs beside the wait/notify sentinel values.
const MAX_TID: i32 = 0x1FFF_FFFF;

// preview1 errno values the socket seam answers with.
const ERRNO_AGAIN: i32 = 6;
const ERRNO_IO: i32 = 29;
const ERRNO_NOTSOCK: i32 = 57;
const ERRNO_PIPE: i32 = 64;
// The seam's "not a socket fd — ask the adapter" answer to the trampoline.
const NOT_MINE: i32 = -1;
// Connection fds live far above anything wasmtime-wasi's table hands out,
// so a socket fd can never collide with a file the guest opens later.
const FIRST_CONN_FD: i32 = 1 << 20;
// preview1 subscription/event layout (48-byte subscription, 32-byte event).
const SUB_TAG: usize = 8;
const SUB_FD: usize = 16;
const EV_ERROR: usize = 8;
const EV_TYPE: usize = 10;

#[derive(Clone)]
struct RunSpec {
    argv: Vec<String>,
    preopens: Vec<(String, String)>,
    envs: Vec<(String, String)>,
    // `-S tcplisten=ADDR`: the listening verbs' socket. Never inherited by
    // an exec'd child — a program `mentl run` executes is not the server.
    tcplisten: Option<String>,
}

// The socket seam's state, shared by every thread of one instance family.
struct Sockets {
    listener: Option<TcpListener>,
    listener_fd: i32,
    // A connection the listener's poll accepted, waiting for sock_accept.
    pending: Option<TcpStream>,
    streams: HashMap<i32, TcpStream>,
    next_fd: i32,
}

impl Sockets {
    fn none() -> Self {
        Sockets {
            listener: None,
            listener_fd: -1,
            pending: None,
            streams: HashMap::new(),
            next_fd: FIRST_CONN_FD,
        }
    }
    fn is_conn(&self, fd: i32) -> bool {
        self.streams.contains_key(&fd)
    }
    fn is_listener(&self, fd: i32) -> bool {
        self.listener.is_some() && fd == self.listener_fd
    }
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
    // It holds only store-agnostic definitions; the trampoline's functions
    // belong to one store and are defined per instantiation (shadow_linker).
    linker: OnceLock<Linker<Host>>,
    spec: RunSpec,
    next_tid: AtomicI32,
    sockets: Mutex<Sockets>,
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
                let linker = match instance_linker(&mut store, linker, &ctx.module, &ctx) {
                    Ok(l) => l,
                    Err(e) => {
                        eprintln!("mentl-runner: wasi-thread-{tid} linker: {e:?}");
                        std::process::exit(134);
                    }
                };
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

// The write half of the same view: bytes into the caller's memory at ptr.
fn write_guest_bytes(caller: &mut Caller<'_, Host>, ptr: i32, bytes: &[u8]) -> Result<()> {
    let (start, n) = (ptr as u32 as usize, bytes.len());
    match caller.get_export("memory") {
        Some(Extern::SharedMemory(sm)) => {
            let data = sm.data();
            if start.checked_add(n).map_or(true, |end| end > data.len()) {
                bail!("mentl_host: guest range {start}+{n} is outside memory");
            }
            for (i, b) in bytes.iter().enumerate() {
                unsafe { *data[start + i].get() = *b };
            }
            Ok(())
        }
        Some(Extern::Memory(m)) => {
            let data = m.data_mut(&mut *caller);
            if start.checked_add(n).map_or(true, |end| end > data.len()) {
                bail!("mentl_host: guest range {start}+{n} is outside memory");
            }
            data[start..start + n].copy_from_slice(bytes);
            Ok(())
        }
        _ => bail!("mentl_host: the guest exports no memory"),
    }
}

fn read_guest_i32(caller: &mut Caller<'_, Host>, ptr: i32) -> Result<i32> {
    let b = read_guest_bytes(caller, ptr, 4)?;
    Ok(i32::from_le_bytes([b[0], b[1], b[2], b[3]]))
}

fn write_guest_i32(caller: &mut Caller<'_, Host>, ptr: i32, v: i32) -> Result<()> {
    write_guest_bytes(caller, ptr, &v.to_le_bytes())
}

// An io error as the preview1 errno the wheel's loops read.
fn errno_of(e: &std::io::Error) -> i32 {
    match e.kind() {
        std::io::ErrorKind::WouldBlock => ERRNO_AGAIN,
        std::io::ErrorKind::BrokenPipe | std::io::ErrorKind::ConnectionReset => ERRNO_PIPE,
        _ => ERRNO_IO,
    }
}

// The linker every instance is built from: the p1 host, wasi-threads'
// spawn, the two ops of the exec seam, and the socket seam's five host
// halves (`mentl_sock`, reached only through the trampoline). Shared-memory
// imports are defined per module (they need the module's declared type) in
// link_and_run.
fn make_linker(engine: &Engine) -> Result<Linker<Host>> {
    let mut linker: Linker<Host> = Linker::new(engine);
    wasmtime_wasi::p1::add_to_linker_sync(&mut linker, |h: &mut Host| &mut h.wasi)?;
    // proc_exit is the RUNNER's, not the library's. wasmtime-wasi's p1
    // adapter refuses any status outside [0..126) ("exit with invalid exit
    // status"), so a guest whose answer is 134 — `mentl run x` where x
    // trapped, the exec seam handing the child's status straight through —
    // died here with exit 1 and a host backtrace instead of the status it
    // computed. The process exit is the guest's value, whatever it is; the
    // OS truncates to a byte, and that is the only policy that belongs at
    // this boundary. Same error type the adapter raises, so the mapping in
    // link_and_run reads both alike (tools/runner/smoke/exit-status.wat).
    linker.allow_shadowing(true);
    linker.func_wrap(
        "wasi_snapshot_preview1",
        "proc_exit",
        |code: i32| -> Result<()> { Err(I32Exit(code).into()) },
    )?;
    linker.allow_shadowing(false);
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
            spec.tcplisten = None;
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
    // ── the socket seam's host halves — each answers NOT_MINE for a
    //    non-socket fd, and the trampoline then asks the adapter ──
    linker.func_wrap(
        "mentl_sock",
        "sock_accept",
        |mut caller: Caller<'_, Host>, fd: i32, _flags: i32, ro: i32| -> Result<i32> {
            let ctx = caller.data().threads.clone();
            let mut socks = ctx.sockets.lock().unwrap();
            if !socks.is_listener(fd) {
                // The wheel's find_listener probes every low fd with this op;
                // a dir preopen answers "not a socket" — never the adapter,
                // whose sock_accept is a trap.
                return Ok(ERRNO_NOTSOCK);
            }
            let stream = match socks.pending.take() {
                Some(s) => s,
                None => match socks.listener.as_ref().unwrap().accept() {
                    Ok((s, _)) => s,
                    Err(e) => return Ok(errno_of(&e)),
                },
            };
            if let Err(e) = stream.set_nonblocking(false) {
                return Ok(errno_of(&e));
            }
            let new_fd = socks.next_fd;
            socks.next_fd += 1;
            socks.streams.insert(new_fd, stream);
            drop(socks);
            write_guest_i32(&mut caller, ro, new_fd)?;
            Ok(0)
        },
    )?;
    linker.func_wrap(
        "mentl_sock",
        "poll_oneoff",
        |mut caller: Caller<'_, Host>, subs: i32, events: i32, nsubs: i32, nevents: i32| -> Result<i32> {
            if nsubs != 1 {
                return Ok(NOT_MINE);
            }
            let sub = read_guest_bytes(&mut caller, subs, 48)?;
            let fd = i32::from_le_bytes([sub[SUB_FD], sub[SUB_FD + 1], sub[SUB_FD + 2], sub[SUB_FD + 3]]);
            let tag = sub[SUB_TAG];
            let ctx = caller.data().threads.clone();
            {
                let mut socks = ctx.sockets.lock().unwrap();
                if !(socks.is_listener(fd) || socks.is_conn(fd)) {
                    return Ok(NOT_MINE);
                }
                // A readable-poll on the listener IS the wait: accept blocking,
                // park the connection for the sock_accept that follows. A
                // connection blocks in its own read/write; its poll is
                // already-ready.
                if socks.is_listener(fd) && tag == 1 && socks.pending.is_none() {
                    let l = socks.listener.as_ref().unwrap();
                    l.set_nonblocking(false)?;
                    let accepted = l.accept();
                    l.set_nonblocking(true)?;
                    match accepted {
                        Ok((s, _)) => socks.pending = Some(s),
                        Err(e) => eprintln!("mentl-runner: accept: {e}"),
                    }
                }
            }
            let mut ev = [0u8; 32];
            ev[..8].copy_from_slice(&sub[..8]);
            ev[EV_ERROR] = 0;
            ev[EV_ERROR + 1] = 0;
            ev[EV_TYPE] = tag;
            write_guest_bytes(&mut caller, events, &ev)?;
            write_guest_i32(&mut caller, nevents, 1)?;
            Ok(0)
        },
    )?;
    linker.func_wrap(
        "mentl_sock",
        "fd_read",
        |mut caller: Caller<'_, Host>, fd: i32, iovs: i32, iovs_len: i32, nread: i32| -> Result<i32> {
            let ctx = caller.data().threads.clone();
            if !ctx.sockets.lock().unwrap().is_conn(fd) {
                return Ok(NOT_MINE);
            }
            if iovs_len < 1 {
                write_guest_i32(&mut caller, nread, 0)?;
                return Ok(0);
            }
            let buf = read_guest_i32(&mut caller, iovs)?;
            let cap = read_guest_i32(&mut caller, iovs + 4)? as u32 as usize;
            let mut data = vec![0u8; cap];
            let got = {
                let mut socks = ctx.sockets.lock().unwrap();
                let s = socks.streams.get_mut(&fd).unwrap();
                s.read(&mut data)
            };
            match got {
                Ok(n) => {
                    write_guest_bytes(&mut caller, buf, &data[..n])?;
                    write_guest_i32(&mut caller, nread, n as i32)?;
                    Ok(0)
                }
                Err(e) => Ok(errno_of(&e)),
            }
        },
    )?;
    linker.func_wrap(
        "mentl_sock",
        "fd_write",
        |mut caller: Caller<'_, Host>, fd: i32, iovs: i32, iovs_len: i32, nwritten: i32| -> Result<i32> {
            let ctx = caller.data().threads.clone();
            if !ctx.sockets.lock().unwrap().is_conn(fd) {
                return Ok(NOT_MINE);
            }
            let mut out = Vec::new();
            for i in 0..iovs_len.max(0) {
                let buf = read_guest_i32(&mut caller, iovs + 8 * i)?;
                let len = read_guest_i32(&mut caller, iovs + 8 * i + 4)?;
                out.extend_from_slice(&read_guest_bytes(&mut caller, buf, len)?);
            }
            let wrote = {
                let mut socks = ctx.sockets.lock().unwrap();
                let s = socks.streams.get_mut(&fd).unwrap();
                s.write_all(&out)
            };
            match wrote {
                Ok(()) => {
                    write_guest_i32(&mut caller, nwritten, out.len() as i32)?;
                    Ok(0)
                }
                Err(e) => Ok(errno_of(&e)),
            }
        },
    )?;
    linker.func_wrap(
        "mentl_sock",
        "fd_close",
        |caller: Caller<'_, Host>, fd: i32| -> Result<i32> {
            let ctx = caller.data().threads.clone();
            let mut socks = ctx.sockets.lock().unwrap();
            if socks.streams.remove(&fd).is_some() || socks.is_listener(fd) {
                Ok(0)
            } else {
                Ok(NOT_MINE)
            }
        },
    )?;
    Ok(linker)
}

// The trampoline: the guest's five socket-facing p1 imports, each a WASM
// function that asks the socket seam first and the adapter second. It
// imports the guest's own shared memory and re-exports it, which is what
// lets both callees read guest memory through the calling wasm frame.
fn trampoline_wat(mem_module: &str, mem_name: &str, mt: &MemoryType) -> String {
    let max = mt.maximum().map(|m| format!(" {m}")).unwrap_or_default();
    let shared = if mt.is_shared() { " shared" } else { "" };
    let min = mt.minimum();
    format!(
        r#"(module
  (import "{mem_module}" "{mem_name}" (memory {min}{max}{shared}))
  (export "memory" (memory 0))
  (import "mentl_sock" "sock_accept" (func $s_accept (param i32 i32 i32) (result i32)))
  (import "mentl_sock" "poll_oneoff" (func $s_poll (param i32 i32 i32 i32) (result i32)))
  (import "mentl_sock" "fd_read" (func $s_read (param i32 i32 i32 i32) (result i32)))
  (import "mentl_sock" "fd_write" (func $s_write (param i32 i32 i32 i32) (result i32)))
  (import "mentl_sock" "fd_close" (func $s_close (param i32) (result i32)))
  (import "wasi_snapshot_preview1" "poll_oneoff" (func $b_poll (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_read" (func $b_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func $b_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_close" (func $b_close (param i32) (result i32)))
  (func (export "sock_accept") (param i32 i32 i32) (result i32)
    (call $s_accept (local.get 0) (local.get 1) (local.get 2)))
  (func (export "poll_oneoff") (param i32 i32 i32 i32) (result i32) (local $r i32)
    (local.set $r (call $s_poll (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
    (if (result i32) (i32.eq (local.get $r) (i32.const -1))
      (then (call $b_poll (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
      (else (local.get $r))))
  (func (export "fd_read") (param i32 i32 i32 i32) (result i32) (local $r i32)
    (local.set $r (call $s_read (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
    (if (result i32) (i32.eq (local.get $r) (i32.const -1))
      (then (call $b_read (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
      (else (local.get $r))))
  (func (export "fd_write") (param i32 i32 i32 i32) (result i32) (local $r i32)
    (local.set $r (call $s_write (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
    (if (result i32) (i32.eq (local.get $r) (i32.const -1))
      (then (call $b_write (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
      (else (local.get $r))))
  (func (export "fd_close") (param i32) (result i32) (local $r i32)
    (local.set $r (call $s_close (local.get 0)))
    (if (result i32) (i32.eq (local.get $r) (i32.const -1))
      (then (call $b_close (local.get 0)))
      (else (local.get $r)))))"#
    )
}

const TRAMPOLINE_OPS: [&str; 5] = ["sock_accept", "poll_oneoff", "fd_read", "fd_write", "fd_close"];

// The linker one instance is built from. Without a listener it is the
// shared linker itself; with one, a copy whose five socket-facing p1
// entries are this store's trampoline functions (store-bound, hence never
// stored in ThreadCtx).
fn instance_linker(
    store: &mut Store<Host>,
    shared: &Linker<Host>,
    guest: &Module,
    ctx: &ThreadCtx,
) -> Result<Linker<Host>> {
    if ctx.sockets.lock().unwrap().listener.is_none() {
        return Ok(shared.clone());
    }
    let (mem_module, mem_name, mt) = guest
        .imports()
        .find_map(|i| match i.ty() {
            ExternType::Memory(mt) => Some((i.module().to_string(), i.name().to_string(), mt)),
            _ => None,
        })
        .ok_or_else(|| {
            format_err!("the socket seam needs a guest that imports its shared memory")
        })?;
    let tramp = Module::new(store.engine(), trampoline_wat(&mem_module, &mem_name, &mt))?;
    let tramp = shared.instantiate(&mut *store, &tramp)?;
    let mut linker = shared.clone();
    linker.allow_shadowing(true);
    for name in TRAMPOLINE_OPS {
        let f = tramp
            .get_func(&mut *store, name)
            .ok_or_else(|| format_err!("trampoline exports no {name}"))?;
        linker.define(&mut *store, "wasi_snapshot_preview1", name, f)?;
    }
    linker.allow_shadowing(false);
    Ok(linker)
}

// A guest trap surfaces as an error; the wasmtime CLI maps traps to exit
// 134 (128+SIGABRT) and the micro battery banks that number, so the runner
// speaks the same status — for the root instance and for an exec'd child.
// It speaks the TRAP too, as the CLI does: the reason and the wasm backtrace
// on stderr. This fn answered 134 in silence (measured 2026-09-22 — a query
// that died inside the medium printed nothing at all), which is the one
// failure a runner must never make quiet: the trap is the measurement that
// names the defect, and without it the only instrument left is a guess.
fn exit_status_of(e: &wasmtime::Error) -> i32 {
    eprintln!("Error: {e:?}");
    if e.downcast_ref::<wasmtime::Trap>().is_some() {
        134
    } else {
        1
    }
}

// One module, run to completion in its own Store: the root instance of
// `mentl-runner run`, or a child of `mentl_host.exec`. Both shapes are the
// same fn because they ARE the same thing — an instance over its own memory
// with its own WASI context and its own thread family.
fn link_and_run(engine: &Engine, module: Module, mut spec: RunSpec) -> Result<i32> {
    // The listening socket, bound here and given a preopen SLOT: the guest's
    // fd table stays positional (dirs, then the listener), and the reserved
    // slot keeps the adapter from ever handing that number to a file.
    let mut sockets = Sockets::none();
    if let Some(addr) = &spec.tcplisten {
        let l = TcpListener::bind(addr).map_err(|e| format_err!("tcplisten {addr}: {e}"))?;
        l.set_nonblocking(true)?;
        spec.preopens.push(("/tmp".to_string(), "/mentl-listener".to_string()));
        sockets.listener = Some(l);
        sockets.listener_fd = 3 + spec.preopens.len() as i32 - 1;
    }
    let mut linker = make_linker(engine)?;
    let ctx = Arc::new(ThreadCtx {
        engine: engine.clone(),
        module: module.clone(),
        linker: OnceLock::new(),
        spec,
        next_tid: AtomicI32::new(1),
        sockets: Mutex::new(sockets),
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

    let linker = instance_linker(&mut store, &linker, &module, &ctx)?;
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
    let mut tcplisten = None;
    let mut module_path: Option<String> = None;
    // `-S tcplisten=ADDR` is the one -S value the runner acts on; every
    // other -W/-S/-D value is engine tuning the runner has built in.
    let note_s = |v: &str, tcplisten: &mut Option<String>| {
        if let Some(addr) = v.strip_prefix("tcplisten=") {
            *tcplisten = Some(addr.to_string());
        }
    };
    while let Some(a) = args.next() {
        match a.as_str() {
            "-W" | "-D" => {
                args.next()
                    .ok_or_else(|| format_err!("{a} expects a value"))?;
            }
            "-S" => {
                let v = args.next().ok_or_else(|| format_err!("-S expects a value"))?;
                note_s(&v, &mut tcplisten);
            }
            _ if a.starts_with("-S") => note_s(&a[2..], &mut tcplisten),
            _ if a.starts_with("-W") || a.starts_with("-D") => {}
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
            tcplisten,
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
    // the exec seam uses for a streamed child.
    let module = Module::from_file(&engine, &cli.module_path)?;
    link_and_run(&engine, module, cli.spec)
}
