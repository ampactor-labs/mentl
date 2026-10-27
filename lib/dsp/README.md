# lib/dsp — sound, the founding workload

This medium was first built for signal processing. The `<~` verb, the
`!Alloc` constraint and the refinement bounds were each designed here first,
for audio, where a single allocation at the wrong moment can be heard. The
course (`examples/pulse/course`) teaches each of them on one chain that grows
from lesson to lesson, and its lessons make their sound with this library.

## Sound has memory

An echo is the current sound plus a little of an earlier one, so an echo
needs a memory of what came before. Most languages make you build that memory
yourself, out of supporting code. In Mentl you write it as a loop in the
graph:

```
fn echo(fb: Decay) = {
  fn stage(x: Float) with !Alloc = { prev => x + fb * prev } <~ delay(12000)
  stage
}
```

`<~` means "feeds back." The right side is a memory element: it returns what
this echo output 12,000 ticks ago, which is a quarter of a second at 48,000
ticks a second. The left side says what to do on each tick. `prev` is the
echo's own earlier output coming back, and the new sample is the current
input plus a share of that earlier output. That one line describes the whole
physics of an echo. A tick is the stage's next call, and each tick advances
the loop without allocating: `prev` is not a box allocated on every tick. The
delay line's memory belongs to the record of the function that holds the
loop. It is allocated once, when that record is built, and read like a
register on every tick. That is why the stage can be declared `!Alloc` and
the declaration holds. `echo` is a maker: each call creates a stage that owns
its own delay line, so two echoes are two independent stages, and a stereo
pair is two calls. Every stage with memory in this library is written that
way.

## The second hand, on stage

Consider a concert on the third night of a tour, in front of two thousand
people. Fifty seconds into the set, the voice stutters: one buffer is
dropped, and the audience hears a click like a snapped string. The cause is
one line, somewhere down the call tree, that allocated memory at the wrong
moment. Every audio programmer guards against this failure the same way, with
discipline, code review and a wiki page that says *never allocate on the
audio thread*. All of that depends on people keeping a promise. Here is the
same intention, written in this medium:

```
fn frame(buf, rig, n: Int) with !Alloc = {
  let lead = rig.lead(220.0) * adsr(0.01, 0.2, 0.6, 0.3, 1.0, tn) |> rig.tone(1200.0)
  wav_frame(buf, n, soft_clip(lead), soft_clip(lead))
}
```

`!Alloc` means the function *cannot allocate*. That is stronger than "does
not allocate," "was tested and did not allocate" or "the team agreed not to
allocate." The compiler proves it transitively, through the oscillator, the
envelope, the filter and its delay line, the PCM writes and everything they
call, all the way down. If any line beneath this signature allocates, the
program does not build, and the compiler reports the chain of reasons back
to the line that allocates. A click caused by an allocation on this path
cannot happen.

The domain's values also carry their bounds in their types:

```
type Sample = Float where -1.0 <= self && self <= 1.0
```

If a `Sample` would leave the unit range, the compiler refuses the line that
breaks the bound, so the error shows up at that line instead of as a glitch
you hear later.

## The modules

- `clock.mn` defines the notions of time (`Clock`, `Tick`, `Sample`,
  `Deadline`). `Sample(rate)` is the rate a program declares it runs at. It
  is an effect whose instance is the rate, so two rates are two effects.
- `signal.mn` has the signal's value types (`Sample`, `Hz`, `Gain`), the pure
  stages (`gain`, `mix`, `clip`, `soft_clip`), and the spectral analysis
  (stft, bandpass, the comodulogram).
- `osc.mn` has the oscillators `saw_voice`, `sine_voice`, `square_voice` and
  `noise_source`. Each is a maker whose stage owns its phase line.
- `envelope.mn` has the shapes of a note over time: `adsr`, `fade` and `fall`.
- `feedback.mn` has the filters (`lowpass_filter`, `highpass_filter`,
  `dc_blocker`, `envelope_follower`) and the channel and stereo strips.
- `stereo.mn` places a voice in the stereo field: `pan_left`, `pan_right`, the
  `echo`, the Schroeder rooms (`room_left`, `room_right`) and the `limiter`.
- `spectral.mn` has the `Distort` effect and its handlers. The distortion a
  program gets is whichever handler its root installs.
- `processors.mn` applies gain, filters and clipping to whole sequences.
- `cfc.mn` is the original research pipeline: cross-frequency coupling on
  real recordings, using native `[Float]` from end to end.

## The receipts

A gate checks the DSP claims, as it checks every other claim.
`bash tools/frontier-gate.sh` runs real workloads and compares each one with
an independent oracle that reads the same bytes. Pulse and every course
lesson render, and an oracle that shares no code with the medium finds the
score in the output file. Each also has one-line twins, copies with a single
line changed, and the compiler must refuse every twin. The `cfc-demo` leg
finds a planted (6,40) coupling, and its comodulogram matches a numpy port of
the same formulas. The `dsp-crucible` leg sends two sinusoids and a noise
tone through the `<~` lowpass, and it passes only if the argmax of the
filtered spectrum matches exactly. The fixture sources are in
`tests/frontier/`, and each one is self-contained and readable.
