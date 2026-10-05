# Research report: the instruction layer of a long-running project built with Claude Code

*One of three web-research passes commissioned by the 2026-09-25 process audit
(`docs/PROCESS-AUDIT-2026-09-25.md`). Sources fetched 2026-09-25. Evidence
tags: **[Doc]** vendor documentation (policy or claims, usually without
published data) · **[Meas]** measured study · **[Obs]** practitioner
observation · **[Inf]** the researcher's inference. "Not re-fetched" means it
was cited from memory of the primary source and not opened this session.*

**Bottom line.** Every vendor source and every measured study found points the
same way. Instruction files work best when they are short, specific and in
force every session. Whatever can be checked mechanically belongs in hooks and
gates, not prose. Accumulated history and live status belong outside the
always-loaded context.

The premise that "context cost is not a constraint" gets the money right and
the attention wrong. A static 70k-token prefix is cheap once cached. But
Anthropic's documentation says plainly that longer files *reduce adherence*.
Also, the two models this project alternates between get opposite official
guidance on the verification instructions the project relies on most.

---

## 1. Official and community guidance on CLAUDE.md / AGENTS.md

**Anthropic, Claude Code documentation (current)**
- **[Doc] Size target.** *"target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."* Files up to 4 MiB load in full, and *"Shorter files produce better adherence."* (https://code.claude.com/docs/en/memory)
- **[Doc] @-imports do not save context.** *"imported files still load and enter the context window at launch"* and *"Splitting into @path imports helps organization but doesn't reduce context."* (same page)
  - **[Inf]** CLAUDE.md @-imports PLAN.md and SYNTAX.md, so 738 + 2,603 + 2,233 = 5,574 lines load at launch. Per file, that is 3.7×, 13× and 11× over the 200-line target. Nothing is truncated, so the issue is adherence, not truncation.
- **[Doc] Advisory, not enforced.** *"Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead."* CLAUDE.md is *"delivered as a user message after the system prompt… no guarantee of strict compliance, especially for vague or conflicting instructions."*
- **[Doc] Contradictions.** *"if two rules contradict each other, Claude may pick one arbitrarily."*
- **[Doc] What belongs in the file.** *"Keep it to facts Claude should hold in every session… If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a skill or a path-scoped rule."* The exclude list names *"Anything Claude can figure out by reading code," "Information that changes frequently,"* and *"Long explanations or tutorials."* (https://code.claude.com/docs/en/best-practices)
- **[Doc] Pruning test.** *"For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"*
- **[Doc] Diagnostic.** *"If Claude keeps doing something you don't want despite having a rule against it, the file is probably too long and the rule is getting lost."*
- **[Doc] Named failure pattern.** *"The over-specified CLAUDE.md… Claude ignores half of it… Fix: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it or convert it to a hook."*
- **[Doc] Emphasis.** Add "IMPORTANT" *"to that line alone. If you emphasize many lines, none of them stands out."*
- **[Doc] Mechanics worth using:** rules with `paths:` frontmatter in `.claude/rules/` load only when matching files are read; skills load on demand; block-level HTML comments are stripped before injection, so maintainer notes cost zero tokens; `/doctor` proposes cuts of content Claude can derive from the codebase; the auto-memory index is capped at 200 lines / 25KB, and the harness prompts Claude to *"merge or drop stale entries."*

**Anthropic, "Effective context engineering for AI agents" (Sept 29, 2025)** (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- **[Doc]** Describes context as an *"attention budget"* with *"n² pairwise relationships for n tokens."* The goal is *"the smallest possible set of high-signal tokens."*
- **[Doc]** *"teams will often stuff a laundry list of edge cases into a prompt… We do not recommend this."* Also: *"minimal does not necessarily mean short."*
- **[Doc]** The recommended hybrid: *"CLAUDE.md files are naively dropped into context up front, while primitives like glob and grep allow it to navigate"*, meaning just-in-time retrieval for everything else.

**Community**
- **[Obs] HumanLayer, "Writing a good CLAUDE.md" (Nov 25, 2025)** (https://www.humanlayer.dev/blog/writing-a-good-claude-md): *"< 300 lines is best, and shorter is even better."* Their own root file is under 60 lines. *"Never send an LLM to do a linter's job."* *"Prefer pointers to copies."* Progressive disclosure through an `agent_docs/` folder. Their "~150–200 instructions" limit is their own reading of IFScale.
- **[Obs] Manus (Yichao Ji, July 18, 2025)** (https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus): keep the prompt prefix stable for KV-cache hits (**[Inf]** so a static 70k prefix is cheap in dollars; the waived cost is not the one that matters); use the file system as "restorable" memory; recite goals in a todo.md to counter drift over ~50 tool calls; "Don't get few-shotted": uniform, repetitive context pushes agents into repetitive rhythms.

**Measured studies of context files.** None tested a file anywhere near 70k tokens.
- **[Meas] ETH Zurich, Gloaguen et al. (Feb 2026; v2 June 2026)**, agents including Claude Code (https://arxiv.org/abs/2602.11988): *"providing context files does not generally improve task success rates, while increasing inference cost by over 20% on average."* *"instructions in the context files are well followed… repository overviews… are not helpful."* Context files are useful *"for specifying non-standard coding practices."*
- **[Meas] Lulla et al. (Jan 2026)**, 10 repos and 124 PRs with Codex and Claude Code (https://arxiv.org/abs/2601.20404): an AGENTS.md was associated with 28.64% lower median runtime and 16.58% fewer output tokens, with comparable completion.
- **[Meas, small n] Khatri (July 2026)**, 17 tasks and 288 runs with Claude Code and Codex (https://arxiv.org/abs/2607.27250): context strategy *"does not measurably move correctness"* (bounded at ≤10–15 percentage points). Failures came from implementation skill, not missing repository knowledge.
- **[Inf]** Short files that encode non-standard, non-derivable conventions buy efficiency; bulk and overviews do not buy correctness; a novel language surface (SYNTAX.md) is the strongest legitimate case for context, but as on-demand reference, not always-on.

## 2. Instruction count and prompt length

- **[Meas] IFScale (Jaroslawicz et al., July 2025)** (https://arxiv.org/abs/2507.11538). Up to 500 keyword-inclusion instructions; the best model reached 68% at 500.

  | Model | 50 | 100 | 250 | 500 |
  |---|---|---|---|---|
  | Claude Opus 4 | 100% | 94.6% | 67.9% | 44.6% |
  | Claude Sonnet 4 | 98% | 94.4% | 77.2% | 42.9% |

  Three decay shapes: threshold, linear, exponential. Bias toward earlier instructions peaks around 150–200 instructions. As density rises, errors become overwhelmingly omissions, not modifications. Putting important instructions first *"becomes a less effective strategy once extreme densities are reached."* Caveats: trivial instructions, a report-writing task, and older-generation models.
- **[Meas] Harada et al., EMNLP 2025 Findings** (https://arxiv.org/abs/2509.21051). Two benchmarks: ManyIFEval (text, up to 10 instructions) and StyleMBPP (code, up to 6 style instructions). *"performance consistently degrades as the number of instructions increases."* A logistic regression on instruction count alone predicts success within about 10%. **[Inf]** Instruction count is a first-order predictor, including for code.
- **[Meas] Chroma, "Context Rot" (July 14, 2025)**, 18 models including Claude Opus 4 and Sonnet 4 (https://www.trychroma.com/research/context-rot). Performance degrades with length even on simple tasks, and faster when the target and question are less semantically similar. Distractors hurt, and not uniformly. LongMemEval: focused input (~300 tokens) beat full input (~113k tokens) significantly in every model family, with semantic content held constant. Claude models tend to abstain rather than hallucinate.
- **[Meas] NoLiMa (ICML 2025; abstract, not re-fetched)** (https://arxiv.org/abs/2502.05167). With lexical overlap between question and target removed, at 32K tokens 10 of 12 models fell below 50% of their short-context baselines; GPT-4o went from 99.3% to 69.7%. **[Inf]** Abstract "laws" that must be matched to code by meaning, not keywords, are exactly this regime.
- **[Meas] "Lost in the Middle" (TACL 2024; not re-fetched)** (https://arxiv.org/abs/2307.03172): a U-shaped position curve. Newer models show less of it, but IFScale still finds bias toward early instructions.
- **[Doc] Counterweight from Anthropic.** Opus 5: *"instruction following, tool calling, and reasoning stay consistent throughout the [1M] window."* Fable 5: *"strong instruction retention across long, complex tasks."* No numbers are published for either. (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5 , https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5) **[Inf]** 70k tokens is about 7% of a 1M window, so raw length is probably not the binding limit for these models. Instruction count, conflicts and distractor load are, and no public benchmark tests Opus 5 or Fable 5 at hundreds of simultaneous behavioral rules.
- **[Meas, 2026] ContextEcho (May 2026)** (https://arxiv.org/abs/2605.24279). Measures persona drift across 23 models, replaying three real Claude Code sessions of 3,746–9,716 turns. *"A single-shot anchor restores the trained register."* **[Inf]** This favors short anchors re-injected mid-session over one huge preamble. Transfer from tone and identity to coding rules is unproven.
- **Over-specification and aggressive wording** (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices): **[Doc]** Opus 4.5/4.6 are *"more responsive to the system prompt… may now overtrigger. The fix is to dial back any aggressive language."* The example given replaces *"CRITICAL: You MUST use this tool when…"* with *"Use this tool when…"*. **[Doc]** *"Tell Claude what to do instead of what not to do."* **[Doc] Fable 5:** *"Skills developed for prior models are often too prescriptive for Claude Fable 5 and can degrade output quality. Review and consider removing older instructions if default performance is better."*

## 3. Mechanism vs prose

- **[Doc] Hooks are the documented home for must-always rules.** *"Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens."* *"Use hooks for actions that must happen every time with zero exceptions."* *"If the instruction is something that must run at a specific point… write it as a hook instead."*
- **[Doc] Checks close the loop.** *"Claude stops when the work looks done. Without a check it can run, 'looks done' is the only signal available."* Gate options: in the prompt, a `/goal` evaluator, a Stop hook, or a fresh-context verifier. A Stop hook blocks the end of a turn, but *"Claude Code overrides the hook and ends the turn after 8 consecutive blocks."*
- **[Doc, not re-fetched] "Building effective agents" (Dec 2024):** *"we actually spent more time optimizing our tools than the overall prompt"*, and *"Poka-yoke your tools."* (https://www.anthropic.com/engineering/building-effective-agents)
- **[Meas] SWE-agent (NeurIPS 2024)** (https://arxiv.org/html/2405.15793). On SWE-bench Lite with GPT-4 Turbo: edit tool with a linter guardrail 18.0% resolved; without the linter 15.0%; no edit tool 10.3%. The failure mode it fixes: *"models repeatedly edit the same code snippet… introducing a syntax error."* *"careful ACI design can substantially improve LM agent performance without modifying the underlying LM's weights."*
- **[Doc] Short, targeted prose can still work.** On Fable 5, one progress-audit instruction *"nearly eliminated fabricated status reports even on tasks designed to elicit them"* in Anthropic's testing.
- **[Software-engineering analogue, not re-fetched]** Sadowski et al., "Lessons from Building Static Analysis Tools at Google" (CACM 2018): analysis results shown outside the developer's workflow were largely ignored; checks surfaced at compile or code-review time, with low effective false-positive rates, got acted on. gofmt settled style by tool rather than by guide.
- **[Inf, skeptical]** The project's "gates caught ~30, prose caught 0" fits all of the above, but the count is biased. Gate catches are logged; errors that prose prevented are invisible. It shows the gates work, not that the prose is inert. Only an ablation can settle the second question.

## 4. Long-running, multi-session projects: memory, decisions, lore

- **Anthropic, "Effective harnesses for long-running agents" (Nov 26, 2025)** (https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents): observed failures are trying to do everything at once, declaring the job done prematurely, and broken handoffs between sessions. The fix: an initializer agent plus a coding agent; `claude-progress.txt`, `feature_list.json` (with a `passes` field) and the git log are read at every session start. JSON was chosen because *"the model is less likely to inappropriately change or overwrite JSON files compared to Markdown files."*
- **[Doc] State management** (prompting best practices): *"Use structured formats for state data… unstructured text for progress notes… Use git for state tracking."* Prefer a fresh context window over compaction, because the models *"are extremely effective at discovering state from the local filesystem."*
- **[Doc] Memory hygiene.** Fable 5: *"Store one lesson per file with a one-line summary at the top… Don't save what the repo or chat history already records; update an existing note rather than creating a duplicate; delete notes that turn out to be wrong."* Auto memory skips *"anything it can derive from the codebase, such as architecture, file paths, or debugging fixes."*
- **[Doc] Re-litigation.** Fable 5's suggested prompt: *"Do not re-derive facts already established in the conversation, re-litigate a decision the user has already made…"* **[Inf]** The project's always-loaded "these docs are NOT authority; interrogate every claim" and "the law is alive" set the opposite knob. Combined with ~286 open named peers, that predicts the repeated re-grounding the docs themselves describe.
- **[Inf / software-engineering analogue, not re-fetched]** Nygard's Architecture Decision Records (2011) keep history in short, numbered records with a status such as accepted or superseded, and never rewrite them. The current rule lives in one place. (https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- **[Obs, from the project's own PLAN.md]** Stale always-loaded status caused real harm: one bullet said persistence was absent when it was built: *"a session reading it would have built the memcpy that already existed."* The vendor rule "exclude information that changes frequently" predicts exactly this.
- **Verification structure:** **[Doc]** the evaluator-optimizer pattern fits *"when we have clear evaluation criteria"* ("Building effective agents"). **[Doc]** *"A fresh context improves code review since Claude won't be biased toward code it just wrote."* **[Doc] Caution:** *"A reviewer prompted to find gaps will usually report some, even when the work is sound… Chasing every finding leads to over-engineering."* **[Doc]** Fable 5: *"Separate, fresh-context verifier subagents tend to outperform self-critique."*

## 5. Alternating two models

- **[Gap]** No controlled study of alternating two models on one codebase was found. ContextEcho measures drift across models, not alternation. Posts warning about switching mid-conversation are anecdotal.
- **[Doc] Anthropic's per-model guidance diverges on exactly the knobs this project leans on.**
  - **Opus 5:** it *"verifies its own work without being told to. If your prompt contains explicit verification instructions ('include a final verification step…,' 'use a subagent to verify'), remove them: instructions like these cause over-verification… removing them reduces wasted tokens with no loss in quality."* Its sample delegation guidance says *"do not use subagents to verify or double-check your own work."* It delegates to subagents more readily than earlier models. Written deliverables *"are often longer than on prior models."*
  - **Fable 5:** *"steer most behaviors with a brief instruction rather than enumerating each behavior by name."* Prompts written for earlier models are often "too prescriptive." *"Make self-verification explicit in long-run prompts,"* using fresh-context verifier subagents. Instructions to reproduce its reasoning in the response can trigger `reasoning_extraction` refusals. In long runs it can drift into *"dense arrow-chain shorthand… labels you made up earlier."*
  - **General:** *"Where a technique names a specific model, treat it as measured on that model and re-check it against your own evals before applying it to another."*
- **[Inf]** One static corpus written in one voice cannot be right for both models. Its verification mandates are what the Opus 5 guide says to delete. Its enumerated drift catalog is what the Fable 5 guide says is unnecessary. Opus 5's longer documents and Fable 5's coined labels are plausible (untested) contributors to the docs' growth and their private vocabulary.

---

## Top 12 recommendations for this project's instruction layer

1. **Cap the always-loaded core.** Aim for 200–300 lines (about 3k tokens) and roughly 50–100 distinct imperatives. Enforce it with a line/token ratchet in CI.
2. **Remove `@PLAN.md` and `@docs/SYNTAX.md` from CLAUDE.md.** Replace them with one-line pointers of the form "read X when doing Y."
3. **Split SYNTAX.md.** Write a surface card of about 150 lines (tokens, precedence, canonical forms, rejected forms) as a `.claude/rules/` file with `paths: ["**/*.mn"]`. Keep the full spec for on-demand reading, and move its dated status and defect narratives out.
4. **Turn every mechanically checkable rule into a hook or gate, then delete its prose.** PreToolUse for "never do X"; PostToolUse for audits; a Stop hook for "done means the board is green".
5. **Rewrite the remaining prose.** Each rule positive, specific and verifiable, with a one-clause reason. Emphasis on at most three lines; retire ALL-CAPS as a register.
6. **Separate law from lore.** Each rule states only the current behavior; its originating incident goes into an ADR-style decision record or an HTML comment (stripped before injection).
7. **Keep live status out of always-loaded prose.** At session start, run the board, read a structured state file and the git log.
8. **Settle decisions explicitly.** An index of decisions with a status; reopening one requires the user or a dedicated skill, not a standing "interrogate everything". Remove internal contradictions such as "completeness wins" vs "the tightest form."
9. **Add short per-model addenda (about 20 lines each).** Opus 5: remove explicit verify and subagent-verify mandates; document-length calibration. Fable 5: brief steering, a fresh-context verifier at intervals, a progress-claim audit, no "reproduce your reasoning" instructions.
10. **Adopt a memory discipline.** One lesson per file with a one-line summary, an index of 200 lines or fewer, wrong notes deleted, nothing stored that the repo or git already records.
11. **Measure before and after with an ablation.** 10–20 scripted tasks, including past drift incidents, under the current corpus and under a slim core plus hooks, on both models. Count gate violations, rule violations, cost and time.
12. **Budget verification.** Deterministic gates as the primary verifier; fresh-context adversarial review only for high-stakes landings, scoped to correctness and requirements; re-inject a short anchor mid-session through a hook rather than relying on the preamble.
