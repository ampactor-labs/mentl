# THE AUTHORED TEXT IS THE DEVELOPER'S DECISIONS — from pin c8ba5799 (2026-10-06)

> This file is the program the dispatched model assembled across the October sessions, kept
> WHOLE: this head section is new, the sections after it are the earlier plan
> bodies (the second program and the Env protocol, the Space pivot, the
> program from pin 2974547b) with only their status markers corrected. Its
> FIRST act after approval is §0: the program moves INTO PLAN.md (and the
> peers it names into RESIDUE.md), consolidated so no document contradicts
> another — then it lives in git, in the three documents every session reads,
> and never again only in a file outside the repository.

## Context — what Morgan asked (2026-10-06)

1. A `mentl where` answer, circled: `effect Filesystem` renders
   `fs_write_file(_: String, _: String) -> ()` — "ugly, non-intuitive,
   non-self-explanatory … one of the things I hope Mentl can solve."
2. "Ultracode some agents" to find what `.mn` code could align better with
   SYNTAX.md, should use the five verbs, under-uses multithreading, under-uses
   multi-shot, and how the medium's own proposal/codegen/proof-space machinery
   could be used better.
3. "Make it right, fundaMENTLy — the ideal root design, the most Carried-Truth,
   Mentl way."
4. `mentl fmt` with no target should work cargo-style: format the modified
   `.mn` files, remove duplicate imports ("a syntax error") and every other
   syntax-format issue.
5. The tutorials become the Pulse course; the Wasatch symphony ("Inversion")
   stays in the program; this plan file updated to the current state WITHOUT
   losing anything, and protected.
6. Everything leans into the arena.
7. Plain `mentl` commands, their answers read whole — stripping them is the
   Carried-Truth violation at the development-protocol level.
8. Every named peer re-grounded; the standing question for every design: is
   this the best possible, maximally human-empowering design, foundationally —
   SOTA-surpassing for its domain — using the medium's comments-as-graph
   paradigm and its multi-threaded, multi-shot proposal machinery (the
   teaching compiler: not AI — better).
9. Later the same morning: "does import graph tracking fall out for free?
   what else falls out for free?" — answered below (§4, rebuilt around the one
   edge everything falls out of).
10. "Fuck a refuter… if the artifact could be better then go right ahead —
    this isn't in production yet, move fast and break things." No refuter
    passes: a finding that shows the artifact can be better is built. The
    mechanical gates stay — the fixed point, the census bounds, the battery —
    because they are what makes breaking things safe (a broken boot stops all
    work), and they cost seconds where a refuter costs an hour.
11. "Do we really need [the audits]?" Not to move: they run on in the
    background, nothing waits on them, and each measured class they report
    becomes a board bound (so the medium audits itself on every pin) or a
    landing.
12. "The new first todo should be to integrate it with PLAN.md — updating and
    consolidating so there are no conflicting docs — so this plan can live on
    forever, at least in git history." → §0.

## The root, in one law

A4 settled it for rows: the POSITIVE row is inferred and projected, and the
source keeps only decisions (negations, instance pins, `Pure`). The same law,
read at every altitude this turn touched, is the root design:

**The authored text holds the developer's DECISIONS. Every fact the graph can
compute is PROJECTED and MAINTAINED by the medium — never hand-kept beside the
graph.** A hand-maintained inventory is the Carried-Truth Law broken at the
surface: it rots, and a projection cannot. Read against what the medium
answered this session:

- **A signature's parameter names are a decision; positional types are an
  inventory that dropped the decision.** The parser accepts "either a bare type
  (positional) or `name: Type`" (`parse_op_param_one`, `mentl doc
  src/parser.mn`), so `effect Filesystem` declares `fs_write_file(String,
  String)` (src/types.mn:4580) and lib/io.mn declares `fd_write(Int, Addr, Int,
  Addr)` with the names living in a comment above each op — the comment is the
  confession. SYNTAX's own law: a parameter list is a product whose fields
  have identity (their names); position is a projection, never the key. → §3.
- **What the voice renders is a projection, so it must speak SYNTAX.** `where`
  prints `-> ()` (SYNTAX omits unit returns), `_:` for a nameless field, and
  `mentl doc` prints free type variables as debug handles (`kind_eq : (a:
  t59337@e47275 …)`) and a learned function-parameter contract as `where self
  is one of tokens`. One developer-facing renderer for every surface. → §3.
- **Layout is a projection; the project is canonical by one command.** →
  §2.
- **The import block is the module's scope: a decision the medium maintains,
  never an inventory kept by hand.** Today:
  - it holds duplicates (infer imports `io` twice and `verify` twice);
  - the facet that should judge it is wrong in both directions;
  - visibility is transitive, so a module uses names its manifest never lists;
  - the runtime library's import of the compiler's metaschema lands in every
    user's namespace.

  What crosses each edge is a projection, never written into the text. → §4.

## Where things stand (read this session)

- **The audit (§5), in its headlines.** Each was measured by the medium's own
  verbs, and where several lenses agree they reached it independently.
  - Proof debt rose 37 → 39 across L-C, and nothing refused it.
  - `mentl audit` advertises "Total (proven never to trap)" over 14 trap sites
    no row records.
  - 490 index-threaded loops sit under a "ratchet" with no bound (390 when the
    tier was born).
  - `any`, `find` and `take` never stop early, because the resume grade cannot
    say "stop".
  - A fanout costs an allocation its let-spelling does not, so the verbs refuse
    under `!Alloc`.
  - Any spawn turns off every arena in the module.
  - The race rule cannot see a store made in place.
  - The wheel never performs a multi-shot op, while 12 speculation brackets are
    written by hand.
  - `where` writes the graph in order to render a name.
  - Of the 463 RESIDUE peers re-grounded, 45 are closed but unmarked and 51 are
    stale.
  - 455 of the medium's 457 effect-op parameters have no name.
  - The fixed point judges a different wheel than `mentl compile` builds.
    march.sh concatenates every lib module, lib first, then src. The driver
    weaves src/main.mn's import DAG, src first. The blob also judges
    lib/combinators, lib/audio/wav and lib/ml/grad, which the DAG never links.
  - The compiler recognizes library effects by their spelling: 10 `"Alloc"`
    literals in 7 modules. A user's own `effect Thread` gets the schedule's
    reading.
  - `mentl check src/main.mn` reports the entry module only. So eight authored
    `own` markers that the inference refutes never reach the board (six in
    graph.mn, one in infer.mn, one in lexer.mn). "The wheel carries zero
    diagnostics" was measured on main.mn alone.
  - src/types.mn (5,384 lines) is in every user program's link, through
    lib/io, lib/json, lib/lsp_frame and lib/dsp/clock. Three of those four
    edges are dead.
  - 516 comments are decoration, archaeology or lifecycle prose, and 134
    `drift-audit: ignore` markers silence a gate.
  - `refs of lines` answered 56 sites, mixing the emitter's local
    `let lines` binders with the prelude's `lines`. An earlier `where` named
    one of those locals (backends/wasm:2808) as the declaration.
- **L-C is repinned, not yet committed.** `MARCH_REPIN=1 bash tools/march.sh
  --fixpoint`: CLEAN m2 == m3 (556,729 lines, census 0), m3 leg 37.36 s · 386 MB
  (395,776 KB), and — the first determinism probe ever run on a clean march —
  FIRST LIGHT m3 == m4, stamped in `.build/gate/fixpoint-stamp`. Boot
  `c8ba579971428cf1cae99d7a0568e797295660c8614703d713e0bb28e09be92e`. The board
  at the pin: crown, proof-exactness and effect-identity green, frontier 599 pass
  / 0 red / 1 expected-red; micros 377/377 on the candidate. The first L-C pin
  (d956687d) is the parent block in boot/PROVENANCE.md.
- **The import facet lies both ways.** `mentl query src/main.mn imports`: 258
  edges, 2 DEAD (infer→canon, parser→canon). `mentl query src/main.mn "refs of
  ty_string"` — canon.mn's only declaration — answers 24 references in parser
  and infer, so both DEAD verdicts are false: `decl_names_of` (src/query.mn:653)
  counts fns, types, effects and handlers and ends in `_ => []`, dropping value
  `let`s; `refs_inside` (src/query.mn:674) tests a reference's span against the
  importer's extent with no module, while every module's spans are its own
  1-based coordinates (the containment class D3 closed at the cursor), so `used`
  can be a false positive. The two duplicate edges print `used` twice.
- **lib stands on src.** lib/io.mn, lib/json.mn, lib/lsp_frame.mn and
  lib/dsp/clock.mn import src/types.mn; lib/search.mn imports src/types.mn
  (`Abort` at types:4324, the graph checkpoint ops at types:2892) and src/own.mn
  (`catch_abort` at own:32), and src/lower.mn imports lib/search.mn —
  `backtrack` rolls back the COMPILER's graph trail, so it is compiler machinery
  wearing a lib path. `Filesystem` is declared at types:4576 though its bridges
  (`fs_*_impl`) live in lib/io.mn.
- **The prose the verbs flag.** lib/io.mn cites net.mn, tcplisten sockets and
  `std/compiler/types.mn`; lib/search.mn cites src/oracle.mn, commit hashes,
  walkthrough sections and line numbers; types.mn's Filesystem block cites a
  walkthrough and commit 1debfdc, "v1", and "fs_list_dir lands separately"
  (it exists); src/canon.mn's header claims a placement constraint from the
  concatenated-wheel era. `fs_read_file_impl` answers an empty string on an
  open failure ("caller should distinguish via fs_exists") — a fabricated value.
- **fmt.** `fmt_run` (src/main.mn:433) judges the entry's whole weave to render
  one module's parse (one wheel judgment measured at 22.68 s / 450,808 KB);
  `mentl fmt` requires a target (src/cli.mn:225); the pre-commit rung formats
  staged src/ and lib/ files and excludes tests/ because fixtures bank exact
  spans.
- **The comment-reference census:** 139 narrations in 19 modules when each
  module is checked as its own entry, 0 in the whole link — the flattened-link
  face of `Hβ.voice.comment-ref-gate-reads-the-flattened-link`.
- **The medium's own projections show internals a developer never wrote**
  (`mentl doc` read whole for src/main.mn, src/parser.mn, src/format.mn,
  src/cli.mn, src/types.mn; `mentl where`): free type variables as debug handles
  in every `doc` line (`kind_eq : (a: t59337@e47275 …)`, `format_default :
  Handler(Format, t43187@e195)`); the phantom `WASI(a)` on every row that
  touches the host (N4); learned contracts as `where self is one of x`
  (`runs_of`, `parse_brace_form`); `_:` for every effect-op parameter; a
  `String` rendered as `List(Byte)` in one place and `String` in the next
  (`query_dir`'s names); and ledes that are some other comment's text (`Stmt`'s lede in types.mn reads "op_name,
  slot_idx — the slot in __state where the arm's fn_idx was written by the
  caller").
- **Declared ops nothing performs.** `mentl query src/main.mn performs`: 86
  effects in the wheel's link, 20 carrying ops nothing performs — among the
  compiler's own, `Interrogate` 0/3 (installed by `edit_run`, every op dead),
  `Format` 1/3, `Workspace` 3/11, `Interact` 4/10, `GraphWrite` 35/39, `EnvRead`
  5/6, `LowerScope` 23/24, `InferCtx` 22/23, `CursorRead` 2/3, `Memory` 19/24,
  `Thread` 2/3, `SharedMemory` 1/7; among the library's, `Clock`, `Sample`,
  `IterContext`, `Network` (dsp/signal), `Distort` and `Choice` are performed
  nowhere in the wheel's link. Since L5 a handler must answer every op of every
  effect it answers, so a dead op is dead code in the declaration AND in every
  handler that answers it.

## The arena in every landing

The arena is the program's memory model now: every extent runs in one (`(body)
~> arena`), what an extent publishes moves and the rest dies at its exit, and
nothing else reclaims (PLAN §7, the arena and Arena·P2 bullets). Each landing
below names its extents rather than inheriting a heap that only grows:

- **F** — one arena per file (parse, render, re-parse, census); a project pass
  peaks at one file's scratch.
- **N** — the renderer and `mentl rename` answer per request, and every session
  answer is already an arena; the sweep holds one module's rewrite at a time.
- **M** — the facet's walk and tighten's per-module import rewrite each one
  arena; the visibility mask is a judgment fact, published, never scratch.
- **The course and W1** — the per-sample path is `!Alloc` (Pulse scene 1
  measured zero heap growth across 480,000 frames); whatever a render allocates
  per block runs in an arena per block, so a long render's heap is one block's.
- **Threads** — the arena's open frontier decides the parallel work. In a
  module that spawns, an arena runs its body and reclaims nothing (SYNTAX §`~>`,
  `Hβ.arena.per-instance-regions`). The threads lens measured the mechanism
  (TH-1): one conjunct at wasm.mn:2345 turns off every arena in any module that
  demands `spawn_task`. So the wheel's first threaded schedule would give up the
  self-compile peak the arenas bought, 1,065,228 KB down to 519,548 KB. A
  region per instance (SPACE.1) is therefore the precondition for every
  parallel extent this program wants, and it sequences before all of them:
  - the course's lesson 10;
  - the compile's level-set fan;
  - the battery's fixtures;
  - `query_dir`'s independent programs.
- **Multi-shot** — a suspended arena keeps its region and each resumption is an
  arena of its own (C×A); durable search and resumable compiles stand on that.

## 0 · The plan lives in the repository — the first act, before any other

The plan sits outside git (`/root/.claude/plans`), and the container is
reclaimed when the session ends. Two documents that disagree are the
Carried-Truth Law broken at the doc layer. §0 runs in three steps, in this
order. The middle step is §1, because the tree already carries L-C's
uncommitted records: `git status` lists 33 paths, among them PLAN.md,
LEDGER.md, RESIDUE.md, docs/MENTL_SPACE.md, boot/PROVENANCE.md and the boot
itself. A docs commit made before L-C's would describe a boot that commit does
not carry.

**0.1 · The record (minutes; the first act).**
- `docs/record/2026-10-06/program.md` is this file verbatim, except that model
  identifiers become "the dispatched model". That is the rule for anything
  pushed, and `diff` against this file shows those words and nothing else.
- Each audit lens's final answer goes beside it verbatim as `<lens>.json`,
  extracted from the agent transcripts. All seven lenses have reported:
  - the five peer parts;
  - verbs, proposals, multi-shot and threads;
  - modules (task ab103d43d3e799736);
  - syntax (journal entry acb0982ce4bb3be83, saved at the scratchpad's
    lens-syntax.json).
- Stage exactly that directory. The pre-commit gates fire on staged `.mn`, and
  none is staged, so the uncommitted L-C tree is untouched.
- Commit ("the program as planned on 2026-10-06, and the audit's answers,
  recorded verbatim") and push. After this commit, nothing of the plan exists
  only outside git.

**0.2 · §1: L-C closes.** Its commit carries the pin and every L-C doc edit.

**0.3 · The integration: one docs commit on top of L-C's, after which no
document contradicts another.** Each truth in this file moves to its one home.
The same commit deletes the record directory from the tree; git history keeps
it at 0.1's sha, which the LEDGER entry for §0 names.

| What this file holds | Its home after 0.3 |
|---|---|
| The root law (the authored text holds decisions) | PLAN §9.1: the Carried-Truth Law at the SURFACE scale, written inside the law it sharpens, beside "at the PERFORMANCE scale" |
| The order (§7) | PLAN §11. THE STANDING CURSOR is rewritten as this order, one paragraph per landing, each pointing at its RESIDUE design. THE ORDER FROM E4 is folded in: its arena is landed, and positions-are-cells and the solver are this order's last two |
| Each landing's design (G2, TRAP, RACE, EFF, F, M1–M12, N1–N6, T, V, AU, SPACE, E1, W1–W3) | RESIDUE, one entry each. Where an entry already holds the gap, that entry is upgraded instead of a second one being written: per-module-env-overlay → M4, reach-edge-on-node → M1, link-is-reachability → M9 (an orphan today), catalog-as-projection → N5, free-variables-render-as-handles → N2, render-must-parse-to-the-same-tree → N2's round trip, filesystem-impl-bypasses-the-effect → N1/N3, literal-spelling-is-intent → F, comment-ref-gate-reads-the-flattened-link → M7, word-arithmetic-is-memory → EFF, index-partiality-is-a-row-fact → TRAP, iteration-is-topology → AU, arena.per-instance-regions → SPACE.1, level-set-par-walk and the other Phase 9.2 peers → SPACE.2 |
| SYNTAX contradicting itself (the syntax lens, SA-7 and SA-8) | Trued in place, because SYNTAX is the wheel and the lathe catches up at the landing named. `-> ()` is a format-liftable redundant form (:1596–1600; :1631's `tick() -> ()` loses its arrow), and F lifts it. One ownership-marker position: before the name (`ref nodes`, `own ast: Node`), the one spelling that works with or without a type; F lifts `ast: own Node`. `fn spawn_task(…)` is renamed, since it names a WasiThreads op that E_FnShadowsOp refuses. `clamp` goes datum-last (AU2). The hole example then uses a call that genuinely is not a stage, `list_set(??, i, v)`, which the Stage Law section already uses. The `<~` example takes the arm form. |
| The course's additions (§6) | docs/MENTL_SPACE.md §5.5, the course's home |
| "The artifact is the refuter" (context item 10) | Rewritten in place in CLAUDE.md and PLAN §9.10. CLAUDE.md ⧗: the adversarial-dispatch bullet becomes "a finding that shows the artifact can be better is built; the build and the mechanical gates refute a wrong form in seconds and make breaking things safe; agents are dispatched for breadth, never as skeptics of a design before it is built". CLAUDE.md ⟲: "adversarial design-convergence before a byte changes" and "independent verify" become design inline against the artifact's records, build, and the orchestrator running the gates itself before any commit |
| The arena in every landing | PLAN §11, one paragraph under the cursor |
| Where things stand, and §5's measured classes | PLAN §7, as new bullets and trued ones. The per-module manifest bullet says visibility is still the import CLOSURE. The #129 bullet's "the next landing" pointer is trued |
| §5's peer verdicts | Applied to RESIDUE in place, from the record's JSON; §5.1 lists every action |
| docs/PROGRAM-2026-09-25.md, docs/proposals/ | Read whole, their live content folded into PLAN §11 and RESIDUE, then deleted from the tree (history keeps them) |
| Every other file under docs/ | Read for contradictions with the three docs, then trued. A doc none of the three points to is folded and deleted |

**The gates.** These are three doc-truth checks. Each is seen RED on today's
tree, then the sweep turns it green. Together they are CLAUDE.md ⟳'s queued
"comment-ref gate generalized to doc anchors".

1. **Every `Hβ.*` name cited in PLAN, CLAUDE, SYNTAX, RESIDUE or LEDGER is a
   RESIDUE entry header.**
   - Today the header form is ambiguous. 508 RESIDUE lines open with a
     backticked peer name, and continuation lines are mixed in with entry
     headers.
   - So the sweep first writes one form, ``### `Hβ.x` — STATUS``.
   - The check is RED on the orphans the re-grounding named: link-is-reachability,
     module-image-cache, held-resume-record-is-not-reclaimed,
     derivative-is-source, world-widening-resume, literal-intern-outside-the-vocabulary,
     seq-addr-downcast, seq-op-signature-driven, destructure-sites,
     warm-image-pending-suppression, carried-truth-projection.
2. **Every status comes from one closed vocabulary, and closures in LEDGER show
   in RESIDUE.**
   - The allowed statuses are OPEN, CLOSED `<date>`, SUPERSEDED → `<peer>` and
     RETRACTED.
   - Today's lines carry OPEN 119, CLOSED 63, NAMED 41, RESOLVED 29, BUILT 6,
     and two dozen free words (THE, TRAP, FIRST…).
   - Every peer a LEDGER entry calls closed must be CLOSED in RESIDUE.
3. **An OPEN entry's backticked code identifiers resolve**, either to a
   declaration `mentl query src/main.mn decls` lists or to a path that exists.
   Dead vocabulary (`heap_reset`, `$world_find`, `RowAssumed`, `judge_window`,
   the movers line) therefore cannot live in an open peer. A CLOSED entry is
   history and is exempt.

**The scrub check.** No model identifier appears in anything staged.

**What 0.3 does not do.** It builds nothing. It moves the program and applies
the verdicts, and verifies with `bash tools/doc-truth.sh` and
`bash tools/verify.sh` (no wheel change). Every landing in §7 is built in its
own commit afterwards.

## 1 · Close L-C (pin c8ba5799) — the remaining steps

1. Replace the `‹NARRATIVE UNWRITTEN›` line of boot/PROVENANCE.md's head block
   with the drafted narrative (scratchpad `prov-lc-final.md`).
2. `bash tools/ide-gate.sh` (both legs) on the new boot; the twin's and the
   browser's numbers; then the Pulse session probe (scratchpad
   `probe-pulse2.mjs` against `.build/space`) for Pulse's edit/read numbers.
3. Re-measure the text projection against HEAD's (`ringcmp.sh`, old =
   2175e015's boot, new = c8ba5799's).
4. `bash tools/state.sh`.
5. Records from the drafts (scratchpad `ledger-lc-merged.md`,
   `plan7-lc-merged.md`, `plan11-lc-final.md`): TWO LEDGER entries, one per pin.
   The d956687d entry already in the tree stays exactly as written (it is what
   happened at that pin); a NEW head entry for c8ba5799 carries what the second
   pin added — the audit A1–A9, the three findings of the close, the
   measurements, the kills since the first pin, the peers named — taken from
   the draft's second half, nothing condensed. PLAN §7's bullet and §11's Arc E
   paragraph. The determinism probe becomes a gate rather than a sentence, and
   reading tools/march.sh for it found the order wrong: the `--fixpoint` leg
   runs AFTER the clean repin has already copied m2 over the boot (march.sh
   :439–466 bless, :511–529 probe), so a non-reproducing m4 sets `fixok=0`
   with the new boot already in place. `MARCH_REPIN=1` runs the m4 leg on every
   repin and BEFORE the bless (one more compile, ~37 s), the bless refused on
   m3 ≠ m4 like any other red, so no pin is ever written unprobed and
   `Hβ.march.determinism-is-never-probed` closes on that change (this pin's
   probe the first record). The c8ba5799 entry also states what the
   proposals lens measured about this pin: the wheel's open proof
   obligations rose 37 → 39 across L-C (`mentl query src/main.mn smt`; the
   pre-L-C answer in the scratchpad's head-smt.txt reads 37, and PLAN S6
   says "hold at 37"), five of them new in src/space.mn (125, 129, 112, 626,
   640), and nothing refused the rise because the board bounds census
   shapes, never answers. G2 is what bounds it from now on.
6. `bash tools/doc-truth.sh`; commit (no attribution lines, no model ids);
   `git push -u origin claude/mentl-design-audit-m1mptf`.
7. → §0.3 runs next, on top of this commit.

## 2 · F — `mentl fmt` makes the project canonical, cargo-style

**The form.** `mentl fmt` with no target renders every `.mn` file of the
project (the working directory's tree, skipping `.build/` and dot-directories)
and writes the ones that are not canonical; `mentl fmt <path>` does the same for
one file or one directory; `mentl fmt --check [path]` writes nothing, lists the
files that are not canonical with what would change, and exits nonzero — the
form a commit hook and the board read.

**Why it is fast, and why that is a law rather than a tune.** Layout is a
projection of the PARSE: the formatter (src/format.mn imports types, effects,
graph, parser, strings — no inference) renders a module from its own parse and
comment weave. `fmt_run` (src/main.mn:433–487) judges the entry's whole weave
anyway — `driver_entry_with_ranges(entry_module)` then `driver_module_ast` —
and its own comment says why: the solo route it had used installed no
diagnostic scope and narrated every dependency at a developer who named one
file. A parse judges nothing, so it narrates nothing but the file's own parse:
the scoping problem the weave route was taken to solve does not arise. The verb
reads the file, runs `frontend(source)` (src/infer.mn:1420, lex then parse),
renders, and judges nothing — the cost of an operation is the size of its
answer (§5.O). One fact to measure before the cut, not after: `frontend`
performs `EnvRead` (the parser reads the env somewhere under
`parse_type_atom`, parser:3329), so a parse-only render may differ from a
judged one wherever the parse consults a judged name. The instrument is the
whole tree rendered both ways, byte-compared; each difference names a parse
that depends on the judgment, which is a layering defect to remove, never a
reason to keep judging. Each file runs in its own arena (`(fmt_file(p)) ~>
arena`), so a project pass holds one file's scratch at a time. The tree walk is
the one the march already owns (`march_walk`, main.mn), generalized to a root
and read by fmt, `march_wheel_files`, the battery and `query_dir` alike — one
home for "the `.mn` files under a directory", skipping `.build/` and
dot-directories.

**"Modified", the Mentl way.** git is an outside oracle. The medium remembers
its own fixed point: `.build/fmt.stamps` maps each path to the hash of the
bytes fmt last saw canonical, so an unchanged file costs a hash and a project
pass costs what changed. A stamp is keyed by content, so it cannot go stale.

**A duplicate import is a syntax error, and fmt is its fix.**
- Morgan called it a syntax error. SYNTAX principle 2 agrees: when two forms
  make one graph, one is rejected. Rust and Go also refuse a repeated import.
- The import list is a SET of edges. The parse keeps one edge per module and
  reports `E_DuplicateImport`.
- `E_DuplicateImport` is armed, so `mentl check` and every compile refuse it.
  It is MachineApplicable, and its fix is the formatter's lift. In the Space,
  where fmt runs on idle, the developer never sees it; in the terminal, the
  refusal names the command that fixes it.
- The set renders in path order. A set has no authored order, and a stable one
  keeps unrelated edits from churning the block.

**The conservation gate learns STATED EQUIVALENCES.**
- `lost_atoms` is a multiset today. Dropping the second `import verify` would
  leave one `verify` atom unpaid, and the write would be refused.
- Each canonicalization therefore names the atoms it removes and the surviving
  node that still carries them. This generalizes `lost_atoms_beside`'s `stated`
  list.
- A lift is never read as a lost name, and a real loss still is.

**What fmt canonicalizes: exactly the graph-preserving band, each a fact of the
parse.**
- Layout and braces, as today.
- Duplicate imports.
- An explicit `-> ()` return.
- Box-drawing decoration runs in comments. The prose line survives, and the
  census counts lines.
- `0 - <literal>` becomes `-<literal>` wherever the literal's own kind makes
  the rewrite exact.
  - `0 - x` over a variable needs the judgment, and for a Float it is
    MaybeIncorrect (`0.0 - 0.0` is +0.0, `-(0.0)` is -0.0).
  - So that case is T's narration and tighten's rewrite, not fmt's.
- A sole-parameter binder `(x) => body` becomes the arm list `{ x => body }`,
  once the parser builds a one-arm list with an irrefutable binder as the same
  LambdaExpr the binder form builds (SYNTAX §«The residue»).
  - This deletes `arm_list_of`'s demand for a `match` body and
    `resugar_head`'s single-parameter path.
- The ownership marker before the name.

**What fmt preserves.**
- A literal's authored spelling: its radix and its digit grouping are intent
  the literal's own span holds. `48_000` stays `48_000`.
- This closes `Hβ.fmt.literal-spelling-is-intent`. On Pulse, the render wrote
  `48000` where the prose says `48_000`.

**The write is atomic across the project.** If any module's render fails the
conservation proof:
- no file is written;
- the failing module is named;
- the exit is nonzero.

**The tests/ constraint, dissolved rather than excluded.** The rung excludes
tests/ because fixtures bank `L:C` coordinates (`// propose 9:37: fill 1`,
`// teach 3: add …`) that a re-layout moves — a position standing in for an
identity. The proposal and teach batteries address by identity instead (`//
propose ??1: …`, the first hole; `// teach inv: …`, the declaration), read
through the medium's own resolution (`battery_verdict`), so every fixture can
be canonical; a contract that still banks a position is a conservation fact —
fmt refuses to move a banked address and says so, as it refuses to lose a name.

**What deletes:** the pre-commit rung's per-file bash logic becomes `mentl fmt
--check` over the staged files (the restaging stays bash, it is git's); the
weave judgment inside `fmt_run`.

**Gates:**
- `mentl fmt --check` at zero over src/, lib/, examples/ and tests/, as a board
  line.
- A three-module fixture project. One module has a duplicate import and one has
  `-> ()`.
  - Bare `mentl fmt` writes both.
  - A second run writes nothing.
  - A module whose render would lose an atom leaves every file untouched, and
    the exit is nonzero.
- A duplicate-import program that compiles clean on the boot and is refused on
  the candidate.
- A `48_000` literal that survives the render.
- The cost of `mentl fmt src/infer.mn`, measured before and after: one weave
  judgment against one parse.

## 3 · N — a signature says what it means, and every surface says it the way SYNTAX writes it

**N1 · The parameter product has identity everywhere.** An effect op's
parameters are `name: Type`, as a fn's are named; the positional form
(`parse_op_param_one`'s "bare type") is refused, `E_UnnamedParameter`, armed
once the tree carries none. The names are not invented — the medium PROPOSES
them from what the graph already holds, through the proposal machinery: (a)
every handler arm for the op binds its parameters by name, so the names the arms
agree on fill (disagreeing arms are a tie, and the tie asks its computed
question — "the arms call parameter 2 `content` and `bytes`; which does the
declaration mean?"); (b) an op the host answers (WASI) carries its names in the
mechanism-comment above it — the comment is absorbed into the signature and
deleted. `mentl tighten` authors the sweep, as it authored 1,490 row residues;
the labeled call (`write_file(path = p, content = c)`) works at every perform
the moment the names exist.

**What the circled block is, read whole** (`mentl where src/main.mn Filesystem`,
src/types.mn:4561–4600, src/pipeline.mn:846–864, `refs of` each op and bridge):
nine ops, every parameter positional; a header citing "v1", "H3.1", "commit
1debfdc", two walkthroughs and an `fs_list_dir` that "lands separately" (it
exists, as `fs_list_dir_impl`, outside the effect); three ops (`fs_open`,
`fs_create`, `fs_close`) that traffic in a raw descriptor `Int`; one handler
(`wasi_filesystem`, pipeline:846) whose arms call the `_impl` bridges; and EIGHT
call sites that skip the effect and call a bridge directly
(`fs_read_file_impl` at persist:93, main:1062 ×4, main:1390, dsp/cfc:277;
`fs_list_dir_impl` at main:362, :378, :1042, :1473), so `!Filesystem` cannot see
them and no other handler can answer them. The voice's `open_file` arm
(voice.mn:1290–1305) opens a descriptor to test existence, never closes it, and
answers the sentinel `FileHandle(0)` on failure.

**The form, dream-coded.** The effect gets its own module, lib/fs.mn, because a
capability is one unit: the effect, its one handler, and the implementation AS
that handler's arms (MOD-5, MOD-11). There is no separately callable `_impl`
left to reach past. The `fs_` prefix goes, because the module is a scope: a
module that declares its own `read_file` narrows its `import fs` to the names
it means, and the collision is settled at the edge (§4 M4). Every failure is
said.

Two naming forms were weighed and decided:
- **The lens's bare verbs** (`read`, `write`, `list`) are rejected. At a call
  site they lose what is read: a file, a socket, stdin.
- **The noun stays** (`read_file`, `list_dir`), and the descriptor ops leave
  the vocabulary (below).

The form:

```
// The filesystem as a program asks for it. The host answers it
// (`wasi_filesystem`); a function that reaches none of these proves !Filesystem.
effect Filesystem {
  exists(path: String) -> Bool
  read_file(path: String) -> String          // an unreadable path performs Fail
  write_file(path: String, content: String)
  list_dir(path: String) -> Option([String])
  make_dir(path: String)
  remove(path: String) -> Bool
  rename(from: String, to: String) -> Bool
}
```

The descriptor ops leave the developer's vocabulary: their three users
(mcp:87/94, main:305/311, main:1340/1347) are the streaming WAT sink, which owns
its descriptor inside the one handler that writes it; the bridges become that
handler's private bodies, and every direct bridge call above becomes a perform.
The rename sweep is authored by the medium: `mentl rename <entry> OLD NEW`
rewrites the declaration and every reference LINKED to it (M1's reference
link, which lands first, so the rename can never be a text replace wearing an
edge's name), module-qualified, through the formatter, conservation-checked
— the verb the op renames, M2's disambiguations and every later rename write
through.

**N2 · One renderer for the developer's eye.** Every surface that shows a type —
`where`, `doc`, `query … type`, the caret's Query line, the View's JSON, LSP
hover, every diagnostic that prints a type — renders through ONE function: the
formatter's type projection with `where`'s naming pass (`name_type_vars`: a
free variable a declaration quantifies is a lowercase name, bound in a
checkpoint and rolled back), unit returns omitted, op parameters with their
names, a contract a parameter LEARNED rendered as the predicate a developer
would write (or as the alias it is) and never as an internal provision form.
The debug renderer (`show_handle`'s `t…@e…`) stays the forensic projection and
leaves every reader-facing path. This closes
`Hβ.voice.free-variables-render-as-handles` (its remaining readers: doc,
`type of`, the Query line, hover, diagnostics) and its row face.

**N3 · Fabricated values at the host boundary.** `fs_read_file_impl` answering
"" on an open failure, and the voice's `FileHandle(0)` sentinel, are the
surrender fallback CLAUDE.md deletes: the op says what happened — an unreadable
path performs `Fail` (AN-2 makes that an abandon the install decides, with no
dummy value flowing back), and a caller that can recover asks `exists` first or
installs a handler that answers. Measured first: `refs of fs_read_file` (12
sites) and each bridge call, for every caller that relies on the empty string.

**N4 · `!` is the never type, not an effect parameter.** Every function that
touches WASI renders its row as `WASI(a)` (`mentl where src/main.mn fmt_run`:
`with Memory + Alloc + Trap + WASI(a) + Arena`; `run_run`: `WASI(b)`; `mentl
doc` prints the same parameter as `WASI(t362504@e442776)`), a type argument no
developer wrote and no reading explains. The only non-ground type among WASI's
fifteen ops is `proc_exit(_: Int) -> !`, and the parser turns `!` into a type
name that "resolves at quantify_ctor_ty to a FRESH quantified var per
occurrence" (src/parser.mn:3381–3385) — fresh per occurrence in the
declaration, then shared by every op of the effect, which makes the effect
generic in it. The probes come first, because the design follows the measurement: a one-op
effect with `-> !` against the same effect with `-> Int`, each rendered by
`where`; and `fail` (prelude:52, `fail(_: String) -> a`, the bare-variable
sibling) performed at two result types in one function — if the effect-level
variable makes those two performs one instance, a correct program refuses or
two instances ride its row, and either way `Fail` is the same case and takes
`-> !`. Then: `!` is quantified per PERFORM, never at the effect,
which is sound exactly because a `-> !` op never resumes — so an arm that
resumes one is refused (`E_ResumeOfNever`, armed at birth), and `WASI`,
`Abort` and every effect with a never-returning op stop carrying a phantom
parameter through every row in the program.

**N5 · The diagnostic catalog is a projection, so the docs cannot name a class
that does not exist.** `mentl query src/main.mn "variants DiagKind"` (read
whole) answers 77 classes; SYNTAX's three tables name ten the wheel has never
declared — `E_StatementSemicolon`, `E_PipeIntoComplete`, `E_PipeHoleAmbiguous`,
`E_ConcatTypeMismatch`, `E_ImportNameCollision`, `E_HandlerUninstallable`,
`W_CapabilityEmpty`, `W_EmptyRow`, `W_RedundantRepr`, `W_Suggestion` — each a
documented refusal that refuses nothing. `mentl diagnostics` (the lag list's
last verb, SYNTAX §«Verbs this document declares») projects the catalog from
the constructors and their projections (`diag_category`, `diag_applicability`,
`diag_refuses`, each class's declaring comment as its trigger); SYNTAX's
tables become that projection's text, and doc-truth refuses any `E_`/`W_`/`T_`/
`P_` name in the docs that the constructors do not declare. Each of the ten is
then either BORN (with its fixture, RED first) or struck from the docs — decided
class by class (`E_ImportNameCollision` is born by M2, `E_StatementSemicolon` is
F's format-lift, the rest by what the artifact does with the shape today).

**N6 · A row says where each effect enters.** The compiler's own judgment of a
variable reference performs the host: `mentl query src/main.mn "effects of
infer_var_ref"` answers `… + WASI(t298095@e270200) + Consume`, and asked why,
the medium answers nothing — `mentl why src/main.mn infer_var_ref` prints
`declared as infer_var_ref` (the gap the root-gate landing already named, still
open). Every charge is noted on the node that makes it (C5's `graph_row_note`),
so the answer is a walk the graph can already take: `mentl why <entry> <fn>
<Effect>` follows the effect from the function's row to the node whose note
charges it, through each callee whose row carries it, to the perform — each hop
its node, its address and its Reason. It is the question every developer asks
of a row they did not expect, the projection that would have found this one in
a second, and the cut line the Severance Map (L-E) draws. Gate: that command on
`infer_var_ref` ends at a perform site (RED on the boot), and a frontier leg
holds the chain for a three-deep fixture.

**What the syntax lens adds to N1 and N2 (SA-1, SA-7; its root designs R1 and
R5).**

*The census.* `CsUnnamedOpParam` is born at the measured 455 (of 457: src/types
200, lib 121, the rest of src 134) and ratchets to 0.

*What deletes at zero.* Once the count is zero, four things go, so the form is
unsayable:
- the parser's bare-type production;
- `op_scheme_param`'s invented `_0` and `_1`;
- `render_op_param`'s `_` branch;
- the comment-held name tables over WASI (lib/io.mn:491–521) and SharedMemory.

`E_HandlerArmArity` then compares NAMES, not counts.

*The same law at every head.* A constructor's fields, an op's multi-field
result and a handler's config are one parameter product, keyed by name. A
census shape, `CsPositionalProduct`, counts two kinds of head:
- two or more unnamed fields of one type;
- a tuple of three or more.

Its sites include `VerbSpec(String, String, …, String)` with its field table in
a comment, `Graph`, `Region`, `inf_exit_fn`'s four-tuple and `ls_enter_frame`'s
parallel lists. Teach proposes the record (T3), and AU2 writes it.

*N2 is one head projection, under a round trip.* For every declaration in the
link, `parse(render(head)) == head` is a board leg, which closes
`Hβ.fmt.render-must-parse-to-the-same-tree` for heads. The leg also requires:
- row variables and type variables to render in disjoint lowercase alphabets.
  Today `spawn` renders as `spawn(_: () -> a with a)`;
- `Any`, `t…@e…` and `-> ()` never to render;
- `doc` to list an effect's ops and a module's value lets. Today it renders
  `E : ()` and leaves canon.mn's `ty_string` out.

**Gates:**
- A parser fixture refusing an unnamed op parameter. It is RED on the boot,
  where it parses.
- A frontier leg asserting that `mentl doc lib/prelude.mn`,
  `mentl where src/main.mn Filesystem` and `mentl where src/main.mn fmt_run`
  print none of these: an `@e` handle, `_:`, `-> ()`, `WASI(a)`.
- An arm resuming a `-> !` op is refused (`E_ResumeOfNever`); it compiled clean
  on the boot.
- A program reads a missing file through `read_file` under an install that
  answers `Fail`, and takes its arm. On the boot it reads `""` and runs on.
- A census shape counting direct bridge calls (`*_impl` reached from outside its
  handler), born at the measured 9 and held at 0.
- The head round-trip leg.
- `mentl tighten` writes the names, `mentl rename` writes the vocabulary, and
  `mentl fmt --check` stays clean.

## 4 · M — the reference link, and the module as a scope (#189 with #188)

**Morgan's question ("does import-graph tracking fall out for free? what else
does?"), answered by reading the judgment.**
- At every value reference, `infer_var_ref` (src/infer.mn:4048) already holds two facts:
  - the module the reference stands in (`rm = graph_module_of(handle)`);
  - the module that declares what it resolved to (`dm = inf_decl_module(name)`).
- It uses the pair once, for F0b's `E_MissingImport` test, then drops it.
- `graph_ref_note(name, handle)` files the reference under its NAME. So the
  refs column answers "who mentions this spelling" and never "who reaches this
  declaration" (PLAN §7: "`refs_col` is keyed by NAME, not handle").

So one edge is missing. Once it is drawn, the import graph stops being a facet
to compute and becomes a projection to read.

**M1 · The reference link (the root of everything below).**
- **The link.** At the one writer, a reference records the declaration it
  resolved to: `graph_ref_link(ref, decl)`, trailed, replacing the name note.
- **The env entry carries its declaration's handle.** It is written once, where
  the entry is minted, because registration stands on the node. Resolution then
  hands over the handle, not a name to look up again.
- **This is `Hβ.lower.reach-edge-on-node`'s edge.** The re-grounding counted four
  name-keyed walks of the fact it carries: reach_entry_names, emit's
  plan_reached, derive's reach_units and query's demand_round. Each becomes a
  walk of links.
- **It is also the value-reference half of #108.** The other name positions are
  type annotations, pattern constructors, handler names and effect names in
  rows. Each joins the link when #108 makes it a cell.
- **One non-value position lands here, because its absence is a silent wrong.**
  An effect name in a row that names no declaration now refuses. Today
  `!Network` in lib/persist.mn:84 resolves to nothing:
  - `mentl check lib/persist.mn` is silent;
  - `mentl where lib/persist.mn Network` answers "not found" and exits 0.

**What then falls out. Each item is a read of the link; none needs a new
mechanism.**
1. **The import graph, true.** A module's edges are the modules its references
   link into.
   - DEAD is an import no link crosses.
   - DUPLICATE is a repeated import.
   - A conduit link lands outside the module's direct imports; their count is
     exactly the migration's size.
   - Today's two false verdicts both go. Canon's value `let` becomes a
     declaration like any other. "Used" becomes a link, never `refs_inside`'s
     module-blind span overlap.
2. **The missing import, proposed.** A conduit link is the gradient's fill at
   the reference: the edge to add, accepted like any proposal.
3. **The import block, maintained.** tighten writes the set the links name, so
   a dead edge leaves and a duplicate cannot be written.
4. **Rename by edge.** `mentl rename` (N1) rewrites a declaration and every
   reference linked to it. It is module-qualified by construction and never a
   text replacement.
5. **A module's surface.** Its exports are the declarations other modules'
   references link to. The proposer's Linked ring offers those and stops
   offering substrate internals: today `hex_glyphs()` ranks first at a String
   hole (`Hβ.synth.linked-ring-offers-substrate-internals`).
6. **Dead declarations.** A dead declaration has no incoming link, and
   `unreachable` is the link closure from main. `unreferenced` stops calling
   `Ty`, `Option` and `Alloc` dead once their annotation positions are links
   (#108).
7. **The per-declaration cone.** An edit's dependents are the reverse links of
   the declarations it changed. That is E2's cone at declaration grain
   (`Hβ.session.edit-pays-for-the-program`).
8. **Link only what is reached.** Arc D's demand link is the link closure from
   main (`Hβ.driver.link-is-reachability`). That peer is an orphan whose design
   lives inside `Hβ.gate.sweep-rederives-the-prelude`. §0.3 gives it a home,
   and M9 builds it.
9. **Prose edges (#188).** A backticked name resolves through the same scope
   and becomes a link like any other.
10. **Symbols are the declaration's (M5).** Lowering and emit name a function
    by the declaration it links to (`$module.name`), and the bare-name indexes
    are deleted.
11. **Call-graph proximity** (`Hβ.cursor.proximity-reads-the-call-graph`)
    becomes a distance over links.
12. **The Severance Map's module bands (L-E)** are read over each module's
    links.
13. **A site is a node.** Audit attribution, the imports facet, `unreferenced`
    and the audit's pending tier stop comparing spans across modules. Each asks
    `owner_decl(h)`, read up E4's parent edge, and a span comparison between two
    modules becomes a type error (`Site({module, span})`).
    - The proposals lens measured the defect. `mentl audit src/egraph.mn`
      charges its last declaration with three obligations from graph.mn and
      types.mn, and the charge was predicted before the run.
    - `mentl audit src/main.mn` prints 37 pending lines for a module that owns
      3 obligations.

**The decision for visibility, argued from the thesis and stated so it can be
refuted.**
- **What visibility is today.** It is the import CLOSURE
  (`inf_module_reaches`, the F0b check at src/infer.mn:4075). Three things
  follow:
  - a module uses names its own import list never states;
  - changing a module's private imports breaks its importers;
  - the runtime library's `import types` puts the compiler's metaschema in
    every user program's namespace. Last session measured it: a user cannot
    declare `count` beside lib/lists without `E_DuplicateFnName`.
- **Why that is wrong.** A name arriving through a conduit is a NAME LOOKUP
  wearing an edge's name.
- **The rule.** A module sees three things and nothing else: its own
  declarations, the declarations of the modules it imports DIRECTLY, and the
  prelude's vocabulary (the one ambient closure). Names repeat across modules
  freely, and a collision exists only inside one module's scope.
- **The re-grounding of `Hβ.driver.per-module-env-overlay` lands here.** "A
  name resolves through its module node's scope — its own decls, then its
  import edges' exports — never through the newest flat-env entry." Pulse
  measured the defect: its `envelope` rebound the DSP library's own reference,
  and the refusal blamed the library with a misattributed `E_MissingImport`.
- **The mechanism is the link, not an env tag.** F0b built the
  env-entry-tag design and the wheel refuted it with 3,541 refusals, because the
  env re-publishes entries and a tag names the publisher. With the link, each
  reference's declaration is read, never looked up.

**M2 · The facets read the link** (the instrument, and the migration's size,
before any visibility change).
- `mentl query <entry> imports` prints, for each edge, the names that cross it,
  then `conduit`, `DEAD` or `DUPLICATE`.
  - Value lets are declarations like any other.
  - Each site is compared by (module, span), never by a bare span.
  - Six comparison sites share the module-blind shape (MOD-1): `refs_inside`,
    `ref_is_outside`, `decl_names_of`, `import_is_used` and its
    `module_tail_eq`, and `audit_walk`.
- A second facet lists every conduit reference.
- A third, `importers of <module>`, gives the reverse edges across the
  repository. Today no facet can say who imports lib/combinators.mn,
  lib/audio/wav.mn or lib/ml/grad.mn.
- `where` and `query` exit nonzero when they answer "not found".
- **Two facets of one medium may not disagree.** A board bound refuses any
  edge `imports` calls used into a module `unreachable` calls linked-whole and
  never called.
  - It is born at the measured 5: main's edges to dsp/feedback, dsp/signal,
    dsp/spectral, ml/tensor and math.
  - It falls to 0 with M9.
  - The facet's other false "used" verdicts were measured too: lower→search,
    io→types, json→types, lsp_frame→types and math→strings.

**M3 · Layer is a fact of the module node, and lib stands on its own**
(MOD-3, MOD-8, MOD-10).

*The rules.*
- The runtime (lib/) sits below the compiler (src/), and a runtime module
  imports only the runtime.
- `E_LayerInversion` is armed at the import edge. It is born at zero once the
  moves below are done.
- A user program resolves against its own project and the runtime, never
  against the compiler's root. `driver_module_path` stops probing src/ and
  /mentl-home/src for an importer that is not a compiler module. A user's
  `import graph` therefore answers `E_MissingModule`; today it links the
  compiler's src/graph.mn.

*What crosses today, and where each goes.*
- **lib/io, lib/json and lib/lsp_frame** import types and use nothing from it.
  The edges are deleted.
- **`Filesystem`** moves to lib/fs.mn (N1).
- **lib/dsp/clock's one use** is `report(EReplayExhausted(span_zero()))`.
  Replay exhaustion becomes an abandoning op of clock's own effect, which the
  program's handler answers through AN-2's unwind. `EReplayExhausted` leaves
  DiagKind.
- **lib/search.mn, effect `Abort` and handler `catch_abort`** are one dead
  subsystem across three modules. Every reference to `catch_abort` and `abort`
  lies inside lib/search, which reaches the compiler's link only through
  lower.mn's unreferenced `import search`. All of it is deleted, and SYNTAX's
  "early exit is via `Abort`" sentence is trued: early exit is an abandoning
  arm (AN-2). The user's TIME library is AU6's, written fresh with no compiler
  edge. The fixtures that name the subsystem are found first with
  `mentl query tests "refs of catch_abort"`, and each either declares its own
  effect or is deleted with it.
- **lib/combinators.mn** is deleted. It holds six stubs that return constants
  while their names claim verdicts, plus a second `map` and `filter`.

*What it buys, measured by the lens on a shared machine.* Pulse's link loses
src/types.mn (5,384 lines). A lesson's judgment should fall from about 51 MB
toward the 39 MB of a module with no types edge.

*Gate.* E_LayerInversion's census of lib→src edges, seen RED at the measured 6
(8 counting combinators), then 0.

**M4 · Direct visibility, migrated by the medium.** The lookup filter reads the
direct edges; `E_MissingImport` becomes "visible only through a conduit", and
the gradient PROPOSES the edge at the reference — one module declares the name:
fill (accept writes the import); several do: the computed question ("`count` is
declared by lists and by main; which?"), answered the way SYNTAX §Imports
answers a collision — at the import edge, never at the call: the selective set
narrows so each name binds one edge (`import lists {map, filter}`), and the
graph refuses two edges into one name (`E_ImportNameCollision`, BORN armed —
SYNTAX's table names it and the wheel has never declared it, N5). A
dotted `lists.count` at the call is the residue SYNTAX names (a re-resolution by
name at every site) and the formatter rewrites, never the answer. That needs the
selective form to exist, and it does not today: `parse_import`
(src/parser.mn:1642–1651) reads the path and stops, and `ImportStmt` carries
one field (`mentl query src/main.mn "variants Stmt"`: `ImportStmt/1`), so
SYNTAX's `import path {a, b}` is unparsed — what its braces become after the
path is the first probe. `ImportStmt(path, Option([String]))`, the import scan
(`import_edges`, parser:1672) reading the set, and the visibility mask honoring
it land here. The migration is authored, not hand-made: `mentl tighten` writes
each module's import block as the set of modules its references resolve into —
a meaning-preserving rewrite by construction, because each added edge is the
resolution the closure already made.

Four link-wide collision refusals become one edge-local refusal (MOD-16):
`E_FnShadowsOp`, `E_OpShadowsOp`, `E_DuplicateFnName` and
`E_DuplicateTypeName`.
- Each narrows to one module's scope, or retires into `E_ImportNameCollision`.
- `E_OpShadowsOp`'s own message describes the defect: "the env holds one
  entry per name, so the second declaration REPLACES the first … the errors
  surface … inside the library, at spans your program never wrote".
- With names scoped, prefixes are a tax with nothing to pay for. lib/strings
  carries 64 of 100 declarations under `str_`, `float_` and `set_`; lib/json
  has 13 `json_`; Filesystem's ops carry `fs_`. `mentl tighten` drops each
  prefix where the module now qualifies the name, and its census of prefixed
  declarations ratchets down.
- WASI's op names (`fd_write`) stay: they are the host ABI's own names, not
  prefixes.

**M5 · A symbol is the declaration's.** Lowering and emit read the symbol off
the declaration the reference links to (`$module.name`, the nested-fn path
symbols already `.`-joined), and the bare-name indexes are deleted
(`fanout_decls_index`, the emit's function index). TRANSITION repin.

**M6 · The import block is maintained by the medium.**
- fmt dedups and orders it (§2).
- tighten removes DEAD edges (no resolution changes) and writes conduit edges
  as direct imports. A dead edge is narrated (`T_DeadImport`, MachineApplicable),
  never refused: an import added a moment before its first use is a normal
  state of an edit.
- The gradient proposes a missing edge at the reference.
- `mentl doc` shows each module's resolution edges.

**Why the block stays in the text, decided against the syntax lens's R3.** R3
would make the import block a pure projection that fmt writes from the
reference edges. Three facts keep the import line in the text:
- **Visibility.** Under M4 the import line is the SCOPE: what this module
  decided to see. It is the dependency surface a reviewer reads and the cut
  line the Severance Map draws. That is a decision, the way a negation is one
  under A4.
- **Layering.** fmt is a parse, and the edges a module's references reach
  exist only after the judgment.
- **Resolution.** A purely projected block would need every name resolved
  project-wide, which is the one namespace M4 retires.

So the medium MAINTAINS the line: it proposes a missing edge, deletes a dead
one and dedups. What crosses each edge is a projection (M2's facet, `doc`),
never written into the text. The one authored narrowing is a selective set
that settles a collision.

**M7 · Prose edges resolve in the same scope (#188).**
- `crc_resolve`'s hit test asks the one visibility function: the conjunct the
  lazy path already asks, in one home.
- The per-module census (139) is swept. Each reference is re-pointed at what
  its module sees, or written as prose.
- The bound moves from verify.sh's stderr grep into `src/board.mn` as a census
  shape.
- The page's lesson Lens stops carrying types.mn's narrations, because lib no
  longer links types.mn.

The census's three classes, measured with each module judged as its own entry
(MOD-12, SA-11):
- upward references against the import DAG, the largest class;
- names that exist nowhere: `Positive` ×7, `Hz` ×3, `IO`,
  `wasi_snapshot_preview1`, `call_indirect` ×2, `return_call`, `__init_lets` ×2,
  `LHandleWith`, `ev_declaring_node`, `world_push`;
- ordinary words in backticks: `f`, `g`, `acc`, `dst`, `next`, `text` and more.

A WAT, WASI or SMT word resolves against the vocabulary that declares it (the
emitter's instruction ADT), or it is written as prose.

The narration itself is trued:
- It names the declaration that owns a node, never `node 6118`.
- It reports each (comment, name) pair once.
- `where <module>` stops printing the narrow-link warnings ahead of its
  answer. Today that is 34 lines before a 10-line answer for types.mn.

**M9 · One link model, read from the DAG** (MOD-4;
`Hβ.driver.link-is-reachability`, an orphan until now).

*Today three link models judge three different wheels.*
- **The march's wheel** is a blob. tools/march.sh, lines 240–241, concatenates
  `find lib -name '*.mn' -not -path '*/tutorial/*' | sort` and then
  `find src … | sort`; tools/wt-env.sh's `wt_wheel` does the same. That is
  every lib module, lib first.
- **`mentl compile src/main.mn`** weaves src/main.mn's import DAG, src first
  (`driver_canonical_order`). That function's comment claims the two paths
  "read one input".
- **The battery's run contract** joins a hand-listed four-file prefix that
  leaves out threading.

*The cost of three models.*
- The blob judges lib/combinators, lib/audio/wav and lib/ml/grad, which the
  DAG never links.
- PLAN's record of the refused single-pass cut lists five lib/combinators
  functions among its 13 unresolved gates. Dead library code shaped a
  landing's census.

*The form.*
- Every compile is the import DAG from an entry plus the prelude edge. That
  covers the fixed point, `mentl compile`, a battery fixture and a lesson on
  the page.
- The DAG is woven in topological order, with each cycle judged as one binding
  group, which is already how `rederive_cone` judges the session's cone.
- The march judges src/main.mn's DAG.
- What the medium ships is a list of library roots, each judged by the board
  as its own entry. These are never imports inside the compiler's entry, so
  main.mn's "shipped surface" imports delete (dsp/feedback, dsp/signal,
  dsp/spectral, ml/tensor, math).
- A run fixture compiles from its module path, as a propose fixture already
  does.

*What deletes.*
- the blob assembly in march.sh and wt-env.sh;
- `driver_canonical_order`, with its order key and insertion sort;
- `battery_libs`' text prefix;
- the three `tutorial` exclusions.

Lib-before-src then falls out of M3's layering, never out of
`str_contains(p, "src/")`.

*Gate.* The march's verb-parity leg compares the module set the fixed point
judges with `mentl query src/main.mn modules`, and refuses any difference.
The boot's input changes, so this is a TRANSITION repin.

**M10 · The medium's vocabulary is held by declaration, never by spelling**
(MOD-7, MOD-6).

*Today the compiler recognizes library effects by their spelling.*
- 10 `"Alloc"` literals sit in 7 modules.
- `projection_of_effects` reads Thread, Simd, Gpu, Persist, Derivative and
  Alloc by name.
- `medium_vocabulary` and the severance labels give `IO` and `Network`
  meaning, though no compiler-linked module declares either.
- So a user's own `effect Thread` gets the schedule's reading. effects.mn
  presents that as a feature; under modules-as-scopes it is a different
  effect wearing the same name.

*The form.*
- The vocabulary is a set of declarations in ONE ambient substrate module.
  They are resolved to handles once, when the prelude edge is drawn, and every
  compiler reader holds the handle.
- A projection class is a fact of the effect's declaration, by identity.
- An intrinsic (`float_of_int`) is a declaration with an intrinsic body in
  that module, so every name a program can say has a home `where` can address.
  Today `where` prints `float_of_int(_)` with no address.

*Gates.*
- A census of string literals in src that spell an effect, held at 0.
- A frontier fixture declaring its own `effect Thread` runs as an ordinary
  dispatch. It is RED today.

**M11 · An effect nothing performs is deleted, and so is an install that
absorbs nothing** (MOD-9).

*Measured with `mentl query src/main.mn performs`.*
- Of 86 effects, 20 have unperformed ops.
- Seven have no performed op at all: Interrogate, Clock, Sample, IterContext,
  Network, Distort and Choice.
- `no_iter_context` is installed seven times on the compiler's routes over an
  effect nothing performs. Its own comment says it is read "by nothing today".
  It keeps main.mn's and pipeline.mn's `import dsp/clock` alive.

*The form.*
- An install whose extent performs nothing it absorbs is narrated
  (`T_InstallAbsorbsNothing`, MachineApplicable), and tighten deletes it.
- An op no site performs is deleted with its arms, and an effect left with no
  ops is deleted whole. Since L5, every handler of an effect answers every op,
  so a dead op is dead code twice: in the declaration and in each arm.
- The `performs` facet becomes a board bound: no NONE row among src-declared
  effects, and PART rows ratcheting down.

**M12 · A module is a capability unit, and the split is read from the graph**
(MOD-11).

*Measured.*
- Four modules hold 53% of src: infer 13,629 lines, backends/wasm 11,321,
  lower 8,411, types 5,384.
- infer.mn hosts at least ten subsystems.
- lib/strings hides five subsystems behind prefixes.

*The form.*
- A `clusters` facet partitions a module's declarations into its disconnected
  reference clusters, read over M1's links.
- A module with k clusters is narrated as k modules.
- The split is a medium-authored move (the rename verb's sibling, through the
  formatter, conservation-checked).
- The first consumers are lib/strings → strings / number / set, and src/types
  → the metaschema / the diagnostics / the view. infer, wasm and lower follow
  in the facet's order, each a landing of its own.
- Modules as scopes (M4) make each prefix the new module's name.
- The Severance Map's bands then sever something (L-E).

**M8 · Nothing is collapsed, because nothing is noise.** The page's Lens hides
every diagnostic from a module other than the caret's behind "N reports in
linked modules" (ide/index.html:500–515), and its own comment confesses the
reason: "a library's comment citing a name this link never reaches … not this
developer's line to fix". That collapse compensates for noise M1 and M5 delete:
a library is judged clean at its own boundary, held there by a board bound
(every lib module checked as its own entry at zero diagnostics, the per-module
census of M5 extended to every class), so a library produces nothing in a
user's link. What remains in another module is the developer's own — a
project's sibling module (`examples/wasatch/scene.mn` beside `main.mn`) — and
it is shown whole at its site, ranked after the caret's module, as the wheel
already ranks it. The `<details>` group, the `linked` filter and the
"linked modules" subtitle delete; the twin gains a leg asserting that a
two-module project with an error in the sibling paints that error in full
(RED on the current page, which collapses it).

**Arena:** each module's judgment groups already run in arenas; tighten's
per-module rewrite and the facet's walk each run in one.

**Gates.** Each is seen RED first.
- **M1's link.**
  - `refs of` a declaration that shares its name with one in another module
    answers only its own references. It is RED today, because the refs column
    is keyed by name.
  - An effect name in a row that resolves to nothing refuses. It is RED today:
    lib/persist.mn's `!Network` is silent.
- **M2's facet.** The canon edges read `used`, not `DEAD`, and infer's repeated
  edges read `DUPLICATE`. The egraph-audit prediction (three foreign
  obligations charged to `apply_rules_from`) answers zero.
- **The lib→src bound**, E_LayerInversion's census. It is seen RED at the
  measured 6 (8 counting combinators), then held at 0.
- **The facet-agreement bound** (M2), born at 5.
- **M9's module-set parity leg.**
- **M10's own-`effect Thread` fixture.**
- **M11's `performs` bound.**
- **The `count` program.** A user program declaring `count` beside an
  `import lists` compiles. It is RED on the boot with `E_DuplicateFnName`.
- **A two-module collision** answers the computed question.
- **The comment-ref bound**, at its measured count, then 0.
- **The release gate.** Board, march and a TRANSITION repin for M1, M5 and M9.

## 5 · The audit — the lenses' answers, and what each becomes

No refuter ran (context item 10). Every lens answered from the medium's own
verbs, and §0.1 commits those answers verbatim under `docs/record/2026-10-06/`:
each finding's claim, sites, current and ideal form, governing law, evidence,
the commands that measured it, and the gate. This section records what each
finding becomes: a landing, a board bound, or a §0.3 edit.

Reported:
- the five peer parts (463 verdicts);
- verbs: 11 findings, 6 root designs, 9 verb gaps;
- proposals: 13 findings, 6 root designs, 8 verb gaps;
- multi-shot: 13 findings, 5 root designs, 8 verb gaps;
- threads: 16 findings, 5 root designs, 5 verb gaps;
- syntax: 15 findings, 7 root designs, 12 verb gaps;
- modules: 16 findings, 5 root designs, 13 verb gaps.

All seven lenses have reported. The workflow that ran syntax was stopped once
it had answered; its last live agent was a duplicate of the threads lens.

**Finding IDs carry their lens's prefix:** VERB-n, PR-n, MS-n, TH-n, SA-n and
MOD-n. LEDGER already uses S1–S6, P1, A1–A7 and T_ for landings and
diagnostics, and §4 uses M1–M12 for its landings. The modules lens numbered its
findings M1–M16, so without the prefix "M3" would point at two different
things.

### 5.0 · Where independent lenses measured the same thing

When several lenses measure the same thing independently, that is the
strongest signal the audit has.

1. **The iteration costume has no gate.**
   - **Lenses:** VERB-1, PR-6, MS-11, peers part 5.
   - **Measured:** 490 index-threaded self-calls on the link (396 in src, 94 in
     lib). There were 390 when the tier was born on 2026-07-30. src/board.mn
     carries no bound on them, and RESIDUE's "the tier's count the ratchet" is
     false.
   - **Landing:** G2.
2. **Early exit cannot be expressed.**
   - **Lenses:** VERB-3, MS-10.
   - **Measured:** the prelude's any, all, find and take resume on every
     element. The resume grade joins RNone with RTail, so an arm that stops on
     one path cannot be said at all. Twelve first-hit walks are hand-rolled
     because of it, and `any` disagrees with the language's own short-circuiting
     `||`.
   - **Landing:** V1.
3. **The board bounds shapes, never answers.**
   - **Lenses:** PR-13, VERB-1.
   - **Measured:** open proof obligations rose 37 → 39 across L-C and nothing
     refused it.
   - **Landing:** G2.
4. **Cycles are hand recursion.**
   - **Lenses:** VERB-6, MS-9.
   - **Measured:** `escaping_fixpoint` answers its 32nd round as though it were
     the fixpoint. The event loop exists twice. The wheel's one `<~` is the
     feed-forward form and never loops. Monotone fixpoints re-derive every round.
   - **Landing:** V3.
5. **A position compared without its module.**
   - **Lenses:** PR-1, MOD-1, this session's import facet.
   - **Measured:** six sites (`refs_inside`, `ref_is_outside`, `decl_names_of`,
     `import_is_used`, `module_tail_eq` and `audit_walk`) compare a span or a
     name without its module. Audit attribution, `imports`, `unreferenced` and
     the pending tier all read through them.
   - **Landing:** M1 (item 13) and M2.
6. **Prose asserting machinery that is not there.**
   - **Lenses:** MS-7, PR-9, TH-5, TH-12, SA-5, MOD-13, peers parts 3–5.
   - **Measured by the syntax and modules lenses:**
     - 516 decorated, archaeological or lifecycle comments.
     - 32 `walkthrough`, 34 `.mn:` and 53 `commit` cells.
     - Module headers that contradict their own code. pipeline.mn claims to
       own `lookup_ty_graph`, which graph.mn declares. io.mn cites
       `std/compiler/types.mn` directly above its own `effect WASI`. math.mn
       says every float op routes through `float_add`, while its bodies use
       the native operators.
     - `LHandleWith` is cited as a desugaring target; no such constructor
       exists.
   - **How they fall:** G2 installs prose-census bounds by CLASS at their
     measured counts, and each falls as the module carrying it is touched.
     F strips the 372 banners, and AU2 rewrites coordinates into declaration
     names.
   - **Measured:**
     - The deleted trial/final pass is described as present in 7 of the 9
       "trial" comments read.
     - The synth header claims MultiShot.
     - `src/oracle.mn` is cited, and it does not exist.
     - 34 comments cite a `.mn:` coordinate.
     - The narrowing comments are refuted by the walk's own row
       (`infer_refinement_narrowing … with Memory + Alloc … -> ()`, so it
       writes nothing).
   - **Landing:** §0.3's sweep, plus G2's prose-coordinate bound.
7. **Effect-op parameters without names.**
   - **Lenses:** SA-1, the proposals verb gap.
   - **Measured:** 455 of 457 op parameters, across 91 effects and 416 ops,
     have no name (src/types.mn 200, lib 121, the rest of src 134). The names
     exist already: in the provider arms' binders, and in `//` comments above
     the WASI and SharedMemory ops.
   - **Landing:** N1.
8. **Duplicate and dead imports, and a facet that is wrong both ways.**
   - **Lenses:** MOD-1, MOD-2, SA-3, PR-11, this session.
   - **Measured:**
     - infer imports io and verify twice each.
     - Both DEAD verdicts are false.
     - At least 10 "used" verdicts are false.
     - Six comparison sites share one shape: a span or a name compared
       without its module.
   - **Landing:** F and M2.
9. **A cursor is an arena with an overlay.**
   - **Lenses:** MS-2 ("one extent, three faces": the arena's heap face plus
     the graph-trail and world faces) and TH-5 ("a cursor is an arena with an
     overlay": writes and mints land in the segment, rollback is its exit,
     commit an ordered publication). The two lenses arrived at one design
     without seeing each other's work.
   - **Measured:** 12 speculation brackets are assembled by hand in 5 modules.
     The graph has one cursor, one trail and one mint counter, so two threads
     interleave on it.
   - **Landing:** AU4. Parallel judgment levels, the battery that judges its
     library once and a threaded ??-fan (SPACE.2) all stand on it.
10. **Projections write.**
    - **Lenses:** MS-4, TH-11.
    - **Measured:** `where` binds every free type variable in the graph in
      order to name it, then rolls back. It does this inside four brackets,
      under a handler documented as read-only. Two concurrent readers of one
      resident session would interleave trail writes.
    - **Landing:** T6.
11. **A comment forces index loops, citing a gap the frame fence closed.**
    - **Lenses:** VERB-7, TH-9.
    - **Measured:** `classify_grade_all`'s "the perform resolves to the
      enclosing frame's `__hstate`" contradicts lower.mn:170–185's fence and
      its own comment ("the each-with-effects lambda gap is the same hole").
    - **Landing:** V4. One micro, run first, settles it.
12. **Pulse never fans out.**
    - **Lenses:** VERB-4, TH-13.
    - **Measured:** the wheel's whole link has 1 `><` (lib/dsp/feedback.mn:99,
      which Pulse does not call) and 2 `<|`. Pulse's three stereo pairs are lets.
    - **Landings:** V2 for the cost of a fanout; SPACE.1 for the arenas a
      spawning module loses.
13. **An effect name in a row resolves to nothing, and nothing says so.**
    - **Lenses:** MOD-6, this session.
    - **Measured:**
      - `!Network` in lib/persist.mn and in lesson 04 both check clean.
      - `mentl where lib/persist.mn Network` answers "not found" and exits 0.
      - `IO` has meaning at three compiler sites, and no module declares it.
    - **Landings:** M1 refuses the unresolved name; M10 holds the vocabulary
      by declaration.
14. **The Stage Law is inverted in the library, the prelude and SYNTAX.**
    - **Lenses:** VERB-5, SA-4.
    - **Measured:**
      - `x |> gain(0.8)` fills `x`.
      - `-2.0 |> clip(0.5)` derives -2.0 where -0.5 is meant.
      - feedback.mn needs a wrapper lambda.
      - The prelude's `reduce`, `scanl`, `nth` and `clamp` take the datum
        first, and so do SYNTAX's own clamp examples.
    - **Landing:** AU2.
15. **Section banners serve as ledes.**
    - **Lenses:** PR-10, SA-11, MOD-14.
    - **Measured:**
      - 372 comments carry `───`.
      - 22 of the ledes in three lib doc answers are banners.
      - json_serialize's lede names `reverse_list`, which no longer exists.
      - Drift row 131 matches the double rule (U+2550), while every banner is
        drawn with the single rule (U+2500).
    - **Landings:** T5 (lede and module-lede); F strips decoration; G2 replaces
      the drift row.
16. **The course has two homes and teaches what the medium refuted.**
    - **Lenses:** MOD-15, SA-8.
    - **Measured:**
      - Lesson 04 says `Pure` unlocks memoization, compile-time evaluation and
        parallelism. D4 deleted all three as things the medium never does.
      - Lesson 01 says `int_to_str` comes from io; it is declared in strings.
      - Pulse's prose spells literals the formatter rewrote.
    - **Landing:** §6.
17. **A gate scoped to less than its claim.**
    - **Lenses:** SA-13, MOD-4, MOD-12.
    - **Measured:**
      - `mentl check src/main.mn` reports main.mn alone, so eight refuted
        `own` markers never reached the board.
      - The fixed point judges a blob that `mentl compile` never weaves.
      - Comment references are judged on the flattened link.
    - **Landings:** G2 (the project is the unit of every gate), M9, M7.
18. **The Filesystem capability is bypassed.**
    - **Lenses:** MOD-5, this session.
    - **Measured:**
      - `fs_read_file_impl` has 7 callers outside its handler.
      - `fs_list_dir_impl` has 4 calls, for an op the effect never declared.
      - The declaration, the handler and the implementation live in three
        modules.
    - **Landings:** N1 and N3. The capability becomes one module whose arms
      are the implementation.
19. **An effect's name lies about what its ops do.**
    - **Lenses:** SA-12, the modules notes.
    - **Measured:**
      - GraphRead holds `graph_push_checkpoint` and
        `graph_attach_comment_ref`, both of which write.
      - GraphWrite holds `graph_install_at` and `graph_product_at`, both of
        which read.
      - Memory holds pure word arithmetic.
    - **Landing:** EFF.

### 5.1 · The peers, re-grounded: 463 verdicts over RESIDUE's 15,958 lines, all applied at §0.3

| Part | Lines | Still true | Closed, marked correctly | Closed, NOT marked | Stale | Design superseded |
|---|---|---|---|---|---|---|
| 1 | 1–3199 | 60 | 30 | 7 | 6 | 6 |
| 2 | 3200–6700 | 41 | 37 | 4 | 9 | 4 |
| 3 | 6701–9599 | 37 | 46 | 3 | 10 | 4 |
| 4 | 9600–12863 | 21 | 34 | 8 | 19 | 4 |
| 5 | 12864–15958 | 13 | 21 | 23 | 7 | 9 |
| **all** | | **172** | **168** | **45** | **51** | **27** |

**What each class becomes at §0.3.**

**Closed but not marked (45): each is marked CLOSED with the pin that closed it.**
- determinism-is-never-probed: 99c0c663; the stamp holds c8ba5799.
- class-bounds-stop-at-the-judgment: R0″.
- one-walk-three-implementations: f862677e.
- return-position-fn-row-is-a-var: armed since 2026-09-25.
- arm-wide-arg-face: L3 + R0j.
- trail-segment-discarded-at-rollback: C6.
- as-pattern-defeats-exhaustiveness: #126.
- record-pattern-unprovable-floor and field-offset-floor-is-never-reported: R0d/R0″.
- effect-mismatch-arming-blocked-by-the-surface: A1/A4.
- authoring-verb-writes-only-proven: a frontier leg since 2026-07-23.
- multishot-float-answer-redrive: AN-1.
- state-init-config-ref-nested: R0c.
- negative-stance-under-mixed-gate: 2026-08-01; its unregistered fixture rotted at #129.
- total-monomorphization, twin-state-width: 2026-08-07.
- continuation-callboundary-bubble, multishot-reyield-composition, multishot-arm-state-commit: band B and S2.
- interp-desugars-to-program.
- branch-spawned-verb-tagged: D5.
- The one-pass family, closed 2026-09-17: round-oscillation-movers, live-cells-need-one-settled-signature, movers-is-the-wrong-ratchet, order-independent-verdicts.
- module-blind-parse: 09-07.
- comment-prose-search: 10-03.
- type-decl-name-registry, nested-alternative-branch-bracketing, list-index-bounds-check, verify-after-apply, ctor-record-construction-unify, transport-runs-frontend, render-totality-before-fmt, compose-width-floor (AN-1's lane), fork-dead-code, float-evidence-ft, partial-via-lambda-recipe and partial-prefix-arity (R0g), int-splice-empty, callsite-result-width, an-arms-report-escapes-an-inner-capture.
- decl-site-file-coordinates: its remainder rides #108.

**Stale descriptions (51): each is trued in place to what the artifact does
now.** The most consequential:
- tools.consult-before-write says RESOLVED, but `tools/consult-gate.sh` is wired
  by nothing.
- green-stamp-under-included-three-batteries has recurred: `wt_state_key`
  misses tests/lens/negation.
- seq-element-stride-carrier landed in July, while PLAN 5.4 still calls it the
  open keystone.
- arm-states-its-meaning is one line now: `resume(tangent_of(v, w))`.
- allocation-census-is-the-emission-itself is unblocked by the arena.
- stage-law-and-reachability: nine violations remain, not ten.
- schemes-are-edges is two entries for one peer; they merge, and their tower
  vocabulary is history.

**Designs superseded (27): each gets the better form the artifact now
allows.**
- per-module-env-overlay → resolution through the module node's scope (M4).
- dcc-noninterference-gate → the sink precondition of Phase 7.
- voiceline-renders-to-nobody and situation-gradient-is-never-filled → project
  the View; delete the parallel homes.
- mutation-delta-is-write-only → the trail is the delta's home.
- a-handle-is-a-handle-at-its-source → Handle as its own type, on the `Addr`
  precedent.
- narrowing-write-requires-discharge → an index precondition decided from the
  path (TRAP, #109).
- multishot.handler-return-clause → deleted. `(f(body)) ~> h` is the same
  graph.
- syntax.open-row-tail → write no clause, or write the negation.
- yield-reachability-closure → op-granular reach plus the engine's exceptions.
- diverge-shared-memory-row → the race rule reads aliased writes.
- install-chain-as-value → merged into handler-chain-is-a-value.

**The classes across parts.**
- **Homeless peers** become §0.3 gates 1 and 2:
  - closures recorded in LEDGER but never written back;
  - orphan peers named only inside other entries (link-is-reachability,
    module-image-cache, held-resume-record-is-not-reclaimed,
    derivative-is-source, world-widening-resume,
    literal-intern-outside-the-vocabulary, seq-addr-downcast,
    seq-op-signature-driven, destructure-sites, warm-image-pending-suppression,
    carried-truth-projection, and the arena's derivative-loss class `LwArena`);
  - history blocks filed under the wrong entry (RESIDUE 9091–9211, 9376–9599,
    6945–7013).
- **Dead vocabulary in open entries** becomes §0.3 gate 3. It includes:
  - `heap_reset`, `$world_find`, `singleton_perform_block`;
  - the 1016 belts, `RowAssumed` / `absorb_into_residual`, `movers`;
  - `judge_window`, `branch_bracket`;
  - `T_*Unprovable` and their ratchets;
  - `effrow_writable`, `op_abi`, `Handler(F)`.
- **Two homes for one fact** go to the landing that deletes the second home:
  - may_yield_by asks both the escaping-row engine and the judged row (E1);
  - reachability is walked by name four times (M1);
  - verify and the e-graph each carry a constant folder (#109; TRAP measures the
    overflow hole they share);
  - the exit-code cap is enforced twice.
- **Gates that cannot fail on the gap they name** go to G2:
  - the LSP hover leg passes with no contents;
  - the lambda list-param leg gates `check` only;
  - the under-application leg accepts "loud at assemble";
  - the consult gate is inert;
  - `wt_state_key` under-includes a battery;
  - mn-mutual-negation-gate rotted;
  - mn-arm-wide-op-arg is unwired.
- **Wheel comments the verbs refute** are fixed in the landing that touches each
  module:
  - own.mn:252–256 cites a config parameter that does not exist;
  - lower.mn:305–312 lists built peers as floors;
  - lower.mn:426–430 names the deleted `$__fb_prev`;
  - cursor.mn:451–457 calls a `contains()` substring test a "structural
    projection";
  - is_builtin_effect still argues seed byte-parity, though the seed is
    deleted;
  - `emit_build_key`'s completeness claim is refuted by a recorded trap.
- **Docs that contradict code** are trued at §0.3:
  - SYNTAX and PLAN §7 describe T_RowInventory's open-row arm, which A3-pos
    deleted;
  - SYNTAX §`<~` sends a runtime depth through "view/slice work" and a
    "register file", but it is a ring with a cap word;
  - SYNTAX names W_CapabilityEmpty and W_EmptyRow for one narration that has
    neither;
  - PLAN §7 says module-of-a-span-is-containment "dies with the proximity
    rank", but it closed at D3.

### 5.2 · Verbs lens: the five verbs, and iteration as topology

Measured on the link:
- `|>` 473, `~>` 316, `<~` 9 (one of them in src, and that one never loops),
  `<|` 2, `><` 1.
- Pulse uses no `|>`, `<|` or `><` at all, and 17 `<~`. Its `render_frame` is
  31 `let`s.

The verbs are complete as topology. They are incomplete in practice at three
seams: fanout cost, the merge convention, and `<~` with no driver.

| ID | Finding | Becomes |
|---|---|---|
| VERB-1 | 490 costumes with no bound | G2 |
| VERB-2 | The detector convicts one spelling (`p + 1`). It misses decrement, rest-recursion, worklists, event loops and nested let-chains, and it convicts a display depth budget | AU1 |
| VERB-3 | The search vocabulary never stops | V1 |
| VERB-4 | `<|` and `><` cost an allocation their let-spelling does not, so under `!Alloc` they refuse. That makes the course's lessons 3 and 5 contradict each other | V2 |
| VERB-5 | The Stage Law is broken in lib/dsp and in nine prelude signatures: `sig \|> clip(0.9)` is `clip(0.9, sig)` today, a silent wrong | AU2 |
| VERB-6 | Every cycle is hand recursion | V3 |
| VERB-7 | Two comments forbid handler stages for a gap the medium closed | V4 |
| VERB-8 | Missing vocabulary breeds second homes: the line scan twice, `==` re-walked three times | AU3 |
| VERB-9 | The lexer and parser thread position by hand: skip_ws 209 refs, push_tok 20, push_node 23 | #108 (the parser is rewritten for cells anyway; a Scan handler, with the multi-shot re-parse as the TIME-axis payoff) |
| VERB-10 | 22 bracket thunks around handler chains | AU5 |
| VERB-11 | The prelude is written in the costume it exists to retire | AU3 |

The lens's nine verb gaps are grown in the landings that need them:
- census per-module rollups;
- missing shapes;
- a whole-link audit;
- `mentl query lib/dsp` refusing a directory;
- a handler arm's resume grade, never projected though SYNTAX promises the badge;
- rewrite verbs;
- the comment-ref narration that precedes every single-module answer.

### 5.3 · Proposals lens: the proposal, codegen and proof machinery turned on the wheel

Measured over six modules:
- 427 declarations taught.
- 367 of them got a row lock, ranked by how often the effect occurs.
- 59 got "no next-step annotation".
- None got a precondition, a return contract or a question, though those
  modules own 22 of the 39 open obligations.

| ID | Finding | Becomes |
|---|---|---|
| PR-1 | Containment by bare spans (the fourth machine of the "not module-qualified is not an address" class) | M1 item 13 |
| PR-2 | Guarded divisions are taught wrong. The path is never read. Both constant folders share the INT_MIN / −1 hole, and whether that hole traps the compiler is unmeasured | TRAP measures it and fixes it if real; #109 reads the path |
| PR-3 | Teach cannot name a refinement at a part, and 20 of the 39 obligations rest on one | T1 |
| PR-4 | The deliberate trap is invisible in the row, while the audit advertises "Total (proven never to trap)" over 14 unrowed trap sites | TRAP |
| PR-5 | Row locks are ranked by prevalence, never by dependents | T2 |
| PR-6 | 490 costumes, and no verb writes the fold | G2, AU2 |
| PR-7 | The proposer never offers a binder in scope, offers substrate internals first, and never builds a call with arguments | T3 |
| PR-8 | The smt facet renders the claim un-negated, with undeclared symbols, and its handler is dead | T4 |
| PR-9 | Comments assert architecture the rows refute and cite rotting coordinates | §0.3 sweep, G2 census |
| PR-10 | The Why at a declaration is a pass label ("ownership-resolved params of …" on all 21 egraph declarations); banner comments become ledes; the Query line is a sliced body | T5 |
| PR-11 | Duplicate imports | F |
| PR-12 | `unreferenced` lists Ty, Option and Alloc as dead | #108 (until then the facet answers "not measured" for those kinds) |
| PR-13 | Open debt has no bound | G2 |

### 5.4 · Multi-shot lens: the TIME axis

Measured:
- The wheel never performs a multi-shot op. `choose` has 0 references, and
  both of its handlers have 0 references.
- The TIME axis is hand-rolled: 12 `graph_push_checkpoint` calls, 15 rollbacks
  and 2 commits across 5 modules.

| ID | Finding | Becomes |
|---|---|---|
| MS-1 | The fixpoint oracle never exercises band B | a board FLOOR (at least one `->*` op in the emitted reach) once the fan performs `choose` (after #159) |
| MS-2 | Twelve hand brackets. The arena is the heap face of one extent whose trail and world faces are still bracketed by hand | AU4 |
| MS-3 | Mycroft's three rounds are a hand-unrolled search with four copies of the fallback (multi-shot is NOT its form) | AU4 |
| MS-4 | `where` writes the graph to render a type, under a handler documented as read-only | T6 |
| MS-5 | lib/combinators' `race` returns its first argument over constant stubs | AU6 |
| MS-6 | lib/search is welded to the compiler's trail and carries AN-1's refused shape | AU6 |
| MS-7 | Stale TIME prose | §0.3 |
| MS-8 | The ??-fan enumerates whole candidates then filters, under 13 installs each. Here multi-shot IS the form | after #159, as its first consumer; also needs ledger state in the trail and (arena, offset) handles |
| MS-9 | Monotone fixpoints re-derive every round | V3 |
| MS-10 | Early exit | V1 |
| MS-11 | The iteration bound | G2 |
| MS-12 | Trail ops split across GraphRead and GraphWrite; the checkpoint is an Int | AU4 |
| MS-13 | The TIME axis is untaught | the course's lesson 8 gains its second half after AU6 (§6) |

### 5.4b · Threads lens: the SPACE axis

The wheel is single-threaded by construction. Across a link of 53 modules,
79,003 lines and 366,285 nodes, the census finds one `><`, two `<|` and one
fanout, the ??-fan.

| ID | Finding | Becomes |
|---|---|---|
| TH-1 | Any spawn turns off every arena in the module: `arena_on` requires that the module never demand `spawn_task` (wasm.mn:2345). A spawning module then allocates through one cell guarded by compare-exchange. So the wheel's first threaded schedule would give up the self-compile peak the arenas bought (1,065,228 → 519,548 KB) | SPACE.1 |
| TH-2 | **The race rule counts only `resume … with` as writing a handler's state.** An arm's in-place `list_set` into a state buffer is a second writer: the judgment's age claim records it (infer.mn:4332–4334), and only the arena reads that record. By the rule's text, two branches bumping a counter kept in a state buffer pass. Unmeasured, because plan mode cannot write the crucible | RACE |
| TH-3 | **Every spawned instance re-runs the module's value-let initializers** (wasm.mn:6384–6385). An init that performs I/O runs once per branch, and a branch reads a fresh copy instead of the root's updated buffer, so Seq and threaded runs diverge | RACE |
| TH-4 | The sequence fanout spawns one host instance per element, and each one re-instantiates 7,351 data segments. A failed spawn traps | SPACE.2 (the schedule is a pool of K workers; a refused spawn runs inline) |
| TH-5 | The graph has one cursor, one trail and one mint counter, and 12 hand brackets | AU4 (convergence 9) |
| TH-6 | The judgment walks binding groups one at a time. The only level partition lives in `driver_check`, a second judge that labels every module `<stdin>` (still called by lsp:450 and voice:1414) | SPACE.2, standing on AU4; `driver_check` is deleted |
| TH-7 | Emission's comment says its records share no state; its 18-effect row and its registries (string_table, spec_registry writing from inside emission) say they do | SPACE.2: freeze the registries at the settle point; `emit_one_fn_to_string` becomes `!GraphWrite + !Diagnostic` and a fanout over records |
| TH-8 | The battery and `query_dir` re-judge the library for every fixture, and the only parallelism is bash | SPACE.2: judge the library once; each fixture is a segment over it (AU4) |
| TH-9 | The resume classifier's rounds are a `fanout` the race rule accepts today, written as an index loop under a refuted comment | V4 (convergence 11) |
| TH-10 | The ??-fan joins inside each branch; teach's three proof fans are filters | SPACE.2: branches return verdicts as values and the joins run in order after the fan |
| TH-11 | Read-only projections bind type variables in the graph | T6 (convergence 10) |
| TH-12 | Simd, Gpu and Persisted all run sequentially, while lower.mn:3452 says "All four backends are LIVE" | §0.3 trues the comment; SPACE.2 adds SPMD lowering gated by the row |
| TH-13 | Pulse and lib/dsp never write a fanout | V2 for cost, SPACE.2 for block-rate `><` (convergence 12) |
| TH-14 | The gradient never proposes a fanout | T8, `SuggestTopology`: the race rule is the proof gate, and `mentl accept` writes the `><` |
| TH-15 | A cold compile reads and lexes the module DAG twice (`driver_entry_scoped`, then `driver_tree_scan`) | SPACE.2: one walk, read twice; a cost line counts modules read |
| TH-16 | 8 of the 9 Phase 9.2 peers have no RESIDUE entry, and driver.mn:278 cites one that has none | §0.3, gate 1 |

The lens's stated order: the substrate and the gate first (TH-1, TH-2), then
the pool and module values (TH-4, TH-3), then the cursor (TH-5). The first
wheel phase to thread is emission, then the classifier rounds, then the
judgment's level sets (the largest win), then the battery, then the
user-facing surface. Each step is gated by m3 under Seq being byte-identical to
m3 under `parallel_compose`.

### 5.4c · Syntax lens: where the corpus departs from SYNTAX

The lens ran 119 `mentl` processes one at a time and read each answer whole.
Its summary: nearly every departure is one disease. A fact the graph already
holds (a name, a projection, an equivalence, a rule) is restated somewhere the
gates cannot see: a comment, a positional slot, a second renderer, or a
hand-kept line. The fixes are graph projections plus census bounds, and most of
them delete code.

| ID | Finding | Becomes |
|---|---|---|
| SA-1 | 455 of 457 effect-op parameters have no name; three homes paper over it (`op_scheme_param`'s `_0`, `render_op_param`'s `_` branch, an arity-only arm check) | N1, with the census born at 455 |
| SA-2 | `mentl fmt` is single-file and target-required; literals rendered by value (`48_000` → `48000`) | F |
| SA-3 | Duplicate imports reach no gate; the facet double-counts them; the multiset conservation census would refuse fmt's fix | F (a syntax error with fmt's fix; stated equivalences) and M2 |
| SA-4 | The Stage Law inverted in lib/dsp, in four prelude signatures and in SYNTAX's examples | AU2, with SYNTAX trued at §0.3 |
| SA-5 | 516 decorated, archaeological or lifecycle comments; 134 `drift-audit: ignore` markers silence a gate | G2 bounds and marker retirement; F strips decoration |
| SA-6 | The binder-lambda residue is wider than SYNTAX claims: partial-eta is uncounted, `(x) => x + 1` keeps its binder, `effectful-lambda` counts construction | F (sole-parameter binder → arm list), AU1 (`CsPartialEta`), AU2 (reference with a hole) |
| SA-7 | Four spellings of one head; row and type variables collide (`spawn(_: () -> a with a)`); SYNTAX contradicts itself on `-> ()` | N2's round trip; SYNTAX trued at §0.3 |
| SA-8 | The course seed, the library and SYNTAX's examples teach non-canonical forms; the ownership marker sits in two positions | §6 (fences as fixtures, examples on the board); one position at §0.3 and F |
| SA-9 | Positional products whose field meanings live in comments (VerbSpec, Graph, Region, the inference context's tuples, parallel lists) | `CsPositionalProduct` in G2; T3 proposes the record; AU2 writes it |
| SA-10 | Base-type pins justified by defects that have since closed; PLAN §9 still tells authors to add them | T9 (`T_TypeInventory`) and AU2; the PLAN §9 line trued at §0.3 |
| SA-11 | Ledes land on the wrong node; modules have no lede slot; comment edges judged on the narrow link with `node N` owners | T5 and M7 |
| SA-12 | Effect membership contradicts the effect names (reads in GraphWrite, writes in GraphRead, arithmetic in Memory) | EFF |
| SA-13 | Eight authored `own` markers the inference refutes, invisible from the entry's check | G2 (the project is the unit) |
| SA-14 | Unary minus spelled `0 - x`, including inside a refinement predicate | F for literal operands; T narrates and tighten rewrites a variable |
| SA-15 | Underscore-named parameters escape the underscore-retain census | AU1 |

**The lens's seven root designs, and where each lives:**

| Root design | Lives in |
|---|---|
| R1 · one parameter-product grammar for every head | N1, extended to constructors and multi-field results by `CsPositionalProduct` |
| R2 · fmt is the project's canonical projection | F |
| R3 · the import block as a projection | M6. It is reconciled, not adopted: the import line stays a decision the medium maintains, for the three reasons M6 gives |
| R4 · graph-changing rewrites are proposals, not formatting | AU2's list |
| R5 · one head projection with a round-trip gate | N2 |
| R6 · the comment paradigm made mechanical | G2, T5, M7 and F |
| R7 · the project is the unit of every gate | G2, §6 and M9 |

**Its twelve verb gaps:**

| Verb gap | Grown in |
|---|---|
| An effect roster with its op names | N2 |
| A listable census roster | G2 |
| The missing census shapes | G2 and AU1 |
| Underscore-retain over parameters | AU1 |
| Prose by token, not substring | G2 |
| `refs of` keyed by name | M1 |
| `imports` with no duplicate verdict | M2 |
| fmt's project mode | F |
| A project-wide check | G2 |
| `where`'s narrow-link noise | M7 |
| `doc` missing lets and rendering instance heads | N2 |
| Ledes cut at an abbreviation | T5 |

### 5.4d · Modules lens: the import graph and module structure

The lens made about 30 runs, one at a time, then checked every facet verdict
against whole-module reads, `refs of` edges and the per-module doc answers. Its
headline: every module-structure facet, and audit, compares spans with no module
identity. Three link models judge three different wheels. The compiler's
metaschema sits in every user program. One root design dissolves most of it.

| ID | Finding | Becomes |
|---|---|---|
| MOD-1 | The facets that judge module structure compare spans with no module identity (six sites). Both DEAD verdicts are false, and at least 10 "used" verdicts are false | M1 and M2, with the facet-agreement bound born at 5 |
| MOD-2 | Dead, duplicate and "shipped surface" edges, each posing as necessary because imports are transitive; lesson 01 teaches a false provenance | M4 (non-transitive), M6, M9 |
| MOD-3 | The runtime imports the compiler (6 lib→src edges, 3 dead); src/types.mn rides into every user program; the resolver offers src/ to user imports | M3 (`E_LayerInversion`; the resolver stops) |
| MOD-4 | Three link models judge three wheels (the march's blob, the driver's DAG, the battery's prefix), under a false comment that they read one input | M9 |
| MOD-5 | Seven call sites bypass Filesystem; its declaration, handler and implementation live in three modules | N1 (lib/fs.mn, arms as the implementation) and N3 |
| MOD-6 | Effect names in rows are never resolved (`!Network` in persist and in lesson 04) | M1 |
| MOD-7 | Library effects recognized by spelling; a user's same-named effect inherits a projection; intrinsics have no home | M10 |
| MOD-8 | lib/search, Abort and catch_abort: one dead subsystem across three modules | M3 deletes it; AU6 writes the user's TIME library fresh |
| MOD-9 | 20 effects with unperformed ops (7 with none); `no_iter_context` installed seven times; the compiler imports dsp/clock for it | M11 |
| MOD-10 | lib/combinators: six fabricated verdicts and a second map/filter, judged by the fixed point | M3 (deleted) and M9 (out of the fixed point) |
| MOD-11 | Four modules hold 53% of src; lib/strings is five subsystems behind prefixes | M12 |
| MOD-12 | 139 comment references resolve nowhere, judged per module, in three classes | M7 |
| MOD-13 | Prose cites deleted files, line numbers, commits and walkthroughs, and contradicts its own code | G2's prose bounds; AU2's coordinate rewrite; each module trued on touch |
| MOD-14 | Banners and module notes become the ledes of unrelated declarations; drift row 131 matches the wrong glyph; row 128 polices a dissolved form | T5 (module lede), F (decoration), G2 (rows replaced by a census shape) |
| MOD-15 | The course has two homes, lives in the runtime library, and teaches refuted claims | §6 |
| MOD-16 | No selective import and no edge-local collision, so the link is one namespace, refused four ways and paid for in prefixes | M4 |

**Its five root designs:**

| Root design | Lives in |
|---|---|
| Modules are scopes, with non-transitive, name-carrying edges | M1, M4, M6 |
| Layer is a fact of the module node | M3 |
| One link model read from the DAG | M9 |
| A capability is one module: the effect, its handler, and its implementation as the arms | N1, M11, M12 |
| Prose names declarations, never places | G2, AU2, T5, M7 |

**Its thirteen verb gaps:**

| Verb gap | Grown in |
|---|---|
| Per-edge crossing sets | M2 |
| `importers of` | M2 |
| Unresolved effect names | M1 |
| Prose by class | G2 |
| `clusters` | M12 |
| `ledes` | T5 |
| Types and effects in `unreferenced` and `performs` | #108 |
| `where`'s exit code | M2 |
| A duplicate-import census | F and M2 |
| The fixed point's module set | M9 |
| Names with no declaring module | M10 |
| Facet self-consistency | M2 |
| `doc`'s module header | T5 |

### 5.5 · The landings the audit adds (ordered in §7, homed in RESIDUE at §0.3)

**G2 · Every gate can fail, and the board bounds answers.** A wheel landing,
because src/board.mn moves.
- **A bound over any question.** The board bounds a located QUESTION, not only a
  census shape: `Bound({ceiling, question: Question})`. Each of these is a
  falling line, seen RED one below its ceiling:
  - open obligations: 39;
  - iteration costumes: 490;
  - prose coordinates: 34;
  - ghosts: 18,681.
  Dead imports are not bounded here. Both of today's DEAD verdicts are false
  (MOD-1), and a bound over a wrong answer is worse than none. They join at
  M2, once the facet is true; MOD-2 measured 10.
- **The project is the unit of every gate** (R7, SA-13).
  - `mentl check` with no target judges the project. `mentl check <entry>`
    reports every module of the link, each diagnostic once, at its own module.
  - The wheel's "zero diagnostics" is then measured over every module.
  - The eight `own` markers the inference refutes (graph ×6, infer, lexer)
    are fixed here: tighten deletes each or proposes `ref`.
  - From G2 on, §8's "`mentl check` at zero" means the project.
- **Prose is bounded by class, never by substring** (SA-5, MOD-13). The prose
  facet gains token-bounded forms. `V1` matches inside `RV128` today, and
  `used to` matches the purpose sense. It also gains these classes:
  - a path naming no file;
  - a `name.mn:N` citation;
  - a hex commit token;
  - a `spec NN` citation;
  - lifecycle words (`no longer`, `previously`, `Until 20`);
  - archaeology needles (`walkthrough`, `seed's`, `DELETED`);
  - box-drawing runs.
  Each is a bound at its measured count (516 comments in the union), falling
  as the module carrying it is touched.
- **A comment never silences a gate.** The 134 `drift-audit: ignore` markers
  are bounded. Each falls when the text row it mutes becomes a structural
  census shape: a string literal is `text`, and a one-shot `++` is not an
  accumulator. At zero, the marker's grammar deletes. Two drift rows retire
  into the banner census shape:
  - row 128, which polices `///`, a dissolved form;
  - row 131, which matches U+2550 while every banner is drawn with U+2500, so
    it cannot fail.
- **The census roster is listable.** `mentl query <entry> census` answers every
  shape with its count. Today it answers "unknown query".
- **The blind gates are made able to fail:**
  - the LSP hover leg asserts `"contents"`;
  - the lambda list-param leg runs the program (expects 7);
  - the under-application leg passes only on 42, and its fixture header is
    trued;
  - `wt_state_key` derives its battery set from the legs (one home);
  - the consult gate is wired as the Edit|Write PreToolUse hook, or retired by
    name;
  - mn-mutual-negation-gate is fixed and registered, or deleted;
  - mn-arm-wide-op-arg is registered.

**TRAP · Traps are in the row.** This preempts everything after it: §0's property
(2) is false at a shape every program writes.
- `out_of_range` is the one home of the deliberate trap, at 14 call sites. It
  answers `!` and charges `Trap`.
- An index, a slice and a byte read raise their precondition as C5's division
  does: `PInBounds(receiver, index)`, decided by the fragment from constants and
  from lengths read along edges. An open claim charges `Trap`.
- A capability label states exactly the absences it was proven from. "Total" is
  not claimed while divergence is unrowed, so `extract_chase`, which traps at
  depth > 1000 by its own comment, stops being called total.
- **The instrument first.** Run `fn main() = (0x80000000 / (0 - 1)) / 2`
  through `mentl check` and `mentl compile`. If a constant folder traps the
  compiler, the fix lands here: one folder that asks the claim it raises (PR-2's
  form).
- **Gates:**
  - crown `leak-index-trap` (`fn f(xs) with !Trap = xs[5]` refuses);
  - crown `sound-index-proven`;
  - the frontier asserts extract_chase's row carries Trap;
  - the fold fixture.
- **Fallout, taken honestly:** a `!Trap` over an index meets the truth, and
  #109's path read later proves the guarded ones.
- **Peers:** index-partiality-is-a-row-fact closes;
  divergence-is-a-row-fact stays named.

**RACE · The race rule reads every write, and a spawned instance shares the
module's values** (TH-2, TH-3). This preempts like TRAP: SYNTAX promises
"provably race-free".
- **The instruments first.** Both are RED-first fixtures, because plan mode
  could not write them.
  - The TH-2 crucible: `handler tally with buf = make_list(1) { bump() => {
    list_set(buf, 0, list_index(buf, 0) + 1); resume() } }`, with two branches
    bumping under `~> tally ~> parallel_compose`. It must refuse with
    `E_ThreadedBranchEffect` naming the in-place store. A control whose arms
    only read `buf` must still run.
  - The TH-3 pair: a module let whose init performs an op performs it exactly
    once under both schedules, and a module buffer the root updated before the
    fanout reads the same value in both branches.
- **The forms, if RED:**
  - "What an arm writes" is ONE published fact: the `resume … with` updates
    plus every store the age claim resolves to `TgState`. The arena and the race
    rule read it alike.
  - Under a spawning schedule, Memory's loads and stores are two effects (L5's
    lesson, `ResumeSummaries` against `ResumeSummariesWrite`).
  - A spawned instance takes the root's module-values record through the task
    record, beside the world, and never runs `$__init_lets`.

**EFF · An op lives in the effect its behaviour belongs to** (SA-12, plus
`Hβ.memory.word-arithmetic-is-memory`, which PLAN §7 names as the landing
after #129). A name that lies about an op makes `!E` a true statement about a
false vocabulary. This sits beside the soundness preemptions because §0's
property (2) is only as good as the effect names it is stated in.

*Writes are one published fact.* What an arm writes is the fact RACE
publishes: the `resume … with` updates, plus every store the age claim
resolves to `TgState`. Two shapes become a census row bounded at 0, read
through that fact and `provider of OP`:
- an op in a `*Write` effect whose providers never write;
- an op in a `*Read` effect whose providers write.

*The measured moves.*
- `graph_push_checkpoint` and `graph_attach_comment_ref` move into GraphWrite.
  A checkpoint changes how every later write behaves. AU4 later takes the
  trail ops off the program-facing surface altogether.
- `graph_install_at` and `graph_product_at` move into GraphRead.
- Before the move, `provider of` measures every handler that answers only one
  of the two effects. Each one either answers the moved op (by forwarding) or
  is split, as L5's exhaustiveness requires.

*Word arithmetic leaves Memory, in RESIDUE's two pins at the bootstrap seam.*
- The ops leaving are the bitwise ops (`i32_and`, `i32_or`, `i32_xor`,
  `i32_shl`), the address offsets (`addr_at`, `addr_diff`), `null_addr` and
  the two puns.
- First pin: the compiler registers them as primitives, as it registers
  `float_of_int`. The library's declarations shadow them, so nothing moves.
- Second pin: the library deletes those declarations.
- Afterwards, Memory holds the operations that read and write memory and
  nothing else. A function doing only word arithmetic is `Pure`, so
  `wav_data` regains the `with Pure` it lost at #129.
- The fixtures that compute on an address are found with the directory query
  `mentl query <dir> "refs of NAME"`.

*Also in this landing.* The deleted pass's vocabulary is renamed
(`trial_group_walk`, `trial_judge_group`).

*Gates.*
- The membership census at 0, seen RED at its measured count.
- A bit-arithmetic function declared `with Pure` runs. It is refused on the
  boot.
- A `!GraphWrite` function that pushes a checkpoint is refused.

**SPACE.1 · Instance segments: the arena's SPACE face** (TH-1;
`Hβ.arena.per-instance-regions`).
- The root hands each instance a segment with one atomic add per chunk, and the
  instance bumps privately inside it. An arena's region is then a span of its
  own instance's segment, so exit, evacuation and reset work as they do
  single-threaded.
- Deterministic chunk bases make addresses reproducible. A segment id is the
  arena half of 9.2's `{arena, offset}` handle.
- The `spawn_task` conjunct at wasm.mn:2345 is deleted. This lands before the
  course, because lesson 10 spawns and it must not give up its arenas.
- **Gates:**
  - spawning-module-runs-the-body asserts exits > 0 and the heap returning to
    its mark;
  - a contention micro prints its wall time beside Seq;
  - the self-compile peak ratchet holds.

**SPACE.2 · The SPACE axis: Phase 9.2, after the Space surfaces** (TH-4, TH-6,
TH-7, TH-8, TH-10, TH-12, TH-13, TH-15). Each step is gated by m3 under Seq
being byte-identical to m3 under `parallel_compose`, and the lens's order holds.
- **The schedule is a pool.** `parallel_compose(workers)` runs a fanout of N as
  K chunked worker loops, and a refused spawn runs inline.
- **Emission is a fanout over records.** The registries are frozen at the
  settle point first.
- **The classifier rounds are a fanout.** That is V4 (convergence 11).
- **The judgment's binding-group levels run as segments (AU4).** Commits happen
  in group order; `driver_check` and its `<stdin>` labels are deleted.
- **The battery judges its library once.** Each fixture is a segment over that
  one judgment.
- **The ??-fan returns verdicts as values.** The joins run in order after the
  fan.
- **SPMD for Simd, gated by the row.** Gpu stays named until a device exists.
- **Pulse renders by block,** with `><` under `parallel_compose`.
- **One DAG walk per cold compile.**
- **Peers:** the 8 Phase 9.2 peers that have no RESIDUE entry are given their
  designs at §0.3.

**T · The teaching compiler teaches what the program owes** (PR-3, PR-5,
PR-7, PR-8, PR-10, MS-4, TH-11, TH-14).
- **T1 · A refinement at a part.** `APart({site, path, alias})`: a claim's leaf
  is walked back through PartFact to its producer. The proposal is proven in
  D4's bracket with S4's cross_parts and ranked by the obligations it
  discharges program-wide. Gates: teach fixtures `part-return`, `part-option`
  and `part-field`, then G2's obligation bound falls.
- **T2 · A lock is taught only when something stands on it.** The dependents are
  read along reverse links (M1), and the answer names them. With no dependents
  there is no teaching. Gates: `lock-protects-a-caller` and
  `lock-nothing-depends`.
- **T3 · The proposer offers what is in scope.**
  - a Lexical ring read up the parent edge;
  - the Linked ring as a module's surface;
  - calls with argument holes;
  - a record for a positional product (SA-9), its field names taken from the
    adjacent comment and from the binders that destructure it at its use
    sites. `VerbSpec(String, String, …, String)` is the first subject.
  - Gate: string-value-tie's contract moves to filling `""`.
- **T4 · One obligation value.** `Obligation({node, pred, reason})`, with its
  hypotheses read from the ancestry and rendered once for the caret, teach,
  audit, the Ledger and smt.
  - smt asserts the negation with declarations;
  - `verify_smt` and `SmtSolver` are deleted;
  - `smt_cmp_op`'s wildcard is enumerated.
- **T5 · The Why at a declaration is its signature's.**
  - `Signature({params, ret, row})` replaces the pass label.
  - A `───` banner is never a lede, and fmt deletes it.
  - The Query line renders the formatter's head.
  - A module has a lede slot (SA-11, MOD-14). Prose before a module's first
    declaration, or set off from the next declaration by a blank line,
    attaches to the MODULE node, and `doc <module>` prints it first.
    - Today lib/threading's header becomes ThreadHandle's lede.
    - math's module note becomes ln2's lede.
    - json_serialize's lede names a `reverse_list` that no longer exists.
  - A field's doc attaches to the field name.
  - The lede is the first sentence, never cut at an abbreviation. Today
    `emit_binop_repr_unsupported` ends at "…repr (e.g.".
  - A `ledes` facet carries a banner test, and `CsMisattachedLede` bounds it.
- **T9 · A base-type pin equal to what inference derives is an inventory**
  (SA-10). This is A4's law (`T_RowInventory`) one sort over.
  - `T_TypeInventory` narrates an annotation whose removal, judged in D4's
    checkpoint bracket, leaves the same type. tighten writes the residue, and
    `CsTypeInventory` bounds it.
  - An annotation that pins what inference would leave generic is a decision,
    and it stays.
  - The written justifications cite defects that are closed:
    - make_echo's comment cites P0's spreading;
    - `fold_acc_eq` cites a peer R0 closed;
    - the `: String` pins cite the pointer-eq era, which E_ShapeUnprovable
      closed.
  - PLAN §9's bug-class line ("annotate the name param `: String`") is trued at
    §0.3, so it stops producing new pins.
- **T6 · Projections never write.** Naming free variables becomes a
  render-context read, `where`'s four rename brackets are deleted, and the
  projection family declares `!GraphWrite + !RowWrite`, armed.
- **T7 · The self-proposal benchmark.** At wheel argument positions, hole the
  argument and require the authored binder among the survivors. The hit rate
  ratchets upward from 0.
- **T8 · The gradient proposes topology** (TH-14). It proposes
  `SuggestTopology` when two lets share no data edge, their rows reach no
  handler that writes state (RACE's one fact), and they capture distinct
  records. The race rule is the proposal's proof gate, the schedule is proposed
  from measured cost, and `mentl accept` writes the `><`. Gates: teach
  fixtures `add ><` over a stereo pair, and `none` over a pair sharing a
  stateful handler.
- A guarded division is answered "none" until #109 reads the path, never with a
  wrong precondition. `%` and `/`'s zero face lean on the divisor alone.

**V · The verbs are whole** (VERB-3/4/6/7, MS-9, MS-10, TH-9, TH-13).
- **V1 · Early exit is a resume grade.**
  - `ResumeUse × MayAbandon`: an arm that resumes on one path and answers on
    another lowers the answering path through AN-2's unwind.
  - `any`, `all`, `find`, `take`, `position` and `fold_while` stop at the first
    hit. `any` is the fold of `||`, and `iterate` yields lazily.
  - Gates: `any` over five elements under a counting handler counts 3 (5
    today). A mixed-arm micro under `!Alloc` is the instrument for how such an
    arm lowers today, which is unmeasured.
- **V2 · A verb never costs more than its desugaring.**
  - Under Seq, a fanout's branch literals are applied in the frame (R0i's law,
    extended to branches). The tuple is a record only where it escapes.
  - A `<~` in a branch literal is a line of the enclosing record.
  - A fanout merges into an N-ary stage through the parameter-product calling
    convention.
  - Gates: `match (x + 1) >< (x + 2) { (a, b) => a * b }` under `!Alloc` grows
    the heap by 0. Pulse's `render_frame` and rooms, rewritten in the verbs,
    render a byte-identical WAV.
- **V3 · Every cycle has a driver.**
  - An input loop is a fold over an Iterate source, and quitting is the
    abandon. `mcp_loop` and `session_line_loop` become one, and
    `cursor_session` folds over the actions, closing
    `Hβ.felt.edit-session-reads-one-action`.
  - A fixpoint is a `<~` on a convergence clock that refuses rather than answer
    a non-fixpoint. `escaping_fixpoint`'s cap is made a loud
    `E_InternalInvariant` first, so the march says whether it was ever reached.
  - Monotone fixpoints iterate over the delta.
  - The per-tick clock rides `Hβ.dataflow.clock-calculus-sample-rate`, named.
- **V4 · Stages are handlers.**
  - List pipelines become `~>` stage chains that re-yield outward, giving one
    pass.
  - Deforestation becomes an Iterate-algebra e-graph rewrite.
  - The two forbidding comments are measured false and deleted.
  - Stands on V1.

**AU · The medium authors the migration** (VERB-1/2/5/8/10/11, PR-6,
MS-2/3/5/6/12, TH-5).
- **AU1 · The detector convicts facts.** The costume detector is re-founded on
  index flow: a parameter threaded ±k, through a rest binder or a worklist pop,
  that reaches an index read.
  - A depth budget is its own class.
  - New shapes: let-chains, nested-call pipes, `<|`/`><` invitations, repeated
    install suffixes, and pipe-fills-non-last.
  - G2's bound resets to the re-founded count and falls.
  - The syntax lens's shapes join the census (SA-6, SA-9, SA-10, SA-11,
    SA-14, SA-15):
    - `CsPartialEta`: a lambda whose body is one call using each parameter
      exactly once as a whole argument, i.e. a reference written as a mint.
      `lambda_is_eta` misses it today, e.g. `(row) => dot(row, x)`.
    - `CsPipeShim`: a pipe stage that is a lambda or carries an explicit `??`,
      the Stage Law's own signal.
    - `CsZeroMinus`.
    - `CsUnderscoreRetain` over parameters and pattern binders, not only lets.
      Today it misses `_ty` and `_i`.
    - `CsPositionalProduct`.
    - `CsTypeInventory`.
    - `CsMisattachedLede`.
  - `effectful-lambda` stops counting the construction charge. Since R0i every
    mint costs an allocation, so all of cli.mn's 20 constructors count as
    "effectful", and the shape measures nothing.
- **AU2 · Rewrites by edge, gated by the board.** One verb family with
  `mentl rename` (N1).
  - The Stage Law reorder is computed from the call products at every call.
  - The costume → vocabulary rewrites go by schema (early-exit loop →
    find/any/position; `acc ++ f(x)` → flat_map; range-index map → windows;
    pairwise equality → `==`).
  - Each is a form-space rewrite, accepted through `mentl accept` with no
    question asked, and checked by the conservation census.
  - Coordinate citations in prose are rewritten to backticked names.
  - The Stage Law's sites (VERB-5, SA-4):
    - lib/dsp's `gain`, `clip` and `mix`, and the filter stages, called
      `stage(x, cutoff)`;
    - the prelude's `reduce(xs, f)`, `scanl(xs, init, f)`, `nth(xs, n, default)`
      and `clamp(x, lo, hi)`;
    - cli.mn's `req_target(argv, mk, msg)`;
    - Pulse's `rig.*(signal, cutoff)` calls.
    `T_StageOrder` narrates a declaration whose pipe sites wrap or hole the same
    parameter. The reorder is proven by re-judging in D4's checkpoint bracket,
    with labeled calls left untouched. Afterwards `x |> dc |> lp(cutoff) |>
    soft_clip` needs no wrapper.
  - The rest of the syntax lens's R4 list, each narrated by teach and written by
    tighten or accept inside a re-judging bracket:
    - a partial-eta lambda becomes a reference with a hole (`dot(??, x)`,
      `req_target(??, VCheck, msg)`);
    - a multi-parameter lambda becomes a reference
      (`Hβ.syntax.multi-param-lambda-is-a-reference`);
    - a base-type inventory is removed (T9);
    - `0 - x` over an Int variable becomes `-x` (exact). Over a Float variable
      it is only narrated, because of the signed zero;
    - a positional product gets field names (T3 proposes them, from the
      adjacent comment and the binders that destructure it).
    Where two proposals tie, the medium asks the computed question.
- **AU3 · The vocabulary grows, and the prelude leaves the costume.**
  - New: position, take_while, drop_while, fold_while, windows, pairs, unzip,
    group_by, sort_by, unfold, fixpoint, and a line-offset projection.
  - The derived operations are rewritten over Iterate: intersperse, scanl,
    repeat, chunk, merge.
  - main and space carry one line scan between them, not two.
  - `cur == next` replaces three hand-written equality walks.
- **AU4 · One speculation extent: the cursor is an arena with an overlay**
  (convergence 9). It is also SPACE.2's parallel cursor: reads fall through to
  the base, and writes and mints land in the segment with `{segment, offset}`
  handles.
  - `(body) ~> speculate` is the arena's sibling, with the graph-trail and world
    faces. Its exit rewinds, restores and reclaims everything except what it
    publishes, and a commit exit keeps the segment.
  - The trail and world ops leave the program-facing surface, so the 12 hand
    brackets cannot be written. A GraphRead op that changes how every later
    write behaves stops existing.
  - Mycroft becomes two thunks under it, with a `<~` recheck run to agreement.
    That closes `Hβ.infer.mycroft-recheck-one-round-short`.
- **AU5 · Handler chains are values.** The 22 bracket thunks are deleted, and a
  repeated-suffix census is added.
- **AU6 · The user's TIME library.**
  - lib/search is made independent of the compiler: first, all, best, count,
    sample and persisted, in AN-1's answer shape.
  - lib/combinators is deleted. Its job is done by `verdict_of` / `VAsk`.
  - A per-branch-state fixture settles the semantics before any policy is
    written.

## 6 · The course is Pulse

MENTL_SPACE §5.5 already designs it: the course is a PROJECT the page opens, ten
lessons on one growing chain a new developer HEARS, each lesson's text the
program's own prose (comments are graph content; the Lede renders it) and its
exercise a hole the medium proves: (1) a sine through `|>`; (2) `<~` a filter;
(3) `<|` and `><` — a send bus and a stereo pair; (4) `~>` the effect rack; (5)
`!Alloc` on the per-sample path; (6) `Sample(48000)`; (7) `Hz` and `Sample`
refinements; (8) the hole and its computed question; (9) the effect that learns
(`~> grad(w)`); (10) voices `><` under `~> parallel_compose`. The landing writes
the ten lessons as `examples/pulse/course/01…10` (each a program `mentl run`
renders to a WAV today, each fmt-canonical at zero self-diagnostics, each with
a proposal-battery contract at its hole), points `ide/space.manifest` at the
course project, and DELETES lib/tutorial/ — its ten lessons are the text-first
stand-in §5.5 names, and keeping both is two homes for the course. Audio in the
page arrives with L-F (the worker instantiates the emitted bytes); W3 plays the
Wasatch symphony there.

Two lessons stand on open work and say so in their own prose until it lands:
lesson 6 refuses a 44.1 kHz stage through the negation on the render path
(`render_frame … with !Sample(44100)`, Pulse scene 1's form), because a handler
does not yet pin its instance — the install refusing a foreign rate is S1
(`Hβ.effects.handler-pins-its-instance`, banked), and the lesson's contract
moves to the install the day S1 lands. Lesson 10 spawns. SPACE.1 (instance
segments) lands before the course, so the lesson's arenas reclaim under
`parallel_compose` as they do sequentially. Without it, any spawn turns off
every arena in the module (TH-1).

**What the course stands on, as the audit measured it (§5).**
- **Lesson 1's `|>` needs the Stage Law in lib/dsp (AU2).** Today
  `sig |> gain(0.8)` fills gain's first parameter, which is correct only
  because multiplication commutes, and `sig |> clip(0.9)` is `clip(0.9, sig)`.
- **Lessons 3 and 5 contradict each other until V2.** A fanout allocates where
  its let-spelling does not, so `<|` and `><` refuse under lesson 5's `!Alloc`.
- **Lesson 10 needs SPACE.1 and RACE.**
- **Lesson 8 gains its second half after AU6 (MS-13).** The medium's search at
  a hole and the developer's own `choose` under `~> best(score)` are one
  primitive (§4④). The chain's voicing is chosen by the same machinery that
  proposed the lesson's fill, so the TIME axis is taught on the course's own
  chain rather than in an eleventh lesson.

The course therefore follows V2, AU2, AU6, SPACE.1 and RACE in §7.

**The course is born canonical and held there** (SA-8, MOD-15).
- **Every lesson carries a contract the battery judges, so a lesson that
  teaches a refuted claim fails.** lib/tutorial's lesson 04 still teaches that
  `Pure` unlocks memoization, compile-time evaluation and parallelism, all
  three of which D4 deleted. Lesson 01 teaches that `int_to_str` comes from io.
- **examples/ joins the board's census pass.** Each program is judged on its
  own link, with every census at 0.
- **SYNTAX's fenced examples are fixtures.** doc-truth extracts each one and
  checks that it parses, judges, and sits at fmt's fixpoint.
- **`ide/space.manifest` lists programs and projects only.**
  `tools/space-stage.sh` computes the runtime modules to stage from the
  medium's `modules` answer for each program. Today 15 lib lines are copied by
  hand, `src/types.mn` among them.

Everything that points at the old course moves with it, each re-derived by the
medium rather than retyped (doc-truth checks the runnable commands): README.md
(the first command and the transcript), docs/READING.md (the course chapter
and its transcripts), docs/POSITIONING.md, docs/DESIGN_SYSTEM.md (the mockup
and the programs list), docs/MENTL_SPACE.md §5.5 (its "until L-F, lib/tutorial"
sentence), ide/README.md, ide/space.manifest (the ten `program` lines become
one `project examples/pulse/course`), tools/verify.sh's islands leg
(`lib/tutorial/*.mn` in its loop) and tools/wt-env.sh's exclusion comment.
The gates: the course project judged clean (`mentl check` per lesson, zero
diagnostics), every lesson's proposal contract green through `mentl test
examples/pulse/course`, every lesson's WAV judged by the pulse-render oracle's
shape (RIFF, rate, RMS bounds, the lesson's pitch by Goertzel), and the IDE
gate's browser leg opening the course project and painting lesson 1.

## 7 · The order

The rules that set this order:
- Foundations come before surfaces, and the hardest comes first.
- The soundness items preempt everything else. This is PLAN §11's preemption
  law: §0's property (2) failing at a shape a real program writes stands above
  all other work.
- Every finding the seven lenses measured has a place below (§5's tables name
  each one's landing).

1. **§0.1 · The record.** This plan and the lenses' answers go into git
   verbatim. Minutes.
2. **§1 · L-C closes.** The m4 leg moves before the bless, and the 37 → 39
   obligations are recorded.
3. **§0.3 · The integration.**
   - The program goes into PLAN §11 and the designs into RESIDUE.
   - The 463 verdicts are applied.
   - The three doc gates are seen RED, then green.
   - CLAUDE.md's law becomes: the artifact is the refuter.
   - The record is deleted from the tree.
4. **G2 · Every gate can fail, and the board bounds answers.** The board gains
   bounds on obligations (39), costumes (490), prose coordinates (34), ghosts
   (18,681) and dead imports (2).
5. **TRAP · Traps are in the row.** The INT_MIN / −1 fold is measured first.
6. **RACE · The race rule reads every write, and a spawned instance shares the
   module's values.** Instruments first.
7. **EFF · An op lives in the effect its behaviour belongs to.** It reads
   RACE's published write fact, and word arithmetic leaves Memory in two pins.
8. **F · `mentl fmt`, cargo-style** (§2). It is the tool every later sweep
   writes through. A duplicate import becomes a syntax error with fmt as its
   fix.
9. **M1 · The reference link,** the root (§4). An effect name in a row
   resolves, or refuses.
10. **N** (§3).
    - Names: 455 → 0, lib/fs.mn as one capability unit.
    - One renderer, with the head round trip.
    - The honest host boundary, the never type, the catalog as a projection,
      and the row's Why.
    - `mentl rename` is born here, on the link.
11. **M2–M12 · The module is a scope** (§4).
    - The facets read the link, and two facets may not disagree.
    - lib stands on its own (`E_LayerInversion`; the search, Abort and
      combinators deletions).
    - Direct visibility.
    - Symbols by declaration.
    - The maintained import block.
    - Prose edges.
    - Nothing collapsed.
    - One link model (TRANSITION).
    - The vocabulary held by declaration.
    - Dead effects and installs deleted.
    - Capability units, through the `clusters` facet.
12. **T · The teaching compiler teaches what the program owes,** T1–T9.
13. **V · The verbs are whole.**
    - V1: early exit.
    - V2: a fanout costs no more than its desugaring.
    - V3: every cycle has a driver.
    - V4: stages are handlers.
14. **AU · The medium authors the migration.**
    - AU1: the detector, with the syntax lens's shapes.
    - AU2: rewrites by edge, including the Stage Law and the R4 list.
    - AU3: the vocabulary.
    - AU4: the speculation extent, which is also the cursor as arena plus
      overlay.
    - AU5: handler chains as values.
    - AU6: the user's TIME library.
15. **SPACE.1 · Instance segments.**
16. **The course** (§6). It stands on V2, AU2, AU6, SPACE.1 and RACE, and it is
    born canonical: SYNTAX's fences are fixtures and examples/ is on the board.
17. **The Space spine and the second program.** Each item's design is in a
    section below:
    - E1, the Env protocol;
    - W1, Wasatch "Inversion" offline;
    - L-D;
    - L-E (the Severance Map ships after its false-green carriers close, or
      they are counted in its third colour; M12's capability units are what its
      bands sever);
    - L-F;
    - W3;
    - W2, as keys arrive.
18. **SPACE.2 · The SPACE axis (Phase 9.2).**
19. **#159 · Capture at every position.** Recover it with `git stash pop` (the
    stash named "#159 capture at every position"). Then MS-8, the ??-fan as
    `choose`, which is #159's first consumer, with MS-1's floor.
20. **#108 · Positions are cells.**
    - The remaining name positions after M1, plus binders, patterns,
      annotations and predicates.
    - VERB-9's Scan handler rides the parser's rewrite.
    - PR-12's `unreferenced` is trued, and so is `performs` over types and
      effects.
21. **#109 · Verify's own solver.** It includes PR-2's one folder and the read
    of the path, plus the 23 peers the re-grounding routed there.

## 8 · Verification, per landing

Every landing: `mentl fmt` (no target, once F lands) and `mentl check` at zero
over the PROJECT, every module reporting at its own module once G2 lands (until
then `mentl check src/main.mn` reports main.mn alone — SA-13); the medium's own
facet for what the landing claims, RED on
the prior boot; micros, frontier, crown, proof-exactness, IDE gate; the
fixed-input cost reading when the wheel's compiler grows; `MARCH_REPIN=1 bash
tools/march.sh --fixpoint` (the determinism leg now runs at every pin); records
(LEDGER with kills, PLAN §7/§11, RESIDUE, SYNTAX where the surface moves,
PROVENANCE); `bash tools/doc-truth.sh`; commit; push.

Two more checks hold from §0.3 and G2 on:
- **The doc gates.** Every cited peer is a header, statuses come from the
  closed vocabulary, and an open entry's code names resolve. A landing that
  closes a peer marks it CLOSED in the same commit, so the LEDGER line and the
  RESIDUE header cannot disagree.
- **The board's bounds over answers.** A landing that raises one says so in its
  commit.

Every new gate is seen RED before it is trusted, and no refuter pass stands in
for one.

---

# THE SECOND PROGRAM AND THE PROTOCOL — from a34c9d27 onward (2026-10-05, evening)

## Context

Three asks arrived after the engine pin landed, and one piece of unfinished
business sits in the tree: (1) "rename MENTL_EDIT accordingly" — the design
document was rewritten to the Space verdicts (five surfaces, the deletions, the
project form, Pulse as the course, the time axis) and is UNCOMMITTED at
`docs/MENTL_EDIT.md` (877 lines, `git status` shows exactly that one `M`);
(2) "standardizing a super clean and developer-friendly environment-variable
and/or secret management paradigm/protocol for Mentl"; (3) a second program
after Pulse: "take data from Salt Lake City and surrounding that is relevant to
the culture in the area … map the (preferably live) types of data streams to
parameters of a synthesizer symphony … explore this idea"; and the standing
order L-C → L-D → L-E → L-F → `#159`. Everything below was measured this
session (three Explore passes with file:line, the medium's own verbs on the
pinned boot, curl against every candidate data source) and is written as the
ULTIMATE form first, then the landing that is whole, then what it names.

**The facts that shape all three designs (measured, file:line):**
- The wheel imports WASI preview1 ALONE and exactly fifteen ops (`effect WASI`,
  lib/io.mn:45–78; `wasi_import_reprs`, src/backends/wasm.mn:4516–4552, the
  import roster's one home; the only `wasi_snapshot_preview1` literal at
  :4508). No `environ_*`, no `clock_time_get`, no `random_get`, no sockets. No
  Mentl program can read an environment variable today, in the terminal or the
  browser, for four independent reasons: no op, no import, the shim passes no
  `--env`/`-S inherit-env` (tools/install.sh:75, tools/wt-env.sh:78), and the
  page's shim answers zero variables (ide/wheel-worker.js:162–163).
- A string CAN be an effect instance argument at the parser: `type EffArg =
  EAInt | EAFloat | EAString | EAType | EANode | EAEffect | EACon`
  (src/types.mn:1108) and `parse_one_eff_arg` (src/parser.mn:988–1009) folds
  `TStringPart(s)` to `EAString(s)` "for value-distinct row equality"; and the
  type layer already anticipates the shape — src/types.mn:4472–4474: `with
  Filesystem("/workspace")` "lands when audit-driven permission scopes become
  meaningful". Inference's instance equality compares a string instance BY
  VALUE (`eff_arg_scalar_unequal`, src/effects.mn:1479 — the payload is a
  typed String, so `!=` is structural, not the pointer-eq class); what is
  UNMEASURED is only whether lowering has an arm for an `EAString` dim where
  it keys arms by instance (the first m2 of E1 measures it).
- The guest has no network, so every fetch is the host's: `tools/install.sh`'s
  `mentl run` is `wasmtime run … --dir "$PWD" --dir /tmp module.wasm args…`
  (:75; no `/mentl-home` preopen at run time); the page's worker serves a
  `{path: bytes}` vfs with `fd_readdir` a stub (ide/wheel-worker.js:159).
- lib/json.mn is real and reachable from user programs (`import json`):
  `json_parse` :73 → `JOk(JsonValue, Int) | JErr`, `JsonValue` :28 (numbers
  always `JNum(Float)`), `json_obj_get` :519, `json_str_or_default` :539,
  `json_int_or_default` :551, `json_serialize` :433; one trap: an exponent is
  SCANNED (`json_scan_number` :165 accepts `e`) and then IGNORED by
  `number_from_substring` (:191–201) — a silent wrong, fixed in W1 by deleting
  that second decimal parser in favour of `parse_float` over the slice
  (lib/strings.mn:846, sign/fraction/exponent-correct), `mn-json-exponent.mn`
  RED first. The writer's `acc ++ item` spine is NOT quadratic: `++` is one
  `seq_concat` over the O(1) concat node (SYNTAX §Concatenation), flattened
  once at `print_string`. `parse_int` (lib/prelude.mn:530) validates nothing;
  `Int` is i32 — epoch milliseconds stay Float (json parses into a Float).
- The stdin session (src/mcp.mn `session_line_loop` :519–543, `session_argv`
  :547, `session_miss` :557) answers the verbs src/main.mn `session_read`
  :1029–1044 names — the address, `accept`, `query`/`where`/`why`, `audit`,
  `teach`; everything else MISS; the target is pinned to `main` — and the
  address answers TEXT (`render_at`, main.mn:1363–1477) off
  `CursorView(NodeKind, Proposal, [VerbFrame], RowFacet, Ownership,
  [(Int, Span, Predicate, Reason)], Teaching, [Reason])` (src/types.mn:1817).
  The page re-parses that text with regexes (ide/index.html `parseFacets`
  :429–444, `parseStderr` :451–465) and two of them are WRONG today: the kind
  regex accepts only lowercase `error|warning|note` while the wheel prints
  `Warning` and `VerificationPending` (`diag_kind`, types.mn:4080), so every
  warning lands in the verdict strip and never in the Lens; and the address
  regex takes the FIRST `at L:C` in a message while `diag_line`
  (types.mn:4517) appends the real span LAST, so a Lens jump can land on a
  Reason's line instead of the diagnostic's. A third gap, by reading: the first
  derivation's diagnostics stay in `opened.err` (ide/session-client.js:87) and
  `project()` reads only the call's `err` — invisible only because every lesson
  has zero diagnostics. `VSpace` exists (src/cli.mn:195–202) and `space_run`
  (main.mn:257–260) is a stub answering 2; the shim intercepts `mentl space`.
- Pulse is the only program; its instrument is PROGRAM-LOCAL (oscillators
  :178–:216, `adsr` :125, echo :247, Schroeder rooms :275/:290, panner
  :310/:312, limiter :321 — all in examples/pulse/render/main.mn), while lib
  holds the one-pole makers (lib/dsp/feedback.mn:31–96), the distortion family
  and its three handlers (lib/dsp/spectral.mn:19–111), `Sample`/`Hz`/`Gain`
  and `soft_clip`/`mix` (lib/dsp/signal.mn:48–83), the clock
  (lib/dsp/clock.mn:53 `effect Sample(rate: Int)`, `sample_at` :119) and the
  WAV writer (lib/audio/wav.mn: `wav_alloc` :27, `wav_header` :36,
  `wav_frame` :83 — the `!Alloc`-safe per-frame write, `wav_bytes` :90).
  Missing for a data-driven piece: parameter smoothing, a sequencer, a tempo
  clock, a voice allocator, a table oscillator, a pure delay tap
  (`Hβ.dataflow.delay-tap`), `pow`/`round`/`fmod`, a right shift, a random
  primitive, date parsing, real-time audio output (none in WASI p1; the page's
  AudioWorklet after L-F). The frontier's `run_pulse_render`
  (tools/frontier-gate.sh:610–657) with tests/frontier/pulse-render/oracle.py
  (RIFF header, RMS bounds, peak, Goertzel per note ≥ 20 dB) is the leg shape
  to copy; its three sed twins each match exactly one line.

## 0 · First — the rename and the design commit (no wheel change, one commit) — LANDED `f376f5e9`

- `git mv docs/MENTL_EDIT.md docs/MENTL_SPACE.md`; its title becomes
  `# Mentl Space — the interaction architecture` (the verb and the page carry
  the product name; the doc follows). References re-pointed, each measured by
  grep over non-`.mn` files (no `.mn` cites it — `mentl query src/main.mn
  "prose MENTL_EDIT"` → 0): PLAN.md:3084 and :3135 (Arc E), docs/DESIGN_SYSTEM.md
  :12, :109, :264, :333, ide/README.md:38, docs/proposals/CLAUDE.next.md:97,
  docs/PROCESS-AUDIT-2026-09-25.md:881. LEDGER.md's two mentions are history and
  stay. The §9 row and the §3.8 decision sentence keep the words "Teach knob"
  (they name what was deleted).
- `bash tools/doc-truth.sh` (it checks that `.mn` citations of `.md` files
  resolve; the rename adds none); commit `Mentl Space — the design, and the
  document named for it` (no attribution lines); `git push -u origin
  claude/mentl-design-audit-m1mptf`.

## 1 · ENV — configuration and secrets are an effect, and the row is the manifest

### 1.1 The ultimate form

**The host boundary IS an effect** (lib/io.mn:38–44 says so of WASI; the
Filesystem effect and `Console` are its projections). Configuration is the
same boundary read by name, so it is one more effect whose INSTANCE is the
variable's name:

```
// lib/env.mn
effect Env(name: String) {
  env(name) -> String          // the op's argument IS the instance
}
handler env_from_host { env(name) => resume(host_environ(name)) }   // the root install, beside stdout_console
```

- **The instance is read off the perform's own argument.** `env("PORT")`
  carries `Env("PORT")` in the row (the parser already folds a string literal
  to `EAString`, parser.mn:993; "literals are folded for value-distinct row
  equality"); `env(name_var)` carries an UNGROUNDED instance that stands for
  every instance it might equal (SYNTAX §«Parameterized effect»), so `!Env`
  and `!Env("DATABASE_URL")` are provable exactly when the program's reads are
  literal, and a computed name honestly defeats the negation. This is the one
  grammar extension: an op parameter that names the effect's parameter grounds
  the instance at the perform — the proof becomes the dispatch at the host
  boundary. (Today the instance is read only off the DECLARATION's `with`
  clause; `fn port() with Env("PORT") = env()` would be the lowered form and
  it is an INVENTORY — A4's law forbids making the developer write the row.)
- **The demand is the manifest — read at the perform sites, never off a
  collapsed row.** `mentl query <entry> env` renders every grounded `Env`
  instance the program performs beneath an install whose handler crosses the
  host boundary, with its read site — the `.env.example` nobody writes,
  projected from the proof; `mentl doc` carries it per module. Two artifact
  facts decide that it is read at the SITES (the Plan agent's refutation of
  "the row is the manifest" as first written): `main`'s row is Env-free the
  moment `~> env_from_host` absorbs it (the absorption law), and a row that
  meets a ground instance beside an ungrounded one keeps the UNGROUNDED one
  (`collision_upgrades`, src/effects.mn:1680 — piece (3) of
  `Hβ.effects.handler-pins-its-instance`). So the roster (`env_demand()`, one
  home) walks the reachable `env` performs to their literal, span, module and
  enclosing declaration and keeps those whose serving install (`served_at`,
  src/main.mn:1428, the Handler facet's own read) is a host-crossing handler.
  A computed name reaching such an install is REFUSED at compile —
  `E_EnvNameUngrounded(span)`, armed at birth, teaching "write the name at
  the read, or ask `env_opt`" — so `env` is total by construction and the
  roster is exact.
- **Nothing executes unproven at the boundary.** `emit_start`
  (src/backends/wasm.mn:6274–6350; the `$wasi_args` call at :6319 is the
  precedent) emits `(call $env_demand_check (i32.const <interned roster>))`
  before `main` whenever the roster is non-empty; `env_demand_check` lives in
  lib/env.mn, reads `wasi_environ()` once and `fail`s under `~> fail_exit`
  (lib/io.mn:137, the host-boundary failure policy) naming EVERY unset
  variable with its read site — exit 1, nothing of `main` executed. The host's
  half only NARROWS what it passes: `mentl run` asks the medium for the
  roster (`mentl_wasm query "$module" env`), takes each name from the shell
  environment, else from `<project>/.env` (`KEY=VALUE`, `#` comments —
  `.gitignore` already ignores `.env`/`.env.*`; its `!.env.example` line
  leaves, the file the protocol says never exists), and passes exactly those
  as `--env NAME=VALUE` (measured on wasmtime 36.0.17: `run --env <NAME[=VAL]>`
  beside `--dir`); nothing else of the developer's shell enters the image. A
  check in bash would be a second home (the compile environment is not the run
  environment), so the shim checks nothing — the module does, at its own
  boundary, under any preview1 host. The developer's loop: write
  `env("PORT")`, run, read "PORT is read at main.mn:12:14 and is not set".
- **Typed ingress is a CLAIM decided once at the boundary.** `let port: Port =
  env("PORT") |> parse_int` with `type Port = Int where 1024 <= self && self
  <= 65535` is honest `V_Pending` today (a value that exists only at runtime);
  the ultimate is the predicate EXECUTED once at ingress — the single place in
  the medium where a runtime check is the proof — which rides
  `Hβ.types.predicate-is-expr` (Phase 8.1): named `Hβ.verify.claim-decided-
  at-ingress`, never built as a hand check. The parse is the PROGRAM's, never
  a typed op per type (`env_int`/`env_float` killed — one reader per type is
  drift 6); `parse_int`'s own partiality (lib/prelude.mn:530–535 answers
  garbage on a non-digit) is the Partiality law's next primitive, named
  `Hβ.lib.parse-int-is-partial` (a `Decimal` precondition the gradient
  proposes), and the conversion the gradient could propose at a
  String-vs-Int mismatch is `Hβ.synth.conversion-proposal-at-type-mismatch`.
- **A secret never enters guest memory.** `persist = memcpy` writes the whole
  image to disk (lib/persist.mn:3–7), so any value the guest holds is in every
  checkpoint; a secret therefore is NOT an `Env` read. It is a HOST-HELD
  capability the host applies on the program's behalf — and since the guest has
  no network, every use of a key is host-mediated already: the well's fetcher
  (§2) reads `UTA_API_KEY` from the host environment and the guest sees only
  the fetched file. The program's data declares the need (the well manifest
  names the key's variable per source, §2.2), the host checks presence at
  launch exactly as it checks `Env`, and `!Secret` is structural: a program
  whose reach declares no keyed source cannot leak one, by construction, and
  an image cannot carry what was never in memory. In the page the worker holds
  keys in JS memory and applies them in its fetch — the same shape, one host
  over. There is no `Secret` effect in the guest: adding one would be a second
  home for a fact the source's own declaration carries.
- **What the medium adds that dotenv / Vault / 12-factor cannot say:** provable
  ABSENCE (`!Env`, `!Env("X")`) under polymorphism and transitively; the
  manifest as a projection of the proof rather than a file kept beside the
  code; the refusal carrying the Reason to the read site; images that cannot
  leak a secret because the secret was never a value.
- **The toolchain's own variables** (MENTL_HOME, MENTL_BOOT, MENTL_WASMTIME,
  MENTL_SPACE_PORT, MENTL_CHROME, MENTL_WT_EXTRA, MENTL_RT_LIBS, MENTL_BIN_DIR,
  MENTL_HEAVY_*, MENTL_IDE_*, MENTL_LOCK_OWNER — thirteen names, all shell,
  none `.mn`; read by install.sh, wt-env.sh, verify.sh, ide-gate.sh,
  heavy-lock.sh, march-gate.sh, crown-gate.sh, run-micro.sh,
  effect-identity-gate.sh, wasmtime-get.sh and ide/test-shim.mjs) get ONE
  home: the table in `tools/wt-env.sh`'s header, the file every script
  sources, each with its default and its reader, and `tools/doc-truth.sh`
  gains the census — every `MENTL_[A-Z_]+` token under tools/, ide/ and
  .githooks/ appears in that table, a gate rather than a paragraph. README
  points at it. There is no `mentl env` verb: the wheel reads none of them,
  and a verb would narrate the host (a config page is a refused import,
  MENTL_SPACE §9).

### 1.2 The first landing — E1 (a wheel landing: board + march + repin)

1. **lib/io.mn** — `effect WASI` gains `environ_sizes_get(Addr, Addr) -> Int`
   and `environ_get(Addr, Addr) -> Int` (the p1 ABI: counts then the
   pointer array + buffer, exactly `args_sizes_get`/`args_get`'s shape);
   `wasi_environ() -> List((String, String))` built like `wasi_args`
   (io.mn:104–113, `cstr_to_string` :90) with the `K=V` split at the first
   `=` (`find_char`, strings.mn). **src/backends/wasm.mn** `wasi_import_reprs`
   gains the two rows (`[RI32, RI32] -> RI32`). The browser already answers
   both (worker :162–163: zero variables), so the boot keeps instantiating in
   the page; the node twin and the gate measure it.
2. **lib/env.mn** (`import io`) — `effect Env(name: String) { env(name:
   String) -> String; env_opt(name: String) -> Option(String) }` — two ops,
   one instance: `env` is a REQUIRED read of a LITERAL name (its absence is
   the launch refusal below, never `""`; a computed name is
   `E_EnvNameUngrounded`), `env_opt` an optional read of any name (presence is
   the program's own question; `env_or(name, default)` is a library fn over
   it); the roster reads the `env` performs alone. `handler env_from_host(vars)
   { env(name) => resume(env_value(vars, name)), env_opt(name) => … }`
   installed as `~> env_from_host(wasi_environ())` — a call in config position
   is UNMEASURED (`emit_config_writes`, wasm.mn:6410, emits any frame
   expression; the fallback is `let vars = wasi_environ()` first) — and
   `handler env_fixed(pairs)` for fixtures, whose missing name performs
   `fail`. No typed reads: the parse is the program's. **The grammar extension
   in src/infer.mn, measured against the mechanism as it is:** an effect's
   instance VALUE DIMS are minted ONCE at registration as opaque placeholders
   — `register_effect_ops` (infer.mn:11986–12040): `value_dims = map((_) =>
   EANode(mint(…)), params)`, every op of the effect sharing the one row
   member `EParameterized(enh, value_dims ++ type vars)` — and they have
   exactly ONE writer today: `pin_declared_instances` (infer.mn:3138–3190,
   `pin_arg_position` :3174), applied at the declaring fn's exit by
   `enforce_row_gate` (:3237), which
   replaces a charge's `EANode` dim with the DECLARATION's scalar (`with
   Sample(48000)`). So `fn port() with Env("PORT") = env()` already works on
   the boot with zero changes — and it is the inventory form. The ultimate
   form adds the SECOND writer, at the perform: `register_effect_ops` notes
   which op parameter positions name the effect's own parameter (`effect
   Env(name: String) { env(name) -> String }` — the op's `name` IS the
   effect's), and the op's call judgment, where its scheme's row is
   instantiated and charged into the frame, writes the perform's LITERAL
   argument into that dim (`pin_arg_position`'s shape with the argument as
   the source: `EAString(s)` / `EAInt(n)`), leaving a non-literal argument's
   dim the opaque `EANode` it is. THE ONE SEAM TO FIND AT BUILD TIME: the
   callee's row joins the frame at the CallExpr judgment, after the
   arguments are judged (the VarRef at infer.mn:4100 instantiates the op's
   scheme BEFORE the arguments exist, so the write cannot live there); if the
   join is a VALUE union, the rewrite is `pin_arg_position`'s shape on that
   value; if it is an EDGE to the instantiated TFun's row cell, the pinned
   member is written through the judged row writer (A7's `RowWrite` — the
   only legal writer) into that cell. Either way the declaration form stays
   the inventory and is not the landing. The row algebra then does the rest unchanged:
   `eff_arg_scalar_unequal` (src/effects.mn:1479) compares `EAString` BY
   VALUE (the payload is a typed String, so `!=` is the structural compare —
   measured, not the pointer-eq class), an ungrounded dim is never provably
   distinct (`eff_args_provably_distinct` :1466), so `!Env("A")` refuses `env(x)`
   and admits `env("B")`, and two literal reads are two row members. One
   registration note, one write at the perform — no new row rule.
3. **The roster, one home.** `env_demand()` in src/pipeline.mn: every
   reachable `env` perform → its literal (or `E_EnvNameUngrounded` at the
   site), its span and module (`decl_site_of`, src/query.mn), its enclosing
   declaration, and the install `served_at` (src/main.mn:1428) resolves to;
   kept only where the serving handler's arm row crosses `WASI`
   (`handler_arms`/`handler_effect_names`, src/query.mn:2420–2434). Read
   twice, never copied: by `QEnv` in src/query.mn (`Question` :122,
   `QueryResult` :207, the render :2380ff) and by `emit_start`'s prologue.
4. **The launch gate.** `emit_start` (wasm.mn:6274–6350) emits `(call
   $env_demand_check (i32.const <interned "NAME\tmodule:L:C\tdecl\n…">))`
   before `(call $main …)` (:6309) when the roster is non-empty;
   `env_demand_check` (lib/env.mn) reads `wasi_environ()` once and `fail`s
   under `~> fail_exit` with every unset name and its site — exit 1, nothing
   of `main` run. The import roster is a projection of use
   (`emit_runtime_imports`, wasm.mn:4474–4482, emits an import iff the program
   performs the op), so the boot's own import set does not move. The shim's
   half (tools/install.sh `run` :59–76): the roster from `mentl_wasm query
   "$module" env`, each name from the shell environment else `<project>/.env`,
   passed as `--env NAME=VALUE`, nothing else. The page: the worker's
   `environ_*` arms exist (ide/wheel-worker.js:162–163, answering an empty
   environment) and lack only an `environ` handed in like `argv` (:107) — the
   page's `.env` is `Hβ.felt.page-environ-from-project-dotenv`, landing with
   L-F, the first time the page RUNS a program.
5. **Fixtures, RED-first on the pinned boot.** Crown: `leak-env-bare` (`with
   !Env` over a body performing `env("A")` → `E_EffectMismatch`),
   `sound-env-instance` (`!Env("A")` admits `env("B")`), `leak-env-instance`
   (`!Env("A")` refuses `env("A")`), `leak-env-computed` (`!Env("A")` refuses
   `env(name)` — the ungrounded instance is never provably distinct). Micros:
   `mn-env-ungrounded-refuses.mn` (refuse `E_EnvNameUngrounded`),
   `mn-env-fixed.mn` (under `env_fixed`, exit = the parsed value). The
   host-facing legs go in tools/frontier-gate.sh, since the micro harness
   passes no `--env` (tools/run-micro.sh:50): `run_env_protocol` — a program
   reading `MN_A`/`MN_B` runs to its exit with both set; with `MN_B` unset it
   exits 1 with `MN_B` and its site on stderr and nothing printed by `main`;
   `mentl query env` on it names both with sites.
6. **Records.** SYNTAX: a new section after «Negation in `with` clauses» —
   "Configuration — the environment is an effect" (the op-argument grounding
   rule, the demand projection, the launch gate, secrets as names the program
   never reads, `.env` as the host's file); RESIDUE: `Hβ.effects.instance-
   grounded-through-call-argument` (the literal flowing through `fn read(name)
   = env(name)` at `read("PORT")` — the instance as a precondition on the
   parameter, P0's value walk one primitive over),
   `Hβ.verify.claim-decided-at-ingress` (DEP predicate-is-expr),
   `Hβ.lib.parse-int-is-partial`, `Hβ.synth.conversion-proposal-at-type-
   mismatch`, `Hβ.felt.page-environ-from-project-dotenv`, and the
   handler-pins entry (RESIDUE.md:8602) gains the cross-reference that its
   piece (3) is what would make a ROW-read roster exact; PLAN §7 bullet, and
   §4⑥'s agentic forcing case gains the sentence that a key is a host
   capability; the wt-env.sh table + doc-truth census; LEDGER + PROVENANCE at
   the pin (infer.mn and wasm.mn move the wheel: board + `MARCH_REPIN=1 bash
   tools/march.sh`).

### 1.3 Named, not built

The refined ingress (8.1); a `Secret` the GUEST could hold without it entering
the image (a host handle whose use is an op — needs a host facility WASI p1
lacks; WASI p2's resource handles are its natural home, behind
`Hβ.threads.terminal-host-horizon`); per-instance `Env` dispatch through
`Hβ.effects.handler-pins-its-instance` (one handler answers all instances
today, as `sample_at` does).

## 2 · WASATCH — the Salt Lake data symphony, the second program after Pulse

### 2.1 The piece

`examples/wasatch/` — the range names the place; the piece is "Inversion" (the
valley's winter air trap, the one phenomenon every resident hears about and no
one can see from inside it). A generative score whose every parameter is a
reading of the city, rendered to 48 kHz stereo exactly as Pulse is, and
provably unable to touch the Outside on its per-sample path. What each source
plays (keyless sources first; every URL measured 200 on 2026-10-05):

| Source (keyless) | Reading | Musical parameter |
|---|---|---|
| USGS NWIS 10010000 / 10010100 (param 62614) | Great Salt Lake elevation, south and north arms (ft) | the DRONE's root: the lake's place in its historic range (4191.4 ft record low 2022 → 4211.6 ft record high 1986) maps to a pitch across an octave; the two arms a detuned pair — the railroad causeway's split, audible as beating |
| USGS NWIS 10171000 (param 00060) | Jordan River discharge (cfs) | the drone's pulse width / a slow tremolo rate |
| NWS api.weather.gov KSLC observation | temperature, wind speed and direction, humidity, pressure, cloud layers, text | temperature → tempo; wind → the noise bed's level and its pan (direction as azimuth); pressure → the master low-shelf; cloud cover → reverb size; precipitation in the text → percussion density |
| NRCS SNOTEL Snowbird `TOBS` (9,170 ft) against KSLC `temperature` | the mountain warmer than the valley | THE INVERSION ITSELF, from two keyless sources — the piece's title fact: the low-pass lid closes and the distortion drive rises with the strength of the inversion; NWS `visibility` thickens it. (METAR left the score: aviationweather sends no CORS header and NWS carries every field it would add.) |
| USGS earthquakes FDSN (bbox 39.5–42 N, −113.5–−110.5) | magnitude, time, depth | bass impacts: amplitude by magnitude, repetition by recency, decay by depth |
| NRCS SNOTEL 766 Snowbird · 366 Brighton · 628 | snow depth (in), SWE (in), temperature | snowpack = SUSTAIN: reverb decay and a high shimmer whose level is depth; three stations three voices |
| OpenSky states (bbox) | aircraft count, altitude, vertical rate, heading | glissandi over the valley: each aircraft a sine sweeping with its vertical rate, panned by its heading (terminal-only: OpenSky answers only its own origin, so the page's well rests this voice honestly) |
| sunrise-sunset.org | sunrise, sunset, solar noon | the FORM: day = major mode and open filters, night = minor and dark; dawn/dusk crossfades |
| ESPN scoreboard | the Jazz's score when a game is on | a four-note motif on a lead, louder when ahead |

TRAX is W2's, not W1's: the keyless GTFS static zip is 8.7 MB with a 23 MB
`stop_times.txt` inside — the guest has no inflate (`Hβ.lib.inflate`, a
deflate reader in Mentl, named) and a 23 MB string walk is not a render; the
stream Morgan named ("trax starts/stops") is UTA's SIRI real-time feed, keyed,
and the first consumer of the host-applied key: the RHYTHM — each line (Blue,
Red, Green, FrontRunner) a timbre, a pulse per departure, panned by the
station's longitude. The other keyed sources join the same way when Morgan
supplies keys: UDOT traffic speeds (an arpeggiator's rate per corridor),
AirNow/PurpleAir AQI (the lid measured, beside the inversion inferred), the
Utah Avalanche Center's danger rating (a warning figure in the brass).
Nothing in the program changes for a keyed source: the well file is the same
shape, fetched by a host that has the key.

### 2.2 Architecture — one home per fact, the Outside at the root only

- **`well.mn` — the sources are Mentl data.** `type Source = Source({name,
  url, key: Option(String), every_s: Int, units})`, `fn sources() -> [Source]`
  with the keyless ten, `plan_line(s)` rendering one tab-separated line; the
  plan's ENTRY is its own file, `plan.mn` (`fn main() = each(print ∘
  plan_line, sources()) ~> stdout_console` — two `main`s in one link collide,
  so the plan and the render are two entries over one data module). **`tools/
  well.sh`** is the host's arm: `cd examples/wasatch && mentl run plan.mn |
  while IFS=$'\t' read name url key …` → curl into `well/$name.json`, a keyed
  source's header applied by NAME from the host environment (`${!key}`; a
  missing key refuses that source loudly by name), a `--loop <seconds>` for
  the terminal's live form — the network is the one thing the guest cannot
  do, so the host does exactly that and nothing else (no normalization: the
  raw body is the file, and parsing is Mentl's). In the page the worker
  performs the same plan with `fetch` into the vfs on the manifest's refresh
  period. CORS, measured 2026-10-05 with an `Origin: https://mentl.ampactor.dev`
  header: NWS, USGS water, USGS quakes, NRCS SNOTEL, sunrise-sunset and ESPN
  answer `access-control-allow-origin: *`; aviationweather.gov sends no header
  and OpenSky answers only its own origin — flights are terminal-only and the
  page's well rests that voice, never fakes it. The snapshot bodies carry no
  exponent-form numbers in any value field (the `5e5`/`46e35` matches are
  inside request-id and ICAO strings); the parser's silent exponent drop is
  fixed in W1 anyway (one decimal parser, above), since a live body may carry
  one.
- **`scene.mn` — ingress and the refined readings.** One function per source
  parses the raw body through lib/json.mn into a REFINED reading: `type Feet =
  Float where 4150.0 <= self && self <= 4220.0`, `type Celsius`, `type Knots`,
  `type Degrees = Float where 0.0 <= self && self < 360.0`, `type Inches =
  Float where 0.0 <= self`, `type Magnitude = Float where 0.0 <= self && self
  <= 10.0`, `type Percent`, `type Cfs`, `type Count`. These are the ingress
  CLAIMS (§1.1): each `let x: Feet = parse_float(…)` an honest `V_Pending`
  today over a runtime value (SYNTAX: a let's claim over a call result),
  COUNTED by the leg as a bound that only falls, refusing at the boundary
  after 8.1 — the program carries the proof obligations it means and the
  gradient log records them. What the bodies are, measured: USGS values are
  JSON STRINGS (`"4189.7"`), so the ingress is `parse_float`
  (lib/strings.mn:846–858); NWS values are floats; a quake's `time` is epoch
  milliseconds (1.79e12 — exact in a Float, never an Int) and
  `metadata.generated` is the snapshot's own clock, so recency is Float
  arithmetic between two Floats with no i32 in sight; sunrise/sunset are ISO
  strings → a fifteen-line `iso_seconds_of_day` (`str_slice` + `parse_int`)
  in scene.mn. `Scene` is one record of readings; a source whose file is
  absent or malformed yields `None` and its voice rests, said once on stderr.
  Names avoid lib/dsp/processors.mn's handlers (`envelope`, `lowpass`,
  `biquad`, `passthrough`, `peak_tracker`, `warm_filter`, `bright_filter`,
  the op `process`): a user program that links the DSP library cannot declare
  them (`Hβ.driver.per-module-env-overlay`). One driver fact W1's first
  compile decides: `driver_module_path` (src/driver.mn:59–81) probes
  `{name}.mn` relative to the preopen/cwd, then src/, lib/, /mentl-home —
  never the ENTRY's own directory — so a five-module project run from the
  repo root may miss `import scene` (Pulse is one file and never met it); the
  fix is one probe, the entry's directory first (the shim already preopens
  the argument's directory, tools/install.sh:41–52), named
  `Hβ.driver.imports-resolve-from-the-entry` if the compile measures it.
- **`score.mn` — readings → the instrument's parameters, pure.** Every mapping
  is a `with Pure` function from a reading to a musical quantity, claiming the
  refinement the instrument demands where it is made (`-> Hz` from the lake's
  range, `-> Gain`, `-> Decay`, a tempo in beats per minute as `Positive`);
  `clamp` lands the ends of every map inside the claim (today the claim over
  `clamp`'s result is `V_Pending` — the gradient's finding for 8.3's interval
  fragment, recorded, not worked around). The score is also WHERE the
  composition lives: the modes, the chord the drone implies, the rhythm
  grammar for departures, the motif.
- **`main.mn` — the render.** Pulse's shape exactly. `fn main(argv)` (the
  well directory from argv, default `well` — explicit over ambient, the CLI's
  own law) reads the scene ONCE at the root through `fs_read_file_impl`
  (lib/io.mn:491, row `WASI` — the host import IS the handler, as cfc.mn's
  `read_recording` :276 already reads a data file; there is no `Well` effect:
  a file read at the root is the well, and an effect for it would be a
  record standing in for one read), computes the parameters and a SORTED
  EVENT TABLE once (quake impacts, departures, the motif — frames computed
  from the readings; the sequencer is that table with a `<~` index line, no
  allocation), builds the rig from the lifted makers, and renders N seconds
  through `render_frame(buf, rig, params, events)` under `!Alloc +
  !Sample(44100) + !WASI + !Thread` — the per-sample path CANNOT cross the
  host boundary, in any direction, nor spawn: the Severance Map's
  thirty-second demo on a real program before the map exists (add one
  `fs_read_file_impl` inside the frame and the compile refuses with the
  Reason). `!WASI` is the whole Outside as one negation, stronger and truer
  than `!Filesystem` (the compiler's `wasi_filesystem` handler lives in
  src/pipeline.mn:884, not in lib; a user program never installs it).
  `!Thread` is read where it is authored (B4), so the voices' `><` inside the
  frame is pure topology and runs sequential under any caller's schedule;
  parallelism arrives at BLOCK altitude in W3, where a block of 128 frames
  per voice is a branch under `~> parallel_compose` (Pulse scene 2's
  real-time shape). A block-rate smoother per parameter (`lowpass_filter`,
  feedback.mn:31, on a parameter line) glides a reading's change; the tempo
  is a `<~` phase accumulator at the sample rate, the same cycle as an
  oscillator; the WAV goes to stdout through `wav_alloc`/`wav_header`/
  `wav_frame`/`wav_bytes` (lib/audio/wav.mn:27/36/83/90). The root chain is
  Pulse's, innermost first: `{ … } ~> stdout_console ~> spectral_flux_distort
  ~> sample_at(48000)` (lib/dsp/spectral.mn:93, lib/dsp/clock.mn:119).
- **What is LIFTED from Pulse into lib** (one home, the Vocabulary law):
  `lib/dsp/osc.mn` (saw/sine/square/noise makers taking `sr: Int`,
  `wrap_phase`, `phase_increment(freq, vib, sr)` — Pulse :178–221),
  `lib/dsp/envelope.mn` (`adsr` :125 and the exponential strikes),
  `lib/dsp/room.mn` (`make_echo(fb, samples)` :247, the Schroeder room
  parameterized by its six line lengths :275–305), `lib/dsp/stereo.mn`
  (`pan_left`/`pan_right` :310–312, `make_limiter(sr)` :321); Pulse imports
  them, keeps its three twin lines intact (`let n = now()`, the `wav_frame`
  call, `fn clock_rate()` — the sed patterns of its leg), and the
  `pulse-render` leg proves byte-identical output across the lift (the oracle
  is the regression contract). Missing primitives, placed rather than built:
  parameter smoothing = `lowpass_filter` on a parameter line; `pow` =
  `exp(b * log(a))` (lib/math.mn); a sequencer = the precomputed event table
  with a `<~` index line; randomness = the LCG line (Pulse :216); no table
  oscillator, resampler, WAV reader or right shift is needed for Inversion.

### 2.3 The landings

- **W1 · the offline render from a checked-in snapshot** — a wheel landing
  (lib/json.mn's one-parser fix and lib/dsp's lifts are linked by the wheel,
  src/main.mn:85–95, so the wheel's bytes move: board + march + repin; and
  the felt walk will find defects — Pulse's found ten). Files:
  `examples/wasatch/{well.mn, plan.mn, scene.mn, score.mn, main.mn,
  GRADIENT.md}`, `examples/wasatch/well/*.json` (ONE fixed day's ten bodies,
  2026-10-05 22:26 UTC, ~25 KB — the bodies already in the session's
  scratchpad `slc/body.*`), `tools/well.sh`,
  `tests/frontier/wasatch-render/oracle.py`, the leg in tools/frontier-gate.sh
  beside `run_pulse_render` (:610–657, registered at :1823), `tests/micros/
  mn-json-exponent.mn` and `mn-wasatch-score.mn`. The mapping has ONE home,
  the program: `mentl run main.mn --score` prints the parameters the snapshot
  derives (drone root Hz, tempo, lid cutoff, onset count…) as one JSON line
  on stderr, the micro pins the mapping functions at hand-computed points,
  and the oracle (python, like Pulse's) asserts the AUDIO against the printed
  parameters — Goertzel power at the drone root ≥ 20 dB over the table's
  other pitches, onset count within the band the cloud amount sets,
  RMS/peak/header as Pulse's — so no second copy of the score lives in
  Python. Three sed twins, each pattern matching exactly one line
  (`run_pulse_render`'s law): `alloc` (an `int_to_str(n)` on the per-sample
  path → `E_EffectMismatch`), `range` (a `1.5` into `wav_frame` →
  `E_RefinementRejected`), `outside` (an `fs_read_file_impl("well/…")` inside
  `render_frame` under `!WASI` → `E_EffectMismatch` — the thirty-second demo
  as a gate); and the ingress pending-claim count, a measured bound that only
  falls. `examples/wasatch/GRADIENT.md` is the felt walk's log (the
  annotations the medium asked for, the refusals, the pending count, the
  defects the walk found — the Pulse log's shape). Thirty seconds of audio:
  Pulse's ten seconds cost 2.58 s wall / 113 MB RSS end to end through the
  stock engine (measured 2026-10-05; the frontier log says 2,249 ms for the
  render alone), so a thirty-second piece with ~2× the voices projects to
  13–15 s — unmeasured until the leg prints it (it reports wall time, never
  ratchets it).
- **W2 · live in the terminal + the keyed sources** (host bash + well.mn data
  + one scene reading per source; no wheel change — it rides W1's landing or
  the next loop). `tools/well.sh --loop <seconds>`: refresh, render thirty
  seconds, write `inversion-<stamp>.wav` (`aplay`/`afplay` are the listener's,
  not ours); UTA SIRI real-time TRAX first (`UTA_API_KEY` applied by the host
  by name), then AirNow for the lid, UDOT, the Avalanche Center, as Morgan's
  keys arrive (`Hβ.wasatch.keyed-sources`); the secret-never-in-memory
  contract measured: a persisted image of the render holds no key bytes
  (`strings` over the image is the oracle), and `mentl query main.mn env`
  answers nothing — the guest performs no `Env` at all.
- **W3 · live in the page** (after L-F): the worker fetches the well on the
  refresh period into the vfs, the module renders 128-sample blocks into a
  ring the AudioWorklet drains (the real-time shape Pulse scene 2 names), the
  page shows each source's reading beside the parameter it drives (the Ledger
  reads `scene.mn`'s claims live: this is the Severance Map's first subject
  that is not the compiler). The course (MENTL_SPACE §5.5) stays Pulse; the
  symphony is the demo that plays.

## 3 · L-C — the view is a projection (`src/space.mn`, the `space` verb over the session) — LANDED in two pins, `d956687d` and `c8ba5799` (TRANSITION, m3 == m4 under `--fixpoint`), both in the working tree; the head section's §1 commits them

### 3.1 One record, two projections

The View is a TREE OF FACTS (src/space.mn, new; the types in src/types.mn
beside `CursorView` :1817): `type Fact = Fact({id: String, kind: String, prov:
String, text: String, site: Option((String, Span)), h: Int, interest: Float,
kids: [Fact]})`, `type View = View({at: (String, Int, Int, Int), ring: [Fact],
lens: [Fact], ledger: [Fact]})`. `space_view(ranges, target, l, c)` resolves
the address as `address_project` does (`address_resolve`, src/main.mn:1240),
reads `cursor_at_handle(h)` (src/cursor.mn:89–96 → `CursorView`), the lede
(`graph_comment_at`), `served_at` (:1428), the tightening
(`banked_tightening`), the obligations (`verify_debt`, src/types.mn:4368),
the diag bank (below), and the declared rows (each `FnStmt`'s `effs`, the
`QIntentOf` read src/query.mn:286–291, over `graph_decls_at()`) — every facet
text is already a `show_*` render of a structured fact (`show_row_facet`,
`show_verb_path`, `show_teaching`, `show_reason`, `obligation_text`), so the
View is those facts before their render. **`render_at` becomes
`view_text(view)`** — the same lines in the same order, one home, so the
CLI's legs and the test-shim's text legs are the regression oracle — and
`view_json(view)` serializes through lib/json.mn (`++` is the O(1) concat
node, one flatten at `print_string`; the View's byte count per caret move is
the open measurement, the 50 ms bar stands; `JNum` renders through
`float_to_str`, so line/col are measured as `1` vs `1.0` first). `interest`:
ring facts 1.0; lens facts by proof state (refusal > pending claim > teaching
> warning) then line; ledger declarations by `position_proximity(h_caret,
h_decl, reach)` (src/cursor.mn:380–393, the decay table :419ff) — Furnas's
degree of interest from the graph, so the page draws what scores and the knob
is gone. Every fact carries its handle, which is the page's key (the Lean
InfoView contract PLAN §11 Arc G names); the View as a graph NODE with a Why
is the named peer `Hβ.space.view-is-graph-content` (today it is a per-answer
arena value, `session_line_loop`'s `~> arena`).

### 3.2 The wire

`mentl space <target>:<line>[:<col>]` — the verb takes an address
(src/cli.mn `VerbSpec` :195–199 → `VSpace(Option((module, line, col)))`,
`parse_address` :289); one grammar for every transport (`session_argv` →
`parse_cli_args`, mcp.mn:547, cli.mn:260 — a `--json` register on the address
verb would be a second grammar, killed); `dispatch_invocation` (main.mn:149)
runs it cold through the same `space_view`; `session_read` (main.mn:1029–1044,
whose wildcard sends `space` to MISS today) gains the arm and admits ANY
module in the link — the `"main"`-only guard (:1030) goes, since
`session_address` (:1086) already takes a target; `session_accept` (:1050)
answers the View at the address after the write, so one painter redraws. The
shim intercepts only bare `mentl space` and `mentl space <dir>`
(tools/install.sh:77–86); an address passes through to the wheel. The reply's
`out` is the JSON; `written` rides as today (worker `take()` :170–174);
`session_whole`'s law holds (a refusal answers MISS and the cold route says
it whole). **Structured diagnostics**: `diag_bank` in src/pipeline.mn beside
`tighten_collector` (:712) banks `(module, diag, line)` on `diag_report` and
forwards outward as `mcp_diag_collector` does (mcp.mn:100–110), answers
`diag_banked()`, forgets the cone's modules at `session_current`'s
re-judgment exactly as `tighten_forget` (:697) does — installed in
`session_run`'s chain (mcp.mn:503) so the FIRST derivation banks too, which
closes the `opened.err` gap by construction. Each lens fact carries
`diag_source`/`diag_code`/`diag_kind`/`diag_applicability`/`diag_span`/
`diag_message` (src/types.mn:4517–4525's projections), so the page's `APPL`,
`SEV`, both regexes and their two measured bugs delete; the Lens's lead
sentence (`leadCopy`, ide/index.html:549–557) moves into src/voice.mn as the
wheel's own. A tie's computed question is the propose fact's `kids`, never a
sniffed string.

### 3.3 The page — one painter, the deletions, the gate

ide/index.html keeps the host: the WASI shim, the SAB channel, the textarea,
`runWheel` for MISS and refusals, `acceptProposal` (:605–619) over the View,
and ONE painter keyed by fact id (`#facets`, `#plens`, `#pledger`,
`#proposal`) that never parses `out` or `err`. DELETED per MENTL_SPACE §3.8:
the Teach knob (:199, :669, the `data-teach` CSS :180–182), the status
(:197, :490–491), the footer (:235–239, :497, :687), the Wavefront strip
(:234, :577–584, `TRAIL`), the Module pane (:227–230, :622–638, :666–667,
`WAT`), `parseFacets` (:429–444), `parseStderr` (:451–465), `APPL` (:445),
`SEV` (:448), `proposalAt`'s sniff (:588–597), `renderLedger`'s regexes
(:562–565). Kept until L-D: `tokenize`/`highlight` (:287–358) and
`renderTopology` (:378–401). The gate: ide/test-shim.mjs leg [9] —
`["mentl","space","main.mn:L:C"]` resident under `READ_BAR_MS`, the JSON
parses, the ring carries eight facts with kinds in primitive order, every
lens fact's site is typed numbers, no `undefined`, the resident JSON equal
to the cold JSON byte for byte (leg [8]'s law at the structured register),
and the View's bytes and ms printed (unmeasured today; the 50 ms bar stands);
leg [10] — an address in a sibling module of a two-file project answers
resident; legs [2]–[8] stay (the text verb remains the CLI's). The browser
`smoke()` (:706–730) drops the Module pane's `SMOKE exit/watlines` and asserts
that the first lesson's View arrived from the session with zero lens facts of
a refusing kind, `ring-real>=8` from the painted DOM, `undefined=false`,
fidelity; tools/ide-gate.sh (:70–95) re-expresses the browser-leg verdict
accordingly; and two legs RED on the current page by the measured bugs: a
`Warning` lands in the Lens, and a diagnostic whose message embeds a Reason's
address jumps to ITS span.

### 3.4 The project form (the half of L-C that is a host change)

`ide/space.manifest` gains `project <dir>` lines that `tools/space-stage.sh`
expands into the folder's `.mn` files (a static host cannot list a
directory); the page's program select lists a project's files, the vfs holds
all of them, the edited file rides the delta under its own path, and the
address targets its module (`session_read` admitting any module, §3.2);
`mentl space <dir>` stages that folder as the project (the shim;
`space-stage.sh <out> <dir>`); a folder pick/drop in the browser
(`showDirectoryPicker`, the host's facility where it has it —
`Hβ.felt.project-picker-outside-chromium` names the rest); the worker's
`fd_readdir` (a lying stub, :159 — success with `bufused` never written) is
made TRUE over the vfs keys (~15 lines, the dirent layout) rather than
deleted; drafts persist as the files (the vfs written back through `written`
and localStorage until the File System Access API is a host facility). The
lessons stay ten one-file projects. The compiler's own source is a project
like any other (open src/main.mn) — measured by the gate opening
`lib/tutorial/` and one `examples/` folder. The page's `.env` and running a
program are L-F's (§1.2.4). What L-C must not touch: tokens/spans and
`VerbFrame` geometry on the canvas (L-D — the View's topology fact carries
`VerbFrame` text only), the Severance Map and the Ledger's bands (`audit`,
`performs`, `where` — L-E), running programs and the page's environ (L-F).

## 3.5 · The adversarial pass — inline first, then the Plan agent's, both recorded

The inline pass ran at 23:10 while the dispatched Plan agent (the dispatched model, max
effort, briefed at 22:43) was still working; the agent reported at 23:37,
after a container restart, and every refutation below marked (agent) is folded
into the sections above. Kills and holds against my sketches:

- **KILL (agent) · "the row is the manifest" as written.** `main`'s row is
  Env-free once `~> env_from_host` absorbs it, and `collision_upgrades`
  (src/effects.mn:1680) keeps the UNGROUNDED member when a ground and an
  ungrounded instance collide. The roster reads the perform sites through
  `served_at`, never a collapsed row; a computed name reaching a host install
  is refused (`E_EnvNameUngrounded`), so `env` is total and the roster exact.
- **KILL (agent) · the declaration form as the protocol.** `with Env("PORT")`
  beside `env("PORT")` is one literal in two homes with nothing checking they
  agree, and the handler arm cannot know the name without the op carrying it
  anyway. CONFIRMED that the declaration form runs on the boot unchanged
  (`pin_declared_instances` would pin the declaration's literal over the
  opaque dim regardless of the perform); the perform-site grounding is the
  second writer the Carried-Truth form needs.
- **KILL (agent) · a compile-time check in `mentl run`, and a `$__env_check`
  written in WAT.** The compile environment is not the run environment; the
  module checks at its own boundary through `env_demand_check` in lib/env.mn,
  called by `emit_start`'s prologue with the interned roster; the shim only
  narrows what it passes.
- **KILL (agent) · `env_int`/`env_float`.** One reader per type is drift 6;
  the parse is the program's (`|> parse_int`), its partiality a named peer.
- **KILL (agent) · a `Secret` effect or instance class in the guest.** The
  guest has no network, and reading a secret even to check presence pulls it
  into the image; a secret is a NAME in data the host applies, `!Env("KEY")`
  is provable for the whole program, and the superseded lattice stays
  superseded.
- **KILL (agent) · `mentl env` and a README table.** The wheel reads none of
  the thirteen variables; the table lives in tools/wt-env.sh under a
  doc-truth census gate.
- **KILL (agent) · "the browser needs an `environ_get` arm".** The arms exist
  (ide/wheel-worker.js:162–163); what is missing is the environ handed in,
  needed first at L-F.
- **KILL (agent) · TRAX from the GTFS static zip in W1.** 8.7 MB zip, 23 MB
  `stop_times.txt`, no inflate in the guest, and a 23 MB string walk is not a
  render — TRAX is W2's keyed real-time feed; `Hβ.lib.inflate` named. (This
  replaces the inline pass's "the well step cuts the departures", which was
  host-side normalization in a costume.)
- **KILL (agent) · air quality as a keyless reading; METAR in the score.**
  Every AQI source is keyed or HTML; the inversion itself is keyless (SNOTEL
  `TOBS` at 9,170 ft against KSLC temperature) and AQI joins in W2.
  aviationweather sends no CORS header and NWS already carries every field
  METAR would add.
- **KILL (agent) · "epoch milliseconds overflow i32 — a design, not a
  workaround".** Milliseconds stay Float (json parses into a Float) and
  recency is Float arithmetic against the snapshot's own `generated`; no Int
  is needed, so there is nothing to design around.
- **KILL (agent) · the JSON exponent as a named-but-harmless gap.** It is a
  silent wrong (scanned at :165, ignored at :191), fixed in W1 by deleting the
  second decimal parser in favour of `parse_float`; killed as a W1 BLOCKER
  (no measured body carries one).
- **KILL (agent) · `well.mn` carrying `main`.** Two `main`s in one link;
  `plan.mn` is the plan's entry.
- **KILL (inline) · the well's install order, and a `Well` effect at all.**
  The first draft put `file_well` outermost (an arm's performs resolve OUTER,
  so its reads would reach the root unhandled); then the effect itself went —
  the scene is read once at the root through `fs_read_file_impl`, and an
  effect for one read would be a record standing in for a read.
- **KILL (inline) · `!Filesystem` on the per-sample path.** `handler
  wasi_filesystem` is the compiler's (src/pipeline.mn:884), not lib's; a
  program reads through `fs_read_file_impl`, whose row is `WASI`; the honest,
  stronger negation is `!WASI`. (Agent: sharpened the same way.)
- **KILL (inline) · a second home for the score in Python.** The program
  prints the parameters it derived (`--score`), a micro pins the mapping at
  hand points, and the oracle judges the audio against the program's own
  claim.
- **KILL (inline) · threads inside `render_frame`.** A frame declared
  `!Thread` keeps its own schedule (B4); `><` inside it is pure topology;
  parallelism belongs at block altitude (W3).
- **KILL (inline) · one `env` op for required and optional reads.** The
  launch gate cannot know a read has a default unless the OP says so; `env`
  (literal, required) and `env_opt` (any name, optional) are one instance,
  two ops.
- **KILL (agent) · `--json` on the address verb.** One grammar for every
  transport; `space <address>` is the verb, and the shim already owns bare
  `space`.
- **KILL (agent) · "JSON per keystroke is slow — a ByteSink writer".** `++`
  is the O(1) concat node and the writer flattens once; the byte count is the
  open measurement and the 50 ms bar stands.
- **KILL (agent) · "W1's keyed sources are E1's first consumer".** Keys are
  host-applied and the guest performs no `Env` in Inversion; E1's first
  consumer is its own fixtures and the docs, and the order stands on Morgan's
  decision plus the host-half dependency (well.sh applies keys by NAME, which
  is the protocol's host half).
- **HOLD (agent) · the perform-site instance write as a second writer.**
  CONFIRMED: `subst_eff_names`/`chase_eff_names` (infer.mn:9378, :8809) touch
  only `EAType`, so a grounded `EAString` rides instantiation verbatim; four
  crown crucibles decide it; the seam is the perform's call judgment (the
  VarRef at :4100 instantiates before the arguments exist).
- **HOLD (agent) · the View as a graph node.** DEFERRED in positive form: a
  per-answer arena value with a handle on every fact as the page's key; the
  node with a Why is `Hβ.space.view-is-graph-content`.
- **HOLD (agent) · `fd_readdir`.** CONFIRMED a lying stub; imports resolve by
  `path_open` so the session never needed it; made true in the worker touch.
- **HOLD (inline) · `render_at` as the text projection of the View**, the
  CLI's and the twin's text legs its regression oracle.
- **HOLD (inline) · ingress refinements stay `V_Pending`** (a guard on the
  path proves nothing today — the path-narrowing peer), decided at the
  boundary after 8.1.

## 4 · The order, and why

1. **§0 the rename + commit** (minutes; unblocks doc-truth on the new name).
2. **L-C** (the standing cursor; a wheel landing). Its View and diag bank are
   what every later surface draws, and W1's Ledger/Lens reads want them.
3. **E1 · the Env protocol** (a wheel landing). Before W1 because
   `tools/well.sh` applying keys by NAME is the protocol's host half and W1's
   GRADIENT cites the law E1 establishes (`!Env("UTA_KEY")` provable for the
   whole program) — not because Inversion's guest performs `Env` (it does
   not; E1's first consumer is its own fixtures and docs); small (two WASI
   ops, one library effect, one roster read by two projections, one
   prologue), and it closes a hole the second program would otherwise paper
   over with a bash convention.
4. **W1 · the offline render** — the felt walk that lifts Pulse's instrument
   into lib, fixes lib/json.mn's one silent wrong, and (per tripwire 3) finds
   the wheel defects no compiler-shaped program can; its oracle is the second
   real program on the board. Placed BEFORE L-D/L-E because W1 is lib +
   examples + one driver probe, not a surface, and L-E's Severance Map needs
   a subject whose capability bands are worth watching — W1 is it.
5. **L-D, L-E** as planned (the map's first subject: `examples/wasatch`).
6. **L-F**, then **W3** (the symphony live in the page); **W2** (keyed
   sources: host bash + data + one reading each) rides W1's landing or any
   loop after it, as Morgan's keys arrive.
7. `#159` resumes (`git stash pop` — "#159 capture at every position").

**Decided by Morgan (2026-10-05, in plan mode):** W1 goes after L-C and
before L-D/L-E, exactly as listed; the folder is `examples/wasatch` and the
piece is "Inversion".

## 5 · Verification, per landing

- §0: `bash tools/doc-truth.sh`; `git grep MENTL_EDIT` empty outside LEDGER.
- L-C: `mentl fmt` on every edited `.mn`, `mentl check src/main.mn` at zero;
  `bash tools/ide-gate.sh` both legs with the new product legs (two RED on the
  current page first); test-shim legs [0]–[9]; `bash tools/state.sh`;
  `MARCH_REPIN=1 bash tools/march.sh`; records (LEDGER with kills, PLAN §7,
  RESIDUE: `Hβ.session.edit-pays-for-the-program` re-measured, SYNTAX if the
  `space` verb's surface is named).
- E1: the five micros + the crown crucible RED on the pinned boot, green
  through m2; `mentl query env` on the wheel itself (expect: the wheel reads
  no environment — ZERO, and that zero is the medium's own `!Env`); the node
  twin and the browser leg still instantiate the boot (environ stubs); board +
  march + repin; SYNTAX/RESIDUE/PLAN/README/LEDGER/PROVENANCE.
- W1: `mentl check` clean and `mentl fmt` a no-op on the program; the render
  through `mentl run` against the snapshot; `python3
  tests/frontier/wasatch-render/oracle.py` green; the three twins RED-first;
  `pulse-render` byte-identical across the lift; `bash tools/frontier-gate.sh`;
  the whole board; a repin only if the wheel moved (expected — budget it).

---

# THE SPACE PIVOT — Mentl Space, the hosts, and the ultimate IDE (2026-10-05)

## Context

Morgan has not seen the IDE; asked whether it is at or past SOTA for code editors
and codebase visualization; asked for "the ultimate code editor / codebase
visualization / Mentl's novel graph-paradigm visualization — maximum info density,
elegant, holistic, comprehensive across all 8 tentacles"; found that meta's "muse"
agent (Loni) pushed eight commits to `main` as him and hosted "Mentl Space" first on
Railway (retired) then on GitHub Pages at `https://space.ampactor.dev/`; learned
there is a "Rust runner" and rejected any lean on Rust/Node ("WASM is the whole
thing"); asked the hosting/domain question (`mentl.space`?, rename to
`mentl.ampactor.dev`?); and asked that every little thing be interrogated — "can we
design this even better?". `#159` (capture at every position) is mid-build and
uncommitted in the tree (src/{cursor,graph,lower,types}.mn — zero overlap with
muse's files; the merge is conflict-free).

Everything below was measured this session (curl, RDAP, `mentl` on the pinned boot
`e7f6e2b9`, two Explore audits, the page's own source) — no claim is remembered.

## 1 · What is true today

### 1.1 The live page (space.ampactor.dev) — the two screenshots, explained at the source

1. **The default demo fails in production.** `deploy-space.yml` copies `ide/*`,
   `boot/mentl.wasm`, `lib/tutorial/` and `src/types.mn` — never the six runtime
   libs the page fetches (`ide/index.html:782-788`); all six 404 on the live site
   (`lib/prelude.mn`, `lib/memory.mn` measured). The page swallows a non-OK fetch
   as `""` (`:798`, a surrender fallback), so "link runtime" links nothing, `fold`
   is unbound, exit 1, 0 WAT lines — exactly the screenshot. The IDE gate's leg 2
   serves the REPO ROOT through `mentl space`, so it cannot see a deploy omission
   (green locally, broken live). Re-pins never redeploy (the workflow triggers on
   `ide/**` only), so the live wasm goes stale at the next pin.
2. **Every space in the code vanishes.** The visible text is the highlighted `pre`
   (the textarea over it is `color: transparent`, `:107`); the page's own tokenizer
   skips whitespace without emitting it (`:445`) and `highlight` concatenates the
   tokens (`:519-520`) — comments keep their spaces (one token), code loses them:
   `fnmain()withMemory+Alloc=`. The topology dots are measured from the textarea's
   real columns, so they land on the wrong glyphs (`m●p`).
3. **Diagnostics never get a line**: the regex expects `at L:C` while the wheel
   prints `at <stdin>:L:C-L:C` (`:872`); the runtime-offset is off by one (`:823`).
   Jump, "apply fix" and Tab-tighten are all dead.
4. **The Lens is telemetry**: seven `heap:` and one `arena:` stderr lines per
   compile render as diagnostics with `undefined` badges (`d.appl`, `:928`) — the
   screenshot's bottom panel; the "clean" state can never appear.
5. **The ring lags the wheel**: the facet parser (`:684-692`) knows neither
   `Topology:` nor `Lede:` nor multi-line answers, so E4's facets never reach the
   page — `verb SURFACE —`, `propose SOCKET` in the screenshot while the boot
   answers `Topology: the body the ~> governs at …` (measured on 09-all.mn:46:15).
6. **The brand is gone**: every colour token is a grey wearing a brand name
   (`--gold:#bbb`, `:14-25`; commit ffe271eb 2026-07-23 "strip the brand layer…
   per the founder's directive"), no font is loaded (`--mono: ui-monospace`), ~15
   hard-coded brand remnants survive, and `docs/DESIGN_SYSTEM.md` still specifies
   the full Okabe–Ito/Mentl Mono system — doc and build contradict each other.
7. **The loop is cold**: each keystroke (650 ms debounce) spawns a fresh 1 GiB
   worker and recompiles whole (188–465 ms measured in node); the resident session
   is used only for the caret read (4.8–8.3 ms, provenance intact — the one surface
   that is genuinely new). Five of eight demos warn about themselves
   (`T_RowInventory`, `E_RedundantBraces`); one claims "LIVE in this page" what the
   page cannot run; no line numbers, find, persistence, multi-file, reliable undo,
   or run.
8. **The gate cannot see any of it**: leg 1 drives the worker/session faces; leg 2
   only asserts that the boot compiled in the page. None of the page's product
   logic is measured — six breakages behind a green gate (PLAN §11 tripwire 4).

**Verdict.** The substrate is real and novel (the unmodified self-hosting compiler
in a browser worker, no backend; a resident session answering typed caret queries
with Reasons in ~5 ms; accept as a graph write). The visible surface is a prototype
that fails its own default demo in production and dropped its design system. It is
not at SOTA; the distance is almost entirely surface + wire work, and the gate
measures none of that layer.

### 1.2 Hosts, and the credibility claim

- The boot imports 20 things: 17 WASI p1 functions (incl. `poll_oneoff`,
  `sock_accept`), `mentl_host.wat_write`/`.exec`, a shared `env.memory`; no
  `thread-spawn` (the judgment spawns nothing). Nothing of Mentl is written in
  Rust: the compiler, judge, formatter, session, `space` file server and test
  driver are all `boot/mentl.wasm`.
- **The page needs no server.** Static files + COOP/COEP headers; the session is a
  worker over a SharedArrayBuffer (`ide/wheel-worker.js:286-351`); the runner is
  not involved. `mentl space` (`src/main.mn:370`) is a static file server written
  in Mentl over the runner's socket seam — dogfooding, not a dependency.
- **The Rust runner** (`tools/runner`, ~800 lines over wasmtime 47) is the CLI's
  HOST ADAPTER: shared imported memory, thread-spawn, exit codes, the exec seam
  (it parses the streamed WAT with wasmtime's own parser), and sockets
  (`-S tcplisten=` for `session`/`space`). A WASM module needs SOME host outside a
  browser; today it is this one. Stock `wasmtime` cannot host the boot (custom
  `mentl_host` imports; `-S threads` dropped at 47).
- **Two things sit outside Mentl**: assembling its WAT (WABT `wat2wasm` in the
  march/gates; wasmtime's parser in the runner; a trapping stub in the page), and
  sockets (runner only).
- **The Node host** (`573e8d27`): Node ≥ 20 + npm `wabt` (an external assembler
  binary), refuses `tcplisten`, threads broken by its own comment
  (`mentl-host.mjs:233-235`), validated against the OLD boot (its "149/149,
  crown 62/62" are `4a253a9a`'s counts; today 377 micros / 136 crown). Morgan
  rejected Node.

### 1.3 Muse's eight commits — verdicts (each measured)

| Commit | What | Verdict |
|---|---|---|
| `a852c1c7` `!E` "Branch A" (+40 effects.mn, +39 infer.mn, 2 crown files) | re-solves `Hβ.infer.declared-row-vacuous-against-a-free-body-row`, CLOSED 2026-09-27 (A3, pin 674154f6). **Measured on the pinned boot e7f6e2b9 WITHOUT muse's code:** `leak-hof-declared-negation` refuses `E_EffectMismatch` ("!E + Any vs E … declared as run at 9:13-9:28"); `sound-hof-declared-negation` exits 0. The leak fixture duplicates `tests/crown/leak-gate-vacuous.mn`. The cap masks a HOF param at the DECLARATION, blind to `~>` masks inside the body, so `fn run(f) with !E = (f()) ~> h` + `run(() => op())` is likely a false refusal (unmeasured — needs main's wheel). Catch-all `_ => ()` arms. Never marched, no PROVENANCE. | **REVERT the src changes whole; drop both fixtures (duplicates).** |
| `573e8d27` Node host + README | see 1.2 | **DELETE `tools/host-node` + the `wt-env.sh` fallback; re-true README** (`:9` overclaims, `:82` "no .github" is false, the soundness headline muse flagged → "sound for the claims it discharges") |
| `fcc02fe1`, `10bc47f4` Pages deploy | ships the page | **KEEP, FIX** (1.1.1) |
| `f75b7fbf` rename "Mentl Space" | title + wordmark | KEEP (`ide/README.md:1` still "mentl edit") |
| `464bad57` install.sh heredoc | real fix (an unquoted heredoc ran `` `mentl run` `` at install) | KEEP |
| `93d7bd19` + `2e73093f` Railway | added then deleted | net zero |

All eight: unsigned, pushed directly to an unprotected `main` under Morgan's
identity. **Protect `main` (PRs only).** Muse's handoff also records that Morgan's
Railway credentials were pasted into a chat — rotate that password (user-side).

### 1.4 Domains (RDAP, redirects followed)

Registered: `mentl.space` (GoDaddy, since 2021-11, expires 2027-11 — held by
someone else), `mentl.dev` (Name.com, registered 2026-06-05), `mentl.com`,
`mentl.org`. **Available**: `mentl.app`, `mentl.io`, `mentl.sh`, `mentl.run`,
`mentl.studio`, `mentl.codes`, `mentl.systems`, `mentl.ai`.

## 2 · Decisions (each asked "can we design this even better?"; Morgan's answers of 2026-10-05 folded in)

1. **Hosting — GitHub Pages stays; the site becomes self-describing,
   self-isolating and subpath-safe.** (a) ONE home for "what the site is":
   `ide/space.manifest` (the files the page fetches); `tools/space-stage.sh`
   stages `.build/space/` from it, and BOTH the workflow and the IDE gate's leg 2
   serve THAT artifact — a deploy omission is a red gate, by mechanism. (b) The
   page isolates itself: `ide/isolate.js`, a ~40-line service worker (no library)
   that adds COOP/COEP to every response AND caches the wasm + sources for offline
   use, so the page works on ANY static host (Pages, `python3 -m http.server`, a
   USB stick, a plane) and the Cloudflare Transform Rule becomes belt-and-braces
   rather than a dependency. (c) A missing file is a loud boot refusal, never
   `""`. (d) Every fetch is relative to the page (`./boot/mentl.wasm`, boot staged
   beside `index.html`), so the same artifact serves at a subdomain or at a
   subpath — ampactor.dev hosts its other projects at `/sonido`, `/perennials/`,
   `/noodles` (measured), and Mentl Space must not break if it ever moves there.
   (e) Deploy on every push to `main` that touches `ide/**`, `boot/**`, `lib/**`,
   `src/types.mn`. (f) The memory ladder starts at 4096 pages (256 MB) and grows
   (E3 made growth real) so phones and tablets can open it — measure. The
   even-better endpoint is named, not built: the prelude as a frozen image slice so
   the page fetches one wasm and no source (`Hβ.persist.module-image-cache`).
2. **Domain — `mentl.ampactor.dev`, nothing bought** (Morgan). One CNAME in
   Cloudflare (`mentl` → `ampactor-labs.github.io`, proxied), the Pages
   custom-domain field (a `CNAME` file in the staged artifact keeps it across
   deploys), the Transform Rule's host expression widened to the new host until
   the service worker makes it optional, HTTPS enforced once the cert issues; the
   old `space` CNAME retired after the switch. Its own origin, not a subpath: the
   isolation headers are per document, and the portfolio's own pages must never
   inherit COEP. (For the record: `mentl.space`/`mentl.dev` are held by others;
   `mentl.app`/`.io`/`.run` are free when there is money — no action now.)
3. **No Rust in the codebase (Morgan: "at all!") — the host is a stock engine
   and the medium owns everything else.** `tools/runner` (800 lines of Rust over
   wasmtime 47, 244 crates) and `tools/host-node` (Node + npm `wabt`) are DELETED.
   The CLI's host becomes the off-the-shelf `wasmtime` binary — an installed
   program like `python3` or Chrome, with zero code of ours in any language but
   WAT: the two imports no CLI defines are satisfied by two five-line WAT shims
   passed with `--preload` (`env` exporting the shared memory; `mentl_host` whose
   `wat_write`/`exec` are `unreachable` — a loud trap, as the browser's worker
   already does). THE MEASUREMENT COMES FIRST (this container's gates run on the
   built runner today; no stock wasmtime is installed; the v36.0.2 release is
   downloadable): can the pinned boot `check`/`compile` the wheel under stock
   wasmtime 36 LTS with `-W threads=y,tail-call=y` and the preloads; does its
   `-S threads=y` still host a spawning program (the frontier's 2× legs); what the
   current release (47+) dropped. The verdict chooses the pinned engine version
   for the gates and names any threaded leg a host cannot run. Then the seams
   leave the wheel: **the exec seam** — outside the browser, `mentl run`/`test`
   hand the compiled module to the host's process facility (the shim, bash: write
   the module, run it, answer its exit; one process per fixture again, ~+50 ms
   each, the honest cost until `asm` + native) and inside the browser to
   `WebAssembly.instantiate` — two hosts, one contract, no Rust; **the socket
   seam** — the session serves on stdio since E2 (the page and any editor own the
   process; LSP's native transport is stdio), `mentl space` is static files, so
   `lib/net.mn`'s p1 socket protocol, `space_run`, the shim's `/dev/tcp` path and
   the runner's trampoline all delete (verify `serve`'s transport first); the CLI
   runs cold over the warm image (a resident CLI session, if ever wanted, is two
   FIFOs — named, not built). After `asm` the boot imports WASI alone, so ANY
   engine hosts it — wasmtime, wasmer, wamr, node, the browser — which is the
   sentence the README gets to say; the terminal's final host is the native
   backend (Phase 10, `docs/NATIVE.md`), Mentl emitting an executable that hosts
   itself — "its own runner", literally, and the only form with no engine at all.
4. **`mentl asm` — the medium assembles its own output.** A WAT→wasm assembler in
   the wheel for the emitter's own dialect (measured on the boot's m2.wat: 72
   distinct instruction/keyword forms; the spawning programs' atomics ride the same
   table — the exact set is `mentl query src/main.mn "text (…"` over the emitter).
   One emit (text, the canonical diffable artifact and the fixpoint's oracle), one
   projection text→bytes. Payoff: in-page `mentl run` with zero externals
   (`Hβ.felt.ide-run-in-page` closes — the worker instantiates the bytes under its
   WASI shim); WABT leaves the march and every gate (`wasm-tools validate` stays an
   optional external cross-check); and **the fixpoint seal runs in the page** —
   boot → m2 bytes → instantiate → m3 → compare, the thesis as a live demo with no
   Rust anywhere. The deeper form (the emit writing bytes with no text round-trip)
   is named if the in-wheel assembly of an 18 MB module measures too slow
   (`Hβ.emit.binary-is-the-emit`).
5. **The IDE** — §2.7 (the design verdicts) and §3 (the form).
6. **Order** — Space first; `#159` parked (stashed by name, as L4a was) — Morgan.

### 2.7 · The design, aspect by aspect — what I would build, and why (Morgan: "would you have designed things this way?")

The test for each is the project's SUCCESS: credibility with the people who can
judge a proof (compiler and PL people, serious engineers, a DSP partner), the
thirty-second demo, and a developer living in it daily — not taste.

| Aspect (DESIGN_SYSTEM.md) | Verdict | Why |
|---|---|---|
| **The octopus mascot, She/Her, "Claude's cousin", five expressive states** | **No character in the product.** The octopus survives only as the MARK (a geometric glyph: favicon, wordmark) and in docs illustration. | A persona with moods ("delighted", "curious") is the chatbot era's move, and it contradicts the two laws the product stands on: "surfaces only what it has proven" and "never frame Mentl as AI/agent". No surviving serious tool has a character in the editing surface (VS Code, Zed, JetBrains, Lean's InfoView); the ones with mascots keep them in marketing (Ferris, the gopher). "Claude's cousin who learned to prove theorems" is a borrowed voice, not Mentl's. And a mascot is pixels carrying zero facts — the one thing the density law forbids. The founder's July directive already said "no mascot"; it was right. |
| **The octagonal `??` socket as a custom-font ligature (Mentl Mono, 17 glyphs)** | **The socket as a SHAPE in the chrome, yes; as a font, no.** Holes, focus rings on holes, the ghost-proposal container and empty states are octagonal (CSS/SVG). The text stays the two ASCII characters. | A custom typeface is a licensing and maintenance project that breaks in every other editor, terminal, diff and GitHub view — the SOURCE must render identically everywhere, or the page lies about the file. Verb glyphs get COLOR and weight, never fused ligatures, for the same reason. |
| **The chakana (Incan stepped cross) as the icon/grid grammar** | **Drop it.** The eight-aspect ring (an octagon with the eight aspects at its vertices, each in its hue) is the one brand geometry. | A sacred Andean symbol borrowed as "heritage texture" for a programming language reads as appropriation and tells a developer nothing; the octagon ring says exactly what is true ("the kernel has eight aspects") and is legible at favicon scale. |
| **Okabe–Ito palette mapped to kernel roles (gold=type, sky=verbs, blue=structure, green=computation, vermillion=boundary/hole, magenta=discipline)** | **Yes — restore it; it is the strongest decision in the doc.** Two corrections: every text pairing on obsidian is MEASURED for WCAG AA by a script in the gate (Okabe–Ito was tuned for white; `#0072B2` fails on obsidian and the doc's `#2A8FC2` is the start of that fix), and BOTH grounds ship in the IDE (obsidian + parchment, `prefers-color-scheme`), not parchment for docs only. | Color as a projection of the kernel is the whole idea: the July strip to greys did not neutralize the design, it DELETED the semantic layer (three greys for six roles — information thrown away). Colorblind-safe by construction is a credibility fact, not a style. |
| **Typography (Mentl Mono / Fraunces / Hanken Grotesk, the 1.25 scale)** | **JetBrains Mono for code with its ligatures OFF; one sans for chrome (Inter or Hanken Grotesk); Fraunces only for docs/marketing display. All three OFL, SELF-HOSTED under `ide/fonts/` — no Google Fonts at runtime.** Keep the scale, 1.5 code line-height. | Offline-first and "no externals" apply to fonts too; `ui-monospace` (today) resolves only in Safari, so the page currently renders in the browser's fallback. |
| **The three-layer layout (Canvas / HUD / Wavefront) and the Teach knob** | **Keep the skeleton; move the density INTO the canvas.** The right rail is the Ring + Ledger + Map (modes); the bottom is Why/trail/realities; the knob is the one density control. | The doc grows the HUD into "mission control" as you prove more; the better form is Tufte's: the facts live on the code itself (gutter, inline marks, overlays) and the rail is the full read at the caret. Panels do not scale; layers on the text do. |
| **"Maximum info density across all eight tentacles"** | **The ASPECT STRIP: at high Teach, each line's gutter carries eight 1-character cells, one per aspect in its hue** — graph (a type ghost present?), propose (a hole/proposal here), topology (a verb stage), row (the ambient-world glyph: hollow = required, filled = granted — a hollow with no filled twin IS the refusal), ownership (a consume/borrow), verify (✓ ◌ ✗ for proven/pending/refuted obligations), teach (the gradient's one next step is on this line), why (a Reason worth reading). Click a cell → that aspect's full read in the Ring. Low Teach shows only the row glyphs; off shows nothing. | Eight facts per line in eight characters, every one a live read of the graph — the densest honest surface a code editor can carry, and it maps 1:1 to the kernel. Aquascope's permission glyphs and Pernosco's provenance are the only comparable things in the field, and neither has eight proven dimensions to show. |
| **The Holographic Lens (ghost proposals at the socket, arrows cycle, Tab snaps)** | **Keep.** Translucent ghost text at the hole; a tie renders the computed question verbatim. | Hazel/Copilot ghost text with proofs behind it — the demo moment. |
| **Motion (surfacing, cursor breath, topology resist, tentacle reach)** | **Surfacing (220 ms ease-out-expo) and the Why-walk ink (300 ms) yes. Cursor breath NO. Topology resist NO.** | A perpetually animating caret distracts and burns battery for no fact; fighting keystrokes with an elastic snap-back is the projectional-editor trap (Darklang's users called it the worst part) — the formatter's canon appears on idle and save, never against the hand. |
| **Voice: two voices, substrate-honest vocabulary, no "AI/agent"** | **Keep, minus the persona.** Mentl's voice is precise second-person narration ("this path performs `Alloc` under `!Alloc`; two proven ways through"). | The vocabulary rule is a correctness stance; the wink and the "She" are not. |
| **The 8 px grid "because eight primitives", the eight-fold radial grid** | 8 px grid yes (it is the standard anyway); the numerology stays out of the docs. | A grid is good because it is a grid. |
| **The editor core** | **No third-party editor library (CodeMirror et al.).** The browser's textarea is a host facility like the DOM; everything above it is a projection the wheel already computes (tokens/spans, structure, references). Line numbers, find-by-edge (`query refs of`, `text`), native undo preserved (`setRangeText`, never `value=`), the trail for graph-level undo, a virtualized highlight layer for the wheel's 60k-line files. | A second parser in the page (Lezer) is the Carried-Truth violation; the whitespace-dropping bug is exactly what a second lexer breeds. |
| **Build/Run chrome (compile button, live/link-runtime toggles, ms/wat/fns/exit)** | **Delete.** Always live, always linked (the runtime is the prelude, never optional). The compile cost (`heap:`/`arena:`) is telemetry shown in the Trail at high Teach, never as diagnostics. "download .wat" → "download .wasm" and "run" after `asm`. | MENTL_EDIT §9 rejects the build/run mental model; the page had re-imported it. |
| **The eight demo strings in the page** | **Delete; the program list is `lib/tutorial/00…09` plus the developer's own drafts.** | One home — the tutorials already exist, their prose is graph content (the lede renders it), and the demos warn about themselves under the current rules. |
| **The IDE is itself a Mentl program (MENTL_EDIT §0)** | **Yes, and it is the architecture, not a slogan: the VIEW is a projection the wheel renders.** `mentl space` becomes a verb the resident session answers per input event (caret moved, text changed, accept, Teach changed) with the VIEW — a structured tree (the JSON the MCP gate already speaks) for the Ring, Lens, Ledger, Map, gutter marks, verb geometry — and the page's JavaScript shrinks to a host: the WASI shim, the SAB channel, the textarea, and ONE generic painter. Each panel's logic moves out of JS into `src/space.mn` one landing at a time; every intermediate ships. | One home for every projection (the wheel), three transports (the page, the CLI, LSP); the page can never lag the wheel's facets again; and the IDE becomes the second real program after Pulse — the tripwire says real programs find wheel defects, and this one is used every day. |
| **"Mentl Space" as the name** | Keep (the rename landed; `mentl space` is the verb). | Not worth a bikeshed; the URL carries the product name now. |

## 3 · The design — Mentl Space in its ultimate form

Laws (the three docs + MENTL_EDIT §9): every pixel is a projection of a proven
fact or it does not render; one graph, two operations at the UI layer — a widget
PROJECTS, a gesture DRAWS AN EDGE (Lean InfoView's RPC-handle contract, never
parsed prose); the projection never takes the keyboard away (Darklang's grave);
density scales with proof (the Teach knob), by LAYERING on the code, never by more
panels; no build/run split, no chat, no 200-item Problems panel; the page keeps no
second model of truth.

**THE VIEW IS A PROJECTION — the page is a host, the wheel renders the IDE.**
One resident session per page (the existing SAB channel, `ide/wheel-worker.js`
role `session`). `mentl space` is a VERB: each input event (caret moved, text
changed, accept, Teach changed, panel chosen) goes in as one line; the answer is
the VIEW — a structured tree (the JSON `src/mcp.mn` already speaks) carrying the
Ring's eight facets with spans and provenance, the Lens (the ranked teaching
step and the diagnostics with their addresses), the Ledger bands, the Map, the
gutter cells, the token spans and the verb geometry. `src/space.mn` computes it
from the reads that exist (`CursorView`, the diag bank, `audit`, `where`,
`query`, `why`, `verify`) — the page's product logic moves there, one panel per
landing. The JavaScript that remains is a host: the WASI shim, the channel, the
textarea, and ONE generic painter keyed by element id. The CLI's stdio session
and the LSP are the other two transports of the same projections. A facet the
wheel grows reaches the page by construction; every regex parser in the page
deletes. (The structured register of the CursorView is this view's first panel,
not a separate landing.)

**THE CANVAS (center).** A plain textarea (the host's text facility — keyboard
never taken) under the wheel's OWN token/span projection (one lexer; the JS
tokenizer deletes; the render slices the source at the wheel's spans, so a space
cannot vanish by construction), virtualized to the visible lines. Line numbers;
find by edge (`query refs of`, `text`); native undo preserved; the formatter's
projection on idle (`mentl fmt` — canon always, once
`Hβ.format.render-totality-before-fmt` is checked). Overlays, each a read of the
graph: the five-verb spines/enclosures from the Topology facet (`VerbFrame`),
never a regex on leading glyphs; **the aspect strip** in the gutter (§2.7) whose
row cell is **the ambient-world glyph** — hollow = this line REQUIRES the effect,
filled = the ambient world GRANTS it, a hollow with no filled twin IS the refusal,
drawn before the call is finished (Aquascope's glyph, PLAN §11 Arc G); the
row-flow tint along chains (`absorb_row` at each `~>`); refinement obligation
marks (✓ proven · ◌ pending · ✗ refuted) at their sites; the amber ownership trace
that drains on consume; the socket's **Holographic Lens** at a `??` — the proven
survivors as translucent ghost text in an octagonal frame, arrows cycle, Tab
accepts through `mentl accept` (a graph edge first), a tie renders the computed
question verbatim. Two grounds (obsidian, parchment) by `prefers-color-scheme`;
the Okabe–Ito roles; self-hosted OFL fonts (§2.7).

**THE RING (right, top).** The eight aspects at the caret, all eight REAL from E4's
projection — Query, Topology, Handler/Propose, Effects, Ownership, Verify,
Teach, Why — each row a door, the provenance contract kept visible
(surface · declared · real · socket).

**THE LEDGER (right, ambient).** The module's inferred rows, obligations
(`verify`-class debt), armed refusals, and the capability bands — reads of
`audit`, `query performs`, `where`.

**THE MAP (the whole-program altitude — a rail mode).** The **Severance Map**
(Arc G): the module/decl tree banded in THREE colours — provably absent /
present / NOT YET PROVABLE, the third COUNTED and ratcheting to zero — select a
subtree and it states the minimal sufficient capability set with the cut line
where the `~>` goes; the thirty-second demo is adding one networking call and
watching a green band turn red with the Reason. The **cursor neighborhood**
(the node, its typed edges and Reason edges within N hops) drawn OVER the canvas
by source position — layout is projection, no hairballs — and a node-and-edge
field only at module altitude. `query` facets as live lists: `refs of`,
`unreachable` (partitioned as the verb partitions it), `ghosts`, `smt`,
`performs`, `modules`, `provider of`, `writes of`.

**THE WAVEFRONT (bottom).** The Why walk as provenance ink with trivial hops
elided (Pernosco); the trail (undo is a trail walk, across projections); the
realities (the fan's survivors; the fork tree when the fused search lands); the
fixpoint seal in motion once `asm` lands.

**RUN · SESSION · DENSITY.** In-page `mentl run` via `asm` (decision 4); later
fill-and-resume (band B). Session-as-image: save/open the session — the IDE's
state is a value (persist = memcpy is real). The Teach knob scales gutter,
overlay and ring detail. The visual system is ONE committed system with loaded
fonts and a type scale — brand restored per DESIGN_SYSTEM.md or a deliberate
neutral (asked); DESIGN_SYSTEM.md is trued in the same landing, one home.

**MEASURE.** The IDE gate grows to the page's product logic: render fidelity
(`hl.textContent === textarea.value`), the default demo compiles on the STAGED
site, no `undefined` in the DOM, every facet line has a row (type-checked by the
structured wire), a tie renders the question, accept at a single-answer hole
writes the text, a screenshot per board for the record (headless Chrome).

## 4 · The sequence — one landing, one board; a pin only when the wheel moves

*Status at 2026-10-06: L-A LANDED `31d56a2e`; L-B LANDED `2c229893`; L-H LANDED
`30b43db4` (pin `2175e015`; wasmtime pinned at 36.0.17 by `a34c9d27`); L-C LANDED
in the working tree (pins `d956687d`, `c8ba5799`); L-D, L-E and L-F are open and
sequenced in the head section's §7.*

- **L-A · Hygiene (no wheel change).** `git stash push -m "#159 capture at every
  position"` (src/{cursor,graph,lower,types}.mn); merge `origin/main`; revert
  `a852c1c7`'s src + its two fixtures; delete `tools/host-node` and the
  `wt-env.sh` fallback; true the README (1.2/1.3: the medium is one wasm module,
  the browser its primary host, the terminal's host an installed engine, nothing of
  Mentl in Rust; `:82`'s "no .github"; the soundness headline) and
  `ide/README.md:1`; `bash tools/doc-truth.sh`; push. Ask Morgan to protect `main`
  and rotate the Railway password.
- **L-B · The page works in production, and looks like the design.**
  `ide/space.manifest` + `tools/space-stage.sh` + the workflow on the staged
  artifact (+ `CNAME`) + `ide/isolate.js` (isolation + offline cache); the gate's
  leg 2 serves `.build/space/` (a 12-line python3 static server with the two
  headers — python3 is already a gate dependency); relative fetches; loud boot
  refusals; the memory ladder from 256 MB; the breakages fixed at their roots
  (spaces → render by slicing the source at token offsets; the diagnostic address
  regex + the runtime offset; `heap:`/`arena:` classified as cost, never
  diagnostics; `Topology`/`Lede`/multi-line facets as the interim before L-C;
  the build/run chrome deleted; the tutorials as the program list, each
  fmt-canonical with zero self-warnings, one with a single-answer hole; the
  "LIVE" overclaim removed); the semantic palette, both grounds, the self-hosted
  fonts and the type scale restored from DESIGN_SYSTEM's tokens, no mascot, no
  custom font, the octagon only as the socket's shape; the contrast script in the
  gate; the gate's product legs (render fidelity, the default program compiles on
  the staged site, no `undefined` in the DOM, every facet line has a row, a tie
  renders its question, accept at a single-answer hole writes the text, a
  screenshot per board). Rename landed; `mentl.ampactor.dev` CNAME (user-side,
  with my exact Cloudflare + Pages steps written in the landing's notes).
  DESIGN_SYSTEM.md and MENTL_EDIT.md trued to §2.7 in the same landing (one home).
- **L-H · No Rust in the codebase (a wheel landing).** The measurement first
  (§2.3): stock wasmtime 36 LTS + the two WAT preload shims hosting the pinned
  boot for `check`/`compile`, `-S threads=y` for a spawning program, the current
  release's deltas; the verdict pins the gate engine. Then: the exec seam leaves
  the wheel (`run_run`/`mentl test` hand the module to the host's process facility
  — the shim outside the browser, `WebAssembly.instantiate` inside — one
  contract), the socket seam deletes (`lib/net.mn`, `space_run`, the `/dev/tcp`
  path; `serve` verified first), `wt-env.sh`/`install.sh`/`verify.sh`/`march.sh`
  on the stock engine, `tools/runner` deleted with every runnable citation of it
  (doc-truth checks named commands), RESIDUE's runner peers closed or re-homed;
  the full board + march + repin.
- **L-C · The view is a projection.** `src/space.mn` + the `space` verb's
  event→view answer over the session; the page's painter; the Ring, Lens and
  Ledger move first (their JS deleted); compiles through the session's living
  check instead of a fresh worker per keystroke (measure;
  `Hβ.session.edit-pays-for-the-program`). A wheel landing: board + march + repin.
- **L-D · The canvas.** Tokens/spans from the wheel (the JS tokenizer deleted);
  virtualized highlight; line numbers; find by edge; fmt on idle; verb geometry
  from `VerbFrame`; the aspect strip and the ambient-world glyphs; obligation
  marks; the ownership trace; drafts persisted; the trail as undo.
- **L-E · The map and the ledger.** The Severance Map with the three-colour law
  and its count on the board; the cursor neighborhood overlay; the ledger bands;
  the Why walk with trivial hops elided.
- **L-F · `mentl asm` + in-page run.** The assembler (a wheel landing: fixtures
  RED-first — the boot's own m2 assembled by the wheel instantiates and compiles
  the wheel to the same bytes `wat2wasm` produces); the worker's run role for user
  programs; WABT out of the shim, the march and every gate; the fixpoint seal on
  the page; "download .wasm" and "run".
- Then `#159` resumes (`git stash pop` by name).

## 5 · Verification

Every landing: `mentl fmt` on edited `.mn`, `mentl check src/main.mn` at zero;
`bash tools/ide-gate.sh` (both legs, on the STAGED site from L-B on, with the
product legs); `bash tools/doc-truth.sh`; `bash tools/state.sh`. Wheel landings
(L-H, L-C, L-F): the full board + `MARCH_REPIN=1 bash tools/march.sh` + records
(PROVENANCE, LEDGER with kills, PLAN §7, RESIDUE, SYNTAX where the surface moves).
L-B's proof: `curl https://mentl.ampactor.dev/lib/prelude.mn` → 200 and the first
tutorial compiles in the deployed page (the gate's leg 2 on the staged artifact is
the same proof before the push), plus the screenshot in the landing record. L-H's
proof: `git ls-files | grep -E '\.rs$|Cargo'` empty, and the board green on the
stock engine with no `tools/runner` on disk.

---

# Mentl — the program from pin 2974547b onward

`docs/PROGRAM-2026-09-25.md` holds every track with its measured basis. This
file is the execution order and the design of the next landings, sequenced by
foundational depth: the soundness spine first (it is the moat — PLAN §1(b)),
then the surfaces that read it.

## P0 · A REFINEMENT IS A FACT A VALUE CARRIES, NOT A PROPERTY OF ITS CLASS (2026-10-01, LANDED at pin e23392f6b1232f84 with P0·H — the first march refused at proof-exactness; function values carry their contracts along edges and a `|>` stage claims; the merged-function face (4) closed at H4, pin 1a68ecc0eef48ab1)

Found on D4's felt walk; preempts D4 (the gradient proposing `n: Positive`
would launder Trap into invisible debt). Measured on boot 13e8484a, each
`with !Trap` checks clean and traps at run (scratchpad d4/p1..p9):
p2 arith result (`dec(x: Positive) = x - 1` typed `-> Positive`, zero debt);
p7 join (`let d = if c { n } else { 0 }` typed Positive, zero debt);
p5 open let claim; p6/p8 open postcondition relied on by a caller;
p4 open arg claim at a guarded param (`inv(m + 1)`); p1 sibling over-demand
(`ratio(t, n: Positive)` types t Positive — RESIDUE's higher-order face (2)
called it "sound, over-demanding" and missed the RESULT face); p9 merging
function values loses the stronger precondition (`if c { inv2 } else { inv }`).
ROOT: refinements ride the union-find class; any merge (join) or mint
(arith) launders them. The compensations confess it: `value_flows_class`,
the interval fragment's "two faces / contamination law", "constraint FIRST",
the let rebind ("the class exposes its most-refined member").

DESIGN (one law: the class carries SHAPES; a refinement is read along the
value's flow edges; a precondition carries the row it guards):
1. `graph_bind` writes `shape_of(ty)` — refinement wrappers stripped at value
   positions; TFun interiors are CONTRACTS and kept whole (types.mn).
2. Param facts column (graph.mn, trailed `MParamFact`): param handle →
   {contract: Option(Ty), guard: row-var handle}, noted by build_param_types
   for every declared-fn param (contract = the authored refinement, or None).
   The walk reaches a param through the VarRef's own link (new read op
   `graph_link_of(h)`: NBound(TVar(b)) → b, no chase).
3. TParam gains a 6th slot, the param's ROW (`param_row`): the row the
   precondition guards — first face of `Hβ.types.param-projects-to-type-row`.
   Declared params: `mk_ef_open([], g)`, g minted at prereg and REUSED by the
   judgment (read off the prereg TFun); lambdas/mk_param: pure. NOT unified in
   unify_param_lists (a call's expected params are built from use with no var
   to adopt into); F8 stays the higher-order peer's.
4. The walks (verify.mn), one Domain walk with a trust flag:
   `value_domain(h, bind, strict)` — literal point; VarRef → link → param
   contract (ty_domain) | let value (recurse) | module let const | self bind;
   if/match/block → hull (DFinite∪DRange → range hull); BinOp/Unary → constant
   fold only in STRICT (no interval arithmetic for row facts — the Add fold is
   overflow-blind, see peer), lo_add kept for claims; Call → len/byte_len
   [0,∞); declared return contract only when !strict. `node_lo_tr` becomes
   domain_lo of it; node_lo_op / ty_lo_at / type_excludes /
   refinement_pred_of / ty_refinement / value_flows_class /
   inferred_alias_name DELETE. `value_carries_alias(h, a)` replaces the
   echo-stop (pure flows + joins-all). `value_leans(h)` → (params reached,
   rests_on_postcondition) for transport.
5. infer.mn: apply_refinement_constraint RETURNS its verdict; the let
   annotation's rebind deletes; the return claim moves before exit_frame;
   partiality_claim on a proven claim charges Trap into the guard of every
   param the divisor/dividend leans on; discharge_arg_refinements (and the
   partial's supplied args) charge `param_row(p)` at the call node unless the
   claim held strictly (Some(true) and not resting on a postcondition), else
   transport the callee's guard into the leaned params' guards; a direct
   VarRef to an UNcontracted declared param INFERS the contract (precondition
   inference, explicit — the wheel leans on it); fun_refinement_crossing
   charges the passed fn's param guard where the demand is debt. At exit:
   TParam ty := the column's contract (inferred ones publish), a still-free
   guard var binds pure.
6. Synth: a hole's refinement comes from the claims raised over it (measure
   tests/proposals first; fix only what breaks).
FIXTURES (RED on 13e8484a): p2/p4/p5/p6/p7 refusals under `!Trap`, p1
accept (`ratio(0, 5)`), p9 refusal of the merge if guards differ — decide
after measuring. Existing: mn-verify-interval (one pending), mn-refine-*,
mn-refine-join-launder (banked red, register it), crown.
PEERS TO NAME: `Hβ.verify.interval-fragment-assumes-unbounded-int` (lo_add
proves `0 <= v + 1` while the i32 floor wraps at INT_MAX — pre-existing,
the fixture canonizes it); `Hβ.verify.row-facts-trust-proven-postconditions`
(strict mode never trusts a postcondition; the design: a verdict column by
the callee's row handle + the call's strict-precondition note);
`Hβ.verify.provenance-through-destructure` (pattern binders / index / field
read no facts; no real code nests a refinement today).

## Context

- **Where the cursor is (2026-09-27).** The soundness spine through A5 and
  the Pulse sprint's foundation — L0 (a held resume reified, multi-shot
  priced), L1 (arithmetic demands a number, at the judgment) and L2 (the `<~`
  line is a ring owned by its record) — are committed and pushed on
  `claude/mentl-design-audit-m1mptf`. The boot is `43aeb30f` (TRANSITION
  m3 == m4, micros 157/157, frontier 414/0/2, crown green, board whole).
  L3, Pulse scene 1, is IN PROGRESS (LANDED since: commit `681379b4`, pin
  `730e097a`, and the whole sprint after it — the table below). The felt walk ran before plan mode and
  found three wheel defects and a Verify gap that the fixes must carry in
  this landing (Step 7, L3 · as found). The next action is finishing the
  parser's half-converted free-use walk.
- **Why the walk matters.** L3 is the first program in Mentl that is not the
  compiler. Every wheel defect it found is silent to the board, because the
  wheel never captures a ground Float, never matches on a Float, and never
  runs `compile` after `run` (PLAN §11 tripwire 3). Each such defect becomes
  a fixture RED-first. The medium's claim that a program which checks clean
  also assembles is false at two of them today.
- **Why this order.** PLAN §0's property (2) — the negative is provable — is
  the one claim no competitor can make (§1(b)), and it is FALSE today at three
  shapes: a declared `!E` over a free body row is vacuous
  (`Hβ.infer.declared-row-vacuous-against-a-free-body-row`), the executable
  root gate credits an install anywhere (`fn main() = op() + ((op()) ~> h)`
  compiles and traps), and the wheel's authored positive rows are inventories
  that under-count callbacks. Fixing those three, in that order, is what
  makes every surface built on rows (the Severance Map, the proposer's row
  pruning, `!Flow`) a projection of a proof rather than of a guess.
- **Morgan's direction.** Design and build the medium cohesively, faster, with
  every landing pushing the envelope; the dispatched model at max effort for any
  dispatched agent — and when the dispatched model is rate-limited (it was, twice), no other
  model is dispatched and the adversarial pass runs inline, recorded as such;
  never attribute Claude in commits; push only to
  `claude/mentl-design-audit-m1mptf`; no PR unless asked.

## Where the program stands (2026-09-27)

| Step | State | Commit / pin |
|---|---|---|
| 0 · mask pin | LANDED, pushed | `fbe8f3c3` / boot `2974547b` |
| 1 · A3 negation gate on the cell | LANDED, pushed | `61d83764` / boot `674154f6` (crown 89/89, 36/36 lens probes) |
| 2 · root gate reads the row alone | LANDED, pushed | `0d90d6e9` / boot `bbc0cc2c` (crown 94/94; four latent wheel traps restructured) |
| 3 · C2 + B1 + E3 | LANDED, pushed | `67be33d0` / boot `a25144cf` (CLEAN; board whole, IDE gate green on the boot itself) |
| 4 · A4 | LANDED, pushed | `a089c890` / boot `d27fc81d` (CLEAN; T_RowInventory + open-row arm; tighten writes the residue; CsAuthoredPositiveRow at 0, seen RED at 164; 1,490 medium-authored patches; zero fallout; `Hβ.infer.ground-differs-by-route` named) |
| 4 · A3-pos | LANDED, pushed (declared_gate installs the closed row; crown 96/96 with leak-cap-callback/sound-cap-admits; two micros lost their `with Abort` caps; wheel untouched) | `b119f135` / boot `b145b836` |
| 4 · F0b | LANDED (E_MissingImport at the reference, armed at zero; the env-entry design refuted by the wheel and replaced by the decls-column table; the solo sweep + `solo_violations_max` deleted; found and closed on the way: the tuple-decomposition unify rule the emit never carried — now a refusal, `E_FnArityMismatch` armed; the proposer's stale-module mints; the warm cone judged under paths; the runner's silent trap exit) | boot `39b00d84` (CLEAN; frontier 407/0/2, crown 96/96, micros 149/149) |
| 5 · A5 | LANDED (the handler's `with` row parsed and carried — the parser had skipped it since the seed; judged at registration like a fn's and, per install, the tee body's row minus the handler's absorption against its negation; the boundary world is the remainder union off marked frames; the per-op join refuted before a line; crown 100/100 with leak-arm-resume-remainder RED-first) | boot `83428bcc` (CLEAN; frontier 407/0/2, micros 149/149, IDE green) |
| 5 · A6 | designed (Step 6), sequenced AFTER Pulse scene 1 and the projection (Step 7) | |
| 7 · Pulse | REDEFINED 2026-09-27 as "the effect that learns"; my first mechanism REFUTED by the dispatched model's pass; four foundation defects found; sprint L0–L5 (Step 7) | |
| 7 · L1 | LANDED in its SECOND form: the numeric demand is a gate on the type cell (`NumericGate`, A3's mechanism one sort over) — judged at the operator, carried by a free cell, checked at unify's var binds, copied at instantiation, reached through the instance column; `E_ArithOnAggregate` armed at birth and refused by `mentl check`; nothing decided at emit. The first form (lower + emit classification, `T_ArithTypeUnprovable`, a post-emit gate) passed every gate and repinned at 1ff80ffb, then was killed three times by the artifact (check accepted the programs; the "zero" was read off the L0 boot's m2.err; the wheel narrated `lo_add`'s floor twin) and deleted whole; peak ceiling 1,042,000 → 1,058,000 with the fixed-input measurement | pin 542ea5a353823b76 |
| 7 · L2 | LANDED: the `<~` line is a ring `[head][slot × depth]` in the image owned by the record of the function that holds the cycle (`LineHome`: a closure past its captures, an install past its arms, a k past its tail; a top-level fn's site rides an instance global `$__init_lines` fills, one per emitted twin); four micros RED on 542ea5a3 (twin-width, closure-instances, arm-instances, deep-line) + the frontier's timed deep-line leg (2M ticks at depth 24,000 in ~20 ms); the arm/remainder refusal killed at the install layout; the k-owned line has no witness (let-bound multi-shot performs are off-spine); TRANSITION, the wheel's one site the whole 25-line m2/m3 diff | pin 43aeb30f3bcc3848 |
| 7 · L0 | LANDED (ResumeUse; held single resume reified; tail-transparency proof; MultiShot op row carries Memory + Alloc at prereg; 3 fixtures RED-first; 12 caps dropped; cost ratchet refused the first proof form, fixed; pinned twice — ae288fea on the source as edited, 5bf55b68 after the pre-commit fmt rung canonicalized two files) | boot `5bf55b68` (CLEAN; 1,032,440 KB; frontier 407/0/2; crown 100/100; micros 152/152; board whole) |
| 7 · L3 | LANDED: Pulse scene 1 renders through `mentl run` (zero heap growth, `!Alloc + !Sample(44100)`); ten silent wheel defects fixed with fixtures (captures, float match, two-face table, instance dedup, join decide, fn-crossing refinement, warm world key, brace_form, record render, DSP makers); two more caught by gates on the way: fmt deleted authored names (conservation gate; op params are TParams; repr position rule) and the occurs check walked row PATHS (visited table; judgment 565 → 314 MB, peak 1,049 → 815 MB); `T_ShowTypeUnprovable` + `show_type_unprovable_max: 22`; board whole | commit `681379b4` / pin `730e097a2531522c` (TRANSITION; second march after the paren strip: same sha) |
| 7 · L4b | LANDED at pin `16286d94fe225527` (CLEAN m2 == m3; the first march REFUSED at the cost ratchet, 980 MB, and the census found `ty_has_wide_seq` path-local and asked at every `++` — one fact per nominal type now, −134 MB on the same source, ceiling 832,000 → 859,000; the second refused on one stale backticked `seen` in a leftover comment): one linear program (`Lin`, `Beside`), two projections — forward byte-identical to the boot's emit but for the mode comment and one local per query; reverse: the primal first with tests and scrutinees as residuals, each query a backward sweep to the seeds, adjoint twins `sym$vjp<key>` recomputing the callee and handing adjoints back through `$__da{j}`; product seeds (record/tuple of Floats, one lane per field), the gradient read by destructuring; mode by cost, refusals naming `Hβ.derive.vector-forward` / `.gradient-as-a-value`; seven micros RED-first, frontier `derive-grad` 36/36 + `derive-grad-series` refusal; kills: `Stmt` name collision, tail choice bound to a local, seed destructured at the extent read whole, uncalled JVP twins emitted, the distortion 2-seed leg refused (series recurse), `CExpr` dead | micros 250/250, crown 102/102, frontier 449/0/2 |
| A7 | LANDED at pin `4bc108088fa73607` (CLEAN m2 == m3): the judged row writer is an INSTALL — `RowWrite` its own effect, `row_gate` innermost at every judgment chain, the wrappers deleted; seen RED at 90/102 crown uninstalled; `adv-mask-two-callers` the three-walks witness; the floor's prose references resolve in the floor alone; m3 leg 842,900 KB (down from 848,160) | pin `4bc108088fa73607` |
| C4 | LANDED at pin `21f8e691f6e04426` (CLEAN m2 == m3): the accept is a GRAPH WRITE and the text its projection — `Accepted(text, proof, inner)` on `Reason`, `graph_accept_note` into a position-keyed column of `graph_handler`'s state read by `graph_bind` at the one writer, `accept_fill` the one home (the session's `y` and the new `mentl accept <path>:<line>:<col>`), the page's Tab routed through the wheel over a write-capable worker vfs; the Why at the accepted position walks to the proposal; IDE twin leg 6 + two frontier legs RED-first on boot 4bc10808; one kill (the per-module check walk's generation was unaddressable — patches re-derive through the one weave read); named: `Hβ.synth.accepted-edge-keyed-by-position`, `Hβ.felt.accept-outlives-the-process`, `Hβ.felt.edit-session-reads-one-action` | pin `21f8e691f6e04426` |
| C5 | LANDED at pin `b1637650e3cd3157` (CLEAN m2 == m3): partiality is a row fact — Int `/` and `%` raise `PTotalDiv` at the site, Verify's fragment decides it from constants, module constants and the divisor's refined type asked at the fatal point (`SelfBind`; `Positive` excludes 0 and -1, `NonZero` 0), the ledger ANSWERS its verdict (`verify -> Option(Bool)`; the site narrates a refutation through `verify_claim`, the raw op's one caller), an open claim charges `Trap` (`effect Trap {}` in the prelude, born into every intern table), every charge is noted on its node (`inf_add_row_at` / `graph_row_note`, trailed) and `row_of_subtree` folds them for the e-graph's `is_pure` (`body_is_pure`/`effs_at` deleted; `Hβ.egraph.per-expr-effect-row` closed as a read); seven micros RED-first on 21f8e691 + the frontier's `absorb-keeps-trap` (`run_open_claim`: V_Pending asserted, exit 134); lib/dsp's six divisions proven by `Positive` on the parameter after the crucibles' caps met `Trap`; the wheel clean with five path-guarded open claims; kills: the ledger arm's report escaped the battery's capture (site narrates), fmt wrote a keyword binder as `_`, the absorb leg counted its own V_Pending as debt; named: `Hβ.verify.partiality-reads-the-path-narrowing`, `Hβ.effects.index-partiality-is-a-row-fact`, `Hβ.effects.divergence-is-a-row-fact`, `Hβ.fmt.keyword-binder-renders-as-wildcard`; prelude floor 2796 → 2805 | pin `b1637650e3cd3157` |
| C6 | LANDED at pin `2fcad4e9e7f987f5` (CLEAN m2 == m3): the computed question is read off the trail — `graph_written_since(cp, below)` (GraphRead: the MSetNode / MSetRow cells since a checkpoint below the enumeration's frontier, a slice view), `context_writes` snapshots each cell's meaning inside the segment before rollback, `SegmentVerdict` carries them out, `keep_survivors` seals the proven candidate (`EnrichedCandidate.writes`), and `divergence_of` reads the first cell two survivors bound differently before the term arms — `DivType(Ty, Ty, Reason)` naming the cell through its Reason, `DivRow` at a row cell; facts compare by alpha-equivalence; `mn-type-tie` ("differ in TYPE — Int against String") and `mn-cell-tie` ("the cell that moves: return of pick") RED-first on b1637650 as value questions, the four standing ties unchanged; `proposal_node` / `indexed_value` deleted; `Hβ.synth.divergence-from-the-trail` CLOSED with its boundary (a finalized declaration's row is a scheme value; in-segment handles collide) | pin `2fcad4e9e7f987f5` |
| C7 | LANDED at pin `6f2ce4378786e53f` (CLEAN m2 == m3): the proposal battery — `mentl test` reads `// propose L:C: fill <text> | ask <arm> | none` (`ExpectPropose`, `ProposeWant`) and judges the Verdict at the hole structurally (`battery_verdict` through the address route, `verdict_meets`, `divergence_arm`); `tests/proposals` × 24 (one per enumerator / divergence arm / proposal landing), the frontier runs it via `wt_battery`; found on the walk: fielded constructors refused as partials (a minted hole in argument position is a value — `Box(??)` fills, `Option(Int)` asks `None` vs `Some(??)`), structured candidates rendered `??` (the formatter's token projection now; `Hβ.felt.candidate-render-is-format` closed), nullary-constructor ties asked shape (`DivVariants`), an empty verdict printed nothing (said at an authored hole); kills: `DVariants` on `Domain` refused by the fragment's combinators, the battery's module-path miss, the effectful-lambda ratchet paid by `collapse_equivalent`'s reference; named `Hβ.synth.linked-ring-offers-substrate-internals`, `Hβ.infer.arm-body-cell-is-free-at-propose` | pin `6f2ce4378786e53f` |
| B4 + C9 | LANDED at pin `477bb667dfab178d` (TRANSITION m3 == m4; m3 leg 862 MB under the 890,000 KB ceiling, moved 873,000 → 890,000 with the fixed-input justification): the schedule reaches a callee's fanout by demand through direct calls — schedule twins keyed by instantiation + letter (`enc_sched`, `nested_twin`), the site's installed schedule noted at the lowering (`site_schedule`, `Option(Schedule)` on the fanout node), `fanout_reach_names` the one reach rule with the declared `!Thread` as its gate, construction keeps every form's callee live (`fanout_form_note` / `fanout_form_drain`), the race rule walks from a spawning caller into callees with row pairs (`race_check_demands`); `fanout(f, xs)` declared in the prelude as `map` and lowered as the fanout node (`lower_global_call` / `completed_call`); C9 `segment_verify` as `candidates |> fanout(...)`; found + fixed: the task record carried the spawn ARM's world (`$perform_world_g`); seven fixtures RED-first on 6f2ce437 (14 / 12 / 3 / 1 / refuse / 10 / 14), all green through m2; the cost ratchet refused twice (sugar vocabulary 41 → 45, peak 924 MB) and the fixed-input probe plus per-step plan marks put the last 22 MB in the emitted reach — the whole-program reach walk asked by the driver's resume block under `persist_to_disk`, replaced by the per-name `fanout_reach_of` (its first form re-walked cycles exponentially, 4.3 GB), the race walk gated on a noted threaded site, the reach's own `heap:` line; kills: the primitive `fanout` (the boot cannot compile a wheel naming a primitive it lacks), the unseeded demand, the Seq-governed inherit, the floor-named nested lambda, the unreachable form callee | pin `477bb667dfab178d` |
| S2 + R1 | LANDED at pin `9387fea1990ef23f` (TRANSITION m3 == m4; the wheel moved only in handle numbers, +111 from handle 176,790): a held resume re-drives through the record it drives (`PdDriver(name, record)`, `resolve_hrec`, `disc_redrives` binds the ladder in every re-driving arm) — five re-yield micros RED-first on 477bb667 (addresses / traps) → 22, 22, 22, 22, 200; and a held resume PERFORMS its continuation's world — the handler's remainder-world cell (`HandlerKind`'s second field, minted at prereg, in the frame signature, cut from the residual by `inf_cut_edge`), callees gate it through the callback's row, every install judges it by `remainder_gates_check`; `spine-callee-alloc` retired from frontier_expected_red, crown 104/104 with `leak-resume-remainder` RED-first; S1 (the instance pin) retracted as a soundness hole — a capability, design question banked; named `Hβ.effects.remainder-row-is-flow-insensitive`, `Hβ.continuations.escaped-resume-carries-its-world-free`, `Hβ.lower.twin-key-is-a-product` | pin `9387fea1990ef23f` |
| P0 + P0·H | LANDED at pin `e23392f6b1232f84` (TRANSITION m3 == m4; m3 leg 934,912 KB under the 954,000 ceiling): a cell holds a shape and a refinement is read along the value's edges (`value_leaves`); a parameter's refinement is a precondition whose guard its open callers pay; every claim noted on its value (`claims` column); destructuring an edge (`PartFact`); the `!Flow` label an influence read; then, forced by the first march refusing at proof-exactness (21/5), a lambda's and a function-typed parameter's contracts learned along edges, and the `|>` stage a claim site (`0 |> inv` under `!Trap` had divided by zero on both trees); crown 116, frontier 482/0/1, micros 269/269; the wheel's open obligations 25 → 34; open: merged function values (face 4), provided-vs-demanded conflation (face 5) | pin `e23392f6b1232f84` |
| H4 | LANDED at pin `1a68ecc0eef48ab1` (TRANSITION m3 == m4; m3 leg 978,500 KB, m4 975,132 KB under the 985,000 ceiling, moved 954,000 → 985,000 with the fixed-input justification — boot 963,944 KB vs candidate judgment +7.4 MB): a function value is every function it can be (`fn_leaves`), one home for what an application owes (`call_owes`); provisions are edges to the values handed (`PProvides(Provided)`), never the function's demand; a function at a part of a parameter teaches the parameter's contract at the path (`with_fn_at`, `cross_parts`); the channel through a generic callee's declared signature (`channel_at`), nominal types included (`PartTypeArg`); a generic call's result read off its arguments (`result_leaves`); what the body cannot see is handed on (`hand_on_value`, `value_fn_positions`); the completed pipe stage carries the pipe's handle (lower). Kills: the max_by occurs check, one-node provisions, ProvidedAny's ⊤ absorbing `inv` (d13), the class read of variable parts (d14), a frontier green measured on the boot, the cost ratchet (+14.7 MB first form), the first repin stopped at 213ec3ec and restored (seven escape sites, one rule), the deep-chase hand-on, the class fallback for provided values, the +11.0 MB nominal first form. Micros 300, crown 124, frontier 486/0/1; six imprecision peers + the tuple-index gap named | pin `1a68ecc0eef48ab1` |
| S4 | LANDED at pin `53f7404bedfa0208` (TRANSITION m3 == m4; m3 leg 973,068 KB, m4 976,768 KB; ceiling 985,000 → 995,000 on the fixed-input reading — boot 975,036 KB vs candidate 978,744–984,892 KB, judgment +1.5 MB): a structure is claimed part by part where it is built, as P0 assumes it part by part where it is taken apart — `cross_parts` the meet of function crossings and value-part claims (`value_parts`, `claim_value_part`, `part_nodes` in sight with `learn_precondition`, `path_leaves` out of sight), `pay_guard` on the parts' leaves (`claim_leaves`); nominal contracts at their constructors' fields grounded at the arguments (`ctor_field_contract`, `argument_fields`; `variant_named_specs_at` moved lower → types); `IndexExpr` a part read; `constructor_named` reads the env; the emit's nested record literal answered the inner's pointer (`$record_<h>` now; 5,129 functions' dead shared declarations deleted, −126,323 bytes); 15 fixtures RED on 1a68ecc0; the wheel's debt 34 → 37; kills: lists/Option "sound", the nested trap "the claim's", the fixture header's "ran without trapping", "state reads none of its writes"; FOUND AFTER THE MARCH: handler state reads only its init (S5, next) | pin `53f7404bedfa0208` |
| S5 | LANDED at pin `852184886f52a848` (CLEAN m2 == m3; m3 leg 987,596 KB; ceiling 995,000 → 1,000,000 on the fixed-input reading — boot 979,780 KB at 461.3 MB vs candidate 976,060–989,188 KB at 464.2 MB): a handler's state is every value written into it — `StateFact({writes})` noted on the init by a pre-pass over the arms before any arm is judged (`bind_handler_state_name`, `arm_updates`), every binder walk reads the join of the writers (`state_leaves`, `state_flow_label`, `state_fn_leaves`, `state_path_read`) under a handler chain of the states entered (`effect StateWalk`, `walking_state_of`, `no_state_walked` beside every `graph_handler`), re-entry reads unknown; the part walk is a first-order path walk applying its reader where the path ends (`part_read` over `path_read`); the race rule reads the facts; a stray update refuses (`E_MissingVariable`); 12 micros + 2 crown RED on 53f7404b; kills: one-unrolling re-entry, part nodes read past the cut (stack exhaustion), the unsound class fallback, the reader-composing form (B2 marker ×8); FOUND: `pick(false).f(0)` reads a class that kept one contract (S6, next) | pin `852184886f52a848` |
| S6 | LANDED (see LEDGER): a function's contract is never lost at a position — census of 23 probes on 85218488, three mechanisms: (M1) an inferred return published its class → every function position of a declaration's/lambda's return publishes the meet (`publish_position`, `fn_at_path` one home with `with_fn_at`); (M2) a charge with no frame was dropped → the authored-return claim runs inside the frame (`claim_authored_return`), a module value let's init answers to the root gate off its nodes (`report_unhandled_init`); (M3) a stated position was unified, never claimed → nominal record construction, `resume` into an op's declared return, and a crossing function's result parts (`cross_result_fns`) each claim; 6 crown + 14 micros RED on 85218488; micros 339, crown 134, PE 30/0, frontier 486/0/1; obligations 37; CLEAN on the tree (m2 == m3); judgment 461.3 MB vs boot 465.4 MB on one source; kills: the RESIDUE lattice-at-unify form (bound roots never link), `with_fn_at` reused (scrubs siblings), "the leak is the crossing" (the payment hit an empty stack), "M1 closes the parameter route" (a6 trapped on m2s6a); named: op-return-is-a-contract, executable-row-includes-inits, candidate-row-is-unjudged, nominal-record-renders-its-variant | pin `6f62b7c400cb5a7b` |
| S1 | DESIGN BANKED 2026-10-02 (RESIDUE `Hβ.effects.handler-pins-its-instance`), built with Pulse scene 2, its first consumer: felt walk on b400dc74 — `(read44()) ~> sample_at(48000)` runs to 48,000, `read44() + sample_rate()` to 96,000 (the collision drops the 44,100 claim), `run(read44)` to 48,000; the five pieces: a served row `handler sample_at(rate) -> Sample(rate)` (A5 gave `with` the arms' bound), the pin as an EtAll gate's present set (the A3 machinery unchanged), collision keeps ground claims beside the ungrounded member, dispatch stays innermost-by-key with distinct claims refused at the install, `E_InstanceNotServed` armed at birth | — |
| D4 | LANDED at pin `b400dc74f2500a60` (CLEAN m2 == m3; m3 leg 995,420 KB under the 1,000,000 ceiling): the gradient proposes what the program owes — a precondition on a parameter an open obligation leans on (matched by guard cell, never name; a written `n: Int` too, the census admitting the base the alias declares, `lost_atoms_beside`), from the aliases the module reaches, proven in a checkpoint bracket against the obligations (`predicate_decide`) and every application the judgment drew (the application edge `graph_apply_note` in `call_owes`; `dry_claim` = learn then claim on a scratch ledger); a return contract where callers' claims rest on the result; the row clause last; one answer `Teaching` = Add | Ask | Need | None, ranked debt → refused → open → absences; `mentl accept` at a declaration writes it through the head render; obligations module-qualified; capabilities nothing performs, three dead Teach ops, `verify_candidate`, `Explanation`, `Candidate`, AOwn/ARef/AWrapHandler deleted; the voice's field retyped to `Teaching`. Eleven teach fixtures (ten RED on 6f62b7c4, settled the control) + three frontier legs (battery, accept ×3, module identity). Kills: the label-count rank, the prelude vocabulary (E_DuplicateTypeName), domain-ordered weakness, the call scan (blind to pipes), the lean by name (a crossing's applier parameter named as main's need), the plain-typed parameter as no position. The comment-ref ratchet refused one march (0 → 2, a probe program's names in a comment). Fixed-input: boot 986,096 KB vs D4 993,816 KB, judgment +2.24 MB (the application edge). Micros 339, crown 134, PE 30/0, frontier 489/0/1. Named `Hβ.teach.leverage-reads-direct-applications` | pin `b400dc74f2500a60` |
| D5 | LANDED at pin `713745c6a557dc01` (CLEAN m2 == m3; commit `4a543b17`, pushed; the board whole; m3 leg 992,672 KB): `where` renders what SYNTAX promises — a fanout site is a `WhereSite` record (the author's glyph `><` / `<|` / `fanout`, the branch edges its boundary holds `×N`, the frame's schedule read through the ONE projection roster, the callers' demand by the emit's own rule `fanout_reach_ask` over the decls column); a function answers its head with its inferred row, each parameter's width and its return's; a local is found by refs → link scoped to the asked module (`QWhere(name, scope)`); free type variables render as the names a developer writes (bound inside a checkpoint, rolled back), widths `per instantiation`. DELETED: the whole-program reach closure (`fanout_reach_names` + four helpers, one reader), two whole-graph scans, the string-keyed schedule walk with its arm-cover test, the index-recursion helpers, the query parser's flatten. Eight frontier assertions RED on b400dc74. Gates: micros 339/339, crown 134/0, PE 30/0, frontier 489/0/1. Fixed input: compiler +16 bytes judgment / +48 module; ceiling 1,000,000 → 1,014,000 (the boot itself crossed it on this source). Kills: one naming pass across a name's binders; `own` as a binder. Banked: the LSP code-action edit (voice gradient peer's second half), `Hβ.query.name-keyed-verbs-miss-locals`, `Hβ.voice.free-variables-render-as-handles` | — |
| E2 | LANDED at pin `8b071ba3c0aebbd0` (CLEAN m2 == m3; m3 leg 1,003,256 KB under the 1,014,000 ceiling): the session keeps its graph — `mentl session` serves on stdin with no listener (one line per verb, the read is the frame); the worker's `session` role blocks in the wheel's own read on a SharedArrayBuffer channel, one client `ide/session-client.js` for page and twin, the per-call roles deleted, the pool armed only for a module importing `wasi.thread-spawn`; a moved tree re-judges its cone (`driver_session_cone` over the warm machinery), `verify_forget` by module node / `tighten_forget` by name (closing a warm compile's double-reported claim); a refusal answers MISS (`session_whole`); the accept answered resident (`accept_draw` under `patch_written`, then the session's own re-judgment); generation currency — a module node's registration supersedes its path's last one, drops what that generation noted in the name-keyed columns, and the module cells read the registration column (the whole-graph walk + quadratic dedup deleted), modules facet sorted. Four frontier legs RED on 713745c6; twin and browser green with timers (reads 5.2–9.4 ms vs 216 cold; browser open 130 / read 5.6); generation oracle 0 of 108 differ. Kills: the env-only shadowing (stale `main()` proposal), the accept's double judgment, the leg-8 accepted position, the warm double-reported claim, the per-read filter (+154 MB at the judgment, caught by the fixed-input reading before the march; the purge at supersession put it 244 KB below the boot); the effectful-lambda ratchet refused 230 (three brackets → `session_address`; HEAD read 227, the tree 228, ceiling 229 → 228, re-marched); `authored_ref_max` 703 → 698. Named: answer-scratch-outlives-the-answer, edit-pays-for-the-program, answer-is-out-err-and-exit | pin `8b071ba3c0aebbd0` |
| E4 + G1 + P1 | LANDED at pin `9d27c325ab2f23ee` (TRANSITION m3 == m4; m3 leg 1,034,740 KB, m4 1,041,948 KB; ceiling 1,014,000 → 1,050,000 with the arena owing 23.7 MB back): the eight aspects at the caret, each read off the graph — the parent edge a spine column at `graph_register_node` (biased +1, untrailed; a module's children its decls), every upward question reads it (`decl_path_to`, `ancestry`, `enclosing_decl`) and `path_to`, `node_contains_handle`, `decl_holding`, `absorbed_around` plus four whole-graph scans deleted; a node spans the tokens it consumed (`upto`), the caret is the character (`caret_span`, one home for CLI and LSP); Topology (`VerbFrame`), the serving install (`Served`), Effects as what evaluating the node performs (`RowFacet`), the obligations inside the node; a parameter's Why at its signature (`FnParam` located), one hop phrase `reason_phrase` (the caret's copy and the emit's 25-arm renderer deleted); minted params render as their type; `mentl where NAME` answers the address; `mentl query <entry> ghosts` (18,681 on the wheel). 24 frontier assertions RED on 8b071ba3. Twelve kills (LEDGER). G1: the medium-first gate (`tools/hooks/medium_first.py`, PreToolUse Grep|Bash; the drift audit as a checked-in PostToolUse hook; `.claude/settings.json`). P1: Morgan's six questions answered in PLAN — `!Flow` dissolves into the influence walk with control edges (§4⑥, Phase 7), Verify's own solver (8.3), one residual Outside (§0), and THE ORDER FROM E4: the arena with lowering-as-columns, then positions are cells, then the solver | pin `9d27c325ab2f23ee` |
| 8 · THE ARENA | LANDED at pins `d7d9da55f89c3d00` (the arena) and `fb8921e335daa8a0` (the dormant strategy deleted, `list_set` as a value keeps, `variants` of an effect), TRANSITION each: `(body) ~> arena` — journal (slot, leaf) at the three typed store sites, exit moves by the fold's fifth leaf (`$evac_<sig>`/`$scan_<sig>`) or keeps; the age claim decides twinning; the judgment's groups run in one; 4,487 exits / 0 kept / 206,870 KB reclaimed / 49,914 KB moved; judgment 511 → 288 MB, peak 1,065 → 874 MB, ceiling 1,050,000 → 884,000; found: parameters read as references (false 17-member cycle), block statements read last first (both RED on 9d27c325); facets `prose NEEDLE` and `variants` of an effect; 12 kills (LEDGER); named: extents beyond the judgment, closure evac face, per-instance regions, region-typed mutation, the `addr` word channel, three claim imprecisions, nested-fn hoisting | pin `fb8921e335daa8a0` |
| 8 · Arena·P2 | LANDED at pins `f950ebfd0e80f634` (the exit's slide runs only when something moved — `nothing-moved-past-memory` exits 134 on fb8921e3; pinned alone because a compiler's runtime is written by its parent) and `912577160150bf94` (TRANSITION each; m3 579,940 KB, m4 587,688 KB): every extent runs in an arena — each statement's lowering and the three pre-passes, each emitted-reach demand walk, each emitted function / twin / wrapper / leaf, each session answer and mcp message, each battery fixture, each speculation (row clause, precondition and return proofs, the synth segment); `heap_reset` deleted from `Alloc` (`mn-raw-rewind-unsayable`, RED through f950ebfd with its own libs: 42); the diag bank a plain collector; the pre-warm intern deleted; `arena_line` at the compile's end; `where` at a handler declaration answers its effects and address (RED on fb8921e3). Fixed input: 870,088 / 871,608 → 575,228 / 574,564 KB, module written 741.5 → 438.0 MB, 19,772 exits / 0 kept; session per answer read 344,536 → 24 B, hole 950,304 → 120, edit 8,044,080 → 119,600, accept 9,031,664 → 119,664, answers identical; ceiling 884,000 → 594,000 | pin `912577160150bf94` |
| 8 · #126 | LANDED at pin `0a096302d535adc2` (TRANSITION m3 == m4; m3 leg 523,740 KB, m4 520,840 KB): a block's run of `fn` declarations is one letrec scope — `Run = Joined | Lone`, `runs_of`/`stmt_runs` the one rule; the free-name walk binds a run's names for every member, the judgment pre-registers and walks the run's groups (`judge_fn_run`, `inf_keep_open` keeping the prereg cells across exits), the lowering binds every register before minting (`lower_run_into`); the emit mints adjacent closure bindings in two phases (`emit_minted_bindings`, `self_capture_name` deleted); a nested symbol is the declaration's path (`ls_fn_symbol`, `.`-joined, `$k`); `pat_tops` one projection for exhaustiveness, `E_PatternInexhaustive` armed at zero; the module free-name walk in an arena (judgment 288.6 → 228.3 MB; peak 581,804 → 519,548 KB fixed input; ceiling 594,000 → 529,000). Ten of twelve fixtures RED on 91257716. Kills: the `split` collision, the materialization cost, the as-pattern RED, the bootstrap refusal of `run_step`'s as-pattern, two prose gates. Named: `Hβ.parser.block-runs-read-by-each-reader` | pin `0a096302d535adc2` |
| 8 · #129 pin 1 | LANDED at pin `2198ed974ede7e87` (TRANSITION m3 == m4; m3 leg 516,120 KB, m4 516,000 KB): `Addr` a Ty arm (`TAddr`) — a word that is not a number (arith refuses via `AoAggregate`, unifies only with itself), equal by identity, ordered by magnitude (`WordOrder`/`word_order_of` read by both compares), shown unsigned (`$show_a`, a generated leaf the show collection demands, `show_is_leaf`), moved opaque (`evac_of` EvOpaque); `Memory` gains `addr_at`, `addr_diff`, `load_addr`, `store_addr` (`$store_addr_j`, leaf 0, in arena modules), `null_addr`, `addr_word`/`word_addr`; `str_payload`'s face unconstrained for pin 2. Found: a sum compare ranked a nullary sentinel against the other operand's address (`B(5) < A` false) — tag-uniform read now, the wheel's 28 sum compares took it. Seven fixtures (four arena legs + `mn-addr-word` refuse on 0a096302, pass 42; `mn-sum-order-tag-first` 1 → 10; arith refusal on both); Int twins of the four legs read 0/0/0/2 there. Fixed input 515,544 → 516,132 KB. Kills: variantless nominal, `load_addr` in Cast, show through int_to_str / sig-letter scan, one-diagnostic arith. Named: `Hβ.infer.arith-refusal-beside-a-mismatch` (pin 2) | pin `2198ed974ede7e87` |
| 8 · #129 pin 2 | LANDED at pin 10cd1956fefa7abf (TRANSITION m3 == m4): the library speaks `Addr` (alloc/heap_mark/Cast.addr answer one; raw loads/stores take one; list links are addresses, element words cross by the puns; `slot_present`, `out_of_range`); arithmetic on an address one refusal per site (`arith_refuses` on both operands before unify); the install frame joins instances only for effects its handler answers (`inf_install_absorbs`); the JSON escaper measures then writes; dead tuples.mn deleted. THE QUESTION ("is that the Mentl way?") killed the first copy barrier — a scan reading every copied word at four byte offsets, marched and repinned, then restored and deleted: a raw copy is OPAQUE (one keep entry, no byte read), a wide list slot copies its scalar as a number (`scalar_copy`; `arena/wide-slot-reclaims` 1 → 42), a content claim on raw memory refused as a second home for the value layer's types. The logged facet grown in the landing: `mentl query <dir>` answers a site facet across a directory of programs (`query_dir`, `query_sites`, `query_judged`). Fixtures: 17 retyped, 6 added | pin 10cd1956fefa7abf |
| 8 · C×A | LANDED at pin cf8a6d500a41d7ba (TRANSITION m3 == m4): a continuation crossing an arena — the exit is flag-aware (a yield in flight SUSPENDS the arena: region kept, journal compacted to the parent, `ArSuspended`; `$__k_arena_extend` wraps `$yield_k`), each resumption opens a fresh arena around the whole wrapped chain (`$__k_arena`), the arena tee is a k2 junction (`is_arena_tee`, `arena_may_yield`, `stage_continuation_boundary` at the tee), non-terminus suspending arenas floor-wrapped; the off-spine floor reports `E_ContinuationUncapturable` at the settle point (`settle_yield`), armed at birth. Eight frontier legs RED on 10cd1956 (six 134, two exit 1), two micros. Kills: the address-compare crossing test, per-segment reopen, the transparent-arena hoist, the lowering-time refusal of dead code, the m2 census line. Found and next: an arm observing its answer refuses `E_ShapeUnprovable` (the answer is no part of an arm's key — the redrive peer's second face) | pin cf8a6d500a41d7ba |
| 9 · AN-1 | LANDED at pin `311479e1144cc884` (TRANSITION m3 == m4): `Handler(instance, answer)` at both registrations (one answer cell, minted at pre-registration, read by the registration), `install_answer` at the tee with the install's reason naming the arm, the arms keyed at the answer (the face-roots exclusion deleted), the continuation face's `$__lane_f64` register, a multi-shot op's arguments at their widths in the yield's record, `proc_exit(Int) -> !`, `value_tails` for every value walk, the three-valued partiality leaves, `ETypeMismatch` carrying its Reason, `where` rendering a handler's answer; micros 366/366, crown 134/0, PE 30/0, frontier 595/0/1; fixed input at parity (531,536 vs 531,004 KB min of three), ceiling 529,000 → 539,000 | pin `311479e1144cc884` |
| 9 · AN-2 | LANDED at pin `e7f6e2b946f44c04` (TRANSITION m3 == m4; m3 leg 525,760 KB min of three, m4 530,932 KB, inside the 539,000 ceiling): `RNone` is `Abandon` always (the bottom-return hedge deleted); `LAbandon` stores the perform's arguments in a per-instance area (`$yield_args`, allocated once at `_start` and the thread entry, sized by the widest perform's arity; pointer slots journaled with their leaves), sets no continuation, raises the flag and branches to the innermost landing (`effect Unwind` / `unwind_scope` over `emit_planned`: an install body's `$__land_<h>` block, an arena body's `$__aland_<h>` block — the arena EXITS on a dead continuation — or the function's return); every boundary a raised flag can cross is `LUnwind` (`k2_floor_wrap`, `unwinding_ops` computed once at `lower_program`, `branch_checked` around spawn/join) — a dead k unwinds, a live k is the floor, refused at the settle point by the callee's row (`settle_unwind`, `row_live_op`, `E_ContinuationUncapturable(op, callee, span)`); the k2 spine reifies only for `can_yield_live` callees; a thread's abandon rides the 24-byte task record and `$join_task_impl` re-raises it. Twelve micros (ten RED-first on 311479e1) + two frontier legs + two arena legs (`abort-exits` replacing `abort-suspends` after kill 1: the area holds addresses, the pointees move by their leaves); micros 377/377, crown 134/0, PE 30/0, frontier 604/0/1; the first march refused at the effectful-lambda census (225 > 223) — three lambdas became references, ceiling 223 → 222; WAT 545,520 → 551,087 lines (+1.0%). Named: arm-remainder-after-a-foreign-live-yield, unwind-by-engine-exceptions, join-performs-the-branch-row, diverging-provider-direct-call | pin `e7f6e2b946f44c04` |
| D3 | LANDED at pin `13e8484aeed28cff` (CLEAN m2 == m3): the gradient reads addresses — positions are the caret's module's handles (`module_handles`, `latest_generation`), proximity between two handles (`position_proximity`, `module_reach_of`), one ranked order for the field and the argmax (`rank_positions`); the suggestion carries its Annotation (moved to types.mn) and the accept splices the formatter's head render (`render_fn_head`) over the declaration's head in its own module's file, guarded by the conservation census (moved to format.mn); `PatchWrite.write_module`; the proposer's rank reads the same proximity (`decl_index`, `ref_handles_of`); deleted: `module_path_of_span`, the by-path import walk, the second argmax order, `cursor_at(Span)`, the eight-fold template invites; two frontier legs RED on boot 9387fea1 (field listed helper decls under main's coordinates; session focused the prelude's `unwrap_or` and wrote `  with Pure` above main.mn's first line); closed `Hβ.cursor.module-of-a-span-is-containment`, `Hβ.synth.proximity-compares-across-modules`; named `Hβ.felt.accepted-clause-carries-its-proof`, `Hβ.cursor.proximity-reads-the-call-graph`, `Hβ.felt.session-caret-never-moves` | pin `13e8484aeed28cff` |
| 7 · L5 | LANDED at pin `c3ca5eeb1a62abca` (CLEAN m2 == m3; commit `3ccc960c`): A6 measured — the felt walk refuted install identity as the hole (the nested same-handler shape is the row being exact, Koka refuses it too; recursive and escaping shapes run under dynamic dispatch) and found the PARTIAL HANDLER: `fn f() with !State = (get() + inc()) ~> only_inc` compiled clean and trapped. A handler is exhaustive over every effect its arms answer (`E_HandlerInexhaustive`, armed at birth); five partial handlers in the wheel and runtime fixed (each_handler's `result`, summaries_frozen → `ResumeSummariesWrite` after the row killed a forwarding arm at the boot's root, preinstall_init_scope and names_not_emitted forward, `Interact` split into `Workspace` + `Interact`); three micros RED-first; the two split-effect frontier legs are refusal contracts; the prelude-floor ceiling 2794 → 2796 with the arm's record; micros 253/253, crown 102/102, frontier 449/0/2 at the pin's board; m3 leg 848,160 KB | pin `c3ca5eeb1a62abca` |
| 7 · L4a′ | LANDED: the derivative crosses a function value and a handler's arms through the record — tangent lanes before a record's header (one per capture: epoch + f64, `emit_record_alloc`), a per-lane epoch against `$__dt_epoch` so state that lived before the extent enters it held fixed, a third fn-table face (`$jvp_face`, `$__jvp_absent`) demanded by signature, `jvp_call` / `jvp_perform` / `jvp_install` intrinsics, `PdFrame` arm twins by install; eight micros RED-first + the frontier's `derive-distort` (12/12 vs central differences); the first march refused at the cost ratchet and the fixed-input probe (boot vs m2 on identical input: +72 bytes) ruled it source growth, ceiling 805,000 → 832,000 | pin `8ee3d09a071eb5b5` (CLEAN m2 == m3; frontier 445/0/2; crown 102/102; micros 243/243) |

The three landed steps' designs below are kept as the record of what was
built; Step 3 is the live cursor and is rewritten as its as-built state plus
the exact verification that remains.

## Step 0 · Land the mask pin — LANDED `fbe8f3c3`

1. Write the narrative into `boot/PROVENANCE.md`'s head block (the LEDGER
   entry's mechanism paragraph, tightened); fill LEDGER's `21f8e691f6e04426` with
   `2974547b80a7c09c` and `‹COST›` with the pin block's cost line
   (`m4 leg 11.71s wall · 987MB peak RSS (1011124 KB)`).
2. `bash tools/state.sh` (the whole board including the IDE gate; the march
   answers from the memo), `bash tools/doc-truth.sh`.
3. Commit (no attribution), push.

## Step 1 · A3 — the negation gate is carried by the cell — LANDED `61d83764` (pin `674154f6`)

As built, two corrections to the design below found by the march: `gate_present`
dedups by ROW only (two declarations stating one bound are one gate);
`row_severs_replay` (src/infer.mn) reads the gates on an open row's single
edge so the replay-severance read survives the universe row leaving cells; the
first cut's authored `with Memory + Alloc` on that reader was refused by the
wheel (it reaches `Intern`) and the row is inferred. Frontier hof-gate-noisy
and pb-own were the red legs that named both.

**The claim it makes true:** if `f` declares `!E` and the program is accepted,
no evaluation of `f`'s body performs `E` outside a handler installed within
that evaluation — under polymorphism, through masks, across forward references
and sig'd recursion (LENS §2.3's theorem, lemma (i) now exact per edge).

**Design (LENS §2.2 second form, with two corrections found this session):**

- **A gate is per-cell metadata, not a row value.** `Gate({row: EffRow, name:
  String, span: Span})` — the NEGATION half of a declaration (`([], [E],
  EtAll)`, instance-aware through `eff_forbids`) plus who declared it. Stored
  sparse in `graph_handler`'s state (`wmap` handle → Gate, lib/imap.mn),
  trailed by `MSetGate(h, prev)` so checkpoints/rollback (the synth fan,
  Mycroft rounds) restore it. `EtAll` then appears in gates and nowhere else:
  the `Open ~ All` / `All ~ Open` unify arms become gate installs (per-edge,
  `forbidden ∖ mask`) instead of binding a universe into cells — the ETALL law
  becomes true by construction and the `allsib` universe bound disappears.
- **Install at declaration EXIT, on the free terminals of the resolved body
  row**, in `enforce_row_gate` (src/infer.mn): `resolve_row` gives presents P
  and free edges `(cell, mask)`; the ground check is `P ∩ forbidden = ∅`
  (today's `row_subsumes`); each terminal receives `forbidden ∖ mask`
  (LENS §2.3's push, exact now that masks ride edges); a cell already gated
  takes the union of forbidden sets. NOT at pre-registration: gating every
  signature row var at prereg falsely refuses a sig'd HOF that returns its
  callback uncalled (`fn make(f: () -> Int) -> (() -> Int) with !E = () =>
  f()` · `make(() => op())`, which the crown's latent/performed rule accepts).
- **Instances minted before the install are reached by edge.** `instantiate`
  (`build_inst_mapping`, src/infer.mn) records fresh ← root for every row var
  it freshens from a pre-registered scheme (`graph_instance_note`, trailed);
  installing a gate on a root walks its instances, checks each one's current
  binding, and gates it. This is what refuses `adv-sigd-self-rec` (the
  recursive call instantiated `run`'s scheme before `run`'s exit) without
  gating latent rows.
- **One judged writer — and it already exists.** `graph_bind_row` has
  exactly two callers in the tree, `bind_edges_to` and `bind_edges_neg`
  (src/effects.mn:967-985), fed by the five unify arms
  (`unify_row_canonical` :999-1085) and the argument edge
  (src/infer.mn:4109). The check lives there: read the target's gate
  (`graph_gate_of`), fold the value (`resolve_row`), check its presents
  (`row_subsumes` against the gate row), push the gate onto the value's free
  edges (each minus its mask — the Open ~ Open residual carries b's edges
  with their masks, so the push reaches a caller's cell exactly as LENS §2.3
  derives), report on violation, then the raw op. The three
  `graph_finalize_row` callers (`inf_exit_fn` :163, `fold_member_cells`
  :1649, the instance pin :2807) check the finalized value against the
  cell's own gate — the `run(a)` shape where a caller pushed the gate before
  the callee finalized. `graph_bind_row`/`graph_finalize_row`/
  `graph_compress_row` stay mechanism.
- **The deferred-gate machinery DELETES.** `defer_row_gate`/`pending_gates`/
  `drain_row_gates`/`row_gate_unresolved`/`edges_any_free_beyond`/`sig_owns`/
  `drain_deferred_row_gates`/`assert_row_gates_drained`/`assert_gates_walk`
  and the park decision at src/infer.mn:2569-2585 exist because the exit
  check was vacuous over a free edge and had to be re-run when the SCC
  resolved. With the gate ON the free edge, the write that resolves it is
  the check, so the exit installs unconditionally and nothing is parked — a
  Carried-Truth deletion, and the sign the form is right. (The SCC cycle
  discipline — `scc_groups`, `group_mono_views`, `group_completion_fold` —
  is unrelated and stays.)
- **Storage.** `graph_handler` state gains `gates` and `instances`, both
  `wmap` (lib/imap.mn — the own.mn `region_tracker` precedent; `wmap_new`
  once per install, prepend-shadow semantics). lib/imap.mn gains `wmap_pop`
  (drop a key's head entry) so the two new `Mutation` arms — `MSetGate(h)`,
  `MInstanceNote(root)` — revert LIFO like the trail itself; a gate write
  prepends the MEET (forbidden sets union), rollback pops. Instances are
  noted only when the freshened root is BELOW the mint ceiling (a prereg
  cell — forward and recursive references), which bounds the map to exactly
  the copies an exit install can miss.
- **Refusal:** `E_EffectMismatch` (armed) at the WRITING site — the argument
  edge for `run(() => op())` — with the message naming the declaring fn and
  its span from the gate record (`Hβ.diag.effect-mismatch-reason`'s first
  face). `T_OverDeclared` narrates only on a GROUND body row (LENS §2.3).
- **Two amendments from the pressure test** (the order-of-judgment cases):
  a finalize is a write, so the three finalize callers PUSH the cell's gate
  onto the finalized value's free terminals as well as checking its presents
  (the co-member case: `a`'s exit gates `b`'s prereg cell P; `infer_fn`
  binds P := `EtOpen([J])` at :2400 — that write pushes onto the judgment
  cell J — and `b`'s finalize of J must then push onto `b`'s own param
  terminals; if `b`'s judgment started first the install resolves through P
  straight to J, so both orders land the gate). And a handler declaration's
  `with !X` takes the same exit install at `register_handler`'s finalize of
  `r_handle` (:8322) — one path for fns and handlers. `graph_compress_row`
  needs no check: it stores a cell's own resolved content, so no new
  terminal enters and no gate moves.
- **Scope of this landing: negation gates only.** A declared POSITIVE row on a
  HOF is theorem-correct as a cap on its callbacks, but the wheel's ~300
  positive rows were written as inventories, never caps
  (`Hβ.effects.declared-positive-rows-under-count-callbacks`), so arming
  positive gates before A4 deletes the inventories would refuse the wheel at
  every HOF. Order: A3-neg (this step) → A4 (Step 4) → A3-pos (closed
  positive declarations become caps, T_OverDeclared retires into the
  projection).
- **Expected wheel fallout is real leaks, fixed honestly.** `!Mutate` is
  declared on hundreds of wheel fns; a `!Mutate` caller of a forward decl or
  of a mutating callback is checked for the first time (today the free tail is
  admitted and never re-checked when the callee lands). Each refusal is either
  a false negation (deleted — a negation is a proof claim) or a real leak
  (the callee fixed). The march measures the count on the first m2.

**Sites** (enumerated by the Explore pass, exact): src/types.mn — `Mutation`
(:985-993) gains `MSetGate`/`MInstanceNote`; the graph op declarations beside
`graph_fresh_row` (:2107) gain `graph_gate_of`/`graph_gate_set`/
`graph_instance_note`/`graph_instances_of`; `type Gate`. src/graph.mn —
`graph_handler` (:286) state + arms, `revert_trail`/`revert_trail_into`
(:1292-1337) the two new arms. src/effects.mn — `bind_edges_to`/
`bind_edges_neg` (:967-985) become the checking writer; the `Open ~ All` /
`All ~ Open` arms (:1062, :1074) install gates instead of binding `EtAll`.
src/infer.mn — `enforce_row_gate` (:2795-2884: install on terminals, ground
check, T_OverDeclared only when ground), `build_inst_mapping` (:7185-7199:
copy the gate, note the instance under the ceiling), `inf_exit_fn` (:163)
and `fold_member_cells` (:1649) check before finalize, the deletions above.
`row_alpha_shallow` (:2205) needs no change — Mycroft rounds roll gates back
with the trail and re-install at each round's exit. lib/imap.mn — `wmap_pop`.
src/pipeline.mn's root gate is untouched here (Step 2).

**Gates seen red first:** LENS §2.6's table as `tests/crown/` crucibles
(vacuous `!E`/`Pure`/unrelated-`!WASI`, `both(f, g)`, sig'd self-recursion,
masked `!E + !F`, two-use `run`, the instance trio) — each leak accepted by
boot 2974547b before the build; the 36 `tests/lens/negation` probes
re-measured into EXPECT.md's third column and given `// expect:` headers
where green (`Hβ.test.lens-probes-are-a-bash-loop` retires with the loop);
crown ≥ 67 + new; `mentl check src/main.mn` at zero diagnostics after the
fallout is fixed; TRANSITION repin expected.

**Adversarial pass:** one dispatched agent at max effort, briefed with the design
above and the two Explore reports, hunts a counterexample (escaping closures,
mutual recursion under prereg, var-meets-var orientation, gates under
rollback, `Pure`, masks over shared cells, handler arms, fanout thunks,
`TCont` worlds, instances) while the build runs. (The plan-phase attempt
died on the dispatched model's rate limit; the inline pass above stands until the build's
agent reports.)

**Build order that keeps every intermediate m2 compiling:** (1) types.mn
`Gate`, `Mutation` arms, op declarations; lib/imap.mn `wmap_pop`; graph.mn
state + arms + rollback — no reader yet, m2 identical. (2) effects.mn: the
checking writer (`bind_edges_to`/`bind_edges_neg` read the gate, check,
push) and the two `EtAll` arms as installs — no gate exists yet, m2
identical. (3) infer.mn: `build_inst_mapping` copies + notes; the three
finalize callers check + push; `enforce_row_gate` installs at exit and
narrates T_OverDeclared only when ground — gates go live, crucibles turn,
wheel fallout measured. (4) delete the deferral machinery. (5) fixtures,
EXPECT.md, docs, march, repin.

## Step 2 · The executable root gate reads the row and nothing else — LANDED `0d90d6e9` (pin `bbc0cc2c`)

As built: `report_unhandled_names(names, i, n, performed, span)` in
src/pipeline.mn has no `installed` conjunct; emit's `EmitEffectCensus` lost
`visit_effect_install` and `drain_effect_census` returns the demand list
alone. The wheel refused FOUR effects at its own root the moment the credit
went, each a real latent trap: `interrogate_all` mapping the `interrogate_at`
OP (now a plain fn `interrogation_at` both arms call, src/eight_loop.mn); the
voice's run arms asking `file_text` of a handler installed INSIDE them (moved
into `mentl_voice_filesystem`, reading `handles_text`, src/voice.mn); the
allocation strategy installed in `emit_context` outside every sink (now
`emit_fold_leaf_helpers(...) ~> emit_memory_bump`, src/pipeline.mn +
src/backends/wasm.mn); `verify_ledger` at main outside `graph_handler`'s
extent (moved inside the dispatch chain, src/main.mn). Seven crown sound
crucibles had refused at the root since birth behind a one-class judge; the
judge counts `E_EffectMismatch\|E_EffectUnhandled` and the crucibles carry
handlers; `sound-root-nested` (`((twice()) ~> h) ~> h`, runs to 20, refuses)
was removed as A5/A6's own fixture. Micros `mn-singleton-preinstall-call`
(`// expect: refuse E_EffectUnhandled`) and `mn-backtrack-full` (root `~>
my_catch`) had their contracts corrected; `authored_ref_max` 723.
`mentl why <entry> <Effect>` answers only "declared as" — the missing
projection is a named peer. Known remainder of the row: an outer install
whose arms are shadowed by an inner same-handler install (A5/A6), and the
remainder row at the perform site
(`Hβ.continuations.remainder-row-charged-at-perform-site`).

With A3 the row at `main` is TRUE. What still lets a program compile and trap
is `report_unhandled_names` (src/pipeline.mn:363-375) clearing a name because
a handler for it is installed SOMEWHERE (`string_in_list(installed, ename)`,
keyed by effect name over the whole post-reach tree — no extent, no nesting).

**The fact that decides it, read at the emit (Explore trace):** a called arm
runs with its own handler OFF the live chain — `$world_push` stores
`install_world@12`, "the world the arm dispatch sets around the arm call
(deep-handler semantics: an arm's performs resolve outer, never self)"
(src/backends/wasm.mn:2734-2738, the bracket at :4496-4514), and arms are
lowered under a frame fence so every perform inside one is a runtime walk
(`PdWalk`, src/lower.mn:4060). The row already models exactly that:
`register_handler` judges the arms under `r_handle` and `inf_add_effect`
only unions, so an arm's own-effect perform is subtracted from the body and
RE-ADDED through `row(h)` at the tee (`absorb_row`, src/infer.mn:4413) —
it reaches the enclosing install, which is where the runtime sends it. So
the row is the dynamic coverage, modeled statically, and the outermost
install's arm re-emission is genuinely unhandled: `format_default`'s
`mentl fmt` trap was a real bug (since restructured to plain fns), not a
gate false positive. The credit is wrong.

**The landing:** delete the credit; the root refuses from the row plus the
`performed` census alone. The wheel's refusal on `GraphRead` (the one
measurement that kept the credit alive; the arm site was never located) is
answered by the medium — `mentl why src/main.mn GraphRead` at the root names
the perform — and fixed at that site: an arm that performs an op of the
effect it handles is asking an OUTER install to serve it, and the outermost
`graph_handler` (src/main.mn:181) has none. `E_InitPerformsOwnOp` already
refuses the init shape lexically; the arm shape needs no new class — the row
says `row(h)` carries the op, the tee re-adds it, and the root refuses. Ends
with `direct.mn` refusing (`E_EffectUnhandled`: E present at the root, no
enclosing install), `Hβ.effects.root-gate-credits-an-install-that-had-not-
opened`, `.reachable-perform-with-no-install-compiles` and
`.an-arm-may-not-perform-its-own-handlers-ops` closed, and §0's "nothing
executes unproven" true at its own boundary. Fixtures (all compile-and-trap
today): `direct`, the state-init self-perform (`handler hf with s = g()`),
`twin-tee` with no declaration; the wheel itself is the fourth.

## Step 3 · One landing, one board: C2 + B1 + E3 — LANDED `67be33d0` (pin `a25144cf`; the text below is the as-built record it was written as)

**What is already edited (uncommitted, HEAD `0d90d6e9`; `git status` shows
exactly these):**

- **C2** — src/main.mn `render_at`'s `VAsk` arm: members render only when
  `len(survivors) <= 3` (`if … { each(...) } else { () }`), the count and
  the computed question always (§11.1: never a list). Verification: `mentl
  tests/frontier/mn-shape-tie.mn:19:31` renders '5 proven survivors' with
  ZERO member lines; the 2-survivor stage tie still lists both.
  tools/frontier-gate.sh's shape-tie leg now checks `qs_members` (lines
  starting with two spaces) == 1 and '5 proven survivors'.
- **B1 · the world rides the task record** — src/backends/wasm.mn:
  `$spawn_task_impl` allocs 16 bytes and stores `$world_g` at +12
  (`[task closure@0][completion@4][result@8][world@12]`);
  `emit_wasi_thread_start` sets `$world_g` from `+12` of the start arg
  right after the tid, so a branch runs in the world it was spawned in (the
  chain and every handler record live in the shared image; the walk reads
  them from any instance). The B1 repro `$S/b1/branch-op.mn` exits 134 on
  the boot (the `ev_declaring_node` miss at 0xFFFFFFFF).
- **B1 · the race rule at lowering** — src/types.mn: `EThreadedBranchEffect
  (String, String, Span)`, category `"lower"`, `diag_refuses` → True (armed
  at birth, born at zero — the wheel installs no threaded schedule),
  `MaybeIncorrect`, message names the effect, the reason, and both fixes.
  src/lower.mn (after `executable_boundary_row`): `threaded_branch_check
  (thunk_h, thunk_row)` runs when the schedule is Threaded, resolves the
  thunk row's present names, and for each non-substrate-grounded effect
  `threaded_handler_for(lower_handler_stack_now(), ename)` walks the stack
  from `last` down to the frame fence (name `""`): a STATEFUL handler
  (`len(lookup_handler_state_inits_of(hname)) > 0`) refuses "…is
  STATEFUL"; no handler before the fence refuses "no handler … installed at
  the fanout's own frame (an install beyond the frame fence — a caller's —
  is not provable from here)"; a stateless one at the frame passes. Called
  as the first statement of both `Ok(thunk_row) => {` thunk builders (the
  `<|` share builder and `synthesize_branch_thunk`).
  `effect_ops_substrate_grounded`/`grounded_scan` MOVED from pipeline.mn to
  lower.mn (before `is_substrate_mem_op`); pipeline reads them from there.
- **B1 fixtures** (untracked, tests/frontier/): `mn-threaded-branch-
  stateless.mn` (`match (0 <| ({ _ => op() }, { _ => op() })) ~>
  parallel_compose ~> h { (a, b) => a + b }`, exit 14);
  `-inner-install.mn` (each branch `(bump()) ~> counter`, `with n = 5`, exit
  10); `-stateful.mn` (two branches bumping one outer counter, refuse);
  `-caller.mn` (the fanout inside `fan`, `main = (fan()) ~> h`, refuse).
  tools/frontier-gate.sh: new `run_refusal_linked()` (RTLIBS linked, the
  refusal form the threading vocabulary needs) after `run_refusal`; four
  legs after `scheduled-effect`: `run_program … threaded-branch-stateless …
  14 yes`, `run_program … threaded-branch-inner-install … 10 yes`,
  `run_refusal_linked … threaded-branch-stateful … E_ThreadedBranchEffect`,
  `run_refusal_linked … threaded-branch-caller … E_ThreadedBranchEffect`.
- **E3 · the page runs the boot** — src/backends/wasm.mn: memory declared
  `32 65536 shared` in both the import and the defined form (rationale
  comment rewritten); new `$memory_reach(end)` emitted before `$alloc`:
  pages needed = `((end − 1) >> 16) + 1`; loop until `memory.size ≥ need`,
  each pass growing by `max(need − size, 256)` clamped to `65536 − size`,
  `unreachable` on a zero delta or a `memory.grow` of −1 (a loud OOM, never
  a silent wrap). The shared `$alloc` calls it on `$new` before the cmpxchg;
  the global `$alloc` is rewritten (`ptr = heap_ptr; new = ptr + n; new <
  ptr ⇒ unreachable; memory_reach(new); heap_ptr = new; ptr`);
  `$image_restore` calls it on `size` before `memory.copy`. Heap starts at
  1 MB, strings from 64 KiB, so the data segments must sit under 2 MB (32
  pages) — CHECK on the first m2 (`grep -c '(data' `, the highest `(data
  (i32.const N)` + its length < 2097152; otherwise raise the minimum, never
  move the segments). ide/index.html fetches `"../boot/mentl.wasm"` (error
  text names `mentl space`; footer "boot/mentl.wasm — the pinned fixpoint
  itself, unmodified"); ide/test-shim.mjs `WASM = MENTL_IDE_WASM ||
  ../boot/mentl.wasm`; ide/README.md's head paragraph rewritten (no
  derivation recipe); `git rm ide/mentl-ide.wasm` staged. The worker's
  memory ladder (16384/8192 pages) is unchanged and its views are per-use
  (`dv()`/`u8()`), so growth is safe; the runner links imported memory at
  the declared type (tools/runner `SharedMemory::new(engine, mt)`), so it
  needs no change.

**Found and built during the verification (2026-09-27, before the pin):**
the race rule's first form stopped at the first STATELESS covering handler,
and a stateless front over a stateful back (`~> h ~> counter`, `h`'s arm
`resume(bump())`) compiled and RAN under it (11 on six runs) — the walk is
transitive through each handler's residual row (`handler_arm_effects`);
"stateful" read "declares a state init" and refused a read-only state — it
reads WRITES (`resume … with` in any arm) through the one total child
projection, which moved from query.mn to graph.mn beside `node_handle`;
the arm-list literal's span was the `{` alone (the refusal landed on one
column) — it is `{` through `}` now; the boot imports the exec seam
(`mentl_host.wat_write`/`.exec`), which a browser will not instantiate
without — the worker provides it as a loud trap (`Hβ.felt.ide-run-in-page`);
and the IDE gate's spawn contracts were stale (the judgment spawns nothing
since pin 7c9dc538; the 09-25 green measured the old copy) — the task
count is reported, the stub control is vacuous unless the judgment spawns,
leg 4's expectation follows the current render. Six B1 fixtures; the IDE
gate GREEN on the new boot (353 ms, 4,399 WAT lines). Pin: TRANSITION
m3 == m4, boot ← m3 `4596519b371fd70e`.

**What remains, in order (one board, one repin):**

1. `source tools/wt-env.sh && wt_m2_ensure` — confirm the m2 is FRESH (`ls
   -la .build/m2cache/m2.wasm` timestamp, `grep ' error'
   .build/m2cache/m2.err` empty; the memo once hit a stale m2 silently).
   Then the data-segment check above, and `$world_g` declared in every
   module that spawns (it is emitted unconditionally at wasm.mn ~2701 —
   verify by `grep -c 'global $world_g' m2.wat`).
2. The m3 leg: compile the wheel through m2 (`wt_wheel lib src` or the
   march's own leg) — the first measurement of E3's growth path on a real
   image (~1 GB of growth in 256-page steps; watch peak RSS against
   `selfcompile_peak_kb_max: 1042000`) and of B1's rule on the wheel (it
   must stay at zero: the wheel installs no threaded schedule).
3. The four B1 fixtures through m2 with RTLIBS linked (exits 14 and 10; the
   two refusals print `E_ThreadedBranchEffect`, exit nonzero, zero WAT
   bytes) — and RED-FIRST: the stateless fixture on the BOOT must exit 134
   (the B1 repro), the two refusal fixtures on the boot must compile (the
   class did not exist). The C2 render at
   `tests/frontier/mn-shape-tie.mn:19:31`.
4. `bash tools/ide-gate.sh` — BOTH legs green with the page and the twin
   loading boot/mentl.wasm. Leg 1 needs the new m2's bytes as the boot? No:
   the gate runs `boot/mentl.wasm`, which at this point is still the
   `bbc0cc2c` wheel with the 65536-page minimum — so leg 1/2 can only turn
   green AFTER the repin. Order therefore: march + repin FIRST (step 5),
   then the ide gate on the new boot, then state.sh.
5. `MARCH_REPIN=1 bash tools/march.sh` — TRANSITION expected (the memory
   declaration and the task record change every module; m3 == m4 is the
   verdict). Then replace the two `‹NARRATIVE UNWRITTEN…›` lines in
   boot/PROVENANCE.md with the `- source: …` narrative.
6. `bash tools/ide-gate.sh` on the new boot (both legs), `bash
   tools/state.sh`, `bash tools/doc-truth.sh`.
7. Records: LEDGER head entry (pin, cost line, the kills — the B1 repro's
   exit-134 read on the boot, the data-segment check, the RSS delta of
   growth-on-demand); RESIDUE closes
   `Hβ.threads.perform-inside-spawned-branch-traps` and
   `Hβ.ide.pinned-wasm-lags-boot` (the "sub-50 ms has no timer" and
   `Hβ.ide.session-call-reinstantiates-per-call` STAY open); PLAN §7's
   thread-schedule bullet (the trap is closed; the race rule is the gate
   SYNTAX's "provably race-free" sentence now has) and §11.2's
   `ide/mentl-ide.wasm` sentence; PROGRAM-2026-09-25.md C2/B1/E3 notes;
   SYNTAX's `><` section gets one sentence naming `E_ThreadedBranchEffect`
   as the schedule's gate; tools/verify-baseline.txt only if a ratchet
   moves (with the justification line).
8. Commit `C2 + B1 + E3 — pin 542ea5a353823b76` (no attribution lines), `git push -u
   origin claude/mentl-design-audit-m1mptf`.

**Refusal contracts to watch on the first m2:** `E_ThreadedBranchEffect`
must not fire on any micro/frontier fixture that installs `~>
parallel_compose` today (`scheduled-effect`, the thread-negation leg, the
2× measurement fixture) unless the branch genuinely performs through a
stateful/unprovable handler — each such red is either a real race the rule
found (fix the fixture by installing inside the branch) or the rule
over-reaching (the stack walk must stop at the fence, not at the root).

## Step 4 · A4 — the positive row is inferred and projected; F0b rides along

- `mentl tighten` authors the sweep: every authored positive row in src/ and
  lib/ that is an inventory (the count `CsWideRow` bounds, and every
  under-counting HOF row `declared-positive-rows-under-count-callbacks`
  names) is deleted; what survives on the page is negations, instance pins
  and genuine narrowings; the address surface (`mentl <file:line>`) projects
  the inferred positive row where `repr` and resume cardinality already
  project theirs. SYNTAX's "A signature is not an inventory" gets its
  endpoint sentence trued; `Hβ.syntax.positive-row-is-authored-by-hand`
  closes; the wide-row bound goes to zero.
- Then **A3-pos**: a surviving closed positive declaration is a cap, gated
  like a negation (`Pg ∪ mask` on push); `T_OverDeclared` becomes the
  projection's business.
- **F0b, the process half that pays for the sweep's many marches:** the
  per-module solo sweep (63 processes, ~2 min per source change) becomes one
  read of the ScopeAll judgment — every env entry carries its declaring
  module, a reference whose defining module is outside the referencing
  module's import closure reports `E_MissingImport` (armed, born at zero) —
  and verify.sh's sweep and its memo delete (`Hβ.verify.solo-sweep-is-one-
  judgment`, designed in RESIDUE).

## Step 6 · A6 — measured, redefined: a handler is exhaustive (L5, 2026-09-30)

**The design below this heading was install identity. The felt walk ran
first (2026-09-30, four probes on boot 16286d94) and refuted the premise
that identity is the last hole under `!E`:**

- `((twice()) ~> h) ~> h` refuses at the root — and that is effect-granular
  PRECISION, not a false refusal: the inner `h` absorbs `E` for the whole
  extent and its arm's own `E` perform resolves outer, so the row is exact
  and Koka refuses the same program. Op-granular arm reach is the named
  peer (`Hβ.effects.op-granular-arm-reach`), not an identity axis.
- A recursive fn installing the same handler per level runs (exit 2) under
  dynamic innermost dispatch, exactly as SYNTAX documents; a closure escaping
  to a second install of the same handler runs (exit 7) the same way. No
  capture, no silent wrong.
- **The real hole is the PARTIAL HANDLER:** `fn f() with !State = (get() +
  inc()) ~> only_inc` compiled clean under the negation and trapped (exit 134)
  — the install subtracted the WHOLE of `State` by name while `get` walked
  past it at runtime. §0's property (2) false at a shape any program writes.

**The law (L5, built):** a handler is exhaustive over every effect its arms
answer — match-exhaustiveness at the handler, Koka/Effekt parity.
`E_HandlerInexhaustive(hname, ename, missing, span)`, armed at birth,
`HasPlaceholders`. The honest partial forms: a forwarding arm (`get() =>
resume(get())` — an arm's own perform resolves outer, the row carries the
forwarding, so a `!State` over the body refuses as it should), or the
partial set declared as its own effect. The lowering's op-keyed dispatch
walk stays; its empty-arm-slot skip is unconstructible.

**What the rule found on the wheel and the runtime, first census:**
lib/prelude.mn `each_handler` (no `result` arm — every micro's floor);
src/infer.mn `summaries_frozen` (no `set_summaries`); src/backends/wasm.mn
`preinstall_init_scope` (two census ops) and `names_not_emitted` (two
drains) — each forwards now; and src/voice.mn's `Interact`, ONE effect whose
two implementers answered disjoint halves — split into `Workspace` (files,
edit, runs) and `Interact` (attention, voice, session).

**Fixtures:** `mn-handler-partial-refuses` (refuse), `mn-handler-forwarding-
arm` (21), `mn-handler-forwarding-arm-refuses` (`!State` over a forwarding
install refuses); the two frontier split-effect legs retired into refusal
contracts. Install identity as a mechanism is NOT built and is not owed by
this measurement; what remains of "identity" is the served-by projection
(`Hβ.effects.served-by-projection`) and band B's TCont world.

## Step 7 · Pulse, redefined — the crown jewel is "the effect that learns" (2026-09-27)

**Context.** Morgan asked whether Pulse is really the crown-jewel flagship,
against eight considerations: the five verbs, threads, multi-shot, the
gradient, the teaching compiler, self-proposal and codegen, the DSP×ML
crossover, and the developer experience. The verdict below is measured
against the tree, not remembered.

**Verdict.** The DOMAIN survives the challenge; the SCENE as scoped does not.
Sound is the one domain where every claim Mentl makes has a native reading
instead of an argument: `|>` is the signal chain, `<~` is every filter, `<|`
is a send bus, `><` is voices and stereo, `~>` is the effect rack (a handler
IS an audio effect — `lib/dsp/spectral.mn` already installs `~> warm_distort`);
`!Alloc` on the per-sample path is a dropout you would otherwise hear;
`Sample(44100)` vs `Sample(48000)` is the canonical audio bug and Mentl refuses
it per instance; and an adaptive filter IS online gradient descent, so DSP and
ML are one loop (`tests/frontier/adaptive-crucible`, converged and
oracle-checked on the board today). But M1's offline WAV renderer touches
three verbs, no thread, no multi-shot, no learning, and the gradient only as a
log. It is the right FIRST scene (the felt walk that finds the medium's gaps)
and not the crown.

**The crown jewel: ONE program that is a real-time-safe effect AND a
differentiable model, because differentiation is a handler swap.** The same
`<~` chain runs `~> realtime` (every op a direct float call, `!Alloc` proven
per sample, `Sample(48000)` pinned) and `~> reverse_mode` (every op captured,
adjoints flowing back as the resumes return — PLAN §4④'s "sampling (ML)" leg
of the one multi-shot substrate). Training is `><` branches under `~> Thread`
with the race rule proving the shared-state discipline; a checkpoint is the
image (`mentl resume` a half-trained model); the chain is authored with `??`
holes filled by reference and ties that ask. Nobody has this: JAX/PyTorch
cannot run in real time and cannot prove absence; C++ DSP cannot
differentiate; NAM/DDSP ship two programs and a Python bridge. **The novel
claim to prove:** backpropagation through `<~` is HANDLE IDENTITY, not
unrolling — the prior at step n is the output record of step n−1, so the
adjoint flows back along an edge the run already drew.

**What is real vs open, measured this turn:**

| Capability | State | Anchor |
|---|---|---|
| `<~` float recurrence, `!Alloc` surviving the cycle | REAL | `tests/frontier/dsp-crucible`, `mn-feedback-transport.mn` |
| DSP×ML in one loop (LMS), batch GD | REAL, oracle-checked | `adaptive-crucible`, `ml-crucible` (exit 42 legs) |
| multi-shot resumption at runtime | REAL | `tests/micros/mn-backtrack-full.mn` (exit 30) |
| threads, branch runs in its spawn world, race rule armed | REAL (2× measured) | B1, `E_ThreadedBranchEffect` |
| persist = memcpy, `mentl resume` | REAL | `lib/persist.mn`, `fs_write_image_impl` |
| stage holes by reference + the computed question | REAL | `mn-pipe-stage-hole.mn`, `propose-fan-demo/bit.mn` |
| `mentl run` (compile + exec through the host seam) | REAL | `src/main.mn:948 run_run` |
| Int↔Float conversion | REAL (primitives) | `src/lower.mn:737-741` |
| byte buffers + file write (a WAV writer's floor) | REAL | `lib/strings.mn:480 bytes_buf`, `lib/io.mn:514 fs_write_file_impl` |
| autodiff as a handler | TAPE form real (89 lines); the multi-shot form named in its own comment, its DEP (the continuation producer) landed, NOT built, and **absent from RESIDUE** (a hidden gap) | `lib/ml/autodiff.mn:30-43` |
| `><` reaching `Thread` inside a reusable fn | OPEN | `Hβ.lower.schedule-specialized-callee` |
| running a program in the page (audio in the browser) | OPEN | `Hβ.felt.ide-run-in-page` |
| the Severance Map page | OPEN (E6); the CLI refusal is real | `E_EffectMismatch` |
| instance-precise `Sample(rate)` in the library | ABSENT: `lib/dsp/clock.mn` declares `effect Sample` UNparameterized; SYNTAX's canonical `effect Sample(rate: Int)` has no library home | `lib/dsp/clock.mn` |

**The four scenes — one program growing, each adding one crown capability
with one measured verdict:**

1. **Render** (M1 as decided): `examples/pulse/render/main.mn`, oscillators →
   echo (`<~ delay`) → lowpass → spectral distortion → stereo mix → 16-bit
   PCM WAV of ≥10 s at 48 kHz; the mono per-sample chain declared `!Alloc`
   (tuples allocate, so stereo is tupled per BLOCK, never per sample);
   `Sample`/`Hz`/`Gain` refinements bound the signal; two refusal twins on the
   board (one `alloc` on the per-sample path → `E_EffectMismatch`; a constant
   outside `Sample` → `E_RefinementRejected`); the gradient log of every `??`.
   Verdict: a playable WAV plus a frontier leg `pulse-render` checked like the
   dsp crucible (header fields, RMS bounds, spectral argmax, python oracle).
2. **Real-time shape**: the render loop becomes a BLOCK loop (the
   AudioWorklet shape: 128-sample blocks), voices rendered `><` under
   `~> Thread` with the race rule holding, `Sample(48000)` an INSTANCE pin
   with a 44.1 kHz stage refused at compile time. Verdict: samples/second
   against the sample rate (the real-time margin as a number on the board),
   the thread pair (bare vs `~> parallel_compose`) on the voices.
3. **The effect that learns**: scene 1's distortion stage differentiated by
   `~> reverse_mode`, a small waveshaper (2 parameters, then a 4-unit MLP)
   trained to match a target WAV rendered by the reference stage; the
   training loop `><` under `~> Thread`; a checkpoint persisted mid-training
   and resumed. Verdict: loss converged against a python oracle; the SAME
   stage bytes run under `~> realtime` with `!Alloc` still proven; the
   resumed run reaches the same loss as the uninterrupted one.
4. **Authoring**: the scene-1 gradient log turned into ≥ 5 proposal fixtures
   on the board (stage holes, refinement fans, the effect-safety hole `?? ~>
   h`); the Severance Map over `examples/pulse` (green `!Alloc`/`!Thread`
   bands, one `println` added, red with the Reason); C4's accept-through-the-
   graph on a Pulse hole. Verdict: fixtures green, the thirty-second demo on
   the page.

**THE DECISION, BY MORGAN'S CRITERION** ("the path that avoids building
workarounds/band-aids and deeply exemplifies and empowers the Carried-Truth
law") **AND HIS CORRECTION** ("are today's bytes the best design you could
muster with full creative control? the docs are the target; make the
foundation all the way down to emit the best design — what would you do
without Mentl, and how does Mentl make it better?"). The first draft of
this section used Law 7 ("byte-identical to today's emit") as a CEILING and
wrote "true the docs" as if the artifact were the authority. Both are the
lowered-target drift in the discipline's costume. Law 7 is a regression
oracle for a change that alters only how a fact is found; the docs describe
the ultimate form and the artifact rises to them; where a library doc claims
a rule the medium does not enforce, the question is whether the RULE is
ultimate (for `E_FeedbackNoContext` it is not — SYNTAX's inferred clock is
the more-ultimate answer, and the README rises to THAT). The Carried-Truth
path is the one where the chain has ONE home and its readings are
projections of it, never copies; of the four sprint shapes offered, only
hardest-first survives — answer "how does one chain run under two readings
without being written twice" BEFORE a renderer line, so that ordinary
arithmetic IS the final form and scene 1 is written once.

**THE FOUNDATION, READ AGAINST THE ULTIMATE RATHER THAN AGAINST ITSELF**
(2026-09-27: one dispatched refuter at max effort over my first design, plus two
inline confirmations). Four defects in the ground Pulse stands on, each a
silent wrong or an O(depth), none of them "today's bytes are fine":

1. **`Hβ.lower.oneshot-nontail-resume-drops-post-code`.** `resume_grade`
   (src/infer.mn:9011) grades every resume `UOne`; `arm_disc_of` (:8973)
   maps `UOne → OneShot`; `lower_resume_oneshot` (src/lower.mn:4319) is
   `LReturn`, emitted as `(return)` (wasm.mn:4026). Code AFTER `resume(v)`
   in an arm is DEAD and the arm never sees the remainder's answer:
   deep-handler semantics silently become shallow. Fixture: `handler dbl {
   ask() => { let r = resume(1); r * 2 } }`, body `ask() + 1`, expect 4,
   predicted 2. ULTIMATE: `ResumeShape = TailOnce | NonTailOnce | Many`
   inferred from the arm as cardinality already is; `NonTailOnce` lowers
   through the one-shot k record (the MultiShot record used once, no redrive
   loop), the spine grammar generalized so an off-spine perform reifies
   instead of trapping at `k2_floor_wrap`, reclaim O(1) once frames live in
   the image (10.1 keystone 1). Until that tier lands, `E_ResumeNotTail`
   REFUSES, armed at birth (the wheel writes none) — a refusal, never a
   silent drop; the tier's design is banked with the peer.
2. **`Hβ.effects.multishot-perform-allocates-unrowed`.** A MultiShot perform
   emits `LMakeContinuation` → `emit_alloc` (wasm.mn:4127) and NO row
   charges Alloc at a perform site (every `construction_row()` caller is a
   literal/ctor site): `fn f() with !Alloc = choose()` under a two-resume
   handler is a false absence proof TODAY — §0's property (2) at a shape the
   crown never wrote. ULTIMATE: the perform site reads the op's `TCont`
   discipline (the fact the classifier already writes) and charges the
   construction row when it is `MultiShot`.
3. **`Hβ.emit.arith-on-aggregate-is-pointer-arith`** — CLOSED at L1.
   `emit_binop_for`'s arithmetic arm (wasm.mn) dispatched on a WIDTH join; a
   record, sum or unresolved operand floored to RI32 and emitted `i32.mul`
   ON THE ADDRESSES with zero diagnostics (`{x: 1} * {x: 2}` compiled).
   ULTIMATE, as built: arithmetic DEMANDS a number of its operand at the
   JUDGMENT — a gate on the type cell (`NumericGate`), checked at the one
   writer, copied at instantiation; `E_ArithOnAggregate` armed at birth,
   `mentl check` refuses; at emit a word emits at its type's repr and a
   free variable is a floor twin's word by construction. The emit-time
   classification with a narration class was the first form and was
   refuted by the wheel's own compile.
4. **`Hβ.emit.feedback-line-shared-across-twins` + the O(depth) line.** The
   `<~` line is N module globals `$s<h>…` keyed by site handle ALONE
   (`delay_slot_names`, wasm.mn:1533), declared once at module scope at the
   floor's width (`state_slot_globals`, :1570), SHARED by every twin of the
   fn (a Float twin writes f64 into an i32 line, or two readings share
   state), and SHIFTED per tick (`emit_delay_shift`, :1558): `delay(24_000)`
   is 24,000 globals and ~48,000 global moves per sample. (Persist does cover
   the slots — `globals_save` writes feedback slots at their repr, wasm.mn
   ~2091 — so the state survives a checkpoint; it is the cost and the OWNER
   that are wrong.) ULTIMATE: the line is a ring in the IMAGE owned by the
   frame the clock calculus proves advances the cycle — the enclosing loop's
   frame or an Iterate-class handler's state — allocated once where that
   frame is entered (JUCE's prepareToPlay/processBlock split made a proof:
   the install allocates, `!Alloc` inside), O(1) per tick, one line per owner
   (per voice, per twin, per thread instance by OWNERSHIP rather than by
   wasm's per-instance globals), memcpy-persistable as heap state. Where no
   such frame exists, `E_FeedbackNoContext` becomes REAL as a measurement —
   SYNTAX's own promise. `Hβ.dataflow.delay-line-runtime-depth` closes with
   it (a runtime depth is the same ring with a runtime size).

**THE PROJECTION, IN ITS SURVIVING FORM — (c): THE INSTALL BECOMES THE
EMIT.** My first design (arithmetic as topology; a runtime `~> reverse_mode`
handler with post-resume arms; `RHandled` as one more Repr) is DEAD, and the
kills are the record: the mechanism dies at defect 1; the representation
axis dies because `repr_of` is `with Pure` over `Ty` with no stack in scope
and is read at 34 emit sites after the lower stack is gone, and a Dual is a
value-ontology (TYPE) fact; the twin key is the quantified vars' encoding
(`spec_enc`, lower.mn:6556), so a monomorphic Float stage has no key;
"interval/units/fixed-point are handlers on the same aspect" was wrong (they
are width and refinement facts the gradient already carries); "no tape" was
wrong (`wmap_add` is an in-place `store_i32` into a mutable table — the tape
renamed). What survives is what I would build WITHOUT Mentl — JAX's
transformations-as-interpreters over one IR, Dex/YOLO's linearize-then-
transpose — made better BY Mentl:
- **AD is a PROJECTION of the extent, demanded at the `~>` edge.**
  `(loss(w, xs)) ~> grad(w)` returns `(value, dvalue/dw)`. Lower reads the
  install lexically (the Schedule read's exact sibling — `schedule_in_stack`
  becomes ONE roster of projection classes, an ADT, before a fifth `if` is
  added) and DERIVES the twin: LINEARIZE (each op's JVP rule — the handler's
  arms READ AS REWRITES through `rewrite_to` (src/egraph.mn:114), never run
  as resumptions, so a user-declared handler over their own primitive IS a
  custom derivative) then TRANSPOSE the linear sub-graph (fan-out becomes
  accumulation into frame locals; a `<~` register transposes to a backward
  register — BPTT through IIR filters as a graph fact, the gradient of a
  delay being a delay in the reversed program). The forward tree stays
  byte-identical; the twin is emitted as a DEMANDED symbol (`EfkAdj` beside
  `EfkK`/`EfkLambda` in `EmitFnKind`, lower.mn:2493 — `lp_step$adj`) exactly
  as `__k_<ph>` fns and `$sp` twins are: the key is "which projection was
  demanded", a lower-time fact, no install in the type.
- **The twin is ordinary code with a ROW.** Its accumulators are frame
  locals, so a fixed-size chain's adjoint program is `!Alloc`. THAT is the
  unlock nobody has: a provably allocation-free BACKWARD pass means learning
  inside the real-time callback — adaptive effects that keep training while
  they run (the adaptive crucible's LMS generalized to any differentiable
  stage) — which JAX, PyTorch, Dex and every DDSP toolkit cannot state.
  `Sample(48000)` rows keep training data and deployment at one rate;
  persist = memcpy checkpoints BETWEEN steps (a mid-arm checkpoint is
  unresumable by the world law, lib/persist.mn:60–68); `><` + the race rule
  is data-parallel training with provably no shared state.
- **How Mentl makes it better than the thing I would build without it:** no
  tracing (the IR is the program); the projection is GRAPH CONTENT (`~>
  grad(w)` is an edge `mentl why` walks, and the address surface renders the
  DERIVATIVE PROGRAM at the caret — the teaching compiler for calculus, the
  adjoint readable where no framework shows it); the row prices the backward
  pass; the fence and demand-per-site are the same limit twins already live
  with (`Hβ.lower.schedule-specialized-callee`, cited, never hidden).
- **Falsifiers, all on the board:** forward bit-identity over a sweep
  (structural f64 eq); a 2-parameter waveshaper's gradient against a
  finite-difference oracle; BPTT through one `<~ delay(1)` over three steps
  against a hand-unrolled oracle; `!Alloc` PROVEN on the adjoint twin of a
  fixed chain; `!Alloc` REFUSED over a fn whose twin allocates. DELETED:
  lib/ml/autodiff.mn's tape (`TapeEntry`, `compute_tape`, `backward`).
  RETRACTED: `Hβ.ml.autodiff-as-multishot` (wrong axis — AD needs no
  multi-shot, it needs a projection), replaced by
  `Hβ.lower.ad-is-a-demanded-projection`, whose RESIDUE entry carries the
  refuter's fifteen kills as the design record (a landing that reports a fix
  and no kills is either lucky or unexamined).

**Scene 1 — what will be run into (from the files, not guessed):**
- `lib/dsp/feedback.mn:72` declares `type Sample = Float where …` and imports
  `dsp/clock`, which declares `effect Sample` — one link set already carries
  both names. Pulse writes `x: Sample` beside `with Sample(48000)`; whether the
  namespaces are separate or the collision is silent is the first compile's
  first measurement.
- The library's `Sample` effect takes no rate; the instance pin the flagship
  claim cites has to be declared (`effect Sample(rate: Int)`), in Pulse or by
  fixing `lib/dsp/clock.mn`. `lib/dsp/feedback.mn` writes `with Sample(rate)`
  only in COMMENTS (lines 38, 66, 91 — "ambient Sample(rate) is
  post-first-light") and passes `sr: Int` as a plain parameter in every
  signature, so the instance-precise form has never been exercised by the
  library that documents it.
- M1 test 5 names `.github/workflows/board.yml`; no `.github/workflows`
  directory exists. The board's CI entry is `tools/ci/run-board.sh`; the
  test is re-stated against it (a workflow file is a separate decision).
  M1 test 6's tutorial exists (`lib/tutorial/00-hello.mn` … `07-gradient.mn`).
- `mentl run` executes through `host_exec` → the runner, which preopens only
  what `--dir h::g` names (tools/runner/src/main.rs:234); whether the exec
  seam passes the cwd decides stdout-vs-path for the WAV (both forms are in
  the verification above).
- `lib/dsp/README.md` and `lib/dsp/clock.mn`'s header both say `<~` REQUIRES
  an Iterate-class handler and that `E_FeedbackNoContext` is a compile error;
  SYNTAX says the clock is inferred and the diagnostic has zero construction
  sites, and `run_run` installs `no_iter_context`. Two docs and one handler
  name for a rule the medium does not enforce: measure, then true the docs.
- `delay(24_000)` (the README's half-second echo): an N-slot line is
  "declared, never allocated"; how a 24,000-slot line is EMITTED is
  unmeasured (globals vs a memory extent) — measure before the echo is
  written at that depth.
- Series math per sample (`sin`/`tanh` Taylor, `lib/math.mn`) at 480k
  samples: cost and accuracy unmeasured beyond the crucibles' small N.
- `E_EffectMismatch` names the DECLARING fn (A3's first face); M1 test 2 asks
  for the Reason AT THE ALLOCATING CALL — likely a `mentl why` walk today, a
  felt item if the refusal's span is the declaration.
- Two silent-wrong classes are live and pre-arm: `T_FieldOffsetUnprovable`
  (open-row field reads) and `T_EqTypeUnprovable` (compares on unresolved
  operands); a 500-line program over records of samples will walk into both.
- `mentl fmt` must be a no-op on 500 lines of a second author's shapes (M1
  test 4) — the arm-list literal and the residue binder forms on real code.

**Scene 1 build (files):** `lib/audio/wav.mn` (RIFF/WAVE header + 16-bit LE
PCM over `bytes_buf`/`store_i8`/`store_i32`, written by
`fs_write_file_impl`; the output PATH is an argument — `mentl run … out.wav`
— never stdout, which carries diagnostics); `examples/pulse/render/main.mn`
(≥ 500 lines: oscillators, the echo, the lowpass from `lib/dsp/feedback.mn`,
the distortion from `lib/dsp/spectral.mn`, the block-tupled stereo mix, the
render loop); `tests/frontier/pulse-render/{oracle.py, expect}` + the
`pulse-render` leg and the two refusal twins in `tools/frontier-gate.sh`;
`lib/dsp/README.md` + `lib/dsp/clock.mn` trued; the `Sample(rate)` home;
`Hβ.ml.autodiff-as-multishot` ENTERED in RESIDUE (the hidden gap closed by
naming, with the hard question above as its design record);
`docs/PROGRAM-2026-09-25.md` Track G rewritten to the four scenes;
`docs/proposals/MILESTONE.next.md` M2/M3 re-sketched to scenes 2–4.

**Verification:** `mentl check` clean and `mentl fmt` a no-op on the program;
`mentl run examples/pulse/render/main.mn > out.wav` (M1 test 1's own form:
the WAV bytes on the program's stdout through `fd_write_bytes(1, …)`, since
`mentl run` compiles then `process_exec`s and diagnostics ride stderr; a
path argument through `fs_write_file_impl` is the fallback if the exec seam
does not preopen the cwd) → a WAV that plays, its header fields, RMS and
spectral argmax cross-checked by the oracle; the two twins seen RED
(compile) then refusing; `bash tools/frontier-gate.sh` with the new leg;
the whole board and a repin ONLY if the wheel changes (library/doc-only
landings do not move the boot); the gradient log committed beside the
program as `examples/pulse/render/GRADIENT.md`.

**THE SPRINT, IN ORDER — each line one landing = one board = one pin.** The
soundness spine first (the preemption law: §0's property (2) is false at
defect 2, and defect 1 is a silent semantic drop), then the foundation
Pulse stands on, then the felt walk, then the projection on defect-free
ground:

- **L0 · the instrument and two soundness fixes — AS BUILT (2026-09-27):**
  `tests/micros/mn-oneshot-nontail-resume.mn` (expect 4) seen RED at 2 and
  `mn-multishot-perform-alloc.mn` (refuse) seen RED compiling clean on the
  boot. No refusal was needed for defect 1: the grade is `ResumeUse =
  RNone | RTail | RDeep | RMany` (multiplicity × position; every
  value-consuming construct wraps its child in `resume_interior`, sequences
  fold `resume_seq` in source order) and a HELD single use takes the
  reified path, called once — the general tier IS the MultiShot record used
  once; its O(1) reclaim is the named remainder. The refuter's "refuse until
  a tier exists" was the lowered form. Found on the way: a lambda-wrapped
  resume is held UNLESS the callee is proven tail-transparent in that
  parameter (`tail_transparent_params`, read at collection; `mn-held-
  resume-in-thunk.mn` expect 21, RED on the boot at 22, while
  `mn-oneshot-lambda-commit.mn` keeps its stack path by proof). Defect 2:
  the op's published row carries `Memory + Alloc` at the discipline join
  (`scheme_with_disc_cost`), and the join is drawn at PRE-REGISTRATION
  (classify before prereg; `pre_register_handler_sig` draws the edges) so
  discipline and cost stopped being facts of source order. Fallout: eleven
  micros' `with Choice`/`with Cell` caps deleted (inventories). Wheel emit
  unchanged in k fns / drivers (3 / 0). SYNTAX §Resume discipline updated;
  RESIDUE carries both closures, `Hβ.lower.classifier-rerun-at-lower`, and
  the AD design record with the fifteen kills.
- **L1 · arithmetic demands a number — AS BUILT (2026-09-27):** the
  demand is a gate on the operand's type cell (`NumericGate`, A3's gate
  mechanism one sort over): `numeric_demand` at the operator (and unary
  negation), `numeric_judge_push` at unify's three var binds,
  `numeric_gates_copy` at instantiation, the instance column for copies
  minted before the demand. `E_ArithOnAggregate` refuses at the judgment,
  armed at birth (wheel census 0); `mentl check` says so. Three refusal
  fixtures + a check leg on the frontier, a reference-theorem micro. The
  first form — classification at lower and at emit, `T_ArithTypeUnprovable`
  with a ratchet, a post-emit gate — passed every gate and pinned at
  1ff80ffb, then was killed by the artifact (check accepted the programs;
  the "born at zero" was measured on the L0 boot's m2.err; the wheel
  narrated `lo_add`'s floor twin over a `t` inference had seen added) and
  deleted whole. Lesson banked: run `mentl fmt` on every edited file BEFORE
  the march, and measure a new class's wheel count on the boot that
  carries it.
- **L2 · the line is a ring in the image, OWNED by the closure record that
  contains the cycle — designed against the emit as read 2026-09-27 (L1's
  wait):**
  TODAY (`LFeedback` arm, wasm.mn ~4434; `delay_slot_names` ~1533;
  `state_slots_collector` ~1148; `walk_lemit_expr` visits `visit_state_slot(h,
  d)` once per LowExpr tree): the line is N module globals `$s<h>` …
  `$s<h>_<N−1>`, declared once per SITE HANDLE at the floor's width
  (`repr_of(lookup_ty(h))` read outside any twin bracket — an f64 twin
  writes f64 into an i32 global), shifted N−1 global moves per tick
  (`emit_delay_shift`), persisted through `image_global_slots` (8 bytes per
  slot in the header), per-INSTANCE by wasm's global semantics. THREE
  DEFECTS, each a silent wrong: (1) twins share one line
  (`Hβ.emit.feedback-line-shared-across-twins`); (2) every CLOSURE minted
  from one lambda shares the lambda's site line — `let lp_l = lowpass(0.3)`
  and `let lp_r = lowpass(0.3)` filter through ONE register, the
  two-channel bug every DSP program writes on its first stereo stage
  (`Hβ.emit.feedback-line-shared-across-closure-instances`, named here);
  (3) O(depth) per tick.
  THE FORM — handler = state = closure, read at the `<~` site: a cycle's
  memory belongs to the record of the function that contains it. A site
  inside a LAMBDA owns a hidden slot in the closure record
  (`[fn_ptr@0][nc@4][captures@8..][lines@8+4nc..]` — `LMakeClosure`'s emit
  (wasm.mn ~4031) allocates the ring right after the record and stores its
  address in the slot; the site reads `(i32.load offset=<slot> (local.get
  $__state))`), so every closure minted from the lambda carries its own
  line — Faust's per-use-site delay, derived from the record rather than
  from a macro. A site inside a TOP-LEVEL fn (a static closure — one record
  for the module) is module-static by the same law: one global per (site,
  emitting twin) named through `emit_site()`, holding the ring's address,
  allocated in `$__init_lines` beside `$__init_lets` and called where that
  one is (`_start`, `$wasi_thread_start` — per instance, as the globals
  were). The ring is `[cap][head][slot × cap]` at the site's repr stride
  (`repr_width`); the tick is `prior = slot[head]` · `slot[head] = current`
  · `head = (head + 1) mod cap` — head indexes the OLDEST slot, so a cap-1
  ring is the single register in effect; four memory ops at any depth. The
  emit needs each site's owner: lower marks a `<~` site with its owning
  lambda (the innermost enclosing LambdaExpr, else static) and its slot
  index — `project_lambda_fn`'s column seed carries the count so the fence
  and the ev base stay one writer (phantom-capture class, e791bf3). Persist
  = memcpy carries rings (they are image records) and the header carries
  one address word per static site instead of N slots; closure-owned
  rings ride their records. Threads: a spawned instance allocates its
  static rings at `$wasi_thread_start` (today's per-instance semantics,
  kept); a closure shared across branches shares its ring — the race
  rule's next arm (`Hβ.threads.closure-line-shared-across-branches`,
  named), and the clock-calculus owner (an Iterate-class install's state
  holding the lines of the voice it advances) stays the named endpoint
  for scene 2's per-block spawns.
  RED-first: (a) the generic `fn step(x, a) = ((prev) => a * x + prev) <~
  delay(1)` called at `(1, 2)` and `(1.5, 2.0)` — the f64 twin into an i32
  line on the boot (assembler refusal or a wrong value; measure); (b) two
  closures from one lambda, each fed a different constant stream, must
  read their own priors (measured shared on the boot); (c) a `delay(24_000)`
  echo fixture timed on the boot against the ring (samples/second on the
  board); (d) every existing `<~` fixture value-stable (the dsp crucible,
  feedback-transport, mn-feedback-iir, mn-delay-depth, the wheel's own
  `cursor_transport.mn:210 <~ accumulate`). `E_ZeroDelayFeedback` /
  `E_ComputedDelayDepth` unchanged. TRANSITION repin (every `<~` site's
  emit moves). lib/dsp/README.md and clock.mn's header raised to SYNTAX's
  inferred-clock rule (no `E_FeedbackNoContext` requirement), and SYNTAX's
  `<~` section gains the owner sentence: a cycle's memory lives in the
  record of the function that contains it — one line per closure, one per
  module for a top-level fn.
  LESSONS CARRIED FROM L1: `mentl fmt` every edited file BEFORE the march;
  measure a new class's wheel count on a boot that carries it; a
  first-form that passes every gate is still asked "would the judgment
  know this?" before it is pinned.
- **L3 · Pulse scene 1 — AS FOUND (2026-09-27; the felt walk ran and the
  wheel did NOT stay untouched: it found four defects, so the fixes ride
  this landing and it is a TRANSITION repin).**
  **In the tree, uncommitted:** `lib/dsp/clock.mn` (`effect Sample(rate:
  Int) { sample_rate() -> Int; advance_sample(); current_sample() -> Int }`;
  `handler sample_at(rate) with count = 0` replaces `sample_real` /
  `sample_test`, which differed only in a constant); `lib/audio/wav.mn`
  (the 44-byte RIFF header as `store_i32` words, PCM16 via `store_i8`, into
  one `bytes_buf` sized before the first sample; `wav_data = buf + 8`,
  since `str_payload` allocates); `examples/pulse/render/main.mn` (~270
  lines, fmt-canonical, `mentl check` clean; the rate pin on the three
  clock readers because A3-pos makes a surviving positive row a CAP, so the
  per-sample fns declare only `!Alloc`); `tests/micros/mn-match-float-
  scrutinee.mn` (expect 40, unrun); `src/parser.mn` HALF-CONVERTED to free
  uses (does not build — `free_uses_merge` undefined, six walkers still
  name-based).
  **What the walk measured (each seen, none guessed):**
  1. **Defect B · a closure capture of a ground local stores at the floor.**
     `fn make(fb: Float) = (x) => x + fb` passes `mentl check` and the
     module does not ASSEMBLE (`unknown local $fb`; the param is
     `$fb.f64`); probes p6–p10 red, p1–p5 green; the read side (`i32.load
     offset=8` then `f64.load`) is already right. ROOT: a ground-typed
     binder's handle is 0 (`ty_handle_of`, src/lower.mn:3745 — "a ground
     type is a value, not a node"), and the compensation — read at the USE
     node's handle, sound because a local is monomorphic — sits INLINE SIX
     TIMES (VarRef :2318–2319, `resume_k_arg` :4491–4492, its sibling
     :4555–4556). `resolve_captures_outer` (:5550) is the one reader
     without it. A seventh copy would be the second-workaround STOP.
  2. **Defect A · a match on a wide scrutinee does not assemble.**
     `$scrut_tmp` is a fixed i32 prologue local (wasm.mn :2277, :3158); the
     LMatch emit parks an f64 in it (:4426); `emit_pat_binds` passes RI32
     as the ROOT value's repr (:7645) and `walk_locals_arms` declares root
     binders at RI32 (:3439); the float-literal predicate reads the root
     f64-wide (:7493). Probes v1, v2, v4, v5, v8, v9, v11 red. Nested
     reads are already right — every step past the root is a pointer
     chase, and payload leaves read at their proven repr.
  3. **Defect C · `compile` after `run` on the same file prints nothing.**
     `mentl run x.mn` then `mentl compile x.mn` → 0 WAT lines ("warm:
     restoring the analyzed image … lowering and emit re-derive"); a fresh
     file compiles; the same file through `compile` twice compiles. Cause
     UNMEASURED — the next output is an instrument, not an edit.
  4. **The `Hz` / `Sample` claims stay V_Pending**, so main.mn's comment
     ("each arm is a literal, so the bound is discharged where it is
     written") is FALSE today. The constant fragment (`node_const_at`,
     src/verify.mn:115) folds literals, `self` and arithmetic, and has no
     arm for `if` / `match` / block; the interval fragment beside it
     already joins over exactly those (`lo_join`, `arms_lo`) — for Int
     lower bounds only, by its own stated scope.
  5. **Felt findings for the gradient log and RESIDUE:**
     - A lambda parameter takes no annotation (`(freq: Float, vib) =>` is
       `P_ExpectedToken`), so a refinement such as `cutoff: Hz` cannot be
       written on a closure's parameter.
     - A user fn named `envelope` collided with dsp/processors' `handler
       envelope`, and the LIBRARY's own reference resolved to the user's
       decl, with `E_MissingImport` blaming dsp/processors. This is the
       per-module env overlay peer, measured on a real program.
     - `E_EffectMismatch` renders raw row variables (`r24515@e13917`).
     - `mentl fmt` rewrote `48_000` as `48000`, losing the authored
       grouping. Whether it also rewrites hex tags is unmeasured.
     - `lowpass_iir` is a top-level fn, so its line is per-instance static
       and a stereo pair through it shares ONE filter. The library should
       expose filter MAKERS that return closures.
     - The prose that L2 left stale: the `lib/dsp/feedback.mn` header
       (`$s<h>` globals, emit_state_globals), the `lib/dsp/signal.mn`
       header and bandpass comment ("ONE module global per site"), and
       `src/pipeline.mn:30` (`sample_real`).
- **L3 · the build, in order — one landing, one board, one pin:**
  1. **B · one read of a resolved name.** Parser: finish `collect_free_uses`
     → `[(name, use handle)]` (`free_uses_merge` keyed by name, keeping the
     first handle, the same drift-audit note as `free_vars_merge`; the list,
     record, stmts, stmt, match-arms and handler-arms walkers return uses;
     `free_vars_merge` stays for name SETS — bound lists, params, binders).
     Lower: ONE projection, `resolved_read(res, local_h, use_h, name)`,
     returns the value of a resolved name at a use — `LLocal` / `LUpval` at
     the binder's handle, or at the use's when the binder is ground;
     `LFeedbackPrior`; the RGlobal drop — and VarRef, both `__k` resolvers
     and `resolve_captures_outer(uses, owner_h)` all call it, the six inline
     conditionals deleted into it. The five capture sites (lambda :2520,
     both fanout thunks :3301/:3365, nested fn :3629, k reify :4843) pass
     uses; `lower_seed_k` / `lower_seed_hrec` seed with handle 0 (the k and
     the record are words by construction). Name-only readers (infer's DAG,
     tail transparency, ownership, query, synth) keep `collect_free_vars`.
     `resume_k_arg` keeps passing its site handle as today — the hypothesis
     that a Float-returning resume-bound callee would read `$__k.f64` is
     PROBED (one fixture) before anything acts on it. **Adversarial pass
     (inline — the dispatched refuter died on the rate limit, and Morgan's rule
     dispatches no other model):** the design HOLDS. Boxing is already the
     mint's job: `emit_capture_stores` (wasm.mn:7153) spills a wide capture
     by `tail_expr_repr(capture)` and `LUpval` dereferences it, so a use
     handle is all the store lacked. Only the capture's VALUE EXPRESSION
     changes; the frame's capture-HANDLE list keeps the binder's handle
     (0 stays 0), so reads inside the lambda body keep their own use handles
     and stay byte-identical. A nested fn's self-capture keeps its non-zero
     binder handle, so `self_capture_name` (:7190) still matches. The deeper form — a
     binder is a graph node with its own cell, so no binder is handle 0 and
     the conditional deletes — goes to RESIDUE (extend
     `Hβ.lower.bind-handle-typed-subpattern` if it covers binders, else
     name `Hβ.lower.binder-is-a-node`).
  2. **A · the match root is read at its repr.** One decider,
     `sr = tail_expr_repr(scrutinee)`, and every reader takes it: the LMatch
     emit sets `local_wat_name("scrut_tmp", sr)` (the naming projection
     every local uses); `walk_locals`' LMatch arm declares that scratch when
     `sr` is wide and the root binders (LPVar, LPAs) at `sr`;
     `emit_pat_binds(pat, sr)` passes it as the root `val_repr`;
     `emit_scrut_at_repr` at path length 0 reads the scratch at the leaf's
     repr (deeper paths start from the word scratch — a pointer); LPAs binds
     at `sr`, not i32; the postmortem stores the root at its width.
     Byte-identical wherever `sr` is RI32 (the wheel). Fixture:
     `mn-match-float-scrutinee.mn` RED on the boot, then 40. **Adversarial
     pass (inline): HOLDS.**
     - `tail_expr_repr` is already the one decider that the capture store
       and the match result width read, so the scratch's width cannot
       disagree with the value set into it.
     - A shared per-repr scratch cannot be read stale. An arm binds before
       its body runs, and an arm whose predicate failed never ran its body.
       A match inside the scrutinee finishes before the outer `local.set`.
     - Literal patterns are unified with the scrutinee by inference, so no
       accepted program reads the root at a repr other than `sr`.
  3. **V · a predicate over a join is the AND over its tails.** The hook is
     exactly where `self` binds: a declared refinement reaches Verify as
     `PWithSelf(value_h, pred)` (`apply_refinement_constraint`,
     src/infer.mn:8062, through `subst_self`), and `predicate_decide_at`'s
     `PWithSelf` arm (src/verify.mn:76) decides it with `self` =
     `value_h`, the MatchExpr node for `note_hz`. `node_const_at` has no
     arm for it, so the answer is None. The arm becomes
     `decide_with_self(inner, sh)`: an `if` / `match` / block at `sh`
     decides as the three-valued `and_decide` of the predicate at each tail
     handle, recursively; any other node decides as today. So the claim
     discharges when it folds true at every tail, refuses when any tail
     folds false, and stays pending otherwise. No second path; STRUCTURE
     reads only, so the contamination law (verify.mn:151) holds. The
     refusal reports at the claim site, as every decided-false refinement
     does. A dead tail that writes an out-of-bound constant is refused too.
     That is conservative and stated, since the text claims every tail.
     Three fixtures, RED first: a `note_hz`-shaped match with no V_Pending
     line; one out-of-range arm, refused; one non-constant arm, pending.
     `channel`'s `Sample` is a CALL result, and the flows-class read already
     accepts a value that flowed from the same named refinement
     (infer.mn:8057, verify.mn:533). So lib/dsp/signal.mn's `soft_clip`
     declares `-> Sample`, and the one honest debt sits in `soft_clip`'s
     own body: `x / (1.0 + x)` over an `if` is the Float interval tier,
     Phase 8.3. That debt is one obligation for the library, never one per
     caller, and main.mn's comments say exactly what the ledger says. Found
     on the way: `type Hz` (lib/dsp/feedback.mn:67) caps at 22,050, which
     is 44.1 kHz's Nyquist, while Pulse runs at 48 kHz. The piece's pitches
     sit far below it, so it is a gradient-log finding for the named DSP
     peer (`Hβ.dsp.hz-ceiling-ambient-sample-rate`), not a refusal.
  3b. **D · FOUND IN THE BUILD (2026-09-28): a wide value crossing the
     call boundary allocates, and no row sees it.**
     - **Measured:** `fn step(f, x: Float) with !Alloc = f(x)` compiles
       clean and calls `$alloc` to box `x`. Each indirect call speaks the
       2026-07-21 word protocol: arity `$ftN`, wide arguments boxed, wide
       results unboxed, wide functions reached through `$wf$` wrappers.
     - **Handlers:** a handler whose op carries a Float does not assemble
       (`fop.mn`, `fstate.mn`, the same on boot). The arm function's
       parameters come from the op's declared types (f64); its result is
       the body's type, which is S, not R; the performer boxes; a state
       commit does an `i32.store` of an f64. No fixture ever installed a
       Float-op handler, so the DSP library's `Distort` handlers have never
       compiled in a real program.
     - **Design, partitioned by CALLER:**
       - Ordinary closures (lambda, nested, partial, a named function as a
         value) are only ever called at typed sites. They get a typed `$ft`
         from the site's repr vector, native arguments and no box, with a
         native table entry. §5.U step 1 made true; it is sound under total
         monomorphization, and a mismatch is a LOUD `call_indirect` trap,
         never silent.
       - Continuations and task thunks are called by runtime helpers
         (`$__k_compose`, spawn). They keep the word face, and `$wf$`
         wrappers remain only for them, inside contexts already priced by
         L0's multi-shot `Memory + Alloc`.
       - Op arms speak the op's DECLARED signature: parameters from
         `op_param_tys`, and for a OneShot arm the result is R. The
         performer converts to the declared ABI (native for ground types;
         a box only at an effect type variable, which is the generic-op
         residue, named and unrowed). An indirect arm call uses the
         declared vector's typed `$ft`.
       - Handler state commits in place through the cell boxed once at
         install. The resume snapshot's scratch locals are read at their
         value's handle.
     - **Witness:** a Pulse fixture returning the heap growth across N
       rendered frames (it must be 0), plus the `fop` / `fstate` / `fclo`
       micros RED-first.
  4. **C · instrument, then fix.** The path as read: `driver_compile_entry`
     (src/driver.mn:595) restores the warm image when `driver_warm_ready`,
     then `driver_incremental` prints "inference restored — lowering and
     emit re-derive" (:719) and runs `warm_program()`. The instrument
     traces which files each invocation opens and writes (`strace -f -e
     trace=openat,write` if present, else the host seam's fs ops), plus the
     warm image's key and mtime. It answers where the second invocation's
     WAT went, and whether the image `run` persisted carries `run`'s
     output routing. The measurement names the cause, the fix follows it,
     and a frontier leg holds the contract: `run` then `compile` on one
     fresh file prints WAT.
  5. **The library rises.** Filter makers returning closures in lib/dsp (a
     stereo pair gets two filters); the three stale comments trued. `mentl
     fmt` keeps a numeric literal's authored spelling — radix and grouping
     are intent, and the literal's own span holds them. Measure hex first,
     then fix the formatter where it drops them.
  6. **Pulse grows to the scene M1 describes (≥ 500 lines).** Two saws and
     a sub, plus a bass line and a noise source (an LCG `<~` over Int); ADSR
     envelopes; the swept lowpass per channel through the makers; the
     spectral distortion; a Schroeder reverb (four comb `<~` lines and two
     allpass lines, each a closure-owned ring); equal-power panning; a
     limiter. `render_frame` stays `!Alloc`; `mentl check` clean; `mentl
     fmt` a no-op.
  7. **The board's contract.** `tests/frontier/pulse-render/`: `oracle.py`
     (RIFF/WAVE/fmt/data tags, 2 channels, 48,000 Hz, 16 bits, data size =
     frames × 4, RMS inside bounds, the first note's spectral argmax at its
     pitch) and the three twins, each RED-first. `alloc-on-the-path.mn`
     (one allocation beneath `render_frame` → `E_EffectMismatch`),
     `sample-out-of-range.mn` (a constant outside `Sample` →
     `E_RefinementRejected`), `rate-mismatch.mn` (a `Sample(44100)` stage
     in the 48 kHz chain → `E_EffectMismatch`). A `pulse-render` leg in
     tools/frontier-gate.sh renders through `mentl run`, pipes to the oracle
     and prints the render's wall time against the piece's 10 s; the twins
     go through `run_refusal_linked`. Render cost is measured before the leg
     is shaped.
  8. **Records.** `examples/pulse/render/GRADIENT.md` holds every felt
     finding above, each with its verdict (fixed here, or the named peer).
     RESIDUE closes the three defects with their kills and names: lambda
     parameter annotations, the env-overlay shadow measured, raw row
     variables in diagnostics, and fmt literal spelling if it outlives this
     landing. Also PLAN §7 (one bullet), LEDGER, PROVENANCE, PROGRAM Track G
     (four scenes), MILESTONE M2/M3, and SYNTAX: the refinement section's
     join-discharge sentence, plus a float-pattern sentence if the section
     makes a width claim.
  9. `mentl fmt` every edited `.mn` BEFORE the march. Then `MARCH_REPIN=1
     bash tools/march.sh` (TRANSITION expected: every closure capture and
     every match's emit moved), the narrative, `bash tools/doc-truth.sh`
     and `bash tools/state.sh`. Commit with no attribution, then push to
     `claude/mentl-design-audit-m1mptf`.
- **L4 · the projection** (as planned): `~> grad(w)`, linearize + transpose
  at lower, the demanded `EfkAdj` twin, the projection-class roster
  replacing the `schedule_in_stack` if-chain, the five falsifiers,
  autodiff.mn deleted, the peers retracted and renamed, the derivative
  program rendered at the caret. Built against scene 1's real distortion
  stage.
- **R0 · PREEMPTING L4a (2026-09-28): record row vars become union-find
  citizens.** L4a's first m2 run trapped in the COMPILER's own
  `facts_moved` twin: `prev` laid out as the 5 fields it names while the
  runtime record has 8. Reduced on boot 730e097a to e2 (12 lines, silent,
  exits an address): a handler arm reads its config's fields, the install
  passes a param, and a two-record fn reads that param. The medium's
  projection names it: `prev: { x | { y } assumed }`: the ASSUMED residual
  (unify_two_open_records' cross-absorb, absorb_into_residual's unbound
  arm) carries no row var, so no twin keys it and open_record_full_fields
  bakes the partial set. Fix: the unseen rest IS a row var (RowContinues
  of a fresh var on both sides), RowAssumed retired, and generalize,
  instantiate, spec keying and the open-against-closed narrowing follow
  the tail (mn-findtag stays green). L4a is stashed whole
  (`git stash list`: "L4a derive") and resumes on the R0 boot, where
  derive.mn's structural facts record is itself a fixture of the class.
  Kills on the way: name collision (b1 renamed the config, still fails);
  recursion (e2 has none); the one-field floor a3 is the known loud form,
  not this.
- **R0 LANDED** (commit `0aef1b6e`, pin `c5439637261f50ab`, board whole).
  **R0′ — the emitted reach** (dead bases not emitted; one reference walker
  `low_refs`; both dedups one pass over a name map; `heap:` lines at
  lowering's end and the module's end): m3 449,015 → 408,868 lines, floors
  8 → 0, eq-unprovable 57 → 34, show-unprovable 22 → 1, 12.3 s → 9.6 s,
  815 → 756 MB. First march REFUSED on the eq ratchet (57 → 58: the reach's
  own `decls_where` compared a 0/1 flag against a generic `want`); liveness
  is `DeclReach = Unreached | Reached` now. Second march running.
  **Then, in order:** R0b (handler arms specialize per install — design in
  the scratchpad `r0b-design.md`: the install's handler reference is a keyed
  site; `RefArms` resolves arm twins under it; the install emit stores twin
  indices under ITS enc, not the enclosing bracket's; PdFrame resolves by
  its install, PdWalk ArmNamed falls to the slot when a handler has keyed
  installs), R0″ (emit-time floor classes refuse at the settle point — the
  fold walk carries the three provability questions; then arm the field
  offset class; the spec_recs quadruple becomes the record), then resume
  the stashed L4a.
- **L4 · AS DESIGNED 2026-09-28 (read against the artifact; refuter pending).**
  Three landings, each one board and one pin: **L4a** linearize (forward
  mode), **L4a′** the derivative crosses dynamic dispatch (closures and
  handler arms — the distortion perform), **L4b** transpose (reverse mode by
  cost). L4 is not done until L4b lands.
  - **SURFACE — the query form, not the pair.** `lib/ml/grad.mn` (replacing
    autodiff.mn): `effect Derivative { d(v: Float) -> t }` and `handler
    grad(w) { d(v) => resume(tangent_of(v, w)) }`, where `tangent_of : (Float,
    t) -> t` is a primitive (register_primitives, the float_of_int
    precedent) meaningful only under the reading; its forward emission is a
    comment-marked floor unreachable by construction, since a grad install
    never builds a record. Use: `(w - rate * d(loss(w, xs))) ~> grad(w)`. The
    tee's value is the body's value (the tee type rule does not change); the
    body asks for derivatives; the Derivative effect proves every query has
    a reading (an unanswered `d` refuses at the root, by the row). WHY NOT
    THE RESIDUE FORM `(loss(w)) ~> grad(w)` returning `(value, d)`: the
    tee's type would depend on the handler (a per-class type rule where every
    other tee is its body's type), and the pair is a tuple — a tuple
    allocates, so the use the crown claim names (learning inside a `!Alloc`
    callback) could never write it. `(l, d(l))` is the pair when wanted, an
    allocation the developer writes and the row sees.
  - **SEMANTICS.** ∂/∂w of the extent: the partial derivative of the
    install's body with respect to the binder `w`, every other free variable
    of the extent held fixed (the definition of a partial derivative, and
    JAX's closure semantics). State that persists across installs (a `<~`
    line, a handler's state) enters the extent held fixed: tangent zero at
    entry, accumulated within. The extent is what is differentiated; the
    install's position says where the derivative starts.
  - **MODE.** Forward first: JVP, total over what the medium writes —
    recursion, tail loops, branches, and `<~` (the tangent of a recurrence
    IS a recurrence: RTRL, online, fixed memory). The derivative program's
    row equals the primal's (it adds only unboxed f64 locals and arithmetic).
    Reverse (L4b) is the O(answer) form when D is large and the output
    scalar, chosen by COST: forward and reverse mean the same thing, so the
    choice is a form-space tie (§5's duality), never authored.
  - **REPRESENTATION — a stage, `lower |> derive |> emit`** (`src/derive.mn`;
    identity when no install demands it, Law 7). Lower recognizes a
    Derivative-class install through the ONE projection roster
    (`type Projection` — replacing `schedule_in_stack`'s if-chain) and lowers
    it to `LDerive(h, seed, body)`: no record, no world push. derive expands
    each LDerive into the body's JVP — primal nodes unchanged and in order
    (bit-identical forward values and effect order) — with each tangent an
    ordinary LowExpr over primal locals (the residuals) and tangent locals
    `x$d`, and DEMANDS a twin `f$jvp` for every known fn the active
    computation calls directly: Float params doubled into (primal,
    tangent), the tangent result returned through a per-instance f64
    register `$__dt` read by the caller immediately after the call (tail
    calls transparent — the last callee sets it). Demand to a fixpoint;
    twins emit through the ordinary per-fn emission under the base symbol's
    sp bracket and line owner.
  - **THE TANGENT VOCABULARY IS CLOSED** (so L4b's transpose reads a known
    set): lane add, sub, negate, scale by a residual, zero, local, twin-call
    register, tangent-line prior. Rules: constants/globals/non-Float → zero;
    `+ -` add/sub; `*` a·db + da·b; `/` (da·b − a·db)/(b·b), b bound once;
    unary `-` negate; float_of_int → zero; float_to_int → inactive Int;
    let → lane local; if/match → structure kept, each branch sets the
    result's lane local; direct call → twin; `d(v)` → v's lane.
  - **`<~` IN A TWIN.** The primal tick is the BASE line (one filter, two
    readings, one state — the line is the program's, not the reading's). The
    lane ticks a TANGENT ring of the same geometry indexed by the primal
    ring's head, allocated per (site) at instance start beside the static
    lines, and ZEROED at each LDerive entry that reaches it (`memory.fill`,
    one instruction — "state at entry is held fixed").
  - **L4a DOMAIN, and the loud floor outside it.** Seed: a Float variable
    (D = 1). First-order code: top-level fns (generic ones through their sp
    twins), direct calls, recursion, branches, match over inactive
    payloads, `<~` in top-level fns, the query. Wherever an ACTIVE value
    would be dropped — an active argument to a dynamic call, an active
    component of an aggregate, an active perform argument other than `d`,
    an active handler state write, a nested derivative install — derive
    REFUSES with an armed class naming the construct and the peer that
    carries it (`E_DerivativeUnreachable`), never a silent zero.
  - **L4a′ (next landing): the derivative crosses dynamic dispatch.** A
    lambda minted inside the extent mints its jvp twin and a record carrying
    its captures' lanes; every function-typed param of a twin is a jvp
    closure; a closure minted outside and called with an active argument
    refuses (its derivative program was never demanded). Handler records
    for handlers whose arms an active perform reaches carry a jvp arm region
    after the arms (demanded statically — all handlers declaring the op);
    the jvp perform walks to the same record and calls the jvp arm; an
    active state write refuses. This is where `fold(0.0, (a, x) => a + w *
    x, xs)` and the distortion perform become differentiable.
  - **L4b: transpose.** Reverse mode from the closed tangent vocabulary; the
    residuals of a fixed chain are frame locals (`!Alloc` proven on the
    twin), and the residuals of a loop or recursion are priced by the row
    (`!Alloc` refused where they are unbounded) — the design record's
    falsifiers 4 and 5 in their reverse form. BPTT through `<~` is the
    transpose of the tangent line.
  - **PEERS NAMED BY THIS DESIGN:** `Hβ.derive.gradient-of-a-product-seed`
    (D lanes in one pass for a record/tuple seed; a gradient record never
    materialized where it is destructured), `Hβ.derive.stop-gradient`
    (`stop(v)`: forward identity, zero tangent), `Hβ.derive.second-order`
    (a reading inside a reading), `Hβ.derive.closure-twins` and
    `Hβ.derive.arm-twins` (L4a′), `Hβ.derive.transpose` (L4b),
    `Hβ.derive.derivative-at-the-caret` (the felt face, unless it lands
    with L4a).
  - **THE ADVERSARIAL PASS RAN INLINE** (the dispatched refuter died on the rate
    limit at dispatch; no other model is sent). KILLS: (a) "the floor refuses
    an ACTIVE argument to a dynamic call" — an INACTIVE closure call or a
    perform whose arm reaches a `<~` site shared with a twin ticks the
    primal line forward and leaves the tangent ring stale, a silent wrong
    with no active value in sight; (b) "refuse an active component of an
    aggregate" — refuses `(l, d(l))`, the design's own recommended pair, and
    every final-position record; (c) `d(d(l))` — the inner result's tangent
    was never computed, so the first design answers 0, silently; (d)
    "derive is a stage between lower and emit" — the jvp of a generic fn
    needs the sp bracket's substitution to know which values are Float, and
    an install inside a generic fn expands per instantiation, so derive runs
    at emit's settling point, after the spec demands and before the sigs
    publish, memoized per (install, bracket); (e) "call the forward fn when
    every argument is inactive" — wrong when the callee's reach ticks a
    shared line (the prior may be active); (f) a global seed — a callee's
    read of the global is a read of the binder during the extent, which the
    lexical seeding misses. HELD: the query form over the pair (the row does
    the work — a `d` outside every reading refuses at the root); the
    register (every non-tail twin call is a let followed by the read; a tail
    call passes the callee's register through; only twins write it; a
    continuation in reach refuses outright); bit-identity (lets and tangent
    arithmetic touch no primal value, and the combined tick reads the head
    once); forward-first (the rules are written once as PARTIALS — each
    construct's ∂out/∂in over residuals — consumed by JVP now and VJP in
    L4b). THE REPAIR — ACTIVITY IS A THREE-POINT LATTICE, and a refusal
    fires where a lost tangent is CONSUMED, never where it is lost:
    `Inactive | Active | Lost(reason)`. Aggregates built with an active
    component are tainted and their loads are Lost; a dynamic call or a
    perform yields Lost when an argument is not Inactive; `d`'s own result is
    Lost ("second order"); a `<~` site's prior activity is the join over its
    ticks (a fixpoint), and every site's tick is Lost in an extent whose
    reach contains a dynamic call or a line-reaching perform (the staleness
    rule); twins are keyed by their Float parameters' activity; `d(v)` of a
    Lost `v` REFUSES naming the loss site. The seed is a local Float binder;
    a global seed refuses (`Hβ.derive.global-seed`). Refusal lands at the
    executable; `mentl check` seeing it is `Hβ.derive.check-sees-the-floor`.
    The derivative as SOURCE (graph content the judgment infers, rows
    proven by inference) needs unboxed product returns and product-valued
    lines: `Hβ.derive.derivative-is-source`.
  - **FALSIFIERS (L4a):** (1) forward bit-identity over a sweep; (2) the
    derivative of the distortion's transfer function (`adaptive_shape`, the
    real scene-1 stage) against a finite-difference oracle, two parameters
    by two installs; (3) the derivative through one `<~ delay(1)` over three
    steps against a hand-unrolled oracle; (4) a `!Alloc` training step whose
    derivative program runs with zero heap growth; plus the LMS crucible's
    hand-written update re-derived as `d(e * e)` and matched to its oracle.
- **L4b · THE GRADIENT — AS DESIGNED 2026-09-30 (read against derive.mn
  whole; the adversarial pass ran inline, kills below).**
  - **THE AUDIT'S FINDING.** derive.mn's header promises "the rules are each
    construct's partials, written once — read forward here, read backward by
    the transpose", and the artifact does not do that: `jvp_arith` bakes the
    partials into forward tangent LowIR and `Tan = TZero | TVal(LowExpr)` is
    already lowered. A transpose cannot read that, and a mirror walker over
    forty constructors would be the duplication. So the first cut is the
    promised one home: the JVP walk emits a LINEAR PROGRAM once, and forward
    lowering and transposition are its two projections.
  - **WHY THE PRODUCT SEED RIDES ALONG.** With one scalar seed, one forward
    pass answers every `d(v)`; the transpose is never cost-minimal (D = 1 ≤
    Q), so reverse mode without a product seed is machinery nothing extracts
    — verify.mn's dead serializer shape. `Hβ.derive.gradient-of-a-product-
    seed` closes here: `~> grad(ws)` with `ws` a record or tuple whose Float
    fields are the D seeds; `d(v)` answers the seed's shape. The GRADIENT IS
    READ BY DESTRUCTURING where it is asked (`let {a, b} = d(v)`, a tuple
    pattern, a one-arm match): the fields bind to the adjoint locals and no
    record is built, so a `!Alloc` extent stays honest with no judgment
    change; a gradient held as a value is `Hβ.derive.gradient-as-a-value`
    (refused, named). The effect's `t` is one instantiation per program
    (`Hβ.effects.two-instances-of-one-effect-do-not-join`), so a program
    seeds one type.
  - **THE LINEAR IR.** `Lin = LinZero | LinName(String) | LinAdd | LinSub |
    LinNeg | LinScale(LowExpr, Lin) | LinQuot(Lin, LowExpr) | LinLane(Int,
    LowExpr, Int) | LinIn(Int)`; statements `Stmt = SPrim(LowExpr) |
    STan(Int, String, Lin) | SIf(Int, String, LowExpr, [Stmt], [Stmt]) |
    SMatch(Int, String, LowExpr, [(LowPat, [Stmt])]) | SQuery(Int, String,
    Lin) | SOut(Int, Lin)` plus the forward-only record forms (lane writes,
    mints, installs, rings, faces). `Jvp{pre: [Stmt], val, tan: Lin, act}`.
    The partials are the Lin the rule writes once; the transpose of a Lin is
    mechanical (`LinAdd` → both sides get g; `LinScale(c, x)` → x gets c·g;
    `LinQuot(x, c)` → x gets g/c; `LinName(n)` → adj_n += g; a defining
    STan zeroes adj of its name after consuming it, so a rebinding's earlier
    definition starts fresh).
  - **FORWARD PROJECTION** lowers the Stmt tree to today's LowIR exactly (D
    = 1 naming kept: `name$d`, `$__dt`, 16-byte lanes) — the derive fixtures
    AND a byte diff of their WAT against the boot are the oracle.
  - **REVERSE PROJECTION** of an extent: the forward sweep emits every SPrim
    in order with predicates and arm indices recorded as residual locals;
    each SQuery is a backward sweep over the STans before it, adjoint
    locals (`name$a`) zeroed per sweep, ending in the seed adjoints; a
    direct call is primal in the forward sweep and a VJP TWIN in the
    backward one — `f$vjp<key>(args…, g)` recomputes f (the residuals are its
    own frame locals) and hands its active Float params' adjoints back
    through registers `$__da{j}` (the `$__dt` shape). Legal only over a FIXED
    CHAIN: no LinLane / LinIn / rings / faces / recursion / queries inside
    twins. Cost: reverse iff legal and Q < D. With D = 1 forward always,
    byte-identical to today.
  - **NAMED, NOT BUILT:** `Hβ.derive.vector-forward` (D lanes through faces,
    rings and recursion: lanes sized (8 + 8D)·n, D registers, D tangent
    params per active Float — a product seed reaching those refuses naming
    it, never a silent zero), `Hβ.derive.transpose-through-iteration`
    (residual stacks priced by the row, or logarithmic recompute),
    `Hβ.derive.transpose-through-the-record` (adjoint lanes; faces under
    reverse), `Hβ.derive.bptt-priced-by-the-row` (the tangent ring's
    transpose over the extent's ticks), `Hβ.derive.gradient-as-a-value`.
  - **KILLS (inline).** (1) "adjoints of a rebound name mix" — zero after the
    defining STan. (2) "residuals clobbered in loops" — reverse excludes
    iteration. (3) "queries inside twins" — excluded; forward carries them.
    (4) "the predicate residual changes forward bytes" — only the reverse
    projection records it. (5) "a tangent read before its definition in the
    reversed order" — adjoints flow later→earlier by construction. (6) "a
    residual computed after the statement that reads it" — `named` temps
    are placed in `pre` before every use and are unique per node handle.
    (7) "the gradient record allocates under `!Alloc`" — destructure-only,
    so it never exists; the value form is a named refusal. (8) "reverse
    through `<~` in one tick" — the prior's adjoint would flow into the
    previous tick; excluded, BPTT named. (9) "VJP twins need the callee's
    residuals" — recompute inside the twin; O(2×) time, zero allocation.
  - **FALSIFIERS, RED-first on boot 8ee3d09a:** a record seed whose `d`
    destructures against hand partials (reverse chosen, D = 2 > Q = 1); the
    same chain with two queries (forward D-lane refuses → the vector-forward
    peer; so the tie's other side is measured by a scalar-seed control); a
    reverse chain through if/match branches; through a direct call (the VJP
    twin); a `!Alloc` gradient step whose heap does not move; the frontier's
    `derive-shape` extended to a 2-seed reading of the drive AND the flux
    against the existing per-parameter central differences; the mode chosen
    written as a WAT comment at the install (the caret face is
    `Hβ.derive.derivative-at-the-caret`). Fix the five unresolved comment
    references `mentl doc src/derive.mn` reports.
- **L5 · A6** — LANDED 2026-09-30 as the exhaustive-handler rule (Step 6 as
  measured; pin `c3ca5eeb1a62abca`). A7 LANDED (pin `4bc108088fa73607`).
  C4 LANDED (the accept is a graph write; the row above). Then C5 and the
  Step 5 order, with scenes 2, 3, 4 as landings of their own.

**Definition of done for the sprint:** the board whole at every pin; the
four foundation peers CLOSED (not narrowed); the WAV plays; the two twins
refuse; the ring line's cost is a number on the board (samples/second at
depth 24,000); the gradient log exists; one distortion stage renders the
same bytes under both readings, its gradient matches the oracle, and its
adjoint twin is `!Alloc`; `mentl <file:line>` renders the derivative program
at the caret.

## Step 8 · THE ARENA — a journaled extent that commits with compaction (LANDED 2026-10-03, pins d7d9da55 and fb8921e3, TRANSITION each)

AS BUILT (supersedes A3's "owners name their buffers" protocol below — kill 3
refuted it for plain code, and the typed-at-the-store form replaced it): every
store into memory older than an open arena journals (slot, leaf) where it
happens — a direct `list_set` through `$list_set_j`, a state commit, a `<~`
tick; `list_set` reached as a value through its table face `$list_set_v`,
leaf 0 (keep). The age claim (fresh / parameter / state / older, a least
fixpoint per function, transported at direct calls) decides which bodies are
twinned by `MovedShape`. Placed at the judgment's binding groups. Measured on
the boot over the wheel: 4,487 exits, 0 kept, 206,870 KB reclaimed, 49,914 KB
moved; judgment 511 → 288 MB; peak 1,065 → 874 MB; ceiling 1,050,000 →
884,000. Also landed: the free-name walk's parameter and source-order fixes,
the prose facet, `variants` of an effect, the dormant `emit_memory_arena`
deleted. Arena·P2 LANDED the same day (pins f950ebfd and 91257716 — every
extent runs in an arena; the row above). Nested-fn hoisting (#126) LANDED
at pin 0a096302. Next: #129 (the `addr` channel), positions are cells
(#108), Verify's solver (#109).

**Measured basis** (scratchpad/arena, binary-patched m2 over the wheel):
census v3/v4 — 15 sampled groups ≥ 1 MB, 53.5 MB of extent: every
old→young word sits in a channel a handler already owns (minted cells,
trail-named older cells, wmap/smap buckets, env buffer + index, the region
index, record-field rebinds); survivors 15.65% of extent bytes without the
trail, 31.57% with it. Census v5 traced the 5% "unknown": abandoned trail
buffers referenced only by popped checkpoint records — garbage, no channel.
**Kill 1 (the user's question, "is this the Mentl way?")**: design D, a
generational collector with a card-marking barrier, was a foreign shape.
**Kill 2 (inline adversarial pass)**: the first re-derivation broke on
non-lexical checkpoints, continuations, contiguity under persist, monotone
state rollback, and region 0. **Fix T (built, measured)**: the trail
journaled every write of the compile, read by nothing at depth 0 — now
only under an open checkpoint, reset on the outermost commit: judgment
499.7 → 489.0 MB, peak 1,029,244 → 1,021,028 KB, WAT byte-identical.

**Kill 3 (2026-10-02, this window): the owner-only form A2 is UNSOUND for
plain code.** Owners naming their slots covers the wheel (census) but not a
`list_set` by plain code into a buffer older than the arena — the young value
would dangle after the exit, a silent wrong. Considered and refuted, each by
measurement or by the representation: a TYPED barrier in `list_set` (the
prelude's `map`/`filter` collectors write generic values in place, so a
shape demand on the stored value re-twins the prelude per element type —
R0d's 3,033 → 120 undone); region typing with effect masking (the ultimate
static form — `Mutate(ρ)` with outlives constraints — a language arc of its
own, named below); evacuating untyped slots (the heap carries no runtime
types, so an untyped root cannot be moved).

**The form (A3, the journaled arena).**
- `(body) ~> arena` — `arena` answers `Alloc` by forwarding, so the roster
  classes it `PArena`; the install lowers to `LArena(h, body, exit)`: no
  record, no world push. Cost row `Memory + Alloc + Arena`; the judgment
  demands the value's WHOLE shape (it is moved by its structure).
- THE JOURNAL: every store into memory older than the innermost open arena
  is journaled where it happens — `list_set`'s word store performs
  `arena_note(xs, i)` (untyped: buffer + index; the emitter elides it in a
  module with no arena, byte-identical), a handler's state commit and a `<~`
  ring tick of a pointer type journal TYPED entries (slot + the type's evac
  leaf) where the emitter knows the type. A journal entry costs a compare
  when no arena is open.
- THE PROTOCOL: `effect Arena { arena_exit() }`, ONE op. At the exit every
  handler around the arena that writes in place names its buffers with the
  primitive `arena_keep(xs)` (typed by `xs`'s element, per call) and
  forwards; `arena_root` terminates at the program's root. No world walk, no
  record evacuators, no slot enumeration.
- THE EXIT: T = heap top after the protocol. A check pass over the journal:
  every entry whose slot holds a value in [M, T) must be typed or lie in a
  claimed buffer — else the arena KEEPS its region (nothing moved, narrated
  on stderr with the buffer), which is sound for any program. Then
  copy-then-slide: journal roots evacuated through their types (TEMP
  addresses, root log), the result through its leaf, Cheney drain over the
  copy log (internal pointers written FINAL), memory.copy down to M, roots
  fixed, [M + S, high water) zeroed, heap = M + S. Nested arenas keep the
  entries whose slot lies below the outer mark.
- FoldEvac — the fifth fold leaf: `$evac_<sig>` (copy at exact size, mark
  forwarded in a bitmap, word 0 holds TEMP, log the scan if the type has
  pointers) and `$scan_<sig>` (evacuate the copy's pointer fields), for
  products (width-summed fields), sums (sentinel words below heap_base;
  [tag][payloads]), sequences (flat by runtime stride / snoc / concat /
  slice; a wide element in a word slot is a box8 cell), box8; function and
  continuation values trap if young (the closure evac face is the peer).
- A spawning module with an arena refuses (per-instance regions are the
  named peer). The zero-stale contract is an EFFICIENCY matter now (a stale
  slot is valid, never dangling) — dead slots only cost copies.
- Placement: per judgment group; `arena_root` at the wheel's root chain.
- Named: `Hβ.arena.region-typed-mutation` (Mutate(ρ) + masking makes the
  journal's check static), `Hβ.arena.closure-evac-face`,
  `Hβ.arena.per-instance-regions`.

## AN-1 · AN ARM'S VALUE IS THE INSTALL'S VALUE — `Handler(instance, answer)` (LANDED `26a76538`, pin `311479e1`; AN-2 LANDED after it, `f0ffcfb5`, pin `e7f6e2b9`)

**Found (C×A's "next"), measured on boot cf8a6d50:** (a) `handler h { bail() =>
"not a number" }` over `(bail() + 1) ~> h` compiles and runs — no install ever
meets the arm's answer (`mn-arm-answer-is-the-install`, refuse); (b) an arm
observing its answer (`a ++ b` over two resumptions) refuses
`E_ShapeUnprovable` because the BASE arm is emitted: the answer is no part of
an arm's key (`mn-arm-answer-observed`, 5); (c) a Float multi-shot answer does
not assemble — the driver reads the answer as a word
(`Hβ.continuations.redrive-reads-the-answer-as-a-word`;
`mn-multishot-float-answer`, `mn-multishot-int-op-float-answer`, 42 each);
(d) a box per crossing would be an allocation no row sees
(`mn-multishot-float-answer-no-box`: heap growth equal at Int and Float);
(e) an abandoning arm's answer never met its install either
(`mn-abandon-answer-refuses`); the per-install control
(`mn-handler-answer-per-install`, 42) passes on the boot; the arena leg
`tests/frontier/arena/float-value-reenters.mn` (42: r == 3.0, ArSuspended 1,
ArExits 2, ArKept 0) is written and not yet in the leg list.

**The form — one law, three halves, all WRITTEN (git diff on the tree):**
- TYPE (src/infer.mn): the handler's type is `TName("Handler", [inst_ty,
  TVar(answer)])` at `pre_register_handler_sig` (`answer_h`) and at
  `register_handler` (`s_h`, the cell every arm's value is already judged
  into, minted BEFORE the type), both quantified with the instance vars
  (`Frozen(inst_vars ++ [s_h], scheme_body)`); `handler_payload_ty` matches
  `[inner, _]`; `handler_answer_ty` reads the answer off a `Handler` or off a
  configured handler's `TFun` result; `install_answer(right, body_answer_h,
  span)` in `infer_pipe_tee` unifies it with the body's answer cell. Verified
  read-only: `build_inst_mapping` (infer.mn:8977) keys each quantified handle
  by its union-find ROOT, so an answer bound to an arm's variable still
  freshens per install — the generalization question is closed.
- KEY (src/lower.mn): `arm_pairs_of(jp, hexpr_h, cfg_hs)` returns
  `spec_pairs_sort(arm_pairs_walk(...))` — the face-roots exclusion,
  `arm_face_roots` and `arm_answers_its_driver` are deleted; the scheme now
  carries the answer, so the walk keys the arm twins at it as at the instance.
- FACE (src/backends/wasm.mn): the continuation face — a wide value crosses
  every boundary whose caller is blind to its type (the install's driver call,
  the re-drive perform `PdDriver`, the resume `emit_word_face_call`, and the
  `$wf$` wrappers of k's and driver-answered arms) in a per-instance LANE
  `$__lane_f64` with the word slot carrying 0, no heap cell:
  `emit_to_continuation` / `emit_from_continuation` /
  `emit_from_continuation_lane`, `emit_args_continuation` (replacing
  `emit_args_word`), `emit_continuation_wrapper` chosen by
  `speaks_continuation_face(base)` (`EfkK` → true; `EfkArm(op, _)` →
  `op_answers_its_driver(op)`); the twin loop and `emit_wide_wrappers` pass
  the base symbol. The runtime helpers between two segments — `$__k_compose`,
  `$__k_extend`, `$__k_arena`, the arena's sweep/close (`$ar_young(0)` is
  false, `$ar_final(0)` is 0, wasm.mn:4774/:4783) — are plain WAT that touch
  no lane, so a value in it crosses them as it left.

**AUDIT (2026-10-03, Morgan's eight lenses — each verdict against the
artifact, read-only):**
- *Carried truth.* The written type half mints the answer TWICE — `answer_h`
  at pre-registration and `s_h` at registration — two cells for one fact.
  `register_handler`'s own comment (infer.mn:12293) states the law for its
  siblings: "the main walk READS the pre-registered r_handle from the env so
  forward references share the same residual row handle". The answer takes
  the same route (step 0). The lane holds a value in ONE home (the word slot
  carries nothing, never a copy). The sole re-derivation in the emitter is
  the five-arm width floor written three times (step 6).
- *Elegance / simplicity.* The form is three deletions or reads: the type
  reads a cell that already existed, the key deletes a compensation, the face
  replaces a box with a register. The positional-lane idea in the first
  draft of step 2 was the one addition — struck: the yield's argument record
  is a PRODUCT and a product's layout is its widths (§5.U); a 0 standing in a
  slot for a value held elsewhere is a lie in a record. One lane, for the two
  crossings that have no slot at all (a resumed value, an answer). The
  install itself may be ONE unify (step 6).
- *Mentl's novelty, against the SOTA.* The TYPE half is PARITY, not novelty
  — Koka's `handler<e,a,b>` and Effekt's typed handlers carry the answer, and
  Mentl was behind (no install ever met it). Three things are past the field:
  (i) arms twinned per install at (instance, answer) — total monomorphization
  THROUGH effect handlers, the proof becoming the dispatch at the handler
  layer, where Koka boxes in polymorphic code and OCaml 5 boxes floats at
  every effect boundary; (ii) the continuation face — a word-faced
  continuation ABI with a float register beside it is the SysV ABI's split
  register classes read into wasm (words in the integer slots, a double in
  XMM0), zero allocation and no runtime type tag; the typed alternative,
  WasmFX's `cont` types, is unavailable and would twin the composer and the
  driver per chain; (iii) a refinement read THROUGH an install's answer
  (step 4) — no handler language has refinements and no refinement language
  has handlers.
- *Developer experience (the tentacles).* QUERY: `mentl where <handler>`
  renders `Handler(Fp, Float)` — what a handler answers becomes a projected
  fact; the tee's caret read names the install's answer. WHY: the refusal's
  Reason names the law ("an arm's value is the install's value") and the
  chain reaches the arm whose value disagrees through the answer cell's
  binds. VERIFY: the hole step 4 closes. PROPOSE: an arm's hole beside a
  ground sibling arm is bounded by the shared answer cell now (a felt check
  on `Hβ.infer.arm-body-cell-is-free-at-propose`, not a closure claim).
  UNLOCK: the row does not move; the no-box fixture is the receipt that the
  face charges nothing. TOPOLOGY, TRACE, TEACH: untouched.
- *Mentl's ideal form.* `Handler(instance, answer)` is the kernel shape — a
  handler is a value with what it handles and what it answers, as `TCont(R,
  S, …)` carries R and S — not a function type over the body (the tee is a
  form that governs its left and thunks it, never an application). The face
  is the honest machine form, not a workaround: wasm has no registers, so a
  per-instance global IS the register, with the `$__dt` protocol as the
  precedent. The one standing imprecision is pre-existing and shared with
  the instance: a forward install judged against the pre-registered scheme
  instantiates a fresh answer the arms have not yet bound.

**Remaining, in order (one landing, one board, one pin):**
0. **ONE answer cell.** `register_handler` reads the answer cell off its own
   pre-registered entry's scheme body (`handler_answer_ty` applied to the
   `env_lookup(hname)` scheme — the r_handle precedent five lines below it)
   and `let s_h = mint(...)` is deleted; the arms are judged into that cell
   and the post-arm re-generalization quantifies it when it stays free.
1. **The last emitter site — `emit_arena` (wasm.mn:4916).** The re-entry's
   leaf for the arena's value reads the continuation face: a wide value is in
   the lane and the word carries nothing, so the leaf is `LfWord` ("nothing to
   move"), never `LfBoxed` — `match evac_of(t) { EvWide => LfWord, _ =>
   evac_leaf(t) }`. Then `$__k_arena` (`emit_arena_reentry`, :4854–4858)
   loses its `-3` / `$ar_box8` arm (`mv = k > 0`): a re-entry never meets a
   boxed float now; the arm was correct by ACCIDENT (`ar_young(0)` false,
   `ar_final(0)` = 0) and the forensic law makes the accident a contract.
   `$ar_box8` stays for the journal's wide list slots.
2. **The yield's argument record is a typed product; the lane stays one.**
   Reading the yield site found the sibling gap: a multi-shot op's WIDE
   ARGUMENT does not assemble — the record parks every argument through the
   i32 `$state_tmp` at word offsets (`emit_yield_arg_stores`,
   wasm.mn:7073–7080; its own comment: "a non-word op arg meets the arm's
   loud call mismatch"), the driver loads words (`emit_driver_arg_loads`) into
   a word-face `call_indirect` (`redrive_vectors`: `(2 + arity) × RI32`).
   The record is a product and takes its widths: 8-byte slots, each argument
   stored at its own repr by the site (`tail_expr_repr`); the driver still
   pushes the word of each slot (a wide slot's word is unused — the driver is
   blind by design, one per handler); an arm's continuation wrapper reads a
   wide parameter from `$yield_args` at its slot (`f64.load offset=8*j`), as
   the k wrapper reads its one value from the lane. The record is live until
   the arm has read it, and a re-drive inside the arm writes a new record
   only after the outer arm has bound its parameters. The ordinal to settle
   by reading the arm emission: the arm's vector is `[k, args…]` after
   `__state`, so parameter j+1 is argument slot j. Fixture RED-first on
   cf8a6d50 (does not assemble): `tests/micros/mn-multishot-float-arg.mn` —
   `effect Ch { choose(x: Float) -> Float }`, arm `choose(x) => resume(x) +
   resume(x * 2.0)`, body `choose(1.5) + 0.5` = 5.5 → 42. Nothing between a
   lane's set and its read speaks the face: the driver loop calls one arm then
   returns; a resume sets the lane immediately before its `call_indirect`; a
   nested re-drive sets and reads around its own call and the outer arm reads
   the lane the instruction after the inner call returns.
3. **`proc_exit(Int) -> !` in lib/io.mn's `WASI` effect.** SYNTAX: a
   never-returning op declares `-> !` (a bare variable, as `abort`'s and
   `fail`'s answers are; there is no bottom in `Ty`); its emit is already
   `(call $proc_exit)(unreachable)` (wasm.mn:7489), stack-polymorphic at any
   width, and `wasi_import_reprs` keeps `None`. Today `fail_exit`'s arm answers
   `()` by the coincidence of proc_exit's unit, so after AN-1 any install of
   `fail_exit` over a non-unit body refuses; the wheel's two installs
   (pipeline.mn:183, :563) answer `()` through `compile_remainder` and pass
   either way. Fixture RED-first on the candidate before the io.mn edit (refuse
   `E_TypeMismatch`), then green: `mn-never-op-answer.mn` — `let n: Int =
   (fail("x")) ~> fail_exit`-shaped, `// expect: 1` (proc_exit(1)).
4. **A tee's value is every value its install can answer — the Verify walk
   reads the arms.** The law AN-1 states exposes a false absence proof the
   value walk makes today: the leaves of a `~>` node are the body's tails
   alone, while an abandoning arm's value IS the install's value. `fn g()
   with !Trap = 100 / (({ let _ = ask(); 5 }) ~> zero)` with `handler zero {
   ask() => 0 }` — the body's one leaf is `5`, the division is PROVEN
   nonzero, and the program divides by zero (MEASURE on cf8a6d50 before a
   line: compiles under `!Trap` and traps; the fixture canonizes whatever it
   shows). `value_leaves` at a `~>` node answers the body's tails and each
   arm body's tails of the installed handler (`graph_install_at(h)` →
   `InstallOf(hname, …)` → the arms off `HandlerKind`), one arm in the one
   walk, so every reader — refinements, the `!Flow` label, `fn_leaves`,
   `claim_leaves` — reads it. A resuming arm's value is a computation over
   the remainder's answer and reads as its own tails. Fixture
   `mn-refine-install-answer.mn` (refuse `E_EffectMismatch` under `!Trap`)
   and a `!Flow` twin if the label walk shares the hole (measure).
   Preempts by the soundness law: §0's property (2) false at the "catch with
   a default" shape every program writes.
5. tools/frontier-gate.sh:1690 — add `float-value-reenters` to the arena leg
   list (42).
6. **Simplifications, in the same edit:** (a) one `lane_of(r)` projection —
   the lane's name for RF64, the named floor for the widths with no producer
   — read by `emit_to_continuation`, `emit_from_continuation` and the wrapper,
   each a two-liner; (b) one reader `handler_parts(ty) -> Option((inst,
   answer))` serving the payload and the answer, the `TFun` arm deleted (the
   payload reader never needed it); (c) ATTEMPT the one-unify install: if
   `unify_payload_in_names` is the structural unify of the performed instance
   it reads as, the whole install is ONE `unify_types(TName("Handler",
   [performed_instance, TVar(body_answer_h)]), lookup_ty(rh))` and
   `handler_payload_ty`, `install_answer` and the per-position loop
   collapse; if the instance half carries a rule the structural unify does
   not (the instance join of `inf_install_absorbs`), keep the two reads and
   say why in the one comment.
7. `mentl fmt` every edited `.mn` (infer, lower, wasm, verify, io, the
   fixtures); build m2 and run the battery (`bash tools/march-gate.sh
   --micros`); the AN-1 fixtures (now ten micros + one arena leg) and every
   arena leg through m2; the RED ones go green, the control stays.
8. **The m3 leg — fallout class to expect and fix honestly:** every handler
   whose arm's value no install ever met. Candidates by `provider of`:
   `catch_abort` (own:33, installed at search:104), `pick_first` / `backtrack`
   (`choose`), the eleven `result` providers (they resume, so the answer is the
   body's — no mismatch expected). Each refusal is the arm's claim trued or a
   real wrong, never a cast at the arm. `mentl check src/main.mn` at zero.
9. Gates: micros, crown, proof-exactness, frontier `--compiler fresh`,
   drift-audit, IDE gate; the fixed-input cost reading (boot vs m2 over one
   wheel source); `bash tools/heavy-lock.sh release`; `MARCH_REPIN=1 bash
   tools/march.sh` (TRANSITION expected: every handler scheme, every
   multi-shot yield record and every wide k/arm wrapper moved).
10. Records and the felt checks: `mentl where` on a fixture's handler renders
   `Handler(Fp, Float)`; the eight-aspect read at a tee names the install's
   answer; `mentl why` at a refused install reaches the arm. SYNTAX
   (§Handler declarations — the handler's type is `Handler(instance,
   answer)`, an arm's value is the install's value, with the measured shapes;
   §«A perform costs what a call costs» — a wide value crosses a continuation
   in a register, never a box, and a multi-shot op's arguments cross at their
   widths; the never-returning-op sentence gains proc_exit; §Refinement types
   — a tee's value is every value its install can answer); RESIDUE (close
   `Hβ.continuations.redrive-reads-the-answer-as-a-word` at both faces and
   the answer clause of `Hβ.emit.arm-twin-converts-at-its-face`; the KILLS;
   name the forward-install imprecision beside the instance's if no peer
   holds it); PLAN §7 bullet; LEDGER head entry (pin, cost line, kills, fixed
   input, gate counts — every number read this turn); PROGRAM entry; the row
   above; boot/PROVENANCE.md narrative; `bash tools/doc-truth.sh`; `bash
   tools/state.sh`. Commit (no attribution), `git push -u origin
   claude/mentl-design-audit-m1mptf`.

**KILLS so far (into the landing record):** (1) "the answer is a word the
driver can read" — the Float multi-shot fixture refused to assemble on
cf8a6d50; (2) "box the answer at the face" (the `emit_wide_ref` form) — a cell
per crossing, 16 B per resumed value and answer, under no row; the no-box
fixture is its contract; (3) "keep the base arms when a face root is wide"
(`arm_face_roots`, R0c's compromise) — deleted: the answer keys the arms;
(4) the re-entry's box8 arm — correct by accident, deleted by contract;
(5) "N positional lanes" — the argument record is a product and takes its
widths; a lane is for the two crossings with no slot; (6) "two mints, one
answer" — the registration reads the pre-registered cell as it reads
`r_handle`.

**THE BUILD'S OWN FINDINGS (2026-10-03, first three m2s):** (7) the step-4
"soundness hole" was REFUTED by the boot before a line: a tee read as
unknown is debt, not a false proof — the fixture's contract is the
refutation (`E_RefinementRejected`) and its proven twin (exit 20) is the
precision witness; the IFC face IS a hole (the leak compiled clean on
cf8a6d50: the label walk joined the tee's children) and is red-first in
the frontier's dcc block. (8) The install column (`graph_install_at`) is
the LOWERING's, written after every claim is decided — the verify walk
reads the handler off the tee's right node (`tee_handler_name`). (9) The
arm header read the handler's instance through a one-argument `Handler`
match (`handler_decl_instance`, lower.mn) — `None` under the two-argument
type, so every arm twin signed its op parameters at the word floor under a
body reading f64 (nine battery fixtures, `$x.f64` undefined). (10) The
resume-value and update scratches were declared at the RESUME node, whose
type is the handler's answer, and read at the value's node — the same
name while the answer was a free floor var, two names once an install
bound it (`resume_commit_prefix` declares at the value's node now). (11)
`mn-backtrack-full` ran on a type confusion: `twac` answered an Int
wearing an Option's type and the root `~> my_catch` answered `None` over an
Int body — the judgment refuses `Int vs Option(t)` at the install, and the
fixture answers the Option its arms do, unwrapped once in main. (12) The
Int-op/Float-answer fixture cannot be written on the spine (the conversion
is a call around the perform, `E_ContinuationUncapturable` at both the
`if` and the `match` shapes) — deleted; capture at every position admits
it. (13) A duplicate `fn_record_name` and a one-argument call of the
wrapper emitter from the derivative twin: the boot refused the first m2
with three type errors.

**THE FOURTH m2's THREE CLASSES (366 judged, 6 broken), each closed before
the fifth build:** (14) the two `__k` resolvers (`resolve_resume_k`,
`resume_k_arg`) named the k local through `local_ty_handle(lh, handle)`
with the k binder at handle 0 — i.e. at the RESUME node's type, which under
AN-1 is the install's ANSWER — so a Float answer declared `$__k.f64` where
the arm's parameter is `$__k` (three wide multi-shot fixtures: "unknown
local" at the `$__k_world` read). A continuation is a record pointer, a
word, read at handle 0 as `__hrec` is; the resolvers no longer ask the
rule and `local_ty_handle`'s comment names its three readers. (15) The two
init-refusal fixtures fell to `E_EffectUnhandled` alone: `E_InitPerformsOwnOp`
rode the dispatch's NAMED arm (`ArmNamed`), which `handler_may_key` withholds
from any handler whose scheme quantifies a variable — every resuming
handler, once its answer is quantified — so the announcement never fired.
The uniqueness of an op's provider is the op's own fact
(`lower_op_default_handler`); `preinstall_init_scope` reads it at the
demand, and `visit_direct_perform` — announced by `PdFrame` and `ArmNamed`,
compared by one listener, ignored by the other — is deleted whole with its
two announcements. (16) The refutation contract (`mn-refine-install-answer`
wanted `E_RefinementRejected`, got `E_EffectMismatch`): the claim decider
read a tee through `join_tails` alone, so the tee was no join and the claim
stayed OPEN (debt → `Trap` → the row refusal) instead of being refuted by
the arm's `0`. One `value_tails` — a join's tails, or a tee's body and
arms — is the home every value walk reads structure through
(`decide_with_self`, `value_leaves`, `expr_path_read`, `value_flow_label`,
`fn_leaves`, `arm_tails`); the three separate tee arms written on the way
are deleted; `note_claim` keeps `join_tails` (a handler's arms are shared
by every install, so a claim noted there would claim for all of them). An
arm installing its own handler is a re-entry: the arms met again add no
tail (the least fixed point, exact), through `StateWalk` keyed by the
handler's residual row cell. (17) The first key written for that guard was
`decl_named(hname)` — a by-name scan of the decls column, declared in
query.mn, which verify cannot import (infer → verify → query → infer
would cycle): `E_MissingImport` refused it before a line ran, and the
answer was already on the env entry — `HandlerKind`'s first field is the
residual row cell, minted once at pre-registration, the one cell every
reference reads the handler through. The gate caught a scan.

**THE FIFTH m2 (366 judged, 4 broken — the init class closed):** (18) the
three wide multi-shot fixtures still did not assemble: the resume's
`$__rk_val_{h}` scratch was declared `i32` by `walk_locals` while the
continuation face hands the answer back at its width (`local.set`
expected i32, got f64); the scratch is declared and named at the answer's
repr (`local_wat_name`, `repr_wat`), the one decider every local reads.
(19) The refutation contract: `node_excludes` answered OPEN whenever a
leaf failed to exclude the point — `leaves_exclude` was a Bool, so a leaf
that IS the fatal point (the arm's `0`, a join's `0` tail) was debt, never
a refutation. The leaves decide three-valued now (`and_decide` over
`leaf_excludes : Option(Bool)`): a point leaf equal to the fatal point
refutes, every leaf excluding it proves, anything else is open — the same
law as a claim over a join, which refuses at the tail that folds false.
SYNTAX's partiality table gains the row.

**THE SIXTH m2 (366 judged, 1 broken):** (20) the only flip was S5's own
`mn-state-reset-owes` — an arm writing `d = 0` beside `100 / d` — which the
three-valued fragment REFUTES (`E_RefinementRejected` at the division)
where the Bool fragment had left it OPEN and `!Trap` caught it. Re-derived
by hand (Law 11): S5's law says a state "owes `d != 0` of every write", a
writer that is the fatal point fails it, and the program divides by zero
(exit 134 on the pin that banked it) — the refutation is the stronger
verdict and the fixture is re-banked to it, its comment trued; SYNTAX's
state paragraph gains the sentence.

**THE SEVENTH m2 — THE FELT CHECKS, each a fill (2026-10-03):** (21) the
install's refusal said `Int vs List(Byte)` and nothing of the arm: the
mismatch reporter's own signature took the unify's Reason and dropped it
(`type_mismatch(a, b, span, reason)` reported `ETypeMismatch(a, b, span)`);
the diagnostic carries its Reason now (`ETypeMismatch(Ty, Ty, Reason,
Span)`, `reason_line`), the install's reason is the arm whose value is its
own (`install_reason` / `answer_reason` over `arm_tails`; the attachment
itself when every arm resumes), the one reason the tee node is bound with —
`Int vs List(Byte) — ~> pipe → at 15:13-15:27: inferred from the arm bail of
handler h`, and the caret's Why at the tee reaches the arm. (22) `where`
rendered a handler without what it answers, a function's install line
without what the install answers: `handler zero absorbs Ask, answers Int`,
`handler ticker absorbs Tick, answers a`, `~> ticker absorbs Tick, answers
Int at …` now (`handler_answer_of`, which `prereg_answer_cell` reads
through). (23) the first reader was named `arm_answers`, which query.mn
declares with two parameters (`provider of`) — the boot refused query.mn's
link at `arms_for_op`; one namespace, one name (`arm_own_value`). (24)
`infer_pipe`'s unreachable PTee arm bound the tee's reason a second time
under "today we don't have handler-value typing" — deleted. Frontier where
legs updated and added (RED on cf8a6d50 by construction). Micros 366/366 on
the seventh m2 (ea30a8f3).

**Adversarial pass:** inline (the last dispatch died on the rate
limit, and Morgan's rule dispatches no other model) — recorded as such.

**Then AN-2 (task #153), a landing of its own:** `RNone` always abandons; a
dead-k yield unwinds from any position (a structured branch to the nearest
landing, never a bare return past a bracket); a live-k yield through an
off-spine call refuses at the settle point. Fixtures from the probes
`bottom-arm.mn` (exit 100: a non-resuming arm of a bare-variable op graded
OneShot returns its value to the perform) and `abandon-offspine.mn` (134 at
the k2 floor).

## Step 5 onward · the program, in its order

A5 (LANDED) · **Step 7's sprint: L0 the two soundness refusals → L1
arithmetic on type → L2 the owned ring line → L3 Pulse scene 1 → L4 the
demanded AD projection → L5 A6** · A7 (the
theorem's mechanical obligations as fixtures) · C4 (acceptance draws an edge —
the page's Propose socket becomes a graph edit) · C5 (DONE: partiality is a
row fact, pin `b1637650e3cd3157`) · C6 (DONE: the question is read off the
trail, pin `2fcad4e9e7f987f5`) · C7 (DONE: the proposal battery, 24 fixtures,
pin `6f2ce4378786e53f`; the first
divergence from the trail — the computed question's true source) · B4 + C9
(DONE: pin `477bb667dfab178d`, TRANSITION) · D3–D5 · E2 (the session keeps its graph) · E4 (DONE: eight facets at the
caret, pin `9d27c325ab2f23ee`) · **the arena, with lowering as columns
designed beside it → positions are cells → Verify's own solver** (THE ORDER
FROM E4, PLAN §11) · E6 (the Severance Map, three colours — over `examples/pulse`; its
"not yet provable" band is exactly the set of cells no gate reached, which
A3 makes countable) · B2–B4 · Pulse scenes 2–4 (real-time shape; the effect
that learns; authoring), each the acceptance test for the C/D/E landings
beside it.

## Where the envelope moves

- **The gate is one mechanism for four arms.** A gate is "a constraint on a
  cell, meet-closed, checked at the one writer, pushed through structure".
  That is also what a refinement obligation on a type cell is (Phase 8.2), a
  flow constraint `!Flow(Secret, Log)` on a row (Phase 7), and an ownership
  grade bound. A3 builds the mechanism with the row negation as its first
  instance and the `Gate` ADT shaped to take the others, so `!Flow` lands as
  a second arm of the same column rather than a second subsystem.
- **Propagation precedes enumeration, for rows, for free.** With gates on
  cells the ??-fan reads the hole cell's gate BEFORE building candidates: a
  hole under `!E` never enumerates E-performing vocabulary (11.1's first
  bullet, delivered by A3 rather than by the fan).
- **The root gate becomes the Severance Map's truth.** Once the row alone
  decides the executable, the map's bands are projections of a proof, and
  the thirty-second demo (a module banded green with `!Network` proven, one
  call added, the band turns red and the compile refuses with the Reason
  naming the call) is a compile, not a rendering.

## Verification, per landing

`verify.sh --preflight` at every edit through the hook · m2 build · crucibles
RED against the prior boot, then green against m2 · `MARCH_REPIN=1
tools/march.sh` (verify --wheel, m3, m4 on transition, the memoized board,
the pin block) · narrative written · `tools/state.sh` · commit and push. One
landing = one board = one repin.
