# Mentl — PLAN.md

> **The three documents.** `CLAUDE.md` is the method; this file is the
> substance — the thesis, the kernel, the resolved decisions, what the artifact
> has not reached and, in §11, the one list of open work; `docs/SYNTAX.md` is
> the surface, the authority on the language's form. Each truth has one home,
> and the others point to it. History is `git log`, the pin chain is
> `boot/PROVENANCE.md`, and the board's numbers are the medium's to report
> (`bash tools/state.sh`, `mentl verify`), never this file's. A landing that
> lands deletes its §11 paragraph and trues §7 in the same commit.

---

## §0 · What Mentl IS — the thesis (the north star)

**Mentl closes the gap between what a person means and what they are forced to
write.** That gap is where the bugs, the complexity and the frustration of
programming live — the first manifesto named it on 2026-03-15, and it has not
moved. A programmer thinks *"this reads a file, parses it, and might fail"* and
is made to write async-ness, borrows, error boxes and lifetimes: ceremony a
language demands to make up for what its compiler could have worked out. Mentl
does not close the gap by hiding the complexity or erasing the types. It closes
it by being smarter about inference: the medium carries every fact it can prove
— the types, the effects, the ownership, the refinements, and the reason behind
each — and the author writes only their decisions: what this code must never
do, what bound a value keeps, what width a number needs. A tool for thought,
not a tax on expression.

Mentl is not a programming language with good features. It is a **medium** — a
lens so clear the developer looks through it and sees their program, not the
language. At any position it says what is true there and why; at a hole it
proposes the next move it can prove; when two proven moves mean different things
it asks the one question that separates them instead of guessing; and picking it
up teaches programming itself. The programs are the means; **the developer they
become is the end.**

Five properties are what closing the gap means:

1. **Proof beats review** — what you claim, the medium proves or refuses, and
   nothing executes unproven, so whether a program does what its author meant
   never rests on someone squinting at it. Proof has no ceiling; review
   asymptotes.
2. **The negative is provable** — "this never touches the network", "this never
   allocates" is something people mean all the time and no mainstream language
   lets them say. `!E` says it, under polymorphism: absence under
   handler/install IDENTITY, under modality, under TIME, and per-INSTANCE
   (`!Sample(44100)`). **Mentl's most underrated arm.**
3. **Intent is lossless** — the Reason chain carries the *why* of every fact,
   walkable to the decision that made it; nothing the author meant is dropped
   between the page and the machine.
4. **Computation is durable** — a running computation is a value: a multi-shot
   continuation, persisted by copying the image.
5. **Systems explain themselves** — the cursor projects live truth at any point,
   so the medium answers the question rather than the author reconstructing it.

**What falls out, and is never the point.** A medium that proves what it runs
and never loses intent does both for every author. Code a person did not write —
a teammate's, a dependency's, a plugin's, a model's — meets the same proofs and
the same refusals, so trustworthy machine-generated code is a CONSEQUENCE of
building the ultimate language for people, never a goal beside it and never the
headline (Morgan, 2026-10-09). The convergence: the same choices return from
three directions — what makes Mentl *ultimate*, what *people* need, and what is
best for *the makers*. The Carried-Truth Law is one law at three scales: Mentl's
kernel never fabricates a fact it can read live; software must never hallucinate
its author's intent; Claude must carry real reasoning, never perform confidence.

**Arche and telos.** The **generative root is the kernel**: one graph, two
operations, `!Outside`. The **person is the telos** — proof wins whenever it
meets convenience because proof *serves* the developer better than an ergonomic
lie. The framing stays tethered to the developer at the keyboard: a sentence
that leads with machines has inverted the thesis, and `tools/doc-truth.sh`
holds every reader-facing door to §0's first sentence.

