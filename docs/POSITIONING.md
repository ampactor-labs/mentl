# Mentl, positioned — the claims and their commands

This document states what Mentl claims against the 2026 field, and gives
the command that checks each claim on this repository. Nothing here asks
to be believed: run the command. The release protocol at the end makes
that the norm rather than a courtesy. It carries no counts — a count in
prose is a copy of a fact the artifact holds, so each claim names the
command that reads it.

The claim in one sentence, from `PLAN.md §0`: **Mentl closes the gap
between what a person means and what they are forced to write.** Its compiler
carries every fact it can prove — types, effects, ownership, refinements,
and the reason behind each — so the source holds only the author's
decisions, and at the position they are working it says what is true and
why, proposes the next move it can prove, and asks the one question that
separates two meanings instead of guessing. It is a programming
environment in the line of Engelbart, Kay, Papert and Victor, with proof
as its trust mechanism and one graph as its substrate.

## Claim 1 — the compiler writes the ceremony, the author writes decisions

A programmer thinks *"this reads a file, parses it, and might fail"* and
most languages make them spell out borrows, error boxes, async-ness and
an effect list a compiler could have worked out. In Mentl the effect row,
the ownership grade and the refinement obligations are inferred, and a
`with` clause holds only what inference cannot say: a negation, an
instance pin, `Pure`. A clause that restates the inferred row is narrated
as an inventory (`T_RowInventory`), and the medium writes its own
migration: `mentl tighten` rewrote the compiler's own signatures to their
residue, and a standing bound keeps them there.

Check it:

```sh
mentl <file>:<line>       # the row, ownership and Reason chain at the line, typed by no one
mentl tighten <file>      # each declared row rewritten to what only its author could say
mentl verify              # the compiler's standing bounds on its own source (src/board.mn),
                          # among them that it authors no positive effect row
```

## Claim 2 — "never" is sayable

"This never touches the network", "this never allocates" — people mean
this constantly, and no mainstream language lets them write it. In Mentl
`!Network` is a claim the compiler proves through every callee, through
higher-order functions and stored closures, and per instance
(`!Sample(44100)`), or refuses at the claim's own span. The nearest prior
in print is Flix's effect exclusion ("With or Without You", Lutze, Madsen,
Schuster, Brachthäuser, ICFP 2023), and absence inside a polymorphic row
goes back to Rémy (POPL 1989) and Links (TyDe 2016); we cite them rather
than claim them. What is Mentl's is the conjunction in one self-hosted
substrate: per-instance negation, negation through a handler's install,
and the compiler held to the same bounds as the programs it compiles.

Check it:

```sh
bash benchmarks/absence/run.sh     # absence tasks judged by the compiler itself: each must
                                   # refuse naming its class at a teaching span, or prove;
                                   # under- and over-refusal both scored
bash tools/crown-gate.sh           # every leak-* crucible in tests/crown must refuse and
                                   # every sound-* one must not
```

## Claim 3 — the medium proposes, and asks instead of guessing

Mentl's `??` is a typed hole whose candidates are pruned by effect rows
(with negation), ownership and refinements, over a live image. Each arm
exists somewhere in prior work — RbSyn (effects), RusSOL (ownership),
Synquid (refinements), Hazel (live holes) — and no published system
combines them in one hole. A survivor is proven before it surfaces. When
two survivors mean different things, the medium does not pick: it reads
the first cell their two proofs bound differently and asks about that —
"which type does this position hold?" — in the vocabulary of what the
developer was just writing. At a declaration the same gradient proposes
the annotation that discharges what the program still owes (a
precondition, a return contract), proven before it is offered.

Check it:

```sh
mentl test tests/proposals      # each fixture's first line states what the hole must fill or ask
mentl test tests/teach          # each fixture states the annotation the gradient must propose
mentl <file>:<line>:<col>       # at any authored ??: the verdict, each survivor with its Reason
```

## Claim 4 — verify by replay, the release

There is no signing ceremony to trust. The pinned compiler
(`boot/mentl.wasm`) carries a provenance chain (`boot/PROVENANCE.md`)
whose every entry was self-confirmed at pin time, and the claim is
*replayable*: re-run the march and the compiler reproduces itself
byte for byte from source. A hand-typed sha cannot enter history —
`tools/doc-truth.sh` runs inside every verify and pre-commit, checking
the recorded pin against `sha256(boot/mentl.wasm)` mechanically. This is
stronger than a signature: a signature says who built it; the replay says
*what it is*, to the byte, on your machine.

```sh
sha256sum boot/mentl.wasm          # the pin
head -40 boot/PROVENANCE.md        # the chain's newest entry, sha included
bash tools/doc-truth.sh            # the docs' checkable claims vs the artifact
bash tools/march.sh                # the replay: source → itself, byte-identical
```

## What falls out — code you did not write

A medium that proves what it runs and never loses intent does both for
every author, so code a person did not write — a dependency's, a
plugin's, a teammate's, a model's — meets the same proofs and the same
refusals. That is a consequence of the thesis, not the thesis. A guessing
assistant's channel is intent → tokens → plausible text → human audit,
lossy at every arrow; Mentl's is intent → constraint → a search pruned by
proof at every step → survivors → a question where they disagree → the
accepted move proven. `mentl mcp` serves the same gate and the session's
reads over the Model Context Protocol to any editor or tool. The nearest
work on this axis is in Scala 3 with published evaluations — Odersky,
Zhao, Xu, Bračevac and Pham, "Tracking Capabilities for Safer Agents"
(CAIS 2026), and LACUNA (arXiv 2605.28617) — and Mentl has run no
comparison against it.

## The honest boundary

Credibility with skeptics comes from stating what is *not* claimed.

- **Spec-faithfulness sits above the crown.** A proof is relative to a
  spec; proof-passing-but-intent-wrong code is a failure a proof
  *launders*, not one it removes. The person owns intent — that is the
  one genuine Outside, and the reason the tie-break asks instead of
  guessing.
- **Verify is sound and incomplete by choice.** Undecidable residue
  accrues as visible `V_Pending` debt, never silent assumption, and the
  compile says so: `mentl query src/main.mn smt` renders each open
  obligation of the compiler's own source.
- **Classes arm one at a time.** A diagnostic class refuses executables
  only once the compiler's own census of that class is zero; `diag_refuses`
  in `src/types.mn` is the live list. Unarmed classes surface and the
  compile proceeds; the verdict says which happened.
- **`!E` is not yet sound at every altitude.** Negation under the modal
  world-index is open (`PLAN.md §4③`); each rule lands as a crucible in
  `tests/crown` first.
- **The correctness oracle is still external.** The micro battery and the
  fixed point prove reproduction and behavior; absorbing them into the
  compiler's own Verify (and diverse double-compilation for
  trusting-trust) is named, sequenced work, not a claim.
