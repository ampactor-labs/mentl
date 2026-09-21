# Mentl

Mentl is a programming language built on one bet: the medium itself — not
a model, not a course, not a review queue — should be the best teacher and
the best pair of hands a developer ever gets. You write what you mean; the
compiler proves it, runs it, and answers *what is true here, and why* at
any line of any file. Five verbs of flow draw the program's shape on the
page. Types carry your real constraints — effects, bounds, ownership — and
a refusal names the claim it could not discharge, at its own span. There
is no separate curriculum: picking the language up is learning to program,
because the compiler's answers are the course.

That has a sharp consequence for how code gets written now. Nobody uses an
LLM for the idea — that is always yours. People use one to guess plausible
text in languages that cannot check intent, then spend the day reviewing
the guesses. Here the medium proposes only code that survived the proof,
shows the whole surviving space, and when your intent genuinely
underdetermines the answer it asks the one question that decides instead
of guessing. Anything may propose — a person, a script, a model — and
nothing executes unproven. The design target is plain: a model behind this
gate is not forbidden, it is not worth invoking.

**Status: working, API unstable.** The verifier is sound and deliberately incomplete; what it cannot decide accrues as visible pending debt rather than a silent pass. No license is chosen yet.

This page is a door with two ways through. If you have never written code:
install below, then walk [Five minutes with the teacher](#five-minutes-with-the-teacher)
— the compiler does the teaching, and the school inside assumes nothing. If
you build compilers or verify software for a living: every claim here has a
command — start at [The receipts](#the-receipts), and the full positioned
statement is [docs/POSITIONING.md](docs/POSITIONING.md).

## One signature, read aloud

Here is a function that runs a plugin — code you did not write and will
never read. The `with` clause is its door policy:

```
fn admit(plugin, x) with !Network + !FileSystem =
  apply(plugin, x)
```

`!Network` reads *cannot reach the network*. Not "does not," not "was tested
and didn't," not "the team agreed not to." Cannot — proven at compile time,
transitively, through everything the plugin calls, to the bottom. If
anything inside it tries, there is no built program to run. It can be
brilliant. It can be a thousand times cleverer than you. It cannot phone
home. Let the machine write. Let anything write.

And when a claim is false, the compiler does not warn — it refuses:

```
type Percent = Int where 0 <= self && self <= 100

fn main() = {
  let p: Percent = 140
  42
}
```
```
$ mentl run refuse.mn
verify: E_RefinementRejected error: refinement predicate proven false at compile time
mentl: refusing to emit — 1 claim(s) the medium could not discharge
$ echo $?
1
```

No warning you can ignore, no runtime crash later: a false claim produces no
executable at all. That is the trust half of the thesis in one exit code;
the teaching half is the school below.

## Try it

```sh
git clone <this-repo> mentl && cd mentl
bash tools/install.sh                 # writes ~/.local/bin/mentl → the live pinned boot
mentl new hello                       # scaffolds hello.mn (one file; the imports are the manifest)
mentl run hello                       # compile, prove, execute
mentl                                 # project the current directory — where you are, what's next
```

`mentl` needs [`wasmtime`](https://wasmtime.dev) on the path. No package
manager, no manifest, no version pin: the pinned boot *is* the release, and
every re-pin is instantly the global command.

## The shape of it

There are exactly five verbs of flow in this medium, and they are the
complete vocabulary; every program you will ever read is these five shapes
combined. `|>` is "and then." `<|` fans one value out to several readers.
`><` runs independent things side by side — literally side by side on the
page, because the shape on the page is the shape of the work, and the
formatter keeps that true. `~>` installs an answerer over everything to its
left. And `<~` feeds a result back to become the next input — the shape
memory is made of, and the shape this medium was born for: sound. That
story, with the echo you can read aloud, lives at
[lib/dsp](lib/dsp/README.md).

## Five minutes with the teacher

The course is ten small programs in `lib/tutorial/`, written to be read
first and run second; no prior programming is assumed. But the teacher is
not the prose — it is the compiler. Here is the first lesson's loop, whole.

**Run it.**

```
$ mentl run lib/tutorial/00-hello.mn
Hello, kernel. The medium is reading you back.
Hello, oracle. The medium is reading you back.
Hello, octopus. The medium is reading you back.
```

**Ask it.** At any line of any file, the medium answers what it knows there
— the type, the effects, and the why. The lesson's own header names the
line to ask about:

```
$ mentl lib/tutorial/00-hello.mn:32
Query: print_string : (s: String) -> () with WASI + Alloc + Memory + r36338@e21797
Effects: WASI + Alloc + Memory + r36338@e21797
Why: print_string flows in here, at lib/tutorial/00-hello.mn:32
     declared print_string, at lib/io.mn:173
```

**Break it.** The lesson's comment dares you: greet joins text, and joining
allocates. Ask greet to promise it never allocates — add `with !Alloc` to
its signature — and the medium answers back, at the exact lines:

```
effects: E_EffectMismatch error: effect row mismatch: !Alloc vs Alloc + Memory
```

You claimed *never*; it read the body and named where the claim breaks.
(The door's Percent showed the stronger form — a false claim that refuses
to build at all. Refusal classes arm one at a time, each once the compiler's
own source is clean of it.)

**Leave a hole.** Write `??` where a value should go and the medium
proposes only what it can prove:

```
type Positive = Int where self > 0

fn choose(n: Positive) = n * 2

fn main() = choose(??)
```
```
$ mentl hole.mn:5:20
Query: ??) : Positive
Propose: 1
Why: declaration-order param, at hole.mn:5
```

And when more than one candidate survives the proof, it does not guess. It
shows the whole proven space and names the move that collapses it:

```
type Bit = Int where 0 <= self && self <= 1

fn pick() -> Bit with Pure = ??
```
```
$ mentl bit.mn:3:30
Query: ?? : Bit
Propose: 2 proven survivors — a tie:
  0  — inferred from the type's integer inhabitants
  1  — inferred from the type's integer inhabitants
  one more constraint (a refinement, a type, an example) collapses it
Why: declared pick, at bit.mn:3
```

Nothing is offered that did not survive the gate, and a tie teaches instead
of picking silently. That is the loop the whole school rides: read a
little, run it, break it on purpose, let the refusal teach, and ask at any
line. Walk the lessons in order: `00-hello` (meet the medium) · `01-graph`
(everything is one graph) · `02-handlers` (effects are answered, not
feared) · `03-verbs` (the five shapes) · `04-row` (declaring and denying
capabilities) · `05-ownership` (who holds a value) · `06-refinement` (types
that carry bounds) · `07-gradient` (the medium proposes) · `08-reasons`
(ask *why*) · `09-all` (everything at once).

## Why not point an LLM at it?

Because the loop above is the thing the LLM was hired to fake. An
assistant samples plausible text and hands you the review; it cannot prune
with a proof, so you become the error-correction layer. The medium
searches the typed graph it already holds — every name in scope, every
constraint you have stated, every reason upstream — pruned by the proof at
each step, and surfaces only survivors. When two survived, you watched it
refuse to guess: it asked for the one missing constraint instead. The idea
was never the model's job; now the typing isn't either. Proposals here are
not reviewed for plausibility — they arrive proven, or they do not arrive.

## The receipts

For the skeptical: each claim with its command, and nothing that asks to be
believed. The full statement — the category, the wedges, the prior art, the
honest boundary — is [docs/POSITIONING.md](docs/POSITIONING.md).

- **The negative is provable.** Thirteen programs whose first line states
  what must prove or refuse — severance, transitivity, the higher-order
  leak, absence through stored closures, reachability on the quiet branch —
  judged by the compiler itself: `bash benchmarks/absence/run.sh` (13/13
  today; the podium this enters is empty — no current verification
  benchmark measures proving the negative).
- **It self-hosts to a byte-identical fixed point.** `bash tools/march.sh`
  compiles the compiler with itself and asserts the bytes reproduce — and
  the parallel judge (eight spawned cursors over one shared image) produces
  the same bytes as the sequential one, gated by sha:
  `bash tools/frontier-gate.sh`.
- **The hole is a proven fan, and ties teach.**
  `mentl lib/tutorial/07-gradient.mn:0` ranks a file's whole absence field;
  at any authored `??` the survivors carry their Reasons.
- **The whole board is the release gate.** `bash tools/state.sh` — git,
  the fixpoint, the frontier contracts, proof-exactness, the `!E` crucibles,
  one scoreboard.

Underneath: one graph; two operations (draw an edge, project a read). Every
subsystem is the same read in a different mode — the compiler, the IDE, the
prover, the proposal engine. Effects are rows with Boolean negation
(`with IO + !Alloc`); handlers are the one dynamic mechanism, and
handler = state = closure = continuation is one heap record, which is why a
paused computation can be persisted by copying bytes. Ownership and
refinement are inferred, not annotated; annotations are inputs that unlock
capability, never ceremony.

## For agents — the gate over MCP

Everyone fences agents at runtime; Mentl proves at compile time. `mentl mcp`
serves the verification gate as an MCP server (newline-delimited JSON-RPC on
stdio) with one tool, because the category is one property:

```json
{"mcpServers": {"mentl-gate": {"command": "mentl", "args": ["mcp"]}}}
```

The agent calls `propose` with Mentl source. The medium compiles it and
proves every claim — declared effect rows, absence severances (`!E`),
refinement predicates — *before* anything is emitted. A violating
proposal comes back `REFUSED` with each undischarged claim named at the
agent's own source lines, and the refusal teaches the fix; a proven one
lands its artifact at `.build/mcp/last.wat` — the only way bytes ever
reach that path is through the proof. The same session, verbatim:

```
REFUSED — 1 claim(s) the medium could not discharge; nothing was emitted
effects: E_EffectMismatch error: effect row mismatch: !E vs E at 3:4-3:24
effects: E_EffectUnhandled error: effect E reaches the executable root with
  no absorbing handler — ... declare one and install it with ~> over the
  performing chain. at 4:4-4:18
```

```
PROVEN — every claim discharged; artifact: .build/mcp/last.wat
infer: T_OverDeclared Warning: function 'good' declares !E but body only
  uses Pure — tighten the signature to unlock capabilities at 6:4-6:33
```

It teaches even when it accepts. The gate stays universal — that is the
point of a gate — and the end state is on the tin: the medium's own
proposals, searched from the live graph and pruned by proof, are the ones
worth taking. A model behind this gate is not forbidden; it is unemployed.

## Where this sits

There is also a civilizational argument. Machines now write most new code;
nobody can read it all; trust has to come from somewhere other than
review, and proof is the only thing that scales past attention. The full
statement — the category, the prior art, the honest boundary — is
[docs/POSITIONING.md](docs/POSITIONING.md), and the four properties it
rests on hold here by construction: any intelligence may propose, nothing
executes unproven, intent is never lost, capability is always bounded. But
that argument is the consequence, not the point. The point is the person
at the keyboard, and the developer they become.

## The surface

```
mentl run <path>        compile, prove, execute (a hole or refuted claim REFUSES)
mentl <path> check      diagnostics only, no emit
mentl compile <path>    emit WAT to stdout
mentl edit [path]       the cursor session — eight aspects + proven proposals
mentl <file>:<line>     project a position: type, effects, ownership, why
mentl <path> audit      the capability set + severance unlocks
mentl fmt <path>        canonical layout (the shape on the page is the graph)
mentl mcp               the gate on MCP stdio — agents propose, nothing executes unproven
mentl new <name>        write <name>.mn here
mentl help              the full projection
```

A target is a module name or a file path, from any directory. A bare `mentl`
reads where you are and offers each source's next keystroke.

## The three documents

Mentl's whole read-path is three self-contained files; everything else under
`docs/` is archaeology.

- `CLAUDE.md` is the method: how the medium is built and how to think in it.
- `PLAN.md` is the substance: what Mentl is, the kernel, the resolved
  decisions, the current state, the campaign order.
- `docs/SYNTAX.md` is the surface: the authoritative language form.

## What is honestly unfinished

The verifier is sound and incomplete by choice: what it cannot decide accrues
as visible pending debt, never assumed true. The named frontier — the modal
effect crown, information-flow control, durable execution as a handler swap, a
native backend — is sequenced in `PLAN.md §5`, in positive form, never hidden.
A claim you cannot re-derive from the board is a claim this project does not
make.

## License

Not yet chosen. Public-repo and license readiness is a tracked item on the
production bar (`PLAN.md §11`, column 5).
