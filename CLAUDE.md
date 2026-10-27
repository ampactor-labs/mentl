# How to work on Mentl

## Write in plain English

This rule comes first because every model copies the voice of what it reads.
Much of this repository is written in a compressed, slogan-like voice that a
newcomer cannot follow: older parts of PLAN.md and SYNTAX.md, the commit
history, and the compiler's printed messages. Do not imitate it. When you
edit a passage written that way, rewrite that passage plainly.

Write for a capable engineer who has never opened this repository.

- Say who or what does what, and why it matters: subject, verb, object.
- Put one idea in each sentence. Prefer short sentences and common words.
- Use a term this project coined only after saying what it means in ordinary
  words, or point to where it is defined. The glossary below covers the
  common ones.
- Keep exact technical terms. Effect, row, handler, refinement, ownership
  and the five pipe operators are precise. Plain English is not vague.
- No slogans, no aphorisms, no inverted or poetic word order, and no chains
  of abstract nouns.
- Give every number its unit and say what it measures.

This covers everything a person reads: commit messages, comments,
documentation, chat replies, and the messages the compiler prints. A printed
message says what is wrong, where, and what to do about it. When you change
one, update the fixtures that cite its text in the same commit.

Before and after, from this repository:

- Before: "The negative is provable at a sink: information flow is the
  verifier's own walk." After: "`mentl check` now refuses code where an
  untrusted value can reach a trusted output, even through a branch, and says
  where the value came from."
- Before: "severs beyond the module: Alloc — unlocks Real-time safe (proven
  zero allocation)". After: "This function never allocates memory, so it is
  safe to call from a real-time loop."
- Before: "A gate is obeyed, never satisfied." After: "When a check fails,
  fix what it measures. Do not change the check so that it passes."
- Before: "Intent is lossless across a rename." After: "`mentl rename`
  updates every use, label and comment that refers to a declaration, and
  refuses a rename that would change what any of them refers to."

Before you commit text, reread it as that newcomer. If they could not say
back what changed and why after one reading, rewrite it.

### Glossary

- **Landing:** one complete, committed piece of work, usually one PLAN §11
  step.
- **The wheel:** the compiler's own source, `src/` and `lib/`.
- **The boot, a pin:** the pinned compiler binary, `boot/mentl.wasm`. Each
  pin is one entry in its chain, recorded in `boot/PROVENANCE.md`.
- **The candidate:** the compiler built from the source in your working tree.
- **The march:** the self-compile check. The boot compiles the wheel into m2,
  m2 compiles it into m3, and m2 must equal m3 byte for byte.
- **The board:** the limits `mentl verify` checks, kept in `src/board.mn`.
- **The judgment:** the type and effect checker.
- **The medium:** Mentl's compiler together with its `mentl` commands.
- **Edge, projection:** a fact the compiler records in its graph, and a view
  of the graph that something prints or uses.
- **A gate:** a check that must pass before a commit or a pin.
- **Red:** failing.

## What to read

Three documents guide the work. Read this one in full every session. Read the
other two in parts.

- `PLAN.md` holds the design: the thesis, the kernel, the decisions, the
  current state (§7) and the only list of open work (§11).
- `docs/SYNTAX.md` is the authority on how Mentl code is written.

A session starts with `mentl map`, which lists every heading of both
documents and every §11 step with its line number and size. `mentl map <id,
title or word>` prints one part, such as `mentl map §11.1` or `mentl map
"Resume discipline"`, and `mentl mcp` serves the same reads. Before acting, a
landing reads PLAN §0, its own §11 step, and every part it touches. Brief an
agent with the parts it needs, never the whole documents.

Nothing else is required reading. History is `git log`. The chain of pins is
`boot/PROVENANCE.md`. What the compiler cannot do yet is measured by the
compiler itself (`mentl verify`, `mentl query`), never kept as prose. Reading
by parts stays the rule while landings that read this way use less context
than loading both documents whole did (363,609 bytes at the start of every
session, measured 2026-10-26) and succeed as often.

## The main design rule

The compiler keeps one graph of facts about the program. Only the judgment
writes to it, by adding an edge when it decides something. Everything else,
from diagnostics to the editor to code generation, reads the graph and
presents a view of it.

So a fact is never computed a second time, copied, cached, stored under a
name, or re-derived anywhere it could be read from the graph. Each of those
is a bug, and its fix is less code. Code that holds a node follows the node's
edges. A name is looked up once: by the writer, in the scope where it
resolves, or at the text boundary where a person typed it.

