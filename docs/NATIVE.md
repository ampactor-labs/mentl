# NATIVE.md — Mentl's native machine, graph to silicon

> Working artifact (band N, `§5.R`), not read-path. The three-doc contract
> stands; this is the design + build plan for the native backend, hardened by a
> 24-agent design/refute/critique pass (2026-07-11). Interrogate, don't absorb.

## §0 · The thesis, and the one correction that made it real

Native is not "lower to assembly." **The graph image is the machine; the cursor
is execution; native code is the cursor's cached projection.** Ten layers were
designed from that thesis and each adversarially refuted, and the refutations
converged — unanimously — on one correction. By PLAN §7's own law (N independent
proposals collapsing onto one attractor *is* the truth signal), that unanimity
is the design, not a setback:

> **The addressing/projection substrate is right and sharper than first stated;
> "there is no stack" is a slogan its own hot path falsifies.** The graph-image
> memory model, the handle-as-offset, the eight-aspect projection, the
> assembler-as-a-handler — all hold. But "every frame is a heap record in the
> monotonic image, never freed" is SML/NJ heap-CPS *without its GC* — a loop or a
> server exhausts the image, and five layers quietly reach for `%rsp` anyway.

The correction is not to bolt a stack back on. It is to read what the kernel
already has:

**Frame representation is the resume-cardinality/ownership grade, and the
activation spine is the graph's own trail.** This is the whole machine's pivot,
and it is derivable *today* from verified artifacts:

- **OneShot activations** (the ~85% grade) are **LIFO-reclaimable**. They live in
  the one monotonic image; a delimited segment's exit reclaims its frames with
  `graph.mn`'s own `graph_rollback` (O(M), the trail-checkpoint that already
  captures `trail_len` at O(1)). Loops stay O(1), servers stay bounded, there is
  no GC and no imported SysV stack — reclamation is a move *inside* the medium,
  so `!Outside` holds. The hardware `%rsp` is not the activation spine; it is
  **demoted** to a bounded per-core scratch the CPU mandates for trap/interrupt
  frame delivery, and nothing else.
- **MultiShot (captured) continuations** materialize as persistent image records
  — the unified `handler = state = closure = continuation` shape, unchanged. The
  captured *segment* (the frame chain between perform and handler) is the
  continuation; `k` owns it, freed at `k`'s use-count 0. And *now* "continuation
  = memcpy" is finally true, because every frame including the OneShot callers is
  in the image — so persist = memcpy, fork-to-a-core = memcpy, exactly as the
  value layer promised (`§5.U`).

The cardinality lattice this session landed (`resume grade = ownership grade`,
one use-count) decides *whether* a continuation forks and, by the same read, the
**frame representation** for the entire machine. `own`/OneShot →
hardware-scratch or trail-reclaimed image frame; `ref`/MultiShot → captured image
record. The same read, one more consumer, and it dissolves five layers' primary
breaks at once.

## §1 · The two keystones

**Keystone 1 — frame representation from the cardinality/ownership lattice, with
the trail as the activation spine.** One decision fixes: whether a call uses
hardware-scratch or an image record; whether a value may be register-only or
needs an image home; whether "continuation = memcpy" is true at all; whether
reclamation is kernel-internal (so `!Outside` holds); and whether native
first-light is even *expressible*. Made right, it dissolves the call-model civil
war, the register-model split, and the never-free break simultaneously. Made
wrong at either extreme, the machine either cannot checkpoint (OneShot on `%rsp`
with no image home) or cannot loop (frames never freed).

**Keystone 2 — deterministic handle-space partitioning.** `native_m3 ==
native_m4` requires the encoder's byte output to be a pure deterministic function
of the graph, which requires handle assignment — and therefore code layout and
every emitted rel-offset — to be independent of core scheduling and allocation
order. Fixed per-core `(arena_id, offset)` partition; work-stealing is a
value-reproducible-only `~> Schedule` handler **never installed on the
self-hosting path** (the same handler-swap logic as persistence, `§4④`). This
kills the "two determinism modes" header flag — a drift-8 tell (a flag = an
unbuilt ADT/handler) the critic caught in three layers.

The keystones compound: keystone 1 makes the memcpy'd continuation *true*,
keystone 2 makes its bytes *reproducible*. Together they earn "image = binary =
process = checkpoint."

## §2 · The four systemic drifts, killed once at the substrate

The refuters found the same foreign-fluency in ≥3 layers each. Each is resolved
once here and inherited, never re-litigated:

- **`call`/`ret`/`%rsp` creeping back in.** The root is real: the CPU's
  Return-Stack-Buffer predictor makes `call`/`ret` cheap and an indirect
  `jmp [cursor]` trashes it — a genuine misprediction cliff the "control edge"
  abstraction never priced. The honest resolution is not denial: **use hardware
  `call`/`ret` exactly where the cardinality read proves a frame is OneShot,
  non-captured, and bounded-depth** — there the RSB is a legitimate hardware
  cache of the return-edge the graph already knows — and cross to image-frames at
  the perform/prompt boundary. State once, inherit everywhere.
- **Register allocation as a pass, renamed.** Belady's MIN (registers),
  linear-scan (target-isa), next-use eviction (codegen) — each rejects
  graph-coloring then imports its equivalent. The kernel-honest form: **residency
  is the use-count read; eviction is e-graph rematerialization** — a value that
  cannot fit is recomputed from its still-live e-graph producer (a pure `LConst`,
  an `LFieldLoad` from a live record) at the extraction cost the e-graph already
  computes, never round-tripped through a spill slot. No Belady, no second
  source of truth.
- **The global mode flag** (determinism modes, warm/cold call modes,
  substrate-effect-set-as-name-list). Every one is drift-8. A flag becomes an ADT
  or a `~>` handler.
