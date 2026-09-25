# Mentl — process audit and redesign plan (2026-09-25)

**Scope.** Morgan asked for a deep audit of the processes, protocols, routines,
laws, rules, shape and path of development so far, followed by a plan to
optimize or redesign them so the build gets a clearer picture and a more
rewarding pace. Everything below was measured on this checkout (branch
`claude/mentl-design-audit-m1mptf`, head `fc4ddd3`) in a fresh container in
which the runner was built and the wheel was run; every number comes from this
session. Field research was done by three independent web-research passes;
their findings and sources are summarized in §4 and the full reports, with
every URL, are in `docs/research/`.

**How to read this.** §0 is the answer. §1 is the evidence. §2 is the
diagnosis. §3 is what to keep. §4 is what the field says. §5 is the redesign.
§6 is the plan. The appendices hold the repeal table and the rot list. Three
ready-to-adopt drafts sit beside this file: `docs/proposals/CLAUDE.next.md`
(the replacement instruction file), `docs/proposals/MILESTONE.next.md` (M1)
and `docs/proposals/board.yml` (the CI board; every command in it passed in
this container).

---

## 0 · The answer in one screen

The language is real and unusually far along for three and a half months. The
compiler self-hosts to a byte-identical fixpoint, the negative-effect proofs
hold (absence 13/13, micros 149/149, `mentl verify` 13 bounds hold, all re-run
here), and the kernel is coherent. The feeling "the closer I get, the farther
we are" is not a mood. It is what the current instruments measure, because
the process has three structural defects:

1. **The acceptance test is unbounded.** "Ultimate, SOTA-surpassing, novel, no
   deferrals" is a direction, and it was made the pass/fail criterion of every
   commit. An unbounded criterion never passes, so every landing records a new
   gap. The residue catalog names 286 peers and 111 more exist only in code
   comments. The only thing being measured is distance to infinity, and it
   grows as the project learns.
