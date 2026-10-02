// Node twin of the browser runner: drives ide/wheel-worker.js — the SAME
// execution host the page uses — and ide/session-client.js — the page's
// own session client — headlessly, so the page and the gate cannot drift.
//   node ide/test-shim.mjs
//
// Leg 0 — COMPILE-STDIN: argc 0, source on stdin -> WAT on stdout. The
//   spawned-task count is REPORTED, never required: the judgment has
//   spawned nothing since the fan's direct spawn was deleted (pin 7c9dc538,
//   2026-09-19 — judge once, sequential by property), and the boot no
//   longer imports wasi.thread-spawn, so the worker arms no pool for it.
// Leg 1 — RED CONTROL: the old stub (thread-spawn -> -1) against this wasm
//   must FAIL LOUDLY (the wheel refuses a failed spawn) — ARMED only while
//   leg 0 spawned; with zero spawns the control is VACUOUS and says so (a
//   control that cannot fail is not a control), never a PASS.
// Leg 2 — ADDRESS MODE: a virtual filesystem + argv so the compiler's own
//   cursor-address transport (`mentl main.mn:L:C` -> src/main.mn at_run ->
//   cursor_at_handle) projects the eight-aspect CursorView the ring reads.
// Leg 3 — THE SOCKET: a ?? hole projects its proven survivor (Propose).
// Legs 4–8 — THE RESIDENT SESSION (E2): one instance for the session's
//   life. Reads answer under READ_BAR_MS, resident; an edit re-judges its
//   cone in place; the accept is drawn into the session's graph and a later
//   read still walks to the proposal; a refusal is answered whole by the
//   cold route; and every resident answer equals the cold one byte for byte.
import { readFile } from 'node:fs/promises';
import { Worker } from 'node:worker_threads';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

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
// ── Legs 4–8: the resident session (E2) — ONE instance, its graph kept ────
// The session is `mentl session` on stdin in one worker, reached through
// ide/session-client.js — the page's own client. Every call is timed and says
// which route answered. RED on boot 713745c6: its session refuses without a
// listener, so every call falls back cold and no leg below is resident.
const { Session } = createRequire(import.meta.url)('./session-client.js');
const spawnWorker = () => {
  const w = new Worker(WORKER);
  return { post: (m) => w.postMessage(m), terminate: () => w.terminate(), onError: (fn) => w.on('error', fn) };
};
const ms = (r) => `${r.ms.toFixed(1)} ms ${r.resident ? 'resident' : 'cold' + (r.why ? ' (' + r.why.trim().split('\n')[0] + ')' : '')}`;
const READ_BAR_MS = 50;   // PLAN §11.2's felt bar, measured here rather than asserted
{
  const prog = 'fn double(x) = x * 2\n\nfn main() with Memory + Alloc =\n  [1, 2, 3]\n    |> map(double)\n    |> fold(0, (acc, x) => acc + x)\n';
  const sess = new Session({ spawn: spawnWorker, module: MODULE, vfs: Object.assign({}, VFS, { 'main.mn': te.encode(prog) }), runCold: (req) => runWheel(req) });
  const opened = await sess.open();
  console.log(`[4] the session opens: ${opened.ok ? 'one derivation in ' + opened.ms.toFixed(0) + ' ms' : 'FAILED — ' + opened.why}`);
  const reads = [];
  // A call is read on its `(`: the caret is the character under it, and the
  // callee's name is a node of its own (E4 — on boot 8b071ba3 a call's extent
  // was its first token, so the call and its callee tied at the name).
  for (const [at, want] of [['main.mn:1:4', /^Query: .*double/m], ['main.mn:5:11', /^Query: map\(/m], ['main.mn:1:4', /^Query: .*double/m], ['main.mn:6:12', /^Query: fold\(/m]]) {
    const r = await sess.call(['mentl', at]);
    reads.push(r);
    const ok = r.exit === 0 && !r.trapped && want.test(r.out) && r.resident && r.ms < READ_BAR_MS;
    console.log(`    read ${at}: ${ms(r)} -> ${ok ? 'PASS' : 'FAIL'}`);
    if (!ok) { bad++; console.log('      ' + (r.out || r.err || '').trim().split('\n').slice(0, 3).join('\n      ')); }
  }
  const t0 = performance.now();
  const cold = await runWheel({ argv: ['mentl', 'main.mn:5:11'], vfs: Object.assign({}, sess.vfs) });
  const cost = (r) => Number((r.err.match(/the answer cost (\d+) bytes/) || [0, 0])[1]);
  console.log(`    the same read cold: ${(performance.now() - t0).toFixed(0)} ms, exit ${cold.exit} (a fresh instance re-deriving the program)`);
  console.log(`    what a read costs the session's image: ${reads.map((r) => (cost(r) / 1024).toFixed(0) + ' KB').join(', ')}`);

  // ── Leg 5: an edit re-judges its cone in place, and the next read is a read
  const hole = 'type Positive = Int where 0 < self\n\nfn choose() -> Positive with Pure = ??\n\nfn main() = choose()\n';
  const r5 = await sess.call(['mentl', 'main.mn:3:37'], { 'main.mn': hole });
  const ok5 = r5.exit === 0 && r5.resident && r5.out.includes('Query: ?? :') && /Propose: \S/.test(r5.out) && /re-judged main\.mn/.test(r5.err);
  console.log(`[5] an edit re-judges the cone in the same instance: ${ms(r5)} -> ${ok5 ? 'PASS' : 'FAIL'}`);
  console.log('    ' + r5.out.trim().split('\n').join('\n    '));
  if (!ok5) { bad++; console.log('    err: ' + r5.err.trim()); }
  const r5b = await sess.call(['mentl', 'main.mn:1:6']);
  const ok5b = r5b.exit === 0 && r5b.resident && !/re-judged/.test(r5b.err) && r5b.ms < READ_BAR_MS;
  console.log(`    the next read re-judges nothing: ${ms(r5b)} -> ${ok5b ? 'PASS' : 'FAIL'}`);
  if (!ok5b) bad++;

  // ── Leg 6: the accept is drawn into the session's graph, and outlives the reply
  // `mentl accept` writes main.mn through the session's own tree and its
  // living check re-judges the write before the position projects (Why:
  // accepted). Then a LATER read at the same position still walks to the
  // proposal — the edge is the session's, where the cold route drew it in a
  // process that ended with the reply and the next read said "int literal".
  const r6 = await sess.call(['mentl', 'accept', 'main.mn:3:37']);
  const wrote = r6.written && r6.written['main.mn'] ? new TextDecoder().decode(r6.written['main.mn']) : '';
  const ok6 = r6.exit === 0 && !r6.trapped && /with Pure = 1\n/.test(wrote) && !wrote.includes('??') && /^Why: accepted `1`/m.test(r6.out);
  console.log(`[6] the accept (the edge, then the projection): ${ms(r6)} · wrote ${wrote ? wrote.length + ' bytes' : 'nothing'} -> ${ok6 ? 'PASS' : 'FAIL'}`);
  console.log('    ' + r6.out.trim().split('\n').join('\n    '));
  if (!ok6) { bad++; console.log('    err: ' + r6.err.trim()); }
  const r6b = await sess.call(['mentl', 'main.mn:3:37']);
  const ok6b = r6b.exit === 0 && r6b.resident && /^Why: accepted `1`/m.test(r6b.out);
  console.log(`    a later read keeps the provenance: ${ms(r6b)} -> ${ok6b ? 'PASS' : 'FAIL'}`);
  if (!ok6b) { bad++; console.log('    ' + r6b.out.trim().split('\n').join('\n    ')); }

  // ── Leg 7: a refusal is answered whole — by the cold route, which carries
  // the reason and the exit code the session's wire cannot
  const r7 = await sess.call(['mentl', 'main.mn:999:1']);
  const ok7 = r7.exit === 1 && !r7.resident && /past the end/.test(r7.err);
  const r7b = await sess.call(['mentl', 'main.mn:5:4']);
  const ok7b = r7b.exit === 0 && r7b.resident;
  console.log(`[7] a refusal answers whole: ${ms(r7)} exit ${r7.exit} -> ${ok7 ? 'PASS' : 'FAIL'} · the session still answers: ${ms(r7b)} -> ${ok7b ? 'PASS' : 'FAIL'}`);
  if (!ok7 || !ok7b) { bad++; console.log('    err: ' + (r7.err || '').trim()); }

  // ── Leg 8: what the session answers is what a cold process answers
  // (the accepted position is excluded on purpose: its Why walks to a
  // proposal the SESSION accepted, an edge a cold process never drew — leg 6)
  let diverged = 0;
  for (const at of ['main.mn:1:6', 'main.mn:5:4', 'main.mn:0']) {
    const r = await sess.call(['mentl', at]);
    const c = await runWheel({ argv: ['mentl', at], vfs: Object.assign({}, sess.vfs) });
    if (!r.resident || r.out !== c.out) { diverged++; console.log(`    ${at}: ${r.resident ? 'DIVERGED' : 'not resident'}\n      resident: ${JSON.stringify(r.out.slice(0, 160))}\n      cold:     ${JSON.stringify(c.out.slice(0, 160))}`); }
  }
  console.log(`[8] resident answers equal cold answers byte for byte: ${diverged ? diverged + ' diverged' : 'PASS'}`);
  if (diverged) bad++;
  sess.close();
}

console.log(bad ? `\n${bad} FAILED` : '\nall surfaces green — the boot runs on the worker shim, and its session keeps its graph');
process.exit(bad ? 1 : 0);

