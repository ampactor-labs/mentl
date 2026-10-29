# Mentl

Mentl closes the gap between what a person means and what they are forced to write. More and more of the software that runs machines is written with AI, and today that software is tested, reviewed and then trusted. In Mentl the rule is part of the program. A function's signature says what it must never do and what range its values keep; the compiler checks each rule through every function the code calls, and a version that breaks one does not build. Nobody has to review for that rule again, whoever or whatever edits the code next.

HUM's grid controller, `examples/grid/station.mn`, decides what a model flywheel and battery do as the power grid's frequency moves. Its function `decide` says it never reaches the network, never touches a file, never calls outside the program, never allocates memory and never stops the program with an error, and the compiler proves all five:

```
$ mentl check examples/grid/station.mn
```

Nothing is printed. `mentl check` prints every claim it cannot prove, at its line, so an empty answer is the whole verdict.

```
$ mentl why examples/grid/station.mn decide Network
decide never uses Network: nothing in decide, and nothing it calls, performs an operation of Network
```

`examples/grid/station-leak.mn` is the same program with one line added inside `decide` that reads an electricity price online. It does not build, and the refusal names the path from the decision to the network:

```
$ mentl check examples/grid/station-leak.mn
effects: E_EffectMismatch error: decide is declared `with !Alloc + !Network + !Filesystem + !WASI + !Trap`, which does not allow Network, and decide uses Network: decide calls `price_m` at examples/grid/station-leak:219:5 → price_m calls `fetch_param` at examples/grid/station-leak:111:14 → `fetch_param` is an operation of Network, declared at dsp/signal:66:1 at examples/grid/station-leak:151:1-256:2
effects: E_EffectUnhandled error: nothing handles Network either: it reaches the top of the program through `decide`, whose error above names the path. Declare a handler for Network and install it with `~>` around the code that uses it. at examples/grid/station-leak:447:1-450:13
```

What is not proven: that the controller's decisions are good, which recordings test; a rule is proven for the function and everything it calls, while a closure made under one handler and run under another is still open (PLAN §11.1); and a claim the verifier cannot decide is reported as pending, and the program still builds. The demo the controller runs in plays on a phone: https://ampactor.dev/hum. The Quick start below installs the `mentl` command in three lines.

## What Mentl is

Mentl is a programming language with an algebraic effect system, compiled to WebAssembly, and its compiler is written in Mentl: the pinned binary in `boot/` compiles `src/` and `lib/` into a compiler that reproduces it byte for byte, and that binary is what is released. An effect is something a function does besides returning a value, such as allocating memory, printing or reaching the network. The compiler infers each function's effects, types, ownership and bounds, so the source holds only the author's decisions: what a function must never do (`!Network`), what bound a value keeps (`type SpinW = Int where -100000 <= self && self <= 100000`), what width a number needs. What an effect does is decided by the handler installed around the code with `~>`: HUM's decision commands its machines through the `Station` effect, the handler `station` is the model, and a handler for real hardware would leave `decide` unchanged. At any line, `mentl why` says what is true there and the chain of reasons, because the compiler keeps one graph of facts and every command reads it. At a hole (`??`) the compiler proposes code it can prove, and when two proven candidates mean different things it asks which one you meant instead of guessing. The aim, unchanged since the first manifesto on 2026-03-15, is to close the gap between what a person means and what a language forces them to write; PLAN.md §0 states it in full.

## The five operators

Every flow in Mentl is written with five operators, and the shape you write is the shape the compiler sees. Lesson 3 of the course, `examples/pulse/course/03-bus.mn`, builds a stereo bus in three lines: `<|` sends one sample to the echo and to the room, `><` puts a branch beside the dry signal, and `|>` runs the mix and the clipper in sequence:

```
let (echoed, roomed) = dry <| (rig.echo, rig.room)
let l = ((echoed) >< (dry)) |> mix(0.35) |> soft_clip
let r = ((roomed) >< (dry)) |> mix(0.5) |> soft_clip
```

Put the cursor on the fanout and the compiler says what it sees there:

```
$ mentl examples/pulse/course/03-bus.mn:49:30
Query: dry <| (rig.echo, rig.room) : (Float, Float)
Topology: the <| shares `dry` with 2 branches, borrowed, so they cannot race
Effects: e + e + e1 + e1
Why: the product of the <| branches' results, the input borrowed by each, at examples/pulse/course/03-bus:49
```

One column to the right, on the `><`, and then on the first `|>`:

```
$ mentl examples/pulse/course/03-bus.mn:50:21
Query: (echoed) >< (dry) : (Float, Float)
Topology: the >< runs 2 branches, each owning its input, in sequence, since no schedule is installed over it, inside the source of the |> at examples/pulse/course/03-bus:50:11

$ mentl examples/pulse/course/03-bus.mn:50:31
Query: ((echoed) >< (dry)) |> mix(0.35) : Float
Topology: the |> runs 2 stages in sequence, this one completing stage 1, and the fanout's product fills the first stage's open slots
```

`~>` installs a handler over everything to its left. Lesson 4 writes a limiter as a handler and chains it behind the library's distortion, and the frame that calls `distort` and `tame` never says how either is done:

```
handler rack = spectral_flux_distort ~> limiter_at(0.6)
…
} ~> stdout_console ~> rack ~> sample_at(48000)
```

```
$ mentl why examples/pulse/course/04-rack.mn frame Distort
frame uses Distort: frame calls `distort` at examples/pulse/course/04-rack:72:11 → `distort` is an operation of Distort, declared at dsp/spectral:19:1
```

`<~` feeds a value back from the previous step. An echo is the current sample plus a share of what the stage put out a quarter of a second ago, and the delay line is memory the stage owns, so the stage is proven to allocate nothing (`lib/dsp/README.md`):

```
fn stage(x: Float) with !Alloc = { prev => x + fb * prev } <~ delay(12000)
```

The grid controller uses the same operator for its memory from one reading to the next: the ten-second average that `decide` compares each level against is `{ p => … } <~ delay(1)`, and the caret inside it names the loop:

```
$ mentl examples/grid/station.mn:188
Query: p : Int
Topology: the recurrence the <~ feeds back at examples/grid/station:186:19
Effects: Pure
```

Lesson 10 renders four voices with `><` over a list and `~> parallel_compose` to run the branches on threads:

```
$ mentl where examples/pulse/course/10-voices.mn render
→ render(ref sr: Int, own frames: Int) -> [[Float]] with Memory + Alloc + Trap + WasiThreads(a, e)  at examples/pulse/course/10-voices:65
  ~> parallel_compose absorbs Thread, answers [[Float]] at 65:25-65:86
  fanout [Thread, a branch per element] at 65:25-65:66
```

How the five are used together, with the compiler's answer at each, is docs/SYNTAX.md's "Composing the five" (`mentl map "Composing the five"`).

## The smallest refusal

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
E_EffectMismatch error: banner is declared `with !Net`, which does not allow Net, and banner
uses Net: banner calls `headline` at quiet:9:29 → headline calls `fetch` at quiet:7:39 →
`fetch` is an operation of Net, declared at quiet:1:1
```

Write `banner` as `greeting(name)` and the claim holds. A network operation then does something only where a handler says what it does. For example, `len(banner("ada") ++ headline("ada")) ~> offline`, where the handler `offline` answers `fetch` by resuming with `"(offline)"`, runs and exits with code 29.

### The same, on a real program

Each line below is a command and what it prints today. Beyond the five rules on `decide`, each power command is typed to its machine's rating, and the cut that copies a reading's timestamp is proven to stay inside the line.

```
$ mentl audit examples/grid/station.mn | head -1
Nothing in this module uses Network, so it is sandboxed (it never reaches the network)
```

The audit's first line is the claim that covers the whole module, handlers included: no function in it performs a network operation. As any WebAssembly module, the compiled controller can call only what it imports, and it imports three functions from its host: `fd_read`, `fd_write` and `proc_exit`.

```
$ mentl why examples/grid/station.mn reading Trap
reading never uses Trap: nothing in reading, and nothing it calls, performs an operation of Trap
```

Leave a stage of a signal chain open with `??` and the medium fills it with what it can prove, or asks. In lesson 8 of the course, `mentl examples/pulse/course/08-hole.mn:50:76` proposes `brighten`, the one stage that fits, and `mentl accept` writes it where the hole was. Where two candidates both prove and mean different things, it does not pick:

```
$ cd tests/frontier/propose-fan-demo && mentl bit.mn:8:30
Query: ?? : Bit
Propose: 2 proven survivors — a tie:
  0  — inferred from the type's integer inhabitants
  1  — inferred from the type's integer inhabitants
  the survivors differ in VALUE — 0 or 1 — and the type admits 0 through 1: which one does this position mean?