- **The host OS primitive reached for to block** (`futex`/`MWAIT` at the "medium
  IS the OS" layer). A blocked-join cursor **reifies via the Yield/memcpy
  machinery it already owns and re-enters the gradient argmax** — a waiting cursor
  is just a cursor not currently selected.

And two deferrals recurred verbatim and are consolidated:

- **"the exact liveness/register-assignment computation"** appeared in *five*
  layers. It is ONE analysis — the escaping-row/ownership read extended to
  register-liveness at every call/perform crossing — built once as S2 below.
- **"gate on band-A `sound-neg-under-poly`"** is *honest* sequencing but its scope
  must be loud: **native codegen can SHIP before band A; its safety story —
  capability confinement, parallel-safety, IFC, `!Thread`/`!Alloc` transitivity —
  cannot be PROVEN until band A closes.** Buildable ≠ verifiable.

## §3 · The layers, corrected (the salvaged cores)

- **Image model.** Handle = a 32-bit image-base-relative *offset*, not a pointer;
  the image base lives in one reserved register (`r15`/`x28`), so every deref is
  one `mov reg,[base + h + disp]` and the whole range is relocatable by memcpy
  with zero fixups. `fn_ptr@0` reinterprets table-index → callee handle,
  byte-compatible with the WASM record. The image-map fold replaces the three
  magic region bases; the header is the fold's memoized limits, so the image is
  self-describing and needs no ELF section table. Page 0 (below `heap_base`) is
  `PROT_NONE` — the sentinel/heap discriminant becomes a hardware MMU guard, and
  every allocation is the allocator's, so nothing below the line is ever
  addressed. **Correction:** the
  persisted/shipped image is DATA-ONLY (arch-neutral); code is a runtime-only
  cache the receiving node re-projects (self-hosting projector), which is what
  keeps W^X honest and the image portable.
- **Frames / no-stack.** See §0/keystone 1 — the corrected form. Salvaged: FRAME
  = the unified record + `[cursor_edge@0][parent_frame@4][result_slot@8]`
  (cursor-as-PC, parent-edge-as-return, hole-as-perform-result). This is the one
  novel move that pays.
- **Continuations.** OneShot = call/return, no reification; MultiShot = own the
  captured frame segment, memcpy-clone only for parallel-to-a-core and
  durable-to-disk. Reification is *not* a stack copy — the frames already are
  data in the image. The `TCont` world-tag (last record field) rides the memcpy
  and is checked at rehydrate → `E_ResumeWorldMismatch`.
- **Registers.** `repr_regclass(Repr) → GPR|FP|VEC` is a clean third terminal
  projection beside `repr_wat`/`repr_width`. Residency from `use_profile`;
  eviction via e-graph remat (§2). Inside any MultiShot-capturable region, no
  value may be register-only (it needs an image home to flush at capture).
- **Codegen.** Native instruction selection is the same total deterministic
  projection `emit_expr` already is — `native.mn` a peer `~> NativeOut {
  emit_bytes([Byte]) }` handler on the same LowIR, identical `emit_module` driver,
  the Reason table a sixth projection over `project_emit_state`. Law 7: every
  WASM path byte-identical.
- **Compilation.** Per-fn epoch-memoized projection cell — `proj_epoch` widening
  `project_queue_merger`'s single global `last_epoch` to fn granularity;
  re-project one fn when `proj_epoch < subtree_epoch`. AOT/JIT/REPL/hot-reload =
  one cursor at different cache-warmth (the fixed point at the compilation scale).
- **Effects / OS.** perform = edge-follow = syscall (io.mn's WASI-as-effect is the
  proven template, WASM backend the peer). The substrate boundary is a **per-
  effect-declaration graph property** (an `EffectDeclKind` arm declares whether
  the op's bottom projects to an instruction) — not a name-list. Privilege = the
  row + the hardware cash-out of a trust-crossing install (PMP on bare metal).
- **Cores.** N cursors on the shared image; the `Schedule` is a `~>` peer handler
  catching the unchanged `LPerform(spawn/join)`; the fixed thread-record side-
  table dissolves into per-branch `[done_i][result_i]` slots on the fanout frame
  (Carried-Truth, kills the drift-7 array). **The effect-state race is a real
  soundness hole:** `$<hname>_state_g` is a mutable global, so a stateful effect
  inside `>< ~> Thread` has two cores racing one word. Race-freedom must be proven
  over the FULL row (input ownership AND effect state); a stateful effect in a
  parallel fanout is a compile-time refusal unless the handler is replicated-per-
  branch-and-merged (monoidal join) or the branches are proven `!<effect>`. This
  is the native face of band-A `sound-neg-under-poly`.
- **Verification.** Proof-carrying native: a position-independent ReasonMap keyed
  on region+handle (not absolute offset) maps each instruction range to its graph
  edge, so a fault projects back to the source (`mentl why` at the metal).
  Refinement checks Verify discharged are elided; negation is enforced by making
  the forbidden primitive un-selectable in the subgraph
  (`E_ForbiddenPrimitiveSelected`) — the negative proven by construction. GATED
  behind band A for the soundness certificate.
- **Target ISA / bootstrap.** Direct per-ISA byte encoders as `~>` handlers, peers
  of `wat_to_string` on the same LowIR; `MachineOp` is a projection *view*
  (generated-and-consumed, never a stored second IR). The linker is the image-map
  fold; the loader is `mmap`/self-locate. WASM stays the portability peer.

## §4 · Missing concerns the critique surfaced (none deferred)

- **FP/SIMD determinism — the silent fixpoint-killer.** The wheel computes floats
  during its own compilation; native x87 80-bit intermediates and FMA contraction
  are not bit-identical to WASM's strict IEEE-754, so `native_m3 != native_m4` on
  the first float unless native FP is pinned **SSE-only, no-FMA-contraction,
  round-to-nearest-even, defined NaN/denormal** (S10). SIMD lane groups must be
  seen by `use_profile` as one vector value or lanes mis-spill.
- **Foreign interop.** `~> Foreign` bottom handler, maximal-unknown row (`!Pure`),
  values copied at the boundary (ownership unprovable across it) — the one named
  `!Outside` seam for the un-Mentl world before it is all Mentl (S15).
- **Error/trap unwinding is trail-rollback** — Abort and refinement traps unwind
  by `graph_rollback` to the handler's checkpoint + a cursor reposition, the same
  primitive as MultiShot backtrack. Free, once §0 lands.
- **Self-hosting the encoder** — the WASM wheel cross-compiles `native.mn`
  (WASM-host → native-target) before it self-hosts; a backend swap, so
  m2≠m3-by-design across it, `native_m3 == native_m4` the check (S13),
  diverse-double-compilation (band J) closing trusting-trust.
- **Live observability + metal hot-reload** (band M) — the ReasonMap + capture-
  flush discipline make a running native cursor inspectable; concurrent code-patch
  is a real cross-core i-cache barrier with a quiescence rule keyed on
  `world_tag` epoch == `proj_epoch` (S18).

## §5 · The build spine — WASM wheel to native fixed point, no deferrals

Everything through **S12 is verifiable in the WASM peer before native exists** —
prove each projection against the standing `m3 == m4`, then swap the backend and
re-prove the fixpoint. That is the discipline's whole point.

- **S0** Reserved-register manifest + per-ISA Target descriptor (image-base,
  frontier, cursor/PC registers, the bounded-`%rsp` trap-scratch role,
  RegClass→physical-file table). One ADT, so three layers cannot pin different
  sets.
- **S1** `repr_regclass(Repr) → RegClass` — pure terminal beside
  `repr_wat`/`repr_width`. Law-7 no-op for WASM. The cleanest first cut.
- **S2** `use_profile` generalizing `count_uses` (own.mn:369, a bare Int-sum) to
  `(grade, sorted-use-positions, escape-bit)`, reading the escape set from lower's
  already-computed capture set — zero new escape analysis. THE one liveness
  analysis five layers needed.
- **S3** The cardinality→frame-representation classifier (**keystone 1**) —
  labels each activation HardwareScratch vs ImageRecord from the cardinality
  lattice + delimited-region containment. Verify in the WASM peer (assert it
  matches the existing tier selection). **← the WASM multi-shot work lands here.**
- **S4** Trail-as-activation-spine reclamation — segment exit does
  `graph_rollback`; a captured `k` owns its segment, freed at use-count 0. Loops
  O(1), no GC, no `%rsp`. Instrument the existing trail in the WASM peer to prove
  it. **← and here.**
- **S5** `native.mn` as a `~> NativeOut` peer handler, one ISA, LEAF fragment
  only. Milestone: a native leaf fn runs and returns.
- **S6** Call/return codegen for the two frame representations (keystone 1 →
  bytes); register-flush-at-capture at every MultiShot perform.
- **S7** Register residency + e-graph-remat eviction; max-materialized-set pre-
  sized over `use_profile`; clobber set as a monotone fixpoint (escaping_row
  precedent). Replaces Belady/linear-scan.
- **S8** The hardware-scratch trap seam — `%rsp` = a bounded per-core interrupt-
  frame arena; the trap handler marshals the CPU frame into an image continuation
  record, then the graph model resumes. The irreducible silicon seam, one copy.
- **S9** Eight-aspect selection completion (repr→regclass, verb→control,
  ownership→residency, row→capability gate at emit, reason→ReasonMap,
  refinement→elision, gradient→widths). Soundness certificate gated on band A.
- **S10** FP/SIMD determinism pinning — or the fixpoint fails on the first float.
- **S11** Deterministic handle-space partition (**keystone 2**); work-stealing a
  value-reproducible-only handler off the self-hosting path. Kills the mode flag.
- **S12** Effect-state parallel-safety gate — stateful effect in `>< ~> Thread` =
  a compile-time refusal unless replicated-and-merged or `!<effect>`. Native face
  of band A.
- **S13** WASM→native cross-compile — **NATIVE FIRST LIGHT**: `native_m3 ==
  native_m4`, micros + repro native, diverse-double-compilation closing
  trusting-trust. The machine is real here.
- **S14** Remaining ISAs as encoder-leaf swaps (explicit per-target selection, no
  false-uniform claim).
- **S15** `~> Foreign` bottom handler; hosted `~> Syscall` the minimal residue,
  bare-metal `~> Mmio`/`~> Hardware`.
- **S16** Address-space commitment — flat handle-addressed physical (PMP, explicit
  guards, COW=memcpy) for bare-metal; hosted static-PIE+mmap a peer
  `~> HostedImage` handler. 4GB is the RI32 floor, RI64 a repr cash-out.
- **S17** Boot/entry as one sequence — hosted (static-PIE → set base → partition
  arenas → find main's handle → first cursor step) and bare-metal (mask-ROM →
  DRAM-init firmware, the named `!Outside` → self-locate → first step).
- **S18** Live observability + metal hot-reload (band M) — `mentl where` live,
  per-fn re-projection, concurrent-patch i-cache barrier.

The load-bearing pivots are S3/S4 (keystone 1) and S11 (keystone 2). The FP gap
(S10) is the fixpoint-killer no single layer watched. Band A is the verifiability
ceiling under everything from S9 on: ship before it, prove after it.

## §6 · Where the WASM work fits — S3/S4, proven in the peer today

The multi-shot the WASM peer runs is S3/S4 *in that peer*: the resume grade is
inferred from each arm's body (SYNTAX §«Resume discipline»), a tail resume is a
direct call, a held or multi-shot perform reifies the frame's REMAINDER as a
record — the lowered frame zipped at the position, every value it reads after
the perform captured beside the world the perform ran in — and an arm that
never resumes unwinds the perform to the install whose arm answers. The native
frame classifier (S3) reads the same grade: a tail-resumed frame is hardware
scratch and a reified remainder is an image record, and the body an install
runs is the frame's own function, entered through the install's record (handler
= state = closure). Both are verifiable against `m3 == m4`.
