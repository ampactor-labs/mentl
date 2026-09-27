# mentl edit — the web IDE (band M's first artifact)

The page runs THE FIXPOINT COMPILER ITSELF in your browser: boot/mentl.wasm,
the pinned boot, unmodified — the page fetches it at `../boot/mentl.wasm`
through `mentl space`, and the node twin loads the same file. It used to
run a hand-derived copy (`ide/mentl-ide.wasm`) with the memory import's
minimum shrunk from 4GB to 512MB, because the wheel declared a 4GB minimum
no browser will allocate; that copy lagged the boot by eight weeks. The
wheel declares a 32-page minimum now and its allocator grows the memory on
demand (2026-09-27), so the page supplies its 1GB shared memory and the
boot grows into it as it judges.

THE EXECUTION HOST IS ide/wheel-worker.js — the runner pattern at the
browser host (`Hβ.ops.wasmtime-runner-migration`'s browser leg, landed
2026-07-29). The page never instantiates the module: the join's
memory.atomic.wait32 is forbidden on the browser main thread, so every
run posts to a worker, and `thread-spawn` dispatches to a pool of workers
spawned and ARMED (module + shared memory + vfs) before `_start` can
block. Dispatch rides a SharedArrayBuffer ring + Atomics.notify, never
postMessage — Chrome flushes a worker's outgoing messages only when the
sender yields, and thread-spawn fires mid-wasm with the root then
blocking in the join (measured: 16 spawns posted, zero delivered, pool
provably loaded). Completion rides the wheel's own task-record protocol
in wasm memory; the workers' messages carry stdio only, so a degraded
message channel can never fabricate a result. Node drives the same
worker file (it has neither hazard — the same blob ran there first),
which is what makes the headless gate a true twin of the page.

Run it:

    mentl space                 # then open http://localhost:7378/ide/

THE SERVER IS THE WHEEL. `mentl space` is the compiler's own verb — an
HTTP/1.1 file server in src/main.mn (the space arms), speaking WASI
preview1 sockets (lib/net.mn: sock_accept + poll_oneoff over a
listener the install shim preopens with -S tcplisten; connections are
plain fds). The serve.mn/serve.sh scaffold this absorbed is git
archaeology. By hand, from the repo root:

    wasmtime run <flags> --dir . -S tcplisten=127.0.0.1:7378 boot/mentl.wasm space

The isolation headers exist for one reason: the compiler's memory is
SHARED (the threading substrate), and browsers require cross-origin
isolation (COOP/COEP) for shared WebAssembly memory. Every response the
Mentl server writes carries the pair; the page also fetches
lib/*.mn + lib/prelude.mn from the repo to link the runtime the
way tools/run-micro.sh does.

The page is `mentl edit` (`docs/MENTL_EDIT.md`) in its first real form,
built to the brand in `docs/DESIGN_SYSTEM.md`. One cursor is the one reader:
move the caret and every surface re-projects around it — panels are cursor
modes, not features. Five surfaces:

- **The Canvas** — a SYNTAX-faithful editor. Each glyph is its kernel role's
  Okabe–Ito hue: the five verbs in sky (Topology), types gold, keywords blue,
  `own`/`ref`/`resume` magenta, literals and `!E` vermillion, the `??` socket
  glowing vermillion. The caret is the position every other surface reads.
- **The Aspect ring** — the eight facets at the cursor (graph, handler, verb,
  row, own, refine, gradient, why). It reads the compiler's OWN eight-aspect
  CursorView: on cursor settle the page runs the wheel's cursor-address
  transport (`mentl main.mn:L:C` → src/main.mn `at_run` → `cursor_at_handle`,
  the same read `mentl edit` projects) over a virtual filesystem (the user
  source as main.mn + the vocabulary closure), and the returned facets (the
  inferred type, the effect row, ownership, refinement obligations, the Teach
  step, the Reason chain) flip their provenance badge to `real`. Where the
  projection is silent or a program the closure can't resolve, the facet keeps
  the page's own read: `surface` (its parse), `declared` (a `with` row read
  verbatim), or `socket` (a named-future gate — never a value it can't earn).
  The badge is `real` ONLY for a fact the compiler graph actually returned.
- **The Lens** — the real `stderr` diagnostics, gradient-ranked to one teaching
  step in Mentl's voice, click-to-jump, with genuine text-fixes for the
  canonicalizations the parser reports (`E_RedundantBraces`,
  `E_RedundantPerform`) and for `T_OverDeclared` (the tightening — the
  message carries the proven row, the same patch `mentl tighten` authors).
- **The Proposal strip** — the cursor line's standing MachineApplicable
  patch as a ghost preview under the editor (was → now), accepted with
  Tab (no proposal: Tab indents — the copilot convention). An
  over-declared row proposes its tightening; a `??` whose Propose facet
  returned ONE proven survivor proposes the fill (a tie never proposes —
  the medium teaches the missing constraint instead of guessing). One
  pure rewrite (`patchLine`) serves the click affordance, the preview,
  and the accept.
- **The Ledger** — the effect rows from the `with` clauses, and the proof
  surface: what a `!E` region is proven *incapable* of. Declared today; the
  transitive hop-by-hop proof is honestly gated on band A.
- **The Wavefront** — the Why strip, plus the realities and trail scrubbers
  drawn as dormant, honest gates (band B's multi-shot producer), never a
  canned branch.

Plus the Teach knob (density scales with what's proven), the emitted-WAT
projection with fn/line/time stats, and eight demos. Everything is either
real compiler output (the WAT, the diagnostics) or a labeled surface read of
the source — no surface ever dresses a guess as the compiler's graph truth.

The aspect ring reads the live graph today, but the read is a full compile per
cursor settle (debounced, one WASM instantiation); the IC cursor's
millisecond re-projection is the ultimate form (`Hβ.felt.reactivity-typed-demand-driven`,
the session `<~` loop). The address transport also resolves a program only when
the vocabulary closure covers its imports; a program reaching for runtime
modules the page does not mount stays on the surface read (honest, never faked)
until the closure widens.

What deliberately does not exist yet, each an honest socket that names its
gate: RUNNING the compiled program in the page (`Hβ.felt.ide-run-in-page` —
needs an in-browser assembler; download the .wat and `wat2wasm out.wat -o
out.wasm --enable-threads --enable-tail-call && wasmtime run
-W all-proposals=y out.wasm`); fill-and-resume and reality-scrubbing (band
B's multi-shot producer); the transitive `!E` proof (band A's crown).

The serving loop is an evidence-threading tail call — constant stack for
the server's whole life, the first-light era's own tail form carrying its
own IDE.

The gate is `bash tools/ide-gate.sh`: the node twin (`node
ide/test-shim.mjs`) drives ide/wheel-worker.js — the SAME execution host
the page uses — through its faces (compile-stdin; the stub-spawn RED
control, armed only while the judgment spawns — it has spawned nothing
since the fan's direct spawn was deleted at pin 7c9dc538, so the control
says VACUOUS rather than passing, and re-arms when the judgment schedules;
the address CursorView; the ?? Propose socket; the resident session), then
headless chrome loads the served page with `?smoke` and the page's own
console wire reports the compile verdict. If the page ever misbehaves, the twin
discriminates shim-vs-DOM in one command; `?smoke&dbg` opens the
worker's debug channel (the probe that found the postMessage-flush
hazard, kept as an instrument).
