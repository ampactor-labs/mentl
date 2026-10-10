# Reading Mentl

These are the project's essays: what Mentl is for, and what it is like to
use. The README carries the commands, the tests and the limitations; the
thesis has one home, `PLAN.md §0`, and these pages are written from it.
Every transcript below was run against the pinned compiler on 2026-10-09
and is quoted whole; `src/types.mn` holds each diagnostic's wording, so a
transcript that has drifted is the code's word against this page's, and
the code wins.

## The gap

Every day people sit down to say what they mean to a computer, and the
biggest source of bugs, complexity and frustration is not syntax or
speed. It is the **gap between what a person means and what they are
forced to write.** A programmer thinks *"this reads a file, parses it,
and might fail,"* and the language makes them spell out async-ness,
borrows, error boxes and lifetimes — ceremony it demands because its
compiler could not work those out for itself.

**Mentl closes the gap between what a person means and what they are
forced to write.** It does it by being smarter about inference rather
than sloppier about types. The compiler carries every fact it can prove — the
type, the effects, the ownership, the bounds, and the reason behind each
— and you write only your decisions: what a function must never do, what
bound a value keeps, what width a number needs. At any line of any file
it answers *what is true here, and why*. At a hole it proposes the next
move it can prove, and when two proven moves mean different things it
asks which one you meant instead of guessing. There is no separate
curriculum: picking the language up is learning to program, because the
compiler's answers are the course. The programs are the means; the
developer they become is the end.

Here is the first lesson's one function. It joins two pieces of text and
prints them:

```
fn greet(name) = "Hello, " ++ name ++ ". The medium is reading you back.\n" |> print_string
```

You wrote no types and no effects. Ask the compiler at the pipe:

```
$ mentl lib/tutorial/00-hello.mn:29:77
Query: "Hello, " ++ name ++ ". The medium is reading you back.\n" |> print_string : ()
Effects: Memory + Alloc + Trap + WASI
Why: through |>, at tutorial/00-hello:29
     result
     its type: returned from fn, at tutorial/00-hello:29
     through |>
     target
```

It worked out that joining text allocates (`Memory + Alloc`) and that
printing reaches the host (`WASI`), and it keeps the chain of why.
Nothing in the source says so, because none of it was a decision.

## Never, said and proven

Some decisions are about what must never happen: *this never touches the
network*, *this never allocates*. People mean this all the time, and no
mainstream language lets them write it. In Mentl it is a clause on the
signature, and the compiler proves it through everything the function
calls — including code passed in that you did not write:

```
effect Network {
  fetch(url: String) -> String
}

fn admit(plugin, x) with !Network = plugin(x)

fn shout(s) = s ++ "!"

fn main() = len(admit(shout, "hi")) + len(admit(fetch, "example.com"))
```
```
$ mentl run admit.mn
effects: E_EffectMismatch error: effect row mismatch: !Network vs Network — at 5:1-5:46: declared as admit at admit:9:43-9:70
verify: V_Pending VerificationPending: 17 verification obligations pending at admit:0:0-0:0
effects: E_EffectUnhandled error: effect Network reaches the executable root with no absorbing handler — calling one of its ops would read garbage evidence at runtime; nothing executes unproven. No handler in scope handles Network — declare one and install it with ~> over the performing chain. at admit:9:1-9:71
mentl: refusing to emit — 2 claim(s) the medium could not discharge
```

`!Network` reads *cannot reach the network* — not "does not," not "was
tested and didn't." `admit(shout, "hi")` passes; `admit(fetch, …)` is
refused at the call that hands it a fetching plugin, and the refusal
names the declaration whose promise it would break. A false claim
produces no program at all. (The pending line is the runtime library's
own open proof debt, reported at your program; a library judged at its
own boundary would report nothing here — `Hβ.space.nothing-is-collapsed`
in `RESIDUE.md`.)

The same holds for a bound:

```
type Percent = Int where 0 <= self && self <= 100

fn main() = {
  let p: Percent = 140
  42
}
```
```
$ mentl run refuse.mn
verify: E_RefinementRejected error: refinement predicate proven false at compile time: 0 <= self && self <= 100 at refuse:4:20-4:23
verify: V_Pending VerificationPending: 17 verification obligations pending at refuse:0:0-0:0
mentl: refusing to emit — 1 claim(s) the medium could not discharge
$ echo $?
1
```

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
[lib/dsp](../lib/dsp/README.md).

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

**Ask it** — at the pipe, as above: the type, the effects, and the why.

**Break it.** Copy the lesson to `hello_alloc.mn` and ask `greet` to
promise it never allocates — write `with !Alloc` on its signature — and
the medium answers at the declaration:

