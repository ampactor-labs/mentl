# SYNTAX.md — Canonical syntax specification

> *The written form of Mentl, chosen as the one that best translates intent
> into computation.*

> **One of the three documents (the contract).** Mentl's read path is exactly
> three documents. `CLAUDE.md` (*method*) is read whole. `PLAN.md` (*substance*)
> and this one, `SYNTAX.md` (*surface*), are read by part through `mentl map`,
> where each `##` and `###` heading is one part. This file is the authority on
> syntax and overrides any claim about syntax in the other two. For what Mentl
> is, the kernel and the resolved design decisions, see `PLAN.md`; for how to
> work, see `CLAUDE.md`. The former `docs/**` documents (DESIGN.md,
> SUBSTRATE.md, the per-module specs) exist only in git history and are no
> longer read; what mattered in them now lives in the three documents.
> **Interrogate, don't absorb** (CLAUDE.md): every form below is the current
> best answer and stays open to re-checking against the question "what does
> the ultimate medium do here." Re-check a form in two directions.
> Reductively: is this the smallest form that corresponds to the graph?
> Generatively: how do multi-shot, threading, WASM memory and the frontier make
> the surface better (`PLAN.md §2`)? Like the source, the surface is invariant
> to the current parser. It is never lowered to "what parses now" (the parser
> is adjusted to match SYNTAX.md, as the next paragraph says), and settling for
> the "form reachable now" is the same drift at the surface: the goal lowered
> without saying so.

This document is the authoritative syntax specification for Mentl. The parser is bound by it and implements exactly what it says. It is written under dream-code discipline: every decision below is the ideal form and does not describe the current parser. Where the current parser deviates, the parser is wrong, and the parser is what gets changed to match this document.

> **Resolved-design note (`PLAN.md §4`).** The surface already realizes the
> value ontology (`§4①`); it is not deferred. There is one sequence node-kind,
> so `String` is `[Byte]` plus a parse-time text/interpolation view, `++` is
> one `seq_concat`, `==` is one derived structural equality, and
> `Int`/`Float` are `Word` plus a representation gradient (`Bool` is already
> derived, as `False | True`). The surface is invariant to the substrate, and
> the byte-sequence ontology is that invariant form, so it is the form written
> on the page. The lowering is scheduled to close the gap to the surface
> (`PLAN.md §5`); the surface is never lowered to match the current lowering.
> The one genuinely post-real forward-pointer is the effect system (`§4③`).
> `!E` is present and relied on now, and so is information flow (`§4⑥`,
> §«Refinement types»). The modal synthesis that closes the higher-order leak
> is scheduled after first-light. Where it would land, this document names its
> absence in positive form and never hedges that the present forms are
> "pragmatic, not final."

---

## Syntax ↔ the eight-primitive kernel

Every form below exists to make one primitive of the kernel (`PLAN.md §2`) reachable as text, and no form exists without a kernel primitive behind it. The constraint matters because a syntactic feature with no kernel primitive behind it has no place in the semantics, and in peer languages every such feature has been regretted. The kernel has eight primitives and Mentl has eight tentacles, so the surface forms below fall into eight matching groups.

| # | Kernel primitive                                    | Tentacle   | Surface form                                                    |
|---|-----------------------------------------------------|------------|-----------------------------------------------------------------|
| 1 | Graph + Env                                    | Query      | AST nodes implicit; `import` brings module envs together         |
| 2 | Handlers with typed resume discipline               | Propose    | `effect`, `handler`, `~>` (the one install verb), `resume`. Ops are invoked as bare calls. An op's effect is recorded in its row (`Closed[eff]` at the declaration), never in a keyword at the call site (`perform` is not a keyword; it was removed, see §«Invoking effect operations»). Resume cardinality is inferred from the arm body's structure (the count of resume sites under control-flow ancestry) and is never written as an annotation. |
| 3 | Five verbs                                          | Topology   | `\|>`  `<\|`  `><`  `~>`  `<~` with canonical layout             |
| 4 | Full Boolean effect algebra (`+ - & ! Pure`)        | Unlock     | `with E1 + !E2 + Pure` in fn signatures, handler signatures and types. A declared row is a constraint, checked against the row inferred from the body's op-call sites, never a contract |
| 5 | Ownership as an effect                              | Trace      | `own` / `ref` parameter markers; inferred from usage count by default (0/1/2+ → Inferred/Own/Ref) |
| 6 | Refinement types                                    | Verify     | `type Name = Base where predicate`; per-program-point narrowing inferred from `if`/`match`/`assert` sites |
| 7 | Continuous gradient                                 | Teach      | The gradient is continuous and derived (gates_unlocked × proximity); annotations are inputs that unlock gradient ascent at a position. The gradient itself is never written by hand: it is what the cursor reads from the kernel's facts at position P. |
| 8 | HM inference with Reasons                           | Why        | No turbofish; generic params declared, inferred at call; wildcard `_` holes admit productive-under-error continuation |

**Rule:** before adding a syntactic form, ask which kernel primitive it surfaces, and therefore which tentacle reports on it. If none, the form does not belong. If several, they were missing a shared form, so merge them into one.

Each section below labels which primitive(s) its forms surface.

---

## Governing principles

Every syntactic decision below follows five rules:

1. **Layout is projection, never contract.** The shape of the code on the page is the computation graph. That holds because the formatter projects the graph onto the page in canonical form, not because the parser reads meaning from whitespace. The kernel leaves no other choice. A contract would make whitespace a second writer into the graph, but the kernel has exactly one writer, inference: one graph and two operations on it, with no third. So layout can only be a read of the graph that inference has already written, and `mentl fmt` is that read at the surface. The parser has one precedence table. `mentl fmt` normalizes wrong layout when the file is saved, and wrong layout is never a parse error.

2. **No redundant form.** If two syntactic forms produce the same graph, one is rejected. The medium rejects syntax that the substrate does not need.

3. **No syntactic ambiguity.** Every token sequence parses to exactly one AST under the rules below. A language that leaves an ambiguity in place passes its cost to every user, so Mentl resolves each ambiguity when the grammar is designed.

4. **Every construct has graph correspondence.** Every piece of syntax produces a substrate operation, so a form with no meaning in the graph is not part of the language.

5. **Diagnostics carry coordinates and Quick Fixes.** Every rejection produces a Located reason chain and, where the fix is mechanically apparent, a MachineApplicable patch. Each error message is written to show how to fix the problem.

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
statements, that is, when it is a `BlockExpr`. The braces are the `BlockExpr`
literal (a scope that runs statements in order before a final expression), and
line count plays no part. A single expression needs no braces, even a
multi-line `if`/`match`/pipe chain. `mentl fmt` projects fold points and
indentation as layout, never as a parse contract (Governing Principle 1: layout
is never semantics).

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

`chase_node`'s body is one multi-line `if`/`match` expression, so it takes no
braces (it is not a `BlockExpr`). `process` introduces `let`-bindings, so its
braces are required, enclosing a `BlockExpr(stmts, final_expr)`. The only
question is whether the body introduces bindings or statements, and the answer
is read live from the graph. The number of lines never matters.

### The Intent Boundary Rule for Parameters

Mentl uses Hindley-Milner type inference, so you do not need to annotate parameters with base types like `Int`, `String`, or structural records.

**Rule:** parameter type annotations are reserved for **Intent Boundaries** and nothing else. Use them to declare:
1. **Refinement Types** (e.g., `pos: ValidOffset`, `span: ValidSpan`) which encode predicates that `Verify` must discharge.
2. **Ownership Markers** (e.g., `own ast: Node`, `ref env: Env`, `ref nodes`) which enforce linearity and aliasing.
3. **Representation Pins** (e.g., `s: f32`, `coeff: f64`) which pin a width the gradient would otherwise infer. A pin is the representation counterpart of the ownership marker (§"Type aliases", representation-pinned alias). `s: f32` is the bare-width form of `s: Float repr f32`.

Do not write `fn name(a: Int)` when the graph can infer it. Do write `fn name(pos: ValidOffset)` to set up a semantic contract backed by the graph, and write `fn name(s: f32)` only when you have decided on a narrower width than inference would choose.

A type annotation that the judgment would derive anyway is an inventory: the projected type, written out by hand. It is the type counterpart of a row inventory, and the medium reports it instead of refusing it. At a declaration whose body alone determines the parameter's type, `mentl teach` answers `lift n: Int` and the caret's Teach facet shows the same. `mentl accept` rewrites the declaration's head without the annotation, and `mentl tighten` removes every such annotation in a project. Each removal is proven, never read off the cells. The medium reads the declaration again from its lines without the annotation, judges it in a fork of the judgment, and removes the annotation only where the face that version publishes is the live one. A refinement, an ownership marker or a width is never removed, even when a callee would imply it, because each is a decision this rule reserves the annotation for.

**An ownership marker has one position: before the parameter's name**, as in `ref nodes` and `own ast: Node`. It is the only spelling that reads the same with a type and without one, which is why the parser reads the marker there (`parse_one_param`). A marker after the colon (`ast: own Node`) is a redundant spelling of the same parameter, so it is format-liftable: the formatter can move it to the name's side. Today the parser refuses it in type position (`P_UnexpectedToken`); after the formatter landing, the parser accepts it and the formatter moves it.

### Redundant braces — braces wrapping a non-BlockExpr

```
// braces around a body with no statements (a bare expression):
fn parse(path: Path) -> Config = { path |> read_file |> decode }
```

Diagnostic: **`E_RedundantBraces`** (format-liftable: the formatter strips the
braces and the user sees no error). Trigger: braces enclose a body that
introduces no `let`-bindings or statements (not a `BlockExpr`), regardless of
line count.

Quick Fix: remove the `{` and `}`.

### Missing braces — statements written without a block

```
// a body that introduces let-bindings but omits the braces:
fn process(input) =
  let validated = input |> validate
  validated |> fft |> extract
```

Format-liftable and silent: the parser reads the statements as the block they
are, and `mentl fmt` writes the braces (`fn process(input) = {`). The rule
depends on whether the body introduces statements, not on line count. The
earlier `chase_node` (a single multi-line `if` expression) needs no braces
because it introduces no statements. No error class names this fix
(§«Diagnostic catalog»).

### Generic type parameters

```
fn map(f: a -> b, xs: [a]) -> [b] =
  ...
```

**The case rule is the declaration**: lowercase identifiers in type
position can only be type parameters (nominal types are capitalized),
so there is no declaration list to write or keep in sync. Type
parameters are inferred at call sites. **No turbofish, and no angle
brackets anywhere.** Call:
```
map(double, [1, 2, 3])   // correct — A=Int, B=Int inferred
```

```
// REJECTED:
map<Int, Int>(double, [1, 2, 3])
```
The parser has no special recognizer for the turbofish. A separate scanner for each foreign form does not scale, and the parser has one precedence table. `map<Int, Int>(...)` parses as the comparison chain that `<` draws (`map < Int`, `Int > (...)`), and the general unexpected-token or type-mismatch diagnostic reports the mistake in context: a `TBool` where a callable was expected, with a Located Reason and a Quick Fix to the call without type arguments, `map(double, [1,2,3])`. The case rule is what retires angle-bracket parameter lists in every declaration position (`type Box<A>`, `fn f<T>`, `effect E<S>`). That report comes from the one general diagnostic path, never from a lookahead written for Rust syntax.

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
`Pure`, or the declaration is refused.** A term that names no effect in the
module's reach is `E_MissingVariable`. This applies in a function's clause, a
handler's, an op signature's, inside a function type
(`f: () -> Int with !Nowhere`) and in a named row (§«Named effect rows»). The
error is reported at the declaration, or at the name itself when the name is
inside a type. If an unknown name were read as an effect of that name,
`fn quiet() with !Nowhere = 1` would check clean and constrain nothing
(tests/micros/mn-effect-name-resolves.mn, mn-effect-name-in-fn-type.mn).

**A function type's row means what a declaration's clause means.** `f: () ->
Int with !Both` keeps its row as its author wrote it, read where every named
row is known. That holds whatever writes the type: a parameter, a return, a
let's annotation, an op's signature, a constructor's field, a handler's
configuration, a type's argument or an alias's body. So `!Both` forbids every
member of `type Both = A + B`, and each name is a reference that `refs of`
finds (tests/crown/leak-fn-type-*.mn,
tests/micros/mn-effect-name-in-alias-fn-type.mn,
mn-effect-name-nested-fn-type.mn).

**A lowercase name in a row is a row variable**: the case rule applies to a row as it applies to a type. `f: () -> a with e` takes a callback that may perform anything, and `e` written again anywhere in the same signature (another parameter's type, or the declaration's own clause) is the same variable, just as a type variable named twice is. A parenthesized group is a row term that the clause folds as a whole, applying the group's outer connective to what the group spells. `with Memory + Alloc + (e - Intern)` is the row of a body that absorbs `Intern` around the callback and pays for the install, and the medium writes such a row back in this form.

**`with` means the same thing in each of its three uses.** Everywhere it appears it reads as *"this construct is accompanied by, or carries, X"*, and the three uses are one concept, not an overload: a function carries effects (`fn f() with E`); a handler carries state (`handler h with s = init`); a resume carries a state update (`resume(v) with s = s + 1`). The grammar distinguishes them by position (a row after a signature, or `name = init` bindings after a handler or resume), and the meaning stays the same. (Installing a handler does not use `with`; it uses the `~>` verb.)

### Return type omission

```
fn id(x: A) = x   // return type inferred
```

The `-> RetTy` clause is optional; when it is absent, the return type is inferred. Most user code does not annotate return types. Mentl's gradient may suggest an annotation when a capability depends on the return type being explicit. It removes a written base return type that the body alone determines (`lift -> Float`), just as it removes a parameter's annotation (§«The Intent Boundary Rule for Parameters»). A return contract such as `-> Hz` is a claim and stays.

### Default parameter values

Trailing parameters may have default values. Call sites may omit them or override via labeled args.

```
fn compress(x: Sample, ratio = 4.0, threshold = -12.0) -> Sample = ...

compress(sample)                                    // ratio and threshold defaulted
compress(sample, 8.0)                               // ratio overridden; threshold defaulted
compress(sample, threshold = -6.0)                  // label to skip over ratio
compress(sample, ratio = 2.0, threshold = -18.0)   // fully labeled
```

A default desugars once, at the declaration, into a fill scoped to the callee. When a call has no argument edge for a parameter, the parameter is filled by projecting the default's node, evaluated in the callee's parameter scope and never in the caller's context. In that scope the earlier parameters are bound in sequence (the same letrec scope that nested fns use). The default is stored in one place (the signature node) and evaluated in one context (the callee); the call site only leaves out an edge. A defaulted slot leaves a `DefaultReason(param, decl_site)` edge, and `mentl why` at the slot follows it to the declaration ("`ratio` defaulted to `4.0` from `compress` — annotate to pin").

### Labeled call arguments

Any call may use `name = value` for trailing positional arguments, with positional arguments before labeled ones:

```
fn queue_task(priority, ref config: Config, timeout_ms = 1000) = ...

queue_task(5, config)                                            // positional only
queue_task(5, config, timeout_ms = 5000)                        // positional + labeled override
queue_task(priority = 5, config = current, timeout_ms = 5000)   // all labeled
```

**Defaults and labeled arguments are not separate features: both follow from the parameter list being a product node-kind.** A parameter list is a positional product (`PLAN.md §2`, L1). Like every product, it may be constructed positionally (`f(a, b)`), by field (`f(x = a, y = b)`), or mixed (`f(a, y = b)`), using the same machinery as the record literals `{a, b}` / `{x: a, y: b}` (punning and field naming). A default is a product field's fallback construction, the same machinery as a record-field default. There is no separate call-site feature: the product node-kind requires all four forms. Labels resolve against the declared parameter names, and an unknown label is `E_UnknownArgLabel`. (Under threading or multi-shot, a labeled call does not depend on order at the product level: the cursor may fill fields in any order.)

**A field is keyed by its name, not its position; the order is a projection.** A parameter product is not the position-keyed drift that CLAUDE.md warns against (`CLAUDE.md` drift-8, evidence-by-row-slot, `mode == 0/1/2`, parallel arrays). Those patterns use position as a fragile stand-in for an identity. A product's fields have an identity, their names, exactly as record fields do (sorted by name at parse, so source order does not matter). `queue_task(priority = 5, config = c)` resolves by name. The positional `queue_task(5, c)` is a convenience that fills fields in declaration order and resolves to the names immediately. Position is a deterministic layout over a set keyed by identity, never the key itself. A label is the name of the field its slot fills: the page writes it as that parameter's name, read through the call's product and its callee's edge, so renaming the parameter rewrites every label that names it (tests/micros/mn-rename-label.mn).

### Partial application — the product with a hole

A parameter product may be constructed with a **hole**, a field left unsupplied. The result is a value, not an error: the function waiting for that field. This is partial application, and it is not a separate feature. It is the product node-kind constructed with one field absent.

```
let adults = filter({ p => p.age > 18 })   // xs is a hole → adults : [Person] -> [Person]
adults(users)                              // fill the hole → the filtered list
adults(new_signups)                        // reuse — a hole-product is a first-class value
```

*(A bare `.field` accessor (`filter(.age > 18)`) is not a form. A field is not a declaration, so `.name` would be a third way to reach a function value besides reference and mint, and §«Function literals» says there are only those two.)*

**The hole is keyed by identity, never by position.** `filter({ p => p.age > 18 })` leaves the parameter `xs` unfilled; the hole is "the parameter `xs`," not "slot 2." When exactly one field is a hole, there is no ambiguity. When several are, `??` names the hole explicitly at the field it marks:

```
between(??, 100)        // the FIRST field is the hole: { x => between(x, 100) }
list_set(xs, ??, v)     // the MIDDLE field is the hole: { i => list_set(xs, i, v) }
```

`??` is the same absence marker as the gradient's hole (§«Token enumeration», `THole`): a field the cursor reads as unsupplied. What fills it depends on context. Synth proposes a candidate, a call supplies a value, the `|>` pipe supplies the flowing datum, or a resumption supplies it later. The marker is the same in every case, and it names which field is missing, never a slot.

**Where nothing can fill the field later, the hole is a value hole and the call is applied.** An operand of an operator, such as `choose(??) + 1`, `-choose(??)` or `choose(??) == 2`, receives nothing from anywhere: no pipe flows into it and no later call fills it, so the product it would suspend into has no filler except the proposer. The call is therefore applied, and its `??` is the slot's value hole under the slot's contract (`choose(??) + 1` over `choose(n: Positive)` proposes `1`). The judgment records this decision on the call's product (`CallShape`) for the lowering to read. In every other position, such as an argument (`f(choose(??))`), a binding (`let c = choose(??)`) or a returned value, the `??` keeps the suspension described above.

**The `|>` pipe fills a hole; it does not rewrite the call.** `x |> f(a)` fills `f(a)`'s remaining hole with `x`:

```
users |> filter({ p => p.age > 18 })              // fills xs → equals filter({ … }, users)
users |> filter({ p => p.age > 18 }) |> map({ p => p.name }) |> sort
```

The pipe's type rule (§«`|>` — converge») requires `right : A -> B`, a product with exactly one hole, and a partial application is exactly that. So the pipe does not append syntax: it fills the product's one remaining hole with the piped value. This is why the five verbs compose. Every stage is a product already filled with its configuration, and its data field is a hole the pipe completes: `x |> clamp(0, 255)` fills `clamp(lo, hi, x)`'s datum. A call that is genuinely not a stage names the pipe's target with `??` (`nodes |> list_set(??, i, v)`, §«The Stage Law»). A stage with more than one hole and none marked, or with no hole at all, is not an `A -> B`, and the pipe's unification refuses it (`E_TypeMismatch`, at its arity face: tests/micros/mn-pipe-into-complete-refuses.mn, mn-pipe-hole-ambiguous-refuses.mn).

**These five forms are one primitive.** Positional construction, construction by field label, defaults, the hole (partial application) and pipe completion are all the parameter-list product, constructed by identity with any subset of its fields supplied, defaulted or left as holes. There is no currying mechanism separate from the product. A "curried function" is a product with holes, and its arity is always exact, because the holes are named fields rather than a hidden nesting of one-argument functions.

**The judgment writes the product once, at the call.** Labels resolve, defaults fill and holes are typed against the parameters that the callee node carries: a let-bound closure's own parameter names, a parameter's own arity, a field's own type. They are never resolved against a module function that happens to share the name, and the lowering reads the product off the call node instead of resolving it again. A partial over a local callee carries the callee's value in its record beside the supplied fields, and every open slot of a partial is typed by its own cell, so `fadd(1.5)` over a Float pair assembles.

**A hole is a suspension point, so partial application and resumption are one operation.** A product with a hole is a computation suspended at its argument, and filling the hole resumes it. When the field is filled by a value, or by the pipe's flowing datum, this is partial application. When the hole is filled later, it is the multi-shot continuation (`PLAN.md §4④`): a `??` hole reified as a resumable record is a continuation waiting for its argument, which can be filled now, later or many times. Partial application and continuation resumption are both hole-filling keyed by identity. They differ only in whether the hole is filled at the call site or captured and resumed. `??` is one absence marker across the whole medium: the gradient's synth hole, the argument hole and the continuation's resume slot are the cursor reading the same absence at three levels.

**A hole can be checked and edited, but never executed.** A bare `??` in
value position (with no parameter product to suspend into) supports the check
and edit projections: the graph types it and the cursor proposes into it. It
is not an executable value. Compiling an executable whose reachable emitted
tree still carries an authored value-position hole is refused
(`E_UnresolvedHole` at the authored span, nonzero exit, zero WAT bytes). The
gate runs between reachability and emit, so a hole in pruned dead code never
causes a false refusal. A `??` inside a parameter product stays executable,
because it is the suspension waiting for its field (`add3(10, ??, 30)` is a
value that runs). Proof debt follows a different rule. An executable with
undischarged `V_Pending` obligations reports them (one ledger projection on
stderr) and compiles. This is the sound-incomplete choice (`PLAN.md §0`):
undecidable residue accumulates where it can be seen, is never assumed true,
and never causes a blanket refusal. The wheel's own self-compile carries
obligations that are undecidable by their structure, so refusing on pending
obligations would refuse the medium itself. A claim that is decidably false is
still refused at the claim site (`E_RefinementRejected`).
tools/proof-exactness-gate.sh is the executable contract for all three legs (a
hole is refused, debt is reported, a suspension runs), and it passes on the
pinned boot.

### The Stage Law — signatures serve the pipe

Hole completion leads to a convention for signatures: **a stage-shaped fn (any
fn meant to stand in a `|>` chain) declares its configuration parameters first
and the flowing datum last.** Filling in declaration order then completes every
stage with no extra syntax:

```
xs |> map(f) |> filter(p) |> take(3) |> fold(0, add)
```

The chain needs no `??`, no wrapper lambdas and no reordered arguments, so the
page reads as the graph. Under this law a `??` inside a pipe always means
something. Either the callee is genuinely not a stage, and the `??` marks that
explicitly (`nodes |> list_set(??, i, v)` pipes into a substrate fn whose
subject is not a chain datum), or the signature breaks the law. In that case
the fix is to change the signature, never to add decoration at N call sites.
The standard vocabulary follows the law: `map(f, xs)` · `filter(p, xs)` ·
`each(f, xs)` · `fold(init, f, xs)` · `take(n, xs)` · `drop(n, xs)` ·
`any/all/find/count(p, xs)`.

**The stage of `each` answers `()`.** An iteration for effect drops its
stage's value by definition, so a stage that answers anything else is a value
the program silently loses, and `each({ x => x + 1 }, xs)` is
`E_TypeMismatch` at the call. A value dropped in any other position is still
silent (`Hβ.infer.statement-value-is-dropped-silently`). Four prelude
signatures still take the datum first: `reduce(xs, f)`, `scanl(xs, init, f)`,
`nth(xs, n, default)` and `clamp(x, lo, hi)`. So `x |> clamp(0, 255)` states
the law, and the prelude is brought into line with it by a reorder that the
medium writes. The reorder reads every call off its product, permutes the
positional calls, leaves labeled calls untouched, and judges the program again
before it writes.

### Vocabulary — names are read as intent, never as ceremony

The developer writes what they mean, not what the machine needs. A name that
adds a description of the machinery on top of the topology is drift. A name
that needs an explanatory comment before it can be read breaks this ruling at
the source, and the comment then exposes two faults: the name's and the
projection's (see §«What a comment TRENDS TO»). Three rulings follow:

- **A removed keyword never returns as a name.** Mentl removed `for`, but a fn
  named `for_each` put the removed keyword back into a name the reader reads
  aloud. Worse, the `E_NotAKeyword` Quick Fix, which exists to replace
  `for`, offered a name that still contained `for`. The iteration-for-effect
  stage is **`each`**: read `xs |> each(f)` aloud. Its handler had been named
  `each_handler` all along, so the substrate already used the correct name.
- **Execution strategy never lives in a name.** How a stage runs is a fact of
  its `~>` handler (`>< [Thread ×4]` is a derived badge, §`><`), so
  `parallel_map` is vocabulary drift over `map ~> Schedule`. The schedule
  reaches a helper's fanout by demand, through a direct call (§`><`). A
  `~> parallel_compose` over `render(voices)` runs every `><` and `fanout` in
  `render`'s direct-call reach threaded. `map` stays sequential by
  construction (one loop), and `fanout(f, xs)` is the sequence fanout that
  declares its applications independent. The parallel map is spelled
  `fanout(f, xs) ~> parallel_compose`.
- **A name must describe the representation correctly.**
  `list_head`/`list_tail` read and remove the last element (the snoc end,
  O(1) by construction). The cons vocabulary they borrowed implies the
  opposite and has already caused one real bug in the project (the
  env-orientation truncation). The correct names are **`last`** and
  **`drop_last`** (symmetric with `take`/`drop`), so the primitives are
  `last`/`drop_last`. The prelude's drop-first is **`rest`**, the word the
  pattern syntax already uses (`[head, ...rest]`), and `tail` is not a name at
  all. The positional `last` duplicate was removed, so the O(1) read of the
  representation is the only one.

### Nested function declarations

`fn` declarations may appear inside another function's body. Nested fns are local to the enclosing body's scope.

```
fn check_exhaustive(patterns) = {
  // inner helper; visible only inside check_exhaustive
  fn covers_all(pats, variants) = all_match(variants, { v => any_match(pats, matches(v, ??)) })
  covers_all(patterns, known_variants())
}
```

A nested `fn name(params) = body` is a declaration scoped to its block. Consecutive `fn` declarations in a block form one run, which is a local letrec scope: every name of the run is in scope in every body of the run and in everything after it, so siblings can call each other in either direction. The run is judged the way the module's declarations are, callee first by binding group, with each cycle judged as one unit, so every member is generalized. One nested `fn ident(x) = x` serves an Int and a String even where its caller is declared above it. Any other statement between two `fn` declarations ends the run. A later fn may capture what that statement computes, and that value does not exist yet while an earlier fn can already be called. So in `fn first() = second() + 1; let k = 2; fn second() = k` the name `second` is out of scope at `first`'s call (`E_MissingVariable`). Two declarations of one name in one run are refused (`E_DuplicateFnName`), as two at module level are, and a fn in a later run shadows a fn of the same name from an earlier run for everything after it. A block-scope `let name = (params) => body` is a closure value, and that is exactly how the two differ. The `let` binds after its value, so its name is not in scope in its own body; it is not generalized; and it may shadow: `let f = (x) => f(x) * 10` calls the `f` bound before it.

**A nested fn is minted where it is declared.** Its closure record (its captures, or an empty record if it has none) is built when the block reaches its run. Every record of the run is allocated and bound before any is filled, so a record that refers to a sibling declared after it, or to itself, holds that sibling's record. The declaring frame pays `Memory + Alloc` once per nested fn, exactly as it pays for a lambda it mints (§«Function literals»), so `fn adder(k) with !Alloc = { fn add(x) = x + k; add }` is refused. A nested fn that captures nothing could be the module's static record and cost nothing. The charge will follow that representation once the lowering builds it (`Hβ.lower.captureless-nested-fn-is-static`). A nested fn minted inside a handler arm captures the arm's continuation, as a lambda minted there does, so its body may `resume` and the fn is a value like any other: an arm may hand it to `fold` and resume once per call (tests/micros/mn-resume-in-referenced-fn.mn).

**A binder shadows its name for its own scope and no further.** A `let` in a block, a pattern in a match arm, a pipe stage's parameter, a recurrence's prior and a binding inside the recurrence body each hide the same name while their scope is open, and the hidden binding is read again, unchanged, once it closes: `fn f(x) = { let y = { let x = 5; x + 1 }; x + y }` answers `f(100) = 106`. Two binders of one name are two values at their own widths, never one storage place. A parameter's ownership grade is read from its own uses, the references whose edge reaches it, never from a shadowing binder's uses (`fn shadowed(xs) = { let xs = 5; xs + xs }` grades its unread parameter by its uses, not its spelling).

**At module scope there is nothing to shadow, and a `let` bound to a function literal is the declaration**: the parser turns `let inc = (x) => x + 1` into `fn inc(x) = x + 1`, which is recursive, generalized and emitted as the symbol its callers call directly, and `mentl fmt` writes it as `fn`. An arm-list literal bound at module scope, `let pick = { Some(v) => v, None => 0 }`, is a declaration too and keeps its spelling, because its one parameter is minted by the literal and never appears on the page. An annotated module let keeps its annotation's constraint and stays a value, and a module value holding a closure (`let add3 = make_adder(3)`) is called through that closure.

---

## Function literals — the arm list

Surfaces primitives #2 (pattern dispatch, the handler's own shape) and #8 (HM inference: a literal's parameter type is inferred from the arms).

