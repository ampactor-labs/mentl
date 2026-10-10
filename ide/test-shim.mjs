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
// Legs 9–10 — THE VIEW (L-C): `mentl space <address>` answers the record
//   the page paints, resident, in any module of the link; every resident
//   View equals a cold process's over the same tree, handles aside; and a
//   module that leaves the link leaves nothing in either of the session's
//   ledgers.
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

// ── L-F: one in-page execution path — compile -> asm bytes -> instantiate.
// The candidate wheel owns both projections.  `outBytes` is deliberately a
// byte channel: decoding Wasm as text would silently change non-UTF-8 bytes.
{
  const help = await runWheel({ argv: ['mentl', 'help'] });
  if (!help.out.includes('assemble WAT to wasm bytes on stdout')) {
    console.log('[L-F] in-page assembly: TRANSITION — this boot predates `mentl asm`');
  } else {
    const source = 'fn main() = 42\n';
    const vfs = Object.assign({}, VFS, { 'main.mn': te.encode(source) });
    const compiled = await runWheel({ argv: ['mentl', 'compile', 'main.mn'], vfs });
    const assembled = compiled.exit === 0 && !compiled.trapped
      ? await runWheel({ argv: ['mentl', 'asm'], stdin: te.encode(compiled.out), binary: true })
      : { exit: 1, outBytes: null, trapped: 'compile refused', err: compiled.err };
    const bytes = assembled.outBytes instanceof Uint8Array ? assembled.outBytes
      : assembled.outBytes ? new Uint8Array(assembled.outBytes) : new Uint8Array(0);
    let run = { exit: 1, trapped: 'the assembler produced no module' };
    try {
      if (assembled.exit === 0 && !assembled.trapped && bytes[0] === 0 && bytes[1] === 97 && bytes[2] === 115 && bytes[3] === 109) {
        run = await runWheel({ module: await WebAssembly.compile(bytes), argv: [], vfs });
      }
    } catch (e) { run = { exit: 1, trapped: String(e) }; }
    const ok = compiled.exit === 0 && !compiled.trapped && assembled.exit === 0 && !assembled.trapped
      && bytes.length > 8 && run.exit === 42 && !run.trapped;
    console.log(`[L-F] in-page assembly and run: ${bytes.length} bytes · exit ${run.exit} -> ${ok ? 'PASS' : 'FAIL'}`);
    if (!ok) { bad++; console.log('    ' + (compiled.err || assembled.err || run.trapped || '').trim().split('\n').slice(0, 4).join('\n    ')); }
  }
}
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

  // ── Leg 9: THE VIEW (L-C) — `mentl space <address>` answers the record the
  // page paints, resident and under the bar: the ring's eight facts in the
  // kernel's order, every Lens site typed numbers, the resident bytes equal
  // to a cold process's, and the View's size and time printed (unmeasured
  // before this leg). RED on boot 2175e015: `space` was the page's verb alone
  // and the session answered MISS, so the cold route exited 2.
  const ORDER = ['query', 'propose', 'topology', 'effects', 'ownership', 'verify', 'teach', 'why'];
  const parseView = (r) => { try { return r.exit === 0 && !r.trapped ? JSON.parse(r.out) : null; } catch (e) { return null; } };
  // EVERY resident View is compared with a cold process's over the same
  // tree. A handle is the SESSION's identity for a node — a cold process
  // mints its own numbers (14534 resident against 7624 cold, measured) — so
  // the Views are compared with the handles off; everything else is a fact
  // of the program and must agree to the byte. `(arena, offset)` is the
  // deterministic form (PLAN §11, 9.2's keystone).
  //
  // ONE field is compared as a containment, not an equality: the references
  // at a declaration (`refs`, L-D). A cold process judges the link of the
  // module it names, while the session holds the whole tree — `main`'s call
  // of `twice` is a reference the cold route over `ops.mn` never judged, and
  // the session's answer carries it (measured on the first L-D m2). So every
  // site the cold route finds the session finds too, and the rest of the
  // View agrees to the byte.
  const unhandled = (v) => JSON.stringify(v, (k, x) => (k === 'h' || k === 'refs' ? undefined : x));
  const siteKey = (s) => `${s.module}:${s.site.line}:${s.site.col}`;
  const refsHold = (rv, cv) => {
    if (!cv.refs) return !rv.refs;
    if (!rv.refs || rv.refs.needle !== cv.refs.needle) return false;
    const have = new Set([...rv.refs.sites, ...rv.refs.texts].map(siteKey));
    return [...cv.refs.sites, ...cv.refs.texts].every((s) => have.has(siteKey(s)));
  };
  const asCold = async (r, argv, label) => {
    const c = await runWheel({ argv, vfs: Object.assign({}, sess.vfs) });
    const rv = parseView(r), cv = parseView(c);
    const same = r.resident && !!rv && !!cv && unhandled(rv) === unhandled(cv) && refsHold(rv, cv);
    console.log(`    ${label}: the same View cold equals it, handles aside: ${same ? 'PASS' : 'FAIL'}`);
    if (!same) { bad++; console.log(`      resident: ${JSON.stringify(r.out.slice(0, 200))}\n      cold:     ${JSON.stringify(c.out.slice(0, 200))}`); }
    return same;
  };
  const siteOk = (s) => s && Number.isInteger(s.line) && Number.isInteger(s.col) && Number.isInteger(s.end_line) && Number.isInteger(s.end_col);
  {
    const r9 = await sess.call(['mentl', 'space', 'main.mn:1:6']);
    const v = parseView(r9);
    const kinds = v ? v.ring.map((f) => f.kind) : [];
    const lensTyped = v ? v.lens.every((f) => f.kind !== 'diag' || siteOk(f.site)) : false;
    const ok9 = !!v && r9.resident && r9.ms < READ_BAR_MS && kinds.join(',') === ORDER.join(',') && lensTyped && !r9.out.includes('undefined')
      && v.at.module === 'main' && v.at.line === 1 && v.at.col === 6 && siteOk(v.at.span) && Array.isArray(v.ledger);
    console.log(`[9] the View, resident: ${ms(r9)} · ${r9.out.length} bytes · ring ${kinds.length ? kinds.join(',') : '(none)'} · lens ${v ? v.lens.length : '?'} · ledger ${v ? v.ledger.length : '?'} -> ${ok9 ? 'PASS' : 'FAIL'}`);
    if (!ok9) { bad++; console.log('    ' + (r9.out || r9.err || '').trim().split('\n').slice(0, 3).join('\n    ')); }
    await asCold(r9, ['mentl', 'space', 'main.mn:1:6'], 'main.mn:1:6');
  }
  // The Lens carries every diagnostic AS THE KIND IT IS, at ITS OWN site —
  // the two bugs the page's regexes had: a Warning never reached the Lens
  // (the regex knew lowercase kinds only) and a message embedding a Reason's
  // address jumped to that address instead of the diagnostic's span.
  {
    const prog = '// `nothing_here` is a reference that resolves nowhere\nfn f(x: Int) = x\n\nfn main() = f("x")\n';
    const r = await sess.call(['mentl', 'space', 'main.mn:2:4'], { 'main.mn': prog });
    const v = parseView(r);
    const diags = v ? v.lens.filter((f) => f.kind === 'diag') : [];
    const warn = diags.find((f) => f.code === 'W_CommentRefUnresolved');
    const mism = diags.find((f) => f.code === 'E_TypeMismatch');
    const okW = !!warn && /warning/i.test(warn.severity) && warn.site.line === 1 && warn.module === 'main';
    const okM = !!mism && mism.site.line === 4 && mism.refuses === true && /error/i.test(mism.severity);
    // every fact carries its lead, so the sentence over the Lens is the first
    // fact's — never a fact of its own standing beside the facts it is about
    const okL = diags.length > 0 && diags.every((d) => typeof d.lead === 'string' && d.lead.length > 0) && diags[0].refuses === true;
    console.log(`    a Warning lands in the Lens as a Warning at its line: ${okW ? 'PASS' : 'FAIL'} · a mismatch sits at its own site, not its Reason's: ${okM ? 'PASS' : 'FAIL'} · every fact carries its lead and the refusal ranks first: ${okL ? 'PASS' : 'FAIL'}`);
    if (!okW || !okM || !okL) { bad++; console.log('    lens: ' + JSON.stringify(diags.map((d) => [d.code, d.severity, d.site && d.site.line])) + (v ? '' : '\n    ' + (r.out || r.err || '').trim().split('\n').slice(0, 3).join('\n    '))); }
    await asCold(r, ['mentl', 'space', 'main.mn:2:4'], 'the Lens');
  }
  // ── Leg 10: an address in a SIBLING module answers resident — the
  // session's reads were pinned to `main` until L-C, though a module's spans
  // are its own coordinates and the link carries every module. The delta
  // brings TWO new modules into the link in a chain whose path order is not
  // its dependency order (`main` sorts before `ops`, which imports `base`):
  // the cone was re-judged one module at a time, so a scan in path order
  // judged `main` before the `ops` it imports and refused `twice` as
  // missing — measured on the pre-fix wheel, where this leg asserted only
  // the ring and passed over a refusing View. The cone is ONE judgment now
  // (rederive_cone hands every module of it to infer_modules_converged at
  // once), so the order inside it is the judgment's own, as the cold route's.
  {
    const delta = { 'base.mn': 'fn two() = 2\n', 'ops.mn': 'import base\n\nfn twice(x) = x * two()\n', 'main.mn': 'import ops\n\nfn main() = twice(21)\n' };
    const r10 = await sess.call(['mentl', 'space', 'ops.mn:3:4'], delta);
    const v = parseView(r10);
    const refusing = v ? v.lens.filter((f) => f.kind === 'diag' && f.refuses) : [];
    const ok10 = !!v && r10.resident && v.at.module === 'ops' && v.ring.length === 8 && v.ring[0].text.includes('twice') && refusing.length === 0;
    console.log(`[10] a sibling module's View, resident, the cone judged deps-first: ${ms(r10)} -> ${ok10 ? 'PASS' : 'FAIL'}`);
    if (!ok10) { bad++; console.log('    ' + (v ? 'refusing: ' + JSON.stringify(refusing.map((d) => [d.code, d.module, d.site && d.site.line, d.text.slice(0, 80)])) : (r10.out || r10.err || '').trim().split('\n').slice(0, 3).join('\n    '))); }
    await asCold(r10, ['mentl', 'space', 'ops.mn:3:4'], 'ops.mn:3:4');
    const r10b = await sess.call(['mentl', 'ops.mn:3:4']);
    const ok10b = r10b.exit === 0 && r10b.resident && /^Query: .*twice/m.test(r10b.out);
    console.log(`    the text address too: ${ms(r10b)} -> ${ok10b ? 'PASS' : 'FAIL'}`);
    if (!ok10b) { bad++; console.log('    ' + (r10b.out || r10b.err || '').trim().split('\n').slice(0, 3).join('\n    ')); }
    // A CYCLE of modules is one judgment unit: `sig` declares the effect and
    // imports `proc`, `proc` imports `sig` and answers its op (lib/dsp/signal
    // and lib/dsp/processors are this shape). Judged one module at a time,
    // whichever came first refused the other's declarations — nineteen
    // `E_MissingVariable` at every arm over `process` when Pulse opened in
    // the page, measured on the per-module wheel; one judgment owes no order.
    const cyc = { 'sig.mn': 'import proc\n\neffect Proc { process(x: Float) -> Float }\n', 'proc.mn': 'import sig\n\nhandler pass {\n  process(x) => resume(x),\n}\n', 'main.mn': 'import proc\nimport sig\n\nfn main() = (process(1.0)) ~> pass\n' };
    const r10c = await sess.call(['mentl', 'space', 'proc.mn:3:9'], cyc);
    const vc = parseView(r10c);
    const refusingC = vc ? vc.lens.filter((f) => f.kind === 'diag' && f.refuses) : [];
    const ok10c = !!vc && r10c.resident && vc.at.module === 'proc' && refusingC.length === 0;
    console.log(`    a cycle of modules is one judgment unit: ${ms(r10c)} -> ${ok10c ? 'PASS' : 'FAIL'}`);
    if (!ok10c) { bad++; console.log('    ' + (vc ? 'refusing: ' + JSON.stringify(refusingC.map((d) => [d.code, d.module, d.site && d.site.line, d.text.slice(0, 80)])) : (r10c.out || r10c.err || '').trim().split('\n').slice(0, 3).join('\n    '))); }
    await asCold(r10c, ['mentl', 'space', 'proc.mn:3:9'], 'proc.mn:3:9');
    // The bank holds a module's reports ONCE across cone judgments. A comment
    // in `base` names a declaration that exists nowhere, so the prose gate
    // narrates it when `base` is judged; three later edits of `main` alone
    // re-judge a cone that does not contain `base`, and the Lens must still
    // carry exactly one such fact. Measured on the m2 that first judged the
    // cone whole: the gate walked its comment cells from handle 0 — the cold
    // route's parse start — so every superseded generation narrated again on
    // every edit (39, then 79, then 119 on a four-line lesson); the walk
    // reads the judgment's own parse start now.
    const bankDelta = { 'base.mn': '// `nowhere` is named by no declaration\nfn two() = 2\n', 'ops.mn': 'import base\n\nfn twice(x) = x * two()\n', 'main.mn': 'import ops\n\nfn main() = twice(21)\n' };
    // the fact itself, named: the one narration, base's line 1, about `nowhere`
    const unresolved = (r) => {
      const v = parseView(r);
      if (!v) return -1;
      const fs = v.lens.filter((f) => f.kind === 'diag' && f.code === 'W_CommentRefUnresolved');
      return fs.length === 1 && fs[0].module === 'base' && fs[0].site.line === 1 && /`nowhere`/.test(fs[0].text) ? 1 : fs.length === 1 ? 'another' : fs.length;
    };
    const b0 = unresolved(await sess.call(['mentl', 'space', 'ops.mn:3:4'], bankDelta));
    const b1 = unresolved(await sess.call(['mentl', 'space', 'main.mn:3:4'], { 'main.mn': 'import ops\n\nfn main() = twice(2)\n' }));
    const b2 = unresolved(await sess.call(['mentl', 'space', 'main.mn:3:4'], { 'main.mn': 'import ops\n\nfn main() = twice(3)\n' }));
    const rb = await sess.call(['mentl', 'space', 'main.mn:3:4'], { 'main.mn': 'import ops\n\nfn main() = twice(21)\n' });
    const b3 = unresolved(rb);
    const okb = b0 === 1 && b1 === 1 && b2 === 1 && b3 === 1;
    console.log(`    the bank holds a module's reports once across cone judgments (${b0}, ${b1}, ${b2}, ${b3}): ${ms(rb)} -> ${okb ? 'PASS' : 'FAIL'}`);
    if (!okb) bad++;
    await asCold(rb, ['mentl', 'space', 'main.mn:3:4'], 'after the cone edits');
    // A module that LEAVES the link keeps nothing in either ledger: `lib2`
    // carries an open claim (`100 / n` over a parameter nothing bounds) and
    // the next tree drops its import, so the session's whole-ledger read —
    // every open obligation as SMT-LIB — must equal a cold process's, which
    // never judged `lib2`. The session's prune cleared its bank alone until
    // the one generation clear forgot the proof ledger beside it.
    await sess.call(['mentl', 'space', 'main.mn:3:4'], { 'lib2.mn': 'fn inv(n) = 100 / n\n', 'main.mn': 'import lib2\n\nfn main() = inv(5)\n' });
    const rq = await sess.call(['mentl', 'query', 'main.mn', 'smt'], { 'main.mn': 'fn main() = 5\n' });
    const cq = await runWheel({ argv: ['mentl', 'query', 'main.mn', 'smt'], vfs: Object.assign({}, sess.vfs) });
    const okq = rq.exit === 0 && rq.resident && rq.out === cq.out && !rq.out.includes('lib2');
    console.log(`    a module that left the link leaves no open claim behind: ${ms(rq)} -> ${okq ? 'PASS' : 'FAIL'}`);
    if (!okq) { bad++; console.log(`      resident: ${JSON.stringify(rq.out.slice(0, 200))}\n      cold:     ${JSON.stringify(cq.out.slice(0, 200))}`); }
  }
  sess.close();
}

