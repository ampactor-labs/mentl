# Mentl

Mentl closes the gap between what a person means and what they are forced to write. You usually know what a piece of code must never do: the frame that renders each block of audio must never allocate memory, and the decision a grid controller makes must never wait on the network. Most languages give you no way to write that down, and make you write everything else instead: types, borrows, lifetimes and error plumbing that a compiler could work out for itself. In Mentl you write three things: the shape of each flow, with five operators named for what they do (pipe, share, split, install and feedback); the rules each part keeps, such as `with !Alloc` or the range a number stays in; and the handlers that say what each effect does. The compiler works out the rest, every type, effect, ownership and width. It checks each rule through every function the code calls, on every build, and a version that breaks a rule does not build. So nobody reviews the code for that rule again, whoever or whatever edits it next.

The programs in this repository show it working today: a course of twelve audio lessons that build one signal chain, two complete pieces rendered from code, a controller for a model flywheel and battery on the power grid, and the compiler itself, which is written in Mentl and compiles itself to the same bytes. Every output on this page is what the pinned compiler, `boot/mentl.wasm` (pin `b46b71133838`, recorded in `boot/PROVENANCE.md`), printed when the command was run for this page.

## Start with nothing

A program needs no annotations to run. The compiler infers every type, every effect and every value's ownership, and the program builds. Each annotation you add is one decision, and each gives the compiler one more thing to check through every call. Mentl's design calls this path the gradient (PLAN §2): it runs from no annotations, where everything is inferred, to every rule you care about holding, one annotation at a time. You do not have to work out the next step: `mentl teach` names, for each function, the annotation that would unlock something, and what it unlocks. On lesson 7 of the course:

```
$ mentl teach examples/pulse/course/07-bounds.mn
frames_per: → `notes: Rate` or `notes: Positive` — either way the division cannot fail, which unlocks trap-free (nothing it reaches can stop with an error; that it always finishes is not proven); they mean different things, so which is meant?
cutoff_at: → `t` must make -9.007199254740992e15 < self && self < 9.007199254740992e15 hold (line 53), and no refinement in reach states it — declare one and annotate `t`
note_hz: → add `with !Alloc` — unlocks real-time safe (it never allocates memory); `frame` stands on it
frame: → `per_note: Rate` or `per_note: Positive` — either way the division cannot fail, which unlocks trap-free (nothing it reaches can stop with an error; that it always finishes is not proven); they mean different things, so which is meant?
nothing to unlock in seconds, build_rig, main
```

`note_hz` already allocates nothing. One clause, `with !Alloc`, turns that into a rule the compiler holds it to on every build, and `frame`, which calls it, can then rely on it. Each of the two divisions could be made safe by either of two annotations: the count is a sample rate (`Rate`) or it is any positive number (`Positive`). Those mean different things, so the compiler asks which one you mean instead of picking. The line for `cutoff_at` is rougher: it states the range a conversion needs as a bare predicate. Working out a step for every function is what lets the compiler choose the single step worth writing first, the one that unlocks the most for the code you are working on. That choice is not made yet: `teach` lists the steps in the order the functions are written, and ranking them by what each unlocks is open work (PLAN §11, "A refusal is a hole").

## Leave a hole

The same works for code you have not written yet. Write `??` where a piece is missing, and the compiler proposes what fits. Lesson 8 leaves one stage of a signal chain open:

```
$ mentl examples/pulse/course/08-hole.mn:50:76
Query: ?? : (Float) -> Float with e
Propose: brighten  — inferred from the in-scope function brighten — row Pure admitted by !Alloc
Topology: stage 1 of 2 of the |> at examples/pulse/course/08-hole:50:14
Effects: whatever its position permits — a hole states no row
Why: the call to ??, at examples/pulse/course/08-hole:50
     unification
     its type: the call to ??, at examples/pulse/course/08-hole:50
     expected
```