Five mechanisms implement this rule, described in PLAN §4⑧: a declaration's
face, the reach, the fork, the whole-truth row and the two projections.
Anything new, such as a summary, a traversal, a trial run, an exit that goes
unreported, or a backend, is built as a reader of one of these five. A sixth
mechanism built beside them is drift.

## When a change is done

Mentl's goal (PLAN §0) is to close the gap between what a person means and
what a language forces them to write. A landing is done when a person at the
keyboard can see the difference: a `mentl` command run on a real program
shows one of five benefits. PLAN gives them short names. In commits and docs,
use the plain words.

- "Proof beats review": the compiler proves a property, so nobody has to
  check it by reading the code.
- "The negative is provable": you can prove what a program never does, such
  as never touching the network.
- "Intent is lossless": what you meant survives edits and renames exactly.
- "Computation is durable": a running program can be saved and resumed.
- "Systems explain themselves": the compiler can say why any fact about the
  program holds.

The real program is a course lesson (`examples/pulse/course`, ten programs on
one audio chain) or one of the two scores (`examples/pulse/render`,
`examples/wasatch`), whichever can show the benefit. `mentl verify` counts
the lessons the compiler cannot yet check cleanly (the `QOwed` bounds in
`src/board.mn`). A landing that makes one pass lowers that limit and names
the lesson in its commit.

A commit message's first line says, in plain words, what a person can now do
or see. The body names the command that shows it, the measurement that
failed before the change, and the new pin. A change that no person can
notice at the keyboard must be groundwork that a named PLAN §11 landing
depends on. Otherwise it is not done.

## The hooks

`.claude/settings.json` installs the hooks. Each refusal states its rule and
the way past it. No flag skips any of them.

- Searching `.mn` source by hand, or writing to it from the shell, is refused
  (`tools/hooks/medium_first.py`). Ask the compiler instead, as the working
  loop below shows.
- A wheel file can be edited only after a `mentl` command naming its path has
  run in this session (`tools/consult-gate.sh`).
- Every edited `.mn` file is checked for drift
  (`tools/hooks/post_edit_drift.sh`).
- A session starts by printing the map.

At commit time `.githooks/pre-commit` runs. Install it with
`tools/setup-git-hooks.sh`, and never commit with `--no-verify`.

- The obey gate (`tools/obey-gate.py`) refuses a commit that raises a limit,
  deletes a bound, adds an expected failure or a silencer, records a partly
  finished landing, adds a script or a `.md` file, or adds lines under
  `tools/`.
- It formats each staged file in `src/` and `lib/`, and drift-checks each
  staged `.mn` file.
- When compiler source is staged, it runs `tools/verify.sh` and requires
  `.build/frontier-stamp` to equal the boot's hash. Only a passing
  `tools/frontier-gate.sh` writes that stamp.
- A commit that changes only documentation runs the obey gate alone, so run
  `bash tools/doc-truth.sh` yourself.

## Testing with the candidate

`mentl` runs the boot. A change to the wheel is judged by the compiler that
the changed source builds:

```
source tools/wt-env.sh; C=$(wt_m2_ensure) && wt_m2_place "$C" .build/probe
MENTL_BOOT=$PWD/.build/probe/m2.wasm mentl check src/main.mn
wt_battery "$PWD/.build/probe/m2.wasm" tests/micros   # compiled, run and judged
```

- A failed build empties `.build/m2cache/key` and leaves `.build/probe` out
  of date. Read `.build/m2cache/m2.err` before anything else.
- `mentl check` refuses what compiling an executable refuses. An effect that
  reaches `main`, or a module value's initializer, with no handler is
  `E_EffectUnhandled`, and the error names where the effect enters. So check
  `src/main.mn` to find a compiler effect that nothing handles. Building alone
  does not show it.
- A fixture states what it expects on its first line. `// expect: N` is an
  exit code below 126, where 134 means a trap. Otherwise the first line names
  the class of error that should refuse it.
- Every test directory runs through `wt_battery <compiler> <dir>`: micros,
  syntax, proposals, teach and frontier. `mentl test` checks a directory and
  prints each fixture's RUN line, and the host runs it. `tests/crown` counts
  `E_EffectMismatch` refusals for its leak-* and sound-* fixtures
  (`tools/crown-gate.sh`). `tests/proposals`, `tests/teach` and
  `tests/frontier` state their contract on the first line, where
  `// propose L:C:` and `// teach N:` refer to lines of the fixture itself.
- Behavior that no first-line contract covers yet, such as a command's
  printed text, an editing workflow or a project route, is checked by a leg
  of `tools/frontier-gate.sh`. A leg refers to fixture line numbers, so a
  line added near the top of a fixture shifts them. Add history at the end.
