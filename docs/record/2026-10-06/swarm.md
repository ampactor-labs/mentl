# The swarm — Wave A of the 2026-10-06 program

Every builder session reads this file whole before its first edit. The program
it executes is `program.md` beside it (§7 is the order); the audit lenses'
answers are the `*.json` files beside it. Every line number below is valid at
the commit that added this file, which is your base.

## The shape

Twelve builder sessions build twelve landings at once, each on its own branch
from one base. One orchestrator session, on `claude/mentl-design-audit-m1mptf`,
integrates them: it merges, runs the march with the repin, runs the board,
writes the records and pushes. The docs integration (program.md §0.3) runs
beside them in the orchestrator's own container. A lane that finishes early
waits for its turn in the order below; a lane that finishes late is integrated
when it lands.

| # | Lane | Branch | Landing — program.md lines |
|---|---|---|---|
| 1 | g2 | `claude/mentl-swarm-g2` | G2 — 1628–1679 |
| 2 | m9 | `claude/mentl-swarm-m9` | M9 — 925–972 |
| 3 | threads | `claude/mentl-swarm-threads` | RACE 1704–1725 + SPACE.1 1770–1785 |
| 4 | trap | `claude/mentl-swarm-trap` | TRAP — 1680–1703 |
| 5 | render | `claude/mentl-swarm-render` | N2 531–543 + N4 552–572 + 604–653 + T6 (inside T, 1806–1874) |
| 6 | fmt | `claude/mentl-swarm-fmt` | F — 343–459 |
| 7 | verbs | `claude/mentl-swarm-verbs` | V2 (inside V, 1875–1909) + the lib/dsp Stage Law |
| 8 | env | `claude/mentl-swarm-env` | E1 — 2292–2520 |
| 9 | asm | `claude/mentl-swarm-asm` | L-F — 3108–3183 (decision 4) and its entry in 3295–3359 |
| 10 | canvas | `claude/mentl-swarm-canvas` | L-D — 3184–3294 and its entry in 3295–3359 |
| 11 | reflink | `claude/mentl-swarm-reflink` | M1 — 654–765, gates 1060–1081 |
| 12 | earlyexit | `claude/mentl-swarm-earlyexit` | V1 (inside V, 1875–1909) |

## The protocol — every lane

### 1 · Start

```
bash tools/base-check.sh <BASE>     # mandatory first action; STALE: merge the base, or stop and report
bash tools/wasmtime-get.sh          # the pinned engine, into .build/wasmtime
mkdir -p ~/tc ~/.local/bin && (cd ~/tc && npm install --silent wabt@1.0.39) \
  && ln -sf ~/tc/node_modules/.bin/wat2wasm ~/.local/bin/wat2wasm
bash tools/install.sh               # the `mentl` command over this checkout
bash tools/setup-git-hooks.sh       # the pre-commit perimeter
bash tools/state.sh --quick         # ground: the board at your base
```

Then read: this file; your lane's design in program.md (the lines above, read
whole), §5.0's convergences that name your findings (1108–1279), and §5.1's
verdict classes (1280–1399); every finding your lane names, by ID, in the lens
JSONs; every RESIDUE entry your design names (RESIDUE.md is markdown — a grep
over it is fine; the medium-first gate refuses hand searches over `.mn` source
only).

### 2 · The laws of this swarm

CLAUDE.md, PLAN.md and SYNTAX.md govern everything you do. These sharpen them
for a swarm:

- **Build the landing whole, in its ultimate form.** No band-aid, no silent
  fallback, no lowered target. A gap you cannot close in this landing is named
  in positive form as a draft RESIDUE entry, never hidden.
- **No refuter pass** (Morgan, 2026-10-06): if the artifact can be better,
  build it; the build and the gates refute a wrong form in seconds. Dispatch
  sub-agents for breadth (fixtures, sweeps, reading), never for a verdict on a
  design you have not built.
- **RED first.** Every new fixture or gate is measured failing on the pinned
  boot at your base (`boot/mentl.wasm`) before your change makes it pass, and
  the failing output goes into your report.
