# Mentl Design System

> Everything Mentl shows is a projection of one read of its graph at a
> position. This design system projects the same read onto pixels, type, color
> and motion, so that how Mentl looks matches how Mentl works.

**Status:** checked against the built page (`ide/`) on 2026-10-05. The tokens
live in one place, `ide/tokens.css`; this document gives the reasons behind
them and records what was decided against. The interaction architecture is in
`docs/MENTL_SPACE.md`, which assumes this file. Both are design documents for
Mentl's felt aspect, the part a person works with directly (PLAN §5, FELT).
Neither is required reading. Question them rather than accept them as settled.

---

## 0 · In five lines

1. Mentl is a medium, not a tool. It has one graph and two operations (draw an
   edge, project). Every pixel is a projection of a proven fact, or it is not
   rendered.
2. There is no character in the product. The brand's shape is the octagon,
   with the eight aspects of the one read at its vertices. The mark is a
   geometric glyph. The octopus remains only as an illustration in prose,
   never as a presence in the editor.
3. Color is a projection of the kernel. The palette is Okabe-Ito, with one hue
   per kernel role, and a script in the gate measures its contrast on both
   grounds.
4. Detail is drawn on the code itself, layered on the text (gutter, inline
   marks, overlays) rather than in more panels, and how much is drawn follows
   the computed degree of interest, never a knob.
5. The centerpiece is Mentl Space: the fixpoint compiler itself, unmodified,
   running in a browser worker, with no server, no toolchain and no chatbot.

The principle to keep in mind:

> An error message shows a way forward and never blames the developer. The
> medium shows only what it has proven. The product is designed to help the
> developer.

---

## 1 · What Mentl is, in design terms

- The program is a graph of meaning, not a pile of files, and text is one
  projection of it. The **cursor** marks where attention is, and at every
  position the medium reads the graph in eight ways.
- All the intelligence comes from the compiler. There is no prompt box and no
  spinner while guesses are generated. Where other tools approximate, Mentl
  proves; an approximation can only get so good, and a proof has no such
  limit. The design must never make Mentl look like a chat bolted onto an
  editor, so the vocabulary rule in §7 is a matter of correctness.
- It runs in the browser. `boot/mentl.wasm`, the pinned fixpoint, judges the
  program in a worker, and the session keeps its graph. A caret read answers
  in tens of milliseconds, and nothing leaves the page.

The page names the eight aspects as follows (each is one row of the ring, §6):

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

The brand is calm and exact, and the product is built to help the developer.
It should look like a product that has already done the hard part and can
show its evidence.

- **Classy**: obsidian and gold, generous space, restraint. Never neon, never
  a gradient mesh, never busy.
- **Honest**: it shows only what is true. No dark patterns, no urgency, no
  magic. People trust the brand because it never overstates, and the third
  colour for "not yet provable" (§8) applies the same rule to a proof.
- **Helpful**: a refusal reads as an opening (*here is a way through*), never
  as blame (*you did it wrong*).
- **Quiet motion**: proven things rise to the surface (one motion, §4.5), and
  nothing animates for its own sake.
- **Precise**: the copy is written in the second person and gives the fact and
  its address. Any wit goes in a tooltip, never in the way.

| Mentl is | Mentl is not |
|---|---|
| a medium, a collaborator, an oracle | a tool, a copilot, an assistant |
| warm obsidian + gold + parchment | cold slate + electric purple + neon |
| proven, deterministic, calm | probabilistic, guessing, hype |
| geometric, legible at favicon scale | a mascot, a persona, a mood |
| quiet until it has something proven | notification-happy, interruptive |

**The two-voice principle.** Wherever text about code appears, it comes from
one of two voices and never a third: the **author's** (the `//` prose, which is
graph content, with its first line rendered as the node's lede) and **the
medium's** (text derived from the substrate). The page marks the difference by
typeface alone: the author's prose in the sans, italic, and the medium's facts
in the mono (§4.2). There is no glyph, no avatar and no "the system says".

**What was decided against, and why** (2026-10-05, each decision based on a
measurement):

