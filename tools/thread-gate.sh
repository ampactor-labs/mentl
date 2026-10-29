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
# WHAT IT READS, AND WHY IT STOPPED COUNTING THREADS. The first form counted
# host OS threads at clone/clone3 under strace, as the delta between a
# 61-declaration program and a 1-declaration one. It went RED three times
# with no wheel change (2026-09-25, 09-27, 09-28: one host clone, "1 decl 9,
# 61 decls 10"), and the reason was in the boot's own import section: since
# the fan stopped spawning (9f766769, 2026-09-19) the wheel imports no
# `wasi.thread-spawn`, so the compile CANNOT create a guest thread and every
# clone the delta saw was the host's. The number stood in for two facts the
# medium already states exactly:
#   · the ARTIFACT — a module imports `wasi.thread-spawn` exactly when its
#     reached tree performs `spawn_task`, and declares its memory shared
#     exactly when it spawns or performs a SharedMemory operation;
#   · the CLAIM — `main`'s inferred row carries `WasiThreads` exactly when
#     the program performs a spawn, read by the medium's own `query` verb.
# Both are exact, neither sees a thread the host makes for itself, and a
# DISAGREEMENT between them is the class above: the source saying one width
# while the artifact runs another.
#
# THE POSITIVE CONTROL IS THE LOAD-BEARING HALF and it is not optional: a
# reader that answers "no spawn" because it cannot see one passes this gate
# forever while the defect walks through it. instrument-gate.sh was built
# after thirty roster items shipped gates that could not fail, and its own
# first run was vacuous. So leg 1 reads a program that really spawns and its
# sequential twin, and REQUIRES both readers to tell them apart. If leg 1
# cannot go red, the other legs are evidence of nothing and this script says
# so and exits 1.
#
# When PLAN §11.8 gives the judgment a width, that landing re-baselines leg 2.
# The import and memory reads are hand tools; the self-compile reporting its
# own width beside its cost line retires this script (PLAN §11.9).
#
# Usage: tools/thread-gate.sh
# Exit:  0 the width is what we think it is, 1 it is not (or cannot be read).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tools/wt-env.sh"

BOOT="${MENTL_BOOT:-$ROOT/boot/mentl.wasm}"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail=0
say() { printf '%s\n' "$*"; }

