/* wheel-worker.js — the wheel's execution host: the runner pattern at the
   browser host (the browser leg of Hβ.ops.wasmtime-runner-migration).

   The pinned boot is a SPAWNING module: it imports the shared image
   (env.memory, 8192-min/65536-max shared in the IDE derivation) plus
   wasi.thread-spawn, and the converged judgment spawns a task per stmt.
   Two substrate facts force this file's shape:

     - memory.atomic.wait32 (the task join) is FORBIDDEN on the browser
       main thread, so ALL wheel execution lives in workers — the page
       never instantiates the module;
     - wasi.thread-spawn needs a real host thread, so the shim spawns a
       nested worker per task. Each task worker instantiates a FRESH
       instance over the run's shared memory (the instance-per-thread
       convention wasmtime follows; re-writing the module's constant data
       segments over the live image is idempotent — identical bytes, the
       same re-instantiation wasmtime performs per spawned thread) and
       calls the module's own wasi_thread_start(tid, arg).

   One script, two hosts — browser Worker and node worker_threads — so the
   page and the headless gate (ide/test-shim.mjs) drive the SAME execution
   host and cannot drift. Two roles:

     {role:"run", module, memPages?, argv, stdin?, vfs?, stubSpawn?}
       (a reply carries `written`: the vfs files the wheel wrote — the
        accept's projection of the module back to its text)
        -> creates the shared memory, instantiates, runs _start, drains the
           task fan, posts {k:"result", exit, out, err, trapped, tasks}
     {role:"task", module, memory, tids, tid, arg, seq, vfs?}
        -> instantiates over the run's memory, calls wasi_thread_start,
           posts {k:"task-done", seq, out, err}, closes itself

   Synchronization is the WASM side's own: the task record's completion
   word joined by the wheel's atomic wait. The task-done message only
   carries the worker's captured stdio back; a crashed task never stamps
   its completion word, so the root's join hangs and the CLIENT's run
   timeout reports it loudly — never a fabricated result. */
"use strict";

const NODE = typeof self === "undefined";
const HOST = NODE
  ? (() => {
      const { parentPort, Worker } = require("node:worker_threads");
      return {
        listen(fn) { parentPort.on("message", fn); },
        post(m) { parentPort.postMessage(m); },
        spawn() {
          const w = new Worker(__filename);
          return {
            post: (m) => w.postMessage(m),
            listen: (fn) => { w.removeAllListeners("message"); w.on("message", fn); },
            onError: (fn) => { w.removeAllListeners("error"); w.on("error", fn); },
            kill: () => w.terminate(),
          };
        },
        close() { parentPort.removeAllListeners(); parentPort.close(); },
      };
    })()
  : {
      listen(fn) { self.onmessage = (e) => fn(e.data); },
      post(m) { self.postMessage(m); },
      spawn() {
        const w = new Worker(self.location.href);
        return {
          post: (m) => w.postMessage(m),
          listen: (fn) => { w.onmessage = (e) => fn(e.data); },
          onError: (fn) => { w.onerror = (e) => fn(e); },
          kill: () => w.terminate(),
        };
      },
      close() { self.close(); },
    };

let DEBUG = false;
const DBG = (m) => { if (DEBUG) console.log("WHEELW " + m); };

const td = new TextDecoder(), te = new TextEncoder();
const cat = (cs) => { const n = cs.reduce((a, c) => a + c.length, 0); const b = new Uint8Array(n); let o = 0; for (const c of cs) { b.set(c, o); o += c.length; } return b; };

/* ── the one WASI shim — the page's two former shims unified ───────────────
   argv [] is compile-stdin (argc 0 -> the wheel's stdin fork); a vfs
   preopens fd 3 as "." (the address transport's --dir). TextDecoder refuses
   SharedArrayBuffer-backed views, so every read COPIES (.slice) before
   decoding — the one shared-memory tax; writes (TypedArray.set into a
   shared view) are allowed. */