- **The medium first.** `mentl` verbs before any hand search over `.mn`
  source; `.mn` edits through the Edit tool only. The hooks enforce both.
- **No act on an unmeasured cause.** When the reason is unmeasured, the next
  output is the instrument. Record every hypothesis a measurement killed.
- **Stay in your lane.** Each lane lists its boundaries. If your landing needs
  a change in another lane's territory, make the smallest change that works and
  say so in your report.

### 3 · Files you do not edit

`boot/mentl.wasm`, `boot/PROVENANCE.md`, `LEDGER.md`, `PLAN.md`, `RESIDUE.md`,
`CLAUDE.md`, `docs/record/**`. The orchestrator writes them from your drafts.
You never repin: run `bash tools/march.sh` without `MARCH_REPIN`, and never
commit a changed `boot/mentl.wasm`. You may edit `docs/SYNTAX.md` where your
landing moves the surface, `src/board.mn` and `tools/verify-baseline.txt`
bounds (each move with its justification line), and anything under `src/`,
`lib/`, `tests/`, `tools/`, `ide/` and `examples/`.

### 4 · Verify — each result read in this session and pasted into the report

```
mentl fmt <every .mn you edited>          # it must end a no-op
mentl check src/main.mn                   # zero diagnostics
bash tools/march-gate.sh --micros         # the battery through your m2
bash tools/frontier-gate.sh --compiler fresh
bash tools/crown-gate.sh                  # judges your m2 by default
bash tools/proof-exactness-gate.sh fresh
C=$(source tools/wt-env.sh >/dev/null 2>&1; wt_m2_ensure); GATE_WASM="$C/m2.wasm" bash tools/effect-identity-gate.sh
bash tools/ide-gate.sh                    # when your lane touches ide/, src/space.mn, src/mcp.mn or the session
bash tools/march.sh                       # no MARCH_REPIN: CLEAN m2 == m3, or TRANSITION m3 == m4; the cost line
bash tools/verify.sh                      # census, ratchets, doc-truth
```

A refusal by the cost ratchet is a finding. Take the fixed-input reading (the
boot and your m2 compiling one wheel source, peak RSS of each) and report it;
never raise a ceiling without it.

### 5 · Report — `landing/<lane>.md` on your branch

- **Verdicts:** the march verdict with its cost line, the battery, frontier,
  crown, proof-exactness, effect identity, the IDE gate where run, `check`.
- **RED first:** each new gate's failing output on the pinned boot.
- **What landed:** the mechanisms, the files, and what was deleted.
- **Kills:** every hypothesis a measurement destroyed, in order.
- **Measurements:** every number, read in this session.
- **Bounds moved:** each with its justification.
- **Open:** what you could not close, each as a draft RESIDUE entry.
- **Record drafts:** a LEDGER entry in the ledger's voice; the PLAN §7 bullet;
  the RESIDUE entries closed, opened or trued, as full text; any PLAN §11
  change.

### 6 · Finish

Merge the moving base before the final verification:
`git fetch origin claude/mentl-design-audit-m1mptf && git merge origin/claude/mentl-design-audit-m1mptf`.
Resolve conflicts in your own changes and keep the base's, since they are
integrated landings. If the boot moved, re-run the RED-first checks it could
have changed. Then §4, then commit (what landed and why; no attribution lines
and no model identifiers anywhere) and push to your branch. Your last message
names the branch, the head sha and the verdict line.

## The lanes

### 1 · g2 — every gate can fail, the board bounds answers, the project is the unit of every gate

Design: 1628–1679; convergences 1, 3, 6 and 17; findings PR-13, VERB-1, SA-5,
SA-13, MOD-13; §5.1's "gates that cannot fail on the gap they name".
The board bounds a located question, not only a census shape
(`Bound({ceiling, question})`): open obligations (39), iteration costumes
(490), prose coordinates (34), ghosts (18,681), prose by class (516 in the
union), each a falling line seen RED one below its ceiling. `mentl check` with
no target judges the project; `mentl check <entry>` reports every module of the
link, each diagnostic once, at its own module; the eight `own` markers the
inference refutes are fixed. The prose facet gains token-bounded forms and the
classes the design lists. The 134 `drift-audit: ignore` markers are bounded,
and drift rows 128 and 131 retire into a banner census shape. The census roster
is listable (`mentl query <entry> census`). The blind gates are made able to
fail: the LSP hover leg, the lambda list-param leg, the under-application leg,
`wt_state_key`, the consult gate (wired or retired by name),
mn-mutual-negation-gate, mn-arm-wide-op-arg.
Boundaries: the dead-import bound waits for M2; the re-founded iteration
detector is AU1, so bound today's detector's count; fmt strips banners, you
bound them.

