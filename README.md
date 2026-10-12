# Mentl

**Mentl closes the gap between what a person means and what they are forced to write.** Most languages make you spell out what their compiler could have worked out — borrows, error plumbing, async-ness, which effects a function has. Mentl's compiler infers those, so the source holds only your decisions: what a function must never do, what bound a value keeps, what width a number needs. At any line it says what is true there and why; at a hole (`??`) it proposes the next move it can prove, and when two proven moves mean different things it asks which one you meant instead of guessing. A claim you write is proven or the program does not build — which also means the same guarantees hold for code you did not write yourself.

Mentl is a programming language and self-hosting compiler with an algebraic effect system that compiles to WebAssembly. An effect is something a function does besides return a value, such as allocating or printing, and each function's type lists them. A negated effect such as `!Network` is a claim the compiler proves through every call, or it refuses to build. The compiler is written in Mentl: the pinned binary in `boot/` compiles `src/` and `lib/` into a compiler that reproduces it byte for byte, and that fixed point is the release.

**Status: working.** The language and the command surface may still change, and the verifier is incomplete by design: a claim it cannot decide is reported as pending debt at compile time and the program still builds.

## Quick start

The compiler is one WebAssembly module, `boot/mentl.wasm`, and it imports WASI preview1 and nothing else, so any engine that speaks that one interface hosts it. The browser is its first host — Mentl Space (`ide/`, served at https://space.ampactor.dev/ from GitHub Pages) runs the unmodified binary in a worker with no toolchain at all. In a terminal the host is the stock `wasmtime` binary, pinned by version and digest and fetched by `bash tools/wasmtime-get.sh`; nothing of Mentl runs in any language but WebAssembly and its text form, and the repository contains no code in any other language than the shell scripts that drive the gates. `tools/install.sh` writes the `mentl` command as a pointer to the binary through that engine; three verbs are the command's own because each needs something a WASI module cannot create — `run` a process for the module the compiler emits, `space` a listening socket for the page, and a resident `session` the process's own stdin is.

```sh
git clone https://github.com/ampactor-labs/mentl.git && cd mentl
bash tools/wasmtime-get.sh  # the pinned engine, into .build/wasmtime (or put a wasmtime 36 on your PATH)
bash tools/install.sh       # writes ~/.local/bin/mentl, a live pointer to boot/mentl.wasm through that engine
mentl run lib/tutorial/00-hello.mn
```

The last command compiles the first lesson, proves its claims and runs it. It prints three lines:

```
Hello, kernel. The medium is reading you back.
Hello, oracle. The medium is reading you back.
Hello, octopus. The medium is reading you back.
```

`mentl new hello` writes a one-file project `hello.mn` in the current directory and `mentl run hello` runs it; the file's imports are its manifest. A bare `mentl` at a terminal lists the `.mn` files in the directory and the verbs that apply to each. The shim is a pointer into the checkout, so after a re-pin of `boot/mentl.wasm` the installed command is the new compiler with no further step.

The toolchain's own environment variables (the engine, the compiler under test, ports, the bin dir) are listed with their defaults and readers in one table at the head of `tools/wt-env.sh`; a program's environment is its own, read through `lib/environ.mn`, and `mentl run` passes it exactly the variables `mentl query <file> env` names, from the shell or the project's `.env`.

## Usage

The verbs, as `mentl help` lists them (the table is `verb_specs` in `src/cli.mn`):

```
mentl run <path> [args]         compile, prove, execute; a hole or a refuted claim refuses
mentl check <path>              diagnostics only, no output
mentl compile <path>            emit WebAssembly text to stdout
mentl <file>:<line>[:<col>]     project one position: type, effects, ownership, the Reason chain;
                                at a ?? hole, the candidates that survived the proof
mentl edit [path]               the cursor session in the terminal
mentl space                     stage and serve the browser IDE at http://127.0.0.1:7397/
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

### The same reads over MCP

`mentl mcp` serves the same gate over the Model Context Protocol (JSON-RPC, one message per line on stdin and stdout) to any editor or tool that speaks it. Its `propose` tool takes Mentl source, compiles it, and answers `PROVEN` with the artifact written to `.build/mcp/last.wat`, or `REFUSED` with each undischarged claim at its source span; `at`, `query`, `audit`, `teach` and `frontier` are the resident session's reads over the same wire. `.mcp.json` in the repository root registers the server for a client that reads that file.

## How it works

Source goes through a lexer and a parser into a syntax tree whose every node has a handle in one graph, and a comment is attached to the node it precedes as a Reason edge. A node still holds its children inside itself rather than as edges of that graph; making the graph the program's only home is the work in progress (PLAN.md §7, its first entry). Type inference is the graph's only writer. It infers types in the Hindley-Milner style, without annotations, and beside each type it writes the effect row, the ownership grade (whether a value is consumed or borrowed), the refinement obligations and a Reason for every binding. Everything else (a diagnostic, the position projection `mentl <file>:<line>`, the formatter, the IDE) is a read of that graph. Lowering and the WebAssembly text emitter (`src/backends/wasm.mn`) are reads too, and the host executes the emitted module (the browser's worker in Mentl Space, the wasmtime engine behind the `mentl` command in a terminal).

Effects are algebraic: an `effect` declaration names operations, code calls them like functions, and a handler installed with `~>` over an expression gives them their meaning and subtracts them from the expression's row. A row is a set with a Boolean algebra (`+`, `-`, `&`, `!` and `Pure`), and a negated name is an obligation to prove that the operation is unreachable from the function, through every callee and through stored closures. A handler's state, its closure and a captured continuation share one heap record, which is why a paused computation can be saved by copying bytes (`lib/persist.mn`, `mentl resume`). Refinement types (`type Percent = Int where 0 <= self && self <= 100`) add predicates that the verifier discharges where it can decide them; the rest is reported as pending debt.

Self-hosting means the compiler is written in the language it compiles, and the fixed point is the test of it. `boot/mentl.wasm` compiles the source in `src/` and `lib/` into a second compiler. That compiler compiles the same source again, and the two outputs must be identical byte for byte. The hand-written seed that first produced such a binary was deleted on 2026-07-10, so the pinned binary is the only bootstrap. Each re-pin appends an entry to `boot/PROVENANCE.md` with the sha256 the march read from the file it copied, and `tools/doc-truth.sh` compares that entry with `sha256sum boot/mentl.wasm` on every verify. The same entry records what the march measured under GNU time: the lines of WebAssembly text the self-compile emits, its wall time and its peak memory.

Two decisions shaped the design. The graph has one writer so that no tool can hold a second copy of a fact that could drift from the first, and every tool answers by reading it. The effect row carries negation as a first-class claim, because "this never reaches the network" is something people mean and no mainstream language lets them say, and a claim the compiler can refuse against is what makes it checkable.

The essays that used to open this README are in [docs/READING.md](docs/READING.md), and the claims measured against the field, each with its command, are in [docs/POSITIONING.md](docs/POSITIONING.md). The language reference is [docs/SYNTAX.md](docs/SYNTAX.md); `PLAN.md` holds the design decisions and, in its §7, the audit of what the code has not reached; `CLAUDE.md` is the working method for changing the compiler. The ten lessons in `lib/tutorial/` are written to be read first and run second, [lib/dsp/README.md](lib/dsp/README.md) shows the feedback verb `<~` on audio, and [ide/README.md](ide/README.md) describes the browser IDE.

## Testing

One GitHub Actions workflow runs here, `.github/workflows/deploy-space.yml`, and it only publishes the browser IDE to GitHub Pages. The gates run on the author's machine, and each re-pin of `boot/mentl.wasm` records their verdicts in the new `boot/PROVENANCE.md` entry, whose head entry is the current board. `tools/ci/run-board.sh` wraps the board for a self-hosted CI machine and nothing in the repository invokes it. The gates need the stock wasmtime engine from Quick start (`bash tools/wasmtime-get.sh`) — the boot assembles each generation itself (`mentl asm`); the browser leg of the IDE gate needs Chrome and skips with a message without it.

```sh
bash tools/state.sh                  # the board: verify, then every gate below, one scoreboard; --quick runs verify only
bash tools/verify.sh                 # the programs in tests/micros (each states its expected exit code — below 126, or 134
                                     # for a trap, the range the WASI host reports — or its refusal on its first line)
                                     # through the pinned boot and again through the compiler this tree's
                                     # source produces; the form fixtures in tests/syntax; the floors and rows contracts;
                                     # the census ratchet (tools/verify-baseline.txt, counts the compiler's own source may
                                     # not raise); and doc-truth. Stamped, so an unchanged tree answers at once
bash tools/march.sh                  # boot compiles the source to m2, m2 compiles it to m3, assert m2 == m3; on a mismatch
                                     # it runs m4 and rules TRANSITION (re-pin from m3) or BROKEN; --fixpoint forces the m4 leg
bash tools/frontier-gate.sh          # contracts over the fixtures in tests/frontier and the ?? authoring workflows; a green
                                     # run stamps the boot sha, and the pre-commit hook refuses a compiler commit without it
bash tools/crown-gate.sh             # !E soundness: every leak-* crucible in tests/crown must report E_EffectMismatch and
                                     # every sound-* crucible must not
bash tools/proof-exactness-gate.sh   # a value-position hole refuses the executable, pending debt is reported, a ?? inside a
                                     # call's argument list still runs
bash tools/effect-identity-gate.sh   # the Fail and Abort effects dispatch separately (a micro), and each is declared once
bash tools/instrument-gate.sh        # the diagnostics instrument can go red: a missing module or a type error exits nonzero,
                                     # and a clean program still emits (the negative control)
bash tools/thread-gate.sh            # the compile spawns as many threads as the source says, read as a delta between two programs
bash tools/ide-gate.sh               # the browser IDE: a Node twin drives ide/wheel-worker.js, then headless Chrome loads the page
bash tools/doc-truth.sh              # the recorded pin equals the binary's sha256, the ledger's head pin matches, and every
                                     # tools/*.sh command and mentl verb the docs name exists
bash benchmarks/absence/run.sh       # the absence tasks: each must refuse naming its class or must prove (benchmarks/absence/README.md)
bash tools/setup-git-hooks.sh        # installs .githooks/pre-commit: fmt on staged sources, the drift audit, verify when compiler
                                     # source is staged, and the frontier stamp
```

Three things are not covered. The determinism probe (the same binary on the same input emits the same bytes) runs only with `bash tools/march.sh --fixpoint`, and `tools/state.sh` reports when it has not run at the current boot. `tools/oracle-selftest.sh`, which runs the proposer over a corpus of holes, runs by hand and is off the board. The engine is an unmodified wasmtime release, pinned by version and digest in `tools/wasmtime-get.sh`, and nothing in the repository tests it.

## Limitations

The verifier is sound for the claims it decides and incomplete: a claim it cannot decide is recorded as pending debt, reported at compile time, and the program still builds. The absence proof `!E` is keyed by effect name, and its soundness under polymorphism at every altitude — the modal world-index — is an open item (PLAN.md §4③); a reachable effect operation with no handler installed refuses the executable (`E_EffectUnhandled`, since 2026-09-27). The compiler emits WebAssembly text, which its own `mentl asm` assembles to the module's bytes, and imports WASI preview1 alone, so any preview1 engine hosts it; the two hosts in the repository are the browser worker (`ide/wheel-worker.js`) and the `mentl` command over the stock wasmtime binary. There is no published package, and no CI service runs the gates.

- Diagnostic classes are armed one at a time, each once the compiler's own source is clean of it; an unarmed class prints its diagnostic and the program is still emitted. `diag_refuses` in `src/types.mn` is the live list of armed classes, and PLAN.md §7 carries the audit of what still narrates.
- Memory is one image: an extent's allocations are reclaimed at its exit by the arena (`(body) ~> arena`, since 2026-10-03) and nothing else frees; the module declares a 32-page minimum shared memory grown on demand, and the self-compile's peak is the cost line of the head entry of `boot/PROVENANCE.md`. A warm start restores the analysed image and then re-derives the compile over it (PLAN.md §5.O).
- The browser IDE keeps one resident compiler instance per page for its caret reads but still recompiles the whole file on each edit, cannot run the compiled program in the page, and needs cross-origin isolation for shared memory (`ide/README.md`). The IDE gate's browser leg has run only where Chrome was present.
- `docs/SYNTAX.md` is written as the target form and names where the parser lags it: `E_FeedbackNoContext` is declared with no construction site, the world half of `E_ResumeWorldMismatch` is not wired, and a chained comparison in a refinement degrades to pending debt instead of a rejection.
- The toolchain is bash on Linux: the gates are shell scripts, WABT's disassemblers and wasm-tools are optional forensic instruments, and there is no native backend (PLAN.md, Phase 10).

## Roadmap

The order is PLAN.md §11. Three items from it:

- The modal world-index (§4③, Phase 6.3), so that `!E` is sound under polymorphism at every altitude. It is open because the rows-as-capabilities result in the literature discharges the positive half only. The negation half is this project's own burden, and each rule lands as a crucible in `tests/crown` first.
- Mentl Space as the medium's own projection (§11, the Space pivot): the page's view rendered by the wheel rather than by the page's own JavaScript, the terminal's host a stock engine with no code of ours, and the assembler in the wheel so a program runs inside the page.
- The Severance Map (§11, Arc G): a view inside `space` that bands each module by the capabilities proven absent, with a third colour for what the crown cannot yet prove — the third colour exists because the crown is still open, and a two-colour map over a partly proven mechanism would overstate the proof.

## License

Two license files are in the tree: `LICENSE-APACHE` (Apache License 2.0) and `LICENSE-MIT` (MIT), both copyright 2026 Morgan Espitia. No manifest states how they combine.
