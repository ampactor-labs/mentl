# Mentl — agent entry point

This file points to the documents that hold the rules and adds no rules of its
own. Before you propose any edit, read CLAUDE.md in full and the other two
documents in parts. `mentl map` lists their parts, and `mentl map <id>` prints
one of them.

- `CLAUDE.md` holds the method: the main design rule, the thesis used as the
  acceptance test for every landing, consulting the medium before any edit,
  and the working loop.
- `PLAN.md` holds the substance: the thesis, the kernel, the resolved
  decisions, what the artifact does not do yet (§7), and the only list of open
  work (§11), ordered by how the five mechanisms (§4⑧) depend on each other.
- `docs/SYNTAX.md` holds the surface syntax and is the authority on how the
  language is written. It overrides any claim about syntax made anywhere else,
  including in this file.

Nothing else is required reading. History is in `git log`, and the chain of
pins is in `boot/PROVENANCE.md`. When a document and the artifact disagree,
the artifact is right, and the document is the next thing to fix.

## Ground before theorizing

```
mentl land --quick   # verify: micros, census, ratchets, doc-truth (stamped-cheap on an unchanged tree)
mentl land           # the landing pass: this tree's compiler judged and pinned once, then the whole board
bash tools/march.sh           # boot → m2 → m3, the fixed point
```

If you did not run a gate, its result is unknown. Never report it as passing.

## Toolchain

`bash tools/wasmtime-get.sh` downloads the stock wasmtime release that the
gates pin by version and digest. A `wasmtime` 36 on PATH also works, and
`MENTL_WASMTIME` names a specific one. `bash tools/install.sh` writes the
`mentl` command. `boot/mentl.wasm` imports only WASI preview1, and the boot
assembles each compiler generation itself (`mentl asm`). The march measures
the self-compile with GNU `time`, so the gates need that program. WABT's
disassemblers and `wasm-tools` (`validate --features all`, `shrink`) are used
only to investigate failures, and nothing requires them. If the toolchain is
incomplete, say so and stop. Reporting a partial board as a passing one is
the failure this project exists to make impossible.

`boot/mentl.wasm` is the compiler. The hand-written seed was deleted in commit
7401c4b (2026-07-10), and the recipe for a cold bootstrap is kept at the tag
`first-light`. A landing that changes the wheel pins a new `boot/mentl.wasm`
in the same commit as the source that produced it. `boot/PROVENANCE.md`
records that chain, and `tools/doc-truth.sh` checks it.