### 2 · m9 — one link model, read from the DAG

Design: 925–972; MOD-4; convergence 17.
Every compile is the import DAG from an entry plus the prelude edge — the
fixed point, `mentl compile`, a battery fixture, a lesson — woven topologically
with each cycle judged as one binding group. The march judges src/main.mn's
DAG; the library roots the medium ships are each judged by the board as their
own entry, and main.mn's "shipped surface" imports are deleted; a run fixture
compiles from its module path. Deleted: the blob assembly in march.sh and
wt-env.sh, `driver_canonical_order`, `battery_libs`' text prefix, the three
tutorial exclusions. The march's verb-parity leg compares the fixed point's
module set with `mentl query src/main.mn modules` and refuses any difference
(RED first against today's blob). Expect a TRANSITION.
Boundaries: `E_LayerInversion` and the lib→src edge deletions are M3, a later
lane.

### 3 · threads — the race rule reads every write; a spawned instance shares the module's values; instance segments

Design: RACE 1704–1725, SPACE.1 1770–1785; TH-1, TH-2, TH-3; §5.4b
(1483–1514).
Instruments first: the TH-2 crucible and the TH-3 pair, as written in the
design, measured on the boot. Then the forms: one published write fact (the
`resume … with` updates plus every store the age claim resolves to `TgState`),
read by the arena and the race rule alike; under a spawning schedule, Memory's
loads and stores split if the crucible demands it; a spawned instance takes the
root's module-values record through the task record and never runs
`$__init_lets`; instance segments (one atomic add per chunk, a private bump
inside, an arena's region a span of its own instance's segment), and the
`spawn_task` conjunct near wasm.mn:2345 deleted.
Gates: the crucible refuses `E_ThreadedBranchEffect` naming the in-place store
while its read-only control runs; the TH-3 pair holds under both schedules;
spawning-module-runs-the-body asserts exits > 0 and the heap back at its mark;
a contention micro prints its wall time beside Seq; the self-compile peak
ratchet holds.
Boundaries: EFF moves ops between effects later and reads your write fact;
SPACE.2 (pools, emission as a fanout) is later.

### 4 · trap — traps are in the row

Design: 1680–1703; PR-2, PR-4; §5.1's two-constant-folders class.
The instrument first: `fn main() = (0x80000000 / (0 - 1)) / 2` through
`mentl check` and `mentl compile`; if a folder traps the compiler, one folder
that asks the claim it raises. `out_of_range` answers `!` and charges `Trap` at
its 14 call sites. An index, a slice and a byte read raise `PInBounds(receiver,
index)`, decided by the fragment from constants and from lengths read along
edges; an open claim charges `Trap`. A capability label states exactly the
absences it was proven from: "Total" is not claimed while divergence is
unrowed, and `extract_chase` carries `Trap`. Count the fallout before the cut —
every `with Pure` or `!Trap` over an index or slice — and sweep it with the
medium (`mentl tighten` where it applies).
Gates: crown `leak-index-trap` and `sound-index-proven`; the frontier asserts
`extract_chase`'s row carries `Trap`; the fold fixture.
Boundaries: the path read that proves guarded indexes is #109, so a guarded
read stays honest debt; divergence stays a named peer.

### 5 · render — one renderer for the developer's eye, and `!` is the never type

Design: N2 531–543, N4 552–572, the syntax lens's additions 604–653, T6 inside
T (1806–1874); SA-7, MS-4, TH-11.
Every surface that shows a type — `where`, `doc`, `query … type of`, the
caret's Query line, the View's JSON, LSP hover, every diagnostic — renders
through one function: the formatter's type projection, with names for free
variables read from a render context and never bound in the graph (T6:
`where`'s four rename brackets deleted; the projection family declares
`!GraphWrite + !RowWrite`, armed). Unit returns omitted; a learned contract
rendered as the predicate a developer would write; row variables and type
variables in disjoint alphabets; `doc` lists an effect's ops and a module's
value lets. Until N1 names them, an unnamed op parameter renders as its bare
type, never `_:`. N4: the probes first (a one-op effect `-> !` against `-> Int`
under `where`; `fail` performed at two result types in one function), then `!`
quantified per perform and never at the effect, and `E_ResumeOfNever` armed at
birth. The head round trip, `parse(render(head)) == head` over every
declaration in the link, is a board leg.
Gates: a frontier leg asserting `doc lib/prelude.mn`, `where … Filesystem` and
`where … fmt_run` print no `@e` handle, no `-> ()` and no `WASI(a)`; the
`E_ResumeOfNever` fixture (it compiles clean on the boot); the round-trip leg
seen RED on the boot.
Boundaries: N1, N3, N5 and N6 are later lanes. fmt owns its canonicalizations;
you own the type and head projection both lanes read.

### 6 · fmt — `mentl fmt` makes the project canonical, cargo-style

Design: 343–459, read whole; SA-2, SA-3, SA-6, SA-14; convergence 8.
As designed: no target formats the project and `--check` writes nothing; the
render is a parse (measure the parse-only render against the judged one over
the whole tree first — each difference is a layering defect to remove); one
arena per file; one tree walk (`march_walk` generalized, read by fmt, the
march, the battery and `query_dir`); `.build/fmt.stamps`; `E_DuplicateImport`
armed, with fmt's lift as its fix; stated equivalences in the conservation
census; the canonicalization band (duplicate imports, `-> ()`, decoration
runs, `0 - <literal>`, the sole-parameter binder as an arm list with the parser
building the one-arm list as the same LambdaExpr, the ownership marker before
the name); a literal's authored spelling preserved; the project written
atomically; the proposal and teach batteries addressed by identity (`// propose
??1: …`, `// teach inv: …`); the pre-commit rung becomes `mentl fmt --check`.
Gates: as listed at 445–459.
Boundaries: the type and head projection is render's; touch format.mn's head
render only where a canonicalization needs it, and say so.

### 7 · verbs — a verb never costs more than its desugaring; lib/dsp obeys the Stage Law

Design: V2 inside V (1875–1909); VERB-4, VERB-5, SA-4, TH-13; §6 (1995–2065).
Under Seq a fanout's branch literals are applied in the frame (R0i's law
extended to branches), the tuple is a record only where it escapes, a `<~` in a
branch literal is a line of the enclosing record, and a fanout merges into an
N-ary stage through the parameter-product calling convention. The Stage Law by
hand in lib/dsp: `gain`, `clip`, `mix` and the filter stages take the datum
last, and their callers in lib/dsp, examples/pulse and tests/ follow.
Gates: `match (x + 1) >< (x + 2) { (a, b) => a * b }` under `!Alloc` grows the
heap by 0 (RED on the boot); Pulse's `render_frame` and rooms rewritten in the
verbs render a byte-identical WAV (the pulse-render oracle); `sig |> clip(0.9)`
fills the datum.
Boundaries: the prelude's datum-first signatures (`reduce`, `scanl`, `nth`,
`clamp`) and `T_StageOrder` are AU2, a later lane.

