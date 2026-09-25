# Mentl — CLAUDE.md

Mentl is a self-hosting, effect-typed language compiled to WASM. The compiler
(`src/**.mn` and `lib/**`) is written in Mentl and compiled by the pinned wheel
`boot/mentl.wasm`. This is the only file loaded at every session start. Read
`MILESTONE.md` (what we are building now) at the start of a session; read
`DESIGN.md` (what Mentl is, the resolved decisions) before design or kernel
work; the syntax card in `.claude/rules/` loads itself when you touch `.mn`,
and `docs/SYNTAX.md` is the full authority on the language's form.

## Build, run, test

```
cargo build --release --manifest-path tools/runner/Cargo.toml   # once: the wasmtime embedding
bash tools/install.sh              # puts `mentl` on PATH (a pointer to boot/mentl.wasm)
mentl run <file.mn>                # compile, prove, execute
mentl check <file.mn>              # diagnostics only
mentl <file.mn>:<line>             # what is true at a line: type, effects, ownership, why
mentl verify src/main.mn           # the standing bounds on the compiler's own source
bash tools/verify.sh               # micros + syntax battery
bash tools/march.sh                # boot → m2 → m3; asserts m2 == m3, the fixpoint
bash benchmarks/absence/run.sh     # the negative-effect proofs, thirteen programs
```

CI runs all of these on every push; a red badge is the only "not green" there
is. The march needs WABT (`wat2wasm`) on the PATH.

## The five verbs

Write and think in them. When you reach for `->` or "and then", name the verb.

- `|>` sequential: A then B
- `<|` fan one value out to several branches (borrowed)
- `><` independent branches, side by side
- `~>` install a handler over everything to its left
- `<~` feed a result back as the next input

## Eight questions before a line

Graph (does a handle, edge or Reason already carry this?) · Handler (which
one projects it, with what resume cardinality?) · Verb · Row (`+ - & !`) ·
Ownership (`own`/`ref`) · Refinement · Gradient (what annotation unlocks what?)
· Reason (what edge does this leave for `mentl why`?)

## Rules

Each rule names what enforces it. A rule marked "review" is enforced by
reading the diff, nothing else.

1. **Carry the handle, read live.** A fact computed, copied, snapshotted or
   re-derived where it could be read live is the bug, and the fix is less
   code. (`mentl verify`'s census shapes; otherwise review.)
2. **Restructure or stop.** If a fix fits in a patch, the structure is wrong.
   A silent fallback is deleted, never wrapped or renamed. (review)
3. **Measure before you assert a cause.** Run the fixture, the march or a
   probe, then edit. A hypothesis is not a finding. (review)
4. **A new gate is seen red first.** (PR checklist)
5. **Ratchets only fall.** Raising a bound is an explicit commit whose reason
   lives in the bound's own comment in `src/board.mn`. (`mentl verify`)
6. **One home per truth.** Docs state what is; git holds what was. No dates,
   no incident stories, no counts copied into prose. (doc lints in pre-commit
   and CI)
7. **Ask the medium before the shell.** `mentl <file:line>`, `query`, `audit`
   and `why` first; grep second, and when grep wins, name the missing
   projection in the commit. (unenforced)

## How we work

- The milestone's acceptance tests are the definition of done. "Ultimate" is
  the direction (`DESIGN.md`), not the bar for a commit.
- One landing is the change, `verify`, `march`, and a five-line commit message
  saying what changed and what the board said. The march writes the
  PROVENANCE entry when it re-pins.
- Deep kernel reasoning stays in one conversation. Breadth goes to fresh
  agents with the model passed explicitly. A fresh-context reviewer is for
  high-stakes landings; it gets `DESIGN.md` and the diff, and it reviews
  correctness, not taste.
- A decision lives in `docs/decisions/` as a short record with a status. To
  reopen one, write a new record; do not re-argue it in a session.
- A restructuring names the acceptance test or `felt` issue it unblocks.
- Report what changed and what was measured. If it is not done, say so in the
  first sentence.
- Comments say what a thing is. The first line is the lede; backticked names
  must resolve. History goes in git.
- Never attribute Claude in commits.

## Where things are

`MILESTONE.md` · `DESIGN.md` · `docs/decisions/` · `docs/SYNTAX.md` ·
`docs/MENTL_EDIT.md` (the IDE) · `docs/NATIVE.md` · `docs/POSITIONING.md` ·
`docs/archive/` (history; not read at session start) · GitHub issues (every
named gap) · `.claude/rules/model-opus.md`, `model-fable.md` (twenty-line
per-model notes; this file is model-neutral)
