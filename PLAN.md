# Mentl — PLAN.md

MENTL_MEMORY.md, the memory north star, takes precedence over this document.

> **The three documents.** `CLAUDE.md` says how to work on Mentl. This file
> holds the design and the working plan: the thesis, the kernel, the
> decisions already made (§4), where the code still falls short of the
> design (§7) and the one list of open work (§11), which opens with the
> boxes in the order they run. `docs/SYNTAX.md` is the authority on how
> Mentl code is written. Each fact is written in one document, and the
> others point to it. CLAUDE.md is read whole. This file and SYNTAX are read
> in parts, through the map that `mentl map` builds from their headings.
> History is `git log`, and the chain of pins is in `boot/PROVENANCE.md`.
> The board's numbers come from the compiler's own commands (`mentl land`,
> `mentl verify`) and are never written in this file. When a box lands, the
> same commit deletes it from §11 and brings §7 up to date.
>
> **The plan lives here and nowhere else** (Morgan, 2026-11-10). No session
> keeps a plan in a tool's plan file, a scratch directory or a
> conversation. What is decided goes into §4, what is open into §11, what
> falls short into §7, and what a session learned about method into
> CLAUDE.md, in the commit that learned it. MENTL_MEMORY.md is never
> edited, so its list of landings is read with §7 beside it: of that list,
> M1 and M3 are built, M2 and M4 in part, and both of its "other open
> landings" are built.

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
   assurance only up to some limit, and proof has no such limit. A person
   sees it as `mentl check examples/grid/station.mn` printing one line and
   no pending claim: every claim the grid controller states is proven, and
   the line counts one place that can still stop the program, which `mentl
   why examples/grid/station.mn main Trap` traces to the printing of each
   decision line. The copy that reads a price inside the decision does not
   build.
2. **The negative is provable**: people often mean "this never touches the
   network" or "this never allocates", and no mainstream language lets them
   say it. `!E` says it, and it holds under polymorphism. The absence it
   proves takes the identity of each handler and install into account, holds
   under modality and over time, and is proven per instance
   (`!Sample(44100)`). This is the most underrated part of Mentl. A person
   sees it as `mentl why examples/grid/station.mn decide Network` answering
   that `decide` never uses Network, and as lesson 6 of the course refusing a
   44.1 kHz stage reached from a 48 kHz chain, naming the declaration where
   the other rate enters.
3. **Intent is lossless**: the Reason chain records why every fact holds, and
   it can be followed back to the decision that produced the fact. Nothing the
   author meant is lost between the source text and the machine code. A
   person sees it as `mentl why` walking any effect in a row back to the
   operation and the calls that carry it, and as `mentl rename` rewriting
   every use, label and comment mention through the same edges.
