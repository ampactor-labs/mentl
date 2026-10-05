# Research report: process lessons for a solo, AI-assisted language project

*One of three web-research passes commissioned by the 2026-09-25 process audit
(`docs/PROCESS-AUDIT-2026-09-25.md`). Tags: **[V]** read this session (fetched
page or search snippet, snippets marked); **[M]** canonical source cited from
prior knowledge without re-fetching (check before quoting). The researcher's
own inference is labelled "Inference:". 21 searches and fetches.*

---

## 1. Language case studies

**Zig**
- [M] The design philosophy is "Zig Zen": about 13 one-line maxims printed by `zig zen` ("Incremental improvements.", "Avoid local maximums.", "Only one obvious way to do things.", "Together we serve the users."). The entire philosophy fits on one screen. https://ziglang.org/documentation/master/#Zen
- [M] Self-hosting became the default in 0.10 (2022). "Goodbye to the C++ implementation of Zig" (Dec 2022) replaced the C++ stage with a WASI build of the compiler committed to the repo. https://ziglang.org/news/goodbye-cpp/ While self-hosting was underway, outside production programs (Bun, TigerBeetle) were already being written in Zig, so the compiler was never the only workload.
- [M] When a feature couldn't keep up, it was cut rather than allowed to hold the release: async/await regressed in the self-hosted compiler, and 0.11 shipped without it. (Not re-verified this session.)

**Roc**
- [V] Why they rewrote: "the root of our problems was architectural across several compiler phases, and fixing it would require rewriting most of the compiler." The blocker was lambda-set resolution. https://www.developersdigest.tech/blog/roc-rust-to-zig-rewrite-feldman (secondary summary; its numbers: 487 days; ~300K lines of Rust became ~464K lines of Zig; incremental rebuilds from 3.4 s to 35 ms).
- [V] GOTO session with Feldman and Vakil, https://gotopia.tech/sessions/4107/roc-and-zig-a-compiler-rewrite-story : AI's role moved from "mechanical test-porting grunt work" to "genuine architectural collaboration"; "guardrails don't live in prompts ("never do this" gets ignored constantly), they live in the code itself — invariants and automated feedback loops that catch the AI when it strays" (the session page's summary, possibly paraphrasing Feldman). Roc v1 is targeted "before end of 2026".
- [M] Roc's unit of design is the "platform" (basic-cli, basic-webserver). Apps are written against real hosts from the start. https://www.roc-lang.org/

