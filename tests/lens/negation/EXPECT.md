# LENS §2 negation probes — the measurement record

The LIVE contract is each fixture's own first line (`// expect: refuse E_Class`
or `// expect: N`), judged by the medium's battery — `mentl test
tests/lens/negation`, run on the board by tools/verify.sh's negation leg
(36/36 since the gate landing, 2026-09-27). This file is the record of what
the probes measured before that: the columns are `mentl check` exit, first
diagnostic class (E_ before T_), `mentl run` exit (134 = wasm trap; a small
number = the program ran and returned a value).

BEFORE = boot 6fef1076, measured 2026-09-25 (the prior table; its header had
misnamed the boot as 7c9dc538, a hex string lifted from PROVENANCE prose).
AFTER PRUNE = boot 13df4844, the pin that fixed the nested-frame prune and
armed E_EffectMismatch. AFTER GATE = the wheel of PROGRAM A3, 2026-09-27 (the
gate carried by the cell): every leak is a refusal, the no-handler forms
refuse at the root, the sounds run. The two fanout probes (`adv-fan-prune`,
`adv-share-prune`) had banked "56", which the battery's in-process exec seam
answered as 1048632 — a TUPLE'S HEAP ADDRESS, not a value; they return
`a + b` (8) now, and the last column reads the corrected fixture.

| fixture | before: check | class | run | after prune: check | class | run | after gate: check | class | run |
|---|---|---|---|---|---|---|---|---|---|
| adv-annot-neg | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-annot-pure | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-arm-resume-world | 0 | T_OverDeclared | 6 | 0 | T_OverDeclared | 6 | 0 | T_OverDeclared | 6 |
| adv-fan-prune | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 8 |
| adv-hof-stored | 0 | — | 7 | 0 | — | 7 | 1 | E_EffectMismatch | 1 |
| adv-la-two-first-neg | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-lambda-prune-nohandler | 0 | — | 134 | 0 | — | 1 | 0 | — | 1 |
| adv-lambda-prune | 0 | T_OverDeclared | 7 | 0 | T_OverDeclared | 7 | 0 | T_OverDeclared | 7 |
| adv-lb-two-first-root | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 | 1 | E_EffectMismatch | 1 |
| adv-lc-one-present-neg | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-mask-partial-nohandler | 0 | T_OverDeclared | 134 | 0 | T_OverDeclared | 1 | 1 | E_EffectMismatch | 1 |
| adv-mask-partial | 0 | T_OverDeclared | 134 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-mask-prune-off | 0 | T_OverDeclared | 6 | 0 | T_OverDeclared | 6 | 1 | E_EffectMismatch | 1 |
| adv-mutual | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-nested-hof-leak | 0 | — | 14 | 0 | — | 14 | 1 | E_EffectMismatch | 1 |
| adv-nested-hof | 0 | — | 6 | 0 | — | 6 | 0 | — | 6 |
| adv-p1-two-first | 0 | T_OverDeclared | 8 | 0 | T_OverDeclared | 8 | 1 | E_EffectMismatch | 1 |
| adv-p4-one-present-noh | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 | 1 | E_EffectMismatch | 1 |
| adv-p4-one-present | 0 | T_OverDeclared | 10 | 0 | T_OverDeclared | 10 | 1 | E_EffectMismatch | 1 |
| adv-p5-two-present | 0 | T_OverDeclared | 11 | 0 | T_OverDeclared | 11 | 1 | E_EffectMismatch | 1 |
| adv-record-stored | 0 | — | 7 | 0 | — | 7 | 1 | E_EffectMismatch | 1 |
| adv-self-arg | 0 | — | 7 | 0 | — | 7 | 1 | E_EffectMismatch | 1 |
| adv-share-prune | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 8 |
| adv-sigd-self-rec | 0 | — | 7 | 0 | — | 7 | 1 | E_EffectMismatch | 1 |
| adv-tee-direct-kept | 1 | E_EffectMismatch | 3 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-tee-prune-nohandler | 0 | — | 134 | 0 | — | 1 | 0 | — | 1 |
| adv-tee-prune | 0 | T_OverDeclared | 3 | 0 | T_OverDeclared | 3 | 0 | T_OverDeclared | 3 |
| adv-twice-called | 0 | — | 8 | 0 | — | 8 | 1 | E_EffectMismatch | 1 |
| adv-two-params-launder | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-two-params-nohandler | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 | 1 | E_EffectMismatch | 1 |
| adv-unsigd-self-rec | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| lens-t1-mono-tee | 0 | — | 1 | 0 | — | 1 | 0 | — | 1 |
| lens-t2-tee-param-direct | 0 | — | 3 | 0 | — | 3 | 0 | — | 3 |
| lens-t3-let-lambda-immediate | 0 | — | 134 | 0 | — | 1 | 0 | — | 1 |
| lens-t4-let-lambda-nongen | 0 | — | 1 | 0 | — | 1 | 0 | — | 1 |
| lens-t5-let-lambda-annot | 0 | — | 1 | 0 | — | 1 | 0 | — | 1 |

A `run` exit of 1 with no `check` class is the executable root gate refusing
`E_EffectUnhandled` (a reachable perform with no handler installed anywhere);
the battery's `refuse E_EffectUnhandled` header is that verdict. The
`T_OverDeclared` rows are a negation declared over a body the tee's mask
leaves Pure — a narration, not a refusal, and pre-existing.