4. **Computation is durable**: a running computation is a value. It is a
   multi-shot continuation, and it is saved by copying the memory image. A
   person sees it in the course's twelfth lesson: `mentl run
   examples/pulse/course/12-resume.mn` renders two seconds of a piece and
   saves its image, and the same command with `resume` reads the image back
   in a second process, whose clock stands where the first one stopped, and
   prints a file byte for byte equal to lesson 11's one-process render. The
   frontier gate's arena leg saves from inside an open arena and resumes the
   arithmetic it was in the middle of
   (tests/frontier/arena/persist-resumes-outside.mn).
5. **Systems explain themselves**: at any point in the code, the cursor shows
   what is currently true there, so the medium answers the question and the
   author does not have to work the answer out. A person sees it at a hole:
   `mentl examples/pulse/course/08-hole.mn:50:76` proposes the one stage that
   fits, `mentl accept` writes it, and where two candidates both prove, the
   cursor asks which one the position means instead of picking.

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
`EfRow(present, absent, tail)` with `EffTail = EtClosed | EtOpen | EtAll`, and
negation is the absent field. The crown battery (`tests/crown/`, run by
`wt_battery` like every test directory) is the soundness gate. The time axis is
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

**⑨ Memory is a projection of the graph** (decided 2026-10-29). The compiler
keeps one graph of facts, and a program's memory is one more view of it. A
value is the record of a node. A lifetime is the extent that owns the node,
where an extent is one run of a handler's body, from its install to its
exit. One extent is five things at once. It is a region, where its values
are allocated. It is a version, the instance a fork runs over. It is a
world, the segment of the install chain a continuation carries. It is a
checkpoint, the image at its boundary. And it is a transaction: its stores
into memory older than itself are its journal, and its exit keeps or drops
them. At the exit, what the result reaches survives and moves out along its
own type, by the reach the judgment drew; everything else is reclaimed and
zeroed in one step, so memory holds a value or zero and never garbage. A
value is written in place where the judgment proves it is owned once. A
value is named by its extent and its offset in it, never by a bare pointer,
and carries no header, count, generation or capability: its type is its
layout. The whole of a program's memory is one image, copied to save,
re-entered to resume, moved to any host and read back as facts.

Five readings follow, and each is a landing's check rather than a claim.
(1) The row is the memory boundary: an extent whose row proves no store
past its own region needs no barrier and no journal, and memory safety and
effect safety are one proof. Built in part on 2026-10-29. The store-age
walk marks a list store into a list its own extent allocated, on the call's
shape, and records what may root each arena's extent, on the install's
shape, so neither fact needs a column of its own. The emitter writes the
marked store with no barrier where no arena can suspend, and the exit of an
extent proven root-free checks that no barrier journaled inside it, so
every run checks the walk. (2) Layout is a projection, as SYNTAX S2.1 says
of text: no author writes a struct, an alignment or a placement, and the
compiler arranges fields by their readers and by the schedule. (3) The
install chain is the memory hierarchy: the arena is the nearest handler
that answers `Alloc`, nesting is locality, and a memory kind (SRAM, SDRAM,
flash, a store on another machine) is a handler of `Memory` that the clock
calculus places. (4) Time is memory's only axis and `<~` names it: a line
keeps a stage's last N values, handler state keeps the past across
resumes, the image keeps everything, and a program that recomputes only
the cone an input changed is the cursor's reactivity (⑦) applied to every
program. (5) One evaluator, many domains: a run-time value is a node the
evaluator writes, as a fact is a column the judgment writes, so `mentl why`
holds for a running program and the debugger is the cursor.

The author decides four things: what must never allocate (`!Alloc` on a
stage), the budget the program fits (a claim on main's row), the depth of a
line (`<~ delay(N)`), and `own`/`ref` where inference fails. The medium
derives every address, lifetime, in-place write, layout, memory kind and
page. Every mechanism the emitted runtime still carries is a fact the
judgment does not hold yet: a barrier at every store the walk cannot prove
its extent's own and at every store of a program that yields, a journal of
one fixed size, a region kept because a root's type was not visible, a
move at an exit, a fixed grow step. §11 orders the landings that replace
each with the fact, and each lowers a count that only falls. The first
landed on 2026-10-29: a module's memory starts where its static data ends
and its first pages are what its start needs, where every module began in
32 pages with its heap at 1 MB.

**⑩ The five operators read left to right at one level** (Morgan,
2026-11-05; not built). `|>`, `<|`, `><`, `~>` and `<~` share one
precedence level and associate to the left, so each operator takes the
whole flow written before it, and parentheses make a sub-flow. All five
bind looser than arithmetic, comparison and logic. Today `|>` binds tighter
than `<|`, `><` and `<~`, and `~>` is loosest (SYNTAX's precedence table,
which states the parser as built), so a fanout piped onward needs
parentheses. The change parses by the old table and prints by the new
one's parentheses, so no tree changes and the march proves it. A product
fills a stage's parameters when the stage takes as many as the product has
parts, so a pair flowing into a two-parameter stage needs no function that
takes it apart. Today that holds for a merge's parts (`((l) >< (r)) |>
mix(0.35)`) and is refused for a value (§7). The formatter writes a chain
one stage per line where it holds a fanout or has two or more stages; where
`<~` sits and how a comment stands beside a stage are settled when it is
built.

**⑪ A default arm answers the empty value, and nothing else** (Morgan,
2026-11-05; not built). A match that asks about one constructor may answer
every other with a default arm whose value is the empty value of the
match's type: `[]`, `None`, `false`, `()` or `""`. A default that answers
anything else stays refused. When an edit adds a constructor to a sum,
`mentl check` says so once at each default over it, so nothing is absorbed
unread. A product of more than two fields is a record, so a pattern names
the fields it reads. A fact the graph can hold is read off an edge, never
matched out of the tree. `mentl tighten` writes defaults and never rosters
(§11.13).

**⑫ Each capability is a module, and no handler stands in for the host**
(Morgan, 2026-11-05; the modules built 2026-11-06, the host's handlers
not). A capability (files, the network, the clock, randomness, the
environment, the console) is one library module that holds its effect and
up to four kinds of handler: the host's own, a recorder that keeps every
answer, a replayer that answers from a recording, and models that say they
are models. No handler answers from a hand-written table in place of the
host. The host target is ordered by what it unlocks: WASI preview 1's
clock, randomness and sleep first (§11.11), then the WASI 0.2 component
target with a real network (§11.14). Continuations the engine owns are left
out, because a continuation the engine holds cannot be saved into the
image.

**⑬ Seven things a program can say or do join the plan** (Morgan,
2026-11-05; none built). A row names the one directory or host a function
may touch (§11.11, §11.14). `mentl audit` calls a function that reaches no
host input deterministic (§11.11). A resource closes when the extent that
opened it ends (§11.11). A program runs against a seeded model of its whole
world, and any failure replays from its seed (§11.15). A unit of measure is
part of a type (§11.7). A failed or timed-out branch of a split stops its
siblings (§11.8, §11.12). And a host call that waits is a perform resumed
later, so no function is marked asynchronous (§11.14).

Four decisions of the same days are about method and are written in
CLAUDE.md: the work runs as boxes that Morgan gates (2026-11-10), a change
that measures wrong is fixed forward, a cost ceiling bends only by a dated
allowance, and work kept only on a session's machine is not kept.

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

### §5.V · The verbs at the north star — three layers, and the medium derives the rest

A program is written in three layers and nothing else. The shape of every
flow is written with the five operators: `|>` runs stages in sequence, `<|`
sends one input to several branches, `><` runs independent pipelines side by
side, `~>` installs a handler over everything to its left, and `<~` feeds a
value back from the previous step. So the shape on the page is the shape the
medium holds. The claims are written on the stages: what a stage must never
do (`with !Alloc`) and what range its values keep (`-> SpinW`). What the
effects do is written at the right edge, as handlers, and no body says how
an effect is handled. The medium derives the rest: each stage's row, the
ownership of every value, the schedule of every fanout, the clock and the
memory of every cycle, the width of every number, and the proof that every
claim holds through every call and every handler installed anywhere, over
time. At any operator the cursor says the shape in one plain sentence and
names the fact it carries: the borrow at `<|`, the ownership and the
schedule at `><`, the stage completed and the slots the product fills at
`|>`, the handler and the effects its arms answer at `~>`, the depth and the
owner of the line at `<~` (built 2026-10-29; `mentl
examples/pulse/course/03-bus.mn:49:30` answers "the <| shares `dry` with 2
branches, borrowed, so they cannot race").

SYNTAX §«Composing the five» is the canon: one shape per operator with what
the medium derives when it is written, twelve rules for writing with the
five, lesson 3 of the course as the whole program with the cursor's answer
at each operator, and the distance between this picture and the artifact,
each row citing the §11 step that closes it. Every example of the syntax,
anywhere, is a real program in this repository, in canonical layout, with
the medium's answer at that site quoted from the pin (CLAUDE.md, "How to
talk about Mentl"). The wheel is the first program held to this canon. Much
of it was written before the canon and reads as its counter-example: index
loops where a pipeline over a sequence belongs, flags where a handler
belongs, tuples built by hand and taken apart on the next line. The census
measures that drift, steps 5 and 13 rewrite it (§11.5, §11.13), and none of
it is a style to copy into new code.

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

Memory is this law's own account (§4⑨). The image is the memo of every
extent kept: a fact kept is bytes, and deriving it again is a miss. So a
module's memory is sized from what the compiler already knows when it
emits, never from a constant. Since 2026-10-29 the heap begins where the
static data ends and the declared pages are the ones `_start` fills, so a
course lesson with no arena begins in two 64 KiB pages and the grid
controller in 34, where every module began in 32 and held 288 after its
first allocation past them. Since 2026-10-30 a program that allocates
nothing after its start declares those pages as its maximum too. The
constants that remain for a program that does allocate, a 2 MB journal, a
256-page grow step and a 4 GB ceiling, are the residue that §11.8's budget
and §11.1's exhaustion fact replace.

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
the compiler.

---

## §7 · What the artifact has not reached

§4 and §5 describe the target in the present tense. This section says where
the pinned compiler falls short of it, and where the two disagree, this
section is correct. Each entry says what is missing or false, the command or
program that shows it, and the §11 design that closes it. An entry leaves
when its design lands. What was built, and when, is `git log` and
`boot/PROVENANCE.md`; the accounts of landings that stood here until
2026-11-10 are in this file's history, at commit eefdcaaa. A count is read
from the command that prints it and is not written here. A gate that did
not run counts as unknown, never as passing.

**Programs the check accepts and the run breaks.** Four false proofs are
open, each run again on pin b46b71133838 on 2026-11-10. `mentl check`
accepts each program and `mentl run` shows the break.

- A `!Trap` recursion a million calls deep stops with "call stack
  exhausted": running out of stack is a trap that no row shows (§11.2).
- A handler of `trap` takes `Trap` out of the row while `trap` still stops
  the machine, so `main with !Trap` over a deliberate trap is accepted and
  the run stops (§11.12).
- A function that picks a member of its own recursive group in an `if`
  publishes none of that member's effects, so `fn quiet() with !Name =
  r(5)` is accepted and the run performs `ask` (§11.1).
- A refinement claim left pending is assumed by its callee and checked
  nowhere when the program runs, so a read it proves can read outside its
  list; what a pending claim should cost is Morgan's open decision (§11.1).
- A wrong proof is caught only where a fixture asks for a witness build
  with `// witness: N` on its first line, as
  tests/micros/mn-witness-proven-read-stops.mn does. No battery builds its
  other fixtures that way, and no verb builds a witness outside a battery
  (§11.B). A witness build keeps the checks of reads, cuts, divisions and
  conversions. It does not check a pattern's claim or a refinement, and its
  stop names the library's line and not the proven place (§11.10).
- The one count of wrong proofs is a single night's, taken with probe
  compilers that nothing keeps (2026-11-10, on the source pin ed44d08f50e7
  was built from). Built as witnesses, all 640 fixtures
  that state `// expect: N` answered their contracts (465 in tests/micros,
  154 in tests/frontier, 21 in tests/syntax). The twelve lessons, the two
  scores and the two hello programs each exited as their plain build does
  and wrote the same bytes. The compiler built as a witness compiled itself
  without stopping, and the module it wrote equals the one that built it.
  The probes: the compile in `battery_step`'s `ExpectRun` arm, then the one
  in `compile_run`, each put under `~> proofs(ProofsWitnessed)`. The count
  is zero for the proofs a witness build checks, and it says nothing of the
  four false proofs above, which a witness build does not check (§11.B).

**Claims and proof.**

- The course and the two scores do not check clean: `mentl verify` counts
  the programs the medium owes in each. A Nyquist bound that reads the
  installed rate inside its predicate is left pending (lesson 6). A
  division by a value nothing bounds charges `Trap` (lesson 7, Pulse). A
  frequency computed from a sine or a product is a claim the verifier
  cannot decide, since it decides integer ranges and no Float range
  (§11.3).
