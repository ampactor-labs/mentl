# SYNTAX.md — Canonical syntax specification

> *The form that best translates intent into computation.*

> **One of the three documents (the contract).** Mentl's read-path is exactly
> three self-contained docs — `CLAUDE.md` (*method*), `PLAN.md` (*substance*),
> and this one, `SYNTAX.md` (*surface*). This file is the **authority on syntax**
> and supersedes any syntactic claim in the other two. For *what Mentl is*, the
> kernel, and the resolved design decisions, see `PLAN.md`; for *how to work*,
> `CLAUDE.md`. The former `docs/**` corpus (DESIGN.md, SUBSTRATE.md, the per-
> module specs) is git archaeology, out of the read-path — its load-bearing
> truths live in the three docs now. **Interrogate, don't absorb** (CLAUDE.md):
> every form below is the current best answer, to be re-checked against "what
> does the ultimate medium do here," not gospel — REDUCTIVELY (is this the minimal
> graph-correspondence?) AND GENERATIVELY (how do multi-shot / threading / WASM-
> memory + the frontier make the surface *better*? — `PLAN.md §2`). Like the
> source, the surface is INVARIANT to the current parser: it is never lowered to
> "what parses now" (§ below — the parser is the lathe adjusted to SYNTAX.md), and
> "form reachable now" is the same downward-equivocation drift at the surface.

This document is **the authoritative syntactic spec for Mentl**. It binds the parser; the parser implements exactly this. It is written under dream-code discipline: every decision below is the IDEAL form, not a description of the current parser. Where the current parser deviates, the parser is wrong; SYNTAX.md is the wheel, the parser is the lathe being adjusted to it.

> **Resolved-design note (`PLAN.md §4`).** The value ontology (`§4①`) is realized
> **on the surface now**, not deferred. There is ONE sequence node-kind, so
> `String` IS `[Byte]` + a parse-time text/interpolation view; `++` is one
> `seq_concat`; `==` is one structural-eq derivation; `Int`/`Float` are `Word` +
> a representation gradient (`Bool` already derives — `False | True`). The surface
> is INVARIANT to the substrate, and the byte-sequence ontology is that invariant
> form, so it IS the form on the page — the *lowering* is sequenced to catch up to
> the surface (§5/§5.3), never the surface lowered to current lowering. The one
> genuinely post-real forward-pointer is the **effect system** (`§4③`): `!E` is
> present and load-bearing now; the modal synthesis that closes the higher-order
> leak, and the IFC flow-constraint (`§4⑥`), are sequenced after first-light —
> their absence named in positive form where each would land, never a hedge that
> the present forms are "pragmatic, not final."

---

## Syntax ↔ the eight-primitive kernel

Every form below exists to make one primitive of the kernel (`PLAN.md §2`) reachable as text. No form exists without a kernel correspondence. This is not decoration — it is a load-bearing constraint: a syntactic feature with no kernel primitive behind it has no semantic home, and every such feature in peer languages has been regretted. The kernel has eight primitives; Mentl has eight tentacles; the surface forms below have eight corresponding surfacing groups.

| # | Kernel primitive                                    | Tentacle   | Surface form                                                    |
|---|-----------------------------------------------------|------------|-----------------------------------------------------------------|
| 1 | Graph + Env                                    | Query      | AST nodes implicit; `import` brings module envs together         |
| 2 | Handlers with typed resume discipline               | Propose    | `effect`, `handler`, `~>` (the one install verb), `resume`. Ops are invoked as BARE CALLS — effect-ness lives in the op's row (`Closed[eff]` at decl), never in a call-site keyword (`perform` is NOT a keyword — dissolved; see §«Invoking effect operations»). Resume cardinality is INFERRED from arm body structure (count of resume sites under control-flow ancestry); never authored as annotation. |
| 3 | Five verbs                                          | Topology   | `\|>`  `<\|`  `><`  `~>`  `<~` with canonical layout             |
| 4 | Full Boolean effect algebra (`+ - & ! Pure`)        | Unlock     | `with E1 + !E2 + Pure` in fn sigs, handler sigs, types — declared row is a CONSTRAINT verified against the row inferred from the body's op-call sites, never a contract |
| 5 | Ownership as an effect                              | Trace      | `own` / `ref` parameter markers; inferred from usage count by default (0/1/2+ → Inferred/Own/Ref) |
| 6 | Refinement types                                    | Verify     | `type Name = Base where predicate`; per-program-point narrowing inferred from `if`/`match`/`assert` sites |
| 7 | Continuous gradient                                 | Teach      | The gradient is continuous, derived (gates_unlocked × proximity); annotations are INPUTS that unlock gradient ascent at a position. The gradient itself is never authored — it emerges from the cursor reading the kernel's truth at P. |
| 8 | HM inference with Reasons                           | Why        | No turbofish; generic params declared, inferred at call; wildcard `_` holes admit productive-under-error continuation |

**Rule:** before adding a syntactic form, ask: which kernel primitive does it surface (and therefore which tentacle speaks for it)? If none, the form doesn't belong. If multiple, they were missing a shared form — consolidate.

Each section below labels which primitive(s) its forms surface.

---

## Governing principles

Five rules every syntactic decision below honors:

1. **Layout is projection, never contract.** The shape of the code on the page IS the computation graph — because the formatter *projects* the graph onto the page in canonical form, not because the parser reads meaning from whitespace. This is *forced* by the kernel, not chosen: a contract would make whitespace a SECOND writer into the graph, but the kernel has exactly one writer (inference) — one graph, two operations, there is no third — so layout is necessarily a READ of the already-written graph, and `mentl fmt` is that read at the surface. The parser has ONE precedence table; wrong layout is normalized at save by `mentl fmt`, never a parse error.

2. **No redundant form.** If two syntactic forms produce the same graph, one is rejected. The medium refuses ceremony the substrate doesn't require.

3. **No syntactic ambiguity.** Every token sequence parses to exactly one AST under the rules below. Ambiguity in a language is debt the user pays; Mentl pays its own debt at design time.

4. **Every construct has graph correspondence.** No syntax exists without a substrate operation it produces. If a form has no graph meaning, it doesn't exist.

5. **Diagnostics carry coordinates and Quick Fixes.** Every rejection produces a Located reason chain and (where mechanically apparent) a MachineApplicable patch. Errors are teaching surfaces, not punishment.

---

## Function declarations

### Canonical form — single-line expression body

```
fn name(p1, p2) -> RetTy with E1 + E2 = expr
```

When the body fits on one line after `=`, no braces are required.

```
fn double(x) = x * 2
fn add(a, b) with Pure = a + b
fn parse(path: ValidPath) = path |> read_file |> decode
```

### Canonical form — block body requires braces

**Rule:** braces are required exactly when the body introduces `let`-bindings or
statements — i.e. when it IS a `BlockExpr`. The braces ARE the `BlockExpr` literal
(a scope sequencing statements before a final expression); they are NOT keyed on
line count. A single expression — even a multi-line `if`/`match`/pipe chain — needs
no braces; `mentl fmt` projects fold-points and indentation as layout, never as a
parse contract (Governing Principle 1: layout is never semantics).

```
fn chase_node(ref nodes, handle, depth) with !Mutate =
  if depth > 100 {
    GNode(NErrorHole(Inferred("depth exceeded")), Fresh(handle))
  } else {
    let GNode(kind, reason) = graph_node_at(nodes, handle)
    match kind {
      NBound(ty) => ...,
      _          => GNode(kind, reason),
    }
  }

fn process(input: [Float]) -> Result with !Alloc = {
  let validated = input |> validate      // let-bindings ⇒ a BlockExpr ⇒ braces
  let normalized = validated |> normalize
  normalized |> fft |> extract
}
```

`chase_node`'s body is one multi-line `if`/`match` expression — **no braces** (not
a `BlockExpr`). `process` introduces `let`-bindings — **braces required**, enclosing
a `BlockExpr(stmts, final_expr)`. The sole question is "does this body introduce
bindings/statements?", read live from the graph — never "how many lines."

### The Intent Boundary Rule for Parameters

Mentl uses Hindley-Milner type inference. **You do not need to annotate base types** like `Int`, `String`, or structural records on parameters. 

**Rule:** Parameter type annotations are strictly reserved for **Intent Boundaries**. Use them to explicitly declare:
1. **Refinement Types** (e.g., `pos: ValidOffset`, `span: ValidSpan`) which encode predicates that `Verify` must discharge.
2. **Ownership Markers** (e.g., `ast: own Node`, `env: ref Env`) which enforce linearity and aliasing.
3. **Representation Pins** (e.g., `s: f32`, `coeff: f64`) which PIN a width the gradient would otherwise infer — the representation peer of the ownership marker (§"Type aliases", representation-pinned alias). `s: f32` is the bare-width form of `s: Float repr f32`.

Do not write `fn name(a: Int)` when the graph can infer it. Do write `fn name(pos: ValidOffset)` to erect a graph-backed semantic contract — and `fn name(s: f32)` only when a narrower-than-inferred width is the control decision.

### Redundant braces — braces wrapping a non-BlockExpr

```
// braces around a body with no statements (a bare expression):
fn parse(path: Path) -> Config = { path |> read_file |> decode }
```

Diagnostic: **`E_RedundantBraces`** (format-liftable — the formatter strips the
braces; the user sees no error). Trigger: braces enclose a body that introduces no
`let`-bindings/statements (not a `BlockExpr`), regardless of line count.

Quick Fix: remove the `{` and `}`.

### Missing braces — statements written without a block

```
// a body that introduces let-bindings but omits the braces:
fn process(input) =
  let validated = input |> validate
  validated |> fft |> extract
```

Diagnostic: **`E_BlockNeedsBraces`** (format-liftable — the formatter wraps the
statements in `{ }`; the user sees no error). Trigger: a body containing
`let`-bindings/statements (a `BlockExpr`) written without its braces — NOT keyed on
line count. The earlier `chase_node` (a single multi-line `if` expression) needs no
braces precisely because it introduces no statements.

Quick Fix: wrap the statement sequence in `{ ... }`.

### Generic type parameters

```
fn map(f: a -> b, xs: [a]) -> [b] =
  ...
```

**The case rule IS the declaration**: lowercase identifiers in type
position can only be type parameters (nominal types are capitalized),
so there is no declaration list to write or keep in sync. Inferred at
call sites. **No turbofish. No angle brackets — anywhere.** Call:
```
map(double, [1, 2, 3])   // correct — A=Int, B=Int inferred
```

```
// REJECTED:
map<Int, Int>(double, [1, 2, 3])
```
There is **no bespoke turbofish recognizer** — a per-foreign-form scanner does not scale, and the parser has ONE precedence table. `map<Int, Int>(...)` parses as the comparison chain `<` draws (`map < Int`, `Int > (...)`), and the **general** unexpected-token / type-mismatch diagnostic teaches in context (a `TBool` where a callable was expected, with a Located Reason and a Quick Fix to the paren-free `map(double, [1,2,3])`). The retirement of angle-bracket parameter lists in ANY declaration position (`type Box<A>`, `fn f<T>`, `effect E<S>`) is carried by the case rule; the teaching is the one general diagnostic path, never a Rust-specific lookahead.

### With-clauses for effects

```
fn fetch(url: String) with IO + Network =
  ...
```

Multiple effects join with `+`. Negation: `!E`. Parameterized: `E(arg)`. Combinations:
```
fn audio_stage(samples) with Sample(44100) + !Alloc + IO =
  ...
```

`Pure` is the identity element of `+`. Writing `with Pure` is allowed (and an explicit purity declaration); `with Pure + IO` simplifies to `with IO`.

**`with` is one keyword, not three.** It reads identically everywhere it appears — *"this construct is accompanied by / carries X"* — and the three surfaces are one concept, not overload: a function carries effects (`fn f() with E`); a handler carries state (`handler h with s = init`); a resume carries a state update (`resume(v) with s = s + 1`). The grammar disambiguates by position (a row after a signature, or `name = init` bindings after a handler/resume); the meaning is constant. (Handler *installation* is not a `with`-surface — it is the `~>` verb.)

### Return type omission

```
fn id(x: A) = x   // return type inferred
```

The `-> RetTy` clause is optional; absent = inferred. Most user code does NOT annotate return types. Mentl's gradient may suggest annotating when capabilities depend on the return type being explicit.

### Default parameter values

Trailing parameters may have default values. Call sites may omit them or override via labeled args.

```
fn compress(x: Sample, ratio: Float = 4.0, threshold: Float = -12.0) -> Sample = ...

compress(sample)                                    // ratio and threshold defaulted
compress(sample, 8.0)                               // ratio overridden; threshold defaulted
compress(sample, threshold = -6.0)                  // label to skip over ratio
compress(sample, ratio = 2.0, threshold = -18.0)   // fully labeled
```

A default **desugars once at the declaration** to a callee-scoped fill: when a call-site argument edge is absent, the parameter is filled by projecting the default's node, evaluated in the **callee's** parameter scope — where earlier parameters are in scope as a sequential binding chain (the same letrec scope nested fns use), never the caller's context. The default has one home (the signature node) and one evaluation context (the callee); the call site only omits an edge. A defaulted slot leaves a `DefaultReason(param, decl_site)` edge — `mentl why` at the slot walks to the declaration ("`ratio` defaulted to `4.0` from `compress` — annotate to pin").

### Labeled call arguments

Any call may use `name = value` for trailing positional arguments. Positional-before-labeled order:

```
fn spawn_task(priority: Int, ref config: Config, timeout_ms: Int = 1000) -> Handle = ...

spawn_task(5, config)                                            // positional only
spawn_task(5, config, timeout_ms = 5000)                        // positional + labeled override
spawn_task(priority = 5, config = current, timeout_ms = 5000)   // all labeled
```

**Defaults and labeled args are not two features — they are the parameter list AS a product node-kind.** A parameter list is a positional product (`PLAN.md §2`, L1); like every product it may be constructed positionally (`f(a, b)`), by field (`f(x = a, y = b)`), or mixed (`f(a, y = b)`) — the identical machinery as record literals `{a, b}` / `{x: a, y: b}` (punning + field-naming), and a default is a product field's fallback construction (the identical machinery as a record-field default). There is no second call-site feature; the product node-kind mandates all four forms. Labels resolve against the declared parameter names; an unknown label is `E_UnknownArgLabel`. (Under threading/multi-shot a labeled call is order-independent at the product level — the cursor may fill fields in any order.)

**Identity, not position — the field's NAME is the key; the order is a projection.** A parameter product is not the position-keyed disease (`CLAUDE.md` drift-8, evidence-by-row-slot, `mode == 0/1/2`, parallel arrays): those use position as a *fragile proxy* for an identity. A product's fields *have* identity — their names — exactly as record fields do (sorted by name at parse, source order irrelevant). `spawn_task(priority = 5, config = c)` resolves by name; the positional `spawn_task(5, c)` is a *convenience* that fills fields in declaration order and resolves immediately *to* the names. Position is a deterministic layout over an identity-keyed set, never the key itself.

### Partial application — the product with a hole

A parameter product may be constructed with a **hole** — a field left unsupplied. The result is not an error; it is a **value**: the function *awaiting* that field. This is partial application, and it is not a distinct feature — it is the product node-kind constructed with one field absent.

```
let adults = filter({ p => p.age > 18 })   // xs is a hole → adults : [Person] -> [Person]
adults(users)                              // fill the hole → the filtered list
adults(new_signups)                        // reuse — a hole-product is a first-class value
```

*(This section's headline example was `filter(.age > 18)` until 2026-09-20, and the bare `.field` accessor it spelled **does not parse and never did** — measured: `P_UnexpectedToken` at the `.`, then `E_MissingVariable: age`. Nothing in the tree used it, nothing implemented it, and the spec was teaching it as the canonical form in three places. It is struck rather than built, because a field is not a declaration, so `.name` would be a THIRD way to reach a function value beside reference and mint — the one thing §«Function literals» says there is not. `Hβ.syntax.field-accessor-documented-never-built` closes by this deletion.)*

**The hole is keyed by IDENTITY, never by position.** `filter({ p => p.age > 18 })` leaves *the parameter `xs`* unfilled — "the parameter `xs`," not "slot 2." When exactly one field is a hole, it is unambiguous. When several are, the hole is named explicitly with `??` at the field it marks:

```
between(??, 100)      // the FIRST field is the hole: (x) => between(x, 100)
clamp(0, ??, 255)     // the MIDDLE field is the hole: (x) => clamp(0, x, 255)
```

`??` is the same absence marker as the gradient's hole (§«Token enumeration», `THole`): a field the cursor reads as *unsupplied*. What fills it depends on context — Synth proposes a candidate, a call supplies a value, the `|>` pipe supplies the flowing datum, a resumption supplies it later — but the marker is one, and it names *which* field, never a slot.

**The `|>` pipe is hole-completion, not a rewrite.** `x |> f(a)` fills `f(a)`'s remaining hole with `x`:

```
users |> filter({ p => p.age > 18 })              // fills xs → equals filter({ … }, users)
users |> filter({ p => p.age > 18 }) |> map({ p => p.name }) |> sort
```

The pipe's type rule (§«`|>` — converge») requires `right : A -> B` — a product with exactly one hole — and a partial application *is* exactly that. So the pipe is not a syntactic append; it is the product's one remaining hole filled by the piped value. This is why the five verbs compose: every stage is a product pre-filled with its configuration, its data field a hole the pipe completes. A stage with more than one hole must name the pipe's target with `??` (`x |> clamp(0, ??, 255)`); a stage with none is a complete value and `E_PipeIntoComplete` teaches the missing hole.

**One primitive, five surfaces.** Positional construction, field/labeled construction, defaults, the hole (partial application), and pipe-completion are ONE thing — the parameter-list product constructed by identity with any subset of fields supplied, defaulted, or left as holes. There is no currying mechanism distinct from the product: a "curried function" is a product-with-holes, and the arity is never fuzzy, because the holes are named fields, not a hidden nesting of one-argument functions.

**The product is the judgment's, written once at the call** (real, 2026-09-30). Labels resolve, defaults fill and holes are typed against the parameters the CALLEE NODE carries — a let-bound closure's own parameter names, a parameter's own arity, a field's own type — never against a module function that happens to share the name, and the lowering reads that product off the call node instead of resolving it again. Until then the lowering resolved every call a second time, by name in the module env: `g(b = 1, a = 5)` on a let-bound `g` ran as `g(1, 5)` (exit 252 for 4, zero diagnostics); `fn run(f) = f(7)` beside a top-level `f(a, b = 100)` spliced the module's default into the callback's call and trapped at the indirect call; the prelude's `fold_handler` arm `f(acc, elem)` was refused with an arity mismatch inside the library the moment a program declared a one-parameter `f`; and a partial over a local — `let inc = add(1)` on a let-bound `add` — called a top-level `add` of the same name, or floored where there was none. A partial over a local callee carries the callee's value in its record beside the supplied fields, and every open slot of a partial is typed by its own cell, so `fadd(1.5)` over a Float pair assembles where it did not (`Hβ.lower.callee-resolved-by-name-in-the-module-env`, closed).

**The hole is the suspension point — SPACE and TIME are one.** A hole-product is a computation *suspended at its argument*; filling the hole *resumes* it. On the SPACE axis this is partial application — the field filled by a value, or by the pipe's flowing datum. On the TIME axis it is the multi-shot continuation (`PLAN.md §4④`): a `??` hole reified as a resumable record is a continuation awaiting its argument, fillable now, later, or many times. Partial application and continuation-resumption are the same operation — hole-filling keyed by identity — distinguished only by whether the hole is filled at the call site or captured and resumed. `??` is one absence marker across the whole medium: the gradient's synth-hole, the argument hole, and the continuation's resume-slot are the cursor reading *the same absence* at three altitudes.

**A hole is productive, never executable.** A bare value-position `??` (no
parameter product to suspend into) admits check/edit projection — the graph
types it, the cursor proposes into it — but it is NOT an executable value:
compiling an executable whose reachable emitted tree still carries an
authored value-position hole is a REFUSAL (`E_UnresolvedHole` at the
authored span, nonzero exit, zero WAT bytes — the gate runs between
reachability and emit, so a hole in pruned dead code never over-refuses).
A `??` inside a parameter product stays executable — it is the suspension
awaiting its field (`add3(10, ??, 30)` is a value that runs). Proof debt is
the OTHER law: an executable with undischarged `V_Pending` obligations
SURFACES them (one ledger projection on stderr) and compiles — the
sound-incomplete choice (`PLAN.md §0`): undecidable residue accrues
visibly, never assume-true, and never a blanket refusal, because the
wheel's own self-compile carries structurally undecidable obligations and
refusing on pending would refuse the medium itself. Decidable-FALSE still
refuses at the claim site (`E_RefinementRejected`).
tools/proof-exactness-gate.sh is the executable contract for all three
legs (hole refuses / debt surfaces / suspension runs), green through the
pinned boot.

### The Stage Law — signatures serve the pipe

A consequence of hole-completion, elevated to the signature convention: **a
stage-shaped fn (any fn meant to stand in a `|>` chain) declares its
CONFIGURATION parameters first and the flowing DATUM last.** Declaration-order
fill then completes every stage with zero ceremony:

```
xs |> map(f) |> filter(p) |> take(3) |> fold(0, add)
```

No `??`, no wrapper lambdas, no argument gymnastics — the page reads as the
graph. Under this law a `??` inside a pipe becomes a SIGNAL, never noise:
either the callee is genuinely not a stage (the `??` says so, explicitly —
`nodes |> list_set(??, i, v)` pipes into a substrate fn whose subject is not
a chain datum), or the signature violates the law — and the fix is the
SIGNATURE, never decoration at N call sites. The standard vocabulary obeys
it: `map(f, xs)` · `filter(p, xs)` · `each(f, xs)` · `fold(init, f, xs)` ·
`take(n, xs)` · `drop(n, xs)` · `any/all/find/count(p, xs)`.

### Vocabulary — names are read as intent, never as ceremony

The developer writes what they mean, not what a computer wants to see; a
name that adds machinery-gloss over the topology is drift — and a name that
needs a decoder-ring comment to read is this ruling violated at the source
(the comment is then a confession twice over: of the name, and of the
projection; see §«What a comment TRENDS TO»). Three rulings:

- **A banished keyword never returns as a name.** Mentl removed `for`; a fn
  named `for_each` carried the loop back into the reader's mouth — worse,
  the `E_NotAKeyword` Quick Fix was teaching people OUT of `for` by handing
  them `for`. The iteration-for-effect stage is **`each`** (`xs |> each(f)` —
  read it aloud); its handler was named `each_handler` all along, the
  substrate already carrying the true name.
- **Execution strategy never lives in a name.** HOW a stage runs is a `~>`
  handler fact (`>< [Thread ×4]` is a derived badge, §`><`), so
  `parallel_map` was vocabulary drift over `map ~> Schedule` — DISSOLVED
  2026-07-02 (`Hβ.prelude.parallel-map-dissolves-into-schedule`). The blocker
  was never map's fanout substrate landing (that landed at PLAN §5.U STEP 4);
  it was that a standalone helper can never reach `Thread` scheduling at all:
  the schedule is read LIVE at the fanout's own install site (§`><` — the
  same `resolve_in_stack` every op uses), never across a call boundary, so a
  `><` inside a reusable fn read `Seq` whatever its caller installed. The
  schedule reaches it now — by DEMAND, through a direct call (real,
  2026-09-30, §`><`): a `~> parallel_compose` over `render(voices)` runs
  every `><` and `fanout` in `render`'s direct-call reach threaded, while
  `map` stays sequential by construction (one loop) and `fanout(f, xs)` is
  the sequence fanout that declares its applications independent. The
  parallel map is spelled `fanout(f, xs) ~> parallel_compose`.