2. **The docs are a diary loaded as a spec.** The three files read at every
   session start total 53,353 words (about 70k tokens). Most of PLAN.md and a
   good part of SYNTAX.md is the history of corrections ("this sentence used to
   say…"; 128 dated incidents in PLAN alone). Over the last five weeks the
   project wrote about four lines of English per line of code and deleted 3.5
   doc lines per 100 added. The project's own measurement says the prose
   caught zero errors the gates did not. The prose kept growing anyway.
3. **Laws accreted instead of becoming mechanisms, and the mechanisms rotted.**
   Every incident became a dated, capitalized law and none was retired. The
   mechanical layer was partly fictional: the pre-commit hook ran on zero
   commits until 2026-09-14, the IDE gate was invoked by nothing, the
   determinism leg never ran, the hooks live in a gitignored directory, and
   there is no CI. The board runs only when a person runs it.

The research adds a fourth finding that is not about process: the headline
positioning is prior art. Effect negation with complete inference and a
safety proof shipped in Flix (ICFP 2023); the nearest rival to "agent code
proven capability-safe, LLM proposes, compiler filters" is Odersky's group
in Scala 3 (2026) with published benchmarks. What is distinctive is the
conjunction in one self-hosted substrate, and it needs a demo and a benchmark
to be credible (§4.3, §5.8).

The redesign keeps the ambition and the kernel and changes the loop: a bounded,
program-shaped definition of done (a second real program and one thirty-second
demo), an always-loaded core of about 300 lines instead of 5,574 with design
and syntax pulled in on demand and zero history in any of it, decisions kept
as short records instead of re-litigated laws, one board run by CI on every
push, and a milestone cadence with visible wins. The steps are in §6.

---

## 1 · What was measured

### 1.1 The artifact

| Thing | Measure |
|---|---|
| Compiler source (`src/**/*.mn`) | 53,981 lines; 21,552 (40%) are comment lines |
| Library (`lib/**/*.mn`) | 7,265 lines |
| Programs that are not the compiler | tutorial 470 lines · dsp 1,106 · ml 146 · absence benchmark 119 |
| Test fixtures | micros 149 · frontier 197 · crown 62 · syntax 17 · others 35 |
| Gates re-run here | `verify.sh` green (micros 149/149, syntax 17/17, floors 1/1) · march: fixpoint holds (§1.5) · absence 13/13 · crown 62/0 · proof-exactness 9/0 · `mentl verify src/main.mn`: 13 bounds hold in 7.5 s |

### 1.2 The read-path (imported by `@` lines at every session start)

| File | Lines | Words | Dated incidents | "never" / "NOT" | Other |
|---|---|---|---|---|---|
| `CLAUDE.md` | 738 | 8,338 | 41 | 60 / 66 | 348 ALL-CAPS words; 171 words per paragraph |
| `PLAN.md` | 2,603 | 25,159 | 128 | 101 / 213 | 124 `Hβ.` references; 61 "MEASURED", 14 "CORRECTED" |
| `docs/SYNTAX.md` | 2,233 | 19,856 | 27 | 109 / 131 | 28 correction paragraphs |
| **Read-path total** | **5,574** | **53,353** | | | about 70k tokens |
| `LEDGER.md` (reference) | 15,791 | 157,127 | 510 entries of 40–130 lines | | 1.08 MB |
| `RESIDUE.md` (reference) | 11,211 | 109,939 | 286 named peers | | largest single entry 1,471 lines |

PLAN.md was 1,676 lines on 2026-08-05 by its own account and is 2,603 today,
up 55% in seven weeks. `src/types.mn` declares 66 diagnostic kinds; SYNTAX's
catalog tables name 49 codes and at least 31 emitted codes are undocumented.
`mentl help` serves 26 verbs; the README lists 10; the help comment in
`src/main.mn` lists 12.

### 1.3 The path: what five weeks produced

Lines changed between 2026-08-18 and 2026-09-21 (97 commits; the two root
snapshots in this shallow clone excluded):

| Area | Added | Deleted |
|---|---|---|
| Read-path and reference docs, README, PROVENANCE | +9,698 | −338 |
| `src` + `lib` | +7,162, of which 51% are comment lines | −4,375 |
| `tools` (bash) | +2,546 | −1,439 |
| `tests` | +735 | −24 |

Per line of executable code (about 3,500), roughly 3.8 lines of English were
written (doc lines plus comment lines). Per read-path file: `CLAUDE.md`
+117/−8, `PLAN.md` +804/−136, `SYNTAX.md` +141/−37, `LEDGER.md` +1,776/−4,
`RESIDUE.md` +2,076/−153. The docs only grow.

Landing cadence, from the ledger's own dates:

| Month | Landings | Active days | Per active day |
|---|---|---|---|
| June | 2 | 2 | 1 |
| July | 256 | 26 | ~10 |
| August | 186 | 11 | ~17 |
| September (to the 21st) | 66 | 16 | ~4 |

Velocity fell three to four times while the doc mass per landing rose. The
first-light fixpoint was reached on 2026-07-10, one month in.

### 1.4 The process layer

- `tools/state.sh` sequences nine gates. `tools/*.sh` is 8,298 lines of bash
  (`frontier-gate.sh` 3,336; `verify.sh` 592; `march.sh` 467).
- `tools/verify-baseline.txt` is 1,102 lines holding 14 numbers: 77 lines of
  prose per number. (`src/board.mn` now carries 13 bounds inside the medium,
  which is the right direction and the right place.)
- `tools/drift-patterns.tsv` holds about 40 regex "drift modes". Mode 9 bans
  "for now", "later", "until", "deferred" and "short-term" in comments. Mode 39
  bans "timebox", "pivot criterion", "ship-gate", "sprint goal" and "N
  sessions". Mode 37 bans "previously", "no longer", "interesting" and
  "important". The process has immunized itself against the vocabulary of
  its own correction.
- `tools/loop-prompt.md` (211 lines) is a second rulebook for the arc loop. It
  bans the word "helper" and requires a medium verb to be run on a file before
  any edit to it.
- The PostToolUse and pre-edit hooks live in `.claude/`, which is gitignored.
  The "mechanical perimeter" exists on one machine and is invisible to this
  checkout. `CLAUDE.md` is itself listed in `.gitignore` while being tracked.
- There is no `.github/`. Nothing runs unless a person runs it.
  `tools/ci/run-board.sh` targets a host the plan lists as "excluded by
  hardware".
- The project's own record of gate rot: the pre-commit hook was installed on
  zero commits until 2026-09-14; `ide-gate.sh` was invoked by nothing;
  `march.sh --fixpoint` never ran in twelve pins; the crown gate went
  unmentioned for eleven ledger entries while a leak rode the arc. Each rot was
  answered with another paragraph and another tripwire.

### 1.5 The march, re-run here

`bash tools/march.sh` on this checkout: **fixed point holds, m2 == m3**, census
0, m3 leg 15.58 s wall and 978 MB peak RSS on four vCPUs. `verify.sh` was green
before it (micros 149/149 through the boot and through this tree's wheel,
syntax battery 17/17, floor contract 1/1). The first march attempt reported
`m3: exit=127, 0 lines` because GNU `time` was not installed, and the line
`✓ GATE: m3 clean (no trap)` still printed green for a leg that never ran;
only the size guard refused. That is a gate that cannot fail, one layer below
the gates the project already documented as rotting, and it is worth a
one-line fix: a non-zero exit is red before any other reading.

### 1.6 Rot found in reader-facing docs in one pass

Each item is small. Together they are the thesis's own counterexample, since
the thesis is carried truth.

- README: "No license is chosen yet." `LICENSE-APACHE` and `LICENSE-MIT` are
  at the root.
- README cites "PLAN.md §11, column 5". §11 has had no columns since
  2026-08-05.
- README's transcript for `mentl lib/tutorial/00-hello.mn:32` shows
  `print_string : …`; the wheel answers `greet("kernel") : ()`.
- `lib/dsp/README.md` says `<~` outside a clock is a compile error
  `E_FeedbackNoContext`; SYNTAX says that diagnostic has zero construction
  sites by design.
- `docs/POSITIONING.md` quotes "139 obligations on the wheel's own
  self-compile", a count in prose, the exact thing PLAN §7 says to delete.
- RESIDUE's own rule is "a gap not in RESIDUE does not exist". Of the 219
  `Hβ.` peer names referenced in source comments, 111 are not in RESIDUE and
  68 appear in none of the five docs at all; 76 RESIDUE peers are referenced
  nowhere else in the tree.
- 166 comment lines in `src/` carry a 2026 date. At `src/infer.mn:1000–1060`,
  45 of 60 lines are comment narrating mechanisms that were deleted.
- `AGENTS.md` says the toolchain "needs only the runner"; the march also needs
  WABT, which it says two lines later.

---

## 2 · Diagnosis: why "closer" reads as "farther"

### 2.1 The criterion has no fixed point

The docs forbid "sufficient", "for now", "later", "timebox", "pivot",
"realistic" and "reachable now", and require "ultimate, SOTA-surpassing,
novel" at every scale. That is a gradient, not a goal. A gradient never
reports arrival; it reports the next step, forever. The instruments the
project built (the residue catalog, the honest audit, the drift modes) can
therefore only count gaps, and they count more as the project understands
more. The feeling in the request is the correct reading of those instruments.
The fix is not lower ambition. It is a second instrument that can report
arrival: a program that runs, a demo that works, a stranger who succeeds.

### 2.2 Laws are indexed by incident, not by principle, and never retire

`CLAUDE.md` has 59 sentences containing never, always, must or forbidden, 41
dated incidents and 348 fully capitalized words. Each law was written the day
something went wrong, in the register of that day ("paid for", "caught live",
"Morgan's cut"). The document says laws are updated in place and superseded
claims deleted; the churn says otherwise (+117/−8 in five weeks). The same
law is restated across files: Carried-Truth alone appears in CLAUDE ⌁,
PLAN §2, §5.O, §9.1 and SYNTAX's comments section. Accretion without
retirement turns a rulebook into lore that must be memorized rather than
derived, and lore is exactly what a fresh session absorbs instead of
interrogates.

### 2.3 The register reproduces itself

The docs are written in a confident, adversarial, capitalized voice, and
`CLAUDE.md` itself observes that fluency and correctness are independent in
model output. A model that reads 70k tokens of this register at session start
writes more of it: more laws, more "the measurement that makes this a rule",
more hundred-line ledger entries for fifty-line diffs. This is why alternating
Opus and Fable does not help; both are prompted into the same voice by the
same files. The register also front-loads suspicion ("you will drift",
"interrogate the author", "Morgan is not the drift-catcher"), a heavy
negative prior to carry into every session.

### 2.4 The medium has one program

54k lines of compiler; about 1,700 lines of everything else. Every design
decision has been validated against one workload, in one style, by one
process. Costs that appear only in ordinary programs (the felt weight of a
thirteen-effect signature, what a beginner types, what a DSP author needs at
the second filter) are invisible, while the compiler's own needs (emit tables,
interning, image layout) shape the language. Languages are shaped by the
programs written in them; a language with one program is shaped by that
program. The wide-row finding of 2026-09-21 is this exactly: the signatures
that grew to nineteen effects are the compiler's, and the compiler is the only
author.

### 2.5 Mechanism was the right conclusion and the wrong follow-through

