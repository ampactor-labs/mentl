#!/usr/bin/env bash
# thread-gate.sh — is the compile's concurrency width what we think it is?
#
# THE CLASS THIS EXISTS FOR, measured 2026-08-17 and closed at pin 3fc233421e
# (Hβ.infer.serialized-judge-still-spawns): §11 5.2 set judge_window = 1 to
# SERIALIZE the planned layer sweep. The window went to 1. THE SPAWN DID NOT.
# For ten days every compile paid one OS thread per layer branch to run those
# branches strictly one at a time — 433 distinct threads on `fn main() = 7`,
# wasi_thread_start at 48.45% inclusive, roughly HALF the compile. The whole
# board was green throughout, because no gate on it counted a thread.
#
# It was found by an aggregate profile someone happened to run. That is the
# part worth refusing to repeat: a constant said "serial", a comment three
# lines above it said "every layer branch runs as a REAL task", both were
# accurate, and prose adjacency caught nothing. Only a measurement did.
#
# WHY A DIFFERENTIAL AND NOT AN ABSOLUTE COUNT. wasmtime creates its own host
# threads for I/O and its pool, and how many is its business and changes with
# its version — an absolute ceiling here would be a ratchet on somebody else's
# implementation detail, red on an upgrade that changed nothing about us.
# Guest layer-branch spawns have a property host overhead does not: they SCALE
# WITH THE NUMBER OF LAYER BRANCHES. So the gate compiles two programs whose
# only difference is declaration count and reads the DELTA. Host overhead is
# identical in both and cancels; per-branch spawning cannot hide in it.
# Measured at this landing: 1 decl -> 11 clones, 61 decls -> 11 clones,
# delta 0. At the 433-thread shape the delta is the layer count.
#
# THE POSITIVE CONTROL IS THE LOAD-BEARING HALF and it is not optional: a
# counter that reads zero because it cannot see threads passes this gate
# forever while the defect walks through it. instrument-gate.sh was built
# after thirty roster items shipped gates that could not fail, and its own
# first run was vacuous. So leg 1 compiles and runs a fixture that really
# spawns and REQUIRES a delta above the floor. If leg 1 cannot go red, the
# other legs are evidence of nothing and this script says so and exits 1.
#
# WHEN PHASE 9.2 RESTORES judge_window = 8 the ratchet does not get deleted —
# it gets RE-BASELINED to the width the parallel walk is supposed to have, and
# it starts answering the question that matters then: is concurrency the width
# we think it is, still. Leg 3 is the half that survives unchanged, because a
# race's only symptom is run-to-run variance and that is precisely the symptom
# that hid the last one.
#
# THE CONFESSION (CLAUDE.md ⟳): every line below is a hand tool standing where
# a projection belongs. The medium performs wasi_thread_spawn through its own
# WasiThreads effect, so the honest form is the wheel reporting its own spawn
# count — `mentl march` printing concurrency beside the cost line it already
# prints, the row it already carries made visible. Named
# Hβ.march.concurrency-is-a-projection in RESIDUE; this script retires into it.
#
# Usage: tools/thread-gate.sh
# Exit:  0 the width is what we think it is, 1 it is not (or cannot be read).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tools/wt-env.sh"

BOOT="$ROOT/boot/mentl.wasm"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
say() { printf '%s\n' "$*"; }

# The instrument must exist. A missing strace is UNKNOWN, never green — the
# skipped-gate-reads-as-pass shape is the one PLAN §10 names outright.
if ! command -v strace >/dev/null 2>&1; then
  say "✗ thread gate: strace absent — the width is UNKNOWN, which is not green"
  exit 1
fi

# clones <argv…> — distinct OS threads the run created, counted at the
# syscall. Exact, not sampled: the polling method that first measured this
# class reads a task table at intervals and a short-lived thread can live and
# die between two reads. clone/clone3 cannot be missed.
clones() {
  strace -f -c -e trace=clone,clone3 -o "$T/st" "$@" >/dev/null 2>&1
  awk '/clone/{s+=$4} END{print s+0}' "$T/st"
}

m() { "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$T" --dir /tmp --dir "$ROOT::/mentl-home" "$BOOT" "$@"; }

# ── leg 1 · POSITIVE CONTROL — the counter can see a guest thread ──────────
# The fixture is the frontier's own real-spawn case: `2 <| (widen, widen)`
# under ~> parallel_compose, branches on host threads over the shared image.
# Linked and piped through STDIN exactly as frontier-gate builds it. The WAT
# byte count is asserted because a refused compile emits zero bytes and
# wat2wasm will happily assemble an empty module that "runs" at exit 0 —
# which is how the first draft of this leg measured nothing and passed.
cat "$ROOT/lib/memory.mn" "$ROOT/lib/strings.mn" "$ROOT/lib/lists.mn" \
    "$ROOT/lib/threading.mn" "$ROOT/lib/prelude.mn" \
    "$ROOT/tests/frontier/mn-real-spawn.mn" > "$T/spawn.mn"
wt_run "$BOOT" < "$T/spawn.mn" > "$T/spawn.wat" 2>"$T/spawn.err"
spawn_bytes=$(wc -c < "$T/spawn.wat")
if [ "$spawn_bytes" -lt 1000 ]; then
  say "✗ control: the spawn fixture emitted $spawn_bytes bytes — nothing was measured"
  exit 1
fi
wt_asm "$T/spawn.wat" "$T/spawn.wasm" 2>/dev/null || { say "✗ control: spawn fixture will not assemble"; exit 1; }

