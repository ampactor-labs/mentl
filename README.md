# Mentl

**Mentl closes the gap between what a person means and what they are forced to write.** Most languages make you spell out what their compiler could have worked out — borrows, error plumbing, async-ness, which effects a function has. Mentl's compiler infers those, so the source holds only your decisions: what a function must never do, what bound a value keeps, what width a number needs. At any line it says what is true there and why; at a hole (`??`) it proposes the next move it can prove, and when two proven moves mean different things it asks which one you meant instead of guessing. A claim you write is proven or the program does not build — which also means the same guarantees hold for code you did not write yourself.

Mentl is a programming language and self-hosting compiler with an algebraic effect system, compiled to WebAssembly. An effect is something a function does besides return a value — allocating, printing, reaching the network — and each function's type carries them. A negated effect such as `!Network` is a claim the compiler proves through every call, or it refuses to build. The compiler is written in Mentl: the pinned binary in `boot/` compiles `src/` and `lib/` into a compiler that reproduces it byte for byte, and that fixed point is the release.

## See it

```
effect Net {
  fetch(url: String) -> String
}

fn greeting(name) = "hello, " ++ name

fn headline(name) = greeting(name) ++ fetch("https://example.com/today")

fn banner(name) with !Net = headline(name)
```

`banner` says it never touches the network, and nothing else is annotated. `mentl check quiet.mn` refuses, naming the path the effect takes:

```
E_EffectMismatch error: effect row mismatch: !Net vs Memory + Alloc + Net — at 9:1-9:43:
declared as banner; Net enters at quiet:9:29 through `headline` → at quiet:7:39 through
`fetch` → declared as fetch, an op of Net declared at quiet:1:1
```

Write `banner` as `greeting(name)` and the claim holds. The network then has a meaning only where a handler gives it one — `len(banner("ada") ++ headline("ada")) ~> offline`, with `offline` answering `fetch` by resuming `"(offline)"`, runs and exits 29.

## Status

Working, and changing. The verifier is sound for what it decides and incomplete by design: a claim it cannot decide is reported as pending debt and the program still builds. One false proof is known: a recursion a person writes deep enough to exhaust the stack traps although its function says `!Trap`, since running out of stack is a trap no row shows yet (PLAN.md §7). The language and the command surface may still change.

## Quick start