### 8 · env — configuration and secrets are an effect, and the demand is the manifest

Design: E1, 2292–2520 (§1.1 the form, §1.2 the landing, §1.3 what is named),
and the env kills at 2832–2936.
As designed in §1.2: the two WASI environ ops and their import rows;
lib/env.mn (`env`, `env_opt`, `env_from_host`, `env_fixed`); the perform-site
instance grounding — the second writer of an effect instance's value
dimensions; the roster read at the perform sites through `served_at`
(`env_demand`, one home, read by the `env` facet and the launch gate);
`E_EnvNameUngrounded`, armed at birth; `emit_start`'s launch gate; the shim
passing exactly the roster's names; the crown and micro fixtures RED first; the
frontier leg; SYNTAX's section; the toolchain-variable table in
tools/wt-env.sh with its doc-truth census.
Boundaries: the page's environ is L-F's (`Hβ.felt.page-environ-from-project-dotenv`).

### 9 · asm — the medium assembles its own output, and the page runs programs

Design: L-F — decision 4 (3108–3183) and its entry in the sequence
(3295–3359); README's WABT sentences.
src/asm.mn assembles the emitter's own WAT dialect (measure the
instruction and keyword set from the emit first); `mentl asm`; the RED-first
gate — the boot's own m2 assembled by the wheel instantiates and compiles the
wheel to the same bytes `wat2wasm` produces. WABT leaves the shim, the march
and every gate through one assemble helper in tools/wt-env.sh. The worker
gains a run role for user programs (in-page `mentl run`); the page gains
"download .wasm" and run; the fixpoint seal runs on the page. Measure the
in-wheel assembly time of the full module; if it is too slow, name
`Hβ.emit.binary-is-the-emit` with the number.
Boundaries: march.sh is also m9's; confine your march change to the assemble
helper.

