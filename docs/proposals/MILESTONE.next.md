# MILESTONE.md — M1: Pulse, first scene (proposed)

**Goal.** Real software written in Mentl that is not the compiler, by Morgan,
used by Morgan. The program is Pulse, the one the day-trace named in May: a
real-time audio pipeline with a browser UI, a cloud ingestion service and a
training pathway. M1 builds its first scene, the offline renderer that writes
a WAV file. Sound is the founding workload (`lib/dsp/README.md`); this is the
first time it gets a program instead of a library, and the first time the
gradient, the oracle and the cursor have a program to be measured on.

**Why this first.** Every design decision so far has been validated against
one workload, the compiler's own source. The costs that only ordinary programs
expose (what a signature feels like at the second filter, what a beginner
types, where `!Alloc` bites) are invisible until a second program exists. The
renderer exercises `<~`, all five verbs, rows with negation, refinements,
ownership and the executable gate, and it produces something you can hear.

## Acceptance tests (the definition of done for M1)

1. `mentl run examples/pulse/render/main.mn > out.wav` produces a playable 16-bit
   PCM WAV of at least ten seconds: oscillators → echo (`<~ delay`) → lowpass
   → the spectral distortion (`lib/dsp/spectral.mn`) → stereo mix.
2. The per-sample path is declared `!Alloc`. Introducing one allocation on it
   makes the build refuse with the Reason at the allocating call. This is the
   thirty-second demo in CLI form; M2 puts it on a page.
3. `Sample` refinements bound the signal; a constant that violates them refuses
   at compile time (`E_RefinementRejected`).
4. The program is at least 500 lines of ordinary Mentl written by Morgan, with
   `mentl fmt` a no-op on it and `mentl check` clean.
5. CI (`.github/workflows/board.yml`) is green on every push during the
   milestone.
6. The stranger test: one person who has never seen the repo installs it and
   runs `lib/tutorial/00-hello.mn` in ten minutes from the README alone. The
   time and every stumble are recorded as issues tagged `felt`.
7. The gradient log: every `??` left while writing the renderer and every
   annotation the gradient surfaced is recorded (what the medium proposed,
   whether it was right, how long it took, what was actually written). This
   is the seed of M2's gradient benchmark.

## Items

- `examples/pulse/render/` (the program). Compiler work in this milestone is
  only what the program needs, each need an issue tagged `felt`.
- WAV output through `lib/io.mn` (bytes to a file; no new host seam).
- CI workflow landed; stamp machinery deleted once it is green twice.
- The process reset from the audit's first 48 hours (docs, lints, archives).

## Explicitly not in M1

The Space spine (resident session, IDE page), the per-decl arena, columns,
`(arena, offset)`, the oracle fan, the modal world-index, native. Each is an
issue with its design linked; none is worked unless a `felt` issue needs it.

## Status against the acceptance tests (2026-09-28, the scene-1 landing)

1. Met: `mentl run` renders ten seconds of 48 kHz stereo; the frontier's
   `pulse-render` leg judges the file with a Goertzel oracle.
2. Met at the declaration, not at the call: one allocation beneath
   `render_frame` refuses `E_EffectMismatch` naming `render_frame`'s row;
   the Reason at the allocating call is `Hβ.diag.effect-mismatch-at-the-call`.
3. Met: a sample out of range refuses `E_RefinementRejected` (a board twin).
4. Not met as written: 460 lines, written by Claude with Morgan's direction,
   `mentl check` clean and `mentl fmt` a no-op.
5. Not met: there is no `.github/workflows`; the board's CI entry is
   `tools/ci/run-board.sh`, and a workflow file is a decision still open.
6. Not run.
7. Met in part: `examples/pulse/render/GRADIENT.md` records every annotation
   the medium asked for and every defect the walk found; no `??` was left,
   so there are no proposal rows yet.

## Next two, sketched

- **M2 · Pulse scenes 2 and 3 — real time, then learning.** The render loop
  becomes 128-sample blocks with voices `><` under `~> Thread` and the race
  rule holding, the handler pinning its `Sample` instance, and the real-time
  margin as a number on the board. Then one distortion stage differentiated
  by `~> grad(w)` (AD as a demanded projection), trained against a target
  rendered by the reference stage, checkpointed mid-training and resumed,
  with the same stage bytes still `!Alloc` under the real-time reading.
- **M3 · Pulse scene 4 — authoring.** The gradient benchmark published from
  the scene-1 log turned into proposal fixtures (holes filled with proven
  survivors and no model; ties that ask the right question; time to first
  proposal); the Severance Map over `examples/pulse` as the thirty-second
  demo; an accept drawn through the graph; `mentl diagnostics` generating
  SYNTAX's catalog tables. What follows is decided from the `felt` issues at
  the end of M3.