On 2026-09-21 the project measured that gates caught about thirty errors and
prose caught none. The consequence that follows is: shrink the prose, grow
the gates. The consequence taken was a 480-line doc landing recording the
lesson, plus more gates layered on gates whose rot the project then documented.
The most important mechanism, an external board that runs on every push and
cannot be forgotten, was never built, so "a gate you did not run is not green"
became a standing anxiety instead of a solved problem.

### 2.6 Process became the product

September's landings are dominated by work about the process: self-audits,
gate repairs, ratchet moves, doc corrections, retractions of earlier doc
claims. That work is real, but the user-facing capability barely moved and the
prose describing the process moved most. The loop prompt even has a rule
counting "dry iterations", which is the process noticing itself.

### 2.7 The human's job drifted to policing

The docs cast Morgan as the last line of defense against the model's drift,
then record that as a failure ("Morgan is not the drift-catcher"). The
exhaustion in the request is the predictable result: a person reviewing
hundred-line rationales for fifty-line diffs, daily, against a bar that cannot
be met. The human's job in a language project is taste, programs and users.
The redesign moves policing to CI and lints so the human can go back to that.

---

## 3 · What is strong and must be kept

- **The kernel.** One graph; handlers as the one dynamic mechanism; rows with
  negation; ownership as an effect; refinement with visible debt; the Reason
  chain. Coherent, ambitious, worth the bet.
- **The fixpoint as CI.** `m2 == m3` byte-identity is an excellent oracle and
  cheap (about ten seconds per leg here).
- **Gates seen red first, ratchets that only fall.** Correct, and rare in
  practice anywhere.
- **The medium's own verbs.** `mentl verify`, `audit`, `query … unreachable`,
  `fmt`, the comment-ref gate, `mentl mcp`. This is the right destination for
  every process rule, and it is already partly built.
- **The absence benchmark.** Thirteen programs judged by the compiler. The one
  artifact that shows the thesis in thirty seconds.
- **The README and the lib/dsp story.** Already the right voice for outsiders.
  Fix the rot, keep the voice.
- **The Severance Map.** The best product face named so far; the argument for
  it in PLAN §11 Arc G is sound.

---

## 4 · What the field says

Three independent web-research passes were run (language-design process
lessons; the instruction layer for coding agents; the 2026 state of the art
the positioning claims against). Each is summarized with its sources; where a
finding changes a recommendation in §5, the recommendation says so.

### 4.1 Language-design process lessons

The pass looked at how languages that shipped got there, and at what the
ones that stalled said afterwards. The pattern is consistent enough to state
as findings rather than opinions.

- **Self-hosting is fine; self-hosting as the only workload is not.** The Go
  FAQ is the clearest primary statement: "Not being self-hosting from the
  beginning allowed Go's design to concentrate on its original use case,
  which was networked servers. Had we decided Go should compile itself early
  on, we might have ended up with a language targeted more for compiler
  construction." Lean 4 compiled itself in October 2020 and shipped its first
  pre-release in January 2021 against a Mathlib that was already about 450k
  lines; Zig's self-hosted compiler landed while Bun and TigerBeetle were
  being written in it; Rust grew alongside Servo; Koka's designer wrote
  Madoko in it; Odin is designed against JangaFX's shipped tools. Every
  self-hosting success had an outside program first or in parallel.
- **Progress is measured on the flagship program, not on the compiler's
  self-image.** Lean's FRO runs a server ("Radar") recording the build cost
  of every Mathlib commit (Mathlib grew 66% while instructions fell 28%,
  January 2025 to July 2026), publishes yearly roadmaps of concrete
  deliverables, and describes its AI split as "specifications written by
  hand, implementations and proofs written by AI", checked by three
  independent kernels plus a sandboxed re-checker because "reinforcement
  learning is just so good at finding backdoors". Anthropic's C-compiler
  experiment moved from test-suite pass rates to compiling Linux, QEMU,
  FFmpeg, SQLite and Postgres, with GCC as the oracle, and its lead
  observed that "it's important that the task verifier is nearly perfect,
  otherwise Claude will solve the wrong problem", and that the model is
  "time blind" and "will happily spend hours running tests instead of making
  progress".
- **Guardrails belong in code, not prompts.** From the GOTO session on Roc's
  compiler rewrite (Feldman and Vakil): "guardrails don't live in prompts
  ('never do this' gets ignored constantly), they live in the code itself —
  invariants and automated feedback loops that catch the AI when it strays."
  Roc's rewrite itself is the cautionary number: justified by one named
  architectural blocker with a measured cost, it still took 487 days.
- **One non-negotiable gate: main is always green.** Graydon Hoare's "not
  rocket science rule" ("automatically maintain a repository of code that
  always passes all the tests", implemented as bors) is the single process
  mechanism every shipped language shares. Carlini's agents "frequently
  broke existing functionality each time they implemented a new feature"
  until CI enforced it.
- **Ratchets: clean up first, then make it an error; no standing baselines.**
  Google's static-analysis practice (SWE book, ch. 20): "We either enable a
  compiler check as an error (and break the build) or don't show it in
  compiler output"; every existing instance is fixed before a check becomes
  an error; checks shown in review must have under 10% effective false
  positives (any report the developer does not act on); a "Not useful"
  button files a bug against the analyzer, and noisy analyzers are disabled.
  Count-keyed ratchets have documented churn modes in agent-heavy repos: a
  fix in one place hides a new violation elsewhere, and whole-tree counts
  blame a change for unrelated drift, so ratchet on identities (sites), not
  counts, and against the diff, not the tree.
- **Separate current truth from history by construction.** Nygard's
  Architecture Decision Records (2011): one short record per decision with a
  status, superseded records kept but never rewritten, the current rule in
  one place. Rust applies the same split at language scale: the Reference
  (current truth), the RFC book (decision history), the Unstable Book
  (in-flight work). The C-compiler agents kept short progress files and made
  logs greppable ("ERROR and the reason on the same line") precisely to keep
  history out of the model's context.
- **Ship by fencing unfinished work, not by finishing it.** Rust 1.0 treated
  stability as the deliverable and gated unfinished features to nightly; Zig
  0.11 shipped without async when it could not keep up; Mojo's 1.0
  (August 2026) explicitly excluded async and private members and Modular
  called 1.0 "a forcing function for focus and prioritization". Gleam's 1.0
  led with "small surface area, learnable in an afternoon" and "only one way
  of doing things", and its post-1.0 news is almost entirely tooling.
- **The stalled cases stalled on scope and closed process.** Unison took
  more than ten years to 1.0, and one critic attributes it to taking on
  distributed computing alongside content-addressed code. Darklang's 2022
  status update kept "running into foundational product problems that
  couldn't be simply patched", and it wound down as "an 8-year-old product
  with no traction". Elm's closed process and 0.19's breaking changes drove
  contributors out, and its last compiler release was in 2019. Hoare's 2023
  retrospective on Rust: his priorities "are broadly not the revealed
  priorities of the community", and he is glad he was not BDFL.
