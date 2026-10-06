# Landing — threads (RACE + SPACE.1), Wave A lane 3

Branch `claude/mentl-swarm-threads`, base `4228ff71` (`base-check` OK; the
base did not move before the finish). Boot measured against: `c8ba5799`.

## Verdicts (each read in this session)

- **march** (no repin): `✓✓ FIXED POINT holds: m2 == m3` — CLEAN.
  `cost: m3 leg 27.66s wall · 387MB peak RSS (396960 KB)` against the
  529,000 KB ceiling. (The container lacked `/usr/bin/time`; the first march
  ran m3 at exit 127 with an empty leg. `apt-get install time` — environment
  only — and the second march is the verdict.)
- **battery** (`march-gate.sh --micros`): rungs 8 / 0; `377/377 fixture
  contracts hold` through m2.
- **frontier** (`--compiler fresh`): `620 pass / 0 red / 2 expected-red`
  (`threaded-branch-captured-store`, declared here; `why-coordinates`,
  standing).
- **crown**: `134 pass / 0 fail`.
- **proof-exactness** (`fresh`): `30 pass / 0 red`.
- **effect identity** (m2): `exit=81 (expected 81) diags=0`, both residue
  rows 0.
- **IDE gate**: not run — the lane touches no `ide/`, `src/space.mn`,
  `src/mcp.mn` or session code.
- **check** `src/main.mn`: zero diagnostics. **verify**: `thesis invariants
  hold`, census 0 / 0, comment-refs 0 (it refused once at 0 → 2 — two stale
  backticked names in my own `StateFact` comment, renamed mid-build; fixed).
- **fmt**: every edited `.mn` renders canonical, names and prose conserved
  (the fixtures were normalized by it; re-running is a no-op).

## RED first (pinned boot c8ba5799)

| Fixture | Boot | Candidate |
|---|---|---|
| `mn-threaded-branch-state-store` (TH-2 crucible) | compiled and ran, exit 3 | refuses `E_ThreadedBranchEffect` ×2: "WRITES its state from an arm (an in-place store into `buf` at 10:22-10:44)" |
| `mn-threaded-branch-state-read` (control) | exit 14 | exit 14 |
| `mn-spawn-module-buffer` (TH-3 b) | exit 0 (each branch read a fresh zero buffer) | exit 18 |
| `mn-spawn-module-init-once` (TH-3 a) | `init` printed 3×, exit 10 | `init` once, exit 10 |
| `mn-spawn-module-values-yielding` (the record past the abandon words) | exit 3 | exit 17 |
| `arena/spawning-module-runs-the-body` (TH-1, contract flipped) | exit 1 | exit 42 |
| `mn-spawn-alloc-contention` vs `-seq` (run only, 3 runs) | threaded 278 / 278 / 300 ms, seq 48 / 50 / 57 ms | threaded 23 / 23 / 25 ms, seq 49 / 60 / 50 ms |
| `mn-threaded-branch-captured-store` | exit 3 (accepted) | exit 3 — declared red, see Open |

## What landed

**RACE — the race rule reads every write.** `StateFact` carries a second
writer, `stores`: every value an arm stores in place into what a state field
holds, as the cells a move of it demands (types.mn). The arena's store claim
notes it where it resolves a target to `TgState` (`state_store_note`,
infer.mn), directly or through a callee storing into its parameter
(`ages_transport`). A `resume … with` commit is already the field's write and
notes nothing more (`commit_settle`), so the fact has one home per writer.
The two readers read it: the install's arena demand
(`ages_install` → `handler_state_writes` = writes past the init ++ stores)
and the race rule (`handler_state_writer`, lower.mn), whose refusal now says
which writer — "an in-place store into `buf` at L:C" or "`resume … with`
updates `n`". **Deleted:** the StoreAges side-ledger — `ages_state_add`,
`ages_state_cells`, the handler's `states` smap and `cells_of`; and
`handler_state_is_written` / `state_field_written` (replaced by the writer
read). `writes of FIELD` projects the stores too (query.mn), so the fact has
a verb.

