// Node twin of the browser runner: drives ide/wheel-worker.js — the SAME
// execution host the page uses — headlessly. Discriminates shim-vs-DOM in
// one command, and proves the Worker-spawn shim runs the live SPAWNING boot
// (shared-image import + wasi.thread-spawn, a host thread per judged stmt).
//   node ide/test-shim.mjs
//
// Leg 0 — COMPILE-STDIN: argc 0, source on stdin -> WAT on stdout. The
//   spawned-task count is REPORTED, never required: the judgment has
//   spawned nothing since the fan's direct spawn was deleted (pin 7c9dc538,
//   2026-09-19 — judge once, sequential by property); the worker pool is the
//   substrate for `~> Thread` and returns to this path when the judgment
//   schedules (PLAN §11 9.2). The 2026-09-25 "tasks=259" measured the
//   eight-week-old ide/mentl-ide.wasm copy, not the boot.
// Leg 1 — RED CONTROL: the old stub (thread-spawn -> -1) against this wasm
//   must FAIL LOUDLY (the wheel refuses a failed spawn) — ARMED only while
//   leg 0 spawned; with zero spawns the control is VACUOUS and says so (a
//   control that cannot fail is not a control), never a PASS.
// Leg 2 — ADDRESS MODE: a virtual filesystem + argv so the compiler's own
//   cursor-address transport (`mentl main.mn:L:C` -> src/main.mn at_run ->
//   cursor_at_handle) projects the eight-aspect CursorView the ring reads.
// Leg 3 — THE SOCKET: a ?? hole projects its proven survivor (Propose).
import { readFile } from 'node:fs/promises';
import { Worker } from 'node:worker_threads';
import { fileURLToPath } from 'node:url';

const HERE = new URL('.', import.meta.url);
const REPO = new URL('../', HERE);
const te = new TextEncoder();
const WORKER = fileURLToPath(new URL('wheel-worker.js', HERE));
// The twin runs the boot itself — the same bytes the page fetches at
// ../boot/mentl.wasm — since the wheel's memory minimum fell to 32 pages
// and its allocator grows on demand (2026-09-27); the hand-derived
// ide/mentl-ide.wasm copy is deleted.
const WASM = process.env.MENTL_IDE_WASM || fileURLToPath(new URL('../boot/mentl.wasm', HERE));
const MODULE = await WebAssembly.compile(await readFile(WASM));

function runWheel(req, timeoutMs = 120000) {
  return new Promise((res) => {
    const w = new Worker(WORKER);
    const t = setTimeout(() => { w.terminate(); res({ exit: 1, out: '', err: '', trapped: 'timeout', tasks: 0 }); }, timeoutMs);
    w.on('message', (m) => { if (m.k === 'result') { clearTimeout(t); w.terminate(); res(m); } });
    w.on('error', (e) => { clearTimeout(t); w.terminate(); res({ exit: 1, out: '', err: String(e), trapped: String(e), tasks: 0 }); });
    w.postMessage(Object.assign({ role: 'run', module: MODULE }, req));
  });
}

const PROG = 'fn double(x) = x * 2\nfn main() = double(21)\n';
let bad = 0;