- `mentl fmt --check` on a fixture that uses syntax the boot cannot parse
  must run through the candidate. A probe (`.build/probe/m2.wat`) can be
  compared only with output of the same binary. Patch probes there, never
  the wheel.
- `mentl land` runs every gate through the candidate. To run one gate by hand
  against the candidate, pass `fresh`: `bash tools/proof-exactness-gate.sh
  fresh`, `bash tools/frontier-gate.sh --compiler fresh`, `MENTL_BOOT=… bash
  tools/crown-gate.sh`, `MENTL_BOOT=… mentl verify`.

## The working loop

1. **Choose the work and check the ground.** The work is PLAN §11's first
   step, unless a failing gate comes first, or a measured false proof that a
   real program hits, in `examples/`, in `lib/` or in the wheel. A problem
   that only a test fixture shows joins the §11 step that owns its mechanism,
   and the fixture becomes that step's failing test. Run `mentl land --quick`
   to see where the tree stands: git, the stamps and verify. Then ask the
   compiler about every file you will touch: `mentl check <file>`,
   `mentl <file>:<line>`, `mentl query src/main.mn "refs of NAME"`,
   `mentl where src/main.mn NAME`, `mentl why <file> <fn> [<Effect>]`, and
   the queries `"census <shape>"`, `"provider of OP"`, `"writes of FIELD"`,
   `"text NEEDLE"`, `"prose NEEDLE"`, `unreachable`, `heads`, `env` and
   `reports`.
2. **Show the failure first.** Before the change, measure the fixture or
   bound failing on the boot, and put its output in the commit message. Any
   claim about behavior that goes into a document, a comment or a commit
   comes from a probe's output, a scratch `.mn` file run through
   `mentl check` and `mentl run`, never from memory.
3. **Build the whole landing in `.mn`,** hardest piece first. If it needs
   something that does not exist yet, build that in the same landing instead
   of handing it back as a question.
4. **Prove it with `mentl land`.** It builds the candidate and checks it
   cheapest first, stopping at the first failure: `mentl check src/main.mn`;
   `mentl fmt --check src lib examples`, since on 2026-10-16 the boot's check
   passed a formatter that dropped every handler arm's comments;
   `mentl verify`'s bounds; the march's ratchets and fixed point; the test
   directories; then the crown, proof-exactness, frontier, effect identity,
   instrument, threads and ide gates. Each result is kept with the exact
   bytes it checked, so a run after a fix redoes only what the fix changed.
   It runs in the background, one compiler-sized run at a time. Read its
   output; never predict it. When a count falls, it stops at the bounds:
   lower that limit, in `src/board.mn` with a dated reason or in
   `tools/verify-baseline.txt` for the cost keys, and run it again. If a
   count would rise, reshape the landing.
5. **Pin once, with `mentl land`, when every gate passes.** The march reports
   CLEAN (m2 equals m3, pin m2), TRANSITION (m3 equals m4, pin m3) or BROKEN.
   It also requires the candidate's peak arena memory, the "line peak" its
   self-compile prints, and its wall-clock time to stay within the boot's on
   the same wheel. On a trap, diff the two emitted modules first (PLAN §8,
   forensics). It then stops for you to replace its placeholder line in
   `boot/PROVENANCE.md` with one sentence describing the change. Running
   `mentl land` again reads the results back on the new boot.
6. **Record it.** Remove the finished text from PLAN §11 and bring §7 up to
   date. Update SYNTAX if the language's surface changed. Check every
   changed claim against the artifact with a command. A file outside PLAN
   names a §11 step by its title, never its number.
7. **Commit on main through the hooks and push** (`git push -u origin
   main`). No branches and no pull requests unless asked. Leave the tree
   clean when the session ends, and end with a message that says what
   changed and what was measured.

## Performance

PLAN §5.O sets the rule: an operation costs no more than the size of the
answer it was asked for. A fact is computed once and then only read, so
deriving it costs a constant amount over time, and delivering an answer
costs in proportion to what was asked.

Whenever you write code, ask what it reads each time it runs, and whether
any of that is a fact the graph already carries. These patterns break the
main design rule at the performance level, and the fix for each is to follow
an edge instead:

- indexing a list inside a loop;
- looking up a name when you already hold a handle to the thing;
- copying a type where an edge between the two belongs;
- rerunning a fixpoint for every reader;
- folding over a whole subtree for every node.

Measure before you claim a cause. `bash tools/profile-self.sh` samples the
compiler compiling itself, and `tools/guest-profile.py` names the callers.
Eight read-throughs once missed a cost that one profile found in a minute. A
change justified by a number but by no rule is the wrong change. The board's
cost limits only go down. The line peak is compared with the boot compiling
the same wheel, so it measures the compiler rather than the size of its
source, and nothing a commit writes can move it.

