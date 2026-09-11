# Mentl — PLAN.md

> **THE THREE-DOCUMENT CONTRACT.** Claude reads and updates exactly three
> self-contained documents, and reads ALL THREE every session:
> - **`CLAUDE.md`** — *method*: how to work (anchors, verbs, drift modes, the
>   interrogate-don't-absorb law).
> - **`PLAN.md`** (this file) — *substance*: what is true (the reframe, the
>   kernel, the resolved decisions, the arc, the state, the laws).
> - **`SYNTAX.md`** — *surface*: the authoritative language form; supersedes any
>   syntactic claim made here or in `CLAUDE.md`.
>
> Method / substance / surface — the three docs are shaped like the medium
> itself (three projections of one graph), so a claim that fits no layer has
> nowhere to hide. Each truth has **exactly one home**; the other docs point by
> layer, never re-assert (this is how the docs can't drift against each other).
> The 56k lines of `docs/specs/**`, the `~/.claude/plans/*` variations, and the
> 85 memory protocols are **git archaeology, out of the read-path**. "Read the
> three docs" is sufficient, forever. **Context cost is NOT a constraint
> (Morgan, 2026-06-18): completeness wins** — Claude must hold the ENTIRETY of
> what Mentl is, every session, not a distilled recollection. Exhaustive in
> coverage; elegant where it can be; never abbreviated at the cost of a truth.

---

## §0 · What Mentl IS — the reframe (the north star)

**Mentl is humanity's verification substrate for the age of machine-generated
code.** Any intelligence may *propose*; nothing *executes* unproven; intent is
never lost; capability is always bounded.

The received wisdom — "AI writes the code, so the language stops mattering" — is
**backwards**. The more code machines generate, the more the bottleneck moves
from *writing* to *trusting*. Five properties define the substrate:

1. **Proof beats review** — when no human authored it, "looks right" is
   worthless. Proof has no ceiling; approximation asymptotes.
2. **The negative is provable** — `!E` under polymorphism: absence under
   handler/install IDENTITY, under modality, under TIME, and per-INSTANCE
   (`!Sample(44100)`). **Mentl's most underrated arm and the future's deepest
   need.**
3. **Intent is lossless** — the Reason chain carries the *why*, walkable to root.
4. **Computation is durable** — multi-shot continuation, persisted.
5. **Systems explain themselves** — the cursor projects live truth at any point.

**Mentl's value is *inversely* correlated with human authorship — antifragile to
AI progress.** The convergence: the same choices return from three independent
directions — what makes Mentl *ultimate*, what *humanity* will need, and what's
best for *the makers*. The Carried-Truth Law is one law at three scales: Mentl's
kernel never fabricates a fact it can read live; software for humanity must never
hallucinate intent; Claude must carry real reasoning, never perform confidence.

**Arche and telos** (crystallized 2026-07-13, adversarial refutation held). The
**generative root is the kernel**: one graph, two operations, `!Outside`. The
**developer is the telos** — proof wins whenever it meets convenience because
proof *serves* the developer better than an ergonomic lie. **The developer's
intent→expression gap and civilization's machine-authored-code trust gap are the
SAME invariant — the Carried-Truth Law — read at two scales.** Guardrail: keep
the framing tethered to the actual developer at the keyboard.

**`!Outside` scope** (§1): **toolchain reflexivity** — every lever to improve the
medium is already inside it. Does NOT close the **intent space** (specs are born
in the human's head) nor the **capability space** (Rice: sound-and-incomplete,
accruing honest `V_Pending` debt). Two named residual Outsides: the external-SMT
(`Hβ.verify.smt-handler-swap`) and the internal correctness oracle
(`Hβ.closure.correctness-oracle-internal`).

`!Outside` is not a new runtime effect beside `Alloc`, `Thread`, or `Flow`. It is
the closure verdict projected over the existing medium: if improving Mentl still
requires a tool, server, verifier, proposer, transport, memory model, or build
step outside Mentl, that edge remains open. Closing it means absorbing that lever
into the graph, rows, `~>` handlers, `TCont` worlds, image columns, or `mentl
space` — never minting a parallel feature named Outside.

Mentl is not a programming language with good features. It is a **medium** — a
lens so clear the developer looks through it and sees their program, not the
language. The programs are the means; **the developer they become is the end.**

---

## §1 · The thesis — the fixed point (`!Outside`)

A tool you can surpass has its means of improvement *outside* it (to beat X you
write Y). **The ultimate medium has no outside.** The compiler is a handler on
its own graph (self-hosting); the IDE is a projection; the proof system is the
kernel; the oracle is incremental-computation plus one cached value; even
*designing* the medium is a `<~` loop folding back into its docs.

- **Unsurpassability is `!Outside`** — the medium's own negation primitive at
  topology altitude. As `!E` proves the absence of a capability, the fixed point
  proves the absence of an outside.
- **Closed over proposers** — any intelligence plugs in as a `Synth` handler
  whose candidates must survive checkpoint → infer → Verify → rollback before
  any human trusts one (OGIS/Synth-Modulo-Oracles). A stronger proposer strictly
  strengthens the medium and can never surpass it. The unit of conversation with
  the medium is the **constraint** (lossless, monotone, compounding), not the
  token (lossy, decaying). **Proof is a MONOTONE FILTER, not a generator** —
  total at instruction-selection, partial at authorship. The dispatch among
  survivors is exogenous (human intent or a `Synth` ranker behind the gate).
- **The medium is the best next-move proposer.** At cursor scope, the medium
  proposes by GUIDED search over the typed graph (rows, Reasons, refinements,
  ownership, proximity), pruned by proof at every step — a structural prior
  richer than a token-window. When survivors tie, the medium surfaces the ONE
  missing constraint (the teaching tie-break), never guesses. **"Cut the model
  out" holds at next-move scope.**
- **THE CLOSED LOOP (Morgan, 2026-07-28):** the loop closes to the HUMAN and
  MENTL, no LLM advantageous at any scope. Three legs: (1) next-move supremacy —
  guided search extraction-optimal per §5; (2) the question beats the guess — the
  teaching tie-break dissolves the underdetermined tail into proven next-moves;
  (3) the loop is felt — the fused oracle makes the cycle instant enough to live
  in. The Synth port stays universal by construction; the target is that nothing
  ever needs to arrive through it.
- **Validated from six directions.** Faust: verbs, no effects. JAX: handlers, no
  graph. Temporal: continuations, no types. Rust: ownership, no effect row.
  Effect-TS: effects, hostile host. Solid: feedback, no proof. **Mentl is the
  convergence point — the body none of them had.**

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
> following the edge is the canonical re-derivation — the §7 registry trap in one
> sentence. Follow the edge; read the live node; never re-resolve by name what the
> graph already connected.

**The irreducible bottom is not eight things.** It is the **graph** (nodes carry
values; typed edges carry types, effects, ownership, refinement, Reasons) and
two operations: **WRITE** = inference (the one writer, HM-live, every edge
justified by a Reason) and **READ** = the cursor projecting the graph at a
position. "The Graph IS the Program — source, WAT, docs, LSP, errors are all
*projections*; the graph is the truth, everything else a shadow."

**The octopus is one nervous system with eight arms — not eight brains.** The
"eight primitives" are the **eight aspects of every cursor-read** (= the eight
interrogations = the eight tentacles = the method and the voice). Three of them
(ownership, refinement, gradient) are *grown from* the others, exactly as the
substrate already admits ("ownership IS an effect"; the gradient is "derived";
refinement is `Verify`+a predicate). Keeping them as eight independent axioms
over-counts the bottom; keeping them as eight arms of one read is the honest
ultimate form — fewer axioms, identical reach, and it resolves the long-standing
"eight primitives" vs "eight aspects of one read" contradiction the old docs
held in two places.

**Every subsystem is the one read in a different mode** — there is no second
mechanism:

| Subsystem | = cursor-read mode |
|---|---|
| compile order | sequential cursor |
| incrementality (the oracle's IC) | cached cursor |
| multi-shot exploration / durable execution | forked cursor |
| truth / the Why Engine | reasoned cursor (a Reason edge per read) |
| proof | verified cursor (`~> verify`) |
| multithreading | parallel cursor (Thread handler) |
| infer / lower / emit / native / GPU | projected cursor (each aspect → a target token; "the handler IS the backend") |
| the felt surface / propose / reactivity | proposing cursor (gradient at `??`) |

**The three deepest capabilities are not features — they are the three AXES of
the one read, and every primitive is interrogated against them (the generative
audit, run alongside the reductive "does the graph already know this?").**
- **Memory = the SUBSTRATE.** One flat linear-memory image; every node and value
  a handle-addressed record; the bump allocator monotonic (determinism =
  fixpoint); sequences are `[len][bytes]`/`[−1][buf][start][len]` views. The
  **unified heap record** makes *handler = state = closure = evidence =
  continuation* ONE shape — so a continuation is a contiguous record and thus
  `memcpy`-serializable: **durable execution falls out of the memory model**
  (the 2025 cloud field reimplements this with bespoke heap-walking serializers).
- **Multi-shot = TIME.** Fork (trail-checkpoint) / cache (the IC cursor memoizes
  live reads by epoch — so "read live" is the semantics and "cached" is the
  mechanism, never hand-rolled) / persist (continuation to disk) the graph across
  versions. The oracle's search, the cached cursor, and durable execution are ONE
  primitive distinguished only by which handler catches the resume (§4④).
- **Threading = SPACE.** Parallel cursors read the shared image lock-free and fork
  to per-thread trails; compile, IDE, prover, and oracle-search are the same graph
  read at many positions (per-thread bump arenas + inference-stable handles =
  deterministic parallel codegen).

The cursor projected through {substrate, time, space} IS the subsystem table
above; **the oracle FUSES all three** — N forked cursors on N threads over one
shared-memory graph with per-fork rollback (trail/rollback + wasi-threads
substrate landed; continuation-reification codegen LANDED — k1 through the M1–M4
cut, self-hosted through first-light (§7); the fused N-thread oracle SEARCH over it
is the open reach). *Best
current organizing answer; interrogate it (§9.9).*

**The eight arms** (project all eight at every cursor before a line; type the
residue): **Graph?** (handle/edge/Reason) · **Handler?** (which projects this,
with what resume cardinality) · **Verb?** (`\|> <\| >< ~> <~`) · **Row?**
(`+ - & ! Pure`) · **Ownership?** (`own`/`ref`, `Consume`/`!Alloc`/`!Mutate`) ·
**Refinement?** (predicate / `Verify`) · **Gradient?** (annotation-as-input
unlocking capability) · **Reason?** (the edge for the Why Engine).

---

## §3 · The bottom-up construction — every layer a mode of the one read

Build L0 upward; each layer's shape is forced by the one below; a non-ultimate
fundamental poisons everything above (the `++`/`String` trap was L1 poisoning
L2). Each layer is the cursor-read in a mode.

- **L0 · The graph.** Nodes + typed edges, live, flat-array O(1) chase,
  epoch-versioned, trail-backed for checkpoint/rollback. The universal
  representation. *Only inference writes.*
- **L1 · The value ontology** — **five node-kinds**: *word* (the machine atom),
  *sequence* (ordered), *product* (record; tuple = positional product), *sum*
  (variant), *function* (closure-with-evidence). Everything else is a **view**
  (§4①).
- **L2 · Topology + cost.** The five verbs draw the shape; the Boolean effect
  row says what crossing an edge requires or forbids (§4②, §4③).
- **L3 · The dynamics.** Handlers + typed resume — the one mechanism;
  themselves graph content (installed via `~>`, typed by inference, projected to
  a backend by the read). Multi-shot is the universal substrate (§4④).
- **L4 · The write.** HM inference, one walk, productive-under-error, every bind
  a Reason. Ownership / effect-row / refinement all *inferred*; authored
  annotations are *constraints verified against* the inferred (§4⑤).
- **L5 · The surface.** The minimal text that makes each kernel aspect reachable
  — `SYNTAX.md`'s domain. Annotations are *inputs to the cursor*, never the
  emergent property.
- **L6 · The felt experience.** The cursor as the gradient's argmax: the Why
  button, `mentl where/edit`, the verification dashboard, fine-grained
  reactivity — all the graph projected for a human. Co-equal, not an afterthought
  (§4⑦).
- **L7 · The closure.** `!Outside` / self-hosting. First-light is **the FIXED
  POINT — the medium reproduced exactly by itself**: `m_n.wat == m_{n+1}.wat`,
  paired with correctness (a buggy compiler self-reproduces to a *wrong*
  fixpoint, so the micros + repro are the second half of the check). The smallest
  instance of `!Outside`, not a build chore. NOT `m2 == m3`: the seed is
  disposable and its bytes need not match the wheel's own output — for a change
  to the compiler's OWN inference the fixed point lands at `m3 == m4` (mechanics:
  §6). The seed's one job is a *correct* `m2`; the flame reproducing itself is
  first-light.

---

## §4 · The resolved decisions — the kernel, not questions

*Decided 2026-06-18. Resolved as kernel — interrogate them still (CLAUDE.md) but
the burden of proof is now on the challenger.*

**① Value ontology — five node-kinds, everything else derived.** `Bool` =
`False | True` (a derived ADT). `Int`/`Float` = *word* + representation-gradient.
`String` = *sequence of byte* + text/interpolation view. The `str_concat`-vs-
`list_concat` split does not exist at the bottom — there is sequence-concat, and
the read picks the representation ("the proof becomes the dispatch").

**② The verbs — five, validated from outside by Faust.** Faust independently
arrived at four: split `<:` ≡ `<|`, recursive `~` ≡ `<~`, sequential `:` ≡ `|>`,
parallel `,` ≡ `><`. Merge folds into `|> merge_fn` (named values + tuple-
unification). `~>` (handler/effects) is the arm Faust lacks: **Mentl = Faust's
topology + handlers.** Five verbs, settled.

**③ THE CROWN — the effect system: rows-with-negation; modal is the TARGET, the
graph is the ROUTE.** Decision: keep rows-with-negation — **never trade away
`!E`**. Hold the **modal synthesis** (Tang–Lindley line, POPL 2026 arXiv
2507.10301 — rows≡capabilities proven) as the unsurpassable-tier TARGET. The
defining question: *can capabilities' no-leak threading coexist with rows'
Boolean negation?* The rows≡capabilities half is discharged in the literature;
the **NEGATION half** is the open burden. Row representation: `EfRow(present,
absent, tail)` with `EffTail = EtClosed | EtVar | EtAll`; negation IS the absent
field. The adversarial soundness GATE LANDED (2026-07-13, `row_subsumes` EfNeg
by-name membership; tests/crown/, crown-gate.sh; m2==m3 byte-identical).
Open in band A: the modal world-index, `Hβ.effects.parameterized-negation-
instance`. **(b) TIME axis**: `TCont(R, S, ResumeDiscipline, EffRow)` LANDED —
the effect-WORLD on the continuation, unify-time gates LIVE (discipline mismatch
raises `E_ResumeWorldMismatch`; the world unifies as a row). Band B's open work:
the runtime value gate. **The graph is the ROUTE:** Mentl's unified-evidence
substrate lets the modality be **inferred and cursor-projected** (a graph fact,
never authored). Real before perfect: the modal world-index is the long game.

**④ Multi-shot is ONE substrate for five things.** Search (oracle), sampling
(ML), backtracking, *and durable execution* (Temporal/Restate/DBOS) are the same
primitive: a resumable continuation, distinguished only by which handler catches
the resume. **Persistence is a handler swap.** Mentl's oracle and the workflow
engine are *literally the same arm*.

**⑤ Ownership — inferred `own`/`ref`, held to the Hylo-quiet bar.** Ownership-
as-inferred-effect (`own` performs `Consume`; `ref` is a row constraint; filled
from use-count). **The measured invariant: if the developer has to think about
it, the inference failed.**

**⑥ The IFC frontier — the row carries information *flow*, not only capability
presence.** `!E` + `~>` already subsumes capability-security. The extension: a
row expressing "this `Secret` may not flow to `Log`" — non-interference proven
like `!Alloc`. Sequenced as Phase 7 (§11).

**⑦ The felt experience is co-equal — reactivity IS the cursor's `<~`.** The
cursor re-projecting on graph delta at the human boundary IS fine-grained
reactivity, incremental compilation, and collab. L6 is not Stage-3 garnish.

---

## §5 · real · felt · unsurpassable — three aspects of one ultimate form

**Apply Mentl's own gradient to Mentl's own development.** These are NOT a
sequence — they are three ASPECTS of the one ultimate form, written in FULL. You
write the ultimate `.mn` answering only to "what is the ultimate form?"; the
disposable seed catches up afterward. first-light ARRIVES when the complete wheel
meets a caught-up seed; it is not a gate chased ahead of the form.

1. **REAL — it WORKS.** End-to-end compilation, micros green, wheel emits correct WAT.
2. **FELT — the human surface (L6).** `mentl where/why/edit`, the gradient, the
   Why button, reactivity — these *fall out as projections*, not added on top.
3. **UNSURPASSABLE — the frontier.** Modal effect synthesis (§4③), IFC (§4⑥),
   durable-execution-as-handler (§4④), value-ontology (§4①), Verify→SMT, native/
   GPU backends, e-graph. Each a move *within* the medium.

   **The felt endpoint:** a `??` is a typed CONSTRAINT; the cursor forks a finite,
   latency-budgeted set of candidates, each run checkpoint → infer → Verify →
   rollback on its own trail, only proven survivors surface. The ranker reads
   **local intent** (Reason chains, proximity, in-scope vocabulary); the
   tie-break TEACHES (surfaces the one missing constraint, never guesses).
   Verify commits to a decidable refinement fragment or emits honest `V_Pending`
   debt — never a silent assume-true.

   **THE OPTIMALITY HALF (Morgan 2026-07-28):** a proposal is not merely proven,
   it is extraction-OPTIMAL. A survivor is an equality CLASS: the e-graph
   saturates the proven fill under effect-aware rewrites, extraction picks cost-
   minimal, repr gradient pins widths, native projection makes "best instruction"
   literal. Superoptimization as the default authoring experience.

   **THE FORK/MERGE DUALITY** (crystallized 2026-07-30):
   - **MEANING-space is explored by FORKING; FORM-space by MERGING.** Fan
     candidates MEAN different things (each needs isolation — checkpoint, per-
     branch world, rollback — because candidates CONFLICT). E-graph members mean
     the SAME thing (merging needs no isolation; saturation is monotone).
   - **Proof is a FILTER over meaning (binary); cost is an ORDER over form (total).**
   - **A TIE IN FORM-SPACE IS FREE; A TIE IN MEANING-SPACE IS A QUESTION.** Two
     cost-minimal members are equal — pick either. Two proven survivors MEAN
     different things — the medium must ASK. This is where the human is
     irreplaceable, derived here rather than asserted.
   - **The order is FORCED:** extract-then-prove optimizes a program that may be
     inadmissible; prove-then-extract is the only sound composition.
   - **The effect row plays BOTH halves:** gates which REWRITES are legal (a
     dropping rewrite fires only when the dropped operand's row subsumes pure)
     AND which CANDIDATES are legal. One algebra, two altitudes.
   STATE: the fan rides real spawned branch cursors; the e-graph is live and
   effect-aware in lower. They are NOT yet fused — building the composition is
   what makes a proposal extraction-optimal rather than merely proven.



### §5.U · The value layer — four projections of one cursor on one heap record

*Verified by a 21-agent adversarial workflow; the inevitable form, not a choice.*

**The four deepest value-layer axes are NOT four features — they are ONE cursor
reading ONE heap record at four altitudes, joined at one emit-time read:
`match lookup_ty(h)`.** That read already exists — `emit_binop_for`
(`backends/wasm.mn`) dispatches `++`/`==` on `lookup_ty(left)` ("the proof
becomes the dispatch"); the AST-in-graph fabric put the handle on every node, and
lower threads it on every LowExpr. There is no second mechanism to build — only a
**refusal-to-read at four slots, deleted**. The shared record is PLAN §6's
`[fn_ptr@0][nstate@4][state@8..][arms][captured_evs]` — *handler = state =
closure = evidence = continuation*, now extended: **= branch-thunk = fold-target =
representation-host**, ONE contiguous handle-addressed shape:

- **REPRESENTATION GRADIENT (the field widths).** `repr_of(lookup_ty(h))` projects
  `Repr = RI32 | RI64 | RF64 | RF32 | RV128` (an ADT; `repr_width` 4/8/16 by match,
  never `==4`). i32 is the floor; i64/f64/f32/v128 are gradient cash-outs. The
  record POINTER stays a word (a handle IS a word) — handle-uniformity and
  memcpy-serializability survive while fields gain real precision. Today `3.14`
  silently emits `(i32.const 0)` (the developer's value becomes ZERO); the gradient
  makes it native unboxed f64 — no NaN-tax, no box, no tag, and the boxed-float
  peer (OCaml's alloc-per-op disease, fatal to DSP) is unsayable.
- **MULTI-SHOT CONTINUATION (the same record FROZEN at a resume site, TIME
  altitude).** `LMakeContinuation` is dimensionally `LMakeClosure + state_index +
  ret_slot` — CONSTRUCTED at STEP 3 (7b72790, the write-only resume_kinds ledger
  dissolved); the k1→M4 arc self-hosted the producer through the fixpoint.
  Read the op's cardinality LIVE: OneShot → `LReturn` (byte-identical, ~85%);
  MultiShot → the dormant continuation record. Because it is one contiguous
  handle-addressed record in the monotonic bump image, **persist = `memcpy`** —
  durable execution falls out of the memory model, zero serializer. The
  write-only `resume_kinds` side-ledger (zero readers) is the textbook
  Carried-Truth violation; the cardinality rides the TCont.
- **PARALLEL TOPOLOGY (the same record FORKED as N branch thunks, SPACE
  altitude).** The thunk is portable across a thread boundary, packable into a
  v128 lane (the gradient's vector cash-out), shippable to a device, or persisted
  mid-flight (a crashed branch re-runs from its memcpy'd thunk — SPACE and TIME
  are the same arm, §4④). The verb is PURE TOPOLOGY contributing zero effects
  (delete the hardwired `Thread` injection); a `~> Schedule` handler reads the
  live handler stack to pick `Seq | Thread | Simd | Gpu` (an ADT, never an int).
- **STRUCTURAL FOLD (the record's TYPE-node recursed by SHAPE, the read itself).**
  `==`/compare/hash/show/pack/unpack are one `fold(ty, leaf)` over the five
  node-kinds; the word-leaf reads the gradient (`f64.eq` for an f64 field), the
  function-leaf serializes a continuation by memcpy. **The eq leaf is total NOW**
  (`emit_eq_leaves`, `backends/wasm.mn`): word / sequence / product landed
  earlier, and the SUM leaf (`emit_eq_leaf_sum` — sentinel-guard + tag-
  compare + per-variant payload recursion, the variant specs read LIVE from the
  env's `ConstructorScheme` via `variant_specs_of`, the same channel synth's
  `ctors_of_type` reads) closes the fifth node-kind — so `==` is total over every
  ADT to the bottom, the eq/hash-divergence footgun structurally unsayable. The
  remaining leaves (show / compare / hash) generalize the SAME generator into
  `fold(ty, leaf)`, retiring the two hand-copies (the `lower_to_string`
  aggregate fall-through; a generated `compare`/`hash` leaf) — LESS code,
  sequenced on STEP 0/1's repr word-leaf and STEP 5's `TCont`-world (the
  function-leaf's serialized-closure world). **The fold's TRAVERSALS are
  unified (2026-07-18, the unified each):** the five walks of the lowered
  tree (four per-leaf type-closure collectors + the show-literal
  re-collection) are ONE walk carrying the four closures as one record, and
  the four dedup walkers are ONE keyed by the FoldOp ADT — 25 fns deleted,
  the eq/cmp collectors' dropped-right-subtree class closed by construction
  (`LEDGER.md`). The LEAF GENERATORS remain four: conjunction / first-nonzero
  chain / FNV mix / concat tree are four real leaves of the one fold, not
  copies — their unification is the synthesize-as-lowered-LFn altitude
  (band D's `Hβ.fold.show-leaf` / `.compare-hash-leaf`), not a walker merge. There is NO pack/unpack leaf: the
  `.kai` cache layer and its `IKAI` tag-byte serializer were DELETED whole
  (2026-07-02 — the Inka-era incremental-compilation side-file; it snapshotted
  env entries lossily, DROPPING Reason chains, and pinned an archaeology wire
  format the fold was contorting around). Durability is persist-as-memcpy of
  the image (§4④) — a serializer leaf has nothing to serialize.
  **BOUNDARY (do not mis-flag):** types.mn's
  `show_type` / `show_reason` / `show_effrow` are the DOMAIN pretty-renderer — the
  *mentl voice*, a `~> Format` projection of the compiler's own metaschema for the
  Why engine and diagnostics — NOT the generic `show`-leaf of `fold(ty, leaf)`
  (which renders an arbitrary USER value). They are a different fold over a fixed
  ADT for a human reader, kept; never retired as a fold-copy.

**THE BINDING KEYSTONE — `TCont(R, S, ResumeDiscipline, EffRow)` — LANDED
IN TWO STRUCTURAL STEPS (27edc30 world index; executable-boundary R/S split).**
Carrying the **effect-WORLD** on the continuation lifts
`!E` to TIME (the modal frontier §4③ lands HERE): a persisted `k` resumed under
a changed handler-set is `E_ResumeWorldMismatch` — a compile-time error, not a
3am production corruption. The one arity change (the coordinated edit across
~14 destructure sites — a representation change, not a patch, per the
unpatchability theorem) went in with the seed mirrored in lockstep; the world
is INERT on the single-world OneShot path (resume-world micro = 42), and band
B's enforcement tier (the value gate, capture-at-reify) is the named remainder.
One edge, two arms.

**The six-step build arc** (each a Carried-Truth deletion the artifact already
names): **(0)** `repr_of(Ty) -> Repr` — the shared read, built once. **(1)** the
representation gradient — delete the arity-keyed i32 deciders, read the handle;
the `$ft`-table keys on the interned Repr-vector (a function type is a product;
`call_indirect`'s match IS structural-equality, so the arity-`$ftN` fork
dissolves). **(2)** the structural fold — three hand-walks → one
`fold(leaf, ty)`; lowest-risk, no arity ripple. **(3)** the multi-shot producer —
the additive half (OneShot byte-identical). **(4)** the parallel-topology collapse
— `PDiverge | PCompose` → one `PFanout` (share-vs-distribute an ownership aspect
read from use-count; Carried-Truth at the node layer). **(5)** the `TCont` arity —
the one coordinated breaking edit, the seed mirrored in lockstep (NOT a
census-shadow follow-up).

**The inevitability.** The four cannot be separated without re-introducing the
bug: you cannot reify a continuation without the gradient (its fields need real
widths or the persisted f64 state corrupts); you cannot persist a thunk without
the unified record (no other serializer to write); you cannot type the fold's
function-leaf without TCont's world; you cannot schedule a fanout without the
record's portability (thunk = closure = continuation). The medium's own comments
named every fix, and every one is CLOSED: the Thread-drift peer (STEP 4,
600bc88), attach-to-TCont (STEP 5, 27edc30), the `$ftN` fork (deleted into the
one repr-vector walk, the m2 march), the product/sum eq floor (STEP 2 + the
sum leaf). This is
`!Outside` at the value layer: a better representation is a deeper `repr_of` arm;
a better schedule is a different `~>` handler; a sixth structural operation is
another leaf; stronger persistence is a different `Persist` catcher. Every lever
is already a move INSIDE the medium.

Write the ultimate form in FULL — all three aspects at once. A leap that advances
*unsurpassable* (the e-graph, the value layer) before the seed can self-host is
NOT premature: the seed catches up, and the census it raises is a SHADOW (§8),
never a reason to hedge the wheel against the seed (the one named drift, §9.6).

### §5.O · The O(1) architecture — performance IS the Carried-Truth Law

**O(1) means no re-deriving an already-addressed fact** (Morgan, 2026-07-13,
trued 2026-08-25). Not an aspiration — the Carried-Truth Law read at the
performance scale. The kernel is one graph whose native access is the flat-array
handle chase (§2), so a super-constant lookup for a fact already connected by a
handle is not "work"; it is a discarded edge. **"O(1) only" means: follow the
edge, never re-scan by name, shape, list position, or side ledger.**

**THE LAW, IN ITS ULTIMATE FORM — and the excuse it replaces (Morgan,
2026-09-07).** This paragraph used to read: *"Whole program actions keep their
honest bounds: compile is O(reachable image) … the law bans accidental
super-constant lookup; it does not ban the structural walks whose output is the
requested value."* That sentence was not an accounting. It was an ALIBI, and it
was written by an intelligence excusing a compiler that throws its own work
away — the exact thing this document's own §9.9 warns about, a permanent cost
called "honest" by the builder who did not want to pay it. It licensed
re-deriving, on every run, a result that could not have changed.

**Measured 2026-09-07, which is why the sentence is gone.** The compiler
persists its analyzed image and restores it (`persist = memcpy` is REAL —
`image_pack` is one `mem_copy(dst, 0, size)`), then re-ran saturate, lower,
reachability, the gate and emit over the restored graph **every single run**. A
five-line two-module program compiled warm in 5.75s against a ~2.0s process
floor: ~3.8s spent re-deriving bytes the previous run had already produced —
while the driver printed *"warm: image current — nothing re-derived."* The
message was true of INFERENCE and false of the compile. A scoped claim rendered
as an absolute is the same move as the paragraph it lived under.

**THE TWO COSTS ARE DIFFERENT AND THE OLD SENTENCE CONFLATED THEM:**
- **DERIVATION — computing a fact. O(1) amortized, no exceptions.** A fact is
  computed ONCE and read forever after. If the inputs did not change, the
  derivation cost is ZERO. This is the Carried-Truth Law extended over TIME:
  re-deriving across runs is the same violation as re-deriving across call
  sites, and the image is what makes "forever" reachable — one `mem_copy`
  carries every fact the last run proved.
- **DELIVERY — handing over a value. O(what was asked for).** You cannot
  produce N bytes in fewer than N operations. That is information, not
  overhead, and it is the ONLY irreducible cost in the medium.

**So the whole law is: the cost of an operation is the size of the answer it
was asked for, and nothing else.** Two corollaries, both enforceable: nothing
is re-derived (time), and nothing is derived that was not demanded (scope —
Arc D's `link-is-reachability` is this half). An operation whose cost grows
with the program while its ANSWER did not change is the law violated, whatever
bound it claims. **The test is falsifiable and it is a gate: change nothing,
compile again, and measure. A compiler that re-reads its own conclusions has
not earned the word "incremental."**

Everything the old sentence listed as a floor is one of the two above or it is
a defect: structural equality is O(1) when the graph already proved the two
handles equal and O(shape) only when it must look; proof re-discharges in the
changed cone alone; persistence is O(image bytes) once and O(dirty pages)
after. None of them licenses a re-derivation.

**The diagnosis (8-agent adversarial workflow, 2026-07-13 — the 22-min
self-compile).** The cost is 100% guest ALGORITHM: JIT is ~20ms, AOT marginal,
`wasm-opt -O2` a measured 4% regression (§8 — the cost is algorithmic, never
instruction slop). Seven independent readers converged on ONE class — the
compiler re-derives BY NAME what a HANDLE already connects:
- **`env_find_flat` — O(n²)** (pipeline.mn:375): a backward by-NAME linear
  `str_eq` scan of the ~2,036-entry flat env buffer per name resolution;
  pre_register_decls registers top-level names FIRST (so they sit deepest), and
  every stdlib reference (`map`/`fold`/`mint`/`N`/`Some`) scans to the bottom.
  ~1e5 refs × ~2k entries — the dominant compute O(n²). CONVERGENT (5 of 7 agents).
- **`dedup_fn_records` / `dedup_names` — O(U²)** (wasm.mn:1145/1168): the
  O(U³)→O(U²) concat-spine fix already landed this session (a flat-buffer
  `name_seen_at`/`fn_record_seen` membership scan over a preallocated `out`; the
  old `acc ++ [x]` spine made `list_index` O(depth) → O(U³), ~1.5e9 node-steps).
  Still super-constant — the O(1) target is a handle-set bit (layer 2).
- **`esc_assoc` — O(n²)** (lower.mn:1383): a name-keyed escaping-row side-ledger
  re-scanned per call site, three stacked passes.
- **`instantiate` → `subst_ty` tree-clone** (infer.mn:4185) + **`find_mapping`'s
  per-leaf `filter`-alloc** (infer.mn:4351): a full type-tree clone per
  polymorphic reference, garbage per TVar leaf. (Perf-trued 2026-07-24: the
  cluster samples at ~0% of the post-crc compile — its cost is ALLOCATION
  volume, the OOM channel, not time; the sharing fix gates on an alloc count.)
- **The 4GB never-free bump image** (memory.mn): ~1e8 transient records → a
  cache-hostile working set that MULTIPLIES the constant factor of every
  pointer-chase — the amplifier on all of the above.
- **Zero parallelism** (pipeline.mn:100): the whole self-compile is ONE sequential
  `|>` cursor, 8 cores idle; the level-set partition (driver.mn) is off the hot
  path.

**CORRECTION (2026-07-13) — the code-reading diagnosis MISSED the actual dominant
cost; empirical `perf` found it.** The 8 agents read code and estimated; the
biggest cost they named (env `env_find_flat`) measured 0.5–4% (below the ±14%
run-variance — fixing it moved nothing). The REAL dominant cost was the
**resume-cardinality classifier** (`classify_fixpoint`, infer.mn) — O(rounds ×
(N² + calls×N)), ~47% of the whole compile — which NO agent flagged, because a
static read can't see a fixpoint's round-count × per-call rescans compounding.
Host `perf` (§8, surviving `proc_exit`) pinned it at 98% of a sample; the O(1)
str_hash-index fix cut m3-gen 1400s → 749s (§7). The lesson is load-bearing for
this whole section: **measure the hot path with `perf`, never trust a
code-reading estimate — the ultimate-form target is still O(1) everywhere, but
which O(n^k) dominates is an empirical question.** The perf loop then VINDICATED
this end to end (§7, 2026-07-14): **1400s → 10s (~140×)** across seven
iterations, and the TWO biggest wins after the classifier — the reachability
per-frontier-name scan (58.66%, iter 6) and `iterate_from`'s snoc-list
`list_index` (48.85%, iter 7) — were ALSO absent from the 8-agent code-reading
diagnosis; both were found by profiling the fixed m2. The build loop is now
~20s (the boot compiler IS the fast wheel), so the O(1) march is cheap to
continue. The build-order layers below (name-is-handle → per-decl arena →
parallel cursors) remain the substrate-generalizing endpoint; the per-subsystem
str_hash indexes (env/summary/region/base/esc/reach) are the O(1) WAYPOINTS
they dissolve — a name is a HANDLE, and reachability an EDGE
(`Hβ.lower.reach-edge-on-node`), not a name scanned live.

**The unifying fix — a name is a HANDLE, not a byte-sequence.** Interned ONCE at
lex (the content-intern hash ALREADY exists at emit — `string_offset` is
O(1)-bucketed since the interner landed — but it is emit-scoped and offset-keyed;
the phase-A move is birthing the table at LEX, where scan_ident today mints a
fresh slice per occurrence and the canonical instance can be stored once). Then
every downstream compare is `i32.eq` (never `str_eq`), every table is
handle-keyed (O(1) index, never a name scan), every set is a handle-bit. This
dissolves env / dedup / find_mapping / esc into the graph's O(1) chase — LESS
code (delete every scanner) — and the byte-sequence survives only as a display
projection (arm 7's gradient cash-out: a name's ultimate representation is a word).

**COST IS ON THE BOARD (Morgan 2026-07-31, the OOM's law) —
RE-INSTRUMENTED 2026-08-07 (the arena's build step 0,
`Hβ.perf.per-decl-arena`).** The march's m3 leg — the self-compile —
runs under GNU time: the cost line prints per run, the pin's mechanical
block carries it, and `selfcompile_peak_kb_max` in verify-baseline
ratchets the peak (a breach refuses the repin, seen RED at ceiling 1).
Measured at the landing: ~8.4s wall, ~1.70GB peak RSS (three reads
within ±0.03% — the earlier "~694MB" claim was an era-stale number this
read corrects). The arena's win lands as that ceiling FALLING. state.sh
still shows the footprint; raising any ceiling stays an explicit
in-commit act, the census pattern applied to cost. Paid for by measurement: the judgment's peak moved
563MB → 3,044MB (07-25 → 07-29) across unmeasured landings and fell 823MB at
the rounds deletion, also unmeasured; a frontier edit-leg holding generations
in the never-free image reached 2,366MB and was the process the kernel killed
(2026-07-31) — layer 3's first field kill. The era-profile method (a
git-extracted boot compiling its own era's source under /usr/bin/time,
sha-stamped rows) is the standing backfill instrument; the 2026-07-31
session's reports under .build/research are its first corpus
(untracked session artifacts).

**The build order — each layer makes the next O(1):**
1. **Handle-interning substrate** (`Hβ.perf.name-is-handle`) — the string intern
   table goes O(1) (a `str_hash`-keyed index), every identifier a handle at lex.
   Load-bearing; everything else is O(1) off it.
2. **The O(1) reads** — `env_lookup` (handle-index → slot, `Hβ.perf.env-o1-index`),
   dedup (handle-set bit, `Hβ.emit.flat-accumulator-dedup` → handle-set),
   `find_mapping` (handle→handle chase), esc-rows (a FIELD on the fn's node read
   live, the side-ledger deleted, `Hβ.lower.esc-row-on-node`), instantiate
   (`Hβ.infer.instantiate-shares-never-clones`), and REACHABILITY — the emitted-fn
   set as EDGE-following from main (`Hβ.lower.reach-edge-on-node`), the name scan
   gone (the `reach_has` membership's remaining O(n²) is `Hβ.lower.reach-membership-o1`).
   The str_hash WAYPOINTS largely converged already (trued 2026-07-24): smap
   (lib/imap.mn, the one String-keyed primitive) carries the infer/lower
   indexes; the two hand-rolled survivors are the env index (pipeline.mn
   env_index_new/env_bucket_pos family) and the emit string table (wasm.mn's own
   buckets). `Hβ.runtime.indexed-map-primitive` finishes as: those two re-key by
   handle onto the one primitive once names are handles. Each a Carried-Truth
   deletion.
3. **Per-decl arena** (`Hβ.perf.per-decl-arena`, gated on
   `Hβ.infer.region-on-tee-alloc-absorb`) — each decl's transient scratch is
   `own`ed and `Consume`d at the decl boundary; the region drop IS the arena reset
   (O(1)), `!Alloc` after; the 4GB working set collapses to one decl's live set →
   cache-resident. Activates the dormant emit_memory_arena swap (wasm.mn:139).
4. **Parallel cursors** — the level-set partition at DECL granularity on the
   compile spine, infer/lower/emit fanned across cores with (arena_id, offset)
   deterministic handle partitioning so native_m3==native_m4 holds
   (`Hβ.driver.level-set-par-walk` multi-core half + `Hβ.native.deterministic-handle-partition`).
   The `><` verb over the shared image; the highest ceiling.

**Self-hosting:** layers 1–2 are Law-7 byte-identical where they change only HOW a
fact is found, a TRANSITION where interning shifts emitted handle-order; layer 3
is a TRANSITION too (the fleet's 2026-07-17 refutation of the earlier
"output-invariant" claim here: any real arena changes allocation order and
therefore handle numbering — plan it as a re-pin, never a no-op); layer 4 CHANGES bytes (handle
numbers shift under the partition — a TRANSITION, re-pin from m3, the sharpest
risk, well-precedented). Each layer marched + gated before the next. The whole
becomes O(n) total (n = program size, O(1) per operation) on N cores — the
substrate-honest floor of "unsurpassed speed."

### §5.R · The post-first-light roadmap — the named remainder

> 95 items / 15 bands, gathered 2026-06-28. **Full peer catalog with SOTA refs
> and file:line anchors: `RESIDUE.md`** (the one home; a hidden gap is drift).
>
> **THE SPINE:** `Hβ.effects.sound-neg-under-poly` is the dependency ROOT —
> its soundness GATE LANDED (29df478); the modal world-index and `TCont`
> world-index remain open. **THE DESTINY AUDIT** (2026-07-14) reframes the
> whole band: **machinery real, performance absent** — the gap is WIRING
> (perform the ops already built), not substrate. ~35–40% scored.
>
> **CRITICAL PATH:** R1 `EffName`-is-a-handle (✅ LANDED) → R2 bind
> `self`/args live → R3 decidable fragment → R4 wire the felt loop → R5
> gate narrowing elision → R6 `~> Backend` emit seam.

**The 15 bands** (each named here, detail in `RESIDUE.md`):
**A** Effects & modal crown · **B** Continuations & TIME · **C** Flow rows (IFC)
· **D** Value layer (fold & repr) · **E** Parallelism & accelerators ·
**F** Verification & proof · **G** Graph & e-graph · **H** Ownership ·
**I** Dataflow & DSP · **J** Self-hosting & `!Outside` · **K** AI-proposer /
Synth · **L** Why-engine & `mentl audit` · **M** Felt surface / `mentl space` ·
**N** Backends (full plan: `docs/NATIVE.md`) · **O** Self-hosting infra.

---

## §6 · The bootstrap reality

> **THE SEED IS DELETED (7401c4b "Fly, my pretty <3", 2026-07-10 — Morgan's own
> hands, the day after first light).** The build loop is `boot/mentl.wasm` (the
> pinned fixpoint wheel, boot/PROVENANCE.md); the ladder below is git
> archaeology — the cold-bootstrap recipe lives at tag `first-light` (band J,
> diverse-double-compilation). Everything in this section phrased as present
> tense about the seed is HISTORY of how the wheel was sparked.

Mentl bootstrapped **backward**. The VFINAL codebase in `src/**.mn` (+ `lib/**`)
IS the compiler — the wheel. A disposable hand-WAT **seed** (`bootstrap/`,
assembled to `bootstrap/mentl.wasm`) compiles the wheel **once** → `mentl2`;
then Mentl compiles itself; the seed is deleted. The seed is the largest
non-ultimate thing in the repo *by design* — it dissolves at first-light.

- **Build & the FIXED-POINT oracle:** `bootstrap/build.sh` → `find src -name
  '*.mn' | sort | xargs cat` + `find lib` piped to `wasmtime run
  bootstrap/mentl.wasm > mentl2.wat` → `wat2wasm` → `mentl2.wasm` compiles the
  wheel → `mentl3.wat` → `mentl3.wasm` compiles the wheel → `mentl4.wat`.
  **First-light = `diff m3.wat m4.wat` EMPTY *and* correctness (micros + repro
  green)** — the fixed point `m_n == m_{n+1}`, the medium reproduced by itself.
  **NOT `m2 == m3`.** Why: `m2` is the wheel compiled by the DISPOSABLE seed, so
  `m2`'s bytes are the seed's output, not the wheel's own — for a change to the
  compiler's own inference `m2 ≠ m3` *even when correct*, while `m3 == m4`
  (`W` reproduced by `W`, seed already out of the loop). The seed's ONE job is to
  spark a *correct* `m2` (offsets resolve, no traps); its bytes are thrown away,
  never matched. Pair the diff with correctness — a buggy compiler self-
  reproduces to a *wrong* fixpoint, so micros/repro are the second half. The old
  `m2 == m3` check was a seed-matches-wheel PROXY: it forced mirroring every wheel
  refinement into the hand-WAT seed (the mirror-grind); the fixed point frees the
  seed to be coarse, only correct. Wheel input is `find`, NOT `cat src/*.mn`
  (which omits `backends/wasm.mn`).
- **WASM substrate.** Linear memory, no GC, tail-call via wasmtime. Bump
  allocator, monotonic, never frees (determinism = fixpoint). Strings: flat
  `[len][bytes]` + view `[-1][buf][start][len]` (sign of first word =
  discriminant) — note §4①: this flat form IS a sequence; the type split is the
  artifact to dissolve. Lists: tag 0=flat, 1=snoc, 3=concat, 4=slice.
- **Handler elimination (the three tiers, "the proof becomes the dispatch"):**
  tail-resumptive (~85%) → direct `call`; static singleton → direct call, the
  record from the live world chain (`$world_find`); polymorphic → `call_indirect` via an evidence-field on the
  closure record (Koka evidence-passing, **never** a vtable); MultiShot → heap
  continuation struct + trail rollback.
- **Handler IS state IS closure** — one heap record
  (`[fn_ptr@0][nstate@4][state@8..][arms]`); the EVIDENCE role dissolved
  into the live world chain (the world-as-value arc — dispatch reads the
  install chain, never a frame region).
- **Non-ultimate by design (dissolve at L1):** the seed (hand-WAT); the bash
  scaffolds (state.sh, verify.sh, run-micro.sh, drift-audit.sh — each
  dissolves into the medium's own where/verify/audit verbs); the external
  runtime/assembler (wasmtime, WABT) — the arc to native is `!Outside`
  (§5 stage 3).

**File map (the wheel):** `graph.mn` (graph, flat-array O(1) chase) · `types.mn`
(Ty + Reason + Scheme + typed AST) · `effects.mn` (EffRow Boolean algebra) ·
`infer.mn` (HM, one walk, the write) · `lower.mn` (the projected read) ·
`backends/wasm.mn` (LowIR → WAT) · `parser.mn` · `pipeline.mn` · `mentl.mn`
(oracle/synth) · `cursor*.mn` (the felt read) · `bootstrap/src/` (modular WAT).

---

## §7 · Current state — the honest audit

**THE BOARD'S NUMBERS LIVE IN `state.sh`, NOT HERE.** A gate is green only for the
boot/source pair it actually measured. When `state.sh` reports boot behind
current source, every boot-suite verdict below that line is a verdict on the OLD
wheel, not a blessing of the checkout. Finish the batch, re-pin once, then let
doc-truth bless the narrative; do not launder a mid-landing through prose.
The 2026-08-25 resume measured exactly that mid-landing state: boot at
`06e7fef1...`, current source ahead of it, and the slow board intentionally
stopped after the needed freshness fact. The current cursor is therefore not
"Phase 11 polish"; it is Arc A of THE SPACE SPINE (§11), and the spine's
terminal bar is the WASM Resident Space session.

Ground FIRST: `bash tools/state.sh` (the whole board). State-as-PROJECTION is
§7's own destiny; each line here is a POINTER.

### The honest audit — what the artifact has NOT reached

§4/§5 write the ULTIMATE FORM (present tense = design). This audit is the
arbiter. Where a design section and this audit disagree, §4/§5 is the TARGET
and this is the STATE.

- **Regions** are compile-time root-tagging + return-transfer, NOT a runtime
  arena. The `emit_memory_arena` swap is dormant (§5.O open work).
- **`persist = memcpy` IS BUILT, and this line said it was absent** — the doc
  rot named as violation #1, measured 2026-09-07. `lib/persist.mn`'s
  `image_pack` is literally one `mem_copy(dst, 0, size)` over `[0, heap-line)`
  plus the globals record; `image_resume` gates on the build key and swaps it
  in; `mentl resume <image>` re-enters a persisted image with the source not
  required to exist; and the driver's warm start restores an analyzed image
  rather than re-inferring. The honest remainder is NOT the mechanism: host
  resources (fds, stdin position, sockets) are outside the image and do not
  restore, and persisting mid-spawn is band E's fusion work. Durable
  execution's *substrate* is here; its cross-machine face
  (`Hβ.persist.cross-machine-resume`) is not.
  **The cost of this sentence being wrong was real**: a session reading it
  would have built the memcpy that already existed.
- **`TCont` effect-WORLD** is INERT on OneShot — tag carried, not enforced.
  "Inert" means the stack-only path never becomes a rehydratable continuation
  value, so no changed-world comparison can fire there. The fix is not a special
  OneShot patch; it is the single continuation/image value model: capture the
  world at reify, persist/fork it as an image record, and refuse mismatched
  resume through the same row check every `~>` edge already uses.
- **O(1) complexity** is the DIRECTION, not built. Honest contract: O(1) chase,
  O(changed cone) incremental, O(reachable) image, O(1) reclaim-after-proof.
- **Executable refusal** is PARTIAL — fifteen classes refuse (read `diag_refuses`
  for the live list, never this doc). Remaining census classes are the
  ratcheting work toward universal.
- **Per-module manifest** — CLOSED at entry, OPEN per-module
  (`solo_violations_max: 0`). The overlay is the stamped second half.
- **Thread schedule** is REAL (host threads over shared image). Safety gated on
  band A. SIMD/GPU/persist remain scaffold (bands E/O).
- **Subsystem-as-cursor** (§2) is ~60% earned. Gap ranked: LOWERING (39
  constructors → columns), ENV (dissolves with schemes-are-edges), REVERSE EDGE
  (landed 2026-08-07), verify/tighten BANKS. The move: put the fact in a column,
  dual-write, migrate readers, delete the side-structure — and its full cycle
  ran once at pin 8aeca3c8: the emittable-fn enumeration went from dual-written
  and zero-read to carrying each symbol's signature edges, emit's six
  re-derivations of the emitted ABI became one settled read, and the walker
  that only re-derived it (`find_local_handle_expr`, 30 arms) deleted. Eleven
  walker families remain of the twelve that entry enumerates.
- **Schemes are VALUES, not edges** — the root the judgment tower compensates
  for. Row half LANDED (5.2); forward-HOF under-publish CLOSED (pin c6eb188e1d37).
  Rung 3 whole is the dissolution.
- **Layer sweep SERIALIZED** (judge_window 1) since 2026-08-07. Parallel returns
  at Phase 9.2 with deterministic handle partition.
- **Resident Space** is not yet the shipping medium. `mentl space` serves the
  browser surface, and cursor/query/propose pieces exist, but the browser still
  needs the resident graph session: one WASM instance, a durable image boundary,
  incremental edit actions, per-caret eight-aspect projections, and an IDE gate
  proving the instance stays alive across actions.
- **Demand linking / prelude caching** must be graph reachability, not a token
  allowlist. The demanded set is read from import edges, free-name binding edges,
  desugar-introduced names, and row/handler/type obligations; the prelude should
  become a frozen image slice, not a reparsed text prefix. A bare program's line
  floor is useful only when this reachability law is true.

Everything else requires the board that measured it. A skipped, stale, or
interrupted gate is UNKNOWN, never green.

### The landing record → `LEDGER.md`

Every landing since first light, newest first. Consult for *what happened at pin
X and why*; `tools/doc-truth.sh` asserts its head pin against the boot sha.

### The named peers → `RESIDUE.md`

Every named positive-form gap, one home each. A hidden gap is drift; a gap not
in `RESIDUE.md` does not exist. §11 names the peers each phase touches.

## §8 · Verification surface

```
# ── the BOOT ERA (post-first-light, 2026-07-10): boot/mentl.wasm IS the compiler ──
bash tools/state.sh            # THE BOARD, ground FIRST: git → verify → march → frontier → proof-exactness → crown → effect-identity, one scoreboard; --quick = verify only
bash tools/verify.sh           # the floor: micros + census — STAMPED green (unchanged tree answers in ms; FORCE_VERIFY=1 re-runs)
bash tools/march-gate.sh --micros   # rungs + battery through boot's wheel-emitted m2 (reads the shared .build/m2cache)
bash tools/march.sh            # THE RATCHET: boot→m2→m3, ASSERTS m2 == m3; on m2 ≠ m3 runs m4 ITSELF and rules TRANSITION (re-pin from m3) vs BROKEN
bash tools/frontier-gate.sh    # scheduled matrix + ?? authoring workflows (--compiler fresh for the current wheel)
bash tools/proof-exactness-gate.sh  # hole refuses · debt surfaces · suspension runs
bash tools/doc-truth.sh        # the docs' checkable claims vs the artifact: PROVENANCE sha == boot sha, ledger head pin, named commands exist (runs inside verify — prose gets a mechanical floor)
mentl space                    # mentl edit in the browser (localhost:7378/ide/) — SERVED BY THE WHEEL (src/main.mn space_run; the shim owns the tcplisten seam)
#   (the seed + --from-seed are deleted, 7401c4b; the cold ladder lives at tag first-light)
python3 tools/emit-diff.py m2.wat m3.wat        # the divergence pinner — run FIRST on any m3 trap (CLAUDE.md ⟲)
python3 tools/emit-diff.py m2.wat m3.wat --trap # m3-side unreachable bodies m2 lacks (filter to comment-marked floors — bare else-unreachable is benign, SYNTAX §exhaustiveness)
grep -B3 '(unreachable)' m3.wat | grep ';;' | sort | uniq -c   # the floor CENSUS in one measurement (concat / field-offset markers)
wat2wasm m2.wat -o m2.wasm --debug-names --enable-threads --enable-tail-call
# WABT (per task) — the tools that PARSE need --enable-tail-call --enable-threads or they
# choke on opcode 0x13 (return_call_indirect). NOT objdump: at WABT 1.0.39 it accepts no
# feature flags at all and disassembles tail-call modules fine bare — passing them is an
# immediate "unknown option" error (measured 2026-08-17, the flag sent a trap-pin probe
# into a two-line failure before it read anything). With the flags where they apply:  objdump -d (disasm,
# the trap-pin workhorse) · -h (section sizes — the runaway-emit diagnostic;
# read the live Code-section size, never a hard-coded number) · wasm-stats
# (opcode distribution — fat/runaway-emit diagnosis) · wasm2wat
# --fold-exprs (readable canonical WAT — NEVER the raw 12MB m2.wat) · wasm-validate · wasm-decompile (C-like)
```

**Modern toolkit (measured; profiling CORRECTED 2026-07-13).** `wasmtime
--profile=guest` writes a Firefox-profiler JSON — BUT it writes NOTHING for a
program that exits via `proc_exit` (WASI), which is every real Mentl compile: the
store is torn down before the dump fires (three attempts wrote empty, 2026-07-13).
Profile the self-compile with host **`perf`** instead — it samples the process
regardless of how the guest exits: `perf record -F 199 --call-graph=fp -o
perf.data -- wasmtime run --profile=perfmap <flags> m2.wasm < wheel.mn` (the
`--profile=perfmap` writes /tmp/perf-<pid>.map so `perf report` resolves guest fn
names; `perf_event_paranoid=2` permits user-space samples of your own child; a
`timeout 300` on the first 5 min is representative for the uniform compile). This
is THE profiler for the self-compile — it pinned the resume-cardinality
classifier's O(n^k) at **98% of the entire compile** (§7) after `--profile=guest`
returned nothing, and it is the tool that made the env miss (attacking a
diagnosed-but-non-dominant O(n²)) unrepeatable: measure, do not guess the hot
path. **AOT is MARGINAL: `wasmtime compile` → .cwasm removes the JIT cost, but the
JIT is only ~20ms MEASURED (the 2 MB boot module), so the compile is 100% guest
ALGORITHM — AOT buys ~nothing for the wheel, ~1s across the 66-micro battery.**
`wasm-opt -O2 -all` was MEASURED A 4% REGRESSION on real guest work (82.7s vs
86.0s AOT on a 2k-line slice): the wheel's cost is ALGORITHMIC (bump-image
allocation churn, linear scans), not instruction slop — wasm-opt stays OUT of
the march loop (module-size hygiene only: −41%). `wasm-tools` (1.252+, the
maintained WABT successor) adds `shrink` (predicate-driven module reduction —
the seed-miscompile pinning tool) and `validate --features all`; WABT's
objdump/wasm2wat remain fine with the tail-call/threads flags.

`.build/` (luks-backed) holds intermediates, not the 6 GB tmpfs (the `TMPDIR`
fix stops EDQUOT). Tooling can lie: a diagnostic's NAME can lie (instrument the
actual emit site); diagnostics print to STDERR not the wat; verify before
asserting.

**Pin a wasm trap with the binary toolkit, NEVER grep the minified emit** (the
fragile path that ate this session): the wasmtime backtrace gives `<addr> <fn>`;
`wasm-objdump -d m2.wasm` maps it to the exact instruction with the `name`
section making locals readable (`<__state>`, `<h>`, `<kind>`) — e.g. it proved
the `lookup_ty_graph` arm threads `graph_chase` from `__state` offset 12 with NO
`*_state_g` home-read; `wasm2wat --fold-exprs m2.wasm` renders readable canonical
WAT for archaeology. `wasm-interp` CANNOT run m2 (no WASI — fails on the
`proc_exit` import); use it only on WASI-free micros, else wasmtime + a targeted
`eprint` for runtime values.

---

## §9 · The hard-won laws

1. **THE CARRIED-TRUTH LAW (root, at three scales).** Every Mentl bug is ONE
   bug: the graph proved X; a consumer re-derived / discarded / fabricated /
   cached X instead of reading it live. Carry the handle, read live; the fix is
   always LESS code. *Same law:* humanity needs software that never hallucinates
   intent; the collaboration needs Claude to carry real reasoning, never perform
   confidence. *And at the PERFORMANCE scale (Morgan 2026-07-13): **O(1) is the
   only acceptable complexity for any operation.*** The graph's only native access
   is the O(1) flat-array handle chase, so a super-constant op re-derives what an
   edge already connects — a scan/re-filter/re-clone IS Law 1 violated at runtime.
   The fix is uniform: a name is a HANDLE (interned once), every read an O(1)
   handle chase (§5.O). Every scanner in the compiler is a place we forgot the
   graph already knew.
2. **Don't patch — restructure or stop.** If a fix fits in a patch, the
   architecture is wrong. A silent failure / surrender-fallback (`_ => str_concat`,
   `_ => 0`) is *deleted*, not wrapped.
3. **Dream-code first — and the dream is INVARIANT to the substrate.** Write the
   final form (perfect Mentl source for the perfect substrate); make the
   disposable seed match it; verify by coherence + census, not by checking a
   mutation. A substrate that can't express the form means the SEED is
   incomplete — complete the seed; NEVER lower the target to fit it. "Ultimate
   form reachable now" / "realistic ultimate" / "the deeper ideal is a follow-up"
   is the target equivocated downward — the underhanded drift wearing the
   discipline's costume. Sequence the WORK (§5); never sequence the TARGET. And
   the dream GROWS: run the generative audit (§2 — multi-shot/threading/memory +
   frontier) so each touch reaches toward a newer ultimate, not only less code.
4. **Mentl solves Mentl.** Reaching for a framework = a missing primitive. Every
   subsystem is the cursor in a different mode.
5. **Build the wheel; never wrap the axle.** No V1 to wrap — only the final form.
6. **Audit before the symptom; probe before hypothesis** (the lesson of
   2026-06-18, paid for in a full session of drift). Your FIRST move on any work —
   above all a bug — is the Universal Audit of the structures you'll touch (*does
   the graph already know this? is this copied / cached / re-derived?*) BEFORE
   tracing any trap; debugging a symptom's mechanism before auditing whether the
   structure should EXIST is the drift itself. Then probe the artifact, never a
   hypothesis; the trap marches deeper per fix (progress). A probe that disproves
   you does NOT crown the next symptom as the root — keep digging until it cannot
   reduce; verify every claim with a tool (memory and prose drift; the artifact is
   truth). And a "choice" between the ultimate form and a safer/lower-risk hedge
   is itself the drift — the ultimate form wins; never hedge the wheel against the
   seed.
7. **Verify the dispatch floor with a GATE; never DEFER the ultimate form for
   it.** A wrong dispatch / evidence / wire-format resolution is a real trap, so
   PROVE each new path: keep the cheap no-regression signal (the existing micros
   stay byte-identical, which catches a broken *working* path early) AND write the
   gate that exercises the NEW path (a round-trip equality, a fresh micro) where
   the seed can run it, structural otherwise. FORBIDDEN is the *other* response to
   risk — SEQUENCING or hedging an ultimate-form feature because the seed might
   miscompile it: the seed-compiled micros are a SHADOW (they prove the seed's
   behaviour, not the wheel's self-hosted correctness); the real oracle is
   first-light (§6); deferring the wheel to protect the shadow is the §3 / §10
   hedge inverted. Risky path → add the gate, write the FULL form (Anchor 0), move
   on. Caution that VERIFIES, yes; caution that DEFERS the ultimate form, no.
   (Corrected 2026-06-23 — Tier-1 sequenced two *verifiable* completions, W03 the
   fold family and W10 tuple-index, under the old wording; Morgan caught it.)
8. **No bolts onto non-ultimate forms.** When the audit finds you working around
   a gap, the move is the ultimate restructure, not another per-layer patch.
9. **Interrogate, don't absorb** (the law that prevents the next re-grounding —
   see CLAUDE.md). These docs are the current best answer, not authority; at
   every claim ask "is this the ultimate form?" The decisions in §4 are resolved,
   but the burden is on the challenger, not assumed away.
10. **Power × anti-drift is the dispatch criterion (not token-frugality);
    report, don't perform.** Token cost is NOT a constraint (Morgan upgraded
    2026-06-21). Choose the most powerful structure: DEEP kernel/novel-concept
    reasoning stays INLINE (the single accumulated context is the handler; a
    cold-brief dispatch loses the altitude = the proven, token-independent
    drift); VERIFY my own conclusions via ADVERSARIAL/independent agents told to
    refute (the anti-fluency-trap tool, a systematic proxy for the
    human-catches-the-drift loop); BREADTH via Workflow fan-out; synthesis
    inline. EVERY dispatched agent runs Opus 5 or Fable 5 — whichever is most
    effective for that job — passed explicitly (Morgan 2026-08-05, superseding
    the 2026-07-24 Fable-only rule; both are unlimited, so the pick is FIT,
    never scarcity, and an omitted model param falls back to an agent
    definition's default and silently downgrades the run); the discipline
    governs each agent. A turn ends with what CHANGED and the MEASURED result;
    work not done → "not done" first sentence; shortest response carrying result
    + next move.

11. **A gate is not trusted until it has been seen RED; a Carried-Truth fix
    DELETES.** Run every new gate against the unfixed tree and watch it fail
    before the fix (march.sh models this — it arbitrates by running the m4 leg
    itself; thirty of the 2026-07-17 fleet's gates could not fail and died to
    one command). And ask of every fix's diff: does it delete? Elegance is the
    axis fluency fakes best; a line count is not — a net-positive "less code"
    fix must say why in its commit (the `++` row fix claimed a deletion while
    adding 43 lines; the flurry plan caught it). The gate's OTHER face: a
    banked expectation is a HYPOTHESIS about the era that banked it — when a
    correct fix flips old gates RED, re-derive each truth by hand before
    re-banking, because the old value may be the bug canonized (2026-07-25:
    nine payload-ladder micros banked the wrong-slot alpha read as their
    expected values; one of them had carried "Expected value when fixed: 2"
    in its own comment since birth).

**Bug classes that cost hours:** `match … with _` masking type errors · dup
top-level fn names (emitter picks one silently) · flat-array ops in Snoc paths
(O(N²)) · `println`/`report` in `report(...)` arms corrupting WAT stdout ·
`acc ++ [X]` in a loop (O(N²); use buffer-counter) · flag-as-int (→ ADT) · a
diagnostic's NAME can lie · **wrong-end stack ops** (push at one end, pop/read
the other — six sites in one commit, b93978f; every Mentl stack pushes at the
END) · **phantom captures** (handler-decl names are top-level globals; a
collector that counts them as captures inflates the ev-region base, e791bf3) ·
**pointer-eq on names** (`==` with no String proof emits i32.eq; byte-equal
strings interned by different passes never match — annotate the name param
`: String`, the Intent Boundary carrying the proof) · **one-operand dispatch**
(a binop's emit reading only ONE operand's type proof; read EITHER, 4fb8e68) ·
**the seed's name-keyed intrinsic table** (bootstrap/src/infer/walk_expr.wat — deleted with the seed, 7401c4b; the lesson outlives the file
types prelude stages BY NAME with byte-pinned offsets — ANY prelude rename or
re-signature is a same-cut three-layer edit: wheel decl, wheel callers, seed
table; miss it and the seed silently mistypes every call) · **blind token-walk
absorbers** (a parser "skip-to-terminator" that walks tokens instead of parsing
structure eats every comma-less sibling — the mint_row arm-drop, 837948c; the
symptom surfaces LAYERS away as a dispatch misroute. Parse structurally or
delete the walk; and a dropped ARM means the record's next slot reads 0 =
table idx 0, so "prints WAT mid-inference" can mean "the parser ate my arm").

---

## §10 · How to resume — the three-document loop

1. **Read `CLAUDE.md`, `PLAN.md`, `SYNTAX.md`.** That is the entire required
   context. `LEDGER.md` (what happened at a pin) and `RESIDUE.md` (the full peer
   catalog) are REFERENCE — consult on demand, never read whole; they left this
   file on 2026-08-05 because 78% of the substance document was a prose copy of
   git. Reference nothing else unless debugging a specific artifact.
2. **Run `bash tools/state.sh`.** The whole board, not a slice: verify (micros +
   census + doc-truth), the march's fixed point, frontier, proof-exactness,
   crown, effect identity. The census is a ZERO-TOLERANCE RATCHET, not a shadow —
   a rising count is a refusal to merge (it has been since 2026-07-22, and the
   older "census is a shadow, expected progress" reading was a seed-era alibi
   that outlived the seed by weeks). Trust the artifact over any prose here; if
   prose disagrees, fix the prose. **A gate you did not run is not green** — the
   crown proved that over eleven landings.
3. **The cursor is the ULTIMATE-FORM arc — write the `.mn` in full.** NOT a
   first-light blocker to chase. Recent leaps that ARE the cursor: the whole AST
   in the one graph (the fabric — every node a resolvable handle); the e-graph
   engine (effect-aware equality saturation) live in lower. The seed's weaker
   inference lags this and catches up ("then we make it work"); NEVER hedge the
   wheel against the seed — that fork (ultimate form vs safer-for-the-seed) IS
   the drift, paid for in a wrongful revert (2026-06-22). All three §5 aspects in
   full — real, felt, unsurpassable — never one phase chased before the others.
4. **Open with the Universal Audit, not the trap (§9.6).** Then every edit:
   project the eight arms (§2); obey Carried-Truth (§9.1); dream-code first
   (§9.3); never bolt (§9.8); interrogate, don't absorb (§9.9). Ask: *what does
   the ultimate medium do here?* Implement that.
5. **Keep the three docs in ultimate form.** Each touch consolidates toward the
   tightest *complete* prefix, one home per truth. They are the only durable
   memory — the investment that means this session never recurs.

---

## §11 · THE PHASES — the ordered program

**Rewritten 2026-08-05**, replacing the five-column production bar;
**extended to the FULL ARC 2026-08-06** — every phase from the current pin to
the seven DONE statements and the terminus, one ordered program. The
extension's own law (the no-completeness-claims rule, twice-corrected): this
is the TRACED set — every peer `RESIDUE.md` names, every §5.R band, every
§5.O layer, every §7 seam and SYNTAX defect, placed in dependency order with
its design banked — and completeness's one proof is the build marching
green, phase by phase, never this document asserting itself exhaustive. The
columns had become a checklist of symptoms; these phases are ordered by
*foundational depth*, because the governing correction is Morgan's:
**performance — and every other superiority — falls out for free when the
design is right.** §5.O
already said it (performance IS the Carried-Truth Law; a scan is a
re-derivation wearing a stopwatch), but the old §11 kept a "performance floor"
column as though speed were a work item. It is not. The test:

> **If a change's justification is a number and not a law, it is the wrong
> change.** `wasm-opt -O2` measured a 4% regression and was correctly refused;
> the 140× came from deleting re-derivations. Every time.

So total monomorphization is not perf work — it is the erasure boundary lying.
The arena is not perf work — it is ownership having a real reclaim.
Name-is-handle is not perf work — it is a name being an edge. Speed is the
side effect in all three, and treating it as the goal is how a wrong change
gets justified.

**THE DEFINITION OF DONE — one statement per §0 property, each a phase's
terminal gate:** (1) *proof beats review* — the crown sound under polymorphism,
Verify on a decidable fragment with honest V_Pending, SMT a certificate-checked
handler swap, every armed class refusing. (2) *the negative is provable* —
`!Flow` on the integrity dual-lattice, PC-labels, robust declassification.
(3) *intent is lossless* — the Why engine total, provenance projected at every
surface, the fmt summit canonical. (4) *computation is durable* —
persist-as-memcpy generalized to cross-machine cursor migration, the session a
value. (5) *systems explain themselves* — `mentl audit` live, docs-as-projection,
the ??-fan with the teaching tie-break as the daily loop. (6) *the oracle at its
limits* — the multithreaded multi-cursor multi-shot fused oracle as the default
judge. (7) *`!Outside` closed* — the native backend, diverse double compilation,
and the correctness oracle absorbed into the wheel's own Verify.

**THE RISK TRIPWIRES, each with its fallback:** (1) the frozen-read instantiate
holds without judgment regressions — tripwire: census classes shifting instead
of falling. (2) the lattice join's confluence survives every future workload —
tripwire: any six-battery split; FRAGX stays armed as the standing collision
census. (3) **THE BOARD'S ORACLES ARE BLIND TO WHAT THE WHEEL NEVER DOES** —
confirmed hard on 2026-08-05: a 27-fixture SYNTAX battery found eight surface
drifts, every one invisible to census, fixpoint, and micros, because the wheel
never writes a lambda list-pattern, never declares a named effect row, never
pipes bare into `len`. The board was green in the same minute the crown was
admitting a higher-order `!E` leak. Fallback and standing counter-measure:
gates that exercise what the wheel does not (Phase 0.4), and every measured
silent-wrong banked as a RED refuse-contract the day it is found. (4) **A GATE
THAT STOPS BEING REPORTED STOPS BEING RUN** — the crown went unmentioned for
eleven consecutive ledger entries while the leak rode the whole arc; nothing
written was false, the gate had merely gone quiet. Closed mechanically by Phase
0.1: a gate not run is a visible blank, and a red one refuses the pin.

**ONE LAW, FOUR FACES — AND THE ORACLE IS THEIR SUM (2026-09-06).** The
board's four largest open items are not four projects. Each is the same
violation — *a materialized view stored where an edge belonged* — and the
oracle is what they add up to:
- **SCHEMES** (`Frozen`, rung 3): a decl's type frozen at its own exit, the
  moment the cell is least finished. The two-pass tower re-judges the gap;
  the movers line counts it.
- **PROVENANCE** (`Reason`): a RECURSIVE VALUE TREE stored inline on every
  node (`GNode(NodeKind, Reason)`), 24 constructors of which nearly all
  carry a copied handle (`Declared(String)` names a node that exists),
  copied structure (`Unified(R, R)` duplicates both subtrees into every
  node that unified — the render's own comment admits "the DAG rendered as
  the tree it is"), copied values (`UnifyFailed(Ty, Ty)` snapshots types
  that may later resolve differently, so a Why chain can render what is no
  longer true), or copied POSITIONS.
- **POSITIONS** (`Span` in a Reason): a coordinate copied beside the very
  handle it describes — the dominant call is literally
  `graph_bind(handle, ty, Located(span, …))`. Copied coordinates also ROT
  UNDER EDITING, which the resident session depends on them not doing.
- **THE FAN** (11.1): the context re-judged per candidate instead of judged
  once and read live.
**THE SUM:** the oracle's central waste — every branch re-judging the whole
context — IS rung 3, not a consequence of it; the teaching tie-break needs
"what distinguishes these survivors", which is a provenance DIFF, cheap over
edges and absurd over duplicated trees; the shared context needs live cells
to be shareable at all; and the runner's shared image plus its own spawn
count is what makes N real cursors observable. Fix them separately and each
is a chore; fix them as one law and the oracle falls out. **Hardest first,
and it is not the tractable-looking piece: judge the context ONCE and let
branches read it live — which is rung 3's live cells, the same problem
wearing the search layer's clothes.**

**THE STANDING CURSOR (Morgan 2026-08-26 — the Space spine; supersedes the
2026-08-11/12 selectors, whose corrected DEP chain it absorbs).** The
production target until Morgan stands it down: the medium complete and
all-powerful in WASM form, used in full through `mentl space` — live caret
authoring AND proof faces (`!Flow` refusals, Why chains) on ONE page, for a
client audience. Native (Phase 10) waits behind that bar, named in positive
form the whole time. The arcs, in order:

- **Arc A · Artifact integrity — LANDED 2026-08-26** (commits a9309bc8,
  63fad408, d59dbfca; the relocation arc, the space-spine selector, the
  gate's deduped sweep and pooled flights; boot re-pinned a7a05294, then
  8cb23d6e). The cadence law held: whole arc, verify once, board once,
  repin once, then the commit series.
- **Arc B′ · Columns, the artifact's own corrected chain** (naive
  columns-first died 2026-08-12 — pointer columns relocate WHERE A POINTER
  IS STORED, never where the POINTEE is allocated, so a per-decl reset would
  dangle cells into virgin zeros; `Hβ.graph.column-pointees-are-words`
  carries the record): (i) the image_bytes census print + flat-buffer-family
  brackets + the per-fn emission region — **LANDED 2026-08-26, pin 8cb23d6e
  (TRANSITION m3 == m4)**, and the print's first reading caught the arena's
  silent zero: the image arms read $heap_ptr, a global the threaded wheel
  never moves, so every extent delta was heap_ptr − heap_ptr from the day
  family 1 landed; the arms read $heap_mark_impl now, and the frontier's
  arena census leg was born RED against the prior boot and went green here;
  (ii) rung 3 WHOLE (`Hβ.infer.schemes-are-edges`, movers → 0) — **the next
  landing, executed from the stage contract RESIDUE banks**: the first
  attempt (a Live variant in Scheme, a projection boundary, a wrapper ADT)
  was refuted by the medium three ways and reverted whole; the terminal
  form is the env carrying cells (Binding = BStatic | BCell), the quantifier
  a projection the caller runs, instantiation the correspondence-edge mint,
  the trial/final collapse following; (iii) the enumeration-reader
  relocation with cons-state re-homed; (iv) `Hβ.lower.lowering-is-a-column`,
  whose STEP (ii) OPENED 2026-09-07 — the emittable-fn enumeration got its
  first reader (each symbol's param and result types, read through the
  settled `sigs_col` ABI column) and `find_local_handle_expr` deleted whole,
  taking the walker census from twelve to eleven — and which ABSORBS
  `Hβ.lower.open-row-field-offset-from-known-set` as its keystone consumer.
  ONE CORRECTION, MEASURED at that landing: the surviving open-row case is
  not a silent wrong. The DIRECT call's neighbour-read was fixed 2026-09-01;
  what remains is the INTERIOR one, and it emits `(unreachable) ;; field
  offset unprovable` — a refusal the executable trips, with no twin demanded
  at the site at all. The wheel ships four such floors today (`op_name`,
  `name`, `init`, `body`), so it is live, and `mentl check` still passes,
  so it is invisible where the sentence said. No client-facing page ships
  either shape; (v) env re-key onto the smap primitive — folds into (ii)'s
  env rework, one landing; (vi) pointees-are-words.
- **Arc C · Image lifetime v1.** With pointees-as-words, 4.3's fork/reset
  resumes soundly; persist = memcpy v0 under its black-box contract
  (requested path honored, versioned image, resume restores, incompatible
  images refuse diagnostically); TCont: capture-at-reify is LANDED — this
  arc graduates rehydrate's Fail refusal into the typed located diagnostic
  AT the v0 persist surface (`world-widening-resume`, `.branch-world-tag`
  stay band-B residue). Lifetime vocabulary everywhere: extents owned by a
  judgment die at scope exit; compaction is a `~>` handler over the
  image-map fold; there is no runtime allocation/reclamation subsystem —
  monotone image pages ARE the graph ARE the heap ARE the continuation store.
- **Arc D · Reachability link** (parallel-capable; roots on the IMAGE
  family, not columns): `Hβ.driver.link-is-reachability` — the demanded set
  read from import edges, free-name binding edges, desugar-introduced names,
  and row/handler/type obligations; the frozen prelude slice via
  `Hβ.persist.module-image-cache`. A token allowlist is the Drift-8 disease
  wearing a linking costume and is refused wherever offered.
- **Arc E · Space session end-to-end.** ITS DESIGN DOCS ARE
  `docs/DESIGN_SYSTEM.md` (brand, tokens, visual language — read first) and
  `docs/MENTL_EDIT.md` (the interaction architecture, which assumes it).
  They are LIVE, not archaeology, and were reachable from nothing until
  2026-09-05 — a session working this arc would not have found them.
  The substrate largely exists
  (`cursor_session`, ide/wheel-worker.js session roles, tools/ide-gate.sh):
  finish residency across actions, verb merge (`edit`/`session`/`serve`
  absorbed BY `space`; doc-truth retires the old names in the same landing),
  and the DEMO GUARD, RETIRED BY MEASUREMENT 2026-09-02. It read: an
  unannotated generic fn reached at a wide type floors at RI32 and sums to
  ~0 with ZERO diagnostics, citing tests/repro/mn-unannotated-float-
  accumulator.mn. Two things were wrong with that clause. There is no
  tests/repro/ directory and no such file anywhere in the tree, so the guard
  named a witness it did not have; and the defect measures FIXED — `fn
  total(xs) = fold(0.0, (a, x) => a + x, xs)` over [1.5, 2.5] compares
  correctly against 3.0 with zero diagnostics, which is 5.1a's total
  monomorphization doing exactly what it landed to do. The guard the page
  still needs is the OPEN-ROW one:
  `Hβ.infer.record-row-vars-are-not-unioned` is live, silent, and reads a
  neighbouring field (tests/repro-wf/open-row-interior-site.mn). Terminal:
  ide-gate green Node + headless Chrome, session alive across actions,
  eight-aspect projections at the caret.
- **Arc F · Proof faces on the page, repriced.** `!Flow` sink-sensitivity
  (`.flowlabel-inference-in-hm` — labels as ROW facts at observation edges,
  the predicate-name heuristic dies) + Why-chain/refusal badges riding the
  transport. Struck as ALREADY LANDED: stride carrier (pin 7db29195),
  monomorphization face, uniform twinning with the f64-state guard,
  annotated-[Float] breadth end to end.

**CADENCE LAW (paid for twice):** one landing = build the WHOLE arc → verify
once → board once → repin once. A march sweep per micro-edit spends the
session on ceremony; a gate that was skipped is UNKNOWN, never green.

**Preemption exception:** `Hβ.infer.declared-row-vacuous-against-a-free-body-row`
stands ABOVE the spine — §0's negative-is-provable failing at the shape most
likely to carry a real negation; between arcs the loop may take it or the
6.3 modal sweep rule-by-rule as loop-sized residue, their verdicts reported
by state.sh, never this block. Nothing else jumps the queue without a
MEASURED demo-blocking fault. "It will surely land" is never a selection
reason — the completion-gradient is a named drift; the iteration's report
opens by naming the priority served.

---

### Phase 0 · The medium can see itself and its board — ✅ COMPLETE 2026-08-06

All four oracles landed: **0.1** board_verdicts() at pin time (`NOT RUN` visible,
red refuses). **0.2** doc-truth checks verb namespace against `mentl help`.
**0.3** structural census (`mentl query <file> "census <shape>"` — anonymous +
verb glyphs + declared-surface shapes; roster at seventeen shapes). **0.4** the
SYNTAX conformance battery (`tests/syntax/`, run by the medium's `test` verb
through verify). Full mechanics: `LEDGER.md`.

### Phase 1 · The row crosses the function boundary — ✅ WHOLE 2026-08-06

Three landings, one day (pins 806c7df4 → e606a650 → 04e20d2482fc): completion
prune's signature keep-set, instance-erasure at effect registration, handler-
residual at install read. Terminal: crown 8/8, frontier 332/0, census 0. Records:
`Hβ.infer.hof-param-row-never-reaches-enclosing` + peers in `RESIDUE.md`.

### Phase 2 · Every judgment reads the graph, never a proxy — ✅ WHOLE 2026-08-07

All items landed: **2.0** `==` coherent with match (span_of_node_raw — no chase).
**2.1** extraction-is-the-emit-cursor (e-graph born in prescribed form; synth's
stored rank deleted into rank_of). **2.2** shape-keyed judgment tier (334 lines
lighter; `check_branch_is_stage` deleted). **2.3** anonymity tier (eta-wrapper,
effectful-lambda convictions ratcheted). **2.4** diverge-shared-memory-row
recovered into RESIDUE. **2.5** census shapes + ratchet (`eta_max: 29`,
`effectful_lambda_max: 394`). Full mechanics: `LEDGER.md`.

### Phase 3 · The surface IS SYNTAX — ✅ WHOLE 2026-08-07

All items landed: **3.1** N-ary law (FanoutExpr carrier; `><` parses N-ary).
**3.2** `mentl where` (derived-badge projection live). **3.3** remaining drifts
(lambda parameter path, named effect rows, `xs |> len` false diagnostic — all
fixed). **3.4** SYNTAX's own defects trued. **3.5** per-module manifest (sweep
reached zero, `solo_violations_max: 0`; overlay proper stamped in RESIDUE).
**3.6** `<~` becomes whole (causality face closed — `E_ZeroDelayFeedback` +
`E_ComputedDelayDepth` armed; context face redirected to Phase 8's clock
calculus). Full mechanics: `LEDGER.md`.

### Phase 4 · Ownership has a real lifetime

**The order here is mandatory, not preference.**

- **4.1 · `Hβ.own.use-after-move`** — ✅ LANDED 2026-08-07 (pin 8ba768c810c4,
  before the arena exactly as ordered). The gap was one leg's ORDER: the
  affine ledger's consume arm checked `borrow_depth` before the used-set, so
  every borrow surface read moved owns silently. `set_contains(used, name)`
  now reads first — consuming second use stays armed `E_OwnershipViolation`;
  borrow-read of a moved name is `T_UseAfterMove`, born at wheel-ZERO and
  ratcheted there (`use_after_move_max: 0`). Gate seen RED:
  `tests/frontier/mn-use-after-move.mn` via `run_narration`. The ARMING
  (diag_refuses at held zero, post-falsification) is the banked residual in
  `RESIDUE.md`.
- **4.2 · `Hβ.infer.grade-is-join-and-mode`** — ✅ LANDED 2026-08-07 (pin
  6cd6281a971f, built against the stamp). count_uses' additive sum deleted
  whole into `usage_of` — the mode-paired `(consume, read)` Usage walk (⊔
  across alternatives; mode from the callee product via `param_borrows`,
  the classification's one home in types.mn that the arg bracket's inline
  test also deleted into; lattice ops home with their ADT). The refused
  first march was the instrument: the consume default on a not-yet-graded
  forward callee made decl order load-bearing (set_contains graded Own,
  every caller moved its set); the read-safe default closed it. BOTH
  ownership narration classes now at wheel-ZERO; the walk's trial/final
  order-dependence measured at +188 moved schemes (movers 474 → 662,
  in-baseline justification; rung 3 dissolves the class and the
  order-dependence with it). Gate: tests/frontier/mn-usage-grade.mn, three
  asserts seen RED.
- **4.3 · The per-decl arena** (`Hβ.perf.per-decl-arena`, gated on
  `Hβ.infer.region-on-tee-alloc-absorb`). It is a hub, and more rides on it than
  was ever written down: the String=`[Byte]` value-ontology dissolution names it
  THE keystone dep; `persist = memcpy`'s image/scratch split; the 4GB ceiling
  that killed a frontier leg and has shadowed the whole constructors arc; the
  allocation payoff of `instantiate-shares-never-clones`; and total
  monomorphization, which needs the headroom its duplication costs. STAMPED
  2026-08-07 and then CORRECTED BY ITS OWN BUILD (`RESIDUE.md` carries the
  full record): steps 0 (cost instrumentation), 1 (the ImageAlloc
  vocabulary), and 2a (the extent-delta census + family 1, the spine's
  band-open bracket) are LANDED — and before family 2, the build refuted the
  design's core: site-classification is UNSOUND for the value graph, because
  published values (Ty/GNode/schemes) are allocated during inference and
  published by pointer-write, so no bracket at the publish site classifies
  them and a per-decl reset would zero live column pointees. The sound form
  is COLUMNS FIRST — the 5.2/5.5 column arc makes the image set = pages +
  flat buffers by construction — so 4.3 PAUSES at 2a and 2b's fork/reset
  DEP-GATES on that arc (the DEP-gate is the next thing to build, not a
  stop: the arc is §11's own next phase). 4.3 and 9.1 still converge on one
   boundary; the fleet's 2026-07-17 "output-invariant" refutation stands.
   LIFETIME VOCABULARY (2026-08-26): the target has no runtime
   allocation/reclamation subsystem — monotone image pages ARE the graph ARE
   the heap ARE the continuation store; lifetime is ownership proving extents
   droppable, compaction a `~>` handler over the image-map fold. The arena,
   GC, and snapshot questions are that ONE question, resumed at Arc C of §11's
   Space spine.
- **4.4 · Ownership's frontier faces.** The quiet gate ✅ LANDED 2026-08-07
  (verify's quiet-gate ratchet: 83 authored own / 817 authored ref in src/,
  param-position text count seen RED at ceiling 1, monotone DOWN — each
  marker the honest grade retires lowers it; the census-shape count is the
  named refinement). `Hβ.ownership.fractional-uniqueness-ref-borrow`
  (Granule OOPSLA 2024 — fractional grades where the inference needs them)
  stays BANKED until a real consumer needs a fraction: the original text of
  the Hylo bar as a BANKED
  CEILING: the corpus count of authored own/ref markers enters
  verify-baseline and only falls; a rising count IS §4⑤'s inference
  failing, measured instead of felt.

### Phase 5 · The deep forms the arena un-gates

- **5.1 · TOTAL monomorphization.** The current form is flow-directed in exactly
  the right way — the demand analysis reads instantiations off the live
  union-find rather than solving a second constraint system, which is
  Carried-Truth applied to [Lutze–Schuster–Brachthäuser, OOPSLA 2025] and an
  improvement on it. But it is SELECTIVE: the worthiness gate specializes only
  where the i32 floor is *wrong*, leaving plumbing uniform. That is a
  perf-motivated hybrid, and perf is not the axis. A uniform representation is
  the one place where the proof deliberately does NOT become the dispatch, and
  every measured silent-wrong lives at that seam — `sort` returning input order
  because `<=` compared addresses, the unannotated float accumulator summing to
  ~0, `describe(2.5)` printing a pointer. STAMPED whole 2026-08-07
  (`Hβ.emit.total-monomorphization`, RESIDUE): the artifact read reframes the
  target — the machinery is already total-by-REPR (the all-word vector IS the
  floor class, correct at the wasm altitude), so the hybrid is exactly ONE
  filter, and the plan was three legs — and the
  same day MEASURED them: 5.1c is KILLED TWICE (the mangle space is finite by
  construction — a wide component is a scalar repr, containers are words —
  and polymorphic recursion cannot reach the emit at all: the signature'd
  probe refuses E_OccursCheck, a measured 5.3 baseline); 5.1a was BUILT AND
  REFUTED BY THE MARCH — the worthiness web deleted whole, m2 compiled, and
  m3 trapped with call stack exhausted in zip_with. THE GATE IS LOAD-BEARING
  CORRECTNESS, not a perf hybrid: the worthy set was leaf-compute by
  construction, so the twin emission for self-recursive closure-carrying
  HOFs was never exercised and miscompiles. Reverted whole. The real blocker
  was the new peer `Hβ.emit.plumbing-twin-selfcall` (CLOSED — no twin ever
  miscompiled; the trap was the ambient stack cliff, fixed at zip_with's
  tail form) and then `Hβ.emit.twin-state-width` (CLOSED — the twin-edge
  conversions: args word-faced, results deref'd, inits boxed; the hstate
  slot ABI is floor-owned words because the shared arm fns read it).
  **5.1a LANDED 2026-08-07** (pin 6fb09a99fb1e — TRANSITION, census 0,
  emit +17% as banked, RSS inside the raised ceiling, the f64-state
  guard green through the total twin set): the worthiness gate is
  DELETED, every candidate twins, and the uniform seam where every
  measured silent-wrong lived is gone. The dead worthiness family
  prunes as its own sweep; type-total still arrives as the Repr ADT
  grows (5.1b — no separate landing).
- **5.2 · `Hβ.infer.schemes-are-edges` rung 3**, the row half, per the settled
  laws in `RESIDUE.md`. THE ROW HALF LANDED 2026-08-07 (pin a13918ee5784 —
  the prereg publish is generalize's own floor, the group drain re-parks
  cross-group gates, two honest +WASI widenings; movers 678 → 453 and
  false T_OverDeclared teachings dead; the parallel final SERIALIZED as
  its precondition — judge_window 1, the K=8 fan's value-boundary law
  dissolved by live cells, the parallel form returning at 9.2 with atomic
  join writes). The movers arc then CLOSED its classes by measurement:
  the grade class (250) is the condemned cadence's own artifact (two
  builds refuted one-sided patching — the divergence relocates; it dies
  with the pass), the type-sort class is benign-by-checking (the pair
  accidentally implements propose-and-check polymorphic recursion; the
  final's clean total re-judgment is the decidable check), and the 26 row
  residuals exposed a REAL under-publish in the shipping pass — the named
  peer `Hβ.infer.forward-hof-row-underpublish` (crown-adjacent: a
  pure-published allocator under a declared `!Alloc` is a false absence
  proof; the ten-iteration dossier and the root-trace instrument live in
  RESIDUE). D8's gate re-derived: every mover class driven to zero or
  proven benign; the peer owns the remainder. With 5.5's column arc this
  also UN-GATES the arena's 2b (4.3's correction): published facts in
  columns make the image set = pages + flat buffers by construction,
  which is what a per-decl reset needs to be sound.
- **5.3 · The decidable fragment plus the proposed-signature teach.** Type
  inference for polymorphic recursion is undecidable (Henglein 1993,
  semi-unification) and that is a theorem, not a design choice — **but Mentl
  currently conflates it with the ROW side, where arXiv 2510.20532 reports
  inference decidable, sound and complete. The row half of the signature price
  may be unnecessary.** Henglein also gave a decidable *fragment* (single
  recursive call, non-nested); bimorphic recursion is decidable too. Haskell and
  OCaml take the crude route — annotate or refuse, no fragment. Infer the
  fragment and beat both. And the framing is the actually-anti-Mentl part: a
  "price" is a tax, where §1's own law says the question beats the guess. The
  medium already knows enough to *propose* the signature from the call sites it
  judged. Deepest of all, iteration-is-topology shrinks the region to near-zero,
  because derived folds are generated and their signatures are known by
  construction. Do not fight the theorem; make it apply to almost nothing.
  THE ARC LANDED 2026-08-07, three steps in one day
  (Hβ.infer.sigd-polymorphic-recursion carries all three): (1) pin
  d8142b3b — the signature'd form ACCEPTS (Haskell/OCaml parity; the
  emit divergence the gate opened closed with the per-base demand cap +
  the spec self-reference floor). (2) pin 7f4bf082 — the TEACH: the
  refusal carries T_PolyRecursionSignature naming the fn from the
  refused cell's own mint reason. (3) pin 94fd07add038 — THE FRAGMENT
  INFERS: unsig'd poly recursion judged by three-round Mycroft
  iteration on the checkpoint substrate (plain-under-capture → general
  assumption → recheck under the result scheme;
  graph_commit_checkpoint born as speculation's accept half) — depth
  unannotated runs 3, BEYOND Haskell/OCaml's annotate-or-refuse; the
  K-exhausted floor refuses honestly with the narration. Remaining
  here: the row side (arXiv 2510.20532), the alpha-stability detection
  + the multi-call fragment boundary, the concrete-signature
  derivation in the teach, iteration-is-topology's shrink.
- **5.4 · The value ontology dissolves, in its PROVEN sequence** (band D —
  the 13-agent-refuted design, arena-gated, order inverted from every naive
  form: representation FIRST, type-merge LAST). (0) `fold_sig`
  distinguishability SETTLED first (the byte leaf's nominal identity vs
  repr-reading fold_sig — the recorded structural decision); RI8 as
  zero-reader vocabulary; the repr-width-polymorphic flat leaf PROVEN on
  WIDE elements ([Float]/[i64]) where no header collision exists. (1) The
  emit consolidation DEFENSIVELY — the ~10 TString-vs-TList outer forks
  collapse into one `match repr_of(elem)` dispatch KEEPING the nominal arm
  H6 names. (2) The runtime reconciliation as its own perf-measured
  TRANSITION — `Hβ.value.seq-element-stride-carrier` (the true keystone: a
  generic body compiles once with a TVar element, so packed traversal
  requires a runtime stride carrier read at access — a fat sequence header
  — or whole-program monomorphization, which 5.1 supplies); the view/slice
  unification; the `[len][bytes]` literal; the concat-persistence decision.
  (3) ONLY THEN the type merge, when the runtime agrees — the self-hosting
  oracle is BLIND to this class (m3==m4 stays byte-identical while user
  code corrupts), so the WIDE-element gates and the stride crucibles are
  the oracle, banked RED-first. With it: `Hβ.infer.seq-addr-downcast` (the
  capability-gated down-cast), `Hβ.infer.seq-op-signature-driven` retiring
  is_seq_op, and the show/compare/hash leaves generalize into the ONE
  `fold(ty, leaf)` — the four generators become four leaves of one walk
  (`Hβ.fold.show-leaf` / `.compare-hash-leaf`), ~1,200 lines gone.
- **5.5 · The subsystem table's remaining 40% — one repeated move, run to
  its end.** The mechanical test (does the per-handle fact live in a spine
  COLUMN?) applied four more times: LOWERING (`Hβ.lower.lowering-is-a-column`
  — LowExpr's 39 handle-first constructors and their walkers become columns
  + one emit walk, killing the lower-time-bake class the ledger declared
  dead three times, and making per-decl incremental EMISSION the same cone
  machinery that re-judges; sequenced after 5.2 exactly as its entry
  prescribes — swap the representation behind the projections); the ENV
  (dissolves with 5.2's schemes-are-edges; the two hand-rolled indexes
  re-key by handle onto the one smap primitive —
  `Hβ.runtime.indexed-map-primitive`); the REVERSE EDGE (a spine column,
  written at the one writer, replacing three subsystems' re-derivations —
  LANDED 2026-08-07, the refs + decls columns, the peer closed);
  the verify/tighten BANKS (per-SITE durable facts — span-keyed
  obligations and tightenables — that become spine columns WITH their
  per-handle readers: the 11.2 dashboard's "V_Pending at this position"
  and 5.6's per-position audit read; sequenced there, not before — a
  column nobody reads per-handle is machinery. The AFFINE ledger is
  struck from this list by measurement, 2026-08-07: its state is
  transient bracketed judgment memory — used-set, borrow depth, branch
  frames, per-fn save/restore — that dies at scope exit; handler state
  IS its correct form, and the durable half it produces, the resolved
  ownership grade, already lands on the fn's TFun at 4.2's one writer).
  Band G rides along — SEQUENCED WITH THIS ARC BY MEASUREMENT
  (2026-08-08): `Hβ.egraph.per-expr-effect-row` is DEP-gated by its own
  site comment (is_pure reduces to effs_at only when infer grows a
  per-expr row binding — a spine column, this arc's own move), and
  `.typed-rulecyclic`'s RED case is unreachable-by-construction until
  the rule set grows (graph_canon_set's strictly-cheaper invariant
  makes the chain monotone; the typed refusal lands WITH the first
  grown rule, where a cycle becomes constructible). `.rule-as-query`,
  `.const-fold-minted-node-full-edges`, saturation deepened; and
  `Hβ.egraph.install-algebra` — the `~>` edge enters the e-graph (elision
  when the extent proves it, the row licensing both rewrite-legality and
  candidate-legality).
- **5.6 · `mentl audit` goes LIVE — the §0 keystone.** With judgments
  reading the graph (2), the surface true (3), ownership real (4), and the
  facts in columns (5.5), the audit is a READ: the Carried-Truth projection
  (`Hβ.audit.carried-truth-projection`) flags a re-derivation/snapshot/
  fabrication BEFORE a line lands — the census shapes, the iteration tier,
  the drift catalog, and the working-discipline hooks absorb into it, and
  the human stops being `mentl audit` by hand. THE ABSORPTION RUNS BOTH
  MOTIONS (opened 2026-08-08, the cadence established at one marched
  landing per mode): INTO the medium — three drift modes are census
  shapes with per-fn audit tiers (mode 10 wildcard-zero, mode 13
  failure-mask, mode 16 print-in-report — the last the first
  CONTEXT-SENSITIVE shape, a fuel-bounded subtree walk every future
  context mode reuses; the medium's detector out-measured the bash grep
  on its first run, 3 wheel sites vs 1) — and OUT of the scaffold: five
  bash rows deleted (modes 30 + 36's fence/keyword/fn-lambda), each
  shape probed COMPILER-REFUSED first (E_NotAKeyword, E_LambdaFence,
  E_RedundantFnOnLambda) — a bash row policing a refused shape is a
  weaker second copy of an armed diagnostic. The three absorbed shapes
  are RATCHETED (2026-08-08, the enforcement half): verify's drift-shape
  tier counts them on the wheel link per gate pass — wildcard-zero held
  at its 9 documented sentinels, failure-mask and print-in-report at
  ZERO — each arm seen RED at an under-set ceiling, and their bash rows
  retired in the same commit (the mode-33 precedent: the grep dies, the
  projection + ratchet is the check). Mode 10's typed fabrications
  (Forall/TVar/"Pure"/"") landed as the FOURTH shape
  (CsWildcardFabricates, pin 8f11d81b61d4 — the census roster at
  thirteen, the audit tier a quad), ratcheted at its measured 21 (seen
  RED at 20) with the four typed rows retired — mode 10 is WHOLE in the
  medium. Mode 15 (underscore-retain) followed as the FIFTH shape (pin
  54bf749eab9f — roster fourteen, tier a quint), BORN AT ZERO on the
  wheel link, its row retired; mode 8 (flag-as-int, three rows one
  shape) as the SIXTH (pin c7cf09a15a00 — roster fifteen, tier a sext),
  also born at zero, either operand order where the regexes saw one;
  mode 7's let-tuple as the SEVENTH (pin 74b43c43e00d — roster sixteen,
  tier a sept), whose dig corrected the anchor to the WEAVE shape (the
  one-arm match — desugar_block makes LetStmt PVar-only at parse, so
  the graph shape covers both spellings) and banked
  `Hβ.query.unreadable-source-refusal` (RESOLVED same day: the verb
  refused the empty weave, pin 76e85e00696e); mode 1's vtable as the
  EIGHTH (pin aa581cb8839b — roster seventeen), where the tier's
  widening count-tuple dissolved into ONE fold over drift_roster() —
  a future mode joins by one roster entry and one label; mode 7's
  param-adjacency row followed 2026-08-09 as CsParallelArrays' SECOND
  face (any adjacent `x, x_h` parameter pair, structural where the
  regex saw four literals — mode 7 fully absorbed), and its dig made
  the audit's per-fn walk UNIFORM: the walk starts at the fn node
  itself, so a shape living on the FnStmt (not in its body subtree)
  convicts — the body-only carve-out deleted. Mode 2 followed the same
  day as CsEnvFrame (the frame-stack family declared/referenced/bound,
  the tenth shape, born at zero) — THE STRUCTURAL CATALOG IS FULLY
  ABSORBED: every remaining drift-patterns row is naming/prose
  (foreign keywords, comment decoration, prose vocabulary), the raw
  text channel's own domain, which the weave census does not read by
  design. Its unsayability face
  matures through Phase 8's diagnostics; its arrival is when a wrong move
  in the wheel's own source is a REFUSAL, not a review finding.

---

### Phase 6 · The crown completes — `!E` sound at every altitude

The spine root finishes. Order inside the phase is the dependency order.

- **6.1 · R1: `EffName`-is-a-handle** — ✅ LANDED 2026-07-24 (pin
  91e35f1e, commit f695480d "identity is a contract"), found already
  whole at the 2026-08-08 phase walk: ENamed/EParameterized carry the
  intern handle, eff_name_handle is the Pure i32 comparison key, the six
  by-name str_eq leaves became word compares, and the landing's own
  record closes the residual — "the crown's positive-path residual
  closes by construction: byte-equal-but-pointer-distinct names are
  untypeable, and a missed mint is a loud type error."
  `Hβ.effects.positive-row-pointer-eq` dissolved there.
- **6.2 · Instance-precise negation** — ✅ MECHANISM WHOLE at the same
  walk (`eff_forbids`' instance arm refuses same-instance and
  not-provably-distinct, admits provably distinct; `eff_admits` the
  positive dual from Phase 1); THE GATE LANDED 2026-08-08: four
  instance crucibles in tests/crown/ (leak-instance-same,
  leak-instance-bare, sound-instance-distinct,
  sound-instance-bare-admits), crown 12/0 — and 6.2 is WHOLE: the
  fifth fixture (leak-instance-node, the EANode conservative arm)
  stands in the battery and holds, because the "unconstructible"
  ruling was measured on the wrong shape — a BARE-IDENT arg
  (`Sample(the_rate)`) parses as EANode and runs end-to-end through
  the handler (re-probed 2026-08-08: check clean, the install serves
  it); only a COMPOUND arg (`Sample(base + 100)`) refuses, at the
  grammar itself (the arg atom is one token). The peer's record is
  `Hβ.syntax.effarg-node-in-with-clause` in RESIDUE — resolved, with
  the compound-constant fold named as the W23 design's remaining
  reach.
- **6.3 · The modal world-index** — `Hβ.effects.modal-world-index` +
  `Hβ.infer.modal-capability-at-tee`: rows + capabilities + negation sound
  SIMULTANEOUSLY as a graph fact. The route is the graph, not the calculus:
  a row var becomes a lexical capability handle at the `~>` edge (no new
  surface form — SYNTAX's modal-readiness note), the modality inferred and
  cursor-projected, with the POPL-2026 rows≡capabilities encoding as the
  external check on the design and the NEGATION half carried by the
  flow-edge substrate the crucibles already police. The burden stays on
  the build: the crown battery grows a crucible per modal rule, RED-first.
  THE FELT WALK RAN 2026-08-08 (six probes; one same-day narration
  correction per the retraction law), and its measurements REFRAME the
  phase — today's medium already holds the conjunction on every walked
  shape: (1) the ESCAPE (a closure performing E, escaping its `~>`
  install, called outside — the shape capability calculi forbid) is
  ADMITTED, dispatched by tier — the static singleton tier direct-calls
  the one handler; under MULTIPLE handlers the dynamic innermost
  install resolves (mn-escape-innermost pins 20, refuting the walk's
  first "birth-capture" decode); with NO handler reaching the root the
  executable REFUSES (E_EffectUnhandled, armed — "nothing executes
  unproven" in the diagnostic's own words). (2) The NEGATION stays
  sound across the escape (leak-escape-negation: an outer `!E` refuses
  the escaped performance — the closure's row kept E riding the
  value). (3) MASKING satisfies negation (`with !E = (work) ~> h`
  accepts — the install's subtraction at evaluation). (4) POLYMORPHIC
  THREADING absorbs through the HOF (`run_it(() => op()) ~> h` under
  `!E` accepts). Crown crucibles pin all of it. The REMAINDER: the
  TIME half (a persisted k under a changed handler set — rides 9.1
  with 6.4's value gates), the per-modal-rule crucible sweep against
  the POPL-2026 encoding (OPENED 2026-08-08, nine rules pinned at
  crown 29/0 — accepts: mask composition with innermost dispatch
  measured at runtime, the latent/performed distinction (E riding a
  RETURNED closure's value row while the constructor's own row stays
  pure under !E), double-HOF threading, the mixed row's licensed
  half (F + !E performing only F), the absolute modality (a Pure
  closure born beside an absorbed perform transports out of its
  birth world unchanged — the []-boxed dual of the escape leak),
  the subtract half at the INSTANCE altitude (an instance-unpinned
  handler is SYNTAX's own "explicit handler bridge" — its install
  clears a pinned instance's row, satisfying an instance-precise
  negation; a handler pinned to one instance is unconstructible
  today, so the over-absorption crucible lands with that surface);
  refusals: install-extent
  exactness (an op AFTER the install closed is unabsorbed), the
  mixed row's negation half (the F license never launders E), and
  the tee's ADD half under negation (an arm-performed F meets an
  outer !F — row(expr ~> h) carries + row(h), so absorbing E never
  launders the arm's own F; the sound dual declares F + !E and the
  pair differs only in the declared row, its own control); the
  TENTH through TWELFTH rules 2026-08-11: latency rides STORAGE at
  ALL THREE carriers — the record field's row rides the field load
  (leak-field-latent / sound-field-transport), the list element's
  rides the index (leak-list-latent / sound-list-transport), the
  tuple element's rides the position (leak-tuple-latent /
  sound-tuple-transport) — refusal at the call, acceptance at pure
  transport, crown 35/0; the DEFAULT PARAMETER carrier 2026-08-17
  (leak-default-latent / sound-default-transport — a default is a
  callee-scoped fill, so its row is the callee's row and a caller's
  `!E` meets it though the call site names neither; the carrier is
  ORACLE-BLIND, the wheel writing no default-valued parameter at all,
  so its own pair is the only RED evidence available); the
  feedback-under-negation rule now waits only on
  3.6's BUILD (its fork dissolved 2026-08-12 — membership is the
  joined resume grade); the 2026-08-18 rule found a LEAK rather than a
  crucible and CLOSED it one pin later — a handler's STATE INIT performs
  in the installer's world (measured: the value reaches `s` through the
  outer handler, exit 7) and charged nobody, because the inits were
  judged two lines above `r_handle`'s scope while the ARMS were judged
  inside it. They are inside it now
  (`Hβ.effects.handler-state-init-row-never-installed`, pin
  b9733815b54d, crown 54/0), and the CONFIG DEFAULTS followed one pin
  later on the same measurement — the same leak one field over, the same
  move, one rule with two carriers: everything a handler install
  EVALUATES belongs in row(h) (pin c3410610ce41, crown 56/0); the third
  question those two left — an init performing the effect its OWN handler
  handles — measured to a GATE finding rather than a row one: the row is
  correct (a declared `!F` catches it) and the executable-root gate
  clears the name because a handler for it is installed SOMEWHERE, so the
  program compiles and traps. It is the mirror of the install-extent rule
  this sweep already pins — an op before the extent OPENS rather than
  after it closes — stamped as
  `Hβ.effects.root-gate-credits-an-install-that-had-not-opened`, with its
  general fix DEP-named on band A's modal install-identity; the
  sweep continues rule-by-rule), and the
  capability-at-tee PROJECTION — ✅ LANDED 2026-08-08 (pin
  2dcd736eb4e6): `mentl where` renders every install as
  `~> h absorbs E at <span>`, the effect set from the handler's own
  arms — the modality as a derived badge, the felt face real.
- **6.4 · TIME's world enforced** — the `TCont` world stops being inert.
  THE CAPTURE IS LANDED, verified at the 2026-08-08 phase walk:
  `Hβ.infer.tcont-world-capture-at-reify` is real —
  inf_current_world() (the current frame's LIVE row var, infer.mn:187)
  rides every PendingContinuationBoundary and
  finalize_continuation_boundaries threads it into the TCont's world
  field; and the declared-but-unwired `E_ResumeWorldMismatchWorld`
  ctor no longer exists (zero construction sites) — the runtime
  refusal is persist's rehydrate REFUSING via Fail, band B's own
  record. REMAINING here: the value gate's TYPED form (the Fail
  refusal graduating to a located diagnostic when the persist surface
  matures), `Hβ.continuations.world-widening-resume` (the typed
  superset-resume), `Hβ.persist.branch-world-tag` — all riding band
  B's persist runtime, sequenced with Phase 9.1 where that substrate
  ships.
- **6.5 · The gated verdicts unlock.** Everything band A held: ownership-
  as-effect VERIFIED, `!Thread`/`!Alloc` transitivity
  (`Hβ.parallel.thread-alloc-transitive-proof` — the `!Thread` HALF
  VERIFIED 2026-08-08 by crucible: the transitive spawn on the REAL
  lib/threading vocabulary refuses under a declared `!Thread`
  (tests/frontier/mn-thread-negation.mn, the frontier leg — the crown's
  stdin harness cannot link lib, so the real-vocabulary crucible lives
  there), the thread-free region accepts, and the REAL-TIME CLAIM
  measured: a bare `><` inside `with !Thread` accepts because the verb
  is pure topology — SYNTAX's provably-race-free sentence now has its
  gate; the `!Alloc` half rides the arena's honest-row attribution),
  race-freedom-by-ownership
  (`.race-freedom-ownership-proof`), and `Hβ.syntax.perform-dissolution`
  closing the surface's last ceremony — ✅ EXECUTED. Terminal gate: the
  crown battery whole (leaks reject, sounds accept, instances precise,
  worlds enforced) — DONE statement (2)'s first half.

### Phase 7 · `!Flow` — the crown applied to data flow

*(The phase's felt walk ran 2026-08-08 through the shim + fresh m2. The
projection layer is real end-to-end — `mentl query <f> "flow NAME"` →
QFlowOf → query_flow_label → predicate_flow_label — and the walk's one
find landed: the TFun arm read the ROW alone, so a `-> Vault` source
(`Vault = String where classified(self)`) answered Public while the
value's own scheme answered Secret; the return-label join closes it
(tests/frontier/mn-flow-refined-source.mn, seen RED against the boot at
exactly that split). Two named truths from the walk: the classifier's
vocabulary is a predicate-NAME heuristic (str_contains
secret/classified/sensitive in predicate_flow_label) — a seed the
`.flowlabel-inference-in-hm` chain replaces with labels as graph facts,
never the shipped form; and FlowLabel's constructors (`Secret`,
`Public`) occupy the user namespace, so a program's own `type Secret`
collides with the label vocabulary — the namespacing question rides the
inference landing.)*

The C chain in its banked order, DEP-rooted on Phase 6:
`Hβ.ifc.dcc-noninterference-gate` (FIRST FACE LANDED 2026-08-08, pin
a025c3523a84 — and its first probe caught the ShowExpr desugar
silently defeating the splice check: the wrapper bound every fragment
to String, the label read classified Public, and a classified splice
passed check with no fixture to see it; fixed by reading through the
wrap, the leak/sound pair born RED. The check is CONSTRUCTION-site —
sink-blind, conservatively sound; sink-sensitivity is the next step's
buy, the RESIDUE entry carries the full remainder) →
`.flowlabel-inference-in-hm` (STAMPED 2026-08-08, RESIDUE the home:
the flow fact is a ROW element — Flow(Src, Sink) charged at
observation edges, `!Flow(Secret, Log)` proving absence as !Alloc
does, the §4⑥ absorption executed on the existing algebra; labels
never ride the type union-find — one tainted Int would label every
Int; the sink-edge move retires the construction-site over-refusal) →
`.pc-label-implicit-flow` →
`.integrity-dual-lattice` (the agentic regime's forcing function — the
integrity spec that makes the mechanism honest) → `.declassify-robust` →
`.flow-world-on-tcont` (labels survive TIME) → `.agentic-fides-target`.
The honest disclaimer stands (the lattice proves where OUTPUT may go,
never what a model does inside its window). Terminal gate:
`!Flow(Untrusted -> Sink)` discharged like `!Alloc`, both regimes
first-class — DONE statement (2) whole.

### Phase 8 · Verification whole — proof beats review, measured

- **8.1 · `Hβ.types.predicate-is-expr`** — PExpr dissolves; predicates are
  ordinary expressions, and the comparison-chain degradation SYNTAX
  documents becomes the loud inference rejection.
- **8.2 · The decidable fragment complete.** The interval engine's banked
  redirect executes: the self-call IH lands on 5.2's dissolution (the
  peel/publish tower gone, class-based reads deterministic); the six
  standing `0 <= self` pendings discharge via authored refined annotations,
  march-measured each; `Hβ.refine.buffer-invariant`,
  `Hβ.infer.predicate-from-bool-expression`,
  `Hβ.verify.higher-order-refinement`, and the DSP tier
  (`Hβ.dsp.hz-ceiling-ambient-sample-rate`,
  `Hβ.dataflow.clock-calculus-sample-rate`) fill the fragment out.
- **8.3 · The SMT handler swap** — `Hβ.verify.smt-handler-swap`: Z3/CVC5
  behind `~> verify_smt`, certificate-CHECKED (the checker inside, the
  solver outside), discharging the undecidable residue by residual theory;
  if an external solver persists at DONE it is the NAMED external-SMT
  `!Outside`, priced honestly. `Hβ.verify.ledger-soundness` (no silent
  assume-true, the Dafny cautionary), `.proof-incrementality-cached-cursor`
  (obligations re-discharge only in the changed cone),
  `.reason-edge-pcc-certificate` (a discharged proof carries a walkable
  certificate — proof-carrying code as a Reason projection).
- **8.4 · Diagnostics' final form.** `Hβ.diag.catalog-as-projection`
  (report takes DiagKind; SYNTAX's three tables become projections of
  types.mn — the hand-kept second home dies),
  `.minimal-inconsistent-core` (`.declared-row-contradiction` LANDED +
  ARMED 2026-08-08 — the tenth refusing class, band L's entry carries
  the arc), `Hβ.emit.trap-as-exception-postmortem` (a BUG-trap unwinds with
  the graph state as payload), `Hβ.infer.marked-lambda-totality-invariant`
  — and UNIVERSAL executable refusal: the remaining name-dependent census
  classes become armed, so every diagnostic class refuses the executable.
  The audit's unsayability face (5.6) completes here.
- **8.5 · Band K — the proposer's receipts.**
  `Hβ.proposer.constraint-not-token-worked-example` (the Lahiri worked
  example answering the spec-oracle problem) and
  `.synth-handler-error-fed-back` (a refuted candidate returns as a
  lossless CONSTRAINT, not a lossy token). Terminal gate: DONE statement
  (1) — the crown sound, Verify decidable-with-honest-debt, SMT
  certificate-checked, every armed class refusing.

### Phase 9 · TIME and SPACE ship — computation durable, cursors parallel

- **9.1 · `persist = memcpy` becomes a shipping claim.**
  `Hβ.continuations.persist-equals-memcpy-handler` over the image-map fold
  (`Hβ.emit.image-map-fold` — the layout as ONE fold, overlap
  unconstructible; the multiple-memories proposal as the image/scratch
  boundary when the substrate carries it), `Hβ.persist.cross-machine-resume`
  (the session a value that moves), `Hβ.persist.module-image-cache` (band
  O — cross-run compile skip as image persist, the deleted .kai layer's
  lesson honored), `Hβ.driver.per-module-env-overlay`'s image face, and
  the multishot polish: `Hβ.lower.either-install-negotiation`,
  `.multishot-uzero-abort`, `Hβ.infer.tail-recursion-resume-cardinality`,
  `Hβ.ml.autodiff-as-multishot` as the demonstration workload. Felt faces
  land WITH it: `Hβ.felt.time-travel-debug-forked-cursor` and
  `.hole-is-dormant-continuation` (Hazel fill-and-resume = the record).
- **9.2 · The parallel cursors.** §5.O layer 4:
  `Hβ.driver.level-set-par-walk`'s multi-core half (`>< ~> Thread` at decl
  granularity on the compile spine) with
  `Hβ.native.deterministic-handle-partition`'s (arena_id, offset) law so
  m3 == m4 SURVIVES parallelism — re-pinned as the sharpest TRANSITION;
  `Hβ.lower.fanout-simd-lane-cashout` (RV128 real),
  `.fanout-gpu-backend-handler` named-or-built per hardware,
  `Hβ.cursor.work-stealing-via-gradient` (idle cores ask the cursor; the
  argmax IS the queue), `.speculative-compile`,
  `Hβ.lower.schedule-specialized-callee` (skeptically scoped as banked),
  `Hβ.f1.handler-substrates`. Safety verdicts ride Phase 6
  (`Hβ.native.effect-state-parallel-safety`'s row face).
- **9.3 · §5.O layers 1–2 finish.** Name-is-handle at LEX (the intern
  table born where scan_ident mints), env O(1) by handle
  (`Hβ.perf.env-o1-index` — largely dissolved by 5.2; whatever survives
  re-keys), reachability as an EDGE (`Hβ.lower.reach-edge-on-node`,
  `.reach-membership-o1`), `Hβ.infer.instantiate-shares-never-clones`
  gated on its alloc count. Every remaining scanner is a place the graph
  already knew — deleted, not tuned. Terminal gate: DONE statement (4),
  and the oracle's fusion substrate (N forked cursors × N threads × one
  image) REAL — statement (6)'s machinery.

### Phase 10 · `!Outside` closes — the execution layer joins the medium

- **10.1 · The native backend** — `docs/NATIVE.md` S0–S18, WASM-peer-
  verified through S12: `Hβ.native.frame-rep-from-cardinality-trail`
  (KEYSTONE 1 — frames in the image, the trail the reclaimer, continuation
  = memcpy stays TRUE natively), `.deterministic-handle-partition`
  (KEYSTONE 2, shared with 9.2), `.repr-regclass`, `Hβ.infer.use-profile`,
  `.reg-residency-egraph-remat` (allocation = residency, eviction =
  rematerialization at extraction cost), `.fp-simd-determinism` (SSE-only/
  no-FMA/RNE pinned — THE fixpoint-killer named before it kills),
  `.foreign-handler` (the one seam for the un-Mentl world),
  `.wasm64-backend-handler`, `Hβ.emit.memory-gc-handler` named. NATIVE
  FIRST-LIGHT: native_m3 == native_m4; wasmtime and WABT retire.
- **10.2 · Trusting-trust closes.** `Hβ.closure.diverse-double-compilation`
  (a second disposable seed converging to identical m3 — DEP native, per
  Wheeler), and `Hβ.closure.correctness-oracle-internal`: the micro
  battery ABSORBS into the wheel's own Verify, so first-light's
  correctness half loses its last external oracle.
  `Hβ.synth.proposer-gauntlet` closes reflexivity over proposers.
- **10.3 · The scaffolds absorb; the docs project.** march → `mentl march`,
  verify → `mentl verify`, state.sh → state-as-projection, the drift
  hooks → the live audit, the 0.2 lag list drains (`where` lands in 3.2,
  `why`/`diagnostics`/`verify`/`at` here), the shim dissolves into real
  `mentl run`/`asm`, wt-env.sh dies with it. `LEDGER.md` and `RESIDUE.md`
  begin dissolving into projections (`Hβ.query.generation-operand` —
  `mentl why --at <sha>`; the frontier ranking IS the residue index).
  Terminal gate: DONE statement (7) — every lever inside, and the two
  named residual Outsides (external SMT if it persists; the intent space,
  permanently) stated as exactly what they are.

### Phase 11 · POLISHED — the felt surface whole, the loop closed, DONE measured

The co-equal aspect (§4⑦) consolidated, not begun — most of its substrate
landed in 5–10; this phase is the finish that makes it FELT.

- **11.1 · The fused fan — THE ORACLE IS NOT A SEARCH.** It is inference run
  with the hole's constraints unresolved, narrowed monotonically, forking
  only where meanings genuinely CONFLICT. The received shape was measured
  2026-09-06 and contradicts the design it implements, five ways:
  `fan_verify` enumerates every candidate and THEN judges each
  (generate-then-filter, where §1's law is proof pruning guided search at
  every step); it forks UNIFORMLY, so form-variants pay full fork cost in
  the code that cites the fork/merge duality; each `candidate_judge`
  re-infers WHOLE in an isolated instance (recompute, not refine — the
  `Frozen` law at the search layer); those instances take an empty
  `graph_handler`, so a fact proven in one branch is invisible to its
  siblings and the shared image is paid for and unused; and the fan spawns
  through `spawn_task` DIRECTLY — zero uses of `><` in synth_proposer or
  oracle — at a width set by the `judge_window` constant, where the
  language's own `~> Schedule` is read live at every other fanout. The
  crown jewel is the one place Mentl does not solve Mentl.
  **THE ULTIMATE FORM:** propagate, then enumerate (narrow the hole's
  type/row/ownership/refinement first; enumerate from the PRUNED space,
  cheapest constraint first); construct only inhabitable terms
  (type-directed from the vocabulary's own types — ill-typed candidates are
  never BUILT, not built-and-rejected); FORK AT MEANINGS, MERGE AT FORMS
  (form-variants saturate in the e-graph, monotone and needing no
  isolation, so the fan's width IS the number of genuine ambiguities —
  exactly what the tie-break must resolve); judge the context ONCE and let
  branches read it live, candidates as deltas; LEMMA SHARING, JOIN-ONLY (a
  proven fact independent of the branch's candidate is monotone and may
  flow to siblings — branch-local bindings never do, the 2026-08-07 race
  and the severance that hid it; this is portfolio solving with clause
  sharing over the shared image, and it is where threads actually pay);
  the fan written as `(c) >< (c) ~> Schedule` so width is a handler
  decision and `judge_window` dissolves; multi-shot making the SEARCH
  durable (a branch is a continuation record, memcpy-serializable, so an
  exploration suspends and resumes across runs and machines — the axis no
  peer has); prove-then-extract FORCED; and never a list — unique survivor
  fills, multiple meanings ask the ONE minimal-entropy question, because a
  list is the medium admitting it does not know.
- **11.2 · `mentl edit` / `mentl space` polished.** The keystroke→parse→format→render loop
  continuous (`Hβ.felt.mentl-edit-runtime`), reactivity typed and
  demand-driven, the verification dashboard (live V_Pending / transitive
  `!E` / Why chains), collab as Grove-CRDT over the TYPED graph,
  legibility derived. The Resident Space Session (`ide/wheel-worker.js`,
  `ide/test-shim.mjs`, `ide/index.html`) hosts the living graph over shared
  WebAssembly memory with sub-50ms address projections and delta updates,
  verified green across Node and headless Chrome (`tools/ide-gate.sh`).
  Every reader-facing page leads with the person at
  the keyboard; the docs themselves pass the source standard.
- **11.3 · DONE, measured.** The seven statements run as gates, each
  already owned by a phase above — (1) Phase 8, (2) Phases 6–7, (3)
  Phases 2–3 + 10.3's Why-total, (4) Phase 9, (5) Phases 5.6 + 8.4 +
  11.2, (6) Phase 9's fused oracle as the default judge, (7) Phase 10 —
  and the TERMINUS is measured against its three legs: next-move
  supremacy, the question beats the guess, the loop is felt. Teachability
  is leg 3's named face: the surface IS the course. The board that day is
  the same board as tonight — verify, march, crown, frontier, census,
  doc-truth — every gate green through a pin the medium blessed itself,
  and the honest audit in §7 EMPTY, because a seam held open on purpose
  is the one thing DONE has none of.

**NOT A PHASE — the docs record what is true as each phase lands.** Batching
doc-truth at the end is exactly what produced the eleven-entry crown gap. §7's
honest audit, `LEDGER.md`, and `RESIDUE.md` move with the artifact or they are
the next drift.

**Excluded by hardware only:** MI300X execution, hosted CI, wasmFX,
shared-everything-threads. Every dispatched agent runs Opus 5 or Fable 5 —
whichever is most effective for that job — passed explicitly; every landing
re-derived on main; the board is the gate.

**THE FELT-PATH-FIRST LAW (paid for 2026-07-28): every phase OPENS by walking
its felt path** — the exact surface an outsider or the daily loop touches,
through the installed shim, before any build starts. A DEP found by walking is
cheap; a DEP found by an outsider is a category loss.

**THE TERMINUS is §1's closed loop:** human and Mentl only, no LLM
advantageous at any scope — every landing measured against the three legs
(next-move supremacy · the question beats the guess · the loop is felt). Leg 3
carries TEACHABILITY as a named face: the surface IS the course, evolved until
picking up Mentl teaches programming itself, so the model is unemployed at the
learning scope too. And every reader-facing page leads with the person at the
keyboard; verification is the mechanism and the receipts, never the identity.