**A function value is reached by exactly two operations, because the kernel has exactly two** (`PLAN.md §2`: draw an edge, and project):

1. **Reference** an existing function, leaving as holes the fields it is not yet given: `f`, `f(cfg)`, `f(a, ??, c)` (§«Partial application — the product with a hole»). This is an edge to a node that exists.
2. **Mint** a new one, with an **arm list**: `{ pattern => body, … }`.

**The cost of each appears in the row of the frame that forms it.** A bare reference to a top-level function reaches its static record and costs nothing. A reference with fields supplied (a partial) and a mint each build a closure record holding the captures and the supplied fields, so each charges `Memory + Alloc` where it is formed, and `with !Alloc` refuses it. A constructor, an op or a primitive named as a value is the partial with every slot open, and so are `hash` and `to_string`, which fold as their calls do (tests/micros/mn-fold-face-as-value.mn). Each builds the same record and pays the same (tests/micros/mn-primitive-value-allocates.mn). There is one structural exception: where a verb applies the literal in place, as the stage of a `|>` or the recurrence of a `<~`, nothing is minted, so nothing is charged (§«`|>` — converge»). Calling a closure charges the closure's own row, which is carried in its type, and never the cost of having made it.

### Canonical form

```
{ pattern => body, ... }
```

The braces are the literal. There is no head, because a head would add nothing that the patterns do not already express. Arms are separated by commas, with a trailing comma allowed, exactly as `match`'s arms are, and the same function parses both because they are the same thing.

```
xs |> map({ Some(v) => v, None => 0 })
weights |> filter({ (name, w) => w > 0 })
{ Leaf => 3, Node(n) => n * 2, _ => 7 }
```

**`match` is the arm list, applied.** `match scrut { arms }` and `{ arms }(scrut)` are the same graph and the same value: one form names its argument at the site, and the other leaves it to the caller. This is why the medium needs no separate lambda. Pattern dispatch was always the way to mint a function, and a binder around it only added a wrapper.

**The literal takes exactly one parameter**: the value its arms match. Several arguments are a product that the arms destructure (`{ (a, b) => a + b }` takes a pair). This is the parameter-list-as-product rule (§«Labeled call arguments») applied to the literal.

**A pair is one argument everywhere.** A call's argument count is its callee's parameter count. `{ (a, b) => a + b }` is called as `f((1, 2))`, never `f(1, 2)`, and it is not a two-argument callback: `fold(0, { (acc, x) => … }, xs)` is refused, because `fold` calls its stage with two arguments. The two-parameter value is the binder form `(acc, x) => …` or a reference. These mismatched shapes are refused (`E_TypeMismatch`, at its arity face), and `let p = (1, 2); p |> add` is one of them. A product built where it is piped is the one exception, and it is not a decomposition: `(1, 2) |> add` is the merge `add(1, 2)`, and the tuple is never built (§«`|>` — converge»). The calling convention that would make the two one value is `Hβ.lower.parameter-product-calling-convention`.

**A brace opens a literal when a pattern ends at a `=>`.** A bounded token scan answers that question, never a speculative parse of a pattern and never the layout. The scan accepts one pattern atom (an ident, optionally applied; a literal; or a balanced group) joined to further atoms only by `@` or `|`. Two adjacent atoms are never a pattern, so `{ setup()` newline `(x) => run(x) }` is the block it looks like. Telling a record literal from a block is unchanged and comes after this check (§«Records», §«Function declarations»).

### The residue — `(params) => body`

The binder form still parses. It is the last form left in the series of retirements that removed `perform`, `handle`, `capability`, the turbofish and `|x|`. A sole-parameter lambda is an arm list, so the binder is a redundant spelling of an arm list. `mentl fmt` writes the arms wherever the lambda's body is a `match` on its parameter (`arm_list_of`). Every arm list reads back that way, and so does the destructure in parameter position, `((a, b)) => e`. A sole-parameter lambda with any other body keeps its binder today (`(x) => x + 1`), because the parser builds `{ x => x + 1 }` as a `match` on a minted parameter, not as the single `LambdaExpr` that the binder form builds. The formatter landing makes them one node, and every sole-parameter mint then renders as its arms. After that, two cases remain on the page:

- **Multi-parameter lambdas** (`(a, b) => a * b`). The arm list takes one parameter, so these retire by becoming references (`fold(0, add, xs)`), which is rule 1 and needs no new form. `Hβ.syntax.multi-param-lambda-is-a-reference`.
- **The zero-argument thunk** (`() => e`) that handed a body to a handler stack. That use is retired in favor of the named handler chain (§«Handler chains»). A thunk that defers a computation for a function to run keeps the binder form, as the two-parameter case does.

The multi-parameter residue retires as the medium writes the migration (`PLAN.md §11`, iteration is topology). Neither case is a second way to mint a function, and no third way is being kept open.

### Examples

**Zero arguments:**
```
() => 42
() => { let x = compute(); x + 1 }
```

**Single argument (the arm list, the canonical form):**
```
{ x => x + 1 }
{ _ => 42 }                                // argument ignored (PWild pattern)
```

**Multiple arguments** (the residue above; its final form is a reference):
```
(a, b) => a * b
(a, _) => a            // second ignored
(_, _) => 0            // all ignored
```

**Destructuring (an ordinary arm pattern, with no parameter position to nest in):**
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

This is the same rule as for named-fn bodies (§"Function declarations"): the brace requirement depends on whether the body is a `BlockExpr`, never on line count. The literal's own braces are not a body's braces. They hold the arms, and an arm's body follows the rule like any other.

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

An arm list is a function, `match` is that function applied, and one `parse_match_arms` parses both, because they are the same node. (Before this mechanism existed, 197 of the wheel's 515 lambda sites were `(x) => match x { … }`, a wrapper written only to reach a form the language already had.)

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

Diagnostic: **`E_RedundantFnOnLambda`**. `fn` is reserved for named declarations; remove `fn` from anonymous forms.

```
// REJECTED — zero-arg via `||`:
|| expr
```

Diagnostic: **`E_LambdaAsOrOr`**. `||` is logical OR (TOrOr); use `() => expr` for zero-arg lambdas. Quick Fix: replace `||` with `() =>`.

---

## Pipe verbs — the five-verb topology

Mentl has five pipe operators. Each writes one shape of flow, and the shape on the page is the shape the compiler sees. The sections below define each one; §«Composing the five» says how they are used together, with the compiler's answer at each.

### `|>` — converge

Sequential data flow. Right-applied to left.

```
input
  |> stage_a
  |> stage_b
  |> output
```

**Layout:** `|>` sits at the left edge, with each stage on its own indented line.

Single line acceptable for short chains:
```
x |> double |> square
```

**Type rule:** if `left: A` and `right: A -> B with E`, then `left |> right: B with E`. The chain's row unions all stage rows.

**A stage is applied, never minted.** A call standing as a stage is completed in place, its hole filled by the piped value. A function literal standing as a stage, such as `x |> { v => v * 2 }` or `x |> { 0 => 1, n => n - 1 }`, binds the piped value to its parameter, and its body is lowered in the frame the pipe stands in. Neither builds a closure, so neither costs the frame anything, and a stage-shaped chain inside a `with !Alloc` function stays allocation-free. The parameter is a binder of that frame like any other: it may share a name with a local there, and the local reads its own value again once the stage closes. A bare reference to a module-level function or op standing as a stage is a call to it. `x |> f` is the direct call `f(x)` and `x |> put` is the perform `put(x)`, both in the frame the pipe stands in and both the same graph as the call they spell, never a call through the function's record (tests/micros/mn-pipe-into-op.mn; the derivative reading enters `x |> f` as it enters `f(x)`, frontier `derive-distort`). A sequence primitive standing as a stage pays its declared row, as its call does: `xs |> slice(??, 0, 1)` builds a view, which is `Alloc`, and `xs |> list_set(??, 0, 5)` stores into the piped list, which is `Mutate` where that list is older than the frame (tests/micros/mn-substrate-stage-pays-its-row.mn, mn-substrate-stage-fresh.mn).

**A stage whose callee is not yet known is the Stage Law's product.** Where the callee's arrow is still a variable (a field of an unannotated record, a parameter, a forward local), `x |> rig.tone(320.0)` is judged as `rig.tone(320.0, x)`: the written arguments first, then the piped value's slot. A callee whose arrow is known is completed by its own parameters, and one whose call is already complete and returns a function is applied whole.

**A product built at the site fills a stage's open slots.** `((l) >< (r)) |> mix(0.35)` is `mix(0.35, l, r)` when `mix(0.35)` leaves exactly two slots. The parentheses are needed because `|>` binds tighter than `><` in the precedence table. This is the merge, Faust's `,` followed by `:`, and the tuple is never built. A stage with one open slot takes the product whole, as it takes any value. The merge requires exact agreement and applies no heuristic.

**A value piped into a stage must meet the stage's requirements.** The piped value fills the stage's parameter exactly as a call's argument fills it, so the parameter's refinement is claimed of the value at the pipe and the row its precondition guards is paid there when the claim is open: `30000.0 |> alpha` over `alpha(c: Hz)` is refused as `alpha(30000.0)` is, and a partial stage must meet the contract of the slot it leaves open (§«Refinement types»).

### `<|` — diverge (fanout)

One input feeds multiple branches, and the output is a tuple of the branch outputs. **The input is borrowed into each branch**, so a value cannot escape the branch tuple.

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

**Layout:** `<|` sits at the left edge before the branch tuple. The branch tuple's `(` opens on the same line as `<|`; branches are on indented lines; the closing `)` returns to the indent of the opening branch.

**Type rule:** if `input: T` and branches are `(T -> A, T -> B, T -> C)`, the result is `(A, B, C)`. The row is the union of all branch rows and the upstream row.

**Ownership:** the input is shared (borrowed, `ref` / `!Mutate`) across all N
branches (use-count N → borrowed), and this ownership is what distinguishes
the two fanout verbs. `own` values cannot flow through `<|`
(`E_OwnershipViolation`: the formatter never silently rewrites a coherent glyph
that its author wrote, so the error reports the violation instead). A branch
that must consume its input independently is `><`, the own-consuming surface
of the same parallel-fanout topology (see §`><`). The read-only borrow is what
makes execution as a handler provably race-free: a shared value borrowed
read-only is safe across threads.

**A branch must meet the same requirements as a stage.** Each branch is applied to the input as a pipe's stage is, so its parameter's refinement is claimed of the input and the row its precondition guards is paid where the claim is open: `0 <| (inv, inv)` over `inv(n: Positive)` is refused as `0 |> inv` is (tests/micros/mn-refine-fanout-branch-owes.mn).

**A fanout over one stage is the pipe.** A product of one field is its field, so `x <| f` answers what `x |> f` answers and the two are one graph: the parser builds the pipe, and `mentl fmt` writes `|>`. A tuple literal of one, `(a,)`, is `a`, as the pattern `(p)` is `p` (tests/micros/mn-product-of-one.mn).

### `><` — parallel compose (structural N-ary)

**Two or more independent pipelines run in parallel.** Each branch has its own input, and the outputs are tupled.

**`<|` and `><` are two surfaces of one parallel-fanout topology, distinguished
by input ownership (arm 5)**, not two different shapes. `<|` ref-borrows one shared
input across N branches (use-count N → borrowed); `><` own-consumes N
independent inputs (each use-count 1 → consumed). Both fan out and tuple the
results. Whether the input is shared or distributed is inferred from the branch
input use-count, by the same inference that drives `own`/`ref`.

**The kernel merges them into one node.** At the substrate there is one
`PFanout` node carrying an arity and an ownership aspect. The duplicate
`PDiverge`/`PCompose` nodes and their parallel infer and lower paths collapse
into it (Carried-Truth: the share-vs-distribute fact is read from use-count,
never re-derived as a second node kind). **The surface keeps both glyphs** as
the author wrote them, to record intent. Ownership checks that the glyph is
coherent and never silently overwrites it. An `own` value through `<|` is
`E_OwnershipViolation`, and the error reports the violation. A genuinely shared
input under `><` is canonicalized to `<|` by the formatter, which fixes
incoherent source. A coherent glyph that its author wrote is never silently
rewritten.

**Independence is the topology; concurrent execution is a `~>` handler choice.**
`><` declares the branches independent. Whether they run sequentially,
threaded, packed into SIMD lanes or on a device is set by a `Schedule`
handler installed in the enclosing `~>` chain:
`type Strategy = Seq | Thread | Simd | Gpu` (an ADT, never a `mode == 0/1/2`
int). In what it performs, the verb stays pure topology. It adds no effect of
its own to the row, and the schedule is not in the row. The cursor reads the
strategy from the live handler stack (the same `resolve_in_stack` every
`perform` uses), exactly as persistence is a handler swap (`PLAN.md §4④`).

What the verb costs is what its let-spelling costs. Under a schedule that runs
the branches in the frame (`Seq`, and `Simd` and `Gpu` until they have a
device), each branch is evaluated where the fanout stands, with no thunk and no
carrier, and the tuple of results is built only where it escapes. A fanout
taken apart where it is made (`match (x + 1) >< (x + 2) { (a, b) => a * b }`)
binds its parts to registers. A fanout piped into a stage with as many open
slots merges into it (`((l) >< (r)) |> mix(0.35)` is `mix(0.35, l, r)`,
§«`|>` — converge»). Neither allocates, so `with !Alloc` accepts both. A fanout
whose tuple escapes (returned, stored, or handed whole to a call) builds the
tuple and charges `Memory + Alloc` in its frame, and `with !Alloc` refuses
that. A spawning schedule builds a thunk per branch, and that cost is charged
to the install that runs it, where the install stands. So a callee declared
`!Alloc`, like one declared `!Thread`, takes no spawning demand from a caller
and runs its in-frame form. Under every schedule, a `<~` in a branch literal is
the enclosing record's line: a thunk minted per call holds that line in its
slot instead of a ring of its own, so `step(1.0)` ticks one recurrence whether
its caller installs `parallel_compose` or nothing.

**With no `Schedule` installed, the schedule is `Seq`**: branches are evaluated
inline in source order, which is deterministic and easy to debug, and the
default does not appear on the page. `~> Thread` runs the branches on parallel
threads. `~> Simd` maps a `[f32; 4]` branch tuple onto a v128 lane, so the
representation gradient and the topology axis combine in one read. Because
`<|` borrows read-only and `><` shares nothing, the schedule is provably
race-free. A real-time region can declare `with !Thread`, and the medium
proves, transitively, that no spawn occurs (provable like `!Alloc`; Rayon and
Faust cannot express this). `mentl where` prints the chosen strategy as a
badge, `>< [Thread ×4]`, which is output and never written as input. It shows
each site in the glyph its author wrote, with the branches it spawns (`<| [Seq
×2]`; a sequence fanout as `fanout [Thread, a branch per element]`), and a
site whose frame installs no schedule names the callers that demand it.

**The compiler checks the race-freedom claim.** A spawned branch runs in the
world it was spawned in. The task record carries the install chain of the
perform that spawned it, and the fresh instance installs that chain before the
branch runs. So an effect a branch performs reaches the handler installed at
the fanout's frame, from a second instance, and the schedule's own ops answer
there too: `current_id()` inside a branch reaches the `parallel_compose` that
started it. `E_ThreadedBranchEffect` (armed) refuses, at lowering, any effect
in a branch's row whose covering handler at that frame matches one of three
cases. The handler is stateful (two instances resuming `with n = n + 1` on one
state record). It lies beyond the frame fence with no caller's schedule
demanding the fanout (a caller's install is provable only along a demand,
described below). Or it is stateless but performs, from an arm, into a
stateful handler further out (an arm runs in the spawned instance and its
performs resolve outward, so the walk follows each handler's own residual row
down the stack). The refusal states the fix: install a stateless handler at
the fanout's frame, or install the handler inside the branch, where each
instance gets its own state record.

The rule reads writes, not declarations. A handler is stateful when an arm
writes its state by either of a field's two writers: a `resume … with` update,
which replaces the record's word, or an in-place store into what the field
holds (`list_set(buf, 0, …)`, directly or through a callee that stores into
its parameter). This is the same fact an install's arena reads. So a state
that is only read is shared read-only across instances, and the program runs.
The rule also reads a branch's own stores by their targets. A store into
memory older than the branch, such as a buffer both branches capture or a
module value, is one memory written from every instance, and the refusal names
the store. A branch that reaches code storing into memory older than that
code's frame carries `Mutate` (§«Negation in `with` clauses») and is refused
the same way, so two branches that call one function and both tick its
feedback line are refused. A store into memory the branch allocated builds a
value and runs; a voice minted in the branch and ticked there is one such case
(tests/frontier/mn-threaded-branch-captured-store.mn,
tests/micros/mn-race-store-into-branch-memory.mn).

**A spawned instance shares the module's values.** A module value let belongs
to the root: its init runs once, in the root, before `main`, and every spawned
instance reads the root's values through the task record. A branch reads the
module buffer the root updated in place, and an init that prints prints once.

**A branch's abandon is re-raised at the join.** A branch whose perform never
resumes leaves its thread with the op and its arguments stored in the task
record. The join re-raises that abandon in the joiner, where the first
abandoned branch in join order wins, and the joiner unwinds from the join to
the install whose arm answers. That answer is the fanout's value. For example,
`match (0 <| ({ _ => ab() }, { _ =>
10 })) ~> parallel_compose ~> h { (a, b) => a + b }` with `ab() => (5, 0)`
answers 5, and the same fanout under `sequential_compose` answers 5 through
the spawn arm's own call boundary. A branch that yields a live continuation
has nowhere to resume, because no joiner can hold it, so it traps loudly at
the thread's end and never silently joins its dummy.

**The schedule reaches a callee's fanout by demand.** A fanout's own frame's
install wins. A fanout whose frame installs no schedule runs under the
schedule that a caller installs over a direct call to it, and so does every
fanout in that callee's direct-call reach. `fn both() = (a()) >< (b())` under
`(both()) ~> parallel_compose` spawns both branches, and the callee is emitted
as a schedule twin, keyed by the install's schedule, beside its instantiation.
What the compiler proves determines the dispatch, just as a twin is keyed by
what its body reads. Two things bound the reach, and the row reads each as a
decision. First, a callee declared `!Thread` keeps its own frame's schedule:
the demand reads the negation, so a real-time region's fanouts stay sequential
under any caller. Second, the demand crosses direct calls only. A function
value minted under the schedule (a lambda, a partial, a nested fn) keeps its
own frame's schedule, because a value can outlive the install, and a spawn it
carried out would find no handler on the chain
(`Hβ.lower.schedule-through-a-value`). A branch thunk, an install's arm and a
state init never leave the extent, so they take the schedule. A direct call is
the declaration its callee's edge reaches, so a nested fn that shares a
module-level fn's name never answers for it
(tests/micros/mn-schedule-reach-shadowed-name.mn). The race rule is read along
the same demand. Each demanded fanout's branch rows are checked against the
installs between it and the demanding site, and a branch whose row is a
callback parameter's row is read at the instantiating site. For example,
`fn tally(f) = (f()) ><
(f())` called with a callback that bumps a stateful counter is refused, where
the lexical rule found a free row.

**`fanout(f, xs)` is the sequence fanout**, `><` over a runtime sequence: `f`
is applied to each element as an independent branch, and the results are
collected in order, under whatever schedule governs the site. It is typed
exactly as `map` is, and with no schedule installed it is `map`. Under a
Thread-class install every element's branch is spawned and joined in source
order (`fanout_threaded`, lib/threading); under a Persist-class install each is
checkpointed and joined (`fanout_persisted`, lib/persist). `map` itself stays a
sequential loop by construction (§Vocabulary). Only a fanout declares its
applications independent, and that is the whole difference between them. Simd
and Gpu pack a fixed lane count and run a sequence fanout sequentially. The
race rule reads the function a sequence fanout applies as every branch's
function, so a `~> parallel_compose` over a fanout whose function writes
through a stateful handler is refused. This check enforces the deterministic
partition (`PLAN.md` §11, forks on every core)
(tests/micros/mn-race-sequence-fanout-store.mn,
mn-race-sequence-fanout-stateful.mn).

**Alternatives are a choice, never a fanout.** A fanout's branches are
independent work whose results are all wanted. Alternatives are one
computation tried several ways, and `choose(options)` (lib/choice.mn) expresses
that. It suspends the computation around it, and the handler that catches its
resumptions defines what choosing means: `every` joins what each option
answered, and `first` stops at the first option that answers `Some`. The
??-fan is one choice (`segment_verify`, src/synth_proposer.mn). Its candidates
are the resumptions of one `choose`, and the compiler's forking handler judges
each in a graph instance of its own, seeded with a version of the graph, and
then drops it. The fork is written once, in that handler's arm
(tests/micros/mn-choice-every-first.mn).

**`><` is a structural N-ary construct the formatter renders in one of two layouts** (a presentation choice, never a parse distinction; there are no semantic "forms," only render shapes):

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

**Layout is the formatter's projection and never carries meaning.**
The precedence table alone draws the tree: `><` binds looser than
`|>`, so `a |> f >< b |> g` is `(a |> f) >< (b |> g)` with or without
parens. The formatter writes the parens and chooses the layout; the
parser enforces nothing about whitespace or parenthesization.

**Render rule (formatter canon):**
- Each branch is rendered in parentheses, `(...)`, to mark where branches begin and end.
- All branches single-line and the total fits the target width → inline layout.
- Any branch multi-line, or the total exceeds the width → vertical layout: each branch on its own line, and `><` alone on its own line at indented center (4-space indent).
- Mixed shapes normalize to vertical at save.

The construct reads top to bottom (vertical) or left to right (inline). After `><`, the chain returns to the left edge for whatever consumes the tupled result. The fanout is parenthesized, because `|>` binds tighter than `><` (§Precedence) and an unparenthesized pipe at the foot would enter the last branch:
```
((audio_left  |> compress |> limit)
    ><
(audio_right |> compress |> limit))
|> stereo_mix
```

### `><` branch typing

A `><` branch is a value computation. "Each branch has its own
input" means the branch is the applied pipeline, a complete
expression whose result the fanout tuples. Every render example
above is one: `audio_left |> compress |> limit` is the limited
signal, not a function waiting for it. So a branch is valid when
the branch expression types in the ordinary way: the value
boundary evaluates it, the tuple carries its result, and a
genuinely ill-typed branch shows up as a unification failure,
with a Reason pointing back to its own site. There is no separate
judgment of branch shape. Four spellings of the same fanout
(calls, literals, pipes, bare vars) have one type and one verdict
(the quartet gate, `tests/frontier/mn-pcompose-value-branches.mn`).
The stage requirement belongs to `<|` alone, where each branch is
applied to the borrowed input and a non-function branch fails
that application's unification. The parser never inspects branch
shape, because classifying forms at parse time would commit to a
form before the judgment has read it, which Governing principle 1
rules out.

### `~>` — tee (handler-attach)

`expr ~> h` installs handler `h` over `expr`: it draws the install edge to `h`'s node and intercepts the effects `expr` performs. `~>` is the one install verb, and there is no keyword spelling (`handle` is not a keyword; see §«Installation»).

**The one law:** `~>` has one precedence, **1, the loosest binary
operator** (see §Precedence). The handler at the foot of a chain
governs everything to its left in the expression; parenthesize
`(stage ~> h)` to narrow the scope to one stage. There is no second
rule. **Whitespace never changes meaning in Mentl**: layout has no
effect, and the inline and block forms mean the same thing.

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

Block or inline layout on the page is the formatter's choice,
projected from the shape of the tree: a chain body gets the block
layout (`~>` on its own line at left-edge indent), and a
single-stage body renders inline. Either way it is the same node
with the same scope.

**Type rule:** `row(expr ~> h) = row(expr) - handled(h) + row(h) + cost(h)`. The handler subtracts what it absorbs; anything its arms perform is added; and the install's own cost, a fact of its class, is charged to the frame it stands in: a dispatched install (a schedule included) builds the record its arms run against and pushes its world, so it costs `Memory + Alloc`, and a derivative reading (`~> grad(w)`, which replaces the install with the extent's derivative program) costs nothing.

*An install whose record never outlives its extent could live in the frame and cost nothing; that representation is `Hβ.lower.install-record-in-the-frame`, and the charge follows it when the lowering builds it.*

**`~>` governs the topology to its left, including a `><` / `<|` fanout.** Because
`~>` is the loosest operator, a `Schedule` handler at the foot of a chain governs
every fanout in the body: `(a |> f) >< (b |> g) ~> Thread` runs both branches
threaded. The branch bodies do not change, so there is no second version to keep
in sync. The fanout verb stays pure topology, and the cursor reads the execution
strategy live from this install edge (§`><`). Adding `~> Thread`, swapping it for
`~> Simd`, or installing `~> persist(...)` over a multi-shot branch is the entire
diff between sequential, parallel, lane-packed and crash-surviving execution. The
schedule is a fact in the `~>` edge and is never built into the verb.

**A derivative reading is the other projection an install can be.** `(body) ~> grad(w)`
uses lib/ml/grad.mn's `Derivative` effect and its `grad` handler. It evaluates
`body` exactly as it evaluates without the install, and lets the body query
`d(v)`: the partial derivative of `v` with respect to the seed `w`, with every
other free variable of the extent held fixed.

```
fn train_step(w: Float, x: Float, want: Float) with !Alloc =
  w - 0.05 * ({ let e = want - w * x; d(e * e) } ~> grad(w))
```

Like a schedule, the install is recognized by the effect its handler answers,
and it builds no record, pushes no world and never calls its arm. The lowering
derives the derivative program from the body's own graph and emits it beside the
forward one, so there is no tape and no second copy of the chain to fall out of
step, and the step above leaves the heap as it found it. The seed is a Float
variable in scope, or a record or tuple of Floats (below). State that lives past
the extent, such as a `<~` line or a handler's state, enters it held fixed, and
a `<~` line inside the extent carries its tangent as a recurrence of its own.

**The reading crosses a function value and a handler's arms through the record
that holds them.** The principle handler = state = closure applies here too. A
closure minted under the reading carries its captures' tangents in its own
record, beside the captures, so `d(f(3.0))` for `f = { v => w * v }` minted
under `~> grad(w)` is 3 wherever `f` is called: through `apply(f, x)`, through
a handler's config, or through the prelude's `fold`. A perform enters its arm's
derivative program, and a state field written by `resume … with` carries its
tangent beside the field. So `fold(0.0, (a, x) => a + w * x, xs)` differentiates
in `w` through the closure, the accumulator's state and the perform that feeds
it, and scene 1's distortion differentiates through the envelopes its handler
keeps. A function value or an install minted before the reading opened is a
free variable of the extent and is held fixed. Its captures and its state carry
no tangent where the reading opens and are differentiated from the first write
inside it, so `d(g(3.0))` for the same `g` minted before the install is 0.

**A product seed is answered in one reverse sweep.** The seed may be a record
or tuple of Floats, as in `~> grad(ws)` with `ws = {a: 2.0, b:
1.0}` — and `d(v)` is then the gradient of `v` in every Float field. It is read
by destructuring where it is asked: `let {a: ga, b: gb} = d(v)` binds each
field to the adjoint of its seed and builds no record, so a `!Alloc` extent
stays allocation-free. The rules of the reading are written once, as a linear
program over the primal's residuals. Forward and reverse mode are its two
projections. Because they mean the same thing, the compiler chooses between
them by cost, and the author never writes the choice. A scalar seed is answered
forward (one pass answers every query). A product seed is answered in reverse:
the primal runs first and keeps each test and scrutinee as a residual, then
each query transposes the statements before it back to the seeds, one adjoint
per tangent. A call into a known function runs that function's adjoint twin,
which recomputes the callee in its own frame and hands its parameters'
adjoints back through registers. The reverse projection does not carry a call
through a function value, a perform reaching an arm, a `<~` line or a record
carrying a tangent, an install, an early return, a query inside a callee, or a
recursion anywhere in the extent's reach. A product seed that reaches one of
these is refused, and the refusal names the vector-forward reading
(`Hβ.derive.vector-forward`); the compiler never answers with a slope of zero.
Holding a gradient as a value (`let g = d(v)`) is refused too
(`Hβ.derive.gradient-as-a-value`), since the record it would build is an
allocation the row does not account for. Reverse mode through iteration,
through the record and through a `<~` line's history are
`Hβ.derive.transpose-through-iteration`,
`Hβ.derive.transpose-through-the-record` and `Hβ.derive.bptt-priced-by-the-row`.

What the reading cannot carry is refused. `d` of a value whose tangent was
lost (into an aggregate, across a multi-shot perform, off a line ticked by
forward code, or through another `d`) is `E_DerivativeUnreachable` at the
query. The error names where the tangent was lost and never reports a slope of
zero. A mint, an install or a state write that would store a lost tangent into
a record is refused where it stands, since later reads of the record could not
detect the loss. A `d` outside every reading leaves `Derivative` unhandled at
the root. A `<~` line that a closure record owns is
`Hβ.derive.closure-line-tangent`.

**An arena is the third: the extent's allocations die at its exit.** `(body) ~> arena`
uses lib/arena.mn's `arena`, which answers `Alloc` by forwarding. It evaluates
`body` exactly as it evaluates without the install, and at the exit reclaims
everything the body allocated except what its publication reaches: the body's
value, and each value the body stored into memory older than the arena. Those
values are moved, by type, and the line resets behind the copies, so an exit
costs what crossed it and never what died.

```
fn total_of(n) = (build(n) |> fold(0, add)) ~> arena   // the list dies; the sum crosses
```

