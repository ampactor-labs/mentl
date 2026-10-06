# Mentl Design System

> *The medium, made visible.*
>
> Mentl is one read at a position, projected. This design system is that read
> projected onto pixels, type, color and motion, so that the way Mentl LOOKS is
> the same truth as the way Mentl WORKS.

**Status:** trued 2026-10-05 against the built page (`ide/`). The tokens have
ONE home, `ide/tokens.css`; this document is the rationale behind them and the
record of what was decided against. The interaction architecture is
`docs/MENTL_SPACE.md`, which assumes this file. Both are design artifacts of the
felt aspect (PLAN §5.2, band M), not read-path: interrogate them, never absorb.

---

## 0 · In five lines

1. **Mentl is a medium, not a tool.** One graph, two operations (draw an edge,
   project). Every pixel is a projection of a proven fact, or it does not
   render.
2. **There is no character in the product.** The brand's geometry is the
   octagon: the eight aspects of the one read, at its vertices. The mark is a
   geometric glyph; the octopus survives as illustration in prose, never as a
   presence in the editor.
3. **Color is a projection of the kernel.** The Okabe–Ito palette, one hue per
   kernel role, measured for contrast on both grounds by a script in the gate.
4. **Density lives ON the code**, scaled by the computed degree of interest
   (never a knob), layered on the text
   (gutter, inline marks, overlays), never as more panels.
5. **The hero is Mentl Space**: the fixpoint compiler itself, unmodified, in a
   browser worker. No server, no toolchain, no chatbot.

The sentence to keep on the monitor:

> **Errors are invitations, not scoldings. The medium surfaces only what it
> has proven. It is on the developer's side.**

---

## 1 · What Mentl is, in design terms

- **The program is a graph of meaning**, not a pile of files; text is one
  projection of it. The **cursor** is where attention is, and at every
  position the medium reads the graph eight ways.
- **The compiler IS the intelligence.** No prompt box, no spinner of guesses.
  Where a tool approximates, Mentl proves; approximation has a ceiling, proof
  has none. Design must never make Mentl look like a chat bolted onto an
  editor — the vocabulary rule in §7 is a correctness stance.
- **It runs in the browser.** `boot/mentl.wasm`, the pinned fixpoint, judges
  in a worker; the session keeps its graph; a caret read answers in tens of
  milliseconds and nothing leaves the page.

The eight aspects, as the page names them (one row of the ring each, §6):

| Aspect | Kernel arm | What it answers at the caret |
|---|---|---|
| **graph** | Graph + Env | the node's type, with its lede (the prose attached to it) |
| **propose** | Handlers | a `??`'s proven survivor, or which install serves a perform |
| **topology** | the five verbs | the verb path from the enclosing declaration |
| **effects** | the Boolean row | what evaluating the node performs; for a function, what calling it performs |
| **ownership** | ownership | `own` / `ref`, inferred or declared |
| **verify** | refinement | every open obligation inside the node |
| **teach** | the gradient | the one annotation worth adding, proven first |
| **why** | Reasons | the Reason chain back to where the fact was minted |

---

## 2 · Brand essence

**Calm, exact, on the developer's side.** The confidence of something that
already did the hard part and shows its receipts.

- **Classy** — obsidian and gold, generous space, restraint. Never neon,
  never gradient-mesh, never busy.
- **Honest** — it shows only what is true. No dark patterns, no urgency, no
  magic. The brand's trust comes from never overstating; a third colour for
  "not yet provable" (§8) is this dial applied to a proof.
- **On your side** — a refusal reads as an opening: *here is a way through*,
  never *you did it wrong*.
- **Alive, quietly** — proven things SURFACE from the deep (one motion, §4.5);
  nothing breathes, pulses or fidgets for its own sake.
- **Precise** — the voice narrates in the second person with the fact and its
  address; wit lives in a tooltip, never in the way.

| Mentl is | Mentl is not |
|---|---|
| a medium, a collaborator, an oracle | a tool, a copilot, an assistant |
| warm obsidian + gold + parchment | cold slate + electric purple + neon |
| proven, deterministic, calm | probabilistic, guessing, hype |
| geometric, legible at favicon scale | a mascot, a persona, a mood |
| quiet until it has something proven | notification-happy, interruptive |

**The two-voice principle.** Wherever text appears about code, two voices
speak and never a third: the **author's** — the `//` prose, graph content, the
first line of it rendered as the node's lede — and **the medium's** —
substrate-derived narration. The page distinguishes them by type alone: the
author's prose in the sans, italic; the medium's facts in the mono (§4.2). No
glyph, no avatar, no "the system says".