### 10 · canvas — the canvas

Design: L-D — the CANVAS paragraph and the aspect strip (3184–3294), its entry
in the sequence (3295–3359), docs/MENTL_SPACE.md's canvas sections.
Tokens and spans come from the wheel (the View carries them, and the page's
JavaScript tokenizer is deleted); a virtualized highlight; line numbers; find
by edge (`query refs of`, `text`); fmt on idle; verb geometry from
`VerbFrame`; the aspect strip (eight cells per line, the row cell the
ambient-world glyph); obligation marks; the ownership trace; drafts persisted;
the trail as undo.
Gates: IDE gate legs RED first on the current page — render fidelity through
the wheel's spans, the strip's cells against the View, find by edge.
Boundaries: the Severance Map and the ledger bands are L-E, a later lane;
src/space.mn's Query line render is render's.

### 11 · reflink — the reference link

Design: M1, 654–765; gates 1060–1081; MOD-1, MOD-6, PR-1; convergences 5 and
13.
At the one writer a reference records the declaration it resolved to
(`graph_ref_link(ref, decl)`, trailed, replacing the name note), and the env
entry carries its declaration's handle from registration. `refs of` answers by
link. The name-keyed reach walks — reach_entry_names, emit's plan_reached,
derive's reach_units, query's demand_round — walk links
(`Hβ.lower.reach-edge-on-node`). A site is a node (`owner_decl` read up the
parent edge; `Site({module, span})`), so audit attribution, `imports`,
`unreferenced` and the audit's pending tier stop comparing spans across
modules. An effect name in a row that names no declaration refuses
(lib/persist.mn's `!Network`).
Gates: `refs of` a name declared in two modules answers each its own; the
unresolved row name refuses; `mentl audit src/egraph.mn` charges
`apply_rules_from` none of graph.mn's or types.mn's obligations.
Boundaries: M2's facets, M3's layer, M4's visibility and M5's symbols are later
lanes built on this link.

### 12 · earlyexit — early exit is a resume grade

Design: V1 inside V (1875–1909); VERB-3, MS-10; convergence 2.
The instrument first: an arm that resumes on one path and answers on another,
under `!Alloc` — what does it lower to today? Then `ResumeUse × MayAbandon`,
the answering path lowered through AN-2's unwind; the prelude's `any`, `all`,
`find` and `take` stop at the first hit (`any` is the fold of `||`), and
`iterate` yields lazily.
Gates: `any` over five elements under a counting handler counts 3 (5 on the
boot); the mixed-arm micro.
Boundaries: V3, V4 and AU3's new vocabulary are later lanes.

## After Wave A

Wave B, built on what Wave A integrates: the course (ten lessons, a lane each,
after verbs and threads), L-E, N1 + N3 + N5 + N6, M2–M5, M7, M10, M11, the rest
of T, V3, V4, EFF, AU1–AU6, then M6, M8, M12. Wave C: W1–W3, #159 with MS-8,
SPACE.2, #108, #109.