- **The phase after self-hosting is second-system territory.** Brooks (1975)
  on the second system as "the most dangerous system a man ever designs",
  over-designed with the ideas sidetracked on the first; Gall's law that a
  complex system that works "is invariably found to have evolved from a
  simple system that worked". Klabnik's Rue (about 100k lines in eleven days
  with an agent) had to be started over once and is "still very janky", a
  reminder that agent-scale line counts are not maturity.
- **The feeling in the request has a measured shape.** Sirois, Molnar and
  Hirsch's meta-analysis (2017): procrastination and avoidance correlate
  with perfectionistic *concerns* (the sense of discrepancy from an ideal,
  r = .23) and negatively with perfectionistic *strivings* (high standards,
  r = −.22). High standards are not the risk; a criterion that manufactures
  discrepancy is. Amabile and Kramer's 12,000 workplace diaries: small,
  regular, visible progress on meaningful work is the strongest driver of
  engagement. Simon's satisficing (1956) is the model: choose against an
  aspiration level, and adjust the level with experience. Scrum's Definition
  of Done is the same idea as a checkable, pre-declared state.

What this changes in §5: a dated definition of done for a first release with
explicit exclusions; unfinished frontier fenced as unstable rather than
blocking; decision records instead of the standing "interrogate every
decision" license; ratchets with end dates keyed on sites; and "every
restructuring names the user-visible capability it unblocks" as an issue
rule.

### 4.2 The instruction layer: what the vendor and the measurements say

- **Anthropic's own target is under 200 lines per CLAUDE.md**, stated with
  the reason: "longer files consume more context and reduce adherence", and
  "@-imports … still load and enter the context window at launch", so the
  split into three files buys organization, not attention.
  (code.claude.com/docs/en/memory)
- **CLAUDE.md is advisory; hooks are deterministic.** "Claude treats them as
  context, not enforced configuration. To block an action regardless of what
  Claude decides, use a PreToolUse hook instead." And: "if two rules
  contradict each other, Claude may pick one arbitrarily." The docs name the
  failure pattern outright: "The over-specified CLAUDE.md … Claude ignores
  half of it … Fix: ruthlessly prune … or convert it to a hook." Emphasis is
  a budget too: mark one line IMPORTANT; "if you emphasize many lines, none
  of them stands out." (code.claude.com/docs/en/best-practices)
- **Instruction count is a first-order predictor of adherence, measured.**
  IFScale (arXiv 2507.11538): Claude Opus 4 followed 100% of 50 simultaneous
  instructions, 94.6% of 100, 67.9% of 250 and 44.6% of 500; errors at
  density are overwhelmingly omissions; putting the important ones first
  stops working at high density. Harada et al. (EMNLP 2025, arXiv
  2509.21051): a logistic regression on instruction count alone predicts
  success within about ten points, including on code-style instructions.
  `CLAUDE.md` alone carries 59 never/always/must sentences; the word "never"
  occurs 270 times across the three read-path files.
- **Long context degrades even without truncation.** Chroma's "Context Rot"
  (2025): a 300-token focused input beat a 113k-token full input in every
  model family with content held constant; distractors that are
  semantically similar to the target hurt most. NoLiMa (ICML 2025): with
  lexical overlap removed, ten of twelve models fell below half their
  short-context baseline at 32k tokens. A rule that must be matched to code
  by meaning, surrounded by dated stories about that rule, is exactly this
  regime.
- **Context files buy efficiency, not correctness, in the field studies
  that exist.** ETH Zurich (arXiv 2602.11988, 2026, agents including Claude
  Code): "providing context files does not generally improve task success
  rates, while increasing inference cost by over 20% on average"; they help
  "for specifying non-standard coding practices". Lulla et al. (arXiv
  2601.20404): an AGENTS.md was associated with 28.6% lower median runtime
  and 16.6% fewer tokens at comparable completion. So a short file encoding
  the non-derivable conventions (the five verbs, the census rule, the build
  commands) is the part that pays; overviews and history do not.