**What was decided against, and why** (2026-10-05, each a measured verdict):

| Was | Now | Why |
|---|---|---|
| An octopus character (She/Her, five expressive states, "a corner of the IDE") | no character in the product; the mark is a geometric glyph; the octopus is illustration in docs only | a persona with moods contradicts "surfaces only what it has proven"; no surviving serious tool has a character in its editing surface; pixels carrying zero facts are what the density law forbids |
| The `??` socket as a custom-font ligature (a derived mono with 17 glyphs) | the socket as a SHAPE in the chrome (CSS clip); the text stays two ASCII characters | source must render identically in every editor, diff and terminal, or the page lies about the file; a typeface is a licensing and maintenance project |
| The chakana (stepped cross) as the icon and grid grammar | the octagon ring is the one geometry | a sacred symbol borrowed as texture says nothing true to a developer; the octagon says exactly what is true |
| Cursor breath, topology resist | gone | an animating caret burns attention for no fact; fighting the keyboard is the projectional editor's grave (the formatter projects on idle and save, never against the hand) |
| Grey tokens wearing brand names (the 2026-07-23 strip) | the semantic palette restored, both grounds | three greys for six roles deleted the information layer, not the decoration |
| Build / run chrome, link-runtime toggles | always live, always linked | the build-and-run mental model is the import MENTL_SPACE §9 refuses |

---

## 3 · The one geometry — the octagon

Everything in the system grows from one fact: **the kernel has eight aspects
of one read.** The octagon is that fact as a shape, and it is used in exactly
three places:

- **The mark.** An octagon ring — eight vertices, each in its aspect's hue
  when colour is available, one weight when it is not — with a hollow centre.
  It reads as a confident geometric glyph at favicon scale and as "the eight
  aspects around the read" at any larger one. Gold on obsidian, ink on
  parchment. The wordmark is `mentl space`, lowercase, in the code face.
- **The socket.** A `??` hole, the focus ring on a hole, the proposal strip's
  frame and every empty "a proven thing can land here" state are
  octagonal — `clip-path` on an ordinary element, never a glyph. The octagon
  is reserved for *an opening awaiting fulfilment*.
- **The ring.** The eight-aspect panel (§6) is the octagon unrolled into rows;
  the row's leading dot carries the aspect's hue.

Nothing else is eight-sided. The grid is 8 px because 8 px is a good grid,
not because of the kernel; the numerology stays out of the product.

---

## 4 · Foundations

### 4.1 · Color — the kernel's roles

