# Mentl — PLAN.md

> **The three documents.** `CLAUDE.md` says how to work on Mentl. This file
> holds the design: the thesis, the kernel, the decisions already made, where
> the code still falls short of the design and, in §11, the one list of open
> work. `docs/SYNTAX.md` is the authority on how Mentl code is written. Each
> fact is written in one document, and the others point to it. CLAUDE.md is
> read whole. This file and SYNTAX are read in parts, through the map that
> `mentl map` builds from their headings. History is `git log`, and the chain
> of pins is in `boot/PROVENANCE.md`. The board's numbers come from the
> compiler's own commands (`mentl land`, `mentl verify`) and are never
> written in this file. When a landing is committed, the same commit deletes
> its §11 paragraph and brings §7 up to date.

---

## §0 · What Mentl IS — the thesis (the north star)

**Mentl closes the gap between what a person means and what they are forced to
write.** The bugs, the complexity and the frustration of programming come
from that gap. The first manifesto named it on 2026-03-15, and the goal has
stayed the same since. A programmer thinks *"this reads a file, parses it, and
might fail"*, and the language makes them write out async-ness, borrows, error
boxes and lifetimes. The language requires this ceremony to make up for what
its compiler could have worked out. Mentl does not close the gap by hiding the
complexity or by dropping the types. It closes it with better inference. The
medium records every fact it can prove (the types, the effects, the
ownership, the refinements, and the reason for each), and the author writes
only their decisions: what this code must never do, what bound a value keeps,
and what width a number needs. The aim is a tool that helps people think and
does not make them write more than they mean.

Mentl is designed as a **medium**, not as a programming language with a list
of good features: a developer working in it should see their program and not
have to think about the language. At any position in the code, the medium
says what is true there and why. At a hole, it proposes the next edit it can
prove. When two proven edits mean different things, it asks the one question
that tells them apart instead of picking one. Learning Mentl also teaches
programming. The programs are the means, and the aim is to make the person a
better developer.

Closing the gap means reaching five properties:

1. **Proof beats review**: the medium either proves what you claim or refuses
   it, and nothing unproven runs. So whether a program does what its author
   meant never depends on someone reading it closely. Review can give
   assurance only up to some limit, and proof has no such limit.
2. **The negative is provable**: people often mean "this never touches the
   network" or "this never allocates", and no mainstream language lets them
   say it. `!E` says it, and it holds under polymorphism. The absence it
   proves takes the identity of each handler and install into account, holds
   under modality and over time, and is proven per instance
   (`!Sample(44100)`). This is the most underrated part of Mentl.
3. **Intent is lossless**: the Reason chain records why every fact holds, and
   it can be followed back to the decision that produced the fact. Nothing the
   author meant is lost between the source text and the machine code.
4. **Computation is durable**: a running computation is a value. It is a
   multi-shot continuation, and it is saved by copying the memory image.
5. **Systems explain themselves**: at any point in the code, the cursor shows
   what is currently true there, so the medium answers the question and the
   author does not have to work the answer out.

**What follows, but is never the goal.** A medium that proves what it runs
and never loses intent does both for every author. Code that a person did not
write (a teammate's, a dependency's, a plugin's, a model's) goes through the
same proofs and the same refusals. So trustworthy machine-generated code is a
consequence of building the ultimate language for people. It is never a goal
beside that one, and never the headline (Morgan, 2026-10-09). The same design
choices keep coming out of three separate questions: what makes Mentl
*ultimate*, what *people* need, and what is best for *the makers*. The
Carried-Truth Law applies at three scales. Mentl's kernel never substitutes a
made-up or recomputed value for a fact it can read live. Software must never
act on an intent its author did not state. Claude must report the reasoning
it actually has, and never claim more confidence than that reasoning
supports.

**Origin and purpose.** Everything in the design is generated from the
kernel: one graph, two operations, and `!Outside`. The purpose of the design
is the person. When proof conflicts with convenience, proof wins, because a
proof serves the developer better than a convenient but false answer. Every
description of Mentl starts from the developer at the keyboard. A sentence
that leads with machines has turned the thesis upside down, and
`tools/doc-truth.sh` checks every document a reader meets first against §0's
first sentence.

**The scope of `!Outside`** (§1) is **toolchain reflexivity**: every means of
improving the medium is already inside it. It does not cover the **intent
space**, because specifications start in a person's head. Nor does it cover
the **capability space**: by Rice's theorem the checker can only be sound and
incomplete, and it records what it cannot decide as explicit `V_Pending`
debt. One named piece is still outside: the correctness oracle, which becomes
internal as §11.2's evaluator. An external solver does not count as outside.
Verify's search is the medium's own (§11.8), and a solver outside the medium
is only a proposer whose certificate the kernel checks, just as it checks a
model working behind `Synth`.

`!Outside` is not a runtime effect like `Alloc`, `Thread`, or `Flow`. It is
the verdict on whether the existing medium is closed: if improving Mentl
still requires a tool, server, verifier, proposer, transport, memory model,
or build step outside Mentl, that gap is still open. Closing it means moving
that piece into the graph, the rows, `~>` handlers, `TCont` worlds, `mentl
space` or image columns, and never adding a separate feature named Outside.

---

## §1 · The fixed point — `!Outside`

A tool can be surpassed when the means of improving it lie *outside* it: to
beat X, you write Y. The ultimate medium has nothing outside it. The compiler
is a handler on its own graph (it is self-hosting). The IDE is a projection.
The proof system is the kernel. The oracle is incremental computation plus one
cached value. Even *designing* the medium is a `<~` loop that feeds back into
its documents.

- **Unsurpassability is `!Outside`**: the medium's own negation primitive,
  applied to the toolchain as a whole. Just as `!E` proves that a capability
  is absent, the fixed point proves that nothing outside is needed.
- **Closed over proposers**: any proposer (a script, a library's tool, a
  model) plugs in as a `Synth` handler. Each candidate it offers must pass
  version, infer, Verify and restore before the person at the keyboard sees
  it. A stronger proposer makes the medium stronger and can never surpass it.
  The person and the medium exchange **constraints**, which lose nothing,
  only accumulate and build on each other, rather than tokens, which lose
  information and fade. Proof is a monotone filter: it only removes
  candidates and never generates them. The person's intent, or a ranker
  placed after the proof check, chooses among the candidates that pass.
- **The medium is the best next-move proposer.** At the cursor, it proposes by
  a guided search over the typed graph (rows, Reasons, refinements, ownership,
  proximity), and proof prunes the search at every step. That structure gives
  the search more to work from than a window of tokens does. When surviving
  candidates tie, the medium shows the one missing constraint that would
  separate them (the teaching tie-break) instead of picking one.
- **The closed loop** (Morgan, 2026-07-28): the loop is the person and the
  medium, and nothing else is needed at any scope. It has three parts. The
  medium proposes the best next move (guided search, extraction-optimal per
  §5). Asking a question is better than choosing arbitrarily: the teaching
  tie-break turns the cases the constraints leave open into proven next moves.
  And the loop is fast enough to work in: the fused oracle makes each cycle
  feel instant. The `Synth` port stays open to any proposer by construction,
  and the target is that nothing ever needs to come through it.
- **Validated from six directions.** Each of six existing systems has one of
  Mentl's parts and lacks another. Faust has verbs but no effects. JAX has
  handlers but no graph. Temporal has continuations but no types. Rust has
  ownership but no effect row. Effect-TS has effects, on a host language
  without native support for them. Solid has feedback but no proof. Mentl
  combines these parts in one system, which none of the six does.
- **Also validated by what existing tools cannot do** (surveyed 2026-09-21).
  *The soundiness ceiling:* tools that analyze a whole codebase rely on call
  graphs recovered by parsing, and that recovery loses information. Static
  call graphs on real Java had a median recall of 0.884 against a dynamic
  oracle (Sui et al., ICSE 2020). Thirteen static tools missed 61% of the
  methods that actually ran, across 1,000 Android apps (ISSTA 2024). The field
  calls this accepted gap "soundiness". In Mentl, inference draws every edge,
  and `!Outside` leaves no dynamic escape hatch for an analysis to miss. That
  is a different foundation, not a better algorithm. *The decidability line:*
  Google's Capslock answers "what can this Go dependency do?". It reduces
  reflection, cgo and `os/exec` to `ARBITRARY_EXECUTION`, and it never reports
  a capability as absent, because it cannot prove absence. WASI's component
  model types capabilities as declared, at the host boundary, for a whole
  module. `!E` proves absence under polymorphism, transitively and per
  instance, which neither of them can do.

---

## §2 · The kernel — one graph, two operations, eight arms

> **The kernel is one graph and two operations: drawing an edge (a write) and
> projecting (a read). There is no third operation.** The universal audit asks
> of every fact: *is it computed, copied, snapshotted, or re-derived anywhere
> it could be read live? If so, that is the bug.* The fix always leads to less
> code.
>
> **A verb draws an edge.** `~> h` connects the install to the node of handler
> `h`, `|>` connects one stage to the next, and `<~` closes a cycle. The
> standard re-derivation bug is reading what an edge already connects by name
> (through a ledger, an index, or a second environment lookup) instead of
> following the edge. Follow the edge and read the live node. Look a name up
> once: at the writer, in the scope where it resolves, or at the text boundary
> where a person typed it.

At bottom, the kernel is not eight things. It is the **graph** (nodes carry
values; typed edges carry types, effects, ownership, refinement and Reasons)
and two operations. **Write** is inference: the one writer, which justifies
every edge with a Reason. **Read** is the cursor projecting the graph at a
position. The graph is the program, and the source, WAT, docs, the IDE and
error messages are projections of it.

The kernel's eight arms are aspects of one mechanism, not eight mechanisms.
The eight primitives are the **eight aspects of every cursor read**, also
called the eight interrogations and the eight tentacles. Three of them
(ownership, refinement and gradient) are built from the others: ownership is
an effect, the gradient is derived, and refinement is `Verify` plus a
predicate. That gives fewer axioms with the same reach.

Every subsystem is the same cursor read in a different mode, and there is no
second mechanism:

| Subsystem | = cursor-read mode |
|---|---|
| compile order | sequential cursor |
| incrementality | cached cursor |
| multi-shot exploration / durable execution | forked cursor |
| truth / the Why engine | reasoned cursor (a Reason edge per read) |
| proof | verified cursor (`~> verify`) |
| multithreading | parallel cursor (Thread handler) |
| infer / lower / emit / native / GPU | projected cursor ("the handler IS the backend") |
| the felt surface / propose / reactivity | proposing cursor (gradient at `??`) |

