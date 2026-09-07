# Mentl — RESIDUE.md · the named-peer catalog

> **REFERENCE, NOT READ-PATH.** The contract stays three documents —
> `CLAUDE.md` (method), `PLAN.md` (substance), `docs/SYNTAX.md` (surface). This
> is the full catalog of named positive-form peers: every gap the project knows
> it has, each with exactly one home.
>
> **Why it left `PLAN.md` (2026-08-05).** 1,474 lines of catalog against ~180
> lines of actual program. The law it serves — *a hidden gap is drift; a named
> positive-form peer is the ultimate form* — is satisfied by the gap being
> WRITTEN DOWN in one place, not by it being in the read path. `PLAN.md §11`
> names the peers each phase touches; this file holds the rest.
>
> **The law is unchanged.** A gap that lives only in a comment is not named
> (measured 2026-07-31: ten `lower.mn` peers existed only in comments and were
> invisible to the roadmap, to `mentl teach`, and to the frontier ranking). A
> gap that lives only in a session's memory is not named either. It lands here,
> or it does not exist.
>
> **Entries are dated observations, not standing truth.** Several below record
> measurements later refuted — deliberately, per the counted-kills law. Where an
> entry and the artifact disagree, the artifact wins. Verify before citing.
>
> **Its own destiny.** These are the absences the frontier should rank and the
> gradient should surface — `mentl frontier` already ranks holes, pending
> proofs, and tightenings from the live graph. A peer catalog kept by hand is
> the same prose shadow the ledger is, one namespace over.

---

`Hβ.effects.return-position-fn-row-is-a-var` — NAMED 2026-08-18 by the
6.3 modal sweep, crown-tier. THE MEASUREMENT, three programs: a closure
performing E, handed OUT of an arm through `resume`, called under `with
!E`. (1) Without a declared row on the op's returned fn type it checks
CLEAN and RUNS — exit 7, the outer handler answering, so the perform is
real and the negation is simply not enforced. (2) With `with Pure`
written on that returned fn type the identical program REFUSES,
E_EffectMismatch. (3) The same closure written inline rather than passed
through resume is caught either way. So the subsumption machinery is
reached at the resume site and works; what is missing is anything to
subsume UNDER.
THE ROOT: an unannotated fn type in a RETURN position mints a free row
VAR, and `fn_arg_directional_positions` fires only when the declared row
is a concrete cap (`row_cap_form`) — deliberately, because a var-tailed
param row is the effect-polymorphic FLOW channel `map`'s `f` needs, and
masking it once convicted 297 wheel sites in one march. A var in a
return position is not a flow channel though; it is a promise about a
value the callee PRODUCES, so the arm teaches the declaration its row
instead of meeting it.
THE DESIGN is variance, and it is why the two positions differ: a
CONTRAVARIANT position (a param) is a demand the caller fills, so its
unannotated row stays a var; a COVARIANT position (a return, an op's
result, a field's declared fn type) is a promise about what the produced
value may do, so its unannotated row should CAP at Pure. Every other
latency carrier already behaves that way — field, list element, tuple,
variant, default param, handler state all refuse — and resume is the
one that does not.
THE OP-RESULT HALF LANDED 2026-08-18, pin 016e00f38745. The blast radius
was measured first and is EMPTY: no op in src or lib declares a fn-typed
return, so `cap_result_fn_row` at `register_one_op` risks nothing in the
wheel — and that emptiness means the crucible pair is the rule's ONLY
oracle, m3 == m4 being blind to a form the wheel never writes (tripwire
3, which is why the pair was written first). The bare form now reports
`E vs Pure` and crown is 59/0. It still RUNS: E_EffectMismatch is not
armed, the name-dependent class §7 tracks toward universal refusal.
**KILL (2026-08-18) — "the other covariant positions are the arc."** The
entry above named a plain fn's declared fn-typed RETURN and a record
field's declared fn type as the remaining work. Measured the next
iteration: all three shapes ALREADY REFUSE — declared fn return,
inferred fn return, and a declared record field holding a performing
closure. There is no arc, and the reason is structural rather than
lucky: a fn HAS A BODY, so its result row is inferred from what the body
actually performs and genuinely carries `+E`. An op has no body, so its
declared type is the only source, and a free var there had nothing to
constrain it. That is what made the op result the single special case,
and it is why the population sweep found zero of all three in src+lib
yet only one of them leaked.
WHAT THE SAME PROBE FOUND INSTEAD, and it was real: the first cut of the
cap matched only a TOP-LEVEL TFun, so `give() -> [() -> Int]` and
`give() -> (Int, () -> Int)` both checked clean and ran at 7 while the
bare `give() -> (() -> Int)` refused. A closure hides in any container
the result carries. `cap_result_fn_row` is structural now — TList,
TTuple and TRecord recurse, a returned fn's own result recurses, and its
PARAMS keep their vars because a param of a returned fn is a demand on
whoever calls it, the contravariant half of the same rule. Crown 61/0
with leak-resume-latent-in-list and -in-tuple, both seen RED.

`Hβ.effects.variant-payload-fn-row` — NAMED 2026-08-18, the one covariant
carrier the result cap deliberately does not reach. `type Box = Wrap(() ->
Int)` declared as an op's result leaks: a closure performing E, resumed out
inside `Wrap`, called under `with !E`, checks clean and runs at 7. The
payload's row is declared at the TYPE declaration and lives on the
constructor's scheme, registered by `register_type_constructors` — a
different writer from `register_one_op`, and capping `TName`'s ARGS would
cap type arguments, which is the wrong altitude. The rule is the same
variance the result cap applies: a constructor payload is covariant at
construction, so its unannotated fn-type row should cap at Pure where the
type is declared. Unmeasured: the population of constructor payloads with
fn types in src+lib, which decides whether this is one arm or an arc.

`Hβ.tools.micro-battery-link-is-the-blob` — NAMED 2026-08-18, the
remaining half of a hole whose other half closed the same day. Every
battery here except the frontier feeds its fixture in on stdin after
concatenating RTLIBS — `memory, strings, lists, prelude`, four modules —
while a real program links seven through its import DAG. The syntax
battery's divergence is now gated (verify runs each fixture through the
manifest too, and caught tests/syntax/labeled-args.mn declaring a name
that WasiThreads owns, unreachable through the manifest since it was
written). The MICRO battery has the same link and no such leg, and the
reason is real rather than laziness: micros are wheel-shaped, many are
`// expect: refuse` fixtures, and a blanket check-clean contract does not
fit them. What WOULD fit is a per-fixture declaration of which link it
means — the default being the manifest, since that is what a person runs.
Measured while naming it: a manifest sweep of every fixture in
tests/{frontier,micros,crown,rows,floors} finds exactly one
E_FnShadowsOp, the deliberate one, so nothing else in the corpus is
silently unreachable today. The peer is about the next one.

`Hβ.tools.gate-stamp-is-uniform` — NAMED 2026-08-18. The frontier keeps a
stamp (`.build/frontier-stamp`, the boot sha256 written on a 0-red run),
so the board can say whether it measured THIS boot and the pre-commit
perimeter can refuse a wheel commit without it. Crown, proof-exactness,
effect-identity and instrument keep none, so nothing — not the board, not
the hook, not PROVENANCE — can distinguish "green" from "not run since
the pin moved" for four of the six boot-suite gates. That is the exact
shape §11 tripwire 4 records: the crown went eleven ledger entries
unmentioned while a leak rode the arc, and nothing written was false. The
stamp is six lines in frontier-gate.sh; the work is making it one thing
every gate does rather than four copies, which is why it is named rather
than pasted. Its own destiny is `mentl verify` owning the suite and the
stamp being a graph fact about the pin instead of a file. Until then
`state.sh` prints the four as explicitly unstamped, because a blank you
can see is worth more than a silence.

`Hβ.repr.option-of-word-niche` — NAMED 2026-08-18, by the landing that
made the cost real. `base_digit(base, byte)` answers IS-this-a-digit and
WHICH-digit together, which is the whole point of it — the split it
replaced is where the lexer's two classifiers drifted apart and read
0b1012 as 5. The honest shape is `Option(Int)`, and the constructor
charge bills `Some(d)` once per scanned digit byte, so the row is
Memory + Alloc and the scan allocates per digit. That is a
REPRESENTATION cost, not a design one: an Option over a word has a free
niche (a word-sized payload cannot use every bit pattern, and the
absent case needs exactly one), so the gradient should carry it in a
register with no record at all. Until it does, the charge is named here
rather than declared away — the alternative, splitting the answer back
into a predicate and a value to dodge the alloc, is the deleted bug
returning to save an allocation. Rides the repr gradient (PLAN §5.U
step 0/1); the measurement that would price it is the alloc count on a
literal-dense compile, which nothing measures yet.

`Hβ.query.cost-per-module` — NAMED 2026-08-18. The cost facet reports
one SUM (`7 module(s) · 6352 source line(s) · 67301 node(s)`), so when
the prelude-floor leg went RED this session the next question — WHICH
module carries the lines — had no projection and was answered with
`wc -l` over the seven names the modules facet had just printed. The
answer mattered: src/types.mn alone is 3672 of the 6352, 57% of what a
program that asks for nothing must process, which is the evidence
`Hβ.driver.link-is-reachability` needs and the reason lexical ADTs
belong in the lexer. The facet already walks the weave's NModule cells
to count them; reporting the per-module split is the same walk not
throwing its intermediate away. Sequenced with the reachability link
work, whose progress it is the natural way to read.

`Hβ.verify.comment-ref-ratchet-is-dark` — MEASURED 2026-08-18, one
fact and no cause. `mentl check src/lexer.mn` reported
`W_CommentRefUnresolved` on `scan_number`'s comment (backticked
`base`), and `mentl query src/main.mn "type base"` answered *not
found* — so the reference resolves nowhere in the whole-wheel link
either. Yet `comment_refs_max: 0` holds and the census stderr the
ratchet reads (`.build/m2cache/m2.err`, 60,989 bytes) carries **zero**
`W_CommentRefUnresolved` lines. A ratchet pinned at 0 that reads 0
from a leg emitting none is not holding anything. The solo checks emit
them freely — types.mn alone showed seven — so the warning is real and
the wheel-link path is where it goes missing. NEXT PROBE, and it must
run before any fix: instrument or diff the two entry paths on ONE file
with a known-unresolved reference, because the difference between them
is the whole finding and every explanation for it so far (link-set
size, reachability pruning, blob concatenation) is forward reasoning
from code. Contrast: `catch_abort` warns solo and correctly does not
warn in the link, because it genuinely resolves there — so the leg is
not simply off.

**KILL (2026-08-18) — "the prelude-floor red predates this iteration."**
The frontier came back `370 pass / 1 red`, the leg six pins deep in
`frontier: NOT RUN` blanks, and lib/ commits since the leg's birth
showed added `import` lines from the per-module sweep. That is a
complete, plausible story and it is wrong. Stashing the session's three
source edits and re-running the leg against the previous boot measured
**6359 — green**. The red was 6413 and it was mine: src/types.mn is 57%
of the prelude floor, so ~40 lines of lexical ADT landing there pushed a
bare program over a ceiling it had 41 lines of room under. Every step of
the refuted story came from reading code and git history; the refutation
took one stash and one leg. The floor now measures 6352, seven lines
BELOW where the session found it, and the ceiling falls to 6360 to hold
that. Recorded because the shape recurs: a rise adjacent to someone
else's landing reads as theirs, and the stash is cheap.

`Hβ.teach.severance-vocabulary-from-link` — STAMPED 2026-08-08 (found
by asking the medium its own next move: `mentl teach src/main.mn`
narrated the IDENTICAL suggestion — "add with !IO" — for every fn
including the TCP server loop). TRACED: teach's severance candidates
come from the FIXED Annotation ADT (mentl.mn's eight variants;
ANotIO/ANotNetwork carry hardwired names), and the wheel performs
WASI/Filesystem/Memory/Alloc — never anything NAMED "IO" — so `!IO`
is VACUOUSLY provable on every fn and the gradient ranks it first
everywhere: provability without informativeness (the same shape as
the audit's "+29 more provable" tail — severing a name the program
never performs is the negation of Zebra). THE LAW: the severance
vocabulary is the LINK'S OWN performed-name set — a `!E` suggestion
is informative exactly when E is performed SOMEWHERE in the program
and absent from THIS fn's row; the name-keyed fixed catalog is
drift-8's cousin at the teaching layer. PRICED: the performed set is
one read of the channel the reached-effect report already projects
(row_names over the judged decls — no new walk); teach's per-fn
suggestion then intersects performed-minus-own-row, ranked by the
existing gates × proximity. ENUMERATED writers: mentl.mn (the
annotation enumeration + unlock_capability's name-keyed arms), the
teach render, and the audit's severable line (a SEPARATE mechanism,
corrected at build — the audit severs the fn's own row members and is
already name-general; the doubled-Sandbox render is its own small
fix). The ownership/refinement/purity families (own/ref/Pure/refined)
stay catalog-form — they are not name-keyed. RESOLVED IN TWO
HALVES, same day (pins 367c2d44425c, f544489b21e6): the declared-set
gate first (`!IO` died — undeclared), then the PERFORMED-set as
mentl_default handler state (the lazy memo via resume-with-state;
per-fn asks O(1)) — uniform `!Network` died the same death, and
`!Alloc` survives exactly where informative (performed across the
wheel; the Real-time unlock on allocation-free fns). THE GROWTH
LANDED same day (pin 811c5d423bf7): ANotEffect(name)/CProvenAbsence
propose any performed name's severance, subsuming the fixed pair
operationally. The fixed trio's ctors are DELETED WHOLE (2026-08-09,
pin 54c97b0f7220 — their one live ref was pick_highest_leverage's own
stale ladder, the red-board fix; the ladder speaks ANotEffect now).
THE PEER IS RESOLVED WHOLE (2026-08-09, pin 84fc4aaac0f6): (a)
TIE-RANKING landed — the performed union carries PREVALENCE counts
((EffName, Int) pairs, sorted most-performed-first at the one memo),
so equal-leverage generics resolve by how much of the link performs
the name, never by env enumeration order; the rich-label ladder stays
on top (probed: the prevalence fixture's !Common beats
first-declared !Rare on the bare link, while the RTLIBS pure control
still leads with !Alloc/Real-time). Gate:
tests/frontier/mn-teach-prevalence.mn, seen RED (!Rare) first. (b)
the doubled-Sandbox render was ALREADY FIXED — severance_unlocks
dedupes by structural == with the measured double recorded in its own
comment; the bank had outlived the fix. The named growth beyond this
peer: per-fn PROXIMITY (does this fn's call neighborhood perform E)
as a second informativeness axis — synth's rank_of owns that read;
it joins if a real teach consumer measures prevalence insufficient.

`Hβ.types.predicate-is-expr` — TRACED 2026-08-08 (Phase 8.1's stamp
check; the peer had lived only as a DEP line in the verify-reads-canon
entry): the CORE IS ALREADY DONE — PExpr is DELETED (types.mn's own
record beside the Predicate ADT: its leaves were a lossy copy of the
expression the AST node already holds, with a `_ => PEVar("?")`
surrender; the predicate now carries live operand HANDLES — PCompare
over two node handles, PBoolNode, PWithSelf threading the self
binder). What REMAINS of 8.1's sentence is the comparison-chain
teaching: `-1.0 <= self <= 1.0` still parses left-assoc into the
ill-sorted `(Bool) <= Float`, the predicate walk accepts it opaquely,
and the debt SURFACES honestly at the executable ("verify: pending
comparison -1.0 <= self <= 1.0" — probed live) but never rejects
loudly at the decl. The loud rejection = judging the where-clause
expression through ordinary inference (the chain's Bool <= Float is
then E_TypeMismatch with a Reason at the decl) — sequenced with the
verify-reads-canon proposal it DEP-feeds, since a judged predicate
node is exactly what canon saturation needs. The probe's side-find is
its own entry: `Hβ.emit.unused-wide-param-floor`.

`Hβ.emit.unused-wide-param-floor` — RESOLVED FOR THE PROVEN CLASS
2026-08-08 (pin cfa58fdd5479, same day as pinned): decl fns read their
param widths from the env bucket (O(1)) when the body scan misses;
wildcards short-circuit; the probed pair runs to 11 under the
frontier's harness. THE NAMED REMAINDER inside this entry: the
synthesized family (lambda_N/thunks/arms) keeps its historical floor —
its call protocol is the indirect/wrapper machinery, never probed
incoherent — because the column walk that would answer it measured
106s of m3 leg (snoc-list indexing; the scan quadratic); the O(1) form
is emitfns_col re-keyed as an smap by name, landing with the columns
arc. The entry below is the original pin, kept as the dig's record.

THE REMAINDER IS RE-CUT BY MEASUREMENT (2026-08-12, probes at pin
c10ad6ef; the O(1) read landed at fe4b88b2 and the deletion was sized
against it, so the sizing was the thing to test first). Three findings,
each artifact-backed, and the first two REFUTE this entry's own
framing:

(1) THE SYNTHESIZED FLOOR IS NOT A FABRICATION — IT IS THE WORD FACE.
Probed: a lambda with an unused `Gain` param (`apply_it((s) => 7, 0.5)`)
runs 7; a nested fn with one (`inner(g)` inside `outer(g: Gain)`) runs 7.
The emitted WAT says why: the caller BOXES the f64 into `$wide_cell` and
pushes the cell pointer, and `$inner` signs `(param $s i32)` — the two
agree because both speak the word face. When the param IS used the scan
reads RF64, `fn_record_is_wide` fires, the `$wf$` twin is emitted, the
table slot holds the twin (`emit_fn_refs`), and the twin derefs. So the
floor is coherent BY CONTRACT for every indirect-dispatched kind, not
merely "never probed incoherent". Reading the declaration instead would
be harmless there (one extra twin) — and fatal at the arm, per (2).

(2) THE BRIEFED BUILD, EXECUTED AS WRITTEN, REGRESSES THE ARM CLASS.
An arm's floored param is what keeps it assembling today: the perform
emits `emit_args_word(args)` — boxing every wide arg — then
`(call $op_<hname>_<op>)` against the arm's repr-projected signature.
Floor the param and the boxed word matches; give the param its real
width and the same call refuses. Measured both directions
(tests/frontier/mn-arm-wide-op-arg.mn, NOT wired to the board because
it is RED): an arm that IGNORES a `Gain` arg runs; an arm that READS one
refuses at assemble with `expected [i32, f64] but got [i32, i32]` at
`(call $op_mixer_gain_read)`, zero diagnostics. That is a live
capability hole — a handler arm cannot use a wide op argument — and it
gets its own entry, `Hβ.emit.arm-wide-arg-face`.

(3) THE DELETION IS THEREFORE DEP-GATED, and the DEP is a
REPRESENTATION change, not an edit. Both readers must read ONE fact —
the op's DECLARED arg types — so that the arm's signature and the
perform's arg emission agree by construction instead of by the accident
of non-use. The emit cannot reach that fact today: an arm fn is named
`op_<hname>_<opname>` and is not env-registered, and splitting that
composed name to recover the op is by-name re-derivation (both halves
may contain underscores — genuinely ambiguous). The column is the road,
and the briefed path does not reach it: `graph_emitfn_at`'s origin is
param-bearing for only TWO of the six kinds — EfkLambda and EfkNested
carry a LambdaExpr/FnStmt at the origin, while EfkArm notes
`node_handle(arm.body)` (the body, not the arm), EfkK notes the perform
handle `ph`, EfkThunk notes a boundary handle and has no params at all,
and EfkPartial's params come from `partial_split`. Nor does lower hold
the handles to note: the arm site sets `locals_handles =
zeros_of_len(len(arm_params))` by the bind_names_as_locals convention.
SO THE BUILD IS: the emitfn note carries the fn's PARAMS the way it
already carries its CAPTURES — one more `[(String, Int)]` field written
at the one writer (7 sites: the effect decl in types.mn, the handler arm
in graph.mn, five note sites in lower.mn), with the arm's pairs sourced
from the op's `EffectOpScheme` — then `param_repr_of` reads that column,
the body scan (`find_local_handle_list`/`_arms`/`_expr`, 104 lines)
deletes whole, `body` drops from all four caller signatures, and the
perform's direct call targets the face it prepared. All of it lands
TOGETHER or the module breaks, and its verdict lives ONE GENERATION
DEEP — `Hβ.emit.twin-state-width`'s own lesson: m2 green is not the
verdict.

`Hβ.emit.unused-wide-param-floor` — TRAP PINNED 2026-08-08 (found by
Phase 8.1's opening probe, en route to the predicate trace): a fn whose
WIDE-typed parameter is UNUSED in its body emits an i32-floor
signature while every caller pushes the real width — INVALID WAT, loud
at assemble (`return_call expected [i32, i32] got [i32, f64]`). Minimal
pair, both probed on pin a025c3523a84: `fn accept_g(s: Gain) = 1`
(Gain = Float where 0.0 <= self; s unused) REFUSES at wat2wasm;
`fn accept_u(s: Gain) = if s <= 1.0 { 1 } else { 0 }` (s used) runs
clean. ROOT: `param_repr_from_body` (backends/wasm.mn) derives a
param's repr by SCANNING THE BODY for its LLocal and falls to
`if h == 0 { RI32 }` when the scan finds nothing — the graph already
holds the param's type on the fn's own TFun product, and the
usage-scan re-derivation fabricates the floor exactly when usage is
absent (Carried-Truth, textbook; the wildcard-zero shape in repr
costume). FIX DIRECTION, enriched by the same-day channel trace: NOT
a LowFn field — LFn(String, Int, [String], [LowExpr], EffRow, Int)
is condemned machinery (the 5.5 lowering-column arc sentences the
whole record; 36 sites would widen a structure sentenced to
deletion) — the param handle is read from the GRAPH's own columns:
for the SYNTHESIZED family (EfkLambda/Thunk/Nested/Arm/K/Partial)
the emitfns_col already carries (kind, ORIGIN, name, fence, caps) —
origin → graph_node_body → LambdaExpr/FnStmt params → the param's
handle → repr_of(lookup_ty(h)); for PLAIN DECLS (the probed class —
no EfkDecl exists in the column) the decls_col holds the judged
FnStmt handles, matched by name through graph_node_body. BOTH need
the one missing piece: a by-name READ op on the columns
(graph_emitfn_note is write-only; decls_col projects only through
QDecls) — the column is the home, the read op is its projection.
Then param_repr_from_body and the find_local_handle family (~60
lines of body-usage scanning) DELETE whole — all four callers (the
wide-fn classifier at 2558, the deref at 2598, the signature renders
at 3015/3242) take the same graph read, lambdas included, and the
`if h == 0 { RI32 }` fabrication has no site left to live in. Sized
one fresh lease. THE GATE LANDED 2026-08-11 for the PROVEN class:
tests/micros/mn-unused-wide-param.mn pins the fixed pair in the
battery (exit 12, diags 0 — accept_g was RED at wat2wasm before pin
cfa58fdd5479; the entry's own record is the RED bank). The wheel
itself never hits the class (march green — the wheel's wide params
are used), so the oracle was blind by the familiar rung-3 shape: a
class the wheel never exercises — the micro is now the eye. The
synthesized-family deletion stands sized one fresh lease, its O(1)
read (graph_emitfn_at) landed at pin fe4b88b2f1be. THAT SIZING IS
SUPERSEDED by the 2026-08-12 re-cut in the entry above: the origin is
param-bearing for two of six kinds, and the deletion DEP-gates on the
arm's call face.

`Hβ.emit.arm-wide-arg-face` — TRAP PINNED 2026-08-12 (found by probing
the sibling entry's sizing rather than trusting it). A HANDLER ARM
CANNOT READ A WIDE OP ARGUMENT. `perform`'s Tier-1 emission pushes
`emit_args_word(args)` — every wide arg boxed into a cell, the arm fn's
ABI declared floor-words in its own comment ("the arm fn is SHARED
between the floor and every twin, so its ABI is floor words",
backends/wasm.mn LPerform arm) — and then direct-calls
`$op_<hname>_<opname>`, whose signature is projected from the arm's
PARAM REPR. The two readers disagree exactly when the arm uses the arg:
the param repr reads RF64 off the use site, the signature renders
`(param $g.f64 f64)`, and the pushed cell pointer meets it as
`expected [i32, f64] but got [i32, i32]`. Measured at pin c10ad6ef,
zero diagnostics, one assembly refusal at `(call $op_mixer_gain_read)`.
The class HID because the unused direction is coherent by accident (a
floored param matches the boxed word), and the wheel's own arms never
read a wide arg — the same oracle blindness the sibling entry names:
green board, absent capability. THE REPRO IS BANKED:
tests/frontier/mn-arm-wide-op-arg.mn (the pair — `gain_read` reads its
`Gain` arg, `gain_ignored` drops one; expect 11). It is deliberately
NOT wired into frontier-gate.sh: a RED leg refuses every pin, and the
fix is DEP-gated below. Wire it in the same commit as the fix, which is
what makes it a seen-RED gate rather than a claim.

THE MACHINERY IS ALREADY 90% RIGHT, which is what makes the fix small
once its DEP lands: the `$wf$` word-face twin for a wide arm IS emitted
(`fn_record_is_wide` fires on the used arm), and the table slot already
holds it (`emit_fn_refs` substitutes `$wf$` at the arm's own index, so
the INDIRECT dispatch path is correct today). Only the direct call
names the native symbol while pushing the word face. THE FIX IS ONE
CHOICE AT ONE SITE — the perform calls the face it prepared — and it is
DEP-GATED on `Hβ.emit.unused-wide-param-floor`'s column build, because
keying that choice on the callee's wideness requires the arm's params to
carry their DECLARED widths: today an arm that ignores a wide arg floors,
emits no twin, and a `$wf$`-keyed call would name a symbol that does not
exist. Both halves land together, or each breaks the other's case. The
alternative face — arms word-faced in signature with the body
dereferencing at each use — is the same coupling read from the other
end and costs a new deref path where the twin generator already exists;
prefer the twin. Sequenced with the 5.5 lowering-column arc, whose one
repeated move (put the per-handle fact in a column, write it at the one
writer, migrate the readers, delete the side-structure) is exactly the
shape here — the body scan IS the side-structure.

`Hβ.ifc.flowlabel-inference-in-hm` — STAMPED 2026-08-08 (the C chain's
second step; build-ready design, not yet built). TRACED, against the
artifact: today's FlowLabel is COMPUTED per query (query_flow_label
reads a Ty's refinement-predicate NAMES — secret/classified/sensitive),
and the one enforcement is construction-site (every splice ⊑ Public).
The inference form must answer two structurally different needs the
trace separates: (1) SOURCE classification — which values are Secret —
and (2) FLOW obligation — which sinks a value may reach. The trap the
trace rules out: labels CANNOT ride the type union-find naively (every
Int unifies through shared cells — one tainted Int would label them
all); label flow follows VALUE-flow edges, not type-identity edges.
THE DIRECTION THE DOCS ALREADY ANSWER (§4⑥ verbatim: "Mentl absorbs
information-flow control into the same Boolean algebra"): the FLOW
fact is a ROW element — a parameterized pseudo-effect Flow(Src, Sink)
charged where a labeled value crosses an observation edge (a splice
whose string reaches a handler, a call into a sink-rowed fn), with
`!Flow(Secret, Log)` proving absence exactly as !Alloc does,
discharged by the same subsumption gate, inheriting the crown's
instance machinery (eff_forbids' EANode conservative arm covers the
unknown-label case for free). SOURCE classification stays per-value:
the refined-alias read today, a declared label surface later — the
classifier's predicate-name heuristic retires when labels become
declared facts, not when the row work lands. PRICED: (a) the row
element's substrate CLEARS AT ZERO — probed 2026-08-08 on the pinned
boot: `effect Flow(src: Int, dst: Int)` declares, installs
(`with Flow(2, 1)`), negates (`!Flow(2, 1)`, rendered correctly in
the T_OverDeclared narration), and RUNS; ADT-ctor arguments clear too
(`effect Flow(src: Level, dst: Level)` with `Flow(Sec, Pub)` checks
clean and runs) — no grammar or algebra work precedes the build; and
the ENFORCEMENT half fires (re-probed 2026-08-11 at pin 93825f3d): a
transitive performer under `with !Flow(1, 2)` REFUSES with the
instance-precise mismatch (`!Flow(1, 2) + Any vs
Flow(<operand>, <operand>)` — 6.2's conservative EANode arm), and the
unhandled Flow at the root refuses the executable independently
(E_EffectUnhandled, armed) — `!Flow` proving absence as `!Alloc` does
is MEASURED live for op-performed flows; the build's whole remainder
is the op-less observation-edge charge and the label surface; (b)
THE CARRY HOLDS FOR SOURCES AND DIES AT DERIVATION — the same-day
re-derivation corrected the first bank (retraction law): a SOURCE
value's label rides its type (Vault-typed pw is classified wherever
inference threads it), but the SPLICE RESULT binds plain ty_string
(infer.mn's MakeStringExpr arm — graph_bind(handle, ty_string)), so
the derived string loses the label at the bind — which is exactly WHY
the sound check sits at the splice today (the last point the label is
visible). Sink-sensitivity therefore requires the PROPAGATION half:
the interpolation's bound type carries the joined fragment label
(TRefined(String, the classification) when any fragment classifies
above Public), so the built string IS classified downstream; (c) the
sink edge then needs its own judgment — an argument position whose
callee performs the observation class, refusing when arg-label ⊑
sink-clearance fails — and SINK CLEARANCE was the open sub-question
(what marks a callee as an observation, at what level, declared how),
now ANSWERED by measurement in THE SINK DERIVATION below, which kills
every clearance-carrier the artifact can read today and leaves the row
charge as the one surviving form; refinement subtyping alone cannot
refuse there (TRefined(String) ⊑
String unifies — refinements narrow, never block). With the
propagation half + the clearance question, the build is
DEDICATED-ARC, not loop-lease; the substrate probes (a) stand; (d) no
new traversal — charges ride judgment where rows already accrue,
O(charge sites). ENUMERATED writers:
types.mn (the Flow effect vocabulary), infer.mn (splice_flow_check
charges the row instead of verifying against Public; the sink-edge
charge at install), effects.mn (nothing — the algebra is closed over
parameterized names already), crucibles (the leak pair re-lands as
row-negation crucibles; the over-refusal case — Secret splice bound
for a Secret sink — becomes the sound fixture that PROVES
sink-sensitivity). The REFUTATION TARGET priced against it: a fourth
graph sort of label cells (row-var precedent) — heavier (a new sort
in unify/generalize/instantiate) and unnecessary if the row carries
the flow; it wins only if per-value label POLYMORPHISM (a fn generic
over its argument's label) is needed before declared labels exist —
measure at build, burden on the challenger.
THE SINK DERIVATION — four kills, one survivor, two DEPs (2026-08-12,
probed at pin c10ad6ef through the installed shim; the build opened on
the brief's named form and the artifact refused it four ways, so the
kills ARE the landing). What the probes killed, each by measurement:
(1) THE EFFECT-OP PARAMETER IS NOT THE CLEARANCE. The reading was that
an op's parameter type declares what it may observe, so the charge
reads it at the op call. lib/io.mn:45 refutes it — every WASI
op takes Int (`fd_write(Int, Int, Int, Int)`): the value crossing into
the host is already a buffer pointer, so a String's label is gone
before the op boundary exists. No labelled argument ever reaches a
real sink's parameter. (2) THE CALLEE'S ROW CANNOT CARRY THE
CLEARANCE EITHER. row_flow_label reads the tail — EtAll (the
universe-minus stance) is Secret, every other tail Public — so
`with Alloc + !WASI` should have read confined. It reads Public:
`flow confined_alloc` and `flow bare_alloc` answer identically on
bodies that genuinely allocate, because the PUBLISHED row is the
INFERRED one and a declared negation never reaches the scheme
row_flow_label reads. The EtAll arm has no live producer at a fn
scheme; whether it has one anywhere is the open half of this kill.
(3) THE PARAMETER-TYPE READING, GENERALIZED, IS VACUOUS OR
OVER-REFUSING — no measurement needed, the lattice decides it: a
concrete `String` parameter labels Public, so constraining against it
refuses every pure helper that touches a secret; treating a concrete
parameter as label-polymorphic instead leaves only Secret-typed
parameters constraining, and those accept everything. Neither is a
check. (4) THE ROW CHARGE SURVIVES THE DESIGN, AND ITS INSTANCE
PRECISION IS REAL (2026-08-12). `Flow(Src, Sink)` charged where a
labelled value crosses, `!Flow(Secret, WASI)` as the policy,
declassification as a handler that absorbs the charge — that form
needs no allowlist, inherits transitivity from the row, and is §4⑥'s
own sentence. The instance-precision DEPs this block once carried
(D1 the nullary-ctor fold, D2 the effect-name representation, the
adjacent E_DeclaredRowContradiction kill) LANDED at pin 42aeaf0739 —
the registration fold, `EAEffect`/`EACon`, crown 39/0; the
effarg-node entry below is the one home for the record — so
`!Flow(Sec, Wasi)` now admits a `Flow(Sec, Store)` caller, an
effect may stand at an argument position without the
parallel-namespace ADT mirror, and the refinement clause keeps its
severance. The sink chain's remaining build is its OWN: the row
charge at observation edges and the sink-edge move that retires the
construction-site over-refusal. WHY THE TWO HALVES DID NOT LAND
SEPARATELY (the stamp's
own coupling warning, now measured): the propagation half alone is
invisible while the construction check stands (the splice already
refuses), and retiring the construction check without a sink edge lets
every classified splice through — a regression the leak fixture would
catch. Coupled means coupled; neither half is a landing on its own.

`Hβ.ifc.dcc-noninterference-gate` — FIRST FACE LANDED 2026-08-08 (pin
a025c3523a84; the C chain's head, banked here at its stamp). TRACED: the
lattice (Public ⊑ Tainted ⊑ Secret, total join), the classifier
(query_flow_label — predicate-name seed), and the splice enforcement
(check_splice_flow_labels → verify(PFlowLe(label, Public)) → always
decidable → E_RefinementRejected) are all real — and the first probe
caught the ShowExpr desugar defeating the whole check (the wrapper binds
String; the label read saw Public; a classified splice passed check).
Fixed by reading through the wrap; the leak/sound fixture pair pins both
faces, born RED. THE NAMED REMAINDER, in chain order: (1) today's check
is CONSTRUCTION-site — every splice must be ⊑ Public, sink-blind; DCC's
own property is sink-sensitive (a Secret splice bound for a
Secret-labeled sink is legal and today over-refuses) — that sensitivity
is `.flowlabel-inference-in-hm`'s buy (labels riding the union-find,
the constraint moving from the splice to the sink edge), NOT a patch
here. The over-refusal is CONFIRMED LIVE at pin c10ad6ef (2026-08-12):
a `Vault` value spliced into a string and handed to an effect op whose
parameter is declared `Vault` refuses at the CONSTRUCTION site with
`E_RefinementRejected: Secret ⊑ Public`, never reaching the sink that
would have cleared it. That refusal is the RED the sink-sensitivity
fixture inherits when the chain's next step lands; its two instance
DEPs landed at pin 42aeaf0739 (the effarg-node entry's registration
fold), so the step is un-gated. (2) The classifier stays a
predicate-NAME heuristic until that same landing. (3) PC-labels
(implicit flow through branching), the
integrity dual, robust declassification, and the TCont flow-world
follow in the banked band-C order. PRICED: the first face was one
infer read-through + two fixtures + one leg; each following chain step
is its own stamped landing.

`Hβ.syntax.effarg-node-in-with-clause` — RESOLVED 2026-08-08 by
measurement (the peer was PLAN-named at 6.2 but never banked here; this
entry is its one home, written at resolution; the header line was
absent until 2026-08-12, so the name PLAN §6.2 points at could not be
found in this file at all — restored with the ADT-ctor face below). 6.2's "unconstructible
from the surface" ruling generalized from the wrong probe shape: a
BARE-IDENT effect arg (`fn stage() with Sample(the_rate)`) parses as
EANode(handle) at the with-clause (parser's eff-arg atom), resolves
live, checks clean, and RUNS through an installed handler (probed
end-to-end at pin 0bbfe0e58e1cb6f3); the conservative-arm crucible
(tests/crown/leak-instance-node.mn — EANode not provably distinct from
the forbidden 44100 refuses) stands in the battery and holds. What a
with-clause cannot carry is a COMPOUND arg (`Sample(base + 100)`) —
the grammar's arg atom is one token, so the `+` breaks the parse
(P_ExpectedToken, before any E_EffArgNotLiteral). The named remaining
reach: W23's "constant-folded projection of its operand node" widened
to compound CONSTANT expressions — a parse change (the arg atom
becomes a bracketed expression) plus the fold at registration, priced
small and sequenced with band-A instance work; a general runtime
expression as an instance stays out (the row algebra compares
instances at the decl).

THE REGISTRATION FOLD LANDED 2026-08-12 — the sink chain's D1 and D2
in one arc, RED-first, m2 == m3 one-generation (the wheel authors no
capitalized bare-ident instance arg, so the fold is judgment-neutral
on its own source; census 0, crown 39/0, verify green). The
representation: EffArg grew `EAEffect(Int)` (an EFFECT at an
instance-argument position — the intern handle ENamed carries; handle
inequality IS value distinctness, one namespace) and `EACon(Int)` (a
NULLARY ctor — its intern handle; two distinct constructors are
distinct VALUES unconditionally, so no type identity rides the word).
The fold is `resolve_declared_instances` at infer's declared-row gate
— the one env-whole deterministic point — mapping each authored
EANode arg through its env kind: EffectDeclKind → EAEffect,
ConstructorScheme with a TName scheme-result (nullary; fielded ctors
carry TFun) → EACon, everything else the conservative EANode arm
unchanged (leak-instance-node's let-bound contract holds). It lives
there and NOT in build_row_seen because the parser calls that fold at
parse time (fn-TYPE rows, env part-built) — an env-dependent leaf
would make the row a function of parse order, 4.2's decl-order
disease. Crucibles: sound-instance-ctor-distinct +
sound-instance-effarg-distinct (born RED at mismatch=1, the
conservative over-refusal, green under the fold) with
leak-instance-ctor-same + leak-instance-effarg-same the
never-over-admit guards (crown 39/0). THE ADJACENT KILL LANDED THE
SAME DAY: E_DeclaredRowContradiction is instance-precise through the
same fold — absent_contradicted_by was ALWAYS instance-aware; the
EANode conservatism alone defeated it — so `Flow(1, Store) +
!Flow(1, Wasi)` keeps its severance as a REFINEMENT (zero reports)
while `+ !Flow(1, Store)` still refuses
(tests/frontier/mn-instance-refinement-clause.mn, born RED at 2
reports against the boot, exactly 1 under the fold; the frontier's
instance-refinement leg). REMAINING, positive form: the fn-TYPE
with-row path (`() -> a with Flow(1, Store)`) keeps EANode
conservatism — its fold runs at parse time where resolution would be
order-dependent; it folds when the annotation-row judgment moves to
infer, priced with the W23 compound-constant reach above.

`Hβ.query.unreadable-source-refusal` — RESOLVED 2026-08-09, the verb
refused the empty weave; the missing-source question the mode-7 dig
named (pin 76e85e00696e), and the fix's RED sharpened the decode twice:
the diagnostic was never missing (E_MissingModule fires at the DAG walk;
the naming probe's 2>/dev/null ate it), and the confident answer was
worse than the banked zero — on a nonexistent entry the query attributed
the PRELUDE'S OWN 23 anonymous fns to the missing file at exit 0 (the
substrate layers join the weave regardless of the entry). The fix reads
the fact the walk already produced: query destructures the ranges it had
discarded; `range_of_module(entry) == None` refuses (stderr names it,
exit 1), Some proceeds. Productive-under-error stays for JUDGED files —
the refusal is only for a question whose own file has no weave. The
frontier's unreadable-entry leg holds both halves (refusal fires, good
path answers), RED-proven against the pre-fix pin. The sibling verbs
(at/audit/teach ride their own entries) inherit the law as their reads
converge on the one discovery home.

`Hβ.infer.hof-param-row-never-reaches-enclosing` — RESOLVED (2026-08-06): the
crown's higher-order leak, closed by the completion prune's SIGNATURE KEEP-SET
(the third keep category, `effects.mn row_keep_completion`). The prune's "no
constraint can arrive" reading is false for a free judgment-era row root the
decl's signature reaches — it escapes through instantiate at every call site,
and generalize's signature collection quantifies exactly it — so the
two-category form dropped `run(f) = f()`'s param row edge (root 29 vs ceiling
26 by binary-patch wat probe) and published `run : Pure` while the row var
rode the scheme disconnected. The fix: `signature_free_roots(param_handles ++
[ret_handle])` at each fn-shaped `inf_exit_fn` site (named decl + lambda;
scope exits pass `[]`), computed THROUGH the live cells at exit —
`free_in_ty(chase_deep(TVar(cell)))`, deep-chased — and threaded to the
prune, whose free arm keeps any root the set contains.

MEASURED, one run deciding both banked hypotheses: the keep census showed
`[SIGROOTS run]` containing the exact severed root and `[PRUNE keep-sig]`
firing on it (29/25 unannotated, 69/66 annotated — both judged passes);
crown flipped 4/1 → 5/5 (leak-higher-order rejects, both sound controls
accept); the wheel self-compile census stayed 0 under the honest rows. The
keep adds NO quantification (its roots are already the signature
collection's), so the qvars(f) = Σ refs × qvars(callee) blowup bound the
prune exists for is untouched.

WHY THE 2026-08-05 ATTEMPT WAS INERT — hypothesis (a), the collection: it
never contained the root, because the live root is reachable only THROUGH
the cells the body bound, and the entry unify's union direction does not
track mint age (c04's annotated row var, minted at pre-registration, still
chases to a judgment-era root — the measurement that killed the
classify-by-mint-position hypothesis). Hypothesis (b) — a downstream
re-drop — was eliminated by the same run: set contains the root ∧ the row
publishes. Graduated crucibles: `tests/crown/leak-hof-named-arg.mn` (the
named-argument face) and `leak-hof-annotated.mn` (the annotated face);
`c03_no_neg` stays a research fixture (its refusal class is
`E_EffectUnhandled`, outside the crown gate's `E_EffectMismatch` grep).

CITATION HYGIENE — corrected in place, and the correction matters: this peer
was opened on a small-model SUMMARY of arXiv 2510.20532 whose "§5" claimed the
mechanism is *propagate the parameter's effect variable upward into the
enclosing row*. **The paper says something materially different.** Balik,
Jędras and Polesiuk (*Deciding not to Decide: Sound and Complete Effect
Inference in the Presence of Higher-Rank Polymorphism*, 23 Oct 2025, read
directly, pages 1–9) DELAY the decision: effect *guards* postpone whether a
locally-bound variable appears in a given effect, and constraints leaving a
quantifier's scope are transformed into formulae of propositional logic to be
solved later — hence the title. Their setting is rank-N polymorphism with
*subeffecting constraints* carried in algebraic type schemes (`∀Δ.[Ω] τ`),
which Mentl's schemes do not have; their effects are set-like with a join
monoid, which Mentl's row triple does match. So the paper is a real and close
neighbour, not a drop-in: adopting it means adopting constraint-carrying
schemes, which is a design decision for `Hβ.infer.schemes-are-edges` to weigh,
not a patch. The carry-don't-drop INSTINCT it supports is sound; any specific
rule attributed to it must be read out of the paper first.

### Named-residue index (entry-born peers not yet in a §5.R band — one home each)

`Hβ.infer.declared-row-vacuous-against-a-free-body-row` — **STAMPED
2026-08-18, and the fork it was banked as is ANSWERED.** Morgan's
criterion (SOTA-surpassing, most empowering to Mentl's own parts, most
empowering to developers, exemplary of the ultimate form) resolves it to
branch A — a declared row constrains its params' rows — and A turns out
not to be a design choice at all but the Carried-Truth Law: the graph
ALREADY holds `row(run) ⊇ row(f)`, the declaration constrains
`row(run)`, and solving gives `row(f) ⊆ declared`. The vacuity is a
DISCARDED constraint, not a missing feature, so the fix is less
machinery rather than more. Branch B (the modal capability-at-tee) is
not the alternative — it answers escape and persisted worlds, the TIME
half — and doing A spends none of its budget.
THE MEASUREMENTS, all this turn:
  · `fn run(f) with Pure = f()` + `run(() => op())` → 0 errors, runs 7.
  · The same with `with !E` → 0 errors, runs 7. **The negation leaks
    identically**, which the entry below never recorded — this is
    §0's second property failing at the shape most likely to carry a
    real negation, not merely an over-permissive `Pure`.
  · The same with an unrelated `with !WASI` → 0 errors, runs 7.
  · ANNOTATING THE PARAM — `fn run(f: () -> Int with Pure) with Pure`
    — REFUSES. The constraint machinery works; only the propagation
    from the fn's own declaration is missing. Same shape as the result
    cap two landings ago: the mechanism is reached, and nothing tells
    it to fire.
  · `fn run(f) = f()` (undeclared) → 0 errors, correct. No declaration
    means effect polymorphism, which is the gradient: the annotation is
    the INPUT that unlocks the proof.
THE SITE is infer.mn's declared-row arm (`if row_subsumes(body_row,
declared_row)`), where inference owns the write. NOT `row_subsumes` —
that is a READ by contract ("a read that rebinds row vars would make
every projection a writer"), and rejecting a free tail there is the
TWICE-MEASURED DEAD END: the ~80% row-var slice, 646 false mismatches
on the self-compile. The comment promising that unify closes the var
later is FALSE and was corrected in place this turn.
THE MECHANISM already exists one function over: `diff_row`'s mask edge
— mint a fresh row cell BOUND to a masked triple over the original
tail vars, so the constraint rides every union as one opaque edge
instead of vanishing at the first frame union. The declaration does the
same move with the declared row's absent set, and a later call
unifying an effectful row into the now-capped var refuses AT THE CALL
SITE, which is where the mistake is and where the Reason chain can name
both spans.
THE POPULATION IS MEASURED, 2026-08-18, and it makes this ONE LANDING
rather than an arc: **11 sites across the eight largest modules**
(infer 2, lower 3, effects 1, parser 1, types 1, query 1, prelude 1,
lists 1). Every one is a fn that declares a row and calls one of its own
parameters — the complete set whose judgment changes when the
declaration stops being vacuous. Fewer will actually refuse, since a
callback already within the declared cap stays admitted.
The instrument is the medium's own: `mentl query <file> "census
declared-row-hof"`, the twenty-second census shape, which reads both
facts where the graph holds them — the signed clauses are FnStmt's own
field, the call is the weave's tree edge walked to the callee's VarRef.
A grep could not have answered it (a param MENTIONED is transport; only
a param CALLED puts its row into the body's row), and the shape stays as
the ratchet for whoever builds the fix.
CROWN-TIER LEAK whose mechanism is now WHOLE, and a DEDICATED ARC rather
than loop-sized residue. Seven ticks narrowed it; six framings died on
the way, each killed by running something after being asserted from a
read. This entry is the current truth, rewritten in place — the kills
are counted below rather than stacked above.

▶ THE REPRO needs no negation, no subtraction, no callback gymnastics:
```
effect B { opb() -> Int }
fn run(f) with Pure = f()
fn main() = run(() => opb())
```
ACCEPTED. `Pure` is the empty row, the strongest claim the surface has,
and a body that calls an effectful callback satisfies it.

▶ THE CHAIN, every link measured or read at its definition. The call
edge CHARGES: `infer_call_saturated` runs `inf_add_row_unified(crow)` on
the chased callee, and `main` receives `with B`, so the callback's effect
does reach the caller. `inf_add_row`'s arm is a plain
`union_row(frame.accumulated_row, row)`, so the param's row var IS in the
frame's accumulated row. `row_without_self` strips the frame's OWN
handle, not the param's var; the two print as distinct roots. The
completion prune is exonerated by bypass. So an OPEN row reaches the
gate, and `T_OverDeclared`'s "body only uses Pure" is a DISPLAY artifact
— the third time a display misled this arc.

▶ THE GATE HAS TWO ARMS AND THE REPRO TAKES THE ONE NOBODY WAS READING
(measured 2026-08-17, and it retracts this entry's own previous claim
that `row_subsumes`' open-tail admission is the site). `enforce_row_gate`
matches the chased cell: an `NRowBound` arm that reports the REAL body
row, and an unbound arm that hardcodes `mk_ef_pure()`. The repro takes
the UNBOUND one — `fn run(f) with A = f()` projects `run : r39693@e2`, a
bare free var, while a genuinely chargeless body BINDS (`fn
chargeless(x) with A = x + 1` projects `chargeless : Pure`). Both narrate
"body only uses Pure" through different arms, which is why the display
misled this arc three separate times.
▶ THE DISCRIMINATOR, one variable at a time: `run`'s row var and its
param's row var are DIFFERENT and unconnected (`r39693@e2` vs
`r39695@e2`); add any concrete charge and they fuse (`A + r39713@e8` in
the row, `r39713@e8` on the param); a block body alone changes nothing
(`r39699` vs `r39701`). So the connection mechanism exists and works —
it does not fire when the accumulated row would be ONLY the param's var.
`union_row` is exonerated at its definition (`tail_join(EtClosed, tb) =
tb` preserves the var), so the loss is downstream of the union and above
the gate, and that step is NOT yet measured.
▶ THE OTHER ADMISSION IS REAL TOO, and deliberate: when the cell IS
bound with an open tail, `row_subsumes` admits it, its comment stating
both the reason and a compensation that does not happen — "the free tail
is vacuous at the gate (THE REBIND AT THE GATE CLOSES IT TO THE DECLARED
ROW). Rejecting it was the ~80% row-var slice of the self-compile's
false effect-mismatches — measured at 646."

▶ THE CONTRAST THAT PINS THE BOUNDARY: `fn direct() with OnlyA = opb()`
REFUSES (`E_EffectMismatch: A vs B`), and a concrete local closure
declared `Pure` refuses with `E_PurityViolated`. Same machinery, same
check. A declared row is enforced against a concrete row and is vacuous
against a free one, exactly and only.

▶ WHY THE BATTERY READS GREEN. Every existing HOF crucible —
`leak-higher-order`, `leak-hof-annotated`, `leak-hof-named-arg` — puts
the negation on the CALLER, where the scheme half works: the param's row
var is quantified, the caller instantiates it, the callback's row
arrives. Phase 1 closed `Hβ.infer.hof-param-row-never-reaches-enclosing`
for that shape and its record is accurate about the scheme. The ROW half
at the declaring function is what this peer names.

▶ SEVERITY. This is §0's second property — the negative is provable —
failing at the shape most likely to carry a real negation: a function
taking a callback and promising `!Alloc`, `!IO` or `Pure`. Programs are
not miscompiled, because the caller is charged through the scheme; the
function's own contract is silently discarded, and anything reading it is
misled.

▶ THIS IS A FORK, NOT A BUG, AND IT IS MORGAN'S. Both admission paths
are deliberate and each has a measurement behind it: the bound-open-tail
path costs 646 false mismatches if rejected, and the unbound path's
eager-enforcement policy exists because parking such gates was measured
to leave "a !WASI declaration over a println-performing body parked
forever, the crown silently off." Neither is a slip to patch. Together
they say one thing: A DECLARED ROW CANNOT CONSTRAIN A ROW THE BODY DOES
NOT DETERMINE, and Mentl's surface has no way to write the
effect-polymorphic declaration that would make the constraint sayable.
The two branches, priced:
  BRANCH A — THE DECLARATION CONSTRAINS ITS PARAMS' ROWS. `with Pure` on
  an HOF closes the param's row var at the declaration, so the refusal
  lands at the CALL SITE where the effectful callback is supplied. This
  is what a developer writing `with Pure` means. Price: it carves an
  exception into the settled publish law ("the cell keeps its PROVEN
  row; the declaration publishes NOTHING"), whose three measured
  fabrication modes are recorded at the gate's own unbound arm; blast
  radius is every annotated HOF in src/ and lib/; it must not reawaken
  the 646 class, which is the gate it has to be seen RED against.
  BRANCH B — THE MODAL CAPABILITY-AT-TEE (Phase 6.3, already planned).
  The free tail is legitimate polymorphism, and the modality separates a
  function's OWN effects from effects threaded through its parameters.
  Price: larger, sequenced behind the crown's remaining modal work, and
  it leaves `with Pure` on an HOF meaning something narrower than
  authors expect until the surface grows a way to say "and nothing
  through my params" — so the leak stands until 6.3 lands.
▶ WHAT LANDED MEANWHILE (pin 5446b82bddd4): the unbound arm's FABRICATED
TEACHING is deleted. It taught over-declaration from `mk_ef_pure()`, a
row the graph never proved, and `mentl tighten` authors the patch that
teaching names — so the medium recommended narrowing a declaration to
`Pure` on a body it had never judged. Enforcement is untouched. The true
teaching for a free cell is banked as `Hβ.diag.row-polymorphic-body`.

▶ THE SIX KILLS, compressed: `row-difference-is-omission` (false —
`diff_row` populates the absent set); `annotated-hof-loses-its-param-row`
(true but narrow — the annotation is not required, `Pure` shows it
plainly); `param-call-never-charges-the-declared-row` (false — it
charges); "the declaration is dropped from the published scheme" (false —
publication carries the INFERRED row by design, "the cell keeps its
PROVEN row; the declaration publishes NOTHING"); "the body row is Pure at
the check" (false — a display artifact); the completion prune as the
site (exonerated by bypass).

▶ THE GATES WAIT WITH THE FIX. The three-line repro is red today and
lands as a crucible with the change; `leak-difference-negation` is held
back the same way. `sound-difference-admits` DID land and stays valid —
it pins that subtraction leaves the unsubtracted member admitted,
higher-order included, and never depended on a retracted mechanism.
SYNTAX §«Named effect rows» is not wrong here and must not be edited to
match the artifact: the identity `E - F = E & !F` is the intended
semantics and the lathe has not been turned to it.

`Hβ.lower.record-pattern-param-receiver` — A SILENT WRONG AND A TRAP,
BOTH GATED ON ONE VARIABLE: whether the destructured record arrived as a
FUNCTION PARAMETER. Measured 2026-08-17 at pin a6e900f35888, each half
against its own control.
▶ FACE ONE — THE WRONG FIELD, SILENTLY. `fn pick(u) = { let {zeta} = u
zeta }` called with `{alpha: 7, zeta: 9}` answers 7. No diagnostic, no
trap, the wrong value. The same pattern over a LOCAL receiver (`let r =
{alpha: 7, zeta: 9}` then `let {zeta} = r`) answers 9, and direct field
access through a parameter is fine, so this is the PATTERN's read and not
the record's layout. A second shape agrees: `{name}` over `{age: 30,
name: 12}` answers 30 through a parameter.
▶ FACE TWO — THE REST BINDING TRAPS. `fn widen(u) = { let {name,
...rest} = u  name }` traps `unreachable` inside `widen`, and it traps
even when `rest` is never read, so the trap is the BINDING rather than
the residual's field access. The identical body over a local receiver
answers 12.
▶ THE ROOT IS ONE, AND THE PROBE FOUND IT (2026-08-17, pin
e06c6658fc20). `lower_pat_typed`'s PRecord arm asks
`record_pat_full_fields(ty)` for the receiver's FULL sorted field set.
Resolved, each named field takes its true offset and the rest gets real
residual specs. Unresolved, ONE branch serves both faces:
`lower_pat_record_fields(flds, 0)` computes `(base + i) * 4` from the
PATTERN's own enumeration index, and `lower_rest_unresolved` hands the
rest empty specs. Both measured faces are that single branch — the wrong
slot is the fabricated index, the trap is emit's floor on the empty
specs.
▶ THE RECEIVER IS GENUINELY POLYMORPHIC, so this is not a fact read too
late and no amount of reading harder fixes it. The medium projects the
parameter as `{ zeta: t39682@e0 | r39684@e2 }`: an open row whose
remaining fields the CALLER decides, which may sort before or after the
named one. The offsets are therefore unknowable at lowering, any value
they take is a guess, and `record_pat_full_fields` answers None
correctly.
▶ ONE BRANCH, TWO HONESTIES — the sharpest statement of the defect. The
rest half says "I do not know" and traps. The field half invents an index
and returns a wrong value silently. The design already decided that
unresolved means unknown; only one of its halves acts on that decision,
and the silent half is the one the docs rank worst.
▶ THE WHEEL WAS EXPOSED — NOT BY ACCIDENT, BY AN UNCHECKABLE PROMISE
(the "accident" wording is RETRACTED, 2026-08-17). Both of the wheel's
record-pattern sites destructured ALL their receiver's fields on purpose,
and pipeline's carried a comment saying why: "CLOSED destructure — an
open-receiver field read computes offsets over the partial field set (the
trecordopen-wrong-field class); the full pattern pins the record's real
layout." The class already had the wheel's own name.
▶ THE PRACTICE DOES NOT HOLD, and that is the sharper defect. A COMPLETE
pattern over an open row and a PARTIAL one are structurally IDENTICAL to
the medium — in both, the receiver's judged type is exactly the pattern's
own fields plus an open tail. The repro projects `{ zeta: t39682@e0 |
r39684@e2 }`; pipeline's site projected `{ args: …, body: …, op_name:
String | r367192@e17 }`. Nothing distinguishes safe from unsafe, so the
discipline was a promise the graph could not check, and a caller passing
one extra field sorting before `args` would have read the wrong slot.
▶ THE WHEEL'S OWN EXPOSURE IS CLOSED (pin f0b63b15a5d6): both receivers
are annotated with the record types types.mn already declared, the rows
close (`{ args: List(String), body: Node, op_name: String }` now), and
the offsets resolve from the full sorted set. Emit fell 175 lines. The
CLASS is untouched — any unannotated record parameter still guesses.
▶ It is also why the existing frontier leg "record-pattern rest: the
residual record builds and reads" passes: its receiver resolves, so it
never enters this branch.
▶ THE FIX IS A FORK ALREADY OPEN ELSEWHERE, not a patch. Either record
twinning becomes TYPE-keyed so each call site specializes its receiver's
layout — 5.1's monomorphization is repr-keyed and every record is one
word, so it collapses all record shapes into one twin — or the layout
travels with the value at runtime. That is the same shape as
`Hβ.value.seq-element-stride-carrier`, where a generic body compiles once
with a TVar element and reads at the wrong stride. This is that class at
the RECORD, and the census law asks for the pass covering both instances
rather than a per-site pin. A fix lands with both repros as fixtures,
never before.
▶ SEVERITY: face one is the silent-wrong class the docs rank worst — a
declared surface answering the wrong value with the whole board green.
The wheel never destructures a record parameter by pattern, which is why
nothing here has ever gone red; `tests/syntax/` exists as of this pin so
the fixed forms stay fixed.
▶ THE REPROS ARE HELD BACK, red today, landing with the fix. The GREEN
halves landed as `tests/syntax/record-pattern-local` and
`record-field-access` — the controls that made the finding precise, kept
as the contracts they proved.

`Hβ.infer.as-pattern-defeats-exhaustiveness` — A FALSE REFUSAL ON A FORM
SYNTAX CALLS REAL. Measured 2026-08-17 at pin a6e900f35888.
`match e { whole @ Click(x) => …, Key(k) => … }` over a two-variant ADT
raises `E_PatternInexhaustive: match misses 1 of 2 variants`, though both
arms are present. Deleting the binder — `Click(x) => …` — and changing
nothing else runs clean, so the as-pattern is the isolated variable.
▶ SYNTAX ALREADY STATES THE RULE the checker is missing: "the binder
carries the scrutinee's own type, and the match predicate is the inner
pattern's alone" (§«As-patterns», landed 2026-07-30). Coverage must
therefore read THROUGH `name @ pat` to `pat`; today the exhaustiveness
walk evidently does not, and the arm counts as covering nothing.
▶ THE COST OF THE SHAPE IT BLOCKS is exactly the shape SYNTAX gives as
the motivating example — "need the whole value AND some pieces": event
forwarding, logging, pass-through. Every such match must currently
either drop the binder or add a wildcard, and a wildcard on a
load-bearing ADT is the masking the docs forbid.
▶ REPRO HELD BACK, red today, landing with the fix; its control (the
same match without the binder) is the green half.

`Hβ.lower.record-pattern-unprovable-floor` — REFUTED BY THE MARCH,
2026-08-17, and the refutation is the useful part: IT REMOVES "JUST
REFUSE" FROM THE FORK'S OPTION SET.
▶ THE EXPERIMENT. `LFieldLoad` and the record-pattern lowering face the
same question — the receiver's field offset is not provable — and answer
it differently. `LFieldLoad` floors with `(unreachable) ;; field offset
unprovable`, and its comment states the law: "NO SILENT FALLBACK ... the
named wrong — not a fabricated offset-0 load that reads a foreign field."
The pattern path fabricates `(base + i) * 4` from the pattern's own
index. Making the pattern answer as its sibling does looked unambiguous:
Anchor 2, the wheel's own precedent, and zero blast radius because the
open-receiver ratchet already holds the wheel at 0.
▶ THE MARCH REFUSED IT. Fixed point held (m2 == m3, census 0) and the
micro battery caught `mn-fn-tuple-param`: RUN exit=134 want=44. The
fixture is `fn g({x, y}) = x * y` called with `{x: 5, y: 6}` — a
destructuring PARAMETER, which is an open-row receiver by construction,
and 7 + 30 + 7 = 44 re-derived by hand. The expectation is right and the
program is right; the floor turned working, idiomatic code into a trap.
Reverted whole.
▶ WHAT IT PROVES. A destructuring parameter is THE common case of the
open-row receiver, and SYNTAX endorses it directly (`({name, age}) =>
greet(name)` is one of its own examples). So refusing on "offset
unprovable" is not a conservative interim — it deletes a documented
surface. The offsets must be RESOLVED, which means the receiver's layout
has to reach the pattern: specialization per call site, or a layout the
value carries. The fork is unchanged in shape and sharper in force,
because the third option everyone reaches for first is now measured dead.
▶ WHAT STAYS TRUE: the silent half is still silent. A partial pattern
over an open receiver still reads the wrong field with no diagnostic
(`{zeta}` over `{alpha: 7, zeta: 9}` answers 7). The difference between
that and `fn g({x, y})` is invisible to the medium, which is exactly why
a blanket floor cannot separate them and exactly why the fix must close
the row rather than police the pattern.

`Hβ.query.field-offset-badge` — THE PROJECTION THIS WHOLE ARC WENT
WITHOUT. Six iterations of this class were traced by writing a fixture,
running it, and reading an exit code to infer which slot a field access
resolved to — `mentl where` renders repr width, resume cardinality and
fanout schedule as derived badges, but not the OFFSET a field access
resolved to, nor whether the receiver's full field set was provable. Both
are facts the graph holds at the site (`resolve_field_offset` computes
exactly them), so this is a read, not a new analysis: at a field access,
`u.zeta @ +8 (full set proven)` or `u.zeta @ +0 (known set only — the
receiver's row is open)`. Every probe in this arc collapses to one query
under it, and the wrong-slot class becomes visible at the cursor instead
of via an exit code. It joins the `where` facets, beside the schedule
badge that already walks the enclosing tee chain.

`Hβ.infer.predicate-position-refs-are-not-noted` — A NAME CALLED INSIDE A
REFINEMENT PREDICATE MAKES NO REFERENCE EDGE. Measured 2026-09-04 at pin
46ad0838, the third missing edge the `unreferenced` facet found in one
sitting.
▶ THE MEASUREMENT: `span_valid` (types.mn:1172) reads unreferenced. Its
one reference is four lines below its own declaration —
`type ValidSpan = Span where span_valid(self)` — and it is real: the
refinement is discharged against that fn at every ValidSpan construction
site in the wheel. The predicate is not walked as an ordinary expression,
so the call inside it notes nothing.
▶ THE COMPANY IT KEEPS: `Hβ.types.predicate-is-expr` (band F) is this
gap's root, and it already carries the other half — the comparison-chain
degradation. When PExpr dissolves and predicates become ordinary
expressions, `infer_var_ref` runs inside them and the edge draws itself
with no new code. That is the fix; this entry exists so the facet's
over-report at `span_valid` reads as a known gap rather than a candidate
for deletion.

`Hβ.crown.effect-mismatch-arming-blocked-by-the-surface` — THE LAST CROWN
CLASS CANNOT REFUSE BECAUSE THE ROW IT PROVES IS UNWRITEABLE. Measured
2026-09-04 at pin 5e780c0e, and the finding is not what it looked like.
▶ THE ARMING LICENCE, from the classes already armed: a class arms when
the wheel's census of it is ZERO and the corpus channel carries only
fixtures that EXPECT the refusal. The wheel's census is 0 errors of every
class, so the corpus is the only gate. E_EffectMismatch carried 15 reports
across the micro battery.
▶ TWO OF THE 15 WERE HONESTLY-WRONG SIGNATURES and are fixed here:
mn-ev2 and mn-ev4 both declared `fn outer(x) with G + D` while calling a
`mid` declared `G + D + Memory`. The author widened the callee and not the
caller. Same shape as mn-cli-dispatch at the E_PurityViolated arming;
same one-line fix. 15 → 13.
▶ THE CLAIM THAT THE REMAINING 13 WERE UNFIXABLE IS RETRACTED. This entry
said "no widening can fix it, because a with-clause cannot say
`Probe({record})`", and the next session's measurement refuted it:
widening `fn run() with Probe` to `with Probe + Memory + Alloc` clears the
ERROR outright, leaving only a T_OverDeclared narration. The instance args
never blocked anything, because `eff_admits` (effects.mn:1105) already
answers TRUE for a bare gate name against any instantiated body name — a
bare `Probe` admits `Probe(τ)` by design. Ten more fixtures widened on
that measurement: the whole payload family plus mn-ev2/mn-ev4. 15 → 5.
▶ AND A SECOND WRONG TURN, recorded because the probe is what stopped it.
Reading `effect Probe { emit(x) -> Int }` — declared with NO parameter
list — I concluded inference was manufacturing a type argument, and was
about to treat that as the bug. infer.mn:8558 says otherwise, explicitly:
an effect's type params ARE the free type vars across all its ops'
signatures, so `emit(x)` with a lowercase `x` declares one by the case
rule. Deleting that would re-break the class its own comment names — "the
payload type never flows performer→handler... the root of both the
list-as-Int erasure and the emitter's heap-dump." The declaration is
right; I misread a bare name as a bare effect.
▶ WHAT ACTUALLY REMAINS IS TWO, in one fixture (finished 2026-09-05).
mn-backtrack-full's three were the same widenable shape. The last two are
mn-feedback-iir, and they are a REFUSAL to widen rather than work left
undone: `fn accum(input) -> Int with Sample` infers `Memory + Alloc`, and
the body row contains no Sample at all — the shape that separates it from
every other carrier. It is `Hβ.effects.feedback-row-substitutes`, whose
measurement SYNTAX already carries: the compiled WAT for a `Delay(N)`
recurrence contains ZERO construction of the spec, so the Alloc is
infer_expr walking the RHS as an ordinary constructor call at a site whose
only load-bearing content is read statically. Widening would declare Alloc
for a site that provably allocates nothing. E_EffectMismatch is armable
the day that peer lands, and not before.
▶ THE REAL SURFACE BUG, which survives all of the above and is smaller
than the one this entry first claimed: T_OverDeclared ADVISES an
unwriteable form. `fn run() with Probe` over a polymorphic op narrates
"declares Probe but body only uses Probe(Int) — tighten the signature",
and `with Probe(Int)` does not parse. `mentl tighten` consumes exactly
these narrations, which is why the round-trip guard at pin 1aca4868 was
needed; the guard declines silently while the ADVICE is still wrong. The
fix is that the narration must not propose a row the grammar cannot
express — either by rendering the writeable prefix or by staying silent
when the only difference is inferred instance args. Banked as
`Hβ.diag.over-declared-advises-an-unwriteable-row`.

`Hβ.infer.resume-in-a-called-fn-has-no-arm-types` — E_ResumeOutsideArm
CANNOT ARM, and the follow-up its own fixture cites was named NOWHERE
until now. Measured 2026-09-04 at pin 5e780c0e.
▶ THE MEASUREMENT: `tests/micros/mn-resume-in-called-fn.mn` runs CORRECTLY
— exit 9, the contract it declares — while inference reports
E_ResumeOutsideArm twice. `drive()` is a top-level fn called from a
handler arm; its `resume` resolves through the evidence tier at runtime
and works. The fixture's own comment says "the typed R→S binding is the
named follow-up," and a grep of this file for that follow-up returned
nothing. PLAN §7's law is that a gap not in RESIDUE does not exist, so it
did not.
▶ WHY THE DIAGNOSTIC IS NOT SIMPLY WRONG, which is the part that took the
reading: `resume : R -> S` needs the arm's continuation types, and
`inf_arm_tys()` answers None when `drive` is judged standalone — because
it IS judged standalone. The report is honest about the typing and wrong
about the program. Arming it would refuse a correct fixture.
▶ THE BUILD: judge a fn reached from an arm under that arm's continuation
types, so the resume in a called fn types against the R and S its caller
proves. That is continuation-polymorphism at the fn boundary, not a patch
to the check. Until then the class stays behind the wildcard and the
fixture keeps carrying two honest false reports.

`Hβ.cursor.cached-argmax-keyed-by-epoch-and-caret` — THE CACHED CURSOR IS
UNBUILT, and the sketch that stood in for it was inert. Opened
2026-09-04 at pin cfb97e95 as `.ic-fixpoint-handler-is-never-installed`;
RE-SCOPED at pin ff7e079b when the reading finished and the sketch was
deleted.
▶ WHAT THE FIRST DRAFT ASKED: whether `ic_fixpoint_handler` (3,245 bytes
of prose, zero references) was built-ahead or abandoned, since deleting
might remove the only implementation of §2's cached cursor. The answer is
NEITHER, and it took reading the arm rather than the count.
▶ THE ARM DID NOTHING. Both branches called `cursor_argmax_compute(caret)`
— identically. The `last_epoch` state was written and never affected a
result, so the memoization its prose described ("resumes the terminal
cursor and STOPS re-projecting") did not exist, and neither did the
install its prose claimed ("installed via `~>` above"). Two false claims
in one comment block, which is exactly what the orphan-claims facet was
built to surface. Deleting it removed no capability; leaving it was the
real risk, because anything that installed it believing the prose would
have got zero caching and thought IC was live.
▶ WHY IT WAS NEVER FINISHED, which is the design knowledge worth keeping:
an epoch alone cannot key this read. `cursor_argmax` takes a CARET, and
moving the caret without editing leaves the graph epoch unchanged while
the correct cursor differs — so a stable-epoch cache answers the wrong
position the first time a human moves without typing. The key is (epoch,
caret). The comment at the deletion site carries this so the next attempt
does not re-derive it.
▶ THE BUILD, when it comes: a CursorRead handler carrying (last_epoch,
last_caret, cached_cursor), resuming the cached cursor only when BOTH the
epoch and the caret match, recomputing otherwise. It is a handler swap on
the effect `cursor_default` already serves — the architecture's own shape
(§2: incrementality IS the cached cursor) — so nothing new is needed
beyond the correct key. The gate is a fixture that moves the caret at a
stable epoch and proves the answer changes.
▶ THE FACET'S OWN LIMITS, stated so 216 is not read as 216 bugs: it
reports declarations with zero outside references and 240+ bytes of
attached prose. Type names dominate the count because an annotation makes
no reference edge (`Hβ.types.type-expressions-are-not-graph-content`), and
a library's public vocabulary is unreferenced by the wheel BY DESIGN —
lib/threading contributes 25 rows for exactly that reason. The signal is
in the compiler's own modules, and even there the prose may be describing
something dormant on purpose.

`Hβ.gradient.delta-re-derives-what-the-diagnostic-already-proposed` —
RESOLVED 2026-09-04 at pin d5e6f594: gradient_delta.mn deleted whole (the
Delta effect, delta_default, its four arms and nineteen supporting fns —
407 lines) with its import and three installs. The record below is kept
because the JUDGMENT is the reusable part: an unreached second
implementation is deleted when the shipping one is better, wired when it
is not, and the diagnostic was better. Measured at pin 8c7e4746 via the
performs facet's `Delta 3/4`.
▶ THE CLUSTER, measured end to end. `delta_pick` has ZERO references.
Its three siblings — delta_effect_row, delta_ownership, delta_refinement
— have exactly one reference each, and all three are inside delta_pick's
own arm (gradient_delta.mn:95, 99, 102). So the four ops form a closed
ring nothing outside enters. `delta_default` is nonetheless INSTALLED at
three sites in main.mn, which is BodyContext's shape one for one: a
handler in real chains whose ops nobody performs.
▶ THE COMMENT NAMES A READER THAT DOES NOT EXIST: "The Cursor handler's
CursorView.teach field reads through delta_pick when the inverse-direction
gradient should fire." There is no `teach:` field in cursor.mn.
▶ WHY IT IS A DELETION AND NOT A WIRING JOB, which is the part that took
the reading: the shipping answer already exists and is better.
main.mn:633 states it — "T_OverDeclared already IS a proposal — the
diagnostic" — and `mentl tighten` reads the T_OverDeclared warnings the
judgment banked, authoring 174 of them at pin 1aca4868. Delta walks the
graph per handle to RE-DERIVE the same verdict the judgment already
proved and wrote down. That is the Carried-Truth Law at the exact shape
the law names, and the fix is toward less code.
▶ THE FACET UNDERSTATED IT, worth recording as a limit of the
instrument: `performs` counts references outside the effect DECLARATION's
extent, and delta_pick's arm lives in the handler, a different
declaration — so the three siblings counted as performed and the roster
read 3/4 rather than 0/4. The facet measures direct reference honestly
and says so; reachability is `Hβ.driver.link-is-reachability`'s question.
Reading the roster AND the zero on delta_pick together is what found it,
which is how the two facets are meant to be used.
▶ THE DELETION: the Delta effect, delta_default and its four arms, the
three implementing bodies, and the three install sites in main.mn.

`Hβ.voice.interact-write-half-is-unwired` — THE Interact SURFACE READS
BUT DOES NOT WRITE: 14 of its 22 ops have never been performed, and until
now the gap was not written down anywhere. Measured 2026-09-04 at pin
9347479e by the `unreferenced` facet, which reported 51 names in voice.mn
and made this visible for the first time.
▶ THE ENTRY EXISTS BECAUSE OF A LAW, not a preference. PLAN §7 says every
named positive-form gap has one home and "a gap not in `RESIDUE.md` does
not exist." A grep of this file for `Interact`, `mentl-voice` and
`mentl_voice` returned nothing, so the largest unwired surface in the
wheel was a hidden gap — drift by the project's own definition, sitting
directly on §11 Arc E's critical path.
▶ THE SPLIT, measured op by op. LIVE (8): project_root, open_file,
save_file, file_text, focus, caret (9 references), consult, propose.
UNWIRED (14): tree_list, create_file, rename_path, delete_path, edit,
speak, run_compile, run_check, run_audit, run_query, declare_intent,
retract_intent, history, cancel_pending. The pattern is not random — the
READING half of the surface is wired and the WRITING and SESSION halves
are not. `mentl_voice_default` handles all 22 and is installed at three
sites, so every arm exists and waits; nothing performs them.
▶ WHAT IT MEANS FOR ARC E: `edit(FileHandle, Patch) -> EditOutcome` is
the op the whole felt surface turns on, and it has zero performs. The
Space session can open a file, read its text, set and read the caret,
consult and propose — and cannot apply a change, speak a VoiceLine, run a
check, or record a turn. Arc E's terminal bar ("session alive across
actions, eight-aspect projections at the caret") is reachable on the read
half alone; the write half is what makes the page an editor rather than a
viewer.
▶ NOT A DELETION, and the distinction is the one the previous pin's
harvest turned on: an op nobody performs is dead vocabulary only when
nothing is coming for it. Here a handler implements all 22 arms and the
standing cursor is the surface they serve. The close condition is the
transport performing them, not the roster shrinking.

`Hβ.io.filesystem-impl-bypasses-the-effect` — CALLERS REACH PAST THE
Filesystem OPS TO THEIR IMPLEMENTATIONS, AND THE ROW DOES NOT SAY SO.
Opened 2026-09-04 at pin 46ad0838 as `.fs-close-op-is-bypassed`; renamed
and re-scoped at pin 9347479e when the gate measured the real extent.
▶ THE FIRST DRAFT WAS TOO NARROW. It named `fs_close` alone, off the
`unreferenced` facet's report. The class is every op: measured 24 impl
call sites outside the handler that owns them, across all nine impls.
`fs_close` was merely the one whose op count reached zero, which is why it
surfaced first.
▶ WHY IT IS INVISIBLE: the impls carry `WASI`; the capability the handler
names is `Filesystem`. A bypass keeps the behaviour and drops the effect
from the row, so `with !Filesystem` holds over a route that writes files —
and `wasi_filesystem`'s own comment promises severance on exactly that
row ("drops path_open / fd_close from that binary"). The proof is sound
about the substrate and wrong about the capability.
▶ ELEVEN CLOSED AT 9347479e: march_run's whole file sequence, main's emit
route, mcp's gate — each provably inside a `~> wasi_filesystem` install,
so the ops were always reachable. `fs_create(String) -> Int` was declared
and armed in the same landing; its absence was why writing a file had no
op to perform. 24 → 13, ratcheted in verify-baseline as
`fs_impl_bypass_max`, monotone down.
▶ THE REMAINING 13, each wanting its own install-coverage reading before
it converts: space's file server (main), `battery_libs` (which DECLARES
`with WASI`, so its row is at least honest about the substrate and the
conversion is a signature change), `persist`, and `dsp/cfc`. Driving them
to zero is the entry's close condition.
▶ THE GATE CANNOT BE A FIXTURE, and the probe is recorded so nobody
retries it: `Filesystem` is the compiler's own effect, declared in
types.mn, so a checked user program has no access to the vocabulary —
`fn f() with !Filesystem` calling `fs_create` answers `E_MissingVariable`,
not a refusal. The property lives on the wheel's own link and the verify
tier reads it there, through the medium's `refs of` answer.

`Hβ.types.type-expressions-are-not-graph-content` — A TYPE IN AN
ANNOTATION HAS NO HANDLE AND NO SPAN, so the reference it makes cannot be
noted and the refusal it earns cannot be located. Measured 2026-09-04 at
pin 1ff3393b, found by the `unreferenced` facet over-reporting every type
name in types.mn.
▶ THIS ENTRY CORRECTS ITS OWN FIRST DRAFT, written an hour earlier at the
same pin under the name `.type-name-in-annotation-never-resolves`. That
draft said the medium never resolves an annotation's type name. The
artifact refutes it: `quantify_ctor_ty` (infer.mn:8389) calls
`env_lookup_type(name)` on every capitalized nullary name, resolves a
TAlias-bodied entry to its live alias, and the probe that produced the
draft had already shown it — `type Real = Int` with `fn f(x: Real)`
type-checks against an Int argument, which only happens if the name
resolved. The draft was reasoning from a symptom (`Nonexistent` produces
`E_TypeMismatch` rather than a not-found) to a mechanism, without reading
the site. Retracted per the corpus's verified-only law.
▶ WHAT IS ACTUALLY TRUE, at infer.mn:8389-8397. The lookup happens; the
`None` arm returns `(TName(name, []), qmap)`, and its own comment blesses
the fallback — "a nominal record / ADT / not-yet-declared name stays
TName." So a typo'd annotation becomes an opaque nominal type and surfaces
three mismatch errors pointing at arithmetic instead of one naming the
type that does not exist.
▶ AND THE FALLBACK IS FORCED BY SOMETHING DEEPER, which is why this entry
is named for that instead. `quantify_ctor_ty` is a pure Ty-tree rewrite:
it has no handle for the name it just resolved and no span for the token
it read. Values are graph content — every expression a node with a handle
and a span, which is what makes `graph_ref_note(name, handle)` and a
located diagnostic possible at the value altitude. Type expressions are a
parallel tree of strings and tuples beside the graph. So the resolution
CANNOT note its edge (no handle to note), and the miss CANNOT refuse
(nothing to point at) — the AST-in-graph fabric, whose own claim is that
every node is a resolvable handle, stops at the type annotation.
▶ WHAT IT COSTS TODAY, measured: 80 names in types.mn — `Ty`, `EffRow`,
`NodeKind`, `SchemeKind` and the rest of the compiler's vocabulary — read
as declared-and-never-reached in the `unreferenced` facet, because the
only sites that reference them are annotations. That is the facet naming
this gap, exactly as its comment says an over-report does.
▶ THE FIX IS THE REPRESENTATION: a type expression becomes graph content,
each name a node carrying its span, resolved through the env edge it
already consults. Then the ref note is the same one line the value and
pattern altitudes already have, and `E_UnknownTypeName` is an ordinary
located refusal — the peer `E_MissingVariable` has had since the start.
The risk to measure RED first is the fallback's own stated reason: whether
the `None` arm ever fires for a name that IS declared (a forward reference
across the concatenated weave). If it does, ordering is a second problem
and the refusal waits on it; if it never does, the refusal is free. That
measurement is the gate and it has not been taken.

`Hβ.infer.record-row-vars-are-not-unioned` — RECORD ROW VARS ARE SECOND
CLASS IN THE UNION-FIND, and that is what survives the offset fix below.
Measured 2026-09-02 at pin 7740ac94; standing repro
`tests/repro-wf/open-row-interior-site.mn`.
▶ THE DIRECT CALL IS FIXED AND THE INTERIOR ONE IS NOT. `fn inner(u:
{zeta: Int, ...}) = u.zeta` reached from inside `fn outer(u: {zeta: Int,
...}) = inner(u)` exits 7 where 9 is correct. The emit says it plainly:
two `$outer` bodies (`$outer$spr_alphai_zetai_` among them, its receiver
closed) and exactly ONE `$inner`, whose body loads `i32.load offset=0` —
alpha's slot.
▶ THE ROOT IS IN unify, one level under the twin machinery.
`unify_two_open_records` proves two open rows are the same row and keeps
them as TWO nodes: it cross-absorbs each side's exclusive fields into the
other's residual (`absorb_into_residual(va, extra_b)` / `(vb, extra_a)`)
and marks both RowAssumed, never unioning va and vb. Its own comment says
"two row variables collapse to one when they're already linked", which is
a CHECK on `va == vb`, never a link. Unify unions the roots for type vars
— the codebase's own stated law — and does not for record row vars.
▶ SO THE PAIRS CANNOT ANSWER. The interior site's row-var root is not the
outer twin's pair key, no interior twin is demanded, and the base body
bakes the known set's ordering. Two edits at pin ‹the interior landing›
made `spec_subst_pairs` and `spec_resolve` able to answer for a row var at
all — both marched clean, both necessary, and MEASURED not sufficient
while the roots stay apart. They stay (Anchor: stack correct fixes).
▶ THE FIX IS THE REPRESENTATION, NOT A PATCH (the unpatchability theorem
names unify explicitly): a record row var becomes an ordinary union-find
citizen, so two rows proven equal ARE one node and the assumed residual
this bind manufactures has nothing left to manufacture. That also retires
`open_record_proven_fields`' RowAssumed decline, since an assumed
remainder from two partial sets is exactly what the union removes.

`Hβ.lower.open-row-field-offset-from-known-set` — RESOLVED 2026-09-01 at
pin 7740ac94 for the DIRECT call (the row var keys the twin; gates
`tests/syntax/record-field-param-open`, `-two-shapes`,
`record-field-through-list`). The interior call is the peer above. The
original record follows, because the shape is the instructive part.
Measured 2026-08-17 at pin 4ce9914b7360.
▶ AN OPEN ROW'S FIELD OFFSETS COME FROM THE KNOWN SET'S OWN ORDERING, not
the runtime record's. `fn pick(u: {zeta: Int, ...}) = u.zeta` called with
`{alpha: 7, zeta: 9}` returns 7 — `zeta` is the only known field, so it
takes index 0, which the actual record uses for `alpha`. Silent: no
diagnostic, no trap, and `mentl check` passes. The closed twin
(`{alpha: Int, zeta: Int}`) returns 9 and is the landed control
`tests/syntax/record-field-param-closed`.
▶ IT IS SYNTAX'S OWN EXAMPLE. §«Row polymorphism» offers `fn greet(u:
{name: String, ...}) -> String = "Hello, " ++ u.name` as the feature's
worked form. The same shape measured: `fn width(u: {name: Int, ...}) =
u.name + 1` over `{name: 5, age: 9}` returns 10 — `age`'s value — because
`age` sorts first in the real record while `name` is index 0 of the known
set. A headline documented surface reads the wrong field.
▶ THE MECHANISM IS AN EMPTY RESIDUAL BIND, measured end to end
2026-08-17, and it means the floor that should catch this is BYPASSED
rather than missing. `resolve_field_offset`'s `TRecordOpen(fields, v)` arm
is correct as written: it asks `open_record_full_fields(fields, v)` for
the receiver's full sorted set and returns -1 when the chase cannot
answer, its comment naming this very class ("an offset prefix-summed over
the partial demanded set is the wrong-slot class ... must floor loudly,
never return a partial sum"). The chase SUCCEEDS: `v` resolves to an
empty residual, so `full` is the known set alone and a real offset comes
back.
▶ AND IT IS CALL-SITE INDEPENDENT, which is what makes it the fork's
concrete face. `fn pick(u: {zeta: Int, ...}) = u.zeta` called twice in one
program — `pick({alpha: 1, zeta: 3}) * 10 + pick({zeta: 5})` — answers
15: the first call reads slot 0 and gets `alpha`, the second reads slot 0
and gets `zeta`. One compiled body, one baked offset, correct only for
callers whose record carries exactly the known fields. A third shape
pins the arithmetic: `{beta: Int, zeta: Int, ...}` over `{alpha: 1,
beta: 2, zeta: 3}` answers 2, `zeta` at index 1 of the KNOWN pair.
▶ THE WRITER IS FOUND: `unify_two_open_records` (infer.mn). When two open
records with DISTINCT row vars unify it computes each side's exclusive
fields and binds each var to the other's — `graph_bind_record_row(va,
extra_b)` and `(vb, extra_a)`. With the same known fields on both sides
both extras are EMPTY, so both tails close to `[]`. That is a fabrication:
two open rows unifying learn that their known fields agree and that their
REMAINDERS are the same unknown, never that there is no remainder. The
function's own comment says tails "collapse to one when they're already
linked" and its `va == vb` arm does exactly that; the `va != vb` arm
closes instead of linking. It predicts all three measured numbers — 7, 2
and 15 — including the two-known-field case where the annotation's var
takes `diff(body_fields, annotation_fields) = []`.
▶ THE OBVIOUS REPAIR IS REFUTED BY THE MARCH (2026-08-17, reverted
whole). Minting one shared fresh tail and binding `va` to
`TRecordOpen(extra_b, tail)` and `vb` to `TRecordOpen(extra_a, tail)` is
the textbook row rule, and `open_record_full_fields` ALREADY chases
`NBound(TRecordOpen(more, v2))`, so the reader anticipates the shape. The
verdict was BROKEN: m2 ≠ m3 by 131477 lines and m4 trapped at exit 134
with zero lines — the medium stopped reproducing itself.
▶ THE SORT-CROSSING EXPLANATION IS REFUTED (2026-08-17, second attempt).
That first break was attributed here to `graph_bind` putting a Ty on a
row handle, re-opening the untagged union `graph_bind_record_row`'s
comment warns about. The ROW-SORT-NATIVE form was then built — the tail
as `Option(Int)` inside `NRecordRowBound`, its own occurs guard, the
chase arm in `open_record_full_fields` — and it BROKE IDENTICALLY: 131497
diff lines against the first attempt's 131477, m4 trapping at exit 134
with zero lines both times. Same signature, different representation, so
the cause is the SEMANTIC change (linking the tails) and not how the link
is stored. The banked cause was wrong and is struck.
▶ WHAT THE TWO ATTEMPTS TOGETHER MEASURE: m3 is clean at both (exit 0,
census 0) and m4 traps at both, so the linked form produces a compiler
that mis-compiles the wheel one generation on. That is a self-application
failure, invisible until the m4 leg — which is why the leg is watched
from the first run here.
▶ THE CAUSE IS MEASURED (2026-08-17, emit-diff on the broken run's own
artifacts — m2 13937263 bytes, m3 13937259, m4 ZERO). The floor census
differs in exactly ONE class: `field offset unprovable`, 4 in m2 and 9 in
m3, which is the whole +5 of the unreachable delta (4286 → 4291). Every
other class is identical.
▶ SO THE LINKED FORM WORKS AS DESIGNED, and at this pin that is what
broke the wheel — five unannotated receivers, not the linking, as the
third attempt below later proved by marching the same semantics CLEAN.
The chase reaches a free tail and floors HONESTLY at five more
sites — and those sites are in the WHEEL's own source, so the compiler
m3 emits traps when it compiles the wheel. The old empty-bind was
papering them over with a guessed offset that happened to be right for
the wheel's own shapes, which is precisely why it self-hosted.
▶ THE FIVE ARE NAMED: `ls_current_lambda_handle_loop` (3) and
`ls_outer_fn_name_loop` (2), both in lower.mn, both taking an
unannotated `frames` and reading `frame.fn_name` / `frame.lambda_h`.
m2's four pre-existing floors (`arms_include_op` ×2,
`record_field_handle`, `arm_body_handle`) are unchanged and are not part
of this.
▶ THIS REFUTES THE WALK-DISAGREEMENT DIRECTION banked one iteration ago.
No reader needed to follow the tail; the readers were fine. The third
dead explanation in this arc, and the one that would have sent a fix into
occurs/subst.
▶ THE ANNOTATION WAS BUILT AND THE MARCH REFUSED IT (2026-08-17,
reverted whole) — AND ITS 39-LINE DIVERGENCE NAMES A SEPARATE SILENT
WRONG. Both receivers were annotated with the frame record's whole
eight-field set, measured field by field off `ls_enter_frame`'s declared
signature rather than guessed, and the row closes (the projection shows
no tail). Emit moved by 39 lines TOTAL, and emit-diff pins every one of
them to NESTED-FUNCTION NAMING: m2 emits `digit`, `go`, `search`,
`yield_from` bare, m3 emits `parse_int_digit`, `parse_int_go`,
`index_of_search`,
`op_synth_default_enumerate_inhabitants_yield_from` qualified, and the
three structurally-differing named fns are exactly those four's parents.
▶ SO `ls_outer_fn_name_loop` HAS BEEN RETURNING THE WRONG VALUE ALL
ALONG. Its own comment calls it the named-fn discriminator for nested-fn
naming; reading `frame.fn_name` through an open row gave it a foreign
slot, so nested fns have never been qualified and the qualification path
has been dormant. That is a defect in its own right, independent of the
tail arc, and the annotation is what surfaced it.
▶ THE TRAP'S CAUSE IS NOT MEASURED. m4 died in 0.97s at 128MB — a far
faster death than the linked-tail attempts' ~10s. The obvious suspicion,
that qualified names collide with existing symbols, is DEAD before it
was banked: duplicate-symbol counts are identical between the
generations (514 and 514), so qualification introduced none. What
remains unmeasured is why a module whose only change is four qualified
nested-fn names fails at startup.
▶ THE DANGLING-SYMBOL PROBE RAN AND KILLED ITSELF. Both generations
DEFINE both naming forms; the annotation shifts exactly one fn from bare
to qualified (m2 carries two `digit*` definitions and one
`parse_int_digit*`, m3 the mirror). No dangling symbol, and the earlier
"defs=0" was an artifact of a trailing-space pattern. Fifth explanation
this arc has killed by measuring.
▶ THE TRAP IS NOW PINNED, by running the artifact rather than reading it.
Feeding m3.wasm the wheel source (2645362 bytes in, zero out, exit 134)
reproduces it with a backtrace: `wasm trap: indirect call type mismatch`,
innermost frame `parse_int_go`, reached through `lex_from` → `lex` →
`infer_program_converged`. So the fault is INDIRECT DISPATCH at the
renamed nested fn — not rows, not symbols, not readers.
▶ WHY THAT MATTERS BEYOND THIS ARC: a nested function's NAME is reaching
its indirect-call identity. The emitter's known hazard is exactly this
family ("dup top-level fn names — emitter picks one silently"), and a
rename that changes which definition a `call_indirect` resolves to is
that hazard with a different trigger.
▶ PINNED TO THE INSTRUCTION (2026-08-17, wasm-objdump at the address the
backtrace named). Inside `parse_int_go`:
`01225e: call_indirect 0 <fns> (type 2 <ft2>)` then
`012267: return_call_indirect 3 0` — the TAIL call, through `ft3`, and
that is the one that traps. Its callee is a closure record's fn pointer
(`local 12`, `i32.load offset 0`).
▶ THE TYPE VOCABULARY IS UNCHANGED, which narrows it hard: both
generations carry the same 36-entry type table, `ft2 = (i32,i32)->i32`
and `ft3 = (i32,i32,i32)->i32`. So the mismatch is not a changed
SIGNATURE — it is a changed TARGET. After the rename, the closure's
stored fn index resolves to a function of different arity.
▶ BOTH BRANCHES OF THAT PROBE ARE NOW DEAD (2026-08-17). COLLISION: each
qualified name is defined exactly once, with 4832 total definitions and
514 multi-defined names IDENTICAL in both generations — the rename
introduced none. STALE INDEX / REORDERING: the function table carries
5876 entries in both and exactly FOUR positions differ (54, 57, 58,
3219), each the same function under its old versus new name. Same order,
same types, same table shape (one elem segment, 8736 baked `_idx`
globals both sides). Nothing about identity moved.
▶ SO THE NAMES ARE NOT THE MECHANISM, and that reframes the whole
sub-arc: wasm function names are advisory, so four renames cannot
themselves change execution. What CAN is the other half of emit-diff's
report, which was read past: THREE NAMED FNS DIFFER STRUCTURALLY —
`index_of`, `parse_int`, `op_synth_default_enumerate_inhabitants`, the
three PARENTS of the renamed nested fns. Their bodies changed, not just
their children's labels.
▶ THE MECHANISM IS COMPLETE (2026-08-17, `parse_int`'s body diffed across
generations — 72 lines in m2, 71 in m3). m3 DROPS ONE LINE:
`(local.set $go (local.get $state_tmp))`, the binding of the freshly
allocated closure record to the local named after the nested fn — while
`(local.get $go)` two instructions later SURVIVES. A wasm local defaults
to zero, so the closure passed to the tail call is a null pointer, its
fn index is garbage, and `return_call_indirect (type ft3)` mismatches.
That is the trap, end to end.
▶ THE DEFECT IS A NAME-KEYED RE-DERIVATION, which is the Carried-Truth
Law at the emitter. One nested fn is reached through TWO name
computations: the closure's table index global is emitted qualified
(`$parse_int_go_idx`), and the local binding is emitted bare (`$go`).
When the discriminator starts qualifying, the global follows and the
`local.set` disappears — while the reader of that local does not. The
same fact, derived twice, and the two derivations disagree.
▶ IT IS LATENT AND INDEPENDENT OF ROWS. Any change that makes a nested
fn's name qualify drops its closure binding; the row arc merely happened
to trip it. This is the first mechanism in the sub-arc that actually
explains the trap, after six explanations that did not.
▶ PROVEN BY POSITION (2026-08-17), which is what makes it a mechanism
rather than a story. `$go` is bound TWICE in m2 and ONCE in m3, and the
order is the whole point: m2 sets at body line 19 and first reads at 21;
m3 has NO set before its first read at line 20, its only set landing at
32. The local is zero at that read, and that zero is the closure the tail
call dispatches on — use-before-def, ending in `indirect call type
mismatch`. The full n=0 diff of the body is seven lines: two index-global
renames, one comment rename, and one PURE DELETION with no counterpart.
▶ A NEAR-RETRACTION, recorded because the recovery is the lesson. A
census of `local.set` lines appeared to show the binding present in BOTH
generations, which would have refuted the whole finding — but that census
filtered out any line containing `state_tmp`, and the dropped line is
`(local.set $go (local.get $state_tmp))`. The filter excluded exactly the
evidence. The positional read settled it; a windowed diff and a filtered
count each lied in opposite directions, and only the unfiltered,
unwindowed measurement was true.
▶ THE SITE IS FOUND, AND IT ALREADY CARRIES A FIX FOR THIS EXACT TRAP.
wasm.mn's `LMakeClosure` arm binds a self-recursive closure's own local
to the record BEFORE filling captures, guarded on
`captures_self(captures_exprs, fn_name)`, and its comment names the
symptom verbatim: "a null fn_ptr, the parse_int nested-go
indirect-call-type-mismatch that trapped m3 in the lexer". The guard is
what fails.
▶ THE DEFECT IS TWO NAMESPACES IN ONE FIELD. `LFn` carries a single
`name`, and the emit spends it on two different things: the table-index
global, deliberately qualified through `spec_closure_name(fn_name)`, and
the LOCAL binding, which must match the source-level name the capture
reads. `captures_self` compares a capture's `LLocal(_, nm)` name against
`fn_name` by string (`field_name_eq`), so once lower qualifies, `"go"`
versus `"parse_int_go"` answers false, the early bind is skipped, and the
self-capture reads a zero local. And the guard is not the only casualty:
even firing, `local_wat_name(fn_name, RI32)` would bind `$parse_int_go`
while the reader reads `$go`.
▶ THE STAMP. TRACED: one `name` field on `LFn`, read at two sites with
incompatible requirements (emitted symbol wants qualification, local
binding must not have it); the capture side never qualifies, so the two
diverge exactly when the discriminator starts working. PRICED: the fix is
a representation change — `LFn` carries the binding name and the emitted
symbol as separate facts, or qualification moves to emit where the two
consumers already sit — and it touches every `LFn` construction and
destructure. WRITERS: lower mints `LFn` names (the nested-fn
discriminator path); wasm.mn reads them at the closure emit, the index
global and `captures_self`. NOT COMPLETE: the full `LFn` site set is not
enumerated yet, and that enumeration is the next iteration's first move.
▶ THAT LANDING IS REVERTED (pin 6e05bd9404ed) AND BOTH ITS CLAIMS FAILED.
DIRECTION: the local namespace is source-named end to end —
`ls_bind_local(name, handle)`, `collect_free_vars`, and the emitted
`(local.get $go)` — so binding the LLet to the qualified name points it at
the emitted namespace and leaves the source-named local unbound, the same
use-before-def one layer over. BYTE-IDENTITY: reverting returns the pin to
exactly 6e05bd9404ed, so the forward change's own pin would have been that
sha had it been a no-op, and it was 3967d236b294 — SOME NESTED FN ALREADY
QUALIFIES, `outer` is not empty everywhere, and equal line counts (412781
both sides) are what made the wrong claim look measured. A CLEAN march
says the medium reproduces itself, not that the emit is unchanged; the pin
sha is the identity oracle.
▶ SO NEITHER SINGLE-NAME DIRECTION WORKS: the binding needs the source
name and the symbol needs the qualified one, and `LFn` has one field for
both. The stamp priced a second field — and the interrogation DISSOLVED
it (2026-08-17, pin ec2f629f11e8). A nested fn binds its own name to its
own handle, a self-reference resolves through that bind, and the capture
keeps the handle it resolved to, while lower builds the closure with that
same handle. "Is this capture the closure being built" is therefore ONE
comparison of two handles. `self_capture_name` replaces `captures_self`:
identity finds the capture, and it returns THE NAME THAT CAPTURE READS,
so the early bind targets what the emitted body loads. Both halves closed
with fewer fields, not more. `m2 == m3` proves the new emit reproduces
the old exactly on the wheel's own source, so nothing was being missed
today and the fix is dormant until qualification starts.
▶ THE BLOCKER IS CLEARED (2026-08-17, pin 6cacd339350c, TRANSITION). The
two receivers are annotated, the discriminator's offsets resolve from the
full sorted set, and nested fns qualify for the first time — bare `go`,
`digit`, `search` gone from the emit, `parse_int_go`, `parse_int_digit`,
`index_of_search` in their place. m2 ≠ m3 by 36 lines and m3 == m4: the
new wheel reproduces itself. The same two annotations marched BROKEN
three times with m4 trapping; what changed is the previous pin's identity
read, which makes the self-capture early-bind fire under qualification.
▶ THE CLASS IS UNTOUCHED, measured at that pin: `fn pick(u: {zeta: Int,
...}) = u.zeta` over `{alpha: 7, zeta: 9}` still answers 7. The WHEEL's
own exposure is closed; any unannotated record receiver still takes its
offsets from the known set. The row arc resumes from here, with the
emitter defect that blocked it fixed rather than avoided.
▶ THE ORIGINAL LANDING TEXT, superseded: The
divergence's construction site is one expression in lower.mn: `fn_name =
if outer == "" { name } else { "{outer}_{name}" }`, and then
`LLet(handle, name, LMakeClosure(handle, fn_ir, …))` — the binding taking
the SOURCE name while the LFn inside carried the QUALIFIED one. They take
the same name now. Byte-identical because `fn_name == name` wherever
`outer` is empty, which is everywhere today; the INVARIANT is what moved.
The enumeration the stamp owed also ran: 29 `LFn` sites across lower.mn
and wasm.mn, and `spec_closure_name` is ORTHOGONAL (it mangles
monomorphization twins, not nested-fn names).
▶ THE CAPTURE SIDE REMAINS. A self-capture still references the fn by its
source name, so consistency under qualification is not end to end. That
is the next step, and only after it does the annotation that opened this
arc become marchable.
▶ AN IDENTITY COMPARISON IS THE ULTIMATE FORM — "is this capture the
closure being built" is a handle question the graph can answer, and it is
being answered by comparing two strings drawn from different naming
schemes, which is the string-keyed drift the catalog names. The site has
`LMakeClosure`'s own handle in scope (destructured as `_h`) and each
capture carries one; whether those two are comparable is unmeasured.
▶ AN AMBIENT FIND, banked because the instruction was stale where the
docs stated it: WABT 1.0.39's `wasm-objdump` accepts NO feature flags at
all — no `--enable-tail-call`, no `--enable-threads` — and disassembles
tail-call bearing modules fine without them. CLAUDE.md §8's "EVERY tool
needs --enable-tail-call --enable-threads" holds for the assembler and
validator, not for objdump at this version; the sentence sent this probe
into an error before it read anything.
▶ THE ARC'S SHAPE IS NOW THREE STEPS, not two: the indirect-dispatch
fault is upstream of the discriminator fix, which is upstream of the
writer flip. Nothing about the row tail can land until a nested fn can be
renamed without breaking dispatch.
▶ THE ORIGINAL PATH STANDS but now has two steps, not one: fix the
discriminator's own defect first (it is real, small, and separately
gated), then re-attempt the writer flip. The frame record has
eight fields (capture_handles, capture_order, captures, fn_name,
lambda_h, local_handles, local_order, locals) and is constructed at three
sites, so the honest close is ONE named type both params share rather
than a hand-copied annotation twice — the structural record already
exists, it simply has no name.
▶ THE VOCABULARY LANDED 2026-08-17, pin 6e05bd9404ed, CLEAN and
behaviour-identical: `NRecordRowBound` carries `Option(Int)` as its tail —
`None` terminates, `Some(v)` continues at another row var — and
`open_record_full_fields` gained the chase arm, so a linked chain reaching
a still-free tail floors. Every writer passes `None` today; the repro
still answers 7. The ARITY change was the point: it is a compile error at
every one of the twenty-one sites across eight files, including any behind
a catch-all, so the enumeration belongs to the compiler rather than to a
grep — the precise failure mode of the sort-crossing attempt.
▶ THE WRITER FLIP RAN A THIRD TIME (2026-08-18, blocker cleared) AND THE
SEMANTICS ARE EXONERATED. `unify_two_open_records`'s `va != vb` arm mints
one shared tail and writes `Some` on both sides; the march came back
**CLEAN, m2 == m3**, at 2280480 KB peak against a 2310000 ceiling. The two
earlier attempts measured 131477 and 131497 diff lines with m4 trapping,
and this entry read that as the linked form breaking the wheel. It was
the discriminator defect the whole time. The same semantic change, after
`Hβ.lower.record-pattern-param-receiver`'s two annotations and the
self-capture identity read, reproduces the medium exactly. That prediction
— "a TRANSITION by construction" — was wrong in the good direction.
▶ AND THE REPIN WAS STILL REFUSED, by the micro battery alone: 138 pass /
1 fail, `mn-findtag` trapping at exit 134. The emitted wat carries one
marked floor, `(unreachable)  ;; field offset unprovable`, reached from
`main`. So the flip is not a self-hosting question at all; it is a
question about one micro's receiver.
▶ THE WRITER IS CONFIRMED BY PROBE, not by prediction. Two eprints — one
per writer, printing both row handles and the four field counts — were
built into a probe m2 and run on the repro. On `fn pick(u: {zeta: Int,
...}) = u.zeta` over `{alpha: 7, zeta: 9}`, per compile pass:
`open-open va=7320 vb=12989 nfa=1 nfb=1 xa=0 xb=0` fires FIRST, then
`open-closed v=12995 nclosed=2 nopen=1 nres=1`. The body's row and the
annotation's row meet each other knowing one field apiece with NO extras,
so both close to `[]`; the call site's closed record then narrows a THIRD
var that the body never reads. That is this entry's per-call-site
paragraph and its writer paragraph, both measured rather than inferred.
▶ AND THE FLIP DOES EXACTLY WHAT IT WAS BUILT FOR, at the intended site:
under it the zeta repro stops answering 7 and TRAPS at the floor. A body
that genuinely cannot know its layout refuses instead of guessing.
▶ SO THE OPEN QUESTION NARROWED TO ONE MICRO. `mn-findtag` shows the same
`xa=0 xb=0` open-open event (va=13022 vb=13030) and answers 7 CORRECTLY
today, while zeta answers 7 WRONGLY. Both close an empty residual; only
one is wrong. Why findtag's receiver resolves correctly through the same
fabrication is the next probe, and it is now a single sharp question
rather than the specialize-versus-runtime-layout fork.
▶ THAT PROBE RAN (2026-08-18) AND ANSWERED, and its first job was killing
a claim this entry had just made without measuring it: that the
second-field micro takes the same `xa=0 xb=0` bind findtag takes. It does
not. On the SHIPPING rule the counting eprint reads `xa=0 xb=0` for
findtag and `xa=1 xb=1` for the second-field micro — same writer, same
two row handles, different inputs. One side knows `{handle}` and the
other `{region_id}`, and each carries the other's field across, so the
full set really is `{handle, region_id}` and `region_id` really is at
offset 4. The control passes for a reason; findtag passes because
`handle` sorts first in both the partial set and the true one.
▶ AND THE FLOOR NAMED THE RECEIVER, which is what the previous landing
built it for. With the open-open bind recording NOTHING (one edit — the
read-side effect of a linked tail when the extra is empty), both micros
trap in `main` at a single floor: `field 'handle' on { handle: Int |
r25043@e1 }` and `field 'region_id' on { handle: Int | r25043@e1 }`. The
enclosing fn is `main` in both, read off the emit rather than assumed.
Note the KNOWN set in the second: `{ handle }`, not `{ region_id }` — so
`main`'s receiver learns `handle` through `pick`'s scheme and everything
else from that one bind.
▶ SO THE BIND IS A CARRIER, NOT ONLY A LIE, and that is the reframe this
arc was missing. `unify_two_open_records` records the union of what the
two sides know; deleting it or free-tailing it discards a fact the graph
had proved, which is why the flip broke a correct program rather than
merely refusing an incorrect one. The defect is the SECOND half of the
same write — asserting that nothing further exists — and the two halves
have to be separated rather than removed together.
▶ WHAT IS STILL MISSING IN findtag, stated as the gap and not a fix:
`unify_record_open_against_closed` binds the call site's residual to a
var (measured `v=13013 nres=1`) that `main`'s receiver does not read. The
narrowing exists and does not reach the instantiated use. That is this
entry's own per-call-site paragraph, now measured as operative for
findtag and not only for zeta, and it is where the next step goes.

`Hβ.infer.field-access-overwrites-a-proven-residual` — RESOLVED
2026-08-18, pin bc516cf945bb, CLEAN. `absorb_into_residual` makes the
incoming fields a CHECK against a bound residual rather than a write over
it: shared fields unify (the proof constrains the demand's fresh
variable), new fields widen, and the unbound case is unchanged. All three
measured faces closed — the leak refuses, `rest.run + 1` is a type error,
and the residual survives an access without downgrading to `assumed`.
Crown grew leak-rest-latent and sound-rest-transport; the type half runs
at tests/syntax/record-rest-field. THE ENUMERATION THE STAMP OWED ran
first and narrowed the target: an annotated open row's KNOWN field was
never affected (those go through `unify_record_fields_loop_shared`), an
unannotated record param defers to the call site and belongs to the
free-body-row fork, and only a field living in a bound residual was
destroyed. The record below is the measurement that found it.

`Hβ.infer.demand-widens-a-closed-residual` — RESOLVED 2026-08-18, pin
c968f690567b, CLEAN. The widening arm reads the tail: `RowAssumed` and
`RowContinues` still widen, `RowClosed` refuses with the `type_mismatch`
the closed-record path always gave. The march settled the stamp's open
line — nothing in the wheel or lib leaned on the widening, census 0 and
the battery green. Gate: `tests/micros/mn-refuse-closed-residual-field`, a
refuse contract falsified in a scratch directory so the battery was never
polluted. The tail landed two pins earlier as a projection; this is its
first enforcement. The measurement that found it follows.

▶ A FIELD THE RECORD PROVABLY LACKS READ ITS NEIGHBOUR'S SLOT. Measured
2026-08-18 at pin bc516cf945bb, three runs.
▶ `let {a, ...rest} = ({a: 1, b: 2})` gives `rest` a residual of exactly
`{b: Int}` under `RowClosed` — the tail proves nothing else exists. Then
`rest.nosuch` checks CLEAN and runs to exit 0, with no diagnostic and no
emit floor.
▶ AND IT IS AN ALIASED READ, not a zero. Name the missing field so it
sorts BEFORE the real one — `rest.aa` — and the program answers **2**,
which is `b`'s value: the widened layout puts `aa` at offset 0 and the
real residual keeps `b` there. A field that does not exist returns a
field that does.
▶ THE CONTROL REFUSES, so the residual path is the variable. The same
unknown name on a plain closed record is
`E_TypeMismatch: { aa: t35097@e6 } vs { a: Int, b: Int }` at the access.
The closed-record path already produces exactly the verdict the residual
path owes.
▶ ORACLE-BLIND: the wheel never writes a field name its own records lack,
so census, fixpoint and micros are all silent on this.

STAMP — `Hβ.infer.demand-widens-a-closed-residual`.
TRACED: `absorb_into_residual`'s `added` branch widens unconditionally.
Widening is CORRECT under `RowAssumed` (a union of partial sets — more may
exist) and under `RowContinues` (the chain has not ended), and WRONG under
`RowClosed`, where the writer proved the residual is the whole remainder,
so a name outside it is provably absent. The distinction is exactly what
the tail landed at pin b8eff49b7252 records, and this is its first
enforcement rather than its first projection.
PRICED: one match on a value already in hand — the tail comes back from
the `graph_chase` `absorb_into_residual` already performs, so there is no
new read, no new walk, and freshness is the same read's. The refusal
routes through `type_mismatch`, the channel the closed-record path uses.
WRITERS: `absorb_into_residual` (infer.mn), the single site. READERS:
unchanged; a refusal at the access never reaches lower.
NOT COMPLETE: whether any wheel or lib site relies on the widening is
UNMEASURED until the march runs, and the march is what settles it — a
new refusal class earns its keep by surviving the self-compile. The
diagnostic's teaching FORM is also unsettled: mirroring the closed-record
message names the two record shapes, which reads well for a small record
and may not for a wide one; band L's `Hβ.diag.catalog-as-projection` is
where that becomes a projection rather than a string.

▶ THE MEASUREMENT THAT FOUND IT, kept because the arc is the value.
Measured 2026-08-18 at pin b8eff49b7252, every step run rather than
read.
▶ THE LEAK. A closure performing `E`, stored in a record field, reached
through a record-REST binding and CALLED under `with !E`, checks CLEAN —
and `T_OverDeclared` volunteers that the body "only uses Memory + Alloc",
which is a false absence proof at the shape §0 rests on. Repro:

    effect E { op() -> Int }
    fn make() = ({keep: 1, run: () => op()})
    fn bad() with !E = {
      let {keep, ...rest} = make()
      rest.run()
    }
    fn main() = bad()

▶ CONTROLLED THREE WAYS on the same pin. Direct field access
(`r.run()`) REFUSES with E_EffectMismatch; a record pattern binding the
field by name (`let {keep, run} = …; run()`) REFUSES; only the rest
binding leaks. The variable is the `...rest`, not the record and not the
pattern.
▶ AND THE TYPE GOES WITH THE ROW. `rest.run + 1` checks clean, where the
same misuse on a direct field is `E_TypeMismatch: () -> Int with E vs
Int`. So the field reached through a rest has NO type at all, and the
missing row is one consequence of the missing type rather than a separate
effect-system gap.
▶ THE PATTERN IS INNOCENT, measured by projection.
`fn peel() = { let {keep, ...rest} = make(); rest }` projects
`() -> {  | { run: () -> Int with E } }` — the residual is bound, its
field is typed, and the row is on it. `infer_pat`'s PRecord arm does
exactly what its comment claims.
▶ THE ACCESS IS THE WRITER, and the mark landed one pin earlier is what
shows it. Insert one read before returning the same binding —
`let x = rest.run` — and `peel` projects
`() -> {  | { run: t35152@e11 } assumed }`. A proven residual carrying a
typed, effectful field became a fresh free variable under an ASSUMED
tail. The access overwrote a proof with a guess, and the guess is
labelled as one only because the tail now records which writer wrote it.
▶ WHY IT IS ANCHOR 1 AND NOT AN EFFECT BUG: the graph proved
`run : () -> Int with E`; a consumer re-derived it as a fresh variable
instead of reading it live. The `!E` leak, the silent type hole, and the
`assumed` downgrade are three faces of that one discard.

STAMP — `Hβ.infer.field-access-overwrites-a-proven-residual`.
TRACED: `infer_field_access_record` mints a fresh `field_h` and a fresh
row var, builds `{field: TVar(field_h) | fresh_row}` as the EXPECTED
receiver, and unifies the actual receiver against it. When the actual's
row var is already bound to a residual, `unify_two_open_records` computes
`extra_b` from the expected side — whose field type is the fresh
variable — and writes it over the bound residual. The expected side is a
DEMAND ("this record has at least this field"), and a demand must be
CHECKED against what is known, never installed over it. What the fix must
preserve is the case the demand is genuinely new: a field the residual
does not carry is still a legitimate widening, which is why the arm
cannot simply refuse to write.
PRICED: one arm of `unify_two_open_records`, on the path already taken;
the added work is a lookup of each incoming field in the existing
residual and a unify where both sides have it, which is bounded by the
residual's own length and touches no new structure. Freshness is not at
issue — the residual is read through `graph_chase` at the moment of the
bind, the same read the writer already performs.
WRITERS: `unify_two_open_records` (infer.mn), the single site.
`infer_field_access_record` is the caller that exposes it and needs no
change; the record-rest pattern arm is measured innocent.
READERS: every consumer of the residual — `open_record_full_fields` in
lower.mn, the show projection in types.mn, and the row's own algebra.
NOT COMPLETE: whether the same overwrite reaches shapes other than the
rest binding is UNMEASURED. Direct field access and by-name record
patterns are measured sound, but they are two shapes, not an enumeration,
and the general case is any receiver whose row var is already bound when
an access demands a field. That enumeration is the first move of the
build, not a claim made here. This peer sits UNDER
`Hβ.lower.open-row-field-offset-from-known-set` and is independent of its
fork: restoring a proven type is right under either branch.

STAMP PAID (2026-08-18, pin b8eff49b7252, CLEAN) — the tail is
`RecordRowTail = RowClosed | RowContinues(Int) | RowAssumed`, the two
writers mark what they knew, and `mentl query` now reads
`{ zeta: Int | {  } assumed }` where it used to read `{ zeta: Int | {  } }`
identically to a proven one. The reader is deliberately unchanged —
RowAssumed answers as RowClosed — because refusing there is measured to
trap mn-findtag, so the arm exists to make the fork's answer a choice
rather than a default. Gate: tests/rows/ plus a verify leg carrying both
halves (the assumed fixture marked, the proven control not), falsified
three ways. The stamp's own NOT COMPLETE line is what remains, unchanged.

STAMP — `Hβ.infer.record-row-residual-is-learned-or-assumed`.
TRACED: `NRecordRowBound(fields, tail)` carries two different writes under
one shape. The open-CLOSED writer PROVES its remainder (the other side is
closed, so the residual is exactly what remains) and the open-OPEN writer
ASSUMES one (it knows only the union of two partial sets).
`open_record_full_fields` reads both as "the full set is fields ++
residual" because the node carries no mark separating them, so a
prefix-summed offset comes back where a refusal belongs. The `Option(Int)`
tail landed at pin 6e05bd9404ed is the vocabulary for CONTINUES; what has
no vocabulary is PROVEN versus ASSUMED, and the three readings the floor
now prints — a free tail, `{ }`, and real fields — are exactly the three
the reader must tell apart.
PRICED: the tail becomes a three-arm ADT (`RowClosed | RowContinues(Int) |
RowAssumed`) rather than an `Option`, which is an arity-equivalent change
at the same twenty-one sites across eight files the previous tail change
enumerated — the compiler performs the enumeration, including behind any
catch-all, which is the precise failure mode the sort-crossing attempt
paid for. Every read stays O(1) on the existing chase: no new walk, no new
pass, no second ledger. Freshness is answered by construction, since the
mark is written in the same instant as the fields by the writer that knows
which it is.
WRITERS: two, both in infer.mn — `unify_record_open_against_closed`
(proven) and `unify_two_open_records` (assumed). READERS:
`open_record_full_fields` in lower.mn is the one that must diverge; the
remaining `NRecordRowBound` matches destructure without consulting the
tail.
NOT COMPLETE: what an ASSUMED residual should DO at the read is the open
half, and this stamp does not pretend to have it — refusing turns findtag
into a trap, which is measured, so the answer is not "floor on assumed".
The two candidates are narrowing the assumed row at the call site so the
question never arises, and specializing the receiver's layout per call
site. Both are the standing fork, and the fork is Morgan's.
▶ A GREEN GATE LANDED FOR THE ADJACENT SHAPE, because the class needs
oracles on both sides of the line. `tests/micros/mn-open-row-second-field`
runs findtag's exact flow but reads `region_id`, the SECOND-sorting field,
where a layout over a partial set would land on `handle`. The pinned boot
answers 2 — correct — so the unification-minted-open channel is sound for
this shape and any future fix that breaks it is caught before the march
instead of by it. Falsified two ways before trusting: it fails against the
flip build (the same trap) and fails against a deliberately wrong
expectation.
▶ THE BANKED PROBE RAN AND ANSWERED (2026-08-18), through the medium's
own projection rather than an eprint. `mentl query "type pick"` on the
two repros: findtag reads
`-> Option({ handle: Int | { region_id: Int } })` — the residual is
LEARNED and non-empty, so the layout is proven and both `t.handle` and
`t.region_id` are right for the reason they look right. zeta reads
`(u: { zeta: Int | { } } ref) -> Int` — the residual is EMPTY, so `zeta`
takes index 0 and the caller's `alpha` sits there. The class is one
rendered character wide: `| { region_id: Int }` versus `| { }`.
▶ SO THE MEDIUM ALREADY SAYS IT, at the query. What it did NOT say was
at the floor, and that is what landed instead of the flip (pin
88050b76596d): `field_offset_unprovable_why` puts the selector and the
receiver's live type on the marker, so the third shape is legible too —
a still-free tail renders `{ slot: Int | r24989@e5 }`, which is a
remainder UNKNOWN rather than one assumed. Unknown, assumed-empty and
proven are now three distinguishable readings at the site where the
offset was needed, and this arc re-derived that fact by hand four times
before the emit was asked to speak it.
▶ WHAT THIS COSTS THE PREMISE. The flip's justification was that the
empty bind is a fabrication driving the wrong-slot class. That is TRUE at
zeta and NOT SUFFICIENT as a landing: the same honest floor also refuses a
program the medium answers correctly today, and refusing correct programs
is not the fix, it is the measured dead end of "just refuse" one layer
deeper. The flip stays reverted; what it bought is the exoneration above
and the narrowed question.
▶ THE PER-CALL-SITE BIND EXISTS AND DOES NOT REACH THE BODY.
`unify_record_open_against_closed` computes `record_fields_diff(closed,
open)` and binds the open var to it, which for the first call above is
`[alpha]` — the right residual. The body's own var is not that one. WHICH
WRITER LEAVES THE BODY'S VAR BOUND TO EMPTY is the named next probe, and
it is the last unmeasured link: a genuinely FREE var would hit
`open_record_full_fields`' `_ => None` and floor, so the empty bind is
what converts a loud refusal into a silent wrong.
▶ THIS IS THE ROOT the other three consumers inherit. The record PATTERN
takes offsets from the pattern's own index; `==` walks the known field
list; field ACCESS takes the known set's index — one rule, three
consumers, all of them computing a position in a set that is not the
record's. `LFieldLoad`'s loud floor is the fourth behaviour and fires only
where the offset resolution returns -1, which is why the inferred-open
case traps while the ANNOTATED-open case silently misreads. That split is
measured, not explained: the annotation supplies known fields where
inference left none, and which of the two paths a site takes has not been
traced to its branch.
▶ WHY IT CANNOT BE FLOORED, already paid for: the march refuted the
blanket floor one iteration earlier (`fn g({x, y})` became a trap). The
offsets must be RESOLVED — the receiver's real layout has to reach the
consumer — which is the standing fork.
▶ SEVERITY. Row polymorphism is not a corner: it is a §4-level feature
with its own SYNTAX section, and every use of it that names a field not
sorted first reads a foreign slot. The wheel is unexposed only because
its own record receivers are now annotated closed.

`Hβ.fold.open-record-shares-closed-signature` — SEPARATED 2026-08-17, and
the NAME IS NOW WRONG: the signature collision is NOT the mechanism. The
banked separating probe — one program holding both a closed and an open
record with the same known fields — answers `closed correct, open wrong`
side by side (exit 1 on the combined encoding, where a shared helper
would have forced one answer for both). So two distinct comparisons are
in play and `fold_sig`'s TRecord/TRecordOpen collapse is not what fires
here; the eq leaf simply walks the KNOWN field list. That makes this
entry a face of `Hβ.lower.open-row-field-offset-from-known-set` above
rather than a peer of its own, and the original confirmation stands as
measured.
▶ CONFIRMED 2026-08-17 by the re-aimed probe, a SILENT WRONG on a
documented surface.
▶ THE MEASUREMENT, one variable. `fn same(a: {x: Int, ...}, b: {x: Int,
...}) = a == b` called with `{x: 1, y: 2}` and `{x: 1, y: 3}` answers
TRUE — the records differ in `y` and the comparison never looks at it,
because the walk enumerates the fields the TYPE knows. Replace the two
`...` with `y: Int` and nothing else, and the same call answers FALSE.
`mentl check` passes the open form at exit 0. No diagnostic, no trap, the
wrong answer.
▶ WHY IT MATTERS BEYOND ITS OWN SITE: this is the THIRD consumer of one
class, and the three answer differently. `LFieldLoad` floors loudly with
`;; field offset unprovable`; the record PATTERN fabricates offsets from
its own index and reads a foreign slot; `==` under-compares and reports
equal. One question — the medium does not know this value's layout —
three behaviours, only one of them honest. That spread is the argument
for a single pass over layout-unknown values rather than per-consumer
repair, and it is the census law's constructive half.
▶ IT ALSO BREAKS EQ'S OWN CONTRACT. Two distinguishable records comparing
equal is the eq/hash divergence footgun §5.U says the total structural
derivation exists to make unsayable. "Equal on the visible interface" may
be a defensible row-polymorphic semantics, but it is not what SYNTAX's
equality table states ("field-wise recursion over the sorted field set")
and not what a developer reads `==` to mean.
▶ THE SIGNATURE HALF IS STILL UNSEPARATED. `fold_sig` mapping `TRecord`
and `TRecordOpen` to one string would produce this, and so would an eq
leaf that simply walks the known field list; the probe cannot tell them
apart, and the fix's shape may differ between them. The separating probe
is a program holding BOTH a closed and an open record with the same known
fields, checking whether they share one generated helper.
▶ GREEN HALF LANDED as `tests/syntax/record-eq-closed`, contract 7 so a
wrong answer exits 1 and a right one exits 7. The open twin is held back
with the fix, per the convention that a fixture never banks a wrong value
as an expectation.
▶ ORIGINAL RE-AIMING, kept: the first probe fired a different floor than
predicted. The banked
probe (a pair of records differing only in a field the pattern never
names, compared through the generated helper) TRAPS before reaching any
comparison: the fixture's `a.x` on an open-row parameter floors at
`field offset unprovable`, so the field LOAD answers before the eq leaf
does. The shared-signature question is therefore still open and still
unmeasured — its probe needs a receiver whose row is CLOSED at the field
access but open at the comparison, or a comparison reached without any
field access at all. What the probe DID establish is banked above and in
the LEDGER: the trap is reachable from source that `mentl check` passes
at exit 0, which is a marked emit floor in reachable code not refusing
the executable.
Original entry, unchanged (2026-08-17, read while tracing the record
type's representation). `fold_sig` in types.mn maps `TRecord(fs)` and
`TRecordOpen(fs, _)` to the same signature string, so an open record and
a closed one with the same KNOWN fields share their generated eq / hash /
show helpers. Whether that is wrong turns on what the shared helper does
with the fields an open record carries beyond the known set — a
structural `==` that compares only the known ones would be the
silent-wrong shape, and a runtime record that genuinely has no extra
fields would make it harmless. NOT MEASURED, so it is a question and not
a claim. The probe is a pair of records differing only in a field the
pattern never names, compared through the generated helper. This is the
`fold_sig` distinguishability question §11 5.4 already settles for the
byte leaf ("a NEW NOMINAL Ty fold_strip does NOT strip, OR fold_sig must
READ repr"), met at the record.

`Hβ.query.record-pattern-open-receiver` — ✅ RESOLVED 2026-08-17, pin
4ce9914b7360, as `CsRecordPatternOpen` with the ratchet
`record_pattern_open_max: 0`. Its build is worth keeping for the KILL:
the first draft filtered only let bindings, marched, and answered 0 for
the wheel — which read as confirmation that the previous pin's
annotations had worked. Falsification refused that reading, because
removing an annotation left the count at 0: both wheel sites are MATCH
arms, so the shape was blind to exactly what it was built to count. The
comment justifying the omission was wrong too — `MatchExpr` carries the
scrutinee node. Corrected, the shape measures 0 annotated and 1 located
at `backends/wasm:1100` un-annotated. The remaining text below is the
design as banked.

`Hβ.query.record-pattern-open-receiver` (design, as banked) — THE JUDGED
HALF OF `CsRecordPattern`. The shape counts every record-pattern site
syntactically (landed 2026-08-17, pin e06c6658fc20, and it found the
wheel's own two); what prices the fix is which of them face an OPEN ROW
receiver, since those are exactly the sites whose offsets are guessed.
The read is the receiver's judged type at the pattern — the same channel
`CsEffectfulLambda` already uses when it reads a lambda's judged row, so
this is a refinement of an existing shape rather than a new mechanism.
Today the open-row half is answered one site at a time by projecting the
node (`mentl <file>:<line>` renders the receiver's row), which is how the
pipeline:424 accident was found; the shape should answer it for the whole
link at once, and its count is the honest denominator for
`Hβ.lower.record-pattern-param-receiver`.

`Hβ.query.default-param-census` — ✅ RESOLVED 2026-08-17, pin
a6e900f35888. `CsDefaultParam` is the census's first DECLARED-SURFACE
shape: where every shape before it asks what the source DOES, this asks
whether a form SYNTAX declares is written here at all — the question
every oracle-blind probe opens with, which a day earlier took two greps
behind two `# mentl-skip` confessions. It reads `TParam`'s own default
slot (`Option(Node)`, filled by the parser at the declaration), so the
count is a chase to a fact the graph proves; the medium now answers
`0 default-valued parameter(s)` about its own weave, confirming the
grep's verdict by a different channel. Seen RED first — the frontier leg
failed against the standing boot before the shape existed.
▶ THE SIBLINGS REMAIN, each its own arm reading its own carrier:
labeled arguments (the call's product fields), as-patterns (the pattern
binder), record rest (the residual slot), named row aliases (the row
decl). They are real leaves of one walk rather than one parameterized
surface shape, the same distinction the fold's four leaf generators
record. Each lands the way this one did: one variant, one label, one
name in the grammar, one fixture line, one frontier spec.

`Hβ.emit.invariant-failure-refuses-instead-of-trapping` — REFUTED
2026-08-18, one iteration after it was banked, by reading the marker's own
instruction context instead of its text.
▶ THE 1016 ARE NOT IMPOSSIBILITIES. Every one sits in the `(else` arm of
an `(if (result i32)` guarded on `world_find`:

    (call $world_find <hkey>)
    (if (result i32)
      (then  … call the op …)
      (else  (unreachable) ;; singleton op call with no live install …))

That is a runtime BELT under a live world lookup — the install chain read
live, exactly as Carried-Truth demands, with a loud precise refusal when
nothing is there. The count at the current pin is 1016 in a 13953554-byte
m2.wat (the 1014 banked before came from the reverted build's artifact
and is struck), across 497 enclosing fns and 30 handlers, the top being
the wheel's own bracket: graph_handler 501, env_handler 164,
lookup_ty_graph 88. Those are the handlers `infer_context` installs, so
the sites run under a live install every time — the guard is simply not
statically discharged that far up the call chain.
▶ AND THE REPRO'S TRAP IS THE SAME BELT FIRING CORRECTLY. Its marker has
the identical guarded shape. The init genuinely runs before its handler's
`world_push`, `world_find` genuinely returns 0, and the medium genuinely
says so, naming the op, the handler, the extent and the fix. Nothing is
wrong at runtime.
▶ SO THE ENTRY'S OWN HEADLINE WAS WRONG ON BOTH HALVES — not a
compile-time impossibility, and not a trap where a diagnostic belongs.
The previous iteration read the marker's TEXT, counted it, and inferred a
policy; one read of the surrounding instructions dissolved it. Recorded
rather than quietly edited, because the tell is worth keeping: a
marker's message describes the branch it sits in, never the branch's
guard.
▶ WHAT SURVIVES, narrower and still real: for the self-init shape the
zero is STATICALLY PROVABLE. The perform lowers inside `LHandleWith`'s
own `inits` field, before that install's `world_push`, so
`world_find` at that site cannot answer. Refusing there is possible where
refusing at the 1016 general sites is not, and that distinction is the
whole remaining peer — see below.

`Hβ.tighten.authors-an-unresolved-handle-as-source` — RESOLVED 2026-08-18,
pin 567a96659693, CLEAN. `effrow_writable` and its two companions answer
"can this row be written as source", and `tighten_fold` consults it before
authoring: a row that is TRUE but carries an argument with no source
spelling is declined with its own reason. Measured verb to verb — before,
`Iterate(t42546@e1, t42548@e1)` went into lib/prelude.mn and the wheel
refused itself; after, both sites are declined by name and prelude is
untouched. The enumeration moved the target twice: `show_effrow` is the
SHARED renderer (diagnostics, `where`, audit) so the fix could not live
there, and `EANode` was innocent — it learned display totality in August
and the debug handle came from `EAType` through `show_type`. The first
build put the guard inside `patch_with_clause`, which made `None` carry
two reasons and the skip line lie about which; moving it to the caller
restored one verdict per meaning.

`Hβ.tools.consult-before-write` — RESOLVED 2026-08-18, and it is the
affordable half of the entry below. The pre-edit hook stops printing the
interrogations and REFUSES: no write to `src/**.mn` or `lib/**.mn` until a
medium verb has named that path this session. The pre-bash hook records
the consult at the exact branch where it already identifies a command as
a medium verb, so the ledger costs nothing and cannot be bypassed by
phrasing. A session starts with the ledger empty, because what the medium
said last session is about a tree that has since moved.
▶ WHY IT EXISTS: ten iterations edited wheel files without once asking
`mentl audit` what it knew about them; the first run answered in one
command what hand-reading had not, and the first `mentl tighten` exposed
a fabricating verb. The hook's own header used to read "never blocks —
audit is POST-edit", which is PLAN §0's argument about prose, written
into the scaffold that was supposed to enforce it.
▶ WHAT IT IS NOT: it does not run the audit (that is the entry below,
priced at 4.91s/777MB and image-gated). It requires that the question was
PUT. A verb answering with errors satisfies it — demanding a clean answer
would deadlock a mid-refactor file that does not yet compile.
▶ PRICED BEFORE IMPOSED: `mentl check` costs 0.65s/208MB on types.mn,
0.73s/227MB on lexer.mn, 2.53s/725MB on infer.mn — once per file per
session, not per edit.
▶ FALSIFIED FIVE WAYS through the hooks' own stdin contract: an
unconsulted wheel edit exits 2, a consult writes the marker, the same edit
then exits 0, a DIFFERENT wheel file stays refused, and a cursor address
counts as a consult. The first attempt failed and the failure was the
find — the ledger sat below the hook's `mentl`-led early exit and never
ran, so it moved to that branch.
▶ SCOPE: wheel source only. tests/, docs and the seed keep the reminder
alone; the law is about editing the medium without asking it.
▶ AND THE LOGIC IS TRACKED. The first landing put it in `.claude/hooks/`,
which `.gitignore` line 2 excludes — an enforcement living in one working
copy is not an enforcement, and the commit would have shipped only the
prose describing it. `tools/consult-gate.sh` owns the three entry points
(record / require / reset) and the hooks are one-line wiring, which is the
pattern the drift-audit hook already used. Re-falsified six ways after the
move, including a lib/ file and a tests/ fixture.

`Hβ.audit.at-the-edit-is-image-gated` — THE SELF-BUILD RATCHET'S OWN NEXT
STEP, PRICED AND REFUSED. Measured 2026-08-18 at pin 567a96659693.
▶ THE CASE FOR IT is the strongest this loop has: over ten iterations the
assistant hand-read source to find what `mentl audit <file>` says in one
command — tightenables, iteration-shapes, drift shapes, unresolved
comment refs, per-fn rows — and ran the verb once, late, by accident.
Every hand-read was a confession. The obvious absorption is the
PostToolUse drift-audit calling the medium's own verb, so the finding
arrives at the EDIT rather than at the commit.
▶ THE PRICE REFUTES IT, on the largest module: `mentl audit src/infer.mn`
costs **4.91 s and 776964 KB**; `tools/drift-audit.sh src/infer.mn` costs
**0.07 s and 3780 KB**. Seventy times the wall, two hundred times the
memory, per edit — and the memory floor is the same one the concurrency
gate guards, so a hook that spends 777 MB per keystroke-scale action is
not a hook.
▶ THE COST IS NOT INHERENT, WHICH IS THE FINDING. The verb re-infers a
9,616-line module and its link from scratch every invocation; the bash
scan reads text. Nothing about auditing requires re-judging what was
judged a second ago — that is the IC cursor's own domain, and the
cross-run half is `Hβ.persist.module-image-cache`.
▶ SO THAT PEER IS RE-MOTIVATED, and its docs undersell it. Band O carries
it as cross-run compile skip, a performance nicety. It is the GATE on the
medium auditing its own construction at the moment of construction —
which is `Hβ.audit.carried-truth-projection`'s whole point and §0's
"unsayable before a line is written". Until the image persists, the wrong
move can only be caught at the commit, by a bash proxy, which is where
this session's drift was in fact caught.
▶ NOT BUILT, and the middle ground was checked: a per-SPAN audit
(`mentl <file>:<line>`) still infers the module, so there is no cheaper
question to ask. The affordable channel today is the 0.07 s text scan,
and its rows stay until the image lands.

`Hβ.tools.authoring-verb-writes-only-proven` — THE GATE THE LANDING ABOVE
COULD NOT WRITE. A verify leg that exercises a WRITING verb needs a
scratch copy of the tree, because running it in place either mutates
during the gate or asserts nothing when the tree is already tight. The
contract to gate is stable and was measured at the landing: on a tight
tree `mentl tighten` reports `0 of N authorable applied` and every
declined site names its own reason. The shape is a copy-run-compare leg;
the reason it is not built is machinery, not doubt. Sibling, unmeasured:
whether `fmt` or any other authoring verb splices a rendered row the same
way — the same class if so.

`Hβ.types.eatype-render-lacks-display-totality` — THE DISPLAY HALF of the
same finding, with a landed precedent one arm away. `show_effarg`'s
`EANode` arm renders a bare VarRef as its name and anything else as
`<operand #N>`, its comment recording the fmt re-parse fixpoint that
taught it. The `EAType` arm renders through `show_type` unconditionally,
so a free type variable prints as its debug handle — which is what a
reader saw before the authoring guard stopped it entering files. The
authoring path is safe now; the PROJECTION still shows a handle where an
honest placeholder belongs, and the fix is the EANode arm's own
discipline applied one line over.

▶ THE MEASUREMENT THAT FOUND IT, kept because the arc is the value. THE
MEDIUM'S OWN AUTHORING VERB FABRICATED. Measured 2026-08-18 at pin
4dc2ac881254, the first time `mentl tighten` was run for real in this
loop.
▶ WHAT IT WROTE. Asked to tighten `src/lexer.mn`, the verb authored 33
row narrowings across the transitive link — and two of them were:

    fn iterate_from(xs, i, n) with Memory + Iterate(t42532@e10, t42533@e5) = …
    fn iterate(xs) with Memory + Alloc + Iterate(t42546@e1, t42548@e1) = …

`t42532@e10` is `show_handle`'s rendering of a FREE type variable — a
projection for a human reader — written into source as an effect
instance's argument. The wheel then refused itself: m2 generation
TRAPPED with 15 `E_UnresolvedHole` errors, the columns falling on those
very arguments.
▶ THE OTHER 31 WERE SOUND. Reverting only `lib/prelude.mn` and marching
the rest came back CLEAN at the IDENTICAL sha (4dc2ac881254) — row
narrowings are judgment, not emit — so the batch minus its two
fabrications is a real landing and is what shipped.
▶ THE DEFECT IS A CONFLATED OUTPUT, not a missing guard. One read serves
two consumers with different contracts: a PROJECTION for a reader may
show an unresolved var, because "unresolved at epoch e" is the honest
answer to a human question; an AUTHORED PATCH may contain nothing the
graph has not proven, because source is not a place to say "I don't
know". `tighten` uses the projection for both.
▶ AND THE DECLINE PATH ALREADY EXISTS. The same run printed
`mentl tighten: list_filled_from at lib/lists.mn:119 — no
single-line with-clause; skipped`, so the verb already knows how to
refuse a site it cannot rewrite and say why. What is missing is the
resolution check, not the machinery.

STAMP — `Hβ.tighten.authors-an-unresolved-handle-as-source`.
TRACED: the tighten site renders the inferred row and splices it into the
declaration text. A row carrying `EParameterized` with unresolved
argument dims renders those dims through the free-var projection, which
is legible and unparseable. The rule the fix states: an authoring verb
emits only what the graph has PROVEN, and declines the site otherwise
with the same skip line the no-single-line-clause case already uses.
PRICED: NOT MEASURED. The check is per rewritten declaration and reads a
row the verb already holds, so it adds no walk — but WHERE the
resolution test belongs is unmeasured: at the row renderer (making an
unresolved dim unrenderable in authoring mode) or at the tighten site
(inspecting before splicing). The first is the one-home form and the
second is local; which is sound depends on whether any other authoring
consumer shares that renderer, and that enumeration has not run.
WRITERS: the tighten verb's rewrite site; possibly the row renderer they
share. NOT ENUMERATED — that enumeration is the build's first move.
NOT COMPLETE: whether `fmt` or any other authoring verb splices a
rendered row the same way is unmeasured, and it is the same class if so.

`Hβ.emit.self-init-singleton-call-is-statically-uninstalled` — RESOLVED
2026-08-18, pin 362ac8b1eeae, CLEAN. `E_InitPerformsOwnOp` is the
thirteenth armed class: the emit pre-pass draws the inits as their own
scope (`{ walk_lemit_list(inits) } ~> preinstall_init_scope(hname, span)`)
and a direct perform naming that install's own handler refuses. The
pricing question answered itself by measurement — the backend had NO span
vocabulary, and the fix was not to invent one but to read the install
node's own Reason through the GraphRead row it already declares, so the
diagnostic lands at real coordinates. Gates both halves:
`mn-refuse-init-performs-own-op` and `mn-init-performs-outer-op` at 42.
The 1016 sibling belts are untouched and stay belts. THE CONFIG-DEFAULT
SIBLING IS MEASURED AND COVERED (2026-08-18, pin 4dc2ac881254): defaults
and state inits lower into one `inits` list, so the same scope catches
both — it refused on the first probe. What was wrong was the MESSAGE,
which said "state init" for both carriers until the sibling fixture made
that visible; it now names the perform-while-building without guessing
which carrier, because the class cannot distinguish them at that point.
Gates `mn-refuse-config-default-own-op` and `mn-config-default-outer-op`
at 7. The stamp follows.

▶ THE STAMP AS BANKED — THE ONE SITE WHERE THE BELT'S GUARD IS DECIDABLE. A singleton op call lexically
inside the `inits` of the very install whose handler it names has a
`world_find` that provably returns 0: the install's `world_push` has not
run, by construction, for every install of that handler.
STAMP. TRACED: `walk_lemit`'s `LHandleWith(_, b, hn, hname, inits,
arm_names)` already separates `inits` as its own field, and
`install_group_enames` over `arm_names` is the set that install absorbs —
both read at the node, both O(1) in the walk. The emit's singleton arm
already knows the handler name it is looking up. The pair of facts is
present; nothing needs deriving.
PRICED: NOT MEASURED. The emit is a streaming projection (wat_stdout
emits as it walks), and the executable gate runs BETWEEN reachability and
emit, so a refusal discovered during emit is discovered too late to leave
stdout with zero WAT — which is the gate's own contract. Whether the
decidable case can be lifted to the gate's pre-emit pass, or whether the
gate needs a second read, is the pricing question and it is what the next
step measures.
WRITERS: the emit's singleton-call arm (backends/wasm.mn) decides the
shape; a pre-emit refusal would instead land in the executable gate
(pipeline.mn). Which of the two is the site depends on the pricing above,
so the writer set is NOT settled.
NOT COMPLETE: the config-default sibling is unmeasured — a default
performing the handler's own effect presumably reaches the same belt, and
"presumably" is the word this loop has been punished for, so it is a
probe and not a claim.

▶ THE ORIGINAL OBSERVATION, kept for the arc: named 2026-08-18 when the
census design below was refuted and the floor's own marker read out what
lower had known all along.
▶ `LInvariantFailure` is emitted where the compiler has PROVEN a path
cannot run — the self-init repro's is `singleton op call with no live
install: hf — the state global is 0 in this extent; install the handler
(~> hf) around the calling walk`. The op, the handler, the extent and the
fix, all present, all at compile time, delivered as `(unreachable)` with
a WAT comment.
▶ The emit arm's comment states the policy deliberately: "Compiler-created
executable boundaries have no productive-under-error value. Preserve the
typed invariant in the WAT diagnostic and terminate; no backend is
permitted to guess a handle, row, representation, or edge." The
no-guessing half is right and stays. The TERMINATE half is what §11
column 2 drives to universal refusal — a program the medium has proven
cannot run should not compile.
▶ SCALE, measured: 1014 markers in a 13962716-byte m3.wat, all one class.
▶ NOT MEASURED, and it is the next probe rather than a claim: whether
those 1014 are unreachable-in-practice or the extent read is conservative
at sites that do run. The wheel self-compiles, so they do not fire; which
of the two reasons holds decides whether this is a refusal to arm or an
extent analysis to sharpen, and the two want different builds.
▶ DEP: none on band A. This is a diagnostics-and-gate question at the
emit boundary, independent of the modal install-identity frontier that
the entry below is blocked on.

`Hβ.effects.root-gate-credits-an-install-that-had-not-opened` — AN OP
BEFORE THE EXTENT OPENS IS THE MIRROR OF THE ONE AFTER IT CLOSES, and only
one of them is caught. Measured 2026-08-18 at pin c3410610ce41: four runs,
three projections. SUPERSEDED IN AIM by the entry above — the shape it
chased is an `LInvariantFailure`, not an effect demand, so the gate was
never the site.
▶ THE SHAPE. A handler whose state init performs the effect that handler
itself handles compiles and TRAPS:

    effect F { g() -> Int }
    handler hf with s = g() {
      g() => resume(42),
    }
    fn main(q) = (g()) ~> hf

`mentl check` is silent, 38467 bytes of WAT are emitted, and the program
exits 134. A trap where a diagnostic belongs.
▶ THE ROW IS RIGHT, which is the first thing to rule out and the thing
that makes this a gate finding rather than a row one. `fn m() with !F =
(g()) ~> hf` REFUSES with `!F + Any vs F`, so the init's F genuinely
escapes its own handler — correct, since the tee adds row(h) AFTER
subtracting handled(h), and an init runs before its install exists.
▶ FOUR CASES, ONE INCONSISTENCY, each read rather than reasoned:

    pure init + install        main : -> Int            gate passes   runs, exit 1
    init performs foreign E    main : -> Int with E     gate REFUSES  —
    init performs its own F    main : -> Int with F     gate passes   traps 134
    no install at all          main : -> Int with F     gate REFUSES  —

Rows two and three carry the same shape of fact and differ only in
whether a handler for that effect exists in scope. The row is sufficient
in all four; the gate is what varies.
▶ THE CONDITION IS FOUND AND IS DELIBERATE.
`report_unhandled_names` (pipeline.mn) clears a name when
`!string_in_list(strict, ename) && string_in_list(installed, ename)`, and
its own comment states the trade: "dynamic installs cover it at runtime
and the SingletonUninstalled guard is the loud belt beneath — the row
alone cannot split a dead extent from live dynamic coverage (the modal
install-identity frontier, band A, owns that split)."
▶ SO IT IS A NEW FACE OF A RULE THE CROWN ALREADY PINS. §11 6.3's
install-extent exactness says an op AFTER the install closed is
unabsorbed, and that crucible passes. An op BEFORE the extent OPENS is
the mirror, and the state init is the shape that reaches it — which is
why the previous two landings, having put the init's row on r_handle,
are what made this visible at all.

STAMP — `Hβ.effects.root-gate-credits-an-install-that-had-not-opened`.
TRACED: the clearing conjunct is install-NAME membership, not extent. For
a state init the extent question is not dynamic at all — the init is
lexically part of the handler declaration and provably runs before any
install of it exists — so this instance is decidable where the general
case the comment defends is not.
PRICED 2026-08-18, and the pricing KILLED the simple branch and MEASURED
the blocker on the narrow one.
▶ DELETING THE CREDIT IS REFUTED. With the clearing conjunct disabled, a
probe m2 built and then REFUSED THE WHEEL: m3 exit 1, pm3.wat ZERO bytes,
one diagnostic — `effect GraphRead reaches the executable root with no
absorbing handler … Install one over the performing chain: ~>
graph_handler`. The comment's defence is exercised, once, by the wheel
itself, so the credit stays. One effect, named, rather than an argument
about dynamic installs in general.
▶ AND THE NARROW BRANCH CANNOT BE WRITTEN AT THIS GATE. A drained demand
is a bare NAME: `demands_to_enames` does `env_lookup(d)` and decides
strictness from the op's own `EffectOpScheme(op_effect, default_handler,
…)` plus `handler_stateful(default_handler)`. No span, no position, no
origin reaches the gate, so it cannot tell an init's perform from a
body's — which is exactly the distinction the narrow fix needs. The
demands come from `walk_lemit(lowered)` + `drain_effect_census()`, so the
change is at the CENSUS, not the gate: a demand would have to carry where
it was performed.
▶ THE CENSUS DESIGN WAS BUILT AND IS REFUTED (2026-08-18, reverted
whole). `EmitEffectCensus` grew a pre-install demand channel, the
`LHandleWith` walk installed a `~>` scope over its own `inits` carrying
that install's absorbed enames, and the gate joined the pre-install set
into `strict`. It MARCHED CLEAN — m2 == m3, census 0, battery green — and
CHANGED NOTHING: the repro still compiled and still trapped, its emit
byte-identical at 38467 bytes both sides.
▶ BECAUSE THE PERFORM NEVER BECOMES A DEMAND. The trap is an
`unreachable` in `main`, and the floor-naming landed earlier this session
reads it out: `executable-boundary invariant: singleton op call with no
live install: hf — the state global is 0 in this extent; install the
handler (~> hf) around the calling walk`. Lower already DIAGNOSES this
exactly — the op, the handler, the extent, the fix — and emits it as an
`LInvariantFailure`, which the census walk does not visit as a demand at
all. Three iterations of this arc aimed at the effect census; the fact
was sitting in the emit under its own name.
▶ SO THE FINDING RE-AIMS, AND UPWARD. This is not a gate that credits the
wrong install; it is a compile-time-KNOWN impossibility emitted as a
runtime trap. The emit arm's own comment states the policy — "Compiler-
created executable boundaries have no productive-under-error value.
Preserve the typed invariant in the WAT diagnostic and terminate" — which
is exactly the shape §11 column 2 is driving to universal refusal.
▶ AND IT IS NOT RARE. The wheel's own m3.wat (13962716 bytes) carries
**1014** of this marker, every one the same class, `singleton op call
with no live install`. What that number means is NOT measured: the wheel
self-compiles, so those sites are unreached or the extent read is
conservative, and which of the two is the next probe rather than a claim
made here.
▶ WHICH MAKES THE SPLIT SMALLER THAN BAND A'S, NOT EQUAL TO IT. The
comment defends a genuinely undecidable case (a dead extent versus live
dynamic coverage). A state init is not that: it provably runs before any
install of its own handler, for every install, statically. So a
census-level origin is sound where the general extent question is not —
and that is the design the next step owes, priced as a representation
change to the demand rather than a conjunct at the gate.
WRITERS: `report_unhandled_names` READS the verdict; `demands_to_enames`
computes it from the op's env entry; `drain_effect_census` /
`walk_lemit` mint the demands. The change lands at the mint, and the row
producers need none, having been measured correct above.
NOT COMPLETE: no fixture landed, because the surface is broken and a
crucible here would canonize the trap. The repro above is the bank. Also
unmeasured: whether the same credit clears an op performed in a config
DEFAULT of a handler that handles it — the sibling shape the last two
pins closed on the row side.

`Hβ.effects.handler-state-init-row-never-installed` — RESOLVED
2026-08-18, pin b9733815b54d, CLEAN, crown 54/0. The stamp's own first
move found it: the ARMS ride `r_handle`, and the inits sat two lines above
that scope. Moving `infer_handler_state_inits` and
`bind_handler_state_names` inside `inf_enter_fn(r_handle, …)` puts an
init's row on the accumulator the tee already carries to every installer —
no new carrier, since `+ row(h)` was written all along. Measured at the
same repro before and after: clean-with-"only uses Pure", then
`!E + Any vs E`, with the init still performing (exit 7 re-run). Gates:
`leak-state-init-performs` and `sound-state-init-pure`. The `Handler(F)`
observation below stands and is now a smaller gap — the type still carries
no row, and the fix routed around it rather than through it, which is the
open half if handler VALUES ever need one. THE CONFIG-DEFAULT QUESTION IS ANSWERED AND CLOSED
(2026-08-18, pin c3410610ce41, CLEAN, crown 56/0): the same leak one
field over — `handler hf(k: Int = op())` checked clean while the default
genuinely performed (exit 7 through an outer handler) — and the same
move fixes it, the default `each` joining the inits inside r_handle's
scope. One rule, two carriers: everything a handler install EVALUATES
belongs in row(h). Gates `leak-config-default-performs` and
`sound-config-default-pure`. ONE open question remains, unmeasured: an
init performing an effect the handler ITSELF handles — does it resolve to
its own arms (a self-install) or to the enclosing world? The measurement
that found the first leak follows.

▶ A HANDLER'S STATE INIT PERFORMED IN THE INSTALLER'S WORLD AND CHARGED
NOBODY. Measured 2026-08-18 at pin c968f690567b, on the 6.3 modal sweep;
three runs, one projection.
▶ THE LEAK. `handler hf with s = op() { g() => resume(s) }` installed by
`fn bad() with !E = (g()) ~> hf` checks CLEAN, and `T_OverDeclared`
volunteers that the body "only uses Pure". Repro:

    effect E { op() -> Int }
    effect F { g() -> Int }
    handler hf with s = op() {
      g() => resume(s),
    }
    fn bad() with !E = (g()) ~> hf
    fn main() = bad()

▶ THE INIT REALLY PERFORMS, which is what makes it a leak rather than a
dead expression. Give `op` a handler returning 7 and install both —
`((g()) ~> hf) ~> he` — and the program exits **7**. The value reached
`s` through an install-time performance of E resolved by the outer
handler.
▶ THE CONTROL REFUSES, so the POSITION is the variable: the identical
`op()` written in `bad()`'s body is
`E_EffectMismatch: !E + Any vs E`. Body charges, init does not.
▶ ARMS ALREADY CHARGE. `tests/crown/leak-arm-adds-row` refuses on the
same shape one layer over, so this is not "the tee never adds" — it is
the init specifically sitting off whatever channel the arms ride.
▶ AND THE HANDLER'S TYPE HAS NOWHERE TO PUT IT: `mentl query "type hf"`
projects `Handler(F)` — the effect HANDLED, with no row for what the
handler performs. SYNTAX's tee rule is
`row(expr ~> h) = row(expr) - handled(h) + row(h)`, and the `+ row(h)`
half has no carrier in that type. infer.mn's own PTee comment says so in
as many words — "we don't have handler-value typing so arm_row can't be
extracted from RHS" — a comment measured TRUE this turn and pointing at
the same hole.

STAMP — `Hβ.effects.handler-state-init-row-never-installed`.
TRACED: `infer_handler_state_inits` walks each init with `infer_expr` at
HANDLER-DECLARATION time, so whatever row the init performs is charged
against the frame current when the DECL is judged, not against any
install site. At runtime the init evaluates once per install, in the
installer's world — measured above. The two disagree, and the honest
reading is SYNTAX's: an init is part of the handler, so its row belongs
in `row(h)` and the tee's existing `+ row(h)` carries it to every
installer. That is not a new concept and not a fork; it is the rule
already written, with a carrier that does not exist yet.
PRICED: unmeasured, and deliberately so — the cost turns on where the
arm channel puts its row, and reading code to guess that is the error
this loop has paid for five times. The read is O(1) per install either
way (a row already computed, joined at an edge already drawn); what is
unpriced is whether a carrier on `Handler(F)` is an arity change at the
handler type's own sites.
WRITERS: NOT ENUMERATED. `infer_handler_state_inits` is where the init's
row is produced; where the ARM row reaches an installer is the unfound
half, and finding it is the build's first move — the arm channel is the
existing, working precedent this fix should join rather than duplicate.
NOT COMPLETE: three questions stay open and each is a measurement, not an
opinion. Does a config PARAMETER's default expression perform in the same
position? Does an init performing an effect the handler ITSELF handles
resolve to its own arms (a self-install) or to the enclosing world? And
does the wheel contain any effectful init today — measured indirectly as
NO, since every gate is green and this leak would hide one, but not
measured directly.
`Hβ.tools.green-stamp-under-included-three-batteries` — RESOLVED
2026-08-18, and the finding is that the loop's own law was being broken by
the loop. `wt_state_key` hashed `tests/micros/*.mn` and not
`tests/syntax`, `tests/rows` or `tests/floors` — three directories whose
fixtures a verify leg reads and whose contents can change its verdict.
Each arrived WITH its leg and none extended the key; two of the three were
added by this loop, three and two iterations before the find.
▶ MEASURED, not read: mutate a syntax fixture, re-derive the key, and the
hash comes back identical (a461fe963731…), so the stamp answers green for
a tree whose battery has grown. `wt_state_key`'s own comment had already
written the verdict — "under-inclusion is the bug".
▶ IT FIRED THE SAME DAY. The commit that added
`tests/syntax/record-spread-resort.mn` was let through by the pre-commit
hook WITHOUT the thesis gate, because the stamp still matched. The fixture
happened to be green (verified by hand, both directions), so nothing
landed broken — but a red one would have landed silently, which is the
"trusting a stamp the change invalidated" hazard named in the loop prompt
and paid for here rather than argued.
▶ Falsified per directory after the fix: a mutation in micros, syntax,
rows and floors each moves the key.

`Hβ.tools.exit-channel-caps-at-125` — RESOLVED 2026-08-18 in the harness,
banked because the ceiling is a fact about the substrate and not about the
fix. MEASURED against the pinned boot: a `main` returning 124 or 125 exits
with that number; 126, 127, 128, 200, 255 and 256 ALL exit **1**. So a
fixture cannot encode a value above 125, and an author who writes one reads
`exit=1` — which says the program computed 1, and it did not. The battery
was audited at the same time: 157 fixtures carry a numeric expectation, 9
sit above the ceiling and every one of them is 134, a wasm trap through
SIGABRT rather than a value, so nothing landed was broken. run-micro.sh now
REFUSES 126 and 127 before running (neither a reachable value nor a signal)
and, on a failure where the expectation exceeds 125 and the run returned 1,
says that the 1 is the channel and not the program. The hazard was
prospective and silent; it is now loud at the only place an author looks.

`Hβ.query.type-of-a-lambda-parameter` — `mentl query <file> "type NAME"`
reaches top-level names and fn parameters and answers `not found: tag`
for a lambda's parameter (measured 2026-08-18 on
tests/micros/mn-findtag.mn, whose `find((tag) => tag.handle == h, tags)`
is exactly the shape a row dig wants to interrogate). The line
projection `mentl <file>:<line>` answers with the whole expression, so
the only way to the inner binder today is a column, and a column
arrived at by counting characters is the fabricated coordinate the loop
forbids. The graph holds the binder — lower binds it, infer judges it —
so this is a lookup that stops at the env's own edge rather than a fact
the medium lacks. Lands with the per-module overlay's link sets
(`Hβ.driver.per-module-env-overlay`), whose scoped views are what let a
query name a binder inside a scope.

`Hβ.at.emit-floor-facet` — THE FLOOR IS LEGIBLE IN THE WAT AND INVISIBLE
AT THE SOURCE. Since pin 88050b76596d the marker names its selector and
the receiver's row, which is the fact a dig needs — but reading it means
compiling to a `.wat` and grepping an artifact, which is a hand tool
where a projection belongs, and this arc confessed it four times in one
iteration. `mentl <file>:<line>` at a field access should carry the
emit's own verdict as an aspect: offset resolved at N, or unprovable
with the row that blocked it. It is the eighth arm (Reason) read at the
emit altitude, and it composes with `mentl where`'s derived badges
rather than adding a surface. DEP: nothing structural — the emit already
computes both halves; what is missing is a channel from the backend's
per-site verdict back to a source position, which the span already on
the LowExpr supplies.

`Hβ.diag.row-polymorphic-body` — WHAT THE CURSOR SHOULD SAY AT A FREE ROW
CELL. `enforce_row_gate`'s unbound arm now teaches nothing there (pin
5446b82bddd4), which is correct and is not the whole answer: silence is
the absence of a false claim, not the presence of a true one. The fact
the graph holds is precise and worth speaking — this function's row is
not determined by its body; it is its parameter's row, and it grounds at
the call site. `fn run(f) with A = f()` should hear that, with the param
named and the two row vars shown as the one edge they will become. The
existing `T_OverDeclared` cannot carry it (it asserts a judged body), so
this is a new `DiagKind` constructor and lands with band L's
`Hβ.diag.catalog-as-projection` rather than as a hand-added string. It is
the teaching half of the fork banked above, and it is useful under EITHER
branch.

`Hβ.lower.state-init-config-ref-nested` — THE ROOT, and this entry OPENS
with the retraction of its own previous version.
▶ RETRACTED: the entry here claimed "decl-side handler state-init
expressions are never inferred", named it
`Hβ.infer.handler-state-inits-are-never-judged`, and reasoned from
`register_handler` doing only the op-shadow check. THAT IS FALSE. The
judging happens elsewhere in the same file:
`infer_handler_state_inits(state)`, whose neighbouring comment states the
contract exactly — "Config params bound FIRST — before the state inits
are inferred — so a state init that references a config param READS the
live config" — and records the bug that motivated it (fold's accumulator
splitting into four vars). The claim was refuted in two seconds by the
probe that should have run first: `handler h(start) with n = nosuchname
+ 1` reports `E_MissingVariable at 5:30-5:40` and `mentl run` REFUSES at
exit 1. Inits are judged; unbound names in them refuse correctly. I read
one site, found it insufficient, and generalised to "never" without
grepping for the other reader — the exact code-reading-over-measurement
error §5.O's own history warns about, made twice in one day.
▶ WHAT IS ACTUALLY TRUE: infer resolves a config ref in a state init
fine, which is why a clean `mentl check` is CORRECT rather than a missed
diagnostic. LOWER cannot lower it. `lower_state_init` matches only a
TOP-LEVEL `VarRef` against the config names, turning it into
`LUpval(0, slot)` — a structural read of the config slot of the same
record, config being written first — and sends everything else through
`lower_expr`, where the config name is not in the lowering scope,
resolves `RGlobal`, misses `env_kind_of`, and becomes the MissingName
floor. So `with n = start` runs and `with n = start + 1` traps, and the
site's own comment has said so all along: "A config ref nested inside a
larger expression is a peer."
▶ THE REMAINING HONEST DEFECT is narrower but real: the failure is a
runtime FLOOR, not a refusal. The program checks clean and traps at exit
134, where a lowering that cannot lower a construct should refuse it.
▶ THE FIRST FIX ATTEMPT IS REFUTED (2026-08-17, reverted whole). No new
op was needed: `ls_enter_frame(fn, locals, local_h, captures, capture_h,
lambda_h)` already resolves a name in CAPTURES to `RUpval(slot)`, so
wrapping the init lowering in a frame whose captures are the config
names should have made a nested ref resolve exactly like the hand-built
top-level case — same slot numbering (`capture_order` index ==
`index_of_name`), same handle 0 — with `lower_state_init`'s special case
dissolving into the resolver. It measured WORSE: m3 trapped, and probing
the candidate wheel showed the DIRECT case (`with n = start`) had
regressed to a trap too, while the nested case was unchanged. So the
frame was not being consulted at all for these lowerings; deleting the
special case simply removed the only thing that worked.
WHAT IS PROVEN SOUND IN ISOLATION, so the next attempt need not re-check
it: `ls_resolve` searches `frame.captures` and returns
`RUpval(cap_idx)` with the capture's handle (lower.mn's handler body);
`ls_enter_frame` is a plain push of a frame record; and the install path
does reach this code — `lookup_handler_state_inits_of` calls
`lower_state_field_inits` directly. Each link checks out and the chain
still fails, which is precisely the shape that wants instrumentation
rather than more reading: I guessed four times in this iteration and the
artifact refused each guess.
THE STRUCTURAL BLOCKER, MEASURED 2026-08-17: THE GRAPH DOES NOT RECORD
WHICH CONFIG SLOT A VARREF RESOLVES TO. `bind_handler_config_params`
records the Reason `LetBinding(name, Declared(hname))` at env-extend
time, which suggested a one-site fix — lower reads the node's Reason,
sees the handler, emits `LUpval(0, slot)`, no walker and no frame, the
Carried-Truth move. The projection refuses it. At the init's config USE
the address answers `start : Int` with `Why: resume carries the
continuation input`, and at the config DECLARATION it answers
`start) : _ — still free`, `Why: placeholder`. The env scope that held
the binding is gone by lower time and the Reason at the node is a
different reason entirely, so there is no live fact to read.
WHAT THAT LEAVES, and why nothing is built: every remaining route needs
either NEW WALK MACHINERY over the init (39 LowExpr arms, which §11 5.5's
column arc plans to delete) or CONTEXT threaded into `lower_expr`'s
shared VarRef arm (the frame, whose failure in the demand walk is still
unmeasured). Neither is a small correct change today.
THE ULTIMATE FORM IS THE ONE 5.5 ALREADY PRESCRIBES: the config-slot
resolution belongs in the graph as a per-handle fact — written at the one
writer where infer binds the param, read live at lower. Then lower needs
no scope, no frame and no walker, the nested case works by construction,
and `lower_state_init`'s special case DISSOLVES rather than being
extended. That is the same "put the per-handle fact in a column, dual-write
at the one writer, migrate the readers, delete the side-structure" move
the subsystem table's remaining 40% is made of, and it sequences with
that arc rather than ahead of it.

RESOLVED TO A MECHANISM 2026-08-17, by reading the emit's own
construction and then the full backtrace. Three facts, each measured:
  (1) THE FLOOR IS A RUNTIME ELSE-BRANCH, NOT AN EMIT-TIME PROOF.
      `singleton_perform_block` emits, for every STATEFUL singleton op
      call site, `LLet(rec, LWorldResolve(hname))` then
      `LIf(rec, [perform], [LInvariantFailure(SingletonUninstalled)])`.
      The `unreachable` is the null-record arm. So a floor COUNT is just
      the number of such call sites in the build — 50 in baseline, 52 in
      the frame variant because the variant adds two — and it is evidence
      of NOTHING about installs. Both prior readings of that count were
      wrong, and so was every design that rested on them.
  (2) THE FRAME CALL SUCCEEDS. The variant's trap sits in
      `lambda_329309` under `op_map_collector_yield` / `iterate_from` /
      `map$spr_initnNode_nLowExpr`, i.e. INSIDE the map's lambda, which
      is `lower_expr(field.init)`. Had `ls_enter_frame` floored it would
      appear directly under `lower_state_field_inits`. It does not.
  (3) THE CONTEXT IS THE DEMAND WALK, not ordinary lowering:
      `lower_state_field_inits` ← `lower_pipe` ← `project_nested_fn` ←
      `lower_stmt_body` ← `reach_construct_loop` ← `reachable_from_main`
      ← `compile_remainder`.
WHAT THAT MAKES THE SPECIAL CASE: not a shortcut around a missing frame,
but a shortcut around `lower_expr`'s VARREF PATH, which cannot run in the
reachability-construction walk. The bare-config-ref case works precisely
because it never enters that path; the nested case fails because it must.
SO THE FIX, grounded in (2) rather than guessed: config refs must be
resolved structurally AT EVERY DEPTH without entering the general VarRef
lowering — the init's own walk substituting `LUpval(0, slot)` for a
config name wherever it appears. The frame is not the mechanism and was
never needed; `lower_state_init` was right to resolve by name.
WHAT IS STILL UNMEASURED, and must not be assumed: WHICH op inside
`lower_expr`'s VarRef arm floors in this walk (`ls_resolve`'s own
dispatch, `graph_bind_note`, or `env_kind_of` on the RGlobal branch).
The design above does not depend on the answer, so it is not a blocker;
it is the probe to run if the structural rewrite meets a second wall.

SUPERSEDED, kept for the record — CORRECTED 2026-08-17 BEFORE ANYTHING WAS BUILT ON IT. The entry below
read 52 `singleton op call with no live install: lower_scope` floors in
the frame variant's wheel and concluded the change caused them. THE
BASELINE WHEEL HAS 50. The delta is +2, which is exactly the number of
new `ls_` call sites the variant added (`ls_enter_frame`,
`ls_exit_frame`), so the mechanism survives but the evidence as stated
did not: an absolute count proves nothing without its baseline, and
counting the baseline cost one march.
AND THE CORRECTION SHARPENS THE QUESTION, because a second measured fact
does not fit "the handler is not installed": the BASELINE compiles the
nested repro to a NON-EMPTY 38,568-byte WAT carrying the `MissingName`
marker for `start`, and reaching that marker requires `ls_resolve` to
have returned `RGlobal` at this very site. So `lower_scope` IS reachable
here at runtime, and the two added sites floored at EMIT time. Those are
different mechanisms and only the second is measured.
NAMED NEXT PROBE, and no design until it runs: determine whether the
emit's singleton-install proof is per CALL SITE. `ls_resolve` is called
from `lower_expr`'s shared VarRef arm and does not floor; the added
`ls_enter_frame` in `lower_state_field_inits` does. If the proof is
per-site, the frame approach is not dead — it needs the install proven at
the new site, which the floor's own message spells out ("install the
handler around the calling walk"). If the proof is per-handler, it is
dead and the structural rewrite is the only route.
SUPERSEDED TEXT, kept for the record: `lower_state_field_inits` runs
where the `lower_scope` handler is NOT INSTALLED. The candidate wheel
built with the frame variant carries 52 floors, read out of
`.build/m2cache/m2.wat` — so every `ls_enter_frame` /
`ls_resolve` / `ls_exit_frame` in that variant lowered to an
`unreachable`, and the compile TRAPPED (exit 134, zero WAT, backtrace
pinning `map$spr_initnNode_nLowExpr` under `lower_stmt_body` — the very
map added by the change).
THE COMMENT THIS ARC DISMISSED SAID EXACTLY THIS: the config slot is
"resolved STRUCTURALLY (the config slot is known by name — carried
truth, not re-derived) rather than via a frame the install must thread
evidence for." The frame is unavailable BECAUSE the install does not
thread LowerScope evidence to this site. The special case is therefore
the CORRECT design, not a shortcut, and three iterations of treating it
as one were three iterations of arguing with a true comment.
WHAT THAT MAKES THE REAL FIX: the nested case must be resolved
STRUCTURALLY too — config refs substituted for `LUpval(0, slot)` inside
the init's lowering without any scope handler. That is a lowering pass
parameterised by `config_names` (thread them into the init's own walk,
or rewrite the lowered tree), and it is the only shape the evidence at
this site permits.
▶ RETRACTED FROM THE ENTRY BELOW: "THE FRAME IS CONSULTED … ZERO
`unbound name` markers". The file grepped for those markers was ZERO
BYTES — the compile had trapped and emitted nothing, so zero matches
meant nothing. A conclusion drawn from an empty artifact, which is the
same "no verdict from empties" the march's own SIZE-GUARD refuses.
Check the byte count before grepping an artifact.

THE PROBE RAN (2026-08-17) AND REFUTED ITS OWN QUESTION. Two facts, both
from the artifact:
  (1) The special case works exactly as documented. Encoding the branch
      taken in the exit code — 777 for an empty `config_names`, 888 for a
      name not found — the repro answers 10, so the list is populated and
      the name resolves at its slot.
  (2) THE FRAME IS CONSULTED. Rebuilding the frame variant and reading
      the EMITTED WAT for the repro shows ZERO `unbound name` markers.
      The name resolves through `ls_resolve` and no MissingName floor is
      emitted. So "the frame was never consulted", written here one
      iteration ago, is WRONG — that was a third guess, refuted like the
      others.
WHAT IS ACTUALLY OPEN: the frame variant lowers CLEANLY and still traps
at RUN. One difference is visible in the code and is the first thing to
test: the special case emits `LUpval(0, slot)` with handle 0, while the
resolver path takes `LUpval(if local_h == 0 { handle } else { local_h },
slot)` and, since the capture handles are zeros, lands on the VarRef's
OWN handle. Same slot, different handle — and emit reads the handle for
type-directed decisions.
INSTRUMENT LESSON, paid for with two broken wheels: `lower_state_field_inits`
is shared by EVERY handler in the wheel, so any behavioural probe there
is a whole-wheel change — a constant substituted for state inits stripped
the wheel's own handlers of their state and produced m3 ≠ m4 twice, once
even when gated on a fixture-only name. The instrument that works here
needs no behaviour change at all: build the candidate m2, compile the
repro, and READ THE WAT.
NAMED NEXT PROBE: diff the emitted state-init region of the repro between
the baseline and the frame variant. Both lower without a floor, so the
divergence is visible in the emitted code, and the handle difference above
is the hypothesis to confirm or kill first.
THE MINIMAL REPRO, seconds instead of a march
(tests/frontier/mn-handler-state-from-config.mn, plus two scratch
variants): `handler h(start) with n = start` runs and answers 10 —
lower's structural case. `handler h(start) with n = start + 1` TRAPS,
because the config name is unbound the moment it sits inside a larger
expression. The emitted WAT names it exactly:
`(unreachable) ;; executable-boundary invariant: unbound name start —
infer proved it missing; the lowering will not guess it into a global`.
THE SILENT-WRONG, which is the part that matters: `mentl check` reports
NOTHING on that program. Zero diagnostics, then a runtime trap at exit
134. The MissingName floor is a deliberate belt-and-braces whose own
comment expects infer to have already fired a precise, spanned
E_MissingVariable — and for ordinary code it does. Here infer never
walked the expression, so nothing fired, and the executable gate had
nothing to refuse. A program that type-checks and traps is the class §0
exists to make unsayable.
THE FIX, one build for both halves: infer judges decl-side state inits
with the handler's config params in scope. Then the unbound name is an
ordinary E_MissingVariable (armed → refuses the executable), the floor
returns to being belt-and-braces, and `n = start + 1` simply WORKS —
which is what unblocks `Hβ.own.region-index-per-install` and its 24%.
Blast radius is real and must be marched, not assumed: expressions the
wheel has never judged become judged, so new diagnostics are possible;
every wheel init is a literal or a simple call, so the census is the
arbiter.
THE GATE LANDS WITH THE FIX. The fixture is RED today by construction,
and gating today's behaviour GREEN would canonize the bug — §9.11's own
warning that a banked expectation can be the bug canonized.

`Hβ.lower.handler-state-init-reads-config` — the SYMPTOM of the root
above, bisected 2026-08-17 to an exact four-variant repro before the
root was found. A handler's STATE INITIALIZER cannot read that
handler's own CONFIG PARAMETER. Four marches, one variable each, on
`region_tracker`:
  no config param                                    → CLEAN
  param present, UNREAD by the initializer           → CLEAN
  param read inline, `list_filled(buckets, [])`      → TRAP, exit 134
  param read via a call, `region_index_new(buckets)` → TRAP, exit 134
So it is neither the parameter's presence, nor a nested call, nor the
value passed (65536 at every site — behaviour-identical to the working
form — traps exactly as 1024 did), nor the capture-vs-literal
distinction (a top-level `let` and a bare literal trap the same). It is
the READ, in the initializer, of the config the install supplied.
THE SYMPTOM FITS THE DOCUMENTED CLASS AT A NEW SITE: `branch_bracket`'s
own comment names `Hβ.lower.install-config-capture-read` — "a
capture-referencing config arg reads 0; params read true" — for ARM
bodies. This is the same zero arriving in the STATE INIT, and the trap
follows mechanically: `list_filled(0, [])` gives an empty index, whose
`len(idx) - 1` mask is `-1`, whose `i32_and(handle, -1)` is the raw
handle, whose `list_set` runs off the end.
WHY IT HAS NEVER FIRED: no handler in the wheel derives state from its
config. `graph_handler(spine0, …) with spine = spine0` ASSIGNS a config
straight through, which works; `intern_table with buckets =
list_filled(4096, [])` uses a literal. Deriving is the untested shape,
so the medium accepts such a handler and miscompiles it — a program that
type-checks and traps, which is the class §0 exists to make impossible.
THE GATE LANDS WITH THE FIX, not before: a frontier fixture whose
handler sizes its own state from its config and asserts the value
arrived. It is RED today by construction, so it would be a red gate, and
those do not land — the fixture and the fix are one landing.
WHAT IT BLOCKS: `Hβ.own.region-index-per-install`, the 24%-of-a-compile
region-index fill, whose only clean fix is exactly this shape. The
alternative route stands if the substrate fix proves deep — put the
region fact in a spine column (§11 5.5's test) and the per-install fill
has nothing left to fill.

`Hβ.own.region-index-per-install` — MEASURED and its first fix REFUTED,
2026-08-17, pin 5a61fc4eba. With the branch spawn deleted the profile is
unambiguous: `branch_bracket` 55.95% inclusive, `list_filled_from`
specialised on Span 25.91% SELF, and 24.04% of the whole run reached
from branch_bracket alone. The cause is `region_tracker`'s state
initializer. `region_index_new()` builds a 65536-slot bucket list one
`list_set` at a time, the initializer runs on EVERY install, and
`branch_bracket` installs the handler per judged branch — so `fn main()
= 7` writes ~28 million slots to hold a few dozen entries. The index
itself is right and its comment says why (it replaced a linear find that
was ~93% of a 2026-07-13 self-compile); the SIZING is what a branch
should not inherit from the root.
LANDED: the bucket count is read live from the index (`len` is
`load_i32`), deleting the 65536/65535/65535 triplicate. Behaviour-neutral
by itself, and the precondition for any sizing.
THE KILL: making the count a handler CONFIG PARAM — `region_tracker(n)`,
the root and trial installs passing 65536 and branch_bracket 1024 —
TRAPPED m3 at exit 134 with zero bytes emitted. Probed twice: a top-level
`let` and a bare literal trap identically, so it is NOT the
capture-referencing-config-arg class `branch_bracket`'s own comment names
(`Hβ.lower.install-config-capture-read`). Isolated by reverting the param
alone and re-marching: mask-only is CLEAN, m2 == m3, census 0. So the
defect is in giving THIS handler a config parameter at all, at one of
these three install sites, and it is unexplained.
NAMED NEXT PROBE, and nothing gets built on this until it runs: bisect
the three installs. Give `region_tracker` a config param and pass it at
the ROOT install only, leaving the trial and branch installs bare (they
would take the hole, which typechecks — that is itself worth confirming
against the trap). A clean march says the branch install is the problem;
a trap says the handler's parameterisation is. Either answer names a real
substrate gap, and the 24% is worth the probe.
ALTERNATIVE ROUTE IF THE PARAM STAYS BROKEN: the region fact is a
per-handle fact, which is exactly §11 5.5's column test — put it in a
spine column, written at the one writer, and the per-install fill has
nothing left to fill.

`Hβ.march.concurrency-is-a-projection` — the thread gate's own retirement,
banked 2026-09-06 the hour the gate landed. `tools/thread-gate.sh` counts
the compile's guest OS threads from OUTSIDE, at clone/clone3 under strace,
as a delta between a 61-declaration program and a 1-declaration one. Every
line of it is a hand tool standing where a projection belongs: the medium
performs `wasi_thread_spawn` through its own WasiThreads effect, so it
already holds the number the script reconstructs from syscalls, and the
honest form is `mentl march` printing concurrency beside the cost line it
prints today — the row made visible, one more fact the self-compile reports
about itself. Until then the gate is the scaffold tier and says so in its
own header. The DEP is small and named: a spawn counter on the WasiThreads
handler, read at march time; it rides Phase 9.2, where the number stops
being 0 and starts being the width the parallel walk is supposed to have.
WHY IT IS WORTH BUILDING RATHER THAN LEAVING TO BASH: the class it guards
(`Hβ.infer.serialized-judge-still-spawns`, below) was invisible for ten days
to a wholly green board, and the reason is exactly that nothing on the board
counted a thread. A projection is not a nicety here — it is the difference
between a fact the medium states about itself and a fact that has to be
excavated by someone who happened to profile.

`Hβ.infer.serialized-judge-still-spawns` — RESOLVED 2026-08-17, pin
3fc233421e, the same day it was found. A block of ONE now runs its branch
as a direct call (`BranchRec = BrDirect | BrSpawned`, decided by block
size so Phase 9.2's K=8 restores spawning untouched). The stamp's
question — is the isolation load-bearing at K=1 — was answered NO by
three readings of the artifact: `branch_bracket` carries the env overlay
and deferred diagnostics whether spawned or not; graph, intern, ledgers
and summaries are the root's live instances by the bracket's own comment;
and the `~> graph_handler` wrapper existed only to reproduce the
sequential form a spawned instance's empty world had broken. MEASURED:
guest threads 433 → 0, floor 0.78s → 0.58s, sweep 297.64s → 239.38s, m3
peak 2298592KB → 2174492KB. ONE CONSEQUENCE the crown caught and nothing
else would have: a task's body row never reached its spawner, so the
thread boundary was hiding the branch's ImageAlloc from every caller —
`driver_check_module` and `rederive_cone` now declare what they always
performed. The record of the find follows.

`Hβ.infer.serialized-judge-still-spawns` (the finding) — MEASURED 2026-08-17 by the
first aggregate profile of a trivial compile, and it is the dominator six
prior probes missed. §11 5.2 SERIALIZED the parallel final on 2026-08-07
(`judge_window = 1`, infer.mn) because the K=8 fan's correctness rested
on published schemes being live-var-free — exactly the property rung 3
deletes — and live cells raced its branches. The window went to 1. THE
SPAWN DID NOT. `layer_judge_walk`'s own comment states the shape without
flinching: "every layer branch runs as a REAL task — a spawned instance
of the whole module over the shared image", and `judge_blocks` spawns a
block of `judge_window`, joins it, and spawns the next. At window 1 that
is one OS thread per layer branch, created and joined, with no
parallelism bought.
THE MEASUREMENT, on `fn main() = 7`: 433 distinct threads over the run,
20 concurrent at peak against a 10-thread wasmtime baseline (measured by
polling the process task table for `help`, which loads the same 2.4MB
module and does no compiling, versus `check`). In the profile
`wasi_thread_start` carries 48.45% inclusive, `branch_bracket` 46.80%,
and the two list primitives the brackets run — `list_filled_from`
specialised on Span at 25.59% SELF and `list_set` at 23.17% SELF —
account for roughly half the entire run. HALF THE COMPILE IS SPAWNING
AND BRACKETING BRANCHES THAT RUN ONE AT A TIME.
WHY IT HID: an earlier `--no-children` read of a smaller capture showed a
flat profile with a 7% top entry, and that reading was recorded as "there
is no hot spot". Aggregating inclusive shares per symbol shows two
functions owning half the run. The lesson belongs beside §5.O's
measure-don't-read-code law: a flat SELF profile over specialised twins
hides a dominator that only the CHILDREN view names.
THE QUESTION TO STAMP, not yet answered: at window 1, can the branch be
a DIRECT CALL? The comment claims the join stream is "byte-identical to
the sequential walk by construction", which argues yes — but the spawn
also buys each branch a fresh instance with branch-local ledgers,
disjoint mint ranges and a read-only intern view, and whether those are
load-bearing at K=1 or merely inherited from the K=8 design is the
open question. Answer it against the artifact before building: the
prize is roughly half the floor, and the risk is that isolation is
doing quiet correctness work the comment credits to the window.
NOT A LICENCE TO TUNE THE CONDEMNED: the parallel form returns at Phase
9.2 with the deterministic handle partition. This is not an improvement
to that machinery — it is the observation that the SERIALIZED path pays
the PARALLEL path's full price for none of its benefit, which is a cost
5.2's own landing did not intend and did not measure.

`Hβ.perf.compile-is-linear-in-source` — the corrected law, 2026-08-17.
▶ RETRACTION FIRST. This entry was written the same day as
`Hβ.perf.compile-is-quadratic-in-modules`, asserting a fitted `0.062·N +
0.0064·N²` and convicting the env. THAT IS REFUTED and the name is
retired. The fit had four points spanning N=7..22 and it OVERFIT: it
predicts `mentl check src/main.mn` (N=54) at 22.0s, and the measurement
is 12.05s. The banked probe that killed it is the one that entry itself
named — separate module COUNT from total DAG LINES — run with the
`modules` facet supplying each entry's set.
▶ THE MEASUREMENT, eight entries, N=6..54, DAG lines 6.3k..58k:
canon N=7 6,299 lines 0.77s · types N=6 6,282 0.78s · effects N=7 7,708
1.00s · parser N=13 14,156 1.91s · infer N=18 25,534 3.67s · driver N=20
26,566 4.00s · lower N=22 32,766 4.78s · main N=54 57,968 12.05s.
Across a 9× size range cost-per-LINE moves 122 → 208 µs (1.7×) while
cost-per-MODULE moves 0.110 → 0.223 s (2.0×). Lines is the better
predictor and the residual drift is ~O(n^1.06). THE COMPILE IS LINEAR IN
THE SOURCE IT PROCESSES, at roughly 150µs a line. There is no pathology
here, and four pins of floor-hunting were looking for one.
▶ WHAT THAT ACTUALLY INDICTS, which is not the constant: a bare
`fn main() = 7` costs 0.77s because the prelude plus runtime floor is
6,299 LINES, and the medium processes all of them to compile one. The
frontier sweep pays that 149 times — ~940k lines of vocabulary
re-derived for fixtures that reference a handful of names. So the levers
are the two already named, in this order: `Hβ.driver.link-is-reachability`
(don't judge prelude decls nothing demands — at decl granularity a bare
program needs tens of lines, not 6,299) and
`Hβ.persist.module-image-cache` / the resident session (don't re-derive
the identical vocabulary across 149 processes). The per-line constant is
the THIRD lever and it is where `Hβ.perf.name-is-handle` lives; it is
worth the least of the three and must not be taken first.
▶ THE METHOD LESSON, recorded because it recurs: four points over a
3× range fitted a curve that a 7.7× range destroyed. §5.O already says
measure rather than read code; this adds that a fit is a hypothesis
until it predicts a point OUTSIDE the range it was fitted on. The
superseded entry's own text below is kept as the refuted claim.

`Hβ.perf.compile-is-quadratic-in-modules` — REFUTED 2026-08-17 by the
probe it named; see the corrected entry above. Retained as the record of
what was claimed: cost tracks MODULE COUNT, not entry size:
17-line canon (7 modules) 0.75s · 3594-line parser (13) 1.82s · 890-line
driver (20) 3.47s · 6559-line lower (22) 4.48s — driver costs nearly
twice parser on a quarter of the lines. Per-module cost RISES with the
count (0.107 · 0.140 · 0.174 · 0.204 s/module), and `a·N + b·N²` fitted
on the endpoints gives ≈ `0.062·N + 0.0064·N²`, predicting parser at
1.89s against 1.82s measured. At 22 modules the N² term is ~69%.
THE MECHANISM, structural and already named: `driver_check_entry` runs
`infer_program_converged` once per module, each against the shared env
every prior module installed into — N lookups over an env that grows
with N. That is §5.O's `env_find_flat` class, and its fix is
`Hβ.perf.name-is-handle` (Phase 9.3): a name interned once at lex, every
compare an `i32.eq`, every table handle-keyed. What is new here is the
TIE: the wheel's own per-invocation cost is now bound to that peer by a
fitted curve rather than a code reading, which is the §5.O lesson
itself — the 8-agent code-reading diagnosis missed the dominant cost and
measurement found it.
NAMED NEXT PROBE before any build: confirm the env is the N² term rather
than another per-module scan, by timing an entry whose modules are large
but few against one whose modules are small but many at equal total
lines. If cost tracks N and not lines, the env is convicted and 9.3 is
the build. Do NOT optimise the per-module constant first — it is the
term that stops mattering.

`Hβ.query.module-dag-facet` — RESOLVED 2026-08-17 at the same pin.
`mentl query <file> "modules"` projects the weave's NModule cells. Kept
as a record of the shape: the absence was found by the mentl-first hook
refusing a hand read, the answer was hand-rolled in shell that session,
and the verb replaced it the same day with its count verified against
that walk (canon 7, lower 22, both matching).

`Hβ.query.cost-facet` — RESOLVED 2026-08-17, pin 42a4cc445d, and it
landed DETERMINISTIC rather than as the wall-clock report this entry
originally asked for. `mentl query <file> "cost"` reports modules linked,
source lines processed and nodes minted, all graph reads. The correction
is the useful part and it generalises: a host measurement can only ever
be REPORTED, because it varies per run; a graph fact can be RATCHETED.
So the facet immediately bought a contract a timer never could — the
frontier's prelude-floor leg, holding a bare program's 6,304 source
lines under a ceiling that may only fall. The wall-clock half stays
unbuilt and unmissed; if a run-time report is ever wanted it is a
separate, unratchetable thing and should be named as such.

`Hβ.query.cost-facet` (original text) — a verb reports no cost, so every timing of one is
a scaffold read. Found 2026-08-17 by the mentl-first hook refusing a
`/usr/bin/time mentl check` and having no projection to offer instead,
which is the hook working: the absence IS the finding. The march already
proves the shape — its m3 leg prints `cost: 15.78s wall · 2249MB peak
RSS`, read from the artifact at the moment it ran — so this is that line
generalized to any invocation, not a new mechanism. It belongs with the
gradient (arm 7): a cost is a fact the medium holds about its own run and
currently discards, which is why `Hβ.gate.sweep-rederives-the-prelude`
above is measured entirely in `/usr/bin/time` numbers this file has to
transcribe by hand — the exact hand-copy the census law forbids
everywhere else. Retires the last external timer in the loop's tooling.

`Hβ.gate.sweep-rederives-the-prelude` — MEASURED 2026-08-17, after Morgan
asked why a frontier sweep does not take two minutes. It takes 4:57.64
for 368 legs over 149 compiler spawns, at 99% CPU on ONE core, 257s of
it user time — so it is real work, uniformly spread, not a few legs
waiting on something.
THE COST IS NOT INSTANTIATION AND IT IS NOT CONCURRENCY. Two timings
decide it: the same wheel on a bare stdin fixture with NO lib linked
runs in 0.040s; on a manifest-linked fixture it runs in 0.754s. Module
instantiation plus a genuine compile is 40ms. The other ~715ms — 95% —
is RE-DERIVING THE PRELUDE, and the sweep pays it 149 times before
looking at a five-line fixture. §8's measurement that the JIT is ~20ms
already said instantiation was not the cost; this says what is.
THE PARALLELISM PLAN IS RETRACTED, and it was mine, given to Morgan one
turn before this measurement. Running 149 redundant derivations eight at
a time hides the waste behind cores instead of deleting it — the fix
direction the Carried-Truth Law forbids. It also carried a real hazard:
`pass()`/`fail()` increment shell counters in the CURRENT shell across
2707 inline lines, so backgrounding a leg loses its increment and the
gate reports fewer legs while still printing 0 red. An arbiter that
silently under-reports is worse than a slow one.
THE NAMED FIX ALREADY EXISTS: `Hβ.persist.module-image-cache` (band O) —
the derived graph image persisted and reloaded, keyed by source hash
plus transitive dep hashes, which is §4④'s persist-as-memcpy applied to
exactly this. One derivation, 149 loads. The resident session
(`mentl session`) is the same fact at session scope, and this gate has
legs TESTING that capability while not using it, which is the sharpest
form of the finding.
WHAT NOT TO DO: narrow the sweep. Gating legs on which directory changed
was proposed and refused the same day (the loop's speed clause); the
sweep's coverage is not the problem, its re-derivation is.
NARROWED TWICE MORE, and the fix got much smaller than an image cache.
FIRST: the cost is a FIXED FLOOR, not a function of the program.
`fn main() = 7` with NO imports costs 0.71s; adding math makes it
0.78s; adding io + math + dsp/signal makes it 0.95s. So ~0.71s is paid by
every invocation regardless of what the program references, and
149 × 0.71 ≈ 106s of the sweep's 257s CPU is one prelude derived 149
times.
SECOND: it is not inference. `mentl fmt` parses and renders WITHOUT
inferring and costs 0.74s on the same fixture — indistinguishable from
`check`'s 0.72s. The floor is entirely pre-inference, and the same wheel
on the same program through STDIN (no lib linked) is 0.040s. The
difference is one thing: the path form auto-links and PARSES THE PRELUDE.
SO THE FIX IS NOT AN IMAGE CACHE FIRST — it is the law the wheel already
landed, applied one layer up. `Hβ.lower.lowering-is-a-column`'s
construction-is-reachability arc made emission demand-driven: a name
popping from the frontier CONSTRUCTS its decl, and a dead decl never
constructs at all. THE LINK NEVER GOT THAT LAW. It parses the whole
prelude eagerly and then discovers the program wanted none of it, which
is the same two-pass shape that arc deleted from lower — every decl
built up front, then a second pass asking which mattered. Demand-load
the link and `fn main() = 7` parses nothing; the image cache becomes an
optimisation on top of a floor that is already near zero, rather than a
way to memoise work that should never happen.
The peer's name stays `Hβ.persist.module-image-cache` for the caching
half; this half is `Hβ.driver.link-is-reachability` and it is the one to
build first.
THE HEADER-SCAN PREREQUISITE IS KILLED, AND THE PEER SURVIVES IT
(2026-08-17, pin b50cdd0c55). This design named "a name-to-decl index
over the prelude that does not parse bodies — a header scan" as what
demand-linking wants, on the theory that parsing the prelude was the
cost. The dep walk's own discovery parse was the cheapest place to test
that theory, because it built a full AST per module and dropped it — the
carried truth re-derived — so deleting it was owed regardless. It was
deleted (`import_edges` reads the import edges from the token stream;
LEDGER carries the mechanics). THE TIME DID NOT MOVE: 0.74s against the
0.71s baseline, three reads, flat. So the floor is not parse-dominated.
Read with the fmt measurement above — floor is pre-inference — the
remaining candidates are the LEX and the file read of the five seeded
modules, and neither has been isolated yet.
What this kills is only the PREREQUISITE, not the peer. A header scan
existed to learn names without paying for a parse; parse is not what is
being paid, so nothing is owed to avoid it, and decl-level demand can
sit at the JUDGE stage where every decl name is already in hand from a
parse that happens anyway. What the peer still promises is untouched and
is now the whole of it: a demanded module is READ, LEXED, PARSED and
JUDGED, and an undemanded one is none of those — which is exactly the
cost the seed pays five times for `fn main() = 7`.
THE PROBE RAN (2026-08-17, pin ef57c6e6a6) and the floor is the LEX.
Sharpened from its banked form, which would have collapsed the DAG
instead of isolating anything: the DAG was held IDENTICAL (the prelude's
four runtime imports supplied as a literal) and only the discovery
read+lex removed. 0.46s against 0.74s — the discovery pass is 0.28s,
38% of the floor. Five small files cannot be 0.28s of I/O, so that is
lex, and the judging pass lexes the same bytes AGAIN after concatenating
the sources. THE FLOOR IS ONE LEX PERFORMED TWICE.
WHAT THE FIRST FIX GOT WRONG, recorded because the shape recurs: the
landing that followed carried the SOURCE through the DAG element, which
deletes the second READ, three path re-resolutions and one re-lex — all
real re-derivations — and measured 0.74s → 0.78s, a 5% REGRESSION over
five settled reads. The deleted read was warm in page cache; the probe's
0.28s was the COLD first pass. Deleting the cheap copy of a doubled
operation while keeping the expensive one buys nothing and costs
whatever the new carrier costs. The regression is not isolated to a
cause and is not claimed to be understood.
THE STAMP, priced by the first PROFILE of this arc (2026-08-17, pin
42a4cc445d). Five elimination probes each indicted and then cleared a
suspect — the discovery parse, the second read, a whole-program lex, the
import fold's shape, and inference (`fmt` 0.833s ≈ `check` 0.780s on the
floor fixture, re-confirming the older reading). Elimination failed
because THERE IS NO HOT SPOT, which only the instrument PLAN §8 names
could show. `perf` with `--profile=perfmap`, 1,778 samples on the floor
fixture: 77.9% guest, and the guest profile is FLAT — the top fourteen
functions sum to ~22%. What composes it is the finding:
`list_index_unchecked` 7.05% · `list_filled_from` 3.34% · `alloc` 2.49% ·
`list_set` 2.20% · `list_index` 1.34% — 16.4% in LIST ACCESS AND
ALLOCATION, spread across lexing, parsing and judging alike, with the
hottest function's own callers split between `crc_scan` (1.73%),
`lex_from` (1.18%) and `scan_to_eol` (1.06%). String comparison — the
`Hβ.perf.name-is-handle` target — is only 2.0% (`str_eq_loop` 0.78,
`str_eq` 0.69, `str_hash_loop` 0.52), which prices that peer far lower
than the §5.O text assumes and is worth knowing before it is built.
SEMANTICS TRACED: today `driver_collect_dag` collects every module, the
compile fold concatenates their whole sources, and the result is parsed
and judged entire. The target seeds reachability from the ENTRY's free
names and takes the transitive decl closure, so an undemanded prelude
decl is never parsed or judged. A missed name is LOUD, not silent —
E_MissingVariable is an armed class — which is what makes the change
safe to attempt at all.
COSTS PRICED: the floor is 6,304 source lines and 67,453 nodes for a
ONE-DECLARATION program, cost is linear in lines (~150µs, eight entries,
N=6..54), and the profile is flat. Those three together say the saving
is PROPORTIONAL to lines skipped and there is no pass to special-case:
skip 90% of the prelude and ~90% of 0.78s goes. Nothing else in the
profile offers that, which is why this peer outranks the representation
work and the handle interning both.
WRITERS ENUMERATED: `driver_collect_visit` (the DAG element),
`driver_entry_with_ranges`'s compile fold (the concatenation),
`driver_check_entry`'s per-module loop, and `driver_tree_scan`.
THE SUGAR SET IS MEASURED (2026-08-17, pin e7c2da624b): 44 names, read
off the artifact as the quoted literals in the lowering, the wasm
backend, the parser, infer and pipeline, intersected against what lib
publishes. The lowering and backend hold 28; parser and infer add 16
more, including `delay`, `not`, `concat`, `last`, `drop_last`,
`byte_at`/`byte_len`, `str_of_buf`, `str_payload` and the float-render
family. THE LOWER BOUND IS NOW A COMPLETE SET (2026-08-17, same day). The
worry was that a name assembled by splicing a fold_sig would never
appear as a literal. The splices were enumerated instead of assumed —
55 across the lowering, the backend and infer — and every one is
compiler-SYNTHESIZED: `__hstate_{h}`, `__fb_prev_{h}`,
`__fanout_spawn_{i}_{h}`, `lambda_{n}`, `compose_{side}_{h}`,
`hash_{fold_sig}`, `tuple_{int_to_str(h)}`, naming WASM locals, globals
and generated functions the compiler emits itself, never a call into
lib/. Of forty distinct spliced prefixes only `tuple_` shares a
namespace with a prelude decl (tuple_get / tuple_set), and its splice is
`tuple_{handle}`, which produces `tuple_1234` and never `tuple_get`. So
the literal scan sees the whole vocabulary and the seed is COMPLETE.
`Hβ.query.desugar-introduced-names` survives as the projection that
would make this a graph read rather than a scan — worth building for the
self-build ratchet, no longer load-bearing for the demand-link.
THE SET IS NOW A GATE: verify holds `desugar_vocabulary: 43` exact, so a
name entering or leaving the vocabulary refuses until the seed is
reconsidered (seen RED at 43 → 44). Its limits are measured and stated
at the check itself: set membership cannot see one corrupted mint among
several of a name, and an outright prelude rename breaks the wheel's own
compile first. The enumeration's first find was
`str_literal_5`, an identity function carrying a name-keyed type-checker
special case and a comment naming the deleted bootstrap; it is gone.
THE SUPERSEDED TEXT, kept because it states the risk correctly: the
SUGAR SET — prelude names the desugar introduces that the
source never writes (`++` → seq_concat, `xs[i]` → list_index, `<~` →
FeedbackSpec, interpolation → to_string, and every `fold_sig`-generated
leaf). Reachability seeded from written names alone would miss them.
They are finite and enumerable from lower's own dispatch sites, and each
miss is a loud refusal rather than a silent wrong, but the set must be
READ OFF THE ARTIFACT and not guessed. That enumeration is the next
step, and it is a measurement, not a design choice.
THE RATCHET THAT WILL MEASURE THE LANDING ALREADY EXISTS: the frontier's
prelude-floor leg, holding tests/frontier/mn-bare-floor.mn at 6,304
lines under a 6,400 ceiling, monotone down.

THE TOKEN-CARRY DESIGN IS KILLED TOO (2026-08-17, pin d74ba9612f), by
the cheapest test available: `infer_program_converged` lexed the whole
concatenated program TWICE (`src |> frontend` at both the trial and the
final), so one lex was deletable with no span re-basing and no DAG
change at all. It was deleted — the two parses stay, the final's fresh
generation being what `pstart` reads — and the fixture moved 0.00s.
Seven settled reads, 0.78s median, unchanged. LEX IS NOT THE FLOOR, so
carrying tokens to avoid a lex would have bought nothing and paid the
whole span-re-basing DEP for it.
WHAT THE FLOOR ACTUALLY IS, measured the same day: TRAVERSING the
tokens. A probe replacing `import_edges`' body with a literal list
measured 0.50s against 0.78s — the entire 0.28s. Rewriting the
traversal as a position recursion, which allocates on the four import
hits instead of a product per token, measured IDENTICAL, so it is not
the fold, the tuple, or the indirect call. It is roughly 11µs per token
over ~25k tokens, and at that rate the cost belongs to the substrate's
per-element traversal, not to imports — which would make it a tax on
the PARSER too, since the parser walks the same stream the same way.
NAMED NEXT PROBE, and nothing gets built on this until it runs: price
per-token traversal DIRECTLY. A micro that walks N tokens doing nothing
but reading each kind, timed at two sizes, answers whether the cost is
linear-but-expensive or quadratic-and-hiding. Linear says the constant
is the target (`Hβ.perf.name-is-handle` reaches it: a token carrying an
interned handle compares by word). Quadratic says a list op in the walk
is not O(1) despite `len` being `load_i32`, and THAT is the find, in
the class §5.O already names — `iterate_from`'s snoc-list `list_index`.
SECOND MEASUREMENT OWED at the same time, because it may dwarf both:
`mentl check` runs `driver_check_entry`, which after the DAG walk calls
`driver_check_module` per module — each one a full
`infer_program_converged`, so two parses and two judgments of every
prelude module, and then the entry again. Count the compiles per
invocation before optimising any single one of them.
ISOLATED TO ONE LINE, single-variable (2026-08-17). Same wheel, same
harness, same program, same path form; the only thing varied is whether
`driver_collect_dag`'s prelude seed can resolve. With the mentl-home
mapping: 0.71s. Without it: 0.03s. THE SEED IS THE WHOLE FLOOR — 0.68 of
0.71s — and 149 × 0.68 ≈ 101s of the sweep's 257s CPU.
TWO EARLIER READINGS WERE CONFOUNDED and are corrected here. The first
compared a DIRECT wasmtime invocation (stdin, 0.03s) against the SHIM
(path, 0.71s) — two harnesses, not two link paths. Re-measured on one
harness, the shim costs nothing (direct-path 0.72s, shim-path 0.72s), so
the conclusion survived the confound but the reasoning had not earned it.
The second ran from a lib-less directory expecting the seed to skip; it
did not, because MENTL_HOME still resolved, and the flat 0.75s there
proved nothing either way. Removing the resolution ROOT is what isolates
it.
WRITERS ENUMERATED: one — `driver_collect_dag` (driver.mn:97), which
seeds `"prelude"` before the entry whenever `fs_exists` finds it, and the
DAG then collects and parses prelude plus its whole transitive runtime
floor. The seed is load-bearing for CORRECTNESS and its comment says why:
every module speaks the prelude's vocabulary (map / fold / Option /
FeedbackSpec) with no import line, and without the seed a compile emits a
module that cannot assemble. So the fix may not delete the seed; it must
make it demand-driven.
THE DESIGN, and it is the arc the wheel already ran one layer down: parse
the ENTRY first (0.03s buys it), take its free-name set, and pull only
the prelude decls that provide those names, transitively. That needs a
name→decl index over the prelude that does NOT require parsing bodies —
a header-only scan — which is the same shape as lower's demand worklist
where a name popping from the frontier constructs its decl. The retry-on-
miss alternative (link bare, re-link on E_MissingVariable) is rejected:
it would halve the cost for programs using nothing and DOUBLE it for
every program that touches the prelude, which is most of the sweep.
`Hβ.march.boot-drifts-behind-clean-landings` — NAMED 2026-08-17, found by
a repin rather than by a gate, which is the whole point. Every gate in
the frontier's boot suite reads the PINNED BOOT. A landing whose march
verdict is CLEAN (`m2 == m3`) needs no repin to be correct, so several
landed without one — the statement-span/dispatcher-mint arc, the cursor
declaration projection, the skip_ws_back dissolution — and boot sat at
`5fe06c92` while source moved past it. The boot suite went on reporting
`frontier 367/0` about a wheel four landings old. When the feedback-row
fix finally forced a repin, FOUR legs fell over at once: own-unconsumed,
and three MCP/session legs. Reverting the pin restored 367/0 with the
old boot, which is the proof the reds were the accumulated arc arriving,
not the row join.
ONE IS ALREADY DERIVED. own-unconsumed asserts `T_OwnUnconsumed … at
10:4`; the narration now reports `10:1-10:23`, the whole `fn drops(own
buf) = 42`. The cause is the dispatcher mint: `parse_fn` was called with
`pos + 1` and started a declaration's span at its NAME, while
`parse_stmt` mints from `pos` and starts it at the `fn` KEYWORD. The new
span is the more truthful one — a declaration's span is the declaration
— so the banked `10:4` is the old era's narrower value and re-banks to
`10:1`, per §9.11's law that a banked expectation is a hypothesis about
the era that banked it. THE OTHER THREE ARE NOT DERIVED and must not be
re-banked by analogy: `mcp refusal verdict`, `resident session
(resident-lines=1)` and `living session (moved=1)` are session/transport
legs, not span assertions, and nothing yet says the span change is even
their cause.
THE SHAPE IS §11 TRIPWIRE 4 IN A NEW COSTUME — there, a gate stopped
being reported and so stopped being run; here a gate kept being reported
GREEN while measuring a stale artifact, which is worse because it reads
as evidence. The standing counter-measure to design: a CLEAN verdict
must not license leaving boot behind, or the boot suite's green means
only "the old wheel still passes".
RESOLVED 2026-08-17, both halves. The four were derived and re-banked
under §9.11 (all one cause — the dispatcher mint moving a declaration's
span start from its NAME to its `fn` KEYWORD; the mcp fixtures contain
no `<~`, which exonerated the row join in one read), and the standing
COUNTER-MEASURE is now armed in verify: PIN FRESHNESS. boot IS the
pinned fixpoint, so when it matches current source
`sha256(boot(wheel)) == sha256(boot)` — the m2 the gate just built is
the boot binary again. Divergence IS the drift, exactly, and a
comment-only change correctly reports none because it emits identically.
IT REPORTS AND DOES NOT REFUSE, deliberately: a CLEAN `m2 == m3`
landing is correct and genuinely needs no repin, so drift is legitimate
and hard-failing it would force a 2.4MB boot binary into git per
emit-changing landing. What was never legitimate was drift staying
INVISIBLE. The one line makes the boot suite's verdict say which wheel
it is a verdict about. Both branches seen: FRESH on the caught-up pin,
and BEHIND when forced against another artifact — and the real
divergence was already measured the iteration before, boot `5fe06c92`
against an m2 that produced `011f0eefbf`.
THE PROBE THIS ENTRY BANKED WAS ITSELF WRONG, worth recording: it said
"repin, then derive". `frontier-gate.sh --compiler fresh` shows the same
reds against current source without touching boot, so the previous
iteration's pin-revert was unnecessary work. The instrument existed; the
probe did not know it.

`Hβ.effects.feedback-row-substitutes` — THE DROP HALF IS FIXED
(2026-08-17, unpinned): `inf_add_row(lam_row)` at the `PFeedback` arm of
`infer_pipe`, where the recurrence lambda's row went to `_row` and was
discarded. Measured through a fresh m2: the negation crucible refuses
where it laundered, `m2 == m3` holds, census 0, and the census the stamp
told me to measure rather than assume came back ZERO — the wheel's own
sixteen `<~` sites absorbed the join without one new diagnostic, so that
prediction was wrong in the cheap direction. THE GATE IS NOT WIRED YET:
tests/frontier/mn-feedback-negation.mn passes only against a wheel
carrying the fix, and the frontier suite reads the pinned boot, so the
leg waits on the repin that `Hβ.march.boot-drifts-behind-clean-landings`
now gates. The ADD half (a `<~` cycle refusing under `!Alloc` because
`Delay(N)` is an ordinary constructor call) is untouched and still
named above.
THE ADD IS A FALSE CHARGE — probed 2026-08-17 and the probe VINDICATED
the doc. Emit's `LFeedback` arm destructures the lowered spec as `_spec`
and discards it; the compiled WAT for a `Delay(N)` recurrence contains
ZERO construction of it across 1553 lines, and the prior rides a
declared global `$__fb_prev_<h>`. So the slots are declared and never
allocated exactly as SYNTAX said, the earlier "untested rather than
refuted" hedge resolves in the doc's favour, and what charges `Alloc` is
`infer_expr` walking the RHS as an ordinary constructor call at a site
whose only load-bearing content — the depth — is read statically by
`feedback_line_depth`. The value is lowered, walked by the pre-passes,
and dropped at emit: dead machinery by the loop's own definition.
A GENUINE FORK, AND IT IS MORGAN'S (step 3: bank both branches priced,
take the next independent item, never answer above the loop's station).
The surface and the emit disagree about what a `<~` RHS IS.
  A · IT STAYS A VALUE, as SYNTAX §«`<~`» says ("The RHS names WHAT
  flows back — a FeedbackSpec value — and is checked as one"). The fix
  is then narrow: the `<~` arm stops charging the RHS's construction,
  and `!Alloc` survives a cycle. Price: one infer site; the surface is
  unchanged; the lowering and its dead emit stay, so the machinery that
  builds a value nobody reads remains, and `accumulate`/`filter_spec`
  keep a uniform value-shaped grammar.
  B · IT BECOMES A STATIC DEPTH ANNOTATION, which is what emit already
  treats it as. Price: SYNTAX changes (the RHS is not an expression),
  `lower_expr(right)` and the four pre-pass walks over `s` delete, the
  charge disappears with the construction rather than by suppression,
  and the depth read has one home instead of a value plus a static
  peek. Cost: the grammar gains a non-expression slot — the thing
  §«Governing principles» spends effort avoiding — and every
  state-element form (`delay`, `accumulate`, `filter_spec`, any
  user-defined register) has to fit it.
B is the smaller artifact and the larger surface change; A is the
reverse. The measurement cannot choose between them, which is why it is
a fork and not a finding.

`Hβ.effects.feedback-row-substitutes` — NAMED 2026-08-17 by the loop
iteration that set out to PIN the feedback-under-negation modal rule
(§11 6.3's own named next rule, unblocked when 3.6 built) and instead
measured the rule UNSOUND. The `<~` site does not JOIN the recurrence
body's row; it substitutes its own, and the substitution errs in both
directions at once. Repros stand at
tests/frontier/mn-feedback-negation.mn and
tests/frontier/mn-feedback-transport.mn — written as the crucible pair,
kept as evidence, and deliberately NOT wired to a frontier leg, because
a leg asserting either measured behaviour would canonize the bug.
DROPPED: a forbidden effect performed inside the recurrence body does
not reach the enclosing row, so `fn cycle() with !E` containing
`((prev) => prev + bump()) <~ Delay(1)` CHECKS CLEAN and reports only
`T_OverDeclared … body only uses Memory + Alloc`. That is an `!E`
soundness hole at the feedback carrier — the crown's own class. The
control isolates it to `<~` alone: the same op called directly refuses,
and the same lambda passed through `fn apply(f) = f(1.0)` and called
refuses, both with E_EffectMismatch, so lambda-row propagation is
healthy everywhere else.
ADDED: `<~ Delay(3)` reaches `Memory + Alloc`, so `fn cycle() with
!Alloc` around it REFUSES. Isolated by a second control — the identical
lambda and comparison with the `<~` removed judges `Pure`, so the
allocation is the feedback site's, not the closure's.
THE DOC CLAIM IS REFUTED and trued in the same landing: SYNTAX §«`<~` —
feedback» stated that a delay line's slots are "declared, never
allocated, so depth costs nothing per tick and the `!Alloc` row survives
at any N". The artifact denies it at N=3.
THE KILL: this iteration's leading theory was that `<~` is pure topology
whose negation survives the cycle while the body's own effects still
charge — the shape every other carrier in the 6.3 sweep holds (field,
list element, tuple position). Both halves measured the opposite way
round. The rule cannot be pinned until the row at the `<~` edge is the
JOIN of the body's row with the site's own, which is where the fix
belongs — one edge, one writer.

STAMP (2026-08-17, the following iteration). SEMANTICS TRACED: the one
writer is the `PFeedback` arm of `infer_pipe` in infer.mn. It binds the
site's TYPE — the recurrence result, or the LHS var for the
feed-forward form — unifies the RHS with `FeedbackSpec`, and reads the
declared depth for the two armed refusals. It composes NO ROW anywhere.
The drop has a single visible cause: the arm destructures the LHS
lambda as `GNode(NBound(TFun(params, ret_ty, _row)), _)` and the row
goes to `_row`. The graph proves the body performs E and the edge
discards it — the Carried-Truth Law in one underscore.
WRITERS ENUMERATED: that arm alone. `infer_expr(left)` and
`infer_expr(right)` run first and charge ambiently, which is why the
enclosing row still shows `Memory + Alloc` and not the lambda's E.
THE ADD IS A DIFFERENT MECHANISM, and it does not refute SYNTAX's
declared-slots half: lower.mn's `PFeedback` arm lowers the RHS through
`lower_expr` as an ORDINARY EXPRESSION while taking the depth
STATICALLY via `feedback_line_depth`, so `Delay(3)` is a real
constructor call that really allocates, and its only load-bearing
content is read at compile time. Whether the constructed value is then
dead at emit is UNVERIFIED here — the emit's `LFeedback` arm decides
it, and that read is the next probe.
COSTS PRICED: the fix is joining the lambda's row where `_row` is
discarded. Rows are a judgment fact, not emitted, so the expected
verdict is CLEAN `m2 == m3` — but the price that matters is not the
emit. The wheel's own sixteen `<~` sites currently pass under rows
computed WITHOUT their bodies' effects; joining will widen them, so the
honest expectation is new `T_OverDeclared` narrations and possibly
`E_EffectMismatch` against declared clauses in lib/dsp. That is a
census/ratchet risk to MEASURE before the fix, not assume — build the
join, run the census, and let the count decide whether the landing is
the join alone or the join plus the widenings it forces.
TWO SECONDARY FINDINGS, both from the trace. (1) `Hβ.query.destructure-
sites` — the `refs of` facet projects constructor APPLICATIONS only, so
`refs of PFeedback` answered "1 reference" (the parser's mint) while
infer and lower both destructure it. The trace nearly banked "infer
never sees PFeedback" on that reading; "who pattern-matches this
constructor" has no projection, and the raw text channel is the only
answer today. (2) RETRACTED 2026-08-17, by reading the detector it accused. The claim
here was that the underscore-retain census shape is blind, sitting at a
ratcheted ZERO while `_row` discarded a proven fact. It is not blind:
`CsUnderscoreRetain` IS drift mode 15 with a precise definition — a LET
whose binder keeps a leading underscore, an unused value renamed instead
of deleted — and it correctly reports zero because the wheel has no such
let. A destructure-position `_name` is a DIFFERENT shape, and the
extension that suggested itself is dead too: 293 underscore-named
binders sit in destructure position across src/ (722 underscore-named
identifiers overall), and they are overwhelmingly correct — naming a
field `_spec` or `_h` documents what is being skipped and reads BETTER
than a bare `_`. A shape firing 293 times on good code is a convention,
not a drift.
WHAT THE `_row` BUG ACTUALLY WAS: not "an underscore appeared" but "this
consumer needed that fact and dropped it" — semantic, undecidable by any
name-shape detector, and provably so by those 293. The class belongs to
`Hβ.audit.carried-truth-projection`, which decides it the only way it
can be decided: by reading whether the GRAPH PROVES a fact the consumer
then failed to use. That is the audit's whole reason to exist, and this
is a worked instance of why a text detector cannot stand in for it.

`Hβ.parser.statement-span-at-dispatch` — NAMED 2026-08-16 at Morgan's
question, "is a helper a band-aid or ultimate design at the foundational
level?" It was a band-aid. `nstmt(stmt, span)` takes the extent as an
ARGUMENT, so all nineteen mint sites in the parser each get to remember
it, and the `type` family's eight all passed the `type` keyword's own
token instead of the declaration's — which is why a `type` node could
never be the widest on its own line. A helper that makes the right span
easier to pass leaves the wrong one sayable; the fix is that no site
passes one. THE TYPE FAMILY IS CONVERTED: `parse_type_decl` returns its
`Stmt` and `parse_stmt` mints, because the dispatcher is the only thing
holding both ends — it has the opening token and receives the closing
index. Eight span arguments deleted, one gained. RESOLVED THE SAME DAY
for EVERY statement kind: `parse_stmt` split into DISPATCH
(`parse_stmt_form`, returning a `Stmt` per kind and never a span) and
MINT (one site, stamping `span_through` from the opening token to the
closing index). Fn, let, effect, handler, import and the bare-expression
form all converted; the four `LetStmt` mints that are DESUGAR sites
(nested fn, destructure prepend-let) keep their own spans, since they are
not statements the dispatcher opened. One mint site now, where there were
nineteen chances to remember, and FnStmt's `span_join(start, body_span)`
— right only because someone remembered — is gone with the rest. Two
bugs surfaced and closed on the way: the closing index sits one PAST the
declaration and the predicate / variant / row paths all return past a
`TNewline`, so the join reached the next line and `source_slice` rendered
a single `t` (`span_last` walks back over layout); and `source_slice`
itself destructured `Span(sl, sc, _, ec)`, discarding the END LINE and
using `ec` as an offset into the START line, so a multi-line `handler
counter { … }` rendered its closing brace's column as a two-character
`ha` — pre-existing, and invisible for as long as every declaration span
was one token wide. The DEEPER form still gated: derive the
extent from the statement's own constituents rather than from token
indices at all — blocked because `Ty` carries no span, so
`AliasStmt(name, TInt)` has no spanned constituent to join through. That
is the AST-in-graph fabric stopping at the type level, and it is the
real root under both.

`Hβ.cursor.eight-arms-at-every-site` — NAMED 2026-08-16, measured with
a probe carrying one site per arm (the eight-arm fixture: refinement
alias, repr pin, effect + handler + resume, own/ref params, a declared
row, and all five verbs; it checks clean, so the SURFACE carries all
eight). PLAN §2's claim is that the eight ARE the aspects of one
cursor-read. The read is rich at a FUNCTION declaration and silent at
three of the arms' own authoring sites. Measured verbatim: at
`fn amplify(own x: Float, k: Coeff) -> Float with !Alloc` the cursor
projects five arms (type, `Effects:`, `Ownership:`, `Teach:`, `Why:`);
at `handler counter with n = 0 {` it projects `counter : t24295@e21654`
with `Why: placeholder`, and at the arm `tick() => resume(n) with n =
n + 1` it projects `resume( : t24294@e3` — an unresolved type variable,
no row, and no resume-cardinality badge, at the single most
handler-dense site there is; at `type Gain = Float where self >= 0.0
&& self <= 1.0` and at `type Coeff = Float repr f64` it projects
NOTHING but `placeholder at 3533:0-3576:0`. So arm 2 (handler + typed
resume), arm 6 (refinement) and arm 7 (gradient) cannot be read where a
developer authors them, which is PLAN §0 pt 5 — systems explain
themselves — failing at three of eight.
RESOLVED 2026-08-16, two roots, and the dig cost two retracted decodes
worth recording. Root one, RENDERING: only `NStmt(FnStmt)` read its
scheme from the env and every other declaration kind fell to
`show_type(ty_of_kind(...))` — the raw t-var the fn's own header
comment forbids. Arms for Refine / Alias / TypeDef / EffectDecl /
HandlerDecl / RowAlias now read each declaration's own node. Root two,
THE SPAN: every `type` form minted with the bare `start` span (the
`type` token alone) while FnStmt has always minted `span_join(start,
body_span)`, and the address resolver's line-mode rule is "the WIDEST
node starting on this line" — so a keyword-wide decl node could never
win its own line, and `type Gain = Float where self >= 0.0 && self <=
1.0` resolved to its own PREDICATE sub-expression. `span_through` joins
each declaration through its last consumed token; case A keys on the
START line, so a multi-line declaration still competes only on its
opening line. Measured after: `Gain = Float where 0.0 <= self && self
<= 1.0`, `Coeff = Float repr f64`, `effect Tick — 1 op(s)`, `handler
counter — 1 arm(s), 1 state field(s)`. Arms 2, 6 and 7 read at their
own authoring sites.
TWO KILLS, both mine, both from mis-located coordinates: "the type
declarations project NOTHING" was probing lines 14 and 16 of the
fixture, which are the BLANK LINES between the declarations (the module
placeholder is the correct answer for a blank line), and the
"address→node resolution gap" banked on top of it was a hypothesis
built on that mis-read, refuted by a four-form control probe in which
every `type` kind resolved. The rule the session paid for twice: read
the line numbers off the artifact before the claim, not off the
arithmetic.
One sub-finding rides it: the
placeholder spans are LINK coordinates, not file coordinates
(`Hβ.query.decl-site-file-coordinates` confirmed live a third time),
and `mentl where` answers empty for any name outside its three badge
families (repr width, resume cardinality, fanout schedule), which is
correct for `where` and is why the ADDRESS form is the one that must
carry all eight. The fix direction is the type-decl and handler-decl
nodes reaching the same projection the fn-decl node already reaches;
the aspects exist (audit projects rows, teach projects the gradient,
proof-exactness projects obligations) and are simply not joined at
those two node kinds. Sequenced with Phase 11.2's `mentl edit` polish,
and it is the cheapest real gain in the felt band: three arms, one
projection each.

`Hβ.emit.under-application-suspension` — **RESOLVED 2026-08-18**, pin
bb317fe4ec6a, and the fix was one condition because the whole mint was
already built. `partial_unfilled` required an AUTHORED `??` before it
would treat a call as a hole-product; a bare positional prefix fell
through to the direct-call emit. Meanwhile `partial_split` had always
turned a slot past the supplied args into a param — its own comment says
"or a hole-adjacent short tail" — so the machinery the prefix form needed
was sitting behind a decider that refused to reach it. The decider now
reads ARITY: short of the declared params → partial, saturated with an
authored hole → partial (the `add(??, 41)` form, correct throughout),
over-applied → unchanged.
THE STATED REASON FOR THE MARKER dissolved on inspection rather than
being overridden. It was that a recovered callee's TFun arity is a guess
under productive-under-error — true, and already answered ONE LAYER
DOWN: `partial_callee_form` admits only a resolved FnScheme or
ConstructorScheme and `lower_call_partial` floors everything else typed
(LInvariantFailure/PartialCalleeShape), so a guessed arity reaches a
floor, never a wrong call. Measured beside it: an unresolvable callee
raises E_MissingVariable, an armed class, and `mentl compile` on that
program writes a ZERO-BYTE wat — there is no module to collapse. The
`??` requirement was a second, redundant guard, and the redundancy was
the defect.
MEASURED AFTER, all previously broken or absent: `add(1)(41)` → 42,
`let inc = add(1); inc(41)` → 42, `c3(10)` then `f(30, 2)` → 42,
`c3(10, 30)` then `f(2)` → 42, `Pair(42)` then `mk(7)` → 42. The
controls held: `add(??, 41)(1)` → 42 and `5 |> add(37)` → 42. CLEAN,
m2 == m3, census 0. Gate: tests/syntax/partial-prefix-application.mn,
seen RED as `type mismatch in call, expected [i32, i32, i32] but got
[i32, i32]`.
THE ONE OPEN FACE is the LOCAL callee — `let g = (a, b) => a + b; g(1)`
still exits 134, which is `partial_callee_form` returning None and the
typed floor firing, loudly and by contract. That is
`Hβ.lower.partial-local-callee`, unchanged by this landing except that
it is now the only unlit face of the family. Its honest gap is that a
floor is a bare trap where a diagnostic belongs: the medium knows the
callee is a local closure and can say so.

`Hβ.infer.mixed-positional-labeled-call` — **RETRACTED 2026-08-18, the
day after it was named.** Six shapes measured clean the next iteration:
two-param all-labeled, mixed, all-positional; three-param mixed (SYNTAX's
own worked example), defaulted-trailing, and label-skips-over. The mixed
form has never been broken. The original probe used `fn spawn(...)` and
the diagnostic was true — about a DIFFERENT `spawn`. Retracted per the
verified-only law; what it was actually seeing is the entry below.

`Hβ.infer.fn-shadows-a-linked-effect-op` — **RESOLVED 2026-08-18**, pin
62718b6e8cb3, on the third iteration and only after the probe was pointed
at a link that actually contained the collision. THE ROOT, measured: the
env is an append-only log read last-write-wins, and an effect decl
re-registers its ops AFTER the entry module's own declarations. The write
order for `spawn` under the manifest is op / fn / fn / fn / op / op — the
op last, so the user's fn loses. That is also why every reading site
failed: at the decl judgment the env still says FnScheme, at the call it
says the op, and by the time any reader looks one kind has already won.
THE SITE is `register_one_op`'s env write, where the losing fn's entry is
still present — the one place both claims on the name meet. The span comes
from the prior entry's own Reason, so the diagnostic points at the fn to
rename rather than at the library. E_FnShadowsOp is armed; wheel census 0.
THE THIRD KILL, and the one that cost the most: both earlier probes ran
through the MICRO harness, whose blob link has no lib/threading —
so `spawn` was only ever a user fn there and the collision was never in
view. `PROBE3 spawn -> FnScheme` and `225 of 225 NOT FOUND` were both
true and both about a program that did not have the defect. The gate
inherited the same trap on its first run: `run_refusal` pipes its fixture
in on stdin, which is that same blob path, so the leg went RED against a
working fix. It drives `compile <path>` now, the way a person does.
GENERAL FORM, worth more than the fix: a probe measures the LINK it was
run in, and a defect that only exists through the manifest is invisible to
every stdin-fed harness the repo owns.

`Hβ.infer.fn-shadows-a-linked-effect-op` (original text) — NAMED 2026-08-18, measured
and then twice failed to build. A user program declaring `fn spawn(a) =
42` beside lib/threading's `Thread` effect — whose ops include
`spawn`, and which a bare program links — gets NO diagnostic about the
collision. The declaration is unreachable: `spawn(7)` performs the op,
and the user's body is judged against the OP's signature, so the only
sign is `E_TypeMismatch: Int vs () -> t... with r...` pointing at their
own call. Coverage is otherwise correct and was mapped: `map`, `fold`,
`len`, `byte_at`, `str_slice`, `report`, `hash` all raise the armed
E_DuplicateFnName; `eprint_string`, `mint`, `intern_str` are simply not
in a user program's link, which is why they are silent. `spawn` is the
one that IS linked and IS silent, because it is an effect OP and the
duplicate-FN check correctly does not cover it. The class it wants is
`EHandlerStateShadowsOp` one scope out — that class exists, is armed,
and says the same thing about a handler's state field.
WHERE IT CANNOT GO, measured: `pre_register_stmt`. The obvious site —
its `None` arm, right where the fn is registered — reads
`env_lookup(name)` and gets **NOT FOUND for every name**: a probe
printed 225 lookups on one micro and not one resolved, so the env is
not a readable source of truth at that phase. The walk's own comment
says as much for a different reason ("keyed by THIS WALK's own
seen-set, never by the env" — an existing FnScheme entry may be a prior
judgment of the same tree under the incremental cursor). Two builds
went in before the probe: a class with six arms and an env read, then
the same read with the ops looked up by kind. Both marched CLEAN with
census 0 and neither fired; both were reverted whole rather than left
as a DiagKind nothing constructs.
THE BANKED PROBE RAN 2026-08-18 AND CHANGED THE DESIGN: this is not a
missing check, it is TWO RESOLUTIONS OF ONE NAME DISAGREEING. Measured,
three readings on one program (`fn spawn(a) = 42` / `fn main() =
spawn(7)`):
  · at the DECL JUDGMENT (infer.mn's FnStmt arm, where every decl
    passes) `env_lookup("spawn")` answers **FnScheme** — the user's own.
    450 FnScheme / 12 NOT FOUND across the micro corpus, so the env is
    fully readable at this phase, unlike pre-register.
  · at the CALL the same name types against `() -> t with r` — the OP's
    parameter, which is where `Int vs () -> t...` comes from.
  · in the FINAL env, `mentl query <the user's own file> "type spawn"`
    answers `(_0: () -> t with r) -> ThreadHandle with Thread(...)`.
    The projection reports the library op's signature for a name the
    file itself declares.
So the user's registration is displaced — the env ends up holding the
op, while the phase that judges the declaration still sees the fn. A
diagnostic bolted to either reading would be describing half of an
incoherence rather than the incoherence.
THE NEXT PROBE, one build: instrument `env_extend` to print whenever a
name's SchemeKind changes for an already-present name. That names the
writer and the phase exactly, and the fix goes there — either the
displacement is refused, or it is ordered and the loser is reported.
Do not add a check at a reading site before that probe runs; two such
checks have already been built and reverted on this entry (a six-arm
EFnShadowsOp class with an env read at pre_register_stmt, then the same
read by kind — both marched CLEAN with census 0, neither fired).
`group_final_publish` is NOT the site either: it handles cycle groups
only, 17 hits and `spawn` not among them.

**KILL (2026-08-18) — "the arity check belongs at infer's proven-TFun
read."** `infer_call_saturated` chases the callee to a bound TFun with
the args in hand, so both counts are present and the site looks
correct by inspection. The check was written there, marched CLEAN, and
changed nothing. An eprint at that read printed 1052 hits over the
micro corpus, eight distinct shapes, and `len(args)` never once
differed from `len(dps0)` — including for a call written with three
arguments to a two-param fn, which arrived as `cname=add args=2
dps0=2`. The surplus is dropped upstream in `fill_arg_slots`, whose
slot buffer is sized by the parameter product, so the counts are equal
by construction everywhere downstream and no judgment CAN see the
mismatch. Two sites were read and reasoned about before the probe; the
probe took one m2 build and ended it. Recorded because the shape is
general: when a check cannot fire at a site where both facts appear to
be present, the facts were reconciled earlier and the question is who
reconciled them.

`Hβ.lower.over-application-drops-surplus` — **RESOLVED 2026-08-18**, pin
9244d5d002fc, and the home was wrong in this entry's own name: the drop
is in `fill_arg_slots`/`place_positional` (src/types.mn), not in lower.
`place_positional` now reports at the overflow, at the surplus
argument's own span. Its old comment — "arity is infer's concern; drop
the overflow here" — was the whole defect written down: infer could
never make it its concern, because the drop is what made the counts
equal. The remainder is ARMING, not detection: it reports as
E_TypeMismatch, the declared code, which does not yet refuse the
executable — the name-dependent class §7 already tracks toward universal
refusal.

`Hβ.lower.over-application-drops-surplus` (original text) — NAMED 2026-08-18, measured
while proving its opposite. `fn add(a, b) = a + b` called as
`add(1, 2, 3)` checks CLEAN with zero diagnostics and runs, returning 3:
the surplus argument is evaluated and dropped. `partial_unfilled`'s own
comment has described this since it was written — "the mint's slot walk
stops at the param count and would silently drop the surplus args'
evaluation" — as the reason over-application does not take the partial
fork, which is correct, but nothing then refuses it either. A parameter
product with more fields supplied than it has is not a product; SYNTAX's
`E_UnknownArgLabel` is the labeled twin of exactly this and it refuses.
The arity is proven at the same read the prefix case now uses, one arm
over, so the refusal is available where the decider already looks. Left
unbuilt in the same landing on the one-variable law, not on difficulty.

`Hβ.emit.under-application-suspension` (original text) — NAMED 2026-08-09 (found live
by the trio-deletion landing). SYNTAX §«Partial application» promises
that under-application IS the hole-product ("when exactly one field is
a hole, it is unambiguous" — `filter(.age > 18)` is the spec's own
example, no `??`), but the lathe's emit for a bare under-applied named
call (`map(candidates_at(performed))`, one arg against a 2-param fn)
produces INVALID WAT — a 1-arg `return_call_indirect` against the
2-arg `$ft2` — instead of constructing the suspension record or
refusing with a diagnostic. wat2wasm catches it loudly at assemble
(measured: the trio landing's first march), so the class is
loud-wrong, not silent-wrong — but malformed output is never the
lathe's answer. The `??`-marked product (`candidates_at(performed,
??)`) is the PROVEN emit path (tests/frontier/
mn-partial-hole-executable.mn; the trio landing ships this form at
project_queue). The fix direction: the apply walk treats an
under-supplied product exactly as a `??`-marked one (the parse/infer
side already types suspensions; the gap is the arity-mismatch call
falling through to the direct-call emit). THE STANDING CRUCIBLE is
LIVE (2026-08-09, per Morgan's along-the-way-finds-become-crucibles
rule): tests/frontier/mn-under-application-loud.mn + its frontier leg
— green while the gap stays loud (assemble refuses), green when the
fix lands (the suspension runs, exit 42), RED only on the
silent-wrong transition (a run with any other value); tighten the leg
to 42-only when the fix lands.

`Hβ.eq.pipekind-match-eq-divergence` — RESOLVED (2026-08-07, the arc
loop's first iteration): the banked probe ran and the divergence was a
MISATTRIBUTION — there never was one. The raw-word census at
`$eq_nPipeKind`'s entry showed the `<~` pair as `a=3 b=3`, identical
sentinels, the eq answering TRUE; the count was 0 because of the walk's
NEXT read: `span_of_handle` CHASES to the union-find root, and a `<~`
node's chase lands on the continuation-boundary cell (bound with a bare
`Inferred` at `finalize_continuation_boundaries`), so the span answered
zero and the census skipped every feedback site as a synthetic mint. THE
LAW THE ROOT TEACHES: a weave walk reads a node's OWN raw facts — body
AND reason — because chasing conflates a node's identity with its
type-class representative; `span_of_node_raw` (graph_reason_at, no
chase) is the census's read now, and all six shapes count their own
sites (the frontier leg's roster gained `<~`). SIX KILLS BANKED, the
sixth being the entry's own former hypothesis: (1) lexer sound; (2)
op_prec sound; (3) kind table + builder sound; (4) the pointer-eq floor
— real and fixed via the Intent-Boundary annotations, but not this
root; (5) the mixed sentinel/boxed-nullary guard — refuted (the probe's
four heap pointers were the fixture's PFanout records, tag 1, CORRECTLY
boxed payload variants and correctly unequal; the reverted
emit_eq_leaf_sum experiment's BROKEN verdict stands as the record that
load-bearing eq semantics change only under march arbitration); (6) the
eq/match divergence itself — the eq was true, the span read was the
thief. The standing-residue face RESOLVED 2026-08-08 (pin
a37aedbadfbaf1d1): collect_ref_spans reads span_of_node_raw — the
accident-invariant retired, the facet's answers identical by law.

`Hβ.query.decl-site-file-coordinates` — a query's Reason span answers in
the linked blob's coordinates and names no file, so "where is NAME
declared, as file:line I can open" has no projection: `query src/infer.mn
"type edges_keep_completion"` answered span 704:4 while the fn lived in
src/effects.mn, and the 2026-08-06 session fell back to confessed greps
twice for exactly this. The span substrate carries the truth; the facet
is the missing rendering (per-module offsets exist the moment
`Hβ.driver.per-module-env-overlay` gives solo queries their real link
set). Named per the ⟳ law: the hand tool is a confession, and this is
its peer.

`Hβ.effects.directional-fn-row-edge` — RESOLVED at its measured scope
(2026-07-30, pin cd43c23c — the §7 entry THE QUIET FN FITS UNDER THE
CAP carries the record: the positional pre-meet at
infer_call_saturated, row_cap_form as the cap/flow boundary the
297-site census taught, the admit leg registered at frontier 324).
The remaining tail is nested variance (a fn-arg's own fn-params flip
direction again) — out of scope by the original sequencing, the
symmetric meet standing there.

`Hβ.verify.interval-fragment` — ENGINE HALF LANDED (2026-07-30, pin
a71ebbcb — the §7 entry THE INTERVAL FRAGMENT AND THE FLOW LICENCE
carries the record: the two-face lower-bound read in verify.mn, the
value_flows_class licence closing the measured arith-class launder,
the mn-verify-interval fixture + frontier leg, arm row unchanged).
THE CALLEE LEG LANDED same day (pin 5e34f710 — an authored return
rides the pre-registered TFun as a Ty VALUE, so a call's bound reads
the callee's annotation verbatim, uncontaminatable by class merging;
the wrap/base fixture faces prove it; TRANSITION m3 == m4). THE
SELF-CALL IH LANDED 2026-08-12 (pin bceed184 — the peel root dug,
named, and DELETED; march m2 == m3, census 0, movers 476 unchanged,
frontier 361/0, crown 35/0, proof-exactness 9/0): the "peel" was
never a unify arm replacing a refined representative — it was the
decl pin's ORDER plus a reader refusal, probe-named exactly. Each
judgment mints a fresh ret cell; the body-return unify links it into
the join's first-bound bare class; the decl's own obligation decides
at the constraint site and READS that bare class; the old post-body
rebind landed one statement later. The rec-call was the one caller
reading the decl's live fn_ty, whose ret slot was the one
construction still carrying the bare var (prereg's own comment names
the law: a value inside the record cannot be class-contaminated).
Fix = the assumed signature bound BEFORE the body (the authored
`-> RetTy` resolved into the decl TFun's ret slot as a VALUE, cell
still bound for grounding; the post-body pin keeps only the body's
refinement constraint; the ownership rewrite carries the same slot)
+ ty_lo chasing a TVar slot to its cell (the reader had refused
exactly the slot that held the fact). The fixture falls 2 → 1
(seek discharges via the IH; wild, the never-launders control,
still pends); the frontier interval leg seen RED at want-2 and
re-derived to want-1. EIGHT KILLS this dig, each one probe: (1) my
"the decide never type-reads a var arg" — refuted by the echo-stop
read at the accrual (apply_refinement_constraint's TAlias arm);
(2) "a let-var breaks the flow" — refuted, S2 silent; (3) "a
comparison's ground unify re-peels a BOUND refined class" — refuted
at specimen scale (S3/S5: bound-meets are check-only, the alias
survives; the 07-30 `i: Nat` re-peel was the free-var FIRST-BIND
order, not a rebind of a bound class); (4) "destructure peels" —
refuted, S6/S7 silent through tuple and Option payloads; (5) the
WARM INSTRUMENT ITSELF — the shim's warm image SUPPRESSES
re-derived obligations (ladder warm: 1 pending line; cold: 8 — S10/
S12/S13/S14's warm silence was the instrument lying; peel probes
run COLD, always); (6) my "prereg + ret pin leave the rec-chase
refined" — refuted by the probe compiler (the fresh final ret cell
read unbound then NBound(TInt) at the two decides, with the pin's
own print proving the rebind ran after both); (7) the banked fix
direction "most-refined representative at EVERY unify" — SUPERSEDED
by the sharper root: the representative law was already written at
both pins, the defect was order + reader, and an every-unify
upgrade WITHOUT inverting the call site's unify-then-discharge
order (infer_call_saturated unifies at the top, discharges after)
would let the upgrade plant the annotation the echo-stop then reads
— S9 measures that order accident today as silent obligation
RELOCATION on free args; any future class-upgrade mechanism must
land the discharge-before-unify inversion FIRST; (8) the cold
ladder's trial+final DOUBLE-ACCRUAL (three sites printed twice) —
the ledger holds both passes' copies, a dedup question for the
debt projection. THE FLOW MAP the specimen ladder measured
(graduated to tests/repro-wf/peel-ladder.mn, 14 rungs): a refined fact ANYWHERE in a
var-connected flow reaches the boundary (annotated producer or
param, through lets, comparisons, destructures, identity
interiors); a bare-first flow accrues its honest first claim at
the boundary; a GROUNDING interior (its own decl judgment
first-binds params/ret bare, publishing ground types with no var
for the fact to ride) breaks propagation — that break is
published-schemes-are-VALUES, rung 3's domain, not a unify arm.
THE OTHER HALF is still TWO on the wheel (march m3.err, unchanged
by design): scan_for_span's return (cursor:544) now needs only the
PARAM-ASSUMPTION LEG — its `i` is an unannotated param whose VarRef
the transparent face rightly refuses; the named next build is
node_lo_tr reading a binder's AUTHORED param annotation (an input,
uncontaminatable — the IH's param dual), after which `i: Handle`
discharges it; and the render_at ph flow (main:999) has NO refined
fact upstream since the mint-route revert — its discharge = the
mint annotation restored PLUS propagation across the chain's
grounding interiors, i.e. rung 3, or per-fn annotations down the
chain (each honest, each measured by the ladder's map). NEW PEER
banked from kill 5: `Hβ.verify.warm-image-pending-suppression` —
the warm path restores the analyzed image but re-derivation does
not re-surface unchanged-decl obligations, so the daily loop's
pending projection under-reports (cold = truth; the march is cold).
TagId's 0..255 and the float intervals stay the SMT tier's.

`Hβ.lower.lowering-is-a-column` — LowIR is the second graph (2026-07-30,
the Fable novelty audit's first proposal; report at
.build/research/novelty-fable-2026-07-30.md). LowExpr (lower.mn:240) is
39 constructors, EVERY ONE handle-first, re-materializing structure that
handle already addresses — a third thing beside the graph's two
operations, with its own writer, while lower.mn's own header and PLAN
§6's file map both call lowering "the projected read". The receiving
mechanism EXISTS: spine_page (graph.mn:107) holds seven per-handle
columns and `boundaries` is ALREADY a lowering fact written into the
graph. The design is "more columns, no tree": lowering writes per-handle
columns (yield boundaries, captures, direct-call resolution, twin encs,
state-slot homes), emit walks program plus columns, and the LowExpr/LowFn
trees and their ten walkers delete together. WHAT IT KILLS: the
lower-time-bake class, which the ledger declared dead THREE separate
times (LShow/LHash, field offsets, LPTuple) and which regenerates
because a tree invites baking — with no tree there is nothing to bake
into. It also makes per-decl incremental EMISSION fall out of the same
cone machinery that re-judges, and makes band N's native_m3==m4 a
statement about graph columns (this and the deterministic-handle
partition are one invariant said twice). COST, honestly: the largest
refactor on the board after schemes-are-edges (lower.mn 6,194 lines,
wasm.mn 7,591), and genuinely synthesized shapes — twins, wide wrappers,
k-records, redrive drivers — either mint graph nodes (precedent:
desugar, NModule, synth candidates all mint) or stay emit-era records.
Sequenced after schemes-are-edges by the same method: swap the
representation behind the projections, never patch the walkers.
STAMPED 2026-08-08 (traced / priced / enumerated — the build's
contract; 5.2's row half landed, so the sequencing gate is open):
— TRACED. The 39 constructors split into ~24 STRUCTURE
re-materializations (LConst/LLocal/LGlobal/LLet/LUpval/LBinOp/
LUnaryOp/LCall/LTailCall/LReturn/LIf/LBlock/LMakeList/LMakeTuple/
LMakeRecord/LMakeVariant/LMatch/LFieldLoad/LShow/LHash/LConvert/
LFeedback/LFeedbackPrior/LInvariantFailure — the graph node plus its
type already address everything; the emit walk reads program+columns
directly) and ~15 DECISION carriers, the genuine lowering facts, each
a per-handle COLUMN: binding resolution (Local/Global/Upval + capture
index), call resolution (direct-callee bit, tail bit, callee-ref
handle for twin demand), dispatch tier (LPerform/LDirectPerform/
LEvPerform/LWasiCall + stateful bit, effect key, op_slot,
state_local), yield boundary (state_index, ret_slot, frame-tail
handle, k-shape — extends the LIVE `boundaries` column family),
install shape (handler_name, state-init handles, arm_names groups),
state-slot home (slot_offset + record-ladder resolution), schedule
(the `~> Schedule` read), and the synthesized-fn set. THE
SYNTHESIZED-SHAPES FORK RESOLVES MINT (precedent: desugar, NModule,
synth candidates all mint; price: minted nodes REPLACE the LowFn tree
allocation in the same image, while emit-era records keep a second
tree — the entry's own kill-list logic convicts them). The k2-floor
rewrite (today a tree→tree pass) becomes a column fact written at the
one writer; LowFn's fence becomes a per-fn column field.
— PRICED (§5.O). Write: one lower pass over the judged cone, O(1)
list_set per decision through spine_page (the mechanism is live at 7
columns; this adds ~7 more — each page grows by that many words per
slot). Read: emit's spine_slot chase, O(1), the identical read canon/
narrowing/boundaries use. Freshness: columns written after judgment,
read only downstream by emit — no stale window, boundaries'
discipline. Deletes the per-compile LowExpr/LowFn tree allocation
(lower's dominant transient) — the arena's 2b image-set precondition
this arc exists to serve.
— ENUMERATED. Writers today, THREE (the census): the lower pass
proper (the mint), the k2-floor rewrite (k2_floor_guard/_list,
lower.mn:4409 region), the twin specialization (spec_candidates/
spec_resolve_build, wasm.mn). Target ONE: the lower pass writing
columns; k2-floor a column fact; twins emit-bracket reads keyed
(handle, repr-vector), no LowFn copy. Walkers, TWELVE families
(measured by the LYield total-match census — H6 totality makes the
rare arm the enumerator; §7's "sixteen" counted list-leg siblings):
lexpr_handle:510, k2_floor_guard:4409, reach_names_expr:5130,
collect_value_holes_expr:5352, spec_scan_expr:5871 (lower.mn);
walk_lemit_expr:1219, collect_call_vectors_expr:2146,
collect_fn_emit_records_expr:2690, walk_locals_expr:2893,
find_local_handle_expr:3297, emit_expr:3929,
collect_fold_tys_expr:5021 (wasm.mn). Each keeps its SIGNATURE and
its body becomes a column read (swap behind the projection), then the
tree and the bodies that only re-walked it delete together.
— THE MARCHED SEQUENCE: (i) column vocabulary lands beside the tree,
dual-written, zero readers (Law-7 no-op) — ✅ OPENED 2026-08-08, pin
d4d552904d8c: the BIND-HOME column (BindHome, the spine's eighth
column, graph_bind_note, the one dual-write at lower's VarRef arm,
keyed by the USE handle the tree discards); ✅ EXTENDED same day,
pins 1055e8e5093b + ccaacb70b5d4: the emittable-fn enumeration
(EmitFnKind × origin × name × fence × captures) at all seven LFn
construction sites, capture pairs at the five lexical sites, the
partial/arm program-live reasons in the op decl. THE PROJECTOR
STAMP (2026-08-08, traced to its first DEP — build gated on this
block): the body projection for an entry re-runs lower's own
construction seeded from columns instead of walk state — for a
lambda: params from the origin's LambdaExpr node, frame entered
with the column's (name, handle) capture pairs in note order, body
lowered by the same lower_body_reified — under an ABSORBING
handler catching graph_emitfn_note + graph_bind_note (the re-run's
notes must not duplicate the enumeration; two handlers covering
one effect's disjoint op sets is the LDirectPerform-documented
form). The coherence gate: projected fn_ir compared to the
tree-built fn_ir by the one structural ==; divergence raises a
census-entering diagnostic, so verify's census-0 ratchet IS the
gate. THE NAMED DEP — NESTING: a nested lambda inside a projected
body re-runs resolve_captures_outer against the OUTER frame
stack, which the live walk holds and the column re-entry does not;
its reconstruction is the ENCLOSING relation + each enclosing
entry's own capture pairs (derivable, recursive), OR the deeper
form — the projected body references nested fns BY ENTRY (the
LMakeClosure arm carrying an entry key instead of an inline LFn),
which is the tree's actual death shape at step (iv). SEQUENCE:
leaf-first (assert coherence on bodies with no nested
construction — the wheel's majority), then the entry-reference
shape closes nesting.
THE FIRST BUILD REVERTED WHOLE (2026-08-08 — the gate WORKED and
the experiment failed it): the leaf projector + census-entering
E_EmitFnProjectionDivergence + the enumeration high-water leaf
test ran on the wheel and fired 25 TIMES — twenty-five
leaf-classified lambdas whose column projection diverges from the
tree build. The march REPINNED ANYWAY (m3 == m4 TRANSITION held —
the divergent projections are deterministic) and verify's census
ratchet caught it post-pin: TWO BOARD FINDINGS BANKED — (1) the
march's transition path does not gate the census (its m3-leg
census read printed nothing and refused nothing; the verify
ratchet was the only net — close the gap when the projector
relands); (2) the gate fires only from generation 2 (the old boot
has no projector: m2.err 0, m3.err 25), so a projector-bearing
landing's first march leg under-reports. SPECIMENS (from the
march m3.err, banked before the revert): lambda_259726 260516
261363 274662 275516 285110 306551 306602 307521 307593 309548
316971 317015 317090 317134 317308 328122 330083 331728 348617
348659 348709 351644 355490 357850. THE ROOT IS DECODED (2026-08-08, four probe marches — kills
counted): (a) DEAD — a whole-wheel eq probe found ZERO
column-vs-walked body mismatches (the program column holds
exactly what the walk lowers, every lambda); (c) not implicated.
(b) CONFIRMED with the exact mechanism: LOWER-TIME FRESH MINTING.
The component probe showed all 25 diverging at BODY only (arity/
params/fence/root-handle equal, neither k2-wrapped); the span
probe placed every specimen at a lambda containing STRING
INTERPOLATION; and the mint census found the whole class — TWO
sites, both in lower_string_interpolation's machinery:
graph_fresh_ty per interior concat (lower.mn:4795, the
staging-clobber fix's per-concat handle) and graph_fresh_ty per
splice show (interp_fragment_shown, lower.mn:4818). A re-lowering
mints NEW cells, so the structural == honestly reports
handle-divergent trees. THE LAW THIS NAMES: body projection
requires lowering to be a PURE PROJECTION — same graph in, same
tree out — and lower-time fresh minting is the one thing in the
wheel that breaks it (the no-mint stamp's claim survives for fn
SHAPES; the intra-body mint class is what it missed). TWO
RESOLUTION DIRECTIONS, the first ruled the next build: (1)
DERIVED IDENTITY — the two mints become reads of a deterministic
key (origin handle × fragment index): mint once at the FIRST
lowering and read thereafter, or key into planned-mint space; the
open mechanics question is what the minted cell's handle is FOR —
the interior concat's ch is read at emit (the ++ dispatch and the
$call_<handle> staging local), so the derived cell must carry the
String type and module-wide uniqueness; (2) THE ULTIMATE FORM —
interpolation desugars AT PARSE into program nodes (the
show/concat structure judged by infer, real types instead of
Inferred placeholder cells), making lower a pure projection by
construction — the desugar-mints precedent applied to the last
lower-time minting in the wheel; named
`Hβ.parser.interp-desugars-to-program`. THE GATE REFRAME (2026-08-08, the decode's second reading — it
corrects the landing shape): in the DESTINATION architecture the
divergence cannot occur, because lowering runs ONCE per emit entry
(the projection IS the construction) and the sequential mint
counter is deterministic per compile — m3 == m4 already proves
it. The mint class poisons only the DUAL-RUN migration
instrument: any body that mints cannot be lowered twice and
compared with the handle-carrying ==. So the projector's landing
shape is one of three, in preference order: (α) the DIRECT SWAP —
the construction site builds VIA the projector (columns-seeded,
one run, no comparison), gated behaviorally by march + micros +
battery exactly as every emit change is; the dual-run coherence
gate remains valid for the NON-minting majority and retires per
kind as each swaps; (β) a handle-insensitive structural compare
(costs a 39-arm masked eq walker — machinery with no
post-migration life, weakest); (γ) direction (2)'s parse-desugar
first (kills the mint class outright, and independently worth it:
splice shows become judged program nodes with real types, and the
IFC fragment walk rides judged structure — but the FORMATTER
carries the fork: MakeStringExpr is the render carrier, so the
desugar must keep the surface form renderable without structure
sniffing — ShowExpr wraps inside the retained MakeStringExpr is
the traced shape for the splice half; the interior-concat half
has no clean parse home yet). α LANDED FOR THE LAMBDA KIND (2026-08-08, pin a3342552c850, CLEAN
byte-identity — the column path builds exactly what the walk
built, whole-wheel, interpolating specimens included; the lambda
arm's inline body-lowering deleted into project_lambda_fn) AND
THE NESTED KIND (same day, pin ae471c6b7fc1 — project_nested_fn
takes the FnStmt construction whole; fn_name/bind_h explicit
arguments, bind_h's column home the stamped dispatch-tier
column). THE THUNK PAIR (pin eae3f3559a0e): project_thunk_fn, ONE
construction for both fanout shapes, share-vs-distribute an
Option — the per-site family deleted, the boundary-row read
hoisted ahead of body lowering. THE SWEEP CLOSED (pin
3adb331719ef): arm, k, and partial measured ALREADY α-shaped —
standalone constructions fed by program/env/boundary facts, no
swap to make; the notes trued to parent-before-child so the
enumeration is tree-ordered across all six kinds. (γ)'S SPLICE
HALF LANDED (pin 058bf710e66d, TRANSITION): ShowExpr parse-minted
around every splice, judged by infer, LShow reading the judged
handle — interp_fragment_shown's per-run mint DELETED; the mint
class's remaining half is the interior-concat handle
(lower.mn:4817), still blocking dual-run lowering of
multi-fragment interpolations only. ONE KEYING REFUTED
(2026-08-08, battery-refused repin — the gate worked), the first
diagnosis retracted by the backtrace probe, and the SECOND
reading corrected by the wat artifact the same hour (the
forensic law, twice in one dig): the emitted main shows
$call_31135 SET TWICE — the outer concat parks str_concat there,
then the splice's own SYNTHESIZED SHOW CALL (int_to_str, keyed by
the LShow's handle = the fragment's handle) re-parks over it —
so the concat's fn_ptr load reads int_to_str's record and the
$ft3 concat through a $ft2 record traps `indirect call type
mismatch`. Both halves were real: it IS the staging-clobber
class (the fragment handle is already CALL-KEYED by its own
show), surfacing as the type mismatch. The law: an interior
concat's key must be distinct from every call-keyed handle in
its own subtree — fragment handles never qualify. THE SETTLED
DESIGN: the judge mints the N−1 concat cells ONCE (infer's
MakeStringExpr arm) and stores them in the BOUNDARY column —
ExecutableBoundary gains InterpBoundary([Int]) beside the fanout
and continuation families (the stamped yield-boundary channel is
exactly this per-node lowering-facts home); lower reads
graph_boundary_at(handle) instead of minting. That makes
lowering a pure projection with judged, trailed, once-minted
cells. ✅ BUILT (pin dddf5dc5d6bb, TRANSITION, both interp micros
green): InterpBoundary in ExecutableBoundary, interp_concat_cells
at the judge mirroring the elision, lower zipping the cells with
the count-mismatch guard refusing loud. THE MINT CENSUS IS ZERO —
lowering is same-graph-in-same-tree-out; the dual-run coherence
gate is available again wherever the arc wants it. TWO FINDINGS BANKED FROM THE
SWEEP: `Hβ.infer.nested-pattern-exhaustiveness` — usage_of's
double-nested match (N(body) → NodeBody → NExpr(Expr)) passed the
checker at 27 of 28 Expr variants and trapped at runtime on the
new ctor; totality must decompose through wrapping patterns, or
every grown ADT walks old matches into their compiled floors (the
placeholder-tell census — grep NExpr(ExprPlaceholder) — is the
hand instrument until the checker closes). And the IFC
read-through: check_splice_flow_labels now sees ShowExpr-wrapped
fragments — its label read must reach the INNER node (verified
green by the flow frontier leg this landing; named here so the
wrap never silently launders a splice's label). What remains
of the arc is step (ii)-onward proper: the enumeration READER,
then the tree deletion — plus (γ)'s ShowExpr follow-up.
THE PHASE-BOUNDARY STAMP (2026-08-08, traced against
pipeline.mn's spine — the reader's build contract):
— TRACED. compile_remainder (pipeline.mn:454) is `saturate_pass
|> lower_program |> reachable_from_main |> executable_gate |>
emit_module`, and the WHOLE remainder runs under ONE install
chain (:466 — wat_stdout … lower_scope ~> arm_state_ctx ~>
spec_registry), so the projectors are callable from emit BY
CONSTRUCTION — the ls world is live there; the boundary to
dissolve is the DATA handoff (the full [LowExpr] tree), not a
handler seam. The end form: construction RELOCATES from
lower-time to emit-time, ONE run still — lower_program shrinks
to its pre-passes (resume_bindings, escaping rows, decl
registration), and per-fn construction runs on demand per
REACHABLE entry. Reachability becomes the WORKLIST: construct
main's entry, collect its references from the constructed body,
construct those, iterate — demand-driven, replacing
lower-all-then-filter, and dissolving the dossier's chicken-egg
(lower-minted references exist exactly when their parent
constructs). The executable gate reads constructed bodies as
entries complete, before module assembly. The module
aggregations (call vectors, fold tys, strings, spec demands)
become per-entry ACCUMULATIONS at construction — the collect_*
walker family deletes here, not at a separate step.
— PRICED (§5.O). Construction becomes O(reachable) — unreachable
decls never lower (today they lower and are filtered). One run
per entry, so the interp mint class never dual-runs. Intern and
data ordering shift with the demand order → the landing is a
TRANSITION by construction; determinism holds (the worklist
order is a pure function of the program — first-reference order
from main). Memory: the full-tree residency window shrinks to
per-entry (the arena's 2b friend).
— ENUMERATED. The moving parts, each a marched landing: (1)
lower_program's per-decl construction relocates behind a
per-entry entry point — ✅ MEASURED ALREADY-SHAPED 2026-08-08:
lower_stmt IS the per-decl entry (lower_stmt_list is a plain map
of it), and the cross-decl state is exactly the four ls_register
pre-passes (globals, escaping rows, may-yield, resume binds) plus
lower_handler_stack_ctx, whose stack is per-install push/pop
balanced within bodies and EMPTY at decl boundaries (read at
lower.mn:145) — so per-decl lower_stmt calls are independent
given the pre-passes; (2) reachable_from_main becomes the
worklist driver keyed by the enumeration — construct main's
decl, collect references from the CONSTRUCTED body, construct
those, iterate — SIZED 2026-08-08 as a DEDICATED-ARC build, not
a loop-lease slice: the BFS construction order reshuffles every
mint (a whole-wheel TRANSITION), three tree-reading seeds need
re-rooting (main_param_count, spec_reach_seed, the always-run
value-let set), and the emitted-fn ORDER decision (source-order
collection vs demand-order emission) must be taken at the top;
half-building the spine leaves the tree unmarchable, so the
landing opens a session with the full design in hand, not a
timed iteration; (3) executable_gate re-roots on per-entry
constructed bodies; (4) emit_module's collect_* family becomes
accumulation at construction; (5) the LowFn/LowExpr handoff
tree deletes (step iv arrives here). Risk tripwire: the
worklist's first-reference order must be deterministic across
generations — the m3 == m4 assertion is the instrument. THE
MARCH CENSUS GAP IS CLOSED (2026-08-08): censusok reads the
m3-leg count against census_errors_max beside costok, refuses
both repin branches and the march's own exit on a rise; logic
seen RED against a synthetic err at ceiling 0, then the live
march green at census 0. The
remaining (i)
columns land by the same pattern as their swaps demand them;
(ii) the projection bodies
swap to column reads one landing at a time (collect_* family first),
each marched; (iii) emit_expr's dispatch swaps to program+columns
under march arbitration (CLEAN expected — same facts, same bytes);
(iv) the trees + tree-only walkers delete whole; (v) k2-floor and
twins re-key. A measured correction from (i)'s first landing: the
walkers take LowExpr VALUES while columns key by HANDLE, so the
step-(ii) collect_* swaps are NOT body-swaps — they re-root on
program+columns walks (the tree-only walkers die at (iv), not (ii));
and reach_names CANNOT re-root on source program alone (lower MINTS
references — fold helpers, twins — the source never wrote), so
reachability's swap waits for the synthesized-shapes mint.
THE MINT RESOLUTION INVERTS (2026-08-08, stamped against the
artifact before any mint was built — the alive-law on the stamp's
own author): the "synthesized shapes mint graph nodes" clause
answered the TREE's question, not the column form's. LowFn has
SEVEN construction sites, all in lower.mn (lower_call_partial:846
the partial wrapper, lower_expr_body:2200 the lambda,
synthesize_diverge_thunks:2791 + synthesize_branch_thunk:2843 the
fanout thunks, lower_stmt_body:3105 the nested fn,
lower_one_arm_decl:3662 the handler arm, reify_frame_k_at:4221 the
continuation k; wasm.mn constructs NONE — its synthesis lives at
the emit-record and raw-WAT altitudes). Every class WRAPS structure
the graph already holds: the lambda IS its program node; the nested
fn IS its FnStmt; the arm body IS the handler decl's arm; the
thunk's body IS the branch handle the boundaries column already
lists; the partial wrapper IS the call node's hole shape; and the k
remainder — the one genuinely-new structure — is k_remainder(
body_node, subs), a SUBSTITUTION-WALK over the frame's own program
node whose every parameter is a graph fact (the ContinuationEdge
column, the perform sites, the deterministic hole name). The trees
carry self-contained bodies because a TREE needs them; columns
dissolve the need. NOTHING MINTS. The replacement design: an
EMITTABLE-FN ENUMERATION — source decls (the decls column), one
entry per lambda / thunk / arm / k / partial (each derived from
program+columns at its origin handle), carrying (kind, origin
handle, deterministic name, fence) — with emit walking the
enumeration and projecting each body from program+columns
(the k entry re-running the substitution walk from the boundary
edge). Twins key (entry, repr-vector) on the same origin handles.
Fold helpers stay band D/5.4's own arc (raw WAT from Ty — below
this altitude, unchanged here). Reachability re-roots on the
enumeration + refs, not on source program alone — the earlier
"waits for the mint" gate dissolves WITH the mint itself; the
enumeration is what it waits for. PRICED: the enumeration is
lower's existing walk WRITING entries instead of trees (no second
walk, no new allocation class — it replaces the LowFn allocation);
emit's per-entry body projection is the same walk emit does today
rooted at a handle instead of a tree. ENUMERATED: the seven
LowFn writers above are the exact sites that become entry writes. Two verb confessions from the stamp's own dig, named
per ⟳: the `type NAME` query facet answers the name, not the
variant/field ROSTER (the ADT-roster facet); the address form lacks
an enclosing-DECL facet (node → its decl — the walker census needed
an awk scan for it).
THE STAMP REFUTED AND RE-CUT (2026-08-12, the independent adversarial
pass before the dedicated session — nine defects, every one receipted
against the artifact; the corrections supersede the stamp's claims in
place). BLOCKING corrections: (1) construction-before-assembly IS the
landing shape — zero-byte refusal + the evidence census + the
global-facts-before-first-byte assembly order (type section, fn
table, string offsets baked via the collected intern table) force ALL
construction to complete before emission; the PRICED residency claim
restates honestly as O(reachable), and per-entry emit-to-string with
incremental interning is the 9.2 parallel-emit arc's, not this one's.
(2) "the projectors are callable from emit BY CONSTRUCTION" was
FALSE: lower_handler_stack_ctx installs around lower_stmt_list INSIDE
lower_program, not in the compile-remainder chains (there are FOUR
plus the battery/mcp routes, not one) — the stack install joins every
chain as a marchable Law-7 pre-landing (state empty at decl
boundaries, behaviorally identical); lower_scope's registered state
genuinely survives, verified. (3) RE-CLASSIFIED by the fix
attempt's own probe (the retraction law, same hour): the block-hole
refusal is NOT an over-refusal — a zero-nested container is
unconditionally EMITTED under container-keep, so the fn is in the
emitted tree and SYNTAX's law ("pruned dead code" = NOT-EMITTED)
refuses its hole by the letter; the frame-aware pairing fix was
built, probed vacuous (the fn's name is in the reach universe under
any pairing), and reverted whole. The TRUE finding is twofold: the
three green dead-hole fixtures pass via NOTE-PATH ASYMMETRY (their
hole shapes never reach lower_expr's note arm), not via reachability
— their comments over-claim; and the block-vs-plain asymmetry is a
semantics seam the RELOCATION dissolves (dead entries never
construct, so never note — emission and reachability finally agree).
The seam is named here, not patched. PRE-LANDINGS, each marchable
while the tree stands: ✅ the handler-stack chain installs (pin
db7d3d360883, CLEAN — SIX chains not four, because `lower_program`
has three call sites of its own: pipeline:455 plus battery_compile
(main) and mcp_judge (mcp); balance verified pair by pair before the
move — the PTee push/pop and five frame-fence pairs, all
straight-line, so the stack is empty at every decl boundary;
placement beside `lower_scope` measured FREE, since all six op
references live in lower.mn and none sits in a chain handler's arm,
and the arms perform only substrate Memory/Alloc, which
`emit_memory_bump` — an `EmitMemory` handler — never catches. The
predicted row cascade measured ZERO: nothing between the install and
the performs declares a row); ✅ the emitfns_idx staleness fix (pin
6b9b08724830, CLEAN — NEITHER banked option: insert-on-note pays the
hot-arm rebind the +94MB measurement already refused, and
rebuild-on-miss cannot tell absent from stale so it re-derives on every
absent name. The landed form is a COVERAGE COUNT — `emitfns_idx_covers`
is the column length the index was folded from, so a read extends by
the uncovered suffix and `emitfns_index_build`'s existing start offset
does the work unchanged. `graph_emitfn_at` measured ZERO call sites,
refs and raw text agreeing, so the arm is provably behaviour-free
today. THE BUILD'S OWN KILL, caught by the peak ratchet at
2551504/2470668KB against a 2470000 ceiling: an eager `smap_new()` in
`graph_handler`'s state init is NOT a one-off 16KB — `graph_handler`
installs once per JUDGED DECL (infer.mn:2263, the layer sweep's
spawn), so state-init cost there is per-decl cost, ~+100MB measured.
The table stays unallocated until a read demands it and the peak
returned inside the prior band); ✅ decls_col grows HandlerDeclStmt +
LetStmt notes (pin 18ce91606de8, CLEAN — and the "zero new readers,
Law-7 vocabulary" scoping was REFUTED by the artifact: `decl_handles()`
feeds the `decls` facet AND `project_queue()`'s seed, so every write to
this column is a proposal position. It landed because "fn-only" was
never the contract — `graph_decl_note` fires from `infer_fn`, which
NESTED fn decls reach — so the let and handler-decl arms of `infer_stmt`
note at the same altitude. Both reader surfaces measured: the decls
fixture carries no handler or let so the facet leg is untouched
(frontier 361/0), and the oracle self-test run on this tree and on the
prior tree with the change stashed gave identical classification counts
and the same single CHANGED skeleton — a PRE-EXISTING drift
(s02_float_arith, expected edit-trap, got refuse-unfilled) now named,
since the self-test runs outside verify and march and nothing was
watching it); ✅ main_param_count re-roots on the DECLS COLUMN (pin
f5b8548875ad, CLEAN — folds graph_decls_at() and reads main's authored
params off its FnStmt node, so the recorded two-shape trap dissolves by
construction: a program node cannot be misled by a lowering shape it
never sees. The env/TFun form was built FIRST and refused by verify's
own drift-shape ratchet — its `_ => 0` for a non-function `main` moved
wildcard-zero 9 → 10 — and the column form needs no wildcard at all, so
the ratchet named the better form rather than merely blocking one. THE OTHER
TWO SEEDS ARE BANKED, tree-free test FAILED and measured:
collect_top_value_lets returns (name, init) where init is the LOWERED
expression emit_init_lets emits — the set could re-root on the program,
the payload cannot while the tree is the emission source, so splitting
them today builds a lookup the relocation deletes; spec_reach_seed
deep-walks spec_scan_expr for WIDE instantiation sites, which are
repr-keyed lowering facts rather than program facts, so its honest form
is a per-entry accumulator, not a seed re-root. Both land WITH the
worklist); per-entry accumulators dual-run
beside collect_* with set-equality gates, one family per landing —
NOT collect_call_vectors, the stamp's own suggestion, REFUTED against
the artifact 2026-08-12 before a line was built: its walk EXPANDS
emit-minted nodes (`LShow(h, x) => collect_call_vectors_expr(
show_node_of(h, x), acc)`, and show_node_of MINTS
`LCall(h, LGlobal(h, "int_to_str"), [x])` inside wasm.mn), so part of
the module's repr-vector set is created DURING the emit walk and exists
nowhere at lower time. A lower-fed accumulator would miss every
interpolation's show call — the wheel's own source is full of them — so
the set-equality gate would go RED by construction, and making it green
means feeding the accumulator from emit too, which IS the relocation
rather than a pre-landing. The viable first family is
`collect_fold_tys`: its LShow/LHash arms accumulate the fold TYPE and
walk the operand, reading only nodes the lowered tree already holds.
The general law this names, and the one the remaining families must each
be tested against: a module aggregation is dual-runnable only if every
node it visits exists before emit.
DECISIONS WRITTEN (derived, none open): container-keep is REPRODUCED
in the driver and the no-main library path seeds all decls — the
narrowing alternative silently changes the installed-effect census
(E_EffectUnhandled refusals on programs that compile today, the
oracle blind to it) and is refused; EMISSION ORDER is source-order
from decls_col on the first landing (smallest diff; the
enumeration's tree-order claim re-scopes to the dual-write era;
demand-order becomes 9.2's option); twin/duplicate notes get
(kind, origin, enc)-keyed idempotence with first-wins (the
state-init duplicate exists TODAY); the k2-floor claim survives
(per-fn-body inside the projectors — the refuter killed its own
candidate there). SIZING verdict: NOT one big-bang — ONE TRANSITION
(the worklist itself, bodies retained, source-order emission)
flanked by marchable landings, in the refuter's order: the
handler-stack chain installs; the idx staleness fix; the decls_col
growth; the seed re-roots; the accumulator dual-runs; the
container-keep/library/order fixtures banked RED; the TRANSITION;
the tree + walker + collect deletion; twins re-keyed.
THE FIRST (ii) SWAP STAMPED — THE HOLE GATE READS THE PROGRAM
(2026-08-11, the loop's sizing pass; build next). collect_value_holes
(lower.mn, the 60-line four-fn family matching all 39 constructors to
test ONE graph fact per carried handle) is the upside-down read:
authored `??` holes are PARSE facts, and the gate scans the lowered
tree for them. TRACED, the three-route joint that forced the stamp:
the gate needs reachable-filtered authored holes, and the
reachable→program mapping has no single home — the decls column notes
FnStmt handles ONLY (top-level lets escape it), the emitfn
enumeration is fn-shaped only, and env schemes carry decl reasons not
subtree roots. THE STAMP CORRECTED BY ITS OWN BUILD PASS (2026-08-11, same day —
the parse-time writer was wrong twice, banked before a line landed):
(1) the parser CANNOT be the writer — nhole has three call sites
(authored THole, the orphan-tee recovery, the unexpected-token
recovery, all minting nonzero ids with real spans), and above all a
call-arg/pipe `??` is a SUSPENSION that must never refuse — the tree
walk's real semantic content was VALUE-POSITION detection, encoded by
what survived to lower's LConst arm. Value-position is a LOWERING
decision, so the column's one writer is lower_expr's authored-hole
arm (lower.mn:2069, `NHole(_) => LConst(handle, ...)` — the arm that
already guards authored identity against canonicalization): it notes
the hole into a pending list. (2) THE DRAIN RIDES THE α-SWAPPED
CONSTRUCTIONS: each constructed entry (project_lambda_fn /
project_nested_fn / project_thunk_fn / the arm, k, and partial
constructions / lower_stmt for top decls) drains pending holes
against ITS OWN entry name — every hole pairs with its nearest
enclosing constructed entry, named exactly as reachability names
them, handler arms included; a top-level value let drains at "" and
"" is always-reachable (__init_lets runs every module value let —
reach_decl_name's own vocabulary). (3) gate_reads = the column
filtered by the reach set on entry NAMES ("" always kept); spans from
the weave; refusal unchanged; a hole in pruned dead code carries an
unreachable entry name and never over-refuses (SYNTAX's law held).
(4) the four-fn walker family DELETES; executable_hole survives as
the note condition. PRICED: O(authored holes) per gate; the pending
list is bounded by holes-per-entry (drained per construction); no new
allocation class. WRITERS: lower's hole arm (note), the seven
construction drains (pair), gate_reads (read). When the worklist
relocation lands, construction is per-reachable-entry and the
name-filter DELETES — the design converges with the arc's
destination instead of building (β)-class machinery. ✅ LANDED (pin 8aefbe91feb0 — CLEAN, census 0, battery 132/0 with
the three dead-hole contracts promoted; the LEDGER entry THE
VALUE-HOLES COLUMN carries the mechanics): the walker family is
deleted (twelve families → eleven), the drain needed TWO sites not
seven (the arm construction + the top-stmt boundary — container
reachability-classes cover the rest), and the gates steered twice:
the census gate caught visit-vs-survival on the wheel's two
pipe-target `??` (closed by graph_hole_unnote at the splice), the
peak ratchet caught the per-stmt state rebind (closed by the
empty-pending fast path). The never-over-refuse law is pinned in the
battery (mn-hole-dead-fn/-handler/-init).
THE (ii) LOOP-FRONTIER RULING (2026-08-11, the sizing pass after the
holes landing): the holes swap was the ONE collect walker re-rootable
at loop scale, because it tested a graph fact per carried handle. The
remaining collect family CARRIES TREE CONTENT — collect_fn_emit_records'
records are (name, params, BODY, fence), and call-vectors/fold-tys are
the module aggregations the phase-boundary stamp's own step (4) says
"become per-entry ACCUMULATIONS at construction — the collect_* walker
family deletes here, not at a separate step." Their re-root IS the
enumeration-reader/worklist relocation, sized by the stamp as a
DEDICATED-ARC build. The loop-sized continuation of this arc is step
(i)'s next decision-carrier column — the DISPATCH-TIER column
(LPerform/LDirectPerform/LEvPerform/LWasiCall + stateful bit, effect
key, op_slot, state_local, noted at lower's one dispatch-decision
site; the BindHome pattern: dual-written, zero readers, Law-7 no-op,
marched) — then the state-slot-home and install-shape columns by the
same pattern, each one landing. The dedicated arc then reads them.

`Hβ.eval.evaluating-cursor` — the subsystem table's missing row
(2026-07-30, the Fable novelty audit's second proposal). §2's table maps
every subsystem to a cursor-read mode and has NO evaluating mode, while
the artifact carries four hand-rolled evaluator fragments (verify.mn's
node_const_at and the compare/decide family, egraph.mn's const_int /
fold_int, the float parse oracle) plus the 332-line predicate-unfold
that was built and reverted. One `~> Evaluate` handler over the five
node-kinds is the medium's own answer, and it doubles as arc 7's missing
INTERNAL reference semantics (the correctness oracle is external today —
§0's own standing !Outside). Overlaps the banked unfold as its larval
form, stated plainly by the auditor.

`Hβ.own.linear-tier-and-persist-value-barrier` — RESOLVED at both halves
(2026-07-30; the Fable novelty audit's third proposal, built first
exactly as it argued — row-neutral to the judgment spine, and it was).
Half (a) the relevant tier: pin b77f345b (§7 AFFINE GAINS EXACTLY-ONCE —
consume_declare / consume_exit_fn's T_OwnUnconsumed narration), its
eight wheel findings swept to ZERO the next landing. Half (b) the
persist VALUE barrier: pin 16da60bd (§7 THE OWN CANNOT CROSS THE WIRE —
consume_declared + replay_barrier_gate at the argument edge whose
declared row severs the external triple; T_OwnAcrossReplay at the
capture site; the declared-not-open semantics the probe forced). The
named RESIDUAL, one face: a continuation reified by the MULTI-SHOT
producer and persisted through the word-rooted `persist(k, path)` op
never crosses this argument edge — an open own frozen inside a reified
k's frame rides band B's TCont value gate
(`Hβ.types.resume-world-mismatch-value-gate`), where the world's
capability check and this owns check are the same read at the same
boundary.

`Hβ.egraph.install-algebra` — the `~>` edge enters the e-graph
(2026-07-30, the Fable novelty audit's fourth proposal). The e-graph
rewrites VALUES and nothing rewrites INSTALLS, while every install pays
an unconditional world push/save/restore (wasm.mn:2463-2472, whose R1
comment calls it "the invariant, not an optimization"). Three
row-licensed moves as canon rewrites: ELISION (an install whose extent
provably performs none of its ops is inert), HOIST, and FUSION. The row
is the licence in each case — the same effect-awareness that already
gates the dropping rewrites, one altitude up. Sequence after the modal
world-index: install identity is what the modal crown is about, and
rewriting installs before that lands would optimize against a semantics
still moving.

`Hβ.query.generation-operand` — every projection takes a WHEN
(2026-07-30, the Fable novelty audit's fifth proposal, and its most
thesis-shaped). `mentl why` and `mentl at` answer about NOW; nothing
projects a past generation, so the medium cannot answer a question about
its own history and GIT REMAINS THE OUTSIDE TIME ORACLE — an !Outside
the docs never named, found by the auditor hitting it: no verb could
project the source of the very commit it was told to ground on. The
substrate exists on all three axes: checkpoints fork the graph,
ty_fingerprint compares generations, the warm image persists them, and
movers_diff (infer.mn:1335) is the larval two-generation renderer,
stderr-only. A why/at that takes a generation operand diffs two worlds
through the machinery already landed — the TIME axis of §2's own cursor,
pointed at the medium's own past.

`Hβ.types.authorship-is-a-reason` — the one authorship fact is a
substring probe (2026-07-30, the Fable novelty audit's sixth, ranked
last by its own author for arc-7 adjacency). Reason (types.mn:811-846)
has no authorship constructor, so the medium's only record of "a human
chose this" is `reason_is_pinned` testing whether a rendered string
CONTAINS "user pinned" (cursor.mn:471) — prose parsed as data, the
Carried-Truth law at the provenance layer. One wrapper ctor applied at
the three authorship boundaries (accept, tighten, MCP propose) makes
human intent a graph fact the Why chain walks, which is what §0's
lossless-intent property actually requires.

`Hβ.egraph.canon-edge-carries-reason` — the one unreasoned write in the
kernel (2026-07-30, the Opus novelty audit's third proposal; the report
is .build/research/novelty-opus-2026-07-30.md). Every graph write
carries a Reason except `graph_canon_set(Int, Int)` (types.mn:1672):
`rewrite_to` (egraph.mn:115) draws an equivalence with no justification
at all, and `mint_fold` (:243) gives the minted NODE a Reason while the
EQUALITY that legitimizes it gets none. Give the edge its Reason and the
relation gains a distinction it cannot express today — PROVEN (a rule
fired) versus ASSUMED (a path condition holds in this scope) — which is
what turns scoped assumption from a discipline into a structure the
executable gate can refuse (an assumed edge reachable from main outside
its drawing scope). Shape: the `canon: [Int]` spine column becomes a
pair cell carrying (target, Reason) — the comments column's own
precedent, no eighth column — plus a `graph_canon_reason_at` projection
(one op per fact, the graph_comment_span_at precedent). It also makes
band F's `Hβ.verify.reason-edge-pcc-certificate` constructible: an
emission whose optimizations have no derivation cannot be certified.
Small and mechanical; its value is as the belt under
`Hβ.verify.congruence-is-the-egraph` below.

`Hβ.verify.congruence-is-the-egraph` — the second decision procedure
already in the tree (2026-07-30, the Opus novelty audit's first
proposal). Mentl runs TWO engines over the same relation and orders them
so they can never meet: egraph.mn maintains a value-equality union-find
with congruence closure and constant folding, while verify.mn keeps a
PRIVATE constant folder (`node_const_at`, verify.mn:111 — its own
comment admits the duplication) and a hand-written interval interpreter
(`node_lo_tr`, :158), and decides every obligation during inference,
before the first canon edge exists (`compile_remainder`'s
saturate_pass runs after, pipeline.mn:447). No path in verify.mn
reaches `egraph_extract`; `graph_canon_at` has exactly two readers, both
inside egraph.mn. THE PROPOSAL: Verify's discharge becomes a READ of the
canon weave, and a path condition becomes a set of ASSUMED canon edges
drawn inside a graph checkpoint and rolled back at the join — the
`??` fan's own machinery (fork, saturate a range, roll back) pointed at
a different relation. What it buys: path-sensitive proof with no new
engine (`if x == 0` makes `x ≡ 0` readable, so `x * 2` folds and a
proven index elides its check —
`Hβ.infer.narrowing-write-requires-discharge` gains a real discharge
source), the second folder deletes, the interval fragment's
contamination law gains an UNCONTAMINATED relation to read instead of a
workaround to maintain, and a genuine piece of the SMT residual moves
from Outside to inside (congruence closure over ground terms IS the EUF
core). DEP: `Hβ.types.predicate-is-expr` (a predicate must be an
ordinary expression node before it can be saturated) and the canon-edge
Reason above (an assumed edge that survives its scope is a miscompile,
not a missed optimization). Re-measure wall time in its own entry — per-
branch scoped saturation multiplies passes, and the crc/classifier
history is explicit that such a landing must.

`Hβ.types.traversal-is-a-handler` — one descent over `Ty`, consumers as
arms (2026-07-30, the Opus novelty audit's second proposal). Nineteen
functions traverse the Ty ADT re-deriving the same descent and differing
only at the leaves (format.mn:913 · graph.mn:772 · synth_proposer.mn:208
· mentl.mn:543 · types.mn:130/251/272/2518/2974 · lower.mn:3131 ·
infer.mn:1626/4849/6052/6090/6184/6305/6455/6550 · verify.mn:247), and
two of those pairs are one algebra twice (the check-then-build twins
from the A.3 allocation landing). THE MENTL-NATIVE TWIST that makes this
more than a visitor pattern: the four walk SHAPES are exactly the four
RESUME CARDINALITIES — zero-resume/Abandon is `occurs_in` stopping at
the first hit; one-resume-accumulating is free_in_ty / fold_sig / ty_lo
/ extract_row / query_flow_label / repr_of; one-resume-rebuilding is
subst_ty_build / chase_deep_build / fold_strip / ty_handle_of;
multi-resume is `enumerate_typed` enumerating a type's inhabitants. The
discipline the medium already INFERS from arm bodies classifies the
traversal it is used in — the kernel explaining a compiler-internal
pattern rather than a pattern imported to explain the kernel. The tax
being paid: TReprPin (the newest constructor) appears at 26 sites across
9 files; TAlias at 49. BOUNDARIES, stated: binary walks do not fit
(`same_ground` and unify descend two types in lockstep — a zip, not a
fold, and they stay); the hot instantiate-path walks must be measured
into the tail-resumptive tier before landing, not after; and the two
render walks stay distinct registers per §5.U's voice/format boundary —
one descent, never one leaf.

`Hβ.query.refs-reads-edges-not-occurrences` — two measured holes in the
refs facet (2026-07-30, found by the Opus novelty audit while working,
offered as findings rather than proposals; one root — `refs of` walks
VarRef OCCURRENCES instead of reading the edges the graph already drew,
Anchor 1 at the query layer). (1) DAG-SCOPED: `refs of graph_canon_at`
answers 0 from graph.mn and 2 from egraph.mn — the more foundational the
name, the emptier and more CONFIDENT the wrong answer, because a base
module's DAG contains only its dependencies, which by definition cannot
reference it. (2) PATTERN-BLIND: `refs of TReprPin` returns 7, all
construction sites; the 26 match arms that destructure it are invisible
because a pattern binds through PCon, not VarRef — and for an ADT
constructor the arms are the MORE important half, they are the
exhaustiveness surface. Both are why an ADT-walk census still needs a
grep confession. Smaller sibling: `mentl query "type NAME"` on an ADT
answers "declared as NAME" without projecting its variants, and nothing
projects the module import graph though the driver holds it as NModule
nodes with ranges.

`Hβ.query.param-render-reversed` — RESOLVED (2026-07-30, the
comment-voice audit's opening conviction; the §7 entry THE VOICE
CANNOT MISORDER carries the arc). The root was query.mn's private
deep-chase family — chase_params_deep / chase_list_deep /
chase_fields_deep / find_unresolved all walked last/drop_last and
PREPENDED, rebuilding every list REVERSED (params, tuple elems, type
args, record fields, the unresolved set): the show_list disease alive
in a query-side copy, measured at cost first (two swapped calls in one
hour from TRUSTING the projection — collect_free_vars, string_in_list —
each convicted by the census in one march). The walks are the map /
filter|>map vocabulary forms now — order-preserving BY CONSTRUCTION,
iteration-is-topology's own tier — and the frontier pins declaration
order (`type of pair` answers alpha-first). The family remains one of
the nineteen Ty descents; its one home arrives with
`Hβ.types.traversal-is-a-handler`.

`Hβ.voice.comment-mass-absorbs-into-projections` — the wheel is 38%
prose, and almost none of it is the endpoint (Morgan's charge,
2026-07-30: comments belong to the developer — the scratchpad, the
fun-place — because the medium's voice speaks everything load-bearing).
Measured: ~17,762 comment-carrying lines of 47,101 in src/**, nearly
all MECHANISM prose — constraints, measured whys, layout laws — written
by the builder because the voice cannot yet carry them: each line is
larval `mentl why` / `mentl audit` content, the ⟳ confession at the
prose layer (SYNTAX §«What a comment TRENDS TO» now states the surface
law; CLAUDE.md ⟳ the method half). THE ABSORPTION ARC, per family:
measured-why comments → Reason edges a `why` hop renders (the largest
class — "measured 2026-07-XX, N sites" prose is a graph fact with a
date); law/invariant comments → refinements, rows, and armed
diagnostics (a stated invariant the medium could refuse on is a
diagnostic not yet born); pointer comments (`the X precedent`, peer
names) → the residue index read live; layout-rationale comments →
deleted by fmt-canonical (the renderer IS the rationale). The census
instrument is `Hβ.query.comment-prose-search`'s verb reading the weave
— classify by whether the deletion test loses unprojectable content;
the RATCHET: comment mass falls as verbs land, never by suppression
(the drift-marker eradication's exact shape one layer up). The residue
at the limit is authored intent — the one genuine Outside, carried
losslessly, never required.

`Hβ.synth.rank-is-a-projection-not-a-field` — RESOLVED (2026-08-07, the
arc loop's second iteration, exactly by its own prescription): `cost`
left the record, the thirteen enumerator constants left their
construction sites, and rank is `rank_of` — a PROJECTION of the LIVE
candidate computed once per candidate at sort entry (the pair-keyed
insertion build), reading the callee name from the node and the decl
reason from the env. A ctor call IS a CallExpr(VarRef), so the design
half's "proximity keyed on the ctor name" fell out as the same one arm;
a nameless candidate (lambda, literal) carries the bare base with no
invented differentiation. The extraction-swap site
(canonicalize-survivor) now rebuilds without a number to carry, so the
stale-ride face dies textually. Cost-neutral: the same refs walk the
stored form paid at enrichment, moved to the read point.

`Hβ.egraph.extraction-cost-composes-repr` — the RULE-GROWTH CONTRACT,
banked 2026-08-07 while truing Phase 2.1 to the artifact: today's
rewrite set shrinks by construction (identity/absorb/fold point at
existing subnodes), so NO cost model exists and none may be hand-grown.
When band G's saturation-deepen adds the first NON-shrinking rule
(strength reduction, fusion, reassociation), "cheaper" must be a
PROJECTION composed from what the graph already proves — repr_of's
widths, effs_at's rows, the use-profile's counts — never a term-shape
function; and the canon edge it justifies should carry the cost's
Reason (the sibling gap `Hβ.egraph.canon-edge-carries-reason`, named in
the extraction-swap comment). The contract gates rule growth in Phase
5.5; violating it re-creates the disease 2.1 measured out of synth.

`Hβ.synth.fan-extraction-needs-a-feeder` — the composition's dormancy,
named with its own artifact (2026-07-30, banked RED at
tests/frontier/mn-fan-extraction-fires.mn, unregistered). The fork/merge
path is live, ordered, and non-destructive, and it CANNOT MOVE ANYTHING
yet for a structural reason: every e-graph rule matches a BinOpExpr
shape (egraph.mn:123-224) while every fan enumerator mints an ATOM
(synth_proposer.mn:684-693 and kin) — the two sets do not intersect, so
extraction always chases a handle to itself and the false-tie collapse
never has two survivors in one class. This is dormant BY CONSTRUCTION,
not broken, and it is stated here rather than implied so no future
reader mistakes a passing gate for a proven mechanism. The FEEDER is
either half: a candidate space that mints composite expressions, or a
rule set that rewrites the shapes the fan already mints (band G's
`Hβ.lower.egraph-saturation-deepen`). The banked fixture is what "fed"
means, and it runs green the day one lands.

`Hβ.effects.negative-stance-under-mixed-gate` — the declared-row gate's
tail asymmetry (measured 2026-07-30, the check-verb landing). A fn
declaring a MIXED row (positives + `!E`) whose body row widened to the
negative stance is REFUSED by its own declaration: row_subsumes' closed
gate arm answers `EtAll => false` by its own written law ("an
unknown-beyond-mask body may perform outside it"), while the mixed
declaration resolves EtClosed — so `with Cast + !Mutate` over a body
proving `Cast(GNode) + !Mutate` mismatches. Measured at
graph.mn's occurs_in_live and inherited by every module weaving it
(egraph). TWO THEORIES DEAD to probes, banked so the fix is not
re-chased: bare-vs-instance is NOT the trigger (a minimal `with Cast`
over `addr(x)` checks clean — eff_name_handle shares the handle
between ENamed and EParameterized, so by-name membership already
admits an instance under a bare declaration), and neither is
negation-beside-positives (`with Cast + !Mutate` on the same minimal
body checks clean). MUTUAL RECURSION is the discriminator (probe four, the minimal RED
banked at tests/frontier/mn-mutual-negation-gate.mn — unregistered,
eight lines, failing on check AND compile AND the concatenated blob
alike): a NON-recursive `!Mutate` callee passes; make the callee a
mutually-recursive pair and the caller's own declaration is refused.
THE ROOT, traced to a named fn: `row_without_self` (effects.mn) takes
the least solution of a recursive row equation — "a tail landing on
the fn's OWN row handle cuts to the closed head" — and that cut is
SELF-only. Under mutual recursion the tail lands on a CO-MEMBER's
handle, so `R_ping = names ∪ R_pong, R_pong = names ∪ R_ping` never
cuts, the row never closes, and the widened tail flows into every
caller until a closed gate refuses it. THE PRESCRIBED FIX ABOVE IS
REFUTED — WIDENING THE CUT IS THE WRONG DIRECTION (2026-07-31, the
source dig; this paragraph is kept as the era's record because a
reader could otherwise BUILD it). The entry proposed taking the
least-solution cut "one scope up" so a tail landing on any SCC member
cuts to closed. The minimized reproduction
(tests/frontier/mn-cycle-charge-freeze.mn) shows the cut IS THE
DEFECT, not its scope: the cycle member whose accumulated tail happens
to keep a live CO-MEMBER edge never cuts and stays CORRECT, while the
member that cuts freezes its row at an instant when its co-members
are unjudged and loses their effects permanently. A group-wide cut
freezes MORE rows, not fewer. TWO ROOT CORRECTIONS also land on this
entry: the effects audit re-diagnosed the refusal itself as the
`EtClosed`-gate × `EtAll`-BODY arm with the `EtAll` manufactured by
the NEGATION PUBLISH (`inter_row` yields EtAll when the body row is
already EtAll), killing the instance-compare and EtAll×EtAll theories
by probe; and `row_without_self` now compares CHASED ROOTS (the
2026-07-31 charge landing), so the self-only-ness this entry names is
already gone. The unconditional-close publish was then MEASURED WRONG
in the guard era (census 70 and m3 ≠ m4 — the withdrawn bb8b93a2
entry's second reverted guess), and the guard half-step itself
reverted (the HALF-STEP REVERTS entry), so the class stands OPEN at
the restored pin exactly as first measured; the DISSOLUTION is the
row half — charges as edges with completion drains, no cut at all.

THE TWELVE-AUDITOR FLEET'S REMAINING PEERS (2026-07-31, banked at their
one home; full reports + the cross-fleet synthesis in
.build/research/audit-*-2026-07-31.md and fleet-synthesis-2026-07-31.md,
each finding artifact-grounded with its own calibration section):

`Hβ.verify.echo-stop-reads-per-leaf` — THE FLOW-FACE LAUNDER, probed
live: a refined return over a JOIN self-discharges through the class
alias, so `fn bad(v: Nat, c) -> Nat = if c { v } else { 0 - 5 }`
compiles with ZERO verify lines and returns -5 through `0 <= self`.
`value_flows_class` tests only the TOP node's shape while
body↔ret↔annotation unified before the constraint read, so the
annotation proves itself. The frontier's "exactly two pendings" holds
by REPRESENTATIVE LUCK (a seek variant whose then-branch is a refined
param discharges silently). FIX: the echo-stop becomes a per-LEAF
coverage verdict over the join spine `node_lo_tr` already walks —
VarRef → its own binding obligation, Call → the callee channel,
literal → GROUND-DECIDE (so the launder UPGRADES to
E_RefinementRejected at the branch), computation → raise. Deletes the
duplicated licence pair (verify.mn:314 ≡ infer.mn:6832). RED banked:
tests/frontier/mn-refine-join-launder.mn.

`Hβ.emit.total-monomorphization` — STAMPED whole 2026-08-07 (§11 5.1;
built on the artifact read of the spec-twin machinery, wasm.mn's
demand analysis). WHAT EXISTS, traced: three passes over projections
the graph holds — CANDIDATES (every reference site whose key projects
wide, closed transitively under substitution via spec_candidates_fix),
WORTHINESS (twin only when the body performs arith/compare/eq on a
wide-bound pair var — the address-comparison witness; plumbing shells
like fold/map stay at the floor), twins seeded into spec_registry and
redirected at every reference-emitting arm. THE REFRAME the read
forces: the machinery is ALREADY total-by-REPR — a candidate keys on
its repr vector (spec_enc), and the all-word vector IS the floor
CLASS, correct at the wasm altitude because a word is a word; the
measured silent-wrongs (address-compare sort, the ~0 float
accumulator, describe printing a pointer) all live at the WIDE seam
the candidates already cover. What §11 calls the perf-hybrid is
exactly ONE filter: the worthiness gate. THE PLAN, three legs: (5.1a)
DELETE WORTHINESS — every wide-keyed candidate twins, plumbing
included (pass 2 dies; pass 1's transitive closure is the whole
analysis); measured by the twin count, the m2 line delta, and the
peak ratchet — the blowup is BOUNDED by the demand set the union-find
already enumerates, and extraction reclaims duplication when band G's
projection matures. (5.1b) type-total IS repr-total plus the Repr ADT
growing (RI8 at 5.4, regclasses at band N) — arriving arms widen the
key BY CONSTRUCTION; no separate landing exists. (5.1c) THE CYCLE
GUARD, a real missing safety: spec_candidates_fix dedups by mangled
name, so polymorphic recursion demanding a NEW vector of its own base
per round would grow the work list unboundedly — the compiler HANGS
on a user program the wheel never writes (the productive-under-error
law's own shape: a hang is an error path recovering by looping). The
guard: a per-base vector-count cap along one demand chain; at the
cap the candidate floors at the uniform word protocol with a
narration (the Henglein price surfaced as teaching, never a hang) —
RED-first via a polymorphic-recursion fixture that today must be
probed (it may hang the current emit; the probe runs under timeout
and its verdict decides whether 5.1c leads or follows 5.1a). PRICED
(§5.O): no new scans — pass 2's deletion REMOVES a walk; the twin
blowup is the one cost, measured not guessed, and the 1,830,000 KB
peak ceiling arbitrates (a justified bump names the arena's later
reclaim). MEASURED 2026-08-07, both legs run: (5.1c) KILLED TWICE —
the mangle space per base is finite by construction (a wide component
is a scalar repr, containers are words, so ≤5^K vectors per base and
the fix terminates with no guard), AND polymorphic recursion cannot
reach the emit at all: the probe (`depth(x: a, n) = ... depth([x],
n-1)`, authored signature) refuses E_OccursCheck — the checker uses
the mono assumption for self-calls even under a signature, so
SYNTAX's "polymorphic recursion prices a signature" is today
refuse-both-ways (a measured 5.3 baseline: below Haskell/OCaml's
crude route). (5.1a) BUILT AND REFUTED BY THE MARCH: the worthiness
web deleted whole (nine fns), m2 compiled, and m3 TRAPPED — call
stack exhausted in zip_with — the wheel's own compile diverging under
a plumbing twin. THE GATE IS LOAD-BEARING CORRECTNESS, not a perf
hybrid: the worthy set was leaf-compute fns by construction
(spec_registry's own comment), so the twin emission for
SELF-RECURSIVE CLOSURE-CARRYING HOFs was never exercised and
miscompiles (zip_with's twinned recursion never terminates). The
deletion REVERTED whole. NEW PEER, the real blocker:
`Hβ.emit.plumbing-twin-selfcall` — PROBED 2026-08-07, three kills
banked and the hypothesis SHARPENED: (1) the minimal plumbing twin is
CORRECT — a wide zip_with fixture through the probe m2 (worthiness
forced true, uncommitted) twins (nine zip_with$ references) and runs
exit 10; (2) a sensitive self-recursive closure-carrying HOF twin
(sum_with, float acc) runs correct through the CURRENT boot — the
live twin set is fine; (3) the compiler NEVER calls zip_with at
runtime (all ten link refs are lib/ml + prelude), yet the reproduced
trap (same probe tree, march) shows m2 executing 20+ zip_with frames
ALL AT ONE PC (0xcf6e) from a caller the truncated backtrace never
prints. A fn executing that provably has no caller is the
corrupted-dispatch shape: a call_indirect whose computed table index
lands on zip_with's slot (the bad-table-index class — "prints WAT
mid-inference means the parser ate an arm"'s runtime sibling),
pointing at a PINNED-BOOT miscompile of the probe SOURCE (the boot
emits m2; the probe source's demand-fn shapes may tickle a boot
emission bug — closure record layout, table-index global, or
evidence slot). SECOND PROBE SESSION (2026-08-07, five more kills — the forensic law:
count them): (4) the dispatch-corruption hypothesis DIED — 0xcf6e
disassembles to `call 68 <zip_with>`, the floor's DIRECT self-call
(no call_indirect anywhere in the loop); (5) "the compiler never
calls zip_with" DIED — it calls ZIP (enumerate = zip∘range; the
original refs query asked the wrong name); the depth-1 entry trap
named the FIRST caller as register_one_op → build_ctor_params →
enumerate — benign, ≤5 deep; (6) the boot-miscompile hypothesis
DIED — the clean-vs-probe emit-diff's 1,379 "differing" fns are all
lambda-NUMBER drift from the probe's own comment lines (zip's one
diff line is a lambda_idx global rename; emit-diff does not
normalize lambda-name references inside named fns — a tool
limitation now known); (7) the enumerate-blowup hypothesis DIED — an
entry trap on any enumerate list >10k never fired; (8) the
list_eq_f64 route DIED — all four binary `call 69 <zip>` sites live
in the generated list_eq_f64, and its depth-1 trap never fired. WHAT
SURVIVES: the runaway enters zip_with through the CLOSURE-VALUE path
(the `global.get $zip_with` record passed first-class into a HOF and
invoked by call_indirect — the one entry the direct-call census
cannot see), with either a huge legitimate list or a list whose
len/rest disagree (rest never shrinking what len reports small). The
coredump and backtrace both cap at 20 frames, so the caller is
invisible to frames. NAMED NEXT INSTRUMENT, fully specified: the
CALLER-ID + COREDUMP-MEMORY scheme — patch each call_indirect site
that can carry the zip_with record (or cheaper: patch zip_with's
entry to store its ARG-list handles and a per-call counter into
scratch words 0-2), run to exhaustion, then read the coredump's DATA
SEGMENT at those addresses (the coredump carries the whole memory
image; frames cap but memory does not) — the stored words name the
runaway's input list handles, and lookup of their headers in the
same image answers huge-vs-corrupt in one read. THIRD SESSION (2026-08-07, the globals-forensics round — wasmtime
coredumps carry GLOBALS, not memory; the probe values live in added
globals and read out of the dump): THE RUNAWAY IS PINNED TO NUMBERS.
zip_with dies 87,311 calls deep (deterministic across runs), on a
list whose len() answers 26 FOREVER: the deepest node decodes as a
slice [len=26][tag4][parent][start=1] (slice_raw's exact layout,
lists.mn:493-498), a fresh 16-byte-class node per level at ~1.8GB
(late compile). rest(xs) = slice(xs, 1, len(xs)) allocates but never
progresses. THE ARITHMETIC CONTRADICTION that names the next read: a
level storing len=26 with start=1 requires its parent's total ≥ 27
(new_len = cend − cstart with cend clamped to total), yet every
probed level shows 26 — so the PARENT pointer (w2, captured) does
not chain to the previous slice node (56 bytes back, not 16 — other
allocations interleave), and the parent's OWN header is the missing
read. SUSPECT ON THE BOARD: slice_raw's `let total =
load_i32(list)` — a representation-BLIND raw read of word 0 as "the
total" (the prober-must-honor-protocols law at the runtime's own
source); if any non-slice representation reaches it whose word 0 is
not a length, total is garbage and the chain follows. FOURTH SESSION (2026-08-07): the parent-chain capture ANSWERED the
contradiction — lens run 26 ← 27 ← 28 up the chain, so the recursion
PROGRESSES correctly one element per level; 87,311 deep with 26 left
means the chain's ORIGIN was ~87,337 long — a number in the range of
the compile's HANDLE count, sharpening the blind-total suspicion to
the chain ROOT: word 0 of the original (non-slice) node misread as a
length (slice_raw's `load_i32(list)` total, or a len() fallback arm)
mints an 87k-len slice over a small list, and every level below is
arithmetically consistent. f's closure index = 41 = floor zip's OWN
pairing lambda ⇒ entry through floor `zip`. Source-level >10k guards
at ALL FIVE direct zip sites (infer 4051/6038/6096/6279, lower 1538)
stayed SILENT through a reproduced trap — five more site kills — so
the entry is the SIXTH zip: enumerate's (prelude:268), whose earlier
binary guard was MISWIRED (passed __state in the arg slot; its
silence proves nothing). RESOLVED 2026-08-07 (pin dedfec69264a — the LEDGER's THE STACK HOLDS
FLAT carries the ten-kill chain): NO corruption existed anywhere. The
counter was global (87,311 = all calls, not depth), the death depth
was the AMBIENT stack budget (a few thousand frames under the emit's
own compile depth), and the entry list was ENUM len=4696 — the
twin-inflated fn-name table (clean ~3,590) crossing a cliff the
pinned build sat ~1,000 fns from on its own. zip_with is now the
buffer-counter tail form (zip_with_fill, range_fill's shape,
callee-first); mn-zip-deep pins 200,000 fresh-stack elements, seen
RED at exit 134. CONSEQUENCES: `Hβ.emit.plumbing-twin-selfcall` is
CLOSED (no twin ever miscompiled); 5.1a RE-SCOPES to a
ratchet-measured cost question (twin count, m2 bytes, peak RSS —
re-attemptable, no crash); two small residues named —
`Hβ.cli.test-single-file-judges` (`mentl test <file>` silently exits
0 without judging; the battery form is the directory) and the
non-tail prelude-builder CENSUS (the `[x] ++ self(rest)` shape
class — zip_with was the proven killer; the class enumeration is one
audit-tier query away). The worthiness gate STANDS until
this closes — named at spec_demands_of as the guard of an unfixed
blowup class (the demand-set explosion is real either way: the gated
twin set is tiny by construction, the total set is not, and the
emit's own prelude consumers are non-tail).
THE RE-ATTEMPT RAN AND PINNED A REAL BREAK (2026-08-07 — the
worthiness filter dropped, marched; reverted whole, pin untouched
at a13918ee): m2 assembles and runs (census 0, RSS 2,209,292 KB —
inside the raised ceiling, the stack cliff crossed safely by the
tail-form zip), and the emit inflates 343,379 → 403,710 lines
(+17%); but M3 FAILS ASSEMBLY — the new wheel's own emit of the
total twin set is WIDTH-BROKEN at a handler-state store:
m3.wat:340004 `(i32.store offset=12)` fed [i32, f64], and :340019
an implicit return expecting f64 got i32, both in a
`$__hstate_237970_wprev` world-save region. THE NEW NAMED PEER:
`Hβ.emit.twin-state-width` — the twin emission of a
handler-state-carrying fn (or a state slot whose repr is wide) is
width-blind at the state store/world-save path; the floor's
uniform i32 state slots and the twin's repr-true locals disagree
at offset 12. 5.1a re-sequences behind THIS peer now (the
generation lag proved the probe order: m2 green is not the
verdict — the break lives one generation deep). The probe that
pins the exact fn: emit-diff the m3 region around 340004 against
m2's emission of the same fn, or grep m3.wat for the hstate
number's owner.
PINNED WHOLE (2026-08-07, the saved refused-march artifact): the
owner is `$fold$sp2nSpan` — fold twinned with an f64 init — and
the break is the HANDLER-STATE record store:
`(local.get $init.f64) (i32.store offset=12)` writes the twin's
repr-true wide param into the uniform word-wide hstate record
(fold's `with acc = init` accumulator slot), and
`op_fold_handler_result`'s i32 return meets the twin's f64 result
at the exit — the same blindness at read. THE FIX SHAPE, §5.U at
the handler-state record: the hstate layout reads repr_of per
STATE FIELD (width-summed offsets exactly as record fields
already do), the state store/read pair emits repr-true
(f64.store/f64.load at computed offsets), and each
op_*_handler_result's return width projects from the op's answer
repr — the unified record's state face joining the repr gradient
(band D's variant-payload sibling at the handler layer). Until it
lands, the worthiness gate stands as the guard of BOTH named
classes (the non-tail blowup census and this width blindness);
5.1a's cost measurement (emit +17%, RSS inside ceiling, cliff
crossed) is banked and re-attemptable the day the state face is
repr-true.
THE WRITER ENUMERATION (2026-08-07, the stamp's census — every
site where the hstate layout's uniform 4-byte slot assumption is
baked): (1) wasm.mn:4115 LHandleWith's record size
`8 + 4*(nstate+total_arms)`; (2) :3522 emit_state_init_writes —
the init store walk, the pinned break's own site; (3) :3606 the
arm-entry offset `8 + 4*nstate + 4*(base+k)`; (4) :4501
LStateSlotStore's emitter (resume-with-state commits through the
__hrec ladder); (5) :4419 the dispatch's `arm_const = 8 +
4*op_slot`; (6) :7142/:7152 the POff(8 + i*4) path offsets (the
persist/fold path readers). The arm-body state READ path and the
op_*_handler_result generators complete the family at the build
(one grep each). THE DISCRIMINATING PAIR, from the closed peer's
own record: sum_with's float-acc twin RUNS CORRECT through the
live twin set while fold's f64-init twin breaks at the init
store — the class splits on how the wide value REACHES the slot
(a direct repr-true param store vs a path that boxes/goes through
a word cell), so the build's first probe diffs the two twins'
state-store emissions to pin which arrival path is width-honest
and which is blind. The fix stays §5.U's per-field repr layout;
the pair tells the build where the seam already half-exists.
THE CENSUS REFINEMENT (2026-08-07, within the refused m3 itself):
the total-twin emission holds 39 fold twins and EXACTLY ONE
carries a wide init — sp2nSpan (the mangle decodes as the
repr-vector: 2 = RF64 init, nSpan the element nominal) — and
wat2wasm reported exactly one broken site: the width class has a
SINGLE INSTANCE in the whole wheel at total candidacy. The
emitter is already HALF repr-true: the twin's param signature
reads the repr (`(param $init.f64 f64)`); only
emit_state_init_writes and the slot arithmetic are width-fixed —
the seam exists at the signature and stops one instruction short.
sum_with's twin is ABSENT from this era's emission (its fixture
lived in a probe tree; the pair-diff needs the fixture re-run if
wanted — the single-instance census makes it optional). The
boxed-slot alternative (word pointer in the slot, wide value
behind it) preserves offsets but contradicts §5.U's repr-true
fields direction; the width-summed per-field layout stays the
stamped form, now sized: one emitting family, six offset sites,
one live instance to prove against, mn-zip-deep-class fixtures to
grow for the f64-state shape.
THE FENCE FINDING (2026-08-07 — the stamp's last structural
clause, banked before the build opens): the hstate record's FENCE
at offset 4 carries NSTATE (the count), and dispatch locates arms
FENCE-RELATIVE by emitted arithmetic that loads the fence and
multiplies by 4 at RUNTIME — so width-summed state slots change
the fence's SEMANTIC: it must carry the state region's BYTE SIZE
(or the arm base directly), and every dynamic fence reader's
emitted sequence adapts (`8 + fence` replacing `8 + 4*nstate`).
The build therefore lands as a TRANSITION even with zero wide
slots in the current wheel (the dispatch arithmetic bytes change),
and the writer census gains the LOWER-side offset producers:
LStateSlotStore's slot_offset is precomputed upstream (the
resume-with-state lowering) and the POff(8+i*4) path entries
likewise — the width summing must happen at ONE projection both
sides read (a state_field_offset(fields, i) beside
tuple_elem_offset's width-summed precedent) or the two layers
disagree. Build shape, final: (1) the one offset projection;
(2) emit_state_init_writes + LStateSlotStore + the arm-body read
+ op_*_handler_result go repr-true through it; (3) the fence
stores bytes; (4) the six-plus-lower sites re-read through the
projection; (5) the f64-state fixture RED first; (6) march as
TRANSITION; then 5.1a's gate-drop re-attempt rides the next
iteration with the banked cost expectations.
THE FENCE HAS NO RUNTIME READERS (2026-08-07, the enumeration's
close): the offset=4 loads in the emitted dispatch are WORLD-CHAIN
node reads (the [key][entry][parent] node's entry field;
world_find's walk), not the hstate record's fence — the ARM BASE
is precomputed into the per-effect [record, base] evidence entry
at install emit (emit_handler_effect_entries), so every
state-offset computation is an EMIT-TIME CONSTANT. The build
therefore shrinks: no runtime dispatch arithmetic changes — the
one offset projection (state_field_offset beside
tuple_elem_offset), the emit-constant sites re-read through it
(LHandleWith's size + init writes + the evidence-entry base +
LStateSlotStore's upstream slot_offset producer + the POff paths
+ op-result widths), the fence field stays or re-encodes freely
(nothing reads it live — a vestigial-write candidate the build
may delete), and the f64-state guard (landed, exit 42) holds
green. The gate-drop re-attempt follows the march.
THE LOWER PRODUCER PINNED (2026-08-07, the map's last piece):
lower's offset comes from resolve_state_slot_offset (lower.mn:4544)
— `8 + idx*4` over the slot-order NAME list (config ++ state), fed
by resume_commit_prefix's stores — and that site has NO repr
access (names only). The shared projection therefore needs the
TYPED state field records threaded to both layers — they already
ride the env's HandlerKind (config_tparams + state with init
nodes), so the one projection takes the typed field list + a
name-or-index and width-sums via repr_of(lookup_ty(init-handle));
resume_commit_prefix's caller threads the typed list where it now
threads names, and emit's install reads the same list it already
holds. THE AGREEMENT CONTRACT: one fn, one home (beside
tuple_elem_offset in the emit's field machinery or types.mn if
lower may not import backends), both layers' offsets equal by
construction — a census assert (emit offset == lower offset per
field) is the build's belt. THE MAP IS WHOLE; the build is a
self-contained arc: the projection fn, the two threading edits,
the five emit-site re-reads, the POff paths, op-result widths,
the march (CLEAN expected on the all-word wheel — every width is
4 today), then the wide store arms and the gate-drop re-attempt.
THE ABI MEASUREMENT INVERTS THE DESIGN (2026-08-07 — one
artifact read replaced the whole mapped build): the FLOOR's fold
takes `(param $init i32)` — a generic float rides a BOXED WORD
end to end (the f64-state micro passes at 42 through word slots),
and the hstate record's READERS are the SHARED arm fns
(op_fold_handler_yield/result — one global pair for floor and
twins alike), so the slot ABI is FLOOR-OWNED WORDS by
construction. One layout already exists; repr-true slots would
break the shared arms. THE CORRECTED FIX, two twin-local emit
arms and nothing else: at a twin's state-init/store where the
value's repr is wide, BOX (alloc an 8-byte cell, f64.store,
i32.store the pointer — the floor's own convention); at a twin's
handler-result read where the result repr is wide, UNBOX
(f64.load through the returned word). Zero layout change, zero
lower change, the fence untouched, the projection/threading/fence
map SUPERSEDED (banked above as the repr-true-arms future — slots
go wide only when the ARM fns twin too). The earlier boxed-slot
rejection was wrong for THIS record class: §5.U's repr-true
fields bind records whose readers are repr-aware; shared floor
arms are not. Acceptance unchanged: the gate-drop march
assembles, f64-state stays 42, the +17% emit and in-ceiling RSS
ride the re-attempt.
THE TWO ARMS AT FINAL PRECISION (2026-08-07): the conversion pair
already exists as emit_wide_ref/emit_wide_deref (wasm.mn:4696 —
the arg-boundary box/unbox emit_args_word uses: spill f64 to an
8-byte cell, word address on the stack; f64.load back). BOTH arms
key on the typed repr at the site, so floor contexts read RI32
and no-op byte-identically (Law 7) while twins convert: (ARM 1,
ready) emit_state_init_writes' value arm appends
emit_wide_ref(tail_expr_repr(init)) after emit_expr(init) — the
boxed word enters the floor-owned slot; the LUpval config arm
stays untouched (already a word). (ARM 2, one region left) the
install's RESULT READ — the `(call $op_*_handler_result)` the
fold twin's body carries is LOWER-BUILT body LIR (the direct
tier), so the unbox hooks where lower constructs that read (wrap
in the wide-deref when repr_of(lookup_ty(install-node)) is wide)
or at its emit — the named next read is lower's handler-lowering
result-read construction site. With both arms the twin's f64
result typing is satisfied at the source, the header/body agree,
and the shared arms never change. Then: solo checks, the
gate-drop probe (the fold twin must assemble), the march, and the
5.1a re-attempt. One iteration of today also re-learned kill (1)
the hard way: a worthiness-SEED probe twins nothing (candidacy
gates upstream at the site collection) — the closed peer's own
record already said the working force was the gate, not the seed.

`Hβ.perf.per-decl-arena` — STAMPED whole 2026-08-07 (§11 4.3; the gate
peer `Hβ.infer.region-on-tee-alloc-absorb` folds in below). WHAT EXISTS,
traced: heap_mark/heap_reset with the virginity contract
(memory.mn:139-145), battle-tested at the BATCH boundary (per-micro
inside `mentl test` — the arena's first real workload); the paged spine
SIZED for per-decl banding by its own comment (graph.mn:91-93 — max
2,305 mints/decl measured, p99 331, 7× headroom); the region proof
(own.mn's region_tracker — every fn body a region, return = transfer);
4.1/4.2 landed as the ordered escape police (T_UseAfterMove + the honest
grade); emit_memory_arena DORMANT (wasm.mn:159-182 — the region
semantics belong to the $alloc body, the seam-gated
Hβ.emit.memory-strategy-body-swap); persist reading [0, heap-line) as
the image (memory.mn:74-99). THE DESIGN — the image/scratch split,
row-classified, no copy-out: two bump spaces in the one linear memory
(image low/monotonic via $ialloc; scratch high, mark/reset per decl;
Hβ.emit.image-map-fold draws the boundary as one fold). Classification
by STRUCTURE ROOT, carried by the writer's own row (an ImageAlloc
effect on the growth fns — the medium's vocabulary, never a runtime
tag). The IMAGE writers, traced set of SIX families: (1) spine
band-open pages (spine_ensure/list_extend_to), (2) the env flat buffer
+ index-bucket conses (src/env.mn growth paths), (3) the intern table
(src/intern.mn — largely parse-phase, pre-mark by construction), (4)
published schemes + their type trees at env_extend (SHRINKS to
near-zero at rung 3 — the families' one transitional member, deleted
by 5.2's own diff), (5) the WAT output buffers (wat_emit
accumulation), (6) the diagnostic bank + oracle-queue roots.
Everything else is scratch and dies at the decl reset. The decl
boundary is the driver's per-decl walk bracketing mark/reset in the
USER-FACING form — a `~>` region install absorbing Alloc — so the
absorb license IS the reset license (the gate peer's whole content;
Mentl solves Mentl). REJECTED BRANCH, priced: copy-out at the boundary
(the return-transfer materialized as a deep copy below the mark) — the
walker is the deleted .kai serializer's shape, and the split buys what
copy-out cannot: the image IS band B's persist set (persist = memcpy
of [0, image-line), scratch excluded by construction). 4.3 and 9.1
converging on ONE boundary is the design's truth signal. PRICED
(§5.O): zero new scans (static per-site classification; O(1) reset;
band-open unchanged); the working set collapses to one decl's live
set. COST INSTRUMENTATION IS BUILD STEP 0 — a doc-truth finding rides
this stamp: §5.O's "march measures wall+RSS / PROVENANCE carries the
cost line / verify-baseline ratchets peak" is STALE prose (none true
of today's march.sh); the instrumentation returns first and the win
lands as a diff of two measured reads, never a claim. MARCH CONTRACT:
TRANSITION by construction (the two-pointer layout shifts heap
addresses → interned offsets → WAT bytes; the 2026-07-17
"output-invariant" refutation governs; re-pin from m3). GATES,
RED-first: (a) the per-decl reset fires on the wheel compile (a
counter ≈ decl count); (b) a post-reset image-reachability audit leg —
the mis-classification tripwire, because virgin-zero reads are SILENT
and the audit is the loud face; (c) the peak-RSS diff recorded
in-baseline; (d) the per-micro batch boundary keeps its green. BUILD
ORDER, marched: (0) cost instrumentation + measured baseline — ✅
LANDED 2026-08-07 (gen under GNU time, the pin's cost line, the peak
ratchet seen RED at ceiling 1 then banked at 1,830,000 KB over three
~1,742,900 KB reads; the self-compile's honest footprint is ~1.70GB /
~8.4s, correcting the era-stale ~694MB); (1)
ImageAlloc vocabulary + $ialloc emit — ✅ LANDED 2026-08-07 (pin
b5730e6110ac: the effect + ialloc in memory.mn, one name in
is_substrate_mem_op grounding it at the root gate by derivation, the
emit arm riding $alloc with the step-3 fork named; micro
mn-image-alloc RED→42; the cost loop's first pin measured a ~4%
cross-invocation RSS spread, named in the pin).
STEP-2 CORRECTED 2026-08-07 (the build refuted the stamp's mechanism
before a line landed): "classify the growth fns onto ialloc" has NO
SEAM for constructor-built structures — spine_open_loop's pages, the
env buckets, the intern table all allocate through the emitted
constructors ($make_list, record mk → $alloc), not through a
wheel-source alloc() call, and row-only decoration is FALSE prose the
medium itself narrates against (a declared-but-unperformed ImageAlloc
is T_OverDeclared). The classification is therefore an EXTENT
BRACKET — exactly the gate peer's own form (a region install
absorbing Alloc): paired substrate ops `image_enter()`/`image_exit()`
on ImageAlloc (depth-counted, borrow_depth's shape and
heap_mark/heap_reset's pairing idiom), bracketing each family's
growth extent so the rows come out TRUE via real performs; the `~>`
tee spelling stays the peer's absorbing refinement once handler
installs can reach the substrate allocator. THE CORRECTED ORDER: (2a-i)
the pair's vocabulary — ✅ LANDED 2026-08-07 (pin e524668b29f3:
image_enter/image_exit declared, recognized, emitted as $image_depth
bumps with the global demand-gated on the pair's performs; zero wheel
performs keep the pin CLEAN; micro mn-image-region RED→42); (2a-ii)
the family brackets + the census — FAMILY (1), spine_ensure's growth
extent, ✅ LANDED 2026-08-07 (pin 2f5ef189a823, the priced TRANSITION
at 6 diff lines; the census rides the extent delta — outermost enter
marks, matching exit accumulates — two branches per bracket, never
per allocation; the row cascade measured at twelve driver-spine
widens, caught by verify's census ratchet after the march, which does
not gate census).
THE CORE REFUTATION (2026-08-07, before family 2 landed a line):
SITE-CLASSIFICATION IS UNSOUND FOR THE VALUE GRAPH. A spine cell is a
WORD pointing to a heap record (the substrate's own definition —
every value a handle-addressed record); the Ty/GNode/scheme values
those cells and the env's entries point at are allocated DURING
inference, interleaved with scratch, and published later by
POINTER-WRITE — so no extent bracket at the publish site classifies
their allocation, and a per-decl reset would zero live
image-reachable values under every column written that decl. Extent
brackets are sound exactly where the extent IS the publish (band-open
pages — family 1 stands; flat-buffer growth shares the property for
the BUFFER cells, not their pointees). The sound forms, priced: (i)
per-decl EVACUATION of live-out values (a generational nursery copy —
structure-copy, not wire-format, so the .kai objection weakens, but
the walker cost and shared-identity questions remain); (ii) COLUMNS
FIRST — rung 3 (schemes-are-edges, §11 5.2) plus the 5.5 column arc
move published facts INTO spine columns and flat buffers, making the
image set = pages + buffers BY CONSTRUCTION, extent-bracketed exactly
as family 1 already is, with no per-value classification anywhere;
(iii) no reset (the arena dies — refused, the hub's riders stand).
CHOSEN: (ii), the Mentl-native form — the graph IS the image.
RE-SEQUENCED: 4.3 PAUSES at 2a (family 1 + the census print next pin
measure the banded fraction honestly); 2b's fork/reset DEP-GATES on
the column arc (5.2 + 5.5); families 2-6's brackets land in the
column era where each family's storage is a page or flat buffer by
construction. §11 4.3's entry carries the same correction; the
reachability audit leg survives as 2b's tripwire unchanged; (3) the
dormant emit_memory_arena resolves at 2b — its real body or its
deletion, one strategy read from the module's own proof.
THE COLUMNS-FIRST CHAIN ITSELF REFUTED (2026-08-12, the independent
adversarial pass, four blocking receipts — this supersedes (ii)'s
"by construction" clause in place): the spine's columns are POINTER
columns (nine of eleven store heap records; only canon/narrowing are
words), and their POINTEES — GNode/NodeBody/Ty-under-NBound/Span/
DispatchTier/InstallShape/StateSlotHome records — are allocated
through plain alloc interleaved with scratch, then published by
pointer-write: the column arc relocates where the pointer is STORED,
never where the pointee is ALLOCATED, so a per-decl reset dangles
every cell into virgin zeros. Three more independent breaks: the
relocation's OWN apparatus (decls_col/emitfns_col/refs_col/holes_col
cons-state plus the demand-latched emitfns_idx) is unbracketed heap
state its pre-landings GROW; the judgment side's unit is the PASS,
not the decl (trial+final movers apparatus, cross-group parked
gates, prereg live links — each load-bearing by design); and the
relocation DISSOLVES the per-decl boundary the reset was specified
against (construction extents nest inside other entries' emission
extents — the surviving grain is per-ENTRY). THE LAW THE ARTIFACT
ALREADY TEACHES, extracted from its three production resets (mcp's
guarded message region, the per-micro region, the per-twin
mark/stream/reset): A RESET IS SOUND EXACTLY WHERE THE EXTENT'S
PUBLISH CHANNEL IS A BYTE COPY INTO A FLAT BUFFER OR PROVABLY EMPTY
— NEVER A POINTER-WRITE. A representation property, not a
sequencing property. THE MISSING KEYSTONE, banked here as its own
peer: `Hβ.graph.column-pointees-are-words` — column values become
words/pool-indices (packed repr per column, an explicit answer for
Ty trees that rides instantiate-shares-never-clones or Ty-as-node),
the representation arc without which no judgment-side reset is ever
sound. THE CORRECTED DEP CHAIN: (1) the image_bytes census print +
brackets on flat-buffer families 3/5/6 (family 2 excluded —
condemned toward D6), decidable NOW, relocation-independent; (2)
rung 3 WHOLE (movers → 0 deletes family 4, collapses the judgment
boundary pass → group); (3) the relocation WITH its cons-state
re-homed to bracketed flat buffers as named pre-landings; (4) the
pointee representation arc; (5) only then 2b's fork/reset at the
grain that exists then (per-entry for lower/emit; per-group-drain at
best for judgment); (6) the ~> absorb spelling rides the
evidence-seam peer independently. SMALLEST SOUND FIRST LANDING: the
per-fn EMISSION region — generalize the proven per-twin
mark/stream/reset shape to the general per-record emit path (probe
first: any post-mark registry/table allocation on that path), landed
with the census print. D5's honesty note: image_bytes has ZERO
performers and memory.mn's comment states the census print in
present tense — mechanism prose ahead of the artifact, trued
2026-08-12 in the same commit as this fold.

`Hβ.own.use-after-move` — BUILT (2026-08-07, pin 8ba768c810c4, before
the arena exactly as prescribed). The mechanism was one leg's ORDER:
the ledger's consume arm checked `borrow_depth > 0` before the
used-set, so every borrow surface (conditions, scrutinees, ref-param
args, every seq-op arg — len's resolved Ref param walks its arg
borrowed) read moved owns silently. Now `set_contains(used, name)`
reads first: consuming second use stays armed E_OwnershipViolation;
borrow-read of a moved name is T_UseAfterMove (narration; wheel census
ZERO at birth, use_after_move_max: 0 ratchet). Gate:
tests/frontier/mn-use-after-move.mn via run_narration, seen RED.
RESIDUAL — the ARMING: joins diag_refuses at held wheel-zero after an
E_OwnershipViolation-precedent falsification pass (the unresolved-
callee borrow default reports true reads-after-move beside the miss —
verify no false channel on resolved programs first).

`Hβ.infer.grade-is-join-and-mode` — BUILT 2026-08-07 (pin 4115ed285d39,
against the stamp; the LEDGER entry of the same name carries the arc).
The walk landed exactly as stamped — usage_of's (consume, read) pair, ⊔
across alternatives, mode from the callee product, lattice ops at
types.mn, count_uses family deleted whole (its NStmt(_) => 0 blanket had
never counted a statement-level use — a third measured blindness, closed
by the walk's explicit LetStmt/ExprStmt arms). TWO STAMP CORRECTIONS the
build measured: (1) the "order-dependence exists today, NAMED not
widened" pricing was wrong-in-degree — the walk's callee-product read
AMPLIFIED it (set_contains calls its textually-later helper; the
consume-default slot graded it Own; every caller moved; the wheel
refused on driver_collect_visit's `visited`). Closed structurally in
param_borrows' one home: a still-Unmarked resolved slot BORROWS (the
read-safe default — passing to an ungraded or unused product must not
burn the caller's own). (2) The blast landed in the MOVERS channel, not
T_UseAfterMove: +188 moved schemes (474 → 662, in-baseline
justification) — forward callees resolve between trial and final, so
grades move with them; rung 3's class-based reads dissolve the class
and this order-dependence together. T_UseAfterMove held 0 throughout;
T_OwnUnconsumed reached wheel-ZERO (collect_arm_tags' authored `own
init` dropped — fold's f is a param callee whose product the grade
cannot read; the seed's transfer is structural). RESIDUAL, banked: the
param-callee blind spot (calling through a fn param reads its args —
the grade cannot see the param's eventual consumption; surfaced only
as under-consume → Ref, the borrow-safe direction) and the
T_OwnUnconsumed arming licence now open at wheel-zero (same
falsification bar as use-after-move's). Band-H baseline rides: 84
authored `own` + 763 authored `ref` in src/ — now honest counts to
drive DOWN, no longer compensation.

`Hβ.parser.unclosed-construct-reports` — an unclosed `effect` or
`handler` brace SILENTLY DELETES THE PROGRAM: both arm loops treat
TEof exactly like a closing brace and their stray-token recovery skips
forward, so `main` is consumed as an effect op, `= 0` is skipped token
by token, and the medium reports SUCCESS on a file with no program in
it (zero diagnostics, exit 0, an empty audit). Data-dependent silence —
the more idiomatic the following code, the more completely it
vanishes. `unclosed_eof` already exists with ONE call site; these loops
never took it. RED banked: tests/frontier/mn-unclosed-effect-brace.mn.

`Hβ.prelude.stage-law-and-reachability` — the shipped vocabulary
violates its own Stage Law at ten public signatures (join · reduce ·
scanl · nth · unwrap_or · starts_with · ends_with · contains ·
index_of · replace), so `"a,b,c" |> split(",")` SILENTLY returns one
part (the pipe fills `sep` with the datum) and `scanl` reverses
`fold`'s argument order — a learner who internalized one writes the
other wrong every time. `tuple_set`'s own documented pipe idiom is a
WILD WRITE at address `a*4`. Beside it: `join`/`unwords`/`unlines`
TRAP in raw WASM (`join_loop`'s unannotated params reach the `++`
no-guess floor — and SYNTAX lists that diagnostic as DISSOLVED, a
doc-truth contradiction to settle at the emit floor). Fixes: flip the
ten signatures, pin `join_loop`'s Intent Boundary, arm the concat
floor as a compile refusal, and add a STAGE-SHAPE audit tier so the
class self-polices (the verb-shape tier's sibling).

`Hβ.runtime.slice-collapse` — `slice_raw` has no collapse branch, so
`rest()`-recursion builds N nested slice nodes and index reads walk the
chain: `zip_with` / `intersperse` / `scanl` / `merge` are quadratic,
`sort` is O(N² log N), and every ML vector primitive inherits it. Four
lines at the one writer (tag-4 parent + summed offsets) make the class
unconstructible; `iterate_from` already pays this bill once by
flattening at its entrance, and taking that workaround a fifth time is
the census law's stop signal. Separable from band D's String work.

`Hβ.lib.vocabulary-gaps` — what a newcomer reaches for and cannot find,
each with its kernel home: `sort_by` (the compare leaf over a key
projection, §5.U); a user-facing `Map`/`Set` (the §4① ordered-keyed-set
unification — `imap` is a compiler-internal primitive that shadows
rather than replaces and fixes 4096 buckets, so word-count is not
writable); `effect Random` with clock.mn's four-tier handler pattern
(host / seeded / record / replay) — which no other stdlib can offer,
because `!Random` PROVES determinism transitively and property testing
becomes a handler swap with exact replay, and today its absence blocks
ML weight init (zeros/ones cannot break symmetry) and lib/test.mn's own
named property tier; a prelude `Fail`/`catch_fail` pair so "errors are
effects" has somewhere to point; and an integer `abs`.

`Hβ.syntax.open-row-tail` — the biggest ceremony in the language: the
kernel's row tail is tri-state (EtClosed / EtVar / EtAll) and the
surface can spell only two. Declaring the one INTERESTING effect on a
body that also touches a list forces `with Memory + Alloc + Tally` or a
standing error-worded report on a CORRECT program. Proposal: `with
Tally + ..` — the record-rest glyph at the row, one absence-marker
family — semantically `row_subsumes`' existing directional gate with an
EtVar tail, zero new algebra, and `mentl tighten` still offers the
closed form as the capability-unlocking move.

`Hβ.run.refuses-on-error` — `mentl check` exits 1 on a file `mentl run`
executes at exit 0: error-worded diagnostics with wrong output, and a
raw wasm trap from the simplest pipe misuse. One bit restores the
contract — the RUN verb reads the diagnostic ledger's error count
before executing (the compile artifact keeps the arming ratchet's
licence), or the word "error" is reserved for classes that refuse. A
student who watches an "error" run learns errors are advisory.

`Hβ.emit.world-walk-memo` — the per-perform world walk is
BODY-INVARIANT: 896 `$world_find` + 1,446 `$ev_perform_node` runtime
walks, and 1,268 of the 1,446 resolve ONE key (the emitter re-resolving
its own output sink per emitted fragment — `$emit_binop` walks the same
key NINETEEN times in a body with zero world writes). A per-body
per-key memo local, invalidated at exactly four emit-visible node
kinds, sound on the call-balanced world the brackets already enforce.
NOT the retired `$state_g` cache. Perf share unmeasured per §5.O's law;
the deletion is sound regardless.

`Hβ.emit.yield-reachability-closure` — the k2 yield wrap is a 240:1
over-approximation: 3,336 wrapped call boundaries and 3,355 flag reads
against 14 real `$__k_extend` compositions (~17k WAT lines of
scaffolding). The algorithm is a `closure_fix`-shaped transitive
yield-reachability over the call graph — exact for the 23.5k
direct-call sites, with the row check surviving only on HOF values.
Composes with band N's frame-rep-from-cardinality.

`Hβ.lower.double-walk-and-dead-fields` — two mechanical deletions the
lower audit proved: the gate and the emit run `walk_lemit` TWICE over
the identical post-reach tree under identical seven-collector brackets
(one bracket hoist, one walk, two drains — the handler IS the state and
the drain IS the read); and `LFn`'s arity and effect-row fields have
ZERO readers at all 24 destructure sites (the `resume_kinds` pattern
verbatim — and `executable_boundary_row` exists solely to compute the
dead row, its refusal half worth keeping under an honest name).
Law-7-inert by construction.

`Hβ.infer.handler-residual-outside-the-scheme` — RESOLVED (2026-08-06,
the same session as the prune fix, five probe-kills deep): the residual
now READS THE INSTALL. The attributed mechanism held — HandlerKind's
raw r_handle bypasses generalize/instantiate — but the dig found THREE
stacked losses, each measured before believed: (1) HandlerKind stored
the PARSE-placeholder config TParams at all three registration writes,
so any install-time read chased dead cells (the census showed cell 4 —
a parse-era handle); it now stores the MINTED tparams the arms bind.
(2) The handler-arm scope's exit ran the completion prune with an empty
keep-set, dropping the arms' config-fn edges — the arm scope's
SIGNATURE is the config cells + the handle-result, so its exit now
passes signature_free_roots(tparam_cells ++ [s_h]) exactly as a named
decl does. (3) A residual that is exactly one config-var edge finalizes
as an ALIAS of that free cell (the flat store's canonical form), and
read_bound_row answers pure on a free root — the measured root-FREE
loss; the residual is now read as the CELL AS AN EDGE
(resolve_row(mk_ef_open([], resid_h))), the same shape a scheme's row
rides. The install completes it: residual_with_config_args joins each
CALLED config arg's row (root-membership in the residual's edge set is
the graph's own record of which config fns the arms call; labeled or
arity-short installs fall back verbatim, the resolve_call_args-shared
pairing named as the refinement). MEASURED: leak-handler-residual
refuses (the crown's leak- contract, seen RED first); the c05 each
fixture (`fn f(xs) with !WASI = each(...)` — the vocabulary face)
refuses; the wheel's own census surfaced 19 falsely-passing sites (18
declaration widens + main's root stack gaining ~> verify_ledger ~>
diagnostics_handler), converging to census 0 with TRANSITION m3 == m4
in two rounds. `Hβ.effects.config-fn-row-in-residual` resolves with it
(one seam, the absorb side — union at the install IS "read the config
row where it already lives"). Rung 3's dissolution of the tower stands
as the deeper form; this closes the soundness hole on the standing
representation.

`Hβ.effects.config-fn-row-in-residual` — RESOLVED (2026-08-06) with its
sibling above: the tee's `extra` is residual_with_config_args — the
residual joined with each called config arg's row, read live off the
install's own arg nodes. One seam, closed at the one absorb site.

`Hβ.lower.*` and kin — TEN PEERS THAT LIVED ONLY IN COMMENTS, banked at
their one home 2026-07-31 (the lower audit's finding 12: each was
declared in a `lower.mn`/`wasm.mn` comment as a positive-form named gap
and appeared ZERO times in this file, so none was visible to the
roadmap, to `mentl teach`, or to the frontier ranking — a gap that
lives only in a comment is a residue-index entry that has not found its
home): `Hβ.infer.order-free-live-row` (lower.mn:1221 — the escaping-row
flow closure's own written dissolution; SUBSUMED by
`Hβ.infer.schemes-are-edges`, whose second uncounted dividend is the
~365-line second effect-analysis engine in lower) ·
`Hβ.lower.diverging-callee-analysis` (lower.mn:1722 — `expr_diverges`
is an AST walk re-deriving a TYPE fact; landing SYNTAX's `-> !` TBang
arm makes it `ty_is_bottom(lookup_ty(h))` and the inter-procedural case
falls out free, so the peer DISSOLVES rather than builds) ·
`Hβ.row.builtin-effect-kind` (lower.mn:1121 — a name-literal ladder
where the env holds the declarations; the severance-vocabulary landing
is the precedent, and the marker's seed-byte-parity argument is STALE:
the seed was deleted 2026-07-10, the constraint is m3 == m4) ·
`Hβ.lower.multishot-anonymous-install` (lower.mn:106) ·
`Hβ.lower.k2-nontrivial-prefix-arg` (lower.mn:4003) ·
`Hβ.lower.fanout-gpu-host-import` (lower.mn:2486) ·
`Hβ.lower.continuation-callboundary-bubble` and
`Hβ.lower.multishot-reyield-composition` and
`Hβ.lower.multishot-arm-state-commit` (lower.mn:272-273, the k-spine's
three named floors). The tenth,
`Hβ.lower.value-fn-availability-edge` (lower.mn:1292), is RESOLVED —
its own comment says "now LIVE" — and is recorded here only so the
stale prose is struck; that distinction between an open gap and a
resolved one is exactly what an index carries and a comment cannot.

`Hβ.dataflow.feedback-becomes-whole` — the design stamp for PLAN §11
Phase 3.6 (banked 2026-08-07; UNBUILT — this entry is what gets built,
and it carries ONE FORK FOR MORGAN, below). FOUR MEASURED FACES at pin
c46691d75a57: (1) `<~` contributes NO iterative effect — the census
fixture's fb types Pure, and lib/dsp's lowpass_iir (declared
`with Sample + Memory + Alloc`) publishes only Memory + Alloc, the
authored Sample vanishing because nothing in the body performs it;
(2) the FeedbackSpec constructors (prelude.mn:519 — delay/accumulate/
filter_spec) are PURE wrappers, so SYNTAX's "a state-element — a value
that performs the iterative effect" is design the artifact never
realized; (3) E_FeedbackNoContext exists in the DiagKind catalog with
ZERO construction sites — the context requirement is entirely
unenforced (the fixture's `x <~ inc(1)` draws only the FeedbackSpec
type mismatch); (4) the zero-delay causality refusal
(`Hβ.dataflow.causality-compile-error`, Faust's rule) is absent —
Delay(0) types like Delay(1). THE DESIGN, traced: infer's PFeedback
arm gains the verb's own typing rule — (a) resolve the ITERATIVE
CONTEXT: an Iterate-class effect present in the enclosing fn's
declared row or installed by an enclosing `~>` (the static
enclosing-tee walk the where verb's schedule badge already built —
reuse it); absent → E_FeedbackNoContext finally fires; (b) CHARGE the
context's effect into the body row (inf_add_row at the arm — the
recurrence performs the tick-advance each iteration, so fb stops
typing Pure and lowpass_iir's authored Sample matches its body);
(c) the CAUSALITY refusal: a literal Delay(0) RHS refuses at the arm
(the decidable case; a computed delay rides Phase 8's refinement
tier); (d) `Hβ.dsp.state-element-install-once` (the !Alloc reclaim)
rides the arena (Phase 4.3) — named, not this build. GATES: the fb
census-fixture site TRUED to a real spec (`x <~ delay(1)` under a
declared context; the census's `<~` pin moves with it), a DSP row
fixture asserting lowpass_iir publishes Sample, a Delay(0) refusal
fixture RED-first, and E_FeedbackNoContext's first firing gated.
THE FORK DISSOLVED (2026-08-12, derived from the kernel per the
no-deferrals charge — the thesis answered it): Iterate-class
membership is the HANDLER'S PROVEN DRIVE STRUCTURE — the
resume-discipline inference the medium already runs. The refuted
branch (A) was structural at the wrong altitude: it read the effect
DECL's op shapes, where any shape is coincidental; the structure that
proves iteration is the handler's ARMS, and that classification is
already load-bearing (dispatch tiers ride it) and already JOINED at
the EffectOpScheme (draw_op_edges folds every declared handler's
resume_grade), so membership is an env READ at the PFeedback arm —
no install needed in scope, no new surface, no allowlist. Branch (B)
dies by the body-is-the-contract law verbatim (the @resume=
precedent: authoring a marker would declare what the arms already
prove). The class predicate: the op's joined resume grade is the
LOOP-DRIVING shape (resume under loop/recursion ancestry — the
MultiShot driver classification), which §4④ makes exactly right:
search, sampling, backtracking, and the clock are ONE primitive, so
a `<~` prior under ANY loop-driving handler means "the value from
the previous resumption" — the clock is the DSP instance, not the
definition. An effect no declared handler drives is ungraded → not
Iterate → E_FeedbackNoContext fires honestly (nothing anywhere gives
"prior" meaning). SOTA note: Faust's ambient clock and Lustre's
clock calculus become a typed, per-instance, INFERRED fact. The
build unblocks whole: (a)-(d) above stand, with (a)'s membership
test reading the EffectOpScheme's grade. TWO MECHANICAL
PREREQUISITES traced at the build's opening (2026-08-12, both
decision-free): (1) op_resume_discipline relocates from lower.mn:2054
to the env altitude — its one home is where the EffectOpScheme lives;
infer's PFeedback arm and lower's tier selection become its two
readers through the import. (2) The effect→ops REVERSE EDGE lands at
effect registration (the one writer that already draws op→effect):
an smap ename → [op names], the reverse-edge precedent's third
application — membership then enumerates the ambient effect's ops
and asks each grade, O(ambient × ops). The PFeedback arm's own
comment names the waiting peer (Hβ.effects.iterate-class-declaration)
— it RESOLVES onto this read; the "declared fact" it awaited is the
joined grade, already declared by every handler body. Build order:
the two prerequisites, then (a) ambient resolution + E_FeedbackNoContext's
first firing (RED-first fixture), (b) the charge, (c) the Delay(0)
refusal with its own DiagKind, (d) stays arena-gated. Gates as
stamped; the wheel's 15 recurrence sites are the no-false-refusal
control.
BUILT 2026-08-12 — PARTLY, AND THE REST KILLED BY ITS OWN CONTROL (pins
7260286fcd68, fc93f1957fb9; the LEDGER entry carries the arc). What
LANDED: prerequisite (1), op_resume_discipline relocated to src/env.mn;
and (c), `E_ZeroDelayFeedback` armed at birth — `<~ delay(0)` refuses,
the eleventh refusing class, gate tests/micros/mn-refuse-zero-delay.mn
seen RED (the identical program RAN, exit 30). What DIED:
— **PREREQUISITE (2) HAD NO REFERENT.** `register_effect_ops`
  (infer.mn) already env_extends the effect name with
  `EffectDeclKind(op_names)`, at the same one writer that draws
  op→effect, and `mentl where`'s handler-covers badge already reads it.
  The banked smap would have been a second copy of a live edge — the
  Carried-Truth violation the entry was written to avoid.
— **THE MEMBERSHIP PREDICATE IS REFUTED ON THE ARTIFACT.** The
  dissolved fork's answer ("the loop-driving resume grade IS the
  class") classifies no clock: measured by badge,
  `choose : Choice op — resume t ->* answer` is the only MultiShot
  family on the wheel, while `tick` / `advance_sample` / `sample_rate` /
  `current_sample` / `yield` / `result` / `iter_context` are every one
  `->1`. The derivation's error is locatable: §4④ unifies search,
  sampling, backtracking and the clock as one SUBSTRATE (a resumable
  continuation), not as one CARDINALITY — a clock handler advances
  state and resumes ONCE per tick, because the iteration is the
  caller's loop. Under the predicate, E_FeedbackNoContext fires at all
  thirteen wheel `<~` sites; the no-false-refusal control refuses the
  build before a byte changes.
— **(b) THE CHARGE DIES WITH IT, and independently on principle.**
  With no membership test there is no effect to charge; and charging
  `Sample` at the arm so that lowpass_iir's authored row matches would
  be inference writing what the annotation asked for — the
  annotation-as-input drift, against SYNTAX's own law that a declared
  row is a CONSTRAINT verified against the inferred, never a contract.
  lowpass_iir is honestly OVER-DECLARED today; `T_OverDeclared` is the
  true narration.
— **E_FeedbackNoContext STAYS AT ZERO CONSTRUCTION SITES, and that is
  now a positive finding rather than a gap.** Its referent — an ambient
  iterative context — is a Faust inheritance the emission never adopted:
  a `<~` site is a per-site state register whose "previous iteration" is
  the enclosing fn's next invocation (dsp/signal.mn's own comment says
  so: "each with its own state global, all advanced once per sample as
  bandpass_step runs down the per-sample bandpass_loop"), which is why
  bandpass_step needs no row. Making the class fire before the clock is
  a proven fact would canonize a false refusal on correct code. Its
  honest home is `Hβ.dataflow.clock-calculus-sample-rate` (Phase 8's
  DSP verify tier): when the clock is INFERRED, "no clock here" is a
  measurement and the refusal is its projection. The `IterContext`
  marker effect (lib/dsp/clock.mn — `iterate_context` / `no_iter_context`)
  is the vocabulary already waiting for that landing.
Phase 3.6 is therefore CLOSED at its causality face and REDIRECTED at
its context face; the remaining `<~` work is the depth read below and
the clock calculus above.

`Hβ.dataflow.feedback-delay-depth-unread` — the `<~` state element's
authored depth reaches NO reader. MEASURED 2026-08-12 by probe at pin
7260286fcd68: the identical recurrence returned 30 under `delay(0)`,
`delay(1)` and `delay(3)` alike, so `delay(N)` emits one slot for every
N and a developer asking for a three-sample delay silently gets one.
`FeedbackSpec = Delay(Int) | Accumulate(a) | FilterSpec(Int, [Float])`
(lib/prelude.mn) declares the depth; lower's PFeedback arm never reads
it. THE ULTIMATE FORM: the depth is read, `delay(N)` emits an N-slot
ring of priors, and `delay(0)` refuses as it does today — the refusal
becomes ONE ARM of the read rather than a standalone check.
`FilterSpec`'s tap count is the same field at the same site. Sequenced
with the DSP verify tier (Phase 8) beside
`Hβ.dataflow.clock-calculus-sample-rate`, since a ring of priors and a
clock are the same question asked at depth and at rate. The gate that
lands with it: a fixture whose `delay(2)` recurrence differs
observably from its `delay(1)` twin — impossible to write today, which
is exactly the measurement.
RESOLVED 2026-08-12 — the depth is read, and the read is ONE projection
with three arms. `feedback_depth` (infer.mn) answers `DepthLiteral(n)` /
`DepthComputed` / `DepthUnstated` off the authored RHS, and every
judgment about a line is an arm of it: the causality refusal became one
(`n <= 0`, widened from `n == 0` so a negative literal cannot size a
line either), lower's `feedback_line_depth` takes the slot count from
the same read and carries it on `LFeedback(h, DEPTH, body, spec)`, and
the emit declares the line from that number and shifts it by the same.
One number, two readers, so a line can never be emitted deeper or
shallower than it is declared.
THE LINE IS A REGISTER FILE, not a ring: `$s<h>` (newest) through
`$s<h>_<N-1>` (oldest), globals declared at module init, the prior read
from the OLDEST and each tick advancing every slot by one — oldest
first, so each read precedes its own overwrite. Zero allocation, so
`!Alloc` survives at any N, and the shift pairs come from zipping the
line against its own tail rather than an index countdown. A depth-1
line has no pairs and no `_i` slots, so it emits byte-for-byte what it
emitted before the depth was read — which is why eleven `delay(1)`
sites and five `accumulate` sites crossed the landing untouched.
THE SILENT-WRONG IS CLOSED AT BOTH ENDS. A computed depth cannot size a
static line, and giving it one slot is the same betrayal in a new
costume, so `E_ComputedDelayDepth` is ARMED at birth (the twelfth
refusing class) on the same literal licence its sibling rides. Wheel
census at arming: 0 — every `delay(...)` in src/ and lib/ is
`delay(1)`. Gate: tests/micros/mn-delay-depth.mn, SEEN RED at pin
c10ad6ef (exit 66 — the 3-deep site answered 6, identical to the
1-deep) and green at 62 after.
TWO LATHE-LAGS SURFACED BY THE BUILD, both measured, both oracle-blind
classes the wheel never writes (§11's tripwire 3 exactly):
`Hβ.parser.named-fn-tuple-param` — RESOLVED 2026-08-12, pin d149cd6976.
SYNTAX §Pattern syntax says patterns appear in "`let`, `match`, function
parameters, and lambda parameters", and the lambda half was real while a
NAMED fn refused one: `fn delay_line_globals((h, depth)) = …` drew
P_UnexpectedToken at the `)` and the `=`. The dig found the machinery
WHOLE and its gate strangling it: parse_one_param's destructure arm
already parsed `{`/`[`/`(` via parse_pat and desugared to fresh-param +
prepend-let (the same bind_param_destructures the lambda path folds
through — no second mechanism), but param_starts_here admitted only
TIdent/TOwn/TRef, so the pattern arm was dead code and `fn f((a,b))`
fell into the bare-own/ref bail (skip_to_rparen ate to the INNER `)`).
The fix is the gate agreeing with the parser it gates: three
pattern-opener arms in param_starts_here (src/parser.mn), nothing else.
Parity measured first through boot's lambda path (tuple 7 / record 30 /
exact-length list 7), then pinned on named fns by
tests/micros/mn-fn-tuple-param.mn (expect 44), SEEN RED against the
unfixed boot (refusal, 6 undischarged claims, zero WAT) and green
through the repinned wheel. The measured boundary: `own`/`ref` before a
pattern opener still terminates the list (seed parity) and the malformed
tail refuses loudly via recovery holes — never a silent mis-bind;
ownership-marked destructure params are unprobed surface, admitted
nowhere. The wasm.mn:1438 `((h, depth))` call-site lambda — the fold
this refusal forced — unfolds back to a named projection as its own
follow-up.
`Hβ.emit.partial-application-arity` — **RESOLVED 2026-08-18**, pin
bb317fe4ec6a, by the same one-condition change as
`Hβ.emit.under-application-suspension`: this entry's
`map(delay_slot_name(h), range(0, depth))` is the same defect one arity
over, and its `return_call` arity mismatch had the same root — the
decider refusing a prefix the mint could already build. The remainder
this entry names below (`Hβ.dataflow.delay-line-runtime-depth`) is
untouched and stays open on its own terms.

`Hβ.emit.partial-application-arity` (original text) — SYNTAX §«Partial application»
declares a hole-product a first-class value, so `map(delay_slot_name(h),
range(0, depth))` should BE the callback. It parses, it checks clean,
and then the emit writes a `return_call` whose arity does not match its
target: `type mismatch in return_call, expected [i32, i32] but got
[i32]` — wat2wasm refuses, so the failure lands at assembly rather than
at the claim. A form the docs call first-class and `check` calls fine
must not die at the assembler; the diagnostic belongs at the site, and
the emit belongs at the arity the product proves. Measured 2026-08-12
with a two-param named fn under `map`.
THE NAMED REMAINDER is `Hβ.dataflow.delay-line-runtime-depth` — a line
whose depth is a runtime value, which wants the image-backed sequence
(a view whose start advances IS the ring) rather than a register file,
and therefore rides the value ontology's view/slice work (5.4) and the
arena (4.3). Until it lands the refusal is the honest surface: the
medium says it cannot hold that line instead of quietly holding a
different one. `Hβ.fold.show-leaf`'s sibling shape applies to LF.2/LF.3
(Accumulate's typed carrier, FilterSpec's taps), which are the same
read growing arms, not new machinery.

`Hβ.driver.per-module-env-overlay` — the design stamp for PLAN §11
Phase 3.5 (banked 2026-08-07 with the first half LANDED: the solo
sweep measured 53 violations across 13 modules at pin 7d8e91e499a1,
two one-line imports killed 17 — verify→graph+io,
format→parser — and solo_violations_max: 36 is the banked ceiling the
frontier's sweep leg enforces). THE RESIDUAL 36 IS TWO ARCHITECTURAL
SEAMS, measured and directioned, not under-imports: (1) THE
INFER→PIPELINE HANDLER SEAM (~20 across nine closures) —
infer.mn:2310's install chain (`~> env_handler(bb, bc, bi) ~> … ~>
intern_view(ib, ie, ic)`) installs handlers DECLARED in pipeline.mn, a
layer the import DAG places ABOVE infer (pipeline imports infer; the
reverse edge would cycle); the fix relocates the handler DECLARATIONS
down to their substrate homes (the env buffer's and intern table's own
modules — which is also §5.5's env-column move meeting the manifest:
the declarations land where the state they manage lives, and infer
imports that); (2) THE MCP→MAIN VERB-GRAMMAR SEAM (16) — mcp.mn:558
parses sessions with parse_cli_args, declared in main.mn beside
VerbSpec/verb_specs ("one grammar two transports", mcp's own comment),
and main imports mcp so the reverse edge cycles; the fix relocates the
verb grammar to a home both transports import. THE OVERLAY PROPER (the
second half, unbuilt): per-module env views on the ONE graph — each
env entry tagged by its defining module at env_extend, each lookup
filtered by the ASKING module's import-closure membership (a
per-module closure bitmask makes the filter O(1)), so solo checks and
queries get their REAL link sets without re-judging; diagnostics scope
to the queried file (healing the fmt scope register's 416 foreign
lines), the census gains its per-file cut, and query spans gain
file-true coordinates (`Hβ.query.decl-site-file-coordinates` lands
here). PRICED: the tag is one word per env entry written at the one
writer; the closure bitmask is per-module, built once from the
manifest DAG; the lookup filter is one mask test. WRITERS when the
second half builds: env_extend (the tag), the driver (the closure
masks from the DAG it already walks), env_lookup (the filter,
context-threaded), the check/query/fmt verbs (the asking-module
context), and the sweep leg's ceiling falling to 0.

`Hβ.types.named-effect-rows` — BUILT 2026-08-07 against this stamp (pin
6768ffac9dfa; the fixture's alias-of-alias `Both - B` grouping case
runs 3 with zero diagnostics; the named residual: a row alias used in
TYPE position today resolves as the nominal shape scheme rather than
refusing — the type-position refusal lands with the diag catalog's
projection, Phase 8.4). The stamp as banked: MEASURED at the felt walk and re-grounded at pin 8031eaf1:
`type Both = A + B` refuses `P_UnexpectedToken: +` at the type-decl
RHS, `A & B` likewise, `A - B` mis-resolves to a nominal non-row — so
SYNTAX §«Named effect rows», the section that RETIRED the `capability`
keyword, has no working spelling. TRACED — the one-representation
law decides the design: the with-clause already parses to signed
triples `[(EffName, Bool, EConn)]` and `build_declared_row`
(effects.mn:167, the signed-clause fold) is their ONE home, so a row
alias STORES THE SAME TRIPLES and expansion happens where rows are
built. THE GROUPING TRAP, killed at trace time: splicing an alias's
triples inline into the outer clause breaks grouping — with X = B,
`X + (A - B)` is B + A while inline `X + A - B` folds to A — so
expansion is NOT triple-inlining; the fold, on meeting a name whose
env kind is the row alias, recursively builds THAT alias's row whole
and applies the outer connective to the RESULT (parenthesization by
construction). Needs: (1) parser — the type-decl RHS row grammar
(ident joined by + - & with ! negation prefixes), producing the decl
that stores the triples — the SAME shape the with-clause mints, one
representation; (2) env — a RowAliasKind([(EffName, Bool, EConn)])
SchemeKind registered at the type name (a row alias is an ENV fact;
it never enters Ty unification — used in TYPE position it is a
refusal, not a TName); (3) the declared-row build resolves each
name through env: leaf effect vs row alias (recursive build + a
cycle guard refusing self-referential aliases loudly); the row
ALGEBRA (union/diff/inter/subsume) never sees alias names —
expansion completes at build time; (4) `W_EmptyRow` (SYNTAX names
it: a named row resolving to Pure narrates); (5) gates — the felt
walk's namedrow probe graduates to a fixture (`type Both = A + B`
+ `with Both` running through handlers), plus a `-` case proving
the grouping law and a `&` case, RED-first. PRICED (§5.O): the
alias expansion is O(alias tree) per declared row, built once per
decl at the existing fold; zero new graph state beyond the env
kind. WRITERS when it builds: parser.mn (the RHS grammar +
decl registration path), types.mn (the SchemeKind variant),
effects.mn or its caller boundary (the env-reading expansion +
guard), the W narration, fixtures + a frontier leg.

`Hβ.lower.list-rest-binding-runtime` — the list-rest BINDING's runtime
gap, measured 2026-08-07 at pin 8031eaf1 while landing the lambda
list-pattern parse fix (Phase 3.3's first drift). Two faces, one
family: (1) the lambda path (`([h, ...t]) => h`) parses and checks
clean now but solo EMISSION dangles — the rest binding emits a
hand-baked `$make_list` call the graph has no edge for, so
reachability (edge-following from main) prunes the definition while
the call survives: `undefined function variable "$make_list"` at
assembly — the Carried-Truth class at the emit layer (a call the
graph cannot see); (2) the fn-param path (`fn take_first([h, ...t])
= h`) REFUSES solo with one undischarged claim before emission — a
different symptom, same never-exercised family. The wheel's own
list-rest matches run because the full link always carries make_list
and its claims discharge there — tripwire 3 verbatim (the board's
oracles are blind to what the wheel never does solo). THE GATE:
tests/frontier/mn-lambda-list-param.mn runs 7 the day this closes
(its header carries the expected value); the frontier's parse-half
leg holds the parse victory meanwhile. The fix direction the
measurement names: the rest binding's list construction must be a
GRAPH-VISIBLE call (a real CallExpr edge to make_list minted at
desugar, exactly as the record-rest residual builds through typed
edges — mn-record-pattern-rest runs 30 through the same gate shape),
never an emit-baked name.

`Hβ.cli.where-verb` — BUILT 2026-08-07 against this stamp (pin
0d3a196299d1; four badges live and gated; two dig lessons in the
LEDGER entry MENTL WHERE LANDS — index walks over env-stored lists,
the typed accessor over the raw field read; the fixture's own badge
corrected the fixture: a handler named threaded that covered Tick
read [Seq], because the projection reads the artifact, not the name).
The stamp as banked: `mentl where` is
the derived-badge projection SYNTAX names six times and the lag list
carries: output, never input — the medium narrating facts the graph
already proves. TRACED — three badges, each an existing read wired to
the surface: (1) REPR — a value name's representation width via the
env scheme → chase → `repr_of_resolved` (types.mn:172, GraphRead),
rendered `name : Float @ f64 (pinned|inferred)` — pinned iff a
TReprPin sits in the chased chain (a small discriminator walk to
write), inferred otherwise; (2) RESUME CARDINALITY — an op name's
`TCont(R, S, discipline, world)` read from its EffectOpScheme's TFun,
rendered `R ->1 S` (OneShot) / `R ->* S` (MultiShot) / `->? `
(Either) per SYNTAX §«Resume discipline»; the channel is the op
scheme — the build verifies where the discipline lands after
handler-decl inference and reads THAT, never a re-derivation; (3)
SCHEDULE — a `><` site's resolved strategy as a STATIC walk up the
site's enclosing `~>` chain in the weave matching Schedule-class
handlers, rendered `>< [Thread]` / `>< [Seq]` (none installed = the
invisible default). The static walk is EXACT, not approximate: the
schedule is read at the fanout's own install site and never crosses a
call boundary (the parallel_map dissolution's law,
`Hβ.prelude.parallel-map-dissolves-into-schedule`), so the enclosing
chain IS the whole truth — lower's ambient-stack read
(lower_fanout_schedule, lower.mn:1620) and the weave walk answer
identically by that law. SURFACE: `mentl where <file> <name>` riding
the query spine exactly as the census did — a QWhere Question
variant, the arm in query_default, the CLI verb mapping through the
query invocation; a `><`-site's badge addresses by name of the
enclosing fn (the fn's fanout sites listed with their schedules).
PRICED (§5.O): each badge O(1) per name (one env lookup + one chase);
the schedule walk O(enclosing-chain depth); a pure READ verb, no
writer. WRITERS enumerated when it builds: main.mn (VerbSpec + the
V* variant + dispatch), pipeline.mn (verb parse → QWhere), query.mn
(the Question variant, the arm, the three badge projections + the
TReprPin discriminator), docs/SYNTAX.md (the lag list SHRINKS —
`mentl where` leaves it, the list's own contract), tools/doc-truth.sh
(verifies the verb serves via `mentl help` — the lag-list check
inverts for this name), the frontier leg + fixture (three badges
asserted: a pinned repr, an op cardinality, a scheduled and an
unscheduled fanout). The gate seen RED first: the fixture's `where`
queries answer unknown-verb through the prior pin.

`Hβ.parser.pcompose-nary` — BUILT 2026-08-07 against this stamp (pin
05fd2307ff43; the mn-fanout-nary micro runs 9 where the prior pin
exited garbage; the m3 trap censused five hidden full-enumeration
walkers by the ExprPlaceholder tell — nested-pattern exhaustiveness
cannot convict across depth, a checker limitation the trap reported;
the anonymity ratchet then convicted the build's own three lambdas
and the stages were named). The stamp as banked: MEASURED at pin 62542a59bf94: `(inc(1)) >< (inc(2))
>< (inc(3))` folds left into `((Int, Int), Int)`, so `let (a, b, c) =`
refuses with "type list arity mismatch: 0 vs 1" + "(Int, Int) vs Int"
— the violation exactly as §11 3.1 states it. TRACED — three encodings,
two REFUTED: (A-min) parse the chain into FanShare's
branches-as-MakeTupleExpr convention — REFUTED by collision: a
tuple-VALUED branch (`(1, 2) >< (3, 4)`) is indistinguishable from the
chain encoding, a silent-wrong class; (C) judgment-side flatten of
left-nested spines with no parser change — REFUTED by the law's own
words ("must parse N-ary") and by parens-intent conflation (grouping
does not survive to the AST, so authored nesting and precedence
folding cannot be told apart); (B) first-branch-left + rest-in-tuple —
REFUTED: the branches are peers and the shape would lie. THE CHOSEN
FORM: `><` alone grows a dedicated N-ary carrier — `FanoutExpr([Node])`
(an Expr variant whose branches are a LIST) — while `<|` KEEPS
`PipeExpr(PFanout(FanShare), input, branches_tuple)`: the two verbs
have different operand structure BY NATURE (`<|` is input × branch-set,
binary; `><` is N peer branches, genuinely N-ary), and the kernel's
"one PFanout node carrying an arity" is already true at LOWER (the
STEP 4 collapse); the surface carriers differ, the lowered node is
one. PRICED (§5.O — each touch a mechanical arm, no new asymptotics):
parser.mn (the prec-2 chain collect builds FanoutExpr from a `><`
run), types.mn (the Expr variant; PipeKind/FanOwn untouched — the
census's CsVerb(PFanout(FanDistribute)) stays keyed on the fanout
kind), query.mn (expr_child_handles gains the arm; census_matches'
CsVerb arm matches FanoutExpr as a `><` site), infer.mn (infer_fanout's
FanDistribute arm walks the list — N value boundaries, TTuple(N)),
lower.mn (the fanout lowering enumerates the list into the
arity-carrying runtime record), format.mn (render_compose_chain reads
the list; the render shapes are unchanged — SYNTAX's vertical/inline
canon is already N-ary). WRITERS enumerated: those six plus the gates —
the nary probe graduates to a micro (expect 9), the census fixture's
`><` roster line keeps counting through the new carrier, and the
three-way destructure fixture is the RED gate. The felt walk that
banked this also re-confirmed 3.3's drifts live (lambda list-pattern
param refuses with six parser warnings; `type X = A + B` refuses
P_UnexpectedToken; `xs |> len` diagnoses a false E_TypeMismatch while
emitting 96,768 bytes of correct WAT) and refuted one 3.4 claim in the
right direction: `-> !` checks CLEAN — SYNTAX's lathe-lag note is
stale and dies at 3.4.

`Hβ.infer.diverge-shared-memory-row` — RECOVERED 2026-08-07 (PLAN §11
Phase 2.4; named 2026-05-05 in b139622b as peer G.1, gone from every
index by 2026-08-05 — drift-9 at the roadmap layer). The original form
spoke the Thread-effect-era substrate (a hardwired `+ Thread` on the
verbs); the RESTATED form speaks today's: the fanout is ONE PFanout
whose ownership aspect discriminates `<|` (FanShare — one input
ref-borrowed across N branches) from `><` (FanDistribute — N owned
inputs, nothing shared), and execution is a `~> Schedule` handler read
live at the install edge. Under `~> Thread`, that ownership aspect IS
a row fact the infer arm must charge: a FanShare fanout's borrow is
VISIBLE across cores — cross-core visibility of a shared referent
requires atomic ordering, so the fanout's row needs `+ SharedMemory`
(or each branch proving it never reads the borrow after spawn); a
FanDistribute fanout shares nothing, so the same arm can prove
`+ !SharedMemory` — parallelizable-no-sync, stated as a negative
capability. This is the substantive half of the two-parallel-verbs
reframe: the ownership discrimination becomes a thing the CROWN
PROVES (a `!SharedMemory` the row algebra discharges) rather than a
thing the docs assert. Sequencing: the charge site is the same infer
fanout arm Phase 2.2 just cleaned; the PROOF verdict inherits
`Hβ.effects.sound-neg-under-poly` (band A / Phase 6), so it lands
with band E's verification tier (Phase 9.2's safety verdicts) —
beside `Hβ.parallel.thread-alloc-transitive-proof` and
`.race-freedom-ownership-proof`, and prior to it `>< ~> Thread`'s
race-freedom claim rests on the ownership read alone. Two sibling
names from the same archaeology, recorded so the recovery is whole:
`Reason.branch-spawned-verb-tagged` (G.2 — spawn provenance
verb-tagged for the Why engine) survives in today's vocabulary as a
facet of `mentl where`'s schedule badge (PLAN §11 3.2); G.3's
thunk-abstraction trigger dissolved when STEP 4 collapsed the two
lower paths into one PFanout.

`Hβ.graph.reverse-edge-and-bound-projection` — oracle.mn's two
surviving iteration convictions, named at their true form (2026-07-30).
`count_dependents` walks ALL handles asking "does this body reference
pos?" — a REVERSE-EDGE query answered by scanning forward edges, O(graph)
per position and quadratic across the candidate set; `collect_bound_positions`
walks all handles collecting the NBound ones — a graph projection written
as a range scan. Neither wants a materialized range (that is worse than
the loop at graph scale): the self-form is the graph answering directly —
the reverse edge read through the same use-edge channel `refs_of_name`
already collects, and bound-cell enumeration as a projection over minted
cells. Iteration-is-topology's tier-2/tier-4 case (a cycle or a read,
never an index), and the payoff is complexity, not idiom.
SUPERSEDED IN PART by PLAN §11 5.5's column framing, reconciled
2026-08-07 (the alive-law: this entry's "read through refs_of_name"
routed one full scan through another — refs_of_name (query.mn:333)
is ITSELF an O(graph) whole-handle walk with span-dedup against
judgment re-mints, so the payoff argument collapsed). THE COLUMN
STAMP OPENS: the three re-derivers enumerated — (1) refs_of_name's
whole-graph VarRef scan, O(graph) per question; (2)
count_dependents' quadratic forward-scan; (3)
collect_bound_positions' range scan (the bound-projection sibling
riding the same fix pattern). THE ONE WRITER: the VarRef
resolution at judgment (infer's VarRef arm — where the use edge is
DRAWN) dual-writes a spine-column entry (decl-root → ref span/
handle), exactly the 5.5 pattern (column at the writer, readers
migrate, side-walks delete). PRICE: O(1) append per reference,
O(k) reads for all three consumers; the current walk's
span-dedup-vs-remint complexity becomes the column's identity
discipline (append in the reporting pass only, or span-keyed).
The build rides the 5.5 column arc's opening — the first column
whose writer is already singular.
THE WRITER SURVEY (2026-08-07, the stamp's close): the one writer
is infer_var_ref (infer.mn:3104 — the VarRef judgment arm), and it
already carries everything the column entry needs (name, the ref's
handle, the span). The column's shape follows graph_index_span's
one→many index precedent (span→handle), not graph_narrow_set's
per-handle page slot: two graph ops — a note (name-key → ref
handle appended) and a read (name-key → the list) — with the key
STRING-keyed on the smap primitive until §5.O layer 1 makes names
handles (the upgrade path named, not blocking). The three readers
then migrate: refs_of_name becomes the read + its span projection
(the dedup discipline moves to the write: note in the reporting
pass only, so judgment re-mints never double-enter);
count_dependents becomes a per-candidate read; and
collect_bound_positions stays a separate projection (bound cells,
not references — it rides the same arc as a sibling, its own op).
Build order: the two ops + handler state, the one write, the
refs_of_name migration with the query's answers proven equal
(old-scan == column per name on the wheel link — the belt), then
the oracle reader, then the scan deletions.
THE COLUMN LANDED (2026-08-07, pin a37869cbfd9d — the LEDGER entry
of the same name): ops + state + the one write + the refs_of_name
migration, belt byte-identical, collect_var_ref_spans deleted,
peak ratchet raised 2,250,000 → 2,400,000 component-attributed.
The write notes above the env match (a missing name is still a
reference); the column is append-only telemetry, not trail-backed
(rolled-back branches' notes are dead handles the read-side
zero-span skip + span dedup drop). THE ORACLE READER LANDED
(2026-08-07, pin 00a91c85efcd — the LEDGER entry of the same name):
the probe traced the incumbent DEAD — count_dependents matched pos
against direct child TYPE handles, and a FnStmt handle is no
expression's child, so surface_area_at(decl) answered a constant 0.
The repair is the migration: surface_area_at reads
len(refs_of_name(name)) off the column; count_dependents,
body_references, and the orphaned list_contains deleted whole.
REMAINING here: collect_bound_positions (oracle.mn) — STAMPED
2026-08-07, build next. SEMANTICS TRACED: one consumer
(project_queue, oracle.mn:194); candidates_at yields non-empty ONLY
at NBound(TFun) positions (gradient_candidates_at's TFun arm is the
sole producer), so the whole-handle chase-walk seeds (a) fn decls —
the productive set — and (b) every fn-typed MENTION and lambda,
each of which re-enumerates the decl's own candidate set per
mention (a Carried-Truth violation inside the incumbent: N copies
of one decl's candidates interleaved in the queue) or applies
decl-surface annotations at positions that have no with-clause.
The name and comment claim a "dependents" filter no code
implements. THE FORM (priced, two rejected): a DECLS COLUMN — the
refs column's exact sibling, graph handler state noting the FnStmt
handle at the decl judgment's one writer, read by a graph_decls_at
op; O(1) note × ~1.6e3 decls at wheel scale (three orders below
the refs column's 2.4e6), O(decls) read. REJECTED: a program-root
stmts op (the stmt LIST is a judgment-time value in driver hands,
not a graph node — inventing a root node to avoid a column is more
machinery, not less); the status quo (O(graph) chases per queue
derivation). SEMANTIC DELTA, named: the new seed EXCLUDES
mentions/lambdas — the repair, not a loss (mentions duplicated;
lambdas have no annotation surface — the anonymity tier is their
channel). WRITERS ENUMERATED: one (the FnStmt judgment arm).
GATE: no test reaches project_queue today (grep-verified); the
landing's leg observes the queue through voice's projection
(query_project_queue behind the teach/at surface) on a fixture:
seed count == decl count, seen RED against the incumbent boot
(mention-inflated count). Then positions_with_dependents' lying
name dies with the walk and this peer closes.
BUILT AND CLOSED (2026-08-07, pin 3f727449e9d5 — the LEDGER's THE
DECLS COLUMN SEEDS THE QUEUE): the column landed per the stamp with
one gate substitution, recorded honestly — voice's queue projection
has no CLI reach (teach reads per-fn gradients, the queue lives in
the space/eight-loop narration), so the observable became the
"decls" QUERY FACET reading the same decl_handles projection the
queue seeds from (one home, two readers — a strictly closer read
than narration would have been). Born RED on the incumbent
("error: unknown query: decls"); the frontier leg pins the
fixture's three decls at 7/9/11. THIS PEER IS CLOSED — its three
re-derivers are gone (refs scan, dependents walk, bound-cell walk),
its columns live (refs, decls), its readers migrated
(refs_of_name, surface_area_at, project_queue's seed).

`Hβ.audit.capability-carries-its-evidence` — the severance teaching's
remainder (named 2026-07-30 with the vocabulary's graph read). The
vocabulary is live now; the capability MAP still names three effects,
and it cannot simply grow because a Capability is a nullary tag whose
render bakes its evidence: CSandbox renders "proven no network access",
so mapping WASI or Filesystem to it would misspeak the proof. The
self-form is the capability carrying WHICH severance discharged it —
`CSandbox(ename)` or a (capability, evidence) pair read from the row —
after which the map extends by construction over every declared effect
(a real-time consumer wants !Mutate and !Thread named; a sandboxed one
wants !WASI and !Filesystem). Cheap once the evidence rides; the
render is the whole design question.

`Hβ.audit.anonymity-tier` — BUILT 2026-08-07 against this stamp (pin
eb827fae186d; the tier reads TWO classes — the build corrected the
stamp's class 3 in place: a pure lambda on a quantified row var is
exactly `map((x) => x + 1, xs)`, the vocabulary itself, so the
quantified-param landing is not an independent conviction and its
honest half — the published row — is the row class already; escape
stays the DEP below). The stamp as banked, correction folded in: MEASURED BASES, both true, name the base when
citing either: the weave census counts 555 anonymous fns on the wheel
link (`mentl query src/main.mn "census anonymous"`, read this day);
§11's 490-of-3,469 counted EMITTED fns (2026-08-05 harvest) — the two
differ because emitted fns dedup and prune. Text-shape approximation:
~136 of the 555 are ETA-WRAPPERS (108 unary `(x) => f(x)`, 17 binary,
11 nullary) — the one class with a MachineApplicable fix. TRACED — four
conviction classes, each a live graph read on the site's OWN raw facts
(the census's span_of_node_raw discipline; no chase for identity):
(1) ETA-WRAPPER — LambdaExpr body is CallExpr(VarRef(g), args) with
args ≡ the param list in order; convict, MachineApplicable (pass `g`).
(2) NON-PURE — the lambda's TFun row ≠ Pure (one chase + row read);
convict as a named-stage-in-hiding: teaching verdict, the name is
intent and stays the human's. (3) QUANTIFIED-ROW-PARAM LANDING — the
lambda lands on a callee param whose row var sits in the callee
scheme's quantified set (the Phase 1 sig-keep boundary read at the
application edge); convict — a published row boundary deserves a named
carrier. (4) ESCAPE — DEP `Hβ.infer.use-profile` (band N S2, the
escape-bit); NAMED, not built — until it lands the tier reads classes
1–3 only, and the tier's report says so. Silent on the pure-local
immediately-consumed lambda — the vocabulary the surface wants
(`map((x) => x + 1, xs)` never narrates). PRICED (§5.O): one weave
walk O(nodes) — census_walk's class, no new asymptotics; per lambda
class-1 is O(arity) on raw body shape, class-2 one amortized chase,
class-3 one edge read into the scheme; all reads live at audit time,
no snapshot, no writer — a pure READ tier. ENUMERATED writers when it
builds: the audit tier arm beside iteration-shape, the frontier leg +
fixture (one convicting eta, one convicting non-Pure, one silent
pure-local — seen RED first), and NOTHING else: the verify-baseline
ceiling and the CensusShape migration are §11 2.5's, not 2.3's.
BANKED NEXT PROBE: the built tier's first whole-link run reports the
class split (eta / non-Pure / quantified-param / multi-class) — that
split decides whether 2.5 banks per-class ceilings or one total.
Correction to §11 2.3's prose carried here: "four named soundness
peers live at that boundary" is not groundable as a counted four in
this catalog — the boundary's actual kin are Phase 1's sig-keep
publish, `Hβ.lower.multishot-anonymous-install`,
`Hβ.lower.partial-via-lambda-recipe`, and the fmt lambda render arm;
kin, not a counted four.

`Hβ.wheel.iteration-is-topology` — the recursion eradication (named
2026-07-30, Morgan's interrogation; the ledger entry ITERATION IS
TOPOLOGY carries the law and the census). The wheel's 390
index-threaded self-calls (the audit's iteration-shape tier is the
standing census instrument) migrate per family toward the medium's own
iteration stack — derived folds / each / iterate for structural walks,
<~ for genuine cycles, driver-resumption for search — each family
march-arbitrated, the tier's count the ratchet. Sequenced WITH
`Hβ.infer.schemes-are-edges` (below): every name-cycle drained is
tower the deletion no longer needs; the wheel's own SCCs (unify, the
parser) are structural folds over Ty/Token written as mutual
recursion, and their migration is the deletion's steepest lever. The
named residual: recursion that survives is sig-priced (the
signature-price law generalized — the price of name-keyed recursion,
period).

`Hβ.dsp.state-element-install-once` — the `<~` RHS's construction is a
lower-time constant (named 2026-08-01, the constructor-charge landing's
DSP decision). A feedback site's state-element spec (`delay(1)`,
`accumulate(init)`, `filter_spec(...)`) constructs ONCE per site at the
register's establishment, never per tick — but the constructor-row
charge reads the RHS ctor call as a per-call construction, so the six
feedback.mn filters carry Memory + Alloc where their emission earns
!Alloc. The reclaim: the judgment reads the install-once fact (the
recognized state-element position exempts the spec's construction from
the per-call charge, or emission hoists and the charge follows the
sugar-charge law's own criterion — charge what the lowering performs).
When it lands, the real-time `!Alloc` rows return to lowpass_iir and
kin with the row proof the file's comments once claimed. stereo_chain
stays honestly charged regardless (its result tuple is a real per-call
construction).

`Hβ.infer.schemes-are-edges` — THE MENTL WAY for the judgment (named
2026-07-30, Morgan's question "is there a better way — a more Mentl
way?" answered at the root): the entire convergence tower — trial /
rounds / cone / fingerprints / the bound / the freeze law / the
declared-row pins / the attractor dances — is ONE compensation for
published schemes being SNAPSHOTS read by name while everything else
in the medium is an EDGE read live. The rounds manually iterate what
the union-find propagates transitively for free; the freeze exists
because live cells raced under the fan; the races were SOLVED for
rows by making the write a commutative JOIN (the lattice landing,
order-free at K=8). The form: publishes as live graph cells whose
teaching is a join, polymorphism as instantiation FLOW-EDGES read
through the union-find (the banked polymorphism-as-flow-edges design
— generalize/instantiate/subst dissolve; the unpatchability theorem's
own prescription: swap the representation behind the projections).
Convergence stops being iterated and becomes what the graph
structurally IS; the tower deletes. Tonight's symptom catalog is the
requirements list, measured: the parity-selected attractors, the
prereg-vs-final entry races, the open-tail subtraction carriers, the
type-half flip surviving a fully-pinned row, the marginal
schedule-variance at the 11/12 boundary. A full-context session's
arc — the biggest single deletion on the board.
THE SOURCE HAS ITS ARTIFACT (2026-07-31, minimized from 930 wheel
movers to fifteen lines — tests/frontier/mn-cycle-charge-freeze.mn,
the §7 entry THE SOLO IS A CYCLE carries the arc): a cycle member's
row is PUBLISHED AS A VALUE at its own decl exit, before its
co-members are judged, so their effects never reach it — and the
member whose accumulated tail accidentally keeps a live CO-MEMBER
edge is the one that stays correct, which makes the cut, not the
openness, the defect. Rung 3's acceptance tests are therefore three
banked REDs (this one, mn-scc-false-negation, mn-two-tail-accumulation)
plus the wheel's mover count reaching zero — and the count is now
printed on every ScopeAll compile, so the ratchet has its number.
RUNG 3 IS NOW A MEASURED BUILD, NOT A SKETCH (2026-07-31 — attempted
first, measured, and reverted to green with the spec it produced;
Morgan's cut: the expensive one first is what makes the cheap ones
cheap or unnecessary). THREE FORMS WERE BUILT AND MARCHED:
(a) THE FULL REPRESENTATION SWAP — `EffTail = EtClosed | EtOpen([Int])
| EtAll`, the tail as a SET OF EDGES so `tail_join` becomes set union
(no first-var drop), with `ef_make` canonicalizing and `EtOpen([]) ⇒
EtClosed`. Surface MEASURED: 52 sites across seven files (infer 20,
effects 16, graph 6, types 5, lower 2, gradient_delta 2, main 1), and
H6 names every one — the census answers `constructor: EtVar` at each
missed site, so the sweep is compiler-driven. Not landed: several
sites are unify BINDING decisions that need their own judgment, and a
half-swept tree does not compile.
(b) DELETING THE CUT OUTRIGHT, with a cycle guard added to
`resolve_row` (carry the cells being resolved; skip a revisit — R ∪ R
= R, so the least solution is the fold's own idempotence). MEASURED:
it terminates and self-reproduces (TRANSITION m3 == m4) and it is
WORSE — 40 E_EffectMismatch, movers 930 → 1476, the wheel +47k lines.
THE READING, and it is the finding: the cut was doing TWO jobs, and
only one of them is the defect. Closing the SELF cycle is right and
necessary (callers and the declared-row gate read a value there, and a
self-referential loop is not one); cutting a CO-MEMBER's edge is the
defect.
(c) THE SEPARATION — `row_without_self` becomes the same resolution
guard SEEDED with the fn's own cell: the self-edge reads closed by
idempotence, every co-member edge stays LIVE. One line replaces the
old handle-compare. MEASURED: the source fixture goes 2 movers → 1 and
`self_first` — the member that LOST its co-member's effect — is FIXED,
which is the defect this whole arc named. The wheel then shows 40
E_EffectMismatch, and those are HONEST: with co-member effects finally
arriving, forty of the wheel's own declarations are under-declared.
THE (c)-PLUS-WIDEN-LOOP PRESCRIPTION IS REFUTED BY THE BATTERY
(2026-07-31, the HALF-STEP REVERTS ledger entry — this paragraph's
first form prescribed exactly it and is superseded in place): form
(c) SHIPPED the findtag/mapelem/mapfield exit-134 class (live
published tails with no completion drain sever the element-instance
payload joins — the fold behind a live tail never fires, a HOF
lambda's param never learns its record), and the forty mismatches
were un-drained reads, not under-declarations — the widen loop would
have canonized artifact rows into forty signatures. (c) reverted
whole; the honest landing is (a) + (c) + the completion drains
TOGETHER — the row half (D3 + D4) as one arc, judged by the
six-fixture acceptance battery (the three graduated micros +
mn-cycle-charge-freeze + mn-mutual-negation-gate +
mn-two-tail-accumulation).

THE RESOLVED DESIGN (2026-07-31; the banner claim "every choice
forced, nothing left to evolve" was REFUTED IN PART the SAME DAY by
the two-refuter fleet — guarantee-refute-fable / guarantee-refute-opus
under .build/research, convergent independently — and is corrected
here in place, the alive-law on the design's own author. THE
CONVERGED DECOMPOSITION: the ROW HALF — D3's edge-set tails + D4's
group-completion gates — is FORCED (both refuters fixture-traced it
green independently; its two named gaps are SETTLED 2026-08-01 by
THE SETTLED LAWS block below). The
SCHEME-OBJECT HALF — D1/D2/D6 — is a CHOSEN architecture with live
alternatives, one of them the landed frozen-read form: D5's one-way
law is unqualified over the TYPE sort (no type join exists —
graph_bind replaces; in-group cell sharing is the landed measured
truth), D6 dies on the fan's enumeration (proposing UNREFERENCED
names needs a decl-listing store in ANY implementation; the
forwarding-edge mechanism fails both horns), D2's bands exclude the
prepass region where the parameter cells actually mint, and D7's
K-wide byte-equality rests on a plan sized by the pass D8 deletes —
the SIZING CIRCULARITY (fixed bands measured dead at C1b). D8 IS a
ratchet (deletion list verified self-contained; graceful degradation
proven). THE HONEST PATH: land the row half, measure
movers — the acceptance (movers 0, the final pass DELETED, one-pass
judge) may be reachable WITHOUT the scheme-object half, and that
measurement, not prose, decides whether D1/D2/D6 proceed. ALL THREE
DECISIONS ARE TAKEN (Morgan delegated the remaining two to the
co-designer seat, 2026-08-01; the forty's diagnosis was answered by
the 2026-07-31 probe — the half-step's own artifact, un-drained
live-tail reads meeting closed gates, dissolved by the revert, no
widen loop):

(1) THE PROOF IS THE INTERFACE — the publish/gate split resolves as
GATE-ONLY, whole: a published row is the body's PROVEN row; a
declaration is a GATE checked at the group's completion plus a
REFINEMENT contributing only its ABSENT set — load-bearing exactly
on an open tail (bind_open_to_neg's mechanism, now the ONLY thing
authored text writes into a row); a declaration can never widen,
close, or EtAll a published row. A closed proven row already entails
every absence (the strongest !E statement IS the closed positive
row), so nothing is lost and the transitive absence proof rides
entailment instead of annotation propagation. This inverts the
received tradition — every mainstream language publishes the
author's PROMISE as the interface and checks the body against it;
Mentl publishes the PROOF and demotes the promise to a gate — and it
is the Carried-Truth Law at the signature boundary (a declaration
republished as the interface is a copy of intent standing in for a
provable fact). T_OverDeclared, tighten, and the gradient already
point here; now it is the semantics. enforce_row_gate's declared-row
bind DELETES with this (the EtAll-fabrication hazard dies
structurally — no path from a declaration into a stored tail);
mn-mutual-negation-gate is the acceptance fixture, landing WITH the
row half (gate-at-completion needs D4). Scope note: this is the ROW
law; type annotations keep their Intent-Boundary semantics (the
let-annotation landing already made `: T` a constraint, consistent).

(2) THE SCHEME-OBJECT RULE, pre-committed with a NO-GO default:
after the row half lands, movers → 0 or a non-row residue ⇒ D1/D2/D6
as written are DEAD (refuted on their own terms — no type join
exists, the fan's enumeration needs a decl-listing store, the sizing
circularity), their surviving ideas folding into smaller named peers
(env dissolution stays §5.O layer-2 via name-is-handle; the band-bit
died with the circularity). A materially nonzero TYPE-sort residue ⇒
a FRESH design pass answering the type-half join question first
(frozen-read extended, or polymorphism-as-flow-edges) — never the
refuted architecture on momentum. Ambiguity defaults to no-go; the
tower dies either way.

THE SETTLED LAWS (2026-08-01 — the row half's two named gaps closed
by ruling (1); the swap is unblocked. THE PRICING RULE, added the
same day after its violation was measured, extended the day after
its second violation was: no representation clause is ever stamped
FORCED or SETTLED until its READ and its WRITE are each priced under
§5.O AND its WRITERS are ENUMERATED — the census law at design
altitude. Two paid instances: semantic fixture-tracing alone stamped
D3 forced with an unpriced fold and the wheel billed it at 4GB; then
"the union is blocked on the scheme-object half" stood as the stamp
while the actual blocker was ONE unenumerated writer
(infer_call_saturated's symmetric row unify), found by a single grep
run AFTER the stamp instead of inside it. The corollary retires a
CLAIM CATEGORY: "exhaustive / complete / every choice forced" is a
verifier's verdict, and a verdict without its run is fabrication
(⟲'s own law applied to the design's author) — a design statement
carries the form "traced over X, priced over Y, enumerated over Z"
and completeness has exactly one proof, the build marching green):
— THE ABSENT-MASK LAW (gap 1): the absent field is the ONE home for
every negation-shaped fact, with THREE writers — the `~>` install's
handled-set subtraction, the declared `!E`, and the diff/inter
algebra — ALL writing by union (a join-semilattice dual to
presents), ALL read at resolution (p ∪ edges' content ∖ a). A mask
never parks: D4's completion drains resolve every edge at the
group's completion event, so a mask meets its tail's content THERE —
not never (the half-step's measured failure), not at a publish
freeze (the original defect).
— THE ETALL LAW (gap 2): EtAll is a DEMAND-side form only — authored
row constraints (a param's `() -> a with !WASI` anything-but shape,
the persist barrier) and the gate's transient universe-minus — NEVER
a supply-side inference result: no publish, no bind, no join may
store EtAll into an inferred row (supply is closed or open-edges,
nothing else). Demand meets supply at row_subsumes' directional gate
(the directional-fn-row-edge landing's own machinery). A stored
supply-side EtAll is a census item at zero.
— THE FLAT-CELL LAW (D3's READ half — added 2026-08-01 after the A2
attempt measured its absence as the hub-cell wall, and Morgan's
rebuke named the failure: the design had stamped D3 FORCED without
ever running §5.O over its read, while the corpus ALREADY held the
answer — the 2026-07-22 canonical-on-write arc, specified and
uncited). A row CELL never stores depth: every write —
graph_bind_row's bind and the teaching join alike — stores the FULLY
FOLDED (p, a, residual-edges), so fold depth is 1 by invariant at the
write. Flatness decays as neighboring cells bind later; the
union-find already answers that: COMPRESS-ON-READ —
resolve_row_compress generalized to edge sets rebinds through-bound
edges to their folded terminals (the branch-arm skip preserved for
determinism), making row reads amortized O(1) exactly as the type
sort's chase. The visiting-set guard (R ∪ R = R, the half-step's one
sound piece) scopes PER READ for in-flight cycles and can no longer
freeze absent content because D4's completion events BOUND the
breadth: a hub cell's edge set grows only while its sources are
un-completed, and completion folds them away — the measured
thousands-element set was never a legitimate steady state, it was
the missing-completion symptom read as memory. The belt: a read
meeting depth > 1 is a census item (the write that skipped
canonicalization names itself). With this law, A2's return is
forced-choice end to end: restore A1-exact from the banked diff (the
census-34 park dies unexamined — its machinery is rewritten under
this law), then ONE arc = flat-cell writes + set compression + the
union + the judged binds + the publish law + the drains, judged by
the six fixtures plus the depth census.

The D-text below IS the PROPOSAL,
under refutation, kept whole for its mechanism detail. The invariants
the proposal claimed as forcing:
one-graph-two-operations (the thesis) · determinism-as-fixpoint via
the planned mint (C1b's deterministic per-decl bands) ·
name-is-handle · the one sorted-handle-set representation (§4①'s
ordered-keyed-set unification) · join-only shared writes (the lattice
law: order-freedom ⇔ monotone commutative idempotent joins, proven at
K=8 for rows) · the measured one-way race (K=8: a caller folding a
decl's live cell mid-flight) · Tarjan groups as parse truth ·
undecidability of inferred polymorphic recursion (the signature price
is math). The unforced remainder is byte layout alone — record
offsets private to their accessors, march-absorbed TRANSITIONs,
load-bearing nowhere; layout is not semantics.)

D1 THERE IS NO SCHEME OBJECT. A decl's identity is its pre-registered
type cell; "the scheme" is a PROJECTION of that subgraph. generalize
writes nothing. instantiate at a site mints fresh cells for exactly
the decl's parameter cells and draws one CORRESPONDENCE EDGE per
pair. Substitution IS the union-find chase; both subst builds die.

D2 PARAMETERS ARE A BAND BIT, DECIDED AT ONE EVENT. The planned mint
already assigns every decl a deterministic handle band. At the decl's
COMPLETION EVENT one sweep over its band writes the parameter bit —
free-at-completion — into a spine column. Thereafter param?(cell) is
an O(1) column read; ownership of an out-of-band free cell is band
arithmetic (it is the earlier owner's parameter; using it is an
instantiation edge). A stored qvar list is a snapshot; a liveness
re-walk is a re-derivation; the band+bit is the unique O(1) form the
fixpoint's own allocator provides. Forced.

D3 ROW TAILS ARE EDGE SETS; ALL SETS ARE THE ONE SORTED HANDLE-SET.
EfRow(present, absent, tails): present/absent sorted handle-sets
(names are handles), tails a SET of edges to row cells — N edges per
cell, tail_join is set union, the first-var drop unconstructible.
Recursion needs no cut: R ∪ R = R; the resolver's visiting-set IS the
least-fixpoint read (the landed guard, now the only law). Not a
bitset — effect space is open and sparse, and a bitset is a global
registry, a side table reborn. Joins commute and idempote → fan-safe
at any K. Forced.

D4 COMPLETION IS THE GROUP'S. The Tarjan group (a solo self-cycle is
a group of one — landed) completes as ONE event: parameter bits,
declared-row gates, and the group's diagnostics fire there. The
deferred-gate machinery deletes with the timing problem it patched.
Polymorphic recursion keeps the signature price — undecidable to
infer, never revisited. Forced.

D5 TEACHING FLOWS DECL→SITE ONLY. A late resolution of a decl cell
propagates along correspondence edges as a JOIN into each site cell;
a site constraint binds the site's OWN cell, never through the edge —
one-way is a law of shared memory paid for at K=8, not taste.
Propagation is not a phase; it is what an edge is. A mover is thereby
impossible by construction — there is no second judgment left to
disagree — which is the difference between driving divergence to zero
and deleting its habitat.

D6 THE ENV DISSOLVES. A name resolves ONCE at the scope walk to its
decl's cell (the VarLookup edge, already minted, becomes THE edge);
after that nothing in the judgment is name-keyed. The flat buffer,
the bucket index, and the per-generation dedup die with the snapshot
they served. Generation shadowing (the resident session) becomes one
forwarding edge on the decl cell — the canon primitive, no second
store. Name-keyed reads survive only at human boundaries (query,
REPL, diagnostics render) as projections.

D7 CLOSURE OVER EVERY PLANNED SYSTEM — why nothing replaces this.
K-wide judgment: every write is an own-band fresh bind or a shared
join — order-free by algebra, byte-equal by the planned mint; schemes
join rows in the one proven write class. Incremental/resident: an
edit's cone propagates along live edges; superseded generations die
by forwarding edge; the arena's job stays reclaim alone. Persist =
memcpy: judgment state is image cells, columns, and edges — zero host
maps. The modal crown, Verify, and audit read live rows off cells.
Every planned system consumes this form; none sits beside it.

D8 THE DELETION LIST — the acceptance IS this list reaching zero: the
final pass · movers_count/movers_line/movers_diff/round_prints/
prints_equal · the deferred row gates · scheme snapshots (stored
Forall at decls; ctor/op records become decl cells) · instantiate-as-
clone and both subst builds · the env buffer/bucket/dedup ·
row_without_self's residual form · the trial/final split (ONE
planned, reporting, bracketed walk) · the fingerprint channel. The
SCC walk DEMOTES to scheduling. Done = movers 0 AND the final pass
GONE AND the judge ONE pass (verification happens ONCE: per-compile
correctness structural, whole-program verification at the march per
landing) AND the landing NET-NEGATIVE in judgment machinery — a
net-positive diff is the tower's signature and STOPS the arc. Until
done, the tower takes NO improvements — no cone bolt-ons, no cadence
tuning, no hygiene on condemned machinery; only the arbitrating
oracles (the march's cost line, the ratchets, the movers count) touch
it (Anchor 2's condemned-forms clause).

D9 BUILD ORDER — each rung marched, direction ratchets live from the
first (movers monotone down · peak-RSS ratchet · battery-gated repin
· the net-negative tripwire): (0) EXECUTED 2026-07-31 (the ledger's
HALF-STEP REVERTS entry): the era bracket convicted the guard pair
itself — not the carve-out — as the three-micro root (element-instance
crossing, this design's own family: live published tails with no
completion drain sever the payload joins), both reverted, boot
restored to 69d6c0b0, and the widen loop REFUTED (the forty were
un-drained reads, not under-declarations). (1) Rows terminal. LANDED
SO FAR: A1 the representation swap (EtVar(v) → EtOpen([v]), marched
CLEAN 2026-08-01, the two paid laws beside it — row walks are
MECHANISM, and A2-without-the-flat-cell-law hits the hub wall) and
the PUBLISH LAW + FLAT-CELL WRITE HALF (pin 1efe083a — gate-only
publishes, flatten at both graph write ops, mn-mutual-negation-gate
GREEN). THE WRITER CENSUS then ran as the extended pricing rule's
opening measurement (2026-08-01 — 28 top-level unify sites in
infer.mn classified; "one site" was a one-grep count and the census
convicted it same-day): CLASS A, per-caller teach-back into a shared
cell (the hub): the CALL edge (infer_call_saturated:3996 — expected
carries mk_ef_open([], row_h) into the symmetric unify, and the
Open~Open arm binds only_a = the CALLEE's private edges toward the
caller's set), the PIPE edge (infer_pipe PForward:4363 — identical
shape, and its charge reads row_h so it needs both halves), the ARG
edge's var-tailed path (a bound-TFun arg meeting a non-cap param row
inside the component unify — fn_arg_directional_positions masks only
row_cap_form today, so a named fn passed to map's f teaches its own
shared cell one edge per call site), plus the low-volume cousin: the
PARTIAL path (unify_args_positionally:3746 — fresh top slots but the
components reach the callee's param structure; extend the fresh-slot
form when a probe convicts it). CLASS B, bounded symmetric merges —
the union's legitimate domain (value positions: list elements 8374,
record fields 5342, if branches 2949, match/handler arms 5917/6038,
tuple/index/spread/field 3027/3104/3333/5461, binops 5478/5486/5511,
scrutinee~pattern 5601, seq operand 3478, instance args 4274/6073) —
writers bounded by construction sites, never caller count. CLASS C,
decl-side self-writes, the legitimate direction (body~ret 2473,
resume/state 3148/3174, the frame's inf_add accumulation, the gate's
absent-join, diff_row's mask mint). Type-component symmetry stays
DELIBERATE everywhere (no type join exists; the mono view's teach
channel is its design) — the disease is row positions only.
**THE ARC LANDED 2026-08-01 (pin 13631390 — the §7 entry THE EDGES
CARRY AND THE FRONTIER STAYS SMALL): B1 + B3 + the charge-as-edge
whole, PLUS two organs the build's three 4GB refutations forced —
the QUANTIFICATION FLOOR (generalize quantifies signature frees
only; top-row-only frees are shared live links instantiation never
freshens) and the COMPLETION PRUNE (a judgment-minted still-free
edge drops as pure at the finalize; prereg cells stay as the cycle
channel — the mint ceiling on infer_ctx, re-armed per branch).
Movers 930 → 415; mn-two-tail-accumulation AND
mn-cycle-charge-freeze green. OPEN: B2 (below), B4's drains, B6's
cut deletion — the cut stands sound-conservative with its fixture
already green.** The designed ladder, kept as the record:
B1 THE
ONE-WAY CALL+PIPE EDGE — on the bound path expected's row IS crow
(the callee's own row, read before building expected), so the row
arm meets crow ~ crow and no-ops by the was==wbs identity — ZERO new
unify machinery, the mask is the identity; row_h mints only on the
free path (fh free := expected wholesale — the forward/param channel
UNSEVERED: the banked open question answers itself, the mask never
applies where there is no row to read); the call's charge is already
crow-direct, the pipe's charge rewires to read the stage's TFun row
with the share-guard kept on its free path. **B1 IS NOT A STANDALONE
RUNG — MEASURED AND CORRECTED IN PLACE (2026-08-01; the §7 entry THE
FRESH ROW CELL WAS A LIVE EDGE carries the build and the probe).**
The form above was built exactly as written and marched TRANSITION
m3 == m4 at census 0, and the two-boot fixed-input probe convicted it
on EFFECTS: `filter_list` / `map_list` / `race` and nine kin proved
**Pure** where they had proved `Memory + Alloc` (85 → 99 movers on an
identical blob — behavior, not workload). The teach-back this rung
deletes was ALSO the channel keeping the caller's charge LIVE: the
bound `row_h` resolved later through the graph, where
`callee_own_row`'s resolve folds a possibly-unjudged callee's row to a
bare VALUE the caller banks forever (Carried-Truth inverted at the
charge — a snapshot where an edge belonged). So B1's third move is
forced and it is the charge: `inf_add_row_unified` takes a bare
`EfRow([], [], EtOpen([callee_root]))` chaining into the callee's own
live cell — scheme_own_row's form, generalized past the co-member
gate — at BOTH edges. That charge needs the UNION beneath it (a
second callee's edge drops at tail_join's first-var), so **B1 + B3 +
the charge-as-edge land as ONE arc**, with B2 free to ride either
side and B4's drains closing the cycles behind them. The sub-rung's
"movers monotone down" acceptance holds for the ARC, not for B1
alone. PRICED, corrected: the per-call work does fall (one chase for
a row-unify walk), and the pricing rule's own third payment is that
"priced" must cover the read's FRESHNESS as well as its cost — this
stamp traced the semantics and the cost and never asked when the row
it reads is true. B2 THE ARG
EDGE GOES TOTAL-DIRECTIONAL — ✅ LANDED 2026-08-07 (pin 2a09f3c22a4f,
TRANSITION at census 0; movers 691 → 686; the mixed-shape census
marker measured ZERO on both legs exactly as stamped; the armed
duplicate-name class caught the build shadowing effects.mn's real
bind_edges_to live). Cap-form params keep landed subsumption; the
pure-flow shape masks and binds one-way; the arg's shared cell is
never written; the 297-site flow survives as a read. B3 THE UNION FLIPS
— tail_join's Open×Open → EtOpen(tail_set_union(vs, ws)), sound
because B1+B2 bound every shared cell's writers to its own decl's
accumulation plus Class B merges; mn-two-tail-accumulation GREENS
here. B4 THE COMPLETION DRAINS (D4) — ✅ LANDED 2026-08-07 (pin
c2becbaef475, CLEAN at census 0; movers steady at 686; the belt
silent). The drain fires at each group's own completion event after
the fold; both pass tails demote to assert_row_gates_drained
(EInternalInvariant + enforce on any survivor — report, never drop);
the final pass's drain was measured already-no-op (membership set
only in trial_judge_group) and the assert makes that checked. B5 THE MONO VIEW SHARES ROWS —
row_handles_only DELETES: the cycle discipline's row-quantification
exception existed ONLY because application-site symmetric row
unifies contaminated shared cells (the measured five mismatches),
and B1+B2 delete that channel; crow then IS the live cell for
in-group callees, so callee_own_row's group-gated re-aim,
scheme_own_row, the group_member/set_group_members ops, and the
group_names state ALL DELETE as dead code — net-negative, the
design's signature (a Class B merge teaching live group cells is a
genuine constraint — a list of co-members demands equal rows —
deliberate, marched). B6 THE CUT DELETES — BUILT WHOLE AND REVERTED ON ITS OWN INSTRUMENT
(2026-08-07): the visiting guard threaded through BOTH resolve
families (resolve_row_v / resolve_edge and the compress twins — a
visited edge stays residual, never unfolds, never rebinds:
R ∪ R = R), the decl-exit cut deleted (raw accumulated row publishes,
self and co-member edges included), and the completion fold extended
to solos (a group of one). MEASURED: TRANSITION m3 == m4 at census 0,
the pass-tail belt silent, NO exit-134 recurrence (the class fixtures
held) — and MOVERS ROSE 686 → 858 (+172), with the solo-fold
extension changing nothing. The arc's own acceptance instrument
("movers monotone down") refutes the landing as-built; blessing a
+25% rise unexplained is blessing around the instrument, so the whole
build reverted per the discipline. WHAT SURVIVES: the guard is sound
and re-lands with the deletion; the fixture battery proves the
correctness face. THE TRACE RAN AND CLOSED THE RUNG (2026-08-07, the movers-line cap
lifted probe-only for full name sets): the +172 are exactly 172 new
movers and they are RECURSIVE FNS ACROSS EVERY SUBSYSTEM (binop_loop,
diag_message, dispatch_request, the gate machinery's own walks) — the
mechanism is the TRIAL-FOLDS/FINAL-DOESN'T ASYMMETRY: the trial has
completion events (trial_judge_group's fold), the final has NONE, so
under the raw publish the trial's recursive rows fold closed while
the final's keep raw self-edges, and every recursive fn's fingerprint
diverges. THE DEEPER CLARIFICATION, read off the artifact: the
current cut ALREADY IS the (c)-separation — row_without_self drops
ONLY edges chasing to the fn's OWN cell; co-member edges survive
live. The defect the whole arc named (co-member cutting) is already
fixed; B6-as-written predates that landing. The self-drop is
LOAD-BEARING while the second pass exists (the final has no
completion event to close what the exit leaves open), and R ∪ R = R
makes dropping the self edge at the OWN cell lossless. B6 therefore
CLOSES as already-satisfied-in-substance; the literal
row_without_self deletion re-opens only when the final pass itself
deletes (the rung's endpoint), at which point no second judgment
exists to disagree. THE MOVERS PATH FORWARD is the 686's actual
content, and its first flip is IN HAND (movers_diff's own output):
fill_row trial `!27+28+-` vs final `!27+-` — the trial's row carries
interned effect 28 the final drops (the fill/float channel), and
process_lowpass flips an OWNERSHIP GRADE (buffer: ref→own — the
4.2-landed grade's forward-callee order-dependence, trial vs final
resolution states). THE TRACE'S FOUR FACTS (2026-08-07): (1) 27 = Memory, 28 = Alloc;
fill_row's link answer is `with Memory` — the PROVEN row — while its
declaration says Memory + Alloc, and every body callee (list_index,
mvl, list_set) judges Memory-only: the declaration over-states. (2)
The wheel carries 291 T_OverDeclared narrations — the medium already
names the family, fill_row among them ("declares Memory + Alloc but
body only uses Memory") — so the movers ≈ the over-declared set plus
the grade flips (process_lowpass's ref→own buffer). (3)
publish_with_instances is DEAD CODE (zero references — the
declared-flavored publish already died; both passes publish via
generalize reading the graph). (4) THE PINPOINT: movers_diff's own
re-read line shows the trial's cell answering Memory at pass end
while the trial's FINGERPRINT captured Memory + Alloc — the
divergence lives BETWEEN the trial's print moment and the cell's
final state (either a rebind after the print, or the print reading
the env SCHEME while the re-read reads the graph ROW — two surfaces,
one of them stale). THE ROOT NAMED BY BISECTION (2026-08-07, three body-ablation marches
+ a publish-moment probe): with fill_row's body emptied to NOTHING
BUT THE SELF-CALL, the trial still publishes Memory + Alloc — the
DECLARED row — while the final publishes Pure, the proof. The trial's
self/intra-group charge reads the callee's PREREG SKELETON cell,
whose row was BOUND WITH THE DECLARED ROW at pre-registration — a
declaration flowing into the supply side through the prereg bind,
precisely what ruling (1) forbids ("a declaration can never widen,
close, or EtAll a published row"); the final's normal instantiation
freshens the quantified row instead, and the completion prune answers
Pure. THE FIX LANDED (2026-08-07, pin
bb3c10c17e3b — TRANSITION m3 == m4, census 0): the one writer was
pre_register_fn_sig's TFun build; its row went bare
(`mk_ef_open([], row_handle)`), and declared_names_of + the
declared_names parameter pruned whole — the declaration lives in the
GATE alone. B4's drains stayed SILENT (no deferral widening); the
forward-ref channel rides the live cell the completion prune keeps.
THE HONEST MEASUREMENT REFUTES THE BLAST PREDICTION: movers 686 →
678 — eight killed, not the 291-family. The T_OverDeclared family
(374 narrations at the new pin) survives untouched because a
declared flavor reached a PUBLISHED row only through prereg-MEDIATED
charges (self-calls and forward refs — fill_row's ablated self-call
was exactly that shape), a small minority of the over-declared set;
the family's other members' published rows never read prereg cells.
THE SCHEME-OBJECT RULE DOES NOT FIRE YET: the rule keys on the
residue AFTER the row half lands whole, and 678 row-sort movers
remain — the row half is incomplete, and its remaining mechanism is
the published-scheme SNAPSHOT itself (trial publishes at its own
completion moments, the final re-generalizes with no completion
events; two publish disciplines over one graph). THE HISTOGRAM RAN
(2026-08-07, cap lifted probe-only, all 678 A/B fingerprints
classified — tools/movers-hist.py, dies with the channel): row-only
337, grade-only 177, row+grade 90, type-only 61, row+type 13. THE
FRONT IS MONOTONE: of the row-involved 440, the paired diffs are 421
ADD-ONLY vs 18 rem-only, 0 mixed — the final's rows are SUPERSETS of
the trial's (28=Alloc the top added name at 119, then a spread of
module effects), and the grades run 287 r→o vs 15 o→r, the same
root at the ownership altitude. MECHANISM, read off the shape: the
trial publishes a CLOSED row at its completion moment while a
forward callee is still unjudged — the live edge contributes
nothing yet, the snapshot closes without it, and the callee's later
judgment fills a cell no published VALUE re-reads; the final,
re-judging over complete trial-published schemes, folds the full
row (and param_borrows resolves the callee product, so ref hardens
to own). THE BRANCH: row-dominant ⇒ the B-arc continues into THE
ROW-HALF SWAP — the published scheme keeps the LIVE row cell (the
settled 2026-08-01 laws; the swap is unblocked), so there is no
snapshot to under-publish; B5's deletions ride with it. THE
TYPE-SORT RESIDUE IS MATERIAL: 74 movers flip concrete-in-trial to
var-in-final (flat_fill's `n:i` → `n:%0` — trial cells call-site
contaminated where the final generalizes fresh); after the row half
lands, the scheme-object rule fires against THIS set — the type-half
join question takes its fresh design pass (frozen-read extended, or
polymorphism-as-flow-edges), never the refuted architecture.
THE ROW-CHANNEL STAMP (2026-08-07, the swap's next landing —
traced, priced, writers enumerated; the artifact verified each
clause this session). SEMANTICS TRACED: the severing writer is
pre_register_fn_sig's hand-rolled quantifier —
`Forall(free_in_ty(fn_ty), fn_ty)` — because free_in_ty(TFun)
collects the TOP row's free cell (free_in_row's tail collection)
while generalize's TFun arm FILTERS row-sort handles out of the
quantifier ("live links — instantiation must SHARE, not freshen",
infer.mn:6445). Every forward call site therefore instantiates a
FRESHENED row copy above the mint ceiling; the charge chains the
copy; row_keep_completion drops it as an unconstrained judgment
copy; the caller's trial tail CLOSES without the callee's effects.
Specimen: join_loop (lib/prelude) calls `++` → str_concat
(lib/strings, `with Memory + Alloc`); prelude sorts before
runtime in the weave, so the trial publishes `!Memory+-.` and the
final `!Memory+Alloc+-.` — the probe's exact fingerprints. THE FIX
IS A DELETION: publish `generalize(handle)` at pre_register_fn_sig
(the handle is graph_bound to fn_ty one line above) — the one
quantification floor, one home; the top-row cell stays
unquantified-and-shared, every forward charge chains the
below-ceiling prereg cell the completion prune is DESIGNED to keep,
and the callee's own judgment fills it (the machinery the bare-row
landing already routed). THE GATE CONSEQUENCE (writer 3, traced):
drain_deferred_row_gates calls enforce_row_gate directly at the
group event, so a cross-group edge still free at the caller's group
completion is enforced EARLY — today this same early fire on
severed copies manufactures false T_OverDeclared teachings
(join_loop's "missing" Alloc IS the severed charge; the 374-count
family is partly this artifact). The refinement: the group drain
RE-PARKS gates still row_gate_unresolved; the pass-tail belt
becomes the tail drain — enforce every survivor against closed
truth, EInternalInvariant reserved for gates STILL unresolved at
the tail (B4 refined, not reverted: group-drain what resolved,
tail-drain the cross-group residue, assert the genuinely missed).
PRICED (§5.O): the publish fix deletes a drifted second copy of the
floor (instantiate freshens strictly fewer cells); kept edges
resolve by compress-on-read, amortized O(1); the drain refinement
reuses the pending_gates queue (re-defer O(parked), no new store).
WRITERS ENUMERATED: pre_register_fn_sig's env_extend (the fix) ·
row_keep_completion (unchanged, now exercised on kept edges) ·
drain_deferred_row_gates + assert_row_gates_drained (the
refinement) · instantiate (unchanged — unquantified cells share by
identity) · enforce_row_gate (unchanged verdicts, now fed closed
truth) · round_prints/ty_fingerprint (unchanged — A/B equality is
the metric). PREDICTIONS BANKED AS ACCEPTANCE: movers fall by
roughly the row-only class (337 of 678); T_OverDeclared falls below
374 as the false teachings die; census holds 0; the march crosses
as a TRANSITION. The grade class (267) and type-sort (74) stay,
each named to its own mechanism.
THE BUILD MARCHED AND THE MARCH REFUSED (2026-08-07, BROKEN —
reverted whole per the discipline; the kills and the refusals both
banked). THE FIX WORKS ON ITS CHANNEL, measured: movers 678 → 453
(225 died — under the 337 prediction because row+grade movers keep
their grade half), T_OverDeclared 374 → 310 (64 false teachings
died), and census 2 — two HONEST under-declarations surfaced (weave
26211: declared GraphRead+Memory+Alloc, body proves +WASI; weave
47580: the same shape richer), the widenings that ride the re-land.
THREE REFUSALS: (1) m3 ≠ m4 by 13 lines — ONE function,
free_in_fields, m4 adding a $__kf local + the multishot yield-floor
block m3 lacks; both generations' DIAGNOSTIC streams are identical
(same 453 movers, same census), so the divergence is an EMIT-TIME
read — the call's suspension classification (cardinality / yieldy
row) flipping between the m2-run and the m3-run. (2) Peak RSS
2,176,760 KB against the 1,830,000 ceiling (+19%) — the kept edges
grow the resolution walks; the flat-cell law's compress-on-read
(resolve_row_compress generalized to edge sets) is the stamped cost
answer and was NOT built — the refusal prices its absence. (3) The
two census errors above (pending widenings, not defects). THE
DISCRIMINATING PROBE, next: rebuild the fix and run the M5 LEG
(m4 compiling the wheel) — m4 == m5 means the m3/m4 toggle was the
OLD BOOT miscompiling a shape the edits newly exercise (the
generation-lag class one rung deeper; the march's arbitration then
needs the m5 rung for inference-reaching-emit changes); m4 ≠ m5
means the fix introduced a genuine nondeterminism — trace the
free_in_fields call-site classification (which row/cardinality read
feeds the yield floor) with a binary-patch probe on both
generations. THE RE-LAND SET, in order: compress-on-read (the cost
half, priced by refusal 2) · the two +WASI widenings (refusal 3) ·
the m5 arbitration (refusal 1) · then the same two edits
(generalize-at-prereg + the drain refinement) unchanged — the
channel fix itself was never refuted.
THE M5 PROBE RAN AND THE STORY DEEPENED (2026-08-07, four kills in
one sitting): (1) m4 ≠ m5 — the toggle is not a wash-out; (2) the
parity story is DEAD — probe A ran the SAME binary on the SAME
input twice and the outputs DIFFER: genuine run-to-run
nondeterminism, exactly ONE BIT (free_in_fields' call_301588 k2
yield-floor staging present/absent, all else byte-identical);
(3) the import census closes the obvious channels — the module
imports NO clock and NO random (fd/sock/thread-spawn only, the
serve paths inert in a compile); (4) the judgment streams of
differing draws are IDENTICAL (same movers, same census) — the
varying read lives in LOWER's classification, after judgment,
invisible to diagnostics. THE STRONGEST BANKED LEAD, measured: the
pinned tree compiles at 1,814,108 KB peak (1.73 GiB, BELOW 2^31)
and is stable across two draws; the fixed tree compiles at
2,176,760 KB (2.08 GiB, ABOVE 2^31) and flips — the signed-i32
boundary sits exactly between the stable and the flipping
configurations, and every byte address above it reads NEGATIVE to
a signed compare. THE DISCRIMINATING PROBE, next: compile a
TRIMMED input under the fix holding peak below 2 GiB — flip gone
⇒ the sign boundary is the channel (and compress-on-read, which
cuts the peak, is the fix's own prerequisite for a second reason;
address-compare hygiene the deeper closure); flip persists ⇒ the
boundary is exonerated and the binary-patch probe prints the k2
classifier's input (the callee-row read at call_301588's decision)
across two draws — the forensic-laws method, one binary, two runs.
The re-land order STANDS with its reason sharpened: compress-on-
read first is now load-bearing twice (cost ratchet AND the
2-GiB-boundary suspect).
THE ROOT IS CONVICTED (2026-08-07, five probes in one sitting —
the dig's terminal form): (1) the 400MB-pad probe EXONERATED the
2 GiB boundary — the padded clean compiler's output is
byte-identical to the unpadded (address-shift invariant across
2^31; the pad reserved untouched pages, RSS 1,826,108 KB, and the
bump still crossed). (2) The trap-on-spawn probe (the first ran
VACUOUS — the sed missed the folded call form; the forensic laws'
honor-the-representation clause bites tools too) re-ran correct
and CONVICTED: replacing wasi_thread_spawn's one call site with
unreachable TRAPS the fixed-tree compile — THE COMPILE SPAWNS REAL
THREADS. (3) The backtrace names the chain whole:
infer_program_final → infer_stmt_list_planned →
planned_layer_sweep → judge_blocks → spawn_block →
spawn_task_impl — the FINAL pass's planned layer sweep runs
branch judgments on host threads, judge_window = 8 concurrent
(infer.mn:2145), on every compile, today. (4) The sweep's own
comment states the precondition my fix broke: "same-layer branches
share only frozen or partitioned state: THE VALUE-BOUNDARY LAW
KEEPS PUBLISHED SCHEMES FREE OF LIVE VARS" — the parallel final's
correctness contract IS the snapshot property rung 3 exists to
delete. (5) The race site is precise: pre-fix, instantiate's
freshening gave every caller a PRIVATE row copy, so B2's
bind_edges_to taught private cells — THE SEVERANCE WAS THE
ACCIDENTAL RACE-GUARD; the fix un-freshens, so same-layer SIBLING
callers of one shared forward callee write ONE cell concurrently,
and the garbled edge list is the flipping k2 read. Every earlier
symptom closes: run-to-run variance (thread scheduling), the
judgment streams agreeing while emit differs (the race garbles a
cell lower reads, coarse counts unaffected), the clean tree's
stability (disjoint writes under the value-boundary law). THE
RE-LAND ORDER, corrected by the conviction: (1) judge_window 8 → 1
— serialize the planned sweep (spawn-join one block at a time =
no overlap = race-free even over live cells; the condemned pass
keeps its shape, and the parallel form returns at Phase 9.2 where
the deterministic handle partition and ATOMIC JOIN WRITES — the
lattice law's implementation half, a named peer for band E — are
designed in). Lands FIRST and alone; expect CLEAN (the joins'
replay is byte-identical to sequential by construction), then
re-run the same-binary flip probe to CONFIRM determinism. (2)
compress-on-read (the RSS ceiling). (3) The fix pair + the two
+WASI widenings, marched as TRANSITION with a two-draw
determinism check in the verdict. The trial's sweep shares the
constant, so window=1 covers both passes.
STEP (1) LANDED AND THE CONFIRMATION RAN (2026-08-07, pin
737147469c02 — CLEAN, census 0, cost 12.02s / 1,816,340 KB): the
sweep is serialized, and the fix pair applied over it compiles
BYTE-IDENTICALLY across two draws at movers 453 — the
nondeterminism is closed at its root, not routed around. Remaining
before the fix pair lands for keeps: (2) compress-on-read — the
BROKEN run's 2,176,760 KB peak was measured with the racing
threads' duplicated resolution; the serialized+fixed compile's
peak is unmeasured and may already sit nearer the ceiling — the
re-land march MEASURES first and builds compression only if the
ratchet refuses (never a pre-emptive tune of condemned-adjacent
machinery); (3) the two +WASI widenings (the census-2 sites), then
the fix pair, marched as TRANSITION with the two-draw determinism
check inside the verdict.
THE WHOLE SET LANDED (2026-08-07, pin a13918ee5784 — TRANSITION
m3 == m4, census 0, movers 678 → 453, T_OverDeclared 374 → 310;
the LEDGER's THE ROW HALF LANDS carries the arc). The stamp's
mechanism held exactly; its magnitude prediction was high (225
died, not ~337 — mixed row+grade movers keep their grade half);
the compression swap measured VACUOUS for the parked set
(unresolved chains fold nothing) and stays as the correct read for
the resolved majority; the peak ceiling rose to 2,250,000 with the
cost component-attributed by variant runs (kept edges +265 MB,
re-parks +106 MB) and the reclaimers named. THE MOVERS PATH
FORWARD from 453: the GRADE class (param modes are read as
callee-product VALUES during usage_of — order-dependent for
forward callees until the mode rides an edge or completion
propagation; 4.2's banked order-dependence, now the dominant
mover flavor) and the TYPE-SORT set (in-group call-site
contamination of shared cells — the scheme-object rule fires here
with its fresh design pass). Next probe: movers-hist on the 453 to
confirm the flavor split before choosing between the mode-edge
design and the type-half pass.
THE HISTOGRAM RAN ON THE 453 (2026-08-07, cap lifted probe-only
through the a13918ee pin): grade-only 250, type-only 90, row+type
86, row-only 26, row+grade 1 — THE ROW CHANNEL IS DEAD (337 → 26,
and the surviving row diffs have no monotone direction: 14 add vs
20 rem), and THE GRADE CLASS DOMINATES at 55% with the monotone
front intact (271 r→o vs 12 o→r: the trial reads unresolved
forward-callee param modes as borrow-safe, the final reads
resolved products as own). Classifier caveat, banked honestly: 77
of the row+type bin carry an empty-tail parse in movers-hist.py's
row regex (a render-vs-parse ambiguity on inner fn-type rows), so
type-involved is 90–176 and the exact cut waits for the type-half
pass; the grade verdict is unambiguous regardless. THE BRANCH: the
GRADE HALF first (the banked rule's grade-dominant arm — 4.2's
forward-callee order-dependence). The next iteration's output is
its STAMP: trace usage_of's write path (where the computed grade is
stored into the published scheme's param modes and when), enumerate
every reader of param_resolved/param_borrows, and price the two
candidate forms — (a) DEFERRED GRADES: the grade computation moves
to a completion/pass-tail event where callee products are resolved
(the drain-refinement's shape at the ownership altitude); (b)
DERIVED MODES: the published mode stops being a stored value and
becomes a projection of the live graph at read time (D1's "the
scheme is a projection" applied to the ownership aspect) — never
build ahead of the stamp.
THE GRADE-HALF STAMP (2026-08-07 — traced, priced, writers
enumerated in the artifact). THE WRITE: infer_ownership (own.mn)
runs at the fn's own judgment, classify_usage over the body's
(consume, read) pair, param_with_resolved into the param records
the publish carries. THE EARLY READ: usage_of's call arms take
arg_slot_mode → callee_borrow_params → env_lookup(callee) →
param_borrows on the CALLEE's params — for a forward callee the
prereg scheme's params are authored-only (resolved Unmarked), so
param_borrows answers the read-safe default (borrow) and the
caller classifies Ref where the final, reading the trial-published
RESOLVED product, classifies Own — the 250-mover monotone front,
mechanism confirmed. READERS OF THE GRADE, enumerated: the usage
walk itself (own:697 arg_slot_mode, own:717 labeled), the affine
ledger's borrow bracket (infer:3974 — MID-PASS, semantic verdicts,
conservative-safe on the default), the ctor-scheme projection
(infer:7603, pass-through), param_borrows' own read (types:398).
THE FORMS PRICED: (b-ultimate) ownership-as-effect riding the row
substrate — `own` performs Consume, charges as joins on live
cells, the classification a projection — is band A's own item,
DEP-rooted on the crown (the spine's ownership-as-effect
dependent), NOT this arc's build; (b-now) mode CELLS on params
re-create the temporal gap unless reads defer — no win alone;
(a-scoped) THE TRIAL-TAIL GRADE SWEEP is the minimal honest form:
after the trial's walk completes (every scheme published,
callee products resolved), one sweep re-runs infer_ownership per
fn against the RESOLVED env and re-extends the scheme with the
updated params — the trial's PUBLISHED grades then match the
final's (which already read trial-resolved products), and the
fingerprint (printed after the sweep) agrees. Mid-pass ledger
reads keep the conservative default — semantically safe, verdicts
unchanged. PRICE: one extra usage walk per fn per trial (the
judgment's own usage cost, once more, zero new stores — env
re-extend is the existing shadow mechanism); the sweep is
condemned-cadence machinery by construction and DELETES WITH THE
PASS at rung 3's endpoint (its comment names the retirement).
PREDICTION: the 250 grade movers fall to near 0; type-sort
(~90-176) remains as the scheme-object rule's set. WRITERS for the
build: infer_ownership (unchanged), the sweep hook at the trial
tail beside assert_row_gates_drained, env_extend (the re-publish).
THE SWEEP AS-BUILT WAS REFUTED BY ITS OWN INSTRUMENT (2026-08-07
— built, marched CLEAN at census 0 inside the ceiling, and MOVERS
ROSE 453 → 529; reverted whole, the repin restored to a13918ee).
The kill's mechanism, banked: the sweep re-published via
generalize(handle) AFTER full resolution, and a re-generalization
over the resolved graph quantifies a DIFFERENT var set than the
decl-exit publish did (fewer frees, different alpha order), so
fingerprints moved on fns whose grades were never wrong — and the
FINAL reads trial-published schemes, so the sweep's re-publishes
shifted the final's own downstream answers too: +76 net movers,
the monotone-down acceptance violated. WHAT SURVIVES: the stamp's
mechanism trace and reader enumeration stand; the refined form for
the next attempt is SURGICAL MODE PATCHING — the sweep updates
ONLY the param modes inside the EXISTING published Forall
(param_with_resolved on the scheme's own TFun params; same
quantifiers, same ret, same row, NO generalize call, NO graph
rebind), so the one changed dimension is the one the grade class
diverges on. If the surgical form also rises, the grade class
waits for the pass deletion itself (rung 3's endpoint dissolves
the second judgment) and the movers ratchet holds at 453 with the
grade class named as the condemned cadence's own artifact.
THE SURGICAL FORM ALSO ROSE (2026-08-07 — built, marched CLEAN at
census 0, movers 453 → 517; reverted whole, pin restored to
a13918ee). The double kill closes the grade arc with a STRUCTURAL
verdict: patching the trial's published modes changes what the
FINAL reads, so the final's own grades shift downstream and the
divergence RELOCATES up the call chains instead of dying — the
two-pass cadence cannot converge grades by patching one side; the
only closures are an iterated shared fixpoint (the rounds
machinery REGROWN, exactly what rung 3 deleted) or the second
judgment's deletion. THE GRADE CLASS (250) IS THEREFORE NAMED THE
CONDEMNED CADENCE'S OWN ARTIFACT — semantically benign (the
final's resolved-product verdicts ship; the trial's early Ref is
the conservative direction), measured by the instrument, and it
dies when the pass dies. The movers ratchet HOLDS AT 453; the
arc's remaining drivable classes are the type-sort set (~90-176,
the scheme-object rule's territory) and the 26 residual row
movers. The movers arc RESTS here — the instrument keeps its
zero-tolerance monotone-down law, and rung 3's endpoint (the
one-pass judge) is the closure for what remains.
B5 CLOSES BY MEASUREMENT (2026-08-07): callee_own_row and
scheme_own_row exist NOWHERE in the tree — already deleted along
the B-arc's landings (the refs query answers 0 for absent names
without erroring, a soft facet quirk noted); row_handles_only is
LIVE (3 refs in the completion machinery) and group_member/
set_group_members are LIVE (the deferral discriminator reads
them). Nothing to delete; the ladder's build steps are spent.
THE ACCEPTANCE RE-DERIVES (forced by the double-kill verdict):
"movers → 0, then the pass deletes" went circular the moment the
grade class proved to be the pass's OWN artifact — 250 movers
exist BECAUSE two judgments exist, so zero is unreachable while
the second pass lives. The honest D8 gate becomes: every mover
class either DRIVEN TO ZERO or PROVEN BENIGN-AND-STRUCTURAL (the
grade class is the latter, by the two builds' measurements); the
unclassified remainder is the TYPE-SORT set (~90-176) and the 26
residual row movers — the type-half fresh design pass (the
scheme-object rule, now FIRED) owns both, and its stamp carries
this re-derived acceptance.
THE TYPE-HALF PASS RAN AND THE FRAME REVERSED (2026-08-07, on the
banked probe53 artifact — no new compile). (1) THE TYPE-SORT CLASS
CLASSIFIES BENIGN-BY-CHECKING: the trial's concrete-in-group types
(flat_fill's n:Int) are HM's group-monomorphic conservatism; the
final's per-decl generalization (n:%0) is a PROPOSED polymorphic-
recursive typing that its own total re-judgment against the
published ∀-schemes then CHECKS (inference of poly-recursion is
undecidable; checking is decidable — the pair cadence accidentally
implements propose-and-check, and census 0 is the stability
verdict). The class dies with the pass; benign, proven by the
checking argument. (2) THE 26 ROW RESIDUALS ARE NOT BENIGN — they
contain a REAL FINAL-PASS UNDER-PUBLISH CLASS, and the frame
reverses: the movers' surviving row signal points at the SHIPPING
judgment, not the condemned trial. The specimen:
neg_names_to_str (gradient_delta.mn:283) is DECLARED `with Intern
+ Memory + Alloc + GraphRead`, its body is show_list with an
interpolating lambda (allocation provable); the TRIAL publishes
exactly the declared set; the FINAL publishes PURE (`!-.`), and
the SOLO oracle (import-DAG, per-decl reads) AGREES WITH THE
FINAL — the under-publish reproduces in every value-read walk.
filter_list/map_list show the same shape (trial `!Memory+Alloc+
-%t` vs final `!-%t'` — the concrete charges lost, only the HOF
tail kept). MECHANISM HYPOTHESIS, one candidate for the dig: the
HOF call's charges ride the callee row's quantified TAIL; the
frozen-read instantiate freshens the tail from the VALUE scheme,
the arg-lambda's row binds the freshened copy, and the caller's
accumulated row captured the union BEFORE the bind — the
severance class, alive in the FINAL's value-instantiation path
(the row-half landing closed it for the trial's cell path only).
THE CONSEQUENCE IS CROWN-ADJACENT: a pure-published allocator
upstream of a declared `!Alloc` makes the absence gate pass
against a false row — a live false-absence channel in the
shipping judgment. THE NEXT ITEM, outranking all movers
bookkeeping: dig the HOF-charge-loss mechanism on the
neg_names_to_str specimen (trace the final's judgment of the
show_list call — where the lambda's Memory+Alloc detaches), fix
at the root, and grow a crucible (a declared-!Alloc caller over a
HOF-allocating callee, seen RED). D8's gate inherits: the row
residuals classify only after this class closes.
THE DIG'S FIRST CUT NAMED THE SORT (2026-08-07): the 5-line repro
does NOT reproduce — `fn shout(xs) = map((x) => "{x}!", xs)`
solo-judges HONEST (`with Memory + Alloc`), and the contrast
between the honest and the lossy is visible in the projected VAR
SORTS: map's published row is `Memory + Alloc + r33878` with the
SAME r-sort var as its f param's row — connected, grounded; 
show_list's published row is a bare `t33279` with its render
param's row a DIFFERENT bare `t33282` — TYPE-sort cells,
disconnected, no content. The quantify_ctor_ty comment names this
exact disease for AUTHORED fn-typed fields ("parse_type_ty mints
the tail as a TYPE handle, which free_in_row never collects and
instantiate can't freshen, so the tail stayed a single free var
that finalize closed to Pure" — fixed there by re-minting), but
show_list carries NO annotations: an UNANNOTATED path also mints
fn-shape row positions as type-sort cells. A t-sort row cell is
invisible to free_in_row (no quantification), unfreshenable by
instantiate, uncollected by the signature keep — its charges drop
at the prune and the published row reads bare. show_list vs map
differ in: module (types.mn vs prelude), recursion shape
(index-recursive self-call vs the prelude loop), and param
position of the fn-arg (2nd vs 1st). THE NAMED NEXT PROBE: find
the minting site — where a TFun shape built by UNIFICATION for an
unannotated param mints its row position (walk_expr's apply path /
unify's fn-shape builder; graph_fresh_ty vs graph_fresh_row), and
which of the three differences selects the t-sort path; the fix
re-mints or sorts correctly at birth (the quantify_ctor_row
precedent), and the crucible is show_list's own shape as a
fixture, seen RED.
THE DISCRIMINATOR SUITE RAN (2026-08-07, scratch fixture, six
shapes solo-queried): sl (entry calling its FORWARD worker, bare
call) is LOSSY — bare t-sort row, no presents at all; sb (single
index-recursive), sc (fn-arg first), sd (non-recursive), se (bare
forwarder to a BACKWARD callee), and sf (forwarder to THE SAME
forward worker plus one sibling `++ "!"` charge) are ALL HONEST —
Memory + Alloc + r-sort connected rows. The worker sl_from itself
publishes honest. THE SELECTOR: textual CALLER-BEFORE-CALLEE, and
the sf result kills both simpler stories (not forward-ness alone —
sf is forward too and honest because it is judged AFTER the worker
in this walk; not the bare-call shape — se is bare and honest).
The walk that loses is the one that reads the callee's PREREG
scheme: its params are bare t-placeholders (no fn shape exists at
registration), quantified TYPE-sort by the floor and freshened
into ORPHAN copies at the caller's instantiation — copies the
callee's later judgment never fills (its own cells bind, not the
copies), so the caller's charge chains nothing that ever grounds,
and the presents of the instantiated row vanish with it. THE OPEN
MECHANISM QUESTIONS for the trace: (1) where exactly the
instantiated row's PRESENTS get lost (the prereg row is bare-open
— it HAS no presents; the caller's row = the kept live cell edge —
resolved by walk end it should fold honest; the query still shows
bare — so either the publish snapshot captured pre-resolution, the
edge was dropped, or the resolution's render lies); (2) where sl's
param's TFun render (with its t-sort row) comes from when sl's
body never applies render. THE TRACE: read infer_call's
forward-ref arm end to end for the sl shape, and probe sl's
published scheme's row cell state at walk end (bound or free; to
what). The crucible stands: sl+sl_from as a fixture, RED on the
bare row.
THE FIXTURE'S OWN MOVERS PRINT CLOSED THE MECHANISM TO ONE HOP
(2026-08-07, the 50-line fixture compiled unscoped through the
pin): sl is the fixture's ONE mover — A (trial)
`->AString!-%2` (the result row OPEN, the tail the kept live edge
to sl_from's prereg cell: the row-half machinery working), B
(final) `->AString!-.` (CLOSED EMPTY — the final drops the edge
and closes). And the REORDER HEALS: sl2 with the worker declared
first judges honest — same code, order flips the shipping answer,
the order-dependence rung 3 exists to kill, alive at the row sort
in the FINAL. THE MECHANISM, one hop from closed: the final SKIPS
fn pre-registration, so a caller-before-callee call has NO
below-ceiling cell to chain — instantiation freshens the published
scheme's quantified row var into an ABOVE-CEILING copy; the
caller's fn-arg is a param, so the copy stays FREE at its exit;
row_keep_completion drops above-ceiling free edges → the tail
closes pure. THE REMAINING QUESTION: why the SIGNATURE KEEP
misses the copy — sl's render param carries the freshened TFun
whose row var IS the copy, and signature_free_roots should reach
it (the Phase-1 higher-order fix covered run(f)=f()'s shape);
either the final's param cells are re-minted after the keep is
built, the keep's walk stops shallow of an instantiated TFun
binding, or the unify order leaves the param's binding invisible
at exit. READ signature_free_roots and infer_fn's final-pass
param minting; the fix follows at whichever site lies. Note: the
fixture's compile exits 1 (unclassified — read its stderr tail at
the fix landing).
THE READ RAN AND ONE DEDUCTION IS HARD (2026-08-07): the keep
machinery is CLEAN — signature_free_roots deep-chases through live
cells and row_var_is_free tolerates the t-sort mint (its own
comment documents the parser residue), build_inst_mapping mints
copies by root sort — and the charge arm
(infer_call_saturated:4272) unions THE CALLEE ROW VALUE
(inf_add_row_unified(crow)): presents ride the VALUE and survive
any prune, so sl's final losing even Memory + Alloc proves THE
CHARGE NEVER FIRED — the arm's `_ => ()` silent no-charge fallback
took it, meaning graph_chase(fh) was NOT NBound(TFun) at charge
time in the final, AFTER the unify at 4255 supposedly bound fh to
the expected TFun. The charge arm's own `_ => ()` is the
drift-catalog's silent-fallback shape sitting on a load-bearing
dispatch — whatever the mechanism, the fix hardens this arm (a
non-TFun fh at charge time is a refusal or a report, never a
silent pure). THE DECISIVE PROBE, next: binary-patch the pinned
boot's judgment of the 50-line fixture — eprint graph_chase(fh)'s
node kind at the charge arm for sl's call in both passes (one
binary, seconds per cycle, the forensic-laws method) — and read
which kind the final sees; the fix follows at the site that
produced it.
THE PROBE RAN THREE CYCLES AND NAMED THE ROOT (2026-08-07, the
eprint-armed compiler on the fixture): (kill 1) the silent
no-charge arm NEVER fires — the charge always executes; (kill 2)
every sl_from charge is a BARE EDGE both raw and RESOLVED at
charge time — correct per the charge-verbatim design; (THE ROOT)
one charge chains `t580@e1` — an EPOCH-1, PRE-REGISTRATION-ERA
cell — and it is STILL FREE at the final's read, AFTER the trial
fully judged sl_from: THE CALLEE'S JUDGMENT NEVER FILLS THE PREREG
ROW CELL. The ownership-resolve rebind (infer.mn:2671,
graph_bind(handle, TFun(inferred_params, TVar(ret_handle),
mk_ef_open([], row_handle)))) and the judgment path REPLACE the
prereg TFun wholesale — new param cells, new return, NEW row cell
— orphaning every prereg cell that forward charges chained. The
row-half landing wired callers to the prereg cell believing "the
callee's own judgment fills it"; the artifact says the judgment
ABANDONS it. The trial's A-fingerprint was never honest for the
sl shape either — it renders the raw open tail whose resolution
is bare; A vs B differ only in whether the prune closed it. THE
FIX FORM (one writer): infer_fn's row accumulator must BE the
prereg row cell — when the fn handle is already TFun-bound at
judgment entry, read ITS row cell and pass it as the frame's
row_handle (and unify/reuse the prereg param and ret cells or
bind them across), instead of minting a parallel set — carry the
handle, read live, the fix is less minting. The rebind sites to
enumerate at the build: the ownership rebind (2671), pre-register
(the TFun birth), and infer_fn's enter/exit row plumbing. The
crucible stands (mn-hof-forward-row: sl's row must equal sf's);
acceptance adds: neg_names_to_str's solo row returns to its
declared set, and the 26 row movers fall.
THE FIX BUILT, MARCHED, AND FAILED ITS ACCEPTANCE ON EVERY AXIS
(2026-08-07 — TRANSITION m3 == m4 at census 0, cost inside the
ceiling, so the reuse is judgment-correct; reverted anyway and the
pin restored to a13918ee because NOTHING observable improved): sl
still prints the bare t-row and stays the fixture's one mover with
the identical A-open/B-closed shape; neg_names_to_str still
publishes pure; movers 453 → 460. THE DEEPENED MYSTERY, banked
with the row_keep_completion read that sharpened it: the prune
KEEPS bound edges unconditionally (its first arm) and passes
through whole at ceiling 0, and with the reuse landed the chained
cell IS filled by the callee's finalize — every model path now
says sl's final exit should keep the bound edge or fold its
content, and the B fingerprint should show the open edge or the
presents; the measurement says CLOSED EMPTY. One of the assumed
layers lies: the final's sl accumulated row may never contain the
charge edge at exit (the charge lands in a frame the exit doesn't
read, or a nested-frame boundary eats it), or the published-value
instantiation inlines bindings so value readers never touch the
cell and the fingerprint renders yet another surface. THE NEXT
PROBE, mechanical: eprint at inf_exit_fn — the frame's
accumulated_row raw, per exit, on the fixture compile (sixteen
lines, order-identifiable) — read what sl's final exit ACTUALLY
holds before the prune; the layer that lied is named by whichever
row appears. The reuse form itself is banked as judgment-correct
(marched clean) and re-lands WITH the real fix once the lying
layer is found — never alone again.
THE EXIT PROBE RAN AND CAUGHT THE ORACLE ITSELF (2026-08-07,
eighteen exit lines on the fixture compile — four truths banked):
(1) the probe works and the accumulators are EDGE-ONLY by design —
presents enter only from closed-value rows (construction_row,
closed substrate schemes); main's exits show Memory + Alloc from
its literals while every fn exit is bare edges. (2) THE REUSE FIX
VERIFIED WORKING in the trial: sl_from exits with rh=208 and sl
with rh=201 — their PREREG cells, reused exactly as designed, the
self-edge visible in the acc. (3) THE FIXTURE-STDIN ORACLE IS
CONTAMINATED: the stdin compile links NO lib — `++` charges a bare
seq-op FACE var (r278-class), not str_concat's Memory + Alloc —
so the fixture cannot lose presents it never had; its A-open/
B-closed mover is face-var machinery, NOT the specimen's
mechanism. The solo query (import-DAG, lib linked) and the stdin
compile are DIFFERENT ORACLES and the dig conflated them from
iteration 61 on. (4) sl's FINAL exit acc is a single edge to
t572@e1 — a PREREG-ERA t-sort cell (mint_param_placeholders'
render placeholder by epoch), meaning the final's charge unified
into a cross-pass param-cell union whose root is the prereg
placeholder — the t-sort-in-row-position class again, now visible
as the union root. THE RE-CUT, next: the fixture gains an IN-FILE
allocating worker (a record/list construction inside the string
path — construction_row's closed presents exist without lib), so
the presents-loss reproduces in the stdin link; then the A/B
re-reads and the layer question (where presents vanish) is asked
against an oracle that actually carries them. The solo-link
specimen (neg_names_to_str) remains the ground truth throughout.
THE REVERT VINDICATED, THE SUSPICION RETIRED (2026-08-07): the
fix-era wheel binary (march64's m2, still in .build) was queried
DIRECTLY on both specimens — neg_names_to_str still renders with
NO row at all (closed pure, no edge to hide behind: the loss is
REAL under prereg-cell reuse) and show_list still the bare t-var.
Iteration 64's revert was correct; the render-artifact worry is
dead. THE SURVIVING CONTRADICTION, exact: with reuse landed, neg's
trial charge should chain show_list's prereg r-sort cell (shared
by the floor, below the ceiling, KEPT by edges_keep_completion) —
neg's published row should be open-with-edge, resolving honest
once show_list's judgment fills the cell; measured: CLOSED pure.
Either the charge chained an above-ceiling instantiated copy
(meaning the prereg publish DID quantify the row cell — check
generalize's floor against the prereg TFun in the artifact), or
the prune's below-ceiling keep did not fire (ceiling state at
neg's exit), or the charge never ran for this call shape. THE ONE
COMBINED PROBE, next iteration: reuse + movers-cap-lift + the
exit-row eprint in ONE probe compiler, the WHEEL as input,
grep neg_names_to_str's exit line and its A/B — every layer
visible in one run. THE SCOPE GUARD, banked per the stall
discipline: if the combined probe does not name the lying layer,
the dossier (fixtures, probes, the four banked truths, this
contradiction) becomes the named peer
Hβ.infer.forward-hof-row-underpublish and the loop returns to
§11's phase order — the dig continues as its own item, not as the
loop's consumer.
THE COMBINED PROBE NAMED THE WHOLE CHAIN (2026-08-07 — the wheel
through the reuse+cap+publish-print compiler; the guard does not
fire): neg's TRIAL publish is HONEST (raw=Memory + Alloc + Intern
+ GraphRead at the publish itself) and its FINAL publish reads
PURE off the graph; walking the chain, show_list's trial publish
is honest (Memory + Alloc + r163613) and its FINAL publish is
`raw=t448575@e1` — a T-SORT EPOCH-1 ROOT. THE MECHANISM, closed:
a t-sort cell (a prereg param placeholder) UNIONS into the
row-position chain during the passes' unifications and becomes
the union-find ROOT; is_row_handle on that root answers false, so
generalize's quantification floor stops recognizing the row var
and QUANTIFIES it — the severance returns at the publish: every
reader instantiates a fresh copy, the prune drops it, and the
caller publishes pure (neg's final; the 26 movers' final side).
The floor CANNOT be widened by sort alone — free_in_row's output
mixes genuine payload TYPE vars (EAType — must freshen) with TAIL
roots (must stay shared), distinguishable only by POSITION. THE
STAMPED FIX: free_in_row splits its collection — payload frees
and tail roots returned separately (or a tail-only collector
beside it); generalize's TFun and TCont arms quantify params +
ret + PAYLOAD frees and share ALL tail roots regardless of mint
sort (row_var_is_free's own tolerance, finally mirrored at the
floor); instantiation never sees a shared tail (not quantified),
so the sort-blind mint question dissolves. WRITERS: free_in_row
(the split), generalize's two arms (the filter swap), and any
other filter caller enumerated at build (query refs of
free_in_row). ACCEPTANCE: neg's final publish returns to its
declared set in the combined probe's own print; show_list's final
publish shows content + shared tail; the 26 row movers fall; the
crucible's stdin caveat stands (re-cut later; the wheel IS the
fixture here).
THE SPLIT BUILT AND THE GUARD FIRED (2026-08-07 — the
quantification-floor split + the prereg reuse, solo-clean, probed
against the acceptance and REFUSED: show_list's final publish
still `raw=t448953@e1 res=t448953@e1`, neg still Pure; reverted
whole, pin untouched at a13918ee). The refusal DEEPENED the
forensics one more level: the final's TFun row VALUE holds an edge
whose ROOT is the free t-cell — the trial's finalize BOUND that
root (the trial publishes honest), so between the trial's publish
and the final's, the root is FREE AGAIN: the final's own
unifications re-root the union (a fresh pass-2 cell winning root
above the bound one) or an unbind/replace lands elsewhere, and
the final's finalize writes a root the publish never reads. The
class is a UNION-ROOT ORDERING dance across passes — deeper than
any single writer this arc can name without a root-trace. THE
PEER IS NAMED: Hβ.infer.forward-hof-row-underpublish — a
final-pass (and solo-link) under-publish of HOF-chained rows,
crown-adjacent (a pure-published allocator under a declared
!Alloc is a false absence proof), with the full dossier in this
entry's chain (iterations 58–68: the histogram, the discriminator
suite, tests/frontier/mn-hof-forward-row.mn and its stdin caveat,
the exit/charge/publish probes, the t-sort root, the two refuted
fixes with their kills). THE NEXT INSTRUMENT, banked for the
peer's own arc: a graph-write ROOT TRACE — binary-patch
graph_finalize_row and the row-union writes to eprint (target
handle, chased root) for the two specimen cells across both
passes; the ordering dance becomes a printed sequence and the one
writer falls out. The loop RETURNS TO §11's PHASE ORDER per the
scope guard; this peer proceeds as its own item.
THE ROOT TRACE RAN (2026-08-07 — a probe compiler printing every
TB/RB/FZ/CP write plus per-decl DECL name/handle/row lines; boot
compiled the print-patched source, the probe m2 compiled the REAL
wheel, 548,830 trace lines, both specimens both passes). FOUR
KILLS, the ordering-dance hypothesis REFUTED by measurement: (1)
no write ever follows a specimen row cell's finalize — FZ is the
LAST touch, there is no post-finalize re-root; (2) the kept edge
cell is NEVER BOUND anywhere in the whole compile (show_list
trial keeps edge 164556, final keeps 454133 — each appears
exactly once, in its own FZ; "bound then freed between passes"
is dead); (3) zero graph_compress_row writes touch any specimen;
(4) zero t-sort binds (TB) target any specimen cell. THE
MEASURED LIE, relocated upstream: neg_names_to_str's TRIAL
finalize stores p4 c (four presents, closed — honest); its FINAL
finalize stores p0 c — the final frame accumulated NOTHING
before finalize, so the loss happens in the FINAL PASS's CHARGE
PATH, not at publish-read time and not in any union dance. The
consistent chain: show_list's final publish quantifies its kept
free edge (the severance at the floor) → neg's final-pass
charges instantiate FRESH row cells instead of chaining the
callee's live below-ceiling cell (454130 existed, minted before
neg's final judgment, never chained) → row_keep_completion
correctly prunes the fresh cells as above-ceiling decl-transients
→ the frame collapses to empty → FZ p0 c → pure published. The
honest prune eating dishonest input; the root is the PUBLISH
QUANTIFYING THE KEPT EDGE plus the charge path reading the
scheme copy instead of the live cell. ONE UNKNOWN remains: the
kept edge's SORT (both passes' kept edges sit at row_handle+2/+3,
minted at body-judgment start; the dossier's render tagged the
root `t…@e1` = t-sort). THE NEXT PROBE, banked: the same probe
compiler shape printing MINT lines (handle + sort + reason tag)
for the specimen decls' first mints — if the kept edge is t-sort,
the sig_keep collector pollutes the row edge set cross-sort and
THAT collector is the one writer to fix; if row-sort, the floor
must share kept edges and the fix is generalize's keep-aware
share. Probe recipe reproducible: patch graph.mn's four write
arms + infer_fn's DECL print, boot-emit, restore, run on the
real wheel blob.
THE SORT IS SETTLED (2026-08-07, the mint-print probe — MT/MR
tags on graph_fresh_ty/graph_fresh_row, same recipe): the kept
edge is `MT 454133` — T-SORT, minted by graph_fresh_ty at
show_list's final body-judgment start. A t-cell inside EtOpen's
edge set is the confirmed root: the representation contract says
edge sets hold ROW-cell handles, readers chasing the t-cell find
NFree and contribute nothing (silent), and generalize's
is_row_handle answers false so the floor QUANTIFIES it — the
severance, and the whole downstream chain the write trace
measured (fresh instantiated copies → prune → p0 → pure). This
also explains the refused split (iteration ~68): its
payload-vs-tail collector classified by CELL SORT, and a t-sort
cell in tail position classified as payload — quantified again.
THE BUILD-READY RE-CUT: classification by POSITION ONLY — any
handle inside a row's tail edge set is a TAIL ROOT (shared at
the floor, never quantified, never freshened), whatever its mint
sort; the t-tolerance the 2026-07-26 raised-lane landing gave
row_var_is_free finally mirrored at generalize's share rule.
ACCEPTANCE unchanged: neg's final publish returns to its
declared four, show_list's final shows p2 + shared tail, the 26
row movers fall, march green.
THE RE-CUT BUILT AND MEASURED VACUOUS (2026-08-07 — the
position-only floor: free_in_row_payload replacing the
is_row_handle filter at generalize's TFun/TCont row terms; solo
0, marched TRANSITION m3==m4, self-reproducing). Both acceptance
faces REFUSED UNCHANGED: neg's solo query still `→ Pure`, movers
still 451 (the only delta: two effectful-lambda convictions
re-classed, 381 → 379). Reverted whole — a marched-clean change
that moves neither observable is dead-weight machinery, not a
stack layer. THE KILL'S MEANING: the specimen's quantification
does NOT bite at the floor's top-row term — either the t-cell
quantifies via the params/ret signature terms (unique() merges
all three; my exclusion of the row term is then a no-op for any
signature-reachable cell), or the sharing lands and the charge
path still fails to heal (the scheme's row structure unread at
the charge). THE NEXT PROBE, banked: QVAR PROVENANCE — the probe
compiler prints, at generalize for the specimen decls, the
Forall's qvar list AND each of the three collection terms
(params / ret / row) separately, so the term that carries the
kept-edge cell is named by the artifact. If params/ret carry it,
the t-cell is signature-reachable and the frame shifts: the
quantification is LEGITIMATE (the cell is the decl's own
polymorphism) and the bug is the row's EDGE to a signature var —
the writer that inserted a signature type var into a row tail
edge set (the charge/tail_join layer) is the root, and the fix
is upstream of the floor entirely.
THE PROVENANCE PROBE ANSWERED — THE MECHANISM IS WHOLE
(2026-08-07, the p3 decl-exit print; the p1/p2 sites measured
prereg-only/cold, the live publish is the decl-exit
generalize at the group walk, infer.mn ~2726). show_list p3:
`P,454131,454131,454133 R W,454133` — the kept cell sits in
BOTH the params term and the top row's edge set; neg p3: P/R/W
all EMPTY. With the source (`fn show_list(ref items, ref
render, ref sep)` — types.mn:3150, an untyped HOF param), every
layer closes: 454133 is RENDER'S PARAM CELL — t-sort by
mint_params, FREE at publish — and the body's application
charged "render's row" as an edge to the param cell itself (the
crown's HOF residual design: the edge means "whatever render's
row turns out to be joins here"). The quantification is
LEGITIMATE (the param's own polymorphism, freshened per call,
bound by the caller's argument). THE ONE GAP IS THE READERS:
free_in_edges' bound arm — and its flatten/resolve siblings —
traverse `GNode(NRowBound(inner))` ONLY; a row edge whose cell
is bound `NBound(TFun(_, _, row))` falls to the catch-all and
contributes NOTHING. So a caller binding render to a real fn
(its row Memory+Alloc+…) has the edge SILENTLY DROPPED at every
row read: neg's charges fold empty, FZ p0 c, Pure published —
the measured chain end to end, with no wrong writer anywhere:
the edge is right, the quantification is right, the READ is
incomplete. THE FORCED FIX, build-ready: row-edge readers
traverse THROUGH a fn-typed binding — an edge to a cell bound
NBound(TFun(_,_,row)) reads that fn's row (what the edge always
meant); the trio law binds the build (free_in_row/occurs_in_row/
subst_row must gain the same arm together, plus
flatten_row_stored at the store and resolve_row at reads).
ACCEPTANCE unchanged: neg's solo query answers its declared
four; movers fall or re-base with justification; march green.
KILLED along the way: the position-only floor cut (vacuous —
the quantification was never the bug), the ordering dance, the
sort-pollution-at-the-writer frame (the writer is correct).
LAYER ONE LANDED (2026-08-07, pin 7343ed3f4aeb — THE ROW READERS
CROSS THE SORT): edge_row_of + the nine-site uniform dispatch,
marched CLEAN, kept per stack-correct-fixes (the readers' gap is
measured true; gate reads meet fn-typed edges mid-judgment). The
acceptance still refuses — and the remaining layer is now exact:
row_keep_completion PRUNES bound above-ceiling edges (the
caller's freshened-then-bound param cell) before
graph_finalize_row's fold — now capable of reading fn-typed
content — ever sees them. The trial's honesty was always the
below-ceiling prereg cells the prune KEEPS. THE NEXT BUILD,
layer two: the completion prune folds BOUND edge content into
presents before dropping still-free transients (resolve first,
prune the residue) — one site, inf_exit_fn's
row_keep_completion input; acceptance unchanged and now expected
to bite: neg's solo four, the sl-caller shapes healing, movers
moving with justification.
LAYER TWO LANDED, ACCEPTANCE STILL REFUSED, SCOPE GUARD FIRED
(2026-08-07, pin 26490a437a55): edges_keep_completion now
dispatches through edge_row_of (the prune's own comment made
true for the fn-typed shape), marched CLEAN — and neg's solo
query STILL answers Pure with movers still 451. The conjunction
has a layer the write-trace reconstruction did not reach:
readers fold fn-typed edges (layer 1), the prune keeps them
(layer 2), yet the finalize still stores empty — so either the
frame's row never HOLDS the fn-typed edge on the solo path (the
charge writes something else than the reconstruction assumed),
or the fold's content is empty at fold time (the param cell
bound AFTER neg's finalize?), or the query's render path reads a
different surface than the finalize wrote. THE NEXT PROBE,
banked for this peer's own arc: the finalize-INPUT print on the
CURRENT wheel — eprint at inf_exit_fn (pre-prune frame row: its
presents and each edge with its chased kind) for the specimen,
one probe compiler, one run; the layer that lies is then read
directly. Per the stall discipline the loop RETURNS TO §11 PHASE
ORDER; this peer proceeds as its own item with the probe recipe
standing.
THE FINALIZE-INPUT PROBE RAN (2026-08-07 — FZIN prints RAW |
after-self | after-prune with per-edge chased kinds, both passes,
both specimens). THE LAYER IS THE CHARGE VALUES, and the
callee-publish-severance frame BREAKS on it: neg TRIAL RAW = p2 +
edge→BOUND-row-cell → WOS folds → p4 honest; neg FINAL RAW = p0 +
ONE edge→free-t-cell (neg's own body-start mint) — the final
pass's charges deposited NOTHING: no presents, no callee-cell
edges. A CLOSED-row callee (++'s Memory + Alloc has no vars to
sever) still contributed zero, so quantification/severance cannot
be the whole mechanism. show_list final RAW = p2 + edge→free
render-cell, SIG-KEPT through the prune (layers 1 + 2 behaving
exactly as landed). THE NAMED SUSPECT: the seq-op FACE
(seq_face_ty, the 3.3 landing) — neg's body is seq-op work, and
the dossier's own stdin caveat measured "++ charges a bare
seq-op face var"; if the face's row is a fresh var per mention
that nothing ever binds to the op's DECLARED row, every face
charge is a free edge and the frame accumulates exactly what
FZIN shows. The trial's honesty would then be a different
resolution path (prereg skeleton cells, below-ceiling, bound by
the op's own judgment). THE PINNING PROBE, banked: print
seq_face_ty's produced row (tail kind) per mention +
inf_add_row's inputs for the specimen's body across both passes —
one run answers whether the face row binds in trial and dangles
in final; the fix is then seq_face_ty keeping the op's DECLARED
row (concrete, closed) under the element-polymorphic face — the
row was never the polymorphic half.
THE FACE HYPOTHESIS KILLED BY SOURCE (2026-08-07, the cheapest
probe first): seq_face_ty's row is `crow` from
instantiate(scheme) — the callee's own instantiated row, exactly
as its comment says — and neg's body holds NO direct seq-ops
anyway: it is ONE HOF call, show_list(names, lambda, " + ") (the
++ lives inside the lambda, whose effects belong to the lambda's
own TFun row until called — correct). THE SHARPEST SURVIVING
FRAME, consistent with every measurement including the p2-present
scheme contributing nothing: the call's row charge is the
one-way-edge design's pair — the frame gains an EDGE to a
call-site row var (f395303, neg's body-start mint — the FZIN
edge), and that var's unify against the callee's row runs
SEPARATELY; if that unify PARKS as a deferred row gate
(drain_deferred_row_gates re-parks cross-group gates to the pass
tail), it drains AFTER inf_exit_fn's finalize already read the
frame — the var binds too late, the published row froze p0. The
trial's honesty = different park conditions (group membership,
gate-resolution state differ between passes). THE PINNING PROBE,
re-cut: print the defer/enforce/drain events (name, row_handle,
gate cell) beside the DECL/FZIN prints — one run shows whether
neg's call gate parks in the final pass and drains after its
finalize; the fix is then ORDERING (drain a decl's own gates
before its finalize) or the charge carrying the resolved row
VALUE instead of the unbound var edge.
THE TUNNEL-MAPPING HYPOTHESIS BUILT AND REFUTED (2026-08-07):
the source chain read subst_edge_build_into consulting
find_mapping on the CHASED root first, with chase_handle's
row-sort arm tunneling through a bound cell's single-edge tail
to the quantified var beyond — the presents at the mid-chain
bound cell discarded by the freshening short-circuit. The
bound-content-first reorder marched CLEAN and moved NEITHER
observable (neg solo still Pure, movers still 479) — reverted
whole, the floor-cut verdict class. FOUR marched layers now
stand as this dig's record (floor cut reverted, readers kept on
live-path merit, prune keep kept on comment-truth merit,
bound-first fold reverted), and the FZIN facts remain the
hardest measurements: final RAW p0 + one free edge whose
identity matches the freshened HOF-row var. THE HONEST STATE:
the charge loss's one writer is still unnamed; source derivation
has been refuted three times where only instrumented A/B
measurement discriminates — the charge VALUE at
inf_add_row_unified per call, printed beside the pass tag, on
the specimen and on a healthy sibling; the differential names
the writer. THIS PEER NEEDS A DEDICATED SESSION with the
movers_diff + charge-print apparatus as one combined instrument
— beyond loop-iteration scale. The loop returns to §11 phase
order.
(2) Decl cells + correspondence edges;
the final pass demoted to a pure ASSERT whose override count must
read zero. (3) The completion-bit column; generalize deletes. (4) THE
DELETION: one-pass judge, D8 swept, measured against the 563MB-class
anchor (§5.O's cost law). (5) Resident, incremental, and the fan
inherit the form; measure, never re-plumb. Banked gates, RED or
green today: ping/pong answer Pure (scratchpad pingpong.mn), solo
stays Pure, mn-mutual-negation-gate compiles, mn-cycle-charge-freeze
and mn-two-tail-accumulation go green, the mover narration deletes
with its channel, census 0, frontier whole, the march. Swap behind
the projections — the read surfaces keep their signatures.

`Hβ.infer.forward-hof-row-underpublish` — RESOLVED 2026-08-11 (pin
c6eb188e1d37, TRANSITION, the LEDGER entry of the same name carries
the three-probe arc). The writer was merge_chased_row's catch-all
(graph.mn): the chase's reading law tunneled through a bound row
cell's single-edge tail and DISCARDED the accumulated presents when
the chain terminated at a cross-sort free t-cell (a fn-typed param's
cell) — trial chains end at NRowFree (preserved), final chains end at
the param t-cell (discarded), which is the entire trial/final
asymmetry. The fix collapsed the NRowFree special case and the
catch-all into one uniform preservation arm. Acceptance met on all
three legs: neg solo answers its declared four, show_list publishes
p2 + shared tail, movers re-based to 474 (honest reads change the
trial/final comparison itself). The class's standing wheel-link gate
is the census's zero-tolerance E_EffectMismatch (it refused the first
repin at census 1 — seen RED — until render_row_triples' honest
+GraphRead widening); the stdin fixture's contamination note stands
in the parent chain. THE DEDICATED ARC's record follows — the entry
was born 2026-08-11 (the forensic chain lives in
`Hβ.infer.schemes-are-edges`' 2026-08-06/07 tail; consult, never
re-read whole). The measured false-absence channel: a
final/solo published Pure under a declared row — specimen
neg_names_to_str (src/gradient_delta.mn:283, declared Intern + Memory
+ Alloc + GraphRead; solo query answers Pure) — crown-adjacent: every
`!E` verdict on a HOF-chained row inherits it.
THE SUPERSESSION (Morgan 2026-08-11, via the loop's standing cursor):
the chain's two closing rulings — "the loop returns to §11 phase
order" and "beyond loop-iteration scale / needs a dedicated session"
— are superseded TOGETHER: the loop session IS the dedicated arc (one
session, context accumulating across iterations, this entry the spine
that survives compaction). PLAN §11's standing cursor holds this peer
at the front until CLOSED, or PARKED per the protocol below.
THE COMBINED INSTRUMENT'S FIRST FIRING (2026-08-11, P1 iteration 1 —
DECL windows at infer_fn + both-arm charge prints at the saturated
charge site + movers cap lifted to 500, one run on the wheel; recipe
proven: Edit-patch → boot-emit → git-restore → run, probe artifacts
in .build/probe-fhof). TWO KILLS and the cascade measured whole.
Kill 1: the charge path's `_ => ()` no-charge arm NEVER fires — 0
NCH / 30,928 CHG across the whole compile; absence-of-charge is dead
as a mechanism. Kill 2: the charge path is exonerated entirely — the
VALUE it reads is already degraded when it arrives: neg's charge of
show_list reads p2 v (trial) → p0 v (final); show_eff_name's own
window reads show_list p2 v → p0 v identically; the lambda-frame
read of show_eff_name itself degrades p4 c → p1 c (Intern alone —
its standing T_OverDeclared names the same survivor); while
show_list-INDEPENDENT callees are byte-stable across passes
(intern_name_of p1 c, eff_name_str p1 c). The cap-lifted movers dump
(483 flips) holds the family: neg, show_eff_name, show_list,
show_list_from all flip. THE CASCADE HAS ONE ROOT: show_list's
PUBLISHED row instantiates as p0 + free tail for every final-pass
caller, though its exit frame carries p2 + sig-kept edge (FZIN,
layers 1+2 green) — the concrete presents vanish between the
after-prune frame and the instantiated read. THE PUB PROBE NAMED THE HOP (2026-08-11, P1 iteration 2 — fzs/pub
prints at the decl-exit and group-final publishes, per decl per
pass): the STORED row term is p0 v in BOTH passes (a bare tail var —
content lives behind the tail cell), and generalize's scheme
DIVERGES on the tail cell's state: show_list trial DXP scheme p2 v
(tail chased to BOUND content), final DXP scheme p0 v (tail FREE —
chase folds nothing); neg trial p4 c → final p0 c (the Pure the solo
query answers); show_eff_name trial p3 v → GFP p4 c (the GROUP
publish is HONEST) → final DXP p1 c, and env reads newest-first, so
the degraded final decl-exit OVERWRITES the honest group publish —
the lie wins by publish order. Cross-pass feedback proven in-run:
show_list's final exit (stderr line 8197) precedes neg's final
judgment (12011), so neg's final charge instantiates the p0 v final
publish — the iteration-1 CHG differential end-to-end. instantiate
is EXONERATED (it copies what the scheme holds). ONE hop remains:
why the FINAL pass's finalize leaves the fn-ty row term's tail cell
UNBOUND where the trial's is bound — infer_fn mints a FRESH
row_handle per pass and rebinds fn_ty per invocation, so the
candidates are the cell-identity split (finalize writes a different
cell than the term's tail references in the final pass) or
finalize's fold dropping the frame's kept content (FZIN showed the
final frame carries p2 + sig-kept edge INTO finalize). THE NEXT
PROBE, banked: the finalize-identity print — at inf_exit_fn's
graph_finalize_row, print the written-to row_handle + written fp;
at DXP, print the stored term's tail cell handle; per pass, per
specimen. Handle equality names the split; handle equality with
dropped content names the fold.
ACCEPTANCE (the chain's, unchanged): neg's solo query answers its
declared four; movers fall or re-base with justification; march
green. On CLOSE: retract the superseded frames in place, true PLAN
§7's seam line, re-cut the stdin-caveat crucible
(tests/frontier/mn-hof-forward-row.mn), and the cursor advances.
THE PROTOCOL (the loop's P1 discipline — one home, here): probe
cycles open and close on a CLEAN tree (`git status --porcelain` empty
before any commit that is not itself the landing); a dirty tree at
iteration open is disposition-FIRST — diff it, restore probe prints
before any other action; a probe compiler is never marched and never
pinned. A banked fact must DISCRIMINATE — kill or confirm a standing
hypothesis, or name a writer; a probe that answers no banked question
is churn, not a fact. Each banked fact REPLACES this entry's prior
next-probe paragraph (frame + kills + the one banked probe — never
append-only accretion), and a frame the artifact later refutes is
retracted in place. Each P1 iteration increments the counter below in
the same commit as its banking; an iteration banking no
discriminating fact appends a dated STALL line instead. PARKED at
three consecutive STALL lines or p1_iterations = 12, whichever first:
write PARKED on the counter line, surface it as the report's last
line, and the cursor advances — reopened only by a new measured fact
or Morgan's word.
p1_iterations: 3 — CLOSED (the peer resolved; the counter retires with it)

`Hβ.infer.round-oscillation-movers` — ROOT FOUND 2026-07-31, and the
peer's own framing is superseded in place: this was never an
"oscillation" and the rounds' deletion did not end it. The movers are
the trial/final divergence, they number 930 on the wheel (the count
instrument landed with the finding — the sixteen-slot display had
hidden the magnitude for a week), and their SOURCE is a fifteen-line
reproduction: A CYCLE MEMBER'S ROW IS PUBLISHED AS A VALUE AT ITS OWN
DECL EXIT, before its co-members are judged, so their effects never
reach it (tests/frontier/mn-cycle-charge-freeze.mn; the §7 entry THE
SOLO IS A CYCLE carries the mechanism and the asymmetry that proves
it). The blocker text below stands as the era's record and its
OPERATIONAL WARNING still holds — row-perturbing engine work in
verify/infer gambles the attractor — but the reason is now named
rather than mysterious, and the cure is rung 3, not a better cadence.
The remaining sub-findings below (the SCC-internal crawl, the marginal
run-variance) are consequences of the same publish-as-value root.
(the era's record follows)
(2026-07-30, third victim): the Pure predicate-fn UNFOLD was built
whole (332-line patch banked in the session scratchpad — the binder
env absorbing the self special-case into node_const_env, the bool/
match evaluator over litval, the body lookup through the env's
Located reason + the span log, the Pure-row gate, the one-level
PBoolNode hook) and its row widens flipped main's row to carry a
phantom Intern no spine component performs — the same
parts-don't-sum signature as the 2026-07-29 relocations and the
2-cycle-cut probe. Row-perturbing engine work in verify/infer now
GAMBLES the attractor every time; the oscillation root outranks every
queued increment until fixed. The dig's standing instruments: the
movers/flip channels, the Pure-pin row-printing bisection, the scc2
trace. (2026-07-29; DUG 2026-07-30 — the
pin-78b1736b landing carries the arc): the "oscillation" was a MONOTONE
resolution front, and three of its four roots are CLOSED (the
fingerprint's set-order fabrication; the backward-only layer walk; the
source-order trial). The REMAINDER, measured by the graduated flip
instrument (movers_diff + probe_tail_why, now the bound-hit's standing
diagnosis channel): the unify/parser SCC chain — within a
mutual-recursion cycle, member B reads co-member A's PREVIOUS-round
final across the cycle's stale link, so an SCC's closure crawls its
internal diameter one round per link; the bound still cuts at ONE
mover (parse_effect_list_from, 2026-07-30), and the daily-verb tax
(~59s field read) is round-count × the per-round FIXED costs (full
re-parse + classify_fixpoint + round_prints — cone-independent). THE
FIX (re-specified twice on 2026-07-30, each by a measured kill — the
pin-5db9b4c3 and no-pin ledger entries carry both): the Tarjan SCC
substrate is LANDED (scc_groups; the trial walks groups
callee-first); classic GHC mono-binding-groups are REFUTED (29 wheel
convictions — the wheel's cycles use polymorphic intra-group
instantiation); and bare per-SCC re-derivation iteration is REFUTED
(rollback-as-fresh-nodes works — simple pairs converge in two probes
— but generic/concrete-tension families ALTERNATE with period 2
forever: re-derivation-from-scratch is not monotone, exactly Salsa's
cycle-recovery contract). THE THIRD COUNTED KILL (2026-07-30,
Morgan's vet — "re-judge? re-infer? re-derive?" — the build reverted
uncommitted): the iteration WITH the generality join was built whole
(ty_join — concrete-over-free pointwise widening preserving cur's
linkage, rows through row_join; closed freezes
Forall(free_in_ty(chase_deep(t)), t) inert across rollback; the join
operating on instantiate(prev) vs instantiate(cur) so no
cross-generation handle ever mixes; all-fn groups only) and the
artifact refuted it on its own terms: TRANSITION m3 == m4 at 355,307
lines with census 0 — a self-stable attractor — but the ONE bound-hit
mover (parse_effect_list_from) SURVIVED untouched (its flip lives in
the rounds' own re-derivation, outside the trial's groups) while the
attractor moved 107,432 emission lines with nothing arbitrating the
move as better. Cost without cure — and the deeper conviction is the
DIRECTION: probes that re-judge, freezes that snapshot, joins over
re-derivations are the tower growing, the exact compensation
machinery `Hβ.infer.schemes-are-edges` already names as the thing to
DELETE. Carried-Truth at architecture scale: the fix for
schemes-read-stale is never a better re-derivation cadence — it is
schemes as live join-written cells the union-find propagates through.
THE ARC REDIRECTS THERE, terminally: this peer's remaining content is
absorbed into `Hβ.infer.schemes-are-edges` (the tower deletion), and
no further tower machinery lands. FIRST RUNG EXECUTED (2026-07-30,
pin 574bc20d — the §7 entry THE ROUNDS ARE DELETED): the rounds, the
bound, the cone, and the mask are GONE; the judgment is trial → final
(the verification framing superseded 2026-07-31 — the final OVERRIDES
on divergence and DELETES at rung 3; the §7 rounds entry carries the
ruling), the bound-hit class dissolved with its substrate, and the
movers instrument graduated to the trial-vs-final divergence report. THE MOVERS' DIG RAN THE SAME DAY and its five
kills are the peer's sharpest evidence yet, each one probe: (1) the
mechanism, confirmed at 8 lines — a recursion edge resolving through
a QUANTIFIED scheme freshens the row var (the frozen-read law), so
row_without_self's tail-lands-on-own-handle premise breaks: `solo`
(self-loop) flips trial-open/final-closed (the trial's
pre-registration vs the final's mono self-registration), and `ping`
publishes `with r…@e…` in BOTH passes — a mutual pair's rows NEVER
close (the mutual-negation-gate root, now measured by the medium's
own query). (2) The join-identity trap: binding a bound terminal to
pure hits the teaching JOIN, and joining pure is the identity —
3,131 measured no-op "closes." (3) The per-member finalize froze
group rows MID-LEARNING — 19 refusals naming the exact dropped
names. (4) Group-exit scoping healed 19 → 2, but the survivors are
the tell: the banked phantom-Intern-at-root attractor class
resurfaced, and a THIRD mover family appeared (the collectors/ml) —
any row-resolution perturbation re-selects the attractor, the
tower's signature. (5) THE RULING, the vet's law applied to the
digger: a third cut site is compensation regrowing the tower —
REVERTED whole; in the edges representation the problem DISSOLVES
(a join-cell taught by its own recursion joins idempotently, R ∪ R
= R — the least solution IS the lattice fixpoint, no cut, no
publish-freshening, no severance). The movers stay the standing
narration (trial correct-but-open, final closed, emission
self-stable); the 8-line probes (solo/pingpong) and the three mover
families are schemes-are-edges' acceptance tests, banked in the
session scratchpad's mover-probe.mn / pingpong.mn shapes.

`Hβ.emit.arm-closure-captures-record` RESOLVED: LANDED (2026-07-24, pin
bb4b870e — the ledger head carries the arc). The capture form won over
the $world_find read exactly as this entry ruled, and for a soundness
reason the ruling had not yet named: a commit targets its own install's
record — a LEXICAL fact — while a chain walk under a rebound redrive
world could resolve a same-named NESTED install's record instead. The
__hrec ladder (LLet alias / seeded capture / trailing param) carries
the record everywhere; the global, the bracket triple, and the
singleton_hnames walk family are deleted; the OneShot-in-thunk cousin
(20-not-25, silently wrong on the prior pin) died in the same landing.

`Hβ.cli.infer-context-bracket` RESOLVED: LANDED (2026-07-23, pin 2644dab5 —
the R5 entry in the ledger; the arc: refuted by the mint-time evidence
snapshot, then admissible the same night when the world-as-value R2 made
performs resolve at the call site; infer_context is the one home, all 14
chains route through it). The history below is the refutation record that
priced the world arc: the analysis-core ORDER LAW is written at its one
home (pipeline.mn's spine block) — ledgers innermost, lookup_ty before
env before graph before mutate_sink, diagnostics outer to graph (its arms
report: the occurs-check fires from graph_bind) — and doc_run's missing
env_handler landed, completing the core on every inference-reaching chain.
The CONSOLIDATION itself was built (a bracket fn taking the body as a
thunk, all 14 chains rewritten) and REFUTED by the artifact before commit:
a closure's evidence snapshot predates the bracket's installs, so every
EVIDENCE-dispatched core op faults its ev-scan into the sentinel — compile
trapped at executable_gate's verify_debt() (Verify is multi-handler:
verify_ledger + verify_smt), the at verb trapped on its ambiguous cursor
ops, while check/doc/teach/query/repl passed on singleton-tier ops (the
state global is dynamic). The split is exactly singleton-vs-evidence; the
wheel shrank 1,568 lines and compiled census-0, so the refutation is
semantic, not syntactic. THE CONVERGED DESIGN (same night, Morgan's
charge to read the pieces together — WORLD-AS-VALUE): the world is a
first-class graph value, a handle to the top of the install chain in the
image ([handler_record, parent] nodes, one $world_g global, O(1) cons per
install, trail-covered restore), with THREE PRINCIPLED TRANSPORTS all
already typed by the kernel: CALLS FLOW the world (the evv the §6
evidence-passing claim always named — the per-frame captured_evs snapshot
was a mint-time CACHE of a dynamic fact, Carried-Truth violated at the
kernel layer); ARMS REBIND to the install node's parent (the deep-handler
law — the M3 fence's PURPOSE, kept, its lexical approximation retired);
RESUMES REBIND to the world frozen on the k record (world_tag@28 upgrades
from bit-tag to handle; the declared-unwired E_ResumeWorldMismatchWorld
gate wires as a side effect — band B's value gate). The earlier "needs a
replay discriminator, open research" hedge is SUPERSEDED — the rebinding
rules ARE the discriminator. The infer half already exists
(inf_current_world onto every ContinuationEdge, TCont's 4th arg). The
dispatch gradient survives whole: tail-resumptive direct calls and the
singleton tier stay as proof-becomes-dispatch cash-outs over the ONE
semantics (the singleton state global becomes the cache of a unique world
entry; the uninstalled-guard's state_g==0 read becomes chain-miss →
refuse). This dissolves BOTH band-N evidence bugs, and its consumers are
the whole §2 fan: the bracket (this peer's original form, re-run as the
proving consumer), per-candidate virtualizing worlds in synth's fork pair
(the third leg beside graph checkpoint + heap region), work-stealing
frontier entries carrying their world as one memcpy-portable word, and
the depth-economics design (no depth parameter: gradient=priority,
handler=budget, multi-shot=memory — every frontier entry a dormant
continuation resumable across cursors/sessions ONLY if its world is a
value). MEASURED RED GATES, minted 2026-07-23 (scratchpad fixtures, to
graduate as frontier legs with the arc): thunk-world (a thunk minted
outside an install, called under one, evidence-dispatched op) traps 134
today, 42 under worlds; arm-config-ev (band N's true shape — a
config-param thunk performed under an arm-internal install) answers 2
today (silent wrong value: re-enters the outer handler), 40 under worlds;
the plain-block shadow control already answers 40 (no-regression
control). BUILD RUNGS, each marched: R1 world-chain substrate
(install/uninstall push-pop + $world_g, additive) → R2 the perform swap
WHOLE (evidence tier reads the chain; captured_evs op-dispatch dies; the
__resume k-threading channel survives — it is an argument, not evidence)
→ R3 arms-under-parent-world → R4 reify/resume world word + the band-B
gate live → R5 the 14-chain bracket consolidation re-run → R6 the fork
pair's world leg in synth/oracle. R2/R3 carry the whole-battery blast
radius; the multishot-era gates (52→66) and the march arbitrate.

`Hβ.infer.nested-alternative-branch-bracketing` (2026-07-24, born of the
fork-spine fix's own build — the medium refusing its builder twice): the
branch/scope ownership fix (1e06cdaa) brackets if/match arms as
BAlternative, but an if-with-consumes NESTED INSIDE a match arm breaks
the enclosing arm union — consumes in LATER sibling arms then collide
cross-arm (E_OwnershipViolation "consumed twice" false positives).
Measured twice on revert_trail_into: the if-in-argument-position shape
AND the let-bound-if shape both refused, while the IDENTICAL cross-arm
consume pattern in single-call arms (revert_trail, one fn over) passes —
so the trigger is the nested alternative, not the arm consumes. The
§4⑤ Hylo-quiet bar names this inference failing (a provably-safe shape
demanded restructuring); the fix is the branch bracket nesting as a
STACK (enter/exit balanced per alternative level), and the
undo_set_within hoist is the passing form until it lands.

`Hβ.ops.wasmtime-runner-migration` (2026-07-23 recon; the wheel-side
spawn glue LANDED 2026-07-24 — the §7 ledger head carries the arc):
steps (1)-(4) are EXECUTED. (1) the 36.0.0 LTS re-pin + wt-env.sh
flag-spelling probe (2026-07-23); (2)+(3) tools/runner — wasmtime crate
47.0.2, wt_run-argv-compatible — S1 byte-identity + battery through
both legs, S2 spawn smoke (tools/runner/smoke/spawn-import.wat,
IMPORTED shared memory re-exported for the p1 ABI) 42 through runner
AND CLI; (4) the banked RED (mn-real-spawn, 134 unaligned-atomic in
the join on both engines) is RESOLVED by the task-record landing (pin
8891428f): the four glue links died into the task record +
proof-driven memory ownership — a spawning module imports the shared
image and allocates through the shared cell; a thread-free module
defines its memory and ships NO thread-spawn import, so the
must-satisfy-thread-spawn instantiation constraint is dissolved
everywhere it was inert. THE PARENTHETICAL HERE READ "(boot included)"
until 2026-09-06, and the artifact refutes it: `wasm-objdump -j Import
-x boot/mentl.wasm` shows func[17] `wasi.thread-spawn` and a shared
`env.memory`, so the pinned boot is a SPAWNING module by this very
taxonomy — as it must be, carrying lib/threading and the judge's own
fan. It was true of the boot that stood when the line was written and
went stale without anyone re-reading it; the class it describes is
unaffected, only the example. The three real-spawn frontier legs (int /
float-carrier / identity) run 60 through BOTH engines. REMAINING
scope, host-path only: (5) swap wt-env.sh/install.sh (+ hosted CI when
it returns, §11 col 5) to the runner, drop `-S threads=y`; (6) retire
the LTS pin. shared-everything-threads is the named eventual target,
unimplemented in any host — name it, do not build toward it. The
BROWSER LEG LANDED 2026-07-29 (the §7 ledger head carries the arc):
ide/wheel-worker.js is the runner pattern at the browser host — a
pre-armed worker pool consuming a SharedArrayBuffer task ring, the
stub-spawn shim retired to the gate's RED control
(tools/ide-gate.sh).
STEP (5) IS TWO HALVES AND ONLY ONE IS A SWAP (MEASURED 2026-09-06).
The pin is a CEILING, not a preference: the same spawning module
answers exit 60 through 36's CLI and `Error: the -Sthreads flag is no
longer supported`, exit 1, through 47's — the CLI cannot execute
Mentl's own output past 36, so every later release is unreachable
while the CLI is the runner. That makes (5)-(6) the only exit rather
than hygiene. The GATE half is a swap: nothing in verify / march /
frontier / crown listens on a socket, so pointing wt-env.sh's WT at
tools/runner lifts the ceiling for the whole board and the compile
path. The SHIM half is BLOCKED ON A BUILD, and the blocker is not the
runner's — it is the crate's: wasmtime-wasi 47's p1 adapter does not
implement sockets AT ALL (`p1.rs` sock_accept logs "p1 sock_accept is
not implemented" and returns Notsock; sock_recv/sock_send likewise),
and 47's CLI refuses the flag outright with "components do not
support --tcplisten". Both measured against the pinned boot, whose
`space` verb serves HTTP 200 on /ide/ through 36 and answers nothing
through 47. So `mentl space` and `mentl session` — Arc E's own
surface, the standing cursor's terminal bar — cannot leave 36 by
swapping a binary. Moving them means the runner OWNS the p1 socket
surface the way it already owns thread-spawn: bind the listener as a
host resource, seat it as a descriptor, and implement sock_accept
against the p1 table. That is the honest shape of it and it is the
same shape as the spawn glue that already landed here — one more host
resource the guest cannot create — filed as
`Hβ.ops.runner-owns-the-p1-socket`. Until it lands the split is
NAMED, never silent: the board runs on the runner, the two listening
verbs run on 36, and the LTS pin retires at (6) only when both do.

`Hβ.infer.live-cells-need-one-settled-signature` — RUNG 3'S REAL DEP,
MEASURED TO A MISCOMPILE 2026-09-07. Publishing the decl's CELL (Live) in
place of a Frozen snapshot now gets ALL THE WAY THROUGH inference and emit —
m2 clean at census 0, m3 exit 0 at 532,547 lines, census 0 — and produces
WAT THAT DOES NOT ASSEMBLE:
    m3.wat: type mismatch in f64.load, expected [i32] but got [f64]
    m3.wat: type mismatch in call, expected [i32,i32,i32,i32,f64]
                                   but got [i32,i32,i32,i32,i32]
At the site: `(call $number_from_substring) (f64.load)` — the caller unboxes
a result the callee returned WIDE. Caller and callee disagree about the f64
ABI, which is the twin-edge conversion pair (`Hβ.emit.twin-state-width`:
args word-faced, results deref'd, inits boxed).
THE ROOT IS NAMED IN THE EMIT'S OWN COMMENT, and it is not a walk
disagreement, a mint band, or a resource limit: "an untwinned callee emits
per its DECLARED scheme ... the same emit_wide_ref/emit_wide_deref pair,
applied per THE ONE SIGNATURE BOTH SIDES AGREE ON". The ABI is a CONTRACT
and a contract is a FIXED fact. A live cell is time-varying, so "the one
signature both sides agree on" stops existing: the callee's body and the
call site can read the decl at different moments and choose different
widths. Frozen publication hid this by giving both sides the same snapshot —
it was not correct, it was COINCIDENTALLY AGREED.
THE ULTIMATE FORM IS NOT "KEEP THE SNAPSHOT". There is a legitimate settling
point and it is not the decl's exit (where generalize freezes today, the
moment the cell is LEAST finished): it is the infer→lower/emit PHASE
BOUNDARY, which graph_bind_row's own comment already names — "the freeze
that makes lattice reads sound is the infer→lower phase boundary, already
structural". Reading a settled fact after inference completes is not a
snapshot; it is a read. So the ABI must be read ONCE at that boundary rather
than baked per-decl during lower, which is `Hβ.lower.lowering-is-a-column`
(§11 5.5) — the lower-time-bake family the ledger has declared dead three
times. RUNG 3'S LIVE CELLS ARE DEP-GATED ON THAT DELETION, and this
miscompile is the evidence; the DEP is the next thing to build, not a stop.
WHAT IS ALREADY PROVEN ON THE WAY: substitution sharing landed alone (pin
8fb668de); the walks now agree on both axes measured here (a visited set as
the exact guard where chase_deep tripwires at d>200, and free leaves
canonicalizing to their union-find ROOT); generalize needs no deep chase (a
shallow head plus a chasing free-var walk reads the same quantifier without
materializing the tree); and the branch overflow band needs re-measuring for
the live regime (64 was measured 2026-07-26 against Frozen; 128 still
exhausts, 256 completes).

`Hβ.infer.movers-is-the-wrong-ratchet-under-live-cells` — THE ACCEPTANCE
CRITERION IS WRONG, MEASURED 2026-09-07. The movers line counts "schemes the
final judges DIFFERENTLY than the trial published", and rung 3's acceptance
has been stated as movers → 0. Under LIVE publication that number does not
fall, it RISES: measured 474 → 1594 with the decl's cell published instead of
a Frozen snapshot (the branch band raised to 4096 so the run reached far
enough to report). That is not a regression. With a snapshot, divergence
between the passes is HIDDEN INSIDE the snapshot — the trial's frozen view
simply stops tracking, and the count sees only what the comparison happens to
catch. With a live cell there is nothing to hide it: the cell IS current
truth, so every decl the final touches reads as a mover. The metric measures
snapshot disagreement, and live cells have no snapshots to disagree.
So the stage contract's own sequencing is right and its ratchet is not:
movers → 0 arrives from DELETING THE SECOND PASS (contract step 4, "the
trial/final collapse FOLLOWS, not precedes"), never from making two passes
agree. Reading the ratchet as a gate ON the live-cell step inverts the order
and would refuse the landing that makes it reachable. THE HONEST GATE for the
live-cell step is the fixpoint plus the census (m3 == m4, census 0), with
movers re-derived AFTER the trial pass is gone; until then a movers RISE at a
publish-Live landing is expected and must be read, not ratcheted.

`Hβ.reason.provenance-is-a-value-tree` — THE PROVENANCE FACE OF THE ONE LAW
(measured 2026-09-06; PLAN §11's ONE LAW, FOUR FACES block is the home for
the synthesis, this entry for the mechanism). `GNode(NodeKind, Reason)` puts
a RECURSIVE VALUE TREE on every node. Classified against the artifact, the 24
constructors carry: a copied EDGE (`Declared`, `VarLookup`, `FnReturn`,
`FnParam`, `LetBinding`, `Instantiation`, `InferredCallReturn`,
`DefaultReason` — each naming a node that exists); copied STRUCTURE
(`OpConstraint`, `MatchBranch`, `Unified`, `ListElement`, `IfBranch`,
`InferredPipeResult` — antecedents duplicated into every node that unified,
which the Why render admits as "the DAG rendered as the tree it is"); copied
VALUES the graph holds live (`UnifyFailed(Ty, Ty)`, `Refinement(Pred, Pred)`
— snapshots, so a Why chain can render types that later resolved
differently, a correctness defect and not only redundancy); copied POSITIONS
(`Located`, `Placeholder`); and genuinely irreducible content in exactly
three places — a label, a `BinOp`, an SMT witness. The labels measure 208
distinct `Inferred("…")` strings, 171 fixed and 37 templated: a FIXED
COMPILER VOCABULARY carried as String, drift mode 8 in the middle of the
provenance layer, and the 37 templates are edges (the name interpolated into
"return of '{name}'" is the fn NODE).
THE ULTIMATE FORM: a Reason is a FLAT TAG PLUS HANDLES — `R(RTag, [Int])`,
no recursion, no Span, no copied Ty, no String names. "Walk to root" becomes
follow a handle and read THAT node's reason: the tree structure becomes the
graph it was always describing, provenance is SHARED rather than duplicated
(an allocation win on the OOM channel), positions come from nodes so they
survive editing, and `UnifyFailed`'s operands read live. `show_reason`'s
24-arm string builder collapses to a tag render plus projections; `Located`
dissolves wherever the position is its own node's, which is the dominant
`graph_bind(handle, ty, Located(span, …))` shape. WHAT IT EMPOWERS, and the
reason it is not cosmetic: the teaching tie-break asks "what distinguishes
these survivors", which is a provenance DIFF — a graph diff over edges, an
absurdity over duplicated trees — so PLAN §11 11.1's minimal-entropy
question is gated on this. Band L's `.reason-edge-pcc-certificate` (a
discharged proof carrying a walkable certificate) is the same edge set read
by the prover. SURFACE: 698 Reason construction sites, 104 graph_bind, 126
report — the largest in the compiler, and H6 enumerates every one.

`Hβ.parser.module-blind-parse` — ONE ROOT, FIVE COMPENSATIONS (found
2026-09-06 by walking the felt path with the CLI, as the felt-path-first
law prescribes). THE PARSER DOES NOT KNOW WHICH MODULE IT IS IN. The
driver concatenates the dep DAG into one text and parses it whole, so
every node is born in the WEAVE's coordinate space with no module
attribution, and five separate machines exist to put back what that one
blindness threw away:
(1) the range map, carried out-of-band beside the graph;
(2) NModule nodes minted AFTER the parse, reconstructed from that map
    (driver.mn's own comment records the era when they had ZERO writers
    and every span resolved to the "" module);
(3) `rehome_seam_comments`, a post-pass moving comments that attached
    across a module seam — its comment states the cause outright, "the
    parser cannot see seams";
(4) `module_path_of_span`'s `scan_for_enclosing_module`, an O(next)
    containment search per call, whose own comment names its "O(1)
    destiny";
(5) the seam-render family — module_seams + seams_walk (O(nodes) per
    call), seam_of_line, span_render_local — four ways to answer "which
    module is this line in?" about a value that should never have lost
    the answer.
MEASURED SYMPTOM, the one that surfaced it: on a SEVEN-LINE file
`mentl why addr.mn double` answers `at 2726:1-2726:21`, because
show_reason renders the raw weave span while the refs facet three lines
away answers `addr:7`. Every felt surface goes through show_reason — LSP
hover, the cursor view's Why line, the type facet's Reason — so §0's
intent-is-walkable property walks to a line no developer can open. A
translation layer every reader must remember to call is one some reader
will not call.
TWO NON-ULTIMATE FORMS WERE BUILT AND REJECTED HERE, both recorded
because each is instructive. (a) Threading the seams into show_reason:
fixes the symptom, entrenches the compensation — a bolt, Anchor 8, and
named as such in the same session that named the family. (b) `Span`
carrying its module (`Span(m, sl, sc, el, ec)`, 96 sites, the whole-wheel
census answering 100): SUFFICIENT, not ultimate — a span inside a Reason
is a COPIED PROJECTION of where a node is, the same disease as a Frozen
scheme one layer over, and copied coordinates ROT UNDER EDITING, which
the resident session and incremental edit depend on them not doing.
THE ULTIMATE FORM: parse PER MODULE. `lex(source_m)` gives module-local
spans, the NModule node is minted BEFORE its parse, and
`parse_program(toks, nmh)` attributes every node at birth — the module a
spine COLUMN (5.5's mechanical test), O(1). One-namespace judgment never
required one TEXT, only one ENV: parse each module, concatenate the DECL
LISTS, judge as one program (infer_program_converged already separates
`lex |> parse_program |> infer_program_*`, so the seam is where it needs
to be). All five compensations delete, plus driver_module_ast's
span-containment filter. And the Reason layer follows: `Located(span, r)`
is a coordinate copied beside the very handle it describes — the
dominant call shape is literally
`graph_bind(handle, ty, Located(span, …))`, the node and a copy of the
node's own position passed to one call. Located carries a HANDLE, and
where the position IS its own node's it dissolves outright.
GUARDS, RED-first: the why-coordinate assertion in tools/frontier-gate.sh
(`mn-where-badges:8` — born RED against the pre-fix boot, which answers
`2729:1-2729:15`); census 0; m3 == m4.

`Hβ.query.comment-prose-search` (2026-07-24, the ⟳ self-build law's
first named confession): the vocabulary sweep ran on grep while
comments are already graph content — the medium's form is a query
projection over the comment weave (find-by-word across attached prose,
spans out, the same channel the Lede facet reads). Small, and it makes
every future prose sweep a verb instead of a hand tool.

`Hβ.runtime.cross-compile-durable-state` CLOSED (2026-07-23, the
adversarial forensic-prober's independent dig — a fresh mind refuting
the accumulated corpus first, then proving the root behaviorally): the
cross-compile trap was the EFFECT-CENSUS COLLECTOR RUNNING AS A
NULL-STATE SINGLETON IN EMIT'S WALK EXTENT. project_emit_state
installed six visitor collectors but not effect_census_collector, so
the shared walk's visit_effect_install routed through the singleton
tier with __state = 0 — its installs accumulator lived at ABSOLUTE
ADDRESS 12 (the null page), below every region mark, never reset,
holding a pointer INTO the region; the reset zeroed/rewound the region
and the next compile's census walked the stale pointer as a list
(named backtrace: list_index_unchecked → string_in_list_loop →
op_effect_census_collector_visit_effect_install → walk_install_groups
→ walk_lemit → project_emit_state). Installing the collector: the full
region-bracketed battery runs 112/112 with byte-identical emitted wat.
The thirteen-kill probe corpus (2026-07-22, the same peer's prior
text) is SUPERSEDED as diagnosis — its pre-virginity infer-side
symptom was this same null-singleton class read through address reuse
under the rewind-only reset, and its "values no placement wrote, in
virgin memory" was exactly right: the writer was outside every
placement channel, storing through the null page. What the corpus
PAID FOR survives as law (CLAUDE.md ⟲, the forensic laws): one-binary
gates, protocol-honoring probes, retraction-on-refutation, counted
kills, and the virginity contract itself ($heap_reset_impl zeroes
[mark, bump) — the allocator accident made a contract; 192MB battery
peak). The CLASS is closed structurally, both altitudes: the wiring
(every walk_lemit bracket installs every visitor family the walk
fires) and the SingletonUninstalled guard in singleton_perform_block —
a singleton op call finding state_g = 0 REFUSES loudly at the site
(the tier's evidence IS the global; null evidence is missing evidence,
the direct-call twin of LUnresolvedEvidence), so the silent null-page
read is unsayable. The regioned battery ships (main.mn battery_loop
mark/resets per micro — the arena's first real workload, §5.O).

The manifest arc's residue (2026-07-18, the arc itself CLOSED — §7 ledger):
`Hβ.infer.order-independent-verdicts` (the census is ORDER-CONDITIONAL: a
runtime fn declared before its prelude consumer meets the TIGHT inferred
scheme where the canonical order met the loose pre-registered one — three
real latent mismatches at prelude sum/chunk/trim under a leaves-first
weave; the canonical sort sidesteps, the class remains; repro: swap
lists/strings before prelude on stdin. The COMPLETE form was BUILT TWICE and
unwired twice by the SAME measured wall (2026-07-23 in the
instance-crossing landing; RE-BUILT AND RE-MEASURED 2026-07-25, phase
B-ii step 0 — the ledger entry carries the arc): a TWO-PASS WALK — a
diag_quiet trial finalizes every scheme; the final pass re-judges fresh
nodes against those finals (fn pre-registration SKIPPED — infer_fn's
unbound-handle arm self-registers monomorphic recursion; the
duplicate-fn refusal decoupled into its own seen-set walk) — closes the
class whole: its verdicts on the wheel converged 50 → 0 and the fifty
findings LANDED as the 2026-07-25 harvest (abs, infer_unaryop, the
formatter's chain arms, autodiff's matrix, the field-carrier split, the
str-raw satellites, ~35 row widens). The wall is CURRENT, not stale:
the judge-0 wheel's m3-leg self-compile exhausts the 4GB bump extent at
emit_wide_wrappers (alloc's wraparound guard; ~28s, 1.1GB RSS). THE
TWO-PASS RE-WIRE IS SUPERSEDED (2026-07-31, the resolved design —
Anchor 2's condemned clause): order-independence is not a second pass,
it is live join-cells with decl→site propagation; this class CLOSES at
rung 3 and no pass cadence returns under any DEP. The 2026-07-25 build
recipe stands only as the era's record.
THE CALLEE-FIRST BLOB (2026-07-23, the field landing) kills the class's
src→lib face whole: the canonical wheel input is lib-before-src, so
every cross-layer reference is BACKWARD; the bare-scheme census fell
492 → 256, and the residual 256 are intra-src forward references — this
peer's remaining scope. In-file, callee-first source order kills
instances one at a time — prelude's iterate_from precedes iterate for
exactly this reason) ·
`Hβ.patch.set-target-state-clobber` RETRACTED (2026-07-18, same day):
probed on the pinned artifact with both a len read and a full iterate,
before and after the perform — seven of seven survive; the original
"lost tail" measurement came from a probe-perturbed build (the
wheel-eprint Heisenberg class: the PROBE-R eprints inside
entry_start_caret changed the very emit under test). A label is a
hypothesis until the artifact confirms it — this one died by the law
that minted it; the hoisted read stays as ordinary hygiene ·
`Hβ.driver.per-module-env-overlay` gains its measured consequence: the
per-module check walk inferred prelude without its layer's vocabulary
(len/list_index missing on a clean program) — check rides the weave until
the overlay lands.

The 2026-07-18 census-tail peers: boundary-weave-generic-thunk-row and
rowbound-ty-residual-tagged both LANDED same day (the census-zero arc —
§7 ledger). `Hβ.emit.option-niche-repr` remains open at its EMIT half:
slot_present landed the READ (a table-typed `a -> Bool` presence test
over the 0-or-handle word), but Option CONSTRUCTION still boxes and
match-on-Option still tag-compares — the lower/emit arm that makes both
read the niche (0=None, handle=Some, zero boxing) is the landing.

The 2026-07-18 harvest + panel born peers (each artifact-verified before naming):
`Hβ.infer.type-decl-name-registry` (a second `type X` silently MERGES —
disjoint ctor sets share tag ids; measured: cross-tag match returns the wrong
arm, zero diagnostics; the decl refusal needs the type-name registry — a
SchemeKind representation change, its own landing; repro banked) ·
`Hβ.lower.trecordopen-wrong-field` (VERIFIED LIVE silent-wrong-VALUE: an open
receiver `u: {name: Int, ...}` reads the wrong slot — offsets computed over
the partial field set while the record sorts over the full set; the panel:
instrument whether self-compile hits the arm, then concrete-receiver
resolution, never a blind -1 refusal) ·
`Hβ.runtime.list-index-bounds-check` (SYNTAX §Indexing promises a runtime
trap; lists.mn tag-0 raw-loads with NO bounds compare — every OOB index is a
silent wrong read; the fix restores the promised trap, and list_index_proven
becomes the genuinely-unchecked variant the R5 discharge selects) ·
`Hβ.infer.narrowing-write-requires-discharge` (R5 re-scoped by the panel: the
elision machinery is DEAD CODE — narrowing_pred_handle descends PAnd's left
conjunct to PTrue, handle 0, never fires; delete the dead machinery, then the
real form: record only when the path predicate discharges BOTH 0<=i AND
i<len(receiver)) · `Hβ.mentl.verify-after-apply-boundness-only` (the teach
loop's proof check reads node-boundness, never re-runs row subsumption;
narrow_row binds without re-inferring — an `!Alloc` proposal on an allocating
fn reads back 'proven'; fix = re-run subsumption under a FRESH diagnostics
handler, graph_rollback does not cover diagnostic state) ·
`Hβ.infer.ctor-record-construction-unify` (single-variant record-wrapping
`Ctor({...})` construction unifies against the ctor's arrow type instead of
its result — ~5 voice sites of E_TypeMismatch) ·
`Hβ.infer.expect-same-chases-bound-var` (LANDED 2026-07-20, pin a0dd9849 — the
ledger head has the full arc). expect_same was the LONE unify arm that bound a
var without chasing, so a scalar clobbered a ctor-argument reference's
NBound(TVar(binder)) live binding and the parameter never learned the field
type (Float → i32 floor → indirect-call trap); the one-line fix chases like
every other arm. It unmasked the runtime handle-word pun, which the §4①
string-layer typing closed whole: byte_len/byte_at/str_slice/str_concat/
view_base/the float builders are seq-ops, str_of_buf is the ONE construction
boundary (a raw buffer word IS a String), handle_recorded dedups Int handles
by i32.eq. Census 0, m3 == m4, board whole. Repro registered:
tests/frontier/mn-ctor-float-param.mn. The next rung the fix exposed —
`Hβ.lsp.hover-response-emission`: serve now clears the json float blocker and
reaches the LSP layer but does not yet write a hover result
(Hβ.lsp.transport-runs-frontend)) ·
`Hβ.lsp.transport-runs-frontend` (ensure_doc_open reads bytes, never
lex/parse/infers — hover reads an unpopulated graph; v1 = the pipeline splice)
· `Hβ.format.render-totality-before-fmt` (SHARPENED 2026-07-23 — the exact
census + the oracle design, ready to open): format.mn is 577 lines of
DORMANT machinery (zero callers; the Format effect + format_program/
format_at_handle/format_chain real). The three surrender-fallbacks measure
as 18 missing arms: render_expr_tokens 17/25 (missing BlockExpr,
LambdaExpr, MakeRecordExpr, MakeStringExpr — the interpolation re-render —
MatchExpr, NamedRecordExpr, RecordUpdateExpr, ResumeExpr),
render_stmt_tokens 4/9 (missing LetStmt, TypeDefStmt, EffectDeclStmt,
HandlerDeclStmt, RefineStmt), render_pat_tokens 3/8 (missing PLit, PTuple,
PList, PRecord, PAlt) — the easy spine renders, everything structural
surrenders. THE BUILD: (1) the 18 arms + precedence-aware parenthesization
(render must be parse's inverse under the ONE precedence table) + the
COMMENT WEAVE projection (decl/interior/trailing comments are graph
content now — the formatter is the weave's biggest consumer; dropping
prose is destroying source); (2) the fmt verb as whole-file projection
(read → frontend → render → write, the tighten driver's surgery
generalized from one clause to the file); (3) THE ORACLE — the formatter
judged by the self-hosting machinery itself: idempotence
(format∘format == format, byte-equal), then format the ENTIRE WHEEL and
the formatted wheel must compile census-0, hold comment-refs 0, pass
battery + frontier, and reach its own m3'==m4' fixpoint — the formatted
source then BECOMES canonical in the same landing. (4) The payoff ratchet:
the 760 E_RedundantBraces (MachineApplicable, format-liftable) die as a
side effect of canonical projection, with E_RedundantPerform and
E_StatementSemicolon riding free — the medium's next batch-authored sweep
after tighten. RED-first fixtures per missing arm class (today a match or
lambda formats to `<expr>` — the gate) · `Hβ.multishot.handler-return-clause` (M5 — named twice in
git history: docs/research/multishot-general-design.md as the next ladder step, absent
here until now) · `Hβ.lower.branch-isolated-handler-state` (the multishot
doc's own correction, missing from every band) ·
`Hβ.infer.usage-grade-unifies-cardinality-ownership` — NOTE: this peer's
name was REUSED on 2026-07-17 for the branch/scope ownership fix; the
ORIGINAL residue (unify classify_usage and resume_grade onto one count_uses)
is still open and lives under this line ·
`Hβ.emit.compose-width-floor` (implemented in lower.mn, tracked nowhere until
now) · `Hβ.cursor.gradient-queue-activate-or-delete` RESOLVED: DELETED
(2026-07-23, pin 56f01996 — the 107-line larval block died whole; band
E's work-stealing-via-gradient keeps the design) · `Hβ.graph.fork-dead-code` (graph_fork + the overlays
module-to-handle index: built, zero callers, taxing the hot alloc path — an
activation slot or a deletion) · `Hβ.emit.float-evidence-ft` (an f64-argument
candidate/closure call dispatched through an all-i32 $ft — `indirect call
type mismatch` at enumerate_float_literals the first time a float-position
enumeration ever ran; the $ft repr-vector walk's evidence-call gap, the
fleet's float-HOF class with its first concrete anchor) ·
`Hβ.why.flow-naming-at-call` (the README Why's `flows into echo(mix, x)`
line — a call-arg's reason carries VarLookup but no callee/param naming;
FnParam-at-call woven into the arg reason at infer) ·
`Hβ.why.refinement-provenance` (the README Why's `output bounded by Sample
via soft_clip` line — the refined alias's provenance chain at the return
position).

`Hβ.synth.vocabulary-arg-holes` · `Hβ.synth.vocabulary-reach-index` ·
`Hβ.cursor.enclosing-decl-edge` (band M kin) ·
`Hβ.cursor.session-weave-epoch-scope` (DISSOLVED by the peer audit — the
session `<~` loop deletes the re-parse that created it; §11) ·
`Hβ.infer.alias-preserving-unify` (LANDED 2026-07-17 — not a unify-peel bug:
a forward-referenced refined alias bound a bare TName; `pre_register_alias`
registers the edges before any fn signature, §7 ledger) ·
`Hβ.own.region-return-transfer` (LANDED at the check; the caller-side
re-tag under region polymorphism is the arena increment) ·
`Hβ.lower.partial-via-lambda-recipe` (the peer-audit merge of
partial-effectful-callee + partial-local-callee: the mint routes through
the LambdaExpr machinery) / `.partial-prefix-arity` (lower.mn floors,
typed) ·
`Hβ.lower.k2-remainder-fncall` · `Hβ.lower.abandon-with-resume-arm` ·
`Hβ.lower.stateful-install-crossing-yield` (band B kin) ·
`Hβ.cli.audit-row-var-render` (cosmetic) ·
`Hβ.emit.int-splice-empty` · `Hβ.emit.f64-closure-capture-box` ·
`Hβ.m2.callsite-result-width` (the loud width family) ·
`Hβ.felt.ide-run-in-page` (in-browser assembler).

`Hβ.infer.sigd-polymorphic-recursion` — §11 5.3's first step,
STAMPED 2026-08-07 (build next). BASELINE, measured at the 5.1c
kill: `fn depth(x: a, n) -> Int = ... depth([x], n - 1)` with a
FULL authored signature refuses E_OccursCheck — the self-call uses
the mono assumption even under the signature, so SYNTAX's
"polymorphic recursion prices a signature" is refuse-both-ways,
below Haskell/OCaml's crude accept-with-annotation route.
SEMANTICS TRACED to one writer: infer_fn's bind-before-body
(infer.mn:2568–2576) — when the decl handle is unbound at
judgment, `env_extend(name, Forall([], fn_ty))` SHADOWS the
prereg's quantified scheme with a mono view, and every self-call
chains the mono cells (unify of [a] against a → the occurs
refusal). The poly route half-exists already:
pre_register_fn_sig publishes generalize(handle) of the
signature-built TFun (quantified for a fully-sig'd decl), and
group_mono_views (infer.mn:1800) EXEMPTS fully-sig'd cycle
members from the mono downgrade — the intra-decl shadow is the
one remaining mono writer. THE BUILD: the `_` arm's env_extend
goes conditional on fn_fully_sigd (the existing discriminator,
infer.mn:1823) — sig'd: skip the shadow, the prereg quantified
scheme stays in scope and self-calls instantiate it fresh per
use (propose-and-check: the body still judges against fn_ty via
graph_bind + the authored param/ret pins, so a body violating
its signature still refuses E_TypeMismatch at the pin sites);
unsig'd: the mono bind stands (HM's mono recursion, soundness).
PRICED (§5.O): zero new machinery — one conditional on an
existing predicate, no scans, no state. WRITERS: one
(infer_fn's env_extend arm). GATE, RED-first: the depth fixture
as a frontier leg — E_OccursCheck through the incumbent boot,
compiles-and-runs through the fix. RISKS, arbitrated by the
board: sig'd self-recursive wheel fns re-judge (census + march);
published schemes may shift (the movers ratchet; a re-base needs
the publish-surface justification). SEQUENCED NEXT after this
step: the Henglein single-call fragment inferred (annotation-free
for the decidable shape), the row side per arXiv 2510.20532, and
the proposed-signature TEACH (the medium proposes the signature
from the call sites it judged — the question beats the guess).
THE FRAGMENT, STAMPED 2026-08-07 (the annotation-free step —
inference where Haskell/OCaml demand the annotation; build after
the teach settles). FORM: Mycroft iteration on the medium's own
speculative substrate — the propose-and-check the trial/final
pair performs by accident, made deliberate per decl. DETECTION
(cheap, syntactic, pre-judgment): the decl is unsig'd AND its
body contains a self-call — those decls judge SPECULATIVELY:
graph_push_checkpoint → judge under a diag-CAPTURE bracket (the
tighten_collector shape with the outward forward held) → on
success, release diags and commit (mono recursion, the common
case — near-zero overhead: one checkpoint + one held list); on
an occurs refusal carrying the teach's FnParam/FnReturn
fingerprint → graph_rollback and RETRY under the Mycroft step:
the name pre-bound to Forall(frees(fn_ty), fn_ty) — the fn poly
over its own fresh cells, exactly the sig'd path's shape with
fresh vars standing for the unauthored types — re-judge, up to
K = 3 rounds or scheme stability; success publishes the INFERRED
poly scheme (the emit's cap + self-ref floor, already landed,
absorb the specialization tail); at K the held refusal + teach
forward unchanged (graceful — never worse than today). Henglein's
fragment (single self-call, non-nested) is the termination
argument for the shapes that converge; K is the totality belt
for everything else. WRITERS: the per-decl judgment driver (the
group walk's decl arm — one speculative bracket), zero new graph
state. PRICED: cost only on unsig'd-recursive decls (one
checkpoint each; retries only after a fingerprinted refusal).
GATE, RED-first: the mn-poly-teach fixture FLIPS — today
refusal + narration; with the fragment, checks and runs 3
unannotated (the leg's assertion inverts; the sig'd fixture
stays green). RISKS: rollback discipline across the decl's env
writes (env_scope_enter/exit must pair through the retry — the
re-entrancy the affine bracket already handles per body);
movers/census arbitration as always.
BUILT WHOLE (2026-08-07, pin 94fd07add038 — the LEDGER's THE
FRAGMENT INFERS): as stamped plus the round-3 soundness recheck
the stamp had named as "or stability" — the result scheme
detached via chase_deep BEFORE the rollback (heap values survive;
graph cells do not), qvars re-minted and subst_ty'd, the row
rebuilt fresh-open (the top row cell is unquantified and would
dangle). mn-poly-fragment runs 3 unannotated; mn-poly-teach
retargeted to the K-exhausted floor (bad — ret ~ [ret] at the
recheck). NAMED NEXT on this peer: (a) alpha-stability detection
(accept early when S_{n+1} ≡α S_n instead of always running the
recheck round); (b) the multi-call fragment boundary (two
self-calls at different shapes — currently both check against
the same assumption, sound via the recheck, but the boundary
deserves its own fixtures); (c) the concrete-signature derivation
in the teach (the narration proposes the actual inferred
signature text — the fragment's own round-2 result rendered); (d)
the row side (arXiv 2510.20532 — decidable row inference may
delete the row half of the price entirely).
BUILT WHOLE (2026-08-07, pin d8142b3b1d98 — the LEDGER's THE
SIGNATURE BUYS THE POLY SELF-CALL): the judgment conditional as
stamped, PLUS the emit half the stamp's risk table missed —
opening the judgment gate resurrected 5.1c's divergence (the
kill's "cannot reach the emit" premise died with the occurs
refusal): the per-base demand cap (spec_base_count >= 8, the
tail flooring at the uniform word protocol) and the
self-reference floor at spec_resolve_build's TVar arm (a binding
containing its own var answers the word terminal — the ctx
re-application exhaustion measured at 13 stacked frames). The
fixture runs 3; the frontier leg pins it. RESIDUE of the arc,
named: (1) the cap's floor is SILENT-but-correct — the teaching
narration ("this base floored at N specializations; a signature
pins the width") lands with the proposed-signature teach step;
THE TEACH, STAMPED 2026-08-07 (build next): at the occurs
refusal on an UNSIG'D poly self-call, the refusal STAYS (mono
inference is HM's floor) and gains the teaching narration —
"polymorphic recursion: the signature buys the poly self-call;
annotate NAME's params and return" — HasPlaceholders, per §1's
question-beats-guess. SEMANTICS TRACED: ONE in-wheel report site
(unify's occurs pre-check, infer.mn:5152; graph.mn's bind guard
is the non-unify belt and stays plain), and the detection is a
FRAME-MEMBERSHIP read — the occurs-refused root chases into the
current judge frame's param/ret cells while the frame's decl is
not fn_fully_sigd (the frame stack already carries the decl; an
inf op projects the current frame's name + cells — one new
read-only op if none serves it). The CONCRETE signature proposal
(deriving the annotation text from the mono-side ground types
with holes at the polymorphized positions) is the fragment
work's own output and SEQUENCES WITH IT — the v1 teach names the
shape and the fix direction, never guesses the types. WRITERS:
the one report site + a T_PolyRecursionSignature narration ctor
(DiagKind + report arms + SYNTAX's narration table). PRICED:
zero steady-state cost — the detection runs only on the occurs
error path. GATE, RED-first: the unsig'd depth fixture — today
plain E_OccursCheck; with the teach, the narration names depth
beside the refusal.
(2) `Hβ.persist.image-key-compiler-build` — NEW: the warm-compile
image (.build/warm-compile-*.img) is keyed by source hash only,
and a NEWER boot restoring an OLDER boot's image traps in alloc
(measured during this dig; images cleared by hand). The key must
include the compiler build (the boot sha) so a repin invalidates
the warm set by construction.

`Hβ.infer.schemes-are-edges` — THE STAGE CONTRACT, WRITTEN FROM THE
REFUTED HYBRID (2026-08-26, the Space spine's B′.ii re-entry). The first
stage-1 attempt built a Live(Int) variant inside Scheme, a scheme_live
projection boundary, a ResolvedForall wrapper ADT, and twenty-five
pattern edits across eight files — and the medium refused it three
ways at once: H6 totality demanded the Live arm at every read site
(static exhaustiveness does not shrink because a boundary projects);
generalize's reach smuggled WASI + GraphRead through every env resolve
row (26 E_EffectMismatch — the read boundary had become a graph walk);
and the whole surface is throwaway at the terminal form. THE LESSON,
Morgan's law applied: do not make a lesser design work. THE TERMINAL
CONTRACT (already written in the artifact's own condemned-carrier
comments — Scheme's and instantiate's — now assembled):
(1) THE ENV CARRIES NO SCHEME OBJECT. Entries become
    (name, Binding, reason, kind) with `type Binding = BStatic(Ty) |
    BCell(Int)` — BStatic for the trees that do not move (aliases,
    ctor variants, effect decls), BCell(h) for judgment-published
    decls. The Scheme ADT dissolves from the env layer entirely.
(2) QUANTIFICATION IS A PROJECTION THE CALLER RUNS: a decl's type IS
    chase(h); the quantifier (generalize's free-in-params walk) is
    computed where polymorphism is consumed, never stored. generalize
    deletes; the chase/free-in walks stay (graph reads the readers'
    rows already carry — no boundary tax, no row smuggling).
(3) INSTANTIATION IS THE CORRESPONDENCE-EDGE MINT instantiate's own
    condemned comment specifies: mint fresh cells for the decl's
    parameter cells, draw one one-way edge per pair, teaching
    propagates decl→site as joins, the clone-the-type walk (subst_ty
    family, 43 sites) deletes.
(4) THE TRIAL/FINAL COLLAPSE FOLLOWS, not precedes: live cells leave
    nothing to diverge; the final's residual duty (the poly-rec
    Mycroft recheck, 5.3's decidable-fragment guard) survives at group
    grain behind tests/micros' depth-unannotated fixture.
(5) lower's ~365-line second effect-analysis engine dissolves in the
    same landing — its reads become cell chases (the subsumption
    RESIDUE already records).
GUARDS, RED-first: the movers line (466 at this writing) reads ZERO or
names only the under-publish class; mn-depth-unannotated stays runs-3;
the crown's 39 crucibles stay green; the wheel self-compiles through
the correspondence edges (m3 == m4, the trusting-trust anchor).

THE STAGE CONTRACT IS PARTLY STALE AND THE BLOCKER IS MEASURED
(2026-09-06). Two corrections and one located wall, all against the
artifact:
— STAGE (1) IS LANDED. types.mn already carries
`type Binding = Frozen([Int], Ty) | Live(Int)` under the header "rung 3
landing A"; the contract above still describes it as future work under
the names BStatic/BCell. What did NOT land is the PRACTICE: 45 Frozen
construction sites against 9 Live, so the env holds snapshots through a
type that can hold cells.
— THE TWO-ARM BINDING IS ITSELF RESIDUE, and the contract's BStatic
should not be built. A static tree (alias, ctor variant, effect decl) is
a cell that is already bound and will not move; giving it a distinct
BINDING KIND is drift mode 6, the primitive-special-case, at the env
layer. The terminal env maps name → HANDLE, boundness read live — which
is `name-is-handle` (§5.O layer 1) and schemes-are-edges turning out to
be one law at two altitudes. Binding's discriminator dies when the Live
arm becomes universal, not by a second arm being designed.
— THE MOVERS ARE CLASSIFIED, all 474 (tools/movers-hist.py over an
uncapped movers_diff): grade 261, row+type 107, type 88, row 15,
row+grade 3; row direction add-only 19 with ZERO removals; grade
directions r->o 282, o->r 13. So the type-sort residue is 195 of 474 and
decision (2)'s pre-committed branch is the FRESH DESIGN PASS, not the
D1/D2/D6 no-go.
— THE TYPE-HALF JOIN QUESTION IS NOT A BLOCKER, and the record above
mis-states it. "Rows have their join; TYPE-scheme generality does not"
is true of the ITERATING design and only of it: a join reconciles a
RECOMPUTED value with a provisional one, and the probe passes recompute
from rollback-refreshed nodes, which is why "concreteness learned in
probe k evaporates in k+1". A live cell is monotonically REFINED, never
recomputed, so there is no second value and no join is required. The
tower compensates for the snapshot; the snapshot is the bug.
— THE WALL, MEASURED TWICE. Publishing the cell at the decl's own exit
(infer.mn's `env_extend(name, generalize(handle), …)` → `Live(handle)`)
compiles clean, census 0 — and the resulting m2 TRAPS compiling the
wheel: exit 134, OOM through
`chase_row_deep ⇄ chase_edges_deep → edge_content_into → tail_set_union
→ alloc_list_sc → alloc`. Cause, localized: `instantiate`'s Live arm is
`instantiate(generalize(h))`, so generalize's chase_deep — one fold per
DECL under Frozen publication — becomes one fold per USE. The flat-cell
law's WRITE half is real and in place (graph_bind_row stores
flatten_row_stored, depth-1 by invariant); it is the materializing READ
that has no compression.
— THE TYPE-SIDE HALF OF THE CURE IS BUILT AND MEASURED (parked, not
landed): subst_ty_build's TVar miss SHARES the edge instead of inlining
the bound cell's content, and subst_changes stops answering true for
every bound var. The old arm's own comment is the confession — "the
freeze exists so readers never read live" — Carried-Truth inverted and
stamped as a law; the inlining was never a fact about substitution, it
was a consequence of the RESULT being a snapshot that must not carry
live pointers. With that pair the trap MOVES but does not clear: still
chase_row_deep, now through map$spnEffNamenEffName. The row side folds
the same way and needs the same ruling.
— THE NEXT THING TO BUILD, forced by both traps: generalize must not
chase_deep AT ALL. Under live publication a decl's type IS its cell, so
the quantifier wants a free-var VISITOR over live cells — walking, never
building — and the deep chase deletes rather than being compressed. The
allocation is the BUILD (map over eff names, tail_set_union), not the
visit. Land order, both halves together or neither (the half-step law,
paid for twice more here): visitor-quantifier + publish-Live +
subst-shares-the-edge, judged by census 0, the movers line, and m3 == m4.
