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
  version → infer → Verify → restore before the person at the keyboard
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
- **Multi-shot = TIME.** Fork (a version of the graph, taken in O(1)), cache
  (the cursor memoizes live reads — "read live" is the semantics, "cached" the
  mechanism), persist (continuation to disk). Search, the cached cursor and
  durable execution are ONE primitive distinguished by which handler catches
  the resume (§4④).
- **Threading = SPACE.** Parallel cursors read the shared image and fork to
  per-thread versions; compile, IDE, prover and oracle search are the same
  graph read at many positions.

The cursor projected through {substrate, time, space} IS the subsystem table;
**the oracle FUSES all three** — N forked cursors on N threads over one shared
graph, each fork a version of its own. The version, the threads and
continuation reification are built; their fusion is §11's frontier.

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

- **L0 · The graph.** Nodes and typed edges, live, every fact a column keyed by
  the handle itself (a four-level trie: an O(1) chase), and the graph a VALUE:
  a version is taken in O(1) by remembering the column roots, a fork is an
  instance of the graph handler seeded with one — its own columns hold what
  it writes and a read falls through to the versions below — and a
  speculation keeps the fork by merging its cells into the instance below or
  drops it with its extent. *Only inference writes.*
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
2026-10-02, built 2026-10-16). `!E` + `~>` already subsumes capability
security; flow adds WHICH value may reach a sink, and the graph already carries
that relation: a refinement is read along a value's flow edges, a handler's
state is every value written into it, memory holds what was stored there, and
the parent edge gives control dependence. So a label is an op named in a
refinement over `self` (`type Untrusted = String where untrusted(self)`): a
source's declared type states it (`-> Untrusted`), a sink's demand is its
absence on a parameter (`exec(cmd: Trusted)`), a leak is `E_RefinementRejected`
at the sink's claim naming where the label entered, endorsement is a function
whose declared return states the absence, and an implicit flow is what decides
whether the code reaching the sink runs — a branch, a call made under a
condition, an abandon. Each declared function's reading is a summary over its
own parameters, read once per settle. A `Flow(Src, Sink)` row element beside it
would be a second home for one fact. The proof says where OUTPUT may go, never
what a model does inside its window.

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
3. **UNSURPASSABLE — the frontier.** Modal effect synthesis (§4③), durable
   execution as a handler (§4④), Verify's own solver, native and GPU backends,
   the e-graph — each a move *within* the medium.

**The felt endpoint.** A `??` is a typed CONSTRAINT: the cursor forks a finite,
latency-budgeted set of candidates, each run version → infer → Verify →
restore against its own version, and only proven survivors surface. The ranker reads
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

Cost is on the board: the march's m3 leg ratchets its peak RSS, and holds the
image's own high-water and its wall time against the pinned boot compiling the
same wheel in the same march, so each ratchet measures the compiler and never
the wheel's size or the machine's load; a ceiling never rises
(a landing whose cost breaches one pays it down). The build order, each layer making the next O(1): (1) a name is a
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