Of the candidates the compiler tried, each judged on its own, only `brighten` passed: its type fits the stage, and its row is `Pure`, which the frame's `with !Alloc` admits. `mentl accept examples/pulse/course/08-hole.mn:50:76` writes it where the hole was, so line 50's `|> ?? |>` becomes `|> brighten |>`. Where two candidates both pass and mean different things, the compiler asks instead of guessing:

```
$ cd tests/frontier/propose-fan-demo && mentl bit.mn:8:30
Query: ?? : Bit
Propose: 2 proven survivors — a tie:
  0  — inferred from the type's integer inhabitants
  1  — inferred from the type's integer inhabitants
  the survivors differ in VALUE — 0 or 1 — and the type admits 0 through 1: which one does this position mean?
Effects: whatever its position permits — a hole states no row
Why: returned from pick, at bit:8
     body
     its type: declared pick, at bit:8
```

## A rule you write is checked, never reviewed

HUM's grid controller, `examples/grid/station.mn`, decides twenty times a second what a model of a flywheel and a battery do as the grid's frequency moves. Its decision function states five rules: it never allocates memory, never reaches the network or a file, never calls anything outside the program, and never stops the program with an error. `mentl where` prints the head the compiler derived:

```
$ mentl where examples/grid/station.mn decide
→ decide(ref valid: Int, ref hz: Int, own rocof: Int, ref level: Int, ref hour: Int, ref rush: Int, ref clean: Int) -> Mode with Mutate + Station  at examples/grid/station:185
  with !Alloc + !Network + !Filesystem + !WASI + !Trap (declared)
  valid : Int @ i32 (inferred)
  hz : Int @ i32 (inferred)
  rocof : Int @ i32 (inferred)
  level : Int @ i32 (inferred)
  hour : Int @ i32 (inferred)
  rush : Int @ i32 (inferred)
  clean : Int @ i32 (inferred)
  -> Mode @ i32 (inferred)
```

The source writes the five rules and `hz: Int`. The compiler worked out the other parameters' types, the ownership of each (`own` or `ref`), and the first line's row, `Mutate + Station`, which is everything `decide` does: it keeps its own memory from one reading to the next, and it commands the two machines through the operations of the `Station` effect. Ask where the network enters, and the compiler answers that it does not:

```
$ mentl why examples/grid/station.mn decide Network
decide never uses Network: nothing in decide, and nothing it calls, performs an operation of Network
```

`examples/grid/station-leak.mn` is the same program with a function that reads an electricity price from the network and one call to it inside `decide`. It does not build, and the refusal lists each call on the way:

```
$ mentl check examples/grid/station-leak.mn
effects: E_EffectMismatch error: decide is declared `with !Alloc + !Network + !Filesystem + !WASI + !Trap`, which does not allow Network, and decide uses Network: decide calls `price_m` at examples/grid/station-leak:221:5 → price_m calls `fetch` at examples/grid/station-leak:113:14 → `fetch` is an operation of Network, declared at net:11:1 at examples/grid/station-leak:153:1-258:2
effects: E_EffectUnhandled error: nothing handles Network either: it reaches the top of the program through `decide`, whose error above names the path. Declare a handler for Network and install it with `~>` around the code that uses it. at examples/grid/station-leak:449:1-452:13
verify: 1 place(s) can stop this program with a trap, 0 of them inside the library through the program's calls; `mentl query examples/grid/station-leak traps` lists each with its claim
```

Part of this guarantee belongs to WebAssembly and to the engine. The compiled controller can call only the functions it imports, and it imports three, all from WASI: `proc_exit`, `fd_write` and `fd_read`. wasmtime's sandbox enforces that list. The rule on `decide` is a statement about the code itself, and it would hold just the same in a program that reaches the network elsewhere. No Mentl program can reach a network yet, because WASI preview 1, the target the compiler emits, has no outbound connection (PLAN §11, "The WASI 0.2 component target, and a real network").

On the controller itself, `mentl check` prints one line:

