# Research report: the 2026 state of the art against Mentl's claims

*One of three web-research passes commissioned by the 2026-09-25 process audit
(`docs/PROCESS-AUDIT-2026-09-25.md`). 25 web searches and fetches; no repo
files read. Tags: **[V]** fetched or seen in primary search results this
session; **[T]** title and venue seen only; **[PK]** prior knowledge, not
re-fetched (treat as leads to check). Where a verdict is inference rather than
documented fact, it says so.*

---

## 1. Effect systems: is "Boolean rows with negation" novel?

**Flix already ships the core claim, with proofs.**
- "With or Without You: Programming with Effect Exclusion" (Lutze, Madsen, Schuster, Brachthäuser; ICFP 2023) **[V]**: "effect polymorphism as well as union, intersection, and complement effects"; programmers can write "effect polymorphic functions … that permit any effects except those in a specific set". Algorithm W plus Boolean unification over the set algebra gives "complete type and effect inference". It proves progress, preservation and an effect-safety theorem: *"no excluded effect is ever performed."* Implemented in Flix; a case study found 59 real code fragments that need exclusion. https://icfp23.sigplan.org/details/icfp-2023-papers/16/With-or-Without-You-Programming-with-Effect-Exclusion · https://dl.acm.org/doi/abs/10.1145/3607846
- Supporting line of work **[V/T]**: Madsen & van de Pol, "Polymorphic types and effects with Boolean unification" (OOPSLA 2020) https://dl.acm.org/doi/10.1145/3428222 ; "Fast and Efficient Boolean Unification for HM-Style Type and Effect Systems" (OOPSLA 2023) https://dl.acm.org/doi/10.1145/3622816 ; "Associated Effects" (PACMPL 2024) https://dl.acm.org/doi/10.1145/3656393 ; "Qualified Types with Boolean Algebras" (Lee, Starup, Lhoták, Madsen; OOPSLA 2025) **[T]**, artifact https://zenodo.org/records/15756115 .
- Not checked: whether mainline Flix today exposes complement syntax or only the paper's extension.

**Rows with explicit absence are older still.** Rémy-style presence/absence flags (POPL 1989) and Links' effect rows with presence polymorphism (Hillerström & Lindley, TyDe 2016) already encode "label absent" inside a polymorphic row **[PK]**. Mentl's `EfRow(present, absent, tail)` has that shape.

**Tang & Lindley.** "Rows and Capabilities as Modal Effects", PACMPL 10 (POPL 2026), DOI 10.1145/3776674, arXiv 2507.10301 **[V]**. https://arxiv.org/abs/2507.10301 · https://popl26.sigplan.org/details/POPL-2026-popl-research-papers/34/Rows-and-Capabilities-as-Modal-Effects
- It claims a uniform framework generalising modal effect types, with "encodings as macro translations from existing row-based and capability-based effect systems" that "preserve types and semantics". This is encoding both into a common modal calculus in order to compare them; it is not a theorem that "rows ≡ capabilities." The abstract says nothing about negation or absence. The base calculus: "Modal Effect Types" (PACMPL 2025, DOI 10.1145/3720476) **[T]**.

