# Mentl Space — the web IDE

The page runs the fixpoint compiler itself in your browser. It is
`boot/mentl.wasm`, the pinned boot, unmodified, and it runs its type and
effect checks in a web worker. Nothing leaves the browser, no server computes
anything, and you install no toolchain, because the compiler is one
WebAssembly module and the page is its host.

    bash tools/space-stage.sh            # stage the site into .build/space (the page + every file it fetches)
    python3 tools/space-serve.py         # serve it with the two isolation headers at http://127.0.0.1:7397/

One file, `ide/space.manifest`, lists everything the site contains: the
compiler, the runtime modules the driver links (`lib/*.mn`, `src/types.mn`)
and the projects, which are the course (`examples/pulse/course`), Pulse's
renderer, Wasatch's score (`examples/wasatch`) and the grid controller
(`examples/grid`). The page opens the first program the manifest names,
lesson 1, unless its address names another. The page
reads the manifest to know what to fetch, and the staging script copies
exactly those files next to the page. The deploy workflow
(`.github/workflows/deploy-space.yml`) and the IDE gate both serve that same
directory. So if the page needs a file that the deploy lacks, the IDE gate
fails before production can return a 404 for it. A missing file stops the
page from booting with a visible error; it is never read as an empty string.

The page sets up cross-origin isolation itself. Shared WebAssembly memory
requires the document to be cross-origin isolated, which takes two response
headers that a plain static host does not set. `ide/isolate.js` is a service
worker that the page registers on every secure host. It adds the headers to
every response and keeps a copy of everything fetched. As a result the page
works on any static host (GitHub Pages, the python server above, a directory
on a USB stick) and opens again offline. If the host sets no headers, the
page reloads once under the worker the first time it opens. A host that does
set them (the local server, or Cloudflare in front of Pages) needs no
reload, and the worker is then a second safeguard.

The editing loop runs in one resident session. One worker runs
`mentl session FILE` on the program in the editor (ide/wheel-worker.js and
ide/session-client.js, the same two files the node twin drives), and a new
one starts when the editor holds another program. Until 2026-11-20 the
session was started on no file and served only a main.mn, so every lesson
was answered by a fresh compile, about 260 ms for each caret move. An edit
sends the changed text with the caret's address. The session re-checks the
part of the program that the edit changed (the moved cone), and it returns
both the eight aspects at the caret and the program's diagnostics in one
reply, in about 100 ms. Moving the caret without an edit only reads the graph
the session already holds: 5 to 11 ms on a lesson, the renderer, Wasatch and
the grid controller, measured on 2026-11-20 in headless Chromium. The page renders the emitted
WebAssembly text only on demand, in the Module tab, and never on each
keystroke.

The header names the compiler the page runs, as `pin 674 · 8a201af57d54`: its
place in `boot/PROVENANCE.md`'s chain since first light and the first 12 hex
digits of its sha256, read from the bytes the page loaded. A compiler no pin
names shows as `candidate · <hash>` (PLAN §4㉓).

The page has these surfaces, and each one is a projection of the compiler's
own answer (docs/MENTL_SPACE.md describes the interaction architecture, and
docs/DESIGN_SYSTEM.md the tokens, which live in `ide/tokens.css`):

- **The Canvas** shows the program, painted from the wheel's own projection
  of it. `mentl space main.mn:0` returns the module's View, which carries the
  canvas (`canvas_of`, src/space.mn). Each token is drawn at the span that the
  compiler's one lexer reports, in the color of its kernel role: the five
  verbs in sky, types in gold, keywords in blue, `own`/`ref`/`resume` in
  magenta, and literals, `!E` and the `??` socket in vermillion. The page has
  no lexer of its own. It cuts the source at the wheel's spans, so every
  character the person typed is on the screen, and it paints only the lines
  in view. The gutter holds the aspect strip and then the line numbers. The
  aspect strip has eight cells per line, one for each aspect. τ marks a
  declaration's type, ⬡ a hole, and a verb glyph each stage. ◇ marks an
  effect the line requires of its callers and ◆ one that an install grants.
  ●/○ mark an owned parameter and its consume, and ✓ ◌ ✗ a claim that is
  proven, open or refuted. ↑ marks the gradient's step, and ¶ a lede or an
  accept. A ✗ in any column marks a refusal of that aspect. Each cell is a
  link into the ring. Drawn over the text are the verb frames and the `~>`
  enclosure, read from the graph's verb sites, the proof marks at their
  claims, the amber trace from an owned value down to its consume, and the
  references a find follows. Find follows edges: the caret's View carries the
  references of whatever the caret names, and the find box queries
  `mentl space main.mn:L:C <name>` for a name's references and the string
  literals that contain it (the Refs tab). When the editor is idle, the
  formatter's canonical text replaces the buffer. An accept and a formatter
  rewrite each count as one native undo step.
- **The Aspect ring** shows the eight facets at the caret, read from the View
  the wheel renders (`mentl space main.mn:L:C` → `space_view`, src/space.mn).
  These are the same facts that `mentl main.mn:L:C` prints as text. The facets
  are graph (the node's type, with its lede), propose (a `??`'s proven
  survivor, or the install that serves a perform), topology, effects,
  ownership, verify (every open obligation at the node), teach, and why (the
  Reason chain). A row is `real` when the compiler has answered it, and
  `surface` only before the first read.