```

What a person cannot see yet: the candidates are judged one after another on one core, an edit re-judges most of the program before the next answer arrives, and the page cannot play a lesson. PLAN §11 names the landing for each (§11.5, §11.6 and §11.8).

## Status

Mentl works, and it is still changing. The verifier is sound for what it decides and incomplete by design: a claim it cannot decide is reported as pending, and the program still builds. `mentl check` prints each pending claim at its line, and `mentl audit` lists it under the function that holds it. One false proof is known: a function that says `!Trap` can still trap when a person writes recursion deep enough to run out of stack, because no effect row shows running out of stack yet (PLAN.md §7). The language and its commands may still change.

## Quick start

The compiler is one WebAssembly module, `boot/mentl.wasm`. It imports WASI preview1 and nothing else, and it needs an engine with tail calls; a module the compiler emits asks for the threads feature only when the program starts a thread or uses a shared-memory operation, and the compiler itself does neither. In a terminal the host is the stock `wasmtime` 36, pinned by version and digest; in the browser, Mentl Space (`ide/`, served at https://space.ampactor.dev/) runs the same binary in a worker.

```sh
git clone https://github.com/ampactor-labs/mentl.git && cd mentl
bash tools/wasmtime-get.sh  # the pinned engine, into .build/wasmtime (or a wasmtime 36 on your PATH)
bash tools/install.sh       # writes ~/.local/bin/mentl, a live pointer to boot/mentl.wasm through that engine
mentl run examples/pulse/course/01-tone.mn > 01.wav
```

The last command compiles the course's first lesson, proves its claims and renders three seconds of a 220 Hz sine, 48 kHz stereo, as a WAV on standard output. `mentl new hello` writes a one-file project and `mentl run hello` runs it; a bare `mentl` lists the `.mn` files in the directory and the verbs that apply to each. The installed command runs whatever `boot/mentl.wasm` the checkout holds, so a new pin takes effect without reinstalling. Three commands are handled by the shim because each needs something a WASI module cannot create: `run` needs a process for the module the compiler emits, `space` needs a listening socket for the page, and `session` needs a long-running process that reads stdin.

## Learn it

The course in `examples/pulse/course` is eleven programs that build one audio chain step by step. Each lesson adds a language feature or a proof whose effect you can hear, and each is written to be read before it is played. The course leads to two full pieces: Pulse (`examples/pulse/render`) and Wasatch "Inversion" (`examples/wasatch`). Wasatch's parameters are readings from Salt Lake, and the code that runs for every sample is proven unable to reach the network or allocate memory.

`examples/grid` is HUM's grid controller, described in the section above. `mentl where examples/grid/station.mn decide` prints the decision's whole list of effects, `Mutate + Station`: it keeps its own memory from one tick to the next and commands the Station's machines through the operations of the `Station` effect, and it does nothing else. The machines answer each command with what they give, and the compiler proves every answer stays within the machine's rating. Each reading runs inside an arena, so the program uses the same memory after 300,000 readings as after one. Every function the controller defines is proven never to stop with an error, the cut that copies the reading's timestamp included: `mentl why examples/grid/station.mn reading Trap` answers that `reading` never uses Trap. The one place the program can still stop is inside the library's `print_string`, where a byte-range check that cannot fail is not yet proven (PLAN §11, the face).

The mentl command answers questions about a program directly:

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
mentl map [part]                PLAN and SYNTAX by part: the map of their headings, or one part by id, title or word
mentl mcp                       serve the proof gate as an MCP server on stdio
mentl help                      the full table: also tighten, where, why, teach, doc, accept, rename,
                                resume, session, serve, repl, asm, march and verify
```

A target is a module name or a file path, from any directory. `mentl mcp` serves the same reads over the Model Context Protocol: its `propose` tool compiles Mentl source and answers `PROVEN`, with the built program in `.build/mcp/last.wat`, or `REFUSED`, with each error at its line; `.mcp.json` registers the server.

## How it works

Source becomes one graph: every node is a handle, a node's body holds its children as handles, a reference is linked to the declaration it resolved to, and a comment is attached to the node it precedes. Type inference is the graph's only writer. It infers types in the Hindley-Milner style and beside each writes the effect row, the ownership grade, the refinement obligations and a Reason for every binding. Everything else reads that graph: diagnostics, the caret, the formatter, the IDE, lowering and the WebAssembly emitter (`src/backends/wasm.mn`). So no tool keeps a second copy of a fact that could drift from the first.

