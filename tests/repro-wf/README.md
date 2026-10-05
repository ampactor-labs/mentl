# wf$ static-closure recursion — repros

A fully-annotated wide recursive math fn (`cos`, `sin_series`, `atan_series`)
recurses infinitely through its `wf$` wide-face wrapper and exhausts the call
stack, once enough wide fns share the fn table. It is layout-dependent, not the
monomorphization floor: the trapping fns are already annotated, and the
`sin_series` body is byte-identical between a working build (cfc-rec) and a
failing one — only the `elem $fns` layout and the `global $sin_series`
data-offset differ, so the baked static-closure fn_ptr resolves to a different
slot. Kin of `Hβ.emit.float-evidence-ft`.

Threshold bracket, all math-only link sets (RTLIBS + math), all fully annotated:

- `wf-1fn-works.mn` — one wide fn calling `atan2` in a loop. Exit 42.
- `wf-5fn-works.mn` — five wide fns (demod columns + mvl). Exit 42.
- `wf-15fn-fails.mn` — a full demodulation comodulogram (~15 wide fns). Traps
  `call stack exhausted` in `wf$atan_series`.

`fb-state-leak.mn` is separate: it proves that a TOP-LEVEL function's `<~` line
is one per program instance and carries across independent passes (filter a
ones signal, then a zeros signal through one top-level recurrence, and the
zeros output carries the leaked tail — exit 7). That is the ownership rule, not
a defect: a cycle's memory belongs to the record of the function that contains
it (SYNTAX §`<~`), and a top-level function's record is the module's. A filter
that must start fresh is MADE — `lib/dsp/signal.mn`'s bandpass mints a new
four-section stage per pass, and `lib/dsp/feedback.mn`'s filters are all
makers.

Run one through the pinned boot: source `tools/wt-env.sh`, then
`cat lib/{memory,strings,lists,threading}.mn lib/prelude.mn
lib/math.mn tests/repro-wf/wf-15fn-fails.mn | wt_run boot/mentl.wasm`,
assemble with `wt_asm`, and run.