- **The two models this project alternates get opposite official guidance
  on the knobs the docs lean on.** The Opus 5 prompting guide says to
  *remove* explicit verification and subagent-verify mandates ("instructions
  like these cause over-verification") and notes its written deliverables
  run longer; the Fable 5 guide says prompts written for earlier models "are
  often too prescriptive", to "steer most behaviors with a brief instruction
  rather than enumerating each behavior by name", and that in long runs it
  can drift into "dense arrow-chain shorthand … labels you made up earlier".
  One corpus written in one voice mandates what one model is told to delete
  and enumerates what the other is told not to enumerate. That is a
  plausible mechanical cause of both the docs' growth and their private
  vocabulary, not only a stylistic one. (platform.claude.com prompting
  guides for Opus 5 and Fable 5)
- **Mechanism beats prose has measured support beyond this repo.** SWE-agent
  (NeurIPS 2024): an edit tool with a linter guardrail resolved 18.0% versus
  15.0% without it, fixing the exact failure of repeatedly re-editing the
  same snippet into a syntax error. Anthropic's harness guidance: "Unlike
  CLAUDE.md instructions which are advisory, hooks are deterministic"; a
  Stop hook can refuse to end a turn until a check passes (and gives up after
  eight consecutive blocks). Sadowski et al. (CACM 2018) on static analysis
  at Google: findings surfaced outside the workflow were ignored; findings at
  compile or review time with low false-positive rates were acted on.
- **One correction to §2.5.** "Gates caught about thirty, prose caught zero"
  is survivorship-biased: gate catches are logged, errors the prose prevented
  are invisible. It shows the gates work; it does not prove the prose is
  inert. The honest way to settle it is an ablation, which §6 now includes.
- **Two mechanics worth using.** Rules under `.claude/rules/` with a `paths:`
  frontmatter load only when a matching file is touched (a 150-line SYNTAX
  surface card for `**/*.mn` costs nothing in other work). Block-level HTML
  comments are stripped before injection, so a rule's originating incident
  can sit beside it at zero token cost.
- **Memory hygiene, per the Fable 5 guide:** one lesson per file with a
  one-line summary, an index under 200 lines, wrong notes deleted, and
  nothing stored that the repo or git already records. Anthropic's
  long-running-agent harness reads a short progress file, a structured
  feature list with a `passes` field, and the git log at every session
  start; it uses JSON for state "because the model is less likely to
  inappropriately change or overwrite JSON files compared to Markdown".

What this changes in §5: the always-loaded core should be one file of
150–200 lines with pointers, not three imported files; `DESIGN.md` is read
when designing and `SYNTAX.md` when writing `.mn` (path-scoped card
always, full spec on demand); the plan gains an ablation and per-model
addenda.

### 4.3 The 2026 state of the art the positioning claims against

The research pass checked each headline claim against primary sources. The
verdicts matter for the plan because a positioning claim that is prior art
costs credibility with exactly the audience the README courts.

- **Effect negation is shipped prior art.** "With or Without You: Programming
  with Effect Exclusion" (Lutze, Madsen, Schuster, Brachthäuser, ICFP 2023)
  gives Flix effect polymorphism with union, intersection and complement
  effects, complete inference by Boolean unification, and a proved
  effect-safety theorem ("no excluded effect is ever performed"), with a case
  study of 59 real fragments that need exclusion. Rémy-style presence/absence
  rows (POPL 1989) and Links' effect rows (TyDe 2016) already encode absence
  inside a polymorphic row; Mentl's `EfRow(present, absent, tail)` has that
  shape. `docs/POSITIONING.md` already cites Flix "rather than claim"; the
  README's "the podium this enters is empty" and PLAN §1's "recall becomes
  1.0 … by a different substrate" do not. What remains open, and is worth
  claiming, is the conjunction: per-instance negation (`!Sample(44100)`),
  negation under handler-install identity, and a world-typed persisted
  continuation, in one substrate. The implementation is also behind the
  paper on the property that matters most: PLAN §7 records that a reachable
  perform with no handler installed anywhere compiles clean today.
- **Tang & Lindley (POPL 2026, arXiv 2507.10301) is overstated in PLAN §4③.**
  "Rows and Capabilities as Modal Effects" encodes row-based and
  capability-based systems into a common modal calculus by macro translation
  in order to compare them. It is not a theorem that rows ≡ capabilities, and
  its abstract says nothing about negation. "The rows≡capabilities half is
  discharged; the negation half is the open burden" is Mentl's framing, not
  the paper's.
- **Capslock is characterized unfairly.** Its caveats document does say
  reported chains "may not necessarily occur in practice" and that cgo,
  assembly and `go:linkname` collapse to `ARBITRARY_EXECUTION`. It also
  reports `reflect`, `unsafe`, `os/exec` and `plugin` as capabilities in
  their own right "so that capabilities are not missed without any indication
  to the user". That is conservative flagging of escape hatches, not silent
  unsoundness, and PLAN §1(b) should say so.
- **The nearest rival to the whole pitch is in Scala 3, with evaluations.**
  Odersky, Zhao, Xu, Bračevac and Pham, "Tracking Capabilities for Safer
  Agents" (arXiv 2603.00991, March 2026; ACM CAIS 2026): agents express
  actions as Scala 3 code under capture checking, capabilities are program
  variables, "local purity" prevents leakage of classified data, and "agents
  can generate capability-safe code with no significant loss in task
  performance." LACUNA (arXiv 2605.28617, May 2026, same group): each agent
  action is a typed hole the LLM fills at runtime, type-checked against the
  surrounding program before it runs, with compiler diagnostics fed back on
  rejection; 8.6% of generations rejected, 0.7 retries per query on
  BrowseComp-Plus, and 76.0% on τ²-bench, matching baseline. That is
  "any intelligence may propose; nothing executes unproven; refusals teach"
  in a mainstream language with a corpus models already write, plus the
  benchmark numbers Mentl does not have. Microsoft's FIDES (arXiv
  2505.23643) and Google's CaMeL (arXiv 2503.18813) hold the runtime-IFC
  side of the same space.
- **The trust thesis is mainstream, not contrarian.** Kleppmann, "Prediction:
  AI will make formal verification go mainstream" (December 2025) argues
  PLAN §0 almost verbatim. The vericoding benchmark (arXiv 2509.22908;
  12,504 specs across Dafny, Verus and Lean) reports off-the-shelf LLM
  success of 82% on Dafny, 44% on Verus and 27% on Lean, with pure Dafny
  verification rising from 68% to 96% in about a year. No survey quantifying
  industrial uptake was found; "gaining adoption" is a trend claim.
- **`persist = memcpy` is the image idea, and the field moved away from
  it.** Smalltalk and Lisp images, Stackless Python's pickled tasklets,
  Racket's serializable continuations and CRIU are the lineage. Golem 1.5
  (May 2026) runs WASM durable execution by oplog replay and its explainer
  rejects whole-memory snapshots on latency grounds; Temporal, Restate and
  DBOS journal steps, and their hard problem is code evolution of in-flight
  executions, which Mentl's build-key gate on `image_resume` does not
  address. A compile-time resume-world check on a persisted continuation
  would be novel if enforced; PLAN §7 records it as inert on the one-shot
  path. Stack switching is Phase 3 in the WebAssembly proposals as of this
  month; proposal continuations are one-shot, so multi-shot stays
  compiler-reified.
- **Ownership inference from use has a close ancestor.** Lean 4 infers
  owned versus borrowed parameters ("Counting Immutable Beans", IFL 2019) as
  an optimization; Koka's Perceus (PLDI 2021) inserts precise reference
  counting with no annotations; OCaml's modes are largely inferred with
  annotations at boundaries. The known cost, and the reason Hylo, Mojo and
  Swift keep conventions explicit at API boundaries, is that inferring a
  signature from a body couples callers to callee bodies and fights
  separate compilation. §4⑤'s "if the developer has to think about it, the
  inference failed" needs that boundary named.
- **Refinement with visible debt is standard.** Liquid Types (PLDI 2008) is
  the decidable-fragment-plus-SMT design; Lean's `sorry`, Dafny's `assume`
  with `dafny audit` and F*'s `admit` are the visible-debt convention;
  gradual verification (VMCAI 2018) is the theory. On this tier Mentl is
  behind: predicates are a separate walk that degrades to debt and the SMT
  swap is unbuilt (PLAN 8.1–8.3).
- **Provenance and holes.** The closest research to the Reason chain is
  Bhanuka et al., "Getting into the Flow" (OOPSLA 2023, constraint
  provenance as flow paths), SHErrLoc, and Hazel's marked lambda calculus
  (POPL 2024). Attaching a Reason to every fact behind one query surface is
  an engineering unification worth having; its known cost is provenance
  blow-up, which PLAN §11 already admits (`Unified(R, R)` duplicating
  subtrees). Proof-filtered filling is shipped at research grade:
  type-constrained decoding (Mündler et al., PLDI 2025) halves compilation
  errors in TypeScript; Hazel's typed-hole contextualization (OOPSLA 2024);
  MoonBit's semantics-guided sampler; LACUNA above. "Choose, Don't Label"
  (Barnaby, Ding, Bastani, Dillig, arXiv 2604.08792, April 2026) exists and
  answers each option as a Hoare triple characterizing a cluster; the claim
  in PLAN §11.1 that its authors name clustering quality and candidate-count
  scaling as limits is not visible in the abstract and should be re-sourced
  or dropped.
