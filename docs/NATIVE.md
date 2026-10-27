# NATIVE.md — Mentl's native machine, graph to silicon

> This is a working document for band N (`§5.R`), not required reading, and the
> three-document contract still holds. It is the design and build plan for the
> native backend, which 24 agents designed, tried to refute and critiqued
> (2026-07-11). Question its claims before you rely on them.

## §0 · The thesis, and the one correction that made it real

In this design, native code generation is not "lower to assembly." The thesis
is that the graph image is the machine, the cursor is execution, and native
code is the cursor's cached projection. Ten layers were designed from that
thesis, and an adversary then tried to refute each one. Every refutation
arrived at the same correction. PLAN §0's convergence law says that when N
independent proposals arrive at one answer, that agreement is the signal that
the answer is true. By that law, the shared correction is the design, not a
setback:

> The addressing and projection substrate is right, and it is sharper than
> first stated. But "there is no stack" is false on the design's own hot path.
> The graph-image memory model, the handle as an offset, the eight-aspect
> projection and the assembler as a handler all hold. "Every frame is a heap
> record in the monotonic image, never freed" is SML/NJ's heap-allocated CPS
> without its garbage collector. A loop or a server would exhaust the image,
> and five layers use `%rsp` anyway without saying so.

The correction adds no stack back. It reads what the kernel already has:

The resume-cardinality/ownership grade decides how each frame is represented,
and the graph's own trail is the activation spine. The rest of the machine
depends on this decision, and it can be derived today from verified artifacts:

- OneShot activations (about 85% of activations are in this grade) can be
  reclaimed in LIFO order. They live in the one monotonic image. When a
  delimited segment exits, it reclaims its frames with `graph.mn`'s own
  `graph_rollback`, which costs O(M) and is the trail checkpoint that already
  records `trail_len` in O(1). Loops stay O(1), servers stay bounded, and there
  is no GC and no imported SysV stack. Reclamation happens inside the medium,
  so `!Outside` holds. The hardware `%rsp` is not the activation spine. Its
  only remaining use is a bounded per-core scratch area, which the CPU requires
  for delivering trap and interrupt frames.
- MultiShot (captured) continuations become persistent image records with the
  unified `handler = state = closure = continuation` shape, unchanged. The
  continuation is the captured segment, the chain of frames between the
  perform and the handler. `k` owns it, and it is freed when `k`'s use count
  reaches 0. With this correction, "continuation = memcpy" becomes true,
  because every frame, including the OneShot callers, is in the image.
  Persisting a continuation is a memcpy, and so is forking it to a core,
  exactly as the value layer (`§5.U`) describes.

The cardinality lattice that this session landed
(`resume grade = ownership grade`, one use count) decides whether a
continuation forks. The same read also decides the frame representation for
the entire machine. An `own`/OneShot frame is hardware scratch or a
trail-reclaimed image frame, and a `ref`/MultiShot frame is a captured image
record. Adding this one consumer of the same read fixes the primary break in
five layers at once.

## §1 · The two keystones

**Keystone 1: frame representation from the cardinality/ownership lattice, with
the trail as the activation spine.** This one decision settles all of these:
whether a call uses hardware scratch or an image record; whether a value may
live only in a register or needs a home in the image; whether "continuation =
memcpy" is true at all; whether reclamation stays inside the kernel (so
`!Outside` holds); and whether native first light (see S13) can even be
expressed. Made right, it resolves the conflict between the call models, the
split between the register models and the problem of frames that are never
freed, all at once. Made wrong in either direction, the machine either cannot
checkpoint (OneShot frames on `%rsp` with no home in the image) or cannot loop
(frames are never freed).

**Keystone 2: deterministic handle-space partitioning.** `native_m3 ==
native_m4` requires the encoder's byte output to be a pure, deterministic
function of the graph. That requires handle assignment, and therefore code
layout and every emitted relative offset, to be independent of core scheduling
and allocation order. Each core gets a fixed `(arena_id, offset)` partition.
Work stealing is a `~> Schedule` handler whose results are reproducible only as
values, and it is never installed on the self-hosting path (the same
handler-swap logic as persistence, `§4④`). This removes the "two determinism
modes" header flag. That flag is a drift-8 sign, a flag standing in for an ADT
or handler that was never built, and the critic found it in three layers.

The two keystones build on each other. Keystone 1 makes the memcpy'd
continuation correct, and keystone 2 makes its bytes reproducible. Together
they make "image = binary = process = checkpoint" true.

## §2 · The four systemic drifts, killed once at the substrate

The refuters found each of these habits, carried over from other languages and
compilers, in ≥3 layers. Each is resolved once here and inherited by every
layer, so it is not debated again:

- **`call`/`ret`/`%rsp` creeping back in.** The cause is real. The CPU's
  Return-Stack-Buffer predictor makes `call`/`ret` cheap, and an indirect
  `jmp [cursor]` defeats it. That causes a sharp rise in mispredictions, a cost
  the "control edge" abstraction never accounted for. The resolution is to use
  hardware `call`/`ret` exactly where the cardinality read proves a frame is
  OneShot, not captured and of bounded depth. There the RSB is a legitimate
  hardware cache of the return edge that the graph already records. At the
  perform/prompt boundary, the code switches to image frames. This rule is
  stated once here, and every layer inherits it.
- **Register allocation as a pass, renamed.** The registers layer proposed
  Belady's MIN, the target-isa layer linear scan, and the codegen layer
  next-use eviction. Each rejects graph coloring and then brings back its
  equivalent. The form that fits the kernel: residency is the use-count read,
  and eviction is e-graph rematerialization. A value that does not fit is
  recomputed from its e-graph producer, which is still live (a pure `LConst`,
  or an `LFieldLoad` from a live record), at the extraction cost the e-graph
  already computes. It is never stored to a spill slot and loaded back. This
  needs no Belady and no second source of truth.
- **The global mode flag** (determinism modes, warm/cold call modes, and the
  substrate's effect set kept as a list of names). Each of these is drift-8.
  The fix turns the flag into an ADT or a `~>` handler.
- **The host OS primitive reached for to block** (`futex`/`MWAIT` at the
  "medium IS the OS" layer). A cursor blocked on a join is reified through the
  Yield/memcpy machinery it already has, and then it re-enters the gradient
  argmax. A waiting cursor is simply a cursor that is not currently selected.

Two deferrals also appeared word for word in several layers, and they are
combined here:

- **"the exact liveness/register-assignment computation"** appeared in five
  layers. It is one analysis: the escaping-row/ownership read, extended to
  register liveness at every call/perform crossing. S2 below builds it once.
- **"gate on band-A `sound-neg-under-poly`"** is correct sequencing, but its
  scope must be stated plainly. Native codegen can ship before band A, but its
  safety claims (capability confinement, parallel safety, IFC, and
  `!Thread`/`!Alloc` transitivity) cannot be proven until band A closes.

## §3 · The layers, corrected (the salvaged cores)

- **Image model.** A handle is a 32-bit offset relative to the image base, not
  a pointer. The image base lives in one reserved register (`r15`/`x28`), so
  every dereference is one `mov reg,[base + h + disp]`, and the whole range can
  be relocated by memcpy with zero fixups. `fn_ptr@0` reinterprets a table
  index as a callee handle, byte-compatible with the WASM record. The image-map
  fold replaces the three magic region bases. The header holds the fold's
  memoized limits, so the image describes itself and needs no ELF section
  table. Page 0 (below `heap_base`) is `PROT_NONE`, so the sentinel/heap
  discriminant becomes a hardware MMU guard. Every allocation comes from the
  allocator, so nothing below that line is ever addressed. **Correction:** the
  image that is persisted or shipped holds only data and does not depend on the
  architecture. Code is a runtime-only cache that the receiving node projects
  again (with the self-hosting projector). This keeps W^X intact and the image
  portable.
- **Frames / no-stack.** §0/keystone 1 gives the corrected form. The part kept
  from this layer: a frame is the unified record plus
  `[cursor_edge@0][parent_frame@4][result_slot@8]` (the cursor as the PC, the
  parent edge as the return, the hole as the perform's result). This is the one
  new idea here that pays for itself.
- **Continuations.** A OneShot continuation is a plain call and return, with no
  reification. A MultiShot continuation owns the captured frame segment, and it
  is cloned by memcpy only to run in parallel on a core or to persist to disk.
  Reification does not copy a stack, because the frames are already data in the
  image. The `TCont` world tag (the record's last field) travels with the
  memcpy and is checked at rehydration; a mismatch is `E_ResumeWorldMismatch`.
- **Registers.** `repr_regclass(Repr) → GPR|FP|VEC` is a clean third terminal
  projection beside `repr_wat`/`repr_width`. Residency comes from
  `use_profile`, and eviction uses e-graph rematerialization (§2). Inside any
  region that a MultiShot continuation can capture, no value may live only in
  a register, because it needs a home in the image to be flushed to at capture.
- **Codegen.** Native instruction selection is the same total, deterministic
  projection that `emit_expr` already is. `native.mn` is a peer `~> NativeOut {
  emit_bytes([Byte]) }` handler on the same LowIR, identical `emit_module` driver,
  and the Reason table is a sixth projection over `project_emit_state`. Law 7
  holds: every WASM path stays byte-identical.
- **Compilation.** Each function has a projection cell memoized by epoch.
  `proj_epoch` widens `project_queue_merger`'s single global `last_epoch` to
  per-function granularity, and one function is projected again when
  `proj_epoch < subtree_epoch`. AOT, JIT, REPL and hot reload are one cursor at
  different levels of cache warmth (the fixed point at the scale of
  compilation).
- **Effects / OS.** A perform is an edge-follow, and the edge-follow is the
  syscall (io.mn's WASI-as-effect is the proven template, and the WASM backend
  is the peer). The substrate boundary is a graph property of each effect
  declaration, not a list of names: an `EffectDeclKind` arm declares whether
  the op's bottom projects to an instruction. Privilege is the row plus the
  hardware enforcement of an install that crosses a trust boundary (PMP on
  bare metal).
- **Cores.** N cursors run on the shared image. The `Schedule` is a `~>` peer
  handler that catches the unchanged `LPerform(spawn/join)`. The fixed
  thread-record side table is replaced by per-branch `[done_i][result_i]` slots
  on the fanout frame (by the Carried-Truth Law; this removes the drift-7
  array). **The effect-state race is a real soundness hole:**
  `$<hname>_state_g` is a mutable global, so a stateful effect inside
  `>< ~> Thread` has two cores racing on one word. Race freedom must be proven
  over the full row, which covers both input ownership and effect state. The
  compiler refuses a stateful effect in a parallel fanout unless the handler is
  replicated per branch and merged (a monoidal join) or the branches are proven
  `!<effect>`. This is how band-A `sound-neg-under-poly` appears in the native
  backend.
- **Verification.** Native code carries its proofs. A position-independent
  ReasonMap, keyed on region and handle (not on absolute offset), maps each
  instruction range to its graph edge, so a fault traces back to the source
  (`mentl why` at the machine level). Refinement checks that Verify has
  discharged are left out of the code. Negation is enforced by making the
  forbidden primitive impossible to select in the subgraph
  (`E_ForbiddenPrimitiveSelected`), so the negative is proven by construction.
  The soundness certificate waits on band A.
- **Target ISA / bootstrap.** Each ISA has a direct byte encoder written as a
  `~>` handler, a peer of `wat_to_string` on the same LowIR. `MachineOp` is a
  projection view: it is generated and consumed, and never stored as a second
  IR. The linker is the image-map fold, and the loader is `mmap` or
  self-location. WASM remains the peer that provides portability.

## §4 · Missing concerns the critique surfaced (none deferred)

- **FP/SIMD determinism, which can break the fixpoint without any warning.**
  The wheel computes floats during its own compilation. Native x87 80-bit
  intermediates and FMA contraction are not bit-identical to WASM's strict
  IEEE-754, so `native_m3 != native_m4` at the first float unless native FP is
  pinned to SSE only, no FMA contraction, round-to-nearest-even, and defined
  NaN/denormal handling (S10). `use_profile` must treat each group of SIMD
  lanes as one vector value, or the lanes are spilled incorrectly.
- **Foreign interop.** A `~> Foreign` bottom handler has the maximal unknown
  row (`!Pure`) and copies values at the boundary, because ownership cannot be
  proven across it. It is the one named `!Outside` boundary with code that is
  not Mentl, until everything is written in Mentl (S15).
- **Error/trap unwinding is trail-rollback.** Abort and refinement traps unwind
  with `graph_rollback` to the handler's checkpoint and then reposition the
  cursor, using the same primitive as MultiShot backtracking. Once §0 lands,
  this needs no extra work.
- **Self-hosting the encoder.** The WASM wheel cross-compiles `native.mn` (from
  a WASM host to a native target) before the native compiler hosts itself.
  That is a backend swap, so m2≠m3 by design across it, and the check is
  `native_m3 == native_m4` (S13). Diverse double-compilation (band J) closes
  the trusting-trust gap.
- **Live observability + metal hot-reload** (band M). The ReasonMap and the
  capture-flush discipline make a running native cursor inspectable. Patching
  code while it runs needs a real cross-core i-cache barrier, with a
  quiescence rule keyed on `world_tag` epoch == `proj_epoch` (S18).

## §5 · The build spine — WASM wheel to native fixed point, no deferrals

Every step through S12 can be verified in the WASM peer before the native
backend exists. Each projection is proven against the standing `m3 == m4`, and
then the backend is swapped and the fixpoint is proven again. That is the
purpose of this build order.

- **S0** A manifest of reserved registers and a Target descriptor for each ISA
  (the image-base, frontier and cursor/PC registers, the bounded-`%rsp`
  trap-scratch role, and the table from RegClass to physical register file).
  It is one ADT, so three layers cannot pin different sets.
- **S1** `repr_regclass(Repr) → RegClass`, a pure terminal beside
  `repr_wat`/`repr_width`. Under Law-7 it is a no-op for WASM. It is the
  cleanest first step.
- **S2** `use_profile` generalizes `count_uses` (own.mn:369, a bare Int sum) to
  `(grade, sorted-use-positions, escape-bit)`. It reads the escape set from the
  capture set that lower has already computed, so it adds no new escape
  analysis. This is the single liveness analysis that five layers needed.
- **S3** The classifier from cardinality to frame representation (keystone 1).
  It labels each activation HardwareScratch or ImageRecord from the cardinality
  lattice and delimited-region containment. Verify it in the WASM peer by
  asserting that it matches the existing tier selection. The WASM multi-shot
  work lands here.
- **S4** Reclamation with the trail as the activation spine. A segment's exit
  runs `graph_rollback`, and a captured `k` owns its segment, which is freed
  when its use count reaches 0. Loops stay O(1), with no GC and no `%rsp`.
  Instrument the existing trail in the WASM peer to prove it. The WASM
  multi-shot work also lands here.
- **S5** `native.mn` as a `~> NativeOut` peer handler, for one ISA and the leaf
  fragment only. Milestone: a native leaf function runs and returns.
- **S6** Call/return codegen for the two frame representations (keystone 1
  turned into bytes), with registers flushed at capture at every MultiShot
  perform.
- **S7** Register residency and eviction by e-graph rematerialization. The
  maximum materialized set is sized in advance from `use_profile`, and the
  clobber set is a monotone fixpoint (following the escaping_row precedent).
  This replaces Belady and linear scan.
- **S8** The hardware-scratch boundary for traps. `%rsp` is a bounded per-core
  arena for interrupt frames. The trap handler marshals the CPU frame into an
  image continuation record, and then the graph model resumes. This is the one
  boundary with the hardware that cannot be removed, and crossing it costs one
  copy.
- **S9** Complete the selection over the eight aspects (repr→regclass,
  verb→control, ownership→residency, row→capability gate at emit,
  reason→ReasonMap, refinement→elision, gradient→widths). The soundness
  certificate waits on band A.
- **S10** Pin FP/SIMD determinism. Without it, the fixpoint fails on the first
  float.
- **S11** Deterministic handle-space partition (keystone 2), with work stealing
  as a handler that reproduces only values, kept off the self-hosting path.
  This removes the mode flag.
- **S12** A parallel-safety gate for effect state: the compiler refuses a
  stateful effect in `>< ~> Thread` unless it is replicated and merged or
  `!<effect>`. This is band A as it appears in the native backend.
- **S13** WASM→native cross-compile, which is native first light: `native_m3 ==
  native_m4`, the micros and repro run natively, and diverse double-compilation
  closes the trusting-trust gap. The native machine exists from this step on.
- **S14** The remaining ISAs, each added by swapping the encoder leaf (with
  explicit selection per target and no false claim that targets are uniform).
- **S15** The `~> Foreign` bottom handler. Hosted, `~> Syscall` is the minimal
  remainder; on bare metal it is `~> Mmio`/`~> Hardware`.
- **S16** Commit to an address space. On bare metal it is flat physical memory
  addressed by handle (PMP, explicit guards, COW=memcpy). Hosted, it is
  static-PIE+mmap in a peer `~> HostedImage` handler. 4GB is the RI32 floor,
  and RI64 is a repr cash-out.
- **S17** Boot and entry as one sequence. Hosted: static-PIE → set base →
  partition arenas → find main's handle → first cursor step. Bare metal:
  mask-ROM → DRAM-init firmware (the named `!Outside`) → self-locate → first
  step.
- **S18** Live observability and hot reload on the metal (band M): `mentl where`
  on a running program, re-projection per function, and the i-cache barrier
  for concurrent patching.

The steps the rest depends on are S3/S4 (keystone 1) and S11 (keystone 2). The
FP gap (S10) can break the fixpoint, and no single layer was checking for it.
Band A limits what can be verified from S9 on: those steps can ship before
band A closes, but they can be proven only after it.

## §6 · Where the WASM work fits — S3/S4, proven in the peer today

The multi-shot support that the WASM peer runs is S3/S4 inside that peer. The
resume grade is inferred from each arm's body (SYNTAX §«Resume discipline»). A
tail resume is a direct call. A held or multi-shot perform reifies the rest of
the frame as a record: the lowered frame, zipped at the current position, with
every value it reads after the perform captured beside the world the perform
ran in. An arm that never resumes unwinds the perform to the install whose arm
answers it. The native frame classifier (S3) reads the same grade: a frame
resumed in tail position is hardware scratch, and a reified remainder is an
image record. The body that an install runs is the frame's own function,
entered through the install's record (handler = state = closure). Both can be
verified against `m3 == m4`.