**Rust**
- [M] Graydon Hoare's "Not Rocket Science Rule": "automatically maintain a repository of code that always passes all the tests" (implemented as bors). https://graydon2.dreamwidth.org/1597.html
- [M] Rust reached 1.0 by treating stability as the deliverable: six-week release trains, nightly/beta/stable channels, unfinished features gated to nightly instead of finished. https://blog.rust-lang.org/2014/10/30/Stability.html
- [V] Hoare's 2023 retrospective (https://graydon2.dreamwidth.org/307291.html , summarized at https://mjtsai.com/blog/2023/06/08/the-rust-i-wanted-had-no-future/): his priorities "are broadly not the revealed priorities of the community that's developed around the language"; he is glad he wasn't BDFL.
- [M] The flagship program: Servo was built alongside pre-1.0 Rust ("Engineering the Servo Web Browser Engine using Rust", ICSE-SEIP 2016). https://arxiv.org/abs/1505.07383
- [M] Documentation shape: three documents for three kinds of truth. Current truth: the Reference (https://doc.rust-lang.org/reference/). Decision history: the RFC book (https://rust-lang.github.io/rfcs/). In-flight work: the Unstable Book (https://doc.rust-lang.org/unstable-book/).

**Unison**
- [V] Unison 1.0 was announced more than ten years after the 2014 project post. https://www.unison-lang.org/unison-1-0/ , https://pchiusano.github.io/2014-09-14/unison.html
- [V; third-party opinion] One critic blames slow adoption on scope: instead of making content-addressed code work with existing source control and IDEs, Unison also took on distributed computing. https://renato.athaydes.com/posts/unison-revolution.html
- Inference: its flagship is the company's own product, Unison Cloud.

**Koka and Effekt**
- [M] Koka's designer wrote a real application in it: Madoko, a Markdown tool for writing papers. https://github.com/koka-lang/madoko Koka's compiler is written in Haskell, so Koka is not self-hosted.
- Effekt's dogfooding was not verified this session.

**Gleam**
- [V] v1.0.0 shipped on 4 March 2024 (https://gleam.run/news/gleam-version-1/): "small surface area, making it possible to learn in an afternoon"; "a strong desire to have only one way of doing things"; "productivity and developer experience is a first class concern".
- [V, from titles] News posts after 1.0 are mostly about tooling ("A field day for Gleam's language server", "Improved performance and publishing"). https://gleam.run/news/ Inference: once the language froze, effort moved to the experience of writing programs in it.

**Elm**
- [V, snippet] Luke Plant's "Why I'm leaving Elm" criticises the closed process and 0.19's breaking changes, which treated existing projects as "collateral damage". https://lukeplant.me.uk/blog/posts/why-im-leaving-elm/
- [V] Evan Czaplicki, "The Hard Parts of Open Source" (Strange Loop 2018). https://thestrangeloop.com/2018/the-hard-parts-of-open-source.html
- [M] The last compiler release was 0.19.1, October 2019. Inference: when one person holds the quality bar and there is no public release cadence, years can pass without a release.

**Lean 4** (from de Moura's FLoC 2026 talk unless noted: https://leodemoura.github.io/static/floc26/)
- [V] Timeline: rebuilt in Lean starting April 2018; compiled itself in October 2020; first pre-release January 2021, when Mathlib was already about 450K lines; 4.0 shipped September 2023 with about 1.1M lines of Mathlib ported; by July 2026 Mathlib has 2.4M+ lines and 750+ contributors.
- [V] The Lean FRO (July 2023, 20 engineers) runs Lean "as a startup": 32 releases and 9,000+ merged PRs; yearly public roadmaps of concrete deliverables (https://lean-lang.org/fro/roadmap/y3/), e.g. "reliable benchmarking, testing, and profiling infrastructure for Lean and Mathlib" and "Close the usability gap: formatter, clearer error messages, IDE polish".
- [V] Progress is measured on the flagship program: a server called "Radar" records build instructions for every Mathlib commit. From January 2025 to July 2026, Mathlib grew 66% while instructions fell 28%.
- [V] How they split work with AI: "Specifications written by hand. Implementations and proofs written by AI." They run three independent kernels plus a sandboxed re-checker ("Comparator"), because "Reinforcement learning is just so good at finding backdoors". Production deployments: Cedar and SampCert (AWS), SymCrypt (Microsoft), and a roughly 500K-line compiler for AWS's Trainium chips.

**Eve and Darklang**
- Eve: no primary post-mortem found within budget; do not reuse circulated quotes without checking.
- [V, snippets] Darklang's 2022 status update: while filling product gaps they "kept running into foundational product problems that couldn't be simply patched in a few months". The team was laid off to fund fundamental changes. https://blog.darklang.com/an-overdue-status-update/ A later wind-down post: an "8-year-old product with no traction was not going to attract new investment." https://blog.darklang.com/

**Jai and Odin**
- [M] Odin is used in production in JangaFX's commercial tools (EmberGen). https://odin-lang.org/ Jai has been developed alongside Jonathan Blow's own engine and game, in closed beta. Both are designed against a shipped product, not against their own compiler.

---

## 2. "A language is shaped by the programs written in it"

- **[V] The strongest documented statement is in the Go FAQ:** "Not being self-hosting from the beginning allowed Go's design to concentrate on its original use case, which was networked servers. Had we decided Go should compile itself early on, we might have ended up with a language targeted more for compiler construction, which is a worthy goal but not the one we had initially." https://go.dev/doc/faq
- [V] Mojo's roadmap: "Phase 1 … leans into its initial killer application: writing high-performance kernels for GPUs and CPUs." https://www.modular.com/blog/the-path-to-mojo-1-0 (snippet)
- [V] Lean 4 was judged against an external workload (Mathlib, 450K lines) from its first pre-release, and still measures itself against Mathlib (Radar).
- [V] Anthropic's C-compiler experiment made real programs the oracle (https://www.anthropic.com/engineering/building-c-compiler): once the compiler passed 99% of test suites, each agent was given a real open-source project to compile (Linux 6.9, QEMU, FFmpeg, SQLite, Postgres, Redis); GCC was the reference.
- [V] Hoare: the shipped language followed the community's revealed priorities, not the founder's.
- **Counter-evidence.** Self-hosting is not the failure in itself: Lean 4, Zig and Go all self-host. Each had an outside workload first or in parallel.
- No documented literature exists under the name "second-program problem". The closest documented ideas are Brooks's "second-system effect" and Gall's law.

---

## 3. Process and organisational research

**(a) Ossification and overdesign**
- [M] Brooks, *The Mythical Man-Month* (1975), ch. 5: the second system is "the most dangerous system a man ever designs", over-designed with the ideas "cautiously sidetracked on the first one."
- [M] Gall, *Systemantics* (1975): "A complex system that works is invariably found to have evolved from a simple system that worked."

**(b) Ratchet-style CI** (Google items from https://abseil.io/resources/swe-book/html/ch20.html)
- [V] Developers ignore compiler warnings, so Google's rule is: "We either enable a compiler check as an error (and break the build) or don't show it in compiler output."
- [V] Before a check becomes an error, every existing instance is fixed first, using automated fixes. There is no standing baseline.
- [V] Checks shown in code review must have under 10% "effective false positives" (any report the developer doesn't act on). The platform runs just under 5%.
- [V] Analyzer authors are held to account: a "Not useful" button files a bug against the analyzer, and analyzers with high rates are disabled. "Static analysis is only as good as the workflow it's integrated into and the trust developers place in it."
- [V, page exists] qntm's "Ratchets in software development": a count stored in CI that may only fall. https://qntm.org/ratchet
- [V, issue titles only; anecdotal] Public issues in agent-heavy repos document two ways count ratchets create churn: a fix in one place can hide a new violation elsewhere ("ratchet on error identities (multiset), not counts": https://github.com/ASolidBPlus/claude-mesh/issues/80); whole-tree counts blame a PR for other people's changes ("evaluate count ratchets against the PR's authored diff, not the whole tree": https://github.com/rjmurillo/ai-agents/issues/5065).
- [V] Carlini: "Claude started to frequently break existing functionality each time it implemented a new feature." The fix was a CI pipeline with "stricter enforcement … so that new commits can't break existing code."

**(c) Separating current truth from history**
- [M] Nygard's Architecture Decision Records (2011): one short record per decision (Title, Context, Decision, Status, Consequences); a reversed decision is kept but marked "superseded", never rewritten. https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- [M] Rust's three-document split (Reference / RFC book / Unstable Book) applies the same idea at language scale.
- [V] In the C-compiler experiment, agents kept "extensive READMEs and progress files that should be updated frequently with the current status" so new agents could orient themselves; logs were built to avoid filling the model's context: print "ERROR and put the reason on the same line so grep will find it."

**(d) Unbounded criteria**
- [M] Herbert Simon (1956), satisficing: pick the first option that meets an aspiration level, and adjust the level with experience. *Psychological Review* 63(2).
- [V] Sirois, Molnar and Hirsch (2017) meta-analysis (https://onlinelibrary.wiley.com/doi/abs/10.1002/per.2098): procrastination correlates positively with perfectionistic *concerns* (r = .23) and negatively with perfectionistic *strivings* (r = −.22). Inference: high standards are not the risk; fear and a sense of falling short are.
- [V] Amabile and Kramer: about 12,000 daily diaries from 238 people in 7 companies; small, regular progress on meaningful work drives engagement and creativity. https://www.amanet.org/articles/the-worth-of-small-wins-teresa-amabile-and-steven-kramer-on-the-progress-principle/
- [M] The Scrum Guide's Definition of Done: "done" is a formal, pre-declared, checkable state. https://scrumguides.org/scrum-guide.html
- [V, snippet] Modular calls Mojo's 1.0 "a forcing function for focus and prioritization."

---

## 4. Language design in the AI era, as a process question

- **Mojo [V]:** killer app first, with explicit exclusions from 1.0: "a robust async programming model and support for private members." Secondary reports: Mojo 1.0.0 shipped on 11 Aug 2026 and the compiler was open-sourced on 18 Aug 2026.
- **MoonBit [V that the pages exist; content M]:** positions itself as an "AI-native" toolchain; its LLM4Code 2024 paper describes the compiler steering the model's token sampling; its 1.0 roadmap preview is a list of concrete features plus a standard-library review. https://www.moonbitlang.com/blog/roadmap , https://www.moonbitlang.com/blog/moonbit-ai , https://dl.acm.org/doi/10.1145/3643795.3648376
- **Bend/HVM:** no roadmap document found within budget.
- **Carlini's C compiler [V]** (https://www.anthropic.com/engineering/building-c-compiler): "it's important that the task verifier is nearly perfect, otherwise Claude will solve the wrong problem." "Time blindness": the model will "happily spend hours running tests instead of making progress"; the fix was a `--fast` mode running a 1% or 10% sample. Scale: about 2,000 sessions and about $20K. Result: output "less efficient than GCC with all optimizations disabled", and the project "nearly reached the limits of Opus's abilities." Agents had specialised roles, including "design critique", "documentation" and "coalescing duplicate code".
- **Feldman [V]:** guardrails belong in code invariants, not prompts (see Roc above).
- **Steve Klabnik, Rue [V]** (https://steveklabnik.com/writing/thirteen-years-of-rust-and-the-birth-of-rue/): his first attempt was a mess and he had to "start over"; the result is still "very janky", with "codegen bugs" and "missing basic features". Press coverage: about 100K lines in 11 days. https://www.theregister.com/2026/01/03/claude_copilot_rue_steve_klabnik/
- **IFScale [V]** (https://arxiv.org/pdf/2507.11538): with 500 simultaneous instructions, the best frontier models managed 68% adherence; degradation follows a threshold, linear, or exponential shape depending on the model.
- [M] Anthropic's Claude Code best-practices post: "A common mistake is adding extensive content without iterating on its effectiveness." https://www.anthropic.com/engineering/claude-code-best-practices

---

## Top 12 transferable lessons for this project

1. **Write the second program before doing more compiler restructuring.** Go's designers credit not self-hosting early with keeping Go aimed at servers. Lean 4 was judged against 450K lines of Mathlib from its first pre-release. A corpus of only the compiler selects for compiler-writing features.
2. **Choose a flagship program that tests the thesis.** Lean already occupies "AI writes, the kernel checks", with production deployments. A "verification substrate for machine-generated code" claim needs a non-compiler program where effect negation and refinements catch real defects, not more design documents.
3. **Measure progress on that program, not on the compiler's self-image.** Lean's Radar tracks cost per Mathlib commit. Carlini moved from test-suite pass rate to building real projects. Self-compile checks and census counts measure internal consistency, not usefulness.
4. **Turn rules into gates, then delete the prose.** IFScale shows adherence decaying as instruction count grows. Feldman says "never do this" in prompts gets ignored while invariants hold. A 53k-word instruction corpus is far beyond the measured range: give it a budget and treat growth as a regression.
5. **Make ratchets temporary and key them on identity, not counts.** Google cleans up first, then makes the check an error; it keeps no standing baselines, requires under 10% effective false positives, and holds analyzer authors accountable. Each ratchet should have an end date by which it becomes a hard error or is deleted.
6. **Keep exactly one non-negotiable gate: main is always green.** The Not Rocket Science Rule; Carlini's agents regressed features constantly until CI enforced it. Any check with meaningful false positives should be advisory.
7. **Separate current truth from history by construction.** Nygard-style immutable decision records marked "superseded", and Rust's Reference/RFC/Unstable split. Keep current-truth documents short and rewrite them in place. Reopen a decision only through a new record; this is also what stops an agent re-litigating it.
8. **Replace "ultimate" with a dated Definition of Done.** Lean FRO publishes yearly deliverables, Modular called Mojo's 1.0 a "forcing function", and Simon's satisficing is the underlying model. Define 1.0 as checkable capabilities on the flagship program, with explicit exclusions.
9. **Ship by fencing unfinished work off, not by finishing it.** Rust 1.0 used feature gates, Zig shipped 0.11 without async, Mojo deferred async and private members. Frontier items can be marked unstable instead of blocking a usable release.
10. **Treat the phase after self-hosting as second-system risk.** Brooks and Gall both warn about it. Darklang kept hitting "foundational problems that couldn't be simply patched". Roc's rewrite was justified by a named blocker with a measured cost and still took 487 days. Require every restructuring to name the user-visible capability it unblocks.
11. **The founder's taste is not the users' revealed priorities.** Hoare says so of Rust, and Elm shows what a closed process costs. Revealed priorities only come from programs written by someone, or for something, other than the compiler.
12. **Build in small, visible wins on a fixed cadence.** Amabile's diaries show small progress drives motivation. Sirois shows the risk is perfectionistic concerns (a sense of discrepancy), not high standards. A regular demo on the flagship program turns that feeling into measured progress.
