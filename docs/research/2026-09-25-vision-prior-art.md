# Research report: prior art for "the medium proposes the next move"

*The fourth web-research pass commissioned by the 2026-09-25 process audit
(`docs/PROCESS-AUDIT-2026-09-25.md`), run after Morgan's reply re-anchored
the audit on the vision in the early docs. 22 search and fetch calls; no
repo files read. **(V)** confirmed this session from the linked page or
search result; **(M)** cited from memory without re-fetching (check
bibliographic details before reuse); "Inference" marks the researcher's
judgment.*

---

## 1. The compiler proposes the next move without an LLM

**What exists**
- **Lean 4 core (V).** Lean 4.22 (Aug 2025) shipped `grind`, an "SMT-style" tactic with theory solvers and Gröbner-basis support, and a new compiler (https://x.com/leanprover/status/1956440244825493766). In Lean 4.28 (Feb 2026), `try?` "uses `first_par` to try three grind variants in parallel"; `first_par` "runs multiple tactics in parallel and returns the first successful result (cancelling the others)" (https://lean-lang.org/doc/reference/latest/releases/v4.28.0/). One `grind` variant uses a "library suggestion engine" whose algorithm the notes do not describe. Lean 4.20 made `rw?`, `show_term` and similar tactics "validate tactics prior to suggesting them, as `exact?` already did" (https://lean-lang.org/doc/reference/latest/releases/v4.20.0/). **Status: shipped.** The prover proposes a checked next step, including a parallel portfolio.
- **Canonical (V, ITP 2025).** Exhaustive type-inhabitation search for dependent type theory, packaged as a Lean tactic that synthesizes proofs and programs; solves 84% of Natural Number Game problems in 51 s total (https://arxiv.org/abs/2504.06239 , https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2025.14). A 2026 follow-up exists (https://arxiv.org/abs/2603.01463), not read.
- **Agda 2.7.0 (V).** Replaced Agsy with **Mimer**, "a type-directed search algorithm based on iterative refinement of meta-variables (holes)"; dropped Agsy's case-split, disprove and refine modes (https://hackage.haskell.org/package/Agda-2.7.0/changelog , https://agda.readthedocs.io/en/latest/tools/auto.html).
- **Haskell (V).** Wingman, the HLS tactics plugin, was proposed for removal: it "doesn't work on the last three major GHC versions" and has no maintainer (https://github.com/haskell/haskell-language-server/issues/3703). Inference: the most prominent typed-hole synthesizer in a mainstream-language editor died of maintenance coupled to the compiler's API. Hoogle+ (OOPSLA 2020, https://doi.org/10.1145/3428273 , M) and djinn (M) remain research or niche.
- **Research synthesizers (M):** Myth (PLDI 2015, https://doi.org/10.1145/2737924.2738007); Synquid, where refinement types prune the search (PLDI 2016, https://doi.org/10.1145/2908080.2908093); Smyth (ICFP 2020, https://doi.org/10.1145/3408991); Scrybe (Mulleners et al., PADL 2023). Idris 2 `:ps`, Coq `auto` and CoqHammer exist; no success statistics verified. Scala's implicit resolution is proof search used for derivation, not offered to the user as a proposed next move.

**Head-to-head evidence**
- **Magnushammer (V, ICLR 2024).** Learned premise selection reaches **59.5% vs Sledgehammer's 38.3%** on PISA and 34.0% vs 20.9% on miniF2F; paired with a language-model prover, PISA state of the art goes from 57.0% to 71.0% (https://arxiv.org/abs/2303.04488).
- **Lean Copilot (V).** LLM-driven search automates **74.2% of proof steps vs 40.1% for rule-based aesop**; assisting humans it needs 2.08 manually entered steps vs 3.86 (https://arxiv.org/abs/2404.12534 , https://proceedings.mlr.press/v288/song25a.html).
- **Li, Parsert and Polgreen (V, CAV 2024).** GPT-3.5 alone is "easily outperformed" by enumerative SyGuS solvers; an LLM placed inside the enumerator beats both and the SyGuS competition winner (https://arxiv.org/abs/2403.03997).
- **Type-constrained decoding (V, PLDI 2025).** Enforcing well-typedness during LLM decoding "reduces compilation errors by more than half" and raises functional correctness (https://dl.acm.org/doi/10.1145/3729274).

**Assessment.** Shipped for proof goals; research-grade for general programs. No evidence found that proof-guided search without a learned ranker beats token prediction at next-move scope in a typed context: where head-to-head numbers exist (Isabelle, Lean), learned ranking clearly beats rule-based search; pure search wins only where goals are small and types very informative (Canonical on the Natural Number Game), or against 2023-era models on formal specifications. Every best result is a hybrid: proof or type checking filters, a model ranks. Inference: the evidence strongly supports "proof is a monotone filter" and runs against "no LLM advantageous at any scope".

**"Ask the one question that separates the candidates."** The established analogue is the *distinguishing input* in oracle-guided synthesis (Jha et al., ICSE 2010, https://doi.org/10.1145/1806799.1806833 , M) and the disambiguation interfaces of programming-by-example (Mayer et al., UIST 2015, https://doi.org/10.1145/2807442.2807459 , M). Both ask about behaviour. Nothing found asks at the level of where two type/effect/ownership derivations diverge.

## 2. Multiverse and parallel exploration of program variants

- **Worlds (M, ECOOP 2011, https://doi.org/10.1007/978-3-642-22655-7_9).** First-class, committable scopes for side effects, in JavaScript and Squeak. The closest conceptual ancestor of forked cursors; research only.
- **Multiverse debugging.** ECOOP 2019 (https://doi.org/10.4230/LIPIcs.ECOOP.2019.27 , M) explored all non-deterministic executions of actor programs. Follow-ups (V), all on the WARDuino WebAssembly VM on STM32 microcontrollers: concolic multiverse debugging (DEBT 2024, https://conf.researchr.org/details/issta-ecoop-2024/debt-2024-papers/2/Concolic-Multiverse-Debugging); MIO, handling input/output (OOPSLA 2025, https://dl.acm.org/doi/10.1145/3763136); remote concolic multiverse debugging attacking state explosion with traces (ECOOP 2026, https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ECOOP.2026.27). Research-grade; state explosion is the named problem.
- **Hazel.** Live programming with fill-and-resume (POPL 2019, https://doi.org/10.1145/3290327 , M). ChatLSP passes hole types and typing contexts from the Hazel language server to an LLM, evaluated on MVUBench (OOPSLA 2024, https://doi.org/10.1145/3689728 , V). Research-grade.
- **HCI prototypes (M), none shipped:** Juxtapose (UIST 2008, https://doi.org/10.1145/1449715.1449732), Variolite (CHI 2017, https://doi.org/10.1145/3025453.3025626), Sketch-n-Sketch (PLDI 2016, https://doi.org/10.1145/2908080.2908103).
- **Unison (M).** Content-addressed code makes variants cheap to keep side by side; no candidate search.
- **Shipped (V): Cursor 2.0 (Oct 2025).** Up to eight agents in parallel on git worktrees or remote machines, outputs compared side by side (https://sdtimes.com/ai/cursor-2-0-enables-eight-agents-to-work-in-parallel-without-interfering-with-each-other/ , https://www.techzine.eu/news/devops/135916/cursor-2-0-introduces-parallel-agents-and-new-model/). Also shipped: Lean's `first_par`; Isabelle's Sledgehammer running several provers concurrently (M).
- **Assessment.** Forked exploration has shipped at two granularities only: whole-filesystem forks of LLM candidates with no proof filter and no shared checked context; and prover portfolios where the first success wins and the rest are discarded. No system found holds forks as checkpoint segments over one shared typed graph. "SpaceTime Programming: Live and Omniscient Exploration of Code and Execution" (2026, https://arxiv.org/abs/2603.18735) surfaced in search; not read.

## 3. Superoptimization and search-based code generation

- **Equality saturation (M).** egg (POPL 2021, https://doi.org/10.1145/3434304), Ruler and egglog are research infrastructure with real users. Cranelift's acyclic e-graph mid-end ships in Wasmtime but deliberately does not run full saturation.
- **Extraction hardness (V).** An OOPSLA 2024 distinguished paper shows extraction is NP-hard and "hard to approximate within any constant ratio"; its treewidth-parameterized algorithm extracts optimally for treewidth ≤ 10 in a fraction of ILP's time (https://dl.acm.org/doi/10.1145/3689801). See also E-Graphs as Circuits (https://arxiv.org/abs/2408.17042).
- **Effects and control flow (V).** Equality saturation for Julia IR (2025) uses ILP extraction exploiting code reuse plus "CFG skeleton relaxation" to rewrite both pure and side-effecting calls (https://arxiv.org/abs/2502.17075). E-Path (2026) runs equality saturation over instruction sequences inside a CFG (https://arxiv.org/abs/2605.28694). LLM-guided strategy synthesis for scalable saturation: https://arxiv.org/abs/2604.17364 (not read).
- **Search superoptimizers (M).** STOKE (ASPLOS 2013, https://doi.org/10.1145/2451116.2451150); Souper (https://arxiv.org/abs/1711.04422); AlphaDev, whose RL-found sorting routines went into LLVM libc++ (Nature 2023, https://doi.org/10.1038/s41586-023-06004-9); Halide's autoscheduler with a learned cost model.
- **Biggest unsolved problems:** optimal extraction under costs that account for shared subterms; saturation blow-up and termination; effects and control flow, today approximated; cost-model fidelity (AlphaDev and STOKE measure real latency because static costs mislead).
- **Inference on "extraction gets smaller, not cleverer":** the hardness comes from counting shared subterms once (egg's bottom-up extractor solves the additive tree-cost case in polynomial time); type-pinned representation widths shrink the menu of alternatives but do not remove the hardness sharing creates; letting the effect row decide which rewrites are legal is plausibly cleaner than CFG relaxation, and untested.

## 4. Multi-shot continuations as a search substrate

- **WebAssembly stack switching (V).** "Continuations in the current proposal are single-shot… An attempt to invoke a continuation more than once results in a trap." On multi-shot: "backtracking, probabilistic programming… exploit multi-shot continuations, but none of our critical use-cases requires multi-shot" (https://github.com/WebAssembly/stack-switching/blob/main/proposals/stack-switching/Explainer.md). Implemented in Wasmtime (https://effect-handlers.org/talks/wasmfx-waw2025.pdf).
- **OCaml, Koka, Effekt, Hansei (M).** OCaml 5 is one-shot by design (PLDI 2021, https://doi.org/10.1145/3453483.3454039); multi-shot by copying in ocaml-multicont (https://github.com/dhil/ocaml-multicont). Koka and Effekt support multi-shot resumptions. Hansei did probabilistic inference with multi-shot delimited continuations (https://okmij.org/ftp/kakuritu/).
- **Forked search over one shared heap on threads (V).** Or-parallel Prolog did exactly this in the 1980s–90s: Aurora shared the stacks and gave each worker a binding array; Muse copied the stacks per worker (Gupta et al., TOPLAS survey, https://cliplab.org/papers/partut-toplas.pdf ; SICStus 3 "Running Prolog in Parallel", https://sicstus.sics.se/sicstus/docs/3.7.1/html/sicstus_6.html ; TPLP sequel, https://arxiv.org/abs/2111.11218). Absent from mainstream Prolog today (M).
- **Assessment.** Multi-shot handlers used for search are research or niche; production runtimes (OCaml 5, Wasm) chose one-shot for performance, so a Wasm-hosted multi-shot search has to reify or copy its own continuations. No continuation-based forked search running on threads over one image found. Or-parallel Prolog is the design ancestor; its known costs (scheduling granularity, installing and uninstalling bindings on every task switch) are the cautionary literature.

## 5. "Systems explain themselves"

- **Foundations (M).** Learnable Programming (http://worrydream.com/LearnableProgramming/), Engelbart (1962), Kay & Goldberg (1977), Papert (1980): arguments and demos, not measurements.
- **Glamorous Toolkit (V).** Moldable development claims to make systems "explainable" by making custom tools cheap; its evidence is an experience-based pattern language (EuroPLoP 2024, https://arxiv.org/abs/2409.18811). No controlled study of developers found.
- **Liveness (V).** Rein et al. (Programming 2025, N=37) found live introspection tools "significantly reduced the time participants took to debug"; the hypothesis that task complexity moderates the effect was not supported, and the study may be underpowered (https://programming-journal.org/2025/9/1/). Prior experiments are few and "largely inconclusive".
- **Rust ownership (V).** Learners "could not connect Rust's static and dynamic semantics"; a visualization of the permission model raised Ownership Inventory scores by 9% on average, and readers interpreted the diagrams with 72% accuracy (OOPSLA 2023, https://dl.acm.org/doi/10.1145/3622841 ; CACM https://cacm.acm.org/research-highlights/a-grounded-conceptual-model-for-ownership-types-in-rust/).
- **Assessment.** Explanation surfaces ship (Lean's InfoView, Glamorous Toolkit, Aquascope). Measured gains are real but modest and short-horizon. Nobody measures whether the environment teaches what completes the program. Inference: the Rust result is a direct warning for "the question beats the guess"; "consumed or borrowed?" is exactly the kind of question learners measurably fail to reason about.

## 6. The annotation gradient

- **Theory (mixed).** Gradual typing (Siek & Taha 2006, M); gradual verification (VMCAI 2018, https://doi.org/10.1007/978-3-319-73721-8_2 , M); gradual effects (ICFP 2014, https://doi.org/10.1145/2628136.2628149 , M).
- **Gradual C0 (V).** Symbolic execution over imprecise specifications cuts run-time overhead by 7.1–40.2% versus fully dynamic checking (TOPLAS / POPL 2025, https://dl.acm.org/doi/10.1145/3704808).
- **Shipped "more annotation, more guarantee" ladders (M):** TypeScript's `strict` flags, Liquid Haskell, Dafny, Rust.
- No tool found tells developers which annotation unlocks which capability, and no study measures whether such guidance helps. **Assessment.** "More annotation, more proof" is mature; a proactive gradient that suggests annotations by the capability they unlock is unoccupied and unmeasured.

## 7. Systems that combine several capabilities

| System | Search / propose | Proof | Live exploration | Explanation at cursor | Codegen |
|---|---|---|---|---|---|
| Lean 4 | yes: exact?, aesop, grind, try?/first_par, Canonical | yes | partial: incremental checking, no forked variants | yes: InfoView and widgets | yes (new compiler) |
| Hazel | LLM only, via ChatLSP | no | yes: fill-and-resume | yes: hole types and error marking | no (interpreter) |
| Isabelle/jEdit | Sledgehammer portfolio | yes | no | yes: continuous checking | yes: exports to SML, OCaml, Haskell, Scala |
| Unison | no | no | cheap variants | partial | its own runtime |
| Glamorous Toolkit | no | no | live objects | yes: moldable views | Pharo VM |
| Cursor 2.0 | LLM | no | parallel worktrees | no | the host toolchain |

None has effect rows with negation, inferred ownership as a guarantee the user sees, and questions derived from diverging derivations. Lean comes closest, covering four of the five columns.

---

## Capability in the vision → closest existing system → status

| Capability | Closest system | Status |
|---|---|---|
| Medium fills typed holes without an LLM | Lean exact?/try?/grind, Agda Mimer, Canonical | Shipped for proof goals; research for general programs; Wingman abandoned |
| Proof prunes candidates at every step | Synquid; type-constrained decoding | Research |
| Joint pruning by effect absence + ownership + refinements | — | None found |
| A tie triggers one separating question | Oracle-guided distinguishing inputs; PBE disambiguation | Research, behavioural questions only; derivation-level: none |
| Parallel forked candidates | Cursor 2.0; Lean first_par; Sledgehammer | Shipped as LLM or filesystem forks and as portfolios |
| Forks as trail segments over one shared image, on threads | Or-parallel Prolog | Historically shipped, then abandoned; none for program candidates |
| Multi-shot continuations as the fork mechanism | Koka, Effekt, multicont, Hansei | Research/niche; Wasm is one-shot |
| The compiler chooses the code form by search | Cranelift e-graphs, Halide autoscheduler, AlphaDev | Shipped piecemeal |
| Effect-aware optimal extraction | Julia equality saturation, E-Path | Research; optimal extraction is NP-hard |
| Live truth at the cursor | Lean InfoView, Hazel, Glamorous Toolkit, Aquascope | Shipped in niches; modest measured gains |
| Proactive annotation gradient | Gradual typing and verification | Theory shipped; proactive guidance: none |
| All five in one medium | Lean 4 | None |

## What is genuinely unoccupied

Nobody combines four things: (a) a general-purpose language whose holes are filled by search pruned jointly by types, effect rows with negation, ownership and refinements; (b) ties resolved by a question taken from where the candidate derivations diverge, rather than by a distinguishing input or a model's ranking; (c) candidates held as rollback segments over one shared, checked graph on several threads, rather than as worktrees or discarded portfolio members; (d) the same graph driving effect-aware extraction for codegen and the explanation at the cursor. Each piece has an ancestor: Synquid for (a) minus effects, oracle-guided synthesis for (b) at the behavioural level, or-parallel Prolog for (c), and Lean for (d) minus effects. The combination is unclaimed, and two pieces most of all: effect absence as a pruning signal, and questions at the derivation level. A proactive annotation gradient is also unclaimed.

The defensible version is not "no model needed", because the measurements run against it. It is "the medium owns the candidate space and the verdict; any ranker plugs in".

## What evidence the vision would need

1. **A next-move benchmark.** Cut holes from real commits. Report the rates of unique survivor, tie and no survivor, plus top-1 accuracy and p50/p95 latency. Compare against an LLM and against an LLM with type-constrained decoding, given the same context.
2. **Question quality.** Per tie, count the questions asked and the percentage answered correctly (include novices), and measure time to the intended program against picking from a list. Controlled, N≥30.
3. **Fork scaling.** Speedup at 1, 2, 4 and 8 threads, bytes per fork, and whether results are identical across thread counts.
4. **Extraction.** Optimality gap against ILP on real functions with effects, and the compile time it costs.
5. **Teaching.** Pre/post concept-inventory gains attributable to the cursor's explanations.