- **Darklang and MoonBit.** The Darklang quote in PLAN §11 Arc G is real
  ("between 'Ok I guess' and 'probably the worst part of Darklang'", March
  2024) and the company later restructured. MoonBit positions itself as
  AI-native with a KV-cache-friendly grammar and a semantics-guided sampler,
  and Golem runs it. The one empirical regularity found is that per-language
  LLM performance tracks corpus size; no study isolates syntax design as the
  cause.

**The zero-corpus problem, stated plainly.** Every real user of Mentl will
write it with a model, and no model has seen Mentl. Under "the LLM is only a
proposer", a low-resource language produces proposals that are mostly
filtered, which is sound and unproductive. Odersky's group chose Scala partly
because models already write it. The README's "a model behind this gate is
unemployed" is the framing the field's evidence argues against; the medium's
job is to make proposals cheap to filter and to teach the proposer back
(which `mentl mcp` already does structurally). The corpus is built by the
second program, the tutorial and a SYNTAX card that fits in a context window.

**Claim, closest prior art, verdict:**

| Claim | Closest prior art | Verdict |
|---|---|---|
| `!E` proving transitive absence under polymorphism | Flix ICFP 2023; Rémy/Links rows | shipped; per-instance form partially novel |
| negation unified with modal/capability tracking | Tang & Lindley POPL 2026 (no negation) | open; novel if solved |
| handler = state = closure = continuation, persist by memcpy | images, Racket, Golem | shipped technique; typed resume-world novel if enforced |
| ownership inferred from use | Lean 4 borrow inference, Perceus, OCaml modes | partially novel framing; modularity cost known |
| decidable refinements plus visible debt | Liquid Types, Dafny/Lean/F* debt conventions | shipped; Mentl behind |
| Reason chain on every fact | Bhanuka et al. 2023, SHErrLoc, Hazel | partially novel (unification) |
| `!Flow` as row facts | FlowCaml, Jif/LIO; FIDES, CaMeL, Scala local purity | shipped; Mentl immature |
| `??` filled by proposer, compiler filters, ties ask | PLDI 2025 decoding, Hazel, LACUNA, Socrates | shipped at research grade; first-divergence question partially novel, unevaluated |
| self-hosting byte-identical fixpoint as CI | GCC three-stage compare, Zig's wasm bootstrap, Wheeler DDC | shipped technique |
| "verification substrate for machine-generated code" | Kleppmann 2025; vericoding; Odersky CAIS 2026 | crowded; the rival has evaluations |

**What credible positioning needs, in order:** (1) close the effect-safety
hole so a perform with no install refuses; (2) a written soundness argument
for per-instance negation; (3) an agent benchmark (AgentDojo or τ²-bench)
through `mentl mcp` against the Scala 3 capture-checking baseline. Until
then, "verification substrate" reads as an unevaluated reformulation of
shipped work, and the README should say what is distinctive: the conjunction,
in one self-hosted substrate, with a demo anyone can run.

---

## 5 · The redesign

### 5.1 Bound the criterion: a definition of done that is program-shaped

Keep "ultimate" as the direction, stated once in `DESIGN.md`. Make acceptance
concrete and external, per milestone:

- **A second program.** Real software written in Mentl that is not the
  compiler, by Morgan, used by Morgan. The founding workload is right: an
  offline audio renderer. A signal chain (oscillators, the echo, a lowpass, the
  spectral distortion) rendered to a WAV file, with `!Alloc` proven on the
  per-sample path and `Sample` refinements on the signal. It exercises `<~`,
  the verbs, rows, refinements and ownership, and it produces something you
  can hear. For the next quarter, every design question is answered by what
  this program needs.
- **The thirty-second demo.** A module banded green with `!Network` proven;
  add one call; the band turns red and the compile refuses with the Reason.
  Static HTML from `mentl audit` first; the resident IDE later if still wanted.
- **The stranger test.** Someone who has never seen the repo installs it and
  runs the tutorial in ten minutes from the README alone.
- **A dated first release, with exclusions.** After M2, write the definition
  of 0.1 as checkable capabilities on the flagship program and an explicit
  list of what is fenced as unstable (the modal world-index, IFC, native,
  the resident IDE). Rust, Zig, Mojo and Gleam all shipped by fencing, and
  Modular's word for 1.0 was "a forcing function". Fenced is not deferred:
  it is named, tracked, and not blocking.

### 5.2 Shrink the read-path and separate truth from history

| Today | Proposed | Budget | Enforced by |
|---|---|---|---|
| `CLAUDE.md` (738 lines, importing the other two) | `CLAUDE.md`: build, run, test; the five verbs; the eight questions; seven rules with their enforcement; pointers. The only always-loaded file; no `@` imports. | ≤150 lines | a line-budget check in pre-commit and CI |
| `PLAN.md` §0–§4 (~300) | `DESIGN.md`: what Mentl is, the kernel, the resolved decisions. Timeless. Read before design work, not at every start. | ≤400 | no `2026-` allowed |
| `PLAN.md` §5–§11 (~2,300) | `MILESTONE.md`: the current milestone's goal, acceptance tests, items, and what is explicitly not in it; the next two sketched. Read at session start. | ≤150 | rewritten per milestone |
| `PLAN.md` §7 (221) | the board's output (`mentl verify`, the CI badge). No prose copy of state. | 0 | — |
| `PLAN.md` §4's "resolved decisions" and the standing "interrogate everything" license | `docs/decisions/NNNN-title.md`: one short record per decision (context, decision, status, consequences); superseded records kept, never rewritten. Reopening a decision means writing a new record. | ≤40 lines each | — |
| `docs/SYNTAX.md` (2,233) | a 150-line surface card under `.claude/rules/` with `paths: ["**/*.mn"]` (tokens, precedence, canonical and rejected forms), loaded only when `.mn` is touched; plus `docs/SYNTAX.md` as the full reference (forms, rules, tables), read on demand; the 28 correction paragraphs go to git history | card ≤150; reference ≤1,200 | no dates; the catalog generated by `mentl diagnostics` once it exists |
| `LEDGER.md` (15,791) | frozen as `docs/archive/LEDGER-2026-06-to-09.md`; `git log` and `boot/PROVENANCE.md` are the ledger | archive | `doc-truth.sh` reads PROVENANCE only |
| `RESIDUE.md` (11,211) | GitHub issues, one label per band; frozen copy archived; only milestone-blocking peers get issues now | archive | — |
| `tools/loop-prompt.md`, `AGENTS.md` | delete the loop prompt; `AGENTS.md` becomes ten lines pointing at `CLAUDE.md` | — | — |
| `docs/MENTL_EDIT.md`, `DESIGN_SYSTEM.md`, `NATIVE.md`, `POSITIONING.md` | keep as design and positioning docs, linked from `DESIGN.md`, fixed for rot | — | — |

