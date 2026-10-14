# Mentl — CLAUDE.md · how to work

Three documents, read whole every session: this one (method), **`PLAN.md`**
(substance — the thesis, the kernel, the decisions, and §11, the one list of
open work) and **`docs/SYNTAX.md`** (surface — the authority on the language's
form). Nothing else is read-path. History is `git log`; the pin chain is
`boot/PROVENANCE.md`; what the program has not reached is measured by the
medium itself (`mentl verify`, `mentl query`), never kept as prose beside it.

@PLAN.md
@docs/SYNTAX.md

## The one law

**One graph. Two operations: draw an edge (the judgment writes), project
(everything else reads).** A fact computed, copied, cached, filed under a
name, or re-derived anywhere it could be read live is the bug, and its fix is
less code. A reader holding a node follows the node's edges; a name is looked
up once, at the writer, where it resolves in its scope — or at the text
boundary, where a person typed it.

## The thesis is the acceptance test

Mentl closes the gap between what a person means and what they are forced to
write (PLAN §0). A landing is done when a person at the keyboard can see it: a
`mentl` verb on a user program shows the property it advances — proof beats
review, the negative is provable, intent is lossless, computation is durable,
systems explain themselves. The commit message names the property and the
verb that shows it. A change no person can feel at the keyboard is either
infrastructure a named landing in PLAN §11 stands on, or it is not done.

## Mentl builds Mentl — enforced, not requested

- **Every question about the program is a verb.** `mentl query`, `where`,
  `why`, `check`, `audit`, `teach`, `verify`, `test`, `<file:line>`. A shell
  search over `.mn` source is refused (`tools/hooks/medium_first.py`); editing
  a file the medium has not been asked about is refused
  (`tools/hooks/consult.sh`). A question no verb answers is a missing facet:
  the command passes with `# verb-gap: <facet>` on it, the gap is logged, and
  the facet is grown in `src/` in the same landing.
- **Every capability lives in the medium's own source.** No new scripts and no
  new documents: the obey gate refuses a new `.sh`, `.py`, `.js` or `.ts` file
  outside `ide/`, any growth of `tools/`, and a new `.md` file
  (`tools/obey-gate.py`). The scripts that remain are scaffolds the medium has
  not absorbed yet; absorbing one into a verb is always in scope, and `tools/`
  only shrinks.
- **The wheel's source is the first user program.** It is written the way
  SYNTAX asks a person to write: verbs over index loops, handlers over flags,
  edges over name lookups, the authored text holding decisions while the
  medium projects the rest. Dead code, side indexes, compensations,
  decoration and archaeology are deleted on sight, found by the medium
  (`mentl query src/main.mn unreachable`, `census`, `mentl verify`).
- **Source edits go through the Edit tool**, so the post-edit hook audits each
  one; a shell write to `.mn` source is refused.

## The loop

1. Ground: `bash tools/state.sh --quick`, then ask the medium about every
   file the landing touches.
2. Build the whole landing in `.mn`. Hardest piece first; a dependency the
   form needs is built in the same arc, never handed back as a question.
3. Prove it: `mentl check src/main.mn` clean, `mentl fmt --check src lib`,
   then `bash tools/state.sh` — micros, the fixed-point march, frontier,
   crown, proof-exactness and the rest, one scoreboard. RED first: a new
   fixture or bound is measured failing on the pinned boot before the change.
4. When the wheel moved: `MARCH_REPIN=1 bash tools/march.sh`, then write the
   one narrative line in `boot/PROVENANCE.md`.
5. Commit on main through the hooks and push. No branches, no pull requests
   unless asked.

## No unfinished work

- **A landing is committed whole.** No "first pin", no "remaining" list, no
  record of a landing that did not land: an arc too large for one commit is
  split into landings each whole in itself, and each is a PLAN §11 item.
- **PLAN §11 is the only list of open work.** A gap found inside the arc is
  fixed inside the arc; nothing is parked anywhere else.
- **A gate is obeyed, never satisfied.** When a gate goes red, the work is
  what it measures. The obey gate refuses a raised ceiling, a dropped bound,
  a red leg declared expected, a silenced gate and a partial landing claimed;
  deleting the symptom where its cause is fixable is the same move.
- **The artifact is the refuter.** Measure before asserting a cause; when the
  cause is unmeasured, build the instrument. Agents are dispatched only for
  breadth (reading, fixtures), with the model passed explicitly, never to
  review a design or a document.

## The forms

The five verbs — name the topology of every flow, in code and in prose:
`|>` sequential · `<|` one input fanned to branches · `><` independent
pipelines · `~>` the handler governing everything to its left · `<~` feedback.
`|>` is never optional: `y |> f |> g`, never `let x = f(y); g(x)`.

The eight questions at every cursor: **Graph** (does an edge already carry
this?) · **Handler** (which handler projects it, with what resume
cardinality?) · **Verb** · **Row** (`+ - & ! Pure`) · **Ownership**
(`own`/`ref`) · **Refinement** · **Gradient** (what annotation unlocks a
capability?) · **Reason** (what edge does the Why walk follow?).

The drift tells, each the one law broken: a closure as a vtable · scope as a
frame stack · effect names as flat strings · a handler chain as a monad stack
· `__closure`/`__ev` beside each other instead of one state · a primitive
special-cased because it is small · N parallel lists where one record was
native · a flag as an int (`mode == 0/1/2`) · claiming done with sub-handles
uncommitted · a `_ =>` arm fabricating a value.

Red flags — stop and restructure: "for now" · "a later pass" · "the smallest
correct change" (sufficient is not ultimate) · "ultimate form reachable now"
(the target lowered) · "option A vs the safer option B" (decide it) · "look X
up by name" when an edge connects it · a fix that adds code to compensate
rather than deleting what made the compensation necessary.

## Conventions

- Never attribute Claude in commits; no model identifiers in any artifact.
- Comments state what IS and why, in the developer's voice; a backticked name
  is an edge and must resolve. History is git's.
- Shell commands that run wheel-scale work (the march, the board) run one at
  a time.