**Per-instance absence.** Capability systems give per-instance absence by construction (Effekt's capability-passing, OOPSLA 2020/2022; Scala capture checking, "Capturing Types", TOPLAS 2023) **[PK]**; Koka has first-class named handlers (OOPSLA 2022) **[PK]**. What looks less common is complement syntax over value-indexed effect instances; Mentl's version compares literal arguments only, so it is narrow.

**Other systems** **[PK]**: Koka rows use scoped labels with no clear notion of "absent"; OCaml 5 effects are untyped (unhandled effect = runtime exception); Unison abilities follow Frank, no complement. 2026 activity **[T]**: "Effect Systems as Abstract Interpretations" (arXiv 2606.19686), "Classifying Capabilities" (arXiv 2607.24504), "Type, Ability, and Effect Systems…" (arXiv 2510.07582).

**Known soundness hazards under higher-order polymorphism** **[PK]**: accidental handling / effect encapsulation (a handler inside a polymorphic HOF can intercept its argument's effects): Zhang & Myers, "Abstraction-safe effect handlers via tunneling" (POPL 2019); Biernacki et al., "Abstracting algebraic effects" (POPL 2019). This bears directly on *which instance* an absence proof is about. Negation composes cleanly with set semantics (Flix, Rémy/Links), not with scoped labels (inference).

**Implementation gap (from the project's own PLAN §7).** A reachable effect operation with no handler installed anywhere currently compiles clean, so the implementation does not yet deliver the effect-safety property that Flix's calculus proves.

## 2. Durable execution and continuations

- **Golem 1.5** (May 14, 2026) **[V]**: https://golem.cloud/blog/golem-1-5-the-agent-runtime/ Durability comes from oplog replay; snapshots are recovery checkpoints; "user-defined snapshotting" serializes structured state through the SDK, not raw linear memory; languages: Rust, TypeScript, Scala (via Scala.js), MoonBit. Golem's explainer says continuous snapshots are *not* whole-memory snapshots "because that would reduce performance and increase latency" (vendor claim via search summary). https://www.golem.cloud/post/what-is-durable-computing So "persist = memcpy of linear memory" is not Golem's primary mechanism, and Golem argues against it on latency grounds.
- **Prior art for memcpy/image persistence** **[PK]**: Smalltalk images; Common Lisp `save-lisp-and-die`; Stackless Python pickled tasklets; Racket's serializable continuations for stateless servlets (McCarthy, ICFP 2009); CRIU. The image idea is old and known to be brittle.
- **Temporal, Restate, DBOS** **[PK]** use event-history replay, journals, or step checkpoints. Their hard problem is code evolution of in-flight executions (Temporal's patching and worker versioning), not serialization. Mentl's `image_resume` gates on a build key, so a persisted continuation cannot survive a recompile; host resources (fds, sockets) are not restored (per Mentl's own docs).
- **WasmFX / stack switching**: Phase 3 in the WebAssembly proposals README (fetched Sept 2026) **[V]** https://github.com/WebAssembly/proposals/blob/main/README.md ; Shared-Everything Threads is Phase 1 **[V]**; Wasmtime implementation: "Continuing Stack Switching in Wasmtime", WAW 2025 **[T]** https://dhil.net/research/papers/wasmfxtime-waw2025.pdf ; "Iris-WasmFX" (PACMPL, DOI 10.1145/3808271) **[T]**. Proposal continuations are one-shot **[PK]**; multi-shot needs compiler-side reification, which is what Mentl does.
- **Verdict.** Memcpy persistence and WASM durable execution are already shipped. A compile-time "resume under changed handler set" error would be novel *if enforced*; per the project's docs it is inert on the one-shot path.

## 3. Ownership and linearity inference (all **[PK]**)

- Lean 4 automatically infers owned vs borrowed parameters ("Counting Immutable Beans", Ullrich & de Moura, IFL 2019, arXiv 1908.05647): the closest prior art to "`own`/`ref` from use."
- Koka Perceus (PLDI 2021) inserts precise reference counting with no annotations; FBIP/FIP (ICFP 2023) checks a `fip` annotation.
- OCaml modes ("Oxidizing OCaml with Modal Memory Management", ICFP 2024; OxCaml): locality, uniqueness and linearity modes, largely inferred, with annotations at boundaries.
- Hylo (`let`/`inout`/`sink`/`set`) and Mojo (`read`/`mut`/`owned`) deliberately keep conventions explicit. Rust is explicit with elision. Granule has graded modal types; fractional uniqueness in Marshall & Orchard, OOPSLA 2024 (verify).
- Known limit: inferring ownership from body use couples a function's signature/ABI to its body; editing a callee can change callers' obligations, breaking modularity and separate compilation. That is why Swift, Hylo and Mojo fix conventions at API boundaries. A 0/1/2+ use-count is a syntactic heuristic; Lean's borrow inference is also heuristic, and there it is an optimization, not a safety proof.
- **Verdict.** Partially novel framing ("ownership as an inferred effect"); the mechanism is established.

## 4. Refinement types, verification, and LLMs

- **Vericoding benchmark** (arXiv 2509.22908; Dafny 2026 workshop at POPL 2026) **[V]**: 12,504 formal specs (Dafny 3,029, Verus 2,334, Lean 7,141). Off-the-shelf LLM success: 27% Lean, 44% Verus, 82% Dafny. Pure Dafny verification rose from 68% to 96% in about a year. Adding natural-language descriptions did not significantly help. https://arxiv.org/abs/2509.22908
- **The thesis is mainstream.** Kleppmann, "Prediction: AI will make formal verification go mainstream" (Dec 8, 2025) **[V]** https://martin.kleppmann.com/2025/12/08/ai-formal-verification.html argues exactly Mentl's §0.
- Prior LLM-plus-verifier work **[PK]**: AutoVerus (arXiv 2409.13082), AlphaVerus (arXiv 2412.06176), Clover (arXiv 2310.17807), DafnyBench (arXiv 2406.08467).
- "Honest V_Pending debt" is standard practice **[PK]**: Lean's `sorry` warnings; Dafny `assume` plus `dafny audit`; F* `admit`; gradual verification (Bader/Aldrich/Tanter, VMCAI 2018). "Decidable fragment plus SMT" is Liquid Types (PLDI 2008).
- Adoption evidence: benchmarks and commentary only; no survey quantifying industrial uptake of verification for AI-generated code was found.
- **Verdict.** The design is already shipped elsewhere; Mentl's refinement tier is behind SOTA per its own docs (a separate `PExpr` walk that degrades to debt; the SMT swap unbuilt).

## 5. Provenance, explainability, and structural editors

- Provenance of inference **[PK]**: Bhanuka, Parreaux, Binder, Brachthäuser, "Getting into the Flow: Towards Better Type Error Messages for Constraint-Based Type Inference" (OOPSLA 2023), the closest research analogue to Reason chains; SHErrLoc (Zhang & Myers POPL 2014; PLDI 2015); type-error slicing (Haack & Wells); Hazel's marked lambda calculus, "Total Type Error Localization and Recovery with Holes" (POPL 2024); Elm and Rust as the industrial bar.
- Darklang: the structured editor was rated "between 'Ok I guess' and 'probably the worst part of Darklang'" and removed ("Darklang is going all-in on AI", Mar 12, 2024 **[V]**, https://blog.darklang.com/gpt/); the company later restructured **[T]** https://blog.darklang.com/goodbye-dark-inc-welcome-darklang-inc/ . JetBrains MPS usability claims not verified.
- **Verdict.** Partially novel: attaching a Reason edge to every inferred fact behind one query surface is an engineering unification; the research components exist; the known cost is provenance blow-up, which Mentl's own docs admit (Reasons duplicated as trees).

## 6. Capability and IFC for AI agents

- **Odersky, Zhao, Xu, Bračevac, Pham, "Tracking Capabilities for Safer Agents"** (arXiv 2603.00991, Mar 2026) **[V]** https://arxiv.org/abs/2603.00991 ; also "Securing Agents With Tracked Capabilities" at ACM CAIS 2026 https://dl.acm.org/doi/10.1145/3786335.3813127 (reported as a best-paper award in the search summary; not independently confirmed). Agents express actions as Scala 3 code under capture checking; capabilities are program variables; "local purity" prevents leakage when processing classified data. Result: "agents can generate capability-safe code with no significant loss in task performance."
- **LACUNA: Safe Agents as Recursive Program Holes** (Zhao, Xu, Bračevac, Pham, Wu, Odersky; arXiv 2605.28617, May 27, 2026) **[V]** https://arxiv.org/abs/2605.28617 : each action is a typed hole `agent[T](task)` an LLM fills at runtime; the code is "type-checked against the surrounding program before it runs", with capability tracking; rejected code triggers retries using compiler diagnostics. BrowseComp-Plus: 8.6% of generations rejected, 0.7 retries per query, 27.1% accuracy. τ²-bench: 76.0% of 392 tasks, matching baseline.
- **FIDES** (Costa, Köpf et al., Microsoft; arXiv 2505.23643, May 2025) **[V]**: a planner tracking confidentiality and integrity labels with deterministic enforcement, evaluated in AgentDojo. https://arxiv.org/abs/2505.23643 · https://github.com/microsoft/fides **CaMeL** (Debenedetti et al., arXiv 2503.18813) **[PK]**. 2026 follow-ons **[T]**: APPA (arXiv 2607.24625), Agent libOS (arXiv 2606.03895). Classic IFC with ML inference **[PK]**: FlowCaml (POPL 2002), Jif, LIO.
- **Capslock caveats** **[V]** https://github.com/google/capslock/blob/main/docs/caveats.md : it cannot analyze cgo or assembly; `go:linkname` becomes `ARBITRARY_EXECUTION`; reported call chains "may not necessarily occur in practice"; no soundness guarantee for absence is claimed. Nuance Mentl's summary omits: Capslock reports `reflect`, `unsafe`, `os/exec` and `plugin` *as capabilities themselves*, "so that capabilities are not missed without any indication to the user." That is conservative flagging of escape hatches, not silent unsoundness.
- **Answer to "is anyone shipping this?"** Yes, at research grade in a mainstream language (Scala 3), with published evaluations, and LACUNA also implements "LLM proposes, type checker filters, diagnostics fed back."

## 7. Synthesis with proof filtering

- **Type-constrained decoding** (Mündler, He, Wang, Sen, Song, Vechev; PLDI 2025) **[V]**: prefix automata plus type inference plus search over inhabitable types, applied to TypeScript; "reduces compilation errors by more than half" and improves functional correctness. https://dl.acm.org/doi/10.1145/3729274
- Hazel, "Statically Contextualizing LLMs with Typed Holes" (OOPSLA 2024) **[PK]**; classical type-directed synthesis: Synquid (PLDI 2016), Myth, Smyth (ICFP 2020) **[PK]**.
- MoonBit describes a "real-time, semantics-based sampler to guide the inference" (LLM4Code 2024) **[V, via summary]** https://dl.acm.org/doi/10.1145/3643795.3648376
- **Disambiguation.** "Choose, Don't Label: Multiple-Choice Query Synthesis for Program Disambiguation" (Barnaby, Ding, Bastani, Dillig; arXiv 2604.08792, Apr 9, 2026) **[V]**. Tool: Socrates. Each answer option is "a Hoare triple that characterizes a cluster of semantically similar candidate programs." Mentl's claim that the authors name clustering quality and candidate-count scaling as limits is not visible in the abstract; unverified.
- Caution on constrained decoding **[T]**: "The Alignment Problem in Constrained Code Generation" (arXiv 2606.21619).
- **Verdict.** "LLM proposes, compiler filters" is already demonstrated. "The question is the first trail divergence" is partially novel versus Socrates, and has no evaluation.

## 8. "AI-native" languages

- MoonBit positions itself as AI-friendly/AI-native **[V, via search summaries]**: a non-nesting, KV-cache-friendly design and a semantics-guided sampler; the MoonBit Pilot agent https://www.moonbitlang.com/blog/intro-moonbit-pilot ; a 2026 Software Synthesis Challenge https://www.moonbitlang.com/2026-scc ; Golem supports it.
- Darklang pivoted "all-in on AI" **[V]**. Mojo and Bend target performance and parallelism, not LLM authorship **[PK]**.
- Empirical evidence: per-language LLM performance tracks training-data volume (MultiPL-E) **[PK]**; the vericoding spread (Lean 27% vs Dafny 82%) shows proof burden and corpus size dominating. No rigorous study isolates syntax design as a causal variable.
- Implication (inference): a zero-corpus language faces the low-resource penalty. With the LLM "only a proposer", poor proposals mostly get filtered, which is sound but unproductive. Odersky's group chose Scala partly because models already write it.

---

## Claim → prior art → verdict

| Mentl claim | Closest prior art | Verdict |
|---|---|---|
| (a) Boolean effect rows with `!E` proving transitive absence under polymorphism | Flix ICFP'23 (complement effects, complete inference, safety proof); Rémy/Links presence rows | **Already shipped**. Per-instance (`!Sample(44100)`): partially novel. Implementation soundness is behind Flix per the project's own docs. |
| Negation plus modal/capability unification | Tang & Lindley POPL'26 encodes rows and capabilities, no negation | **Open problem; novel if solved.** The paper does not claim "rows ≡ capabilities." |
| (b) handler = state = closure = continuation record, memcpy persistence | Smalltalk/Lisp images, Stackless pickling, Racket serializable continuations, Golem | **Already shipped** as a technique. Golem rejects whole-memory snapshots for latency. The build-key gate means no code evolution. |
| Typed resume-world check on persisted continuations | Temporal versioning (runtime, untyped) | **Novel if enforced**; currently inert per own docs. |
| (c) Ownership inferred from use count | Lean 4 borrow inference, Perceus, OCaml modes | **Partially novel** framing. Modularity cost is known. |
| (d) Decidable refinements plus visible debt | Liquid Haskell, Dafny/F*/Lean debt conventions, gradual verification | **Already shipped**; Mentl is behind. |
| (e) Reason chain on every fact | Bhanuka et al. OOPSLA'23, SHErrLoc, Hazel MLC | **Partially novel** (unification/engineering). |
| (f) IFC as row facts `!Flow(Secret, Log)` | FlowCaml, Jif/LIO; FIDES, CaMeL, Scala local purity | **Already shipped**; Mentl's version is immature per own docs. |
| (g) `??` filled by LLM, compiler filters | Type-constrained decoding (PLDI'25), Hazel ChatLSP, LACUNA (May 2026), MoonBit sampler | **Already shipped (research)**. The first-divergence question is partially novel, unevaluated. |
| (h) Self-hosting on WASM, byte-identical fixpoint CI | GCC 3-stage compare, Zig's `zig1.wasm` bootstrap, Wheeler DDC **[PK]** | **Already shipped** technique. The determinism leg (`--fixpoint`) is never run per own docs. |
| (i) "Verification substrate for machine-generated code" | Kleppmann 2025; vericoding; Odersky CAIS'26; FIDES/CaMeL | **Contested / crowded**. The thesis is mainstream and the closest rival is in Scala 3. |

## What this means for positioning

The headline differentiators are not defensible as firsts: effect negation under polymorphism has been proven and implemented in Flix since 2023; "LLM proposes, type checker filters" and capability-typed agent code were published in 2026 by Odersky's group in Scala 3 with task-performance evaluations Mentl lacks; the "trust bottleneck" thesis is mainstream (Kleppmann, Dec 2025). Citing Tang & Lindley as "rows ≡ capabilities proven" overstates the paper. Characterizing Capslock as silently unsound omits that it reports its escape hatches as capabilities. Both should be corrected before external use.

What may be genuinely distinctive is the combination: complement rows, per-instance negation, a world-typed persisted continuation, and full provenance, all in one self-hosted substrate. The highest-value unclaimed research target is negation combined with modal/capability tracking and typed resume-worlds.

Credible positioning needs three things, in order: (1) the effect-safety hole closed (a perform with no install should refuse); (2) a published soundness argument for per-instance negation; (3) an empirical agent benchmark (AgentDojo or τ²-bench) against the Scala 3 capture-checking baseline. Absent those, "verification substrate" reads as an unevaluated reformulation of shipped work, and a zero-corpus language will struggle to get proposals worth filtering.

### Sources (fetched or seen this session)
arxiv.org/abs/2507.10301 · popl26.sigplan.org (Rows & Capabilities) · dl.acm.org/doi/10.1145/3720476 · icfp23.sigplan.org (Effect Exclusion) · dl.acm.org/doi/10.1145/3428222 · dl.acm.org/doi/10.1145/3622816 · zenodo.org/records/15756115 · golem.cloud/blog/golem-1-5-the-agent-runtime/ · golem.cloud/post/what-is-durable-computing · github.com/WebAssembly/proposals · dhil.net/research/papers/wasmfxtime-waw2025.pdf · arxiv.org/abs/2604.08792 · arxiv.org/abs/2505.23643 · github.com/microsoft/fides · arxiv.org/abs/2509.22908 · dl.acm.org/doi/10.1145/3729274 · blog.darklang.com/gpt/ · 2025.splashcon.org (Simple Essence of Monomorphization, DOI 10.1145/3720472; confirms Mentl's citation exists) · martin.kleppmann.com/2025/12/08/ai-formal-verification.html · moonbitlang.com · dl.acm.org/doi/10.1145/3643795.3648376 · github.com/google/capslock/blob/main/docs/caveats.md · arxiv.org/abs/2603.00991 · dl.acm.org/doi/10.1145/3786335.3813127 · arxiv.org/abs/2605.28617