A session then starts on about 300 always-loaded lines (CLAUDE + MILESTONE),
with the syntax card appearing only when `.mn` files are touched and DESIGN
and the full SYNTAX pulled in when the work needs them, and zero history in
any of it. That is inside the vendor's stated target and inside the range
where instruction-following was measured to hold (§4.2). The archives stay in
the tree for anyone who wants the story, and nothing reads them by default.

### 5.3 Every law becomes a mechanism, a one-line rule, or nothing

Apply the project's own ordering rule ("a law that can become a gate must") to
the process docs. Sorting the current imperatives:

- **Becomes a lint or gate, then the prose is deleted:** comment references
  must resolve (exists); the census shapes (exist, in `mentl verify`); no
  dates in read-path docs; read-path line budgets; no dated history in `src/`
  comments; the fixpoint (exists); a new gate is seen red first (a PR
  checklist line).
- **Stays as a one-line rule, at most ten of them:** carry the handle, read
  live; restructure or stop; a new gate is seen red first; delete, do not
  decorate; measure before asserting a cause; ultimate is the direction, the
  milestone is the work; ask the medium before the shell; one home per truth.
- **Deleted, with git keeping the story:** every dated incident; every
  vocabulary ban on thinking words (timebox, pivot, later, for now, helper,
  sufficient); the "Morgan said" attributions; the drift regexes that police
  prose (modes 9, 14, 37, 39, and the mode-40 rows whose forms the parser
  already refuses); the pre-edit "consult" perimeter. Appendix A lists each
  repeal with its replacement.
- **Ratchets get an end date and a key.** Per Google's practice (§4.1) a
  ratchet is a transition, not a home: each bound in `src/board.mn` names the
  date by which it becomes a hard error (a refusing `DiagKind`) or is
  deleted, and it is keyed on sites (which `mentl verify` already lists), not
  on a count, so a fix in one place cannot hide a new violation elsewhere.
- **A restructuring names what it unblocks.** An issue proposing internal
  restructuring (arena, columns, `(arena, offset)`, the fan) must name the
  `felt` issue or the acceptance test it unblocks; Roc's rewrite was
  justified by one named blocker with a measured cost, and still cost 487
  days.

### 5.4 One board, run by a machine, on every push

A GitHub Actions workflow (`docs/proposals/board.yml`, each step run here):
build the runner (cached by Cargo.lock), install WABT and GNU `time`, run
`verify.sh`, `march.sh`, the absence benchmark, the crown gate and
proof-exactness.
Once it is green twice, delete the stamp machinery (`frontier-stamp`,
`verify.green`, the "which gates measured this boot" block). Stamps exist to
avoid re-running by hand; CI removes the hand. The pre-commit hook shrinks to
`mentl fmt` on staged wheel files plus `mentl verify src/main.mn`. "A gate you
did not run is not green" stops being a law and becomes a red badge nobody can
miss.

### 5.5 Code prose: what a thing is, not what it was

Adopt SYNTAX's own comment rule for the compiler: the first line is the lede,
references are backticked and must resolve, and history lives in git. The
mechanism: a lint that refuses a `2026-` date or the phrases "used to",
"was deleted" and "the movers" in a `//` comment under `src/` and `lib/`, plus
a per-file comment-line ratchet that only falls. Target: comment share from
40% toward about 15% over the quarter, by deleting narration and never ledes.
Where a comment explains a mechanism the medium cannot yet speak, it stays;
where it explains a mechanism that no longer exists, it goes.

### 5.6 The register

Calm, present tense, specific, checkable. No ALL-CAPS emphasis, no incident
dates, no attributions, no "paid for". A rule is stated once, with the
mechanism that enforces it or the word "unenforced". Docs are written for a
reader who was not there. `docs/proposals/CLAUDE.next.md` is the model.

### 5.7 Working with the models

- Session start: `CLAUDE.md` (always loaded) and `MILESTONE.md`. `DESIGN.md`
  before design or kernel work; the syntax card loads itself on `.mn` files
  and the full `SYNTAX.md` is read when the form is in question. Never the
  archives.
- Session end: a commit message that says what changed and what the board
  said. Five lines, not a hundred. The PROVENANCE entry the march writes at a
  re-pin is the landing record.
- Adversarial review stays, budgeted as below; it is the best anti-fluency
  tool available. A fresh agent gets `DESIGN.md` and the diff, never the
  ledger.
- One model is the editor of record for the docs in a given month and the
  other reviews. Alternating authorship of the same prose is how a register
  drifts.
- Per-model addenda of about twenty lines each, kept beside `CLAUDE.md`, not
  inside it: the Opus guide says to remove explicit verify and
  subagent-verify mandates and to calibrate document length; the Fable
  guide says to steer with brief instructions, use a fresh-context verifier
  at intervals, and avoid "reproduce your reasoning" instructions. One
  neutral core plus two short addenda replaces one corpus that is wrong for
  both.