**The wheel's modules** (`src/`): `graph` (the graph: the versioned columns,
union-find, the forking handlers) · `types` (the metaschema: `Ty`, `Reason`, `NodeBody`,
`DiagKind`, the compiler's effects) · `effects` (the row algebra) · `lexer`,
`parser` (the text boundary) · `infer` (the judgment, the one writer) · `env`
(the scope) · `intern` · `own` (ownership grades) · `verify` (refinements, the
value walk, obligations) · `egraph` · `derive` (derivative readings) · `lower`,
`backends/wasm` (the projection to WAT) · `asm` (WAT to bytes) · `driver` (the
module DAG and layers) · `pipeline` (handler stacks, diagnostics) · `format` ·
`query`, `cursor`, `cursor_transport`, `space`, `mentl` (the reads: the facets,
the eight aspects, the View, the gradient) · `synth_proposer` (the ??-fan) ·
`rename` (a rename, one write at a declaration) · `board` (the standing
bounds) · `cli`, `main` (the verbs) · `lsp`, `mcp`
(transports) · `canon`. The runtime library is `lib/`, which never imports the
compiler (§7).

---

## §7 · What the artifact has not reached

§4 and §5 write the target in the present tense; this section is the state, and
where they disagree this section is the arbiter. Each line points at the §11
landing that closes it. A gate that did not run is UNKNOWN, never green.

- **The program is the graph, and its one-write operations are not all built.**
  A node is its handle (`type Node = Int`), a body holds its children as handles,
  and everything the judgment learns about a node is a column at that handle;
  the program itself is a node, the link, whose members are its module nodes,
  each holding the text its judgment read and its imports as edges, and every
  reader starts from it — the compile, the session, the address, the battery. A
  value reference is linked to the declaration it resolved to. A pattern is a
  node the judgment binds, its constructor linked the same way, a sub-pattern
  — a rest among them — is the cell of the part it takes apart, and every
  binder a pattern writes, a let's and a match arm's among them, is declared
  where it is written, so the caret at a binder says its uses; a parameter is
  a node of its own, the cell of the argument its position takes, so a
  destructured parameter is its pattern and its names are declared where
  they are written, each once per head; a handler arm's arguments are
  parameters by the same rule, and a state field's name is the binder of its
  init, linked from every `resume … with` that writes it; a name written
  in a type is a node linked to the type it names, and so are an effect a
  declaration's row or a function type's row names, the op a handler arm
  serves and a sugar that calls a primitive (`xs[i]`, `++`, an interpolation's
  seams, a list rest), so `refs of` reaches every one of them. A type, a
  Reason and the lowered program are still value trees (§11.18), so a name
  written inside a type renders from the type's value. Three one-write
  operations are built: a named handler chain's install becomes its members'
  installs (SYNTAX §«Handler chains»); a rename is one write at the
  declaration (`mentl rename`), every reference, label and comment mention
  rendering through its edge, a rename that moves an edge refused, and one
  that reaches a name inside a type refused; and an edit is judged at the
  grain it was made — the statements it rewrote or moved are read again from
  their own lines into the module's node, the declarations whose judgment
  read them are judged again with them, and every other statement keeps its
  nodes and its judgment. A proposal's accept is not (§11.2).
- **Names are still read where an edge exists** (§11.2, §11.3, §11.18): the
  lowered program's identity is its symbol, so the emit's reach walks key their
  units by it; an arm's resume grade is settled before the judgment draws
  any edge, so it reads the functions its body declares, and the parameters a
  callee calls at its tail, by their spelling; the emit cuts a list rest by
  the slice's spelling, its lowered pattern holding no
  handle; an emitted
  arm's kind holds its op's spelling, and the performs the lowering writes for
  a schedule (`spawn`, `thread_join`, `persist_branch`, `join_persist`) name
  their ops, the compiler's own vocabulary.
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
- **A derived fold over a sequence is one call per element** (§11.11): `==`
  over two lists of twenty thousand pairs exhausts the stack, where five
  thousand compare, and compare, hash and show recurse the same way.
- **Teach answers locks and preconditions, and little else** (§11.8): no
  refinement at a part, no call with argument holes, no record proposed for a
  positional product.
- **The course and the scores are owed** (`mentl verify`, the `QOwed` bounds;
  §11's verification whole): a Nyquist bound that reads the installed rate
  inside its predicate is left pending (lesson 6), a division by a value
  nothing bounds charges `Trap` (lesson 7, Pulse), and a frequency computed
  from a sine or a product is a claim the interval fragment has not grown
  (Pulse, Wasatch). The page cannot yet play a lesson (§11.13).
- **Effect names lie about their ops** (§11.9): GraphRead holds writes,
  GraphWrite holds reads, and `Memory` holds pure word arithmetic, so a
  function doing only arithmetic on words is not `Pure`.
- **Effect-op parameters are nameless, and a filesystem failure is silent**
  (§11.4): every filesystem operation is a `Filesystem` op whose implementation
  is its handler's arm, but a path that does not read answers an empty string
  and one that does not open answers fd 0.
- **A module's init stores what one binder names** (§11.18): a module-scope
  let whose pattern is a discard, a literal or a destructure refuses where the
  program is emitted (`E_InternalInvariant`).
- **Regions are runtime**: every extent runs in an arena — each module's
  parse, binding groups, declaration lowerings and the reach walk, emitted
  units, session answers, speculations, spawned instances' runs — and
  ownership's regions stay compile-time facts.
- **`persist = memcpy` is built**: `lib/persist.mn` writes the image,
  `image_resume` gates on the build key, `mentl resume <image>` re-enters it.
  Host resources (descriptors, sockets) do not restore; cross-machine resume and
  a session that outlives its process are open (§11.18).
- **A continuation answers to the world it is resumed in, and a row names
  effects, not installs**: a continuation carries its own segment of the world
  it was captured in and reaches the installs around its resume past it, and
  each install's remainder is an instance of its handler's world cell, which a
  negation and the root judge wherever the program states them. A row says
  which effects a computation performs, each at the instance it performs, and
  never which install answers one: an install answers the instance it serves,
  so two installs of one instance are one fact to a negation, and absence is
  proven per instance, not per install (the modal crown, §11).
- **Threads are real**: `~> parallel_compose` runs branches on host threads over
  the shared image, a branch runs in the world it was spawned in, and
  `E_ThreadedBranchEffect` refuses a stateful handler a branch reaches, a store
  a branch makes into memory older than itself, and code a branch reaches that
  writes memory older than its own frame. SIMD and GPU run their branches
  sequentially. A function value's writes are read through its claim, written
  where its judgment ends — its parameters by the arguments a call hands, a
  capture by the binder's age in the frame holding the value, its own
  feedback line by the value's age, the functions it applies by what the
  callee hands them — so a call through it pays `Mutate` only where the
  memory it reaches is older than the caller's frame; a call's answer read
  off a tee (a fold's accumulator, a handler's answer) is memory the
  store-age walk cannot place, so a function threading a table through a
  fold's result owes `Mutate` it could prove (§11.18). A wide
  answer does not cross a thread's join: `parallel_compose`'s arms are
  emitted once at the word face, so a Float-answering branch traps where its
  join is read at the site's face (§11.16).
- **The judgment is one pass; schemes are still values** (§11.18): a candidate
  is judged against a version of the one live graph, and a declaration's type
  is frozen at its exit.
- **Incrementality is not a cached cursor** (§11.18): the delta between two
  versions of the graph costs what moved (`graph_written_since` reads it for
  the tie-break), and nothing re-projects on it. An edit's cone has no
  cutoff: every declaration whose judgment read a
  rewritten one is judged again, transitively, whether or not what the
  rewritten one publishes moved, so an edit to `chain_spelling`, which a
  third of the wheel's functions read transitively, judges 1,767
  declarations, about what a cold judgment costs, where an edit to a leaf
  judges seventeen; and every edit's judgment stays in the image. The warm
  start restores an image and judges the edit's cone over it.
- **The resident Space keeps its graph for a session's life**; a session derives
  once per open, and a fresh process derives cold (§11.18).
- **Speculation is a choice, and a fork is an instance, one speculation at a
  time**: every judgment the medium tries and may undo performs `choose`
  (lib/choice.mn), and the forking handlers run each resumption under the
  judgment's chain over a graph handler instance of its own, seeded with the
  version of the instance below (`graph_version`: the column roots, the
  mint, the span log, O(1)), beside instances of the row gate, the mint, the
  ledgers, the store ages and the frame stack seeded from the instances
  below, an env view over the entries below, a diagnostic collector and a
  view of the intern table as the fork found it (`forked`). The option's
  writes land in its own columns and a read falls through to the versions
  below, so the handler that judges every option drops each instance with
  its arena (`speculate`) and the handler that keeps the first held round
  merges its cells into the instance below (`graph_keep`) and adopts its
  ledger facts, its frame stack and its store ages (`branch_join`). The
  ??-fan's candidates, teach's locks and contracts and the Mycroft rounds
  of every unsigned declaration's judgment fork this way; a candidate's
  teaching is read inside its instance as the cells that instance wrote. A
  fork mints no word: the intern table is written at the text boundary and
  born holding the medium's own vocabulary, and a word first seen inside a
  fork is refused by name. The options run one after another, so two never
  run at once; forks on threads are the fused oracle's one pin left (§11).
  A continuation is captured at any position, by a copy of its frame's
  lowered tail (§11.18).
- **The compile is sequential by construction** (§11.16).
- **The prose still asserts machinery that is not there**: decoration banners,
  coordinates in prose, ledes that are another comment's text, and forward
  pointers (`Hβ.*` labels) in the wheel's comments that no §11 paragraph
  names — the documents carry none, held by `tools/doc-truth.sh`. Each
  module's comments are trued in the landing that touches it; fmt strips the
  decoration (§11.12).

---

## §8 · Verification surface

```
bash tools/state.sh                 # THE BOARD, ground first: verify, march, frontier, proof-exactness, crown, effect identity, threads, ide — one scoreboard; --quick = verify only
mentl verify [path]                 # the standing bounds on the medium's own source (src/board.mn), read off one judged graph; a rise refuses
mentl check [path]                  # every module of the link judged, no emit; no path: the project
mentl query <entry> <question>      # refs of NAME · unreachable · unreferenced · census <shape> · ghosts · imports · performs · smt · text · prose · writes of · reads of · provider of · heads · env · reports · owed <dir>
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

The order is biggest moves first (Morgan, 2026-10-16): the frontier leads, in
the order it is written below, and the standing cursor follows it, the native
backend last. Two rules preempt both: a false proof a user can hit (§0's
property 2 failing at a shape a real program writes) is closed before anything
else, and the net that verifies every landing stays trustworthy. A landing is
committed whole; a gap found inside it is fixed inside it; when it lands its
paragraph leaves this list. Each `Hβ.*` label names the landing's design as git
keeps it. The DSP arc runs before the fused oracle's last landing (Morgan,
2026-10-21), in this order: a predicate decided as written (verification
whole), a delay sized from the rate (§11.7) and the prelude's stage order
(§11.11).

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
absorbed into the wheel's own Verify; (8) *nothing owed* — every ceiling on
the board at zero or at a decision the author made, the course and the two
scores judged clean (the `QOwed` bounds at zero), no expected red, no
silencer, no diagnostic class named and unborn, no landing named outside this
list. The terminus is §1's closed loop: the person and the medium, nothing
else needed at any scope.

**ONE LAW, FIVE FACES.** The largest open items are one violation — a
materialized view stored where an edge belonged: STRUCTURE (cut: a node is its
handle), REFERENCES (cut: a name is a node linked to what it names, and a
binder is declared where it is written), SCHEMES
(a declaration's type frozen at its exit), PROVENANCE (a `Reason` is a value
tree copying handles, structure, types and spans into every node) and the
LOWERED PROGRAM (`LowExpr`, a second tree whose walks read names). The oracle is
their sum: a fan that judges context once and reads it live, a tie-break that is
a provenance diff, a search over live shared cells.

**THE FRONTIER LEADS** — each a move inside the medium, in the order work
runs, its design written here whole so a session starts from this paragraph
and the artifact:

- **The fused oracle** — the graph is a VALUE, and a fork is an instance of
  the graph handler seeded with a version of it. `choose` (lib/choice.mn)
  is caught by `speculate` and `first_held` (src/infer.mn). Landed
  2026-10-20: every per-handle fact is a column keyed by the handle itself
  (lib/imap.mn's persistent trie, four levels of 64 under a root that grows
  with the mint); an instance's columns hold the cells it wrote and a read
  falls through to the version it was seeded with and the versions below
  that (`col_get`); a version is taken in O(1) (`graph_version`: the
  instance's columns and the version below them). Each resumption of a
  `choose` runs under the judgment's whole chain over an instance of its
  own (`forked`: the row gate, the mint, the ledgers, an env view over the
  entries below, a diagnostic collector, the graph instance), so every
  write of the option lands in its instances and the instances below are
  untouched by construction; `speculate` drops each instance with its arena
  and `first_held` merges the kept instance's cells into the instance below
  (`graph_keep`, lib/imap.mn's `pt_merge`, O(what it wrote)) and adopts its
  ledger facts — the env entries, the decided and the open claims, the
  consumes, the held reports (`branch_join`). The trail, the checkpoint stack, the restore and
  the heap mark are deleted; nothing is journaled. A handler standing
  outside every fork — the frame stack, the store ages — reads no graph in
  its arms, because an arm's perform resolves to the instance below the
  fork (the frame exit hands the body its facts and the body computes the
  published row). The tie-break is computed: each survivor is sealed with
  the context cells its judgment bound, read inside its instance as the
  cells that instance wrote (`graph_written_since`), the first cell two
  survivors bound differently is the question (`DivType` with the cell's
  own Reason, `DivRow`), and survivors the e-graph extracts to one class
  are one meaning shown once. The compiler is still emitted as a
  thread-free module (a defined memory, a bump allocator, no spawn import),
  and that is the one pin left, taken in three landings. (a) A fork owns
  every ledger it writes — landed 2026-10-21: `forked` installs, beside the
  instances above, a store-ages and a frame-stack instance seeded with the
  state of the instances below (`AgesSeed`, `CtxSeed`) and a view of the
  intern table as the fork found it (`intern_view`), so every ledger an
  option's judgment writes is the option's own; the keep adopts the kept
  option's frame stack and store ages (`inf_adopt`, `ages_adopt`) as it
  merges its graph cells; the collector filters a forget on its own list;
  every option of one choice mints its handles from the version's own
  `next`, so a handle is the same under any schedule; a word is interned at
  the text boundary or born in every table (`medium_vocabulary`, `Mutate`
  among them), so a fork mints no word and one first seen inside a fork is
  refused by name — nothing is banded, since nothing in a fork mints; and
  the judgment's core is named once (`judgment_core`) and stands under the
  module judgment, the fan and the facets. `mentl why src/infer.mn forked`
  names the substrate's effects, `StateWalk` (the root's stateless walk),
  `Mutate` (the graph instance's own trie store) and the view's refusal,
  and nothing else. (b) A store claim travels with the function — landed
  2026-10-21: every function's claim is written where its judgment ends, a
  lambda's and a nested fn's at their own node, and names what the body
  writes — its parameters by position, the captures it writes, its own
  record (a closure's feedback line), the parameters it applies with what it
  hands each slot (a parameter of its own, a loop's accumulator, or nothing
  it can name), the functions its result can be, and whether it writes
  beyond all of these; a call through a value reads the claims of every
  function the value can be (`fn_leaves`), a partial's through its product,
  a maker's answer through the maker's `returned`, and charges each write
  by the age of what it reaches in the calling frame, so `Mutate` leaves
  the callee's row where every write is accounted for, leaves its names
  where the callee applies a function of the caller's own (the tail carries
  it to the caller's callers, who read the caller's `applies`), and stands
  where a write is unaccounted (`mutation_masked`, `charge_leaf`); a
  closure inside a binding group calling a co-member hands the call to the
  declaring function to settle. The race rule reads a branch's `Mutate` off
  the rows so judged, so a voice minted in the branch and ticked there is
  the branch's own construction and runs. The tenth lesson renders
  (`mentl run examples/pulse/course/10-voices.mn`), the course's owed count
  fell 6 → 5, and the boot's silent strip of a callback's `Mutate` from a
  masked callee row — a false proof a fold writing its accumulator could
  hit — is closed (tests/micros/mn-mutate-closure-line-is-the-value.mn,
  mn-mutate-capture-fresh.mn, mn-mutate-capture-param-refuses.mn,
  mn-mutate-through-callback-param.mn,
  mn-race-store-into-branch-memory.mn). (c) The compiler spawns
  (`Hβ.oracle.forks-on-threads`): the demand walk that twins a direct
  callee by the install's schedule follows a `~> h` in the demanded reach
  into `h`'s arms, the arm twins keyed by the schedule letter and minted
  only where the schedule changes the lowering; `parallel_compose` is a
  POOL sized to the cores — a fanout enqueues its branches as task records
  in the image's shared queue, a nested fanout inside a worker enqueues
  instead of spawning, and the join reads results by option index — and
  stands over the judgment at every verb entry; `sequential_compose`
  stands at one site, `mentl march`'s determinism leg, which compiles the
  wheel twice in-process, once under each schedule, asserts the two WATs
  byte-identical and prints both wall times, its spawn arm running the
  task in the performer's world as the task record does; the emit sees
  `spawn_task` reached and emits the spawning module; the page's resident
  session arms the pool its run role has. Gates: m3 under
  `sequential_compose` byte-identical to m3 under `parallel_compose`
  (§11.16's statement made real), the two wall times on the board, every
  battery green at every pin.
- **The crown, modal** (`Hβ.effects.modal-world-index`): a row names
  EFFECTS — `EffName` carries a name and its arguments, a `RowEdge`'s mask
  names effects, `inf_mark_install_frame` drops the handler the install
  judgment holds in hand — so absence is proven per effect, never per install.
  The form: an effect in a row is indexed by the install that answers it
  (`E@h`, the install node the judgment resolves when it draws the op edge;
  `E@?` where a caller's install answers), a mask names the installs it
  subtracts, and a row variable bound at a `~>` edge is that install's lexical
  capability — the Tang–Lindley synthesis with the negation half carried.
  The facts that need an install's identity fall out: a handler held as a
  value (its record IS the install's identity), two installs of one instance
  with a negation between them, a closure minted under one install and called
  under another. An install's instance is already its own: a perform reaches
  the innermost install serving its instance, and an install subtracts only
  the instance it serves (SYNTAX §«Installation in `with` clauses»), so the
  index refines what the instance distinguishes. Written once,
  where the op edge is drawn; read by `row_subsumes`, `diff_row`, the gate's
  mask, the Why walk and `mentl where`. `inter_row`'s silent arm deletes, a
  world mismatch names its two worlds, and a persisted continuation's world is
  checked where the image is resumed. One crucible per modal rule, RED first,
  with its sound twin; the page's hop-by-hop unroll of a `!E` under
  polymorphism rides it (`Hβ.effects.sound-neg-under-poly`).
- **Verification whole**: the verifier decides a predicate's EXPRESSION — the
  `Predicate` projection, `node_to_predicate` and the copy frozen into
  `TRefined` delete, the value walk reading the predicate's nodes and a
  called function's contract and body — so a predicate that calls a function
  is decided; a parameter is what its calls hand it, so a bound every call
  establishes — `0 <= i` where each call hands `0` or `i + 1`, read under the
  path at each call and the body's own hypothesis at the recursive one — is
  a hypothesis of the body, and the wheel's index loops are proven
  (`Hβ.verify.parameter-is-what-its-calls-hand`); a slice past its sequence
  is the row fact `Trap` as an index out of range is
  (`Hβ.effects.index-partiality-is-a-row-fact`); a bug trap performs `Trap`
  carrying the node, and the root answers it with the node's aspects and
  Reason chain, never a bare `unreachable`; a label's claim on a part read off
  a call's answer is read through the callee's return tails, proven where
  the callee built the part in sight and owed, naming the site, where it did
  not (`Hβ.verify.part-of-a-call-answer`); a refinement a callback demands of
  the values a callee hands it is judged where the callee passes them
  (`Hβ.verify.higher-order-refinement`) — its first face landed 2026-10-21: a
stage completed in place, a pipe's or a `<|` branch's, is one application
of its callee with the whole product, so a learning parameter learns every
slot and a filter's cutoff handed through a record field is decided where
the record crosses; a learned contract reads an open record to the end of
its row; a parameter a recursive call hands back to itself teaches
nothing; and the `<|` branch, which owed nothing, owes what a stage owes
(lessons 2, 5 and 9; tests/micros/mn-refine-stage-through-field.mn,
mn-refine-fanout-branch-owes.mn); a state
  write is read as the claim's own hypothesis, an inductive invariant
  (`Hβ.verify.state-reads-its-invariant`); a handler is a judgment unit: a
  claim an arm makes about its own state's parts is decided once every arm
  is judged, its row fact with it, where today an arm's claim over the
  state's memory is owed and the `Trap` it guards charged at the install,
  since a later arm could hand the memory away
  (`Hβ.verify.handler-is-a-judgment-unit`); non-termination is a row fact
  beside `Trap` (`Hβ.effects.divergence-is-a-row-fact`); then the solver is the search
  (§11.17), the fragment growing in the order the wheel's own debt names it,
  the debt ceiling falling with each step.
- **`!Outside` closes**, last: the keystone — lowering is a column on the
  program's own handles and a continuation is its frame's record in the image
  (§11.18, `Hβ.lower.lowering-is-a-column`); the native backend
  (`docs/NATIVE.md`, the deterministic band its second keystone); diverse
  double compilation (`Hβ.closure.diverse-double-compilation`); the
  correctness oracle absorbed into the wheel's own Verify
  (`Hβ.closure.correctness-oracle-internal`); and every scaffold under tools/
  absorbed into a verb — the march is `mentl march` and the board
  `mentl verify` already; the state script is next, and the loop then names
  no script.

**THE STANDING CURSOR** — the order work runs in once the frontier has moved:

1. **The judgment costs what it answers** — the cost law (§5.O) paid where
   it is measured red, four pieces in one arc, each RED first. (a) A
   recursive group is judged in time linear in the group
   (`Hβ.infer.update-relations-multiply`). Landed 2026-10-19: a reference
   to a co-member shares the edges of its row whose chains reach no
   quantified root, where it copied the group's whole edge closure along
   every path (`subst_edge_build_into`); the free-leaf walk reads each cell
   once (`free_in_row`); an update's relation (`DemandCopy`) is written once
   per pair of row cells, whatever handles spell it (`row_copy_carry`); the
   rows a generalization closes over are walked once as a set
   (`rows_related_closure`); and the lowering reads a declaration's
   judgment once (`ls_judgment_memo`). Twenty, forty and eighty members
   threading `{...ctx, install: n, self: i}` judge in 0.6, 0.7 and 0.9 s,
   where boot 8b3c3374 judged forty for 33.5 s and exhausted the image on
   eighty (tests/micros/mn-record-update-group.mn). What remains is the edge
   itself: the relation is still a demand copied onto the fresh cells at
   every instantiation (`relation_copy_one`) and read by chasing, where an
   edge between the two row cells, kept by the copy of a cell, is the form
   §11.18's schemes-as-edges names; a reference still substitutes a row's
   edges (`subst_row_build`) where a correspondence edge would share them
   all; and the flow walk builds its context as a record literal
   (`ctx_at`), where the update form is the one SYNTAX asks a person to
   write. (b) An arm's resume grade is the column §11.18 names, written
   once where the op edge is drawn, and the tail facts a column on the
   declaration the callee's edge reaches, where `arm_grade` re-runs the
   arm's fixpoint per reader and the tail facts are an smap keyed by spelling
   (`Hβ.cost.arm-grade-is-a-column`). (c) The hot path, measured
   (`bash tools/profile-self.sh`, `tools/guest-profile.py`), each top caller
   removed by the law it breaks, never by a number. Landed 2026-10-19 (pin
   8b3c3374): the dispatch walk memoized per instance, and the emit's index
   loops over pushed and concatenated lists read flat, fold or ask an smap
   — 13 s to 8 s for the self-compile. Still measured and named, for the
   profile to rank: the memo answers from a hashed table where a dense
   index per (effect, op) would answer inline from two loads; `fold` and
   `each` index their flat list through the typed bounds check per element;
   `instantiate(Live(h))` re-generalizes the declaration at every use;
   `env_snapshot` fills an index per call and each `??` segment installs a
   fresh env; `row_of_subtree` is an unmemoized whole-subtree fold called per
   node; `reach_units` and `plan_reached` key their walks by symbol;
   `set_canonicalize` re-sorts a growing accumulator in the
   `effects_of_edges` loop; the `wmap` columns have fixed bucket counts, so a
   graph read scans a bucket of hundreds; `ls_find_str_local` and
   `name_set_prefix_contains` scan per lookup (`Hβ.cost.hot-path-by-law`).
   The self-compile's wall and peak ratchet down; the wall is read as a share
   of the boot's on the same wheel, since a lone wall reading is the machine's
   load as much as the compiler's. (d) The edit's cone has a cutoff: a
   declaration whose rewritten dependency publishes the same scheme, row and
   claims is not judged again (`Hβ.session.edit-cone-cutoff`), where today
   every declaration whose judgment read a rewritten one is judged again
   transitively (§7).
2. **Every position is a cell — #108** (`Hβ.graph.positions-are-cells`). The
   write the structure cut was for that is not yet built: accepting a
   proposal rewrites the hole's node in place, the position-keyed accept
   column (`Hβ.synth.accepted-edge-keyed-by-position`) deleted.
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
   Handlers are package management, so there is no package manager: an
   `import` performs `resolve(path)`, and the handler installed over the link
   answers — the project's folder and the library today, a content-addressed
   store or a registry beside them — so a version is that handler's config,
   the lock is the hashes the link's import edges resolved to (kept in the
   image, so a build is reproduced by its handler and its lock), and a
   dependency's capabilities are a negation its import edge states (`import
   vendor/json with !Network`), proven over everything the module exports.
   The root table (`module_roots`) deletes into the handler, and a module's
   layer is what the handler answers about where it found the module.
4. **Names, the host boundary, and the catalog**
   (`Hβ.syntax.parameter-product-has-identity`,
   `Hβ.io.filesystem-failure-is-said`,
   `Hβ.diag.catalog-as-projection`). An effect op's parameters are named as a
   function's are: the medium proposes each name from what its handlers' arms
   bind and asks where they disagree, `mentl tighten` writes the sweep, and the
   positional form then refuses (`E_UnnamedParameter`). Every filesystem
   failure is said — an unreadable path performs `Fail`, never answers an empty
   string or a sentinel handle. A type name that resolves nowhere refuses
`E_MissingVariable` at the name, where `fn f(x: Nope) = x + 1` refuses as
arithmetic on `Nope` (measured 2026-10-21). `mentl diagnostics` projects the catalog
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
   in one pass; deforestation is an `Iterate`-algebra e-graph rewrite. V5: a
   `<~` cycle's clock is inferred, so a cycle nothing advances is refused as
   a measurement (`Hβ.dataflow.clock-calculus-sample-rate`); its depth may be
   a value the ring reads at run time (`Hβ.dataflow.delay-line-runtime-depth`);
   and the delay spec is the static depth the emit already treats it as,
   never an expression judged in a dropped frame
   (`Hβ.effects.feedback-row-substitutes`). The line is read at a moving,
   fractional tap — a chorus, a flanger, a pitch shift — as well as at its
   oldest slot; a decaying line flushes a denormal in its tick, since wasm
   has no flush-to-zero mode; a stage's coefficient is computed when its
   input moves, never once per sample (`compute_alpha`'s `exp` runs per tick
   in every filter today); and a `<|` or `><` join aligns branches of known
   latency or refuses the misaligned merge (measured 2026-10-21, after a
   survey of Sonido).
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
   what inference derives narrated as the inventory it is. The voice absorbs
   the comment mass that states mechanism
   (`Hβ.voice.comment-mass-absorbs-into-projections`), and the Why's thin
   hops name a call argument's flow (`Hβ.why.flow-naming-at-call`) and a
   refined alias's provenance (`Hβ.why.refinement-provenance`) and elide the
   trivial ones (`Hβ.viz.why-walk-elides-trivial-hops`).
9. **An op lives where its behaviour belongs**
   (`Hβ.effects.op-lives-where-its-behaviour-belongs`,
   `Hβ.memory.word-arithmetic-is-memory`). A `*Write` effect's ops write and a
   `*Read` effect's read, held by a census at zero read through the published
   write fact: `graph_version` and `graph_attach_comment_ref` move into
   GraphWrite. Word
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
10. **Handlers installed once.** One install per extent; a handler's start
    state its own; a chain named once; nothing installed only to swallow an op
    nobody reads. A handler named as a value is its record
    (`Hβ.effects.handler-value-is-its-record`): `let h = one` binds it, a
    parameter holds it, and an install of a value pushes the record it holds
    and absorbs the effect its `Handler(P, A)` type names — today the value's
    emit names a global nothing defines, and the module does not assemble. A
    generic op is quantified per perform, so two instantiations of one effect
    do not join at an install
    (`Hβ.effects.two-instances-of-one-effect-do-not-join`).
11. **The medium authors the migration — iteration is topology**
    (`Hβ.wheel.iteration-is-topology`). The costume detector convicts index flow
    (a parameter threaded ±k into an index read), with let-chains, nested-call
    pipes, `<|`/`><` invitations, repeated install suffixes and partial eta
    (`(row) => dot(row, x)`) as shapes, the multi-parameter lambda retiring
    into a reference (`Hβ.syntax.multi-param-lambda-is-a-reference`); tighten
    rewrites by edge, the prelude's
    datum-first signatures (`reduce`, `scanl`, `nth`, `clamp`) among them; a
    speculation's cursor is an arena with an overlay. Recursion that survives
    is priced by a signature. The structural folds the
    emitter derives over a sequence — `==`, compare, hash and show — are loops,
    where each is emitted today as one call per element, so two lists of
    twenty thousand pairs exhaust the stack where they are compared (measured
    2026-10-16, first by the rename's edge lists), and the prelude's `sort`
    exhausts it at twenty thousand elements, its `merge` one call per
    element. A Float compares, equals and hashes in IEEE total order inside
    those folds, so `[nan] == [nan]` agrees with `a == a` and `sort` places
    a NaN, where it answers `[0.0, 0.0, 2.0, NaN, 1.0]` for `[1.0, NaN,
    -0.0, 0.0, 2.0]` today; `<` on a Float stays IEEE for arithmetic
    (measured 2026-10-21, after a survey of Turbosort).
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
    A comment inside an expression attaches by the span rule the gate measures
    (`Hβ.parser.expr-interior-comment-attach`).
    The batteries address a hole and a declaration by identity, never by
    `L:C`, so every fixture can be canonical; `mentl fmt --check` at zero over
    src, lib, examples and tests is a board line.
13. **The page plays the course** (`Hβ.space.the-canvas`,
    `Hβ.emit.the-medium-assembles-its-output`, `Hβ.viz.severance-map`). The
    course is written — `examples/pulse/course`, ten lessons on one growing
    chain a developer hears, each a program `mentl run` renders, the page
    opening the folder as a project, and `mentl verify` counting the lessons
    the medium cannot yet judge clean (the `QOwed` bounds, src/board.mn). The
    canvas paints the wheel's own tokens at their spans, the aspect strip and
    the ambient-world glyphs, obligation marks, the ownership trace, fmt on
    idle and a version as undo. The page runs what it compiles: the worker
    instantiates the bytes `mentl asm` writes, a lesson plays to the speaker,
    and the fixpoint seal runs in the page. The page's remaining faces are
    named: the View as graph content (`Hβ.space.view-is-graph-content`), a
    folder pick outside Chromium (`Hβ.felt.project-picker-outside-chromium`),
    the run in the page (`Hβ.felt.ide-run-in-page`), the ambient-world gutter
    (`Hβ.viz.ambient-world-gutter`), the living runtime's render loop
    (`Hβ.felt.mentl-edit-runtime`), typed demand-driven reactivity
    (`Hβ.felt.reactivity-typed-demand-driven`), time travel over the forks
    (`Hβ.felt.time-travel-debug-forked-cursor`), and the terminal session
    reading more than one action (`Hβ.felt.edit-session-reads-one-action`).
    The Severance Map bands the module
    and declaration tree in three colours — provably absent, present, not yet
    provable — the third counted and falling; it ships after its known false
    greens close or counts them in the third colour, and its demo is
    Wasatch's network twin turning a green band red with the refusal naming
    the call. Then the stranger test: someone who has never seen the
    repository finishes lesson 1 from the README alone.
14. **Wasatch "Inversion" — the sources and the player**
    (`Hβ.wasatch.keyed-sources`, `Hβ.env.configuration-is-an-effect`). The
    score is written and renders from its snapshot (`examples/wasatch`: every
    parameter a reading of Salt Lake on the evening of 2026-10-20, each with
    its source and its time; the per-sample path `!Network + !Filesystem +
    !Alloc + !Sample(44100)`; the frontier's twin fetching one parameter on
    that path refused). What remains is the live half: the keyed sources
    (UTA's real-time TRAX first, then the gauges and the observation the
    snapshot was read from) through a host-applied key the guest never holds
    — the open half of configuration as an effect — and the score played in
    the page as the readings change.
15. **The reading's remaining faces** (`Hβ.derive.vector-forward`,
    `Hβ.derive.gradient-as-a-value`, `Hβ.derive.transpose-through-iteration`,
    `Hβ.derive.transpose-through-the-record`,
    `Hβ.derive.bptt-priced-by-the-row`, `Hβ.derive.closure-line-tangent`,
    `Hβ.lower.ad-is-a-demanded-projection`). A product seed is answered
    through a call made through a value, a perform, a `<~` line, a record
    carrying a tangent, an install, an early return, a query inside a callee
    and a recursion, where the reverse projection refuses today naming the
    vector-forward reading; a gradient held as a value is a record the row
    sees; the transpose crosses iteration and the record; a `<~` line's
    history is priced by the row; a line a closure record owns carries its
    tangent; and arithmetic on a user type arrives as a numeric projection's
    rules, the same mechanism that makes a chain differentiable.
16. **The compile runs on every core** (`Hβ.driver.level-set-par-walk`,
    `Hβ.native.deterministic-handle-partition`). A handle becomes an
    `{arena, offset}` product (one word by a repr pin), deterministic under any
    order; the schedule is a pool; emission, the classifier rounds and the
    judgment's binding-group levels are fanouts; the battery judges its library
    once; Pulse renders by block under `parallel_compose`. A branch's answer
    crosses the join at its own width — the task record holds a Float as a
    double and the schedule's arms are twinned at the install's answer, where
    today they are emitted once at the word face and a Float-answering
    `fanout` under `parallel_compose` traps at its join. A schedule reaches a
    fanout through a function value minted under it
    (`Hβ.lower.schedule-through-a-value`). Two branches writing disjoint
    ranges of one buffer run, each owning its slice of the memory the fanout
    hands it, where today they refuse as one buffer written from every
    instance, and the refusal's advice names a stateless handler for an
    effect with no ops. Every step is gated by
    m3 under `Seq` byte-identical to m3 under `parallel_compose`.
17. **Verify's own solver** (`Hβ.verify.the-solver-is-the-search`). The
    proposer's search is the solver: union-find and the e-graph as congruence
    closure, the chain of forked instances as the assignment stack, a fork as a case split,
    the first divergence of two forks' write sets as conflict analysis. The fragment, in the order the
    wheel's own debt names it: overflow-aware intervals, linear arithmetic
    beyond the difference bounds the path is read in, equality from the
    e-graph. An external solver plugs in only as a proposer
    whose certificate the kernel checks.
18. **The remaining faces of the one law.** Schemes are edges
    (`Hβ.infer.schemes-are-edges`: instantiation a correspondence edge, never a
    clone); a `Reason` is an edge to the node it names, never a copied tree;
    lowering is columns on the program's own handles, the `LowExpr` tree and its
    walkers deleted (`Hβ.lower.lowering-is-a-column`) — a lowered unit is a
    column on its declaration's handle, where its identity is the symbol
    `LFn(String, …)` carries and the emit's and the reading's reach walks
    (`plan_reached`, `reach_units`) key their units by it; the gate is m3 ==
    m4 with the symbol-keyed walks deleted; a continuation is
    its frame's record in the image and the node it stopped at, captured by a
    copy and resumed by entering the frame's one function at that node, where
    the lowering copies the frame's tail into a function of its own at each
    place the frame can suspend (`capture_frame`), so a block with n such
    places writes its tail n times; a module value is a
    column on its binder, so a module-scope let binds every binder its pattern
    writes, each at a global of its own, and runs its value for effect when it
    binds none, where any pattern but one binder refuses today; an
    executable's row is `main`'s and its inits'
    (`Hβ.effects.executable-row-includes-inits`); an arm's resume
    grade is a column on the arm, written once where its op edge is drawn, and
    a nested fn's grade a column on its declaration, where every reader of an
    arm's discipline grades the arm again (`arm_grade`: the op edge, the
    never-returning op's check, the continuation's discipline, the session's
    comparison), each re-running the arm's fixpoint and scanning its
    declarations per reference; incrementality reads an edit's delta as two
    versions compared (`Hβ.graph.delta-is-two-versions`), the
    session paying for what an edit moved (`Hβ.session.edit-pays-for-the-program`)
    and outliving its process (`Hβ.felt.accept-outlives-the-process`); persist
    resumes across machines (`Hβ.persist.cross-machine-resume`); and a call's
    answer read off a tee — a fold's accumulator, a handler's answer — is
    memory the store-age walk cannot place, where the install's arms say what
    the body's answer can be, as the value walk already reads them
    (`Hβ.effects.tee-answer-is-the-arms`).
19. **Every record lives where its extent does**
    (`Hβ.lower.install-record-in-the-frame`,
    `Hβ.lower.captureless-nested-fn-is-static`,
    `Hβ.lower.held-resume-record-is-not-reclaimed`,
    `Hβ.arena.closure-evac-face`, `Hβ.arena.extent-spanning-a-spawn-keeps`,
    `Hβ.value.seq-element-stride-carrier`,
    `Hβ.lower.parameter-product-calling-convention`). An install whose record
    never outlives its extent lives in the frame and costs nothing; a nested
    fn that captures nothing is the module's static record; a held resume's
    record is dropped after its one call; an arena's exit moves a value whose
    type the store cannot see, and reclaims across a spawn its instance makes;
    a list's element crosses its slot at its own width, so a Float is never
    boxed to cross a word slot; and a pair handed to a one-parameter literal
    and two arguments handed to a two-parameter function are one calling
    convention. Each charge follows the representation the day the lowering
    builds it, so `!Alloc` accepts what allocates nothing.

---

Excluded by hardware only: MI300X execution, wasmFX, shared-everything threads.
