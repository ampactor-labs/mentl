# lib/dsp — sound, the founding workload

This medium was born for signals. The `<~` verb, the `!Alloc` oath, the
refinement bounds — each earned its shape here first, on audio, where a
single wrong allocation is audible. The course (`examples/pulse/course`)
teaches each of them on one growing chain; this is the library it plays.

## Sound has memory

An echo is now plus a little of before; there is no echo without a before.
Most languages make you build memory out of scaffolding. Here, memory is a
shape you draw — a loop in the graph:

```
fn echo(fb: Decay) = {
  fn stage(x: Float) with !Alloc = { prev => x + fb * prev } <~ delay(12000)
  stage
}
```

`<~` means "feeds back." The right side is a memory element: it hands back
what this echo put out 12,000 ticks ago, and at 48,000 ticks a second that is
a quarter second. The left side is what to do each tick: `prev` is the echo's
own past arriving back; the new sample is now plus a share of before. The
whole physics of an echo, in one line you can read aloud. What advances the
loop is a tick — the stage's own next call — and a promise rides inside it:
`prev` is not a box secretly allocated each tick. The line's memory belongs
to the record of the function that holds the loop, allocated once where that
record is built and read as a register every tick, which is why the stage
can swear `!Alloc` and the oath holds. `echo` is a MAKER: each call mints a
stage that owns its line, so two echoes are two rooms, and a stereo pair is
two calls. Every stage with memory in this library is written that way.

## The second hand, on stage

Picture the third night of a tour. Two thousand people. Fifty seconds into
the set, the voice stutters — one dropped buffer, a click like a snapped
string — because somewhere down the call tree one line allocated memory at
the wrong moment. Every audio programmer alive holds that dread at bay the
same way: discipline, review, a wiki page that says *never allocate on the
audio thread*. A promise. Here is the same intention, said in this medium:

```
fn frame(buf, rig, n: Int) with !Alloc = {
  let lead = rig.lead(220.0) * adsr(0.01, 0.2, 0.6, 0.3, 1.0, tn) |> rig.tone(1200.0)
  wav_frame(buf, n, soft_clip(lead), soft_clip(lead))
}
```

`!Alloc`. Read it: *cannot allocate*. Not "does not," not "was tested and
didn't," not "the team agreed not to." Cannot — proven, transitively: the
oscillator, the envelope, the filter and its line, the PCM writes, everything
they call, to the bottom. If one line anywhere beneath this signature
allocates, the program does not build, and the refusal arrives with the
chain of reasons walked back to the guilty line. The dread does not get
quieter. It gets impossible.

And the domain's values carry their own bounds as types:

```
type Sample = Float where -1.0 <= self && self <= 1.0
```

A `Sample` that leaves the unit range is not a glitch you hear later — it
is a claim the compiler refuses at the line that broke it.

## The modules

- `clock.mn` — the notions of time (`Clock`, `Tick`, `Sample`, `Deadline`);
  `Sample(rate)` is the rate a program declares it runs at, an effect whose
  instance is the rate, so two rates are two effects.
- `signal.mn` — the signal's value types (`Sample`, `Hz`, `Gain`), the pure
  stages (`gain`, `mix`, `clip`, `soft_clip`), and the spectral analysis
  (stft, bandpass, the comodulogram).
- `osc.mn` — the oscillators: `saw_voice`, `sine_voice`, `square_voice`,
  `noise_source`, each a maker whose stage owns its phase line.
- `envelope.mn` — the shape of a note in time: `adsr`, `fade`, `fall`.
- `feedback.mn` — the filters: `lowpass_filter`, `highpass_filter`,
  `dc_blocker`, `envelope_follower`, and the channel and stereo strips.
- `stereo.mn` — the field a voice stands in: `pan_left`, `pan_right`, the
  `echo`, the Schroeder rooms (`room_left`, `room_right`), the `limiter`.
- `spectral.mn` — the `Distort` effect and its handlers: the distortion is
  whichever handler the root installs.
- `processors.mn` — gain, filters, clip over whole sequences.
- `cfc.mn` — the founding research pipeline: cross-frequency coupling on
  real recordings, native `[Float]` end to end.

## The receipts

The DSP claims are gated like everything else — real workloads
cross-validated against independent oracles over the same bytes, wired into
`bash tools/frontier-gate.sh`: Pulse and every course lesson render and an
oracle that shares nothing with the medium hears the score in the file, and
their one-line twins refuse; the `cfc-demo` leg finds a planted (6,40)
coupling and the comodulogram matches a numpy port of the same formulas;
the `dsp-crucible` leg pushes two sinusoids and a noise tone through the
`<~` lowpass and the verdict is the filtered spectrum's argmax, exact. The
fixture sources live in `tests/frontier/`, self-contained and readable.