- The compiler's own claims are mostly open. `mentl check src/main.mn`
  prints its pending claims, nearly all of them the bounds of an index read
  or a cut. `mentl verify` prints three counts of that debt: open
  obligations, claims left open at explicit calls, and places that can trap
  with no claim. No command says how the counts relate (§11.3, §11.10,
  §11.13).
- A claim proven only through the program's calls leaves the `Trap` in the
  row, so `with !Trap` cannot rest on it yet (§11.3).
- The judgment charges `Trap` at a call of `str_eq` and none at `==` on two
  strings, which runs the same function. `mentl why FILE F Trap` says a
  function that compares with `==` never uses `Trap`, and the module it
  compiles to calls `str_eq` (a scratch program, 2026-11-10). The
  comparison cannot stop a run, since `str_eq` reads only below the two
  lengths it found equal, but the judgment has not proven that, so one of
  its two answers is unproven. The compiler's own source still calls
  `str_eq` by name where SYNTAX says a developer writes `==` (`mentl query
  src/main.mn "refs of str_eq"`; §11.13).
- The traps facet does not follow the arms of a handler a function
  installs. It calls the grid controller's one remaining trap `main`'s own,
  with no path, where `mentl why examples/grid/station.mn main Trap` traces
  it into the library (`mentl query examples/grid/station.mn traps`;
  §11.1).
- `mentl teach` proposes locks, preconditions and lifts and little else,
  and lists every function's step in source order with nothing ranked
  (`mentl teach examples/pulse/course/07-bounds.mn`; §11.5).
- A refusal offers no fix. A dropped value goes unreported outside the
  stage of `each`. Accepting a proposal is not one write at the hole's
  node, and its provenance does not outlive its process (§11.5, §11.6).

**The row.**

- Absence is proven per effect and per instance, never per install. Two
  installs of one instance are one fact to a negation, and no row reads
  the link from a perform to the install that answers it (§11.1).
- Every list stage carries `Alloc`, `Trap` and `Diverge`, so a pipeline
  over a list is refused where the same work as an index walk is accepted:
  `fn energy(xs) with !Alloc = xs |> map(square) |> fold(0, plus)`
  (§11.13). Early exit cannot be written: `any`, `all`, `find` and `take`
  visit every element (§11.7).
- A recursion by a counter, a cycle of two functions, a loop that ends when
  a handler's state reaches a bound, and the float printer's walks perform
  `Diverge` (§11.1).
- A handler of `Alloc` is always lowered as an arena, and its arms never
  run (§11.12).
- No Mentl program can reach a network, so every `!Network` is true by
  construction: `mentl query examples/grid/station.mn "provider of fetch"`
  answers that no handler declares an arm for it (§11.14). The clock's real
  handlers do not build, and its test handlers answer the same values on
  every run (§11.11).

**Memory.**

- Without a footprint claim on `main`, the arena journal (2 MB), the grow
  step (256 pages) and the ceiling (4 GB) are the compiler's own constants.
  A program that opens an arena starts in 34 pages for that reason; `mentl
  < FILE` prints a program's footprint line (§11.8).
- No course lesson has a constant footprint. Each allocates its file's
  buffer after the start, at a size it computes when it runs (§11.2).
- The compiler yields, so it keeps every list-store barrier, and none of
  its arena exits is proven root-free. `mentl query src/main.mn "census
  arena-unknown"` lists the installs whose roots the judgment left unknown,
  each with the write it could not place (§11.8).
- A part read off a value out of sight, a list's element above all, is
  read as older memory, because the judgment keeps nothing of what a store
  put into an allocation. `mentl verify` counts the values the verifier's
  walk cannot place (§11.8).
- A join, `xs ++ ys`, is read as memory the walk cannot follow, so a
  function whose answer is a join answers older memory: `mentl query
  src/main.mn "claim of int_to_str"` says `returns: older`, and every use
  of such a function counts as a value the walk cannot place. The function
  a join calls, `list_concat`, already claims what it answers: one of its
  operands, or a new node that holds both. A probe that read the join by
  that claim placed 1,732 values and passed every battery; it is written
  out as the payment of §11.B's box, with the fixtures it still owes.
- An arena opened inside a spawned branch sometimes keeps its region. The
  frontier leg that expects it reclaimed fails about one run in thirty
  (§11.B, "First, a check that fails at random").
- A resume does not restore host resources. Resuming on another machine
  and a session that outlives its process are open (§11.6).
- SIMD and GPU schedules run their branches one after another. A branch
  that answers a Float traps at a thread's join (§11.2). The compile is
  sequential, and forks run one at a time (§11.8).

**The graph and the lowering.**

- A type, a `Reason` and the lowered program are value trees. The lowered
  program is identified by its symbol, so the emit's reach walks key their
  units by spelling (§11.2, §11.3).
- An arm's resume grade and a callee's tail facts are read by spelling and
  derived again for every reader. The emit cuts a list rest, names an arm's
  kind and writes a schedule's performs by spelling (§11.2, §11.3, §11.4).
- A scheme is a value: a declaration's type is frozen at its exit and
  copied at each use (§11.3).
- Each mechanism is built more than once. Every interprocedural fact keeps
  a ledger of its own, some keyed by spelling. Absence, the effect-enters
  chain, the race rule, the schedule's demand, the edit cone, `refs of` and
  `unreachable` each walk the edges in their own way. The graph has one
  projection, the WAT emit, and no reference meaning to check it against
  (§11.1, §11.2, §11.3).
- A module's init stores only what one binder names: `let (a, b) = (3, 4)`
  at module scope is refused as an internal invariant. A module value that
  holds a partial, `let inc = plus(1)`, passes the check and stops the
  emitter (§11.2).
- An edit's cone has no cutoff: every declaration whose judgment read a
  rewritten one is judged again, whether or not what it publishes changed.
  A session derives its graph once each time it opens (§11.6).

**What a person meets.**

- A module sees its whole import closure, so a user's `fn count` is
  refused as a second declaration of the library's, and the refusal does
  not say where the first one stands (§11.4).
- A default arm over a sum is refused, and the refusal says to let `mentl
  tighten` write the roster. The five operators do not share one
  precedence level. A pair does not fill a two-parameter stage (§4⑩, §4⑪,
  §11.13).
- The wheel is not written the way SYNTAX asks. `mentl query src/main.mn
  census` counts its `match` sites, rosters, index walks and operator
  sites; the board bounds the rosters and the index walks and nothing else
  (§11.5, §11.13).
- An effect operation's parameters have no names. A type name that
  resolves nowhere is refused as arithmetic on it. A label on a sequence
  primitive's argument is refused as unknown (§11.3, §11.5).
- The verbs' own defects, found by running each one, are listed in §11.5.
- A tuple pattern written as a parameter of a module-level function builds
  and runs, and its head does not print back as one declaration. `mentl
  query FILE heads` counts it, and the landing pass refuses a pin over it
  (§11.5).
- `sin(3.0)` is 9e-9 from its value (§11.7).
- The page cannot play a lesson (§11.6).
- A Mentl program runs only as WebAssembly, under an engine with tail
  calls. The landing pass, the march and the batteries' host loop are shell
  scripts under tools/ (§11.9).

**Comments and documents.**

- Code in a comment is not judged, an `Hβ.*` label in the source is plain
  text, and a comment can silence a gate. `mentl verify` counts the
  comments that carry coordinates, commit hashes, spec citations, lifecycle
  prose, archaeology, banners and silencers, and none of those counts is
  falling (§11.5).
- `tools/doc-truth.sh` checks the pin, the verbs and scripts the documents
  name, their labels, every `§` they cite and the token enumeration's
  count. Nothing checks a number or a "today" sentence in a document
  against the compiler, which is how ten of this file's statements were
  found false on 2026-11-10, each by running the command it named (§11.5).
- SYNTAX describes the present state beside the language's surface, in
  sentences that say "today" and "not yet", although this section is the
  authority on the state (§11.5).

---

## §8 · Verification surface