# THE CONTROL IS A TWIN, NOT A FLOOR. It compared the spawn fixture against
# `boot help` until 2026-09-06, and that is two DIFFERENT modules — 2.4MB
# against ~11KB — so the engine's own per-module compile threads rode in the
# baseline. Under the CLI the confound happened to point the right way (8 vs
# 15) and the leg passed; the moment the gates moved to the embedded runner it
# inverted (8 vs 6) and the control correctly declared the counter blind. It
# was right to fail, and it was right for the wrong reason: an absolute floor
# read off a different module is not a control at all.
# mn-scheduled-fanout-int is the SAME source one schedule apart — the `><`
# thesis twin, sequential_compose against parallel_compose, identical link set
# and near-identical size. Its delta is guest threads and nothing else, which
# is the property the ratchet below already relies on and the control had not
# been holding itself to.
cat "$ROOT/lib/memory.mn" "$ROOT/lib/strings.mn" "$ROOT/lib/lists.mn" \
    "$ROOT/lib/threading.mn" "$ROOT/lib/prelude.mn" \
    "$ROOT/tests/frontier/mn-scheduled-fanout-int.mn" > "$T/seq.mn"
wt_run "$BOOT" < "$T/seq.mn" > "$T/seq.wat" 2>"$T/seq.err"
seq_bytes=$(wc -c < "$T/seq.wat")
if [ "$seq_bytes" -lt 1000 ]; then
  say "✗ control: the sequential twin emitted $seq_bytes bytes — nothing was measured"
  exit 1
fi
wt_asm "$T/seq.wat" "$T/seq.wasm" 2>/dev/null || { say "✗ control: sequential twin will not assemble"; exit 1; }
seq_c=$(clones "$WT" run "${WT_RUN_FLAGS[@]}" "$T/seq.wasm")
spawn_c=$(clones "$WT" run "${WT_RUN_FLAGS[@]}" "$T/spawn.wasm")
if [ "$spawn_c" -gt "$seq_c" ]; then
  say "  ✓ control: one source, two schedules — parallel reads $spawn_c vs sequential $seq_c; the counter sees guest threads"
else
  say "  ✗ control: parallel reads $spawn_c, sequential twin $seq_c — THE COUNTER IS BLIND, every leg below is vacuous"
  exit 1
fi

# ── leg 2 · THE RATCHET — guest spawns do not scale with the program ───────
printf 'fn main() = 7\n' > "$T/one.mn"
python3 - "$T/many.mn" <<'PY'
import sys
# 60 independent declarations: 60 layer branches for the planned sweep, one
# for the trivial control. Independent on purpose — a dep chain would
# serialize the partition and hide per-branch spawning behind its own
# ordering, which would make this leg agree with a broken tree.
n = 60
with open(sys.argv[1], "w") as f:
    f.write("\n".join(f"fn f{i}(x) = x + {i}" for i in range(n)))
    f.write("\nfn main() = f0(1) + f%d(2)\n" % (n - 1))
PY
one_c=$(clones "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$T" --dir "$ROOT::/mentl-home" "$BOOT" check "$T/one.mn")
many_c=$(clones "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$T" --dir "$ROOT::/mentl-home" "$BOOT" check "$T/many.mn")
delta=$((many_c - one_c))
BASELINE="$ROOT/tools/verify-baseline.txt"
want=$(grep -E '^judge_spawn_delta_max:' "$BASELINE" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
if [ -z "$want" ]; then
  say "  · ratchet: judge_spawn_delta_max absent from verify-baseline.txt — not yet enforced"
else
  if [ "$delta" -le "$want" ]; then
    say "  ✓ ratchet: 1 decl -> $one_c threads, 61 decls -> $many_c, delta $delta (ceiling $want)"
  else
    say "  ✗ ratchet: delta $delta exceeds $want — per-branch spawning is back (1 decl $one_c, 61 decls $many_c)"
    say "    judge_window is in src/infer.mn; a block of one runs BrDirect by block size, not by reading it."
    fail=1
  fi
fi

# ── leg 3 · DETERMINISM — two draws, byte-identical ───────────────────────
# The half that matters when the width goes back up. A race in the judge has
# exactly one symptom, run-to-run variance, and it is the symptom that hid the
# 2026-08-07 garbled-cell race for as long as it hid: the judgment streams
# agreed while the emit differed, so anything coarser than a byte compare
# reported agreement. Cheap enough to run every time, which is the point —
# a determinism check you only run when you already suspect a race is a check
# that confirms suspicions rather than raising them.
m compile "$T/many.mn" > "$T/d1.wat" 2>/dev/null
m compile "$T/many.mn" > "$T/d2.wat" 2>/dev/null
d1=$(wc -c < "$T/d1.wat"); d2=$(wc -c < "$T/d2.wat")
if [ "$d1" -lt 1000 ] || [ "$d2" -lt 1000 ]; then
  say "  ✗ determinism: a draw emitted $d1 / $d2 bytes — nothing was compared"
  fail=1
elif cmp -s "$T/d1.wat" "$T/d2.wat"; then
  say "  ✓ determinism: two draws byte-identical ($d1 bytes)"
else
  say "  ✗ determinism: two draws of ONE source DIFFER ($d1 vs $d2 bytes) — the compile is racing"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  say "✓ thread gate: the compile's concurrency width is what the source says it is"
else
  say "✗ thread gate: the width is not what the source says it is"
fi
exit "$fail"