```
$ mentl check examples/grid/station.mn
verify: 1 place(s) can stop this program with a trap, 0 of them inside the library through the program's calls; `mentl query examples/grid/station traps` lists each with its claim
```

`mentl audit` lists every function the controller defines as never stopping with an error, except `main`. The one place left is the printing of each decision line, inside the library, reached through the handler `main` installs:

```
$ mentl why examples/grid/station.mn main Trap
main uses Trap: main installs `station` at examples/grid/station:475:13 → station calls `print_string` at examples/grid/station:172:5 → print_string calls `str_payload` at io:208:21 → str_payload calls `flat_raw` at strings:199:14 → flat_raw calls `fill_range` at lists:504:5 → fill_range calls `store_strided` at lists:535:11 → store_strided calls `trap` at lists:96:65 → `trap` is an operation of Trap, declared at memory:235:1
```

No rule guards that check yet, so it stays a place the program can stop (PLAN §11, "The face: every declaration publishes one, and verification reads it"). `mentl query FILE traps` counts this place as `main`'s own and does not yet follow the handler into the library, which is why the line above says 0 of them are inside it.

## The shape you write is the shape it keeps

Every flow is written with five operators, each named for what it does to a value: the pipe `|>`, the share `<|`, the split `><`, the install `~>` and the feedback `<~`. `examples/hello/five.mn` uses each once:

```
// hello: Mentl's five operators, once each.
// `mentl run examples/hello/five.mn` prints:
//   hello
//   2 **
//   6 ******
//   12 ************
import io

fn double(n) = n * 2

// The feedback, <~, adds each number to the total before it.
// `!Alloc` is checked on every build: a version
// of this stage that allocates does not build.
fn add(x) with !Alloc = { t => t + x } <~ delay(1)

fn bar(n) = join("", repeat(n, "*"))

fn say(n, b) = print("{n} {b}\n")

// The share, <|, sends each total to two stages, and
// the pipe, |>, hands both answers to `say`.
fn row(x) = (add(x) <| (int_to_str, bar)) |> say

// The install, ~>, sends what `print` writes to the screen.
fn main() = {
  print("hello\n")
  // The split, ><, doubles every number, each a branch.
  each(row, [1, 2, 3] >< double)
  0
} ~> stdout_console
```

`mentl run examples/hello/five.mn` prints the four lines its comment shows. Put the cursor on an operator, and the compiler says in one sentence what it holds there. The Topology line at each:

- The feedback, `<~`, feeds back a value from the previous step. At `examples/hello/five.mn:14:40`: "the <~ feeds back the output 1 tick ago; its line is owned by `add` and allocated once". That is why `add` can say `!Alloc` while it keeps a running total.
- The share, `<|`, sends one input to several branches, each borrowing it. At `22:21`: "the <| shares its input with 2 branches, borrowed, so they cannot race, inside the source of the |> at examples/hello/five:22:13".
- The pipe, `|>`, runs stages in sequence. At `22:43`: "the |> runs 1 stage in sequence, and the fanout's product fills the first stage's open slots", so the two answers fill both of `say`'s parameters.
- The split, `><`, runs independent branches side by side, each owning its input. At `28:23`: "the >< applies one stage to every element of the list on its left, each element a branch of its own, in sequence, since no schedule is installed over it, inside the body the ~> governs at examples/hello/five:25:13". Under a schedule handler the same branches run on threads: lesson 10 renders four voices with `~> parallel_compose`, and `mentl where examples/pulse/course/10-voices.mn render` prints `fanout [Thread, a branch per element] at 65:25-65:60`.
- The install, `~>`, puts a handler over everything to its left. At `30:3`: "the ~> installs `stdout_console` over everything to its left, answering Console". What `print` does is decided there, at the right edge, and nowhere in the body.

docs/SYNTAX.md's "Composing the five" uses all five together in lesson 3 of the course, with the compiler's answer at each operator.

## Every fact can be asked why