```
mentl land [--quick | --board]      # the landing pass: this tree's compiler judged cheapest first, stopping at the first red — verify, march, frontier, proof-exactness, crown, effect identity, threads, ide — every verdict kept by the bytes it judged, pinned once; --quick = verify only; --board = the board on the pinned boot
mentl verify [path]                 # the standing bounds on the medium's own source (src/board.mn), read off one judged graph; a rise refuses
mentl check [path]                  # every module of the link judged, no emit; no path: the project
mentl query <entry> <question>      # type NAME · effects NAME · ownership NAME · why NAME [Effect] · flow NAME · claim NAME · where NAME · refs of NAME · provider of OP · writes of FIELD · reads of FIELD · variants TYPE · census [<shape>] · text NEEDLE · prose NEEDLE · owed <dir> · traps · decls · modules · imports · performs · env · heads · ghosts · cost · smt · reports · verification · unresolved · unreferenced · unreachable · orphan-claims; `<question> in MODULE` narrows a site question to one module
mentl why <file> <fn> [<Effect>]    # the declaration's reason, then where each effect of its row enters
mentl where <file> <name>           # a declaration's head, row, widths and address
mentl <file>:<line>[:<col>]         # the eight aspects at the caret, with the Lede
mentl map [<id, title or word>]     # the read path by part: PLAN and SYNTAX by heading and §11 step; a name serves one
bash tools/march.sh                 # the fixed point: boot→m2→m3, m4 on a difference, TRANSITION or BROKEN; MARCH_REPIN=1 pins
bash tools/march-gate.sh --micros   # the rungs and the micro battery through the boot's m2
bash tools/frontier-gate.sh         # what no fixture contract names yet: the verbs' text, the authoring workflows, the project routes (--compiler fresh for the current wheel)
wt_battery C.wasm tests/crown       # each leak refuses with its class, each sound twin is accepted
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

1. Read `MENTL_MEMORY.md` and `CLAUDE.md` whole and the map the session
   starts with (`mentl map`), then PLAN §0, the first box of §11.B and every
   part of PLAN and SYNTAX that box names (`mentl map <id>`). That is the
   entire required context.
2. Run `mentl land --quick`. Where the code and the prose here disagree,
   trust the code and fix the prose.
3. Take the first box of §11.B. If Morgan has not gated it, the work is to
   get it gated: run its failing measurement again, sharpen what is
   unclear, and ask. Before any edit, ask the medium about every structure
   the box touches (`mentl query`, `where`, `why`, `<file:line>`).
4. Build the box exactly as written, prove and pin it with `mentl land`,
   commit and push as CLAUDE.md's working loop says, and delete the box from
   §11.B in that commit.
5. A box starts from a written definition of done and the command that
   proves it, and every claim of progress is a command's output from this
   session, never a memory.

---

## §11 · The program — the one list of open work

This section is the plan. §11.B says what is done next, as boxes in the
order they run. §11.1 to §11.15 are the designs that later work builds.
Each design keeps its number wherever it stands, and it is cut into boxes
when its turn comes.

**How the list works** (Morgan's method, 2026-11-10). A box is one bounded
piece of work, fully specified in text before anyone builds it: what a
person will see, the measurement that fails today, the files and functions
it touches with their signatures, the edge cases, what it refuses and how,
what it leaves alone, and the command that proves it. Morgan gates each box
before it is built. A box is built exactly as written. A box that turns out
unclear or wrong is a stop: the builder reports it, the box is rewritten,
and Morgan gates it again. One box is in flight at a time. When a box
lands, its commit deletes it from §11.B, brings §7 up to date, and carries
the receipt in its message: the files changed, the output of the command
that proves it, and anything that was unclear.

**What comes before any order.** A false proof that a user can hit (§0's
property 2 failing on code that a real program contains) is fixed before
anything else, and the checks that verify every landing must stay reliable.
A real program is one in `examples/`, `lib/` or the wheel. A false proof
that only a probe or a test fixture reaches is measured and joins the design
that owns its mechanism, and its fixture becomes that design's failing
test. So finding a new case never moves it ahead in the order. A gap found
inside a box is a stop, never a second piece of work done on the side.

**The designs' own order** is the dependency order of the five mechanisms
(§4⑧; Morgan, 2026-10-23): each design reads only what an earlier one
built. The DSP arc runs before the fused oracle's last pin (Morgan,
2026-10-21), so §11.7 comes before §11.8. Each `Hβ.*` label names a design
as git records it. A file outside PLAN cites a design by its name (`PLAN
§11, the keystone`), never by its number.

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
whose walks read names). The keystone (§11.2) and the face (§11.3) remove
the last three.

**THE STANDING CURSOR**: the first box of §11.B is the next thing to do.

### §11.B · The boxes, in the order they run

One box is written out. On 2026-11-10 Morgan approved a night's work on
this branch ("I trust you and approve you to work through the night"), and
the builder read that as his gate on the boxes here, in order. Each
landing's receipt is his to review, and a box he did not mean to gate is
reverted on his word.

The boxes build one instrument. A false proof used to be found only when
someone thought to write the program that exposes it (§7). A witness build
keeps the checks the compiler proved away, so every program we already run
becomes such a program. Two boxes landed on 2026-11-10. The first built it
for one fixture at a time: a fixture whose first line is `// witness: N` is
built with every proven check kept. The second ran it over everything we
have and counted the programs that answer differently: none of 640
fixtures, none of the sixteen example programs, and not the compiler
compiling itself (§7 holds the count and its commands). The box below
makes that run part of every landing. The arena already works this way: an
extent the judgment proved root-free checks, at its exit, that no barrier
journaled inside it (§4⑨).

**What a box does to the board.** A box that adds code to the wheel raises
the two counts that grow with code: the values the memory walk cannot place
and the places that can trap with no claim (`src/board.mn`). Neither limit
may rise, so a box names what pays for its code before it is built: a class
of values the walk learns to place, or code that leaves because the new
form made it unnecessary. `MENTL_BOOT=<candidate> mentl verify` shows both
counts before the landing pass, and `mentl query src/main.mn "census
unplaced"` says beside each value what stopped the walk. The witness box
stopped at this on its first landing pass. It paid by teaching the walk
that a constructor with no fields is a word, which placed 890 values. The
next payment is measured and written into the box below: the join.