- **The Lens** lists every stored diagnostic, shown as its own kind at its own
  site. The caret's module comes first, and the linked modules are folded
  under a count. Each lead sentence is the wheel's own text, and clicking a
  diagnostic jumps to its site. Telemetry (`heap:`, `arena:`, `session:`)
  measures cost and never enters the View.
- **The proposal strip** appears at a `??` whose Propose facet returned
  exactly one proven survivor. Tab accepts it through
  `mentl accept main.mn:L:C`, which writes a graph edge first and then the
  text as that edge's projection (the reply carries the rewritten file).
  Elsewhere in the editor Tab indents, and Escape and then Tab moves focus
  out of the editor to the controls after it. A
  tie produces no proposal; the medium shows the computed question instead.
- **The Ledger** lists the declarations nearest the caret, measured by
  distance in the graph, each with its inferred row, its open obligations and
  the tightenings the medium would write. The Why chain is the ring's eighth
  facet.
- **The Run tab** shows what the run button did. The button compiles the
  program in the editor, assembles it with `mentl asm` and runs the bytes in
  a worker. When the program's standard output is a WAV file (the header
  says RIFF, WAVE, 16-bit PCM and has a data chunk), the tab says how many
  seconds of sound it holds, at how many frames a second and in how many
  channels, draws the left channel's wave, and offers play, stop and a
  saved `.wav`. The sound plays once the run ends. Any other output is shown
  as text, and what the program wrote to standard error is shown below it.
  The page reads the file's own header and parses nothing the compiler
  printed. A run that traps says it did not complete and plays nothing. Run
  pressed while the editor is still checking an edit waits for that check
  and then runs.
- **The programs** are the projects the manifest names, each member under
  its own path: the course's twelve lessons (`examples/pulse/course`, with
  the module they share next to them), Pulse's renderer, Wasatch's score
  and the grid controller with its refused twin. There is also a scratch
  buffer, and drafts persist in the browser.
- **The address** names the program and the caret as `mentl` takes them:
  `?at=examples/pulse/course/03-bus.mn:49:30` opens lesson 3 with the caret
  on its share, and the ring shows what `mentl
  examples/pulse/course/03-bus.mn:49:30` prints. A file alone opens it where
  you left it, and a line alone puts the caret on its first character that
  is not a space. The address bar follows the caret while the editor holds
  the served text, and names the file alone once you edit it. A link to a
  file you have edited in this browser says so and offers to restore the
  served text, as one step of the undo. README and SYNTAX link each answer
  they quote at a caret this way. `mentl space <dir>` opens a folder of your own the same way.
  Density is computed from the caret and is never configured. ◐ switches the
  ground (the background) between obsidian and parchment, and it follows the
  system preference by default.

Several things do not exist yet. The page plays a lesson's WAV file only
after the run has ended, so no sound comes out while the program is still
running, and lesson 12's second process, which resumes the first one's
saved memory, does not run in the page. Both belong to the PLAN §11 work
named "the page plays the course". Until then, lesson 12 renders in the
terminal (`mentl run … > lesson.wav`). Also missing are the row-flow tint and the
sealed `!E` wall over the canvas (named as next work in docs/MENTL_SPACE.md
§8), fill-and-resume and reality scrubbing (band B), and the transitive `!E`
proof (band A's crown).

The gate is `bash tools/ide-gate.sh`. First the node twin
(`node ide/test-shim.mjs`) drives ide/wheel-worker.js and
ide/session-client.js, the same execution host the page uses, through each
of its faces: compile-stdin, the stub-spawn control, the address CursorView,
the `??` Propose socket and the resident session. Then
`ide/browser-leg.mjs` drives headless Chrome over its debugging pipe. It
loads the staged site at `/?smoke` and prints the page's own console lines
as they arrive. `SMOKE-VIEW` reports the View: the first lesson's View from
the session, eight ring facts, and no refusal among the lens facts.
`SMOKE-PROJECT` reports the project: Pulse opened as a project, its member
mounted at its path, and zero refusals. `SMOKE-PRODUCT` reports the product:
render fidelity, no `undefined` in the page chrome, eight real ring rows, a
Warning in the Lens at its line, and a mismatch at its own site.
`SMOKE-CANVAS` reports the canvas: no tokenizer in the page, every painted
token equal to the source sliced at the canvas's span, every strip cell taken
from the View, frames and marks drawn, the references at a caret drawn and a
needle's references listed, the formatter's canonical text on idle, and the
accept as one undo step. Once the page prints `SPACE-READY`, the browser leg
captures the loaded page in both grounds (`.build/space.png`,
`.build/space-parchment.png`). (Chrome's own `--screenshot` captures the
page at the load event, before the wheel has booted. Under a virtual-time
budget it never returns on this page, because the session's worker blocks
inside the wheel's read.) `tools/contrast.py` measures every pairing of text
and ground in the tokens against WCAG.
