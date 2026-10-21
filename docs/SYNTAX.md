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
> the surface (`PLAN.md §5`), never the surface lowered to current lowering. The one
> genuinely post-real forward-pointer is the **effect system** (`§4③`): `!E` is
> present and load-bearing now, and so is information flow (`§4⑥`, §«Refinement
> types»); the modal synthesis that closes the higher-order leak is sequenced
> after first-light — its absence named in positive form where it would land,
> never a hedge that the present forms are "pragmatic, not final."

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
2. **Ownership Markers** (e.g., `own ast: Node`, `ref env: Env`, `ref nodes`) which enforce linearity and aliasing.
3. **Representation Pins** (e.g., `s: f32`, `coeff: f64`) which PIN a width the gradient would otherwise infer — the representation peer of the ownership marker (§"Type aliases", representation-pinned alias). `s: f32` is the bare-width form of `s: Float repr f32`.

Do not write `fn name(a: Int)` when the graph can infer it. Do write `fn name(pos: ValidOffset)` to erect a graph-backed semantic contract — and `fn name(s: f32)` only when a narrower-than-inferred width is the control decision.

**An ownership marker has ONE position: before the parameter's name** — `ref nodes`, `own ast: Node`. It is the one spelling that reads the same with a type and without one, which is why the parser reads the marker there (`parse_one_param`). The marker after the colon (`ast: own Node`) is the redundant spelling of the same parameter, so it is format-liftable to the name's side; the parser refuses it in type position today (`P_UnexpectedToken`), and the formatter landing parses it and lifts it.

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

Format-liftable and silent: the parse reads the statements as the block they are,
and `mentl fmt` writes the braces (`fn process(input) = {`). Keyed on the body
introducing statements, NOT on line count — the earlier `chase_node` (a single
multi-line `if` expression) needs no braces precisely because it introduces no
statements. No class names the lift (§«Diagnostic catalog»).

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

**Every name in a row is a declared effect, a row alias, a row variable or
`Pure`, or the declaration refuses.** A term that names no effect in the
module's reach — in a function's clause, a handler's, an op signature's,
inside a function type (`f: () -> Int with !Nowhere`) or in a named row
(§«Named effect rows») — is `E_MissingVariable` at the declaration, and
inside a type at the name itself: an unknown name read as an effect OF THAT
NAME would make `fn quiet() with !Nowhere = 1` check clean and constrain
nothing (tests/micros/mn-effect-name-resolves.mn,
mn-effect-name-in-fn-type.mn).

**A function type's row means what a declaration's clause means.** `f: () ->
Int with !Both` holds its row as its author wrote it, read where every named
row is known, whatever writes the type — a parameter, a return, a let's
annotation, an op's signature, a constructor's field, a handler's
configuration, a type's argument, an alias's body — so `!Both` forbids every
member of `type Both = A + B`, and each name is a reference `refs of`
answers (tests/crown/leak-fn-type-*.mn,
tests/micros/mn-effect-name-in-alias-fn-type.mn,
mn-effect-name-nested-fn-type.mn).

**A lowercase name in a row is a row variable** — the case rule read at a row, as it is read at a type. `f: () -> a with e` takes a callback performing anything, and `e` written again anywhere in the same signature — another parameter's type, the declaration's own clause — is the same variable, as a type variable named twice is. A parenthesized group is a row term the clause folds whole, its outer connective applied to what it spells: `with Memory + Alloc + (e - Intern)` is the row of a body that absorbs `Intern` around the callback and pays for the install, and it is how the medium writes such a row back.

**`with` is one keyword, not three.** It reads identically everywhere it appears — *"this construct is accompanied by / carries X"* — and the three surfaces are one concept, not overload: a function carries effects (`fn f() with E`); a handler carries state (`handler h with s = init`); a resume carries a state update (`resume(v) with s = s + 1`). The grammar disambiguates by position (a row after a signature, or `name = init` bindings after a handler/resume); the meaning is constant. (Handler *installation* is not a `with`-surface — it is the `~>` verb.)

### Return type omission

```
fn id(x: A) = x   // return type inferred
```

The `-> RetTy` clause is optional; absent = inferred. Most user code does NOT annotate return types. Mentl's gradient may suggest annotating when capabilities depend on the return type being explicit.

### Default parameter values

Trailing parameters may have default values. Call sites may omit them or override via labeled args.

```
fn compress(x: Sample, ratio = 4.0, threshold = -12.0) -> Sample = ...

compress(sample)                                    // ratio and threshold defaulted
compress(sample, 8.0)                               // ratio overridden; threshold defaulted
compress(sample, threshold = -6.0)                  // label to skip over ratio
compress(sample, ratio = 2.0, threshold = -18.0)   // fully labeled
```

A default **desugars once at the declaration** to a callee-scoped fill: when a call-site argument edge is absent, the parameter is filled by projecting the default's node, evaluated in the **callee's** parameter scope — where earlier parameters are in scope as a sequential binding chain (the same letrec scope nested fns use), never the caller's context. The default has one home (the signature node) and one evaluation context (the callee); the call site only omits an edge. A defaulted slot leaves a `DefaultReason(param, decl_site)` edge — `mentl why` at the slot walks to the declaration ("`ratio` defaulted to `4.0` from `compress` — annotate to pin").

### Labeled call arguments

Any call may use `name = value` for trailing positional arguments. Positional-before-labeled order:

```
fn queue_task(priority, ref config: Config, timeout_ms = 1000) = ...

queue_task(5, config)                                            // positional only
queue_task(5, config, timeout_ms = 5000)                        // positional + labeled override
queue_task(priority = 5, config = current, timeout_ms = 5000)   // all labeled
```

**Defaults and labeled args are not two features — they are the parameter list AS a product node-kind.** A parameter list is a positional product (`PLAN.md §2`, L1); like every product it may be constructed positionally (`f(a, b)`), by field (`f(x = a, y = b)`), or mixed (`f(a, y = b)`) — the identical machinery as record literals `{a, b}` / `{x: a, y: b}` (punning + field-naming), and a default is a product field's fallback construction (the identical machinery as a record-field default). There is no second call-site feature; the product node-kind mandates all four forms. Labels resolve against the declared parameter names; an unknown label is `E_UnknownArgLabel`. (Under threading/multi-shot a labeled call is order-independent at the product level — the cursor may fill fields in any order.)

**Identity, not position — the field's NAME is the key; the order is a projection.** A parameter product is not the position-keyed disease (`CLAUDE.md` drift-8, evidence-by-row-slot, `mode == 0/1/2`, parallel arrays): those use position as a *fragile proxy* for an identity. A product's fields *have* identity — their names — exactly as record fields do (sorted by name at parse, source order irrelevant). `queue_task(priority = 5, config = c)` resolves by name; the positional `queue_task(5, c)` is a *convenience* that fills fields in declaration order and resolves immediately *to* the names. Position is a deterministic layout over an identity-keyed set, never the key itself. And a label is the name of the field its slot fills: the page writes it as that parameter's name, read through the call's product and its callee's edge, so renaming the parameter rewrites every label that names it (tests/micros/mn-rename-label.mn).

### Partial application — the product with a hole

A parameter product may be constructed with a **hole** — a field left unsupplied. The result is not an error; it is a **value**: the function *awaiting* that field. This is partial application, and it is not a distinct feature — it is the product node-kind constructed with one field absent.

```
let adults = filter({ p => p.age > 18 })   // xs is a hole → adults : [Person] -> [Person]
adults(users)                              // fill the hole → the filtered list
adults(new_signups)                        // reuse — a hole-product is a first-class value
```

*(A bare `.field` accessor (`filter(.age > 18)`) is not a form: a field is not a declaration, so `.name` would be a THIRD way to reach a function value beside reference and mint — the one thing §«Function literals» says there is not.)*

**The hole is keyed by IDENTITY, never by position.** `filter({ p => p.age > 18 })` leaves *the parameter `xs`* unfilled — "the parameter `xs`," not "slot 2." When exactly one field is a hole, it is unambiguous. When several are, the hole is named explicitly with `??` at the field it marks:

```
between(??, 100)        // the FIRST field is the hole: { x => between(x, 100) }
list_set(xs, ??, v)     // the MIDDLE field is the hole: { i => list_set(xs, i, v) }
```

`??` is the same absence marker as the gradient's hole (§«Token enumeration», `THole`): a field the cursor reads as *unsupplied*. What fills it depends on context — Synth proposes a candidate, a call supplies a value, the `|>` pipe supplies the flowing datum, a resumption supplies it later — but the marker is one, and it names *which* field, never a slot.

**Where nothing can fill the field later, the hole is a value hole and the call applies.** An operand of an operator — `choose(??) + 1`, `-choose(??)`, `choose(??) == 2` — is handed nothing by anyone: no pipe flows into it, no later call fills it, so the product it would suspend into has no filler but the proposer. The call is therefore the applied call, its `??` the slot's value hole under the slot's contract (`choose(??) + 1` over `choose(n: Positive)` proposes `1`), and the judgment records the decision on the call's product (`CallShape`) for the lowering to read. In every other position — an argument (`f(choose(??))`), a binding (`let c = choose(??)`), a value returned — the `??` keeps the suspension above.

**The `|>` pipe is hole-completion, not a rewrite.** `x |> f(a)` fills `f(a)`'s remaining hole with `x`:

```
users |> filter({ p => p.age > 18 })              // fills xs → equals filter({ … }, users)
users |> filter({ p => p.age > 18 }) |> map({ p => p.name }) |> sort
```

The pipe's type rule (§«`|>` — converge») requires `right : A -> B` — a product with exactly one hole — and a partial application *is* exactly that. So the pipe is not a syntactic append; it is the product's one remaining hole filled by the piped value. This is why the five verbs compose: every stage is a product pre-filled with its configuration, its data field a hole the pipe completes — `x |> clamp(0, 255)` fills `clamp(lo, hi, x)`'s datum. A call that is genuinely not a stage names the pipe's target with `??` (`nodes |> list_set(??, i, v)`, §«The Stage Law»); a stage with more than one hole and none marked, or with no hole at all, is not an `A -> B`, and the pipe's unification refuses it (`E_TypeMismatch`, at its arity face: tests/micros/mn-pipe-into-complete-refuses.mn, mn-pipe-hole-ambiguous-refuses.mn).

**One primitive, five surfaces.** Positional construction, field/labeled construction, defaults, the hole (partial application), and pipe-completion are ONE thing — the parameter-list product constructed by identity with any subset of fields supplied, defaulted, or left as holes. There is no currying mechanism distinct from the product: a "curried function" is a product-with-holes, and the arity is never fuzzy, because the holes are named fields, not a hidden nesting of one-argument functions.

**The product is the judgment's, written once at the call.** Labels resolve, defaults fill and holes are typed against the parameters the CALLEE NODE carries — a let-bound closure's own parameter names, a parameter's own arity, a field's own type — never against a module function that happens to share the name, and the lowering reads that product off the call node instead of resolving it again. A partial over a local callee carries the callee's value in its record beside the supplied fields, and every open slot of a partial is typed by its own cell, so `fadd(1.5)` over a Float pair assembles.

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

**The stage of `each` answers `()`.** An iteration for effect drops its
stage's value by definition, so a stage that answers anything else is a value
the program silently loses, and `each({ x => x + 1 }, xs)` is
`E_TypeMismatch` at the call. A value dropped in any other position is still
silent (`Hβ.infer.statement-value-is-dropped-silently`). Four prelude
signatures still take the datum first — `reduce(xs, f)`, `scanl(xs, init, f)`,
`nth(xs, n, default)` and `clamp(x, lo, hi)` — so `x |> clamp(0, 255)` is the
law the prelude catches up to, through a medium-authored reorder that reads
every call off its product, permutes the positional ones, leaves labeled calls
untouched, and re-judges the program before it writes.

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
  `parallel_map` is vocabulary drift over `map ~> Schedule`. The schedule
  reaches a helper's fanout by DEMAND, through a direct call (§`><`): a
  `~> parallel_compose` over `render(voices)` runs
  every `><` and `fanout` in `render`'s direct-call reach threaded, while
  `map` stays sequential by construction (one loop) and `fanout(f, xs)` is
  the sequence fanout that declares its applications independent. The
  parallel map is spelled `fanout(f, xs) ~> parallel_compose`.
- **A name must not lie about the representation.** `list_head`/`list_tail`
  read and remove the LAST element (the snoc end — O(1) by construction);
  the borrowed cons-vocabulary asserts the opposite and has already billed
  the project one real bug (the env-orientation truncation). The true names
  are **`last`** and **`drop_last`** (symmetric with `take`/`drop`): the
  primitives are
  `last`/`drop_last`; prelude's drop-first is **`rest`**, the pattern
  surface's own word (`[head, ...rest]`), and `tail` is no name at all.
  One home per truth: the positional `last` duplicate dissolved into the
  O(1) representation read.

### Nested function declarations

`fn` declarations may appear inside another function's body. Nested fns are local to the enclosing body's scope.

```
fn check_exhaustive(patterns) = {
  // inner helper; visible only inside check_exhaustive
  fn covers_all(pats, variants) = all_match(variants, { v => any_match(pats, matches(v, ??)) })
  covers_all(patterns, known_variants())
}
```

A nested `fn name(params) = body` is a declaration scoped to its block, and consecutive `fn` declarations in a block form one RUN — a local letrec scope: every name of the run is in scope in every body of the run and in everything after it, so siblings call each other in either direction. The run is judged as the module's declarations are, callee-first by binding group with each cycle judged as one unit, so every member is generalized — one nested `fn ident(x) = x` serves an Int and a String even where its caller is declared above it. Any other statement between two `fn` declarations ends the run: a later fn may capture what that statement computes, which does not exist while an earlier fn can already be called, so in `fn first() = second() + 1; let k = 2; fn second() = k` the name `second` is out of scope at `first`'s call (`E_MissingVariable`). Two declarations of one name in one run refuse (`E_DuplicateFnName`), as two at module level do, and a fn in a later run shadows one of its name in an earlier run for what follows it. A block-scope `let name = (params) => body` is a closure VALUE, and the two differ in exactly that: the `let` binds after its value, so its name is not in scope in its own body, it is not generalized, and it may shadow — `let f = (x) => f(x) * 10` calls the `f` bound before it.

**A nested fn is MINTED where it is declared.** Its closure record — its captures, or an empty record with none — is built when the block reaches its run, every record of the run allocated and bound before any is filled, so a record that holds a sibling declared after it, or itself, holds the sibling's record. The declaring frame pays `Memory + Alloc` once per nested fn, exactly as it pays for a lambda it mints (§«Function literals»): `fn adder(k) with !Alloc = { fn add(x) = x + k; add }` refuses. A nested fn that captures nothing could be the module's static record and cost nothing; the charge follows that representation the day the lowering builds it (`Hβ.lower.captureless-nested-fn-is-static`). A nested fn minted inside a handler arm captures the arm's continuation as a lambda minted there does, so its body may `resume` and the fn is a value like any other: an arm may hand it to `fold` and resume once per call (tests/micros/mn-resume-in-referenced-fn.mn).

**A binder shadows its name for its own scope and no further.** A `let` in a block, a pattern in a match arm, a pipe stage's parameter, a recurrence's prior and a binding inside the recurrence body each hide the same name while their scope is open, and the hidden binding is read again, unchanged, once it closes: `fn f(x) = { let y = { let x = 5; x + 1 }; x + y }` answers `f(100) = 106`. Two binders of one name are two values at their own widths, never one storage place. The ownership a parameter is graded reads its own uses, the references whose edge reaches it, never a shadowing binder's (`fn shadowed(xs) = { let xs = 5; xs + xs }` grades its unread parameter by its uses, not its spelling).

**At module scope there is nothing to shadow, and a `let` bound to a function literal IS the declaration**: `let inc = (x) => x + 1` is born as `fn inc(x) = x + 1` at parse — recursive, generalized, emitted as the symbol its callers call directly — and `mentl fmt` writes it as `fn`. An arm-list literal bound at module scope, `let pick = { Some(v) => v, None => 0 }`, is a declaration too and keeps its spelling, because its one parameter is minted by the literal and never reaches the page. An annotated module let keeps its annotation's constraint and stays a value, and a module value holding a closure (`let add3 = make_adder(3)`) is called through that closure.

---

## Function literals — the arm list

Surfaces primitives **#2** (pattern dispatch, the handler's own shape) and **#8** (HM inference: a literal's parameter type is inferred from the arms).

**A function value is reached by exactly TWO operations, because the kernel has exactly two** (`PLAN.md §2` — draw an edge, project):

1. **REFERENCE** an existing function, with the fields it is not yet given left as holes — `f`, `f(cfg)`, `f(a, ??, c)` (§«Partial application — the product with a hole»). An edge to a node that exists.
2. **MINT** a new one, with an **ARM LIST** — `{ pattern => body, … }`.

**What each costs is in the row of the frame that forms it.** A bare reference to a top-level function reaches its static record and costs nothing. A reference with fields supplied (a partial) and a mint each build a closure record — its captures, its supplied fields — so each charges `Memory + Alloc` where it is formed, and `with !Alloc` refuses it. The exception is structural, not a discount: where a verb APPLIES the literal in place — the stage of a `|>`, the recurrence of a `<~` — nothing is minted, so nothing is charged (§«`|>` — converge»). Calling a closure charges the closure's own row, which rides its type, and never the cost of having made it.

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

