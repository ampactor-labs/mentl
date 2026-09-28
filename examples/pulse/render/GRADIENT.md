# Pulse · scene 1 — the gradient log

M1's seventh test asks for this file: what writing the renderer asked of the
medium, what the medium answered, and what was actually written. It is the
seed of M2's gradient benchmark, so it records measurements, not impressions.

## How it was written

The program was written directly, without `??` holes: no position was left
for the medium to propose into, so this log has no proposal rows yet. That is
itself the first finding for M2 — the renderer's shapes (makers returning
stages, a record of stages, a per-sample frame) were known before a line was
typed, and the holes M2 measures need a writer who does not already know
them.

What the medium did instead was **refuse, narrate, and project**. Every entry
below is one of those, with its verdict: fixed in this landing, or named as a
peer in `RESIDUE.md` with its design.

## What the medium asked for (annotations it surfaced)

| Where | What was written | Why |
|---|---|---|
| `make_echo`'s stage | `x: Float` on the signal parameter | Without it, inference spread the feedback gain's `Decay` bound through `x + fb * prev` onto `x`, and the echo demanded a `Decay` of its input — a demand nobody wrote. The annotation states the stage's true domain. Named: `Hβ.verify.higher-order-refinement` (arithmetic spreads a refinement to its operands). |
| `cutoff_at` | `-> Hz` | A filter demanding `Hz` was handed an unproven Float through the rig; the medium surfaced the debt at the crossing, and the claim moved to where the value is made. It stays pending (the Float interval tier, Phase 8.3) — the program's one open obligation. |
| `kick_pitch` | `-> Float`, not `-> Hz` | The kick's sine voice demands nothing of its frequency, so claiming `Hz` would only add a second pending obligation. A claim is written where something relies on it. |
| `render_frame`, `render_loop` | `with !Alloc + !Sample(44100)` | The oath and the rate. The handler at the root serves any instance of `Sample`, so the rate rule is a negation on the path. Named: `Hβ.effects.handler-pins-its-instance`. |
| every maker's stage | a nested `fn stage(…) with !Alloc` | A lambda cannot carry a row or annotated parameters; a nested fn is the closure that can. Named: `Hβ.lang.lambda-param-annotation`. |

## What the walk found, and where each went

Fixed in this landing (each held by a fixture seen RED on boot `43aeb30f`):

1. **A closure capturing a ground Float did not assemble** (`unknown local
   $fb`). Captures carry the USE handle — `local_ty_handle`, one read.
   `tests/micros/mn-capture-ground-wide.mn`.
2. **A match on a Float did not assemble** (the scrutinee parked in the word
   scratch). The root is read at its repr. `tests/micros/mn-match-float-scrutinee.mn`.
3. **A claim over a `match` or `if` was never decided** — `note_hz`'s `Hz`
   stayed pending over eight literals. A join decides as the AND over its
   tails. `tests/frontier/mn-refine-join-{discharges,refuses,pending}.mn`.
4. **A Float crossing a call allocated, and `!Alloc` was false** — `fn step(f,
   x: Float) with !Alloc = f(x)` boxed its argument on every call; a handler
   over a Float op did not assemble. The table carries two faces: the word
   face every `fn_ptr` names, for callers blind to the type, and the native
   face one half later, for sites that prove a wide vector.
   `tests/micros/mn-wide-closure-call-alloc-free.mn`,
   `mn-wide-op-state-alloc-free.mn`.
5. **`mentl compile` after `mentl run` printed nothing** — a warm image carries
   the handler world that wrote it, output sink included. Images are filed
   under `world_key()`.
6. **A refinement crossing a function-typed argument was dropped** — the
   render took a 70,900 Hz sweep into an `Hz` filter and checked clean.
   `tests/frontier/mn-refine-fn-{result-refuses,result-discharges,param-pending,param-discharges}.mn`.
