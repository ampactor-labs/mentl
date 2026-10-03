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
accruing honest `V_Pending` debt). One named residual Outside: the internal
correctness oracle (`Hβ.closure.correctness-oracle-internal`). An external
solver is not one — Verify's search is the medium's own (§11, 8.3), and a
solver outside it is a proposer whose certificate the kernel checks, as a
model behind `Synth` is (decided 2026-10-02).

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
- **AND VALIDATED FROM OUTSIDE BY WHAT THE FIELD CANNOT DO** (surveyed
  2026-09-21). Two findings, both load-bearing, both citable.
  **(a) The soundiness ceiling.** Nearly every tool that reasons about a whole
  codebase is downstream of a call graph RECOVERED BY PARSING, and that
  recovery is measurably lossy: median recall **0.884** for static call-graph
  construction on real Java programs against a dynamic oracle (Sui et al., ICSE
  2020); **13 static analysis tools missed 61% of dynamically-executed
  methods** across 1,000 Android apps, whose authors wrote *"a high level of
  precision in call graph construction is a synonym for a high level of
  unsoundness"* (ISSTA 2024); and the field formally conceded the position as
  **"soundiness"** — sound on ordinary control flow, deliberately unsound on
  reflection, dynamic loading, `eval` and native code. Mentl's edge is DRAWN by
  inference, not guessed by a parser, and `!Outside` means there is no dynamic
  escape hatch to be unsound about: handler dispatch is itself graph content
  resolved through the live world chain. Every recall number above becomes 1.0
  — **not by a better algorithm, by a different substrate**, which is the
  shortest true statement of this project's advantage.
  **(b) The decidability line, which has a funded competitor sitting on the
  wrong side of it.** Google's Capslock answers "what can this dependency do?"
  for Go and ships into `deps.dev`. Its own caveats document concedes that
  reflection, `cgo`, assembly, `go:linkname`, `os/exec` and `plugin` collapse
  to `ARBITRARY_EXECUTION`, and that reported call chains *"may not necessarily
  occur in practice"* — and **nowhere does it claim that absence of a reported
  capability is a guarantee, because it cannot.** Capslock can say *"I found a
  path to NETWORK."* It cannot say *"there is no path."* WASI's component model
  gets capability typing, but DECLARED, at the host boundary, whole-module.
  `!E` under polymorphism, transitively, per-instance is the only thing in that
  survey on the other side of the line — which makes §0's property (2) not
  merely Mentl's most underrated arm but its most defensible one.

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