**`!Outside` scope** (§1): **toolchain reflexivity** — every lever to improve the
medium is already inside it. It does NOT close the **intent space** (specs are
born in the human's head) nor the **capability space** (Rice:
sound-and-incomplete, accruing honest `V_Pending` debt). One named residual
Outside: the internal correctness oracle (§11's frontier). An external solver is
not one — Verify's search is the medium's own (§11), and a solver outside it is
a proposer whose certificate the kernel checks, as a model behind `Synth` is.

`!Outside` is not a runtime effect beside `Alloc`, `Thread`, or `Flow`. It is
the closure verdict projected over the existing medium: if improving Mentl still
requires a tool, server, verifier, proposer, transport, memory model, or build
step outside Mentl, that edge remains open. Closing it means absorbing that lever
into the graph, rows, `~>` handlers, `TCont` worlds, image columns, or `mentl
space` — never minting a parallel feature named Outside.

---

## §1 · The fixed point — `!Outside`

A tool you can surpass has its means of improvement *outside* it (to beat X you
write Y). **The ultimate medium has no outside.** The compiler is a handler on
its own graph (self-hosting); the IDE is a projection; the proof system is the
kernel; the oracle is incremental computation plus one cached value; even
*designing* the medium is a `<~` loop folding back into its docs.

- **Unsurpassability is `!Outside`** — the medium's own negation primitive at
  topology altitude. As `!E` proves the absence of a capability, the fixed point
  proves the absence of an outside.
- **Closed over proposers** — any proposer (a script, a library's tool, a
  model) plugs in as a `Synth` handler whose candidates must survive
  checkpoint → infer → Verify → rollback before the person at the keyboard
  sees one. A stronger proposer strictly strengthens the medium and can never
  surpass it. The unit of conversation with the medium is the **constraint**
  (lossless, monotone, compounding), not the token (lossy, decaying). **Proof
  is a MONOTONE FILTER, not a generator**; the dispatch among survivors is
  human intent or a ranker behind the gate.
- **The medium is the best next-move proposer.** At cursor scope it proposes by
  GUIDED search over the typed graph (rows, Reasons, refinements, ownership,
  proximity), pruned by proof at every step — a structural prior richer than a
  token window. When survivors tie, it surfaces the ONE missing constraint (the
  teaching tie-break), never guesses.
- **THE CLOSED LOOP (Morgan, 2026-07-28):** the loop is the PERSON and the
  MEDIUM, and nothing else is needed at any scope. Three legs: next-move
  supremacy (guided search, extraction-optimal per §5); the question beats the
  guess (the teaching tie-break dissolves the underdetermined tail into proven
  next moves); the loop is felt (the fused oracle makes the cycle instant enough
  to live in). The `Synth` port stays universal by construction; the target is
  that nothing ever needs to arrive through it.
- **Validated from six directions.** Faust: verbs, no effects. JAX: handlers, no
  graph. Temporal: continuations, no types. Rust: ownership, no effect row.
  Effect-TS: effects, hostile host. Solid: feedback, no proof. **Mentl is the
  convergence point — the body none of them had.**
- **And from outside, by what the field cannot do** (surveyed 2026-09-21).
  *The soundiness ceiling:* whole-codebase tools stand on call graphs recovered
  by parsing, and the recovery is lossy — median recall 0.884 for static call
  graphs on real Java against a dynamic oracle (Sui et al., ICSE 2020); thirteen
  static tools missed 61% of dynamically executed methods across 1,000 Android
  apps (ISSTA 2024); the field names the concession "soundiness". Mentl's edge is
  DRAWN by inference, and `!Outside` leaves no dynamic escape hatch to be unsound
  about — not a better algorithm, a different substrate. *The decidability line:*
  Google's Capslock answers "what can this Go dependency do?", collapses
  reflection, cgo and `os/exec` to `ARBITRARY_EXECUTION`, and never claims that
  an unreported capability is absent, because it cannot; WASI's component model
  types capabilities as DECLARED, at the host boundary, whole-module. `!E` under
  polymorphism, transitively, per instance, is on the other side of that line.

---

## §2 · The kernel — one graph, two operations, eight arms

> **One graph. Two operations: draw an edge (write), project (read). There is no
> third.** THE UNIVERSAL AUDIT: *Is this fact computed, copied, snapshotted, or
> re-derived anywhere it could be read live? If yes, it is the bug.* The fix is
> always toward LESS code.
>
> **A verb DRAWS an edge.** `~> h` connects the install to handler `h`'s node;
> `|>` connects stage to stage; `<~` closes a cycle. Reading what an edge already
> connects **by name** (a ledger, an index, an env re-lookup) instead of
> following the edge is the canonical re-derivation. Follow the edge; read the
> live node; resolve a name once — at the writer, in its scope — or at the text
> boundary, where a person typed it.

**The irreducible bottom is not eight things.** It is the **graph** (nodes carry
values; typed edges carry types, effects, ownership, refinement, Reasons) and
two operations: **WRITE** = inference (the one writer, every edge justified by a
Reason) and **READ** = the cursor projecting the graph at a position. The graph
IS the program; source, WAT, docs, the IDE and errors are projections.

**The octopus is one nervous system with eight arms — not eight brains.** The
eight primitives are the **eight aspects of every cursor read** (= the eight
interrogations = the eight tentacles). Three of them — ownership, refinement,
gradient — are grown from the others ("ownership IS an effect"; the gradient is
derived; refinement is `Verify` plus a predicate): fewer axioms, identical reach.

**Every subsystem is the one read in a different mode** — there is no second
mechanism:

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

**The three deepest capabilities are the three AXES of the one read**, and every
primitive is interrogated against them (the generative audit, run alongside the
reductive one):
- **Memory = the SUBSTRATE.** One flat linear-memory image; every node and value
  a handle-addressed record; extents reclaimed by arenas. The **unified heap
  record** makes *handler = state = closure = evidence = continuation* ONE shape,
  so a continuation is a contiguous record and **durable execution falls out of
  the memory model** (`persist = memcpy`).
- **Multi-shot = TIME.** Fork (trail checkpoint), cache (the cursor memoizes live
  reads — "read live" is the semantics, "cached" the mechanism), persist
  (continuation to disk). Search, the cached cursor and durable execution are ONE
  primitive distinguished by which handler catches the resume (§4④).
- **Threading = SPACE.** Parallel cursors read the shared image and fork to
  per-thread trails; compile, IDE, prover and oracle search are the same graph
  read at many positions.

The cursor projected through {substrate, time, space} IS the subsystem table;
**the oracle FUSES all three** — N forked cursors on N threads over one shared
graph with per-fork rollback. The trail, the threads and continuation
reification are built; their fusion is §11's frontier.

**The eight arms** (project all eight at every cursor before a line): **Graph?**
(handle/edge/Reason) · **Handler?** (which projects this, with what resume
cardinality) · **Verb?** (`\|> <\| >< ~> <~`) · **Row?** (`+ - & ! Pure`) ·
**Ownership?** (`own`/`ref`, `Consume`/`!Alloc`/`!Mutate`) · **Refinement?**
(predicate / `Verify`) · **Gradient?** (annotation as input unlocking capability)
· **Reason?** (the edge for the Why engine).

---

## §3 · The bottom-up construction — every layer a mode of the one read

Each layer's shape is forced by the one below; a non-ultimate fundamental poisons
everything above it.

- **L0 · The graph.** Nodes and typed edges, live, flat-array O(1) chase,
  epoch-versioned, trail-backed for checkpoint and rollback. *Only inference
  writes.*
- **L1 · The value ontology** — **five node-kinds**: *word*, *sequence*,
  *product* (record; tuple = positional product), *sum*, *function*
  (closure-with-evidence). Everything else is a **view** (§4①).
- **L2 · Topology and cost.** The five verbs draw the shape; the Boolean effect
  row says what crossing an edge requires or forbids (§4②, §4③).
- **L3 · The dynamics.** Handlers with typed resume — the one mechanism,
  themselves graph content (installed via `~>`, typed by inference, projected to
  a backend). Multi-shot is the universal substrate (§4④).
- **L4 · The write.** HM inference, one walk, productive under error, every bind
  a Reason. Ownership, effect row and refinement are all inferred; authored
  annotations are constraints verified against the inferred (§4⑤).
- **L5 · The surface.** The minimal text that makes each kernel aspect reachable
  — `SYNTAX.md`'s domain. Annotations are inputs to the cursor, never the
  emergent property.
- **L6 · The felt experience.** The cursor as the gradient's argmax: the Why
  walk, `mentl where`, the verification dashboard, fine-grained reactivity — all
  the graph projected for a human. Co-equal, never an afterthought (§4⑦).
- **L7 · The closure.** `!Outside` / self-hosting: **the fixed point — the
  medium reproduced exactly by itself**, `m_n.wat == m_{n+1}.wat`, paired with
  correctness (a buggy compiler reproduces itself to a *wrong* fixed point, so
  the micros and the frontier are the other half of the check). §6 carries the
  mechanics.

---

## §4 · The resolved decisions — the kernel, not questions

*Decided 2026-06-18. Interrogate them still; the burden of proof is on the
challenger.*

**① Value ontology — five node-kinds, everything else derived.** `Bool` =
`False | True` (a derived ADT). `Int`/`Float` = *word* + representation gradient.
`String` = *sequence of byte* + text/interpolation view. There is one
sequence-concat, and the read picks the representation ("the proof becomes the
dispatch").

**② The verbs — five, validated from outside by Faust.** Faust arrived at four:
split `<:` ≡ `<|`, recursive `~` ≡ `<~`, sequential `:` ≡ `|>`, parallel `,` ≡
`><`. Merge folds into `|> merge_fn`. `~>` is the arm Faust lacks: **Mentl =
Faust's topology + handlers.**

**③ THE CROWN — rows with negation; modal is the TARGET, the graph is the
ROUTE.** Never trade away `!E`. The modal synthesis (Tang–Lindley line, POPL
2026, arXiv 2507.10301 — rows ≡ capabilities proven) is the unsurpassable-tier
target; its open burden is the NEGATION half. Row representation:
`EfRow(present, absent, tail)` with `EffTail = EtClosed | EtVar | EtAll`;
negation IS the absent field. The crown battery (`tests/crown/`,
`bash tools/crown-gate.sh`) is the soundness gate. The TIME axis is
`TCont(R, S, ResumeDiscipline, EffRow)`: the effect WORLD on the continuation,
unified as a row, discipline mismatch refused (`E_ResumeWorldMismatch`). The
modality is inferred and cursor-projected, never authored.

**④ Multi-shot is ONE substrate for five things.** Search (the oracle),
sampling, backtracking *and durable execution* are one primitive: a resumable
continuation, distinguished by which handler catches the resume. **Persistence
is a handler swap.**

**⑤ Ownership — inferred `own`/`ref`, held to the Hylo-quiet bar.**
Ownership as an inferred effect (`own` performs `Consume`; `ref` is a row
constraint; filled from use count). **If the developer has to think about it,
the inference failed.**

**⑥ Information flow is the influence walk, not a row element** (decided
2026-10-02). `!E` + `~>` already subsumes capability security; flow adds WHICH
value may reach a sink, and the graph already carries that relation: a
refinement is read along a value's flow edges, a handler's state is every value
written into it, and the parent edge gives control dependence. So a
classification is a refinement on a source's declared type (`-> Untrusted`), a
sink's demand is a precondition on its parameter (`exec(cmd: Trusted)`), a leak
is `E_RefinementRejected` at the argument, endorsement is a function whose
declared return states the stronger label, and an implicit flow is the ancestry
walk to a classified scrutinee. A `Flow(Src, Sink)` row element beside it would
be a second home for one fact. The proof says where OUTPUT may go, never what a
model does inside its window.

**⑦ The felt experience is co-equal — reactivity IS the cursor's `<~`.** The
cursor re-projecting on graph delta at the human boundary IS fine-grained
reactivity, incremental compilation and collaboration.

---

## §5 · real · felt · unsurpassable — three aspects of one ultimate form

These are not a sequence; they are three ASPECTS of the one form, written in
full. The `.mn` answers only to "what is the ultimate form?".

1. **REAL — it works.** End-to-end compilation, the battery green, the wheel
   emitting correct WAT at its own fixed point.
2. **FELT — the human surface (L6).** `mentl where`, `mentl why`, the caret's
   eight aspects, the gradient, reactivity — projections, never add-ons.
3. **UNSURPASSABLE — the frontier.** Modal effect synthesis (§4③), flow (§4⑥),
   durable execution as a handler (§4④), Verify's own solver, native and GPU
   backends, the e-graph — each a move *within* the medium.

**The felt endpoint.** A `??` is a typed CONSTRAINT: the cursor forks a finite,
latency-budgeted set of candidates, each run checkpoint → infer → Verify →
rollback on its own trail, and only proven survivors surface. The ranker reads
local intent (Reason chains, proximity, in-scope vocabulary); the tie-break
TEACHES. Verify commits to a decidable fragment or emits honest `V_Pending`
debt — never a silent assume-true.

**The optimality half** (Morgan, 2026-07-28): a proposal is extraction-OPTIMAL —
a survivor is an equality class the e-graph saturates under effect-aware
rewrites, extraction picks the cost-minimal member, the repr gradient pins
widths. Superoptimization as the default authoring experience.

**The fork/merge duality.** MEANING-space is explored by FORKING (candidates
conflict, so each needs isolation); FORM-space by MERGING (e-graph members mean
the same thing, so saturation needs none). Proof is a filter over meaning; cost
is an order over form. **A tie in form is free; a tie in meaning is a question**
— which is where the human is irreplaceable, derived rather than asserted.
Prove-then-extract is the only sound order. The effect row plays both halves:
it gates which rewrites are legal and which candidates are.

### §5.U · The value layer — one record read at four altitudes

*handler = state = closure = evidence = continuation = branch thunk = fold
target = representation host*: one contiguous, handle-addressed record, read by
one emit-time read, `match lookup_ty(h)`.

- **Representation gradient** — `repr_of(Ty) -> Repr` (`RI32 | RI64 | RF64 |
  RF32 | RV128`, widths by match). i32 is the floor; the gradient infers the
  rest, and a `repr` pin is an input, never a requirement. A record pointer
  stays a word, so the record stays memcpy-serializable.
- **Multi-shot continuation** — the same record frozen at a resume site: a
  tail resume returns; a held or multi-shot resume reifies the remainder; persist
  is a copy of the image.
- **Parallel topology** — the same record forked as N branch thunks; the verb is
  pure topology and a `~> Schedule` handler picks `Seq | Thread | Simd | Gpu`.
- **Structural fold** — `==`, compare, hash and show are folds over the five
  node-kinds; equality is total to the bottom, sums included.
- **The keystone** `TCont(R, S, ResumeDiscipline, EffRow)` carries the effect
  world on the continuation, so `!E` reaches TIME: a continuation resumed under a
  changed handler set is a refusal, not a corruption.

### §5.O · The cost law — performance IS the Carried-Truth Law

**The cost of an operation is the size of the answer it was asked for, and
nothing else.** Two costs, never conflated: DERIVATION — computing a fact — is
O(1) amortized: a fact is computed once and read forever after, and re-deriving
across runs is the same violation as re-deriving across call sites (the image is
what makes "forever" reachable); DELIVERY — handing over a value — is O(what was
asked for), the only irreducible cost. The test is falsifiable and a gate:
change nothing, compile again, measure. A compiler that re-reads its own
conclusions has not earned the word "incremental".

Measure the hot path; never trust a code-reading estimate. Eight readers missed
the dominant cost of the 2026-07-13 self-compile (the resume-cardinality
classifier, 98% of a sample under host `perf`); profiling the fixed compiler
then took the self-compile from 1,400 s to 10 s. `wasm-opt -O2` measured a 4%
regression: the cost is algorithmic, never instruction slop. **If a change's
justification is a number and not a law, it is the wrong change.**

Cost is on the board: the march's m3 leg ratchets its peak RSS and the image's
own high-water, and a ceiling never rises (a landing whose cost breaches one pays
it down). The build order, each layer making the next O(1): (1) a name is a
handle from the lexer on; (2) every read an O(1) chase — the environment, the
reach walks (§11.18), instantiation shared rather than cloned; (3) the arena —
every extent reclaims at its exit what its publication does not reach (built);
(4) parallel cursors on deterministic `{arena, offset}` handles (§11.16).

---

## §6 · The bootstrap — the boot is the compiler

`boot/mentl.wasm` is the compiler: the pinned fixed-point wheel, its chain in
`boot/PROVENANCE.md`. The disposable seed that sparked it was deleted on
2026-07-10 (7401c4b); the cold-bootstrap recipe lives at tag `first-light`.

- **The fixed point.** `bash tools/march.sh` compiles the wheel with the boot
  (m2), the wheel with m2 (m3), and asserts m2 == m3; on a difference it runs m4
  itself — m3 == m4 is a TRANSITION (the wheel's own output moved; repin from
  m3), anything else is BROKEN. `MARCH_REPIN=1` pins. Every pin pairs the fixed
  point with correctness: the micro battery, the frontier, the crown.
- **The substrate.** One WASM linear memory; a bump line whose every extent runs
  in an arena (a landing names its extents rather than inheriting a heap that
  only grows); strings `[len][bytes]` with the `[−1][buf][start][len]` view;
  lists tagged flat, snoc, concat and slice. The boot imports WASI preview1 alone
  and defines its memory, so any preview1 engine hosts it; the gates use the
  stock wasmtime release pinned by version and digest
  (`bash tools/wasmtime-get.sh`). `mentl asm` assembles the wheel's own output.
- **Handler elimination** ("the proof becomes the dispatch"): tail-resumptive →
  a direct call; a static singleton → a direct call with the record from the
  live world chain; polymorphic → `call_indirect` through the record (evidence
  passing, never a vtable); held or multi-shot → a heap continuation record.
  Handler = state = closure: one record, `[fn_ptr][nstate][state…][arms]`;
  dispatch reads the install chain.

**The wheel's modules** (`src/`): `graph` (the graph: spine columns, union-find,
trail, checkpoints) · `types` (the metaschema: `Ty`, `Reason`, `NodeBody`,
`DiagKind`, the compiler's effects) · `effects` (the row algebra) · `lexer`,
`parser` (the text boundary) · `infer` (the judgment, the one writer) · `env`
(the scope) · `intern` · `own` (ownership grades) · `verify` (refinements, the
value walk, obligations) · `egraph` · `derive` (derivative readings) · `lower`,
`backends/wasm` (the projection to WAT) · `asm` (WAT to bytes) · `driver` (the
module DAG and layers) · `pipeline` (handler stacks, diagnostics) · `format` ·
`query`, `cursor`, `cursor_transport`, `space`, `mentl` (the reads: the facets,
the eight aspects, the View, the gradient) · `synth_proposer` (the ??-fan) ·
`board` (the standing bounds) · `cli`, `main` (the verbs) · `lsp`, `mcp`
(transports) · `canon`. The runtime library is `lib/`, which never imports the
compiler (§7).

---

## §7 · What the artifact has not reached

§4 and §5 write the target in the present tense; this section is the state, and
where they disagree this section is the arbiter. Each line points at the §11
landing that closes it. A gate that did not run is UNKNOWN, never green.

- **The program is the graph, and its one-write operations are not all built.**
  A node is its handle (`type Node = Int`), a body holds its children as handles,
  and everything the judgment learns about a node is a column at that handle; a
  value reference is linked to the declaration it resolved to. A pattern is a
  node the judgment binds, its constructor linked the same way, and a name
  written in a type is a node linked to the type it names; a row's effect name
  and a handler arm's op are still names with no node (§11.2); a type, a Reason
  and the lowered program are still value trees (§11.18). The first one-write operation is built: a named handler
  chain's install becomes its members' installs (SYNTAX §«Handler chains»); a
  rename, the session's edit and a proposal's accept are not (§11.2).
- **Names are still read where an edge exists** (§11.2, §11.18): the lowered
  program's identity is its symbol, so the emit's reach walks key their units
  by it and a resume-bound function is found by its spelling; a sugar's
  callee is a spelling the lowering resolves at the link's scope.
- **A module sees its whole import closure** (§11.3): visibility is the closure,
  so a user cannot declare a name the prelude declares, one namespace is paid
  for in prefixes, and the compiler recognizes library effects by their
  spelling. The layer half is closed: a library never imports the compiler and
  a user program cannot.
- **A catch-all over a sum is capped, not yet named at the declaration**
  (§11.5): the census bounds it and tighten writes any one as its roster; a
  constructor declared later still falls silently into every catch-all over its
  type.
- **A dropped value is silent** outside the stage of `each` (§11.6).
- **Early exit cannot be said and every cycle is hand recursion** (§11.7):
  `any`, `all`, `find` and `take` visit every element.
- **Teach answers locks and preconditions, and little else** (§11.8): no
  refinement at a part, no call with argument holes, no record proposed for a
  positional product.
- **Effect names lie about their ops** (§11.9): GraphRead holds writes,
  GraphWrite holds reads, and `Memory` holds pure word arithmetic, so a
  function doing only arithmetic on words is not `Pure`.
- **Effect-op parameters are nameless, and a filesystem failure is silent**
  (§11.4): every filesystem operation is a `Filesystem` op whose implementation
  is its handler's arm, but a path that does not read answers an empty string
  and one that does not open answers fd 0.
- **Executable refusal is partial**: `diag_refuses` holds the live list; a class
  born at zero arms at birth, and the rest are §11's work.
- **Regions are runtime**: every extent runs in an arena — each module's
  parse, binding groups, declaration lowerings and the reach walk, emitted
  units, session answers, speculations, spawned instances' runs — and
  ownership's regions stay compile-time facts.
- **`persist = memcpy` is built**: `lib/persist.mn` writes the image,
  `image_resume` gates on the build key, `mentl resume <image>` re-enters it.
  Host resources (descriptors, sockets) do not restore; cross-machine resume and
  a session that outlives its process are open (§11.18).
- **`TCont`'s world is a rule at every install and inert as a value**: there is
  no first-class `k` whose resume under a changed world could be refused (the
  frontier).
- **Threads are real**: `~> parallel_compose` runs branches on host threads over
  the shared image, a branch runs in the world it was spawned in, and
  `E_ThreadedBranchEffect` refuses a stateful handler a branch reaches, a store
  a branch makes into memory older than itself, and code a branch reaches that
  writes memory older than its own frame. SIMD and GPU run their branches
  sequentially. A write made through a function value is charged where the call
  stands, whatever memory it writes, so `!Mutate` and the race rule refuse some
  programs that write only fresh memory through a callback (§11.18).
- **The judgment is one pass; schemes are still values** (§11.18): a candidate
  is judged inside a checkpoint on the one live graph, and a declaration's type
  is frozen at its exit.
- **Incrementality is not a cached cursor** (§11.18): `graph_mutated` carries
  the handle and its prior value at every write, and every handler discards
  both; the session re-judges an edit's cone and still pays for the program; the
  warm start restores an image and re-derives the compile over it.
- **The resident Space keeps its graph for a session's life**; a session derives
  once per open, and a fresh process derives cold (§11.18).
- **The wheel never performs a multi-shot op**, and its speculation is
  bracketed by hand (§11.11, §11.15).
- **The compile is sequential by construction** (§11.16).
- **The prose still asserts machinery that is not there**: decoration banners,
  coordinates in prose, ledes that are another comment's text. Each module's
  comments are trued in the landing that touches it; fmt strips the decoration
  (§11.12).

---

## §8 · Verification surface

```
bash tools/state.sh                 # THE BOARD, ground first: verify, march, frontier, proof-exactness, crown, effect identity, threads, ide — one scoreboard; --quick = verify only
mentl verify [path]                 # the standing bounds on the medium's own source (src/board.mn), read off one judged graph; a rise refuses
mentl check [path]                  # every module of the link judged, no emit; no path: the project
mentl query <entry> <question>      # refs of NAME · unreachable · unreferenced · census <shape> · ghosts · imports · performs · smt · text · prose · writes of · reads of · provider of · heads · env
mentl why <file> <fn> [<Effect>]    # the declaration's reason, then where each effect of its row enters
mentl where <file> <name>           # a declaration's head, row, widths and address
mentl <file>:<line>[:<col>]         # the eight aspects at the caret, with the Lede
bash tools/march.sh                 # the fixed point: boot→m2→m3, m4 on a difference, TRANSITION or BROKEN; MARCH_REPIN=1 pins
bash tools/march-gate.sh --micros   # the rungs and the micro battery through the boot's m2
bash tools/frontier-gate.sh         # the scheduled matrix and the authoring workflows (--compiler fresh for the current wheel)
bash tools/crown-gate.sh            # leaks refuse, sounds accept
bash tools/proof-exactness-gate.sh  # a hole refuses, debt surfaces, a suspension runs
bash tools/ide-gate.sh              # the resident session: the node twin, then headless Chrome over the page
bash tools/verify.sh                # what no verb has absorbed: micros through the host, the sha chain, doc-truth
mentl test tests/proposals          # each fixture's first line is its contract at the hole
mentl test tests/teach              # each fixture's first line is its contract at the declaration
mentl space                         # the page, localhost:7397
python3 tools/emit-diff.py A.wat B.wat [--trap]   # the divergence pinner — first on any m3 trap
bash tools/profile-self.sh          # the self-compile under the guest profiler; tools/guest-profile.py names callers
```

**Forensics.** On any m3 trap, diff the emits first (`tools/emit-diff.py`), then
`wasm-tools validate --features all` the module and `wasm-tools shrink` to a
minimal repro. Patch a probe into `.build/probe/m2.wat` rather than the wheel's
source: editing the source changes the rows and layout under test. A probe is
comparable only within one binary. Read a value through its representation,
never a raw offset. The guest profiler and host `perf` find the hot path;
`wasm-opt` is not the lever.

---

## §9 · The laws

1. **The Carried-Truth Law, at four scales.** Every bug is one bug: the graph
   proved X; a consumer re-derived, discarded, fabricated or cached X instead of
   reading it live. Carry the handle, read live; the fix is less code. At the
   performance scale, a super-constant operation re-derives what an edge already
   connects (§5.O). At the surface scale, the authored text holds the developer's
   DECISIONS and every fact the graph computes is projected and maintained by the
   medium, never hand-kept beside it: a positive row is inferred (the source keeps
   negations, pins and `Pure`), parameter names are a decision, layout is a
   projection, the import block is a decision the medium maintains, and the
   diagnostic catalog is projected from its constructors. At the collaboration
   scale, carry real reasoning, never perform confidence.
2. **Don't patch — restructure.** If a fix fits in a patch, the architecture is
   wrong. A silent surrender fallback (`_ => 0`, `_ => str_concat`) is deleted,
   never wrapped.
3. **Dream-code first, and the dream is invariant to the substrate.** Write the
   final form; when the substrate cannot express it, the substrate is
   incomplete — complete it. "Reachable now", "realistic ultimate" and "a later
   follow-up" are the target lowered. Sequence the work, never the target. And
   run the generative audit (§2) so each touch reaches a newer ultimate.
4. **Mentl solves Mentl.** Reaching for a framework is a missing primitive.
5. **Build the wheel; never wrap the axle.**
6. **Audit before the symptom; probe before the hypothesis.** The first move on
   any work is the universal audit of the structures it touches. A probe that
   disproves you does not crown the next symptom; no edit, record or commit acts
   on a cause the artifact has not shown; when the cause is unmeasured, the output
   is the next instrument.
7. **Prove a new path with a gate; never defer the ultimate form for it.**
8. **No bolts onto non-ultimate forms, and none onto condemned ones.** A
   structure a §11 landing deletes takes no improvements.
9. **Interrogate, don't absorb** — these docs are the current best answer, and
   so is the code beside them: a structure's existence is not evidence that it
   should exist, and a comment is often the confession of the defect it covers.
10. **The artifact is the refuter; report, don't perform.** A finding that the
    artifact can be better is built, and the build and the gates refute a wrong
    form in seconds. A turn ends with what changed and the measured result; work
    not done is said first.
11. **A gate is not trusted until it has been seen red; a carried-truth fix
    deletes.** A banked expectation is a hypothesis about the era that banked it:
    when a correct fix flips old gates red, re-derive each truth by hand before
    re-banking.

**Bug classes that cost hours:** a `match … with _` masking a type error ·
duplicate top-level names · flat-array ops in snoc paths · printing inside a
report arm corrupting the WAT on stdout · `acc ++ [x]` in a loop · a flag as an
int · a diagnostic's name lying · a stack pushed at one end and popped at the
other · phantom captures · one-operand dispatch (a binop reading one operand's
type) · a blind token-walk absorber eating comma-less siblings.

---

## §10 · How to resume

1. Read `CLAUDE.md`, `PLAN.md`, `docs/SYNTAX.md`. That is the entire required
   context.
2. Run `bash tools/state.sh --quick`; trust the artifact over any prose here,
   and fix the prose where they disagree.
3. Take §11's first item. Ask the medium about every structure it touches —
   `mentl query`, `where`, `why`, `<file:line>` — before any edit.
4. Build the landing whole, prove it on the board, repin if the wheel moved,
   commit on main, push, and delete the item's paragraph from §11.

---

## §11 · The program — the one list of open work

The order follows four rules, in this order: protect what exists; keep the net
that verifies every landing trustworthy; close any false proof a user can hit
before anything else (§0's property 2 failing at a shape a real program writes
preempts this list); then the faces of the one law, hardest first. A landing is
committed whole; a gap found inside it is fixed inside it; when it lands its
paragraph leaves this list. Each `Hβ.*` label names the landing's design as git
keeps it.

**THE DEFINITION OF DONE** — one statement per §0 property, each a terminal
gate: (1) *proof beats review* — the crown sound under polymorphism, Verify
deciding its fragment with honest `V_Pending`, its search the medium's own,
every diagnostic class refusing; (2) *the negative is provable* — an `Untrusted`
value reaching a `Trusted` sink refused, implicit flows included; (3) *intent is
lossless* — the Why walk total, provenance projected at every surface, the
formatter's fixed point canonical; (4) *computation is durable* — persist
generalized to cross-machine resume, the session a value; (5) *systems explain
themselves* — `mentl audit` live, the docs a projection, the ??-fan with its
teaching tie-break as the daily loop; (6) *the oracle at its limits* — the fused
multi-cursor multi-shot search as the default judge; (7) *`!Outside` closed* —
the native backend, diverse double compilation, and the correctness oracle
absorbed into the wheel's own Verify. The terminus is §1's closed loop: the
person and the medium, nothing else needed at any scope.

**ONE LAW, FIVE FACES.** The largest open items are one violation — a
materialized view stored where an edge belonged: STRUCTURE (cut: a node is its
handle), REFERENCES (cut for value references; items 1 and 2 finish it), SCHEMES
(a declaration's type frozen at its exit), PROVENANCE (a `Reason` is a value
tree copying handles, structure, types and spans into every node) and the
LOWERED PROGRAM (`LowExpr`, a second tree whose walks read names). The oracle is
their sum: a fan that judges context once and reads it live, a tie-break that is
a provenance diff, a search over live shared cells.

**THE STANDING CURSOR** — the order work runs in:

2. **Every position is a cell — #108** (`Hβ.graph.positions-are-cells`). A
   pattern and a name written in a type are nodes that draw the edge a value
   reference draws (`graph_ref_link`), so `refs of` a constructor answers the
   patterns that take its values apart, `refs of` a type its annotations and
   nominal constructions, `unreferenced` counts a type used wherever its name
   is written or a value of it is built or taken apart, and the imports facet
   reads an import used only by a pattern or an annotation as used. A row's
   effect name, a handler arm's op name and a sugar's primitive are nodes that
   draw the same edge, so `refs of` an effect answers its rows, `refs of
   slice` its list-rest patterns, `unreferenced` measures an effect as it
   measures a type, and the imports facet stops reading an import used only by
   a row as DEAD; the sugar's callee is the edge at its node, which the lowering reads where it
   now resolves `concat_callees`, `subscript_callee` and `list_rest_callee` by
   spelling at the link's scope (the two concats one `seq_concat`, §4①). A
   sub-pattern's node is the cell of the part it takes apart, where a second
   cell is minted beside it today, so a binder is declared at its own
   position, and a claim is located at the value it claims. Then the writes
   the structure cut was for: a
   rename is one write at the declaration (the `rename` verb, through the
   formatter); the session re-judges the nodes an edit rewrote rather than
   re-parsing a module (the declaration-grain cone over the in-edges); accepting
   a proposal rewrites the hole's node in place, and the position-keyed accept
   column (`Hβ.synth.accepted-edge-keyed-by-position`) deletes.
3. **A module is a scope** (`Hβ.driver.per-module-env-overlay`,
   `Hβ.query.facets-read-the-link`, `Hβ.modules.import-block-is-maintained`,
   `Hβ.modules.vocabulary-held-by-declaration`,
   `Hβ.effects.unperformed-effects-delete`, `Hβ.space.nothing-is-collapsed`,
   `Hβ.modules.capability-units-by-clusters`). A name resolves through its
   module's own declarations, its direct imports' and the prelude's — never the
   newest entry of one flat environment — so a user's `count` beside lib/lists is
   legal, a library's own reference never rebinds to a user's declaration of the
   same name, and a collision is settled at the import edge by a selective set
   (`E_ImportNameCollision`, born armed). Two declarations of one name inside a
   module refuse at the second, naming the first, whatever their kinds: today a
   constructor sharing an effect's name shadows the effect and every row naming
   it refuses as no effect, two effects of one name merge their ops, and two
   types' constructors of one name surface as type mismatches at the uses
   (measured 2026-10-15). The medium proposes a missing edge at
   the reference, writes a conduit as a direct import and narrates a dead one
   (`T_DeadImport`); fmt dedups and orders the block. The facets follow:
   `imports` prints what crosses each edge and `conduit`, `DEAD` or `DUPLICATE`;
   `importers of <module>`; `where` and `query` exit nonzero on "not found"; two
   facets may not disagree. The compiler's vocabulary is held by declaration:
   the effects a schedule, a derivative reading or an arena reads resolve to
   handles once, so a user's own `effect Thread` is an ordinary effect, and no
   string literal in src spells an effect. An install that absorbs nothing is
   narrated (`T_InstallAbsorbsNothing`) and an op nothing performs is deleted
   with its arms. A module splits along its reference clusters (a `clusters`
   facet; lib/strings and src/types first), its prefixes becoming module names.
   The page's "reports in linked modules" collapse deletes, since a library
   judged clean at its own boundary produces nothing in a user's link.
4. **Names, the host boundary, and the catalog**
   (`Hβ.syntax.parameter-product-has-identity`,
   `Hβ.io.filesystem-failure-is-said`,
   `Hβ.diag.catalog-as-projection`). An effect op's parameters are named as a
   function's are: the medium proposes each name from what its handlers' arms
   bind and asks where they disagree, `mentl tighten` writes the sweep, and the
   positional form then refuses (`E_UnnamedParameter`). Every filesystem
   failure is said — an unreadable path performs `Fail`, never answers an empty
   string or a sentinel handle. `mentl diagnostics` projects the catalog
   from the `DiagKind` constructors, SYNTAX's tables become its text, and each
   class the docs name that no constructor declares is born with its fixture or
   struck.
5. **A later constructor is named where it falls**
   (`Hβ.match.catch-all-over-a-sum-is-the-roster`). Declaring a variant narrates,
   at the declaration, every catch-all it falls into. The exhaustiveness matrix
   leaves one fact on the match node — the roster each catch-all covers — that
   the refusal, the census, tighten and the lowering read, where the lowering
   re-walks the matrix today.
6. **A dropped value is said** (`Hβ.infer.statement-value-is-dropped-silently`).
   A block's non-final statement whose value is a function refuses
   (`E_DroppedValue`); a non-unit word or aggregate narrates until the wheel's
   census is zero, then refuses; `let _ = e` is the explicit discard.
7. **The verbs are whole** (`Hβ.verbs.the-verbs-are-whole`). V1: early exit is a
   resume grade, so `any`, `all`, `find`, `take` and `position` stop at the first
   hit and `iterate` yields lazily — `any` over five elements under a counting
   handler counts 3. V3: every cycle has a driver — an input loop is a fold over
   an `Iterate` source with quitting the abandon (`mcp_loop` and
   `session_line_loop` become one; `cursor_session` folds over its actions), and
   a fixpoint is a `<~` on a convergence clock that refuses rather than answer a
   non-fixpoint. V4: list pipelines are `~>` stage chains that re-yield outward
   in one pass; deforestation is an `Iterate`-algebra e-graph rewrite.
8. **Teach says what the program owes**
   (`Hβ.teach.teaches-what-the-program-owes`). A refinement proposed at a part
   (walked back through `PartFact` to its producer, ranked by the obligations it
   discharges); a declaration with an authored clause still offered the further
   locks its dependents stand on; a lexical ring read up the parent edge, calls
   built with argument holes, a record proposed for a positional product; one
   obligation value rendered once for the caret, teach, audit and smt (smt
   asserting the negation with its declarations); a declaration's Why its
   signature's, and a module a lede of its own; the self-proposal benchmark;
   topology proposed under the race rule's proof; and a base-type pin equal to
   what inference derives narrated as the inventory it is.
9. **An op lives where its behaviour belongs**
   (`Hβ.effects.op-lives-where-its-behaviour-belongs`,
   `Hβ.memory.word-arithmetic-is-memory`). A `*Write` effect's ops write and a
   `*Read` effect's read, held by a census at zero read through the published
   write fact: `graph_push_checkpoint` and `graph_attach_comment_ref` move into
   GraphWrite, `graph_install_at` and `graph_product_at` into GraphRead. Word
   arithmetic leaves `Memory` in two pins at the bootstrap seam (registered as
   primitives the library shadows, then the library's declarations deleted), so a
   function doing only arithmetic on words is `Pure`. Memory's stores become an
   effect of their own, so the store-age judgment reads a raw store off the op's
   edge, where it reads the op's spelling today (`raw_store_target`). A
   substrate primitive's face lives on its declaration
   (`Hβ.infer.seq-op-signature-driven`): the faces are a table in the judgment
   (`seq_op_sig`), read along the edge a reference draws to the primitive, and
   they become each primitive's own signature, its body typed through it, once
   a list's element crosses its slot at its own width — `list_set`'s journal of
   the value it stores is the face's today.
10. **Handlers installed once, pinned to their instance**
    (`Hβ.effects.handler-pins-its-instance`). One install per extent; a
    handler's start state its own; a chain named once; nothing installed only to
    swallow an op nobody reads. A handler's config parameter named in the
    instance position serves that instance alone (`handler sample_at(rate) with
    Sample(rate)`), refused statically at an install a provably distinct claim
    reaches. A handler named as a value is its record
    (`Hβ.effects.handler-value-is-its-record`): `let h = one` binds it, a
    parameter holds it, and an install of a value pushes the record it holds
    and absorbs the effect its `Handler(P, A)` type names — today the value's
    emit names a global nothing defines, and the module does not assemble.
11. **The medium authors the migration — iteration is topology**
    (`Hβ.wheel.iteration-is-topology`). The costume detector convicts index flow
    (a parameter threaded ±k into an index read), with let-chains, nested-call
    pipes, `<|`/`><` invitations, repeated install suffixes and partial eta
    (`(row) => dot(row, x)`) as shapes; tighten rewrites by edge, the prelude's
    datum-first signatures (`reduce`, `scanl`, `nth`, `clamp`) among them; a
    speculation is one extent — the cursor an arena with an overlay — and the
    trail ops leave the program-facing surface; the user gets a TIME library.
    Recursion that survives is priced by a signature.
12. **The project is canonical, and a render that changes the tree is not
    written** (`Hβ.fmt.the-project-is-canonical`,
    `Hβ.fmt.render-must-parse-to-the-same-tree`). fmt lifts every
    graph-preserving redundancy — `-> ()`, box-drawing decoration in comments,
    `0 - <literal>` where exact, the sole-parameter binder as an arm list once
    the parser builds one `LambdaExpr` for both, the ownership marker before the
    name — and the silencer markers go with the drift-audit scaffold they
    silence, its modes absorbed into the census. A render whose re-parse is a
    different tree (a structural fingerprint over both parses) is refused, and
    the heads round trip falls to zero as the parser grows the rules it misses.
    The batteries address a hole and a declaration by identity, never by
    `L:C`, so every fixture can be canonical; `mentl fmt --check` at zero over
    src, lib, examples and tests is a board line.
13. **The course and the page** (`Hβ.course.pulse-is-the-course`,
    `Hβ.space.the-canvas`, `Hβ.emit.the-medium-assembles-its-output`,
    `Hβ.viz.severance-map`). The course is Pulse: ten lessons on one growing
    chain a developer hears (`examples/pulse/course/01…10`), each a program
    `mentl run` renders, fmt-canonical at zero self-diagnostics, with a proposal
    contract at its hole, opened by the page as a project; lib/tutorial is
    deleted. The canvas paints the wheel's own tokens at their spans, the aspect
    strip and the ambient-world glyphs, obligation marks, the ownership trace,
    fmt on idle and the trail as undo. The page runs what it compiles: the worker
    instantiates the bytes `mentl asm` writes, and the fixpoint seal runs in the
    page. The Severance Map bands the module and declaration tree in three
    colours — provably absent, present, not yet provable — the third counted and
    falling; it ships after its known false greens close or counts them in the
    third colour, and its demo is one networking call turning a green band red
    with the refusal naming the call. Then the stranger test: someone who has
    never seen the repository finishes lesson 1 from the README alone.
14. **Wasatch "Inversion" — the first program the world hears**
    (`Hβ.wasatch.inversion`, `Hβ.wasatch.keyed-sources`,
    `Hβ.env.configuration-is-an-effect`). A generative score whose every
    parameter is a reading of Salt Lake — the lake's elevation, the Jordan's
    discharge, the inversion itself as the mountain warmer than the valley,
    earthquakes, snowpack, aircraft, the sun, the Jazz — rendered at 48 kHz as
    Pulse is, and provably unable to reach the Outside on its per-sample path.
    W1 renders offline from a checked-in snapshot; W3 plays live in the page; W2
    adds the keyed sources (UTA's real-time TRAX first) through a host-applied
    key the guest never holds — the open half of configuration as an effect.
15. **A continuation is captured at any position**
    (`Hβ.lower.offspine-perform-is-the-frame-not-in-the-image`). Frames live in
    the image: a frame is a record, a continuation its extent, capture a copy,
    so a held or multi-shot perform reifies from any position and
    `E_ContinuationUncapturable` has nothing left to refuse. Then the ??-fan
    performs `choose`, so the fixed point exercises a multi-shot op.
16. **The compile runs on every core** (`Hβ.driver.level-set-par-walk`,
    `Hβ.native.deterministic-handle-partition`). A handle becomes an
    `{arena, offset}` product (one word by a repr pin), deterministic under any
    order; the schedule is a pool; emission, the classifier rounds and the
    judgment's binding-group levels are fanouts; the battery judges its library
    once; Pulse renders by block under `parallel_compose`. Every step is gated by
    m3 under `Seq` byte-identical to m3 under `parallel_compose`.
17. **Verify's own solver** (`Hβ.verify.the-solver-is-the-search`). The
    proposer's search is the solver: union-find and the e-graph as congruence
    closure, the trail as the assignment stack, a fork as a case split, the first
    divergence of two trails as conflict analysis. The fragment, in the order the
    wheel's own debt names it: path narrowing (the guarded index reads and the
    divisions under a guard), overflow-aware intervals, linear arithmetic,
    equality from the e-graph. An external solver plugs in only as a proposer
    whose certificate the kernel checks.
18. **The remaining faces of the one law.** Schemes are edges
    (`Hβ.infer.schemes-are-edges`: instantiation a correspondence edge, never a
    clone); a `Reason` is an edge to the node it names, never a copied tree;
    lowering is columns on the program's own handles, the `LowExpr` tree and its
    walkers deleted (`Hβ.lower.lowering-is-a-column`) — a lowered unit is a
    column on its declaration's handle, where its identity is the symbol
    `LFn(String, …)` carries and the emit's and the reading's reach walks
    (`plan_reached`, `reach_units`) key their units by it, and a function
    bound to a handler's resume is the declaration the arm's references
    reach, where it is found by its spelling (`ls_resume_bind_of`); the
    gate is m3 == m4 with the symbol-keyed walks deleted; incrementality has the
    trail as the delta's home (`Hβ.graph.mutation-delta-is-write-only`), the
    session paying for what an edit moved (`Hβ.session.edit-pays-for-the-program`)
    and outliving its process (`Hβ.felt.accept-outlives-the-process`); persist
    resumes across machines (`Hβ.persist.cross-machine-resume`); and a function
    value carries its store claim on its type, as it carries its contract, so a
    call through it pays `Mutate` only where the memory it hands is older than
    the caller's frame (`Hβ.effects.store-claim-travels-with-the-function`).

---

### The frontier — each a move inside the medium

- **The crown, modal** (`Hβ.effects.modal-world-index`): rows, capabilities and
  negation sound together as a graph fact, one crucible per modal rule, red
  first; the TIME face — a resumed continuation refused under a changed world —
  rides persist.
- **Flow** (§4⑥): the influence walk gains control edges, a label is a
  refinement on a source's declared type and a sink's demand a precondition, and
  `FlowLabel` and its readers retire.
- **Verification whole**: the verifier decides a predicate's expression, where
  it decides the projection a type carries (`node_to_predicate`); a bug trap
  unwinds with the graph as its payload; every diagnostic class refuses the
  executable.
- **The fused oracle**: N forked cursors on N threads over one image, form
  variants merged as e-graph classes, meanings forked only at genuine
  disjunctions, the question computed from the first divergence of two trails —
  the default judge.
- **`!Outside` closes**: the native backend (`docs/NATIVE.md`, frames in the
  image and the deterministic partition its keystones), diverse double
  compilation (`Hβ.closure.diverse-double-compilation`), the correctness oracle
  absorbed into the wheel's own Verify
  (`Hβ.closure.correctness-oracle-internal`), and every scaffold under tools/
  absorbed into a verb — the march is `mentl march` and the board `mentl verify`
  already; the state script is next.

Excluded by hardware only: MI300X execution, wasmFX, shared-everything threads.