// ── Legs 11–13: THE CANVAS (L-D) — the text's own projection, from the wheel.
// `mentl space <file>:0` (the module altitude) carries the canvas: every
// token of the text at its own span and class, the aspect strip (eight cells
// per line, each a live read of one aspect), the verb frames, the proof marks
// and the ownership traces. The page's JavaScript tokenizer is deleted: a
// span the wheel did not answer cannot be painted. RED on boot c8ba5799: the
// View had no canvas, no refs at a caret and no needle find.
{
  const prog = [
    '// `double` doubles — the lede',          //  1  a prose lede (non-ASCII: the column is a byte's)
    'fn double(x) = x * 2',                     //  2
    '',                                         //  3
    'effect Ask {',                             //  4
    '  ask() -> Int',                           //  5
    '}',                                        //  6
    '',                                         //  7
    'handler one {',                            //  8
    '  ask() => resume(1),',                    //  9
    '}',                                        // 10
    '',                                         // 11
    'fn needs() = ask() + 1',                   // 12  performs Ask; no install on the path: the row carries it to callers
    '',                                         // 13
    'fn inv(n) = 100 / n',                      // 14  an open claim: n may be zero
    '',                                         // 15
    'fn main() = {',                            // 16
    '  let a = (ask() + needs()) ~> one',       // 17  served here: the install grants Ask
    '  let b = [1, 2, 3]',                      // 18
    '    |> map(double)',                       // 19
    '    |> len',                               // 20
    '  let c = 100 / 5',                        // 21  a proven claim
    '  a + b + c + inv(4) + ("s{a}" |> len)',   // 22  a splice
    '}',                                        // 23
    '',
  ].join('\n');
  const sess = new Session({ spawn: spawnWorker, module: MODULE, vfs: Object.assign({}, VFS, { 'main.mn': te.encode(prog) }), runCold: (req) => runWheel(req) });
  const parseView = (r) => { try { return r.exit === 0 && !r.trapped ? JSON.parse(r.out) : null; } catch (e) { return null; } };
  const r11 = await sess.call(['mentl', 'space', 'main.mn:0']);
  const v = parseView(r11);
  const cv = v && v.canvas;
  // (a) THE TOKENS COVER THE TEXT: every byte that is not whitespace lies in
  // exactly one token, tokens never overlap, and each token's class is a word
  // of the wire's own vocabulary. Columns are the text's BYTES (a lexer's
  // column), so the twin reads the text as bytes, as the page converts them.
  const bytes = te.encode(prog);
  const lineStarts = [0];
  bytes.forEach((b, i) => { if (b === 10) lineStarts.push(i + 1); });
  const off = (l, c) => lineStarts[l - 1] + c - 1;
  const CLASSES = new Set(['kw', 'disc', 'verb', 'hole', 'str', 'spl', 'num', 'cm', 'ty', 'fn', 'self', 'neg', 'id', 'op']);
  let covered = new Uint8Array(bytes.length), overlap = 0, badClass = 0;
  for (const t of (cv && cv.tokens) || []) {
    const [sl, sc, el, ec, cls] = t;
    if (!CLASSES.has(cls)) badClass++;
    for (let i = off(sl, sc); i < off(el, ec); i++) { if (covered[i]) overlap++; covered[i] = 1; }
  }
  let uncovered = 0;
  bytes.forEach((b, i) => { if (b !== 32 && b !== 10 && b !== 9 && !covered[i]) uncovered++; });
  const okTok = !!cv && cv.tokens.length > 0 && uncovered === 0 && overlap === 0 && badClass === 0 && cv.lines === 24;
  console.log(`[11] the canvas's tokens cover the text exactly: ${ms(r11)} · ${cv ? cv.tokens.length : 0} tokens, ${uncovered} uncovered byte(s), ${overlap} overlapping, ${badClass} unknown class(es) -> ${okTok ? 'PASS' : 'FAIL'}`);
  if (!okTok) { bad++; console.log('    ' + (v ? JSON.stringify(Object.keys(v)) : (r11.out || r11.err || '').trim().split('\n').slice(0, 3).join('\n    '))); }
  // (b) THE STRIP: eight cells a line, in the kernel's order, each the read
  // the line's own graph answers.
  const ARMS = ['query', 'propose', 'topology', 'effects', 'ownership', 'verify', 'teach', 'why'];
  const strip = new Map(((cv && cv.strip) || []).map((s) => [s.line, s.cells]));
  const cell = (line, arm) => { const cs = strip.get(line); return cs ? cs[ARMS.indexOf(arm)] : null; };
  const has = (line, arm, glyph) => { const c = cell(line, arm); return !!c && (!glyph || c.glyph === glyph); };
  const checks = [
    ['the declaration\'s type at 2', has(2, 'query', 'proven')],
    ['the lede\'s Reason at 2', has(2, 'why', 'proven')],
    ['a perform its row carries out, hollow, at 12', has(12, 'effects', 'open')],
    ['the install that grants it, filled, at 17', has(17, 'effects', 'proven')],
    ['the open claim at 14', has(14, 'verify', 'open')],
    ['the proven claim at 21', has(21, 'verify', 'proven')],
    ['a |> stage at 19 and 20', has(19, 'topology') && has(20, 'topology')],
    ['the gradient\'s step at 14', has(14, 'teach', 'open')],
    ['every line carries eight cells', [...strip.values()].every((cs) => cs.length === 8)],
  ];
  const failed = checks.filter(([, ok]) => !ok).map(([n]) => n);
  console.log(`[12] the aspect strip reads the graph per line: ${checks.length - failed.length}/${checks.length} -> ${failed.length ? 'FAIL' : 'PASS'}`);
  if (failed.length) { bad++; console.log('    missing: ' + failed.join('; ') + '\n    strip: ' + JSON.stringify([...strip.entries()].slice(0, 12))); }
  const chain = ((cv && cv.frames) || []).find((f) => f.verb === '|>' && f.stages.length === 3);
  const okF = !!chain && chain.stages[1].line === 19 && chain.stages[2].line === 20;
  console.log(`    the |> chain's frame from the graph, stage by stage: ${okF ? 'PASS' : 'FAIL'}`);
  if (!okF) { bad++; console.log('    frames: ' + JSON.stringify((cv && cv.frames) || null)); }
  // (c) FIND BY EDGE: at a caret on a use, the View carries every reference
  // to what it names — the parameter `x`, its use at 2:16, never another x;
  // a needle names a declaration and the View answers its references and the
  // string literals that hold it.
  const r13 = await sess.call(['mentl', 'space', 'main.mn:2:16']);
  const v13 = parseView(r13);
  const refs = v13 && v13.refs;
  const okR = !!refs && refs.sites.some((s) => s.module === 'main' && s.site.line === 2);
  const r13b = await sess.call(['mentl', 'space', 'main.mn:22:3', 'double']);
  const v13b = parseView(r13b);
  const found = v13b && v13b.refs;
  const okN = !!found && found.needle === 'double' && found.sites.some((s) => s.site.line === 19);
  console.log(`[13] find by edge — the references at the caret: ${okR ? 'PASS' : 'FAIL'} · a needle's references: ${okN ? 'PASS' : 'FAIL'}`);
  if (!okR || !okN) { bad++; console.log('    refs: ' + JSON.stringify(refs || null) + '\n    needle: ' + JSON.stringify(found || null) + '\n    ' + ((r13b.err || '').trim().split('\n').slice(0, 2).join(' | '))); }
  // the canvas a session answers is the canvas a cold process answers, handles aside
  const c11 = await runWheel({ argv: ['mentl', 'space', 'main.mn:0'], vfs: Object.assign({}, sess.vfs) });
  const noH = (x) => JSON.stringify(x, (k, y) => (k === 'h' ? undefined : y));
  const okC = !!v && r11.resident && !!parseView(c11) && noH(v) === noH(parseView(c11));
  console.log(`    the canvas View cold equals it, handles aside: ${okC ? 'PASS' : 'FAIL'}`);
  if (!okC) bad++;
  sess.close();
}

console.log(bad ? `\n${bad} FAILED` : '\nall surfaces green — the boot runs on the worker shim, and its session keeps its graph');
process.exit(bad ? 1 : 0);
