# Mentl — process audit and redesign plan (2026-09-25)

**Scope.** Morgan asked for a deep audit of the processes, protocols, routines,
laws, rules, shape and path of development so far, followed by a plan to
optimize or redesign them so the build gets a clearer picture and a more
rewarding pace. Everything below was measured on this checkout (branch
`claude/mentl-design-audit-m1mptf`, head `fc4ddd3`) in a fresh container in
which the runner was built and the wheel was run; every number comes from this
session. Field research was done by three independent web-research passes;
their findings and sources are in §4.

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

The redesign keeps the ambition and the kernel and changes the loop: a bounded,
program-shaped definition of done (a second real program and one thirty-second
demo), a session read-path of about 1,900 lines instead of 5,574 with zero
history in it, laws turned into lints or deleted, one board run by CI on every
push, and a milestone cadence. The steps are in §6.

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

*(Research passes in progress; this section is filled in the next commit.)*

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

### 5.2 Shrink the read-path and separate truth from history

| Today | Proposed | Budget | Enforced by |
|---|---|---|---|
| `CLAUDE.md` (738 lines) | `CLAUDE.md`: build, run, test; the five verbs; the eight questions; seven rules with their enforcement; pointers | ≤150 lines | a line-budget check in pre-commit and CI |
| `PLAN.md` §0–§4 (~300) | `DESIGN.md`: what Mentl is, the kernel, the resolved decisions. Timeless. | ≤400 | no `2026-` allowed |
| `PLAN.md` §5–§11 (~2,300) | `MILESTONE.md`: the current milestone's goal, acceptance tests, items, and what is explicitly not in it; the next two sketched | ≤150 | rewritten per milestone |
| `PLAN.md` §7 (221) | the board's output (`mentl verify`, the CI badge). No prose copy of state. | 0 | — |
| `docs/SYNTAX.md` (2,233) | `docs/SYNTAX.md`: forms, rules and tables only; the 28 correction paragraphs go to git history | ≤1,200 | no dates; the catalog generated by `mentl diagnostics` once it exists |
| `LEDGER.md` (15,791) | frozen as `docs/archive/LEDGER-2026-06-to-09.md`; `git log` and `boot/PROVENANCE.md` are the ledger | archive | `doc-truth.sh` reads PROVENANCE only |
| `RESIDUE.md` (11,211) | GitHub issues, one label per band; frozen copy archived; only milestone-blocking peers get issues now | archive | — |
| `tools/loop-prompt.md`, `AGENTS.md` | delete the loop prompt; `AGENTS.md` becomes ten lines pointing at `CLAUDE.md` | — | — |
| `docs/MENTL_EDIT.md`, `DESIGN_SYSTEM.md`, `NATIVE.md`, `POSITIONING.md` | keep as design and positioning docs, linked from `DESIGN.md`, fixed for rot | — | — |

A session then starts on at most about 1,900 lines (CLAUDE + DESIGN +
MILESTONE + SYNTAX), a third of today, with zero history in it. The archives
stay in the tree for anyone who wants the story, and nothing reads them by
default.

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

- Session start: `CLAUDE.md`, `DESIGN.md`, `MILESTONE.md`, and `SYNTAX.md`
  when writing `.mn`. Never the archives.
- Session end: a commit message that says what changed and what the board
  said. Five lines, not a hundred. The PROVENANCE entry the march writes at a
  re-pin is the landing record.
- Adversarial review stays; it is the best anti-fluency tool available. A
  fresh agent gets `DESIGN.md` and the diff, never the ledger.
- One model is the editor of record for the docs in a given month and the
  other reviews. Alternating authorship of the same prose is how a register
  drifts.
- Repeal the "no time" rule for planning. Milestones with dates are how a
  person feels progress; the ban on that vocabulary is the single rule most
  responsible for the feeling in the request.

### 5.8 Triage the half-built arcs against the second program

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
- CI green on every push.
- The stranger test, run once by someone who is not Morgan.

### M2, two weeks: the demo

- The Severance Map as static HTML generated from `mentl audit`, three
  colours (absent, present, not yet provable) with the third counted. The
  thirty-second script recorded as a GIF in the README.
- The absence benchmark published as the receipts page; positioning tightened
  per §4 so prior art is named and the claim is the conjunction.
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
| "Context cost is NOT a constraint: hold the ENTIRETY" (CLAUDE ⊜, PLAN header) | Read-path budget of about 1,900 lines; archives are on demand. Attention, not tokens, is the constraint. |
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
| The nine drift modes as prose (CLAUDE) | The structural ones are census shapes in `mentl verify` already; the prose list is deleted. |

## Appendix B · The rot list to fix in the reset

See §1.6. Add: the README verb roster (10) versus `mentl help` (26); the
`src/main.mn` help comment (12 verbs, including `serve`, `repl`, `--with`);
`AGENTS.md`'s toolchain sentence; SYNTAX's three diagnostic tables versus the
66 kinds; the `Hβ.` names in code that name no catalog entry.
