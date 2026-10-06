# earlyexit — early exit is a resume grade (V1)

Status: stage 1 (the compiler mechanism) is built and verified. Stage 2 (the
prelude's `any`/`all`/`find`/`take` and their two micros) is
`landing/earlyexit-stage2.patch`. It has to go in after this lane's repin,
because the current boot compiles the new prelude under its old lowering
(measured below). Lazy `iterate` is not built; it is named under Open.
verify.sh was stopped mid-run when the recovery routine fired.

The four stage-1 micros are `landing/earlyexit-stage1-micros.patch`. The pre-commit
verify runs the battery through the BOOT, and they are RED there by design, so they go in
with the repin. They are green through this lane's m2 (381/381 battery with them in).
The pre-commit verify also caught an unresolved backtick (`echo`) and one effectful lambda
over the 220 bound. Both are fixed: the backtick is now prose, and the lambdas are now
named `arm_op_answers` / `arm_is_driven`.

## Verdicts (read this session, stage 1, base 4228ff71)
- march: CLEAN, `m2 == m3`. Cost line: m3 leg 27.02s wall, 389MB peak RSS (398888 KB).
- micro battery through m2: 381/381.
- frontier (fresh): 599 pass / 0 red / 1 expected-red.
- crown: 134 pass / 0 fail.
- proof-exactness: 30 pass / 0 red.
- effect identity: green (mn-effect-identity exit 81).
- `mentl check src/main.mn`: zero diagnostics.
- verify.sh: NOT RUN TO COMPLETION (interrupted).
- ide-gate: not run (this lane does not touch ide/ or the session).

## The instrument, then RED first
Each line below shows the boot with the base prelude, then the stage-1 m2:
- `ask(x) => if x > 2 { 100 } else { resume(x) }` over `ask(1)+ask(5)` under `!Alloc`
  (tests/micros/mn-mixed-arm-answers.mn): **101** → 100. The arm's answer went back to the
  performer as the op's result, with no diagnostic.
- the same op, one handler resuming and one abandoning (mn-mixed-across-handlers): **trap 134**
  (`uninitialized element` in op_echo_ask, through the redrive) → 106.
- an answer naming its install, nested installs of one handler (mn-answer-names-its-install):
  **36** → 5.
- an answer under a held resume's remainder (mn-answer-through-held-resume): **22** → 20.
- stage 2 on the stage-2 compiler: `any` with a counting handler (mn-any-stops-at-the-hit):
  **5** → 3. find/all/take (mn-search-stops-at-the-hit): **8** → 6.

## What landed (stage 1)
- `ResumeUse` gains the one new point of ResumeUse × MayAbandon, `RTailOrAbandon`.
  `resume_join(RNone, RTail)` is that point now, not RTail. The match-arm and tail-argument
  folds start at their first element, never at an RNone identity. A mixed grade read from
  another frame (a callee summary, or a lambda handed to a tail-transparent callee) is the
  held grade (`resume_from_frame`).
- A callee's parameters are tail-transparent only when every tail path calls one of them
  (`tail_paths_delegate`). `call_if(c, () => resume(1))` was a stack return, and its `0`
  went back as the op's result.
- `ResumeDiscipline.OneShotOrAbandon`. disc_join: a resume beside an abandon is the mixed
  op. The first handler drawn sets the op's discipline. Closes
  `Hβ.lower.abandon-with-resume-arm`.
- Lowering: the arm of a mixed op is lowered down its result spine (`lower_answering`, by
  the judgment's grade through `ls_resume_grade`, the classifier fixpoint registered once in
  lower_program). A leaf that never resumes becomes `LAnswer(h, value, record)`.
  `lower_block`/`lower_match_arms` take a `BranchAt`.
- Emit: `LAnswer` stores the value at its width into area slot 0 (journaled) and the
  install record into slot 1. It sets `$yield_op = -1` (`answer_key`), a dead k and the
  flag, then unwinds. The performer's boundary check takes it from there (mixed ops are in
  `unwinding_ops`). The install's redrive takes an answer that names its own record, clears
  the slot, and returns the value in both channels (the word and `$__lane_f64`).
  `handler_drives` / `handler_takes_answers` / `driven_ops_of` decide where the driver runs.
- derive: answering installs are not entered by the reading (as multi-shot ones are not).
- SYNTAX §Resume discipline: the OneShotOrAbandon bullet.

## Kills
1. "The boot's `take` drops an element" — killed. The boot was compiling the NEW prelude
   under its old lowering. With the base prelude, take is correct (takeprobe 33).
2. The first march trapped at m3 (4.2GB peak). The cause measured was the new prelude
   compiled by the boot (m2's own any/all/find/take were wrong). With the prelude reverted:
   CLEAN, 389MB.
3. Stage 2 kept 5694 arena exits and peaked at 680MB. The cause measured was the answer
   slot staying journaled after the catch. With the slot zeroed at the catch: 0 kept,
   491MB peak.
4. Per-arm answer precision through `ls_resume_grade` at emit: it refused m2 with
   `E_EffectUnhandled LowerScope` at main, so the decision is per op.
5. `AtValue`/`AtAnswer` collided with infer's FnEnd constructors and were renamed
   BranchValue/BranchAnswer. A HOF form of lower_block fired infer's `B2-mixed-open
   arg-edge` probe print, so it was replaced by the ADT.

## Stage 2 validation (stage-1 m2 as the boot, `landing/earlyexit-stage2.patch` applied)
s2 = stage1(wheel+patch) and s3 = s2(wheel+patch): **s2 == s3**, 560033 lines. The s3 leg
ran 27.46s at 491264 KB peak (under the 539,000 KB ceiling), with 0 arenas kept. All six
micros pass on s2.

## Open (draft RESIDUE)
- `Hβ.prelude.iterate-walks-the-representation`. `iterate` still flattens a non-flat list
  before its first yield. The form is to index a flat run in place, walk a slice as its
  base's window and a concat left then right with an explicit stack, and flatten a snoc
  chain only when the walk reaches it. Snoc reaches its first element last, so it is
  inherently O(n) prep. Typing needs a substrate entry for the run read, because a raw Addr
  child poisons the element var. Not measured: how many wheel iterates hit non-flat lists.
- The early-exit census shape (VERB-3's gate), the 12 hand-rolled first-hit walks and
  `position`/`fold_while` are not built.
- Process note: four arms in lower.mn were written by a python script, not the Edit tool.
  drift-audit was run on the file by hand afterward and came back CLEAN.

## Next step
Run verify.sh, write the ledger draft, merge the base, and push. After the integration
repins from this lane, apply `landing/earlyexit-stage2.patch` and march.