- Verification is budgeted: deterministic gates are the primary verifier;
  fresh-context adversarial review is for high-stakes landings, scoped to
  correctness ("a reviewer prompted to find gaps will usually report some,
  even when the work is sound").
- Repeal the "no time" rule for planning. Milestones with dates are how a
  person feels progress; the ban on that vocabulary is the single rule most
  responsible for the feeling in the request.
- Measure the instruction layer instead of arguing about it: ten to twenty
  scripted tasks, including past drift incidents, run under the current
  corpus and under the slim core plus hooks, on both models, counting gate
  and rule violations, cost and time. It is the only way to know whether the
  prose was preventing anything, and it is a day of work.

### 5.8 Positioning: claim the conjunction and the demo, cite the field

Per §4.3: name Flix as prior art for `!E` in the README (POSITIONING already
does); correct the Tang & Lindley sentence in PLAN §4③ and the Capslock
paragraph in PLAN §1; drop "the podium is empty"; state the distinctive claim
as the conjunction in one self-hosted substrate, with the thirty-second demo
and the absence benchmark as the receipts; name Odersky's capture-checked
agents and LACUNA as the nearest work and plan the benchmark that compares
against them. Retire "a model behind this gate is unemployed": the model is
the proposer every user will actually use, and the medium's job is to make its
proposals cheap to filter and to teach it back through the gate.

### 5.9 Triage the half-built arcs against the second program

The Space spine (Arcs B′ to G), the per-decl arena, the columns, the oracle
fan, `(arena, offset)` and native each become an issue with its design doc
linked. Only what the current milestone needs is worked. A named gap is not
drift; an unnamed gap is. Issues are names.

---

## 6 · The plan

### First 48 hours: the reset (no compiler changes)

1. Branch `process-reset`. Move `LEDGER.md` and `RESIDUE.md` to
   `docs/archive/`. Point `doc-truth.sh` at PROVENANCE only.
2. Write `DESIGN.md` from PLAN §0–§4, condensed, dates and corrections
   stripped. Write `MILESTONE.md` for M1 (below). Replace `CLAUDE.md` with the
   draft. Delete `tools/loop-prompt.md`; shrink `AGENTS.md`.
3. Strip SYNTAX's correction paragraphs into git; reconcile the catalog with
   the 66 kinds in `types.mn`.
4. Fix every item in §1.6 and Appendix B. Remove `CLAUDE.md` and the hooks
   from `.gitignore`; bring the hooks into the repo or delete them.
5. Add the three doc lints (line budgets, no dates in the read-path, no dates
   in `src/` comments) to pre-commit. Delete drift modes 9, 14, 37, 39.
6. Add `.github/workflows/board.yml` from `docs/proposals/board.yml`.
   Delete the stamps once it is green twice.
7. Open issues for the peers that block M1 only (likely under fifteen).
   Everything else is archived by name and is one grep away.
8. Start `docs/decisions/` with one record per resolved decision in PLAN §4
   (seven records, each under forty lines). From then on a decision is
   reopened by a new record, never by a session re-arguing it.

### M1, two weeks: the second program (`docs/proposals/MILESTONE.next.md`)

- `examples/render/`: an offline audio renderer in Mentl that writes a WAV.
  Oscillator → echo (`<~ delay`) → lowpass → the spectral distortion → mix,
  with `!Alloc` proven on the per-sample path and `Sample` refinements on the
  signal. Acceptance: `mentl run examples/render/main.mn > out.wav` produces a
  playable file; introducing an allocation on the audio path makes the
  `!Alloc` claim refuse; the program is at least 500 lines of ordinary Mentl
  written by Morgan.
- Every language pain met while writing it becomes an issue tagged `felt`.
  The milestone's compiler work is only what those issues need.
- CI green on every push, and the CI summary prints the renderer's compile
  time and peak memory beside the compiler's own, so the flagship has its
  own number the way Mathlib has Radar.
- The instruction-layer ablation from §5.7, run once, both models.
- The stranger test, run once by someone who is not Morgan.

### M2, two weeks: the demo

- The Severance Map as static HTML generated from `mentl audit`, three
  colours (absent, present, not yet provable) with the third counted. The
  thirty-second script recorded as a GIF in the README.
- The effect-safety hole closed first: a reachable perform with no install
  anywhere refuses (PLAN §7's own finding). A map that says "provably absent"
  over that hole is the two-colour lie in a different costume.
- The absence benchmark published as the receipts page; positioning tightened
  per §4.3 and §5.8 so prior art is named and the claim is the conjunction.
- The agent loop measured once: a model writes the renderer's next processor
  through `mentl mcp` with diagnostics fed back; count rejections and retries
  the way LACUNA reports them. This is the receipt the README currently
  asserts without a number.
- `mentl diagnostics` generating SYNTAX's catalog tables.

### M3: decided at the end of M2, from the `felt` issues

Candidates, not commitments: the resident `mentl space` session; the modal
world-index (PLAN 6.3) if the map's third colour is too large to ship; the
arena if the renderer's compile cost demands it; native only when a program
needs it.

### What to stop doing

- Writing a law after every mistake. Write a lint, or nothing.
- Writing ledger entries. Write commit messages.
- Measuring against "ultimate". Measure against the milestone's acceptance
  tests; keep "ultimate" as the direction in `DESIGN.md`.
- Re-auditing the process. This is the last audit of its kind until M2 ends;
  the retrospective then is one page.

---

## Appendix A · Repealed laws and their replacements

| Current rule (where) | Replacement |
|---|---|
| "Context cost is NOT a constraint: hold the ENTIRETY" (CLAUDE ⊜, PLAN header) | An always-loaded core of about 300 lines; design, syntax and archives on demand. Attention, not tokens, is the constraint. |
| "No deferrals, no 'for now', no 'later'" (CLAUDE ⚖, red-flag table, drift mode 9) | A named issue is the deferral. `TODO` in code is allowed and counted by a ratchet that only falls. |
| Drift mode 39: "timebox", "pivot", "ship-gate", "sprint goal" banned | Deleted. Milestones have dates. |
| "There is no time — only the work" (CLAUDE ⊕) | Keep the no-cron rule; drop the no-time rule. |
| "Sufficient is not ultimate" (red-flag table) | The milestone's acceptance test defines sufficient; ultimate is the direction in DESIGN.md. |
| Dated laws named after incidents (all three docs) | Deleted from the read-path; git and the archive keep them. |
| "Morgan is not the drift-catcher" (loop prompt) | CI and lints catch drift; the human's job is programs and taste. |
| The "consult before edit" pre-edit hook (loop prompt §4) | Deleted. `mentl verify` in pre-commit and CI is the gate. |
| Stamp machinery: frontier-stamp, verify.green, the STAMPS block | Deleted once CI is green twice. |
| `tools/verify-baseline.txt` (1,102 lines for 14 numbers) | `src/board.mn` for bounds the medium can measure; a 20-line TSV for the rest. |
| `LEDGER.md` entries per landing | A five-line commit message; the PROVENANCE entry the march writes. |
| `RESIDUE.md` as the catalog of every gap | Issues for what blocks the milestone; the archive for the rest. |
| "Never attribute Claude in commits" | Kept. |
| "A gate is not trusted until seen RED" | Kept, as a PR checklist line. |
| "Ratchets only fall" | Kept, in `src/board.mn`. |
| "Every dispatched agent runs Opus or Fable, passed explicitly" | Kept, one line. |
| "Interrogate, don't absorb" as a standing license to reopen any decision every session | Decision records with a status; reopening is a new record. The critical stance stays for code and claims; settled decisions are settled until re-decided. |
| "Verify my own conclusions via adversarial dispatch" as a mandate on every landing | Budgeted: deterministic gates first; fresh-context review for high-stakes landings only. |
| The nine drift modes as prose (CLAUDE) | The structural ones are census shapes in `mentl verify` already; the prose list is deleted. |

## Appendix B · The rot list to fix in the reset

See §1.6. Add: the README verb roster (10) versus `mentl help` (26); the
`src/main.mn` help comment (12 verbs, including `serve`, `repl`, `--with`);
`AGENTS.md`'s toolchain sentence; SYNTAX's three diagnostic tables versus the
66 kinds; the `Hβ.` names in code that name no catalog entry.