## Mentl builds Mentl

The hooks and gates enforce these rules. They are not suggestions.

- **Every question about the program has a `mentl` command:** `query`,
  `where`, `why`, `check`, `audit`, `teach`, `verify`, `test` and
  `<file:line>`. Where a question has none, record the gap with
  `# verb-gap:` and add the query to `src/` in the same landing.
- **New capabilities go into the compiler's own source.** No new scripts, no
  new documents and no growth of `tools/`. The scripts that remain are
  scaffolding the compiler has not absorbed yet, and turning one into a
  `mentl` command is always in scope.
- **The wheel is the first real Mentl program.** Write it the way SYNTAX asks
  anyone to write Mentl: the five pipe operators instead of index loops,
  handlers instead of flags, edges instead of name lookups. The written source
  holds the decisions, and the compiler derives the rest. Delete dead code,
  side indexes, workarounds, decoration and leftovers from history on sight
  (`mentl query src/main.mn unreachable`, `census`, `mentl verify`).
- **Use agents only for breadth,** such as reading many files or writing
  fixtures. Pass the model explicitly, and start each agent from the map and
  the parts its brief names. Never use an agent to review a design or a
  document. Running the artifact is what proves a design wrong.

## No unfinished work

- **Commit each landing whole.** No first pass and no list of what remains.
  Split work too large for one commit into landings that are each complete,
  and make each one a PLAN §11 step.
- **Build foundations first.** Before a landing starts, every fact it reads
  must already be carried by an edge from earlier work. A fact it needs that
  nothing carries yet is the landing to build first. Order the work so that
  nothing is left pending, half done or marked "may" while it waits for
  something later.
- **PLAN §11 is the only list of open work.** Fix a gap you find inside the
  work as part of the work. Never park it anywhere else.
- **When a gate fails, fix what it measures.** Deleting the symptom when its
  cause can be fixed is the same as raising the limit.
- **A limit above zero is a landing's failing test, never a resting place.**
  An expected-failure entry, a silenced warning, an error class that is named
  but never produced, and a landing named outside PLAN §11 are one problem in
  four forms. Attach each to the landing that brings it to zero.
- **Running the artifact settles it.** Measure before you claim a cause. If
  the cause cannot be measured yet, build the tool that measures it.

## Writing Mentl code

The five pipe operators name the shape of every flow. Use them in code, and
use them to describe a flow in prose.

- `|>` runs stages in sequence.
- `<|` sends one input to several branches.
- `><` runs independent pipelines side by side.
- `~>` installs a handler over everything to its left.
- `<~` feeds back a value from the previous step.

Always write a sequence with `|>`: `y |> f |> g`, never
`let x = f(y); g(x)`.

Ask eight questions at every line you write:

- **Graph:** does an edge already carry this fact?
- **Handler:** which handler produces it, and how many times does it resume?
- **Verb:** which of the five operators is this flow?
- **Row:** which effects does it have (`+ - & ! Pure`)?
- **Ownership:** is the value owned (`own`) or borrowed (`ref`)?
- **Refinement:** what range or property must the value keep?
- **Gradient:** which annotation would unlock a capability?
- **Reason:** which edge does `mentl why` follow to explain it?

Signs of drift, each a break of the main design rule:

- a closure used as a vtable;
- scope modeled as a stack of frames;
- effect names kept as plain strings;
- a handler chain treated as a monad stack;
- `__closure` and `__ev` kept side by side instead of as one state;
- a primitive special-cased because it is small;
- several parallel lists where one record belongs;
- a flag stored as an integer (`mode == 0/1/2`) instead of a type with named
  cases;
- calling work done while parts of it are uncommitted;
- a `_ =>` match arm that invents a value.

Phrases that mean stop and restructure: "for now", "a later pass", "the
smallest correct change", "the ultimate form is reachable now", "option A
versus the safer option B" (decide it instead), "look X up by name" when an
edge already connects it, and any fix that adds code to compensate instead
of deleting what made the compensation necessary.

## Conventions

- Never credit an AI model in a commit, and never put a model identifier in
  any file.
- Comments say what the code does and why, in plain English, as the
  developer would explain it. A name in backticks is a reference and must
  resolve to a declaration visible from that module. Leave history to git.
- Run compiler-sized jobs, such as the march, the board or a profile, one at
  a time.
- Make decisions instead of deferring them. You have full authority. Answer a
  design question with the eight questions and by running the artifact, then
  build the answer.