Like a schedule and a reading, the install is recognized by the effect its
handler answers. It builds no record and pushes no world, and it charges
`Arena`, an effect no handler answers, so `main`'s row shows whether a program
opens an arena, and a program that opens none pays nothing at a store. A store
into older memory is known where it happens: a list slot's `list_set`, a
handler's state commit and a `<~` tick each journal the slot with the type
known at the store, wherever the judgment cannot prove that the target belongs
to the extent. A store into a buffer the extent allocated needs no journal
entry. For a parameter, the answer depends on its callers, and for a handler's
state, on its installs. A value whose type is not known at the store (a
function, a continuation, a store through `list_set` reached as a value) is
never moved.
The exit keeps the whole region instead, which is correct for any program and
reclaims nothing (`Hβ.arena.closure-evac-face`). Reclamation is reachability
from the publication, never a `Consume`, so ownership's regions stay
compile-time facts. In a module that spawns, each instance allocates in a run
of its own: one atomic add per 64 KB chunk on the image's frontier, then a
private bump inside the chunk. So an arena's region is a span of its own
instance's run, and it reclaims in a spawned branch as it does in the root. An
arena open across a spawn its instance makes, or across a chunk that could not
extend its run, keeps its region. A spawned child's records lie in the child's
run, where the exit never looks, and they may hold the extent's values
(`Hβ.arena.extent-spanning-a-spawn-keeps`).

**A suspended arena keeps its region, and each resumption is an arena of its
own.** An op performed inside an arena and answered by a handler outside it
suspends what the arena encloses: the continuation the handler holds and the
perform's arguments live in the arena's region, and the rest of the body has
not run. So the exit does not end the extent. The arena suspends instead, and
its region joins the extent around it. Every resumption runs the rest inside a
fresh arena that exits where the body ends, reclaiming what that resumption
built and moving out what it published. The fresh arena encloses everything the
original enclosed, a callee's rest after the perform as much as the body's own,
and it opens before any of it runs. Under a handler that resumes three times,
`fn step() = work() ~> arena` with `fn work() = pick() +
len(build(200)) - 200` grows the heap 96 bytes in all, against 19,240 with no
arena. When an arena's body suspends, the arena is a point at which the frame
it stands in is captured (§«Resume discipline»), so the rest of that frame
resumes at the arena's value. An arm that never resumes leaves the arena
suspended for good, with its arguments intact. `arena_stat(ArSuspended)`
counts the suspensions.

### `<~` — feedback (cycle closure)

Closes a cycle back into the pipeline; the value computed flows back as input on the next iteration.

```
signal <~ delay(3)        // 3-sample feedback delay
state  <~ accumulate(0)   // running accumulator
filter <~ filter_spec(N, coeffs)
```

**Layout:** `<~` may appear inline (one line) or at indented center for clarity:
```
signal
    <~ delay(3)
```

**Type rule:** `<~`'s RHS is a **state-element**: `delay(N)`, `accumulate(init)`, `filter_spec(N, coeffs)`, or any user-defined register of that shape. The verb checks it as one (`FeedbackSpec`), and a non-spec RHS fails that unification with a Reason pointing to its own site.

**The causality rule:** a cycle with no delay has no computable value, because the prior would be the very output being computed. So `x <~ delay(0)` is **`E_ZeroDelayFeedback`**, an armed refusal at the `<~` site (nonzero exit, zero WAT). Faust makes this impossible to write by inserting its delay implicitly. Mentl names the depth, so the depth can be wrong, and the medium refuses a wrong one. The refusal is one arm of the depth read described below: the same read that sizes the line also judges whether that size can be expressed. Both `delay(0)` and `Delay(0)` are refused, since they are the two spellings of one FeedbackSpec variant.