**And a pair is ONE argument, at every altitude.** A call's argument count is its callee's parameter count: `{ (a, b) => a + b }` is called as `f((1, 2))`, never `f(1, 2)`, and it is not a two-argument callback — `fold(0, { (acc, x) => … }, xs)` is refused, because `fold` calls its stage with two arguments; the binder form `(acc, x) => …` or a reference is the two-parameter value. The shapes refuse (`E_TypeMismatch`, its arity face) — `let p = (1, 2); p |> add` among them. A product BUILT where it is piped is the one exception, and it is not a decomposition: `(1, 2) |> add` is the merge, `add(1, 2)`, the tuple never built (§«`|>` — converge»). The calling convention that would make the two one value is `Hβ.lower.parameter-product-calling-convention`.

**A brace opens a literal when a PATTERN ends at a `=>`.** That question is answered by a bounded token scan, never by parsing a pattern speculatively and never by layout: one pattern atom — an ident (optionally applied), a literal, or a balanced group — joined to further atoms only by `@` or `|`. Two adjacent atoms are never a pattern, so `{ setup()` newline `(x) => run(x) }` is the block it looks like. Record literal and block discrimination are unchanged and follow (§«Records», §«Function declarations»).

### The residue — `(params) => body`

The binder form still parses, and it is the last of the line that retired `perform`, `handle`, `capability`, the turbofish and `|x|`. A sole-parameter lambda IS an arm list, so the binder is the redundant spelling of one. `mentl fmt` writes the arms wherever the lambda's body is a `match` on its parameter (`arm_list_of`) — every arm list reads back that way, and so does the param-position destructure `((a, b)) => e`. A sole-parameter lambda with any other body keeps its binder today (`(x) => x + 1`), because the parser builds `{ x => x + 1 }` as a `match` on a minted parameter rather than as the one `LambdaExpr` the binder form builds; the formatter landing makes them one node, and every sole-parameter mint then renders as its arms. What survives on the page after that is the honest remainder:

- **multi-parameter** (`(a, b) => a * b`) — the arm list is one-parameter, so these retire by becoming REFERENCES (`fold(0, add, xs)`), which is rule 1 and needs no new form. `Hβ.syntax.multi-param-lambda-is-a-reference`.
- **the zero-argument thunk** (`() => e`) that handed a body to a handler stack — RETIRED into the named handler chain (§«Handler chains»). A thunk that defers a computation for a function to run stays the binder form, the two-parameter case's sibling.

The multi-parameter residue retires as the medium authors the migration (`PLAN.md §11`, iteration is topology); neither is a second minting form, and no third is being held open.

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
{
  input => {
    let cleaned = input |> clean
    cleaned |> transform
  },
}
```

### Rule — braces are the BlockExpr literal

- **A single expression body** (even multi-line) needs no braces: `{ x => x + 1 }`, `{ x => if c { a } else { b } }`.
- **A body that introduces `let`-bindings/statements (a `BlockExpr`)** requires braces: `{ x => { let y = setup(x); y + 1 } }`.

Identical to named-fn bodies (§"Function declarations"): the brace requirement keys on "is this a `BlockExpr`?", never on line count. The literal's own braces are not a body's: they hold the arms, and an arm's body follows the rule like any other.

### Inline higher-order use

```
map({ x => x + 1 }, xs)
filter({ x => x > 0 }, xs)
fold(0, (acc, x) => acc + x, xs)           // two parameters — a reference is the ultimate form
zip_with((a, b) => a * b, xs, ys)          // likewise
```

### Returned closures

```
fn compose(f, g) = { x => g(f(x)) }
fn id(x) with Pure = x
```

### Match arms ARE the literal

An arm list IS a function, `match` is that function applied, and one `parse_match_arms` serves both: the unity is not a resemblance between two forms, it is the same node. (Before the mechanism, 197 of the wheel's 515 lambda sites were `(x) => match x { … }` — a wrapper paid to reach a form the language already had.)

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

**A stage is APPLIED, never minted.** A call standing as a stage is completed in place (its hole filled by the piped value), and a function literal standing as a stage — `x |> { v => v * 2 }`, `x |> { 0 => 1, n => n - 1 }` — is the piped value bound to its parameter, its body lowered in the frame the pipe stands in. Neither builds a closure, so neither costs the frame anything, and a stage-shaped chain inside a `with !Alloc` function stays allocation-free. The parameter is a binder of that frame like any other: it may share a name with a local there, and the local reads its own value again once the stage closes. A bare op reference standing as a stage is the perform: `x |> put` is `put(x)` in the frame the pipe stands in (tests/micros/mn-pipe-into-op.mn).

**A stage whose callee is not yet known is the Stage Law's product.** Where the callee's arrow is still a variable — a field of an unannotated record, a parameter, a forward local — `x |> rig.tone(320.0)` is judged as `rig.tone(320.0, x)`: the arguments written, then the piped value's slot. A callee whose arrow is known is completed by its own parameters, and one whose call is already complete and returns a function is applied whole.

**A product built at the site fills a stage's open slots.** `((l) >< (r)) |> mix(0.35)` is `mix(0.35, l, r)` when `mix(0.35)` leaves exactly two slots — the parentheses are the precedence table's, since `|>` binds tighter than `><`: the merge, Faust's `,` then `:`, and the tuple is never built. A stage with one open slot takes the product whole, as it takes any value; the merge asks for exact agreement and never guesses.

**Applying a stage owes what the stage demands.** The piped value fills the stage's parameter exactly as a call's argument fills it, so the parameter's refinement is claimed of the value at the pipe and the row its precondition guards is paid there when the claim is open: `30000.0 |> alpha` over `alpha(c: Hz)` refuses as `alpha(30000.0)` does, and a partial stage owes the contract of the slot it leaves open (§«Refinement types»).

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
    { x => x |> stage_a1 |> stage_a2 },
    stage_b1,
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

**A branch owes what a stage owes.** Each branch is applied to the input as a pipe's stage is, so its parameter's refinement is claimed of the input and the row its precondition guards is paid where the claim is open: `0 <| (inv, inv)` over `inv(n: Positive)` refuses as `0 |> inv` does (tests/micros/mn-refine-fanout-branch-owes.mn).

**A fanout over one stage is the pipe.** A product of one field is its field, so `x <| f` answers what `x |> f` answers and the two are one graph: the parse builds the pipe, and `mentl fmt` writes `|>`. A tuple literal of one, `(a,)`, is `a`, as the pattern `(p)` is `p` (tests/micros/mn-product-of-one.mn).

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
What the verb COSTS is what its let-spelling costs. Under a schedule that
runs the branches in the frame (`Seq`, and `Simd` and `Gpu` until they have a
device), each branch is evaluated where the fanout stands — no thunk, no
carrier — and the tuple of results is built only where it ESCAPES: a fanout
taken apart where it is made (`match (x + 1) >< (x + 2) { (a, b) => a * b }`)
binds its parts to registers, and one piped into a stage with as many open
slots MERGES into it (`((l) >< (r)) |> mix(0.35)` is `mix(0.35, l, r)`, §«`|>`
— converge»), so neither allocates and `with !Alloc` accepts both. A fanout
whose tuple escapes — returned, stored, handed whole to a call — builds it and
charges `Memory + Alloc` in its frame, and `with !Alloc` refuses that. A
spawning schedule builds a thunk per branch at the cost of the install that
runs it, charged where that install stands — so a callee declared `!Alloc`,
like one declared `!Thread`, takes no caller's spawning demand and runs its
in-frame form. A `<~` in a branch literal is the enclosing record's line under
every schedule: a thunk minted per call holds that line in its slot instead of
a ring of its own, so `step(1.0)` ticks one recurrence whether its caller
installs `parallel_compose` or nothing.
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
site whose frame installs no schedule names the callers that demand it.

**The race-freedom claim has its gate.** A spawned branch runs in the world it
was spawned in — the task record carries the install chain of the PERFORM that
spawned it and the fresh instance installs it before the branch runs — so an
effect a branch performs reaches the handler installed at the fanout's frame,
from a second instance, and the schedule's own ops answer there too:
`current_id()` inside a branch reaches the `parallel_compose` that started it.
`E_ThreadedBranchEffect` (armed) refuses at lowering any effect in a branch's
row whose covering handler at that frame is STATEFUL (two instances resuming
`with n = n + 1` on one state record), lies beyond the frame fence with no
caller's schedule demanding the fanout (a caller's install is provable only
along a demand, below), or is stateless but performs, from an arm, into a
stateful one further out (an arm runs in the spawned instance and its performs
resolve outer, so the walk follows each handler's own residual row down the
stack). The fix is stated in the refusal: install a stateless handler at the
fanout's frame, or install the handler inside the branch, where each instance
gets its own state record. The rule reads WRITES, not declarations: a handler
is stateful when an arm writes its state by either of a field's two writers —
a `resume … with` update, which replaces the record's word, or an in-place
store into what the field holds (`list_set(buf, 0, …)`, directly or through a
callee that stores into its parameter), the same fact an install's arena reads
— so a state that is only read is shared read-only across instances and runs.
And the rule reads a branch's own stores by their targets: a store into memory
older than the branch — a buffer both branches capture, a module value — is
one memory written from every instance, and refuses naming the store; a
branch reaching code that stores into memory older than that code's frame
carries `Mutate` (§«Negation in `with` clauses») and refuses the same way, so
two branches calling one function whose feedback line both tick refuse; a
store into memory the branch allocated builds a value and runs — a voice
minted in the branch and ticked there among them
(tests/frontier/mn-threaded-branch-captured-store.mn,
tests/micros/mn-race-store-into-branch-memory.mn).

**A spawned instance shares the module's values.** A module value let is the
root's: its init runs once, in the root, before `main`, and every spawned
instance reads the root's values through the task record — a branch reads the
module buffer the root updated in place, and an init that prints prints once.

**A branch's abandon is re-raised at the join.** A branch whose perform never
resumes leaves its thread with the op and its arguments banked in the task
record; the join re-raises it in the joiner — the first abandoned branch in
join order wins — and the joiner unwinds from the join to the install whose
arm answers, which is the fanout's value: `match (0 <| ({ _ => ab() }, { _ =>
10 })) ~> parallel_compose ~> h { (a, b) => a + b }` with `ab() => (5, 0)`
answers 5, and the same fanout under `sequential_compose` answers 5 through
the spawn arm's own call boundary. A branch that yields a LIVE continuation
has nowhere to resume — no joiner can hold it — and traps loudly at the
thread's end, never silently joining its dummy.

**The schedule reaches a callee's fanout by DEMAND.** A fanout's own frame's
install wins; a fanout whose frame installs no schedule runs under the
schedule a CALLER installs over a direct call to it, and so does every fanout
in that callee's direct-call reach: `fn both() = (a()) >< (b())` under
`(both()) ~> parallel_compose` spawns both branches, and the callee is emitted
as a schedule TWIN keyed by the install's schedule beside its instantiation —
the proof becomes the dispatch, as a twin is keyed by what its body reads. Two
things bound the reach, each a decision the row reads. A callee declared
`!Thread` keeps its own frame's schedule: the negation is what the demand
reads, so a real-time region's fanouts stay sequential under any caller. And
the demand crosses DIRECT calls only: a function value minted under the
schedule — a lambda, a partial, a nested fn — keeps its own frame's schedule,
because a value can outlive the install and a spawn it carried out would find
no handler on the chain (`Hβ.lower.schedule-through-a-value`); a branch
thunk, an install's arm and a state init never leave the extent and take the
schedule. A direct call is the declaration its callee's edge reaches, so a
nested fn sharing a module-level fn's name never answers for it
(tests/micros/mn-schedule-reach-shadowed-name.mn). The race rule is read along
the same demand: each demanded fanout's branch rows are checked against the
installs between it and the demanding site, and a branch whose row is a
callback PARAMETER's is read at the instantiating site — `fn tally(f) = (f())
>< (f())` called with a callback that bumps a stateful counter refuses, where
the lexical rule saw a free row.

**`fanout(f, xs)` is the SEQUENCE fanout** — `><` over a runtime sequence: `f`
applied to each element as an independent branch, the results collected in
order, under whatever schedule governs the site. It is typed exactly as `map`
is and, with no schedule installed, IS `map`; under a Thread-class install
every element's branch is spawned and joined in source order
(`fanout_threaded`, lib/threading), under a Persist-class install
checkpointed and joined (`fanout_persisted`, lib/persist). `map` itself stays
a sequential loop by construction (§Vocabulary): only a fanout declares its
applications independent, which is the whole difference between them. Simd
and Gpu pack a fixed lane count and run a sequence fanout sequentially. The
race rule reads the function a sequence fanout applies as every branch's, so a
`~> parallel_compose` over a fanout whose function writes through a stateful
handler refuses — the deterministic partition (`PLAN.md §11.16`) stated as a
gate (tests/micros/mn-race-sequence-fanout-store.mn,
mn-race-sequence-fanout-stateful.mn).

**Alternatives are a choice, never a fanout.** A fanout's branches are
independent work whose results are all wanted; alternatives are one
computation tried several ways, and `choose(options)` (lib/choice.mn) says
so: it suspends the computation around it, and the handler that catches its
resumptions says what choosing means — `every` joins what each option
answered, `first` stops at the first option that answers `Some`. The ??-fan is
one choice (`segment_verify`, src/synth_proposer.mn): its candidates are the
resumptions of one `choose`, and the compiler's forking handler judges each
in a graph instance of its own, seeded with a version of the graph, and drops
it, the fork written once in that handler's arm
(tests/micros/mn-choice-every-first.mn).

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
parse-time form classification commits a form before the judgment has
read it, which Governing principle 1 rules out.

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

*An install whose record never outlives its extent could live in the frame and cost nothing; that representation is `Hβ.lower.install-record-in-the-frame`, and the charge follows it when the lowering builds it.*

**`~>` governs the topology to its left — including a `><` / `<|` fanout.** Because
`~>` is the loosest operator, a `Schedule` handler at the foot of a chain governs
every fanout in the body: `(a |> f) >< (b |> g) ~> Thread` runs both branches
threaded; the branch bodies do not change (there is no second version to keep in
sync). The fanout verb stays pure topology; the cursor reads the execution
strategy LIVE from this install edge (§`><`) — adding `~> Thread`, swapping it for
`~> Simd`, or installing `~> persist(...)` over a multi-shot branch is the entire
diff between sequential, parallel, lane-packed, and crash-surviving. The schedule
is a fact in the `~>` edge, never baked into the verb.

**A derivative reading is the other projection an install can be.** `(body) ~> grad(w)` — lib/ml/grad.mn's `Derivative`
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
that holds them.** Handler = state = closure, read once more:
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

**A product seed is answered in one reverse sweep.** The
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

**An arena is the third: the extent's allocations die at its exit.** `(body) ~> arena` — lib/arena.mn's `arena`, which answers `Alloc`
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
compile-time facts. In a module that spawns, each instance allocates in a run
of its own — one atomic add per 64 KB chunk on the image's frontier, a private
bump inside — so an arena's region is a span of its own instance's run and
reclaims in a spawned branch as in the root. An arena open across
a spawn its instance makes, or across a chunk that could not extend its run,
keeps its region: a spawned child's records lie in the child's run, where the
exit never looks, and may hold the extent's values
(`Hβ.arena.extent-spanning-a-spawn-keeps`).

**A suspended arena keeps its region, and each resumption is an arena of its
own.** An op performed inside an arena and answered by a
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
arena. An arena whose body suspends is a place the frame it stands in is
captured at (§«Resume discipline»), so the rest of that frame resumes at the
arena's value; an arm that never resumes leaves the arena suspended for good,
its arguments intact. `arena_stat(ArSuspended)` counts the suspensions.

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

**The causality rule:** a cycle with no delay has no computable value — the prior would be the very output being computed — so `x <~ delay(0)` is **`E_ZeroDelayFeedback`**, an ARMED refusal at the `<~` site (nonzero exit, zero WAT). Faust makes this unsayable by inserting its delay implicitly; Mentl names the depth, so the depth can be wrong, so the medium refuses it. The refusal is one ARM of the depth read below — the same read that sizes the line judges whether the size is sayable — and both `delay(0)` and `Delay(0)` convict, the two spellings of one FeedbackSpec variant.

**The iterative context is the CLOCK, and the clock is inferred, not required.** A `<~` site is a per-site state register whose *previous iteration* is the enclosing function's next call, which is why the stage `bandpass_stage` mints (`lib/dsp/signal.mn`, four `<~` sites) carries no clock in its row and is correct; requiring an ambient effect would refuse correct code, every `<~` site in the wheel's own link among it. So no class refuses a `<~` for a missing context. Its honest refusal is the inferred clock's (`Hβ.dataflow.clock-calculus-sample-rate`, Lustre's clock calculus): when the medium *proves* what advances a cycle, "nothing advances this one" becomes a measurement, and the refusal is that measurement projected — `Sample`/`Tick`/`Clock` instances of the class by what they do, never a name-allowlist.

**The declared depth IS the line's depth, and the line is a RING OWNED BY THE RECORD OF THE FUNCTION THAT CONTAINS THE CYCLE.** `delay(N)` carries N priors: the site's line is an N-slot ring, the prior the cycle reads is its OLDEST slot — y[n−N] — and each tick stores the output over it and advances the head by one, so a tick is a load, a store and a bounded increment at any depth (`delay(24_000)` costs what `delay(1)` costs per tick; `tests/frontier/mn-feedback-deep-line.mn` drives 2,000,000 ticks at that depth and the frontier leg prints the ticks per second). `delay(1)` is the single register it always was; `delay(3)` is genuinely three deep: the same recurrence driven six times answers 6 under `delay(1)` and 2 under `delay(3)`. The ring is allocated ONCE, where its owner is built — never per tick — and its owner is the record of the function the `<~` sits in (handler = state = closure, read at the site): a lambda's line lives in the closure record past its captures, so every closure minted from one lambda is its own filter (`let lp_l = lowpass(0.3)` and `let lp_r = lowpass(0.3)` are two lines, the two-channel shape every stereo stage writes); a handler arm's line lives in the install record past the arms, so every `~> h` is its own filter; a reified remainder's line lives in the k record, shared by that k's resumptions as every heap write of the remainder is; a top-level fn's line — its record being the module's immutable data record — rides an instance global allocated at start, one per emitted twin, so a generic recurrence reached at Int and at Float ticks two lines at two widths; and a `<~` directly in a module value let's init is static the same way, its line owned by the module's init function, while a fn nested in that init is a closure minted there and keeps its lines in its record (module scope is a frame). A filter that must exist once per signal is therefore a MAKER: lib/dsp's `lowpass_filter(sr)`, `highpass_filter(sr)`, `dc_blocker()` and `envelope_follower(attack, release, sr)` each return the stage, and each stage minted owns its line (`tests/micros/mn-feedback-closure-instances.mn`, `mn-feedback-arm-instances.mn`, `mn-feedback-twin-width.mn`, `mn-feedback-deep-line.mn`). **The `!Alloc` row survives the cycle.** The RHS is checked as a `FeedbackSpec` VALUE — its type is what the site reads — but its construction never executes: emit discards the lowered spec and the prior is a register read off the ring, so the site judges the spec in a frame whose row is dropped (tests/frontier/mn-feedback-transport.mn pins it). The surface question behind it stays open and is the smaller artifact: whether the RHS should stop being an expression and become a static depth annotation, which is what the emit already treats it as (`Hβ.effects.feedback-row-substitutes`, branch B).

**The depth must be a LITERAL.** The literal is compiled into the line twice: it sizes the ring where its owner allocates it (`line_ring_bytes`, src/backends/wasm.mn — a two-word header, then the slots), and it is the modulus the head wraps at on every tick, an immediate in the emitted code. A depth the medium can only read at runtime is a depth today's line cannot hold — and handing such a site one slot is precisely the silent wrong the depth read exists to end. `delay(n - 1)` is **`E_ComputedDelayDepth`**, armed at the `<~` site. A runtime depth is the same ring with a cap word: the depth stored beside the head in the header's second word (padding today), the ring allocated at the size the value names, and the tick's modulus read from the ring instead of the immediate. That is `Hβ.dataflow.delay-line-runtime-depth`, and it waits on no other landing — only on a program that needs it.

**Binding the prior — the recurrence form.** The LHS may be a one-parameter function literal `{ prev => body }`; `prev` binds the **prior iteration's output**, read live, so a genuine IIR recurrence `y[n] = f(x[n], y[n-1])` is expressed (not approximated by a bare feed-forward LHS):

```
fn lowpass(x: Sample, a) -> Sample with !Alloc =
  { prev => a * x + (1.0 - a) * prev } <~ delay(1)
