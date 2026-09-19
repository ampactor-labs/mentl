# Mentl — agent entry point

This file is a POINTER, not a second rulebook. It used to restate the method
in weaker words and drifted: it told agents to keep `bootstrap/mentl.wat`
aligned for two months after the seed was deleted, which sent every fresh
session hunting a directory that does not exist. One truth, one home — the
same law the code is held to.

## Read these three, whole, before proposing any edit

- **`CLAUDE.md`** — method: how to work. Anchors, the five verbs, the drift
  modes, the red-flag table, the dispatch criterion.
- **`PLAN.md`** — substance: what is true. The reframe, the kernel, the
  resolved decisions, the phases, the honest audit of what is NOT reached.
- **`docs/SYNTAX.md`** — surface: the authoritative language form. It
  supersedes any syntactic claim made anywhere else, including here.

`LEDGER.md` (what happened at pin X and why) and `RESIDUE.md` (every named
gap; a gap not in it does not exist) are REFERENCE — consult on demand,
never read whole. Everything else under `docs/` is either linked from those
five or is archaeology.

Interrogate, don't absorb. These docs are the current best answer, not
authority; where a doc and the artifact disagree, the artifact wins and the
doc is the next thing to fix.

## Ground before theorizing

```
bash tools/verify.sh      # the floor — micros, census, ratchets, doc-truth
bash tools/state.sh       # the whole board
bash tools/march.sh       # boot → m2 → m3, asserts the m2 == m3 fixpoint
```

`verify` is stamped-cheap on an unchanged tree. **A gate you did not run is
UNKNOWN, never green.**

## Toolchain — the gates need more than `mentl` does

`bash tools/install.sh` puts `mentl` on the path and it needs only the
runner, `cargo build --release --manifest-path tools/runner/Cargo.toml`
(a wasmtime embedding; the wasmtime CLI is not used anywhere). The gates
need:

- **tools/runner** — runs `boot/mentl.wasm`; every verb and every gate
  leg. It owns what the CLI could not: wasi-threads' spawn, the exec seam
  `mentl run`/`mentl test` execute through, and the listening socket
  `session`/`space` serve on.
- **WABT** (`wat2wasm`, `wasm-validate`, `wasm-objdump`) — the march
  assembles each generation's WAT, so `tools/march.sh` cannot run without it.
- **wasm-tools** — `validate --features all`, and `shrink` for minimal repros.

If the toolchain is incomplete, say so and stop. Reporting a partial board as
a green one is the failure this project exists to make impossible.

## The seed is deleted

`bootstrap/` does not exist. The hand-WAT seed was deleted at 7401c4b
(2026-07-10, the day after first light); `boot/mentl.wasm` — the pinned
fixpoint wheel — IS the compiler. The build loop is boot → m2 → m3 with
`m2 == m3` asserted. The cold-bootstrap recipe is archaeology at tag
`first-light`.

A landing that changes the wheel re-pins `boot/mentl.wasm`, and that binary
belongs in the same commit as the source that produced it — `boot/PROVENANCE.md`
and `tools/doc-truth.sh` both assert that chain.