**Two grounds, one accent family.** Obsidian (the editor's home) and parchment
(reading, docs, and the light theme of the page itself). The page follows
`prefers-color-scheme` and the ◐ control overrides it; both grounds ship in
the IDE, since a proof read in daylight is still a proof.

The accents are **the Okabe–Ito colorblind-safe set.** Accessibility is not a
constraint applied afterwards; it is the palette's reason for existing. The
six hues stay distinguishable under every common colour-vision deficiency, so
they are never swapped for prettier ones.

| Token (`ide/tokens.css`) | Kernel role — the semantic layer | Where the page uses it |
|---|---|---|
| `--gold` / `--gold-b` | **types and contracts; the cursor; Teach** — what is known or promised | type names, the `REAL` badge, the caret line, the trail |
| `--sky` / `--sky-b` | **the five verbs — topology** | `\|>` `<\|` `><` `~>` `<~`, the verb spines |
| `--blue` / `--blue-b` | **structure — keywords, the graph's skeleton** | `fn` `let` `match` `type` `effect` `handler` `with` |
| `--green` / `--green-b` | **computation — functions, handlers — propose** | declarations, the install that serves a perform |
| `--verm` / `--verm-b` | **boundaries — literals, `!`, the `??` socket, a refusal** | numbers, negation, holes, `E_*` lines |
| `--mag` / `--mag-b` | **discipline — `own` / `ref`, `resume`, `Pure`** | ownership markers, the resume keyword |
| `--wheat` | string literals (organic content) | strings |

Each hue has a base and a bright (`-b`) step; the on-ground variants (Okabe–Ito
was tuned for white, so `#0072B2` fails on obsidian and the page's blue is
`#2A8FC2`) live in the token file. Status colours are DERIVED from the same
roles — a refusal is vermillion, a narration gold, a proof green, a hint sky —
never new hues.

**Measured, not asserted.** `tools/contrast.py` reads the token file and
checks every text-on-ground pairing against WCAG: body text (primary, bright,
muted) at 4.5 and labels at 3.0, on canvas, raised and abyss, in both grounds.
The IDE gate runs it; a token that fails is a red gate, not a taste.

### 4.2 · Typography

Three faces, three jobs, all **self-hosted** under `ide/fonts/` (OFL; the
licences sit beside the files) — no font request leaves the page, so the page
works offline and on a stick.

1. **JetBrains Mono, ligatures OFF** — all code, the facets' facts, labels,
   the wordmark. The verb glyphs get colour and weight, never fused ligatures:
   the source must look the same in every editor, or the page lies about the
   file.
2. **Inter** — chrome, prose, the author's voice (italic), labels.
3. **Fraunces** — display only, for docs and marketing headings. Not loaded by
   the page.

Scale (1.25 major third at a 16 px base): 12 · 14 · 16 · 20 · 24 · 32 · 40 ·
60. Code line-height 1.5, prose 1.6, headings 1.15. The page's code sits at
13 px / 1.55 so a 60k-line wheel module stays legible in a half-width pane.

### 4.3 · Space

An 8 px base unit, with a 4 px half step: 0 · 4 · 8 · 16 · 24 · 32 · 48 · 64 ·
96 · 128. Generous negative space is the register; the three layers of the
page (§8) meet on hairlines, never on boxes.

### 4.4 · Radius, depth, elevation

The metaphor is **the deep**: chrome is the abyss; useful things SURFACE
toward the reader, gaining lightness as they rise.

- Radius 6 / 10 / 16 / full. **The octagonal clip** is the one exception,
  reserved for sockets (§3).
- Depth on obsidian is expressed by lightening the ground (`--abyss` →
  `--canvas` → `--raised1` → `--raised2` → `--raised3`) plus a 1 px
  `--border` hairline and, on the most-surfaced interactive layer, a faint
  gold glow (`--glow-gold`) rather than a drop shadow.
- The **holographic layer** — proposed, not yet real — renders translucent and
  slightly luminous; on Tab it snaps to full opacity. The proposal strip at a
  `??` is this layer.

### 4.5 · Motion

Motion expresses one truth: **a proven thing arrives.** It is never
decorative.

| Motion | Meaning | Spec |
|---|---|---|
| **Surfacing** | a proven fact rises into a facet row | translate-up 8 px + fade-in; `220 ms cubic-bezier(.16, 1, .3, 1)` (`--e-surface`) |
| **Ghost materialize** | a proposal assembles at the socket | translucent fill; `180 ms` |
| **Tab-snap** | the proposal becomes real | opacity to full, one crisp settle; `120 ms` |
| **The Why walk** | provenance drawn along the path | an ink line extends hop by hop; `300 ms` |
| **Cursor jump** | the argmax moved | a smooth ease to the new position; `400 ms`, never a teleport |

Deleted on 2026-10-05: *cursor breath* (a perpetually animating caret) and
*topology resist* (elastic snap-back against the hand). Under
`prefers-reduced-motion` everything above degrades to opacity or instant;
nothing essential is motion-only.

### 4.6 · Iconography

Geometric line icons, 1.5–2 px optical stroke, 24 px artboard, 8 px safe
margin. The **eight aspect marks** are the ring's dots and, at high Teach, the
gutter's aspect-strip cells (§8) — each in its role's hue, together forming the
octagon ring that is the "all eight" mark. The file icon is the ring in gold on
obsidian.

### 4.7 · Tokens

The machine-readable tokens are **`ide/tokens.css`** — the `:root` block for
obsidian, the parchment overrides under `prefers-color-scheme: light` and
`[data-theme="parchment"]`, the font faces. They are not repeated here: a
second copy is the drift this document exists to refuse. `tools/contrast.py`
is their measurement.

---

## 5 · The five-verb visual language

This is what nothing else has. Mentl programs are built from five **verbs**,
and the verbs draw the program's shape on the page. The page renders them
faithfully: the formatter's canon is SYNTAX's, and `mentl fmt` projects it on
idle and on save, never against a keystroke.

| Verb | Name | Shape | Colour |
|---|---|---|---|
| `\|>` | sequential | A then B, down the left edge | sky |
| `<\|` | divergent | one input fans to parallel branches | sky |
| `><` | parallel | independent pipelines at the indented centre | sky |
| `~>` | handler | the foot governs the whole chain to its left | sky |
| `<~` | feedback | the output loops back as the next input | sky |

**In the canvas** faint sky spines connect the stages of a chain so a pipeline
reads as the diagram it is. The spines are drawn from the compiler's Topology
facet (the verb path at the caret), never from a regular expression over
leading glyphs — the page keeps no second parser (MENTL_SPACE §2).

**The `??` socket** is the sixth signature glyph: an opening, productive under
error. It renders as the two characters in vermillion inside an octagonal
frame, never as a red squiggle; the proposal strip beside it is the
holographic layer.

---

## 6 · The eight-aspect ring, as built

At any caret the compiler's address projection (`mentl <file>:<line>:<col>`)
prints the facets it has something true to say about, and the page renders
them as rows of ONE panel:

```
●  graph      REAL   greet builds a line and flows it into print_string …      ← the lede, the author's voice
                     fn greet(name) = … : (name: String own — inferred) -> () with Memory + Alloc
●  propose    REAL   a ?? here is where the medium proposes; a perform says which install serves it
●  topology   REAL   no verb holds this node
●  effects    REAL   Memory + Alloc  when called
●  ownership  REAL   own
●  verify     REAL   no open obligation at this node
●  teach      REAL   add `with !Alloc` — locks …
●  why        REAL   ownership-resolved params of 'greet', at main:29
```

Each row: the aspect's dot in its hue, the label, a **provenance badge**
(`REAL` — the compiler answered it; `SURFACE` — a token-level guess before the
first read; `SOCKET` — a hole's row), the fact. The label column is one grid
column for the whole ring, sized by its widest label and badge, so no badge
ever runs into a fact. A row whose aspect has nothing to say at this node
says so in the author's register (italic sans), never with an empty line.
Eight facets, not eight alarms: the panel is serene by construction, because
the compiler printed only what it proved.

---

## 7 · Voice & tone

Mentl's product copy is **substrate-honest**. The product never speaks like a
chatbot, because it is not one.

**Forbidden vocabulary (user-facing):** "AI", "agent", "assistant", "chatbot",
"prompt", "completion", "model", "training", "hallucination" (except to
refute), and the hedges that mask a missing fact — "may want to", "might
consider", "perhaps".

| Don't say | Say |
|---|---|
| "AI suggests…" | "the medium proposes…" / "the gradient surfaces…" |
| "the model thinks…" | "the medium proved…" / "the fan found…" |
| "autocomplete" | "a proven proposal" / "the socket fills" |
| "it might be wrong" | (the unproven is never surfaced, so this never occurs) |
| "error: you did X wrong" | "this path performs `Alloc` under `!Alloc` — two proven ways through" |

The voice is **second person, present tense, with the address**: *"`Alloc`
cannot run under `!Alloc` here. Two proven ways through — Tab takes one."*
Never first person — there is no one speaking, there is a graph being read.

Empty state of the canvas: *"Type a program. What the medium can prove of it
appears beside it."* After a proof: *"Verified: `0 <= self && self <= 100`
holds on every path."* A Teach step: *"`with !Alloc` locks this real-time
safe; the body already proves it."*

---

## 8 · Mentl Space — the surface

> The interaction architecture is `docs/MENTL_SPACE.md`; the sequence that
> builds the rest is PLAN §11 (the Space pivot). This section is what the page
> IS today and the two layers it grows next.

**Two layers around the code, as built:**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ ◯ mentl space   [ 00 · hello ▾ ]                                              ◐ │
├──────────────────────────────────────────────┬───────────────────────────────┤
│ 17  // Read it: mentl lib/tutorial/…:29:77     │ ASPECT RING            kw: fn │
│ 19  import io                                  │ ● graph     REAL  …           │
│ 29  fn greet(name) = "Hello, " ++ name … |> … │ ● propose   REAL  …           │
│ 31  fn main() = {                              │ ● topology  REAL  …           │
│ 32    greet("kernel")                          │ … effects · ownership · verify │
│                                                │   · teach · why               │
│   the canvas: a textarea under the highlight   ├───────────────────────────────┤
│   layer, line numbers, the verb spines         │ Lens ⓪ · Ledger               │
│                                                │   ✓ clean — the graph is      │
│                                                │     coherent                  │
└──────────────────────────────────────────────┴───────────────────────────────┘
```

1. **The Canvas (centre)** — the program in its kernel colours over a plain
   textarea (the keyboard is never taken), line numbers, the verb spines. An
   edit sends the changed text with the caret's address to the resident
   session, which re-judges the moved cone and answers the facets and the
   diagnostics in one reply (~100 ms); a caret move is a read of the graph the
   session holds (~20 ms). The emitted module is rendered on demand.
2. **The rail (right)** — the **Aspect ring** (§6) above the **Lens** (every
   banked diagnostic as the kind it is at its own site, the caret's module
   first and the linked modules folded under a count, the lead sentence the
   wheel's own; click to jump — cost lines never enter the View) and the
   **Ledger** (the declarations nearest the caret by the graph's proximity,
   the open obligations, the tightenings). The Why chain is the ring's eighth
   facet. Every row is a fact of the View the wheel renders (`mentl space
   <file>:<line>[:<col>]`, src/space.mn); the page paints and never parses.

Density is **computed**, never configured: each fact scores a degree of
interest from the caret (docs/MENTL_SPACE.md §3), and the knob, the status
bar, the footer, the Wavefront strip and the Module pane are gone. The
**programs** are the lessons in `lib/tutorial/`, the projects the manifest
lists (`project <dir>`, or `mentl space <dir>`) and the developer's drafts,
kept in the browser; there is no sample-code dropdown that warns about itself.

**The next two layers, named (PLAN §11, L-D and L-E):** the **aspect strip** —
at high Teach, eight one-character gutter cells per line, one per aspect in its
hue (the effects cell is the ambient-world glyph: hollow = this line REQUIRES
the effect, filled = the world GRANTS it, a hollow with no filled twin IS the
refusal, drawn before the call is finished); and the **Severance Map** — the
module tree banded in THREE colours, provably absent / present / NOT YET
PROVABLE, the third counted and ratcheting to zero, with the cut line where the
`~>` goes. A two-colour map would be the lie; the three-colour map is the
instrument.

**The feeling to design for.** No spinner of guesses, no chat. You change a
constraint and the facts beside the code change, provably, in front of you.
That moment is the entire pitch.

---

## 9 · Other surfaces (sketched)

- **The terminal** — `mentl <file:line:col>` prints the same facets the ring
  renders; `mentl where`, `why`, `query` are the ring's rows as verbs. Warm
  and sparse: the obsidian palette in ANSI.
- **Editors over LSP** — the Obsidian theme as the canonical VS Code theme;
  hover and the code actions carry the facets.
- **Docs** — parchment ground, Fraunces display, the code face for code, the
  octagon ring for "all eight" moments. Two-voice rendering of annotated code.
- **Landing** — the live page IS the landing; the five-verb glyphs as the hook,
  the proof-has-no-ceiling thesis stated plainly. Never a feature-grid
  template.

---

## 10 · Accessibility (non-negotiable)

- **Colorblind-safe by birth** — the Okabe–Ito set, never broken for looks.
- **Never colour alone** — every coloured state also carries a glyph, a
  position or text (a refusal is the socket shape and the Lens line; a badge
  is a word).
- **Contrast measured** — `tools/contrast.py` in the IDE gate, both grounds.
- **Motion** — opacity-only or instant under `prefers-reduced-motion`.
- **Keyboard-first** — Tab accepts the proven proposal at a socket; the ring's
  rows are doors; nothing needs a pointer.
- **Local-first** — the page registers a service worker that keeps every file
  it fetched, so it opens again offline; no account, no server.

---

## 11 · Design drift (do / don't)

| Don't (drift) | Do (substrate-honest) |
|---|---|
| cold slate + electric purple / neon | warm obsidian + gold + parchment |
| a colour because it looks nice | the hue that MEANS the role |
| red squiggles, scoldings | octagonal sockets, invitations |
| a chat panel, a prompt box, a sparkle button | the socket, the gradient, proven ghost text |
| a mascot that interrupts and guesses | nothing until it is proven; then it surfaces |
| drop shadows for depth | a lighter ground and a faint glow |
| decorative gradients, mesh blobs | the octagon ring, the verb spines |
| generic `->` arrows in diagrams | the five real verbs drawing real shapes |
| "Save / Build / Run" as the mental model | one live program; a hole is a suspension point |
| a library's parser in the page | the compiler's own tokens and spans |
| loud, busy, notification-happy | calm, spacious, proven |

---

## 12 · What to make next

1. **The mark** — the octagon ring (§3), favicon → wordmark → lockup, gold on
   obsidian and ink on parchment.
2. **The aspect strip** and the **ambient-world glyphs** in the gutter (§8).
3. **The Severance Map** page with its three-colour law and its count on the
   board.
4. **The eight aspect marks** as an icon family.
5. **The docs' parchment** as a reading surface from the same tokens.

Everything traces back to `ide/tokens.css` and the keystone:

> **Color, type, layout and motion are projections of the kernel. The design
> system is a handler on the same graph as the language. Make the way Mentl
> looks be the same truth as the way Mentl works.**
