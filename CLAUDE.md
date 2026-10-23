# Mentl — CLAUDE.md · how to work

Three documents, read whole every session: this one (the method), **`PLAN.md`**
(the substance — thesis, kernel, decisions, §7 the state, §11 the one list of
open work) and **`docs/SYNTAX.md`** (the surface — the authority on the
language's form). Nothing else is read-path. History is `git log`; the pin
chain is `boot/PROVENANCE.md`; what the program has not reached is measured by
the medium itself (`mentl verify`, `mentl query`), never kept as prose.

@PLAN.md
@docs/SYNTAX.md

## The one law

**One graph. Two operations: draw an edge (the judgment writes), project
(everything else reads).** A fact computed, copied, cached, filed under a
name, or re-derived anywhere it could be read live is the bug, and its fix is
less code. A reader holding a node follows the node's edges; a name is looked
up once, at the writer, where it resolves in its scope — or at the text
boundary, where a person typed it.

**Five mechanisms carry the law** (PLAN §4⑧): a declaration's face, the
reach, the fork, the whole-truth row and two projections. A new summary, walk,
trial, unreported exit or backend is a reader of one of them; a sixth built
beside them is the drift.

## The thesis is the acceptance test

Mentl closes the gap between what a person means and what they are forced to
write (PLAN §0). A landing is done when a person at the keyboard can see it: a
`mentl` verb on a user program shows the property it advances — proof beats
review, the negative is provable, intent is lossless, computation is durable,
systems explain themselves. The user program is a course lesson
(`examples/pulse/course`, ten programs on one audio chain) or one of the two
scores (`examples/pulse/render`, `examples/wasatch`) wherever one can show the
property: `mentl verify` counts the lessons the medium cannot yet judge clean
(the `QOwed` bounds, `src/board.mn`), and a landing that turns one green
lowers that ceiling and names the lesson in its commit. The commit message
names the property, the verb that shows it, the measurement that was RED
before, and the pin. A change no person can feel at the keyboard is either
infrastructure a named PLAN §11 landing stands on, or it is not done.

## What the hooks refuse — the exact rules

`.claude/settings.json` wires four hooks; each refuses with exit 2 and says
why. There is no flag past any of them.

- **Searching `.mn` source by hand** (`tools/hooks/medium_first.py`, before
  every Grep and Bash call). The Grep tool is refused when its `glob` names
  `.mn` or is `*`/`**`, when its `path` is `src`, `lib` or a `.mn` file, or when
  it has no `path`, `glob` or `type` at all; give it a `path` outside `src/`
  and `lib/`, a `glob` such as `*.md`, or a `type`. In Bash, `grep`, `rg`,
  `ag`, `ack` and `git grep` are refused when an operand names `.mn`, `src` or
  `lib`, and `rg`/`ag`/`ack` with no path are refused at the repository root
  unless a filter excludes `.mn`; a `grep` filtering another command's output
  passes. The confession: a Bash search carrying `# verb-gap: <facet>` passes
  and the facet lands in `.build/verb-gaps.log`; a question no verb answers is
  a missing facet, grown in `src/` in the same landing.
- **Writing `.mn` source from the shell** (same hook): `sed -i`, `perl -i`,
  `tee`, `cp`, `mv`, `install`, a `>`/`>>` redirect, or a python/node script
  that writes a `.mn` path. The writers are the Edit and Write tools and the
  verbs that write their own fixpoint (`mentl fmt`, `mentl tighten`,
  `mentl accept`, `mentl rename`). Shell writes to `.md` files pass.
- **Editing a wheel file the medium was not asked about**
  (`tools/consult-gate.sh`, before every Edit/Write of `src/**.mn` or
  `lib/**.mn`): refused until a `mentl` command whose text names that path has
  run this session (`mentl check src/x.mn` is the cheapest; an answer with
  errors still counts). The ledger `.build/consult` resets at session start.
  Tests, docs and tools are not gated.
- **A drift pattern in an edited `.mn`** (`tools/hooks/post_edit_drift.sh`,
  after every Edit/Write): `tools/drift-audit.sh` runs on the file and the
  named drift mode is shown; `tools/drift-patterns.tsv` holds the patterns.

**The commit boundary** (`.githooks/pre-commit`, installed by
`tools/setup-git-hooks.sh`; never `--no-verify`): the obey gate
(`tools/obey-gate.py`) refuses a ceiling raised in `src/board.mn` or a
`*_max:` raised in `tools/verify-baseline.txt`, a bound deleted (unless its
ceiling was 0), a new `frontier_expected_red:`, more `drift-audit: ignore`
markers, a record of a partial or unlanded landing in any `.md`, a new `.sh`
`.py` `.js` `.mjs` `.ts` file outside `ide/`, a new `.md` file, or more lines
under `tools/`; then `mentl fmt` rewrites each staged `src/` or `lib/` file in
place and re-stages it (a partially staged file is skipped, a file the parser
refuses is restored); the drift audit runs on every staged `.mn`;
`tools/verify.sh` runs when compiler source is staged (stamped — an unchanged
tree answers at once); and a compiler commit needs `.build/frontier-stamp` to
equal the boot's sha, which only a green `tools/frontier-gate.sh` writes. A
docs-only commit runs the obey gate alone, and verify's stamp keys on no
document, so after a docs edit run `bash tools/doc-truth.sh` yourself.

## The candidate compiler

`mentl` runs the pinned boot. A change to the wheel is judged by the compiler
the changed source produces:

```
source tools/wt-env.sh; C=$(wt_m2_ensure) && wt_m2_place "$C" .build/probe
MENTL_BOOT=$PWD/.build/probe/m2.wasm mentl check src/main.mn
wt_battery "$PWD/.build/probe/m2.wasm" tests/micros   # compiled, run and judged
```

- A failed build empties `.build/m2cache/key` and leaves `.build/probe` STALE:
  read `.build/m2cache/m2.err` before anything else.
- `mentl check` refuses what the compile refuses at the executable root: an
  effect reaching `main` or a module value's init with no handler is
  `E_EffectUnhandled` at the end of the judgment, naming where it enters, so
  a compiler effect nobody handles at the root is found by checking
  `src/main.mn`, never only by building.
- A fixture's `// expect: N` is an exit code below 126 (134 is a trap), or its
  refusal class on the first line. Every battery runs through `wt_battery
  <compiler> <dir>` (micros, syntax, proposals, teach): `mentl test` judges a
  directory and prints each fixture's RUN line, and the host runs it;
  `tests/crown` leak-*/sound-* by `E_EffectMismatch` count
  (`tools/crown-gate.sh`); `tests/proposals` and `tests/teach` carry their
  contract on the first line; `tests/frontier` legs live in
  `tools/frontier-gate.sh`. Frontier fixtures bank exact spans, so a line added
  to a fixture's head moves its coordinates; history goes at the tail.
- `mentl fmt --check` of a fixture using a form the boot cannot parse runs
  through the candidate. A probe (`.build/probe/m2.wat`) is comparable only
  within one binary; patch probes there, never in the wheel's source.
- The gates take the candidate as `fresh`: `bash tools/proof-exactness-gate.sh
  fresh`, `bash tools/frontier-gate.sh --compiler fresh`,
  `MENTL_BOOT=… bash tools/crown-gate.sh`, `MENTL_BOOT=… mentl verify`.

## The loop

1. **Choose and ground.** The work is PLAN §11's first step unless a measured
   false proof or a red gate preempts it. `bash tools/state.sh --quick`, then
   ask the medium about every
   file the landing touches: `mentl check <file>`, `mentl <file>:<line>`,
   `mentl query src/main.mn "refs of NAME"`, `mentl where src/main.mn NAME`,
   `mentl why <file> <fn> [<Effect>]`, `mentl query src/main.mn "census
   <shape>"`, `"provider of OP"`, `"writes of FIELD"`, `"text NEEDLE"`,
   `"prose NEEDLE"`, `unreachable`, `heads`, `env`, `reports`.
2. **RED first.** The fixture or bound is measured failing on the pinned boot
   before the change; its output goes in the commit message. A claim about
   behaviour bound for a document, a comment or a commit is a probe's output
   (a scratch `.mn` through `mentl check` and `mentl run`), never memory.
3. **Build the whole landing in `.mn`**, hardest piece first; a dependency the
   form needs is built in the same arc, never handed back as a question.
4. **Prove it**, through the candidate, cheapest first: `mentl check
   src/main.mn` 0; `mentl fmt --check src lib examples` (the boot's check once
   passed a formatter that lost every handler arm's prose, 2026-10-16); the
   batteries through `wt_battery`; crown, proof-exactness and frontier as
   `fresh`; `mentl verify`; then `bash tools/state.sh` — verify, the march,
   frontier, proof-exactness, crown, effect identity, threads, ide — one
   scoreboard, about seven minutes. Runs that long go in the background, one
   wheel-scale run at a time, and their output is read, never predicted. A
   count that fell lowers its ceiling (`src/board.mn`, with a dated reason;
   `tools/verify-baseline.txt` for the cost keys); a count that would rise
   means the landing is reshaped.
5. **Repin when the wheel moved.** `MARCH_REPIN=1 bash tools/march.sh`, then
   the one narrative line replacing the march's placeholder in
   `boot/PROVENANCE.md`. The march rules CLEAN (m2 == m3, repin from m2),
   TRANSITION (m3 == m4, repin from m3) or BROKEN, and holds the candidate's
   image line peak and wall against the boot on the same wheel; on a trap,
   diff the two emits first (PLAN §8, forensics).
6. **Record.** The landed text leaves PLAN §11 and §7 is trued; SYNTAX where
   the surface moved; every changed claim checked against the artifact with a
   verb; a file outside PLAN cites a §11 step by its name, never its number.
7. **Commit on main through the hooks and push** (`git push -u origin main`).
   No branches, no pull requests unless asked. The tree is clean when the
   session ends, and the last message says what changed and what measured.

## The cost law at the cursor

PLAN §5.O: the cost of an operation is the size of the answer it was asked
for. Derivation is O(1) amortized — a fact is computed once and read forever
after; delivery is O(what was asked). At every write ask: what does this read
per operation, and is any of it a fact an edge already carries? A list indexed
in a loop, a name looked up where a handle is in hand, a type cloned where a
correspondence edge belongs, a fixpoint re-run per reader, a whole-subtree fold
per node: each is the Carried-Truth Law broken at the performance scale, and
its fix is the edge. Measure before asserting: `bash tools/profile-self.sh`
samples the self-compile and `tools/guest-profile.py` names the callers; eight
readers once missed the cost that one profile found in a minute. A change
justified by a number and not a law is the wrong change; the board's cost
ceilings only fall, and the image's line peak is held against the pinned boot
compiling the same wheel, so it measures the compiler and never the wheel's
size, and nothing a commit writes moves it.

## Mentl builds Mentl — enforced, not requested

- **Every question about the program is a verb.** `mentl query`, `where`,
  `why`, `check`, `audit`, `teach`, `verify`, `test`, `<file:line>`. A gap is
  confessed with `# verb-gap:` and the facet grown in `src/` in the same
  landing.
- **Every capability lives in the medium's own source.** No new scripts, no new
  documents, no growth of `tools/`: the scripts that remain are scaffolds the
  medium has not absorbed; absorbing one into a verb is always in scope.
- **The wheel's source is the first user program**, written the way SYNTAX asks
  a person to write: verbs over index loops, handlers over flags, edges over
  name lookups, the authored text holding decisions while the medium projects
  the rest. Dead code, side indexes, compensations, decoration and archaeology
  are deleted on sight (`mentl query src/main.mn unreachable`, `census`,
  `mentl verify`).
- **Agents are for breadth only** — reading, fixtures — with the model passed
  explicitly; never to review a design or a document. The artifact is the
  refuter.

## No unfinished work

- **A landing is committed whole.** No "first pin", no "remaining" list: an arc
  too large for one commit is split into landings each whole in itself, each a
  PLAN §11 item.
- **Foundations first, by dependency.** Before a landing starts, every fact it
  reads is carried by an edge already landed; a fact it needs that no landing
  carries is the landing built first. Nothing is left pending, "may" or half
  done because a later landing is missing — the order is chosen so each
  landing is whole when it lands.
- **PLAN §11 is the only list of open work.** A gap found inside the arc is
  fixed inside the arc; nothing is parked anywhere else.
- **A gate is obeyed, never satisfied.** When a gate goes red, the work is what
  it measures. Deleting the symptom where its cause is fixable is the same
  move as raising the ceiling.
- **A ceiling above zero is a landing's RED, never a resting place.** An
  expected-red entry, a silencer, a diagnostic class named and unborn, and a
  landing named outside PLAN §11 are the same thing in four spellings; each
  is attached to the landing that zeroes it.
- **The artifact is the refuter.** Measure before asserting a cause; when the
  cause is unmeasured, build the instrument.

## The forms

The five verbs name the topology of every flow, in code and in prose: `|>`
sequential · `<|` one input fanned to branches · `><` independent pipelines ·
`~>` the handler governing everything to its left · `<~` feedback. `|>` is
never optional: `y |> f |> g`, never `let x = f(y); g(x)`.

The eight questions at every cursor: **Graph** (does an edge already carry
this?) · **Handler** (which handler projects it, with what resume
cardinality?) · **Verb** · **Row** (`+ - & ! Pure`) · **Ownership**
(`own`/`ref`) · **Refinement** · **Gradient** (what annotation unlocks a
capability?) · **Reason** (what edge does the Why walk follow?).

The drift tells, each the one law broken: a closure as a vtable · scope as a
frame stack · effect names as flat strings · a handler chain as a monad stack
· `__closure`/`__ev` beside each other instead of one state · a primitive
special-cased because it is small · N parallel lists where one record was
native · a flag as an int (`mode == 0/1/2`) · claiming done with sub-handles
uncommitted · a `_ =>` arm fabricating a value.

Red flags — stop and restructure: "for now" · "a later pass" · "the smallest
correct change" · "ultimate form reachable now" · "option A vs the safer
option B" (decide it) · "look X up by name" when an edge connects it · a fix
that adds code to compensate rather than deleting what made the compensation
necessary.

## Conventions

- Never attribute the model in a commit; no model identifiers in any artifact.
- Comments state what IS and why, in the developer's voice; a backticked name
  is an edge and must resolve in the module's own reach. History is git's.
- Shell commands that run wheel-scale work (the march, the board, a profile)
  run one at a time.
- Decisions are made, not deferred: full authority was granted; a design
  question is answered by the eight questions and the artifact, and the
  answer is built.
