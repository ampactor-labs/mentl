# Working plan: Mentl, from 2026-10-29 — the memory paradigm, and the landings that follow from it

This file is the working plan and the memory of this line of thought. It is
written so that a reader who has lost the conversation can continue the work
from it alone: what is decided, why, what it changes for the people who
build Mentl and the people who use it, what each landing measures, and in
what order. PLAN.md §11 stays the only list of open work in the repository;
PLAN §7 the state; CLAUDE.md the method; the commits the measurements. A
landing leaves this file when its check is in hand and one line joins
"Done". The design sections stay until PLAN §4⑨ holds them (M1's commit),
after which this file keeps a pointer and the landing list.

## Standing rules

The branch is `claude/hum-pitch-claims-check-g31gnj`; main only with the
user's word. Commit as sonofagoose through the hooks, never `--no-verify`,
no model name in any file, the `Claude-Session` trailer only. Plain English
by CLAUDE.md, and "proves" never alone (the rule, the check through every
call, the version that breaks it does not build). No subagents; no
background work beyond `mentl land`. Every claim a command's output from
this session. Every syntax example a real program in the repository with the
pin's answer beside it. Mentl only: no other repository's firmware and no
outside engine is part of the path to any host. Simplify and consolidate;
use carried truth to its full extent; write new code with the five
operators and the comment paradigm (a backticked name is an edge; a comment
states intent); ask at every line "why, could this be better".

## Done (the commits are the record)

- a062fcb4 the standard (CLAUDE.md "How to talk about Mentl"), the README's
  first screen, SYNTAX "Composing the five".
- c68d167c a program that starts no thread owns an unshared memory (pin
  f2721cd5); a6dbe178 the caret says each operator's shape (pin e4c8c79d);
  pull request #26 merged both to main.
- 826bdfdd PLAN carries the canon (§5.V), the state, the embedded path.
- fb660f61 a hole proposes the values in scope around it (pin a3cef2997c4d).
- 320cdfc7 the gate judges a proposal with the library it will run with (pin
  fffd9481fdf3): `propose` on the controller answers PROVEN where the boot
  before refused it with 31 missing names; the leaky twin is refused with
  the path; one `gated_compile` record serves the battery and the gate.
- The eight emails and the HUM wording patch with its PDFs: delivered as
  files; the user sends and applies them.
- Yoke readiness: the five MCP calls answer from the controller project on
  the new pin; the honest price rule proves; the leaky form is refused with
  the path; the document is yoke-night.md in the scratchpad (delivered).
- Mentl Space keeps up by construction: `mentl space
  examples/pulse/course/03-bus.mn:49:30` paints the topology sentence and
  `mentl space main.mn:253:5` on the controller copy paints the 22-survivor
  tie with its question (checked on the new pin). The deployed page
  redeploys only from main, so it serves the new pin once main holds it.

## The bottom of Mentl: memory is a projection of the graph

Asked for before any board: the lowest, most foundational memory paradigm,
checked against the state of the art and designed to set the standard. It is
not a new mechanism beside PLAN §4⑧'s five. It is the recognition that the
kernel's own discipline, one graph, one writer, extents and an image, is
the memory model, and that the program's memory and the compiler's memory
are the same thing read in two domains.

### What the field has (read 2026-10-29; sources at the end)

- Precise reference counting with reuse: Koka's Perceus inserts the counts
  so a cycle-free program is garbage-free and updates in place where a value
  is unique ("functional but in-place"); Lean 4 does the same ("Counting
  Immutable Beans") with inferred borrowing. The cost is count traffic on
  every share, paid at run time.
- Regions: MLKit and Cyclone made lifetimes regions in types. Verona
  isolates a region behind one entry point and lets one region be mutable
  at a time; PLDI 2025 enforces that discipline dynamically for a Python-like
  language. Vale puts a generation in every reference and checks it on use
  unless a static analysis or a region proves it (2 to 11 percent measured).
  CHERI puts bounds and permissions in every pointer in hardware (128-bit
  capabilities, up to 1.65 times slower on Morello). Each pays at run time
  for what it cannot prove.
- Value semantics: Hylo bans sharing of mutable state instead of mutation
  (one binding may mutate a value at a time) and gets part-wise in-place
  update and local reasoning. Mentl's `own`/`ref` inference is the same bet
  made silent (PLAN §4⑤).
- Compile-time deallocation: ASAP (Proust, Cambridge 2017) inserts frees from
  static analysis with no annotations and was never put in a real compiler.
  Zig and Odin hand an allocator down as a parameter or an implicit context,
  and arenas are their idiom. Faust compiles a signal program to constant
  memory with delay lines sized by the compiler.
- The host: WebAssembly's memory64 is standard and multi-memory is shipping
  (Safari expected 2026); custom page sizes (1 byte or 64 KiB) are a proposal
  wasmi already implements; Wizer snapshots an instance into a new module
  (its minimum pages and its non-zero segments), which is what Mentl's image
  already is; Motoko keeps the whole Wasm memory across an upgrade with a
  type-driven safety check, which Mentl's build key does by hash today.

### What Mentl already has (with the places to read)

- The arena (lib/arena.mn, a 59-line module): `(body) ~> arena` is a handler
  that answers `Alloc`; at its exit what the body's result reaches moves out
  along its type, the rest is reclaimed and zeroed in one step, and a store
  into memory older than the arena is journaled where it happens because the
  judgment knows, by the store-age walk, which stores can reach older memory
  (a buffer the scope allocated cannot; a parameter is its callers'
  question; a handler's state its installs'). A value whose type the store
  could not see (a function, a continuation) keeps the whole region, and the
  arena counts it. The `Arena` effect has no ops: it is the fact that code
  opens one, charged to main's row, which turns every store's barrier on.
- The arena's runtime (src/backends/wasm.mn from line 5287): globals
  `$ar_depth`, `$ar_mark`, `$ar_jb`, `$ar_jn`, `$ar_jover`, `$ar_abort`, and
  the counters `$ar_exits`, `$ar_kept`, `$ar_freed`, `$ar_moved`, `$ar_high`,
  `$ar_susp`; `arena_sweep` returns without reclaiming when the journal
  overflowed (`$ar_jover`, line 5420), so a smaller journal costs reclaim,
  never meaning; the journal block is 262,144 entries of 8 bytes (2 MB),
  allocated first in `_start` (line 6867). The memory declaration
  (`emit_memory_decl`, 5002; the lines at 5043 and 5045) is `(memory
  (export "memory") 32 65536)`; `$heap_ptr` starts at 1,048,576 (5067) above
  strings laid out from 64 KB (`emit_string_data`, 3819; the entries are set
  at 2464, before the declaration is written at 2549); `$memory_reach`
  (5140) grows by at least 256 pages (16 MB); the threaded frontier cell at
  address 64 is set to 1 MB in `_start` (6859); the dispatch memo is 1,536
  bytes. These are the wheel's own constants leaking into every program.
- Ownership as an effect (src/own.mn): every use of an `own` parameter
  performs `Consume`; the affine ledger refuses a double consume; `own` and
  `ref` are inferred from use counts. Uniqueness is a fact the graph holds.
- The image (lib/persist.mn): [0, heap line) plus the mutable globals is the
  whole program state; persist is memcpy and resume re-enters the same
  addresses; the build key (a hash of what the layout depends on) gates a
  resume; host resources (descriptors, the stdin position) are not in it.
  WebAssembly call frames live engine-side, so an image is complete only
  where continuation records already cover the stack.
- Memory as effects (lib/memory.mn): `Memory`, `Alloc`, `Cast`; "the WASM
  runtime IS the handler"; an operation not declared there does not exist;
  `addr` is capability-gated and an arena keeps a region whose address
  escaped.
- The graph: a node is its handle; every fact is a column at the handle; the
  judgment is the one writer; a fork runs over a version in an instance of
  its own (an arena) and keeps or drops it (`speculate`, `graph_keep`,
  `branch_join`, PLAN §7). PLAN §11.8 makes a handle an {arena, offset}
  product deterministic under any order. PLAN §5.O says a fact is derived
  once and read after, and the image is what lets a fact outlive a run.
- The board (src/board.mn) bounds nothing about memory except the march's
  line peak and peak RSS (boot/PROVENANCE.md records 281,630 KB and 279,516
  KB at pin fffd9481fdf3 for the compiler compiling itself). The counters
  the runtime already keeps are not yet printed or ratcheted.

### The law (PLAN §4⑨, dated 2026-10-29, to be written in M1's commit)

Memory is a projection of the graph. A value is a node's record, and a
lifetime is an extent's. A computation is an extent; an extent is at once a
region (where its values live), a version (the fork's instance), a world (the
continuation's segment), a checkpoint (the image at its boundary) and a
transaction (its stores into older memory are its journal, and its exit
keeps or aborts). Its exit keeps what its result reaches, by the reach the
judgment drew, moving each survivor through its own type. A value is written
in place when the graph proves it owned once. A value is addressed by its
extent and its offset, never by a bare pointer, and carries no header, count,
generation or capability: its type is its layout. Every exit leaves zero
behind it, so memory is a value or it is zero, never garbage. The whole of it
is one image that is copied to save, re-entered to resume, moved to any host,
and read back as facts. The image is the memo of every extent kept, which is
the cost law (§5.O) stated about memory: a fact kept is bytes, and deriving
it again is a miss.

The author decides four things and nothing else: what must never allocate
(`!Alloc` on a stage), what budget the program fits (a claim on main's row),
the depth of a line (`<~ delay(N)`), and `own`/`ref` where inference fails.
The medium derives every address, every lifetime, every in-place write, the
layout of every record, the memory kind every extent lives in, every page
the host must provide, and the proof that running out of memory cannot
happen where the row says so.

### Five readings of the one law

1. **The row is the memory boundary.** An extent's row says everything that
   crosses its edge: `Alloc` grows memory inside it; `Mutate@h`, the modal
   form of §11.1, is a store into the older extent `h`'s region; its result
   is what it publishes; `Pure` means nothing crosses. The store-age walk is
   the modal row. So an extent whose row proves no store past its own region
   needs no barrier and no journal, and its exit moves its result and nothing
   else. Memory safety and effect safety are one proof.
2. **Layout is projection** (SYNTAX S2.1 says it of text). No author writes
   a struct, an alignment, a row-or-column choice or a placement; a record is
   its handler's state fields, a line is its depth, a product is the merge
   stage's slots. Inside the image there is no ABI and the reach knows every
   reader of every field, so the compiler owns arrangement: fields read
   together kept together, cold fields apart, a list stored as columns when a
   `><` under a SIMD or GPU schedule reads it lane-wise and as rows when a
   `|>` walks it. §5.U already lets a handler choose the schedule over one
   record; layout following the schedule is what makes the choice free.
3. **The install chain is the memory hierarchy.** A perform travels outward
   to the nearest handler that answers it; an allocation stays in the nearest
   extent that owns it; a value's life extends outward exactly as far as its
   reach. The arena is literally the nearest handler answering `Alloc`.
   Nesting is locality: inner extents are hot and short-lived, outer extents
   resident, the outermost the image. Memory kinds are therefore handler
   instances of `Memory` (registers, SRAM, SDRAM, flash, a persistent store,
   another machine), and the clock calculus (§11.7) places each extent in the
   kind its clock deserves, with `!Memory@sdram` provable on an audio path.
   Multi-memory is the host's form of this: the image in one memory, the
   heap in another, a board's flash and RAM.
4. **Time is memory's only axis, and `<~` names it.** Memory is the past
   kept: a line keeps a stage's last N values, handler state keeps the past
   across resumes, the image keeps everything, a fork keeps a branch of it.
   Every piece of memory has a clock (how often it changes) and a depth (how
   much it keeps); static clocks with written depths are exactly the programs
   with a provable constant footprint. Incremental compilation (§11.6) is a
   `<~` of depth one over the edit clock, undo the same line at depth N, and
   a program recomputing only the cone that reads a changed input (§11.7's
   coefficient recomputed when its input changes) is the same mechanism:
   reactivity (§4⑦) is how every program runs, not a feature of the page.
5. **One evaluator, many domains.** §4⑧ calls the value walk and the
   derivative reading the evaluator's abstract and tangent instances. Taken
   to the end: inferring types evaluates the program in the domain of types,
   inferring rows in the domain of effects, running it in the domain of
   bytes, differentiating in tangents. Each walks the same extents (the
   program's installs) and leaves columns at the same handles in the same
   image. Compile time and run time are two domains of one evaluation, so a
   run-time value is a node written by the evaluator as a fact is a column
   written by the judgment; `mentl why` works on a running program (a value's
   reason is its flow, §4⑥, instantiated); the debugger is the cursor; and
   the static part of `_start` can be emitted as the image because it is an
   evaluation already done.

### The gold standard, each claim a count on the board that only falls

1. No garbage: at every exit the live set is the reach, exactly; regions kept
   because a root's type was not visible fall to zero (`$ar_kept`).
2. No dangling: a handle never outlives its extent except by move, by
   construction, with no run-time check (no generation, no count).
3. No serializer: persist is memcpy, resume re-enters; compatibility between
   builds is a comparison of faces per extent, so a live program upgrades
   by re-judging the cone whose faces changed and keeps the rest of its
   image (Motoko's upgrade check made exact).
4. The footprint is stated: `mentl compile` says what the host must provide;
   for a program whose row proves `!Alloc` past its start and whose lines
   have written depths, the number is the whole truth for the program's life
   (Faust's constant memory, proven), and running out of memory is a row
   fact the crown negates.
5. Deterministic layout: the same bytes under any schedule; the image is
   reproducible and portable, and a persisted image can be checked against a
   recomputation as the march checks the compiler.
6. In place where owned: a `|>` chain over an owned value allocates nothing;
   each stage reuses the record it consumes (Perceus's reuse without the
   counts).
7. The residue is visible: where the proof cannot decide, Mentl keeps a
   region rather than check a reference; the fallback costs memory, never
   time, and the counters say where it fell.

### The residue table: every run-time mechanism is a fact the judgment does not yet hold

| Mechanism in the emitted runtime | The fact that deletes it | Landing |
|---|---|---|
| 32 initial pages, heap at 1 MB, 16 MB grow step | the data's end and the start's bytes, known at emit | M1 |
| the store barrier on for the whole program | the row: `Mutate` past the extent's own region, per extent | M2 |
| 4 GB max, grow by a constant | the budget claim on main's row | M3 |
| the journal (2 MB, global) | the extent's stores into older memory, counted where bounded; exits emitted per extent from their static roots | M6 |
| regions kept at exits | closures and continuations carrying their type | M6 |
| the shared frontier cell, `shared` memory for every spawning program | a private memory per instance and one shared image (two memories) | M5 |
| moves at exits for values that escape | allocation placed where the reach says the value will live | M8 |
| headers of any kind | none exist except the closure's, which M6 removes | M6 |
| frames outside the image | §11.2's capture at any position | M10 |
| the fork's own keep and merge beside the arena's exit | one extent exit, the fork a reader of the arena | M10 |

### Implications for development (what I learned by thinking it through)

- Every run-time mechanism is a confession about a fact the judgment does
  not hold, and the roadmap is the list of confessions. Each landing deletes
  code and lowers a count; a memory landing that adds a mechanism is drift.
  This is §9.11 ("a carried-truth fix deletes") applied to the runtime.
- The compiler is the first program under the model and its hardest. The
  march already measures the model's residue (line peak, peak RSS); the
  runtime's counters are not yet printed or ratcheted. So the first move is
  to print them in the self-compile's phase line and put `kept` and the
  journal's high-water on the board as bounds that only fall. Every memory
  landing then shows its effect on the compiler compiling itself, the one
  measurement a person reading PROVENANCE can trust.
- The face (§4⑧) must carry three memory facts per declaration: what it
  allocates and whether that is bounded, which values escape it, and the
  stores into older memory it can make. They should be sets of handles, not
  counts, so an edit that does not change them leaves the face equal and the
  cone small; otherwise memory facts would make incremental re-judgment
  worse.
- The evaluator (§11.2) is the keystone for memory too: the row's exhaustion
  fact, the footprint proof and the frames in the image all want it. Do not
  start there. The landings below produce the facts (the counters, the
  per-extent exits, the placed allocations) that make the evaluator's job a
  reading of them; building the evaluator first would guess at facts the
  landings measure.
- The fork and the arena are two implementations of one exit. Unifying them
  (the fork as a reader of the arena) removes the compiler's own speculation
  code in favor of the runtime it already emits for every program, and puts
  the compiler's forks under the same counters. It comes late (M10) because
  the per-extent exit (M6) must exist first for the fork to read it.
- Testing memory facts needs a program that can read its own footprint.
  `memory_pages() -> Int` (an `Alloc` op beside `heap_mark`, lib/memory.mn
  line 155; the native roster in src/effects.mn near 2074; the emit arm near
  wasm.mn 8218) lets a `// expect: N` micro state a module's initial pages.
  The counters give the board its two bounds. A `mentl audit` memory tree
  gives the frontier gate text to read until it is a fixture contract. No
  tools/ growth is needed for any of them.
- The documents: PLAN §4⑨ (the law and the five readings), §5 gains a
  paragraph beside §5.U and §5.O naming memory as a projection, §7 records
  the constants and the counters as state, and the landings attach to the
  steps that own their mechanism: §11.1 (the modal `Mutate` and the
  exhaustion fact), §11.2 (frames in the image, the evaluator), §11.6
  (incrementality as `<~`), §11.7 (clocks place extents), §11.8 (handles,
  two memories, determinism), §11.9 (the native projection). SYNTAX's
  "Composing the five" gains a memory column in its table. CLAUDE.md's eight
  questions gain a ninth to propose to the user: "Extent: which extent owns
  this value, and what crosses its edge?"
- Threads simplify: a private memory per instance and one shared image make
  `shared` memory a fact of programs that share mutable state, and a store
  into shared handler state is a journaled store whose conflict is an abort,
  the same analysis §11.8 wants for the solver. The thread gate's reading of
  SHARED and OWNED changes with M5.
- Risks, named: moves at exits for large escaping values until M8; regions
  kept for closures until M6; an image complete only at covered points until
  M10; a budget claim pending for programs with unbounded allocation (honest,
  not a defect); the browser's multi-memory support (Safari) for Mentl Space
  until it ships; packing {arena, offset} into one 32-bit word (§11.8's repr
  pin) needs its own design; zero-at-allocation against zero-at-exit is a
  measurement, not a decision, and stays open until measured.
- Wording: "memory is the graph's shadow" is a metaphor and does not go into
  a document; the literal sentence is "memory is a projection of the graph".
  Every memory claim follows the standard: the compiler says N bytes and
  proves it holds because every stage past the start is `!Alloc` and every
  line has a written depth, and a version that breaks it does not build.

### Implications for the person at the keyboard

- Memory stops being a subject. There is nothing to allocate, free, count or
  collect, and the four decisions left are the ones a reviewer asks about
  today. The five operators are the memory operators: `~>` is where memory
  lives, `<~` the only remembered past, `|>` reuses what it owns, `<|`
  copies nothing, `><` shares nothing.
- Memory becomes legible as structure. `mentl audit` prints a program's
  memory as the tree the author wrote: resident memory is the handler tree
  plus the lines (`station` holds six words; `decide` holds five lines of one
  word), transient memory is each extent's bytes, reclaimed at its exit. The
  caret says where a value lives and when it dies ("lives in the arena opened
  at line 450, moved out at its exit along `Mode`"), and `mentl why` answers
  "why does this program need 2 MB" (the journal) or "why is this region
  kept" (a closure's type unseen at its store).
- The footprint is a proven number. For an audio chain or a controller whose
  row allows it, `mentl compile` states the constant and the proof, which is
  what real-time audio and a 264 KB board actually need; a budget exceeded is
  refused naming the extent that breaks it and the number that would fit.
- Durability, live upgrade and reactivity are one thing seen three ways: a
  program is saved by copying, moved between hosts, upgraded by comparing
  faces (what state carries over is said at the keyboard), and recomputes
  only the cone an input changed, so a sample-rate change re-derives a
  coefficient once and a controller re-decides only what a reading touched.
- Embedded placement is derived: the audio path in SRAM, the station's state
  in SDRAM, the image in flash, each by its clock, with the audio path
  provably never touching the slow memory. The story for a board becomes
  "the compiler places your program on the chip and proves it fits".
- Performance without a profiler: zero start (the image is emitted), no
  collector pauses, in-place reuse along pipes, columnar layout under a SIMD
  or GPU schedule, and deterministic replay for any bug.
- HUM's claim grows honestly: "300,000 readings in the same memory" today,
  "a proven constant footprint of N bytes" when M4 lands, each sentence by the
  standard.
- Teaching: the course can gain a lesson that shows memory as the handler
  tree and `!Alloc` by proof (a decision for the user; the course's ten
  lessons are otherwise unchanged).

### Decisions to confirm with the user, none blocking M1

- The budget as a row claim on main (a parameterized effect instance in the
  style of `Sample(48000)`) rather than a handler; its name.
- A ninth question in CLAUDE.md's "Writing Mentl code".
- Whether the course gains a memory lesson.
- M0's two board bounds (`kept`, journal high-water) as the first memory
  counts.

### The landings, in the order where each empowers the next

Each is one commit through `mentl land`, red first on the boot, with its
check named; each deletes a mechanism from the residue table and lowers a
count. Later ones are specified only to the depth needed to order them; each
gets its own planning pass when it starts.

- **M1 — A module's memory starts where its data ends, and its first pages
  are what its start needs; the runtime says its own counts.**
  `emit_memory_decl` receives the data's end (known at 2464, before the
  declaration at 2549) and the start's bytes (the memo, the fold stack's
  home, the 2 MB journal when an arena is open, the argument area);
  `$heap_ptr` and the threaded frontier cell start at the data's end aligned
  to 16 bytes; the initial page count covers the start; the threaded import
  declares the same count; max and grow step unchanged (M3's). `memory_pages()
  -> Int` joins `Alloc` and lowers to `memory.size`. The self-compile's phase
  line prints `$ar_exits`, `$ar_kept`, `$ar_moved`, `$ar_high` and the
  journal's high-water, and the board gains two bounds, `kept` and journal
  high-water, at their measured values. Fixtures: tests/micros
  `mn-memory-pages-start.mn` (`// expect: 2`, no arena) and
  `mn-memory-pages-arena.mn` (33, an arena open). Red on pin fffd9481fdf3:
  `32 65536` and `1048576` in `mentl compile examples/grid/station.mn`; the
  controller's start need falls from about 18 MB to about 2 MB, measured by
  `/usr/bin/time -v` on one reading, both numbers in the commit. Docs: PLAN
  §4⑨ and the §5 paragraph, §7 (constants, counters), §11.8 loses the
  heap-base and first-pages clauses, §11.9 rewritten in Mentl's terms (the
  native projection, no outside engine, no other repository), SYNTAX's
  table gains its memory column. Title: "A module's memory starts where its
  data ends, and its first pages are what its start needs".
- **M2 — The barrier follows the row.** The store barrier and the journal
  are emitted per extent, on only where the extent's row admits a store past
  its own region; an extent proven otherwise exits by moving its result
  alone. Check: the self-compile's `kept` and journal counts fall and the
  line peak does not rise; the arena fixtures hold. This is the decisive
  test of reading 1; if the counts do not fall, the design is wrong where it
  matters and the table says where.
- **M3 — The budget is a claim.** `Within(bytes)` on main's row (name to
  confirm): the emitter reads it as it reads a schedule, for the max pages,
  the grow step and the journal's size; a start need past it is refused
  naming both numbers; the memory line is the number `mentl compile` says.
  Check: a fixture refused at a budget its start exceeds, one that fits.
- **M4 — Constant memory, proven.** A program whose main's row is `!Alloc`
  past its start and whose lines are static declares `(memory N N)`; the
  whole-truth row gains the exhaustion fact the crown negates (§11.1b).
  Check: the course's `!Alloc` lessons and the controller carry the proven
  footprint; HUM's sentence changes.
- **M5 — Two memories.** The image (strings, static closures, tables, the
  memo, everything `_start` builds that never changes) emitted as a data
  segment in memory 0; the heap in memory 1; a spawned instance imports
  memory 0 and owns a memory 1; the shared frontier cell goes; `shared` is
  declared only for state that is shared. Check: the thread gate reads the
  two declarations; the self-compile's bytes are identical under both
  schedules; Mentl Space serves the two-memory boot (browser support
  verified).
- **M6 — Exits emitted per extent, closures carry their type.** The exit
  moves exactly the static roots the judgment knows; the journal remains
  only for stores through values whose targets the judgment could not see;
  a closure carries its signature as its type so it moves. Check: `kept`
  reaches zero on the self-compile; the journal's high-water falls to the
  unknown-edge residue.
- **M7 — Handles are {arena, offset}** (§11.8): deterministic under threads,
  the image portable between hosts. Check: m3 under `sequential_compose`
  equals m3 under `parallel_compose` byte for byte with the pool on.
- **M8 — Allocate where it will live, reuse in place where owned.** The
  reach places an escaping value in the extent that publishes it, so moves at
  exits become the exception; a `|>` stage reuses the owned record it
  consumes (§11.7). Check: `$ar_moved` falls on the self-compile; the
  course's `Alloc` census falls.
- **M9 — Layout and placement are projections.** Fields grouped by their
  readers; columns under SIMD and GPU schedules; memory kinds as `Memory`
  instances placed by clock (§11.7, §11.9). Check: a lesson under a SIMD
  schedule reads lanes from columns; an audio path proves `!Memory@sdram`.
- **M10 — One exit for the fork and the arena; frames in the image.** The
  fork reads the arena's exit; a continuation is captured at any position
  (§11.2); a checkpoint is complete anywhere; live upgrade compares faces.
  Check: the speculation code in the wheel shrinks; the arena leg persists
  and resumes mid-call.
- **M11 — The native projection** (§11.9): the same facts emitted as Thumb-2
  for the Cortex-M7 and M0+, the board's clock, codec and line as handlers
  over main. Mentl only.

### Sources

Perceus (PLDI 2021): https://www.microsoft.com/en-us/research/publication/perceus-garbage-free-reference-counting-with-reuse/ ·
Counting Immutable Beans: https://arxiv.org/pdf/1908.05647 ·
Verona regions (OOPSLA 2023): https://microsoft.com/en-us/research/uploads/prod/2023/10/oopslab23main-p377.pdf ·
Dynamic Region Ownership (PLDI 2025): https://pldi25.sigplan.org/details/pldi-2025-papers/64/Dynamic-Region-Ownership-for-Concurrency-Safety ·
Vale generational references: https://vale.dev/blog/generational-references ·
Hylo, mutable value semantics: https://arxiv.org/pdf/2106.12678 ·
ASAP (UCAM-CL-TR-908): https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-908.html ·
CHERI on Morello (IISWC 2025): https://eprints.whiterose.ac.uk/id/eprint/231424/1/iiswc25_cheri_workload_characterisation_on_cheribsd_morello.pdf ·
Wasm custom page sizes: https://github.com/WebAssembly/custom-page-sizes/blob/main/proposals/custom-page-sizes/Overview.md ·
Wasm memory64: https://github.com/WebAssembly/memory64 ·
Wizer: https://docs.rs/crate/wizer/latest/source/src/lib.rs ·
Motoko orthogonal persistence: https://docs.internetcomputer.org/languages/motoko/fundamentals/actors/orthogonal-persistence/index.md ·
Faust: https://en.wikipedia.org/wiki/FAUST_(programming_language) ·
Zig allocators: https://antonz.org/allocators/

## Other open landings

- **The fan's rank reads the arms beside the hole** (PLAN §11.5). At the
  controller's hole the question names `hz`, `island` and `level` (the names
  used most often nearby) before the `draw` and `spin_w` the neighbouring
  arms of the same `if` use. `candidate_rank` (src/synth_proposer.mn) gains
  the sibling arms' references as its strongest term; a nested function in
  scope is offered when its body does not reach the hole's declaration; a
  fixture per rule, red on the boot. Title: "The question at a hole names
  what its neighbours use first".
- **The gate's JSON reader accepts `\uXXXX`** (lib/json.mn `decode_escape`;
  PLAN §7 records it): a client that escapes non-ASCII is refused today.

## Verification, every landing

The check named in the landing, in hand as a command's output from this
session; `mentl land` green and pinned for a compiler change, docs-only
commits through `bash tools/doc-truth.sh`; the branch pushed after each
commit; main only with the user's word. When a landing's check is in hand,
its section leaves this file and one line joins "Done".