| Was | Now | Why |
|---|---|---|
| An octopus character (She/Her, five expressive states, "a corner of the IDE") | no character in the product; the mark is a geometric glyph; the octopus is illustration in docs only | a persona with moods contradicts "surfaces only what it has proven"; no surviving serious tool has a character in its editing surface; pixels carrying zero facts are what the density law forbids |
| The `??` socket as a custom-font ligature (a derived mono with 17 glyphs) | the socket as a shape in the chrome (CSS clip); the text stays two ASCII characters | source must render identically in every editor, diff and terminal, or the page misrepresents the file; a typeface is a licensing and maintenance project |
| The chakana (stepped cross) as the icon and grid grammar | the octagon ring is the one geometry | a sacred symbol borrowed as decoration conveys nothing true to a developer; the octagon conveys exactly what is true |
| Cursor breath, topology resist | gone | an animated caret draws attention without showing any fact; overriding the keyboard is why projectional editors failed (the formatter projects when you pause and when you save, never against your typing) |
| Grey tokens with brand names (the 2026-07-23 strip) | the semantic palette restored, on both grounds | three greys for six roles deleted the information layer, not the decoration |
| Build / run chrome, link-runtime toggles | always live, always linked | the build-and-run mental model is the imported pattern that MENTL_SPACE §9 rejects |

---

## 3 · The one geometry — the octagon

The whole visual system starts from one fact: the kernel has eight aspects of
one read. The octagon draws that fact as a shape, and it is used in exactly
three places:

- **The mark.** An octagon ring with a hollow centre and eight vertices, each
  in its aspect's hue when colour is available and all in one weight when it
  is not. At favicon size it reads as a clear geometric glyph, and at any
  larger size as "the eight aspects around the read". It is gold on obsidian,
  or ink on parchment. The wordmark is `mentl space`, lowercase, in the code
  face.
- **The socket.** A `??` hole, the focus ring on a hole, the proposal strip's
  frame and every empty "a proven thing can land here" state are octagonal,
  drawn with `clip-path` on an ordinary element, never with a glyph. The
  octagon is reserved for an opening waiting to be filled.
- **The ring.** The eight-aspect panel (§6) is the octagon laid out as rows,
  and each row's leading dot carries the aspect's hue.

Nothing else is eight-sided. The grid is 8 px because 8 px is a good grid
size, not because of the kernel; the product gives the number eight no other
meaning.

---

## 4 · Foundations

### 4.1 · Color — the kernel's roles

There are two grounds and one family of accents. Obsidian is the editor's
default ground, and parchment is for reading, for docs and for the light theme
of the page itself. The page follows `prefers-color-scheme`, and the ◐ control
overrides it. Both grounds ship in the IDE, because people also read proofs in
daylight.

The accents are the Okabe-Ito colorblind-safe set. The palette was chosen for
accessibility from the start, rather than adjusted for it afterwards. Its six
hues stay distinguishable under every common colour-vision deficiency, so they
are never swapped for prettier ones.

| Token (`ide/tokens.css`) | Kernel role (the semantic layer) | Where the page uses it |
|---|---|---|
| `--gold` / `--gold-b` | **types and contracts; the cursor; Teach**: what is known or guaranteed | type names, the `REAL` badge, the caret line, the trail |
| `--sky` / `--sky-b` | **the five verbs: topology** | `\|>` `<\|` `><` `~>` `<~`, the verb spines |
| `--blue` / `--blue-b` | **structure: keywords, the graph's skeleton** | `fn` `let` `match` `type` `effect` `handler` `with` |
| `--green` / `--green-b` | **computation: functions, handlers; propose** | declarations, the install that serves a perform |
| `--verm` / `--verm-b` | **boundaries: literals, `!`, the `??` socket, a refusal** | numbers, negation, holes, `E_*` lines |
| `--mag` / `--mag-b` | **discipline: `own` / `ref`, `resume`, `Pure`** | ownership markers, the resume keyword |
| `--wheat` | string literals (organic content) | strings |