**⑥ Information flow is the influence walk, not a row element** (decided
2026-10-02, superseding "the row carries information flow"). `!E` + `~>`
already subsumes capability security; what flow adds is WHICH value may reach
a sink, and the graph already carries that relation. Since P0 a refinement is
read along a value's flow edges, since S5 a handler's state is every value
written into it, and since E4 the parent edge gives control dependence (the
branch a perform stands under). So a classification is a refinement on a
source's declared type (`-> Untrusted`), a sink's demand is a precondition on
its parameter (`exec(cmd: Trusted)`), a leak is `E_RefinementRejected` at the
argument, and precondition inference carries the demand up the call graph to
where the data enters; endorsement is a function whose declared return states
the stronger label, the one place a policy check lives; an implicit flow is
the ancestry walk to a classified scrutinee. A `Flow(Src, Sink)` row element
and a label lattice beside it would be a second home for one fact (Morgan's
challenge named the reification; the artifact P0, S5 and E4 built is the
measurement). The agentic regime's forcing case — untrusted tool output must
not reach a privileged sink — is the same machinery with the order reversed.
Sequenced as Phase 7 (§11).

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
   durable-execution-as-handler (§4④), value-ontology (§4①), Verify's own solver, native/
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
read corrects). The arena's win landed as that ceiling FALLING — 1,050,000
→ 884,000 KB on 2026-10-03, read off three runs of the boot that carried
it, and 884,000 → 594,000 the same day once every extent ran in one.
state.sh
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
3. **The arena** (`Hβ.perf.per-decl-arena`, LANDED 2026-10-03) —
   `(body) ~> arena`: an extent's allocations die at its exit except what
   its publication reaches, which moves by type, so the reset costs what
   crossed, never what died. Reclaiming is reachability from the
   publication, not a `Consume` (ownership's regions stay compile-time).
   Placed at the judgment's binding groups (its high-water 511 → 288 MB,
   the self-compile's peak 1,065 → 874 MB) and then at every extent beyond
   them — each declaration's lowering, each emitted unit, each session
   answer, each speculation (the heap when the module is written 741 → 438
   MB, the peak 870 → 575 MB). Remaining: the per-thread regions layer 4
   needs (`Hβ.arena.per-instance-regions`).
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

- **Regions are runtime since the arena** (2026-10-03, the bullet after
  E4's): `(body) ~> arena` reclaims an extent's allocations at its exit
  except what its publication reaches. Ownership's regions stay what they
  were — compile-time root-tagging and return-transfer — and the arena does
  not read them: an exit decides by reachability from the extent's
  publication, never by a `Consume`. Every extent runs in one — the
  judgment's binding groups, each declaration's lowering, each emitted
  unit, each session answer, each speculation — and nothing else reclaims:
  the raw rewind beside `heap_mark` is deleted (the bullet after the
  arena's).
- **`persist = memcpy` IS BUILT, and this line said it was absent** — the doc
  rot named as violation #1, measured 2026-09-07. `lib/persist.mn` writes
  `[0, heap-line)` plus a bounded globals header STRAIGHT FROM THE IMAGE to
  the file (`fs_write_image_impl`, one host op, all-or-nothing — 2026-09-17;
  it had been a 2x buffer copy behind a 960MB capacity gate that refused the
  wheel's own image, both deleted); `image_resume` gates on the build key and
  swaps it in; `mentl resume <image>` re-enters a persisted image with the source not
  required to exist; and the driver's warm start restores an analyzed image
  rather than re-inferring. The honest remainder is NOT the mechanism: host
  resources (fds, stdin position, sockets) are outside the image and do not
  restore, and persisting mid-spawn is band E's fusion work. Durable
  execution's *substrate* is here; its cross-machine face
  (`Hβ.persist.cross-machine-resume`) is not.
  **The cost of this sentence being wrong was real**: a session reading it
  would have built the memcpy that already existed.
- **`TCont` effect-WORLD** is INERT on OneShot as a VALUE and LIVE as a RULE
  (A5, 2026-09-27). The perform-site boundary's world is LENS §2.4's static
  remainder now — the union of every frame's live row cell from the site up
  to the nearest enclosing tee that absorbs the effect, read off the frame
  stack whose install marks carry what each tee absorbs
  (`inf_remainder_world`) — and the arm-world rule is enforced where the
  remainder is known: at every install, the tee body's row minus what the
  handler absorbs is judged against the handler's own declared negation
  (`remainder_gates_check`), so `handler h with !F` installed over a body
  whose remainder performs F refuses at the install naming `h`. That clause
  had been SKIPPED by the parser since the seed ("WAT-invisible"), so a
  handler's `with !F` bound nothing until this landing; it rides the
  `HandlerDeclStmt` and is judged at registration like a fn's. The arm's own
  `TCont` world at registration is still the arm frame's cell, and there is
  no first-class `k`: "inert" means the stack-only path never becomes a
  rehydratable continuation value, so no changed-world comparison can fire
  there. The remainder is the single continuation/image value model — capture
  the world at reify, persist/fork it as an image record, refuse a mismatched
  resume through the row check every `~>` edge already uses — and the
  identity half (an outer install shadowed by an inner one of the same
  handler, `Hβ.effects.arm-world-static-rule`) was measured 2026-09-30 as
  the row being exact, not blind — L5's bullet below carries the hole that
  measurement found instead, the partial handler.
- **O(1) complexity** is the DIRECTION, not built. Honest contract: O(1) chase,
  O(changed cone) incremental, O(reachable) image, O(1) reclaim-after-proof.
- **Executable refusal** is PARTIAL — read `diag_refuses` for the live list and
  its size; this doc carries neither. It used to say "fifteen classes refuse" in
  the same breath as "never this doc", and the artifact measured EIGHTEEN on
  2026-09-15 — a sentence that told the reader not to trust it while giving them
  a number to trust. **A count in prose is a copy of a fact the artifact holds**,
  so the count is deleted rather than corrected: the pointer is the whole
  content. The remaining census classes are the ratcheting work toward
  universal, and the ZERO-held ones are not ratchet work at all — a class
  measured at zero is armed, not counted (`diag_refuses`' own licence: "born at
  ZERO on every program measured, which is the point").
- **Per-module manifest** — CLOSED at entry AND per-module (2026-09-27): a
  name a module reaches only through the whole link refuses
  `E_MissingImport` at the reference inside the one judgment — the declarer
  read off the statement's own column, the closure one table per judgment
  with the prelude's closure ambient — armed at zero on the wheel; the
  63-process solo sweep and `solo_violations_max` are deleted, and verify.sh
  keeps only the islands leg (the modules the entry never links). The overlay
  is the stamped second half.
- **Thread schedule** is REAL (host threads over shared image; measured
  2026-09-25 at 2×: two 1.5e9-iteration branches, bare 4.50 s wall / 4.47 s
  user, `~> parallel_compose` 2.31 s / 4.57 s) — and A BRANCH RUNS IN THE
  WORLD IT WAS SPAWNED IN (2026-09-27): the task record carries the spawning
  frame's world and the fresh instance installs it before the thunk runs, so
  an effect performed inside a spawned branch reaches the handler at the
  fanout's frame (`Hβ.threads.perform-inside-spawned-branch-traps` CLOSED —
  it faulted at the 0x100000000 belt before; the identity fixture had passed
  only because `thread_id()` is a direct WASI op). What sharing the chain
  exposes is refused at lowering, `E_ThreadedBranchEffect` (armed): every
  effect a branch's row carries must reach, at the fanout's own frame and
  before the frame fence, a STATELESS handler — transitively through each
  covering handler's own residual row, because an arm runs in the spawned
  instance and its performs resolve outer. A stateful handler at the frame,
  an install beyond the fence, and a stateless front over a stateful back
  refuse (the third was accepted by the rule's first form and RAN, measured
  before the pin); each branch installing its own handler runs. SYNTAX's
  "provably race-free" sentence has its gate, and the gate reads WRITES: a
  handler is stateful when an arm carries a `resume … with` update, so a
  state only read shares one immutable record across instances and runs.
  The thread gate reads the compile's width off the boot's import section
  and `main`'s row, which must agree (2026-09-28): its host-`clone` ratchet
  went red three times on a module that cannot spawn
  (`Hβ.threads.gate-counts-host-clones`, CLOSED). Safety gated on
  band A. SIMD/GPU remain scaffold (bands E/O). **PERSIST IS NOT IN THAT LIST
  and this bullet said it was until 2026-09-15** — six lines above, the
  persist-is-built bullet exists *because* the absence claim was named "doc rot
  violation #1" on 2026-09-07, and the correction landed in that bullet while
  this sibling kept the old word. One truth, two homes, and the fix took at the
  first home only: the Carried-Truth Law at the doc layer, inside the section
  that arbitrates it. What is genuinely open for persist is the cross-machine
  face (`Hβ.persist.cross-machine-resume`) and host resources outside the image,
  both named in that bullet.
- **Subsystem-as-cursor** (§2) is ~60% earned. Gap ranked: LOWERING (39
  constructors → columns), ENV (dissolves with schemes-are-edges), REVERSE EDGE
  (the refs + decls columns landed 2026-08-07 — but `refs_col` is keyed by
  NAME, not handle, so it is the reverse edge's waypoint, not the edge;
  `Hβ.lower.reach-edge-on-node` is the handle-keyed form, and this line said
  "landed" for six weeks while PLAN cited that peer three times and RESIDUE
  never held it — corrected 2026-09-17), verify/tighten BANKS. The move: put the fact in a column,
  dual-write, migrate readers, delete the side-structure — and its full cycle
  ran once at pin 8aeca3c8: the emittable-fn enumeration went from dual-written
  and zero-read to carrying each symbol's signature edges, emit's six
  re-derivations of the emitted ABI became one settled read, and the walker
  that only re-derived it (`find_local_handle_expr`, 30 arms) deleted. Eleven
  walker families remain of the twelve that entry enumerates.
- **Schemes are VALUES, not edges** — the root the judgment tower compensates
  for. Row half LANDED (5.2); forward-HOF under-publish CLOSED (pin c6eb188e1d37).
  Rung 3 whole is the dissolution.
- **The judgment is ONE pass** (2026-09-17 — the trial/final tower deleted,
  `LEDGER.md` carries the numbers). The planned layer sweep and its block fan
  went with it, and `judge_window` followed it out on 2026-09-19: its last
  reader, the ??-fan, stopped copying the graph, so the constant that paced
  a spawn has no successor rather than a serialized life. A candidate is
  judged inside a checkpoint on the ONE live graph now; the width returns at
  Phase 9.2's deterministic handle partition and atomic join writes, as a
  `~> Schedule` decision, never a constant.
- **The caret projection DROPPED MODULE IDENTITY — measured and CLOSED the same
  day** (2026-09-19). `mentl <file>:<line>` read the SOURCE by (file, line) and
  the GRAPH NODE by line ALONE, so on a multi-module link whichever module owned
  that line number was judged instead: `src/synth_proposer.mn:733` rendered
  `segment_verify`'s source beside `scan_number`'s type, effects, ownership,
  Lede and Why, and `src/lower.mn:733` did the same, because `src/lexer.mn:733`
  owns that line. Every aspect agreed with itself, which is what made it
  unnoticeable, and it was demo-blocking by Arc E's own terminal gate
  ("eight-aspect projections at the caret"). The address narrows the span index
  to the addressed module before the three-case line rule runs; the module
  handle comes from `collect_module_cells`, which was standing on it at every
  step of its own walk and dropping it — the defect `driver_module_ast`'s
  comment had already confessed. `Hβ.cursor.address-drops-module-identity`
  carries the record, and the same root at the DIAGNOSTIC surface (Landing 1's
  candidate leak to `strings:0:0-0:0`) is now its own named peer rather than a
  second witness riding this one.
  **THE FINDING WORTH CARRYING FORWARD is what the fix EXPOSED**, because it is
  §11's POSITIONS face saying the same thing twice: with the strangers gone, the
  module NODE won the covering case at every line no decl reaches, and one layer
  over, `module_path_of_span` answers "which module is this span in?" by
  containment over NModule spans — which stopped being able to answer once each
  module's spans became its own 1-based coordinates. A position that is not
  module-qualified is not an address, and the medium held three machines that
  believed otherwise. Two are closed; the third
  (`Hβ.cursor.module-of-a-span-is-containment`) dies with the proximity rank.
- **Incrementality is not a cached cursor yet, and the precise shape is
  sharper than "epoch is a counter"** (corrected 2026-09-19). Epoch IS used as
  an invalidation key: `project_queue_merger` (oracle.mn) memoizes the project
  queue on it and re-projects when it moves, with its own comment stating the
  law correctly. What is missing is the CONE — it re-projects the WHOLE queue,
  collapsing to one boolean a per-handle delta the graph already computes.
  `graph_mutated(Int, Mutation)` carries *(handle, prior value)* at nine write
  sites and **every handler in the tree discards both arguments**
  (`mutate_sink`, `lsp_adapter`), so the delta is write-only
  (`Hβ.graph.mutation-delta-is-write-only`). The warm start likewise restores an
  image and re-derives the compile over it (§5.O).
- **Resident Space** keeps its graph since E2 (2026-10-02, the bullet after
  D5's): one WASM instance answers for the session's life, an edit re-judges
  only the cone it moved, the accept is drawn into the graph the session
  keeps, and the IDE gate times every read. Each answer runs in an arena
  since 2026-10-03 and keeps what the session learned and nothing it only
  computed — a read 24 bytes, an edit's fresh generation 119,600
  (`Hβ.session.answer-scratch-outlives-the-answer`, closed; the bullet
  after the arena's). What stands between it and the shipping medium is a
  durable image boundary: a session derives once per open, and a fresh
  process derives cold (`Hβ.felt.accept-outlives-the-process`). The eight aspects at the
  caret are read off the graph since E4 (the bullet after E2's).
- **Demand linking / prelude caching** must be graph reachability, not a token
  allowlist. The demanded set is read from import edges, free-name binding edges,
  desugar-introduced names, and row/handler/type obligations; the prelude should
  become a frozen image slice, not a reparsed text prefix. A bare program's line
  floor is useful only when this reachability law is true.
- **THE NESTED-FRAME PRUNE DROPPED PARAMETER ROWS — CLOSED 2026-09-25.** A
  lambda, a `~>` body or a fanout thunk exited the completion prune with its
  own signature as the keep-set, so a parameter's row cell was dropped as
  scratch before the enclosing declaration's gate read it: `fn run(f) = (f())
  ~> h` published Pure and a program performing an unhandled effect passed
  `mentl check` and trapped at the root — no negation involved, the root gate
  blind. Fixed by the inherited keep-set (every exit prunes with the whole
  frame stack's signatures) plus the tee reader's catch-all; the pass-through
  form was built first and refuted by the wheel at 163 mismatches (scratch
  kept behind a mask cell became a channel between callers). What the fix
  exposed is the open half: the wheel's declared positive rows omit what
  their callbacks perform wherever this prune hid it
  (`Hβ.effects.declared-positive-rows-under-count-callbacks`), and the
  decision is to infer and project the positive row (Morgan, 2026-09-25).
  `E_EffectMismatch` is ARMED at the same pin: the crown's own verdict had
  printed and let the program run.
- **A `~>` MASK SPILLED ONTO THE EDGES BESIDE IT — CLOSED 2026-09-26.** A
  row held one absent set for its whole open tail, and the stored flatten
  folded each install's mask cell into it: `fn run(f, g) = f() + ((g()) ~>
  h)` published `!E + r_f + r_g`, so a caller declaring `!E` over an
  E-performing `f` was ACCEPTED, and two tees erased each other's callbacks'
  effects. No negation was needed for the row to be false. The mask rides
  the edge now (`RowEdge(cell, mask)`,
  `Hβ.effects.mask-spills-onto-sibling-edges`), `diff_row` writes nothing,
  and paths to one cell meet by intersection. The gate A3 installs pushes exactly this per-edge mask. What
  it exposed: the executable root gate still credited an install ANYWHERE, so
  `fn main() = op() + ((op()) ~> h)` — row `E`, correct — compiled and
  trapped; CLOSED 2026-09-27, the bullet after next.
- **THE NEGATION GATE IS CARRIED BY THE CELL — CLOSED 2026-09-27.** A
  declared `!E` over a body row that resolved to a parameter's free cell
  constrained nothing: `fn run(f) with !E = f()` accepted `run(() => op())`
  and ran, and so did every shape LENS §2.6 lists — two parameters, a
  masked tee's second negation, a sig'd self-reference, a cycle member, a
  chain, an outer wrapper, a stored callback. A gate is a constraint the
  CELL carries (`Gate({reason, row})`): the declaration's exit installs it
  on the resolved row's free terminals through each edge's mask, every
  writer into a gated cell judges the folded value and pushes the gate
  onto its free terminals, copies minted while the declaration is open are
  noted under their root, and the refusal names the declaration. The
  universe row appears in gates and nowhere else (an authored `!E` on a
  function-type parameter is a gated free cell, which un-refused
  `fn both(f: () -> Int with !E, g) with !F = f() + g()`). Crown 89/89, the
  36 probes a 36/36 battery, the wheel at zero diagnostics
  (`Hβ.infer.declared-row-vacuous-against-a-free-body-row`, LEDGER). What
  it exposed: K = 3 Mycroft rounds are one short of the fixpoint on a
  shape whose recheck grounds the return from the callback, so the accept
  path was unreachable there and the mono re-run judged it
  (`Hβ.infer.mycroft-recheck-one-round-short`).
- **THE EXECUTABLE ROOT GATE READS THE ROW AND NOTHING ELSE — CLOSED
  2026-09-27.** It cleared a name because a handler for it was installed
  ANYWHERE in the post-reach tree — no extent, no nesting — so `fn main() =
  op() + ((op()) ~> h)` compiled and trapped, an arm asking its own handler
  for a sibling op compiled and aborted (the arm runs in the install's own
  world, so its performs resolve OUTER — measured at four shapes), an escaped
  closure called bare at main compiled and aborted, and a reachable perform
  with no install anywhere passed `mentl check` (2026-09-21's finding). The
  credit is deleted; the gate reads main's row and the emit's demand census,
  and the install half of that census — read by nothing else — with it. The
  wheel refused FOUR effects at its own root the moment the credit went, and
  every one was a real latent trap the credit had covered: `interrogate_all`
  mapping the `interrogate_at` OP over every position (now a plain fn both
  arms call); the voice's run arms asking `file_text` of a handler the
  documented composition installs INSIDE them (moved beside the handles table
  they read); the allocation strategy installed in emit_context OUTSIDE every
  sink a march or a battery installs inside (it installs where the emitter
  allocates, inside the live sink — the fold leaves' bracket added, and the
  strategy's whole-compile install deleted); and verify_ledger at main
  reading the graph outside graph_handler's extent (moved inside the
  dispatch chain). Seven crown sound crucibles had refused at the root on
  every boot since birth — no handler at all — behind a judge that counted
  one class; the judge counts both refusals now and the crucibles carry
  handlers. Crown 94/94 (five root crucibles, three red on the prior boot),
  the frontier's escaped-install leg a compile-time refusal where it pinned
  a runtime 134. What the row still cannot see: an outer install whose arms
  are shadowed by an inner install of the same handler (`((twice()) ~> h)
  ~> h` runs to 20 and refuses) — measured 2026-09-30 as effect-granular
  PRECISION, not a hole (`Hβ.effects.op-granular-arm-reach`); the hole
  that walk found was the partial handler, closed the same day (L5, below).
  (`Hβ.effects.root-gate-credits-an-install-that-had-not-opened`,
  `Hβ.effects.reachable-perform-with-no-install-compiles`,
  `Hβ.effects.an-arm-may-not-perform-its-own-handlers-ops` — all CLOSED.)
- **THE MEDIUM'S OWN PROJECTIONS WENT UNASKED, and asking them was the whole
  audit of 2026-09-21.** Six findings, one law — *a fact with two homes, or a
  fact restated where an edge already carried it* — and every one was found by
  a verb, not a grep. `mentl audit src/main.mn` (never run before): 303 lines,
  of which 122 were `severable:` lines carrying TWO distinct facts, because a
  module-level truth was re-derived per function; severance reads at the module
  now and a function's line carries only its delta (303 → 210, the 56 real
  findings no longer buried). `mentl query <entry> unreachable`: 276 decls in
  one flat list, of which 202 sat in modules where NOTHING is reached — library
  surface a program links, not dead code — and 74 sat inside modules the entry
  runs through; the facet partitions on that ratio now, which is how the dead
  ranked-queue oracle became legible in one read. `mentl check src/main.mn`
  answered ONE diagnostic on 3,056 decls — `E_RedundantBraces` in the wheel's
  own `dispatch_invocation` — so the wheel was not at its own formatter's
  fixpoint; it is now, and the wheel's source carries zero diagnostics.
  Beside them: `fmt` was the last verb on a solo entry route that installed no
  diagnostic scope (it narrated every dependency at a developer who named one
  file) and is on the weave route with `driver_check_entry` deleted; the Why
  chain had two renderers, the dead one the worse form, and one is gone;
  `tools/verify-baseline.txt` held 646 lines — 38% — as a second home for the
  twelve bounds that moved to `src/board.mn`, read by nothing, and they are
  gone. **The transferable half is the method, not the count: the verbs
  answered in minutes what hand-reading had not asked in weeks, which is §0's
  fifth property working — and it only works when someone runs them.**

- **`m3 == m4` HAS NOT BEEN MEASURED IN AT LEAST TWELVE PINS, and the reason
  it does not matter is worth stating so nobody re-discovers the gap as a
  scare.** `march.sh` asserts **m2 == m3**, which IS the fixed point in the
  boot era because boot is itself wheel-emitted. The m4 leg exists as the
  ARBITER ON FAILURE: when m2 ≠ m3 the march generates m4 itself and rules
  TRANSITION (m3 == m4, re-pin from m3) vs BROKEN. On a CLEAN march m4 is
  deductively redundant — if `m2 == m3` byte-for-byte then m3 *is* m2, so
  `m4 = m3(src) = m2(src) = m3` follows.
  What m4 would actually test on a clean run is **determinism itself** — same
  wasm, same input, same bytes — which does NOT follow, and which
  `march.sh --fixpoint` exists to check. Measured 2026-09-21: **nothing
  invokes that flag.** Not `state.sh`, not a hook, not `tools/ci/run-board.sh`;
  the only matches are comments in `frontier-gate.sh` describing what the
  fixpoint is blind to. The last twelve pins are all CLEAN. So this is the
  ide-gate shape one layer down — **a leg that only runs on failure has never
  been exercised on success** — and `Hβ.march.determinism-is-never-probed`
  carries it.
- **THE POSITIVE ROW IS INFERRED AND PROJECTED — the wheel authors none
  (A4, 2026-09-27).** A signature used to be an inventory: 1,336 of the
  wheel's 1,626 `with` clauses carried bare positive names (132 signatures at
  four effects, 155 at five, a tail to NINETEEN), each a hand-copy of a fact
  inference computes — SYNTAX says the declared row is "a CONSTRAINT verified
  against the row inferred from the body" — and every one buried the `!E`
  worth reading. `T_RowInventory` narrates a clause whose bare names the body
  proves exactly, OR whose body row is open (a cap that installs no gate
  constrains nothing), `mentl tighten` writes each clause's RESIDUE — its
  negations and instance pins, or no clause — and `CsAuthoredPositiveRow`
  bounds the wheel at ZERO (seen RED at 164 through the swept-halfway tree).
  The medium authored the sweep itself, 1,148 + 157 + 164 + 21 patches over
  five runs; 529 clauses remain, 273 negation-only and 256 `Pure`, every one
  a decision. What the sweep exposed: NOTHING — the wheel judged clean
  through the fully inferred rows with zero `E_EffectMismatch`, the
  negations having been true all along, and the m3 leg's warnings fell
  161 → 62. `type Judging` (2026-09-21's named capability) lost its last
  user and is deleted. `T_OverDeclared` reads the positive half only: a
  negation-only signature is never "over-declared" (it narrated
  `!Mutate + Any` against a Pure body). **And a surviving positive row is a
  GATE (A3-pos, the same day):** `declared_gate` installs the closed row
  itself, so `fn run(f) with E = f()` refuses `run(() => op_f())` at the
  argument edge (accepted by boot d27fc81d, where only the negation half
  installed) and a `~>` mask inside the body widens the cap (`Pg ∪ mask`);
  crown `leak-cap-callback` / `sound-cap-admits` pin it. Two micros carrying
  `with Abort` on a try/catch HOF refused on arming and lost their caps —
  LENS §2.2's predicted class. On the wheel a positive row is a refused
  inventory; in user code it is a decision the medium enforces.
- **A HELD SINGLE RESUME IS REIFIED, AND A MULTI-SHOT PERFORM IS PRICED —
  CLOSED 2026-09-27 (L0 of the Pulse sprint).** Two foundation defects found
  by reading the emit against the ultimate instead of against itself, the
  day Morgan corrected "byte-identical to today's emit" from a ceiling back
  to a regression oracle. (1) Code after `resume(v)` in an arm was DEAD:
  every resume graded `UOne`, `UOne` lowered as the stack `return`, so
  `handler dbl { ask() => { let r = resume(1); r * 2 } }` over `ask() + 1`
  answered 2 where the deep-handler contract says 4 — one-shot conflated
  with tail-resumptive. The grade is `ResumeUse` now (multiplicity × the
  position of the one use — ownership's return-transfer distinction read on
  the continuation), and a HELD single use takes the reified path, called
  once (`Hβ.lower.oneshot-nontail-resume-drops-post-code`; the record's
  O(1) reclaim is `Hβ.lower.held-resume-record-is-not-reclaimed`). (2) A
  multi-shot perform allocates its remainder record and no row said so:
  `fn quiet() with !Alloc = flip()` under a two-resume handler compiled
  clean — property (2) false at a shape the crown never wrote. The op's
  published row carries `Memory + Alloc` at the discipline join, and the
  join is drawn at PRE-REGISTRATION from the classifier's summaries, so an
  op's discipline and cost stopped being facts of source order
  (`Hβ.effects.multishot-perform-allocates-unrowed`). The wheel's emit
  moved in no k fn, driver or twin; twelve fixtures lost the `with Choice`
  caps that had been inventories all along. A lambda-wrapped resume is held
  unless its callee is PROVEN tail-transparent in that parameter
  (`tail_transparent_params`, gated on the tail spine's callee names so the
  proof costs nothing where no declaration calls a parameter at its tail —
  the first form's ~100 MB of per-parameter free-variable lists refused the
  repin at the cost ratchet, the ratchet doing its job).
- **ARITHMETIC DEMANDS A NUMBER OF ITS OPERAND — CLOSED 2026-09-27 (L1 of
  the Pulse sprint).** The arithmetic arm of the emit read only the
  operands' emitted WIDTHS, so a record floored to a word and `{x: 1} *
  {x: 2}` multiplied the two ADDRESSES with zero diagnostics, then trapped
  at run time (exit 134, boot 5bf55b68) — the `T_EqTypeUnprovable` class one
  operator over, found by the refuter that killed the first Pulse design.
  The first form built classified the operand at lower and at emit and
  passed every gate; the artifact refuted it twice before it was pinned:
  `mentl check` accepted both programs (only the executable refused), and
  the wheel's own compile narrated the floor twin of `lo_add` (verify.mn)
  "unproven" over a `t` the judgment had already seen added — the emit
  re-deriving a fact inference held. The demand is a GATE ON THE TYPE CELL
  (`NumericGate`, the gate mechanism's second arm beside A3's row gate):
  judged at the operator when the operand is bound, carried by the cell
  when it is free, checked at the one writer (unify's var binds), copied
  at instantiation, reached through the instance column — so the judgment
  refuses at the operator, at the call that instantiates a generic
  arithmetic at a record, and through a sig'd self-reference's copy;
  `E_ArithOnAggregate` is armed at birth (wheel census 0). At emit nothing
  is decided: a word at its type's repr, a variable a floor twin's word by
  construction (a wide instantiation mints its twin even through a
  reference — measured), and the narration class the first form minted is
  deleted with its ratchet and the post-emit gate
  (`Hβ.emit.arith-on-aggregate-is-pointer-arith`).
- **THE `<~` LINE IS A RING OWNED BY THE RECORD THAT HOLDS THE CYCLE —
  CLOSED 2026-09-27 (L2 of the Pulse sprint).** The line was N module
  globals keyed by the site handle alone, declared at the floor's width
  and shifted N−1 global moves per tick, so three silent wrongs shared
  one root: two twins of one generic recurrence shared one line (the
  Float twin wrote f64 into an i32 slot and refused to assemble), two
  closures minted from one lambda shared one line (`let lp_l =
  lowpass(0.3)` and `let lp_r = lowpass(0.3)` filtered through ONE
  register — the two-channel bug every stereo stage writes), two installs
  of one handler shared the arm's line, and `delay(24_000)` was 24,000
  globals moved per tick (2.5 MB of WAT for a one-line echo). Handler =
  state = closure, read at the site: a cycle's memory belongs to the
  record of the function that contains it (`LineHome`, types.mn — lower
  assigns each site a slot in its frame's record past the captures, the
  state and arms, or the k tail; the record's minter allocates one ring
  per site; a top-level fn's site, its record being the module's
  immutable data record, rides an instance global `$__init_lines` fills,
  one per emitted twin). The ring is `[head][slot × depth]` at the site's
  repr under the active bracket; the tick is a load, a store and a bounded
  increment at any depth. Micros `mn-feedback-twin-width`,
  `-closure-instances`, `-arm-instances`, `-deep-line` each RED on boot
  542ea5a3; the frontier's deep-line leg prints ticks per second at depth
  24,000 (a wall clock is never ratcheted). The remainder-owned line
  (a `<~` after a multi-shot perform) is built by the same rule and has
  no witness: a let-bound multi-shot perform is off the k2 spine and
  floors before any line could tick (L0's named remainder). What the
  ownership exposes and names: a closure or install record shared by two
  threaded branches shares its ring and the race rule reads effects, not
  cycle state (`Hβ.threads.closure-line-shared-across-branches`); a
  top-level fn's line is per INSTANCE, so two branches calling one
  recurrence run two lines with no diagnostic
  (`Hβ.threads.static-line-is-per-instance`). lib/dsp's README and
  clock.mn header, which required an Iterate-class handler and cited
  `E_FeedbackNoContext`, are raised to SYNTAX's inferred-clock rule.
- **THE FIRST PROGRAM THAT IS NOT THE COMPILER FOUND TEN DEFECTS THE BOARD
  COULD NOT — CLOSED 2026-09-28 (L3, Pulse scene 1).**
  `examples/pulse/render/main.mn` renders ten seconds of 48 kHz stereo to a
  WAV through `mentl run`: seventeen stages minted by makers, twenty-seven
  live `<~` lines, `render_frame` declared `!Alloc + !Sample(44100)` and
  measured at zero heap growth across 480,000 frames. Every defect it found
  was silent to the board because the wheel never does the thing (§11
  tripwire 3): it never captures a ground Float, matches on one, passes one
  through an indirect call, or runs `compile` after `run`. Two did not
  ASSEMBLE after a clean `mentl check` — a closure capturing a ground Float
  (the capture read its binder's handle, which a ground binder does not
  have; captures carry the USE handle now) and a match on a Float (the
  scrutinee parked in the word scratch; the root is read at its repr). Two
  were FALSE ABSENCE PROOFS — a Float crossing any indirect call was boxed,
  so `fn step(f, x: Float) with !Alloc = f(x)` allocated under its own
  `!Alloc`, and a handler over a Float op did not assemble (the function
  table carries two faces now: the word face every `fn_ptr` names, for
  callers blind to the type, and the native face half a table later, for
  sites that prove a wide vector; a perform speaks its site's face too,
  since R0j — the declared-signature ABI this sentence first named boxed
  every generic op's wide argument);
  and two instances of one effect collapsed to the first, so a 44.1 kHz
  reader after a 48 kHz one escaped `!Sample(44100)` while the other order
  refused (collision is the complement of provable distinctness). Two were
  claims NEVER DECIDED — a refinement over an `if`/`match` stayed pending
  over eight literals (a join decides as the AND over its tails), and a
  refinement crossing a function-typed argument was DROPPED, so a
  70,900 Hz sweep reached an `Hz` filter and checked clean (a result
  position is judged on the lambda's body; a parameter the callee does not
  carry is honest `V_Pending`). One was a warm image restoring a FOREIGN
  WORLD: `compile` after `run` printed nothing, the compile having restored
  run's image and emitted into run's sink (images are filed under
  `world_key()`). One was the parser (a fn body's `{` had its own copy of
  the brace discrimination, so `fn f() = {x: 1}` read as a block —
  `brace_form` is the one home) and its projection in the formatter (body
  records wrapped in parens; a record never broke, so a fourteen-field rig
  rendered on one 300-column line). And the DSP library was WRONG where it
  had never run: one filter per program for every top-level filter, a DC
  blocker that was a leaky integrator with a DC gain of 200, a high-pass
  reading its own output as the low-pass state, an envelope follower that
  ignored `release`. The filters are makers now, each stage owning its
  ring. The frontier's `pulse-render` leg renders, judges the WAV against a
  Goertzel oracle, and refuses three one-line twins (an allocation beneath
  `render_frame`, a sample out of range, a 44.1 kHz clock);
  `examples/pulse/render/GRADIENT.md` is the log. Named rather than fixed:
  `Hβ.verify.higher-order-refinement` (three faces),
  `Hβ.effects.handler-pins-its-instance`, `Hβ.lang.lambda-param-annotation`,
  `Hβ.dataflow.delay-tap`, `Hβ.diag.effect-mismatch-at-the-call`,
  `Hβ.fmt.literal-spelling-is-intent`, and the env overlay measured on a
  real program (`Hβ.driver.per-module-env-overlay`). Two more surfaced on
  the way to the pin, both caught by a gate rather than by reading. The
  render leg went red after the library was formatted: `mentl fmt` had
  deleted an effect parameter's annotation (and, as a census of every
  `.mn` in the tree then showed, op parameter names and a pinned alias's
  base) while reporting "prose conserved"; fmt now refuses to write a
  render that loses any name or literal of its source
  (`Hβ.fmt.render-deletes-authored-intent`). And the cost ratchet refused a
  +27% self-compile peak, which bisected to one binding group: the occurs
  check walked row PATHS, exponential in a cycle's depth, and keeping a
  table of entered cells took the judgment's high-water from 565 MB at the
  previous pin to 314 MB (`Hβ.infer.occurs-check-walks-row-paths`).
- **THE UNSEEN REST OF A RECORD IS A ROW VARIABLE — CLOSED 2026-09-28
  (R0, preempting L4a).** A helper reading two fields of an unannotated
  record, called with two record shapes, read the wrong slots for every
  shape but one, silently: the second access met the first as two open
  rows and their union was written as the whole row, tagged "assumed",
  with no variable left for a twin to key on. It was found by the
  derivative walk trapping inside the compiler's own twin of a
  two-record fn, not by any fixture, because every row-polymorphic helper
  the board ran read one field or took one shape. Two open rows meet at
  one fresh variable now, only free terminals are ever written, and every
  reader walks the chain through `record_row_full`
  (`Hβ.infer.record-row-vars-are-not-unioned`). Both things it exposed
  CLOSED the same day. A base body whose every reference resolved to a
  twin was emitted anyway, its floors narrated at a developer who never
  calls it (R0′, pin b29e319b): emit runs a second reach over the
  references under their brackets, a decl nothing live names is not
  emitted, and the wheel's field-offset floors went 8 → 0
  (`Hβ.emit.dead-base-emitted-beside-its-twins`). And a handler's arms read
  their config through the declaration's row, one arm set for every
  install (R0b, pin 30a35888): an install is a reference site, its config
  arguments key the arms it runs, and the record stores the twins
  (`Hβ.emit.handler-arms-specialize-per-install`). What R0b exposed CLOSED
  at R0c (pin 0bc8383e8b6ced84). The twin cap meters recursion along each demand's
  lineage instead of a base's twins program-wide, so ten record shapes
  through a two-level chain run where eight did
  (`Hβ.emit.twin-cap-meters-breadth-not-divergence`). A handler's state
  inits lower once, at the declaration, into an init fn of the record, so
  they read the config and a captured config argument arrives
  (`Hβ.lower.handler-state-init-reads-config`,
  `Hβ.lower.install-config-capture-read`). An install keys its arms at its
  effect's instance, config or not, and an arm is called at its op's
  declared face while it runs at its instance, reached through an op-face
  adapter where the two differ — which also closed a pre-existing
  ground-Float handler that did not assemble
  (`Hβ.emit.arm-twin-converts-at-its-face`). What R0c cost — half the
  twin mass byte-identical copies — CLOSED at R0d (pin 2d7845607e804eb4):
  a twin is keyed by what its body reads, the read a demand on the type
  cell beside the numeric gate, so twin functions went 3,033 → 120. The
  merged twins had hidden that every product layout read its widths
  outside the twin, which one slot width answers now, and a record pattern
  resolves at emit by name, which closed the 2026-08-17 parameter-receiver
  silent wrong (`Hβ.emit.twin-key-is-what-the-body-reads`,
  `Hβ.lower.record-pattern-param-receiver`). What R0d named CLOSED at R0e
  (pin dbbfd10784e308c3): a list pattern binds and tests each element at its own
  width and position. It had not assembled over a Float element, and its
  test walker read its sub-patterns from the wrong end on every boot,
  silently, because none of the wheel's list-pattern arms carries a
  refutable sub-pattern (`Hβ.lower.bind-handle-typed-subpattern`). Open
  from this chain: no multi-shot install with a wide answer assembles,
  because the redrive reads the answer as a word
  (`Hβ.continuations.redrive-reads-the-answer-as-a-word`); and a record
  update over a generic base closes its result to the base's known fields
  (`Hβ.infer.record-update-closes-an-open-base`).
- **EVERY FLOOR THE EMIT WRITES IS SAID BEFORE THE FIRST BYTE — CLOSED
  2026-09-28 (R0″, pin 2d18aeddf7fc9b46).** Three classes — an unprovable field offset,
  a compared or shown operand whose shape is still a variable, a reference
  past the twin cap — were decided inside per-fn emission, after the gate
  had read the ledger, so none could refuse: armed, each would have counted
  a refusal with the module already on stdout. The module is planned whole
  and written after (`emit_plan`, `emit_planned`), one gate reads between
  them on every route (`gated_plan`), and the emitted reach settles each
  body under the bracket it is emitted in: `E_FieldOffsetUnprovable` and
  `E_ShapeUnprovable` armed at wheel-zero, `E_InstantiationDepth` born
  armed. Auditing every emission-time report found more than the three:
  `LInvariantFailure` wrote its trap with no word at all (a block local in a
  module-scope `let` compiled clean and trapped), and a static-home belt was
  guarding a live hole — module scope is lowered with no frame, four shapes
  (`Hβ.lower.module-scope-has-no-frame`, closed at R0f below). And `mentl fmt`
  had been rewriting `(run() ~> h).beta` as `run() ~> h.beta` under "names
  conserved": the postfix heads lacked the precedence inverse (fixed), and
  a render that parses to a different tree is still refused by nothing
  (`Hβ.fmt.render-must-parse-to-the-same-tree`).
- **MODULE SCOPE IS A FRAME, AND A MODULE BINDING IS WHAT IT IS — CLOSED
  2026-09-28 (R0f, pin 51f332d71a7baae1).** A module value let's init was lowered
  with no frame, so a block local resolved as a global, a nested fn took a
  static line home it had no record for, and a `<~` in an init named its
  ring global with the emit site's diagnostic label. The init lowers inside
  the frame of `$__init_lets` now, and its static lines have that function
  as their owner. A module `let inc = (x) => x + 1` was judged a value and
  called as a symbol nothing emitted; the parser births it as the `FnStmt`
  it is, recursive and generalized, and fmt writes it as `fn` (an arm-list
  one keeps `let name = { … }`, its parameter being minted). And every
  value binding had been registered as `FnScheme`, so a module value
  holding a closure was called directly by a name that was never a
  function; value bindings carry `ValueScheme`. Each of the five shapes
  checked clean on boot 2d18aedd and either refused or did not assemble;
  each now runs to the value its source computes.
- **A CHAIN IS DIFFERENTIATED BY READING IT — FORWARD MODE LANDED
  2026-09-28 (L4a, pin 0976f1d7da263d74).** `(w - rate * d(loss(w, xs))) ~>
  grad(w)` is a training step (lib/ml/grad.mn): the body evaluates as it
  does without the install, and `d(v)` is ∂v/∂w. Every install is classed
  by ONE roster, read off the effects its handler answers (`type Projection
  = PDispatch | PSchedule(Schedule) | PDerivative`); a derivative install
  builds no record and lowers to `LDerive`, which src/derive.mn expands at
  emit's settle point into the body's JVP beside the forward program — no
  tape, no second copy of the chain. Directly-called functions get JVP
  twins, a `<~` line carries its tangent as a ring of its own, and a lost
  tangent refuses where `d` consumes it (`E_DerivativeUnreachable`, armed),
  never answering zero. The receipts are against oracles the reading
  cannot share a mistake with: scene 1's distortion slope in the drive and
  in the flux against the finite difference of the same function at 18
  points, the adaptive crucible's LMS rule re-derived as `d(e * e)` and
  judged by its own oracle, dy3/da through a `<~` line, forward identity
  over a sweep, and a `!Alloc` training step whose heap does not move. What
  it exposed: a parameter named like an effect op was lowered as that op
  (the compiler's own `jvp_pair`; the callee is resolved once now), and
  the same name-keyed read still resolves a call's argument product and a
  partial's callee (`Hβ.lower.callee-resolved-by-name-in-the-module-env`).
  And one soundness hole, preempting the queue: an ordinary install
  allocates and no row said so, so `!Alloc` accepted every `~>` it wraps
  (`Hβ.effects.install-allocates-unrowed`, CLOSED by R0i, the next
  bullet). Open: closures and handler arms under the reading (L4a′),
  reverse mode by cost (L4b).
- **WHAT A CONSTRUCT BUILDS IS IN THE ROW OF THE FRAME THAT BUILDS IT —
  CLOSED 2026-09-28 (R0i).** `!Alloc` was a false absence proof at the
  most common shapes a program writes: probing every construct that builds
  a record found SIX the row never charged — an install (40 bytes per call,
  stateless or not), a lambda mint (16), a partial application (16), an
  interpolation (48 for `"v{x}"`), a splice show, and both fanouts (56 for
  `(x + 1) >< (x + 2)`) — each compiling clean under `!Alloc` on boot
  0976f1d7 while the heap grew. Each is charged where it is built now, an
  install by its class off the one projection roster (a derivative reading
  builds nothing), and a literal a verb applies in place — the stage of a
  `|>` as well as the recurrence of a `<~` — is lowered in the frame it
  stands in and mints nothing, by the same test at both readers. The wheel
  held thirteen false `with Pure` clauses over interpolation; they are gone.
  Two defects surfaced on the way and closed in the landing: a binder that
  shadowed a name in a nested block, a match arm or a recurrence body wrote
  the shadowed binder's register, so `f(100)` answered 11 for 106 with no
  diagnostic, and a shadow at another width did not assemble — a frame's
  binders are one list resolved innermost-first now, each with a register
  of its own (`Hβ.lower.shadowing-binder-clobbers-its-register`); and `++`,
  interpolation and `xs[i]` call primitives the judgment's order never saw,
  so a refusal under `!Alloc` landed at `str_concat`'s declaration instead
  of the developer's line (`Hβ.infer.sugar-callee-judged-after-its-caller`).
  A third came from the frontier the moment a mint was charged: a
  proposal's candidate is judged under a read-only intern view that must
  never mint, and the judgment names `Memory` and `Alloc` by literal, so a
  program whose link never mentioned them trapped mid-proposal — every
  intern table is born holding the medium's own vocabulary now
  (`Hβ.intern.medium-vocabulary-is-born-with-the-table`).
  What it named next: the census was done by hand, and the gate that makes
  it mechanical — an emitted body that allocates under a row the judgment
  proved `Alloc`-free is an internal contradiction — is R0j, the bullet
  after this one; an install whose record never escapes could live in the
  frame and cost nothing (`Hβ.lower.install-record-in-the-frame`).
- **THE ALLOCATION AUDIT AT THE SETTLE POINT — CLOSED 2026-09-30 (R0j).**
  At emit's settle point every unit the module will emit is walked under
  the bracket it is emitted in, and a construct whose emission builds a
  record in a unit whose row does not say `Alloc` is `E_InternalInvariant`
  at the construct, refused before a byte (`alloc_audit`,
  src/backends/wasm.mn); the emission holds the other direction, every
  allocation a unit's code makes passing through `EmitMemory`
  (`emit_memory_audited`). RED on the wheel at birth — SIXTEEN list-pattern
  rests cut a slice with no row saying so — and zero since the rest charges
  its callee's row and a record's rest `construction_row()`; two false
  `with Pure` clauses fell to the charge. The record-rest fixture then found
  a pre-existing silent wrong: a rest through an unannotated parameter read
  its field at the RECEIVER's slot (3 for 2 over `{a: 1, b: 2, c: 3}`, a
  virgin 0 for 3), because a twin's pair for a row variable was the site's
  whole record where the rest binder's chain starts past the receiver's
  named fields; the pair is the residual past the learned fields now and
  each reader spells `learned ++ residual` from its own start
  (`Hβ.lower.row-terminal-pair-is-the-whole-record`, CLOSED). Then the
  FRONTIER, where the wheel's shape stops being the language's (§11
  tripwire 3): seven micros and seventeen legs refused through the first
  m2, four classes behind them, none the audit wrong about an allocation.
  A generic op's perform boxed its wide argument at the op's word face — a
  perform speaks its SITE'S face now, as a closure call does, the arm
  twinned at the install's instance being that face by construction, and
  the op-face adapters are deleted whole
  (`Hβ.emit.generic-op-box-is-unrowed`, CLOSED). A nested `fn` was minted
  with no row saying so, every lib/dsp maker among them — the block charges
  the mint. `ialloc` was asked for `Alloc` where it is rowed under
  `ImageAlloc` — a unit's row is asked for the site's own effect. And the
  continuation machinery landing in a spine callee's k twin is the OP's
  remainder cost, recorded there and never refused against the callee's
  row — which named the open half: a held resume through a `!Alloc`
  callee ran its remainder inside that callee's frame and nothing charged
  it, a false absence proof on the board as a declared red
  (`Hβ.continuations.spine-callee-row-is-blind-to-the-held-resume`, CLOSED
  2026-10-01 — the resume performs its continuation's world, S2 below). A
  wide value boxed into a list primitive's word slot is narrated
  (`T_WordSlotBox`), the slot being the representation's. What the audit
  does not see — the JVP twins, a library's whole-emit, the generated
  leaves and the runtime family, and `mentl check`, which never plans — and
  its ultimate form, the emission's own allocation counted per unit before
  the gate so the walk deletes, are one named peer
  (`Hβ.emit.allocation-census-is-the-emission-itself`).
- **A CALL'S PRODUCT IS THE JUDGMENT'S, WRITTEN ONCE AT THE CALL — CLOSED
  2026-09-30 (R0g).** The lowering resolved every call a second time, by
  NAME against the module env: the argument product (labels, defaults) and
  a partial's callee were both read off whatever module declaration shared
  the callee's name, blind to the scope the call stands in. Four silent
  shapes on boot 523f1732: the prelude's `fold_handler` arm `f(acc, elem)`
  refused with an arity mismatch inside the library when a program
  declared `fn f(x: Int)`; `fn run(f) = f(7)` beside a top-level `f(a, b =
  100)` spliced the module's default into the callback's call and trapped;
  `g(b = 1, a = 5)` on a let-bound `g` ran as `g(1, 5)` with zero
  diagnostics; `let inc = add(1)` over a let-bound `add` called the
  top-level `add`, or floored where there was none. The judgment writes
  each call's positional product — and a cell per slot a partial leaves
  open — at the call node (`CallProduct`, the spine's `products` column,
  trailed), against the parameters the CALLEE NODE carries, and the
  lowering reads it; a partial over a local carries the callee's value in
  its record; the use site's own name read for a bare constructor or op's
  arity is deleted, the judgment writing that product at the reference.
  What the build exposed: a partial's open tail slot was typed by the
  partial node's arrow, so a wide slot never assembled, and a closure
  call's result face was read off the call node where a partial's body
  needs the callee's return — both closed with it
  (`Hβ.lower.callee-resolved-by-name-in-the-module-env` CLOSED, nine
  fixtures RED-first).
- **THE DERIVATIVE CROSSES A FUNCTION VALUE AND A HANDLER'S ARMS THROUGH
  THE RECORD — LANDED 2026-09-30 (L4a′).** The forward reading (L4a) stopped
  at every call through a value and every perform: the tangent was lost
  there and a `d` of it refused, and a handler's state was invisible to it —
  `d(fold(0.0, (a, x) => a + w * x, xs))` and a total accumulated by a
  stateful handler answered ZERO with no diagnostic on boot 0bc95063
  (mn-derive-fold, mn-derive-state-inside/-outside), the one output the
  reading may never produce. Handler = state = closure, read once more:
  under a reading every record with captures carries a LANE per capture —
  an epoch and an f64, sixteen bytes per capture before its header, so no
  offset the emit ever wrote moves and a module with no reading allocates
  none — a mint under the reading writes its active captures' tangents
  there, an arm writes each state field's beside the field, and a twin
  reads its captures' lanes; a lane's epoch is compared with the reading's,
  so what lived before the extent enters it held fixed (a mint before the
  install answers 0, the same body minted under it 3 —
  mn-derive-closure-captures). Every symbol a call through a value or a
  walking perform can reach carries a DERIVATIVE FACE, the twin keyed at
  every Float parameter, a third table half past the word and native faces,
  demanded for every symbol whose signature is a site's — the
  `call_indirect` over-approximation, named (`Hβ.derive.face-demand-is-by-
  type`) — and a dispatch naming its install calls the arm twin the reading
  demanded there. Measured: eight micros RED-first (6, 30, 60, 70, 40, 90
  and two refusals) and the frontier's `derive-distort` — scene 1's
  distortion PERFORM under its stateful handler, in the drive and in the
  first sample, whose influence on every later one runs only through the
  envelopes the arm keeps, 12 of 12 against the central difference of the
  same chain. The one refusal the scheme keeps static: a mint, an install
  or a state write under the reading that would store a LOST tangent into a
  record refuses where it stands, since the record's later readers could
  not know (`Hβ.derive.closure-twins`, `Hβ.derive.arm-twins` CLOSED; a `<~`
  line a closure record owns is `Hβ.derive.closure-line-tangent`). What it
  cost: every callee that performs or calls through a value is twinned
  wherever an extent calls it, since any record it reaches may hold an
  active tangent.
- **THE GRADIENT OF A PRODUCT SEED IS ONE REVERSE SWEEP, AND THE TWO MODES
  ARE TWO PROJECTIONS OF ONE LINEAR PROGRAM — LANDED 2026-09-30 (L4b).**
  derive.mn's header had promised "the rules are each construct's partials,
  written once — read forward here, read backward by the transpose", and
  the artifact baked the partials into forward tangent code, so nothing
  could read them backward and a product seed refused. The walk writes a
  LINEAR PROGRAM once now — `Lin` the tangent of one value over the primal's
  residuals, `Beside` the statements beside the primal's — and forward
  lowering and the transpose are its two projections: the eleven L4a/L4a′
  micros and the three crucibles emit through the new compiler exactly as
  through the boot but for the mode comment at each install and one local
  per query, every value unchanged. A record or tuple of Floats seeds the
  reading (`~> grad(ws)`), one lane per Float field, the gradient READ BY
  DESTRUCTURING where it is asked and never built; a scalar seed is answered
  forward, a product seed in reverse where its reach is a fixed chain — the
  primal first with each test and scrutinee as a residual, then each query
  transposed back to the seeds, a call into a known function answered by
  its ADJOINT TWIN (`sym$vjp<key>`: the callee recomputed in its own frame,
  adjoints handed back through the `$__da{j}` registers) — and refuses
  naming `Hβ.derive.vector-forward` otherwise. Seven micros RED-first on
  boot 8ee3d09a (28, 32, 48, 28, a `!Alloc` gradient norm at zero heap
  growth over a thousand sweeps, and two refusals) and the frontier's
  `derive-grad` (36 of 36 partials of a rational waveshaper against central
  differences) beside `derive-grad-series` (the same seed over scene 1's
  distortion REFUSES: its series recurse). Found on the way: a choice at a
  twin's exit bound to a local left the twin with no result (a choice at a
  body's exit stands in place); a seed destructured at the extent was read
  whole and lost (a pattern over the seed binds its fields to their lanes);
  the tangent twins a reverse extent demanded while it was read were
  emitted uncalled (the calls fixpoint keeps the faces' twins and what the
  programs name). And the cost ratchet REFUSED the first repin at 980 MB —
  +148 MB for a thousand lines — and the census it forced found the
  compiler, not the landing: the wide-sequence type walk was path-local
  and asked at every binary operator, so each `++` on a list of the
  reading's statements re-walked the LowExpr universe at 1.8 MB; the fact
  is one per nominal type now, the emit byte-identical, the self-compile
  134 MB lighter on the same source (`Hβ.lower.wide-seq-walk-was-path-
  local`; the per-declaration census that found it is the named facet
  `Hβ.lower.per-decl-cost-census`). Named:
  `Hβ.derive.transpose-through-iteration`,
  `Hβ.derive.transpose-through-the-record`, `Hβ.derive.bptt-priced-by-the-row`,
  `Hβ.derive.gradient-as-a-value`.
- **A HANDLER IS EXHAUSTIVE OVER EVERY EFFECT ITS ARMS ANSWER — CLOSED
  2026-09-30 (L5, A6 as measured).** A6 was designed as install identity,
  and four probes on boot 16286d94 refuted the premise before a line was
  written: `((twice()) ~> h) ~> h` refuses at the root because the row is
  EXACT — the inner install absorbs `E` for the whole extent and its arm's
  own perform resolves outer, so the outer arms are unreachable; Koka
  refuses the same program (`Hβ.effects.op-granular-arm-reach` names the
  finer verdict, precision never soundness) — and a recursive same-handler
  install (exit 2) and a closure escaping into a second install of the
  same handler (exit 7) run under dynamic innermost dispatch as SYNTAX
  documents. The hole was one probe over: a PARTIAL handler. `fn f() with
  !State = (get() + inc()) ~> only_inc`, `only_inc` answering `inc` alone,
  compiled CLEAN under the negation and trapped at the root (exit 134) —
  the install subtracted the whole of `State` by name while `get` walked
  past it at runtime, §0's property (2) false at a shape any program
  writes. A handler is exhaustive now — the match-exhaustiveness law at a
  handler, Koka/Effekt parity — `E_HandlerInexhaustive` at registration,
  armed at birth, naming the ops no arm answers; the honest partial forms
  are a forwarding arm (the row carries the forwarding, so `!State` over
  that body refuses as it should) or the ops as their own effect. The
  first census found FIVE partial handlers in the wheel and its runtime,
  each a place `!E` was false: the prelude's `each_handler` (no `result`
  arm — the floor every micro links), infer's read-only `summaries_frozen`
  over a read/write effect, emit's `preinstall_init_scope` and
  `names_not_emitted`, and voice's `Interact`, one effect whose two
  handlers answered disjoint halves, split into `Workspace` and
  `Interact`. What it exposed: the first fix of `summaries_frozen` was a
  forwarding arm and the ROW killed it — the frozen round is installed
  where no ctx encloses it, so the forwarded write reached the root and
  the boot refused the wheel; a forwarding arm claims an enclosing handler,
  and where none exists the split is the form (`ResumeSummariesWrite`).
  Install identity as a mechanism is owed by no measurement; its felt face
  is `Hβ.effects.served-by-projection`, its TIME face band B's.
  (`Hβ.effects.handler-must-be-exhaustive` CLOSED; the identity half of
  `Hβ.effects.arm-world-static-rule` resolved.)
- **THE JUDGED ROW WRITER IS AN INSTALL — CLOSED 2026-09-30 (A7).** LENS
  §2.3 lemma (i)'s premise (every row writer refuses a violating write and
  pushes the gate as stated) was kept by two wrappers a writer had to
  remember to call, and the plan's form for its mechanical half was a board
  bound counting the raw ops' references — a proxy for a proof. The row
  writes are their own effect (`RowWrite`, the three ops out of
  `GraphWrite`), answered raw by `graph_handler` at the root and JUDGED by
  `row_gate` installed innermost at every judgment chain: the check every
  gate demands, then the raw write forwarded outward. Inside a judgment a
  raw row write is unsayable — the perform reaches the judged handler first
  — and the wrappers are deleted. Seen RED: declared and not installed, the
  crown accepted twelve gate leaks (90/102); installed, 102/102. The
  three-walks witness (`adv-mask-two-callers`, two callers of one masked
  HOF, the first negating what the second performs) runs to 10 exactly when
  the quantifier reaches the cell behind the mask as the flatten does.
  What it exposed: the runtime floor's prose is judged in every program's
  link, so a backticked name there must resolve in the floor alone — two
  references (one from L5) narrated on every compile and are prose now.
  Named: `Hβ.effects.row-write-outside-the-judgment` (a perform outside
  every judgment chain would be served raw; none exists, and the medium has
  no module-private declaration to refuse one).
- **THE ACCEPT IS A GRAPH WRITE, AND THE TEXT IS ITS PROJECTION — CLOSED
  2026-09-30 (C4).** Accepting a proposal was `replace_span` alone: the
  medium proposed a value with a proof, the developer accepted, and the
  graph forgot both — the re-derived node read as an authored literal and
  `Why` at the position said "int literal", the one hop that was false
  (§0 property 3, intent lossless, false at the exact gesture that
  creates intent the source cannot hold). The edge is drawn first now:
  `graph_accept_note` enters the accept into a column of the graph
  handler's state — the module path, the extent the rendered text will
  occupy, the text, the proof the proposal carried — and the splice that
  re-derives the module is what makes it readable, because graph_bind
  reads the column at the one writer and binds the node minted at that
  extent with its reason wrapped in `Accepted(text, proof, inner)`
  (`Located` kept outermost, so no span reader unlocates the node). The
  Why engine then walks it as any hop: `Why: accepted \`1\` — proposed:
  inferred from the type's integer inhabitants, at hole:9` over
  `inferred from int literal`. Two routes, one home (`accept_fill`): the
  edit session's `y`, and `mentl accept <path>:<line>:<col>` — the second
  graph operation surfaced beside the first, since `mentl <address>`
  projects a position and `mentl accept <address>` draws an edge there; a
  tie refuses with the computed question (never a guess), a filled
  position refuses, and the exit code is the verdict. The page's Tab
  routes through the same verb: the worker's virtual filesystem took a
  write path (the wheel projects the module back to its file, the reply
  carries what it wrote), and the IDE gate's node twin accepts at the
  hole its socket leg projects — RED on boot 4bc10808 (no verb, exit 2,
  nothing written). What the first probe found: the patch handler
  re-derived through the per-module check walk, whose generation was not
  addressable (the verb re-projected its own position and found the OLD
  hole, typed and proposing, while the file already carried the value) —
  a patch re-derives through the one weave read the session and the
  address share now. Named, not fixed: the column is keyed by position
  because the transport re-parses (`Hβ.synth.accepted-edge-keyed-by-
  position`, dies with E2's resident graph); the edge lives as long as
  the graph — a fresh process derives cold and answers `int literal`
  (`Hβ.felt.accept-outlives-the-process`, E2's on-disk face); the edit
  session reads one action per invocation
  (`Hβ.felt.edit-session-reads-one-action`).
- **PARTIALITY IS A ROW FACT — CLOSED 2026-09-30 (C5).** Integer `/` and
  `%` trap on a zero divisor, and `/` on INT_MIN / -1, and nothing said so:
  a `Pure` row was a false totality proof at every division by a variable,
  and the e-graph's absorb rewrite read its operand's SHAPE, so `(1 / n) *
  0` answered 0 at n = 0 where the program traps (measured on boot
  21f8e691, the C4 pin). A partial primitive's precondition is a CLAIM now
  (`PTotalDiv`), raised at the site and decided by Verify's fragment — a
  constant, a module value bound to one (read at the let's own node), or
  the operand's refined type asked whether it EXCLUDES the fatal point by
  deciding its predicate with `self` bound there (`Positive` excludes 0 and
  -1, `NonZero` 0) — with three outcomes: proven charges nothing, a
  refutation refuses at the site (`1 / 0` is `E_RefinementRejected`), and
  an open claim charges `Trap`, a substrate effect with no operations
  (`effect Trap {}`, the prelude), inferred and projected like `Alloc` and
  provably absent: `fn ratio(t, n) with !Trap = t / n` refuses, `n:
  Positive` accepts. The ledger answers its verdict (`verify` returns the
  decision — one decide, no second beside it). The e-graph reads the same
  fact: every charge is noted on the node that makes it in the move that
  joins the frame (`inf_add_row_at`, `graph_row_note`, trailed), a subtree's
  row is a fold over structure (`row_of_subtree`), and `is_pure` reads it —
  the shape guess and the type-row read are deleted, which closes
  `Hβ.egraph.per-expr-effect-row` as a read rather than a column. Verify's
  `self_h == 0` sentinel is the `SelfBind` ADT. Seven micros RED-first, the
  frontier's `absorb-keeps-trap` a runtime-trap contract; lib/dsp's six
  divisions by a hop or a grid width are PROVEN by one refinement on the
  parameter (`Positive`, cfc.mn — the crucibles' authored caps on `main`
  met `Trap` first, the row telling the truth about a library that had
  never stated its preconditions), and the wheel judged clean with five
  open partiality claims (`mentl query src/main.mn smt` renders each),
  every one guarded on a PATH the narrowing walk computes and never
  writes — the named next face
  (`Hβ.verify.partiality-reads-the-path-narrowing`), beside the index's
  precondition (`Hβ.effects.index-partiality-is-a-row-fact`) and
  non-termination (`Hβ.effects.divergence-is-a-row-fact`). Survivors
  dedupe by canonical root before the question is computed (dormant by
  construction, the feeder peer stands), and `extract_chase`'s cap traps
  where it silently answered. Found on the way: `mentl fmt` wrote a
  keyword binder as a wildcard under "names conserved"
  (`Hβ.fmt.keyword-binder-renders-as-wildcard`).
- **THE QUESTION IS READ OFF THE TRAIL — CLOSED 2026-09-30 (C6).** The
  computed question's source was each survivor's own reads — a callee's
  declared row by name, a literal's denotation — and on a hole whose cell
  was FREE it asked the wrong question: `let x = ??` beside `one()` and
  `word()` answered "differ in VALUE and nothing here bounds the value"
  (boot b1637650) where the two segments had disagreed on the position's
  TYPE first. A candidate's segment carries out the context cells its
  binds moved (`graph_written_since`: the trail's MSetNode / MSetRow
  entries since the checkpoint, below the enumeration's handle frontier,
  read BEFORE the rollback undoes them — each as the meaning the cell then
  held), the proven survivor is sealed with them, and the divergence is the
  first such cell two survivors bound differently, classified by the cell:
  `DivType(a, b, reason)` names it through its own Reason ("the cell that
  moves: return of pick" when the hole shares a class with a parameter and
  the declaration's return), `DivRow` at a row cell; only when no context
  cell moves does the question fall to the term, read as before. Two
  fixtures RED-first (`mn-type-tie`, `mn-cell-tie`), the four standing
  ties unchanged. What the trail cannot carry, named with the closure
  (`Hβ.synth.divergence-from-the-trail`): a declaration's row is a scheme
  VALUE after finalize, so no candidate's charge moves it (rung 3), and a
  segment's own mints collide numerically after rollback ((arena, offset)).
- **THE PROPOSAL BATTERY, AND WHAT ITS FIRST TWENTY-FOUR FIXTURES FOUND —
  2026-09-30 (C7).** Zero proposal fixtures existed as a battery; the
  `test` verb reads a second contract now — `// propose L:C: fill <text>`
  | `ask <arm>` | `none` — and judges it against the Verdict at that hole
  through the address route's own resolution and view, structurally, so a
  contract binds the classification and the voice may move
  (`tests/proposals`, twenty-four fixtures: one per enumerator, one per
  divergence arm, one per proposal landing; the frontier runs the
  battery). Writing them was a felt walk over every enumerator, and the
  walk found four things the six hand-written tie legs could not: a
  fielded constructor was refused against the hole it was built for
  (`Box(??)` judged as `Box` awaiting its field, since a `??` in argument
  position is the partial's marker — a hole the proposer mints is a value
  the next fill supplies now, and `Option(Int)` asks `None` against
  `Some(??)` where it filled `None` alone); every structured candidate
  rendered as `??` (the renderer is the formatter's token projection now:
  `()`, `{x: ??, y: ??}`, `(??, ??)`, `[]`, `(_, _) => ??`,
  `Hβ.felt.candidate-render-is-format` closed); two nullary constructors
  asked a SHAPE question where they are the type's own values
  (`DivVariants`: "True or False", "Circle or Square"); and an authored
  hole nothing proved printed nothing at all (it says so now, with the
  refusals as its reasons). Named: the Linked ring offers the substrate's
  own helpers (`hex_glyphs()` at a String hole —
  `Hβ.synth.linked-ring-offers-substrate-internals`) and a handler arm's
  hole is free at propose time
  (`Hβ.infer.arm-body-cell-is-free-at-propose`).

- **THE SCHEDULE REACHES A CALLEE'S FANOUT BY DEMAND — CLOSED 2026-09-30
  (B4 + C9).** A `><` inside a reusable fn was permanently `Seq`: the lexical
  read stopped at the frame fence, so no helper could fan out under its
  caller's `~> parallel_compose`, and the ??-fan had no fanout to stand in at
  all (`judge_window` was a constant standing in for a width the language
  could not say). A call standing under a spawning install — its own frame's,
  noted by the lowering, or the one inherited from the twin it is emitted in —
  demands the callee as a SCHEDULE TWIN, keyed by the site's instantiation
  with the schedule as a trailing letter, emitted beside the instantiation
  twins by the same plan; a fn declared `!Thread` takes no demand, the
  negation read where it is AUTHORED (a ground body's declared negation
  leaves nothing in the published row, which the first `!Thread` control
  measured by running threaded); a site carries what its own frame installs
  and inherits otherwise; a value that can outlive the install keeps its
  instantiation alone (`Hβ.lower.schedule-through-a-value`); and the race
  rule walks from a spawning caller into its callees with the site's row
  pairs, so `tally(() => bump())` under a stateful counter refuses through
  the polymorphic HOF where boot 6f2ce437 ran it to 11. `fanout(f, xs)` is
  the SEQUENCE fanout — the prelude's `map(f, xs)` by declaration, a fanout
  node at the lowering, `fanout_threaded` / `fanout_persisted` under the
  spawning schedules — and `segment_verify` is written `candidates |>
  fanout(...)`: width a handler decision at the propose site, a
  `~> parallel_compose` over it refused by the race rule (`graph_handler` is
  stateful), 9.2's DEP as a gate. FOUND ON THE WAY: a Thread op inside a
  spawned branch trapped on every boot since B1 — the task record carried
  the spawn ARM's world, which the deep-handler law strips of the schedule
  itself (persist.mn's lesson one effect over); it carries the world of the
  PERFORM now (`Hβ.threads.task-record-carries-the-arm-world`). The
  bootstrap seam killed `fanout` as a primitive: the boot cannot compile a
  wheel that names a primitive it lacks, and the hand-written scheme was a
  copy of `map`'s. And the cost ratchet refused the candidate at 924 MB
  against 873 and shaped the emit: the fixed-input probe (boot and candidate
  over one wheel source) priced the compiler's own growth at ~50 MB, the
  per-step marks over the plan put the last 22 MB in the emitted reach, a
  subtraction probe blamed the site's schedule perform and the WAT killed
  it (0 bytes per ask), and the truth was one probe over — lib/persist's
  four Persist-class sites asked the reach rule, which walked every body of
  the wheel to answer; the emit asks it of one name now (`fanout_reach_of`),
  the reach's mark stands as its own `heap:` line, and the race walk is
  gated on a noted threaded site. Named:
  `Hβ.lower.race-rule-obligation-flows-to-callers`,
  `Hβ.persist.sequence-fanout-replay-barrier`.

- **A HELD RESUME RUNS ITS REMAINDER WHERE IT IS CALLED — CLOSED 2026-10-01
  (S2).** Two defects at one seam, found by measuring the declared-red
  `spine-callee-alloc` rather than trusting its entry. THE RUNTIME: a held
  resume whose remainder performs one of its handler's ops again re-drives the
  handler from the resume's own frame, and the driver dispatched through that
  frame's `$__state` — the install record in the arm, the closure record in a
  lambda — so a resume handed to `plus_one` over `bump() + bump()` answered an
  address where deep semantics give 22, and a stateless handler and a called
  fn trapped (five shapes, boot 477bb667). The driver carries the record it
  drives, read through the install-record ladder every re-driving arm binds
  (`Hβ.lower.redrive-drives-the-frame-record`). THE ROW: a resume charged
  nothing, so a callback that resumes was Pure and its callee's gate judged
  nothing — `fn apply(f) with !Log = f() + 0` accepted `apply(() =>
  resume(1))` while the remainder performed Log inside apply. An arm's
  continuation world is the handler's remainder-world cell now, a held
  resume performs it, a callee gates it through the callback's row, and every
  install judges those gates against its own remainder by A5's check; the
  handler's residual cuts the cell before it publishes. Crown 104/104
  (`leak-resume-remainder` red on the boot), five micros red-first,
  `spine-callee-alloc` out of frontier_expected_red. Named: a resume in a
  called fn charges no world
  (`Hβ.infer.resume-in-a-called-fn-has-no-arm-types`), the remainder judged
  is the whole body (`Hβ.effects.remainder-row-is-flow-insensitive`), and an
  escaping resume carries the cell free
  (`Hβ.continuations.escaped-resume-carries-its-world-free`). The instance pin
  that was queued beside it as a soundness hole is not one — the bridge serves
  what the row says and nothing escapes the negation above it — and its
  design question is banked (`Hβ.effects.handler-pins-its-instance`).

- **THE GRADIENT READS ADDRESSES — CLOSED 2026-10-01 (D3).** The felt walk
  on a two-module program found the field, the session and the accept all
  module-blind: `mentl main.mn:0` listed an imported helper's declarations
  under main's coordinates (the tiers were filtered by line range, and every
  module numbers its lines from 1), `mentl edit main` opened on the prelude's
  `unwrap_or` (the proximity compared bare spans), and accepting its
  suggestion wrote `  with Pure` above main.mn's first line (the suggestion
  carried only text, inserted above a line number in the target file). A
  position is a handle of the caret's module, proximity is read between two
  handles, and the field and the argmax read one order — score, then source
  position — so the session's focus is the field's head. The suggestion
  carries its annotation, and the accept splices the formatter's own head
  render over the declaration's head in its own module's file, guarded by the
  formatter's conservation census. The proposer's rank reads the same
  proximity (hole, declaration, uses — all handles). Named: the accepted
  clause draws no edge yet (`Hβ.felt.accepted-clause-carries-its-proof`),
  nearness inside a module is three steps where the call graph would be the
  gradient (`Hβ.cursor.proximity-reads-the-call-graph`), and the CLI session's
  caret never moves (`Hβ.felt.session-caret-never-moves`).

- **A REFINEMENT IS A FACT A VALUE CARRIES — CLOSED 2026-10-01 (P0).**
  Found on D4's felt walk before D4 began: refinements rode the
  unification class, so every join and every operator that met a refined
  value laundered its refinement onto the result. Six `with !Trap`
  programs checked clean on boot 13e8484a and trapped at run — `x - 1`
  over `x: Positive` typed Positive, `if c { n } else { 0 }` typed
  Positive, open let, argument and postcondition claims read as facts —
  and the same merging refused a correct one: `n: Positive` on one operand
  of `t / n` demanded Positive of `t` (`mn-refine-sibling-operand`). A cell holds
  a SHAPE now; a refinement is read by one walk along the value's edges
  (constants, binders, join tails, a callee's declared return, lengths,
  sums), each reader asking its own question — a row fact stands on
  constants, lengths and preconditions, a claim on owed postconditions too.
  A parameter's refinement is a precondition whose GUARD holds the row it
  protects (`Trap` of `100 / n` under `n: Positive`): a caller whose claim
  is open pays it, a caller whose claim held on its own parameters carries
  it to them, an unannotated parameter handed to a refined one learns the
  precondition, and a self-recursive or cyclic caller pays at its exit or
  the cycle's. A `let` annotation is a claim its value owes; every claim is
  noted on its value's node, so a hole's proposals and its `?? : Positive`
  read what was claimed of it. Destructuring is a value-flow edge (a part
  reads its whole's construction at its position, or its whole's contract
  projected), and the `!Flow` seed's label moved off the class with the
  rest: a value is as classified as everything it was built from — on the
  tree before that read five derived leaks of a classified value checked
  clean, which the boot had refused by the very merging P0 removes. Crown
  green at the pin over 116 crucibles (eleven `leak-refine-*` red on the
  boot, the pipe's among them — the next bullet), `mn-refine-join-launder`
  registered after two months banked red, the wheel's own debt up from 25
  to 34 open obligations, every one a fact the class had hidden. Named: the
  Add fold assumes unbounded Int
  (`Hβ.verify.interval-fragment-assumes-unbounded-int`), a row fact never
  stands on a postcondition even a proven one
  (`Hβ.verify.row-facts-trust-proven-postconditions`), a product return and
  a cycle's returns prove no contract
  (`Hβ.verify.proven-return-over-products-and-cycles`), a generic call drops
  the contract its parametricity preserves
  (`Hβ.verify.contracts-through-parametric-calls`), and a row write that
  reaches its own cell is skipped whole, names and all
  (`Hβ.effects.row-self-bind-skip-drops-names`). The merged function value
  it left open — `if c { inv2 } else { inv }` called at 0 under `!Trap`
  kept the first branch's contract and trapped — closed at H4 (below).
- **A FUNCTION'S CONTRACT TRAVELS WITH THE FUNCTION, AND A PIPE STAGE IS AN
  APPLICATION — CLOSED 2026-10-01 (P0·H, the same pin).** P0's first march
  refused at proof-exactness, 21 pass / 5 red: `run(() => 30000.0)` into
  `fn run(f) = alpha(f())` checked clean with debt where the boot refused
  it, and a lambda handed an `Hz` its callee provides read as debt — both
  directions of a callback's contract had ridden the unification class
  into the function type. They are read along edges now. A lambda's
  parameter learns its precondition as a declared one does and the
  lambda's type publishes it; a function-typed parameter learns from how
  its body applies it — what every application hands each position and what
  a refined position demands of its result — and publishes both, so a
  caller's crossing judges the function it hands in. Measuring that found a hole on both trees: a `|>` stage raised no
  claim at all, so `0 |> inv` under `!Trap` checked clean and divided by
  zero and `30000.0 |> alpha` reached an `Hz` parameter — at the form this
  project calls never optional. The pipe is an application now, claiming of
  the piped value what the stage's parameter demands
  (`Hβ.verify.pipe-stage-raises-no-claim`). A `<~` cycle's lambda learns
  nothing, since no application raises a claim for its prior.
- **A FUNCTION VALUE IS EVERY FUNCTION IT CAN BE, AND APPLYING IT OWES WHAT
  EACH ONE DEMANDS, WHEREVER IT FLOWED — CLOSED 2026-10-02 (H4).** P0 read a
  value's refinement along its edges and left function values on their
  types, which unification merged and kept one side of. Measured on boot
  13e8484a and pin e23392f6, each of these checked clean under `!Trap` and
  divided by zero: a join of two functions applied (`if c { inv2 } else {
  inv }`), a list of them, a function at a part of a parameter (`fn first(fs,
  k) = fs[0](k)` over `[inv]`, a record field alike), one a generic callee
  moves by its signature alone (`fold(0, (acc, f) => acc + f(k + 1),
  [inv])`), a callback that is the caller's own parameter, a caller's
  callback whose results `map` hands to `fold`, and a generic call's result
  (`id(if c { inv2 } else { inv })(k + 1)`); and the merge refused a correct
  program the other way — `drive`'s provision of `Hz` to its callback read as
  `outer`'s `g` demanding `Hz` (higher-order face 5). A function value is now
  every function it can be (`fn_leaves`: a join every tail, a reference its
  binder's value, a part, a field or an element its whole's construction, a
  generic call's result the arguments its signature returns of the result's
  variable), and an application — call or pipe — owes each leaf's
  preconditions, conjoined, and the rows they guard (`call_owes`). What a
  body PROVIDES a function is an edge to the values it hands (`PProvides`),
  never the function's demand, so `apply5(inv)` over `fn apply5(f) = f(5)`
  discharges by `0 < 5` where the pin had refused it. A function at a part of
  a parameter teaches the parameter's contract at that path; a generic
  callee's DECLARED SIGNATURE carries each argument's values at a quantified
  variable to every callback the variable reaches — parametricity, the
  callee's body never read (the channel), a nominal type's arguments
  included: `Option(a)`'s values are its construction's fields; and what the
  body cannot see is handed on, never assumed — a function returned, handed
  to another learning callee or to one out of sight, or placed where the
  contract is a variable learns that it is also handed values nothing here
  can name. The first repin (213ec3ec) was stopped and the boot restored
  when `wrap(inv)(0)` over `fn wrap(g) = { let _ = g(5); g }` divided by
  zero: a provision read as everything the function would ever be handed.
  Found on the way: a completed `|>` stage carried the stage's handle, so
  `(2 |> wrap(3)) == [3, 2]` compared two addresses and `(2.0 |> scale(3.0))
  > 5.0` did not assemble
  (`Hβ.lower.pipe-stage-completed-call-carries-the-stage-handle`, closed).
  Named, each sound and imprecise: `Hβ.verify.relational-provision`,
  `Hβ.verify.channel-depth-one`, `Hβ.verify.channel-through-callback-results`,
  `Hβ.verify.generic-callee-scheme-read-by-name`,
  `Hβ.verify.type-arg-part-reads-every-field`,
  `Hβ.verify.crossing-guard-carries-to-the-provision`; and a language gap the
  walk passed, `Hβ.infer.tuple-index-through-an-unannotated-parameter`. The
  higher-order peer (`Hβ.verify.higher-order-refinement`) keeps face 1's
  remainder and κ, the one form that would answer every face at once.
- **A STRUCTURE IS CLAIMED PART BY PART WHERE IT IS BUILT, AS IT IS ASSUMED
  PART BY PART WHERE IT IS TAKEN APART — CLOSED 2026-10-02 (S4).** P0 made a
  destructured part read its whole's contract projected to the position, so
  a callee ASSUMES `r.den` is `Positive` under `r: {den: Positive}`; the
  caller's claim of that contract crossed only the structure's function
  parts and answered held, so the `Trap` the callee's division guarded was
  neither paid nor carried. Measured on boots e23392f6 and 1a68ecc0, each
  checked clean under `!Trap` and divided by zero: `den_inv({den: 0})`, a
  tuple's position, a list's element taken by a pattern, a nested record, a
  record a `let` built, an unannotated parameter placed in a record, and a
  record handed straight through an unannotated parameter; and `let xs:
  [Positive] = [0]` compiled clean. A structure's claim is the meet of its
  parts' (`cross_parts`): a part built in sight is claimed at every node it
  can be, an unannotated parameter placed there learning the contract, and a
  part of a whole built out of sight is read off the whole's leaves at the
  part — held where every leaf states it, owed otherwise; a guard is paid on
  what the claim stood on, the parts' leaves (`claim_leaves`). A nominal
  contract's parts are its constructors' fields grounded at its arguments
  (`variant_named_specs_at`, moved from lower to types, one home the
  judgment and the emit read), so `opt_inv(Some(5))` under
  `Option(Positive)` proves its division and `res_inv(Err("bad"))` under
  `Result(Positive, String)` owes nothing of `Positive`, where the boot
  refused both; an index read is a part read (`100 / xs[0]` under `xs:
  [Positive]`); a constructor is recognized by the env (`constructor_named`).
  The wheel's open obligations 34 → 37, each a part the class had hidden:
  `TypeVariants`' tag, `Graph`'s span index, `rank_positions`' handles.
  Found on the way, in the emit: a record literal written as a field of
  another parked its base pointer in the one scratch local every record
  literal shared, so the outer answered the INNER's pointer — `let r =
  {inner: {den: 5}}` bound `r` to `{den: 5}` and `r.inner.den` read 0 with
  no diagnostic on every boot through 1a68ecc0; a record parks in its own
  scratch now, as a variant and a tuple had since July
  (`Hβ.emit.nested-record-literal-answers-the-inner-pointer`, closed). Open:
  a join one of whose tails is not a construction reads every tail off the
  whole (`Hβ.verify.provenance-through-destructure`), a type argument's
  function parts still read every field
  (`Hβ.verify.type-arg-part-reads-every-field`) — and, found after the
  march, a handler's state read as its INIT, which S5 closed (the next
  bullet).
- **A HANDLER'S STATE IS EVERY VALUE WRITTEN INTO IT — CLOSED 2026-10-02
  (S5).** A state name was bound to its init's cell, so every walk that
  reads a binder answered the init alone and an arm's `resume … with` write
  was read by nothing. Measured on pin 53f7404b, each checked clean and
  failed at run: `100 / d` over `with d = 5` under `!Trap` while an arm
  wrote `d - 5`, `inv(d)` over `n: Positive`, and a function written into
  state applied at 0 under the init's contract (exit 134 each); a
  classified value written into a public-initialized state spliced clean
  where a classified init refused. A state field binds where its init
  stands and its binder fact names every writer — the init and each update
  of the field — noted before any arm is judged (`StateFact`); the value
  walk, the `!Flow` label, a function value's leaves and a part each read
  the join of the writers, each as the expression it is. A write may read
  its own state, so the walks run under a handler chain whose links are the
  states entered (`StateWalk`, `walking_state_of`): a state re-entered
  reads as unknown — exact for the label, sound for refinements — and the
  part walk applies its reader where its path ends, inside every state it
  entered (`path_read`). The race rule reads the facts, and its re-walk of
  the arms deletes. An update naming no field of its handler is refused
  (`E_MissingVariable`): `resume(0) with m = n + 1` beside `with n = 0`
  compiled clean and `n` stayed 0. The wheel's open obligations hold at 37.
  Open: a write that reads its state proves nothing of it, and the verdict
  over a writer judged after the claim follows arm order, sound both ways
  (`Hβ.verify.state-reads-its-invariant`). FOUND ON THE WAY, and closed by
  S6 (the next bullet): a function in a structure a call returns was read off
  a class that kept one branch's contract.
- **A FUNCTION'S CONTRACT IS NEVER LOST AT A POSITION — CLOSED 2026-10-02
  (S6).** `pick(false).f(0)` over `fn pick(c) = if c { {f: succ} } else {
  {f: inv} }` checked clean under `!Trap` and divided by zero, and a census of
  twenty-three probes on pin 85218488 found three mechanisms behind it. An
  INFERRED position published its class, which kept the first branch's
  contract — a function inside a returned record, tuple, `Option` or list,
  through a relay, a module let, a lambda and a parameter: every function
  position of a declaration's or a lambda's return now publishes the meet of
  every function the position can hold (H4's whole-function meet,
  generalized). A CHARGE WITH NO FRAME WAS DROPPED: the authored return's
  claim ran after its declaration's frame closed, so `fn mk() -> (Int) -> Int
  = inv` paid its guard into nothing and `mk()(0)` trapped — the claim runs
  inside the frame — and a module value let's init, judged in no frame, was
  invisible to the root gate: `let x = op()` compiled and trapped at init
  where `fn main() = op()` refused, and now refuses at the let. A STATED
  position was UNIFIED, NEVER CLAIMED: a nominal record's construction, a
  `resume` into an op's declared return, and a function's result parts where
  it crosses into a parameter each claim now, and `R{den: 0}` under `den:
  Positive` is refuted. The wheel's obligations hold at 37 and its emit did
  not move. Open: a performer never stands on an op's refined return
  (`Hβ.verify.op-return-is-a-contract`), `main`'s negations do not reach the
  inits (`Hβ.effects.executable-row-includes-inits`), the proof gate never
  judges a candidate's own row, so `Box(??)` is proposed under `!Alloc`
  (`Hβ.synth.candidate-row-is-unjudged`), and fmt renders a nominal record as
  its variant (`Hβ.fmt.nominal-record-renders-its-variant`).
- **THE GRADIENT PROPOSES WHAT THE PROGRAM OWES — CLOSED 2026-10-02 (D4).**
  At `fn inv(n) = 100 / n`, whose one unproven fact is that `n` may be zero,
  the Teach facet answered `with !Alloc` (boot 6f62b7c4): the gradient
  proposed effect clauses alone, ranked by the count of capability labels
  each unlocked — `with Pure` "unlocked" memoization, compile-time evaluation
  and automatic parallelization, three things the medium never does — and the
  refinement SYNTAX's partiality section names as a division's proof had no
  constructor. The gradient proposes what discharges an open obligation now,
  each candidate PROVEN in a checkpoint bracket by the judgment's own
  decisions: a precondition on a parameter of the declaration the claim
  leans on (matched by its guard cell, never its name), from the refinement
  aliases the module reaches, judged against the declaration's obligations
  and every application of it the judgment drew; a return contract where a
  caller's open claim rests on the declaration's result; the row clause
  last, as a lock. The answer is ONE value — add one annotation, ask between
  two that prove the same and mean different things (`n: NonZero` or `n:
  Positive` with no call to choose), say the predicate a parameter needs
  when no alias in reach states it, or nothing — ranked by what each proves:
  debt discharged, then calls refused and left open, then absences, so
  `NonZero` wins where a call passes -3. `mentl accept
  <file>:<line>:<col>` at a declaration writes it through the formatter's
  head render, over a written `n: Int` too (the census counts `Int` present
  as the base the alias declares). Applications are a graph edge drawn where
  they are judged (`call_owes`) — the first form scanned the graph for call
  nodes and never saw a pipe stage — obligations at a node are
  module-qualified (`main.mn:3` counted helper.mn:3's claim), and the
  capabilities nothing performs, the Teach effect's three dead ops and
  Synth's dead `verify_candidate` are deleted. Eleven teach fixtures run
  through `mentl test tests/teach`. Open: the leverage counts direct
  applications only (`Hβ.teach.leverage-reads-direct-applications`), an
  accepted annotation draws no edge (`Hβ.felt.accepted-clause-carries-its-proof`),
  and a representation pin waits on an overflow-aware interval fragment
  (`Hβ.verify.interval-fragment-assumes-unbounded-int`).
- **`WHERE` RENDERS WHAT SYNTAX PROMISES — CLOSED 2026-10-02 (D5).** The
  verb printed `>< [Thread]` where SYNTAX promises `>< [Thread ×4]`, the
  same glyph for a `<|` and a sequence fanout, an empty line for every
  function with no install or site, `not found` for every parameter and
  local, and every generic type as a debug handle (boot b400dc74). A site
  carries the shape its author wrote with the branch edges its boundary
  holds, the schedule its frame installs read through the one projection
  roster, and the callers that demand it threaded, read by the emit's own
  rule (`fanout_reach_ask`, the one home of the ask) over the decls column;
  the whole-program reach closure and the two whole-graph scans only this
  verb used are deleted. A function answers its head with its inferred row
  and the width of each parameter and of its return; a local is found the
  way the judgment drew it, each reference in the asked module along its
  link to the cell it reads; a free type variable renders as the name a
  developer would write (bound inside a checkpoint, rolled back), its width
  `per instantiation`. Open: the voice's gradient field stays unfilled
  until an LSP code action carries an edit
  (`Hβ.voice.situation-gradient-is-never-filled`), `type of`, `why` and
  `flow of` miss locals (`Hβ.query.name-keyed-verbs-miss-locals`), and the
  other surfaces still print handles
  (`Hβ.voice.free-variables-render-as-handles`).
- **THE SESSION KEEPS ITS GRAPH — CLOSED 2026-10-02 (E2).** The page's
  session re-instantiated the wheel and zero-filled its memory on every
  call, so each projection was a whole derivation and "sub-50 ms" had no
  timer; the CLI's socket session re-derived the WHOLE weave on any edit; a
  resident verb that refused answered nothing at exit 0; and the accept's
  edge died with the cold process that drew it, so the next read said "Why:
  int literal" (boot 713745c6). `mentl session` with no listener serves on
  stdin — one line per verb, the answer written whole before the next line
  is read — and the page's worker blocks inside that read on a
  shared-memory channel, so ONE instance answers for the session's life
  (`ide/session-client.js`, one client for the page and the node twin). A
  moved tree re-judges its CONE through the warm compile's own machinery,
  each ledger forgetting only the modules the cone re-judges
  (`verify_forget`, which closed a warm compile reporting an edited claim
  twice); a refusal answers MISS so the cold route says it whole; the
  session answers the accept, so its edge survives into every later read.
  What keeping a graph exposed: every by-name read answered for EVERY
  generation the session held — after one edit the proposer offered
  `main()` at a hole `main` calls. A module node's registration now
  supersedes its path's last one and drops what that generation noted in
  the name-keyed columns, so the columns, the scanners and the module cells
  answer for the current generation (27 verbs over four edits, resident
  against cold: 0 of 108 differ). Measured on the pinned boot's stdin
  session: a read 14 ms keeping 420 KB, a hole read 25 ms (2.2 MB), an edit
  97–101 ms (8.6–10.1 MB, the cone alone), the accept 105 ms; the node
  twin's reads 5.2–9.4 ms resident against 216 ms cold; the page's, open
  130 ms and a read 5.6 ms. Open: an edit still pays for the program
  rather than its cone (`Hβ.session.edit-pays-for-the-program`), and a
  refusal crosses the wire only as MISS
  (`Hβ.session.answer-is-out-err-and-exit`); each answer's kept scratch
  closed at Arena·P2 (`Hβ.session.answer-scratch-outlives-the-answer`).
- **THE CARET READS THE GRAPH AT THE NODE — CLOSED 2026-10-02 (E4).** On
  boot 8b071ba3 the caret answered a fanout by its first token, a generic
  variable by the node around it and a call's `(` by its callee; it wrote no
  Topology, said nothing of which install serves a perform, read Effects off
  the TYPE (a let binding a lambda said its body's effect for a mint that
  allocates) and counted the obligations sharing a line. A node spans the
  tokens it consumed and the caret is the character under it
  (`caret_span`); a parent edge drawn at the one writer answers every upward
  question (`decl_path_to`, `ancestry`), and four whole-graph scans and the
  downward path search are deleted. Each aspect projects where it has
  something true to say: Query; Topology, the verb path down the
  declaration; Handler, the install that serves a perform or why none on the
  path does; Effects, what evaluating the node performs, and for a function
  value what minting it costs and what calling it performs; Ownership;
  Verify, each obligation inside the node named; Teach; and Why, the node's
  own chain and then its type's, a parameter's read walking to its
  signature through ONE Reason phrase where two stood (the caret's and the
  emit's WAT comment, beside the chain renderer `show_reason`). `where`
  answers the address; a minted parameter never renders. What it measured
  and hands to the representation work (§11's order): 18,681 cells the
  parser mints and the judgment never binds (`mentl query <entry> ghosts`)
  — names, parameters, predicates, annotations — which are also why `refs
  of` misses a type annotation or a pattern constructor, and why a claim
  sits at the application rather than at the value it claims. The parent
  write's per-registration scratch costs 23.7 MB the arena reclaims; the
  ceiling (1,014,000 → 1,050,000) records that debt.
- **AN EXTENT'S ALLOCATIONS DIE AT ITS EXIT EXCEPT WHAT ITS PUBLICATION
  REACHES — THE ARENA, LANDED 2026-10-03.** At least four of the eight
  landings before E4 raised the self-compile's peak ceiling, 98% of the
  judgment's heap was scratch, and nothing reclaimed any of it: the bump
  image never freed. `(body) ~> arena` (lib/arena.mn) is an install the
  lowering replaces (`LArena`) — no record, no world push — and its exit
  reclaims everything the body allocated except the body's value and what
  the body stored into memory older than the arena. Those MOVE, by type: a
  list slot's direct `list_set`, a handler's state commit and a `<~` tick
  each write a journal entry where the store happens, with the leaf its
  value moves through (the fold's fifth leaf, `$evac_<sig>` /
  `$scan_<sig>`), and the exit copies what the publication reaches, slides
  the copies down to the mark and zeroes what it touched. A value whose
  type its store could not see — a function, a continuation, a store
  through `list_set` reached as a value — has no leaf, and the exit keeps
  the whole region rather than move it: correct for any program, reclaiming
  nothing. The judgment's AGE CLAIM decides which stores need a leaf at all
  — a buffer the scope allocated cannot be older, a parameter is its
  callers' question (each function publishes the parameters it stores into,
  transported at every direct call), a handler's state its installs' — so
  only those bodies are twinned by the shape they move. The judgment's
  binding groups each run in one. Measured on the boot over the wheel,
  three runs identical to the byte in their heap trace: 4,487 exits, 0
  kept, 206,870 KB reclaimed, 49,914 KB moved; the judgment's high-water
  288 MB against the prior boot's 511 MB; the self-compile 863,636–874,384
  KB against 1,061,396–1,065,228; the ceiling 1,050,000 → 884,000, E4's
  debt paid with 126 MB to spare, and the pin's own march measured both
  legs under it (869,872 and 875,644 KB). THE COLUMNS-FIRST PRECONDITION IS
  SUPERSEDED: a reset was unsound while a published value could reach
  older memory by a pointer write no bracket saw
  (`Hβ.graph.column-pointees-are-words`); the journal sees every such
  write with its type, so the reset is sound with the value graph as it
  is. The dormant strategy that claimed the name — `emit_memory_arena`,
  installed by nothing, its `$arena_ptr` moved by nothing and persisted in
  every image — is deleted. Found on the way, silent and RED on the prior
  boot: a function's parameters read as references in the judgment's call
  graph (a false cycle of seventeen through the list substrate), and a
  block's statements read last first. Two facets the dig confessed: `prose
  NEEDLE`, and `variants` of an effect. Open: the extents beyond the
  judgment (closed the same day, the next bullet), a closure's move
  (`Hβ.arena.closure-evac-face`), regions per instance in a spawning module
  (`Hβ.arena.per-instance-regions`), region-typed mutation, the `addr` word
  channel, three imprecisions of the age claim, and nested fns that do not
  hoist (`Hβ.infer.nested-fn-siblings-do-not-hoist`, closed two bullets
  on).
- **EVERY EXTENT RUNS IN AN ARENA AND NOTHING ELSE RECLAIMS — CLOSED
  2026-10-03 (Arena·P2).** Past the judgment the heap climbed 288 → 741 MB
  with no exit, and every answer the resident session gave kept what it
  minted. Each statement's lowering and the lowering's pre-passes, each
  demand walk of the emitted reach, each emitted function, twin, wrapper
  and leaf, each session answer and mcp message, each battery fixture and
  each speculation (the row clause bracket, the precondition and return
  proofs, the synth fan's segment) runs in one, publishing what its extent
  is for: a lowering's registries, an emitted unit's text, an answer's next
  (tree, ranges, manifest) and the edges it drew into older memory, each
  journaled where it was stored. `heap_reset` is deleted from `Alloc`, so a
  rewind that drops a region something older still points into is
  unsayable, and the raw brackets that leaned on a convention — the per-fn
  emission's, the fold leaves', the session's — are arenas. Over the
  wheel's source, the previous boot against the candidate it compiles: the
  heap when the module is written 741.5 → 438.0 MB, peak 870,088 → 575,228
  KB, 19,772 exits and none kept; the ceiling 884,000 → 594,000. A session
  answer keeps what the session learned: a read 344,536 B → 24, a hole
  read 950,304 → 120, an edit 8,044,080 → 119,600, the accept 9,031,664 →
  119,664, the answers byte-identical. Found on the way: an exit that moved
  nothing out of a region larger than the memory had grown before it
  opened slid zero bytes from past the memory's end, which wasm
  bounds-checks — the battery's first fixture trapped once each ran in an
  arena; the slide runs only when something moved, pinned first because a
  compiler's runtime is written by its parent. Open: a closure's move
  (`Hβ.arena.closure-evac-face`), regions per instance
  (`Hβ.arena.per-instance-regions`), and a word with an address's
  provenance stored raw (`Hβ.arena.cast-addr-crosses-the-journal`).
- **A BLOCK'S RUN OF `fn` DECLARATIONS IS ONE LETREC SCOPE — CLOSED
  2026-10-03 (#126).** SYNTAX promised that a block's nested fns hoist so
  they may reference each other, and the judgment refused `odd` inside its
  sibling `even` with `E_MissingVariable`. A block's statements are read in
  runs (`stmt_runs`): consecutive `fn` declarations join one, any other
  statement stands alone, since a later fn may capture what it computes.
  Three readers take the runs through that one rule — the free-name walk
  binds every member's name for every member's body, the judgment
  pre-registers the run and walks its binding groups callee-first as the
  module's (`judge_fn_run`), and the lowering binds every member's register
  before it mints any — and the emit mints a body's adjacent closure
  bindings in two phases, every record allocated and bound before any is
  filled (`emit_minted_bindings`), which absorbs the self-capture special
  case. Found on the way, each RED on the prior boot: a nested fn's symbol
  `{outer}_{name}` made a name shadowed across runs, one helper name in two
  branches, and a sibling spelled like the path one symbol, which the emit
  refused as its own collision — the symbol is the declaration's path joined
  by `.` now (`ls_fn_symbol`); and the exhaustiveness check read an
  as-pattern as covering nothing, three readers each walking an arm's top
  pattern — one projection now (`pat_tops`), `E_PatternInexhaustive` armed
  at zero. The module's free-name walk ran outside every arena, its scratch
  outliving it: in one, over the wheel's source, the judgment's heap 288.6
  → 228.3 MB, peak 581,804 → 519,548 KB, the ceiling 594,000 → 529,000.
  Open: each reader materializes the runs
  (`Hβ.parser.block-runs-read-by-each-reader`, riding with positions as
  cells).
- **AN ADDRESS IS A TYPE OF ITS OWN, AND THE LIBRARY SPEAKS IT — CLOSED
  2026-10-03 (#129, two pins).** An arena's exit moves a value by its type,
  and every address was typed Int: one held where the exit looks was copied
  as a number and the cell it named reclaimed under it — five probes silent
  (the arena's value 109 for 14, a slot written raw 1 for 42, a record's
  field 1 for 6, bits `mem_copy` carried 1 for 42, a list's element 7 for
  12). THE FIRST PIN made `Addr` a type (`TAddr`): a word in every machine
  respect and not a number — arithmetic on it refuses, it orders by
  magnitude (the one `WordOrder` both compares read), it shows as the
  unsigned number it names — and its move is opaque, so an address of the
  region where the exit looks keeps the region; `Memory` gained `addr_at`,
  `addr_diff`, `load_addr`, `store_addr` (journaled with no leaf),
  `null_addr` and the two puns. THE SECOND PIN, compiled by the first: the
  library speaks it — `alloc`, `heap_mark` and `Cast`'s `addr` answer an
  address, every raw load and store takes one, the list runtime's node
  links are addresses and its element words cross by the puns — and
  arithmetic on an address is one refusal per site, judged on both operands
  before they meet. Of the five probes, two keep the region now and two are
  refused as written (an address stored where a word goes, one among
  numbers); the copy answered 1 for 42 through this pin's compiler — the
  first pin had declared the bits `mem_copy` copies the program's own claim,
  and the probe refuted the boundary. A raw copy is OPAQUE now: bits carry
  no type, so a copy that writes memory older than an open arena keeps that
  arena's region and the exit reads no copied byte; the form first built
  instead read every copied word at four byte offsets for something that
  looked like an address of the region, a conservative collector's scan the
  arena's own design had refused, and it is deleted. A store that says what
  it stores keeps an arena reclaiming: a wide list slot copies its scalar as
  the number it is (`scalar_copy`), where its raw copy kept the region (exit
  1 for 42 on that form). Found on the
  way: an install frame joined the instances of an effect its handler does
  not answer (two `Cast`s beside an unrelated handler refused at
  `main:0:0`), the JSON escaper wrote its count into the buffer it had
  outgrown (`"a"` serialized as a NUL) and passed control bytes raw, a sum
  ordered a nullary variant's sentinel against an address, and three floor
  comments narrated unresolved references on every battery fixture. What
  stays the program's own claim is a NUMBER made from an address — a pun, a
  distance — since a number names nothing an exit could read. Open: pure
  word arithmetic — bitwise operations, address offsets, the puns — is
  declared in `Memory`, so a function doing only arithmetic cannot be
  `Pure` (`Hβ.memory.word-arithmetic-is-memory`, the next landing).
- **A SUSPENDED ARENA KEEPS ITS REGION, AND EACH RESUMPTION IS AN ARENA OF
  ITS OWN — CLOSED 2026-10-03 (C×A).** An op performed inside an arena and
  answered outside it suspends what the arena encloses, and the exit ran on
  the way out anyway, reclaiming the arm's continuation and the perform's
  arguments: on boot 10cd1956 six shapes trapped at 134 and two answered
  wrong — an abandoning arm read a reclaimed argument, a list-valued arena
  came back empty. The exit reads the live fact now: a yield unwinding
  through it SUSPENDS the arena (the region kept and joined to the extent
  around it, `ArSuspended` counted) and wraps the continuation, and every
  resumption opens a fresh arena around everything the original enclosed —
  a callee's rest as much as the body's own — before any of it runs. The
  arena tee is a capture point of the frame it stands in, so the rest of
  that frame resumes at the arena's value. Under an arm resuming three
  times the heap grows 96 bytes against 19,240 with no arena. The floor the
  suspension exposed REPORTS: a held or multi-shot perform where no
  continuation can be captured yet is `E_ContinuationUncapturable` at the
  perform, armed at birth and said over the emitted reach — the boot
  compiled it clean and trapped. Found, and next: an arm that observes its
  answer (`a ++ b` over its resumptions) refuses `E_ShapeUnprovable`, since
  an install keys its arms at its effect's instance and never at its answer
  (`Hβ.continuations.redrive-reads-the-answer-as-a-word`, its second face);
  and capture at every position stays
  `Hβ.lower.offspine-perform-is-the-frame-not-in-the-image`.
- **AN ARM'S VALUE IS THE INSTALL'S VALUE — CLOSED 2026-10-03 (AN-1).** A
  handler's type carried its effect's instance and never its answer, so no
  install met what the arms answered: on boot cf8a6d50 an arm answering a
  String under an Int body compiled and ran, an arm observing its answer
  over two resumptions refused `E_ShapeUnprovable` because the BASE arm was
  emitted, and a multi-shot handler answering a Float did not assemble, the
  driver reading its answer as a word. The type is `Handler(instance,
  answer)` now — the answer the cell every arm's value is judged into,
  minted once at pre-registration and read by the registration as its row
  cells are, quantified with the instance, met at every install by the
  body's answer — so an install keys its arms at its answer as at its
  instance (the face rule's answer clause and `arm_face_roots` deleted),
  and a wide value crosses the continuation face in a REGISTER, never a
  cell: the composer, the arena re-entry and the driver call through one
  word-arity face blind to the types, a Float resumed or answered crosses
  in a per-instance lane beside the word slot (the machine ABI's split
  register classes read into wasm; nothing boxed, no row moved — the same
  two-resumption program at Int and at Float grows the heap by the same
  bytes), and a multi-shot op's arguments cross in the yield's record at
  their widths, where a Float argument had refused to assemble. The parity
  half is Koka's and Effekt's typed handlers; past them, arms twinned per
  install at instance and answer, and the zero-allocation face. What the
  law exposed, closed with it: every value walk read a tee as nothing it
  could read, so `100 / ((…) ~> h)` was debt whatever `h` answered and an
  arm answering a classified value spliced clean — a tee's value is the
  body's tails and each arm's tails now (a `resume` tail hands the
  remainder's answer through), read by the refinement, the flow label and
  the function-value walks alike; `proc_exit(Int) -> !`, a never-returning
  op answering a bare variable, so `fail_exit` answers any install. And the
  felt half, measured after the gates were green: the install's refusal
  said `Int vs List(Byte)` and nothing of the arm — the mismatch reporter's
  own signature took the unify's Reason and dropped it — so the diagnostic
  carries its Reason now (`ETypeMismatch(Ty, Ty, Reason, Span)`), the
  install's is the arm whose value is its own, and the refusal reads
  `Int vs List(Byte) — ~> pipe → at 15:13-15:27: inferred from the arm bail
  of handler h`, the caret's Why at the tee reaching the arm; `mentl where`
  says what a handler answers beside what it absorbs (`handler zero absorbs
  Ask, answers Int`; a variable, under the name a developer writes, when
  every arm resumes) and what each install answers.

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
bash tools/state.sh            # THE BOARD, ground FIRST: git → verify → march → frontier → proof-exactness → crown → effect-identity → instrument → threads → ide, one scoreboard; --quick = verify only
mentl verify [path]            # THE BOARD, in the medium: the standing bounds on its own source, read off ONE judged graph (src/board.mn carries each bound WITH its justification); a breach REFUSES, an unread or unclean weave refuses rather than measuring less
bash tools/verify.sh           # the floor the verb has not absorbed: micros through the exec seam, the sha chain, the world outside the graph — STAMPED green (unchanged tree answers in ms; FORCE_VERIFY=1 re-runs)
bash tools/march-gate.sh --micros   # rungs + battery through boot's wheel-emitted m2 (reads the shared .build/m2cache)
bash tools/march.sh            # THE RATCHET: boot→m2→m3, ASSERTS m2 == m3; on m2 ≠ m3 runs m4 ITSELF and rules TRANSITION (re-pin from m3) vs BROKEN
bash tools/frontier-gate.sh    # scheduled matrix + ?? authoring workflows (--compiler fresh for the current wheel)
mentl test tests/proposals     # THE PROPOSAL BATTERY (C7): each fixture's first line is its contract — `// propose L:C: fill <text>` | `ask <arm>` | `none` — judged against the Verdict at that hole, never the rendered line (the frontier runs it)
mentl test tests/teach         # THE TEACH BATTERY (D4): each fixture's first line is its contract — `// teach L: add <text>` | `ask <text>` | `need` | `none` — judged against the gradient's answer at the declaration on line L (the frontier runs it)
bash tools/proof-exactness-gate.sh  # hole refuses · debt surfaces · suspension runs
bash tools/ide-gate.sh         # the resident session: the node twin over ide/wheel-worker.js, then headless Chrome over `mentl space` (leg 2 skips loudly without chrome)
bash tools/doc-truth.sh        # the docs' checkable claims vs the artifact: PROVENANCE sha == boot sha, ledger head pin, named commands exist (runs inside verify — prose gets a mechanical floor)
mentl space                    # mentl edit in the browser (localhost:7378/ide/) — SERVED BY THE WHEEL (src/main.mn space_run; tools/runner owns the tcplisten seam)
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
The arena is not perf work — it is an extent's lifetime being a fact: what
the extent publishes outlives it, and nothing else does.
Name-is-handle is not perf work — it is a name being an edge. Speed is the
side effect in all three, and treating it as the goal is how a wrong change
gets justified.

**THE DEFINITION OF DONE — one statement per §0 property, each a phase's
terminal gate:** (1) *proof beats review* — the crown sound under polymorphism,
Verify on a decidable fragment with honest V_Pending, its search the medium's
own (an outside solver a proposer whose certificate the kernel checks), every
armed class refusing. (2) *the negative is provable* — flow refused where an
`Untrusted` value reaches a `Trusted` sink, implicit flows included, both
regimes first-class.
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
branches read it live — the same problem the SCHEMES face wears one layer
down.** CORRECTED 2026-09-15: this sentence used to end "which is rung 3's
live cells", and liveness is NOT the lever — `Live(handle)` shipped, every
reader was made total over it, and the movers count did not move (470 → 470,
infer.mn:1054). "Judge ONCE" means exactly what it says at both altitudes:
one judgment of the context, not a live variant of a frozen one. In the
compiler that is deleting the trial pass; in the fan it is the shared trail
segment. The two faces are the same because both are *one judgment read many
times*, never *a second judgment reconciled with the first*.

**THE STANDING CURSOR (Morgan 2026-08-26 — the Space spine; supersedes the
2026-08-11/12 selectors, whose corrected DEP chain it absorbs).** The
production target until Morgan stands it down: the medium complete and
all-powerful in WASM form, used in full through `mentl space` — live caret
authoring AND proof faces (flow refusals, Why chains) on ONE page, for a
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
  (ii) **DELETE THE TRIAL PASS — and this entry used to say "rung 3 WHOLE
  (`Hβ.infer.schemes-are-edges`, movers → 0), the next landing". THAT IS
  MEASURED FALSE and the measurement is in the wheel's own source**
  (`src/infer.mn:1054`, 2026-09-01): *"both publishes became `Live(handle)`
  and every reader was made total over the posture, and the count did not
  move — 470 before, 470 after, the same four flips … The divergence is
  BETWEEN GENERATIONS: a trial cell and a final cell are different nodes in
  different parses, and no amount of liveness inside one pass can make two of
  them agree. So the count cannot reach zero while both passes exist, and the
  retirement condition below is not a gate the walk can pass — the pass is
  what has to go."* `Live(h)` is live at infer.mn:1011, :2048, :2620 (13
  sites) and did not even remove the COPY: `instantiate`'s
  `Live(h) => instantiate(generalize(h))` still runs `chase_deep` +
  `subst_ty`, its own comment reading *"the clone rides the mapped spine as
  before."* Liveness was tried, measured, and moved neither number.
  **The real target — and the paragraph that stood here was REFUTED BY THE
  ARTIFACT on 2026-09-15, in four reads.** It said: *"the final consumes three
  things from the trial — `rows`, `layers`, `summ` — and only `rows` requires
  judging … So the trial is a whole-program pre-registration standing where
  per-SCC fixpoint iteration belongs … Design what replaces `rows` — forward
  references within and across SCCs — then cut."* **`rows` carries no forward
  references.** It is `(decl_name, mint_count)` pairs, and the wheel says so at
  its one writer (`stmt_measure_one`, infer.mn:2075): `let before =
  graph_next()` · `infer_stmt(node)` · `(stmt_decl_name(node), graph_next() -
  before)`. **The trial runs a complete whole-program inference and survives
  only as a per-statement count of graph nodes.** Its two consumers read
  DISJOINT halves and neither wants the judgment: `round_prints` matches
  `(name, _)` (infer.mn:1109) and `rows_total`/`rows_bases` match `(_, c)`
  (infer.mn:2206, :2214) — and the name half is `stmt_decl_name`, a free AST
  fact. The trial's own comment states the purpose: *"the final's plan
  prefix-sums it into the deterministic handle bases."*

  **SO THE TRIAL IS A HANDLE-COUNTING ORACLE, and the question it answers is
  the one to attack: why must the numbering be planned in ADVANCE?** Because
  `infer_stmt_list_planned` pre-assigns each stmt a dense range `[base, base +
  count)` with bases as prefix sums in SOURCE order, so handle numbers are
  invariant to walk order — the byte-equality gate the parallel fan (9.2) must
  pass. That is a *flattening* of `(arena_id, offset)` into one dense integer
  space, and the flattening is the sole reason the counts must be known first.
  §10.1 KEYSTONE 2 already names the unflattened form
  (`Hβ.native.deterministic-handle-partition`): with the arena identified by
  the stmt's source index and the offset local to it, stmt *i*'s fifth mint is
  `(i, 5)` whatever any other stmt does and whatever order they are judged in
  — **deterministic by construction, needing no advance count at all.**

  **THE CONVERGENCE, and it is why this is hardest-first rather than one
  chore:** the counting pass (`Hβ.infer.judge-once-per-scc`), the per-decl
  arena (4.3 / `Hβ.perf.per-decl-arena`), and the deterministic partition
  (9.2 + 10.1's keystone) are ONE representation change. A handle that is
  `(arena, offset)` makes the arena real, makes the partition deterministic
  without planning, and deletes the counting pass — three named peers, one
  cut. The slack machinery this entry once listed as part of that cut —
  `mint_overflow_quota = 64`, `graph_mint_plan`/`graph_mint_seal` — is
  ALREADY GONE (2026-09-19), and the reason corrects the entry rather than
  merely dating it: once the ??-fan stopped copying the graph, `mint_limit`
  was zero at all eleven `graph_handler` installs, so the banded partition
  was a FALSE BRANCH that every single mint paid for, not machinery a
  prediction needed. The measured *"324 over-measure stmts, every delta 1 or
  2"* residue was the tell all along, because a count that is *almost* right
  is a PREDICTION of the final's minting, not a measurement of it. What
  `(arena, offset)` still owns is the counting pass and the deterministic
  partition. Handle-uniformity survives, and the FORM of that survival is
  corrected here (2026-09-19) because the sentence that stood in this slot
  wrote it in C: *"a packed `(arena << K) | offset` is still one word."*
  **`<<` IS NOT A TOKEN** — SYNTAX's enumeration has no shift, `<` is TLt and
  `|` is variant-separation, so that expression does not lex, and the wheel
  contains zero `<<` in 60,500 lines. It is also the wrong SHAPE, which is
  the part worth catching: a packed bitfield is position-as-identity, drift 8
  at the representation layer, and §5.U's own law says the surface never
  carries a representation decision. **A handle IS a two-field product
  `{arena, offset}`**; whether it occupies one word is `repr`'s business, and
  the artifact beside it already writes the decode without a bit op —
  `spine_band(h) = h / spine_slots`, `spine_slot(h) = h % spine_slots`
  (graph.mn). So handle-uniformity is a REPR PIN on a product, `repr_of`'s
  own arm, and §5.U's memcpy-serializability is untouched for the reason it
  always was: one word, pinned, never hand-packed.

  **PROBES (a) AND (c) RAN THE SAME DAY AND THE ANSWER CORRECTS BOTH PRIOR
  CLAIMS — THE TRIAL HAS TWO PRODUCTS, NOT ONE.** `env_handler` is installed
  OUTSIDE both passes (the trial's chain ends at `verify_ledger`,
  infer.mn:1081; the final's at `resume_summaries_ctx`, infer.mn:2147), so ONE
  env spans both generations and the trial's entries survive, shadowed. The
  question was whether the shadow is ever READ. It is, and it is load-bearing:
  - `pre_register_fn_sig` has **exactly one caller** — `pre_register_stmt`
    (infer.mn:843), the TRIAL's arm. The final's `pre_register_stmt_final`
    (infer.mn:2664) differs from the trial's in exactly that arm: on `FnStmt`
    it does `smap_add(seen, name, 1)` and nothing else. **The final never
    pre-registers a function signature.**
  - Every piece of cycle machinery — `scc_groups` (called once, :1069),
    `trial_judge_group`, `group_mono_views`, `group_completion_fold`,
    `group_final_publish` — is called ONLY from the trial. **The final has no
    cycle discipline.**
  - `layers` is dependency DEPTH and its own comment states cycles share one:
    *"A cycle contributes no edge from an on-stack callee: the SCC's members
    take depths from their acyclic callees and judge together as one binding
    group."* So callee-first order eliminates ACYCLIC forward references, and
    intra-CYCLE ones have nowhere to resolve but the trial's entries.

  **SO: the trial's second product is the FORWARD-REFERENCE TABLE, carried by
  ambient handler state rather than by an edge.** That is why both earlier
  readings were half right. §11 and RESIDUE said *"the second judgment exists
  solely to supply provisional schemes for forward references"* — right about
  the FUNCTION, wrong about the CARRIER (it named `rows`). The correction
  above said *"solely a handle-counting oracle, nothing of its judgment
  survives"* — right about `rows`, wrong about *solely*. The truth is the
  union: **counts passed by value, signatures passed by shadow.** A dependency
  invisible in every signature is exactly what a Carried-Truth audit is for,
  and it is why two readings of the same code missed it.

  **PROBE (b) ALSO RAN: `classify_fixpoint` IS purely syntactic** — the whole
  classifier region (infer.mn:9264–9560) contains ZERO `env_lookup`,
  `graph_*`, `lookup_ty` or `chase_deep` calls; `summary_of` resolves against
  the classifier's own smap through `summaries_frozen`. `summ` needs no judged
  graph, as its comment claimed. All three probes are answered.

  **AND TOGETHER THEY INVERT THE FIX. The two passes, diffed:** the TRIAL
  pre-registers fn sigs, runs the SCC cycle discipline, walks unplanned, and
  installs FRESH analysis ledgers that are DISCARDED. The FINAL does none of
  the pre-registration, none of the cycle discipline, walks LAYER-ordered with
  PLANNED handle bases, adds `comment_refs_check(stmts, pstart, parse_end)`,
  and ships its ledgers. So **the trial is the COMPLETE judge and the final is
  an incomplete one whose only structural addition is planned handle
  numbering.** The second pass exists to redo the judgment with
  order-independent handle identity — nothing else.

  **THEREFORE THE SECOND PASS IS A CONSEQUENCE OF THE FLATTENED HANDLE, and
  unflattening it deletes the FINAL, not the trial.** With `(arena, offset)`
  there is no numbering to plan, so there is nothing to redo: keep the trial —
  which already judges completely — move `comment_refs_check` onto it, and drop
  the fresh-ledger bracket so its obligations ship. ONE change, and three
  compensations die with it: the counting (`rows`), the movers instrument
  (which measures a divergence between two passes that should not both exist),
  and the fresh-ledger bracket itself — whose own comment says it exists
  because *"without them the trial's undischarged debt accrued into the SHARED
  verify ledger and the final judgment reported doubled V_Pending"*, i.e. it is
  a compensation for running twice. The two-parse seam goes the same way; its
  own comment already predicted this (*"when rung 3 deletes the second pass
  this seam simply loses a caller"*).

  This SUPERSEDES the two-step decomposition written here hours earlier
  ("1. make the final a WHOLE judge … 2. handle = (arena, offset)"). Step 1
  was building the trial a second time inside the final, and its named hazard
  — that a quantified skeleton at an intra-cycle forward use instantiates a
  fresh copy, the disconnected-vars class `group_mono_views` exists to prevent
  — was the tell that the work was already done one pass over. Delete the
  duplicate; do not complete it.

  **THE CUT WAS BUILT AND THE MARCH REFUSED IT (2026-09-15).** The single pass
  was constructed whole and `mentl check` passed; the march then measured
  **8.09s / 954MB against 12.52s / 2,338MB — −59% peak RSS, −35% wall** — and
  refused: `census 13 > 0`, then `BROKEN: m3 ≠ m4 (m4 exit=134)`. The 13 are
  one class, named by the medium: *"a row gate for 'X' is still unresolved at
  the pass tail"*, every X a row-polymorphic HOF (`filter_list`/`filter_loop`,
  `map_list`/`map_loop`, `min_by_key`, `env_resolve_where`, …).
  `assert_row_gates_drained()` already drains at the tail, so these are
  UNRESOLVABLE rather than un-drained: `group_mono_views` keeps ROW handles
  quantified and freshening per use, so nothing binds the gate's handle.
  **The second pass therefore had a load-bearing role beyond planned
  numbering — it judged with every scheme ALREADY PUBLISHED**, which is what
  discharged those gates. That is the fourth correction to this arc in one
  day, again from the artifact. The open question is exact: *how does a
  declared-row gate on a row-polymorphic HOF discharge inside one pass?* —
  and loosening it is not a guess to make, since a declared row enforced
  against a free row var is a false absence proof
  (`Hβ.infer.forward-hof-row-underpublish`'s own class). Source reverted;
  `RESIDUE.md` carries the full record. **A DEFECT THAT IS LIVE TODAY fell
  out of it: the trial runs under `~> diag_quiet`, so those 13
  `E_InternalInvariant` reports are SUPPRESSED on every compile right now —
  a gate gone quiet, §11 tripwire 4's own class, found only because deleting
  the second pass removed the muting.**

  **THE PRIZE WAS MEASURED FIRST, and it never had been.** The pass boundary
  reports itself (`passes:` on the ScopeAll channel — `pstart` was already the
  trial's handle frontier, so only the byte mark beside it was missing). From
  a clean march's m3 leg: **the second pass is 1,338,717,968 bytes and 465,664
  handles against the trial's 668,132,712 and 248,740 — 67% of the judgment's
  2.01GB high-water, 1.87× more handles than the pass it re-does, at 2.00× the
  bytes.** Deleting it takes the judgment from ~2.0GB to ~0.67GB and unblocks
  the ceilings 4.3 is pinned under. Beside it: image-classified bytes are 35MB
  of 2,007MB, so **98% of the judgment's heap is scratch** — 4.3's arena
  thesis with a number for the first time. Netting out one parse per pass, the
  FINAL's judgment alone mints ~217k handles more than the TRIAL's; the
  hypothesis (NOT acted on) is that `group_mono_views` makes cycle members
  SHARE cells in the trial while the final, having neither pre-registration nor
  cycle discipline, instantiates a FRESH copy per intra-cycle forward use — the
  disconnected-vars class this entry named as a *future* hazard, possibly
  already being paid. A probe decides it.

  **LANDED 2026-09-17 — THE SECOND PASS IS GONE, m3 == m4, census 0.** The
  judgment is `infer_program_once`; the m3 leg measures **10.31s / 941MB**
  against the two-pass wheel's 15.0s / 2,334MB, WAT 409,812 → 402,974
  lines, and the trial/final vocabulary, the movers instrument, the planned
  sweep, the block fan and the fingerprint render are deleted (the medium's
  own `mentl query src/main.mn unreachable` names dead fns now — the facet
  was built because the census that found them was a grep). The refused
  cut's exact question — *how does a declared-row gate on a row-polymorphic
  HOF discharge in one pass?* — resolved without loosening: a gate defers
  while ANY free var remains and resolves when the only frees left are the
  SIGNATURE'S OWN (`sig_frees`), because a row var the signature quantifies
  is the HOF's polymorphism, not an unresolved chain. The m4 trap's root was
  the parser: `free_vars_stmt` answered `[]` for every `HandlerDeclStmt`, so
  arm references never reached the callee-first DAG. `RESIDUE.md`'s
  `Hβ.infer.judge-once-per-scc` carries the whole record; `(arena, offset)`
  did not have to land for the pass to go and stays 9.2/10.1's keystone.

  **AND THE SUBSTRATE IS ALREADY `(arena, offset)` — but the naive cut is
  REFUTED BY ARITHMETIC, measured before a line was written.** A handle
  already decomposes: `spine_band(h) = h / spine_slots`, `spine_slot(h) = h %
  spine_slots`, `spine_slots = 16384` (graph.mn:96–100), pages opening on
  demand — and the page structure was built FOR this, its own comment reading
  *"max 2,305 mints per decl on the wheel, p99 331 — 7× headroom for the
  per-decl banding this page structure carries next"*. So per-decl banding is
  just `band = decl index`. BUT `spine_open_loop` (graph.mn:129) allocates
  TWELVE columns per page, each `make_list(16384)`, eagerly — so one band per
  decl is 3,385 pages ≈ 665M slots ≈ **2.66GB of spine alone**, against a
  measured 2.4GB whole-compile peak. It roughly doubles the image. Two
  prerequisites, both deletions: **(1) size the band from the measured
  distribution** — p99 is 331, not 16384; a 512-slot band lands ~83MB with
  overflow bands for the ~1% tail, and total memory is unchanged in the dense
  case because it is (pages × slots) either way, only each band's unused tail
  being waste. **(2) lazy columns** — twelve dense columns for a page whose
  sparse columns readers already guard (graph.mn:103) is the same
  over-allocation one layer down, independent of this arc. The 16384 figure
  was sized so ONE page holds the worst decl; that is right for a DENSE space
  and wrong for a per-decl one, where the cost is paid 3,385 times rather than
  ~40. The env-carries-cells form
  (Binding = BStatic | BCell), the quantifier as a caller-run projection and
  instantiation as the correspondence-edge mint remain the banked shape for
  the SCHEME layer, but they are no longer justified by the movers claim;
  (iii) the enumeration-reader
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
  `name`, `init`, `body`), so it is live.
  **AND "NOT A SILENT WRONG" WAS THE WORD THAT WAS WRONG, corrected
  2026-09-15 by the artifact.** That sentence ended "`mentl check` still
  passes, so it is invisible where the sentence said", which read the
  invisibility as a scoping detail. It was the defect. The floor was
  WRITTEN into every module and never SAID to anyone: the compile exited
  0, no diagnostic named it, and the program trapped at the instruction
  that admits it — so it is silent in the only sense that matters, and a
  trap nobody was told about is not a refusal. The emit site's own comment
  claimed `PLAN §0` ("the medium makes the wrong move unsayable") while
  delivering its inverse at the one boundary that named the promise.
  The single-pass cut's m4 leg died inside `emitfns_index_build`, whose
  ENTIRE else-branch is the `name` floor, at a bare `wasm trap:
  unreachable` with no diagnostic anywhere in the run — which is how a
  silent floor is always found, by a later generation stepping on it.
  The class reported from 2026-09-15 at the receiver carrying the selector
  and the receiver's live type (`Hβ.emit.field-offset-floor-is-never-
  reported`). The wheel's four sites went on 2026-09-28 — record rows became
  union-find citizens (R0) and the emit stopped writing base bodies no live
  reference reaches (R0′) — and the class ARMED the same day as
  `E_FieldOffsetUnprovable`, once the plan settled every emitted body before
  the gate read the ledger (`Hβ.emit.emit-time-class-cannot-refuse`, R0″).
  No client-facing page ships
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
- **Arc F · Proof faces on the page, repriced.** Flow refusals as sink
  preconditions over the influence walk (Phase 7 as re-scoped 2026-10-02 —
  no row element, the label lattice deleted) + Why-chain/refusal badges
  riding the transport. Struck as ALREADY LANDED: stride carrier (pin 7db29195),
  monomorphization face, uniform twinning with the f64-state guard,
  annotated-[Float] breadth end to end.
- **Arc G · THE SEVERANCE MAP — the page that makes the thesis watchable.**
  The module/decl tree banded by capability; select a subtree and it states
  the MINIMAL SUFFICIENT capability set with the cut line where the `~>`
  install goes. It reads what this landing already sharpened — severance at
  the module node with per-function deltas (`module_severance`,
  src/pipeline.mn) — plus the handler install chain and `mentl query <f>
  performs`. No new substrate; it is a projection of something already proven,
  which is `!Outside` stated as a product decision.
  **WHY THIS ONE, argued from a survey of the field rather than from taste**
  (2026-09-21). It is the only fact in software visualization that is BINARY,
  VERIFIABLE and CONSEQUENTIAL: everything else renders a quantity (complexity,
  coupling, hotness) or a possibility (this path MAY be tainted), and
  impossibility is the only shape that converts into a decision — *sandbox it /
  ship it / let the agent run unattended*. It is legible in one glance to
  someone who has never heard of an effect system: green band cannot, red band
  can. And the demo is thirty seconds — a module banded green with `!Network`
  proven, one networking call added, **the band turns red and the compile
  refuses with the Reason naming the call.** That is §0 rendered as an EVENT
  instead of a claim, which is the exact thing whose absence killed Eve (its
  founder's own post-mortem: *"there's no real great way to quantify the
  benefits of a language before it's been fully realized"*). The Severance Map
  is that quantification, available before the language is finished.
  **THE THREE-COLOUR LAW, non-negotiable.** The verdict is only as sound as
  the crown under polymorphism, and `Hβ.effects.sound-neg-under-poly`'s modal
  world-index is OPEN (§4③, §6.3). Shipping a two-colour proof UI over a
  partially-proven mechanism is precisely the "prose calls a permanent cost
  deliberate" failure `CLAUDE.md` names. So the map renders **provably absent /
  present / NOT YET PROVABLE**, the third band is visible and COUNTED, and that
  count is a board bound ratcheting to zero as band A lands. A two-colour map
  is the lie; the three-colour map is the instrument.
  **THE FALSIFIABLE TEST, stated so it can fail:** if a module ever renders
  green while performing the effect, the crown is unsound and the map is worse
  than nothing. That is the right property for it to have — a visualization
  that can be wrong in a way that matters is one that is saying something.
  **THE DELIVERY SHAPE IS NOT A DESTINATION.** The field's empirical record is
  brutal and specific: 62% of the complete SOFTVIS/VISSOFT corpus (387 papers,
  181 analysed) has no evaluation or only anecdotal evidence, median 13
  participants, 3% industrial; average tool lifespan **3.7 years**; CodeSee
  shut down, Sourcetrail archived — and Sourcetrail's archive note names the
  real killer, *"growing difficulties keeping up with evolving dependencies for
  multiple programming languages and build systems"*, which is a cost Mentl
  does not have because the compiler IS the index. The survivors are gutters,
  hovers and exit codes: the Dafny gutter, Flowistry's fade, CodeQL's path. So
  the map ships as three faces of one fact — **the PAGE sells it, the GUTTER
  keeps it alive, the EXIT CODE makes it matter**: (i) the page in `space`;
  (ii) an always-on ambient-world gutter at the caret, stealing Aquascope's
  hollow-vs-filled glyph (hollow `E` = this expression REQUIRES it, filled =
  the ambient world grants it, and a hollow glyph with no filled counterpart IS
  the refusal, drawn before the call is finished); (iii) the NEGATIVE-SPACE
  DIFF in CI — a PR whose right column is the absence delta (*lost `!Alloc` at
  audio_stage*, *gained Network reachability in parser/*). That third one is
  monotone the right way, where every security tool today diffs FINDINGS and
  therefore gets quieter as its analysis gets worse.
  **TWO ARCHITECTURAL STEALS, both from proof UIs rather than from
  visualization tools.** From **Lean's InfoView/ProofWidgets**: widgets do not
  parse the prover's output, they hold an RPC handle into the elaborator's live
  state, and graphical manipulations translate BACK into source steps. That is
  `one graph, two operations` at the UI layer — the widget PROJECTS, the
  gesture DRAWS AN EDGE — and `space` should be held to that contract and
  nothing weaker. From **Pernosco**: click a value → backward explanation with
  trivial hops AUTO-ELIDED; the Why chain needs that on day one, and §11
  already names the noise (`Unified(R, R)` duplicating subtrees).
  **THE ONE NEGATIVE RESULT TO INTERNALISE**, because it is aimed straight at
  this arc: Darklang's projectional editor was rated by its own users *"between
  'Ok I guess' and 'probably the worst part of Darklang'"* and removed, and
  JetBrains says the same from the vendor side — MPS's usability cost is
  mitigated only by EMULATING parser-based editing. **The projection must never
  take the keyboard away.** Mentl is structurally safe here (layout is
  projection, the parser has one precedence table, text is the input) and is
  one design decision away from that grave.
  Peers: `Hβ.viz.severance-map`, `Hβ.viz.ambient-world-gutter`,
  `Hβ.viz.negative-space-diff`, `Hβ.viz.why-walk-elides-trivial-hops`.

**THE ORDER FROM E4 (Morgan's questions, 2026-10-02) — foundations before
surfaces.** Anything that depends on a lifetime is built twice if it is built
before lifetimes exist, so the next three landings are representation, and
E6, B2–B4 and Pulse scenes 2–4 follow them.
(1) **THE ARENA — LANDED 2026-10-03** (the §7 bullet after E4's). An
extent's publication outlives it and nothing else does: the exit moves the
body's value and every value the body stored into older memory — each such
store journaled where it happens, with the type the store knows — and
resets the line behind the copies, so an exit costs what crossed. The row
says where a barrier is owed (the age claim, read along the target's
edges), so a store into the scope's own buffers costs nothing. Placed at the
judgment's binding groups: high-water 511 → 288 MB, the self-compile 1,065
→ 874 MB, the ceiling 1,050,000 → 884,000, the debt E4 recorded paid.
Then placed at every extent beyond the judgment the same day (Arena·P2):
each declaration's lowering, each emitted unit, each session answer, each
speculation — the heap when the module is written 741 → 438 MB, the ceiling
884,000 → 594,000 — with the raw rewind deleted, so nothing else reclaims.
`{arena, offset}` handles and lazily opened columns are no longer the
reset's precondition — the journal sees every pointer write into older
memory — and stay 9.2's deterministic partition. **Lowering-as-columns**
was not designed in this landing, and the arena is why it need not be: it
is now only the question of where a declaration's facts live
(`Hβ.lower.lowering-is-a-column`), separate from how long its scratch does.
(2) **POSITIONS ARE CELLS.** Binders, patterns, annotations and predicates
become the cells inference binds: the ghost count (18,681 on the wheel at
E4, `mentl query <entry> ghosts`) to zero under a ratchet, `refs of` a type
or a pattern constructor answered, a claim located at the value it claims.
(3) **VERIFY'S OWN SOLVER** (8.3 as re-scoped).

**CADENCE LAW (paid for twice):** one landing = build the WHOLE arc → verify
once → board once → repin once. A march sweep per micro-edit spends the
session on ceremony; a gate that was skipped is UNKNOWN, never green.

**Preemption exception:** the soundness spine stands ABOVE the Space spine —
§0's negative-is-provable failing at a shape a real program writes.
`Hβ.infer.declared-row-vacuous-against-a-free-body-row` was the first such
item and CLOSED 2026-09-27 (the gate carried by the cell);
`Hβ.effects.root-gate-credits-an-install-that-had-not-opened` CLOSED the
same day (the executable root gate reads the row and nothing else); next is
the 6.3 modal sweep rule-by-rule as loop-sized residue, their verdicts
reported by state.sh, never this block. Nothing else jumps the queue
without a MEASURED demo-blocking fault. "It will surely land" is never a
selection reason — the completion-gradient is a named drift; the
iteration's report opens by naming the priority served.

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

**THE ANONYMITY TIER WAS RE-FOUNDED 2026-09-20 and the correction is the
transferable half.** It convicted every `LambdaExpr`, and a third of what it
counted was PATTERN DISPATCH — which the medium has no second way to write,
so the count could not reach zero and a ratchet on an unreachable floor
measures nothing. With the arm-list literal (SYNTAX §«Function literals») the
same sites carry no param list at all, so counting them as lambdas would have
been the census reporting a form the source does not contain — the
Carried-Truth violation at the doc layer, inside the instrument that exists to
catch it. `lambda_is_written_as_a_mint` excludes the shape; what the tier
convicts now is a REFERENCE WRITTEN AS A MINT, which is a number that can
reach zero. A census shape is a CLAIM about what should not exist, and a shape
that convicts the only available spelling is claiming the language is wrong.

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
  borrow-read of a moved name refuses as `E_UseAfterMove`. Gate seen RED
  twice, once per half: `tests/frontier/mn-use-after-move.mn` as a narration
  at the landing, and again as a REFUSAL contract on 2026-09-15 (exit 0 with
  4,474 WAT bytes against the unarmed tree) when the class was ARMED at pin
  21696779. **WHOLE — the banked residual is discharged and its ratchet is
  gone.** The entry used to end here with "born at wheel-ZERO and ratcheted
  there (`use_after_move_max: 0`) … The ARMING is the banked residual", and
  that arrangement is the thing worth carrying forward: the key's own text
  named the zero as an *arming licence*, both its conditions were met at the
  landing, and it then sat for five weeks as a counter standing in for a proof
  nobody had minted. **A ratchet held at ZERO is a proxy for a proof** —
  `diag_refuses` holds the proof directly, in its own words ("born at ZERO on
  every program measured, which is the point: it does not police a mistake, it
  holds an invariant"). Fourteen of verify-baseline's twenty-six keys read zero
  the day this one retired; each that is a real `DiagKind` retires the same
  way, and each that is only a census shape retires when its shape is minted as
  a class — which is 8.4's universal executable refusal, arriving one landing
  at a time rather than as a sweep.
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
- **4.3 · The per-decl arena** (`Hβ.perf.per-decl-arena`) — ✅ LANDED
  2026-10-03, in the form its own 2026-08-07 refutation priced and passed
  over: EVACUATION. It is a hub — the String=`[Byte]` dissolution names it
  THE keystone dep, `persist = memcpy`'s image/scratch split rides it, the
  ceiling that killed a frontier leg shadowed the whole constructors arc,
  `instantiate-shares-never-clones` cashes its allocation payoff here, and
  total monomorphization needed its headroom. The 2026-08-07 build refuted
  site classification (a published value reaches older memory by a pointer
  write no bracket sees) and chose COLUMNS FIRST; the arena answers that
  objection at the write itself — every store into memory older than an
  open arena is journaled where it happens, with the type the store knows —
  so the reset is sound with the value graph as it is, and the column arc
  is no longer its precondition (`RESIDUE.md` carries both records). The
  fleet's 2026-07-17 "output-invariant" refutation stood: three TRANSITION
  pins. LIFETIME VOCABULARY: an extent's lifetime is a `~>` install, never
  a subsystem beside the program — what it publishes moves, what it does
  not is gone, and the image is still the graph is still the heap.
  Reclaiming is reachability from the publication, not a `Consume`:
  ownership's regions stay compile-time. Placed at the judgment's binding
  groups and at every extent beyond them (Arena·P2, §7).
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
  (2026-08-08): `Hβ.egraph.per-expr-effect-row` CLOSED 2026-09-30 (C5) —
  not as the spine column this sentence named but as a READ: the
  judgment notes each charge on the node that makes it and a subtree's
  row is a fold over structure (`row_of_subtree`), which is what
  `is_pure` reads now — and
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
  cleared the name because a handler for it was installed SOMEWHERE, so the
  program compiled and trapped. It is the mirror of the install-extent rule
  this sweep already pins — an op before the extent OPENS rather than
  after it closes — stamped as
  `Hβ.effects.root-gate-credits-an-install-that-had-not-opened` and
  CLOSED 2026-09-27 without band A: the credit is deleted and the root
  gate reads the row alone (§7); the
  sweep continues rule-by-rule), and the
  capability-at-tee PROJECTION — ✅ LANDED 2026-08-08 (pin
  2dcd736eb4e6): `mentl where` renders every install as
  `~> h absorbs E, answers T at <span>`, the effect set from the handler's own
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

### Phase 7 · Flow — the influence walk gains control edges

**Re-scoped 2026-10-02** (§4⑥): no `Flow` row element and no label lattice.
The phase is three moves on machinery that exists. (1) CONTROL EDGES: the
influence walk that reads a value's label (P0·D's leaves, S5's state writes)
also reads the parent edge to every branch, scrutinee and guard the value or
the perform stands under — an implicit flow is that ancestry. (2) LABELS ARE
REFINEMENTS: a source's declared return carries its classification, a sink's
parameter its demand, and the integrity dual (`Untrusted` must not reach
`Trusted`) is the same claim read the other way; a predicate over provenance
is decided by the walk, never by a predicate's name. (3) DELETION:
`FlowLabel`, `predicate_flow_label`, `query_flow_label`, `QFlowOf` and the
construction-site splice check (`Hβ.ifc.dcc-noninterference-gate`'s first
face, which caught the ShowExpr desugar defeating it on 2026-08-08) retire
into the claim the splice's sink raises. Persistence needs nothing: a label
is a refinement on a value in the image. The honest disclaimer stands — a
proof says where OUTPUT may go, never what a model does inside its window.
Terminal gate: `Untrusted` reaching a `Trusted` sink refused like `!Alloc`,
both regimes first-class — DONE statement (2) whole.
(`Hβ.ifc.flowlabel-inference-in-hm`'s row-element design is SUPERSEDED.)

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
- **8.3 · Verify's own solver — the search Mentl already is.** Re-scoped
  2026-10-02 from "Z3/CVC5 behind `~> verify_smt`". A CDCL(T) solver's parts
  are already kernel machinery: union-find and the e-graph are congruence
  closure, the trail with checkpoint and rollback is the assignment stack and
  backjump, a fork is a case split, a gate checked at the one writer is
  theory propagation, C6's first divergence between two trails is conflict
  analysis, and promotion below a checkpoint is clause learning. So the solver
  and the `??` proposer are ONE search: a satisfying model is a proposal, an
  unsat core is 8.4's minimal inconsistent core, a learned conflict is the
  computed question. The fragment, in the order the wheel's own debt names
  it: path narrowing (all five partiality claims C5 left open on the wheel
  are path-guarded, `Hβ.verify.partiality-reads-the-path-narrowing`),
  overflow-aware Int intervals
  (`Hβ.verify.interval-fragment-assumes-unbounded-int`), linear arithmetic
  (difference logic, then simplex), equality from the e-graph, case splits by
  fork. An external solver plugs in where a model does — behind the gate,
  its certificate (Alethe/LFSC) checked by the kernel — and is never an
  Outside (`Hβ.verify.smt-handler-swap` re-scoped to that proposer slot).
  `Hβ.verify.ledger-soundness` (no silent assume-true, the Dafny
  cautionary), `.proof-incrementality-cached-cursor` (obligations
  re-discharge only in the changed cone), `.reason-edge-pcc-certificate` (a
  discharged proof carries a walkable certificate — proof-carrying code as a
  Reason projection).
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
  (1) — the crown sound, Verify decidable-with-honest-debt and its search
  the medium's own, every armed class refusing.

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
  `Hβ.lower.held-resume-record-is-not-reclaimed` (the held single
  resume's record, O(1) once frames live in the image). The demonstration
  workload is Pulse's learned effect, and it is a PROJECTION, not a
  resumption: `Hβ.lower.ad-is-a-demanded-projection` retracted the
  autodiff-as-multishot peer on 2026-09-27 (reverse mode needs no
  multi-shot; it needs the install to become the emit). Felt faces
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
  the schedule twin (`Hβ.lower.schedule-specialized-callee`, CLOSED
  2026-09-30 — the demand through direct calls),
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
  Terminal gate: DONE statement (7) — every lever inside, and the one
  named residual Outside (the intent space, permanently) stated as exactly
  what it is.

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
  **THREE OF THE FIVE CLOSED 2026-09-19 (pin 7c9dc538), and the measurement
  that closed them was the fan's own constant.** `judge_window` was 1 and the
  block walk spawned exactly one task per block and joined it immediately, so
  the isolation was guarding a concurrency that was switched off. A candidate
  is judged inside `graph_push_checkpoint` + `heap_mark` + `world_top` … 
  rollback on the ONE live graph now — the triple the gradient's row bracket
  already owned (`row_clause_holds` since D4), whose own comment calls it
  *"the synth fan's exact shape"* —
  so the isolated per-candidate instance, the empty `graph_handler` that made
  a sibling's proof invisible, and the direct `spawn_task` at a constant width
  are all deleted, along with the banded partition that existed only to
  number them. TWO STAND, and they are the two that need other arcs:
  generate-then-filter (narrowed for the REFINEMENT arm by the Domain read,
  pin 2f6ddeac; the rest of the eight arms still judge after constructing),
  and forking UNIFORMLY, which waits on the e-graph yielding CLASSES so a
  form-variant never forks at all. The width returns at 9.2 as a
  `~> Schedule` decision. Sequential is now a PROPERTY of the segment walk
  rather than a constant, which is why the fan's own trail is readable.
  **THE HOLE BECAME A TERM CELL 2026-09-19 (pin 92a8d732)** — the sentence
  this section opens with stopped being a design statement. `propose_at` was
  handing the proposer a COPY of the hole's type (`ty_of_kind` keeps the
  handle on `NFree` and discards it on `NBound`), so the proof gate had no
  cell to bind and instantiated the target fresh; `Context` carries the
  handle now and `candidate_proven` unifies. What the copy hid, measured:
  a hand-rolled return-type matcher refused `none_of() -> Option(a)` at an
  `Option(Int)` hole — one type under unification — and every nullary
  constructor candidate was minted as a CALL (`None()`), ill-typed by
  construction, its mismatch leaking to a span in an unrelated module while
  the candidate rendered as a bare `??`. The matcher is deleted in favour of
  a SOUND index (`heads_may_unify`, which can hide nothing), and refusals
  now render at the address surface, which they never had. `Hβ.synth.
  divergence-from-the-trail`'s remaining owing is a FIXTURE — a hole whose
  cell is genuinely free at propose time — not a mechanism.
  **A SIXTH WAS FOUND AND CLOSED 2026-09-18, and it was the one that touched
  the developer: the ANSWER was a LIST.** `Proposals([(Node, Reason)],
  [(String, Reason)])` made six surfaces re-derive the verdict from `len`,
  and the copies disagreed at the position where it costs most — the address
  render's one-survivor arm dropped the Reason while its tie arm kept one per
  candidate, so the medium showed its reasoning when unsure and withheld it
  where a developer is likeliest to accept on faith. `Proposal({verdict,
  rejected})` over `VFill(Node, Reason) | VAsk(Divergence, …) | VNone` makes
  that unsayable, and the tie's fixed sentence ("one more constraint … 
  collapses it", the same words at every position) became the COMPUTED
  question below, classified by `Divergence` — row, then denotation, then
  value, then shape — with one RED-first fixture per arm. The remaining five
  are the fan's own mechanism and stand.
  **AND THE RECEIVED SHAPE IS NOT MENTL'S PRIVATE FAILURE — IT IS THE
  FIELD'S** (surveyed 2026-09-14). Five areas, five different communities,
  one limit: *the artifacts of reasoning are discarded between phases.*
  Type-directed synthesis (Smyth's live bidirectional evaluation, Scrybe's
  top-down deduction over it) propagates a SPEC — examples — through the
  sketch, never the judgment. LLM-based synthesis generates, then verifies,
  then repairs on the counterexample: verification is a post-hoc FILTER and
  every candidate is judged WHOLE. E-graph extraction is NP-hard over an
  arbitrary DAG cost, answered with ILP or heuristics, and side effects are
  handled by *relaxing the CFG skeleton* — an approximation bolted on
  because the IR has no effect algebra. Effect systems reached rows ≡
  capabilities (POPL 2026, Tang et al., arXiv 2507.10301 — §4③'s own
  citation) and NOBODY carries negation into that unification.
  Disambiguation clusters candidates and asks a multiple-choice query scored
  by information gain ("Choose, Don't Label", 2026), whose authors name
  clustering quality and scaling in candidate count as its limits. Every one
  of those five is the Carried-Truth Law read at the search layer, which is
  why the fix here is the same fix as everywhere else in this document and
  not a cleverer search.

  **THE ULTIMATE FORM — THE ORACLE IS INFERENCE WITH A TERM-SORTED
  UNKNOWN.** A `??` is a cell whose binding is undetermined; so is every
  unresolved type variable, and Mentl ALREADY owns that machine — union-find
  over the graph, monotone narrowing, trail-backed checkpoints. The oracle
  today re-implements it badly. Make the hole a TERM CELL IN THE SAME
  UNION-FIND and four things stop being aspirations:
  - **Propagation precedes enumeration.** Type, row, ownership grade,
    refinement and consumer shape narrow the cell BEFORE anything is built,
    so ill-typed candidates are never CONSTRUCTED rather than
    constructed-and-rejected, and enumeration runs only on a maximally
    narrowed cell with more than one inhabitant, cheapest constraint first.
    Smyth/Scrybe do this for examples; doing it for the whole eight-aspect
    judgment (§2's arms, all of them) is the surpass.
  - **Fork only at genuine disjunction.** A trail forks when a constraint is
    a real disjunction; form-variants never fork, being congruence classes —
    which IS the e-graph. "Fork at meanings, merge at forms" stops being
    policy and becomes mechanism, and the fan's width is literally the
    number of disjunctions in the constraint system.
  - **Shared context is free, not engineered.** Branches are trail SEGMENTS
    over ONE graph, so a fact proven above the fork is simply visible: there
    is no sharing protocol because there is nothing to share. LEMMA SHARING
    is then promotion below the checkpoint — a fact independent of the
    branch's choice is monotone and may flow to siblings, branch-local
    bindings never (the 2026-08-07 race and the severance that hid it) —
    sound for exactly the reason clause-sharing is sound in portfolio SAT,
    and it is where threads actually pay.
  - **Stated precisely, because the slogan would be false:** this is
    CLP-style propagation over the graph with DISJUNCTION AS A LAYER ABOVE
    the cell substrate. Plain unification is not confluent for terms. The
    shared thing is the substrate — cells, trail, narrowing — not the
    solving discipline.

  **THE QUESTION IS COMPUTED, NOT CLUSTERED.** Two survivors differ at a
  FIRST DIVERGENCE IN THE TRAIL — the earliest cell where they bound
  differently. That cell is not a cluster label; it is the exact proposition
  the developer never stated, and because every binding carries a Reason it
  renders in their own vocabulary ("is `xs` consumed here, or borrowed?"),
  never as "which of these two programs?". This dissolves both limits the
  multiple-choice line names against itself: there is no clustering to be
  bad at, and no scaling in candidate count, because the question is
  computed from two trails rather than from enumerating a set. **The
  tradeoff is named rather than smuggled:** first-divergence is the EARLIEST
  distinguishing proposition, not the maximum-information-gain one. The
  claim is that earliest is the better question for a medium you live in —
  it asks about what the developer was just writing, where max-gain asks
  about whatever behavioural consequence happens to split the space — and
  that is a design decision, recorded as one, falsifiable by a felt walk.
  **THE CLASSIFICATION LANDED BEFORE THE TRAIL DID (2026-09-18), AND THE
  TRAIL IS ITS SOURCE NOW (C6, 2026-09-30).** `Divergence` names WHAT
  separates the survivors and speaks it in that arm's own vocabulary. Its
  source was each survivor's live reads while candidates were judged in
  COPIED instances; every candidate is a segment over the ONE graph since
  pin 7c9dc538, and the segment now carries out the context cells its binds
  moved (`graph_written_since`, read before the rollback undoes them), so
  the first such cell two survivors bound differently IS the question — a
  type cell with its own Reason (`DivType`: a free hole asks "which type
  does this position hold?" where the survivors' reads had asked a value
  question about `1` and "a"; a hole in a parameter's class names the
  declaration's return as the cell that moves), a row cell as `DivRow`.
  Only when no context cell moves is the question about the TERM, read as
  before — row, denotation, value, shape. What the trail cannot yet carry
  is stated with it: a declaration's row is a scheme VALUE after finalize,
  so a candidate's charge cannot move it and the row arm at the term level
  stays the survivors' own read (rung 3, `Hβ.infer.schemes-are-edges`), and
  a segment's own mints collide numerically after rollback, so the diff
  reads context cells alone until `(arena, offset)`
  (`Hβ.synth.divergence-from-the-trail`, CLOSED). The precedence itself is a judgment
  and is recorded as one: a same-denotation tie is a MEANING tie at the
  INTENT altitude, not §5's free form-space tie, because the duality calls a
  tie free when a COST function totally orders it and cost is blind to what a
  later reader learns from a name.

  **EXTRACTION GETS SMALLER, NOT CLEVERER.** Extraction is NP-hard over an
  ARBITRARY cost function on an AND-OR DAG; Mentl's cost is not arbitrary.
  It is the repr gradient, and repr is a TYPE-LEVEL fact (§5.U), so wherever
  the type pins the width the extraction choice is FORCED and the search
  collapses onto the genuinely-free positions. That is not a better ILP — it
  is a smaller problem. Rewrite-legality under effects is likewise a row
  query where the field needs a CFG relaxation to approximate one, the
  effect row playing both halves exactly as §5 already says. Prove-then-
  extract stays FORCED; the order is the soundness argument, not a
  preference.

  **THE TWO AXES NO PEER CAN RETROFIT.** `!E` in the modal setting — the
  unification is discharged, the NEGATION half is open, and absence under
  polymorphism, through higher-order code, across a persisted continuation's
  `TCont` world is unclaimed territory (§4③'s open burden is also the moat).
  And a DURABLE SEARCH: a branch is a continuation record in a
  memcpy-serializable image, and `persist = memcpy` is BUILT (§7), so an
  exploration suspends and resumes across runs and machines while every peer
  synthesizer is a within-process search. The fan is written
  `candidates |> fanout(...)` — the sequence fanout under whatever schedule
  the propose site installs (B4 + C9, 2026-09-30) — so width is a handler
  decision and `judge_window` has dissolved; and the answer is never a LIST — unique survivor fills, and
  multiple meanings ask the one question, because a list is the medium
  admitting it does not know.

  **WHAT IT DEPENDS ON — corrected 2026-09-15, because the first draft of
  this paragraph inherited a refuted chain.** It said "term cells need live
  cells (rung 3) … and both need D0". Both halves are wrong at the artifact.
  Liveness is not the lever (`Live(handle)` shipped and moved nothing,
  infer.mn:1054), so what a term cell needs is ONE judgment to read — the
  trial pass deleted, not a live variant minted. And D0 is not the gate it
  was taken for: its 690 code sites would delete `subst_ty`/`chase_deep` only
  alongside an instantiate-as-correspondence-edge design that does not yet
  exist, so it is a PARKED precondition with a named missing half, not the
  next step. What survives intact: the first-divergence question needs
  provenance as EDGES — a diff is cheap over shared edges and absurd over
  duplicated trees — and the shared trail segment needs one judged context.
  §11's "one law, four faces" still holds; the correction is which face is
  load-bearing, and it is the PASS, not the freeze.
- **11.2 · `mentl edit` / `mentl space` polished.** The keystroke→parse→format→render loop
  continuous (`Hβ.felt.mentl-edit-runtime`), reactivity typed and
  demand-driven, the verification dashboard (live V_Pending / transitive
  `!E` / Why chains), collab as Grove-CRDT over the TYPED graph,
  legibility derived. The Resident Space Session (`ide/wheel-worker.js`,
  `ide/test-shim.mjs`, `ide/index.html`) hosts the living graph over shared
  WebAssembly memory with sub-50ms address projections and delta updates,
  measured by `tools/ide-gate.sh` — **which nothing invoked until 2026-09-21**,
  not `state.sh`, not a hook, not `tools/ci/run-board.sh`, while this sentence
  read "verified green across Node and headless Chrome" and Arc E named
  `ide-gate green` as the Space spine's terminal bar. Tripwire 4 on the arc
  this plan calls the production target, with the green claim already written
  over it. The gate is ON THE BOARD now, so the claim is a measurement: leg 1
  (the node twin over `ide/wheel-worker.js` — stub-spawn RED control,
  compile-stdin through real spawned tasks, the address CursorView, the `??`
  Propose socket, resident navigation, resident delta+propose) is GREEN; leg 2
  (headless Chrome over `mentl space`) SKIPS loudly where chrome is absent,
  and a board that has only ever run leg 1 has not measured the browser —
  until 2026-09-25, when both legs ran GREEN (leg 2: `SMOKE exit=0 tasks=259
  ms=2049`; the skip was the literal command name `google-chrome` — the
  gate FINDS a browser now: `$MENTL_CHROME`, the usual names on PATH, then
  Playwright's chromium). **THAT GREEN MEASURED A WHEEL THE TREE NO LONGER
  HAD** (2026-09-27): the 259 tasks were the eight-week-old IDE copy judging
  per stmt, and the twin's first legs DEMANDED spawns — a stub spawn that
  must refuse, `tasks > 0` — where the judgment has spawned nothing since
  the fan's direct spawn was deleted at pin 7c9dc538. Loading the boot
  itself turned them red; the task count is a measurement now, the stub
  control is armed only while the judgment spawns and prints VACUOUS
  otherwise, and the page compiles the boot in 353 ms (`SMOKE exit=0
  tasks=0 watlines=4399 ms=353`). The session keeps its graph since E2
  (2026-10-02): one instance answers for the page's life over a
  shared-memory channel, an edit re-judges its cone in that instance, and
  the gate times every read against the cold route — the twin's leg 4, and
  the browser's `SMOKE-SESSION open=130 read=5.6 resident=true query=true`
  at pin 8b071ba3. The page runs THE BOOT
  ITSELF since 2026-09-27: the wheel's memory minimum is 32 pages and its
  allocator grows the memory on demand, so the page fetches
  `../boot/mentl.wasm` through `mentl space`, the node twin loads the same
  file, and the hand-derived `ide/mentl-ide.wasm` copy — the 2026-07-29
  wheel, eight weeks behind the boot — is deleted
  (`Hβ.ide.pinned-wasm-lags-boot` closed).
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
