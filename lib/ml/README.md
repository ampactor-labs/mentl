# lib/ml — learning is a reading of the chain you already wrote

A model is an ordinary Mentl chain. Learning uses the rate at which the
model's output changes with a parameter. Mentl computes that rate with a
reading of the chain itself, so no second program is written beside it:

```
(w - rate * d(loss(w, xs))) ~> grad(w)
```

The body evaluates exactly as it would if the handler were not installed.
`d(v)` requests ∂v/∂w. The medium computes it with a derivative program, which
it derives from the chain's own graph and emits beside the forward program.
Nothing records a tape and no operator is overloaded. There is also no
hand-written backward pass, so none can drift out of step with the forward
pass.

- `grad.mn` holds the `Derivative` effect and the `grad` reading.
- `tensor.mn` holds the basic matrix code that the models are built on.

The part of SYNTAX's §«`~>` — tee» on the derivative reading lists what the
reading covers today and what it refuses. A refusal names the construct that
would lose a derivative; the reading never returns zero in its place.

## The receipts

`bash tools/frontier-gate.sh` checks the learning workloads, and it compares
each one with an independent oracle run on the same data. The `ml-crucible`
leg runs batch gradient descent on 32 points and converges exactly to the
planted weights (3, 1). The `adaptive-crucible` leg is a 2-tap LMS filter that
learns a channel *online*, so feedback, float math and learning run in one
loop. Both legs write their gradients by hand. The `derive-lms` leg runs the
same filter but requests its step as `d(e * e)`, and checks it against the
same oracle facts. The `derive-shape` leg checks the slope of the distortion
that scene 1 renders against the finite difference of the same function
(`tests/frontier/derive-crucible/`).