The compiler keeps one graph of facts about the program. Type inference is the only thing that writes to it, and every command reads it: the caret, `why`, `where`, `teach`, `audit`, the formatter, the editor and the code generator. So no tool keeps a second copy of a fact that could drift from the first, and every fact has a reason the compiler can show. `mentl why` walks an effect back to the operation that performs it, as above. `mentl query FILE traps` lists every place a program can stop with an error, each with the state of the rule that guards it. Lesson 7 has four:

```
$ mentl query examples/pulse/course/07-bounds.mn traps
→ 4 place(s) where the program can stop with a trap
  examples/pulse/course/07-bounds:76:15-76:60: no claim is checked here; inside the library, wav_header uses Trap: wav_header calls `store_tag` at audio/wav:39:3 → store_tag calls `byte_at` at audio/wav:57:15 → byte_at calls `list_index` at strings:44:20 → list_index calls `trap` at lists:234:37 → `trap` is an operation of Trap, declared at memory:235:1
  examples/pulse/course/07-bounds:48:24-48:52: its claim is pending
  examples/pulse/course/07-bounds:64:11-64:23: its claim is pending
  examples/pulse/course/07-bounds:68:3-68:26: no claim is checked here; inside the library, wav_frame uses Trap: wav_frame calls `pcm16` at audio/wav:88:18 → at audio/wav:75:30, `float_to_int`'s precondition, open at its argument
4 place(s) can trap: 0 proven by their operands, 0 proven only through the program's calls, 2 pending, 0 refused, 2 with no claim
```

The two pending claims are the two divisions `teach` offered to settle above. A claim the compiler cannot decide is never waved through: `mentl check` prints it at its line on every build, and the program still builds.

## Memory you never manage

A Mentl program has nothing to allocate, free, count or collect. A computation runs in an extent: `(body) ~> arena` gives the body a region of memory, and at the body's exit what its result still reaches moves out and the rest is reclaimed at once. The controller runs each reading in one (`fn step() = if reading() ~> arena { step() }`). Compiled, assembled and run directly under the pinned wasmtime on four hand-written readings repeated, the whole process peaked at 18,304 KB of resident memory over 1,000 readings and at 18,276 KB over 300,000 readings, which took 11.3 s. Lesson 11 of the course reports its own memory when it ends:

```
$ mentl run examples/pulse/course/11-footprint.mn > 11.wav
11-footprint: 290 pages of 64 KiB held; heap line 2933920 bytes before the first section, 2933920 after the last extent ended; 5 extents ended, 0 kept their memory, 0 KB reclaimed, 0 KB moved
```

Where the compiler cannot see what an extent's result reaches, the extent keeps its memory instead of checking references at run time, and the count of kept extents is printed, as above. Placing each value in the extent where it will live, so that nothing moves at an exit, is open work (PLAN §11, "Forks on every core").

## A program that outlives its process

A paused program is its memory, so saving it is copying that memory and resuming it is reading the copy back into the same addresses. Lesson 12 renders lesson 11's piece in two processes. The first plays two of the piece's four one-second sections, saves its memory and exits. The second reads the memory back and plays the last two:

```
$ mentl run examples/pulse/course/12-resume.mn
$ mentl run examples/pulse/course/12-resume.mn resume > 12.wav
warm: reusing the analysis saved by the last run
$ cmp 11.wav 12.wav
```

`cmp` prints nothing: the two-process render is byte for byte the one-process render, both 768,044 bytes with sha256 `a2499211…`. The saved image was 2,934,864 bytes. An open file or a position in an input stream belongs to the host and does not travel, and a program is saved between two of its statements, never in the middle of a call, because a running call's frames live in the engine (PLAN §11, "The keystone: lowering is a column, and the graph gains its evaluator").

## A program that learns

Lesson 9 plays a sawtooth through two filters. The left channel is the library's low-pass filter at 600 Hz. The right is a one-pole filter whose coefficient starts at zero and learns, sample by sample, to match the left. The learning step asks for a derivative and installs the handler that answers it:

```
fn slope(a, x, yprev, want) = {
  let e = want - (a * x + (1.0 - a) * yprev)
  d(e * e)
} ~> grad(a)
```

`d(e * e)` asks for the derivative of the squared error with respect to `a`, the variable `grad(a)` names. The compiler derives the derivative from the same arithmetic the filter runs, so there is no second copy of the filter to fall out of step. The coefficient is a `<~` line inside the filter's own line, and the frame that renders it declares `with !Alloc`. Rendered and compared with Python's `wave` module, the two 16-bit channels differ by a mean of 19.64 in the first tenth of a second and by 0.00 in the last. Only 712 of the 144,000 frames differ at all, the last of them 24.6 ms in.

## The compiler is the first Mentl program

The compiler is written in Mentl, in `src/` and `lib/`. The pinned binary compiles that source into a second compiler, which compiles the same source again, and the two outputs must be identical byte for byte. For the current pin that self-compile took 9.65 s of wall time at a peak of 268 MB of resident memory (`boot/PROVENANCE.md`). The hand-written seed that first built the compiler was deleted on 2026-07-10, so the pinned binary is the only way to build it, and `boot/PROVENANCE.md` records every pin with the sha256 read from the file. `mentl verify` holds the counts the compiler keeps about its own source as ceilings that only fall. On this pin 37 of them hold, among them the places in the compiler that can stop with an error and no rule guarding them (3,373) and the values whose memory the verifier cannot place yet (34,654).

## What is not proven

Never claimed: that a program does what its author meant. What the compiler cannot yet guarantee, each with the PLAN §11 step that closes it:

- A claim the verifier cannot decide is printed as pending, and the program still builds. Lesson 6 leaves 1 such claim, lesson 7 leaves 4, Pulse 3 and Wasatch 7 ("The face: every declaration publishes one, and verification reads it").
- A function that says `!Trap` can still run out of stack when it recurses deeply enough, because no effect row shows running out of stack yet. `fn depth(n) with !Trap = if n == 0 { 0 } else { 1 + depth(n - 1) }` checks clean and stops with "call stack exhausted" a million calls deep ("The keystone: lowering is a column, and the graph gains its evaluator").
- An effect can slip past a negation through a function of the caller's own recursive group when that function is first used where its row meets a pure one: such a program checks clean while the effect runs ("The soundness core: the crown modal, the row whole, the reach one walk").
- A program's own handler of `trap` takes `Trap` out of its row while a failed check still stops the machine, so `main with !Trap` is accepted and the run stops ("An extent can end early, and leaves older memory as it found it").
- No program can reach a network or read the host's clock or randomness yet ("The WASI 0.2 component target, and a real network"; "The host's clock, randomness and sleep are real").
- A program shares one namespace with everything it links, so it cannot declare a name the library declares: `fn count(x) = x + 1` is refused with `E_DuplicateFnName` ("A module is a scope, and a package carries its judgment").
- The browser page cannot play a lesson yet, the compile runs on one core, and there is no native backend ("Edits cost what they change, and the page plays the course"; "Forks on every core"; "`!Outside` closes").

## Quick start

The compiler is one WebAssembly module, `boot/mentl.wasm`. It imports WASI preview 1 and nothing else, and it needs an engine with tail calls.

```sh
git clone https://github.com/ampactor-labs/mentl.git && cd mentl
bash tools/wasmtime-get.sh   # the pinned engine, wasmtime 36.0.17, into .build/wasmtime
bash tools/install.sh        # writes ~/.local/bin/mentl, a pointer to boot/mentl.wasm through that engine
mentl run examples/hello/five.mn
```