Each hue has a base and a bright (`-b`) step. The variants tuned for each
ground live in the token file (Okabe-Ito was tuned for white, so `#0072B2`
fails on obsidian, and the page's blue is `#2A8FC2`). Status colours are
derived from the same roles (a refusal is vermillion, a narration gold, a
proof green, a hint sky) and never add new hues.

Contrast is measured, not asserted. `tools/contrast.py` reads the token file
and checks every pairing of text and ground against WCAG: body text (primary,
bright, muted) at 4.5 and labels at 3.0, on canvas, raised and abyss, on both
grounds. The IDE gate runs it, so a token that fails turns the gate red; it is
not a matter of taste.

### 4.2 · Typography

Each of the three typefaces has one job. All three are self-hosted under
`ide/fonts/` (OFL; the licences sit beside the files), so no font request
leaves the page, and the page works offline and from a USB stick.

1. **JetBrains Mono, ligatures off**: all code, the facets' facts, labels, the
   wordmark. The verb glyphs get colour and weight but never fused ligatures,
   because the source must look the same in every editor or the page
   misrepresents the file.
2. **Inter**: chrome, prose, the author's voice (italic), labels.
3. **Fraunces**: display only, for docs and marketing headings. The page does
   not load it.

The type scale is a 1.25 major third on a 16 px base: 12 · 14 · 16 · 20 · 24 ·
32 · 40 · 60. Line height is 1.5 for code, 1.6 for prose and 1.15 for
headings. The page sets code at 13 px / 1.55 so that a 60k-line wheel module
stays legible in a half-width pane.

### 4.3 · Space

The base unit is 8 px, with a 4 px half step: 0 · 4 · 8 · 16 · 24 · 32 · 48 ·
64 · 96 · 128. The layout uses generous empty space, and the three layers of
the page (§8) are separated by hairlines, never by boxes.

### 4.4 · Radius, depth, elevation

The visual model is **the deep**: the chrome is the abyss, and useful things
rise toward the reader, getting lighter as they rise.

- Radius 6 / 10 / 16 / full. The octagonal clip is the one exception,
  reserved for sockets (§3).
- On obsidian, depth is shown by lightening the ground (`--abyss` →
  `--canvas` → `--raised1` → `--raised2` → `--raised3`), plus a 1 px
  `--border` hairline and, on the topmost interactive layer, a faint gold glow
  (`--glow-gold`) instead of a drop shadow.
- The **holographic layer** (proposed, not yet real) renders translucent and
  slightly luminous, and on Tab it snaps to full opacity. The proposal strip
  at a `??` is this layer.

### 4.5 · Motion

Motion shows one event only: a proven thing arriving. It is never decorative.

| Motion | Meaning | Spec |
|---|---|---|
| **Surfacing** | a proven fact rises into a facet row | translate-up 8 px + fade-in; `220 ms cubic-bezier(.16, 1, .3, 1)` (`--e-surface`) |
| **Ghost materialize** | a proposal assembles at the socket | translucent fill; `180 ms` |
| **Tab-snap** | the proposal becomes real | opacity to full, one crisp settle; `120 ms` |
| **The Why walk** | provenance drawn along the path | an ink line extends hop by hop; `300 ms` |
| **Cursor jump** | the argmax moved | a smooth ease to the new position; `400 ms`, never a teleport |

Deleted on 2026-10-05: *cursor breath* (a caret that animated all the time)
and *topology resist* (an elastic snap-back against the user's input). Under
`prefers-reduced-motion`, everything above falls back to an opacity change or
an instant change, and nothing essential is shown only through motion.

### 4.6 · Iconography

Icons are geometric line icons with a 1.5 to 2 px optical stroke, a 24 px
artboard and an 8 px safe margin. The **eight aspect marks** are the ring's
dots and, at high Teach, the gutter's aspect-strip cells (§8). Each is in its
role's hue, and together they form the octagon ring that is the "all eight"
mark. The file icon is the ring in gold on obsidian.

### 4.7 · Tokens

The machine-readable tokens are in `ide/tokens.css`: the `:root` block for
obsidian, the parchment overrides under `prefers-color-scheme: light` and
`[data-theme="parchment"]`, and the font faces. They are not repeated here,
because a second copy is exactly the drift this document is meant to prevent.
`tools/contrast.py` measures them.

---

## 5 · The five-verb visual language

Nothing else has this visual language. Mentl programs are built from five
**verbs**, and the verbs set the program's shape on the page. The page renders
them exactly: the formatter's canonical layout is the one SYNTAX defines, and
`mentl fmt` projects it when you pause and when you save, never against a
keystroke.

| Verb | Name | Shape | Colour |
|---|---|---|---|
| `\|>` | sequential | A then B, down the left edge | sky |
| `<\|` | divergent | one input fans to parallel branches | sky |
| `><` | parallel | independent pipelines at the indented centre | sky |
| `~>` | handler | the foot governs the whole chain to its left | sky |
| `<~` | feedback | the output loops back as the next input | sky |

In the canvas, faint sky spines connect the stages of a chain, so a pipeline
reads as the diagram it is. The spines are drawn from the compiler's Topology
facet (the verb path at the caret), never from a regular expression over
leading glyphs, because the page keeps no second parser (MENTL_SPACE §2).

The `??` socket is the sixth signature glyph: an opening that keeps the
program productive under error. It renders as the two characters in
vermillion inside an octagonal frame, never as a red squiggle, and the
proposal strip beside it is the holographic layer.

---

## 6 · The eight-aspect ring, as built

At any caret, the compiler's address projection (`mentl <file>:<line>:<col>`)
prints each facet for which it has a true fact, and the page renders them as
the rows of one panel:

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

Each row shows the aspect's dot in its hue, the label, a **provenance badge**
(`REAL`: the compiler answered it; `SURFACE`: a token-level guess before the
first read; `SOCKET`: a hole's row) and the fact. The label column is one grid
column for the whole ring, sized by its widest label and badge, so no badge
ever runs into a fact. When an aspect has no fact at this node, its row states
that in the author's register (italic sans), never with an empty line. The
ring shows eight facets, not eight alarms, and the panel stays visually quiet
because the compiler printed only what it proved.

---

## 7 · Voice & tone

Mentl's product copy is **substrate-honest**: it describes only what the
underlying system actually does. The product's text never reads like a
chatbot's, because the product is not a chatbot.

**Forbidden vocabulary (user-facing):** "AI", "agent", "assistant", "chatbot",
"prompt", "completion", "model", "training", "hallucination" (except to
refute it), and the hedges that hide a missing fact: "may want to", "might
consider", "perhaps".

| Don't say | Say |
|---|---|
| "AI suggests…" | "the medium proposes…" / "the gradient surfaces…" |
| "the model thinks…" | "the medium proved…" / "the fan found…" |
| "autocomplete" | "a proven proposal" / "the socket fills" |
| "it might be wrong" | (the unproven is never surfaced, so this never occurs) |
| "error: you did X wrong" | "this path performs `Alloc` under `!Alloc`. Two proven ways through" |

The voice is **second person, present tense, with the address**: *"`Alloc`
cannot run under `!Alloc` here. Two proven ways through: Tab takes one."*
It is never first person, because no one is speaking; the text is a read of
the graph.

Empty state of the canvas: *"Type a program. What the medium can prove of it
appears beside it."* After a proof: *"Verified: `0 <= self && self <= 100`
holds on every path."* A Teach step: *"`with !Alloc` locks this real-time
safe; the body already proves it."*

---

## 8 · Mentl Space — the surface

> The interaction architecture is in `docs/MENTL_SPACE.md`, and the order in
> which the rest gets built is PLAN §11 (the Space pivot). This section
> describes what the page is today and the two layers it adds next.

Two layers sit around the code today:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ ◯ mentl space   [ 00 · hello ▾ ]                                              ◐ │
├──────────────────────────────────────────────┬───────────────────────────────┤
│ 17  // Read it: mentl examples/pulse/course/…  │ ASPECT RING            kw: fn │
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

1. **The Canvas (centre)**: the program in its kernel colours over a plain
   textarea (the page never takes over the keyboard), with line numbers and
   the verb spines. An edit sends the changed text, with the caret's address,
   to the resident session, which re-judges the cone the edit changed and
   returns the facets and the diagnostics in one reply (~100 ms). Moving the
   caret reads the graph the session holds (~20 ms). The emitted module is
   rendered on demand.
2. **The rail (right)**: the **Aspect ring** (§6) above the **Lens** and the
   **Ledger**. The Lens lists every banked diagnostic as the kind it is, at its
   own site, with the caret's module first and the linked modules folded under
   a count. Its lead sentence is the wheel's own, and clicking an entry jumps
   to it; cost lines never enter the View. The Ledger shows the declarations
   nearest the caret by the graph's proximity, the open obligations and the
   tightenings. The Why chain is the ring's eighth facet. Every row is a fact
   of the View the wheel renders (`mentl space
   <file>:<line>[:<col>]`, src/space.mn); the page paints and never parses.

How much the page shows is computed, never configured: each fact gets a
degree-of-interest score from the caret (docs/MENTL_SPACE.md §3), and the
knob, the status bar, the footer, the Wavefront strip and the Module pane are
gone. The programs are the projects the manifest lists (Pulse's renderer, the
course's lessons in `examples/pulse/course`, Wasatch's score; `project <dir>`,
or `mentl space <dir>`) and the developer's drafts, kept in the browser. There
is no sample-code dropdown that warns about itself.

**The next two layers, named (PLAN §11, L-D and L-E):** the **aspect strip**
and the **Severance Map**. The aspect strip shows, at high Teach, eight
one-character gutter cells per line, one per aspect in its hue. Its effects
cell is the ambient-world glyph: hollow means this line requires the effect,
filled means the world grants it, and a hollow with no filled twin is the
refusal, drawn before the call is finished. The Severance Map shows the module
tree in three colour bands (provably absent, present, not yet provable), with
the third band counted on a limit that only goes down, to zero, and with the
cut line where the `~>` goes. A map with two colours would misstate what is
proven; the third colour is what makes the map accurate.

The experience to design for: there is no spinner while guesses are made, and
there is no chat. You change a constraint, and the facts beside the code
change in front of you, each one proven. That moment is the whole pitch.

---

## 9 · Other surfaces (sketched)

- **The terminal**: `mentl <file:line:col>` prints the same facets the ring
  renders, and `mentl where`, `why` and `query` are the ring's rows as verbs.
  The output is warm and sparse, using the obsidian palette in ANSI.
- **Editors over LSP**: the Obsidian theme is the canonical VS Code theme, and
  hover and the code actions carry the facets.
- **Docs**: parchment ground, Fraunces for display, the code face for code,
  and the octagon ring wherever all eight aspects appear together. Annotated
  code is rendered in the two voices.
- **Landing**: the live page is the landing page. The five verb glyphs are the
  hook, and the thesis (`PLAN.md §0`) is stated plainly: Mentl closes the gap
  between what a person means and what they are forced to write. The landing
  is never a feature-grid template.

---

## 10 · Accessibility (non-negotiable)

- **Colorblind-safe from the start**: the Okabe-Ito set, never altered for
  looks.
- **Never colour alone**: every coloured state also carries a glyph, a
  position or text (a refusal is the socket shape and the Lens line; a badge
  is a word).
- **Contrast measured**: `tools/contrast.py` runs in the IDE gate, on both
  grounds.
- **Motion**: opacity-only or instant under `prefers-reduced-motion`.
- **Keyboard-first**: Tab accepts the proven proposal at a socket, each of the
  ring's rows opens its detail, and nothing needs a pointer.
- **Local-first**: the page registers a service worker that keeps every file
  it fetched, so it opens again offline. There is no account and no server.

---

## 11 · Design drift (do / don't)

| Don't (drift) | Do (substrate-honest) |
|---|---|
| cold slate + electric purple / neon | warm obsidian + gold + parchment |
| a colour because it looks nice | the hue that means the role |
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

1. **The mark**: the octagon ring (§3), favicon → wordmark → lockup, gold on
   obsidian and ink on parchment.
2. **The aspect strip** and the **ambient-world glyphs** in the gutter (§8).
3. **The Severance Map** page with its three-colour law and its count on the
   board.
4. **The eight aspect marks** as an icon family.
5. **The docs' parchment** as a reading surface from the same tokens.

Everything traces back to `ide/tokens.css` and to this rule:

> Color, type, layout and motion are projections of the kernel. The design
> system is a handler on the same graph as the language. How Mentl looks must
> match how Mentl works.