```

The prior is a **graph node** (the feedback site's own carried value), not a register copied into scope — the literal's parameter resolves to `RFbPrior` → `LFeedbackPrior`, emitting a direct read of the site's prior local, and `prev` binds it. The body is **inlined**, never a heap closure: a `<~` recurrence allocating per tick would defeat the `!Alloc` real-time row, so the prior is a register read. A bare-expression LHS (no literal) is the feed-forward form — it computes on the current input only; the literal's parameter is what carries `y[n-1]`. The binder spelling `((prev) => body) <~ delay(1)` builds the same recurrence and is the residue §«Function literals» names. The surface surpasses Faust's untyped `~`: the prior carries the same refinement row (`Sample`/`Hz`/`Gain`) and the `!Alloc` proof as the forward path. (Surface kernel correspondence: primitive #3 the `<~` verb; primitive #5 the prior is owned-read, not aliased.)

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

`...` is anonymous rest; `...r` binds the rest to a row variable `r`, lowercase by the case rule, and every `...r` of one signature is that one variable, so `fn sum_x(a: {x: Int, ...r}, b: {x: Int, ...r})` takes two records with one remainder:
```
fn extend(base: {name: String, ...r}, age: Int) -> {name: String, age: Int, ...r} =
  ...
```

**An open row keys the twin.** The row var is a quantified var like any other: the call site proves the whole field set, so each record shape mints its own specialization and reads its own layout, and `fn width(u: {name: Int, ...}) = u.name + 1` reads `name` at its own offset whatever other fields the caller's record holds (`tests/syntax/record-field-param-open`, `record-field-param-open-two-shapes`, `record-field-through-list`). A row that nothing closes refuses (`tests/floors/mn-unprovable-offset`, where the receiver is main's own parameter). The unseen rest of a record is always a row variable, never an assumed remainder: two open rows meet at one fresh variable both continue into, so a body reading two fields (`fn pick(u) = u.x * 10 + u.y`) still mints one twin per record shape (`tests/micros/mn-row-two-fields-two-shapes.mn`).

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
field crosses into it.

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

**Every other brace reads its `{` through ONE discrimination**: `...` opens an update, a pattern ending at `=>` opens an arm list (§«Function literals»), a field name followed by `:`, `,` or `}` opens a record, and anything else opens a block. A function body is such a slot, so `fn origin() = {x: 0, y: 0}` returns a record and needs no parens, and `fn f() = {x}` is the punned one-field record — never a block holding `x`, which the formatter lifts to `fn f() = x` (`E_RedundantBraces`).

### Pattern syntax for records

```
let {name, age} = morgan       // both fields bound to locals
let {name, ...rest} = morgan   // bind name; rest is a record of remaining fields
let {name: n, age: a} = morgan // bind to renamed locals
```

`{name, ...rest}` binds `rest` to a fresh record of the remaining fields, each copied at its own width, and `rest`'s own field accesses read the residual's layout. `..._` keeps the open-acceptance without a bind, exactly as in list patterns. Binding a rest BUILDS that record, so it charges `Memory + Alloc` in the frame the pattern stands in, and `with !Alloc` refuses it (`tests/micros/mn-record-rest-alloc.mn`).

**A record holds one field of each name**, so the rest has none of the fields the pattern names: the row behind them lacks their names, and `rest.name` refuses where it is written (`tests/micros/mn-record-rest-lacks-the-field.mn`). A rest named twice in a signature lacks every field written in front of it in either place.

**A record pattern reads its fields BY NAME** through its receiver's whole field set, which the twin of each caller proves: a parameter's record may carry fields the pattern never names, sorted before or after the ones it does, and `fn pick(u) = { let {zeta} = u; zeta }` answers `9` over `{alpha: 7, zeta: 9}` (`tests/syntax/record-pattern-param`, `-param-rest`). The rest's OWN reads spell the residual's layout: `fn f(u) = { let {a, ...rest} = u; rest.b }` over `{a: 1, b: 2, c: 3}` answers `2`, the twin's pair for the row variable being the residual past the named fields (`tests/micros/mn-record-rest-through-param.mn`).

### Field access

```
morgan.name
nested.outer.inner
```

Field access lowers to `LFieldLoad` with offset resolved at compile time from the record's type. O(1) load.

A record literal written as a field of another is its own record: `let r = {inner: {den: 5}}` reads `r.inner.den` as 5.

### Record update — spread into new record

```
let older = {...user, age: user.age + 1}
let tagged = {...event, timestamp: now(), processed: true}
```

`{...existing, field: new_value, ...}` creates a NEW record by copying `existing`'s fields and overwriting/adding the listed fields. Non-destructive; original record unchanged (ownership preserved).

**An update keeps every field it does not write.** Its type is the written fields in front of a COPY of the base past them: the copy is the base's row without the written names, a relation the two rows' free ends carry, so a field either learns reaches the other whichever is known first. A field the base holds under a written name stays the base's — the record holds one field of that name, the written one, at the written value's type — and every other field of the base is kept, including those not known where the update is judged. So `fn with_b(r, b) = {...r, b}` hands back every field its caller passed in: over `{a: 1, b: 2, c: 3}` it overwrites `b`, over `{a: 4, c: 6, z: 1}` it adds one, and each record shape is built in its own copy of `with_b`, whose layout the emit reads under that copy (tests/micros/mn-record-update-keeps-the-row.mn, mn-record-update-shadows-the-field.mn, mn-record-update-in-a-stage.mn, mn-record-update-copies-the-base.mn). An update joins the record it copies, and a function threading a record through its own recursion by updates returns the shape it was handed: `if c { sc } else { {...sc, fb: 1} }` is one record, and so is `{...walk(sc, n - 1), fb: 1}` returned beside `sc` (mn-record-update-joins-its-base.mn, mn-record-update-through-recursion.mn).

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

**A sugar calls the language's primitive, whatever its name binds where the sugar stands.** `xs[i]` calls the prelude's `list_index`, `++` the sequence concat `list_concat`, an interpolation's seams `str_concat`, and a rest pattern cuts with `slice`. The node that writes the sugar is linked to the primitive it calls, as a call's callee is: `refs of slice` answers a rest pattern beside the calls that name it, the lowering calls what the edge reaches, and the sugar charges the primitive's row, read off its declaration — so a parameter named `list_index` never swallows the index's charge (`tests/micros/mn-sugar-callee-is-the-vocabulary.mn`). A parameter sharing a primitive's name is the parameter when it is called: a substrate primitive's face belongs to its declaration and travels along the edge a reference draws to it, so `fn apply(len) = len(5)` is judged against the callback it is handed (`tests/micros/mn-param-named-like-a-primitive.mn`).

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

**A function field's unwritten row is the declaration's.** A field whose
function type names no row — `Holds(() -> Int)` — holds one row for the whole
type, a cell of the declaration no scheme quantifies: every construction
writes the row of the function it stores into it, and every match reads it
back, so a function taken out performs what any function put in performs, and
`fn bad() with !E = match make() { Holds(f) => f(), Empty => 0 }` refuses
where `make` stores a closure performing E. A field that carries a different
row at each use says so with a type parameter (`Holds(a)`)
(tests/crown/leak-field-row-unwritten.mn).

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

Every value the scrutinee of a match of two or more arms can take reaches an
arm (a match of one arm asserts its shape instead, below). A value no arm
reaches:

Diagnostic: **`E_PatternInexhaustive`** at the `match` keyword, naming the value
that escapes as a pattern:
> "match misses `None` — write its arm"

Quick Fix: insert the arm the witness names. The refusal never proposes a
wildcard: a `_` arm over a sum is the roster of variants the author declined
to write, and the medium bounds the shapes of it that fabricate (`mentl verify`,
the wildcard-zero and wildcard-fabricates census).

**The check reads the WHOLE pattern, column by column**: the arms are a
matrix of pattern rows, a column of constructors is complete when the arms
name every variant of the type and each variant's payload columns are
themselves covered, and a column with a wildcard or binder covers the rest —
so a match naming every `Stmt` variant but one inside `NStmt(…)` refuses as
`match misses `NStmt(HandlerChainStmt(_, _))``, the witness being the first
missing variant in declaration order. A tuple column is one constructor of
its width. **The read is strict over every pattern kind**: a list column is
the sum it is, `[]` or a head before a rest, so `[]` beside `[h, ...t]` is
whole and `[x]` beside `[]` misses `[_, ...]`; a record column is the union
of the fields its patterns name, an unnamed field `_`; Bool's two literals
are the constructors they are; and any other literal column is covered only
by a row that is wild there, since no set of literals covers a word or a
text — `0` beside `1` misses `_`, and `Some(false)` beside `None` misses
`Some(True)` (tests/micros/mn-literal-payload-inexhaustive.mn,
mn-list-length-inexhaustive.mn, mn-int-literal-inexhaustive.mn). An arm
covers what its top pattern covers: an alternation every branch, an
as-pattern `name @ pat` what `pat` does (`whole @ Leaf(_)` covers `Leaf`).
The refusal is armed: a match missing a variant does not compile to a program
that traps when the variant arrives.

**A catch-all over a sum is the roster its author declined to write.** A `_`
or a bare binder after other arms of a match over a sum swallows the
constructors those arms leave, and a constructor declared later joins it
unread — the exhaustiveness gate satisfied while what it knew is thrown away.
So the medium counts the shape (`mentl verify`'s catch-all census, bounded at
the wheel's count) and `mentl tighten` writes in its place the alternation of
the constructors that reach it, each payload `_`, under the arm's binder when
it bound one: after `Dot => 1`, the arm `other => "many"` over `type Shape =
Dot | Line(Int) | Box(Int, Int) | Blob` becomes `other @ (Line(_) | Box(_, _)
| Blob) => "many"`, and `_ => 4` after `Dot` and `Line(_)` becomes `Box(_, _)
| Blob => 4`, the comment the arm carries kept above it
(tests/frontier/tighten-demo/wild.mn). The roster is written at the arm's own
pattern node, so the arm keeps its body and its prose. The write costs nothing
at run time: the last arm of an exhaustive match runs untested, as the `_`
did. Three shapes are not the roster and are never counted: a `_` inside a
payload, which ignores a part the arm does not read; a `_` over a word, a
text or a list, the honest complement no roster could name; and a match's
only arm, which is a binding (`{ x => body }`, `match v { x => … }`), never a
dispatch. Once nothing in the wheel is left to rewrite the shape refuses —
the third step of `Hβ.match.catch-all-over-a-sum-is-the-roster`.

**A match of several arms dispatches; a match of one arm asserts.** `let [a,
b] = xs`, `let Some(v) = o`, a one-arm literal (`{ [h, ...t] => h }`) and
`match v { p => e }` are one graph — a match of one arm — and a parameter
written as a pattern (`fn h([p, q]) = p - q`) makes the same claim of its
argument; each ASSERTS the value's shape where several arms would dispatch
on it. So the case its pattern leaves is not a refusal: the shape is a claim,
decided along the value's edges as an index's precondition is (§«Partiality —
a primitive's precondition is a claim»). It is proven where every value the
scrutinee can be has the shape — `let [a, b] = [3, 4]`, `let Some(v) =
Some(a)` — and costs nothing; refuted where one is built otherwise — `let
Some(v) = None` is `E_RefinementRejected` at the let; and open otherwise, the
match's own row carrying the `Trap` a mismatch is, so `with !Trap` refuses a
destructure of a parameter until its shape is proven or its value is matched
by arms of its own. The arms of a match of several stay the roster of what it
handles. The law reads the patterns, never the spelling: the binder form
`([h, ...t]) => h` and the arm list `mentl fmt` writes it as assert one shape
with one meaning (tests/micros/mn-destructure-claim-proven.mn,
mn-destructure-claim-open.mn, mn-destructure-claim-refuted.mn).

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

The authored `repr <width>` suffix parses (`parse_repr_pin` after any
type-decl base) and the bare-width parameter pin (`s: f64`, `s: f32`, `i64`,
`v128`) mints the same `TReprPin` in type-atom position. The pin types
transparently — identity is the base's; `repr_of`'s own arm is the one width
reader — and since both spellings parse to one pin, the formatter decides the
spelling by POSITION: a pin at a type declaration's right-hand side renders
with its suffix (`type Coeff = Float repr f64`) and a pin in an annotation
renders bare (`s: f64`). The i64/f32/v128 pins carry full vocabulary; their
emission cash-outs ride the named wide-producer residue (the RF64 path is
fully live).

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
answers its head — as SYNTAX writes one, its parameters' types and its
inferred row, each parameter's ownership grade before its name — and the
address it is declared at (`inv(own n: Int) -> Int with Trap  at main:11`) before its parameters' and return's widths; a value
whose type is still a variable reads `a : a @ per instantiation`, since every
instantiation is specialized and takes its own width.
Every surface that shows a type — `where`, `doc`, `query … type of`, the
caret, the View, hover, every diagnostic — renders it through one projection,
the formatter's, with each free variable named by the render as a developer
would write it: a type variable by the name it was declared with, else the
first free letter; a row variable `e`, `e1`, … from an alphabet the type
variables never use, so `spawn(f: () -> a with e)` reads which is which. A
unit result writes no arrow, a parameter no author named shows its bare type,
and naming writes nothing into the graph (the head of every module-level
function comes back as itself through `parse∘render`, counted by `mentl query
<entry> heads`). A pin that names the width the gradient would already infer
is redundant (drop it; the gradient reaches it anyway), and so is a pin equal to the
floor on an integral type. **The same `repr` pin is a
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

**A predicate is an ordinary expression, judged where its type is declared.**
`self` is the value being refined, at the base type, and the expression must
be a `Bool`: the functions it calls are references (`refs of even` answers
`type Even = Int where even(self)`), and `mentl fmt` writes it back as its
author wrote it. What `Verify` decides is a projection of that expression the
type carries (tests/micros/mn-predicate-as-written.mn,
mn-refs-of-predicate-callee.mn).

**A predicate may perform, and the claim is then the install's to decide.**
`type Hz48 = Float where 0.0 < self && self < nyquist()`, with `nyquist`
reading the installed `Sample(48000)`, is a bound the clock answers: the
predicate's row rides the claim, judged where the claim is made under the
installs that stand there. The medium decides such a claim only where the
perform's answer is in sight; today it leaves it pending, honest debt the
board counts (examples/pulse/course/06-rate.mn), and the proof engine's
reading of an install's answer inside a predicate is §11's verification
whole.

**The bounds join with `&&` — there is no comparison chaining.** A chained
`-1.0 <= self <= 1.0` parses left-associatively as `(-1.0 <= self) <= 1.0`
(one precedence table, no special case), an ill-sorted `Bool <= Float` that
principle 2 already rules against as a second spelling of the conjunction, so
the declaration refuses: `E_TypeMismatch`, `Bool vs Float` at the outer `<=`
(tests/micros/mn-predicate-chain-refuses.mn).

```
let s: Sample = 0.5      // Verify discharges -1.0 <= 0.5 && 0.5 <= 1.0 statically
let p: ValidPort = 8080  // statically discharged
let bad: Sample = 1.5    // E_RefinementRejected — 1.5 violates the Sample bounds
```

**A claim over a join decides as the AND over its tails.** `fn note_hz(k: Int)
-> Hz = match k { 0 => 220.0, 1 => 261.63, _ => 440.0 }` discharges because
every arm folds inside the bound; one arm at `30000.0` refuses at the claim;
an arm that is not a constant (`_ => f * 2.0`) leaves the claim honest
`V_Pending`. `if`, `match` and a block's final expression are read by
STRUCTURE, never by guessing which arm runs, so a dead arm that writes an
out-of-bound constant refuses too — the claim covers every tail.

**A refinement crossing a function-typed argument is judged.** The argument's
RESULT, where the callee hands it to a refined position, is judged on the
lambda's own body: with `fn run(f) = alpha(f())` and `alpha(c: Hz)`, `run(()
=> 30000.0)` refuses and `run(() => 440.0)` discharges. The argument's
PARAMETERS, where it demands a refinement, discharge when the callee's own
type says it passes one (`fn drive(f, c: Hz) = f(c)`) and are honest
`V_Pending` otherwise — the values a callee passes are made inside the
callee, and judging them there is refinement variables' work
(`Hβ.verify.higher-order-refinement`).

**A refinement is a fact a VALUE carries, read along the edges it flowed —
never a property of its type.** A value is what its sources are: a constant is
its point, a reference reads its binder (a parameter's refinement, a `let`'s
annotation, a constructor field's declared contract), a join takes every
tail, a call is its callee's declared return, and a part a pattern
destructured is the argument at that position where its whole was built. A
computation inherits nothing: `fn dec(x: Positive) -> Positive = x - 1`
leaves `0 < x - 1` honest `V_Pending`, and `let d = if c { n } else { 0 }` is
the join of `n` and `0`, never `n`'s refinement. A refinement riding the
unification class would carry it onto every join and every operator's
result, and `ratio(t, n: Positive)` would demand Positive of `t`.

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
built, as it is assumed part by part where it is taken apart.** Under `r:
{den: Positive}` a field read or a pattern assumes `r.den` is `Positive`, and
so it does under `r: R` with `type R = {den: Positive}`, the nominal
record's field contract read along its name to the declaration
(tests/micros/mn-nominal-field-contract.mn), so every construction handed
there owes it of the part it builds:
`den_inv({den: 0})` refuses at the `0`, a list literal owes `[Positive]`'s
contract of every element, a tuple its position's, and a nominal contract its
constructors' fields read at the type's arguments — `Option(Positive)` owes
`Positive` of `Some`'s field and nothing of `None`, and `Result(Positive,
String)` nothing of `Err`'s. A part of a value built out of sight is read off
the value: held where every source states it at that part — a parameter's
precondition, a declared return, a let's claim — and owed otherwise, the row
its precondition guards paid where the claim is open. An index read is a part
read (`100 / xs[0]` under `xs: [Positive]` is total), and `let xs:
[Positive] = [0]` refuses where it is written.

**A function's contract travels with the function.** A lambda's parameter
learns its precondition as a declared one does — `(c) => alpha(c)` demands
`Hz` of every value it is called with — and every application owes it: a call
through the value, a function crossing, and a pipe stage, which applies its
stage and so claims of the piped value what a call's argument would owe
(`30000.0 |> alpha` refuses as `alpha(30000.0)` does). A function-typed
parameter learns from how its body applies it: the values every application
hands each position — `fn drive(f, c: Hz) = f(c)` hands its function `c`'s
values, which are `Hz`, and `fn feed(f) = f(440.0)` hands it `440.0` — and
what a refined position demands of the result — `fn run(f) = alpha(f())`
publishes `f: () -> Hz` — so a caller's crossing judges the function it hands
in: a lambda's body against the demanded result, its own demands against the
values the callee hands it. A stage completed in place — `x |> rig.f(5)`, a
`<|` branch — is one application with the whole product, so a record of
filters handed to a frame learns each cutoff the frame hands the filter it
pipes through, and a parameter a recursive call hands back to itself
teaches nothing (tests/micros/mn-refine-stage-through-field.mn). A `<~` cycle binds its lambda's parameter with no
application to raise a claim, so that parameter learns nothing and a demand
inside the body stays the body's debt.

**A function value is every function it can be.** A join of two functions, a
list or a record of them, a function a pattern took apart, a function a
generic call returns: applying the value owes the precondition of every
function it can be, conjoined per position, and the row each one guards —
`pick(false)(0)` over `fn pick(c) = if c { inv2 } else { inv }` owes `inv`'s
`Positive` whichever branch comes first. What a body HANDS a function is never
what that function DEMANDS: a function handed to `fn outer(g) = drive(g,
440.0) + g(30000.0)` is judged against both values it will be handed, not
against `drive`'s `Hz` as a demand of its own. A function moving through a
GENERIC callee is judged by the callee's signature alone — parametricity, the
callee's body never read: `fold(0, (acc, f) => acc + f(0), [inv])` hands the
list's `inv` to the callback, which applies it at 0, and refuses; a nominal
type's arguments carry their values the same way, so `opt_apply({ g => g(0)
}, Some(inv))` refuses through `Option(a)`. And what a body cannot see is
never assumed: a function parameter it returns, hands to another function its
caller chose, or places where the contract is a type variable is judged as
handed values nothing there can name.

**A function's contract is never lost at a position.** A declaration or a
lambda returning functions publishes, at every position of its return that
holds one, the meet of every function the position can hold: `fn pick(c) =
if c { {f: succ} } else { {f: inv} }` makes `pick(c).f` demand `Positive`
whichever branch runs — through a tuple, an `Option`, a list, a relay, a
module value and a parameter alike. A position whose type is STATED is
crossed by every function placed there, which pays there the guard of each
demand the position does not provide: an authored return (`fn mk() -> (Int)
-> Int = inv`), a nominal record's declared field (`Ops{f: inv}` under `{f:
(Int) -> Int}`), an op's declared return at `resume` (`resume(inv)` into
`get_fn() -> (Int) -> Int`), and the functions inside a function's result
where it crosses into a parameter that applies them.

**A tee's value is every value its install can answer.** The value walk reads
a `~>` node as the body's tails and each arm's tails of the installed handler
— an arm whose tail is the `resume` hands the remainder's answer through and
adds no value of its own — so `100 / (({ let _ = ask(); 5 }) ~> zero)` with
`zero`'s arm answering `0` is refuted (`E_RefinementRejected`), and with the
arm answering `5` it is proven under `!Trap` and runs; a label is read
through the same answers, so an arm answering an untrusted value brings the
label through the install (`tests/micros/mn-flow-tee-arm.mn`,
`mn-refine-install-answer.mn`, `mn-refine-install-answer-proven.mn`).

**An op's declared return is a contract every resume owes.** A performer
stands on what its op is declared to answer, so a refinement there is claimed
of the value each arm resumes with: under `get() -> Positive`, `get() =>
resume(0)` refuses where it resumes, and `inv(get())` owes nothing. A
resumed value the medium cannot prove is owed once, at the resume, never
assumed by every performer (`tests/micros/mn-op-return-is-a-contract.mn`).

**A label is an op named in a refinement over `self`, and what can bring it
to a value is read along the value's edges** (`PLAN.md §4⑥`). Under `effect
Trust { untrusted(v: String) -> Bool }`, `type Untrusted = String where
untrusted(self)` states the label and `type Trusted = String where
!untrusted(self)` states its absence. Presence is never claimed: a position
declared to hold the label — a function's declared return, a parameter, a
field, a let's annotation, what an op is declared to be handed — is where the
label enters. Absence is a claim: `exec(cmd: Trusted)` owes it of every
argument, and a value the label can reach refuses there
(`E_RefinementRejected`), the refusal naming where it entered (`untrusted
enters at main:20:30 through what read_cmd is declared to answer`). What can
reach a value is everything it is computed from — an operand, a splice, a
field placed in a record, a value stored in place into memory it reads, an
arm's answer, a state's writes — and everything that decides whether the code
computing it runs: a branch's condition, a call made under one, a statement
before it that can abandon. A function handed to another is applied to what
that function hands it, read at the install that runs it, so a stage handed to
`each` over an untrusted list reaches the sink with an untrusted element; a
parameter is what every call hands it. Endorsement is a declared return that
states the absence (`fn quote(s) -> Trusted`), read by callers and never
claimed of the body. A secret is the same law over another op (`type Secret =
String where secret(self)`, `log_line(msg: Public)`). Each declared
function's reading is a summary over its own parameters, read once per settle
and repeated to its least fixed point, so recursion terminates. `mentl query
<file> "flow of NAME"` says what a function answers, endorses and demands
(`tests/micros/mn-flow-*.mn`, each fixture's second line its contract at the
sink).

The predicate is a compile-time obligation; at gradient-top it erases entirely (no runtime check). `Verify`'s default ledger accrues what it cannot discharge statically (`V_Pending`); Verify's own solver discharges more of it as its fragment grows (`PLAN.md §11`, Verify's own solver: path narrowing, overflow-aware intervals, linear arithmetic, case splits by fork) — same source, deeper proof engine. An external solver plugs in only as a proposer whose certificate the kernel checks.

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

Each operation declares its parameters and its return type (if non-unit). **Resume cardinality is INFERRED at handler-decl time from each arm body** — never declared on the effect op. The infer pass counts resume call sites under control-flow ancestry; the inferred cardinality attaches to the op's `TCont` continuation type and drives lower's tier selection (Tier 1 direct call vs Tier 3 heap continuation).

**An op's parameters are a parameter product, named as a function's are** — `print(msg: String)`, `fail(msg: String) -> a`, `effect Sample(rate: Int)` — because the field's NAME is the key (§«Labeled call arguments»): a perform may be labeled, an arm binds by name, and every projection reads the name. The positional spelling (`fs_write_file(String, String)`, a bare type per parameter) still parses, and nearly every op in the medium's own source is written that way, its names living in the arms that bind them or in a comment above the op. That is the gap the naming sweep closes: the medium proposes each name from what its providers' arms bind (asking where they disagree), and once no op is left unnamed the bare form is refused.

The graph type is `TCont(R, S, ResumeDiscipline, World)`: `R` is the value
accepted by `resume`, `S` is the answer produced by the captured remainder,
and `World` is the exact capability world frozen with that remainder. `R` and
`S` are independent. A handler may resume a `Float` operation into a remainder
whose answer is `Int`; neither representation may stand in for the other.

### Invoking effect operations

An effect op is invoked as a **bare call** — the same surface as any
function call:

```
fn expect_true(value) = check(value, "expected true")   // check is the Test effect's op
```

The env binding proves op-ness (`EffectOpScheme`); the op's `TFun` row
carries `Closed[eff]` definitionally from its declaration. The enclosing
fn's `with` clause is verified against the row inferred from these call
sites. The reader who needs suspension points reads the row in the
signature or the cursor's projection — the medium narrates what a
keyword would only whisper.

**`perform` is not a keyword**: the word lexes as an ordinary identifier, so
a stale-fluency `perform check(...)` parses as ordinary expressions and the
general unresolved-name diagnostic teaches the bare call in context — no
bespoke recognizer, no format-lift class. `resume` keeps its keyword: it is
context-bound to handler arms, typed by the typed-resume law (`resume : R ->
S`), and names the continuation — a value the call site cannot otherwise
reach.

**A perform costs what a call costs.** An op's arguments cross at the widths
the site proves and its result comes back at the width the site proves,
exactly as a closure call's do — a Float op costs a Float call — and the arm
that answers is the one twinned at the install's instance, which is the site's
own instance, so no cell is built at an effect's type variable: `fn walk(xs:
[Float]) with !Alloc = { put(xs[0]); put(xs[1]) }` under `handler total with
s = 0.0 { put(v) => resume() with s = s + v }` runs and allocates nothing. A
perform under `!Alloc` is therefore admitted exactly when the op's own row is
— and a held or multi-shot op's row says `Memory + Alloc`, because reifying
the remainder is what such a perform builds (§«Resume discipline»).

**A wide value crosses a continuation in a register, never a cell.** The
caller of a continuation, and the driver that runs a multi-shot arm, are blind
to the types they call through — one word-arity face serves every chain — so
a Float resumed into a continuation, or answered by a multi-shot arm, crosses
in a per-instance register beside the word slot, set immediately before the
call and read immediately after it (the machine ABI's own shape: words in the
integer slots, a double in a float register), and a multi-shot op's arguments
cross in the yield's record at their widths. Nothing is boxed and no row
changes: the same two-resumption program at Int and at Float grows the heap by
the same bytes (`tests/micros/mn-multishot-float-answer-no-box.mn`).

### Unit return omission

An effect op that returns unit `()` declares no return:

```
effect Console { print(msg: String) }       // returns ()
```

`-> ()` makes the same graph as its absence, so it is a redundant form (Governing principle 2) and format-liftable: `mentl fmt` writes an op's head without it (`render_effect_ops`), and a function's authored `-> ()`, which the render carries back today, lifts the same way at the formatter landing. A projection never writes it either: `mentl where` still prints `-> ()` on a unit op, and the one head renderer every surface reads through ends that. A non-unit return is written, because an op has no body to infer it from: `read() -> String`.

**Never-returning ops** declare `-> !`, the never type: the op never returns
to its performer, so its arm never resumes — `abort() -> !` (the control cut
the Abandon discipline reads), `fail(String) -> !`, and WASI's
`proc_exit(Int) -> !` (the host ends the process). `!` is quantified per
PERFORM, never at the effect: each perform meets a result variable of its own,
so one function may perform `fail` where a list stands and where an Int
stands, and an effect whose only non-ground op returns `!` carries no type
parameter — `Fail` and `WASI` read as bare names in every row. That is sound
exactly because the arm never resumes: an arm that resumes a `-> !` op is
`E_ResumeOfNever`, armed. An arm ending in a never op answers any install,
which is what makes `fail_exit` installable over a body of any type
(§«Handler declarations»; `tests/micros/mn-resume-of-never-refuses.mn`,
`mn-never-two-result-types.mn`). A bare variable result (`ask() -> a`) is the
effect's own parameter: the install fixes it and the arm resumes a value of
it.

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
  tick()
  current_sample() -> Float
}

effect Budget(limit: Int) {
  spend(amount: Int) -> Bool
}
```

