# Mentl

A programming language and self-hosting compiler with an algebraic effect system that compiles to WebAssembly. An effect is something a function does besides return a value, such as allocating or printing, and each function's type lists them. A negated effect such as `!Network` is a claim the compiler proves through every call, or it refuses to build. The compiler is written in Mentl: the pinned binary in `boot/` compiles `src/` and `lib/` into a compiler that reproduces it byte for byte, and that fixed point is the release.

**Status: working.** The language and the command surface may still change, and the verifier is incomplete by design: a claim it cannot decide is reported as pending debt at compile time and the program still builds.

## Quick start

The compiler is one WebAssembly module, `boot/mentl.wasm` — it compiles Mentl, including its own source, and runs on any host that provides the WASI seam (WASI preview1, shared memory, `mentl_host`, thread-spawn, sockets). Two hosts ship in `tools/`: the reference Rust runner (`tools/runner`, embedding wasmtime — needs a Rust toolchain to build) and a Node host (`tools/host-node` — needs node ≥ 20, zero Rust). `tools/install.sh` uses the runner when it is built and falls back to the Node host otherwise.

```sh
git clone https://github.com/ampactor-labs/mentl.git && cd mentl
bash tools/install.sh     # writes ~/.local/bin/mentl, a live pointer to boot/mentl.wasm through the selected host
mentl run lib/tutorial/00-hello.mn
```

The last command compiles the first lesson, proves its claims and runs it. It prints three lines:

```
Hello, kernel. The medium is reading you back.
Hello, oracle. The medium is reading you back.
Hello, octopus. The medium is reading you back.
```

`mentl new hello` writes a one-file project `hello.mn` in the current directory and `mentl run hello` runs it; the file's imports are its manifest. A bare `mentl` at a terminal lists the `.mn` files in the directory and the verbs that apply to each. The shim is a pointer into the checkout, so after a re-pin of `boot/mentl.wasm` the installed command is the new compiler with no further step.

## Usage

The verbs, as `mentl help` lists them (the table is `verb_specs` in `src/cli.mn`):

```
mentl run <path> [args]         compile, prove, execute; a hole or a refuted claim refuses
mentl check <path>              diagnostics only, no output
mentl compile <path>            emit WebAssembly text to stdout
mentl <file>:<line>[:<col>]     project one position: type, effects, ownership, the Reason chain;
                                at a ?? hole, the candidates that survived the proof
mentl edit [path]               the cursor session in the terminal
mentl space                     serve the browser IDE at http://localhost:7378/ide/
mentl fmt <path>                rewrite the file in canonical layout
mentl audit <path>              the capability set, and the !E claims the file could add
mentl query <path> <question>   why, type, effects, ownership, unreachable declarations, census
mentl test [dir]                compile and run every fixture in a directory against its // expect: line
mentl new <name>                write <name>.mn in the current directory
mentl mcp                       serve the proof gate as an MCP server on stdio
mentl help                      the full table: also tighten, where, why, teach, doc, resume,
                                session, serve, repl, march and verify
```

A target is a module name or a file path, from any directory.

### A refused claim

```
type Percent = Int where 0 <= self && self <= 100

fn main() = {
  let p: Percent = 140
  42
}
```

`mentl run` on this file reports `E_RefinementRejected` at the claim's line; the message is "refinement predicate proven false at compile time" (`src/types.mn`). It then prints `mentl: refusing to emit` with the count of undischarged claims, writes no program and exits 1 (`executable_gate` in `src/pipeline.mn`). `mentl check` reports the same diagnostics and emits nothing, so an editor can keep working on a file that does not yet prove.

### The gate over MCP

`mentl mcp` serves the same gate to AI agents over the Model Context Protocol (JSON-RPC, one message per line on stdin and stdout) with a single tool, `propose`. It takes Mentl source, compiles it, and answers `PROVEN` with the artifact written to `.build/mcp/last.wat`, or `REFUSED` with each undischarged claim at its source span. `.mcp.json` in the repository root registers the server for a client that reads that file.

## How it works

Source goes through a lexer and a parser into one graph: every node of the syntax tree is a handle in it, and a comment is attached to the node it precedes as a Reason edge. Type inference is the graph's only writer. It infers types in the Hindley-Milner style, without annotations, and beside each type it writes the effect row, the ownership grade (whether a value is consumed or borrowed), the refinement obligations and a Reason for every binding. Everything else (a diagnostic, the position projection `mentl <file>:<line>`, the formatter, the IDE) is a read of that graph. Lowering and the WebAssembly text emitter (`src/backends/wasm.mn`) are reads too, and the host in `tools/runner` executes the emitted module.