**RACE — a spawned instance shares the module's values.** A spawning module
with value lets declares `$mvals_g`; the root's `_start`, after
`$__init_lets`, writes every let's word into one record; `$spawn_task_impl`
stores it in the task record past the world (and past the abandon words in a
yielding module — `task_mvals_offset`, the layout's one home); the thread
entry loads each let global from it and **never calls `$__init_lets`**. The
`value_lets` projection moved up so `emit_memory_decl` can read it.

**SPACE.1 — instance segments.** In a spawning module every instance bumps
privately in its own run `[$seg_base, $seg_end)` (`$heap_ptr` is the
instance's line, starting at 0) and touches the shared frontier cell at 64
once per chunk (`$seg_refill`: one `i32.atomic.rmw.add`, at least 64 KB; a
chunk that begins at the run's end extends it, any other starts a new run).
The root takes its first chunk in `_start`. The arena runtime reads the
instance's line (`emit_arena_runtime(spawns)`), and three spawn-only rules
keep it sound: a region below the run's base keeps (a jump, or a spawn while
the arena was open — `$spawn_task_impl` sets `seg_base` to the line, since a
child's records lie outside the young range and may hold the extent's
values); the exit's scratch must fit in the run or extend it in place
(`$seg_extend`, a cmpxchg on the frontier), else keep; a store is journaled
unless its slot lies inside the region itself. A spawned instance allocates
its journal at its first arena (below the mark); a restored image resets the
run to empty at the restored line. **Deleted:** the `spawn_task` conjunct on
`arena_on` and the per-allocation compare-exchange `$alloc`. Thread-free
modules — the wheel among them — emit byte-identically (m2 == m3).

`heap_mark` stays the IMAGE's frontier in a spawning module, not the
instance's line: lib/persist reads the image extent through it, and the wheel
imports persist, so a new Memory op would cross the bootstrap seam (the boot
would compile it as an unhandled perform and m2's warm-image write would
trap). The doc on `heap_mark` (lib/memory.mn) says so; the arena reads its
line in the runtime.

Files: `src/types.mn`, `src/infer.mn`, `src/lower.mn`, `src/query.mn`,
`src/backends/wasm.mn`, `lib/memory.mn`, `docs/SYNTAX.md` (§`><` race rule
and module values, §`~>` arena under spawn), `tools/frontier-gate.sh`,
`tools/verify-baseline.txt`, eight new frontier fixtures, the arena fixture's
contract rewritten.

## Kills

1. "The arm-state store race can be closed without touching Memory" — held
   (the age claim already resolved the store; only the reader was narrow).
2. "The crucible's refusal text can reuse the commit wording" — killed by the
   first m2: `counter`'s `resume … with` read as "an in-place store into `n`",
   because `ages_store_binder` filed the commit through the same settle. The
   commit is the field's write already; it now notes nothing (`commit_settle`).
3. "The captured-buffer race falls to the same fact" — killed: two branches
   storing into one captured buffer run (exit 3) on boot and candidate; no
   handler stands between, and the branch row says only `Memory`.
4. "`heap_mark` can become the instance's line" — killed by reading persist:
   `image_header` sizes the image by it, and a new op to separate the two
   would trap m2 at the bootstrap seam.
5. "The root's arena after the join reclaims KB" (first fixture) — killed by
   a probe: 1 exit, 0 kept, 0 KB freed, because that arena published the
   whole list; publishing a sum, it frees. Branch arenas: 1 exit, 0 kept,
   3 KB freed.
6. "The root's run starts at 1 MB from the global's initializer" — killed by
   reading the invariant: `seg_end - heap_ptr` underflows when `heap_ptr`
   starts above an empty run; the line now starts at 0 and the root refills
   in `_start`.

## Measurements

March m3 leg 27.66 s, 396,960 KB. Contention (4 × 1e6 allocations, run only):
boot threaded 278–300 ms vs seq 48–57 ms; candidate threaded 23–25 ms vs seq
49–60 ms; the frontier leg printed 19 ms / 48 ms. Stress probe (8-element
`fanout` of branches whose arenas publish lists across chunk refills, under a
root arena enclosing the spawns): 361200 three runs out of three, the root
arena 1 exit / 1 kept.

## Bounds moved

`frontier_expected_red: threaded-branch-captured-store` (tools/
verify-baseline.txt), with its justification line: the race is real, the rule
cannot read it while Memory's loads and stores are one effect; it retires
loudly the day it refuses. No ceiling raised.

## Open (draft RESIDUE entries)

**`Hβ.threads.captured-store-race`** — two threaded branches storing in place
into one buffer they both capture (`0 <| (bump(buf), bump(buf))` under
`parallel_compose`) compile and race (exit 3). The arm-state face is closed;
this face has no handler between. Build-ready design: Memory's stores become
their own effect (`MemoryWrite`: `store_i32`, `store_i8`, `store_f64`,
`store_addr`, `mem_copy`, and `list_set`'s row), read only where a spawning
schedule stands, and the race rule asks every store a branch's reach makes
for the age claim's target classified at the BRANCH boundary (a branch scope
kind beside `AgeFn`/`AgeClosure`/`AgeArm`): a target the branch allocated owes
nothing; a capture, a parameter of a partial branch, a state, a module value
or anything older refuses `E_ThreadedBranchEffect` naming the store. EFF's move
of ops between effects is where the split lands; it reads this lane's
`StateFact.stores`. Gate: the frontier leg, declared red today.

**`Hβ.arena.extent-spanning-a-spawn-keeps`** — an arena open across a spawn
its instance makes, or across a refill that could not extend its run, keeps
its region (sound, reclaims nothing). Design: a run per arena extent — the
refill under an open arena first tries `$seg_extend`, and the young range
becomes the instance's chunk list since the mark (a span set, not one
interval), with the exit scanning a joined child's run as part of the extent
when the join happens inside it. Gate: a root arena enclosing a fanout whose
branches return lists of the extent's values reclaims with `ArKept == 0`.

**`Hβ.threads.segment-bases-are-not-deterministic`** — chunk bases come from
the order of atomic adds, so addresses differ run to run under parallelism.
9.2's `{arena, offset}` handle: the segment id is the instance's spawn ordinal
and the chunk ordinal within it, mapped to a base reserved per instance, so
m3 == m4 holds when the wheel first threads. Gate: two runs of a threaded
program print identical heap addresses.

**`Hβ.memory.instance-line-and-image-extent-are-two-reads`** — in a spawning
module `heap_mark` answers the image frontier (persist's extent) while the
arena reads the instance line in the runtime; a program cannot ask its own
line. Design: an `image_extent()` op beside `image_key` that persist reads,
landed across the bootstrap seam in two pins (op support first, repin, then
persist and `heap_mark` switch). Gate: `heap_mark()` returns to its mark
after an arena in a spawning module.

## Record drafts

**LEDGER** — *RACE + SPACE.1 (Wave A, threads).* The race rule read one
writer and the arena another, of one fact: an arm's `list_set` into its state
buffer was recorded by the age claim and seen only by the arena, so two
threaded branches bumping a count kept in a state buffer ran (exit 3 on boot
c8ba5799). `StateFact` carries both writers now — the commits and the
in-place stores — and the side-ledger that held the stores
(`ages_state_add`/`ages_state_cells`) is deleted; the refusal names the store.
A spawned instance re-ran every module init: an init that printed printed
three times, and a branch read a fresh copy of a buffer the root had updated
(exit 0 for 18). The root writes its module values once into a record the
task record carries, and the thread entry loads them. And a spawn anywhere
turned every arena in the module off while every allocation was a
compare-exchange on one cell (4 × 1e6 allocations: threaded 278–300 ms against
48–57 ms sequential). Each instance bumps in its own run, one atomic add per
64 KB chunk (23–25 ms threaded); an arena's region is a span of its run and
reclaims in a spawned branch and in the root, and keeps where a spawn or a
jump crossed it. Kills: the commit read as an in-place store until it noted
nothing; the captured-buffer race survives (declared red, it needs Memory's
stores as an effect); `heap_mark` stays the image frontier because persist
sizes the image by it and a new op would trap m2 at the seam. Fixed point
CLEAN, m3 396,960 KB.

**PLAN §7 bullet** — **THE RACE RULE READS EVERY WRITE, AND A SPAWNED
INSTANCE SHARES THE MODULE AND OWNS ITS RUN — CLOSED 2026-10-06 (RACE +
SPACE.1).** One write fact (`StateFact.stores` beside `writes`) read by the
race rule and the arena alike; module values written once by the root and
carried in the task record; instance segments with one atomic add per chunk,
the `spawn_task` conjunct on `arena_on` deleted. Open:
`Hβ.threads.captured-store-race`, `Hβ.arena.extent-spanning-a-spawn-keeps`,
`Hβ.threads.segment-bases-are-not-deterministic`,
`Hβ.memory.instance-line-and-image-extent-are-two-reads`.

**RESIDUE** — `Hβ.arena.per-instance-regions`: CLOSED by SPACE.1 (text above).
TH-2's and TH-3's findings close with RACE. The four entries under Open are
new.

**PLAN §11** — no change to the order; SPACE.1 lands before the course as
planned, and lesson 10 keeps its arenas inside branches.