Five mechanisms implement the table in code: the face, the reach, the fork,
the whole-truth row and two projections (§4⑧). A subsystem is built as a
reader of them, never as a sixth mechanism beside them.

The three deepest capabilities are the three **axes** of the one read, and
every primitive is checked against them. This is the generative audit, which
runs alongside the reductive one:
- **Memory is the substrate.** One flat linear-memory image. Every node and
  value is a record addressed by a handle, and arenas reclaim extents. The
  **unified heap record** gives a handler, its state, a closure, evidence and
  a continuation one shape. So a continuation is a contiguous record, and
  durable execution follows directly from the memory model
  (`persist = memcpy`).
- **Multi-shot is time.** It covers the fork (a version of the graph, taken
  in O(1)), the cache (the cursor memoizes live reads: "read live" is the
  meaning, and "cached" is how it is done) and persist (a continuation
  written to disk). Search, the cached cursor and durable execution are one
  primitive, told apart by which handler catches the resume (§4④).
- **Threading is space.** Parallel cursors read the shared image and fork
  into per-thread versions. Compiling, the IDE, the prover and the oracle's
  search all read the same graph at many positions.

Projecting the cursor through substrate, time and space gives the subsystem
table above. The oracle combines all three: N forked cursors on N threads
over one shared graph, each fork with a version of its own. The version, the
threads and continuation reification are built, and combining them is §11.8.

**The eight arms** are the eight questions to answer at the cursor before
writing a line: **Graph?** (handle, edge, Reason) · **Handler?** (which
handler projects this, with what resume cardinality) · **Verb?**
(`\|> <\| >< ~> <~`) · **Row?** (`+ - & ! Pure`) · **Ownership?**
(`own`/`ref`, `Consume`/`!Alloc`/`!Mutate`) · **Refinement?** (predicate,
`Verify`) · **Gradient?** (an annotation, given as input, that unlocks a
capability) · **Reason?** (the edge the Why engine follows).

---

## §3 · The bottom-up construction — every layer a mode of the one read

Each layer's shape is fixed by the layer below it, so a foundation that is
not in its ultimate form damages every layer above it.

- **L0 · The graph.** Nodes and typed edges, kept live. Every fact is a
  column keyed by the handle itself (a four-level trie, so a lookup is an
  O(1) chase), and the graph is a value. A version is taken in O(1) by
  remembering the column roots. A fork is an instance of the graph handler
  seeded with a version: its own columns hold what it writes, and a read
  falls through to the versions below. A speculation keeps the fork by
  merging its cells into the instance below, or drops it along with its
  extent. *Only inference writes.*
- **L1 · The value ontology.** There are **five node-kinds**: *word*,
  *sequence*, *product* (a record; a tuple is a positional product), *sum*,
  and *function* (a closure with evidence). Everything else is a **view**
  (§4①).
- **L2 · Topology and cost.** The five verbs draw the shape of the program,
  and the Boolean effect row says what crossing an edge requires or forbids
  (§4②, §4③).
- **L3 · The dynamics.** Handlers with typed resume are the one mechanism.
  They are graph content themselves: installed with `~>`, typed by inference,
  and projected to a backend. Multi-shot is the substrate under all of it
  (§4④).
- **L4 · The write.** HM inference in one walk, which continues past an error
  and records a Reason for every binding. Ownership, the effect row and
  refinements are all inferred. Annotations an author writes are
  constraints, verified against what was inferred (§4⑤).
- **L5 · The surface.** The minimal text that makes each aspect of the
  kernel reachable; `SYNTAX.md` covers it. Annotations are inputs to the
  cursor, never the emergent property itself.
- **L6 · The felt experience.** The cursor acts as the gradient's argmax.
  The Why walk, `mentl where`, the verification dashboard and fine-grained
  reactivity are all the graph projected for a person. This layer has equal
  standing with the others and is never an afterthought (§4⑦).
- **L7 · The closure.** `!Outside` and self-hosting. The fixed point is the
  medium reproducing itself exactly, `m_n.wat == m_{n+1}.wat`, checked
  together with correctness: a buggy compiler can reproduce itself and reach
  a *wrong* fixed point, so the micros and the frontier are the other half of
  the check. §6 describes how it works.

---

## §4 · The resolved decisions — the kernel, not questions

*Decided 2026-06-18. They can still be questioned, and whoever challenges one
has to prove the case.*

**① Value ontology: five node-kinds, and everything else derived.** `Bool` is
`False | True` (a derived ADT). `Int`/`Float` is a *word* plus the
representation gradient. `String` is a *sequence of byte* plus a text and
interpolation view. There is one sequence concatenation, and the read picks
the representation ("the proof becomes the dispatch").

**② The verbs: five, confirmed from outside by Faust.** Faust has four of
them: split `<:` ≡ `<|`, recursive `~` ≡ `<~`, sequential `:` ≡ `|>`, and
parallel `,` ≡ `><`. Faust's merge becomes `|> merge_fn`. `~>` is the one
Faust lacks, so Mentl is Faust's topology plus handlers.

**③ The crown: rows with negation. The modal form is the target, and the
graph is the way to reach it.** Never give up `!E`. The modal synthesis (the
line of work by Tang and Lindley, POPL 2026, arXiv 2507.10301, which proves
rows equivalent to capabilities) is the target for the unsurpassable tier.
What it still leaves open is the negation half. Rows are represented as
`EfRow(present, absent, tail)` with `EffTail = EtClosed | EtVar | EtAll`, and
negation is the absent field. The crown battery (`tests/crown/`,
`bash tools/crown-gate.sh`) is the soundness gate. The time axis is
`TCont(R, S, ResumeDiscipline, EffRow)`: the continuation carries its effect
world, unified as a row, and a mismatch in resume discipline is refused
(`E_ResumeWorldMismatch`). The modality is inferred and shown at the cursor,
never written by an author.

**④ Multi-shot is one substrate for five things.** Search (the oracle),
sampling, backtracking *and durable execution* are one primitive: a resumable
continuation. They differ only in which handler catches the resume, so making
a computation persistent means swapping one handler for another.

**⑤ Ownership: `own`/`ref` are inferred, and must stay as unobtrusive as in
Hylo.** Ownership is an inferred effect: `own` performs `Consume`, `ref` is a
row constraint, and both are filled in from the use count. If the developer
has to think about ownership, the inference has failed.

**⑥ Information flow is the influence walk, not a row element** (decided
2026-10-02, built 2026-10-16). `!E` with `~>` already covers capability
security. Flow adds which value may reach a sink, and the graph already
records that relation. A refinement is read along a value's flow edges, a
handler's state is every value written into it, memory holds what was stored
there, and the parent edge gives control dependence. So a label is an op
named in a refinement over `self`
(`type Untrusted = String where untrusted(self)`). A source states the label
in its declared type (`-> Untrusted`). A sink requires the label's absence on
a parameter (`exec(cmd: Trusted)`). A leak is refused with
`E_RefinementRejected` at the sink's claim, naming where the label entered.
Endorsement is a function whose declared return type states the absence. An
implicit flow is whatever decides whether the code that reaches the sink
runs: a branch, a call made under a condition, or an abandon. Each declared
function's reading is a summary over its own parameters, read once per
settle. A `Flow(Src, Sink)` row element beside it would store the same fact
in a second place. The proof says where output may go, never what a model
does inside its context window.

**⑦ The felt experience has equal standing, and reactivity is the cursor's
`<~`.** When the graph changes, the cursor projects again at the boundary
with the person, and that re-projection is fine-grained reactivity,
incremental compilation and collaboration.

**⑧ Five mechanisms carry the one read into every subsystem** (decided
2026-10-23). Every open item needs the same five mechanisms, so each one is
built once and the items become its readers (§11 orders them by dependency):

- **The face.** Every declaration publishes one summary where its judgment
  ends: its scheme as edges, its row with each effect at the install that
  answers it, its contract (preconditions stated and learned, and
  postconditions), its store claim, its flow summary, its resume grades and
  its latency. Every caller reads the face instead of deriving it again.
  Re-judging after an edit stops wherever a face comes out equal. A module's
  interface is its exports' faces. Compatibility between versions is computed
  by comparing faces. A library ships with its faces already judged.
- **The reach.** One walk over the edges inference drew, `reach(from, edge
  kinds, stop)`: absence (`!E`), import capabilities, the Severance Map, the
  effect-enters chain, the race rule, the edit cone, `refs of`, `unreachable`
  and the schedule's demand are all questions it answers. Its answers are
  exact because the one writer drew every edge, so one function removes §1's
  soundiness ceiling.
- **The fork.** One speculative primitive on every core: take a version in
  O(1), run an instance over it, then keep or drop it. The ??-fan (the
  candidates offered at a hole), a diagnostic's fixes, accept, tighten,
  teach, the solver's case splits, the judgment's rounds, undo and time
  travel all use it. **A refusal is a hole**: where the program lacks a
  proof, the medium forks candidate edits, judges them, and shows the proven
  ones or asks the one question that separates them.
- **The whole-truth row.** Every way a computation can stop or reach outside
  itself is a row fact that the crown can negate: a trap, a failure,
  divergence, allocation and running out of memory, a store into older
  memory, a host resource, a secret. A recursion deeper than its stack moves
  the rest of its work to the heap, so depth costs `Alloc` and never causes
  an unreported trap.
- **Two projections.** Lowering is a column on the program's own handles, and
  every backend is a handler over it: the WAT emit, the native emit, and an
  evaluator that gives the graph's reference meaning. The evaluator is the
  correctness oracle, the second path of diverse double compilation, the
  runtime witness of every static `!E`, and the instant run in the page. The
  value walk and the derivative reading are its abstract and tangent
  instances.

---

## §5 · real · felt · unsurpassable — three aspects of one ultimate form

These three are not stages done one after another. They are three aspects of
the one form, and each is written out in full. The `.mn` code is judged by one
question only: what is the ultimate form?

1. **REAL — it works.** Compilation works end to end, the test battery
   passes, and the wheel emits correct WAT at its own fixed point.
2. **FELT — the human surface (L6).** `mentl where`, `mentl why`, the eight
   aspects at the caret, the gradient and reactivity. These are projections of
   the graph, never add-ons.
