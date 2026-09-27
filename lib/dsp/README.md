# lib/dsp — sound, the founding workload

This medium was born for signals. The `<~` verb, the `!Alloc` oath, the
refinement bounds — each earned its shape here first, on audio, where a
single wrong allocation is audible.

## Sound has memory

An echo is now plus a little of before; there is no echo without a before.
Most languages make you build memory out of scaffolding. Here, memory is a
shape you draw — a loop in the graph:

```
fn echo(mix, x) with Clock(48_000) =
  ((prev) => x + mix * prev) <~ delay(24_000)
```

`<~` means "feeds back." What advances the loop is a tick — here the
function's own next call, at the rate `Clock(48_000)` in the row declares:
the medium infers a cycle's clock from the cycle's own site (a `<~` is a
per-site line whose previous iteration is the enclosing function's next
call), so the row names the rate the program runs at, never a context the
loop must find before it may exist. The right side is a memory element: it hands back what you gave it 24,000
ticks ago, and at 48,000 ticks a second that is half a second — the slap of
a stone room. The left side is what to do each tick: `prev` is the echo's
own past arriving back; the new sample is now plus a share of before. The
whole physics of an echo, in one line you can read aloud. And a promise
rides inside it: `prev` is not a box secretly allocated each tick — the
line's memory belongs to the record of the function that holds the loop
(one line per closure, per handler install, per module for a top-level
fn), allocated once where that record is built and read as a register
every tick, which is why this same echo can sit inside a function that has
sworn never to allocate, and the oath holds.
Lesson `03-verbs` (`mentl run lib/tutorial/03-verbs.mn`) builds the context
from nothing and walks all five verbs.

## The second hand, on stage

Picture the third night of a tour. Two thousand people. Fifty seconds into
the set, the voice stutters — one dropped buffer, a click like a snapped
string — because somewhere down the call tree one line allocated memory at
the wrong moment. Every audio programmer alive holds that dread at bay the
same way: discipline, review, a wiki page that says *never allocate on the
audio thread*. A promise. Here is the same intention, said in this medium:

```
fn voice(x) with Clock(48_000) + !Alloc =
  x
    |> gain(-3.0)
    |> lowpass(0.2)
    |> echo(0.35)
```

`!Alloc`. Read it: *cannot allocate*. Not "does not," not "was tested and
didn't," not "the team agreed not to." Cannot — proven, transitively: the
gain, the filter, the echo and its half-second memory, everything they
call, to the bottom. If one line anywhere beneath this signature allocates,
the program does not build, and the refusal arrives with the chain of
reasons walked back to the guilty line. The dread does not get quieter. It
gets impossible.

And the domain's values carry their own bounds as types:

```
type Sample = Float where -1.0 <= self && self <= 1.0
```

A `Sample` that leaves the unit range is not a glitch you hear later — it
is a claim the compiler refuses at the line that broke it.

## The modules

- `clock.mn` — the four peer notions of time (`Clock`, `Tick`, `Sample`,
  `Deadline`), the rates a program declares it runs at; `<~` infers its
  clock and requires none of them.
- `feedback.mn` — the memory elements: `delay(n)`, `accumulate(init)`, the
  IIR state carriers the recurrence form binds `prev` against.
- `processors.mn` — gain, filters, clip: the everyday stages.
- `signal.mn` — stft, bandpass, the comodulogram machinery.
- `spectral.mn` — the DFT family.
- `cfc.mn` — the founding research pipeline: cross-frequency coupling on
  real recordings, native `[Float]` end to end.

## The receipts

The DSP claims are gated like everything else — real workloads
cross-validated against independent oracles over the same bytes, wired into
`bash tools/frontier-gate.sh`: the `cfc-demo` leg finds a planted (6,40)
coupling and the comodulogram matches a numpy port of the same formulas;
the `dsp-crucible` leg pushes two sinusoids and a noise tone through the
`<~` lowpass and the verdict is the filtered spectrum's argmax, exact. The
fixture sources live in `tests/frontier/`, self-contained and readable.
