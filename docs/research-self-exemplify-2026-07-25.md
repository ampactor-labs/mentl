# Self-exemplification research pass — how Mentl best utilizes and exemplifies itself

Grounded 2026-07-25 on live main at 4268f1a8 (base-check OK; verify green: census 0,
comment-refs 0, 114/114 micros). Verbs exercised through the pinned boot: help, check,
address projection (voice-demo `voice.mn:9` answers `Query: echo(mix, x) : Float`),
query (`effects of fold` → `Memory + Alloc`; `why mix` → located reason), teach, doc.
All three docs read whole. Every claim below cites what was run or read.

## The direct answer first

**The single most powerful thing the medium could do for its own development that it
does not do today: judge its own changes.** Today the development loop is: Claude
edits → bash orchestrates boot(wheel) → bash diffs the generations → bash gates
assert → the human blesses the pin. Every piece of the in-medium replacement now
exists separately: the warm-start image cache (B-i, landed this week) gives the
incremental judge; fixtures-as-graph-content (`// expect:` on micros) gives
self-describing oracles; the census/ratchet is already the medium's own verdict; the
eight-interrogation loop exists as substrate (src/eight_loop.mn) with ZERO performs.
Fused, that is `mentl march` as a verb: the medium re-judges only the edited cone,
runs its own gates, projects the divergence as Reason edges, and REFUSES a regression
the way it refuses a hole — the §0 convergence (docs : Claude :: language : developer
:: human : mentl audit) executed at the development layer. Findings 1–4 below are the
reachable rungs of exactly this; they are ordered so each lands whole on its own.

## Ranked findings (impact × elegance × reachability)

### 1. ★ OPENING MOVE — `refs of` computes every span and throws them away; grep stays the session's caller-finder