3. **UNSURPASSABLE — the frontier.** Modal effect synthesis (§4③), durable
   execution as a handler (§4④), Verify's own solver, native and GPU backends,
   and the e-graph. Each one is built *within* the medium.

**The felt endpoint.** A `??` is a typed constraint. The cursor forks a finite
set of candidates within a latency budget and runs each one through version,
infer, Verify and restore against its own version. Only the proven survivors
are shown. The ranker reads local intent (Reason chains, proximity, in-scope
vocabulary), and the tie-break teaches. Verify either decides a claim within
its decidable fragment or records explicit `V_Pending` debt. It never
silently assumes a claim is true.

**The optimality half** (Morgan, 2026-07-28): a proposal is optimal by
extraction. Each survivor is an equality class that the e-graph saturates
under effect-aware rewrites. Extraction picks the member with the lowest cost,
and the representation gradient fixes the widths. The aim is that
superoptimization is the default whenever an author writes code.

**The fork/merge duality.** The space of meanings is explored by forking:
candidates conflict, so each needs isolation. The space of forms is explored
by merging: the members of an e-graph class mean the same thing, so
saturation needs no isolation. Proof filters meanings, and cost orders forms.
When two forms tie, either one can be picked at no cost. When two meanings
tie, the medium has to ask the person. This is where the person cannot be
replaced, and it follows from the design rather than being assumed. Proving
first and extracting second is the only sound order. The effect row serves
both halves: it decides which rewrites are legal and which candidates are.

### §5.U · The value layer — one record read at four altitudes

A handler, its state, a closure, evidence, a continuation, a branch thunk, a
fold target and a representation host are all one contiguous record. The
record is addressed by a handle and read by one emit-time read,
`match lookup_ty(h)`.

- **Representation gradient**: `repr_of(Ty) -> Repr` (`RI32 | RI64 | RF64 |
  RF32 | RV128`, with widths chosen by a match). i32 is the smallest width;
  the gradient infers the rest, and a `repr` pin is an input, never a
  requirement. A record pointer stays one word, so the record can still be
  serialized with memcpy.
- **Multi-shot continuation**: the same record, frozen at a resume site. A
  tail resume returns. A held or multi-shot resume reifies the remainder.
  Persisting is a copy of the image.
- **Parallel topology**: the same record, forked as N branch thunks. The verb
  states only the topology, and a `~> Schedule` handler picks
  `Seq | Thread | Simd | Gpu`.
- **Structural fold**: `==`, compare, hash and show are folds over the five
  node-kinds. Equality is defined all the way down, sums included.
- **The keystone**, `TCont(R, S, ResumeDiscipline, EffRow)`, carries the
  effect world on the continuation, so `!E` also holds over time. A
  continuation resumed under a changed set of handlers is refused instead of
  running in a corrupted state.

### §5.O · The cost law — performance IS the Carried-Truth Law

**The cost of an operation is the size of the answer it was asked for, and
nothing else.** There are two costs, and they must never be confused.
*Derivation*, computing a fact, is O(1) amortized: a fact is computed once and
only read after that. Deriving it again in a later run breaks the rule just as
deriving it again at another call site does, and the image is what lets a
fact outlive a run. *Delivery*, handing over a value, costs O(what was asked
for), and it is the only cost that cannot be removed. The test is
falsifiable, and it is a gate: change nothing, compile again, and measure. A
compiler that works out its own earlier conclusions again should not be
called incremental.

Measure the hot path, and never trust an estimate made by reading code. Eight
readers missed the largest cost in the 2026-07-13 self-compile: the
resume-cardinality classifier, 98% of a sample under host `perf`. Profiling
the fixed compiler then took the self-compile from 1,400 s to 10 s. Running
`wasm-opt -O2` gave a measured 4% regression, because the cost is in the
algorithms, never in wasteful instructions. A change justified by a number
and by no rule is the wrong change.

Cost is on the board. The march's m3 leg ratchets its peak RSS. It also
compares the image's own high-water mark and its wall time with the pinned
boot compiling the same wheel in the same march, so each ratchet measures the
compiler, never the wheel's size or the machine's load. A ceiling never
rises, and a landing whose cost goes over one must bring the cost back down.
The work is built in this order, each layer making the next one O(1): (1) a
name is a handle from the lexer on; (2) every read is an O(1) chase: the
environment, the reach walks (§11.1), and instantiation shared instead of
cloned (§11.3); (3) the arena: every extent reclaims at its exit whatever its
published result does not reach (built); (4) parallel cursors on
deterministic `{arena, offset}` handles (§11.8).

---

## §6 · The bootstrap — the boot is the compiler

`boot/mentl.wasm` is the compiler: the pinned wheel at its fixed point, with
its chain of pins in `boot/PROVENANCE.md`. The throwaway seed that first
built it was deleted on 2026-07-10 (7401c4b), and the recipe for
bootstrapping from scratch is kept at tag `first-light`.

- **The fixed point.** `bash tools/march.sh` compiles the wheel with the boot
  to get m2, compiles the wheel with m2 to get m3, and checks that m2 == m3.
  If they differ, it builds m4 itself. If m3 == m4, the verdict is
  TRANSITION: the wheel's own output changed, and the pin is taken from m3.
  Anything else is BROKEN. `MARCH_REPIN=1` pins. Every pin pairs the fixed
  point with correctness: the micro battery, the frontier and the crown.
- **The substrate.** One WASM linear memory, allocated by a bump line in
  which every extent runs in an arena. A landing names its extents instead of
  inheriting a heap that only grows. Strings are `[len][bytes]`, with the
  `[−1][buf][start][len]` view. Lists are tagged flat, snoc, concat or slice.
  The boot imports only WASI preview1 and defines its own memory, so any
  preview1 engine can host it. The gates use the stock wasmtime release,
  pinned by version and digest (`bash tools/wasmtime-get.sh`). `mentl asm`
  assembles the wheel's own output.
- **Handler elimination** ("the proof becomes the dispatch": what is proven
  about a handler decides how it is called). A tail-resumptive handler
  becomes a direct call. A static singleton becomes a direct call with the
  record taken from the live world chain. A polymorphic handler becomes
  `call_indirect` through the record (evidence passing, never a vtable). A
  held or multi-shot handler becomes a heap continuation record. A handler,
  its state and a closure are one record, `[fn_ptr][nstate][state…][arms]`,
  and dispatch reads the install chain.

