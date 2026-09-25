# LENS §2 negation probes — before and after the nested-frame prune fix

Fixtures for docs/LENS-2026-09-25.md §2.6 and §7.1 (the adversarial pass's `adv-*` and the inline `lens-t*` discriminators).
Not wired into any gate: the remaining leak rows are red-first contracts for the gate landing (LENS §2.2, rules 1–4).
Columns: `mentl check` exit, first diagnostic class (E_ before T_), `mentl run` exit (134 = wasm trap; 7/3/8/… = the program ran and returned a value).
BEFORE = boot 6fef1076, measured 2026-09-25 (the prior table; its header misnamed the boot as 7c9dc538, a hex string lifted from PROVENANCE prose). AFTER = boot 13df4844, the pin that fixed the prune and armed E_EffectMismatch.

| fixture | before: check | class | run | after: check | class | run |
|---|---|---|---|---|---|---|
| adv-annot-neg | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 |
| adv-annot-pure | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 |
| adv-arm-resume-world | 0 | T_OverDeclared | 6 | 0 | T_OverDeclared | 6 |
| adv-fan-prune | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 56 |
| adv-hof-stored | 0 | — | 7 | 0 | — | 7 |
| adv-la-two-first-neg | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-lambda-prune-nohandler | 0 | — | 134 | 0 | — | 1 |
| adv-lambda-prune | 0 | T_OverDeclared | 7 | 0 | T_OverDeclared | 7 |
| adv-lb-two-first-root | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 |
| adv-lc-one-present-neg | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-mask-partial-nohandler | 0 | T_OverDeclared | 134 | 0 | T_OverDeclared | 1 |
| adv-mask-partial | 0 | T_OverDeclared | 134 | 1 | E_EffectMismatch | 1 |
| adv-mask-prune-off | 0 | T_OverDeclared | 6 | 0 | T_OverDeclared | 6 |
| adv-mutual | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 |
| adv-nested-hof-leak | 0 | — | 14 | 0 | — | 14 |
| adv-nested-hof | 0 | — | 6 | 0 | — | 6 |
| adv-p1-two-first | 0 | T_OverDeclared | 8 | 0 | T_OverDeclared | 8 |
| adv-p4-one-present-noh | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 |
| adv-p4-one-present | 0 | T_OverDeclared | 10 | 0 | T_OverDeclared | 10 |
| adv-p5-two-present | 0 | T_OverDeclared | 11 | 0 | T_OverDeclared | 11 |
| adv-record-stored | 0 | — | 7 | 0 | — | 7 |
| adv-self-arg | 0 | — | 7 | 0 | — | 7 |
| adv-share-prune | 0 | T_OverDeclared | 56 | 0 | T_OverDeclared | 56 |
| adv-sigd-self-rec | 0 | — | 7 | 0 | — | 7 |
| adv-tee-direct-kept | 1 | E_EffectMismatch | 3 | 1 | E_EffectMismatch | 1 |
| adv-tee-prune-nohandler | 0 | — | 134 | 0 | — | 1 |
| adv-tee-prune | 0 | T_OverDeclared | 3 | 0 | T_OverDeclared | 3 |
| adv-twice-called | 0 | — | 8 | 0 | — | 8 |
| adv-two-params-launder | 1 | E_EffectMismatch | 1 | 1 | E_EffectMismatch | 1 |
| adv-two-params-nohandler | 0 | T_OverDeclared | 1 | 0 | T_OverDeclared | 1 |
| adv-unsigd-self-rec | 1 | E_EffectMismatch | 7 | 1 | E_EffectMismatch | 1 |
| lens-t1-mono-tee | 0 | — | 1 | 0 | — | 1 |
| lens-t2-tee-param-direct | 0 | — | 3 | 0 | — | 3 |
| lens-t3-let-lambda-immediate | 0 | — | 134 | 0 | — | 1 |
| lens-t4-let-lambda-nongen | 0 | — | 1 | 0 | — | 1 |
| lens-t5-let-lambda-annot | 0 | — | 1 | 0 | — | 1 |