Effects are algebraic: an `effect` names operations, code calls them like functions, and a handler installed with `~>` gives them meaning and subtracts them from the expression's row. A row has a Boolean algebra (`+`, `-`, `&`, `!`, `Pure`), and a negated name is an obligation that the operation is unreachable, through every callee and every stored closure. A handler's state, its closure and a captured continuation share one heap record, so a paused computation is saved by copying bytes (`lib/persist.mn`, `mentl resume`). Refinement types (`type Percent = Int where 0 <= self && self <= 100`) add predicates the verifier discharges where it can decide them; information flow is checked by the same walk, so the compiler refuses a program in which an `Untrusted` value reaches a `Trusted` sink.

Self-hosting is tested by a fixed point. `boot/mentl.wasm` compiles `src/` and `lib/` into a second compiler; that compiler compiles the same source again, and the two outputs must be identical byte for byte. The hand-written seed that first produced such a binary was deleted on 2026-07-10, so the pinned binary is the only bootstrap. Each re-pin appends an entry to `boot/PROVENANCE.md` with the sha256 read from the file it copied, the cost of the self-compile and the board's verdicts, and `tools/doc-truth.sh` compares that entry with the binary on every verify.

The open work builds five mechanisms (PLAN.md §4⑧): every declaration publishes one summary its callers read (the face); one walk answers every reachability question (the reach); one speculative primitive serves proposals, fixes, refactors and the solver (the fork); the effect row tells every way a computation can stop (the whole-truth row); and the graph has two projections, the compile and an evaluator that is its reference meaning.

## Testing

`.github/workflows/board.yml` runs the board on every push to main and every pull request; `.github/workflows/deploy-space.yml` publishes the browser IDE. The gates need the pinned wasmtime (`bash tools/wasmtime-get.sh`) and GNU `time`, which the march measures the self-compile under.

```sh
mentl land                           # the landing pass: this tree's compiler judged cheapest first, stopping at the first red,
                                     # every verdict kept by the bytes it judged, pinned once; --quick: verify; --board: the board
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
- The absence proof is per effect instance, not yet per install: a closure created under one handler and called under another is the open modal case (PLAN.md §4③).
- Memory is one image, reclaimed only where an extent ends (`(body) ~> arena`); a warm start restores the analysed image and re-derives the compile over it.
- The browser IDE keeps one resident compiler per page but recompiles the whole file on each edit, cannot yet play a lesson in the page, and needs cross-origin isolation for shared memory (`ide/README.md`).
- The compile is single-threaded, and there is no native backend.

## Roadmap

PLAN.md §11 is the one ordered list, each step reading only what an earlier one built:

1. A rule written on a function also holds through a closure made under one handler and run under another, the effect row says every way a computation can stop, and one walk answers every reachability question.
2. Lowering becomes columns on the program's own handles, so the compiler keeps no second tree of the program, and the graph gains an evaluator that gives it a reference meaning and searches for inputs that break a claim.
3. Every declaration publishes one summary that every caller and the verifier read, so the course and the two scores check clean.
4. A module is a scope: an import states the capabilities it may use, a version is a handler the resolver installs, and whether two packages fit is computed from their summaries.
5. Every refusal is answered the way a `??` is: the compiler proposes the proven fix or asks the one question that separates two, and the catalog of its messages is projected from the code.
6. An edit re-judges only what it changed, the session outlives its process, and the page plays a lesson while you read it.
7. The five operators are whole: early exit stops at the first hit, every cycle has a driver and an inferred clock, a delay line is read at any tap, and Wasatch plays from live sources.
8. Proposals and the compiler's own work run on every core, with the same bytes in any order, and the verifier's own solver is that search.
9. The native backend compiles the same program to machine code, two independent compilations are compared, and every script under `tools/` has become a `mentl` verb.

## Documents

Three documents explain the project: [CLAUDE.md](CLAUDE.md), the method for changing the compiler, read whole; [PLAN.md](PLAN.md), the thesis, the design decisions, what the code has not reached (§7) and the open work (§11); and [docs/SYNTAX.md](docs/SYNTAX.md), the authority on how the language is written. The last two are read one part at a time through `mentl map`. [lib/dsp/README.md](lib/dsp/README.md) shows the feedback verb `<~` on audio, [lib/ml/README.md](lib/ml/README.md) the derivative reading, and [ide/README.md](ide/README.md) the browser IDE. History is `git log`.

## License

Two license files are in the tree: `LICENSE-APACHE` (Apache License 2.0) and `LICENSE-MIT` (MIT), both copyright 2026 Morgan Espitia. No manifest states how they combine.