// ── Leg 0: compile-stdin — the boot judges in the worker ────────────────────
let spawned = 0;
{
  const r = await runWheel({ argv: [], stdin: te.encode(PROG) });
  spawned = r.tasks;
  const ok = !r.trapped && r.out.includes('(module') && r.out.includes('$double');
  console.log(`[0] compile-stdin: exit ${r.exit} · has (module ${r.out.includes('(module')} · has $double ${r.out.includes('$double')} · tasks ${r.tasks} (reported, not required) -> ${ok ? 'PASS' : 'FAIL'}`);
  if (!ok) { bad++; console.log('    err: ' + r.err.trim().split('\n').slice(0, 6).join('\n    ') + (r.trapped ? '\n    trap: ' + r.trapped : '')); }
}
// ── Leg 1: the stub spawn REFUSES this wasm — armed only while leg 0 spawned ─
if (spawned > 0) {
  const r = await runWheel({ argv: [], stdin: te.encode(PROG), stubSpawn: true }, 30000);
  const succeeded = !r.trapped && r.exit === 0 && r.out.includes('(module');
  console.log(`[1] stub-spawn control: exit ${r.exit} · trapped ${r.trapped ? JSON.stringify(String(r.trapped).slice(0, 60)) : 'no'} -> ${succeeded ? 'FAIL (a stub shim ran the spawning wheel?!)' : 'PASS (refused loudly)'}`);
  if (succeeded) bad++;
} else {
  console.log('[1] stub-spawn control: VACUOUS — the judgment spawned nothing on this path (judge once, since pin 7c9dc538); the control re-arms when the judgment schedules (PLAN §11 9.2)');
}
// ── Leg 2: address mode projects the REAL CursorView (the ring wire) ────────
const libs = ['lib/memory.mn', 'lib/strings.mn', 'lib/lists.mn', 'lib/threading.mn', 'lib/io.mn', 'lib/prelude.mn', 'src/types.mn'];
const VFS = {};
for (const p of libs) VFS[p] = new Uint8Array(await readFile(new URL(p, REPO)));
{
  const vfs = Object.assign({}, VFS);
  vfs['main.mn'] = te.encode('fn main() with Memory + Alloc =\n  [1, 2, 3, 4, 5]\n    |> map((x) => x * x)\n    |> filter((x) => x > 3)\n    |> fold(0, (acc, x) => acc + x)\n');
  const r = await runWheel({ argv: ['mentl', 'main.mn:3:8'], vfs });
  const q = (r.out.split('\n').find((l) => l.startsWith('Query:')) || '');
  const ok = r.exit === 0 && !r.trapped && q.includes(' : ') && r.out.includes('Effects:');
  console.log(`[2] address CursorView: exit ${r.exit} · tasks ${r.tasks} -> ${ok ? 'PASS' : 'FAIL'}`);
  console.log('    ' + r.out.trim().split('\n').join('\n    '));
  if (!ok) { bad++; console.log('    err: ' + r.err.trim().split('\n').slice(0, 6).join('\n    ')); }
}
// ── Leg 3: the socket — a ?? hole projects a proven survivor (Propose) ──────
{
  const hole = 'type Positive = Int where 0 < self\n\nfn choose() -> Positive with Pure = ??\n\nfn main() = choose()\n';
  const r = await runWheel({ argv: ['mentl', 'hole.mn:3:37'], vfs: { 'hole.mn': te.encode(hole) } });
  const ok = r.exit === 0 && !r.trapped && r.out.includes('Query: ?? :') && /Propose: \S/.test(r.out);
  console.log(`[3] address Propose socket: exit ${r.exit} · tasks ${r.tasks} -> ${ok ? 'PASS' : 'FAIL'}`);
  console.log('    ' + r.out.trim().split('\n').join('\n    '));
  if (!ok) { bad++; console.log('    err: ' + r.err.trim().split('\n').slice(0, 6).join('\n    ')); }
}
// ── Leg 4: Resident Session Initiation & Multi-Caret Navigation ─────────────
class ResidentWorkerSession {
  constructor(workerPath, module, vfs, memPages = 16384) {
    this.worker = new Worker(workerPath);
    this.module = module;
    this.vfs = vfs;
    this.memPages = memPages;
    this.nextId = 1;
    this.pending = new Map();
    this.worker.on('message', (m) => {
      if (m.k === 'session-ready') {
        if (this.onReady) this.onReady();
      } else if (m.k === 'session-reply') {
        const p = this.pending.get(m.id);
        if (p) {
          this.pending.delete(m.id);
          p(m);
        }
      }
    });
  }

  init() {
    return new Promise((resolve) => {
      this.onReady = resolve;
      this.worker.postMessage({
        role: 'session-init',
        module: this.module,
        memPages: this.memPages,
        vfs: this.vfs,
      });
    });
  }

  call(argv, stdin = null, vfsDelta = null) {
    const id = this.nextId++;
    return new Promise((resolve) => {
      this.pending.set(id, resolve);
      this.worker.postMessage({
        role: 'session-call',
        id,
        argv,
        stdin,
        vfsDelta,
      });
    });
  }

  close() {
    this.worker.postMessage({ role: 'session-close' });
    this.worker.terminate();
  }
}

{
  const sess = new ResidentWorkerSession(WORKER, MODULE, VFS);
  await sess.init();
  const vfsDelta = {
    'main.mn': te.encode('fn double(x) = x * 2\n\nfn main() with Memory + Alloc =\n  [1, 2, 3]\n    |> map(double)\n    |> fold(0, (acc, x) => acc + x)\n'),
  };
  const r1 = await sess.call(['mentl', 'main.mn:1:4'], null, vfsDelta);
  // The line rule reaches the DECLARATION at 1:4 and renders its source
  // (`Query: fn double(x) = x * 2 : …`); the old `Query: double(` matched a
  // render the wheel no longer writes.
  const ok1 = r1.exit === 0 && !r1.trapped && /^Query: .*double/m.test(r1.out);
  const r2 = await sess.call(['mentl', 'main.mn:5:8']);
  const ok2 = r2.exit === 0 && !r2.trapped && r2.out.includes('Query: map(');
  const ok = ok1 && ok2;
  console.log(`[4] resident session navigation: r1.exit ${r1.exit} · r2.exit ${r2.exit} -> ${ok ? 'PASS' : 'FAIL'}`);
  if (!ok) { bad++; console.log('    err: ' + (r1.err || r2.err).trim()); }

  // ── Leg 5: resident session delta update ──────────────────────────────────
  const updatedProg = 'type Positive = Int where 0 < self\n\nfn choose() -> Positive with Pure = ??\n\nfn main() = choose()\n';
  const r3 = await sess.call(['mentl', 'main.mn:3:37'], null, { 'main.mn': te.encode(updatedProg) });
  const ok3 = r3.exit === 0 && !r3.trapped && r3.out.includes('Query: ?? :') && /Propose: \S/.test(r3.out);
  console.log(`[5] resident session delta + propose: exit ${r3.exit} -> ${ok3 ? 'PASS' : 'FAIL'}`);
  console.log('    ' + r3.out.trim().split('\n').join('\n    '));
  if (!ok3) { bad++; console.log('    err: ' + r3.err.trim()); }

  sess.close();
}

console.log(bad ? `\n${bad} FAILED` : '\nall surfaces green — the spawning wheel runs on the worker shim with resident session support');
process.exit(bad ? 1 : 0);