Effects are algebraic: an `effect` declaration names operations, code calls them like functions, and a handler installed with `~>` over an expression gives them their meaning and subtracts them from the expression's row. A row is a set with a Boolean algebra (`+`, `-`, `&`, `!` and `Pure`), and a negated name is an obligation to prove that the operation is unreachable from the function, through every callee and through stored closures. A handler's state, its closure and a captured continuation share one heap record, which is why a paused computation can be saved by copying bytes (`lib/persist.mn`, `mentl resume`). Refinement types (`type Percent = Int where 0 <= self && self <= 100`) add predicates that the verifier discharges where it can decide them; the rest is reported as pending debt.

Self-hosting means the compiler is written in the language it compiles, and the fixed point is the test of it. `boot/mentl.wasm` compiles the 60,776 lines of `src/` and `lib/` (counted with `wc -l`, tutorial excluded) into a second compiler. That compiler compiles the same source again, and the two outputs must be identical byte for byte. The hand-written seed that first produced such a binary was deleted on 2026-07-10, so the pinned binary is the only bootstrap. Each re-pin appends an entry to `boot/PROVENANCE.md` with the sha256 the march read from the file it copied, and `tools/doc-truth.sh` compares that entry with `sha256sum boot/mentl.wasm` on every verify. At the head entry the self-compile emits 419,267 lines of WebAssembly text in 9.94 s of wall time with a peak of 978 MB of memory, measured by the march under GNU time on the author's machine.

Two decisions shaped the design. The graph has one writer so that no tool can hold a second copy of a fact that could drift from the first, and every tool answers by reading it. The effect row carries negation as a first-class claim, because a claim the compiler can refuse against is what makes "this plugin cannot reach the network" checkable.

The essays that used to open this README are in [docs/READING.md](docs/READING.md), and the claims measured against the field, each with its command, are in [docs/POSITIONING.md](docs/POSITIONING.md). The language reference is [docs/SYNTAX.md](docs/SYNTAX.md); `PLAN.md` holds the design decisions and, in its §7, the audit of what the code has not reached; `CLAUDE.md` is the working method for changing the compiler. The ten lessons in `lib/tutorial/` are written to be read first and run second, [lib/dsp/README.md](lib/dsp/README.md) shows the feedback verb `<~` on audio, and [ide/README.md](ide/README.md) describes the browser IDE.

## Testing

There is no `.github/` directory, so no GitHub Actions workflow runs here. The gates run on the author's machine, and each re-pin of `boot/mentl.wasm` records their verdicts in the new `boot/PROVENANCE.md` entry. The head entry reads: crown green, proof-exactness green, effect-identity green, frontier 390 pass / 0 red / 2 expected-red, and the micro battery and census not run at that pin. `tools/ci/run-board.sh` wraps the board for a self-hosted runner and nothing in the repository invokes it. The gates need the runner from Quick start plus WABT (`wat2wasm`, `wasm-validate`, `wasm-objdump`) to assemble each generation; the browser leg of the IDE gate needs Chrome and skips with a message without it.

```sh
bash tools/state.sh                  # the board: verify, then every gate below, one scoreboard; --quick runs verify only
bash tools/verify.sh                 # the 149 programs in tests/micros (each states its expected exit code or refusal on
                                     # its first line) through the pinned boot and again through the compiler this tree's
                                     # source produces; the 17 form fixtures in tests/syntax; the floors and rows contracts;
                                     # the census ratchet (tools/verify-baseline.txt, counts the compiler's own source may
                                     # not raise); and doc-truth. Stamped, so an unchanged tree answers at once
bash tools/march.sh                  # boot compiles the source to m2, m2 compiles it to m3, assert m2 == m3; on a mismatch
                                     # it runs m4 and rules TRANSITION (re-pin from m3) or BROKEN; --fixpoint forces the m4 leg
bash tools/frontier-gate.sh          # contracts over the 161 fixtures in tests/frontier and the ?? authoring workflows; a green
                                     # run stamps the boot sha, and the pre-commit hook refuses a compiler commit without it
bash tools/crown-gate.sh             # !E soundness: the 31 leak-* crucibles in tests/crown must report E_EffectMismatch and
                                     # the 31 sound-* crucibles must not
bash tools/proof-exactness-gate.sh   # a value-position hole refuses the executable, pending debt is reported, a ?? inside a
                                     # call's argument list still runs
bash tools/effect-identity-gate.sh   # the Fail and Abort effects dispatch separately (a micro), and each is declared once
bash tools/instrument-gate.sh        # the diagnostics instrument can go red: a missing module or a type error exits nonzero,
                                     # and a clean program still emits (the negative control)
bash tools/thread-gate.sh            # the compile spawns as many threads as the source says, read as a delta between two programs
bash tools/ide-gate.sh               # the browser IDE: a Node twin drives ide/wheel-worker.js, then headless Chrome loads the page
bash tools/doc-truth.sh              # the recorded pin equals the binary's sha256, the ledger's head pin matches, and every
                                     # tools/*.sh command and mentl verb the docs name exists
bash benchmarks/absence/run.sh       # the 13 absence tasks: 8 must refuse naming the class, 5 must prove (benchmarks/absence/README.md)
bash tools/setup-git-hooks.sh        # installs .githooks/pre-commit: fmt on staged sources, the drift audit, verify when compiler
                                     # source is staged, and the frontier stamp
```