The effect name itself carries arguments. **Row algebra treats `Sample(44100)` and `Sample(48000)` as distinct effects**, and a body that performs both carries both, in either order: `fast() + slow()` under `!Sample(44100)` refuses exactly as `slow() + fast()` does. An instance's argument is a value the judgment carries at the type level: each perform's is a variable that a literal argument binds (§«The perform grounds its instance»), that a declaration's row binds, or that the install answering it binds, so `fn stage() = sample_rate()` runs at the rate of whatever declares or installs around it, specialized per rate as every instantiation is (tests/micros/mn-instance-declared-reaches-its-clock.mn). A declaration's free instances of one effect are one, so a function runs at one rate. Two instances are two row members unless they are the same value, and a negation refuses every member it cannot prove distinct, so an instance whose argument nothing grounds (an operand node) is refused by a negation of any instance it might equal (`tests/crown/leak-instance-order.mn`). A TYPE argument is not a value instance: an effect's type variables are shared across its ops, so one handler serves one instantiation and the install unifies the performs; a generic op quantified per perform is `Hβ.effects.two-instances-of-one-effect-do-not-join`.

### Installation in `with` clauses

```
fn audio_loop() with Sample(44100) + IO + !Alloc =
  ...
```

The argument is evaluated at install time and frozen. Two functions declared with `Sample(44100)` and `Sample(48000)` cannot interoperate without an explicit handler bridge, and the install is that bridge's one form: **an install serves the instance its handler's config names.** A handler's config parameter that shares its NAME with one of the effect's parameters is that parameter at the install — the perform's own grounding rule (§«The perform grounds its instance») read at the handler — so lib/dsp's `handler sample_at(rate)` serves `Sample(rate)`, and `~> sample_at(48000)` serves `Sample(48000)` alone. A handler whose config names no effect parameter, or whose config is computed where the install stands, serves every instance it cannot prove another. One law decides three readings, so the row says what the run does:

- **A perform reaches the innermost install serving its instance.** Nested clocks are two clocks: under `~> sample_at(48000) ~> sample_at(750)` an audio stage declared `with Sample(48000)` reads the inner one and a control stage declared `with Sample(750)` passes it and reads the outer, for an op that resumes and for one that never does (tests/micros/mn-instance-routes-multirate.mn, mn-instance-routes-abandon.mn).
- **An install subtracts only the instance it serves.** `fn play() with !Sample(44100) = rate44() ~> sample_at(48000)` refuses, the 44.1 kHz stage's instance passing the 48 kHz clock (tests/crown/leak-instance-passes-install.mn), and so does an install over a callback whose row is open where the install is judged (leak-root-instance-foreign-callback.mn).
- **An instance no install serves reaches the root.** A 44.1 kHz stage under only the 48 kHz clock is `E_EffectUnhandled`, the refusal naming the chain and proposing `~> sample_at(44100)` (tests/micros/mn-install-serves-its-instance.mn).

`mentl where` says which instance each serves: `handler sample_at absorbs Sample(rate), answers a` at the declaration, and in a function's badges `~> sample_at absorbs Sample(48000), answers Int` at each install, a computed config read as the name it is computed from (`Sample(r)`).

### Resume discipline — inferred, not annotated

Resume cardinality is **inferred from each handler arm body** at handler-decl time; the developer never types `@resume=`. The infer pass walks the arm body collecting resume call sites — its own, and those of the functions it declares, read where it calls or hands them on, since a `resume` stands only inside an arm and a function the arm declares is in scope nowhere else (tests/micros/mn-resume-summary-is-the-arms.mn); classifies via control-flow ancestry + branch-disjointness:

- **`OneShot`** (inferred when zero or one resume site, not under loop ancestor — or multiple sites all in branch-disjoint paths — AND the one use sits at the arm's RESULT position: the arm's value on every path is the resume itself, through `if`/`match`/block tails and a tail call into a helper that resumes at its own tail) — continuation lives on the stack; no heap capture; performance is direct-call equivalent. Compile error never fires here because the inference produces the correct kind from the body's structure.
- **The held single resume** (inferred when the one resume site is INTERIOR — bound by `let`, an operand, an argument, an element, a lambda body — so the arm keeps computing after the remainder returns: `ask() => { let r = resume(1); r * 2 }`) — the remainder is reified as the continuation record and called once; the code after `resume` runs when the remainder returns, and the arm's value is what the install answers (`ask() + 1` under that arm is 4; `tests/micros/mn-oneshot-nontail-resume.mn`). The grade is `ResumeUse` (types.mn): multiplicity × position, ownership's return-transfer distinction read on the continuation. The record is the honest cost of holding a continuation; dropping it after its one call, O(1), is `Hβ.lower.held-resume-record-is-not-reclaimed`. A held resume runs the remainder INSIDE the frame that calls it — the arm, or a callee the arm hands a resuming lambda to — so that frame's row carries the remainder's: the resume performs its continuation's world, the handler's remainder, and every install judges what the frames it runs through forbid against its own body minus what it absorbs. `fn apply(f) with !Log = f() + 0` refuses `apply(() => resume(1))` under an install whose body performs `Log` after the perform (`tests/crown/leak-resume-remainder.mn`). When that remainder performs one of the handler's own ops again, the resume re-drives the handler where it stands, deep semantics at any depth (`tests/micros/mn-held-resume-*-reyield.mn`).
- **`MultiShot`** (inferred when one or more resume sites under loop/recursion ancestry, or two sites both reachable from one path) — continuation captured to the heap as a closure. Enables backtracking, non-determinism, generators. **A MultiShot op's row carries `Memory + Alloc`**: the perform site reifies the remainder as a heap record, so performing the op IS an allocation, and a `!Alloc` declaration around such a perform refuses (`tests/micros/mn-multishot-perform-alloc.mn`). The op's discipline and cost are settled at pre-registration, from parse structure, so they never depend on whether the handler precedes its performers in source order.
- **`Abandon`** (inferred when the arm never resumes — zero resume sites, whatever the op's declared return) — the arm's value is the install's value and the continuation is DEAD: the perform UNWINDS, and nothing after it runs, in its own frame or in any frame between it and the install whose arm answers. The unwind is structured, never a bare return past a bracket: a frame leaves by its innermost landing — an install body's block, so the install's driver runs (its own op dispatches the arm; a foreign one bubbles) and its world restore follows; an arena body's block, so the arena EXITS as any extent does, the perform's arguments moving out of the region through their leaves (their slots in the argument area were journaled where they were stored) and the rest reclaimed — only a LIVE continuation suspends an arena; or the function's own return. Every boundary a raised flag can cross checks after it: a call whose callee's row may abandon, a direct arm call of a handler whose arms may, an install or an arena off the frame's tail, a fanout's spawn and join. An abandoning perform allocates nothing — its arguments cross in a per-instance area allocated once at start — so `with !Alloc` holds over it (`tests/micros/mn-abandon-alloc.mn`).

**A continuation is captured at any position.** A held or multi-shot perform suspends the computation around it wherever it stands — a `let`'s value, past a statement, an argument, a right operand, a branch, an element, a field, an arm's body, a `<~` body. Each frame (a function's body, a lambda's, an arm's, an install's, an arena's) is read once for the places a yield may leave it, and at each the frame's REMAINDER is minted as a function: the frame's own lowered tree zipped at that place, with what ran before it dropped, the branch it stands in kept alone, and its value the hole the remainder takes. Each value the remainder reads from before the place is captured into its record, beside the world the perform ran in and the `<~` lines the frame ticks, which stay the frame's own: a remainder reads the prior its cycle loaded and ticks the function's line, never one of its own. A call, an install or an arena whose row may carry a live continuation is such a place too: when the callee yields, the frame composes its remainder onto the continuation the callee's perform began, so each resumption returns through the call and finishes the frame. Under a handler that resumes `choose()` with 1 and then 2, `{ let x = inner(); x + 1 }` over `fn inner() = choose() * 10` answers `(10 + 1) + (20 + 1)`. A part of the frame that ran before the perform and is read after it is held in a register, so a resumption reads it and never runs it again: in `seven() * 5 + pick() + total()`, `seven()` counts once however many times `pick` resumes. An abandoning op, whose arm never resumes, mints no remainder: it performs from any position and unwinds (§«Resume discipline»). A live continuation that reaches a thread's join traps there, since no joiner can hold it (§`><`). The fifteen positions are `tests/micros/mn-capture-*.mn`.

**A resumed remainder answers to the world it is resumed in.** A continuation carries its own segment of the world it was captured in — every install between the perform and the install that caught it, that install included — and past that segment it reaches the installs standing where it is resumed, which is what the rows judge. So an install an arm wraps around its resume governs the remainder (`ask() => resume(0) ~> inner_get` answers the remainder's `get` from `inner_get`), and a continuation the arm hands out (`ask() => Paused({ x => resume(x) })`) and the program resumes later reaches the installs around that call. Each install's remainder — what its body performs past the effects the install handles — is held as an instance of its handler's world cell, so a negation over a resume judges it wherever the program states it: `fn sneaky(k) with !Get = k(1)` refuses for a `k` whose remainder performs Get, and a `k` resumed at the top of `main` with nothing answering its Get is `E_EffectUnhandled` at the root. An arm runs outside its install on every path, so its own perform reaches the handler outside, a held or multi-shot arm's included: the install's driver hands the body's pending perform to the arm once, and a yield the arm raises bubbles past it. The value a resume hands over is computed in the arm's world, before the remainder's is entered. A resume entering its continuation from a world other than the one its install caught it in copies the segment onto that world, so a held resume charges `Memory + Alloc` beside its continuation's world. (tests/micros/mn-resume-world-*.mn, mn-arm-own-perform-*.mn, tests/crown/*resume-escaped*.mn.)

The cardinality is **load-bearing on type+lower** — it's why Mentl can express real-time DSP and constraint-search backtracking under one effect algebra (and why a persisted multi-shot continuation is `memcpy`-serializable while a one-shot is a stack frame). But the **annotation form is drift**: authoring `@resume=` would declare what the body already proves. The body IS the contract — and because a fact this load-bearing must be legible ("systems explain themselves", `PLAN.md §0`), the cursor **projects** it read-only: `mentl where` shows the op's `TCont` as `R ->1 S` (one-shot) or `R ->* S` (multi-shot), a derived badge — never an authored annotation. The body remains the contract; the projection is output, not input.

### Negation in `with` clauses

```
fn pure_op(x: Int) -> Int with !Alloc + !IO =
  ...
```

`!E` proves ABSENCE of effect E. Stronger than not-mentioning E because it propagates transitively through the call graph: any callee that performs E causes the whole declaration to fail with `E_EffectMismatch`.

**The refusal names where E enters.** Every charge is noted on a node of the construct that makes it, so the Reason the refusal carries is the walk from the declaration to the perform — on tests/frontier/mn-effect-enters.mn, where `fn quiet(x) with !WASI = helper(x)` reaches the host three calls down: `declared as quiet; WASI enters at tests/frontier/mn-effect-enters:19:26 through `helper` → at tests/frontier/mn-effect-enters:15:3 through `log_it` → at tests/frontier/mn-effect-enters:12:18 through `print_string` → at io:209:3 through `fd_write_bytes` → at io:187:3 through `fd_write` → declared as fd_write, an op of WASI declared at io:45:1`. Each hop is a site in its own module's coordinates — a call or a stage names its callee, a tee its handler, a function value handed to a callee is entered, a construct that charges by itself is named (`building the list`), a value in scope is where the walk stops — and the message carries the first refused effect's chain. The same chain is the caret's Why at the declaration, one per effect of its row, and the answer of `mentl why <file> <fn> <Effect>`; `mentl why <file> <fn>` prints the declaration's reason and then every effect's chain. An effect an install absorbs enters through the install — the arm whose perform resolves outside it — never through the body it absorbs from: under `fn quiet() with !Log = work() ~> relog`, where `relog` answers `log` by performing `log` again, the chain names `relog`'s arm, not `work`'s `log` (tests/frontier/mn-effect-enters-absorbed.mn).

**And through the declaration's own parameters.** A negation on a function
that calls a callback is a GATE on that callback's row: `fn run(f) with !E =
f()` refuses `run(() => op())` at the call, and the refusal names `run`'s
declaration — under polymorphism, through a `~>` mask (`fn run(f) with !E +
!F = (f()) ~> h` with `h` absorbing E gates `f` with `!F` alone), across
forward references, sig'd recursion and stored callbacks, and
instance-precisely (`!Sample(44100)` admits a callback performing
`Sample(48000)`). A callback that is only RETURNED, never called, performs
nothing in the declaring body and stays admissible. The same gate is what an
authored negation on a function-TYPE parameter is: `f: () -> Int with !E`
constrains `f`'s row at every call of `f`, and beside it a sibling
parameter's row is judged on its own.

When used alone (e.g., `with !Mutate`), it creates a **negative capability stance** representing "anything except this effect" (universe-minus). This is how Mentl expresses region-freezes and borrows (`ref`) mathematically without a separate borrow-checker.

**`Mutate` is a store into memory older than the frame that makes it**: a parameter's memory, a capture, a module value, a part of another value, the feedback line a function's record owns. So `!Mutate` proves a function leaves every memory that existed before it ran as it found it, and `fn poke(ref xs) with !Mutate = list_set(xs, 0, 5)` refuses. A store into memory the frame allocated builds a value and performs nothing. A store into a parameter's memory performs `Mutate` in the function that makes it, and a caller pays it only where the argument it hands is older than its own frame: with `fn fill(buf, v) = list_set(buf, 0, v)`, `fn make() with !Mutate = make_list(1) |> fill(??, 4)` holds, and a caller that hands `fill` its own parameter hands the write on to its callers. An install answers its arms the same way: a state its init built is the install's own, and a config the arms write is charged by the age of what the install hands them. A `<~` tick writes its line, which every call shares, so `fn step(x) with !Mutate = ({ prev => prev + x }) <~ delay(1)` refuses. The members of a cycle say what they write when the cycle's judgment ends, read again until no claim grows. A function value carries its claim as it carries its contract — a lambda's and a nested fn's are written where their judgment ends — so a call through it pays `Mutate` only where the memory it reaches is older than the caller's frame: a parameter it writes by the argument handed, a capture it writes by the binder's age in the frame holding the value, its own feedback line by the value's age (a closure's line lives in its record), and the functions it applies by what the callee hands them, a fold's accumulator among them where the stage hands it back. So `fn run() with !Mutate = { let c = counter(); c(1) }` holds over a counter whose tick the closure's own row charges, and `fn k(buf) with !Mutate = { let g = { x => list_set(buf, 0, x) }; g(7) }` refuses, the capture being `k`'s parameter (tests/micros/mn-mutate-negation-refuses.mn, mn-mutate-tick-refuses.mn, mn-mutate-fresh-is-construction.mn, mn-mutate-closure-line-is-the-value.mn, mn-mutate-capture-fresh.mn, mn-mutate-capture-param-refuses.mn, mn-mutate-through-callback-param.mn).

**Modal-readiness is a mechanism, not a claim (`PLAN.md §4③`, forward-pointer).** The modal effect synthesis (rows + capabilities unified, closing the higher-order leak) threads effects as *lexical capabilities* through the EXISTING `~>` binding: `~> h` lexically scopes the effect `h` absorbs — that IS the capability mechanism. So the modal form adds only a typing rule (a row variable becomes a lexical capability handle at `~>`), no new surface form: rows give `!E`, `~>` gives the lexical capability, modal is their unification on forms that already exist. Sequenced post-real (§5).

`Pure` is shorthand for "the body's row must be the empty row (no present names, closed tail — `EfRow([], [], EtClosed)` in the kernel's canonical triple)":
```
fn pure_op(x) with Pure = x + 1
```

### The perform grounds its instance

An op parameter that shares its NAME with one of its effect's parameters is that parameter at the perform: the op's argument there is the instance's argument, so a literal grounds the instance where the operation is performed and the row carries it:

```
effect Environ(name: String) {
  env(name: String) -> String
}

fn port() with !Environ("SECRET") = env("PORT") |> parse_int   // accepted: Environ("PORT") is provably not Environ("SECRET")
fn leak() with !Environ("SECRET") = env("SECRET")              // E_EffectMismatch
fn read(n) with !Environ("SECRET") = env(n)                    // E_EffectMismatch: a computed name grounds nothing, and an ungrounded instance is distinct from none
```

A computed argument leaves the instance ungrounded, which is honest: the negation holds exactly when the reads it guards are literal.

### Configuration — the environment is an effect

The process environment is read through `lib/environ.mn`, where the variable's name is the instance:

```
import environ

fn main() = (env("PORT") |> parse_int |> serve) ~> env_from_host
```

- **`env(name)` is a required read**, and its name is written at the read: a computed name is `E_EnvNameUngrounded`, because the program's demand on its host could not be stated before it runs. **`env_opt(name)`** is optional and accepts any name, answering `Option(String)` (`env_or(name, fallback)` over it). A literal optional name is a narrow demand. A computed optional name is reported as `* [all optional]`: its value cannot be selected before execution, so the host deliberately grants access to its whole environment.
- **The demand is a projection, never a file.** `mentl query <entry> env` names each required and optional read beneath an install that crosses the host boundary (`env_from_host`), with its mode, site, and declaration. Literal reads give an exact roster. A computed optional read reports broad access explicitly. The projection is read at perform sites, since a row is free of `Environ` the moment the install absorbs it.
- **Required absence is checked before execution.** The compiler writes the roster into the module's start: before any of the program runs, its initializers included, every missing required variable is named with its read site and the process exits 1 (`PORT is read at main:3:14 (in main) and is not set`). Optional absence returns `None`. The check is the module's own, so it holds under any preview1 host.
- **The host follows the roster.** For literal names, `mentl run` takes each value from the shell, else from the project's `.env` (`KEY=VALUE`, `#` comments), and passes only those requested names as `--env`. If the roster contains a computed optional read, the shim passes the whole shell environment and `.env` values not already set in the shell. This is an explicit broad capability: it can expose credentials and toolchain variables to the guest.
- **Environment reads are guest data.** A value returned by `env` or `env_opt` is in guest memory and may enter a persisted image. `!Environ("API_KEY")` proves that the program does not perform that grounded read; it does not make values read under another name, supplied through another channel, or returned by another host service secret. Host-held opaque credentials need a host operation that applies the credential without returning it to the guest; that boundary remains open work.
- `env_fixed(pairs)` serves fixed variables for a fixture and asks no host, so nothing read under it is demanded.

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

A state init may read the handler's config — `handler window(size) with buf = make_list(size)`, `with n = cfg.x` — because each install builds its state from the config it was given, as a function of its own record, before the handler is installed: an init performs in the installer's world, and one that performs an effect its own handler alone answers is `E_InitPerformsOwnOp` at the declaration, as an install's argument performing one is at the install — each runs before the install exists, so nothing could answer it, and the refusal's chain names the perform.

### Handler chains — a composition is a value

```
handler judgment = affine_ledger ~> region_tracker ~> verify_ledger
handler judged_emit = emit_ctx ~> judgment

fn check(entry) = (judge(entry)) ~> judgment
```

`handler NAME = h1 ~> h2(cfg) ~> h3` names a COMPOSITION of handlers. An
effect row is a first-class kernel value, so naming a row is what `type`
already does (§«Named effect rows»); a handler composition is a value by the
same reasoning, and naming one needs no new form — the `=` opens the chain
where the arms would open, and the chain is a `~>` tree whose leaves are
handler references, bare or applied to their config. A member may be another
chain, which stands for its members.

**An install of the name is the installs of its members, innermost first,
and the graph holds exactly that.**
`body ~> judgment` is `body ~> affine_ledger ~> region_tracker ~>
verify_ledger` in every respect — the row (each member's absorption removed,
each member's arms added, each install's cost charged), the remainder gates,
the lowering, the Why walk — because the judgment WRITES those installs into
the graph at the install node, once: each member is instantiated at the
reference (a copy of its subtree, as a row alias's terms are copied where a
signature reads them, so a config argument is evaluated per install and a
handler's instance and answer are the install's own), the installs are nested
over the body, and the install's node is registered again as the outermost
of them. Every reader after the judgment asks the graph and sees the installs
the author would have spelled; the formatter writes `~> judgment` back, since
the install node is bound with the reference its author wrote
(`ChainInstall`), whose edge reaches the chain, and `refs of judgment` counts
the install.

A chain carries no config of its own — `~> judgment(x)` is
`E_HandlerChainShape` — and a member is a handler or a chain: a value that is
neither, or a member whose argument declares anything (a function, a handler,
a type, an import — `member_declarations` walks the argument), is refused at
the declaration with the same class, whether or not anything installs the
chain. The class is ARMED: nothing of a malformed chain compiles
(tests/micros/mn-handler-chain-shape-refuses.mn). The declaration installs
nothing and renders on one line, its members joined by ` ~> `.

### A handler is exhaustive

An effect declaration is a sum of requests and a handler is the arm list over
it, so the match law (§«Exhaustiveness») binds a handler as it binds a
`match`: **the arms answer EVERY op of every effect they answer.** A handler
with an arm for `inc` and none for `get` is `E_HandlerInexhaustive` at the
`handler` keyword, naming the ops no arm answers — ARMED, never a narration.

The law is what makes the install's row exact. `expr ~> h` subtracts from
`expr`'s row the effects `h`'s arms answer, by name; a perform of an op with
no arm would walk past the install at runtime and reach whatever is outside
it, which the row never saw: `fn f() with !State = (get() + inc()) ~>
only_inc`, `only_inc` answering `inc` alone, is the shape
(`tests/micros/mn-handler-partial-refuses.mn`).

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
[Byte] — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler
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
assembles (`tests/micros/mn-arm-answer-is-the-install.mn`,
`mn-arm-answer-observed.mn`, `mn-multishot-float-answer.mn`). A
never-returning op answers a bare variable
(`proc_exit(Int) -> !`), so an arm ending in one — `fail_exit`'s
`proc_exit(1)` — answers any install.

**The right side of `~>` is a handler, and its type says so.** The install
resolves its handler once, along the edge its reference draws, before the
body it governs is judged; whatever the right side is, its type meets
`Handler(P, A)` there, a configured handler named bare meeting it with its
scheme's result. So `ask() + 1 ~> r.zero` over a record whose `zero` is an
Int refuses `E_TypeMismatch` at the install
(`tests/micros/mn-install-of-a-non-handler.mn`). A handler held by a value —
`let h = one`, then `~> h` — types, and its emit names a global nothing
defines, so the module does not assemble: a handler named as a value has no
record yet (`Hβ.effects.handler-value-is-its-record`).

### State updates via `with` on resume

When an arm wants to evolve state, it uses a `with` clause on `resume`:

```
inc() => resume() with n = n + 1
```

The `with` clause lists state updates by field name. Unlisted state stays unchanged. A name that is not one of the handler's state fields is refused (`E_MissingVariable`, "state field: m") — the write would reach nothing anything reads.

**A state is every value written into it.** At any read in an arm, a state field holds its init or whatever some arm last wrote, so everything the medium proves of it is proven of all of them: `100 / d` over `with d = 5` owes `d != 0` of every write — `with d = d - 5` in another arm leaves the division's claim open and refuses under `!Trap`, and `with d = 0` in another arm REFUTES it where it stands (`E_RefinementRejected`: a writer that is the fatal point fails the claim as a join's `0` tail does) — a label a write brings reaches every read of the state, and a function written into it is applied under every function it can be. A state no arm writes is its init at every read and proves what the init proves. A write that reads the state it writes (`with d = d + 1`) reads it there as unknown, so a counter's bound is owed rather than proven; reading it as the claim's own hypothesis — an inductive invariant — is the named next step (`Hβ.verify.state-reads-its-invariant`).

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
keywording it collided with the codebase's most common identifier. The
retirement follows the turbofish precedent
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

`with !Consume` on the handler itself is the handler's own row — the same signed clause a fn signature carries, verified the same way — and it binds at TWO altitudes (the arm-world rule): the ARMS may not perform `Consume` themselves (the registration-time gate), and at every install the REMAINDER the arms resume into — the tee body's row with what this handler absorbs removed — may not perform it either, because resuming inside an arm continues that remainder under the handler. So `handler h with !F { op() => resume(1) }` installed over `op() + fop()` refuses at the install, naming `h`; installed over `op() + op()`, or over a body whose `fop()` an inner install absorbs, it holds; and `handler h with !E` over the ops it handles has nothing to check, since the absorption removes them. The check is per install — the body is read where it is known, never joined across installs into the handler's one row.

(`tests/crown/leak-arm-resume-remainder.mn`.)

---

## Named effect rows (capabilities)

Surfaces kernel primitive **#4** (the Boolean effect row). An effect row is a
first-class kernel value (`PLAN.md §2`), so **naming a row is what `type` already
does** — there is no separate `capability` keyword:

```
type File = Read + Write
type Network = Http + Dns
type ApiClient = File + Network
```

`type Name = <row-expr>` is a transparent alias (§Type aliases): `Name` unpacks to
its row at every site that takes a row, and `with File + Network` composes
structurally. Its terms are effect names, capitalized as every declared effect
is. The RHS uses the full Boolean algebra `+ - & ! Pure`:

- `+` **union** — `type ApiClient = File + Network`
- `-` **difference** — `type ReadOnly = File - Write` (admits `Read`, rejects `Write` at the structural gate)
- `&` **intersection** — `type Shared = ServiceA & ServiceB` (effects BOTH require — the natural typing of a `<|` divergent join); the identity `E - F = E & !F` holds (`inter_row`)
- `!` **negation** — `!Alloc` (universe-minus; transitive proof-of-absence)

```
fn fetch(url) with ApiClient = {
  let body = http("GET", url)
  write(local_cache_path(url), body)
}
```

A row alias is stored as its authored terms and expanded where a signature reads
it (`row_alias_triples`, src/effects.mn), so an alias that resolves to `Pure`
(everything subtracted out) simply IS `Pure` there: it adds no constraint and
can be dropped. A cycle through an alias's own expansion refuses
(`E_RowAliasCycle`), and so does a negated alias whose row is not positive and
closed (`E_RowAliasNegation`). A named row's terms are judged where they are
written, as a clause's are: each names a declared effect, another named row or
a row variable, and an instance's arguments meet its effect's parameters, so a
misspelled term refuses at the `type` (`E_MissingVariable`;
tests/micros/mn-effect-name-in-row-alias.mn).

A named row joins two or more terms, or opens with `!`. One name alone is the
type it spells — `type Locked = Lock` a transparent alias, `type Locked =
Lock(Held)` a type of one constructor — because a second name for one effect
is the redundant form, so `with !Locked` over it refuses as a name that is no
effect. A constructor that shares an effect's name shadows the effect in the
one namespace a link has today, and every row naming the effect then refuses
(the collision a module's scope settles, `PLAN.md §11`).

### A SIGNATURE IS NOT AN INVENTORY — name the capability, author the negation

**The measurement that makes this a rule rather than a preference.**
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
The POSITIVE row is inferred and PROJECTED: what a
signature authors is a decision — a negation, an instance pin, `Pure` — and the
full positive row is read at the address surface (`mentl <file:line>` renders
`-> T with Memory + Alloc`) the way `repr` width and resume cardinality already
are. So the normal signature is `with !Alloc + !Thread`: shorter *and* the part
worth reading. Three mechanisms carry it:

- **`T_RowInventory`** narrates a clause whose bare positive names the body's
  row proves, every one, where that row is GROUND — a cell nothing charged, or
  a resolved row with no free terminal (`enforce_row_gate`, src/infer.mn). Over
  an OPEN body row (a callback's row rides its tail) the bare names are a CAP
  and the cap is a gate (below), a decision rather than an inventory, so
  nothing is narrated. `T_OverDeclared` keeps the ground case where a declared
  name is beyond the proven row, and reads the positive half only: a
  negation-only signature is never "over-declared" (it used to narrate
  `!Mutate + Any` against a Pure body).
- **`mentl tighten`** writes each narrated clause's RESIDUE — its negations and
  instance pins, or no clause at all — never the proven row. The medium
  authored its own migration: 1,490 clauses, the wheel judging clean through
  the inferred rows with zero `E_EffectMismatch` — its negations had been true
  all along.
- **`mentl verify` bounds the shape** (`CsAuthoredPositiveRow`, `src/board.mn`)
  at ZERO on the wheel: a capability nobody authors needs no name.

**A positive row that survives is a CAP, and the cap is a gate.** `fn run(f) with E = f()` says `run`'s body, callbacks
included, performs at most E: the argument edge for `run(() => op_f())`
refuses `E_EffectMismatch` naming `run`'s declaration, exactly as a negation
does, and a `~>` mask inside the body widens what reaches the gate (`Pg ∪
mask` on the push: `fn run2(f) with E = ((f()) ~> hf) + op_e()` admits a
callback performing F, because `hf` absorbs it before the gate). So a
positive row on a HOF is a decision the medium
enforces; write one when the cap is meant, and let inference project the row
otherwise. The two micros that carried `with Abort` on a try/catch HOF whose
thunks allocate and choose refused on arming and lost their caps — a positive
row cannot say what their comment asked of it (`try_with_abort_catch`: a row "to
allow the outer scope's effects to flow").

There is no `capability` keyword: `capability X = <row>` would be structurally `type X = <row>` — a row is a type-level value, so naming one IS a type alias, and a second keyword for it is the redundant form Governing Principle 2 rejects. Nominal row identity would be record-style branding; capabilities want structural composition, so the transparent alias is the ultimate form.

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

Patterns appear in `let`, `match`, function parameters, lambda parameters and
handler arm arguments.

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
| `PAs`               | `name @ pat`, `name @ (p1 \| p2)` | binds `name` to whole value AND destructures via `pat`; over a parenthesized alternation, under any branch |

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
in, and `with !Alloc` refuses it (`tests/micros/mn-list-rest-alloc.mn`).
`..._` cuts nothing.

**A sub-pattern is the cell of the part it takes apart, and a binder is
declared where it is written.** In `Pair(a, b) => a / b` the `b` the arm
reads reaches the `b` the pattern binds, and the caret's Why there names that
line; the two elements of `[x, y]` are two values, a rest is a node of its own
(a binder, or `_` holding its presence), and `w @ pat` names the value its
position takes apart. A destructuring pattern's shape claim is located at the
value it claims (tests/micros/mn-declared-*.mn).

**Every binder is declared where it is written.** A let's binder and a match
arm's are their pattern's nodes, each the cell of the value it names, so the
edge from `total` reaches the `total` the let binds, and `mentl
<file>:<line>:<col>` at a binder says its uses — the sites the page's find
draws at the same caret (tests/micros/mn-declared-let-binder.mn,
mn-declared-arm-binder.mn). A parameter is declared the same way: it is a node
of its own, the cell of the argument its position takes, holding its pattern,
its annotation, its default and its ownership marker, and its pattern binds
against that cell as a let's binds against its value. So the caret at a
parameter's name names the parameter and says its uses, and a destructured
parameter is its pattern, with no name minted for it
(tests/micros/mn-declared-fn-param.mn, mn-declared-lambda-param.mn). A
handler arm's arguments are parameters by the same rule, each the cell of the
op's argument at its position, so an arm takes a pair apart where its body
begins (`give((a, b)) => resume(a + b)`). A state field's name is the binder
of its init, and the name a `resume … with` update writes is a node linked to
it, so the caret at a field lists its reads and the updates that write it, and
the Why at an update's name walks to `state n of counter`
(tests/micros/mn-declared-arm-arg.mn, mn-declared-state-field.mn,
mn-declared-state-write.mn, mn-arm-arg-pattern.mn).

**A head and a pattern bind each name once.** Two binders of one name —
across a head's parameters and inside their patterns, or in one pattern —
leave a use that could reach either, and a parameter list holds one field per
name, which a label names. The second is refused, naming the first
(`E_DuplicateBinder`). The branches of an alternation bind the same names by
law and are not two binders (tests/micros/mn-duplicate-binder-head.mn,
mn-duplicate-binder-pattern.mn).

**A rename is one write at the declaration.** Every
reference renders the name its edge reaches, a label the name of the
parameter its slot fills, and a comment's backticked mention is an edge as
well, so `mentl rename <file>:<line>:<col> <name>` writes the new name where
the declaration holds it — a binder, a declaration's head, a constructor's or
an op's entry — and rewrites each mention along its edge. The program is then
judged again, its rewritten files read from memory, and its edges compared
with the edges it drew: a rename that would move one — a use another
declaration of the new name captures, a use of the new name the renamed
declaration captures, a mention that resolves elsewhere — or that would leave
an error, writes nothing and says why. A name written inside a type renders
from the type's value, so a rename that reaches one refuses; so does a new
name that breaks the case rule or is a word of the language, and a
declaration outside the program's own layer. The battery states each verdict
as `// rename L:C to NEW: N name(s)` or `refuses <word>`
(tests/micros/mn-rename-*.mn).

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

**An alternation stands wherever a pattern does** — an arm, a constructor's
payload (`W(Dot | Line(_))`), a record field (`{kind: Dot | Box(_, _), n}`),
a list element (`[Dot | Line(_), ...rest]`) — so the parens around a grouped
one in those positions are the redundant spelling, and `mentl fmt` writes
`W(Dot | Line(_))` for `W((Dot | Line(_)))`
(tests/micros/mn-payload-alternation.mn).

**Layout**: an alternation renders inline when it fits
and past the width one branch per line, each continuation led by its `|` —
the roster a catch-all stood for is often forty names, and the parser passes
over the newline before a `|` as layout. Branches that each bind the whole
value under one name render as that binder over the group, `b @ (C(_) | D)`
(§«As-patterns — rule»).

### As-patterns — rule

`name @ pat` binds the whole value and destructures it in one arm; the binder
carries the scrutinee's own type, and the match predicate is the inner
pattern's alone.

`name @ pat => body`: binds `name` to the entire matched value; `pat` destructures it further. `name` and any bindings inside `pat` are all available in the arm body. Common for "need the whole value AND some pieces" cases — event forwarding, logging, pass-through.

**The binder over a group**: `name @ (A | B)` binds the whole value under any
branch of the alternation it groups — the spelling `mentl tighten` writes for
a binder that stood over a sum — and a parenthesized pattern is that pattern,
since there is no product of one: `(A | B)` is the alternation, `(a, b)` the
pair as before. One spelling for one graph: `b @ C(_) | b @ D`, every branch
under the same binder, is the tree the formatter writes back as `b @ (C(_) |
D)`, one branch per line past the width
(tests/micros/mn-grouped-as-pattern.mn).

`@` is TAt (reserved for handler annotations more generally; no current load-bearing user-facing `@`-form on effect ops — `@resume=` was erased per the inference-from-body discipline). Context disambiguates if other `@`-forms are introduced in future kernel additions.

---

## Imports

### Canonical form

```
import path/to/module
```

The path is a slash-separated module name, and **a module's LAYER is read off
the root that resolved it** — `User` (the program's own directory), `Lib` (the
runtime library, `lib/` of the repository or of the installed home) or
`Compiler` (`src/`). An importer probes the roots its layer may reach: a User
module its own directory, then the library roots; a Lib module the library
roots alone; a Compiler module every root. So a program resolves against its
own project and the runtime library, and the compiler's roots are never
offered to it: a user's `import graph` names no module and refuses
`E_MissingModule` with the paths it probed. A file the
program's own folder holds is the program's whatever it contains — a project
whose folder is this repository reaches `src/graph` as its own file, under
its own layer. A lib module importing the compiler is unconstructible by the
same rule, so no second diagnostic names it. The layer
rides every report from its writer: on the file route (`check`, `run`,
`compile <file>`) the register renders the narrations of the entry's own layer
and the debt summary counts only its obligations — a developer sees their
project, never the library beneath it, and a maintainer checking `lib/io.mn`
sees the library's. The stdin route and the board read every layer. A module's
own imports probe from where IT was found — a user module's folder, a library
module's root — so `sub/b`'s `import c` is `sub/c.mn` beside it, and the
entry's `import sub/c` is the same file: the walk keys a module by the path a
spelling resolved to, so two spellings of one file are one module and one
edge, and one spelling of two files is two modules — a program's own
`lists.mn` beside the library's (`tests/frontier/user-link/nest` holds both
shapes). Each module is a node of the program's link, and an import is an
edge to the node it resolved to, never a name matched again. A
repository-relative
spelling (`lib/lists`) names a module only where the program's own folder
holds the repository's layout; the library's name is `lists`.

### Selective import

```
import path/to/module {name_a, name_b, name_c}
```

Only the listed names are brought into scope. The parser reads the path and stops today (`ImportStmt` carries the path alone), so the selective set, and the collision refusal below that rests on it, are the lathe's next turn — the module as a scope, `Hβ.driver.per-module-env-overlay`. A link is one namespace today, so a program's `fn count` beside the library's refuses link-wide (`E_DuplicateFnName`, tests/micros/mn-link-name-collision-refuses.mn).

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

- **Pure prose, graph-attached.** Contiguous `//` lines concatenate to one String; a blank `//` line is a paragraph break. The comment attaches to the immediately-following declaration (`fn`/`type`/`effect`/`handler`/`let`), or — with none — to the enclosing block / the file's `Module` handle; a decl-boundary comment is **never dropped**: a run at the file's tail, with no declaration after it, attaches to a unit carrier that renders as its prose alone. An INTERIOR comment (inside a `{ }` body) attaches to the finest FOLLOWING node — the next statement, the final expr, or the block's own unit node when nothing follows — and a TRAILING same-line comment attaches BACKWARD to the node whose line it shares (same-line is structural: the comment token sits before any newline, one token of lookahead). Both are graph content in the same weave the decl comment fills, judged by the same backtick gate, and the address surface renders the attached prose's first line as the `Lede:` facet. A match arm's pattern is a node, so a comment above an arm, or trailing its `=>`, attaches to the pattern, and `mentl fmt` writes it above the arm. **Attachment is by SPAN, so an ANONYMOUS node is a home like any other**: a comment above a lambda inside an argument list attaches to the lambda (`Lede:` at the lambda's address, its backticked params resolving through the enclosing decl's binders), and a lambda's span is its whole extent, head through body, so `mentl <file:line>` on the lambda's line reaches it — the address rule and the weave's rule are one question, and the span is the one fact both read. Expression-interior comments elsewhere (inside parens / match-arm headers) attach by the same span rule (`Hβ.parser.expr-interior-comment-attach` names what the gate has not measured there).
- **Register is a projection, not a delimiter.** How much surfaces — the one-line lede, or the full body — is the gradient reading the comment's relevance at the cursor (the same gradient that drives every projection), NOT an author-chosen `//`-vs-`///` audience split. The author writes prose; the cursor decides what shows. First sentence = lede.
- **Surfaces verbatim, rendered per target.** The substrate stores the raw String; render handlers interpret presentation — HTML `<code>` for `` `backticks` ``, terminal ANSI, markdown fence. `` `backticks` `` cross-reference identifiers; the author writes the reference, the handler resolves it — **in the comment's own module's reach**: a declaration of its own module, of a module it imports or of the prelude, a binder of the commented node, a keyword or surface word, or a word a string literal of a module it reaches writes (the WAT and WASI vocabulary the emitter's literals write resolves in the emitter, and nowhere the emitter is not imported). A resolved reference is a mention edge to what it names — a binder's as much as a declaration's — so a rename rewrites the mention along it. A name the whole link carries but the module never imports is no edge the module can draw, so it does not resolve: `W_CommentRefUnresolved`, and the author points the reference at what resolves or writes the word as prose.
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
exactly as the bash scaffolds absorb into verbs (`CLAUDE.md`). What `//`
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
- **Not a blessing.** Prose cannot canonize a compensation: a residue's comment names its RETIREMENT CONDITION (the peer, the count that drives to zero), never its permanence. "Deliberate" written by the builder over a standing cost is the costume, not a fact.
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
carries the spliced node's type, **effect row** and labels up into the
enclosing string-construction expression: so `"{network_call()}"` adds the
call's effects to the row, and `exec("sh -c {cmd}")` over an untrusted `cmd`
refuses at the sink (§«Refinement types», `tests/micros/mn-flow-splice.mn`) —
not a runtime surprise. Splice rendering
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

There is no `'...'` literal form, no `'''...'''` variant and no `{{`/`}}` brace-doubling: a splice-free `"abc"` and `'abc'` would produce one byte-sequence graph, and literalness is a property of a *region* (`\{`), read by the cursor — never a mode hoisted onto the quote character. One sequence kind ⇒ one string surface.

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
chain back to the `++` site — `E_TypeMismatch`, its Reason naming the `++`
(`infer_binop`): a type error, not a dispatch artifact.

**Drift-refusal preserved:** `++` never fabricates a result for a genuinely
untypable operand — it surfaces the unification failure with a Located reason (the
no-silent-fallback law, `PLAN.md §9.2`). **Dissolved:** the
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
B(Int) | A`, `B(5) < A` holds.

**Drift-refusal preserved:** `==` on a heap value never emits pointer comparison —
pointer-eq lying as structural equality is the silent fallback `PLAN.md §9.2`
deletes. The derivation is **total over the five node-kinds** — this general
definition, never a carve-out per shape; `str_eq` is the byte-sequence instance
the surface `==` lowers to, never a developer-facing primitive.

**Two holes in that totality, both closed, kept for what they teach.** (1) An
operand whose type is still a VARIABLE where the comparison is emitted has no
structure to read, and the one-word compare it would fall to is an address
lie for anything but a word. It REFUSES: `E_ShapeUnprovable`, armed, said at
the comparison before a byte of the module exists — the same refusal a show,
a hash and a `++` of such an operand take. (2) A POLYMORPHIC sum compared its
payload by ADDRESS while the monomorphic one compared by value, because the
generated helper was keyed on the nominal name alone; the sig folds its
arguments so each instantiation names its own leaf, and the specs ground
against them, so the payload recursion calls its own type's helper
(`tests/frontier/mn-eq-polymorphic-sum.mn` holds the contract with its
monomorphic control beside it). The transferable half: (2) was invisible to
(1)'s census because the unprovable operand sat inside a generated leaf rather
than at an authored comparison. A census that measures one surface does not
see the same class one layer in.

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

**The demand belongs to the JUDGMENT, as a gate on the cell.** `{x: 1} * {x:
2}` refuses at the operator (`tests/frontier/mn-arith-on-aggregate.mn`);
`scale({x: 1}, {x: 2})` over `fn scale(a, b) = a * b` refuses at the argument
edge that binds the copied gate, naming `*`'s site
(`mn-arith-on-aggregate-twin.mn`); a copy minted before the demand — a
signature'd fn's self-reference — is reached through the instance column
(`mn-arith-on-aggregate-instance.mn`); and `mentl check` says so in every
case. At emit nothing is decided: a word emits at its type's repr, and a
variable still free there is a FLOOR twin's quantified var — every wide
instantiation, through a reference included
(`tests/micros/mn-arith-generic-ref-float.mn`), mints its own twin and binds
the var under it — so it is a word at the floor width by construction. An
emit that read only the operands' WIDTHS multiplied two record addresses with
zero diagnostics. Arithmetic on a USER type is not pointer arithmetic and not
a trait: it arrives as a numeric projection's rules
(`Hβ.lower.ad-is-a-demanded-projection`), the same mechanism that makes a
chain differentiable.

### Addresses — the word that names memory

An address names memory: the raw memory operations read from and write to
one (lib/memory.mn's `Memory`). Its type is `Addr`, and it is a word in every
machine respect — one i32, equal by identity, hashed as itself — and NOT a
number. `alloc` and `heap_mark` answer one, `Cast`'s `addr`
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
operands, with three outcomes:

| The claim at `a / b` | Outcome |
|---|---|
| a constant divisor that is not 0 (and, for `/`, not -1 — or a constant dividend that is not INT_MIN) | PROVEN — the site charges nothing |
| a constant zero divisor (`1 / 0`), or `INT_MIN / -1` by constants | REFUSED — `E_RefinementRejected` at the site: the program's meaning is a trap |
| a divisor one of whose sources IS the fatal point — a join's tail (`100 / (if c { 5 } else { 0 })`), an installed arm's answer (`100 / ((…) ~> zero)` with `zero` answering `0`) | REFUSED — the text writes the trap on that tail, as a claim over a join refuses at the tail that folds false |
| a divisor whose every source EXCLUDES the fatal point — a constant, a length, or a parameter whose refinement does (`Positive` (`0 < self`) excludes 0 and -1; `NonZero` (`self != 0`) excludes 0, so it proves `%` outright and `/` only beside a dividend that cannot be INT_MIN) | PROVEN — and where it stands on a parameter's refinement, the `Trap` waits in that parameter's guard, paid by a caller whose argument claim is open |
| a module value bound to a constant (`let lanes = 4`) | PROVEN — the fragment reads the let's own node |
| anything else — a parameter nothing bounds, a local, a call | OPEN — the site charges **`Trap`** into the row |

`Trap` is the effect the substrate performs when a partial primitive's
precondition fails (`effect Trap { trap() -> ! }`, lib/memory.mn — its one
op the deliberate trap, `out_of_range()`, which never returns and says so,
so it stands where a value of any type is owed, as the
complement arm of a match over a word the representation bounds; nothing
handles it, and its absence is the whole point of naming it). It is a row
fact like `Alloc`: inferred and projected (`fn ratio(t, n) = t / n` renders
`-> Int with Trap` at the address surface), transitive through calls, and
provable absent — `fn ratio(t, n) with !Trap = t / n` refuses
`E_EffectMismatch`, `fn ratio(t, n: Positive) with !Trap = t / n` accepts.
The gradient PROPOSES the annotation: at `fn inv(n) =
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
so `(1 / n) * 0` traps at `n = 0` as written.

What the fragment cannot yet read, named: a guard on the PATH (`if b == 0 {
None } else { a / b }` — a read up the parent edge the verifier has not
grown, `Hβ.verify.partiality-reads-the-path-narrowing`; the wheel's two open
division claims, both in `int_fold`, are of this shape), and the other partial
primitives — an index out of range (`xs[i]`, whose precondition needs the
same path read), a slice past its sequence — which are the same law one
primitive over (`Hβ.effects.index-partiality-is-a-row-fact`). A destructuring
pattern is that law one form over: the shape it asserts is its precondition,
decided by the same walk (§«Exhaustiveness»). Non-termination is not a trap
and not in the row (`Hβ.effects.divergence-is-a-row-fact`).

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
with a value: `(1) >< (2) |> inc` runs as `(1, inc(2))`, never
`inc((1, 2))`). The parens are the source's own
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

The parser accepts any whitespace; the precedence table alone draws the tree (Governing principle 1). Tabs are converted to spaces at save. Indent is a render decision, never a parse contract — there is no ill-indented program, only un-normalized source the formatter has not yet touched.

**Render rule** (canonical):
- The formatter renders code in canonical 2-space / 4-space form on save.
- **A render that would lose what the author wrote is not written.** `mentl fmt` lexes its render beside the source and spends every identifier, literal (by value, so `48_000` and `48000` are one) and prose line of the source against the render's; anything left unpaid is a loss, the verb names it with its line, leaves the file untouched, and exits nonzero.
- **The head of a postfix form keeps its parens.** A call, a field read and an index bind tighter than every operator, so a callee, a receiver or an indexed value that is anything but an atom renders parenthesized: `(r |> keep).level`, `((a, b) => a * b)(2, 3)`, `([1, 2] ++ [3, 4])[2]`. Rendered bare, the re-parse would take the postfix onto the head's last operand under "names conserved", because no name is lost; a render that re-parses to a different tree is not yet refused (`Hβ.fmt.render-must-parse-to-the-same-tree`).
- **An arm list is its own delimiter.** A recurrence whose body is an arm
  list renders bare, `{ prev => a * x + (1.0 - a) * prev } <~ delay(1)`, and
  so does a literal standing as a stage or a branch; the binder form keeps
  its parens, `((prev) => body) <~ delay(1)`, because its body extends
  rightward and a bare render would re-parse the verb into it.
- **A destructuring let renders as the let.** The parse makes `let (a, b) = v` and the rest of its block one arm of a `match`, the same graph a hand-written one-arm `match` makes; the match a let becomes is born remembering it, so `mentl fmt` writes the let back at the block's indent and a written `match` stays a match.
- **A tuple, a list or a `><` fanout past the width breaks** — one element per line, or §`><`'s vertical layout — as a call's arguments and a record do.
- The `Format` effect at `src/format.mn` declares one op, `format_program`; `format_default` is the canonical handler.
- The editing surfaces format as a projection — keystroke → parse → format → render — so the developer never sees badly-indented code: the page's canvas re-renders the canonical form on idle, never mid-keystroke (the canvas landing), and `mentl edit` takes one action per invocation today (`Hβ.felt.edit-session-reads-one-action`).
- The LSP transport (external editors via VS Code / vim / Emacs) answers no formatting request yet; its format-on-save is the same `format_default` read, one more method on the server's dispatch.
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

Format is idempotent (`format(format(x)) == format(x)`), so the incremental cursor's fixpoint converges in one iteration, and `mentl fmt` writes its own fixpoint in one invocation (it renders, re-parses, re-renders, and writes the second render). The format problem dissolves into the cursor projection.

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
`main`. `main`'s declared row judges `main` alone
(`Hβ.effects.executable-row-includes-inits`).

A module value let binds every binder its pattern writes, and a discard runs
its value for effect. The init stores what one binder names and nothing
else today, so a module-scope `let _ = e`, `let 5 = e` or `let (w, h) = e`
refuses where the program is emitted (`E_InternalInvariant`), never runs
without the value it was written for
(tests/micros/mn-module-let-discard-refuses.mn,
mn-module-let-destructure-refuses.mn; PLAN §11.18).

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
  // Early exit is an arm that never resumes: its perform unwinds to the
  // install whose arm answers (§«Resume discipline», `Abandon`).
  // The gradient teaches the substrate at the friction-point: when a user
  // types `for x in xs`, `E_NotAKeyword` surfaces a Quick Fix to the
  // verb form `xs |> each({ x => ... })`.
  // ITERATION IS TOPOLOGY, stated whole (2026-07-30): structural walks
  // are derived folds/`each`/`map` over the data's shape, cycles are
  // `<~`, search is handler resumption. Named recursion stays LEGAL —
  // but an index-threaded self-call (`f(xs, i + 1, n)`) is the
  // imperative loop in recursion's costume (`mentl audit`'s
  // iteration-shape tier names it), and polymorphic recursion infers
  // within the decidable fragment the judgment's rounds reach, pricing a
  // signature only past it (`T_PolyRecursionSignature` teaches it there —
  // inference beyond the fragment is undecidable, the price is real math).

  // ─── Identifiers and literals (carry payload) ─────────────────────
  // Constructors share ONE namespace (env entries). The literal tokens
  // are named TIntLit/TFloatLit because Ty's canonical nullary
  // TInt/TFloat already claim the bare names — two declarations claiming
  // one constructor name shadow silently and mis-unify.
  | TIdent(String)
  | TIntLit(Int)
  | TFloatLit(Float)
  | TComment(String)                // // — every comment is graph content,
                                    //   attached to the next decl / enclosing node
  | TStringPart(String)             // a literal chunk of a "..." string; a
                                    //   splice-free string is one chunk
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
| `TFn`           | `fn`             | —         | start of a function declaration (never a literal's head — `E_RedundantFnOnLambda`) |
| `TLet`          | `let`            | —         | start of let-binding                           |
| `TIf`           | `if`             | —         | start of if-expression                         |
| `TElse`         | `else`           | —         | between if branches                            |
| `TMatch`        | `match`          | —         | start of match-expression                      |
| `TType`         | `type`           | —         | start of type declaration                      |
| `TEffect`       | `effect`         | —         | start of effect declaration                    |
| `THandler`      | `handler`        | —         | start of handler declaration                   |
| `TWith`         | `with`           | —         | effect clauses, handler state, a resume's state update |
| `TResume`       | `resume`         | —         | inside handler arm body                        |
| *(removed)*     | —                | —         | `for`, `in`, `loop`, `break`, `continue`, `return`, and `perform` are NOT Mentl keywords. Iteration uses the pipe verbs and the Iterate effect; early exit is an arm that never resumes; ops are bare calls (`perform` dissolved 2026-08-08). |
| `TImport`       | `import`         | —         | top-level import statement                     |
| `TWhere`        | `where`          | —         | refinement type clause                         |
| `TOwn`          | `own`            | —         | parameter ownership marker                     |
| `TRef`          | `ref`            | —         | parameter borrow marker                        |
| `TPure`         | `Pure`           | —         | `with Pure` declaration                        |
| `TTrue`         | `true`           | —         | Bool literal                                   |
| `TFalse`        | `false`          | —         | Bool literal                                   |
| **Identifiers and literals (6)** |  |           |                                                |
| `TIdent(s)`     | `[A-Za-z_][...]` | name      | variable refs, fn names, type names, etc.      |
| `TIntLit(n)`    | `[0-9][0-9_]*`, `0x[0-9A-Fa-f_]+`, `0b[01_]+`, `0o[0-7_]+` | i32 value | integer literal (decimal / hex / binary / octal; underscores allowed for readability) |
| `TFloatLit(f)`  | `[0-9][0-9_]*\.[0-9][0-9_]*` | f64 value | floating-point literal (underscore separators allowed) |
| `TComment(s)`   | `// ...`         | comment text (contiguous lines concatenated, leading `//` stripped) | graph content; attaches to next decl / enclosing node |
| `TStringPart(s)`| a literal chunk of `"..."` or `"""..."""`, between splices; a splice-free string is one chunk | chunk text (escape-resolved) | string literal and interpolation (→ `MakeStringExpr`) |
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
| `TLBrace`       | `{`              | —         | blocks, records, arm lists, effect and handler bodies |
| `TRBrace`       | `}`              | —         | close LBrace                                   |
| `TLBracket`     | `[`              | —         | list literals, list patterns                   |
| `TRBracket`     | `]`              | —         | close LBracket                                 |
| `TComma`        | `,`              | —         | separator in tuples, params, fields, lists     |
| `TDot`          | `.`              | —         | field access                                   |
| `TColon`        | `:`              | —         | type annotation, record field binding          |
| `TSemicolon`    | `;`              | —         | canonical-never — newlines separate statements; lexed so the formatter can lift it to newline layout |
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
| `THole`         | `??`             | —         | hole — the gradient's syntactic absence marker; Mentl's Synth proposes candidates filling the position. Single `?` is no longer a token. |
| **Layout / structural (2)** |     |           |                                                |
| `TNewline`      | `\n`             | —         | statement separator; transparent around binops (layout is never semantics) |
| `TEof`          | (end of input)   | —         | always last token; parser uses to terminate    |

**Checksum: 62 variants** (17 keywords + 6 identifiers/literals + 14 two-char operators + 23 single-char operators/punctuation + 2 layout) — a reviewer cross-check that the `TokenKind` declaration and this catalog enumerate the SAME set; the hand-maintained stand-in for `mentl audit` until the cursor projects it from the graph. Exhaustiveness over the ADT (§Lexer/Parser obligations) IS the cardinality guarantee — the number is its shadow, not its source. (`TColonColon`, `TCapability`, `TTilde`, and `THandle` are absent: a token with no kernel correspondence is speculative inventory — and `handle` is the medium's own domain noun, not a keyword (§«Installation»). `TStringPart`/`TStringSplice` carry every string, a splice-free one as a single chunk.)

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
constructor (`type DiagKind = ERedundantBraces(Span) | EEffectMismatch(EffRow, EffRow, Reason, Span) | …`)
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
`format_default`. Identity already lives on the ADT: `report` takes one
`DiagKind`, and its source, severity, applicability and message are its
projections (`diag_source`, `diag_kind`, `diag_applicability`, `diag_message`,
src/types.mn). What remains is the tables: until they are the
text of that projection (`mentl diagnostics`, `Hβ.diag.catalog-as-projection`),
every row names a class a constructor declares, and a shape the general class
refuses is written on that class's row with the fixture that holds it.

The three groupings below are **derived bands**, not authored law:
- **Format-liftable** ≡ `MachineApplicable` ∧ the redundant form has no graph node (next section).
- **Hard error** ≡ severity=error — a substrate violation the medium cannot auto-recover. Every one refuses the executable: the gate reads the count of errors the judgment reported, so a program carrying one is never emitted, and `mentl check` exits nonzero over it (tests/micros/mn-*-refuses.mn).
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

*The silent lift is the DESIGN. `E_RedundantBraces` still surfaces as a
warning — it retires when the formatter's canonical projection becomes the
save path (`PLAN.md §11`, the project canonical), never by
muting the reporter.*

| Code                  | Trigger (an emitted token, removed/transformed)         | Canonicalization                                 |
|-----------------------|---------------------------------------------------------|--------------------------------------------------|
| `E_RedundantBraces`   | braces wrapping a non-`BlockExpr` (no statements)       | drop the braces; user sees no diagnostic         |

Five more redundant spellings lift silently, with no class, since each parses
to the same graph as its canonical form: statements written without braces
(the parse reads them as their block and the render writes the braces,
§«Missing braces»), a `;` between statements (the parser passes over it as a
separator and the render writes newline layout), an explicit `-> ()` (§«Unit
return omission»), an ownership marker after the colon (`ast: own Node`,
§«The Intent Boundary Rule»), and a `<|` over one stage, which the parse
builds as the pipe it is (§«`<|` — diverge»).

### Hard errors (substrate violations)

| Code                  | Trigger                                       | Applicability        | Quick Fix                                      |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `E_PatternInexhaustive` | a value escapes every arm of a match of two or more arms — a match of one arm, a destructuring `let` among them, claims its shape instead (§«Exhaustiveness») — read over the whole pattern, column by column, so a variant missing INSIDE a constructor's payload refuses too; the message names the escaping value as a pattern. An alternation covers its branches, an as-pattern its inner pattern; a list column is `[]` or a head before a rest, a record its fields, Bool's literals its constructors, and any other literal column is covered only by a wild row (`0` beside `1` misses `_`). ARMED | `HasPlaceholders`    | insert the arm the witness names |
| `P_ExpectedToken`     | the parser expected one token and found another. It recovers so the judgment can go on, and a recovery is a guess at text it could not read, so the program refuses | `MaybeIncorrect`     | write the token it expected |
| `P_UnexpectedToken`   | a token not valid at its position; in pattern position the recovery is a wildcard, so the program refuses rather than run the arms it swallowed (tests/micros/mn-pattern-token-refuses.mn) | `MaybeIncorrect`     | restructure per the surrounding form |
| `P_UnclosedConstruct` | EOF inside a construct (block, match arms, etc.) before its closer | `MaybeIncorrect` | close the construct OR remove its opening token |
| `E_RefinementRejected`| value violates refinement predicate — or a partial primitive's precondition refuted by constants (`1 / 0`, `INT_MIN / -1`; §«Partiality»), or a destructuring pattern's shape refuted by how the value was built (`let Some(v) = None`; §«Exhaustiveness») | `Unspecified`        | adjust value or widen refinement               |
| `E_EffectMismatch`    | declared row doesn't subsume body row. The Reason names the declaration and, for a function, the chain of sites the first refused effect enters through — each a `module:line:col` naming what the effect crosses there (a callee, a stage, a handler, a function value entered) or the construct that charges it (`rendering the value`, `building the list`) — to the op where the chain reaches one (the span stays the declaration's, whose clause is what the body violates). An install whose arms perform an effect the installing declaration forbids is this class: what an arm performs enters the install's row (§«`~>` — tee»; tests/micros/mn-handler-arm-forbidden-refuses.mn) | `MaybeIncorrect`     | widen declaration OR install absorbing handler at the site the chain names |
| `E_PurityViolated`    | `with Pure` body performs non-empty effects   | `MaybeIncorrect`     | remove `with Pure` or absorb the effect        |
| `E_ZeroDelayFeedback` | `x <~ delay(0)` — a cycle with no delay: the prior would be the value being computed. ARMED (refuses the executable); one arm of the depth read, both the `delay` and `Delay` spellings | `MaybeIncorrect` | raise the delay to at least 1 |
| `E_ComputedDelayDepth` | `x <~ delay(n - 1)` — the depth is a runtime value. A feedback line's ring is sized and wrapped by its literal depth, so an unreadable depth cannot be held, and the site would silently get one slot. ARMED, the sibling arm of the same read | `MaybeIncorrect` | write the depth as a literal, or hold the history yourself |
| `E_OwnershipViolation`| `own` consumed twice / escapes ref scope      | `Unspecified`        | restructure to single-consume or use `ref`     |
| `E_UseAfterMove`      | a borrow-READ of a name the affine ledger already moved — the read half of affine beside `E_OwnershipViolation`'s consume half. ARMED. Sound today only by accident: the heap frees only where an extent ends — an arena's exit, a reset — never at a `Consume`, so it is a use-after-free the day a `Consume` reclaims | `Unspecified` | drop the read, or restructure so the move happens after it — never a patch |
| `E_HandlerInexhaustive` | a handler's arms answer some ops of an effect and not others (§«A handler is exhaustive») — an install absorbs every op of the effects its arms answer, so the missing op would escape the row and reach nothing at runtime. ARMED; the shape it refuses was a false absence proof that trapped | `HasPlaceholders` | add the arm; forward the op outward (`op(…) => resume(op(…))`); or declare the ops this handler answers as their own effect |
| `E_ResumeOfNever` | a handler arm resumes an op declared `-> !` (§«Never-returning ops») — the never type is quantified per perform, so no value the arm hands back is one every performer can receive. ARMED | `MaybeIncorrect` | end the arm with the value the install answers, or declare the op's result type if it does return |
| `E_EffectUnhandled` | an effect reaches the executable root — `main`'s row, or a module value's init, which runs before `main` in the same world — with no install absorbing it, and its ops are not the substrate's own instructions (Memory, WASI and Cast ground; a row fact with no ops, Mutate or Arena, grounds vacuously). Judged at the end of the judgment, so `mentl check` refuses it where `mentl compile` does, the chain naming where the effect enters. ARMED (tests/micros/mn-check-root-unhandled.mn, mn-check-root-unhandled-init.mn) | `MaybeIncorrect` | install a handler for it over the performing chain; the message names the handlers in scope that answer it |
| `E_InitPerformsOwnOp` | a handler's state init or config default, or an install's own argument, performs an effect that handler alone answers (§«Handler declarations») — each runs before the install exists, so nothing can answer the perform. ARMED (tests/micros/mn-refuse-init-performs-own-op.mn, mn-check-install-config-own-op.mn) | `MaybeIncorrect` | move the perform into an arm, or compute the value under a handler installed around this one |
| `E_ThreadedBranchEffect` | under a threaded schedule, a branch's row carries an effect whose covering handler at the fanout's frame — or, for a fanout a caller's schedule demands, along the demand's chain of installs, the callback parameter's row read at the instantiating site — writes its state (`resume … with`), lies beyond the frame fence with no demand reaching it, or reaches such a handler through its own arms (§`><`); or the branch stores into memory older than itself, or reaches code that writes memory older than its own frame (`Mutate`) — a sequence fanout's function read as every branch's. ARMED | `MaybeIncorrect` | install a handler that writes no state at the fanout's frame, or install the handler inside the branch; give each branch memory it allocates |
| `E_DerivativeUnreachable` | a `d(v)` under a derivative reading whose argument's tangent was lost — into an aggregate, across a multi-shot perform, off a line ticked by forward code or a line a closure record owns, or through another `d` — a mint, an install or a state write under the reading that would store a lost tangent into a record, or a reading whose seed is not a Float variable in scope (§`~>`). The message names the loss site. ARMED: the alternative is a slope of zero the program never has | `Unspecified` | keep the value out of the aggregate until it is asked for, or seed the reading at a Float variable |
| `E_EnvNameUngrounded` | a required environment read (`env`, lib/environ.mn) whose name is not a literal at the read — the program's demand on its host could not be stated before it runs, so its launch gate could not check it (§«Configuration — the environment is an effect»). ARMED | `MaybeIncorrect` | write the variable's name at the read, or ask `env_opt` and decide what an absent value means |
| `E_MissingVariable`   | name not in scope                             | `MaybeIncorrect`     | check spelling; check imports                  |
| `E_MissingImport`     | a name resolves only because the whole link carries it: declared at module level in a module the referencing module never imports, directly or transitively (the prelude's closure is ambient — the driver links it into every compile). ARMED, naming both modules at the reference | `MaybeIncorrect` | add `import <declaring module>` to the referencing module |
| `E_UnknownArgLabel`   | a labeled arg names no declared parameter     | `MaybeIncorrect`     | check the label against the parameter names    |
| `E_TypeMismatch`      | unification failed — the message carries the Reason the unify was asked with, past the diagnostic's own span (`Int vs [Byte] — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler h`). Three shapes are this class with their own Reasons: a pipe into a stage with no hole (`x \|> f(a, b)` over two parameters) and one into a stage with two holes none marked (`x \|> g(a)` over three), each refused where the stage meets the pipe's one-parameter function, and a `++` whose operands' element types do not unify (`[1] ++ [true]`), its Reason naming the `++` (tests/micros/mn-pipe-into-complete-refuses.mn, mn-pipe-hole-ambiguous-refuses.mn, mn-concat-type-mismatch-refuses.mn) | `Unspecified`        | adjust types; widen / narrow; leave a stage one hole, marking it `??` where it is not the last field |
| `E_OccursCheck`       | infinite type                                 | `Unspecified`        | restructure to break cycle                     |
| `E_OrphanHandlerAttach` | `~>` with no preceding chain                | `Unspecified`        | delete `~>` or supply body                     |
| `E_NotAKeyword`       | user typed `for`/`while`/`loop`/`break`/`continue`/`return` | `MaybeIncorrect` | rewrite as verb form per substrate             |
| `E_PatternAlternationBindingMismatch` | branches in `\|` bind different names or types | `MaybeIncorrect` | adjust patterns to bind same names with unifiable types |
| `E_DuplicateBinder` | a name bound twice in one head — across its parameters and inside their patterns — or by one pattern (`fn f(x, x)`, `(x, x) => x`); the second binder is refused, naming the first, and an alternation's branches, which bind the same names by law, are one binder each. ARMED | `MaybeIncorrect` | rename one binder |
| `E_ResumeOutsideArm`  | `resume` where no continuation exists — outside a handler arm and every lambda or nested fn minted inside one, whose record captures the arm's k. ARMED (tests/micros/mn-resume-outside-arm-refuses.mn) | `Unspecified`        | move the resume into an arm, or declare the fn inside the arm; the continuation only exists there |
| `E_ResumeWorldMismatch` | two continuations (`TCont(R, S, discipline, world)`) unify with incompatible resume DISCIPLINES — OneShot, MultiShot and Abandon are distinct representations (stack frame, heap record, dead continuation), so the mismatch is hard. The WORLD half is the row unification in the same TCont arm (`!E` lifted to the TIME axis, §4③). A continuation resumed under a changed world answers to that world past its own segment, and a negation over the resume or the root refuses one whose world cannot answer its remainder, as `E_EffectMismatch` or `E_EffectUnhandled` (§«A resumed remainder answers to the world it is resumed in») | `MaybeIncorrect` | align the handler arms' resume cardinality; for a world clash, re-install the absorbing handler before the resume OR widen the continuation's world |
| `E_DeclaredRowContradiction` | one authored clause asserts a name present AND absent (`with E + !E`, instance-aware — a bare present beside an instance absent stays a refinement). Reported at the signed fold BEFORE the meet's drop; ARMED (refuses the executable): the pre-diagnostic meet let a performing body check clean under a declared `!E` | `MachineApplicable` | drop one side of the contradiction |
| `E_ArithOnAggregate`  | `+ - * / %` or unary `-` whose operand is a product, sum, sequence, function, continuation or unit — the operands are addresses and the arithmetic would be on where the values live. ARMED: judged at the operator for a bound operand and at the one writer for a gated cell bound later (a `NumericGate` on the cell, copied at instantiation, reached through the instance column), so the judgment refuses, `mentl check` says so, and no WAT streams | `Unspecified` | give the operand a number (a word) or read the field you meant |
| `E_UnresolvedHole`    | compiling an EXECUTABLE whose reachable emitted tree carries an authored value-position `??` (§«Partial application» — a hole is productive for check/edit, never an executable value; a parameter-product `??` is an executable suspension and runs). Raised by the executable gate between reachability and emit: nonzero exit, zero WAT bytes, the authored weave span on the diagnostic | `HasPlaceholders` | fill the hole (accept a Synth survivor) or suspend it into a parameter product |
| `E_FieldOffsetUnprovable` | a field read or a record pattern whose receiver's row never closed where the body is emitted — no field set, so no slot. Said at the SETTLE POINT: the plan's emitted reach asks it of every body under the bracket that body is emitted in, a base at the floor and a twin under its own pairs, before the gate reads the ledger, so the compile exits 1 with zero WAT bytes. ARMED (`tests/micros/mn-payload3.mn`) | `MaybeIncorrect` | close the receiver's row — annotate it at its Intent Boundary, or give the call site a shape its specialization can key on |
| `E_ShapeUnprovable` | a comparison, a show, a hash or a `++` whose operand is still a type VARIABLE where it is emitted: nothing proves the shape the read needs, and the word reading it would fall to is an address lie for anything but a word. Said at the settle point beside its row sibling and ARMED with it | `MaybeIncorrect` | prove the operand — give the call site a shape its specialization can key on, or name the type at its Intent Boundary |
| `E_HandlerChainShape` | a handler chain (`handler NAME = h1 ~> h2`, §«Handler chains») with the wrong shape: a member that is not a handler or a chain, a member whose argument declares anything (a function, a handler, a type, an import), or the chain installed with arguments of its own — a chain carries no config, its members do; all three judged at the declaration or the install, never at the lowering. ARMED (tests/micros/mn-handler-chain-shape-refuses.mn) | `MaybeIncorrect` | name a handler at the member; move the declaration beside the chain; install the chain bare and give the member its config |
| `E_InstantiationDepth` | a reference eight instantiations deep in a recursion whose type grows with every call, reaching a callee that READS the growing structure (a comparison, a show, a field — or a number). Monomorphization cannot specialize without bound, and the ninth level would read the structure as a word, so the settle point refuses there. ARMED. A wide value nothing reads crosses the word protocol boxed and back, and is admitted | `Unspecified` | recurse over a type that keeps its shape, or leave the growing part unread |

### Gradient narration (teaching surfaces)

| Code                  | Trigger                                       | Applicability        | Action                                          |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `T_OverDeclared`      | a declared bare positive name beyond the proven row (the positive half only — a negation is a proof claim, never over-declared) | `MachineApplicable`  | `mentl tighten` writes the clause's residue |
| `T_RowInventory`      | a declared clause whose bare positive names the body's GROUND row proves, every one — the projected row written by hand (§«A signature is not an inventory»). Over an OPEN body row the bare names are a cap the declaration installs as a gate, and nothing is narrated | `MachineApplicable` | `mentl tighten` writes the residue — negations, instance pins, or no clause |
| `T_WordSlotBox`       | a wide value (a Float) boxed into a fresh cell to cross a callee's slot sized for a word — a list primitive's element (`list_set`) — inside a unit whose row does not say `Alloc`: the representation's cost, not the program's, until the slot takes the value's own width (`Hβ.value.seq-element-stride-carrier`). Said at the settle point by the allocation audit, which refuses every allocation that IS the program's | `MaybeIncorrect` | keep the value at a word's width where the slot is one, or wait for the carrier |
| `W_RedundantWhere`    | `type X = Y where true` — vacuous predicate   | `MachineApplicable`  | drop the `where true`; alias is transparent     |

---

## What this document is NOT

- NOT a tutorial. The course is `examples/pulse/course`: ten programs on one audio chain, each a lesson `mentl run` renders, which the page opens as a project (`docs/MENTL_SPACE.md` §5.5).
- NOT a reference for library functions. See `lib/` and `mentl doc <module>`.
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

*(`mentl verify` holds the medium's standing bounds on its own source, each
bound and its justification in `src/board.mn` where `mentl why` walks them.
It absorbs the census half of `tools/verify.sh`; the legs that measure the
world outside the graph — the micro battery's exec seam, the march's peak
RSS, the scaffold count — remain the script's, named rather than silently
inherited.)*

## Authority

This document is the authority on syntax: it supersedes any syntactic claim in `CLAUDE.md`/`PLAN.md` (the live three-doc contract) and in the archived `docs/**` corpus (git archaeology — DESIGN.md, SUBSTRATE.md, the per-module specs). Where any of them conflicts with SYNTAX.md, SYNTAX.md is correct.

Mentl's discipline applies to syntax: every form below was decided by asking the eight interrogations — one per kernel primitive (`PLAN.md §2`; the table lives in `CLAUDE.md`), one per Mentl tentacle. Graph (what AST does it produce?), handler + inferred resume cardinality (what installed handler reads it, what cardinality does the arm body prove?), verb (which topology?), row (what `+ - & !` constraint do the body's op-call sites prove?), ownership (what `own`/`ref` does the use-count infer?), refinement (what predicate does the path narrow?), gradient (what annotation INPUT or body-structure unlocks the cursor's projection here?), Reason (what edge does it leave for the Why Engine?). Forms that failed any of the eight were rejected. **Annotations declare INPUTS to the cursor; never the emergent property itself.**

When questions arise about syntax not yet covered here: resolve the design question by interrogating it against the kernel (`PLAN.md §2`) — reductively (minimal graph-correspondence?) and generatively (what do multi-shot / threading / unified-memory + the frontier make better?) — then update this document. SYNTAX.md is the one home for the surface.