7. **Two instances of one effect collapsed to the first** — a 44.1 kHz reader
   after a 48 kHz one escaped `!Sample(44100)`; the other order refused.
   `tests/crown/leak-instance-order.mn`.
8. **`fn f() = { field: v }` parsed as a block** — the fn body held its own
   copy of the brace discrimination. One home: `brace_form`.
9. **The formatter** wrapped a body record in parens (the parser gap,
   projected) and never broke a long record (a fourteen-field rig on one
   300-column line).
10. **The DSP library** held one filter per program for every top-level
    filter (a stereo pair shared one memory), a `dc_blocker` that was a leaky
    integrator with a DC gain of 200, a `highpass_iir` reading its own output
    as the low-pass state, an `envelope_follower` that ignored `release`, and
    `-> Sample` claims on outputs that leave the unit range. The filters are
    makers now, each stage owning its memory.
11. **`mentl fmt` deleted what it could not render** — found by this
    program's own frontier leg, which went red after the library was
    formatted: the effect head rendered `effect Sample(rate: Int)` as
    `effect Sample(rate)`, and the renderer's `with Sample(48000)` then
    refused against a bare variable. The same render dropped an effect op's
    parameter names and a pinned alias's base, all while reporting "prose
    conserved". fmt now spends every name and literal of the source against
    its render and refuses to write on any loss; a census of every `.mn` in
    the tree under that rule found exactly these three shapes.

Named, with their designs in `RESIDUE.md`:

- `Hβ.verify.higher-order-refinement` — refinement variables, so the values a
  callee passes are judged where they are made; the arithmetic spread above;
  records of functions (a rig field's function type) not yet judged at the
  crossing.
- `Hβ.effects.handler-pins-its-instance` — `~> sample_at(48_000)` serves any
  `Sample` instance.
- `Hβ.fmt.literal-spelling-is-intent` — `mentl fmt` rewrote `0x46464952` as
  `1179011410` and `48_000` as `48000`. The WAV writer writes its tags as the
  four characters they are, which is the better form regardless.
- `Hβ.lang.lambda-param-annotation` — `(freq: Float, vib) =>` is a parse error.
- `Hβ.dataflow.delay-tap` — a `<~` site hands its body only its own prior, so
  a pure delay tap is not expressible; the reverb's allpass is written
  through the comb it contains (`y = ((1 − g²)·w − x) / g`).
- `Hβ.diag.effect-mismatch-at-the-call` and
  `Hβ.diag.raw-row-variables-in-mismatch` — the allocation twin refuses at
  the declaration, not at the allocating call (M1's second test asks for the
  call), and the message prints row variables (`r18196@e608`).
- `Hβ.driver.per-module-env-overlay`, measured: a user fn named `envelope`
  collided with dsp/processors' `handler envelope`, and the library's own
  reference resolved to the user's declaration. The library's new `lowpass`
  maker collided with its own `handler lowpass` the same way and is named
  `lowpass_filter`.
- `Hβ.dsp.hz-ceiling-ambient-sample-rate` — `Hz` caps at 22,050, 44.1 kHz's
  Nyquist, in a 48 kHz program.

## Measurements (the render through the landing's compiler)

- Ten seconds, 480,000 stereo frames, 17 stages in the rig and 27 live `<~`
  lines — each minted stage owns its own: six oscillator phases, one noise
  state, five filter memories, two 12,000-sample echoes, eight comb and four
  allpass lines of reverb, and the limiter's envelope.
- Heap growth across the render: **0 bytes** (a `heap_mark` bracket around
  `render_loop`).
- `mentl check`: clean. `mentl fmt`: a no-op (the program is written in the
  formatter's canonical form). One `V_Pending`: `cutoff_at`'s `Hz`.
- Compile and render together: about three seconds.
- The oracle (`tests/frontier/pulse-render/oracle.py`): header, loudness
  (RMS 0.19 / 0.19), no full-scale sample (peak 16,322 of 32,767), and each
  of the eight notes 31–40 dB over the score's other pitches.
