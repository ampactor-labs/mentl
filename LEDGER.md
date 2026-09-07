# Mentl — LEDGER.md · the landing record

> **REFERENCE, NOT READ-PATH.** The three-document contract is unchanged —
> `CLAUDE.md` (method), `PLAN.md` (substance), `docs/SYNTAX.md` (surface). This
> file is the fourth thing you may *consult* and must never *read whole*: the
> mechanics of every landing since first light, newest first.
>
> **Why it left `PLAN.md` (2026-08-05).** It was 7,002 of PLAN's 10,809 lines —
> 78% of the substance document was a hand-written prose copy of 448 commits.
> That is the Carried-Truth Law violated at the doc layer, and §7's own destiny
> sentence had said so for months ("state as projection, never a hand-kept prose
> ledger"). Holding it in the read path cost every session the context to carry
> it and bought nothing `git log` does not already hold. The cut is structural,
> not editorial: no entry was deleted, and none was edited.
>
> **What it is for.** One question: *what actually happened at pin X, and why?*
> Reach for it when a pin's mechanics matter — a fix's blast radius, why a form
> was chosen, what a measurement showed. Reach for `git log` when you want the
> diff. Reach for `PLAN.md` when you want what is TRUE.
>
> **What it is NOT for.** It is not a roadmap (that is `PLAN.md §11`), not a peer
> catalog (that is `RESIDUE.md`), and not authority. An entry records what one
> session measured on one day. Where an entry and the artifact disagree, the
> artifact wins and the entry is history, not a claim.
>
> **The one live coupling:** `tools/doc-truth.sh` reads the head pin from this
> file and asserts it equals the boot sha prefix. Moving or reformatting the
> head entry breaks that check, which is the point — the pin chain is
> mechanical.
>
> **Its own destiny is deletion.** Every line here is a projection the medium
> should make of its own history — `Hβ.query.generation-operand`: every
> projection takes a WHEN. Until `mentl why --at <sha>` exists, git is the
> outside time oracle and this file is its prose shadow.

### The landing ledger (newest first; · pin = boot re-pinned)

- 2026-09-07 · pin 8fb668de4613c1a2 · THE CHECK CHASES, SO THE BUILD CAN
  SHARE — and three configurations measured where rung 3's real wall is.
  verify green, march CLEAN m2 == m3, census 0, cost 17.85s / 2252MB.
  ▶ WHAT LANDED. subst_changes answered TRUE for every bound var, and in a
  judged decl most vars ARE bound, so check-then-build was present and never
  got to answer no: every polymorphic reference rebuilt the callee's whole
  type tree (`Hβ.infer.instantiate-shares-never-clones`, whose cost the docs
  place on the allocation channel). The check follows the edge now and asks
  whether the CONTENT changes — a bound cell holding no mapped var answers
  false and its subtree shares; only a path reaching a quantified var
  rebuilds. The opposite error was BUILT and measured first: answering by the
  mapping alone leaves a quantified var behind a binding unseen, and
  polymorphism severs silently.
  ▶ THE WALL IS THE READ PATH, and three configurations name it. Publishing
  the decl's CELL instead of a Frozen snapshot compiles clean at census 0
  every time, and the resulting m2 fails to compile the wheel three
  different ways: (a) with generalize's chase_deep intact — OOM through
  chase_row_deep / chase_edges_deep / tail_set_union / alloc, because a fold
  that ran once per DECL now runs once per USE; (b) with a shallow head and a
  non-chasing free_in_ty — the quantifier reads the param CELLS themselves,
  over-quantifies, and a judge branch exhausts its planned mint band
  (graph_fresh_ty's loud `load_i32(0 - 1)`); (c) with a shallow head and a
  CHASING free_in_ty — still the mint band, because chase_deep is bounded at
  d > 200 and an unbounded walk is not. That last one is CLAUDE.md's own law
  arriving as a bug: the three "vars of a type" walks must AGREE.
  ▶ THE ROOT UNDER ALL THREE, and Morgan's question named it before the
  measurement did — "the word chase makes me feel like work that doesn't
  need to be done is being done; isn't everything a record, and don't
  records carry all the information needed?" They do, and a stored LINK is
  precisely a record failing to carry it. graph_compress_row's own comment
  is the proof: path compression is "an OPTIMIZATION WRITE", and "a BRANCH
  cursor SKIPS it, because a branch rebinding shared chain cells makes
  sibling chases schedule-dependent — the measured k2 yield-floor flips at
  window 8 traced to exactly these writes (1,463 foreign row binds)".
  So: chase-with-compression is a READ THAT WRITES; parallel readers cannot
  write; compression is therefore disabled in branches; branches re-walk
  uncompressed chains; and under live publication that re-walk is the
  re-fold that OOMs. The chase is not merely wasted work — IT IS WHAT MAKES
  READ-ONLY PARALLELISM UNSOUND, and it is why the multi-cursor fan cannot
  simply be turned up.
  ▶ WHERE SOTA SITS AND WHY MENTL LEAVES IT. Union-find with path
  compression is O(α(n)) amortized and e-graphs (egg's deferred rebuild) are
  its batch form — both optimal FOR A SINGLE-THREADED MUTATOR, and both
  depend on read-side mutation. Mentl's setting breaks that assumption four
  ways: ONE writer (inference), MONOTONE refinement, a flat handle-addressed
  image where a chase is a pointer walk across the cache-hostile working set
  §5.O names as the constant-factor amplifier, and N parallel readers
  WANTED. There, canonical-on-write dominates: the writer pays once at the
  bind, every reader does a direct load, reads are PURE, and N cursors read
  lock-free with no atomics and no branch guard. The law is already in the
  artifact at half strength — graph_bind_row stores flatten_row_stored,
  depth-1 by invariant at the WRITE — while reads still re-fold and the TYPE
  sort does not do it at all.
  ▶ NEXT, forced: move compression to the WRITE path and delete it from the
  read. resolve_row calls graph_compress_row today (a reader writing);
  graph_bind_row is where it belongs (the writer compressing what it just
  walked). Then branch reads are pure, the branch guard disappears, the
  re-walk disappears, and publish-Live becomes affordable — which is rung 3,
  the fan's shared context, and the parallel cursor, all unblocked by one
  relocation.

- 2026-09-06 · pin 41aec80bddfe2ce2 · THE WARM PATH WAS HALF-KEYED, AND THE
  GATE THAT KNEW IT STOPPED ONE LINE SHORT. frontier 374/0, verify green,
  march CLEAN m2 == m3, census 0, cost 15.16s / 2148MB.
  ▶ THE PRIOR ENTRY IS CORRECTED, not amended. It said "board whole, every
  gate green," and that was true AS MEASURED and wrong. The pin it blessed
  shipped a broken incremental compile.
  ▶ THE BUG. f58dfc10 moved module identity onto the resolved path and took
  the tree scan and the manifest with it — but split_weave_by_module still
  bucketed the analyzed statements by NAME. assoc_stmts then answered EMPTY
  for every cached module, so the warm path emitted the cone alone: 2933
  bytes where the cold compile of the same tree is 37644, `a` and the entire
  prelude gone. That is the SAME half-keying the prior entry warned about in
  its own prose — "a half-keyed graph is the same defect wearing an ordering
  costume" — written by someone who had just missed a fifth site. Knowing the
  shape of a class does not find its members; only a measurement does.
  ▶ WHY IT RODE A PIN. tests/frontier's warm-inc leg has exactly the check
  that catches this: incremental output vs a cold compile of the patched
  tree, byte-compared. It did not run. The cone-line check above it went red
  on a RENDERING change — the cone prints `b.mn main.mn` now, because it
  carries the identity — and the leg `return`ed. So a cosmetic red masked a
  correctness red sitting one line below it, and the board reported the leg
  as a single failure that looked like mine to re-bank.
  ▶ THE FIX IS TWO LINES AND ONE OF THEM ISN'T THE BUG. split_weave_by_module
  keys the bucket by the range tuple's PATH (the tuple already carried both;
  range_of_module keeps matching the NAME, because that is what a user types
  at an address). And the leg no longer returns on an independent failure.
  The second is the one that matters: a leg that halts at its first red hides
  the rest of its own coverage, and only a genuine precondition — no artifact
  to read — earns an early return. Two legs in this file still return; both
  are real preconditions (a failed compile has no wat to diff).
  ▶ A DIAGNOSTIC THAT COULD LIE, in the gate built to catch those. The census
  leg fans its queries through xargs and threw away every child's stderr and
  exit code, so a query that DIED was indistinguishable from a shape that is
  genuinely absent — and the judge blamed the shape. It records the exit now
  and says QUERY DIED, and the failure message names the pid-suffixed files
  that exist instead of an unsuffixed path nothing ever wrote.
  ▶ ONE UNRESOLVED, NAMED RATHER THAN GUESSED. The board's census-40 red did
  not reproduce on a clean dir (372/1, then 374/0). A SIGPIPE-under-pipefail
  hypothesis — grep -q short-circuiting the cat feeding it — was TESTED at
  200 iterations and did NOT reproduce; the outputs are ~100 bytes, too small
  to race. No cause is banked. What landed instead is the instrument that
  will name the failure if it returns, which is the honest move when a probe
  disproves you: do not crown the next thing you see.
  ▶ THE MEASUREMENT THAT ANSWERED THE LTS QUESTION, banked here because it
  reframes a named peer. The same spawning module through two runners:
  wasmtime 47's CLI answers `Error: the -Sthreads flag is no longer
  supported` and exits 1; 36's runs it to 60. The CLI cannot execute Mentl's
  own output past 36, so the LTS pin is a CEILING, not a preference, and
  every release after it is unreachable while the CLI is the runner.
  Hβ.ops.wasmtime-runner-migration steps (5)-(6) are therefore not hygiene;
  they are the only exit. tools/runner builds clean here against wasmtime 47.
  Its own next_tid counter is the projection tools/thread-gate.sh currently
  rebuilds from strace, which is Hβ.march.concurrency-is-a-projection with
  the substrate already written.

- 2026-09-06 · pin f58dfc1070f5c7a5 · A MODULE'S IDENTITY WAS THE SPELLING
  THAT REACHED IT. Board whole (verify green, march CLEAN m2 == m3, frontier
  374/0, crown 62/0, proof-exactness 9/0, effect-identity PASS, instrument
  reads); census 0; cost 11.19s / 2148MB.
  ▶ THE FIND, from a wrong turn. Building a positive control for an
  unrelated gate, a concatenated lib blob was fed to `mentl compile <file>`
  and refused with E_DuplicateTypeName on `type Bool`. The blob was
  malformed — the file path resolves imports, so prelude arrived twice —
  but the interesting half was that the SAME BYTES through stdin compiled
  and ran. Two transports, two meanings. Probing that split found the root
  one layer down and much worse: `import lists` checks clean at 0
  diagnostics, `import lib/lists` refuses with 58. One file. Two spellings.
  Two module identities.
  ▶ THE ROOT. driver_collect_visit keyed its visited set by the module NAME
  and called driver_module_path on the very next line. So both spellings
  passed the check, the same source was collected twice, and every
  declaration in it collided with itself. An import is an EDGE; drawing an
  edge that already exists is a no-op, which is what an edge IS. The walk
  was drawing a second one.
  ▶ WHY NO GATE SAW IT — tripwire 3, whole. The wheel's own build is the
  cat-blob through stdin, which never resolves an import at all, and every
  lib spells its siblings bare (`import lists`, no prefix). So the wheel
  never once resolved a path-prefixed import, and a user's first one is red
  on line one. The board was green in the same minute `mentl check` refused
  a four-line program.
  ▶ THE FIX IS ONE KEY AT FIVE SITES, and the fifth is why it is not
  smaller: the visited set, the dep edges, the layer partition's wait
  condition, the tree scan's downstream closure, the entry filter. Fixing
  only the visited set would have been WORSE than the bug — a name-matched
  dep edge against a path-keyed DAG is DROPPED, and the partition then runs
  an importer before its dep. A half-keyed graph is the same defect wearing
  an ordering costume.
  ▶ IT DELETES, three times, and each deletion was already named in this
  file's own header as fixed for every OTHER consumer of the walk:
  driver_check_module was re-resolving a path the walk had resolved (up to
  five fs_exists probes per module) and re-reading a file the walk had read;
  rederive_cone was resolving a name that was already a path. The per-module
  check was the last consumer still following a name. Net code +8 lines —
  the additions are the ModuleEntry alias and the path-keying, and the
  commit says so rather than claiming a deletion it did not make (Law 11).
  ▶ THE PERSISTED MANIFEST keys on the same identity, so the first warm run
  after this sees every hash as new, re-derives once, and re-persists with
  paths. Self-healing, one cold run.
  ▶ GATE, born RED: tests/syntax/import-path-spelling.mn — 58 errors through
  the manifest link while the identical source is silent through the blob
  link. That divergence is precisely what the syntax battery's manifest leg
  was built to catch, so the gate needed no new harness; it needed a fixture
  nobody had thought to write. 58 → 0.
  ▶ THE MEDIUM CONVICTED THE AUTHOR. The first draft wrote
  `map((dep) => driver_module_path(dep), …)` out of caution about passing a
  `ref`-param fn point-free. verify's anonymity ratchet went red — "eta rose
  28 → 30 — a named fn newly hidden behind a lambda." Point-free checks
  clean; the caution was superstition. That is `mentl audit`'s larval form
  doing its job on someone editing the wheel, which is the whole point of
  ratcheting a shape rather than reviewing for it. effectful_lambda_max
  385 → 384, holding the gain the same leg measured.
  ▶ A SECOND DEFECT, found because the board could not run. tools/wt-env.sh
  is SOURCED, so its wasmtime flag probe inherited the caller's shell
  options. Under `set -o pipefail` — which verify.sh sets and an interactive
  source does not — wasmtime's nonzero exit masked grep's MATCH, so the
  probe took the wrong branch and added the `-W shared-memory=y` that 36 LTS
  rejects; every gate run trapped with "unknown -W option". Invisible on 43,
  which wants the flag regardless, so there the wrong branch and the right
  behaviour coincided: the defect could only fire on the version this repo
  pins. A captured string matched with `case` has no exit status to inherit.
  The deeper reading is that the version fork itself is the liability, which
  is what Hβ.ops.wasmtime-runner-migration steps (5)-(6) already say.
  ▶ AND THE GATE THAT STARTED IT ALL: tools/thread-gate.sh, wired into
  state.sh. Nothing on the board counted a thread, which is why
  judge_window = 1 sat beside a spawn-per-branch for ten days with every
  gate green (433 threads on `fn main() = 7`). Three legs — a positive
  control that requires a really-spawning fixture to read above the floor
  (the first draft of it was VACUOUS: the fixture failed to compile,
  wat2wasm assembled the empty output, the run exited 0, and it "passed"
  having measured nothing); a DELTA ratchet between a 61-decl and a 1-decl
  program, so wasmtime's own host threads cancel and the gate measures us
  rather than the runner; and a two-draw byte compare, the leg that survives
  Phase 9.2 unchanged because a race's only symptom is the run-to-run
  variance that hid the 2026-08-07 garbled cell. judge_spawn_delta_max: 0,
  seen RED at ceiling -1. Retirement named:
  Hβ.march.concurrency-is-a-projection — the medium performs
  wasi_thread_spawn through its own effect and already holds the number this
  script rebuilds from syscalls.
  ▶ TWO STALE CLAIMS RETRACTED against the artifact. RESIDUE said a
  thread-free module "(boot included)" ships no thread-spawn import;
  wasm-objdump reads func[17] wasi.thread-spawn and a shared env.memory in
  the pinned boot, so boot is a spawning module by that taxonomy. And
  wt-env.sh's "it costs ~13 minutes" for the wheel compile measured 20s
  here — the perf arc's own win, never re-read into the prose that motivated
  it.
  ▶ THE SHAPE ALL FOUR SHARE, worth more than any one of them: a fact that
  was true when written, silently stopped being true, and no gate read it.
  judge_window beside a spawn-per-branch; "(boot included)" beside a boot
  that imports thread-spawn; a probe whose answer depended on its caller; a
  cost claim off by 40×. None were bad reasoning. All were unread
  measurements — which is the argument for projections over prose at exactly
  the altitude PLAN §0's fifth property makes the point.

- 2026-09-04 · (no repin — fixtures only) · E_EffectMismatch 15 → 5, AND
  TWO OF MY OWN CLAIMS RETRACTED. Battery errors 19 → 9; carriers eleven
  files → four; micros 149/149; verify green.
  ▶ THE PREVIOUS ENTRY WAS WRONG. It said the remaining 13 could not be
  fixed by widening, because a with-clause cannot say `Probe({record})`.
  Measurement: widening `fn run() with Probe` to `with Probe + Memory +
  Alloc` clears the ERROR outright, leaving a T_OverDeclared narration.
  The instance args never blocked anything — `eff_admits`
  (effects.mn:1105) answers TRUE for a bare gate name against any
  instantiated body name, so a bare `Probe` admits `Probe(τ)` by design,
  and has all along. Ten fixtures widened on that reading: the payload
  family plus mn-ev2/mn-ev4.
  ▶ AND A SECOND WRONG TURN THE PROBE CAUGHT BEFORE IT LANDED. `effect
  Probe { emit(x) -> Int }` declares no parameter list, so I read
  `Probe(Int)` as inference manufacturing an argument, and was one edit
  from treating that as the bug. infer.mn:8558 says the opposite in its
  own words: an effect's type params ARE the free type vars across all its
  ops' signatures, so a lowercase `x` declares one under the case rule.
  Removing it re-breaks what that comment names — "the payload type never
  flows performer→handler... the root of both the list-as-Int erasure and
  the emitter's heap-dump." A two-file probe (annotated vs unannotated op
  arg) isolated the variable and the site's own prose refuted the
  conclusion.
  ▶ WHAT REMAINS IS TWO REPORTS IN ONE FIXTURE (finished 2026-09-05).
  mn-backtrack-full's three were the same shape and widened the same way —
  `Choice vs Memory + Alloc + Choice(List(Int))` and its two siblings. 5 →
  2, battery errors 19 → 6, carriers down to three files.
  ▶ THE LAST TWO ARE A REFUSAL TO WIDEN, not an omission. mn-feedback-iir
  declares `fn accum(input) -> Int with Sample` and the medium infers
  `Memory + Alloc` — note the body row contains no Sample at all, which is
  what separates it from every other carrier. That is
  `Hβ.effects.feedback-row-substitutes`, and SYNTAX already records the
  measurement: the compiled WAT for a `Delay(N)` recurrence contains ZERO
  construction of the spec, so the `Alloc` is `infer_expr` walking the RHS
  as an ordinary constructor call at a site whose only load-bearing content
  is read statically. Widening would declare Alloc for a site that provably
  allocates nothing — trading a visible diagnostic for a silent lie in a
  fixture's own signature. E_EffectMismatch arms when that peer lands.
  ▶ THE REAL SURFACE BUG, smaller than the one the previous entry claimed
  and still real: T_OverDeclared ADVISES an unwriteable row. Over a
  polymorphic op it narrates "declares Probe but body only uses
  Probe(Int) — tighten the signature", and `with Probe(Int)` does not
  parse. `mentl tighten` consumes exactly these narrations, which is why
  the round-trip guard at pin 1aca4868 exists — the guard declines
  silently while the advice stays wrong. Banked as
  `Hβ.diag.over-declared-advises-an-unwriteable-row`.

- 2026-09-04 · (no repin — fixtures only) · THE LAST CROWN CLASS IS BLOCKED
  BY THE SURFACE, NOT BY THE CROWN. Battery errors 19 → 17; micros
  149/149; verify green.
  ▶ THE QUESTION THIS ANSWERS is Morgan's: every armed diagnostic deletes
  a category of guessing permanently, so the arming path IS the path out of
  the loop. E_EffectMismatch is the last crown class unarmed, and the
  licence is measured, not argued: the wheel's census of every error class
  is 0, so the corpus channel is the only gate. It carried 15 reports.
  ▶ TWO WERE HONESTLY-WRONG SIGNATURES, fixed here. mn-ev2 and mn-ev4 both
  declared `fn outer(x) with G + D` while calling a `mid` declared
  `G + D + Memory` — the author widened the callee and not the caller.
  Exactly the mn-cli-dispatch shape that unblocked E_PurityViolated. 15 →
  13, and both files left the battery's carrier list.
  ▶ THE OTHER 13 ARE NOT FIXABLE BY WIDENING, and that is the finding.
  mn-payload declares `with Probe` and the medium infers `Memory + Alloc +
  Probe({alpha: Int, beta: Int, gamma: Int})` — a type-parameterized
  INSTANCE. A with-clause takes value arguments; it cannot say
  `Probe({record})` at all. So no signature exists that matches what
  inference proved, and the payload family carries most of the 13 for that
  one reason.
  ▶ THE BLOCKER IS `Hβ.syntax.type-instance-in-with-clause`, which is the
  SAME gap that made `mentl tighten` author un-re-parseable rows at pin
  1aca4868. The guard there refuses to write what cannot be read back;
  this is that sentence from the other side — the medium cannot declare
  what it can prove. Banked as
  `Hβ.crown.effect-mismatch-arming-blocked-by-the-surface`.
  ▶ AND A SECOND CLASS MEASURED UNARMABLE, its follow-up named nowhere
  until now. `tests/micros/mn-resume-in-called-fn.mn` runs correctly —
  exit 9 — while reporting E_ResumeOutsideArm twice, and its own comment
  calls the fix "the named follow-up". A grep of RESIDUE for it returned
  nothing, so by PLAN §7's law it did not exist. The report is honest
  about the TYPING (`resume : R -> S` needs the arm's continuation types,
  and inf_arm_tys answers None for a standalone `drive`) and wrong about
  the PROGRAM. Arming would refuse a correct fixture. Banked as
  `Hβ.infer.resume-in-a-called-fn-has-no-arm-types`; the build is
  continuation-polymorphism at the fn boundary, not a patch to the check.
  ▶ WHAT WAS DELIBERATELY NOT DONE: mn-feedback-iir's two reports are
  plausibly `Hβ.effects.feedback-row-substitutes` — the `<~` site
  over-charging Alloc — rather than wrong signatures, and blanket-widening
  them would canonize an over-charge as a fixture's declared truth.
  mn-backtrack-full's three are unread. Both are named rather than
  guessed.

- 2026-09-04 · pin 40b1c7148281d298 · THREE DEAD FNS, AND THE FACET'S
  OVER-REPORT CONFIRMED AS STATED. CLEAN m2 == m3 at 418641 lines, census
  0; micros 149/149; frontier 374/0.
  ▶ DELETED from backends/wasm, each read at its site first:
  `ty_to_wasm_type` — the composition `repr_of |> repr_wat` with no
  consumer, while repr_wat itself answers 19 references, so callers reach
  the projection directly. `handle_recorded` — a membership walk whose ONE
  reference is its own recursive call; the facet counts references outside
  the declaration's extent, which is precisely the distinction that makes
  a self-recursive orphan visible where a raw ref-count would read 1 and
  look alive. `emit_load_chain` — a one-line wrapper defaulting leaf_repr
  to RI32, while all four callers use emit_load_chain_repr; its comment
  moved onto the surviving fn.
  ▶ THE EMIT LINE COUNT DID NOT MOVE — 418641 before and after. That is
  the independent confirmation that all three were unreachable:
  reachability had already pruned them from the emitted tree, so this is
  source hygiene and not a behaviour change. A deletion that changes the
  artifact would have meant the measurement was wrong.
  ▶ THE OVER-REPORT IS WHAT THE ENTRY SAYS, measured rather than assumed.
  The remaining backends/wasm rows are TYPE names, and cursor_transport's
  three — Surface, Action, PatchWrite — are EFFECT names carried in
  cursor_step's declared row. Type position draws no reference edge
  (`Hβ.types.type-expressions-are-not-graph-content`), so they read as
  orphans and are not. Two probes settled it; the facet's limit held
  exactly as written.
  ▶ THE READING DISCIPLINE, five landings in: the facet names candidates
  and a person reads each at its site. That has now sorted BodyContext,
  Delta and ic_fixpoint_handler (deleted), graph_emitfn_at,
  graph_narrow_set, diag_applicability and interrogate_all (dormant under
  named peers), fs_close (a bypass to fix, not vocabulary to remove), and
  these three. The count is never the verdict.

- 2026-09-04 · pin ff7e079b49ca0e4e · THE LARGEST CLAIM IN THE WHEEL WAS
  INERT. CLEAN m2 == m3 at 418641 lines, census 0; micros 149/149;
  frontier 374/0. Orphan-claims 216 → 215.
  ▶ THE FACET NAMED IT, one pin old, on its first run:
  `ic_fixpoint_handler`, 3,245 bytes of prose and zero references. The
  question banked with it was built-ahead or abandoned, because deleting
  might have removed the only implementation of §2's cached cursor.
  ▶ THE ANSWER IS NEITHER, and only reading the arm gives it. Both
  branches called `cursor_argmax_compute(caret)` — identically. The
  `last_epoch` state was written and never affected a result. So the
  memoization the prose described did not exist, and the handler was a
  no-op wrapper around what `cursor_default` already does.
  ▶ TWO FALSE CLAIMS IN ONE COMMENT BLOCK: "Installed via `~>` above" (it
  is installed nowhere) and "on a stable epoch it resumes the terminal
  cursor and STOPS re-projecting" (it re-projected in both branches). This
  is the fourth comment this session asserting a consumer or behaviour the
  artifact refutes, and the first one a VERB found rather than a hand read.
  ▶ DELETED, and the reasoning matters more than the diff: removing it
  costs no capability, while KEEPING it was the actual risk. An unbuilt
  thing is honest; a built-looking thing that silently does nothing is
  worse than an absence, because the next person installs it on the
  strength of 3,245 bytes of prose and believes IC is live.
  ▶ WHY IT WAS NEVER FINISHED — the design knowledge, kept at the deletion
  site and in RESIDUE so the next attempt does not re-derive it: an epoch
  alone cannot key this read. `cursor_argmax` takes a CARET, and moving the
  caret without editing leaves the graph epoch unchanged while the correct
  cursor differs, so a stable-epoch cache answers the wrong position the
  first time a human moves without typing. The key is (epoch, caret), the
  peer is `Hβ.cursor.cached-argmax-keyed-by-epoch-and-caret`, and its gate
  is a fixture that moves the caret at a stable epoch and proves the answer
  changes.

- 2026-09-04 · pin cfb97e95594f703b · THE PATTERN BEHIND THREE FINDS BECAME
  A VERB. CLEAN m2 == m3 at 418650 lines, census 0; micros 149/149;
  frontier 374/0.
  ▶ THE PATTERN: BodyContext ("read by LEvPerform's offset arithmetic" —
  zero readers), Delta ("the Cursor handler's CursorView.teach field reads
  through delta_pick" — no such field), and the drifted verify_candidate
  copy ("mirrors the sequential arm exactly" — it did not). Three finds,
  one shape: a declaration nothing references, carrying prose that explains
  how it is used. The prose is the evidence — someone wrote down a belief
  the graph disagrees with — and every one cost a hand read.
  ▶ THE VERB: `mentl query <file> "orphan-claims"` reports the structural
  conjunction, zero outside references AND 240+ bytes of attached comment,
  read live through graph_comment_at (a comment is graph content, so this
  needed no new column).
  ▶ WHAT IT DELIBERATELY DOES NOT DO, because the limit is the design: it
  does not read English. Deciding that "read by LEvPerform" is a CLAIM
  would mean parsing meaning, and a checker that guesses at meaning would
  be a second, worse comment-ref tier. It names the sites; a person reads
  the prose. The existing comment-ref ratchet covers the other half at the
  name layer — a BACKTICKED name that resolves nowhere — and it stayed at
  ZERO through all three finds, because every phantom reader was named
  without backticks. That is the gap this fills, and why it is a separate
  tier rather than a widening of that one.
  ▶ FIRST RUN: 216 declarations. That is not 216 bugs and the entry says so
  — type names dominate because an annotation makes no reference edge
  (`Hβ.types.type-expressions-are-not-graph-content`), and a library's
  public vocabulary is unreferenced by the wheel by design, lib/threading
  alone contributing 25 rows.
  ▶ THE STANDOUT, found in one read: `cursor -> ic_fixpoint_handler` at
  3,245 bytes of prose and zero references — the largest single claim in
  the wheel, a handler nothing installs ANYWHERE. One step past Delta,
  which at least sat in three chains. Banked as
  `Hβ.cursor.ic-fixpoint-handler-is-never-installed` rather than deleted:
  Delta was decidable because the T_OverDeclared diagnostic was
  demonstrably the better shipping answer, and here nothing else memoizes
  cursor projections by epoch, so deleting might remove the only
  implementation of a capability §2 names. Built-ahead and abandoned look
  identical from the reference count alone.
  ▶ MY OWN PRECEDENCE BUG, caught by the medium in one check and worth the
  line: `acc ++ filter(…) |> map(…)` maps over the ACCUMULATOR, because
  `++` binds tighter than `|>`. The error read `List(Byte) vs (String,
  String, Int)`. Written explicitly now with the reason at the site.

- 2026-09-04 · pin d5e6f594f3bfa9ef · THE GRADIENT'S INVERSE DIRECTION HAD
  TWO IMPLEMENTATIONS. CLEAN m2 == m3 at 417799 lines, census 0; micros
  149/149; frontier 374/0. Wheel 59,296 → 58,983 lines.
  ▶ DELETED WHOLE: src/gradient_delta.mn — the Delta effect, delta_default,
  its four arms and nineteen supporting fns, 407 lines; the import in
  main.mn and the three `~> delta_default` installs.
  ▶ THE MEASUREMENT that made it certain, taken at the previous pin.
  delta_pick: zero references. delta_effect_row, delta_ownership,
  delta_refinement: exactly one each, all three inside delta_pick's own arm
  (gradient_delta.mn:95, 99, 102). Four ops in a closed ring nothing enters
  — while delta_default sat installed in three real chains, which is
  BodyContext's shape again. The imports facet confirmed the module's only
  external consumer was that install, and row_to_with_clause /
  capabilities_unlocked_by, the two fns that looked shareable, answered
  only from inside the module.
  ▶ THE COMMENT NAMED A READER THAT DOES NOT EXIST: "The Cursor handler's
  CursorView.teach field reads through delta_pick when the inverse-
  direction gradient should fire." There is no `teach:` field in cursor.mn.
  Third time this session a comment claimed a consumer the artifact
  refutes, after BodyContext's "read by LEvPerform" and the fan's "mirrors
  the sequential arm exactly."
  ▶ WHY DELETE RATHER THAN WIRE, which is the whole judgment: the shipping
  answer already exists and is better. main.mn:633 states it — "T_Over-
  Declared already IS a proposal — the diagnostic" — and `mentl tighten`
  reads those banked warnings, authoring 174 of them at pin 1aca4868. Delta
  walked the graph per handle to re-derive the verdict the judgment had
  already proved and written down. That is the Carried-Truth Law at the
  exact shape the law names, so the fix is toward less code and the
  question "should the cursor perform these?" answers itself: the cursor
  should read the diagnostic.
  ▶ THE FACET'S OWN LIMIT, recorded at the RESIDUE entry and worth
  repeating: `performs` read this roster as 3/4, not 0/4, because it counts
  references outside the effect DECLARATION's extent and delta_pick's arm
  lives in the handler — a different declaration. The facet measures direct
  reference honestly; reachability is a different question and belongs to
  `Hβ.driver.link-is-reachability`. Reading the roster together with
  delta_pick's zero is what found this, which is how the two facets compose.

- 2026-09-04 · pin 17790803376704d8 · THE PROOF GATE HAD TWO HOMES. CLEAN
  m2 == m3 at 420007 lines, census 0; micros 149/149; frontier 374/0.
  ▶ HOW IT SURFACED: the performs facet, one pin old, reported `mentl ->
  Synth 1/3`. Reading the two unperformed ops at their sites is what the
  facet is for, and verify_candidate's arm held a second copy of what
  "proven" means.
  ▶ THE TWO COPIES. The arm (synth_proposer.mn): `verify_after_apply(h) &&
  refinement_admits(target_ty, h)`. The fan's candidate_judge:
  `verify_after_apply(h) && refinement_admits(tcopy, h)`, where tcopy is
  `instantiate(Frozen(free_in_ty(target_ty), target_ty))`. candidate_judge's
  own comment claims "the nested trio mirrors the sequential
  verify_candidate arm exactly." It does not. The fan instantiates the
  target FRESH — its comment two lines later says why, "so the proof never
  binds the hole's live frontier" — and the arm passed the live target in.
  ▶ SO THE DEAD COPY WAS THE WRONG COPY, which is what a second home
  eventually becomes. Nothing performed verify_candidate, so nothing had
  been hurt; anything that started performing it would have taken the path
  with the defect the fan had already fixed. This is §1's own gate — the
  one that makes "any intelligence may propose, nothing executes unproven"
  a mechanism rather than a sentence — so a drifted duplicate of it is the
  Carried-Truth Law violated at the thesis's sharpest seam.
  ▶ THE FIX IS ONE HOME: candidate_proven holds the definition; the fan
  calls it and the arm calls it. Less code, and the arm's fresh-instantiate
  behaviour arrives by construction rather than by a second edit.
  ▶ THE FACET STILL REPORTS 1/3, and that is correct. The duplication is
  gone; the op still has no performers, which is the honest state of a
  contract op an external Synth handler would implement. An arm calling a
  fn is not a bypass — the arm IS the handler, so no seam is skipped, which
  is what distinguishes this from the Filesystem case two pins back.
  ▶ AND A GATE THAT LIES, banked as
  `Hβ.perf.first-march-after-a-source-change-reads-100mb-high` — RETRACTED
  ONE PIN LATER, see the entry above. The peak ratchet had refused the
  first march of three consecutive landings (2,310,816 / 2,316,080 /
  2,311,408 against a 2,310,000 ceiling, ~2,210,000 on every re-read), and
  the next session's controlled test refuted the mechanism this entry
  guessed at. The observations stand; the explanation did not.

- 2026-09-04 · pin 899a4b571112f58e · THE HAND CLASSIFICATION BECAME A
  VERB. CLEAN m2 == m3, census 0; micros 149/149; frontier 374/0.
  ▶ THE PATTERN THAT EARNED IT. Three landings running, the find was one
  shape — an effect whose ops nothing performs. BodyContext: four ops, zero
  readers, installed in every lowering route. The Filesystem bypass: the
  ops existed and eleven callers reached past them. Interact: 22 ops, 14
  never performed. Every one cost a hand read, because `unreferenced`
  reports bare NAMES and telling an op from a fn from a type meant opening
  each site. That reading is the part of the loop that was still me.
  ▶ THE VERB: `mentl query <file> "performs"` groups declared ops by the
  effect that declares them and answers k/n per roster. Same two columns as
  the two facets before it — the decls the weave carries, the refs column —
  restricted to EffectDeclStmt and counted per op.
  ▶ A HANDLER ARM IS NOT A PERFORM, and that is the design rather than an
  accident of the measurement: an arm is the promise's other half, never
  its consumer. So k/n reads as how much of a surface is actually reached,
  which is the question all three finds were really asking.
  ▶ WHAT IT REPORTS: 78 effects, 23 with ops nothing performs. Its
  independent read of Interact says 8/22 — the same split measured by hand
  at the previous pin, which is the check that the verb agrees with the
  method it retires. The compiler's own rosters sit mostly at n−1
  (GraphRead 20/21, GraphWrite 28/29, InferCtx 16/17, Delta 3/4), which is
  the dormant-vocabulary class already carrying named peers; the wide gaps
  are Interact at 8/22, Synth 1/3, OracleQuery 2/4, Interrogate 1/3, and
  the library rosters (threading 0/3, ml/autodiff 0/5, dsp/clock's four)
  that no wheel code performs because publishing them IS their job.
  ▶ THE PEAK CEILING, NOT RAISED AGAIN. The first march after the edit read
  2,316,080KB against a 2,310,000 ceiling; two further reads of the
  identical tree read 2,210,700 and 2,210,532. The outlier is the first run
  after a source change, the same shape as the previous pin's 816KB breach.
  Two consecutive landings have now measured this: the ceiling holds and
  the first-run reading is not evidence.

- 2026-09-04 · pin 055b396f7fadab87 · A HANDLER'S EXTENT SURVIVES TAIL
  RECURSION, MEASURED. CLEAN m2 == m3 at 418677 lines, census 0; micros
  149/149; frontier 374/0. Seam 11 → 8.
  ▶ THE QUESTION, and why it was worth a fixture instead of a guess. Seven
  filesystem bypasses were blocked behind one unknown: `mentl space`'s
  accept loop never returns, so installing a handler over it only works if
  the extent outlives a self-tail-call. Reasoning it out would have been
  cheap and unverified, and the project has paid for that before.
  tests/micros/mn-handler-extent-tail-loop.mn puts the install outside and
  the perform inside every iteration. It answers 10 — meaning not only does
  the extent survive, the handler's STATE accumulates across iterations
  (bump answers 1, 2, 3, 4), which is the half a server actually depends
  on.
  ▶ WHAT IT UNBLOCKED: space_run installs `~> wasi_filesystem` over
  space_loop, and the file server performs fs_exists / fs_read_file instead
  of reaching past them to the impls. The install immediately made the
  medium REFUSE space_conn and space_loop for declaring `Memory + Alloc +
  WASI` while performing Filesystem. That refusal is the proof the bypass
  had been suppressing — the row finally naming what those fns do — and
  both signatures carry `+ Filesystem` now.
  ▶ ONE MORE WHERE THE ROW WAS ALREADY RIGHT AND THE CALL SITE LAGGED:
  driver_warm_persist's mkdir — its signature has declared Filesystem all
  along.
  ▶ AND ONE CONVERTED, THEN REVERTED BY THE BOARD, the sharper of the two.
  persist_write DECLARES `Memory + Alloc + Filesystem + WASI` while `mentl
  query "type persist_write"` reported its inferred row as `Alloc + Memory
  + WASI` — the bypass had made that signature false in the OTHER
  direction, over-declaring a capability the body never reached. Converting
  it looked obviously right, and the frontier's persist shadow leg refused
  it: `fs_write_file` answers E_MissingVariable at 3405 in that subset
  link, because the Filesystem effect is declared in src/types.mn and
  lib/persist.mn must compile standalone. A lib/ module cannot perform this
  effect at all, so the impl there is FORCED, not lazy — a floor under the
  ratchet rather than a site awaiting work. Whether that floor can fall is
  the effect's own home question, a different landing from converting call
  sites. The comment at the site says so now.
  ▶ A RATCHET NOT RAISED. The first march breached the peak-RSS ceiling by
  816KB (0.035%). A second read of the identical tree measured 2,206,204KB
  against the first's 2,310,816KB — a 104MB swing, which is exactly the
  run-to-run variance that ceiling's own comment documents ("a ratchet set
  inside its own measurement's variance is not a ratchet; it is a coin flip
  that blocks good work"). Noise, not a regression; the ceiling stands.
  ▶ THE REMAINING 8: battery_libs' four reads, main's battery loop read,
  dsp/cfc's read, image_resume's, and persist_write's structural one. All
  but the last sit in a fn declaring `with ... WASI` with no Filesystem
  handler in its chain, so the op is unreachable there; they convert when
  their callers install — a per-route reading, not a sweep.

- 2026-09-04 · pin 777418b1df461548 · THE LARGEST UNWIRED SURFACE WAS A
  HIDDEN GAP. CLEAN m2 == m3 at 418643 lines, census 0; micros 148/148;
  frontier 374/0.
  ▶ WHAT THE FACET SURFACED: 51 unreferenced names in voice.mn. Reading
  them found `Interact` — 22 ops, `mentl_voice_default` implementing every
  arm, installed at three sites, and 14 ops nothing has ever performed.
  ▶ THE SPLIT IS THE FINDING, not the count. LIVE (8): project_root,
  open_file, save_file, file_text, focus, caret (nine references), consult,
  propose. UNWIRED (14): tree_list, create_file, rename_path, delete_path,
  edit, speak, run_compile, run_check, run_audit, run_query,
  declare_intent, retract_intent, history, cancel_pending. The reading half
  of the surface is wired; the writing and session halves are not. `edit`
  is the op the felt surface turns on and it has zero performs — the Space
  session can open a file, read its text, set and read the caret, consult
  and propose, and cannot apply a change, speak a line, run a check, or
  record a turn.
  ▶ WHY IT IS A LANDING AND NOT A NOTE: PLAN §7 says every named gap has
  one home and "a gap not in `RESIDUE.md` does not exist." Grepping that
  file for `Interact`, `mentl-voice` and `mentl_voice` returned nothing. So
  the largest unwired surface in the wheel was a hidden gap sitting on §11
  Arc E's own critical path — drift by the project's definition, and
  invisible until a facet counted declarations against references. Named as
  `Hβ.voice.interact-write-half-is-unwired`.
  ▶ NOT A DELETION. Fourteen unperformed ops look exactly like the dead
  vocabulary the previous pin harvested, and are the opposite: a handler
  implements all of them and the standing cursor is the surface they serve.
  The close condition is the transport performing them, never the roster
  shrinking.
  ▶ THE SEAM TIGHTENED 13 → 11. mcp_run's two mkdirs sat two lines ABOVE
  its own `~> wasi_filesystem` bracket, so the op was unreachable there and
  the impl was the only spelling that resolved; they moved inside. The
  remaining 11 stop at the same wall and it is recorded at the ratchet:
  space's file server, battery_libs, persist, driver's warm cache and
  dsp/cfc each sit in a fn declaring `with ... WASI` inside a chain with no
  Filesystem handler at all. Converting them means ADDING an install, and
  for space that install goes over an infinite tail-recursive accept loop —
  whether a handler's extent survives tail recursion is a substrate
  question that wants its own measurement, not a guess inside a sweep.

- 2026-09-04 · pin 9347479ebf108d99 · ELEVEN CALLERS REACHED PAST THE
  FILESYSTEM EFFECT. CLEAN m2 == m3 at 418643 lines, census 0; micros
  148/148; frontier 374/0.
  ▶ WHAT WAS WRONG: `wasi_filesystem`'s own comment promises that "a
  function that doesn't reach fs_* ops proves `with !Filesystem`," and that
  audit-driven severance then drops path_open / fd_close from the binary.
  march_run, main's emit route and mcp's gate created, wrote, renamed,
  closed and unlinked files through the `_impl` fns instead. All three sit
  inside a `~> wasi_filesystem` install — march_run's entire body has the
  chain at its foot — so the ops were reachable the whole time and the
  bypass bought nothing.
  ▶ WHY NOBODY SAW IT: the impls carry `WASI`, not `Filesystem`. The row
  stayed truthful about the substrate and silent about the capability, so
  `with !Filesystem` kept holding over routes that were writing files, and
  the severance the handler promises would have qualified a file-writing
  binary to drop the very imports it uses. One line of main.mn had both
  spellings in one expression: `fs_exists_impl(gen_path)` beside
  `fs_read_file(gen_path)`.
  ▶ THE DEP, BUILT RATHER THAN NAMED: the effect had no op for what two of
  those routes do most. `fs_create_impl` is genuinely distinct from
  `fs_open_impl` — WASI oflags CREAT|TRUNC and write-only rights against
  CREAT and read/write — and no `fs_create` op existed, so reaching for the
  impl was the only way to write a file. `fs_create(String) -> Int` is
  declared and armed now.
  ▶ THE GATE, and it immediately corrected me. A new verify tier asks the
  medium `refs of <impl>` for each of the nine and counts sites outside the
  handler that owns them (pipeline) or the definition (io) — the verb's
  answer, never a grep, because a grep cannot tell a call from a name in a
  comment. My hand census had found three bypasses; the tier found
  THIRTEEN remaining after I fixed those three. The pre-fix number was then
  measured properly rather than derived — the fix stashed, the tier re-run
  — and read 24. Eleven conversions, 24 → 13.
  ▶ THE 13 ARE NAMED, NOT ACCEPTED. space's file server, battery_libs
  (which at least DECLARES `with WASI`, so its row is honest about the
  substrate), persist, and dsp/cfc. Each needs its own install-coverage
  reading before it converts, which is the same per-site discipline that
  kept four dormant declarations alive at the previous pin. The ratchet is
  monotone down and the entry `Hβ.io.fs-close-op-is-bypassed` — banked one
  pin ago naming only fs_close — is corrected in RESIDUE to the real
  extent.
  ▶ A FIXTURE THAT COULD NOT EXIST, recorded because it cost a probe: the
  natural gate would be `fn f() with !Filesystem` calling the ops, refusing
  transitively, in the frontier battery. It cannot be written. `Filesystem`
  is the COMPILER's own effect, declared in types.mn, and a checked user
  program has no access to that vocabulary — `mentl check` on the fixture
  answered `E_MissingVariable: fs_create`. The property lives on the
  wheel's own link, which is where the tier put it.

- 2026-09-04 · pin 46ad0838189effcc · A WRITE-ONLY HANDLER IN THE EMIT
  CHAIN OF EVERY ROUTE. CLEAN m2 == m3 at 418607 lines, census 0; micros
  148/148. Wheel 59378 → 59296 lines.
  ▶ THE HARVEST, and how it was read. `mentl query "unreferenced"` named
  eleven lowercase declarations in the compiler's own modules. Each was
  read AT ITS SITE before anything was touched — a report is a reading, not
  a delete list, which is the caveat the imports facet earned one pin back
  and it paid again here: four of the eleven are not dead.
  ▶ THE FIND: BodyContext. Four ops, one handler, one install in
  `emit_context` — so it rode all seven lowering routes. Its writers are
  `set_body_captures` and `set_body_evidence` at backends/wasm.mn:2783-2784,
  one call each. Its readers are nobody: `current_body_captures` measures
  ZERO references. The comment above the writes says "LEvPerform inside
  this body reads it to compute its offset arithmetic," and the artifact
  says otherwise; the second write passes a literal `[]`. This is the
  write-only side-ledger PLAN §5.U names as the textbook Carried-Truth
  violation, using `resume_kinds` as its example — the same shape, still
  installed, in the emit stack of every route that lowers. Deleted whole.
  The one-home `emit_context` from pin 1aca4868 is what made that a
  single-line removal instead of seven.
  ▶ ALSO DELETED, each an op whose only arm nothing performs:
  `current_region` (own.mn), `graph_reason_edge` and `graph_mint_at`
  (graph.mn — infer.mn's own comment records that mint_at's caller
  "dissolved into this config" and the op stayed), and
  `ls_current_lambda_handle`. The last one is the instructive case: it
  drags the `lambda_h` field on the lower frame record, written at five
  `ls_enter_frame` call sites and read by nothing else. Deleting the op
  alone would have MANUFACTURED a write-only ledger in the same landing
  that cured one, so the field, the op's arity, its loop, and all five
  call sites went together.
  ▶ FOUR STAYED, and the reasons are the point. `graph_emitfn_at` and
  `graph_narrow_set` say in their OWN comments that they are dormant
  vocabulary under named peers (`Hβ.lower.lowering-is-a-column`,
  `Hβ.infer.narrowing-write-requires-discharge`) — "defined but uncalled"
  is the slot for what is about to be built. `diag_applicability` is the
  unread half of the catalog projection `Hβ.diag.catalog-as-projection`
  will read. And `fs_close` is dead only because main.mn:425, main.mn:1826
  and mcp.mn:128 call `fs_close_impl` directly, reaching past the effect
  declared to carry it — deleting the op would canonize the bypass and lose
  the handler seam, so it is banked as `Hβ.io.fs-close-op-is-bypassed`.
  ▶ A THIRD MISSING REF EDGE, found the same way: `span_valid` is
  referenced only from `type ValidSpan = Span where span_valid(self)`, and
  a predicate is not walked as an ordinary expression, so the call notes
  nothing. Banked as `Hβ.infer.predicate-position-refs-are-not-noted`; it
  dissolves for free when `Hβ.types.predicate-is-expr` lands.
  ▶ AND A RETRACTION, one hour old.
  `Hβ.infer.type-name-in-annotation-never-resolves`, banked at the previous
  pin, said the medium never looks up an annotation's type name. The
  artifact refutes it: `quantify_ctor_ty` (infer.mn:8389) calls
  `env_lookup_type` on every capitalized nullary name, and the probe that
  produced the claim had already shown it — `type Real = Int` with
  `fn f(x: Real)` type-checks against an Int. That draft reasoned from a
  symptom to a mechanism without reading the site. Replaced by
  `Hβ.types.type-expressions-are-not-graph-content`, which names the real
  root: `quantify_ctor_ty` is a pure Ty-tree rewrite with no handle for the
  name it resolved and no span for the token it read, so it CANNOT note the
  edge and the miss CANNOT refuse. The AST-in-graph fabric stops at the
  type annotation.

- 2026-09-04 · pin 1ff3393b59c62018 · THE MEDIUM FINDS ITS OWN DEAD
  DECLARATIONS. CLEAN m2 == m3 at 419046 lines, census 0; micros 148/148.
  ▶ THE VERB: `mentl query <file> "unreferenced"` answers, for every name
  the weave declares, how many of its reference sites lie outside its own
  declaration. Zero is the finding. It is the import read one altitude
  down and turned around: that one asks whether any name an edge BRINGS is
  referenced INSIDE the importing extent; this asks whether any site
  referencing a declared name lies OUTSIDE the declaring one. Same two
  columns, same O(1) probe, opposite direction — decl_names_of over the
  decls the weave already carries, graph_refs_at per name, span_overlaps
  against the declaration's own extent.
  ▶ WHY IT HAD TO EXIST: nine dead fns came out of src/ by hand at pin
  9109e063 — one grep per name, then reading each hit to tell a call from
  a mention in a comment. That is the same blindness that hid three dead
  imports for weeks, and it costs a pass per name.
  ▶ WHAT ITS FIRST RUN FOUND WAS A BUG IN THE GRAPH, NOT A LIST OF DEAD
  CODE. 461 of 4,388 read unreferenced, and the roster was implausible —
  `TStringLit` at zero refs, `TIntLit` at exactly two, both of them its
  construction sites in the lexer. Every `match` on a constructor was
  registering nothing. The resolution HAS to happen there (arity and
  exhaustiveness are checked against the scheme it finds), so the edge was
  proven and dropped: the Carried-Truth Law, at the reverse-edge column.
  graph_ref_note now fires at the PCon site above its env match, for
  infer_var_ref's own stated reason — a missing constructor is still a
  reference. Measured: 461 → 415, forty-six names the graph knew about.
  ▶ THE REMAINDER IS A DIFFERENT FINDING AT A DIFFERENT PRICE. What is
  left in types.mn is almost all type NAMES — `Ty`, `EffRow`, `NodeKind`,
  `SchemeKind` — whose constructors are everywhere and whose names appear
  only in declarations and annotations. Probed: `fn f(y: Nonexistent)`
  yields `E_TypeMismatch: Nonexistent vs Int` at the body. The name is
  never resolved, so nothing was dropped; there is no edge to carry. That
  is a missing capability, banked as
  `Hβ.infer.type-name-in-annotation-never-resolves` with the repro and the
  gate to see RED first. Keeping the two apart is the point: one was a
  deletion, the other is a build.
  ▶ THE FACET STATES ITS OWN LIMITS AT THE SITE, because a reader will
  otherwise take the number further than it goes. `main` is the entry and
  is not dead. A library's public vocabulary (lib/threading, lib/test) is
  unreferenced BY the compiler and correctly so. And UNREFERENCED is not
  unreachable — it measures the direct reference, exactly as the import
  read does; `Hβ.driver.link-is-reachability` is the judgment that decides
  what the program needs.

- 2026-09-04 · pin 1aca486868b92bc4 · THE MEDIUM WRITES ITS OWN SOURCE.
  CLEAN m2 == m3 at 417952 lines, census 0; micros 148/148.
  ▶ WHAT LANDED: `mentl tighten main` authored 174 of 223 row narrowings
  across 27 files — the largest medium-authored diff the wheel has taken,
  and the first one the verb is provably allowed to make.
  ▶ THE BUG THE RUN BEFORE IT FOUND: `mentl tighten src/cursor.mn` authored
  132 changes and the march answered with census 40 — twenty
  `E_ConstructorArity` ("constructor Cast takes 0 fields; the pattern binds
  1") and twenty `E_EffectMismatch` whose two sides printed identically as
  `Memory + Alloc + Cast(GNode)`. The identical print is the tell: the rows
  really were equal as VALUES and unequal as TEXT, because tighten had
  written the row it inferred rather than a row the grammar can read. Source
  said `Cast`; inference proved `Cast(GNode)`, the type-parameterized
  instance; the with-clause grammar takes value arguments alone, so the
  re-parse turned the type application into a constructor pattern.
  ▶ THE PROPERTY, stated once: a self-authoring verb has exactly ONE
  soundness obligation — author nothing you cannot re-parse. Everything else
  it does is a proposal the board judges. `row_is_authorable` already
  refused open tails (`EtOpen`, `EtAll`) and had no arm at all for an effect
  ARGUMENT that carries a type. `every_eff_arg_authorable` refuses `EAType`
  and admits the rest; `eff_name_authorable` routes every `EParameterized`
  through it. That is the whole fix, and it is at the one site that decides
  what tighten may write.
  ▶ WHY THE BOARD NEVER SAW IT: tighten's output is read by nothing until
  someone marches it. The guard makes the refusal structural instead —
  the verb now declines to author the un-re-parseable row rather than
  emitting it and waiting for a compile to disagree.
  ▶ THE RATCHET RAISED, WITH ITS REASON: anonymity 384 → 385 under the
  medium's own 174 changes. The quiet gate's ref count (813 → 814) and the
  first anonymity read were MINE, from `ref` markers written into the guard
  fns by the same copy-the-surrounding-style reflex that gate exists to
  catch — those came off. What remains is one lambda whose row became
  visible to the tier because the medium narrowed the tree around it. The
  tier is telling the truth about a tree it wrote; the count moves with the
  measurement in verify-baseline, not with a fix.

- 2026-09-04 · pin 9109e063bf2b1726 · THE MEDIUM FINDS ITS OWN DEAD IMPORTS.
  CLEAN m2 == m3 at 417769 lines, census 0; micros 148/148, frontier 374/0.
  ▶ THE VERB: `mentl query <file> "imports"` answers every import edge in the
  weave with whether the imported module brings any name the importing one
  references. Every term was already in the graph — module_cells gives each
  module its path, span and decls; an ImportStmt among those decls IS the
  edge; graph_refs_at answers each declared name's sites in O(refs) — so the
  read is a fold over edges, not a scan of text.
  ▶ WHY IT HAD TO BE THE GRAPH: it reports 63 dead of 256 on the wheel, where
  the shell census of the same question found 52. A grep cannot tell a used
  name from one written in a comment, and that gap is exactly how three dead
  `import types` lines sat unseen long enough to put the compiler's whole op
  vocabulary into every user program.
  ▶ ONE MORE DISCARD FIXED ON THE WAY: module_cells returned (path, span) and
  dropped the cell's own decls, so every consumer that wanted a module's
  content re-derived it from text. It carries (path, span, decls) now.
  ▶ THE HONEST LIMIT, at the site: imports are TRANSITIVE, so an edge
  bringing no referenced name of its own may still be the conduit by which a
  third module arrives. The facet reports the direct reference it measured
  and says nothing about the conduit; `Hβ.driver.link-is-reachability` is the
  judgment that decides those. So the 63 are a reading, not a delete list.
  ▶ FOUR RATCHETS TRIPPED AND THREE WERE FIXED RATHER THAN RAISED. The ref
  markers came off the new fns — the quiet gate is right that annotating
  around inference IS the inference failing, and they were written by copying
  surrounding style. The two returned lambdas became hole-products under the
  Stage Law (configuration first, datum last), which is the language's own
  answer and left the anonymity tier nothing to convict. The backticked names
  that resolved nowhere became prose. Only movers rose, +1, the arithmetic
  any added fn pays in a tower that shifts ~0.8% of schemes.


- 2026-09-04 · pin 5b828fd0b1602670 · THREE DEAD IMPORTS PUT THE COMPILER IN
  EVERY USER PROGRAM. CLEAN m2 == m3 at 415869 lines, census 0; micros
  148/148, frontier 374/0, prelude floor 6385 → 2737 source lines, a bare
  weave 7 modules → 6.
  ▶ THE DIG STARTED SOMEWHERE ELSE. A per-class corpus census turned up 57
  E_TypeMismatch across eight fixtures that all pass their gates, 42 of them
  in one 16-line crown crucible. The errors pointed INSIDE lib, so the first
  reading was that the weave was dirty; a trivial program reported zero,
  which killed that. The crucible declared `effect Feed { yield(x: Int) }`
  beside prelude's `Iterate.yield`, the env holds one entry per name, and the
  second declaration replaced the first — every prior call retyped and the
  cascade surfaced at spans the author never wrote. Renaming the op left
  exactly 1 error: `!E + Any vs E`, the refusal the crucible exists to prove.
  It had been passing on 44 wrong reasons.
  ▶ THE ROOT WAS NOT THE COLLISION. Eight fixture op names collided with
  wheel ops, and the reason a user program can collide with `abort` or `mint`
  at all is that lib/lists, lib/strings and lib/threading each declared
  `import types` while referencing not one name from it. Three dead lines put
  the compiler's own module — Abort, FreshHandle, Consume, GraphRead/Write,
  Diagnostic, EnvRead/Write, Verify, ~170 ops — into the namespace of every
  program that touches a list. Deleting them removed `types` from the weave
  and the abort/mint collisions with it (mn-ev8: 1 error → 0).
  ▶ THE CEILING THE GATE HAD BEEN RAISING FELL. frontier's prelude floor was
  raised three times in four iterations, every raise a types.mn addition, and
  its own comment called that evidence FOR `Hβ.driver.link-is-reachability`
  and predicted "this number falls hard and the ceiling follows it down". It
  fell 57% on three deleted imports. Dead imports are the crudest possible
  unreachability, so the real judgment is still ahead of this.
  ▶ E_OpShadowsOp, ARMED. register_one_op's claim check read the FnScheme
  pair and dropped the other eight kinds into `_ => ()`, at the one site
  whose own comment says "this write is the one place both claims are
  present". The arm is exhaustive now: fn reports (as before), cross-effect
  op reports and REFUSES, handler-name is measured harmless (ops and handlers
  resolve in disjoint positions), and the five uppercase kinds cannot collide
  by the case rule. Licence measured both halves: 325 wheel ops with zero
  cross-effect reuse, and the corpus clean after the crucible's rename.
  ▶ WHAT THE REFUSAL COSTS, and it is real: two effects sharing an op name is
  ordinary elsewhere (`Reader.get` beside `State.get`) and Mentl cannot say
  it, because op identity is the bare name while the env entry already
  carries its effect. `Hβ.env.op-identity-is-effect-and-name`.
  ▶ THE CORRECTION THAT MATTERS MOST: the first build of this landing was a
  diagnostic that reported the collision and let the program compile anyway —
  the corruption plus a note about it. That is the residue pattern in a
  compiler's costume, and 35 of the previous 100 commits are `residue:`
  entries. Morgan named it mid-turn. The arming, and then the three
  deletions, are what closing it looks like.


- 2026-09-03 · pin 7e2f8deba2a9d6d4 · THE CROWN REFUSES. CLEAN m2 == m3 at
  416176 lines, census 0; micros 148/148, verify and frontier green.
  E_PurityViolated is ARMED — the first of the effect system's own two
  verdicts to reach the refusal law.
  ▶ §0's FIRST PROPERTY WAS FALSE. "Any intelligence may propose; nothing
  executes unproven" — and `fn claims_pure(n) with Pure = shout(n)` reported
  E_PurityViolated, then emitted 38,750 bytes and ran to exit 9. It exits 1
  with zero WAT now.
  ▶ THE LICENCE WAS ALREADY SATISFIED, and measured rather than assumed.
  diag_refuses states its own rule — a class arms when the wheel's census of
  it is zero — and the wheel's census is 0. The user-path half was checked
  across all 372 corpus fixtures: the only carriers left are the two that
  EXPECT the refusal. The recorded refutation against arming, "the wheel
  reports 2,266 errors about its own source," is era-stale; it refuted the
  ALL-AT-ONCE form, which is still the right refusal, and classes arm one at
  a time as their census falls.
  ▶ THE ONE TRUE BLOCKER was a fixture, not the compiler. mn-cli-dispatch's
  parse_verb and build_question declared `with Pure` while constructing
  payload-carrying variants; construction allocates, which this project
  settled at the constructor-charge landing, and the signatures had been
  wrong since they were written. Nothing caught them because the class did
  not refuse and the battery's diagnostic counter could not report a nonzero
  number.
  ▶ A CORRECTION TO THE DIG THAT FOUND IT: an earlier reading of this
  session claimed E_TypeMismatch and E_ResumeOutsideArm were armed classes
  that were failing to fire. They are not armed at all — that list was
  scraped from a line range overlapping three other projection tables in
  types.mn (span, applicability, message), so constructor names were read
  from the wrong functions. diag_refuses spans 2542-2651 and holds fifteen
  True arms; the machinery fires correctly, and E_DuplicateFnName proved it
  by refusing a probe in the same session.
  ▶ WHAT REMAINS FOR THE SECOND VERDICT: E_EffectMismatch carries 15 corpus
  reports across 12 micros plus the feedback-row false charge, whose fix is
  a fork RESIDUE reserves for Morgan. E_ResumeOutsideArm has one documented
  false positive (mn-resume-in-called-fn, whose own comment names it "the
  recovered diagnostic"), and E_TypeMismatch one report in
  mn-uzero-through-frames. Each is a class-sized arc, and each ends with an
  arm in diag_refuses.


- 2026-09-03 · pin b60ea6ed67ed214b · NINE FNS NOTHING CALLED. CLEAN
  m2 == m3 at 416159 lines — byte-identical to the pin before it, which is
  the proof: reachability had already pruned every one, so the deletion is
  source-only.
  ▶ THE CENSUS: every declared fn (2897) against every reference in the
  tree. 38 have no caller. 29 of those are lib — prelude vocabulary and the
  dsp/CFC workload — where no internal caller means API, not death. Nine
  were compiler dead weight, and six of them carried a comment describing a
  world that had already ended: three per-base digit predicates superseded
  by base_digit, whose own comment calls itself "the one accumulator";
  name_set_insert calling itself "the one remaining single-element write"
  that nothing writes; a self-test declaring `with Pure` under a comment
  claiming it declares `with !Mutate` and proves lone negation, which the
  crown battery covers in 50+ crucibles; and publish_with_instances, whose
  comment had already passed sentence — "DIES WITH THE DECLARED PUBLISH".
  The declared publish died; the fn stayed.
  ▶ WHAT THE CENSUS SAYS ABOUT THE PROSE: a stale comment outlives the code
  it lies about, because nothing reads it. comment-refs gates backticked
  NAMES resolving; it cannot gate a sentence whose subject no longer runs.
  The deletion test SYNTAX states for comments has no mechanical form yet.
  ▶ AND WHAT IT COULD NOT ANSWER: `mentl query "refs of NAME"` answers one
  name at a time and there is no all-names facet, so the census ran as a
  shell loop over grep. That absence is the finding — a dead-code
  projection is the medium's own `refs` verb folded over its decls column,
  which the reverse-edge landing already built.


- 2026-09-03 · pin 39f26832c0b8858c · A BOUND ROW IS NOT FREE, AND TWO
  PROVEN-EQUAL ROWS ARE ONE CELL. CLEAN m2 == m3 at 416159 lines, census 0;
  micros 148/148, syntax 12/12, floor and residual contracts green.
  ▶ THE SILENT WRONG WENT ONE HOP DEEPER than the twin key. An open-row
  callee reached from inside another twin's body read a neighbouring field
  (7 where 9 was asked), and the trace named a severed proof rather than a
  bad unifier: the annotation closed row 24730 and the field access read
  24736, six cells later, offset unprovable in between.
  ▶ THREE WRITES CLOSE IT, each the same law at a different site.
  free_in_ty's TRecordOpen arm collected its row var unconditionally, so a
  BOUND row — one already carrying a proven residual — was reported free,
  generalize quantified it, and instantiate minted a fresh empty one over
  the proof. free_in_row states that exact rule six lines below and this
  sort had never applied it. unify_two_open_records now UNIONS two rows it
  has proven identical, the NBound(TVar) edge chase_handle already follows,
  whose own comment carries the law the arm was missing: unify unions the
  ROOTS. And absorb_into_residual stops writing `[] assumed` onto cells that
  know nothing — the bound arm already said `if len(added) == 0 { () }` and
  the unbound arm said the opposite.
  ▶ THE FABRICATION HAD BEEN PAYING A COIN FLIP. mn-findtag passed for years
  because its manufactured empty residual gave offset 0 and `handle` sorts
  first in {handle, region_id}. Removing the guess trapped it — exactly as
  the code comment warned it would, "measured twice" — and the collector fix
  made it pass for the real reason. That comment had recorded the symptom
  and blessed the guess; the guess was the bug.
  ▶ A THIRD STATE BECAME VISIBLE, and the gate grew to see it. A remainder
  is proven, assumed, or genuinely FREE, and the third was invisible while
  every unknown cell got stamped assumed. tests/rows fixtures now declare
  which they expect on a `// residual:` header, and all three readings are
  checked — where the old gate asserted "assumed" and was, it turns out,
  gating a fabrication.
  ▶ WHAT THIS COST AND WHAT IT DID NOT. The movers ceiling rose 470 → 471,
  the two collector fns. Two fixtures were re-derived by hand rather than
  re-banked (§9.11), and one probe that answered — the demand walk's own
  pairs decision, which no verb projects — was removed rather than
  graduated; its projection is unbuilt and named here rather than
  pretended.


- 2026-09-02 · pin 8b4e09ca3c2e47f5 · A ROW VAR RESOLVES LIKE ANY OTHER
  VAR, AND THE SYMPTOM SURVIVED IT. CLEAN m2 == m3 at 415790 lines, census
  0; verb parity green, micros 148/148, frontier 374/0, syntax 12/12.
  ▶ WHY: an audit of what else discards a proof, run against the artifact
  rather than the docs. Eight of SYNTAX's worked examples measured TRUE
  (short-circuit guarding its own read, spread resorting slots, rest-field
  layout, a label skipping a default, the `??` pipe hole, alternation
  binding, as-patterns, `==` looser than comparison), and `==` over an
  open row compares the whole record. The ledgers PLAN calls deleted are
  genuinely gone. What did not hold is below.
  ▶ THE OFFSET FIX WAS INCOMPLETE ONE HOP DEEPER. An open-row callee
  reached from INSIDE another twin's body still read the decl's unlearned
  row: `outer` mints `$outer$spr_alphai_zetai_` with its receiver closed,
  and the single `$inner` it calls loads offset 0 — alpha's slot — for a
  program that must answer 9. Two sites could not answer for a row var at
  all: spec_subst_pairs returned a record row var verbatim where a type
  var consults the pairs, and spec_resolve's change-walk read only field
  types, so a site whose ONLY change was the row closing reported
  unchanged. Both answer now.
  ▶ AND NEITHER CLEARED IT, which is what named the root. The fixes are
  correct by the law, marched clean, and measured insufficient — the
  conjunction the law describes. `unify_two_open_records` proves two open
  rows are the same row and keeps them as TWO nodes: it cross-absorbs each
  side's exclusive fields and marks both RowAssumed, never unioning va and
  vb. Its own comment says they "collapse to one when they're already
  linked", which is a check on `va == vb` and never a link. Unify unions
  the roots for type vars — this codebase's own stated law — and does not
  for record row vars, so the interior site's root is not the twin's pair
  key and no interior twin is demanded.
  `Hβ.infer.record-row-vars-are-not-unioned` carries it; the standing
  repro is tests/repro-wf/open-row-interior-site.mn. The fix is the
  representation, which the unpatchability theorem already names for
  unify.
  ▶ THE AUDIT'S OTHER FINDINGS, banked not built: the crown's own verdicts
  do not refuse. `fn claims_pure(n) with Pure = shout(n)` reports
  E_PurityViolated and then emits 38,750 bytes and runs to exit 9; the
  same holds for E_EffectMismatch. Fifteen of fifty error classes refuse.
  diag_refuses' stated licence — "a class is ARMED when the wheel's own
  census of it is ZERO" — is satisfied today (census 0), and the
  refutation recorded against arming reads "the wheel reports 2,266 errors
  about its own source", which is an era-stale number. The measured
  blocker is one documented false positive:
  `Hβ.effects.feedback-row-substitutes` charges Alloc for `<~` slots that
  are declared and never allocated, so `fn cycle() with !Alloc` REFUSES a
  correct real-time program. Fix that, and §0's first property reaches the
  crown. Also: PLAN §11 Arc E cites tests/repro/mn-unannotated-float-
  accumulator.mn as the demo guard's witness — there is no tests/repro/
  directory, and the defect it describes measures FIXED (exit 9, zero
  diagnostics) since total monomorphization landed.

- 2026-09-01 · pin 7740ac9492c0f2ec · THE ROW VAR KEYS THE TWIN, SO THE
  OFFSET IS THE RECORD'S. TRANSITION m3 == m4 at 415700 lines, census 0;
  syntax battery 12/12 through both links, floor contract green, residual
  mark green, micros 148/148, frontier 374/0, verb parity green.
  ▶ THE SILENT WRONG, reproduced first: `fn width(u: {name: Int, ...}) =
  u.name + 1` over `{name: 5, age: 9}` answered 10 — `age + 1` — with zero
  diagnostics. SYNTAX's own worked example of row polymorphism is that
  shape, so the defect sat on a documented surface, and §11 Arc B′ (iv)
  had already ruled that no client-facing page ships it.
  ▶ THE MECHANISM, measured not reasoned: two call sites at two record
  shapes through one open-row callee answered 10 and 6 where both are 6.
  The shapes DISAGREEING is what named the root — one body, one baked
  offset. `unify_record_open_against_closed` was correct all along; it
  binds each instantiation's row var to the proven residual, RowClosed.
  What discarded that proof was two sites dropping the same handle: the
  specialization walk's `TRecordOpen(fs, _)` never paired the row var, so
  every shape shared a key and a body; and `spec_subst_pairs` substituted
  the known fields' types while keeping the row var verbatim, so even a
  paired row could not close the receiver. The offset then came from the
  decl's own row, which never learned a residual and reads as empty.
  ▶ THE FIX: pair the row var on a PROVEN whole set, and let the pair
  resolve the open row to the closed record it was proven to be.
  `open_record_proven_fields` is the offset read's walk held to the key's
  stricter standard — an assumed remainder is tolerable for an offset
  (refusing there turns a correct program into a trap, measured twice) but
  not for a key, because two sites keyed on a guess mint two bodies that
  disagree. A TRANSITION: 383 diff lines, the twins arriving.
  ▶ TWO BANKED EXPECTATIONS FLIPPED, re-derived by hand (§9.11 — the old
  value may be the bug canonized). `tests/rows/mn-assumed-residual` was
  banked at 7, the wrong slot, carrying its own instruction that "the day
  it changes is a day someone chose"; it reads 9 now. Its assumed-remainder
  MARK stands — that half was always right. `tests/floors/mn-unprovable-
  offset` expected a trap on a list-pattern shape whose row does close, at
  the call, where the emit could not see it; that was a limitation
  canonized, and the shape moved to the syntax battery answering 5. The
  floor keeps its contract with a receiver nothing closes — main's own
  parameter — which still refuses at 134.
  ▶ THE GATE'S OWN GATE, twice wrong and twice self-reported: the verb
  parity leg added one pin earlier compared the verb against the m3 leg,
  so it called this honest TRANSITION a verb failure; moved after the
  repin it ran a different binary than the one that wrote m2.wat. It sits
  after the m2 leg now and compares against m2, because the verb runs
  BOOT. A gate that has been seen red for its own reasons is worth more
  than one that has only been seen green.

- 2026-09-01 · pin f56db33328545399 · THE ENV CARRIES CELLS, AND THE MOVERS
  DID NOT MOVE. CLEAN m2 == m3 at 415201 lines, census 0; verb parity byte
  for byte; micros 148/148, frontier 374/0, verify green.
  ▶ WHAT LANDED: the Live posture stopped being dormant. Both publish sites
  bind `Live(handle)` — the env carries the decl's cell, and the quantifier
  is a projection each reader runs at its own moment of consumption. The
  thirteen readers that matched only the frozen shape were made total, in
  two forms by layer: inside infer, through judgment_ty (row_print,
  resolve_one_eff_arg, check_instance_args, the list_index charge,
  op_scheme_arity, the type-position alias read, scheme_ret_ty, and synth's
  vocabulary enumeration); below it, through the shallow chase to the bound
  node, which is that layer's live read (types.mn's callee_params, own.mn's
  callee_borrow_params). env.mn's env_entry_is_type was left alone by
  measurement rather than oversight: aliases publish Frozen, and a Live
  entry falls through to the kind check, which answers correctly.
  ▶ THE SURRENDER DELETED: own.mn's `_ => None`. A callee whose env entry
  was not yet an arrow meant "every bare arg reads", which is the whole
  printed flip set — grade `r` in the trial, `o` in the final. It now
  chases the cell, and the frozen-TVar case, which was the same read one
  moment earlier, shares the chase.
  ▶ THE KILL: this was supposed to drive the movers to zero. It did not.
  470 before, 470 after, the same four flips. The claim at infer.mn — that
  snapshot publishes under-resolve and live join-cells close the gap — is
  MEASURED FALSE and has been rewritten in place. The snapshot was never
  stale within a pass, because the trial walks callee-first and a decl is
  finished when it publishes; the divergence is between the two PARSES, and
  a trial cell and a final cell are different nodes in different
  generations. So the retirement condition written for the second pass —
  movers 0 licensing the deletion — is a gate the walk cannot pass. PLAN
  §11 5.2 had it right: the class dies WITH the pass. The honest condition
  is order-independence closing structurally, decl→site propagation so one
  generation suffices, and then the pass and its counter go together.
  ▶ WHY IT STAYS: the fix is correct by the law even though it did not
  clear the symptom (CLAUDE.md ⊕, the stack-don't-revert clause). The env
  carrying cells is what the stage contract prescribes, thirteen readers
  are total where they were partial, and a surrender fallback is gone. What
  it bought is knowledge: the next attempt aims at the second parse, not at
  the publish.

- 2026-09-01 · pin 5b7ddb96c9c5b030 · THE MEDIUM CAN MARCH ITSELF AGAIN.
  CLEAN m2 == m3 at 415103 lines (494 fewer than the pin before it),
  census 0; verb parity green — `mentl march` reproduces the m3 leg byte
  for byte; verify green with two ceilings raised in-commit.
  ▶ WHAT WAS FOUND: `mentl march` was DEAD, and had been for as long as
  nobody looked. Its chain omitted `lower_handler_stack_ctx`, so
  `lower_frame_fence_push`'s perform reached no handler and the verb
  trapped inside `project_nested_fn` on every run. The board never saw
  it: every gate calls `tools/march.sh`, so the scaffold stayed green
  while its own successor could not judge a generation. §11's tripwire
  (4) one layer up — a gate that stops being reported stops being run,
  and here the scaffold's existence was the cover.
  ▶ WHAT LANDED: the missing home. Seven lowering routes each
  hand-copied `string_table ~> emit_memory_bump ~> body_context ~>
  mentl_default ~> lower_scope ~> lower_handler_stack_ctx ~>
  arm_state_ctx ~> spec_registry`; march's copy is where a handler fell
  out. `emit_context` is that chain's one home — infer_context's peer on
  the far side of the cursor — and `compile_context` is the second fact
  the copies were re-deriving: that a lowering route installs emit
  inside analysis. A caller now supplies only its sink and its
  filesystem prefix, which is the only part that ever differed. The
  emission fell 415597 → 415103 lines.
  ▶ THE GATE, SEEN RED: `tools/march.sh` grew a verb-parity leg — the
  verb runs on the generation the script just judged, and must exit 0,
  match the m3 leg's line count, and report that it reproduces it. Run
  against the pre-fix boot it exits 1; against this pin it is green.
  ▶ THE RATCHETS, RAISED IN-COMMIT: movers 468 → 470 and effectful
  lambdas 384 → 385, both this change's own arithmetic. The two new
  context fns are effect-polymorphic HOFs, which is precisely the shape
  the movers class is made of — two HOFs in, two movers out, a 100% rate
  against a ~0.8% baseline, the mechanism showing itself. The lambda is
  the one `() => emit_context(body)` that composing two thunk-taking
  stacks costs; the first shape of this landing cost seven and the tier
  convicted it, correctly, before the collapse paid six back.
  ▶ WHAT THE DIG ALSO MEASURED, banked for the next landing: the movers
  are a read-ordering surrender, not a judgment disagreement.
  `callee_borrow_params` (own.mn) matches `Frozen(_, TFun(ps, _, _))`
  and answers `_ => None` otherwise — so when a callee's env entry is
  not yet an arrow, every bare arg reads and the grade lands `r`, where
  the final's re-judgment lands `o`. That is the whole printed flip set
  (`buffer:rlf → buffer:olf`, `list:ri → list:oi`). A census of readers
  still matching Frozen-only found thirteen sites, invisible to the
  checker because they hide inside nested patterns or behind that
  surrender: env.mn:94, own.mn:696, synth_proposer.mn:264,
  types.mn:3078/3082/3521, infer.mn:1082/2514/3278/3631/6516/7183/8331/
  9222. A probe publishing `Live(handle)` at both publish sites built
  m2 clean and died at infer.mn:1082 — `row_print`, the movers
  instrument's own reader — which is what named the census.
  ▶ AND A CONTRADICTION TO SETTLE: infer.mn:1193 gates the final pass's
  deletion on movers reaching 0; PLAN §11 5.2 records the grade class as
  refuted for one-sided patching, dying only WITH the pass. Both cannot
  hold. Deleting the pass today ships the trial's under-resolved answer
  on 470 schemes, so the real gate is the sentence at infer.mn:1010-1012:
  order-independence closes structurally — live cells plus decl→site
  propagation — and the pass deletes then.

- 2026-09-01 · pin 9214b85c910b0d40 · THE ENV'S JUDGMENTS BIND AS FROZEN
  OR LIVE. CLEAN m2 == m3 at 415597 lines, census 0; rungs 8/8 and
  micros 148/148 through the new wheel, frontier 374/0, verify green
  end to end.
  ▶ WHAT LANDED: the schemes-are-edges stage contract's terminal form —
  Binding = Frozen([Int], Ty) | Live(Int): a publisher's decision
  carried verbatim, or the graph's cell, read at consumption.
  generalize_pair derives (qs, ty) from the cell; judgment_ty and
  judgment_pair are the one reader-side read, and twenty-four reader
  sites flow through them instead of re-deriving the projection. The
  manifest link caught the kernel vocabulary calling upward into the
  judgment layer: the ctor-membership predicates moved beside their
  only reader in query (import infer declares the edge the blob link
  hid), and query_flow_label's env arm reads a live cell through its
  own graph op. Movers fell 470 → 468, ratchet lowered to hold.

- 2026-08-26 · pin 8cb23d6eabf53e2a · THE ARENA CENSUS READS, SO THE
  SILENT ZERO COULD NOT STAND. TRANSITION m3 == m4 at 415923 lines,
  census 0; frontier 373/0 (the arena census leg born RED, green here),
  verify green.
  ▶ WHAT LANDED: the image_bytes print beside the movers line (the arena
  chain's named next landing), image_enter/exit brackets on three more
  families (intern's miss arms, the WAT buffer's yield and collect
  extents, the branch diagnostic bank), and the arena census leg in the
  frontier. The per-fn emission region's probe receipt banked at its
  site: landed 2026-07-25, its overwrite-before-read contract is the
  bracket's standing law.
  ▶ THE CATCH, IN ORDER: the print's first read was 0, because the
  image arms hardcoded $heap_ptr — a global the threaded wheel never
  moves; the live heap line is the shared cell at 64. Every extent
  delta since family 1 landed was heap_ptr − heap_ptr. The arms read
  $heap_mark_impl now, the strategy-invariant read the neighboring
  heap_mark op always had; the correct value (721192 on the probe
  fixture, 725472 on the gate's) arrived only in m3, because an emit
  arm is genetic material — m2 carries boot's version, m3 carries the
  source's.
  ▶ THE TRANSITION: the march arbitrated m3 == m4 and re-pinned from
  m3, the trusting-trust anchor doing exactly its job.
  ▶ THE REFUSAL: the first schemes-are-edges stage attempt (a Live
  variant in Scheme, a projection boundary, a wrapper ADT, twenty-five
  pattern edits) was refuted by the medium three ways: H6 totality
  taxed every read site; generalize's reach smuggled WASI through every
  resolve row; the whole surface is throwaway at the terminal form.
  Reverted whole; the terminal contract (env carries cells, quantifier
  a caller-side projection, instantiation the correspondence-edge mint,
  trial/final collapse following) is the entry's stage contract in
  RESIDUE. Not a lesser design made to work.
  ▶ RIDER: the 63fad408 commit message called the space verb merge
  "Arc B"; the spine's own text makes it Arc E. PLAN is the authority;
  commit messages are prose shadows.

- 2026-08-26 · pin a7a0529464cc1234 · THE SURFACE MOVES TO ITS OWN ADDRESS
  SPACE. CLEAN — m2 == m3 at 415834 lines, census 0; frontier 372/0
  re-stamped at this sha, the gate's wall 274.9s → 159.1s.
  ▶ WHY: the Space spine (PLAN §11, THE STANDING CURSOR) opens with an
  address change on purpose — `mentl space` (Arc B) lands semantics, and
  semantics land cleanly only when the surface's files already live where
  they will stay. The demo surface's library half moved lib/runtime/* →
  lib/* whole; the wheel held the same 415834 emitted lines through the
  move, which IS the test: a relocation that reaches emit was not a
  relocation.
  ▶ THE PIN FLOATED FOR ONE SESSION, AND THE MARCH CAUGHT IT. The first
  re-pin (b6a43d39) predated the sweep's finding; when lib/combinators.mn
  learned its missing `import effects` (mk_ef_pure), the march refused the
  old sha and this pin exists — same 415834 lines, different bytes: one
  import line changes a module's judgment in place. A pin is a claim about
  source, and a source edit after the pin is a new pin.
  ▶ THE GATE FOUND ITS OWN DRIFT WHILE BLESSING IT. The solo sweep went red,
  and the red derived to two independent causes, neither in lib at first
  sight: the sweep loop globbed lib/*.mn twice, so one E_MissingVariable in
  lib/combinators.mn was reported as two; and combinators itself was missing
  `import effects` for mk_ef_pure — a module under-importing its names, the
  exact class the sweep exists to catch, found by fixing the counter that
  watches it. Ceiling stays 0; the drift catalog has one real retiree.
  ▶ THE FLIGHT: the frontier's census (24 queries) and solo sweep (~48
  module checks) fan out eight-wide now — xargs -n 1 (its default batching
  merged children into one invocation; the landed-count guard caught the
  silent drop before it could teach the gate a false green), spawn
  concurrent, judge serial, because bash counters cannot cross children.
  Boot tax measured at 53ms×250≈13s of the gate — cold start was never the
  cost; the work is real, so the win is flight, and the order-of-magnitude
  still lives in the medium (Arc C warm sessions, §5.O layer 4). The
  oversubscription is honest: 8 concurrent wasmtime instances stack their
  own JIT threads (423s user for 159s wall), which is the memory graph Arc
  C exists to flatten.

- 2026-08-18 · pin 000fee7f6ada9c90 · THE MEDIUM COUNTS ITS OWN
  POPULATION. CLEAN — m2 == m3 at 415834 lines, census 0, frontier 372/0
  with twenty-two census shapes.
  ▶ WHY: `Hβ.infer.declared-row-vacuous-against-a-free-body-row` is
  stamped and its build was blocked on one number — how many wheel fns
  declare a row AND call a parameter, since each is a site whose judgment
  changes when the declaration stops being vacuous. That seam has a
  history (646 false mismatches, twice) and the stamp forbids building it
  on reasoning.
  ▶ NO GREP COULD ANSWER IT. A param MENTIONED is transport; only a param
  CALLED puts its row into the enclosing body's row, so the question is
  structural — the callee's own VarRef — not textual.
  ▶ WHAT LANDED: `CsDeclaredRowHof`, the twenty-second census shape, four
  sites like every other (the ADT, the label, the detector, the CLI name)
  plus a fuel-bounded subtree walk mirroring CsPrintInReport's. Both facts
  are read where the graph holds them: the signed clauses are FnStmt's own
  field, the call is the weave's tree edge.
  ▶ THE ANSWER: 11 across the eight largest modules — infer 2, lower 3,
  effects 1, parser 1, types 1, query 1, prelude 1, lists 1. That makes
  the crown fix ONE LANDING rather than an arc, and fewer than 11 will
  actually refuse since a callback already inside the declared cap stays
  admitted.
  ▶ THE SELF-BUILD RATCHET in its plainest form: the instrument the
  medium lacked is now a verb facet it owns, pinned by the frontier
  roster, and it stays as the ratchet for whoever builds the fix.

- 2026-08-18 · pin 97b8475ebc27c34c · THE RESULT CAP IS TOTAL OVER Ty.
  CLEAN — m2 == m3 at 415522 lines, census 0, crown 62/0, frontier 372/0.
  ▶ THREE CUTS, THREE HOLES, ONE CAUSE. The cap matched a top-level TFun
  (a list and a tuple leaked), then three containers (an alias and a
  variant payload leaked). Each hole was found by a probe rather than by
  reading, and each had the same cause: a `_ => t` arm over a load-bearing
  ADT answers "nothing to cap" for every shape nobody has thought of yet.
  That is the forbidden residue the audit names, sitting in a function
  written to close a soundness leak.
  ▶ WHAT LANDED: the walk enumerates all fifteen Ty constructors with no
  catch-all, so a new one cannot compile until someone decides what it
  means for a result. TAlias, TRefined, TReprPin and TRecordOpen recurse;
  TCont is left alone (its R and S are the resume boundary, typed by the
  typed-resume law at the arm); TName is left alone deliberately.
  ▶ THE CENSUS LAW'S CONSTRUCTIVE HALF is the point: after the second
  container the answer stopped being another arm and became the pass that
  makes the whole class impossible.
  ▶ OPEN, named: `Hβ.effects.variant-payload-fn-row`. A constructor's
  payload row is declared at the type declaration and lives on the
  constructor's scheme — a different writer — so it wants the same
  variance rule at that site, with its own population measured first.
  ▶ GATE: leak-resume-latent-via-alias, seen RED.

- 2026-08-18 · pin 0be798f9af1a7859 · THE RESULT'S CAP IS STRUCTURAL.
  CLEAN — m2 == m3 at 415225 lines, census 0, crown 61/0, frontier 372/0.
  ▶ THE ARC NAMED LAST LANDING DOES NOT EXIST. That entry called a plain
  fn's declared fn-typed return and a record field's declared fn type the
  remaining work. All three shapes already refuse — declared fn return,
  INFERRED fn return, declared record field — and the reason is
  structural: a fn HAS A BODY, so its result row is inferred from what the
  body performs and genuinely carries `+E`. An op has no body, so its
  declared type is the only source and a free var there had nothing to
  constrain it. That is what made the op result the single special case,
  and why a population sweep found zero of all three in src+lib while only
  one leaked.
  ▶ THE REAL REMAINDER, from the same probe: the first cut matched only a
  TOP-LEVEL TFun, so `give() -> [() -> Int]` and `give() -> (Int, () ->
  Int)` checked clean and ran at 7 while the bare `give() -> (() -> Int)`
  refused. A closure hides in any container the result carries.
  ▶ WHAT LANDED: `cap_result_fn_row` recurses — TList, TTuple, TRecord,
  and a returned fn's own result. Its PARAMS keep their vars, because a
  param of a returned fn is a demand on whoever calls it: the
  contravariant half of the one rule.
  ▶ THE HOOK REFUSED TWICE and both were right. Drift mode 9 fired on the
  word "until" in a fixture comment — history reading as deferral, rewritten
  positively rather than suppressed. Then the anonymity ratchet convicted
  the inline record-field lambda, 384 → 385, "a row newly denied its decl
  home"; it is `cap_result_field` now, a named fn.
  ▶ GATES: leak-resume-latent-in-list and -in-tuple, both seen RED.

- 2026-08-18 · pin 016e00f38745aa79 · A RESULT IS NOT A FLOW CHANNEL.
  CLEAN — m2 == m3 at 415107 lines, census 0, crown 59/0, frontier 372/0,
  16.26s wall, peak 2274164 KB.
  ▶ THE LEAK, found by the 6.3 sweep's untested carriers: a closure
  performing E, handed OUT of an arm through `resume` and called under
  `with !E`, checked clean and RAN (exit 7, the outer handler answering —
  so the perform was real and the negation simply unenforced). The same
  closure written inline was caught. The fanout branch, the other
  untested carrier, refuses correctly.
  ▶ THE ROOT was not the resume site. Writing `with Pure` on the op's
  returned fn type made the identical program refuse, which proved the
  subsumption machinery is reached there and works — there was nothing to
  subsume UNDER. An unannotated fn type mints a free row VAR, and
  `fn_arg_directional_positions` fires only on a concrete cap
  (`row_cap_form`), deliberately: a var-tailed PARAM row is the
  effect-polymorphic flow channel `map`'s `f` needs, and masking it once
  convicted 297 wheel sites in one march.
  ▶ THE RULE IS VARIANCE. A parameter is a demand the caller fills, so its
  unannotated row stays a var. A result is a promise about what the
  produced value may do — nothing flows in — so its unannotated row caps
  at Pure. Every other latency carrier already behaved that way: field,
  list element, tuple, variant, default param, handler state all refuse.
  ▶ WHAT LANDED: `cap_result_fn_row` at `register_one_op`. Blast radius
  measured FIRST and empty — no op in src or lib declares a fn-typed
  return — which is why this was one landing and not an arc, and also why
  the crucibles are its only oracle: m3 == m4 cannot see a form the wheel
  never writes.
  ▶ GATES: three crown crucibles, all seen RED first —
  leak-resume-latent (explicit cap), sound-resume-transport (pure closure
  admitted), leak-resume-latent-bare (the form a person actually types,
  which ran at 7 before this and reports `E vs Pure` after).
  ▶ REMAINDER: the other covariant positions — a plain fn's declared
  fn-typed return, a record field's declared fn type — are the arc, each
  needing its own blast-radius measurement. The parser mints all three
  rows at ONE site because it cannot see the position, so each consumer
  caps for itself. E_EffectMismatch remains unarmed, so the bare form
  reports and still runs.

- 2026-08-18 · no pin (tests + tools) · THE BATTERY FOR BLIND SPOTS HAD
  ONE. The syntax battery exists because the fixpoint, census and micros
  are green on what the wheel does and silent on everything else — and it
  runs its fixtures through a four-module blob (RTLIBS: memory, strings,
  lists, prelude) while a real program links seven through its import DAG.
  ▶ FOUND by running all nine fixtures through the manifest and comparing
  against their declared expectations: eight agreed, `labeled-args` wanted
  14 and exited 1. Its fn was named `spawn_task`, which is an op of the
  WasiThreads effect, so through the manifest the declaration was
  unreachable and every call performed the op. It had passed since it was
  written because threading is not in the blob.
  ▶ E_FnShadowsOp, armed hours earlier in the same session, is what named
  it — the class's first outing on a program nobody wrote to test it.
  ▶ WHAT LANDED: a manifest leg beside the syntax battery. Every fixture
  must also CHECK CLEAN through the real link; a form that behaves
  differently in the two links is a finding either way. Seen RED against
  the unfixed fixture, naming it exactly. The fixture's fn is `queue_task`
  now, and it runs 14 in both links.
  ▶ SWEPT while there: every fixture in tests/{frontier,micros,crown,rows,
  floors} through the manifest — exactly one E_FnShadowsOp, the deliberate
  one. Nothing else in the corpus is silently unreachable.
  ▶ NAMED: `Hβ.tools.micro-battery-link-is-the-blob` — the micro battery
  has the same link and no such leg, and a blanket check-clean contract
  does not fit fixtures that are meant to refuse. The shape that fits is a
  per-fixture declaration of which link it means, defaulting to the
  manifest, because that is what a person runs.

- 2026-08-18 · pin 62718b6e8cb3126f · ONE NAME, TWO KINDS. CLEAN — m2 ==
  m3 at 415042 lines, census 0, battery green, frontier 372/0, 15.52s
  wall, peak 2184164 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: E_FnShadowsOp, the fifteenth armed class, reported at
  `register_one_op`'s env write. A fn whose name is an op of a linked
  effect is UNREACHABLE — every call performs the op — and the body is
  judged against the op's signature, so the only symptom was
  `Int vs () -> t...` at the author's own call, naming a shape they never
  wrote. The span is the losing fn's, read from the prior env entry's own
  Reason.
  ▶ THE ROOT, measured: the env is append-only and read last-write-wins,
  and an effect decl re-registers its ops AFTER the entry module's
  declarations. The write order for `spawn` through the manifest is
  op / fn / fn / fn / op / op. The op lands last; the fn loses.
  ▶ WHY THREE ITERATIONS. Every reading site is structurally blind here:
  at the decl judgment the env answers FnScheme, at the call it answers
  the op, and by the time a reader looks one kind has already won. Two
  checks were built at reading sites and reverted whole (a six-arm class
  with an env read at pre_register_stmt, then the same read by kind) —
  both marched CLEAN with census 0 and neither fired.
  ▶ THE KILL THAT COST THE MOST: both earlier probes ran through the
  MICRO harness, whose blob link has no lib/runtime/threading, so `spawn`
  was only ever a user fn there. `PROBE3 spawn -> FnScheme` and
  `225 of 225 NOT FOUND` were true and were about a program that did not
  have the defect. Pointing the same probe at the manifest link printed
  the write order in one run.
  ▶ THE GATE INHERITED THE SAME TRAP and went RED against a working fix:
  `run_refusal` pipes its fixture in on stdin — that same blob path. The
  leg drives `compile <path>` now, the way a person does. GENERAL FORM: a
  probe measures the LINK it was run in, and a defect that exists only
  through the manifest is invisible to every stdin-fed harness here.
  ▶ CEILING RAISED, recorded: the prelude floor 6360 → 6366. The class is
  six arms in src/types.mn, which is 57% of that floor, and a class is
  permanent content, not prose — trimming its comments recovered half the
  cost. Second ceiling event in three iterations, both types.mn
  additions, which is evidence FOR `Hβ.driver.link-is-reachability`: a
  program that asks for nothing should not link the diagnostic catalog.
  ▶ GATE: tests/frontier/mn-fn-shadows-op.mn + its manifest-path leg,
  seen RED at the pinned boot (0 reports) and RED again on its first
  wiring.

- 2026-08-18 · pin 9244d5d002fc0932 · AN ARGUMENT WITH NO SLOT IS THE
  REFUSAL. CLEAN — m2 == m3 at 414650 lines, census 0, battery green,
  14.39s wall, peak 2183688 KB against a 2310000 ceiling.
  ▶ THE DEFECT, measured: `add(1, 2, 3)` against a two-param fn checked
  clean and ran, returning 3. `idf(41, 2)` returned 41. Four shapes, no
  diagnostic anywhere.
  ▶ TWO WRONG SITES BEFORE THE RIGHT ONE, and the record matters more
  than the fix. FIRST I read `infer_call_arg_list`, whose `else` arm
  judges a surplus arg against no param — plausible, and not the drop.
  THEN I added the check at `infer_call_saturated`'s proven-TFun read,
  where the callee is BOUND and the args are in hand: the perfect site by
  inspection. It marched CLEAN and changed nothing. The probe is what
  ended it — an eprint at that read printed 1052 hits across the whole
  micro corpus, eight distinct shapes, and `len(args)` NEVER differed
  from `len(dps0)`. Adding the callee name to the probe finished it:
  `cname=add args=2 dps0=2` for a call written with three arguments.
  ▶ THE ROOT is `fill_arg_slots` in src/types.mn: the slot buffer is
  `make_list(len(params))`, so `place_positional` has nowhere to put a
  surplus argument and its own comment said so — "More positional args
  than params — arity is infer's concern; drop the overflow here". Infer
  could never make it its concern, because the drop is precisely what
  makes the counts equal downstream. Two subsystems each deferring to the
  other, and the argument fell between them. Every judgment after that
  point sees a saturated call, which is why a LIVE diagnostic class
  (EFnArityMismatch, correct and firing for TFun-vs-TFun since long
  before this) plus five probe shapes plus my own added check were all
  silent together.
  ▶ WHAT LANDED: `place_positional` reports at the overflow, at the
  SURPLUS ARGUMENT's own span rather than the call's — the argument with
  no home is the thing to point at. The class is unchanged; only the
  reachability is new. Reports as E_TypeMismatch, which is the declared
  code (SYNTAX names E_TypeMismatch and not E_FnArityMismatch; the
  constructor is an internal refinement carrying the better message, and
  `diag_code` maps it deliberately — the fixture header, not the arm, was
  the wrong half).
  ▶ MEASURED AFTER: all four over-application shapes report; the
  saturated and prefix controls hold at 42. Wheel census 0 — the medium's
  own source over-applies nothing.
  ▶ THE REMAINDER is ARMING: E_TypeMismatch reports but does not refuse,
  so `add(1, 2, 3)` still produces a runnable module. That is the
  name-dependent class §7 already tracks toward universal refusal, not a
  new gap.
  ▶ FOUND ALONGSIDE, pre-existing (measured by swapping boots, identical
  on both): the MIXED positional-then-labeled call form SYNTAX declares
  with a worked example — `spawn(2, timeout = 40)` — reports
  E_UnknownArgLabel for a label that IS a declared parameter. The fully
  labeled form runs correctly (tests/syntax/labeled-args.mn, 14). Banked
  as `Hβ.infer.mixed-positional-labeled-call`.
  ▶ GATE: tests/micros/mn-refuse-over-application.mn, seen RED as a
  clean-checking program that ran.

- 2026-08-18 · pin bb317fe4ec6a7ce6 · UNDER-APPLICATION IS THE
  HOLE-PRODUCT. CLEAN — m2 == m3 at 414629 lines, census 0, battery
  green, 15.07s wall, peak 2281768 KB against a 2310000 ceiling.
  ▶ FOUND by probing the `??` family as an oracle-blind surface — SYNTAX
  §«Partial application» declares five spellings of one primitive and the
  wheel's own source writes none of them. Three of five failed, every one
  CHECKING CLEAN first: `add(1)(41)` and `let inc = add(1); inc(41)`
  emitted `(call $add)` with two operands where three were expected
  (wat2wasm refused — an oracle outside the medium); `let g = (a,b) =>
  a+b; g(1)` produced a module that assembled and trapped at 134; and
  `add(1, 2, 3)` on a two-param fn ran, returning 3, the surplus
  evaluated and dropped. The two that worked — `add(??, 41)(1)` and
  `5 |> add(37)` — are what made the gap legible.
  ▶ THE ROOT was one redundant guard. `partial_unfilled` required an
  AUTHORED `??` before treating a call as a hole-product, so the bare
  positional prefix fell through to the direct-call emit. But
  `partial_split` has always turned a slot past the supplied args into a
  param — its own comment reads "or a hole-adjacent short tail" — so the
  entire mint the prefix form needed was sitting behind a decider that
  would not reach it. The decider now reads ARITY: short of the declared
  params → partial; saturated by count with an authored hole → partial;
  over-applied → unchanged.
  ▶ THE MARKER'S STATED REASON DISSOLVED RATHER THAN BEING OVERRIDDEN.
  The comment said a recovered callee's TFun arity is a guess under
  productive-under-error and flooring every mismatch would collapse the
  module. True, and already answered ONE LAYER DOWN: `partial_callee_form`
  admits only a resolved FnScheme or ConstructorScheme, and
  `lower_call_partial` floors everything else typed
  (LInvariantFailure/PartialCalleeShape), so a guessed arity reaches a
  floor and never a wrong call. Measured beside it: an unresolvable callee
  raises E_MissingVariable, an armed class, and `mentl compile` writes a
  ZERO-BYTE wat for that program — there is no module to collapse. Two
  guards for one property, and the outer one was the defect.
  ▶ MEASURED AFTER: `add(1)(41)` → 42, `let inc = add(1); inc(41)` → 42,
  `c3(10)` then `f(30, 2)` → 42, `c3(10, 30)` then `f(2)` → 42, the
  constructor partial `Pair(42)` then `mk(7)` → 42. Controls held at 42.
  ▶ CLOSED: `Hβ.emit.under-application-suspension` and
  `Hβ.emit.partial-application-arity` — the same defect at two arities,
  named nine days apart.
  ▶ OPEN, one face: the LOCAL callee (`let g = (a,b) => a+b; g(1)`) still
  exits 134, which is the typed floor firing by contract —
  `Hβ.lower.partial-local-callee`. Its honest gap is that a floor is a
  bare trap where a diagnostic belongs. NAMED:
  `Hβ.lower.over-application-drops-surplus`, measured this landing and
  left unbuilt on the one-variable law — the arity is proven at the same
  read the prefix case now uses, one arm over.
  ▶ GATE: tests/syntax/partial-prefix-application.mn, seen RED as the
  operand-count mismatch before the change.

- 2026-08-18 · pin f95ce4c642134d2b · THE SCANNER RETURNS ITS VALUE, NOT A
  POSITION. CLEAN — m2 == m3 at 414608 lines, census 0, battery green,
  frontier 371/0, 17.59s wall, peak 2273604 KB against a 2310000 ceiling.
  ▶ WHAT WAS WRONG, measured before anything was written: `0b1012` ran and
  exited 5, `0o1238` exited 83, `0b12` exited 1, a bare `0x` and a bare
  `0b` and `0o9` all exited 0, and `123abc` reported `E_MissingVariable:
  abc` — the medium naming a fragment the author never wrote. Every one
  compiled clean and ran.
  ▶ THE ROOT is the Carried-Truth Law at the lexer. `scan_number` walked
  the literal, proved its base, and proved byte by byte which bytes were
  digits of it — then returned a POSITION and an Int base in {2,8,10,16}.
  The caller re-sliced the source and walked it AGAIN through
  `parse_int_base_loop`, whose three hand-written byte ranges accepted any
  hex digit whatever the base and answered `0` for everything else. Two
  walks, two classifiers, and a fabricated value wherever they disagreed —
  which is precisely what a digit outside its base is. The loop's own
  comment named the fabrication and deferred it to "peer sub-handle
  B.12.4.R", a naming scheme three eras dead.
  ▶ WHAT LANDED: `NumBase = BBin | BOct | BDec | BHex` (drift 8 deleted —
  the base was a flag-as-int matched by `base == 10`), and `base_digit`,
  which answers IS-a-digit and WHICH-digit as ONE `Option(Int)` so the two
  can no longer drift apart. `scan_number` returns `NumScan` — `NumInt`
  carrying the accumulated value, `NumFloat` carrying only the extent
  (parse_float still owns the mantissa walk), `NumNoDigits` for a prefix
  that promised digits and met none. `parse_int_base` and
  `parse_int_base_loop` lost their only caller and are deleted:
  lib/runtime/strings.mn is 39 lines lighter.
  ▶ E_MalformedNumericLiteral is the FOURTEENTH armed class, and the
  abutting-alnum test lives at the ONE call site because it is the same
  rule for all four bases: a literal that ends against a letter or digit
  was never one literal. Armed at birth on the lexical licence — the
  judgment reads source bytes, so it has no resolution dependency and
  cannot differ between the blob link and a user path. Wheel census 0 at
  arming.
  ▶ THE FLOOR CAUGHT ME, AND THE FIRST STORY ABOUT IT WAS WRONG. The
  frontier came back 370/1: the prelude floor (source lines a program
  that asks for nothing must still process) read 6413 against a 6400
  ceiling. Six pins of `frontier: NOT RUN` and a per-module-import
  landing in lib/ made a complete story where the red predated this
  session. Stashing the three source edits and re-running against the
  previous boot measured 6359 — GREEN. The red was mine: src/types.mn is
  3672 of the floor's 6352 lines, 57% of it, so ~40 lines of lexical ADT
  landing there cleared a ceiling that had 41 lines of slack. The ADTs
  moved to src/lexer.mn, which is where their only readers are and which
  a bare program does not link; the floor now reads 6352, seven below
  where the session found it, and the ceiling falls 6400 → 6360 to hold
  it. The kill is banked in RESIDUE with the stash that produced it.
  ▶ THE GATE LIED ABOUT THE FIXTURES IT WAS REFUSING. Both new refusal
  micros reported `m2 COMPILE trap=!6+25+-.` — no trap existed; the
  harness greps `!\S+` out of stderr and printed an effect row mined from
  the movers report. It now names a trap only when stderr shows one, and
  otherwise prints the first real error line plus the `// expect: refuse
  E_Class` header the fixture was missing, which is what the failure
  actually was. PLAN §9's "a diagnostic's NAME can lie", inside the gate.
  ▶ GATES, RED FIRST: tests/syntax/numeric-base-literals.mn (the control —
  0b1_011 + 0o17 + 0x2A + 2_3 = 91, already green at the old pin, because
  well-formed literals always worked); mn-refuse-malformed-base-literal
  and mn-refuse-base-prefix-no-digits, both measured running with
  fabricated values (5 and 0) against the pinned boot before the fix.
  ▶ NAMED: `Hβ.repr.option-of-word-niche` (base_digit allocates per digit
  byte — a representation cost, and splitting the answer back to dodge it
  would restore the bug), `Hβ.query.cost-per-module` (the facet reports a
  sum; which module carries the floor was answered by hand),
  `Hβ.verify.comment-ref-ratchet-is-dark` (the solo checks emit
  W_CommentRefUnresolved freely, the census stderr the ratchet reads
  carries zero, and the reference in question resolves nowhere in either
  link — one fact, no cause, next probe named).

- 2026-08-18 · pin 567a96659693 · SOURCE IS NOT A PLACE TO SAY I DO NOT
  KNOW. CLEAN — m2 == m3 at 414196 lines, census 0, battery green,
  frontier 371/0, 16.66s wall, peak 2271636 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: `effrow_writable` / `effname_writable` / `effarg_writable`,
  and `tighten_fold` consults the first before authoring. A row that is
  TRUE but carries an argument with no source spelling is declined, and
  the skip line says which reason it is.
  ▶ THE ENUMERATION THE STAMP OWED CHANGED THE TARGET TWICE. First: the
  splice is `show_effrow(used)` inside `patch_with_clause`, and
  `show_effrow` is the SHARED renderer — diagnostics, `mentl where` and
  the audit report all read it — so the fix could not live there without
  rewriting every diagnostic. Second: `EANode` was innocent. Its renderer
  learned display totality in August (a bare VarRef writes its name, any
  other shape takes an honest placeholder, its comment recording the fmt
  re-parse fixpoint that taught it). The debug handle came from `EAType`
  through `show_type` on a free variable — an arm one line away that never
  learned the same discipline.
  ▶ AND THE FIRST BUILD PUT THE GUARD IN THE WRONG PLACE. Inside
  `patch_with_clause` it worked — the verb declined and wrote nothing —
  but `None` then carried two reasons and the caller printed one, so the
  skip line said "no single-line with-clause" about a line that had one.
  That is the same class corrected two pins ago at a diagnostic's message.
  Moved to `tighten_fold`, where the reason is spoken: one verdict, one
  meaning, two distinct refusals.
  ▶ MEASURED, verb to verb: before, `mentl tighten src/lexer.mn` wrote
  `Iterate(t42546@e1, t42548@e1)` into lib/prelude.mn and the wheel
  refused itself with fifteen unresolved-hole errors. After: `iterate` and
  `iterate_from` are declined by name with the row reason, `list_filled_from`
  still declined with the clause reason, `0 of 3 authorable applied`, and
  lib/prelude.mn is untouched.
  ▶ THE MEDIUM CAUGHT MY OWN ERROR IN PASSING: `E_PatternInexhaustive` on
  `effname_writable` — EffName has three variants and a filtered grep had
  shown me two. The filter-is-part-of-the-claim law, paid for again.
  ▶ NOT GATED, named instead: a leg that runs a WRITING verb during verify
  needs a scratch-copy harness. `Hβ.tools.authoring-verb-writes-only-proven`
  carries the shape.
  ▶ AND THE ANONYMITY RATCHET CAUGHT THE FIRST DRAFT: eta 28 → 31, three
  `(a) => f(a)` wrappers I had just written where the name itself is the
  argument. The tier's own MachineApplicable fix — pass the name — and the
  gate refused the commit until it was taken.
  ▶ ONE VARIABLE: the writability check and where its refusal is spoken.

- 2026-08-18 · pin 4dc2ac881254 (unchanged) · THE VERB WROTE A HANDLE
  WHERE A VALUE BELONGED. CLEAN — m2 == m3 at 413773 lines, census 0,
  battery green, and the sha IDENTICAL to the prior pin, because row
  narrowings are judgment and not emit.
  ▶ MEDIUM-AUTHORED, which is the point. `mentl tighten src/lexer.mn`
  wrote 33 row narrowings across the transitive link — 31 of them sound,
  every one narrowing a declared row to what its body proves, and none of
  them typed by hand. That is the preferred form the self-build ratchet
  names, exercised for the first time in this loop.
  ▶ AND THE VERB FABRICATED TWICE. Two rewrites carried
  `Iterate(t42532@e10, t42533@e5)` — `show_handle`'s free-variable
  rendering, a projection meant for a reader, spliced into source as an
  effect instance's arguments. The wheel refused itself: m2 generation
  trapped with 15 `E_UnresolvedHole` errors on those columns.
  ▶ THE PROVEN-GOOD SUBSET SHIPPED, per the verdict law: revert
  lib/prelude.mn alone, march the other four files, CLEAN at the same sha.
  ▶ THE FINDING IS BANKED as
  `Hβ.tighten.authors-an-unresolved-handle-as-source` with its stamp. One
  read serves two consumers whose contracts differ — a projection may say
  "unresolved at epoch e", an authored patch may not — and the verb uses
  the projection for both. Its decline path already exists (the same run
  skipped a site with no single-line with-clause and said so); what is
  missing is the resolution check.
  ▶ HOW IT WAS FOUND: by asking the medium instead of reading its source.
  `mentl audit src/lexer.mn` named the tightenable site and offered the
  patch; running the verb produced the defect. Nine iterations of this
  loop used `check`, `query` and `test` and never `audit` or `tighten`,
  which is why a fabricating authoring verb sat unmeasured.
  ▶ ONE VARIABLE: the medium's own tightening batch, minus the two lines
  it could not write honestly.

- 2026-08-18 · pin 4dc2ac881254 · THE MESSAGE CATCHES UP TO THE CLASS.
  CLEAN — m2 == m3 at 413773 lines, census 0, battery green, frontier
  371/0, 15.95s wall, peak 2269028 KB against a 2310000 ceiling.
  ▶ THE BANKED PROBE ANSWERED ON ITS FIRST RUN: a config DEFAULT
  performing the handler's own op already refuses with
  `E_InitPerformsOwnOp`. Defaults and state inits lower into one `inits`
  list, so the scope armed at the previous pin covers both — measured, and
  now held there by a fixture rather than by that coincidence.
  ▶ WHAT WAS ACTUALLY WRONG was the message. It said "state init" for both
  carriers, which is false for a default, and only writing the sibling
  fixture made the imprecision visible. The diagnostic now names what is
  known — a perform while the handler builds itself, from either carrier —
  instead of guessing which one it was. The class cannot distinguish them
  at that point and the message no longer pretends to.
  ▶ GATES: `mn-refuse-config-default-own-op` as a refuse contract, and
  `mn-config-default-outer-op` running at 7 — a default performing ANOTHER
  handler's op stays ordinary, the default still fires, `k` still binds.
  Both falsified before landing.
  ▶ ONE VARIABLE: the diagnostic's text.

- 2026-08-18 · pin 362ac8b1eeae · AN INIT CANNOT CALL THE HANDLER IT IS
  BUILDING. CLEAN — m2 == m3 at 413738 lines, census 0, battery green,
  frontier 371/0, 14.99s wall, peak 2259388 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: `E_InitPerformsOwnOp`, the THIRTEENTH armed class. A
  direct perform lexically inside `LHandleWith`'s own `inits`, naming that
  install's own handler, refuses at compile time. The emit pre-pass draws
  the scope as an install rather than threading a flag —
  `{ walk_lemit_list(inits) } ~> preinstall_init_scope(hname, span)` — and
  the arm compares the perform's handler name to the install's own.
  ▶ WHY ONLY THERE: the 1016 sibling guards in the wheel's own emit are
  belts under a LIVE `world_find`, and no static extent discharges them
  (measured the previous iteration, and the reason that framing was
  retracted). This site is the one where the zero is provable: the
  install's `world_push` is emitted below its inits, for every install of
  it, so the lookup cannot answer.
  ▶ THE SPAN IS READ, NOT FABRICATED. The backend had no span vocabulary
  at all — measured, the new lines are its only mentions — and the fix was
  not to invent one: `reason_span_or_zero(graph_reason_at(ih))` reads the
  install node's own Reason through the GraphRead row the backend already
  declares and the types.mn projection it already imports. The diagnostic
  lands at 2616:15-2616:22 rather than at zero.
  ▶ MEASURED BEFORE AND AFTER on the same program. At pin c3410610ce41 it
  compiled to 38467 bytes and trapped at exit 134, the belt naming the op,
  the handler, the extent and the fix — correct, and after emitting a
  module. Now: `E_InitPerformsOwnOp … at 2616:15-2616:22`, exit 1, nothing
  emitted.
  ▶ GATES, both halves: `mn-refuse-init-performs-own-op` as a refuse
  contract, and `mn-init-performs-outer-op` running at 42 — an init
  performing an op ANOTHER handler answers is ordinary and must stay so.
  Falsified in a scratch directory first: the same fixture with its
  expected class mutated reports `FAILR … wanted E_OccursCheck`.
  ▶ ONE VARIABLE: the inits scope and the class it reports.

- 2026-08-18 · pin c3410610ce41 · WHAT THE INSTALL EVALUATES, THE INSTALL
  PAYS. CLEAN — m2 == m3 at 413442 lines, census 0, battery green, crown
  56/0, frontier 371/0, 17.09s wall, peak 2274404 KB against a 2310000
  ceiling.
  ▶ WHAT LANDED: the config-DEFAULT `each` moves inside
  `inf_enter_fn(r_handle, …)` to sit beside the state inits the previous
  pin moved. One rule, two carriers — everything a handler install
  EVALUATES belongs in row(h), which the tee already adds to every
  installer.
  ▶ IT WAS THE PREVIOUS STAMP'S OWN OPEN QUESTION, and the answer was the
  same leak one field over. At pin b9733815b54d
  `handler hf(k: Int = op())` installed by
  `fn bad() with !E = (g()) ~> hf` checked CLEAN with T_OverDeclared
  reporting the body "only uses Pure"; the default genuinely performed
  (give `op` a handler returning 7 and the value arrives at `k`, exit 7).
  After: `!E + Any vs E`, with the run still answering 7.
  ▶ MEASURED BEFORE BUILT, in that order: the check-clean, then the
  install-time performance, then the edit. The confirmation was the
  build's first step rather than a substitute for it.
  ▶ THE COMMENT MOVED WITH THE CODE and lost nothing: a config default is
  still typed at its one home, the handler's own parameter scope, and an
  omitting explicit install still re-infers through resolve_call_args.
  What is new is where its ROW goes.
  ▶ GATES: `leak-config-default-performs` and `sound-config-default-pure`.
  The sound half matters as much here — the default still fires and still
  binds `k`, so charging what an install evaluates must not charge what it
  does not.
  ▶ ONE VARIABLE: the default `each`'s position relative to the row scope.

- 2026-08-18 · pin b9733815b54d · AN INIT PERFORMS WHERE THE ARMS PERFORM.
  CLEAN — m2 == m3 at 413442 lines, census 0, battery green, crown 54/0,
  frontier 371/0, 18.09s wall, peak 2282872 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: two lines moved. `infer_handler_state_inits` and
  `bind_handler_state_names` now run INSIDE `inf_enter_fn(r_handle, …)`
  rather than before it, so an init's row joins the same accumulator the
  arms use — the one whose own comment says "r_handle binds to R, the row
  `~> h` adds to the caller". No new carrier, no new concept: SYNTAX's tee
  rule already reads `+ row(h)`, and an init is part of the handler.
  ▶ THE BUILD'S FIRST MOVE WAS THE STAMP'S OWN: find the channel the ARMS
  ride, because arms already charge (`leak-arm-adds-row` refuses) and the
  fix should join that channel rather than duplicate it. It is `r_handle`,
  and the inits sat two lines above its scope.
  ▶ MEASURED BEFORE AND AFTER at the same repro. Before, at pin
  c968f690567b: `handler hf with s = op()` installed by
  `fn bad() with !E = (g()) ~> hf` checked CLEAN with T_OverDeclared
  reporting the body "only uses Pure". After: `!E + Any vs E`. The init
  still performs — `((g()) ~> hf) ~> he` with `op` handled to 7 exits 7,
  re-run after the landing — so the row was added without changing when
  the init evaluates.
  ▶ WHY THE WHEEL DID NOT NOTICE: every handler in it has a pure init,
  which is why census, fixpoint and the whole battery stayed green through
  a leak this wide, and why `sound-state-init-pure` is the half worth
  gating beside the leak.
  ▶ THE ENV HAZARD DID NOT FIRE. The site's own comment warns that an
  `env_extend` inside `inf_enter_fn` can vanish before lower, and
  `bind_handler_state_names` extends the env; the arms read those names
  and the march came back CLEAN at census 0, so the warning's scope is
  narrower than the move. Recorded because the next reader will ask.
  ▶ ONE VARIABLE: the two lines' position relative to the row scope.

- 2026-08-18 · pin c968f690567b · A FIELD THAT DOES NOT EXIST STOPS
  ANSWERING WITH ONE THAT DOES. CLEAN — m2 == m3 at 413442 lines, census
  0, battery green, frontier 371/0, 16.72s wall, peak 2283876 KB against a
  2310000 ceiling.
  ▶ WHAT LANDED: `absorb_into_residual`'s widening arm reads the tail.
  Under `RowAssumed` or `RowContinues` a new field still widens — more may
  genuinely exist. Under `RowClosed` the writer proved the residual IS the
  remainder, so a name outside it is provably absent and the access is a
  `type_mismatch`, the same verdict a closed record already gave. The tail
  landed at pin b8eff49b7252 as a projection; this is its first
  ENFORCEMENT.
  ▶ WHAT IT WAS DOING, measured before the edit and the worst version of
  the class. `let {a, ...rest} = ({a: 1, b: 2})` gives `rest` a residual of
  exactly `{b: Int}`. `rest.nosuch` checked clean and ran to exit 0. Then
  `rest.aa` — the name chosen to sort BEFORE the real field — ran to exit
  **2**, which is `b`'s value: the widened layout put `aa` at offset 0 and
  the real residual keeps `b` there. Not a missing refusal; an aliased
  read.
  ▶ THE CONTROL WAS ALWAYS RIGHT, which is what made the fix a
  restoration rather than a new policy: the same unknown name on a plain
  closed record is `E_TypeMismatch: { aa: … } vs { a: Int, b: Int }` at the
  access. The residual path simply was not giving the verdict the record
  path gave.
  ▶ THE MARCH SETTLED THE STAMP'S OPEN LINE. Whether any wheel or lib site
  leaned on the widening was unmeasured; a new refusal class earns its keep
  by surviving the self-compile, and it did — CLEAN at census 0 with the
  whole battery green.
  ▶ GATE: `tests/micros/mn-refuse-closed-residual-field` as a refuse
  contract, judged by `mentl test`. Falsified in a scratch directory rather
  than the battery: the same fixture with its expected class mutated
  reports `FAILR … wanted E_OccursCheck`, so the judge distinguishes
  classes and the contract is not a rubber stamp.
  ▶ THE SOUND PATHS ARE UNTOUCHED, each re-run: the legit rest field still
  answers 12, and the assumed-residual fixture still checks clean.
  ▶ ONE VARIABLE: the widening arm gaining its match on the tail.

- 2026-08-18 · pin bc516cf945bb · A DEMAND IS CHECKED, NOT INSTALLED.
  CLEAN — m2 == m3 at 413349 lines, census 0, battery green, crown 52/0,
  16.05s wall, peak 2279344 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: `absorb_into_residual` replaces the raw bind in
  `unify_two_open_records`. A field access builds an EXPECTED receiver
  `{field: <fresh> | <fresh row>}` and unifies the real one against it, so
  the incoming fields are a QUESTION. When the var already carries a
  residual, the shared fields now UNIFY — the graph's proof constrains the
  fresh variable, the direction that keeps a fact — and only genuinely new
  fields widen it. The unbound case is untouched: nothing is known, the
  union IS the reading, and it stays marked assumed.
  ▶ WHAT IT CLOSED, all three faces measured before and after. The `!E`
  leak: a closure performing E, reached through `{keep, ...rest}` and
  called under `with !E`, checked CLEAN at the previous pin and now
  refuses with `!E + Any vs Memory + Alloc + E`. The type hole:
  `rest.run + 1` checked clean and is now
  `E_TypeMismatch: () -> Int with E vs Int`. The downgrade: inserting one
  read before returning the binding used to turn
  `{ | { run: () -> Int with E } }` into `{ | { run: t35152@e11 } assumed }`
  and now leaves it unchanged.
  ▶ THE ENUMERATION THE STAMP OWED, run first and it moved the target.
  Three receiver shapes measured: an ANNOTATED open row keeps its known
  field's type (`E_TypeMismatch: Int vs List(Byte)` inside the callee), an
  UNANNOTATED record param defers to the call site (the callee judges Pure
  — that is the free-body-row fork, a different peer), and only a field
  living in a bound RESIDUAL was destroyed. Known fields went through
  `unify_record_fields_loop_shared` all along; the residual path was the
  one that wrote instead of checking.
  ▶ GATES: crown grew leak-rest-latent and sound-rest-transport (52/0),
  and tests/syntax/record-rest-field pins the type half as a running value
  at 12. The leak fixture was measured RED at pin b8eff49b7252 this same
  session, which is its falsification.
  ▶ A NEW PEER FELL OUT: a demand naming a field a RowClosed residual
  lacks still widens rather than refusing, though the mark now proves the
  record cannot have it — `Hβ.infer.demand-widens-a-closed-residual`.
  ▶ ONE VARIABLE: the residual bind becoming a check.

- 2026-08-18 · pin b8eff49b7252 · A PROOF AND A GUESS STOP LOOKING THE
  SAME. CLEAN — m2 == m3 at 413243 lines, census 0, battery green,
  frontier 371/0, 14.27s wall, peak 2281976 KB against a 2310000 ceiling.
  ▶ WHAT LANDED: `NRecordRowBound`'s tail stops being `Option(Int)` and
  becomes `RecordRowTail = RowClosed | RowContinues(Int) | RowAssumed` —
  what the WRITER knew about everything past the fields. The open-CLOSED
  writer proves its remainder and marks `RowClosed`; the open-OPEN writer
  has seen two partial sets and their union, never the whole, and marks
  `RowAssumed`. The mark rides the write, because the fields alone cannot
  say which of the two produced them.
  ▶ WHY A THIRD ARM RATHER THAN A BOOLEAN: `Option(Int)` already answered
  "does the chain continue", and the missing question is a different one.
  Folding both into one shape is what made a proof and a guess return the
  same field offset, which is where the wrong-slot class lives.
  ▶ THE READER IS DELIBERATELY UNCHANGED. `open_record_full_fields`
  answers RowAssumed exactly as RowClosed, because refusing there turns
  mn-findtag into a trap — measured twice, once through the linked tail
  and once through a bind that recorded nothing. What an assumed remainder
  should DO is the open half of the stamp and the fork is Morgan's; the
  arm is written out rather than merged so the day that changes is a day
  someone chose.
  ▶ THE MARK IS OBSERVABLE, which is what makes this more than vocabulary.
  `mentl query "type pick"` reads `{ zeta: Int | {  } assumed }` on a
  declared `...` with no closed partner and `{ handle: Int | { region_id:
  Int } }` unmarked on findtag, whose residual comes from the closed-side
  writer. Both were read off the same two commands before the build, where
  they projected identically.
  ▶ THE GATE: tests/rows/ plus a verify leg with both halves — the assumed
  fixture must carry the mark AND the proven control must not, since a
  projection that says "assumed" everywhere or nowhere passes either half
  alone. Falsified three ways first: each check pointed at the other's
  file, and a wrong expected exit. The fixture also RUNS, pinning the
  wrong-slot answer 7 as a value rather than a description.
  ▶ ONE VARIABLE: the tail's representation and its projection. The
  reader's behaviour, the writers' field computation, and every other
  `NRecordRowBound` match are untouched, which is why a representation
  change at this depth came back CLEAN rather than as a transition.

- 2026-08-18 · pin 88050b76596d · THE FLOOR SAYS WHICH. TRANSITION first
  (m2 ≠ m3 by 8 lines, m4 exit 0 at 412987 lines, m3 == m4), then CLEAN
  (m2 == m3) after the quiet gate sent one line back — and the sha is the
  SAME BINARY across both, 88050b76596d. census 0, battery green, frontier
  371/0, peak 2177904 KB against a 2310000 ceiling.
  ▶ THE RATCHET WAS RIGHT AND THE ARTIFACT SAID SO. The new fn declared
  `ref rec`, copying its sibling, and the pre-commit quiet gate refused at
  authored ref 814 → 815 — a marker is inference failing, not a fix.
  Dropping it re-marched to a byte-identical pin, so the ownership
  inference had already reached that grade and the annotation was pure
  decoration. Precedent is not authority; the ceiling measured it in one
  commit attempt.
  ▶ WHAT LANDED: the emit's `field offset unprovable` marker carries the
  selector and the receiver's live type. `field_offset_unprovable_why` is
  the sibling of `field_sel_offset` over the same two operands — one
  answers the offset, the other answers why there was none — and the
  floor writes its answer. Measured on a fixture whose unannotated record
  param is read through a list pattern: before, `;; field offset
  unprovable`; after, `;; field offset unprovable: field 'slot' on
  { slot: Int | r24989@e5 }`. The RED half was read off the same file
  before the build.
  ▶ WHY IT IS A PROJECTION AND NOT A MESSAGE: the two facts printed are
  ones the graph already holds at that instruction, and the marker was
  standing in for them in prose. This arc re-derived the blocking row by
  hand four times across as many iterations; the emit knew it each time.
  It also DISTINGUISHES the two shapes the wrong-slot class turns on — a
  free tail prints as `r24989@e5`, an assumed-empty remainder as `{ }` —
  which is the difference between a remainder unknown and one fabricated.
  ▶ THE ROW WIDENED HONESTLY, AND THE MEDIUM ENUMERATED THE SITES.
  `show_type` performs `Intern`, so the first march refused at census 9:
  one error at the new fn and eight at the show-helper emit chain that
  reaches `emit_expr`, each with its own span. `+ Intern` on those eight,
  and the new fn dropped an `EnvRead` its body never performs. The
  compiler named every site; no grep was involved.
  ▶ THE FIRST MARCH ALSO FAILED ONE MICRO AND THE SECOND DID NOT. One
  variable moved between them — the corrected row — and the battery went
  green. Recorded as the sequence measured, not as a mechanism, because
  the mechanism was not probed.

- 2026-08-17 · pin 6cacd339350c · THE DISCRIMINATOR WORKS, AND THE ARC'S
  BLOCKER IS CLEARED. TRANSITION — m2 ≠ m3 by 36 lines, m4 exit 0 at
  412788 lines, m3 == m4, repinned from m3. census 0, frontier 371/0,
  16.39s and 16.70s wall on the two legs.
  ▶ WHAT LANDED: the two receivers of the nested-fn name discriminator are
  annotated with the frame record's whole field set, so their offsets
  resolve from the full sorted set instead of a foreign slot. Nested fns
  are QUALIFIED for the first time — bare `go`, `digit` and `search` are
  gone from the emit, and `parse_int_go`, `parse_int_digit` and
  `index_of_search` stand in their place, each once.
  ▶ THIS EXACT CHANGE BROKE THE MEDIUM THREE TIMES. It is the same two
  annotations that marched BROKEN with m4 trapping at exit 134, and what
  makes it land now is the previous pin's identity read: with the
  self-capture found by handle rather than by name, the early bind fires
  under qualification and targets the local the body actually reads. The
  fix and its prerequisite were separated by five iterations of measuring,
  and the separation is why this one is a TRANSITION rather than a fourth
  revert.
  ▶ THE M4 LEG IS THE WHOLE VERDICT. m3 alone was clean at every failed
  attempt too; only running the generation after it distinguishes "emits
  something" from "reproduces itself". The banked instruction to watch
  that leg from the first run was earned by three failures and paid off
  here.
  ▶ WHAT IS NOT FIXED, measured this turn: the open-row class itself.
  `fn pick(u: {zeta: Int, ...}) = u.zeta` over `{alpha: 7, zeta: 9}` still
  answers 7. The wheel's OWN exposure is closed — its discriminator no
  longer reads a foreign slot — but any unannotated record receiver still
  takes its offsets from the known set. That is the arc's actual target
  and it is untouched.
  ▶ THE ARC IS BACK WHERE IT WAS BEFORE THE DETOUR, with the detour's
  defect fixed rather than worked around: the emitter no longer breaks
  when a nested fn's name qualifies, so the row work can proceed without
  tripping it.

- 2026-08-17 · pin ec2f629f11e8 · THE SELF-CAPTURE IS READ BY IDENTITY.
  CLEAN, m2 == m3, census 0, frontier 371/0, 16.27s wall · 2280528 KB
  peak, 412788 lines, module 2421155 bytes.
  ▶ THE STAMP SAID "LFn CARRIES BOTH NAMES" AND THE INTERROGATION FOUND
  BETTER. A nested fn binds its own name to its own handle
  (`ls_bind_local`), a self-reference resolves through that bind, and the
  capture keeps the handle it resolved to (`LLocal(local_h, name)`) — while
  lower builds the closure with that same handle. So "is this capture the
  closure being built" is ONE comparison of two handles, needing no names
  at all, and the second name field the stamp priced is not needed.
  ▶ IT CLOSES BOTH HALVES OF THE DEFECT. `self_capture_name` replaces
  `captures_self`: it finds the capture by identity and returns THE NAME
  THAT CAPTURE READS, so the early bind targets what the emitted body
  actually loads. The predecessor compared the capture's name against the
  LowFn's name — two namespaces the moment the discriminator qualifies —
  and got the guard wrong AND would have bound the wrong local even had it
  fired.
  ▶ MEASURED, and no byte-identity is claimed this time. The pin moved to
  ec2f629f11e8 and the emit grew 7 lines against a smaller module,
  because the SOURCE changed; `m2 == m3` is the load-bearing reading —
  the new emit reproduces the old one exactly on the wheel's own source,
  so no self-capture in the wheel was being missed today. The fix is
  correct-for-the-future and neutral-for-the-present, which is what the
  fixpoint holding at a changed pin means.
  ▶ THIS IS THE THIRD DIRECTION TRIED at this defect and the first that
  did not have to be reverted. One name for the fn failed (the local
  namespace is source-named); keeping the source name failed (the symbol
  must qualify); carrying both was priced and then dissolved by reading
  what the graph already connects. Fewer fields, not more — the shape a
  Carried-Truth fix is supposed to have.
  ▶ WHAT REMAINS: the discriminator itself is still wrong (it reads a
  foreign slot through an open row), so nothing qualifies yet and this fix
  is dormant. Re-attempting the receiver annotation is the next step, and
  it is now the only known blocker between here and the row arc.

- 2026-08-17 · pin 6e05bd9404ed · THE PREVIOUS LANDING IS REVERTED, AND
  ITS OWN CLAIM IS REFUTED BY THE SHA. CLEAN, m2 == m3, census 0, 412781
  lines, 16.43s wall · 2177112 KB peak.
  ▶ THE NEXT STEP WAS THE CAPTURE SIDE, and reading it killed the previous
  step's DIRECTION. The local namespace is source-named end to end:
  `ls_bind_local(name, handle)` binds the source name in the enclosing
  frame, `collect_free_vars` collects source names, and the emitted WAT
  reads `(local.get $go)`. Binding the LLet to the QUALIFIED name
  therefore points it at the emitted namespace and leaves the source-named
  local unbound — the same use-before-def one layer over, not a fix.
  ▶ THE SHA REFUTES THE OTHER HALF OF THAT ENTRY. It claimed
  byte-identical output on the ground that `fn_name == name` wherever
  `outer` is empty. Reverting returns the pin to exactly 6e05bd9404ed, the
  tail-vocabulary pin — so if the forward change had been a no-op its own
  pin would have been this sha, and it was 3967d236b294 instead. SOME
  NESTED FN ALREADY QUALIFIES: `outer` is not empty everywhere, the
  discriminator is not uniformly broken, and the change altered real
  output while marching clean. The line count being equal on both sides
  (412781) is what made the wrong claim look measured. Re-marching after a
  comment-only edit returned the SAME sha again, which proves comments do
  not reach emit and leaves the fn_name substitution as the sole cause.
  ▶ WHAT THAT ADDS TO THE LAW: equal line counts are not identity, and a
  march verdict of CLEAN says the medium reproduces itself, not that the
  emit is unchanged. The pin sha is the identity oracle and it was sitting
  in the same output I quoted the line count from.
  ▶ THE STAMP STANDS AND IS NOW SHARPER. `LFn` carries one name spent on
  two namespaces; neither namespace can be made to serve the other, which
  is precisely why both single-name directions fail. The fix is `LFn`
  carrying BOTH the binding name and the emitted symbol, and the sites are
  enumerated (29 across lower.mn and wasm.mn).

- 2026-08-17 · pin 6e05bd9404ed · THE PREVIOUS LANDING IS REVERTED, AND
  ITS OWN CLAIM IS REFUTED BY THE SHA. CLEAN, m2 == m3, census 0, 412781
  lines, 16.43s wall · 2177112 KB peak.
  ▶ THE NEXT STEP WAS THE CAPTURE SIDE, and reading it killed the previous
  step's DIRECTION. The local namespace is source-named end to end:
  `ls_bind_local(name, handle)` binds the source name in the enclosing
  frame, `collect_free_vars` collects source names, and the emitted WAT
  reads `(local.get $go)`. Binding the LLet to the QUALIFIED name
  therefore points it at the emitted namespace and leaves the source-named
  local unbound — the same use-before-def one layer over, not a fix.
  ▶ THE SHA REFUTES THE OTHER HALF OF THAT ENTRY. It claimed
  byte-identical output on the ground that `fn_name == name` wherever
  `outer` is empty. Reverting returns the pin to exactly 6e05bd9404ed, the
  tail-vocabulary pin — so if the forward change had been a no-op its own
  pin would have been this sha, and it was 3967d236b294 instead. SOME
  NESTED FN ALREADY QUALIFIES: `outer` is not empty everywhere, the
  discriminator is not uniformly broken, and the change altered real
  output while marching clean. The line count being equal on both sides
  (412781) is what made the wrong claim look measured.
  ▶ WHAT THAT ADDS TO THE LAW: equal line counts are not identity, and a
  march verdict of CLEAN says the medium reproduces itself, not that the
  emit is unchanged. The pin sha is the identity oracle and it was sitting
  in the same output I quoted the line count from.
  ▶ THE STAMP STANDS AND IS NOW SHARPER. `LFn` carries one name spent on
  two namespaces; neither namespace can be made to serve the other, which
  is precisely why both single-name directions fail. The fix is `LFn`
  carrying BOTH the binding name and the emitted symbol, and the sites are
  enumerated (29 across lower.mn and wasm.mn).

- 2026-08-17 · pin 3967d236b294 · ONE NAME FOR ONE FUNCTION. CLEAN,
  m2 == m3, census 0, frontier 371/0, 16.32s wall · 2271368 KB peak,
  412781 lines both generations — byte-identical by construction.
  ▶ THE STAMP'S DEBT IS PAID, and its first move was the enumeration it
  said it owed: 29 `LFn` sites across lower.mn and wasm.mn, and
  `spec_closure_name` measured ORTHOGONAL — it mangles monomorphization
  twins, not nested-fn qualification. That cleared the way to the
  construction site itself.
  ▶ THE DIVERGENCE IS ONE EXPRESSION. lower.mn computes
  `fn_name = if outer == "" { name } else { "{outer}_{name}" }` and then
  built `LLet(handle, name, LMakeClosure(handle, fn_ir, …))` — the
  binding taking the SOURCE name while the `LFn` inside carried the
  QUALIFIED one. Two names for one function, agreeing only because
  `outer` is empty at every site until the discriminator works. They take
  the same name now.
  ▶ WHY IT IS BYTE-IDENTICAL AND STILL WORTH LANDING: `fn_name == name`
  wherever `outer` is empty, which is everywhere today, so the emit could
  not move — the march confirms 412781 lines on both sides. What changed
  is the INVARIANT the closure emit depends on: its self-capture
  early-bind is guarded by `captures_self(captures_exprs, fn_name)`, a
  string compare that answers false the moment the two names diverge,
  skipping the bind and leaving the closure's fn_ptr a zero local. Same
  vocabulary-first shape as the row tail slot: put the invariant in place
  while it costs nothing, so the behaviour change lands alone.
  ▶ WHAT REMAINS, stated so the landing is not read as the fix: the
  CAPTURES still reference the fn by its source name, so a self-capture
  under qualification is not yet consistent end to end. This closes one
  of the two divergences at the construction site; the capture side is
  the next, and only then does the annotation that started this arc
  become marchable.

- 2026-08-17 · THE SITE IS FOUND, AND IT ALREADY CARRIES A FIX FOR THIS
  EXACT TRAP (no pin — the output is a design stamp; boot unchanged at
  6e05bd9404ed).
  ▶ wasm.mn's `LMakeClosure` arm binds a self-recursive closure's own
  local to the record BEFORE filling captures, guarded on
  `captures_self(captures_exprs, fn_name)`. Its comment names this
  iteration's symptom verbatim — "a null fn_ptr, the parse_int nested-go
  indirect-call-type-mismatch that trapped m3 in the lexer". Someone met
  this before and wrote the guard; the guard is what fails now.
  ▶ THE DEFECT IS TWO NAMESPACES IN ONE FIELD. `LFn` carries a single
  `name`, and the emit spends it on two incompatible things: the
  table-index global, deliberately qualified through
  `spec_closure_name(fn_name)`, and the LOCAL binding, which must match
  the source-level name the capture reads. `captures_self` compares a
  capture's `LLocal(_, nm)` against `fn_name` with `field_name_eq`, so
  once lower qualifies, "go" versus "parse_int_go" answers false, the
  early bind is skipped, and the self-capture reads a zero local. The
  guard is not the only casualty: even firing, `local_wat_name(fn_name,
  RI32)` would bind `$parse_int_go` while the reader reads `$go`.
  ▶ THE STAMP, and its incompleteness is stated rather than papered.
  TRACED: one `name` field read at two sites with opposite requirements,
  diverging exactly when the discriminator starts working. PRICED: a
  representation change — `LFn` carries binding name and emitted symbol
  as separate facts, or qualification moves to emit where both consumers
  already sit — touching every `LFn` construction and destructure.
  WRITERS: lower mints the names; wasm.mn reads them at the closure emit,
  the index global, and `captures_self`. NOT ENUMERATED: the full `LFn`
  site set, which is the next iteration's first move and the reason this
  iteration stops at the stamp rather than building.
  ▶ THE ULTIMATE FORM IS AN IDENTITY COMPARISON. "Is this capture the
  closure being built" is a handle question the graph can answer, and it
  is being answered by comparing two strings drawn from different naming
  schemes — the string-keyed drift the catalog names. `LMakeClosure`'s own
  handle is in scope at the site (destructured as `_h`) and each capture
  carries one; whether those two are comparable is unmeasured, and that
  measurement decides whether the fix is a representation change or a
  one-line read.
  ▶ EIGHT ITERATIONS WITHOUT A src LANDING, named plainly: the row work
  is blocked behind this, and this is now stamped rather than open. The
  loop's own rule applies — never build unstamped — and the stamp is this
  iteration's whole output.

- 2026-08-17 · USE-BEFORE-DEF, PROVEN BY POSITION — AND A NEAR-RETRACTION
  THAT WAS ITSELF THE ERROR (no pin — probe only; boot unchanged at
  6e05bd9404ed).
  ▶ THE MECHANISM IS COMPLETE. `$go` is bound TWICE in m2's `parse_int`
  and ONCE in m3, and the ORDER carries the fault: m2 sets at body line
  19 and first reads at 21; m3 has no set before its first read at line
  20, its only set landing at 32. The local is zero at that read, and
  that zero is the closure the tail call dispatches on — use-before-def
  ending in `indirect call type mismatch`. The full unwindowed diff of
  the body is seven lines: two index-global renames, one comment rename,
  and one PURE DELETION with no counterpart.
  ▶ THE NEAR-RETRACTION, recorded because the recovery is the lesson.
  Mid-iteration a census of `local.set` lines appeared to show the
  binding present in BOTH generations, which would have refuted the whole
  finding, and I began writing the retraction. That census filtered out
  any line containing `state_tmp` — and the dropped line is `(local.set
  $go (local.get $state_tmp))`. The filter excluded exactly the evidence.
  ▶ THREE INSTRUMENTS, TWO OF THEM LYING IN OPPOSITE DIRECTIONS: a
  windowed diff (n=2) showed a deletion and could not prove the absence
  of a counterpart elsewhere; a filtered census showed presence and had
  silently dropped the line; only the unwindowed diff plus the positional
  read were true. The law says measure rather than reason, and this
  iteration adds the corollary — a measurement's FILTER is part of the
  claim, and an instrument that excludes the evidence reads exactly like
  a refutation.
  ▶ NEXT STEP, a BUILD with a precise target: find what drops the FIRST
  binding when a nested fn's name qualifies. The `LLet` emit always
  writes its `local.set`, so the loss is upstream — a lowering or dedup
  decision that treats the binding as redundant once the name changes.
  The allocator arms are not it: they emit `(local.set $<target> (call
  $alloc …))`, and the dropped line binds an already-allocated record.

- 2026-08-17 · THE MECHANISM IS COMPLETE: A DROPPED `local.set`, AND IT IS
  A NAME-KEYED RE-DERIVATION (no pin — probe only; boot unchanged at
  6e05bd9404ed).
  ▶ THE BANKED PROBE READ THE LAST UNREAD PIECE of the 39-line diff:
  `parse_int`'s own body, 72 lines in m2 and 71 in m3. The missing line is
  `(local.set $go (local.get $state_tmp))` — the binding of the freshly
  allocated closure record to the local named after the nested fn — while
  `(local.get $go)` two instructions later SURVIVES. A wasm local defaults
  to zero, so the closure handed to the tail call is a null pointer, its
  fn index is garbage, and `return_call_indirect (type ft3)` mismatches.
  That is the trap, end to end, and it is the first account in this
  sub-arc that actually explains it.
  ▶ THE DEFECT IS THE CARRIED-TRUTH LAW AT THE EMITTER. One nested fn is
  reached through TWO name computations: the table-index global emits
  qualified (`$parse_int_go_idx`), the local binding emits bare (`$go`).
  When the discriminator starts qualifying, the global follows and the
  `local.set` vanishes while its reader does not. The same fact derived
  twice, and the derivations disagree.
  ▶ IT IS LATENT AND HAS NOTHING TO DO WITH ROWS. Any change that makes a
  nested fn's name qualify drops that fn's closure binding. The row arc
  merely tripped it, which is why six explanations about rows, sorts,
  readers, symbols, indices and tables all died first.
  ▶ WHAT THIS COST, stated so the shape is legible: seven probes to reach
  a one-line diff that was inside the first emit-diff report. The report
  said "named wheel fns differing (structural, 3)" on its second line and
  I read the rename list beneath it instead. The instrument was right the
  first time; the reading was not.
  ▶ NEXT STEP IS A BUILD with a precise target: the emit site that writes
  a nested fn's closure `local.set` must read the SAME name the index
  global reads. The allocator arms are not it — they emit `(local.set
  $<target> (call $alloc …))`, and the dropped line binds an
  already-allocated record, so the site is the let-binding path.

- 2026-08-17 · THE NAMES ARE EXONERATED, AND THE READ-PAST HALF OF THE
  DIFF IS THE ONE THAT MATTERS (no pin — probe only; boot unchanged at
  6e05bd9404ed).
  ▶ THE BANKED PROBE HAD TWO BRANCHES AND BOTH DIED. Collision: each
  qualified name is defined exactly once, and the corpus is identical
  across generations — 4832 definitions, 514 names defined more than once,
  both sides. Stale index or reordering: the function table carries 5876
  entries in both and exactly FOUR positions differ (54, 57, 58, 3219),
  each the same function under its old versus new name, with one elem
  segment and 8736 baked `_idx` globals on both sides. Identity did not
  move.
  ▶ THAT REFRAMES THE SUB-ARC. Wasm function names are advisory, so four
  renames cannot by themselves change execution — which means the naming
  I have been chasing for two iterations was never the mechanism. The
  fault has to live in the other half of emit-diff's report, and that half
  was in the output all along: THREE NAMED FNS DIFFER STRUCTURALLY —
  `index_of`, `parse_int` and `op_synth_default_enumerate_inhabitants`,
  the three PARENTS of the renamed children. Their bodies changed.
  ▶ I READ PAST IT because the rename list was the vivid part of the same
  report. Three explanations died this iteration (collision, stale index,
  reordering) and all three were about names; the line naming structural
  divergence sat above them in the output that opened this chain.
  ▶ NEXT PROBE, the last unread piece of a 39-line diff: read those three
  parents' bodies against each other. The trap is a
  `return_call_indirect` inside `parse_int`'s child, so the divergence
  that matters is how the parent builds or passes the closure it
  tail-calls.
  ▶ NO src CHANGE, fifth in a row, same blocker as named last iteration
  and now narrower: the row work waits on an emit divergence in three
  parent functions, and the arc will not build until that divergence is
  read rather than inferred.

- 2026-08-17 · THE TRAP IS PINNED TO ITS INSTRUCTION, AND THE TYPE TABLE
  CLEARS THE SIGNATURES (no pin — probe only; boot unchanged at
  6e05bd9404ed).
  ▶ THE BANKED PROBE RAN: wasm-objdump at the address the backtrace named.
  Inside `parse_int_go`, two indirect calls sit three instructions apart —
  `01225e: call_indirect 0 <fns> (type 2 <ft2>)` and `012267:
  return_call_indirect 3 0`. The TAIL call, through `ft3`, is the one that
  traps, and its callee is a closure record's fn pointer (`local 12`,
  `i32.load offset 0`).
  ▶ THE TYPE VOCABULARY IS IDENTICAL ACROSS GENERATIONS — both carry the
  same 36-entry table, `ft2 = (i32,i32)->i32`, `ft3 = (i32,i32,i32)->i32`.
  That narrows the fault hard: the mismatch is not a changed SIGNATURE but
  a changed TARGET. After the rename, the closure's stored fn index
  resolves to a function of different arity.
  ▶ AN AMBIENT FIND, and the docs paid for it in this very probe: WABT
  1.0.39's `wasm-objdump` accepts NO feature flags — no
  `--enable-tail-call`, no `--enable-threads` — and disassembles
  tail-call-bearing modules fine without them. §8's "EVERY tool needs" is
  true of the assembler and validator and false of objdump at this
  version; the flag turned the first attempt into a two-line "unknown
  option" before it read a single instruction. §8 is trued in place.
  ▶ WHY NO src CHANGE, fourth in a row and named plainly: the row arc is
  BLOCKED BEHIND AN EMITTER DEFECT THAT HAS NOTHING TO DO WITH ROWS. A
  nested function cannot currently be renamed without an indirect call
  resolving to the wrong arity, and every step toward the open-row fix
  passes through such a rename. Each iteration's probe has been the
  loop's mandated first move and each has advanced the pin one layer —
  startup failure, then naming, then instruction, now target-versus-
  signature — but none of them is the fix, and pretending otherwise would
  be the theory-defence the loop forbids.
  ▶ NEXT PROBE: read which fn index that closure stores and what occupies
  it in each generation. The `$fns` table plus the closure's construction
  site answer it, and the answer either names a collision — two nested fns
  qualifying to one name, the documented silent-pick — or a stale index.

- 2026-08-17 · THE TRAP IS PINNED: INDIRECT CALL TYPE MISMATCH AT A
  RENAMED NESTED FN (no pin — probe only; boot unchanged at
  6e05bd9404ed).
  ▶ THE BANKED PROBE RAN AND KILLED ITSELF FIRST. It asked whether a
  definition was renamed while a caller kept the old symbol. It was not:
  both generations DEFINE both naming forms, and the annotation shifts
  exactly one fn from bare to qualified — m2 carries two `digit*`
  definitions and one `parse_int_digit*`, m3 the mirror. The earlier
  "defs=0, callrefs=1" was an artifact of a trailing-space pattern, and
  the dangling-symbol reading died with it. Fifth explanation this arc has
  killed by measuring rather than reasoning.
  ▶ THEN THE INSTRUMENT CHANGED KIND, which is what finally answered.
  Reading the WAT had reached its limit, so the artifact was RUN: m3.wasm
  fed the wheel's own source (2645362 bytes in, zero out, exit 134)
  reproduces the failure by hand, with a backtrace. `wasm trap: indirect
  call type mismatch`, innermost frame `parse_int_go`, reached through
  `lex_from` → `lex` → `infer_program_converged` → `compile_stdin_run`.
  ▶ SO THE FAULT IS INDIRECT DISPATCH AT THE RENAMED NESTED FN — not
  rows, not symbols, not readers. A nested function's NAME is reaching its
  `call_indirect` identity, which is the emitter's known hazard family
  ("dup top-level fn names — the emitter picks one silently") with a new
  trigger: a rename changing which definition an indirect call resolves
  to.
  ▶ THE ARC IS NOW THREE STEPS, not two. The indirect-dispatch fault sits
  upstream of the discriminator fix, which sits upstream of the writer
  flip. Nothing about the row tail can land until a nested fn can be
  renamed without breaking dispatch — and that ordering was invisible
  until the artifact was run instead of read.
  ▶ NEXT PROBE is the prescribed one: `wasm-objdump -d` at the trapping
  address, reading the `call_indirect` and the type it expected against
  the type it got. The address is in the captured backtrace.

- 2026-08-17 · THE ANNOTATION SURFACES A SECOND SILENT WRONG, AND THE
  MARCH STILL REFUSES (no pin — experiment reverted whole; boot unchanged
  at 6e05bd9404ed).
  ▶ THE NAMED STEP WAS BUILT. Both exposed receivers took the frame
  record's whole eight-field annotation, every field type measured off
  `ls_enter_frame`'s declared signature rather than guessed, and the
  projection confirms the row closes with no tail.
  ▶ BROKEN, BUT WITH A NEW SIGNATURE: 39 diff lines against the linked
  tail's 131497, and m4 dead in 0.97s at 128MB against its ~10s. A
  39-line divergence is small enough to READ, which is the first time
  this arc could pin one exactly.
  ▶ EVERY ONE OF THE 39 IS NESTED-FUNCTION NAMING. m2 emits `digit`,
  `go`, `search`, `yield_from` bare; m3 emits `parse_int_digit`,
  `parse_int_go`, `index_of_search` and
  `op_synth_default_enumerate_inhabitants_yield_from` qualified; the three
  structurally-differing named fns are exactly those four's parents.
  Nothing else in 4835 functions moved.
  ▶ SO THE DISCRIMINATOR HAS BEEN WRONG ALL ALONG.
  `ls_outer_fn_name_loop`'s own comment calls it the named-fn
  discriminator for nested-fn naming; reading `frame.fn_name` through an
  open row handed it a foreign slot, so nested fns have never been
  qualified and the qualification path has been dormant. A defect in its
  own right, surfaced by the annotation, independent of the tail arc.
  ▶ ONE HYPOTHESIS DIED BEFORE IT WAS BANKED: that qualified names
  collide with existing symbols. Duplicate-symbol counts are identical
  between generations — 514 and 514 — so qualification introduced none.
  Checking it cost one grep over artifacts already on disk, and it is the
  fourth explanation this arc has killed by measuring instead of
  reasoning.
  ▶ THE TRAP'S CAUSE REMAINS UNMEASURED, said plainly. Why a module whose
  only change is four qualified nested-fn names fails at startup is not
  known. The next probe is cheap because the diff is 39 lines: read those
  four functions' call sites against their definitions, since a renamed
  definition with a stale caller assembles and fails at the first call,
  which fits a 0.97s death better than anything about rows.
  ▶ THE PATH NOW HAS TWO STEPS instead of one: fix the discriminator's own
  defect first — it is real, small and separately gated — then re-attempt
  the writer flip.

- 2026-08-17 · THE BREAK IS MEASURED: THE LINKED TAIL IS HONEST AND THE
  WHEEL CANNOT AFFORD IT YET (no pin — measurement on the reverted run's
  own artifacts; boot unchanged at 6e05bd9404ed).
  ▶ THE INSTRUMENT THE ARC HAD NEVER USED. CLAUDE.md prescribes
  `emit-diff` FIRST on any trap, and the broken run's artifacts survived
  it: m2 13937263 bytes, m3 13937259, m4 ZERO — the empty that proves the
  trap. `--trap` was noise, as the docs warn (bare exhaustive-match elses
  are benign), so the marked-floor census answered instead.
  ▶ ONE CLASS DIFFERS, AND IT IS THE WHOLE DELTA. `field offset
  unprovable`: 4 in m2, 9 in m3. Total unreachables 4286 → 4291. Every
  other floor class is identical between the generations.
  ▶ SO THE LINKED FORM WORKS AS DESIGNED — that is what breaks the wheel.
  The chase reaches a free tail and floors honestly at five more sites,
  and those sites are the WHEEL's own, so the compiler m3 emits traps when
  it compiles the wheel. The empty-bind was papering them over with a
  guessed offset that happened to be right for the wheel's own shapes,
  which is exactly why the wheel self-hosted while user code read foreign
  fields.
  ▶ THE FIVE ARE NAMED: `ls_current_lambda_handle_loop` (3) and
  `ls_outer_fn_name_loop` (2), both lower.mn, both taking an unannotated
  `frames` and reading `frame.fn_name` / `frame.lambda_h`. m2's four
  pre-existing floors are unchanged and unrelated.
  ▶ THAT REFUTES THE DIRECTION I BANKED LAST ITERATION — that some reader
  must follow the tail and does not. No reader needed to; they were fine.
  Third dead explanation in this arc, and the one that would have sent a
  fix into occurs and subst. The measurement cost one grep over artifacts
  that were already on disk.
  ▶ THE PATH IS CONCRETE AND SMALL: give those two receivers a provable
  type, exactly as the two record-PATTERN receivers were closed at pin
  f0b63b15a5d6, then re-attempt the writer flip. The frame record has
  eight fields and three construction sites, so the honest close is ONE
  named type both params share — the structural record already exists, it
  simply has no name.

- 2026-08-17 · THE LINKED TAIL BREAKS IN THE ROW SORT TOO — MY OWN CAUSE
  REFUTED (no pin — experiment reverted whole; boot unchanged at
  6e05bd9404ed, the vocabulary pin stands).
  ▶ THE STAMP'S DEBT WAS PAID and the answer is a kill. Last iteration
  landed the tail slot as vocabulary and named the writer flip as this
  iteration's work. It went in exactly as designed: the op carries
  `Option(Int)`, the terminating call site passes `None` where the other
  side is CLOSED (the one case where None is a proof rather than an
  assumption), the tail gets its own occurs guard at the row sort, and
  `unify_two_open_records` mints one shared fresh tail for both vars.
  ▶ BROKEN, WITH THE SAME SIGNATURE AS THE SORT-CROSSING ATTEMPT: 131497
  diff lines against that attempt's 131477, m3 clean both times (exit 0,
  census 0), m4 trapping both times at exit 134 with zero lines.
  ▶ THAT REFUTES THE CAUSE I BANKED. The first break was recorded here as
  the untagged-union hazard — `graph_bind` putting a Ty onto a row handle,
  the thing `graph_bind_record_row`'s comment was written to prevent. This
  attempt never left the row sort and failed identically, so the cause is
  the SEMANTIC change (linking the tails), not how the link is stored. I
  wrote that explanation with the artifact's own comment as support and it
  was still wrong; the comment explained a DIFFERENT past failure, and
  reading it as this one's cause was the fluency trap the loop names.
  ▶ WHAT IS NOW MEASURED, and it is the useful residue: the linked form
  produces a compiler that is itself clean and then mis-compiles the wheel
  one generation on. A self-application failure, invisible before the m4
  leg — which is why the previous entry's instruction to watch that leg
  from the first run was right even though its reasoning was not.
  ▶ THE NAMED NEXT PROBE, stated as a direction rather than a cause: every
  reader except `open_record_full_fields` takes the tail as `_` — occurs,
  resolve, subst, the renderers. CLAUDE.md's law is that the walks over
  one structure must AGREE, and a chain one walk chases while another
  ignores it is that disagreement. It is unmeasured. Two dead explanations
  in this arc are what skipping that distinction costs.

- 2026-08-17 · pin 6e05bd9404ed · THE ROW RESIDUAL GROWS ITS TAIL, AS
  VOCABULARY. CLEAN, m2 == m3, census 0, frontier 371/0, 16.91s wall ·
  2270116 KB peak.
  ▶ WHAT LANDED. `NRecordRowBound([(String, Ty)])` becomes
  `NRecordRowBound([(String, Ty)], Option(Int))`: `None` terminates the
  chain — these fields and no more — and `Some(v)` continues it at another
  row var whose residual is not yet known. Every writer passes `None`
  today, so the pin is behaviour-identical, confirmed by re-running the
  arc's repro unchanged at 7. `open_record_full_fields` gained its chase
  arm for the linked case, which reaches a still-free tail and floors, so
  the reader is ready before the writer exists.
  ▶ WHY AN ARITY CHANGE AND NOT A NEW NODE KIND. The previous attempt died
  because a row walk's catch-all silently crossed a sort boundary; a new
  kind would be found only where matches are exhaustive, and a catch-all
  is exactly where it would not. An arity change is a compile error at
  EVERY site — twenty-one of them, across eight files — so the enumeration
  is the compiler's rather than mine. That property is the whole reason
  this shape was chosen over the one the reader's existing
  `NBound(TRecordOpen(...))` arm seemed to invite.
  ▶ THE STAMP THIS PAYS. `unify_two_open_records` closes both tails to the
  other side's exclusive fields, which reads as "and nothing further" and
  is what bakes a field offset over a partial set. The repair is to LINK
  the tails, and the constraint the march imposed last iteration is that
  the link must live in the ROW SORT. This slot is that vocabulary. The
  writer flip is the next step and is a TRANSITION by construction — the
  refuted attempt measured 131477 diff lines for the same semantic change,
  so the m4 leg matters from the first run.
  ▶ WHAT IS NOT YET TRUE, said plainly: nothing reads `Some` yet, so the
  silent wrong is untouched. `fn pick(u: {zeta: Int, ...}) = u.zeta` over
  `{alpha: 7, zeta: 9}` still answers 7. The vocabulary is the floor the
  fix stands on, not the fix.

- 2026-08-17 · THE WRITER IS FOUND, AND THE OBVIOUS REPAIR IS BROKEN (no
  pin — experiment reverted whole; boot unchanged at 4ce9914b7360).
  ▶ THE BANKED PROBE ASKED which writer leaves the body's row var bound to
  empty. It is `unify_two_open_records`. When two open records with
  DISTINCT row vars unify, it computes each side's exclusive fields and
  binds each var to the OTHER's — so when both sides know the same fields,
  both extras are empty and both tails close to `[]`. Two open rows
  unifying learn that their known fields agree and that their remainders
  are the same unknown; they never learn there is no remainder. The
  function's own comment says tails "collapse to one when they're already
  linked", and its `va == vb` arm does exactly that — the `va != vb` arm
  closes instead. It predicts every number this arc measured: 7, 2, and
  15, including the two-known-field case where the annotation's var takes
  `diff(body, annotation) = []`.
  ▶ THE TEXTBOOK REPAIR WENT IN AND THE MARCH REFUSED IT. One shared fresh
  tail, `va := TRecordOpen(extra_b, tail)` and `vb := TRecordOpen(extra_a,
  tail)` — and `open_record_full_fields` already chases `NBound(
  TRecordOpen(more, v2))`, so the reader was written for this shape.
  Verdict BROKEN: m2 ≠ m3 by 131477 lines, then m4 trapped at exit 134
  with zero lines. The medium stopped reproducing itself. Reverted whole.
  ▶ THE ARTIFACT HAD ALREADY RECORDED WHY, in the very op the change went
  around. `graph_bind_record_row`'s comment: the residual lives "under its
  OWN node kind (NRecordRowBound)" because "binding residuals under
  NRowBound made the row slot an untagged EffRow-or-Ty union every row
  walk's catch-all silently crossed." Binding a row handle to a Ty through
  `graph_bind` is that untagged union by another door. I read that comment
  this turn while locating the op and did not weigh it against the edit —
  the ambient charge names exactly this, and the march charged for it.
  ▶ WHAT SURVIVES, and it is the useful half: the fix's SHAPE is right —
  link the tails, do not close them — and its REPRESENTATION is now
  constrained. A linked tail wants vocabulary inside the row sort:
  residual fields plus an unknown-remainder marker in `NRecordRowBound`,
  or its own node kind. Never a Ty bound onto a row handle. The reader's
  existing `NBound(TRecordOpen(...))` arm is not the invitation it looks
  like; it is a shape some other path produces, and using it from here
  crosses the sort boundary that comment was written to defend.
  ▶ 131477 DIFF LINES is its own measurement: open-record unification with
  distinct vars is not a corner of the wheel. Whatever lands here changes
  a great deal of emit, so it is a TRANSITION by construction and wants
  the m4 leg watched from the first attempt.

- 2026-08-17 · THE FLOOR IS BYPASSED, NOT MISSING — AN EMPTY RESIDUAL
  BIND (no pin — docs; boot unchanged at 4ce9914b7360).
  ▶ THE BANKED PROBE asked which branch the annotated-open case takes,
  since the inferred-open case floors. The answer inverts the framing: the
  refusal machinery is already correct and is being BYPASSED.
  `resolve_field_offset`'s `TRecordOpen(fields, v)` arm asks
  `open_record_full_fields(fields, v)` for the receiver's full sorted set
  and returns -1 when the chase cannot answer — its comment naming this
  exact class, "an offset prefix-summed over the partial demanded set is
  the wrong-slot class ... must floor loudly, never return a partial sum."
  The chase SUCCEEDS: `v` resolves to an EMPTY residual, so the full set
  is the known set alone and a real offset comes back. A genuinely free
  var would hit `_ => None` and trap; the empty bind is what turns a loud
  refusal into a silent wrong.
  ▶ CALL-SITE INDEPENDENT, which is the fork's concrete face.
  `fn pick(u: {zeta: Int, ...}) = u.zeta` called twice in one program —
  `pick({alpha: 1, zeta: 3}) * 10 + pick({zeta: 5})` — answers 15: the
  first call reads slot 0 and gets `alpha`, the second reads slot 0 and
  gets `zeta`. One compiled body, one baked offset, right only for callers
  whose record carries exactly the known fields. The arithmetic pins with
  a third shape: `{beta: Int, zeta: Int, ...}` over `{alpha: 1, beta: 2,
  zeta: 3}` answers 2 — `zeta` at index 1 of the KNOWN pair.
  ▶ THE PER-CALL-SITE BIND EXISTS AND MISSES THE BODY.
  `unify_record_open_against_closed` computes `record_fields_diff(closed,
  open)` and binds the open var to it — `[alpha]` for the first call
  above, the right residual. The body's var is not that one. Which writer
  leaves the body's var bound to EMPTY is the last unmeasured link and the
  named next probe.
  ▶ NO SRC CHANGE, fourth in a row, and the blocker is now demonstrated
  rather than argued: one compiled body cannot carry a per-caller layout,
  so the repair is per-call-site specialization or a runtime layout
  carrier — the standing fork — and the floor route was refuted by the
  march two iterations back.
  ▶ SELF-BUILD RATCHET, banked as `Hβ.query.field-offset-badge`: every
  probe in this arc inferred a resolved offset from an exit code, because
  `mentl where` renders repr width, resume cardinality and fanout schedule
  but not the offset a field access resolved to nor whether the full field
  set was provable. Both are facts `resolve_field_offset` already
  computes. Under that badge this entire arc is one query.

- 2026-08-17 · THE ROOT, AND IT LANDS ON SYNTAX'S OWN WORKED EXAMPLE (no
  pin — tests and docs; boot unchanged at 4ce9914b7360).
  ▶ THE BANKED SEPARATING PROBE RAN FIRST and killed the name it was
  banked under. One program holding both a closed and an open record with
  the same known fields answers `closed correct, open wrong` side by side
  — a shared generated helper would have forced ONE answer for both, so
  `fold_sig`'s TRecord/TRecordOpen collapse is not the mechanism. The eq
  leaf simply walks the KNOWN field list.
  ▶ THAT POINTED AT THE ROOT, and it is worse than the eq face. An open
  row's field OFFSETS are computed from the known set's own ordering
  rather than the runtime record's. `fn pick(u: {zeta: Int, ...}) =
  u.zeta` over `{alpha: 7, zeta: 9}` returns 7: `zeta` is the only known
  field, so it takes index 0, which the real record uses for `alpha`.
  Silent — no diagnostic, no trap, check passes at exit 0. The closed twin
  returns 9.
  ▶ IT IS SYNTAX'S OWN EXAMPLE. §«Row polymorphism» offers `fn greet(u:
  {name: String, ...}) = "Hello, " ++ u.name` as the feature's worked
  form. Measured in that exact shape: `fn width(u: {name: Int, ...}) =
  u.name + 1` over `{name: 5, age: 9}` returns 10, which is `age + 1`,
  because `age` sorts first in the record while `name` is index 0 of the
  known set. A headline documented surface reads a foreign field.
  ▶ ONE RULE, FOUR CONSUMERS. The pattern takes offsets from the pattern's
  own index; `==` walks the known field list; field access takes the known
  set's index; `LFieldLoad` floors loudly, but only where offset
  resolution returns -1, which is why the INFERRED-open case traps and the
  ANNOTATED-open case silently misreads. That split is measured, not
  explained — the annotation supplies known fields where inference left
  none — and tracing which branch each site takes is the next probe.
  ▶ NO SRC CHANGE, and the blocker is structural rather than scheduling:
  the offsets must be RESOLVED, since the march already refuted the
  blanket floor (`fn g({x, y})` became a trap), and resolving requires the
  receiver's real layout to reach the consumer — the standing fork.
  ▶ LANDED: `tests/syntax/record-field-param-closed` (contract 9, the
  control that made the finding precise), battery at five; SYNTAX's
  row-polymorphism section now records the measured gap beneath its
  example, because a reader would otherwise trust it. SYNTAX stays the
  authority — the lathe has not been turned to it.

- 2026-08-17 · THE OPEN ROW'S THIRD CONSUMER, AND IT ANSWERS WRONG
  SILENTLY (no pin — tests and docs; boot unchanged at 4ce9914b7360).
  ▶ THE BANKED PROBE, re-aimed as its entry prescribed — a comparison
  reached without any field access — and it CONFIRMS the hypothesis the
  first attempt could not reach. `fn same(a: {x: Int, ...}, b: {x: Int,
  ...}) = a == b` over `{x: 1, y: 2}` and `{x: 1, y: 3}` answers TRUE. The
  records differ in `y`; the comparison walks only the fields the type
  knows. Replace the two `...` with `y: Int`, change nothing else, and the
  same call answers FALSE. `mentl check` passes the open form at exit 0.
  ▶ THREE CONSUMERS, THREE ANSWERS, ONE QUESTION. The medium does not know
  a `TRecordOpen` value's layout, and its consumers disagree about what to
  do: `LFieldLoad` floors loudly with `;; field offset unprovable`; the
  record PATTERN fabricates offsets from its own index and reads a foreign
  slot; `==` under-compares and reports equal. Only the first is honest.
  That spread is the case for one pass over layout-unknown values instead
  of per-consumer repair — and yesterday's march already proved the
  per-consumer floor cannot be that pass, because it turns `fn g({x, y})`
  into a trap.
  ▶ IT BREAKS EQ'S CONTRACT, not merely a corner: two distinguishable
  records comparing equal is the eq/hash divergence §5.U says the total
  structural derivation exists to make unsayable, and SYNTAX's equality
  table says "field-wise recursion over the sorted field set".
  ▶ WHAT IS STILL UNSEPARATED, stated so it is not later read as settled:
  a shared `fold_sig` between `TRecord` and `TRecordOpen` would produce
  this, and so would an eq leaf that walks the known field list. This
  probe cannot distinguish them. The separating probe holds both a closed
  and an open record with the same known fields and asks whether one
  generated helper serves both.
  ▶ LANDED: `tests/syntax/record-eq-closed`, the green half, contract 7 so
  a wrong answer exits 1 and a right one exits 7. The battery is four
  fixtures. The open twin waits with the fix rather than banking a wrong
  value as an expectation.
  ▶ NO SRC CHANGE, and the reason is structural: every repair here needs
  the receiver's layout to reach the consumer, which is the standing fork
  (specialize per call site, or carry the layout at runtime) — and the
  third option, refusing, was measured dead one iteration ago.

- 2026-08-17 · THE MARCH REFUTED THE FLOOR, AND THE REFUTATION REMOVES AN
  OPTION FROM THE FORK (no pin — experiment reverted whole; boot unchanged
  at 4ce9914b7360, wheel source restored).
  ▶ THE BANKED PROBE RAN FIRST and killed its own hypothesis. The
  `fold_sig` entry predicted that an open and a closed record sharing a
  signature would make `==` compare only the known fields. The fixture
  never reaches the comparison: `a.x` on an open-row parameter floors at
  `(unreachable) ;; field offset unprovable`, the field LOAD answering
  before the eq leaf. Read from the emitted WAT (4132 bytes, two
  unreachables, one marked). The shared-signature question is still open
  and needs a probe that reaches a comparison without a field access.
  ▶ WHAT THE PROBE DID ESTABLISH: `mentl check` passes that fixture at
  exit 0 and the executable traps. A MARKED emit floor in reachable code
  does not refuse the executable — the gate reads errors, holes and armed
  classes, and an emit floor is none of those.
  ▶ THE EXPERIMENT the finding suggested. `LFieldLoad` and the
  record-pattern lowering face one question — the offset is not provable —
  and answer differently. The load floors with the marker and its comment
  states the law ("NO SILENT FALLBACK ... the named wrong — not a
  fabricated offset-0 load that reads a foreign field"); the pattern
  fabricates `(base + i) * 4` from its own index. Making the pattern
  answer as its sibling does looked unambiguous, with zero blast radius
  since the open-receiver ratchet holds the wheel at 0.
  ▶ THE MARCH REFUSED THE REPIN. Fixed point held (m2 == m3, census 0,
  412873 lines) and the battery caught `mn-fn-tuple-param`: RUN exit=134
  want=44. Its `fn g({x, y}) = x * y` over `{x: 5, y: 6}` is a
  DESTRUCTURING PARAMETER — an open-row receiver by construction — and
  7 + 30 + 7 = 44 re-derived by hand before touching anything. The
  expectation is right and the program is right; the floor turned working
  idiomatic code into a trap. §9.11 asks whether an old gate going red
  canonized a bug, and here it did not: SYNTAX gives `({name, age}) =>
  greet(name)` as one of its own examples.
  ▶ WHAT IT PROVES, and it is worth more than the change would have been:
  a destructuring parameter is THE common case of the open-row receiver,
  so refusing on "offset unprovable" is not a conservative interim — it
  deletes a documented surface. The offsets must be RESOLVED, which means
  the receiver's layout must reach the pattern: specialization per call
  site, or a layout the value carries. The third option everyone reaches
  for first is now measured dead, and the fork is sharper for it.
  ▶ THE SILENT HALF IS UNCHANGED: a partial pattern over an open receiver
  still reads the wrong field with no diagnostic, and the medium cannot
  tell it from `fn g({x, y})`. That indistinguishability is precisely why
  a blanket floor cannot separate them.

- 2026-08-17 · pin 4ce9914b7360 · THE OPEN-RECEIVER RATCHET, AND A SECOND
  GATE THAT COULD NOT FAIL CAUGHT BEFORE IT LANDED. CLEAN, m2 == m3,
  census 0, 16.56s wall · 2271808 KB peak.
  ▶ WHAT IT MEASURES. `CsRecordPatternOpen` filters the record-pattern
  sites by the receiver's JUDGED type: open (`TRecordOpen`) means
  lowering has no full sorted field set and takes offsets from the
  pattern's own index. The read composes two existing homes and invents
  nothing — `graph_chase` resolves the receiver handle through the
  union-find, so a TVar needs no separate walk, and `fold_strip` is
  types.mn's own alias / refinement / repr-pin peel, the file's declared
  Carried-Truth home for a property OF THE TYPE.
  ▶ THE KILL, and it is the iteration's most useful output. The shape's
  first draft filtered only `LetStmt` sites. It marched, and answered 0
  for the wheel — which read as confirmation that the previous pin's
  annotations had worked. The falsification refused that: removing one
  annotation left the count at 0. Both of the wheel's record-pattern
  sites are MATCH arms, not let bindings, so the shape was blind to
  exactly what it was built to count, and its zero meant nothing. The
  comment justifying the omission — that an arm's scrutinee is out of
  reach — was also wrong: `MatchExpr` carries the scrutinee node, handle
  and all. This is the second toothless gate this session caught by
  falsifying rather than by review, after the syntax battery's first
  draft.
  ▶ THE CORRECTED SHAPE IS DISCRIMINATING, measured both ways: 0 with
  both receivers annotated, and 1 with `backends/wasm:1100` LOCATED when
  one annotation is removed. `record_pattern_open_max: 0` in
  verify-baseline holds it, and the ceiling is a contract rather than a
  tolerance — a rise means a receiver whose offsets are guessed.
  ▶ WHY ZERO IS THE RIGHT CEILING. A complete pattern over an open row
  and a partial one are structurally identical to the medium, so no
  discipline at the site distinguishes safe from unsafe. Annotating the
  receiver is the only move that turns the offsets into a proof, and the
  ratchet is what keeps the wheel from silently reacquiring the exposure
  the previous pin closed.
  ▶ AMBIENT FIND, banked not asserted: `fold_sig` (types.mn) maps
  `TRecord` and `TRecordOpen` to the SAME signature string, so an open
  and a closed record with the same known fields share generated
  eq/hash/show helpers. Whether that is wrong depends on what the shared
  helper does with the fields an open record carries beyond the known
  set, which is not measured. Named as
  `Hβ.fold.open-record-shares-closed-signature`.

- 2026-08-17 · pin f0b63b15a5d6 · THE WHEEL'S RECORD DESTRUCTURES STOP
  RESTING ON A PROMISE — and the previous entry's "accident" is RETRACTED
  as the wrong word for a sharper defect. CLEAN, m2 == m3, census 0,
  frontier 371/0, 17.30s wall · 2257136 KB peak; emit 412596 → 412421
  lines.
  ▶ THE RETRACTION FIRST. Yesterday's entry called pipeline:424 "correct
  by accident." The site's own comment refutes that: it destructures ALL
  three fields deliberately, and says why — "CLOSED destructure — an
  open-receiver field read computes offsets over the partial field set
  (the trecordopen-wrong-field class); the full pattern pins the record's
  real layout." The second site (`{arms: _, ename: en}`) follows the same
  discipline. Neither was an accident; both were a documented practice,
  and the class already had the wheel's own name for it.
  ▶ BUT THE PRACTICE DOES NOT HOLD, which is the sharper finding. A
  complete pattern over an open row and a PARTIAL one are structurally
  IDENTICAL to the medium: in both cases the receiver's judged type is
  exactly the pattern's own fields plus an open tail. The failing repro
  projects `{ zeta: t39682@e0 | r39684@e2 }`; pipeline's site projected
  `{ args: …, body: …, op_name: String | r367192@e17 }`. Same shape. So
  "the full pattern pins the layout" was an author's promise the graph
  could not check, and nothing distinguished a safe site from an unsafe
  one. A caller passing a record with one extra field sorting before
  `args` would have read the wrong slot, silently.
  ▶ WHAT LANDED: both receivers are ANNOTATED with the record types
  types.mn already declares — `[{args: [String], body: Node, op_name:
  String}]` and `[{arms: [String], ename: String}]`. The rows close, and
  the medium says so: the same projection that showed the open tail now
  reads `{ args: List(String), body: Node, op_name: String }`. Offsets
  resolve from the receiver's full sorted field set, so they are a proof.
  The types existed all along at their declarations; only the parameters
  were unannotated, which is exactly the Intent Boundary SYNTAX reserves
  annotations for.
  ▶ MEASURED CONSEQUENCE: emit fell 175 lines and peak RSS fell ~17MB.
  Resolving real offsets is not only sounder, it is less code — the shape
  a Carried-Truth fix is supposed to have.
  ▶ WHAT REMAINS is the class, not these two sites:
  `Hβ.lower.record-pattern-param-receiver`. Any unannotated record
  parameter still guesses, and the guess is still silent while its rest
  half traps. The fix's ultimate form stays the open fork — type-keyed
  twinning versus a runtime layout carrier — but the wheel no longer
  depends on the answer.

- 2026-08-17 · pin e06c6658fc20 · THE BANKED PROBE RAN, AND IT FOUND THE
  WHEEL STANDING ON AN ACCIDENT. CLEAN, m2 == m3, census 0, frontier
  371/0, 16.18s wall · 2274684 KB peak.
  ▶ THE PROBE the previous entry banked — how a record pattern resolves
  its field offset through a parameter receiver — answered at the
  definition and then at the artifact. `lower_pat_typed`'s PRecord arm
  asks `record_pat_full_fields(ty)` for the receiver's FULL sorted field
  set. Resolved, each named field takes its true offset. Unresolved, the
  fallback is `lower_pat_record_fields(flds, 0)`, which computes
  `(base + i) * 4` from the PATTERN's own enumeration index — correct
  only when the pattern names the first k fields of the full set in
  sorted order.
  ▶ THE RECEIVER IS GENUINELY POLYMORPHIC, so this is not a fact read too
  late. The medium projects the parameter as `{ zeta: t39682@e0 |
  r39684@e2 }` — an open row, whose remaining fields the CALLER decides.
  With an open row those extra fields may sort before or after the named
  one, so the offsets are unknowable at lowering and any value they take
  is a guess. `record_pat_full_fields` returns None correctly; the
  fallback is what invents.
  ▶ ONE BRANCH, TWO HONESTIES. The rest half of that same fallback
  (`lower_rest_unresolved`) carries empty specs so emit fires its loud
  floor — the trap measured yesterday. The field half fabricates an
  index and returns a wrong value with no diagnostic. That asymmetry is
  the finding: the design already decided unresolved means unknown, and
  only one of its two halves says so.
  ▶ THE WHEEL IS EXPOSED, and correct by accident. The new census counts
  2 record patterns on its own link (`backends/wasm:1096`,
  `pipeline:424`), and the site projects its receiver as `{ args: …,
  body: …, op_name: String | r367192@e17 }` — open. Its three sorted
  names are slots 0 through 2, so the fabricated indices land right. That
  is forensic law 5 exactly: an invariant held by accident is a bug the
  first new capability exposes, and naming the accident is the first half
  of making it a contract.
  ▶ WHAT LANDED: `CsRecordPattern`, the census's second declared-surface
  shape, reading both spellings where the pattern lives — a let binding's
  own pattern and a match arm's. It replaces the grep that priced this
  fix and answers with LOCATED sites, which is how the exposure above was
  found at all. Seen RED first against the standing boot.
  ▶ WHY NO FIX YET, stated plainly: the ultimate form is a fork already
  open elsewhere. Either record twinning becomes TYPE-keyed so each call
  site specializes its receiver's layout (5.1's repr-keyed monomorphization
  cannot, since every record is one word), or the layout travels with the
  value at runtime. That is the same shape as
  `Hβ.value.seq-element-stride-carrier`, where a generic body compiles
  once with a TVar element and reads at the wrong stride; this is that
  class at the RECORD, and naming the second instance is what the census
  law asks for before designing the pass.

- 2026-08-17 · PHASE 0.4 WAS NEVER BUILT, AND ITS FIRST SWEEP FOUND TWO
  DEFECTS NOTHING ELSE CAN SEE (no pin — tools, tests and docs; boot
  unchanged at a6e900f35888).
  ▶ THE FIND, measured three ways before it was written down: `tests/syntax/`
  had no history under any ref (`--diff-filter=A` across all refs is
  empty), no gate in tools/ named it, and exactly one doc line mentioned
  it — inside a phase marked ✅ COMPLETE, pointing at a LEDGER that has no
  entry for it. The 27-fixture SYNTAX run behind §11 tripwire 3 was a
  one-off whose fixtures never landed. That is why its eight findings had
  to be rediscovered by hand, and why the plan's named counter-measure
  for the oracle-blind class did not exist while three iterations probed
  that class manually.
  ▶ THE BATTERY IS THE MEDIUM'S OWN VERB. `mentl test <dir>` already reads
  each fixture's `// expect:` header, so 0.4 needed fixtures and a verify
  leg, not a new script.
  ▶ THE LEG WAS BUILT WRONG FIRST AND THE RED CHECK CAUGHT IT. Its first
  draft read `mentl test` alone, and passed against a deliberately
  falsified expectation — because that verb reports the DECLARED value
  beside the WAT and judges the compile side only; it does not execute.
  A gate that cannot fail is the exact class Law 11 exists for, and this
  one was caught by the falsification rather than by review. It runs each
  fixture through run-micro.sh now, and the falsified contract fails with
  `exit=12 expected=11`.
  ▶ TWO DEFECTS, each isolated to one variable, both on surfaces the wheel
  never writes: a record pattern whose receiver is a FUNCTION PARAMETER
  reads the wrong field SILENTLY (`{zeta}` over `{alpha: 7, zeta: 9}`
  answers 7; the same pattern over a local receiver answers 9), and the
  rest binding TRAPS through a parameter even when the residual is never
  read while the same body over a local receiver answers 12. Separately,
  an as-pattern defeats exhaustiveness — a match covering both variants
  of a two-variant ADT is refused `E_PatternInexhaustive`, and deleting
  the binder alone runs clean.
  ▶ A THEORY DIED ON THE WAY. The first reading of the field defect was
  "record patterns bind by position," which the very next probe refuted:
  `{zeta}` over `{alpha: 7, zeta: 9}` answers 9 as a local, and a
  positional read would have answered 7. The parameter receiver is the
  real variable, and the wrong theory would have sent a fix into the
  record layout instead.
  ▶ WHAT LANDED GREEN: three fixtures whose contracts are measured —
  labeled arguments fully labeled (14), the record pattern over a local
  receiver (9), field access through a parameter (12). The last two are
  the controls that made the finding precise, kept as contracts. The red
  repros are held back with their peers, per the convention this session
  has used all along: a fixture never banks a wrong value as an
  expectation (§9.11's nine payload micros).

- 2026-08-17 · pin a6e900f35888 · THE CENSUS GROWS ITS FIRST
  DECLARED-SURFACE SHAPE. CLEAN, m2 == m3, census 0, frontier 371/0,
  16.66s wall · 2277312 KB peak.
  ▶ WHAT IT IS, and why it is a different KIND of shape. The fourteen
  shapes before it ask what the source DOES — a drift silhouette, a
  judged row, a verb glyph. `default-param` asks whether a form SYNTAX
  DECLARES is written here at all. That is the question every
  oracle-blind probe opens with (§11 tripwire 3: the board is green on
  what the wheel does and silent on everything else), and yesterday it
  could only be answered from outside the medium — the previous entry's
  own measurement took two greps behind two `# mentl-skip` confessions,
  one for the count and one to prove the file set non-empty so the zero
  was a verdict.
  ▶ IT READS THE CARRIER THE GRAPH ALREADY HOLDS. A default is `TParam`
  slot 4, an `Option(Node)` the parser fills at the declaration, so the
  detector is `NStmt(FnStmt(_, params, _, _, _))` with `param_default`
  read per param — a chase to a proven fact, never a re-derivation from
  source text. No new graph state and no writer added; the census stays
  a read, and the walk was already O(nodes).
  ▶ MEASURED, and it CONFIRMS yesterday's grep independently: the census
  facet run against the wheel's own entry answers `0 default-valued
  parameter(s)` over the judged weave. The wheel writes no
  default-valued parameter, now established by the medium about itself
  rather than by a regex about its text.
  ▶ SEEN RED FIRST, properly: the frontier leg was added before the
  shape existed and failed against the standing boot — "census
  'default-param' misses its own site (line 39)" — then passed against
  the new pin, with the fixture line read back from the artifact rather
  than counted.
  ▶ THE SIBLINGS STAY SEPARATE ARMS ON PURPOSE. Labeled arguments,
  as-patterns, record rest and named row aliases are the surfaces worth
  the same treatment, and each reads its OWN carrier — so each is one
  more variant, not a generalized surface parameter. They are real
  leaves of one walk, the distinction the fold's four leaf generators
  already record.
  ▶ CLOSES `Hβ.query.default-param-census`, banked one iteration ago.
  The confession named the missing projection; the projection exists.

- 2026-08-17 · THE DEFAULT PARAMETER IS A CARRIER, AND IT WAS THE ONE THE
  BOARD COULD NOT SEE (no pin — tests only; boot unchanged at
  5446b82bddd4, wheel source untouched). Crown 48 → 50, both legs green.
  ▶ THE RULE. A default is not a call-site convenience. SYNTAX desugars
  it once at the declaration into a callee-scoped fill evaluated in the
  CALLEE's parameter scope, so the default's row IS the callee's row —
  and a caller under `with !E` must meet it even though the call site
  mentions neither the parameter nor the effect. Measured in all three
  shapes before either fixture landed: a direct effectful default
  refuses (`!E + Any vs E`), a closure default that is CALLED refuses,
  and a closure default never called ACCEPTS. That is the same
  latent-versus-performed split the field, list, tuple, variant, state
  and partial carriers already pin, now at the carrier none of them
  reached.
  ▶ WHY IT IS WORTH A CRUCIBLE: the wheel writes no default-valued
  parameter at all — 0 across 29 src modules against 2079 fn
  declarations by the same grep engine, so the zero is a verdict and not
  an empty read. Fixpoint, census, micros and march are therefore
  structurally silent here, which is §11 tripwire 3 exactly: the board is
  green on what the wheel does and says nothing about what it does not.
  ▶ THE RED EVIDENCE IS THE PAIR. Each fixture is the other with one
  edit: add `b()` to sound-default-transport and it becomes
  leak-default-latent, which rejects; remove it and the leak becomes the
  sound twin, which accepts. Both readings were taken before either file
  was written, which is the only honest form of "seen RED" for a pin of
  behaviour that is already correct.
  ▶ BANKED: `Hβ.query.default-param-census` — the measurement above was a
  grep, and a hand tool is a confession. The medium has census shapes for
  eta-wrappers, effectful lambdas and the drift modes; it has none for a
  declared surface like a default-valued parameter, so "does the wheel
  exercise this?" cannot be asked of the medium. That question is the
  selector's own, every time it owes an oracle-blind probe.

- 2026-08-17 · pin 5446b82bddd4 · THE GATE STOPS TEACHING FROM A CELL IT
  NEVER JUDGED — and the same measurement RETRACTS the entry that stood
  here. CLEAN, m2 == m3, census 0, 14.11s wall · 2266360 KB peak.
  ▶ WHAT THE PREVIOUS ENTRY GOT WRONG. It named `row_subsumes`' open-tail
  admission as the leak's site. That admission is real and deliberate,
  and it is NOT what fires on the repro: the gate has two arms, and the
  `Pure` narration comes from the UNBOUND one, which hardcodes
  `mk_ef_pure()` as the body row it reports. Reading one arm and
  attributing the message to it was the same error this arc has now made
  three times with the same display.
  ▶ THE DISCRIMINATOR, isolated one variable at a time. `fn run(f) with
  A = f()` projects `run : r39693@e2` against its param's own
  `r39695@e2` — two DIFFERENT free vars, never unified. Add a concrete
  charge and they fuse: `A + r39713@e8` in the row, `r39713@e8` on the
  param, the same var. A block body alone changes nothing (`r39699` vs
  `r39701`), so the discriminating variable is the concrete charge, not
  the body form. And a genuinely chargeless body BINDS: `fn
  chargeless(x) with A = x + 1` projects `chargeless : Pure`. So a cell
  still FREE at the gate was never determined by its body at all.
  ▶ WHAT LANDED, and it is a deletion. The gate's unbound arm treated
  free as proven-empty — the graph draws that distinction (NRowFree vs
  NRowBound(Pure)) and the arm erased it — then taught over-declaration
  from the row it had fabricated. That teaching is not cosmetic: `mentl
  tighten` authors the patch T_OverDeclared names, so the medium was
  recommending that an author narrow a declaration to `Pure` on a body it
  had never judged. The free-cell arm now teaches nothing. Measured both
  directions through the new pin: `run` loses the warning AND the
  `tighten: with A — body proves Pure` line; `chargeless` keeps both.
  ▶ ENFORCEMENT IS UNTOUCHED, deliberately. Eager enforcement on a free
  tail is this gate's settled policy and its own comment carries the
  measurement that settled it — parking such a gate left "a !WASI
  declaration over a println-performing body parked forever, the crown
  silently off." The teaching went; the verdict did not move.
  ▶ THE LEAK ITSELF IS NOW A FORK, NOT A BUG, and it is Morgan's. Both
  admission paths are deliberate: a BOUND row with a free tail is
  admitted by `row_subsumes` (rejecting it cost a measured 646 false
  mismatches), and an UNBOUND cell is admitted by the arm above. Neither
  is a slip. What they add up to is that a declared row cannot constrain
  a row the body does not determine — and Mentl's surface has no way to
  write the effect-polymorphic declaration that would. The two branches
  are priced in RESIDUE under
  `Hβ.infer.declared-row-vacuous-against-a-free-body-row`.
  ▶ BANKED: `Hβ.diag.row-polymorphic-body` — what the cursor should say
  at a free cell instead of nothing ("this row is polymorphic in f's
  row; it grounds at the call site"). Suppressing a false teaching is
  correct and is not yet the true one.

- 2026-08-17 · THE LEAK'S BOUNDARY IS EXACT: CONCRETE ROWS ARE ENFORCED,
  A FREE VAR IS NOT (no pin — three probes, all reverted; boot unchanged
  at 5a61fc4eba, wheel source untouched).
  ▶ FOUR MEASUREMENTS, and two candidates died before a fix was built on
  either.
  1. THE COMPLETION PRUNE IS EXONERATED. Bypassing `row_keep_completion`
     entirely leaves the repro accepting. The param's row var was never
     in the frame's accumulated row at exit, so the keep-set was never
     the question. (Census went 0 → 12 with the prune off, which is the
     prune doing its actual job and unrelated.)
  2. THE CHARGE RUNS. Replacing the call edge's silent `_ => ()` arm with
     a visible probe effect produced nothing, so the `NBound(TFun…)` arm
     is the one taken and `inf_add_row_unified(crow)` fires.
  3. `row_without_self` IS LOAD-BEARING: removing it makes the wheel trap
     outright, which is evidence the frame's accumulated row contains the
     frame's OWN row handle. Inconclusive as a probe, informative as a
     fact.
  4. THE CLINCHER, and it needs no wheel change: a LOCAL closure with a
     CONCRETE row, declared Pure, REFUSES —
     `E_PurityViolated: expected Pure but found effects: B`. Same call
     machinery, same declaration; the only difference from the leaking
     repro is concrete-row versus free-var.
  ▶ SO THE BOUNDARY IS: a declared row is enforced against a concrete
  body row and silently vacuous against a body row that is a free var
  flowing from a called parameter. The strongest remaining candidate is
  that the param's row var unifies with the enclosing fn's own row var —
  it must, since the body IS `f()` — and `row_without_self` then strips
  it as a self-reference. Measurement 3 is consistent with that and does
  not prove it, so it stays a candidate.
  ▶ NEXT PROBE: determine whether the param's row root equals the frame's
  own row handle at exit. If it does, the fix is that self-stripping must
  distinguish the frame's own row from a var merely unified INTO it, and
  the three-line gate lands with it.

- 2026-08-17 · THE BODY ROW IS *PURE* AT THE CHECK, AND PUBLICATION IS
  EXONERATED (no pin — the leak's fifth narrowing, site bracketed; boot
  unchanged at 5a61fc4eba, wheel source untouched).
  ▶ PUBLICATION IS RULED OUT BY MEASUREMENT, and the previous entry's
  framing with it: `fn wide() with A + B = opb()` publishes `with B`, so
  publication carries the INFERRED row by design. The check's own
  neighbouring comment says the same law outright — "the cell keeps its
  PROVEN row; the declaration publishes NOTHING".
  ▶ THE CHECK IS `row_subsumes(body_row, declared_row)` (infer:3378) and
  the INPUT is the finding: `T_OverDeclared` on the repro reads "declares
  !B + Any but BODY ONLY USES PURE". body_row is PURE, not an open var,
  so the subsumption passes trivially — and the one declaration-write the
  design keeps, the absent refinement, is gated on an OPEN tail by that
  same comment ("closed bodies entail their absences and take no write").
  A Pure body takes no write. Both halves are the design working exactly
  as written, on an input that is wrong.
  ▶ SO THE LOSS SITS BETWEEN THE CALL AND THE DECL EXIT. The charge
  provably happens — `inf_add_row_unified(crow)`, and `main` receives
  B — while the frame's accumulated row is Pure by the time the check
  reads it. The completion prune at `inf_exit_fn` is the CANDIDATE, since
  its signature keep-set is what Phase 1 added to stop precisely this,
  but that is not measured and is not acted on.
  ▶ NEXT PROBE: read the frame's accumulated row immediately before and
  after the prune on the three-line repro. Four causes in this arc were
  asserted from reading code and refuted by running something; this one
  waits for the run.

- 2026-08-17 · THE DECLARED ROW IS VACUOUS AGAINST A FREE BODY ROW (no
  pin — the leak's fourth and measured narrowing; boot unchanged at
  5a61fc4eba, wheel source untouched).
  ▶ THE PREVIOUS ENTRY IS CORRECTED. It said a call to a function-typed
  param "charges nothing". IT CHARGES: `infer_call_saturated` runs
  `inf_add_row_unified(crow)`, its comment covers exactly this case
  ("a pre-free callee ... crow IS the fresh row cell"), and the proof is
  in the artifact — `main`'s row on the repro reads `() -> Int with B`,
  so the callback's effect reaches the caller.
  ▶ WHAT IS BROKEN, from two projections of one file: `run`'s published
  type is `(f: () -> t with r34983) -> t with r34981`. The authored
  `with Pure` IS NOT IN IT. The body's inferred row is a free VAR, the
  declared row neither refuses against it nor binds it, and the
  declaration is dropped from the published scheme. The repro compiles
  because there is no Pure left to violate.
  ▶ THE CONTRAST THAT PINS IT: `fn direct() with OnlyA = opb()` refuses
  with `E_EffectMismatch: A vs B`. Same machinery, same check; the only
  difference is a CONCRETE body row instead of a free one. A declared row
  is enforced against concrete rows and vacuous against a free var.
  ▶ NOT BUILT, and the sentence the dry-iteration rule owes: the SITE is
  unmeasured — whether the declaration is dropped at publication
  (generalize / env_extend) or the check admits a free var — and the two
  call for different edits. Reading either one and guessing which is what
  produced the three retractions this arc has already paid for. The next
  probe instruments the declared-vs-inferred comparison; no edit precedes
  it.
  ▶ FOUR NARROWINGS, each measured, each correcting the last: row
  subtraction (false), the annotation (true but not required), "charges
  nothing" (false), and now the free-var vacuity. The repro went from
  seven lines to three and the mechanism from a guess to a projection.

- 2026-08-17 · `fn run(f) with Pure = f()` IS ACCEPTED (no pin — the leak
  narrowed to three lines; boot unchanged at 5a61fc4eba, wheel source
  untouched).
  ▶ THE NARROWING, three ticks from a seven-line subtraction crucible to
  this:
  ```
  effect B { opb() -> Int }
  fn run(f) with Pure = f()
  fn main() = run(() => opb())
  ```
  `Pure` is the empty row and the body calls an effectful callback. It
  compiles.
  ▶ WHAT IS BROKEN: a call to a function-typed PARAMETER charges nothing
  to the enclosing fn's inferred row, so the DECLARED row is never
  checked against it. No negation is involved, which is why the earlier
  framings kept sliding — subtraction was a red herring
  (`diff_row` provably populates the absent set) and so was the
  annotation (`Pure` shows it without one).
  ▶ IT CORRECTS A "CLOSED" PEER. §11 Phase 1 records
  `Hβ.infer.hof-param-row-never-reaches-enclosing` closed by the
  signature keep-set, "publishes its param's row var in row and scheme
  coherently". The SCHEME half is real and is exactly what
  `leak-higher-order`, `leak-hof-annotated` and `leak-hof-named-arg`
  measure — each puts its negation on the CALLER, where the instantiated
  scheme delivers the callback's row. The ROW half is not: the enclosing
  fn's own row stays Pure. Every HOF crucible in the battery tests the
  half that works.
  ▶ SEVERITY, plainly: this is §0's "the negative is provable" failing at
  the shape most likely to carry a real negation — a function taking a
  callback and promising `!Alloc`, `!IO` or `Pure`. The promise compiles
  and verifies nothing. The caller is still charged through the scheme,
  so simple programs are not miscompiled; the local claim is simply
  false.
  ▶ Banked as `Hβ.infer.param-call-never-charges-the-declared-row`,
  superseding the two framings this arc filed and retracted. The
  three-line gate lands with the fix.

- 2026-08-17 · THE LEAK IS REAL, THE MECHANISM WAS NOT: AN ANNOTATED HOF
  LOSES ITS PARAM'S ROW (no pin — a retraction and a sharper repro; boot
  unchanged at 5a61fc4eba, wheel source untouched).
  ▶ THE BUILD THIS TICK OWED was "make `-` populate the absent set".
  Pricing it first showed the wheel declares no subtracted row, so the
  change was contained — and then reading `diff_row` showed there was
  nothing to change: it already does
  `ef_make(name_set_diff(pa, pb), name_set_union(aa, pb), ta)`, removing
  the name from the PRESENT set and adding it to the ABSENT set, exactly
  as SYNTAX's `E - F = E & !F` says. The open-tail arm builds the same
  masked triple.
  ▶ SO THE PREVIOUS ENTRY'S MECHANISM IS RETRACTED. "The artifact
  subtracts it instead, E - F = E" came from reading an error message's
  DISPLAY — `effect row mismatch: A vs B` — as though it were the row. A
  display is not a measurement, and that is the second time this arc has
  billed me for the difference.
  ▶ THE LEAK IS REAL AND SHARPER THAN THE FRAMING. It needs no
  subtraction: `fn run(f) with A + !B = f()` accepts
  `run(() => opb())`, and the medium volunteers the reason —
  `T_OverDeclared: function 'run' declares A + !B but body only uses
  Pure`. The callback's row never reaches the enclosing fn's row when
  that fn carries its OWN declared row, so the `!B` has nothing to check.
  ▶ WHY THE BATTERY MISSES IT, in one clause: `leak-hof-annotated`
  refuses the same shape because `fn run(f: () -> Int) = f()` has NO
  with-clause — run's row is inferred, carries f's row, and the CALLER's
  `!E` catches it. §11 Phase 1 closed the unannotated form via the
  signature keep-set; the annotated form was not closed with it, and
  every existing HOF crucible puts the negation on the caller, so nothing
  covers the case where a developer writes it on the function that takes
  the callback — the natural place to write it.
  ▶ Banked as `Hβ.infer.annotated-hof-loses-its-param-row` with the
  six-line repro. The crucible stays held back until the fix; the sound
  half that landed (`sound-difference-admits`) never depended on the
  retracted mechanism and stands.

- 2026-08-17 · THE SWEEP FINDS A REAL LEAK: ROW SUBTRACTION IS OMISSION,
  NOT NEGATION (no pin — one crucible landed, one held back; boot
  unchanged at 5a61fc4eba, wheel source untouched; crown 47 → 48).
  ▶ PRIORITY SERVED: the 6.3 modal sweep, fifth tick — and the first that
  found a hole instead of pinning a rule that already held.
  ▶ THE MEASUREMENT. SYNTAX §«Named effect rows» gives
  `type ReadOnly = File - write` and states `E - F = E & !F`, so a
  subtracted member is FORBIDDEN. The artifact drops it instead: with
  `type Both = A + B` and `type OnlyA = Both - B`, the medium reports a
  fn declared `with OnlyA` as carrying the POSITIVE row `A`, no absent
  member. `E - F = E`.
  ▶ WHY NOTHING NOTICED. A DIRECT perform still refuses —
  `fn direct() with OnlyA = opb()` gives `E_EffectMismatch: A vs B` —
  because a positive row does not admit B, so the everyday case is caught
  and the wheel, which never writes a subtracted row in a higher-order
  position, stays green. The HIGHER-ORDER case leaks: `fn run(f) with
  OnlyA = f()` applied to `() => opb()` is ACCEPTED, the callback's row
  unifying into the open tail a positive row carries. That is the exact
  failure §4③ names as the reason Koka omitted negation, reached here
  through `-` rather than through `!`.
  ▶ WHAT LANDED AND WHAT DID NOT. `sound-difference-admits` pins the half
  that holds: subtraction leaves A admitted, higher-order included. The
  leak crucible is held back rather than sitting red in the battery, and
  lands with the fix — the same call the state-init fixture got.
  `Hβ.effects.row-difference-is-omission-not-negation` carries the repro.
  ▶ THE FIX IS THE DOC'S OWN IDENTITY: `-` lowers to `inter_row` against
  the negation, so the subtracted name enters the ABSENT field of the
  canonical triple instead of leaving the present one. SYNTAX is the
  authority and is not edited to match the artifact; the lathe is what
  gets turned.

- 2026-08-17 · NEGATION DISTRIBUTES OVER A NAMED ROW — CROWN 45 → 47 (no
  pin — crucibles only; boot unchanged at 5a61fc4eba, wheel source
  untouched).
  ▶ PRIORITY SERVED: the 6.3 modal sweep, fourth tick, and this one
  leaves the storage-carrier family for a different rule rather than
  hunting an eighth carrier. Three ticks of carriers is where that vein
  ran out, and continuing it would have been the completion-gradient
  rather than the sweep.
  ▶ THE RULE. `type Both = A + B` is a transparent alias (SYNTAX §Named
  effect rows, landed 2026-08-07), so `with !Both` has to forbid BOTH
  members — otherwise a named capability set is a hole in the negation,
  and a developer naming a set is exactly when the medium should keep
  proving absence. `leak-alias-negation` performs A under `!Both`:
  refused (mismatch=1). `sound-alias-negation` performs C, which the
  alias does not name, under `!Both + C`: accepted. The pair pins BOTH
  failure directions — a negation that under-refuses leaks, and one that
  over-refuses makes named rows unusable.
  ▶ SEEN RED: a leak body that performs nothing takes the gate to
  `✗ want reject, mismatch=0`, crown 46/1, and back to 47/0 on restore.

- 2026-08-17 · THE HOLE-PRODUCT JOINS THE LATENCY RULE, AND CORRECTS THE
  LAST ENTRY — CROWN 43 → 45 (no pin — crucibles only; boot unchanged at
  5a61fc4eba, wheel source untouched).
  ▶ PRIORITY SERVED: the 6.3 modal sweep, third tick.
  ▶ THE PREVIOUS ENTRY CALLED THE STORAGE-CARRIER FAMILY COMPLETE against
  §5.U's five node-kinds. It was not. SYNTAX calls partial application
  "the product with a hole" — a first-class VALUE carrying its supplied
  fields — so the PARAMETER PRODUCT is a storage carrier exactly like the
  record field and the tuple position, and nothing pinned it. The roster
  check that found it took one `ls`.
  ▶ `leak-partial-latent` partially applies a fn that performs E, leaves
  the hole open, and fills it under `with !E`: refused (mismatch=1).
  `sound-partial-transport` builds the identical partial application
  under the same negation and never fills the hole: accepted. That pair
  is the surface's own claim measured — a hole-product performs nothing
  until its field arrives, and the row rides the product until it does.
  ▶ SEEN RED: dropping the filling call takes the gate to `✗ want reject,
  mismatch=0`, crown 44/1, and back to 45/0 on restore.
  ▶ THE CARRIER SET, stated without the word complete this time: list
  element, record field, tuple position, variant payload, handler config
  slot, handler state slot, and the parameter product's hole. Six
  crucible pairs across three ticks, none of which touched wheel source —
  the rules all held; what was missing was the board's ability to see
  them break.

- 2026-08-17 · HANDLER STATE JOINS THE LATENCY RULE — CROWN 41 → 43 (no
  pin — crucibles only; boot unchanged at 5a61fc4eba, wheel source
  untouched).
  ▶ PRIORITY SERVED: the 6.3 modal sweep, continuing from the sum
  carrier landed at the previous tick.
  ▶ THE GAP. `leak-handler-residual` pins a CONFIG fn's row reaching the
  residual, and nothing pinned the STATE slot. §5.U calls config and
  state ONE unified record — handler IS state IS closure IS evidence — so
  the latency rule has to hold at both, and only one was covered.
  `leak-state-latent` holds `() => op()` in a handler's own state field,
  calls it from an arm, and installs under `with !E`: refused
  (mismatch=1). `sound-state-transport` stores the identical closure and
  never calls it: accepted. The crown already held the rule at this slot;
  the sweep pins it so the board can see it regress.
  ▶ SEEN RED: inverting the leak so the arm resumes a constant instead of
  calling the state closure takes the gate to `✗ want reject,
  mismatch=0`, crown 42/1, and back to 43/0 on restore.
  ▶ THE STORAGE-CARRIER FAMILY IS NOW COMPLETE against §5.U's five
  node-kinds: sequence (list element), product (record field, tuple
  position), sum (variant payload), and the handler record's own two
  slots (config, state). A word cannot carry a closure, and the function
  kind is the escape case already pinned by leak-escape-negation.

- 2026-08-17 · THE SUM CARRIER JOINS THE LATENCY RULE — CROWN 39 → 41
  (no pin — crucibles only; boot unchanged at 5a61fc4eba, wheel source
  untouched).
  ▶ PRIORITY SERVED: §11's standing cursor names the 6.3 modal sweep
  rule-by-rule as the loop-sized residue, and the state-init defect is
  parked behind the column arc, so continuing to bash at it would have
  been the completion-gradient the block forbids as a selection reason.
  ▶ THE GAP THE ROSTER SHOWED. Latency-rides-STORAGE was pinned at three
  carriers — the list element, the record field, the tuple position —
  which are the SEQUENCE and PRODUCT node-kinds. §5.U names five, and the
  SUM was unpinned: a closure performing E carried as an ADT variant's
  payload, matched out and called. `leak-variant-latent` refuses at the
  call (mismatch=1) and `sound-variant-transport` accepts the same
  variant matched without calling. Both pass, so the crown already held
  this rule; the sweep's job is to PIN it, and an unpinned rule is a rule
  the board cannot see regress.
  ▶ SEEN RED, because a coverage crucible that cannot fail is decoration.
  Inverting the leak case to not call its payload takes the gate to
  `✗ want reject, mismatch=0`, crown 40/1, then back to 41/0 on restore.
  The pair discriminates.

- 2026-08-17 · NOTHING BUILT, AND THE SENTENCE NAMING WHY: THE GRAPH DOES
  NOT RECORD THE CONFIG SLOT (no pin — third iteration without a src
  change, so the dry-iteration rule owes this sentence; boot unchanged at
  5a61fc4eba, src and lib byte-identical).
  ▶ THE DESIGN THAT LOOKED RIGHT AND DIED TO ONE PROJECTION.
  `bind_handler_config_params` records the Reason
  `LetBinding(name, Declared(hname))` when it env-extends each config
  param, which promised a one-site fix: lower reads the VarRef node's
  Reason, sees the handler, emits `LUpval(0, slot)`. No walker, no frame,
  one site, and Carried-Truth exactly. The medium refused it. At the
  init's config USE the address answers `start : Int` with `Why: resume
  carries the continuation input`; at the config DECLARATION it answers
  `start) : _ — still free`, `Why: placeholder`. The env scope holding
  that binding is gone by lower time and the node's Reason is a different
  reason, so there is no live fact to read. Killed before a byte changed,
  which is what the acting-gate is for.
  ▶ WHAT STRUCTURALLY PREVENTS THE BUILD, in one sentence as owed: the
  config-slot resolution is not a graph fact, so every remaining route
  needs either new walk machinery over the init (39 LowExpr arms that
  §11 5.5's column arc plans to delete) or context threaded into
  `lower_expr`'s shared VarRef arm (the frame, whose failure in the
  demand walk is still unmeasured) — and neither is a small correct
  change today.
  ▶ THE ULTIMATE FORM IS 5.5's OWN MOVE, which is why this sequences
  rather than stalls: put the config-slot resolution in a column, written
  where infer binds the param, read live at lower. Then lower needs no
  scope, no frame and no walker; the nested case works by construction;
  and `lower_state_init`'s special case dissolves instead of being
  extended. Four designs died in this arc because they tried to reach a
  fact the graph never wrote down. Writing it down is the fix.

- 2026-08-17 · THE FLOOR COUNT WAS NEVER EVIDENCE, AND THE FRAME CALL
  WORKS (no pin — instrument run, variant reverted whole; boot unchanged
  at 5a61fc4eba, src and lib byte-identical).
  ▶ THE BANKED PROBE ASKED whether the emit's singleton-install proof is
  per call site. It is NEITHER per-site nor per-handler: there is no
  emit-time proof at all. `singleton_perform_block` emits, for every
  STATEFUL singleton op call site, `LWorldResolve` into a local and then
  an `LIf` whose null arm is `LInvariantFailure(SingletonUninstalled)`.
  The `unreachable` is a RUNTIME else-branch. So a floor count is simply
  the number of stateful singleton call sites in a build — 50 baseline,
  52 in the variant because the variant adds two — and it says nothing
  about what is installed. Two iterations of design rested on that count.
  Both were wrong, and reading the emit's own construction cost one grep.
  ▶ THE FULL BACKTRACE, read whole rather than grepped, corrects the
  other half. The trap is in `lambda_329309` under
  `op_map_collector_yield` / `iterate_from` /
  `map$spr_initnNode_nLowExpr` — INSIDE the map's lambda, which is
  `lower_expr(field.init)`. Had `ls_enter_frame` floored it would sit
  directly under `lower_state_field_inits`. IT DOES NOT: the frame call
  succeeds. And the context is the demand walk, not ordinary lowering —
  `lower_pipe` ← `project_nested_fn` ← `lower_stmt_body` ←
  `reach_construct_loop` ← `reachable_from_main`.
  ▶ SO THE SPECIAL CASE IS A SHORTCUT AROUND `lower_expr`'s VARREF PATH,
  not around a missing frame. The bare config ref works because it never
  enters that path; the nested case fails because it must. The fix that
  follows — and it follows from a measurement, not a preference — is to
  resolve config refs structurally AT EVERY DEPTH without entering the
  general VarRef lowering. The frame was never the mechanism, and
  `lower_state_init` was right to resolve by name all along.
  ▶ WHAT REMAINS UNMEASURED is named rather than assumed: which op inside
  the VarRef arm floors in this walk. The design does not depend on the
  answer, so it is not a blocker — it is the probe to run if the
  structural rewrite meets a second wall.

- 2026-08-17 · THE NEW LAW'S FIRST RUN CATCHES ITS AUTHOR (no pin —
  a verified correction; boot unchanged at 5a61fc4eba, src and lib
  untouched, m2 == m3 re-confirmed by the baseline build this used).
  ▶ WHAT THE ITERATION WAS FOR. `CLAUDE.md ⊕` and the loop's step 4 now
  gate ACTING, not only asserting: no edit builds on a cause the artifact
  has not shown this turn. The next build depended on one such cause —
  "52 `no live install: lower_scope` floors prove the handler is absent
  at `lower_state_field_inits`" — so the law required counting the
  baseline before designing against it.
  ▶ THE BASELINE HAS 50. The delta is +2, exactly the number of new `ls_`
  call sites the frame variant added. The mechanism survives; the
  evidence as written did not. An absolute count proves nothing without
  its baseline, and the baseline cost one march. Had this gone unchecked
  it would have been the sixth refuted cause in this arc, and the first
  one to steer a build.
  ▶ AND IT SHARPENS THE QUESTION, because a second measured fact does not
  fit "the handler is not installed": the BASELINE compiles the nested
  repro to a NON-EMPTY 38,568-byte WAT carrying the `MissingName` marker
  for `start`, and reaching that marker requires `ls_resolve` to have
  returned `RGlobal` at this very site. `lower_scope` is therefore
  reachable here at RUNTIME, and the two added sites floored at EMIT
  time. Two different mechanisms; only the second is measured, so no
  design rests on either yet.
  ▶ THE NEXT INSTRUMENT, which is this iteration's output rather than an
  explanation: is the emit's singleton-install proof per CALL SITE?
  `ls_resolve` in `lower_expr`'s shared VarRef arm does not floor; the
  added `ls_enter_frame` does. Per-site means the frame route is alive
  and needs the install proven where the floor's own message says to put
  it; per-handler means it is dead and the structural rewrite is the only
  road. One measurement decides, and nothing is built before it.

- 2026-08-17 · ANSWERED: THE SCOPE HANDLER IS NOT INSTALLED THERE, AND
  THE COMMENT SAID SO (no pin — probe reverted whole; boot unchanged at
  5a61fc4eba, src and lib byte-identical to the previous pin).
  ▶ THE ANSWER, MEASURED. The candidate wheel built with the frame
  variant carries 52 `singleton op call with no live install:
  lower_scope` floors, read straight out of `.build/m2cache/m2.wat`. So
  `lower_state_field_inits` runs where `lower_scope` is NOT installed,
  every `ls_*` call in the variant lowered to an `unreachable`, and the
  compile trapped — exit 134, zero WAT, the backtrace pinning
  `map$spr_initnNode_nLowExpr` under `lower_stmt_body`, which is the map
  the change itself added.
  ▶ THE SITE'S OWN COMMENT WAS RIGHT, and this arc spent three
  iterations arguing with it. It says the config slot is "resolved
  STRUCTURALLY (the config slot is known by name — carried truth, not
  re-derived) rather than via a frame the install must thread evidence
  for." The frame is unavailable precisely BECAUSE the install threads no
  LowerScope evidence here. The special case is the correct design given
  that, not the shortcut I kept calling it.
  ▶ AND A RETRACTION OF THE PREVIOUS ENTRY'S CENTRAL CLAIM. It reported
  "THE FRAME IS CONSULTED … ZERO `unbound name` markers" in the variant's
  WAT. That file was ZERO BYTES — the compile had already trapped and
  emitted nothing, so zero matches meant nothing at all. It is the same
  "no verdict from empties" the march's own SIZE-GUARD refuses, made by
  hand. The rule is one line: check an artifact's byte count before
  grepping it.
  ▶ WHAT THE REAL FIX MUST BE, now constrained by evidence rather than
  taste: the nested case has to be resolved STRUCTURALLY too — config
  refs substituted for `LUpval(0, slot)` within the init's own lowering,
  with no scope handler involved. A lowering parameterised by
  `config_names`, or a rewrite of the lowered tree. That is the only
  shape the evidence at this site permits, and it is the first design in
  this arc that the artifact has not refused.

- 2026-08-17 · THE INSTRUMENT REFUTES THE PREVIOUS ITERATION'S OWN
  DIAGNOSIS (no pin — probes reverted whole; boot unchanged at
  5a61fc4eba, src and lib byte-identical to the previous pin).
  ▶ THE MANDATED PROBE, run before any third design as the last entry
  required. Two facts, both from the artifact. The special case works
  exactly as documented: encoding which branch it takes in the exit code
  — 777 for an empty `config_names`, 888 for a name not found — the repro
  answers 10, so the list is populated and the name resolves at its slot.
  And THE FRAME IS CONSULTED: rebuilding the frame variant and reading
  the EMITTED WAT shows ZERO `unbound name` markers, so the name resolves
  through `ls_resolve` and no MissingName floor is emitted. "The frame was
  never consulted", written one iteration ago, is WRONG — a third guess,
  refuted like the two before it.
  ▶ WHAT IS ACTUALLY OPEN is now well posed: the frame variant lowers
  CLEANLY and still traps at RUN. One visible difference is the first
  hypothesis to kill — the special case emits `LUpval(0, slot)` with
  handle 0, while the resolver path takes
  `LUpval(if local_h == 0 { handle } else { local_h }, slot)` and, the
  capture handles being zeros, lands on the VarRef's OWN handle. Same
  slot, different handle, and emit reads the handle for type-directed
  decisions.
  ▶ THE INSTRUMENT LESSON, paid for with two broken wheels.
  `lower_state_field_inits` is shared by EVERY handler in the wheel, so a
  behavioural probe there is a whole-wheel change: substituting a constant
  for state inits stripped the wheel's own handlers of their state and
  produced m3 ≠ m4 twice — the second time even gated on a fixture-only
  name. The instrument that works needs no behaviour change at all: build
  the candidate m2, compile the repro, read the WAT. That is what finally
  answered the question, and it is what the next probe uses — diff the
  state-init region between baseline and variant.
  ▶ FIVE GUESSES REFUTED IN TWO ITERATIONS on one defect. The pattern is
  consistent enough to name: every one came from reading code and
  reasoning forward, and every refutation came from running something.
  The rule this earns is narrower than "measure first" — when a chain's
  links each verify and the whole still fails, stop reading the links.

- 2026-08-17 · THE CAPTURE-FRAME FIX IS REFUTED, AND THE ITERATION STOPS
  GUESSING (no pin — experiment reverted whole per step 5; boot unchanged
  at 5a61fc4eba, src and lib byte-identical to the previous pin).
  ▶ THE BUILD THE STAMP OWED. The design was to give the lowering scope a
  way to declare a config slot, so a nested config ref in a handler state
  init would resolve like any captured name. Reading the artifact
  improved it before a byte changed: NO new op is needed, because
  `ls_enter_frame(fn, locals, local_h, captures, capture_h, lambda_h)`
  already resolves a name in CAPTURES to `RUpval(slot)`. Wrapping the
  init lowering in a frame whose captures are the config names should
  have given the nested case the identical lowering the top-level case
  hand-builds — same slot numbering, same handle — while DELETING
  `lower_state_init`'s special case into the general resolver.
  ▶ IT MEASURED WORSE. m3 trapped. Probing the candidate wheel directly:
  the bare program compiled fine (exit 7), the nested case was unchanged
  (still 134), and the DIRECT case — which worked before at exit 10 —
  had regressed to 134. So the frame was never consulted for these
  lowerings, and deleting the special case removed the only mechanism
  that worked. Reverted whole; `direct.mn` answers 10 again.
  ▶ WHAT IS PROVEN SOUND IN ISOLATION, banked so the next attempt does
  not re-read it: `ls_resolve` searches `frame.captures` and returns
  `RUpval(cap_idx)`; `ls_enter_frame` is a plain push; and the install
  path does reach the changed function, since
  `lookup_handler_state_inits_of` calls `lower_state_field_inits`
  directly. Every link checks out and the chain still fails.
  ▶ THE HONEST LESSON OF THE DAY, and it is the second time it has been
  written since morning: I guessed FOUR times in this iteration — the
  capture-read class, the value 1024, "state inits are never judged", and
  now the frame — and the artifact refused each one. A chain whose links
  each verify and whose whole still fails is the signature of a wrong
  MODEL, not a wrong link, and the answer to that is an instrument, not
  another reading. The next probe is one print of `config_names` and the
  resolution verdict at the init's VarRef; no third design before it
  exists.

- 2026-08-17 · RETRACTION: STATE INITS *ARE* JUDGED — THE GAP IS AT
  LOWER, WHERE ITS OWN COMMENT SAID (no pin — a correction and a design;
  boot unchanged at 5a61fc4eba, src and lib untouched).
  ▶ THE PREVIOUS ENTRY IS WRONG AND THIS ONE RETRACTS IT. It claimed
  "decl-side handler state-init expressions are never inferred", banked
  it as `Hβ.infer.handler-state-inits-are-never-judged`, and reasoned
  from `register_handler` performing only the op-shadow check. The
  judging lives elsewhere in the same file:
  `infer_handler_state_inits(state)`, whose neighbouring comment states
  the contract outright — config params bound FIRST so a state init
  referencing one reads the live config — and records the bug that
  motivated it. Two seconds of probe refute the claim: `handler h(start)
  with n = nosuchname + 1` reports `E_MissingVariable at 5:30-5:40` and
  `mentl run` REFUSES at exit 1.
  ▶ HOW THE ERROR WAS MADE, recorded because it is the same one twice in
  one day: I read ONE site, found it insufficient, and generalised to
  "never" without grepping for a second reader. §5.O's own history is
  that code-reading loses to measurement, and the measurement here cost
  one fixture and two seconds. The rule earns its own line — before
  writing "never" about a compiler, run the program that would prove it.
  ▶ WHAT IS ACTUALLY TRUE. Infer resolves a config ref in a state init
  correctly, so a clean `mentl check` is the RIGHT answer rather than a
  missed diagnostic. LOWER is the gap: `lower_state_init` matches only a
  TOP-LEVEL `VarRef` against config names and turns it into
  `LUpval(0, slot)`; everything else goes through `lower_expr`, where the
  config name is not in the lowering scope, resolves RGlobal, misses
  `env_kind_of`, and becomes the MissingName floor. `with n = start` runs;
  `with n = start + 1` traps. The site's comment has said this all along.
  ▶ THE DEFECT THAT SURVIVES the retraction is narrower and still real: a
  construct the lowering cannot lower produces a runtime FLOOR rather
  than a refusal, so the program checks clean and traps at 134.
  ▶ AND THE FIX IS SMALLER THAN EITHER STORY SUGGESTED. The lowering
  scope already carries an `RUpval(slot)` verdict; the config ref needs
  no "config-capture frame", only a way to declare one. `ls_bind_upval`
  beside `ls_bind_local`, a scope pushed in `lower_state_field_inits`
  binding each config name to its slot — and then `lower_state_init`'s
  top-level special case DISSOLVES into the general resolver. The fix
  deletes a special case instead of adding one. Banked at
  `Hβ.lower.state-init-config-ref-nested`; marched next iteration,
  because it touches the resolver every lowered name goes through.

- 2026-08-17 · HANDLER STATE INITS ARE NEVER JUDGED — A PROGRAM THAT
  CHECKS CLEAN AND TRAPS (no pin — the root located and banked with its
  repro; boot unchanged at 5a61fc4eba, src and lib untouched).
  ▶ FROM SYMPTOM TO ROOT IN ONE ITERATION, because the repro got small.
  The previous pin bisected the trap to "a state initializer cannot read
  its config" across four wheel-scale marches at ~60s each. A 30-line
  fixture reproduces it in two seconds, and splitting it pins the
  boundary exactly: `handler h(start) with n = start` runs and answers
  10; `with n = start + 1` traps. Direct assignment survives only because
  `lower_state_init` special-cases a bare config VarRef STRUCTURALLY into
  `LUpval(0, slot)` — no binding required. Anything larger needs the name
  to actually resolve, and it does not.
  ▶ THE ARTIFACT NAMES ITS OWN ROOT. The emitted WAT carries
  `(unreachable) ;; executable-boundary invariant: unbound name start —
  infer proved it missing; the lowering will not guess it into a global`.
  The lowering is behaving correctly and refusing to fabricate. Reading
  infer for the other half: BOTH `HandlerDeclStmt` sites reach
  `register_handler`, which checks state-field NAMES against op names,
  mints config tparams, env_extends the handler — and never walks a
  single init EXPRESSION. The only `infer_expr` over a state init in the
  file is for `resume() with x = …` updates.
  ▶ SO THE CLASS IS BIGGER THAN THE PEER IT EXPLAINS: everything in a
  `with field = init` clause is unjudged — no types, no name resolution,
  no diagnostics. It has never bitten because every init the wheel writes
  is a literal, a nullary call, or a bare config ref.
  ▶ AND IT IS A SILENT WRONG, which is why it is banked loudly.
  `mentl check` reports NOTHING on the trapping program — zero
  diagnostics, then exit 134. The MissingName floor's own comment expects
  infer to have already fired a precise, spanned E_MissingVariable, and
  for ordinary code it does; here infer never walked the expression, so
  nothing fired and the executable gate had nothing to refuse. A program
  that type-checks and traps is exactly what §0 exists to make unsayable.
  ▶ NOT BUILT, DELIBERATELY. The fix is one change for both halves —
  infer judges decl-side state inits with config params in scope — and
  its blast radius is real: expressions the wheel has never judged become
  judged. That is a marched build, not a tired end-of-iteration edit, and
  it is now fully specified. The fixture stays as the repro rather than
  becoming a gate: it is RED by construction, and gating today's
  behaviour green would canonize the bug (§9.11's own warning).

- 2026-08-17 · A HANDLER'S STATE INIT CANNOT READ ITS OWN CONFIG (no pin
  — the experiment reverted whole per the loop's step 5; boot unchanged
  at 5a61fc4eba, src and lib identical to the previous pin).
  ▶ THE PROBE THE LAST PIN BANKED, run and answered. The question was
  which of `region_tracker`'s three install sites broke when the handler
  gained a config parameter. The answer is none of them: it is the
  handler's own state initializer READING the config, and four marches
  with one variable each pin it exactly —
  no param → CLEAN · param present but UNREAD → CLEAN · param read
  inline as `list_filled(buckets, [])` → TRAP 134 · param read through a
  call as `region_index_new(buckets)` → TRAP 134.
  Not the presence, not the nested call, not the value (65536 at every
  site, behaviour-identical to the working form, traps exactly as 1024
  did), not capture-vs-literal (both trap). The READ is the defect.
  ▶ WHY THE SYMPTOM IS EXACTLY WHAT IT SHOULD BE. `branch_bracket`'s own
  comment names `Hβ.lower.install-config-capture-read` — "a
  capture-referencing config arg reads 0" — for ARM bodies. The same zero
  arriving in a STATE INIT explains the trap mechanically:
  `list_filled(0, [])` is an empty index, `len(idx) - 1` is `-1`,
  `i32_and(handle, -1)` is the raw handle, and `list_set` runs off the
  end. Banked as `Hβ.lower.handler-state-init-reads-config`.
  ▶ WHY IT HAS NEVER FIRED, which is the part that matters beyond this
  arc: no handler in the wheel derives state from its config.
  `graph_handler(spine0, …) with spine = spine0` assigns one straight
  through and works; `intern_table` uses a literal. DERIVING is the
  untested shape, so the medium accepts such a handler and miscompiles
  it — a program that type-checks and traps, which is the class §0 exists
  to make unsayable. It is tripwire 3 again: the board is green on what
  the wheel does and silent on what it does not.
  ▶ NOTHING LANDED, DELIBERATELY. A gate for this is RED by construction
  today, and red gates do not land; the fixture and the substrate fix are
  one landing. The experiment reverted whole and the tree is byte-identical
  to the previous pin.

- 2026-08-17 · THE BUCKET COUNT IS THE INDEX'S OWN — AND THE FIX IT WAS
  FOR IS REFUTED (pin 5a61fc4eba — CLEAN m2 == m3, re-pinned from m2 per
  march.sh, 412135 lines, census 0; m3 leg 16.55s wall · 2124MB peak
  RSS).
  ▶ THE PROFILE, RE-PRICED because the last landing invalidated it. With
  the branch spawn deleted, `branch_bracket` is STILL 55.95% inclusive —
  so the thread was never the cost, the BRACKET is — and
  `list_filled_from` specialised on Span is 25.91% SELF, 24.04% of the
  whole run reached from branch_bracket alone. The cause is
  `region_tracker`'s state initializer: `region_index_new()` fills 65536
  slots one `list_set` at a time, the initializer runs on EVERY install,
  and branch_bracket installs it per judged branch. `fn main() = 7`
  writes ~28 million slots to hold a few dozen entries.
  ▶ WHAT LANDED. The bucket count was the literal 65536 in the
  constructor and 65535 in both accessors' masks — one fact written three
  times. `len` is `load_i32`, so the mask reads it from the list that
  already knows it. Behaviour-neutral alone, and the precondition for any
  sizing.
  ▶ THE KILL. Making the count a handler CONFIG PARAM, so a branch could
  size to its own statement instead of inheriting the root's, TRAPPED m3
  at exit 134 with zero bytes. Probed twice — a top-level `let` and a
  bare literal trap identically — so it is NOT the
  capture-referencing-config-arg class branch_bracket's own comment
  names. Reverting the param alone and re-marching gives CLEAN, which
  isolates it exactly: the defect is in parameterising THIS handler at
  one of its three install sites, and it is unexplained. The next probe
  bisects the installs; RESIDUE carries it, with the spine-column route
  as the alternative if the parameter stays broken.
  ▶ A RATCHET CORRECTION, and the lesson is about ratchets not memory.
  The peak ceiling was cut to 2250000 at the previous pin from ONE
  reading of 2174492. Three pins of materially the same wheel read
  2298592, 2174492 and 2256804KB, and this pin read 2175392 — ~120MB of
  run-to-run variance. The tighter line was measuring noise, and it
  REFUSED a clean fixpoint on its next run. Raised to 2310000, above the
  highest of the three. A ratchet set inside its own measurement's
  variance is not a ratchet; it is a coin flip that blocks good work, and
  the rule that follows is to set a ceiling from a SPREAD, never a point.

- 2026-08-17 · ▶▶▶ THE SINGLETON JUDGE BLOCK STOPS SPAWNING — 433
  THREADS TO ZERO, THE SWEEP 297.64s → 239.38s (pin 3fc233421e — CLEAN
  m2 == m3, re-pinned from m2 per march.sh, 412058 lines, census 0; m3
  leg 15.23s wall · 2123MB peak RSS).
  ▶ THE STAMP, ANSWERED AGAINST THE ARTIFACT before a byte changed. The
  question was whether a branch's isolation is load-bearing at K=1 or
  inherited from the K=8 design. Three readings say inherited:
  `branch_bracket` — installed inside `branch_judge`, spawned or not —
  carries the private env overlay and the deferred diagnostics; the
  bracket's own comment says graph, intern, the ledgers and the
  summaries "stay the root's live instances"; and the `~> graph_handler`
  wrapper on the spawn exists ONLY because a spawned instance's world is
  empty where the sequential render reads the dispatch chain's own
  instance — it was added to reproduce the sequential form, which is the
  form a direct call simply IS. The spawn is the concurrency, never the
  semantics.
  ▶ THE BUILD. `BranchRec = BrDirect | BrSpawned`, and a block of ONE
  runs its branch as a direct call. The decision is by BLOCK SIZE, not by
  reading `judge_window`, so Phase 9.2's K=8 restores spawning with no
  edit here and a trailing singleton block still goes direct — correct
  and free.
  ▶ MEASURED, and this is the arc's first real win after six probes that
  each cleared a suspect: guest threads 433 → 0 (peak 10, exactly the
  runner's own baseline, so the guest now spawns none); the floor fixture
  0.78s → 0.58s over seven settled reads; the frontier sweep 297.64s →
  239.38s at 371/0; the m3 leg 2298592KB → 2174492KB with its ceiling
  lowered to 2250000 to hold it.
  ▶ THE CROWN CAUGHT THE ONE REAL CONSEQUENCE, which is the part worth
  keeping. The first march came back CLEAN on the fixpoint with 139/139
  micros and census 2 — two E_EffectMismatch, both on ImageAlloc. A
  task's body row never reached its spawner, so the thread boundary had
  been HIDING the branch's allocation from every caller's row; the direct
  call makes it visible. `driver_check_module` and `rederive_cone` now
  declare what they always performed. That is a row widened by DELETION,
  not by a new effect, and nothing but the effect system would have said
  so.
  ▶ WHAT IT MEANS FOR THE ARC. `Hβ.driver.link-is-reachability` is still
  the named build and its pricing stands, but the floor it attacks is now
  0.58s rather than 0.78s, and the phases it can skip (lex 4.17%, parse
  4.02%, the judge's ~15%) are a larger share of what remains.

- 2026-08-17 · HALF THE COMPILE IS SPAWNING BRANCHES THAT RUN ONE AT A
  TIME (no pin — the finding and its stamp; boot unchanged at
  e7c2da624b, src and lib untouched).
  ▶ WHAT THE AGGREGATE PROFILE FOUND, after six probes each cleared
  their suspect. `fn main() = 7` compiles in 0.78s, and the inclusive
  per-symbol view says where it goes: `wasi_thread_start` 48.45%,
  `branch_bracket` 46.80%, and the two list primitives those brackets
  run — `list_filled_from` specialised on Span at 25.59% SELF, `list_set`
  at 23.17% SELF — roughly HALF the run. At the OS level the same
  fixture creates 433 distinct threads, 20 concurrent at peak against a
  10-thread wasmtime baseline (measured by polling the task table for
  `help`, which loads the identical 2.4MB module and compiles nothing).
  ▶ THE CAUSE, read from the artifact. §11 5.2 serialized the parallel
  final on 2026-08-07 — `judge_window = 1` — because the K=8 fan's
  correctness rested on published schemes being live-var-free and live
  cells raced its branches. The window went to 1; THE SPAWN DID NOT.
  `layer_judge_walk`'s comment states it plainly: "every layer branch
  runs as a REAL task — a spawned instance of the whole module over the
  shared image", and `judge_blocks` spawns a block of `judge_window`,
  joins it, spawns the next. At window 1 that is one OS thread per layer
  branch with no parallelism bought. The serialized path pays the
  parallel path's full price for none of its benefit — a cost 5.2's
  landing did not intend and did not measure.
  ▶ WHY IT HID FOR SIX PROBES, which is the method lesson. An earlier
  `--no-children` read of a smaller capture showed a flat profile topping
  out at 7%, and that reading was banked as "there is no hot spot" —
  which then justified concluding the cost was diffuse substrate work.
  The CHILDREN view aggregated per symbol shows two functions owning half
  the run. A flat SELF profile over monomorphized twins hides a dominator;
  §5.O's measure-don't-read-code law needs the corollary that HOW you
  read the profile is itself a measurement choice that can be wrong.
  ▶ THE STAMP, banked at `Hβ.infer.serialized-judge-still-spawns` and
  deliberately NOT built this iteration: at window 1, can the branch be a
  direct call? The comment claims the join stream is "byte-identical to
  the sequential walk by construction", which argues yes — but the spawn
  also buys each branch a fresh instance with branch-local ledgers,
  disjoint mint ranges and a read-only intern view, and whether those are
  load-bearing at K=1 or merely inherited from the K=8 design has to be
  answered against the artifact first. The prize is about half the floor;
  the risk is that the isolation is doing quiet correctness work.
  ▶ IT ALSO RE-RANKS THE ARC. `Hβ.driver.link-is-reachability` was the
  named next build, priced at the phases it could skip. Those phases —
  lex 4.17%, parse_program 4.02%, the judge's own 15% — sit beside a
  spawn overhead of comparable size that no amount of demand-linking
  removes, because it is paid per BRANCH, not per line.

- 2026-08-17 · THE SPLICED-NAME GAP IS CLOSED, AND THE SEED SET IS A
  CONTRACT (no pin — tools only; boot unchanged at e7c2da624b, src and
  lib untouched, so the fixpoint stands).
  ▶ THE STAMP'S LAST RISK, DISCHARGED BY MEASUREMENT. The sugar set was
  measured at 44 names by scanning quoted literals, and banked honestly
  as a LOWER BOUND: a name assembled by splicing a fold_sig would be
  invisible to that scan. So the splices were enumerated — 55 of them
  across the lowering, the backend and infer — and every one is
  compiler-SYNTHESIZED: `__hstate_{h}`, `__fb_prev_{h}`,
  `__fanout_spawn_{i}_{h}`, `lambda_{n}`, `compose_{side}_{h}`,
  `hash_{fold_sig}`, `tuple_{int_to_str(h)}`. These name WASM locals,
  globals and generated functions the compiler emits itself; none is a
  call into lib/. Checked rather than eyeballed: of forty distinct
  spliced prefixes, only `tuple_` shares a namespace with any prelude
  decl (tuple_get / tuple_set), and its splice is `tuple_{handle}` —
  `tuple_1234`, never `tuple_get`. THE LITERAL SCAN SEES THE WHOLE SET,
  so demand-linking's seed vocabulary is complete and the peer is
  unblocked on that count.
  ▶ THE CONTRACT. verify now holds `desugar_vocabulary: 43` EXACT (44
  minus the `str_literal_5` relic deleted at the previous pin). The
  reason it is worth a gate is not hygiene: when that set changes, the
  demand-link's SEED must change with it, and nothing else in the repo
  would say so.
  ▶ WHAT THE RED TESTS TAUGHT, and this is the honest half. The first
  draft of the gate's comment claimed it catches a prelude rename
  breaking a desugar path. Two RED tests refuted its own author.
  Renaming `list_to_flat` in lib/ aborted verify long before the check
  ran — the wheel's own source calls it, so that break is loud already.
  Corrupting ONE `"list_to_flat"` literal in the lowering left the count
  at 43, because this is SET MEMBERSHIP and the name appears more than
  once. What it does catch was then seen RED properly: a new prelude
  name entering the vocabulary moved 43 → 44 and refused. The comment
  and the failure message were rewritten to claim exactly that and no
  more — a gate that oversells what it proves is the Carried-Truth Law
  violated at the prose layer, and the artifact caught it here.
  ▶ ONE PROCESS SLIP, recorded because the law is explicit: the baseline
  value 43 was written by arithmetic (44 minus the deleted relic) and
  only then measured. It agreed, but the order was wrong — the number
  goes in AFTER the read, never before.

- 2026-08-17 · ▶▶▶ THE SUGAR SET IS 44 NAMES, AND ONE OF THEM WAS A
  RELIC (pin e7c2da624b — CLEAN m2 == m3, re-pinned from m2 per
  march.sh, 411950 lines, census 0; m3 leg 19.52s wall · 2239MB peak
  RSS).
  ▶ THE MEASUREMENT THE STAMP OWED. `Hβ.driver.link-is-reachability`
  banked one unenumerated risk and called it a measurement rather than a
  design choice: which prelude names does the compiler MINT that source
  never writes? Reachability seeded from written names alone would miss
  them, and demand-linking is unsafe until they are known. Read off the
  artifact — quoted literals in the lowering, the wasm backend, the
  parser, infer and pipeline, intersected against what lib publishes —
  the answer is 44. The lowering and backend contribute 28 (list_index,
  list_set, str_concat, to_string, make_list, slice, hash, the
  eq/compare/hash families, world_find_from, ev_perform_node); parser
  and infer add 16 more, including `delay` (the `<~` vocabulary), `not`,
  `concat`, `last`, `drop_last`, `byte_at`/`byte_len`, `str_of_buf`,
  `str_payload`, and the float-render family. STATED AS WHAT IT IS: a
  measured LOWER BOUND. A name assembled by splicing a fold_sig is
  invisible to a literal scan, so this is a floor, not a proof, and the
  completeness demand-linking needs must come from the lowering's own
  dispatch rather than from a grep.
  ▶ WHAT THE ENUMERATION CAUGHT. `str_literal_5` sat in the sugar set —
  and it is `fn str_literal_5(s) with Pure = s`, the IDENTITY function.
  Its comment claimed it allocates a small constant string from bytes
  with the caller encoding the string as individual byte arguments,
  which is false twice over (callers pass whole literals), and its own
  text named the bootstrap DELETED ON 2026-07-10. It survived because it
  was load-bearing in the wrong sense: a name-keyed entry in
  `is_seq_op`'s cname chain and a hand-written signature in infer's
  substrate table, so the type checker special-cased an identity.
  Deleted whole — four call sites inlined to their literals, the fn
  gone, both table entries gone. A name-keyed special case retired
  rather than renamed, which is one fewer name in the very table band
  D's `Hβ.infer.seq-op-signature-driven` exists to dissolve.
  ▶ THE GATE ORDER, because this was a refactor and not a feature. The
  behaviour was PINNED FIRST: the float-sentinel fixture exercises NaN,
  ±Inf and -0.0 — the four values float_to_str renders through a branch
  the digit path never touches — and measured exit=15 BEFORE the
  deletion, 15 after. Each sentinel is a BIT, so the exit code names
  WHICH branch broke rather than only that one did; the RED test
  (breaking the NaN literal) returned exit=11, naming that branch by
  arithmetic. Its first draft used `print`, which the armed
  E_MissingVariable refused — the medium correcting the fixture before
  the fixture could check the medium.
  ▶ THE SELF-BUILD CONFESSION, named not absorbed: no projection
  enumerates the names the lowering introduces, so this was a grep.
  `Hβ.query.desugar-introduced-names` is the missing facet, and it is
  the one that would make the sugar set a graph read rather than a
  literal scan — exactly the gap between the lower bound above and the
  proof demand-linking needs.

- 2026-08-17 · THE PROFILER REACHES THE SHIM, AND THE FLOOR HAS NO HOT
  SPOT (no pin — tools and docs only; boot unchanged at 42a4cc445d, src
  untouched, so the fixpoint stands and pin freshness holds).
  ▶ WHY A PROFILE AT ALL. Five probes across four pins each indicted a
  suspect and then cleared it: the discovery parse, the second read, a
  whole-program lex, the import fold's shape, and now inference (`fmt`
  0.833s ≈ `check` 0.780s on the floor fixture, re-confirming a reading
  from an earlier era). Elimination kept failing for one reason, and it
  took the instrument PLAN §8 names to see it: THERE IS NO HOT SPOT.
  ▶ THE PROFILE, 1,778 samples on tests/frontier/mn-bare-floor.mn:
  77.9% guest, and the guest side is FLAT — the top fourteen functions
  sum to ~22%, the largest single one being 7%. The composition is what
  matters: `list_index_unchecked` 7.05% · `list_filled_from` 3.34% ·
  `alloc` 2.49% · `list_set` 2.20% · `list_index` 1.34%, so 16.4% sits
  in LIST ACCESS AND ALLOCATION, spread evenly across lexing, parsing
  and judging — the hottest function's callers split three ways between
  `crc_scan` (1.73%), `lex_from` (1.18%) and `scan_to_eol` (1.06%).
  This is the mechanism behind the linear-in-source law the previous pin
  measured: per-line work is a fixed quantity of list operations, so the
  cost tracks lines and no pass can be blamed.
  ▶ TWO NUMBERS WORTH CARRYING FORWARD. String comparison — the
  `Hβ.perf.name-is-handle` target — is only 2.0% of the run
  (`str_eq_loop` 0.78, `str_eq` 0.69, `str_hash_loop` 0.52), which
  prices that peer far below what §5.O's text assumes; it should be
  built for the correctness and O(1) reasons it also carries, not for
  this. And `comment_refs_check` is 3.87% INCLUSIVE — the backtick judge,
  a prose gate, running inside `infer_program_final` on every compile.
  Named, not touched: it is user-facing (W_CommentRefUnresolved is their
  warning), so moving it is a diagnostics design decision, not a perf
  edit.
  ▶ THE SELF-BUILD HALF. Getting that profile meant hand-assembling the
  wasmtime command the shim already builds, because the canonical flags
  cannot express `--profile=perfmap` — the "ceremony one layer down"
  CLAUDE.md ⟳ calls a confession. `MENTL_WT_EXTRA` now appends
  word-split extra runner flags in wt-env.sh, so
  `MENTL_WT_EXTRA=--profile=perfmap perf record -g -- mentl check <f>`
  resolves guest symbols through the installed verb. Empty by default,
  so every gate and march runs byte-identical flags — verified both
  ways at this pin.
  ▶ THE STAMP IT PRICES lands in RESIDUE against
  `Hβ.driver.link-is-reachability`: semantics traced, costs priced
  (proportional saving, no pass to special-case), writers enumerated,
  and ONE unenumerated risk named as the next step — the SUGAR SET of
  prelude names the desugar introduces that source never writes
  (`++` → seq_concat, `xs[i]` → list_index, `<~` → FeedbackSpec,
  interpolation → to_string). Finite, enumerable from lower's dispatch
  sites, loud on a miss, and to be READ OFF THE ARTIFACT rather than
  guessed — which is a measurement, not a design choice.

- 2026-08-17 · ▶▶▶ COST IS A GRAPH READ, SO IT CAN BE RATCHETED — AND
  THE PREVIOUS PIN'S LAW IS RETRACTED (pin 42a4cc445d — CLEAN m2 == m3,
  re-pinned from m2 per march.sh, 412024 lines, census 0; m3 leg 18.68s
  wall · 2238MB peak RSS).
  ▶ THE RETRACTION FIRST, because the previous entry asserts it. That
  pin claimed THE COMPILE IS QUADRATIC IN MODULE COUNT, with a fitted
  `0.062·N + 0.0064·N²` and the env convicted. Its own named probe
  refuted it. Eight entries, N=6..54, DAG lines 6.3k..58k: canon 7 /
  6,299 / 0.77s · types 6 / 6,282 / 0.78s · effects 7 / 7,708 / 1.00s ·
  parser 13 / 14,156 / 1.91s · infer 18 / 25,534 / 3.67s · driver 20 /
  26,566 / 4.00s · lower 22 / 32,766 / 4.78s · main 54 / 57,968 /
  12.05s. Cost-per-LINE moves 122 → 208 µs (1.7×) where cost-per-MODULE
  moves 0.110 → 0.223 s (2.0×), so lines is the better predictor and the
  residual is ~O(n^1.06). The quadratic predicted `main` at 22.0s. THE
  COMPILE IS LINEAR IN THE SOURCE IT PROCESSES, ~150µs a line. The
  method lesson is the durable half: four points over a 3× range fitted
  a curve a 7.7× range destroyed — a fit is a hypothesis until it
  predicts a point OUTSIDE the range it was fitted on, and §5.O's
  measure-don't-read-code law now carries that corollary.
  ▶ THE BUILD. `mentl query <file> "cost"` reports modules linked,
  source lines processed, and nodes minted — the weave's own NModule
  cells and `graph_next()`, never a clock. That distinction is the
  point: a wall time is a HOST fact that varies per run, so it can be
  reported and never ratcheted, while these three are identical every
  run. `module_paths` from the previous pin became `module_cells`
  (path + span) with paths and the line extent as two projections of
  ONE walk, rather than a second walk for the second fact.
  ▶ WHAT IT MAKES POSSIBLE, which is why it was worth building: the
  frontier now holds the PRELUDE FLOOR as a contract.
  tests/frontier/mn-bare-floor.mn is a bare `fn main() = 7` whose whole
  cost — 7 modules, 6,304 source lines — is vocabulary the medium
  processes to answer nothing, and the leg refuses a RISE. Monotone
  down; what lowers it is `Hβ.driver.link-is-reachability`. Both halves
  seen RED: unknown-query against the prior boot, and the real 6,304
  against a deliberately under-set ceiling.
  ▶ THE FACET CONFIRMS THE CORRECTED LAW from an independent channel:
  10.7 · 11.7 · 11.7 · 12.2 nodes minted per source line across the same
  9× range. Node minting is linear in source, measured deterministically
  rather than through a clock.
  ▶ AND IT REFRAMES THE FLOOR HUNT'S TARGET. Five pins chased a constant
  inside the prelude. The number that matters is that a program of ONE
  DECLARATION costs 6,304 lines of vocabulary, and the sweep pays it 149
  times — ~940k lines re-derived for fixtures naming a handful of names.
  The levers, in order: demand-link the decls a program actually uses,
  then stop re-deriving identical vocabulary across processes
  (`Hβ.persist.module-image-cache` / the resident session). The per-line
  constant is third and worth least.

- 2026-08-17 · ▶▶▶ THE MEDIUM CAN SHOW ITS OWN DAG, AND THE HAND WALK IT
  RETIRED FOUND THE REAL LAW (pin 86ddf00ac4 — CLEAN m2 == m3, re-pinned
  from m2 per march.sh, 411660 lines, census 0; m3 leg 17.76s wall ·
  2225MB peak RSS). `mentl query <file> "modules"` projects the weave's
  module set from the NModule cells `driver_entry_with_ranges` already
  mints per range — the same cells `module_path_of_span` narrows by
  containment, read whole instead. A graph read, not a second walk of
  the filesystem. It was built because this iteration NEEDED the answer
  and could not get it: the driver proves the DAG on every invocation
  and could show it to nobody, so the question "which modules does this
  entry pull" was answered by a hand-written shell transitive-closure
  loop over `grep '^import'` — the confession the self-build ratchet
  exists to convert. Facet born RED against the prior pin (`error:
  unknown query: modules`); the frontier leg pins the count AND two
  named members, so it cannot pass on a number alone.
  ▶ WHAT THE HAND WALK MEASURED, which is worth more than the verb: cost
  tracks MODULE COUNT, not entry size, and not linearly. 17-line canon
  (7 modules) 0.75s · 3594-line parser (13) 1.82s · 890-line driver (20)
  3.47s · 6559-line lower (22) 4.48s — note driver costs nearly twice
  parser on a quarter of the lines. Per-module cost RISES with the
  count: 0.107 · 0.140 · 0.174 · 0.204 s/module. Fitting `a·N + b·N²` on
  the endpoints gives ≈ `0.062·N + 0.0064·N²`, which predicts parser at
  1.89s against 1.82s measured. THE COMPILE IS QUADRATIC IN MODULE
  COUNT, and at 22 modules the N² term is ~69% of the total.
  ▶ THE MECHANISM IS STRUCTURAL AND ALREADY NAMED: `driver_check_entry`
  runs `infer_program_converged` once per module, each against the
  shared env every prior module installed into. Env grows with N, so N
  lookups over an O(env) read is N². That is §5.O's `env_find_flat`
  class exactly, whose fix is `Hβ.perf.name-is-handle` (Phase 9.3) — a
  name interned once at lex, every compare an `i32.eq`, every table
  handle-keyed. This measurement is the first time the wheel's own
  per-invocation cost has been tied to that peer with a fitted curve
  rather than a code reading, which is the §5.O lesson (the 8-agent
  code-reading diagnosis missed the real dominant cost; perf found it).
  ▶ THE FLOOR HUNT ENDS HERE AND IS SUPERSEDED. Four pins chased 0.28s
  in a five-module prelude — not the parse, not the second read, not the
  lex, not the fold. The quadratic is the larger fact and it subsumes
  the search: the constant per module stops mattering once N² dominates.

- 2026-08-17 · ▶▶▶ ONE LEX PER COMPILE, AND TWO KILLS THAT COST MORE
  THAN IT (pin d74ba9612f — CLEAN m2 == m3, re-pinned from m2 per
  march.sh, 411335 lines, census 0; m3 leg 17.10s wall · 2135MB peak
  RSS). `infer_program_converged` ran `src |> frontend` twice and
  `frontend` is `source |> lex |> parse_program`, so every compile lexed
  the entire concatenated program twice — 57,881 lines of it on the
  wheel's own self-compile. The two PARSES are load-bearing and stay:
  the final walks a FRESH generation of nodes, which is exactly what
  `pstart = graph_next()` reads as its lower bound, so parsing once and
  judging one tree twice would collapse the boundary the tower is built
  on. The two LEXES never were — a token is a value, it mints nothing.
  This is NOT an improvement to the condemned tower (Anchor 2): its
  judgment, its cadence and its two generations are untouched, and when
  rung 3 deletes the second pass this seam loses a caller rather than
  needing unpicking.
  ▶ KILL ONE: lex is not the floor. Deleting a whole-program lex moved
  the fixture 0.00s — seven settled reads at 0.78s median, the same as
  the pin before it. The deletion is kept because it is one, not because
  it paid.
  ▶ KILL TWO, and it kills the previous pin's own conclusion: the 0.28s
  discovery floor is TRAVERSING the module's tokens, and not the shape
  that traverses them. A probe replacing `import_edges`' body with a
  literal list measured 0.50s against 0.78s — the whole floor. So the
  fold was rewritten as a position recursion, allocating on the four
  import hits instead of a product per token, and it measured
  IDENTICAL. The cost is the walk itself, roughly 11µs per token over
  ~25k tokens, which is a substrate signal about traversal rather than
  anything to do with imports. The position form was REVERTED: its only
  justification was a speedup that did not exist, and §11's own test
  says a change justified by a number the number refutes is the wrong
  change. The fold stands because the law prefers it.
  ▶ WHAT THE THREE PINS TOGETHER NOW SAY, since each killed the next
  one's premise: it is not the parse (pin b50cdd0c), not the second
  read (pin ef57c6e6), not the lex, and not the fold. It is per-token
  traversal cost, and `mentl check` additionally runs
  `infer_program_converged` once per module through `driver_check_module`
  on top of the entry's own — two parses and two judgments of the whole
  prelude per module. RESIDUE names both and the next probe measures
  traversal directly before anything else is built on a guess.

- 2026-08-17 · ▶▶▶ THE DAG CARRIES WHAT THE WALK RESOLVED — AND THE
  MEASUREMENT REFUSES TO CONGRATULATE IT (pin ef57c6e6a6 — CLEAN
  m2 == m3, re-pinned from m2 per march.sh, 411331 lines, census 0; m3
  leg 17.25s wall · 2236MB peak RSS). The DAG element was the module
  NAME, so four consumers re-derived everything else BY NAME — the
  canonical sort key re-resolved the path, the compile fold re-resolved
  it and re-read the file, the tree scan did both and re-lexed for its
  imports, and `driver_module_in_dag_deps` did all three a third time.
  Path resolution is up to five `fs_exists` probes, so a five-module
  prelude paid dozens of stat calls and read and lexed every file twice
  in one compile: the canonical re-derivation, a name followed where the
  walk had already drawn the edge. The element is now
  `(name, path, source, imports)` behind four projections,
  `driver_module_in_dag_deps` is deleted whole, `driver_module_order_key`
  takes the carried path and loses `Filesystem`, and a missing module
  carries `None` rather than a `""` sentinel a consumer has to recognize.
  ▶ THE PROBE THAT NAMED IT, and what it actually said. Banked as the
  next probe last pin: hold the DAG identical and remove only the
  discovery read+lex. Measured 0.46s against 0.74s — the discovery pass
  is 0.28s, 38% of the floor. But that pass reads COLD, and the read this
  landing deleted is the SECOND one, warm in page cache. Deleting the
  cheap copy while keeping the expensive one, plus whatever the new
  element costs, measures 0.74s → 0.78s: a 5% REGRESSION, five settled
  reads, NOT isolated to a cause. Sweep wall unchanged at 297.64s, 368/0.
  ▶ THE FORM STAYS, per CLAUDE.md ⟐ — a just-built ultimate form that
  fails is the instrument finding the next non-ultimate fundamental, and
  retreating from it because a stopwatch disagreed with a law is the
  hedge the anchors forbid. §11's own test is the arbiter and it cuts
  this way: a change justified by a NUMBER that the number refutes is
  wrong, but this one is justified by the Carried-Truth Law and deletes a
  whole function to obey it. What the numbers now name precisely is the
  next build: the floor is the LEX, performed twice on every module in
  one compile, and ~0.28s of the 0.74s is the copy nobody needs. The
  walk lexes; the judging pass concatenates the sources and lexes the
  same bytes again. Carrying TOKENS instead of source deletes that, and
  the element this pin built is what carries them — its DEP is the span
  coordinate space, because per-module token streams are file-local
  while the weave is concatenation-relative (`driver_entry_with_ranges`
  already computes exactly that mapping).
  ▶ THE QUIET GATE REFUSED ALL FIVE `ref` MARKERS this landing authored,
  and dropping them left the emit BYTE-IDENTICAL — same sha, same 411331
  lines — so the inference held every borrow already and the annotations
  were noise. That is twice in two pins, and it is §4⑤'s bar measured
  rather than hoped: if the developer has to think about ownership the
  inference failed, and it has not.

- 2026-08-17 · ▶▶▶ THE DEP WALK STOPS PARSING, AND THE THEORY THAT SENT
  IT THERE DIES (pin b50cdd0c55 — CLEAN m2 == m3, re-pinned from m2 per
  march.sh, 410658 lines, census 0; m3 leg 15.78s wall · 2249MB peak
  RSS). `driver_collect_visit` ran a full `lex |> parse_program` on every
  module in the DAG, read its four import strings off the top, and
  dropped the tree — which the pass that actually judges the module then
  built again. That is the carried truth discarded and re-derived, and
  the private graph instance the discovery parse needed existed only to
  contain mints from a tree nobody kept (unbracketed they entered the
  live weave as a second generation and the duplicate holes reached the
  position enumerators). An import is a LEXICAL fact — `import a/b` is
  TImport followed by its segments, and TImport appears nowhere else,
  the word inside a string lexing as that string — so `import_edges`
  (parser.mn, beside the `parse_import_path` it reuses) reads the edges
  from the token stream. No tree, no mints, no instance to bracket; the
  isolation went with the parse it isolated, and
  `driver_extract_imports_from_ast` was deleted rather than left.
  THE MEDIUM THEN PRICED THE CONSEQUENCE ITSELF: six dep-walk rows
  measured over-declared and tightened to exactly what their bodies use
  — `driver_collect_dag`, `_visit`, `_visit_list`, `driver_tree_scan`,
  `_dag_with_deps`, `driver_module_in_dag_deps` all dropping
  ImageAlloc + EnvRead + GraphWrite + Mutate + Cast + WASI — and two of
  them now PROVE `!Diagnostic`, which is the absence their own comment
  had claimed in prose since the walk was written ("the per-module check
  will surface E_MissingModule"). The row states it now, so a future
  report there is a refusal instead of a surprise. Six schemes stopped
  diverging trial-to-final as a result (movers 475 → 469): the
  divergence did not relocate the way the entries above it measure, it
  WAS the over-declaration. The quiet gate then caught the one marker
  this landing tried to author — `ref` on import_edges, where the
  use-count already derives the borrow — and refused it, which is the
  ratchet doing precisely its job on the hand that set it.
  ▶ THE KILL, banked because it is worth more than the landing: the
  theory that sent this dig — that the discarded parse was the prelude
  seed's 0.68s cost floor — is REFUTED. Same bare program, three reads:
  0.74s against the 0.71s baseline. FLAT. Removing one of two parses
  moved nothing, so the floor is not parse-dominated, and the header
  index the banked `Hβ.driver.link-is-reachability` design called its
  prerequisite is NOT one. Decl-level demand belongs at the JUDGE stage,
  where every decl name is already in hand from a parse that has to
  happen anyway. The deletion stands on its own terms — a tree and its
  mints per module, gone, and the rows exact — but it bought no time and
  this entry does not pretend otherwise. Next probe named in RESIDUE:
  split lex from infer on the seed path, because "not parse" is not yet
  "which".

- 2026-08-17 · ▶▶▶ THE PIN CATCHES UP, AND FOUR EXPECTATIONS CATCH UP
  WITH IT (pin 011f0eefbf — CLEAN m2 == m3, re-pinned from m2 per
  march.sh, 410798 lines, census 0; m3 leg 17.83s wall · 2301MB peak
  RSS): `Hβ.march.boot-drifts-behind-clean-landings`, and the shape is
  worth more than the fix. A CLEAN verdict (`m2 == m3`) means a landing
  is correct and needs no repin — so several in a row correctly took
  none, and boot sat at `5fe06c92` while source moved four landings
  past it: the statement-span/dispatcher mint, the cursor declaration
  projection, the skip_ws_back dissolution, the feedback row join.
  Every gate in the frontier's BOOT suite reads that artifact, so the
  board went on printing `frontier 367/0` about a wheel that no longer
  existed in source. §11 tripwire 4 says a gate that stops being
  reported stops being run; this is the worse sibling — a gate that
  keeps being reported GREEN while measuring something stale, which
  reads as evidence rather than as silence.
  THE INSTRUMENT WAS ALREADY THERE, which is its own small lesson: the
  previous iteration reverted a pin to observe the reds, when
  `frontier-gate.sh --compiler fresh` shows them against current source
  without touching boot at all. The banked probe said "repin, then
  derive"; the repin was never needed to derive.
  ALL FOUR REDS HAD ONE CAUSE, AND IT WAS NOT THE ROW JOIN. The
  dispatcher mint starts a declaration's span at its `fn` KEYWORD, where
  `parse_fn(tokens, pos + 1)` used to start it at the NAME. Measured
  side by side on the same fixture: boot `at 3:4-3:24`, fresh `at
  3:1-3:24`. The mcp propose fixtures contain no `<~` at all, which is
  what exonerated the row join in one cheap read rather than a rebuild.
  Re-banked under §9.11 — a banked expectation is a hypothesis about the
  era that banked it — after deriving each by hand: `at 3:4` → `at 3:1`
  (mcp refusal), `at 10:4` → `at 10:1` (own-unconsumed), `Query: double`
  → `Query: fn double` and `Query: main(` → `Query: fn main(` (the
  resident and living session legs, whose Query line now carries the
  whole declaration — `Query: fn double(x) = x * 2 : (x: Int own —
  inferred) -> Int` — where it used to carry the bare name).
  With the pin caught up, the feedback-negation leg is wired: the `!E`
  crucible that laundered a forbidden effect through a `<~` cycle now
  refuses, on the pinned boot, permanently.

- 2026-08-16 · ▶▶▶ THE DEMAND ANALYSIS LOSES ITS CONCAT SPINE
  (pin 5fe06c927b — TRANSITION, m3 == m4, re-pinned from m3 per
  march.sh, 410181 lines, census 0, crown 39/0, frontier 364/0,
  proof-exactness 9/0, effect-identity green; m3 leg 17.91s wall ·
  2401MB peak RSS):
  `spec_candidates_fix` accumulated its accepted set onto `[d] ++ done`,
  and both reads it makes of that set index it: membership by mangled
  name, and the per-base count the polymorphic-recursion cap meters.
  `list_index` on a concat spine is O(depth), so each read walked a
  structure whose indexing was itself linear, and the transitive closure
  paid that once per accepted candidate. `spec_base_count` alone
  measured 7.95% of the self-compile; `spec_rec_name_seen` 5.41%. The
  buffer-counter replaces the spine (`make_list(64)` plus a count, which
  is `reach_grow`'s own shape and this codebase's standing answer to the
  class), and the accepted set's three operations get one home:
  `spec_demand_accept` appends at the count, `spec_buf_demanded` and
  `spec_buf_base_count` walk the flat slots directly. Seven
  worthiness-gate fns went with it, dead since 5.1a made twinning total
  by candidacy: `spec_ophs_sensitive`, `spec_interior_names`,
  `spec_oph_wide_pair`, `spec_tuple_elem_wide_pair`,
  `spec_ty_needs_structure`, `sum_has_payload`, `spec_base_count`. The
  round-invariant facts channel they fed went with them, so the fix now
  returns the accepted buffer sliced to its count and nothing else. Net
  −47 lines. Two ratchets fell and were held: movers 476 → 475, and
  effectful-lambda 385 → 384, because the deleted witness carried
  `any((e) => spec_tuple_elem_wide_pair(e, pairs), es)` and the
  conviction died with the code rather than by a rename. THE PIN'S OWN
  LESSON, paid at this entry: the board block was written with crown,
  frontier, proof-exactness and effect-identity all reading NOT RUN, and
  doc-truth refused the tree until this line existed. All four were then
  run at this same sha and are green above. The coupling caught an
  unblessed pin exactly where Phase 0.1 said a gate that stops being
  reported stops being run.

- 2026-08-12 · ▶▶▶ CONSTRUCTION IS REACHABILITY (pin 73d3a124ce —
  TRANSITION, m2 ≠ m3 by 26 diff lines and m3 == m4, census 0, crown
  39/0, frontier 364/0, proof-exactness 9/0; m3 leg 16.47s wall ·
  2395MB peak RSS): the enumeration-reader relocation,
  `Hβ.lower.lowering-is-a-column`. The deleted `build_reach_index`
  answered "what does NAME reference?" by walking trees that had ALL
  been constructed up front — every decl lowered, then a second pass
  asked which ones mattered. The demand worklist inverts it: a name
  popping from the frontier CONSTRUCTS its decl, and the constructed
  body IS the edge list, read once. A lower-minted reference exists
  exactly when its parent constructs; a dead decl never constructs at
  all, so emission and reachability agree by construction instead of by
  two passes kept in sync. `lower_program` becomes its pre-passes and
  the program flows on. The written decisions held: container-keep is
  reproduced at the name map (every arm name keys its WHOLE container
  stmt), emission is source order from the stmt list — never the demand
  order the worklist drains in — and a no-main library seeds ALL decls
  rather than narrowing (narrowing would shift the installed-effect
  census on programs that compile today). The build's own find, caught
  as an undefined-`$int_to_str` assembly break in the interp micros:
  `show_subtys` collected a `[Byte]` leaf no render surface can call, so
  the minted body's interior dangled once the worklist stopped flowing
  dead-decl seeds — the collector now reads the same fact the dispatch
  reads. Four fixtures pin the decisions (library-whole, emission-order,
  container-keep, hole-dead-block). THE GATE'S OWN BUG, measured at
  absorption: the library leg reported RED while printing alpha=1
  beta=1 — `printf` piping 800KB into `grep -q` lets grep exit at its
  first match, the writer takes SIGPIPE, and under `set -o pipefail` the
  condition reads false. The leg now writes the wat to a file and greps
  the file, which is the idiom every other wat-scale leg in that gate
  already used; the class has exactly one other member: none.

- 2026-08-12 · THE GATE AGREES WITH ITS PARSER (pin d149cd6976 — CLEAN
  m2 == m3 in one generation, census 0, battery green with the new micro
  at 44): `Hβ.parser.named-fn-tuple-param` RESOLVED. SYNTAX §Pattern
  syntax has always said patterns appear in function parameters; the
  lambda half ran while `fn f((a, b))` refused at the `)` and the `=`.
  The dig's one find: the machinery was WHOLE and its own gate strangled
  it — parse_one_param's destructure arm (parse_pat → fresh param +
  prepend-let → bind_param_destructures, the identical projection the
  lambda path folds through) was dead code, because param_starts_here
  admitted only TIdent/TOwn/TRef, so a pattern opener fell into the
  bare-own/ref bail and skip_to_rparen ate to the INNER `)`. The fix is
  three arms in one predicate (src/parser.mn param_starts_here:
  TLBrace/TLBracket/TLParen → true) — no second mechanism, no infer
  change, the desugar shared with lambdas by construction. Parity
  measured BEFORE the fix through boot's lambda path (tuple 7 / record 30
  / exact-length list 7); tests/micros/mn-fn-tuple-param.mn (expect 44 =
  7+30+7) SEEN RED against the unfixed boot (refusal, six undischarged
  claims, zero WAT), green through the repinned wheel. Boundary measured:
  own/ref before a pattern opener still terminates the list (seed parity)
  and refuses loudly via recovery holes — zero-WAT, never a silent
  mis-bind. Banked follow-up: the wasm.mn:1438 `((h, depth))` call-site
  lambda — the fold this refusal once forced — unfolds back to a named
  projection; the anonymity ratchet holds meanwhile.

- 2026-08-12 · ▶▶▶ AN INSTANCE ARGUMENT HAS AN IDENTITY
  (pin 42aeaf0739 — CLEAN m2 == m3, re-pinned from m2 per march.sh;
  census 0, crown 39/0, verify green, m3 leg 19.19s wall · 2310MB
  peak RSS inside the ceiling; the fixpoint held one-generation
  exactly as the wheel-clause census predicted). Effect-instance identity completed in three
  pieces, one registration fold. EffArg grew `EAEffect(Int)` (an
  EFFECT standing at an instance-argument position — the intern handle
  ENamed carries; handle inequality IS value distinctness) and
  `EACon(Int)` (a NULLARY ctor — its intern handle; two distinct
  constructors are distinct values unconditionally, so the word needs
  no type identity beside it). `resolve_declared_instances` folds each
  authored bare-ident arg at infer's declared-row gate — the one
  env-whole deterministic point; NOT build_row_seen, which the parser
  calls at parse time where an env leaf would make the row a function
  of parse order (4.2's disease) — EffectDeclKind → EAEffect, nullary
  ConstructorScheme (TName scheme-result) → EACon, all else the
  conservative EANode arm untouched (leak-instance-node holds). The
  algebra's two halves each grew the word-compare arms
  (eff_arg_scalar_unequal / frag_args_same_walk), the pin takes the
  folded constants exactly as scalars, and the walks carry them as
  the inert identities they are. RED-first: sound-instance-ctor-
  distinct + sound-instance-effarg-distinct born RED at mismatch=1
  (the conservative over-refusal RESIDUE measured as `!Flow(Sec,
  Wasi) + Any vs Flow(Sec, Store)`), green under the fold; the two
  leak-* guards never flipped. THE ADJACENT KILL fell out at zero
  extra mechanism: absent_contradicted_by was always instance-aware —
  EANode conservatism alone defeated it — so `Flow(1, Store) +
  !Flow(1, Wasi)` keeps its severance as a refinement while the
  same-instance clause still refuses
  (mn-instance-refinement-clause, born RED at 2 reports, exactly 1
  under the fold; the frontier's instance-refinement leg). One
  ratchet catch mid-landing: the fold's map lambda judged effectful
  (387→388) and the tier's own teaching named it
  (resolve_instance_triple). The wheel authors no capitalized
  bare-ident instance arg, so the fold is judgment-neutral on its own
  source — the one-generation fixpoint is the prediction confirmed.
  D1+D2 of the flowlabel sink chain are un-gated; the fn-TYPE
  with-row's EANode conservatism and W23's compound-constant reach
  stay the named remainder (RESIDUE effarg-node, the one home).
- 2026-08-12 · ▶▶▶ THE THREE-WORKTREE UNION (pin d4242c5c733b — CLEAN
  m2 == m3, census 0, battery green, crown 35/0, frontier 361/0,
  proof-exactness 9/0; the orchestrator's own re-derivation after the
  splice): the day's parallel fleet joined on one tree — the delay
  line (pin 1a1f545f in its worktree), the peel fix (the rec-call IH
  real, the late-rebind machinery deleted), and the relocation's four
  pre-landings (the handler stack in every compile chain — six, not
  four, measured; the emitfn index carrying coverage instead of a
  latch; the decls column taking every declaration; main's arity from
  its decl). Each landed CLEAN in its own worktree under the
  owner-enforced heavy lease; each rebased onto the moved main; the
  union pin is the merged tree's own fixpoint, re-derived by the
  orchestrator — nothing blessed on a builder's word. The fifth
  pre-landing refuted with its law banked (a module aggregation is
  dual-runnable only if every node it visits exists before emit);
  the flowlabel and repr briefs refuted-by-measurement in the same
  fleet cycle, their kills and corrected designs banked in their
  entries.
- 2026-08-12 · ▶▶▶ THE DELAY LINE IS AS DEEP AS IT SAYS (pin 1a1f545f0e0b
  — CLEAN m2 == m3, 408963 lines, census 0, crown green,
  proof-exactness green, 22.35s wall · 2397MB peak RSS inside the
  ceiling). `delay(3)` had been emitting the one-slot register `delay(1)`
  emits — the authored depth reached no reader at all, so a developer
  asking for a three-sample delay silently got one. The probe that opened
  this at the causality landing said it plainly: `delay(0)`, `delay(1)`
  and `delay(3)` each returned 30.
  **THE READ IS ONE PROJECTION WITH THREE ARMS.** `feedback_depth`
  (infer.mn) answers `DepthLiteral(n)` / `DepthComputed` / `DepthUnstated`
  off the authored RHS — the same read `feedback_declares_zero_delay`
  was doing for one value, generalized to the value itself. The causality
  refusal became one arm (`n <= 0`, widened from `n == 0` so a negative
  literal cannot size a line either); lower's `feedback_line_depth` takes
  the slot count from it and carries it on `LFeedback(h, DEPTH, body,
  spec)`; the emit declares the line from that number and shifts it by the
  same. One number, two readers, so a line can never be emitted deeper or
  shallower than it is declared — which is the whole bug, stated as a
  structure that cannot hold it.
  **THE LINE IS A REGISTER FILE, NOT A RING.** `$s<h>` (newest) through
  `$s<h>_<N-1>` (oldest), globals declared at module init; the prior is
  the OLDEST slot — y[n−N] — and each tick advances every slot by one,
  deep end first so each read precedes its own overwrite. The shift pairs
  come from reversing the line and zipping it against its own tail: the
  walk is the line's shape, not an index countdown. Zero allocation, so
  `!Alloc` survives at any N, and `state_slot_globals` is the ONE
  projection both the plain module path and the image substrate read, so
  the two can no longer disagree about which slots exist or how wide they
  are (a persisted image now carries the whole line, not its newest slot).
  **DEPTH-1 IS BYTE-IDENTICAL BY CONSTRUCTION** — a one-slot line has no
  `_i` names and no pairs to shift, so eleven `delay(1)` sites and five
  `accumulate` sites crossed untouched and the march ruled CLEAN rather
  than TRANSITION. Predicted before the run from the emit's own shape,
  then measured.
  **THE SILENT WRONG IS CLOSED AT BOTH ENDS.** A computed depth cannot
  size a static line, and quietly giving it one slot is the same betrayal
  in a new costume, so `E_ComputedDelayDepth` is ARMED at birth — the
  TWELFTH refusing class, on the same literal licence its sibling rides.
  Census at arming: 0, measured across src/, lib/, tests/ and examples/
  (every `delay(...)` in the tree is a literal).
  **BOTH GATES SEEN RED FIRST.** mn-delay-depth exits 66 at the parent pin
  — the 3-deep site answering 6, identical to the 1-deep — and 62 after,
  the value derived by hand from the recurrence before the build (y = 1,
  1, 1, 2, 2, 2 under `delay(3)`; 1..6 under `delay(1)`) and confirmed
  independently by a hand-written WAT probe of the shift before a byte of
  the emit was trusted. mn-refuse-computed-delay ran clean at exit 10 with
  zero diagnostics before, refuses after.
  **THE RATCHETS, MEASURED ON BOTH TREES.** movers 476 → 478 and
  effectful lambdas 385 → 387, each re-based in verify-baseline with its
  reason. The movers rise is the condemned pass's documented relocation,
  established here by building the pre-change tree in the same session:
  the named mover set and its A/B fingerprints are BYTE-IDENTICAL across
  the two builds, so nothing new diverges — two existing schemes joined
  the tail when infer.mn's decl order shifted. The anonymity rise is two
  emit callbacks whose remedy is blocked by measured lathe-lag, now
  named: a NAMED fn cannot take the tuple-pattern parameter SYNTAX
  promises (`Hβ.parser.named-fn-tuple-param`), and partial application —
  which SYNTAX calls a first-class value — checks clean then emits a
  `return_call` with mismatched arity that wat2wasm refuses
  (`Hβ.emit.partial-application-arity`). Either landing retires both
  convictions without renaming a lambda. The third callback took the
  tier's own remedy: the shift step is the named `emit_shift_pair`.
- 2026-08-12 · ▶▶▶ MAIN'S ARITY COMES FROM ITS
  DECL (pin f5b8548875ad — CLEAN m2 == m3, 408296 lines (125 fewer, the
  deleted fold), census 0, frontier 361/0, peak 2358676KB inside the
  ceiling). The relocation arc's fourth pre-landing: three tree-reading
  seeds were listed for re-rooting; ONE re-roots, and the other two are
  banked with the measurement that refuses them.
  **RE-ROOTED — `main_param_count`.** It folded the lowered tree matching
  TWO decl shapes, a plain `LDeclareFn` and the `LLet`-wrapped closure the
  wheel's own main takes; matching only the first once dropped _start's
  argv arg and broke the m3 assemble. The whole hazard is a tree-shape
  hazard, so the fix is to stop reading shapes: fold the DECLS COLUMN,
  read main's authored `params` off its FnStmt node. Both call sites drop
  the `lowered` argument, and the read is the relocation's own reader
  shape — a column, no tree.
  **THE MEDIUM'S OWN RATCHET FORCED THE BETTER FORM.** The first attempt
  read main's TFun from the env and needed a `_ => 0` arm for a `main`
  bound to a non-function. Verify's drift-shape tier convicted it —
  wildcard-zero 9 → 10 — and refused. The column form needs no wildcard
  at all (`_ => acc` is the fold's identity), so the ratchet did not
  merely block a regression; it named a form that was strictly better,
  and it depends on the decls column the previous landing grew.
  **BANKED, NOT FORCED — the other two fail the tree-free test, each for
  its own reason.** `collect_top_value_lets` returns `(name, init)` and
  the init is a LOWERED expression `emit_init_lets` emits; the SET could
  re-root on the program, but the PAYLOAD cannot while the tree is the
  emission source, so splitting them today buys a lookup the relocation
  deletes — the (β)-class machinery this arc's own stamp warns against.
  `spec_reach_seed` deep-walks `spec_scan_expr` for WIDE instantiation
  sites, which are repr-keyed lowering facts and not program facts at
  all; its honest form is a per-entry accumulator (the next pre-landing's
  class), never a seed re-root.

- 2026-08-12 · ▶▶▶ THE DECLS COLUMN TAKES EVERY
  DECLARATION (pin 18ce91606de8 — CLEAN m2 == m3, 408421 lines, census 0,
  frontier 361/0, peak 2359364KB inside the ceiling). The relocation
  arc's third pre-landing, and the first whose stamped premise was
  wrong.
  **THE PREMISE REFUTED.** The pre-landing was scoped as "zero new
  readers — Law-7 vocabulary". `decls_col` has a live reader:
  `decl_handles()` (query.mn), and it feeds TWO surfaces — the `decls`
  query facet the frontier pins, and `project_queue()` (oracle.mn:197),
  which maps `candidates_at` over exactly those handles. Every write to
  this column is a PROPOSAL POSITION. The dual-write pattern the other
  step-(i) columns use does not apply here.
  **WHAT LANDED ANYWAY, and why it is the honest form.** `graph_decl_note`
  fires from `infer_fn`, which nested `fn` declarations reach too — so
  the column was never top-level-only, and "fn-only" was the incomplete
  state rather than the contract. The let and handler-decl arms of
  `infer_stmt` now note at the same altitude: an arm is an emittable
  entry whose lower-composed name cannot be parsed back to (handler, op),
  so its origin is its handler decl's node; a module value binding is an
  entry through `__init_lets`. `decl_handles()`'s own comment carried
  "the judged fn-decl handles" and is corrected.
  **BOTH READER SURFACES MEASURED, not argued.** The decls fixture holds
  three fn decls and no handler or let, so the facet leg is untouched —
  frontier 361/0. The oracle self-test was run on this tree AND on the
  landing-2 tree with the change stashed: identical classification counts
  (assemble-fail 1, clean-run 2, refuse-unfilled 2, runtime-trap 1) and
  the same single CHANGED skeleton (s02_float_arith, expected edit-trap,
  got refuse-unfilled) on both. That drift is PRE-EXISTING and is named
  here rather than absorbed — the self-test is outside verify and march,
  so nothing was watching it.

- 2026-08-12 · ▶▶▶ THE EMITFN INDEX CARRIES ITS COVERAGE, NOT A
  FLAG (pin 6b9b08724830 — CLEAN m2 == m3, 408395 lines, census 0,
  frontier 361/0, peak 2359396KB inside the ceiling; every other ratchet
  unmoved). The relocation arc's second pre-landing. `graph_emitfn_at`
  built its by-name index at first demand and latched `emitfns_idx_built`;
  `graph_emitfn_note` kept appending without touching it, so every note
  after the first read was invisible. Today that is unreachable — and the
  measurement proves it rather than assuming it: `graph_emitfn_at` has
  ZERO call sites, in the medium's own refs answer and in the raw text
  both, because the enumeration is step (i) vocabulary, dual-written and
  zero-read. Under the emit-time worklist the interleave is the normal
  case, so the latch had to go before the first reader arrives.
  **THE FIX IS A COUNT, NOT A BOOLEAN.** `emitfns_idx_covers` is the
  column length the index was folded from. Equal means whole; shorter
  names exactly the suffix to fold in, and `emitfns_index_build` already
  took a start offset, so the one-time build became an extension with no
  new machinery. Rebuild-on-miss was refused as the alternative: a miss
  cannot distinguish absent from stale, so it re-derives on every absent
  name — Law 1 violated at the read.
  **THE BUILD REFUTED ITS OWN FIRST FORM, and the ratchet is what caught
  it.** Seeding the state with `emitfns_idx = smap_new()` read as free —
  `list_filled(4096, [])` is one 16KB table. The peak ratchet refused the
  repin at 2551504KB and again at 2470668KB against a 2470000 ceiling,
  both above the prior tree's whole band (2358596/2446768). The root:
  `graph_handler` installs ONCE PER JUDGED DECL (the layer sweep's
  `spawn_task(... ~> graph_handler(...))`, infer.mn:2263), so anything
  eager in its state init multiplies by the decl count — ~+100MB
  measured. The table now stays the empty `[]` until a read demands it,
  and the peak returned to 2446668/2359396, inside the prior band.
  Banked as a standing law for this file: state-init cost in
  `graph_handler` is per-decl cost.
  **A COMMENT CORRECTED IN THE SAME PASS.** The arm's prose claimed "the
  synthesized-family repr read and the enumeration reader resolve entries
  without the quadratic column scan" in the present tense against zero
  readers. It now says what the read is FOR.

- 2026-08-12 · ▶▶▶ THE LOWER-HANDLER STACK MOVES TO THE COMPILE
  CHAIN (pin db7d3d360883 — CLEAN m2 == m3, 408373 lines, census 0, peak
  2446768KB inside the 2470000 ceiling; every ratchet unmoved, movers 476). The first
  pre-landing of the enumeration-reader relocation, and it exists because the
  relocation stamp's "the projectors are callable from emit BY CONSTRUCTION"
  was false: `lower_handler_stack_ctx` installed around `lower_stmt_list`
  INSIDE `lower_program` (lower.mn:5033), so its capability ended where
  lowering ended. When construction relocates to emit time, a body projected
  from columns performs the frame fence with no handler in reach.
  **THE CENSUS FIRST — six chains, not four.** `compile_remainder` has four
  callers (pipeline's `compile`, `resume_image`, `compile_stdin`,
  `compile_source`), but `lower_program` has THREE call sites — pipeline:455
  plus main:1691 (`battery_compile`) and mcp:117 (`mcp_judge`), each its own
  full chain. Six installs, one deletion.
  **THE BALANCE, VERIFIED BEFORE THE MOVE** (the claim the widened extent
  rests on): six push references and six pop references, every pair
  straight-line — the PTee arm (2508/2513) and the five frame-fence sites
  (878/880, 912/926, 945/951, 3785/3813, 4362/4386). Nothing branches
  between a push and its pop, and `lower_handler_pop` on an empty stack is
  already a no-op, so the stack is empty at every decl boundary and a chain
  install sees exactly what the inner one saw.
  **PLACEMENT IS FREE, AND MEASURED SO.** All six references to the three
  ops live in lower.mn; none sits in a chain handler's arm, so no ordering
  constraint arises from the arm-performs-resolve-outward law. The handler's
  own arms perform only substrate Memory/Alloc, which no chain handler
  catches (`emit_memory_bump` handles `EmitMemory`, not `Memory` — checked,
  not assumed). It lands beside `lower_scope`, with the lower-phase cluster,
  where `arm_state_ctx` already sets the precedent of a chain install
  alongside nested ones.
  **NO ROW CASCADE.** The prediction was a widening sweep through the lower
  call graph; the measurement was zero — `lower_program`, `compile_remainder`
  and the walk beneath them declare no rows, so the effect crossed the whole
  remainder without a single authored clause to widen. Law-7 byte-identical,
  as a pure extent change should be.

- 2026-08-12 · ▶▶▶ THE CAUSALITY REFUSAL LANDS AND PHASE 3.6's MEMBERSHIP
  DESIGN DIES TO ITS OWN CONTROL (pin fc93f1957fb9 — CLEAN m2 == m3,
  408298 lines, census 0, frontier 361/0, crown green, peak 2359448KB
  inside the ceiling). Two kills first, both pre-build, both from the
  artifact:
  **KILL 1 — the banked Iterate-class predicate.** `Hβ.dataflow.feedback-becomes-whole`
  had membership = "any of the effect's ops has joined resume discipline
  MultiShot", derived from §4④'s one-primitive unification. The badges
  refute it: `choose : Choice op — resume t ->* answer` is the ONLY
  MultiShot family on the wheel, while `tick`, `advance_sample`,
  `sample_rate`, `current_sample`, `yield`, `result` and `iter_context`
  are all `->1`. A clock handler advances state and resumes ONCE per
  tick — the iteration is the CALLER's loop, not multi-resumption — so
  cardinality cannot be the class discriminator, and the predicate would
  have fired E_FeedbackNoContext at all thirteen wheel `<~` sites. Two
  of those thirteen (bandpass_step's four, ic_compile_loop's one) declare
  no row at all, so no ambient-row reading saves them either.
  **KILL 2 — the reverse-edge prerequisite had no referent.**
  `register_effect_ops` already env_extends the effect name with
  `EffectDeclKind(op_names)` at the same one writer that draws op→effect;
  `mentl where`'s handler-covers badge already reads it. The banked smap
  would have been a second copy of an edge the graph draws.
  **WHAT LANDED.** `E_ZeroDelayFeedback` — the causality rule at Mentl's
  typed altitude, armed at birth (the literal licence: the depth is read
  from the authored `delay(<int literal>)`, no resolution dependency,
  wheel census 0). `feedback_declares_zero_delay` reads the RHS call's
  callee name and first argument at the PFeedback arm, the same read
  `predicate_flow_label` makes at the same altitude; both `delay(0)` and
  `Delay(0)` convict, a computed depth answers false rather than guessing.
  **THE PROBE THAT PAID FOR ITSELF.** `delay(0)`, `delay(1)` and
  `delay(3)` all returned 30 — the authored depth reaches no reader at
  all, so `delay(3)` silently gives a one-sample delay. Banked as
  `Hβ.dataflow.feedback-delay-depth-unread`; the refusal becomes one arm
  of that read when it lands.
  **THE DIG'S REAL LESSON, closed in the same commit.** The detector
  "would not fire" for an hour: it fired on the wheel (census 5 under a
  deliberately over-firing probe build) and never through `mentl check`.
  The installed shim hardcodes `MENTL_HOME` to the repo it was installed
  from, so in a worktree every `mentl` verb judges with MAIN's boot —
  and verify.sh's contract-battery leg shelled out to exactly that,
  while every sibling leg reads `$C/m2.wasm`. The leg now reads the
  wheel the gate just built. A gate that judges with someone else's
  compiler is the Carried-Truth Law at the scaffold.

- 2026-08-12 · ▶▶▶ op_resume_discipline MOVES TO THE ENV ALTITUDE — Phase
  3.6's first prerequisite (pin 7260286fcd68 — CLEAN m2 == m3, 407922
  lines, census 0, frontier 361/0, peak 2357356KB inside the ceiling).
  The projection of an env entry belongs beside the entry: the fn read
  `env_lookup(op_name)` and pulled the discipline off EffectOpScheme's
  fourth field while living in lower.mn, so any other reader had to
  import the whole backend to ask a question about a name. It lands in
  src/env.mn with the resolve family; lower keeps its seven call sites
  through a new `import env`. Byte-identical by construction — a
  relocation moves no judgment — which is why the march ruled CLEAN
  rather than TRANSITION.

- 2026-08-11 · ▶▶▶ THE EMITFN BY-NAME READ — THE INDEX MATERIALIZES AT
  DEMAND (pin fe4b88b2f1be — CLEAN m2 == m3, census 0, battery green,
  peak 2451136KB inside the ceiling): graph_emitfn_at lands as the
  enumeration's identity projection beside the ordered column — one
  O(N) fold of the column into an smap at the FIRST read, O(1) after,
  the note path one push exactly as before. THE MEASURED LAW, paid
  twice in one landing: the peak ratchet refused the hot-arm
  piggyback (+94MB — two state-field rebinds per note) and then the
  state-init smap_new (+118MB — HANDLER STATE INITS RUN PER INSTALL,
  thousands of branch brackets each paying the 4096-slot allocation;
  the hoeffect dig's state-init lesson at the MEMORY face). The init
  is the empty-list sentinel; the built flag gates the read's three
  arms. Un-gates: the synthesized-family repr floor deletion
  (Hβ.emit.unused-wide-param-floor's named remainder — the 106s
  quadratic column scan dies onto this read) and the enumeration
  reader's by-name access.
- 2026-08-11 · ▶▶▶ THE INSTALL-SHAPE COLUMN — STEP (i) COMPLETES
  (pin 06a0d62b070d — CLEAN m2 == m3, census 0, battery green, peak
  2441448KB inside the justified 2470000 ceiling): InstallOf(hname,
  config-arg program handles, arm-name groups), the spine's ELEVENTH
  column, noted at the PTee install lowering with the arm-groups
  lookup deduped through the let the LHandleWith construction shares.
  THE STEP-(i) VOCABULARY IS COMPLETE — bind-home, the emittable-fn
  enumeration, dispatch-tier, state-slot-home, install-shape — every
  decision-carrier column the enumeration-reader relocation was
  stamped to read now exists, dual-written and zero-read. The column
  arc's loop-frontier is exhausted; the next arc work is the
  dedicated-arc relocation (the phase-boundary stamp's build), and
  the standing cursor's next loop item falls to the phase order.
- 2026-08-11 · ▶▶▶ THE STATE-SLOT-HOME COLUMN — STEP (i)'S THIRD
  DECISION CARRIER (pin 38569e600884 — CLEAN m2 == m3, census 0,
  the pin advancing twice through in-landing teachings: the anonymity
  tier convicted the note's map lambda and the product-with-hole
  `map(resume_upd_pair(??, fields), updates)` replaced it — the
  canonical suspension, no lambda, the row at its decl home;
  battery green, peak 2429068KB inside the ceiling): StateSlotHome =
  SlotPairs([(field, offset)]), the spine's TENTH column, noted at
  resume_commit_prefix through the SAME one-home resolver the
  LStateSlotStore constructions read — column and tree cannot drift
  apart by construction. Zero readers until the enumeration-reader
  arc; the remaining step-(i) vocabulary is the install-shape column,
  then the arc's next work is the dedicated-arc relocation.
- 2026-08-11 · ▶▶▶ THE DISPATCH-TIER COLUMN — STEP (i)'S SECOND
  DECISION CARRIER (pin d96a258b5685 — CLEAN m2 == m3, census 0,
  battery green, peak 2327532KB inside the justified 2440000 ceiling):
  the BindHome pattern applied whole — DispatchTier
  (DtLexical(target, state_local) / DtSingleton(hname, stateful) /
  DtEvidence(ename, ev_slot) / DtWasi(name), all-payload constructors
  by design so no nullary tag aliases the addr-0 virgin cell), the
  spine's NINTH column, written at the four decision arms (the lexical
  tier, the singleton construction, the evidence floor, both wasi
  forks), non-trailed by the bind-note contract, zero readers until
  the enumeration-reader arc reads dispatch off the column instead of
  re-deriving it from LowExpr constructors. The peak ceiling's raise
  carries its fixed-input justification in the baseline: one word per
  spine slot — the column arc's own §5.O price, stated in the stamp
  before the build measured it.
- 2026-08-11 · ▶▶▶ THE VALUE-HOLES COLUMN — THE FIRST WALKER SWAP LANDS
  (pin 8aefbe91feb0 — CLEAN m2 == m3, census 0, battery 132/0 with the
  three dead-hole contracts promoted, peak 2318716KB under the
  2410000KB ceiling): lowering-is-a-column step (ii) opens with the
  hole gate reading the PROGRAM's own column instead of re-walking the
  lowered tree. The one writer is lower_expr's authored-hole arm
  (value-position is a lowering decision — a consumed call-arg hole
  never reaches it, "the mint precedes lo_args"); entries drain
  pending holes against their own names at TWO sites (the handler-arm
  construction and the top-stmt boundary — a nested lambda shares its
  container's reachability class, "" rides __init_lets always-live);
  the executable gate filters the pairs by the reach vocabulary; the
  four-fn collect_value_holes family DELETES (twelve walker families
  → eleven). THE GATES DID THE STEERING, twice: the census gate
  refused the first repin at TWO E_UnresolvedHole on the wheel's own
  pipe-target `??` (io.mn fs_readdir_loop, graph.mn merge_chased_row)
  — the note measured VISITS where the contract is SURVIVAL, closed
  by graph_hole_unnote at the pipe completion's splice (the pipe owns
  its hole); the peak ratchet then refused +108MB of per-stmt handler
  state rebinds, closed by the empty-pending fast path (the
  overwhelming case resumes without rebinding). Contracts measured
  BEFORE the swap and held after: dead-fn, dead-arm, dead-init holes
  all run (exit 42, diags 0) — the never-over-refuse law
  (SYNTAX §«Partial application») pinned in the battery. Ratchets
  re-based in the same commit with their justifications: movers 474 →
  475 (the new column fns' schemes move once between passes, the
  standing trial/final channel), effectful lambdas 383 → 385 (the two
  pairing folds' lambdas perform Alloc — real vocabulary, the tier's
  conviction correct).
- 2026-08-11 · ▶▶▶ THE READING LAW KEEPS EVERY TERMINAL — THE FORWARD-HOF
  FALSE-ABSENCE CHANNEL CLOSES (pin c6eb188e1d37 — TRANSITION m3 == m4,
  census 0, battery 129/0, peak RSS fell 2336 → 2250MB): the P1 dig's
  three-probe arc, run by the loop in one session, named the one writer
  the dossier's 68 iterations circled. Probe 1 (both-arm charge prints)
  exonerated the charge path (0 NCH / 30,928 CHG) and measured the
  degradation cascade (neg reads show_list p2 v trial → p0 v final).
  Probe 2 (fzs/pub at both publish sites) pinned the hop: the stored term
  is p0 v both passes; trial's generalize resolves the tail cell, the
  final's reads it unresolved — and the degraded final decl-exit
  OVERWRITES the honest group publish (env newest-first). Probe 3 (FIN
  write + FINQ read-back + CEL cell-chase) caught the contradiction on
  one screen: the finalize's write lands (p2 v + edge) and the chase of
  the same cell answers ty-free — the chain tunnels through the bound
  cell into the fn-typed param's free t-cell, and merge_chased_row's
  catch-all returned the bare terminal, DISCARDING the accumulated
  presents (graph.mn:821, the silent surrender-fallback at the one
  mechanism every row read routes through; trial survived only because
  its chain ends at NRowFree, whose arm preserved). THE FIX DELETES: the
  NRowFree special case and the catch-all collapse into one uniform
  preservation arm — every non-bound terminal keeps the reading riding
  an edge to it. ACCEPTANCE, all three legs: neg_names_to_str solo
  answers Memory + Alloc + Intern + GraphRead + !Mutate (was Pure — the
  crown-adjacent false absence dead); show_list publishes Memory + Alloc
  + !Mutate + t-tail (p2 + shared tail, the banked target verbatim);
  movers re-base to 474 with the justification that honest reads change
  the trial/final comparison itself. The honest read surfaced ONE census
  claim (render_row_triples missing its GraphRead — widened, the census
  gate seen RED refusing the first repin and green after). The peer
  Hβ.infer.forward-hof-row-underpublish is RESOLVED; its dossier stands
  as the kill record; p1_iterations closed at 3.
- 2026-08-09 · ▶▶▶ THE TIE-RANKING — PREVALENCE, AND THE SEVERANCE PEER
  RESOLVES WHOLE (pin 84fc4aaac0f6 — CLEAN m2 == m3, census 0): the
  performed-name union grows its PREVALENCE half — name_count_bump
  counts per-scheme occurrences into (EffName, Int) pairs and the one
  memo point sorts most-performed-first — so severance_negations emits
  candidates in prevalence order and pick_highest_leverage's
  first-proven fallback resolves equal-leverage generics by how much
  of the link performs the name, never by env enumeration order (the
  uniform-!SmtSolver symptom's root). The rich-label ladder stays on
  top. Gate: mn-teach-prevalence.mn on the BARE stdin link (the
  prelude's Alloc prevalence would hand the ladder the win) — Rare
  declared and performed first, Common performed by three fns, main
  performing only Noise; seen RED (!Rare, enumeration order) against
  the prior boot, GREEN (!Common) after, with the RTLIBS pure control
  re-probed intact (!Alloc/Real-time). The doubled-Sandbox sibling was
  found ALREADY FIXED (severance_unlocks dedupes by structural ==,
  the measured double in its own comment) — the bank had outlived the
  fix, retracted per the entry. Hβ.teach.severance-vocabulary-from-link
  is RESOLVED WHOLE; the named growth beyond it (per-fn proximity as a
  second informativeness axis) joins only if a real consumer measures
  prevalence insufficient.
  (pin 07e6a8a25758 — CLEAN m2 == m3, census 0): CsEnvFrame joins as
  the TENTH census shape — the scope-as-frame-stack family (parent_env
  / env_stack / push_frame / pop_frame / env_chain) declared as an fn,
  referenced as a value, or let-bound, the same members the bash regex
  policed, now counted from the weave (roster ten, audit tier 9 → 10,
  fixture push_frame at line 38, all seen RED against the prior boot).
  Born at ZERO on the wheel link and ratcheted there (env_frame_max);
  the mode-2 bash row dies. With it the drift catalog's STRUCTURAL
  modes are fully absorbed into the medium — every remaining
  drift-patterns row is naming/prose (foreign keywords, comment
  decoration, prose vocabulary), the raw text channel's own domain,
  which the weave census does not read by design. The uniform per-fn
  walk (the mode-7 landing's find) carried this one with zero new
  walker code: one roster entry, one label, one detector arm, one
  family fn.
  WALK (pin 8683232e5ae1 — CLEAN m2 == m3, census 0): CsParallelArrays
  grows its second face — an FnStmt whose parameter list carries any
  adjacent `x, x_h` pair (adjacent_handle_params, a rest-slice pairwise
  walk), structural where the bash regex saw exactly four literal names
  (locals/captures/frames/handlers). The dig's real find: the audit's
  per-fn drift tier NEVER VISITED THE FN NODE — drift_shapes_of walked
  the body subtree only, so a shape living on the FnStmt itself was
  census-visible but audit-invisible (probed: census counted fixture
  line 37, audit stayed at 8). The fix deleted code: the walk starts at
  the fn handle and body_child_handles descends, one uniform walk, the
  per-kind carve-out gone. Fixture pp_site(locals, locals_h) at line 37,
  roster leg grew the second parallel-arrays spec, audit tier 8 → 9 —
  both seen RED against the prior boot first. Wheel measures ZERO on
  the param face (parallel_arrays_max stays 0); the census label trues
  to "site(s)". The last mode-7 bash row dies (the ninth absorption's
  completion); remaining bash rows: naming/prose modes + mode 2.
  (pin 54c97b0f7220 — CLEAN m2 == m3, census 0): the general severance's own
  landing left the board RED at teach-pure-control — the ONE leg the
  pre-commit verify does not run — because pick_highest_leverage's
  priority ladder still named the retired fixed ctors (ANotAlloc/
  ANotIO/ANotNetwork), rungs no ANotEffect candidate can match, so
  APure outranked the proven !Alloc on the pure control. The fix is
  the census law, not a patch: the trio's ONE remaining reference WAS
  the ladder (query counted 1 ref each), so the three ctors are
  deleted from Annotation whole — seven match families shrink
  (kind/span/apply/caps/eq/unlock/show) — and the ladder speaks the
  general vocabulary (annotation_eq's ANotEffect arm is
  name-sensitive, so each rung matches its proven namesake; the
  literal ladder's replacement by measured leverage stays the banked
  tie-ranking refinement). Two more homes fell in the same sweep:
  oracle.mn's gradient_candidates_at — a frozen second copy of the
  enumeration whose own comment claimed "the SAME enumeration
  gradient_next runs" — collapses into mentl.mn's gradient_candidates
  (ONE enumeration, two readers; project_queue reads
  performed_names_of_link once and threads it), and
  try_each_annotation's fork pre-warm generalizes from three fixed
  intern literals to an each-walk over the candidates' own names (the
  fixed warm could never protect a general name; the walk protects
  any caller). Measured: teach-pure-control regains `main: → add with
  !Alloc to unlock Real-time safe`; teach-alloc-honest's winner is
  now the honest `!ImageAlloc` general severance (no false !Alloc);
  frontier 359/0, the board whole again. The lesson lands MECHANICAL,
  not procedural: the violation walked through the board's one
  non-refusing state (`frontier: NOT RUN` is a visible blank, and the
  pre-commit hook ran verify only), so the same commit adds the
  FULL-GREEN PERIMETER — frontier-gate writes .build/frontier-stamp
  (the boot sha256) on a 0-red run and clears it on any red, and the
  hook's new Gate 4 refuses any wheel/boot commit whose staged boot
  lacks a matching green stamp (seen RED first: the stampless commit
  attempt refused, then frontier stamped, then the commit passed).
  Boot↔source coherence stays the march's own contract (m2 == m3);
  this perimeter binds gate↔boot, exactly the d51661f1 class. Second find,
  banked as Hβ.emit.under-application-suspension: bare
  under-application (`map(candidates_at(performed))`, no `??`) EMITS
  INVALID WAT — a 1-arg return_call_indirect against the 2-arg $ft2 —
  instead of constructing the suspension SYNTAX promises or refusing;
  wat2wasm catches it loudly, but the lathe's answer must be the
  suspension record or a diagnostic, never malformed output. The
  `??`-marked product (`candidates_at(performed, ??)`) is the proven
  emit path (mn-partial-hole-executable) and is the landed form.

- 2026-08-08 · ▶▶▶ THE GENERAL SEVERANCE (pin 811c5d423bf7 — CLEAN
  m2 == m3, census 0): ANotEffect(name, span) joins Annotation
  (appended last, tags unshifted) and CProvenAbsence(name) joins
  Capability — one severance candidate per performed BARE name,
  proven by the same negation-narrowing row read as the fixed pair
  it subsumes; known names route through capabilities_for_severance
  and keep their rich labels. THE DIG'S THREE CORRECTIONS: (1)
  fn-name collision — severance_candidates already lived in the
  audit machinery; E_DuplicateFnName (armed) REFUSED the m2 emit,
  the tenth-class contract catching the session's own hands; (2)
  two honest row breaks (ctor construction allocates under a
  declared Pure — the with-Pure dropped; intern_str widened a
  declared row +Intern); (3) the union's first cut walked
  decls-column HANDLES through lookup_ty and measured EMPTY — a
  decl node's bound type is not its fn's TFun; the env SCHEMES are
  the channel (the QEffects read, link-wide). MEASURED END STATE:
  teach speaks true crown facts — `!SmtSolver` suggested where
  provable IS performed in the link and absent from the fn — but
  ties in leverage rank by enumeration order (uniform !SmtSolver
  across non-Pure fns): the TIE-RANKING among equal-leverage
  severances (rich-label first; then per-fn informativeness) is the
  peer's named refinement.

- 2026-08-08 · ▶▶▶ THE SEVERANCE LAW WHOLE (pin f544489b21e6 — CLEAN
  m2 == m3, census 0): the performed-set half lands in the
  Mentl-native form — the link's row-name union (graph_decls_at →
  lookup_ty → row_names, deduped by the name handle's i32 identity)
  computed ONCE and held as mentl_default's handler state (handler =
  state, the lazy memo: resume-with-state fills it at the first
  teach_gradient; per-fn asks read O(1)). The negation candidates
  require membership. MEASURED both directions: uniform `!Network`
  DIED (declared-but-never-performed — the target the half-law
  landing named), and `!Alloc` SURVIVES exactly where informative
  (Alloc is performed across the wheel; severing it on
  allocation-free fns is the Real-time unlock — march_sort_insert,
  tail_set_has, the pure algebra leaves). The gradient's first move
  per fn is now a fact about THIS program, not the catalog's. The
  general vocabulary (an ANotEffect(name) variant proposing ANY
  performed name's severance, retiring the fixed ctor pair) stays
  the peer's named growth. All new fns named recursion — zero
  lambda convictions this landing.

- 2026-08-08 · ▶▶▶ THE VOCABULARY GATE, HALF THE LAW (pin 367c2d44425c
  — CLEAN m2 == m3, census 0): gradient_next's name-keyed negation
  candidates (ANotIO / ANotNetwork) enter only when
  effect_in_vocabulary resolves their names through the env's O(1)
  bucket — an undeclared name's negation is unspeakable (a row naming
  it would E_MissingVariable), so it is never a candidate. MEASURED:
  `!IO` died on the wheel link (the vacuous first-move suggestion the
  stamp recorded on every fn including the TCP loop), and `!Network`
  SURVIVED — declared in lib, never performed in the wheel, teach
  still uniform on it — the live example that the declared-set gate
  is HALF the stamped law; the PERFORMED-set intersection (the
  handler-state form: the link's row-name union computed once and
  held as Teach state) is the peer's remaining build, now with a
  measured target (uniform !Network must die the same death !IO
  did).

- 2026-08-08 · ▶▶▶ THE REFS READ RAW (pin a37aedbadfbaf1d1 — CLEAN
  m2 == m3, census 0): the 2.0 walk law lands at its named sibling —
  collect_ref_spans reads span_of_node_raw instead of the chased
  span_of_handle, so a noted reference's span is its OWN parse site,
  never the union-find root's reason. The chased read greened only
  because VarRef roots happened to retain Located reasons (the
  accident-invariant 2.0's record named); the facet's answers measure
  identical post-swap — by law now, not luck. The standing-residue
  face in the eq-divergence dossier closes.

- 2026-08-08 · ▶▶▶ THE CONTRADICTION ARMS (pin bfc68f441f996e — CLEAN
  m2 == m3, census 0): E_DeclaredRowContradiction joins diag_refuses,
  the TENTH armed class — the decl-site licence (a fact read from the
  authored clause's own signed fold, no resolution dependency), census
  0 at birth measured by the diagnostic's own landing march. The
  armed-class contract proven both ways: pre-arm the contradiction
  fixture compiled to 2,394 WAT bytes at exit 0 WITH the diagnostic on
  stderr (the exact silent-wrong arming deletes); post-arm exit 1,
  zero bytes. The frontier grows the run_refusal leg. Universal
  executable refusal's remaining census classes stay the
  name-dependent E_TypeMismatch kin (§7's own sentence).

- 2026-08-08 · ▶▶▶ THE CONTRADICTION REFUSES AT THE DECL (pin d06486727bbb
  — CLEAN m2 == m3, census 0; the first cut's each-lambda convicted at
  the anonymity tier and rewrote as named recursion, superseding the
  same-arc 0544ec77b558):
  Hβ.diag.declared-row-contradiction (band L, named 2026-07-05) lands,
  and the opening probe SHARPENED the peer's own claim: PLAN's text
  said the contradiction "surfaces only downstream when the body
  performs the dropped effect (the subsumption gate, loud)" — the
  probe measured the performing body checking CLEAN, because the
  fold's meet (effects.mn's "authored meet", its own comment blessing
  the drop) resolved `with E + !E` by discarding the negation and the
  kept E then LICENSED the perform. A declared negation silently
  ignored is a false-absence surface — worse than a missing teaching.
  The fix: report_row_contradictions runs the same pair law the
  subtraction filters by (instance-aware — a bare-present beside an
  instance-absent stays a refinement, unreported) and reports
  E_DeclaredRowContradiction per contradicted name BEFORE the drop,
  at the decl (span_zero, the ERowAliasCycle precedent; the located
  span is the standing refinement). The march's census gate measured
  the WHEEL contradiction-free — the class is born at zero. Gate:
  mn-row-contradiction (both decls refuse, pure and performing
  bodies), born RED against the pre-fix pin. Cost: 17.05s wall,
  2339MB peak.

- 2026-08-08 · ▶▶▶ THE DEBT TAXONOMY COMPLETES (pin 104f21891c89
  unchanged; the TagId probe reverted byte-identical): the ten
  remaining pendings are now EACH classified with an owning arc, and
  the classification closed on the engine's own header rather than a
  guess — probing lower:2098's two-literal if-join with a `let tag:
  TagId` annotation moved the obligation one line and discharged
  nothing, because verify.mn's interval fragment is LOWER-BOUNDS-ONLY
  BY DESIGN ("TagId's upper half and the float intervals stay the SMT
  tier's" — the fragment's own scoping sentence; the lo side already
  joins if-branches). The full map: 5 span_valid = structurally
  undecidable honest pending; 2 TagId upper-halves (lower:2098,
  infer:7893) + 1 DSP float interval (dsp/feedback:143) = band F's
  SMT tier (8.3); 1 span-index cascade (main:1163) = the substrate
  element-typing / proof-incrementality arcs; 1 self-call IH
  (cursor:544) = rung 3. Annotation work on this debt is DONE — three
  discharged, everything else owned by a named engine arc. 13 → 10
  across the day's three discharges.

- 2026-08-08 · ▶▶▶ THE THIRD DISCHARGE (pin 104f21891c89 unchanged —
  byte-identical, judgment-only truth): voice:832 clears by refining
  the ADT PAYLOAD — CaretTarget's TargetHandle(Int) becomes
  TargetHandle(Handle) at the decl, so the refinement rides every
  construction site and resolve_cursor_target's arm returns proven.
  Debt 11 → 10, no relocation. THE BARE 0<=self ONE-ANNOTATION SET IS
  EXHAUSTED: three discharged (cursor:297 the param, main:999 the
  mint-site param, voice:832 the ADT payload — three different
  annotation altitudes, one law each time: put the refinement where
  the value is BORN or where the obligation MINTS), two banked to
  their owning arcs (main:1163 the span-index cascade; cursor:544 the
  self-call IH on rung 3). The remaining debt classes: five
  span_valid (the structurally-undecidable honest pending), two TagId
  byte-ranges (lower:2098, infer:7893 — a shape read owed), one DSP
  sample bound (Phase 8's DSP tier).

- 2026-08-08 · ▶▶▶ THE SECOND DISCHARGE (pin 104f21891c89 — CLEAN
  m2 == m3, census 0): main:999 clears, debt 12 → 11 — and the site
  taught WHERE an annotation works: the producer-side return
  annotation (field_ranked -> [(Float, Handle)]) measured INERT
  first (byte-identical pin, debt unchanged), because an obligation
  minted against a POLYMORPHIC param at judge-time never re-visits
  under the caller's refined instantiation — the discharge landed
  only when the annotation moved to the MINT site itself
  (render_field_tier's ranked param). The mint-site law now guides
  the remaining set: main:1163 measured CASCADE-class (ph flows from
  address_resolve, whose three sub-resolvers all read the
  span-index's plain (Span, Int) elements — the discharge belongs to
  the span-index typing its handles at the substrate, or to band F's
  proof-incrementality re-visiting under instantiation), joining
  cursor:544's self-call-IH class as measured-not-annotatable.
  Remaining one-annotation candidates: voice:832. Both producer
  annotations kept — true documentation at zero cost.

- 2026-08-08 · ▶▶▶ THE FIRST DISCHARGE (pin 4fa7e36b386c — CLEAN
  m2 == m3, census 0, wall 17.85s): Phase 8.2's discharge arc opens
  with the debt facet's own instrument — cursor:297's `0 <= self`
  pending (score_one_position's plain-Int handle flowing into
  Cursor's refined Handle field) clears by ONE authored Intent
  Boundary, `handle: Handle`, because handles are BORN refined
  (graph_fresh_ty -> Handle) and the annotation reconnects the chain.
  Debt 13 → 12, no relocation (the facet's site list proves the
  absence — the count fell and no new site appeared). The remaining
  bare `0 <= self` set: main:1163, main:999, voice:832, cursor:544.
  SAME-DAY REFUTATION at the second site: cursor:544 is NOT the
  one-annotation shape — annotating scan_for_span's counter `i:
  Handle` measured debt 12 → 13 (the self-call's `i + 1` needs the
  interval induction 0<=i ⊢ 0<=i+1, exactly the self-call IH class
  8.2 already banks on rung 3's dissolution, AND the caller's
  literal-0 arg minted a NEW obligation at cursor:540 instead of
  discharging — the call-arg position does not run the literal
  discharge the construction site runs, a fragment gap worth its own
  look when 8.2's engine work opens). Reverted whole; the pin
  returned byte-identical. The prescription's measure-each clause is
  the whole point: two sites, two verdicts, one annotation kept.

- 2026-08-08 · ▶▶▶ THE DEBT SPEAKS ITS SITES (pin a90453e3e444 — CLEAN
  m2 == m3, census 0; the first cut's own ratchets bit once more — the
  reflexive `ref` dropped, the render lambda named render_debt_line —
  and the re-march superseded a187ffeb1b83): QRVerifyDebt's render grows the
  site list — one line per pending obligation, the predicate the graph
  holds at the developer's coordinates through the module seams (the
  refs facet's own lesson: render WHAT was computed, not how much).
  The wheel link's 13 obligations enumerate for the first time at the
  CLI: five span_valid (the structurally-undecidable class), six
  0 <= self (main:1163, main:999, cursor:297, cursor:544, voice:832 —
  PLAN 8.2's named discharge set, now addressable), two byte-range
  conjunctions (lower:2098, infer:7893), one DSP sample bound
  (dsp/feedback:143). Gate: mn-debt-facet (the chained-comparison
  pending renders located) in the frontier. Phase 8.2's discharge
  work opens with its instrument in hand.

- 2026-08-08 · ▶▶▶ THE UNUSED PARAM SIGNS AT ITS WIDTH (pin cfa58fdd5479
  — CLEAN m2 == m3, census 0, wall 19.22s): the
  unused-wide-param miscompile healed for the proven class. When the
  body-usage scan misses, param_repr_of now reads the fn's own type
  product through the ENV BUCKET (O(1) — Forall's body, one TVar hop
  via resolved_fn_ty, the TParam matched by field_name_eq) instead of
  fabricating the i32 floor; wildcard params short-circuit (they bind
  nothing — the floor is their truth). The probed pair runs to 11
  through the frontier's compile-assemble-run harness. THE DIG'S OWN
  MEASUREMENTS: (1) the first form walked emitfns_col + decls_col per
  miss and cost 106s of m3 leg (snoc-list indexing is O(i) — the scan
  quadratic); env-first halved it, and narrowing the synthesized
  family back to its floor restored 19s — that family's call protocol
  is the indirect/wrapper machinery, never probed incoherent, and its
  column read returns as an smap when the O(1) form lands (the peer's
  residue). (2) The census gate refused mid-arc (the env read widened
  spec_wide_twin_names' declared row — +EnvRead, the honest widening).
  (3) The run-verb leg taught the harness law: a gate leg cannot
  `wt_run <compiler> run FILE` (WASI has no exec) — run_program's
  compile-assemble-run harness is the one road. Peer:
  Hβ.emit.unused-wide-param-floor RESOLVED for decls, the synthesized
  family's floor named inside it.

- 2026-08-08 · ▶▶▶ THE DCC GATE'S FIRST FACE (pin a025c3523a84 — CLEAN
  m2 == m3, census 0): Phase 7's chain head opens by catching a LIVE
  silent regression on its first probe. The splice IFC check
  (check_splice_flow_labels → verify(PFlowLe(label, Public)), always
  decidable) was real and CALLED — but the ShowExpr desugar had bound
  every splice fragment to String, so query_flow_label read the
  WRAPPER's type, classified Public, and the obligation discharged
  clean: a classified value spliced into any string passed check. No
  gate could see it — no refusal fixture existed (rung 3 of the
  board-blindness tripwire, again). The fix reads THROUGH the wrap
  (splice_flow_check on the inner node; the unwrapped arm kept for
  pre-ShowExpr shapes). The gate: mn-ifc-splice-leak (classified
  splice → E_RefinementRejected "Secret ⊑ Public" at the splice span)
  and mn-ifc-splice-sound (Public splice → clean), the pair differing
  only in the source's classification — born RED (the leak checked
  CLEAN on the pre-fix pin). The DCC gate's named remainder in
  RESIDUE: today's check is CONSTRUCTION-site (every splice ⊑ Public,
  sink-blind — conservatively sound, over-refuses a Secret splice
  bound for a Secret sink); sink-sensitivity is what
  .flowlabel-inference-in-hm buys when labels ride the union-find.
  Cost: 17.53s wall, 2333MB peak.

- 2026-08-08 · ▶▶▶ THE EIGHTH DRIFT SHAPE, AND THE TIER BECOMES A
  ROSTER (pin 0bbfe0e58e1cb6f3, superseding the same-arc aa581cb8839b
  after the landing's own ratchets bit — CLEAN m2 == m3, census 0; the
  quiet gate refused SEVEN reflexive ownership markers on the roster
  walk (dropped, inference grades — §4⑤ enforced against this
  session's own hands) and the anonymity ratchet convicted the render
  fold's nameless Alloc row (named drift_note_fold); peak 2404368 KB,
  a reading the pre-correction 2400000 ceiling would have refused —
  the noise-band ruling earned its keep on its second march): mode 1's
  vtable absorbs as CsVtableRecord — a MakeRecordExpr or
  NamedRecordExpr field named fn_*/handler_* holding a LambdaExpr,
  the name-keyed anchor that leaves the unified each's honest-named
  closure record silent (the retired regex could only see the
  pre-dissolution lambda spellings, which no longer parse). The
  specimen taught its own lesson: a bare `= {fn_go: ...}` body parses
  as a BLOCK — the record literal parenthesizes (the brace-header
  law). AND the uniform pass hits the tier's own construction: the
  widening count-tuple (seven arms of one shape) dissolves into ONE
  fold over drift_roster() — counts as a list bumped per node,
  render folding census_label over the pairs — so the ninth mode
  joins by one roster entry and one label. Census roster seventeen,
  tier 8 specimen lines, wheel at ZERO, mode 1's row retired (the
  mode-33 precedent, eighth application). Peak 2393576 KB — the
  HIGH mode, inside the noise-band-corrected ceiling on its first
  post-correction march.

- 2026-08-08 · ▶▶▶ THE QUERY REFUSES THE EMPTY WEAVE (pin 76e85e00696e
  — CLEAN m2 == m3, census 0): Hβ.query.unreadable-source-refusal
  RESOLVED, with the dig's decode sharpened by the fix's own RED — the
  diagnostic was never missing (E_MissingModule fired at the DAG walk;
  the probes' 2>/dev/null ate it); the gap was the VERB proceeding to
  answer at exit 0, and the answer was worse than the banked zero: on
  a nonexistent entry the query attributed the PRELUDE'S OWN 23
  anonymous fns to the missing file (the substrate layers join the
  weave regardless of the entry). The fix reads the fact the walk
  already produced: query destructures the ranges it had discarded,
  and range_of_module(entry) == None refuses (stderr names it, exit
  1) while Some proceeds — productive-under-error for JUDGED files,
  refusal only when the question's own file has no weave. query_run
  passes the code through (the hardwired 0 deleted). Frontier leg:
  the missing-entry census refuses AND the good path still answers,
  RED-proven against the old pin (23 sites, exit 0). Cost: 17.25s
  wall, 2342MB peak — 2398768 KB, 1232 KB under the ceiling; the
  arena (4.3, column-gated) is the named answer, never a raise.

- 2026-08-08 · ▶▶▶ THE SEVENTH DRIFT SHAPE (pin 74b43c43e00d — CLEAN
  m2 == m3, census 0; supersedes the same-day 6b1400a3404908 whose
  detector the dig corrected): mode 7's parallel-arrays absorbs as
  CsParallelArrays — and the honest weave shape is the ONE-ARM MATCH
  destructuring a tuple into first-two _h binders, because
  desugar_block turns every destructuring let into exactly that at
  parse (lower.mn:3157's own law: LetStmt is PVar-only by
  construction), so the first-cut LetStmt(PTuple) anchor was
  UNCONSTRUCTIBLE and its census read zero everywhere. Both spellings,
  one graph, one count. THE DIG'S KILLS, per the forensic law: (1)
  "tuple destructure computes zero" — retracted, a $?-after-pipe
  artifact of the prober, every runtime path measured correct (3/33);
  (2) "multi-line blocks desugar differently" — refuted, the variable
  was the MOUNT: the probe files lived under /tmp and the census
  answered a confident ZERO on the unreadable file — the real find,
  banked as Hβ.query.unreadable-source-refusal (a query on a source
  the judge cannot read must refuse loudly, never walk an empty weave
  to zero — the silent-fallback class at the verb layer). Census
  roster sixteen, audit tier a sept, pa_site at mn-census-verbs:35
  counting under the fixed detector. Wheel link at ZERO —
  parallel_arrays_max born at the floor, the let-tuple row retired
  (the mode-33 precedent, seventh application); mode 7's
  param-adjacency row stays, a distinct shape. Cost: 16.22s wall,
  2238MB peak.

- 2026-08-08 · ▶▶▶ THE SIXTH DRIFT SHAPE (pin c7cf09a15a00 — CLEAN
  m2 == m3, census 0): mode 8's flag-as-int absorbs as CsFlagAsInt —
  a BEq whose one operand is VarRef mode/token_kind/scheme_kind and
  whose other is an int literal, either order (the int-coded state an
  ADT is begging to replace; the three TSV rows were one shape).
  Census roster fifteen, audit tier a sext, fi_site specimen at
  mn-census-verbs:34. RED banked pre-march (unknown query on the old
  generation). The wheel link measures ZERO flag compares —
  flag_as_int_max born at the floor, the three mode-8 rows retired in
  the same landing (the mode-33 precedent, sixth application). Cost:
  16.90s wall, 2327MB peak.

- 2026-08-08 · ▶▶▶ THE FIFTH DRIFT SHAPE (pin 54bf749eab9f — CLEAN
  m2 == m3, census 0): mode 15's underscore-retain absorbs as
  CsUnderscoreRetain — a LetStmt whose binder is a PVar opening with
  the underscore (a bare `_` is PWild at parse, so every underscore
  PVar is the retained costume; deletion, not decoration, is the fix
  the mode always named). Census roster fourteen, audit tier a quint,
  ur_site specimen at mn-census-verbs:33. RED banked pre-march
  (unknown query on the old generation). The wheel link measures ZERO
  retained underscores — underscore_retain_max is born at the floor,
  and mode 15's bash row retires in the same landing (the mode-33
  precedent, fifth application). Cost line: 17.38s wall, 2336MB peak
  (2392684 KB — 7.3MB under the 2400000 ceiling; the next RSS growth
  breaches, and the arena is the named answer, not a raise).

- 2026-08-08 · ▶▶▶ THE FOURTH DRIFT SHAPE (pin 8f11d81b61d4 — CLEAN
  m2 == m3, census 0): mode 10's typed fabrications absorb as
  CsWildcardFabricates — a wildcard arm whose body is LitString("") /
  LitString("Pure") or a call whose callee names Forall / TVar, the four
  values a missing case silently absorbs a new variant into (the zero
  literal stays CsWildcardZero's own shape). The detector is the
  established template: an arm-list walk beside any_wildcard_zero, the
  minting-ctor read name-keyed through the weave exactly as
  CsPrintInReport keys on the print family. The audit's drift tier grows
  to the quad (wz, fm, pir, wf); the census roster to THIRTEEN shapes
  with wf_site's specimen at mn-census-verbs:32; the frontier's tier
  assert to four drift-shape lines. RED banked pre-march: the old
  generation answers "unknown query: census wildcard-fabricates".
  Enforcement (ratchet + the four bash rows' retirement) follows the
  cadence next — the ratchet seeds from the fresh wheel's measured
  count, never assumed zero. Cost line: 16.58s wall, 2326MB peak — both
  inside their ceilings.

- 2026-08-08 · ▶▶▶ THE AUDIT SPEAKS THE DRIFT SHAPES (pin 9d959f5900 —
  CLEAN m2 == m3, census 0): the absorbed modes gain their per-fn
  reader. drift_shapes_of counts the three census shapes within one
  body's subtree — the same census_matches membership, scoped by
  body_child_handles — and `mentl audit` renders the drift-shape
  tier beside iteration and anonymity: the audit names the costume
  where it stands, the census locates the corpus. Between this and
  the row retirement (9e65da5d: five bash rows deleted, each shape
  probed compiler-refused first), 5.6's absorption has both of its
  motions running — shapes INTO the medium, redundant scaffold OUT.
  Frontier 351/0 with the tier's leg.

- 2026-08-08 · ▶▶▶ THE PRINT-IN-REPORT SHAPE (pin ba1a7e4ea694 —
  CLEAN m2 == m3, census 0): the third drift-catalog absorption, and
  the first CONTEXT-SENSITIVE census shape — mode 16 (a report call
  whose argument subtree calls print/println/print_string, the
  WAT-stdout corruption class) becomes CsPrintInReport via a
  fuel-bounded subtree search over body_child_handles, the weave's
  own tree edge — reusable machinery for every future context mode.
  The roster leg grows to twelve; the specimen resolves report/
  println locally so the shared fixture stays diagnostic-free.

- 2026-08-08 · ▶▶▶ THE FAILURE-MASK SHAPE (pin 0094b2176c8a — CLEAN
  m2 == m3, census 0): the second drift-catalog absorption — mode 13
  (`expr || true`) becomes CsFailureMask, the BOr-with-LitBool(true)
  silhouette read structurally from the weave. The roster leg grows
  to eleven; the wheel's own query.mn measures ZERO mask sites. The
  absorption cadence is now established machinery: shape ctor +
  label + detector + grammar word + specimen + roster line, one
  marched landing per mode.

- 2026-08-08 · ▶▶▶ THE WILDCARD-ZERO SHAPE (pin 448c51080635 — CLEAN
  m2 == m3, census 0): 5.6's first drift-catalog absorption — mode 10
  (the `_ => 0` surrender-fallback silhouette) becomes CsWildcardZero
  in the weave census, and the medium's detector out-measures the
  bash scaffold on its first run: three wheel sites located
  (parser:210, query:742, types:217) where the grep pattern saw one.
  The census counts the SHAPE; the masked-case-vs-true-zero judgment
  stays the reader's. The roster leg grows to ten shapes, the fixture
  gains wz_site at line 27.

- 2026-08-08 · ▶▶▶ THE BARE WHY VERB (pin bd96e9334f5e — CLEAN
  m2 == m3, census 0): SYNTAX's verb-lag list retires its first name.
  `mentl why <path> <name>` is why_verb_args routing to the query
  facet's Reason-chain walk — three lines mirroring where's shape;
  the lag list shrinks to diagnostics + verify (10.3's remaining
  absorptions), and the where leg's conjunction gains the why assert,
  born RED against the verb-less prior boot.

- 2026-08-08 · ▶▶▶ THE ADT ROSTER PROJECTS (pin c0510e2f5441 — CLEAN
  m2 == m3, census 0): `variants NAME` joins the query grammar — the
  type's constructors with arities from the env's ConstructorScheme
  registry, the confessed missing facet (named twice: the lowering
  stamp's walker census needed an awk scan for it; the
  `mentl diagnostics` verb needs it to walk DiagKind). The
  is_ctor_of/scheme_result_is predicates relocated synth → types
  (scheme vocabulary's one home; query never imports the proposer).
  THE CENSUS GATE'S FIRST LIVE CATCH rode this landing: the Question
  ADT's two voice-side walkers missed the new ctor, the m3-leg
  census rose to 2, and the march REFUSED THE REPIN — exactly the
  gap the 25-divergence incident closed. The arms landed; the leg
  (variants Option → None/0, Some/1) born RED against the facet-less
  boot; frontier 350/0.

- 2026-08-08 · ▶▶▶ LOWERING IS A PURE PROJECTION (pin dddf5dc5d6bb —
  TRANSITION m3 == m4, census 0): the last lower-time mint dies.
  infer's MakeStringExpr arm mints the N−1 interior-concat cells
  once (interp_concat_cells — the judge-side mirror of lower's
  empty-literal elision) and stores them as InterpBoundary in the
  boundary column, the trailed per-node lowering-facts channel
  beside the fanout and continuation families; lower's fold zips
  the judged cells instead of minting, and a count mismatch refuses
  through the typed terminal rather than letting zip TRUNCATE a
  string (the silent-drop hazard named before it could exist). The
  path here was a three-reading forensic dig in one day: the
  fragment-handle keying refused by the battery, the staging-clobber
  diagnosis retracted by the backtrace probe (`indirect call type
  mismatch`), the second reading corrected by the wat artifact
  ($call_31135 set twice — the splice's own synthesized show parks
  on the same key), and the settled law: an interior concat's key
  must be distinct from every call-keyed handle in its own subtree,
  which only a mint satisfies — so the mint moved to the judge where
  it is trailed and once. With the census at zero, lowering is
  same-graph-in-same-tree-out for the first time; dual-run
  coherence is available again wherever a gate wants it.

- 2026-08-08 · ▶▶▶ THE SPLICE SHOW IS A JUDGED NODE (pin 058bf710e66d —
  TRANSITION m3 == m4, census 0): γ's splice half
  (Hβ.parser.interp-desugars-to-program). The parser mints ShowExpr
  around every splice at MakeStringExpr's construction; infer judges
  it (the inner keeps its own type — the show accepts ANY type by
  construction, the dispatch stays emit's structural read; the node
  itself is String); lower's arm is LShow(handle, ...) on the JUDGED
  program handle, and interp_fragment_shown — the per-run
  graph_fresh_ty placeholder mint, the projector divergence
  dossier's smaller root — DELETES with its map call. The sweep:
  eight walkers named by exhaustiveness refusals, three more found
  by the ExprPlaceholder-tell census (full enumerations behind
  NodeBody dispatch), and the twelfth — usage_of, own.mn — found
  only by the m3 TRAP: its double-nested match (N(body) → NodeBody →
  NExpr(Expr)) passed the checker at 27 of 28 Expr variants, so the
  compile-time law fell through to the runtime unreachable. THAT
  CHECKER GAP IS THE LANDING'S SECOND FINDING, banked as
  Hβ.infer.nested-pattern-exhaustiveness: totality over a nested
  payload's constructor space must decompose through the wrapping
  pattern, or a grown ADT walks silently into old matches' floors.
  fmt renders the wrap invisibly (braces render the INNER — the
  render∘parse fixpoint holds). TRANSITION: the parse shape crossed
  one generation. The mint class's remaining half is the
  interior-concat handle (lower.mn:4817).

- 2026-08-08 · ▶▶▶ THE TEE SPEAKS ITS MODALITY (pin 2dcd736eb4e6 —
  CLEAN m2 == m3, census 0): §11 6.3's capability-at-tee projection
  as a `mentl where` badge — fn_tee_lines walks the queried fn's body
  mirroring the fanout walk's traversal, and every `~>` install
  renders `~> h absorbs E at <span>`, the effect set read from the
  handler's arms (each op's EffectOpScheme ename, distinct names
  joined " + "). Probed live before the leg: sound-masking-negation's
  f answers `~> h absorbs E`. The where leg's fifth assert born RED
  (the prior boot lacked the facet); mn-where-badges gains the
  installed fn. The modal walk's remaining 6.3 items after this:
  the crucible sweep continues rule-by-rule; the TIME half rides 9.1.

- 2026-08-08 · ▶▶▶ THE α SWEEP COMPLETES (pin 3adb331719ef — CLEAN
  m2 == m3, census 0): the closing measurement — arm, k, and partial
  need NO swap, because their constructions are already α-shaped:
  lower_one_arm_decl takes only handler-decl facts (config/state
  field names, the projected cardinality, the fence), reify_frame_k_at
  is argument-fed off the continuation boundary edge, and
  lower_call_partial derives everything from the call node (its
  captures ARE the supplied args). The seam vocabulary for the
  future enumeration reader is therefore: the swapped kinds read
  cap pairs from entries; the already-α kinds' argument seams are
  the stamped columns (the arm's decl facts, the k's frame-tail
  handle in the yield-boundary column, the partial's call shape).
  The one true-up: the arm's and k's notes move to
  PARENT-BEFORE-CHILD, so the whole enumeration is tree-ordered —
  parents precede their nested mints across all six kinds.

- 2026-08-08 · ▶▶▶ THE FANOUT PAIR SHARES ONE PROJECTOR (pin eae3f3559a0e —
  CLEAN m2 == m3, census 0): α's third move doubles as the uniform
  pass — project_thunk_fn is the one thunk construction for both
  fanout shapes, the share-vs-distribute discriminator an Option
  (Some(input_h) applies the branch to the `<|` shared input riding
  capture slot 0; None evaluates the `><` branch as its own value).
  The per-site family (synthesize_diverge_thunks' inline body +
  synthesize_branch_thunk's) deletes into it; the boundary-row read
  moves ahead of body lowering, so the Err path no longer lowers a
  body it discards (fewer side-effect notes on refusal, Ok-path mint
  sequence unchanged). CLEAN one generation apart is the
  output-preservation proof.

- 2026-08-08 · ▶▶▶ THE NESTED FN BUILDS FROM THE COLUMNS (pin ae471c6b7fc1 —
  CLEAN m2 == m3, census 0): α's second kind, the FnStmt construction
  deleted into project_nested_fn — the resume-binding context (bank
  A3's CUT: the arm_state_ctx install, appended __k/__hrec params)
  moves whole; fn_name and bind_h are explicit arguments with their
  column homes named (the entry carries the name already; bind_h
  waits on the dispatch-tier column). The m2 == m3 CLEAN verdict is
  the output-preservation gate one generation apart: the old boot
  has no swap, so a projector diverging from the walk would have
  surfaced as TRANSITION. Two kinds down (lambda, nested); thunk /
  arm / k / partial remain, each the same move.

- 2026-08-08 · ▶▶▶ THE LAMBDA BUILDS FROM THE COLUMNS (pin a3342552c850 —
  CLEAN m2 == m3, census 0): landing shape α executed for the lambda
  kind. project_lambda_fn — column-seeded, one run — replaces the
  lambda arm's inline body-lowering whole; the site keeps exactly
  what FEEDS the columns (free-var collection, capture resolution,
  the enumeration note) and the construction reads them back. CLEAN
  byte-identity is the proof: the column path builds exactly what
  the walk built, across every wheel lambda including the 25
  interpolating specimens the dual-run gate could not compare.
  Between the captures pin and this one sits a full
  revert-and-decode arc (RESIDUE's projector-stamp block): the
  dual-run coherence experiment fired 25 census divergences, was
  reverted whole with its kills banked, and four probe marches
  decoded the root — hypothesis (a) dead by a zero-mismatch
  whole-wheel eq probe (the program column holds exactly what the
  walk lowers); the real mechanism lower-time fresh minting,
  exactly two graph_fresh_ty sites, both in string interpolation
  (the per-interior-concat handle and the per-splice show cell).
  The law it named: body projection requires lowering to be a pure
  projection; the mint class poisons only dual-running, so α (one
  run, behavioral gates) is the landing shape, with the ShowExpr
  parse-desugar (Hβ.parser.interp-desugars-to-program) banked as
  the mint class's own dissolution. Two board findings ride the
  dossier: the march's transition path never gated the census, and
  a projector-bearing landing's first leg under-reports (the old
  boot has no projector).

- 2026-08-08 · ▶▶▶ THE ENTRY CARRIES ITS CAPTURES (pin ccaacb70b5d4 —
  CLEAN m2 == m3, census 0): the enumeration entry's fifth field —
  (name, binding-time handle) pairs zipped from
  resolve_captures_outer's parallel triple at the five lexical sites
  (lambda, diverge thunk, branch thunk, nested fn, k); the partial
  and arm pass [] with the reason banked in the op decl (their
  capture sets are program-live — the call node's args, the handler
  record's fields). This closes body projection's last frame-state
  dependency: a projection re-derives each capture's read through
  the ENCLOSING entry's own layout, so the lexical-frame stack —
  lower's walk state, never a column — stops being needed at emit.
  The de-parallelized pair form is deliberate: the triple's
  parallel-arrays shape (drift 7, named in its own return comment)
  does not propagate into the column.

- 2026-08-08 · ▶▶▶ THE EMITTABLE-FN ENUMERATION LANDS (pin 1055e8e5093b —
  CLEAN m2 == m3, census 0, peak 2,375,716 KB inside the ceiling): the
  no-mint resolution's vocabulary, dual-written. EmitFnKind's six
  kinds (Partial/Lambda/Thunk/Nested/Arm/K) beside BindHome;
  graph_emitfn_note appends (kind, origin handle, deterministic name,
  fence) to emitfns_col in lower's walk order — the decls contract,
  non-trailed; SEVEN notes at the seven LFn construction sites
  (lower_call_partial:846, lower_expr_body's lambda, the two fanout
  thunks keyed by thunk_h, lower_stmt_body's nested fn,
  lower_one_arm_decl's arm keyed by the arm body's node,
  reify_frame_k_at's k keyed by ph). The finality measurement that
  licensed construction-time notes: k2_floor's
  LMakeClosure/LMakeContinuation/LDeclareFn arms pass LowFn interiors
  through UNTOUCHED — each body is floored at its own construction,
  so (kind, origin, name, fence) is final where the note fires. The
  read-side contract banked in the op decl: the step-iii
  enumeration-walking emit filters by the reach set, because lower
  runs on every decl and emit does not — the entry list is a superset
  of the emitted set by construction.

- 2026-08-08 · ▶▶▶ THE BIND-HOME COLUMN OPENS THE LOWERING ARC (pin d4d552904d8c —
  CLEAN m2 == m3, census 0, peak 2,369,792 KB inside the ceiling):
  step (i) of the lowering-is-a-column stamp, the smallest marched
  slice — ONE column, ONE writer, zero swapped readers. BindHome
  (nullary-first per the zero-cell law) beside ExecutableBoundary;
  the spine page grows its eighth column with spine_put_bind;
  graph_bind_note lands beside graph_decl_note under the same
  non-trailed contract (lowering runs post-judgment, re-lower
  overwrites with the same verdict); the dual-write sits at lower's
  VarRef resolution arm — the ONE decision site — keyed by the USE
  node's handle, the identity the LowExpr mint discards when it
  replaces it with the binding-time handle (the column already
  carries MORE than the tree). The RGlobal sub-split (ctor/fn/
  missing) deliberately stays a live env read — storing it would
  copy what env_kind_of answers. Found on the way: spine_page:109's
  "the shape's one home" comment was false by measurement — the page
  record's shape is ALSO annotated at graph_branch_seed's op decl
  (types.mn:1790); both homes now carry bind. Readers arrive at step
  (iii)'s re-rooted emit walk; the write-only interval is the
  stamp's own priced transition, named in the column's comment.

- 2026-08-08 · ▶▶▶ THE SOURCE CARRIES ITS RETURN'S LABEL (pin a3ffc8c3e223 —
  CLEAN m2 == m3, census 0, frontier 348/0): Phase 7's felt walk (the
  phase opener, per the felt-path-first law) probed the flow facet at
  three shapes and found the TFun arm reading the row alone — a
  `-> Vault` source over `Vault = String where classified(self)`
  answered Public while `flow pw` on the value answered Secret. The
  arm now joins query_flow_label(ret) with row_flow_label(row)
  (types.mn): a fn's flow character is its return's sensitivity JOINED
  with its capability confinement. Gate born RED against the prior
  boot at exactly the value-Secret/fn-Public split
  (tests/frontier/mn-flow-refined-source.mn + the flow-facet leg).
  Dig lesson re-learned: a shim probe tests the PINNED boot, never the
  just-marched m2 — the fix "not working" was the old wheel answering.
  Two walk truths banked in PLAN Phase 7: predicate_flow_label's
  vocabulary (str_contains secret/classified/sensitive) is a seed
  heuristic `.flowlabel-inference-in-hm` replaces with labels as graph
  facts; and FlowLabel's constructors occupy the user namespace, so a
  program's own `type Secret` collides (the walk's first fixture hit
  it — `type Secret` resolved to FlowLabel).

- 2026-08-08 · ▶▶▶ PERFORM DISSOLVES (pin 1e808f7f4514 — CLEAN
  m2 == m3, census 0): §11 6.5's surface item executed against a
  zero-live-use corpus measurement. TPerform leaves the lexer,
  parser dispatch, render, and TokenKind (64 → 63 variants);
  parse_perform deletes whole; E_RedundantPerform's ctor and seven
  projection arms delete. The stale-fluency spelling parses as
  ordinary expressions and the general diagnostic teaches — the
  turbofish/`handle` precedent's third application, and the
  format-liftable table loses its one keyword-stripping row. SYNTAX
  moves in the same landing (kernel table, token table, checksum,
  the if-example).

- 2026-08-08 · ▶▶▶ THE DECLARED NODE PINS ITS DIM (pin 7cc5ab7f544e —
  CLEAN m2 == m3, census 0, crown 13/0): the effarg peer's identity
  half, one arm — pin_scalar_or_keep's EANode case takes the declared
  operand node exactly as the scalar arms take their literals. The
  false same-name mismatch dies (`with Sample(rate)` no longer
  refuses its own body's tick()); the honest conservative gate
  remains as the fixture's ONE mismatch, both sides rendered by
  name. Hβ.syntax.effarg-node-in-with-clause CLOSES across three
  landings: the parse arm was always there (the fmt render's debug
  form was the masquerade), the render speaks the operand, the
  identity pins.

- 2026-08-08 · ▶▶▶ THE ROW RENDER SPEAKS THE OPERAND (pin 7f3cc86a70fe —
  CLEAN m2 == m3, census 0, crown 13/0): show_eff_arg's EANode arm
  reads the operand node's source spelling live, keeping the debug
  placeholder only for bodyless nodes (the value-dim mints). Found by
  the fifth instance crucible's own write: the debug form broke fmt's
  render→re-parse fixpoint (`Sample(<operand #N>)` refused by the
  canonical render's re-parse), which had masqueraded as
  E_EffArgNotLiteral being live — parse_one_eff_arg's TIdent→EANode
  arm was fine all along, correcting the previous landing's tension
  claim. The conservative-arm crucible (leak-instance-node) lands:
  §11 6.2's five fixtures are whole. BANKED at
  Hβ.syntax.effarg-node-in-with-clause (re-scoped to the identity
  half): the declared Sample(rate) and the charged instance mint
  pointer-distinct EANodes — the same-name mismatch is conservative
  and sound but teaches wrongly; the fix is the charge carrying the
  declared clause's own operand node.

- 2026-08-07 · ▶▶▶ THE ACCEPT GAINS ITS BELT (pin 58197fecea01 —
  CLEAN m2 == m3, census 0): 5.3's named-next (a), the Mycroft
  stability check.
  ty_alpha_eq — a bijective-TVar paired walk over detached Ty values,
  exhaustive over the fourteen arms, rollback-safe because cell
  numbers never compare (only the correspondence pattern; rows
  compare shallowly by sets + tail form, the named v1 boundary) —
  gates the speculative accept: the recheck round's PUBLISHED scheme
  must be alpha-equal to the ASSUMED one, else the plain re-run.
  Closes the unsound window where self-calls were checked against a
  scheme that is not the one published. The fragment fixture still
  runs 3; the K-exhausted teach still narrates; the sig'd path
  untouched.

- 2026-08-07 · ▶▶▶ THE FRAGMENT INFERS (pin 94fd07add038 — CLEAN
  m2 == m3, census 0, micros green; the first form breached the
  anonymity + movers ratchets and was taught — three helper lambdas
  named, movers re-based 458 → 479 on the publish-surface channel,
  the intermediate pin collapsed): §11 5.3's Mycroft iteration,
  built whole against its stamp on the medium's own substrate. Every
  unsig'd decl judges speculatively: round 1 plain under the
  poly_capture diag bracket (multi-effect handler — the three
  Diagnostic ops held in state + its own PolyCapture release op, the
  diag_branch precedent); the common mono case commits
  (graph_commit_checkpoint, the NEW accept half of speculation — pop
  without restore; synth only ever rolled back) and replays its held
  narrations. A poly-fingerprinted refusal rolls back and retries
  under the general assumption (mycroft_prebind — the name poly over
  fresh cells, the sig'd path's shape with fresh vars); a clean round
  2 RECHECKS under its own result scheme (round 3 — the soundness
  round: the result detached via chase_deep BEFORE the rollback so
  the heap value survives, its qvars re-minted and subst_ty'd, the
  row rebuilt fresh-open because the top row cell is unquantified and
  would dangle). Any failure falls back to the plain re-run — never
  worse than the pre-fragment refusal. ACCEPTANCE: unsig'd
  depth(x,n) = …depth([x],n−1) checks CLEAN and runs 3
  (mn-poly-fragment — inference where Haskell and OCaml demand the
  annotation); the teach retargets to the K-exhausted floor (bad
  returns x while self-calling at [x] — round 3's recheck refuses
  honestly, the narration names bad); the sig'd fixture stays green.
  The self-call's row-drop soundness rides the fixpoint argument
  (self ⊆ body); the full alpha-stability detection and the
  multi-call fragment boundary are the peer's named next.

- 2026-08-07 · ▶▶▶ THE REFUSAL TEACHES THE SIGNATURE (pin 7f4bf082992e —
  CLEAN m2 == m3, census 0): §11 5.3's teach, v1, built against its
  stamp with one measured correction — the unsig'd shape's occurs
  fires at the GRAPH WRITE GUARD, not unify's pre-check (the stamp's
  named site), so both report sites gained the narration and the
  guard's is the live one. Detection is the refused cell's own
  FnParam/FnReturn mint reason (no frame widening needed — the stamp's
  frame-membership read simplified to a provenance read); the message
  is conditional and honest, HasPlaceholders. The DiagKind ctor
  T_PolyRecursionSignature rides all seven projection arms. Fixture
  tests/frontier/mn-poly-teach.mn: E_OccursCheck + the narration
  naming depth, leg born RED. MEASURED ASIDE — RETRACTED same
  day (the forensic retraction law): occurs_in_live IS the guard's own
  occurs_in over the same spine (one walk, graph.mn), so no
  disagreement is possible on equal inputs; the two reports come from
  two DIFFERENT binds — the unsig'd shape's occurs arises on a bind
  the unify pre-check arm never sees (the var-var union path), and
  the guard is simply the site that meets it. No trio observation
  stands; the belt architecture is working as designed.

- 2026-08-07 · ▶▶▶ THE SIGNATURE BUYS THE POLY SELF-CALL (pin d8142b3b1d98 —
  CLEAN at the final leg, census 0, micros green; the arc crossed one
  TRANSITION mid-landing): §11 5.3's first step lands whole. The
  judgment half is ONE conditional — infer_fn's bind-before-body keeps
  the prereg quantified scheme for a fn_fully_sigd decl (the mono
  shadow was the one remaining mono writer; group_mono_views already
  exempted sig'd cycle members) — with the belt arm binding mono when
  prereg never registered the name. The emit half is the resurrected
  5.1c guard, needed the hour the judgment gate opened: the demand
  chain mints a fresh mangle per nesting level (depth@[w],
  depth@[[w]], …), so spec_base_count caps a base at 8 specializations
  (the tail floors at the uniform word protocol — correct for every
  vector, containers are words); and the spec ctx's self-referential
  pair (a := [a]) made spec_resolve_build re-apply ctx to its own
  output to stack exhaustion — its TVar arm now floors a binding that
  contains its own var at the word terminal. free_in_ty's reuse
  widened two spec rows +GraphRead honestly. The fixture
  (tests/frontier/mn-sigd-poly-recursion.mn) runs depth(7,3) = 3 end
  to end; the frontier leg pins it, born RED at E_OccursCheck. Emit
  −9,219 lines: the cap floors the wheel's own >8-deep demand chains.
  A stale warm image traps surfaced during the dig —
  .build/warm-compile-*.img restored by a NEWER boot traps in alloc;
  the image key lacks the compiler build (banked below).

- 2026-08-07 · ▶▶▶ THE PRUNE KEEPS FN-TYPED LINKS (pin 26490a437a55 —
  CLEAN m2 == m3, census 0): layer two of the
  under-publish peer. edges_keep_completion dispatches through
  edge_row_of; the prune's own comment ("a bound edge is a content
  link — KEPT") now holds for both row-bearing shapes. The
  acceptance STILL refuses (neg solo Pure, movers 451) — the
  conjunction has a layer the trace reconstruction did not reach,
  and the SCOPE GUARD fires: the dig returns to
  Hβ.infer.forward-hof-row-underpublish's own arc with the
  finalize-input print banked as its next probe; the loop returns
  to §11 phase order. Three verdicts stand from this dig: the floor
  cut refuted-and-reverted, the readers landed on live-path merit,
  the prune keep landed on comment-truth merit.

- 2026-08-07 · ▶▶▶ THE ROW READERS CROSS THE SORT (pin 7343ed3f4aeb —
  CLEAN m2 == m3, census 0, micros green): layer one of the
  under-publish peer's forced fix. edge_row_of (types.mn) is the one
  row-edge content projection — a row cell reads its row, a cell
  bound to a FUNCTION type reads the fn's row — and the complete
  edge-walk census (nine sites: resolve, compress, flatten, occurs,
  free, subst, chase-deep, lower's effects_of and multishot readers)
  dispatches through it, the trio law satisfied by construction. The
  compress site folds but never rebinds a fn-typed edge (that write
  would overwrite the TFun). Acceptance NOT yet: neg still Pure,
  movers still 451 — the fixture shows why, cleanly: sl's own row is
  legitimately its param's free var (effect polymorphism); the loss
  is at CALLERS, where row_keep_completion prunes the bound
  above-ceiling fresh edge before finalize's fold — now capable of
  reading it — ever runs. The trial passed on below-ceiling prereg
  cells; the final/solo die on pruned fresh ones. The named next
  layer: the completion prune FOLDS bound edges before dropping
  transients. Kept per stack-correct-fixes: the layer's own claim
  (readers must traverse fn-typed edges) is measured true and
  mid-judgment gate reads meet such edges today.

- 2026-08-07 · ▶▶▶ THE DECLS COLUMN SEEDS THE QUEUE (pin 2403d0f8f32c —
  CLEAN m2 == m3, census 0, peak 2,340,996 KB inside ceiling; the
  landing's first form breached the eta and quiet ratchets and was
  taught by them — the facet's map lambda became the bare name, the
  projection fns' authored refs dropped for the inferred grade, and
  the intermediate uncommitted pin collapsed into this one): the
  bound-projection stamp built whole, and the reverse-edge peer
  CLOSES. The column: graph_decl_note / graph_decls_at over decls_col
  (the refs column's sibling — append-only, not trail-backed), the
  one writer infer_fn's entry, ~one note per decl per judgment round.
  The projection decl_handles lives in query.mn (one home, two
  readers: the oracle queue's seed and the new "decls" facet), and
  the whole-handle NBound walk (collect_bound_positions) deletes. The
  queue repair, named: the old walk seeded every fn-typed MENTION —
  each re-enumerating its decl's own candidate set, N copies
  interleaved — and lambdas, which have no annotation surface; the
  column seeds judged decls only. The GATE: the "decls" facet born
  RED on the incumbent boot ("error: unknown query: decls"), green
  through this pin (tests/frontier/mn-decls-facet.mn's three decls
  listed at lines 7/9/11), pinned by the new frontier leg. The
  self-build ratchet counts one verb facet grown (decls), one scan
  deleted, one lying name retired (positions_with_dependents).

- 2026-08-07 · ▶▶▶ THE ORACLE READS THE COLUMN (pin 00a91c85efcd —
  CLEAN m2 == m3, census 0, wheel −15 lines, emit −101): the
  reverse-edge peer's second reader. The probe-first law earned its
  keep: the banked stamp said "read the name at pos and count the
  column", and the site trace showed the incumbent answered NOTHING —
  count_dependents asked "which nodes carry pos as a direct child
  handle", but expr_child_handles returns child TYPE handles and a
  FnStmt handle is no expression's child, so surface_area_at(decl)
  was a constant 0 and the oracle's surface-area rank input was dead
  weight from birth. The repair IS the migration: surface_area_at
  matches the decl, answers len(refs_of_name(name)) — the column
  read through the one span-deduped projection — and count_dependents,
  body_references, and the orphaned list_contains delete whole.
  Peak 2,329,624 KB inside the 2,400,000 ceiling. Remaining on
  Hβ.graph.reverse-edge-and-bound-projection:
  collect_bound_positions' bound-cell projection (bound cells are not
  references — its own op), then the peer closes.

- 2026-08-07 · ▶▶▶ THE REVERSE EDGE IS A COLUMN (pin a37869cbfd9d —
  CLEAN m2 == m3, census 0, micros 128/0): §11 5.5's first column
  lands per the banked stamp. Two graph ops (graph_ref_note /
  graph_refs_at, GraphWrite/GraphRead) over a refs column in the
  graph handler's state (smap multi-map — smap_get_all collects the
  bucket, O(bucket) never O(map)); the ONE writer is infer_var_ref,
  noting name → handle ABOVE the env match so a missing name still
  counts (the scan counted it); refs_of_name reads the column
  tail-first (the column prepends; oldest-first preserves the
  scan-era answer order and first-seen dedup) and the O(graph)
  whole-weave VarRef scan (collect_var_ref_spans) DELETES. The BELT
  held byte-identical on untouched files (singleton_perform_block →
  lower:5119,5853; push → types:3107, prelude:284, threading:101).
  The column is append-only telemetry, NOT trail-backed: rolled-back
  branches' notes are dead handles the read side's zero-span skip
  and span dedup drop. COST: peak ratchet seen RED at 2,250,000
  (measured 2,337,908 first run; 2,240,820 on the repin run —
  ~4% run variance) and raised to 2,400,000, component-attributed
  (~36 B/note × ~2.4e6 notes across judgment rounds; wall flat
  15–17s). Next per the stamp: count_dependents reads the column
  per candidate; collect_bound_positions' sibling projection; then
  the remaining scan deletions.

- 2026-08-07 · ▶▶▶ THE WORTHINESS FAMILY PRUNES (pin 2d3b3ca384a9 —
  CLEAN m2 == m3, census 0, emissions identical at 403,741 lines):
  spec_worthy_closure, spec_any_name_in, and spec_name_in delete whole
  — the ref census showed only self- and intra-family references — and
  the sweep's knock-ons ratchet down (movers 453 → 451, effectful
  lambdas 383 → 381). The facts thread rides the candidates scan and
  its unused half prunes when spec_candidates_fix is next restructured.

- 2026-08-07 · ▶▶▶ TOTAL BY CANDIDACY — 5.1a lands, the worthiness gate
  deletes (pin 6fb09a99fb1e — TRANSITION m3 == m4, census 0; emit
  343,679 → 403,741 lines, the banked +17%; RSS 2,201,332/2,216,724 KB
  inside the 2,250,000 ceiling; battery green with the f64-state guard
  at 42 through the TOTAL twin set). Every candidate twins now — the
  selective hybrid whose uniform seam housed every measured
  silent-wrong (sort comparing addresses, the float accumulator
  summing to zero, describe printing a pointer) is gone, and the
  erasure boundary tells the truth. The gate's two guarded classes
  closed first, each by its own landing: the ambient stack cliff by
  zip_with's buffer-counter tail form (mn-zip-deep), the hstate width
  blindness by the twin-edge conversions (THE TWIN EDGES CONVERT, one
  pin earlier — args word-faced, results deref'd, inits boxed, floor
  no-op byte-for-byte). The re-attempt was measurement-first end to
  end: the first drop BROKE (assembly), the break pinned to one
  instruction, the class censused to one instance, the ABI read
  inverted the fix's whole design, and the acceptance probe proved
  assembly before any march. THE SWEEP LANDED same day (pin
  2d3b3ca384a9 — CLEAN, emissions identical): spec_worthy_closure,
  spec_any_name_in, and spec_name_in deleted whole, the ref census
  showing only self- and intra-family references. The facts thread
  rides the candidates scan (same walk, marginal assembly) and its
  unused half prunes when spec_candidates_fix is next restructured.

- 2026-08-07 · ▶▶▶ THE TWIN EDGES CONVERT — Hβ.emit.twin-state-width
  closes (pin ef8083b05fe2 — CLEAN m2 == m3, census 0, cost 14.35s /
  2,188,540 KB inside the ceiling; the f64-state guard holds 42). The
  arc ran measurement-first end to end: the 5.1a gate-drop re-attempt
  pinned the break (fold$sp2nSpan writing its repr-true f64 init into
  the word-wide hstate record with i32.store; the op-result i32 meeting
  the twin's declared f64), the census sized the class to ONE instance
  in 39 fold twins, and the decisive ABI read — the floor's fold takes
  `(param $init i32)`, generic floats riding boxed words end to end —
  INVERTED the mapped width-summed-layout build: the hstate slot ABI is
  floor-owned words because the SHARED arm fns read it, so repr-true
  slots would break the arms, and the fix is conversion at the twin's
  own edges. Two arms, both keyed on the site's typed repr so floor
  contexts no-op byte-for-byte: LPerform's args emit word-faced
  (emit_args_word — the existing arg-boundary box) and its result
  derefs via repr_of(lookup_ty(h)); emit_state_init_writes boxes a
  wide init (emit_wide_ref) before the word store. The acceptance probe
  proved it whole before the march: with the worthiness gate dropped,
  the total-twin m3 ASSEMBLES where it failed. The superseded
  projection/threading/fence map stays banked as the repr-true-arms
  future; 5.1a's re-attempt (cost banked: emit +17%, RSS in-ceiling)
  is unblocked. One process confession: a probe edit reached the tree
  through sed once (the perimeter's Edit-only law violated; the edit
  was probe-scoped and reverted through Edit).

- 2026-08-07 · ▶▶▶ THE ROW HALF LANDS — the snapshot's row channel closes
  (pin a13918ee5784 — TRANSITION m3 == m4, census 0; movers 678 → 453,
  T_OverDeclared 374 → 310; cost 13.68s / 2,105,980 KB inside the raised
  ceiling). The stamped pair, landed exactly as stamped: (1) the prereg
  publish is generalize(handle) — the hand-rolled Forall quantified the
  top-row cell (free_in_ty(TFun) collects the tail) where generalize's
  floor keeps row-sort cells unquantified-and-shared, so forward charges
  now chain the live prereg cell the completion prune keeps, and the
  callee's judgment fills it; (2) the group drain re-parks gates still
  unresolved (cross-group edges) instead of enforcing half-rows early,
  and the pass-tail belt enforces closed truth, reserving
  EInternalInvariant for the genuinely missed. With them: the two +WASI
  widenings the honest rows exposed (row_cap_form, audit_walk — the
  census's own findings), and the gate-path resolves swapped to the
  compressing form (measured VACUOUS for the parked set — unresolved
  chains fold nothing — kept as the correct read for the resolved
  majority). THE MEASUREMENTS AGAINST THE STAMP: movers fell 225 (the
  prediction said ~337 — the row+grade mixed class keeps its grade
  half); 64 false teachings died; determinism held through the full
  ladder (m3 == m4 byte-exact, the two-draw probe identical). THE PRICE,
  attributed by variant runs: +265 MB is the kept-edge substrate itself
  (variant without re-parks: 2,080,964 KB), +106 MB the re-park
  re-checks — representation weight, not re-walk waste; the ceiling rose
  to 2,250,000 with the reclaimers named (the arena's columns-first
  form; rung 3's endpoint where the second pass deletes). What remains
  of the movers: the grade class (param modes read as callee-product
  VALUES — order-dependent until modes ride edges or completion
  propagation) and the 74-ish type-sort set (in-group call-site
  contamination — the scheme-object rule's territory).

- 2026-08-07 · ▶▶▶ THE SWEEP SERIALIZES — the parallel final convicted and
  stood down (pin 737147469c02 — CLEAN m2 == m3, census 0; cost 12.02s /
  1,816,340 KB, the ~3s wall delta the serialization's honest price).
  The arc that led here is the session's deepest forensic dig: the
  row-half build (generalize-at-prereg + the drain refinement) marched
  BROKEN with a one-bit m3/m4 divergence (free_in_fields' k2 yield-floor
  staging), and five probes ran it to the root — the m5 leg killed the
  wash-out story, a same-binary re-run killed the parity story (genuine
  run-to-run nondeterminism), the import census killed clock/random, a
  400MB pad probe killed the 2^31 signed-boundary lead (the padded clean
  compiler's output is byte-identical — address-shift invariant), and
  the corrected trap-on-spawn probe CONVICTED: replacing
  wasi_thread_spawn's one call site with unreachable traps the compile,
  backtrace infer_program_final → planned_layer_sweep → judge_blocks →
  spawn_block. The final pass judges branches on real threads,
  judge_window = 8, and its own comment names the precondition the row
  fix breaks: "published schemes free of live vars." The race is
  precise: instantiate's freshening had given every caller a PRIVATE row
  copy, so bind_edges_to taught private cells — the severance was the
  accidental race-guard; un-freshening it lets same-layer sibling
  callers join ONE shared callee cell concurrently, and the garbled edge
  list is the flipping classification. The landing: judge_window 1 — the
  branches stop overlapping, the machinery keeps its shape, the parallel
  form returns at Phase 9.2 with atomic join writes (banked band-E
  peer). CONFIRMED on this pin: the fix pair applied over the serialized
  sweep compiles byte-identically across two draws, movers 453. One
  process lesson banked: a git stash of the probe edits swept the
  landing edit with them — re-applied and sha-verified against the
  marched wheel input before the bless.

- 2026-08-07 · ▶▶▶ THE PREREG ROW GOES BARE — the movers' declared channel
  closes (pin bb3c10c17e3b — TRANSITION m3 == m4, 26-line emit delta
  crossing one generation; census 0; movers 686 → 678; cost 9.12s wall /
  1,814,108 KB peak, inside the ratchet). The root iteration 44's
  body-ablation cornered: pre_register_fn_sig's skeleton TFun row was
  `mk_ef_open(declared_names, row_handle)` — the authored effect names
  entering the SUPPLY side as presents. Only the trial reads prereg rows
  (the final skips fn pre-registration), so every self or intra-group
  charge through a prereg cell folded the DECLARED flavor into the trial's
  published row while the final published the proof: fill_row emptied to
  its bare self-call still published Memory + Alloc in the trial vs Pure
  in the final. The fix is a deletion twice over: the row goes bare
  (`mk_ef_open([], row_handle)` — a forward ref chains the live cell the
  completion prune keeps as the cycle channel, and the callee's own
  judgment fills it with PROVEN content read live), and declared_names_of
  + the declared_names parameter prune whole — the declaration lives in
  the GATE alone (ruling (1) of the rung-3 laws). THE HONEST MEASUREMENT:
  the channel killed 8 movers, not the predicted 291-family — the
  T_OverDeclared family (374 sites) survives untouched because its
  members' PUBLISHED rows never carried the declared flavor except
  through prereg-mediated charges (self-calls and forward refs), a small
  minority. The 678 remainder is the scheme-value root itself — published
  schemes are VALUES snapshotted at decl exit, rung 3's actual target —
  so the movers instrument now points at exactly one mechanism. Baseline
  movers_max 686 → 678.

- 2026-08-07 · ▶▶▶ THE GATES FIRE AT COMPLETION — rung 3's B4 lands
  (pin c2becbaef475 — CLEAN m2 == m3, census 0; movers steady at 686;
  the pass-tail belt silent). The deferred declared-row gates now
  drain at each group's own completion event — trial_judge_group
  calls the drain after the completion fold, when the cycle's chains
  are closed; solos drain at their own exits; sequential groups make
  the parked-set-at-exit exactly the group's — and both pass tails
  demote to assert_row_gates_drained: a survivor reports
  EInternalInvariant (census-visible) and still enforces, the
  report-never-drop belt. The final pass's old drain was already a
  no-op by mechanism (group membership is set only inside
  trial_judge_group, so final-pass gates always enforced eagerly);
  the assert makes that fact checked instead of incidental. D4's
  timing problem is now closed at the event where the design said it
  belongs; the park/drain machinery's full deletion waits for the
  construction that makes parks impossible. Next: B6 — the cut
  deletes and mn-cycle-charge-freeze greens.



- 2026-08-07 · ▶▶▶ THE ARG EDGE GOES TOTAL-DIRECTIONAL — rung 3's B2
  lands (pin 2a09f3c22a4f — TRANSITION m3 == m4 at 99,476 m2/m3 diff
  lines, census 0 on both legs; movers 691 → 686; the B2-mixed-open
  census marker ZERO on both legs exactly as the stamp predicted).
  The build followed the settled stamp: fn_arg_directional_positions'
  else-arm gains the pure-flow case — a param row chasing to
  EfRow([], [], EtOpen(vs)) with empty presents and absents masks the
  position, runs the same component meet as the cap arm, and binds
  ONE-WAY through effects.mn's existing bind_edges_to (the armed
  E_DuplicateFnName class caught the build's own shadow of that name
  live — the stamp's bind_edges_to was already real machinery, and
  the duplicate died in one edit). The caller-private instantiated
  param cells learn the arg's row; the arg's shared decl cell is
  never written; the 297-site flow the original mask severance
  convicted survives as a READ. Mixed open shapes keep the symmetric
  path with the eprint census marker. Remaining rungs in the designed
  ladder: B4 (the completion drains at trial_judge_group), B6 (the
  cut deletes; mn-cycle-charge-freeze greens), B5's dead-code
  deletions, then the movers measurement fires the pre-committed
  scheme-object rule.



- 2026-08-07 · ▶▶▶ THE STACK HOLDS FLAT — the zip cliff closed, the
  plumbing-twin mystery dissolved into ten kills and one prelude fix
  (pin dedfec69264a — CLEAN m2 == m3, census 0; mn-zip-deep RED at
  exit 134 → 42 through the battery). The forensic chain, counted:
  the total-twinning trap was hypothesized as a twin miscompile, a
  corrupted dispatch, a boot miscompile, an enumerate blowup, a
  list_eq_f64 route, a slice/rest non-progression, and a root-word
  corruption — every one killed by a measurement (binary entry traps,
  emit-diff, coredump-globals forensics with probe values stored in
  added globals, parent-chain capture, five source-site guards, and
  finally threshold-2000 guards naming ENUM len=4696). The truth was
  simple and structural: cons-recursive zip_with spends one NON-TAIL
  frame per element; the emit's enumerate over the fn-name table runs
  under thousands of compile frames; the twin-inflated table (~4,696
  names vs the clean ~3,590) crossed the ambient cliff — and the
  PINNED build sat ~1,000 fns from the same death on its own table.
  The fix is the prelude's own canonical shape: zip_with_fill, the
  buffer-counter tail form range_fill already models, callee-first
  per iterate_from's law; enumerate and zip inherit it. Two residues
  banked: `mentl test <file>` silently exits 0 without judging (the
  battery form is the directory — a verb gap), and 5.1a's blocker is
  RE-SCOPED — with the cliff gone the worthiness deletion crashes
  nothing, so its blowup becomes a ratchet-measured cost question
  (twin count, m2 bytes, peak RSS), re-attemptable on its own
  schedule. The forensic instruments graduated: the globals-store +
  coredump-read scheme is now a named, reusable postmortem channel
  (wasmtime coredumps carry globals, never memory).



- 2026-08-07 · THE VALUE GRAPH REFUTES THE SPLIT — 4.3's core corrected,
  the arena re-sequenced behind the column arc (docs-only; the pin
  stands at 2f5ef189a823). Before family 2 landed a line, one
  substrate fact killed site-classification for the value graph: a
  spine cell is a WORD pointing to a heap record, and the
  Ty/GNode/scheme values the columns and env point at are allocated
  during inference, interleaved with scratch, published later by
  POINTER-WRITE — no extent bracket at the publish site classifies
  them, and a per-decl reset would zero live pointees under every
  column written that decl. Three sound forms priced (nursery
  evacuation; columns-first; no reset); COLUMNS FIRST chosen — the
  5.2/5.5 arc moves published facts into pages and flat buffers, so
  the image set exists BY CONSTRUCTION and family 1's bracket form
  covers it whole. 4.3 pauses at 2a (family 1 + the census print);
  2b's fork/reset DEP-gates on the column arc; families 2-6 land in
  the column era. The refutation is the instrument working: the audit
  leg that would have caught this at runtime was priced into the
  stamp, and the design read caught it first.

- 2026-08-07 · ▶▶▶ THE CENSUS RIDES THE EXTENT — arena 2a-ii opens with
  the delta accounting and the first image family
  (pin 2f5ef189a823 — TRANSITION m3 == m4 at 6 m2/m3 diff lines,
  census 0, battery green through the candidate). The counting form
  matured before any family landed: instead of touching the
  allocator's hot path, the census rides the EXTENT DELTA — the
  outermost image_enter saves the bump watermark into $image_mark, the
  matching image_exit adds (bump − mark) to $image_bytes — so
  measurement costs two branches per BRACKET, not three instructions
  per ALLOCATION. image_bytes() -> Int lands taught-not-performed
  (the generation-lag ladder walked again); the driver's census print
  performs it next pin. FAMILY (1) BRACKETS: spine_ensure's growth
  extent (the table grow + the page loop — pages that outlive every
  per-decl reset), the wheel's first real performs of the pair; its
  declared row widened Memory + Alloc → + ImageAlloc and the solo
  check confirmed the cascade contained. Both march legs ran measured
  (the m4 read_cost path's first live use: 9.31s/9.32s wall,
  1,810,488/1,810,408 KB — the same-session tightness holding across
  generations). The landing's second half was a census catch: the
  march does not gate census, and the bracket's row cascade rode the
  first repin as 12 E_EffectMismatch — the whole driver compile spine
  reaches spine_ensure, so twelve declared clauses were missing
  + ImageAlloc. verify's ratchet refused (0 → 12); the twelve widened
  in place, census back to 0, the pin re-blessed byte-identical.
  Five families remain: env, intern, schemes, the WAT buffers, the
  diagnostic bank.

- 2026-08-07 · ▶▶▶ THE BRACKET'S COUNTING PAIR — arena 2a-i, and the
  step-2 correction the artifact forced
  (pin e524668b29f3 — CLEAN m2 == m3, census 0; micro mn-image-region
  RED→42). Before a line landed, the stamped step-2 mechanism was
  REFUTED by one row read: spine_open_loop allocates its pages through
  the emitted constructors (Memory + Alloc, no wheel-source alloc()
  call), so "swap the growth fns onto ialloc" has no seam, and
  row-only decoration is false prose the medium itself narrates
  against (T_OverDeclared). The classification is the EXTENT BRACKET —
  the gate peer's own form: image_enter/image_exit, depth-counted
  (borrow_enter's shape, heap_mark/heap_reset's pairing idiom),
  landed in this pin as counting emissions only ($image_depth
  demand-gated on the pair's performs, the spawn-cell precedent;
  allocator untouched). Zero wheel performs keep the pin CLEAN — the
  generation-lag ladder walked deliberately: the ops taught first,
  the six family brackets next pin under the taught boot, then 2b's
  one TRANSITION (the $alloc depth-fork, the boundary fixed from the
  census the brackets make possible, the per-decl mark/reset, the
  reachability audit leg). RESIDUE's corrected order carries the
  design; the CLEAN-vs-TRANSITION pricing of each remaining sub-step
  is recorded there.

- 2026-08-07 · ▶▶▶ THE IMAGE GETS ITS VERB — arena step 1 lands the
  ImageAlloc vocabulary (pin b5730e6110ac — CLEAN m2 == m3, census 0;
  micro mn-image-alloc RED→42). The classification layer the six image
  families will declare: `effect ImageAlloc { ialloc(Int) -> Int }` in
  memory.mn with the design note; one name added to
  is_substrate_mem_op — which grounds the effect at the root gate BY
  DERIVATION (effect_ops_substrate_grounded scans the op table; no
  second list to maintain); the emit arm in the step-1..2 form (a
  $alloc call — with no per-decl reset live the spaces are
  indistinguishable, so the row carries the truth and the pointer
  forks at step 3's TRANSITION, named at the arm). Step 0's machinery
  closed its first full loop on this pin: the mechanical block carries
  the machine-written cost line, and it immediately taught something —
  two same-source m3 runs measured 1,817,356 vs 1,743,620 KB, a ~4%
  cross-invocation spread against the ±0.03% same-session band the
  ceiling was derived from. The ceiling stands; the spread is named in
  the pin. Next: step 2, the six families classified onto ialloc, each
  a marched step.

- 2026-08-07 · ▶▶▶ THE GRADE READS THE LATTICE — Phase 4.2 deletes the
  additive count into the mode-paired Usage walk
  (pin 6cd6281a971f — CLEAN m2 == m3, census 0; BOTH ownership
  narration classes at wheel-ZERO; movers re-based 474 → 662; the
  landing crossed two pins — 4115ed285d39 carried the walk, then the
  anonymity ratchet convicted its own three fold lambdas (usage_of
  performs EnvRead → rows without decl homes, 394 → 397 refused) and
  the named last/drop_last walks repinned at the head). The
  build followed the stamp exactly: usage_seq/usage_join relocated to
  types.mn beside the Usage ADT (one lattice home — own cannot import
  infer); own.mn's count_uses family (the NStmt(_) => 0 blanket that
  never counted a statement-level use included) deleted whole into
  usage_of — the (consume, read) pair walk with ⊔ across if/match
  alternatives and mode deciding which component a mention feeds
  (conditions, scrutinees, index receivers, field bases,
  record-update bases read; call args take the callee's own product
  through param_borrows, the classification's new one home that
  infer_call_arg's inline test also deleted into). The fixture's
  three asserts flipped RED→GREEN: no false T_OwnUnconsumed on the
  clean own-callers, finish/stmt_use badge Own, the condition-read
  param badges Ref. THE REFUSED FIRST MARCH WAS THE INSTRUMENT: m3
  refused with exactly one census error — driver_collect_visit's
  `visited` "consumed twice" — because set_contains calls its
  textually-later helper, the not-yet-graded slot defaulted to
  consume, set_contains graded Own, and every caller moved its set.
  The root was param_borrows' unresolved-slot default; the read-safe
  default (a still-Unmarked resolved grade borrows) cleared it and is
  the honest reading — passing to an ungraded or unused product must
  not burn the caller's own. One wheel true-up rode along:
  collect_arm_tags' authored `own init` dropped (fold's f is a param
  callee whose product the grade cannot read; the seed's transfer is
  structural, and band H's bar is fewer authored markers). Residue
  measured, not guessed: the walk's trial-vs-final order-dependence
  surfaced as +188 moved schemes (forward callees resolve between
  passes), banked in the movers re-base with rung 3 named as the
  dissolution; T_UseAfterMove held 0 throughout; T_OwnUnconsumed fell
  to 0 when the one narration's site trued.

- 2026-08-07 · ▶▶▶ THE READ HALF OF AFFINE — Phase 4.1 lands
  use-after-move before the arena can make it memory-unsafe
  (pin 8ba768c810c4 — CLEAN m2 == m3, census 0, wheel T_UseAfterMove
  census ZERO at birth on both march legs). The felt walk's probes
  (grab/peek, twice/seq_after) convicted the exact leg: the affine
  ledger's consume arm checked `borrow_depth > 0` BEFORE the used-set,
  so every borrow-read of a moved own — an if-condition, a match
  scrutinee, a ref-param arg, every seq-op arg (len's resolved Ref
  param walks its arg borrowed) — resumed silently. `sink(xs) +
  sink(xs)` refused (two moves, the armed class); `sink(xs) + len(xs)`
  ran silent (move then read). The dig's false trail is recorded
  because the ROW killed it: infer_seq_op was suspected of skipping
  the mention hook entirely, and its declared row — no Consume, where
  infer_call_saturated carries it — redirected the trace to the arg
  pre-walk (infer.mn:3070) and from there to the ledger's leg order.
  The fix is ONE reorder: `set_contains(used, name)` first; a
  consuming second use stays E_OwnershipViolation (armed, message
  unchanged), a borrow-read of a moved name reports the new
  T_UseAfterMove narration (types.mn: the variant + its six
  projection arms; own.mn: the reorder + read_after_move_msg). Gates:
  run_narration (frontier-gate's Warning-tier sibling of
  run_diagnostic) + tests/frontier/mn-use-after-move.mn, seen RED
  (exit=0, zero narrations, the silent-wrong exact) against the
  unfixed boot; use_after_move_max: 0 ratchets the wheel census where
  it was born. ARMING CONDITION banked in the baseline block: the
  class joins diag_refuses only at held wheel-zero after an
  E_OwnershipViolation-precedent falsification pass (adversarial
  probes on resolved programs). §11 4.2's text stands as written —
  the walk's probes measured the LEDGER handling branches correctly
  (branch_enter/divider/exit) while 4.2's subject is count_uses' Grade
  (own.mn:502 sums if-branches additively; the ⊔-join deletion into
  resume_grade's Usage fold is untouched, next in order).

- 2026-08-07 · ▶▶▶ THE SWEEP REACHES ZERO — the arc loop's twentieth
  iteration closes the last per-module seam
  (pin c46691d75a57 — CLEAN m2 == m3, census 0; the sweep 16 → 0).
  src/cli.mn is born carrying the verb grammar whole: the EntryVerb
  ADT, EntryHandlerInvocation, the VerbSpec table, parse_cli_args, the
  cursor-address parse family, and the target helpers — ~300 lines out
  of main.mn, which keeps only the DISPATCH (running the proven verb
  is the entry's own job). main and mcp both import cli — one grammar,
  two transports, one home, exactly as mcp's own comment ("one grammar
  two transports") had described without the import to make it true.
  mcp's 16 cascade violations (the ParseError/Invocation/VAt
  constructors missing, their binders degrading) died with the one
  import. solo_violations_max ratcheted 16 → 0: THE FLOOR AND THE
  CONTRACT — every module's solo check resolves every name through
  its own declared imports, enforced per landing by the frontier's
  sweep leg. §11 3.5's first half is WHOLE (53 → 17-killed → two
  seams → 0 across four iterations); the overlay proper (scoped
  diagnostics, per-file census, file-true spans) remains the stamped
  second half, and the drift-catalog retirement this zero gates is
  its own named step.

- 2026-08-07 · ▶▶▶ THE HANDLER SEAM CLOSES — the arc loop's nineteenth
  iteration relocates the env and intern substrates
  (pin 2730fa8557df — CLEAN m2 == m3, census 0; the sweep 36 → 16).
  src/env.mn is born carrying env_handler WITH its whole substrate —
  the flat buffer machinery, the 4096-bucket index, the resolve
  family, the dedup walk — and src/intern.mn carries
  intern_table/intern_view/intern_probe; pipeline's 300-line cluster
  deleted, both modules imported by pipeline AND infer (env imports
  types+strings; intern imports types+lexer+strings — no cycles). The
  seam's diagnosis held exactly: the install chain at infer.mn:2310
  names the handlers, so the declarations belong BELOW infer at the
  state's own modules — and one import pair in infer healed all NINE
  affected closures transitively (cursor, oracle, eight_loop,
  gradient_delta, mentl, synth_proposer, lower, wasm rode infer's
  closure). The old pipeline header's claim — "none can import this
  module. The handlers stay here." — was the seam's own alibi,
  refuted by relocating the handlers to a module everyone CAN import.
  solo_violations_max ratcheted 36 → 16 in-baseline; the residual 16
  is the mcp→main verb-grammar seam alone. This is also §5.5's
  env-column move meeting the manifest early: the env substrate now
  has one module home for the column migration to land in.

- 2026-08-07 · ▶▶▶ THE PER-MODULE SWEEP ARMS — the arc loop's
  eighteenth iteration lands Phase 3.5's first half
  (pin f826a9cb1668 — CLEAN m2 == m3, census 0). The solo census
  re-measured: 53 E_MissingVariable across 13 modules (the 2026-07-31
  29/18 figure had aged — mcp joined at 16 and the counts drifted).
  Two one-line imports killed 17: verify→graph+runtime/io (node_handle
  ×11 + eprint_string — verify.mn had imported only types) and
  format→parser (the five handler-arm/state-field accessors the where
  verb's dig already used through query's own import).
  solo_violations_max: 36 banks the ceiling; the frontier's sweep leg
  (one solo judgment per module) enforces it, reaching 0 when the two
  RESIDUAL SEAMS close — and the diagnosis is the landing's real
  yield: the 36 are NOT under-imports. The infer→pipeline handler
  seam (~20 across nine closures): infer.mn:2310's install chain
  names env_handler/intern_view, DECLARED in pipeline.mn a layer the
  DAG places above infer — the declarations relocate DOWN to their
  substrate homes, which is §5.5's env-column move meeting the
  manifest. The mcp→main verb-grammar seam (16): parse_cli_args and
  the VerbSpec roster serve two transports from the entry module —
  the grammar relocates to a home both import. Both fix directions
  banked in the overlay stamp (Hβ.driver.per-module-env-overlay),
  whose second half — tagged env entries, per-module closure
  bitmasks, O(1) lookup filters, scoped diagnostics, the per-file
  census cut, file-true spans — is the priced design.

- 2026-08-07 · ▶▶▶ THE SEQ-OP MENTION TYPES AS THE FACE — the arc
  loop's sixteenth iteration lands Phase 3.3's false-diagnostic drift
  (pin 7d8e91e499a1 — the loop's FIRST TRANSITION: m2 ≠ m3 with
  m3 == m4 at 341,131 lines, repinned from m3 per the arbitration;
  census 0). The root was one projection short: `len`'s env scheme is
  the RAW body's (`(xs: Int) -> Int` — the substrate boundary types
  the body's own parameter as the address word), the saturated and
  holed CALL paths already forced the face (seq_op_sig), and the bare
  VarRef MENTION was the last raw-scheme leak — `xs |> len` unified
  List(Int) against Int and reported a false E_TypeMismatch while
  lower emitted the seq-op dispatch correctly (the felt walk's
  measured diagnose-wrong-emit-right split). seq_face_ty closes it at
  infer_var_ref: a seq-op mention binds TFun(face params, face ret,
  the callee's own declared row) — so pipes, HOF arguments
  (`map(len, xss)` was the same leak), and stored seq-ops all type as
  the face, one read. The TRANSITION verdict is the fix measured: the
  wheel's own seq-op mentions judge differently under the face, the
  emit crossed one generation, and the march ran m4 itself and
  repinned from m3 — blessing m2 would have been the trusting-trust
  mistake the arbitration exists to prevent. The fixture
  (mn-pipe-into-len, exit 3, zero diagnostics through the manifest
  path) and its frontier leg gate both faces; one harness lesson
  recorded: run-micro's stdin path links no prelude, so
  prelude-consuming fixtures gate through compile-path legs.

- 2026-08-07 · ▶▶▶ NAMED EFFECT ROWS ARE REAL — the arc loop's
  fifteenth iteration builds Phase 3.3's named-row drift against its
  stamp (pin 6768ffac9dfa — CLEAN m2 == m3, census 0). SYNTAX
  §«Named effect rows», the section that retired the `capability`
  keyword, has its working spelling: `type Both = A + B` routes the
  type-decl RHS through the with-clause's OWN parse_effect_list (the
  dispatch at parse_type_decl split `|` from `+ - &`; a leading `!`
  routes before the type parse), stores the signed triples verbatim
  on RowAliasStmt, and registers RowAliasKind at pre_register_alias —
  an env fact whose scheme Ty is nominal only for shape, never
  unified. Expansion lives at the ONE home the stamp chose:
  build_declared_row became build_row_seen, whose fold, on a name
  resolving to RowAliasKind, builds THAT alias's row WHOLE and
  applies the outer connective to the result — so the fixture's
  `type JustA = Both - B` (an alias referencing an alias under
  subtraction, the grouping case) runs correctly by construction.
  Cycles refuse (E_RowAliasCycle, then pure — loud then productive);
  `!Alias` is sound only over a positive-closed row
  (E_RowAliasNegation names the boundary). THE CASCADE, paid and
  recorded: eff_name_str/report/env_lookup inside the fold grew its
  row (+Intern +Diagnostic +EnvRead), and because the PARSER's
  fn-type with-rows read the same fold, the parse path itself gained
  EnvRead — eleven declared clauses widened (three cursor, seven
  driver, one effects), each enumerated by the whole-link check, the
  row discipline doing exactly its job. The fixture + frontier leg
  gate both faces (compile silent, run 3); seen RED at
  P_UnexpectedToken on the prior pin.

- 2026-08-07 · ▶▶▶ THE LAMBDA LIST-PATTERN PARAMETER PARSES — the arc
  loop's thirteenth iteration lands Phase 3.3's first measured drift
  (pin 8031eaf123ec — CLEAN m2 == m3, census 0). The root was named in
  §11's own text: the paren-lambda path parses its content as an
  EXPRESSION before the `=>` is seen, and `...` was not expression
  grammar — the "second, weaker copy of the parameter parser" was
  expr_to_pat's reinterpretation ceiling, not a separate parser. The
  fix is the COVER GRAMMAR (the same resolution arrow-function
  grammars use): the list parser mints RestExpr("t") at `...t` (rest
  closes the list — it is the tail), expr_to_pat consumes a trailing
  RestExpr into PList's Some(rest), and anywhere else the marker
  reaches infer it refuses loudly — ERestOutsideDestructure, a new
  DiagKind teaching that rest lives in patterns and `++` joins lists
  in expressions. The Expr variant swept the same total-match roster
  FanoutExpr mapped two iterations ago (collect_fn_decls,
  resume_grade, walk_refinement, count_uses, collect_free_vars,
  flow_edges, lower_expr, render_tokens_for — each a one-line leaf
  arm). THE UNMASKED SECOND ROOT, banked not chased: with the parse
  clean, the fixture's RUN dangles at assembly — the rest BINDING
  emits a hand-baked $make_list call the graph has no edge for, so
  reachability prunes the definition while the call survives; the
  fn-param path refuses solo with one undischarged claim — both faces
  banked as Hβ.lower.list-rest-binding-runtime with the fix direction
  (a graph-visible CallExpr at desugar, the record-rest precedent).
  The fixture graduated to tests/frontier with the parse-half leg
  live and the run-half expected value in its own header for the day
  the peer closes.

- 2026-08-07 · ▶▶▶ MENTL WHERE LANDS — the arc loop's twelfth iteration
  builds Phase 3.2 against its stamp
  (pin 0d3a196299d1 — CLEAN m2 == m3 at 339,110 lines, census 0; four
  marches in one iteration, each CLEAN — the unnarrated intermediates
  collapsed by the march, and the last leg named the verb's own parse
  stage after the anonymity ratchet convicted it). The verb rides the query spine as the
  census did: QWhere through query_default, the badges pure reads —
  `gain : Float @ f64 (inferred)` (repr via repr_of + the TReprPin
  pinned/inferred walk), `tick : Tick op — resume Int ->1 answer` (the
  discipline read off EffectOpScheme's own fourth field),
  `>< [Thread] at :12` / `>< [Seq] at :14` (the static enclosing-tee
  walk, exact by the never-crosses-a-call-boundary law; a lambda or
  nested fn resets the chain — the frame fence's static mirror; the
  handler-covers read is two env lookups, the handler's arms against
  the effect's op roster). TWO DIG LESSONS: the first trap was a list
  PATTERN over env-stored lists (HandlerKind arms, EffectDeclKind ops
  — snoc/slice representations; the parse_query_string flat-protocol
  lesson, §7 face 13, now paid a second time: index walks, never list
  patterns, on any stored list); the second was the field-offset floor
  (`a.op_name` on a list_index element whose type stayed open at emit)
  healed by the wheel's own typed accessor handler_arm_op_name — the
  medium's existing projection over a hand re-read, exactly the
  mentl-first law at the source layer. One fixture correction the
  badge itself taught: the original `threaded` handler covered Tick,
  not Thread, and the badge said [Seq] — the projection read the
  artifact, not the name; parallel_compose (the real Thread coverer)
  yields [Thread]. SYNTAX's lag list shrank by its first name; the
  frontier grew the four-badge leg. query.mn gained `import parser`
  (the accessor's home; no cycle — parser's closure is
  types/effects/graph/canon/lexer).

- 2026-08-07 · ▶▶▶ THE N-ARY LAW LANDS — the arc loop's tenth iteration
  builds Phase 3.1 against its stamp
  (pin 05fd2307ff43 — CLEAN m2 == m3 at 336,495 lines, census 0; the
  iteration's first leg pinned a21b4cdc4c81, then the anonymity ratchet
  convicted three lambdas the build itself wrote and the stages were
  named — the tier's own teaching applied to its author). `><`
  parses through the dedicated FanoutExpr carrier: the left-assoc binop
  loop ACCRETES a `><` run into one node whose branches are a list
  (`a >< b` mints FanoutExpr([a, b]); `>< c` extends it), so
  PipeExpr(PFanout(FanDistribute)) is no longer constructed — the kind
  survives as the census/glyph key and FanShare's discriminant, exactly
  as the stamp chose. Infer walks N value boundaries into TTuple(N)
  (the binary arm delegates); lower enumerates N thunks tagged by
  position into the arity-carrying runtime record (STEP 4's collapse
  meant zero emit change); fmt renders the N-ary vertical/inline canon.
  THE TRAP WAS THE CENSUS INSTRUMENT: the first march's m3 leg died in
  collect_fn_decls — a nested full enumeration (NExpr(...) inside the
  NodeBody match) that the exhaustiveness checker cannot convict across
  pattern depth, so the missing arm emitted the benign else-unreachable
  and trapped at runtime. The ExprPlaceholder tell (`grep
  "NExpr(ExprPlaceholder)"`) censused all five full-enumeration
  walkers in one measurement: infer_expr (had the arm), collect_fn_decls,
  resume_grade, walk_refinement, own's count_uses — each gained its
  branch-list arm in its own recursion idiom. The verdict came out
  CLEAN, not TRANSITION, because the wheel itself never writes a
  reachable `><` — the board's oracles are blind to what the wheel
  never does (tripwire 3), which is exactly why the gate is a MICRO:
  mn-fanout-nary (expect 9) was seen RED as a garbage exit on the prior
  pin (the three-way destructure misreading nested pairs) and runs 9
  with zero diagnostics on this one. One allocation lesson banked in
  place: PFanout(FanDistribute) constructed per render call breached
  two declared rows; the fix is the top-level binding
  fanout_distribute_kind — constructed once, rows intact.

- 2026-08-07 · THE ANONYMITY RATCHET ARMS — the arc loop's eighth
  iteration lands Phase 2.5's second half (tools-only, no repin; the
  wheel is untouched). verify.sh runs the two census queries per gate
  pass — `census eta` and `census effectful-lambda` on the wheel link
  through the just-compiled m2 — and refuses a rise against the banked
  ceilings eta_max: 29 / effectful_lambda_max: 394 (measured at pin
  62542a59bf94; 423 convictions of 555 anonymous, the graph's exact
  read correcting the stamp's ~136 text-shape eta estimate). Two keys
  because the classes fall differently: an eta dies by passing the
  name that exists, an effectful lambda by a named stage gaining the
  row's decl home. Raw CsAnonymous is NOT ratcheted — the tier's own
  silence law protects the pure-local vocabulary. Both arms were seen
  RED at under-set ceilings before the true ones were banked, and an
  empty census answer refuses loudly rather than reading as zero (the
  silent-fallback class, refused at the gate's own construction).
  With this, Phase 2 — every judgment reads the graph, never a
  proxy — is WHOLE: 2.0 the raw-reason law, 2.1 rank-as-projection,
  2.2 the shape-keyed deletion, 2.3 the anonymity tier, 2.4 the
  shared-memory-row recovery, 2.5 the census shapes + this ratchet.

- 2026-08-07 · ▶▶▶ THE CENSUS GROWS ITS JUDGMENT SHAPES — the arc loop's
  seventh iteration lands Phase 2.5's first half
  (pin 62542a59bf94 — CLEAN m2 == m3 at 335,550 lines, census 0). Three
  shapes join CensusShape: CsEta, CsEffectfulLambda (disjoint by
  construction — the effectful arm excludes eta, matching the audit
  tier's precedence), CsIterationCostume (a FnStmt whose body carries
  the index-threading self-call). The MOVE is the migration §11 named:
  the detector families (lambda_is_eta / lambda_carries_row /
  recursion_shape_of and kin) and the one total child projection
  (expr/stmt/body_child_handles) leave oracle.mn for query.mn — the
  census is the detectors' home, and oracle's audit aggregates read
  them through its existing import (the import direction forced the
  move: query cannot import oracle). census_matches gains the handle
  beside the body and widens to GraphRead — judgment shapes read the
  graph at the site (the lambda's judged row, the fn's own self-calls)
  where syntactic shapes read the body alone. The fixture grew three
  sites at pinned lines (eta 24, effectful-lambda 25, iteration 26)
  and the census roster grew their entries, seen RED as "unknown
  query" through the prior pin; all three count their own sites
  through this one. THE REMAINING HALF, named: the conviction-count
  ratchet in verify-baseline (the eta + effectful-lambda whole-link
  counts as banked ceilings that only fall — the tier's convictions,
  NOT raw CsAnonymous, whose pure-local majority is vocabulary the
  tier itself declares silent).

- 2026-08-07 · ▶▶▶ THE ANONYMITY TIER — the arc loop's fifth iteration
  builds Phase 2.3 against the stamp its fourth iteration banked
  (pin eb827fae186d — CLEAN m2 == m3 at 335,287 lines, census 0). The tier
  is a READ beside its siblings (oracle.mn: anonymity_shape_of joins
  pipe_shape_of and recursion_shape_of; pipeline.mn renders the
  section): the eta-wrapper convicts on the body's own raw shape
  (CallExpr(VarRef(g), args) with g outside the params and args ≡ the
  params in order — MachineApplicable, pass g), the effectful lambda
  convicts on its judged TFun row read through resolve_row (the fixture
  proved the read's necessity: ticks' fn row shows Tick absorbed by the
  ~> foot, while the lambda's own row still carries it), and the
  pure-local vocabulary stays silent. The gate
  (tests/frontier/mn-anonymity-tier.mn) was seen RED at zero narration
  on the prior pin; all three faces assert on this one. ONE STAMP
  CORRECTION, found at build time and folded into the stamp in place:
  the quantified-row-param class is NOT an independent conviction — a
  pure lambda landing on a quantified row var is exactly
  `map((x) => x + 1, xs)`, SYNTAX's own vocabulary, and its honest half
  (the published row) is already the row class; the tier reads two
  classes, with escape DEP-named on the use-profile. The solo check
  caught one row omission before the march (lambda_carries_row needed
  Alloc — resolve_row builds rows). 777 lines heavier: the tier's own
  weight, priced by the stamp as one census-class walk.

- 2026-08-07 · ▶▶▶ THE SHAPE-KEYED BRANCH JUDGMENT DELETED — the arc
  loop's third iteration lands Phase 2.2 (pin e1ef0bd41417 — CLEAN
  m2 == m3 at 334,510 lines, census 0; 334 lines lighter than the prior
  pin, the deletion measured). The tier's census found one member left:
  check_branch_is_stage, a partial shape match judging `><` branches by
  spelling — PipeExpr passed, TFun/TVar/NFree chased types passed,
  everything else drew E_BranchNotStage. The quartet fixture
  (tests/frontier/mn-pcompose-value-branches.mn) saw the gate RED on the
  prior pin exactly as §11 measured: `(inc(a)) >< (inc(b))` and
  `(1) >< (2)` convicted twice each (both branches), `(a |> inc) >< (b
  |> inc)` and `(a) >< (b)` silent, all four : Int, the run already
  answering 96. The type-keyed truth was in the artifact all along —
  infer_fanout_value_boundary evaluates each `><` branch as a value and
  the tuple carries the results, so the check contradicted its own
  organ's semantics; `<|`'s stage requirement is
  infer_fanout_apply_one's ordinary application unification and never
  needed the special case. Deleted whole: the check fn, its two call
  sites, and the EBranchNotStage variant with its four projection arms
  (exhaustiveness confirming completeness). SYNTAX §«>< branch typing»
  rewritten to the value-branch law (its old paragraph mis-transplanted
  `<|`'s requirement onto `><`, against its own render examples); the
  diagnostic-table row deleted. The formatter's five chain arms — §11
  2.2's cited evidence — were confirmed history (fixed 2026-07-25 by
  the order-independent judge, the comment at format.mn:142 carrying
  the record), not an obligation. Hβ.infer.pcompose-branch-stage-type
  never reached RESIDUE — it lived in the check's comment and SYNTAX's
  paragraph, and dissolved with them (its design premise refuted by the
  artifact's own measurement). The frontier grows the quartet leg:
  compile silent (zero E_ lines) + run 96, one verdict for four
  spellings.

- 2026-08-07 · ▶▶▶ RANK IS A PROJECTION — the arc loop's second
  iteration lands Phase 2.1 (pin 4e7cfc88 — CLEAN m2 == m3 at 334,844
  lines, census 0). The runner's stamp check paid for itself before a
  line was written: the item's "delete the extraction pass" half had NO
  REFERENT — egraph.mn was born in the prescribed form (canon edges in
  the one graph, extraction = the union-find chase, congruence by live
  operand re-reads, the fan/e-graph range composition already landed
  with its forced prove-then-extract order; the deleted (from,to)
  side-ledger's epitaph is the file header), and today's rewrite set
  shrinks by construction, so no cost model existed to delete either.
  The LIVE half was synth's stored rank, and its RESIDUE entry's own
  prescription executed exactly: `cost: Float` left EnrichedCandidate,
  thirteen enumerator constants (0.1–0.6) left their construction
  sites, and rank_of projects the live candidate ONCE per candidate at
  sort entry — pair-keyed insertion, the callee name read from the
  node, the decl reason from env_lookup, so a constructor call ranks
  through the same one arm (a ctor call IS a CallExpr(VarRef) — the
  entry's design half fell out free) and a nameless candidate carries
  the bare 0.5 base with no invented differentiation. Both measured
  faces die: the sort no longer compares a measured proximity against
  made-up constants, and the extraction-swap site rebuilds without a
  number to ride stale. Cost-neutral by construction — the same
  refs_of_name walk the stored form paid at enrichment, moved to the
  read point. Banked: Hβ.egraph.extraction-cost-composes-repr as the
  RULE-GROWTH CONTRACT (a future non-shrinking rule's "cheaper" is a
  projection composing repr_of/effs_at/use-counts, never a term-shape
  fn; the canon edge carrying the cost's Reason is the named sibling
  Hβ.egraph.canon-edge-carries-reason), gating band G at Phase 5.5.

- 2026-08-07 · ▶▶▶ THE WEAVE READS ITS OWN REASON — the arc loop's first
  iteration lands Phase 2.0 by running its banked probe, which refuted
  the phase's own framing (pin ddcf27c7 — CLEAN m2 == m3 at 334,506
  lines, census 0). The marker-delimited raw-word probe at
  $eq_nPipeKind's entry read the full comparison stream of the `<~`
  census: 28× (0 vs 3), 20× (2 vs 3), four heap pointers vs 3 that
  decoded to tag-1 PFanout records (correctly boxed payload variants,
  correctly unequal — the "boxed nullary" of the prior hypothesis was
  the fixture's own `<|`/`><` nodes), and 2× (3 vs 3) — the feedback
  pair, identical sentinels, the eq answering TRUE. The census's zero
  was the walk's NEXT read: span_of_handle chases to the union-find
  root, a `<~` node's chase lands on the continuation-boundary cell
  (bound bare-Inferred at finalize_continuation_boundaries), the span
  answers zero, and the site is skipped as a synthetic mint. Fix:
  span_of_node_raw (graph_reason_at, no chase) — the weave walk reads
  the node's OWN parse site; chasing is for type resolution, and
  conflating the two is the law this landing names. All six shapes
  count their own sites; mn-census-verbs gained its `<~` line and the
  frontier leg's roster grew to six. Hβ.eq.pipekind-match-eq-divergence
  RESOLVED with six kills, the sixth its own hypothesis;
  refs_of_name's shared chased-span read banked as the
  accident-invariant sibling.

- 2026-08-06 · ▶▶▶ THE MEDIUM COUNTS ITS OWN SHAPES — Phase 0.3's
  structural census lands as a query facet (pin 43cc582afdf7 — CLEAN
  m2 == m3 at 334,486 lines, census 0, crown 8/8, frontier 333/0 with
  the new leg green). `mentl query <file> "census <shape>"`:
  CensusShape = CsAnonymous | CsVerb(PipeKind), classified at the
  grammar's one boundary through show_pipe_kind (the glyph roster
  appears exactly where the external string enters), the walk mirroring
  refs_of_name (span-deduped weave scan), the result QRCensus(label,
  sites) riding render_ref_spans and projecting to AnsRefs at the voice
  (a proven list never drops to Silence). H6 harvested three voice arms
  (tentacle_for_question, question_span, query_result_to_answer) the
  moment the variants landed — the march's census=3 was exactly those.
  THE FACET'S FIRST RUN was its own instrument: census_matches' `pk ==
  k` compiled to raw pointer i32.eq until Intent-Boundary annotations
  (shape: CensusShape, body: NodeBody) routed it to $eq_nPipeKind — the
  documented pointer-eq class, on an ADT, caught by disassembly. And
  the felt walk measured the facet's one blind shape: `census <~`
  answers 0 on files full of `<~` while both sides of the instrumented
  compare RENDER PFeedback — an eq/match divergence banked with five
  kills (lexer/prec/kind-table sound; the pointer floor real but not
  the root; the mixed sentinel/boxed-nullary guard hypothesis REFUTED —
  its emit_eq_leaf_sum experiment made the march rule BROKEN, m4
  refusing 18 claims because the one structural == serves the wheel's
  own row membership, and was reverted whole). The named next probe:
  binary-patch $eq_nPipeKind's entry, read the raw (a, b) words for the
  pair that renders identically and compares unequal
  (Hβ.eq.pipekind-match-eq-divergence, RESIDUE.md). Whole-link counts
  stand as the wheel-ratchet semantics; the per-file cut rides the
  per-module overlay peer.

- 2026-08-06 · ▶▶▶ THE SIGNATURE KEEPS ITS ROW — the crown's higher-order
  leak closed at the completion prune, the instance-erasure root closed
  at effect registration, and the handler-residual seam closed at the
  install read: one session, three landings, the banked probe deciding
  the first build (final pin 04e20d2482fc — TRANSITION m3 == m4 at
  333,715 lines, census 0, crown 8/8; the session's intermediate pins:
  806c7df4 the sig-keep alone, e606a650 adding the instance work).
  THE THIRD LANDING — THE RESIDUAL READS THE INSTALL
  (Hβ.infer.handler-residual-outside-the-scheme +
  Hβ.effects.config-fn-row-in-residual, both RESOLVED): the c05
  re-measurement proved the seam distinct, and the dig found three
  stacked losses — HandlerKind carrying parse-placeholder config tparams
  at all three registration writes (the install read chased cell 4, a
  parse-era handle); the handler-arm scope exiting with an empty
  signature keep (its signature IS the config cells + the handle
  result, so the arms' config-fn edges dropped at the prune this same
  session built); and the edge-only residual finalizing as an ALIAS of
  the free config cell, which read_bound_row reads as pure (the
  root-FREE census line — the finalize's flat store canonicalizes a
  bare single-edge row to the edge's own cell, correct for scheme
  readers who chase THROUGH an edge, wrong for a bound-row read).
  The fix: store the minted tparams in HandlerKind; pass
  signature_free_roots(tparam_cells ++ [s_h]) at the arm exit; read
  the residual as resolve_row(mk_ef_open([], resid_h)) — the shape a
  scheme's row rides; and join each CALLED config arg's row at the
  install (residual_with_config_args — root-membership in the
  residual's edge set is the graph's own record of which config fns
  the arms call; labeled/arity-short installs fall back verbatim).
  Measured: tests/crown/leak-handler-residual refuses (RED-first);
  the each/!WASI vocabulary fixture refuses; the wheel's own census
  surfaced 19 falsely-passing sites — 18 declaration widens
  (Intern/StringTable/GraphWrite/EnvRead/the judge's
  BranchEnv+Consume+WasiThreads+DiagRegister rows — the new bare-
  admits-instanced membership is what makes the bare widens legal)
  plus main's root stack gaining ~> verify_ledger ~>
  diagnostics_handler (Verify, then the ledger's own Diagnostic,
  reaching the root unabsorbed) — converging census 19 → 0 in two
  rounds, TRANSITION m3 == m4, crown 8/8, frontier 332/0.
  The 2026-08-05 dig had proven the drop site (`edges_keep_completion`'s
  `root < ceiling` compare) and refuted a signature keep-set as inert;
  the named next probe — print the collected set beside the dropped
  root — answered both hypotheses in ONE run: collected THROUGH the live
  cells at exit (`signature_free_roots` = unique ∘ flatten ∘ map
  (free_in_ty ∘ chase_deep ∘ TVar) over param cells + return, threaded
  as `inf_exit_fn`'s argument from the named-decl and lambda exit sites;
  scope exits pass []), the set CONTAINS the exact severed root
  ([SIGROOTS run] 29 · [PRUNE keep-sig] root 29 ceiling 25 unannotated,
  69/66 annotated — the banked pair) and the row publishes, so the
  refuted attempt's failure was the COLLECTION (declared slots — the
  live root is reachable only through the cells the body bound; the
  entry unify's union direction does not track mint age, which is why
  even the annotated form's prereg-minted row var chases to a
  judgment-era root) and no downstream re-drop exists. Mechanism: the
  prune's "no constraint can arrive" reading is false for a
  signature-reachable root — it escapes through instantiate at every
  call site, and generalize's signature collection already quantifies
  exactly it, so the keep adds NO quantification and the qvars(f) =
  Σ refs × qvars(callee) blowup bound is untouched. Crown 4/1 → 5/5
  through the probe m2 and green through the pinned boot with the two
  graduated crucibles (tests/crown/leak-hof-named-arg — the
  named-argument face; leak-hof-annotated — the kill test that buried
  classify-by-mint-position). SAME ARC: generalize's quantification
  floor (`_ => Forall(free_in_ty(...))`, the drift-mode-10 commit
  blocker) is exhaustive Ty arms, TCont's world receiving the TFun
  arm's row-sort split (a continuation's world is a row position at the
  TIME altitude); drift-audit CLEAN on both organs. MEASURED STILL
  OPEN, banked with its mechanism split: `fn f(xs) with !WASI =
  each((x) => println(...), xs)` passes with zero effect diagnostics
  over the lib baseline (c05) — the handler-residual face loses the row
  UPSTREAM of the prune (the residual read bypasses the scheme
  instance), so §11 Phase 1.2's "same root, three faces" was
  pre-measurement conflation; the seam is
  `Hβ.infer.handler-residual-outside-the-scheme` +
  `Hβ.effects.config-fn-row-in-residual`, pre-existing at every green
  pin since birth. THE SECOND DIG OF THE SAME SESSION — the arc's one
  remaining frontier red (instance sibling: `hi_rate` publishing bare
  `Sample`, its declared 48000 erased) root-caused to register_effect_ops
  deriving the instance from op TYPE vars alone: `effect Sample(rate:
  Int)` with concrete ops minted a bare ENamed, so every charge erased
  the identity the row algebra distinguishes — an ANCIENT blindness the
  HEAD-era gate masked by publishing the declared row verbatim
  (publish_with_instances), unmasked when the publish law deleted that
  write. Fix, three coordinated parts: (1) declared params become opaque
  EANode value dims on the op row, FIRST so authored scalar positions
  align — eparam_arg_tys skips them, so the type-space install flow
  never meets a value dim, and free_in_eff_arg answers [], so they ride
  instantiation verbatim; (2) the declared gate pins authored scalars
  into matching not-provably-distinct charges BEFORE the subsumes read —
  via graph_finalize_row, because the teaching JOIN dedups the pinned
  entry against the stored one by name (the first pin attempt measured
  exactly that); (3) subsumption's present legs read eff_admits, the
  instance law's positive dual of eff_forbids (bare declaration admits
  every instance of its name; instanced declaration refuses a bare
  charge, frag_args_same on instanced pairs). `hi_rate : Sample(48000)`
  publishes precise; the severance fixtures' refusals hold; the movers
  baseline re-based 406 → 424 (the publish-law re-baseline's own
  precedent — kept sig-edges change what the HOF family publishes, the
  flip census naming map_list/filter_list/flat_fill_*/the float-digit
  fns). The three crucible reds (dsp/ml/adaptive) were the arc's own
  constructor-charge truth unswept in fixtures — six declarations
  widened to their measured rows (tuple returns charge Alloc; delay's
  state element charges Memory + Alloc). Probe instruments preserved at
  .build/research/crown-2026-08-05/ (both wat patch scripts, the c01-c05
  crucibles, every gate log of the landing).
- 2026-08-01 · ▶▶▶ THE CONSTRUCTORS CHARGE — the stamp executes whole,
  and the largest widen loop since the effect-truth sweep runs to zero
  (pin 4a822b299c — CLEAN m2 == m3 at 331,325 lines, census 0, battery
  green through the battery-gated repin). **CORRECTED IN PLACE 2026-08-05
  (the ⟲ law — an entry is history, and the artifact outranks it): THE
  CROWN IS RED AT THIS PIN.** An era bracket over fixed crucibles — the
  git-extracted HEAD boot 69d6c0b0 against this one — measured crown 5/5
  against 4/1 and frontier 332/0 against 322/8, so the regression entered
  somewhere in this uncommitted arc. `tests/crown/leak-higher-order`
  (`fn run(f) = f()`; `fn bad() with !E = run(() => op())`) is REFUSED by
  69d6c0b0 with `E_EffectMismatch: !E vs E` and EMITTED by this pin, which
  additionally offers `T_OverDeclared: body only uses Pure` — the medium
  teaching the developer to delete the declaration that would have caught
  the leak. Root, read off the published scheme rather than guessed:
  `run : (f: () -> t with r37739) -> t` publishes **Pure** — a
  function-typed parameter's row variable sits in the parameter type and
  is never joined into the enclosing row. Three variants discriminate: a
  NAMED fn argument leaks identically (not a lambda bug), a lambda called
  in place is still caught (not a row-inference bug), and with no `!E` at
  all `E_EffectUnhandled` also stops firing (not the negation algebra).
  The fix is `PLAN.md §11` Phase 1, with published sound-and-complete
  machinery behind it (arXiv 2510.20532 §5: propagate the parameter's
  effect variable upward into the enclosing row). Eleven consecutive
  entries above this one report no crown verdict at all — the gate had
  stopped being mentioned, which is why only a captured board could catch
  it; `march.sh` now writes every gate and `NOT RUN` is a visible blank.
  THE CHARGE: every value
  construction — tuple, list, record, record-update, nominal-record
  literals AND the payload ctor arrows — charges Memory + Alloc through
  ONE row mint (construction_row(), the shared read the three infer
  arms and the ctor arrow all take); nullary tags and the tuple-const
  READ stay chargeless (they allocate nothing). The stamp's one false
  claim died to its own probe BEFORE a byte was built: the ctor call
  path did NOT already charge (payload_ctor measured Pure), so the
  arrow gained the row at its mint — the pre-build probe doing exactly
  the pricing rule's job. THE WIDEN LOOP, measured at each round:
  census 181 → 73 → 0 in TWO rounds — round 1 the 108-pair mechanical
  sweep (every pair verified applied against the tree, not the log);
  round 2 the 73-site cascade ring the sharper judge named, including
  four bare synth-mint rows round 1's census could not see (the
  publish law: callers read the PROVEN row, so each round's widens
  surface the next ring). Round 2's locator reads the DECL HEAD near
  the diagnostic's span and verifies the declared row against the
  report's own left side — the raw weave-line arithmetic drifts ~2
  lines per no-trailing-newline file and is not a mapping instrument.
  THE PIN IS BYTE-STABLE: the charge plus 181 widened declarations
  changed ZERO emitted bytes (the same sha before and after the whole
  loop) — the landing is pure judgment truth, Law-7-inert by
  measurement. THE DSP DECISION lands with it instead of parking:
  feedback.mn's six real-time rows drop Pure + !Alloc to the proven
  Sample + Memory + Alloc, the comments that CLAIMED the row proof
  trued in the same edit, and the reclaim is a named peer —
  Hβ.dsp.state-element-install-once (the `<~` RHS spec is a lower-time
  constant constructed once per feedback site, never per tick; when the
  judgment reads that install-once fact, !Alloc returns); stereo_chain
  is the honest exception stated in place (the fanout's result tuple
  IS a per-call construction — the charge is true there, not
  over-approximate). GATES: mn-constructor-row-charge GRADUATED into
  tests/micros (refuse E_PurityViolated — all three faces fire at
  file-local spans through the new pin); movers 414 → 406 RATCHETED —
  eight trial/final divergences were constructor-attribution
  asymmetries after all, so the stamp's "symmetric across passes"
  held for the scan_int_part class but not universally; the surviving
  406 (the fill/float family) remain the trial-only channel, next read
  unchanged (one flip's trial judgment traced at its own charge
  sites).
- 2026-08-01 · ▶▶ THE CONSTRUCTORS CHARGE NOTHING — the movers dig's
  second yield, banked with its stamp (no pin move — a fixture and
  this design only; the board stays green on 3d6f2d0c; the stamp's
  ctor-already-charges parenthetical below is REFUTED — the landing
  entry above carries the correction). THE
  MEASUREMENT, four-line probe through the audit verb: makes_tuple,
  makes_list, and makes_record ALL publish Pure while their lowerings
  allocate — the index-sugar class at the WIDEST surface: a declared
  `with Pure` over any literal is a FALSE PROOF, and the audit's own
  real-time teaching ("!Alloc — proven zero allocation") is unsound
  against every constructor in the language. THE STAMP for the
  landing (next session's step): TRACED — the tuple/list/record
  construction judgments charge Memory + Alloc as PRESENTS (values,
  no edges; nullary tags and the tuple-const READ stay chargeless —
  they allocate nothing; the ADT ctor call path already charges
  through its scheme); PRICED — a name-set union per construction
  site, no allocation beyond today's union, freshness moot (presents
  are values); WRITERS — the three infer arms, enumerated by the
  probe's own faces. THE WIDEN SWEEP IS THE LANDING'S BODY: every
  wheel fn constructing values gains Memory + Alloc in its proven
  row, so the census names each too-narrow declared row (the
  honest-attribution precedent at its widest scale — expect the
  largest widen loop since the effect-truth sweep). The acceptance is
  tests/frontier/mn-constructor-row-charge.mn (BANKED RED,
  unregistered — it joins the contract battery WITH the fix, never
  before: registering now would hold the march hostage). Named
  Hβ.infer.constructor-row-charge. THE MOVERS' MAIN MECHANISM stays
  open and sharper again: constructors are symmetric across passes,
  so scan_int_part's trial-side Alloc (trial Memory+Alloc vs final
  Memory on a tuple-returning scanner) comes from a TRIAL-ONLY
  channel — with charges, sugar, and constructors all excluded, the
  remaining suspects are the trial's group machinery (the completion
  fold spreading a co-member's charged Alloc) and the trial-vs-final
  prereg difference; the next read is one flip's trial judgment
  traced at its own charge sites.
- 2026-08-01 · ▶▶ THE SUGAR CHARGES WHAT ITS LOWERING PERFORMS — the
  415-movers dig opens and its first yield is a false-proof class
  closed (pin 3d6f2d0c — CLEAN m2 == m3 at 331,194, census 0, movers
  415 → 414 ratcheted). THE FIND, probe-first: movers_diff's own
  fingerprints named the flips as trial-side EXTRA names (fill_row
  trial Memory+Alloc vs final Memory; band_energy_loop trial Memory
  vs final Pure — name 27 = Memory, 57 = Alloc, resolved through the
  audit verb's render), and ground truth convicted the FINAL of
  under-proving. The five-line repro then split four faces on one
  file: `list_index(xs, i)` spelled charges Memory; `xs[i]` charged
  NOTHING — the sugar's judgment and its lowering disagreed about
  what the form performs, so `fn f(xs) with Pure = xs[0]` was a FALSE
  PURE PROOF, invisible only because Memory is substrate-grounded
  (the arming licence, not structure — Morgan's mid-dig correction
  reframed it from teaching artifact to the fundamental class it is:
  any derived form whose lowering performs what the judgment never
  charged is a silent row hole). THE FIX at the one force:
  infer_index_force charges list_index's declared row read live from
  the env (the seq-op charge's law at the sugar; the tuple-const
  route stays chargeless — its extraction is compile-time, and the
  fixture's control taught the annotation requirement: an unannotated
  param judges free and takes the generic force). prelude's
  iterate_from widens to Memory + Iterate — the wheel's ONE
  conviction. The refusal fixture joins the CONTRACT BATTERY
  (tests/micros/mn-index-sugar-row — RED-first measured: clean
  through the pre-fix boot, E_PurityViolated through the fixed one;
  auto-enumerated forever). THE MOVERS' MAIN MECHANISM stays open,
  sharpened: symmetric-gap classes are now EXCLUDED (this gap was
  identical in both passes and still didn't explain the flips), so
  the trial-side extra names come from a trial-only channel — the
  next iteration reads one flip's trial judgment against its final
  judgment directly.
- 2026-08-01 · ▶ THE GROUP RE-PUBLISHES ITS WHOLE TRUTH — D4's
  essential half lands at the trial (pin 1da683b6 — CLEAN m2 == m3 at
  331,100, census 0, battery green). group_completion_fold: after a
  multi-member group's walk, every member's row cell re-finalizes to
  its resolved row — co-member content folds through the live charge
  edges, self-edges cut from the store — and group_final_publish then
  re-generalizes over the folded truth. The read is the decl exits'
  own resolve-on-stored shape (no new form; cycle-read termination
  stays artifact-proven, trace-unproven — flagged, the march the loud
  arbiter). MEASURED HONESTLY: the arc's metric did not move — movers
  hold at 415, so the mutual-recursion store class is NOT the movers'
  mechanism (the trial's folded publishes and the final's decl-exit
  stores already resolved to the same fingerprints, exactly as the
  edges design predicts). The fold is the designed completion organ —
  B6's cut deletion and the gates' completion firing both stand on
  it — landed inert-on-emission; THE 415 MOVERS' REAL CLASS is the
  next dig's question, opened by reading one mover's two fingerprints
  (movers_diff) instead of guessing: fill_row / the flat_fill family
  / the float-format family head the list.
- 2026-08-01 · ▶▶▶▶ THE EDGES CARRY AND THE FRONTIER STAYS SMALL — the
  one-way-edge arc lands whole, and the movers metric takes its largest
  fall (pin 13631390 — TRANSITION m3 == m4 at 330,629 lines, census 0,
  battery green, the wheel ~18k lines SMALLER; movers 930 → 415 with
  the ratchet ratcheted DOWN; mn-two-tail-accumulation GREEN for the
  first time, mn-cycle-charge-freeze GREEN a rung early,
  mn-mutual-negation-gate held — all three through the installed verb,
  after two harness false-reds re-taught the one-blob law). THE
  LANDING, five organs, the last two forced by the build's own three
  4GB refutations: (1) THE ONE-WAY CALL+PIPE EDGES — on the bound path
  the expectation's row IS the callee's own crow, so unify_row meets
  identical rows and no-ops at its was==wbs check (D5 executed at both
  edges with zero new unify machinery; the free path keeps fh :=
  expected wholesale, the forward/param channel unsevered). (2) THE
  CHARGE IS THE CALLEE'S ROW VERBATIM — live tail edges intact, never
  a resolve's fold (the B1 revert's liveness lesson: content folds at
  READ time, where reads are pure); callee_own_row, scheme_own_row,
  and the whole post-unify fallback ladder DELETE. (3) THE UNION at
  tail_join (EtOpen × EtOpen → set union) — a second callee's edge
  survives where the first-var drop discarded it. (4) THE
  QUANTIFICATION FLOOR — generalize quantifies SIGNATURE frees only
  (params + ret + the row's type-sort payload vars); a free cell
  reachable only through the top row is a LIVE LINK instantiation must
  SHARE, never freshen — D1's own sentence executed, and the measured
  exponential (qvars(f) = Σ refs × qvars(callee), the 4GB guard inside
  instantiate's mint storm on a 6,458-line lib blob) dead at root. The
  first bare-sig form over-dropped and the census convicted it in one
  march (Float vs Int at the dsp weave — EAType payload vars ARE
  substitutable polymorphism; the sort-split fixed it). (5) THE
  COMPLETION PRUNE at the finalize — a still-free edge minted DURING
  the judgment reads as the pure body and drops (the publish law's own
  unbound reading); a prereg cell below the mint ceiling stays as the
  cycle channel; the ceiling rides infer_ctx state, set by both pass
  drivers and re-armed per branch bracket beside the summaries. THE
  DIG'S METHOD is the entry's other half: the entry-trap probe
  (binary-patch at tail_set_insert's entry — the backtrace shows
  CALLERS, not recursion), the 3GB alloc-threshold sample, and prefix
  bisection on the lib blob turned three anonymous 4GB deaths into
  three named mechanisms; the charge-arm fold built en route was
  REVERTED by its own analysis (a fold at the accumulation unwraps a
  `~>` subtraction's opaque mask — the multieffect-leak class; the arm
  now documents why it must stay a plain join). RODE ALONG: the six
  honest row widens the crisper judge demanded (five driver entries +
  cursor_view_of), and main's dispatch gains `~> intern_table` — the
  process table for the stray Intern extents (discovery parses, solo
  renders) outside any infer_context bracket; Intern is evidence-tier
  (two handlers), so the gate's strict conjunct clears only row-wise,
  and the install IS the row cure plus the live chain node the strays
  dispatch through (inner brackets shadow with their own tables;
  stray handles never cross extents). NAMED RESIDUE: B2 (the arg
  edge's var-tailed one-way bind) is NOT landed — the component unify
  still teaches a shared-cell fn arg at HOF sites (bounded by call
  sites, no longer multiplied by the union's old drop semantics); the
  415 movers are the next dig's worklist; the driver widens carry
  T_OverDeclared tighten invitations; B4's drains and B6's cut
  deletion (row_without_self stands, sound-conservative) complete the
  rung, with mn-cycle-charge-freeze's early green suggesting B6 may
  arrive cheaper than designed.
- 2026-08-01 · ▶▶ THE FRESH ROW CELL WAS A LIVE EDGE — B1 built, marched,
  and REVERTED by the measurement it exists to serve (no pin move; boot
  restored to 1efe083a, board green at movers 1197). THE BUILD: the
  one-way call and pipe edges exactly as D9 rung 1 specified — on the
  bound path the expectation's row IS the callee's own `crow`, so
  unify_row meets crow ~ crow and no-ops at its `was == wbs` check,
  deleting the hub's per-caller teach-back with zero new machinery (one
  chase serving both the arg mask and the row); the free path kept
  verbatim, the pipe's charge rewired to read the stage's TFun row. It
  MARCHED — TRANSITION m3 == m4 at 349,440 lines, census 0, micros and
  the contract battery whole. THE LEASH THEN REFUSED IT (movers
  1197 → 1230) and the two-boot fixed-input probe made the refusal a
  DIAGNOSIS rather than a budget question: the same 6,458-line lib blob
  answers 85 movers under 1efe083a and 99 under the B1 judge — behavior,
  not workload (the A1 precedent's byte-identical-under-both-judges
  reading does NOT hold here) — and the stderr diff names the mechanism
  outright. `filter_list`, `map_list`, `race`, `race_internal`,
  `collect_verified_survivors`, `tiebreak_declared_intent` and seven kin
  all resolve their bodies to **Pure** under the new judge where the old
  proved `Memory + Alloc`. THE FINDING, and it is the session's yield:
  THE TEACH-BACK WAS ALSO THE CHARGE'S LIVENESS. The fresh `row_h` bound
  into the callee's edges left the caller holding a cell that resolved
  LATER through the graph; delete the write and `callee_own_row`'s
  resolve folds the callee's row at a moment its own body may be
  unjudged, so the caller banks a bare VALUE forever — Carried-Truth
  inverted at the charge, a snapshot where an edge belonged. So the
  one-way edge CANNOT land until the charge is itself an edge (a bare
  `EtOpen([callee_root])` chaining into the callee's live cell —
  scheme_own_row's own form, generalized past the co-member gate), and
  that needs the UNION first, because tail_join's first-var drop would
  discard every callee's edge after the first. B1 + B3 + the
  charge-as-edge are ONE move; B4's drains close the cycles. The ladder
  is corrected in place at D9 rung 1 (the alive-law), and the pricing
  rule takes its third payment: B1's stamp priced the WORK per call and
  never traced the read's LIVENESS — "priced" must mean the read's
  freshness as well as its cost.
- 2026-08-01 · ▶▶▶▶ THE PROOF IS THE INTERFACE — the publish law and
  the flat-cell write half LAND in the executing judge, and the
  fixture that could only green under gate-only semantics goes green
  (pin 1efe083a — TRANSITION m3 == m4 at 348,948 lines, census 0 at
  the new judge, battery 121/0 through the new wheel, the
  battery-gated repin's first BLESSED use). THE LANDING: a published
  row is the body's PROVEN row — enforce_row_gate's declared-row
  publish, its EtAll inter, and the lag PIN are DELETED; the
  declaration is a GATE plus an ABSENT-only refinement joining an open
  tail's cell (bind_open_to_neg's mechanism as the one authored
  write); the unbound cell reads as the pure body (over-declared
  teaching, no fabricating bind — the EtAll fabrication the park
  measured three ways at this exact arm is structurally gone). WITH
  IT, THE FLAT-CELL LAW's write half: flatten_row_stored at BOTH graph
  write ops folds every stored row to depth 1 under the reading law
  (graph.mn's own mechanism vocabulary — merge_row's precedent), so no
  read path ever recurses stored chains. mn-mutual-negation-gate
  COMPILES CLEAN (rc 0, zero mismatches — the `Cast + !Mutate`-over-
  mutual-recursion class dead at its root: no pin, no fabricated
  universe-minus to refuse through); the 112,259-line m2/m3 diff is
  the judge crossing one generation, self-reproduced at m4. THE UNION
  STAYS OFF, and its second conviction sharpened the finding into the
  design's own pre-committed channel: with flat cells the reads were
  shallow and the SETS still exploded — thousands of distinct fresh
  edges accumulating at SHARED LOOSE-PREREG CELLS, one per forward
  caller's teach — which is not a row-representation problem but the
  schemes-as-shared-snapshots root itself, the SCHEME-OBJECT half's
  territory arriving early as the union's blocker (decision (3)'s
  measurement, delivered before the movers count could). The A2
  remainder is now exactly: the scheme-object decision (per its
  pre-committed rule, now with this measurement in hand) → the union
  flips on → mn-two-tail-accumulation greens → A4 deletes the cut.
  THE HUB'S EXACT WRITER, found the same night (one grep past the
  landing): infer_call_saturated builds expected =
  TFun(params, ret, mk_ef_open([], row_h)) and runs the SYMMETRIC
  unify(fh, expected) — when the callee's row is OPEN (a shared
  loose-prereg cell), the Open~Open arm's a-side is the CALLEE, so
  bind_edges_to teaches the CALLEE'S SHARED EDGES a row chaining to
  each caller's fresh row_h — one teach-back per caller, the hub. This
  is D5's one-way law (teaching flows decl→site ONLY) violated at the
  row's own call edge — and the cure's precedent sits two lines up in
  the same fn: fn_arg_directional_positions already MASKS argument-row
  positions from the wholesale unify for exactly this reason. THE
  DESIGN FORK for the fresh pass (the pricing rule applies): (a) mask
  the TOP-LEVEL row from the call-edge type unify + bind row_h as a
  READ-side alias of the callee's row after fh resolves (the
  scheme_own_row bare-edge form) — with ONE open channel to settle:
  the unresolved-forward-callee path, where fh := expected wholesale
  and row_h legitimately BECOMES the callee's row cell (the
  forward-ref teach channel the mask would sever); or (b) direction
  at the row arm itself (bind the fresher/caller side) — rejected on
  smell (the arm cannot know which side is the caller; direction is
  the CALL EDGE's fact, not the algebra's). Form (a) with the
  forward-ref channel answered IS the scheme-object decision's
  minimal landing: no scheme objects, no band bits — one directional
  edge at one site, D5 executed where the measurement demanded it.
  AND THE EXTENDED PRICING RULE GOVERNS THE LANDING ITSELF: "one
  site" is a one-grep count, not a census — the landing OPENS by
  enumerating every unify whose a-side can be a shared open row cell
  (the call edge found; the pipe edge, the install edge's residual
  unify, op-registration/effect-op edges, the annotation and gate
  unifies) and masks each site the census convicts, or records why
  its a-side cannot be shared. The mask lands census-complete or the
  hub reappears one edge over. THE CENSUS RAN THE SAME DAY and
  convicted the count on schedule — THREE Class-A sites, not one
  (call + pipe + the arg edge's var-tailed path, with the partial
  path a named cousin) — and the fresh pass RESOLVED the fork
  sharper than form (a): the mask is the IDENTITY — expected's row
  IS the callee's own crow on the bound path, so the Open~Open arm
  meets crow ~ crow and no-ops with zero new machinery, and the
  forward-ref channel answers itself (the free path has no row to
  read, so the mask never applies there and fh := expected keeps
  today's wiring whole). The complete design — the three-class
  census, the B1–B6 rung ladder, B5's deletion dividend (the mono
  view's row-quantification exception and the whole
  callee_own_row/group_member channel die as dead code) — is D9
  rung 1 in the schemes-are-edges entry, the one home.
- 2026-08-01 · ▶▶ A2 ATTEMPTED WHOLE, MEASURED, AND PARKED — the union
  writer, the judged bind sites, and the publish law were BUILT
  TOGETHER (exactly as the settled laws demanded — the census proved
  the pairing forced: with the union live, boot's declared-row pin
  delivered fabricated EtAll through every completed path, census 5 at
  the driver entries), and the wheel then convicted the build at TWO
  deeper layers, each a permanent law: (1) THE ROW WALKS ARE
  MECHANISM — the A1/A2 fold/filter/any forms put the resolver ON the
  Iterate handler machinery, and the first multi-edge walk FLOORED the
  k2 yield boundary from inside a fold's own yield arm
  (tail_set_insert → resolve_edge_compress → op_fold_handler_yield,
  exit 134 at m3's first trial unify) — every row walk is now
  STRUCTURAL recursion (graph.mn's chase discipline; landed, kept);
  (2) THE HUB-CELL WALL — with the union live the m3 leg died in
  tail_set_insert at the 4GB guard, one insert walking a
  thousands-element set: hub cells taught by many callers accumulate
  edge sets at wheel scale, and UN-MEMOIZED resolution over DAG-shaped
  tails re-walks shared substructure combinatorially (the linear-chain
  era never had DAGs; the read semantics the design owed is now
  written — THE FLAT-CELL LAW in the settled-laws block: flat-on-write
  + compress-on-read + completion-bounded breadth + the depth census —
  and the corpus had held its core uncited since 2026-07-22, the
  canonical-on-write arc; Morgan's rebuke named the exhaustiveness
  failure and the law closes it). THE PARK: the two
  semantic switches reverted in place (tail_join keeps the first set;
  the gate keeps the era's declared publish+pin, both carrying their
  CONDEMNED records), the A2 machinery stays pre-staged and inert over
  singletons, and the fixpoint HOLDS (CLEAN m2 == m3 at 349,630
  lines, no trap) — but the parked judge convicts the wheel CENSUS 34
  (E_EffectMismatch: bodies resolving `… + !Mutate + Any` — an EtAll
  edge folding in through the solo-negation publish family — at the
  fp_* fingerprint walks, the egraph gates, occurs_in_live, the
  driver entries, verify_each_enriched: every family riding
  resolve_row). THE OPEN DIG, banked with its instruments: the
  A1-vs-park delta is ~6 candidates (the structural-walk group
  membership — resolve_row/resolve_edges/resolve_edge are now a
  Tarjan cycle where A1's recursion rode the fold's HOF edge; the new
  helpers' declared rows; the judged unify arms); the first probe is
  `query "type resolve_row"` under the parked m2 (is its published
  row `!Mutate + Any`?), then bisect the six. The full tree diff is
  banked at .build/research/tree-a1-plus-a2parked-2026-08-01.patch;
  the board is HONESTLY RED (census ratchet) until the 34 resolve —
  an uncommitted mid-arc working state, A1 beneath it proven.
- 2026-08-01 · ▶▶ A1 LANDS — THE TAIL IS AN EDGE SET, behavior-
  preserving and marched (no pin move — the tree rides ahead of
  69d6c0b0 until the blessing; CLEAN m2 == m3 at 347,334 lines,
  census 0 both generations, battery 121/0). EtVar(Int) is DELETED
  from EffTail; the open tail is EtOpen([Int]) — §4①'s
  sorted-handle-set, ef_make canonicalizing EtOpen([]) to EtClosed —
  swapped across all seven files in one sweep with H6 as the census
  (the compile came back census-0 on the FIRST pass). The READS took
  their N-correct forms now, zero semantic freedom under the settled
  laws: resolve and its compress twin fold every edge through ONE
  shared assembly (edge_content_into — presents through the mask,
  absents joining, residual tails merging, EtAll absorbing —
  identity-until-progress preserved exactly), the chase-face value
  boundary and the frozen-read subst ride the same assembly,
  free/occurs/changes collect over every edge, and the fingerprint
  renders the edge set through the alpha map. The BINDS stay
  singleton-explicit (last(edges) — the sole edge by the A1
  construction contract stated at the EffTail decl: no union writer
  exists yet, so a multi-edge set is unconstructible; the A2 rung
  lands the union WITH the judged bind sites — the half-step's
  lesson). The condemned cut and the first-set drop keep their exact
  shapes over sets, fates restated in place. THE MOVERS LEASH DID
  ITS JOB EN ROUTE: 930 → 956 and the ratchet REFUSED until the
  fixed-input probe proved the rise workload-not-behavior — the
  unchanged lib blob answers 48 movers with the byte-identical name
  list under BOTH judges, and findtag runs 7 through the A1 wheel —
  so the ceiling raised with the measurement in its comment (the
  next legal move is DOWN). Acceptance battery as expected: the
  three graduated micros GREEN; cycle-charge-freeze /
  mutual-negation-gate / two-tail-accumulation stay RED for A2–A4.
- 2026-07-31 · ▶▶▶ THE HALF-STEP REVERTS AND THE BATTERY NAMES ITS
  CLASS — rung 0 executed: the guard pair withdrawn by its measured
  regression, boot RESTORED (pin 69d6c0b0 — the stage-law pin stands;
  the bb8b93a2 / 3fa5f0c7 pins are WITHDRAWN, unblessed heads dropped
  from PROVENANCE). THE BRACKET FIRST: the three red micros
  (findtag / mapelem / mapfield, exit 134 — the first battery ever run
  over those pins, hidden by the OOM) ran under all three boot
  generations: HEAD 69d6c0b0 answers 7/2/2, staged bb8b93a2 traps,
  working 3fa5f0c7 traps — the GUARD PAIR is the breaking landing and
  the EtAll carve-out is exonerated as trigger (reverted with it; it
  existed only to patch the guard's fallout). THE MECHANISM, read off
  the judges' own instruments on one micro blob: movers 48 → 111;
  pick's body row rendering Memory + Alloc + !Iterate + r26098@e13 —
  a parked subtraction mask and a LIVE row var in a published row;
  iterate losing its own Iterate presence behind a live tail; head's
  convergence flips tail-only against staged's CONTENT flips
  (presence arriving only at the final). One sentence: the guard
  moved the cut to the read and let live tails escape into published
  rows with NO completion event to drain them — fragment/payload
  joins behind those tails never fire, so the element instance riding
  the yield op's payload never teaches a HOF lambda's param (field
  offset unprovable → the trap), and parked masks surface as
  !Iterate-carrying bodies at forty closed gates. Discriminators
  pinned the class edge: find + arithmetic lambda GREEN, inline-list
  + field GREEN, a local find copy GREEN — prelude find's handler
  channel + a field demand + the element-via-annotation is the exact
  shape. THE FORTY'S DIAGNOSIS IS ANSWERED BY THE PROBE: neither
  honest under-declarations nor a tail-render question — the
  half-step's own artifact, dissolved by the revert; the widen loop
  would have canonized un-drained reads into forty signatures and is
  REFUTED. The revert is exact (zero non-comment delta on
  effects.mn / infer.mn against the stage-law pin); both sites carry
  their fates in place (row_without_self: CONDEMNED whole-or-nothing,
  deletes only with D3+D4 landed together; the bind-site EtAll
  fabrication banked for D3's absent-mask law). The three micros
  GRADUATE to the row half's acceptance battery beside
  mn-cycle-charge-freeze and mn-mutual-negation-gate — element-
  instance crossing is the exact class D3's edge-set tails + D4's
  completion drains must keep green.
- 2026-07-31 · ▶▶▶ THE CUT BECOMES THE GUARD (WITHDRAWN same day —
  the entry above carries the measurement: the guard shipped the
  findtag/mapelem/mapfield exit-134 class, the battery-gated repin
  refused the pin, boot restored to 69d6c0b0; this entry stands as
  the era's record) — rung 3's first
  structural half, landed with its census honest (pin bb8b93a2,
  CLEAN m2 == m3 at 393,158 lines, **census 40**). THE CHANGE, two
  lines of substance: `resolve_row` carries the cells it is already
  resolving and skips a revisit — R ∪ R = R, so the fold computes a
  recursive row equation's least solution at the READ — and
  `row_without_self` becomes that same guard SEEDED with the fn's own
  cell, replacing a handle compare. The recursion decision therefore
  moves from the publish to the read, which is the whole fix: the self
  cycle still closes (callers and the gate read a value), while every
  CO-MEMBER edge stays LIVE, so a cycle member's effects can arrive
  after its own decl exit — the one thing the old cut made impossible.
  PROVEN on the minimal reproduction: `self_first`, the member that
  lost its co-member's effect, is FIXED (mn-cycle-charge-freeze goes
  2 movers → 1; `co_first`'s remaining flip needs the edge SET, which
  is rung 3's other half). THE CENSUS IS 40 AND THAT IS THE STATE OF
  THIS PIN, recorded rather than hidden: with co-member effects
  finally arriving, forty declared rows meet bodies that resolve to
  more than before. The diagnostic renders them as POSITIVES
  mismatches whose positives plainly fit, which is `show_effrow`'s
  tail-blindness (the effects audit's §5) making an EtAll-vs-EtClosed
  disagreement unreadable — so the FIRST move of that dig is landing
  the tail render, not another guess at the algebra. TWO GUESSES WERE
  MEASURED AND REVERTED, both banked so neither is re-chased:
  deleting the cut outright (census 70, movers 930 → 1476, wheel +47k
  — proving the cut does TWO jobs and only one is the defect), and
  closing the negation publish's tail per the audit's own prescription
  (census 70 AND m3 ≠ m4 — the negative stance reaching a caller is
  not by itself this class). Morgan's cut governs the sequencing here:
  nothing is in production, the ultimate form is the only target, and
  a nonzero census on a self-reproducing pin is an honest waypoint —
  the ratchet's zero is restored by the widen/tail-render dig, not by
  reverting the structural fix that made the defect visible.
- 2026-07-31 · ▶▶ THE STAGE LAW REACHES THE STRINGS — the fleet's
  user-path findings land where a beginner actually stands
  (pin 69d6c0b0). Two silent-wrongs on the plainest lines in the
  language, each measured on the prior boot: `"a,b,c" |> split(",")`
  answered ONE part at exit 0 — datum-first bound `s = ","`, so the
  pipe filled `sep` with the data and the call split the SEPARATOR by
  the list, and because both parameters are String nothing in the type
  system could catch it (the signature ORDER is the contract) — and
  `join(["ab","cd"], "-")` TRAPPED at exit 134 with zero diagnostics,
  because join_loop's unannotated params left the element type free and
  `++` reached its no-guess floor INSIDE SHIPPED LIBRARY CODE. The
  refusal was right; its form was an `unreachable`. Both are now
  config-first / datum-last with their Intent Boundaries pinned, four
  call sites moved (words, lines, unwords, unlines, the query grammar,
  the session wire), and the comment that claimed a `str_concat` repair
  never present in the body is trued to the pins that are. The contract
  is EXECUTABLE (tests/frontier/mn-stage-law-strings — split, join,
  round-trip, and words through the pipe, 42), so the class cannot
  regress silently. CLEAN m2 == m3 at 346,221 lines; census 0; frontier
  332/0; micros 121/0; proof-exactness 9/9; crown 5/5. The eight
  remaining Stage-Law violations and the audit's stage-shape tier (the
  verb-shape tier's sibling, which makes the class self-policing) ride
  `Hβ.prelude.stage-law-and-reachability`.
- 2026-07-31 · ▶▶▶ THE SOLO IS A CYCLE, AND THE COUNT NAMES THE SOURCE —
  Morgan's cut ("explore the very source of issues") turns a symptom
  sweep into the arc's forcing artifact (pin 74d63b7c). THE FIX FIRST:
  the cycle discipline's entry test `len(members) > 1` was a WRONG
  PROXY for cyclicity — a self-recursive singleton IS a cycle, and the
  discipline's two live pieces (the mono view, the group membership the
  charge reads) apply to every group; only the exit sweep is genuinely
  multi-member work (a singleton has no late member to carry, and
  re-publishing appends an identical env entry per decl). MEASURED, both
  forms marched: 1,764 movers with the gate against 930 without it —
  47% of every weave's trial/final divergence was the excluded solo —
  and the wheel emits ~3,700 lines SMALLER under the sharper trial.
  THE INSTRUMENT: movers_line gains its TOTAL (the sixteen-slot display
  named the class and hid the magnitude — a family that saturates reads
  identically to one that fills it exactly, which is why a new mover in
  user code hid behind known lib movers for a week). THEN THE DIG, and
  it is the session's finding: 930 minimized to FIFTEEN LINES
  (tests/frontier/mn-cycle-charge-freeze.mn, banked RED) by reproducing
  the flip on the lib weave alone (83 movers, a one-second loop instead
  of a ten-minute march — the instrument choice that made bisection
  cheap). THE SOURCE, stated exactly: A CYCLE MEMBER'S ROW IS PUBLISHED
  AS A VALUE AT ITS OWN DECL EXIT — a moment when its co-members have
  not been judged — so the effects they later prove never reach it.
  Three deliberate mechanisms compose to it: scheme_own_row charges a
  BARE edge (names stripped, the fix for the fragment-join hazard that
  cost 52 Int-vs-List(Float)); tail_join keeps the FIRST var, so a
  second co-member's edge is dropped entirely (one tail slot); and
  row_without_self CUTS a self-rooted tail to closed, freezing the row
  at that instant and severing the surviving edge. THE ASYMMETRY IS THE
  PROOF and it inverts the obvious reading: the member charging its OWN
  row first goes WRONG (self_first: trial !E1, final !E1+E2), while the
  member whose accumulated tail happens to be a CO-MEMBER's var keeps a
  LIVE EDGE, never cuts, and resolves correctly later (co_first: no
  flip at all) — the open tail is the honest form and THE CUT IS WHAT
  BREAKS IT. This is the Carried-Truth Law at the judgment's own
  publish: a row published as a value is a COPY of what the graph knew
  at decl exit, where an edge read live is correct. It unifies three
  fleet findings under one root (the multi-callee false !E, the
  tail_join first-var drop, the 930 movers) and gives rung 3 its
  acceptance test: a charge DRAWS AN EDGE into the callee's live row
  cell — N edges per cell, not one tail slot — and the least solution
  is the join's own idempotence, R ∪ R = R, no cut. CLEAN m2 == m3 at
  346,221 lines; census 0; frontier 332/0; micros 121/0;
  proof-exactness 9/9; crown 5/5.
- 2026-07-31 · ▶▶ THE INSTRUMENTS JOIN THE REGISTER — the fleet's top
  convergence executed: six of twelve reports named the ungoverned
  narration channel, and it closes at the register's own law
  (pin 24d9f96f). The compiler's instruments were raw stderr on every
  user verb — ~28 lines (the 16-name movers block, four convergence
  flips with raw fingerprints, the wheel's OWN verify obligations at
  types.mn spans) before a hello-world's first output; the syntax
  auditor graded it the single highest teachability-per-line fix and
  the lib auditor measured it opening lesson 00. THE FORM: DiagRegister
  gains the scope READ (diag_scope_of — the register's live value, one
  arm on the root diagnostics_handler), and each instrument applies the
  register's law to its own lines: the movers/convergence block prints
  only under ScopeAll (it is never about the user's file — the march,
  census, and battery never perform diag_scope, so the maintainer
  channel keeps every line byte-for-byte); a debt line carries a SPAN,
  so it renders exactly when that span is in scope (diag_report's own
  test at the instrument) — the first blanket form was convicted by the
  frontier's interval leg in one run (a user's OWN pending is their
  teaching surface, "this claim was not checked", and must render;
  only the wheel's obligations quiet). One honest widen
  (driver_check_entry +DiagRegister). FRAGX stays unguarded BY ITS OWN
  SITE'S LAW (an arm-perform rides the handler's residual past every
  bracket — the face-pollution class the root-row gate once refused;
  it appears only on wheel-scale checks besides) — named residue with
  the census-to-zero route: the collision class closing deletes the
  line. MEASURED: a user's `mentl run` stderr 28 → 0 with stdout
  untouched; the march's m3 leg keeps the movers narration and all 12
  debt lines; CLEAN m2 == m3 at 349,657 lines; census 0; frontier
  332/0; micros 121/0; proof-exactness 9/9; crown 5/5. The fleet's
  ranked program continues: the solo-inclusion one-liner, the
  echo-stop leaf coverage, the TEof recovery, run-refuses-on-error.
- 2026-07-31 · ▶▶ THE FLEET'S FIRST TWO CORRECTIVES — the twelve-auditor
  fleet convicts the day's own landing within hours, and both fixes land
  marched (pin 3c0ee1a1). Morgan dispatched twelve auditors (six Fable,
  six Opus, one per subsystem — reports in .build/research/audit-*).
  CORRECTIVE ONE — reported, refuted, retracted, and finally PROVEN
  TRUE by the decisive instrument, all in one session (the ⟲ law at
  fleet scale; this entry superseded its own first two forms in
  place): the effects auditor measured the deferred row gate
  swallowing the `!E` crown for effect-polymorphic tails; the
  cross-audit refuted the claim off capture files and both auditors
  retracted; the infer auditor then re-executed the GIT-EXTRACTED
  historical boot twelve times — 12/12 deterministic silence — proving
  the original finding real and the refutation the measurement error
  (the MTIME FALLACY: the boot file's mtime records only its last
  write, an intermediate fixed boot had already repinned, and an
  unstamped post-fix capture compounded the misread). The delivery
  mechanism, attributed at the site: a non-member's deferred gate
  parked in a BRANCH instance's infer_ctx (branch_judge's facts tuple
  carries no gates channel), and the branch bracket's death took the
  parked gate with it — the pass-tail drain never held it. The
  corrective moots the whole channel: the deferral is GROUP-GATED
  (group_member — the same parse-truth fact the live charge reads), a
  non-member's free tail enforces eagerly at decl exit, and the
  final's gates all fire eagerly (group_names is trial-scoped). p13
  refuses at both lines; pingpong holds Pure ×3; TRANSITION m3 == m4.
  The process law, paid FOUR wrong resolutions across two auditors
  and this orchestrator before one command ended it: every exchanged
  probe result carries its boot sha, and any cross-time comparison
  RE-RUNS the git-extracted binary — never trusts mtimes or commit
  adjacency. CORRECTIVE TWO (the
  frontier's four red legs, traced through the pre-corrective boot to
  prove they predated corrective one): the warm persist's capacity
  guard reads the heap line SIGNED, so past 2GB it reads NEGATIVE and
  `negative < 960MB` waved exactly the loads it exists to refuse into
  alloc's 4GB wraparound trap (image_pack under driver_warm_persist —
  the banked signed-2GB class firing at its own guard). The
  non-negative conjunct restores the best-effort law: the cache never
  kills the compile; the four legs (interval, directional-edge,
  record-rest, repr-pin) healed. CLEAN m2 == m3 at 349,471 lines;
  census 0; frontier 332/0; micros 121/0; proof-exactness 9/9; crown
  5/5. Counted kills en route: the doubling-buffer theory (image_pack
  already pre-sizes exactly), the load-flake theory (deterministic
  reproduction), and my own first read that the reds were corrective
  one's regression (the committed boot trapped identically). The
  fleet's remaining findings are the synthesis's charge — the rolling
  bank is in the session scratchpad.
- 2026-07-31 · ▶▶▶▶ THE CHARGE LANDS ON THE LIVE CELL — schemes-are-edges
  rung two: recursion rows CLOSE, and a pure mutual pair answers Pure for
  the first time in the project's history (pin 56fa21b9). THE ROOT, fixed
  at its site (the movers' dig's kill #1): a co-member call's row charge
  landed on the instantiation's FRESHENED copy — severed forever from the
  callee's accumulator — so the row equation R_ping = N₁ ∪ R_pong never
  closed (re-measured RED through the prior boot the hour before:
  `with r41564@e11` on the pair, Pure on solo). THE FORM, three moves,
  each convicted into shape by the board: (1) callee_own_row re-aims an
  unresolved instance row at the callee's OWN row read live from the
  env's scheme body — and THE CHARGE IS A BARE EDGE
  (EfRow([],[],EtVar(root)), unrooted so the chain stays intact): the
  first form charged the resolve's folded content, and its live
  parameterized fragments reached the install-frame join, unifying
  different callers' payloads onto one decl cell — 52 Int-vs-List(Float)
  across the dsp chain, the 286 class resurrected and killed by the bare
  edge (content rides the chain and arrives at READ time, where reads
  are pure). (2) The re-aim is GROUP-GATED (group_member — scc_groups'
  parse truth carried on the per-pass infer_ctx to the one consumer):
  ungated, every free-rowed FnScheme re-aimed, and genuinely
  effect-polymorphic HOFs (show_list) chained every caller onto ONE
  shared quantified var — the whole diagnostics-voice SCC entangled, 81
  mismatches; a co-member's free row is the severed-recursion channel,
  any other is the polymorphism channel where freshening IS the
  semantics. (3) row_without_self compares CHASED ROOTS
  (find-before-compare — the union-find law at the row sort: the frame's
  fresh cell aliases its prereg root through the entry unify, so the raw
  compare missed the self-loop arriving through the alias). WITH IT THE
  GATE LEARNS TIMING: a declared-row gate whose body tail is still an
  open chain at decl exit (a cycle's non-last member — its charged roots
  resolve only when the last member cuts) PARKS (defer_row_gate) and
  drains at the pass tail where every chain has closed; enforce_row_gate
  is the one home both firing sites share, re-reading the row LIVE at
  fire time. One honest widen (eff_args_all_literal `with Pure` →
  Memory + Alloc — its body rides `all`, which allocates). MEASURED:
  ping/pong/solo all Pure; a bare entry's user-path mismatches 14 → 0;
  mn-mutual-negation-gate's original disease (the never-closing widened
  tail) is DEAD — its one residual line is the OTHER named class
  (bare-Cast declared vs Cast(Int) proven at the EtAll–EtAll strict
  compare, Hβ.effects.parameterized-negation-instance's admission);
  census 82 → 1 → 0; TRANSITION m3 == m4 twice en route, then CLEAN
  m2 == m3 at 349,442 lines; micros 121/0; proof-exactness 9/9; crown
  5/5; frontier green. THE ARC'S READING: the edges representation
  arrived at the recursion channel — the row equation solved by the
  graph's own least-fixpoint reading instead of iteration. Named
  residuals, each measured: the movers narration persists (the trial's
  prereg-vs-final divergence for the solo/self class — the next rung);
  the MULTI-TAIL WALL stands (tail_join keeps the first var, so a
  second co-member tail in one body still drops — the pending-tails
  frame fold or the SCC-condensed row cell is the design fork); and the
  solo-DAG address renders still show vacuous open tails on some
  mixed-declared fns (the weave-dependent openness class, gates
  passing).
- 2026-07-31 · ▶ THE DOOR LEADS WITH THE DEVELOPER — Morgan's standing
  correction executed at the description surfaces (no pin move —
  README / POSITIONING / PLAN prose only; the wheel untouched). The
  README's lead had latched onto the machine-code-age category
  ("verification substrate") as the IDENTITY — the exact inflation §0's
  own guardrail forbids ("keep the machine-age framing tethered to the
  actual developer at the keyboard") — while the identity is the telos
  §0 already resolved: the medium as the best teacher and pair of hands
  a developer gets, learnable from the compiler's own answers, with
  LLM-obsolescence its consequence (§1's closed loop). README re-led
  (the bet; the LLM paragraph — nobody uses a model for the idea, and
  behind this gate one is not worth invoking; "Why not point an LLM at
  it?" after the school; "Where this sits" carrying the civilizational
  argument as consequence-not-point, the four properties intact);
  POSITIONING gains the category-is-the-wedge-not-the-point paragraph
  under its category claim; §11's terminus gains leg 3's TEACHABILITY
  face (SYNTAX evolved until picking up Mentl teaches programming
  itself). The ruling, so it never regresses: every reader-facing page
  leads with the person at the keyboard; proof is the mechanism and
  the receipts, never the pitch.
- 2026-07-30 · ▶▶▶▶ THE ROUNDS ARE DELETED — the convergence tower's
  first big rung comes down by deletion, and the judgment becomes
  trial → final-as-verification (pin 574bc20d; Morgan's cut: "big
  rungs first"). THE FORM: the trial's callee-first layer walk over
  parse-truth groups + the cycle discipline make its finals the
  fixpoint ON ARRIVAL (the trial's own header had said so for a day);
  the final already re-judges everything against those finals —
  planned, bracketed, reporting — so the final IS the verification:
  round_prints renders after the trial and after the final, and a
  disagreement is a LOUD named divergence (movers_line + movers_diff,
  the graduated instruments) for the trial to be fixed at, never an
  iteration to hide in. (The framing is SUPERSEDED IN PLACE 2026-07-31,
  Morgan's cut: a final that proceeds with its own answer on divergence
  OVERRIDES — it does not verify; the second pass is the tower at
  cadence two, and rung 3's acceptance now carries its DELETION. The
  entry stands as the era's record.) DELETED WHOLE: converge_rounds, the 12-round
  bound, infer_program_round, pre_register_masked, the masked layer
  sweep (three fns), round_prints_masked, mask_all, and the cone
  family (cone_mask / moved_names / cone_mask_walk / frees_hit) — the
  rounds' own per-round re-parse was the substrate of the one
  oscillator they existed to settle (the bound-hit mover was
  rounds-resident, measured; no trial-side fix could clear a
  rounds-side artifact, so the cure was always the machinery's
  deletion, exactly as the schemes-are-edges peer sentenced). THE
  PAYOFF, measured: the daily field read (`mentl src/main.mn:0`)
  fell 59s → 22.5s — two passes where up to thirteen ran, every
  daily verb inheriting it. THE VERIFICATION'S FIRST FIRING did its
  job on arrival: 16 movers named on the wheel (the dsp float chain,
  hann → dft → mvl → comodulogram — the same family the rounds-era
  front climbed), emission SELF-STABLE across them (TRANSITION
  m3 == m4 at 360,735 lines, the 113,320-line m2/m3 diff the
  representation crossing one generation), census 0, frontier 332/0
  through the new judge, micros green. The movers are the next dig's
  exact worklist, printed on every compile's stderr — the trial's one
  under-resolution, now impossible to forget. RODE ALONG: the
  perimeter hook's wrapper-tolerant leads gain `time` (the novelty
  audit's side-finding, closed at its own measurement's doorstep).
  Attractor honesty: the trial-fed wheel is 4,286 lines larger than
  the rounds-fed one — the resolution attractor moved, arbitrated by
  the fixpoint, the census, and the whole board, and the field's
  tightening count rose 2 → 12 (the sharper/different rows are
  T_OverDeclared invitations, `mentl tighten`'s queue).
- 2026-07-30 · ▶▶ THE VOICE CANNOT MISORDER — the comment-voice audit
  opens by convicting the voice's own truth, and the comment law gains
  its destiny statement (pin 61f8150f). Morgan's charge: comments
  should be designed into the voice so completely that `//` becomes the
  developer's scratchpad — the fun-place — with everything load-bearing
  spoken by the medium. THE OPENING CONVICTION, forced by the prior
  landing's own cost: `type of pair` answered `(beta, alpha)` for a
  declared (alpha, beta) — query.mn's private deep-chase family
  (chase_params_deep / chase_list_deep / chase_fields_deep /
  find_unresolved) walked last/drop_last and PREPENDED, reversing every
  list it rebuilt; the show_list disease alive in a query-side copy,
  and it had already cost two swapped calls convicted by the census.
  The walks are the map / filter|>map vocabulary forms now
  (iteration-is-topology executing on the voice's own organs), the
  frontier pins declaration order, and both witnesses answer true
  (pair alpha-first; collect_free_vars node-first). THE AUDIT'S
  MEASUREMENT: the wheel is ~38% prose (17,762 comment-carrying lines
  of 47,101), nearly all MECHANISM the voice cannot yet speak — the ⟳
  confession at the prose layer, now law at all three docs: SYNTAX
  §«What a comment TRENDS TO» (the deletion test — delete the comment;
  lost unprojectable content names the missing verb; `//`'s endpoint is
  authored intent alone), CLAUDE.md ⟳ (a mechanism-comment is the hand
  tool's confession one layer up), and the absorption arc per family on
  the new peer (measured-whys → Reason edges; invariants → refinements
  and armed diagnostics; pointers → the residue index live;
  layout-rationale → deleted by fmt-canonical). The naming ruling
  sharpened in place: a name needing a decoder-ring comment violates
  vocabulary-as-intent at the source. CLEAN m2 == m3 at 356,449 lines;
  census 0; the query-order frontier leg green.
- 2026-07-30 · ▶▶▶ THE OWN CANNOT CROSS THE WIRE — the persist value
  barrier lands, and the relevant tier sweeps its own eight findings to
  zero (pin 16da60bd). THE VALUE HALF: consume_declared projects the
  frame's authored-own names whole, and the call-edge gate
  (replay_barrier_gate, riding infer_call_saturated's one param-product
  read) intersects them with a thunk argument's free names wherever the
  param's declared row severs the external triple under the !-stance —
  the row IS the replay contract (7c91063c's own barrier), so the same
  structural fact gates effects AND values, one edge. T_OwnAcrossReplay
  teaches at the capture site: finish the own before the persist, or
  move its whole lifetime inside the thunk. THE SEMANTIC CATCH, worth
  the entry alone: the first op was declared-minus-used, and the probe
  killed it before it shipped — CAPTURING the own IS its consume, so
  the subtraction blinds the gate to the exact target; the projection
  is DECLARED, freeness in the thunk discriminates, and a prior use
  plus the capture is the SPACE law's double, reported separately.
  Replay is BParallel on the TIME axis — the ledger that catches
  `take(x) + take(x)` across `><` arms catches
  `persist_branch(() => take(x))` across resumed runs, one algebra, two
  axes. THE SWEEP (8 → 0): push_tok / push_node / trail_append /
  apply_connective / trial_judge_group de-owned (pass-through and
  borrow-only params — the marker lied about finalization the bodies
  never owed), and the blanket condition-borrow REPLACED by the
  read-shape projection (is_read_shape / infer_borrowed_read — the one
  shape test all four borrow surfaces share): decision ARITHMETIC over
  a value borrows (`buf != 0`, literals, unary, binop-of-reads); a CALL
  follows its callee's product. The blanket was UNSOUND, not merely
  noisy — it silenced a genuine `if take(buf) { take(buf) }` double —
  and its narrowing is what let the splice-scanner's real consumes
  count (the two false owns healed). The four-face ownership fixture
  gains the honest forms (the guard helper declares the `ref` its body
  proves — the len precedent; the direct face exercises decision
  arithmetic; runs 42). THREE FINDS RODE: (1) THE QUERY RENDERS PARAMS
  REVERSED — `pair(alpha, beta)` answers `(beta, alpha)` through `type
  of` (minimal repro banked; show_list is first-first and unify aligns
  parse-order, so the lie is confined to the ask projection's own param
  walk) — measured at cost: TWO swapped calls in one hour from trusting
  the projection, each convicted by the census in one march
  (collect_free_vars, string_in_list); named
  Hβ.query.param-render-reversed, the comment-voice audit's opening
  conviction. (2) The frontier's brace-accretion face was a
  gate-that-cannot-fail since birth: `grep '\{ \{'` is an invalid BRE
  interval, exit 2, and the NEGATED check read the error as pass —
  fixed-string now. (3) The march's supersede-not-stack law carried
  three unnarrated repins through one landing correctly — the placeholder
  head never stacked. CLEAN m2 == m3 at 356,439 lines; census 0;
  T_OwnUnconsumed 0; frontier 331/0 (the persist value leg: the
  captured open own narrates, the self-contained thunk silent, the
  loop runs); micros green; proof-exactness 9/9; crown 5/5.
- 2026-07-30 · ▶▶ AFFINE GAINS EXACTLY-ONCE — the relevant tier lands,
  the novelty head-to-head's first build (pin b77f345b). The Fable
  audit's build-first pick, chosen for the reason it gave: the ledger
  already carries Diagnostic, so the exit-check is row-neutral to the
  judgment spine — the one class of engine work that does not gamble
  the oscillation attractor. THE GAP: the ownership ledger reported
  consumed-twice and said NOTHING about never-consumed, so an authored
  `own` a body drops — or only ever borrows — was silent, and a
  persisted continuation capturing such a value loses the close
  obligation entirely. THE LANDING: consume_declare (the Consume
  effect's seventh op) records each authored `own` param INSIDE the
  body's consume frame; consume_exit_fn narrates whichever were never
  consumed (T_OwnUnconsumed, narration tier per the census arming law;
  Unspecified applicability — the fix is a consume the developer must
  place, or an honest widening to `ref`, never a patch). THE SEMANTICS
  the probes settled: a transfer-out IS the consume (the
  return-transfer law's own reading — hands_back stays silent), and an
  own that is only BORROWED fires, because at-most-once-and-only-read
  is `ref`'s claim, not `own`'s — the diagnostic teaches the honest
  marker. THREE CATCHES en route, each counted: the first form
  declared at mint_params and was WIPED by consume_enter_fn's fresh
  frame before the walk (a report that never fired — measured, moved
  inside the bracket); the armed E_DuplicateFnName class caught this
  landing's own interrupted double-edit before any probe ran; and the
  leg's first span assertion assumed line 1 while the fixture's own
  comment block puts drops at 10:4 (file-local render confirmed
  correct). THE WHEEL'S FIRST CENSUS: 8 findings, all real (trail,
  buf ×7 — owns only ever borrowed or dropped); they are the sweep
  queue, and the class arms when they reach 0. The persist half —
  image_pack scanning captured frames for undischarged owns — stays on
  the peer. CLEAN m2 == m3 at 355,257 lines; census 0; frontier 330/0;
  micros 121/0; proof-exactness 9/9; crown 5/5.
- 2026-07-30 · ▶ NINE DESIGNS FROM TWO INDEPENDENT AUDITS — the
  novelty head-to-head, banked whole (no pin move — PLAN only; boot
  stands at 2132e1ce). Morgan dispatched Fable 5 and Opus 5 against an
  IDENTICAL brief — find what nobody has named, expressible in Mentl's
  own primitives, artifact-grounded as absent, with a mandatory
  calibration section — explicitly to learn which model serves THIS
  project better. Both delivered; every proposal is now a named peer in
  the residue index above, attributed. THE ARCHITECTURAL LEAP came from
  Fable: LowIR is the SECOND GRAPH (39 handle-first constructors
  re-materializing what the handle already addresses) while the graph
  already carries a lowering fact as a spine column — and the
  lower-time-bake class regenerating three times is the cost of the tree
  existing. THE MOST ELEGANT OBSERVATION came from Opus: the four Ty
  walk SHAPES are exactly the four RESUME CARDINALITIES, so the
  discipline the medium already infers from arm bodies classifies the
  traversal it is used in — the kernel explaining a compiler-internal
  pattern rather than a pattern imported to explain the kernel. THE
  SHARPEST THESIS FINDING was Fable's: no verb can project a past
  generation, so GIT IS STILL THE OUTSIDE TIME ORACLE for the medium's
  own history — an !Outside the docs never named, found by the auditor
  hitting it while trying to ground on a commit. THE ONLY LIVE-DEFECT
  CATCH was Opus's: extract_optimal, written an hour earlier, took the
  span of the node a rewrite moved TO (fixed at the pin above). Both
  calibrated honestly — Fable dropped a candidate for colliding with
  hours-old work and reproduced this session's own row_without_self dig
  without claiming it; Opus dropped three as overlapping and counted a
  killed hypothesis. Side findings from their paths, real: the refs
  facet is DAG-scoped and pattern-blind
  (Hβ.query.refs-reads-edges-not-occurrences), the perimeter hook
  refuses a pinned-commit read with no verb to offer, and `time` is
  missing from its wrapper-tolerant lead list.
- 2026-07-30 · ▶ THE PROPOSAL KEEPS THE DEVELOPER'S COORDINATES — the
  fork/merge landing's own review defect, caught by an independent
  auditor within the hour (pin 2132e1ce). extract_optimal's first form
  rebuilt a swapped candidate with `parse_span_of(cheapest)` — the span
  of the node the rewrite moved TO — so a `why` at an
  extraction-optimized proposal would have answered with the
  coordinates of a node the developer never wrote. A proposal is about
  the position they are FILLING; the cheaper body now lands at the
  candidate's own span. BANKED WITH IT, from the same audit (the report
  is .build/research/novelty-opus-2026-07-30.md; three designs, each
  artifact-grounded, each with an honest calibration of its own
  novelty): Hβ.egraph.canon-edge-carries-reason (the ONE kernel write
  with no Reason — and the belt that turns "an assumed edge must not
  escape its scope" from a rule someone remembers into a refusal the
  gate can make), Hβ.verify.congruence-is-the-egraph (Verify keeps a
  PRIVATE constant folder and a hand-written interval interpreter and
  decides before the first canon edge exists — the proposal points the
  fan's own fork-and-scoped-saturate machinery at the equality relation,
  deletes the second folder, and moves the EUF core of the SMT residual
  from Outside to inside), and Hβ.types.traversal-is-a-handler
  (nineteen Ty descents, and the Mentl-native twist: the four walk
  shapes ARE the four resume cardinalities, so the discipline the medium
  already infers from arm bodies classifies the traversal it is used
  in). Plus Hβ.query.refs-reads-edges-not-occurrences — the refs facet
  is DAG-scoped (answering 0 confidently for a foundational name) and
  pattern-blind (an ADT's match arms, the exhaustiveness surface, are
  invisible because a pattern binds through PCon, not VarRef).
- 2026-07-30 · ▶▶▶ THE FORK AND THE MERGE COMPOSE — §5's optimality
  half stops being a design and becomes the fan's own path
  (pin 296d7f99). Morgan's charge, exactly: don't describe the
  composition, build it. THE SEAM is verify_each_enriched — where the fork side
  finishes: fan_verify explores MEANING-space by FORKING (candidates
  conflict, each proves in its own rolled-back branch cursor, proof is
  a FILTER), and every survivor is then an equality CLASS rather than
  one program, so saturate_range draws the equivalence edges over the
  candidates' OWN handle range and egraph_extract picks the
  cost-minimal member (FORM-space by MERGING — equals compose, nothing
  is ever undone). THE ORDER IS NOW ENFORCED IN CODE: extract-then-
  prove would optimize a program that may be inadmissible, so
  prove-then-extract is the only composition and it is the one the
  artifact runs. The RANGE is what keeps the merge half cheap — a fan
  at one cursor position saturates what it minted, never a session's
  whole graph (apply_rules_from already carried its start, so the range
  cost one parameter and no new machinery). THE DUALITY'S SHARPEST
  CONSEQUENCE lands with it: survivors extracting to the SAME e-class
  are ONE MEANING IN TWO FORMS, so they collapse to a single proposal
  and §1's teaching tie-break fires only on a real disagreement of
  meaning — the medium stops being able to ask a question with no
  content. PROVEN NON-DESTRUCTIVE at the case that matters: the Bit
  hole's 0 and 1 are different e-classes, survive as two, and still
  teach. HONEST STATE, stated rather than implied: on today's candidate
  space (literals, vocabulary calls) and today's rule set (const-fold +
  the arithmetic identities) the extraction rarely has a cheaper member
  to find — the composition is correct, ordered, and inert-until-fed,
  and what feeds it is a richer candidate space or a richer rule set
  (band G's saturation-deepen), not more plumbing. The medium's own
  judge convicted two first drafts en route: a Stage-Law arg order that
  let the pipe fill the wrong hole (Int vs List(EnrichedCandidate)),
  and an accumulator read twice (E_OwnershipViolation) — both rewritten
  in the fold vocabulary iteration-is-topology prescribes. CLEAN
  m2 == m3 at 355,179 lines; census 0; frontier 329/0; micros 121/0;
  proof-exactness 9/9; crown 5/5.
  THE COMPLETENESS PASS, run immediately after (Morgan: "how do we
  ensure clean and complete foundations and bank every possible win") —
  three findings, each named rather than implied, so nothing here rests
  on a claim the artifact does not carry. (1) THE DORMANCY IS
  STRUCTURAL AND NOW HAS ITS ARTIFACT: every e-graph rule matches a
  BinOpExpr while every fan enumerator mints an atom, so the sets do
  not intersect and extraction always chases a handle to itself —
  `Hβ.synth.fan-extraction-needs-a-feeder`, with the RED fixture
  (mn-fan-extraction-fires) that says what "fed" means and runs green
  the day a feeder lands. Stated so no reader mistakes today's green
  board for a proven mechanism — the exact gate-that-cannot-fail class
  caught twice already today. (2) THE RANKER SPEAKS TWO VOCABULARIES:
  `cost` is read by rank_insert but written as a LIVE gradient read for
  vocabulary calls and as HARDCODED literals for every shape
  enumerator, so the sort compares a measurement against invented
  constants — and extraction made it worse by carrying a stale number
  onto a swapped node. Both faces dissolve in one DELETION
  (`Hβ.synth.rank-is-a-projection-not-a-field`): rank computed at sort
  time from the candidate, the field gone, nothing stale left to carry.
  (3) WHAT IS ACTUALLY PROVEN, precisely: the order is enforced in
  code; the path compiles to the byte-identical fixpoint; the fan's own
  legs stay green with the composition inserted (non-destruction on the
  real-tie case, 0 and 1 for a Bit hole). What is NOT proven is any
  firing — and that is finding (1), not an omission.
- 2026-07-30 · ▶ THE MUTUAL CYCLE'S ROW NEVER CLOSES — four probes,
  eight lines, one named root (no pin move — the measurement and its
  banked RED; boot stands at ec04f745). The prior landing named
  Hβ.effects.negative-stance-under-mixed-gate from the wheel's own
  check verdicts; this iteration DUG it to the root instead of
  guessing at the crown's algebra. THE MINIMAL REPRO
  (tests/frontier/mn-mutual-negation-gate.mn, unregistered — it fails
  today by construction): a fn declaring `Cast + !Mutate` over a
  MUTUALLY-RECURSIVE `!Mutate` callee is refused by its own
  declaration, E_EffectMismatch at its decl span, on check AND compile
  AND the concatenated blob alike (so it was never a check-path
  artifact). FOUR THEORIES KILLED IN ORDER, each banked so none is
  re-chased: bare-declared-vs-instance-proven passes alone
  (eff_name_handle shares the handle between ENamed and
  EParameterized, so by-name membership already admits an instance
  under a bare declaration); negation-beside-positives passes; a
  NON-recursive `!E` callee passes; mutual recursion is the
  discriminator. THE ROOT, named at a specific fn: `row_without_self`
  (effects.mn) takes the least solution of a recursive row equation —
  its own comment says "a tail landing on the fn's OWN row handle cuts
  to the closed head" — and that cut is SELF-only, so under mutual
  recursion the tail lands on a CO-MEMBER's handle, `R_ping = names ∪
  R_pong` and `R_pong = names ∪ R_ping` never cut, the row never
  closes, and the widened tail flows into every caller until a closed
  gate refuses it. THE FIX IS THE SAME ARGUMENT ONE SCOPE UP — the cut
  belongs to the whole BINDING GROUP — and its scope is measured, not
  assumed: the cut fires at inf_exit_fn, where infer_ctx's stack holds
  only the NESTING frames (a co-member is a sibling top-level fn, never
  on it), so the group's row handles must reach that handler, AND the
  rounds re-judge in LAYER order without group context, so a
  trial-only fix would be undone next round. That is a focused landing
  across the cycle discipline and the convergence walk — banked whole
  rather than ridden, with the artifact that starts it.
- 2026-07-30 · ▶▶ THE CHECK VERB WAS TELLING THE TRUTH — the audit's F6
  probed instead of believed, and its "false diagnostics" were real
  (pin ec04f745). Morgan's cut ("make the engine meet the surface")
  aimed at F6: `mentl check <file>` reportedly emits false diagnostics
  on a weave-clean file, which is why a 103-row regex catalog stands in
  as the write-time discipline and 136 ignore-markers live in the
  source. FIRST FINDING, and it inverts the premise: the diagnostics
  are NOT false. graph.mn and egraph.mn both call eprint_string and
  neither imports runtime/io — genuine manifest violations ("the
  imports ARE the manifest", §11 col 2) that ONLY the concatenated
  wheel blob masks, because concatenation resolves every name whether
  the module declared its dep or not. The verb named them precisely;
  the source was wrong. Both imports land, the per-file verdict on
  those files falls 2 → 1, and the medium's per-module honesty becomes
  measurable: graph 1 · egraph 1 · types 0 · effects 0 · lower 4 ·
  parser 1 — a ratchet the check verb can drive to zero, which is
  exactly what F6's whole chain (drift-modes-read-the-row → the 136
  markers delete → the hook becomes one verb) is gated behind. SECOND
  FINDING, measured not assumed: the shared residue is ONE row gap —
  occurs_in_live declares `Cast + !Mutate` and proves `Cast(GNode) +
  !Mutate`, which by-name membership should admit (eff_name_handle
  shares the handle between ENamed and EParameterized). Two theories
  died to probes: bare-vs-instance alone passes (a minimal `with Cast`
  over `addr` checks clean), and so does bare-with-negation (`with
  Cast + !Mutate`). The surviving reading is row_subsumes' own written
  law — a body whose tail went EtAll (the negative stance) is never
  subsumed by a gate that resolved EtClosed — so a MIXED declaration
  (positives + `!E`) that closes meets a body row that widened, and
  the asymmetry refuses a fn that satisfies its own declaration. Named
  Hβ.effects.negative-stance-under-mixed-gate with the repro recipe
  and both dead theories, because the fix is in the gate's tail
  algebra and deserves its own landing rather than a rider.
- 2026-07-30 · ▶ THE TIER'S OWN NEIGHBOURS — iteration-is-topology's
  second family, at the audit's sharpest instance (pin b1b53025). The
  selfhood audit found the file that HOSTS the verb-shape and
  iteration-shape tiers carrying four convictions of its own, two of
  them the tiers' own machinery — chain_scan (the scanner
  pipe_shape_of calls) and rest_uses, four lines above pipe_shape_of
  itself: the census landing had rewritten the tier's own body and left
  its neighbours. Both migrate: the suffix use-count is a
  `|> drop |> map |> sum` chain; the run-length scan splits into the
  two stages it always was — per-position LINKS (does stmt i feed
  stmt i+1 exactly once?) then a fold carrying the run, flushing at
  >= 2 — with the one-step exception and the twice-used silence
  preserved by construction. The tier's own gate fixtures answer
  byte-identically (the migration cannot change what the tier says).
  oracle.mn 4 → 2 convictions. THE SURVIVORS ARE NOT AN IDIOM
  PROBLEM and are named as such: count_dependents and
  collect_bound_positions walk HANDLE SPACE, and materializing a range
  at graph scale is worse than the loop — their self-form is the graph
  answering directly (a reverse-edge read, a bound-cell projection),
  banked as Hβ.graph.reverse-edge-and-bound-projection, where the
  payoff is complexity (count_dependents is O(graph) per position,
  quadratic across the candidate set) rather than vocabulary.
- 2026-07-30 · ▶▶ THE SEVERANCE VOCABULARY IS A GRAPH READ — the
  selfhood audit's F12, and the audit report's own headline executed
  (pin 1cb58126). Morgan's second dispatch ("audit all the ways Mentl
  can be more ITSELF") returned fifteen findings ranked by
  identity-leverage (.build/research/selfhood-audit-2026-07-30.md);
  its closing paragraph is the sharpest statement of the project's
  state yet written: THE MEDIUM STILL KEEPS A COPY OF WHAT IT KNOWS,
  AND THEN READS THE COPY — a scheme published as a snapshot and
  re-read by name (F4, the tower), a binding stored in a buffer with a
  string-keyed index beside it instead of drawn as an edge (F5), 390
  index-threaded loops each a copy of the position the structure
  already holds (F1), the roadmap a copy of the absences the comment
  weave carries and the frontier ranks (F7), 11,239 lines of prose a
  copy of measurements the artifact holds (F8), the drift catalog a
  regex copy of what a row states (F6) — and the five verbs' near-
  absence is the SURFACE SYMPTOM of that, not a separate problem
  ("a medium that reads copies has nothing to fan out over and no
  cycle to close — the topology is only visible once the truth is
  live"). Its cheapest item lands now: three interned literals named
  the audit's severance vocabulary while the env held every effect
  declaration in scope, so the audit could never tell a fn it could
  prove !Mutate / !WASI / !Thread, and every fn got the identical
  three-name constant where §5's felt endpoint asks for a gradient.
  severance_vocabulary FOLDS EffectDeclKind out of env_snapshot — the
  env's own "this name is an effect" edge — so a newly-declared
  effect enters the audit by construction; the literal list and its
  drift marker delete. The teaching tier leads with severances whose
  absence unlocks a NAMED capability and counts the rest (28 in the
  wheel's DAG scope), and a body with provable severances but no
  capability named still speaks rather than going silent. THE
  CORRECTNESS GAIN, measured: in a scope where IO and Network are not
  declared at all, the old line still offered "Sandbox (proven no
  network access)" — a proof claimed about an effect that does not
  exist there. RETRACTED SAME DAY, and the retraction is the more
  useful finding (Morgan's cut: "don't regress that — make the engine
  meet the surface"): the resident-session leg's red was first read as
  "a bare module has nothing severable, by construction," and THE
  FIXTURE WAS EDITED to suit that reading — the regression, the
  fixture bent to a weaker world instead of the world fixed. In the
  SHIPPED world a bare module carries the substrate vocabulary (the
  shim mounts MENTL_HOME, the prelude seeds the DAG): `with !Alloc` is
  sayable and provable in any file with no imports, verified through
  the installed verb. What the red actually reported: THE GATE'S OWN
  mcp INVOCATION mounted only the project dir, so the agent-facing
  session — the surface §0 says makes any proposer trustworthy —
  derived with NO substrate vocabulary at all, and every propose
  through it compiled against an empty world. The hardcoded three
  literals had masked that for the leg's whole life (a literal needs
  no env). Fixture bare again; the invocation gains the mount every
  other leg and the shim itself carry. THE LAW, at the gate layer: a
  gate must exercise the SHIPPED configuration — one that tests a
  world no user inhabits cannot fail for the right reason, and it
  taught a false lesson the moment it finally failed. THE PIN MACHINERY'S OWN FIRST LESSON rode along:
  this landing marched twice, and the march stacked a second
  placeholder block on the unnarrated first — an UNNARRATED head is a
  working step, not history, so emit_provenance now SUPERSEDES a
  placeholder head instead of stacking (the chain records blessed
  pins, and blessing is exactly what the narrative is). NAMED
  REMAINDER: the capability map still knows three effects — extending
  it needs each capability's render to name WHICH severance proved it
  (CSandbox renders "proven no network access", so mapping WASI to it
  would misspeak), which is Hβ.audit.capability-carries-its-evidence.
- 2026-07-30 · ▶ THE MARCH WRITES ITS OWN PIN — the scout's move 2, the
  fabrication class deleted at its source (no pin move — tools only;
  boot stands at feccc8a9). The march HOLDS the sha, the verdict, the
  generation, the line count and the census at the moment it repins,
  and a human retyping any of them later is the class caught live TWICE
  (a sha tail completed from memory — CLAUDE.md ⊕). So emit_provenance
  writes the mechanical block itself, sha256 read from the artifact it
  just copied, and the author writes exactly ONE line: the narrative,
  replacing the march's `‹NARRATIVE UNWRITTEN›` placeholder. THE
  REMINDER BECOMES A REFUSAL: doc-truth fails while a placeholder entry
  stands, so "the pin is not blessed until the entry is written" — a
  printed sentence since the boot era — is now mechanical, and an
  unblessed pin cannot pass verify. Both legs instrument-checked (the
  insertion on a scratch copy: chain 191 → 192 entries, exact position;
  the refusal RED with a planted placeholder, GREEN restored), and the
  check's OWN first run convicted itself — an unanchored grep fired on
  the recipe prose that names the placeholder (the string-literal
  blindness class, one layer up), anchored to the entry form. The
  PROVENANCE recipe rewritten to the new ritual. Ledger-as-projection's
  first executed rung (PLAN §7's own destiny: state as projection,
  never a hand-kept prose ledger) — the remaining hand-written half is
  the narrative, which is the human judgment the projection can never
  hold.
- 2026-07-30 · ▶ THE HARNESS SPEAKS ONLY MECHANICS — the practice
  scout's first move executed (no pin move — hooks/tools only; boot
  stands at feccc8a9). Morgan's dispatch ("research improving dev
  best practices, tailored to the Claude Code workflow, until Mentl
  cuts everything that isn't Human or Mentl out of the loop") came
  back with the framing fact: THE GATE IS ALREADY ON CLAUDE'S WIRE
  (.mcp.json serves mentl-gate) AND CLAUDE'S OWN WRITE CHANNEL
  BYPASSES IT — most of the ranked moves close that gap (the full
  memo: .build/research/practice-scout-2026-07-30.md). Executed now,
  move 1 — the harness truth sweep: session-start.sh had been a
  drifted SECOND HOME for law, grounding every session on "INLINE
  ONLY" (superseded 2026-06-21) and "census is a SHADOW, enforces
  nothing" (a zero-tolerance ratchet since 2026-07-22) — stripped to
  mechanics + pointers (law lives in CLAUDE.md alone; nothing dated
  remains in the hook, so it can no longer drift); the pre-commit's
  Gate 2 silently no-opped for a week against comment-ratchet.sh
  (deleted 2026-07-22) behind its -x check — the gate-that-cannot-
  fail vacuity, deleted with its absorption recorded in place, and
  the phantom determinism-gate.sh cite trued to the march;
  doc-truth's named-command sweep now covers .claude/hooks/*.sh +
  .githooks/pre-commit (the third party's instruction surfaces are
  reader-facing docs). BANKED from the scout's ranking: move 2 — the
  march writes its own PROVENANCE block at repin (sha/verdict/lines/
  census machine-emitted, the narrative human; deletes the
  twice-caught sha-fabrication class — ledger-as-projection's first
  executed rung); move 3 — widen the MCP/session verb surface
  (check/test/fmt/march/frontier) and rewire post-edit-mn.sh to
  session-backed whole-weave judgment (the every-proposer-through-
  the-gate channel; rides the convergence tax until
  schemes-are-edges). Outward finds banked: vericoding benchmarks
  arriving (VeriBench, Dafny-2026) — the absence benchmark's
  empty-podium claim re-verifies before the next positioning pass;
  none measures proving the NEGATIVE. The Opus selfhood audit
  ("all the ways Mentl can be more ITSELF") is still running.
- 2026-07-30 · ▶▶ THE FIRST FAMILY MIGRATES — iteration-is-topology
  executes its first family, and the migration's own red teaches the
  recipe's pin (pin feccc8a9). The law now lives in all three docs
  (CLAUDE Anchor 6's method statement, SYNTAX's token-note surface
  clause, PLAN's ledger + peer — one home per projection). THE FAMILY:
  pipeline's cold render/set walks — six index-threaded loop fns
  (owner_names_of · absent_from_loop · name_in_list_loop ·
  severance_unlocks_loop · caps_not_in · cap_in · ref_span_lines)
  DELETED whole into map/filter/any/fold; the tier's file count
  18 → 11; the wheel 55 lines smaller (the law smiling). THE RECIPE'S
  LOAD-BEARING PIN, paid for in one measured red: under the Stage Law
  the datum infers LAST, so a datum-last lambda's bare `==` word-floors
  to pointer-eq while its element is still free — EffName membership
  went always-false, everything read "absent," and Alloc was offered
  severable on allocating rows; the severance-honest frontier leg
  (its own prior landing's gate) caught it in ONE run — the gate
  catching the migrator, the two-oracle law live. One typed operand
  (`target: EffName`) restores the structural dispatch (the
  either-operand law); the recipe states it permanently: a datum-last
  lambda doing ==/arith on the element states the element's type
  (the annotated-helper discipline, until monomorphization covers
  datum-last free lambdas). Hot-path convicts (env_bucket_pos, the
  gate scans) stay deliberately unmigrated — their families move
  only under their own perf measurement. Morgan's two dispatches ride
  this arc: the Fable practice scout (dev-practice research toward
  the closed-loop terminus) and the Opus selfhood auditor ("all the
  ways Mentl can be more ITSELF") run in the background, reports to
  .build/research/. Board whole: frontier 329/0; micros 121/0;
  proof-exactness 9/9; crown 5/5; census 0; CLEAN m2 == m3 at
  354,506 lines.
- 2026-07-30 · ▶▶ ITERATION IS TOPOLOGY — Morgan's interrogation of
  recursion itself becomes a law, a measurement, and the audit's next
  tier (pin d949fa7a). THE QUESTION ("was recursion even the correct
  thing for Mentl? has it tainted us?") and THE HONEST ANSWER: the
  recursion idiom was Claude's ML/Scheme import, never a decision the
  medium made — SYNTAX declared the true model at birth (no loop
  keywords; iteration is |> stages, <~ cycles, Iterate handlers) and
  the wheel's body speaks Scheme with a Mentl accent (census: 373
  vocabulary call sites against hundreds of hand-rolled index loops;
  28 <~ uses, almost all in the DSP lib). THE DEEP BILL: the entire
  convergence tower is recursion's invoice — name-keyed mutual
  recursion is what makes the judgment cyclic and schemes into
  snapshots needing iteration; Faust (the verbs' own validator) has no
  recursion, one <~-typed-locally cycle form, and single-pass
  compilation. THE ULTIMATE MEDIUM'S ITERATION STACK, read off the
  kernel: (1) structural iteration = DERIVED folds over the five
  node-kinds — total, terminating, generated never authored; (2)
  cyclic dataflow = <~, the cycle drawn once as an edge, typed by the
  local recurrence rule; (3) unbounded search = handlers + multi-shot
  (iteration as resumption — the oracle's own form); (4) named general
  recursion = the priced residual (the signature-price law
  generalizes: it is the price of name-keyed recursion, period). THE
  TIER: recursion_shape_of (oracle.mn, beside pipe_shape_of) convicts
  a self-call threading an incremented index over the fn's own param —
  structural over the one total child projection; derived-fold-shaped
  recursion (recursing on children, never counters) stays silent. Its
  first wheel census: 390 convictions — the migration queue, measured
  by the medium itself (the name grep guessed 78). Two live catches
  during the build: the tier's own first form convicted itself
  (args_thread_index was index-threaded — rewritten in the vocabulary
  it preaches), and the first probe's verdict was the PROBER's error
  (a grep window too narrow to reach the tier's line — forensic law 2,
  counted; the tier was correct from its first march). THE ARC
  REFRAMED: schemes-are-edges lands into a wheel being drained of
  name-cycles — "shrink recursion until the judgment has nothing
  cyclic left to iterate"; the migration (costume families → folds /
  each / iterate / <~ / drivers, march-arbitrated per family) is the
  named peer Hβ.wheel.iteration-is-topology. Two-face frontier leg
  registered; frontier 329/0; micros 121/0; proof-exactness 9/9;
  crown 5/5; census 0; CLEAN m2 == m3 at 354,538 lines.
- 2026-07-30 · ▶▶▶ THE CYCLE DISCIPLINE — the schemes-are-edges arc
  opens at its foundation: monomorphic recursion by default, the
  signature price for polymorphic recursion (pin 4e8eb504). At group
  entry an unsig'd Tarjan-cycle member's env view re-registers with
  its TYPE cells SHARED — Forall over only the row-sort quantifiers of
  the same pre-registered skeleton — so an intra-cycle forward use
  TEACHES the callee's actual param/ret cells instead of discarding
  its demand into a fresh copy (the disconnected-vars class): this is
  NOT tower machinery — no probes, no freezes, no joins — it is
  union-find propagation as the cycle's constraint channel, the edges
  model's own form for cycles, and it SURVIVES the tower's deletion
  as the cycle judgment. The full-mono first form was convicted by
  the wheel in one march (five E_EffectMismatch — application-site
  row unifies contaminating callee rows through the shared row cell;
  the directional-edge law's class), so ROW handles stay quantified,
  freshening per use. A fully-annotated member (every param + return
  authored — lowercase params being the DECLARED polymorphism) keeps
  its quantified pre-registration: polymorphic recursion by intent.
  The group-exit sweep re-generalizes every member over the group's
  resolved cells (an early member's final carries a late member's
  resolution instead of quantifying a then-free var the frozen-read
  law would forever freshen). MEASURED HONESTLY: census 0 at every
  generation (zero wheel cycles pay a type-side mono price);
  TRANSITION m3 == m4 at 353,904 lines; the board whole (micros
  121/0, frontier 328/0, proof-exactness 9/9, crown 5/5) — and the
  bound-hit mover (parse_effect_list_from) is UNMOVED: its flip is
  ROUNDS-resident (each round's re-parse + re-judgment regenerates
  it; no trial-side seed can clear a rounds-side oscillator). The
  measurement sharpens the arc: the rounds' DELETION is the cure —
  trial-as-the-judgment + one verification pass + the reporting
  final — and this discipline is its prerequisite (the rounds can
  only delete when the trial's cycle finals are trustworthy, which
  is exactly what landed here).
- 2026-07-30 · ▶▶ THE VET — Morgan's charge ("re-judge? re-infer?
  re-derive?") audits the 24-hour window against Carried-Truth + the
  eight interrogations; the tower brick reverts and the gate learns
  the whole grammar (no pin move — boot stands at f09e54a3). THE HEAD
  CONVICTION: the SCC generality-join iteration — built whole this
  session, marched to a self-stable TRANSITION (355,307 lines, census
  0) — REVERTED uncommitted: the one bound-hit mover survived it and
  the attractor moved 107k lines unarbitrated, and the deeper verdict
  is the direction itself (probes that re-judge, freezes that
  snapshot, joins over re-derivations are the tower the residue index
  already sentences to deletion; the third counted kill is banked in
  the movers entry, and the arc redirects terminally to
  Hβ.infer.schemes-are-edges). THE SECOND CONVICTION, named with its
  fix: scope_localize (the diagnostic-localization landing) reads the
  structural span honestly but then performs STRING SURGERY on the
  rendered line — re-rendering show_span to measure the tail it
  slices, an accident-invariant (every line must end with exactly
  that tail) and two renders of one fact; the fix is structural and
  small: diag_report already carries the DIAG to the terminal arms,
  so the span tail renders AT the terminal arm from the structure in
  hand (diag_line drops its tail; root + mcp collectors append
  through one shared projection) — named
  Hβ.diag.span-tail-at-terminal-arm. Counted as tower compensation
  (dissolves with schemes-are-edges): the refs facet's span dedup and
  the enumerators' latest-mint-wins dedup both exist because rounds
  re-mint generations. THE CLEAN SLATE, verified commit by commit:
  repr-pin (width stated once, read live via repr_of's one arm),
  as-pattern (the binder's cell IS the scrutinee's — one unify edge),
  record-rest (DELETED the pattern-subset index bake), the interval
  legs (authored constraints stored as values are source truth, not
  cached derivations), the authored rows at the parser SCC (signature
  prices, true on their own merits). THE GATE FIX riding the vet:
  march-gate's micro reader knew half the fixture-contract grammar
  and failed four refuse fixtures as headerless — it reads
  `// expect: refuse E_Class` now (pass iff the class reports), and
  the tier runs 121/0. The law's own demonstration: the census caught
  the fabricated Fresh(0) reason in the reverted build's freeze skip
  before any commit; Morgan caught the architecture.
- 2026-07-30 · ▶▶ THE WIDTH IS AN INPUT — SYNTAX's representation pin
  is real, and the census named every walk in one march
  (pin f09e54a3). `type Coeff = Float repr f64` parses
  (parse_repr_pin probes the `repr` ident after ANY type-decl base —
  the medium's noun stays a word, the handle/turbofish precedent) and
  the bare-width atom (`k: f64` / `f32` / `i64` / `v128`) mints the
  SAME TReprPin(Repr, Ty) — the fifteenth Ty constructor, arm 7's
  authored INPUT as a graph fact. The law at every layer: identity is
  the BASE's (unify peels the pin in RN.2's exact shape, a var
  binding the PINNED type so repr_of chases to the width; fold_strip
  strips it so every dispatch sees the base; same_ground recurses),
  and repr_of's own arm is the ONE width reader — annotation, never a
  type. H6 did the sweep's work: the first march's census convicted
  all SIXTEEN exhaustive Ty walks by weave line (occurs_in · fp_ty ·
  same_ground · chase_probe_tag/chase_changes/chase_deep_build ·
  free_in_ty · subst_changes/subst_ty_build · ty_handle_of ·
  extract_row · enumerate_typed · fold_sig · show_type ·
  query_flow_label · render_type_tokens, plus ty_lo's unflagged
  straggler), each gaining its transparent arm — the
  census-names-the-walks feedback at full width. The formatter is the
  parse's inverse both ways: a bare atom renders bare, an alias pin
  renders its suffix. RF64-on-Float is the fully-live pin; i64/f32/
  v128 carry whole vocabulary with their emission cash-outs riding
  the named wide-producer residue, and fold_strip's arm banks band
  D's fold_sig-reads-repr reopening for the first wide-int producer.
  Fixture mn-repr-pin runs 42 (RED on the prior boot: `repr`/`f64`
  refused as unknown names); SYNTAX's lathe-lag note trued. CLEAN
  m2 == m3 at 353,220 lines; census 0; frontier 328/0;
  proof-exactness 9/9; crown 5/5.
- 2026-07-30 · ▶▶ THE WHOLE VALUE AND ITS PIECES — SYNTAX's as-pattern
  is real end to end (pin 010fc317). `name @ pat` parses (the TAt peek
  after a lowercase pattern ident), types (the binder's cell IS the
  scrutinee's — one unify edge, so the name carries exactly the
  matched value's type — then the inner walks the same handle),
  lowers (LPAs, the inner keeping the scrutinee's type through
  lower_pat_typed), and emits (the predicate is the inner's alone —
  the binder never affects matching; the bind stores the whole value
  at the pattern's path before the inner's binders; the local at the
  pattern-binder word floor). The whole walk family gained its arms
  in one sweep with the census catching the single wrong guess
  (render_pat → render_pat_tokens). SYNTAX's lathe-lag note trued.
  Fixture runs 47 (mn-as-pattern — `e @ Click(x)` feeding both
  altitudes to one arm; the frontier leg registered). CLEAN m2 == m3
  at 351,914 lines; census 0; frontier 327/0; proof-exactness 9/9.
- 2026-07-30 · ▶▶▶ THE REST COMES TO RECORDS — SYNTAX's documented
  `{name, ...rest}` pattern is real end to end, and the sweep fixes a
  latent wrong-slot class as its rider (pin 7932c192). The parse
  mirrors the list rest's at_ellipsis arm; infer binds the rest to a
  record carrying the SAME residual row the open pattern constrains
  (mk_record_open([], row_h) — resolution flows by construction);
  lower_pat_typed resolves the receiver's full sorted field set
  (structural TRecord, or nominal through nominal_record_fields — the
  judge convicted the first TName three-field guess: arity 2, the env
  channel is the truth) into residual (field, src_index) specs; emit
  BUILDS the residual record (alloc + word-slot copies, the declared
  rest local doubling as the build accumulator — no scratch spent)
  and the rest's own field access reads the residual's layout. THE
  RIDER: the named fields' offsets now read their TRUE full-set
  indices where the receiver resolves — the pattern-subset index bake
  (`4 × pattern-index`) was the wrong-slot class at the pattern
  layer, pre-existing. An unresolved receiver floors loudly
  (resolved-or-loud); nested rests ride the same floor until the
  receiver threading deepens; word-width copies inherit the named
  f64-aggregate-pattern-width residue. SYNTAX's lathe-lag note trued
  in place. Fixture runs 30 (mn-record-pattern-rest, the frontier
  leg registered); CLEAN m2 == m3 at 351,099 lines; census 0;
  frontier 326/0; proof-exactness 9/9.
- 2026-07-30 · ▶ A CAPABILITY UNLOCKS ONCE + two stale items counted
  (pin ec1d4664). The audit's severance line concatenated per-effect
  unlock lists undeduped — IO and Network both unlock CSandbox, so
  "Sandbox (proven no network access)" rendered twice per fn severing
  both; severance_unlocks dedups by structural == over the nullary
  ADT. AND the queue healed itself twice, measured before building:
  `mentl <unknown-verb>` exits 2 (the exit-code sweep had already
  landed the refusal the space-era note asked for), and the abs-path
  audit answers identically to the relative form (the shim's
  path-derived mount + the verb rewiring healed it) — both
  observations retired as stale, zero code. CLEAN m2 == m3 at
  349,509 lines; census 0; frontier 325/0.
- 2026-07-30 · ▶▶ THE DIAGNOSTIC SPEAKS THE USER'S LINE —
  Hβ.diag.file-local-span-render RESOLVED at the register
  (pin 4aa1f090). scope_localize rebuilds diag_line's one `at <span>`
  tail in the user's coordinates whenever the span falls inside
  ScopeAt's range — a pure string/ctor read in the root arm (the span
  needs no graph world; the register's range IS the subtraction, so
  the per-line seam walk the debt renderer measured as crc-class cost
  never enters this path). With the quiet-discovery landing beneath
  it, the whole check-path chain is: the discovery parse absorbs →
  the weave parse reports once → the register localizes — a line-2
  type error renders ONCE at 2:19 where the DAG path had printed
  twice at weave 5730 (the localize frontier leg banks both faces;
  325/0). ScopeAll (the census channels) stays weave-native by
  construction. CLEAN m2 == m3 at 349,406 lines; census 0;
  proof-exactness 9/9.
- 2026-07-30 · ▶ THE DISCOVERY PARSE GOES QUIET — the report doubling
  dies at its source (pin 0b3d9348). driver_extract_imports' throwaway
  bracket gains ~> diag_quiet (the trial's own absorption policy): a
  structure read is not the reporting pass, its file-local spans are
  unplaceable, and the weave parse re-reports every diagnostic
  placeably — every parse diagnostic had printed TWICE since the DAG
  path was born (measured all day as the 2:24 + 5730:24 pairs; ONE
  now). The fn's declared row drops the Diagnostic it no longer
  carries. The surviving coordinate is the WEAVE span — the
  Hβ.diag.file-local-span-render residue rises in priority with its
  design sharpened: the seam render exists (span_render_local) but a
  per-line seam walk at census scale is the crc-class cost, so the
  render-side subtraction reads the REGISTER's own range, never a
  per-diagnostic seam walk. CLEAN m2 == m3 at 349,099 lines; census
  0; frontier 324/0; proof-exactness 9/9.
- 2026-07-30 · ▶ THE STRING NAMES ITS OWN LINE —
  Hβ.lexer.string-newline-refusal RESOLVED (pin ec3bc868). A raw
  newline in a SINGLE-line string literal reports P_UnclosedConstruct
  at the string's own line with the `"""` teaching, terminates the
  literal, and leaves the newline unconsumed — productive-under-error
  at the lexical layer — where the swallow had run to the next quote
  or EOF and surfaced as a brace complaint lines away (measured: a
  line-2 error reported at 6:1; the fmt hook itself then witnessed
  the new diagnostic firing on the banked fixture's own line). The
  triple scanner is its own chunk walk, untouched; the wheel carries
  ZERO of the narration (the fmt string-atomicity law had kept
  content newlines out). CLEAN m2 == m3 at 349,088 lines; census 0;
  frontier 324/0; proof-exactness 9/9; mn-string-newline banks the
  refuse contract.
- 2026-07-30 · ▶▶ THE QUIET FN FITS UNDER THE CAP —
  Hβ.effects.directional-fn-row-edge RESOLVED at its measured scope
  (pin cd43c23c). The call edge's fn-arg row meet goes DIRECTIONAL
  where the param's declared row is a CONCRETE cap (closed or the
  !-stance EtAll): fn_arg_directional_positions meets non-row
  components symmetrically, the TOP rows by row_subsumes(arg, param),
  and masks the position from the wholesale unify (a fresh slot — the
  symmetric equality never re-runs). A Pure fn now admits where a
  `with Tick` fn is expected — the banked RED runs 7 — while the
  noisy-into-narrow refusals stand (hof-row-gate's leg + the
  Tick-vs-Pure face, both measured same-day). THE SCOPE WAS PAID FOR:
  the first form masked VAR-tailed param rows too, and the wheel's own
  census convicted 297 sites in ONE march — the effect-polymorphic
  channel (map's f) is a FLOW the arg's row must unify into, never a
  cap to subsume under; row_cap_form is that boundary, written where
  the 297 taught it. TRANSITION m3 == m4 at 349,013 lines; census 0;
  frontier 324/0 (the admit leg registered); proof-exactness 9/9;
  crown 5/5. The nested-variance tail (a fn-arg's OWN fn-params flip
  direction again) stays out of scope by the peer's own sequencing.
- 2026-07-30 · ▶ THE SUMMIT WAS ALREADY PROMOTED — the fmt-canonical
  page closes as a measurement, not a ceremony (no pin move; boot
  a62b1299 stands). The whole-wheel fmt sweep (every src + non-tutorial
  lib file through the verb) found the tree at the fixpoint except
  own.mn's 8 reflowed lines — the pre-commit fmt rung has been
  promoting the canonical form file-by-file since it landed, so the
  queued "summit promotion" dissolved into practice already in
  motion. The last file lands; the march is byte-identical; the fmt
  summit's swap-gate ledger item is CLOSED by the artifact's own
  state.
- 2026-07-30 · ▶ TWO ROWS SHARPEN TO THEIR INTENT — the third marker
  wave (no pin move — comment/tools only; boot a62b1299 stands). Mode
  7's naming-tell anchors to the let-tuple destructure (a CTOR's
  payload binders legitimately carry the _h handle convention — the
  BoundaryEdge record's own fields had demanded 17 markers under the
  bare-pair form), and mode 3's string-keyed row anchors to the
  COMPARE/arm adjacency (`== "IO"` / `"IO" =>`) — the bare literal
  inside `intern_str("IO")` is the NEW shape, the canonical name
  entering the intern once, and the old row fired on the cure. Four
  families strip (positional-destructure, same-as-above,
  literal-NAMES-the-effect, pre-warm-names): markers 161 → 136; day
  total 269 → 136 (49% of the eradication charge executed through
  precision, never through suppression). Full-wheel audit CLEAN; the
  march byte-identical.
- 2026-07-30 · ▶ THE AUDIT GAINS THE CODE CHANNEL — the string-literal
  blindness dies structurally, and the second marker wave strips (no
  pin move — comment/tools only; boot a62b1299 stands). Code-channel
  patterns scan a STRIPPED TWIN (string contents → "", // tails
  removed, line count preserved; reports and the suppression walk
  cite the original), so a keyword grep can never fire inside an
  emitted WAT string or a prose sentence again; content-targeting
  rows (modes 3/9/10-strings/14/37) declare `raw` and scan the
  original — the twin itself taught the split when the strip
  COLLAPSED every string to the empty-string tell and mode 10 fired
  22 false hits (the string-CONTENT patterns are raw by nature).
  Same-line suppression reads the original (the twin's stripped
  marker was invisible to the text filter — measured, fixed).
  Markers 180 → 161 (WAT-instruction-text, output-literal, and
  Reason-string families); day total 269 → 161. Full-wheel audit
  CLEAN; the march byte-identical.
- 2026-07-30 · ▶ THE FIRST MARKER FAMILY DIES INTO THE MEDIUM — mode
  33 retires and its 89 suppression markers strip (no pin move —
  comment-only, the march byte-identical; boot a62b1299 stands). The
  let-where-pipe grep could pattern-match one line and demanded ~80
  hand markers ("sequenced effectful read") to suppress its blindness;
  its successor is the audit verb's verb-shape tier (pipe_shape_of,
  landed 2026-07-29), which counts USE EDGES through the total child
  projection and honors the sequenced-effectful and reuse exceptions
  STRUCTURALLY. The grep row deletes from drift-patterns.tsv with its
  retirement recorded in place; the full-wheel audit runs CLEAN with
  zero coincidental shielding (no other mode fired on the
  now-unsuppressed lines). Markers 269 → 180; the remaining families
  (WAT-instruction-text ×14, the BoundaryEdge positional destructures
  ×13, the tail) each retire when their medium-side successor exists —
  Hβ.audit.drift-modes-read-the-row's per-family ratchet, first
  family executed.
- 2026-07-30 · ▶ THE REFERENCE ENTERS ONCE AND SPEAKS LOCALLY — the
  refs facet's generation dedup + the seam projection's one home
  (pin a62b1299). The collector dedups by SPAN (a reference's
  identity is its source location; the converged rounds' re-minted
  generations rendered one reference FOUR times, measured), and the
  seam family moves to types.mn (module_seams / span_render_local
  beside show_span) where the verify debt lines and the refs render
  both read it: `refs of bump` answers one located line in the
  developer's own coordinates. CLEAN m2 == m3 at 348,397 lines;
  census 0; frontier 323/0; proof-exactness 9/9.
- 2026-07-30 · ▶ THE DEBT SPEAKS THE DEVELOPER'S COORDINATES — the
  four-times-paid hand map becomes a projection (pin 852c34dc). The
  pending ledger's spans render as `path:local_line` through the
  graph's own NModule seams (debt_module_seams reads the span log
  once; the driver minted one NModule per woven file at discovery —
  the same seam truth the comment re-homing pass reads); a seam-free
  blob weave (stdin, the march) renders the raw span by construction.
  The DAG face measured: `tests/frontier/mn-verify-interval:29`
  where the weave's 5709 stood. Retires the session's named
  weave-span→file:line confession (⟳(2) — the fourth hand-pay was
  this landing's own trigger). CLEAN m2 == m3 at 348,178 lines;
  census 0; frontier 323/0; proof-exactness 9/9.
- 2026-07-30 · ▶ THE DEBT NAMES ITS PRODUCER — the voice annotation's
  placement trade (pin 44877c73). resolve_cursor_target gains
  `current_handle: Handle` + `-> Handle`: the Caret ctor's
  consumer-edge pend discharges through the adopted return alias and
  the producer's own return pends at its decl — count holds 11, but
  the ledger now attributes the missing proof to the fn that MINTS
  handles (its match leaves are transparent-position VarRefs the
  two-face law correctly refuses to type-read; the honest cure is the
  authored-payload read, the same family as the self-call IH). CLEAN
  m2 == m3; census 0; frontier 323/0.
- 2026-07-30 · ▶▶ THE LET ANNOTATION BECOMES A CONSTRAINT — a measured
  judgment hole closes, and the interval arc takes its first wheel
  debt (Hβ.infer.let-annotation-base-unify RESOLVED · pin 30194578).
  THE HOLE, probe-first: `let x: Int = "hi"` compiled CLEAN —
  apply_let_annotation only verified the refinement; the value cell
  never met the annotation, so the base-type half of "the `: T`
  annotation is a CONSTRAINT" (the code's own promise) was decorative,
  and an annotated alias could never reach a consumer edge (the lexer
  annotation's arg echo starved on exactly this — measured as a
  12 → 12 wash before the edge landed). THE LANDING, three moves in
  the licence's order: constraint FIRST (the uncontaminated read),
  the base unify (the mismatch refuses — mn-let-ann-pins banks the
  refuse contract), then the REPRESENTATIVE REBIND (the decl pin's
  most-refined-member law at the let: a concrete-bound value cell
  cannot adopt through concrete-meets-refined, so the refined form
  re-binds as the class representative — the third measured face of
  the one peel root, after the rec-callee publish and the param
  census). THE CHAIN'S YIELD: lex's `let n: ValidOffset =
  byte_len(source)` discharges its own obligation through the len leg
  (the first wheel-internal interval discharge) and the lex_from arg
  edge echo-stops through the adopted alias — wheel debt 12 → 11.
  Census 0 at every step (zero wheel lets lied); CLEAN m2 == m3 at
  347,287 lines; frontier 323/0; proof-exactness 9/9; the battery
  carries the new refuse contract. The remaining five `0 <= self`
  survivors keep their named routes in the residue index.
- 2026-07-30 · ▶▶ THE AUTHORED RETURN RIDES AS A VALUE — the interval
  fragment's callee leg goes live cross-fn (pin 5e34f710). An authored
  `-> RetTy` rides the pre-registered TFun as the resolved Ty VALUE
  instead of the bound cell (pre_register_fn_sig's ret_component): a
  value inside the record cannot be class-contaminated, so
  callee_ret_lo reads the callee's own annotation verbatim at every
  call — `fn wrap() -> Nat = base()` discharges through base's
  declared Nat, the assume-the-signature induction with nothing to
  launder. The discriminating probe that drove it: wrap DISCHARGES
  while the self-call (seek) still pends — so the failure was never a
  peel window (the prior entry's theory, corrected in place) but the
  callee read hitting a TVar ret, and ty_lo keeps NO TVar arm BY
  DESIGN: a chased ret var reaches the obligation's own class through
  tail-call merging, and an unannotated tail callee granted that read
  would launder (the g-case — `fn f() -> Nat = g()` with g free must
  pend at f, and does). The SELF-CALL IH is the named remainder with
  its exact sound discriminator banked (callee-class == DECL-class —
  class-vs-TARGET is the launder, class-vs-DECL is exact; needs
  graph_root_of + a Predicate carrier). The cell still binds for
  forward-ref grounding; infer_fn's unify against the pre-scheme
  keeps semantics — TRANSITION m3 == m4 at 347,173 lines (the
  105k-line m2/m3 diff is the representation crossing one
  generation); census 0 at every generation; frontier 323/0
  (the fixture grows the wrap/base faces, runs 28, still exactly two
  honest pendings); proof-exactness 9/9.
- 2026-07-30 · ▶▶▶ THE INTERVAL FRAGMENT AND THE FLOW LICENCE — Verify
  grows its first inference leg, and the dig kills a measured
  refinement launder (Hβ.verify.interval-fragment's engine half lands ·
  pin a71ebbcb). THE SOUNDNESS KILL first, witnessed at runtime: the
  typed-identity echo-stop read CLASS membership as proof, and the
  arith unify puts a computation's result in its operand's refined
  class — `fn wild(v: Nat) -> Nat = v - 1` accrued NOTHING and
  `wild(0)` ran to -1 through a `0 <= self` return (wasmtime's own
  "invalid exit status" the witness). value_flows_class is the
  licence: typed identity holds for value-FLOW nodes (a var, a call
  result, a join — the value IS a class member's value, covered by
  that member's own boundary obligation) and NEVER for a computation
  (BinOp/UnaryOp mint a NEW value whose membership is a theorem) —
  computations raise, at both readers (the accrual echo-stop and the
  synth-gate admit). THE ENGINE: a lower-bound read over node
  structure slotted into compare_decide_at's None path (verify.mn
  wholly; the arm row unchanged — the decide family already carries
  the superset). TWO FACES under one contamination law, the build's
  own second kill: the single-face walk's type-identity leg
  re-laundered `v - 1` by reading the obligation TARGET's class — the
  annotation's unify had just entered it — so the transparent face
  (the target + if/match/block joins, whose cells unify with the
  target's) reads STRUCTURE only (literals, joins, the len/byte_len
  floor), and type reads live where the class boundary is crossed: a
  BinOp's operands (cells merged with the arith ground, never the
  target's) and a call's bound off the CALLEE's published TFun return
  (the assume-the-signature induction). MEASURED on the fixture
  (mn-verify-interval, 21): cap discharges (if-join + len), bump
  discharges (Add + opaque type read of the refined param), wild
  pends visibly and still runs, seek pends as the named peel-window
  residue (its return constraint runs inside the ann-unify's peel,
  before the most-refined rebind — the rec-call's published bound not
  yet readable there). The frontier leg asserts EXACTLY TWO pendings
  — fewer is a re-launder, more is a lost discharge. RIDES WITH IT,
  the session's third find: image_pack's transient doubling crosses
  the allocator's SIGNED-2GB boundary (807MB packed clean, 1017MB
  trapped in alloc — the banked "wire doubles the image" residue
  firing as a hard 134 that killed the compile), and a best-effort
  cache must never kill the compile: driver_warm_persist skips loudly
  past 960MB (the capacity dissolves with the per-decl arena's
  image/scratch split). Wheel debt holds 12 with ZERO new accruals
  under the licence (the wheel launders nothing); the six `0 <= self`
  survivors are the annotation sweep's targets (the peer's remaining
  half, with the peel-window fix its sharpest single). CLEAN
  m2 == m3 at 347,171 lines; census 0; frontier 323/0;
  proof-exactness 9/9.
- 2026-07-30 · ▶▶ THE COMMENT COMES HOME AT THE SEAM — the weave's one
  cross-module attach class closes at the layer that owns the seams
  (Hβ.parser.comment-attach-module-boundary RESOLVED · pin 997684f1).
  The parser attaches prose over ONE seamless weave — correct
  single-file semantics, structurally blind to module boundaries — so
  a lib file's tail comment attached forward to the NEXT module's
  first decl, and the entry's own fns rendered kernel prose as their
  Lede (the felt face the ghost-addr dig surfaced). The seam truth
  arrives with the driver's ranges, so the re-homing lives THERE, not
  as a parser patch: the NModule fold collects (line_start, nlines,
  handle) triples, and rehome_seam_comments walks the parse span log
  re-homing any comment whose OWN span's module differs from its
  attached node's module — target the comment's own module's NModule
  cell (a module has at most one file tail; the cell never collides).
  THE DIG'S TWO OP-LAYER FINDS, each a Carried-Truth violation at the
  column: (1) the comment column STORES (text, span) — the attach
  writes both — but the read projected text only, so the comment's
  own address was unreachable; graph_comment_span_at is the sibling
  projection (one op per fact, the parse_span_of idiom — never a
  pair-widening that taxes format.mn's fifteen text-only readers).
  (2) attach MERGES behind existing text (the blank-separated-blocks
  rule), so "clear by empty attach" PREPENDS an empty paragraph and
  keeps the prose — graph_clear_comment is the honest take-side,
  restoring the column's own absent form. Felt face measured healed:
  the fixture entry's 1:4 projection carries no lib Lede. CLEAN
  m2 == m3 at 345,371 lines; census 0; frontier 322/0;
  proof-exactness 9/9; lede-demo green (own-prose attach untouched).
- 2026-07-30 · ▶▶ BOUND BEATS GHOST AT THE ADDRESS — the head-anchored
  decl-span defect's felt face closes (pin 4f477b1f). The measured
  face, RED-banked live through the prior pin: `mentl main.mn:1:4` (a
  column inside the decl's NAME) rendered `width( : t76439@e54117 /
  Why: placeholder` — the tightest-containing rule let a never-judged
  parse cell over the name beat the decl itself. ONE ordering axiom
  above the area rule, column mode only: a BOUND cell beats a ghost
  (address_bound — the graph's own "was anything proven here" read,
  one chase); a `??` node is typed, hence bound, so the hole's reach
  is untouched, and every prior address behavior survives where no
  ghost competes. The healed face projects the decl's full eight
  aspects with the Why at its own line. The frontier gains the
  decl-name address leg (both faces seen — 322 legs); the perimeter
  hook's lead-strip learns cd-prefixed compounds (its third
  over-block class closed). CLEAN m2 == m3; census 0; frontier
  322/0; proof-exactness 9/9. The named cousin stays open:
  Hβ.parser.comment-attach-module-boundary (the healed Lede shows a
  lib tail-comment attaching across the module seam).

- 2026-07-30 · ▶ THE HANDLE PRODUCERS OPEN — the 0 <= self sweep's
  first pair (no pin move — emission-neutral; boot dd8a70f1 stands).
  handle_at_span / scan_for_span gain `-> Handle` (the scan's miss
  default is the ground 0, its hit the walk counter): the transport's
  three re-demanded Caret/pin boundaries collapse to ONE honest
  producer pend, handle_at_span discharging by typed identity through
  its callee. Whole-weave debt 14 → 12; the day's Arc 3 arc
  138 → 12 (91%). The remaining twelve, classified at their sites:
  six 0 <= self (the Cursor-field chain, make_list's capacity,
  resolve_cursor_target, the render_at family — each its own short
  producer walk), three span_valid producer/construction pends
  (span_join, span_zero — the banked unfold's fixtures — and the
  module-mint), TagId ×2, Sample ×1. CLEAN m2 == m3; census 0;
  frontier 321/0; proof-exactness 9/9.

- 2026-07-30 · ▶▶ THE PROBES GRADUATE AND THE VERDICT CORRECTS ITSELF
  (pin dd8a70f1; this entry RETRACTS its own first conclusion in
  place, per ⟲ — the pin's commit message carries the era's wrong
  reading). The bound-hit channel gained two graduated probes —
  probe_entry_hist (the mover's env index + row-tail letter; its
  first read exposed env_snapshot's latest-per-name dedup: n=1 by
  construction, the probe's own blindness named at its decl) and the
  same-round re-read of row_print at the flip. Their data: same
  index, closed scheme, fresh-read closed, every flip A=open /
  B=closed. The first conclusion — "the carry is unfaithful, the flip
  is the instrument's artifact" — was REFUTED by walking the carry's
  own timeline: a deep-SCC member's ROUND-1 fresh read is HONESTLY
  OPEN (the SCC-internal chain still crawls one member per round —
  the twice-killed local-iteration problem, alive), the carry
  preserves that open render FAITHFULLY through masked-out rounds,
  and the flip fires exactly when the front reaches the member; the
  round-11 re-read is closed because by round 11 it IS closed. The
  instruments and the carry are both sound; the REAL residue is the
  one already spec'd twice: the SCC-internal crawl, whose true cures
  are the generality-join local iteration (measured requirements
  banked) or Hβ.infer.schemes-are-edges (the tower's deletion). The
  bound-hit stays marginal (the front usually completes by ~11), the
  emission stable, the banked unfold gated on either cure. Board at
  the pin: CLEAN m2 == m3; census 0; frontier 321/0.

- 2026-07-30 · ▶ THE DECLARED ROW PINS UNDER LAG — the gate's silent
  hole closes (pin 870d9fc9). The cached flip render convicted my own
  same-day revert (the stack-correct-fixes law live):
  parse_effect_list_from's published tail flipped open ↔ closed WITH
  its authored row, because the declared-effs gate's unbound arm was
  `_ => ()` — when mutual recursion left the body row unresolved at
  decl exit, enforcement silently skipped and generalize published an
  open-tailed final. The arm BINDS the declaration now: the contract
  stands regardless of round parity, and teaching beyond it
  mismatches loudly on the next unify. TRANSITION m3 == m4; census 0;
  frontier 321/0; proof-exactness 9/9. The residue is bounded to a
  point: the marginal run-variant flip persists with ALL decl-exit
  channels closed — the A-phase's open-tailed carrier must be a
  skipped-round env read surfacing the trial's loose prereg entry
  (the render matches its exact shape: six declared names + open
  tail); the banked next probe prints the flipping entry's env
  POSITION and GENERATION at the bound, which names the read path in
  one firing. The unfold patch stays banked behind it.

- 2026-07-30 · ▶▶ THE SIGNATURE AT THE CYCLE — the last structural
  oscillator dies, and the judgment CONVERGES for the first time (no
  pin move — the authored rows are emission-neutral, boot fb265daa
  stands). THE CONVICTION BY SOURCE: parse_one_effect performs
  intern_str — the parser SCC's rows carry Intern HONESTLY — and the
  undeclared pair's row tails oscillated open ↔ closed between rounds,
  the last bound-hit mover; which attractor the bound cut decided
  whether downstream install subtractions held, and the Intern this
  pair genuinely performs reached main's row as the "phantom" that
  struck three times (the relocations, the 2-cycle probe, the unfold's
  widens — all three victims one carrier). THE KILL: the pair gains
  its AUTHORED row (with Memory + Alloc + GraphRead + GraphWrite +
  Diagnostic + Intern — the signature price every HM judge charges at
  polymorphic-recursion points, SYNTAX's own form): the declared-row
  gate closes the tails deterministically, the whole-tree bound-hit
  goes from STRUCTURAL (every compile) to MARGINAL (run-variant at
  the 11/12 boundary, emission stable — CLEAN m2 == m3 across runs).
  TWO probes measured and reverted en route, each banked: the
  declared-row gate's unbound arm PINNING the declaration when
  resolution lags (principled — the `_ => ()` hole leaves a declared
  row unenforced under mutual-recursion lag — but it re-perturbed
  convergence; lands with the type-half understanding), and the
  unfold stack re-measured (parse_effect_list_from's fingerprint
  still flips under a fully-pinned ROW — the flip lives in the
  scheme's TYPE half: the next dig's exact target, movers_diff
  already renders it). Board: CLEAN m2 == m3; census 0; frontier
  321/0; proof-exactness 9/9. The unfold patch stays banked; the
  blocker demotes from structural to the marginal type-half residue.

- 2026-07-30 · ▶ THE DEMAND LAW'S DUAL FACE — never demand a proof the
  body doesn't use (pin fb265daa). The whole-ledger projection's map
  put six of the ten surviving span_valid obligations at ONE pair of
  lines (the address tie-break's span_area calls), and the site read
  inverted the fix's direction: span_area's ValidSpan param was
  CEREMONY — the area fold is total arithmetic over the four fields,
  the proof never read, the demand converting every bare-span caller
  into debt. Widened to bare Span (with find_tightest's call riding):
  debt 21 → 14, the day's arc 138 → 14 (90%) — and the remaining
  fourteen are ALL genuine: three span_valid producer/construction
  pends (span_join, span_zero — the Pure predicate-fn unfold's ground
  fixture — and the module-mint), eight 0 <= self producer
  boundaries, TagId ×2, Sample ×1. Zero ceremony left in the span
  class; the refinement discipline now has BOTH faces stated —
  producers carry proofs, consumers demand only what they read.
  CLEAN m2 == m3; census 0; frontier 321/0; proof-exactness 9/9.

- 2026-07-30 · ▶▶ THE LEDGER SPEAKS WHOLE AND THE CTOR FIELD CARRIES
  THE PROOF — Arc 3's second landing: debt 58 → 21, the day's arc
  138 → 21 (pin 862f66fd). THE VERB GREW FIRST (⟳(3) — the count line
  hid the composition; the per-entry projections had classified 138
  one file at a time): report_verify_debt renders the COMPLETE ledger,
  one line per obligation (span · classify_predicate class ·
  predicate), and its first firing answered in one read — 47
  span_valid boundaries, 31 of them infer-side consumers of
  node-destructured spans. THE PRODUCER AT THAT SCALE IS THE
  CONSTRUCTOR FIELD: Node = N(NodeBody, ValidSpan, Int) — every
  destructure reads ValidSpan by type, the obligation moves to
  N-construction, and the parser's mints discharge by identity
  through the already-annotated span_at/span_join (the chain closing
  exactly as the producer-carries-proof law predicts). 85% of the
  wheel's proof debt discharged by construction-site TYPING alone —
  zero engine changes, three producer annotations and one ctor
  field. CLEAN m2 == m3; census 0; frontier 321/0; proof-exactness
  9/9. THE RESIDUE, exact from the whole-ledger read: 10 span_valid
  at unfed construction sites (the lexer's counter-built mints — the
  Pure predicate-fn unfold's own fixtures), 8 bare 0 <= self
  (Handle/ValidOffset producers), 2 TagId, 1 Sample. NAMED with the
  session's third recurrence: the weave-span → file:line projection
  is missing from the verbs (three hand-mapping loops tonight; the
  debt listing renders weave coordinates — the file-local-span
  class's inventory face; one projection at the range map retires the
  hand loop).

- 2026-07-30 · ▶▶▶ THE PRODUCERS CARRY THE PROOF AND THE VERBS READ ONE
  WEAVE — Arc 3 opens with the span-debt collapse and a true-positive
  gate find (pin d14fa41e). THE INVENTORY BY THE MEDIUM: the field
  projection classified the wheel's 138 pending obligations to ONE
  dominant class — span_valid at ~85 consumer boundaries, the proof
  lost at every producer's bare Span return. THE COLLAPSE: span_join /
  span_zero / span_at gain `-> ValidSpan` (the construction-site law
  types.mn's own comment always promised; Intent Boundaries, three
  lines) — whole-weave debt 138 → 58, ~80 consumer boundaries
  collapsing by typed identity into two honest producer obligations;
  CLEAN m2 == m3; census 0; proof-exactness 9/9. THE GATE THEN EARNED
  ITS KEEP: the frontier's session leg went red as a TRUE POSITIVE —
  the fixture's weave reaches src/types.mn (runtime/lists imports
  types), and the COLD audit's "pending: 2" turned out to be JUNK
  DEBT from the analysis verbs' own SECOND discovery path:
  driver_check_entry runs per-module SOLO checks judged without their
  layer's vocabulary (the per-module-env-overlay residue, live) —
  measured flooding E_MissingVariable on True/len/list_index from any
  out-of-tree directory, stderr discarded by the gate, junk obligations
  accruing — while the RESIDENT session read the weave and told the
  truth (the leg had passed only while the junk was zero: a gate that
  could not fail until the annotations armed it, forensic law 5 live).
  THE REWIRE: audit/teach (analyze_fns) and query derive through THE
  ONE DISCOVERY HOME — driver_entry_with_ranges + driver_module_ast,
  the same weave the check verb, the address, and the resident session
  read; driver_check_entry's remaining callers are fmt (which wants
  the entry's solo parse for file-local render spans — its dep-flood
  is named residue) and the compile path's own walk. Frontier 321/0
  from both sides. BANKED: teach's missing facet — debt-keyed
  REFINED-RETURN proposals (walk the obligation's Reason to the
  producing callee, propose the alias; tonight's 85-to-1 ratio is the
  spec) — and the R3 unfold gap made exact: span_zero = Span(0,0,0,0)
  under `where span_valid(self)` pends because the predicate is a FN
  CALL; one-level unfolding of a Pure predicate fn on a ground
  construction discharges it outright — the highest-yield Verify
  increment next.

- 2026-07-30 · ▶ THE PASS INVARIANTS STOP RE-DERIVING — classify-once
  + cone-proportional prints (pin 43f33c0a). Two carried-truth
  deletions the eight-interrogation audit surfaced on the convergence
  machinery: classify_fixpoint ran per PASS (thirteen whole-tree walks
  per judgment) while its own comment admitted the grades read arm
  STRUCTURE no pass changes — it classifies ONCE in the trial and the
  name-keyed value threads to every round and the final; and
  round_prints fingerprinted EVERY name every round while the
  value-boundary law makes a masked-out final a VALUE nobody can
  teach — its print carries, only the cone re-renders
  (round_prints_masked; the m3 == m4 oracle backstops the law). Both
  CLEAN. Measured honestly: the field read holds its ~60-69s band —
  the alternating SCC families keep the cone LARGE (they and their
  dependents re-judge every round) and the per-round re-parse
  dominates, so the collapse waits on the generality join; with it
  the two named per-round re-derivations left are the parse (the
  checkpoint+frozen-finals form dissolves it — proven mechanically by
  the iteration arc, gated on the join's freeze semantics) and the
  prepass. RIDER: the pin ritual's mandatory re-read caught a sha
  tail completed from memory (the ⊕ fabrication class, second live
  catch) before it reached the blessed line.

- 2026-07-30 · ▶▶ THE ITERATION MEETS ITS MONOTONICITY — the second
  counted kill of the SCC rung, and the join named as the true
  remainder (no pin move — the reverted tree reproduces 5db9b4c3
  CLEAN). Per-SCC local Mycroft iteration was BUILT WHOLE on landed
  machinery: probe passes over rollback-refreshed parse nodes
  (graph_push_checkpoint/graph_rollback as the FRESH-NODE SUPPLY — the
  same parse nodes re-judge with virgin cells, zero re-parse, the
  whole-tree rounds' re-parse dissolved for the group's scope), finals
  frozen to values between probes, fingerprint-stable → a bare keep
  pass. Its own instruments then drove three rounds of truth: (1) the
  handle-reuse freeze lesson — a carried quantifier set left
  probe-minted leaves unquantified and the restored mint counter made
  the next probe REUSE their handles; the fix is
  Forall(free_in_ty(chase_deep(t)), ·), full re-quantification of the
  folded value (quantified vars are mapping-first at instantiate, so
  reuse is inert); (2) the scc2 sequence probe measured SIMPLE pairs
  CONVERGING in two probes (scan_string_loop/handle_escape,
  spec_resolve, module_imports — the mechanism works); (3) the
  scc-flip render convicted every generic/concrete-tension family of
  PERIOD-2 ALTERNATION (chase_*_changes, serialize_*, emit_pat_*:
  params flipping rl%0 ↔ rlNTy() probe over probe, rows gaining and
  losing Memory+Alloc) — re-derivation-from-scratch is NOT MONOTONE:
  concreteness learned in probe k evaporates in k+1, and a 45-member
  group burned 47 probes to no fixpoint. The literature's own contract
  (Salsa cycle recovery: participants must be monotone; join against
  last_provisional_value) is confirmed by the artifact. The iteration
  DELETED whole (drift-9 — the knowledge lives here); the Tarjan
  substrate, the group-ordered trial, and both flip instruments stay.
  THE TRUE REMAINDER, now fully specified: the GENERALITY JOIN —
  freeze_k := join(freeze_{k-1}, result_k), rows through row_join
  (their lattice exists), type schemes through a widening that keeps
  the more-informative of consistent shapes — and with it the
  iteration converges monotone and the rounds retire. Board: CLEAN
  m2 == m3 at 343,707 lines; census 0; the standing pin holds.

- 2026-07-30 · ▶▶ BINDING GROUPS FOR ORDER, MYCROFT FOR CYCLES — the
  Tarjan substrate lands, and the classic mono-group form dies to the
  wheel's own judgment (the SCC rung's first arc · pin 5db9b4c3). The
  SOTA sweep ran first (Morgan's charge): the classic form (Heeren's
  generalized-HM framing, GHC binding groups — SCCs judged once,
  mono-within-group, generalize at exit, zero iteration) against the
  bleeding edge (Salsa 2025-26 cycle recovery in rust-analyzer —
  per-cycle FIXPOINT iteration with monotone join), and the decisive
  difference named: Salsa iterates because a query system discovers
  dependencies during execution; Mentl's frees DAG is parse truth
  known up front. THE BUILD: scc_groups — Tarjan over the same frees
  the layers read, 7-tuple state threaded whole (the record-threading
  first form died to spread-update inference fragmenting the type;
  the medium also taught that nominal record spread P{...a} is
  unparsed — anonymous {...a} is the documented form), groups popped
  callee-first BY CONSTRUCTION (a sink SCC completes first) — and the
  trial walks groups in topo order, cycle members adjacent in source
  order. THE COUNTED KILL, the arc's real yield: the classic MONO
  semantics was built WHOLE (mono views over the prereg skeletons,
  re-asserted per member, group-exit generalization — zero new
  minting) and the wheel CONVICTED it with 29 E_TypeMismatch
  (Int vs Float, List(Byte) vs Int — a cycle member used at TWO
  instantiations by co-members): the rounds are a MYCROFT ITERATION
  (polymorphic recursion by fixpoint) and the wheel genuinely uses
  that power inside its cycles, so GHC's weaker classic form cannot
  serve Mentl — the more-accepting semantics IS the ultimate form,
  and the rung redirects to per-SCC LOCAL Mycroft iteration (Salsa's
  own shape; fresh nodes per re-judgment via branch-cursor
  instantiation — the fan as the iteration substrate). Board at the
  pin: TRANSITION m3 == m4 at 343,707 lines; census 0; the SCC crawl
  unchanged (14 convergence lines — order alone cannot fix
  intra-cycle iteration, exactly as predicted). The residue index
  carries the redirected spec.

- 2026-07-30 · ▶▶▶ THE JUDGMENT CONVERGES CALLEE-FIRST — the rounds'
  resolution front dies at three roots, and the "oscillation" was
  never an oscillation (Hβ.infer.round-oscillation-movers' dig ·
  pin 78b1736b). THE INSTRUMENT FIRST (banked last session, landed as
  the opening move): movers_diff renders each bound-hit mover's TWO
  round-fingerprints verbatim — the A/B byte-diff IS the flipping
  component — and probe_tail_why reads the mover's published row-tail
  cell through graph_reason_at, the Why engine naming the binder. Its
  first firing killed the attractor theory outright: every flip was
  MONOTONE open→closed, one call-DAG layer per round (round 9 closed
  columns, round 10 its caller comodulogram, round 11
  pac_comodulogram — a resolution FRONT the 12-round bound cut
  mid-climb; the 12-round tax was the wheel's call depth). THE THREE
  ROOTS, each measured before fixed: (1) ty_fingerprint rendered a
  row's name SET in storage order — walk_lemit/walk_lemit_top
  fingerprinted one set in two orders and cone-thrashed forever; the
  render now imposes ascending-handle order (fp_names' selection
  walk), the equality witness's own contract, exactly as fp_var
  alpha-numbers vars — while the ROW layer stays deliberately
  orderless (its own law: no algebra consumer reads an order; the
  fingerprint is the one consumer that needs determinism and pays at
  the render, never on the ef_make hot path; fp_row's false
  "sorted at birth" prose trued). (2) stmt_layers_ast counted only
  BACKWARD edges — backward_depth's restriction was spelled in its
  own name; deleted into a memoized descent over the WHOLE frees DAG
  (cycles flatten via the on-stack guard), so forward-reference
  chains close in one round. (3) the trial judged in SOURCE order
  only to be re-derived by round 1 — the trial now walks its own
  layers (frees + decl names are PARSE truth, computed once before
  any judgment, riding out to serve trial walk + rounds' cone +
  final's sweep; infer_stmt_list_measured deleted). MEASURED: movers
  at the bound 16 → 1; the survivor is the unify/parser SCC chain —
  an SCC's closure still crawls its internal diameter one round per
  link (member B reads co-member A's previous-round final across the
  cycle's stale link), so the bound still cuts and the field read
  holds at ~59s (the tax is round-count × the per-round FIXED costs:
  full re-parse + classify_fixpoint + round_prints, cone-independent).
  Two honest widens rode (row_to_with_clause / neg_names_to_str
  + GraphRead — the converged judge resolves deeper than the
  bound-cut attractor ever did). TRANSITION m3 == m4 (twice en route,
  once at the pin); census 0 at every generation. THE NAMED NEXT
  RUNG, spec'd by tonight's trace: the SCC-LOCAL FIXPOINT — judge a
  cycle as ONE unit iterated to its own fixpoint, whose true form is
  the branch-cursor fan (fresh instantiations per re-judgment are
  exactly what branch cursors provide) — the rounds absorbing into
  the fused oracle, killing the remaining bound-hit AND the ~59s
  daily-verb tax in one mechanism (rounds 12 → ~3). Banked with it
  (Morgan's charges, 2026-07-30): the drift-audit ignore MARKERS and
  the "drift" vocabulary itself are Claude-weakness bookkeeping with
  no place in the medium's body — their eradication rides
  Hβ.audit.drift-modes-read-the-row (the audit reads the ROW and the
  graph's edge order; all ~223 markers delete with it); and the
  perimeter hook gained wrapper-tolerant lead detection (timeout/nice/
  env-prefixed mentl is still the verb).

- 2026-07-29 · ▶▶ THE FIXTURE STATES ITS OWN CONTRACT — the refuse
  grammar lands and the frontier bash's dissolution channel opens
  (the self-exemplification pass's banked opening move executed ·
  pin 2fb58e9a). `// expect: refuse E_Class` joins `// expect: N` as
  the Expect ADT (ExpectRun | ExpectRefuse); battery_compile carries
  mcp_diag_collector (the forwarder — every line still reaches
  stderr) and returns the banked diagnostics beside the gate verdict;
  a refuse fixture passes iff the named class REPORTS as an error —
  the battery judges the JUDGMENT, never stricter than the medium
  (armed classes withhold the artifact, unarmed ones surface-and-emit:
  both are the law, and the contract asserts exactly what the medium
  asserts). First two contracts live and REFUSE-passing through
  `mentl test tests/micros` (117 run + 2 refuse): the forward-order
  seam and the hole gate as self-stated fixtures. RIDES WITH IT:
  the mentl-first perimeter — the repo's own PreToolUse hook refuses
  grep-family reads AND Edit-bypassing writes against .mn source AND
  the hand-assembled invocation family (`source wt-env && wt_run …` —
  ⟳(2)'s own 2026-07-26 catch, re-caught tonight and made unsayable;
  the installed verb IS the invocation; scripts and /tmp/.build stay
  free; `# mentl-skip: <reason>` is the confession channel naming the
  missing projection). AND THE SINGLE SOURCE OF TRUTH (Morgan): every
  `~/.claude/plans/*` file verified against the artifact — five are
  other projects; the two Mentl files (the eight-arc finish line +
  its execution sidecar) are integrated here (§11's arcs +
  definition-of-done + risk tripwires) and retired to archaeology.
  CLEAN m2 == m3 at 339,714 lines; census 0. The dissolution
  continues per-family: each frontier refusal leg converts to a
  contract fixture as it is touched, and the bash mass falls with
  every conversion.

- 2026-07-29 · ▶▶▶ THE SESSION IS THE TRANSPORT — resident-first
  becomes the CLI's default, and the dormant-to-canonical audit that
  chose it is executed (Hβ.session.resident-verbs' CLI face ·
  pin e09626cb). Morgan's question ("abilities that are dormant that
  should become canonical default?") ranked five; the first lands
  whole: `mentl session` derives the project ONCE (mcp_run's bracket,
  the living check per connection) behind the shim's tcplisten seam
  (the space verb's proven pattern, port 7377) and answers the READ
  verbs — at/query/audit/teach, the field via at line 0 — over a
  one-line wire speaking the CLI's OWN GRAMMAR: the shim tab-joins
  argv, session_answer parses it with parse_cli_args (one grammar, two
  transports, zero new protocol), and serves through the SAME
  projections the cold verbs run. MEASURED: resident audit BYTE-EQUAL
  to the cold verb's output; MISS fires for cold-only verbs and the
  shim falls back to the cold exec; a bare teach serves the resident
  entry. THE SHIM INTERROGATED (Morgan's unease was a correct
  Carried-Truth read): its first forward form duplicated the routing
  policy in a bash case — dispatch truth in TWO homes — and was cut
  to a pure transport: EVERY verb is offered, the MEDIUM decides
  (session_answer's match is the one policy home), MISS or a dead
  port falls back. The shim's whole seam family (mounts, exec,
  listeners) remains the WASI-p1 pressure gauge for the runner
  migration (Hβ.ops.wasmtime-runner-migration), where it dissolves.
  THE DIG'S TWO KILLS EN ROUTE: the resident at cost 131s PER CALL —
  address resolution list_indexed the converged session's
  multi-generation snoc span log (the iterate-flattens-once law's
  FOURTH kill; flattened once before the walk: 131s → 0s, the cold
  path faster too) — and the 1:4 "placeholder" projection was chased
  through a refuted cell-filter theory (built, probed, REVERTED — the
  winner carries a real body) to its true class: the HEAD-ANCHORED
  decl span (the ranker landing's own named lathe-lag) leaves the
  FnStmt uncontaining at name columns, so a tighter never-bound cell
  wins and renders its free var; cold reproduces byte-identically —
  a pre-existing address-face defect, NOT a session regression (the
  transport faithful even to the bug), its fix the named
  tree-containment form (Hβ.cursor.enclosing-decl-edge's address
  face). AND THE MENTL-FIRST GATE (Morgan: "nothing else I've tried
  has actually got you to stop using grep"): the repo's hook set gains
  .claude/hooks/pre-bash-mentl-first.sh — a grep-family command
  against .mn source is mechanically REFUSED with the verb menu that
  answers better (query/refs/why/at/check/audit), artifact greps stay
  legal, and the escape hatch (# mentl-skip: <reason>) is a ⟳(2)
  confession naming the missing projection. Prose could not enforce
  the medium-first order; the hook makes the wrong move unsayable —
  the larval mentl audit at the toolchain boundary. GATES: two
  frontier legs (session resident audit byte-equal · the MISS
  sentinel), RED against any pre-session boot by construction; CLEAN
  m2 == m3 at 339,257 lines; census 0. Remaining dormant-to-canonical
  queue, ranked at the audit: the ambient frontier (bare `mentl` in a
  project answers the ranked field), tighten joining fmt's canonical
  pass, `mentl march` as the practiced default over the bash script,
  session-image persistence on exit; the felt payoff of resident-first
  stays capped until Hβ.infer.round-oscillation-movers lands (the
  12-round tax on every re-derivation).

- 2026-07-29 · ▶▶▶▶ THE ONE JUDGE — every judgment site runs the
  converged walk, and the single-pass infer_program DELETES
  (Hβ.infer.order-independent-verdicts' daily-verb face closes ·
  pin 223452c1, superseding the session's three intermediates —
  9d346047 the one-judge TRANSITION, 4d50895d effects-home +
  structured bank, afff6ade the O(n²) snapshot dedup — as the frontier
  and the march clock convicted each; the arc's facts below). THE SEAM,
  probe-first: the audit-banks landing had
  named a tuple list meeting str_concat_all's [String] with no refusal;
  the b1 probe minimized it — a fn declared AFTER its caller judged
  through the DAG path read the LOOSE pre-registration, so its [tuple]
  return bound silently against [String] (zero diagnostics, the
  runtime flat_fill trap), while the backward-declared twin refused
  cleanly. The consumer census then named the split: the converged
  judge served stdin/compile/mcp only; check/audit/teach/at/field/
  session/repl/battery/warm-cone ran single-pass at driver.mn's three
  sites, driver_check_module, analyze_fns' stdin arm,
  compile_source/check_source, battery_compile, and repl_eval_line.
  ALL NINE now run infer_program_converged; infer_program deleted with
  its prose trued. THE OWNER SWEEP rode along where provable: the
  free-vars family (collect_free_vars + fourteen kin) → parser.mn
  (parse truth — lower's captures and the judgment's layers both read
  it, and infer←lower was the cycle that had stranded the cluster);
  the convergence cluster + frontend + diag_quiet + diag_branch →
  infer.mn beside the trial/round/final walks; the spec trio
  (spec_pairs_find/pair_or_var/subst_pairs) + lookup_ty_graph +
  effect LookupTy → graph.mn; effect EnvRead/EnvWrite/BranchEnv/
  Intern moved BESIDE their handlers (the effect-beside-handler law:
  a handler judged before its effect declares registers a broken
  identity — its install then absorbs NOTHING and a fully-handled
  program refuses at the gate, measured live when env_handler moved
  ahead of types.mn). THE EFFECTS PREPASS PHASE lands with it
  (pre_register_effect — the pre_register_alias precedent one
  namespace over): effects register whole before ANY handler sig, in
  the trial, every round, and the final. And the trial RETURNS ITS
  STMTS: the converged arm's frees walk read them instead of
  re-parsing — the arm-position frontend ran OUTSIDE diag_quiet (R2)
  and double-reported every check's parse narration; the re-parse is
  deleted (Carried-Truth). THE BLOCKED HALF, named with its conviction:
  relocating env_handler/intern_table OUT of pipeline.mn flips main's
  row to carry a present Intern no spine component explains — seven
  bisect blobs (order hoists, import strips, phase/frees reverts)
  isolated the PLACEMENT itself as the trigger while every local
  mechanism died to a probe (rows measured via Pure-pin printing:
  every verb arm, dispatch, the chain handlers, print_error_and_help
  all Intern-free; the parts don't sum to the whole). That is the
  12-round oscillation's attractor selection biting as semantics —
  BOTH trees bound-hit (movers: the walk_lemit family,
  driver_incremental, the judgment fns, resume_bindings,
  resolve_field_offset, mentl_edit_session, float_to_str, the dsp
  Sample/pac pair), silently until today; the movers eprint now rides
  every daily verb's stderr, loud. Hβ.infer.round-oscillation-movers
  names the dig (the residue index carries it); env.mn stays the named
  destination. GATES: mn-check-forward-order REFUSES through this
  pin's check (E_TypeMismatch at its file-local call span) and was
  measured SILENT through the prior boot — the frontier leg banks both
  faces; TRANSITION m3 == m4 at 338,467 lines (the 102,124-line m2/m3
  diff is the emit changes crossing one generation); census 0 (two
  honest widens: driver_check_module/check_entry +WASI — the
  convergence movers eprint). Known inherited finds now visible on the
  daily path, each real before today: ONE E_PurityViolated on the main
  DAG (weave 12995 — a with-Pure fn whose body allocates; solo-module
  checks stay clean, the entry-conditional class), the infer.mn:1826
  bracket's E_MissingVariable pair on lower/infer/driver entries
  (healed for the handlers this sweep homed; verify_ledger's import
  landed), and the weave-coordinate span render on DAG diagnostics
  (the named file-local-span class, now with a calibration: main.mn
  renders at +29,251 in its own check). THE SECOND WAVE, same session
  (the intermediate pin's frontier ran 303/10 and convicted both):
  (1) THE OP-VOCABULARY HOME LAW — moving effect EnvRead/EnvWrite/
  BranchEnv/Intern beside their handlers broke the DAG manifest
  (warm-start/warm-inc cold compiles refused E_MissingVariable on
  env_lookup/intern_name_of: performers across infer/lower/driver/
  cursor cannot import pipeline). An effect declares in the LOWEST
  module every performer imports — types.mn for these; the
  effect-beside-handler form holds exactly where the handler's module
  IS that floor (graph.mn for LookupTy — every performer imports
  graph, verified by census). (2) THE STRUCTURED DIAG BANK —
  diag_branch banked (line, span-line, is-error), so on the converged
  daily path (where every stmt judges through the branch bracket) a
  branch-fired T_OverDeclared reached the collectors STRUCTURE-LESS:
  `mentl tighten` printed the warning and authored nothing (the bank
  read empty), and the mcp problem-space/edit legs starved the same
  way. The bank carries (diag, line) now and the join RE-PERFORMS
  diag_report per fact into the root chain — every Diagnostic
  forwarder sees a branch report exactly as a live one, the root arm
  counts and scope-registers off the diag itself, and diag_absorb
  DELETES with both its arms (the fold reached only the one handler
  carrying the arm — the partial-forwarder disease its own comment
  had named). This also lands the file-local-span residue's banked
  prerequisite ("the banked tuple must carry the span structurally"):
  the span now rides the diag whole. (3) THE SNAPSHOT PROJECTS
  RESOLUTION — the converged passes append one env entry PER
  GENERATION per name, and env_snapshot returned the raw buffer: the
  ??-fan's vocabulary proposed the same fn THREE times (the
  sole-pure-survivor and two-survivor-tie legs red; the accept path
  refused the "tie" its own duplicates minted). env_snapshot now
  answers each name's LATEST live entry by probing the env's own O(1)
  bucket index (an entry survives iff it IS its name's latest position
  — the same edge every lookup reads), composed base-then-private for
  branch instances. The first form — a seen-list scan returning a cons
  spine — was itself convicted by the march clock (~20 minutes per
  compile leg at wheel scale: O(n²) string probes over the multiplied
  buffer at the gate's two reads + the redrive census, with every
  consumer's list_index gone O(depth)) and superseded within the
  session; the probed fan then answered `Propose: pure_seven()`, one
  survivor. The re-measure, per its own law:
  fixture-scale checks stay sub-second; the wheel-scale field read
  (`mentl src/main.mn:0`) costs 58s against the single-pass 8.5s —
  and the tax IS the oscillation (the movers keep the incremental
  cone hot through all 12 bound rounds), so the movers dig is the
  correctness root and the daily-verb perf root in one; the warm
  image and the resident session are the standing absorbers
  meanwhile. CLEAN m2 == m3 at 338,163 lines at the final pin.

- 2026-07-29 · ▶ THE AUTHORED ROW SPEAKS INSTANCES — eff_name_label
  closes its own banked follow-up (CLEAN m2 == m3 · pin 04ba90a3). The
  label that lands IN SOURCE (the tighten patch, the with-clause
  invitation) stripped every parameterized instance to its bare name —
  a proven Sample(44100) authored as Sample, a semantically WIDENED
  row that dropped the instance the proof carried. Literal-arg
  instances render in place now (SYNTAX's own canonical spelling); a
  type or node arg keeps the bare name — the sound wider-or-equal
  declaration, never an unparseable Cast(GNode) pasted into a
  signature (the render-vs-authorable seam, closed at its authoring
  face; the diagnostic voice keeps show_eff_arg's full truth).
  Frontier 318/0; census 0.
- 2026-07-29 · ▶▶ THE TUPLE INDEXES — SYNTAX §Indexing's documented
  form judges (CLEAN m2 == m3 · pin 33a60e05). The index sugar forced
  EVERY receiver to List — the census's own conviction at audit_walk
  one pin earlier — while lower always carried the tuple dispatch (its
  LFieldLoad prefix-sum). The judge's half runs now: a receiver whose
  SHALLOW root binding is a tuple (graph_chase + fold_strip — the
  first form's chase_deep_at tripped its own depth belt on the wheel's
  unconverged chains, measured at the m3 leg: a mid-judgment probe is
  never the value-boundary fold), indexed by a LITERAL, types as that
  position's element; an out-of-range literal reports EConstructorArity
  at the judgment; a runtime-variable index on a product, or a free
  receiver, takes the generic force and its honest mismatch. Named
  remainder of Hβ.infer.index-expr-dispatch: the open POSITIONAL
  demand (TRecordOpen's tuple sibling) for generic-body receivers — a
  literal-indexed tuple in a generic body destructures until it lands.
  Named seam: the judge's Cast(GNode) row render exceeds the parser's
  declared-row grammar (bare Cast is the authored spelling) — a
  proven-row report you cannot paste as a declaration. Fixture
  mn-tuple-index (the let-bound receiver, the literal form, a Float
  element) runs 42, RED on the prior boot. Frontier 318/0; census 0.
- 2026-07-29 · ▶▶ THE AUDIT READS THE BANKS — pending proofs and
  tightenings speak per fn, and the session's bare path joins the
  bracket (CLEAN m2 == m3 · pin c453d7a0). The up-to-dateness gap
  Morgan named made real: audit_project reads the two banks the
  judgment already holds — verify_debt() attributed by decl EXTENT
  (span start to the next decl's; parse_span_of is the O(1)
  spans-column read) and tightenables() by the banked fn name — so
  the per-fn audit and the frontier are two projections of one truth
  (`noisy : IO` carries its tighten line with the proven row).
  analyze_fns' chain gains tighten_collector (inside infer_context's
  thunk, where the judgment's performs reach it). THE GATE'S REFUSAL
  EN ROUTE WAS REAL: mcp_run's no-project path ran mcp_loop BARE —
  the tool arms' static rows (audit's new Verify + Tighten; query's
  ask) flowed to main, and Query had survived only through its
  stateless default while verify_ledger, stateful, refused. One
  bracket holds both paths now (the conditional moved inside; installs
  cost nothing on the empty path). The probe also caught audit_walk
  piped into str_concat_all without render_audit — report tuples eaten
  as strings, a flat_fill trap surfaced by the fixture before any
  bless (and a silent-typing seam worth naming: the tuple list met
  the String-consuming concat without a judgment refusal). Named
  residue: the kin-naming teach stays gated on its true dep — the
  reverse-bind index (naming WHICH operands share a free hole's var
  needs class members; the Why chain doesn't carry them, and a
  per-render cell scan is the span disease reborn). Frontier 315/0;
  census 0.
- 2026-07-29 · ▶ THE OPEN HOLE ASKS — an undetermined ?? renders the
  collapsing question, never the raw var (CLEAN m2 == m3 ·
  pin 69334101 — the first wording tripped the drift grep on its own
  prose, "fn (" and "return" inside the teaching string: the
  string-literal blindness firing on user-facing text, the absorption
  argument's second live demonstration). The field probe measured `?? : t10417@e19089` at `n + ??`
  — substrate vocabulary at the exact moment §1's law says the
  question beats the guess (the fan cannot enumerate an open type, so
  the missing constraint IS the answer). node_query_line gains the
  NHole arm: a still-free chased type renders the annotate-to-collapse
  invitation; a typed hole renders exactly as before, and the Why hop
  rides beneath. WITH IT (the same loop day's instrument): verify's
  MANIFEST GATE — the wheel's own ~2.5s DAG judgment of src/main.mn,
  zero-tolerance on missing names (the canon.mn class self-polices;
  detector proven both faces). Frontier 315/0; census 0. Named next
  at this render: the kin-naming teach (the free var's unification
  class knows WHICH operands share it — "tied to n through +" — the
  reason-chain read one hop deeper).
- 2026-07-29 · ▶▶▶ THE FIELD REACHES THE WHEEL — the spans spine column
  lands, and the whole-problem-space read becomes daily at wheel scale
  (CLEAN m2 == m3 · pin ffa2734a). Morgan's charge ("daily should
  include the multithreaded multi-cursor multi-shot behaviors")
  measured first: the small-field baseline is 0.35s (the sequential
  render walk is noise — the named ><-swap is refuted at daily scale
  by its own measurement), but `mentl src/main.mn:0` TRAPPED at 90s+
  — and the dig ran three shapes of ONE read to the representation:
  (1) parse_span_of rode the generic find, whose iterate FLATTENS the
  whole (span, handle) log per call — the field calls it per position,
  and alloc's wraparound guard trapped inside the flatten (the
  backtrace's own frames); (2) the allocation-free scan then measured
  O(n^2) over the snoc-spined log (600s timeout, same scale); (3) the
  resolution is the SPANS SPINE COLUMN — the paged spine's seventh
  column, dual-written at the ONE writer (graph_index_span keeps the
  ordered log for containment scans; graph_span_of is the by-handle
  O(1) read — §5.O layer 2, exactly the form the frontier landing had
  named as this read's destiny). WITH IT, the manifest law's exact
  class: canon.mn was imported by NOBODY — ty_string reachable only
  in the blob, every DAG-path judgment (check/at/field) starving for
  it since the file's birth, the blob-fed march structurally blind;
  parser.mn and infer.mn declare the import. MEASURED END STATE:
  `mentl src/main.mn:0` answers in 8.5s at exit 0 — the medium ranks
  its own main's whole problem space (0 holes, 6 pending proofs,
  2 tightenings, 115 gradient positions, each pending rendered at its
  span) in one daily command; multithreaded (the spawning judgment),
  multi-shot (the per-hole fans), multi-cursor (the ranked field) in
  one invocation. Frontier 315/0; census 0. Named residue: the field
  header renders the entry's abs spelling (the dual-spelling module
  key — one canonical key at one home is the fix) · the pending line
  renders `span_valid(...)` through the voice's argument compression
  (the fmt-summit predicate-render precedent applies) · the DAG-vs-
  blob divergence class wants its own cheap census instrument (a
  per-module manifest check the medium runs on itself; tonight's was
  found by the felt walk, five days late).
- 2026-07-29 · ▶▶ THE VERB-SHAPE TIER — audit names the |> the bindings
  draw, and the dig closes a latent double-visit class (CLEAN
  m2 == m3 · pin 0513aca1 — the pin also carries driver_check_entry's
  loud entry refusal and puts the whole arc on the daily CLI, whose
  shim now derives a mount from the path argument so every verb
  reaches paths outside the standing mounts). SYNTAX ⌖'s own law (|> is
  NEVER optional on a chain) becomes a read the medium makes about ANY
  source: pipe_shape_of (oracle.mn) walks a fn body's statement spine,
  and a let-bound name consumed EXACTLY ONCE by exactly the FOLLOWING
  statement is a |> stage written as a binding — runs of >= 2 report as
  the audit's verb-shape line, with the step count. The verb is a
  PROJECTION of use edges (the same fact own/ref grades from): a name
  used twice is <| territory and never fires; a single step is the
  law's own exception; the counting walks the ONE total child
  projection, never a text scan. THE DIG'S CONVICTION, probe-second
  (count_var_uses answered 2 for one occurrence): all three LetStmt
  mints alias the ABSENT annotation to the VALUE node (the parser's
  own no-fresh-mint sentinel — deliberate, handle-stability-motivated,
  its comment confessing the banked name Hβ.parser.let-expr-annotation)
  and stmt_child_handles listed BOTH channels — every COUNTING walk
  through an unannotated let double-visited its value subtree, masked
  until now because the existing walks (containment, the ranker) are
  boolean. The channel contributes a child only when it IS an
  annotation (the kind-read infer already makes); the Stmt decl's
  comment — which claimed LitUnit absence — is TRUED to the artifact.
  RIDES WITH IT: the fmt pre-commit rung (canonical form enters
  history — staged src/ lib/ files render canonical and re-stage;
  parse-refused files are restored, loudly; tests/ excluded because
  fixtures bank exact spans; tracked at tools/hooks/pre-commit), which
  fired on its own landing commit and immediately measured the
  trailing-marker interaction (a width-broken let strands a trailing
  drift-audit marker two lines from its literal — the severance
  vocabulary moved to its own fn with the marker weave-adjacent).
  THE TIER'S OWN FIRST RUNS then convicted two voice-truth roots, both
  landed in the same arc: (1) show_list rendered LAST-FIRST — every
  rendered list in the medium's voice was REVERSED, function params and
  tuple elements in show_type included (measured live: map's declared
  (f, xs) rendered (xs, f); the walk was last/drop_last for snoc-O(1),
  the order an accident canonized) — first-first now, and the frontier
  measured ZERO banked faces flipped; (2) severance claimed Alloc
  severable on rows visibly carrying Alloc — "Real-time safe (proven
  zero allocation)" offered on allocating fns — because row_names is a
  TOP-LINK read and a chained row hides its deeper presents; the
  reached set now reads the CHASED row, the same resolution the render
  walks (one value, both consumers). GATES: mn-audit-pipe-shape (both
  faces — the 2-step invite, the twice-used and single-step silences)
  and mn-audit-severance-honest (the allocating row refused the offer,
  the pure control keeps it), each RED on the pinned boot; frontier
  315/0; census 0. Named residue: the audit verb's abs-path invocation
  prints nothing at exit 0 (the range-cut misses; the relative form
  scopes correctly). The tier's next rungs: the MachineApplicable
  patch (tighten-style authorship of the |> rewrite — datum-position
  read required), the frontier tier (verb-shape positions ranked in
  the field), and fmt-canonical promotion once the wheel passes its
  own judge clean.
- 2026-07-29 · ▶▶▶ THE BROWSER RUNS THE SPAWNING BOOT — the Worker-spawn
  shim lands, and the page compiles through 252 real threads in 932ms
  (the runner pattern at the browser host — the browser leg of
  Hβ.ops.wasmtime-runner-migration · no re-pin, ide/ + tools only, the
  wheel untouched). Morgan's charge ("look at the thing that's blocking
  you and design it better") executed on the README paragraph that had
  dressed the blocker as a boundary: ide/mentl-ide.wasm re-derives from
  the LIVE boot (the memory import's declared min sedded 65536 → 8192;
  the host provides 16384), and ide/wheel-worker.js is the ONE execution
  host — the page and the node twin drive the same file, so the gate and
  the DOM cannot drift. TWO HOST FACTS forced the shape, each measured
  against node (which has neither; the identical blob ran there first,
  3.5s/252 tasks against a 90s browser hang): (1) all wheel execution
  lives in workers — the join's memory.atomic.wait32 is forbidden on the
  browser main thread, so the page never instantiates the module; (2)
  the dispatch channel is SHARED MEMORY, never postMessage — Chrome
  flushes a worker's outgoing messages only when the sender yields, and
  thread-spawn fires mid-wasm with the root then blocking in the join
  without ever yielding (probed through the worker's own debug channel:
  16 spawns logged, zero task starts, pool provably loaded). The landed
  form is the emscripten-pthread convergence: a pool of workers spawned
  and ARMED (module + shared memory + vfs) before _start can block,
  consuming (tid, arg) pairs from a SharedArrayBuffer ring via
  Atomics.waitAsync — the producer's qPush is stores + notify, no event
  loop anywhere on the path, and a nested fan qPushes into the same ring
  by construction. Each task instantiates FRESH over the run's memory
  (instance-per-thread, wasmtime's own convention; the constant-segment
  rewrite over the live image is the same idempotent re-init wasmtime
  performs per spawned thread). Completion rides the wheel's OWN
  task-record protocol in wasm memory — the workers' messages carry
  stdio only, so a degraded message channel can never fabricate a
  result. GATES (tools/ide-gate.sh, both legs): the node twin's four
  faces — the stub-spawn RED control (the pre-worker shim traps
  `unreachable` against this wasm: the measured reason the page had
  pinned an old wheel), compile-stdin through real tasks, the address
  CursorView (the version-skew RED healed — live wheel, live libs), the
  ?? Propose socket — and the browser leg (mentl space + headless
  chrome reading the page's ?smoke console wire): exit=0 tasks=252
  watlines=4403 ms=932, wat line-count identical to node. The pool cut
  node's blob compile 3.5s → 0.97s (252 worker boots → 12). Named
  residue: the pool BOUNDS a nested fan where wasmtime's OS threads are
  unbounded — a deeper-than-pool nested join would starve loudly under
  the run timeout, unreached by the judgment's stmt-ordered joins
  (stated at the arm role).
- 2026-07-29 · ▶▶▶ THE PROBLEM IS THE SOLUTION — every absence becomes
  a ranked frontier position (the resident-session arc's sixth rung ·
  pin 8981b63c). Morgan's principle executed at the field: absence is
  ONE node-kind, and the frontier now ranks ALL of it — holes, PENDING
  PROOF OBLIGATIONS (the verify ledger's live debt, each a position
  rendered with its predicate and Reason), TIGHTENINGS (every
  T_OverDeclared the judgment banked: the declared row, the proven
  row, the standing `mentl tighten` patch invitation), then the
  gradient tier. The error list IS the work queue. THE MOVES: the
  tighten_collector + effect Tighten moved to pipeline.mn (the one
  home main's CLI chains and mcp's session bracket both install —
  imports flow main → mcp → pipeline; the collector sits INSIDE the
  infer_context body chain, where the judgment's performs reach it —
  the outside placement measured dead); effect Verify gains
  verify_reset (both handler arms — the ledger clears debt, the SMT
  arm keeps its SAT witnesses: a counterexample is a proof, not an
  obligation); session_current performs both clears BEFORE
  re-derivation (the generation boundary's law); and the enumerators
  gained the LATEST-MINT-WINS dedup keyed on span START
  (address_better_a's tie rule as the enumerator's law — the second
  generation doubled every position, and full-span equality missed a
  reshaped decl whose extent changed; the head anchor is the
  identity). The splice floor caught once more en route: the
  tightening line rendered the fn name as a pointer numeral until the
  named-mint String pin (spec_mangle's law, tighten_line). MEASURED
  LIVE on the session: pre-edit 1 hole / 1 pending / 1 tightening /
  3 gradient; the honest edit (dropping the false `with IO`) clears
  its tightening from the NEXT frontier — 1 / 1 / 0 / 3, exactly one
  re-derivation. CLEAN m2 == m3; frontier 313/0 (the problem-space
  coproc leg RED on the pre-rung boot; both prior Field assertions
  re-banked to the four-tier line); census 0 at every step. Named
  residue: the stale-only span (a position an edit REMOVED entirely
  ghosts until the generation floor — the session-epoch face);
  pending/tightening entries rank in accrual order (the
  score_one_position rank generalizes to span-keyed entries when the
  fan lands over them). The next depth IS the fan: each frontier
  position carries its resolution — a hole its fills, a tightening
  its one proven row, a pending its missing constraint — and the
  oracle-as-search verifies candidates per position as branch cursors.
- 2026-07-29 · ▶▶▶ THE FRONTIER TELLS THE TRUTH — the ranked absence
  field becomes a faithful session read, and the discovery parse gets
  its throwaway instance (the resident-session arc's fifth rung ·
  pin 29acd4c6). The `frontier` tool joins the session: the entry's whole
  ranked field — every authored ?? first with its proven-survivor fan
  and tie-teaching, then the annotation-gradient tier — the oracle's
  frontier, the gradient's argmax uncollapsed, answered from the
  living graph (`mentl main.mn:0`'s read; act on the head, ask again,
  the session re-derives as the tree moves). THREE ROOTS made it
  true, each measured before fixed: (1) THE CARET READ THE CHASE —
  caret_span_of_handle followed the binding chain, so a hole unified
  with a call's result rendered at the CALL's site with the call's
  source as its Query (main:4:11/"width(n)" for the hole at 5:7); the
  unchased reason cell ALSO rebinds when inference resolves the node
  (the last-bind reason carried the enclosing binop's span), so the
  read landed on the SPAN INDEX written at birth (parse_span_of — the
  only never-rebound channel, the one address resolution already
  trusts; its O(n) find is bounded by the position count, the
  handle-keyed index the §5.O layer-2 form). (2) THE VIRGIN WALK —
  enumerate_gradient_positions asked teach_gradient about every cell
  in range(0, next), and junk suggestions entered the field under
  garbage coordinates (prelude prose as the entry's own line 1 — the
  C1c-era enumerator residue, closed by the chased-kind decl gate it
  named). (3) THE DISCOVERY GENERATION — the birth-span read exposed
  what the chased read had hidden by accident: driver_extract_imports
  full-parses every module for its import heads, minting a SECOND
  complete AST into the live graph, and wherever file-local
  coordinates coincide with the weave range (every 1-module world)
  the duplicate generation's holes entered the enumerators — each
  authored ?? counted twice, once judged and once as a free ghost
  (?? : t18@e0), and the ??-authoring edit workflows focused the
  ghost (FIFTEEN frontier legs red at once: the field count, the
  positive-hole and capability-hole sessions, the tie leg). The
  discovery parse now runs in a THROWAWAY graph instance
  (~> graph_handler with the empty config — the C1c branch-cursor
  machinery as isolation; the import names flow out as heap strings,
  only graph cells die), the accident named a contract at its writer.
  Widen rounds: the discovery family's rows carry the parse's honest
  Diagnostic + Mutate + Cast + WASI (the judge's Cast(GNode) payload
  render taught the bare-name declaration spelling en route), plus
  hole_gate/authored_hole to the span-index read. CLEAN m2 == m3;
  frontier 312/0 (the frontier-read leg RED on the pre-rung boot:
  wrong address, wrong Query, 7 ghost positions; the cursor-address
  field leg healed to its banked faces); census 0. The session
  surface: propose + query + at + frontier + audit + teach. Named
  residue: Hβ.parser.comment-attach-module-boundary (the last lib's
  tail comment attaches forward across the module seam to the entry's
  first decl — width's Lede rendered kernel prose; the weave attach
  should stop at NModule boundaries).
- 2026-07-29 · ▶▶▶▶ THE SEQUENCE-OF-STRUCT LEAVES AND THE FOLD
  BOUNDARY — structural ==/hash/ordering become true over lists of
  structs, and the fold family resolves its types once at entry
  (Hβ.emit.seq-struct-eq-leaf RESOLVED · pin b214afba). THE CLASS,
  measured three ways on the prior boot: [(1,2,3)] == [(1,2,3)]
  answered FALSE — the eq/cmp/hash sequence arms floored every
  STRUCTURAL element (product, sum, nested list, computed string —
  literal interning masked the [String] face) to the word runtime
  fns' per-element compare, pointer identity standing in for
  structure at BOTH altitudes (top-level and field); top-level
  hash of ANY list was an undefined-$hash_l<sig> ASSEMBLY BREAK
  (emit_hash's unconditional agg routing demanded a leaf the
  collector never contributed); list-of-struct ordering compared
  pointers (garbage sort). THE WALKERS: $eq/$compare/$hash_l<sig>
  generated when the element face is structural
  (seq_face_structural) — the show family's recursive listbody
  shape, elements through $list_index (representation-total), the
  element leaf selected by face (seq_elem_leaf_callee — runtime
  names as values, never a mode key); the eq walker mirrors
  list_eq's identity+length protocol, the 3-way walker
  list_compare_loop's elementwise-first-difference, the FNV walker
  list_hash's exact seed with each element's OWN hash in the mix
  (eq ⇒ hash, the agreement preserved). THE FOLD BOUNDARY (Morgan's
  cut — "design the most elegant and powerful solution" — after a
  45-site fold_sig wrapper sweep was built and REVERTED as the
  N-reader patch): chase_deep runs ONCE where a type ENTERS the
  family — the two binop dispatch entries, show_hash_ty, and the
  three operand contribs — and sigs, dedup, generation, field
  dispatch, and walker callees all read a var-free type BY
  INVARIANT. The collision the boundary dissolves was MEASURED: two
  TList(TVar) sites with different bindings fold_sig'd to one raw
  "li", shared one walker, and the second site's elements walked
  the wrong protocol (trapped in list_eq_loop); the boundary also
  heals the show family's same latent collision for free.
  hash_node_of's float-list route joins the field twin
  (list_hash_f64 — the top-level/field hash route split closed).
  manifest_same DISSOLVED back into == (the workaround's written
  destiny, one landing later — the census law's clock never reached
  two): the living session's manifest compare is the walkers' first
  wheel-internal consumer, proven in production by the living leg.
  TRANSITION m3 == m4 (the 476-line m2/m3 diff is the walkers
  crossing one generation); frontier 311/0 (mn-list-tuple-eq +
  mn-list-tuple-fold registered, RTLIBS-linked, both RED-measured
  on the pre-leaf boot); census 0 after ONE honest widen round
  (20 entry fns gain chase_deep's row); micros green through
  verify. Named residue: the show family's sig discipline now
  rides the same boundary but its list walker predates it — a
  probe-pass over show's per-face renders under the boundary is
  the audit single.
- 2026-07-29 · ▶▶▶ THE SESSION GRAPH GOES LIVING — the resident graph
  tracks the tree, and the staleness check is a pure read (the
  resident-session arc's fourth rung · pin 3973fd21). Before every
  message the loop compares the tree's manifest against the banked one
  and a moved tree re-derives INTO the resident world — never a
  restore (the swap-crossing law's third constraint executed): the new
  generation shadows by the env's latest edge (the B-i incremental
  law), ranges and the scoped entry ast replace, and the message's
  region stays unreclaimed (moved ⇒ no reset — the fresh generation
  was minted after the mark; the fork-spine law at the serve loop).
  driver_manifest is a PROJECTION off the range map the derivation
  already minted: per woven path, (path hash, byte length, content
  hash) word triples — no discovery, no parse, no graph write, and
  coverage is complete over the banked set (an edit, a deletion, and
  a new import all move some banked triple; the one hole — a
  reported-missing module later created — is named at the decl). The
  living check crosses into the loop AS A VALUE (the at_read
  precedent: session_current on the resident path, the Pure identity
  on the no-project path), after the gate refused the first form's
  derivation row at the bare root — the loop is row-polymorphic.
  MEASURED: exactly one re-derivation per edit; post-edit reads answer
  the new truth — query resolves the new fn at its span, audit lists
  it, and the at reaches a line that did not exist before the edit
  (the range map replaced; the answer byte-matches the CLI at the
  same address). The pinned-boot RED: moved=0, the new fn absent from
  every face — the startup snapshot answering stale. TWO WHEEL FINDS
  en route, each probe-convicted before fixed: (1) the first check
  form re-ran collect_dag per message — the discovery parse MINTED
  into the live graph, and a resettable message's region reclaim
  killed that spine growth under later reads (the fork-spine class,
  measured twice: spine_comment_at's list_index trap on the next
  check; address_case_a walking a reset span-index buffer); the pure
  read makes the class unconstructible. (2) Structural == over a
  sequence of PRODUCTS floors to $list_eq's per-element word compare
  — pointer identity as equality, the exact silent fallback the eq
  law forbids, at BOTH altitudes (emit_eq_for_ty's and
  emit_field_eq's TList arms; measured: byte-identical manifests
  answered unequal, and [(1,2,3)] == [(1,2,3)] runs 7 through the DAG
  judge). Named Hβ.emit.seq-struct-eq-leaf with its banked fixture
  (tests/frontier/mn-list-tuple-eq.mn, both faces): the fix is the
  generated sequence-of-struct leaf (length + elementwise walk
  calling the element's own eq family, demanded transitively), with
  the hash/compare/show siblings audited for the same arm;
  manifest_same is the class's FIRST named workaround (a second is
  the stop). CLEAN m2 == m3; frontier 305/0 (the living leg: fifo
  coprocess, the file edited between messages); census 0. The session
  is now the full loop an agent needs: propose + five living reads
  over a graph that tracks the tree.
- 2026-07-29 · ▶▶ AUDIT AND TEACH JOIN THE SESSION — the analysis verbs
  become resident reads, and the verb pair collapses to one composed
  projection (the resident-session arc's third rung · pin 1c2e53fa).
  analyze_fns's (project, render) pair FUSED into one
  `projection(ast) -> String` per verb — audit_project / teach_project,
  the pure homes the CLI verb and the session tool BOTH call (the
  address_project law at the analysis verbs; transport stays the
  caller's: analyze_fns prints, the session returns the text as the
  tool result — no Console sweep needed here because the projections
  were already value-shaped, one transport site each). THE SCOPING READ:
  the session holds the full weave ast while the CLI's audit parses the
  entry alone — driver_module_ast cuts the entry's top-level nodes by
  its weave range at session start (homed beside range_of_module; the
  NModule mint computes this same filter and holds it as decls but
  discards the minted handle — the handle-kept read is the named O(1)
  form), so the session's audit/teach answer exactly the CLI's scope,
  never the prelude/lib flood. The gate's tripwire asserts the ABSENCE
  of a prelude fn in the audit face (the retraction law: assert
  absence, not only presence). Measured: the session's audit answers
  the CLI's byte-same four lines; teach speaks each fn's next
  annotation ("add with !Alloc to unlock Real-time safe"); query still
  answers afterward in one conversation. The session surface is
  propose + query + at + audit + teach — five tools, one derivation.
  CLEAN m2 == m3; frontier 304/0; census 0 on first compile (every row
  inferred — the projection pair's rows flow through HM, zero widens).
  Remaining rungs: the oracle-as-search (the fan from ?? candidates to
  hypotheses over the resident frontier) · work-stealing-via-gradient
  as the session's scheduler.
- 2026-07-29 · ▶▶ THE ADDRESS JOINS THE SESSION — the eight-aspect
  projection becomes a resident read, and the voice's transport becomes
  an install (the resident-session arc's second rung · pin 4d1bf583).
  The address render family (render_at, render_field, the field tier,
  the Why hops — ~20 sites) spoke print_string DIRECTLY: the transport
  baked into the narration, the violation io.mn's Console effect exists
  to prevent. The family performs Console's `print` now — WHERE it
  lands is the install: at_run adds stdout_console (the CLI unchanged
  byte-for-byte at its legs), and the session's new `at` tool runs THE
  SAME core under console_bank (the collecting console, drained per
  call) and returns the banked lines as the tool text. TWO structural
  moves rode along: address_project extracted as the ONE address home
  (at_run's inline block, verbatim — CLI and session cannot drift),
  and the transport crossed the import boundary AS A VALUE
  (session_at_read builds in main.mn where the renders live, passes
  into mcp_run as a stored fn carrying its row — the effect-poly ctor
  capability exercised at the architecture layer; imports flow
  main → mcp, never back). Measured: at {line:3, col:4} in the
  resident conversation answers the byte-same projection the CLI
  serves at main.mn:3:4 — Query, Why, the fan at a hole — beside query
  and propose, one derivation. The session surface is now propose +
  query + at; `why` rides query's own grammar. CLEAN m2 == m3;
  frontier 304/0 (the session leg asserts the at face); proof-
  exactness 9/9; crown 5/5; census 0. Next rungs named: audit as a
  session read (analyze_fns speaks Console the same way) · the
  oracle-as-search (the fan from ?? candidates to hypotheses over the
  resident frontier) · work-stealing-via-gradient as the scheduler.
- 2026-07-29 · ▶▶▶ THE SESSION GOES RESIDENT — the mcp serve loop holds
  the living graph and queries answer as reads (the resident-session
  arc's first rung · pin 65934277). The refutation's constraints
  cashed straight into the correct form: mcp_run derives the project
  ONCE (resolution-conditional, the prelude-seed precedent) inside one
  analysis bracket that ENCLOSES THE WHOLE SERVE LOOP — the session's
  instances live for the server's life, no swap exists anywhere, the
  image IS the session's memory (all three Hβ.session.resident-verbs
  constraints hold by construction, not by discipline). THE NESTING IS
  THE ISOLATION: a propose's own infer_context installs fresh
  innermost instances that shadow the session's (the world law), and
  its millions of judgment mints land in spine pages allocated inside
  the request REGION — the reset kills them with the instance while
  the session's spine lives below every mark. A session READ inverts
  the region law deliberately (the resettable bit threads the
  dispatch): its answer printed, its small mints (a question's parse
  nodes) kept as durable session growth — a reset would orphan spine
  pages later reads still chase (the fork-spine class held off at the
  serve loop). The `query` tool joins `propose`: ask(parse_query_
  string(q)) against the LIVE env/graph, schemes with Reasons as the
  teaching payload. MEASURED: five messages — initialize, tools/list,
  two queries, a propose — in 0.7s wall, the resident line printing
  ONCE, both schemes answered live, PROVEN after the reads; the prior
  cost was 3.8s for a SINGLE cold query. The frontier leg drives the
  whole conversation and asserts each face (RED on the pre-session
  boot: tools/list served propose alone). Named residue: query
  Reasons render weave spans on this channel (the file-local-span
  class's session face) · the at/audit/why tools (the session's next
  reads) · the oracle-as-search over the resident frontier (the fan
  generalizing from ?? candidates to hypotheses) · work-stealing-via-
  gradient as the session's scheduler. CLEAN m2 == m3; frontier 304/0;
  proof-exactness 9/9; crown 5/5; census 0.
- 2026-07-29 · ▶▶ THE SWAP-CROSSING LAW CONVICTS THE WARM VERBS — a
  measured refutation banked whole, and the fmt string-atomicity
  defect caught by its one witness (· pin 6eb1b61c). Morgan's charge
  ("don't tell me you're inefficient and continue being inefficient")
  opened the resident-session arc at its nearest rung: the B-i warm
  image wired into the projection verbs (at/query/tighten/edit/check)
  through one home (driver_entry_warm — probe by a key sidecar BEFORE
  any restore, exact-tree only; the sidecar's own splice-pin bug found
  by its bytes: module names rendered as per-run pointer numerals, a
  key that never matched itself). The exact-tree face MEASURED TRUE:
  cold == warm BYTE-IDENTICAL at the at-address projection, the
  restore serving in the wasmtime-JIT-floor time (and the first 7.8×
  claim died as the JIT-cache confound — counted). THEN THE FRONTIER
  REFUTED THE FORM at the session faces (16 red): a mid-verb
  image_resume kills EVERY pre-swap heap value — the caller's own argv
  strings (at_run's target rendering EMPTY in its own error message),
  the chain's own handler records (the edit legs' 134s) — and works
  only where deterministic allocation makes two processes' worlds
  coincide byte-for-byte: forensic law 5, the accident never
  canonized. The machinery DELETED whole (drift-9 — the knowledge
  lives here, not in dead code); the verbs derive fresh; the yield is
  Hβ.session.resident-verbs with the resident session's MEASURED
  constraints: (1) no mid-chain swap, ever; (2) per-invocation strings
  cannot cross a swap; (3) the image must be the session's OWN memory
  (one long-lived process — the mcp serve loop is the natural host —
  holding the analyzed graph, every verb a read, no restore). The
  march-practice ruling re-affirmed en route (229fda2f's own words):
  the whole-world ladder is the AUDIT tier, not the inner loop.
  RIDER, the fmt defect its one witness caught: the canonical pass had
  reflowed space_respond's header string ACROSS RAW NEWLINES — the
  serve answered a bare status line (raw newline + \n = end of
  headers), invisible to the march (Law-7-invisible: the wheel never
  calls its own serve), RED only at the frontier's serve leg. The
  literal restored one-line; the renderer defect named
  (Hβ.format.string-literal-atomic-layout — a string literal is
  CONTENT; the width engine treats it as atomic, never reflowing
  inside the quotes; the whole-tree census found exactly the one
  site). CLEAN m2 == m3; frontier 303/0; proof-exactness 9/9; crown
  5/5; census 0.
- 2026-07-29 · ▶▶▶▶▶ THE MASKS RIDE THE CHASE — the wheel passes its own
  root-row gate, and five Carried-Truth roots fall in one continuous
  dig (· pin 0ab5d903). THE OPENING MOVE was the gate itself: the
  escaped-install witness ran its arm with a dead chain (exit 7, clean
  compile), and the criterion's conjuncts were interrogated to their
  tiers. The experimentally-sharpened gate refused the WHEEL (GraphRead
  + Intern at main's root), and nine theories died to probes before the
  graph named its own writers: (1) THE CHASE KILLED EVERY MASK —
  chase_node's NRowBound arm destructured `EfRow(names, _, EtVar)`,
  DISCARDING each level's absent set at the one mechanism every row
  read routes through; merge_chased_row/merge_row now fold under the
  reading law (presents filter through accumulated masks; the EtAll
  special case dissolves into the uniform arm) — measured RED→GREEN as
  main's row carrying twenty-one riding masks for the first time.
  (2) THE WRITE GUARDS PERFORMED OPS FROM THEIR ARMS — occurs_in
  chased whatever instance the OUTER chain held (the wrong-instance
  class at the guard itself) and charged GraphRead into
  graph_handler's residual past every bracket; the occurs family is
  STATE-PASSED now (mechanism layer, beside chase_node), with
  occurs_in_live the one op-based face for bracketed pre-checks.
  (3) THE FRAGX CENSUS SPOKE THE VOICE from the bind arm
  (show_reason = GraphRead + Intern in the residual — the exact face
  measured on infer_context); it speaks SPANS now, pure projections.
  (4) THE RENDER MOVED TO THE REPORT BOUNDARY — report is a plain fn
  rendering diag_line in the REPORTER's world and performing
  diag_report(kind, line); every arm (root, quiet, branch, tighten,
  mcp) receives the line made and never renders — the diagnostics/
  graph arm-dependency cycle the install order could only half-satisfy
  dissolves, and Hβ.diag.render-chases-wrong-instance is
  unconstructible at those arms. (5) THE FREEZE RE-DERIVES ITS
  QUANTIFIER — branch_replay_one folded the type (chase_deep) while
  keeping PRE-fold qvars, so folded leaves fell outside the
  instantiation mapping and every caller SHARED the terminal (the
  union-pool: infer_context's two-era duplicated qvars, measured);
  Forall(free_in_ty(fty), fty) for generalized schemes, empty-q mono
  shares preserved. RIDERS, each its own truth: ef_make keeps
  coexisting present/absent (the reading law makes the pair COHERENT —
  present adds now, absent filters the tail; the authored `with A + !A`
  meet moved to build_declared_row, its one decl-site home);
  chase_row_deep + subst_row_build fold with the same filter;
  fp_row fingerprints the RESOLUTION (bound-content blindness closed);
  persist_to_disk's arm writes the wire DIRECTLY through persist_write
  (an arm re-performing its own op resolves OUTER — the residual
  honestly carried Persist and refused every fixture whose only
  handler was that install: the R2 law catching the library's own
  forwarder); fourteen honest row widens. THE GATE SETTLED AT THREE
  TIERS, the backtrack acid pair arbitrating (both refuse under any
  stricter form — their per-candidate dynamic installs are the
  legitimate face the row cannot see): EVIDENCE-floor demands STRICT
  (a dead-chain perform walks garbage evidence, NO belt — the one
  sharpening that stands, install-anywhere clears nothing); STATEFUL
  singletons clear on an install (SingletonUninstalled the loud belt —
  mn-singleton-preinstall-call holds that tier at 134); STATELESS
  singletons ground by the measured value-sound licence (the arm
  ignores __state — the escaped arm answers its honest 7). TWO
  TRIPWIRES pin today's semantics for the modal install-identity
  frontier to consciously flip: mn-effect-escaped-install (exit 7 —
  the dead-extent escape the licence admits) beside
  mn-effect-residual-absence (42 — residual !E). One fixture arity
  trued en route (backtrack-full's `abort() -> Option` — the
  bare-parameterized class in the acid test's own decl, convicted by
  the sharper judge). THE LADDER: TRANSITION m3 == m4 at the
  occurs/chase crossing (96,106-line m2/m3 diff — the whole arc's
  emit crossing one generation), then CLEAN m2 == m3 three times as
  the persist policy, the fmt-canonical pass, and the three-tier gate
  landed. Board whole at the pin: micros whole (the backtrack acid
  pair healed); proof-exactness 9/9; crown 5/5; census 0; the touched
  set fmt-canonical. Counted kills, each one probe: the
  statement-position theory, the lambda-thunk and inner-tee theories,
  the residual-wash theory, the chain-bisection triple (p1/p2/p3
  identical — the conviction that moved the dig off infer_context),
  the loose-prereg-alone theory, the fingerprint-alone theory, the
  ef_make-alone theory, the shell's own `exit=$?` reading a grep.
  Named residue: Hβ.infer.arm-op-residual-census (the uniform audit
  this landing did by hand — every handler arm performing ops outside
  its own state is a residual carrier; the census instrument is the
  medium's own row read per arm) · the a=[Pure] absent-entry render
  seen mid-dig (an EPure in an absent set — benign or a mint oddity,
  one probe when next in the row layer).
- 2026-07-28 · ▶▶▶ THE ARGUMENT EDGE RUNS SUBSUMPTION — and the persist
  barrier lands on the op whose contract is re-execution (Arc 3's
  external-effect resume barrier, first face · pin 7c91063c). The
  banked next single executed: unify_row_canonical's two Closed~EtAll
  arms judge by row_subsumes — pass, no bind, the negation row a GATE,
  never an equand — where the old equality arm falsely refused EVERY
  closed-row argument against a neg-row param (a Pure thunk "failed"
  the universe-minus row it plainly satisfies; the b3 probe banked the
  RED). ON that edge, the barrier: persist_branch's param row is
  `() -> a with !WASI + !Filesystem + !Network` — a crashed branch
  RE-RUNS its thunk (the SPACE=TIME fork, §4④), so the row severs what
  a replay cannot un-send (the image restore rolls back Alloc/Memory;
  it cannot un-send a packet), and ordinary row checking at the
  argument edge is the WHOLE gate — the typed form of the invariant
  the durable-execution field re-derives at runtime by journal-diffing.
  THE AUDIT REDIRECTED THE BARRIER to its true home: persist(Int,
  String) stays word-rooted — a DATA root (the warm compile's asts,
  driver.mn) replays nothing, so it carries no gate; the op that
  replays is the op that severs. GATES, the RED matrix measured on the
  prior boot: persist-branch-clean healed 1 false mismatch → 0 AND
  runs the whole checkpoint+run+join loop (42); hof-row-gate healed
  2 → exactly 1 (the quiet thunk admits, the noisy edge alone
  reports); persist-branch-external names the severed triple at the
  lambda's own span ("WASI + Alloc + Memory + t… vs !Network +
  !Filesystem + !WASI"). One dead label counted en route: the external
  face's first zero-mismatch was a phantom `print` (E_MissingVariable
  starves the row; the fixture's callee is println). CLEAN m2 == m3 at
  327,391 lines — no wheel site ever depended on the false mismatches,
  and the arm's EtAll-tailed thunk() row rides the wheel's own
  persist_to_disk through census 0. Named residue:
  Hβ.effects.directional-fn-row-edge (the meet is direction-blind —
  both orientations subsume; the contravariant-precise call edge is
  the sequel) · Hβ.lower.persist-schedule-branch-row-gate (the fanout
  lowering's synthesized persist_branch dispatch is post-inference —
  a persisted `><` branch's row rides the enclosing inference,
  visible but not yet refused at the persist boundary; the refusal
  lands when schedule resolution moves to infer).
- 2026-07-28 · ▶▶ THE FN TYPE SPEAKS ITS ROW — the resume barrier's
  vocabulary parses, and the signed-clause fold finds one home
  (pin 8471a255). The barrier design collapsed into VOCABULARY the
  moment the persist surface was audited: persist takes a word
  (addr(thunk)) so no per-op gate can type it — but a Persist op
  declared `persist(k: () -> a with !WASI + !Network + !Filesystem,
  path)` makes ORDINARY row checking at the argument edge the whole
  barrier, zero new machinery (the row proves what Temporal diffs at
  replay). The DEP was foundational lathe-lag: TFun's row was
  render-only — `() -> Int with !WASI` parsed NOWHERE (a param
  annotation split the decl; a type alias refused at the `with`).
  Landed: parse_type_ty's arrow arm gains the optional `with <row>`
  (greedy-inner in return position — parenthesize for the outer
  clause), the row built by build_declared_row, which MOVED to
  effects.mn with its kin (is_pure_eff_name / apply_connective /
  has_pure_declared — pure algebra over the parsed triples, ONE home
  for infer's declared rows and the parser's type rows; the parser's
  silent mk_ef_open dependence became a declared import). MEASURED
  LIVE (the b3 probe): `accept_thunk(f: () -> Int with !WASI)` REFUSES
  a WASI-performing thunk argument — E_EffectMismatch "WASI + Alloc +
  Memory vs !WASI" at the call — the barrier firing through the
  existing crown. The named next single, its RED banked:
  Hβ.effects.hof-row-subsumption-at-call — the arg edge runs UNIFY's
  equality, so a rigid Pure arg falsely refuses against the neg param
  ("Pure vs !WASI") while row_subsumes itself reads Pure ⊆ !WASI
  correctly; the call's arg-to-param edge must run SUBSUMPTION for
  fn-typed params (contravariant at the one directional edge — the
  general unify stays symmetric). With it lands the Persist op's
  declared row (the barrier proper) and its two crucibles: the
  absorbed-thunk persist admitted, the raw-external persist teaching
  the absorb-or-own-replay move. Dynamic Wind (OOPSLA 2025) stays the
  bracket-semantics read for the resume side. CLEAN m2 == m3;
  census 0.
- 2026-07-28 · ▶▶ THE INSTANCE JUDGES ITS ARGS — the signature check
  lands, and the prior entry's parse claim corrects in place
  (pin 2eb7cee5). RETRACTION (the ⟲ law, the probe's own find): the
  previous entry's "the decl head parses" was RECOVERY — the
  crucibles' stderr carried six P_ tokens each (`rate: Int` refused at
  the colon: parse_config_params took bare names, the 2026-07-24
  measured handler-config lathe-lag), the params never reached the
  TParam list, and the E_EffectMismatch assertions passed because the
  negation law needs no params; the frontier legs grepped mismatches
  only, blind to the P_ narration. The head TRULY parses now:
  parse_config_params gains parse_one_param's exact `: Ty` annotation
  arm — ONE fix, BOTH lathe-lags (the annotated handler config
  `scaler(f: Int)` heals with the effect head), zero P_ tokens on
  every instance fixture. THE JUDGE: check_instance_args runs at the
  declared-row site (the span in hand) — each authored instance
  resolves the effect's registered TTuple scheme by kind
  (EffectDeclKind, the effect_instance_arity read's own shape); arity
  disagreement reports EConstructorArity, a scalar-literal arg whose
  ground type disagrees reports ETypeMismatch (same_ground over
  fold_strip — alias/refined params compare at their ground), and
  type/node args pass to the instance-unification flow (the modal
  frontier's face). Measured: Sample("hi") vs rate: Int = one
  mismatch; Sample(48000, 2) = one arity; the sibling crucible stays
  clean and runs 42. Two frontier legs pin it (argty asserts the head
  parses P_-free too — the leg the retraction teaches: assert the
  ABSENCE of narration, not only the presence of the report). CLEAN
  m2 == m3; census 0.
- 2026-07-28 · ▶▶▶ THE NEGATION HOLDS ITS INSTANCE — Arc 3's first
  landing: the parameterized decl parses and !E(instance) becomes
  precise (Hβ.effects.parameterized-negation-instance's core ·
  pin 9f4ebef2). The felt walk's DEP first: `effect Sample(rate: Int)`
  parses (ten P_ tokens on the prior boot — SYNTAX's canonical form was
  lathe-lag), the params riding the same [TParam] product fn params and
  handler config ride (EffectDeclStmt widened, seventeen destructure
  sites swept), and registering as the effect's env SCHEME — TTuple of
  the params' types, the instance signature, where a placeholder empty
  tuple had sat since the entry's birth. THE INSTANCE LAW is ONE
  predicate (eff_forbids, SYNTAX's own equality: name AND argument
  value): a bare !E severs every instance and the bare name;
  !E(args) blocks the bare name (a bare occurrence could be any
  instance — conservative) and any instance not PROVABLY distinct,
  where provable distinctness is scalar literals (Int/Float/String)
  with unequal values at a shared position — type and node args never
  prove it. BOTH crown faces read it: subsumption's forbidden-
  membership (name_in_forbidden carries whole EffName entries now, not
  bare handles), and ef_make's absent-minus-present through its OWN
  pair law (absent_contradicted_by): the probe caught the first form
  over-eager — a BARE present beside an INSTANCE absent is a
  REFINEMENT ("any Sample except 44100"), not a contradiction, so the
  absent survives; only same-identity pairs and an instance-present
  under a bare-absent contradict and drop. THE MEASURED BEFORE: the
  by-name dedup DELETED a declared !Sample(44100) the moment
  Sample(48000) was present — the severance silently vanishing at row
  construction (the felt walk's inst2 checked clean for the wrong
  reason). Three frontier crucibles, each corner: the provably-distinct
  sibling ADMITTED and running 42 (a Sample(48000) callee under
  Sample(48000) + !Sample(44100)); the same instance SEVERED
  (E_EffectMismatch, one report); the bare perform BLOCKED
  conservatively. CLEAN m2 == m3; census 0. The named remainder:
  instance-arg TYPING against the registered signature (a
  with-clause's Sample("hi") vs rate: Int — the scheme is registered,
  the judge's check is the next single), and instance flow into op
  rows (a body's bare tick() under a declared instance stays bare — the
  admit-through-instantiation face, the modal frontier's dep).
- 2026-07-28 · ▶▶ THE ENCLOSING DECL DESCENDS THE TREE — containment
  becomes a structural read (the ranker landing's named next single;
  Hβ.cursor.enclosing-decl-edge's walk half · pin 93be5c52). Spans
  cannot resolve containment (decl and body parse spans are
  head-anchored — a three-line body's span measured two columns), so
  the vocabulary's nontermination guard was DEAD for every multi-line
  body: a hole inside banner proposed banner() and main(). The
  child-handle projection is TOTAL now — expr_child_handles gains the
  match-arm bodies it dropped, stmt_child_handles is its new Stmt
  sibling (let values, fn bodies, expr stmts, handler state inits and
  arm bodies; type-level carriers contribute none), and
  body_child_handles is the ONE dispatch over NodeBody every tree walk
  reads. enclosing_fn_decl_at descends the tree
  (node_contains_handle — the hole a descendant of the decl's body
  node), nesting resolved structurally (a candidate whose own stmt
  node sits inside the standing best's body is the inner fn and wins);
  cursor declares its oracle import (the manifest law — the blob
  census is blind to a missing import the DAG path refuses). Measured
  on the ranker fixture: 7 survivors → 5, banner() and main() both
  excluded, width() still first; the frontier leg pins the exclusion
  (RED on the span-blind boot — both leaked). The O(1) form (the
  decl-containment edge minted at parse) remains the peer's edge half.
  CLEAN m2 == m3; census 0.
- 2026-07-28 · ▶▶ THE SHOW FLOOR CLOSES TO ZERO — the 44-marker census
  swept whole (the splice landing's own residue · pin 09bfedc2). The
  liveness triage ran mechanically on the artifact (floor calls vs twin
  calls vs self-recursion; nine floors externally live, the rest dead
  twin-served copies), and every splice-only param in the wheel now
  carries its true type as an Intent Boundary: seventeen decl pins
  across nine files (driver_module_path had already paid the class's
  loudest bill — the zero manifest), two element-shape pins
  (render_effect_ops' op rows, render_state_updates' update records),
  and three named-mint hoists where the datum-last lambda judgment
  leaves the binder free past any list pin — render_gradient_line's
  proven pattern applied at audit_report_lines (the audit verb's per-fn
  header rendered fn names as pointer numerals), consume_twice_msg,
  and parallel_collision_msg (the affine ledger's two diagnostics named
  their consumed binding as a numeral). The last marker named a JUDGE
  gap, Hβ.infer.arm-binder-op-param-type — NARROWED BY PROBE
  (2026-07-30): an ordinary declared-param arm binder IS bound (a
  `log(msg: String)` arm's `msg + 1` refuses E_TypeMismatch, measured
  through the current judge — bind_arm_args reads the op's
  instantiated params), so the general claim is retracted; the
  residual is the `other =>` skip in infer_one_handler_arm (an op
  whose scheme is not TFun-shaped skips bind_arm_args and its binders
  judge free — the Consume-era witness's likely route, its one site
  pinned). The CLASS-KILLER stays banked on
  Hβ.emit.show-free-floor in its constructive form: flow-directed
  demand (Lutze–Schuster–Brachthäuser, "The Simple Essence of
  Monomorphization", OOPSLA 2025 — instantiation flow tracked through
  type variables, higher-rank included, cyclic flow the uniform
  refusal); the union-find already holds the flow — the twin demand
  analysis learns to read its CLOSURE instead of per-site reference
  projections, which is exactly the HOF boundary where every damaged
  site tonight lived. Frontier recon riders banked the same sweep: the
  durable-execution industry's whole convergence (journal + replay +
  refuse-on-divergence, Temporal/Restate, all runtime) is the untyped
  form of Arc 3's resume barrier — the row proves what they diff; and
  Dynamic Wind for Effect Handlers (OOPSLA 2025) is the formal
  treatment to read the world save/restore brackets against before the
  TCont value gate. CLEAN m2 == m3; census 0; show-floor markers
  44 → 0.
- 2026-07-28 · ▶▶▶▶ THE SPLICE TELLS THE TRUTH — four roots under one
  law, and the canonical page lands (the fmt summit closes ·
  pin a971601e). The whole-wheel sweep's red legs reduced to FOUR
  Carried-Truth violations at four layers, each measured before fixed:
  (1) THE FORMATTER BORROWED THE VOICE at the predicate — RefineStmt/
  TRefined rendered through show_predicate, whose call arm compresses
  arguments to `(...)` (diagnostic economy), and the canonical page
  DESTROYED authored refinements (`len(self)` → `len(...)`, a parse
  break the render register then scoped out of the user's stderr — the
  fmt-rung-2 disease one projection over). render_predicate_tokens is
  the formatter's own parse-inverse projection: operands are node
  HANDLES read live through render_body_tokens, the cmp glyph is
  binop_to_str (total — never show_cmp_op's `?` floor), precedence-
  inverse grouping at the predicate altitude; and the VOICE's shadowing
  `(...)` arm DELETED — show_pred_operand carried two CallExpr arms
  since 10b79aa8, the compressor above shadowing the args-rendering arm
  below, dead since birth. (2) THE LINE RIDES EVERY SCAN RETURN — the
  string scanner's splice-termination and every chunk flush returned
  (pos, col, buf, count) with NO line, so every token after a splice
  spanning newlines carried spans stale by the splice's height: the
  whole-weave address collapse (nodes lying about their lines resolve
  to nothing but the module placeholder — the fan legs' red), the
  register's silent mute (the P_ narration landed outside the user's
  range), and warm-inc's span-keyed cone misattribution (the
  incremental emission carrying the patch's OLD constant) were ONE
  dropped tuple field, found by splice-bisecting the 51-file sweep to
  one decl and that decl to one rendered spelling. Every scan return
  widened to carry the live line; the chunk scan counts raw newlines
  (Hβ.lexer.string-newline-refusal named for the single-line form's
  refusal question). (3) A SPLICE KEEPS ITS OWN TYPE —
  unify_string_fragments bound EVERY fragment to String (the
  pre-structural-show era's rule, contradicting SYNTAX's own law);
  deleted whole, and lower wraps each splice fragment in the structural
  LShow (the implicit to_string, dispatched at emit from the operand's
  live type — String rides the identity arm). Hβ.emit.int-splice-empty
  CLOSED at both halves: "I{7}J" rendered empty in EVERY user program
  ever (str_concat read the raw word as a null-page string) while the
  wheel dodged by spelling int_to_str at every one of its own splices.
  (4) THE UNMASKING — with fragments no longer forced String, a param
  used ONLY in a splice generalizes, and the word-floor copy shows a
  String operand as a pointer numeral: spec_mangle minted garbage twin
  names and the redrive liveness probe (an HOF lambda the twin
  machinery cannot serve) dropped the def while installs kept the
  calls — m3 emitted 16 redrive references and no definition, the
  march's BROKEN verdict catching internally-inconsistent output
  (332 → 18 → 0 diff lines across the three pins of the dig).
  spec_mangle and the new one-home arm_fn_name pin String (Intent
  Boundaries, load-bearing); the show floor writes its census marker
  (`;; show on unresolved operand` — 52 on the wheel;
  Hβ.emit.show-free-floor carries the triage: a firing site is a
  generic the twins did not serve). THE CANONICAL PAGE: 51/51 files
  rendered canonical with prose conserved, TREE-IDEMPOTENT at two
  consecutive whole-wheel sweeps; the refinements survive verbatim
  modulo comparison canonicalization (authored `len(self) > 0` renders
  `0 < len(self)`, stable on reparse). GATES seen RED on the prior
  boot: mn-int-splice (15 → 42; the four splice faces incl. the
  multi-line nested-string call) and mn-splice-line-carry (module
  placeholder → the decl resolves). THE INTERMEDIATE PIN'S OWN GATES
  then convicted the floor LIVE in the driver — driver_module_path's
  floor'd splices minted pointer-numeral paths, fs_exists refused every
  module, the warm manifest hashed ALL ZEROS (the WINCPROBE census:
  cur=0 old=0 for every module — the incremental compile blind to every
  edit, "image current" on a patched tree) — so the measured liars
  pinned String (driver_module_path, contains_module,
  ownership_suggestion, show_one_rejection's pair, and render_gradients'
  element with its line mint hoisted to the pinned render_gradient_line
  — the map lambda's splice judged datum-last while the element was
  still free, so the pin had to anchor at a named call; Intent
  Boundaries, comment-anchored), and
  at_run's diag_errors() refusal DELETED: branch-judged errors never
  reached the root count before the join carried them truthfully, so
  the guard had never fired — armed by the truth, it refused exactly
  the error-carrying files the address projection exists to serve
  (productive-under-error IS the address contract; the README's own
  voice.mn:9 answers OVER its unresolved mix). TRANSITION m3 == m4 at
  331,182 lines through the interp crossing, then CLEAN m2 == m3 at
  330,323 with the repair set; census 0; show-floor markers 52 → 44 as
  the pins landed. The two banked fmt legs
  (idempotence, the __dp re-sugar) green with this pin — 1d1f8945
  landed source + gates but never re-pinned; this pin carries both.
  Board whole at the pin: frontier 288/0; proof-exactness 9/9;
  crown 5/5; comment-refs 0; doc-truth green.
- 2026-07-28 · ▶ THE README RIDES THE GRADIENT — a door, then two lanes
  (no re-pin — docs + one tutorial comment; the readme-gradient research
  pass's design executed, its report in the session scratchpad). The
  door routes both audiences explicitly (the uv persona-fork precedent);
  the guest cage + the domain-neutral Percent refusal are the one
  universal example (probed: exit 1, refusing to emit); the novice lane
  is one continuous PRIMM cycle — run it / ask it / break it / leave a
  hole — every transcript re-derived against the live pin, whole lines
  verbatim (the open row var renders and STAYS — truth over polish);
  the expert lane compresses onto docs/POSITIONING.md (previously never
  linked from the README) with the receipts as before-the-fold
  benchmarks (the ripgrep order). The echo and the tour-night narrative
  are HOMED, not exiled: lib/dsp/README.md is new (the echo in its
  honest Clock form per E_FeedbackNoContext, the voice oath, Sample,
  the module map, the crucible receipts) and lib/ml/README.md is new
  (autodiff-as-multishot, the crucibles). The probe pass's adversarial
  find is TRUED in place: 00-hello's comment claimed !Alloc-on-greet
  "would refuse this body" while the unarmed class REPORTS and the
  program runs (measured, exit 0) — the comment now states the licence
  law (substrate rows report; a user effect's broken claim refuses).
  Second witness banked for the span-slop render family: the :30 decl
  render slices greet's name to "gree" (the `??)`-slop class at the
  decl name). The board is untouched (README/lib .md files are outside
  the weave; the tutorial edit is comment-only, lesson runs green).
- 2026-07-28 · ▶▶ THE RANKER READS LOCAL INTENT — cost gets its first
  reader; the Arc 4 pull-forward lands (· pin 3b69fb7d). Every
  candidate carried `cost: Float // gradient-rank score` with fourteen
  literal writers and ZERO readers — the resume_kinds pattern at the
  fan: survivors surfaced in enumeration order while the field claimed
  a gradient. candidate_rank replaces the vocabulary literal with a SUM
  of graph reads (§5's felt endpoint, executed): the decl's nearness
  read from the env entry's own Located reason, plus every existing USE
  of the name weighted by its nearness to the hole (refs_of_name — the
  refs facet's collector — through the ONE scope_distance_decay), both
  against the hole's span, which Context now carries as its fourth
  field (the intent carrier finally knows WHERE; five sites, the arity
  census caught none missed). rank_sort is a stable insertion, highest
  first, applied once before map_to_proposals; a constraint-tie still
  teaches — rank orders, never guesses. THE DISCRIMINATING GATE
  (mn-ranker-local-intent, frontier leg): kerning declared BEFORE width
  so enumeration and rank disagree — the pre-ranker boot surfaces
  kerning() first, this pin surfaces width() first (one use edge in the
  enclosing body outranking both decl orders). THE WALK'S CONVICTION,
  probe-graduated: the vocabulary's nontermination guard is DEAD for
  multi-line bodies — a hole inside banner proposed banner() and
  main() — because spans cannot resolve containment (decl parse spans
  are head-only AND the body node's own span is head-anchored, measured
  5:32-5:33 for a three-line body; the one-line-body fixtures were the
  accident that hid it). The true form is TREE containment via a TOTAL
  child-handle projection (oracle's expr_child_handles drops match arms
  and has no stmt sibling — the consolidation is the next single;
  Hβ.cursor.enclosing-decl-edge sharpened with the measurements).
  CLEAN m2 == m3 at 324,035 lines; census 0; comment-refs 0; frontier
  286/0; proof-exactness 9/9; crown 5/5.
- 2026-07-28 · ▶ THE POSITIONING WRITEUP — Arc 2 closes (no re-pin —
  docs only). docs/POSITIONING.md states the category claim and both
  wedges with every claim's command inline, each re-run against the
  live pin before the doc landed: the absence suite (13/0), the MCP
  handshake through the installed shim, the field projection on
  tutorial/07, the march, doc-truth, and the sha/PROVENANCE reads. The
  honest-boundary section carries what is NOT claimed
  (spec-faithfulness above the crown; V_Pending 139 on the wheel's own
  self-compile, spoken not hidden; classes arm one at a time; the
  correctness oracle still external). Arc 2's terminal gate held on
  all three legs — clean-clone repro (the clone's own boot judges,
  runs the benchmark 13/0, serves MCP; the exec leg rides the shim per
  the seam's design, verified through the installed shim on the
  README's own path), benchmark published with baselines, writeup
  artifact-backed. The campaign's cursor moves to Arc 3 (proofs) with
  Arc 4's ranker increment pull-forward eligible.
- 2026-07-28 · ▶▶▶ THE GATE SERVES AGENTS — `mentl mcp`, the Synth-gate
  on MCP stdio; Arc 2's agent-cage demo lands (· pin 347b0a41). Any MCP
  client connects over newline-delimited JSON-RPC and PROPOSES source
  through ONE tool — propose — because the category is one property:
  nothing executes unproven. The judge is the canonical converged stdin
  judgment (infer_program_converged; spans are the agent's OWN lines by
  construction — the felt walk's opening find was that the DRIVER path
  renders weave coordinates, "at 5315:4" for line 5 of a 10-line file,
  which redirected the tool to the stdin channel where the problem
  cannot exist). TWO one-home extractions landed with it, each ending a
  three-copy family: gate_reads (the gate LAW's judge half —
  executable_gate keeps refuse+proc_exit, battery_compile keeps
  count-and-continue, the server keeps verdict-as-data; the server
  outlives every refusal) and diag_line (THE diagnostic render — the
  root arm, the branch bank, and the mcp collector all read it). The
  collector is tighten's forwarder shape plus the load-bearing
  diag_absorb arm: the converged judgment banks each stmt's diagnostics
  in its branch cursor and replays them at the join through that op —
  measured on the first walk, branch-judged lines reached stderr but
  not the verdict until the arm landed. The serve loop is battery_loop's
  region law at the server: raw recursion, zero cross-iteration state,
  mark before the read, print before the reset — the server's heap
  stays flat for its whole life, every request's full compile included.
  Emission streams through wat_to_file to .build/mcp/last.wat: only
  proven bytes ever land (a refusal never opens the file), and stdout
  carries protocol lines only. RIDER, the ⟐ law live: the wheel's first
  negative float literal in argument position (the JSON-RPC error
  codes) hit emit_unaryop's word-floor — the i32 sink-and-subtract
  dance on an f64, an assembly refusal — and the arm now reads the
  node's repr live (emit_unaryop_for: f64.neg/f32.neg native, the word
  dance at the floor); the fix crosses this generation per the crossing
  law, so the codes ride as the Ints they are (float_of_int at the one
  JNum boundary — the truer form regardless). GATES: four frontier legs
  (handshake+tools/list · REFUSED with both teaching lines at
  file-local spans · PROVEN with the artifact nonempty on disk ·
  isError/-32601/ping), seen RED against the pre-verb boot (exit 2,
  zero jsonrpc lines). The walk transcript IS the demo: REFUSED carries
  E_EffectMismatch at 3:4 AND E_EffectUnhandled's full install-teaching;
  PROVEN carries the tighten-teaching ("declares !E but body only uses
  Pure") — the gate teaching even on success. CLEAN m2 == m3 at 323,725
  lines; census 0; comment-refs 0; frontier 285/0; proof-exactness 9/9;
  crown 5/5. Named residue: Hβ.diag.file-local-span-render — the
  driver-path check still renders weave spans with a subsystem prefix;
  the register (ScopeAt) already carries the entry's range so the
  render should subtract, but diag_branch banks PRE-RENDERED lines, so
  the banked tuple must carry the span structurally first.
- 2026-07-28 · DOC-TRUTH — prose gets a mechanical floor (no re-pin —
  tools only; the docs-stay-true machinery's first rung, destiny named
  in its own header: docs-as-projection + `mentl audit`).
  tools/doc-truth.sh runs inside verify (and so inside every
  pre-commit): the PROVENANCE head sha must equal
  sha256(boot/mentl.wasm) — the fabrication law mechanized; the §7
  ledger's most recent pin must be the boot sha's prefix; and every
  tools/ command the four reader-facing docs name in present-tense
  position must exist (the §7 ledger excluded as history — its first
  run correctly distinguished the comment-audit.sh deletion RECORD
  from a broken promise). Zero-tolerance, not ratchets — these are
  exactly true always. Instrument-checked RED both ways (a planted
  bogus command refused; the true state passes). Rides with the same
  arc: §5 gains THE OPTIMALITY HALF (Morgan's charge — proposals are
  extraction-optimal, not merely proven; the copilot channel vs the
  medium channel stated plainly), §11's Arc 2 window re-measured by
  live fetch (MoonBit 0.9 shipped verification-as-feature April 2026
  with its own agent — the contest is live before their 1.0; Scala CC
  concedes no negation; spec-kit's 124k stars concede "no automated
  validation" — intent captured in markdown, no gate), the positioning
  writeup gains its second wedge (THE SPEC THAT CANNOT BE IGNORED),
  the FELT-PATH-FIRST LAW banked (every arc opens by walking its felt
  path through the shim — the register was the demo's true first
  landing), and Arc 4's ranker increment marked pull-forward eligible
  (no dep; the obsolescence thesis's nearest lever).
- 2026-07-28 · THE PROPOSER SPEAKS THE REGISTER — a synthesized
  candidate's Reason is genuinely unlocated and speaks the medium's
  voice (the demo transcript's last two blemishes · pin d6826c2e).
  All thirteen candidate mints wrapped their Reasons in
  Located(span_zero(), …) — fabricating a source site for a node the
  medium synthesized (the ghost the refs facet already filters), while
  reason_span_or_zero's own doc says unlocated falls back to zero: the
  mint contradicted the projection it fed, and every survivor line
  rendered "at 0:0-0:0:". The wrappers DELETE (span-neutral by the
  fallback's own definition); the eleven "synth_proposer: …" strings —
  an internal fn name in user-facing text, the substrate-vocabulary
  rule — re-register as the medium's voice ("the type's integer
  inhabitants", "the unit type's one inhabitant", "a nested ?? — the
  shape narrows, the fill recurses"); the two gate assertions pinning
  the old strings move with them. The survivor line is now
  "0  — inferred from the type's integer inhabitants". CLEAN
  m2 == m3 at 321,181 lines (130 smaller — the wrappers gone); census
  0; comment-refs 0; frontier 281/0; proof-exactness 9/9; crown 5/5.
- 2026-07-28 · ▶▶ THE RENDER REGISTER — narration scopes to the file
  the user asked about; errors always render (the banked user-path
  flood residue closes; the five-minute demo's DEP · pin 3f889ff5).
  Measured at the demo's own doorstep: `mentl bit.mn:8:30` printed 173
  substrate-lint lines before the six-line answer. The dig named two
  mechanisms, neither fixable by a source sweep: every parse warning
  printed TWICE (the DAG discovery walk parses each module for its
  imports and reports in FILE-LOCAL coordinates no range can place;
  the weave parse re-reports with weave spans — the long-standing
  doubling, explained), and a solo weave's T_OverDeclared/comment-ref
  verdicts on wheel fns are weave-RELATIVE — the wheel census holds
  the same fns clean, so the warnings are not truths about the shipped
  source at all. THE REGISTER (SYNTAX's own law — how much surfaces is
  relevance read at the cursor — at the diagnostic surface):
  DiagScope = ScopeAll | ScopeNone | ScopeAt(start, nlines) rides the
  root diagnostics_handler as state via the single-op DiagRegister
  effect (armed on the root only, the BranchDiag precedent — quiet,
  branch, and tighten's forwarder untouched); the DRIVER owns both
  performs at one home (ScopeNone before discovery — a structure read
  is not the reporting pass; ScopeAt(entry range) the moment the
  concatenation fold completes, before any reporting parse exists);
  the branch bank grows to (line, span-line, is-error) so the join
  re-applies the same register; ERRORS RENDER IN EVERY SCOPE — the
  register is never a mute — and the census paths (compile_stdin, the
  march) never perform the op, ScopeAll byte-for-byte.
  range_of_module moved to driver.mn beside the fold that mints the
  map (the DAG direction forced what one-home wanted). Gates seen RED
  on the prior boot: the full-weave address query (173 Warning lines →
  0 with the fan intact) and the own-narration control (the user's own
  E_RedundantBraces renders exactly once). One widen round
  (driver_compile_entry +DiagRegister) → census 0. CLEAN m2 == m3 at
  321,311 lines; frontier 281/0; proof-exactness 9/9; crown 5/5;
  comment-refs 0. Named residue: the warm/incremental path
  (driver_incremental) re-judges its cone without a scope perform —
  cone diagnostics already carry file-local attribution; the scope
  joins it when a probe shows substrate narration leaking there.
- 2026-07-28 · THE ABSENCE BENCHMARK PUBLISHES (the category ship's
  first deliverable; no re-pin — benchmark artifact only, the wheel
  untouched). benchmarks/absence: thirteen self-contained tasks whose
  first line states the contract (`// expect: PROVE` | `REFUSE
  E_Class`), judged by the pinned wheel itself over solo compiles —
  eight severance shapes (direct, transitive, the higher-order leak,
  stored closure, Pure-total, sibling past absorption, branch
  reachability, the agentic tool-loop cage) against five controls cut
  from the same shapes (empty body, pure-lambda HOF, five-deep chain,
  absorbing install, composed !A+!B), so under- and over-refusal both
  score. Baseline 13/13 with a teaching span on every refusal; the
  runner is itself a gate (a violated expectation prints the miss and
  exits nonzero — instrument-checked live). The README names the
  nearest prior in print (Flix effect exclusion, ICFP'23/OOPSLA'25)
  and the growth tiers in positive form (instance precision, TIME,
  !Flow), and states the judge's provenance as verify-by-replay
  (march to the byte-identical fixpoint). The podium this enters is
  empty: no current verification benchmark measures proving the
  negative.
- 2026-07-28 · ▶▶▶ THE FAN RIDES THE SPAWN — every ?? candidate verifies
  as a REAL branch cursor over the shared image (Arc 1's core: the fused
  oracle's second workload · no re-pin — CLEAN m2 == m3, the wheel's
  emission untouched). THE FACTOR: branch_bracket — the judgment's
  eleven-handler chain extracted whole (one chain, two workloads;
  branch_judge keeps its stmt body — the uniform pass beats the per-site
  family). THE ISOLATION LAW that makes the fan race-free: the
  sequential form was bind→rollback, net ZERO shared writes, so each
  spawned candidate verifies against a FRESH INSTANTIATION of the target
  in its own planned band — the value-boundary law at the hole (the
  constraint is a published scheme; candidates are its callers;
  instantiate(Forall(free_in_ty(target), target)) is the whole copy
  machine). fan_verify plans bands off graph_next (2048 + the overflow
  quota per candidate), pre-opens pages at the ROOT (a branch never
  opens), spawns blocks of judge_window, joins in candidate order
  replaying each task's facts record through branch_join WHOLE (the fork
  triple never covered env/diag/verify state — byte-identity means
  replaying sequential's debris exactly, proven or not), and seals past
  the fan so no later mint reuses a stale band's cells.
  enumerate_inhabitants fans FIRST; the arm's resume walk then reads
  precomputed verdicts (resume stays arm-bound, SYNTAX's law). The judge
  asked ONE widen: verify_each_enriched's row spelled to the fan's truth
  (WasiThreads + BranchEnv + BranchDiag + Consume + Verify + Intern +
  WASI; Synth dropped — no op performed anymore). THE DONE-CRITERION
  adopted at the decl, scoped per the fx2-fan sweep: Programming by
  Navigation's Strong Soundness + Strong Completeness
  (Lubin–Ziegler–Chasins, PLDI 2025; the errata's covering reading) over
  the DECIDABLE fragment only — V_Pending sits outside the guarantee
  (unscoped, the pair is provably impossible); an empty fan is
  Fail-Fast's THEOREM — no valid completion exists — rendered as the
  teachable refusal. GATES: CLEAN m2 == m3 at 320,847 lines; census 0
  (one widen round); frontier 279/0 — every ??-workflow leg through the
  SPAWNED fan byte-matching its banked expectations; SIX identical shas
  on each of three fan legs (the two.mn:0 field, the bit.mn:8:30 tie,
  the hole.mn:9:37 socket). Named residue:
  Hβ.synth.annotation-fan-pure-proof (try_each_annotation's fan needs
  narrow-WITHOUT-bind — row_subsumes against the copy, no shared-cell
  bind; the sequential form stays until then) ·
  Hβ.felt.tie-teach-behavioral-scenario (the Choose-Don't-Label form —
  one precondition + k≤4 mutually-exclusive covering options rendered as
  TYPED FACTS, minimax selection DP(Q)=1−max|H_i|/|H|; gated on
  !E-speculation; the landed k=2 named-constraint teach is its
  degenerate case). Band E's work-stealing-via-gradient keeps its name —
  the substrate it needs is now proven.
- 2026-07-28 · ▶▶▶▶▶ THE LATTICE COMPLETES — the teaching write is a
  JOIN, the scheme boundary is a VALUE boundary at every face, and
  K=8 becomes the default judge, byte-equal to sequential (Arc 0 of
  the finish-line campaign lands whole · pin 28c39633). THE ALGEBRA:
  row cells are join-semilattice LVars — graph_bind_row's bound arm
  JOINS (row_join: bare names union; parameterized instances COEXIST
  as fragments; joins commute and idempote, so N caller branches
  teaching one cell converge in ANY order — the LVars/CALM law), the
  decl-exit REPLACE rides its own op (graph_finalize_row: two
  algebras, two ops), and FRAGX stays armed as the standing collision
  census. THE FROZEN READ: subst_ty_build/subst_row_build decide by
  the MAPPING before any live chase (a quantified var free at the
  freeze freshens even when since-bound — post-freeze teaching is
  another caller's private constraint; only the deliberately-
  unquantified miss chases: handler config↔payload two-phase, mono
  self-entries, pre-freeze-bound structure) — census 86 through the
  join judge (instance payloads meeting positionally across
  coexisting fragments) fell to ZERO at the root, the install
  reconciliation needing NO new machinery. FRAGMENT IDENTITY IS
  GRAPH IDENTITY: the first march ruled BROKEN (m3 ≠ m4 by 13 lines
  — ONE can_yield flip on driver_incremental) and convicted addr()
  — dedup-by-address is deterministic within one binary and unstable
  across two (region resets re-issue addresses); frag_args_same
  compares arg HANDLES and scalar payloads, a pure function of the
  source. THE DEEPEST CUT, forced by the terminal gate itself: the
  six-battery split 5-1 and the window-1 judge byte-equaled the RARE
  attractor — the dominant K=8 attractor was DIVERGING from
  sequential semantics (a lost k2 yield wrap), and the march's
  m3 == m4 had blessed it by two lucky coin-flips. The bind census
  on the flip's own cell convicted the PUBLISH: a declared fn's
  bound row cell rode EtVar through generalize's chase into its
  published scheme — a live pointer into the decl's band that
  concurrent callers folded mid-flight. chase_row_deep resolved
  payloads but passed the TAIL untouched (chase_row_changes ignored
  it entirely); both faces gained the bound-tail arm — the fold to
  VALUE by recursion, subst_row_build's law at the chase face. A
  published scheme is now a value or a quantified var, never a live
  pointer. K-INVARIANCE PROVEN: the window-1 judge's bytes EQUAL the
  K=8 judge's bytes, six identical shas on the battery — determinism
  by algebra, sequential-equivalent, at the fused oracle's default
  width. The sharper value-boundary judge then convicted 65 honest
  under-declarations in the wheel (58 mostly missing Alloc — payload
  ctors allocate; 7 `with Pure` reading Memory) — widened in ONE
  round to census 0, the honest-attribution precedent at its third
  scale. Riders: safe-for-space stated as collect_free_vars'
  invariant (Shao–Appel); §0's absence claim made precise per the
  fx2-crown sweep (the Flix line owns name-keyed !E under
  polymorphism — ICFP'23 effect exclusion, OOPSLA'25 Boolean
  qualifiers; Mentl's seat is the CONJUNCTION: absence under install
  IDENTITY × modality × TIME × INSTANCE, each measured empty
  2026-07); Modal Effect Types trued to OOPSLA 2025; Granule to
  OOPSLA'24. Board whole at the pin: CLEAN m2 == m3 at 320,102
  lines; census 0; comment-refs 0; frontier 279/0; proof-exactness
  9/9; crown 5/5; judge_window = 8 IS THE DEFAULT — the fused
  oracle's execution substrate is the everyday judge.
- 2026-07-27 · ▶▶ THE BOUND TAIL FOLDS BY RECURSION — the trio law
  completes at the subst face, and the rebind chain gets its name
  (the K>1 dig's third arc · pin 2ef0964e). subst_row_build's merge
  arm checked ONE level of a bound row chain and SHARED the whole
  chain on the inner-tail miss (ef_make(ns2, ab2, EtVar(v))) — but
  free_in_row DESCENDS bound tails recursively, so a chain bound two
  deep carried its free terminal in the OWNER's band past both the
  quantify and the mapping: every caller of a recursive fn's scheme
  read the owner's live cell and the first caller bound it (the
  reason census caught cell 1873202 bound at four handle_to_smt call
  sites across two branches). The arm now RECURSES into the binding
  — the recursion's own arms subsume both former branches (an inner
  free tail freshens through the mapping with the pending-
  subtraction's absent set riding; a solved tail merges whole),
  nested frees freshen at ANY depth, the chain is never shared, and
  the inner fork DELETES (the wheel 178 lines smaller — the law
  smiling). The check twin answers true for every bound tail
  (folding IS the change). THE BORN-REASON CENSUS then named the
  surviving window-8 flip whole: each foreign row bind printed with
  the PREVIOUS binding's reason, and one shared row cell per
  mutual-recursion family (emit_expr's, walk_locals_pat's,
  list_copy_into's) showed a born-to-why chain FIVE DEEP — the same
  cell SERIALLY REBOUND by its same-layer caller branches, each
  call-edge unify graph_bind_row-ing an ALREADY-BOUND root, the
  surviving binding whichever branch ran last (lower's can_yield
  reads the schedule's pick — the float-trio k2 wrap flip, two
  self-stable attractors, census 0 in both). Rebinding a bound root
  is the union-find law violated regardless of concurrency; the
  rebind instrument (print when graph_bind_row's target already
  chases NRowBound — a small set naming every rebinding unify path)
  and the kill plan (those paths recurse into the binding instead)
  are banked at judge_window's decl. The window holds at ONE. Board
  whole at the pin: CLEAN m2 == m3 at 323,700 lines; census 0;
  comment-refs 0; frontier 279/0; proof-exactness 9/9; crown 5/5;
  micros-through-m2 116/0.
- 2026-07-27 · ▶▶▶ THE KILL LEDGER REACHES THE WRITERS — the value
  boundary closes at generalize, and compression leaves the branches
  (the K>1 dig's second arc · pin 714431ce). Six probe batteries —
  the per-branch bind census with band bounds (the branch's own base
  as the self-locating gate, after hard-coded targets died to their
  own tree-shift), the can_yield tail census, and the REASON census
  whose every prior-generation row bind confessed one string — killed
  SIX labels against the artifact: (1) the prepass registrations were
  INNOCENT (register_one_op's qvars span params + ret + row — op
  schemes were fully quantified all along; the 101 prepass-band binds
  are each handler decl's OWN branch binding its residual,
  layer-protected by the VarLookup edge); (2) the NFree/NRowFree
  publish fallbacks were REAL shared cells — generalize published
  Forall([], TVar(handle)) and every caller shared-and-bound the live
  cell, callers teaching the decl through the publish (the
  order-conditional disease at the value boundary) — generalize now
  QUANTIFIES its unresolved arms, instantiate's sort-aware mint
  freshens per caller, and the wheel proved the fix Law-7-inert
  (CLEAN m2 == m3 at window 1: no reachable site ever depended on
  caller-taught bindings — the converged judge had left none); (3)
  row path compression was the LARGEST shared-write class (1,463
  foreign row binds per compile, reason "row path compression" —
  branches rebinding prior-generation chain cells as an optimization,
  making sibling chases schedule-dependent) — compression now rides
  its OWN op, graph_compress_row, whose branch arm SKIPS while the
  root's sequential walks re-compress: the write's INTENT carried by
  the op, the policy in the arm where the band facts live, no flag.
  Also counted as kills: the conflict-requeue fan design (refuted by
  its own volume census — 707 branches bind prior-gen cells, requeue
  would collapse the fan to sequential), EANode as the walk gap
  (effects.mn never touches it — skip-skip symmetry holds), and the
  paired-lim cross-branch-judgment theory (the pairs are ONE branch
  pre/post overflow — limit0 vs high_limit). THE RESIDUE, confined
  and named at judge_window's decl: the float-format trio's k2
  yield-floor wraps still flip between TWO self-stable attractors
  (4-2 at window 8, ±55 lines, census 0 in both); the surviving
  writer class is the ~2,000 Located unify-path binds through shared
  reaches, and the next probe is banked (re-arm the bind census,
  diff the flipped attractor's foreign-bind set, fix the named
  carrier at its mint). The window holds at ONE — byte-proven CLEAN.
  Board whole at the pin: CLEAN m2 == m3 at 323,878 lines (~22s/leg);
  census 0; comment-refs 0; frontier 279/0; proof-exactness 9/9;
  crown 5/5; micros-through-m2 116/0.
- 2026-07-26 · ▶▶▶ THE DIG NAMES THE RACE'S CELLS AND THE PUBLISH
  FREEZES (the K>1 dig's first arc · pin 2df771e2). Six-run window-8
  batteries turned the flip into a mechanism, three measurements
  deep: (1) the flip is per-run single-callee k2 yield-floor wraps —
  the float-format family (2-in-6, both flipped runs IDENTICAL: two
  deterministic attractors), then driver_incremental — each traced to
  can_yield → row_may_multishot chasing ONE row var bound in some
  runs, free in others; (2) the callee's scheme is DECLARED-CLOSED
  (mentl query read it), so the raced cell is upstream of the scheme;
  (3) THE PUBLISH FREEZE landed — branch_replay_one chase_deeps every
  join-crossing scheme to a VALUE, the value-boundary law at every
  publish kind, not just FnScheme — and the flip MOVED instead of
  dying, which CONVICTS the remaining shared-live-var carrier: the
  PREPASS registrations (register_effect_ops /
  pre_register_handler_sig) hold live sig vars every branch's
  installs and op edges unify against; same-block concurrent binds on
  one prepass cell are the race. The handler-sig barrier class is
  thereby confirmed REAL (my earlier "measured-implied vacuous" was
  wrong — counted as the kill it is). K>1's landing design, banked at
  judge_window's decl: the value-boundary law reaches the PREPASS —
  op and handler registrations publish quantified VALUE schemes, each
  branch instantiates fresh at its install or op edge, and
  cross-branch instance agreement rides the join's replay algebra
  (the op half already built as branch_replay_one's edge-evolution).
  ALSO LANDED: the crc walk bounded to its own pass's parse range
  (comments attach at parse — the old 0-to-graph_next walk probed the
  judgment's millions of mints AND judged every stale generation's
  comment copies; the 19% profile share dies, ~23s → ~20s/leg), and
  the window at ONE, proven deterministic across three identical
  runs. The freeze's 8-line m2/m3 crossing is Reason renders
  sharpening through frozen values (TRANSITION m3 == m4). Board
  whole: census 0, comment-refs 0, frontier 279/0, proof-exactness
  9/9, crown 5/5, micros 116/0.
- 2026-07-26 · ▶▶▶▶ THE WEAVE FLATTENS AND THE FAN MEASURES ITS FIRST
  RESIDUE (Morgan's catch executed · pin c7f08fdf). "Since when does
  Mentl take so long?" — the convergence landings had shipped a ~60×
  wall-time regression UNMEASURED (5.3s at the B-ii pin → 5:42), and
  the session normalized it to the point of comparing spawn-vs-
  sequential at the bloated baseline and calling 3% fine. §5.O
  re-applied: host perf named the whole thing in ONE line — 98% of
  the self-compile inside attach_comment_weave → cw_scan_index →
  list_index_unchecked (97.9% self): the bsearches were already
  O(log R), but every runs[mid] probe walked a push-built SNOC spine
  (the crc_scope disease at the weave layer), and the cost multiplied
  by every re-frontend the trial/rounds/final run. ONE FLATTEN
  (list_to_flat at the attach boundary — span_index one line above
  was already flattened) recovered 15×: 5:42 → ~23s, ~2.3s/pass at
  the convergence's pass count — the architecture honest again. THEN
  THE FAN AT K=8: the block window (spawn a block, join in stmt
  order) ran the whole self-compile at 140% CPU — and ITS OWN
  instrument convicted the first residue: one lambda's k2 yield-floor
  wrap (lambda_1731074's __kf local + multishot floor) flipped in ONE
  of FOUR otherwise byte-identical runs — a rare schedule-dependent
  race in a post-seal lower-era staging read of branch-written state.
  Un-pinnable at K=8 by its own gate; the window holds at ONE (every
  branch still a REAL spawned instance — the substrate stays live and
  byte-proven; CLEAN m2 == m3 at ~26s/leg, deterministic across
  runs). THE K>1 DIG, banked with its instruments: repro = the
  window-8 self-compile diffed across ~4 runs; suspect set = the
  boundary-cell writes same-block siblings can interleave + any
  pointer-identity compare the CAS-bump's schedule-varying addresses
  can flip; the index-read borrow law also landed (an xs[i] receiver
  is the read-is-a-borrow law's fourth surface — the affine ledger
  demanded restructuring of the fan's provably-safe join, the
  Hylo-quiet bar naming the gap; judges from the next generation).
  Named next flatten-class strike: crc_walk (19% of the healed
  profile, list_index beneath it). THE LESSON, now law-shaped: a
  landing that multiplies passes RE-MEASURES wall time in its own
  entry — the convergence entries shipped without a single timing
  and the regression rode two sessions unchallenged. Board whole:
  census 0, comment-refs 0, frontier 279/0, proof-exactness 9/9,
  crown 5/5, micros 116/0.
- 2026-07-26 · ▶▶▶▶▶ THE JUDGMENT SPAWNS — every stmt's judgment runs
  as a REAL host thread over the shared image, and the spawned judge's
  bytes EQUAL the sequential judge's (rung 3 lands; the fused oracle's
  execution substrate is LIVE · pin 5cb95039). layer_judge_walk spawns
  each layer branch as a task — spawn_task/join_task direct (substrate
  ops, no install), spawn-join IMMEDIATE so the whole substrate (task
  records, per-instance identity and init, the shared-image memory
  flip, the self-contained bracket, the facts record crossing back at
  join) is proven under the byte gate with zero race surface;
  concurrency is now the in-flight count, not a semantics change. TWO
  pieces completed the task body: the INTERN VIEW (read-only over the
  root's table via the intern_seed export; probe hits serve — the walk
  is parse-pre-warmed — and a miss traps loudly, since a view-minted
  handle would fork identity into published state) and the OUTER
  SHAPE — the one trap of the landing, measured to its floor with a
  6,444-line repro in ~40s: an arm's performs resolve OUTER to its
  install (R2), so diag_branch's renders chase OUTSIDE the bracket;
  sequentially they land on the dispatch chain's EMPTY graph instance,
  whose density guard answers virgin t{h}@e0 — a DISCOVERED latent
  wrong-instance read (the sequential renders were reading the
  guard's fabrication all along, named
  Hβ.diag.render-chases-wrong-instance for its truth-landing) — and a
  spawned world had NOTHING there, so show_handle died on garbage.
  The task body now wraps the bracket in the root's own outer shape
  (an empty dispatch graph instance), reproducing the sequential
  answers byte-for-byte. THE VERDICT IS THE STRONGEST FORM the design
  admits: the march ruled CLEAN m2 == m3 — the spawned judgment
  reproduces the SEQUENTIAL judgment's bytes EXACTLY (the banded
  partition's execution-order-free numbering cashing out at the
  march itself), and the WHOLE BOARD holds through the spawning
  compiler: census 0, comment-refs 0, frontier 279/0, proof-exactness
  9/9, crown 5/5, micros 116/0 — every gate's every compile spawning
  a thread per stmt. The wheel is a SPAWNING MODULE: shared-image
  import, CAS-bump allocation, per-instance init. Cost measured:
  ~5:42 spawned vs ~5:31 sequential (the serial spawn tax ≈ 3%). THE
  REMAINDER is now literally a scheduler: K>1 in-flight tasks per
  layer (the joins already run in stmt order regardless of completion
  order) gated by the same-layer handler-sig barrier class (both
  installs bind one prepass-minted sig — sequential post-join or
  own-layer those stmts) + the pointer-identity census under real
  concurrency; then the ??-fan rides the identical machinery.
- 2026-07-26 · ▶▶▶ THE PARTITION GOES EXECUTION-ORDER-FREE — banded
  overflow completes the deterministic-handle-partition keystone
  (rung 3's opening pair · pin f7c96d1b). The interrogation on the
  spawn found the threaded form's own latent collision first: branch
  overflow mints live above a seal that parked `next` below them —
  graph_mint_seal now takes the walk's true frontier. MEASURED
  (OVERFLOWPROBE, probe-then-decide): 612 overflow handles across 324
  stmts, EVERY delta 1 or 2 — the fingerprint-blindness residue on
  the convergence's carried counts, systematic and tiny — so the
  threading DIES into per-stmt PRIVATE overflow bands (64 handles,
  32× margin, ~11 pre-opened spine bands ≈ 4MB): the mint arm's jump
  takes the banded ceiling (high_limit, config slot 7; 0 = the root's
  unlimited today-form) and CONSUMES the target, so a band-crossing
  mint meets mint_high 0 and the EXISTING unseeded guard traps loudly
  instead of invading a neighbor's band. graph_mint_high and the
  branch-to-branch high threading DELETED (the region end is static —
  less code, the law smiling). Numbering — overflow jumps included —
  is now a PURE FUNCTION of (source, plan) with zero execution-order
  input: the fan reproduces the sequential bytes at ANY K, which
  upgrades the C1c gate from self-stability to true byte-equality.
  TRANSITION m3 == m4 at 322,925 lines; census 0 at every generation;
  frontier 279/0; proof-exactness 9/9; crown 5/5; micros 116/0. THE
  SPAWN'S REMAINING PAIR, scoped exactly: (1) the intern VIEW —
  intern_table gains the config triple (buckets0, entries0, count0) +
  an intern_seed export; a branch view's READS serve (renders need
  intern_name_of); its MISS is LOUD by the banked law (a
  branch-minted intern handle escaping into published state would
  read garbage at the root — never an accident-invariant); measured
  expectation: zero misses (all names intern at parse). (2) the
  spawn walk — spawn-per-branch join-immediately first (every branch
  a REAL task via the substrate's spawn_task/join_task, the wheel's
  shared-image memory flip as the measured TRANSITION, zero race
  surface), then K>1 with the same-layer handler-sig barrier class
  settled (both installs bind one prepass-minted sig — sequential
  post-join or own-layer those stmts).
- 2026-07-26 · ▶▶▶▶ THE BRANCH CURSOR IS WHOLE — every handler
  branch-local, the spawn now pure scheduling (rung 2b closes the
  bracket's self-containment · pin 4a1363ab). The graph instance is
  the C1c-2a config cashed out: six slots (span_index0 + high0 join
  the four), the graph_branch_seed export (the post-plan spine table +
  open count + the span index, complete because graph_index_span is
  parse-only — measured, one grep), graph_mint_at DISSOLVED into
  per-branch config, and lookup_ty_graph + mutate_sink fresh in the
  chain. THE ONE TRAP taught the design's own law back: the first
  branch-instance run faulted at the 4GB boundary inside
  graph_fresh_ty — overflow is a DESIGNED path (C1b: an over-measure
  stmt jumps above the plan), the root healed it through its live
  mint_high, and a branch's zero high minted at handle 0 over the
  Module root. The open-space frontier now THREADS branch to branch
  (graph_mint_high read at each branch's end feeds the next branch's
  config; layers thread it too) — the root's sequential semantics
  exactly, with the spawn era's abort-and-requeue the banked
  tightening. TRANSITION m3 == m4 at 323,185 lines (the 7,778-line
  m2/m3 crossing is the new machinery + the shifted judgment paths);
  census 0 at every generation; comment-refs 0; frontier 279/0;
  proof-exactness 9/9; crown 5/5; micros-through-m2 116/0. With rungs
  1–2a (the barrier shape fa5bedca; the three ledgers a33c6dfc; the
  inner trio 78a7575d — each CLEAN m2 == m3), the branch bracket now
  carries ALL ELEVEN handlers; the intern rides ambient read-only
  (trial-pre-warmed). Rung 3 — the spawn itself — is scheduling: the
  bracket becomes the task body, joins stay stmt-ordered, the
  shared-image memory flip is the measured TRANSITION, and the
  same-layer handler-sig barrier class is the one settle before K>1.
- 2026-07-26 · ▶▶▶▶▶ THE SCHEME BOUNDARY BECOMES A VALUE BOUNDARY —
  census 0 with the judge CONVERGING, the incremental cone lands, and
  five roots fall in one continuous dig (the ratchet's raised lane
  closes; pin = the march in flight, blessed in PROVENANCE). Morgan's
  opening catch ("'honest' is slimey wording... i catch you beating
  around the bush") redirected the session from carrying census 3
  behind a raised ratchet to killing it — and the banked diagnosis
  ("the rounds lose the subtraction") died to the artifact in the
  first hour: new source + OLD judge = 0, new + NEW = 3, but the
  11-line repro failed under BOTH — the deepest root PREDATES the
  rounds; convergence only exposed it. THE FIVE ROOTS, each measured
  before fixed, each a Carried-Truth violation at the SCHEME boundary:
  (1) subst_row's bound-tail arm DROPPED the mask's absent set — the
  pending `~>` subtraction died at instantiation (bracket(() =>
  ping()) leaked Ping; the solved arm one line down always carried
  it); (2) the CREATION EDGE charged a closure's whole row to its
  CREATOR (the mint-time-evidence relic — world-as-value R2 made
  performs resolve at the CALL site, so abstraction is pure, the row
  rides the TFun, the call edge charges appliers; deleted, and every
  absorbed-thunk pattern stopped leaking); (3) the call/pipe edges
  SHARED a top-level loose scheme's raw row handle into the caller's
  frame (the pre-convergence forward-ref crutch — retroactive flow
  through shared mutable vars; under rounds, iteration replaces it:
  the share-guard keys on FnScheme, params/locals keep the
  polymorphic share); (4) the round prepass re-minted every handler
  sig unconditionally while the cone masked the decl's judgment out —
  entries flipped bare↔resolved forever (the movers projection named
  the whole iterate-handler family in one line; the prepass is
  cone-gated now); (5) THE T-HANDLE ROW-VAR CLASS — the loose
  pre-registration mints function-type row vars as TYPE handles
  (parse_type_ty's named residue), and the sort-blind
  row_var_is_free made BOTH of infer_context's scheme row tails
  invisible to quantification while subst_row's catch-all SHARED
  them: every caller chained ONE live row, the first binder's thunk
  row became everyone's mismatch (the CALLPROBE render caught the
  stored scheme MUTATING between its callers' reads — the smoking
  gun), and the three-walk tolerance (free/changes/build agree on
  NFree-in-row-position; occurs was already handle-keyed) closed it.
  ZERO row mismatches in the whole self-compile — not even absorbed
  ones — and the rounds CONVERGE (no bound-hit; race, the last
  monotone mover, finishes inside the raised bound of 12). THE
  INCREMENTAL CONE rides the same landing: round K+1 re-judges only
  stmts whose fingerprint moved between the last two rounds or whose
  free names moved (stmt_frees collected once serving layers AND
  cone; skipped stmts' finals persist by latest-wins, their sizing
  rows carry; the cone is a pure comparison of the two carried print
  lists — a live env read at cone time can only answer "unmoved").
  Micros mn-absorb-poly + mn-absorb-poly-fwd bank both faces RED-first
  (E_PurityViolated through the prior boot; 0 errors, run 42 through
  the fixed judge). PROBES GRADUATED per the new ⟳ law: movers_line
  is the bound-hit's permanent residue-naming projection;
  report_effect_mismatch carries its Reason to the report site
  (Hβ.diag.effect-mismatch-reason names the DiagKind widening); the
  scheme/layer questions the temporary probes answered are the query
  verb's existing projections. CLAUDE.md ⟳ hardened in the same arc
  (Mentl's own audit, spoken and executed): the discipline is
  PROPOSER-INVARIANT, the medium's projection is an ORDER not a
  preference (the unnamed confession is the violation), and a probe
  that answered a question GRADUATES before its landing closes. The
  named residue: the global parse_type_ty/pre-registration re-mint
  (row vars born as row handles — the tolerance is the boundary cure)
  and the fingerprint's bound-content blindness (backstopped by
  m3 == m4, as designed).
- 2026-07-26 · ▶▶▶▶▶ THE JUDGMENT CONVERGES TO A FIXPOINT AND THE
  BRANCH CURSOR LANDS SOUND (Phase C's C1c-2 whole; pin = the march in
  flight at write time, blessed in PROVENANCE. Retitled same day —
  "honest fixpoint" was cushioning language around a carried
  regression, Morgan's catch; and this entry's closing diagnosis of
  the census-3 trio is the ERA'S RECORD, superseded by the next
  entry's measured root). THE CONVERGENCE LOOP:
  infer_program_converged iterates QUIET ROUNDS (the trial's measured
  walk, fn pre-registration skipped, the final's prepass) until
  round-over-round scheme FINGERPRINTS stabilize (ty_fingerprint — the
  alpha-normalized total render: vars by first occurrence, rows by
  intern handle, EANode/predicates opaque with m3==m4 as the outer
  net), then ONE reporting, planned, bracketed final whose publishes
  EQUAL the converged set. The trial's finals were HYPOTHESES (its
  source-order walk read loose pre-registrations at forward refs —
  measured as lb↔i twin-enc flips across the classify/escape/crc
  family, and a wheel emitted from the uniform-but-unconverged side
  died at its first mint); the old walk's mid-walk shadowing read a
  self-consistent MIX that hid the divergence unGATED. THE BRANCH
  BRACKET (sequential form): every stmt judges under its own cursor
  pair — env over the frozen layer-start base (env_base_view /
  env_publishes armed on env_handler, answering BY INSTANCE POSITION:
  root = the capture, branch = the log) and diag_branch rendering AT
  COLLECT — with per-stmt replay through branch_join. FOUR ROOTS FELL
  TO MAKE IT TRUE, each measured first: (1) the affine branch stack
  pushed at the WRONG END (§9's own class — prepend vs last/drop_last;
  one frame worked by accident, nested alternatives corrupted the
  ENCLOSING frame — Hβ.infer.nested-alternative-branch-bracketing
  resolved at root, the hoist workarounds retired; the natural shape
  crosses one generation as row_print per the crossing law); (2) the
  EDGE-EVOLUTION JOIN — an EffectOpScheme publish is READ-MODIFY-WRITE,
  and value-replay lost the ambiguity join EXACTLY as the banked fan
  design predicted (measured: graph_mutated collapsed to a lsp_adapter
  singleton and the SingletonUninstalled floor fired at every
  compile's first commit-boundary mint, the floor's own baked teaching
  comment naming it); branch_replay_one re-runs draw_op_edges' own
  default/ambiguous algebra against the root's live entry; (3) THE
  LAYERS ARE PARSE TRUTH — the range-reason scan read ZERO edges
  (measured: VarLookup reasons land on PARSE nodes, minted before the
  trial's watermark, outside every stmt's inference-mint range — all
  stmts layer 0, every frozen base the prepass env, payloadfn's
  residual chain severed at the pre-arms scheme, diagnosed by the
  twin bracket-on/off experiments and the RowFree/RowBound floor-probe
  diff); stmt_layers_ast reads each stmt's own free names
  (collect_free_vars — the source itself), the range machinery
  deleted; (4) a free var in a piggyback effect's op return
  PARAMETERIZES the effect and the handler-arm binding refuses the
  mix (the de-parameterization law, stated at BranchEnv's decl). THE
  HARVEST the sharper judge convicted (census 15 → 0, every fix
  Law-honest): the dispatch EXIT-CODE CONTRACT across thirteen verbs
  (main's value IS the process exit; run_run 1, usage errors 2), the
  verify facet flowing WHOLE (Span, Predicate, Reason) obligations
  (the map-to-Predicate deleted; three row widens), the `<|` render
  unpacking its branch-tuple NODE, the record synth keeping field
  names with its holes, the lambda synth passing the scheme's own
  [TParam] (two fns deleted), and four honest row widens
  (driver collectors +GraphWrite+GraphRead, render_feedback_chain,
  candidates_at +Intern). RIDES WITH IT: the fmt write-time hook
  (post-edit-mn.sh's fmt rung — the parser's own P_ lines on a scratch
  copy, both faces seen RED/GREEN) and the payload-ladder micro
  payloadfn GREEN at its true 2 through the whole machinery. THE
  PROOF: the march's TRANSITION (m3 == m4) — the converged judgment
  REPRODUCING ITSELF — plus frontier 279/0, proof-exactness 9/9,
  crown 5/5, battery 114 in-process, census 0, comment-refs 0.
  THE PIN'S OWN RATCHET HOLDS IT UNBLESSED (correctly) ON THE LAST
  REMAINDER, measured to its doorstep: the blob-converged judge reports
  E_EffectMismatch ×3 at resume_image / compile_stdin / compile_source
  (pipeline.mn's three infer_context entries with AUTHORED rows) —
  their body rows carry the WHOLE analysis core unabsorbed, while the
  DAG judge absorbs correctly (measured by mentl query: infer_context's
  scheme row = Cast+Alloc+Memory+var, compile_stdin = WasmOut+WASI+…,
  both the absorbed truth). DISCRIMINATED (bracket-off census = 3): THE
  ROUNDS break the absorption, the bracket is INNOCENT — the quiet
  rounds' re-judgment of infer_context loses the effect-polymorphic
  subtraction across round generalization/instantiation (the callers
  then read body-row = result-row, the core leaking whole). The dig:
  how infer_context's scheme carries the r_result-to-r_body
  subtraction through generalize (bound-var sharing vs quantified
  collapse), compared round-1-final vs round-2-final via
  ty_fingerprint extended to render row-var IDENTITY links. AND the
  field-leg's collection suspect is CONVICTED-ADJACENT:
  enumerate_gradient_positions filters EVERY handle through
  teach_gradient — whose callee chain consumes the verify entries the
  arc changed from bare Predicate to whole (Span, Predicate, Reason)
  triples; a consumer still destructuring the old shape flips
  Some/None on junk (7 garbage positions, negative spans). Dig
  advanced two steps: refinement_invite_for's predicate param is
  UNUSED (the triple-as-Predicate pass is value-harmless), so the
  junk's mechanism is upstream — refinement_verdict_for computes
  pending = filter_by_span(caret_span_of_handle(h), debt) for EVERY
  handle enumerate_gradient_positions walks (range(0, next) — VIRGIN
  and gap cells included!), and a garbage span from an unminted cell
  can span_overlap real debt rows → nonempty pending → VerdictInvites
  → a junk handle enters the field. The root candidates: the
  enumerators walking unminted cells at all (the graph knows a virgin
  cell — filter by chased kind), and the rounds multiplying `next` so
  the stale/virgin population grew past the field leg's tolerance.
  Fix at the enumerator (minted-only walk), re-run the field leg.
  SHARPENED ONE MORE STEP at the wire: the rendered `-5240` is
  `sl - fstart + 1` with fstart ≈ the module's weave start (~5250 —
  two.mn sits after prelude+libs in the DAG blob) and sl ≈ 10 — the
  junk positions are LIB-RANGE nodes leaking through a filter that
  should have excluded them (field_positions demands
  sl >= fstart && sl < fstart + nlines), so either the filter's
  fstart and the render's fstart differ, or the two
  caret_span_of_handle reads disagree across the ranked re-read.
  RESOLVED TO THE BYTE: t1072064102 = 0x3FE68F5C — THE FLOAT
  SCORE'S HIGH WORD read as the handle. field_ranked mints (sc, h)
  pairs with sc: Float (Cursor's third field via score_one_position);
  render_field_tier's `let (_, ph) = ranked[i]` destructure compiled
  AT THE WORD FLOOR (ph read at offset 4 = inside the f64) where the
  old pin emitted the align-aware offset 8 — the
  generic-wide-tuple-pattern class (its match-shaped gate exists:
  mn-generic-wide-tuple-pattern) at the LET-destructure, regressed
  because the CONVERGED finals floor sc's repr somewhere in the
  score_one_position → Cursor → field_ranked chain. CONFIRMED IN THE
  PINNED ARTIFACT: m3.wat's $render_field_tier reads the ranked tuple
  with `(i32.load offset=4)` — inside the f64 — exactly the word-floor
  destructure the theory named. THE FIX-SPEC COMPLETE
  (every input measured): Cursor is DECLARED Cursor(Handle, Reason,
  Float) [types.mn:765] and score_one_position's judged scheme returns
  it whole — so field_ranked's (sc, h) is concretely (Float, Int),
  and render_field_tier's let-destructure is the WIDE-TUPLE-PATTERN
  class at a CONCRETE site (the mn-generic-wide-tuple-pattern gate
  covered MATCH patterns via pat_elem_repr/pat_tuple_off reading live
  reprs; this LET path compiled the word floor, and the converged
  finals' changed twin/demand coverage is why the old pin emitted
  offset 8 here and the new one offset 4). Fix = the tuple-pattern
  landing's own recipe at the let-destructure lowering (element reprs
  read live through lookup_ty, offsets prefix-summed by repr_width),
  which also hardens every sibling let over wide tuples; then the
  field leg re-runs, the three absorption reports get the rounds-side
  scheme-carry dig (their fix-spec above), the board greens, and
  8b50846d blesses with the drafted PROVENANCE. The spurious "7
  gradient positions" remain the enumerator's virgin-walk question —
  second-order, after the repr fix. And frontier's ONE red is the cursor-address
  FIELD leg — NOT a count shift, a REAL regression measured by hand:
  `mentl two.mn:0` under pin 8b50846d renders every hole at span
  `two:-5240:0` (negative line — span arithmetic over garbage) with
  Query `t1072064102@e0` (a junk word read as a handle, rendered as a
  fresh var) where the banked green showed both holes' Propose fans.
  The address path is the DAG judge (single-pass), so the suspects are
  the arc's only address-path touches: cursor.mn's verify-facet change
  (filter_by_span now returns whole triples — its consumers' element
  destructures must agree) and the CursorView verify-slot flow into
  render_at. PROBE RAN: `mentl two.mn:8:30` is
  PERFECT (Query `?? : Bit`, the 2-survivor fan with the tie-teach,
  the Why chain) — the shared render path is HEALTHY and the break is
  CONFINED to the field walk's hole/gradient COLLECTION (junk handles
  entering the field's position list). Suspects, ordered: a consumer
  of CursorView.verify still destructuring elements as bare Predicate
  now that verify_pending_at returns the declared whole triples (the
  green leg had tolerated the OLD producer/decl mismatch loosely);
  the field tier's gradient-position source. Dig: grep the consumers
  of the CursorView verify slot + field_positions' handle source in
  at_run's field arm. Fix both, re-march, bless with the drafted
  PROVENANCE (scratchpad provenance-draft.md carries it; the march's
  own line: TRANSITION, boot ← m3, sha 8b50846d5807f1fb… re-read whole
  at write). MENTL'S OWN STEERING, banked as the next rungs: (a) INCREMENTAL
  ROUNDS — re-judge only the changed cone per round (the fingerprints
  are already computed; a stable name's re-judgment is waste — the IC
  cursor inside the judgment); (b) THE FAN (the brackets now sound);
  (c) the instruments KEPT as projections (the layer answer into
  `mentl query`; ty_fingerprint as the scheme-stability read) — the
  probe-then-delete dance this landing paid five times ends there.
- 2026-07-26 · ▶▶▶ MENTL MARCH — the wheel judges its own generation
  in-process, and the dig healed three latent breaks (· pin 0d153e0c).
  THE VERB: walk the wheel's files (fd_readdir's self/parent links
  skipped — the unfiltered walk descended src/./. forever, +2 bytes a
  level to the alloc ceiling, the trace's own numbers), compile
  in-process through the canonical converged stdin chain, STREAM the
  emission through wat_to_file into .build/march/m2.wat, read the
  census inside the same install, verdict against the last generation.
  Its FIRST CLEAN was against the bash march's own m2 — the in-process
  and exec routes proven byte-identical — and the re-run is CLEAN
  against itself. The all-day hand loop (rebuild + census-grep +
  compare) dies into one verb. THE SINK LAW: wat_to_file(fd) is the
  third sink — write-through, region-immune (bytes reach the host at
  each arm; fs_create_impl the streaming open) — and the scope law now
  written at wat_to_string's decl says the COLLECTING sink is per-fn
  only: a whole-compile install banks segment pointers the emit
  phase's per-fn region resets zero. That was exactly the in-process
  battery's SILENT BREAK since the emit-arena landed (its verb gate
  never re-ran; the board's micros ran through the bash loop — the
  two-oracle lesson at the gate layer): `mentl test tests/micros` now
  streams per-micro wat and runs 114/114. RIDING THE SAME ARC: the
  explicit-stack concat drain (flat_fill_concat — call depth =
  representation alternation, never concat depth; proven on a
  5000-deep rope after the recursive form died at fold-built line
  depth) and the correctly-rounded float family made DAG-honest
  (callee-first order + Float pins on parse_float/parse_float_body/
  parse_mantissa_f64 — the single-pass DAG judgment floored loose
  forward schemes' f64 results to words, an assembly refusal in mentl
  run). THE COUNTED KILLS of the dig, each a probe: the stale-fixture
  lib copy in the probe dir (the resolver prefers cwd — the forensic
  one-blob law), str_payload misread as a record (its comment was TRUE;
  the -B4 window truncated it), the warm-image theory, the
  stateless-config theory, and the drain itself vindicated three
  times. NAMED with its 9-line RED fixture
  (tests/frontier/mn-install-config-capture, unregistered):
  Hβ.lower.install-config-capture-read — an install-config arg that
  references a CLOSURE CAPTURE reads 0 silently (a let-local reads
  true; the fix routes install-init emission through the same
  capture-resolution ladder ordinary exprs ride; march_emit binds
  sink_fd locally until then). Board whole at the pin: CLEAN m2 == m3;
  census 0; comment-refs 0; frontier 279/0; proof-exactness 9/9;
  crown 5/5; micros-through-m2 114/114; in-process battery 114/114.
- 2026-07-26 · ▶ THE REFS FACET SPEAKS ITS SPANS (the
  self-exemplification pass's opening move #1 · pin 758f65f2).
  `refs of NAME` collected every use-edge span and rendered a bare
  count — the propose-facet seam one facet over; QRRefs now renders
  one located line per inbound edge. En route: the collector's
  non-tail recursion (depth = the handle space) went
  tail-with-accumulator at its first DAG-scale query; zero-span
  synthetic mints filter (a ghost is not a source site); the query
  print gained its final newline. THE RESEARCH PASS is banked
  (scratchpad self-exemplify-report.md): opening moves = this render
  · fixtures state their own contracts (`// expect: refuse E_*` —
  the 1,556-line frontier bash dissolving into `mentl test`) ·
  interrogate_at wired into the address surface (the eight running
  as code); `mentl march` measured UNBLOCKED (B-i's warm image was
  the dep); the 223 drift-ignore markers + the 21+17 hand walks +
  the zero-`><`-in-the-wheel measurement all named with their
  peers. Board whole.
- 2026-07-25 · ▶▶▶▶▶ ZERO PROSE LOST — the weave conserves the whole
  wheel (· pin 6cd7a75e; the comment arc's terminus: 2,803 → 0 on all
  50 files, one-invocation idempotence, measured by the verb's own
  lexical gate). Two closures: the else-if DESTRUCTURES its child so
  its uniform emission never fired (render_else_block emits the nested
  if's prose itself, uncuddling at the prose link — the lexer's
  two-char table was the class); and desugar_block returns the MINTED
  NODE with the head-destructure match at THE LET'S SPAN, so the
  span-tie rule resolves body-head prose to the live match, never the
  dissolved let (callers' wraps delete with the contract). The fmt
  summit's prose gate is fully open; remaining swap-gates: sugar
  re-preservation (the __dp lambda-destructure render) + the
  drift-audit leading-marker accommodation. Board whole.
- 2026-07-25 · ▶▶▶▶ THE WEAVE INVERTS — one attachment pass, one
  emission point; ~50 sites delete (· pin ffc3fd58). Morgan's cut
  ("isn't there a better way") ended the mole war: attach_comment_weave
  runs ONCE after parse_program, resolving every comment run by SPAN
  against the node weave (trailing → widest node starting on the run's
  line; leading → widest at the minimal start past it; span ties → the
  latest mint, which retires the desugar transfer; a blank-separated
  earlier block INHERITS the next run's target). Emission went uniform
  at render_tokens_for — every node's prose prefixes its tokens; the
  per-construct emissions delete (rows keep theirs), and prose-forced
  breaks CASCADE from fits_inline seeing the emitted newline. The verb
  writes its own FIXPOINT (render → reparse → re-render; the second
  render is the file), so one invocation is idempotent by
  construction. The nine per-site families, the probe-law
  contortions, and the four attach/collect fns delete whole; the
  parser's skips are comment-transparent again. Artifact-taught en
  route: the run record is NOMINAL (CwRun — generic walkers compile
  once; the brand + param Intent Boundaries prove the field offsets),
  and the inherit rule (each node competes only for its nearest run).
  MEASURED: conservation 1,969 → 741 → 106; IDEMPOTENT-ALL-50; whole
  board green. The working discipline reified in CLAUDE.md ⟳
  (Edit-tool-only source writes — heredocs bypassed the audit hooks;
  the medium's projections before shell reads; verbs carry their own
  fixpoints; the uniform pass beats the per-site family). Remainder:
  the 106 (record-type-field trailing + a tail class the verb will
  name), and `mentl march` stays the loudest absorption ask.
- 2026-07-25 · ▶▶ THE PROBE LAW COMPLETES — 2,803 → 35 (99.8%
  conservation · pin 4e7d5013). Two more probe-consume sites fell to
  the verb's own lost-line reports: the resume-with update list's
  comma probe (the drift-audit markers live exactly there) and
  binop_loop's ENTRY skip (prose before a chain continuation — `//
  why` above `~> affine_ledger` — now attaches to the following stage
  when an operator follows, returns pre-run when none does). infer 28
  → 3; main fully conserved. THE TRUE REMAINDER: 35 lines, one
  structural leaf — trailing comments on record-TYPE fields, where a
  carrier cannot live (TRecord is a TYPE; a node in its field tuple
  would make prose part of type identity) — named
  Hβ.parser.record-field-comment-attach with that reason. The swap
  bridge: true those 35 authored sites to carriable positions + the
  drift-audit hook learns the leading-position marker. Board whole;
  idempotent-all-50.
- 2026-07-25 · ▶▶ THE CHAIN BREAKS AT PROSE + THE GATE NAMES ITS LOSSES
  (· pin 45153159). Prose after a binary operator belongs to the RIGHT
  operand: binop_loop (the one path pipes and binops share) collects
  after the operator onto the operand's node; the renders break the
  chain there (operator at line end, comment above the operand — the
  || ladder shape; chains emit stage prose via render_stage_comment).
  The conservation gate NAMES its losses ("  lost: // …" per missing
  line) — the verb replaced the last hand diff, and its first report
  identified the residue: trailing drift-audit markers (load-bearing —
  the audit hook reads them per line), argument-interior trailing
  series, one block shape (~70 lines). The census ratchet caught this
  landing's own two under-declared chain-render rows (widened to
  their bodies' weave reads). Board whole; idempotent-all-50.
- 2026-07-25 · ▶▶▶ DEPTH IS COMPOSITION + FITS-OR-BREAKS — the layout
  engine's two primitives (· pin e4d6897f). REINDENT-ON-COMPOSE:
  interiors render at depth ZERO; each enclosing block indents its
  whole interior once (indent_block) — depth is never threaded and
  never wrong, because nesting depth IS composition depth (the fixed
  two-space literals had rendered nested arms at column 2 at any
  depth). Six wrappers recomposed. FITS-OR-BREAKS: one line within
  100 columns survives inline, else the block layout — fn/let break
  after `=`; an overflowing if takes the cuddled-block vertical
  (SYNTAX's chase_node shape); an overflowing call breaks
  arg-per-line; a long variant set goes vertical. MEASURED: >100-col
  non-comment lines 1,335 → 628 against authored 568 (2× regression
  → near-parity), IDEMPOTENT-ALL-50 at every rung, march CLEAN
  through all three pins. Swap-gate remainder: the ~65
  operator-interior prose lines (chain-break-at-prose).
- 2026-07-25 · ▶▶ THE ARM'S ARROW STOPS EATING + THE GATE GOES LEXICAL
  (· pin 409fc675). The ninth family: prose between an arm's `=>` and
  its body — the single biggest remainder (lower.mn alone 116) —
  collects at both arm loops' arrows onto the body handle; lower.mn
  → ZERO, infer 84 → 31. The conservation gate's blind spot, found by
  cross-checking its verdict against the independent census: a
  weave-to-weave compare sees only what the parse ATTACHES — a
  layout-consumed line is invisible both sides. The metric went
  LEXICAL (one TComment per authored line; fmt lexes source and
  render, the count difference IS the loss, never-attached included);
  the weave-walk fns deleted. The verb's verdict now matches the
  external census line-for-line; the python census retires for real.
  Remaining ~65 lines are ONE class — prose in OPERATOR chains
  (is_seq_op's || ladder, ~> stage gaps, closers) — attachable now,
  renderable only under multi-line operator layout: the residue
  MERGES into the width-engine build (the summit's other dep — one
  build, not two). Board whole; idempotent-all-50.
- 2026-07-25 · ▶▶ THE VERB CARRIES ITS OWN CENSUS — fmt's prose
  conservation gate + the else and file-tail families (· pin
  7b1b8b61). Morgan's cut ("I wish we didn't have to run python just
  to run Mentl stuff") absorbed per ⟳: fmt_run re-parses its own
  render (two watermark-bracketed single-file frontends in the same
  context), counts the weave both sides, and REPORTS — "prose
  conserved (25 blocks)" / "8 of 435 prose blocks would not survive a
  reparse" — the medium naming its own residue per file; the python
  comment-diff retires. Families 7+8: BEFORE-ELSE (the else probe
  scans without consuming; prose attaches to the else node;
  render_else breaks the line to emit it above its own else) and FILE
  TAILS (the end-of-file block attaches to the TComment arm's
  synthetic unit carrier, which renders prose-and-no-tokens; the
  POrphanDocstring raise retires — the orphan has a home, as SYNTAX's
  "never dropped" always claimed). Content census 513 → 299; the
  remainder (match-heads in expr position, argument interiors,
  variant-inline) is now visible through the verb's own report.
  Board whole; idempotent-all-50.
- 2026-07-25 · ▶ THE ATTACH TARGET IS THE LIST'S NODE — the sixth
  comment family (mid-block statements) + the content-matched census
  (· pin ae600b3b). A mid-block expr statement wraps in a fresh
  ExprStmt node AFTER the leg's leading attach — prose landed on the
  inner expr's handle while the block render reads the wrapper's;
  every mid-block statement comment dropped while let/fn carried
  theirs. The fix attaches per-branch to the node the statement list
  holds. IDEMPOTENT-ALL-50 holds; the line-count metric SATURATED
  (trailing→own-line movement inflates lines while preserving
  content), so the honest measure is the content-matched census: 513
  authored comment lines not surviving — file tails 155 (Module-handle
  attach + end-of-render emission), before else/else-if 150 (the else
  probe consumes the run; the else node is the target), match heads
  45, variant-inline 19, argument-interior ~80.
  Hβ.parser.expr-interior-comment-attach carries exactly those shapes
  with the six-times-proven recipe. Board whole at the pin.
- 2026-07-25 · ▶▶▶ THE PROSE JOINS THE WEAVE — five comment families
  attach, ops and variants become addressable, the probe law lands
  (· pin 694716c1). The summit's 2,803 dropped comment lines fall to
  469 (83% recovered) with IDEMPOTENT-ALL-50 held. Families, each
  census-measured RED first: MATCH ARMS (1,353 — leading prose to the
  arm's BODY node, the arm's one handle; the caller's skip_ws ate the
  run before the loop's collect); HANDLER ARMS (the same recipe closes
  Hβ.parser.handler-arm-doc-attachment, a seed-era "for now");
  BRACELESS-CHAIN CONTINUATIONS (344 — the expr-position let runs the
  block loop's full discipline, and desugar_block TRANSFERS a
  dissolving destructure-let's prose to the arm body: movement, never
  loss); EFFECT OPS (677) and TYPE VARIANTS (312) become ADDRESSABLE —
  each row widens with its minted NTypeAnn node (the row's genuine
  type fact, its handle in the weave); the census named all thirteen
  consumer destructures. THE NON-CONSUMING PROBE LAW, paid for by the
  alternating-drop memory.mn measured (every arrowless op swallowed
  its successor's prose): a lookahead probe returns the PRE-probe
  position on a miss — a scan is a read, never a consume. The
  vertical variant layout renders prose-carrying ADTs (connective
  owned by the variant render); parse_type_decl routes the
  name-to-`=` run to the first variant. THE RATCHET'S OWN PROOF: the
  moment op/arm/variant prose entered the weave the comment-refs gate
  judged it — 16 never-audited phantoms fired, each trued to 0.
  Named remainder (469): before if/else (286) + before match head
  (126) — expression-position runs needing render sites at the
  if/match projections — plus closer/eof tails;
  Hβ.parser.expr-interior-comment-attach narrows to exactly that.
  CLEAN m2 == m3 at 299,248 lines; census 0; comment-refs 0; frontier
  279/0; proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ IDEMPOTENT-ALL-50 — the fmt fixpoint reached; the
  summit's swap gated by its own comment law (· pin 672a924b). Four
  render roots + one parse canonicalization, each convicted by the
  sweep: the LET-CHAIN FLATTENS AT PARSE (a braceless chain parsed to
  nested per-let BlockExprs while the braced spelling parsed flat —
  two graphs for one meaning; parse_let_expr merges the continuation
  into ONE statement sequence, Law-7 byte-identical); the SURFACE-TYPE
  PROJECTION (the formatter borrowed show_type — the VOICE — and
  leaked `with t45323@e23311` into an effect op's rendered source,
  which pass 2 misparsed into three bogus op declarations;
  render_type_tokens is the parse's inverse, swapped at all eight fmt
  type sites — §5.U's voice/format boundary enforced); a LAMBDA
  OPERAND ALWAYS RE-WRAPS (prec 0 + render_chain_pos at every chain
  head — the recurrence rendered paren-free read back as
  `delay(1)(prev)`); a BODY-LEAD `{` IS THE BLOCK (record
  literal/update as fn/lambda/arm body re-wraps — render_grouped_body
  at five surfaces); INT_MIN renders its wrapping positive spelling
  (the minus accreted one per pass). ORACLES: all 50 wheel files
  format to a byte-fixpoint in one pass; the formatted tree compiles
  census-0, wat value-identical to pristine modulo three CLASSIFIED
  diffs (handle renumbering; the FNV const-fold firing
  order-sensitively — value-identical, banked with band G's
  typed-rulecyclic; yield_from's open-record demand-order offsets —
  the named trecordopen class). THE GATE HOLDS THE SUMMIT: the
  formatted tree DROPS 2,803 comment lines (16.7% of authored prose —
  expression-interior comments consumed as layout,
  Hβ.parser.expr-interior-comment-attach) and doubles >100-char lines
  (572 → 1208, the width-aware layout engine); canonizing prose
  destruction is forbidden by the weave's own law, so the SWAP gates
  on exactly those two builds. The voicey carry leg re-banked to the
  surface-canonical spelling (authored byte-identical). CLEAN
  m2 == m3 at 298,159 lines; census 0; comment-refs 0; frontier
  279/0; proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ THE TWO READERS AGREE — parse_float goes correctly
  rounded, one float projection survives, and list_set's flat contract
  goes loud (the fmt summit's idempotence sweep forced all three roots ·
  pin ea643e6c). The summit's 19 non-idempotent files were ONE mechanism,
  three liars, each convicted by probe: parse_float paid one rounding per
  fractional digit (rebuilt: ONE f64-integer mantissa accumulation —
  exact through 2^53, every authored literal — + ONE scale by the exact
  power of ten; proven EQUAL to IEEE division at the probe, closing
  Hβ.runtime.parse-float-correctly-rounded over the exact-mantissa
  range); the render normalization divided by an UNREPRESENTABLE
  negative power (0.3's scaled arrived 2.9999999999999996, a whole ulp
  off — negative exponents now MULTIPLY by the exact positive power);
  and the root under the root — the shortest ascent's rounded-last bump
  list_set a PUSH-BUILT digits list, and list_set computed FLAT
  addresses for every tag, writing the digit over the snoc's PARENT
  POINTER: the round-last arm was dead since birth (measured:
  list_set(push(make_list(0),2),0,3)[0] == 2; index 1 on a two-element
  snoc "worked" by layout coincidence). list_set's base now REFUSES a
  structured tag loudly — the documented contract enforced, the census
  instrument for any other violator (the board ran clean: one instance
  existed). With parse correct, the shortest oracle parse(cand)==f gives
  the assembler's own verdict on every short candidate — so
  float_to_str_bits DELETED whole, the emit boundary reverts to
  float_to_str, and the wheel's f64 constants are TRUE to their authored
  spellings for the first time (the fixpoint was structurally blind to
  this: the wat text was the fixpoint object while values drifted from
  intent — the m2/m3 TRANSITION's 76 lines are the corrections crossing
  one generation). Probe battery: 0.3/0.995/6.02/2.5/1.0/100.5/0.001
  all canonical-short; 0.1+0.2 = "0.30000000000000004"; READERS-AGREE.
  Named residue: Hβ.runtime.float-render-17-digit-exact (the unverified
  nd=17 tail's float-stepped extraction — never reached by a lexed
  literal, whose own spelling is a short witness). TRANSITION m3 == m4
  at 296,456 lines; census 0; comment-refs 0; frontier 279/0;
  proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶ FMT RUNGS 1·2·4 — the render register of the voice
  stops lying (pin 7215e8c2). The with-clause renders the SIGNED
  TRIPLES verbatim (connector per entry, per-entry !, instance args
  through show_eff_arg — the diagnostics voice and the formatter now
  speak the SAME arg projection, one home), replacing the closed-row
  rebuild that destroyed 41 declared rows as «invalid-effect»; the
  handler renders read the TYPED closed projections (the bypassed
  cure — every handler decl trapped before); authored -> RetTy
  carries (91 heads were dropping). Three RED-first legs (voicey):
  behavioral 42, verbatim carries, byte idempotence; frontier 279/0;
  CLEAN m2 == m3 at 295,930. THE VOICE FRAME (Morgan's charge, made
  structural): fmt is ONE REGISTER of the medium's voice — the same
  projection machinery reading the graph back to the human at three
  registers: diagnostics NARRATE (spans, Reasons, quick-fixes), fmt
  RENDERS (the canonical shape — layout as projection is what keeps
  human text and graph truth in byte-agreement, so every downstream
  span/patch/census points at stable text), teach/tighten/the ??-fan
  PROPOSE. The daily loop: write loosely → the medium normalizes +
  narrates + proposes. Rung 3 LANDED same day (pin a0172f04 —
  render_if_branch supplies braces EXACTLY ONCE: the parser wraps a
  braced branch in a BlockExpr and the old render's literal braces
  accreted a wrap per pass until the inner pair re-parsed as the
  record pun; else-if renders bare; the implicit-unit else renders
  nothing — the identity; the voicey leg asserts no accretion).
  Rung 5 LANDED same day (pin 5ad4aef6 — the
  render goes TOTAL over the weave: the block final's prose renders
  via the one render_stmt_comment projection, and attached prose
  forces the block layout at an if branch; parser.mn 809 → 623
  comment lines kept, 77% from the census's 68%, and the file
  formats clean where it trapped; the remaining drops classify to
  the expression-interior positions the parser never attaches —
  Hβ.parser.expr-interior-comment-attach, a parser refinement, not
  render debt). Rung 6 LANDED same day (pin 997e42f5 — the
  shortest faithful render whose oracle is parse_float itself, the
  lexer's own conversion; en route the probe named
  Hβ.runtime.parse-float-correctly-rounded: parse_float's naive
  digit/scale summation disagrees with the assembler's
  correctly-rounded reader — parse_float("0.3") != the wat-born 0.3,
  measured — so the EMIT boundary keeps the bits-faithful
  seventeen-digit projection (float_to_str_bits) until the parse is
  correctly rounded, and digit_at's false zero-pad doc became true
  at the one reader). ALL SIX RUNGS LANDED; the SUMMIT (whole-wheel
  fmt → census 0 → fixpoint → formatted source canonical, retiring
  the 778) is the next fmt arc.
- 2026-07-25 · ▶▶ HANDLER-CONFIG DEFAULTS + THE BASE-FRESHNESS
  CONTRACT + THE PUSH (pin 9de2ecc4). The product law lands at the
  handler decl: config goes [String] → [TParam] — the fn-param
  carrier itself, ONE default representation (the fifth slot), ONE
  fill (resolve_call_args), zero second mechanisms; parse mirrors
  parse_one_param's scalar face; defaults type in the handler's own
  scope under a DefaultReason edge; the formatter renders them back.
  Four-face fixture (bare fills / explicit / no-parens / labeled
  skip) = 42; frontier 276/0. Fleet-built, cherry-picked three-way
  onto live main, re-derived (one stale-base tax: a row predating the
  intern era, widened; the numbering TRANSITION crossed in the same
  march). THE PROCESS FIX the day demanded: the worktree machinery
  had based builders on a snapshot ELEVEN PINS stale — root cause
  consistent with basing on origin/main, unpushed since 7cc859ae —
  so (1) tools/base-check.sh is every builder's mandatory first
  action (the brief pastes main's sha; stale = rebase-or-abort,
  never build), reified in CLAUDE.md's dispatch law; (2) four stray
  worktrees from prior sessions pruned after verifying absorption;
  (3) main PUSHED (54 commits, 7cc859ae..fd406556) and staying
  pushed — an unpushed origin is a stale base factory. NAMED
  CASH-OUT now unlocked: the eleven config-quadruple install sites
  (graph_handler ×9, env_handler ×2) collapse to bare installs with
  decl-site defaults. NEXT per Morgan: the fmt ladder (the formatter
  is the anti-drift instrument — canonical projection makes layout
  mechanical), rungs 1–2 first (the signed-triple row render and the
  typed handler-arm reads — the same disease families root-fixed in
  the compiler today).
- 2026-07-25 · ▶▶ THE TYPE NAMESPACE REFUSES — the last named
  silent-MERGE class closes (fleet-built, transplanted, re-derived ·
  pin 3f4fba83). Two `type X` decls in one namespace silently MERGED
  — ctors tag from 0 per decl, a cross-tag match returns the wrong
  arm, zero diagnostics (measured RED: exit 13 where 99 was honest).
  E_DuplicateTypeName ARMED AT BIRTH (decl-site licence, blob census
  0 at arming); refuse_duplicate_type_decls claims every type head in
  a WALK-LOCAL seen-set (never an env probe — a multi-variant decl
  registers only ctor names; cross-walk re-registration is the
  two-pass judge's own legitimate shape); both registration walks run
  it (trial absorbed by diag_quiet, final reports). Frontier
  refuse-dup-type leg PASS; 273/0. Same pin arc, two singles landed
  inline: THE UNSEEDED-OVERFLOW GUARD (pin ed5dc82b — the bracket
  refutation's F1 hardened on the live arms: an overflow with
  mint_high 0 is an unseeded branch cursor and traps loudly instead
  of minting handle 0 over the shared Module root) and the
  fleet-builder's HANDLER-CONFIG DEFAULTS landing complete in its
  worktree (commit 572e487b — TParam carrier reuse, one default
  representation, one fill through resolve_call_args; four-face
  fixture 8/16/6/12=42; TRANSITION m3==m4 in-worktree; TRANSPLANT TO
  MAIN PENDING, with the eleven-site bare-install collapse as its
  cash-out and the inherited earlier-param-default lathe-lag noted).
- 2026-07-25 · THE ARM-SPEC DESIGN REFUTED — a proven negative
  redirects the payload arc (no code shipped; the fleet's adversarial
  pass, orchestrator-re-derived from the micro sources). The named
  successor Hβ.lower.arm-payload-specialization (spec-twins at handler
  arms) could fix AT MOST 3 of the six 134-banked micros: the floors
  SPLIT — payload/payload2/payloaddirect floor inside the ARM fn (the
  arm is the medium's last "named generic compiled once at the decl's
  floor" — install-independent, proven by an inline-perform probe
  still trapping), while payload3/4/5 floor in MAIN on the
  handle-result read ((run() ~> hold).beta) with word-shuttle arms no
  arm machinery can reach; THAT root is the row representation's
  fragment drop (two ops of one effect performed in one non-install
  frame: the name-set union's by-name dedup drops the second
  fragment's args outside install frames — the instance-crossing
  landing's own "join by position" gate, measured by four probes:
  both-inline 2, single-op-through-boundary 2, two-ops-one-callee
  134, two-ops-two-callees 2). REPLACEMENT, two landings completing
  EXISTING channels, ordered L1 → L2:
  Hβ.effects.same-name-fragments-coexist (L1, fixes 3/4/5): same-named
  EParameterized fragments COEXIST in the row — dedup by full identity,
  not by name — until the install reconciles them (§4③'s own "the
  handler is where the single instance is established";
  unify_instances_to already iterates every fragment; only the
  representation starves it). Compat gate: heterogeneous performs of
  one op under ONE install become an honest install-site type error;
  the fold-over-[Int]+[Float] caller is the green control.
  Hβ.emit.arm-under-install-instantiation (L2, fixes payload/2/direct):
  the arm emits under its installs' instantiation — demand channel =
  the STATIC LHandleWith sites (the install is the one place the
  instantiation is total; perform-site routing REFUTED — the singleton
  tier bakes arm calls into arbitrary intermediate fns), pairs = the
  handler env scheme's inst-var roots against lookup_ty of the install
  value, through the EXISTING spec bracket + field_sel_offset;
  all-installs-agree (the dominant case) = one arm under one bracket,
  no twin, no routing; divergent + floor-sensitive = a LOUD compile
  refusal naming the divergence (strictly better than the runtime
  134); divergent + plumbing stays floored-and-correct (the
  heterogeneous-install control runs green today). Also refuted en
  route: per-DECL monomorphization (heterogeneous installs of one
  plumbing handler are legal and live), runtime field-by-name (drift
  8), annotate-the-param as the resolution (the standing charge's own
  words; it survives only as a legitimate authored Intent Boundary).
  The six micros' 134 expectations are the RED gates; three of their
  comments carry the wrong diagnosis (polymorphic-op — actually the
  fragment drop) and true with L1.
- 2026-07-25 · ▶▶ THE OVERLAY FAMILY DIES WHOLE — the fleet's first
  executed census, and the C1b dividend undershot (pin 6913e09d). The
  recon-overlay agent's complete consumer census found the per-module
  overlay index DEGENERATE: graph_fork had ZERO perform sites for the
  structure's entire life (orchestrator re-derived before acting — the
  pipeline law), so overlay_count was forever 1 and every mint fed one
  "global" row whose only reader chain dead-ends at an op with zero
  performs. DELETED whole: five state fields, the per-mint
  overlay_register_at write (~200k × [2 index reads + extend + 3 sets
  + a tuple alloc] per self-compile, off the hottest write path), the
  graph_fork op+arm, five fns, the eager overlays_to_pairs build on
  every snapshot (20 sites; 19 ignored it), the Graph middle field
  (→ Graph(next, span_index)); checkpoint 12 → 7 fields, restore
  10 → 5 (a smaller fork value for the C1c fan). The ONE real reader
  — QueueItem.module_path, a construction-time SNAPSHOT of a live
  fact — rewires to the live read: filter_by_module keys on
  module_path_of_span(parse_span_of(pos)), NModule span containment;
  the fn moves to graph.mn (DAG-homed beside parse_span_of).
  Resolves Hβ.graph.fork-dead-code as DELETION. Named residue:
  Hβ.oracle.module-queue-live-key — when a doc-batch surface first
  performs query_module_queue, the live filter's O(next) NModule scan
  takes its O(1) form (the handle-indexed span weave + the plan's
  stmt→range projection); build WITH that first performer, never
  before. Wheel 621 lines smaller. CLEAN m2 == m3 at 294,395 lines;
  census 0; comment-refs 0; frontier 272/0; proof-exactness 9/9;
  crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ RESOLVED OR LOUD — the trecordopen-wrong-field
  silent-wrong class CLOSES (the field-access cluster's emit half ·
  pin 723220b3). resolve_field_offset's open-record arm resolves the
  FULL field set through the row residual the graph already carried
  behind the row var (open_record_full_fields — NRecordRowBound,
  chained open rows, or a closed bind, canonically sorted via the
  parser's own sort) and floors -1 when any tail is genuinely free —
  never again a prefix-sum over the partial demanded set. THE BYTES
  SHOWED THE FIX BOTH WAYS (the 31-line m2/m3 crossing): offset=0
  loads became offset=4 — LIVE wrong-slot reads in the wheel itself,
  healed — and unprovable floors became correct reads through the
  residual. THE NINE RED MICROS WERE THE FIX WORKING: the payload
  ladder (2026-07-01's diagnostic rungs) had CANONIZED the wrong-slot
  values — payloadfn's own comment carried "Expected value when
  fixed: 2" since birth, and the banked 1 was alpha read through
  offset 0. Re-banked: payloadfn/hoflambda/mapfield at the true 2;
  the six genuinely-free-tail arms at the honest 134 floor (silent
  wrong → loud), with the named successor
  Hβ.lower.arm-payload-specialization — the spec-twin machinery at
  handler arms closing the op-payload residual per instantiation (a
  polymorphic op's arm is the same demand-analysis shape as a named
  generic; until then the floor is the truth). With the judgment half
  (the unify arm, pin f0ab3177) this closes the LAST known
  silent-wrong class on the board. TRANSITION m3 == m4 at 295,451
  lines; census 0; comment-refs 0; frontier 272/0; proof-exactness
  9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶ THE NOMINAL SATISFIES THE ROW — a canonical SYNTAX
  form stops lying (the field-access cluster's judgment half · pin
  f0ab3177). Morgan's audit charge ("what's named? what's avoided?
  any fundamentals not ultimate?") surfaced the cluster this session
  had WORKED AROUND twice instead of root-fixing: nominal-record
  field access. Probed RED on the artifact first: `p.age` on a
  let-bound Person raised a false E_TypeMismatch (Person vs
  {age: t | r}) on SYNTAX's own documented form — while emit resolved
  the offset correctly, the judgment lying about correct code — and a
  row-polymorphic {age: Int, ...} parameter refused a Person
  outright. THE FIX IS A LIVE-EDGE READ, not a patch: unify's TName
  arm gains the TRecordOpen case — a nominal record satisfies a
  structural field demand by its own declaration, read through
  nominal_record_fields (the THIRD reader of RecordSchemeKind beside
  the literal check and the ctor arrow view; one channel, three
  readers), delegating to unify_record_open_against_closed (zero new
  unifiers). The brand never erases: the TName side stays bound, only
  the demand's field vars and row residual bind; a CLOSED structural
  demand still refuses (exact-shape identity is the brand's point).
  Both probes heal to 42; two frontier legs registered RED-first;
  frontier 266 → 272/0. CLEAN m2 == m3 at 295,191 lines; census 0;
  board whole. The cluster's EMIT half stays named with its design:
  trecordopen-wrong-field — a receiver still GENUINELY open at emit
  computes offsets over the partial demanded set (silent wrong reads;
  the fix resolves through the row residual or refuses loudly, never
  a partial-set offset).
- 2026-07-25 · THE PAGE PRE-OPEN — the fan's band opens become
  unraceable (Phase C rung 1 step C1c-2c opening move · pin
  3a53f775). graph_mint_plan pre-opens every band the plan touches,
  sequentially, before any planned walk — a branch cursor then only
  writes cells, never opens a band, so page opens cannot race by
  construction. CLEAN m2 == m3 at 295,016 lines; board whole. THE
  JOIN PROTOCOL, derived and banked in the mirror for the bracket
  build: every branch-local mutable fact (diagnostics, env publishes,
  affine consumes, verify debt) returns as a DELTA replayed into the
  root in stmt order at the join — collisions and refusals re-detect
  deterministically at the replay, so branch instances stay fresh and
  the sequential judgment reproduces exactly; the bracket proves
  itself byte-identical SEQUENTIALLY before any thread runs it.
- 2026-07-25 · THE ENV VIEW — the branch cursor's second leg lands
  Law-7-inert (Phase C rung 1 step C1c-2b · pin d8c42e3a).
  env_handler gains the base triple (base_buf, base_count,
  base_index): a branch installs over the root's shared entries as a
  read-only BASE — its extends land in a fresh private buffer that
  dies at the join, publishes re-applied through the root in stmt
  order — while the root passes the empty base, so root resolves stay
  one-level. The four lookup arms compose the EXISTING env_resolve
  family as private-then-base Option fallbacks (zero new resolve
  machinery); a branch snapshot appends the private prefix to the
  base view. CLEAN m2 == m3 at 294,988 lines; board whole. Remaining
  C1c-2 rungs: the collecting diag branch instance, page pre-open at
  graph_mint_plan, the branch bracket proven byte-identical
  SEQUENTIALLY, then the fan.
- 2026-07-25 · THE CURSOR CONFIG — the branch-cursor substrate lands
  Law-7-inert (Phase C rung 1 step C1c-2a · pin 3f4262bc).
  graph_handler gains config (spine0, spine_open0, next0, limit0): a
  parallel branch cursor installs over the SHARED spine table with a
  private planned range; the nine root installs pass the empty graph
  explicitly. State records live in shared heap, the install chain
  stays per-instance — the spawn substrate's own shape. Probed en
  route: handler-config DEFAULTS don't parse (the parameter-product
  law implies them — parse_arg_names takes bare names; the lathe-lag
  named, the explicit quadruple honest until that turn). CLEAN
  m2 == m3 at 294,873 lines; board whole. C1c-2's remaining rungs,
  design banked in the mirror: the env-view config (branch reads the
  shared buffer, private extends die at join), per-branch diag
  collection re-reported in stmt order, pre-open the plan's pages
  before the fan, and the fan itself gated on byte-equality with
  C1c-1's sequential layer walk.
- 2026-07-25 · ▶▶ THE LAYER-ORDERED FINAL — the fan's execution shape
  runs sequentially, and the fixpoint proves walk-order convergence
  (Phase C rung 1 step C1c-1 · pin 406e4d2a). The trial's own reasons
  ARE the stmt DAG: every reference it resolved drew a VarLookup
  Reason, so a stmt's edges are the VarLookup names over its trial
  range — read through the new graph_reason_at (the unchased reason
  cell, the Why engine's raw read), never a second AST walker (the
  40-arm walker copy refused; lower's reach walk stays DAG-forbidden
  from infer). Only BACKWARD edges order the walk — a forward fn ref
  resolves to the trial's published final scheme, and the genuinely
  order-coupled stmts (top-level lets) precede their dependents in
  source — so depths compute in ONE ascending pass, the layer graph
  is acyclic by construction, and a missing edge (destructured let,
  unnamed stmt) degrades to source order, never a reorder-before-dep.
  The final pass walks LAYER BY LAYER with source-order pre-assigned
  bases: numbering stays plan-determined; only the judgment order
  changes — to exactly the order C1c-2's `>< ~> parallel_compose`
  fan will run concurrently. The march's verdict is the finding: the
  reorder is TRANSITION-grade (1,228 emit lines differ between the
  source-order and layer-order judgments) and SELF-STABLE (m3 == m4)
  — walk-order convergence proven by the fixpoint, the same gate the
  concurrency will be held to. The medium refused two of this
  landing's own first forms en route (census-named: LetStmt's pat is
  a bare Pat, and the affine judge rejected let-_-then-reuse
  threading at both walkers — thread list_set's return). TRANSITION
  m3 == m4 at 294,828 lines; census 0; comment-refs 0; frontier
  266/0; proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶ THE PLANNED MINT — the deterministic handle partition
  goes live, sequential-planned (Phase C rung 1 step C1b · pin
  c53dd17b). The trial IS the sizing oracle: each stmt's mint count is
  the graph_next delta around its trial inference — a fact the graph
  already carries, read at the stmt boundary, zero instrumentation —
  and the final pass mints each stmt into a pre-assigned dense range
  [base, base+count), bases prefix-summed from the final's own
  post-prepass frontier. The numbering is a pure function of the
  source through the trial's determinism: EXACTLY what the parallel
  fan (C1c) must reproduce, which is its byte-equality gate — landing
  sequential-planned first splits the numbering TRANSITION from the
  concurrency, so the fan marches as a NO-OP diff against this pin.
  Three graph ops carry the plan (mint_plan / mint_at / mint_seal —
  none touch the trail: the plan is numbering, not mutation); a mint
  at a range's ceiling jumps deterministically to the open space
  above the plan and clears the limit; an under-measure stmt leaves
  virgin gap cells absorbed by the word-face guard on graph_node_at
  (the C1a Cast read's second consumer). THE DESIGN CORRECTION that
  made it this small: the banked per-decl BAND encoding (handle =
  band<<14 | slot) died to arithmetic — sparse handle space forced
  eager-page memory (1.8GB at decl grain), 15 range-iterator
  migrations, and guard complexity; the landed form keeps handle
  space DENSE and decouples the partition (a numbering plan) from
  the storage (C1a's pages) entirely — zero iterator changes, zero
  storage changes, ~90 lines. C1c's remaining prerequisites, named:
  pre-open the plan's pages before the fan (spine_ensure once,
  sequentially — cursors then write cells only, race-free by
  construction) and the per-cursor overflow rule (requeue the decl
  for a sequential post-join re-run — deterministic, the rare path).
  TRANSITION m3 == m4 at 292,882 lines (the 6,586-line m2/m3 diff is
  the planned numbering crossing one generation); census 0;
  comment-refs 0; frontier 266/0; proof-exactness 9/9; crown 5/5;
  micros 114/114; 5.57s median / 515MB — flat.
- 2026-07-25 · ▶▶▶ THE PAGED SPINE — six weaves become one page record,
  and the graph stops moving (Phase C rung 1 step C1a, Law-7-inert ·
  pin 0e3af09c). The six handle-weaves (nodes, program, comments,
  canon, narrowing, boundaries) dissolve into ONE structural record
  per band — six 16,384-slot columns allocated whole at band-open
  (sized by the measured mint distribution: max 2,305/decl, p99 331),
  written in place, never relocated. DELETED: graph_extend_to + the
  NFree gap-fill (pages need no fill — a virgin cell is the absent
  contract: mint-density guards nodes by `next` alone, program and
  comments guard the cell's word face through the Cast read, canon
  and narrowing read 0 as no-edge, a boundaries 0 IS NoBoundary at
  nullary tag 0), the five per-weave extend+set+rebind arms (an
  in-place cell write rebinds NO state), the seventeen-field
  checkpoint (→ twelve fields, the spine contributing two words:
  band table + open count), undo_set_within + the spine-merge
  restore semantics (rollback = restore the COUNT + a plain backward
  in-place trail walk; in-fork bands close by count, their cells
  stale-and-overwritten at the next open — the trail's own
  logical-length discipline one level up), the Graph snapshot's
  zero-reader nodes and epoch fields (every destructure ignored
  them), and current_overlay (a write-only cache of names[idx]).
  The fork-spine class (the boundaries[23] stale-spine trap, the
  seventeen-field snapshot's whole reason) is UNCONSTRUCTIBLE: a
  page that never moves cannot dangle, and a spine snapshot stays
  valid across mints. One trap en route, pinned against the binary
  then named as its class: the page read's inferred open-record
  receiver computed field offsets over the partial demanded set —
  `.nodes` read offset 0, the boundaries column, GNode destructure
  of a boundary word (trecordopen-wrong-field, measured live) — and
  the judge REFUSED the first nominal-record fix with 12 exact
  E_TypeMismatch sites (nominal TName vs the open-row field demand),
  forcing the honest form: the page is STRUCTURAL (mechanism, not a
  branded value), closed at the one annotated projection
  (spine_page's return). MEASURED: 5.49s median / 511MB RSS —
  neutral time inside the variance band, flat memory (+5MB = 13
  bands × 384KB exactly), the doubling-copy churn gone. CLEAN
  m2 == m3 at 291,710 lines; census 0; comment-refs 0 (the ratchet
  caught five of this landing's own backticked narrations); frontier
  266/0 through the paged rollback; proof-exactness 9/9; crown 5/5;
  micros 114/114. C1b next: bands become DECL-grained (handle =
  band·16384 + slot, a TRANSITION), which makes overlay membership a
  band-range projection and the enclosing-decl edge an O(1) read.
- 2026-07-25 · ▶▶ THE FORK TRIPLE — R6 closes the world arc, and the
  interleave shows its first live witness (Phase C rung 0 · pin
  09b95e50). Every candidate fork restores THREE legs — graph
  checkpoint, heap region, WORLD — at all three fork sites (the synth
  fan's two loops; try_each_annotation, half a pair since birth, gains
  its heap AND world legs). world_restore lands as the fork boundary's
  world reset (a substrate op, NOT a general setter — its one sound use
  is a value world_top() returned at the fork point, predating every
  push the forked extent made; the world's other writers stay the
  emitted pushes and bracket restores), crossing recognition in the
  two-generation dance the crossing constraint demands — the gate
  REFUSED the single-step form (E_EffectUnhandled: Memory at the root)
  exactly as the world_top precedent says, and the law is now paid at
  the substrate-op altitude twice. The world leg had held by
  extent-balance alone — an accident-invariant made a contract before
  the parallel fan (rung 3) needs it per-cursor. THE INTERLEAVE
  WITNESS, counted: landing the heap leg at try_each_annotation
  trapped the field leg in intern_probe — a candidate's
  intern_str("Alloc") FIRST-inserted its canonical row IN the region,
  the reset zeroed it, the next candidate's probe walked garbage (and
  teach-pure-control's severed-name proposal died of the same root).
  THE CONTRACT: the intern is DURABLE state; a fork extent must never
  first-intern. The pre-warm (the severed-effect names interned once
  below the fork marks) makes every in-fork intern a pure probe hit —
  stated at the site, and banked as the two-channel design's first
  measured case (durable-vs-transient inside one extent — exactly what
  the §5.O image/scratch split exists for). CLEAN m2 == m3; census 0;
  frontier 266/0; proof-exactness 9/9; crown 5/5; micros 114/114.
  Phase C's remaining rungs: the deterministic handle partition (the
  keystone, shared with native), the parallel compile spine, the fused
  oracle.
- 2026-07-25 · ▶▶▶▶▶ THE ORDER-INDEPENDENT JUDGE GOES LIVE — phase B-ii
  COMPLETES its payoff: the two-pass walk re-wires into compile_stdin,
  self-hosts, and costs ~12% (pin 5b693139). The re-measure law paid
  twice today: the banked recipe re-landed and self-compiled with NO
  OOM on the first try (the morning's arena strikes had already
  un-gated it — the arena demoted from gate to amplifier for the
  SECOND time), and the first timing (24.5s, 5.2× over single-pass)
  fell to 5.3s through four cuts the landing itself forced, each
  caught by a gate or a probe: (1) TypeVariants — the type's own env
  entry CARRIES its variant specs, minted at registration where the
  list is in hand; the whole-env backward scans (46% of the two-pass
  compile once the env doubled — perf named variant_specs_filter_from
  at 45.9%) deleted whole; the entry registers BEFORE the ctors so a
  same-named single-variant ctor shadows it in value position (the
  585-error refusal that taught the order — `Instant(ns)` resolving
  the arrow-less type entry), and the read is the kind-filtered walk.
  (2) The env walk family UNIFIED: the three predicated bucket walks
  are ONE env_bucket_pos_where over top-level predicate fns passed as
  static closure pointers — zero allocation (Morgan's "lookup? 8
  interrogations" cut: the fourth copy of the validated-continue shape
  was drift-7 at the env layer); the plain hottest-path resolve keeps
  its own predicate-free shape deliberately. (3) The trial is a WORLD
  of its own — fresh affine/region/verify ledgers die with its
  bracket. (4) THE CLASS EXPOSES ITS MOST-REFINED MEMBER (the
  representative-choice projection the alias-preserving peer
  prescribed, written at the decl's own ret pin): the ann-pin's unify
  peels the wrapper into the class, so generalize published PEELED
  finals and every caller's edge raised an undischargeable copy of a
  proof the decl already carried — four spurious `self == 7` pends on
  the capability fixture the moment finals resolved (the ledger-speak
  probe named every one); the rebind makes the refined form the
  representative, generalize publishes refined finals, and callers
  inherit the decl's proof — debt 0. THE JUDGMENT ITSELF: verdicts no
  longer depend on declaration order anywhere on the stdin path;
  the emitted wheel is ~40k lines SMALLER than the single-pass wheel
  (finals prune what looseness padded); 5.3s / 506MB RSS. CLEAN
  m2 == m3 at 290,409 lines; census 0; frontier 266/0; proof-exactness
  9/9; crown 5/5; micros 114/114. B-ii's residue: the step-4 decl
  regions (infer +91MB walk, lower +99MB) remain the arena's remaining
  shares — amplifiers now, gating nothing.
- 2026-07-25 · ▶▶▶ THE WORTHINESS CLOSURE — the demand analysis' 274MB
  monster dies, and the gate caught the fix's own first form
  under-approximating (the arena arc's second strike · pin a9d0fb45).
  The chain, each step measured: spec_resolve went CHECK-THEN-BUILD
  (A.3's exact shape — the eager walk re-cloned every fully-concrete
  site type at ~1e5 reference reads; the change-walk is raw-recursion
  loops per the battery law, closures allocate; ~29MB); the sub-seam
  probe then pinned spec_worthy_fix at +274MB — every ROUND re-scanned
  every candidate's whole body TWICE and re-minted every interior
  site's mangled name, though BOTH facts are ROUND-INVARIANT (sensitive
  depends only on the body+pairs; the interior twin-name edges only on
  the body+ctx). THE FUSED FORM: one body scan per candidate — inside
  spec_candidates_fix's own transitive closure — yields the inner
  candidates, the sensitivity witness, and the interior edges; the
  worthiness fixpoint is then a pure name-set closure over facts
  (closure_fix's species, the incremental cursor's sibling — zero
  scans, zero mints per round); spec_worthy_fix / spec_worthy_pass /
  spec_candidate_sensitive / spec_candidate_calls_worthy deleted whole.
  THE CATCH, counted as the kill it is: the first fused form ran the
  sensitivity witness UNDER the instantiation ctx — the witness's own
  law says "at the floor, no substitution: the var-ness is exactly what
  the floor emission sees" — ctx masked every var, the wheel
  under-emitted 17k lines of twins, and the address-comparison
  miscompile class RE-OPENED; the float frontier leg convicted the
  unblessed intermediate (exit 1, the silent-wrong made loud), and the
  witness moved ctx-clear while interior keys stay ctx-set (ONE
  structural scan, TWO lookup contexts — stated at the site). MEASURED
  on the corrected sound build: self-compile 6.78s → 4.71s (−31%), RSS
  728MB → 407MB (−44%), every twin kept. Combined with the morning's
  emission regions, the day's arena strikes: 6.4s/754MB-bump →
  4.7s/407MB-RSS with Law 7 or the fixpoint held at every step.
  TRANSITION m3 == m4 at 332,604 lines; census 0; frontier 266/0;
  proof-exactness 9/9; crown 5/5; micros 114/114. The arc's remaining
  named shares: infer +110MB and lower +99MB (the step-4 decl regions,
  the genuine interleave), then the two-pass re-wire rides.
- 2026-07-25 · ▶▶ THE EMIT PHASE JOINS THE ARENA — measure first, then
  the region (phase B-ii steps 1+3 open · pin 8ea44a73). The watermark
  probe named the image's true shape: post-read 11.8MB → parse 66.4 →
  infer 176.0 → saturate 178.0 → lower 277.5 → reach 307.8 → EMIT
  753.8MB — emit owned 59% of the whole self-compile image. The
  sub-seam probe split it exactly: spec_demands_of ALONE +362MB (its
  own "zero new storage" comment refuted by the artifact — the
  comments-can-be-wrong law with a number), record collection +15MB,
  the per-fn emission churn ~54MB. THE CUT LANDED: emit_functions
  built EVERY fn's full text before writing one byte (map-then-each —
  the entire module's emission materialized simultaneously); each
  record now builds → streams → resets under its own heap region, and
  the twin loop, wide wrappers, and fold-leaf families ride the same
  bracket — the compile spine's first per-fn regions, the battery's
  arena pattern at the emit phase. MEASURED: emission's allocation
  share fell to ~0 (pre-fns 699.0MB → post-fns 699.03MB); Law 7 held
  BYTE-IDENTICAL (allocation addresses never reach the wat, proven not
  assumed). The bracket's standing contract at the site: per-fn
  metadata handlers (body_context and kin) overwrite before any read,
  so a dangling region pointer is never read. The arc's next strike is
  NAMED WITH ITS NUMBER: the 362MB spec-demand churn (the per-site
  instantiation walks), then infer's +110MB and lower's +99MB — the
  step-4 decl regions. CLEAN m2 == m3; census 0; frontier 266/0;
  proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶▶ THE INCREMENTAL CURSOR — PHASE B-i COMPLETES (§2's
  cached-cursor mode cross-run; landing 3 · pin dfe19175). Patch one
  module of a DAG: the next compile restores the image, names the exact
  cone ("warm: re-deriving b main" — a cached), re-judges ONLY the cone
  into the restored world, and re-persists — the image tracks the tree
  edit by edit, and the emission is BYTE-IDENTICAL to a cold compile of
  the patched tree (the frontier's strongest oracle; the pure-warm third
  run answers "image current — nothing re-derived"). The mechanism is
  the swap-parameter dissolution completed: the image carries its OWN
  manifest, entry name, and per-module statement buckets as typed roots
  (warm_manifest / warm_entry / warm_asts), so the post-swap path takes
  ZERO pre-swap heap arguments; the current tree reads fresh off the
  host fs (files survive the swap by nature); re-registration shadows
  the stale entries (the env's latest edge wins) and the entry is
  ALWAYS in a nonempty cone (every DAG module is one of its transitive
  deps). MORGAN'S MID-BUILD CUT — "8 interrogations" — found two
  Carried-Truth violations the green byte-equality probe could not see:
  warm_root was a STORED FLATTEN of warm_asts (the derived value
  persisted beside its source — deleted; warm_program() is the read),
  and the incremental path walked the module tree THREE times (the
  pairs pass, the deps pass, the order pass — fused into ONE
  driver_tree_scan whose three consumers are projections). Two classes
  paid en route, both catalog entries firing live: the POINTER-EQ class
  twice (module_in / manifest_hash_of compared erased elements at the
  word floor — every module "changed" and NONE joined the cone, the
  probe's own "warm: re-deriving " empty line the tell; `: String`
  Intent-Boundary pins carry the proof until name-is-handle retires
  str_eq), and E_DuplicateFnName DECOUPLED from the env into the
  registration walk's own seen-set (the env-based check misread a prior
  judgment's entry as a duplicate the moment the cone re-registered —
  exactly the flaw the two-pass build named yesterday; its banked
  decoupling is now the landed form, and the incremental cursor is its
  first consumer). Honest bounds stated in place: the fixture's
  byte-equality is exact because it is lambda-free (lambda names carry
  handles; the deterministic handle partition, Phase C's keystone,
  generalizes it); the split-by-ranges attribution reads the weave
  fold's own carried product (the zero-reader per-module overlay
  machinery belongs to the retired per-module check walk, not
  fake-ridden); cone diagnostics carry file-local spans — sharper for
  the user than weave lines. CLEAN m2 == m3 at 330,626 lines; census 0;
  frontier 266/0 (twelve TIME legs); proof-exactness 9/9; crown 5/5;
  micros 114/114. B-i's remaining felt tier — the edit-session as a
  persisted value — rides Phase D's living session on exactly this
  substrate.
- 2026-07-25 · ▶▶▶ THE RESUME VERB + THE FINGERPRINT DISSOLUTION — the
  image IS the process, and the interrogation deleted a gate (phase B-i
  landing 4 · pin 99ecf00d). `mentl resume <image>` re-enters a
  persisted compile image and emits with the SOURCE ABSENT — the
  frontier leg deletes main.mn and the emission stays byte-identical:
  the projection rode the image, absence is the proof. THE RESTRUCTURE
  THAT MADE IT SOUND (the eight interrogations refusing the obvious
  port): the resume verb under the arm-form rehydrate would have needed
  the resuming process to replicate the persisting process's install
  AND allocation prefix (its argv alone shifts every chain-node
  address) — the fingerprint contract generalized to an unmeetable
  demand. The root: an effect-arm restore puts ONE dispatch bracket's
  pre-swap world write on the trust path. rehydrate DISSOLVED into
  image_resume — the restore as a direct substrate call — and with it
  every remaining pre-swap-saved world write fires in the benign tail
  (extent-ends after the last perform) while every post-swap dispatch
  walks the RESTORED $world_g: the world is image-resident end to end,
  and an image is resumable from ANY same-build process, any argv, any
  chain. The fingerprint, its walk (world_fingerprint /
  fingerprint_bytes), its wire field, and the morning's own
  install-prefix-correspondence law are DELETED — superseded by
  structure, not softened (the ⚖ alive-law: the measurement that
  binds rewrites the law in place; this morning's landing-1 entry
  reads as the era's record). The wire is [key][k][size][gcount]
  [globals][image]; the corruption legs pin both remaining guards RED
  (build-key refusal naming both keys; corrupt-gcount tripping
  $image_restore's layout belt). compile_remainder is the ONE home for
  the projection half — cold, warm, and resume all run exactly it (the
  three routes cannot drift); the verb rides the VerbSpec table with
  its own raw-path builder (an image is a file, never a module). The
  convergence loop en route: the sharper judgments named
  driver_compile_entry's missing Fail/WASI and image_resume's
  Filesystem-vs-WASI truth (the _impl substrate face, the persist
  policy layer's own convention) — census 0 → 1 → 0 twice, the ratchet
  refusing each intermediate. CLEAN m2 == m3 at 330,542 lines; census
  0; frontier 263/0 (nine persist/warm/resume legs); proof-exactness
  9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ THE WARM START — the compile restores its own analyzed
  image (phase B-i landing 2 · pin 28eb3444). driver_compile_entry keys
  the weave (every DAG module's text hashed in canonical order — the
  prelude seed rides the same list the analysis weaves — mixed with the
  build key), and on a CLEAN analysis persists the whole rooted image
  into the project's .build; the next compile of the same weave probes
  both wire gates COLD-SIDE (a stale or foreign cache falls back to
  re-derivation instead of refusing; rehydrate's own gates stay the trap
  beneath), restores, and lowers the live graph — frontend and inference
  skipped whole (Hβ.persist.module-image-cache's first real form; the
  dirty case re-derives honestly because the diagnostics ledger rides
  the image as counts, not replayable prints). The typed re-entry is
  warm_root — a top-level cell the globals record restores; the compile
  chain grew ~> persist_to_disk ~> fail_exit. THE GATE (frontier
  warm-start, RED before the landing): cold run persists and emits;
  warm run prints the warm line and emits BYTE-IDENTICAL WAT off the
  restored image — the strongest oracle the seam admits, and it held
  despite the two runs lowering from different heap lines. TWO LAWS
  PAID FOR EN ROUTE: (1) VIRGINITY IS THE RESTORE'S CONTRACT
  ($heap_reset_impl's law at the image altitude) — $image_restore zeroes
  [image-extent, old-bump): the restored line rewinds, so the resuming
  process's dead pre-swap heap must read never-allocated, or
  post-restore allocations serve stale bytes as unwritten slots.
  Measured through five probe rounds (count the kills): the warm
  saturate walk chased a garbage operand into list_index's i<0 bounds
  trap (the 0x100000000 signature); the record, its canon spine, and
  node 3389's cells all probed BYTE-FAITHFUL live-vs-wire before the
  dead-region channel isolated by elimination; the two-process fixture
  had survived only by allocating almost nothing post-swap — an
  accident-invariant named a contract (forensic law 5). (2) A PREAMBLE
  FIX CROSSES A GENERATION — the executing $image_restore is the
  EMITTING compiler's preamble, so every probe of the fix through the
  boot-emitted m2 ran the OLD form (the pattern-fill experiment
  included; its assertion failure was the tell); the fix first executes
  in m3's own body. The crossing constraint, already law at the
  recognition layer (world_top), now named at the PREAMBLE altitude so
  no future substrate-preamble fix is probed a generation early.
  Residue banked: the cache is compile-seam only (check/at/teach ride
  driver_entry_with_ranges — landing 3's per-module IC generalizes);
  the wire doubles the image transiently at persist (the arena's
  scratch channel absorbs it). TRANSITION m3 == m4 at 331,274 lines
  (the 2-line crossing is the restore preamble); census 0; frontier
  260/0; proof-exactness 9/9; crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ THE ORDER-INDEPENDENT JUDGE'S HARVEST — the two-pass
  walk rebuilt, converged to judge-ZERO, measured, and its fifty
  findings landed while the machinery unwired (phase B-ii step 0
  closes · pin 6965d5bb). The banked design built clean in one pass:
  a diag_quiet handler (all three Diagnostic ops armed) absorbs the
  TRIAL pass, whose one product is the env holding every fn's FINAL
  scheme; the FINAL pass re-judges fresh nodes with every reference —
  forward included — resolving those finals (fn pre-registration
  skipped: infer_fn's unbound-handle arm self-registers monomorphic
  recursion; the duplicate-fn refusal decoupled into its own seen-set
  walk). THE JUDGE CONVICTED THE WHEEL of ~20 real order-masked
  wrongs, 50 errors → 0 across five convergence rounds, every fix
  valid under today's judgment too (boot census held 0): abs was an
  IDENTITY on negative floats (its `0` literals pinned Int -> Int
  while all three callers — the dsp envelope/peak/flux family — pass
  Float; each forward site unified loose while the compiled body
  word-floored); infer_unaryop string-matched "Neg"/"Not" against the
  parser's UNeg/UNot ADT — no arm ever matched, and the deleted
  catch-all fabricated `!x` as its operand's type instead of Bool;
  the formatter's five chain arms matched PipeExpr at the wrong
  altitude (ast_kind_of projects NodeBody; every chain fell to the
  non-chain render — the render-totality arc's own arms, dead since
  birth); autodiff under-dimensioned its matrix ([Float] at the op
  decl AND the tape field; transpose named the truth); the
  record-literal field carrier is the parser's (name, value) TUPLE —
  oracle's three literal arms read .init off tuples (the 6807a214
  claim corrected; resume updates alone are records); the str-raw
  satellites (driver count_lines, main's line helpers, lsp_frame's
  whole header family) re-typed through byte_len/byte_at with
  read_headers_until_blank gaining its str_of_buf boundary; list_eq's
  loop un-crossed altitudes (list_index_unchecked, the f64 siblings'
  form); driver_check_module's if arms agreed on (); with_run exits 1
  on its unbuilt verb; and ~35 declared rows widened to their bodies'
  truth (the widen loop 13 → 22 → 18 → 6 → 2 → 0, automated per-round,
  two multi-line heads hand-fixed per the never-mangle rule). THE
  MEASUREMENT THE STEP CHARTERED: the judge-0 wheel's m3-leg
  self-compile still dies — alloc's wraparound guard at
  emit_wide_wrappers, ~28s, 1.1GB RSS with the 4GB bump extent
  exhausted — so the two-pass OOM verdict is CURRENT, not stale
  (unlike seq-op's), and the machinery unwired whole (drift-9-clean:
  zero dead code stays). Banked on the peer: the working build recipe,
  the convergence protocol (fix the JUDGED source under the standing
  judge, rebuild the judge, repeat), and the DEP now measured at the
  exact site — the arena's image/scratch split, or wasm64's ceiling
  lift. En route kills, counted: the first error map skipped
  wt_wheel's tutorial exclusion (all src lines shifted — the
  one-binary/one-blob forensic law at the map layer); the second
  drifted +7 after the abs fix edited the blob under it. TRANSITION
  m3 == m4 at 330,255 lines (the 14-line crossing is infer_unaryop's
  corrected graph); census 0; frontier 258/0; proof-exactness 9/9;
  crown 5/5; micros 114/114.
- 2026-07-25 · ▶▶▶ THE ROOTED-IMAGE PERSIST — persist = memcpy made real,
  proven by a fresh process (phase B-i landing 1 · pin 88c1b888). The
  image [0, heap-line) plus the mutable-global record IS the whole
  program state (wasm call frames live engine-side), so the emitter now
  projects three facts of a module over ITSELF, emitted only when the
  reachable tree performs an image op (Law 7 — the wheel stays
  byte-identical): $build_key (a hash of the fn table names, interned
  data, and mutable-global census — exactly the three same-build-only
  word classes a restored image's baked words depend on; the key IS the
  compatibility contract, no over-refusal), $globals_save/$globals_restore
  (the census record, slot 0 the heap line, wide feedback slots at their
  own repr), and $image_restore — globals from the wire FIRST (the wire
  may lie inside the image range), then ONE memory.copy of the image
  over [0, size): memmove semantics make the overlapping self-copy
  exact, so the staged-scratch choreography the first design carried
  DELETED ITSELF (the law smiling: less code). persist.mn sheds the
  record-copy prototype whole — persist(k, path) drops the caller-
  supplied size (heap_mark reads it live), the wire is [key][k][size]
  [fingerprint][gcount][globals][image], and rehydrate refuses through
  TWO gates: the build key, and the world fingerprint RE-PURPOSED by
  interrogation — the first design deleted it as vacuous (the world
  rides the image), then the unwind walk resurrected it: the restore
  happens INSIDE a perform's dynamic extent, every enclosing dispatch
  bracket writes back a pre-swap world address as it unwinds, and those
  addresses are valid exactly when the resuming process reached
  rehydrate under the SAME install prefix (same build + deterministic
  bump ⇒ same addresses) — the name-level fingerprint is that contract,
  checked, an accident-invariant made a contract before it ever fired
  (forensic law 5 ahead of the crash). The declared-unwired
  E_ResumeWorldMismatchWorld DELETED (wire-or-delete resolved: refusal
  rides fail; the cross-world-resume class dissolves when the world is
  image data). The typed re-entry channel is a restored top-level ROOT
  — leg B reads A's thunk through the restored let global, fully typed,
  and the no-from_addr law holds untouched (rehydrate's returned word
  is the belt beside it, tied by Cast's addr). GATES at all four
  corners: leg A persists mid-computation (exit 40, ~1MB wire); leg B —
  a FRESH PROCESS of the same wasm — passes both gates, swaps A's image
  in, chases three A-heap records (root list → thunk record → captures)
  and runs A's thunk (exit 42); a corrupted key refuses naming both
  keys; a corrupted fingerprint refuses naming both worlds. Counted
  kill en route: the first gate probes corrupted disk+8/+20 believing
  an on-disk header exists — fs_write writes the PAYLOAD, the file IS
  the wire; both "gates failed" verdicts were the prober violating the
  protocol it probed (forensic law 2), dead in one re-read. RED on the
  pre-image boot (unrecognized substrate ops → compile refusal, zero
  WAT). Board whole at the pin: CLEAN m2 == m3 at 330,102 lines;
  census 0; frontier 258/0; proof-exactness 9/9; crown 5/5; micros
  114/114. B-i's named remainder: the warm-start cache (landing 2),
  per-module IC on the overlay write-half (landing 3), `mentl resume
  <img>` re-projecting at the saved caret with the source absent
  (landing 4), and session-as-value as the felt gate.
- 2026-07-24 · ▶▶ THE SEQ-OP ROW UN-REVERTS — re-measurement, not the
  arena, un-gated it (phase B-ii step 0 · pin 7aa2d7a0). The B-ii recon
  banked the verdict: both OOM rulings were one representation era
  stale (measured on the 559k-line wheel; the current wheel compiles at
  ~694MB against the 4GB ceiling — 6× headroom). The 2026-07-17 revert
  re-ran on the current pin: infer_seq_op reads the callee's OWN
  declared row live (graph_chase(fh) — the read its own comment
  prescribed for a year), the Memory floor surviving only for an
  unresolved callee. NO OOM at the m3 leg; the honest-attribution
  compiler immediately re-judged its own source and named NINETEEN
  under-declared rows (the widen loop, 19 → 3 → 2 → 0: str_slice,
  fs_path_view, chase_probe_tag, show_span, the whole synth
  candidate-mint family) — the honest wheel lands 3,600 lines SMALLER.
  CLEAN m2 == m3 at 329,046; census 0; board whole. The arena demotes
  from keystone to amplifier; the two-pass walk's re-measure is the
  remaining step-0 item. Recon reports for BOTH phase-B halves are
  banked in the campaign mirror (persist: rehydrate is dead code, the
  world-mismatch raise unwired, the emitter can generate
  $globals_save/restore, four RED-first landings specified; arena:
  the image/scratch two-channel design, the interleaving hazard map,
  the fork-pair sweep find at try_each_annotation).
- 2026-07-24 · ▶▶▶▶ THE TSTRING DISSOLUTION LANDS WHOLE — PHASE A
  COMPLETE (A.4 steps 4+5 in one arc · pin 5673c47c). The nullary
  TString ctor is DELETED from Ty; "String" IS one canonical
  TAlias("String", TList(TByte)) node in THE CANON (src/canon.mn, the
  new one-home for shared canonical nodes — born when the census named
  25 forward references: top-level lets are not pre-registered, so the
  canon sorts early; order-independent-lets is the named dissolver and
  the ef_pure_row shared form's future home). Every mint flipped
  (parse_type_atom, four infer binds, eighteen face rows); the
  unify/same_ground string arms, both already_string probes, and every
  H6 scalar row deleted whole — the compile-guided sweep, census-named
  at 26 → 0 across two rounds; BConcat strips first; synth's
  byte-element dispatch keeps String holes proposing string literals.
  The sentinel's own comment carried its retirement: the OOM died with
  A.3's sharing, partial migration with the one shared node.
  TRANSITION m3 == m4 at 332,555 lines (the 6,336-line crossing is the
  type-representation change); census 0 at every generation; frontier
  254/0 — every string-oracle leg green through the TString-free
  compiler; crown 5/5; micros 114/114. §4①'s "String IS [Byte]" is now
  a fact of the Ty ADT itself, not a claim bridged by special arms.
  Named residue: the String-hole proposal leg (oracle gap 7, the
  edit-harness shape) and the order-independent-lets capability.
- 2026-07-24 · ONE TYPE, ONE HASH (A.4 step 3 · pin 540eb950).
  hash_node_of's list arm goes element-face: a byte face hashes as
  TEXT (str_hash), the projection a String field always took — the
  hash route split dies (one type, one hash fn), and the reach seed
  mirrors the route. The scalar-faces oracle leg held green through
  the change (its pins were deliberately route-agnostic). CLEAN
  m2 == m3 at 333,019 lines; board whole.
- 2026-07-24 · ▶ THE TSTRING DISSOLUTION OPENS — recon banked, oracle
  wave landed, the dead arms delete (A.4 steps 1–2 · pin e213ce1b).
  The Fable recon (worktree snapshot, self-adversarial re-grep) found
  the fact the 2026-07-20 attempt lacked: EVERY backend fold dispatch
  strips, so fold_strip(TString) = TList(TByte) makes the emit's
  TString arms DEAD-BUT-AGREEING — and form (ii) is forced (delete
  the ctor; "String" = one shared canonical TAlias("String",
  TList(TByte)); H6 exhaustiveness turns every missed site into a
  compile refusal, the anti-absorption mechanism itself). Two
  pre-existing diseases surfaced: the HASH ROUTE SPLIT (top-level
  hash(s) → list_hash, a String FIELD → str_hash — one type, two hash
  fns) and [String] element == word-comparing at concrete sites. STEP
  1: three oracle legs pin today's routes (scalar faces / aggregates /
  the : String annotation boundary — the fixpoint is structurally
  blind to string-route regressions; the wrong [String] == is
  deliberately NOT pinned). STEP 2: thirteen dead arms delete whole —
  census confirmed no exhaustiveness loss, CLEAN m2 == m3 at 332,942
  lines (280 smaller), and the string battery ran green through the
  arm-less wheel. REMAINING: step 3 (hash-route unification + BConcat
  strip-first), step 4 (mint flip under peel-coexistence + the synth
  byte-elem proposal arm + the C fixture), step 5 (ctor deletion,
  H6-compile-guided sweep). The full corrected design is in the
  campaign mirror.
- 2026-07-24 · THE VOICE SPEAKS ITS PAYLOADS (two #9 render singles ·
  pin 10b79aa8). show_eff_arg's EAType arm renders the instance's real
  type via show_type — the cast-refused crucible's message now carries
  the live payload where an opaque marker sat — and show_pred_operand
  gains the call-shaped arm, so len(self)/abs(x) predicates render as
  calls. callee_name's sentinel is load-bearing, untouched. CLEAN
  m2 == m3 at 333,222 lines; board whole. Banked en route: a
  len(self) > 0 ground refusal still pends at Verify (the
  ground-decidable fragment does not fold len — band F's fragment
  growth, distinct from the render class).
- 2026-07-24 · IDENTITY IS THE FIRST STRUCTURAL FACT (the eq
  short-circuit · pin 3d862357). The generated $eq_<sig> helpers open
  with one word compare — the same record equals itself — before any
  field conjunction or tag load; list_eq/list_eq_f64 say the same fact
  in their raw bodies (identity is the value-faithful reading even for
  a NaN-holding sequence self-compare). Sound unconditionally,
  effective wherever canonical instances flow — the intern made that
  the common case for names. TRANSITION m3 == m4 (the 20-line diff is
  the two preambles crossing one generation); board whole; ~6.4s.
  Named residue: str_eq's typed body cannot say pointer identity —
  the String == identity path is a one-fn emit-wrapper strike. The A.4
  adversarial mint-enumeration recon is DISPATCHED (Fable, worktree
  snapshot) — its report opens the TString dissolution arc.
- 2026-07-24 · THE CAST VOCABULARY — the word-face capability, zero
  readers by design (A.5 · pin 394917cf; phase A closes except A.4's
  own arc). effect Cast { addr(a) -> Int } lands beside effect Memory
  (the substrate home RTLIBS and the wheel both see); lower erases the
  perform to its operand — identity at the word level, zero emission —
  so the substrate is the handler, no census demand reaches the
  executable gate, and the ROW carries the whole meaning: with Cast
  admits, a declared !Cast severs. No from_addr up-cast exists, ever
  (str_of_buf stays the one localized coercion). Crucibles seen at
  both poles: cast-addr proves word-face facts through the erase (42;
  RED on the pre-Cast boot — the op lowered as a handler-less demand
  and the gate refused the executable) and cast-refused proves the
  severance REPORTS at the declaration, E_EffectMismatch naming
  !Cast vs Cast(<type>) — the A.6 bare-name-matches-instance handle
  compare doing exactly its job. Two truths banked from the probe:
  E_EffectMismatch is NOT an armed refusing class (the
  reference-memory "user-effect !E hard-refuses" claim describes a
  different tier; arming the class is the refusal-law's licence-gated
  landing, named here so it is never smuggled in as a rider), and the
  parameterized instance renders its payload as `<type>` (the
  E_RefinementRejected `<expr>` render class's sibling — the residue
  queue carries both). CLEAN m2 == m3 at 333,002 lines; census 0;
  frontier 245/0; board whole at the pin. The first consumer is the
  arena-gated signature-driven seq-op landing (B-ii), where raw
  bodies gain authored signatures and rows become true by inference.
- 2026-07-24 · INSTANTIATE SHARES, NEVER CLONES — landed in its second
  form after the artifact killed the first (A.3 · pin 6d6ac5ab; the
  superseded first-form pin 0bb49387 stays in the PROVENANCE chain as
  the counted kill). subst_ty and chase_deep_at are CHECK-THEN-BUILD:
  a Bool change-walk (word returns — zero allocation) gates the
  original eager arms, which recurse through the sharing face so
  unchanged sub-subtrees re-share at every level; find_mapping's
  per-leaf filter materialization is a plain walk. THE KILL, counted:
  the first form flag-threaded (Ty, changed) tuple returns — and
  tuples are heap records in this substrate, so every scalar arm
  minted a record where the eager walk minted none; measured +6%
  (6.42s → 6.82s medians, three runs each, same wheel through both
  boots) with RSS flat — the panel priced the sharing but not the
  flag's carrier. The check form measures NEUTRAL (6.51s median,
  inside the reference band) and allocates nothing on unchanged
  paths; max RSS stays ~717MB because the self-compile's peak lives
  in lower/emit, not this channel — the sharing's real purchase is
  HEADROOM for the TString alias dissolution (A.4), whose type-node
  bloat multiplies through exactly the instantiate channel. CLEAN
  m2 == m3 at 332,964 lines; census 0 at every generation; board
  whole at the pin.
- 2026-07-24 · ▶▶▶ EFFNAME IS A HANDLE — identity becomes a contract
  (A.6, the crown cash-out · pin 91e35f1e). ENamed(Int) |
  EParameterized(Int, [EffArg]); EPure = the absent 0. The
  ripple-killer the adversarial panel missed: the projection SPLITS —
  eff_name_handle (Pure, the comparison key: the six by-name str_eq
  leaves go word i32.eq, and bare-vs-instance matching is the same
  compare) beside eff_name_str (render-only, intern_name_of), so the
  dreaded row widening never touches the hot family — only the few
  cold render sites widened (eff_names_to_str, row_to_with_clause,
  catalog_handled_effects, eff_name_label). The intern grew
  intern_str + intern_name_of + entries (the reverse read arriving
  WITH its reader), and intern_table moved OUTERMOST in the core: the
  report arm renders diag_message live and an arm's performs resolve
  outer to its install (R2's law at the core order — an inner intern
  left diagnostics' row rendering handlerless). THE SWEEP WAS
  MEDIUM-NAMED: 12 → 2 → 1 → 0 across four compiles, every typed site
  an armed E_TypeMismatch naming its own line. THE BLIND SPOT the
  census structurally cannot see, the FIXPOINT caught: eff_names_of
  ("effect-row names as bare strings") pushed the raw handle word
  into lower's ERASED string list — no type meets an erased list —
  and the m3 leg trapped in the escaping fixpoint's set_insert where
  str_lt walked a tiny address into a garbage make_list. One
  projection renders the boundary now; the lesson is the two-oracle
  law made concrete: the armed census gates the typed surface, the
  self-application leg is the net beneath the erased one. MEASURED:
  crown 5/5 with the positive-path residual (~146 byte-equal-but-
  pointer-distinct false mismatches) closed BY CONSTRUCTION (the pair
  is untypeable; a missed mint is a loud type error — the contract
  the intern's masking lacked); CLEAN m2 == m3 at 330,661 lines
  (handle assignment is a pure function of the source); frontier
  241/0; proof-exactness 9/9; micros 114/114; census 0; 6.9s
  self-compile (the row-mint probes cost ~0.3s against exactness —
  honest, and the token-carries-handle cut removes them). NAMED
  RESIDUE, each its own strike: TName's String names are the same
  disease at the TYPE layer (type_name_eq's str_eq pin sits in
  unify's hot path — the sequel identity cut); TIdent still DISCARDS
  the handle lex returns (token-carries-handle unlocks env keying,
  §5.O layer 2); instance-precise negation
  (Hβ.effects.parameterized-negation-instance) stays the banked
  follow-on with its own crucibles.
- 2026-07-24 · ▶▶ THE INTERN SUBSTRATE — a name is born once (A.2, the
  phase-A spine · pin 66e097e9). effect Intern { intern_span } +
  intern_table land as the analysis core's innermost handler (every
  chain's lex runs inside the bracket): one row per unique identifier
  — (canonical String, handle, keyword kind) — hashed over the source
  RANGE, compared by the new str_eq_at, keyword-classified ONCE at
  first sight; a repeat occurrence returns the SAME String pointer
  with its banked kind — zero allocation, zero keyword compares (the
  row-carries-kind form beats the refuter's 18-i32.eq floor: no
  per-occurrence compare at all). The planned declared-row sweep never
  fired — the frontend chain's rows are all inferred, so Intern flowed
  to the bracket's absorption with ZERO census errors on first
  compile. THE MARCH RULED TRANSITION (592 lines) AND THE ARBITRATION
  FOUND A HEAL, NOT A LEAK (the refuter's Law-7 expectation was wrong
  in premise, and its own accident-class warning was the mechanism):
  the capture walk's dedup (set_contains, lower.mn:5009) compares
  names WITHOUT a String proof — pointer identity — so boot's
  per-occurrence slices double-captured twice-mentioned free names
  (index_of's search captured sublen TWICE; counted in the m2 WAT, 2
  reads vs m3's 1); canonical instances make that dedup byte-accurate
  and 36 wheel fns' closure records shrink. Named forward: canonicity
  MASKS the identity-sensitive compare class within a lex session —
  an accident-invariant, not a fix; a runtime-constructed name still
  pointer-misses. A.6's Int handle is the contract; the by-name-leaf
  census instrument rides it. MEASURED: 6.42s → ~6.0s; str_eq 5.85%
  → 4.0%; intern machinery below the profile floor; m3 == m4,
  census 0 at every generation, board whole at the pin. Self-build
  delta: the medium refused nothing and named nothing this landing
  because there was nothing to name — the armed classes and the
  fixpoint arbitration did the reviewing a human would have.
- 2026-07-24 · THE STALE-BUCKET FALLBACK WAS THE SCAN — env_find_flat
  DELETED whole (phase A's fourth strike · pin 3d2b029c). The comment
  called the stale-bucket case rare; the profile priced it at 5.85% —
  every scope re-entry reuses positions, so env_resolve's
  first-hit-then-bail shape ran the O(n) scan constantly.
  env_bucket_pos validates against the buffer INSIDE the walk (the
  type/ctor siblings' shape) and continues past stale pairs; complete
  by construction (every env_extend adds its pair; pairs are never
  removed), so the fallback is unreachable and §5.O's documented
  villain dies as LESS code. CLEAN m2 == m3 at 330,057 lines (50
  smaller); self-compile 6.42s — 15.56 → 6.42 across the day's three
  strikes, 70.58 → 6.42 (11×) across the campaign's perf arc. The
  medium's own verdicts gated every step (census 0, comment-refs 0 at
  each generation — the prose about the deleted fn died with it).
- 2026-07-24 · THE PATTERN PATH FOLLOWS THE ENV'S OWN EDGE (phase A's
  third strike · pin 8ba823f5). ctor_payload_tys_of re-derived a
  constructor's entry by scanning the whole env snapshot backward per
  LPCon bind (6.86% of the self-compile; a pinned str_eq the untyped
  snapshot tuple forced) — while the env's bucket index already drew
  the edge. env_lookup_ctor lands as the THIRD kind-filtered read
  (env_lookup_type's exact validated-walk shape, predicate =
  ConstructorScheme); the snapshot scan and its pointer-eq essay die
  whole. CLEAN m2 == m3 at 330,107 lines; ctor_payload_tys_find gone
  from the profile; ~8.5s → ~7.2s. The re-profile names the next two:
  env_find_flat at 5.85% is NOT the rare stale-bucket case its comment
  claims — env_resolve validates only the FIRST bucket hit and bails
  to the O(n) scan on staleness, where the type/ctor siblings validate
  INSIDE the walk and continue; folding the validation in makes the
  fallback unreachable and deletes env_find_flat whole (§5.O's
  documented villain). The ceremony residue (list_index_unchecked
  20.8%, len 12.6%) is now call volume itself — caller-side hoists or
  emit inlining, banked for the phase's re-measure.
- 2026-07-24 · ▶▶ THE CEREMONY FUSE — 15.56s → 8.46s (1.84×; 8.35×
  across the two perf landings), and phase A's design survives its
  adversarial panel CORRECTED (· pin cec0f2df). THE PROFILE FIRST (the
  campaign's measure-first law, third strike): host perf on the
  post-crc compile put the sequence header ceremony on top —
  seq_stride 9.4% + seq_tag 4.5% + decode_stride 4.2% +
  load/store_strided 5.8% raw, paid per element by
  list_index_unchecked (18.3%) and the fill walks — while the
  documented instantiate/subst_ty/find_mapping cluster sampled ~0%
  (its cost is ALLOCATION volume, the OOM channel; the sharing fix
  gates on an alloc count now, not a profile line). THE FUSE is the
  carried-truth law at the representation layer: the accessor-call
  form read the SAME tag word three times per element; the fused
  arms read it once and derive both projections locally — the word
  fast path is a single load, concat/slice recursion derives no
  stride at all, list_set keeps the byte range-trap and the wide
  copy-protocol through store_strided, and the flat_fill family
  collapses to native mem_copy for flat-to-flat ranges (three
  per-element strided loops became one bulk copy each; snoc fills
  derive their stride once per node). Uniform stride through a fill
  is the construction law (flat_raw allocates with the tree's own
  sc; sub-nodes carry the parent's), stated at the site. Lib-source
  only: CLEAN m2 == m3 at 329,959 lines, census 0, battery green,
  frontier/proof-exactness/crown/micro-tier green at the pin. THE
  PANEL'S PHASE-A VERDICT, banked as the corrected design: the
  `with Cast` body sweep REFUTED outright (masked by the seq-op
  Memory hardcode, self-deleting under tighten's T_OverDeclared
  authorship, inconsistent across the cascade — phase A lands
  `effect Cast { addr }` + lower-erase + RED-first crucible as
  ZERO-READER vocabulary, the RI8 precedent; the body sweep moves to
  the arena-gated signature-driven landing where rows become true by
  INFERENCE); the intern is a NINTH core handler in infer_context
  (string_table's install covers only 3 of 14 chains), emit offsets
  stay VISIT-ASSIGNED (pre-seeding = ~300KB dead-name bloat + an
  O(U²) dedup gate; the intern handle is compile-scoped, the offset
  its emit-time projection — two reads of one row), and A.2's gate
  expectation INVERTS to Law-7 byte-identical (an observed
  TRANSITION means lex state leaked into emit — a bug signal, not a
  crossing); the subst_ty changed-flag means "returned value differs
  from the input record" (an NBound resolution always reports
  changed — the shape-preserving reading; the freshened-only reading
  silently hands consumers unresolved TVar subtrees), and chase_deep
  is the SECOND unconditional reconstructor the alias dissolution
  must measure; ENamed's representation is FORCED to the Int handle
  (surface == on Strings is byte-compare by the structural law, so
  the String pick cannot deliver i32.eq; a missed mint becomes a
  loud type error — the enforcement the mint-law convention lacked,
  with six constructed-name families the design had missed); persist
  is SAFE either way (world_fingerprint hashes name BYTES from the
  image). Two traps named for the build: nested infer_context
  brackets must not shadow the intern (or handles never cross a
  bracket — the contract, instrumented at the three by-name leaves:
  a byte-equal-but-handle-distinct pair fires the census); the
  intern op's row ripples through lex_from into every chain body
  (plan the declared-row sweep, the ++-carries-row precedent). A.0
  doc-truths landed with the fuse: the §5.O instantiate anchors
  (2687/2840 → 4185/4351), the stale string_offset O(n) claim (it
  is O(1)-bucketed; the phase-A move is birth-at-LEX), the six-
  waypoint claim trued to its converged state (smap carries the
  infer/lower indexes; env_index and the emit string table are the
  two hand-rolled survivors), the band-B anchor (3174 → 5023), and
  graph.mn's checkpoint comment (thirteen → seventeen words).
  BANKED from the same profile, the next strikes: ctor_payload_tys_find
  6.86% + variant_specs_filter_from 0.61% are ONE scan family (a
  backward str_eq walk of the whole env snapshot per pattern bind /
  per variant read at EMIT — env_find_flat's sibling, itself 3.39%);
  the fix is one name-keyed read on the emit state serving both,
  Law-7 byte-identical expected.
- 2026-07-24 · ▶▶ THE PROSE GATE COST FIVE COMPILERS — 70.58s → 15.56s
  (4.5×) from one flatten (the campaign's measure-first law paying within
  its first hour). Host perf on the self-compile (the §8 recipe) showed
  83% of ALL wall time inside comment_refs_check → crc_scope_at: the
  backtick checker's scope list was snoc-spined and list_index walks the
  spine per read, so every commented handle paid O(scopes²) spine steps —
  while every documented perf target measured as noise (env_find_flat
  0.53%, str_eq 0.47%). The fix is the iterate-flattens-once precedent:
  crc_fn_scopes' result flattened ONE time before the per-comment scans.
  No code-reading estimate had ever named the site — the third time
  (after the classifier and the reachability scan) that the dominant
  O(n^k) was invisible to static reading. The remaining profile is
  representation ceremony (seq_stride/seq_tag/decode_stride header
  decodes per element access — the carried-truth question at the list
  altitude, Phase A/B's re-measure target). The README-transcript session
  that rode this also surfaced, each banked in the residue queue: the
  user-path diagnostic flood (every `mentl check` prints the SHIPPED
  lib's own T_OverDeclared/RedundantBraces warnings — the tighten/fmt
  sweep's felt face), the chained-comparison refinement degradation
  (SYNTAX's own canonical `-1.0 <= self <= 1.0` parsed ill-sorted and
  silently pended — SYNTAX trued to the `&&` form at three sites, the
  loud rejection arriving with predicate-is-expr), the `<expr>` operand
  render in E_RefinementRejected's message, and the `??)`-span slop in
  the address projection. CLEAN m2 == m3 expected (a compiler-internal
  perf change; the march arbitrates).
- 2026-07-24 · THE SCOREBOARD THAT NEVER FIRED, FIRED (the completion
  campaign's opening move — instruments before arcs; no re-pin, tools
  only). march-gate --micros read a `micro:` registry that was EMPTY for
  all 85 revisions of verify-baseline.txt — a gate that could not fail,
  gating nothing since birth (the 8458415b note's "since the backtick
  sweep" attribution refuted by the git census). The tier now enumerates
  tests/micros/mn-*.mn and reads each micro's OWN `// expect:` first-line
  oracle — the one home verify.sh already reads; the registry doc is
  deleted. Every verdict now stamps the sha of the m2 it judges: the
  first firing ran a stale prior-pin probe and reported the pre-fix
  20-not-25 — exactly the forensic one-binary law — and the stamp makes
  that class self-identifying. Against the true m2 (sha == boot ==
  8891428f, the fixpoint literal): 114/114.
- 2026-07-24 · ▶▶▶ THE FANOUT SPAWNS FOR REAL — the task record lands
  whole and `>< ~> parallel_compose` runs branches on host threads over
  ONE shared image (band E's real-spawn claim made true; the
  runner-migration peer's banked RED dies · pin 8891428f). THE ROOT was
  never four bugs: the spawn crossing had no unit of state — spawn
  banked the host thread id while join dereferenced it as a record, the
  entry wrote completion/result words past the closure's allocation, the
  start argument was a sentinel zero, and a spawned instance re-read a
  fresh zeroed image. The TASK RECORD answers all of it at once:
  [task closure@0][completion@4][result@8], allocated per spawn through
  the ONE allocator ($spawn_task_impl — loud refusal on a host spawn
  failure; no static slot region, no capacity ceiling, no tid ledger),
  banked whole in ThreadHandle, joined by $join_task_impl's atomic wait.
  The rewritten $wasi_thread_start stamps per-instance identity
  ($tid_g — current_id's truth source; a per-instance global IS
  instance-local storage), runs $__init_lets when lets exist (globals
  are per-instance; the copies land in fresh shared-cell records), and
  invokes the task through the closure protocol. TWO OWNERSHIP READS AT
  THE MODULE-IMAGE ALTITUDE, both from the program's own proof
  (spawn_task ∈ the fifth projection): a spawning module IMPORTS the
  shared image (the wasi-threads convention, re-exported for the p1
  ABI — a defined memory is per-instance, so a child of a defining
  module reads a fresh zeroed image) and allocates through the shared
  CELL at address 64 (compare-exchange bump; root _start initializes it
  once); a thread-free module keeps its self-contained defined memory,
  plain bump, and ships NO thread-spawn import at all — the
  must-satisfy-thread-spawn instantiation constraint the recon named is
  DISSOLVED for every non-spawning program, boot included.
  heap_mark/heap_reset went strategy-invariant at the call site
  ($heap_mark_impl beside $alloc; the reset writes the line where the
  strategy keeps it). THE DELETIONS: threading.mn 355 → 160 lines — the
  whole ffi/sentinel/intrinsic block, closure_pointer, the
  done-past-the-captures address arithmetic, the write-only threads
  ledger (the resume_kinds pattern at the schedule layer), num_cores
  (preview1 exposes no processor count — an op with no truth source is
  a fabrication; the spawn degree is the fanout's own branch count),
  and the wasi_threads handler whole (its spawn arm was bypassed by the
  direct route since Stage 4a); the dormant emit_memory_atomic_cas
  handler (byte-identical to bump — the strategy fork was never in the
  emitter) died into the emit_memory_decl body fork. The wheel's own
  dispatch chain dropped its dead schedule installs: a standing
  parallel_compose install would put the spawn arm's performs into the
  wheel's emitted tree and flip the wheel itself to the shared-image
  shape for parallelism it never performs (zero `><` in the wheel) — a
  schedule installs lexically at the fanout it schedules (SYNTAX §`><`:
  no Schedule → Seq). TWO LATENT SURFACE BUGS fixed by the same audit:
  WaitResult's decl order now matches the wait32 ABI (nullary ctor =
  tag word = the instruction's result; the old order silently swapped
  not-equal and timed-out), and atomic_rmw gained its real dispatch
  ($atomic_rmw_impl br_table on the RmwOp tag; its old emit was a
  dangling call) with two-operand cmpxchg split into its own honest op
  (the one-operand rmw shape cannot carry expected+replacement).
  GATES seen RED on the prior pin (exit 134, unaligned atomic in the
  join, identically through both engines): frontier real-spawn (60 —
  the sequential twin's exact answer, the §`><` thesis gate: one
  source, two schedules, identical results) · real-spawn-float (60 —
  a spawned instance's f64 carrier allocated through the shared cell
  and read by the joiner: the cross-instance allocation story proven)
  · real-spawn-identity (60 — both branches read positive stamped
  ids). Board whole at the pin: TRANSITION m3 == m4 at 329,774 lines
  (the 36-line m2/m3 diff is the emit change crossing one generation),
  then CLEAN m2 == m3; census 0; comment-refs 0; frontier 241/0;
  proof-exactness 9/9; crown 5/5; battery green through both engines'
  smokes. The named remainder of the runner-migration peer is now ONLY
  the host-path endgame (swap wt-env to the runner, retire the CLI
  pin) — no wheel-side glue remains.
- 2026-07-24 · ▶▶ THE COMMIT'S RECORD RIDES THE __k RAILS — the last
  bracket-maintained cache dies (Hβ.emit.arm-closure-captures-record
  RESOLVED, and the OneShot cousin the pre-build probe surfaced dies
  with it · pin bb4b870e). LStateSlotStore's fourth field is the
  resolved record READ, minted at lower through the __hrec ladder: a
  stateful arm binds `__hrec` as an LLet alias of its own $__state (the
  install record the driver passed; ls_bind_local before body lowering
  so nested mints resolve it), a lambda captures it (lower_seed_hrec —
  lower_seed_k's exact walk-free shape, transitive by induction), and a
  resume-bound fn takes it as the SECOND trailing param after __k (both
  call-site forks append the pair; dead-word 0 where no record is in
  scope — a commit on a dead path stores just before its paired
  k-call's dead-word trap, so the path still dies loudly at the
  resume). With every commit path through the ONE ladder, the
  $<hname>_state_g singleton globals, the install bracket's
  save/set/restore triple, the _prev locals, and the singleton_hnames
  walk family are DELETED — emitted artifacts carry ZERO _state_g, and
  anonymous/named installs are one shape at the install site. THE PROBE
  PAID FIRST: measured on the prior pin BEFORE building, a OneShot
  resume-with-state inside a thunk LOST its commit into the thunk's
  closure record (20-not-25, zero diagnostics; the classifier descends
  lambdas, so the shape is reachable) — the 32-not-46 disease at the
  other discipline, and the uniform ladder kills both (micro
  mn-oneshot-lambda-commit, RED 20 on the prior pin, 25 here). The
  medium caught its builder twice en route — census 0 → 1 → 0 (the
  bind's if-arms Int-vs-(); the arms unify) and drift mode 15 on an
  underscore binder (the residue form is the bare effect-statement) —
  and the comment-refs ratchet surfaced an ACCIDENT-invariant (forensic
  law 5): five backticked prev references had resolved only against the
  doomed _prev bracket locals; unbackticked to prose, ratchet back to
  0. Board whole at the pin: TRANSITION m3 == m4 at 329,794 lines (the
  2,018-line m2/m3 diff is the emit change crossing one generation; the
  new wheel SMALLER than its old-emit form), then CLEAN m2 == m3 with
  the prose fixes; census 0; comment-refs 0; frontier 232/0;
  proof-exactness 9/9; crown 5/5; the commit-class micros 25/46/46/51.
- 2026-07-24 · ▶▶▶ THE SINGLETON TIER READS THE WORLD — R4 completes at
  the last dispatch tier, and A4 un-floors on top (the banked RED pair
  goes green · pin 8458415b). THE ARC: the A4 un-flooring (installs
  TRANSPARENT to the k2 terminus flag; body_has_foreign_yield deleted —
  the frozen world CARRIES what the foreign clause re-derived) took
  mn-world-resume-frozen from its banked 134 to a NEW measured red, 30 —
  the crossing composed but the remainder's emitt read ZERO: the
  singleton tier's direct call read $scaler_state_g, and main's bracket
  had already restored it before the redrive ran the resumes. The k
  record's frozen world (R4's rebind, correctly set by LResumeK) was
  never consulted — the singleton state global is a CACHE of the
  chain-top entry, and every $world_g REBIND (LResumeK, __k_compose)
  invalidates it, not just lexically in remainders but through every fn
  a resume's dynamic extent calls. THE FIX AT THE REPRESENTATION: the
  perform reads the chain. singleton_perform_block's record source is
  LWorldResolve(handle, hname) — a new LowIR leaf emitting
  (call $world_find (i32.const <interned hname>)) — and $world_find
  walks the live chain. THE KEY IS THE HANDLER, NOT THE ENAME (the
  frontier caught the first form red-handed: the LSP serve leg's
  postmortem trapped inside op_mentl_voice_default_focus — the
  ename-keyed find returned the SPLIT-EFFECT pair's chain-top,
  mentl_voice_filesystem's record, to mentl_voice_default's arm; two
  handlers covering one effect's disjoint op sets is exactly what the
  per-hname global was precise about, because the op→handler edge is
  per-OP). The chain node widens to [key@0][entry@4][parent@8][iw@12]
  [hkey@16] — the ename key stays the evidence tier's walk
  (ev_perform_node untouched, persist's fingerprint walk untouched),
  the interned handler name is the singleton find's key, 0 for
  anonymous installs. With it: handler_stateful counts CONFIG params
  (scaler's arm reads the record for f — the config-only guard skip is
  WHY the 30 was silent; the compile gate's refusal conjunct tightens
  in lockstep, one shared fn), the redrive driver uses its own __state
  (both callers always passed the record — the global re-read was a
  re-derivation of a value in hand), emit_singleton_globals shrinks to
  installed-only (the no-config-declared union existed to make the
  dead global.get assemble; noconfig_handler_names deleted), and the
  ten LowExpr walks gained their LWorldResolve leaf arms — named by
  the medium's own census (E_PatternInexhaustive ×10, the exact
  sites), not by hand audit. The $<hname>_state_g global survives with
  ONE reader: the resume-commit store's closure home (arm commits run
  inside their install's live bracket — sound); its retirement is the
  named peer Hβ.emit.arm-closure-captures-record. MEASURED, the whole
  board: TRANSITION m3 == m4 at 331,648 lines (the 17,331-line m2/m3
  diff is the chain read + node widening crossing one generation;
  2,380 lines smaller than the prior wheel), census 0, comment-refs 0,
  frontier 232/0 (mn-world-resume-frozen GRADUATED as a leg — 134 on
  the pre-A4 boot, 30 under the cache read, 42 through the chain; the
  lsp serve leg RED under the ename key, healed by the hname key),
  proof-exactness 9/9, crown 5/5. Scaffold gap noted en route:
  march-gate --micros enumerated an empty promoted tier (CLOSED
  2026-07-24, the scoreboard entry above — the git census refuted this
  note's own "since the backtick sweep" attribution: the registry was
  empty for all 85 revisions of its life).
- 2026-07-24 · THE KEYED SCAN'S LAST CORPSE LEAVES THE SOURCE (the
  foundation cut's second write-side cleanup · pin 9bfcf506):
  ev_lookup/ev_scan — kept one generation for the prior boot's emitted
  LEvRef sites — deleted exactly as their own comment scheduled (zero
  references in the emitted artifact; reach had pruned them), and
  pipeline.mn's grounding comment trued from the dead call-boundary
  evidence-threading justification to the live one (the
  stateful-default zero-state read the SingletonUninstalled guard
  refuses). CLEAN m2 == m3; census 0; comment-refs 0. The keyed-ev
  region's write side is now EMPTY of source.
- 2026-07-24 · ▶▶▶▶ THE EVIDENCE REGION DIES WHOLE + THE FORK KEEPS ITS
  SPINES (the world arc's foundation cut, rung two, landed WITH the
  latent fork-pair root its one red surfaced · pin 612b6589): the
  keyed-ev machinery deleted end to end — LSuspend
  collapses into bare calls (every call direct or closure-conv, the
  evidence fork gone), LFnRef/LEvRef/LEvEntry/LUnresolvedEvidence deleted
  with every walker arm, closures are [fn_ptr][nc][captures] (no region,
  no sentinel), the handler record loses captured_evs, and the k record is
  [fn_ptr][nc][captures][state_idx][ret_slot][WORLD] — the LAST word the
  LIVE $world_g at reify (the static world_tag fingerprint died with
  world_tag_of_row), read by $__k_world at fixed offset 16+4*nc. R4's
  rebind is REAL: LResumeK (the resume invocation's own node) brackets the
  k call in the record's frozen world; $__k_extend stores the inner k's
  world; $__k_compose re-sets at the fk transition. The __resume channel
  is an ARGUMENT: resume-bound fns gain a trailing __k param (the
  resume_bindings closure), call sites append it unconditionally-if-bound
  (resume_k_arg — dead-k word 0 where no k is in scope), and closure
  mints SEED __k whenever a k is lexically in scope (lower_seed_k — the
  walk-free stateless rule after the synth-walk guard refused the
  stateful ls read). The k2 call-boundary wrap migrated from LSuspend to
  LCall/LDirectCall (same can_yield predicate; the __kr_ junction park
  restored after the double-wrap measured 134 on four k-micros). persist
  rewrote whole: signatures drop the caller-passed tags, the wire carries
  a name-level chain fingerprint derived from the record's own world
  slot, rehydrate refuses divergence and patches an equivalent world
  live. ev_lookup/ev_scan stay in source ONE generation (boot's emitted
  LEvRef sites — the ev_perform_entry precedent; delete at the next
  pin). THE ONE RED became the dig, and the dig closed a LATENT class
  as old as the fork pair: capability-hole's edit ACCEPT step trapped
  134 in the re-infer, and TEN labels died to probes before the root
  (count the kills): the yield-flag leak; the real-LYield theory; the
  patched-scratch-file theory; the k2-floor theory (the new wheel
  contains ZERO raise instructions — instruction-form count,
  string-literal contamination excluded — so no floor guard can ever
  pass, and the 5,259 dormant k2 wraps are can_yield over-approximating
  a module that cannot raise: the raise-site absence proof deletes
  them, banked below); the E_DuplicateFnName anomaly (pre-existing
  session-weave noise, 311 in GREEN legs too); the virgin-globals read;
  the nullary-ctor-sentinel decode of the row slot; and finally this
  entry's own banked "a TCont's WORLD field written wrong" — REFUTED:
  no writer existed, the record itself was alien. THE MEDIUM NARRATED
  ITS OWN DEATH (Morgan's redirect, feedback-medium-diagnoses-itself —
  stop hand-probing; make the medium speak): emit_match_arms'
  exhaustive fallthrough became the in-scratch POSTMORTEM — scratch
  word 0 = the failing cascade's own scrutinee ($scrut_tmp, exact by
  construction since nested matches re-set it), word 4 = the match
  node's graph handle baked as a code constant
  (Hβ.emit.trap-as-exception-postmortem's larval form; every
  ill-sorted destructure in every future build self-identifies) — and
  the crash-branch probe called the wheel's OWN projections instead of
  raw-offset decoding: lookup_ty through $lookup_ty_graph_state_g into
  show_type, graph_chase's reason into show_reason. The narration:
  finalize_continuation_boundaries' fatal slot was boundaries[23]
  holding a pointer to the interned ": " — a data-section len-2 string
  whose [len=2][tag=16] words tag-collide with
  PendingContinuationBoundary — and the three implicated "handles"
  were that string's own internals; two rounds of hand-decoding had
  misread the same bytes as a nullary-ctor sentinel. THE ROOT, latent
  since the fork pair landed (2026-07-23): graph_push_checkpoint
  recorded only trail_len, so a state spine GROWN during a candidate
  fork (extend_to's doubling copy) had no inverse — graph_rollback
  restored slots into the region-doomed spine, heap_reset zeroed it,
  the propose fan's renderer reused the memory, and check #2's
  finalize walked the alien word into occurs_in_row's destructure
  (deterministic per binary, vanishing under probe allocations — the
  forensic-law fingerprint, measured across three lineages; the cut's
  41%-smaller layout merely moved which constant landed there). THE
  FIX AT THE REPRESENTATION: the checkpoint is the fork's STATE
  VALUE — graph_push_checkpoint snapshots the seventeen grow-able /
  co-varying state fields as one record (pre-mark, O(1));
  graph_rollback walks the CURRENT trail backward INTO the snapshot's
  spines (revert_trail_into over undo_set_within — bounded, never
  extends; backward order makes the oldest old-value win per slot, so
  every in-place case lands pre-fork, and a slot alive only in a
  discarded grown spine is skipped) then restores every field
  wholesale; the unpaired-rollback arm keeps the legacy walk. The
  trail's own comment claimed "each mutation has a precise inverse" —
  spine growth was the mutation with no entry. The fix's own first
  two shapes were then REFUTED by the frontier (the gate catching the
  fixer, twice): restoring HALF the overlay family desynced the
  parallel quartet (count > restored bufs — propose-fan OOB'd in
  overlays_to_pairs; the whole names/bufs/lens/count/current family
  now forks together), and the pop's slice(stack, 0, n-1) MINTED ITS
  SLICE NODE IN THE DYING REGION — the next fork walked a zeroed cell
  (the doomed-allocation class recursing through its own cure); the
  pop is drop_last, the snoc-parent READ, allocation-free. The repro
  now runs the FULL edit loop green (fan → accept → patch → re-infer,
  rc 0, the Why facet reading the patched line). MEASURED, the whole
  board: the march ran TRANSITION m3 == m4 at 333,992 lines (pin
  4900d2c7 — the 1,932-line m2/m3 diff was the postmortem emit
  crossing one generation) then CLEAN m2 == m3 at 334,028 lines with
  the overlay/pop completions (pin 612b6589, blessed) — the wheel 40%
  smaller than the pre-cut 559k; census 0 at every generation;
  comment-refs 0; battery 113/113; frontier 229/0 (capability-hole,
  the field leg, and the fan leg all green); proof-exactness 9/9;
  crown 5/5. Peer born of the fix's own build:
  Hβ.infer.nested-alternative-branch-bracketing (named-residue
  index — the medium refused two correct shapes of the walker before
  the undo_set_within hoist). Banked structural findings, unchanged:
  the 5,259 dormant k2 floors (delete via raise-site absence proof)
  and the resume_k_arg dead-k word wanting its
  SingletonUninstalled-style guard.
  mn-world-resume-frozen (tests/frontier, UNREGISTERED) is the arc's
  banked RED pair (134 today — the driverless-install crossing floors
  before the world even matters; the A4 un-flooring is the next rung
  with it as the gate). Fixture lathe-lag measured en route: an
  ANNOTATED handler config param (`scaler(f: Int)`) does not parse.
- 2026-07-23 · THE PERFORM SCAN'S CORPSE LEAVES THE SOURCE (the world
  arc's write-side cleanup, rung one · pin 9448692b): ev_perform_entry
  deleted with its reach seed — the fn its own comment scheduled for
  this rung, zero callers since the R2 pin crossed — and all nine
  prose sites trued to ev_perform_node or reworded off the dead
  symbol. CLEAN m2 == m3 at 577,727 lines (reach had already pruned
  it; the deletion removes source only); board whole at the pin.
  Rung two is the foundation cut the census forced: the keyed-ev
  region dies WHOLE (effect entries write-only since R2; LSuspend's
  evidence fork collapses to bare calls), the __resume channel becomes
  a real trailing argument on resume-bound fns (the "argument, not
  evidence" ruling executed), and the k record freezes the LIVE world
  handle (the static world_tag fingerprint dies) with resume rebinding
  through it — R4's semantics at the representation layer.
- 2026-07-23 · ▶▶▶ THE FORMATTER SPEAKS — render totality + `mentl fmt`
  (the formatter arc's first landing · pin 013e26bd): the 18 missing
  arms land (Expr 25/25, Stmt 9/9, Pat 8/8; the surrender-fallbacks
  deleted into enumeration), and first light on the dormant module
  killed four latent bugs — the reversed joiners (every list rendered
  backwards, unseen at zero callers), the `{{`-is-not-an-escape class
  (22 sites to SYNTAX's \{), unescaped string content
  (format∘parse-identity made true), and the op/fn name collision at
  the direct-call tier (graph_node_at — the class named
  Hβ.emit.op-fn-name-collision-direct-call). Precedence-INVERSE
  parenthesization under the one table; the gate is BEHAVIORAL (42
  before and after — typechecking cannot tell (a+b)*c from a+b*c),
  plus byte-exact idempotence and prose/annotation carry: three
  frontier legs, RED on the pre-verb boot. The comment weave renders
  back (trailing→leading is movement not loss, stable from pass two);
  authored annotations survive with fields in the parse's own
  alphabetical canon; assemble_render carries String intent boundaries
  (the fan's elements arrive free — the §9 law's sibling). Named
  refinements: sugar preservation (destructuring lets re-render as
  their desugared match — the graph's truth), the width-aware layout
  engine, and the summit: the wheel formatting ITSELF (the 760
  E_RedundantBraces die there). The trecordopen-wrong-field class
  gained its lambda-shaped repro en route (a lambda param's field read
  on a plain record — annotated-closed dodges). Board whole: CLEAN
  m2 == m3 at 577,765 lines, census 0, comment-refs 0, frontier 229/0,
  battery 113/113.
- 2026-07-23 · ▶▶▶ THE RATCHET RUNS — 77 medium-authored tightenings,
  19 corrected by the canonical judge (tighten goes batch · pin
  b0204323): every authorable T_OverDeclared applies per run (per file
  bottom-up; monotone-safe by the wider-declaration argument);
  iteration 1 authored 75, iteration 2 authored 2; the blob's
  canonical judgment then REFUTED 19 DAG-computed rows (the
  order-conditional class measured live at scale — the tighten loop is
  now Hβ.infer.order-independent-verdicts' sharpest consumer), and
  each was trued to the judge's own found-row, converging 19 → 13 → 0
  with the emitted wheel BYTE-IDENTICAL throughout (pure inference
  truth, zero emit drift). Residue: 15 multi-line decl heads the
  single-line patcher refuses (never mangle). The wheel's declared
  rows are now at the canonical judgment's fixpoint for every
  single-line head. Board whole: CLEAN m2 == m3 at 563,042 lines,
  census 0, comment-refs 0, frontier 226/0, battery 113/113.
- 2026-07-23 · ▶▶▶▶ THE MEDIUM AUTHORS ITS FIRST CHANGE (`mentl
  tighten`; the self-build audit's step 1 executed whole · pin
  ab8daa07): T_OverDeclared was always a MachineApplicable proposal
  carrying the proven row — the tighten verb turns the first authorable
  one (closed tail) into the patch. The tighten_collector is the
  COLLECTING FORWARDER over Diag: every diagnostic re-performs outward
  from the arm — the world arc's deep-handler law in production the
  night it landed — and all three Diag ops carry arms (a partial-effect
  handler leaves zero fn slots; a perform through one is a garbage
  dispatch — the constraint, named at the handler). Run on the wheel's
  own DAG, the medium authored spec_is_agg (src/backends/wasm.mn:223)
  `with Memory` → `with Pure`; the fixpoint held CLEAN through the
  self-authored diff and the human's role reduced to gates + commit —
  §0's convergence (docs : Claude :: language : developer :: human :
  mentl audit) at its first executable instance. Three frontier legs
  seen RED on the pre-verb boot (author / fresh-check / fixpoint).
  NAMED FOLLOW-UP (Morgan's cut at the suppress marker): the
  drift-audit's mode-33 exclusion is a ROW fact a grep cannot read —
  the scaffold takes per-line ignore markers where the medium reads
  the row; the absorption (an infer-side let-where-pipe class gated on
  the callee's row, pure-only, plus the string-literal blindness) is
  the comment-refs precedent applied to the drift audit, and the whole
  ignore-marker family dies with it (Hβ.audit.drift-modes-read-the-row).
  Board whole: CLEAN m2 == m3 at 561,214 lines, census 0, comment-refs
  0, frontier 226/0, battery 113/113.
- 2026-07-23 · THE ANNOTATION VERIFIER PROVES
  (Hβ.mentl.verify-after-apply-boundness-only RESOLVED — the self-build
  audit's gap 2 · pin fadbbee7): apply_annotation_tentatively returns
  the PROOF — row_subsumes(body row read live from base_ty, narrowing),
  the finalize gate's own engine — and boundness demotes to the
  structural belt. Seen RED live: an allocating main was offered
  "!Alloc ... proven zero allocation"; fixed, it loses the false claim
  and gains the TRUE !IO severance, the pure control keeps !Alloc.
  Frontier legs mn-teach-alloc-honest + mn-teach-pure-control (judging
  main's own line — teach projects every fn in the blob). This clears
  the soundness gap standing on the self-authorship path (the audit's
  step 1a); the tighten driver is step 1b. Board: CLEAN m2 == m3 at
  559,311 lines, census 0, comment-refs 0, frontier 223/0, battery
  113/113.
- 2026-07-23 · ▶▶ THE BRACKET LANDS — R5, the world arc's first
  wheel-internal consumer (Hβ.cli.infer-context-bracket RESOLVED · pin
  2644dab5): the analysis core installs as ONE fn — infer_context
  (pipeline.mn) brackets the body thunk in the eight-handler core in
  the settled order; all 14 inference-reaching chains route through
  it; the per-chain parallel/threads re-installs die (dispatch's
  boundary installs them once); the wheel shrinks 2,168 lines. The
  EXACT form refuted twenty-four hours earlier by the mint-time
  evidence snapshot, now sound because a computation performs in the
  world where it is CALLED — the refuting smoke re-run all green (at
  projects, compile - emits, check refuses broken input). A future
  verb structurally cannot mis-order or forget the core. Board whole:
  CLEAN m2 == m3 at 558,997 lines, census 0, comment-refs 0, frontier
  221/0, battery 113/113. The arc's remaining rungs: the write-side
  cleanup (ev_perform_entry + the captured_evs perform role, zero
  callers), R4 (the k record freezes the world; band B's value gate),
  R6 (the fork pair's world leg in synth/oracle).
- 2026-07-23 · ▶▶▶ THE PERFORM READS THE WORLD — R2+R3 land together
  (evidence dispatch goes dynamic; deep-handler law by construction ·
  pin e8bcfb14): every evidence-tier perform resolves through the LIVE
  install chain — ev_perform_node walks [key][entry][parent]
  [install_world] nodes from the world top (passed inline as
  (global.get $world_g): the wheel source performs no world_top op,
  the CROSSING CONSTRAINT — the prior pin's gate judges the source
  with the prior recognition set, so a new substrate op must arrive
  declared-but-unperformed; E_EffectUnhandled caught both wrong forms
  before any binary ran, first the Alloc-declared world_top flooring
  the root, then the performed form itself), resolves ONCE into a
  per-site local (the old arm re-scanned the frame region four times
  per perform), and the ARM CALL alone brackets in the node's
  install_world — an arm's own performs resolve OUTER, never self;
  args evaluate at the perform site; tail-resumptive resume-as-return
  continues under the perform-site world by construction. THE THREE
  GATES FLIPPED AND GRADUATED (tests/frontier/mn-world-*, RTLIBS
  legs): thunk 134 → 42 (a thunk performs where CALLED, not where
  minted — the class that refuted the queue-5 bracket), arm-config
  2 → 40 (band N's Hβ.lower.config-fn-evidence-in-arm silent-wrong
  class DEAD), shadow control 40. ev_perform_entry stays in source
  solely for the prior pin's emitted sites (zero callers this
  generation; reach prunes it) — its deletion plus the write-only
  forward machinery (derive_ev_slots effect entries, the captured_evs
  regions' perform role) is the named write-side cleanup rung; then
  R4 (the k record freezes the world; the band-B value gate) and R5
  (the 14-chain bracket consolidation re-run — now admissible). Board
  whole at the pin: TRANSITION m3 == m4 at 561,165 lines (the
  32,564-line m2/m3 diff is the dispatch crossing one generation),
  census 0, comment-refs 0, frontier 221/0, battery 113/113.
- 2026-07-23 · ▶ THE WORLD CHAIN — R1 of the world-as-value arc
  (writers only, the reader is R2 · pin 8156ee0c): every emitted
  install draws its runtime edge — $world_g + $world_push cons one
  [key][record][parent] node per absorbed effect group, save/restored
  around the install extent (world outermost of the two brackets; the
  save is unconditional, anonymous installs included — the invariant,
  not an optimization); install enames intern through visit_string so
  every world key resolves nonzero. The three repro-world fixtures
  hold their measured values through the new emit (134 / 2 / 40 — the
  chain is inert by construction until the perform swap reads it), and
  the m4 leg ran the wheel's entire self-compile under live world
  brackets. TRANSITION m3 == m4 at 561,069 lines (the 26,623-line
  m2/m3 diff is the bracket crossing one generation); census 0,
  comment-refs 0, frontier 212/0, battery 113/113. Next: R2, the
  perform swap whole — the evidence tier reads the chain, captured_evs
  op-dispatch dies, the __resume k-threading channel survives.
- 2026-07-23 · THE ANALYSIS-CORE ORDER LAW + doc's env completion
  (queue 5's honest yield; the consolidation itself refuted by
  measurement · pin 4b10e457): the infer-context audit enumerated all
  14 inference-reaching chains (not the ledger's seven), settled the
  install-order question at ONE home (pipeline.mn's spine — ledgers
  innermost; lookup_ty before env before graph before mutate_sink;
  diagnostics outer to graph, because graph_bind's occurs-check reports
  FROM the graph arm — probed live: at_run counts it, exit 1, via the
  unique-handler state global; the outer placement makes the count
  tier-independent), and completed doc_run's core with its missing
  env_handler (env ops resolved through dispatch's instance while its
  graph was chain-local — accident made contract). The BRACKET FN was
  BUILT WHOLE and REFUTED before commit (⟲ — the verifier's own theory
  died to the artifact): all 14 chains rewritten over a body thunk,
  wheel 1,568 lines smaller, census 0 — and the smoke split exactly
  singleton-vs-evidence: check/doc/teach/query/repl green (state-global
  ops are dynamic), compile and the at verb TRAPPED (executable_gate's
  verify_debt is multi-handler Verify; the cursor ops are ambiguous —
  both evidence-dispatched, and a closure's evidence snapshot predates
  the bracket's installs; the M3 lexical fence is the semantics, not a
  bug). Reverted whole; `Hβ.cli.infer-context-bracket` (named-residue
  index) banks the measurement, the DEP (dynamic evidence crossing vs
  the fence's replay guarantee), and the build order behind band B's
  world discriminator. Board whole at the pin: CLEAN m2 == m3 at
  559,460 lines, census 0, comment-refs 0, frontier 212/0, battery
  113/113.
- 2026-07-23 · THE WHEEL SERVES ITS OWN IDE — `mentl space` (queue 4;
  the serve scaffold's written dissolution executed · pin 61c10ab8):
  ide/serve.mn absorbed whole as src/main.mn's space arms (mime
  projection · one-read request · request-line path · route, with "/"
  and directories to index.html and ".." refusing · the isolation-pair
  respond · the tail accept loop, constant stack for the server's
  life); serve.mn + serve.sh + serve.wasm DELETED, every reference
  re-pointed (README, MENTL_EDIT, tutorials, §8, the runner design).
  The listener is the install shim's seam — WASI p1 has no
  bind/listen, so the host resource rides the same shim boundary as
  run's exec seam (--dir "$MENTL_HOME::." maps the repo at guest "."
  so the verb serves from ANY directory; -S tcplisten=127.0.0.1:7378,
  override MENTL_SPACE_PORT); without a listener the verb refuses and
  TEACHES the seam. Two frontier legs seen RED on the pre-verb boot:
  the refusal-teach, and the live serve asserting 200 + the
  cross-origin-isolation pair on ide/index.html; smoked end-to-end
  through the installed shim from /tmp. One observation banked with
  its one-line design: `mentl <unknown-verb>` prints the catalog and
  exits 0 — the refusal law at the CLI surface wants exit 1 when argv
  NAMED a verb (bare `mentl` stays the welcome projection at 0).
  Board whole at the pin: CLEAN m2 == m3 at 559,432 lines, census 0,
  comment-refs 0, frontier 212/0, battery 113/113.
- 2026-07-23 · gradient_queue DELETED WHOLE (queue 3 · pin 56f01996):
  the built-exposed-zero-callers GradientQueue block (effect + handler +
  its four private fns, 107 lines) dies; the peer resolves as DELETE;
  band E's work-stealing-via-gradient keeps the design. CLEAN m2 == m3
  at 558,531 lines; board whole.
- 2026-07-23 · THE COMMENT WEAVE AT THREE ALTITUDES (queue 2 — SYNTAX's
  "never dropped" made true for the measured gap · pin aa6338e9). A
  block-INTERIOR comment attaches to the finest FOLLOWING node (next
  statement / final expr / the block's unit node — by HANDLE, so the
  before-final-expr case never wraps the final as an ExprStmt), and a
  TRAILING same-line comment attaches BACKWARD to the node whose line
  it shares — same-line decided by TOKEN geometry (no TNewline between
  item and comment; the span test failed because a braceless let-chain
  leaves the position past consumed newlines — the str_contains doc
  attached to str_compare until the token test, caught by reading the
  Lede at the address). The address surface renders the attached
  prose's first line as the Lede facet through the one
  comment_first_line projection (a duplicate lede helper died to
  E_DuplicateFnName's own refusal — the armed class catching the
  session's hand again). Interior comments thereby joined the backtick
  gate, and the referent set grew its SCOPE face: each top-level decl
  contributes (extent, comment_locals), extents from consecutive stmt
  starts since decl spans are head-only, so interior backticks resolve
  against the enclosing fn's params and binders; the eight residual
  phantoms were the narration class, unbackticked per the contract.
  The affine ledger pairs a buffer move inside a destructure-desugared
  arm with sibling-leg moves (three clean small repros; the real fn
  refused), so the block loop is destructure-free — helpers own the
  collects. Gates: lede-demo (decl + interior + trailing all render,
  RED as zero Lede lines on the prior pin); the ratchet itself (0 → 23
  → 0 as the new judge saw interior prose and the heal closed it).
  Board whole: CLEAN m2 == m3 at 558,532 lines, census 0,
  comment-refs 0, frontier 210/0, battery 113/113. Expression-interior
  positions (parens / arg lists / match-arm headers) stay layout — the
  named refinement Hβ.parser.expr-interior-comment-attach (SYNTAX
  carries it).
- 2026-07-23 · ▶▶ THE BLOB DECLARES CALLEE-FIRST + THE SUBSTRATE FACE
  TABLE + THE N-CURSOR FIELD (queue 0b landed with the order truth it
  forced · pin 6807a214). The dig: `mentl two.mn:0` rendered every
  position as one ghost var — the ranked (Float, Int) tier read ph at
  the word-floor offset 4 while construction stored wide; no twin
  minted because the demand walk's pairs resolved to FREE vars; the
  Why probe named the fresh instantiation; the bare-scheme census then
  measured the true shape: 492 wheel fns published fully-bare schemes
  — the src-first blob made every src→lib call a FORWARD reference
  reading the loose pre-registered snapshot (the order-conditional
  class at its true size; the RTLIBS repros all passed because
  fixtures sit AFTER the libs). THE FLIP: the canonical wheel input is
  lib-before-src (wt_wheel lib src; march.sh matches) — callee-first
  at module scale, the same cure prelude's iterate order applies
  in-file. Bare schemes halve to 256 (intra-src residual, the named
  order peer); field_ranked resolves whole; three tier twins mint
  worthy. The sharper order re-judged the wheel — 57 diagnostics
  trued: 33 declared rows widened to their bodies' truth (+Alloc
  mostly; ic_compile_loop's IC-era row dropped — the body runs the
  compile spine), the escaping family's two op declarations now speak
  the string name-sets the family always carried (a first [EffName]
  guess and a double-conversion detour both died to the artifact; the
  probe's reason chain named the decl), expr_child_handles reads
  {name, init} records by the init edge (MakeRecordExpr AND ResumeExpr
  passed the record itself to node_handle), render_propose_arm's
  guarded unwrap became the match (Pure holds), and the zero-caller
  cursor_session_batch + CursorSessionResult deleted whole. THE FACE
  TABLE: seq_op_sig is ONE home both substrate paths derive from —
  infer_seq_op forces each argument position against it (the per-arm
  force boilerplate deleted), and a HOLED/under-applied seq-op call
  builds its product-with-holes from the SAME face, never from the raw
  body's env scheme (list_set's `l + 8` types l Int; the partial
  minted from it unified every pipe datum with Int the moment the
  order made the scheme visible). The wheel's 14 `|> list_set(??, …)`
  pipes rewrote saturated (clean under both judges); the class is
  gated RED-first (mn-seq-op-holed-pipe: 4 errors on the prior boot,
  72 through the face). THE FIELD (0b): `mentl <file>:0` projects the
  whole absence field — every authored hole ranked first, each
  rendered through the same cursor_at_handle + render_at path the
  single-address form uses (a hole's line carries its Propose fan,
  ties teaching), the annotation-gradient tier after; sequential, the
  `><` swap honestly gated on the runner migration. Gate: the
  propose-fan-demo field leg (RED as "lines count from 1" on the prior
  pin). Board whole at the pin: TRANSITION m3 == m4 at 557,233 lines,
  census 0 at every generation, comment-refs 0, frontier 209/0,
  battery 113/113.
- 2026-07-23 · ▶▶▶ THE INSTANCE CROSSES THE FN BOUNDARY — subst_row's
  dropped closed-tail merge, the trio law completed over bound tails,
  and the install-frame fragment join (the fold-family dig's root,
  twelve iterations and twenty killed labels, landed whole · pin
  cad3ca53). THE ROOT: subst_row's EtVar arm merged a bound row's
  names only when the inner tail was itself EtVar — a row var SOLVED
  to a CLOSED row (every declared-row fn) fell to the catch-all and
  returned the empty row, DISCARDING the bound row's whole present set
  at instantiation. Every caller of every declared-row fn has read a
  BARE row since the row machinery landed; no effect instance ever
  crossed a fn boundary; map's element died at the caller. The merge
  arm reads the binding live, freshening through the same mapping the
  params use, under the solved tail. THE TRIO LAW then completed it
  (the second half, pinned by the install probe): free_in_row and
  occurs_in_row now descend a BOUND tail exactly as subst_row
  traverses it — collection-without-descent left the tail's inner
  payload vars unquantified, so instantiate shared them RAW across
  every call site, map's install bound the shared answer var to [b],
  and every later HOF decl collided against it (the cross-decl
  Bool-vs-List wave; the probe read the stale [b] inside any's own
  fragment). With them: publish_with_instances (a declared-bare name
  keeps the body's parameterized instance at publish),
  inf_add_row_unified gated on the INSTALL frame (yield's and
  result's fragments are one instance inside a tee body and join by
  position before the name-set union can drop one; a caller's
  independent callee instances never join — the ungated form unified
  fold-over-[Int] with fold-over-[Float], the 286-error m3 wave),
  the effects.mn name-set bare→parameterized upgrade at the three
  dedup seams, prelude's callee-first iterate order, chase_deep root
  canonicalization with chase_row_deep over EAType payloads and TCont
  worlds, the compare-leaf f64 stash pair (the bare (f64.lt) select
  never assembled — every Float-field compare helper was born broken),
  and spec_pairs_walk chasing body-bound vars. THE TWO-PASS WALK built
  en route (iterations 10-11) was REVERTED by measurement: its second
  pass tips the 4GB image at the m3 emit (alloc-unreachable in the
  reach walk — the seq-op-row precedent verbatim); the verdict and the
  design are banked on Hβ.infer.order-independent-verdicts, DEP-gated
  on the arena. The sharper compiler immediately exposed one CANONIZED
  silent-wrong: micro mn-mapelem banked exit 1 — the old wheel floored
  map's unresolved record to offset 0 and read alpha where .beta=2 was
  meant — and one under-declared fixture row (stats fsum gains fold's
  true Alloc). Gates: mn-forward-wide-instantiation RED on the prior
  pin (a forward wide instantiation through a mono caller), bisect-r
  42, the trued micro at its real value. Board whole at the pin:
  TRANSITION m3 == m4 at 553,900 lines, census 0 at every generation,
  comment-refs 0, frontier 205/0, battery 113/113.
- 2026-07-23 · THE TUPLE PATTERN READS THE BRACKET (the pattern path's
  last lower-time layout bake dies · pin 80852432). LPTuple carries
  (elem_ty, sub_pat) — live element vars — and (offset, width) project
  at EMIT: pat_elem_repr resolves through lookup_ty (the bracket-aware
  channel construction and binop dispatch already read; the raw chase
  answered the floor and split a twin against its own construction),
  pat_tuple_off runs the identical align_for+repr_width prefix-sum, and
  a var-typed tuple destructure is itself a worthiness WITNESS
  (spec_oph_wide_pair's TTuple arm — a var element landing wide demands
  the twin; pointer instantiations keep word slots, minting nothing).
  Seen RED twice on the prior pin: the worthy twin's WAT did not
  assemble ($sc.f64 undefined local — the in-flight N-cursor code's
  (Float, Handle) ranked tuples were the first trigger), and the
  non-worthy floor read an f64's high word at baked offset 4 as the
  next element (invalid exit, zero diagnostics — probe-second). Gate
  mn-generic-wide-tuple-pattern: twin assembly + floor face +
  mixed-order (Int, Float, Int) alignment, 42. CLEAN m2 == m3 at
  550,965 lines (the witness mints zero twins on the wheel itself);
  frontier 202/0, battery 113/113, census 0. The two SIBLINGS stay
  named with their designs: record-field patterns
  (Hβ.emit.f64-aggregate-pattern-width — the carrier lacks fty; the fix
  is this landing's shape one arm over: carry the field ty, read
  pat_elem_repr, fold the offsets live) and generic CON payloads
  (Hβ.emit.spec-con-payload-instantiation — ctor_payload_tys_of reads
  the DECLARED scheme whose roots the bracket does not key; the fix
  resolves the payload tys through the site-instantiated ctor type at
  the match, the same spec_resolve read the twins' interior calls use).
- 2026-07-23 · ▶▶ THE FAN PROJECTS + THE FORK PAIR (the /loop's queue-0
  landing · pin 08640f17). A `??` tie LISTS the proven survivor space —
  each candidate rendered with its Reason, then the collapsing move
  (propose-fan-demo seen RED as the bare count line; the frontier leg
  asserts both Bit survivors project). Both candidate-verify loops
  (verify_each_enriched and enumerate_inhabitants' resume-per-proven
  fan) gain the FORK PAIR — graph checkpoint + heap region per
  candidate, memory and graph both restored at the fork boundary, O(1)
  each — the exploration substrate's honest isolation, and the arena's
  second real workload after the battery. The medium caught its own
  builder again within minutes (census 0 → 1 → 0: the fork pair's
  heap ops forced verify_each_enriched's declared row to its Alloc
  truth). The multi-shot arm's first wheel-internal consumer is the
  N-cursor pass, next in the queue.
- 2026-07-23 · ▶▶ THE MANIFEST TELLS THE TRUTH — every module's import
  list resolves its whole vocabulary, and the medium wrote its own
  worklist (the /loop's first landing · pin cab557e8). The probe form
  `mentl src/<m>.mn:1:1` turned each module's E_MissingVariable set into
  the exact edge list; four sweep rounds converged: nine primary moves
  to DAG-honest homes plus their sibling closures (the wasm-layer
  reach/spec/ctor helpers → lower; node_handle + parse_span_of → graph;
  why_expand → query; the flow-label trio → types — each was defined
  DOWNSTREAM of its users, the backward edges that made module entry
  fail), plain imports across fourteen modules, and main_param_count
  rewritten on lower's own decl walk. The rewrite's first flat form
  MISSED the LLet-closure named-fn shape (the wheel's own main) and
  dropped _start's argv — the march's transition arbitration refused
  the unassemblable m3 before any pin moved (the size-guard/arbitrate
  machinery paying for itself again); the fix matches exactly
  reach_decl_name's shape set. The comment-truth sweep rode the same
  ladder: T2–T7 trued (deleted-seed mirrors, six→eight fields, dead
  item-11.B pointers → the live name-is-handle peer, the stale
  voice.mn:9 example → a projecting address, era-narration → mechanism
  prose), and SYNTAX corrected its two false claims — the retired third
  projection, and the comment-attachment gap MEASURED and named with
  its build (interior/trailing comments are today consumed as layout;
  the finest-following-node attachment is the named upgrade). Board
  whole at the pin: m2 == m3 at 549,887 lines, census 0, comment-refs
  0, frontier 198/0, battery 113/113. The de-theme landed separately
  (ffe271eb — system fonts, neutral palette, no mascot, no octagon
  motifs; function untouched, twin green).
- 2026-07-23 · ▶▶▶ THE DIRECT-CALL CASH-OUT — every named call goes
  native; the word-face wrapper's tail-leak dies; the signal crucible
  goes green (the dispatch gradient's own endpoint, landed whole ·
  pin f8abad90). THE DIG (the cfc-researcher's blocker, four labels
  killed by the artifact): its table-layout theory REFUTED (the
  three-way check — elem position == idx global == baked closure index,
  perfect at every probed fn); my alloc-trap a HARNESS ARTIFACT (the
  unmounted recording file — len(garbage)); the n-guards proved the
  series terminates; the TRUE root read from the frames: THE WORD-FACE
  WRAPPER BREAKS TAIL CALLS — a tail recursion's return_call_indirect
  lands IN the wf$ wrapper, whose body-call was plain, leaking ONE
  frame per iteration; at 4096 samples the stack tips with the innocent
  atan ladder on top (the researcher's threshold was never fn-count —
  it was recursion depth through any wrapper). THE FIX AT THE ROOT,
  never the symptom: LDirectCall — a callee lower proved a top-level
  FnScheme (the LGlobal-from-FnScheme mint; locals shadowed first,
  value bindings keep the closure path) emits `call $name` /
  `return_call $name` with NATIVE widths. Three artifact-taught
  corrections en route, each loud: fn schemes carry TParam PRODUCTS
  (param_ty unwraps — my first helper trapped repr_of on the product);
  arg widths follow the CALLEE'S DECLARED signature (word floor for
  generic/Int params — the seq-op raw bodies live there — native f64
  for declared Floats; six assembly refusals taught it); and a TWIN's
  widths read the SAME spec_site_pairs/spec_subst_pairs projection that
  minted the redirect (raw lookup_ty floored free vars against the
  twin's native slots — three assembly REDs). The pipe splice gained
  the node's arm (26 phantom E_UnresolvedHole = partial-application
  ??s surviving the `_` fallback — the m3 leg's own refusal caught it).
  Word-result wf$ wrappers tail-collapse as the belt. MEASURED: the
  wheel SHRANK 19,942 lines (−3.5%) and the wasm 5.3% — every named
  call in the language dropped closure-eval + spill + call_indirect for
  one direct call; the researcher's whole bracket runs (wf-1/5 = 42,
  wf-15's 4096-deep demod as true tails); signal-crucible TRANSPLANTED
  and GREEN (exit 42, cross-validated against the independent oracle —
  argmax flat 2, strong coupling; the STFT + `<~` bandpass + filter
  comodulogram lands as lib/dsp/signal.mn with tests/repro-wf banked).
  Board whole: frontier 198/0, battery 113/113, census 0, comment-refs
  0, m2 == m3 at 549,924 lines. Hβ.emit.float-evidence-ft's named class
  narrows to the genuine value-dispatch residue (lambdas/HOF through
  the table keep the word protocol — sound, just not yet fast).
- 2026-07-23 · ▶▶ THE SOCKET SPEAKS AT THE ADDRESS SURFACE (the Propose
  facet's first render + the resolver's column law · pin 17d1c3be).
  `mentl hole.mn:9:37` at an authored `??` now projects the socket's
  content: `Query: ?? : Positive · Propose: 1 · Why: declared choose` —
  the ONE proven survivor, rendered through the SAME
  render_candidate_source projection the edit transport's accept path
  applies, at the one-shot address read; a tie prints the survivor count
  + the teaching line (never a hidden first-wins pick — PLAN §5's
  tie-break law at this surface too). render_at stops discarding the
  CursorView's propose slot (the ide-visionary's seam report named it:
  the graph computed the proposal; the terminal threw it away). TWO
  structural fixes were forced by the artifact before the facet could be
  real: (1) THE COLUMN LAW — address_better_a picked the WIDEST
  containing node for BOTH address forms while its own comment promised
  "a column address narrows within it"; the code caught up to the
  comment (file:LINE keeps the line's root = widest; file:L:C picks the
  TIGHTEST containing node), and on IDENTICAL spans the LATEST mint wins
  — mint order builds constituents before composites, so the later node
  is the more derived reading (a `??` mints its id cell then the NHole
  over the same span; the address must reach the NHole, whose Propose
  facet speaks). (2) The sharper wheel then caught MY OWN first attempt
  at a ty_of_kind NHole arm as ill-sorted (E_TypeMismatch NodeKind vs
  NodeBody — census 0 → 1 on the m3 leg): NHole is a BODY constructor
  and can never appear as a chased cell state, so the arm was dead code
  with a sort error; DELETED (the census-as-ratchet catching the
  session's own hand within the hour — the medium keeping its builder
  honest, §0 live). Gate leg: tests/frontier/propose-demo +
  frontier-gate's cursor-address-propose assertion, seen RED on the
  pre-arm boot (the address printed no Propose line and resolved the id
  cell). The ide-visionary's proof-of-life landed in parallel (ide/
  only): the browser aspect ring reads the compiler's real eight-aspect
  CursorView over a virtual fs, RED→GREEN on provenance 'real', plus a
  genuine serve.mn catch (read_request hand-rolled the pre-merge +4
  String layout — latent OOB under the armed bounds check, fixed to
  bytes_buf/+8/str_of_buf; the wheel-side class census came back CLEAN —
  zero +4 payload writes, all 18 str_of_buf callers on the merge's
  migrated boundary — so serve.mn was the class's last instance); its
  batch commits when it reports against this pin. RETRACTION, same night (the ⟲ law on the orchestrator's own
  claim): commit dbf538ea's message says the fixpoint judged the
  rewritten tutorials because "the wheel blob includes lib/**" — FALSE;
  wt_wheel and march.sh both carry `-not -path '*/tutorial/*'`, so the
  tutorials are OUTSIDE the blob and the matching m2cache key proved
  nothing (an excluded file cannot change the key — the inference was
  consistent with its own negation). The tutorials' real verification
  is direct: each compiled through the pinned boot, assembled, run,
  output checked (re-derived by hand for 00/03/06/08 — greetings, 30,
  51, 9). The lesson is §9.6 verbatim: verify the formula, not the
  plausible reading of its output.
- 2026-07-23 · ▶▶ THE NULL-SINGLETON CLASS CLOSES + THE REGION BATTERY
  SHIPS (the cross-compile trap's root, proven adversarially and landed at
  every altitude · pin 6c192865). The forensic-prober (a fresh mind told
  to refute the thirteen-kill corpus) did exactly that: with the virgin
  reset on main the old infer-side death was GONE, and the real death sat
  at compile #14 entirely in EMIT — project_emit_state installed six
  visitor collectors but not effect_census_collector, so the shared walk's
  census op ran as a NULL-STATE SINGLETON: its accumulator lived at
  absolute address 12 (the null page — below every region mark, never
  reset, holding a stale pointer into the region), and the next compile
  walked the stale pointer as a list. THREE CLOSURES, one landing: (1) the
  wiring — every walk_lemit bracket installs every visitor family the walk
  fires (the row's dynamic-extent obligation, stated at the site); (2) the
  GUARD — singleton_perform_block refuses a STATEFUL singleton op call
  whose state global is 0 (SingletonUninstalled, the tier's evidence IS
  the global; the LDirectPerform node carries the stateful bit read once
  at the mint, and the LIf's condition is the record pointer's own
  truthiness — no comparison nodes, no operand-width hazard); stateless
  stays UNGUARDED by the same licence the compile gate's STATEFUL
  conjunct encodes (the arm ignores __state; null is sound by
  construction; byte-identical emission, Law 7) — the two altitudes
  cannot contradict on any program; (3) the REGION battery ships —
  battery_loop marks/resets per micro (113/113, ~192MB peak, the
  per-decl arena's first real workload, §5.O). The guard was seen RED
  live TWICE the hour it landed, each firing a real missing install: (1)
  the test verb's directory arm ran battery_run's fs/console ops bare
  (tolerated for months because the stateless arms read the null page
  benignly) — fixed by giving the match the chain its sibling always
  had; (2) the EDIT chain ran its whole inference without
  lookup_ty_graph, so every lookup_ty in a `??` authoring session read
  the NULL PAGE AS THE GRAPH — silently wrong inference in the felt
  loop's own flagship workflow, surfaced only because the guard refused
  it (16 frontier legs RED at unify_install_payload's lookup_ty). The
  second firing triggered the CENSUS the two-trap rule demands: SEVEN
  chains reach inference; serve_run/compile/battery/stdin carried the
  install, FIVE did not — edit_run, pipeline_check (whose own comment
  records the same class from the region sweep one landing ago),
  check_source, at_run, repl_run, and doc_run (missing affine_ledger
  and region_tracker too — its per-module inference ran every analysis
  op driverless). All five gain their installs in one sweep; the class
  now polices itself (any chain a future verb forgets traps loudly at
  the exact site instead of silently reading the null page). The
  residual drift-7 is NAMED with its design question: the analysis
  core (affine/region/verify/lookup_ty/env/graph) is one sub-chain
  hand-copied per verb with ORDER VARIANCE (env-before-graph is
  load-bearing; parallel_compose presence varies) — the order question
  is now SETTLED (the law at pipeline.mn's spine) and the bracket-fn
  form REFUTED by the evidence fence; `Hβ.cli.infer-context-bracket`
  (named-residue index) carries the measurement and the DEP-gated
  design. Fixture mn-singleton-preinstall-call banks the class
  (stateful op called before its install executes: compile gate admits —
  an install exists, grounding the whole-program conjunct — runtime guard
  refuses, exit 134; on the pre-guard wheel this ran SILENTLY WRONG,
  reading and writing state through the null page). Measured en route:
  an `_x` pattern binder emits byte-identical wat to `_` — the
  ignored-slot naming convention is free documentation. Five ladders,
  one landing: TRANSITION (guard bytes) → CLEAN (test-verb bracket) →
  TRANSITION (stateful-only refinement; wheel 95 lines SMALLER than the
  all-guarded form) → CLEAN (edit-chain install) → CLEAN (the
  seven-chain census sweep). The thirteen-kill corpus is superseded as diagnosis, kept as
  law (CLAUDE.md's forensic laws); Hβ.runtime.cross-compile-durable-state
  is CLOSED (named-residue index carries the resolution).
- 2026-07-23 · THE MARCH ABSORBS THE HAND LADDERS (the ladder's own
  alive-law audit, Morgan's challenge: "are you sure m2–m4 is the best
  practice, canonicalized, automated, future-proof?" · pin 229fda2f).
  The AUDIT'S VERDICT, banked: the LAW (self-application to a byte
  fixpoint + adversarial oracles, TRANSITION re-pinned from m3) is right
  and future-proof — it generalizes to native (native_m3==native_m4,
  NATIVE.md) and to parallel cursors (the deterministic handle
  partition exists for exactly this); the PRACTICE was scaffold with
  four measured gaps, three closed HERE: march.sh gains the SIZE-GUARD
  (two empty legs can no longer read as a fixpoint), MARCH_REPIN=1
  (CLEAN blesses m2, TRANSITION blesses m3 — the wrong-side cp a hand
  script made once is now impossible; PROVENANCE prose stays the
  session's, the pin unblessed until written), and the per-leg census
  echo. The canonical run also caught the hand ladders' container
  drift: they assembled without --debug-names; wt_asm's pin carries the
  name section (readable backtraces), the fixpoint wat byte-identical.
  THE REMAINING GAP is the ultimate form, named in full: the ladder
  recompiles the whole world thrice to answer a changed-cone question —
  Carried-Truth at the practice layer — and dissolves into the medium
  as (a) the INCREMENTAL fixpoint (the IC cursor re-deriving only the
  changed cone + downstream, the whole-world march kept as the
  trusting-trust audit tier, not the per-landing loop), (b) `mentl
  march` as a verb (self-application as a cursor mode, the bash
  scaffold dissolved per §6), and (c) the verdict as a PROJECTION
  (emit-diff's handle-anchored divergence as the march's Reason, never
  a line count). Sessions must never hand-roll ladders again — the
  canonical tool now bends to the probe loop instead.
- 2026-07-23 · THE RESET RESTORES VIRGINITY + the law goes alive in
  CLAUDE.md (the twelve-kill forensic dig's landings · pin 502f691e).
  heap_reset now zeroes [mark, bump) before the rewind ($heap_reset_impl,
  a dedicated preamble fn — never inline, the callers' scratch may be
  live): the post-reset world is bit-identical to the never-allocated
  world, so every zero-read (slot_present's Option niche, unwritten
  make_list slots — alloc_list_sc writes only the header) stays true
  under reuse. The invariant had held by ACCIDENT of monotonicity —
  wasm's zero-init pages — and the first reuse served stale bytes as
  placed arg slots; measured under the contract, the regioned battery
  runs at a 192MB peak. The battery ships no-reset still: the
  twelve-kill corpus (named-residue index) ends at a standing frontier
  the virgin reset does NOT clear — the fill_arg_slots slots buffer
  ALIASES the env handler's own state in virgin memory (both gated hits
  at collect's placed arm, zero at every placement channel, one
  binary), with the yield machinery in every fatal frame; the
  address-pair probe is loaded. CLAUDE.md gains the ⚖ ALIVE-LAW
  section (Morgan's update-the-law license as first-class law; the
  docs' own census-to-zero; the standing charge made ambient) and the
  five FORENSIC LAWS distilled from the dig (one-binary gates,
  protocol-honoring probes, retract-fast, count-the-kills,
  accident-invariants become contracts at the one writer). TRANSITION
  m3 == m4 (the 2-line preamble/call-form crossing); board whole.
- 2026-07-22 · THE SINGLETON TIER TELLS THE TRUTH — LDirectPerform +
  the stateful-uninstalled refusal (the last silent-wrong class of the
  gate arc closes · pin fc2a9520). The singleton perform is its own
  LowIR node whose EVERY reader — emit, locals, reach, k2, spec, the
  census — delegates through singleton_perform_block, so its semantics
  equal the old inline form BY CONSTRUCTION (the ladder proved it: CLEAN
  m2 == m3 == m4, byte-identical). The census walk fires its demand, and
  the gate's resolver tightens: a demand through an op with a default
  handler grounds when the handler is STATELESS (the direct call touches
  no state) and joins the refusal set when STATEFUL — the read of a
  zero-initialized state global that no install ever wrote, the exact
  silent-wrong the emit's own comment used to wave off as "never read"
  (comment trued). Sound because the singleton tier is unique-handler by
  definition: an install of the ename IS an install of that handler.
  Fixture mn-effect-stateful-uninstalled seen RED (the prior boot
  compiled it clean and the artifact returned the wrong value); the
  stateless shape stays green. Frontier 192/0; census 0. The gate arc's
  named remainder is now EMPTY; the one open external arc is the
  wasi-threads migration — DESIGN COMPLETE (the threads-scout recon,
  2026-07-23), banked as `Hβ.ops.wasmtime-runner-migration` in the
  named-residue index.
- 2026-07-22 · ▶▶ THE CRUCIBLE TIER — DSP, ML, and the DSP×ML fusion land
  as real-workload gates, and building them killed a latent miscompile
  (an isolated builder's arc, merged whole · pin fe68767f). Three
  self-contained fixtures, each cross-validated against an independent
  python oracle over the SAME formulas, every verdict a discrete fact
  with wide margins: dsp-crucible (two sinusoids + a pseudo-noise tone
  through the `<~` recurrence lowpass; verdict = 8-bin DFT argmax of the
  FILTERED output — load-bearing on the filter, the raw signal's louder
  tone sits elsewhere — + zero-crossings 21 + clip count 64); ml-crucible
  (batch gradient descent, 2-parameter linear regression on 32 points;
  w,b converge to the planted 3,1); adaptive-crucible (a 2-tap LMS filter
  learning channel [2,1] ONLINE while filtering — feedback, float math,
  and learning in one loop, the fusion only the medium states this
  cleanly; residual power 13.89 → 2e-30). Each seen RED by perturbation
  (lowpass a=0.9 flips the argmax to bin 7; wrong slope exits 10; wrong
  channel exits 10; teaching codes kept under WASI's 126 exit ceiling).
  THE HARVEST: float `<~` NEVER ASSEMBLED — the emit hardcoded the
  feedback slots ($__fb_prev/$__fb/the state global) to i32, so the
  entire float IIR family in lib/dsp/feedback.mn was dead codegen
  (Carried-Truth: the graph proved the feedback node's type; the emit
  fabricated i32); the fix reads repr_of(lookup_ty(h)) live at both decl
  sites. No reachable wheel site floats a `<~`, so the fix rode a CLEAN
  m2 == m3 == m4. Frontier 191/0 at the pin; census 0; the builder ran
  isolated in a worktree and the merge was two clean 3-way patches.
- 2026-07-22 · THE STAGING CLOBBER'S ROOT — one handle, one local, nine
  writers (the interp-segment mint · pin ccd9381d). The
  effectful-arg staging clobber witnessed thrice tonight reduced to ONE
  mint bug: lower_string_interpolation's fold stamped the MakeString
  node's single handle on every interior str_concat call, and emit's
  per-handle staging local ($call_<handle>) folded all N−1 segments into
  ONE cell — re-set per segment while later splice reads still loaded
  through it. Pinned mechanically, not by repro (three structured repro
  shapes ran CORRECT — the corruption needs the arm-context interleave):
  the diagnostics arm's wat under the reconstructed 5-splice render shows
  nine local.set of $call_73934 with reads against stale values; under
  the fix every staging local in the same arm sets ONCE. The fix is the
  mint law: every interior concat mints its own handle
  (graph_fresh_ty at the fold), the outermost keeps the node's handle
  (its type/span identity). TRANSITION m3 == m4 (4,246 lines of staging
  renames crossed one generation); the sequenced-lets forms landed
  earlier tonight stay as better prose, no longer load-bearing. Board
  whole at the pin.
- 2026-07-22 · ▶▶ THE EVIDENCE HOLE REFUSES AND TEACHES — E_EffectUnhandled,
  the gate's third read, born ARMED on the true rows (the arc Morgan opened
  with "we should never see a WASM error" · pin TBD). An executable whose
  main-row carries an effect no install absorbed REFUSES at compile
  (exit 1, zero WAT, main's own decl span) with the graph-derived teach:
  no handler in scope → the declare-one form; a declared-but-uninstalled
  handler → "Install one over the performing chain: ~> pong" — read from
  the env's own HandlerKind arms through each op's EffectOpScheme, never a
  name table. THE CRITERION READS THE ARTIFACT, not a ledger — Morgan
  caught the first build red-handed ("building a ledger system?
  carried-truth violation much?"): lower-side note-lists caching perform/
  install facts were drift-7 by the letter, and they died into the emit's
  OWN single-walk multi-projection pre-pass — the SEVENTH projection
  (EmitEffectCensus: visit_effect_demand at LEvPerform's ename-carrying
  floor node and LYield's op, visit_effect_install at LHandleWith's arm
  groups), run by the gate over the post-reach tree it already holds.
  Reach-filtering is FREE (dead code is absent from that tree — the
  to_string shell-body class), a lexically resolved LPerform fires no
  demand (discharged by its install), and a singleton-tier perform fires
  none (direct call). Conjunction: present at the root ∧ not
  substrate-grounded ∧ a floor demand exists ∧ no install anywhere (the
  install conjunct covers the ambiguous-handler floor). SIX false-refusing
  micros forced the design there, and TWO inference roots fell to them: a
  VAR tail's pending mask now lives IN THE GRAPH (diff_row mints a fresh
  var bound to the masked triple over the original tail — union's absent
  is the mask INTERSECTION, set-correct, so a top-level mask on a var
  tail vanished at the frame union: multieffect's `run() ~> buffer` in
  let position lost Emit's subtraction), and a multi-effect handler's
  install subtracts its FULL arm-derived set (derive_handler_enames — the
  single-name subtraction left buffer's sibling effect on the caller's
  row). THE Show/Hash EFFECT SHELLS DISSOLVED at the same root: the
  LShow/LHash build had moved their dispatch to emit-structural, so
  `effect Show`/`show_default`/`with Show` was archaeology whose contract
  poisoned every caller's row — to_string/hash are now seq-op table faces
  (a -> String, a -> Int; raw word bodies that never run). WITNESSED
  THRICE and cured by sequencing, the EFFECTFUL-ARG STAGING CLOBBER: an
  effectful expression evaluated inside an interpolation splice list, a
  ctor argument list, or another perform's argument list corrupts a
  sibling operand's staged value (the diagnostics render's span read a
  stale env record; the perform-ledger probe read "" for every frame) —
  the render and every touched site are sequenced-lets now; the emit-side
  root is the next staging dig. THE NEXT DIG, design COMPLETE
  (specified against the artifact, ready to build): the
  uninstalled-singleton class. Corrected mechanism — the $ev_lookup
  assembly failure is the BARE-STDIN path only (the contract name is
  genuinely absent from an unlinked input; linked programs carry it), so
  the real remainder is the LINKED stateful case: a singleton-tier
  perform against a never-installed stateful handler reads the zero-init
  state global — silent-wrong. The build, each piece named: (1)
  LDirectPerform(handle, hname, op, args) — the singleton perform's own
  LowIR node, its emit arm DELEGATING to emit_expr over the exact
  LBlock/LLet/LPerform value lower_singleton_perform builds today (byte
  drift impossible by construction; Law 7 arbitrates); (2) the census
  walk fires visit_effect_demand at it; (3) the gate's resolver already
  maps op→ename, and for a demand that resolves through an op WITH a
  default handler the refusal tightens to stateful(handler) ∧ ename ∉
  installs — sound because the singleton tier is UNIQUE-handler by
  definition, so an install of the ename IS an install of that handler
  (ename-install ⟺ hname-install); statefulness reads live from
  HandlerKind's state fields. Stateless-uninstalled stays green (the
  direct call touches no state). This read
  could not EXIST before the triple: the six-form row dropped the install's
  subtraction off unresolved tails, so main's row lied (the design was
  refuted by six micros in its first life THIS session, for exactly that
  reason) — the representation fix is what makes the diagnostic true. Also
  landed on the way, each witnessed by probe: the pure row returns as the
  wheel's OWN first top-level let (ef_pure_row, riding the init-bracket
  fix); fn env entries carry Located(decl-span) reasons at both register
  sites (the Why chain and this diagnostic read them); handler_arms_touch
  destructures CLOSED (the trecordopen-wrong-field class — the open field
  read returned garbage and the proposal missed pong); the name compares
  pin `: String` (the §9 pointer-eq class); and the diagnostics render is
  sequenced-lets — the old single 5-splice line MIS-RENDERED its last
  splice when an earlier splice's evaluation allocated (witnessed live:
  the span rendered a stale env record's span, 362:78 for 2523:4, until a
  preceding read shifted the staging — the shared-scratch clobber class at
  the interpolation emit; the sequenced form has nothing to clobber; the
  minimal-repro dig is the named residue
  Hβ.emit.interp-splice-staging-clobber). Fixtures RED-first against the
  pre-gate boot (both refusal programs compiled CLEAN, 5.6KB of WAT that
  faults at 0x100000000 at runtime): frontier mn-effect-unhandled +
  mn-effect-uninstalled (refusals) + mn-effect-absorbed (42). check/edit
  never route through the gate — the productive surfaces stay open.
- 2026-07-22 · THE BACKTICK CONTRACT REACHES ZERO (comment-refs 52 → 0,
  ratchet 0 · pin 10639d69). Morgan asked what the 52 phantoms were for —
  nothing: stale prose debt behind a tourniquet (the ratchet existed only to
  stop the number rising, and it caught this session's own fresh phantom
  before commit). Every cited symbol now resolves: dead names repointed to
  live successors (collect_fn_emit_records; MultiShot/OneShot for the stale
  Many/One spellings), deletion-history and other-scope locals unbackticked
  to prose (the contract: a backtick is a reference into the one namespace;
  narration is prose), and the checker's own leftover CLH per-comment eprint
  deleted (1,536 stderr lines every compile since the pass landed).
  comment_refs_max: 0 makes the class a hard gate — the census arming law,
  one layer up, at the prose boundary. Board whole at the pin.
- 2026-07-22 · ▶▶ THE ROW IS A TRIPLE — the six-form EffRow tree dissolves
  into ONE canonical record (the representation-law update Morgan licensed:
  "if a law written earlier now holds us back, update the law" · pin 09380a33).
  `EfRow(present, absent, tail)` with `EffTail = EtClosed | EtVar(v) | EtAll`;
  reading = present ∪ (tail ∖ absent); canonical AT BIRTH (ef_make dedups,
  absent ∖= present, empty-set identity fast paths) so no read ever
  normalizes — the normalize/retry rewrite passes, the six-arm cross-products
  in unify/union/subsumes, and the read-time chasing allocation storm are
  DELETED whole. Research-grounded, then made Mentl's own: Rémy's
  presence/absence row fields (1989, the Links lineage) carry `!E` as a FIELD
  where Koka's scoped labels chose duplicates precisely to avoid absence;
  the `~>` subtraction rides the SAME field (a pending mask on a var tail —
  the modal-effects reading of the install as a TRANSITION fact, Tang–Lindley
  POPL 2026, held as data instead of a rewrite step); and the eager literal
  difference is the Castagna/Elixir set-theoretic cure (their 1000-clause
  slowdown is this compiler's 1e5-unify OOM, same disease) — the handled set
  is always a literal, so diff_row is ef_make(pa∖pb, aa∪pb, ta), eagerly, no
  lazy BDD. The FAT-ROW ROOT this dissolves: the old normalize_inter
  open×neg arm subtracted known names and DROPPED the negation from the
  unresolved tail var, so an install typed before its body's row grounds
  never subtracted the handled effect — main's row kept every absorbed
  effect, dead evidence entries stacked, and the unhandled-effect fault at
  0x100000000 had no diagnostic. TWO one-writer rulings landed with it:
  subsumption READS (resolve_row, no binds — the E_EffectMismatch the medium
  raised on egraph's is_pure was itself the catch: a compressing read had
  made every projection a writer; the GraphWrite compression belongs to
  unify_row alone, where inference owns the bind) and the free-tail law
  re-derived on the triple (a tail still EtVar after resolve is GENUINELY
  free = vacuous at the gate — its rejection was the 646-error
  false-mismatch wave m2's first self-judgment raised, the same ~80% slice
  the six-form census once had). THE FIRST TOP-LEVEL LET the medium ever
  compiled came out of this arc (`let ef_pure_row = …`, the shared pure
  row): boot faulted at 0x100000000 emitting $__init_lets — NOT an OOM (RSS
  2.6GB of 4GB, measured; the OOM story died to /usr/bin/time) but a wild
  key-scan: emit_init_lets was the ONE emit_expr caller with no local
  `~> emit_memory_bump` bracket (every fn body rides one —
  emit_one_fn_to_string's shape), so the evidence-dispatched emit_alloc
  (three memory handlers; never singleton-tiered) scanned an unthreaded
  region into the wild address. Two hypotheses died to the artifact on the
  way (⟲): "the 4GB ceiling" (RSS measurement) and "band-N
  config-fn-evidence-in-arm" (the direct named loop reproduced the fault);
  the local bracket is the mechanism, and the init bodies now emit under
  it. Fixture tests/frontier/mn-top-level-let.mn (module
  ctor-with-empty-list-args lets) seen RED on the pre-fix boot (exit 134,
  the exact fault), GREEN through the fixed wheel (42). The wheel keeps
  mk_ef_pure() allocating until this fix pins; the shared module-let pure
  row is the named follow-up (the wheel's own first top-level let). Hygiene
  rode along: 12 six-form remnants + 23 zero-reference fns deleted (~215
  lines — normalize_row, neg_row, the list_* alias shims, dormant cursor
  variants); the comment-truth pass leaves ZERO six-form mentions in code
  OR prose (SYNTAX/PLAN trued; §4③ carries the representation note). Board:
  census 0 at every generation; ladder m2 == m3 == m4 byte-identical
  (18.8MB), size-guarded (the empty-wat cmp-equal trap closed — every leg
  asserts nonempty before diff); feedback-iir 30, handled-Ping 42,
  top-level-let 42.
- 2026-07-22 · THE AFFORDABILITY DIG, second pass — two more mechanisms
  measured, the arc's design now COMPLETE on paper (tree back at the
  green fixpoint; no re-pin). Attempt A, the identity floor
  (row_is_canonical guarding normalize_row to alloc-free identity +
  resolve_row split into a progress guard and a reduce path): the wheel
  compiled census-0 and the fixtures held, but the SELF-compile still
  OOM'd — the trap moved to normalize_inter under unify_row_canonical,
  meaning some row class permanently fails the canonicality mirror and
  rebuilds per call (suspect: same-named EParameterized instances vs the
  by-name prefix-contains — UNVERIFIED; profile with perf before
  believing, §8's law). Attempt B, containment (the pending pair bound
  behind a fresh row var, the flowing row kept in the three cheap
  forms): refuted by mechanism — a pending-BOUND tail meets open-open
  unify, which BINDING-MERGES per call (graph_bind_row on an
  already-bound tail recurses into binding-unification), so the
  subtraction cannot ride the tail slot at all. THE COMPLETE NEXT ARC,
  one landing: (1) canonical-on-write rows — normalize once at
  graph_bind_row, unify operands arrive canonical by invariant, reads
  return the stored node; (2) the deferred subtraction as an
  INSTALL-EDGE fact (the `~>` draws an edge, §2's own words) read by
  residual-row consumers, never a rewrite of the flowing row's tail;
  (3) profile-first (host perf on the self-compile) so the churn source
  is measured, not guessed — three prior code-reading estimates in this
  family were wrong (the classifier lesson repeating at the row layer).
  All comments touched in the reverted attempts carried their truths
  into this ledger; the KNOWN-INCOMPLETENESS block at normalize_inter's
  open×neg arm survives in the entry above as the site's standing
  characterization.
- 2026-07-22 · THE ROW'S DROPPED SUBTRACTION — root FOUND and fix PROVEN;
  shipping WAITS on canonical-on-write rows (no re-pin; the tree stays at
  the green fixpoint). The arc: retiring the raw-WASM error class (an
  unhandled effect compiles CLEAN then dies as `memory fault at
  0x100000000` — the ev-scan walking main's empty evidence into the
  sentinel page, MEASURED) led through three designs to ONE root.
  (1) The gate-time ROW read (E_EffectUnhandled at the executable gate,
  main's residual row minus substrate/default effects) — REFUTED by six
  micros: main's row still carried Sample past an absorbing install.
  (2) The mint-site read (an LEvRef threaded from main's frame) with an
  `ls_outer_fn_name() == "main"` guard — Morgan's own cut: a name-keyed
  special case, and Mentl must judge itself by structure, not by name.
  (3) The gate walk over ONE child projection (lowexpr_children — the
  walker-unification seed, ~40 arms once, every future walk a recursion
  over it) with a provided-set carried through enclosing installs —
  which surfaced the TRUE root: normalize_inter's open×neg arm
  `EfOpen(names, v) − handled => EfOpen(names − handled, v)` SUBTRACTS
  THE KNOWNS AND DROPS THE NEGATION FROM THE TAIL, so an install typed
  before its body's row resolved never subtracts the handled effect —
  main's fat row, and DEAD LEvRef evidence entries minted from it (the
  runtime survives only because the singleton tier never scans them).
  THE FIX, built and proven on the fixtures: the pending subtraction —
  `EfInter(EfOpen(names − handled, v), EfNeg(EfClosed(handled)))` —
  with resolve_row growing reduction arms (chase operands, re-run the
  pure reduction; the open head unions into a pending tail via the
  total union). Under it feedback-iir runs 30 AND the unhandled-Ping
  program's row is true. It cannot SHIP yet: rows are re-normalized
  PER READ (unify_row_canonical → normalize per call, ~1e5 unifies ×
  sort_unique/wrap allocations), and the pending nodes multiply that
  churn past the 4GB ceiling mid-self-compile — Carried-Truth violated
  at the ROW layer (§5.O: a normalize per read is a re-derivation).
  THE NEXT ARC, fully specified: CANONICAL-ON-WRITE rows — normalize
  once at graph_bind_row, reads return the stored node (O(1)), binds
  re-canonicalize only the affected row; the deferred subtraction then
  rides the store free, the row becomes TRUE, and E_EffectUnhandled
  re-lands in its ELEGANT first form (the row read at the gate) with
  the graph-derived proposal (handlers_absorbing — the env names which
  declared handlers absorb the effect; the diagnostic teaches the
  install; the finite candidate set is Synth's larval proposal). The
  unifying frame, banked from Morgan's charge: absence is ONE node-kind
  — the value `??`, the evidence hole, the proof hole, V_Pending — one
  gate law (productive, never executable), one proposal machinery, the
  ambient argmax ranking them, multi-shot exploring them: every
  diagnostic-with-span-and-proposal is a search position for
  Mentl-building-Mentl. Ladder-hygiene lesson, paid live: an empty
  m3.wat cmp-equal to an empty m4.wat read as a fixpoint — a gate that
  cannot fail; size-guard every ladder leg (march.sh's arbitration
  already does; my by-hand legs now must).
- 2026-07-22 · ▶▶ THE REPRESENTATION CHASE — the truth unification erased,
  carried back (pin 35e5437e). The SeqRep lattice (SRFlat | SRSnoc |
  SRRope | SRSlice | SRUnknown) is the fact every runtime helper re-derives
  per value (load tag_word; branch): minted at the construction the graph
  already knows (a literal is flat, `++` a rope, push snoc, slice a view),
  carried through local lets by the LowerScope edge ls_bind_local ALREADY
  draws (name -> the init's handle — no new state, no handler, no installs:
  the chase is a pure projection over two existing edges), JOINED at
  control merges (equal survives, a genuine merge widens to SRUnknown —
  the honest floor where the tag branch is real information), fuel-bounded
  (8 steps; exhaustion degrades sound). ONE license per match (hoisted out
  of the per-arm map — the first build allocated per arm × per chase and
  hit the 4GB ceiling on the wheel; the trap taught the hoist). The first
  consumer: a proven-flat word-stride scrutinee's list pattern emits raw
  POff(8+4i) loads — ZERO $list_index calls, bounds proven by the
  pattern's own length test — the exact bytes the pre-PIdx emitter
  ASSUMED for every list, now proven per receiver; rope and snoc stay on
  the total reader. Measured on the three-representation fixture: flat =
  0 calls/2 raw loads, rope = 3 calls, snoc = 2 calls, one behavior
  (mn-seq-rep-license, frontier). Named consumers next: xs[i] under the
  license (needs a proper bounds-composed low node), the spec bracket
  carrying rep pairs (generic bodies get proven reps — the twins' next
  axis), and the per-fn rep summary (interprocedural). Board whole:
  census 0, frontier 174/0, proof-exactness 9/9, crown 5/5, micros
  green, clean m2 == m3 at the pin.
- 2026-07-22 · THE COMMENT SCAFFOLDS DISSOLVE INTO THE COMPILE (absorption
  complete, no re-pin — tools only). tools/comment-audit.sh and
  comment-ratchet.sh are DELETED: the medium's own W_CommentRefUnresolved
  pass (every compile's infer tail) is the classifier, and verify.sh's
  census step ratchets its count off the SAME m2.err the census already
  reads — zero extra passes, comment_refs_max in the baseline (52 at
  absorption; the ratchet drives it to 0). state.sh's separate PHANTOMS
  gate dissolves into verify; the pre-commit hook keeps only the semantic
  reminder (content-matches-code is the judgment no resolver makes). This
  is the ratchet script's own written destiny executed: "both ratchets
  dissolve together into mentl audit, which is the projection they are
  larval forms of."
- 2026-07-22 · ▶▶ FIELD OFFSETS PROJECT AT EMIT + THE STRUCTURED ENC — the
  monomorphization machinery generalizes from repr to STRUCTURE (pin
  09f9706a). The last lower-time layout bake moves to the read: LFieldLoad
  carries a SELECTOR (FByName / FByIndex — the FieldSel ADT), and ONE
  projection (field_sel_offset) resolves it at emit through lookup_ty under
  the active specialization bracket — record fields, tuple slots, and the
  record-update copy path (which now projects off BASE's handle, healing the
  added-field layout split) all read live. The spec enc stops speaking repr
  only: a structured concrete encodes as its fold_sig (wide digits unchanged
  — existing twin names stable), so structure-bound sites become candidates,
  and the worthiness witness generalizes to spec_ty_needs_structure — the
  floor lies about ANY operand beyond the true word scalars (wide, string,
  list, record, tuple, payload sum; a nullary-only sum is word-honest, read
  from the variant specs). 128 structured twins emit on the wheel;
  in_owner_names' `==` on [String] HEALS BY TWIN and its Intent-Boundary pin
  is DELETED — the eq-on-generic-String class (pointer-eq under the word
  floor, the §9 class) closes systemically, by specialization instead of
  annotation. Twin emission hardened en route: nested-lambda contributions
  dedup by mangled name (two parents, one lambda, one enc), and every
  generated fold-leaf opener declares the state-insert scratch trio (a
  tuple-with-sum sig's conjunction recursion emitted undeclared locals — an
  assembly failure no prior sig shape reached). The one remaining pin family
  is characterized exactly: cl_state_names/cl_arm_names read fields of a
  CONSTRAINED-open record — TRecordOpen, which the TVar-shaped witness
  misses, and whose offsets over a partial field set are the wrong-field bug
  — the row must resolve under the bracket; that dig deletes the last two
  pins. Ladders ran two-stage disposable (W1 pinned under boot → m2 → the
  unpinned wheel → m3 == m4). Board whole at the pin: census 0, frontier
  171/0 (+rope-list-pattern — the pa11 crucible), proof-exactness 9/9,
  crown 5/5, micros green, phantoms 220 → 54 with the ratchet lowered.
- 2026-07-22 · THE TEST VERB COMPILES THE BATTERY IN-PROCESS + the region
  substrate (CLI absorption stage 2 · pin 658f3988). `mentl test <dir>`
  forks on the target's own shape: a DIRECTORY is the battery
  (fs_list_dir_impl — fd_readdir joins io.mn's transport set; a file stays
  the single check). Each micro declares its oracle in its first line
  (`// expect: N`, the 112-micro sweep c63a0a47 — the expectation is graph
  content ON the artifact, never a side-table row); each compiles
  IN-PROCESS under a fresh handler chain (verdict = holes + refusals, the
  check verb's own licence), WAT under .build/test/ beside a streamed
  manifest line; execution stays the shim's seam (WASI owns no
  process-spawn — the process_exec precedent). One process replaces a
  wasmtime boot per micro. The REGION substrate landed with it: Alloc
  gains heap_mark()/heap_reset (emit = the bump global read/written, the
  §5.O arena's first grain), gated RED-first (mn-heap-region: a reclaimed
  region's next alloc returns the SAME address; 134 on the pre-arm pin, 42
  here). The honest residue: bracketing each battery compile with
  mark/reset traps compile #2 in its own infer while EVERY input is
  probe-verified intact (libs len+head+tail, the names, the reset
  address), and WITHOUT the reset 100 compiles run clean to the 4GB
  ceiling — 12 short of the battery. The no-reset form ships; verify.sh
  keeps the per-process loop as the gate; the peer
  Hβ.runtime.cross-compile-durable-state (named-residue index) carries the
  corpus, and closing it IS the arena's first real workload. Board: census
  0, frontier 168/0 (+heap-region), proof-exactness 9/9, crown 5/5, micros
  green, clean m2 == m3 self-confirmed at the pin
- 2026-07-22 · THE HYGIENE WAVE + three rulings banked (no re-pin — the
  wheel untouched). DELETED per Morgan's ruling (git is the archive, no
  archaeology ceremony): docs/specs (2.2M), docs/research (1.3M),
  docs/errors, docs/traces, DESIGN.md, SUBSTRATE.md, ULTIMATE_MEDIUM(.md +
  _DIAGRAM), SYNTHESIS_CROSSWALK.md, EFFECTS.md — docs/ is now the three-doc
  contract plus the three live working artifacts (NATIVE.md, DESIGN_SYSTEM.md,
  MENTL_EDIT.md); every dangling pointer in PLAN/SYNTAX rewritten as a
  git-history note. .build purged 579GB → 21M (keyed m2cache kept).
  tests/repro dissolved (all repros graduated to gates). THE PHANTOM RATCHET
  made PRINCIPLED: comment-audit resolves a cited symbol against wheel source
  UNION the emitted artifact's own namespace (read live from m2.wat —
  normalized __-prefixes and _<handle> suffixes; the artifact IS the
  namespace) UNION the three docs' design vocabulary (fn_ptr / tag_word /
  nstate resolve against the design's source exactly as fns resolve against
  code) — 286 → 231, baseline ratcheted down; the residue is genuinely
  stale prose (the hand-sweep is the named follow-up, frame_k's defining
  home included). THREE RULINGS BANKED: (1) Hβ.voice.script-is-projection —
  the mentl voice is NOT a model: it speaks only the author's own comment
  prose, graph projections (types/rows/Reasons/spans), and a fixed template
  grammar composed of them — easy enough to teach anyone, deep enough along
  the gradient that the hardest developers feel the floor under every word;
  (2) Hβ.compile.fixpoint-is-larval-forked-cursor — every hand-rolled
  worklist/fixpoint in the wheel (the spec demand analysis, classify_fixpoint,
  reach, worthiness) is a larval FORKED-CURSOR SEARCH; when trail-fork lands
  as compile substrate each rewrites as forks with rollback (Morgan's own
  call: 'why build a worklist when we could have built a forked cursor
  search'); (3) the anti-drift safeguards (drift-audit, the hooks, the
  discipline prose) are LARVAL mentl audit — when the medium is real they
  dissolve INTO it (§0's own convergence: the gate that keeps an LLM honest
  is the gate that keeps every proposer honest), so the hygiene endpoint is
  absorption into verbs, never deletion of the safeguard
- 2026-07-22 · ▶▶ THE LSHOW/LHASH BUILD — the LAST lower-time type bake moves
  to emit; FOUR latent breaks close (monomorphization face 7 + band D's leaf
  seam · pin f60110f4). to_string/hash are STRUCTURAL nodes dispatched at
  emit under the active bracket (show_node_of/hash_node_of — one dispatch
  home; every walk delegates through it; scalar sites byte-identical), so a
  twin's render shows the VALUE and its hash agrees with its eq; a
  render-only generic still twins (the operand is a worthiness witness).
  The four closures, each probe-pinned RED first: the aggregate leaf call is
  DIRECT (§5.U's own law — the closure-convention form referenced a
  $show_<sig> global NO module ever emitted, an assembly failure in every
  minimal module); the leaf's interior renderers survive reach
  (show/hash_reach_names — int_to_str was pruned); the decor literals
  register (the fold_closures.show CALL-SITE field read resolved a wrong
  empty slot — Hβ.lower.trecordopen-wrong-field measured LIVE: n=0 at
  register vs n=1 at generation from ONE record; fixed by passing the whole
  closed-annotated record); and hash(x) gains its declaration (the to_string
  mirror — the name NEVER resolved; the hash surface was unreachable from
  user code). Twin fold collection runs per-demand under its bracket
  ($show_ld beside $show_li). Gates: mn-generic-show (RED: address render) ·
  mn-aggregate-show (RED: assembly failure) · mn-aggregate-hash (RED:
  E_MissingVariable) — all 42; frontier 165/0; census 0; TRANSITION
  m3 == m4 with the new wheel SMALLER (the name-bake machinery deleted).
  The monomorphization arc's residue is now EMPTY of known silent-wrong
  faces; wide_call_seed / is_show_global / is_hash_global / the five lower
  dispatch fns are deleted whole
- 2026-07-22 · THE EXACT-SUBSTITUTION SWAP — monomorphization face 3 CLOSES
  (the multi-type unlock · pin 4a114123). The bracket carries the site's
  EXACT instantiation pairs (root -> concrete); a free leaf answers its OWN
  root's binding; a root not in the pairs stays the honest floor TVar; the
  one-wide-type guard is DELETED (the free-leaf rule and its guard were
  scaffolding around the subscript fracture, retired with it). Mixed
  instantiations twin: sqboth at (Float, Int) -> $sqboth$sp20 squares the
  f64 AND the i32 natively in one body. Gate mn-generic-multitype RED (1)
  on the prior pin, 42 now; frontier 156/0; census 0; clean m2 == m3. The
  monomorphization arc's named residue is now ONE face: the lower-time
  show/hash bake (band D's leaf work — the LShow/LHash build)
- 2026-07-22 · THE SUBSCRIPT FRACTURE FIX — Force = UNIFY, never overwrite
  (infer.mn IndexExpr · pin da45bcdd). The xs[i] sugar arm graph_bind-
  OVERWROTE its receiver, discarding the proven TList(elem) and orphaning a
  fresh element class per subscript — the union-find FRACTURE beneath the
  monomorphization free-leaf rule, pinned by an adversarial worktree agent
  (probe: merge's condition subscripts rooted at 13777, its param element at
  13793; the unify fix collapses them to ONE class, agent-verified). Its
  sibling seq_force one table over states the law verbatim. Both forces now
  unify; the §4① String seam holds (a proven-TString receiver SATISFIES the
  force, s[i] binds TByte — sharper than the old clobber). The REFUTED
  hypothesis is the record's point: my own "instantiate-shares is the root"
  died to the artifact (instantiate heals through argument unification,
  polymorphic recursion included) — the adversarial dispatch existing so the
  orchestrator's label could be killed by a probe. UNLOCKED, named: exact
  root-keyed substitution (replacing free-leaf) and the multi-type-generic
  guard lift, now that a generic body's element classes are one root.
  TRANSITION m3 == m4; census 0; frontier 153/0; proof-exactness 9/9;
  crown 5/5. Sibling finds from the same ultracode wave, banked: to_string/
  hash are the ONLY remaining lower-time type bakes (the D3 map — everything
  else already reads under the emit bracket; the build moves them to a
  structural LowExpr node dispatched at emit), and a pre-existing LOUD break:
  to_string((1,2)) in a MINIMAL lib set emits calls to $show_<sig>/$int_to_str
  that reach never kept and no static closure global backs — assembly
  failure, masked in the full battery by richer lib sets
  (Hβ.emit.generated-helper-reach — the show-face reach arms fix it as a
  side effect when the emit-dispatch build lands)
- 2026-07-22 · NESTED-LAMBDA TWINS — monomorphization residue face 1 CLOSES
  (Hβ.emit.spec-nested-lambda-twin LANDED · pin a919906d). A lambda born
  inside a generic body twins under the parent's instantiation with ZERO body
  rewriting: the worthy demand contributes every record nested in its body
  (mangled with the parent's enc), and the closure-mint arm redirects the
  record's table index through the bracket's active enc (spec_closure_name —
  the LGlobal redirect's closure-mint face, registry-gated; captures,
  self-binding, local naming keep the original name). Bracket state widened
  to (spec_wty, spec_enc) on the one LookupTy handler. The landing FORCED a
  width-consistency fix with reach beyond twins: a param used ONLY inside a
  nested closure had no param-decl width source (find_local_handle_expr
  stopped at the closure boundary) while the capture-store read the live
  handle — (param $k i32) declared, $k.f64 read, an assembly break; captures
  and evs are PARENT-frame expressions and the walk now reads them. Gate
  mn-generic-nested-lambda RED (1) on the prior pin, 42 now; frontier 153/0;
  census 0; clean m2 == m3. Remaining faces: the lower-time show/hash
  dispatch (mn-generic-show-lower-dispatch, band D's leaf-as-lowered-LFn)
  and multi-type generics (the uniform-wide guard)
- 2026-07-22 · ▶▶ NAMED-GENERIC MONOMORPHIZATION — the §5.U scalar half LANDS
  (Hβ.value.seq-element-stride-carrier's monomorphization face · pin 92fceff0).
  A named generic fn compiled ONCE at the RI32 floor and, reached at a Float
  instantiation, compared/added the word-protocol REFERENCES (prelude `sort`
  returned its input in allocation order; `reduce(xs, min)` picked by address —
  the data-validator tier's harvest, silent-wrong, zero diagnostics). Now: emit
  runs a DEMAND ANALYSIS — each reference site's instantiation is a PROJECTION
  off the live union-find (scheme type walked against the site's resolved type;
  zero new storage, zero infer changes — Carried-Truth: the unifier already
  drew the edges, the walk reads them), a site whose quantified vars land on
  ONE distinct wide type is a candidate, and a candidate is WORTHY when its
  body performs arith/compare/eq on a free-floored operand OR an interior site
  redirects to a worthy twin (the transitivity fixpoint: sort twins because
  merge is worthy — no recursion special-case; plumbing shells like fold/map
  stay floor, which the word protocol keeps CORRECT — twins only where the
  floor is WRONG). A worthy twin is the SAME record emitted once more under
  the SPECIALIZATION STATE: lookup_ty_graph carries spec_wty (set/cleared
  around the twin's emission), and while set a FREE var answers the wide
  instantiation — the free-leaf rule, FORCED by the artifact (probe: a generic
  body's unresolved classes FRACTURE — merge's param element roots at 13793,
  its comparison operands at 13777 — so no root-keyed mapping is complete;
  one-wide-type demands make every free unambiguous, and multi-type generics
  stay floor as the named residue). THREE hard-won mechanisms, each
  probe-pinned RED first: (1) STATE-swap, never a second handler — a second
  LookupTy handler demoted every lookup_ty out of the singleton
  direct-dispatch tier (16 frontier reds: ev-scan faults at infer sites that
  never threaded evidence); (2) the order-conditional row class — wasm.mn
  sorts before types/lower in the wheel, so INFERRED rows disagreed between
  Tier-2 callees and bare callers (a 4GB ev fault): every spec fn DECLARES its
  row, the build_reach_index precedent; (3) the concat floor at wide_all — an
  open element through a filter-with-handler chain, closed by the declared
  [String] Intent Boundary. Twins ride every name surface appended (table via
  $wf$ word faces when wide, idx globals, static closures); LGlobal/LFnRef
  redirect through spec_target_name gated on spec_registry (SpecTwins — the
  StringTable pattern), the spec_twins_exist fast path keeping twin-free
  modules at one op per reference (Law 7: Int instantiations byte-identical).
  Gates seen RED: tests/frontier/mn-generic-float-{accumulator,comparator}.mn
  run 1 (silent-wrong) on the pre-spec boot, 42 now — the two repro files
  GRADUATED into them (deleted). CFC's annotation discipline becomes OPTIONAL
  (annotated accumulators still valid Intent Boundaries, no longer required
  for correctness on these shapes). Residue, probed the same day and BANKED
  with a repro (tests/repro/mn-generic-nested-lambda.mn):
  Hβ.emit.spec-nested-lambda-twin — a lambda BORN INSIDE a generic body is a
  separate record emitted once at the floor, and the twin's closure mint still
  references the floor lambda's index; the fix is the same mechanism one level
  deeper (nested records join the demand under the same wide type + a rename
  walk), first witnessed by scale_all$sp22 delegating to its floor lambda.
  Second face, probed the same day (tests/repro/mn-generic-show-lower-dispatch
  .mn): a LOWER-time type dispatch inside a generic — to_string(x)/hash(x) —
  is invisible to the emit bracket twice over (the binop-only worthiness
  witness never counts a call, and lower already committed the word-show path
  into the LowIR: describe(2.5) prints the ADDRESS). The ultimate is band D's
  own show/compare-hash-leaf-as-lowered-LFn work, which moves those reads to
  emit where the bracket specializes them.
  Board whole: census 0, frontier 150/0,
  proof-exactness 9/9, crown 5/5, micros green, m2 == m3
- 2026-07-22 · THE DATA-VALIDATOR TIER — three real-workload oracles the
  fixpoint cannot be (no re-pin — tests + gate only, the wheel unchanged;
  m2 == m3 held). Three on-disk validators, each cross-validated against an
  INDEPENDENT implementation over the SAME bytes (the representation-stress
  leg: a byte-identical wheel can still corrupt user data, and only a second
  implementation agreeing on real data catches it): (1) cfc-rec — the CFC
  comodulogram on a REAL 4096-sample recording (WASI fs → view-split →
  parse_float → native [Float]), a 6→60 coupling DISTINCT from the inline
  demo's 6→40, Mentl and a faithful numpy port of cfc.mn both argmax flat 7;
  (2) stats-float — fold-sum mean, comparison-reduction argmin/argmax,
  mean-threshold count over 400 samples, three discrete facts EXACT against
  numpy (argmin 137 / argmax 298 / above 199 — discrete, so no ULP
  tolerance); (3) text-bytes — the String=[byte] merge's first real-text
  gate: byte_len / byte_at / structural == / a 256-slot histogram argmax
  over a 429-byte corpus, four facts exact against python. Every gate seen
  RED first (reversed data, perturbed text, a 6→40 recording — Mentl and
  the oracle shift TOGETHER, so the assertions are data-driven). Frontier
  135 → 144 / 0. Fixture transport hardened: the gate's own per-run dir is
  mapped as the guest's /tmp (wasmtime --dir "$dir::/tmp"), so the host
  never writes the shared world-writable /tmp (the predictable-path symlink hazard
  a commit-review flagged) — .mn sources keep their /tmp paths. THE HARVEST
  the validators paid immediately: building stats-float surfaced the
  monomorphization corner's SECOND face — a NAMED generic comparator passed
  higher-order (`reduce(xs, min)`) and prelude `sort` (resting on the named
  generic `merge`) silently MISORDER floats. Mechanism confirmed by probe:
  the word protocol passes each f64 by reference, the bump allocator hands
  out ascending addresses, and the i32-floored `<=` compares ADDRESSES — so
  sort returns its input order unchanged (values intact, order garbage,
  zero diagnostics). The precise scope rule, replacing two earlier
  narrower framings: lambdas and annotated helpers are SOUND (specialized
  per call site — map/filter/fold/each/reverse and every annotated
  accumulator); any NAMED generic fn compiled once at the i32 floor and
  reached at a wide type is NOT. Repros banked:
  tests/repro/mn-named-generic-float-comparator.mn (+ the accumulator
  sibling's scope note corrected). The ultimate — per-call-site
  monomorphization of named generics — LANDED the same day (the entry
  above); both repros graduated into frontier gates and were deleted
- 2026-07-21 · THE CFC PIPELINE RUNS ON NATIVE [Float] + the generic-over-wide
  keystone EVIDENCED (no re-pin — lib/dsp/cfc.mn is a leaf the compiler compiles
  but never calls, so m2 == m3 held directly). The cross-frequency-coupling
  research pipeline (lib/dsp/cfc.mn + the demo) sheds its fixed-point-Int carrier
  — the 2026-07-19 workaround for "a [Float] list does not round-trip today" —
  and runs on NATIVE f64 samples, phase/amplitude columns, and comodulogram
  matrix, finding the planted (6,40) coupling (frontier cfc-demo exit 42, 65
  fewer WAT lines: to_fixed/from_fixed/cfc_scale DELETED). This is the §5.U
  wide-element cash-out validated on the real workload — representation stress
  on real DSP, the verification leg that catches what m3==m4 cannot. The
  migration surfaced, by that same stress, the OPEN half of
  Hβ.value.seq-element-stride-carrier, EVIDENCED with a minimal repro
  (tests/repro/mn-unannotated-float-accumulator.mn). That peer names TWO
  solutions — a runtime stride carrier OR whole-program monomorphization; the
  STRIDE CARRIER shipped (7db29195) and made the SEQUENCE-READ sound (list_index
  reads the element stride live), so this is NOT the sequence read (that runs
  with an annotated accumulator). It is the MONOMORPHIZATION half, on a SCALAR:
  an UNANNOTATED float
  accumulator threaded through recursion (`sum(xs,i,acc) = sum(xs,i+1, acc +
  list_index(xs,i))`) leaves `acc` a type var when the body is checked (the list
  element is free), so the fn compiles ONCE at the RI32 floor — `(param $acc
  i32)`, `(i32.add)` — and a native-f64 [Float] call reads the f64 values as
  words: the sum is garbage (~0), exit 1, ZERO diagnostics. A generic function
  over a wide element compiled at the word floor cannot serve a Float
  instantiation; this is the SILENT-WRONG class (the friend's "m3==m4 is not a
  sufficient oracle" made concrete). The ULTIMATE is monomorphization or a
  runtime stride carrier; the HONEST INTERMEDIATE (broken -> diagnostic, never
  silent) is a REFUSAL where a wide-repr argument meets a word-repr parameter of
  a generic body. CFC dodges it by annotating every float accumulator (re/im/
  sc/ss/best: Float — the representation pin the gradient needs at a polymorphic
  boundary), and all annotated-[Float] paths are broad and green (literals, ==,
  ordering, arithmetic, show, map, threaded annotated accumulators, matrices,
  list-of-[Float] — verified by an 8-case representation-stress battery). SCOPE:
  this entry's second framing ("only named recursion floors") was ALSO
  incomplete — superseded by the 2026-07-22 validators entry above, whose
  measurement is the precise rule: any NAMED generic fn compiled once at the
  i32 floor and reached at a wide type is the floor (unannotated recursion AND
  named comparators passed higher-order, prelude sort/min/max included);
  lambdas and annotated helpers are sound. Board green: m2 == m3, frontier
  cfc-demo 42, census 0
- 2026-07-21 · EFFECT-POLYMORPHIC STORED FUNCTIONS + the mentl verb table
  (a hole in the medium closed, and the CLI overhaul it unblocked · pin
  1167ddfe). A first-class CLOSURE carrying its own effect row can now be
  STORED in an ADT field and called — the medium carries functions-with-
  their-rows through data, the same capability handlers rest on. The root
  was in the inferencer: quantify_ctor_ty (infer.mn) passed a function-typed
  ctor field's effect ROW through UNQUANTIFIED, so its open tail was a single
  free var that finalize closed to Pure — every effectful stored closure then
  "violated Pure," and a table of heterogeneous-row builders could not
  typecheck. TWO sub-roots: parse_type_ty minted the function-type row var as
  a TYPE handle (fresh_handle → graph_fresh_ty), which free_in_row never
  collects and instantiate cannot freshen; and quantify_ctor_ty never added
  it to the quantified set. quantify_ctor_row re-mints the open tail as a
  genuine row var (graph_fresh_row / NRowFree) and quantifies it; result_ty
  filters row handles out by node-kind (is_row_handle) so the type stays
  non-parametric; instantiate's is_row_handle → mint_row already freshens a
  quantified row var, so each ctor use gets a fresh row and the list unifies
  the builders' rows by the row algebra. This is the Carried-Truth Law at the
  type layer: the function's effect row is a fact the graph proved and
  quantify_ctor_ty DISCARDED. The fix UNBLOCKED the CLI overhaul (Morgan's
  ask): the verb set had three drifting homes — the hand-written verb_catalog
  help, the `if mode == "..."` parse chain, the dispatch match — now ONE
  VerbSpec table (name, arg-hint, BUILDER CLOSURE, description) projected by
  both find_verb (the closure builds the typed Invocation, or a per-verb
  ParseError naming the missing argument — a better message than the old
  generic one) and verb_catalog (the help, padded from the same rows), so
  they cannot drift; the address probe and dispatch match are unchanged. An
  earlier pass HERE sidestepped the inferencer hole with a VerbBuild data-tag
  (a name build_invocation re-derived the construction from — drift-8 + a
  Carried-Truth re-derivation, the closure IS the edge the tag re-derived);
  Morgan caught it, and the ultimate form is the closure carried directly.
  Witnessed RED→GREEN on the wheel's OWN census: the verb table drove it from
  7 E_PurityViolated (unfixed boot → m2) to 0 (fixed m2 → m3), then m3 == m4
  byte-identical, re-pinned boot holds the clean m2 == m3. Board whole:
  census 0, frontier 131/0 (+stored-fn-effect-poly capability test),
  proof-exactness 9/9, crown 5/5, micros green, phantom 286. Residue, named:
  parse_type_ty still mints EVERY function-type row var as a TYPE handle (the
  localized ctor-field fix corrects it only where it's load-bearing; the
  global parser fix is higher-blast-radius, sequenced); and the isolated
  stored-fn fixture is a capability smoke test, not the fix's discriminating
  gate (the generalization-to-Pure needs the full 14-builder context — the
  wheel census is the trusted gate)
- 2026-07-21 · ▶▶ THE WIDE-ELEMENT [Float] CASH-OUT (§5.U's stride carrier
  reaches its first wide element · pin 683d66cb). [Float] is a first-class
  packed sequence end to end, and the SAME landing kills the
  float-evidence-ft class ("all the birds, one stone"). The WORD PROTOCOL is
  the keystone: "a handle IS a word", so the generic/indirect boundary speaks
  WORD-ARITY only — a wide value (f64, stride 8) crosses BY REFERENCE, its
  address its word face (emit_wide_ref spills to a fresh cell + f64.store and
  leaves the address; emit_wide_deref cashes back via f64.load; call_ft_name
  is always $ft{arity}, the per-site repr-vector $ft DELETED as unsound at
  polymorphic sites). A wide-signatured fn — named (`scale`) OR a capturing
  lambda — reaches the fn table through a `$wf$<name>` word-face WRAPPER
  (deref args, direct-call the native body at full speed, spill the wide
  result), so a polymorphic call site never needs the callee's emission. The
  literal is born stride-8 (make_list_sc, the allocator's second face paired
  with make_list); load_strided's wide arm returns the ADDRESS, store_strided
  mem_copies stride bytes from the reference; structural == compares VALUES
  via list_eq_f64 (deref each element — the word list_eq would pointer-compare
  them), with list_compare_f64/list_hash_f64/float_to_str the ordering/hash/
  show leaves. The reach walk CONTRIBUTES the f64 family at the exact
  ==/ordering/show/hash mint sites (reach_names_expr's wide_binop_seed/
  wide_call_seed reading the operand's live type through ty_has_wide_seq) —
  the visitor-walk projection of the runtime contract the emit-side comment
  names, so a float-free module drags in nothing and the reach index's row
  widens honestly to LookupTy + EnvRead. One real emit bug fixed en route
  (§9 wrong-scratch class): emit_wide_ref used $state_tmp for its spill cell,
  clobbering the closure record a capturing lambda holds live there — the
  k-cell was then read as a fn record → indirect-call mismatch; a dedicated
  $wide_cell local closes it. TRANSITION m3 == m4 (the 6056-line m2/m3 diff
  is the emit change crossing one generation), then the re-pinned boot holds
  the CLEAN m2 == m3 fixed point. Board whole: census 0, frontier 128/0 (+4
  wide-element fixtures list/map/hof/show, RED-first where f64.const into an
  i32 slot did not even ASSEMBLE), proof-exactness 9/9, crown 5/5, micros
  green, phantom 286. Residue, named: the RI64/RF32/RV128 producers (the
  wide-ref/deref arms stand as loud floors until an i64/f32/v128 producer
  exists — the wide-element mechanism is complete, only its other reprs
  await their first values), and the visitor-walk projection swallowing the
  rest of emit_runtime_contract's static list (str_eq/list_eq/… — the wide
  family proved the pattern; the deeper dissolution is the same walk widened)
- 2026-07-21 · ▶▶ THE STRING=[BYTE] MERGE LANDS WHOLE (§4①'s biggest
  dissolution · pin dbcaca3e). String IS a stride-1 byte list, end to end:
  TString unifies with [byte] in unify_types (nullary, no alias clone, no
  mint changes; a generic element binds TByte), the physical record is the
  unified [count][tag_word][bytes@+8] (literals via the emit's 8-byte
  header; every builder through bytes_buf; io/net/json/lsp_frame/persist/
  driver/main off the +4 layout), byte_at IS list_index, `++` IS the O(1)
  concat node (strings inherit the rope; str_concat_all is the two-pass
  N-ary packer — the right-fold form stack-exhausted, measured on the first
  ladder run), str_slice IS the slice node, and the sign-bit VIEW machinery
  is DELETED (view_base → str_payload, the stride-normalizing
  materialization boundary: a rope/slice flattens, a wider-stride [byte]
  repacks, exactly where WASI demands contiguity). TByte~TInt landed as
  CHECK-LEVEL value-equality (same_ground, never a binding — forced by
  datum-last inference: map((b)=>b-32, s) types the lambda while b is FREE,
  so operator-scoped directional widening can never fire; the earlier
  "directional at the operator" ruling was internally contradictory on its
  own flagship example). The slot stays protected where slots actually
  live: reads via the carrier, writes via store_strided's 0..255 range trap
  (the bounds-trap precedent; the exit-134 fixture), construction follows
  the RESULT type, boundaries normalize stride. unify_types gained its
  missing TByte scalar arm (the catch-all had refused Byte vs Byte).
  list_to_flat split to two altitudes (table-typed [a]→[a] over flat_raw,
  the make_list/alloc_list precedent) — that ONE root was the whole
  13-entry libs-isolation shadow (iterate/reduce/unique/chunk); the shadow
  is now EMPTY. Landed via the two-stage DISPOSABLE ladder: boot compiled
  W1 (old layout + new compiler) → m2; m2 compiled the real tree →
  m3 == m4 == m5 byte-identical — m3 == m4 DIRECTLY, so the migration is
  behavior-preserving for the compiler's own computation; W1 discarded,
  zero permanent compat. The NINE-fixture behavioral battery
  (map/fold/filter/eq-concat-push/slice-index/interp/cross-stride-eq/parse/
  range-trap) joins the frontier gate — the oracle the fixpoint cannot be
  (it is structurally blind to string corruption) — RED-first under the
  pre-merge boot (15 refusals). Board whole at pin: census 0, frontier
  116/0, proof-exactness 9/9, crown 5/5, micros 72/72, phantoms 287→286.
  Residue, named: Hβ.infer.byte-narrowing-ground-discharge (compile-time
  ground 0..255 narrowing on top of the runtime trap),
  Hβ.emit.int-splice-empty (pre-existing — probed byte-equal under the
  pre-merge boot), the wide-element stride cash-outs ([Float]/[i64] ride
  the reserved sc codes), and TString's final dissolution into a pure
  alias edge under name-interning (§5.O layer 1)
- 2026-07-21 · THE STRIDE CARRIER LANDS (7db29195; the §4① substrate keystone)
  + the merge FULLY DIAGNOSED. A sequence carries its element stride in the free
  HIGH bits of its existing tag word (tag_word = sc*16 + tag; zero-biased so sc 0
  => stride 4 and every current list is byte-identical; only a byte writes sc 1).
  decode_stride/pack_tag/seq_stride/seq_tag/seq_sc/load_strided/store_strided in
  lists.mn (load_strided BRANCHES load_i8/load_i32 — no padding); stride_class in
  types.mn; alloc/list_set/index/push/concat/slice/flat_fill thread the stride;
  snoc/concat/slice nodes carry the parent's sc (self-describing). The flat leaf
  reads the stride LIVE, so a generic body over a packed sequence never assumes
  4 — the substrate that makes String=[byte] SOUND. m2==m3==m4, census 0, 72
  micros green. One real bug fixed en route: decode_stride belongs in lists.mn,
  not the type layer (the micro RTLIBS blob has no src/). The TYPE-MERGE HALF
  (unify_types String↔[byte] both arms, same_ground cross-arms, fold_strip
  TString => TList(TByte); TString STAYS NULLARY — no TAlias clone, the OOM
  dodged; no mint site changes) was BUILT then REVERTED: an 8-agent build cycle
  PROVED (binary, not theory) it is INSEPARABLE from the physical migration —
  alone it TRAPS m3, because str_eq now lowers to $list_eq => list_index_unchecked
  which reads a string's +4 CONTENT byte as a tag word (garbage => unreachable),
  first hit in env_resolve's interned-name compare while self-compiling. THE
  REMAINING ULTIMATE, sequenced (land ATOMICALLY, never the merge alone): (1) the
  physical +8 layout migration — strings become [count][pack_tag(0,1)][bytes@+8]
  (identical to a stride-1 list), ~50 raw +4 sites across strings.mn + io/net/
  lsp_frame/json/persist/driver/main + the emit_string_data/string_literal_collector
  8-byte header + emit_list_literal stride + the show byte-guard (show_subtys skips
  a TByte element's list-show helper, or "hi" renders "[104,105]"); (2) the
  DIRECTIONAL TByte→Int arithmetic coercion (Hβ.infer.seq-addr-downcast) — REQUIRED
  even for map((b)=>b-32, "abc"): list_index returns the element TByte, byte
  arithmetic needs Int, and TByte does NOT unify with TInt (the value is an Int-repr
  word, the SLOT is stride 1 — a byte-value-to-Int widening at the operator,
  result Int, preserving fold-distinguishability so a [byte] never collapses to
  stride-4 [Int]); (3) the two-stage DISPOSABLE bootstrap (no permanent compat —
  boot emits old +4 literals; W1 reads +4/emits +8 → m2 works; W2 reads +8 →
  m3==m4; re-pin; W1 discarded). The BEHAVIORAL BATTERY (map/fold/index/==/concat/
  show over real strings, output-checked) is the LOAD-BEARING gate — the fixpoint
  oracle is structurally blind to string corruption (census 0 and m3==m4 both hold
  for a byte_at-disciplined wheel while user code corrupts)
- 2026-07-20 · THE STRING=[BYTE] TYPE-MERGE SHORTCUT REFUTED (a proven
  NEGATIVE that redirects the arc; no code shipped, STEP 0 stands): a 6-agent
  adversarial ultracode pass (wf_b7ba2a2e-22c) killed the naïve `String →
  TAlias(TList(TByte))` merge on the EXACT regression band D names —
  `map(f, "hi")` TYPECHECKS (the ordinary structural `[a]`-peel binds
  a:=TByte) then CORRUPTS at runtime, because iterate_from's `xs[i]`
  (prelude.mn:53/63) compiles ONCE with its element a TVar (repr RI32) → the
  generic 4-byte-stride list_index reads a string's content-byte-4 as a tag
  and pointer-chases garbage. Emit-selection CANNOT redirect a TVar element
  (it specializes only at CONCRETE sites), and the m3==m4 oracle is BLIND (the
  wheel is byte_at-disciplined, never maps a string) — a clean E_TypeMismatch
  today becomes silent memory corruption over the whole map/fold/each surface.
  Three more confirmed: the mint enumeration was ~4× incomplete (missed
  infer.mn:4922 + the ~11 is_seq_op result-binds, so the shortcut can't even
  reach census 0), the type-merge OOM is type-node bloat (TString sentinel → a
  2-record TAlias ×instantiate-clone, NOT the ev-slot mechanism I'd cited), and
  the fold-dissolution offsets by repr_width=4 not stride_of=1. VINDICATES band
  D's representation-first / wide-elements-first sequence; the TRUE keystone is
  `Hβ.value.seq-element-stride-carrier` (a runtime stride carrier or
  monomorphization for generic-over-packed traversal), proven on WIDE elements
  BEFORE String is minted TList(TByte). The lesson is CLAUDE.md ⟲: the design
  is a hypothesis until an adversary refutes it against the artifact — this one
  died before a byte changed (§5.R band D peer sharpened in lockstep)
- 2026-07-20 · THE §4① STRING LAYER TYPES ITSELF — the expect_same root fix
  lands, no compromises (Hβ.infer.expect-same-chases-bound-var; census held 0
  the honest way). A Float POSITIONAL ctor field from an unannotated param
  (`type Box = MkBox(Float)`, `fn wrap(g) = MkBox(g)`) left `g` an unresolved
  var — expect_same, the LONE unify arm that bound a var without chasing,
  CLOBBERED the arg reference's NBound(TVar(binder)) live binding, orphaning
  the binder — so g floored to i32 and the f64 call site trapped indirect-call
  (the ctor-arg face of float-evidence-ft; it also blocked LSP serve on json's
  parse_number Float). The one-line fix (chase the var live, like every other
  arm) UNMASKED the runtime's pervasive handle-word pun, so foundational
  correctness demanded typing the string layer whole: byte_len/byte_at/str_slice/
  str_concat/view_base/the float builders are seq-ops (typed calls over
  self-consistent raw bodies, the list_index pattern); str_of_buf is the ONE
  construction boundary (§4① — a raw [len][bytes] buffer word IS a String),
  coerced at every builder's return; parse/comment functions read via byte_at/
  byte_len not raw arithmetic; state slots dedup by handle identity (i32.eq),
  not str_eq (handle_recorded — a handle is not a name). Six m2 builds drove
  the census 10 → 17 (typing byte_len alone, refuted) → 15 → 8 → 2 → 0. The LSP
  json float blocker CLEARED (serve reaches the LSP layer; hover-response is the
  next rung). TWO convergent shortcuts were built and refuted by the binary
  before the foundational path: typing byte_len as String SPREAD the census (the
  string layer is uniformly raw-Int, 104 `s + N` sites), and address-permissive
  memory ops is blocked because `s + 12` forces Int through `+`. TRANSITION
  m3 == m4 (594-line diff = the emit change crossing one generation); the
  runtime-shadow grew 2 → 13 (benign — generic prelude combinators' free element
  var surfaced in ISOLATION by the precise propagation; full wheel census 0).
  Board whole: census 0, frontier 89/0 (ctor-float-param + lsp-blocker-cleared),
  proof-exactness 9/9, crown 5/5, micros 72/72 · pin a0dd9849
- 2026-07-18 · THE RECORD-CTOR ARROW VIEW (census 101 → 73): `X({...})` — the single-variant nominal ctor in the one application syntax — met the env's RESULT binding at infer_call's chase and mismatched at 29 sites, the tail's biggest root. The arrow is a VIEW minted at the read (record_ctor_arrow_view — the identical instantiation infer_pat's RecordSchemeKind arm performs; one view two readers; the scheme stays the RESULT, one home); the saturated machinery does the rest. TRANSITION m3 == m4 · pin 8e248607
- 2026-07-18 · FIVE MORE CLASSES EXTINCT (census 185 → 101): EffectMismatch + PurityViolated to ZERO (the widen loop's fixpoint — nine rebuild-and-re-judge iterations; !-carrying declarations matched on positive parts); ResumeOutsideArm (the synth candidate fan moved INTO its arm — backtrack's try_each shape; the census was right); ConstructorArity (QRFlowLabel's second field); PatternInexhaustive (the counter was PAlt-BLIND — collect_arm_tags/arms_have_wildcard now flatten alternation branches; voice's two H6 matches were exhaustive all along). register_one_variant's refutable let-destructure became its match; unlock_capability gained AWrapHandler→CSandbox; dead lib/runtime/buffer.mn DELETED whole (zero consumers, three findings one deletion) · pins 0f3d4f17, bfc576f2
- 2026-07-18 · THE ADDRESS IS THE SURFACE (census 213 → 185; frontier 71/0): `mentl voice.mn:9` answers `Query: echo(mix, x) : Float` — README §9's smallest transport, real. VAt at the argv boundary; driver_entry_with_ranges returns the module-range map from the concatenation fold that always computed it; the three-case line rule resolves over the span index every node writes at birth; cursor_at_handle (new CursorRead op; the eight-arm fan extracted to one cursor_view_of) projects without re-resolving; the facet-silent render reads source slices, env schemes, literal bodies, and the Why walk mapped to file:line — every lede a live read. propose_at is the ABSENCE facet structurally (authored_hole, the patch gate's own read) — which also fenced Hβ.emit.float-evidence-ft (an f64-arg candidate ctor through an all-i32 $ft, trapping the first float-position enumeration ever taken). The session's exact-reason-span resolver SURVIVES as the documented live-generation crutch (measured: mint-span find_tightest resolved a stale generation, 13 edit fixtures red at once; dissolves with session-weave-epoch-scope). Remaining README-Why substrate named: why-flow-naming (FnParam-at-call), refinement-provenance · pin 6e7c10b2
- 2026-07-18 · THE EFFECT-TRUTH SWEEP, ROUNDS 1+2 (census 301 → 213 → 185 across the arc): the census-spec fleet (29 per-file readers) produced exact specs for 192 sites; 148 + ~55 cascade widens applied — declared rows to the bodies' truth, aspirational Pure dropped for the honest Memory/Alloc, missing match arms written with real payload arities, LStateSlotStore's fourth field bound. The re-pinned sharper compiler re-judged its own source each round (the ++-carries-row precedent at scale) · pins 01ccaa3a, intermediate
- 2026-07-18 · TWO CHECKER ROOTS (census 343 → 301): E_IfMissingElse EXTINCT — the unit test matched TName("Unit"), a spelling the inferencer never produces (real unit is TUnit; probe: then_ty=() at all 25 sites) + 6 unresolved op-results the unify below decides. E_FeedbackNoContext EXTINCT — the check read the COMPILER'S runtime handler stack while inferring the COMPILED program's structure (a category error firing on every real `<~`, SYNTAX's canonical lowpass included); the compile-time class fact is the named peer Hβ.effects.iterate-class-declaration · pin 57a2113e
- 2026-07-19 · THE ULTRACODE BATCH — COLUMN 2 CLOSES (recon fleet + four
  isolated builders, transplanted by hand, marched serially): R3 the
  ground-decidable arithmetic fragment (PWithSelf binder, litval_arith,
  proven-false REFUSES; frontier fixtures RED-first) · the generative
  self-test loop (four real bugs on run one — the proven-fill zero-divisor
  is §1 executable; a failing case reduced 842B→131B; the CHANGED detector
  caught a banked case graduating) · the LSP transport runs the frontend (didOpen →
  driver_check; the serve chain carries the analysis handlers; the
  serve wire's pinned blocker = the FOURTH float-evidence hit) · the
  CFC pipeline's first pass (cos/sqrt/atan2; single-bin windowed DFT;
  MVL comodulogram finds the planted (6,40), peak/median 5.93 matching
  the numpy oracle; read_recording = the real-file transport). Census
  0 and m2 == m3 at every pin; frontier 77→84→86/0 across the merges
- 2026-07-18 · ▶▶▶ CENSUS ZERO (73 → 0 in one day; 2,266 three days prior):
  the medium's verdict on its own source is CLEAN, and the ratchet holds
  zero. After the five-pin tail (below), the last three roots: EVERY
  APPLICATION STAGES ITS BOUNDARY (the seq-op fast path skipped
  stage_continuation_boundary — lower's k2 crossing found NoBoundary at
  four sites, pinned by an epoch-field probe; E_UnresolvedType extinct) ·
  NRecordRowBound (the record-row residual's own node kind; NRowBound
  EffRow-only; occurs_in_row total over six row forms; the Ty-wrap mint
  deleted; ten mirror arms) · slot_present (the niche's READ half — the
  presence test table-typed `a -> Bool`, never pinning a slot's element).
  Every gate green at the pin: fixed point, frontier 71/0,
  proof-exactness 9/9, crown 5/5, micros-through-m2 72/0
- 2026-07-18 · THE TYPEMISMATCH TAIL FELLED (census 73 → 6, five pins; the
  eight-interrogations charge): the seq-op HOLE guard (a `??` argument no
  longer counts toward saturation — the Stage-Law partial mints; 14) + the
  `<~` RECURRENCE prior ((prev)=>body applies to its own result, RHS checked
  against FeedbackSpec; 14) · THE KIND IS THE NAMESPACE (env_lookup_type — a
  type-position read filters the env by kind, so `effect Sample` no longer
  shadows `type Sample`; quantify_ctor_ty is the one reader; 15) · A BUCKET
  IS A LIST THAT STARTS EMPTY (list_filled mints the four hash indexes with
  one shared []; every `if x == 0 {[]}` guard + env_bucket_at DELETED;
  eff_names_of's null guard out with its extinct class; 14) · THE BOUNDARY
  MADE NAMEABLE (alloc_list/slice_raw = the RAW altitude's own names, so raw
  walks stop calling table-typed names; int_to_str joins the table's String
  face; `-> !` PARSES — TBang arm + per-occurrence bottom var, abort()
  finally never-returns; verify_candidate takes Candidate, LPLit's emit arm
  matches LowValue, HandlerDeclStmt/LHandleWith/drain_string_literals
  declare their real elements, seq_force admits TString under a TList force
  — len on a String is canonical; 12) · THE DIAGNOSTIC LEARNS ITS ADDRESS
  (all eight E_UnresolvedType reports read the node's weave span; the four
  became locatable and named their one root, the `&&` boundary-weave thunk
  row; the escaping family speaks name-sets end to end). Clean fixed points
  + two TRANSITIONs; every gate green at each pin
- 2026-07-18 · THE INDEX LAW IS REAL (census 348 → 343): SYNTAX §Indexing's "traps on out-of-range" was prose — list_index tag-0 raw-loaded, every OOB a silent adjacent-memory read (the panel's find). The checked entry landed with its structural prerequisite: `&&`/`||` SHORT-CIRCUIT (lower's BKBool arm; the boolean verbs are control — SYNTAX gains the sentence). The eager i32.and had run every guarded read: set_insert / cache_filter_loop / register_one_variant all read one-past under their own guards (nullary ctors probed index 0 of EMPTY payload lists on every ADT ever inferred) — three latent OOBs in the trap's first hour. Then the trap swept the DRIVERLESS-CHAIN class: check / check_source / edit / repl ran infer's consume+region ops with NO analysis handlers installed — zero state records reading the sentinel page as empty ledgers since the chains were born; all four now install affine_ledger + region_tracker. Dead narrowing-elision write deleted (never fired — PAnd left-descent to PTrue; unsound if activated); the discharge-gated write is the named peer. micro oob-traps=134. TRANSITION m3 == m4, then clean fixed points · pin 3112cec5
- 2026-07-18 · THE VALUE CLASSES ARM (census 348 held; frontier 69/0): diag_refuses gains ERefinementRejected (the §11 "landed and locked" claim was FALSE — a decidable-false `let bad: Sample = 1.5` emitted 2,513 bytes at exit 0) and EOwnershipViolation (its unresolved-callee false channel dead; the adversarial panel could not falsify the detector on resolved programs). node_const folds negated literals so the canonical Sample range DECIDES — and the sharper compiler caught the wheel fabricating tag -1 into TagId's 0..255 (lower_pat's unresolved-ctor arm): deleted into LPUnresolvedCon (match test honestly false, sub-binders declare at the word floor, the dead arm assembles). The dormant mn-refine-reject micro (asserting pre-arm exit-0, wired to nothing) superseded by frontier refusal fixtures; the handler-forward-ref regression added. m2==m3 clean fixed point · pin 01d77f31
- 2026-07-18 · ONE MISS, ONE DIAGNOSTIC + THE HANDLER-NAMESPACE REFUSALS (census 352 → 348): the env-miss path bound TVar(self) — tripping graph_bind's own occurs check (a spurious 0:0 E_OccursCheck per missing name) and reading downstream as an unconstrained var (the ownership move-default cascade the panel proved). It now binds NErrorHole via the new graph_bind_hole op; an unresolved VarRef callee borrows its direct args; the occurs check reads its span from the bind's Located reason. Two classes born ARMED at the decl site: E_HandlerStateShadowsOp (a state field naming an op of its handled effect compiled clean and returned the WRONG value; the medium's own m3 leg caught the second wheel violation, `caret`, the hour the check landed) and E_DuplicateFnName. Voice state fields renamed turns/caret_now; the code-dead duplicate FeedbackSpec deleted (silently shared tag ids with prelude's Delay/Accumulate/FilterSpec — the duplicate-TYPE decl refusal is the named peer Hβ.infer.type-decl-name-registry, repro banked). E_MissingVariable/E_OccursCheck reach wheel-zero but do NOT arm (the licence correction). Frontier gains run_refusal. m2==m3 · pin d6dd8ed9
- 2026-07-18 · THE SMT HANDLER TELLS THE TRUTH (census 356 → 352): verify_smt declared only `witnesses` while its arms update and read `debt` — the unknown-debt ledger never existed as state (2 E_MissingVariable + 2 paired E_OccursCheck). `debt = []` is the whole fell. Same commit: solver polarity (validity = UNSAT of the negation; SmtSat now returns a COUNTEREXAMPLE with the rejection, never proof-evidence — predicate_decide short-circuits ground predicates so the solver only sees open ones); node_to_predicate's missing BNe arm (`self != 0` fell to opaque PBoolNode and accrued debt instead of deciding); show_pred_operand's `<expr>` fabrication on compound operands (the refinement's own -1.0 bound rendered as `<expr>` in the diagnostic that exists to teach it — UnaryOp/BinOp render recursively). m2==m3 · pin 45244e15
- 2026-07-18 · A HANDLER'S IDENTITY IS A PARSED FACT (pre_register_handler_sig; census 578 → 356): `pre_register_stmt` registered FnStmt, TypeDefStmt, EffectDeclStmt but not HandlerDeclStmt — handlers entered the env only at the main walk's `register_handler`, so every `~> handler_name` before the handler's declaration in source order (115 sites) floored E_MissingVariable. The handler's identity (effect, instance type, config, residual row, HandlerKind) reads only parsed structure and the effect env (already registered by EffectDeclStmt). Moving the identity registration to pre_register makes handler names resolve order-independently; the main walk reads the pre-registered r_handle from the env so forward references share the same residual row handle. E_MissingVariable 115→4, E_OccursCheck 115→4. Clean m3==m4 TRANSITION, pin 8bf740a4
- 2026-07-17 · A BORROWING PARAMETER BORROWS (move-vs-borrow part 3; census 582 → 578): CallExpr previously inferred every argument before reading the callee's parameter product, so an owned value passed to `observe(ref value)` consumed exactly like one passed to `take(own value)`. The call now reads the canonical TParam product after labeled/default resolution: a direct VarRef passed to authored or inferred Ref enters the existing borrow scope; Own parameters and nested computations keep their normal move inference. `len` / `list_index` declare the read-only access their bodies prove; update_file_text_loop carries list_set's returned owner. E_OwnershipViolation 4→0, while the real `take(value) + take(value)` double move remains rejected. Carried-Truth: the callee product already owns the access mode; the call re-derived a move. Clean m2==m3 fixed point, pin 361ed16c. RED-first: mn-own-call-arg-borrow + mn-own-forward-ref-seq; negative control: mn-own-call-arg-move; frontier 63/0
- 2026-07-17 · A READ IS A BORROW (move-vs-borrow, census 615 → 582): an `if` condition / `match` scrutinee / a `.field` receiver is READ, never moved, so an `own` value used there is a borrow. A borrow_depth counter on affine_ledger + borrow_enter/borrow_exit bracket the condition, the scrutinee, and a value-chain field receiver (`f(x).field` keeps its normal move of `x`); consume no-ops inside. Cleared 33 of 37 with soundness intact (a real `(take(buf), take(buf))` double-move to two `own` params still caught). Two clean m2==m3 transitions, pin 1e06cdaa. Residue (4, all graph/voice): the call-arg-borrow — `len(nodes)` then `list_copy_into(nodes)`, an `own` value passed to a BORROWING param; the last piece reads the callee's param ownership at each argument
- 2026-07-17 · THE AFFINE MODEL STOPS FIGHTING SAFE CODE (`Hβ.infer.usage-grade-unifies-cardinality-ownership` — the branch + scope halves; census 727 → 615): 115 of 152 `E_OwnershipViolation` "consumed twice" were false positives — the medium stricter than Rust on provably-safe code, the inverse of §4⑤'s Hylo-quiet bar. Two masked bugs. (1) `if`/`match` arms were never bracketed, so an `own` value read in both arms of `if i<0 {slice(buf)} else {list_set(buf)}` counted twice — but arms are ALTERNATIVES (one runs). A `BranchMode` ADT (BParallel | BAlternative) rides the branch frame; branch_exit collides only for BParallel (`><`/`<|`), unions for BAlternative (if/match). (2) affine_ledger installed ONCE at the pipeline, not per body — a name consumed in one fn stayed `used` and collided in the next naming the same `own` param (`buf`/`acc`, the dominant shape); consume_enter_fn/consume_exit_fn bracket each infer_fn body (fresh scope, restored on exit, re-entrant). Carried-Truth: the graph knows a branch is an alternative and a body is a scope. `><`/`<|` collision path unchanged (crown + micros green). Emit grew → clean m2==m3 TRANSITION, pin 6d693a87. RED-first: tests/frontier/mn-own-alternative-branches.mn. E_IfMissingElse 29→32 = latent errors the ownership false-positives had masked (total still fell). Residue (37): move-vs-borrow-by-callee — an `own` read in an `if` condition or a field is a BORROW
- 2026-07-17 · STAGE 1 — the bare-parameterized-type-arity class felled (`Hβ.infer.bare-parameterized-type-arity`, census 874 → 727): the `0 vs 1` arity mismatches were one shape, one type over from Stage 1a's bare `List` — a bare parameterized type (mostly `Option`) written without its argument in a declaration, meeting the real `Option(X)`/`List(X)` its consumers build. The root was `env_lookup(String) -> Option` (types.mn): the effect op erased the `Option((Scheme, Reason, SchemeKind))` its own handler proves via env_resolve, so every env_lookup match site mismatched. Swept its siblings too — the Annotation ctors (`Option(Span)`), the teach/CursorView gradient field (`Option(AnnotationSuggestion)`), PList/LPList rest (`Option(String)`), gradient_pop/step (`Option(Cursor)`), inf_arm_tys (`Option(Int)`), ls_escaping_of (`Option(EffRow)`), the Situation/TopicFacts record fields, the Lsp response ctors, Explanation's fix (`Option(Patch)`), QRHandlerProvider (`Option(String)`), tree_list (`[TreeEntry]`), NonEmptyList (`[a]`), QRIntent's tuple. Carried-Truth: each consumer/handler proves the type the declaration erased. Pure declaration fix — emit byte-identical, boot UNCHANGED, so no re-pin; the census ratchet is the gate. Residue: `Buffer` → `Buffer(a)` (genuinely generic, named)
- 2026-07-17 · STAGE 1 — the census's biggest root felled (`Hβ.infer.alias-preserving-unify`, census 1233 → 874): the 362 `Span vs ValidSpan` / `Int vs ValidOffset` errors were ONE forward-reference bug. `pre_register_decls` ran a single source-order pass, so a fn signature quantified before its refined alias was declared (parser.mn's `span: ValidSpan` precedes types.mn, last in the concatenated wheel) baked a bare nominal `TName` the main walk could never refine — `unify(bare-TName, base)` floored at the leaf. Fix (`pre_register_alias`): register alias edges in a phase BEFORE any fn signature, so `quantify_ctor_ty` reads the LIVE edge (Carried-Truth: the graph drew the alias; the resolver re-derived a name). My own banked "a two-pass is a no-op / ruled out" was the drift — measured against BOOT's census, not the fixed compiler's (⟲: a label is a hypothesis until the artifact confirms it, the verifier included). Emit byte-identical → clean m2==m3 fixed point; boot re-pinned (wheel-neutral yet tool-changing) `5e9ec2d6…`. RED-first gate: tests/frontier/mn-refined-alias-forward-ref.mn (fails `Pos vs Int` on the old boot, runs 42 on this one; frontier 50→53)
- 2026-07-17 · STAGE 4 — the surface parses its own canonical form (`Hβ.parser.refined-alias-nonatomic-base`): `parse_type_decl` probed only `p2+1` for `where`, so a multi-token base (`[Int]`) hid it — SYNTAX:990's own `type NonEmpty = [a] where len(self) > 0` did not parse. Fix parses the whole base first, then branches. Wheel-neutral (m2==m3 byte-identical) yet tool-changing, so boot re-pinned `ab34a853…`; guarded by tests/frontier/mn-refined-alias-nonatomic.mn (frontier 47→50) — tooling improved WITH the medium
- 2026-07-17 · STAGE 1a — the census's largest root felled: a bare `List` in a declaration is the nominal `TName("List",[])` that never unifies with the native `TList` consumers build (SYNTAX §4① — one sequence kind `[a]`); the fix is `[Element]` at the declaration, read live from the consumer, never a TName↔TList unify bridge (which would legitimize the illegal shape while leaving the element erased). Core ADTs (Ty/Node/Pat/LowExpr/LowPat/LowFn/Scheme/EffRow) + the shared handler-arm/state-field records (also cleared `N vs Node` 14→0) + the leaf ADTs and effect-op sigs. Census 2266 → 1233 (true bare-List shape 645+ → 6, residue = the dead buffer.mn); inference-only, m2==m3 byte-identical, zero new classes — af8a9189+ef0030b1. Stage 2a (`Hβ.infer.seq-op-row-from-callee`) built + marched + REVERTED: correct but DEP-gated on §5.O per-decl-arena (the Alloc attribution's ev-slot emit tips the 4GB bump image → m3 OOM; §11 col 2)
- 2026-07-16 · BARE MENTL PROJECTS WHERE YOU ARE: the tty fork (fd_fdstat_get), the directory projection (fd_readdir), verb_catalog one-string-two-surfaces, mentl help; a two-rung transition ladder; §11 rescoped (MI300X = the last arc, not required) + the named-peer audit (four verdicts) — 80215c38 · pin e2babb24
- 2026-07-16 · MENTL RUNS FROM ANYWHERE (§11 col 1): install shim = a POINTER to the live boot; resolver chain + /mentl-home guest path; fs_at (the preopen table IS the mount table — longest-prefix, fd_prestat_dir_name); prelude declares its imports (the manifest); driver_compile_entry = the one-namespace DAG concatenation. Temp-dir matrix: run=42, hole refuses · pin 26bfe90a
- 2026-07-16 · §7 → this ledger; PROVENANCE compacted; archaeology banners; tools/state.sh = THE BOARD; §11 THE PRODUCTION BAR authored — a09026c, f6ed08c
- 2026-07-16 · regions live: fn body = region, return = TRANSFER; Hylo-quiet on the wheel (0 escapes) — 82a7e42 · pin 94e449dc
- 2026-07-16 · region tag speaks truth: `.region_id` read offset-0 (handle-as-region) pinned in binary; tuple tag — e887bde · pin 4b7f998f; board 47/0
- 2026-07-16 · executable gate: holes REFUSE (E_UnresolvedHole, exit 1, zero WAT), honest V_Pending SURFACES and runs; refinement ledger truth (4 raw-pred wrapper verifies deleted, call-arg discharge = R2's third site, typed-identity stops echo, decl-site schema verify deleted) — 10999e6 · pin 701c7024; proof-exactness 9/9
- 2026-07-16 · NFree per-read report deleted (a free var is a legal quantified param — generalize's own Forall); census 31,546→2,984, fleet-converged — 9611c52 · pin cf479f9d
- 2026-07-16 · partial application is a value: `add3(10, ??, 30)` mints its lambda, runs 42 (was trap 134); pipe fork-free via lower_call_dispatch — 40ad601
- 2026-07-16 · capability tie fixture: two proven survivors refuse the guess — bf0257f
- 2026-07-16 · capability `??` workflow green (row prunes, rejections teach) + the let-statement bind (census 34,028→31,414) — 54c403dd+8fd0358b · pin c323a40f
- 2026-07-16 · positive `??` workflow green end to end (hole→survivor→Reason→patch→run) — 1255a76 · pin 7b188a31
- 2026-07-16 · felt route lives: `mentl edit` reaches the eight-aspect CursorView; CursorRead/PatchWrite naming — bdec460 · pin 9c8b23ba
- 2026-07-16 · inference-owned executable boundaries (TCont R/S, boundary weave, one-field carrier) + the pattern-constraint law (constrain_scrutinee, ~4,400 diagnostics resolved); frontier gate battery born — cf00697→fede003 · pin 7bd9e3e7
- 2026-07-14 · value-proof R2 landed (parse_let carried the annotation; subst_self at infer_pat: `let bad: Sample = 1.5` REJECTS) + string-interner O(1) — 730dfe8+9feb727
- 2026-07-14 · crown positive gate largely sound: pointer-eq at name_set_contains, by-name fix 598→146 false mismatches, −16k emitted lines — cc487f8 · pin 8a5d8ff7 (m3==m4)
- 2026-07-14 · felt CLI connected: argv wire + verb dispatch (compile/check/audit/teach/query WORK; six latent bugs rooted) — 91755d6+f1b13e2 · pins bea3692b, c4bdba19
- 2026-07-14 · destiny audit (8-subsystem, artifact-grounded): machinery real / wiring absent; the R1–R6 path — git history: docs/research/destiny-audit-2026-07-14.md
- 2026-07-13→14 · THE PERF LOOP, seven iterations, 1400s→10s (~140×): classifier summary-index (→749s) · region tracker handle-index (→490s) · esc write-index (→226s) · esc read-index (→56s) · reachability index + LSuspend garbage-Int root (→13s, TRANSITION · pin 349a3302) · iterate flattens once (→10s). Lesson: perf the artifact, never the estimate (the 8-agent code-read missed every dominant cost)
- 2026-07-13 · THE CROWN's negation gate landed: row_subsumes EfNeg by-name; 5/5 crucibles (tests/crown/) — 29df478
- 2026-07-13 · M4 the Abandon discipline self-hosted (4th ResumeDiscipline; deaden after diverge; option-protocol 0→42) · pin 67e44c9c (m3==m4)
- 2026-07-12 · M3 THE CUT: classifier fixpoint, choose+enumerate_inhabitants flip MultiShot, k gates enter baseline (52→66), evidence FENCE at fn-frame boundaries · pin ac204467 (m3==m4)
- 2026-07-12 · M2 nested-choose (redrive at resume boundary; hole-set reifier kills the diagonal) + UZero ratchets + A4 refuted (2 silent-wrong-value bugs found+fixed: S1 wrong-record state home, S2 driverless install crossing)
- 2026-07-11 · k1 CONTINUATION REIFICATION landed self-confirmed (mn-multishot=30 via a real k record) — 1746a87; M1.1–M1.6 the mechanism arc (world-tag homomorphism, composer pair, k2 boundary, args packet, state-commit, resolution ladder), six fixpoints in one day; k2/k3 design bank twice-refuted — 287521d
- 2026-07-11 · THE PIVOT: the AST desugar refuted (intent lost, resume≠restart, micro-only) — continuation-reification codegen named the true keystone; IDE grows its five surfaces — 73d21df
- 2026-07-10 · ▶▶▶▶▶ FIRST LIGHT: m3 == m4 byte-identical + battery green through m3 — 87c0152, tag `first-light`. Final cut: the pattern-string intern (284-fn eq-dispatch flip class)
- 2026-07-10 · the boot era: seed DELETED (7401c4b "Fly, my pretty <3"), boot/mentl.wasm IS the compiler, march.sh the ratchet; ide/ born (the fixpoint compiler in-browser, served by serve.mn) — 77da34d+b72590d
- 2026-07-10 · the summit: m4 first exists; emit_float_const forward-ref pin, variant alloc = width-summed fold (every float lexed collapsed to 0.0), interpolation source-order (204k→2.7k diff)
- 2026-07-09 · the 4096-byte lexer cut: raw-TName annotations vs the alias edge (pre_register alias arms; quantify_ctor_ty env resolve) — f320f97; evidence-tail LSuspend.tail (2158c4e); concat-floor class EXTINCT 14→0 (bare-List decls; render family str_concat by name; float e308 lex root) — 581a92f+c595cc5; reach OOB = 2GB memory preamble, not corruption — 2fc7544
- 2026-07-08 · result()->r: infer_seq_op's FUNCTOR arms dissolved (NOT the path — the ledger overclaimed; `fn infer_seq_op` is live at infer.mn:1040 and still hardcodes a row, `Hβ.infer.seq-op-row-from-callee` §11); multi-payload effect instances position-wise (TName carry); occurs-check completion (the hang WAS productive-under-error failing) — 7adada9; emit-diff.py banked (the divergence pinner)
- 2026-07-07 · the singleton dispatch tier (op→handler edge; ev_perform_entry 6401→4209); reachability==emission (dcac3b8); the f64 census SEVEN roots (capture-shadowing inversion killing let-poly; fabrication sentinels→TVar(h); float render off-by-start; ft traversal orders; binder widths; WASI widths as data; Int/Float lies) — e7b4623→e44afd9; m3 ASSEMBLES AND RUNS first time (local_wat_name = (name, repr) projection)
- 2026-07-05→06 · `handle` de-keyworded (the medium's noun vs its lexer, 106 lost binders) — 55e60de; union_row TOTAL over six row forms (the 99%-wall infinite loop); nominal-record ctor identity — 4cdd820; Handle collision → ThreadHandle; assembly-ladder faces 8–22 (slice-of-slice, PAlt, rest-wild presence, wasi dedup, `<|` thunk capture, `$_` positional); undefined-ref ladder closed — 4e3faa7
- 2026-07-01→04 · the m2 march: pipe = hole-completion BOTH layers (prepend convention deleted — the whole m2 trap zoo); `??` parses/types/lowers; the 8/8 rung day (nine bands, the raw-0 root b73748c: union_row's ++ emitted str_concat via h=0 binders); the wheel's evidence-passing call convention decoded (the sst_ clone); phase 1 closed 0/34→34/34 (plans/noble-brewing-rose.md)
- 2026-06-22→28 · the value layer: STEP 0–5 landed (repr_of · gradient · fold eq-leaf · multishot producer record · PFanout collapse · TCont keystone); the e-graph live in lower; the whole AST into the one graph (the fabric); SYNTAX to ultimate form
- 2026-06-18→23 · the reframe + the three-doc consolidation; the crown's EfOpen~EfNeg unify (b4b1989); the handler registry dissolved into the live read
