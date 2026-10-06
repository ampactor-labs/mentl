# Mentl Space — the web IDE

The page runs THE FIXPOINT COMPILER ITSELF in your browser: `boot/mentl.wasm`,
the pinned boot, unmodified, judging in a worker. Nothing leaves the browser,
no server computes anything, and no toolchain is installed — the compiler is
one WebAssembly module and the page is its host.

    bash tools/space-stage.sh            # stage the site into .build/space (the page + every file it fetches)
    python3 tools/space-serve.py         # serve it with the two isolation headers at http://127.0.0.1:7397/

WHAT THE SITE IS has one home, `ide/space.manifest`: the compiler, the runtime
modules the driver links (`lib/*.mn`, `src/types.mn`) and the lessons in
`lib/tutorial/`. The page reads the manifest to know what to fetch; the staging
script copies exactly those files beside the page; the deploy workflow
(`.github/workflows/deploy-space.yml`) and the IDE gate serve THAT directory —
so a file the page needs and the deploy lacks is a red gate before it is a 404
in production. A missing file is a loud boot refusal, never an empty string.

THE PAGE ISOLATES ITSELF. Shared WebAssembly memory needs the document to be
cross-origin isolated, which takes two response headers a plain static host
does not set. `ide/isolate.js` is a service worker the page registers on
every secure host: it adds the headers to every response and keeps a copy of
everything fetched, so the page works on any static host (GitHub Pages, the
python server above, a directory on a stick) and opens again offline. Where
the host set no headers the first open reloads once under the worker; a host
that sets them (the local server, Cloudflare in front of Pages) needs no
reload and the worker is belt and braces.

THE LOOP IS THE RESIDENT SESSION. One worker runs `mentl session` for the
page's life (ide/wheel-worker.js, ide/session-client.js — the same two files
the node twin drives). An edit sends the changed text with the caret's
address: the session re-judges the moved cone and answers the eight aspects
at the caret AND the program's diagnostics in one reply (~100 ms); a caret
move alone is a read of the graph the session already holds (~20 ms). The
emitted WebAssembly text is rendered on demand (the Module tab), never per
keystroke.

The surfaces, each a projection of the compiler's own answer (docs/MENTL_SPACE.md
is the interaction architecture; docs/DESIGN_SYSTEM.md the tokens, which live in
`ide/tokens.css`):

- **The Canvas** — the program, every glyph in its kernel role's hue (the five
  verbs sky, types gold, keywords blue, `own`/`ref`/`resume` magenta, literals
  and `!E` and the `??` socket vermillion). The highlight layer slices the
  source between tokens, so every character the hand typed is on the screen.
  Line numbers in the gutter; the verb spines drawn beside the chains.
- **The Aspect ring** — the eight facets at the caret, read off the View the
  wheel renders (`mentl space main.mn:L:C` → `space_view`, src/space.mn — the
  same facts `mentl main.mn:L:C` prints as text): graph
  (the node's type, with its lede), propose (a `??`'s proven survivor, or the
  install that serves a perform), topology, effects, ownership, verify (every
  open obligation at the node), teach, why (the Reason chain). A row is `real`
  when the compiler answered it; `surface` only before the first read.
- **The Lens** — every banked diagnostic as the kind it is at its own site,
  the caret's module first and the linked modules folded under a count, the
  lead sentence the wheel's own; click to jump. Telemetry (`heap:`, `arena:`,
  `session:`) is cost and never enters the View.
- **The proposal strip** — at a `??` whose Propose facet returned ONE proven
  survivor, Tab accepts it through `mentl accept main.mn:L:C`: a graph edge
  first, the text its projection (the reply carries the rewritten file). A
  tie never proposes — the medium renders the computed question instead.
- **The Ledger** — the declarations nearest the caret by the graph's own
  proximity, each with its inferred row, the open obligations and the
  tightenings the medium would author. The Why chain is the ring's eighth
  facet.
- **The programs** — the lessons `lib/tutorial/00…09` and a scratch buffer;
  drafts persist in the browser; a project's members (`project <dir>` in
  ide/space.manifest, or `mentl space <dir>`) open under their own paths.
  Density is computed from the caret, never configured; ◐ switches the
  ground (obsidian / parchment, the system preference by default).

What deliberately does not exist yet, each named: RUNNING the compiled program
in the page needs the assembler in the wheel (`Hβ.felt.ide-run-in-page` — until
then download the .wat); the canvas's tokens and verb geometry from the
wheel, and the aspect strip in the gutter (PLAN §11, L-D); fill-and-resume and reality scrubbing (band B); the transitive `!E`
proof (band A's crown).

The gate is `bash tools/ide-gate.sh`: the node twin (`node ide/test-shim.mjs`)
drives ide/wheel-worker.js and ide/session-client.js — the SAME execution
host the page uses — through its faces (compile-stdin, the stub-spawn control,
the address CursorView, the `??` Propose socket, the resident session); then
`ide/browser-leg.mjs` drives headless Chrome over its debugging pipe: it loads
the STAGED site at `/?smoke`, prints the page's own console wire as it arrives
— the View's (`SMOKE-VIEW`: the first lesson's View from the session, eight
ring facts, no refusing lens fact), the project's (`SMOKE-PROJECT`: Pulse
opened as a project, its member mounted at its path, zero refusals) and the
product's (`SMOKE-PRODUCT`: render fidelity, no `undefined` in the chrome,
eight real ring rows, a Warning in the Lens at its line, a mismatch at its
own site) — and captures the loaded
page in both grounds (`.build/space.png`, `.build/space-parchment.png`) once
the page says `SPACE-READY`. (Chrome's own `--screenshot` captures the load
event, before the wheel has booted, and never returns under a virtual-time
budget on this page, since the session's worker blocks inside the wheel's
read.) `tools/contrast.py` measures every text/ground pairing of the tokens
against WCAG.
