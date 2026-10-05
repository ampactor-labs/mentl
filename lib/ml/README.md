# lib/ml — learning is a reading of the chain you already wrote

A model is an ordinary Mentl chain. Learning asks how its output changes
with a parameter, and that question is a READING of the chain, not a second
program beside it:

```
(w - rate * d(loss(w, xs))) ~> grad(w)
```

The body evaluates exactly as it would without the install. `d(v)` asks for
∂v/∂w, and the medium answers from a derivative program it derives from the
chain's own graph and emits beside the forward one. Nothing records a tape,
no operator is overloaded, and no hand-written backward pass can drift from
the forward pass it mirrors, because none exists.

- `grad.mn` — the `Derivative` effect and the `grad` reading.
- `tensor.mn` — the matrix floor the models stand on.

What the reading covers today and what it refuses (naming the construct that
would lose a derivative, never answering zero) is written in `RESIDUE.md`
under `Hβ.lower.ad-is-a-demanded-projection`.

## The receipts

The learning workloads are gated in `bash tools/frontier-gate.sh`, each
cross-validated against an independent oracle over the same data: the
`ml-crucible` leg runs batch gradient descent on 32 points and converges to
the planted weights (3, 1) exactly; the `adaptive-crucible` leg is a 2-tap
LMS filter learning a channel *online* — feedback, float math and learning in
one loop. Both write their gradients by hand; the `derive-lms` leg runs the
same filter with its step asked for as `d(e * e)` and judged by the same
oracle facts, and the `derive-shape` leg checks the slope of the distortion
scene 1 renders against the finite difference of the same function
(`tests/frontier/derive-crucible/`).