- **A name must not lie about the representation.** `list_head`/`list_tail`
  read and remove the LAST element (the snoc end — O(1) by construction);
  the borrowed cons-vocabulary asserts the opposite and has already billed
  the project one real bug (the env-orientation truncation). The true names
  are **`last`** and **`drop_last`** (symmetric with `take`/`drop`); the
  sweep is EXECUTED across all layers (283 sites): the primitives are
  `last`/`drop_last`; prelude's drop-first is **`rest`**, the pattern
  surface's own word (`[head, ...rest]`), and `tail` is no name at all.
  One home per truth: the positional `last` duplicate dissolved into the
  O(1) representation read.

### Nested function declarations

`fn` declarations may appear inside another function's body. Nested fns are local to the enclosing body's scope.

```
fn check_exhaustive(patterns) = {
  fn covers_all(pats, variants) = {
    // inner helper; visible only inside check_exhaustive
    all_match(variants, (v) => any_match(pats, (p) => matches(v, p)))
  }
  covers_all(patterns, known_variants())
}
```

A nested `fn name(params) = body` is a declaration scoped to its block, and consecutive `fn` declarations in a block form one RUN — a local letrec scope: every name of the run is in scope in every body of the run and in everything after it, so siblings call each other in either direction. The run is judged as the module's declarations are, callee-first by binding group with each cycle judged as one unit, so every member is generalized — one nested `fn ident(x) = x` serves an Int and a String even where its caller is declared above it. Any other statement between two `fn` declarations ends the run: a later fn may capture what that statement computes, which does not exist while an earlier fn can already be called, so in `fn first() = second() + 1; let k = 2; fn second() = k` the name `second` is out of scope at `first`'s call (`E_MissingVariable`). Two declarations of one name in one run refuse (`E_DuplicateFnName`), as two at module level do, and a fn in a later run shadows one of its name in an earlier run for what follows it (real, 2026-10-03; until then a nested fn's name was in scope only in its own body and after its declaration, so a sibling calling one declared below it was refused). A block-scope `let name = (params) => body` is a closure VALUE, and the two differ in exactly that: the `let` binds after its value, so its name is not in scope in its own body, it is not generalized, and it may shadow — `let f = (x) => f(x) * 10` calls the `f` bound before it.

**A nested fn is MINTED where it is declared** (real, 2026-09-30). Its closure record — its captures, or an empty record with none — is built when the block reaches its run, every record of the run allocated and bound before any is filled, so a record that holds a sibling declared after it, or itself, holds the sibling's record. The declaring frame pays `Memory + Alloc` once per nested fn, exactly as it pays for a lambda it mints (§«Function literals»): `fn adder(k) with !Alloc = { fn add(x) = x + k; add }` refuses. Until this landed the judgment never charged it, and every maker in lib/dsp returning its nested stage carried a row of `Pure`. A nested fn that captures nothing could be the module's static record and cost nothing; the charge follows that representation the day the lowering builds it (`Hβ.lower.captureless-nested-fn-is-static`).

**A binder shadows its name for its own scope and no further.** A `let` in a block, a pattern in a match arm, a pipe stage's parameter, a recurrence's prior and a binding inside the recurrence body each hide the same name while their scope is open, and the hidden binding is read again, unchanged, once it closes: `fn f(x) = { let y = { let x = 5; x + 1 }; x + y }` answers `f(100) = 106`. Two binders of one name are two values at their own widths, never one storage place (real, 2026-09-28: until then an arm's `Some(x)` or a block's `let x` wrote the parameter's register, and that program answered 11 with zero diagnostics — `Hβ.lower.shadowing-binder-clobbers-its-register`).

**At module scope there is nothing to shadow, and a `let` bound to a function literal IS the declaration** (real, 2026-09-28): `let inc = (x) => x + 1` is born as `fn inc(x) = x + 1` at parse — recursive, generalized, emitted as the symbol its callers call directly — and `mentl fmt` writes it as `fn`. An arm-list literal bound at module scope, `let pick = { Some(v) => v, None => 0 }`, is a declaration too and keeps its spelling, because its one parameter is minted by the literal and never reaches the page. An annotated module let keeps its annotation's constraint and stays a value, and a module value holding a closure (`let add3 = make_adder(3)`) is called through that closure. Until this landed the let was judged a value and lowered as a lambda named for its handle while its callers called `$inc`, a symbol nothing emitted: `mentl check` was clean and the module did not assemble (`Hβ.lower.module-scope-has-no-frame`).

---

## Function literals — the arm list

Surfaces primitives **#2** (pattern dispatch, the handler's own shape) and **#8** (HM inference: a literal's parameter type is inferred from the arms).

**A function value is reached by exactly TWO operations, because the kernel has exactly two** (`PLAN.md §2` — draw an edge, project):

1. **REFERENCE** an existing function, with the fields it is not yet given left as holes — `f`, `f(cfg)`, `f(a, ??, c)` (§«Partial application — the product with a hole»). An edge to a node that exists.
2. **MINT** a new one, with an **ARM LIST** — `{ pattern => body, … }`.

**What each costs is in the row of the frame that forms it** (real, 2026-09-28). A bare reference to a top-level function reaches its static record and costs nothing. A reference with fields supplied (a partial) and a mint each build a closure record — its captures, its supplied fields — so each charges `Memory + Alloc` where it is formed, and `with !Alloc` refuses it. The exception is structural, not a discount: where a verb APPLIES the literal in place — the stage of a `|>`, the recurrence of a `<~` — nothing is minted, so nothing is charged (§«`|>` — converge»). Calling a closure charges the closure's own row, which rides its type, and never the cost of having made it.

### Canonical form

```
{ pattern => body, ... }
```

The braces ARE the literal; there is no head, because there is nothing for a head to say that the patterns do not. Arms separate with commas, trailing comma allowed, exactly as `match`'s arms do — they are parsed by the same function, because they are the same thing.

```
xs |> map({ Some(v) => v, None => 0 })
weights |> filter({ (name, w) => w > 0 })
{ Leaf => 3, Node(n) => n * 2, _ => 7 }
```

**`match` is the arm list APPLIED.** `match scrut { arms }` and `{ arms }(scrut)` are the same graph and the same value — one form names its argument at the site, the other leaves it to the caller. This is why the medium needs no separate lambda: pattern dispatch was always the mint, and a binder wrapping it was the wrapper.

**The literal takes exactly ONE parameter** — the value its arms match. Several arguments are a product the arms destructure (`{ (a, b) => a + b }` takes a pair), which is the parameter-list-as-product rule (§«Labeled call arguments») read at the literal.

**And a pair is ONE argument, at every altitude.** A call's argument count is its callee's parameter count: `{ (a, b) => a + b }` is called as `f((1, 2))`, never `f(1, 2)`, and it is not a two-argument callback — `fold(0, { (acc, x) => … }, xs)` is refused, because `fold` calls its stage with two arguments; the binder form `(acc, x) => …` or a reference is the two-parameter value. Until 2026-09-27 the type layer decomposed a single tuple parameter against N parameters ("parameters ARE tuples") while the emit did not, so `(1, 2) |> add` checked clean and trapped at the indirect call; the rule is gone and the shapes refuse (`E_TypeMismatch`, its arity face). The calling convention that would make the two one value is `Hβ.lower.parameter-product-calling-convention`.

**A brace opens a literal when a PATTERN ends at a `=>`.** That question is answered by a bounded token scan, never by parsing a pattern speculatively and never by layout: one pattern atom — an ident (optionally applied), a literal, or a balanced group — joined to further atoms only by `@` or `|`. Two adjacent atoms are never a pattern, so `{ setup()` newline `(x) => run(x) }` is the block it looks like. Record literal and block discrimination are unchanged and follow (§«Records», §«Function declarations»).

### The residue — `(params) => body`

The binder form still parses, and it is the last of the line that retired `perform`, `handle`, `capability`, the turbofish and `|x|`. `mentl fmt` no longer writes it wherever the arm list expresses the same graph — a sole-parameter lambda, including the param-position destructure `((a, b)) => e`, renders as its arms — so what survives on the page is the honest remainder:

- **multi-parameter** (`(a, b) => a * b`) — the arm list is one-parameter, so these retire by becoming REFERENCES (`fold(0, add, xs)`), which is rule 1 and needs no new form. `Hβ.syntax.multi-param-lambda-is-a-reference`.
- **the zero-argument thunk** (`() => e`) — retires into a named handler chain rather than into a literal. `Hβ.syntax.handler-chain-is-a-value`.

Both are named in positive form with their measured counts in `RESIDUE.md`; neither is a second minting form, and no third is being held open.

### Examples

**Zero arguments:**
```
() => 42
() => { let x = compute(); x + 1 }
```

**Single argument — the arm list, the canonical form:**
```
{ x => x + 1 }
{ _ => 42 }                                // argument ignored (PWild pattern)
```

**Multiple arguments** (the residue above — a reference is the ultimate form):
```
(a, b) => a * b
(a, _) => a            // second ignored
(_, _) => 0            // all ignored
```

**Destructuring — an ordinary arm pattern, with no param position to nest in:**
```
{ {name, age} => greet(name) }             // record destructure
{ (a, b) => a + b }                        // tuple destructure
{ [h, ...t] => process(h, t) }             // list destructure
```

**Block body:**
```
(input) => {
  let cleaned = input |> clean
  cleaned |> transform
}
```

### Rule — braces are the BlockExpr literal

- **A single expression body** (even multi-line) needs no braces: `(x) => x + 1`, `(x) => if c { a } else { b }`.
- **A body that introduces `let`-bindings/statements (a `BlockExpr`)** requires braces: `(x) => { let y = setup(x); y + 1 }`.

Identical to named-fn bodies (§"Function declarations"): the brace requirement keys on "is this a `BlockExpr`?", never on line count.

### Inline higher-order use

```
map({ x => x + 1 }, xs)
filter({ x => x > 0 }, xs)
fold(0, (acc, x) => acc + x, xs)           // two parameters — a reference is the ultimate form
zip_with((a, b) => a * b, xs, ys)          // likewise
```

### Returned closures

```
fn compose(f, g) = (x) => g(f(x))
fn id(x) with Pure = x
```

### Match arms ARE the literal — the sentence that became a mechanism

This section used to read: *"Match arms are `pattern => body`. **Match arms ARE pattern-dispatched lambdas** — same separator, same body discipline. The syntactic unity reflects semantic unity."* That was a remark about RESEMBLANCE, and the medium's own census priced it: **197 of 515 lambda sites (38%) were `(x) => match x { … }`**, with 57 more a single tuple pattern in param position — half the corpus paying a wrapper to reach a form the language already had, and this document conceding the point in prose while the parser charged for it.

It is a mechanism now: an arm list IS a function, `match` is that function applied, and one `parse_match_arms` serves both. The unity is not reflected; it is the same node.

### Rejected forms

```
// REJECTED — pipe-fence form (superseded by `()` unification):
|x| x + 1
|acc, x| acc + x
```

Diagnostic: **`E_LambdaFence`** with Quick Fix rewriting `|params| body` → `(params) => body`.

```
// REJECTED — `fn` keyword on anonymous lambda:
fn (x) => x + 1
```

Diagnostic: **`E_RedundantFnOnLambda`** — `fn` is reserved for named declarations. Remove `fn` for anonymous forms.

```
// REJECTED — zero-arg via `||`:
|| expr
```

Diagnostic: **`E_LambdaAsOrOr`** — `||` is logical OR (TOrOr). Use `() => expr` for zero-arg lambdas. Quick Fix: replace `||` with `() =>`.

---

## Pipe verbs — the five-verb topology

Mentl has FIVE pipe verbs. Each draws a specific shape on the page; the layout IS the topology.

### `|>` — converge

Sequential data flow. Right-applied to left.

```
input
  |> stage_a
  |> stage_b
  |> output
```

**Layout:** `|>` sits at the LEFT EDGE. Each stage on its own indented line.

Single line acceptable for short chains:
```
x |> double |> square
```

**Type rule:** if `left: A` and `right: A -> B with E`, then `left |> right: B with E`. The chain's row unions all stage rows.

**A stage is APPLIED, never minted.** A call standing as a stage is completed in place (its hole filled by the piped value), and a function literal standing as a stage — `x |> (v) => v * 2`, `x |> { 0 => 1, n => n - 1 }` — is the piped value bound to its parameter, its body lowered in the frame the pipe stands in. Neither builds a closure, so neither costs the frame anything, and a stage-shaped chain inside a `with !Alloc` function stays allocation-free (real, 2026-09-28; before, each literal stage minted a closure per call under the same `!Alloc`). The parameter is a binder of that frame like any other: it may share a name with a local there, and the local reads its own value again once the stage closes.

**Applying a stage owes what the stage demands.** The piped value fills the stage's parameter exactly as a call's argument fills it, so the parameter's refinement is claimed of the value at the pipe and the row its precondition guards is paid there when the claim is open: `30000.0 |> alpha` over `alpha(c: Hz)` refuses as `alpha(30000.0)` does, and a partial stage owes the contract of the slot it leaves open (real, 2026-10-01; the pipe raised no claim before, §«Refinement types»).

### `<|` — diverge (fanout)

One input, multiple branches, output is a tuple of branch outputs. **Input is BORROWED into each branch** — a value cannot escape the branch tuple.

```
input
  <| (
    branch_a,
    branch_b,
    branch_c,
  )
```

Or equivalently with stage chains in branches:
```
input
  <| (
    (x) => x |> stage_a1 |> stage_a2,
    (x) => x |> stage_b1,
    extract_c,
  )
```

**Layout:** `<|` sits at the LEFT EDGE before the branch tuple. The branch tuple's `(` opens on the same line as `<|`; branches are on indented lines; the closing `)` returns to the indent of the opening branch.

**Type rule:** if `input: T` and branches are `(T -> A, T -> B, T -> C)`, the result is `(A, B, C)`. Row is union of all branch rows + upstream row.

**Ownership:** input is shared (borrowed, `ref` / `!Mutate`) across all N branches
(use-count N → borrowed) — and this ownership *is* the discriminator. `own` values
cannot flow through `<|` (`E_OwnershipViolation` — a coherent authored glyph the
formatter never silently rewrites; it teaches the violation); a branch that must
consume its input independently is `><`, the own-consuming surface of the *same*
parallel-fanout topology (see §`><`). The read-only borrow is what makes
execution-as-a-handler PROVABLY race-free: a shared value borrowed read-only is
safe across threads.

### `><` — parallel compose (structural N-ary)

**Two or more INDEPENDENT pipelines run in parallel.** Each branch has its own input. Outputs are tupled.

**`<|` and `><` are two surfaces of ONE parallel-fanout topology, discriminated by
input OWNERSHIP (arm 5)** — not two different shapes. `<|` ref-borrows ONE shared
input across N branches (use-count N → borrowed); `><` own-consumes N independent
inputs (each use-count 1 → consumed). Both fan out and tuple the results; the
share-vs-distribute reading is inferred from the branch input use-count (the same
inference that drives `own`/`ref`). Two glyphs, one topology read through
ownership — never two topological primitives.

**THE KERNEL MERGES THEM TO ONE NODE.** At the substrate there is one `PFanout`
node carrying an arity + an ownership aspect — the duplicate `PDiverge`/`PCompose`
nodes and their parallel infer/lower paths collapse into it (Carried-Truth: the
share-vs-distribute fact is read from use-count, never re-derived as a second node
kind). **The surface keeps BOTH glyphs authored** as intent, with ownership
CHECKING coherence, never silently overwriting: an `own` value through `<|` is
`E_OwnershipViolation` (teach the violation); a genuinely-shared input under `><`
fmt-canonicalizes to `<|` (the formatter fixes *incoherent* source) — but a
coherent authored glyph is never silently rewritten. The author writes the shape
they mean; ownership keeps it honest.

**Independence is the topology; concurrent EXECUTION is a `~>` handler choice.**
`><` declares the branches independent; whether they run sequential / threaded /
SIMD-lane-packed / on a device is decided by a `Schedule` handler installed in the
enclosing `~>` chain — `type Strategy = Seq | Thread | Simd | Gpu` (an ADT, never
a `mode == 0/1/2` int). The verb stays PURE TOPOLOGY in what it performs — it
contributes no effect of its own to the row, and the schedule is not in it; the
cursor reads the strategy from the live handler stack (the same `resolve_in_stack`
every `perform` uses), exactly as persistence is a handler swap (`PLAN.md §4④`).
What the verb COSTS is in the row: a fanout builds the tuple of its results (and
`><` a thunk per branch), so both glyphs charge `Memory + Alloc` in the frame
they stand in, and `with !Alloc` refuses `(x + 1) >< (x + 2)` (real, 2026-09-28;
the row said nothing of it before, at 56 bytes per call).
**No `Schedule` installed → `Seq`** — inline-eval in source order, deterministic
and debuggable, the invisible default. `~> Thread` runs the branches on parallel
threads; `~> Simd` cashes a `[f32; 4]` branch tuple to a v128 lane (the
representation gradient and the topology axis composing in ONE read). Because `<|`
borrows read-only and `><` shares nothing, the schedule is PROVABLY race-free; a
real-time region can declare `with !Thread` and the medium PROVES, transitively,
that no spawn occurs (provable like `!Alloc` — Rayon/Faust cannot state this).
`mentl where` badges the chosen strategy: `>< [Thread ×4]`, output not input —
each site in the glyph its author wrote with the branches it spawns (`<| [Seq
×2]`; a sequence fanout as `fanout [Thread, a branch per element]`), and a
site whose frame installs no schedule names the callers that demand it (real,
2026-10-02).

**The race-freedom claim has its gate (real, 2026-09-27).** A spawned branch
runs in the world it was spawned in — the task record carries the install
chain of the PERFORM that spawned it and the fresh instance installs it before
the branch runs — so an effect a branch performs reaches the handler installed
at the fanout's frame, from a second instance, and the schedule's own ops
answer there too: `current_id()` inside a branch reaches the
`parallel_compose` that started it (real 2026-09-30; until then the record
carried the spawn arm's world, which by the deep-handler law excluded the
schedule itself, and the branch faulted at the chain's end). `E_ThreadedBranchEffect` (armed)
refuses at lowering any effect in a branch's row whose covering handler at
that frame is STATEFUL (two instances resuming `with n = n + 1` on one state
record), lies beyond the frame fence with no caller's schedule demanding the
fanout (a caller's install is provable only along a demand, below), or is stateless but
performs, from an arm, into a stateful one further out (an arm runs in the
spawned instance and its performs resolve outer, so the walk follows each
handler's own residual row down the stack). The fix is stated in the refusal:
install a stateless handler at the fanout's frame, or install the handler
inside the branch, where each instance gets its own state record. The rule
reads WRITES, not declarations: a handler is stateful when an arm carries a
`resume … with` update (the one writer this document gives state), so a
state that is only read is shared read-only across instances and runs.

**The schedule reaches a callee's fanout by DEMAND (real, 2026-09-30).** A
fanout's own frame's install wins; a fanout whose frame installs no schedule
runs under the schedule a CALLER installs over a direct call to it, and so
does every fanout in that callee's direct-call reach: `fn both() = (a()) ><
(b())` under `(both()) ~> parallel_compose` spawns both branches, and the
callee is emitted as a schedule TWIN keyed by the install's schedule beside
its instantiation — the proof becomes the dispatch, as a twin is keyed by
what its body reads. Two things bound the reach, each a decision the row
reads. A callee declared `!Thread` keeps its own frame's schedule: the
negation is what the demand reads, so a real-time region's fanouts stay
sequential under any caller. And the demand crosses DIRECT calls only: a
function value minted under the schedule — a lambda, a partial, a nested fn —
keeps its own frame's schedule, because a value can outlive the install and a
spawn it carried out would find no handler on the chain
(`Hβ.lower.schedule-through-a-value`); a branch thunk, an install's arm and
a state init never leave the extent and take the schedule. The race rule is
read along the same demand: each demanded fanout's branch rows are checked
against the installs between it and the demanding site, and a branch whose
row is a callback PARAMETER's is read at the instantiating site — `fn
tally(f) = (f()) >< (f())` called with a callback that bumps a stateful
counter refuses, where the lexical rule saw a free row. Until this landed the
frame fence made a callee's fanout `Seq` whatever its caller installed, and
no reusable helper could fan out.

**`fanout(f, xs)` is the SEQUENCE fanout** — `><` over a runtime sequence: `f`
applied to each element as an independent branch, the results collected in
order, under whatever schedule governs the site. It is typed exactly as `map`
is and, with no schedule installed, IS `map`; under a Thread-class install
every element's branch is spawned and joined in source order
(`fanout_threaded`, lib/threading), under a Persist-class install
checkpointed and joined (`fanout_persisted`, lib/persist). `map` itself stays
a sequential loop by construction (§Vocabulary): only a fanout declares its
applications independent, which is the whole difference between them.
Simd and Gpu pack a fixed lane count and run a sequence fanout sequentially.
The ??-fan is written this way (`segment_verify`, src/synth_proposer.mn):
the candidates fan through their judgment under the schedule of the propose
site — none installed, sequential by property — and a `~> parallel_compose`
over it is refused by the race rule, each branch writing the one graph
through a stateful handler, which is 9.2's deterministic partition stated as
a gate.

**`><` is a structural N-ary construct the formatter renders in one of two layouts** (a presentation choice, never a parse distinction — there are no semantic "forms," only render shapes):

**Vertical layout (formatter-canonical for multi-line branches):**
```
(pipeline_a)
    ><
(pipeline_b)
```

Three or more branches stack:
```
(pipeline_a)
    ><
(pipeline_b)
    ><
(pipeline_c)
```

**Inline layout (formatter-canonical for atomic branches):**
```
(branch_a) >< (branch_b)
(audio_l |> compress) >< (audio_r |> compress)
(extract_x) >< (extract_y) >< (extract_z)
```

**Layout is the formatter's projection — never semantics.** The
precedence table alone draws the tree: `><` binds looser than `|>`,
so `a |> f >< b |> g` IS `(a |> f) >< (b |> g)` with or without
parens. The formatter writes the parens and chooses the layout; the
parser enforces nothing about whitespace or parenthesization.

**Render rule (formatter canon):**
- Each branch rendered parenthesized — `(...)` — for visual branch boundaries.
- All branches single-line + total fits target width → inline layout.
- Any branch multi-line OR total exceeds width → vertical layout: each branch on its own line; `><` ALONE on its own line at INDENTED CENTER (4-space indent).
- Mixed shapes normalize to vertical at save.

The construct reads top-to-bottom (vertical) or left-to-right (inline). After `><` the chain returns to LEFT EDGE for whatever consumes the tupled result — the fanout parenthesized, because `|>` binds tighter than `><` (§Precedence) and an unparenthesized foot-pipe enters the last branch:
```
((audio_left  |> compress |> limit)
    ><
(audio_right |> compress |> limit))
|> stereo_mix
```

### `><` branch typing

A `><` branch is a VALUE computation — "each branch has its own
input" means the branch IS the applied pipeline, a complete
expression whose result the fanout tuples (every render example
above is one: `audio_left |> compress |> limit` is the limited
signal, not a function awaiting it). So branch validity is the
branch expression's ordinary typing: the value boundary evaluates
it, the tuple carries its result, and a genuinely ill-typed branch
surfaces as the unification failure it is, with a Reason back to
its own site. There is no branch-shape judgment — four spellings
of the same fanout (calls, literals, pipes, bare vars) are one
type and one verdict (the quartet gate,
`tests/frontier/mn-pcompose-value-branches.mn`). The stage
requirement belongs to `<|` alone, where each branch is APPLIED to
the borrowed input and a non-function branch fails that
application's unification. The parser never inspects branch shape —
parse-time form classification is the eager-form-commitment drift
(`protocol_parse_is_eager_graph_projection.md`).

### `~>` — tee (handler-attach)

`expr ~> h` installs handler `h` over `expr` — drawing the install edge to `h`'s node and intercepting the effects `expr` performs. `~>` is the one install verb; there is no keyword spelling (`handle` is not a keyword — see §«Installation»).

**The one law:** `~>` has ONE precedence — **1, the loosest binary
operator** (see §Precedence). The handler at the foot of a chain
governs everything to its left in the expression; parenthesize
`(stage ~> h)` to narrow the scope to one stage. There is no second
rule: no layout sensitivity, no inline/block semantic split.
**Whitespace is never semantically load-bearing in Mentl.**

```
source
  |> lex
  |> parse
  |> infer
  ~> env_handler          // governs (source |> lex |> parse |> infer)
  ~> graph_handler        // wraps env_handler(...)
  ~> diagnostics_handler  // outermost — sandbox boundary
```

Narrow scope is parens, visible at the site:
```
raw_string
  |> (parse_json ~> catch_parse_error(default = "{}"))
  |> save_to_db
```

Block vs inline on the page is the FORMATTER's choice, projected
from tree shape: a chain body earns the block layout (`~>` on its
own line at left-edge indent); a single-stage body renders inline.
Same node, same scope, either way.

**Type rule:** `row(expr ~> h) = row(expr) - handled(h) + row(h) + cost(h)`. The handler subtracts what it absorbs; anything its arms perform is added; and the install's own cost, a fact of its class, is charged to the frame it stands in: a dispatched install (a schedule included) builds the record its arms run against and pushes its world, so it costs `Memory + Alloc`, and a derivative reading (`~> grad(w)`, which replaces the install with the extent's derivative program) costs nothing.

*The fourth term is real since 2026-09-28. Until then `with !Alloc` accepted `(ask(w) + 1.0) ~> scaled(w)` while every call grew the heap 48 bytes, and a stateless handler's install grew it 40 (`Hβ.effects.install-allocates-unrowed`). An install whose record never outlives its extent could live in the frame and cost nothing; that is a representation the lowering has not built, and the charge follows it when it does (`Hβ.lower.install-record-in-the-frame`).*

**`~>` governs the topology to its left — including a `><` / `<|` fanout.** Because
`~>` is the loosest operator, a `Schedule` handler at the foot of a chain governs
every fanout in the body: `(a |> f) >< (b |> g) ~> Thread` runs both branches
threaded; the branch bodies do not change (there is no second version to keep in
sync). The fanout verb stays pure topology; the cursor reads the execution
strategy LIVE from this install edge (§`><`) — adding `~> Thread`, swapping it for
`~> Simd`, or installing `~> persist(...)` over a multi-shot branch is the entire
diff between sequential, parallel, lane-packed, and crash-surviving. The schedule
is a fact in the `~>` edge, never baked into the verb.

**A derivative reading is the other projection an install can be** (real,
2026-09-28, forward mode). `(body) ~> grad(w)` — lib/ml/grad.mn's `Derivative`
effect and its `grad` handler — evaluates `body` exactly as it evaluates without
the install, and lets it ask `d(v)`: the partial derivative of `v` with respect to
the seed `w`, every other free variable of the extent held fixed.

```
fn train_step(w: Float, x: Float, want: Float) with !Alloc =
  w - 0.05 * ({ let e = want - w * x; d(e * e) } ~> grad(w))
```

Like a schedule, the install is recognized by the effect its handler answers,
and it builds no record, pushes no world and never calls its arm: the lowering
derives the derivative program from the body's own graph and emits it beside the
forward one, so there is no tape and no second copy of the chain to fall out of
step, and the step above leaves the heap where it found it. The seed is a Float
variable in scope, or a record or tuple of Floats (below). State that lives past
the extent — a `<~` line, a handler's state — enters it held fixed, and a `<~`
line inside the extent carries its tangent as a recurrence of its own.

**The reading crosses a function value and a handler's arms through the record
that holds them** (real, 2026-09-30). Handler = state = closure, read once more:
a closure minted under the reading carries its captures' tangents in its own
record, beside the captures, so `d(f(3.0))` for `f = { v => w * v }` minted
under `~> grad(w)` is 3 wherever `f` is called — through `apply(f, x)`, through
a handler's config, through the prelude's `fold`. A perform enters its arm's
derivative program, and a state field written by `resume … with` carries its
tangent beside the field, so `fold(0.0, (a, x) => a + w * x, xs)` differentiates
in `w` through the closure, the accumulator's state and the perform that feeds
it, and scene 1's distortion differentiates through the envelopes its handler
keeps. A function value or an install minted BEFORE the reading opened is a
free variable of the extent and is held fixed: its captures and its state carry
no tangent where the reading opens, and are differentiated from the first write
inside it, so `d(g(3.0))` for the same `g` minted before the install is 0.

**A product seed is answered in one reverse sweep** (real, 2026-09-30). The
seed may be a record or tuple of Floats — `~> grad(ws)` with `ws = {a: 2.0, b:
1.0}` — and `d(v)` is then the gradient of `v` in every Float field, READ BY
DESTRUCTURING where it is asked: `let {a: ga, b: gb} = d(v)` binds each field to
the adjoint of its seed and builds no record, so a `!Alloc` extent stays honest.
The rules of the reading are written once, as a linear program over the
primal's residuals, and the two modes are its two projections, chosen by cost
and never authored, since forward and reverse mean the same thing: a scalar seed
is answered forward (one pass answers every query), a product seed in reverse —
the primal runs first with each test and scrutinee kept as a residual, then
each query transposes the statements before it back to the seeds, one adjoint
per tangent, and a call into a known function runs that function's ADJOINT
TWIN, which recomputes the callee in its own frame and hands its parameters'
adjoints back through registers. What the reverse projection does not carry —
a call through a function value, a perform reaching an arm, a `<~` line or a
record carrying a tangent, an install, an early return, a query inside a callee,
a recursion anywhere in the extent's reach — a product seed reaching it REFUSES
naming the vector-forward reading (`Hβ.derive.vector-forward`), never a slope
of zero; and holding a gradient as a value (`let g = d(v)`) refuses too
(`Hβ.derive.gradient-as-a-value`), since the record it would build is an
allocation the row never saw. Reverse through iteration, through the record and
through a `<~` line's history are `Hβ.derive.transpose-through-iteration`,
`Hβ.derive.transpose-through-the-record` and `Hβ.derive.bptt-priced-by-the-row`.

What the reading cannot carry, it refuses: `d` of a value whose tangent was lost
— into an aggregate, across a multi-shot perform, off a line ticked by forward
code, through another `d` — is `E_DerivativeUnreachable` at the query, naming
where it was lost, never a slope of zero; and a mint, an install or a state
write that would store a lost tangent into a record refuses where it stands,
since the record's later readers could not know. A `d` outside every reading
leaves `Derivative` unhandled at the root. A `<~` line a closure record owns is
`Hβ.derive.closure-line-tangent`.

**An arena is the third: the extent's allocations die at its exit** (real,
2026-10-03). `(body) ~> arena` — lib/arena.mn's `arena`, which answers `Alloc`
by forwarding — evaluates `body` exactly as it evaluates without the install,
and at the exit reclaims everything the body allocated except what its
publication reaches: the body's value, and each value the body stored into
memory older than the arena. Those move, by type, and the line resets behind
the copies, so an exit costs what crossed and never what died.

```
fn total_of(n) = (build(n) |> fold(0, add)) ~> arena   // the list dies; the sum crosses
```

Like a schedule and a reading, the install is recognized by the effect its
handler answers; it builds no record and pushes no world, and it charges
`Arena` — an effect no handler answers — so `main`'s row says whether a program
opens one, and a program that opens none pays nothing at a store. A store into
older memory is known where it happens: a list slot's `list_set`, a handler's
state commit and a `<~` tick each journal the slot with the type the store
knows, wherever the judgment cannot prove the target belongs to the extent — a
buffer the extent allocated owes nothing, a parameter is its callers' question,
a handler's state its installs'. A value whose type the store cannot see — a
function, a continuation, a store through `list_set` reached as a value — is
never moved: the exit keeps the whole region instead, correct for any program
and reclaiming nothing (`Hβ.arena.closure-evac-face`). Reclamation is
reachability from the publication, never a `Consume`: ownership's regions stay
compile-time facts. In a module that spawns, the arena runs its body and
reclaims nothing (`Hβ.arena.per-instance-regions`).

**A suspended arena keeps its region, and each resumption is an arena of its
own** (real, 2026-10-03). An op performed inside an arena and answered by a
handler outside it suspends what the arena encloses: the continuation the
handler holds and the perform's arguments live in the arena's region, and the
rest of the body has not run. So the exit does not end the extent — the arena
SUSPENDS, its region joining the extent around it — and every resumption runs
the rest inside a fresh arena that exits where the body ends, reclaiming what
that resumption built and moving out what it published. The fresh arena
encloses everything the original enclosed, a callee's rest after the perform
as much as the body's own, opened before any of it runs: under a handler that
resumes three times, `fn step() = work() ~> arena` with `fn work() = pick() +
len(build(200)) - 200` grows the heap 96 bytes in all, against 19,240 with no
arena. An arena whose body suspends is a capture point for the function it
stands in (§«Resume discipline»), so the rest of that function resumes at the
arena's value; an arm that never resumes leaves the arena suspended for good,
its arguments intact. `arena_stat(ArSuspended)` counts the suspensions. Until
this landed the exit ran on the way out and reclaimed the continuation and the
arguments from under the arm, which then trapped or read zero
(`Hβ.arena.suspended-by-a-continuation`).

### `<~` — feedback (cycle closure)

Closes a cycle back into the pipeline; the value computed flows back as input on the next iteration.

```
signal <~ delay(3)        // 3-sample feedback delay
state  <~ accumulate(0)   // running accumulator
filter <~ filter_spec(N, coeffs)
```

**Layout:** `<~` may appear INLINE (one line) or at INDENTED CENTER for clarity:
```
signal
    <~ delay(3)
```

**Type rule:** `<~`'s RHS is a **state-element** — `delay(N)`, `accumulate(init)`, `filter_spec(N, coeffs)`, or any user-defined register of that shape — and the verb checks it as one (`FeedbackSpec`); a non-spec RHS fails that unification with a Reason to its own site.

**The causality rule (real, 2026-08-12):** a cycle with no delay has no computable value — the prior would be the very output being computed — so `x <~ delay(0)` is **`E_ZeroDelayFeedback`**, an ARMED refusal at the `<~` site (nonzero exit, zero WAT). Faust makes this unsayable by inserting its delay implicitly; Mentl names the depth, so the depth can be wrong, so the medium refuses it. The refusal is one ARM of the depth read below — the same read that sizes the line judges whether the size is sayable — and both `delay(0)` and `Delay(0)` convict, the two spellings of one FeedbackSpec variant.

**The iterative context is the CLOCK, and the clock is inferred, not required** (measured 2026-08-12). An earlier reading of this section demanded "the structural presence of a cycle/iteration-resume handler in the enclosing stack," with `E_FeedbackNoContext` when absent. The substrate never realized that: a `<~` site is a per-site state register whose *previous iteration* is the enclosing function's next call, which is why the stage `bandpass_stage` mints (`lib/dsp/signal.mn`, four `<~` sites) carries no clock in its row and is correct. Requiring an ambient effect would refuse correct code — the wheel's own thirteen `<~` sites among it — so `E_FeedbackNoContext` has no construction site, deliberately. Its honest form is the inferred clock (`Hβ.dataflow.clock-calculus-sample-rate`, Lustre's clock calculus): when the medium *proves* what advances a cycle, "nothing advances this one" becomes a measurement, and the refusal is that measurement projected. `Sample`/`Tick`/`Clock` are instances of the class, never a name-allowlist (a name-allowlist would be the string-keyed drift at the handler layer); `IterContext` (`lib/dsp/clock.mn`) is the marker vocabulary waiting on that landing.

**The declared depth IS the line's depth (real, 2026-08-12), and the line is a RING OWNED BY THE RECORD OF THE FUNCTION THAT CONTAINS THE CYCLE (real, 2026-09-27).** `delay(N)` carries N priors: the site's line is an N-slot ring, the prior the cycle reads is its OLDEST slot — y[n−N] — and each tick stores the output over it and advances the head by one, so a tick is a load, a store and a bounded increment at any depth (`delay(24_000)` costs what `delay(1)` costs per tick; `tests/frontier/mn-feedback-deep-line.mn` drives 2,000,000 ticks at that depth and the frontier leg prints the ticks per second). `delay(1)` is the single register it always was; `delay(3)` is genuinely three deep, measured by the same recurrence driven six times answering 6 under `delay(1)` and 2 under `delay(3)`. The ring is allocated ONCE, where its owner is built — never per tick — and its owner is the record of the function the `<~` sits in (handler = state = closure, read at the site): a lambda's line lives in the closure record past its captures, so every closure minted from one lambda is its own filter (`let lp_l = lowpass(0.3)` and `let lp_r = lowpass(0.3)` are two lines, the two-channel shape every stereo stage writes); a handler arm's line lives in the install record past the arms, so every `~> h` is its own filter; a reified remainder's line lives in the k record, shared by that k's resumptions as every heap write of the remainder is; a top-level fn's line — its record being the module's immutable data record — rides an instance global allocated at start, one per emitted twin, so a generic recurrence reached at Int and at Float ticks two lines at two widths; and a `<~` directly in a module value let's init is static the same way, its line owned by the module's init function, while a fn nested in that init is a closure minted there and keeps its lines in its record (real, 2026-09-28 — module scope is a frame). A filter that must exist once per signal is therefore a MAKER: lib/dsp's `lowpass_filter(sr)`, `highpass_filter(sr)`, `dc_blocker()` and `envelope_follower(attack, release, sr)` each return the stage, and each stage minted owns its line — they were top-level fns until 2026-09-28, one line per program, so a stereo pair through one filter shared one memory. Until this landed the line was N module globals keyed by the site alone: two closures from one lambda, two installs of one handler and two twins of one generic shared one register (the Float twin wrote f64 into an i32 line and refused to assemble), and a deep line was N global moves per tick (`tests/micros/mn-feedback-closure-instances.mn`, `mn-feedback-arm-instances.mn`, `mn-feedback-twin-width.mn`, `mn-feedback-deep-line.mn`, each measured on boot 542ea5a3 before the fix). **The `!Alloc` row survives the cycle (2026-09-25).** The RHS is checked as a `FeedbackSpec` VALUE — its type is what the site reads — but its construction never executes: emit discards the lowered spec and the prior is a register read off the ring, so the site judges the spec in a frame whose row is dropped. Until that landing the constructor's allocation charged the frame: `fn cycle() with !Alloc` around `((prev) => ramp(prev)) <~ Delay(3)` refused with `!Alloc + Any vs Memory + Alloc`, and arming `E_EffectMismatch` turned that false charge into a false refusal of a correct program, which is what closed it (tests/frontier/mn-feedback-transport.mn pins it). The surface question behind it stays open and is the smaller artifact: whether the RHS should stop being an expression and become a static depth annotation, which is what the emit already treats it as (`Hβ.effects.feedback-row-substitutes`, branch B).

**The depth must be a LITERAL.** A line is a fixed set of slots, so a depth the medium can only read at runtime is a depth it cannot hold — and handing such a site one slot is precisely the silent wrong the depth read exists to end. `delay(n - 1)` is **`E_ComputedDelayDepth`**, armed at the `<~` site. A runtime-sized line wants the image-backed sequence rather than a register file, which is `Hβ.dataflow.delay-line-runtime-depth`, riding the value ontology's own view/slice work.

**Binding the prior — the recurrence form.** The LHS may be a single-param lambda `(prev) => body`; `prev` binds the **prior iteration's output**, read live, so a genuine IIR recurrence `y[n] = f(x[n], y[n-1])` is expressed (not approximated by a bare feed-forward LHS):

```
fn lowpass(x: Sample, a: Float) -> Sample with Sample + Pure + !Alloc =
  ((prev) => a * x + (1.0 - a) * prev) <~ delay(1)
```

The prior is a **graph node** (the feedback site's own carried value), not a register copied into scope — `prev` resolves to `RFbPrior` → `LFeedbackPrior`, emitting a direct read of the site's prior local. The body is **inlined**, never a heap closure: a `<~` recurrence allocating per tick would defeat the `!Alloc` real-time row, so the prior is a register read. A bare-expression LHS (no lambda) is the feed-forward form — it computes on the current input only; the `(prev) =>` form is what carries `y[n-1]`. The surface surpasses Faust's untyped `~`: the prior carries the same refinement row (`Sample`/`Hz`/`Gain`) and the `!Alloc` proof as the forward path. (Surface kernel correspondence: primitive #3 the `<~` verb; primitive #5 the prior is owned-read, not aliased.)

---

## Records

Mentl records are **structural**: a record TYPE is `{name: T1, age: T2}` — no nominal declaration ceremony required. Two records with the same fields and types unify. Row polymorphism is supported.

### Canonical literal form

```
{name: "Morgan", age: 30}
```

Fields separated by commas. Each field is `name: value`. A literal that fits the line renders inline; one past the width, or one whose field carries a comment, renders one field per line, each closed by its comma, so adding a field at the end is a one-line diff — the call-argument law at the record altitude (`mentl fmt` wrote a fourteen-field literal on one 300-column line until 2026-09-28):
```
{
  name: "Morgan",
  age: 30,
  email: "morgan@example.com",
}
```

**Field punning** — when the value's expression IS a variable of the same name as the field:
```
let name = "Morgan"
let age = 30
{name, age}              // sugar for {name: name, age: age}
```

Mixed punning:
```
{name, age, email: derive_email(name)}
```

**Sorting at parse time.** Fields are sorted alphabetically by name when the AST is constructed. Source order is irrelevant; the canonical AST has fields in alphabetical order. This makes record-equality and field-offset computation deterministic.

### Canonical type form

```
{name: String, age: Int}
```

Inline structural. Used in fn parameter types, return types, let-bindings. No declaration ceremony.

### Row polymorphism

Open record type — accepts any record with AT LEAST these fields:
```
fn greet(u: {name: String, ...}) -> String =
  "Hello, " ++ u.name
```

`...` is anonymous rest; `...R` binds the rest to a row variable `R` for further use:
```
fn extend(base: {name: String, ...R}, age: Int) -> {name: String, age: Int, ...R} =
  ...
```

**The lathe is turned to this section as of 2026-09-01.** It carried a
SILENT WRONG for two weeks and the record is kept because the shape is
instructive: an OPEN row's offsets were computed from the KNOWN field
set's own ordering instead of the runtime record's, so `greet` above,
called with a record whose other fields sort before `name`, read one of
those fields. `fn width(u: {name: Int, ...}) = u.name + 1` over
`{name: 5, age: 9}` returned 10 — `age + 1` — with no diagnostic and no
trap; `mentl check` passed.

The repair was never a refusal. Turning it into a floor breaks
`fn g({x, y})`, whose destructuring parameter is the same open row, and
the march measured exactly that. The row var is a quantified var like any
other, and it keys the twin: the call site proves the whole field set, so
each record shape mints its own specialization and reads its own layout.
Two sites had dropped the same handle — the specialization walk discarded
the row var, and the substitution kept it unresolved. Gates:
`tests/syntax/record-field-param-open` (the red twin of the closed
control), `record-field-param-open-two-shapes` (two shapes through one
callee, which is the measurement that named the mechanism rather than the
symptom), and `record-field-through-list`. A row that nothing closes still
refuses — `tests/floors/mn-unprovable-offset`, where the receiver is
main's own parameter.

**The SECOND field reached the same class again (closed 2026-09-28).** A
body reading two fields met them as two open rows and wrote each side's
missing fields as the other's whole remainder, leaving no variable to
generalize, so `fn pick(u) = u.x * 10 + u.y` over `{x: 1, y: 2}` and `{a:
5, x: 3, y: 4}` read one layout for both and answered 54 for 46, silently
(`tests/micros/mn-row-two-fields-two-shapes.mn`). The unseen rest of a
record is always a row variable now, never an assumed remainder: two open
rows meet at one fresh variable both continue into, so every record shape
still mints its own twin.

### Nominal record types

When a brand is wanted (distinct identity, not just shape):
```
type Person = {name: String, age: Int}
type Customer = {name: String, age: Int}    // DIFFERENT type from Person despite same shape
```

Nominal records are constructed using their type name:
```
let p = Person{name: "Morgan", age: 30}
let c = Customer{name: "Morgan", age: 30}
// p and c have different types; cannot be unified
```

A nominal record's declared field types are claimed where the record is
built, as a constructor's arguments are: `R{den: 0}` under `type R = {den:
Positive}` refuses at the `0`, and a function placed at a function-typed
field crosses into it (real, 2026-10-02 — both compiled clean before).

**Brace-header slots close at `{` — the construction never extends a header.**
Three grammar slots parse an expression whose own terminator is `{`: an `if`
condition, a `match` scrutinee, and a handler declaration's state inits
(`with x = init {`). In those slots a capitalized name followed by `{` is the
name alone — the brace opens the form's block, never a record body:

```
handler find(pred) with found = None {   // `None {` — the `{` opens the arms
  ...
}
match acquired { ... }                    // scrutinee ends at `{`
if owner == None { fallback() }           // `None {` — the then-block
```

This is forced, not chosen: the slot's follow-set contains `{`, so a greedy
record-continuation is ambiguous by construction (`None { x }` — a punned
single-field record or a block holding `x`? — no lookahead resolves it), and
principle 3 makes the grammar pay that debt here. The common case (a nullary
constructor as init or scrutinee) is free; the rare record-literal-in-header
parenthesizes, and the general unexpected-token diagnostic teaches it:

```
match (Person{name: n}) { ... }           // record literal in a header slot
```

Everywhere else — bindings, arguments, arm bodies, operands — `TypeName{...}`
extends as written. Layout is never consulted (principle 1); the slot, not
whitespace, decides.

**Every other brace reads its `{` through ONE discrimination** (real,
2026-09-28): `...` opens an update, a pattern ending at `=>` opens an arm
list (§«Function literals»), a field name followed by `:`, `,` or `}` opens a
record, and anything else opens a block. A function body is such a slot, so
`fn origin() = {x: 0, y: 0}` returns a record and needs no parens, and `fn
f() = {x}` is the punned one-field record — never a block holding `x`, which
the formatter lifts to `fn f() = x` (`E_RedundantBraces`). Until 2026-09-28 a
fn body carried its own copy of the decision that read every `{` as a block,
the formatter wrapped body records in parens to compensate, and `fn f() = {
field: v }` failed to parse on a page written by hand.

### Pattern syntax for records

```
let {name, age} = morgan       // both fields bound to locals
let {name, ...rest} = morgan   // bind name; rest is a record of remaining fields
let {name: n, age: a} = morgan // bind to renamed locals
```

The record-pattern REST is real (2026-07-30): `{name, ...rest}` binds `rest`
to a fresh record of the remaining fields, each copied at its own width, and
`rest`'s own field accesses read the residual's layout. `..._` keeps the
open-acceptance without a bind, exactly as in list patterns. Binding a rest
BUILDS that record, so it charges `Memory + Alloc` in the frame the pattern
stands in, and `with !Alloc` refuses it (real, 2026-09-30 — it was unrowed
before; `tests/micros/mn-record-rest-alloc.mn`).

**A record pattern reads its fields BY NAME** through its receiver's whole
field set, which the twin of each caller proves: a parameter's record may
carry fields the pattern never names, sorted before or after the ones it
does, and `fn pick(u) = { let {zeta} = u; zeta }` answers `9` over `{alpha:
7, zeta: 9}` (real, 2026-09-28). Until then a pattern through a parameter
read the slot of its own field index and answered `7`, silently, and its
rest trapped (`tests/syntax/record-pattern-param`, `-param-rest`). And the
rest's OWN reads spell the residual's layout (real, 2026-09-30): `fn f(u) =
{ let {a, ...rest} = u; rest.b }` over `{a: 1, b: 2, c: 3}` answers `2`. It
answered `3` — the receiver's `c` slot — and `rest.c` a virgin `0`, because
the twin's pair for the row variable was the whole record the call proved
while the rest's chain starts past the named fields; the pair is the
residual past them now (`tests/micros/mn-record-rest-through-param.mn`).

### Field access

```
morgan.name
nested.outer.inner
```

Field access lowers to `LFieldLoad` with offset resolved at compile time from the record's type. O(1) load.

A record literal written as a field of another is its own record: `let r = {inner: {den: 5}}` reads `r.inner.den` as 5 (real, 2026-10-02 — until then every record literal parked its base pointer in one shared scratch, so the outer literal answered the inner's pointer and `r.inner.den` read 0 with no diagnostic).

### Record update — spread into new record

```
let older = {...user, age: user.age + 1}
let tagged = {...event, timestamp: now(), processed: true}
```

`{...existing, field: new_value, ...}` creates a NEW record by copying `existing`'s fields and overwriting/adding the listed fields. Non-destructive; original record unchanged (ownership preserved). Field lists must be type-compatible with the source shape.

---

## Indexing

Subscript access for lists and tuples.

```
argv[1]                      // list index
nodes[idx]                   // list index
(a, b, c)[0]                 // tuple element access (compile-time bounds check)
matrix[i][j]                 // chained indexing
```

`xs[i]` lowers to the appropriate runtime call based on the receiver's inferred type:
- `[a]` → `list_index(xs, i)`.
- Tuple → compile-time position extraction.

Bounds-checking is runtime for lists (traps on out-of-range); compile-time for tuples (H6 exhaustiveness).

Refinements over the index tighten bounds:
```
fn safe_get(xs: [a], i: ValidIndex(xs)) -> a = xs[i]
```

When `i` is refined to a proven-valid index, the compiler elides the bounds check.

---

## Algebraic data types

### Type declaration

```
type Option
  = Some(a)
  | None

type Tree
  = Leaf
  | Branch(Tree(a), a, Tree(a))
```

Each variant is a constructor with zero or more fields. Type
parameters are the lowercase identifiers in field positions — the
case rule IS the declaration (uppercase = nominal type, lowercase =
parameter). Every constructor of a type quantifies the type's full
parameter set (`None : Option(a)` too). Types APPLY with parens,
the one application syntax at every level: values `f(x)`, effects
`Sample(44100)`, types `Option(Int)` / `Tree(a)`.

### Constructor calls (value construction)

```
let some_value = Some(42)
let nothing = None
let tree = Branch(Leaf, 1, Branch(Leaf, 2, Leaf))
```

Same syntax as function calls. Inference disambiguates by looking up the name in env: if it's a `ConstructorScheme`, it lowers to `LMakeVariant` with the constructor's tag_id; if a `FnScheme` (a declared fn), to a direct call of its symbol; if a `ValueScheme` (a let, pattern or state binding), to a call through the closure the value holds.

### Pattern matching

```
match opt {
  Some(v) => v,
  None    => 0,
}
```

Arms separated by commas. Trailing comma allowed.

### Exhaustiveness

The match must cover every variant of the scrutinee's type, OR include a wildcard arm `_ => default`. Missing variants without wildcard:

Diagnostic: **`E_PatternInexhaustive`** at the `match` keyword:
> "match on Option does not cover variant: None. Add `None => ...` arm or `_ => ...` wildcard."

Quick Fix: insert stubs for missing variants.

An arm covers what its top pattern covers: an alternation every branch, an as-pattern `name @ pat` what `pat` does (`whole @ Leaf(_)` covers `Leaf`). The refusal is armed (real, 2026-10-03): a match missing a variant no longer compiles to a program that traps when the variant arrives. Until then the class narrated and emitted, and an as-pattern was read as covering nothing, so `whole @ Leaf(_)` beside `Pair(a, b)` reported a false "misses 1 of 2".

### Type aliases

Three forms of `type` declaration, distinguished by RHS shape:

**Transparent alias** — `type X = Y` (no `where`, RHS is a type expression, not a record literal).

```
type Port = Int
type Frequency = Float
type Bytes = [Int]
```

Creates `TAlias("X", Y)`. The alias and underlying type unify transparently — `Port` and `Int` are interchangeable for type-checking. The name is preserved in Reason chains and in Mentl's voice.

**Refined alias** — `type X = Y where pred`.

```
type ValidPort = Int where self >= 1024 && self <= 65535
type Sample = Float where -1.0 <= self && self <= 1.0
```

Creates `TRefined(TAlias("X", Y), pred)`. The alias names the type; the refinement narrows it via predicate. Verify discharges the predicate at construction sites.

**Representation-pinned alias** — `type X = Y repr <width>` (optionally `where pred`).

```
type Cents     = Int repr i64 where self >= 0
type Coeff     = Float repr f64
type LaneGain  = Float repr f32
type Pixels    = Int repr v128            // four packed lanes
```

*Real (2026-07-30):* the authored `repr <width>` suffix parses (`parse_repr_pin`
after any type-decl base) and the bare-width parameter pin (`s: f64`, `s: f32`,
`i64`, `v128`) mints the same `TReprPin` in type-atom position. The pin types
transparently — identity is the base's; `repr_of`'s own arm is the one width
reader — and since both spellings parse to one pin, the formatter decides the
spelling by POSITION: a pin at a type declaration's right-hand side renders with
its suffix (`type Coeff = Float repr f64`) and a pin in an annotation renders
bare (`s: f64`). Until 2026-09-28 a canonical pair rendered bare everywhere, and
a declaration written as this section writes it came back as `type Coeff = f64`.
The i64/f32/v128 pins carry full vocabulary; their emission
cash-outs ride the named wide-producer residue (the RF64 path is fully live).

`repr <width>` is a **gradient INPUT — a PIN, not a constructor** (the peer of
`own`/`ref` at the representation altitude; it surfaces primitive #7). The gradient
INFERS a value's representation from its type and use (`Word` is the i32 FLOOR;
`i64`/`f64`/`f32`/`v128` are cash-outs the gradient reaches on its own — a `0.5`
literal is native unboxed f64 with no annotation). `repr` only PINS one when asking
for a specific width is a control decision — wider precision (`i64` so money never
loses a cent — the refinement then PROVES it), a hardware lane (`f32`/`v128` for a
bandwidth-bound DSP stage), never a default the developer must type. The pin is a
field of the alias node read at lower (`repr_of(lookup_ty(h))` → `RI32 | RI64 |
RF64 | RF32 | RV128`, an ADT — `repr_width` is 4/8/16 by match, never `==4`), so
`type Coeff = Float repr f64` makes every `Coeff` field a full-precision `f64.*`
slot. The record POINTER stays a word (a handle IS a word) — handle-uniformity and
memcpy-serializability are invariant under the pin.

`mentl where` projects the chosen width as a derived badge — `s : Float @ f32
(pinned)` when authored, `c : Float @ f64 (inferred)` when the gradient reached it
— output, never input. Every parameter and local answers it, and a function
answers its head with its inferred row and the address it is declared at
(`inv(n)  at main:11`) before its parameters' and return's widths; a value
whose type is still a variable reads `a : a @ per instantiation`, since every
instantiation is specialized and takes its own width (real, 2026-10-02). A pin that names the width the gradient would already infer
is `W_RedundantRepr` (drop it; the gradient reaches it anyway). A pin equal to the
floor on an integral type is likewise vacuous. **The same `repr` pin is a
parameter annotation** (the Intent-Boundary peer of `own`/`ref` — §"The Intent
Boundary Rule"): `fn gain(s: f32, k: f32) = s * k` pins the bare-width form (`f32`
≡ `Float repr f32` at the parameter altitude); the gradient infers every unpinned
parameter's representation from use.

**Nominal record** — `type X = {f1: T1, f2: T2, ...}`.

```
type Person = {name: String, age: Int}
type Customer = {name: String, age: Int}    // distinct from Person despite same shape
```

Creates `TName("X", [], TRecord([...]))`. The record's name brands its identity — `Person` and `Customer` do NOT unify even with identical fields.

**For nominal distinction over a primitive** — wrap in a single-field record:

```
type Port = {value: Int}
type Customer = {value: String}
```

No `newtype` keyword required; the record name carries the brand. Field access via `.value`.

### Refinement types

```
type Sample = Float where -1.0 <= self && self <= 1.0
type NonEmpty = [a] where len(self) > 0
type Even = Int where self % 2 == 0
```

`self` refers to the value being refined. The refinement is a `Predicate` discharged by the `Verify` effect at construction sites and elsewhere as needed.

**The bounds join with `&&` — there is no comparison chaining.** A chained
`-1.0 <= self <= 1.0` parses left-associatively as `(-1.0 <= self) <= 1.0`
(one precedence table, no special case), an ill-sorted `Bool <= Float` that
principle 2 already rules against as a second spelling of the conjunction.
Today's predicate walk accepts that shape opaquely and degrades it to honest
`V_Pending` debt (measured 2026-07-24 — this section's own examples carried
the chain and silently lost their refusals); the loud inference rejection
with a Reason arrives when predicates become ordinary expressions
(`Hβ.types.predicate-is-expr`, the band-F chain head).

```
let s: Sample = 0.5      // Verify discharges -1.0 <= 0.5 && 0.5 <= 1.0 statically
let p: ValidPort = 8080  // statically discharged
let bad: Sample = 1.5    // E_RefinementRejected — 1.5 violates the Sample bounds
```

**A claim over a join decides as the AND over its tails** (real,
2026-09-28). `fn note_hz(k: Int) -> Hz = match k { 0 => 220.0, 1 => 261.63,
_ => 440.0 }` discharges because every arm folds inside the bound; one arm
at `30000.0` refuses at the claim; an arm that is not a constant (`_ => f *
2.0`) leaves the claim honest `V_Pending`. `if`, `match` and a block's final
expression are read by STRUCTURE, never by guessing which arm runs, so a dead
arm that writes an out-of-bound constant refuses too — the claim covers every
tail. Until this landed a claim over a join was never decided, and a
note table of eight literals carried eight pending obligations.

**A refinement crossing a function-typed argument is judged** (real,
2026-09-28). The argument's RESULT, where the callee hands it to a refined
position, is judged on the lambda's own body: with `fn run(f) =
alpha(f())` and `alpha(c: Hz)`, `run(() => 30000.0)` refuses and `run(() =>
440.0)` discharges. The argument's PARAMETERS, where it demands a
refinement, discharge when the callee's own type says it passes one (`fn
drive(f, c: Hz) = f(c)`) and are honest `V_Pending` otherwise — the values
a callee passes are made inside the callee, and judging them there is
refinement variables' work (`Hβ.verify.higher-order-refinement`). Until
this landed the refinement was DROPPED at the crossing: a 70,900 Hz sweep
reached an `Hz` filter and `mentl check` was clean.

**A refinement is a fact a VALUE carries, read along the edges it flowed —
never a property of its type** (real, 2026-10-01, P0). A value is what its
sources are: a constant is its point, a reference reads its binder (a
parameter's refinement, a `let`'s annotation, a constructor field's declared
contract), a join takes every tail, a call is its callee's declared return,
and a part a pattern destructured is the argument at that position where its
whole was built. A computation inherits nothing: `fn dec(x: Positive) ->
Positive = x - 1` leaves `0 < x - 1` honest `V_Pending`, and `let d = if c {
n } else { 0 }` is the join of `n` and `0`, never `n`'s refinement. Until this
landed refinements rode the unification class, so every join and every
operator that met a refined value carried its refinement onto the result:
six `with !Trap` programs checked clean and trapped at run time, and `ratio(t,
n: Positive)` demanded Positive of `t` (boot 13e8484a).

**A parameter's refinement is a PRECONDITION, and what it guards travels to
the caller.** Inside the body it is assumed; every call owes it as a claim at
the argument. A row fact the body proves BY the precondition is the
precondition's to guard — `fn inv(n: Positive) with !Trap = 100 / n`
accepts, and `Trap` waits on `n` — and a caller pays it exactly when its own
claim is open: `inv(5)` owes nothing, `inv(m + 1)` charges `Trap` to its
caller, and a caller passing its own `p: Positive` hands the guard on to its
callers. A parameter with no annotation, handed straight into a refined
position, learns the precondition (`fn wrap(x) = inv(x)` owes `Positive` of
its callers). A function with no authored return publishes the contract every
return tail carries, a self-call read as returning what the others do.

**A `let` annotation is a CLAIM its value owes**, decided where the value is
made and never a fact laid over it: `let k: Positive = e - 1` leaves `0 < e -
1` open, and `100 / k` charges `Trap`. A reader of `k` may stand on the
annotation for another claim — the debt is carried once, at the let — and
never for a row fact.

**A structured contract is claimed part by part where the structure is
built, as it is assumed part by part where it is taken apart** (real,
2026-10-02, S4). Under `r: {den: Positive}` a field read or a pattern
assumes `r.den` is `Positive`, so every construction handed there owes it
of the part it builds: `den_inv({den: 0})` refuses at the `0`, a list
literal owes `[Positive]`'s contract of every element, a tuple its
position's, and a nominal contract its constructors' fields read at the
type's arguments — `Option(Positive)` owes `Positive` of `Some`'s field and
nothing of `None`, and `Result(Positive, String)` nothing of `Err`'s. A part
of a value built out of sight is read off the value: held where every
source states it at that part — a parameter's precondition, a declared
return, a let's claim — and owed otherwise, the row its precondition guards
paid where the claim is open. An index read is a part read (`100 / xs[0]`
under `xs: [Positive]` is total), and `let xs: [Positive] = [0]` refuses
where it is written. Until this landed a structure's claim crossed only its
function parts, so seven shapes of this checked clean under `!Trap` and
divided by zero.

**A function's contract travels with the function** (real, 2026-10-01, P0·H).
A lambda's parameter learns its precondition as a declared one does —
`(c) => alpha(c)` demands `Hz` of every value it is called with — and every
application owes it: a call through the value, a function crossing, and a
pipe stage, which applies its stage and so claims of the piped value what a
call's argument would owe (`30000.0 |> alpha` refuses as `alpha(30000.0)`
does). A function-typed parameter learns from how its body applies it: the
values every application hands each position — `fn drive(f, c: Hz) = f(c)`
hands its function `c`'s values, which are `Hz`, and `fn feed(f) = f(440.0)`
hands it `440.0` — and what a refined position demands of the result — `fn
run(f) = alpha(f())` publishes `f: () -> Hz` — so a caller's crossing judges
the function it hands in: a lambda's body against the demanded result, its
own demands against the values the callee hands it. A `<~` cycle binds its
lambda's parameter with no application to raise a claim, so that parameter
learns nothing and a demand inside the body stays the body's debt. Until this
landed the pipe raised no claim at all, and `0 |> inv` under `!Trap` checked
clean and divided by zero (boot 13e8484a).

**A function value is every function it can be** (real, 2026-10-02, H4). A
join of two functions, a list or a record of them, a function a pattern took
apart, a function a generic call returns: applying the value owes the
precondition of every function it can be, conjoined per position, and the
row each one guards — `pick(false)(0)` over `fn pick(c) = if c { inv2 } else
{ inv }` owes `inv`'s `Positive` whichever branch comes first. What a body
HANDS a function is never what that function DEMANDS: a function handed to
`fn outer(g) = drive(g, 440.0) + g(30000.0)` is judged against both values it
will be handed, not against `drive`'s `Hz` as a demand of its own. A function
moving through a GENERIC callee is judged by the callee's signature alone —
parametricity, the callee's body never read: `fold(0, (acc, f) => acc +
f(0), [inv])` hands the list's `inv` to the callback, which applies it at 0,
and refuses; a nominal type's arguments carry their values the same way, so
`opt_apply({ g => g(0) }, Some(inv))` refuses through `Option(a)`. And what a
body cannot see is never assumed: a function parameter it returns, hands to
another function its caller chose, or places where the contract is a type
variable is judged as handed values nothing there can name. Until this landed
a function's contract rode its type, which unification merged and kept one
side of: the join and the `fold` shapes checked clean under `!Trap` and
divided by zero, and `g(30000.0)` refused a correct program (boot e23392f6).

**A function's contract is never lost at a position** (real, 2026-10-02,
S6). A declaration or a lambda returning functions publishes, at every
position of its return that holds one, the meet of every function the
position can hold: `fn pick(c) = if c { {f: succ} } else { {f: inv} }`
makes `pick(c).f` demand `Positive` whichever branch runs — through a tuple,
an `Option`, a list, a relay, a module value and a parameter alike. A
position whose type is STATED is crossed by every function placed there,
which pays there the guard of each demand the position does not provide: an
authored return (`fn mk() -> (Int) -> Int = inv`), a nominal record's
declared field (`Ops{f: inv}` under `{f: (Int) -> Int}`), an op's declared
return at `resume` (`resume(inv)` into `get_fn() -> (Int) -> Int`), and the
functions inside a function's result where it crosses into a parameter that
applies them. Until this landed a published return kept the first branch's
contract, a stated position was unified and never claimed, and an authored
return's payment was dropped outside its declaration's frame: each shape
checked clean under `!Trap` and divided by zero (pin 85218488).

**A tee's value is every value its install can answer** (real, 2026-10-03).
The value walk reads a `~>` node as the body's tails and each arm's tails of
the installed handler — an arm whose tail is the `resume` hands the
remainder's answer through and adds no value of its own — so `100 / (({ let _
= ask(); 5 }) ~> zero)` with `zero`'s arm answering `0` is refuted
(`E_RefinementRejected`), and with the arm answering `5` it is proven under
`!Trap` and runs; the flow label reads the same leaves, so an arm answering a
classified value classifies the install and its splice refuses. Until this
landed every walk read a tee as nothing it could read: the refutation was
debt, the proof was a refusal the program did not owe, and the classified
arm's splice compiled clean on boot cf8a6d50
(`tests/micros/mn-refine-install-answer.mn`,
`mn-refine-install-answer-proven.mn`, `tests/frontier/mn-ifc-tee-arm-leak.mn`).

The predicate is a compile-time obligation; at gradient-top it erases entirely (no runtime check). `Verify`'s default ledger accrues what it cannot discharge statically (`V_Pending`); the Arc F.1 SMT handler swap discharges those by residual theory — same source, deeper proof engine.

---

## Effect declarations

### Unparameterized effect

```
effect IO {
  print(msg: String)               // unit return; `-> ()` omitted
  read() -> String
}

effect State {
  get() -> s
  set(v: s)                        // unit return; `-> ()` omitted
}
```

Each operation declares its parameter types and return type (if non-unit). **Resume cardinality is INFERRED at handler-decl time from each arm body** — never declared on the effect op. The infer pass counts resume call sites under control-flow ancestry; the inferred cardinality attaches to the op's `TCont` continuation type and drives lower's tier selection (Tier 1 direct call vs Tier 3 heap continuation). See `protocol_cursor_is_the_substrate.md` for the discipline.

The graph type is `TCont(R, S, ResumeDiscipline, World)`: `R` is the value
accepted by `resume`, `S` is the answer produced by the captured remainder,
and `World` is the exact capability world frozen with that remainder. `R` and
`S` are independent. A handler may resume a `Float` operation into a remainder
whose answer is `Int`; neither representation may stand in for the other.

### Invoking effect operations

An effect op is invoked as a **bare call** — the same surface as any
function call:

```
fn expect_true(value) = {
  check(value, "expected true")     // canonical — check is the Test effect's op
}
```

The env binding proves op-ness (`EffectOpScheme`); the op's `TFun` row
carries `Closed[eff]` definitionally from its declaration. The enclosing
fn's `with` clause is verified against the row inferred from these call
sites. The reader who needs suspension points reads the row in the
signature or the cursor's projection — the medium narrates what a
keyword would only whisper.

**`perform` is not a keyword** (dissolved 2026-08-08, the
`Hβ.syntax.perform-dissolution` peer executed — the turbofish/`handle`
precedent, third application): the word lexes as an ordinary
identifier, so a stale-fluency `perform check(...)` parses as ordinary
expressions and the general unresolved-name diagnostic teaches the
bare call in context. No bespoke recognizer, no format-lift class —
`E_RedundantPerform` and the `TPerform` token are deleted with it.
`resume` keeps its keyword: it is context-bound to handler arms, typed
by the typed-resume law (`resume : R -> S`), and names the
continuation — a value the call site cannot otherwise reach.

**A perform costs what a call costs** (real, 2026-09-30). An op's
arguments cross at the widths the site proves and its result comes back at
the width the site proves, exactly as a closure call's do — a Float op costs
a Float call — and the arm that answers is the one twinned at the install's
instance, which is the site's own instance, so no cell is built at an
effect's type variable: `fn walk(xs: [Float]) with !Alloc = { put(xs[0]);
put(xs[1]) }` under `handler total with s = 0.0 { put(v) => resume() with s
= s + v }` runs and allocates nothing. Until this landed the op's DECLARED
signature was the call's face, so a value at a variable's position was boxed
into a fresh cell on every perform, 8 bytes under a row that said nothing of
it, and a `fold` over Floats paid it per element. A perform under `!Alloc`
is therefore admitted exactly when the op's own row is — and a held or
multi-shot op's row says `Memory + Alloc`, because reifying the remainder is
what such a perform builds (§«Resume discipline»).

**A wide value crosses a continuation in a register, never a cell** (real,
2026-10-03). The caller of a continuation, and the driver that runs a
multi-shot arm, are blind to the types they call through — one word-arity
face serves every chain — so a Float resumed into a continuation, or answered
by a multi-shot arm, crosses in a per-instance register beside the word slot,
set immediately before the call and read immediately after it (the machine
ABI's own shape: words in the integer slots, a double in a float register),
and a multi-shot op's arguments cross in the yield's record at their widths.
Nothing is boxed and no row changes: the same two-resumption program at Int
and at Float grows the heap by the same bytes
(`tests/micros/mn-multishot-float-answer-no-box.mn`); until this landed the
driver read a wide answer as a word and such a program did not assemble.

### Unit return omission

If an effect op returns unit `()`, the `-> ()` clause may be omitted:

```
effect Console { print(msg: String) }       // returns ()
effect Console { print(msg: String) -> () } // equivalent, explicit
```

Both forms are accepted; absence is the idiomatic short form. Non-unit returns MUST be declared explicitly: `read() -> String`. This mirrors the fn-declaration rule where `-> RetTy` is optional on inferred fns but REQUIRED when declared.

**Never-returning ops** declare `-> !`: the op's handler arm never resumes
(`abort() -> !` — the control cut the Abandon discipline reads; a bare type
variable `fail(msg: String) -> a` is the bottom-producing sibling whose return
unifies with any consumer). The form parses and checks clean (probed at pin
62542a59, the Phase 3 felt walk — zero diagnostics). `proc_exit(Int) -> !` is the
WASI op's own declaration (lib/io.mn, 2026-10-03): the host ends the process,
so the op answers a bare variable and an arm ending in it answers any
install — which is what makes `fail_exit` installable over a body of any type
now that an install meets its arms' answer (§«Handler declarations»).

### Calling resume with unit

For ops returning `()`, the handler arm calls `resume()` (no inner unit literal required):

```
handler stdout_console {
  print(msg) => {
    fd_write(msg)
    resume()                // canonical — not resume(())
  }
}
```

Per the parameter-list-as-product rule (§"Labeled call arguments"), a zero-arg call unifies with a unit parameter type. `resume()` and `resume(())` are grammatically equivalent; `resume()` is canonical by §"No redundant form."

### Parameterized effect (first-class)

```
effect Sample(rate: Int) {
  tick() -> ()
  current_sample() -> Float
}

effect Budget(limit: Int) {
  spend(amount: Int) -> Bool
}
```

The effect name itself carries arguments. **Row algebra treats `Sample(44100)` and `Sample(48000)` as distinct effects**, and a body that performs both carries both, in either order: `fast() + slow()` under `!Sample(44100)` refuses exactly as `slow() + fast()` does. Two instances are two row members exactly when they are PROVABLY distinct — the question a negation asks, so the set and the negation cannot disagree — and an instance whose argument nothing grounds (an operand node) stands for every instance it might equal. Until 2026-09-28 a row kept the first of two same-named instances and the verdict depended on the order of the calls (`tests/crown/leak-instance-order.mn`). A TYPE argument is not a value instance: an effect's type variables are shared across its ops, so one handler serves one instantiation and the install unifies the performs; a generic op quantified per perform is `Hβ.effects.two-instances-of-one-effect-do-not-join`.

### Installation in `with` clauses

```
fn audio_loop() with Sample(44100) + IO + !Alloc =
  ...
```

The argument is evaluated at install time and frozen. Two functions declared with `Sample(44100)` and `Sample(48000)` cannot interoperate without an explicit handler bridge — at the ROW, today. A handler does not yet pin its instance: `~> sample_at(48000)` answers a `Sample(44100)` perform, so the rate rule a program states is a negation on its path (`render_frame … with !Sample(44100)`), and the install that refuses a foreign instance is `Hβ.effects.handler-pins-its-instance`.

### Resume discipline — inferred, not annotated

Resume cardinality is **inferred from each handler arm body** at handler-decl time; the developer never types `@resume=`. The infer pass walks the arm body collecting resume call sites; classifies via control-flow ancestry + branch-disjointness:

- **`OneShot`** (inferred when zero or one resume site, not under loop ancestor — or multiple sites all in branch-disjoint paths — AND the one use sits at the arm's RESULT position: the arm's value on every path is the resume itself, through `if`/`match`/block tails and a tail call into a helper that resumes at its own tail) — continuation lives on the stack; no heap capture; performance is direct-call equivalent. Compile error never fires here because the inference produces the correct kind from the body's structure.
- **The held single resume** (inferred when the one resume site is INTERIOR — bound by `let`, an operand, an argument, an element, a lambda body — so the arm keeps computing after the remainder returns: `ask() => { let r = resume(1); r * 2 }`) — the remainder is reified as the continuation record and called once; the code after `resume` runs when the remainder returns, and the arm's value is what the install answers (`ask() + 1` under that arm is 4). *Real 2026-09-27: the count alone chose the representation before, so this shape lowered as the stack return, the code after the resume was dead, and the install answered 2 — measured on boot 83428bcc by `tests/micros/mn-oneshot-nontail-resume.mn`. The grade is `ResumeUse` (types.mn): multiplicity × position, ownership's return-transfer distinction read on the continuation.* The record is the honest cost of holding a continuation; dropping it after its one call, O(1), is `Hβ.lower.held-resume-record-is-not-reclaimed`. A held resume runs the remainder INSIDE the frame that calls it — the arm, or a callee the arm hands a resuming lambda to — so that frame's row carries the remainder's (real, 2026-10-01): the resume performs its continuation's world, the handler's remainder, and every install judges what the frames it runs through forbid against its own body minus what it absorbs. `fn apply(f) with !Log = f() + 0` refuses `apply(() => resume(1))` under an install whose body performs `Log` after the perform; until then the resume charged nothing and `apply` ran the remainder's `Log` under its own `!Log` (`tests/crown/leak-resume-remainder.mn`). When that remainder performs one of the handler's own ops again, the resume re-drives the handler where it stands, deep semantics at any depth (`tests/micros/mn-held-resume-*-reyield.mn` — an address or a trap on every boot through 477bb667).
- **`MultiShot`** (inferred when one or more resume sites under loop/recursion ancestry, or two sites both reachable from one path) — continuation captured to the heap as a closure. Enables backtracking, non-determinism, generators. **A MultiShot op's row carries `Memory + Alloc`**: the perform site reifies the remainder as a heap record, so performing the op IS an allocation, and a `!Alloc` declaration around such a perform refuses (`tests/micros/mn-multishot-perform-alloc.mn`; it compiled clean with a Pure row until 2026-09-27 — `Hβ.effects.multishot-perform-allocates-unrowed`). The op's discipline and cost are settled at pre-registration, from parse structure, so they never depend on whether the handler precedes its performers in source order.
- **`Either`** (inferred when callers pin distinct kinds at different install sites; gradient-undecided at the EffectOpScheme) — handler arms may use either; loses some optimization headroom.

**Where a continuation is captured** (real, 2026-10-03). A held or multi-shot perform suspends the computation around it, and the lowering captures the rest where the perform is the FIRST work its frame does — a function's, a block's, an arena's: the whole expression, or an operand of an operator chain whose earlier operands are plain values — and through every call or arena standing at such a position, which captures its own remainder and composes it with the callee's. A perform anywhere else — `{ let v = pick(); v + 1 }` — is `E_ContinuationUncapturable`, said where the emitted program holds it and never in a body nothing runs: until then it compiled clean and trapped (exit 134 on every boot through 10cd1956, `tests/micros/mn-perform-off-spine-refuses.mn`). A call that may suspend standing anywhere else keeps the runtime check it always had. An abandoning op, whose arm never resumes, has no remainder to capture and performs from any position. Capturing at every position is `Hβ.lower.offspine-perform-is-the-frame-not-in-the-image`.

The cardinality is **load-bearing on type+lower** — it's why Mentl can express real-time DSP and constraint-search backtracking under one effect algebra (and why a persisted multi-shot continuation is `memcpy`-serializable while a one-shot is a stack frame). But the **annotation form is drift**: authoring `@resume=` would declare what the body already proves. The body IS the contract — and because a fact this load-bearing must be legible ("systems explain themselves", `PLAN.md §0`), the cursor **projects** it read-only: `mentl where` shows the op's `TCont` as `R ->1 S` (one-shot) or `R ->* S` (multi-shot), a derived badge — never an authored annotation. The body remains the contract; the projection is output, not input.

### Negation in `with` clauses

```
fn pure_op(x: Int) -> Int with !Alloc + !IO =
  ...
```

`!E` proves ABSENCE of effect E. Stronger than not-mentioning E because it propagates transitively through the call graph: any callee that performs E causes the whole declaration to fail with `E_EffectMismatch`.

**And through the declaration's own parameters (real, 2026-09-27).** A
negation on a function that calls a callback is a GATE on that callback's
row: `fn run(f) with !E = f()` refuses `run(() => op())` at the call, and the
refusal names `run`'s declaration — under polymorphism, through a `~>`
mask (`fn run(f) with !E + !F = (f()) ~> h` with `h` absorbing E gates `f`
with `!F` alone), across forward references, sig'd recursion and stored
callbacks, and instance-precisely (`!Sample(44100)` admits a callback
performing `Sample(48000)`). A callback that is only RETURNED, never called,
performs nothing in the declaring body and stays admissible. The same gate
is what an authored negation on a function-TYPE parameter is: `f: () -> Int
with !E` constrains `f`'s row at every call of `f`, and beside it a sibling
parameter's row is judged on its own. Until this landed the negation over a
body whose row was a parameter's was vacuous — the program compiled and
ran.

When used alone (e.g., `with !Mutate`), it creates a **negative capability stance** representing "anything except this effect" (universe-minus). This is how Mentl expresses region-freezes and borrows (`ref`) mathematically without a separate borrow-checker.

**Modal-readiness is a mechanism, not a claim (`PLAN.md §4③`, forward-pointer).** The modal effect synthesis (rows + capabilities unified, closing the higher-order leak) threads effects as *lexical capabilities* through the EXISTING `~>` binding: `~> h` lexically scopes the effect `h` absorbs — that IS the capability mechanism. So the modal form adds only a typing rule (a row variable becomes a lexical capability handle at `~>`), no new surface form: rows give `!E`, `~>` gives the lexical capability, modal is their unification on forms that already exist. Sequenced post-real (§5).

`Pure` is shorthand for "the body's row must be the empty row (no present names, closed tail — `EfRow([], [], EtClosed)` in the kernel's canonical triple)":
```
fn pure_op(x) with Pure = x + 1
```

---

## Handler declarations

### Canonical form

```
handler name(cfg_p1: T1, cfg_p2: T2) with state_a = init_a, state_b = init_b {
  op_arm_1(args) => body,
  op_arm_2(args) => body,
}
```

Three parts:
1. **Config parameters** in `(...)` — closure-captured at install site.
2. **State** after `with` — internal state evolving across arms. The same slot, read by position, may instead carry the handler's own effect row (`handler h with !F { … }` — §«Negation guards on handlers»): a `!`, or a name not followed by `=`, opens a row; a name followed by `=` opens the state inits.
3. **Op arms** in `{...}` — one arm per effect operation, EVERY operation of every effect the arms answer (§«A handler is exhaustive» below).

### Examples

```
// No config, no state — pure handler
handler log_to_stderr {
  log(msg) => {
    write_stderr(msg)
    resume()
  },
}

// Config (URL captured at install) + no state
handler websocket_sink(url: String) {
  emit(ev) => {
    ws_send(url, encode(ev))
    resume()
  },
}

// State (counter that evolves)
handler counter with n = 0 {
  inc() => resume() with n = n + 1,
  get() => resume(n),
}

// Both config + state
handler bounded_log(prefix: String) with count = 0, max = 100 {
  log(msg) => {
    if count >= max { resume() }
    else {
      write_stderr(prefix ++ ": " ++ msg)
      resume() with count = count + 1
    }
  },
}
```

A state init may read the handler's config — `handler window(size) with buf = make_list(size)`, `with n = cfg.x` — because each install builds its state from the config it was given, as a function of its own record, before the handler is installed: an init performs in the installer's world, and one that performs its own handler's ops is `E_InitPerformsOwnOp`. *(Real 2026-09-28, R0c: until then the install lowered the declaration's inits in its own scope, where the config does not exist, so only a bare `with n = cfg` worked and anything more reached a floor and trapped.)*

### A handler is exhaustive

An effect declaration is a sum of requests and a handler is the arm list over
it, so the match law (§«Exhaustiveness») binds a handler as it binds a
`match`: **the arms answer EVERY op of every effect they answer.** A handler
with an arm for `inc` and none for `get` is `E_HandlerInexhaustive` at the
`handler` keyword, naming the ops no arm answers — ARMED, never a narration.

The law is what makes the install's row exact. `expr ~> h` subtracts from
`expr`'s row the effects `h`'s arms answer, by name; a perform of an op with
no arm would walk past the install at runtime and reach whatever is outside
it, which the row never saw. Measured 2026-09-30, and the last known hole
under `!E`: `fn f() with !State = (get() + inc()) ~> only_inc`, `only_inc`
answering `inc` alone, compiled clean under the negation and trapped reading
the evidence at the root (`tests/micros/mn-handler-partial-refuses.mn`).

A handler that means to answer some ops of an effect FORWARDS the rest — an
arm that performs its own op resolves to the enclosing handler (deep-handler
semantics), and the row carries what it forwards:

```
handler only_inc {
  inc() => resume(1),
  get() => resume(get()),      // forwarded to the handler around this one
}

fn f() = (get() + inc()) ~> only_inc      // row: State — `get` escapes f
fn main() = (f()) ~> both                 // 20 + 1
```

`fn f() with !State` over that body refuses (`E_EffectMismatch`: the
forwarded `get` escapes), which is exactly what the partial handler hid. The
other honest form declares the ops the handler answers as their own effect.
Koka and Effekt require the same; the split-effect pair — two handlers
covering one effect's disjoint op sets — is written as two effects.

### An arm's value is the install's value — `Handler(instance, answer)`

A handler is typed by what it handles and by what it answers: `Handler(E,
A)`, the effect's instance and the ANSWER — the cell every arm's body is
judged into, quantified with the instance when the arms leave it free, and
met at every install by the body's own answer. An arm that resumes answers
the install with what the remainder answered, so its value is the body's;
an arm that does not resume answers the install itself, so its value must
be the body's: `handler h { bail() => "not a number" }` installed over
`(bail() + 1) ~> h` refuses `E_TypeMismatch` at the install — `Int vs
List(Byte) — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler
h`, the Reason the unify was asked with, which names the arm whose value is
its own (a `resume` tail hands the remainder's answer through, so a handler
whose every arm resumes answers its install's body) — and the caret's Why at
the tee walks to that arm. `mentl where` says what a handler answers beside
what it absorbs (`handler zero absorbs Ask, answers Int`; `handler ticker
absorbs Tick, answers a`, the variable under the name a developer writes)
and what each install in a function answers (`~> ticker absorbs Tick, answers
Int at 12:28-12:46`). The arms are keyed at the answer as at the instance, so an
arm that observes its answer (`a ++ b` over two resumptions) runs at the
answer its install gives it, and a multi-shot handler answering a Float
assembles (real, 2026-10-03). Until then the handler's type carried its
instance alone and no install ever met the arms' answer: the String arm
above compiled and ran, the observing arm refused `E_ShapeUnprovable`, and
the Float answer did not assemble (`tests/micros/mn-arm-answer-is-the-install.mn`,
`mn-arm-answer-observed.mn`, `mn-multishot-float-answer.mn`, each measured
on boot cf8a6d50). A never-returning op answers a bare variable
(`proc_exit(Int) -> !`), so an arm ending in one — `fail_exit`'s
`proc_exit(1)` — answers any install.

### State updates via `with` on resume

When an arm wants to evolve state, it uses a `with` clause on `resume`:

```
inc() => resume() with n = n + 1
```

The `with` clause lists state updates by field name. Unlisted state stays unchanged. A name that is not one of the handler's state fields is refused (`E_MissingVariable`, "state field: m") — the write would reach nothing anything reads (real, 2026-10-02; until then `resume(0) with m = n + 1` beside `with n = 0` compiled clean and dropped the write).

**A state is every value written into it** (real, 2026-10-02, S5). At any read in an arm, a state field holds its init or whatever some arm last wrote, so everything the medium proves of it is proven of all of them: `100 / d` over `with d = 5` owes `d != 0` of every write — `with d = d - 5` in another arm leaves the division's claim open and refuses under `!Trap`, and `with d = 0` in another arm REFUTES it where it stands (`E_RefinementRejected`, real 2026-10-03: a writer that is the fatal point fails the claim as a join's `0` tail does; it was owed, never refuted, before) — a classified write makes the state classified, and a function written into it is applied under every function it can be. A state no arm writes is its init at every read and proves what the init proves. A write that reads the state it writes (`with d = d + 1`) reads it there as unknown, so a counter's bound is owed rather than proven; reading it as the claim's own hypothesis — an inductive invariant — is the named next step (`Hβ.verify.state-reads-its-invariant`). Until this landed the proof read a state as its init alone, and all three of those shapes checked clean and failed at run.

### Installation

`~>` is the ONE handler-installation operator — it draws the install edge to the
handler's node (`PLAN.md §2`):

```
body_expr ~> handler_name(cfg_args)
```

A sub-scope is a brace-block — a first-class `BlockExpr` — installed the same way:

```
{ let a = setup(); work(a) } ~> handler_name(cfg_args)
```

There is no `handle { body } with h` keyword spelling — `handle` is NOT a
keyword. It is the medium's own domain noun (the graph's node pointer), and
keywording it collided with the codebase's most common identifier: the wheel's
own `let handle = …` binders degraded to `_` under its own lexer (the 2026-07-05
pass-2 face — 106 lost binders). The retirement follows the turbofish precedent
(§«Generic type parameters»): no bespoke keyword for a foreign spelling; a
stale-fluency `handle { body } with h` parses as ordinary expressions and the
general unexpected-token diagnostic teaches `(body) ~> h` in context. One verb,
one edge — and the vocabulary word stays a word.

### Negation guards on handlers

```
handler affine_ledger with !Consume {
  consume(name, span) => ...,
}
```

`with !Consume` on the handler itself is the handler's own row — the same signed clause a fn signature carries, verified the same way — and it binds at TWO altitudes (A5, 2026-09-27, LENS §2.4's arm-world rule): the ARMS may not perform `Consume` themselves (the registration-time gate), and at every install the REMAINDER the arms resume into — the tee body's row with what this handler absorbs removed — may not perform it either, because resuming inside an arm continues that remainder under the handler. So `handler h with !F { op() => resume(1) }` installed over `op() + fop()` refuses at the install, naming `h`; installed over `op() + op()`, or over a body whose `fop()` an inner install absorbs, it holds; and `handler h with !E` over the ops it handles has nothing to check, since the absorption removes them. The check is per install — the body is read where it is known, never joined across installs into the handler's one row.

*(Until 2026-09-27 the parser SKIPPED a handler's effect-row `with` to the arms as "WAT-invisible", so this clause bound nothing: `handler h with !F` accepted a remainder performing F with no diagnostic, measured RED on boot 39b00d84 by `tests/crown/leak-arm-resume-remainder.mn`. The clause rides the `HandlerDeclStmt` now and the formatter renders it back.)*

---

## Named effect rows (capabilities)

Surfaces kernel primitive **#4** (the Boolean effect row). An effect row is a
first-class kernel value (`PLAN.md §2`), so **naming a row is what `type` already
does** — there is no separate `capability` keyword:

```
type File = read + write
type Network = http + dns
type ApiClient = File + Network
```

`type Name = <row-expr>` is a transparent alias (§Type aliases): `Name` unpacks to
its row at every site that takes a row, and `with File + Network` composes
structurally. The RHS uses the full Boolean algebra `+ - & ! Pure`:

- `+` **union** — `type ApiClient = File + Network`
- `-` **difference** — `type ReadOnly = File - write` (admits `read`, rejects `write` at the structural gate)
- `&` **intersection** — `type Shared = ServiceA & ServiceB` (effects BOTH require — the natural typing of a `<|` divergent join); the identity `E - F = E & !F` holds (`inter_row`)
- `!` **negation** — `!Alloc` (universe-minus; transitive proof-of-absence)

```
fn fetch(url) with ApiClient = {
  let body = http("GET", url)
  write(local_cache_path(url), body)
}
```

A row that resolves to `Pure` (everything subtracted out) is `W_CapabilityEmpty`
(the alias adds no constraint — drop it); a row referencing an undeclared effect
surfaces `E_MissingVariable` at the unresolved name.

### A SIGNATURE IS NOT AN INVENTORY — name the capability, author the negation

**The measurement that makes this a rule rather than a preference (2026-09-21).**
The wheel's own declared-row distribution is 132 signatures at four effects and
155 at five — then a tail at 13, 14, 16, 17 (four of them), 18 and **nineteen**.
A nineteen-name `with` clause breaks three laws at once, and they are this
document's own:

1. **It is a re-derivation.** §«With-clauses for effects» says the declared row
   is *a CONSTRAINT verified against the row inferred from the body* — so every
   name is a hand-copy of a fact inference computed. Widening one leaf edits
   every signature above it. That is the Carried-Truth Law violated at the
   surface, in the surface that exists to express it.
2. **It is not intent.** The Intent Boundary Rule reserves annotations for
   DECISIONS — a refinement, an ownership marker, a representation pin.
   `with Memory + Alloc` on a body that obviously allocates is dictation.
3. **It buries the signal.** `!E` is the crown. In a nineteen-name row the one
   negation worth reading is a needle in a haystack the author typed.

**The form, and it needs no new syntax — it is the ABSENCE of the clause.**
The POSITIVE row is inferred and PROJECTED (real, 2026-09-27, A4): what a
signature authors is a decision — a negation, an instance pin, `Pure` — and the
full positive row is read at the address surface (`mentl <file:line>` renders
`-> T with Memory + Alloc`) the way `repr` width and resume cardinality already
are. So the normal signature is `with !Alloc + !Thread`: shorter *and* the part
worth reading. Three mechanisms carry it:

- **`T_RowInventory`** narrates a clause whose bare positive names are exactly
  what the body proves — or whose body row is OPEN (a callback's row rides
  its tail), where a positive cap installs no gate and so constrains nothing.
  `T_OverDeclared` keeps the case where a declared name is beyond the proven
  row, and reads the positive half only: a negation-only signature is never
  "over-declared" (it used to narrate `!Mutate + Any` against a Pure body).
- **`mentl tighten`** writes each narrated clause's RESIDUE — its negations and
  instance pins, or no clause at all — never the proven row (the old form
  wrote type-instances the grammar cannot read back). The medium authored its
  own migration: 1,490 clauses over five runs, the wheel judging clean through
  the inferred rows with zero `E_EffectMismatch` — its negations had been true
  all along.
- **`mentl verify` bounds the shape** (`CsAuthoredPositiveRow`, `src/board.mn`)
  at ZERO on the wheel, seen RED at 164 through the half-swept tree. The
  sixteen-name capability `type Judging` that the first landing named (the
  wide-row count, 19 → 12) lost its last user and is deleted: a capability
  nobody authors needs no name.

**A positive row that survives is a CAP, and the cap is a gate (real,
2026-09-27, A3-pos).** `fn run(f) with E = f()` says `run`'s body, callbacks
included, performs at most E: the argument edge for `run(() => op_f())`
refuses `E_EffectMismatch` naming `run`'s declaration, exactly as a negation
does, and a `~>` mask inside the body widens what reaches the gate (`Pg ∪
mask` on the push: `fn run2(f) with E = ((f()) ~> hf) + op_e()` admits a
callback performing F, because `hf` absorbs it before the gate). Before this
landing a positive cap installed nothing — only its negation half did — and
that program compiled. So a positive row on a HOF is a decision the medium
enforces; write one when the cap is meant, and let inference project the row
otherwise. The two micros that carried `with Abort` on a try/catch HOF whose
thunks allocate and choose refused on arming and lost their caps — the class
LENS §2.2 predicted (`try_with_abort_catch`: a row "to allow the outer scope's
effects to flow", which a positive row cannot say).

**Dissolved:** the `capability` keyword and the `TCapability` token. `capability X
= <row>` was structurally `type X = <row>` (the doc's own prior admission, peer
`Hβ.types.capability-as-row-alias`) — a row is a type-level value, so naming one IS
a type alias, and a second keyword for it is the redundant form Governing Principle
2 rejects. (Want *nominal* row identity — a row that does not unify with its
structural equal? That is record-style branding; but capabilities want structural
composition, so the transparent alias is the ultimate form.)

---

## Pipeline + handler installation in code

### Installing a handler in code

```
let result = computation() ~> state_handler
```

A sub-scope is a brace-block installed the same way; config args ride on the
handler:

```
let result = { let x = setup(); work(x) } ~> state_handler
let log    = { work() } ~> bounded_log("INFO")
```

(There is no keyword install spelling — `handle` is not a keyword
(§«Installation»); handler state and arms live at the handler *declaration*,
never at the install site.)

### Multi-handler chain (capability stack)

```
source
  |> stages
  ~> mentl_default
  ~> affine_ledger
  ~> verify_ledger
  ~> diagnostics_handler   // outermost = least trusted = sandbox boundary
```

Reading top-to-bottom = inner-to-outer trust hierarchy.

---

## Pattern syntax

Patterns appear in `let`, `match`, function parameters, and lambda parameters.

### Variants

| Pattern             | Form                              | Binds              |
|---------------------|-----------------------------------|--------------------|
| `PVar`              | `name`                            | binds `name`       |
| `PWild`             | `_`                               | binds nothing      |
| `PLit`              | `42`, `"hello"`, `true`, `()`     | matches literal    |
| `PCon`              | `Some(v)`, `Branch(l, x, r)`      | binds inner pats   |
| `PTuple`            | `(a, b, c)`                       | positional binds   |
| `PList(prefix, rest)` | `[a, b, c]`, `[head, ...rest]`, `[_, ..._]` | positional prefix + optional rest |
| `PRecord`           | `{name, age}`, `{name: n, ...r}`  | field punning + rest |
| `PAlt`              | `pat_1 \| pat_2 \| ...`            | matches if any branch matches; no variable bindings inside alternatives |
| `PAs`               | `name @ pat`                      | binds `name` to whole value AND destructures via `pat` |

### Examples

```
match value {
  Some(0)            => "zero",
  Some(n)            => "got " ++ int_to_str(n),
  None               => "nothing",
}

match list {
  []                 => "empty",
  [single]           => "one element: " ++ show(single),
  [head, ...rest]    => "head + " ++ int_to_str(len(rest)),
  [_, ..._]          => "non-empty",
}

match user {
  {name: "Morgan", ...} => "found Morgan",
  {name: n}             => "user " ++ n,
}

// Pattern alternation — multiple patterns, one arm body
match event {
  Click(_) | Key(_) | Scroll(_) => "user input",
  Resize | Paint                => "render event",
  _                              => "other",
}

// As-patterns — bind whole value AND destructure
match event {
  e @ Click({x, y}) => process_click_with_coords(e, x, y),
  e @ Key(k)        => log_and_dispatch(e, k),
  _                 => ignore(),
}

let (x, y) = point
let {name, age} = user
let [first, second, ...rest] = items
```

List rest uses the same `...rest` surface as record rest. `rest` is
optional in the AST; no rest means exact-length match, while `..._`
accepts any remaining tail without binding it. `|` remains pattern
alternation / type-variant separation and is never list-cons syntax. A
bound list rest is CUT — the elements past the prefix, as a slice — so it
costs what `slice` costs, `Memory + Alloc`, in the frame the match stands
in, and `with !Alloc` refuses it (real, 2026-09-30: sixteen of the wheel's
own rests were unrowed until the allocation audit's first run;
`tests/micros/mn-list-rest-alloc.mn`). `..._` cuts nothing.

### Exhaustiveness

Match arms must cover all variants OR include a wildcard. Missing-variant errors include the missing variants by name (per H3's exhaustiveness machinery).

### Pattern alternation — rule

`pat_1 | pat_2 | ... | pat_n => body`: body executes if ANY branch matches. Variable bindings ARE allowed inside alternatives WHEN:

1. **All branches bind the same set of names.** Wildcards and literals don't count as bindings.
2. **For each binding name, the types across branches unify.** The body sees the unified type.
3. **Compatible refinements.** When refinements differ across branches, the body sees the disjunction; Verify discharges per-arm.

```
match opt {
  Some(x: Int) | Right(x: Int) => use(x),    // ACCEPTED — same name, same type
  None | Empty => default,                    // ACCEPTED — no bindings
  ...
}

match v {
  Some(x) | Other(y) => use(x)                // REJECTED — different binding names
  //   ^ E_PatternAlternationBindingMismatch
}
```

When branches bind different names: `E_PatternAlternationBindingMismatch` with the conflict surfaced. When the same name has incompatible types: same diagnostic with the type conflict surfaced.

### As-patterns — rule

The as-pattern is real (2026-07-30): `name @ pat` binds the whole value and
destructures it in one arm; the binder carries the scrutinee's own type, and
the match predicate is the inner pattern's alone.

`name @ pat => body`: binds `name` to the entire matched value; `pat` destructures it further. `name` and any bindings inside `pat` are all available in the arm body. Common for "need the whole value AND some pieces" cases — event forwarding, logging, pass-through.

`@` is TAt (reserved for handler annotations more generally; no current load-bearing user-facing `@`-form on effect ops — `@resume=` was erased per the inference-from-body discipline). Context disambiguates if other `@`-forms are introduced in future kernel additions.

---

## Imports

### Canonical form

```
import path/to/module
```

The path is a slash-separated module name. The `ModuleResolver` handler maps it to a file in `std/` or the project's source tree.

### Selective import

```
import path/to/module {name_a, name_b, name_c}
```

Only the listed names are brought into scope.

### No rename / alias

There is no `import X as Y` — an alias is a redundant second name for an edge the import already drew (no-redundant-form). A name collision is resolved **once, at the import edge**, not re-derived at N call sites: selective import narrows each side so each name binds one edge.

```
import dsp/spectral {fft}
import lin/spectral {fft}    // E_ImportNameCollision — two edges into `fft`
```

The graph **refuses** two edges into one name rather than papering over it with a re-resolved dotted path; the developer narrows the selective sets (or, if both are genuinely needed, binds each module's resolved env node once and reaches `.fft` through that single edge). A qualified `dsp.spectral.fft` re-resolves the import edge **by name** at every call site — the canonical re-derivation (`PLAN.md §2`) — so it is the residue the formatter rewrites, never the recommended disambiguator.

**One-separator law:** `/` appears ONLY in import position (transport-honest — the module path maps to the file transport). Everywhere in expressions, `.` is the one access operator — fields and qualified names alike. There is no third separator; `::` is not a token.

---

## Comments

Surfaces primitive #8 (HM with Reasons — a comment is a Reason edge).

There is **ONE comment form**, `//`, and it is **graph content** — the medium
never blinds itself to prose. The lexer emits a comment token; the parser attaches
each comment to the node it precedes (the following declaration, or — with none —
the enclosing block / the file's synthetic `Module` handle) as a
`CommentReason(text, span)` edge, walked by the Why engine and surfaced in Mentl's
voice. "Lossless intent" (`PLAN.md §0`) means a `// HACK: …` is intent the graph
carries, never noise the lexer drops.

```
// Single-pole IIR low-pass, sample-rate-parameterized. Real-time-safe.
//
// Use in audio callbacks where allocation would cause dropouts.
// References to `Sample` and `<~` are resolved by render handlers.
fn lowpass_filter(samples: [Sample]) -> [Sample] with !Alloc =
  ...
```

### What a comment IS

- **Pure prose, graph-attached.** Contiguous `//` lines concatenate to one String; a blank `//` line is a paragraph break. The comment attaches to the immediately-following declaration (`fn`/`type`/`effect`/`handler`/`let`), or — with none — to the enclosing block / the file's `Module` handle; a decl-boundary comment is **never dropped**, and an orphan with genuinely no home surfaces `P_OrphanDocstring` (gradient-narration), never a silent discard. An INTERIOR comment (inside a `{ }` body) attaches to the finest FOLLOWING node — the next statement, the final expr, or the block's own unit node when nothing follows — and a TRAILING same-line comment attaches BACKWARD to the node whose line it shares (same-line is structural: the comment token sits before any newline, one token of lookahead). Both are graph content in the same weave the decl comment fills, judged by the same backtick gate, and the address surface renders the attached prose's first line as the `Lede:` facet. **Attachment is by SPAN, so an ANONYMOUS node is a home like any other**: a comment above a lambda inside an argument list attaches to the lambda (measured 2026-09-17 — `Lede:` at the lambda's address, its backticked params resolving through the enclosing decl's binders), and a lambda's span is its whole extent, head through body, so `mentl <file:line>` on the lambda's line reaches it (it used to be the head alone, and the line's widest-node rule reached a body sub-node instead — the address rule and the weave's rule are one question, and the span is the one fact both read). Expression-interior comments elsewhere (inside parens / match-arm headers) attach by the same span rule; `Hβ.parser.expr-interior-comment-attach` in `RESIDUE.md` names what the gate has and has not measured there.
- **Register is a projection, not a delimiter.** How much surfaces — the one-line lede in `RTerse`, the full body in `RExplain` — is the gradient reading the comment's relevance at the cursor (the same gradient that drives every projection), NOT an author-chosen `//`-vs-`///` audience split. The author writes prose; the cursor decides what shows. First sentence = lede.
- **Surfaces verbatim, rendered per target.** The substrate stores the raw String; render handlers interpret presentation — HTML `<code>` for `` `backticks` ``, terminal ANSI, markdown fence. `` `backticks` `` cross-reference identifiers; the author writes the reference, the handler resolves it.
- **Code blocks compile via the same pipeline.** A comment containing Mentl source IS Mentl source — the compile verifies it; there is no separate doc-test category.

### What a comment TRENDS TO

The design pressure, stated so the trend is never mistaken for an accident:
**a comment that states a mechanism is a CONFESSION that a projection is
missing.** The medium carries types, rows, ownership, refinements, resume
cardinality, spans, and Reasons, and the voice projects them at every
position — so a comment restating a projectable fact is the graph's truth
hand-copied into prose, where it can rot (the Carried-Truth Law at the prose
layer). The deletion test: delete the comment; if information is lost that no
projection can answer, the MISSING PROJECTION is the finding — name the peer,
grow the verb, and the comment's load-bearing half ABSORBS into the medium,
exactly as the bash scaffolds absorb into verbs (`CLAUDE.md ⟳`). What `//`
trends toward as the voice completes is the developer's OWN prose — intent,
taste, the scratchpad, the reminder, the fun — the one genuine Outside
(`PLAN.md §0`: intent), which the medium carries losslessly and never
requires. The wheel measures the distance today: ~38% of its lines carry
prose, nearly all of it mechanism the voice cannot yet speak — each line
larval `mentl why` content queued for absorption, never the endpoint
(`Hβ.voice.comment-mass-absorbs-into-projections`).

### What a comment is NOT

- **Not a markup language.** No `=== headers ===` decorations; the declaration's name IS the heading. Render handlers add presentation chrome.
- **Not JSDoc / Sphinx tags.** No `@param`/`@returns`/`@throws`/`@since`/`@deprecated`: the effect row + refinement substrate already carries parameter/return/capability information. Lifecycle vocabulary ("previously", "no longer", "legacy", `@deprecated`) is forbidden by the positive-form discipline — a comment shows what IS, not what was.
- **Not a gate.** A comment adds, never silences: a declaration with no comment still surfaces Mentl's substrate-derived tentacles (the silence predicate).
- **Not a blessing.** Prose cannot canonize a compensation: a residue's comment names its RETIREMENT CONDITION (the peer, the count that drives to zero), never its permanence. "Deliberate" written by the builder over a standing cost is the costume, not a fact — "the final IS the verification" (superseded 2026-07-31) is the recorded instance.
- **Not the only voice.** Mentl's substrate voice (per-tentacle, derived from the graph) is the second voice. Two speakers per declaration; no editorial third.

**Dissolved:** the `//`-vs-`///` split. `//` was "the medium deliberately does NOT read this" — a category of prose the self-explaining, unsilenceable medium blinded itself to, contradicting `PLAN.md §0`. One form, all graph content, register projected.

### No block comments

Mentl does not have `/* ... */` block comments. Composability of the substrate means there's no need to disable large code regions; if code is unwanted, delete it. Version control preserves history.

---

## Strings

Surfaces primitive #1 (the sequence node-kind).

A string is a **sequence of bytes** — `String = [Byte]` (`PLAN.md §4①`), not a
primitive. There is **ONE string form**, `"..."`, and interpolation is **always
live**:

```
"hello"
"with newline\n"
"escaped quote: \""
"result is {a + b}"
"hello, {name}!"
```

**Interpolation is a graph edge, not runtime substitution.** A `{expr}` splice
carries the spliced node's type, **effect row**, and (under the IFC frontier,
`§4⑥`) flow-label up into the enclosing string-construction expression: so
`"{network_call()}"` adds `Network` to the row, and `"{secret}" ~> Log` is a
provable non-interference violation — not a runtime surprise. Splice rendering
dispatches `to_string` structurally at lower from the spliced node's inferred type
(the `++`/`==` proof-becomes-dispatch precedent — no `Show` trait-bound).

**Literal braces** are `\{` and `\}` — a region the splice-scanner skips — never
brace-doubling and never a second delimiter.

**Escape codes:** `\n`, `\r`, `\t`, `\\`, `\"`, `\{`, `\}`, `\0`, `\xHH` (hex byte).

### Multi-line

`"""..."""` is the multi-line variant of the one form (interpolation still live);
leading whitespace common to all lines is stripped (indentation-aware):

```
let block = """
  Hello, {name}.
  Your age is {age}.
"""
```

**Dissolved** (redundant-form + foreign fluency): the `'...'` literal form, its
`'''...'''` variant, and `{{`/`}}` brace-doubling. A splice-free `"abc"` and
`'abc'` produced an identical byte-sequence graph; literalness is a property of a
*region* (`\{`), read by the cursor — never a mode hoisted onto the quote
character (the Python/shell convention). One sequence kind ⇒ one string surface.

---

## Operator precedence

One canonical table. Higher number = tighter binding. **These are
the literal integers** returned by `op_prec` (src/parser.mn) — one
table, two projections (this spec and that fn), zero translation; the
seed's third projection retired with the seed. Structural forms (call
`f(args)`, field access `.`, indexing, unary `-`/`!`) bind tighter
than every binary operator; `=` in let and `=>` in lambda sit at
statement level — neither participates in the binop ladder.

| Prec | Operators                                | Associativity   | Notes                          |
|------|------------------------------------------|-----------------|--------------------------------|
| 10   | `*`, `/`, `%`                            | left            |                                |
| 9    | `+`, `-` (binary)                        | left            |                                |
| 8    | `++`                                     | left            | one `seq_concat` over the sequence kind; associativity immaterial under the concat-tree representation; see §"Concatenation operator" |
| 7    | `<`, `>`, `<=`, `>=`                     | left            | comparison                     |
| 6    | `==`, `!=`                               | left            | looser than comparison: `a < b == c < d` reads as `(a<b) == (c<d)` |
| 5    | `&&`                                     | left            | SHORT-CIRCUITS: `a && b` ≡ `if a { b } else { false }` — the right operand evaluates only when the left is true, so a guard protects the read it guards (`pos < n && set[pos] == x` is sound) |
| 4    | `\|\|`                                   | left            | SHORT-CIRCUITS: `a \|\| b` ≡ `if a { true } else { b }` |
| 3    | `\|>`                                    | left            | sequential pipe — looser than all value operators: `a == b \|> f` pipes the comparison |
| 2    | `<\|`, `><`, `<~`                        | left            | convergent verbs — they draw shape around chains |
| 1    | `~>`                                     | left (loosest)  | handler-attach floor — governs the whole chain to its left |

`~>` deliberately has the LOWEST precedence so the handler at the
foot of a chain captures everything to its left as its body — the
one law of `~>` (§tee). Nonsense same-tier chains (`a < b < c`)
are not a parser concern: inference rejects them with a typed
Reason chain (`TBool` vs operand type), which localizes better
than any associativity rule could.

### Concatenation operator

`++` is **one total `seq_concat`** over the sequence node-kind — element-agnostic
over the unified `[len][bytes]`/view record (`PLAN.md §4①`, §6). There is no
`String`-vs-`List` dispatch because there is no split: `String` IS `[Byte]`, so
`"ab" ++ "cd"` and `[1, 2] ++ [3, 4]` are the same operation on different element
types.

The graph carries the element type only to **typecheck that the operands' element
types unify** (ordinary HM unification) — never to choose the operator. So an
operand of not-yet-resolved element type is an open `[?a]` that **still
concatenates**; "unresolved operand" is not a failure mode. Element-type mismatch
(`[Int] ++ [Bool]`) surfaces as an ordinary unification failure with a Reason
chain back to the `++` site — **`E_ConcatTypeMismatch`**, a type error, not a
dispatch artifact.

**Drift-refusal preserved:** `++` never fabricates a result for a genuinely
untypable operand — it surfaces the unification failure with a Located reason (the
no-silent-fallback law, `protocol_no_silent_fallback`). **Dissolved:** the
`list_concat`-vs-`str_concat` dispatch table and `E_ConcatTypeUnresolved`
(`(unreachable)` when lower couldn't pick a representation) — both existed only to
choose between two representations the unified ontology does not have. A
representation gradient (packed-byte vs boxed) is a lower-time cash-out of the
proven element type, invisible at the surface, never two surface operators.

### Equality operator

`==`/`!=` are **one structural-equality derivation**, directed by the operand's
element/field type (read at emit from the graph). There is no rule to remember and
no representation split — `String` is just the `[Byte]` instance of the sequence
case (what was `str_eq`):

| Operand shape                              | Structural-eq projection                          |
|--------------------------------------------|---------------------------------------------------|
| scalar (`Int`, `Bool`, byte, nullary tag, address) | `i32.eq` / `i32.ne` — value equality IS structural |
| sequence (`[a]`, incl. `String = [Byte]`)  | length-then-element recursion (`[Byte]` case is byte-compare) |
| product (record / tuple)                   | field-wise recursion over the sorted field set    |
| sum (ADT)                                  | tag-equality then payload recursion               |

The ordering operators `<` `<=` `>` `>=` are the same derivation with a 3-way
leaf: a word orders by its value (an address by its magnitude, §«Addresses»),
a sequence length-then-element, a product field-wise, and a sum by its
variants' DECLARATION order first and its payloads second — so over `type T =
B(Int) | A`, `B(5) < A` holds (real, 2026-10-03: the generated compare had
ranked a nullary variant's word against the other operand's address, and that
program answered the opposite with no diagnostic).

**Drift-refusal preserved:** `==` on a heap value never emits pointer comparison —
pointer-eq lying as structural equality is the silent fallback
`protocol_no_silent_fallback` forbids. The derivation is **total over the five
node-kinds** (the `Hβ.eq.structural-deep` peer is this general definition realized,
not a carve-out); `str_eq` is the byte-sequence instance the surface `==` lowers
to, never a developer-facing primitive.

**TWO MEASURED HOLES IN THAT TOTALITY, both CLOSED.** (1) An operand whose
type is still a VARIABLE where the comparison is emitted has no structure to
read, and the one-word compare it would fall to is an address lie for
anything but a word. It REFUSES (real, 2026-09-28): `E_ShapeUnprovable`,
armed, said at the comparison before a byte of the module exists — the same
refusal a show, a hash and a `++` of such an operand take
(`Hβ.emit.eq-on-unresolved-operand-is-pointer-eq`, closed). It had narrated
as `T_EqTypeUnprovable` since 2026-09-18, and the class could not arm while
it was decided during emission, after the gate had read the ledger.
(2) A POLYMORPHIC sum compared its payload by ADDRESS — `Some(BInt(7)) ==
Some(BInt(7))` was false while the monomorphic `BInt(7) == BInt(7)` was true —
because the generated helper was keyed on the nominal name alone and the
constructor's declared payload type is the quantified var. CLOSED the day it
was measured (2026-09-18, `Hβ.eq.polymorphic-sum-payload-is-pointer-eq`): the
sig folds its arguments so each instantiation names its own leaf, and the
specs ground against them, so the payload recursion calls its own type's
helper. `tests/frontier/mn-eq-polymorphic-sum.mn` holds the contract with its
monomorphic control beside it. The entry stays written here because its
blindness is the transferable half: (2) was invisible to (1)'s census, whose
count held unchanged across the whole discovery, because the unprovable
operand sat inside a generated leaf rather than at an authored comparison. A
census that measures one surface does not see the same class one layer in.

### Arithmetic operators

`+ - * / %` and unary `-` unify their operands and DEMAND one more thing of
them: a number. The demand is a constraint on the operand's type CELL — the
gate mechanism's second arm, beside the row gate (§«Negation in `with`
clauses») — and the operand's cell decides:

| Operand's cell                                | Arithmetic's verdict                           |
|-----------------------------------------------|------------------------------------------------|
| bound to a word (`Int`, `Float`, `Byte`, an alias or refinement of one, a `repr` pin) | the instruction at the operand's repr — `i32.*` at the floor, `f64.*`/`f32.*`/`i64.*` where the gradient or a pin says so |
| still FREE at the operator                    | the cell carries the demand (a `NumericGate`); the one writer judges whatever later enters it — a word passes, a variable inherits the gate, an aggregate refuses — and instantiation copies it onto the fresh var, so a generic `a * b` refuses `{x: 1}` at the CALL that instantiates it |
| bound to a product / sum / sequence / function / continuation / unit, or an address | `E_ArithOnAggregate` REFUSES at the judgment — arithmetic on an aggregate has no meaning the value ontology gives it; the operands are addresses, and an address moves by `addr_at` (§«Addresses») |

**THE THIRD MEASURED HOLE, closed 2026-09-27 in its second form.** The
arithmetic arm of the emit read only the operands' emitted WIDTHS, so a
record floored to a word and `{x: 1} * {x: 2}` multiplied the two ADDRESSES
with zero diagnostics, then trapped at run time reading a field off the
product (boot 5bf55b68, exit 134). The first form classified the operand's
TYPE at lower and again at emit under the twin bracket, narrated the
variable case and added a second gate after the emit for the generic one;
it passed every test, and the artifact refuted it twice before it was
pinned: `mentl check` still accepted both programs (only the executable
refused), and the wheel's own compile narrated the floor twin of a generic
`Option(t)` add "unproven" over a `t` the judgment had already seen added —
the emit re-deriving a fact inference held. The demand belongs to the
JUDGMENT, as a gate on the cell: `{x: 1} * {x: 2}` refuses at the operator
(`tests/frontier/mn-arith-on-aggregate.mn`); `scale({x: 1}, {x: 2})` over
`fn scale(a, b) = a * b` refuses at the argument edge that binds the copied
gate, naming `*`'s site (`mn-arith-on-aggregate-twin.mn`); a copy minted
before the demand — a signature'd fn's self-reference — is reached through
the instance column (`mn-arith-on-aggregate-instance.mn`); and `mentl check`
says so in every case. At emit nothing is decided: a word emits at its
type's repr, and a variable still free there is a FLOOR twin's quantified
var — every wide instantiation, through a reference included
(`tests/micros/mn-arith-generic-ref-float.mn`), minted its own twin and
bound the var under it — so it is a word at the floor width by
construction, and the arithmetic narration class the first form minted no
longer exists. Arithmetic on a USER type is not pointer arithmetic and not
a trait: it arrives as a numeric projection's rules
(`Hβ.lower.ad-is-a-demanded-projection`), the same mechanism that makes a
chain differentiable.

### Addresses — the word that names memory

An address names memory: the raw memory operations read from and write to
one (lib/memory.mn's `Memory`). Its type is `Addr`, and it is a word in every
machine respect — one i32, equal by identity, hashed as itself — and NOT a
number (real, 2026-10-03). `alloc` and `heap_mark` answer one, `Cast`'s `addr`
answers the address a value lives at, and every raw load and store takes one:

| An address…                       | …is                                                         |
|-----------------------------------|-------------------------------------------------------------|
| compared `==` / `!=`              | identity: two allocations are two addresses                 |
| ordered `<` `<=` `>` `>=`         | by MAGNITUDE — wasm32's memory runs to 4 GB, so one past 2 GB is above one below it, where the signed order of an Int would put it under |
| shown (`"{p}"`)                   | the unsigned number it names (`4294967280`, never `-16`)    |
| in arithmetic (`p + 8`, `8 + p`)  | refused, one `E_ArithOnAggregate` at the operator whichever side it stands on: it moves by `addr_at(p, 8)` and is measured by `addr_diff(q, p)` |
| read and written                  | `load_addr` / `store_addr`; a byte, a word or a float at it through the raw loads and stores |
| at a word slot                    | `addr_word` / `word_addr`, the identity on the machine, where a value crosses the runtime's word protocol |

The type is what an arena's exit reads (§`~>` — lib/arena.mn): an address of
the arena's region found where the exit looks — the arena's value, a field, an
element, a slot `store_addr` wrote into older memory — keeps the region, since
nothing can say what the address names; held as an Int it was copied as a
number and the cell reclaimed under it, silently. What stays the program's
own claim is a NUMBER made from an address — a pun through `addr_word`, or a
distance added to one — since a number names nothing an exit could read.

A raw copy carries bits, and bits carry no type, so the exit never reads one
as an address: a `mem_copy` that writes memory older than an open arena keeps
that arena's region whatever the bytes were. A store that says what it
stores is how a program keeps an arena reclaiming past it — a float into a
packed list moves nothing on its account, and neither does a byte, a word
or a float stored through the raw stores.

---

### Partiality — a primitive's precondition is a claim, and an open claim is a row fact

Integer `/` and `%` are PARTIAL: the substrate traps on a zero divisor, and
`/` also on `INT_MIN / -1`, the one quotient a signed word cannot hold (`%`
answers 0 there). The medium never totalizes them — a fabricated 0 for a
division by zero is the surrender fallback `CLAUDE.md` forbids — and it never
lets a trap hide either. Each site raises its precondition as the claim it
is, decided by `Verify`'s fragment from what the graph holds about the two
operands, with three outcomes (real, 2026-09-30):

| The claim at `a / b` | Outcome |
|---|---|
| a constant divisor that is not 0 (and, for `/`, not -1 — or a constant dividend that is not INT_MIN) | PROVEN — the site charges nothing |
| a constant zero divisor (`1 / 0`), or `INT_MIN / -1` by constants | REFUSED — `E_RefinementRejected` at the site: the program's meaning is a trap |
| a divisor one of whose sources IS the fatal point — a join's tail (`100 / (if c { 5 } else { 0 })`), an installed arm's answer (`100 / ((…) ~> zero)` with `zero` answering `0`) | REFUSED — the text writes the trap on that tail, as a claim over a join refuses at the tail that folds false (real, 2026-10-03; such a tail answered OPEN before, debt where the refutation names the cause) |
| a divisor whose every source EXCLUDES the fatal point — a constant, a length, or a parameter whose refinement does (`Positive` (`0 < self`) excludes 0 and -1; `NonZero` (`self != 0`) excludes 0, so it proves `%` outright and `/` only beside a dividend that cannot be INT_MIN) | PROVEN — and where it stands on a parameter's refinement, the `Trap` waits in that parameter's guard, paid by a caller whose argument claim is open |
| a module value bound to a constant (`let lanes = 4`) | PROVEN — the fragment reads the let's own node |
| anything else — a parameter nothing bounds, a local, a call | OPEN — the site charges **`Trap`** into the row |

`Trap` is the effect the substrate performs when a partial primitive's
precondition fails (`effect Trap {}`, the prelude — no operations, nothing
handles it, and its absence is the whole point of naming it). It is a row
fact like `Alloc`: inferred and projected (`fn ratio(t, n) = t / n` renders
`-> Int with Trap` at the address surface), transitive through calls, and
provable absent — `fn ratio(t, n) with !Trap = t / n` refuses
`E_EffectMismatch`, `fn ratio(t, n: Positive) with !Trap = t / n` accepts.
The gradient PROPOSES the annotation (real, 2026-10-02): at `fn inv(n) =
100 / n` the Teach facet names `n: NonZero` — the refinement in the module's
reach that discharges the claim and that every call of `inv` satisfies — and
`mentl accept <file>:<line>:<col>` at the declaration writes it, over a
written `n: Int` too; where two refinements prove the same and the calls
cannot choose between them it asks which is meant, and where none in reach
states the claim it says the predicate the parameter needs. The refinement
on the divisor is the input that unlocks the proof — lib/dsp's six
divisions by a hop or a grid width are proven by one refinement on the
parameter (`hop: Positive`,
`num_high: Positive`), and each caller pays the claim once, at the
argument: a literal folds, and a computed value is honest debt that pays the
guarded `Trap` at the call (`inv(m + 1)` under `!Trap` refuses; P0,
§«Refinement types»). Whether the type excludes a point is asked of
the refinement itself — its predicate decided with `self` bound to that
point — so any refinement the fragment can decide at a constant serves,
never a name-allowlist of "nonzero-ish" types.

The e-graph reads the same fact: `x * 0 ≡ 0` drops its operand only when the
operand's subtree row is pure, and a division whose claim stays open is not,
so `(1 / n) * 0` traps at `n = 0` as written. Until this landed the purity
gate read the operand's SHAPE — arithmetic over a literal and a variable —
and that program answered 0 (measured on boot 21f8e691).

What the fragment cannot yet read, named: a guard on the PATH (`if b == 0 {
None } else { a / b }` — the narrowing the walk computes and never writes,
`Hβ.verify.partiality-reads-the-path-narrowing`; the wheel's five open
claims, in `fold_int`, `litval_arith` and `pick_from_pool`, are all of this
shape), and the other partial
primitives — an index out of range (`xs[i]`, whose precondition needs the
same path read), a slice past its sequence — which are the same law one
primitive over (`Hβ.effects.index-partiality-is-a-row-fact`). Non-termination
is not a trap and not in the row (`Hβ.effects.divergence-is-a-row-fact`).

---

## Canonical layout (formatter canon)

Layout is never semantics. The precedence table alone draws the
tree; the formatter projects the canonical shape at save. Nothing
below is parser-enforced — it is what `mentl fmt` writes.

### Sequential verbs at LEFT EDGE

`|>` and `~>` sit at the left edge of the code's enclosing indent. Each stage on its own indented line:

```
input
  |> stage_a
  |> stage_b
  ~> handler
```

### Convergent verbs at INDENTED CENTER

`<|`, `><`, `<~` sit at indented center (typically 4-space indent from the enclosing left-edge):

```
(branch_a)
    ><
(branch_b)
```

```
input
  <| (
    branch_a,
    branch_b,
  )
```

### Return to LEFT EDGE for continuing chain

After a convergent construct, the chain returns to the left edge — and
the fanout that feeds it is PARENTHESIZED, because the precedence table
demands it: `|>` (3) binds tighter than `><` (2), so an unparenthesized
`a >< b |> mix` pipes into the LAST BRANCH (`a >< (b |> mix)` — probed
with a value at the Phase 3.4 truing: `(1) >< (2) |> inc` runs as
`(1, inc(2))`, never `inc((1, 2))`). The parens are the source's own
requirement; the formatter renders them:

```
((audio |> compress)
    ><
(ctrl  |> scale))
|> mix          // returns to left edge — consuming the WHOLE fanout
~> sink
```

### Indentation discipline

**The medium handles formatting; the developer types meaning.**

Mentl's canonical layout: 2-space indent for left-edge verbs (`|>`, `~>`, `<|`); 4-space indent for indented-center convergent verbs (`><`, `<~`). The shape on the page IS the computation graph because the formatter projects it there (governing principle 1).

**Formatter canon** (the shape `mentl fmt` writes — NOT a parse rule; the parser has one precedence table and ignores whitespace entirely):
- Left-edge verbs render indented MORE than their input.
- Convergent verbs (`><`, `<~`) render at least as indented as the left-edge verbs of the same chain.
- Each stage of a `|>` / `~>` chain renders at the SAME indent as its peers.
- Within a `<|` branch tuple, branches render at the SAME indent as each other.

The parser accepts any whitespace; the precedence table alone draws the tree (chain-link-5, `protocol_parse_is_eager_graph_projection.md`). Tabs are converted to spaces at save. Indent is a render decision, never a parse contract — there is no ill-indented program, only un-normalized source the formatter has not yet touched.

**Render rule** (canonical):
- The formatter renders code in canonical 2-space / 4-space form on save.
- **A render that would lose what the author wrote is not written** (real, 2026-09-28). `mentl fmt` lexes its render beside the source and spends every identifier, literal (by value, so `48_000` and `48000` are one) and prose line of the source against the render's; anything left unpaid is a loss, the verb names it with its line, leaves the file untouched, and exits nonzero. Until then the gate counted prose alone and wrote whatever it rendered: it deleted an effect parameter's annotation (`rate: Int`), an op parameter's name (`msg: String`) and a pinned alias's base (`Float repr f64`) while reporting "prose conserved", and it wrote a lossy render of a file that did not parse.
- **The head of a postfix form keeps its parens** (real, 2026-09-28). A call, a field read and an index bind tighter than every operator, so a callee, a receiver or an indexed value that is anything but an atom renders parenthesized: `(r |> keep).level`, `((a, b) => a * b)(2, 3)`, `([1, 2] ++ [3, 4])[2]`. Rendered bare, the re-parse takes the postfix onto the head's last operand — `(run() ~> h).beta` came back as `run() ~> h.beta`, an install of `h.beta`, under "names conserved", because no name was lost. The census of names cannot see a moved operand; a render that re-parses to a different tree is not yet refused (`Hβ.fmt.render-must-parse-to-the-same-tree`).
- The `Format` effect at `src/format.mn` declares `format_program` / `format_at_handle` / `format_chain` ops; `format_default` is the canonical handler.
- `mentl edit` (built-in) auto-formats continuously — keystroke triggers parse → format → render. The developer never sees badly-indented code because the medium normalizes before display.
- The LSP transport (external editors via VS Code / vim / Emacs) provides format-on-save through the same `format_default` handler, different transport.
- Tabs in the on-disk file are converted to spaces at the next save; the renderer's indent-width preference is per-developer (editor setting), but the file on disk is canonical for L1 byte-identity and version-control determinism.

**Composition**: the formatter is a `~>` handler in the cursor stack:

```
keystroke
  |> tokenize
  |> parse_to_graph
  ~> format_default
  ~> render_to_transport
    <~ accumulate(graph)
```

Per `protocol_oracle_is_ic.md`: format is idempotent (`format(format(x)) == format(x)`), so the IC fixpoint converges in one iteration. The format problem dissolves into the cursor projection.

---

## Top-level program structure

A `.mn` file is a sequence of top-level statements. Each is one of:

- `import path/to/module` — module imports
- `type Name = ...` — type declarations (ADTs, aliases, refinements, named rows)
- `effect Name { ... }` — effect declarations
- `handler name(...) with ... { ... }` — handler declarations
- `fn name(...) = ...` — function declarations
- `let name = ...` — top-level value bindings (constants)

A `.mn` file with no `main` function is a LIBRARY module — its declarations are imported by other modules. Compilation produces a WAT module whose `_start` is a clean exit.

A `.mn` file with `fn main()` is an EXECUTABLE — `_start` invokes `main`.
Its module value lets run first, so what an init performs is the
executable's: an effect no handler serves refuses at the let as it would in
`main` (real, 2026-10-02 — `let x = op()` compiled and trapped at init
before). `main`'s declared row judges `main` alone
(`Hβ.effects.executable-row-includes-inits`).

---

## Token enumeration

The lexer emits a stream of `Token` values. The parser consumes them via exhaustive match. Both the wrapper shape and the variant enumeration are canonical here; the parser implements them exactly.

### Token wrapper — substrate-native pattern

```
type Token = Tok(TokenKind, Span)
```

This mirrors the `N(NodeBody, Span, Int)` wrapper for AST nodes: a structured-value with positional metadata. Every token carries its source span for parser diagnostics and downstream Located reasons.

Accessors:
```
fn token_kind(t) = let Tok(k, _) = t; k
fn token_span(t) = let Tok(_, s) = t; s
```

### TokenKind variants — exhaustive

```
type TokenKind
  // ─── Keywords ─────────────────────────────────────────────────────
  = TFn | TLet | TIf | TElse | TMatch | TType
  | TEffect | THandler | TWith
  | TResume
  | TImport | TWhere
  | TOwn | TRef | TPure
  | TTrue | TFalse
  // Note: `loop`, `break`, `continue`, `return`, `for`, `in` are NOT
  // reserved keywords — Mentl has no imperative control flow constructs.
  // Iteration is via `|>` + `<~` + `Iterate` effect handlers.
  // Early-exit is via `Abort` effect + `catch_abort` handler.
  // The gradient teaches the substrate at the friction-point: when a user
  // types `for x in xs`, `E_NotAKeyword` surfaces a Quick Fix to the
  // verb form `xs |> each((x) => ...)`.
  // ITERATION IS TOPOLOGY, stated whole (2026-07-30): structural walks
  // are derived folds/`each`/`map` over the data's shape, cycles are
  // `<~`, search is handler resumption. Named recursion stays LEGAL —
  // but an index-threaded self-call (`f(xs, i + 1, n)`) is the
  // imperative loop in recursion's costume (`mentl audit`'s
  // iteration-shape tier names it), and polymorphic recursion prices a
  // signature (the with-clause/annotated form — inference there is
  // undecidable, the price is real math).

  // ─── Identifiers and literals (carry payload) ─────────────────────
  // Constructors share ONE namespace (env entries). The literal-token
  // trio is named TIntLit/TFloatLit/TStringLit because Ty's canonical
  // nullary TInt/TFloat/TString (the canonical Ty enumeration) already claim the bare names —
  // two declarations claiming one constructor name shadow silently and
  // mis-unify (the 2026-06-09 "expected Ty, found TokenKind" ×95 class).
  | TIdent(String)
  | TIntLit(Int)
  | TFloatLit(Float)
  | TStringLit(String)
  | TComment(String)                // // — every comment is graph content,
                                    //   attached to the next decl / enclosing node
  | TStringPart(String)             // literal chunk of an interpolating "..."
                                    //   string (amendment-C brace scan)
  | TStringSplice                   // marks the start of a `{expr}` splice;
                                    //   ordinary tokens follow, TRBrace closes

  // ─── Two-character operators ──────────────────────────────────────
  | TEqEq | TBangEq | TLtEq | TGtEq          // comparison
  | TArrow | TFatArrow                       // -> and =>
  | TPlusPlus                                // ++ concat
  | TPipeGt | TLtPipe | TGtLt | TTildeGt | TLtTilde   // five verbs
  | TAndAnd | TOrOr                          // logical
  // `::` is NOT a token. Module paths use `/` at import position;
  // `.` is the one access operator in expressions. A token with no
  // kernel correspondence is speculative inventory.

  // ─── Single-character operators and punctuation ───────────────────
  | TLParen | TRParen | TLBrace | TRBrace | TLBracket | TRBracket
  | TComma | TDot | TColon | TSemicolon
  | TPlus | TMinus | TStar | TSlash | TPercent
  | TEq | TLt | TGt | TBang | TAmp
  | TPipe | TAt | THole

  // ─── Layout / structural ──────────────────────────────────────────
  | TNewline                        // statement separator; transparent around binops (layout is never semantics)
  | TEof                            // end of input — always last
```

### Variant catalog (canonical lexical form, payload, expected parse contexts)

| Variant         | Lexical form     | Payload   | Where parser expects it                       |
|-----------------|------------------|-----------|------------------------------------------------|
| **Keywords (17)** |                |           |                                                |
| `TFn`           | `fn`             | —         | start of function declaration / lambda         |
| `TLet`          | `let`            | —         | start of let-binding                           |
| `TIf`           | `if`             | —         | start of if-expression                         |
| `TElse`         | `else`           | —         | between if branches                            |
| `TMatch`        | `match`          | —         | start of match-expression                      |
| `TType`         | `type`           | —         | start of type declaration                      |
| `TEffect`       | `effect`         | —         | start of effect declaration                    |
| `THandler`      | `handler`        | —         | start of handler declaration                   |
| `TWith`         | `with`           | —         | effect clauses, handler state, handle-with     |
| `TResume`       | `resume`         | —         | inside handler arm body                        |
| *(removed)*     | —                | —         | `for`, `in`, `loop`, `break`, `continue`, `return`, and `perform` were previously reserved but are NOT Mentl keywords. Iteration uses pipe verbs + Iterate effect; early-exit uses Abort effect; ops are bare calls (`perform` dissolved 2026-08-08 — the peer executed). |
| `TImport`       | `import`         | —         | top-level import statement                     |
| `TWhere`        | `where`          | —         | refinement type clause                         |
| `TOwn`          | `own`            | —         | parameter ownership marker                     |
| `TRef`          | `ref`            | —         | parameter borrow marker                        |
| `TPure`         | `Pure`           | —         | `with Pure` declaration                        |
| `TTrue`         | `true`           | —         | Bool literal                                   |
| `TFalse`        | `false`          | —         | Bool literal                                   |
| **Identifiers and literals (7)** |  |           |                                                |
| `TIdent(s)`     | `[A-Za-z_][...]` | name      | variable refs, fn names, type names, etc.      |
| `TIntLit(n)`    | `[0-9][0-9_]*`, `0x[0-9A-Fa-f_]+`, `0b[01_]+`, `0o[0-7_]+` | i32 value | integer literal (decimal / hex / binary / octal; underscores allowed for readability) |
| `TFloatLit(f)`  | `[0-9][0-9_]*\.[0-9][0-9_]*` | f64 value | floating-point literal (underscore separators allowed) |
| `TStringLit(s)` | `"..."` or `"""..."""` | string content (escape-resolved, interp markers preserved) | string literal (degenerate single-chunk interpolating string) |
| `TComment(s)`   | `// ...`         | comment text (contiguous lines concatenated, leading `//` stripped) | graph content; attaches to next decl / enclosing node |
| `TStringPart(s)`| literal chunk between splices in an interpolating `"..."` | chunk text | string interpolation (amendment-C brace scan → MakeStringExpr) |
| `TStringSplice` | start of a `{expr}` splice inside `"..."` | — | followed by ordinary tokens; `TRBrace` closes the splice |
| **Two-character operators (14)** |  |           |                                                |
| `TEqEq`         | `==`             | —         | equality comparison                            |
| `TBangEq`       | `!=`             | —         | inequality comparison                          |
| `TLtEq`         | `<=`             | —         | less-than-or-equal                             |
| `TGtEq`         | `>=`             | —         | greater-than-or-equal                          |
| `TArrow`        | `->`             | —         | function return type, fn-type form             |
| `TFatArrow`     | `=>`             | —         | match arm separator, lambda body separator     |
| `TPlusPlus`     | `++`             | —         | sequence concat (`seq_concat`)                 |
| `TPipeGt`       | `\|>`            | —         | sequential pipe                                |
| `TLtPipe`       | `<\|`            | —         | divergent pipe (fanout)                        |
| `TGtLt`         | `><`             | —         | parallel compose (structural N-ary)            |
| `TTildeGt`      | `~>`             | —         | handler-attach (the one install verb); `~` is consumed by maximal munch only into `~>`/`<~`, so a standalone `~` is an unexpected-char lex error (no bare-`~` token) |
| `TLtTilde`      | `<~`             | —         | feedback                                       |
| `TAndAnd`       | `&&`             | —         | logical and                                    |
| `TOrOr`         | `\|\|`           | —         | logical or                                     |
| **Single-character operators and punctuation (23)** |  |           |                              |
| `TLParen`       | `(`              | —         | grouping, params, tuples, calls                |
| `TRParen`       | `)`              | —         | close grouping                                 |
| `TLBrace`       | `{`              | —         | blocks, records, handler arms, type variants   |
| `TRBrace`       | `}`              | —         | close LBrace                                   |
| `TLBracket`     | `[`              | —         | list literals, list patterns                   |
| `TRBracket`     | `]`              | —         | close LBracket                                 |
| `TComma`        | `,`              | —         | separator in tuples, params, fields, lists     |
| `TDot`          | `.`              | —         | field access                                   |
| `TColon`        | `:`              | —         | type annotation, record field binding          |
| `TSemicolon`    | `;`              | —         | canonical-never — newlines separate statements; lexed so the formatter can lift it to newline layout (`E_StatementSemicolon`) |
| `TPlus`         | `+`              | —         | addition; effect union                         |
| `TMinus`        | `-`              | —         | subtraction; unary negate                      |
| `TStar`         | `*`              | —         | multiplication                                 |
| `TSlash`        | `/`              | —         | division; module-path separator                |
| `TPercent`      | `%`              | —         | modulo                                         |
| `TEq`           | `=`              | —         | binding (let / fn / type)                      |
| `TLt`           | `<`              | —         | less-than comparison (no generic-param role — angle brackets retired; `f<T>(...)` parses as a comparison chain and the general unexpected-token / type-mismatch diagnostic teaches, never a bespoke turbofish lookahead) |
| `TGt`           | `>`              | —         | greater-than comparison (no generic-param role; see `TLt`) |
| `TBang`         | `!`              | —         | logical not; effect negation                   |
| `TAmp`          | `&`              | —         | effect-row intersection (`inter_row` — §«Named effect rows»); row-expression syntax only, no value-operator precedence |
| `TPipe`         | `\|`             | —         | type-variant separator; pattern alternation in match arms (the `\|x\|` lambda fence is rejected — `E_LambdaFence`) |
| `TAt`           | `@`              | —         | as-patterns: `name @ pat` binds the whole value AND destructures (§«As-patterns»); `@resume=` erased per inference-from-body |
| `THole`         | `??`             | —         | hole — the gradient's syntactic absence marker; Mentl's Synth proposes candidates filling the position. The Mentl Mono ligature renders `??` as the octagonal-socket glyph (8 sides ↔ 8 kernel primitives). Single `?` is no longer a token. |
| **Layout / structural (2)** |     |           |                                                |
| `TNewline`      | `\n`             | —         | statement separator; transparent around binops (layout is never semantics) |
| `TEof`          | (end of input)   | —         | always last token; parser uses to terminate    |

**Checksum: 63 variants** (17 keywords + 7 identifiers/literals + 14 two-char operators + 23 single-char operators/punctuation + 2 layout) — a reviewer cross-check that the `TokenKind` declaration and this catalog enumerate the SAME set; the hand-maintained stand-in for `mentl audit` until the cursor projects it from the graph. Exhaustiveness over the ADT (§Lexer/Parser obligations) IS the cardinality guarantee — the number is its shadow, not its source. (`TColonColon`, `TCapability`, `TTilde`, and `THandle` are absent: a token with no kernel correspondence is speculative inventory — and `handle` is the medium's own domain noun, not a keyword (§«Installation»). `TStringPart`/`TStringSplice` carry the interpolation substrate.)

### Lexer obligations

- **Every emitted Token MUST be a variant of the `TokenKind` ADT declared above** — exhaustiveness, not a magic number, is the law (the parser's exhaustive match, §Parser obligations, guarantees completeness). Adding a token kind means updating SYNTAX.md first, then the lexer, then the parser's match (which fails to compile until the new variant is handled — H6 at the lexical layer).
- **Whitespace (other than `\n`) is silently consumed.** The lexer skips spaces and tabs without emitting a token. Only newlines are semantic.
- **Comments `// ...` emit `TComment(text)`** (leading `//` stripped, contiguous lines concatenated). A comment is graph content — the parser attaches each to the following declaration / enclosing node; the medium never silently consumes prose. There is one comment form.
- **Block comments do not exist.** Per the Comments section of this spec.

### Parser obligations

- **Match on `Token` must be exhaustive.** No wildcard arms over `TokenKind` without explicit per-variant enumeration. H6's discipline: `_ => …` on a load-bearing ADT is rejected by code review and substrate convention.
- **Span propagation.** Every parsed AST node is constructed with the joined span of its constituent tokens. Use `span_join(token_span(first), token_span(last))`.
- **Angle brackets are retired; `<`/`>` are always comparison.** `<` and `>` are TLt/TGt everywhere. Generic type parameters are the lowercase-identifier convention (the case rule IS the declaration — §«Generic type parameters»); there is no angle-bracket parameter list in any declaration position. The parser does NOT carry a bespoke `ident<...>(` recognizer — a per-foreign-form scanner does not scale, and the parser has ONE precedence table + productive-under-error. A stale-fluency `f<T>(args)` parses as the comparison chain the precedence table draws (`<` is TLt), and the **general** unexpected-token / type-mismatch diagnostic teaches in context (a `TBool` where a callable was expected, with a Located Reason). The teaching surface is the one general diagnostic path, not a Rust-specific lookahead.
- **Pipe-vs-or disambiguation.** `|` is TPipe (variant separator in `type` body + pattern alternation in match arm body); `||` is TOrOr (logical or). No `|x|` lambda fence — lambdas use `(params) => body`.

### `if` without `else` — unit-returning conditional

An `if cond { body }` without `else` is legal when `body`'s type is unit `()`. The compiler inserts an implicit `else { () }`. Used for side-effect conditionals:

```
if should_log { log("message") }             // unit body — OK
if x > 0 { x * 2 }                            // non-unit body — E_IfMissingElse
```

Diagnostic on non-unit if-without-else: **`E_IfMissingElse`** with Quick Fix suggesting either adding an `else` branch or restructuring. Lowers the "forgot the else accidentally" class of bug to a compile error.

---

## Diagnostic catalog (syntax-level errors introduced by SYNTAX.md)

Mentl's diagnostics are TEACHING surfaces, not punishment — and a diagnostic IS a
**projection of the graph**, not a hand-maintained registry. Each is a `DiagKind`
constructor (`type DiagKind = ERedundantBraces(Span) | EEffectMismatch(EffRow, EffRow, Span) | …`)
carrying its **Located Reason edge** (arm 8) and its **Applicability**
(`type Applicability = MachineApplicable | MaybeIncorrect | HasPlaceholders | Unspecified`
— an ADT, never a string). The live catalog is `mentl diagnostics` walking those
constructors, the same way `mentl where`/`mentl audit` project; the tables below are
worked EXAMPLES at the forms where each is introduced, not the source of truth.

Two axes describe every diagnostic; the **category is their product, not a third
column** (drift-7 avoided): **severity** (error vs narration) and **applicability**
(the four-value ADT, which drives automation — `MachineApplicable` auto-applies,
`MaybeIncorrect` confirms, `HasPlaceholders` fills in, `Unspecified` is text-only). A
**Quick Fix is a draw-an-edge** the medium applies to the shared graph image, then
the IC cursor re-projects to show the resolved state and any newly-surfaced
downstream Reason — the same `<~ accumulate(graph)` loop the formatter uses. The
diagnostic surface IS a `~>` handler re-projecting the graph, exactly like
`format_default`. (Relocating diagnostic IDENTITY fully onto the `DiagKind` ADT — so
`report` takes a `DiagKind`, not strings, and these three tables become a projection
of `types.mn` — is the unsurpassable form, sequenced as the
`Hβ.diag.catalog-as-projection` follow-up.)

The three groupings below are **derived bands**, not authored law:
- **Format-liftable** ≡ `MachineApplicable` ∧ the redundant form has no graph node (next section).
- **Hard error** ≡ severity=error — a substrate violation the medium cannot auto-recover.
- **Gradient narration** ≡ severity=narration — Mentl's voice; accept or dismiss.

### Format-liftable (parse-canonicalized — no graph node to "strip")

Not a formatter strip-pass: a redundant form parses to the **same canonical graph**
as its minimal form, so it has no node by the time `format_default` runs — "lifting"
is the formatter projecting the canonical graph back, and the redundant input never
survives parse (`format(format(x)) == format(x)` because `parse(x)` already lost the
redundancy). A format-lift earns a (silent) code **IFF it removes/transforms a
graph-present artifact — a `TokenKind` the lexer actually emitted**. Whitespace
re-flow emits no token, so it carries no code — which is exactly why
`E_IndentMismatch` does **not** exist (there is no ill-indented program, only
un-normalized source the formatter has not yet touched).

*The silent lift is the DESIGN; the artifact's state, probed 2026-08-07:
`E_StatementSemicolon` is silent as designed, while `E_RedundantBraces`
still surfaces as a warning — it retires when the formatter's canonical
projection becomes the save path (the fmt sweep's payoff ratchet,
`RESIDUE.md`'s fmt entry), never by muting the reporter.
`E_RedundantPerform` is DELETED (2026-08-08): `perform` is no longer a
token, so there is nothing to lift.*

| Code                  | Trigger (an emitted token, removed/transformed)         | Canonicalization                                 |
|-----------------------|---------------------------------------------------------|--------------------------------------------------|
| `E_RedundantBraces`   | braces wrapping a non-`BlockExpr` (no statements)       | drop the braces; user sees no diagnostic         |
| `E_BlockNeedsBraces`  | statements (a `BlockExpr`) written without braces       | wrap the statements in `{ }`; user sees no diagnostic |
| `E_StatementSemicolon`| `;` between statements                                  | lift to newline layout; canonical text has no `;` |

### Hard errors (substrate violations)

| Code                  | Trigger                                       | Applicability        | Quick Fix                                      |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `E_PatternInexhaustive` | match missing variants, no wildcard — an alternation covers its branches, an as-pattern its inner pattern. ARMED 2026-10-03 (refuses the executable) | `HasPlaceholders`    | insert stubs for missing variants              |
| `E_RefinementRejected`| value violates refinement predicate — or a partial primitive's precondition refuted by constants (`1 / 0`, `INT_MIN / -1`; §«Partiality») | `Unspecified`        | adjust value or widen refinement               |
| `E_EffectMismatch`    | declared row doesn't subsume body row         | `MaybeIncorrect`     | widen declaration OR install absorbing handler |
| `E_PurityViolated`    | `with Pure` body performs non-empty effects   | `MaybeIncorrect`     | remove `with Pure` or absorb the effect        |
| `E_FeedbackNoContext` | `<~` used without iterative context — DECLARED, zero construction sites by design: the ambient-context requirement is a Faust inheritance the substrate never adopted (a `<~` prior is a per-site register advanced by the enclosing fn's next call), so firing it would refuse correct code. It becomes real when the clock is INFERRED (`Hβ.dataflow.clock-calculus-sample-rate`) | `MaybeIncorrect` | install an `Iterate`-class handler (`Sample`/`Tick`/`Clock`)        |
| `E_ZeroDelayFeedback` | `x <~ delay(0)` — a cycle with no delay: the prior would be the value being computed. ARMED (refuses the executable); one arm of the depth read, both the `delay` and `Delay` spellings | `MaybeIncorrect` | raise the delay to at least 1 |
| `E_ComputedDelayDepth` | `x <~ delay(n - 1)` — the depth is a runtime value. A feedback line is a fixed set of declared slots, so an unreadable depth cannot be held, and the site would silently get one slot. ARMED, the sibling arm of the same read | `MaybeIncorrect` | write the depth as a literal, or hold the history yourself |
| `E_OwnershipViolation`| `own` consumed twice / escapes ref scope      | `Unspecified`        | restructure to single-consume or use `ref`     |
| `E_UseAfterMove`      | a borrow-READ of a name the affine ledger already moved — the read half of affine beside `E_OwnershipViolation`'s consume half. ARMED 2026-09-15: it narrated while its own census held at zero (the arming law its decl and fixture both stated), and a narration held at zero is a counter standing in for a proof. Sound today only by accident: the heap frees only where an extent ends — an arena's exit, a reset — never at a `Consume`, so it is a use-after-free the day a `Consume` reclaims | `Unspecified` | drop the read, or restructure so the move happens after it — never a patch |
| `E_HandlerUninstallable` | handler arms need effects context disallows | `MaybeIncorrect`   | widen ambient row or restructure handler       |
| `E_HandlerInexhaustive` | a handler's arms answer some ops of an effect and not others (§«A handler is exhaustive») — an install absorbs every op of the effects its arms answer, so the missing op would escape the row and reach nothing at runtime. ARMED at birth, 2026-09-30, born at wheel-zero; the shape it refuses was a false absence proof that trapped | `HasPlaceholders` | add the arm; forward the op outward (`op(…) => resume(op(…))`); or declare the ops this handler answers as their own effect |
| `E_ThreadedBranchEffect` | under a threaded schedule, a branch's row carries an effect whose covering handler at the fanout's frame — or, for a fanout a caller's schedule demands, along the demand's chain of installs, the callback parameter's row read at the instantiating site — writes its state (`resume … with`), lies beyond the frame fence with no demand reaching it, or reaches such a handler through its own arms (§`><`). ARMED, born at wheel-zero | `MaybeIncorrect` | install a handler that writes no state at the fanout's frame, or install the handler inside the branch |
| `E_ContinuationUncapturable` | a held or multi-shot perform standing where its continuation cannot be captured: not the first work of its function, block or arena — bound by a `let`, past a statement, after an operand that does work (§«Where a continuation is captured»). Said at the settle point over the emitted reach, so a body nothing runs is never refused. ARMED at birth, 2026-10-03: it compiled clean and trapped at a runtime floor no diagnostic named (exit 134) | `MaybeIncorrect` | move the perform to the front of its function, block or arena, or move what precedes it into a function the perform's function calls |
| `E_DerivativeUnreachable` | a `d(v)` under a derivative reading whose argument's tangent was lost — into an aggregate, across a multi-shot perform, off a line ticked by forward code or a line a closure record owns, or through another `d` — a mint, an install or a state write under the reading that would store a lost tangent into a record, or a reading whose seed is not a Float variable in scope (§`~>`). The message names the loss site. ARMED at birth: the alternative is a slope of zero the program never has | `Unspecified` | keep the value out of the aggregate until it is asked for, or seed the reading at a Float variable |
| `E_MissingVariable`   | name not in scope                             | `MaybeIncorrect`     | check spelling; check imports                  |
| `E_ImportNameCollision` | two selective imports bind the same name    | `MaybeIncorrect`     | narrow the selective sets so each name binds one edge |
| `E_MissingImport`     | a name resolves only because the whole link carries it: declared at module level in a module the referencing module never imports, directly or transitively (the prelude's closure is ambient — the driver links it into every compile). ARMED at birth, 2026-09-27: the per-module solo sweep as one read of the one judgment, naming both modules at the reference | `MaybeIncorrect` | add `import <declaring module>` to the referencing module |
| `E_UnknownArgLabel`   | a labeled arg names no declared parameter     | `MaybeIncorrect`     | check the label against the parameter names    |
| `E_TypeMismatch`      | unification failed — the message carries the Reason the unify was asked with, past the diagnostic's own span (`Int vs List(Byte) — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler h`; real 2026-10-03 — the reporter had taken the reason and dropped it, so a mismatch said its two types and nothing of why they met) | `Unspecified`        | adjust types; widen / narrow                   |
| `E_OccursCheck`       | infinite type                                 | `Unspecified`        | restructure to break cycle                     |
| `E_OrphanHandlerAttach` | `~>` with no preceding chain                | `Unspecified`        | delete `~>` or supply body                     |
| `E_PipeIntoComplete`  | `x \|> f(…)` where `f(…)` has no hole (already a complete value, not a `A -> B`) | `MaybeIncorrect` | leave a hole for the piped value (drop an arg or mark it `??`) |
| `E_PipeHoleAmbiguous` | `x \|> f(…)` where `f(…)` has more than one hole and none is marked `??` | `MaybeIncorrect` | mark the pipe's target field with `??` (`x \|> clamp(0, ??, 255)`) |
| `E_NotAKeyword`       | user typed `for`/`while`/`loop`/`break`/`continue`/`return` | `MaybeIncorrect` | rewrite as verb form per substrate             |
| `E_PatternAlternationBindingMismatch` | branches in `\|` bind different names or types | `MaybeIncorrect` | adjust patterns to bind same names with unifiable types |
| `E_ResumeOutsideArm`  | `resume` outside a handler-arm body           | `Unspecified`        | move the resume into an arm; the continuation only exists there |
| `E_ResumeWorldMismatch` | two continuations (`TCont(R, S, discipline, world)`) unify with incompatible resume DISCIPLINES — OneShot and MultiShot are distinct representations (stack frame vs heap record), so the mismatch is hard; `Either` unifies with either. The WORLD half is the row unification in the same TCont arm (`!E` lifted to the TIME axis, §4③); its dedicated runtime raise (`E_ResumeWorldMismatchWorld`) is declared but not yet wired — lathe-lag, band B | `MaybeIncorrect` | align the handler arms' resume cardinality; for a world clash, re-install the absorbing handler before the resume OR widen the continuation's world |
| `E_ConcatTypeMismatch` | `++` operands' element types fail to unify (e.g. `[Int] ++ [Bool]`) | `MaybeIncorrect` | unify the element types |
| `E_DeclaredRowContradiction` | one authored clause asserts a name present AND absent (`with E + !E`, instance-aware — a bare present beside an instance absent stays a refinement). Reported at the signed fold BEFORE the meet's drop; ARMED (refuses the executable): the pre-diagnostic meet let a performing body check clean under a declared `!E` | `MachineApplicable` | drop one side of the contradiction |
| `E_ArithOnAggregate`  | `+ - * / %` or unary `-` whose operand is a product, sum, sequence, function, continuation or unit — the operands are addresses and the arithmetic would be on where the values live. ARMED at birth (the wheel's census is zero): judged at the operator for a bound operand and at the one writer for a gated cell bound later (a `NumericGate` on the cell, copied at instantiation, reached through the instance column), so the judgment refuses, `mentl check` says so, and no WAT streams. Until 2026-09-27 it compiled and multiplied the addresses | `Unspecified` | give the operand a number (a word) or read the field you meant |
| `E_UnresolvedHole`    | compiling an EXECUTABLE whose reachable emitted tree carries an authored value-position `??` (§«Partial application» — a hole is productive for check/edit, never an executable value; a parameter-product `??` is an executable suspension and runs). Raised by the executable gate between reachability and emit: nonzero exit, zero WAT bytes, the authored weave span on the diagnostic | `HasPlaceholders` | fill the hole (accept a Synth survivor) or suspend it into a parameter product |
| `E_FieldOffsetUnprovable` | a field read or a record pattern whose receiver's row never closed where the body is emitted — no field set, so no slot. Said at the SETTLE POINT: the plan's emitted reach asks it of every body under the bracket that body is emitted in, a base at the floor and a twin under its own pairs, before the gate reads the ledger, so the compile exits 1 with zero WAT bytes. ARMED 2026-09-28 at wheel-zero. It narrated as `T_FieldOffsetUnprovable` from 2026-09-15 and could not arm while it was decided during emission, after the gate: a program carrying one compiled clean and trapped at the instruction that admits it (`tests/micros/mn-payload3.mn`, exit 134 on every boot before the arming) | `MaybeIncorrect` | close the receiver's row — annotate it at its Intent Boundary, or give the call site a shape its specialization can key on |
| `E_ShapeUnprovable` | a comparison, a show, a hash or a `++` whose operand is still a type VARIABLE where it is emitted: nothing proves the shape the read needs, and the word reading it would fall to is an address lie for anything but a word. Said at the settle point beside its row sibling and ARMED with it (2026-09-28). The eq and show narrations it replaces (`T_EqTypeUnprovable`, `T_ShowTypeUnprovable`) counted two sites on the wheel, both `list_compare_loop` reading its elements through the typed `list_index`; it reads the words the emit's by-name call guarantees, and the count is zero | `MaybeIncorrect` | prove the operand — give the call site a shape its specialization can key on, or name the type at its Intent Boundary |
| `E_InstantiationDepth` | a reference eight instantiations deep in a recursion whose type grows with every call, reaching a callee that READS the growing structure (a comparison, a show, a field — or a number). Monomorphization cannot specialize without bound, and the ninth level would read the structure as a word, so the settle point refuses there. ARMED at birth (2026-09-28): two ten-deep lists compared unequal and a nested show printed an address before it. A wide value nothing reads crosses the word protocol boxed and back, and is admitted | `Unspecified` | recurse over a type that keeps its shape, or leave the growing part unread |

### Gradient narration (teaching surfaces)

| Code                  | Trigger                                       | Applicability        | Action                                          |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `T_OverDeclared`      | a declared bare positive name beyond the proven row (the positive half only — a negation is a proof claim, never over-declared) | `MachineApplicable`  | `mentl tighten` writes the clause's residue |
| `T_RowInventory`      | a declared clause whose bare positive names are exactly what the body proves, or a positive cap over an OPEN body row (which installs no gate and so constrains nothing) — the projected row written by hand (§«A signature is not an inventory») | `MachineApplicable` | `mentl tighten` writes the residue — negations, instance pins, or no clause |
| `T_WordSlotBox`       | a wide value (a Float) boxed into a fresh cell to cross a callee's slot sized for a word — a list primitive's element (`list_set`) — inside a unit whose row does not say `Alloc`: the representation's cost, not the program's, until the slot takes the value's own width (`Hβ.value.seq-element-stride-carrier`). Said at the settle point by the allocation audit, which refuses every allocation that IS the program's | `MaybeIncorrect` | keep the value at a word's width where the slot is one, or wait for the carrier |
| `W_Suggestion`        | probable Quick Fix available                  | `MaybeIncorrect`     | (Mentl-proposed)                                |
| `W_RedundantWhere`    | `type X = Y where true` — vacuous predicate   | `MachineApplicable`  | drop the `where true`; alias is transparent     |
| `W_EmptyRow`          | a named row (`type X = <row>`) resolves to `Pure` | `MaybeIncorrect`     | drop the alias; the row IS `Pure` already       |
| `P_ExpectedToken`     | parser expected one token kind, found another | `MaybeIncorrect`     | (parser-emitted; pre-substrate-classification)  |
| `P_UnexpectedToken`   | token kind not valid at this position         | `MaybeIncorrect`     | restructure per the surrounding form            |
| `P_UnclosedConstruct` | EOF inside a construct (block, match arms, etc.) before its closer | `MaybeIncorrect` | close the construct OR remove its opening token |
| `P_OrphanDocstring`   | a `//` comment with no following declaration, outside the prelude | `MaybeIncorrect` | attach to the next declaration, or bind to the enclosing node (never dropped) |

---

## What this document is NOT

- NOT a tutorial. See `examples/` for tutorials.
- NOT a reference for stdlib functions. See `std/` source + generated docs.
- NOT a description of the current parser. The parser implements this; where they disagree, the parser is wrong.
- NOT an aspirational wishlist. Every form here is required to land in the parser — closing the gap between this spec and the parser is a standing obligation, not a someday (the parser is the lathe turned to SYNTAX.md; where they disagree, the parser is wrong).

---

## Verbs this document declares that the CLI has not yet grown

SYNTAX is the authority and the CLI is a lathe turned to it, so this file may
name a projection before `mentl help` serves it. That licence is real and it is
also exactly how a promise rots unnoticed, so the lag is a LIST, in one home,
checked mechanically: `tools/doc-truth.sh` reads the names below and fails on
any *other* verb the docs name. The list shrinks as verbs land; it never grows
silently.

- **`mentl diagnostics`** — the live catalog projected from the `DiagKind`
  constructors, so the tables in this file stop being a hand-kept second home.

*(`mentl verify` LANDED 2026-09-19 and left this list — the medium's standing
bounds on its own source, each bound and its justification in `src/board.mn`
where `mentl why` walks them. It absorbs the census half of `tools/verify.sh`;
the legs that measure the world outside the graph — the micro battery's exec
seam, the march's peak RSS, the scaffold count — remain the script's, named
rather than silently inherited.)*

## Authority

This document is the authority on syntax: it supersedes any syntactic claim in `CLAUDE.md`/`PLAN.md` (the live three-doc contract) and in the archived `docs/**` corpus (git archaeology — DESIGN.md, SUBSTRATE.md, the per-module specs). Where any of them conflicts with SYNTAX.md, SYNTAX.md is correct.

Mentl's discipline applies to syntax: every form below was decided by asking the eight interrogations — one per kernel primitive (`PLAN.md §2`; the table lives in `CLAUDE.md`), one per Mentl tentacle. Graph (what AST does it produce?), handler + inferred resume cardinality (what installed handler reads it, what cardinality does the arm body prove?), verb (which topology?), row (what `+ - & !` constraint do the body's op-call sites prove?), ownership (what `own`/`ref` does the use-count infer?), refinement (what predicate does the path narrow?), gradient (what annotation INPUT or body-structure unlocks the cursor's projection here?), Reason (what edge does it leave for the Why Engine?). Forms that failed any of the eight were rejected. **Annotations declare INPUTS to the cursor; never the emergent property itself.**

When questions arise about syntax not yet covered here: resolve the design question by interrogating it against the kernel (`PLAN.md §2`) — reductively (minimal graph-correspondence?) and generatively (what do multi-shot / threading / unified-memory + the frontier make better?) — then update this document. SYNTAX.md is the one home for the surface.