function makeShim({ memory, argv, stdin, vfs, spawnFn }) {
  const dv = () => new DataView(memory.buffer), u8 = () => new Uint8Array(memory.buffer);
  const out = [], err = [];
  const written = new Set();   // vfs files this instance wrote (the accept's projection)
  let srcPos = 0;
  const fds = new Map(); let nextFd = 8;
  const args = (argv || []).map((s) => te.encode(s + "\0"));
  const argTotal = args.reduce((a, b) => a + b.length, 0);
  const readStr = (p, l) => td.decode(u8().slice(p, p + l));
  const norm = (p) => p.replace(/^\.\//, "").replace(/^\//, "");
  const stat = (ptr, ft, sz) => { const v = dv(); for (let i = 0; i < 64; i += 8) v.setBigUint64(ptr + i, 0n, true);
    v.setUint8(ptr + 16, ft); v.setBigUint64(ptr + 24, 1n, true); v.setBigUint64(ptr + 32, BigInt(sz), true); };
  const P = {
    proc_exit(code) { const e = new Error("exit"); e.exitCode = code; throw e; },
    args_sizes_get(a, b) { dv().setUint32(a, args.length, true); dv().setUint32(b, argTotal, true); return 0; },
    args_get(ap, bp) { let p = bp; args.forEach((a, i) => { dv().setUint32(ap + 4 * i, p, true); u8().set(a, p); p += a.length; }); return 0; },
    fd_write(fd, io, n, o) { const v = dv(); let t = 0;
      const h = fds.get(fd);
      for (let i = 0; i < n; i++) { const p = v.getUint32(io + 8 * i, true), l = v.getUint32(io + 8 * i + 4, true), b = u8().slice(p, p + l);
        if (h && !h.dir) {
          // a FILE the wheel writes — `fs_write_file` after `mentl accept`
          // projects the accepted graph back to the module's text. The vfs
          // entry IS the file: splice the bytes in at the fd's position and
          // remember the name, so the reply can hand the page what changed.
          const d = vfs[h.name], nd = new Uint8Array(Math.max(d.length, h.pos + b.length));
          nd.set(d); nd.set(b, h.pos); vfs[h.name] = nd; h.pos += b.length; written.add(h.name);
        } else { (fd === 2 ? err : out).push(b); }
        t += l; }
      v.setUint32(o, t, true); return 0; },
    fd_read(fd, io, n, o) { const v = dv();
      if (fd === 0) {
        if (!stdin) { v.setUint32(o, 0, true); return 0; }
        let t = 0;
        for (let i = 0; i < n && srcPos < stdin.length; i++) { const p = v.getUint32(io + 8 * i, true), l = v.getUint32(io + 8 * i + 4, true);
          const k = Math.min(l, stdin.length - srcPos); u8().set(stdin.subarray(srcPos, srcPos + k), p); srcPos += k; t += k; }
        v.setUint32(o, t, true); return 0;
      }
      const h = fds.get(fd); if (!h || h.dir) return 8; const d = vfs[h.name]; let t = 0;
      for (let i = 0; i < n && h.pos < d.length; i++) { const p = v.getUint32(io + 8 * i, true), l = v.getUint32(io + 8 * i + 4, true);
        const k = Math.min(l, d.length - h.pos); u8().set(d.subarray(h.pos, h.pos + k), p); h.pos += k; t += k; }
      v.setUint32(o, t, true); return 0; },
    fd_close(fd) { fds.delete(fd); return 0; },
    fd_seek(fd, off, w, o) { const h = fds.get(fd); if (!h) return 8;
      h.pos = w === 0 ? Number(off) : w === 1 ? h.pos + Number(off) : vfs[h.name].length + Number(off);
      dv().setBigUint64(o, BigInt(h.pos), true); return 0; },
    fd_prestat_get(fd, p) { if (vfs && fd === 3) { dv().setUint8(p, 0); dv().setUint32(p + 4, 1, true); return 0; } return 8; },
    fd_prestat_dir_name(fd, p) { if (vfs && fd === 3) { u8()[p] = 46; return 0; } return 8; },   // "."
    path_open(b, df, pp, pl, of, rb, ri, ff, o) { if (!vfs) return 44; const nm = norm(readStr(pp, pl));
      if (nm === "" || nm === ".") { const fd = nextFd++; fds.set(fd, { name: ".", pos: 0, dir: 1 }); dv().setUint32(o, fd, true); return 0; }
      // WASI oflags: CREAT = 1, TRUNC = 8 — the wheel's fs_write_file opens
      // with both (0x9). A create births the entry; a truncate empties it.
      if (!(nm in vfs)) { if (!(of & 1)) return 44; vfs[nm] = new Uint8Array(0); }
      if (of & 8) vfs[nm] = new Uint8Array(0);
      const fd = nextFd++; fds.set(fd, { name: nm, pos: 0 }); dv().setUint32(o, fd, true); return 0; },
    path_filestat_get(fd, fl, pp, pl, s) { if (!vfs) return 44; const nm = norm(readStr(pp, pl)); if (!(nm in vfs)) return 44; stat(s, 4, vfs[nm].length); return 0; },
    fd_filestat_get(fd, s) { const h = fds.get(fd); if (!h) return 8; stat(s, h.dir ? 3 : 4, h.dir ? 0 : vfs[h.name].length); return 0; },
    fd_fdstat_get(fd, p) { if (vfs && fd === 3) { dv().setUint8(p, 3); return 0; } const h = fds.get(fd); if (h) { dv().setUint8(p, h.dir ? 3 : 4); return 0; } return 8; },
    fd_readdir() { return vfs ? 0 : 8; },
    clock_time_get(id, pr, o) { dv().setBigUint64(o, 0n, true); return 0; },
    random_get(p, l) { u8().fill(0, p, p + l); return 0; },
    environ_sizes_get(a, b) { dv().setUint32(a, 0, true); dv().setUint32(b, 0, true); return 0; },
    environ_get() { return 0; },
    path_create_directory() { return 44; }, path_unlink_file() { return 44; }, path_rename() { return 44; },
  };
  const proxy = new Proxy(P, { get(t, k) { return k in t ? t[k] : () => 8; } });
  // The exec seam (`mentl_host.wat_write` / `mentl_host.exec`, tools/runner)
  // is what runs a COMPILED program — `mentl run`, the micro battery — and
  // the page never asks for it. The boot imports the pair, and a browser
  // refuses to instantiate a module whose import module is absent, so the
  // seam is present here as the same thing wasmtime makes of an unknown
  // import: a trap the moment it is reached, never a value. Running the
  // compiled program in the page is `Hβ.felt.ide-run-in-page` (an in-page
  // assembler); until it lands this is the honest socket, and it is loud.
  const seam = (name) => () => { throw new Error(`mentl_host.${name}: the exec seam has no in-page assembler (Hβ.felt.ide-run-in-page)`); };
  const mentl_host = { wat_write: seam("wat_write"), exec: seam("exec") };
  const writtenFiles = () => Object.fromEntries([...written].map((n) => [n, vfs[n]]));
  return { imports: { env: { memory }, wasi_snapshot_preview1: proxy, wasi: { "thread-spawn": spawnFn }, mentl_host }, out, err, writtenFiles };
}

/* ── the pre-armed task pool over a shared-memory queue ────────────────────
   TWO HAZARDS THIS SHAPE EXISTS FOR, both measured 2026-07-29 against node
   (which has neither — the identical blob ran 252 tasks there while Chrome
   hung 90s):
     1. Chrome cannot finish LOADING a nested worker's script while its
        parent worker thread is blocked — so the pool is spawned and
        ARM-handshaked (module + memory + vfs delivered) BEFORE _start can
        ever block.
     2. Chrome flushes a worker's OUTGOING postMessages only when the
        sender yields its event loop — and thread-spawn fires mid-wasm,
        after which the root blocks in the join without ever yielding, so
        a postMessage dispatch never leaves the sender (probed: 16 spawns
        logged, zero task starts, pool provably loaded). The dispatch
        channel is therefore SHARED MEMORY: thread-spawn writes (tid, arg)
        into a SharedArrayBuffer ring and bumps a doorbell with
        Atomics.notify — no event loop anywhere on the path. Emscripten's
        pthread pool converged on the same shape for the same reasons.

   Pool workers consume via Atomics.waitAsync, staying event-loop-live, so
   their task-done stdio messages flush; where waitAsync is missing the
   sync-wait fallback degrades only the stdio channel — the compile stays
   correct, because completion rides the wheel's OWN task-record protocol
   in wasm memory, never these messages. One queue serves the whole run:
   a nested fan (a task spawning tasks) qPushes into the same ring and any
   free pool worker picks it up. tid comes from the run-wide shared
   counter (the host allocates tids, the wasi-threads convention).

   Queue layout (Int32Array on one SAB): [0] doorbell · [1] tail · [2] head
   · cells at 8, CAP × 3 words [ready, tid, arg]. Producers claim a tail
   slot (Atomics.add), publish with ready=1 + notify; consumers claim head
   by CAS, await the publish, zero ready (+ notify the wrap-waiter). */
const POOL_N = 12;   // the judge window is 8; width covers it with slack
const Q_CAP = 1024, Q_CELLS = 8;
function qMake() {
  const q = new Int32Array(new SharedArrayBuffer(4 * (Q_CELLS + Q_CAP * 3)));
  return q;
}
function qPush(q, tid, arg) {
  const i = Atomics.add(q, 1, 1);
  const c = Q_CELLS + (i % Q_CAP) * 3;
  while (Atomics.load(q, c) !== 0) Atomics.wait(q, c, 1, 50);   // wrap: wait for the consumer to free the cell
  q[c + 1] = tid; q[c + 2] = arg;
  Atomics.store(q, c, 1); Atomics.notify(q, c, 1);
  Atomics.add(q, 0, 1); Atomics.notify(q, 0, 1);
}
async function qLoop(q, runTask) {
  const cellWait = async (idx, expect) => {
    if (Atomics.waitAsync) { const w = Atomics.waitAsync(q, idx, expect, 500); if (w.async) await w.value; }
    else Atomics.wait(q, idx, expect, 500);
  };
  for (;;) {
    const bell = Atomics.load(q, 0);
    const h = Atomics.load(q, 2), t = Atomics.load(q, 1);
    if (h < t && Atomics.compareExchange(q, 2, h, h + 1) === h) {
      const c = Q_CELLS + (h % Q_CAP) * 3;
      while (Atomics.load(q, c) !== 1) await cellWait(c, 0);    // await the producer's publish
      const tid = q[c + 1], arg = q[c + 2];
      Atomics.store(q, c, 0); Atomics.notify(q, c, 1);
      await runTask(tid, arg);
      continue;
    }
    await cellWait(0, bell);   // doorbell — the pre-read bell closes the missed-notify race
  }
}
function makePool(n, armMsg) {
  const workers = [], armed = [];
  let doneCount = 0; const io = [];
  for (let i = 0; i < n; i++) {
    const w = HOST.spawn();
    armed.push(new Promise((res) => {
      w.listen((m) => {
        if (m.k === "armed") { res(); return; }
        if (m.k === "task-done") { doneCount++; io.push({ out: m.out, err: m.err }); }
      });
      if (w.onError) w.onError((e) => { res(); io.push({ out: "", err: "pool worker error: " + ((e && e.message) || e) + "\n" }); });
    }));
    w.post(armMsg);
    workers.push(w);
  }
  return {
    ready: Promise.race([Promise.all(armed), new Promise((r) => setTimeout(r, 10000))]),
    stdio: () => ({ doneCount, io }),
    killAll() { for (const w of workers) w.kill(); },
  };
}
function makeFan(q, tids, pool) {
  let spawned = 0;
  const spawn = (arg) => {
    const tid = Atomics.add(tids, 0, 1);
    spawned++;
    qPush(q, tid, arg);
    return tid;
  };
  // io drain only — the wasm-side join already proved every task completed;
  // this collects the stdio messages queued while _start held the thread.
  const drain = async () => {
    const t0 = Date.now();
    while (pool.stdio().doneCount < spawned && Date.now() - t0 < 3000)
      await new Promise((r) => setTimeout(r, 20));
    pool.killAll();
    return { spawned, io: pool.stdio().io };
  };
  return { spawn, drain };
}

let residentSession = null;

HOST.listen(async (msg) => {
  if (msg.role === "session-init") {
    const { module, memPages, vfs, stubSpawn, dbg } = msg;
    DEBUG = !!dbg;
    let memory = null, lastE = null;
    try {
      for (const p of [memPages || 16384, 8192]) {
        try { memory = new WebAssembly.Memory({ initial: p, maximum: 65536, shared: true }); break; }
        catch (e) { lastE = e; }
      }
      if (!memory) throw (lastE || new Error("Failed to allocate shared WebAssembly.Memory"));
      const tids = new Int32Array(new SharedArrayBuffer(4));
      Atomics.store(tids, 0, 1);
      const sessionVfs = Object.assign({}, vfs || {});
      let q = null, pool = null, fan = null;
      if (!stubSpawn) {
        q = qMake();
        pool = makePool(POOL_N, { role: "arm", module, memory, tids, q, vfs: sessionVfs, dbg: DEBUG });
        await pool.ready;
        fan = makeFan(q, tids, pool);
      }
      residentSession = { module, memory, tids, q, pool, fan, vfs: sessionVfs, stubSpawn: !!stubSpawn };
      HOST.post({ k: "session-ready" });
    } catch (e) {
      HOST.post({ k: "session-error", error: String((e && e.message) || e) });
    }
  } else if (msg.role === "session-call") {
    if (!residentSession) {
      HOST.post({ k: "session-reply", id: msg.id, exit: 1, out: "", err: "no resident session active\n", trapped: "no session", tasks: 0 });
      return;
    }
    const { id, argv, stdin, vfsDelta } = msg;
    if (vfsDelta) {
      Object.assign(residentSession.vfs, vfsDelta);
    }
    let trapped = null, exit = 0;
    new Uint8Array(residentSession.memory.buffer).fill(0);
    Atomics.store(residentSession.tids, 0, 1);
    const shim = makeShim({
      memory: residentSession.memory,
      argv: argv || [],
      stdin: stdin || null,
      vfs: residentSession.vfs,
      spawnFn: residentSession.stubSpawn ? (() => -1) : ((a) => { const t = residentSession.fan.spawn(a); return t; }),
    });
    try {
      const inst = await WebAssembly.instantiate(residentSession.module, shim.imports);
      inst.exports._start();
    } catch (e) {
      if (e && e.exitCode !== undefined) exit = e.exitCode;
      else trapped = String((e && e.message) || e);
    }
    const out = td.decode(cat(shim.out));
    const err = td.decode(cat(shim.err));
    HOST.post({ k: "session-reply", id, exit, out, err, trapped, tasks: 0, written: shim.writtenFiles() });
  } else if (msg.role === "session-close") {
    if (residentSession && residentSession.pool) {
      residentSession.pool.killAll();
    }
    residentSession = null;
    HOST.post({ k: "session-closed" });
  } else if (msg.role === "run") {
    const { module, memPages, argv, stdin, vfs, stubSpawn } = msg;
    DEBUG = !!msg.dbg;
    let memory = null, trapped = null, exit = 0, fan = null, shim = null;
    try {
      // the binary declares min 8192 (512MB); provide more when the host
      // allows — the ladder retries smaller on a reservation refusal.
      let lastE = null;
      for (const p of [memPages || 16384, 8192]) {
        try { memory = new WebAssembly.Memory({ initial: p, maximum: 65536, shared: true }); break; }
        catch (e) { lastE = e; }
      }
      if (!memory) throw lastE;
      const tids = new Int32Array(new SharedArrayBuffer(4));
      Atomics.store(tids, 0, 1);
      DBG("memory ok, arming pool");
      let q = null;
      if (!stubSpawn) {
        q = qMake();
        const pool = makePool(POOL_N, { role: "arm", module, memory, tids, q, vfs: vfs || null, dbg: DEBUG });
        await pool.ready;   // every pool worker LOADED + ARMED before _start can block
        DBG("pool armed");
        fan = makeFan(q, tids, pool);
      }
      shim = makeShim({ memory, argv: argv || [], stdin: stdin || null, vfs: vfs || null,
                        spawnFn: stubSpawn ? (() => -1) : ((a) => { const t = fan.spawn(a); DBG("spawn tid=" + t); return t; }) });
      const inst = await WebAssembly.instantiate(module, shim.imports);
      DBG("instantiated, _start");
      try { inst.exports._start(); }
      catch (e) { if (e && e.exitCode !== undefined) exit = e.exitCode; else trapped = String((e && e.message) || e); }
      DBG("_start done");
    } catch (e) { trapped = String((e && e.message) || e); }
    let tasks = 0, extraErr = "";
    if (fan) {
      const d = await fan.drain();
      tasks = d.spawned;
      for (const io of d.io) {
        if (io.err) extraErr += io.err;
        if (io.out) extraErr += "[task stdout] " + io.out;   // never interleaved into the wat stream
      }
    }
    const out = shim ? td.decode(cat(shim.out)) : "";
    const err = (shim ? td.decode(cat(shim.err)) : "") + extraErr;
    HOST.post({ k: "result", exit, out, err, trapped, tasks, written: shim ? shim.writtenFiles() : {} });
  } else if (msg.role === "arm") {
    // a pool worker: hold the run's module/memory/queue, consume tasks
    // until the run's drain kills the pool. Each task gets a FRESH
    // instance over the shared memory (the instance-per-thread convention,
    // here instance-per-task on a pooled thread — identity is stamped per
    // instance by the wheel's own wasi_thread_start). A nested spawn from
    // a task qPushes into the SAME ring — any free pool worker serves it
    // (bounded by the pool where wasmtime's OS threads are unbounded: a
    // fan deeper than the pool would starve, loudly, under the run
    // timeout — unreached by the judgment's stmt-ordered joins).
    const { module, memory, tids, q, vfs } = msg;
    DEBUG = !!msg.dbg;
    const runTask = async (tid, arg) => {
      DBG("task start tid=" + tid);
      const shim = makeShim({ memory, argv: [], stdin: null, vfs: vfs || null,
        spawnFn: (a) => { const t = Atomics.add(tids, 0, 1); qPush(q, t, a); return t; } });
      let err0 = "";
      try {
        const inst = await WebAssembly.instantiate(module, shim.imports);
        inst.exports.wasi_thread_start(tid, arg);
      } catch (e) { err0 = "task " + tid + ": " + String((e && e.message) || e) + "\n"; }
      DBG("task end tid=" + tid);
      HOST.post({ k: "task-done", out: td.decode(cat(shim.out)), err: err0 + td.decode(cat(shim.err)) });
    };
    HOST.post({ k: "armed" });   // the pool awaits this before _start can ever block
    qLoop(q, runTask);   // never returns — the drain kills the worker
  }
});