`mentl run examples/pulse/course/01-tone.mn > 01.wav` renders the course's first lesson: 3.000 seconds of 16-bit stereo at 48,000 samples per second, a 220 Hz tone (220.0 upward zero crossings per second in the left channel). `mentl new hello` writes a one-file project, and `mentl run hello` runs it. The installed command runs whatever `boot/mentl.wasm` the checkout holds, so a new pin takes effect without reinstalling. Mentl Space, the browser editor, runs the same compiler in the page at https://mentl.ampactor.dev/. It is deployed from the main branch and serves an older pin (`156a841220d8…`), so its answers can differ from this page's.

## Learn it

The course in `examples/pulse/course` is twelve programs that build one audio chain, each adding one feature or one rule whose effect you can hear: `01-tone`, `02-line`, `03-bus`, `04-rack`, `05-silence`, `06-rate`, `07-bounds`, `08-hole`, `09-learn`, `10-voices`, `11-footprint` and `12-resume`. Each lesson's header names the commands to try on it. The course leads to two complete pieces, Pulse (`examples/pulse/render`) and Wasatch "Inversion" (`examples/wasatch`). `examples/grid` holds the controller and its leaky copy, and `examples/hello` the five operators once each and a door lock built from them.

The commands, in brief (`mentl help` lists them all):

- `mentl run FILE`, `mentl check FILE` and `mentl compile FILE` build, check and emit a program.
- `mentl FILE:LINE:COL` puts the cursor there: the type, the topology, the effects, the ownership and the chain of reasons.
- `mentl where FILE NAME` and `mentl why FILE NAME [EFFECT]` give a declaration's derived head and where each effect of its row comes from.
- `mentl teach FILE` names the next annotation worth writing, and `mentl audit FILE` says what each function never does.
- `mentl accept FILE:LINE:COL` writes a hole's one fitting candidate, and `mentl rename FILE:LINE:COL NAME` renames a declaration and every use.
- `mentl query FILE QUESTION` answers the rest, such as `traps`, `"refs of NAME"` or `"census unplaced"`.
- `mentl mcp` serves the same reads and the proof gate to an editor or another program over the Model Context Protocol.

## What Mentl is

For the engineer: Mentl is a programming language with algebraic effects, compiled to WebAssembly, whose compiler is written in Mentl. An `effect` declares operations, and code calls them like functions. A `handler` gives them meaning, and the install operator, `~>`, puts it around the code to its left, so no body says how an effect is done and swapping the handler changes the behaviour without touching the body. Every function has a row, the set of effects it can perform, which the compiler infers; the row has a Boolean algebra, and `!E` says a function never performs `E` through everything it calls. Types are inferred in the Hindley-Milner style, each fact with a Reason. Ownership is an effect the compiler infers from how often a value is used. Refinement types add predicates the verifier decides where it can: the controller's `type SpinW = Int where -100000 <= self && self <= 100000` is a power the flywheel can give. PLAN.md §0 states the thesis in full, and docs/SYNTAX.md is the authority on how the language is written.

## Documents

- [MENTL_MEMORY.md](MENTL_MEMORY.md): the project's north star, which no commit may change.
- [CLAUDE.md](CLAUDE.md): the method for changing the compiler.
- [PLAN.md](PLAN.md): the thesis, the design decisions, what the code has not reached (§7) and the one list of open work (§11).
- [docs/SYNTAX.md](docs/SYNTAX.md): how Mentl is written.
- [boot/PROVENANCE.md](boot/PROVENANCE.md): every pin of the compiler, with its hash and cost.
- [lib/dsp/README.md](lib/dsp/README.md), [lib/ml/README.md](lib/ml/README.md) and [ide/README.md](ide/README.md): the feedback operator on audio, the derivative reading, and the browser editor.

PLAN and SYNTAX are read one part at a time: `mentl map` lists their headings with line numbers and sizes, and `mentl map §11.1` prints one part. History is `git log`.

## License

Two license files are in the tree: `LICENSE-APACHE` (Apache License 2.0) and `LICENSE-MIT` (MIT), both copyright 2026 Morgan Espitia. No manifest states how they combine.
