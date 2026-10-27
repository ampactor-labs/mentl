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
and the projects, which are Pulse's renderer, the course
(`examples/pulse/course`) and Wasatch's score (`examples/wasatch`). The page
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
`mentl session` for as long as the page is open (ide/wheel-worker.js and
ide/session-client.js, the same two files the node twin drives). An edit
sends the changed text with the caret's address. The session re-checks the
part of the program that the edit changed (the moved cone), and it returns
both the eight aspects at the caret and the program's diagnostics in one
reply, in about 100 ms. Moving the caret without an edit only reads the graph
the session already holds, in about 20 ms. The page renders the emitted
WebAssembly text only on demand, in the Module tab, and never on each
keystroke.

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
  text as that edge's projection (the reply carries the rewritten file). A
  tie produces no proposal; the medium shows the computed question instead.
- **The Ledger** lists the declarations nearest the caret, measured by
  distance in the graph, each with its inferred row, its open obligations and
  the tightenings the medium would write. The Why chain is the ring's eighth
  facet.
- **The programs** are the projects the manifest names, each member under
  its own path: Pulse's renderer, the course's ten lessons
  (`examples/pulse/course`, with the module they share next to them) and
  Wasatch's score. There is also a scratch buffer, and drafts persist in the
  browser. `mentl space <dir>` opens a folder of your own the same way.
  Density is computed from the caret and is never configured. ◐ switches the
  ground (the background) between obsidian and parchment, and it follows the
  system preference by default.

Several things do not exist yet. The page cannot yet run the compiled
program. `mentl asm` assembles the wheel's own output, and having the worker
instantiate those bytes so that a lesson plays through the speaker is the
PLAN §11 work named "the page plays the course", where the graph's evaluator
runs a lesson at once. Until then, a lesson renders in the terminal
(`mentl run … > lesson.wav`). Also missing are the row-flow tint and the
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