Three things are not covered. The determinism probe (the same binary on the same input emits the same bytes) runs only with `bash tools/march.sh --fixpoint`, and `tools/state.sh` reports when it has not run at the current boot. `tools/oracle-selftest.sh`, which runs the proposer over a corpus of holes, runs by hand and is off the board. The runner crate has no tests of its own.

## Limitations

The verifier is sound and incomplete: a claim it cannot decide is recorded as pending debt, reported at compile time, and the program still builds. The absence proof `!E` is keyed by effect name, its soundness under polymorphism is an open item (PLAN.md §4③), and on the compiler's own source an effect operation with no handler installed anywhere still compiled with zero diagnostics (PLAN.md §7). The compiler emits WebAssembly only and runs on any host providing the seam contract; two such hosts ship in `tools/` (the Rust runner and the Node host). There is no published package, and no CI service runs the gates.

- Diagnostic classes are armed one at a time, each once the compiler's own source is clean of it; an unarmed class prints its diagnostic and the program is still emitted. Two cases are measured. A field access whose offset the graph cannot prove emits an `unreachable` instruction and traps at run time, reported as `T_FieldOffsetUnprovable`; the compiler's own source had four such sites when the class was added (PLAN.md §11). A comparison whose operand type is still unresolved at emit compares one machine word, which for a heap value compares addresses, reported as `T_EqTypeUnprovable`.
- Memory is a monotone image: the allocator never frees, there is no runtime arena, and the module imports a 4 GB shared memory; the self-compile peaks at 978 MB (the head entry of `boot/PROVENANCE.md`). A warm start restores the analysed image and then re-derives the compile over it (PLAN.md §5.O).
- The browser IDE recompiles the file on each cursor settle, cannot run the compiled program in the page, and needs a browser with cross-origin isolation for shared memory (`ide/README.md`). The IDE gate's browser leg has run only where Chrome was present.
- `docs/SYNTAX.md` is written as the target form and names where the parser lags it: `E_FeedbackNoContext` is declared with no construction site, the world half of `E_ResumeWorldMismatch` is not wired, and a chained comparison in a refinement degrades to pending debt instead of a rejection.
- The toolchain is bash on Linux: the gates are shell scripts, WABT and wasm-tools are external, and there is no native backend (PLAN.md, Phase 10).

## Roadmap

The order is PLAN.md §11. Three items from it:

- The modal world-index (§4③, Phase 6.3), so that `!E` is sound under polymorphism at every altitude. It is open because the rows-as-capabilities result in the literature discharges the positive half only. The negation half is this project's own burden, and each rule lands as a crucible in `tests/crown` first.
- The resident Space session (§11, Arc E): one WebAssembly instance in the browser that stays alive across edits and projects the eight aspects at the caret. The substrate exists (`ide/wheel-worker.js`, `tools/ide-gate.sh`); the browser leg is measured only where Chrome is present.
- The Severance Map (§11, Arc G): a page that bands each module by the capabilities proven absent, with a third colour for what the crown cannot yet prove. It comes after the Space session, because the page ships inside `space`; the third colour exists because the crown is still open, and a two-colour map over a partly proven mechanism would overstate the proof.

## License

Two license files are in the tree: `LICENSE-APACHE` (Apache License 2.0) and `LICENSE-MIT` (MIT), both copyright 2026 Morgan Espitia. No manifest states how they combine.