```
effects: E_EffectMismatch error: effect row mismatch: !Alloc vs Memory + Alloc + Trap + WASI — at 29:1-29:104: declared as greet at hello_alloc:29:1-29:104
mentl: refusing to emit — 1 claim(s) the medium could not discharge
```

You claimed *never*; it read the body and refused to build the claim.

**Leave a hole.** Write `??` where a value should go and the medium
proposes only what it can prove:

```
type Positive = Int where self > 0

fn rate() -> Positive = ??
```
```
$ mentl hole.mn:3:25
Query: ?? : Positive
Propose: 1  — inferred from the type's integer inhabitants
  · refused out_of_range — inferred from performs Trap — refused by the target row Pure
  · refused world_key — inferred from performs Memory — refused by the target row Pure
Effects: whatever its position permits — a hole states no row
Why: returned from rate, at hole:3
     body
     its type: declared rate, at hole:3
```

And when more than one candidate survives the proof, it does not guess. It
names what separates them and asks:

```
type Bit = Int where 0 <= self && self <= 1

fn pick() -> Bit = ??
```
```
$ mentl bit.mn:3:20
Query: ?? : Bit
Propose: 2 proven survivors — a tie:
  0  — inferred from the type's integer inhabitants
  1  — inferred from the type's integer inhabitants
  the survivors differ in VALUE and the type admits 0 through 1: which one does this position mean?
  · refused out_of_range — inferred from performs Trap — refused by the target row Pure
  · refused world_key — inferred from performs Memory — refused by the target row Pure
Effects: whatever its position permits — a hole states no row
Why: returned from pick, at bit:3
     body
     its type: declared pick, at bit:3
```

(The refused lines name helpers of the runtime library a learner never
wrote; offering them at all is `Hβ.synth.linked-ring-offers-substrate-internals`
in `RESIDUE.md`.) Nothing is offered that did not survive the proof, and a
tie teaches instead of picking silently. That is the loop the whole school
rides: read a little, run it, break it on purpose, let the refusal teach,
and ask at any line. Walk the lessons in order: `00-hello` (meet the
medium) · `01-graph` (everything is one graph) · `02-handlers` (effects are
answered, not feared) · `03-verbs` (the five shapes) · `04-row` (declaring
and denying capabilities) · `05-ownership` (who holds a value) ·
`06-refinement` (types that carry bounds) · `07-gradient` (the medium
proposes) · `08-reasons` (ask *why*) · `09-all` (everything at once).

## Why it proposes instead of guessing

A suggestion that might be wrong makes you its reviewer: it hands you
plausible text and the job of checking it. The medium does the opposite.
It searches the typed graph it already holds — every name in scope, every
constraint you have stated, every reason upstream — prunes by proof at
each step, and shows only survivors. When two survive, you watched it
refuse to choose for you; it asked the one thing it could not know. The
idea is always yours, and so is every decision; what the medium takes
off your hands is the typing, and the checking.

## The receipts

Each claim with its command; the full statement, with the prior art and
the honest boundary, is [docs/POSITIONING.md](POSITIONING.md).

- **The negative is provable:** `bash benchmarks/absence/run.sh` — each
  task's first line states what must prove or refuse, judged by the
  compiler itself.
- **The medium proposes, and asks:** `mentl test tests/proposals` and
  `mentl test tests/teach` — each fixture states what the hole must fill
  or ask, or what annotation the gradient must propose.
- **It self-hosts to a byte-identical fixed point:** `bash tools/march.sh`
  compiles the compiler with itself and asserts the bytes reproduce.
- **The whole board is the release gate:** `bash tools/state.sh` — the
  fixed point, the frontier contracts, proof-exactness, the `!E`
  crucibles, one scoreboard.

Underneath: one graph; two operations (draw an edge, project a read). Every
subsystem is the same read in a different mode — the compiler, the IDE, the
prover, the proposal engine. Effects are rows with Boolean negation
(`with IO + !Alloc`); handlers are the one dynamic mechanism, and
handler = state = closure = continuation is one heap record, which is why a
paused computation can be persisted by copying bytes. Ownership and
refinement are inferred, not annotated; annotations are inputs that unlock
capability, never ceremony.

## What falls out

A medium that proves what it runs and never loses what you meant does
both for every author. Code you did not write — a dependency, a plugin, a
teammate's change, a model's output — meets the same proofs and the same
refusals, so it can be trusted for the same reason yours can. That is a
consequence of building the language for people, not the reason for
building it. The point is the person at the keyboard, and the developer
they become.

## The three documents

Mentl's whole read-path is three self-contained files; everything else under
`docs/` is reference or archaeology.

- `CLAUDE.md` is the method: how the medium is built and how to think in it.
- `PLAN.md` is the substance: what Mentl is, the kernel, the resolved
  decisions, the current state, the campaign order.
- `docs/SYNTAX.md` is the surface: the authoritative language form.