m() { "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir "$T" --dir /tmp --dir "$ROOT::/mentl-home" "$BOOT" "$@"; }

# spawn_import <module.wasm> — SPAWN or NONE for the wasi.thread-spawn import,
# then SHARED or OWNED for the memory, or UNREAD when the file is not a module.
# Each section is walked entry by entry, so no name is read misaligned.
spawn_import() {
  python3 - "$1" <<'PY'
import sys
def leb(b, i):
    r = s = 0
    while True:
        x = b[i]; i += 1
        r |= (x & 0x7f) << s; s += 7
        if x < 0x80:
            return r, i
def name(b, i):
    n, i = leb(b, i)
    return b[i:i + n].decode(), i + n
def limits(b, j):
    flags, j = leb(b, j); _, j = leb(b, j)
    if flags & 1:
        _, j = leb(b, j)
    return j
b = open(sys.argv[1], 'rb').read()
if b[:4] != b'\0asm':
    print('UNREAD'); sys.exit()
i, found, shared = 8, False, False
while i < len(b):
    sid = b[i]; size, j = leb(b, i + 1); start = j
    if sid == 5:
        shared = bool(b[leb(b, j)[1]] & 2)
    if sid == 2:
        n, j = leb(b, j)
        for _ in range(n):
            mod, j = name(b, j); field, j = name(b, j)
            found = found or (mod, field) == ('wasi', 'thread-spawn')
            kind = b[j]; j += 1
            if kind == 0:
                _, j = leb(b, j)
            elif kind == 1:
                j = limits(b, j + 1)
            elif kind == 2:
                shared = bool(b[j] & 2); j = limits(b, j)
            elif kind == 3:
                j += 2
            elif kind == 4:
                _, j = leb(b, j + 1)
    i = start + size
print(('SPAWN' if found else 'NONE') + (' SHARED' if shared else ' OWNED'))
PY
}

# spawn_row <file.mn> — SPAWN when the medium's row at `main` carries
# WasiThreads, NONE when it does not, UNREAD when the medium printed no row (a
# query that answered nothing measured nothing).
spawn_row() {
  local row
  row=$(m query "$1" "type main" 2>/dev/null | grep -m1 '^→')
  if [ -z "$row" ]; then
    echo UNREAD
  elif printf '%s\n' "$row" | grep -qw WasiThreads; then
    echo SPAWN
  else
    echo NONE
  fi
}

# ── leg 1 · POSITIVE CONTROL — both readers can see a spawn ─────────────────
# The frontier's own real-spawn case (`2 <| (widen, widen)` under
# ~> parallel_compose, branches on host threads over the shared image) and
# its sequential twin — one source, one schedule apart, §`><`'s thesis pair.
# Each is read twice: compiled, and its module's imports read; judged, and
# its row at main read. The four answers must split exactly by schedule. The
# WAT byte count is asserted because a refused compile emits zero bytes and
# wat2wasm happily assembled an empty module — which is how the first
# draft of this gate's control measured nothing and passed.
control() {
  local f="$1" want="$2" mem="$3" src="$T/$1.mn"
  { printf 'import threading\n'; cat "$ROOT/tests/frontier/$f.mn"; } > "$src"
  m compile "$src" > "$T/$f.wat" 2>"$T/$f.err"
  local bytes a b
  bytes=$(wc -c < "$T/$f.wat")
  if [ "$bytes" -lt 1000 ]; then
    say "  ✗ control: $f emitted $bytes bytes — nothing was measured"
    exit 1
  fi
  wt_asm "$T/$f.wat" "$T/$f.wasm" 2>/dev/null || { say "  ✗ control: $f will not assemble"; exit 1; }
  a=$(spawn_import "$T/$f.wasm")
  b=$(spawn_row "$src")
  if [ "$a" = "$want $mem" ] && [ "$b" = "$want" ]; then
    say "  ✓ control: $f reads $want twice — its module's imports and its row at main — and its memory $mem"
  else
    say "  ✗ control: $f should read $want with its memory $mem; its module says $a, its row says $b — THE READERS ARE BLIND, every leg below is vacuous"
    exit 1
  fi
}
control mn-real-spawn SPAWN SHARED
control mn-scheduled-fanout-int NONE OWNED

# ── leg 2 · THE BOOT — the compile runs on one instance ─────────────────────
# The judgment is one sequential pass since 2026-09-17 and the fan stopped
# spawning on 2026-09-19, so the boot must import no spawn, the wheel's row at
# main must carry none, and the two must agree. The memory is read from the
# module the compiler under test emits for the wheel (the next pin's shape at
# a transition), never from its own bytes, which the previous pin emitted.
a=$(spawn_import "$BOOT"); a=${a% *}
b=$(spawn_row "$ROOT/src/main.mn")
(cd "$ROOT" && m compile src/main.mn 2>/dev/null) > "$T/wheel.wat"
mem=$(grep -m1 -E '^ *\((memory|import "env" "memory")' "$T/wheel.wat" | grep -q shared && echo SHARED || echo OWNED)
[ -s "$T/wheel.wat" ] || mem=UNREAD
if [ "$a" = NONE ] && [ "$b" = NONE ] && [ "$mem" = OWNED ]; then
  say "  ✓ boot: one instance — the boot imports no wasi.thread-spawn, main's row carries no WasiThreads, and the wheel's module owns an unshared memory"
elif [ "$a" = UNREAD ] || [ "$b" = UNREAD ] || [ "$mem" = UNREAD ]; then
  say "  ✗ boot: a reader answered nothing (imports $a, row $b, memory $mem) — the width was not read"
  fail=1
elif [ "$a" = NONE ] && [ "$b" = NONE ]; then
  say "  ✗ boot: the wheel starts no thread but its module declares its memory shared, so an engine without the threads feature refuses it"
  fail=1
elif [ "$a" != "$b" ]; then
  say "  ✗ boot: the source and the artifact DISAGREE — main's row says $b, the boot's imports say $a"
  fail=1
else
  say "  ✗ boot: the compile spawns — the boot imports wasi.thread-spawn and main's row carries WasiThreads"
  say "    a width for the judgment is Phase 9.2's decision, and the landing that makes it re-baselines this leg."
  fail=1
fi

# ── leg 3 · DETERMINISM — two draws, byte-identical ───────────────────────
# The half that matters when the width goes back up. A race in the judge has
# exactly one symptom, run-to-run variance, and it is the symptom that hid the
# 2026-08-07 garbled-cell race for as long as it hid: the judgment streams
# agreed while the emit differed, so anything coarser than a byte compare
# reported agreement. Cheap enough to run every time, which is the point —
# a determinism check you only run when you already suspect a race is a check
# that confirms suspicions rather than raising them. Sixty independent
# declarations, so a future parallel walk has branches to race over.
python3 - "$T/many.mn" <<'PY'
import sys
n = 60
with open(sys.argv[1], "w") as f:
    f.write("\n".join(f"fn f{i}(x) = x + {i}" for i in range(n)))
    f.write("\nfn main() = f0(1) + f%d(2)\n" % (n - 1))
PY
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