**The iterative context is the clock, and the clock is inferred, not required.** A `<~` site is a per-site state register whose previous iteration is the enclosing function's next call. That is why the stage that `bandpass_stage` mints (`lib/dsp/signal.mn`, four `<~` sites) carries no clock in its row and is still correct. Requiring an ambient effect would refuse correct code, including every `<~` site in the wheel's own link. So no error class refuses a `<~` for a missing context. The correct refusal belongs to the inferred clock (`Hβ.dataflow.clock-calculus-sample-rate`, Lustre's clock calculus): once the medium proves what advances a cycle, "nothing advances this one" becomes a measurement, and the refusal reports that measurement. `Sample`/`Tick`/`Clock` then become instances of the class by what they do, never by a list of allowed names.

**The declared depth is the line's depth, and the line is a ring owned by the record of the function that contains the cycle.** `delay(N)` carries N priors. The site's line is an N-slot ring, and the prior the cycle reads is its oldest slot, y[n−N]. Each tick stores the output over that slot and advances the head by one, so a tick is a load, a store and a bounded increment at any depth (`delay(24_000)` costs what `delay(1)` costs per tick; `tests/frontier/mn-feedback-deep-line.mn` drives 2,000,000 ticks at that depth and the frontier leg prints the ticks per second). `delay(1)` is the single register it always was, and `delay(3)` is genuinely three deep: the same recurrence driven six times answers 6 under `delay(1)` and 2 under `delay(3)`.

The ring is allocated once, where its owner is built, and never per tick. Its owner is the record of the function the `<~` sits in (the principle handler = state = closure, applied at the site). A lambda's line lives in the closure record after its captures, so every closure minted from one lambda is its own filter (`let lp_l = lowpass(0.3)` and `let lp_r = lowpass(0.3)` are two lines, the two-channel shape every stereo stage uses). A handler arm's line lives in the install record after the arms, so every `~> h` is its own filter. A reified remainder's line lives in the k record and is shared by that k's resumptions, as every heap write of the remainder is. A top-level fn's record is the module's immutable data record, so its line lives in an instance global allocated at start, one per emitted twin, and a generic recurrence reached at Int and at Float ticks two lines at two widths. A `<~` directly in a module value let's init is static in the same way, with its line owned by the module's init function, while a fn nested in that init is a closure minted there and keeps its lines in its record (module scope is a frame). A filter that must exist once per signal is therefore a maker: lib/dsp's `lowpass_filter(sr)`, `highpass_filter(sr)`, `dc_blocker()` and `envelope_follower(attack, release, sr)` each return the stage, and each stage minted owns its line (`tests/micros/mn-feedback-closure-instances.mn`, `mn-feedback-arm-instances.mn`, `mn-feedback-twin-width.mn`, `mn-feedback-deep-line.mn`).

**The `!Alloc` row still holds across the cycle.** The RHS is checked as a `FeedbackSpec` value, since its type is what the site reads, but its construction never executes. Emit discards the lowered spec and the prior is a register read off the ring, so the site judges the spec in a frame whose row is dropped (tests/frontier/mn-feedback-transport.mn tests this). The surface question behind this stays open and is the smaller artifact: whether the RHS should stop being an expression and become a static depth annotation, which is how the emit already treats it (`Hβ.effects.feedback-row-substitutes`, branch B).

**The depth must be a literal.** The literal is compiled into the line twice. It sizes the ring where its owner allocates it (`line_ring_bytes`, src/backends/wasm.mn: a two-word header, then the slots), and it is the modulus the head wraps at on every tick, an immediate in the emitted code. Today's line cannot hold a depth that the medium can only read at runtime, and giving such a site one slot would be exactly the silent error the depth read is there to prevent. So `delay(n - 1)` is **`E_ComputedDelayDepth`**, armed at the `<~` site. A runtime depth is the same ring with a cap word: the depth stored beside the head in the header's second word (padding today), the ring allocated at the size the value names, and the tick's modulus read from the ring instead of the immediate. That is `Hβ.dataflow.delay-line-runtime-depth`. It depends on no other landing, only on a program that needs it.

**Binding the prior: the recurrence form.** The LHS may be a one-parameter function literal `{ prev => body }`, where `prev` binds the prior iteration's output, read live. This expresses a genuine IIR recurrence `y[n] = f(x[n], y[n-1])` instead of approximating it with a bare feed-forward LHS:

```
fn lowpass(x: Sample, a) -> Sample with !Alloc =
  { prev => a * x + (1.0 - a) * prev } <~ delay(1)
```

The prior is a graph node (the feedback site's own carried value), not a register copied into scope. The literal's parameter resolves to `RFbPrior` → `LFeedbackPrior`, which emits a direct read of the site's prior local, and `prev` binds it. The body is inlined, never a heap closure: a `<~` recurrence that allocated per tick would break the `!Alloc` real-time row, so the prior is a register read. A bare-expression LHS (no literal) is the feed-forward form, which computes on the current input only; the literal's parameter is what carries `y[n-1]`. The binder spelling `((prev) => body) <~ delay(1)` builds the same recurrence and is the residue §«Function literals» names. This form does more than Faust's untyped `~`: the prior carries the same refinement row (`Sample`/`Hz`/`Gain`) and the same `!Alloc` proof as the forward path. (Surface kernel correspondence: primitive #3 is the `<~` verb; under primitive #5 the prior is owned-read, not aliased.)

### Composing the five — the shape of a whole program

This section is written from the ultimate form PLAN §0 and §5 describe, and today's compiler is measured against it at the end. Every example is a real program in this repository, shown as `mentl fmt` writes it, with the compiler's answer at that site quoted beside it from the pinned binary.

**The thesis in syntax.** A Mentl program is written in three layers and nothing else. The shape of every flow is written with the five operators, so the shape on the page is the shape the compiler holds. The claims are written on the stages: what a stage must never do (`with !Alloc`, `!Trap`, `!Network`) and what range its values keep (`Hz`, `SpinW`). What the effects do is written at the right edge, as handlers installed with `~>`, and no body ever says how an effect is handled. The compiler derives everything else: each stage's row, the ownership of every value, the schedule of every fanout, the clock and the memory of every cycle, the width of every number, and the proof that every claim holds through every call. At any position the cursor says what is true there and why, back to the decision that made it so. Where the author leaves `??`, the compiler forks the candidates, proves each, shows only the survivors and asks only when two proven meanings differ. The same program runs against a model, a recording or real hardware by swapping one handler.

**One shape per operator.** The third column is what the compiler derives when the shape is written; where it cites a PLAN §11 step, that part of the derivation is open work, and the citation is replaced by the command's output when the step lands.

| The shape you mean | Write | The compiler derives | Shown in | Where its memory lives |
|---|---|---|---|---|
| stages in sequence | `x \|> f \|> g` | the chain's row; a stage is applied in place, never minted, so a chain allocates nothing; a chain over a sequence yields its results outward in one pass, and deforestation is a rewrite the rows license (PLAN §11.7) | every lesson; `frame` in lesson 2 | the stage's result only; the chain itself owns no record |
| one value to several places | `dry <\| (rig.echo, rig.room)` | the input is borrowed by every branch, so the fanout cannot race; the result is the branches' product; a join aligns branches of known latency or refuses the misaligned merge (PLAN §11.7) | lesson 3, line 49 | one record, the input, read by every branch; a branch's result is its own |
| independent flows side by side | `(echoed) >< (dry)`, `fanout(render, notes)` | each branch owns its input; the schedule comes from the handler at the foot, never from the verb, and runs on every core deterministically (PLAN §11.8) | lesson 3, line 50; lesson 10, line 65 | the branches allocate in the extent that encloses the fanout; a spawned instance allocates in a run of its own |
| the branches rejoin | `((a) >< (b)) \|> mix(0.35)` | the product fills the stage's open slots; no tuple is built | lesson 3, lines 50 and 51 | the stage's slots; no tuple record |
| a flow that needs its own past | `{ prev => … } <~ delay(N)` | a line of depth N owned by the stage's record, allocated once, so `!Alloc` holds across the cycle; the cycle's clock is inferred, the depth may be a value read at run time, and the line is read at any tap (PLAN §11.7) | lesson 2, line 44; the controller's five recurrences in `decide` | the line's N slots, allocated once with the stage's record |
| what the effects do | `body ~> inner ~> outer` | the row loses what each handler absorbs and gains what its arms perform; the install edge carries the schedule, the derivative reading or persistence; a negation holds through every handler a caller installs (PLAN §11.1) | lesson 4, `rack`; lesson 9, `~> grad`; lesson 10, `~> parallel_compose`; the controller's `~> station` and `~> arena` | the handler's state record, which outlives every resume; an arena's body is an extent, reclaimed at its exit except what its result reaches (PLAN §4⑨) |

**Twelve rules for using them well.** Each is checked by the compiler, so breaking one is a refusal or a worse row, never a matter of taste.

1. A sequence is `|>`. Never `let x = f(y); g(x)`: the pipe is the same graph as the calls, and the reader sees the flow as one line.
2. The datum is the last parameter. Then every function can stand as a stage, and a partial call (`mix(0.35)`, `rig.dark(300.0)`) leaves the slot the pipe fills (§«The Stage Law»).
3. A stage is applied, never minted. A function literal standing as a stage costs the frame nothing, so a chain inside a `with !Alloc` function stays allocation-free; a closure is built only where a value escapes.
4. Choose the fanout by ownership, not by taste. `<|` when one value is read by every branch, borrowed and race-free by construction; `><` when each branch consumes its own input. An owned value through `<|` is `E_OwnershipViolation`, so the choice is checked.
5. Rejoin by piping the product into a stage with that many open slots. Never build the tuple by hand and take it apart on the next line; the merge is the stage's slots.
6. Memory is a cycle with its depth written: `{ prev => … } <~ delay(N)`, where `prev` is the output N ticks ago. A maker (`fn echo(fb) = { fn stage(x) with !Alloc = … <~ delay(N); stage }`) mints one line per stage, so stereo is two calls and the two never share a byte.
7. Handlers go at the right edge, innermost first, the sandbox outermost: `} ~> stdout_console ~> rack ~> sample_at(48000)`. Narrow a handler to one stage with parentheses, `(parse ~> catch)`, and nowhere else.
8. Decisions live in handlers, so you swap the handler, not the body: `warm_distort` for `spectral_flux_distort` in `rack`, `sequential_compose` for `parallel_compose` under the voices, real hardware for the `station` model. The body is unchanged and re-proven each time.
9. Say what a stage must never do, and what range its values keep: `with !Alloc`, `with !Trap`, `cutoff: Hz`, `-> SpinW`. The proof follows the shape through every call, so a claim on `decide` covers the whole decision.
10. Where you are unsure, leave `??`. The compiler proposes what it can prove, and asks when two proven candidates mean different things.
11. Layout is projection. Sequential verbs at the left edge, convergent verbs at the indented center (§«Canonical layout»). `mentl fmt` writes it, so nobody argues about it.
12. Read the shape back from the compiler before you trust it: the caret on the operator, `mentl why` on an effect, `mentl where` on a declaration. If the compiler cannot say the shape in one plain sentence, either the shape is wrong or the caret is, and the second is the open work named at the end of this section.

The signs that a flow has gone wrong are the drift list in CLAUDE.md: an index loop where a pipeline over a sequence belongs, a flag where a handler belongs, a closure used as a table of functions, several parallel lists where one record belongs, a cycle written as mutable state instead of `<~`.

**The whole program, by example.** Lesson 3 (`examples/pulse/course/03-bus.mn`) writes a stereo bus in three lines: one sample goes to the echo and to the room, each branch is put beside the dry signal, and the pair is mixed and clipped in sequence.

```
let (echoed, roomed) = dry <| (rig.echo, rig.room)
let l = ((echoed) >< (dry)) |> mix(0.35) |> soft_clip
let r = ((roomed) >< (dry)) |> mix(0.5) |> soft_clip
```

The compiler's answer at each operator, from the pinned binary:

```
$ mentl examples/pulse/course/03-bus.mn:49:30
Query: dry <| (rig.echo, rig.room) : (Float, Float)
Topology: the <| shares `dry` with 2 branches, borrowed, so they cannot race
Effects: e + e + e1 + e1
Why: the product of the <| branches' results, the input borrowed by each, at examples/pulse/course/03-bus:49

$ mentl examples/pulse/course/03-bus.mn:50:21
Query: (echoed) >< (dry) : (Float, Float)
Topology: the >< runs 2 branches, each owning its input, in sequence, since no schedule is installed over it, inside the source of the |> at examples/pulse/course/03-bus:50:11
Effects: Pure
Why: the product of the >< branches' results, each branch owning its input, at examples/pulse/course/03-bus:50

$ mentl examples/pulse/course/03-bus.mn:50:31
Query: ((echoed) >< (dry)) |> mix(0.35) : Float
Topology: the |> runs 2 stages in sequence, this one completing stage 1, and the fanout's product fills the first stage's open slots
Effects: Pure

$ mentl examples/pulse/course/03-bus.mn:63:5
Query: { : ()
Topology: the ~> installs `stdout_console` over everything to its left, answering Console, inside the body the ~> governs at examples/pulse/course/03-bus:58:3
Effects: Memory + Alloc + Sample(48000) + Trap + Mutate + WASI

$ mentl examples/pulse/course/02-line.mn:44
Query: { prev => a * x + (1.0 - a) * prev } <~ delay(1) : Float
Topology: the <~ feeds back the output 1 tick ago; its line is owned by `stage` and allocated once
Effects: Mutate
Why: through <~, at examples/pulse/course/02-line:44
```

The same bus without the operators is what every other language makes you write: a tuple built by hand and taken apart on the next line, three `let`s where one chain reads, a closure allocated per stage, and no proof that the two branches cannot race, because nothing in the text says the input is shared. The operators are not shorter for their own sake. Each one is a fact the compiler can prove because the shape says it.

Lesson 4 (`04-rack.mn`) writes a limiter as a handler and chains it behind the library's distortion; the frame calls `distort` and `tame` and never says how either is done, and `mentl why examples/pulse/course/04-rack.mn frame Distort` names where the effect enters: `frame calls `distort` at examples/pulse/course/04-rack:72:11`. Lesson 10 (`10-voices.mn`) renders four voices with `><` over a list, and `mentl where examples/pulse/course/10-voices.mn render` reads the schedule from the install edge: `fanout [Thread, a branch per element]` under `~> parallel_compose`. The grid controller (`examples/grid/station.mn`) keeps its memory from one reading to the next with five `<~ delay(1)` recurrences inside `decide`, and the caret inside the first of them, `mentl examples/grid/station.mn:188`, answers `Topology: the recurrence the <~ feeds back at examples/grid/station:186:19`.

**The developer's loop.** Write the shape; `mentl check` prints nothing; the caret on an operator says its shape; `mentl why` names where an effect enters and `mentl where` the schedule the install edge carries; a hole proposes the proven survivors and asks only at a tie (`mentl examples/pulse/course/08-hole.mn:50:76` proposes the one stage that fits, and `mentl accept` writes it; `mentl tests/proposals/scope-binder-tie.mn:7:3` offers the two parameters and the let around an `Int` hole beside the three literals that fit, and asks which value the position means); a refusal names the path (`mentl check examples/grid/station-leak.mn`); `mentl rename` moves a name through every edge; `mentl run` renders the sound. Every claim in this paragraph is a command that runs on the pinned binary today.

**What the cursor says today, and what it does not yet.** Each of the five operators answers at the caret with one sentence naming the fact it carries, as the block above shows: the borrow at `<|`, the ownership and the schedule at `><`, the stage completed and the slots the product fills at `|>`, the handler and the effects its arms answer at `~>`, the depth and the owner of the line at `<~`. A fixture states what the caret must say at an operator with `// at L:C: <shape>` (tests/micros/mn-shape-*.mn), in a short form of the shape, so the sentence's voice may change without a fixture moving. `mentl teach` narrates the annotation gradient (§«Gradient narration»), names the declarations that have a next step, and says once which have none ("nothing to unlock in seconds, note_hz, shape, frame, build_rig, main" on lesson 3). What the caret does not yet say in words: the Effects line at a site whose row is still open prints variables, `e + e + e1 + e1`, which a newcomer cannot read; that is PLAN §11.1, the row whole. The rest of the distance is the PLAN §11 steps the table cites, in PLAN's order, and this section adds no list of its own.

---

## Records

Mentl records are **structural**: a record type is `{name: T1, age: T2}`, and no nominal declaration is required. Two records with the same fields and types unify. Row polymorphism is supported.

### Canonical literal form

```
{name: "Morgan", age: 30}
```

Fields are separated by commas. Each field is `name: value`. A literal that fits the line renders inline. One wider than the line, or one whose field carries a comment, renders one field per line, each closed by its comma, so adding a field at the end is a one-line diff. This is the call-argument law applied to records (`mentl fmt` wrote a fourteen-field literal on one 300-column line until 2026-09-28):
```
{
  name: "Morgan",
  age: 30,
  email: "morgan@example.com",
}
```

**Field punning** applies when the value's expression is a variable with the same name as the field:
```
let name = "Morgan"
let age = 30
{name, age}              // sugar for {name: name, age: age}
```

Mixed punning:
```
{name, age, email: derive_email(name)}
```

**Sorting at parse time.** Fields are sorted alphabetically by name when the AST is constructed. Source order does not matter; the canonical AST has fields in alphabetical order. This makes record-equality and field-offset computation deterministic.

### Canonical type form

```
{name: String, age: Int}
```

The type is written inline and is structural. It is used in fn parameter types, return types and let-bindings, and needs no declaration.

### Row polymorphism

An open record type accepts any record with at least these fields:
```
fn greet(u: {name: String, ...}) -> String =
  "Hello, " ++ u.name
```

`...` is anonymous rest; `...r` binds the rest to a row variable `r`, lowercase by the case rule, and every `...r` of one signature is that one variable, so `fn sum_x(a: {x: Int, ...r}, b: {x: Int, ...r})` takes two records with one remainder:
```
fn extend(base: {name: String, ...r}, age: Int) -> {name: String, age: Int, ...r} =
  ...
```

**An open row keys the twin.** The row var is a quantified var like any other: the call site proves the whole field set, so each record shape mints its own specialization and reads its own layout, and `fn width(u: {name: Int, ...}) = u.name + 1` reads `name` at its own offset whatever other fields the caller's record holds (`tests/syntax/record-field-param-open`, `record-field-param-open-two-shapes`, `record-field-through-list`). A row that nothing closes is refused (`tests/floors/mn-unprovable-offset`, where the receiver is main's own parameter). The unseen rest of a record is always a row variable, never an assumed remainder: two open rows meet at one fresh variable both continue into, so a body reading two fields (`fn pick(u) = u.x * 10 + u.y`) still mints one twin per record shape (`tests/micros/mn-row-two-fields-two-shapes.mn`).

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

**Brace-header slots close at `{`, so a record construction never extends a header.**
Three grammar slots parse an expression whose own terminator is `{`: an `if`
condition, a `match` scrutinee, and a handler declaration's state inits
(`with x = init {`). In those slots a capitalized name followed by `{` is the
name alone, and the brace opens the form's block, never a record body:

```
handler find(pred) with found = None {   // `None {` — the `{` opens the arms
  ...
}
match acquired { ... }                    // scrutinee ends at `{`
if owner == None { fallback() }           // `None {` — the then-block
```

The grammar has no other option here. The slot's follow-set contains `{`, so a
greedy record continuation is ambiguous by construction: `None { x }` could be
a punned single-field record or a block holding `x`, and no lookahead resolves
it. Principle 3 requires the grammar to settle that ambiguity here. The common
case (a nullary constructor as init or scrutinee) costs nothing; the rare
record literal in a header is parenthesized, and the general unexpected-token
diagnostic shows how:

```
match (Person{name: n}) { ... }           // record literal in a header slot
```

Everywhere else (bindings, arguments, arm bodies, operands), `TypeName{...}`
extends as written. Layout is never consulted (principle 1): the slot
determines the reading, not whitespace.

**Every other brace reads its `{` through one test**: `...` opens an update, a pattern ending at `=>` opens an arm list (§«Function literals»), a field name followed by `:`, `,` or `}` opens a record, and anything else opens a block. A function body is such a slot, so `fn origin() = {x: 0, y: 0}` returns a record and needs no parens. `fn f() = {x}` is the punned one-field record, never a block holding `x`; such a block is what the formatter lifts to `fn f() = x` (`E_RedundantBraces`).

### Pattern syntax for records

```
let {name, age} = morgan       // both fields bound to locals
let {name, ...rest} = morgan   // bind name; rest is a record of remaining fields
let {name: n, age: a} = morgan // bind to renamed locals
```

`{name, ...rest}` binds `rest` to a fresh record of the remaining fields, each copied at its own width, and `rest`'s own field accesses read the residual's layout. `..._` keeps the pattern open without binding the rest, exactly as in list patterns. Binding a rest builds that record, so it charges `Memory + Alloc` in the frame the pattern stands in, and `with !Alloc` refuses it (`tests/micros/mn-record-rest-alloc.mn`).

**A record holds one field of each name**, so the rest has none of the fields the pattern names: the row behind them lacks their names, and `rest.name` is refused where it is written (`tests/micros/mn-record-rest-lacks-the-field.mn`). A rest named twice in a signature lacks every field written in front of it in either place.

**A record pattern reads its fields by name** through its receiver's whole field set, which the twin of each caller proves: a parameter's record may carry fields the pattern never names, sorted before or after the ones it does, and `fn pick(u) = { let {zeta} = u; zeta }` answers `9` over `{alpha: 7, zeta: 9}` (`tests/syntax/record-pattern-param`, `-param-rest`). The rest's own reads spell the residual's layout: `fn f(u) = { let {a, ...rest} = u; rest.b }` over `{a: 1, b: 2, c: 3}` answers `2`, the twin's pair for the row variable being the residual past the named fields (`tests/micros/mn-record-rest-through-param.mn`).

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

`{...existing, field: new_value, ...}` creates a new record by copying `existing`'s fields and overwriting or adding the listed fields. The update is non-destructive: the original record is unchanged (ownership preserved).

**An update keeps every field it does not write.** Its type is the written fields in front of a copy of the base past them: the copy is the base's row without the written names, a relation the two rows' free ends carry, so a field added to either row reaches the other, whichever is known first. A field the base holds under a written name stays with the base: the new record holds one field of that name, the written one, at the written value's type. Every other field of the base is kept, including those not known where the update is judged. So `fn with_b(r, b) = {...r, b}` hands back every field its caller passed in: over `{a: 1, b: 2, c: 3}` it overwrites `b`, over `{a: 4, c: 6, z: 1}` it adds one, and each record shape is built in its own copy of `with_b`, whose layout the emit reads under that copy (tests/micros/mn-record-update-keeps-the-row.mn, mn-record-update-shadows-the-field.mn, mn-record-update-in-a-stage.mn, mn-record-update-copies-the-base.mn). An update joins the record it copies, and a function threading a record through its own recursion by updates returns the shape it was handed: `if c { sc } else { {...sc, fb: 1} }` is one record, and so is `{...walk(sc, n - 1), fb: 1}` returned beside `sc` (mn-record-update-joins-its-base.mn, mn-record-update-through-recursion.mn).

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

Lists are bounds-checked at run time (an out-of-range index traps). Tuples are bounds-checked at compile time (H6 exhaustiveness).

**A sugar calls the language's primitive, even where the primitive's name is bound to something else at the sugar's location.** `xs[i]` calls the prelude's `list_index`, `++` calls the sequence concat `list_concat`, the joins in an interpolation call `str_concat`, and a rest pattern cuts with `slice`. The node that holds the sugar is linked to the primitive it calls, in the same way a call is linked to its callee. So `refs of slice` lists a rest pattern next to the calls that name the primitive, the lowering calls the declaration the link reaches, and the sugar charges the row that the primitive's declaration states. A parameter named `list_index` therefore never replaces the row that indexing charges (`tests/micros/mn-sugar-callee-is-the-vocabulary.mn`). A call of a parameter that has a primitive's name calls the parameter. A substrate primitive's face (what its declaration publishes) belongs to that declaration and is read by following a reference's edge to it. In `fn apply(len) = len(5)` the call's edge leads to the parameter, so the call is judged against the callback that the caller passes (`tests/micros/mn-param-named-like-a-primitive.mn`).

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

Each variant is a constructor with zero or more fields. The type's
parameters are the lowercase identifiers in field positions. Case alone
declares them: an uppercase name is a nominal type and a lowercase name is
a parameter. Every constructor of a type quantifies all of the type's
parameters (`None : Option(a)` too). A type is applied with parentheses,
the same application syntax used at every level: values `f(x)`, effects
`Sample(44100)`, types `Option(Int)` / `Tree(a)`.

**When a function field's type names no row, the field uses one row for the
whole declaration.** A field such as `Holds(() -> Int)` has one row for the
whole type, held in a cell of the declaration that no scheme quantifies.
Every construction writes into that cell the row of the function it stores,
and every match reads the row back. So a function taken out of the field
performs whatever any function put into it performs, and
`fn bad() with !E = match make() { Holds(f) => f(), Empty => 0 }` is rejected
where `make` stores a closure that performs E. A field that must carry a
different row at each use declares it with a type parameter (`Holds(a)`)
(tests/crown/leak-field-row-unwritten.mn).

### Constructor calls (value construction)

```
let some_value = Some(42)
let nothing = None
let tree = Branch(Leaf, 1, Branch(Leaf, 2, Leaf))
```

Constructor calls use the same syntax as function calls. Inference distinguishes them by looking up the name in env. A `ConstructorScheme` lowers to `LMakeVariant` with the constructor's tag_id; a `FnScheme` (a declared fn) lowers to a direct call of its symbol; a `ValueScheme` (a let, pattern or state binding) lowers to a call through the closure the value holds.

### Pattern matching

```
match opt {
  Some(v) => v,
  None    => 0,
}
```

Commas separate the arms. A trailing comma is allowed.

`match` is only for reading sums: a value of a sum type is taken apart by a match and nowhere else. It is not one of the flow operators. Two ways of writing it replace a form that should be used instead: a one-arm `match` over a product is a `let` pattern written as a match, and a `match` over `Some`/`None` handles a missing value by hand where a stage or a handler would handle it once. The census counts each shape (`mentl query <entry> "census match"`, `match-destructure`, `match-option`), and the count in the wheel may only go down (PLAN §11, a refusal is a hole).

### Exhaustiveness

In a match of two or more arms, every value the scrutinee can take must
reach an arm. (A match of one arm asserts its shape instead; see below.)
When some value reaches no arm:

Diagnostic: **`E_PatternInexhaustive`** at the `match` keyword, naming as a
pattern the value that escapes:
> "match misses `None` — write its arm"

Quick Fix: insert the arm that the witness (the escaping value) names. The
quick fix never proposes a wildcard, because a `_` arm over a sum is itself
rejected (below).

**The check reads the whole pattern, column by column.** The arms form a
matrix of pattern rows. A column of constructors is complete when the arms
name every variant of the type and each variant's payload columns are
covered in turn. A column with a wildcard or a binder covers the rest. So a
match that names every `Stmt` variant except one inside `NStmt(…)` is
rejected with `match misses `NStmt(HandlerChainStmt(_, _))``, where the
witness is the first missing variant in declaration order. A tuple column is
one constructor of its width. **The check is strict for every kind of
pattern.** A list column is a sum of two cases, `[]` or a head before a
rest, so `[]` beside
`[h, ...t]` is complete and `[x]` beside `[]` misses `[_, ...]`. A record
column is the union of the fields its patterns name, and a pattern that does
not name a field has `_` there. Bool's two literals count as its two
constructors. Any other literal column is covered only by a row with a
wildcard in that column, since no set of literals covers every word or every
text: `0` beside `1` misses `_`, and `Some(false)` beside `None` misses
`Some(True)` (tests/micros/mn-literal-payload-inexhaustive.mn,
mn-list-length-inexhaustive.mn, mn-int-literal-inexhaustive.mn). An arm
covers what its top pattern covers: an alternation covers what each branch
covers, and an as-pattern `name @ pat` covers what `pat` covers
(`whole @ Leaf(_)` covers `Leaf`). This error stops compilation: a match
that misses a variant never compiles into a program that traps when that
variant arrives.

**A catch-all arm over a sum stands for a roster, the list of constructors
that its author did not write.** A `_` or a bare binder after other arms of a
match over a sum matches every constructor those arms leave, and a
constructor declared later also falls into it silently. The exhaustiveness
check then passes, while the information about which constructors the arm
covers is lost. So the compiler rejects this shape with
**`E_CatchAllOverSum`** at the arm, and the error names, as a pattern, the
roster the arm stands for. `mentl tighten` writes that roster in the arm's
place: the alternation of the constructors that reach the arm, each with its
payloads written as `_`, under the arm's binder when it had one. After `Dot => 1`,
the arm `other => "many"` over `type Shape = Dot | Line(Int) | Box(Int, Int) |
Blob` becomes `other @ (Line(_) | Box(_, _) | Blob) => "many"`, and `_ => 4`
after `Dot` and `Line(_)` becomes `Box(_, _) | Blob => 4`. The comment the
arm carried stays above it (tests/frontier/tighten-demo/wild.mn,
tests/micros/mn-catch-all-over-sum-refuses.mn). The roster is written at the
arm's own pattern node, so the arm keeps its body and its comments. It costs
nothing at run time: the last arm of a match of several arms runs without a
test, as the `_` arm did, since the judgment rejects every match that a
value can escape. A constructor declared later is then
`E_PatternInexhaustive` at every match over its type, so its author decides
the case at each of those places. Three shapes are not a roster and stay
legal: a `_` inside a payload, which ignores a part the arm does not read; a
`_` over a word, a text or a list, whose remaining values no roster could
name; and a match's only arm, which is a binding
(`{ x => body }`, `match v { x => … }`), never a dispatch.

**A match of several arms dispatches; a match of one arm asserts.** `let [a,
b] = xs`, `let Some(v) = o`, a one-arm literal (`{ [h, ...t] => h }`) and
`match v { p => e }` all build the same graph, a match of one arm. A
parameter written as a pattern (`fn h([p, q]) = p - q`) makes the same claim
about its argument. Each of these asserts the value's shape, where several
arms would dispatch on it. So a case that the pattern leaves out is not
rejected: the shape is a claim, decided along the value's edges in the same
way as an index's precondition
(§«Partiality — a primitive's precondition is a claim»). The claim is proven
where every value the scrutinee can be has the shape, as in
`let [a, b] = [3, 4]` and `let Some(v) =
Some(a)` — and costs nothing; refuted where one is built otherwise — `let
Some(v) = None` is `E_RefinementRejected` at the let. Otherwise the claim is
open, and the match's own row carries the `Trap` that a mismatch raises. So
under `with !Trap`, a destructure of a parameter is rejected until its shape
is proven or its value is matched by arms of its own. A run that reaches a
mismatch stops with a message that gives the pattern's own address and the
constructor that arrived: `trap: a
pattern's claim failed at shape:9:3 — Dot arrived`
(tests/micros/mn-trap-claim-says.mn, mn-trap-claim-fielded.mn). The arms of
a match of several arms remain the list of the cases it handles. The rule
depends on the patterns, never on how they are spelled: the binder form
`([h, ...t]) => h` and the arm list that `mentl fmt` writes for it assert one
shape with one meaning (tests/micros/mn-destructure-claim-proven.mn,
mn-destructure-claim-open.mn, mn-destructure-claim-refuted.mn).

### Type aliases

A `type` declaration has three forms, told apart by the shape of the right-hand side:

**Transparent alias**: `type X = Y` (no `where`, and the right-hand side is a type expression, not a record literal).

```
type Port = Int
type Frequency = Float
type Bytes = [Int]
```

Creates `TAlias("X", Y)`. The alias and the underlying type unify transparently: `Port` and `Int` are interchangeable for type checking. The name is kept in Reason chains and in Mentl's voice.

**Refined alias**: `type X = Y where pred`.

```
type ValidPort = Int where self >= 1024 && self <= 65535
type Sample = Float where -1.0 <= self && self <= 1.0
```

Creates `TRefined(TAlias("X", Y), pred)`. The alias names the type, and the refinement narrows it with a predicate. Verify discharges the predicate at construction sites.

**Representation-pinned alias**: `type X = Y repr <width>` (optionally with `where pred`).

```
type Cents     = Int repr i64 where self >= 0
type Coeff     = Float repr f64
type LaneGain  = Float repr f32
type Pixels    = Int repr v128            // four packed lanes
```

The parser accepts the written `repr <width>` suffix (`parse_repr_pin` after
any type-declaration base), and the bare-width parameter pin (`s: f64`,
`s: f32`, `i64`, `v128`) creates the same `TReprPin` in type-atom position.
The pin is transparent to typing: the type's identity is the base type's,
and `repr_of`'s own arm is the only reader of the width. Both spellings parse
to the same pin, so the formatter picks the spelling by position: a pin on a
type declaration's right-hand side is printed with its suffix
(`type Coeff = Float repr f64`), and a pin in an annotation is printed bare
(`s: f64`). The i64/f32/v128 pins have full vocabulary support; generating
code for them is part of the named wide-producer residue (the RF64 path is
fully live).

`repr <width>` is an input to the gradient: a pin, not a constructor. It is
the counterpart of `own`/`ref` at the level of representation, and it is the
surface form of primitive #7. The gradient infers a value's representation
from its type and its use. `Word` is the i32 floor, and
`i64`/`f64`/`f32`/`v128` are widths the gradient reaches on its own: a `0.5`
literal is a native unboxed f64 with no annotation. `repr` pins a width only
when asking for a specific width is a control decision: wider precision
(`i64` so that money never loses a cent, which the refinement then proves)
or a hardware lane (`f32`/`v128` for a bandwidth-bound DSP stage). It is
never a default the developer must type. The pin is a field of the alias
node, read at lowering (`repr_of(lookup_ty(h))` → `RI32 | RI64 |
RF64 | RF32 | RV128`, an ADT — `repr_width` is 4/8/16 by match, never `==4`), so
`type Coeff = Float repr f64` makes every `Coeff` field a full-precision `f64.*`
slot. The record pointer stays a word, because a handle is a word, so the pin
does not change handle-uniformity or memcpy-serializability.

`mentl where` shows the chosen width as a derived badge, `s : Float @ f32
(pinned)` when authored, `c : Float @ f64 (inferred)` when the gradient
reached it. The badge is output only and cannot be written in source. Every
parameter and local has a badge. A function's badge gives its head, then the
address where it is declared, then the widths of its parameters and its
return. The head is written as SYNTAX writes one: its parameters' types, its
inferred row, and each parameter's ownership grade before its name
(`inv(own n: Int) -> Int with Trap  at main:11`). A value whose type is still
a variable reads `a : a @ per instantiation`, since every instantiation is
specialized and gets its own width.
Every surface that shows a type (`where`, `doc`, `query … type of`, the
caret, the View, hover, and every diagnostic) prints it through one
projection, the formatter's. The printer names each free variable as a
developer would write it: a type variable by the name it was declared with,
or else the first free letter; a row variable as `e`, `e1`, … from an
alphabet the type variables never use, so `spawn(f: () -> a with e)` shows
which is which. A unit result is printed with no arrow, a parameter that no
author named shows only its type, and naming writes nothing into the graph:
the head of every module-level function comes back unchanged through
`parse∘render`, counted by `mentl query
<entry> heads`. A pin that names the width the gradient would infer anyway
is redundant and should be dropped, and so is a pin equal to the floor on an
integral type. **The same `repr` pin is also a parameter annotation**, the
counterpart of `own`/`ref` under §"The Intent Boundary Rule":
`fn gain(s: f32, k: f32) = s * k` pins with the bare-width form (`f32` ≡
`Float repr f32` at the parameter level). The gradient infers the
representation of every unpinned parameter from its use.

**Nominal record**: `type X = {f1: T1, f2: T2, ...}`.

```
type Person = {name: String, age: Int}
type Customer = {name: String, age: Int}    // distinct from Person despite same shape
```

Creates `TName("X", [], TRecord([...]))`. The record's name is part of its identity, so `Person` and `Customer` do not unify even though their fields are identical.

**For nominal distinction over a primitive**, wrap the primitive in a single-field record:

```
type Port = {value: Int}
type Customer = {value: String}
```

No `newtype` keyword is needed, because the record's name makes the type distinct. The field is read with `.value`.

### Refinement types

```
type Sample = Float where -1.0 <= self && self <= 1.0
type NonEmpty = [a] where len(self) > 0
type Even = Int where self % 2 == 0
```

`self` refers to the value being refined. The refinement is a `Predicate` discharged by the `Verify` effect at construction sites and elsewhere as needed.

**A predicate is an ordinary expression, judged where its type is declared.**
`self` is the value being refined, at the base type, and the expression must
be a `Bool`. The functions it calls are ordinary references (`refs of even`
finds `type Even = Int where even(self)`), and `mentl fmt` writes the
predicate back as its author wrote it. What `Verify` decides is a projection
of that expression, which the type carries
(tests/micros/mn-predicate-as-written.mn, mn-refs-of-predicate-callee.mn).

**A predicate may perform an effect, and the claim is then decided under the
install that answers it.** In
`type Hz48 = Float where 0.0 < self && self < nyquist()`, where `nyquist`
reads the installed `Sample(48000)`, the bound depends on the installed clock.
The predicate's row is carried with the claim and judged where the claim is
made, under the installs in effect there. The medium decides such a claim
only where the perform's answer is visible to it. Today it leaves the claim
pending, as an open obligation that the board counts
(examples/pulse/course/06-rate.mn). The proof engine's reading of an
install's answer inside a predicate is §11's verification whole.

**Bounds are joined with `&&`. There is no comparison chaining.** A chained
`-1.0 <= self <= 1.0` parses left-associatively as `(-1.0 <= self) <= 1.0`,
because there is one precedence table and no special case. The result is
`Bool <= Float`, which is ill-sorted, and principle 2 already rules it out as
a second spelling of the conjunction, so the declaration is rejected with
`E_TypeMismatch`, `Bool vs Float` at the outer `<=`
(tests/micros/mn-predicate-chain-refuses.mn).

```
let s: Sample = 0.5      // Verify discharges -1.0 <= 0.5 && 0.5 <= 1.0 statically
let p: ValidPort = 8080  // statically discharged
let bad: Sample = 1.5    // E_RefinementRejected — 1.5 violates the Sample bounds
```

**A claim over a join is decided as the AND of the claim over each
tail.** `fn note_hz(k: Int)
-> Hz = match k { 0 => 220.0, 1 => 261.63, _ => 440.0 }` discharges because
every arm folds to a constant inside the bound. With one arm at `30000.0`,
the claim is rejected. An arm that is not a constant (`_ => f * 2.0`) leaves
the claim open as `V_Pending`. `if`, `match` and a block's final expression
are read by their structure, never by guessing which arm runs, so a dead arm
that returns an out-of-bound constant is rejected too: the claim covers
every tail.

**A refinement that crosses a function-typed argument is judged.** Where the
callee passes the argument's result to a refined position, the result is
judged on the lambda's own body. With `fn run(f) = alpha(f())` and
`alpha(c: Hz)`, `run(()
=> 30000.0)` refuses and `run(() => 440.0)` discharges. Where the argument
requires a refinement of its own parameters, the requirement is discharged
when the callee's own type states that it passes a refined value
(`fn drive(f, c: Hz) = f(c)`), and is left open as `V_Pending` otherwise. The
values a callee passes are made inside the callee, and judging them there is
the work of refinement variables (`Hβ.verify.higher-order-refinement`).

**A refinement is a fact that a value carries, read along the edges the value
flowed through. It is never a property of the value's type.** A value is what
its sources are. A constant is a single point. A reference reads its binder: a
parameter's refinement, a `let`'s annotation, or a constructor field's
declared contract. A join takes every tail. A part that a pattern took apart
is the argument at that position where the whole value was built. A call of a
declaration whose body is visible is what that body computes at the call's
arguments, under the postcondition the callee states. Each tail is a value
the call may take: together the tails can prove a claim, and no single tail
refutes one. When the reading reaches a body it has already entered, down
another branch or through another call, that body is read as what its
declaration publishes, so a reading costs the declarations it reaches. A
generic call is read by its signature: a result at a quantified variable is
one of the values passed in at that variable. A perform is what the op's
providers resume with, each a value it may take, and an install that pins
the op's effect answers only for the instance it serves
(tests/micros/mn-call-reads-the-callee.mn,
mn-perform-reads-the-providers.mn, mn-generic-result-by-signature.mn). A
computation inherits nothing: `fn dec(x: Positive) -> Positive = x - 1`
leaves `0 < x - 1` open as `V_Pending`, and `let d = if c { n } else { 0 }`
is the join of `n` and `0`, never `n`'s refinement. If a refinement were
attached to the unification class, it would be carried onto every join and
every operator's result, and `ratio(t, n: Positive)` would require Positive
of `t`.

**A parameter's refinement is a precondition, and what it guards moves to the
caller.** Inside the body the precondition is assumed, and every call must
satisfy it as a claim at the argument. A row fact that the body proves by
using the precondition is guarded by the precondition:
`fn inv(n: Positive) with !Trap = 100 / n` is accepted, and `Trap` is guarded
by the claim on `n`. A caller is charged with that row fact exactly when its
own claim is open: `inv(5)` leaves nothing to prove, `inv(m + 1)` charges
`Trap` to its caller, and a caller that passes its own `p: Positive` passes
the guard on to its own callers. A parameter with no annotation that is
passed straight into a refined position takes on that precondition
(`fn wrap(x) = inv(x)` requires `Positive` of its callers). A function with
no written return type publishes the contract that every return tail
carries, and a call to itself is read as returning what the other tails
return.

**A `let` annotation is a claim that its value must satisfy.** The claim is
decided where the value is made; it is never a fact laid over the value. So
`let k: Positive = e - 1` leaves `0 < e -
1` open, and `100 / k` charges `Trap`. A reader of `k` may rely on the
annotation for another claim, because the open claim is recorded once, at
the let. It may never rely on the annotation for a row fact.

**A structured contract is claimed part by part where the structure is
built, just as it is assumed part by part where it is taken apart.** Under `r:
{den: Positive}` a field read or a pattern assumes `r.den` is `Positive`, and
the same holds under `r: R` with `type R = {den: Positive}`, where the
nominal record's field contract is read by following its name to the
declaration (tests/micros/mn-nominal-field-contract.mn). So every
construction passed to that position must satisfy the contract for the part
it builds: `den_inv({den: 0})` is rejected at the `0`. A list literal must
satisfy `[Positive]`'s contract for every element, and a tuple must satisfy
each position's contract. A nominal contract applies to its constructors'
fields, read at the type's arguments: `Option(Positive)` requires
`Positive` of `Some`'s field and nothing of `None`, and `Result(Positive,
String)` nothing of `Err`'s. A part of a value built in code that the
analysis cannot inspect is read from the value. The part holds where every
source states it at that part (a parameter's precondition, a declared
return, a let's claim). Otherwise its contract is an open claim, and the row
its precondition guards is charged where the claim is open. An index read is
a part read (`100 / xs[0]` under `xs: [Positive]` is total), and `let xs:
[Positive] = [0]` is rejected where it is written.

**The parts of a memory are what its writers put there.** A list is written
in place (`list_set`), so an element read from it is either a value the list
was built with or any value that a store into its memory placed there. Each
stored value is one the part may hold: what holds of every such value proves
the claim, and no single one refutes it, since another write may have
replaced it. The writers are read in the frame where the memory is read (the
declaration or handler that holds the read, and every function and literal
inside it), and through each callee the memory is passed to, by what the
callee's own code stores into the parameter. Some memory is not visible to
the analysis: memory that the frame passes to a place where its later writes
cannot be tracked (into another value, a resume, a state's update, or a
function value whose row can carry `Mutate`); memory older than the frame,
where the frame calls code that writes older memory; and every memory in a
frame that holds a write the walk cannot place. A parameter's precondition
and a state's writes hold where they are made, but a store the frame makes
after them may replace the values they guaranteed. A handler's arms run in
any order, so its memory is read once every arm is judged, and a claim that
is open before then is checked again when the judgment settles
(tests/micros/mn-memory-written-*.mn).

**A function's contract travels with the function.** The compiler infers a
precondition for a lambda's parameter as it does for a declared function's
parameter: `(c) => alpha(c)` requires `Hz` of every value it is called with.
Every application must satisfy that precondition: a call through the value,
a function crossing, and a pipe stage. A pipe stage applies its function, so
it claims of the piped value what a call's argument would have to satisfy
(`30000.0 |> alpha` is rejected as `alpha(30000.0)` is). For a function-typed
parameter, the compiler infers the contract from how the body applies it. It
records the values that every application passes at each position
(`fn drive(f, c: Hz) = f(c)` passes its function `c`'s values, which are
`Hz`, and `fn feed(f) = f(440.0)` passes it `440.0`), and what a refined
position requires of the result (`fn run(f) = alpha(f())` publishes
`f: () -> Hz`). So where a caller passes a function in, the crossing judges
that function: a lambda's body against the required result, and the
lambda's own requirements against the values the callee passes it. A stage
completed in place (`x |> rig.f(5)`, a `<|` branch) is one application with
the whole product. So for a record of filters passed to a frame, the
compiler infers each cutoff that the frame passes to the filter it pipes
through, and a parameter that a recursive call passes back to itself adds
nothing to what is inferred (tests/micros/mn-refine-stage-through-field.mn).
A `<~` cycle binds its lambda's parameter with no application that could
raise a claim, so nothing is inferred for that parameter, and a requirement
inside the body remains an open claim of the body.

**A function value is judged as every function it can be.** This covers a
join of two functions, a list or a record of them, a function that a pattern
took apart, and a function that a generic call returns. Applying the value
must satisfy the precondition of every function it can be, conjoined per
position, and is charged the row each one guards: `pick(false)(0)` over
`fn pick(c) = if c { inv2 } else { inv }` must satisfy `inv`'s `Positive`
whichever branch comes first. The values a body passes to a function never
become that function's own requirements. A function passed to
`fn outer(g) = drive(g,
440.0) + g(30000.0)` is judged against both values it will be passed, not
against `drive`'s `Hz` as a requirement of its own. A function that moves
through a generic callee is judged by the callee's signature alone, by
parametricity, and the callee's body is never read:
`fold(0, (acc, f) => acc + f(0), [inv])` passes the list's `inv` to the
callback, which applies it at 0, so the call is rejected. A nominal type's
arguments carry their values the same way, so `opt_apply({ g => g(0)
}, Some(inv))` refuses through `Option(a)`. Nothing is assumed about values
that the analysis cannot trace from the body. A function parameter that the
body returns, passes to another function its caller chose, or places where
the contract is a type variable is judged as being passed values that
nothing there can name.

**A function's contract is never lost at a position.** A declaration or a
lambda that returns functions publishes, at every position of its return
that holds a function, the meet of every function the position can hold:
`fn pick(c) =
if c { {f: succ} } else { {f: inv} }` makes `pick(c).f` demand `Positive`
whichever branch runs. This holds through a tuple, an `Option`, a list, a
relay, a module value and a parameter alike. Every function placed at a
position whose type is stated crosses that position, and is charged there
with the guard of each requirement the position does not provide. Such
positions are an authored return (`fn mk() -> (Int)
-> Int = inv`), a nominal record's declared field (`Ops{f: inv}` under `{f:
(Int) -> Int}`), an op's declared return at `resume` (`resume(inv)` into
`get_fn() -> (Int) -> Int`), and the functions inside a function's result
where it crosses into a parameter that applies them.

**The value of a tee (a handler install) is every value its install can
answer with.** The value walk reads a `~>` node as the tails of the body plus
the tails of each arm of the installed handler. An arm whose tail is the
`resume` passes the remainder's answer through and adds no value of its own.
So `100 / (({ let _ = ask(); 5 }) ~> zero)`, with `zero`'s arm answering
`0`, is refuted (`E_RefinementRejected`), and with the arm answering `5` it
is proven under `!Trap` and runs. A label is read through the same answers,
so an arm that answers with an untrusted value carries the label through the
install (`tests/micros/mn-flow-tee-arm.mn`,
`mn-refine-install-answer.mn`, `mn-refine-install-answer-proven.mn`).

**An op's declared parameter is a precondition: its arms assume it, and its
performers must satisfy it.** Every perform claims the parameter's refinement
of its argument, and an arm may rely on that refinement for its argument, as
a function body relies on its parameter's: under `put(v: Positive)`, a
division by `v` inside an arm is proven. What the precondition guards is
charged where the arm runs, at the install, because a handler's arms may be
judged after its performers, whose rows are already published by then.

**An op's declared return is a contract that every resume must satisfy.** A
performer relies on the value its op is declared to return, so a refinement
there is claimed of the value each arm resumes with. Under
`get() -> Positive`, `get() =>
resume(0)` refuses where it resumes, and `inv(get())` has nothing left to
prove. A resumed value that the medium cannot prove leaves one open claim,
at the resume, and is never assumed at every performer
(`tests/micros/mn-op-return-is-a-contract.mn`).

**A label is an op named in a refinement over `self`, and what can attach the
label to a value is read along the value's edges** (`PLAN.md §4⑥`). Under `effect
Trust { untrusted(v: String) -> Bool }`, `type Untrusted = String where
untrusted(self)` states the label and `type Trusted = String where
!untrusted(self)` states its absence. Presence is never claimed. The label
enters at a position declared to hold it: a function's declared return, a
parameter, a field, a let's annotation, or what an op is declared to be
passed. Absence is a claim: `exec(cmd: Trusted)` requires it of every
argument, and a value that the label can reach is rejected there
(`E_RefinementRejected`). The error names where the label entered (`untrusted
enters at main:20:30 through what read_cmd is declared to answer`). What can
reach a value is everything the value is computed from (an operand, a
splice, a field placed in a record, a value stored in place into memory it
reads, an arm's answer, a state's writes), and everything that decides
whether the code that computes it runs (a branch's condition, a call made
under one, a statement before it that can abandon). A function passed to
another function is applied to what that function passes it, read at the
install that runs it, so a stage passed to `each` over an untrusted list
reaches the sink with an untrusted element. A parameter is what every call
passes it. Endorsement is a declared return that states the absence
(`fn quote(s) -> Trusted`); callers read it, and it is never claimed of the
body. A secret follows the same rule over another op (`type Secret =
String where secret(self)`, `log_line(msg: Public)`). Each declared
function's reading is a summary over its own parameters, read once per
settle and repeated until it reaches its least fixed point, so recursion
terminates. `mentl query
<file> "flow of NAME"` shows what a function returns, endorses and requires
(`tests/micros/mn-flow-*.mn`; each fixture's second line states its
contract at the sink).

The predicate is a compile-time obligation. At gradient-top it is erased entirely and there is no runtime check; the only check a program runs is a partial primitive's, where its instruction would trap anyway (§«Partiality»). `Verify`'s default ledger collects what it cannot discharge statically (`V_Pending`). Verify's own solver discharges more of it as the fragment of logic it decides grows (`PLAN.md §11`, Verify's own solver: overflow-aware intervals, linear arithmetic, case splits by fork), so the same source gets deeper proofs without being changed. An external solver can plug in only as a proposer whose certificate the kernel checks.

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

Each operation declares its parameters and, if the return is not unit, its return type. **Resume cardinality is inferred from each arm body when the handler is declared**, and is never declared on the effect op. The infer pass counts resume call sites and their control-flow ancestors. The inferred cardinality is attached to the op's `TCont` continuation type and decides which tier the lowering selects (Tier 1 direct call or Tier 3 heap continuation).

**An op's parameters are a parameter product, named as a function's parameters are**: `print(msg: String)`, `fail(msg: String) -> a`, `effect Sample(rate: Int)`. They are named because the field's name is the key (§«Labeled call arguments»): a perform may use labels, an arm binds by name, and every projection reads the name. The positional spelling (`fs_write_file(String, String)`, a bare type per parameter) still parses, and nearly every op in the medium's own source is written that way, with its names given only in the arms that bind them or in a comment above the op. The naming sweep closes that gap: the medium proposes each name from what its providers' arms bind, and asks the developer where they disagree. Once no op is left unnamed, the bare form is rejected.

The graph type is `TCont(R, S, ResumeDiscipline, World)`: `R` is the value
accepted by `resume`, `S` is the answer produced by the captured remainder,
and `World` is the exact capability world frozen with that remainder. `R` and
`S` are independent. A handler may resume a `Float` operation into a remainder
whose answer is `Int`; neither representation may stand in for the other.

### Invoking effect operations

An effect op is invoked as a **bare call**, with the same syntax as any
function call:

```
fn expect_true(value) = check(value, "expected true")   // check is the Test effect's op
```

The env binding shows that the name is an op (`EffectOpScheme`), and the
op's `TFun` row carries `Closed[eff]` by definition from its declaration.
The enclosing fn's `with` clause is verified against the row inferred from
these call sites. A reader who needs to know where a computation can
suspend reads the row in the signature or in the cursor's projection. The
medium shows that information directly, where a keyword would only hint at
it.

**`perform` is not a keyword.** The word lexes as an ordinary identifier, so
a `perform check(...)` written out of habit from another language parses as
ordinary expressions, and the general unresolved-name diagnostic shows the
bare call in context. There is no special-case recognizer for it and no
format-lift class. `resume` stays a keyword: it is bound to the context of
handler arms, typed by the typed-resume law (`resume : R ->
S`), and names the continuation, a value the call site cannot reach in any
other way.

**A perform costs what a call costs.** An op's arguments cross at the widths
proven at the site, and its result comes back at the width proven at the
site, exactly as a closure call's do: a Float op costs a Float call. The arm
that answers is the one twinned at the install's instance, which is the
site's own instance, so no cell is built at an effect's type variable:
`fn walk(xs:
[Float]) with !Alloc = { put(xs[0]); put(xs[1]) }` under `handler total with
s = 0.0 { put(v) => resume() with s = s + v }` runs and allocates nothing. So
a perform under `!Alloc` is accepted exactly when the op's own row is
accepted. A held or multi-shot op's row includes `Memory + Alloc`, because
such a perform builds the reified remainder (§«Resume discipline»).

**A wide value crosses a continuation in a register, never in a cell.** The
caller of a continuation, and the driver that runs a multi-shot arm, do not
have the types they call through, because one word-arity face serves every
chain. So a Float resumed into a continuation, or answered by a multi-shot
arm, crosses in a per-instance register next to the word slot. The register
is set immediately before the call and read immediately after it, which is
the machine ABI's own shape: words in the integer slots, a double in a float
register. A multi-shot op's arguments cross in the yield's record at their
widths. Nothing is boxed and no row changes: the same two-resumption program
at Int and at Float grows the heap by the same number of bytes
(`tests/micros/mn-multishot-float-answer-no-box.mn`).

### Unit return omission

An effect op that returns unit `()` declares no return:

```
effect Console { print(msg: String) }       // returns ()
```

`-> ()` builds the same graph as leaving it out, so it is a redundant form (Governing principle 2) that the formatter lifts out: `mentl fmt` writes an op's head without it (`render_effect_ops`). A function's written `-> ()`, which the printer still writes back today, will be lifted out the same way by the formatter landing. No projection should print it either: `mentl where` still prints `-> ()` on a unit op, and the single head renderer that every surface reads through will end that. A non-unit return must be written, because an op has no body to infer it from: `read() -> String`.

**Never-returning ops** declare `-> !`, the never type. Such an op never
returns to its performer, so its arm never resumes. Examples are
`abort() -> !` (the control cut that the Abandon discipline reads),
`fail(String) -> !`, and WASI's `proc_exit(Int) -> !` (the host ends the
process). `!` is quantified per perform, never at the effect: each perform
gets a result variable of its own. So one function may perform `fail` where
a list is expected and where an Int is expected, and an effect whose only
non-ground op returns `!` has no type parameter, so `Fail` and `WASI` appear
as bare names in every row. This is sound because the arm never resumes: an
arm that resumes a `-> !` op is rejected with `E_ResumeOfNever`. An arm that
ends in a never op answers any install, which is what allows `fail_exit` to
be installed over a body of any type
(§«Handler declarations»; `tests/micros/mn-resume-of-never-refuses.mn`,
`mn-never-two-result-types.mn`). A bare variable result (`ask() -> a`) is the
effect's own parameter: the install fixes it, and the arm resumes with a
value of that type.

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

Under the rule that a parameter list is a product (§"Labeled call arguments"), a zero-argument call unifies with a unit parameter type. `resume()` and `resume(())` are grammatically equivalent, and `resume()` is the canonical form by §"No redundant form."

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

The effect name itself takes arguments. **Row algebra treats `Sample(44100)` and `Sample(48000)` as distinct effects**, and a body that performs both carries both, in either order: `fast() + slow()` under `!Sample(44100)` is rejected exactly as `slow() + fast()` is. An instance's argument is a value that the judgment carries at the type level. Each perform's argument is a variable bound by a literal argument (§«The perform grounds its instance»), by a declaration's row, or by the install that answers it. So `fn stage() = sample_rate()` runs at the rate of whatever declaration or install surrounds it, specialized per rate as every instantiation is (tests/micros/mn-instance-declared-reaches-its-clock.mn). All of a declaration's free instances of one effect are the same instance, so a function runs at one rate. Two instances are two row members unless they are the same value, and under a negation every member that cannot be proven distinct is rejected. So an instance whose argument nothing grounds (an operand node) is rejected under a negation of any instance it might equal (`tests/crown/leak-instance-order.mn`). A type argument is not a value instance: an effect's type variables are shared across its ops, so one handler serves one instantiation and the install unifies the performs. A generic op quantified per perform is the landing `Hβ.effects.two-instances-of-one-effect-do-not-join`.

### Installation in `with` clauses

```
fn audio_loop() with Sample(44100) + IO + !Alloc =
  ...
```

The argument is evaluated at install time and then fixed. Two functions declared with `Sample(44100)` and `Sample(48000)` cannot work together without an explicit handler bridge, and an install is the only form that bridge takes: **an install serves the instance its handler's config names.** A handler's config parameter that has the same name as one of the effect's parameters is that parameter at the install. This is the perform's own grounding rule (§«The perform grounds its instance») applied to the handler. So lib/dsp's `handler sample_at(rate)` serves `Sample(rate)`, and `~> sample_at(48000)` serves only `Sample(48000)`. A handler whose config names no effect parameter serves every instance. A handler whose config is computed where the install stands serves the instance that the computing operand names. A stage that names no rate runs at the rate of the clock around it, and a stage declared at a rate that the operand is not proven to equal goes past the install. So `r() with Rt(5)` under `~> rt_at(seven(3)) ~> rt_at(5)` reads 5, never the 7 that the inner clock computes (tests/micros/mn-instance-computed-clock-passes.mn, tests/crown/leak-root-instance-computed-install.mn). One rule decides three cases, so the row describes what the program does when it runs:

- **A perform reaches the innermost install that serves its instance.** Nested clocks are two separate clocks: under `~> sample_at(48000) ~> sample_at(750)`, an audio stage declared `with Sample(48000)` reads the inner one, and a control stage declared `with Sample(750)` goes past it and reads the outer one. This holds for an op that resumes and for one that never does (tests/micros/mn-instance-routes-multirate.mn, mn-instance-routes-abandon.mn).
- **An install subtracts only the instance it serves.** `fn play() with !Sample(44100) = rate44() ~> sample_at(48000)` is rejected, because the 44.1 kHz stage's instance goes past the 48 kHz clock (tests/crown/leak-instance-passes-install.mn). The same rejection applies to an install over a callback whose row is open where the install is judged (leak-root-instance-foreign-callback.mn).
- **An instance that no install serves reaches the root.** A 44.1 kHz stage under only the 48 kHz clock is `E_EffectUnhandled`, and the error names the chain and proposes `~> sample_at(44100)` (tests/micros/mn-install-serves-its-instance.mn).

`mentl where` shows which instance each handler and install serves: `handler sample_at absorbs Sample(rate), answers a` at the declaration, and `~> sample_at absorbs Sample(48000), answers Int` at each install in a function's badges. A computed config is shown as the name it is computed from (`Sample(r)`).

### Resume discipline — inferred, not annotated

Resume cardinality is inferred from each handler arm body when the handler is declared; the developer never types `@resume=`. The infer pass walks the arm body and collects its resume call sites. These are the arm's own sites and those of the functions the arm declares, read where the arm calls them or passes them on, since a `resume` can stand only inside an arm and a function the arm declares is in scope nowhere else (tests/micros/mn-resume-summary-is-the-arms.mn). The pass then classifies the arm by control-flow ancestry and by whether branches are disjoint:

- **`OneShot`** is inferred when there is zero or one resume site not under a loop ancestor (or several sites, all on branch-disjoint paths), and the one use is in the arm's result position: on every path, the arm's value is the resume itself, through `if`/`match`/block tails and through a tail call into a helper that resumes at its own tail. The continuation lives on the stack, with no heap capture, and performance equals a direct call. No compile error can fire here, because the inference produces the correct kind from the body's structure.
- **The held single resume** is inferred when the one resume site is interior (bound by `let`, or used as an operand, an argument, an element or a lambda body), so the arm keeps computing after the remainder returns: `ask() => { let r = resume(1); r * 2 }`. The remainder is reified as the continuation record and called once. The code after `resume` runs when the remainder returns, and the arm's value is what the install answers (`ask() + 1` under that arm is 4; `tests/micros/mn-oneshot-nontail-resume.mn`). The grade is `ResumeUse` (types.mn): multiplicity × position, which is ownership's return-transfer distinction applied to the continuation. The record is the real cost of holding a continuation. Freeing it after its one call, in O(1), is the landing `Hβ.lower.held-resume-record-is-not-reclaimed`. A held resume runs the remainder inside the frame that calls it (the arm, or a callee to which the arm passes a lambda that resumes), so that frame's row includes the remainder's row. The resume performs its continuation's world, which is the handler's remainder, and every install judges what the frames it runs through forbid against its own body minus what it absorbs. Under an install whose body performs `Log` after the perform, `apply(() => resume(1))` is rejected against `fn apply(f) with !Log = f() + 0` (`tests/crown/leak-resume-remainder.mn`). When that remainder performs one of the handler's own ops again, the resume runs the handler again where it stands, which gives deep-handler semantics at any depth (`tests/micros/mn-held-resume-*-reyield.mn`).
- **`MultiShot`** is inferred when one or more resume sites are under loop or recursion ancestry, or when two sites are both reachable from one path. The continuation is captured to the heap as a closure. This enables backtracking, non-determinism and generators. **A MultiShot op's row carries `Memory + Alloc`**: the perform site reifies the remainder as a heap record, so performing the op is an allocation, and a `!Alloc` declaration around such a perform is rejected (`tests/micros/mn-multishot-perform-alloc.mn`). The op's discipline and cost are settled at pre-registration, from the parse structure, so they never depend on whether the handler comes before its performers in source order.
- **`Abandon`** is inferred when the arm never resumes (zero resume sites, whatever the op's declared return). The arm's value is the install's value and the continuation is dead: the perform unwinds, and nothing after it runs, in its own frame or in any frame between it and the install whose arm answers. The unwind is structured and is never a bare return past a bracket. A frame leaves through its innermost landing point, of which there are three. The first is an install body's block: the install's driver runs (its own op dispatches the arm, and a foreign op bubbles outward), and its world restore follows. The second is an arena body's block: the arena exits as any extent does, the perform's arguments move out of the region through their leaves (their slots in the argument area were journaled where they were stored), and the rest is reclaimed. Only a live continuation suspends an arena. The third is the function's own return. Every boundary that a raised flag can cross is followed by a check of the flag: a call whose callee's row may abandon, a direct arm call of a handler whose arms may abandon, an install or an arena that is not in the frame's tail position, and a fanout's spawn and join. An abandoning perform allocates nothing, because its arguments cross in a per-instance area allocated once at start, so `with !Alloc` holds over it (`tests/micros/mn-abandon-alloc.mn`).

**A continuation is captured at any position.** A held or multi-shot perform suspends the computation around it wherever it stands: a `let`'s value, after a statement, an argument, a right operand, a branch, an element, a field, an arm's body, or a `<~` body. Each frame (a function's body, a lambda's, an arm's, an install's or an arena's) is read once for the places where a yield may leave it, and at each such place the frame's remainder is created as a function. That function is the frame's own lowered tree zipped at that place: what ran before the place is dropped, only the branch the place stands in is kept, and the place's value becomes the hole the remainder takes. Each value from before the place that the remainder reads is captured into its record, next to the world the perform ran in and the `<~` lines the frame ticks. Those lines stay the frame's own: a remainder reads the prior value its cycle loaded and ticks the function's line, never a line of its own. A call, an install or an arena whose row may carry a live continuation is such a place too. When the callee yields, the frame composes its remainder onto the continuation that the callee's perform began, so each resumption returns through the call and finishes the frame. Under a handler that resumes `choose()` with 1 and then 2, `{ let x = inner(); x + 1 }` over `fn inner() = choose() * 10` answers `(10 + 1) + (20 + 1)`. A part of the frame that ran before the perform and is read after it is held in a register, so a resumption reads it and never runs it again: in `seven() * 5 + pick() + total()`, `seven()` is counted once however many times `pick` resumes. An abandoning op, whose arm never resumes, creates no remainder: it performs from any position and unwinds (§«Resume discipline»). A live continuation that reaches a thread's join traps there, since no joiner can hold it (§`><`). The fifteen positions are tested by `tests/micros/mn-capture-*.mn`.

**A resumed remainder runs under the world it is resumed in.** A continuation carries its own segment of the world it was captured in: every install between the perform and the install that caught it, including that install. Beyond that segment it reaches the installs that stand where it is resumed, and that is what the rows judge. So an install that an arm wraps around its resume governs the remainder (`ask() => resume(0) ~> inner_get` answers the remainder's `get` from `inner_get`). A continuation that the arm returns (`ask() => Paused({ x => resume(x) })`) and that the program resumes later reaches the installs around that later call. Each install's remainder (what its body performs beyond the effects the install handles) is held as an instance of its handler's world cell, so a negation over a resume is checked against it wherever the program states the negation: `fn sneaky(k) with !Get = k(1)` is rejected for a `k` whose remainder performs Get, and a `k` resumed at the top of `main` with nothing answering its Get is `E_EffectUnhandled` at the root. An arm runs outside its install on every path, so its own perform reaches the handler outside, and this includes a held or multi-shot arm: the install's driver passes the body's pending perform to the arm once, and a yield the arm raises bubbles past the install. The value that a resume passes over is computed in the arm's world, before the remainder's world is entered. A resume that enters its continuation from a world other than the one its install caught it in copies the segment onto that world, so a held resume charges `Memory + Alloc` in addition to its continuation's world. (tests/micros/mn-resume-world-*.mn, mn-arm-own-perform-*.mn, tests/crown/*resume-escaped*.mn.)

Both type checking and lowering depend on the cardinality. It is why Mentl can express real-time DSP and constraint-search backtracking under one effect algebra, and why a persisted multi-shot continuation is `memcpy`-serializable while a one-shot continuation is a stack frame. Writing it as an annotation, however, would be drift: authoring `@resume=` would declare what the body already proves. The body is the contract. A fact that this much depends on must be visible ("systems explain themselves", `PLAN.md §0`), so the cursor shows it read-only: `mentl where` shows the op's `TCont` as `R ->1 S` (one-shot) or `R ->* S` (multi-shot), a derived badge and never an authored annotation.

### Negation in `with` clauses

```
fn pure_op(x: Int) -> Int with !Alloc + !IO =
  ...
```

`!E` proves that effect E is absent. This is stronger than not mentioning E, because it propagates transitively through the call graph: any callee that performs E makes the whole declaration fail with `E_EffectMismatch`.

**The error names where E enters.** Every charge is recorded on a node of the construct that makes it, so the Reason the error carries is the walk from the declaration to the perform. In tests/frontier/mn-effect-enters.mn, `fn quiet(x) with !WASI = helper(x)` reaches the host three calls down, and the Reason reads: ``quiet uses WASI: quiet calls `helper` at tests/frontier/mn-effect-enters:20:26 → helper calls `log_it` at tests/frontier/mn-effect-enters:16:3 → log_it calls `print_string` at tests/frontier/mn-effect-enters:13:18 → print_string calls `fd_write_bytes` at io:208:3 → fd_write_bytes calls `fd_write` at io:186:3 → `fd_write` is an operation of WASI, declared at io:45:1``. The refusal puts the clause first: ``quiet is declared `with !WASI`, which does not allow WASI, and`` then the same chain. Each hop is a site in its own module's coordinates. A call or a stage names its callee, a tee names its handler, a function value passed to a callee is entered, a construct that charges by itself is named (`building the list`), and the walk stops at a value in scope. The message carries the chain of the first rejected effect. The same chain is the caret's Why at the declaration, one per effect of its row, and the output of `mentl why <file> <fn> <Effect>`; `mentl why <file> <fn>` prints the declaration's reason and then every effect's chain. An effect that an install absorbs enters through the install, at the arm whose perform resolves outside it, and never through the body it absorbs from. Under `fn quiet() with !Log = work() ~> relog`, where `relog` answers `log` by performing `log` again, the chain names `relog`'s arm, not `work`'s `log` (tests/frontier/mn-effect-enters-absorbed.mn).

**The negation also covers the declaration's own parameters.** A negation on
a function that calls a callback is a gate on that callback's row:
`fn run(f) with !E =
f()` refuses `run(() => op())` at the call, and the refusal names `run`'s
declaration. This holds under polymorphism, through a `~>` mask
(`fn run(f) with !E +
!F = (f()) ~> h` with `h` absorbing E gates `f` with `!F` alone), across
forward references, recursion with a signature and stored callbacks, and
per instance (`!Sample(44100)` accepts a callback that performs
`Sample(48000)`). A callback that is only returned, never called, performs
nothing in the declaring body and stays admissible. An authored negation on
a function-typed parameter is the same gate: `f: () -> Int with !E`
constrains `f`'s row at every call of `f`, and a sibling parameter's row is
judged on its own.

Used alone (for example `with !Mutate`), a negation creates a **negative capability stance**, meaning "anything except this effect" (universe-minus). This is how Mentl expresses region freezes and borrows (`ref`) in the row algebra, without a separate borrow checker.

**`Mutate` is a store into memory older than the frame that makes the store**: a parameter's memory, a capture, a module value, a part of another value, or the feedback line that a function's record owns. So `!Mutate` proves that a function leaves every memory that existed before it ran as it found it, and `fn poke(ref xs) with !Mutate = list_set(xs, 0, 5)` is rejected. A store into memory the frame allocated builds a value and performs nothing. A store into a parameter's memory performs `Mutate` in the function that makes it, and a caller is charged with it only where the argument it passes is older than its own frame. With `fn fill(buf, v) = list_set(buf, 0, v)`, `fn make() with !Mutate = make_list(1) |> fill(??, 4)` holds, and a caller that passes `fill` its own parameter passes the write on to its own callers. An install is charged for its arms the same way: a state that its init built belongs to the install, and a write the arms make to a config is charged by the age of what the install passes them. A `<~` tick writes its line, which every call shares, so `fn step(x) with !Mutate = ({ prev => prev + x }) <~ delay(1)` is rejected. The members of a cycle record what they write when the cycle's judgment ends, and are read again until no claim grows. A function value carries its claim as it carries its contract (a lambda's claim and a nested fn's claim are written where their judgment ends), so a call through it is charged `Mutate` only where the memory it reaches is older than the caller's frame. A parameter it writes is judged by the argument passed, a capture it writes by the binder's age in the frame that holds the value, its own feedback line by the value's age (a closure's line lives in its record), and the functions it applies by what the callee passes them, including a fold's accumulator where the stage passes it back. So `fn run() with !Mutate = { let c = counter(); c(1) }` holds over a counter whose tick is charged by the closure's own row, and `fn k(buf) with !Mutate = { let g = { x => list_set(buf, 0, x) }; g(7) }` is rejected, because the capture is `k`'s parameter (tests/micros/mn-mutate-negation-refuses.mn, mn-mutate-tick-refuses.mn, mn-mutate-fresh-is-construction.mn, mn-mutate-closure-line-is-the-value.mn, mn-mutate-capture-fresh.mn, mn-mutate-capture-param-refuses.mn, mn-mutate-through-callback-param.mn).

**Modal effects need no new mechanism (`PLAN.md §4③`, a pointer to later work).** The modal effect synthesis (unifying rows and capabilities, which closes the higher-order leak) passes effects as *lexical capabilities* through the existing `~>` binding: `~> h` lexically scopes the effect that `h` absorbs, and that scoping is the capability mechanism. So the modal form adds only a typing rule (a row variable becomes a lexical capability handle at `~>`) and no new surface form: rows give `!E`, `~>` gives the lexical capability, and the modal form unifies the two on forms that already exist. It is sequenced after REAL (§5).

`Pure` is shorthand for "the body's row must be the empty row" (no present names and a closed tail, which is `EfRow([], [], EtClosed)` in the kernel's canonical triple):
```
fn pure_op(x) with Pure = x + 1
```

### The perform grounds its instance

An op parameter that has the same name as one of its effect's parameters is that parameter at the perform: the op's argument there is the instance's argument. So a literal argument grounds the instance where the operation is performed, and the row carries it:

```
effect Environ(name: String) {
  env(name: String) -> String
}

fn port() with !Environ("SECRET") = env("PORT") |> parse_int   // accepted: Environ("PORT") is provably not Environ("SECRET")
fn leak() with !Environ("SECRET") = env("SECRET")              // E_EffectMismatch
fn read(n) with !Environ("SECRET") = env(n)                    // E_EffectMismatch: a computed name grounds nothing, and an ungrounded instance is distinct from none
```

A computed argument leaves the instance ungrounded. The negation holds exactly when the reads it guards are literal.

### Configuration — the environment is an effect

The process environment is read through `lib/environ.mn`, where the variable's name is the instance:

```
import environ

fn main() = (env("PORT") |> parse_int |> serve) ~> env_from_host
```

- **`env(name)` is a required read**, and its name must be written at the read: a computed name is `E_EnvNameUngrounded`, because the program's demand on its host could not be stated before it runs. **`env_opt(name)`** is optional, accepts any name and returns `Option(String)` (`env_or(name, fallback)` is built on it). A literal optional name is a narrow demand. A computed optional name is reported as `* [all optional]`: its value cannot be selected before execution, so by design the host grants access to its whole environment.
- **The demand is a projection of the graph and is never written to a file.** `mentl query <entry> env` names each required and optional read beneath an install that crosses the host boundary (`env_from_host`), with its mode, site and declaration. Literal reads give an exact list. A computed optional read reports broad access explicitly. The projection is read at perform sites, because a row no longer contains `Environ` once the install absorbs it.
- **A missing required variable is caught before execution.** The compiler writes the list of required names into the module's start. Before any of the program runs, including its initializers, every missing required variable is named with its read site and the process exits with status 1 (`PORT is read at main:3:14 (in main) and is not set`). A missing optional variable returns `None`. The check is part of the module itself, so it holds under any preview1 host.
- **The host uses the list.** For literal names, `mentl run` takes each value from the shell, or else from the project's `.env` (`KEY=VALUE`, `#` comments), and passes only the requested names as `--env`. If the list contains a computed optional read, the shim passes the whole shell environment plus the `.env` values not already set in the shell. This is an explicit broad capability: it can expose credentials and toolchain variables to the guest.
- **Environment reads are guest data.** A value returned by `env` or `env_opt` is in guest memory and may enter a persisted image. `!Environ("API_KEY")` proves that the program does not perform that grounded read; it does not make values read under another name, supplied through another channel, or returned by another host service secret. Host-held opaque credentials need a host operation that applies the credential without returning it to the guest; that boundary remains open work.
- `env_fixed(pairs)` serves fixed variables for a fixture and does not query the host, so nothing read under it is demanded.

---

## Handler declarations

### Canonical form

```
handler name(cfg_p1: T1, cfg_p2: T2) with state_a = init_a, state_b = init_b {
  op_arm_1(args) => body,
  op_arm_2(args) => body,
}
```

A handler has three parts:
1. **Config parameters** in `(...)`, captured by the closure at the install site.
2. **State** after `with`: internal state that changes across arms. The same slot, read by position, may instead hold the handler's own effect row (`handler h with !F { … }`; see §«Negation guards on handlers»). A `!`, or a name not followed by `=`, opens a row; a name followed by `=` opens the state inits.
3. **Op arms** in `{...}`: one arm per effect operation, covering every operation of every effect the arms answer (§«A handler is exhaustive» below).

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

A state init may read the handler's config (`handler window(size) with buf = make_list(size)`, `with n = cfg.x`), because each install builds its state from the config it was given, as a function of its own record, before the handler is installed. An init performs in the installer's world. An init that performs an effect only its own handler answers is `E_InitPerformsOwnOp` at the declaration, just as an install's argument that performs one is rejected at the install. Both run before the install exists, so nothing could answer the perform, and the error's chain names it.

### Handler chains — a composition is a value

```
handler judgment = affine_ledger ~> region_tracker ~> verify_ledger
handler judged_emit = emit_ctx ~> judgment

fn check(entry) = (judge(entry)) ~> judgment
```

`handler NAME = h1 ~> h2(cfg) ~> h3` names a composition of handlers. An
effect row is a first-class kernel value, so naming a row is what `type`
already does (§«Named effect rows»). By the same reasoning a handler
composition is a value, and naming one needs no new form: the `=` opens the
chain where the arms would open, and the chain is a `~>` tree whose leaves
are handler references, bare or applied to their config. A member may be
another chain, which stands for its members.

**Installing the name installs its members, innermost first, and the graph
holds exactly that.**
`body ~> judgment` is `body ~> affine_ledger ~> region_tracker ~>
verify_ledger` in every respect: the row (each member's absorption removed,
each member's arms added, each install's cost charged), the remainder gates,
the lowering and the Why walk. This is because the judgment writes those
installs into the graph at the install node, once. Each member is
instantiated at the reference as a copy of its subtree, as a row alias's
terms are copied where a signature reads them, so a config argument is
evaluated per install, and a handler's instance and answer belong to that
install. The installs are nested over the body, and the install's node is
registered again as the outermost of them. Every reader after the judgment
reads the graph and finds the installs that the author would have written
out. The formatter writes `~> judgment` back, since the install node is
bound with the reference its author wrote (`ChainInstall`), whose edge
reaches the chain, and `refs of judgment` counts the install.

A chain has no config of its own: `~> judgment(x)` is
`E_HandlerChainShape`. A member must be a handler or a chain. A value that is
neither, or a member whose argument declares anything (a function, a
handler, a type or an import, found by `member_declarations` walking the
argument), is rejected at the declaration with the same class, whether or not
anything installs the chain. This error stops compilation: no part of a
malformed chain compiles (tests/micros/mn-handler-chain-shape-refuses.mn).
The declaration installs nothing and is printed on one line, with its
members joined by ` ~> `.

### A handler is exhaustive

An effect declaration is a sum of requests, and a handler is the arm list
over it, so the exhaustiveness rule for matches (§«Exhaustiveness») applies
to a handler as it does to a `match`: **if the arms answer any op of an
effect, they must answer every op of it.** A handler with an arm for `inc`
and none for `get` is `E_HandlerInexhaustive` at the `handler` keyword, and
the error names the ops that no arm answers. This error stops compilation;
it is never only a note.

This rule is what makes the install's row exact. `expr ~> h` subtracts from
`expr`'s row, by name, the effects that `h`'s arms answer. A perform of an op
with no arm would go past the install at run time and reach whatever is
outside it, which the row does not include. A program of this shape is
rejected: `fn f() with !State = (get() + inc()) ~>
only_inc`, `only_inc` answering `inc` alone
(`tests/micros/mn-handler-partial-refuses.mn`).

A handler written to answer only some ops of an effect forwards the rest: an
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

`fn f() with !State` over that body is rejected (`E_EffectMismatch`: the
forwarded `get` escapes), which is exactly what the partial handler hid. The
other correct form declares the ops the handler answers as their own effect.
Koka and Effekt require the same. A split-effect pair, two handlers that
cover disjoint sets of one effect's ops, is written as two effects.

### An arm's value is the install's value — `Handler(instance, answer)`

A handler is typed by what it handles and by what it answers: `Handler(E,
A)`, the effect's instance and the answer. The answer is the cell that every
arm's body is judged into. It is quantified together with the instance when
the arms leave it free, and every install meets it with the body's own
answer. An arm that resumes answers the install with what the remainder
answered, so its value is the body's value. An arm that does not resume
answers the install itself, so its value must have the type of the body's
answer: `handler h { bail() => "not a number" }` installed over
`(bail() + 1) ~> h` is rejected at the install with `E_TypeMismatch`, `Int vs
[Byte] — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler
h`. That is the Reason attached to the unification, and it names the arm
whose value is its own. (A `resume` tail passes the remainder's answer
through, so a handler whose every arm resumes answers with its install's
body.) The caret's Why at the tee walks to that arm. `mentl where` shows what
a handler answers next to what it absorbs
(`handler zero absorbs Ask, answers Int`; `handler ticker
absorbs Tick, answers a`, with the variable shown under the name a developer
would write), and what each install in a function answers
(`~> ticker absorbs Tick, answers
Int at 12:28-12:46`). The arms are keyed by the answer as they are by the
instance, so an arm that uses its answer (`a ++ b` over two resumptions) runs
at the answer its install gives it, and a multi-shot handler that answers a
Float assembles (`tests/micros/mn-arm-answer-is-the-install.mn`,
`mn-arm-answer-observed.mn`, `mn-multishot-float-answer.mn`). A
never-returning op answers with a bare variable (`proc_exit(Int) -> !`), so
an arm that ends in one, such as `fail_exit`'s `proc_exit(1)`, answers any
install.

**The right side of `~>` must be a handler, and its type is checked.** The
install resolves its handler once, by following the edge its reference
draws, before the body it governs is judged. Whatever the right side is, its
type must meet `Handler(P, A)` there; a configured handler named without its
arguments meets it with its scheme's result. So `ask() + 1 ~> r.zero` over a
record whose `zero` is an Int is rejected with `E_TypeMismatch` at the
install (`tests/micros/mn-install-of-a-non-handler.mn`). A handler held by a
value (`let h = one`, then `~> h`) passes type checking, but its emitted code
names a global that nothing defines, so the module does not assemble: a
handler named as a value has no record yet
(`Hβ.effects.handler-value-is-its-record`).

### State updates via `with` on resume

To update state, an arm uses a `with` clause on `resume`:

```
inc() => resume() with n = n + 1
```

The `with` clause lists state updates by field name. Unlisted state stays unchanged. A name that is not one of the handler's state fields is rejected (`E_MissingVariable`, "state field: m"), because nothing would ever read what the write stores.

**A state is judged as every value written into it.** At any read in an arm, a state field holds its init or whatever some arm last wrote, so whatever the medium proves about the field must hold for all of those values. `100 / d` over `with d = 5` requires `d != 0` of every write. `with d = d - 5` in another arm leaves the division's claim open, so it is rejected under `!Trap`, and `with d = 0` in another arm refutes the claim where it stands (`E_RefinementRejected`: a write of the fatal value makes the claim fail, as a join's `0` tail does). A label that a write brings reaches every read of the state, and a function written into the state is applied as every function it can be. A state that no arm writes is its init at every read and proves what the init proves. A write that reads the state it writes (`with d = d + 1`) reads it there as unknown, so a counter's bound stays an open claim rather than being proven. Reading it as the claim's own hypothesis, an inductive invariant, is the named next step (`Hβ.verify.state-reads-its-invariant`).

### Installation

`~>` is the only operator that installs a handler. It draws the install edge
to the handler's node (`PLAN.md §2`):

```
body_expr ~> handler_name(cfg_args)
```

A sub-scope is a brace block, which is a first-class `BlockExpr`, and it is installed the same way:

```
{ let a = setup(); work(a) } ~> handler_name(cfg_args)
```

There is no `handle { body } with h` keyword spelling, and `handle` is not a
keyword. It is the medium's own domain noun (the graph's node pointer), and
making it a keyword collided with the most common identifier in the
codebase. Its removal follows the turbofish precedent
(§«Generic type parameters»): the language adds no special keyword for a
spelling borrowed from another language. A `handle { body } with h` written
out of habit parses as ordinary expressions, and the general
unexpected-token diagnostic shows `(body) ~> h` in context. So one operator
draws one kind of edge, and the word handle stays an ordinary identifier.

### Negation guards on handlers

```
handler affine_ledger with !Consume {
  consume(name, span) => ...,
}
```

`with !Consume` on the handler itself is the handler's own row. It is the same signed clause that a fn signature carries, verified the same way, and it applies at two levels (the arm-world rule). The arms may not perform `Consume` themselves (the registration-time gate). At every install, the remainder that the arms resume into, which is the tee body's row minus what this handler absorbs, may not perform it either, because resuming inside an arm continues that remainder under the handler. So `handler h with !F { op() => resume(1) }` installed over `op() + fop()` is rejected at the install, and the error names `h`. Installed over `op() + op()`, or over a body whose `fop()` an inner install absorbs, it holds. `handler h with !E` over the ops it handles has nothing to check, since the absorption removes them. The check is made per install: the body is read where it is known, and it is never joined across installs into the handler's single row.

(`tests/crown/leak-arm-resume-remainder.mn`.)

---

## Named effect rows (capabilities)

A named row is the surface form of kernel primitive #4 (the Boolean effect
row). An effect row is a first-class kernel value (`PLAN.md §2`), so naming a
row is what `type` already does, and there is no separate `capability`
keyword:

```
type File = Read + Write
type Network = Http + Dns
type ApiClient = File + Network
```

`type Name = <row-expr>` is a transparent alias (§Type aliases): `Name` expands
to its row at every site that takes a row, and `with File + Network` composes
structurally. Its terms are effect names, capitalized like every declared
effect. The right-hand side uses the full Boolean algebra `+ - & ! Pure`:

- `+` **union**: `type ApiClient = File + Network`
- `-` **difference**: `type ReadOnly = File - Write` (admits `Read`, rejects `Write` at the structural gate)
- `&` **intersection**: `type Shared = ServiceA & ServiceB` (the effects that both require, which is the natural typing of a `<|` divergent join); the identity `E - F = E & !F` holds (`inter_row`)
- `!` **negation**: `!Alloc` (universe-minus; a transitive proof of absence)

```
fn fetch(url) with ApiClient = {
  let body = http("GET", url)
  write(local_cache_path(url), body)
}
```

A row alias is stored as its written terms and expanded where a signature
reads it (`row_alias_triples`, src/effects.mn), so an alias that resolves to
`Pure` (everything subtracted out) is simply `Pure` there: it adds no
constraint and can be dropped. A cycle through an alias's own expansion is
rejected (`E_RowAliasCycle`), and so is a negated alias whose row is not
positive and closed (`E_RowAliasNegation`). A named row's terms are judged
where they are written, as a clause's terms are: each must name a declared
effect, another named row or a row variable, and an instance's arguments must
meet its effect's parameters, so a misspelled term is rejected at the `type`
(`E_MissingVariable`; tests/micros/mn-effect-name-in-row-alias.mn).

A named row joins two or more terms, or opens with `!`. A single name on its
own is the type it spells (`type Locked = Lock` a transparent alias,
`type Locked =
Lock(Held)` a type of one constructor), because a second name for one effect
is the redundant form. So `with !Locked` over such a declaration is rejected,
because the name is not an effect. A constructor that has the same name as an
effect shadows the effect in the single namespace a link has today, and every
row that names the effect is then rejected (a module's own scope will settle
this collision, `PLAN.md §11`).

### A SIGNATURE IS NOT AN INVENTORY — name the capability, author the negation

A measurement of the wheel makes this a rule rather than a preference. Among
the wheel's declared rows, 132 signatures name four effects and 155 name
five, and a tail of signatures names 13, 14, 16, 17 (four of them), 18 and
nineteen. A `with` clause of nineteen names breaks three of this document's
own rules at once:

1. **It is a re-derivation.** §«With-clauses for effects» says the declared row
   is *a CONSTRAINT verified against the row inferred from the body*, so every
   name is a hand copy of a fact that inference computed. Widening the row of
   one leaf function forces an edit to every signature above it. That breaks
   the Carried-Truth Law in the very syntax that exists to express it.
2. **It is not intent.** The Intent Boundary Rule reserves annotations for
   decisions: a refinement, an ownership marker, a representation pin.
   `with Memory + Alloc` on a body that obviously allocates only copies down
   a fact the compiler already has.
3. **It hides the negation.** `!E` is the most important part of a signature.
   In a row of nineteen names, the one negation worth reading is hard to find
   among the names the author typed.

**The fix needs no new syntax: the signature leaves the positive clause out.**
The positive row is inferred and projected. What a signature writes is a
decision (a negation, an instance pin, `Pure`), and the full positive row is
read at the address surface (`mentl <file:line>` renders
`-> T with Memory + Alloc`), the way `repr` width and resume cardinality
already are. So the normal signature is `with !Alloc + !Thread`, which is
shorter and is the part worth reading. Three mechanisms support it:

- **`T_RowInventory`** reports a clause whose bare positive names are all
  proven by the body's row, where that row is ground: a cell nothing charged,
  or a resolved row with no free terminal (`enforce_row_gate`, src/infer.mn).
  Over an open body row (a callback's row is carried in its tail) the bare
  names are a cap, and the cap is a gate (below). That is a decision rather
  than an inventory, so nothing is reported. `T_OverDeclared` covers the
  ground case where a declared name is beyond the proven row, and reads only
  the positive half: a signature with only negations is never
  "over-declared" (it used to report `!Mutate + Any` against a Pure body).
- **`mentl tighten`** writes each reported clause's residue (its negations
  and instance pins, or no clause at all) and never the proven row. The
  medium's own source was migrated this way: 1,490 clauses, after which the
  wheel judged clean through the inferred rows with zero `E_EffectMismatch`,
  so its negations had been true all along.
- **`mentl verify` bounds the shape** (`CsAuthoredPositiveRow`, `src/board.mn`)
  at zero on the wheel: a capability nobody writes needs no name.

**A positive row that remains is a cap, and the cap is a gate.**
`fn run(f) with E = f()` states that `run`'s body, callbacks included,
performs at most E. The argument edge for `run(() => op_f())` is rejected
with `E_EffectMismatch`, and the error names `run`'s declaration, exactly as
for a negation. A `~>` mask inside the body widens what reaches the gate (`Pg ∪
mask` on the push: `fn run2(f) with E = ((f()) ~> hf) + op_e()` accepts a
callback that performs F, because `hf` absorbs it before the gate). So a
positive row on a higher-order function is a decision the medium enforces.
Write one when the cap is meant, and otherwise let inference project the
row. The two micros that carried `with Abort` on a try/catch higher-order
function, whose thunks allocate and choose, were rejected once the gate was
enforced and lost their caps. A positive row cannot express what their
comment asked of it (`try_with_abort_catch`: a row "to
allow the outer scope's effects to flow").

There is no `capability` keyword: `capability X = <row>` would be structurally the same as `type X = <row>`. A row is a type-level value, so naming one is a type alias, and a second keyword for it would be the redundant form that Governing Principle 2 rejects. Nominal row identity would be record-style branding, but capabilities require structural composition, so the transparent alias is the right form.

---

## Pipeline + handler installation in code

### Installing a handler in code

```
let result = computation() ~> state_handler
```

A sub-scope is a brace block installed the same way, and config arguments go
on the handler:

```
let result = { let x = setup(); work(x) } ~> state_handler
let log    = { work() } ~> bounded_log("INFO")
```

(There is no keyword spelling for an install, because `handle` is not a
keyword (§«Installation»). Handler state and arms belong to the handler
*declaration*, never to the install site.)

### Multi-handler chain (capability stack)

```
source
  |> stages
  ~> mentl_default
  ~> affine_ledger
  ~> verify_ledger
  ~> diagnostics_handler   // outermost = least trusted = sandbox boundary
```

Read from top to bottom, the installs go from inner to outer in the trust hierarchy.

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
  {name: "Morgan", ..._} => "found Morgan",
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

List rest uses the same `...rest` syntax as record rest. `rest` is
optional in the AST: with no rest the match requires an exact length, while
`..._` accepts any remaining tail without binding it. `|` stays pattern
alternation and type-variant separation, and is never list-cons syntax. A
bound list rest is cut out as a slice of the elements past the prefix, so it
costs what `slice` costs, `Memory + Alloc`, in the frame where the match
stands, and it is rejected under `with !Alloc`
(`tests/micros/mn-list-rest-alloc.mn`).
It never costs the `Trap` that a slice's bounds can raise: the arm runs only
where the list holds the prefix, so the cut is in bounds by the pattern's
own test (`tests/micros/mn-rest-cut-is-in-bounds.mn`). `..._` cuts nothing.

**A sub-pattern is the cell of the part it takes apart, and a binder is
declared where it is written.** In `Pair(a, b) => a / b`, the `b` that the
arm reads reaches the `b` that the pattern binds, and the caret's Why there
names that line. The two elements of `[x, y]` are two values, a rest is a
node of its own (a binder, or `_` marking its presence), and `w @ pat` names
the value that its position takes apart. A destructuring pattern's shape
claim is located at the value it claims (tests/micros/mn-declared-*.mn).

**Every binder is declared where it is written.** The binder of a let and
the binder of a match arm are nodes of their pattern, each the cell of the
value it names, so the edge from `total` reaches the `total` that the
let binds, and `mentl
<file>:<line>:<col>` at a binder lists its uses, which are the sites the
page's find draws at the same caret (tests/micros/mn-declared-let-binder.mn,
mn-declared-arm-binder.mn). A parameter is declared the same way. It is a
node of its own, the cell of the argument its position takes, and it holds
its pattern, its annotation, its default and its ownership marker. Its
pattern binds against that cell as a let's pattern binds against its value.
So the caret at a parameter's name names the parameter and lists its uses,
and a destructured parameter is its pattern, with no name created for it
(tests/micros/mn-declared-fn-param.mn, mn-declared-lambda-param.mn). A
handler arm's arguments are parameters by the same rule, each the cell of
the op's argument at its position, so an arm takes a pair apart where its
body begins (`give((a, b)) => resume(a + b)`). A state field's name is the
binder of its init, and the name that a `resume … with` update writes is a
node linked to it. So the caret at a field lists its reads and the updates
that write it, and the Why at an update's name walks to `state n of counter`
(tests/micros/mn-declared-arm-arg.mn, mn-declared-state-field.mn,
mn-declared-state-write.mn, mn-arm-arg-pattern.mn).

**A head and a pattern bind each name once.** Two binders of one name,
whether across a head's parameters and inside their patterns or within one
pattern, leave a use that could reach either one, and a parameter list holds
one field per name, which a label names. So the second binder is rejected,
and the error names the first (`E_DuplicateBinder`). The branches of an
alternation are required to bind the same names, so they are not two
binders (tests/micros/mn-duplicate-binder-head.mn,
mn-duplicate-binder-pattern.mn).

**A rename is one write at the declaration.** Every reference prints the name
its edge reaches, a label prints the name of the parameter its slot fills,
and a backticked mention in a comment is an edge as well. So
`mentl rename <file>:<line>:<col> <name>` writes the new name where the
declaration holds it (a binder, a declaration's head, a constructor's entry
or an op's entry) and rewrites each mention along its edge. The program is
then judged again, with its rewritten files read from memory, and its edges
are compared with the edges it drew before. A rename that would move an
edge, or that would leave an error, writes nothing and reports why. An edge
moves when another declaration of the new name captures a use, when the
renamed declaration captures a use of the new name, or when a mention
resolves elsewhere. A name written inside a type is printed from the type's
value, so a rename that reaches one is rejected. A rename is also rejected
when the new name breaks the case rule or is a word of the language, and
when the declaration is outside the program's own layer. The battery states
each verdict as `// rename L:C to NEW: N name(s)` or `refuses <word>`
(tests/micros/mn-rename-*.mn).

### Exhaustiveness

Match arms must cover every value, and a wildcard may cover only what no roster of constructors could name (§«Exhaustiveness» above). A missing variant is named by the pattern that escapes.

### Pattern alternation — rule

`pat_1 | pat_2 | ... | pat_n => body`: the body runs if any branch matches. Variable bindings are allowed inside alternatives when:

1. **All branches bind the same set of names.** Wildcards and literals don't count as bindings.
2. **For each binding name, the types across branches unify.** In the body, the name has the unified type.
3. **The refinements are compatible.** When refinements differ across branches, the name carries their disjunction in the body, and Verify discharges each arm separately.

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

When branches bind different names, the error is `E_PatternAlternationBindingMismatch`, and it shows the conflict. When the same name has incompatible types, the same diagnostic shows the type conflict.

**An alternation can stand wherever a pattern can**: in an arm, a
constructor's payload (`W(Dot | Line(_))`), a record field
(`{kind: Dot | Box(_, _), n}`) or a list element
(`[Dot | Line(_), ...rest]`). So parentheses around a grouped alternation in
those positions are the redundant spelling, and `mentl fmt` writes
`W(Dot | Line(_))` for `W((Dot | Line(_)))`
(tests/micros/mn-payload-alternation.mn).

**Layout**: an alternation is printed inline when it fits. When it is wider
than the line, it is filled to the width, and each continuation line starts
with its `|`. The roster that a catch-all stood for is often forty names,
and it is read as a paragraph. The parser treats the newline before a `|` as
layout (tests/micros/mn-roster-filled.mn). Branches that each bind the whole
value under one name are printed as that binder over the group,
`b @ (C(_) | D)` (§«As-patterns — rule»).

### As-patterns — rule

`name @ pat` binds the whole value and destructures it in one arm; the binder
carries the scrutinee's own type, and the match predicate is the inner
pattern's alone.

`name @ pat => body`: binds `name` to the entire matched value, and `pat` destructures it further. `name` and any bindings inside `pat` are all available in the arm body. This is common where code needs the whole value and some of its pieces, as in event forwarding, logging and pass-through.

**The binder over a group**: `name @ (A | B)` binds the whole value under any
branch of the alternation it groups. This is the spelling that
`mentl tighten` writes for a binder that stood over a sum. A parenthesized
pattern is the pattern inside it, since there is no product of one: `(A | B)`
is the alternation, and `(a, b)` is the pair as before. One graph has one
spelling: `b @ C(_) | b @ D`, where every branch has the same binder, is the
graph that the formatter writes back as `b @ (C(_) |
D)`, filled past the width (tests/micros/mn-grouped-as-pattern.mn).

`@` is TAt (reserved for handler annotations more generally). Effect ops currently have no user-facing `@`-form that anything depends on, because `@resume=` was removed once resume cardinality was inferred from the arm body. Context will disambiguate if later kernel additions introduce other `@`-forms.

---

## Imports

### Canonical form

```
import path/to/module
```

The path is a slash-separated module name. **A module's layer is read off the
root that resolved it**: `User` (the program's own directory), `Lib` (the
runtime library, `lib/` of the repository or of the installed home) or
`Compiler` (`src/`). An importer searches only the roots its layer may reach.
A User module searches its own directory, then the library roots. A Lib
module searches the library roots alone, and a Compiler module searches every
root. So a program resolves imports against its own project and the runtime
library, and the compiler's roots are never offered to it: a user's
`import graph` names no module and is refused with `E_MissingModule`, which
lists the paths it searched. A file in the program's own folder belongs to
the program, whatever it contains. A project whose folder is this repository
reaches `src/graph` as its own file, under its own layer. The same rule means
a lib module cannot import the compiler, so no second diagnostic is needed
for that case.

Every report carries its layer, attached where the report is written. On the
file route (`check`, `run`, `compile <file>`), the register shows only the
narrations of the entry module's own layer, and the debt summary counts only
that layer's obligations. A developer sees their project and not the library
beneath it, and a maintainer checking `lib/io.mn` sees the library's. The
stdin route and the board read every layer.

A module's own imports are searched from where that module was found: a user
module's folder, or a library module's root. So `sub/b`'s `import c` is
`sub/c.mn` beside it, and the entry's `import sub/c` is the same file. The
import walk keys each module by the path its spelling resolved to. Two
spellings of one file are therefore one module and one edge, and one spelling
that resolves to two different files is two modules, such as a program's own
`lists.mn` and the library's (`tests/frontier/user-link/nest` holds both
cases). Each module is a node of the program's link, and an import is an edge
to the node it resolved to; the name is not matched again. A
repository-relative spelling (`lib/lists`) names a module only where the
program's own folder has the repository's layout; the library's own name for
that module is `lists`.

### Selective import

```
import path/to/module {name_a, name_b, name_c}
```

Only the listed names are brought into scope. Today the parser reads the path and stops (`ImportStmt` carries the path alone), so the selective set, and the collision refusal below that depends on it, are not built yet. They come with the next step, which makes each module a scope (`Hβ.driver.per-module-env-overlay`). Today a link is one namespace, so a program's `fn count` beside the library's is refused across the whole link (`E_DuplicateFnName`, tests/micros/mn-link-name-collision-refuses.mn).

### No rename / alias

There is no `import X as Y`. An alias would be a redundant second name for an edge the import already drew (the no-redundant-form rule). A name collision is resolved once, at the import edge, and is never re-derived at each call site: selective import narrows each side so that each name binds one edge.

```
import dsp/spectral {fft}
import lin/spectral {fft}    // E_ImportNameCollision — two edges into `fft`
```

The graph does not allow two edges into one name. The developer then narrows the selective sets, or, if both names are needed, binds each module's resolved env node once and reaches `.fft` through that single edge. A qualified name such as `dsp.spectral.fft` does not solve the collision: it resolves the import edge again by name at every call site, which is the standard example of re-derivation (`PLAN.md §2`). The formatter treats it as residue (a leftover form) and rewrites it, and it is never the recommended way to tell two names apart.

**One-separator law:** `/` appears only in import position, because a module path maps onto the file that holds the module. In expressions, `.` is the only access operator, for fields and qualified names alike. There is no third separator; `::` is not a token.

### Capabilities and versions at the import edge

```
import vendor/json with !Network + !Filesystem
```

**An import states what the imported module may never do.** The negation is the same one the row algebra uses. It is proven over everything the imported module exports, by the same walk that proves a declaration's `!E`. So a dependency whose exports reach the network is refused at the import with `E_EffectMismatch`, and the chain names the export and the call. A dependency is then trusted for exactly what its import edge says. The claim still holds after every upgrade, because it is checked again at every link.

**An import performs `resolve(path)`, and the handler installed over the link answers it.** Today two handlers answer it, the project's folder and the library; a content-addressed store or a registry is one more handler beside them. So a version is that handler's configuration, the lock is the set of hashes that the link's import edges resolved to, and there is no package manager apart from the medium. **Compatibility is computed, never declared**: every declaration publishes a face, which is its type, its row and its contract. An upgrade whose exported faces are unchanged, or only widen what callers may rely on, is accepted. An upgrade that breaks a caller's use is refused at that call. A package carries what the judgment decided about it, and the kernel checks its faces wherever it does not trust them.

Today the parser reads `import path` alone (`ImportStmt` carries the path), so the negation, the selective set and the resolve handler are not built yet. They come next (`PLAN.md` §11, a module is a scope).

---

## Comments

Comments are the syntax of primitive #8 (HM with Reasons): each comment is a
Reason edge.

There is one comment form, `//`, and every comment is graph content: the
medium never ignores prose. The lexer emits a comment token. The parser
attaches each comment to the node it precedes (the following declaration or,
when there is none, the enclosing block or the file's synthetic `Module`
handle) as a `CommentReason(text, span)` edge. The Why engine walks that
edge, and the explanations Mentl prints show the comment. "Lossless intent"
(`PLAN.md §0`) means a `// HACK: …` is intent the graph carries, never noise
the lexer drops.

```
// Single-pole IIR low-pass, sample-rate-parameterized. Real-time-safe.
//
// Use in audio callbacks where allocation would cause dropouts.
// References to `Sample` and `<~` are resolved by render handlers.
fn lowpass_filter(samples: [Sample]) -> [Sample] with !Alloc =
  ...
```

### What a comment IS

- **Pure prose, attached to the graph.** Contiguous `//` lines join into one String, and a blank `//` line is a paragraph break. The comment attaches to the declaration that immediately follows it (`fn`/`type`/`effect`/`handler`/`let`), or, when there is none, to the enclosing block or the file's `Module` handle. A comment at a declaration boundary is never dropped: a run of comments at the end of the file, with no declaration after it, attaches to a unit carrier that renders as that prose alone. An interior comment (inside a `{ }` body) attaches to the most specific node that follows it: the next statement, the final expression, or the block's own unit node when nothing follows. A trailing comment on the same line attaches backward to the node whose line it shares. Being on the same line is a structural fact: the comment token comes before any newline, which the parser detects with one token of lookahead. Interior and trailing comments are graph content in the same weave that the declaration comment fills, they are checked by the same backtick gate, and the address surface renders the first line of the attached prose as the `Lede:` facet. A match arm's pattern is a node, so a comment above an arm, or trailing its `=>`, attaches to the pattern, and `mentl fmt` writes it above the arm. **Attachment is by span, so an anonymous node can hold a comment like any other node.** A comment above a lambda inside an argument list attaches to the lambda: its `Lede:` appears at the lambda's address, and its backticked parameters resolve through the enclosing declaration's binders. A lambda's span is its whole extent, from head through body, so `mentl <file:line>` on the lambda's line reaches it. The address rule and the weave's rule answer the same question, and both read the same fact, the span. Comments inside other expressions (inside parentheses or match-arm headers) attach by the same span rule (`Hβ.parser.expr-interior-comment-attach` names what the gate has not measured there).
- **How much of a comment is shown is a projection.** The gradient reads the comment's relevance at the cursor (the same gradient that drives every projection) and selects the one-line lede or the full body. The author does not pick an audience with a `//`-vs-`///` split. The author writes prose, and the cursor determines what is shown. The first sentence is the lede.
- **Stored verbatim, rendered for each target.** The substrate stores the raw String, and render handlers decide how it is presented: HTML `<code>` for `` `backticks` ``, terminal ANSI, markdown fence. `` `backticks` `` cross-reference identifiers; the author writes the reference, the handler resolves it — **in the comment's own module's reach**: a declaration of its own module, of a module it imports or of the prelude, a binder of the commented node, a keyword or surface word, or a word a string literal of a module it reaches writes (the WAT and WASI vocabulary the emitter's literals write resolves in the emitter, and nowhere the emitter is not imported). A resolved reference is a mention edge to what it names — a binder's as much as a declaration's — so a rename rewrites the mention along it. A name the whole link carries but the module never imports is no edge the module can draw, so it does not resolve: `W_CommentRefUnresolved`. The author then points the reference at something that resolves, or writes the word as plain prose.
- **Code blocks compile through the same pipeline.** Mentl source inside a comment is Mentl source, and the compiler checks it. There is no separate doc-test category.

### What a comment TRENDS TO

The design deliberately pushes comments in one direction. **A comment that
states a mechanism shows that a projection is missing.** The medium carries
types, rows, ownership, refinements, resume cardinality, spans and Reasons,
and the voice (the explanations Mentl prints) projects them at every
position. A comment that restates a fact the medium can project is a hand
copy of the graph's truth in prose, where it can go out of date (the
Carried-Truth Law applied to prose). To test a comment, delete it. If that
loses information that no projection can supply, the finding is the missing
projection: name the peer, extend the verb, and the part of the comment that
carried information moves into the medium, in the same way that the bash
scaffolds are absorbed into verbs (`CLAUDE.md`). As the voice is completed,
what remains in `//` comments is the developer's own prose: intent, taste,
scratch notes, reminders and fun. That prose is the one input that genuinely
comes from outside the medium (`PLAN.md §0`: intent), and the medium carries
it without loss but never requires it. The wheel shows how much remains:
today ~38% of its lines carry prose, and nearly all of that prose describes
mechanism the voice cannot project yet. Each such line is `mentl why`
content waiting to be absorbed, not the end state
(`Hβ.voice.comment-mass-absorbs-into-projections`).

### What a comment is NOT

- **Not a markup language.** There are no `=== headers ===` decorations; the declaration's name is the heading. Render handlers add the presentation formatting.
- **Not JSDoc or Sphinx tags.** There is no `@param`/`@returns`/`@throws`/`@since`/`@deprecated`: the effect row and the refinement substrate already carry parameter, return and capability information. The positive-form discipline forbids lifecycle vocabulary ("previously", "no longer", "legacy", `@deprecated`): a comment describes what is, not what was.
- **Not a gate.** A comment adds information and never silences anything: a declaration with no comment still shows the tentacles Mentl derives from the substrate (the silence predicate).
- **Not a blessing.** Prose cannot make a compensation canonical. The comment on a residue names the condition for retiring it (the peer, or the count that must reach zero), never a claim that it is permanent. When the builder writes "deliberate" over a standing cost, the word hides the cost and states no fact.
- **Not the only source of explanation.** Mentl's substrate voice (one part per tentacle, derived from the graph) is the second source. Each declaration has these two and no third, editorial one.

**Dissolved:** the `//`-vs-`///` split. Under it, `//` meant "the medium deliberately does not read this": a category of prose that the medium ignored, although the medium is designed to explain the program and its explanations cannot be switched off. That contradicted `PLAN.md §0`. Now there is one form, all of it is graph content, and how much of it is shown is projected.

### No block comments

Mentl does not have `/* ... */` block comments. Because the substrate composes, there is no need to disable large regions of code; if code is unwanted, delete it. Version control keeps the history.

---

## Strings

Strings are the syntax of primitive #1 (the sequence node-kind).

A string is a sequence of bytes, `String = [Byte]` (`PLAN.md §4①`), and not a
separate primitive. There is one string form, `"..."`, and interpolation is
always active:

```
"hello"
"with newline\n"
"escaped quote: \""
"result is {a + b}"
"hello, {name}!"
```

**Interpolation is a graph edge, not substitution at run time.** A `{expr}`
splice carries the spliced node's type, effect row and labels up into the
enclosing string-construction expression. So `"{network_call()}"` adds the
call's effects to the row, and `exec("sh -c {cmd}")` over an untrusted `cmd`
is refused at the sink before the program runs (§«Refinement types»,
`tests/micros/mn-flow-splice.mn`). To render a splice, lowering dispatches
`to_string` structurally from the spliced node's inferred type. This follows
the precedent of `++` and `==`, where the proof decides the dispatch, so
there is no `Show` trait bound.

**Literal braces** are written `\{` and `\}`, which mark a region the splice
scanner skips. There is no brace doubling and no second delimiter.

**Escape codes:** `\n`, `\r`, `\t`, `\\`, `\"`, `\{`, `\}`, `\0`, `\xHH` (hex byte).

### Multi-line

`"""..."""` is the multi-line variant of the one string form, and
interpolation still works in it. Leading whitespace common to all lines is
stripped (the form is indentation-aware):

```
let block = """
  Hello, {name}.
  Your age is {age}.
"""
```

There is no `'...'` literal form, no `'''...'''` variant and no `{{`/`}}` brace doubling. A splice-free `"abc"` and `'abc'` would produce the same byte-sequence graph. Whether text is literal is a property of a region (`\{`), which the cursor reads; it is never a mode attached to the quote character. Because there is one sequence kind, there is one string syntax.

---

## Operator precedence

There is one canonical table, and a higher number binds tighter. The numbers
are the literal integers that `binop_prec` and `pipe_prec` return
(src/parser.mn). The parser binds by this one table, the formatter adds
parentheses by it, and this spec shows it. Structural forms (call `f(args)`,
field access `.`, indexing, unary `-`/`!`) bind tighter than every binary
operator. `=` in let and `=>` in lambda sit at statement level, and neither
is part of the binary-operator precedence levels.

| Prec | Operators                                | Associativity   | Notes                          |
|------|------------------------------------------|-----------------|--------------------------------|
| 10   | `*`, `/`, `%`                            | left            |                                |
| 9    | `+`, `-` (binary)                        | left            |                                |
| 8    | `++`                                     | left            | one `seq_concat` over the sequence kind; associativity does not matter under the concat-tree representation; see §"Concatenation operator" |
| 7    | `<`, `>`, `<=`, `>=`                     | left            | comparison                     |
| 6    | `==`, `!=`                               | left            | looser than comparison: `a < b == c < d` reads as `(a<b) == (c<d)` |
| 5    | `&&`                                     | left            | short-circuits: `a && b` ≡ `if a { b } else { false }`. The right operand is evaluated only when the left is true, so a guard protects the read after it (`pos < n && set[pos] == x` is sound) |
| 4    | `\|\|`                                   | left            | short-circuits: `a \|\| b` ≡ `if a { true } else { b }` |
| 3    | `\|>`                                    | left            | sequential pipe, looser than all value operators, so `a == b \|> f` pipes the comparison |
| 2    | `<\|`, `><`, `<~`                        | left            | convergent verbs, which build structure around chains |
| 1    | `~>`                                     | left (loosest)  | handler attach, the lowest level; it governs the whole chain to its left |

`~>` has the lowest precedence on purpose, so that the handler at the end
of a chain takes everything to its left as its body. That is the one rule
of `~>` (§tee). The parser does not reject meaningless chains within one
level, such as `a < b < c`. Inference rejects them with a typed Reason
chain (`TBool` against the operand type), which locates the error more
precisely than any associativity rule could.

### Concatenation operator

`++` is one total `seq_concat` over the sequence node-kind. It works the same
for every element type, over the unified `[len][bytes]`/view record
(`PLAN.md §4①`, §6). There is no dispatch between `String` and `List`,
because they are not separate: `String` is `[Byte]`, so `"ab" ++ "cd"` and
`[1, 2] ++ [3, 4]` are the same operation on different element types.

The graph carries the element type only to check that the operands' element
types unify (ordinary HM unification), and never to choose the operator. So
an operand whose element type is not resolved yet is an open `[?a]` that
still concatenates; an unresolved operand is not a failure. An element-type
mismatch (`[Int] ++ [Bool]`) is reported as an ordinary unification failure
with a Reason chain back to the `++` site: `E_TypeMismatch`, with its Reason
naming the `++` (`infer_binop`). It is a type error, not a side effect of
dispatch.

**Drift-refusal preserved:** `++` never invents a result for an operand that
cannot be typed. It reports the unification failure with a Located reason
(the no-silent-fallback law, `PLAN.md §9.2`). **Dissolved:** the
`list_concat`-vs-`str_concat` dispatch table and `E_ConcatTypeUnresolved`
(`(unreachable)` when lower could not pick a representation). Both existed
only to choose between two representations that the unified ontology does
not have. A representation gradient (packed bytes or boxed values) is
decided during lowering from the proven element type. It is invisible at the
surface and never appears as two surface operators.

### Equality operator

`==`/`!=` are one structural-equality derivation, directed by the operand's
element or field type (read from the graph at emit). There is no rule to
remember and no split by representation: `String` is the `[Byte]` instance
of the sequence case (what was `str_eq`):

| Operand shape                              | Structural-eq projection                          |
|--------------------------------------------|---------------------------------------------------|
| scalar (`Int`, `Bool`, byte, nullary tag, address) | `i32.eq` / `i32.ne`; value equality is structural |
| sequence (`[a]`, incl. `String = [Byte]`)  | length-then-element recursion (`[Byte]` case is byte-compare) |
| product (record / tuple)                   | field-wise recursion over the sorted field set    |
| sum (ADT)                                  | tag-equality then payload recursion               |

The ordering operators `<` `<=` `>` `>=` are the same derivation with a
3-way leaf. A word orders by its value (an address by its magnitude,
§«Addresses»). A sequence orders element by element, with a prefix before
every sequence that extends it (`[1] < [1, 2]` and `[1, 2, 3] < [2]`). A
product orders field by field. A sum orders first by the declaration order
of its variants and then by its payloads, so over `type
T = B(Int) | A`, `B(5) < A` holds.

**Inside the structural folds a Float is totally ordered.** `==`, compare and
hash over a sequence, a product or a sum's payload order a Float by the IEEE
total order, with every NaN one value above +∞. So `[nan] == [nan]` agrees
with `a == a`, `[-0.0] < [0.0]` holds and the two are not equal, and hash
agrees with `==`. `==` and `<` on a Float itself keep IEEE behavior for
arithmetic (tests/micros/mn-fold-float-total-order.mn). `sort` will place a
NaN once the derived compare is a node that a generic function can call
(`PLAN.md` §11, the keystone). A fold's recursion depth never grows with a
sequence's length. A sequence is walked in a loop, and a sum's last field of
its own type is the next round of that loop, so comparing two lists or two
chains costs one loop and not one call per element
(tests/micros/mn-fold-sequence-loops.mn, mn-fold-chain-loops.mn).

**A fold keeps its pending work in memory, never on the call stack.** Some
types recur through a field that the fold does not reach last: a tree's
first child, a rose tree's list of children, or two types that recur through
each other. For these, the work each level leaves (the fields not yet
compared, the elements not yet walked, the closers a rendering still has to
write) waits on the instance's own stack, which grows on the heap as deep as
the value nests. `==`, compare, hash and show complete over two trees nested
100,000 deep through their first field (tests/micros/mn-fold-deep-tree.mn,
mn-fold-deep-rose.mn, mn-fold-mutual-chain.mn). That memory is in the row. A
comparison or a hash over such a type charges `Memory + Alloc` where the type
is known. Over a type variable, the cell carries the charge as a demand,
which is paid in a row that each instantiation owns, unless the function
already pays `Memory + Alloc`, which is all a spill can cost. So
`fn same(a: Tree, b: Tree) with !Alloc = a == b` is refused, a generic
`fn eq2(a, b) = a == b` costs a caller something only where the caller names
such a type, and `hash` passed to a function declared `!Alloc` is refused at
the gate on that callback once its parameter is a tree
(tests/micros/mn-fold-spill-alloc-refuses.mn, mn-fold-calm-no-alloc.mn,
tests/crown/leak-fold-spill-through-lambda.mn). A type that recurs only
through its last field, such as a list or a chain, keeps nothing pending and
allocates nothing.

**Drift-refusal preserved:** `==` on a heap value never emits a pointer
comparison. Pointer equality used in place of structural equality gives
wrong answers; it is the silent fallback that `PLAN.md §9.2` removes. The
derivation is total over the five node-kinds through this one general
definition, with no special case per shape. `str_eq` is the byte-sequence
instance that the surface `==` lowers to, and it is never a primitive the
developer calls directly.

**That totality had two holes. Both are closed, and they are described here
because the lesson applies elsewhere.** (1) An operand whose type is still a
variable where the comparison is emitted has no structure to read, and the
one-word compare it would fall back to compares addresses, which is wrong
for anything but a word. It is refused with `E_ShapeUnprovable`, which is
armed and reported at the comparison before any byte of the module is
written. A show, a hash and a `++` of such an operand are refused the same
way. (2) A polymorphic sum compared its payload by address while the
monomorphic one compared by value, because the generated helper was keyed on
the nominal name alone. The sig folds its arguments so that each
instantiation names its own leaf, and the specs ground against them, so the
payload recursion calls its own type's helper
(`tests/frontier/mn-eq-polymorphic-sum.mn` holds the contract, with its
monomorphic control beside it). The lesson that applies elsewhere: (1)'s
census did not see (2), because the unprovable operand sat inside a
generated leaf and not at a comparison the author wrote. A census that
measures one surface does not see the same class of problem one layer
further in.

### Arithmetic operators

`+ - * / %` and unary `-` unify their operands and require one more thing of
them: that they are numbers. The requirement is a constraint on the
operand's type cell. It is the second arm of the gate mechanism, beside the
row gate (§«Negation in `with` clauses»), and the state of the operand's
cell determines the outcome:

| Operand's cell                                | Arithmetic's verdict                           |
|-----------------------------------------------|------------------------------------------------|
| bound to a word (`Int`, `Float`, `Byte`, an alias or refinement of one, a `repr` pin) | the instruction at the operand's repr: `i32.*` at the floor, `f64.*`/`f32.*`/`i64.*` where the gradient or a pin says so |
| still free at the operator                    | the cell carries the demand (a `NumericGate`). The one writer checks whatever later enters the cell: a word passes, a variable inherits the gate, and an aggregate is refused. Instantiation copies the demand onto the fresh variable, so a generic `a * b` given `{x: 1}` is refused at the call that instantiates it |
| bound to a product / sum / sequence / function / continuation / unit, or an address | `E_ArithOnAggregate` refuses it at the judgment. The value ontology gives arithmetic on an aggregate no meaning: the operands are addresses, and an address moves by `addr_at` (§«Addresses») |

**The demand belongs to the judgment, as a gate on the cell.** `{x: 1} * {x:
2}` refuses at the operator (`tests/frontier/mn-arith-on-aggregate.mn`);
`scale({x: 1}, {x: 2})` over `fn scale(a, b) = a * b` is refused at the
argument edge that binds the copied gate, and the message names `*`'s site
(`mn-arith-on-aggregate-twin.mn`). A copy made before the demand existed,
such as the self-reference inside a fn that has a signature, is reached
through the instance column (`mn-arith-on-aggregate-instance.mn`).
`mentl check` reports each of these cases. Nothing is decided at emit: a
word is emitted at its type's repr, and a variable still free there is the
quantified variable of a floor twin. Every wide instantiation, including one
through a reference
(`tests/micros/mn-arith-generic-ref-float.mn`), makes its own twin and binds
the variable under it, so the variable is a word at the floor width by
construction. An emit that read only the operands' widths multiplied two
record addresses and reported nothing. Arithmetic on a user type is neither
pointer arithmetic nor a trait. It comes from the rules of a numeric
projection (`Hβ.lower.ad-is-a-demanded-projection`), the same mechanism that
makes a chain differentiable.

### Addresses — the word that names memory

An address names a location in memory: the raw memory operations read from
and write to one (lib/memory.mn's `Memory`). Its type is `Addr`. On the
machine it is a word in every respect (one i32, equal by identity, hashed as
itself), but it is not a number. `alloc` and `heap_mark` return one,
`Cast`'s `addr` returns the address a value lives at, and every raw load and
store takes one:

| An address…                       | …is                                                         |
|-----------------------------------|-------------------------------------------------------------|
| compared `==` / `!=`              | identity: two allocations are two addresses                 |
| ordered `<` `<=` `>` `>=`         | by magnitude: wasm32's memory runs to 4 GB, so an address past 2 GB is above one below it, where the signed order of an Int would put it below |
| shown (`"{p}"`)                   | the unsigned number it names (`4294967280`, never `-16`)    |
| in arithmetic (`p + 8`, `8 + p`)  | refused with one `E_ArithOnAggregate` at the operator, whichever side it stands on; it moves by `addr_at(p, 8)` and is measured by `addr_diff(q, p)` |
| read and written                  | `load_addr` / `store_addr`; a byte, a word or a float at it through the raw loads and stores |
| at a word slot                    | `addr_word` / `word_addr`, the identity on the machine, where a value crosses the runtime's word protocol |

An arena's exit reads this type (§`~>`, lib/arena.mn). When the exit finds
an address in the arena's region where it looks (the arena's value, a field,
an element, or a slot that `store_addr` wrote into older memory), it keeps
the region, since nothing can tell what the address refers to. Held as an
Int, the address was copied as a number and the cell was reclaimed under it,
with no error. A number made from an address (a pun through `addr_word`, or
a distance added to one) remains the program's own claim, since a number
refers to nothing an exit could read.

A raw copy carries bits, and bits carry no type, so the exit never reads a
copy as an address. A `mem_copy` that writes memory older than an open arena
keeps that arena's region, whatever the bytes were. A store that states what
kind of value it stores is how a program lets an arena keep reclaiming past
it: a float stored into a packed list moves nothing on its account, and
neither does a byte, a word or a float stored through the raw stores.

---

### Partiality — a primitive's precondition is a claim, and an open claim is a row fact

Integer `/` and `%` are partial: the substrate traps on a zero divisor, and
`/` also traps on `INT_MIN / -1`, the one quotient a signed word cannot hold
(`%` returns 0 there). The medium never makes them total, because returning
an invented 0 for a division by zero is the silent fallback that `CLAUDE.md`
forbids, and it never lets a trap go unreported either. Each site raises
its precondition as a claim. `Verify`'s fragment decides the claim from what the
graph holds about the two operands, with three outcomes:

| The claim at `a / b` | Outcome |
|---|---|
| a constant divisor that is not 0 (and, for `/`, not -1, unless the dividend is a constant that is not INT_MIN) | PROVEN: the site charges nothing |
| a constant zero divisor (`1 / 0`), or `INT_MIN / -1` by constants | REFUSED: `E_RefinementRejected` at the site, because the program's meaning is a trap |
| a divisor one of whose sources is the fatal point: a join's tail (`100 / (if c { 5 } else { 0 })`), or an installed arm's answer (`100 / ((…) ~> zero)` with `zero` answering `0`) | REFUSED: the text writes the trap on that tail, in the same way that a claim over a join is refused at the tail that folds false |
| a divisor whose every source excludes the fatal point: a constant, a length, or a parameter whose refinement excludes it (`Positive` (`0 < self`) excludes 0 and -1; `NonZero` (`self != 0`) excludes 0, so it proves `%` outright and proves `/` only beside a dividend that cannot be INT_MIN) | PROVEN. Where the proof rests on a parameter's refinement, the `Trap` waits in that parameter's guard, and a caller whose argument claim is open pays it |
| a module value bound to a constant (`let lanes = 4`) | PROVEN: the fragment reads the let's own node |
| anything else: a parameter nothing bounds, a local, a call | OPEN: the site charges `Trap` into the row |

`Trap` is the effect the substrate performs when a partial primitive's
precondition fails (`effect Trap { trap() -> ! }`, lib/memory.mn). Its one
op, `trap()`, is the deliberate stop. It never returns, as its type
declares, so it can stand where a value of any type is expected, such as the
complement arm of a match over a word that the representation bounds.
Nothing handles this effect; it is named so that its absence can be proven.
A run that reaches it stops and prints why at the perform's own address
(`trap: a precondition failed at lists:234:37`). Every stop that the emit
writes reports its kind before the machine stops (`memory
is exhausted`, a pattern's claim, the compiler's own invariant), and the
board limits the instruction to the three places where it follows such a
reported stop (tests/micros/mn-oob-traps.mn, mn-trap-exhausted-says.mn).

An integer `/` or `%`, or a `float_to_int`, whose claim the fragment left
open is checked where the instruction would trap. The check stops the run
the same way and names the face that failed: `trap: a precondition failed at
tests/micros/mn-div-open-says:8:13 — the divisor is 0`, `the quotient does
not fit the word`, `the operand is not a number`, `the operand is outside the
word` — where the engine's own trap said `integer divide by zero` and gave no
address. Where the fragment proved the claim, the bare instruction is
emitted, so the check is a projection of the open claim, and a proof removes
it (tests/micros/mn-div-open-says.mn, mn-div-overflow-says.mn,
mn-mod-open-says.mn, mn-float-to-int-says.mn, mn-float-to-int-nan-says.mn).

Like `Alloc`, the trap effect is a row fact. It is inferred and projected
(`fn ratio(t, n) = t / n` renders `-> Int with Trap` at the address surface),
it is transitive through calls, and it can be proven absent:
`fn ratio(t, n) with !Trap = t / n` is refused with `E_EffectMismatch`, and
`fn ratio(t, n: Positive) with !Trap = t / n` is accepted.

The gradient suggests the annotation. At `fn inv(n) =
100 / n` the Teach facet names `n: NonZero`, the refinement in the module's
reach that discharges the claim and that every call of `inv` satisfies.
`mentl accept <file>:<line>:<col>` at the declaration writes it, even over a
written `n: Int`. Where two refinements prove the same thing and nothing in
the calls separates them, it asks which one is meant. Where no refinement in
reach states the claim, it reports the predicate the parameter needs.

The refinement on the divisor is the input that makes the proof possible. In
lib/dsp, six divisions by a hop or a grid width are proven by one refinement
on the parameter (`hop: Positive`, `num_high: Positive`), and each caller
pays the claim once, at the argument. A literal folds, and a computed value
leaves an open claim that charges the guarded `Trap` at the call
(`inv(m + 1)` under `!Trap` is refused; P0, §«Refinement types»). Whether a
type excludes a point is asked of the refinement itself, by deciding its
predicate with `self` bound to that point. So any refinement that the
fragment can decide at a constant works, and there is no allowlist of
"nonzero-ish" type names.

`float_to_int` follows the same rule at a conversion the machine cannot
complete: a Float that is not finite, or is beyond what an Int holds, traps.
Its face claims `Truncatable` (`type Truncatable = Float where -2147483649.0 <
self && self < 2147483648.0`, from the prelude) of its argument. So a
constant in range is proven, a constant out of range is
`E_RefinementRejected` where it is passed, and a value nothing bounds charges
`Trap` (tests/micros/mn-float-to-int-*.mn). The word primitives form one
roster published by kind, and each one's face states what it does: `floor`
and `sqrt` are instructions, total over every Float. An effect op may not
take a primitive's name (`E_OpShadowsPrimitive`), since the op would answer
some calls of the primitive and not others. The library calls the conversion
only where its argument is bounded: `exp` scales by squaring, `sin` reduces
its phase with `floor`, and a decimal digit is read by comparison
(tests/micros/mn-sin-large-argument.mn).

The e-graph reads the same fact. `x * 0 ≡ 0` drops its operand only when the
operand's subtree row is pure, and a division whose claim stays open is not
pure, so `(1 / n) * 0` traps at `n = 0` as written.

**A claim can use the conditions on the path that reaches it.** A claim
stands where control reached it, so the conditions above it on the parent
edge hold there. Inside an `if`'s branches, the test is known to be true in
one branch and false in the other. Inside the right operand of `&&`, the
left operand is known to be true, and inside the right operand of `||`, it
is known to be false. Inside a `match` arm, its own literal pattern is known
to match and every earlier literal arm is known to have failed. So
`if b > 0 { a / b }`, `if b == 0 { 0 } else { a % b }`,
`match b { 0 => 0, _ => a % b }`, `if i >= 0 && i < len(xs) { xs[i] }` and
`if len(xs) == 0 { d } else { xs[len(xs) - 1] }` are total, and `!Trap`
holds over each. A source the path excludes never reaches the site: after
`let i = if c { -1 } else { 1 }`, the read in `if i >= 0 && i < len(xs) {
xs[i] }` is proven, where the same read written bare is refused at the
join's `-1` tail (tests/micros/mn-path-excludes-fatal-tail.mn), and a
division or a refinement claim behind such a guard is proven the same way.
The conditions are about terms, each plus a constant: a
constant, a binder read along its edge, or the length that the vocabulary's
`len` returns (a parameter named `len` is not a length). They are decided as
difference bounds. A condition is a fact about machine words, so a term with
an offset counts only where the facts already counted keep it inside the
word. For example, past `i
>= 0 && i + 1 <= len(xs)` the read `xs[i]` stays open, since `i + 1` wraps
at the largest Int (tests/micros/mn-path-*.mn). A read that the judgment
proves in bounds uses the unchecked traversal, which dispatches on the
list's shape and is total (tests/micros/mn-proven-read-is-total.mn).

**A sequence primitive checks its own precondition.** `slice` and
`str_slice` trap where a bound leaves the sequence (when `0 <= start <= end <=
len(xs)` fails). They never clamp the range to a view the caller did not ask
for. `make_list` traps at a negative count before anything is allocated, so
the count never reaches the allocator as exhausted memory. `list_set` traps
at an index outside its list, where a store past the end would overwrite
the next allocation. Each check is in the primitive's own body, so an
explicit call of one carries its `Trap` wherever its claim stays open
(tests/micros/mn-slice-bound-is-trap.mn, mn-make-list-count-is-trap.mn).

**An explicit call of a sequence primitive raises its face's claim.** A call
of `list_index` or `byte_at` with both arguments in place raises the read's
claim, `0 <= i < len(xs)`, and a call of `slice` or `str_slice` with its
three raises the cut's, `0 <= start <= end <= len(xs)`. Each is decided by
the same fragment, with the conditions on the call's path. Proven, the call
is the form beneath the check, `list_index_unchecked` or `slice_raw`, and
charges no `Trap`, so `fn from(s, k) with !Trap = if 0 <= k && k <=
byte_len(s) { str_slice(s, k, byte_len(s)) } else { "" }` is accepted.
Refuted, the call is refused where it stands: `slice([1, 2, 3], 1, 5)` is
`E_RefinementRejected`. Open, the call keeps the primitive, and the
primitive's own row carries the `Trap`; the ledger owes nothing for it, since
that row already says the program can stop there, where an open claim at
`xs[i]` or at `/` has no other record
(tests/micros/mn-explicit-read-proven-is-total.mn,
mn-explicit-cut-proven-is-total.mn,
mn-explicit-cut-fixed-out-of-range-refuses.mn,
mn-explicit-read-open-is-a-row-fact.mn). `make_list`'s count and `list_set`'s
index are still checked in their bodies alone, and a call that a pipe
completes (`xs |> slice(1, 3)`) raises no claim yet (`PLAN.md` §11, the
face).

The fragment cannot yet read a bound that a parameter takes from every call,
such as `0 <= i` where each call passes `0` or `i + 1`
(`Hβ.verify.parameter-is-what-its-calls-hand`). A destructuring
pattern follows the same rule in another form: the shape it asserts is its
precondition, decided by the same walk (§«Exhaustiveness»). Non-termination
is not a trap and is not in the row (`Hβ.effects.divergence-is-a-row-fact`).

**Recursion depth costs memory; it must never be a hidden trap.** A row
lists every way a computation can stop, so running out of stack must not be
the one way it leaves out. A recursion deeper than its stack spills its
remainder to the heap and resumes on a fresh stack, as a continuation
captured the same way as any held perform's. So its depth costs `Alloc`,
`!Trap` holds over any recursion, and `!Alloc` restricts a real-time stage
to the recursion that the stage bounds. A derived fold already keeps its
pending work in memory (§«Equality operator»). A recursion that a person
writes still runs out of stack today with nothing in the row, so a `!Trap`
recursion a million calls deep checks clean and then traps (`PLAN.md` §7;
§11, the keystone).

---

## Canonical layout (formatter canon)

Layout never changes meaning. The precedence table alone determines the
tree, and the formatter writes the canonical shape on save. The parser
enforces none of the rules below; they describe what `mentl fmt` writes.

### Sequential verbs at LEFT EDGE

`|>` and `~>` sit at the left edge of the code's enclosing indent, with each stage on its own indented line:

```
input
  |> stage_a
  |> stage_b
  ~> handler
```

### Convergent verbs at INDENTED CENTER

`<|`, `><`, `<~` sit at an indented center position (typically a 4-space indent from the enclosing left edge):

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

After a convergent construct, the chain returns to the left edge, and the
fanout that feeds it is parenthesized, because the precedence table requires
it. `|>` (3) binds tighter than `><` (2), so an unparenthesized
`a >< b |> mix` pipes into the last branch (`a >< (b |> mix)`). A probe with
values shows this: `(1) >< (2) |> inc` runs as `(1, inc(2))`, never as
`inc((1, 2))`. The source itself requires the parentheses, and the formatter
writes them:

```
((audio |> compress)
    ><
(ctrl  |> scale))
|> mix          // returns to left edge — consuming the WHOLE fanout
~> sink
```

### Indentation discipline

**The medium does the formatting; the developer types only the content.**

Mentl's canonical layout uses a 2-space indent for left-edge verbs (`|>`, `~>`, `<|`) and a 4-space indent for the indented-center convergent verbs (`><`, `<~`). The shape on the page is the computation graph, because the formatter projects it there (governing principle 1).

**Formatter canon** (the shape `mentl fmt` writes; these are not parse rules, since the parser has one precedence table and ignores whitespace entirely):
- Left-edge verbs render indented more than their input.
- Convergent verbs (`><`, `<~`) render at least as indented as the left-edge verbs of the same chain.
- Each stage of a `|>` / `~>` chain renders at the same indent as its peers.
- Within a `<|` branch tuple, branches render at the same indent as each other.

The parser accepts any whitespace; the precedence table alone determines the tree (Governing principle 1). Tabs are converted to spaces on save. Indentation is decided when rendering and is never part of parsing. No program is badly indented; there is only source that the formatter has not normalized yet.

**Render rule** (canonical):
- The formatter renders code in canonical 2-space / 4-space form on save.
- **A render that would lose what the author wrote is not written.** `mentl fmt` lexes its render next to the source and matches every identifier, literal (compared by value, so `48_000` and `48000` are the same) and prose line of the source against the render's. Anything left unmatched is a loss: the command names it with its line, leaves the file untouched and exits nonzero.
- **The head of a postfix form keeps its parentheses.** A call, a field read and an index bind tighter than every operator, so a callee, a receiver or an indexed value that is anything but an atom renders in parentheses: `(r |> keep).level`, `((a, b) => a * b)(2, 3)`, `([1, 2] ++ [3, 4])[2]`. If the head were rendered bare, the re-parse would attach the postfix to the head's last operand, and the "names conserved" check would pass it because no name is lost. A render that re-parses to a different tree is not refused yet (`Hβ.fmt.render-must-parse-to-the-same-tree`).
- **An arm list is its own delimiter.** A recurrence whose body is an arm
  list renders bare, `{ prev => a * x + (1.0 - a) * prev } <~ delay(1)`, and
  so does a literal used as a stage or a branch. The binder form keeps its
  parentheses, `((prev) => body) <~ delay(1)`, because its body extends to
  the right and a bare render would re-parse the verb into it.
- **A destructuring let renders as a let.** The parser turns `let (a, b) = v` and the rest of its block into one arm of a `match`, the same graph that a hand-written one-arm `match` makes. The match that a let becomes records from the start that it came from a let, so `mentl fmt` writes the let back at the block's indent, and a written `match` stays a match.
- **A tuple, a list or a `><` fanout past the width breaks** into one element per line, or into §`><`'s vertical layout, as a call's arguments and a record do.
- The `Format` effect at `src/format.mn` declares one op, `format_program`; `format_default` is the canonical handler.
- The editing surfaces format as a projection (keystroke → parse → format → render), so the developer never sees badly indented code. The page's canvas re-renders the canonical form when the editor is idle, never in the middle of a keystroke (the canvas landing), and `mentl edit` takes one action per invocation today (`Hβ.felt.edit-session-reads-one-action`).
- The LSP transport (external editors such as VS Code, vim and Emacs) does not answer formatting requests yet. Its format-on-save will be the same `format_default` read, as one more method on the server's dispatch.
- Tabs in the file on disk are converted to spaces at the next save. Each developer sets the renderer's indent width in their own editor, but the file on disk stays canonical, for L1 byte identity and deterministic version control.

**Composition**: the formatter is a `~>` handler in the cursor stack:

```
keystroke
  |> tokenize
  |> parse_to_graph
  ~> format_default
  ~> render_to_transport
    <~ accumulate(graph)
```

Format is idempotent (`format(format(x)) == format(x)`), so the incremental cursor's fixpoint converges in one iteration, and `mentl fmt` writes its own fixpoint in one invocation (it renders, re-parses, re-renders and writes the second render). So formatting needs nothing beyond the cursor projection.

---

## Top-level program structure

A `.mn` file is a sequence of top-level statements. Each is one of:

- `import path/to/module`: module imports
- `type Name = ...`: type declarations (ADTs, aliases, refinements, named rows)
- `effect Name { ... }`: effect declarations
- `handler name(...) with ... { ... }`: handler declarations
- `fn name(...) = ...`: function declarations
- `let name = ...`: top-level value bindings (constants)

A `.mn` file with no `main` function is a library module: other modules import its declarations. Compiling it produces a WAT module whose `_start` exits cleanly.

A `.mn` file with `fn main()` is an executable: `_start` invokes `main`.
Its module value lets run first, so what an initializer performs belongs to
the executable, and an effect that no handler serves is refused at the let,
as it would be in `main`. `main`'s declared row judges `main` alone
(`Hβ.effects.executable-row-includes-inits`).

A module value let binds every binder its pattern writes, and a discard
runs its value for its effects. Today the initializer stores only what a
single binder names, so a module-scope `let _ = e`, `let 5 = e` or
`let (w, h) = e` is refused where the program is emitted
(`E_InternalInvariant`) and never runs without the value it was written
for (tests/micros/mn-module-let-discard-refuses.mn,
mn-module-let-destructure-refuses.mn; PLAN §11, the keystone).

---

## Token enumeration

The lexer emits a stream of `Token` values, and the parser consumes them with an exhaustive match. The wrapper shape and the list of variants below are canonical, and the parser implements them exactly.

### Token wrapper — substrate-native pattern

```
type Token = Tok(TokenKind, Span)
```

This mirrors the `N(NodeBody, Span, Int)` wrapper for AST nodes: a structured value with positional metadata. Every token carries its source span, for parser diagnostics and for the Located reasons built later from it.

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
| `TFn`           | `fn`             | none      | start of a function declaration (never the head of a literal: `E_RedundantFnOnLambda`) |
| `TLet`          | `let`            | none      | start of let-binding                           |
| `TIf`           | `if`             | none      | start of if-expression                         |
| `TElse`         | `else`           | none      | between if branches                            |
| `TMatch`        | `match`          | none      | start of match-expression                      |
| `TType`         | `type`           | none      | start of type declaration                      |
| `TEffect`       | `effect`         | none      | start of effect declaration                    |
| `THandler`      | `handler`        | none      | start of handler declaration                   |
| `TWith`         | `with`           | none      | effect clauses, handler state, a resume's state update |
| `TResume`       | `resume`         | none      | inside handler arm body                        |
| *(removed)*     | none             | none      | `for`, `in`, `loop`, `break`, `continue`, `return`, and `perform` are not Mentl keywords. Iteration uses the pipe verbs and the Iterate effect; early exit is an arm that never resumes; ops are bare calls (`perform` was dissolved on 2026-08-08). |
| `TImport`       | `import`         | none      | top-level import statement                     |
| `TWhere`        | `where`          | none      | refinement type clause                         |
| `TOwn`          | `own`            | none      | parameter ownership marker                     |
| `TRef`          | `ref`            | none      | parameter borrow marker                        |
| `TPure`         | `Pure`           | none      | `with Pure` declaration                        |
| `TTrue`         | `true`           | none      | Bool literal                                   |
| `TFalse`        | `false`          | none      | Bool literal                                   |
| **Identifiers and literals (6)** |  |           |                                                |
| `TIdent(s)`     | `[A-Za-z_][...]` | name      | variable refs, fn names, type names, etc.      |
| `TIntLit(n)`    | `[0-9][0-9_]*`, `0x[0-9A-Fa-f_]+`, `0b[01_]+`, `0o[0-7_]+` | i32 value | integer literal (decimal / hex / binary / octal; underscores allowed for readability) |
| `TFloatLit(f)`  | `[0-9][0-9_]*\.[0-9][0-9_]*` | f64 value | floating-point literal (underscore separators allowed) |
| `TComment(s)`   | `// ...`         | comment text (contiguous lines concatenated, leading `//` stripped) | graph content; attaches to next decl / enclosing node |
| `TStringPart(s)`| a literal chunk of `"..."` or `"""..."""`, between splices; a splice-free string is one chunk | chunk text (escape-resolved) | string literal and interpolation (→ `MakeStringExpr`) |
| `TStringSplice` | start of a `{expr}` splice inside `"..."` | none | followed by ordinary tokens; `TRBrace` closes the splice |
| **Two-character operators (14)** |  |           |                                                |
| `TEqEq`         | `==`             | none      | equality comparison                            |
| `TBangEq`       | `!=`             | none      | inequality comparison                          |
| `TLtEq`         | `<=`             | none      | less-than-or-equal                             |
| `TGtEq`         | `>=`             | none      | greater-than-or-equal                          |
| `TArrow`        | `->`             | none      | function return type, fn-type form             |
| `TFatArrow`     | `=>`             | none      | match arm separator, lambda body separator     |
| `TPlusPlus`     | `++`             | none      | sequence concat (`seq_concat`)                 |
| `TPipeGt`       | `\|>`            | none      | sequential pipe                                |
| `TLtPipe`       | `<\|`            | none      | divergent pipe (fanout)                        |
| `TGtLt`         | `><`             | none      | parallel compose (structural N-ary)            |
| `TTildeGt`      | `~>`             | none      | handler-attach (the one install verb); `~` is consumed by maximal munch only into `~>`/`<~`, so a standalone `~` is an unexpected-char lex error (no bare-`~` token) |
| `TLtTilde`      | `<~`             | none      | feedback                                       |
| `TAndAnd`       | `&&`             | none      | logical and                                    |
| `TOrOr`         | `\|\|`           | none      | logical or                                     |
| **Single-character operators and punctuation (23)** |  |           |                              |
| `TLParen`       | `(`              | none      | grouping, params, tuples, calls                |
| `TRParen`       | `)`              | none      | close grouping                                 |
| `TLBrace`       | `{`              | none      | blocks, records, arm lists, effect and handler bodies |
| `TRBrace`       | `}`              | none      | close LBrace                                   |
| `TLBracket`     | `[`              | none      | list literals, list patterns                   |
| `TRBracket`     | `]`              | none      | close LBracket                                 |
| `TComma`        | `,`              | none      | separator in tuples, params, fields, lists     |
| `TDot`          | `.`              | none      | field access                                   |
| `TColon`        | `:`              | none      | type annotation, record field binding          |
| `TSemicolon`    | `;`              | none      | never canonical: newlines separate statements; it is lexed so the formatter can lift it to newline layout |
| `TPlus`         | `+`              | none      | addition; effect union                         |
| `TMinus`        | `-`              | none      | subtraction; unary negate                      |
| `TStar`         | `*`              | none      | multiplication                                 |
| `TSlash`        | `/`              | none      | division; module-path separator                |
| `TPercent`      | `%`              | none      | modulo                                         |
| `TEq`           | `=`              | none      | binding (let / fn / type)                      |
| `TLt`           | `<`              | none      | less-than comparison (no generic-parameter role, since angle brackets are retired; `f<T>(...)` parses as a comparison chain and the general unexpected-token or type-mismatch diagnostic explains it; there is no special turbofish lookahead) |
| `TGt`           | `>`              | none      | greater-than comparison (no generic-parameter role; see `TLt`) |
| `TBang`         | `!`              | none      | logical not; effect negation                   |
| `TAmp`          | `&`              | none      | effect-row intersection (`inter_row`, §«Named effect rows»); row-expression syntax only, with no value-operator precedence |
| `TPipe`         | `\|`             | none      | type-variant separator; pattern alternation in match arms (the `\|x\|` lambda fence is rejected with `E_LambdaFence`) |
| `TAt`           | `@`              | none      | as-patterns: `name @ pat` binds the whole value and also destructures it (§«As-patterns»); `@resume=` is erased in favor of inference from the body |
| `THole`         | `??`             | none      | hole: the gradient's syntactic marker for a missing piece; Mentl's Synth proposes candidates to fill the position. A single `?` is no longer a token. |
| **Layout / structural (2)** |     |           |                                                |
| `TNewline`      | `\n`             | none      | statement separator; transparent around binary operators (layout never changes meaning) |
| `TEof`          | (end of input)   | none      | always the last token; the parser uses it to stop |

**Checksum: 62 variants** (17 keywords + 6 identifiers/literals + 14 two-char operators + 23 single-char operators/punctuation + 2 layout). The count lets a reviewer check that the `TokenKind` declaration and this catalog list the same set. It is a hand-maintained stand-in for `mentl audit` until the cursor projects the count from the graph. Exhaustiveness over the ADT (§Lexer/Parser obligations) is what guarantees the count; the number reflects that guarantee and does not create it. (`TColonColon`, `TCapability`, `TTilde` and `THandle` are absent, because a token with no counterpart in the kernel would be speculative inventory, and `handle` is a noun of the medium's own domain, not a keyword (§«Installation»). `TStringPart`/`TStringSplice` carry every string, and a splice-free string is a single chunk.)

### Lexer obligations

- **Every emitted Token must be a variant of the `TokenKind` ADT declared above.** The rule is exhaustiveness, not a magic number: the parser's exhaustive match (§Parser obligations) guarantees completeness. Adding a token kind means updating SYNTAX.md first, then the lexer, then the parser's match, which fails to compile until the new variant is handled (H6 applied at the lexical layer).
- **Whitespace (other than `\n`) is silently consumed.** The lexer skips spaces and tabs without emitting a token. Only newlines carry meaning.
- **Comments `// ...` emit `TComment(text)`** (leading `//` stripped, contiguous lines concatenated). A comment is graph content: the parser attaches each one to the following declaration or the enclosing node, and the medium never silently discards prose. There is one comment form.
- **Block comments do not exist.** See the Comments section of this spec.

### Parser obligations

- **Match on `Token` must be exhaustive.** There are no wildcard arms over `TokenKind`; every variant is listed explicitly. Under H6's discipline, `_ => …` on a load-bearing ADT is rejected by code review and by substrate convention.
- **Span propagation.** Every parsed AST node is constructed with the joined span of its constituent tokens. Use `span_join(token_span(first), token_span(last))`.
- **Angle brackets are retired; `<`/`>` are always comparison.** `<` and `>` are TLt/TGt everywhere. Generic type parameters follow the lowercase-identifier convention (the case rule is the declaration, §«Generic type parameters»); there is no angle-bracket parameter list in any declaration position. The parser has no special `ident<...>(` recognizer, because a separate scanner for each foreign form does not scale, and the parser has one precedence table and keeps producing a tree after an error. A `f<T>(args)` written out of habit from another language parses as the comparison chain that the precedence table builds (`<` is TLt), and the general unexpected-token or type-mismatch diagnostic explains it in context (a `TBool` where a callable was expected, with a Located Reason). The one general diagnostic path does the explaining; there is no Rust-specific lookahead.
- **Pipe-vs-or disambiguation.** `|` is TPipe (the variant separator in a `type` body and pattern alternation in a match arm); `||` is TOrOr (logical or). There is no `|x|` lambda fence; lambdas use `(params) => body`.

### `if` without `else` — unit-returning conditional

An `if cond { body }` without `else` is legal when `body`'s type is unit `()`. The compiler inserts an implicit `else { () }`. This form is used for conditionals that run only for their side effects:

```
if should_log { log("message") }             // unit body — OK
if x > 0 { x * 2 }                            // non-unit body — E_IfMissingElse
```

An if without an else whose body is not unit is rejected with **`E_IfMissingElse`**, and a Quick Fix suggests adding an `else` branch or restructuring the code. This turns the bug of forgetting the else into a compile error.

---

## Diagnostic catalog (syntax-level errors introduced by SYNTAX.md)

Mentl's diagnostics are written to explain the problem, and a diagnostic is
a projection of the graph, not an entry in a hand-maintained registry. Each
is a `DiagKind` constructor
(`type DiagKind = ERedundantBraces(Span) | EEffectMismatch(EffRow, EffRow, Reason, Span) | …`)
that carries its **Located Reason edge** (arm 8) and its **Applicability**
(`type Applicability = MachineApplicable | MaybeIncorrect | HasPlaceholders | Unspecified`,
an ADT, never a string). The live catalog is `mentl diagnostics`, which walks
those constructors, in the same way that `mentl where`/`mentl audit` project.
The tables below are worked examples at the forms where each diagnostic is
introduced; they are not the source of truth.

Two axes describe every diagnostic: **severity** (error or narration) and
**applicability** (the four-value ADT, which drives automation:
`MachineApplicable` is applied automatically, `MaybeIncorrect` needs
confirmation, `HasPlaceholders` needs the developer to fill something in,
and `Unspecified` is text only). The category is the product of the two
axes, not a third column (drift-7 avoided). A **Quick Fix draws an edge**:
the medium applies it to the shared graph image, and then the IC cursor
re-projects to show the resolved state and any Reason further downstream
that now appears. It is the same `<~ accumulate(graph)` loop the formatter
uses. **A refusal is a hole**: a fix is offered only once it is proven. The
refusal site forks each candidate edit, judges it in its own instance, and
shows the survivors or asks the one question that separates them, the same
loop a `??` runs (§«Partial application», `PLAN.md` §11, a refusal is a
hole). The diagnostic surface is a `~>` handler that re-projects the graph,
just like `format_default`. Identity already lives on the ADT: `report`
takes one `DiagKind`, and its source, severity, applicability and message
are projections of it (`diag_source`, `diag_kind`, `diag_applicability`,
`diag_message`, src/types.mn). Only the tables remain. Until they are the
text of that projection (`mentl diagnostics`, `Hβ.diag.catalog-as-projection`),
every row names a class that a constructor declares, and a shape that the
general class refuses is written on that class's row with the fixture that
holds it.

The three groupings below are derived from those two axes; they are not separate rules:
- **Format-liftable** ≡ `MachineApplicable` ∧ the redundant form has no graph node (next section).
- **Hard error** ≡ severity=error: a substrate violation the medium cannot recover from automatically. Every hard error refuses the executable. The gate reads the count of errors the judgment reported, so a program with one is never emitted, and `mentl check` exits nonzero on it (tests/micros/mn-*-refuses.mn).
- **Gradient narration** ≡ severity=narration: the explanations Mentl prints, which the developer accepts or dismisses.

### Format-liftable (parse-canonicalized — no graph node to "strip")

A redundant form is not stripped by a separate formatter pass. It parses to
the same canonical graph as its minimal form, so it has no node by the time
`format_default` runs. "Lifting" is the formatter projecting the canonical
graph back, and the redundant input does not survive parsing
(`format(format(x)) == format(x)` because `parse(x)` already lost the
redundancy). A format-lift gets a (silent) code if and only if it removes or
transforms something present in the graph: a `TokenKind` the lexer actually
emitted. Re-flowing whitespace emits no token, so it gets no code. That is
why `E_IndentMismatch` does not exist: no program is badly indented; there
is only source that the formatter has not normalized yet.

*The silent lift is the intended design. `E_RedundantBraces` is still
reported as a warning. It will be retired when the formatter's canonical
projection becomes the save path (`PLAN.md §11`, the project canonical),
never by muting the reporter.*

| Code                  | Trigger (an emitted token, removed/transformed)         | Canonicalization                                 |
|-----------------------|---------------------------------------------------------|--------------------------------------------------|
| `E_RedundantBraces`   | braces wrapping a non-`BlockExpr` (no statements)       | drop the braces; user sees no diagnostic         |

Five more redundant spellings are lifted silently, with no class, since each
parses to the same graph as its canonical form: statements written without
braces (the parser reads them as their block and the render writes the
braces, §«Missing braces»), a `;` between statements (the parser skips it as
a separator and the render writes newline layout), an explicit `-> ()`
(§«Unit return omission»), an ownership marker after the colon
(`ast: own Node`, §«The Intent Boundary Rule»), and a `<|` over one stage,
which the parser builds as the pipe it is (§«`<|` — diverge»).

### Hard errors (substrate violations)

| Code                  | Trigger                                       | Applicability        | Quick Fix                                      |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `E_PatternInexhaustive` | a value escapes every arm of a match that has two or more arms (a match with one arm, including a destructuring `let`, claims its shape instead, §«Exhaustiveness»). Coverage is read over the whole pattern, column by column, so a variant missing inside a constructor's payload is refused too, and the message names the escaping value as a pattern. An alternation covers its branches, and an as-pattern covers its inner pattern. A list column is `[]` or a head before a rest, a record is its fields, and Bool's literals are its constructors; any other literal column is covered only by a wild row (`0` beside `1` misses `_`). ARMED | `HasPlaceholders`    | insert the arm the witness names |
| `E_CatchAllOverSum`   | a `_` or bare binder after other arms of a match over a sum. It stands for the constructors those arms leave out, and a constructor declared later would fall into it without being read. The message names the roster as a pattern. A `_` in a payload, over a word, a text or a list, or as a match's only arm is legal (§«Exhaustiveness»). ARMED (tests/micros/mn-catch-all-over-sum-refuses.mn) | `MachineApplicable` | write the roster; `mentl tighten` writes each in its arm's place |
| `P_ExpectedToken`     | the parser expected one token and found another, including a name the grammar requires, so `fn let(x)` is refused at the keyword (tests/micros/mn-keyword-name-refuses.mn). The parser recovers so that the judgment can continue, but a recovery is a guess at text the parser could not read, so the program is refused | `MaybeIncorrect`     | write the token it expected |
| `P_UnexpectedToken`   | a token not valid at its position. In pattern position the recovery is a wildcard, so the program is refused instead of running the arms the wildcard swallowed (tests/micros/mn-pattern-token-refuses.mn) | `MaybeIncorrect`     | restructure per the surrounding form |
| `P_UnclosedConstruct` | EOF inside a construct (a block, match arms, effect operations, a type's variants) before its closer. It is reported once, at the end of input, and the rest of the file is never read as the construct's members | `MaybeIncorrect` | close the construct or remove its opening token |
| `E_RefinementRejected`| a value violates a refinement predicate, a partial primitive's precondition is refuted by constants (`1 / 0`, `INT_MIN / -1`; §«Partiality»), or a destructuring pattern's shape is refuted by how the value was built (`let Some(v) = None`; §«Exhaustiveness») | `Unspecified`        | adjust value or widen refinement               |
| `E_EffectMismatch`    | the declared row does not subsume the body row. The Reason names the declaration and, for a function, the chain of sites through which the first refused effect enters, up to the op where the chain reaches one. Each site is a `module:line:col` that names what the effect crosses there (a callee, a stage, a handler, a function value entered) or the construct that charges it (`rendering the value`, `building the list`). The span stays the declaration's, since its clause is what the body violates. An install whose arms perform an effect that the installing declaration forbids is in this class: what an arm performs enters the install's row (§«`~>` — tee»; tests/micros/mn-handler-arm-forbidden-refuses.mn) | `MaybeIncorrect`     | widen the declaration, or install an absorbing handler at the site the chain names |
| `E_PurityViolated`    | `with Pure` body performs non-empty effects   | `MaybeIncorrect`     | remove `with Pure` or absorb the effect        |
| `E_ZeroDelayFeedback` | `x <~ delay(0)`: a cycle with no delay, where the prior value would be the value being computed. ARMED (refuses the executable); one arm of the depth read, covering both the `delay` and `Delay` spellings | `MaybeIncorrect` | raise the delay to at least 1 |
| `E_ComputedDelayDepth` | `x <~ delay(n - 1)`: the depth is a runtime value. A feedback line's ring is sized and wrapped by its literal depth, so a depth that cannot be read cannot be held, and the site would silently get one slot. ARMED, the sibling arm of the same read | `MaybeIncorrect` | write the depth as a literal, or hold the history yourself |
| `E_OwnershipViolation`| `own` consumed twice, or escapes its ref scope | `Unspecified`        | restructure to single-consume or use `ref`     |
| `E_UseAfterMove`      | a borrow read of a name that the affine ledger already moved: the read half of the affine rule, beside `E_OwnershipViolation`'s consume half. ARMED. Today such a read is sound only by accident, because the heap frees memory only where an extent ends (an arena's exit, a reset), never at a `Consume`. It becomes a use-after-free once a `Consume` reclaims memory | `Unspecified` | drop the read, or restructure so the move happens after it; do not patch around it |
| `E_HandlerInexhaustive` | a handler's arms answer some ops of an effect and not others (§«A handler is exhaustive»). An install absorbs every op of the effects its arms answer, so the missing op would escape the row and reach nothing at run time. ARMED; the shape it refuses was a false proof of absence that trapped | `HasPlaceholders` | add the arm; forward the op outward (`op(…) => resume(op(…))`); or declare the ops this handler answers as their own effect |
| `E_ResumeOfNever` | a handler arm resumes an op declared `-> !` (§«Never-returning ops»). The never type is quantified per perform, so no value that the arm hands back is one that every performer can receive. ARMED | `MaybeIncorrect` | end the arm with the value the install answers, or declare the op's result type if it does return |
| `E_EffectUnhandled` | an effect reaches the executable root (`main`'s row, or a module value's initializer, which runs before `main` in the same world) with no install absorbing it, and its ops are not the substrate's own instructions (Memory, WASI and Cast are grounded; a row fact with no ops, such as Mutate or Arena, is grounded vacuously). It is judged at the end of the judgment, so `mentl check` refuses it wherever `mentl compile` does, and the chain names where the effect enters. ARMED (tests/micros/mn-check-root-unhandled.mn, mn-check-root-unhandled-init.mn) | `MaybeIncorrect` | install a handler for it over the performing chain; the message names the handlers in scope that answer it |
| `E_InitPerformsOwnOp` | a handler's state initializer or config default, or an install's own argument, performs an effect that only that handler answers (§«Handler declarations»). Each of these runs before the install exists, so nothing can answer the perform. ARMED (tests/micros/mn-refuse-init-performs-own-op.mn, mn-check-install-config-own-op.mn) | `MaybeIncorrect` | move the perform into an arm, or compute the value under a handler installed around this one |
| `E_ThreadedBranchEffect` | under a threaded schedule, a branch's row carries an effect whose covering handler writes its state (`resume … with`), lies beyond the frame fence with no demand reaching it, or reaches such a handler through its own arms (§`><`). The covering handler is the one at the fanout's frame or, for a fanout that a caller's schedule demands, the one along the demand's chain of installs, with the callback parameter's row read at the instantiating site. The class also covers a branch that stores into memory older than itself, or reaches code that writes memory older than its own frame (`Mutate`); a sequence fanout's function is read as every branch's function. ARMED | `MaybeIncorrect` | install a handler that writes no state at the fanout's frame, or install the handler inside the branch; give each branch memory it allocates |
| `E_DerivativeUnreachable` | a `d(v)` under a derivative reading whose argument's tangent was lost: into an aggregate, across a multi-shot perform, off a line ticked by forward code or a line a closure record owns, or through another `d`. The class also covers a mint, an install or a state write under the reading that would store a lost tangent into a record, and a reading whose seed is not a Float variable in scope (§`~>`). The message names the loss site. ARMED: the alternative is a slope of zero that the program never has | `Unspecified` | keep the value out of the aggregate until it is asked for, or seed the reading at a Float variable |
| `E_EnvNameUngrounded` | a required environment read (`env`, lib/environ.mn) whose name is not a literal at the read. The program's requirement on its host could not be stated before it runs, so its launch gate could not check it (§«Configuration — the environment is an effect»). ARMED | `MaybeIncorrect` | write the variable's name at the read, or ask `env_opt` and decide what an absent value means |
| `E_MissingVariable`   | name not in scope                             | `MaybeIncorrect`     | check spelling; check imports                  |
| `E_MissingImport`     | a name resolves only because the whole link carries it: it is declared at module level in a module that the referencing module never imports, directly or transitively (the prelude's closure is always in scope, because the driver links it into every compile). ARMED, naming both modules at the reference | `MaybeIncorrect` | add `import <declaring module>` to the referencing module |
| `E_UnknownArgLabel`   | a labeled arg names no declared parameter     | `MaybeIncorrect`     | check the label against the parameter names    |
| `E_TypeMismatch`      | unification failed. The message carries the Reason the unification was asked with, beyond the diagnostic's own span (`Int vs [Byte] — ~> pipe → at 15:13-15:27: inferred from the arm bail of handler h`). Three shapes belong to this class, each with its own Reason. A pipe into a stage with no hole (`x \|> f(a, b)` over two parameters) and a pipe into a stage with two holes, neither marked (`x \|> g(a)` over three), are each refused where the stage meets the pipe's one-parameter function. A `++` whose operands' element types do not unify (`[1] ++ [true]`) has a Reason naming the `++` (tests/micros/mn-pipe-into-complete-refuses.mn, mn-pipe-hole-ambiguous-refuses.mn, mn-concat-type-mismatch-refuses.mn) | `Unspecified`        | adjust types; widen / narrow; leave a stage one hole, marking it `??` where it is not the last field |
| `E_OccursCheck`       | infinite type                                 | `Unspecified`        | restructure to break cycle                     |
| `E_OrphanHandlerAttach` | `~>` with no preceding chain                | `Unspecified`        | delete `~>` or supply body                     |
| `E_NotAKeyword`       | the user typed `for`/`while`/`loop`/`break`/`continue`/`return` | `MaybeIncorrect` | rewrite it in the verb form             |
| `E_PatternAlternationBindingMismatch` | branches in `\|` bind different names or types | `MaybeIncorrect` | adjust patterns to bind same names with unifiable types |
| `E_DuplicateBinder` | a name bound twice in one head (across its parameters and inside their patterns) or by one pattern (`fn f(x, x)`, `(x, x) => x`). The second binder is refused, and the message names the first. An alternation's branches, which must bind the same names, count as one binder for each name. ARMED | `MaybeIncorrect` | rename one binder |
| `E_ResumeOutsideArm`  | `resume` where no continuation exists: outside a handler arm and outside every lambda or nested fn created inside one, whose record captures the arm's k. ARMED (tests/micros/mn-resume-outside-arm-refuses.mn) | `Unspecified`        | move the resume into an arm, or declare the fn inside the arm; the continuation only exists there |
| `E_ResumeWorldMismatch` | two continuations (`TCont(R, S, discipline, world)`) unify with incompatible resume disciplines. OneShot, MultiShot and Abandon are distinct representations (stack frame, heap record, dead continuation), so the mismatch is a hard error. The world half is the row unification in the same TCont arm (`!E` lifted to the time axis, §4③). A continuation resumed under a changed world is checked against that world beyond its own segment, and a negation over the resume or the root refuses a continuation whose world cannot answer its remainder, as `E_EffectMismatch` or `E_EffectUnhandled` (§«A resumed remainder answers to the world it is resumed in») | `MaybeIncorrect` | align the handler arms' resume cardinality; for a world clash, re-install the absorbing handler before the resume or widen the continuation's world |
| `E_DeclaredRowContradiction` | one authored clause asserts a name both present and absent (`with E + !E`, instance-aware: a bare present name beside an absent instance stays a refinement). It is reported at the signed fold, before the meet drops it; ARMED (refuses the executable). Before this diagnostic, the meet let a performing body check clean under a declared `!E` | `MachineApplicable` | drop one side of the contradiction |
| `E_ArithOnAggregate`  | `+ - * / %` or unary `-` whose operand is a product, sum, sequence, function, continuation or unit. The operands are addresses, so the arithmetic would operate on where the values live. ARMED: judged at the operator for a bound operand, and at the one writer for a gated cell bound later (a `NumericGate` on the cell, copied at instantiation and reached through the instance column). So the judgment refuses, `mentl check` reports it, and no WAT is streamed | `Unspecified` | give the operand a number (a word) or read the field you meant |
| `E_UnresolvedHole`    | compiling an executable whose reachable emitted tree carries an authored value-position `??` (§«Partial application»: a hole is productive for check and edit, never an executable value; a parameter-product `??` is an executable suspension and runs). Raised by the executable gate between reachability and emit, with a nonzero exit, zero WAT bytes, and the authored weave span on the diagnostic | `HasPlaceholders` | fill the hole (accept a Synth survivor) or suspend it into a parameter product |
| `E_FieldOffsetUnprovable` | a field read or a record pattern whose receiver's row never closed where the body is emitted: with no field set, there is no slot. Reported at the settle point. The plan's emitted reach asks it of every body under the bracket that body is emitted in, a base at the floor and a twin under its own pairs, before the gate reads the ledger, so the compile exits 1 with zero WAT bytes. ARMED (`tests/micros/mn-payload3.mn`) | `MaybeIncorrect` | close the receiver's row: annotate it at its Intent Boundary, or give the call site a shape its specialization can key on |
| `E_ShapeUnprovable` | a comparison, a show, a hash or a `++` whose operand is still a type variable where it is emitted. Nothing proves the shape the read needs, and the one-word read it would fall back to compares addresses, which is wrong for anything but a word. Reported at the settle point beside its row sibling, and ARMED with it | `MaybeIncorrect` | prove the operand: give the call site a shape its specialization can key on, or name the type at its Intent Boundary |
| `E_HandlerChainShape` | a handler chain (`handler NAME = h1 ~> h2`, §«Handler chains») with the wrong shape: a member that is not a handler or a chain, a member whose argument declares anything (a function, a handler, a type, an import), or the chain installed with arguments of its own (a chain carries no config; its members do). All three are judged at the declaration or the install, never at lowering. ARMED (tests/micros/mn-handler-chain-shape-refuses.mn) | `MaybeIncorrect` | name a handler at the member; move the declaration beside the chain; install the chain bare and give the member its config |
| `E_OpShadowsPrimitive` | an effect op declared with a word primitive's name (`floor`, `float_to_int`, …): the primitive is the judgment's own declaration, and an op of its name would answer some calls of it and not others (§«Partiality»). ARMED (tests/micros/mn-op-shadows-primitive.mn) | `MaybeIncorrect` | name the op for what it answers |
| `E_InstantiationDepth` | a reference eight instantiations deep in a recursion whose type grows with every call, reaching a callee that reads the growing structure (a comparison, a show, a field, or a number). Monomorphization cannot specialize without bound, and the ninth level would read the structure as a word, so the settle point refuses there. ARMED. A wide value that nothing reads crosses the word protocol boxed and back, and is accepted | `Unspecified` | recurse over a type that keeps its shape, or leave the growing part unread |

### Gradient narration (teaching surfaces)

| Code                  | Trigger                                       | Applicability        | Action                                          |
|-----------------------|-----------------------------------------------|----------------------|-------------------------------------------------|
| `T_OverDeclared`      | a declared bare positive name beyond the proven row (the positive half only; a negation is a proof claim and is never over-declared) | `MachineApplicable`  | `mentl tighten` writes the clause's residue |
| `T_RowInventory`      | a declared clause whose bare positive names are all proven by the body's ground row: the projected row written out by hand (§«A signature is not an inventory»). Over an open body row, the bare names are a cap that the declaration installs as a gate, and nothing is narrated | `MachineApplicable` | `mentl tighten` writes the residue: negations, instance pins, or no clause |
| `T_WordSlotBox`       | a wide value (a Float) boxed into a fresh cell to cross a callee's slot sized for a word, such as a list primitive's element (`list_set`), inside a unit whose row does not say `Alloc`. The cost belongs to the representation, not the program, until the slot takes the value's own width (`Hβ.value.seq-element-stride-carrier`). Reported at the settle point by the allocation audit, which refuses every allocation that is the program's own | `MaybeIncorrect` | keep the value at a word's width where the slot is one, or wait for the carrier |
| `W_RedundantWhere`    | `type X = Y where true`: a vacuous predicate  | `MachineApplicable`  | drop the `where true`; the alias is transparent |

---

## What this document is NOT

- Not a tutorial. The course is `examples/pulse/course`: ten programs on one audio chain, each a lesson that `mentl run` renders and that the page opens as a project (`docs/MENTL_SPACE.md` §5.5).
- Not a reference for library functions. See `lib/` and `mentl doc <module>`.
- Not a description of the current parser. The parser implements this document; where they disagree, the parser is wrong.
- Not a wishlist. Every form here must be implemented in the parser. Closing the gap between this spec and the parser is a standing obligation, not something for later (the parser is built to match SYNTAX.md; where they disagree, the parser is wrong).

---

## Verbs this document declares that the CLI has not yet grown

SYNTAX is the authority, and the CLI is built to match it, so this file may
name a projection before `mentl help` lists it. That permission is real, but
it is also how a documented verb can go stale without anyone noticing. So
the verbs that lag are kept in one list, which a script checks:
`tools/doc-truth.sh` reads the names below and fails on any other verb the
docs name. The list shrinks as verbs are added to the CLI, and it never
grows without notice.

- **`mentl diagnostics`**: the live catalog projected from the `DiagKind`
  constructors, so that the tables in this file stop being a second,
  hand-kept copy.

*(`mentl verify` checks the medium's standing bounds on its own source, and
each bound and its justification are kept in `src/board.mn`, where
`mentl why` walks them. It takes over the census half of `tools/verify.sh`.
The legs that measure the world outside the graph (the micro battery's exec
seam, the march's peak RSS, the scaffold count) stay in the script, and they
are listed here by name instead of being left there silently.)*

## Authority

This document is the authority on syntax. It overrides any claim about syntax in `CLAUDE.md`/`PLAN.md` (the three live documents) and in the archived `docs/**` files (kept only in git history: DESIGN.md, SUBSTRATE.md, the per-module specs). Where any of them conflicts with SYNTAX.md, SYNTAX.md is correct.

Mentl's discipline applies to syntax. Every form in this document was decided by asking the eight interrogations, one per kernel primitive (`PLAN.md §2`; the table lives in `CLAUDE.md`) and one per Mentl tentacle: graph (what AST does it produce?), handler and inferred resume cardinality (what installed handler reads it, and what cardinality does the arm body prove?), verb (which topology?), row (what `+ - & !` constraint do the body's op-call sites prove?), ownership (what `own`/`ref` does the use count infer?), refinement (what predicate does the path narrow?), gradient (what annotation input or body structure unlocks the cursor's projection here?), and Reason (what edge does it leave for the Why Engine?). Forms that failed any of the eight were rejected. **Annotations declare inputs to the cursor, never the emergent property itself.**

When a question comes up about syntax that this document does not cover yet, resolve it by checking the design against the kernel (`PLAN.md §2`), both reductively (what is the minimal correspondence to the graph?) and generatively (what do multi-shot, threading, unified memory and the frontier make better?). Then update this document. SYNTAX.md is the one place where the surface syntax is defined.