**Current form:** `mentl <target> refs of NAME` walks the live weave and
collects the span of every `VarRef` (src/query.mn:336-345, `refs_of_name` /
`collect_var_ref_spans` — "the inbound use-edge set, read live. No AST side-index"),
then the render discards all of it: src/pipeline.mn:1251 `QRRefs(spans) => "→
{int_to_str(len(spans))} reference(s)"`. Ran it live: `refs of echo` → `→ 3
reference(s)`, no locations. Meanwhile every development session (Claude's and
Morgan's) answers "who calls X" with `grep -n` dozens of times — the single most
frequent hand tool on the project, re-deriving edges the graph already holds.

**Mentl-native form:** the reasoned cursor (arm 8 / arm 1). The Why render in the same
chain already maps spans to file:line (`why mix` printed `at 2:5-2:8`; the address
surface prints `voice.mn:7` via the module-range map from `driver_entry_with_ranges`)
— the refs facet just never got the projection. This is the exact seam pattern the
ledger already convicted once: "the graph computed the proposal; the terminal threw it
away" (the propose-facet fix, pin 17d1c3be). Same disease, refs facet.

**Smallest complete landing:** render `QRRefs` as one `file:line` per span through the
range map (the render is the whole change; the collection is done), plus the
declaration site marked. Gate: a frontier leg asserting the span list on a two-module
fixture. Then `mentl src/main.mn refs of spec_resolve` — the DAG compile pulls
the whole wheel — replaces development grep with a graph read.

**Named?** New. `Hβ.query.comment-prose-search` (named-residue index) covers PROSE
search only; nothing names the refs render. Smallest finding in the list, largest
daily-frequency payoff.

### 2. ★ OPENING MOVE — frontier fixtures don't carry their own oracles; the biggest hand tool (1,556 lines of bash) is the medium's blind spot

**Current form:** tools/frontier-gate.sh is 1,556 lines — per-leg RTLIBS link-set
arrays (frontier-gate.sh:80-130), per-leg exit assertions, refusal assertions
(`run_refusal`, :492), banked-shadow prose. 79 fixtures in tests/frontier/ carry no
expectations (checked mn-effect-absorbed.mn — prose only); the oracle lives in bash.
The micros already crossed this river: each declares `// expect: N` as its first line
and both verify.sh (:61-72) and `battery_expect` (src/main.mn:1522) read it — "the
expectation lives ON the artifact it gates... never in a side-table." The frontier
never followed. verify-baseline.txt is meanwhile down to exactly 2 content lines
(census_errors_max, comment_refs_max) — that side-table is effectively absorbed
already; frontier-gate.sh is the remaining one.

**Mentl-native form:** a comment is graph content (SYNTAX §Comments), and the imports
ARE the manifest (§11 col 2, landed): a fixture's link set is its `import` list; its
oracle is its own first-line comment, with the grammar grown one arm — `// expect:
refuse E_UnresolvedHole` — since a refusal class is a `DiagKind` fact the medium
asserts about itself. This directly answers the fleet's deepest §11 finding,
`Hβ.medium.cannot-observe-its-own-programs`: a fixture that states its own
contract is a program the medium can observe; a bash assertion is not.

**Smallest complete landing:** (a) `battery_expect` grows the `refuse E_*` form and
`battery_run` verdicts it compile-side (armed classes already exit nonzero with zero
WAT — the assertion is exit+empty-emit); (b) a fixture with imports routes through the
DAG entry instead of the concatenated RTLIBS blob; (c) migrate the compile-verdict and
exit-code legs (the majority of the 279) leg-by-leg, each migration deleting its bash.
Host-bound legs stay at the shim seam by design: the 7 python-oracle sites
(cross-validation against an independent implementation is deliberately OUTSIDE the
medium — trusting-trust), byte-identity across engines, and tcplisten/serve legs.

**Named?** New as a landing. §11 names the observation gap
(`Hβ.medium.cannot-observe-its-own-programs`) and PLAN §6 names the general
scaffold-dissolution tier, but no peer names frontier-gate's absorption; the micro
battery's absorption (pin 658f3988) is the proven precedent one tier below.

### 3. ★ OPENING MOVE — the eight interrogations exist as substrate and run zero times

**Current form:** src/eight_loop.mn declares `effect Interrogate { interrogate_at,
interrogate_all, interrogation_invites }` (:122) and `handler interrogate_default`
(:147) — "when the eight run as code, the medium IS the discipline." It compiles in
the wheel, census-clean, and is INSTALLED in both edit-session chains (src/main.mn:397,
:1099). Perform sites outside its own module: **zero** (grepped all of src/ per op).
The install-site comment (main.mn:387-389) says cursor_default's arms fan "Synth /
Interrogate / Teach..." — the artifact refutes the Interrogate third of that sentence:
no op is ever performed. The comment-refs ratchet cannot see this class (the backticks
resolve; the semantics lie). Meanwhile the discipline the file lifts runs as
tools/drift-audit.sh — bash + a 13KB grep-pattern TSV — appeased by **223**
`// drift-audit: ignore` markers across the wheel (measured), each one a line where
the author pays ceremony to a scaffold that cannot read the row.

**Mentl-native form:** the eight arms ARE the one cursor-read (§2); `interrogate_at(h)`
is that read reported. This is the most symbolic dormant substrate in the repo: the
project's own method, built, wired into the chain, never asked a single question.

**Smallest complete landing:** wire `interrogate_at` into the address surface — `mentl
<file:line>` gains a Residue facet listing the interrogations that don't clear at that
node (the render is the existing facet-silent pattern; the chain already installs the
handler). RED-first gate on a fixture with a known residue (e.g. an unclassified flow
or a missing Reason). Before wiring, true the file's internals against the current
substrate (it predates several representation swaps; census 0 proves it compiles, not
that its verdicts are current — interrogate, don't absorb). The drift-audit absorption
(finding 5) then retires marker families INTO this surface instead of into ad-hoc
infer warnings.

**Named?** The destiny is named twice at concept altitude — band L
`Hβ.audit.carried-truth-projection` (the §0 keystone) and CLAUDE.md ⟳ (drift-audit →
`mentl audit`) — but no peer names the concrete fact that the Interrogate machinery
exists installed-and-unperformed, and no landing names the address-surface wiring.
The zero-performs measurement is new.

### 4. `mentl march` — the self-judgment loop is newly unblocked by the warm image

**Current form:** tools/march.sh (167 lines) + wt-env.sh's `wt_m2_ensure` bash cache
(sha256-keyed, .build/m2cache) recompile the whole world three times to answer a
changed-cone question; tools/state.sh (54 lines) sequences the gates; the human writes
PROVENANCE and blesses the pin. march.sh's own header and the 2026-07-23
march-absorption ledger entry name the destiny: the INCREMENTAL fixpoint (IC re-derive
only the changed cone), `mentl march` as a verb, the verdict as a projection
(emit-diff.py's handle-anchored divergence as the march's Reason, retiring the python).

**Mentl-native form:** the cached cursor (§2) at the development layer. What changed
this week: B-i landed persist=memcpy + the warm start + `mentl resume` — the medium
already restores its own analyzed image and re-judges cones byte-identically. The
march verb is no longer blocked on substrate; it is a driver over machinery that
exists. The whole-world bash march demotes to the trusting-trust audit tier (its
correct final role), exactly as the entry prescribes.

**Smallest complete landing:** `mentl march` = warm-restore → re-judge cone → emit →
byte-compare against the pinned generation → verdict with the divergence as Reasons;
the mechanical PROVENANCE block (shas, line counts, gate tallies) printed by the verb,
narrative prose staying human (finding 9). Gate: the verb's verdict agrees with
bash march.sh on one CLEAN and one TRANSITION case before the bash demotes.

**Named?** Fully named (the march-absorption entry, CLAUDE.md ⟳ standing queue). The
new content is sequencing: B-i just removed the DEP, so this is now a driver, not a
substrate build.

### 5. The drift audit reads bytes; the graph knows the row — 223 markers of appeasement

**Current form:** tools/drift-audit.sh + drift-patterns.tsv grep staged .mn files;
223 `// drift-audit: ignore` markers in the wheel (measured) exempt lines one at a
time — e.g. main.mn:1610 exempts a sequenced effectful read the ROW already justifies
(the callee performs; a pipe stage cannot). The scaffold is string-blind and
row-blind; every false positive becomes permanent line noise.

**Mentl-native form:** arm 4 — the row IS the fact each drift mode approximates.
"let-where-pipe" is a warning only when the callee's row is Pure; string-literal hits
are not code; mode 15's residue form is a bare effect statement. All are infer-side
facts.

**Smallest complete landing:** the named peer as written — the infer-side
let-where-pipe class gated on the callee's row (pure-only), string-literal blindness
fixed by construction (the lexer already knows), and the marker family deleted with
the modes it appeased. Lands naturally as a tier of finding 3's surface.

**Named?** Yes — `Hβ.audit.drift-modes-read-the-row` (born at the tighten landing,
pin ab8daa07). The 223-marker census is the new measurement making it urgent.

### 6. ~38 hand-copied structural walks where the wheel's own best idiom already exists

**Current form:** `LMakeClosure` arms appear in 21 distinct match sites in
src/lower.mn and 17 in src/backends/wasm.mn — each a full LowExpr traversal copy. The
cost is measured by the medium itself: the LWorldResolve landing had to add its leaf
arm to TEN walks, "named by the medium's own census (E_PatternInexhaustive ×10)" (§7
ledger, pin 8458415b). The cure is already in-tree and proven: `walk_lemit`
(wasm.mn:1012) is ONE walk firing SEVEN visitor families as effect performs with
handlers chained via `~>` (wasm.mn:745-830) — "per-node `perform visit_X` ops; FOUR
visitor handlers chained via `~>`" grew to seven including the effect census.

**Mentl-native form:** every subsystem is the one read in a different mode (§2);
N traversal copies are drift-7 at the LowIR layer. A new projection should be a
handler installed over the ONE walk, never a new 40-arm match.

**Smallest complete landing:** absorb the remaining READ-ONLY traversals (locals
collection, reach seeds, spec scans, k2 predicates) into walk_lemit visitor families,
one traversal per landing, each deleting its walk. Transform walks (tree rewrites)
are out of scope — a unit-op visitor cannot rewrite; forcing them in would be the
wrong altitude. Perf holds by construction: the visitor form is the same
zero-allocation recursion with effect dispatch the census walk already pays.

**Named?** Partially. The §5.U "unified each" covered the FOLD walks; the
"walker-unification seed (lowexpr_children, ~40 arms once)" was designed inside a
ledger dig but never landed as a fn or a peer (grep: no `lowexpr_children` in src).
The walk census (21+17) is new.

### 7. The hand fixpoints are larval forked-cursor searches — and the fork substrate now exists

**Current form:** `classify_fixpoint`/`classify_rounds` (src/infer.mn:5627-5646,
whole-program rounds to a monotone fixpoint with a by-value entries compare),
`spec_candidates_fix` + the worthiness closure (src/backends/wasm.mn:389-421), the
reach walk (lower.mn:5268 membership). Each is a hand worklist.

**Mentl-native form:** the forked cursor (§2 TIME axis). Named verbatim:
`Hβ.compile.fixpoint-is-larval-forked-cursor` — "when trail-fork lands as compile
substrate each rewrites as forks with rollback." The fork triple (graph checkpoint +
heap region + world, R6) landed 2026-07-25, and Phase C's fused oracle is this
convergence in flight.

**Smallest complete landing:** nothing new to name — the sequencing note is that the
DEP is gone, and the classifier (the compile's measured former 47% hotspot, now
indexed) is the natural first rewrite because its fixpoint is monotone and its rounds
are already value-compared. Cite the peer; do not re-derive the design here.

**Named?** Fully (the ruling + Phase C). Listed to keep the map complete.

### 8. The wheel barely speaks its own topology language — measured, with an honest boundary

**Current form:** real verb usage in src/** (comments/strings excluded): `~>` ~214
lines (the handler spine — genuinely exemplary), `|>` ~111 lines in 41k, `<~` 5 real
sites (the session/queue loops: pipeline.mn:640, oracle.mn:433, mentl.mn:770,
format.mn:311, cursor_transport.mn:241), `<|` and `><` **zero** real sites — every
grep hit is a token name, ADT declaration, or comment. The compiler that ships
parallel fanout never fans out; the iteration idiom is ~80 `*_loop(xs, i, n)`
index-threaded recursions.

**Mentl-native form:** the five verbs; the `><` fan on the compile spine.

**Honest boundary (adversarial):** the hot-path raw loops are DELIBERATE — the
battery law ("Raw loops (the battery law)", wasm.mn:425) and the ceremony-fuse
measurement (list_index ceremony was ~20% of compile) mean a blanket loop→fold sweep
would fight measured perf. The exemplification target is the SPINE (`><` at the layer
fan — Phase C's next rung, C1c-2's bracket then the fan, in flight) and COLD paths
only, via the tighten-class batch pass (CLAUDE.md ⟳ "the fmt/tighten batch loop" —
medium-authored idiom rewrites gated by the board), never a hand sweep.

**Named?** The spine fan: named and in flight (Phase C). The cold-path idiom pass:
named at concept altitude (⟳ standing queue), no concrete peer.

### 9. The board's prose is hand-written where it is mechanical

**Current form:** boot/PROVENANCE.md entries and the §7 ledger head are typed by the
session; march.sh MARCH_REPIN=1 blesses the pin but "PROVENANCE prose stays the
session's, the pin unblessed until written." The mechanical block — shas, wheel line
counts, gate tallies, census/comment-refs numbers — is exactly the fabrication
surface the ⊕ law polices by hand ("a sha tail completed from memory is a
fabrication," caught live 2026-07-25).

**Mentl-native form:** state-as-projection (§7's own named destiny). The medium
printing its own measured block makes the fabrication class unsayable instead of
policed.

**Smallest complete landing:** a slice of finding 4 — the march verb emits the
mechanical block; the human writes only the narrative. Named at concept altitude;
the slice is new.

### 10. wt-env.sh's dissolution is real but DEP-gated — name the gate, don't force it

**Current form:** the flag quartet, wt_run/wt_asm, and the bash m2cache
(tools/wt-env.sh — its own header: "The instant `mentl run` / `mentl asm` exist as
real subcommands, this file dissolves"). Beside it, the medium now has its OWN
warm-start image cache (B-i) — two caching systems, one in-guest and one in bash.

**Adversarial finding:** in-guest `mentl asm` cannot land under WASI preview1 (no
host assembler reachable; wat2wasm/wasm-tools are host binaries), and run's exec is
the shim's seam by design. The honest dissolution rides
`Hβ.ops.wasmtime-runner-migration` steps 5-6 (the rust runner absorbs the flags; a
wasm-tools-linked runner can absorb assembly). Named by the file itself + the runner
peer; nothing new to add except the refusal to force it early.

### 11. The felt flood — the medium's answers drown in its own warnings

**Current form:** every verb invocation on any target prints the SHIPPED lib's 798
warnings (mostly E_RedundantBraces + T_OverDeclared) on stderr before the answer —
ran `check`/`query`/address forms; the flood precedes every result. For the two
audiences of §11's bar this is the first impression of the medium judging itself.

**Mentl-native form / landing:** already named and in motion — the warnings are the
format-lift backlog by construction (verify.sh:94-95 "the formatter erases them by
construction"); the fmt SUMMIT (whole-wheel fmt → canonical source) + the tighten
multi-line patcher retire the classes. Nothing new; listed because it is the felt
face of self-exemplification and the summit's blocker ladder is already measured
(§11's fmt entry). One added observation: `mentl voice.mn doc` printed nothing for a
commented file while teach/query answered — worth a probe when col 4's doc work
opens (unverified root; noted, not diagnosed).

### 12. Fixture prose asserts what the artifact refutes — a semantic-comment class the ratchet cannot see

**Current form:** main.mn:387-389's chain comment claims cursor_default "performs
Synth / Interrogate / Teach / Verify / Graph ops" — the Interrogate claim is false
(zero performs, finding 3). The backtick ratchet holds 0 because the NAMES resolve;
the semantic claim lies. The pre-commit hook's own text names the gap: "a resolver
cannot judge this; until the medium can, the developer IS mentl audit."

**Mentl-native form:** a comment is a Reason edge; a checkable claim inside prose
("X performs Y", "zero callers", "O(1)") is a projection the medium could verify the
way it verifies backticks — the comment-refs precedent one semantic level up.
Smallest slice: a perform-claim checker for the one grammatical form "performing
<Op>" / "performs <op>" against the op's live call-site census. Speculative-tier;
listed last deliberately — the general problem is semantic and belongs to `mentl
audit`'s endgame, but the measured false instance justifies naming the class.

**Named?** The general form is §0's mentl-audit endpoint; the specific
perform-claim slice is new.

## Observations that refused to become findings (adversarial kills)

- "Use more refinements in the wheel" — killed: R3's fragment is ground-arith only;
  wider self-refinement today accrues V_Pending noise, not proof (band F gates it).
- "Rewrite the emit's string building" — the `~> Backend` seam is already named
  (destiny audit R6); nothing to add.
- "Replace host perf profiling" — genuinely host-side (§8: guest profiling dies at
  proc_exit); correctly external, not a confession.
- "The python oracles in frontier legs are hand tools" — they are deliberately
  EXTERNAL oracles (independent implementation = the trusting-trust leg); absorbing
  them would weaken the gate.

## The three opening moves, restated as one sentence each

1. **Render what the graph already computed** — refs-of spans (pipeline.mn:1251), and
   development grep dies into `mentl query`.
2. **Let fixtures state their own contracts** — `// expect: refuse E_*` + imports as
   link sets, and the 1,556-line frontier bash begins dissolving into `mentl test`.
3. **Perform the eight** — wire `interrogate_at` into the address surface, and the
   project's method stops being prose Claude follows and starts being a projection
   the medium runs.
