# MILESTONE.md — M1: the second program (proposed)

**Goal.** Real software written in Mentl that is not the compiler, by Morgan,
used by Morgan: an offline audio renderer that writes a WAV file. Sound is the
founding workload (`lib/dsp/README.md`); this is the first time it gets a
program instead of a library.

**Why this first.** Every design decision so far has been validated against
one workload, the compiler's own source. The costs that only ordinary programs
expose (what a signature feels like at the second filter, what a beginner
types, where `!Alloc` bites) are invisible until a second program exists. The
renderer exercises `<~`, all five verbs, rows with negation, refinements,
ownership and the executable gate, and it produces something you can hear.

## Acceptance tests (the definition of done for M1)

1. `mentl run examples/render/main.mn > out.wav` produces a playable 16-bit
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

## Items

- `examples/render/` (the program). Compiler work in this milestone is only
  what the program needs, each need an issue tagged `felt`.
- WAV output through `lib/io.mn` (bytes to a file; no new host seam).
- CI workflow landed; stamp machinery deleted once it is green twice.
- The process reset from the audit's first 48 hours (docs, lints, archives).

## Explicitly not in M1

The Space spine (resident session, IDE page), the per-decl arena, columns,
`(arena, offset)`, the oracle fan, the modal world-index, native. Each is an
issue with its design linked; none is worked unless a `felt` issue needs it.

## Next two, sketched

- **M2 · the demo.** The Severance Map as static HTML from `mentl audit`
  (three colours, the third counted); the thirty-second GIF in the README;
  `mentl diagnostics` generating SYNTAX's catalog tables; positioning
  tightened with prior art named.
- **M3 · decided from the `felt` issues at the end of M2.**