The compiler is one WebAssembly module, `boot/mentl.wasm`, importing WASI preview1 and nothing else, so any engine that speaks that one interface hosts it. In a terminal the host is the stock `wasmtime`, pinned by version and digest; in the browser, Mentl Space (`ide/`, served at https://space.ampactor.dev/) runs the same binary in a worker.

```sh
git clone https://github.com/ampactor-labs/mentl.git && cd mentl
bash tools/wasmtime-get.sh  # the pinned engine, into .build/wasmtime (or a wasmtime 36 on your PATH)
bash tools/install.sh       # writes ~/.local/bin/mentl, a live pointer to boot/mentl.wasm through that engine
mentl run examples/pulse/course/01-tone.mn > 01.wav
```

The last command compiles the course's first lesson, proves its claims and renders three seconds of a 220 Hz sine, 48 kHz stereo, as a WAV on standard output. `mentl new hello` writes a one-file project and `mentl run hello` runs it; a bare `mentl` lists the `.mn` files in the directory and the verbs that apply to each. The shim points into the checkout, so a re-pin of `boot/mentl.wasm` is the installed command with no further step. Three verbs belong to the shim because each needs what a WASI module cannot create: `run` a process for the module the compiler emits, `space` a listening socket for the page, and `session` a resident process over stdin.

## Learn it

The course in `examples/pulse/course` is ten programs on one growing audio chain — each lesson a verb or a proof you hear — written to be read first and heard second. It grows into two scores: Pulse (`examples/pulse/render`) and Wasatch "Inversion" (`examples/wasatch`), a piece whose parameters are readings of Salt Lake and whose per-sample path is proven unable to reach the network or allocate.

The medium answers questions about a program directly:

```
mentl examples/pulse/course/01-tone.mn:38      # the caret: type, effects, ownership, the Reason chain
mentl where examples/pulse/course/06-rate.mn frame  # a declaration's head, row, widths and address
mentl why examples/pulse/course/06-rate.mn frame    # where each effect of its row enters
mentl query <file> "refs of NAME"              # every place an edge reaches NAME
```

A program's environment is read through `lib/environ.mn`, and `mentl run` passes it exactly the variables `mentl query <file> env` names, from the shell or the project's `.env`.

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
mentl test [dir]                judge every fixture in a directory against its first-line contract
mentl new <name>                write <name>.mn in the current directory
mentl mcp                       serve the proof gate as an MCP server on stdio
mentl help                      the full table: also tighten, where, why, teach, doc, accept, rename,
                                resume, session, serve, repl, asm, march and verify
```

A target is a module name or a file path, from any directory. `mentl mcp` serves the same reads over the Model Context Protocol: its `propose` tool compiles Mentl source and answers `PROVEN`, with the artifact in `.build/mcp/last.wat`, or `REFUSED`, with each undischarged claim at its span; `.mcp.json` registers the server.

## How it works

Source becomes one graph: every node is a handle, a node's body holds its children as handles, a reference is linked to the declaration it resolved to, and a comment is attached to the node it precedes. Type inference is the graph's only writer. It infers types in the Hindley-Milner style and beside each writes the effect row, the ownership grade, the refinement obligations and a Reason for every binding. Everything else — a diagnostic, the caret, the formatter, the IDE, lowering and the WebAssembly emitter (`src/backends/wasm.mn`) — reads that graph, so no tool holds a second copy of a fact that could drift from the first.

Effects are algebraic: an `effect` names operations, code calls them like functions, and a handler installed with `~>` gives them meaning and subtracts them from the expression's row. A row has a Boolean algebra (`+`, `-`, `&`, `!`, `Pure`), and a negated name is an obligation that the operation is unreachable, through every callee and every stored closure. A handler's state, its closure and a captured continuation share one heap record, so a paused computation is saved by copying bytes (`lib/persist.mn`, `mentl resume`). Refinement types (`type Percent = Int where 0 <= self && self <= 100`) add predicates the verifier discharges where it can decide them; information flow is the same walk, so an `Untrusted` value reaching a `Trusted` sink refuses.

Self-hosting is tested by the fixed point. `boot/mentl.wasm` compiles `src/` and `lib/` into a second compiler; that compiler compiles the same source again, and the two outputs must be identical byte for byte. The hand-written seed that first produced such a binary was deleted on 2026-07-10, so the pinned binary is the only bootstrap. Each re-pin appends an entry to `boot/PROVENANCE.md` with the sha256 read from the file it copied, the cost of the self-compile and the board's verdicts, and `tools/doc-truth.sh` compares that entry with the binary on every verify.

The open work converges on five mechanisms (PLAN.md §4⑧): every declaration publishes one summary its callers read (the face); one walk answers every reachability question (the reach); one speculative primitive serves proposals, fixes, refactors and the solver (the fork); the effect row tells every way a computation can stop (the whole-truth row); and the graph has two projections, the compile and an evaluator that is its reference meaning.

## Testing

`.github/workflows/board.yml` runs the board on every push to main and every pull request; `.github/workflows/deploy-space.yml` publishes the browser IDE. The gates need the pinned wasmtime (`bash tools/wasmtime-get.sh`) and GNU `time`, which the march measures the self-compile under.

```sh
bash tools/state.sh                  # the board: verify, then every gate below, one scoreboard; --quick runs verify only
bash tools/verify.sh                 # the micro battery through the pinned boot and through this tree's compiler, the form
                                     # fixtures, the census ratchet and doc-truth; stamped, so an unchanged tree answers at once
bash tools/march.sh                  # boot → m2 → m3, assert the fixed point (m4 on a mismatch: TRANSITION or BROKEN); the
                                     # candidate's wall and image line peak are held against the boot on the same wheel
bash tools/frontier-gate.sh          # contracts over tests/frontier and the ?? authoring workflows; a green run stamps the boot
bash tools/crown-gate.sh             # !E soundness: every leak-* crucible refuses, every sound-* crucible is accepted
bash tools/proof-exactness-gate.sh   # a value-position hole refuses, pending debt is reported, a suspension runs
bash tools/effect-identity-gate.sh   # Fail and Abort dispatch separately
bash tools/instrument-gate.sh        # the diagnostics instrument can go red, and a clean program still emits
bash tools/thread-gate.sh            # the compile spawns as many threads as the source says
bash tools/ide-gate.sh               # the browser IDE: a Node twin, then headless Chrome over the page
bash tools/doc-truth.sh              # the pin equals the binary's sha256, and every command and verb the docs name exists
bash tools/setup-git-hooks.sh        # installs the pre-commit gates (tools/install.sh runs it in a git checkout)
```

The determinism probe (one binary, one input, the same bytes) runs only with `bash tools/march.sh --fixpoint`, and nothing in the repository tests the engine itself.

## Limitations

- `!Trap` is false where the stack runs out (Status, above).
- A program shares one namespace with everything it links, so a user cannot declare a name the library declares, and a dependency's capabilities cannot yet be stated at its import.
- The absence proof is per effect instance, not yet per install: a closure minted under one handler and called under another is the open modal case (PLAN.md §4③).
- A failed file read answers an empty string rather than failing.
- Memory is one image, reclaimed only where an extent ends (`(body) ~> arena`); a warm start restores the analysed image and re-derives the compile over it.
- The browser IDE keeps one resident compiler per page but recompiles the whole file on each edit, cannot yet play a lesson in the page, and needs cross-origin isolation for shared memory (`ide/README.md`).
- The compile is single-threaded, and there is no native backend.

## Roadmap

PLAN.md §11 is the one ordered list, each step reading only what an earlier one built:

1. The read path is a map: the documents served by section, so a session loads what it reads.
2. The soundness core: the crown made modal, the row whole (`Fail`, divergence, partiality, every trap the emit writes said), the reach one walk.
3. The keystone: lowering a column on the program's own handles, the deep stack spilling to the heap, and the graph's evaluator as the correctness oracle and a witness that searches boundary inputs.
4. The face: one published summary per declaration, which verification reads — the course and the scores judged clean.
5. A module is a scope: imports that state capabilities, versions as a resolve handler, compatibility computed from faces.
6. A refusal is a hole: every diagnostic answered by the proposer loop a `??` runs, and the catalog projected from the code.
7. Edits that cost what they change, and the page that plays the course.
8. The verbs whole and the audio arc: early exit, cycles with drivers, delay lines read at any tap, Wasatch's live sources.
9. Forks on every core: the compiler and Verify's own solver parallel and deterministic.
10. `!Outside` closes: the native backend and diverse double compilation.

## Documents

Three documents are the read-path: [CLAUDE.md](CLAUDE.md), the method for changing the compiler; [PLAN.md](PLAN.md), the thesis, the design decisions, what the code has not reached (§7) and the open work (§11); and [docs/SYNTAX.md](docs/SYNTAX.md), the authority on the language's form. [lib/dsp/README.md](lib/dsp/README.md) shows the feedback verb `<~` on audio, [lib/ml/README.md](lib/ml/README.md) the derivative reading, and [ide/README.md](ide/README.md) the browser IDE. History is `git log`.

## License

Two license files are in the tree: `LICENSE-APACHE` (Apache License 2.0) and `LICENSE-MIT` (MIT), both copyright 2026 Morgan Espitia. No manifest states how they combine.