**The wheel's modules** (`src/`): `graph` (the graph: the versioned columns,
union-find, the forking handlers) · `types` (the metaschema: `Ty`, `Reason`,
`NodeBody`, `DiagKind`, the compiler's effects) · `effects` (the row algebra)
· `lexer`, `parser` (the text boundary) · `infer` (the judgment, the one
writer) · `env` (the scope) · `intern` · `own` (ownership grades) · `verify`
(refinements, the value walk, obligations) · `egraph` · `derive` (derivative
readings) · `lower`, `backends/wasm` (the projection to WAT) · `asm` (WAT to
bytes) · `driver` (the module DAG and layers) · `pipeline` (handler stacks,
diagnostics) · `format` · `query`, `cursor`, `cursor_transport`, `space`,
`mentl` (the reads: the facets, the eight aspects, the View, the gradient) ·
`synth_proposer` (the ??-fan) · `rename` (a rename, one write at a
declaration) · `board` (the standing bounds) · `sections` (the map that reads
the documents by part) · `cli`, `main` (the verbs) · `lsp`, `mcp`
(transports) · `canon`. The runtime library is `lib/`, which never imports
the compiler (§7).

---

## §7 · What the artifact has not reached

§4 and §5 describe the target in the present tense. This section describes
the current state, and where the two disagree, this section is correct. Each
item points to the §11 landing that closes it. A gate that did not run counts
as unknown, never as passing.

- **`!Trap` is false under deep recursion** (§11.2): running out of stack is
  a trap that no row shows, so a `!Trap` recursion that a person writes a
  million calls deep passes the check and then traps with "call stack
  exhausted".
- **False proofs are found only when someone thinks to write a probe**
  (§11.2, the witness).
- **The program is the graph, and its one-write operations are not all built.**
  A node is its handle (`type Node = Int`), and a body holds its children as
  handles. Everything the judgment learns about a node is a column at that
  handle. The program itself is a node, the link. Its members are its module
  nodes, each holding the text its judgment read and its imports as edges,
  and every reader starts from the link: the compile, the session, the
  address and the battery. A value reference is linked to the declaration it
  resolved to. A pattern is a node the judgment binds, and its constructor is
  linked the same way. A sub-pattern, including a rest, is the cell of the
  part it takes apart. Every binder a pattern writes, including a let's and a
  match arm's, is declared where it is written, so the caret at a binder
  lists its uses. A parameter is a node of its own, the cell of the argument
  at its position. So a destructured parameter is its pattern, and its names
  are declared where they are written, each once per head. A handler arm's
  arguments are parameters by the same rule. A state field's name is the
  binder of its init, linked from every `resume … with` that writes it. A
  name written in a type is a node linked to the type it names. So are an
  effect named in a declaration's row or a function type's row, the op a
  handler arm serves, and a sugar that calls a primitive (`xs[i]`, `++`, an
  interpolation's seams, a list rest), so `refs of` reaches every one of
  them. A type, a Reason and the lowered program are still value trees
  (§11.2, §11.3), so a name written inside a type is rendered from the type's
  value. Three one-write operations are built. Installing a named handler
  chain installs each of its members (SYNTAX §«Handler chains»). A rename is
  one write at the declaration (`mentl rename`): every reference, label and
  comment mention is rendered through its edge, and a rename that would move
  an edge, or that reaches a name inside a type, is refused. An edit is
  judged at the grain it was made: the statements it rewrote or moved are
  read again from their own lines into the module's node, the declarations
  whose judgment read them are judged again with them, and every other
  statement keeps its nodes and its judgment. Accepting a proposal is not yet
  a one-write operation (§11.5).
- **Names are still read where an edge exists** (§11.2, §11.3, §11.4). The
  lowered program is identified by its symbol, so the emit's reach walks key
  their units by the symbol. An arm's resume grade is settled before the
  judgment draws any edge, so it reads the functions its body declares, and
  the parameters a callee calls at its tail, by their spelling. The emit cuts
  a list rest by the slice's spelling, because its lowered pattern holds no
  handle. An emitted arm's kind holds its op's spelling, and the performs that
  the lowering writes for a schedule (`spawn`, `thread_join`,
  `persist_branch`, `join_persist`) name their ops by spelling, in the
  compiler's own vocabulary.
- **A module sees its whole import closure** (§11.4). Everything in the
  closure is visible, so a user cannot declare a name the prelude declares,
  sharing one namespace costs long name prefixes, and the compiler recognizes
  library effects by their spelling. The layering half is done: a library
  never imports the compiler, and a user program cannot.
- **A dropped value goes unreported** outside the stage of `each` (§11.5).
- **Early exit cannot be written, and every cycle is recursion written by
  hand** (§11.7): `any`, `all`, `find` and `take` visit every element.
- **Teach proposes locks, preconditions and lifts, and little else** (§11.5).
  It proposes no refinement at a part, no call with argument holes, and no
  record for a positional product. A proposed precondition says which row it
  frees of `Trap`. A lift removes a written base type that the body alone
  decides. It is proven by the fork alone: the declaration is read again
  from its lines without the annotation, since the cells hold the written
  type whichever side decided it. The course's declaration heads are lifted;
  the wheel's are not.
- **The course and the scores do not yet check clean** (`mentl verify`, the
  `QOwed` bounds; §11.3). A Nyquist bound that reads the installed rate inside
  its predicate is left pending (lesson 6). A division by a value that nothing
  bounds charges `Trap` (lesson 7, Pulse). A frequency computed from a sine or
  a product is a claim the interval fragment cannot decide yet (Pulse,
  Wasatch). The page cannot play a lesson yet (§11.6).
- **Some effect names do not match what their ops do** (§11.1): GraphRead
  holds writes, GraphWrite holds reads, and `Memory` holds pure word
  arithmetic, so a function that only does arithmetic on words is not `Pure`.
- **Effect-op parameters have no names** (§11.5): an op's declaration types
  its parameters by position, `fs_read_file(String) -> String`, so each
  handler arm names them itself, and no two arms have to agree.
- **A module's init can only store what one binder names** (§11.2): a
  module-scope let whose pattern is a discard, a literal or a destructure is
  refused when the program is emitted (`E_InternalInvariant`).
- **Regions exist at runtime**: every extent runs in an arena (each module's
  parse, binding groups, declaration lowerings and the reach walk, emitted
  units, session answers, speculations, and the runs of spawned instances),
  and ownership's regions stay compile-time facts.
- **`persist = memcpy` is built**: `lib/persist.mn` writes the image,
  `image_resume` checks the build key, and `mentl resume <image>` re-enters
  the image. Host resources (descriptors, sockets) are not restored. Resuming
  on another machine, and a session that outlives its process, are still
  open (§11.6).
- **A continuation answers to the world it is resumed in, and a row names
  effects, not installs.** A continuation carries its own segment of the
  world it was captured in, and past that segment it reaches the installs
  around the place where it is resumed. Each install's remainder is an
  instance of its handler's world cell, which a negation and the root judge
  wherever the program states them. A row says which effects a computation
  performs, each at the instance it performs, and never which install answers
  one. An install answers the instance it serves, so to a negation two
  installs of one instance are one fact, and absence is proven per instance,
  not per install (the modal crown, §11.1).
- **Threads are real**: `~> parallel_compose` runs branches on host threads
  over the shared image, and a branch runs in the world it was spawned in.
  `E_ThreadedBranchEffect` refuses a stateful handler that a branch reaches, a
  store that a branch makes into memory older than itself, and code reached
  by a branch that writes memory older than its own frame. SIMD and GPU run
  their branches one after another. A function value's writes are read
  through its claim, written where its judgment ends. The claim places its
  parameters by the arguments a call passes, a capture by the binder's age in
  the frame that holds the value, its own feedback line by the value's age,
  and the functions it applies by what the callee passes them. So a call
  through the value pays `Mutate` only where the memory it reaches is older
  than the caller's frame. A call's answer read off a tee (a fold's
  accumulator, a handler's answer) is memory the store-age walk cannot place,
  so a function threading a table through a fold's result owes `Mutate` it
  could prove (§11.3). A wide answer does not cross a thread's join:
  `parallel_compose`'s arms are emitted once, at the word face, so a branch
  that answers a Float traps where its join is read at the site's face
  (§11.2).
- **The judgment is one pass; schemes are still values** (§11.3): a candidate
  is judged against a version of the one live graph, and a declaration's type
  is frozen when its judgment exits.
- **Incrementality is not a cached cursor** (§11.6). The delta between two
  versions of the graph costs only what changed (`graph_written_since` reads
  it for the tie-break), but nothing projects again from that delta. An
  edit's cone has no cutoff. Every declaration whose judgment read a
  rewritten one is judged again, transitively, whether or not what the
  rewritten one publishes changed. So an edit to `chain_spelling`, which a
  third of the wheel's functions read transitively, judges 1,767
  declarations, about what a cold judgment costs, while an edit to a leaf
  judges seventeen. Every edit's judgment also stays in the image. The warm
  start restores an image and judges the edit's cone over it.
- **The resident Space keeps its graph for a session's life.** A session
  derives the graph once each time it opens, and a new process derives it
  from scratch (§11.6).
- **Speculation is a choice, and a fork is an instance, one speculation at a
  time.** Every judgment that the medium tries and may undo performs `choose`
  (lib/choice.mn). The forking handlers run each resumption under the
  judgment's chain, over a graph handler instance of its own, seeded with
  the version of the instance below (`graph_version`: the column roots, the
  mint, the span log, O(1)). Beside it run instances of the row gate, the
  mint, the ledgers, the store ages and the frame stack, seeded from the
  instances below, plus an env view over the entries below, a diagnostic
  collector, and a view of the intern table as the fork found it (`forked`).
  An option's writes land in its own columns, and a read falls through to the
  versions below. So the handler that judges every option drops each instance
  along with its arena (`speculate`). The handler that keeps the first held
  round merges its cells into the instance below (`graph_keep`) and adopts
  its ledger facts, its frame stack and its store ages (`branch_join`). The
  ??-fan's candidates, teach's locks and contracts, and the Mycroft rounds of
  every unsigned declaration's judgment all fork this way. A candidate's
  teaching is read inside its instance, as the cells that instance wrote. A
  fork adds no word to the intern table: the table is written at the text
  boundary and starts out holding the medium's own vocabulary, and a word
  first seen inside a fork is refused by name. The options run one after
  another, never two at once; running forks on threads is the one pin the
  fused oracle still needs (§11.8). A continuation can be captured at any
  position, by copying its frame's lowered tail (§11.2).
- **The compile is sequential by construction** (§11.8).
- **Each mechanism is built more than once** (§11.1, §11.2, §11.3). Every
  interprocedural fact keeps a ledger of its own (a scheme, a store claim, a
  flow summary, a learned precondition, a resume grade), and some ledgers are
  keyed by spelling. So no single comparison says whether what a declaration
  publishes has changed. Absence, the effect-enters chain, the race rule, the
  schedule's demand, the edit cone, `refs of` and `unreachable` each walk the
  drawn edges in their own way. The graph has one projection, the WAT emit;
  the value walk and the derivative reading are evaluators of their own, and
  there is no reference meaning to check the emit against.
- **Code in a comment is not judged, and the wheel's comments break SYNTAX's
  rules for comments** (§11.5, §11.4, §11.1). SYNTAX says the code in a
  comment compiles, and it does not. A fenced block holding `fn broken( = = 3`
  passes the check, and a `mentl rename` of a function the block calls leaves
  the block calling a name that no longer exists (measured 2026-10-23). So an
  example in a comment goes out of date without anyone noticing. A backticked
  name is an edge that a rename follows, but an `Hβ.*` label is plain text,
  and most labels in the wheel's comments name no §11 paragraph. The
  documents carry no such label, which `tools/doc-truth.sh` checks, but
  nothing checks the source. A comment can still silence a gate
  (`drift-audit: ignore`), which SYNTAX says a comment never does. Decoration
  banners group code in modules that have not been split along their
  clusters. Some ledes repeat another comment's text. Archaeology, lifecycle
  prose, commit hashes and coordinates are capped on the board, and none of
  those counts is falling. Nothing checks a claim made in prose:
  `row_subsumes`'s comment says a gate check only reads the graph, which
  `!GraphWrite` would prove, but cannot while GraphRead holds writes. Three
  smaller features are incomplete. An unresolved mention is reported across
  its comment's first line rather than at the backticked word. A
  declaration's Why does not walk its comment, although the Lede shows it.
  And fmt moves a trailing comment onto a line of its own even where it would
  fit beside its code.
- **Only a script checks the documents against the code, and only in part**
  (§11.5). `tools/doc-truth.sh` checks the pin, the verbs and scripts the
  documents name, their labels, every `§` they cite against the map, and the
  token enumeration's count. Nothing checks SYNTAX's precedence table against
  `binop_prec` and `pipe_prec`, although SYNTAX says the table is their
  literal integers. None of SYNTAX's fences is tagged or judged. A backticked
  name in a document resolves to nothing, so a rename leaves it out of date.
  SYNTAX also describes the present state beside the language's surface, in
  sentences that say "today" and "not yet", although this section is the
  authority on the state.

---

## §8 · Verification surface

```
mentl land [--quick | --board]      # the landing pass: this tree's compiler judged cheapest first, stopping at the first red — verify, march, frontier, proof-exactness, crown, effect identity, threads, ide — every verdict kept by the bytes it judged, pinned once; --quick = verify only; --board = the board on the pinned boot
mentl verify [path]                 # the standing bounds on the medium's own source (src/board.mn), read off one judged graph; a rise refuses
mentl check [path]                  # every module of the link judged, no emit; no path: the project
mentl query <entry> <question>      # refs of NAME · unreachable · unreferenced · census <shape> · ghosts · imports · performs · smt · text · prose · writes of · reads of · provider of · heads · env · reports · owed <dir>
mentl why <file> <fn> [<Effect>]    # the declaration's reason, then where each effect of its row enters
mentl where <file> <name>           # a declaration's head, row, widths and address
mentl <file>:<line>[:<col>]         # the eight aspects at the caret, with the Lede
mentl map [<id, title or word>]     # the read path by part: PLAN and SYNTAX by heading and §11 step; a name serves one
bash tools/march.sh                 # the fixed point: boot→m2→m3, m4 on a difference, TRANSITION or BROKEN; MARCH_REPIN=1 pins
bash tools/march-gate.sh --micros   # the rungs and the micro battery through the boot's m2
bash tools/frontier-gate.sh         # what no fixture contract names yet: the verbs' text, the authoring workflows, the project routes (--compiler fresh for the current wheel)
bash tools/crown-gate.sh            # leaks refuse, sounds accept
bash tools/proof-exactness-gate.sh  # a hole refuses, debt surfaces, a suspension runs
bash tools/ide-gate.sh              # the resident session: the node twin, then headless Chrome over the page
bash tools/verify.sh                # what no verb has absorbed: micros through the host, the sha chain, doc-truth
mentl test tests/proposals          # each fixture's first line is its contract at the hole
mentl test tests/teach              # each fixture's first line is its contract at the declaration
mentl test tests/frontier           # each fixture's first line is its contract: the exit it answers, the class it refuses, or what the hole proposes
source tools/wt-env.sh; wt_battery C.wasm tests/micros   # a battery compiled, run and judged by compiler C; `mentl test` judges and lists the RUN lines, the host runs them
mentl space                         # the page, localhost:7397
python3 tools/emit-diff.py A.wat B.wat [--trap]   # the divergence pinner — first on any m3 trap
bash tools/profile-self.sh          # the self-compile under the guest profiler; tools/guest-profile.py names callers
```

**Forensics.** On any m3 trap, diff the emitted modules first
(`tools/emit-diff.py`), then run `wasm-tools validate --features all` on the
module and `wasm-tools shrink` to get a minimal repro. Patch a probe into
`.build/probe/m2.wat` rather than the wheel's source, because editing the
source changes the rows and layout under test. A probe can be compared only
with output of the same binary. Read a value through its representation,
never at a raw offset. The guest profiler and host `perf` find the hot path;
`wasm-opt` does not fix it.

---

## §9 · The laws

1. **The Carried-Truth Law, at four scales.** Every bug is the same bug: the
   graph proved X, and some consumer re-derived X, discarded it, replaced it
   with a made-up value or cached it, instead of reading it live. Keep the
   handle and read live; the fix is less code. At the performance scale, an
   operation that costs more than a constant re-derives what an edge already
   connects (§5.O). At the surface scale, the text an author writes holds the
   developer's decisions, and the medium projects and maintains every fact
   the graph computes instead of a copy kept by hand. A positive row is
   inferred (the source keeps negations, pins and `Pure`), parameter names are
   a decision, layout is a projection, the import block is a decision the
   medium maintains, and the diagnostic catalog is projected from its
   constructors. At the collaboration scale, report the reasoning you
   actually have, and never claim more confidence than it supports.
2. **Don't patch — restructure.** If a fix fits in a patch, the architecture is
   wrong. A fallback that silently gives up (`_ => 0`, `_ => str_concat`) is
   deleted, never wrapped.
3. **Dream-code first, and the dream is invariant to the substrate.** Write the
   final form. When the substrate cannot express it, the substrate is
   incomplete, so complete it. "Reachable now", "realistic ultimate" and "a
   later follow-up" each mean the target has been lowered. Order the steps of
   the work, but never lower the target. Also run the generative audit (§2),
   so that each change finds a better ultimate form than the last one.
4. **Mentl solves Mentl.** Needing an outside framework means a primitive is
   missing.
5. **Build the wheel; never wrap the axle.** Build each capability into the
   compiler itself, never as a wrapper around it.
6. **Audit before the symptom; probe before the hypothesis.** Any work starts
   with the universal audit of the structures it touches. When a probe
   disproves your hypothesis, do not promote the next symptom to the cause. No
   edit, record or commit acts on a cause that running the code has not shown.
   When the cause has not been measured, the next thing to build is the tool
   that measures it.
7. **Prove a new path with a gate; never defer the ultimate form for it.**
8. **No bolts onto non-ultimate forms, and none onto condemned ones.** Do not
   improve a structure that a §11 landing deletes.
9. **Interrogate, don't absorb**: these documents are the current best answer,
   and so is the code beside them. That a structure exists is no evidence
   that it should, and often a comment exists only because of a defect in the
   code it describes.
10. **The artifact is the refuter; report, don't perform.** When you find
    that the artifact could be better, build the improvement; the build and
    the gates show a wrong form within seconds. A turn ends with what changed
    and the measured result, and any work not done is stated first.
11. **A gate is not trusted until it has been seen red; a carried-truth fix
    deletes.** A recorded expectation is a hypothesis about the time when it
    was recorded. When a correct fix turns old gates red, work out each
    expected result again by hand before recording it again.

**Bug classes that cost hours:** a `match … with _` hiding a type error ·
duplicate top-level names · flat-array ops in snoc paths · printing inside a
report arm, which corrupts the WAT on stdout · `acc ++ [x]` in a loop · a flag
stored as an int · a diagnostic whose name does not describe its error · a
stack pushed at one end and popped at the other · phantom captures ·
one-operand dispatch (a binop reading one operand's type) · a token walk that
consumes, without checking, sibling items that have no comma between them.

---

## §10 · How to resume

1. Read `CLAUDE.md` whole and the map the session starts with (`mentl map`),
   then PLAN §0, §11's first step and every part of PLAN and SYNTAX the step
   touches (`mentl map <id>`). That is the entire required context.
2. Run `mentl land --quick`. Where the code and the prose here disagree,
   trust the code and fix the prose.
3. Take §11's first item. Before any edit, ask the medium about every
   structure it touches (`mentl query`, `where`, `why`, `<file:line>`).
4. Build the landing whole, prove and pin it with `mentl land`, commit on
   main, push, and delete the item's paragraph from §11.

---

## §11 · The program — the one list of open work

The steps follow the dependency order of the five mechanisms (§4⑧; Morgan,
2026-10-23). Each step reads only what an earlier step built, so each one can
be committed whole. Two rules come before this order. A false proof that a
user can hit (§0's property 2 failing on code that a real program contains)
is fixed before anything else, and the checks that verify every landing must
stay reliable. A real program is one in `examples/`, `lib/` or the wheel. A
false proof that only a test fixture reaches is measured and joins the step
that owns its mechanism, and its fixture becomes that step's red test. So
finding a new case never moves it ahead in the order. The DSP arc runs
before the fused oracle's last pin (Morgan, 2026-10-21), so step 7 comes
before step 8. A landing is committed whole, and a gap found inside it is
fixed inside it. When it lands, its text leaves this list and §7 is updated.
Each `Hβ.*` label names a design as git records it. A file outside PLAN
cites a step by its name (`PLAN §11, the keystone`), never by its number, so
the order can change without leaving a citation out of date.

**The definition of done**: one statement per §0 property, each one a final
gate. (1) *Proof beats review*: the crown is sound under polymorphism, the
row records every way a computation stops, Verify decides its fragment with
explicit `V_Pending`, its search is the medium's own, and every diagnostic
class is actually raised. (2) *The negative is provable*: an `Untrusted` value
that reaches a `Trusted` sink is refused, implicit flows included. (3)
*Intent is lossless*: the Why walk is total, provenance is projected at every
surface, the formatter's fixed point is canonical, every comment's code is
judged, and every mention in a comment is an edge. (4) *Computation is
durable*: persist extends to resuming on another machine, and the session is
a value. (5) *Systems explain themselves*: `mentl audit` is live, the docs
are a projection, and a refusal is answered by the same proposer loop as a
`??`. (6) *The oracle at its limits*: the fused multi-cursor multi-shot
search is the default judge. (7) *`!Outside` closed*: the native backend,
diverse double compilation, and the correctness oracle absorbed into the
wheel's own evaluator. (8) *Nothing owed*: every ceiling on the board is at
zero or at a decision the author made, the course and the two scores check
clean (the `QOwed` bounds at zero), and there is no expected red, no
silencer, no diagnostic class that is named but never raised, and no landing
named outside this list. The end point is §1's closed loop: the person and
the medium, with nothing else needed at any scope.

**Five forms of one violation.** The largest open items are all the same
violation: a materialized view stored where an edge belongs. It takes five
forms. Structure (already fixed: a node is its handle). References (already
fixed: a name is a node linked to what it names, and a binder is declared
where it is written). Schemes (a declaration's type is frozen at its exit).
Provenance (a `Reason` is a value tree that copies handles, structure, types
and spans into every node). And the lowered program (`LowExpr`, a second tree
whose walks read names). The keystone (step 2) and the face (step 3) remove
the last three.

**THE STANDING CURSOR**: the order in which the work runs.

1. **The soundness core: the crown modal, the row whole, the reach one
   walk.** (a) The crown, made modal (`Hβ.effects.modal-world-index`). A row
   names effects: `EffName` carries a name and its arguments, a `RowEdge`'s
   mask names effects, and `inf_mark_install_frame` drops the handler that the
   install judgment already has. So absence is proven per effect, never per
   install. The form: an effect in a row is indexed by the install that
   answers it (`E@h`, the install node the judgment resolves when it draws the
   op edge; `E@?` where a caller's install answers). A mask names the installs
   it subtracts, and a row variable bound at a `~>` edge is that install's
   lexical capability. This is Tang and Lindley's synthesis, with the negation
   half carried through. The facts that need an install's identity then follow
   directly: a handler held as a value (its record is the install's
   identity), two installs of one instance with a negation between them, and a
   closure created under one install and called under another. The index is
   written once, where the op edge is drawn, and it is read by
   `row_subsumes`, `diff_row`, the gate's mask, the Why walk and `mentl
   where`. `inter_row`'s silent arm is deleted, a world mismatch names its two
   worlds, and a persisted continuation's world is checked where the image is
   resumed. A generic op is quantified per perform, so two instantiations of
   one effect do not join at an install
   (`Hβ.effects.two-instances-of-one-effect-do-not-join`). Each modal rule
   gets one crucible fixture, red first, with its sound twin. The page's
   hop-by-hop unrolling of a `!E` under polymorphism is part of this step
   (`Hβ.effects.sound-neg-under-poly`).
   (b) The row is complete: every way a computation can stop or reach outside
   itself is a row fact the crown can negate. Non-termination is a row fact
   beside `Trap` (`Hβ.effects.divergence-is-a-row-fact`), and an executable's
   row is the row of `main` and of its inits
   (`Hβ.effects.executable-row-includes-inits`). Each op belongs to the
   effect that matches what it does
   (`Hβ.effects.op-lives-where-its-behaviour-belongs`,
   `Hβ.memory.word-arithmetic-is-memory`): the ops of a `*Write` effect write
   and the ops of a `*Read` effect read. A census held at zero checks this
   through the published write fact (`graph_version` and
   `graph_attach_comment_ref` move into GraphWrite). Then a comment saying
   that a function only reads the graph (`row_subsumes`'s) becomes the
   negation it states, `with !GraphWrite`, and the comment is removed. Word
   arithmetic leaves `Memory` in two pins at the bootstrap seam: first it is
   registered as primitives that the library shadows, then the library's
   declarations are deleted. After that, a function doing only arithmetic on
   words is `Pure`. Memory's stores become an effect of their own, so the
   store-age judgment reads a raw store off the op's edge, where today it
   reads the op's spelling (`raw_store_target`). (c) The reach is one walk
   (`Hβ.graph.reach-is-one-walk`): `reach(from, edge kinds, stop)`, cached as
   columns, answers absence, the effect-enters chain, the race rule, the
   schedule's demand, the edit cone, `refs of`, `unreachable` and the
   Severance Map's bands, each keyed by edge and none by spelling. Each query
   first gives the same answers as its own separate walk on the wheel and the
   batteries, and then the separate walks are deleted.

2. **The keystone: lowering is a column, and the graph gains its evaluator**
   (`Hβ.lower.lowering-is-a-column`, `Hβ.lower.the-evaluator-is-a-projection`).
   Lowering becomes columns on the program's own handles, and the `LowExpr`
   tree and its walkers are deleted. A lowered unit becomes a column on its
   declaration's handle. Today its identity is the symbol `LFn(String, …)`
   carries, and the reach walks of the emit and of the reading
   (`plan_reached`, `reach_units`) key their units by that symbol. The gate
   is m3 == m4 with the symbol-keyed walks deleted. A `Reason` becomes an
   edge to the node it names, never a copied tree. A continuation becomes its
   frame's record in the image plus the node it stopped at, captured by a
   copy and resumed by entering the frame's one function at that node. Today
   the lowering copies the frame's tail into a separate function at each
   place the frame can suspend (`capture_frame`), so a block with n such
   places writes its tail n times. A module value becomes a column on its
   binder. Then a module-scope let binds every binder its pattern writes,
   each at a global of its own, and runs its value for effect when it binds
   none; today any pattern other than one binder is refused. The derived
   compare becomes a node that a generic function calls, the 3-way fold that
   `<` on an aggregate already runs. Then `sort` orders a Float in the folds'
   total order, and a NaN sorts above +inf. Today `sort` reads `<` and
   answers `[-0.0, 0.0, 1.0, NaN, 2.0]` for `[1.0, NaN, -0.0, 0.0, 2.0]`
   (measured 2026-10-24).
   **The stack spills** (`Hβ.lower.deep-stack-spills-to-heap`). A recursive
   call is a place where its frame may suspend. Past a depth bound, the rest
   of the work moves to the heap and resumes on a fresh stack. So depth is
   bounded by memory, which `Alloc` shows, `!Trap` holds over any recursion,
   and `!Alloc` limits real-time code to recursion it bounds. The red test: a
   `!Trap` recursion a million calls deep traps today.
   **The evaluator** is a handler over the lowering column. It gives the
   graph's reference meaning beside the WAT emit, and it brings the
   correctness oracle into the medium
   (`Hβ.closure.correctness-oracle-internal`). Every fixture runs through both
   projections, and the two must agree. A trace handler records every
   perform, so a run that performs an effect its declaration negates fails
   the battery. The witness searches as well as replays. Each declaration
   that states a negation or a refinement is run at the boundary values its
   parameters' types admit (zero, −1, the Int extremes, NaN and the
   infinities, the empty sequence, a deeply nested value), under the trace
   handler and the heap mark. So a claim that some input breaks fails the
   battery and names the input; today a false proof is found only by a probe
   that someone thought to write. The page runs straight from the session's
   graph. The value walk and the derivative reading become the evaluator's
   abstract and tangent instances, and arithmetic on a user type comes from a
   numeric projection's rules (`Hβ.lower.ad-is-a-demanded-projection`).
   **Every value crosses at its own width, and every record lives where its
   extent does** (`Hβ.lower.install-record-in-the-frame`,
   `Hβ.lower.captureless-nested-fn-is-static`,
   `Hβ.lower.held-resume-record-is-not-reclaimed`,
   `Hβ.arena.closure-evac-face`, `Hβ.arena.extent-spanning-a-spawn-keeps`,
   `Hβ.value.seq-element-stride-carrier`,
   `Hβ.lower.parameter-product-calling-convention`,
   `Hβ.effects.handler-value-is-its-record`). An install whose record never
   outlives its extent lives in the frame and costs nothing. A nested fn that
   captures nothing is the module's static record. A held resume's record is
   dropped after its one call. An arena's exit moves a value whose type the
   store cannot see, and reclaims across a spawn its instance makes. A list's
   element crosses its slot at its own width, so a Float is never boxed to
   cross a word slot. A thread's task record holds a Float answer as a
   double, and the schedule's arms are twinned at the install's answer; today
   a `fanout` that answers a Float under `parallel_compose` traps at its
   join. A pair passed to a one-parameter literal and two arguments passed to
   a two-parameter function use one calling convention. A handler named as a
   value is its record: `let h = one` binds it, a parameter holds it, and an
   install of a value pushes the record it holds and absorbs the effect its
   `Handler(P, A)` type names. Today the value's emit names a global that
   nothing defines. Each charge follows the representation from the day the
   lowering builds it, so `!Alloc` accepts code that allocates nothing.

3. **The face: every declaration publishes one, and verification reads it**
   (`Hβ.graph.every-declaration-publishes-a-face`). A declaration's face is
   one column written where its judgment ends: its scheme, its row with each
   effect at its install, its contract (preconditions stated and learned, and
   postconditions), its store claim, its flow summary, its resume grades and
   its latency. Every caller reads it. Schemes become edges
   (`Hβ.infer.schemes-are-edges`): instantiation is a correspondence edge,
   never a clone, which pays down the rest of a recursive group's cost
   (`Hβ.infer.update-relations-multiply`). Today the relation is copied onto
   fresh cells at every instantiation (`relation_copy_one`), a reference
   substitutes a row's edges (`subst_row_build`), and the flow walk builds its
   context as a record literal (`ctx_at`), although the update form is the one
   SYNTAX asks a person to write. An arm's resume grade becomes a column on
   the arm, written once where its op edge is drawn, and a callee's tail facts
   become a column on the declaration its edge reaches
   (`Hβ.cost.arm-grade-is-a-column`). Today `arm_grade` re-runs the arm's
   fixpoint for every reader (the op edge, the never-returning op's check,
   the continuation's discipline, the session's comparison), and the tail
   facts are an smap keyed by spelling. A substrate primitive's face moves
   onto its declaration (`Hβ.infer.seq-op-signature-driven`). Today the faces
   are a table in the judgment (`seq_op_sig`). Each becomes the primitive's
   own signature, with its body typed through it, once a list's element
   crosses its slot at its own width (step 2). Its precondition is a claim on
   that face, decided at every explicit call the way `xs[i]`'s is
   (`make_list`'s count, a slice's bounds, an index). So a call that the
   fragment proves in range charges no `Trap`, where today every explicit
   call of one charges the `Trap` its body's check can raise. A call's answer
   read off a tee (a fold's accumulator, a handler's answer) is placed by the
   install's arms, as the value walk already reads them
   (`Hβ.effects.tee-answer-is-the-arms`). Today a function threading a table
   through a fold's result owes `Mutate` it could prove.
   **Verification reads the face.** The verifier decides a predicate's
   expression directly. The `Predicate` projection, `node_to_predicate` and
   the copy frozen into `TRefined` are deleted, and the value walk reads the
   predicate's nodes and a called function's contract and body. So a
   predicate that calls a function, or that performs an op answered by an
   install in sight (lesson 6's Nyquist bound), is decided. A parameter is
   what its calls pass it (`Hβ.verify.parameter-is-what-its-calls-hand`).
   Each call's hand-off is recorded where its edge is drawn and read under
   that call's path, and the recursive call is read under the body's own
   hypothesis. So `0 <= i`, where every call passes `0` or `i + 1`, is a
   hypothesis of the body, and the wheel's index loops are proven. A label's
   claim on a part read off a call's answer is read through the callee's
   return tails. It is proven where the callee built the part in sight, and
   owed, naming the site, where it did not
   (`Hβ.verify.part-of-a-call-answer`). A refinement that a callback requires
   of the values a callee passes it is judged where the callee passes them
   (`Hβ.verify.higher-order-refinement`), with its stage face built. A state
   write is read as the claim's own hypothesis, an inductive invariant
   (`Hβ.verify.state-reads-its-invariant`). A handler is a judgment unit: a
   claim an arm makes about its own state's parts is decided once every arm
   is judged, together with its row fact. Today the claim is owed and the
   `Trap` it guards is charged at the install
   (`Hβ.verify.handler-is-a-judgment-unit`). A Float carries its range (a
   sine's [-1, 1], affine combinations, a clamp), so a frequency computed from
   a sine or a product is decided (Pulse, Wasatch).
   Layout must not change what is owed. Measured on 2026-10-27
   with `mentl audit` on examples/grid/station.mn: one comment line or one
   blank line added near the top, with no change to the code, takes the
   pending claim of its find_from function off the list, so 13 pending
   claims become 12, while the same line added just above main changes
   nothing. A two-line function added near the top makes the list 15, and
   pending claims appear under droop and is_digit instead. So the audit
   places each pending claim on a declaration by a position that layout
   moves, and a claim can drop off the list. The audit prints only a count
   per declaration, so which claims these are cannot be seen yet. This step
   places each claim on the declaration that owns it and has the audit name
   each claim it counts. The step's gate is that the course and the two
   scores check clean, the `QOwed` bounds fall to zero, and the wheel's open
   obligations fall with each piece.

4. **A module is a scope, and a package carries its judgment**
   (`Hβ.driver.per-module-env-overlay`, `Hβ.query.facets-read-the-link`,
   `Hβ.modules.import-block-is-maintained`,
   `Hβ.modules.vocabulary-held-by-declaration`,
   `Hβ.effects.unperformed-effects-delete`, `Hβ.space.nothing-is-collapsed`,
   `Hβ.modules.capability-units-by-clusters`,
   `Hβ.modules.compatibility-is-computed`,
   `Hβ.modules.a-package-carries-its-judgment`). A name resolves through its
   module's own declarations, its direct imports' and the prelude's, never
   through the newest entry of one flat environment. So a user's `count`
   beside lib/lists is legal, a library's own reference never rebinds to a
   user's declaration of the same name, and a collision is settled at the
   import edge by a selective import set (`E_ImportNameCollision`, active from
   the start). Two declarations of one name inside a module are refused at the
   second, which names the first, whatever their kinds. Today a constructor
   that shares an effect's name shadows the effect, and every row naming the
   effect is refused as naming no effect; two effects of one name merge their
   ops; and two types' constructors of one name show up as type mismatches
   where they are used (measured 2026-10-15). The medium proposes a missing
   edge at the reference, writes a conduit as a direct import and reports a
   dead one (`T_DeadImport`); fmt removes duplicates and orders the import
   block. The facets follow: `imports` prints what crosses each edge and marks
   it `conduit`, `DEAD` or `DUPLICATE`; `importers of <module>` is added;
   `where` and `query` exit nonzero on "not found"; and no two facets may give
   different answers. The compiler's vocabulary is held by declaration: the
   effects that a schedule, a derivative reading or an arena reads resolve to
   handles once. So a user's own `effect Thread` is an ordinary effect, no
   string literal in src spells an effect, and the performs the lowering
   writes for a schedule name their ops by edge. An install that absorbs
   nothing is reported (`T_InstallAbsorbsNothing`), and an op that nothing
   performs is deleted along with its arms. A module splits along its
   reference clusters (a `clusters` facet; lib/strings and src/types first),
   and its prefixes become module names. A decoration banner drawn by hand is
   read as the cluster it marks: the facet proposes the split the banner
   names, and the banner is removed with the split, never before it, so the
   grouping is kept. The page's collapsed "reports in linked modules" section
   is deleted, since a library judged clean at its own boundary produces
   nothing in a user's link.
   Handlers are package management, so there is no package manager. An
   `import` performs `resolve(path)`, and the handler installed over the link
   answers it: today from the project's folder and the library, and later
   also from a content-addressed store or a registry. So a version is that
   handler's configuration, the lock is the hashes that the link's import
   edges resolved to (kept in the image), and a dependency's capabilities are
   a negation that its import edge states
   (`import vendor/json with !Network`), proven over everything the module
   exports by step 1's reach. Compatibility is computed, never declared. A
   version whose exported faces equal the last one is a patch. One whose
   faces only widen what callers may rely on is compatible. Any other is
   breaking, and the resolve handler refuses an upgrade that breaks a caller's
   use and names the call. A package carries its judgment: its faces and
   lowering columns are a content-addressed segment of image, judged once by
   its author and read by every link that resolves to it. The kernel
   re-checks the segment wherever it does not trust it, so the segment is
   treated as a certificate that is always checked and never taken on trust.
   The root table (`module_roots`) is deleted and its job moves into the
   handler, and a module's layer is what the handler reports about where it
   found the module.

5. **A refusal is a hole** (`Hβ.diag.a-refusal-is-a-hole`). One proposer loop
   runs under the diagnostics, Teach, accept, tighten and fmt. Where the
   program lacks a proof, the medium forks candidate edits, judges each in its
   own instance, and shows the proven ones or asks the one question that
   separates them. So `mentl check` runs the same loop that a `??` runs. The
   catalog is a projection (`Hβ.diag.catalog-as-projection`):
   `mentl diagnostics` projects it from the `DiagKind` constructors, and
   SYNTAX's tables become its text. Each class the docs name that no
   constructor declares is either added with its fixture or struck. Each
   class is tested: its fixture is refused, and its fix, applied in a fork,
   passes. Accepting a proposal rewrites the hole's node in place
   (`Hβ.graph.positions-are-cells`), and the position-keyed accept column
   (`Hβ.synth.accepted-edge-keyed-by-position`) is deleted.
   An effect op's parameters are named the way a function's are
   (`Hβ.syntax.parameter-product-has-identity`). The medium proposes each
   name from what its handlers' arms bind and asks where they disagree, `mentl
   tighten` applies the names everywhere, and the positional form is then
   refused (`E_UnnamedParameter`). A type name that resolves nowhere is
   refused with `E_MissingVariable` at the name; today `fn f(x: Nope) = x + 1`
   is refused as arithmetic on `Nope` (measured 2026-10-21). A dropped value
   is reported (`Hβ.infer.statement-value-is-dropped-silently`). A block's
   non-final statement whose value is a function is refused
   (`E_DroppedValue`). A non-unit word or aggregate is reported without being
   refused until the wheel's census reaches zero, and refused after that.
   `let _ = e` is the explicit discard.
   Teach lists what the program still owes
   (`Hβ.teach.teaches-what-the-program-owes`). It proposes a refinement at a
   part (walked back through `PartFact` to its producer, and ranked by the
   obligations it discharges). A declaration with an authored clause is still
   offered the further locks its dependents rely on. Teach reads a lexical
   ring up the parent edge, builds calls with argument holes, and proposes a
   record for a positional product. One obligation value is rendered once for
   the caret, teach, audit and smt (smt asserts the negation along with its
   declarations). A declaration's Why is its signature's, and a module gets a
   lede of its own. The step also covers the self-proposal benchmark,
   topology proposed under the race rule's proof, and removing from the
   wheel's own heads the types the judgment derives, as was done for the
   course's (`mentl tighten`). The Why walk's thin hops name a call argument's
   flow (`Hβ.why.flow-naming-at-call`) and a refined alias's provenance
   (`Hβ.why.refinement-provenance`), and the trivial hops are left out
   (`Hβ.viz.why-walk-elides-trivial-hops`).
   A comment is held to what it says (`Hβ.comment.a-fence-is-judged`,
   `Hβ.comment.a-label-is-a-mention`,
   `Hβ.voice.comment-mass-absorbs-into-projections`). A fenced block in a
   comment is judged as a module of its own, within the reach of the module
   that holds the comment. A refusal there is reported at the fence, and the
   block's names are mention edges, so a rename rewrites them. SYNTAX's
   fences are judged the same way, each tagged with the contract it holds, so
   the examples of the language's surface are compiled. An `Hβ.*` label is a
   mention of the §11 paragraph that names it. It resolves, or raises
   `W_CommentRefUnresolved`, as a backticked name does, so one rule covers the
   documents and the source, and doc-truth's label check is folded into it.
   The silencer markers are removed with the drift-audit scaffold they
   silence, and its modes move into the census, so no comment changes a
   verdict. The voice (the explanations Mentl derives from the graph) takes
   over the comments that only state mechanism. No counter can tell a comment
   that states mechanism from one that states intent, so each landing carries
   the rule: it applies SYNTAX's deletion test to the comments of every module
   it touches, and its commit names the projection that now answers each
   comment it deleted. Archaeology, lifecycle prose, commit hashes,
   coordinates, and ledes that repeat another comment's text fall to zero. A
   comment inside an expression attaches by the span rule that the gate
   measures (`Hβ.parser.expr-interior-comment-attach`). An unresolved mention
   is reported at its backticked word, a declaration's Why walks its comment,
   and fmt keeps a trailing comment beside its code where it fits.
   The documents become projections that the medium holds to the code
   (`Hβ.docs.tables-are-projections`, `Hβ.docs.a-rule-has-an-id`,
   `Hβ.docs.a-name-in-a-document-is-an-edge`). Each is the medium's own
   reading, never a documentation tool beside it: there is no site generator
   (the page and `mentl doc` render the documents) and no decision-record
   directory (§4 is the register of decisions). SYNTAX's tables are rendered
   from what they describe, as the catalog is rendered from the `DiagKind`
   constructors (above). Each class there also carries its explanation and a
   site that constructs it, and a constructor that nothing constructs is
   struck. The precedence table is rendered from `binop_prec` and
   `pipe_prec`, and the token enumeration from `TokenKind`, whose hand-kept
   checksum is deleted. Each normative sentence of SYNTAX carries an id, a
   fixture names the ids it witnesses, and `mentl verify` bounds the number
   of sentences that no fixture witnesses, a ceiling that only falls. A §4
   decision carries an id that a comment or a commit cites as a mention. A
   backticked name in the three documents is a mention resolved against the
   wheel and the library, so `mentl rename` rewrites the documents along with
   the source, and a name that nothing declares raises a warning. SYNTAX
   states the surface and §7 the state: each "today" and "not yet" in SYNTAX
   moves to the §7 line it describes, and leaves its label where the form
   will stand.
   The medium writes the wheel's migration itself
   (`Hβ.wheel.iteration-is-topology`). The costume detector flags index flow
   (a parameter threaded ±k into an index read), and treats as shapes to
   rewrite let-chains, nested-call pipes, places that call for `<|`/`><`,
   repeated install suffixes and partial eta (`(row) => dot(row, x)`). The
   multi-parameter lambda is replaced by a reference
   (`Hβ.syntax.multi-param-lambda-is-a-reference`). A `match` whose one arm
   takes a product apart is written as the `let` it is, and a `match` over
   `Some`/`None` as the stage or handler that answers the absence (the census
   counts both: `match-destructure`, `match-option`; there were 6,123 `match`
   sites against 857 `|>` on 2026-10-27). Tighten rewrites by edge, and keeps
   each rewrite as a candidate only when every declaration it touches
   publishes the same face as before; the prelude's datum-first signatures
   (`reduce`, `scanl`, `nth`, `clamp`) are among the rewrites. Recursion that
   survives is priced by a signature. Handlers are installed once: one install
   per extent, a handler's start state its own, a chain named once, and
   nothing installed only to swallow an op that no code reads.
   The project is canonical, and a render that changes the tree is not
   written (`Hβ.fmt.the-project-is-canonical`,
   `Hβ.fmt.render-must-parse-to-the-same-tree`). fmt removes every
   redundancy that leaves the graph unchanged: `-> ()`, box-drawing
   decoration in comments (a banner, once its module has split along the
   cluster it marks, step 4), `0 - <literal>` where exact, the sole-parameter
   binder as an arm list once the parser builds one `LambdaExpr` for both, and
   the ownership marker before the name. A render whose re-parse is a
   different tree (compared by a structural fingerprint over both parses) is
   refused, and the heads round-trip count falls to zero as the parser learns
   the rules it misses. The batteries address a hole and a declaration by
   identity, never by `L:C`, so every fixture can be canonical.
   `mentl fmt --check` at zero over src, lib, examples and tests is a line on
   the board.

6. **Edits cost what they change, and the page plays the course.** The
   edit's cone gets a cutoff (`Hβ.session.edit-cone-cutoff`): a declaration
   whose rewritten dependency publishes the same face is not judged again.
   Today an edit to `chain_spelling` judges 1,767 declarations (§7). The
   delta between two versions is read by comparing the two versions
   (`Hβ.graph.delta-is-two-versions`). The session pays only for what an edit
   changed (`Hβ.session.edit-pays-for-the-program`) and outlives its process
   (`Hβ.felt.accept-outlives-the-process`). Persist resumes across machines
   (`Hβ.persist.cross-machine-resume`), so the session is a value.
   The hot path is measured (`bash tools/profile-self.sh`,
   `tools/guest-profile.py`), and each top caller is removed by fixing the
   rule it breaks, never by chasing a number (`Hβ.cost.hot-path-by-law`).
   These costs are measured and named, for the profile to rank. The dispatch
   memo answers from a hashed table, where a dense index per (effect, op)
   would answer inline from two loads. `fold` and `each` index their flat list
   through the typed bounds check for every element. `instantiate(Live(h))`
   re-generalizes the declaration at every use. `env_snapshot` fills an index
   per call, and each `??` segment installs a fresh env. `row_of_subtree` is
   a whole-subtree fold, not memoized, called for every node.
   `set_canonicalize` re-sorts a growing accumulator in the
   `effects_of_edges` loop. The `wmap` columns have fixed bucket counts, so a
   graph read scans a bucket of hundreds of entries. `ls_find_str_local` and
   `name_set_prefix_contains` scan on every lookup. And a handler's state
   commit journals its slot at every write, where once per extent would hold
   what the exit reads. So the parse of src/infer.mn writes past the arena
   journal's 262,144 entries, and its exit keeps every temporary the parse
   built (measured 2026-10-22, with a probe that traps at the overflow). The
   self-compile's wall time and peak memory ratchet down. The wall time is
   read as a share of the boot's on the same wheel, since a single wall-time
   reading reflects the machine's load as much as the compiler.
   The page plays the course (`Hβ.space.the-canvas`,
   `Hβ.emit.the-medium-assembles-its-output`, `Hβ.viz.severance-map`). The
   course is written: `examples/pulse/course` holds ten lessons on one
   growing chain that a developer hears, each a program that `mentl run`
   renders. The page opens the folder as a project, and `mentl verify` counts
   the lessons the medium cannot yet judge clean (the `QOwed` bounds,
   src/board.mn). The canvas paints the wheel's own tokens at their spans,
   the aspect strip and the ambient-world glyphs, obligation marks, the
   ownership trace, fmt on idle, and a version as undo. The page runs what it
   compiles: immediately through step 2's evaluator, and through the bytes
   that `mentl asm` writes when speed matters. A lesson plays to the speaker,
   and the fixpoint seal runs in the page.
   The page's remaining parts are named: the View as graph content
   (`Hβ.space.view-is-graph-content`), a folder pick outside Chromium
   (`Hβ.felt.project-picker-outside-chromium`), the run in the page
   (`Hβ.felt.ide-run-in-page`), the ambient-world gutter
   (`Hβ.viz.ambient-world-gutter`), the living runtime's render loop
   (`Hβ.felt.mentl-edit-runtime`), typed demand-driven reactivity
   (`Hβ.felt.reactivity-typed-demand-driven`), time travel over the forks
   (`Hβ.felt.time-travel-debug-forked-cursor`), and the terminal session
   reading more than one action (`Hβ.felt.edit-session-reads-one-action`).
   The compile reports its steps to the page as it does to a terminal: the
   page's handler of the `Progress` effect paints them, and MCP sends them as
   notifications while a long request runs.
   The Severance Map is step 1's reach, projected over the module and
   declaration tree in three colours: provably absent, present, and not yet
   provable. The third colour is counted, and the count must fall. The map
   ships only after its known false greens are fixed, or once it counts them
   in the third colour. Its demo is Wasatch's network twin turning a green
   band red, with the refusal naming the call. Then comes the stranger test:
   someone who has never seen the repository installs the medium and
   finishes lesson 1 from the README alone.

7. **The verbs are whole, and the DSP arc** (`Hβ.verbs.the-verbs-are-whole`).
   Early exit is a resume grade, so `any`, `all`, `find`, `take` and
   `position` stop at the first hit, and `iterate` yields lazily: `any` over
   five elements under a counting handler counts 3. Every cycle has a driver.
   An input loop is a fold over an `Iterate` source, with quitting as the
   abandon (`mcp_loop` and `session_line_loop` become one; `cursor_session`
   folds over its actions). A fixpoint is a `<~` on a convergence clock that
   refuses rather than return a non-fixpoint. List pipelines are `~>` stage
   chains that yield their results outward in one pass, and deforestation is
   an e-graph rewrite in the `Iterate` algebra, legal where the rows allow it.
   A `<~` cycle's clock is inferred, so a cycle that nothing advances is
   refused as a measurement (`Hβ.dataflow.clock-calculus-sample-rate`). Its
   depth may be a value the ring reads at run time
   (`Hβ.dataflow.delay-line-runtime-depth`). The delay spec is the static
   depth the emit already treats it as, never an expression judged in a
   dropped frame (`Hβ.effects.feedback-row-substitutes`). The line can be
   read at a moving, fractional tap (for a chorus, a flanger or a pitch shift)
   as well as at its oldest slot. A decaying line flushes a denormal in its
   tick, since wasm has no flush-to-zero mode. A stage's coefficient is
   computed when its input changes, never once per sample (today
   `compute_alpha`'s `exp` runs per tick in every filter). A `<|` or `><`
   join aligns branches of known latency, with latency part of each stage's
   face, or refuses the misaligned merge (measured 2026-10-21, after a survey
   of Sonido). The prelude takes the datum last in every stage-shaped
   signature, through step 5's reorder.
   The derivative reading's remaining parts (`Hβ.derive.vector-forward`,
   `Hβ.derive.gradient-as-a-value`, `Hβ.derive.transpose-through-iteration`,
   `Hβ.derive.transpose-through-the-record`,
   `Hβ.derive.bptt-priced-by-the-row`, `Hβ.derive.closure-line-tangent`). A
   product seed is answered through a call made through a value, a perform, a
   `<~` line, a record carrying a tangent, an install, an early return, a
   query inside a callee and a recursion; today the reverse projection refuses
   these, naming the vector-forward reading. A gradient held as a value is a
   record the row sees. The transpose crosses iteration and the record. A
   `<~` line's history is priced by the row. And a line that a closure record
   owns carries its tangent.
   Wasatch "Inversion"'s live half (`Hβ.wasatch.keyed-sources`,
   `Hβ.env.configuration-is-an-effect`). Today the score renders from its
   snapshot (`examples/wasatch`: every parameter is a reading of Salt Lake
   on the evening of 2026-10-20; per-sample path: `!Network + !Filesystem +
   !Alloc + !Sample(44100)`). What remains is the keyed sources (UTA's
   real-time TRAX first, then the gauges and the observation the snapshot was
   read from), reached through a key that the host applies and the guest
   never holds. A secret is a label on an opaque host handle: the flow walk
   proves it never reaches output, and an import's negation proves that a
   dependency never touches it. The score then plays in the page as the
   readings change.

8. **Forks on every core** (`Hβ.oracle.forks-on-threads`,
   `Hβ.driver.level-set-par-walk`, `Hβ.native.deterministic-handle-partition`,
   `Hβ.lower.schedule-through-a-value`, `Hβ.verify.the-solver-is-the-search`).
   The compiler is still emitted as a module without threads (a defined
   memory, a bump allocator, no spawn import), and this is the one pin the
   fused oracle still needs. A handle becomes an `{arena, offset}` product
   (one word, by a repr pin) that is deterministic under any order. The
   demand walk that twins a direct callee by the install's schedule follows a
   `~> h` in the demanded reach into `h`'s arms. The arm twins are keyed by
   the schedule letter and created only where the schedule changes the
   lowering. `parallel_compose` becomes a pool sized to the cores: a fanout
   enqueues its branches as task records in the image's shared queue, a
   nested fanout inside a worker enqueues instead of spawning, and the join
   reads results by option index. The pool stands over the judgment at every
   verb entry. `sequential_compose` stands at one site: `mentl march`'s
   determinism leg, which compiles the wheel twice in-process, once under
   each schedule, checks that the two WATs are byte-identical, and prints
   both wall times. When the emit finds `spawn_task` reached, it emits the
   spawning module. The page's resident session activates the pool that its
   run role has. Emission, the classifier rounds and the judgment's
   binding-group levels are fanouts, the battery judges its library once, and
   Pulse renders block by block under `parallel_compose`. A schedule reaches a
   fanout through a function value created under it. Two branches that write
   disjoint ranges of one buffer run, each owning its slice of the memory the
   fanout passes it. Today they are refused as one buffer written from every
   instance, and the refusal's advice names a stateless handler for an effect
   with no ops.
   Verify's own solver is the search: union-find and the e-graph serve as
   congruence closure, the chain of forked instances as the assignment stack,
   a fork as a case split, and the first divergence of two forks' write sets
   as conflict analysis. The fragment grows in the order that the wheel's own
   debt calls for: overflow-aware intervals, linear arithmetic beyond the
   difference bounds the path is read in, and equality from the e-graph. An
   external solver plugs in only as a proposer whose certificate the kernel
   checks. Every step is gated by m3 under `sequential_compose` being
   byte-identical to m3 under `parallel_compose`, with the two wall times on
   the board.

9. **`!Outside` closes.** The native backend (`docs/NATIVE.md`, whose second
   keystone is the deterministic band) is one more projection of step 2's
   lowering column. Diverse double compilation
   (`Hβ.closure.diverse-double-compilation`) compiles the wheel through two
   independent projections and compares the results. Every scaffold under
   tools/ is absorbed into a verb: the march is `mentl march`, the board is
   `mentl verify` and the landing pass is `mentl land`, so the working loop
   names no script. The gates that `mentl land` runs in sequence on the host
   are next. The run and refusal legs of the frontier gate are fixture
   contracts, run as a battery of the landing pass (2026-10-27, `mentl test
   tests/frontier`). The gate keeps what no contract covers yet (a verb's
   text, an edit workflow, a project route), and each of these becomes a
   contract that the battery gains, until the gate is empty.

---

Excluded only because of hardware limits: MI300X execution, wasmFX, and
shared-everything threads.
