# Mentl — agent entry point

This file is a pointer, not a second rulebook. Read CLAUDE.md whole and the
other two by part — `mentl map` lists their parts, `mentl map <id>` serves one
— before proposing any edit:

- **`CLAUDE.md`** — the method: the one law, the thesis as every landing's
  acceptance test, the medium asked before any edit, the loop.
- **`PLAN.md`** — the substance: the thesis, the kernel, the resolved
  decisions, what the artifact has not reached (§7) and the one ordered list of
  open work (§11), in the dependency order of the five mechanisms (§4⑧).
- **`docs/SYNTAX.md`** — the surface: the authoritative language form. It
  supersedes any syntactic claim made anywhere else, including here.

Nothing else is read-path. History is `git log`; the pin chain is
`boot/PROVENANCE.md`. Where a document and the artifact disagree, the artifact
wins and the document is the next thing to fix.

## Ground before theorizing

```
mentl land --quick   # verify: micros, census, ratchets, doc-truth (stamped-cheap on an unchanged tree)
mentl land           # the landing pass: this tree's compiler judged and pinned once, then the whole board
bash tools/march.sh           # boot → m2 → m3, the fixed point
```

**A gate you did not run is UNKNOWN, never green.**

## Toolchain

`bash tools/wasmtime-get.sh` fetches the stock wasmtime release the gates pin
by version and digest (a `wasmtime` 36 on PATH also serves; `MENTL_WASMTIME`
names one explicitly), and `bash tools/install.sh` writes the `mentl` command.
`boot/mentl.wasm` imports WASI preview1 alone; the boot assembles each
generation itself (`mentl asm`). The march measures the self-compile under GNU
`time`, which the gates need. WABT's disassemblers and `wasm-tools`
(`validate --features all`, `shrink`) are forensic instruments, not
dependencies. If the toolchain is incomplete, say so and stop: reporting a
partial board as a green one is the failure this project exists to make
impossible.

`boot/mentl.wasm` is the compiler; the hand-written seed was deleted at 7401c4b
(2026-07-10) and the cold-bootstrap recipe lives at tag `first-light`. A
landing that changes the wheel re-pins `boot/mentl.wasm` in the same commit as
the source that produced it — `boot/PROVENANCE.md` and `tools/doc-truth.sh`
assert that chain.