**First, a check that fails at random.** One leg of the frontier gate,
`tests/frontier/arena/spawning-module-runs-the-body.mn`, exits 1 where it
expects 42 in about one run in thirty, on the pinned compiler as on any
candidate, since both write the same module for it. In the failing runs an
arena opened inside a spawned branch keeps its region, so the leg's
`arena_stat(ArKept) == 0` is false: of 1,000 runs on 2026-11-10, 32 failed
in both branches and 4 in one. The landing pass stopped on it once that
night and passed on the next run. An unreliable check comes before any
order (§11's second rule), so this is settled before Box 1 is built.

The cause, read from the module the leg compiles to. In a module that
spawns, every instance takes its memory from one shared line, a chunk at a
time (`$seg_refill`: 64 KB, or the size asked for where that is larger). An
arena's exit reclaims only a region that is one span of the instance's own
chunks, and `$arena_sweep` keeps the region in two cases that depend on the
other instances: the instance took a chunk during the arena that did not
follow its last one, because another instance had taken a chunk in between
(`m < $seg_base`); or the exit's copy space does not fit and the chunk
cannot be extended, for the same reason (`$seg_extend` answers 0). The leg
meets the first case by construction. The first arena an instance opens
allocates its 2 MB journal, which is one chunk filled exactly, so the
arena's mark stands at the chunk's end and the body's first allocation
takes a new chunk. When the other branch takes a chunk between those two
allocations, the region is kept. Keeping is sound, and it costs the
branch's memory until the instance ends.

Morgan's to gate, since it says what a spawned branch's arena promises.
Two forms settle the leg. (a) The leg asserts what holds today: each
branch counts an exit and answers the right sum, and the root, which runs
alone after the join, counts an exit, keeps nothing and frees memory; §7
then holds that a spawned branch's arena can keep its region, closed by
the landing that gives each instance a memory of its own (MENTL_MEMORY.md,
"Two memories"). (b) The runtime takes a fresh chunk before an arena's
mark when the current one is nearly full, which makes this leg's small
arena reclaim on every run and leaves an arena larger than a chunk as it
is. The builder recommends (a): (b) grows the shared line's mechanism,
which the two-memories landing deletes, and it would make the leg pass
while the property it names stayed untrue for larger arenas.

1. **Box 1 · Every battery runs each `// expect` fixture both ways.**
   Gated with the night's work (2026-11-10). The count it waited on is zero
   (§7). It needs the check that fails at random settled first. Two parts
   of its form changed after the gate, by what was measured that night, and
   are marked "for the gate" below.

   What a person sees. `mentl land` turns red when a proof is wrong on any
   fixture: every fixture that states `// expect: N` is built twice, once
   trusting the proofs and once keeping their checks, and both runs must
   answer its contract.

   Fails today. A wrong proof on a fixture passes every gate unless the
   fixture's answer happens to depend on it.

   The form. In `battery_step`'s `ExpectRun` arm (`src/main.mn`), after the
   trusted compile, the module is compiled again under `~>
   proofs(ProofsWitnessed)` to `battery_wat_path` of the stem followed by
   `~w`, and a second line `RUN <stem>~w` follows the first, with the same
   exit and the same line a stop must say. In `tools/wt-env.sh`,
   `wt_battery`'s count of the fixtures it saw leaves out the verdicts
   whose stem ends in `~w`: one line replaced and none added, so the count
   still equals the directory's files and a failing witness run still
   counts as broken.

   For the gate: the box first said the second run happens only "where the
   two texts differ". Of the 670 modules the micro, frontier and syntax
   directories compile, 639 differ between the two builds, because the
   library every program links holds proven reads. Comparing two texts to
   skip one run in twenty is code the measurement does not pay for, so the
   form above runs both builds always.

   What it costs, measured 2026-11-10 on the micro battery: 1 min 54 s with
   either build alone, of which the compile step is 1 min 42 s and the
   host's assemble and run step 12 s. 470 of its 779 fixtures are run
   fixtures, so building those twice brings it to about 3 minutes, and the
   landing pass gains about a minute and a half over its three batteries
   that run programs. The second compile judges the fixture a second time.
   Judging once and lowering twice would cost less, and it is not this
   box: it needs the lowering to be a column of the graph (§11.2).

   What pays for its code on the board. For the gate: the memory walk
   reads a join, `xs ++ ys`, as the call of the function its node is linked
   to, `list_concat`, by that function's own store claim (`returns:
   parameters 1, 0`: the join answers one of its operands or a new node
   that holds both). A probe built it in three places and was removed; its
   patch is 148 lines.
   - `src/graph.mn`, `stops_of`: the `BConcat` arm answers `[StopCall(h, h,
     [l, r])]` where it answered `[StopBeyond(h)]`. The join's node stands
     as its own callee, since the judgment links it to the primitive.
   - `src/verify.mn`, `call_roots`: a callee that is a join is read by the
     claim, as a named function is. The claim-reading arm becomes a
     function, `claimed_roots(memo, call, callee, args)`, that both use.
   - `src/infer.mn`, `call_targets` and `call_holds`: the same, through
     `claimed_targets` and `claimed_holds`. A join inside the group that
     declares `list_concat` stays older memory, as today.
   Measured on the probe: the values the walk cannot place fall 33,771 ->
   32,039 (1,732 placed) and every other count is unchanged; the compiler
   reproduces itself (m2 equals m3); micros 779 of 779, crown 191 of 191,
   frontier 219 of 219, syntax 21 of 21 and the frontier gate's 369 legs
   pass. It costs 11 KB of the self-compile's line peak (285,125 KB against
   the pin's 285,114 KB on the same source), paid as the last walk fix was,
   on one dated line closed by the next commit. Three fixtures in
   tests/micros attack it and hold on the pin and on the probe, where
   `mentl query FILE "claim of joined"` says `returns: parameters 1, 0`
   and the pin says `returns: older`: `mn-arena-join-answers-older-operand`
   (the left operand is empty, so the join answers the older right operand
   and a young value stored into it must outlive the arena),
   `mn-arena-join-left-operand-older` (the same with the right operand
   empty) and `mn-arena-join-of-young-moves` (a join of two young lists is
   the arena's answer, and another is stored into older memory).

   Left alone. A proof on a fixture that states another contract (`//
   check:`, `// expect: refuse`) is not built as a witness. No verb builds
   a witness outside a battery.

   Proves it. `wt_battery` on each test directory reports the same count of
   fixtures as before, and a fixture with a wrong proof, placed in a scratch
   directory, prints `FAIL(run)` for its `~w` stem.

**Next, in the order proposed.** These are not boxes yet. Each is cut into
boxes when the ones above have landed, and Morgan reorders the list by
saying so.

- The library's list walk is settled once, so a pipeline stands where a
  claim is checked. The failing test is `fn energy(xs) with !Alloc = xs |>
  map(square) |> fold(0, plus)`, refused today while the same sum as an
  index walk is accepted (§11.13). The boards and the rewrite of the wheel
  in its own idiom both wait on it.
- A default arm answers the empty value, and `mentl tighten` stops writing
  rosters (§4⑪, §11.13).
- A pair fills a two-parameter stage, the five operators share one level,
  and the formatter writes one stage per line (§4⑩).
- A pending claim is said in the developer's words with what would
  discharge it, lesson 7's four lines first. `mentl teach` ranks its steps
  by what each unlocks. A refusal offers its proven fix, one class first
  (§11.5).
- A claim's verdict is a fact at its node (§11.10).
- The host's clock, randomness and sleep are real (§11.11). With it comes
  the first run of the whole medium on a small Linux machine: the engine's
  probe (`bash tools/wasmtime-get.sh probe <engine>`), the compiler
  compiling itself, and a lesson through the speaker.
- An extent can end early (§11.12), then the soundness core (§11.1), the
  component target (§11.14), a seeded world (§11.15), and the keystone and
  the designs after it in their dependency order (§11.2 to §11.9).

One decision of Morgan's stands open and gates the soundness core's form:
what a claim left pending costs when the program runs (§11.1(b)).

### §11.1 · The soundness core: the crown modal, the row whole, the reach one walk

(a) The crown, made modal (`Hβ.effects.modal-world-index`). A row
names effects: `EffName` carries a name and its arguments, and a
`RowEdge`'s mask names effects. Since 2026-11-06 an install's frame mark
carries the install's node and a perform is linked to the install that
answers it, but no row reads that link. So absence is proven per
effect, never per install. The form: an effect in a row is indexed by
the install that answers it (`E@h`, the install node the judgment resolves when it draws the
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
(`Hβ.effects.sound-neg-under-poly`). A negation binds the handlers that
answer the function's own operations while it runs (built
2026-10-30); the install finds the negating declarations by a climb of its own,
which the reach (c) replaces. A function of the caller's own recursive
group keeps its effects where a use hands it on (built 2026-10-30),
but not where a use first meets its row with a closed one: in `fn r(x) =
{ let g = if x > 100 { plain } else { e }; g(x) }`, with `plain` Pure
and e, which calls r back, asking for a name, the `if` binds e's
pre-registered row to `plain`'s and e's judgment replaces it unchecked,
so `fn quiet() with !Name = r(5)` checks, where the same `if` is
refused when e is not in a group with r (a list `[plain, e]` likewise).
The bind must become a cap the member's exit judges, and it must tell a
use's bind from a Mycroft round's own: a cap taken from an earlier
round's row refused the compiler's own flow walk in verify.mn
(`handed_of`, `slot_flow`, `escape_hand`, `reached_of`, `escape_apply`
among them, measured 2026-10-30). The compiler's own `render_row`,
written as `vs |> map(render_row_edge) |> unique |> join(" + ")`, is
still published without the `GraphRead`, `TypeRender` and `Intern`
that `render_row_edge` performs (measured 2026-10-30 on the group of
`show_reason` and `enters_tail`), so it stays written as a call of
`show_list`.
(b) The row is complete: every way a computation can stop or reach outside
itself is a row fact the crown can negate. An executable's row is the row
of `main` and of its initializers; each op belongs to the effect that
matches what it does, the ops of a `*Read` effect write nothing (held at
zero by a census), word arithmetic is `Pure`, memory's writes are an
effect of their own, `MemoryWrite`, and a recursion that is no descent
performs `Diverge` (all built 2026-10-30). The measure reads part
edges alone. A cycle of two or more functions, a loop that ends when an
effect's state reaches a bound (the course's `play`, which runs until the
clock reaches its frame count), a list halved by slices (the prelude's
`sort`), an interval narrowed by a search (the sorted-set helpers in
lib/strings.mn), a counter (`split_walk`, the float printer's walk by
decades and its power countdowns), and every list stage's walk by an
index still perform `Diverge`. The list walk's index goes when a stage
reuses the owned list it consumes, and the float printer's when it reads
digits off a float's bits. A refinement claim left pending is assumed,
and nothing checks it when the program runs. Inside a function a
parameter's refinement is assumed, so a read or a cut it proves runs
without its check, and a caller that cannot prove the refinement carries
the read's `Trap` (2026-11-06); but the run never stops there, so
with no `!Trap` promise it reads outside the list:
`fn at(xs, i: NonNeg) = if i < len(xs) { list_index(xs, i) } else { 0 }`
called as `at([4, 5], k - 3)` with k = 1 answers 2, the list's length
word. Where no proof leans on the refinement, the type holds a value it
excludes: `fn keep_small(n: Small) = n` under `type Small = Int where 0
<= self && self < 10`, called as `keep_small(x + 1)` with x = 12, answers
13, and `mentl query FILE traps` says nothing can trap (both measured
2026-11-06). What a pending claim costs when the program runs is not
decided, and the decision is Morgan's. SYNTAX's refinement section says
the predicate is erased and no check runs. The alternatives are a check
where the claim is pending, wherever its predicate performs no effect,
so the run stops there and that site's `Trap` is the one that happens;
or a refusal to build. A label, whose predicate is an effect's
operation, stays a claim the flow walk decides under each of them.
(c) The reach is one walk (`Hβ.graph.reach-is-one-walk`): `reach(from, edge kinds, stop)`, cached as
columns, answers absence, the effect-enters chain, the race rule, the
schedule's demand, the edit cone, `refs of`, `unreachable` and the
Severance Map's bands, each keyed by edge and none by spelling. Each query
first gives the same answers as its own separate walk on the wheel and the
batteries, and then the separate walks are deleted. Memory's question,
which allocation a value may be, is one walk since 2026-11-05; the
eight queries follow, one landing each. A merge stage's slots are the
fanout's boundary result cells, not the parts' own values, so a claim
over them prints as `<expr>` and nothing proves it: `fn m(xs) with !Trap
= if len(xs) > 5 { ((xs) >< (5)) |> list_index } else { 0 }` is refused
although the guard proves the read (measured 2026-11-06); the walk
follows a boundary result cell to the value its branch answers. The
traps facet (2026-11-06)
is a ninth: it walks a function's body and not the arms of the handlers
it installs, so a trap reached through an installed handler counts as
the installing function's own, with no path into the library (`mentl
query examples/grid/station.mn traps` says so of `main`, where `mentl
why examples/grid/station.mn main Trap` follows the arm into
`print_string`).

### §11.2 · The keystone: lowering is a column, and the graph gains its evaluator

(`Hβ.lower.lowering-is-a-column`, `Hβ.lower.the-evaluator-is-a-projection`).
Lowering becomes columns on the program's own handles, and the `LowExpr`
tree and its walkers are deleted. A lowered unit becomes a column on its
declaration's handle. Today its identity is the symbol `LFn(String, …)`
carries, and the reach walks of the emit and of the reading
(`plan_reached`, `reach_units`) key their units by that symbol. The gate
is m3 == m4 with the symbol-keyed walks deleted. The self-compile's memory
peaks where the emit plans the module, at the list of twin records
`plan_reached` builds (the place the march's arena line named on
2026-11-05), so twins keyed by handle are where that peak falls. A `Reason` becomes an
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
a `><` that answers a Float under `parallel_compose` traps at its
join. A pair passed to a one-parameter literal and two arguments passed to
a two-parameter function use one calling convention. A handler named as a
value is its record: `let h = one` binds it, a parameter holds it, and an
install of a value pushes the record it holds and absorbs the effect its
`Handler(P, A)` type names. Today the value's emit names a global that
nothing defines. Each charge follows the representation from the day the
lowering builds it, so `!Alloc` accepts code that allocates nothing.
A module value that holds a partial of a declared function, `let inc =
plus(1)`, makes the emitter stop with a trap ("a precondition failed at
backends/wasm:4533:11") while `mentl check` accepts it: the emitter
writes a static closure record for it as though it were a function of
the table, and it is a value global. A partial of a sequence primitive
written with a `??`, `let cut = slice(??, 0, 2)`, is never built as a
closure, so its hole is refused as unresolved while `mentl check`
offers proposals for it (both measured 2026-11-06).

### §11.3 · The face: every declaration publishes one, and verification reads it

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
that face, owed at every explicit call the way `xs[i]`'s is (a read's and
a cut's). `make_list`'s count and `list_set`'s index raise no claim
yet. A stage a pipe completes owes its call's claims since 2026-11-06.
A call's answer
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
read as what its calls pass it (`Hβ.verify.parameter-is-what-its-calls-hand`),
and a claim every call proves leaves the program's debt. What
remains is the row, which still carries the `Trap` the judgment charged
where the claim was open, so a `with !Trap` cannot yet rest on a proof
through the calls. A label's
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
The four sequence primitives' face carries parameters with no names, so
`slice([1, 2, 3], start = 0, end = 2)` is refused with "no parameter
named `start` on `slice`" while `mentl where` prints the declaration's
names; the face takes its names from the declaration it stands for. A
list parameter's stated length is not read when a cut's or a read's
bounds are decided: `fn cut(xs: Big) with !Trap = slice(xs, 5, 9)` over
`type Big = [Int] where len(self) >= 9` is refused, and a caller's
ten-element literal leaves `9 <= len(...)` pending. A parameter's default
is judged and run in the caller's frame: `fn g(a, b = a * 2)` is refused
with E_MissingVariable at `a`, and a held partial runs its defaults
once, where it is built; a default belongs to the callee, with the
earlier parameters in scope (SYNTAX's "Default parameter values"). All
three measured 2026-11-06.
The step's gate is that the
course and the two scores check clean, the `QOwed` bounds fall to zero,
and the wheel's open obligations fall with each piece.

### §11.4 · A module is a scope, and a package carries its judgment

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

### §11.5 · A refusal is a hole

(`Hβ.diag.a-refusal-is-a-hole`). One proposer loop
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
is refused as arithmetic on `Nope` (measured 2026-10-21). A bare install
of a handler whose configuration parameter has no default is refused with
the arity text "function arity mismatch: 1 param(s) vs 0 param(s)", where
the refusal should name the parameter and say to write its value
(tests/micros/mn-install-config-without-default-refuses.mn, 2026-11-06).
An install written with an argument list that leaves a configuration
slot open, `twice() ~> counting()` where `counting` takes `step`, is
judged as an ordinary partial, and the emitter stops at an internal
invariant naming a shape number; it is refused where it stands, as the
bare install is. Labels at a call whose callee is a function value
resolve against whatever parameter names the value's type carries, the
first function unified into it, and are dropped without a word when it
carries none: `fn app(f) = f(b = 3, a = 10)` hands minus 3 and 10 in
written order. Labels there are refused (E_UnknownArgLabel), as they are
on a held partial. Two labels for one parameter are accepted, the second
replacing the first, and the parameter nobody named becomes an open slot
(`plus(a = 1, a = 2)`); the second is refused where it stands. A function
spliced into a string prints its raw machine word (`"{double}"` prints
4456), and `"{double(??)}"` builds and prints a closure's address; a
splice of a function value is refused, which refuses the hole too. The
proposer offers fills at a slot a pipe or a share fills, though writing
one turns the stage into a complete call the pipe refuses; it offers
nothing there and says the pipe fills the slot. It also lists the
parameter the parser mints for an arm-list literal (`__al` and a number)
as a value in scope, which no source can name. A parse error's recovery
makes the node an authored `??` makes, so the compile reports holes at a
`=>` and a `}` nobody wrote, with `mentl accept` offered there. A share's
bare `??` branch and a merge's `??` part are reported twice, once for
each time the lowering reaches them. `mentl why` names "a guard a
callee's precondition hands to its caller" whenever the body does not
show the effect, even where the effect comes from a default argument or
the body still holds a hole, and says a function never uses an effect
when its row, to which a hole adds nothing, lacks it; at a hole it says
the hole's row is not known yet. All measured on 2026-11-06 by running
programs against the pin.
The verbs themselves, each run on pin b46b71133838 with its whole answer
read (2026-11-09). `mentl teach src/main.mn` stops after 67 seconds
saying memory is exhausted, at 4.2 GB. `mentl check` and `mentl teach`
with no path, run in a project folder that lies under this repository,
judge the compiler and never the project. A bare `mentl` waits without a
word while its input is open. `mentl --with` finds the handler it is
given and says it cannot install one. `mentl tighten` needs a second run
when a clause and a catch-all both change, and says "NOT written" with
exit 0. `mentl resume` refuses the image lesson 12 saves, as not this
build's, though `mentl run` with `resume` reads it. `mentl repl` prints
no answers. `mentl query` answers an unknown question with exit 0 and
cannot list its questions; `ownership NAME` answers a count of
parameters, and `unresolved` a count with no sites. `mentl rename`
reports two names written for three changed lines. `mentl edit` prints a
placeholder where its Why belongs. The gate's server names its version
"first-light". A session answers `where` and `query` and misses on
`why`. The prelude imports `threading` and uses nothing from it, which
`query imports` marks DEAD.
A dropped value
is reported (`Hβ.infer.statement-value-is-dropped-silently`). A block's
non-final statement whose value is a function is refused
(`E_DroppedValue`). A non-unit word or aggregate is reported without being
refused until the wheel's census reaches zero, and refused after that.
`let _ = e` is the explicit discard.
Teach lists what the program still owes
(`Hβ.teach.teaches-what-the-program-owes`). It works out the next step
for every function, which is what choosing among the steps needs, and
ranks them by what each unlocks, as the gradient was designed (DESIGN.md
of 2026-03-23, the gradient walkthrough of 2026-04-22): the step that
unlocks the most for the code at the caret comes first, and nothing is
offered where no step unlocks anything. Today `mentl teach` lists every
function's step in the order the functions are written, with nothing
ranked (`mentl teach examples/pulse/course/07-bounds.mn`). It proposes a refinement at a
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
the board. fmt
writes the sequence fanout `xs >< f` without branch parentheses where
its own module declares `f`, since it reads the parse and no judgment;
a stage the module only imports (`xs >< int_to_str`) keeps the branch
layout `(xs) >< (int_to_str)` until fmt reads the judged graph's
boundary cell, which decides the form.

### §11.6 · Edits cost what they change, and the page plays the course

The
edit's cone gets a cutoff (`Hβ.session.edit-cone-cutoff`): a declaration
whose rewritten dependency publishes the same face is not judged again.
Today an edit to `chain_spelling`, which a third of the wheel's functions
read transitively, judges 1,767 declarations, about what a cold judgment
costs, while an edit to a leaf judges seventeen. The
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
`name_set_prefix_contains` scan on every lookup. The
self-compile's wall time and peak memory ratchet down. The wall time is
read as a share of the boot's on the same wheel, since a single wall-time
reading reflects the machine's load as much as the compiler.
The page plays the course (`Hβ.space.the-canvas`,
`Hβ.emit.the-medium-assembles-its-output`, `Hβ.viz.severance-map`). The
course is written: `examples/pulse/course` holds twelve lessons on one
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

### §11.7 · The verbs are whole, and the DSP arc

(`Hβ.verbs.the-verbs-are-whole`).
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
`compute_alpha`'s `exp` runs per tick in every filter). `sin` and `cos`
reach f64 precision on their reduced range: today eight terms on [-π, π)
leave `sin(3.0)` 9.4e-9 from its value (measured 2026-11-04, 337 million
units in the last place), so the reduction narrows to a quarter turn
before the series, which moves every render by that error. A `<|` or `><`
join aligns branches of known latency, with latency part of each stage's
face, or refuses the misaligned merge (measured 2026-10-21, after a survey
of Sonido). The prelude takes the datum last in every stage-shaped
signature, through step 5's reorder.
A unit of measure is part of a type (§4⑬). `Hz`, `Seconds`, `Samples` and
`Gain` no longer unify with each other, a product or quotient of units is
the unit it means (seconds times hertz is a count), adding hertz to a gain
is refused at the `+` with both units named, and a plain literal takes the
unit its slot wants. Today the course's and the scores' units live in names
and comments (`elevation_ft`, a 35 ms time constant written `0.035`), and
the judgment reads an alias as its base, so an `Hz` passes where a `Gain`
is wanted (measured 2026-11-05).
The derivative reading's remaining parts (`Hβ.derive.vector-forward`,
`Hβ.derive.gradient-as-a-value`, `Hβ.derive.transpose-through-iteration`,
`Hβ.derive.transpose-through-the-record`,
`Hβ.derive.bptt-priced-by-the-row`, `Hβ.derive.closure-line-tangent`). A
product seed is answered through a call made through a value, a perform, a
`<~` line, a record carrying a tangent, an install, an early return, a
query inside a callee and a recursion; today the reverse projection refuses
these and says to seed one Float at a time. A gradient held as a value is a
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
readings change. The judgment reads any one-parameter function value on
the left of `<~` as the recurrence, typing the site as its result, while
the lowering applies only a function literal there, so `acc(x = x) <~
delay(1)` is typed Int and compiled as a closure (measured 2026-11-06);
the left side is read as SYNTAX's `<~` part says, where a literal binds
the prior and any other value is fed forward.

### §11.8 · Forks on every core

(`Hβ.oracle.forks-on-threads`,
`Hβ.driver.level-set-par-walk`, `Hβ.native.deterministic-handle-partition`,
`Hβ.lower.schedule-through-a-value`, `Hβ.verify.the-solver-is-the-search`).
The compiler is still emitted as a module without threads (a defined
memory, a bump allocator, no spawn import), and this is the one pin the
fused oracle still needs. The module's memory is sized by the program.
The heap base sits where the static data ends and the first pages are
what the start needs (built 2026-10-29: a lesson with no arena begins in
two 64 KiB pages, the grid controller in 34). A program's memory budget
is a claim on main (built 2026-10-30: `with Footprint(bytes)` caps the
memory at the pages that cover the claim, gives the arenas' journal a
quarter of it up to 2 MB, and refuses a claim the start already
exceeds). A program that allocates nothing after its start declares
the pages its start needs as its maximum, so its claim is proven (built
2026-10-30). Still open: the journal is sized to the program's own arenas,
and a program that cannot prove its whole run fits its claim is refused
when it is built; today a run that outgrows its claim stops saying
memory is exhausted. Without a claim the journal (2 MB), the grow step
(256 pages, 16 MB) and the ceiling (4 GB) are the wheel's constants
(`src/backends/wasm.mn`), sized for a compile of the compiler. In a
module that spawns, an arena's exit copies its survivors past its region
and asks the shared frontier to extend its instance's run; when another
instance holds the next chunk, the extension fails and the exit keeps
its region (measured 2026-10-30: tests/frontier/arena/
spawning-module-runs-the-body.mn keeps in 3 of 40 runs of one module,
`kept 1, freed 0` in both branches, the answer unchanged). A private
memory per instance with one shared image removes the shared frontier
and this keep with it. A store keeps its barrier wherever the store-age walk
cannot prove its target is its own extent's, which today includes every
store in a module that yields: the judgment does not yet know which
frames can suspend between an allocation and a store, so the compiler,
which yields, keeps all of its list-store barriers. A handler's state
above an extent is read at the exit off the install chain, so it never
roots an extent through the journal (built 2026-11-05); an extent is
root-free through the journal when no list-slot or raw store it makes
targets older memory, and no arena in the compiler is yet, since each
stores nodes into the graph's columns. Placement first needs what each
allocation holds: the judgment decides every store into an allocation
and keeps nothing of what the store put there, so a list's element out
of sight reads as older memory (§7); a column of the values each store
puts into an allocation, written where the store is judged, places the
element and lets `list_index` answer a part of its list. The next fall
is the placement that allocates a published value where it will live
(MENTL_MEMORY's M8), after which the journal holds the unknown-edge
residue alone. A handle becomes an
`{arena, offset}` product
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
A split can be cancelled (§4⑬). When one branch of a `><` fails, or a
deadline passes, the schedule's handler stops the branch's siblings at
their next perform or allocation and reclaims their extents as an arena's
exit does, the split answers the failure, and the row says which branches
may be stopped. Today under `parallel_compose` every branch starts, the
join raises the first failure again, and the other branches keep running
and are never joined; no operation cancels a branch (read from the emitter
on 2026-11-05, not run as a program).
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

### §11.9 · `!Outside` closes

The native backend (`docs/NATIVE.md`, whose second
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
The proof travels to the host, and `docs/NATIVE.md`'s hardware handlers
are its final form. A module the compiler emits needs an engine with tail
calls and bulk memory, and threads only when the program starts one. The
board path is Mentl's own: no other repository's firmware and no outside
engine stands between the compiler and the chip. The native projection
emits the same lowering column as Thumb-2 for the Daisy Seed's Cortex-M7
and the RP2040's Cortex-M0+. The board's clock, codec and serial line are
handlers installed over `main`, one import per operation, the mechanism
step 7 names for configuration, and the reading reaches `decide` as a
record through those arms, never as text to parse. The first measurement
on a board, before any other change, is microseconds per reading and
memory after 300,000 readings, read by the program itself. The RP2040
(264 KB of SRAM, no FPU, 133 MHz) needs the memory landings first: a
module's memory sized from what its start needs (built 2026-10-29), the
journal and the grow step sized by a budget the program declares (step
8), and a proven constant footprint where the row says `!Alloc` past the
start (built 2026-10-30 for a program that allocates nothing after its
start; a size the program computes waits for step 2's evaluator, and
running out of memory as a row fact is step 1's).

### §11.10 · A claim's verdict is a fact at its node

Where the ledger or the
settle decides a claim, its verdict (open, proven, proven only through
the program's calls, refused) is written at the claim's node, beside the
claim the graph already keeps there (`graph_claim_note`), and every
reader reads the node: `mentl check`'s printout, the traps facet, the
editor's strip and teach's debt. The ledger keeps only the open debt it
prints and the claims the settle asks again. Red today: the strip and the
traps facet find a claim proven only through the calls by matching its
module and span against the ledger's lists (`verify_handed`,
`trap_owed_at`, `trap_decided_at`), which cost the board three places
that can trap with no claim and eleven values the walk cannot place when
the strip learned them (2026-11-06).

### §11.11 · The host's clock, randomness and sleep are real

The WASI boundary
leaves lib/io.mn for a module of its own. The emitter imports
`clock_time_get`, `random_get` and `poll_oneoff`; `clock_host` reads the
hour, `sleep` waits, and a deadline counts down from the clock it reads.
lib/random.mn gives the host's randomness and a seeded generator that
names its algorithm. Every capability module holds the host's handler, a
recorder, a replayer and models that say they are models, and no handler
answers from a table in place of the host. `mentl audit` calls a
function whose row reaches no host input deterministic. A row can name
the directory a function may touch (`with Filesystem("data")`), and a
file is an owned handle closed when the extent that opened it ends.

### §11.12 · An extent can end early, and leaves older memory as it found it

A
perform is answered by its nearest install, and the machine is only the
root: one fact says who answers each operation, read by the judgment and
by the lowering alike. A handler of `Trap` ends its extent: the memory
the extent allocated is reclaimed, its stores into older memory are
undone from the journal, which then keeps each old value, and the
install answers its value. So `main with !Trap` holds over a request
that fails, and the state the request wrote is the state before it. A
passed deadline and a failed branch of a split end their extents the
same way. The first measurement is in hand: the pinned engine does not
run WebAssembly's exception handling, which would cost nothing when
nothing fails (`bash tools/wasmtime-get.sh probe`, 2026-11-10), so on that
engine an early end cannot be an engine exception. Red today: a handler of
`trap` takes `Trap` out of the row while `trap` still stops the machine,
so `!Trap` is accepted and the run stops. And a handler of `Alloc` is
always lowered as an arena, its arms never run, so a program cannot write
an allocator of its own; the one fact about who answers an operation
covers that too.

### §11.13 · The roster leaves the page, and the index walks become stages

A
default arm over a sum is accepted where it answers the empty value of
the match's type, and refused otherwise. When an edit adds a
constructor, `mentl check` says so once at each default over it, and
`mentl tighten` writes defaults instead of rosters. The syntax tree's
products of more than two fields become records. Each sequence stage of
the library keeps its index walk in a nested function whose claims
settle at the stage's close, so its face says it never traps, and the
functions `census iteration` names become pipelines over their
sequences. The board's counts of rosters and of iteration costumes fall
with it.
Measured on pin b46b71133838 (2026-11-10): a pipeline cannot stand
where a claim is checked. `fn energy(xs) with !Alloc = xs |> map(square)
|> fold(0, plus)` is refused, because every stage walks its list through
`iterate` (lib/prelude.mn), which first calls `list_to_flat`, a copy for
any list not stored flat, and then reads each element by an index whose
bounds claim is pending wherever the prelude is linked; the same sum
written as an index walk is accepted. A pair cannot flow into a
two-parameter stage: `pairs |> each(f)` is refused with "function arity
mismatch: 2 param(s) vs 1 param(s)", though a pattern parameter, `fn
g((a, b))`, is accepted.
`census iteration` does not count a walk that counts down
(`branch_replay_verify`, src/infer.mn). The wheel's `match` sites rose
from 6,123 on 2026-10-27 to 6,748, against 1,044 `|>`, 5 `><`, 2 `<|`
and 1 `<~`; the board bounds rosters and costumes, and nothing bounds
the total.

### §11.14 · The WASI 0.2 component target, and a real network

Mentl emits the
component itself, the canonical ABI's lifting and lowering included, one
effect per WASI interface, and imports exactly what `main`'s row
reaches. `fetch` is answered over `wasi:http`, so a program can reach the
network and a negation of `Network` means something. A row names the
hosts a function may reach (`with Network("api.weather.gov")`), a socket
and a body are owned handles, and an asynchronous host call is a perform
resumed later.

### §11.15 · A seeded world

Each capability has a model that takes a seed and a
fault plan (delays, skew, failures). A verb runs `main` under the
models, checks the program's claims and stated properties at each step,
and on a failure prints the seed that replays the run exactly.

---

Excluded: MI300X execution and shared-everything threads, because of
hardware limits; and continuations the engine owns (wasmFX), because the
image cannot hold them (§4⑫).
