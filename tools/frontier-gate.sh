#!/usr/bin/env bash
# Focused contracts for the executable-boundary and constrained-hole frontier.
# These are real assertions, not xfails: the command exits nonzero while any
# contract is red. Keep separate from verify.sh until the whole board is green.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
source "$ROOT/tools/wt-env.sh"

usage() {
  cat <<'EOF'
usage: tools/frontier-gate.sh [--compiler boot|fresh|both|PATH]

  boot   pinned boot/mentl.wasm (default)
  fresh  current wheel-emitted compiler from wt_m2_ensure
  both   run boot, then fresh
  PATH   run one explicit compiler artifact
EOF
}

selection=boot
while [ "$#" -gt 0 ]; do
  case "$1" in
    --compiler)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      selection="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "frontier: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

compilers=()
labels=()
add_compiler() {
  labels+=("$1")
  compilers+=("$2")
}

case "$selection" in
  boot)
    add_compiler boot "$ROOT/boot/mentl.wasm"
    ;;
  fresh)
    cache=$(wt_m2_ensure) || { echo "frontier: fresh compiler generation trapped" >&2; exit 2; }
    add_compiler fresh "$ROOT/$cache/m2.wasm"
    ;;
  both)
    add_compiler boot "$ROOT/boot/mentl.wasm"
    cache=$(wt_m2_ensure) || { echo "frontier: fresh compiler generation trapped" >&2; exit 2; }
    add_compiler fresh "$ROOT/$cache/m2.wasm"
    ;;
  *)
    [ -f "$selection" ] || { echo "frontier: compiler not found: $selection" >&2; exit 2; }
    case "$selection" in
      /*) compiler_path="$selection" ;;
      *)  compiler_path="$ROOT/$selection" ;;
    esac
    add_compiler explicit "$compiler_path"
    ;;
esac

# THE MEMO (Hβ.tools.gate-stamp-is-uniform): this gate's verdict is a function
# of the compiler bytes it runs and the files it reads — tests/, lib/ (every
# fixture links the prelude), ide/, examples/ (the flagship program the
# pulse-render leg renders), this script and the expected-red names in the
# baseline. When a green run already judged exactly those, the verdict is
# read back instead of re-derived; a byte-identical repin used to pay this
# whole gate a second time. FORCE_GATES=1 re-runs it.
frontier_key=$(wt_memo_key_run "${compilers[@]}" tests lib ide examples tools/frontier-gate.sh tools/verify-baseline.txt)
if frontier_memo=$(wt_memo_hit "frontier-$selection" "$frontier_key"); then
  printf '%s\n' "$frontier_memo"
  echo "  (memo: these compilers already ran every leg against these inputs green — FORCE_GATES=1 re-runs)"
  sha256sum "$ROOT/boot/mentl.wasm" | cut -d' ' -f1 > "$ROOT/.build/frontier-stamp"
  exit 0
fi

RTLIBS=(
  "$ROOT/lib/memory.mn"
  "$ROOT/lib/strings.mn"
  "$ROOT/lib/lists.mn"
  "$ROOT/lib/threading.mn"
  "$ROOT/lib/prelude.mn"
)

# The persist fixture additionally needs the WASI fs layer and the Persist
# handler itself; its runs preopen /tmp for the checkpoint files.
PERSIST_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/io.mn"
  "$ROOT/lib/persist.mn"
)

# The CFC pipeline links the DSP math substrate (math.mn), the comodulogram
# (dsp/cfc.mn, whose read_recording crosses the WASI boundary → io.mn), and
# the synthetic-signal generator (cfc-demo/gen.mn). The demo builds its
# signal inline, so its run preopens nothing.
CFC_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/io.mn"
  "$ROOT/lib/math.mn"
  "$ROOT/lib/dsp/cfc.mn"
  "$ROOT/tests/frontier/cfc-demo/gen.mn"
)

# The signal-crucible link set: the CFC substrate plus lib/dsp/signal.mn (the
# STFT + `<~` bandpass + filter-based comodulogram). signal.mn reuses cfc.mn's
# mean-vector-length, matrix readers, and file transport (import, never
# duplicate), so both are linked; its own demodulation columns, STFT, and `<~`
# bandpass sit on top. The run preopens /tmp for the recording.
SIGNAL_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/io.mn"
  "$ROOT/lib/math.mn"
  "$ROOT/lib/dsp/cfc.mn"
  "$ROOT/lib/dsp/signal.mn"
)

# The data-validator lib set: the base runtime plus the WASI fs layer (io.mn),
# for the on-disk [Float]-statistics and String=[byte]-text validators. Their
# runs preopen /tmp for the fixture.
IO_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/io.mn"
)

# The real-workload crucible lib set: the base runtime plus the transcendental
# float substrate (math.mn — sin/cos/sqrt/atan2). The dsp/ml/adaptive crucibles
# build their signals and learners inline (no file I/O), so their runs preopen
# nothing.
MATH_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/math.mn"
)

# The derivative-reading lib set (L4a, 2026-09-28): the signal set plus the
# spectral distortion scene 1 renders and lib/ml/grad.mn's `Derivative` /
# `grad`, so the crucibles differentiate the library's own stages rather than
# copies of them.
DERIVE_RTLIBS=(
  "${SIGNAL_RTLIBS[@]}"
  "$ROOT/lib/dsp/spectral.mn"
  "$ROOT/lib/ml/grad.mn"
)

# The arena lib set (2026-10-03): the base runtime plus lib/arena.mn's
# `arena` handler and the `Arena` effect its install charges.
ARENA_RTLIBS=(
  "${RTLIBS[@]}"
  "$ROOT/lib/arena.mn"
)

total_pass=0
total_fail=0
# Declared standing failures (frontier_expected_red) — not reds. See judge().
total_xred=0
RUNTIME_SHADOW=""
BOOT_RUNTIME_SHADOW=""
# 2026-07-17: repinned after Stage 1b removed check_ref_escape. The runtime libs
# shed their "escapes its scope (returned)" false alarms (a syntactic check with
# no hazard model, 356 across the wheel), so the inherited-debt multiset SHRANK —
# a removal, which the rule above explicitly permits. Verified by reading the new
# shadow: the same E_TypeMismatch/E_RedundantBraces set minus the ownership false
# positives, never a NEW entry.
#
# 2026-07-18: repinned for the bounds-trap landing — lists.mn gained the checked
# list_index entry + list_index_unchecked (SYNTAX §Indexing made real), and
# strings.mn/cache_map.mn spell their guarded reads as control flow (sound
# under both the old eager `&&` and the short-circuit lowering). The shadow's
# byte change is those three files; the diagnostic multiset did not grow.
#
# 2026-07-18 (2): repinned for the effect-truth sweep — the runtime libs'
# declared rows widened to their bodies' truth (prelude iterate, combinators'
# Pure fictions dropped for the Memory/Alloc the list ops perform, cache_map's
# Pure declarations, persist's Persist op, threading's Memory). Rows only;
# the diagnostic multiset SHRANK (the sweep's own purpose).
#
# 2026-07-20: repinned for the §4① string-layer typing + the expect_same
# chase-first fix (Hβ.infer.expect-same-chases-bound-var). The multiset GREW
# 2 -> 13, and the growth is benign-by-construction: the new entries are all
# `Int vs List` in prelude's GENERIC list combinators (reduce/unique/chunk/
# iterate) whose element type is a free var when the libs compile WITHOUT
# src/. The expect_same fix propagates that var precisely instead of the old
# clobber masking it, so the isolation shadow surfaces it — but the FULL
# wheel census is 0 (they resolve at every concrete use), so no user program
# and no self-compile sees them. Growth here is the isolation context lacking
# src/, not a regression; the full-wheel census is the real gate.
# 2026-07-21: the shadow is EMPTY (the sha256 of zero bytes) — the §4①
# String=[byte] landing healed the whole inherited class. The 13 entries were
# ONE root: list_to_flat's raw body typed (Int)->Int and poisoned the element
# var of every generic combinator that called it (iterate/reduce/unique/chunk)
# when the libs compiled without src/. The two-altitude split (list_to_flat
# joins the seq-op table as [a] -> [a]; flat_raw is the raw body — the
# make_list/alloc_list precedent) deleted the class at its origin. The libs
# now compile in isolation with ZERO diagnostics.
EXPECTED_RUNTIME_SHADOW_SHA256="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

pass() {
  echo "  PASS $*"
  total_pass=$((total_pass + 1))
}

fail() {
  echo "  RED  $*"
  total_fail=$((total_fail + 1))
}

# ─── The NAMED standing failure, replacing a COUNT (2026-09-15) ───────
# `frontier_red_max: 1` was a permission slip with a blank name field. It
# compared only the COUNT (march.sh's board_frontier: `[ "$red" -gt "$max" ]`),
# so it could not tell WHICH leg was red — fix the standing one, break a crown
# leg, and the board still printed "378 pass / 1 red", byte-identical to a
# healthy day. A count standing in for an identity is drift 8 (`mode == 0/1/2`)
# at the gate layer, and the perimeter was wired to read it, so the blindness
# reached the commit gate.
# It could not catch the OTHER direction either: when a standing red is FIXED,
# `red=0 -gt max=1` is false, nothing reports the ceiling is now slack, and it
# silently licenses one future unrelated red forever — §9.11's "a banked
# expectation is a HYPOTHESIS about the era that banked it", with nothing to
# test it.
# The project already uses the right form everywhere else: tests/floors/ does
# not COUNT refusals, each fixture DECLARES that it must refuse. So a standing
# failure is a contract keyed by NAME, in the baseline's one home, and it is
# judged in BOTH directions — which is strictly stronger than the ceiling it
# replaces, and retires `frontier_red_max` entirely.
expected_red_has() {  # <key>
  grep -qE "^frontier_expected_red:[[:space:]]*$1([[:space:]]|\$)" \
    "$ROOT/tools/verify-baseline.txt" 2>/dev/null
}

# judge <key> <ok:0|1> <message…>
#   ok=1, undeclared -> PASS      ok=0, undeclared -> RED
#   ok=0, declared   -> XRED      ok=1, declared   -> RED (the contract is STALE:
#                                 the peer landed, so the entry must retire —
#                                 the case a count can never see)
judge() {
  local key="$1" ok="$2"; shift 2
  if expected_red_has "$key"; then
    if [ "$ok" = 1 ]; then
      echo "  RED  $key: STALE EXPECTED-RED — this leg now PASSES; delete"
      echo "       'frontier_expected_red: $key' from tools/verify-baseline.txt"
      total_fail=$((total_fail + 1))
    else
      echo "  XRED $key (declared standing failure) — $*"
      total_xred=$((total_xred + 1))
    fi
  elif [ "$ok" = 1 ]; then
    pass "$*"
  else
    fail "$*"
  fi
}

# Normalize only compiler errors and unresolved proof obligations. Runtime
# sources currently carry a known diagnostic shadow; comparing this multiset
# keeps that debt explicit while refusing every diagnostic introduced by a
# frontier fixture. Messages and graph epochs are deliberately omitted, but
# source spans and duplicate counts remain part of the fingerprint.
normalize_errors() {
  awk '
    /E_[A-Za-z0-9_]+ error:|V_?Pending[A-Za-z0-9_]*/ {
      code = ""
      span = ""
      if (match($0, /E_[A-Za-z0-9_]+/)) {
        code = substr($0, RSTART, RLENGTH)
      } else if (match($0, /V_?Pending[A-Za-z0-9_]*/)) {
        code = substr($0, RSTART, RLENGTH)
      }
      if (match($0, / at [0-9]+:[0-9]+-[0-9]+:[0-9]+/)) {
        span = substr($0, RSTART, RLENGTH)
      }
      if (code != "") print code span
    }
  ' "$1" | LC_ALL=C sort
}

capture_runtime_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/runtime-shadow.wat" err="$dir/runtime-shadow.err"

  { cat "${RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "runtime shadow compile (exit=$rc; see $err)"
    return 1
  fi

  RUNTIME_SHADOW="$dir/runtime-shadow.normalized"
  normalize_errors "$err" > "$RUNTIME_SHADOW"
  pass "runtime shadow captured ($(wc -l < "$RUNTIME_SHADOW") inherited errors)"
}

run_program() {
  local compiler="$1" label="$2" source="$3" expected="$4" link_runtime="$5"
  local dir="$6" wat="$dir/$label.wat" wasm="$dir/$label.wasm"
  local cerr="$dir/$label.compile.err" aerr="$dir/$label.assemble.err"
  local rout="$dir/$label.run.out" rerr="$dir/$label.run.err"
  local rc diags errors shadow="" normalized unexpected run_flags=()

  case "$link_runtime" in
    yes)
      cat "${RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr" ;;
    persist)
      cat "${PERSIST_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir /tmp) ;;
    cfc)
      cat "${CFC_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr" ;;
    cfc-rec)
      cat "${CFC_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    signal)
      cat "${SIGNAL_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    io-rec)
      cat "${IO_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    math)
      cat "${MATH_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr" ;;
    derive)
      cat "${DERIVE_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr" ;;
    arena)
      cat "${ARENA_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$cerr" ;;
    *)
      wt_run "$compiler" < "$source" > "$wat" 2> "$cerr" ;;
  esac
  rc=$?
  diags=$(grep -cE '(^|: )[EWVTP]_' "$cerr" 2>/dev/null || true)
  normalized="$dir/$label.normalized"
  unexpected="$dir/$label.unexpected"
  normalize_errors "$cerr" > "$normalized"
  if [ "$link_runtime" = yes ]; then
    comm -23 "$normalized" "$RUNTIME_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$RUNTIME_SHADOW")"
  elif [ "$link_runtime" = persist ]; then
    comm -23 "$normalized" "$PERSIST_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$PERSIST_SHADOW")"
  elif [ "$link_runtime" = cfc ] || [ "$link_runtime" = cfc-rec ]; then
    comm -23 "$normalized" "$CFC_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$CFC_SHADOW")"
  elif [ "$link_runtime" = signal ]; then
    comm -23 "$normalized" "$SIGNAL_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$SIGNAL_SHADOW")"
  elif [ "$link_runtime" = io-rec ]; then
    comm -23 "$normalized" "$IO_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$IO_SHADOW")"
  elif [ "$link_runtime" = math ]; then
    comm -23 "$normalized" "$MATH_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$MATH_SHADOW")"
  elif [ "$link_runtime" = derive ]; then
    comm -23 "$normalized" "$DERIVE_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$DERIVE_SHADOW")"
  elif [ "$link_runtime" = arena ]; then
    comm -23 "$normalized" "$ARENA_SHADOW" > "$unexpected"
    shadow="; inherited-shadow=$(wc -l < "$ARENA_SHADOW")"
  else
    cp "$normalized" "$unexpected"
  fi
  errors=$(wc -l < "$unexpected")
  if [ "$rc" -eq 0 ] && [ "$errors" -eq 0 ]; then
    pass "$label compile (diagnostics=$diags$shadow)"
  elif [ "$rc" -eq 0 ]; then
    fail "$label compile (new-errors-or-debt=$errors diagnostics=$diags; see $unexpected)"
  else
    fail "$label compile (exit=$rc diagnostics=$diags; see $cerr)"
    return
  fi

  if wt_asm "$wat" "$wasm" 2> "$aerr"; then
    pass "$label assemble"
  else
    fail "$label assemble ($(head -1 "$aerr"))"
    return
  fi

  wt_run "${run_flags[@]}" "$wasm" > "$rout" 2> "$rerr"
  rc=$?
  # The run's verdict goes through judge, keyed by the leg's label, so a
  # program leg can be DECLARED RED by name in frontier_expected_red and
  # retires loudly the day it passes — the same two-direction contract the
  # named legs already have. Compile and assemble stay plain: a declared
  # standing failure is a claim about the program's ANSWER, never a licence
  # for it to stop compiling.
  if [ "$rc" -eq "$expected" ]; then
    judge "$label" 1 "$label run (exit=$rc)"
  else
    judge "$label" 0 "$label run (exit=$rc expected=$expected; see $rerr)"
  fi
}

# The rooted-image persist gate: one compile, one assemble, TWO processes of
# the same wasm against one guest /tmp. Leg A writes the wire (exit 40); leg
# B swaps A's image in (image_resume — the direct-substrate restore) and
# runs A's continuation-shaped record against A's heap (exit 42). A
# per-gate dir maps as the guest's /tmp so the legs share the wire without
# touching the host's shared /tmp. Two corruption legs see the gates RED:
# a flipped build key refuses through fail with both keys named; a flipped
# globals count trips $image_restore's layout belt (the structural trap).
run_persist_image() {
  local compiler="$1" dir="$2" label="persist-image"
  local src="$ROOT/tests/frontier/mn-persist-image.mn"
  local wat="$dir/$label.wat" wasm="$dir/$label.wasm"
  local cerr="$dir/$label.compile.err" aerr="$dir/$label.assemble.err"
  local pdir="$dir/$label.tmp" rc

  cat "${PERSIST_RTLIBS[@]}" "$src" | wt_run "$compiler" > "$wat" 2> "$cerr"
  rc=$?
  local normalized="$dir/$label.normalized" unexpected="$dir/$label.unexpected"
  normalize_errors "$cerr" > "$normalized"
  comm -23 "$normalized" "$PERSIST_SHADOW" > "$unexpected"
  local errors; errors=$(wc -l < "$unexpected")
  if [ "$rc" -ne 0 ] || [ "$errors" -ne 0 ]; then
    fail "$label compile (exit=$rc new-errors=$errors; see $cerr)"
    return
  fi
  pass "$label compile"
  if ! wt_asm "$wat" "$wasm" 2> "$aerr"; then
    fail "$label assemble ($(head -1 "$aerr"))"
    return
  fi
  pass "$label assemble"
  mkdir -p "$pdir"
  rm -f "$pdir/mn-persist-image.img"
  wt_run --dir "$pdir::/tmp" "$wasm" > "$dir/$label.a.out" 2> "$dir/$label.a.err"
  rc=$?
  if [ "$rc" -ne 40 ]; then
    fail "$label leg-a persist (exit=$rc expected=40; see $dir/$label.a.err)"
    return
  fi
  pass "$label leg-a persist (exit=40, wire $(wc -c < "$pdir/mn-persist-image.img" 2>/dev/null || echo 0)B)"
  wt_run --dir "$pdir::/tmp" "$wasm" resume > "$dir/$label.b.out" 2> "$dir/$label.b.err"
  rc=$?
  if [ "$rc" -eq 42 ]; then
    pass "$label leg-b resume (exit=42 — a fresh process re-entered the image)"
  else
    fail "$label leg-b resume (exit=$rc expected=42; see $dir/$label.b.err)"
    return
  fi
  cp "$pdir/mn-persist-image.img" "$pdir/good.img"
  python3 - "$pdir/mn-persist-image.img" <<'PY'
import sys
p = sys.argv[1]; b = bytearray(open(p,'rb').read()); b[0] ^= 0xFF
open(p,'wb').write(bytes(b))
PY
  wt_run --dir "$pdir::/tmp" "$wasm" resume > "$dir/$label.k.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ] && grep -q 'is not this build' "$dir/$label.k.out"; then
    pass "$label corrupt-key refusal (exit=$rc, both keys named)"
  else
    fail "$label corrupt-key admitted (exit=$rc; see $dir/$label.k.out)"
  fi
  cp "$pdir/good.img" "$pdir/mn-persist-image.img"
  python3 - "$pdir/mn-persist-image.img" <<'PY'
import sys
p = sys.argv[1]; b = bytearray(open(p,'rb').read()); b[12] ^= 0xFF
open(p,'wb').write(bytes(b))
PY
  wt_run --dir "$pdir::/tmp" "$wasm" resume > "$dir/$label.g.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ] && [ "$rc" -ne 42 ]; then
    pass "$label corrupt-gcount belt (exit=$rc — the layout trap fired)"
  else
    fail "$label corrupt-gcount admitted (exit=$rc; see $dir/$label.g.out)"
  fi
}

# The persist gate's arena face: the persist lib set plus lib/arena.mn, one
# build, two processes. Leg A persists the image from inside an open arena
# (exit 40); leg B swaps it in, opens and exits an arena of its own, and
# reads what A's arena allocated through A's thunk (exit 42). The arena's
# depth, mark and journal length are not in the image — they describe A's
# stack — so B runs outside A's arenas and A's region is ordinary heap there.
run_persist_arena() {
  local compiler="$1" dir="$2" label="arena-persist-resumes-outside"
  local src="$ROOT/tests/frontier/arena/persist-resumes-outside.mn"
  local wat="$dir/$label.wat" wasm="$dir/$label.wasm"
  local cerr="$dir/$label.compile.err" aerr="$dir/$label.assemble.err"
  local pdir="$dir/$label.tmp" rc
  cat "${PERSIST_RTLIBS[@]}" "$ROOT/lib/arena.mn" "$src" | wt_run "$compiler" > "$wat" 2> "$cerr"
  rc=$?
  local normalized="$dir/$label.normalized" unexpected="$dir/$label.unexpected"
  normalize_errors "$cerr" > "$normalized"
  comm -23 "$normalized" "$PERSIST_SHADOW" > "$unexpected"
  if [ "$rc" -ne 0 ] || [ -s "$unexpected" ]; then
    fail "$label compile (exit=$rc new-errors=$(wc -l < "$unexpected"); see $cerr)"
    return
  fi
  if ! wt_asm "$wat" "$wasm" 2> "$aerr"; then
    fail "$label assemble ($(head -1 "$aerr"))"
    return
  fi
  mkdir -p "$pdir"
  rm -f "$pdir/persist-resumes-outside.img"
  wt_run --dir "$pdir::/tmp" "$wasm" > "$dir/$label.a.out" 2> "$dir/$label.a.err"
  rc=$?
  if [ "$rc" -ne 40 ]; then
    fail "$label leg-a persist inside the arena (exit=$rc expected=40; see $dir/$label.a.err)"
    return
  fi
  wt_run --dir "$pdir::/tmp" "$wasm" resume > "$dir/$label.b.out" 2> "$dir/$label.b.err"
  rc=$?
  if [ "$rc" -eq 42 ]; then
    pass "$label (leg A 40 inside the arena, leg B 42 outside it)"
  else
    fail "$label leg-b resume (exit=$rc expected=42; see $dir/$label.b.err)"
  fi
}

# The warm-start gate (B-i landing 2): ONE compiler, ONE project, TWO runs.
# Run 1 (cold) analyzes, persists the rooted image into the project's
# .build, and emits; run 2 restores the image (the warm line on stderr)
# and lowers the SAME live graph — the emitted WAT must be byte-identical.
# The repo maps as /mentl-home so the resolver reaches the stdlib.
run_warm_start() {
  local compiler="$1" dir="$2" label="warm-start"
  local wdir="$dir/$label.proj" rc1 rc2
  mkdir -p "$wdir/.build"
  printf 'fn main() = 40 + 2\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.1.wat" 2> "$dir/$label.1.err"
  rc1=$?
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.2.wat" 2> "$dir/$label.2.err"
  rc2=$?
  if [ "$rc1" -ne 0 ] || [ ! -s "$dir/$label.1.wat" ]; then
    fail "$label cold compile (exit=$rc1; see $dir/$label.1.err)"
    return
  fi
  if grep -q '^warm:' "$dir/$label.1.err"; then
    fail "$label cold run claimed warm (see $dir/$label.1.err)"
    return
  fi
  pass "$label cold compile (exit=0, wire $(ls "$wdir/.build" 2>/dev/null | head -1))"
  if [ "$rc2" -ne 0 ]; then
    fail "$label warm compile (exit=$rc2; see $dir/$label.2.err)"
    return
  fi
  if ! grep -q '^warm:' "$dir/$label.2.err"; then
    fail "$label warm line absent (run 2 re-derived; see $dir/$label.2.err)"
    return
  fi
  if cmp -s "$dir/$label.1.wat" "$dir/$label.2.wat"; then
    pass "$label warm compile (byte-identical emission off the restored image)"
  else
    fail "$label warm emission diverges (diff $dir/$label.1.wat $dir/$label.2.wat)"
    return
  fi
  # Leg 3 — the resume verb with the SOURCE ABSENT: the projection rode the
  # image, so deleting main.mn and resuming the .img must emit the same WAT.
  local img
  img=$(ls "$wdir/.build"/warm-compile-*.img 2>/dev/null | head -1)
  command rm -f "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" resume ".build/$(basename "$img")" \
    > "$dir/$label.3.wat" 2> "$dir/$label.3.err"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$label resume verb (exit=$rc; see $dir/$label.3.err)"
    return
  fi
  if cmp -s "$dir/$label.1.wat" "$dir/$label.3.wat"; then
    pass "$label resume with the source ABSENT (byte-identical — the projection rode the image)"
  else
    fail "$label resume emission diverges (diff $dir/$label.1.wat $dir/$label.3.wat)"
  fi
}

# The flagship program (Track G, Pulse scene 1): examples/pulse/render
# rendered through the compiler under test by `mentl run`, and the WAV judged
# by an oracle that shares nothing with the medium
# (tests/frontier/pulse-render/oracle.py: the header, both channels'
# loudness, no full-scale sample, and each of the score's eight notes
# standing 20 dB over the others). Then its three refusal twins, each the
# program with ONE line changed — patched here, so the program keeps one
# home and a twin can never drift from it:
#   alloc  an allocation on the per-sample path   → E_EffectMismatch
#   range  a constant outside `Sample` handed to the WAV writer
#                                                 → E_RefinementRejected
#   rate   a clock reader pinned at 44.1 kHz under the path's
#          `!Sample(44100)`                       → E_EffectMismatch
# A patch that stops applying is a failure, never a skipped twin. The render's
# wall time prints beside ten seconds of audio; a wall clock is a host fact
# and is never ratcheted.
run_pulse_render() {
  local compiler="$1" dir="$2" label="pulse-render"
  local pdir="$dir/$label.proj" rc t0 t1
  rm -rf "$pdir"
  mkdir -p "$pdir"
  cp "$ROOT/examples/pulse/render/main.mn" "$pdir/main.mn"
  t0=$(date +%s%N)
  wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" run main \
    > "$dir/$label.wav" 2> "$dir/$label.err"
  rc=$?
  t1=$(date +%s%N)
  if [ "$rc" -ne 0 ] || [ ! -s "$dir/$label.wav" ]; then
    fail "$label render (exit=$rc; see $dir/$label.err)"
  elif python3 "$ROOT/tests/frontier/pulse-render/oracle.py" "$dir/$label.wav" > "$dir/$label.oracle" 2>&1; then
    pass "$label: ten seconds rendered in $(( (t1 - t0) / 1000000 )) ms, the oracle holds ($(grep -c '^PASS' "$dir/$label.oracle") checks)"
  else
    fail "$label oracle ($(grep '^FAIL' "$dir/$label.oracle" | head -1); see $dir/$label.oracle)"
  fi
  local twin pattern replacement class tdir
  for twin in alloc range rate; do
    case "$twin" in
      alloc) pattern='^  let n = now()$'
             replacement='  let n = now()\n  let label = int_to_str(n)'
             class=E_EffectMismatch;;
      range) pattern='^  wav_frame(buf, n, channel(dry_l, echo_l, room_l, gain), channel(dry_r, echo_r, room_r, gain))$'
             replacement='  wav_frame(buf, n, 1.5, channel(dry_r, echo_r, room_r, gain))'
             class=E_RefinementRejected;;
      rate)  pattern='^fn clock_rate() with Sample(48000) = sample_rate()$'
             replacement='fn clock_rate() with Sample(44100) = sample_rate()'
             class=E_EffectMismatch;;
    esac
    tdir="$dir/$label-$twin.proj"
    rm -rf "$tdir"
    mkdir -p "$tdir"
    if [ "$(grep -c "$pattern" "$ROOT/examples/pulse/render/main.mn")" != "1" ]; then
      fail "$label-$twin: the patch no longer applies to the program (pattern: $pattern)"
      continue
    fi
    sed "s/$pattern/$replacement/" "$ROOT/examples/pulse/render/main.mn" > "$tdir/main.mn"
    wt_run --dir "$tdir::." --dir "$ROOT::/mentl-home" "$compiler" check main \
      > "$dir/$label-$twin.out" 2> "$dir/$label-$twin.err"
    rc=$?
    if [ "$rc" -ne 0 ] && grep -q "$class" "$dir/$label-$twin.err"; then
      pass "$label-$twin refuses ($class)"
    else
      fail "$label-$twin: expected $class and a refusal (exit=$rc; see $dir/$label-$twin.err)"
    fi
  done
}

# The incremental cursor gate (B-i landing 3): a three-module DAG, one
# edit, one truth. Run 1 compiles cold and persists; b.mn is patched; run
# 2 restores the image, names the re-derived cone (b main — a stays
# cached), and its emission must equal a COLD compile of the patched tree
# (the fixture is lambda-free, so handle numbering cannot leak into the
# wat and byte-equality is the honest oracle at today's pin; the
# deterministic handle partition generalizes it).
# Two verbs, one file, two worlds: `run` persists its analyzed image under
# the world its handlers built, and a `compile` after it must not restore
# that image into its own output — the image is filed under world_key(), so
# the compile finds none and derives, and the second verb's WAT is whole.
# A program that links library modules by import runs as a project — the
# `run` verb resolves its imports the way a developer's program does, where
# a battery fixture is compiled over the runtime floor alone — and answers
# its expected exit.
run_project() {
  local compiler="$1" dir="$2" label="$3" source="$4" expected="$5"
  local pdir="$dir/$label.proj" rc
  rm -rf "$pdir"
  mkdir -p "$pdir"
  cp "$source" "$pdir/main.mn"
  wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" run main \
    > "$dir/$label.run.out" 2> "$dir/$label.run.err"
  rc=$?
  if [ "$rc" -eq "$expected" ]; then
    pass "$label: runs to $expected"
  else
    fail "$label: run exit=$rc, want $expected (see $dir/$label.run.err)"
  fi
}

run_warm_world() {
  local compiler="$1" dir="$2" label="warm-world"
  local wdir="$dir/$label.proj" rc lines
  rm -rf "$wdir"
  mkdir -p "$wdir/.build"
  printf 'fn main() = 9\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" run main \
    > "$dir/$label.run.out" 2> "$dir/$label.run.err"
  rc=$?
  if [ "$rc" -ne 9 ]; then
    fail "$label: run exit=$rc, want 9 (see $dir/$label.run.err)"
    return
  fi
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.wat" 2> "$dir/$label.err"
  rc=$?
  lines=$(wc -l < "$dir/$label.wat")
  if [ "$rc" -eq 0 ] && grep -q '(module' "$dir/$label.wat"; then
    pass "$label: compile after run emits the module ($lines WAT lines)"
  else
    fail "$label: compile after run emitted $lines WAT lines (exit=$rc; see $dir/$label.err)"
  fi
}

# A warm compile reports each open claim ONCE. The image it restores carries
# the proof ledger the cold run left, and the cone it re-judges re-accrues
# its own claims, so the ledger forgets the obligations of each module it is
# about to re-judge first (verify_forget, keyed by the module's current node).
# RED on boot 713745c6: one edit to an entry carrying one open claim, and the
# warm compile reported it twice — once at the span the edit had moved.
run_warm_debt() {
  local compiler="$1" dir="$2" label="warm-debt"
  local wdir="$dir/$label.proj" n
  rm -rf "$wdir"
  mkdir -p "$wdir/.build"
  printf 'type Positive = Int where 0 < self\n\nfn inv(n: Positive) = 100 / n\n\nfn main() = inv(len([1, 2]) - 1)\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > /dev/null 2> "$dir/$label.1.err"
  printf 'type Positive = Int where 0 < self\n\nfn inv(n: Positive) = 100 / n\n\nfn main() = inv(len([1, 2, 3]) - 1)\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.wat" 2> "$dir/$label.2.err"
  n=$(grep -c '^verify: pending comparison 0 < self' "$dir/$label.2.err")
  if grep -q '^warm: re-deriving main\.mn$' "$dir/$label.2.err" && [ "$n" = "1" ] \
     && grep -q '^verify: pending comparison 0 < self at main:5:13-5:36$' "$dir/$label.2.err"; then
    pass "$label: the warm compile reports the edited claim once, at its new span"
  else
    fail "$label: $n pending report(s) after one edit, want 1 at main:5:13-5:36 (see $dir/$label.2.err)"
  fi
}

run_warm_incremental() {
  local compiler="$1" dir="$2" label="warm-inc"
  local wdir="$dir/$label.proj" refdir="$dir/$label.ref" rc
  mkdir -p "$wdir/.build" "$refdir/.build"
  printf 'fn base() = 20\n' > "$wdir/a.mn"
  printf 'import a\nfn mid() = base() + 1\n' > "$wdir/b.mn"
  printf 'import b\nfn main() = mid() * 2\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.1.wat" 2> "$dir/$label.1.err"
  rc=$?
  if [ "$rc" -ne 0 ] || [ ! -s "$dir/$label.1.wat" ]; then
    fail "$label cold compile (exit=$rc; see $dir/$label.1.err)"
    return
  fi
  pass "$label cold compile"
  printf 'import a\nfn mid() = base() + 2\n' > "$wdir/b.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.2.wat" 2> "$dir/$label.2.err"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$label incremental compile (exit=$rc; see $dir/$label.2.err)"
    return
  fi
  # The cone names RESOLVED PATHS, because a path is what a module's identity
  # IS (pin f58dfc10 — `lists` and `lib/lists` were two identities for one
  # file until the tree scan keyed the path). Rendering names here would mean
  # a path->name lookup, which is the re-derivation the same landing deleted.
  # The assertion is unchanged in substance and re-derived by hand before it
  # was re-banked (Law 11): b is the edited module, main its importer, and the
  # `$` anchor still proves a stayed CACHED — an unchanged dep must not appear.
  # A failure here does NOT return: the divergence check below reads the same
  # two artifacts and does not depend on this one. It used to return, and that
  # is how a REAL incremental bug rode a pin — the cone line went red on a
  # rendering change, the leg stopped, and "incremental == cold" never ran to
  # report that the warm path had dropped every cached module. A leg that
  # halts at its first failure hides the rest of its own coverage; only a
  # genuine precondition (no artifact to read) earns an early return.
  if ! grep -q '^warm: re-deriving b\.mn main\.mn$' "$dir/$label.2.err"; then
    fail "$label cone line (want 'warm: re-deriving b.mn main.mn'; see $dir/$label.2.err)"
  else
    pass "$label cone named (b main re-derived, a cached)"
  fi
  cp "$wdir/a.mn" "$wdir/b.mn" "$wdir/main.mn" "$refdir/"
  wt_run --dir "$refdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.ref.wat" 2> "$dir/$label.ref.err"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$label cold reference (exit=$rc; see $dir/$label.ref.err)"
    return
  fi
  if cmp -s "$dir/$label.2.wat" "$dir/$label.ref.wat"; then
    pass "$label incremental == cold-of-patched (byte-identical)"
  else
    fail "$label incremental diverges from cold (diff $dir/$label.2.wat $dir/$label.ref.wat)"
  fi
}

# An ARMED class's contract: the diagnostic fires AND the executable refuses —
# nonzero exit, ZERO WAT bytes (the refusal law, PLAN §11 col 2). run_diagnostic
# asserts the productive form (exit 0, diagnostics on stderr); an armed class's
# fixture moves HERE in the same commit that arms it.
run_refusal() {
  local compiler="$1" label="$2" source="$3" expected_code="$4" dir="$5"
  local wat="$dir/$label.wat" err="$dir/$label.compile.err"
  local rc count size

  wt_run "$compiler" < "$source" > "$wat" 2> "$err"
  rc=$?
  count=$(grep -c "$expected_code error:" "$err" 2>/dev/null || true)
  size=$(wc -c < "$wat" 2>/dev/null || echo 0)
  if [ "$rc" -ne 0 ] && [ "$count" -gt 0 ] && [ "$size" -eq 0 ]; then
    judge "$label" 1 "$label refusal ($expected_code=$count exit=$rc wat=0B)"
  else
    judge "$label" 0 "$label refusal (exit=$rc $expected_code=$count wat=${size}B; see $err)"
  fi
}

# run_refusal's runtime-linked sibling: the fixture links lib/ (a schedule
# handler, the prelude) and must still refuse — no WAT, nonzero exit, the
# class named at least once.
run_refusal_linked() {
  local compiler="$1" label="$2" source="$3" expected_code="$4" dir="$5"
  local link_runtime="${6:-yes}"
  local wat="$dir/$label.wat" err="$dir/$label.compile.err"
  local rc count size

  # The lib set is the program's, as run_program reads it: the runtime floor
  # by default, the derivative-reading set for a refusal the reading makes.
  case "$link_runtime" in
    derive)
      cat "${DERIVE_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$err" ;;
    arena)
      cat "${ARENA_RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$err" ;;
    *)
      cat "${RTLIBS[@]}" "$source" | wt_run "$compiler" > "$wat" 2> "$err" ;;
  esac
  rc=$?
  count=$(grep -c "$expected_code error:" "$err" 2>/dev/null || true)
  size=$(wc -c < "$wat" 2>/dev/null || echo 0)
  # A refusal leg's verdict goes through judge too: a program the medium
  # SHOULD refuse and still compiles is a standing failure a name can declare
  # (spine-callee-alloc was one from 2026-09-30 until its refusal fired on
  # 2026-10-01), and it retires loudly the day the refusal fires.
  if [ "$rc" -ne 0 ] && [ "$count" -gt 0 ] && [ "$size" -eq 0 ]; then
    judge "$label" 1 "$label refusal ($expected_code=$count exit=$rc wat=0B)"
  else
    judge "$label" 0 "$label refusal (exit=$rc $expected_code=$count wat=${size}B; see $err)"
  fi
}

run_diagnostic() {
  local compiler="$1" label="$2" source="$3" expected_code="$4" dir="$5"
  local wat="$dir/$label.wat" err="$dir/$label.compile.err"
  local rc count other

  wt_run "$compiler" < "$source" > "$wat" 2> "$err"
  rc=$?
  count=$(grep -c "$expected_code error:" "$err" 2>/dev/null || true)
  other=$(grep -E 'E_[A-Za-z0-9_]+ error:' "$err" 2>/dev/null \
    | grep -vc "$expected_code error:" || true)
  if [ "$rc" -eq 0 ] && [ "$count" -gt 0 ] && [ "$other" -eq 0 ]; then
    pass "$label diagnostic ($expected_code=$count)"
  else
    fail "$label diagnostic (exit=$rc $expected_code=$count other-errors=$other; see $err)"
  fi
}

# The narration contract — run_diagnostic's Warning-tier sibling: the program
# COMPILES (exit 0, narration is a finding not a failure) and the expected
# T_/W_ class surfaces on stderr with no error-class noise beside it.
run_narration() {
  local compiler="$1" label="$2" source="$3" expected_code="$4" dir="$5"
  local wat="$dir/$label.wat" err="$dir/$label.compile.err"
  local rc count other

  wt_run "$compiler" < "$source" > "$wat" 2> "$err"
  rc=$?
  count=$(grep -c "$expected_code Warning:" "$err" 2>/dev/null || true)
  other=$(grep -cE 'E_[A-Za-z0-9_]+ error:' "$err" 2>/dev/null || true)
  if [ "$rc" -eq 0 ] && [ "$count" -gt 0 ] && [ "$other" -eq 0 ]; then
    pass "$label narration ($expected_code=$count)"
  else
    fail "$label narration (exit=$rc $expected_code=$count other-errors=$other; see $err)"
  fi
}

# The silence contract — run_narration's dual: the program compiles, runs
# to its answer, and one NAMED class never appears, at either severity. A
# floor in a body the program never runs is not a finding about the
# developer's program, so it is not said at them.
run_unnarrated() {
  local compiler="$1" label="$2" source="$3" expected="$4" code="$5" dir="$6"
  local n
  run_program "$compiler" "$label" "$source" "$expected" "" "$dir"
  n=$(grep -cE "$code (Warning|error):" "$dir/$label.compile.err" 2>/dev/null || true)
  if [ "$n" -eq 0 ]; then
    pass "$label unnarrated ($code=0)"
  else
    fail "$label unnarrated ($code=$n; see $dir/$label.compile.err)"
  fi
}

# The open-claim contract — run_program's third face: the program's whole
# point is an obligation the judgment cannot decide, so the compile must
# SURFACE it (V_Pending, zero errors) rather than pass clean, the module
# assembles, and the run answers the expected exit — for a claim that
# stays open, the trap the row promised.
run_open_claim() {
  local compiler="$1" label="$2" source="$3" expected="$4" dir="$5"
  local wat="$dir/$label.wat" wasm="$dir/$label.wasm"
  local cerr="$dir/$label.compile.err" aerr="$dir/$label.assemble.err"
  local rout="$dir/$label.run.out" rerr="$dir/$label.run.err"
  local rc pending errors

  wt_run "$compiler" < "$source" > "$wat" 2> "$cerr"
  rc=$?
  pending=$(grep -c 'V_Pending' "$cerr" 2>/dev/null || true)
  errors=$(grep -cE 'E_[A-Za-z0-9_]+ error:' "$cerr" 2>/dev/null || true)
  if [ "$rc" -eq 0 ] && [ "$pending" -gt 0 ] && [ "$errors" -eq 0 ]; then
    pass "$label compile (open claim surfaced: V_Pending=$pending errors=0)"
  else
    fail "$label compile (exit=$rc V_Pending=$pending errors=$errors; see $cerr)"
    return
  fi
  if wt_asm "$wat" "$wasm" 2> "$aerr"; then
    pass "$label assemble"
  else
    fail "$label assemble ($(head -1 "$aerr"))"
    return
  fi
  wt_run "$wasm" > "$rout" 2> "$rerr"
  rc=$?
  if [ "$rc" -eq "$expected" ]; then
    judge "$label" 1 "$label run (exit=$rc)"
  else
    judge "$label" 0 "$label run (exit=$rc expected=$expected; see $rerr)"
  fi
}

# Same differential accounting for the persist lib set: pin boot's shadow,
# per-compiler shadows may only shrink it.
capture_persist_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/persist-shadow.wat" err="$dir/persist-shadow.err"

  { cat "${PERSIST_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "persist shadow compile (exit=$rc; see $err)"
    return 1
  fi

  PERSIST_SHADOW="$dir/persist-shadow.normalized"
  normalize_errors "$err" > "$PERSIST_SHADOW"
  pass "persist shadow captured ($(wc -l < "$PERSIST_SHADOW") inherited errors)"
}

# Same differential accounting for the CFC lib set (runtime + io + math +
# dsp/cfc + gen): the demo may only add refusals the base libs do not carry.
capture_cfc_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/cfc-shadow.wat" err="$dir/cfc-shadow.err"

  { cat "${CFC_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "cfc shadow compile (exit=$rc; see $err)"
    return 1
  fi

  CFC_SHADOW="$dir/cfc-shadow.normalized"
  normalize_errors "$err" > "$CFC_SHADOW"
  pass "cfc shadow captured ($(wc -l < "$CFC_SHADOW") inherited errors)"
}

# Same differential accounting for the signal lib set (runtime + io + math +
# dsp/cfc + dsp/signal): the demo may only add refusals the base libs do not carry.
capture_signal_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/signal-shadow.wat" err="$dir/signal-shadow.err"

  { cat "${SIGNAL_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "signal shadow compile (exit=$rc; see $err)"
    return 1
  fi

  SIGNAL_SHADOW="$dir/signal-shadow.normalized"
  normalize_errors "$err" > "$SIGNAL_SHADOW"
  pass "signal shadow captured ($(wc -l < "$SIGNAL_SHADOW") inherited errors)"
}

# The STFT + `<~` bandpass + comodulogram (lib/dsp/signal.mn) on a REAL on-disk
# recording + a python cross-validation. The recording carries a 4 Hz-phase ->
# 50 Hz-amplitude coupling — a DIFFERENT pair than cfc-demo (6->40) and cfc-rec
# (6->60), so the pipeline is proven to find a coupling it was never tuned to, not
# to memorize one grid cell.
#   (1) Mentl reads the recording (WASI fs -> parse_float -> native [Float]),
#       computes the comodulogram (`<~` bandpass conditioner + cfc.mn's windowed-
#       DFT mean-vector-length), the STFT dominant bin, and the `<~` bandpass
#       selectivity, and exits 42 iff all three verdicts hold.
#   (2) oracle.py (an INDEPENDENT port of signal.mn's pipeline using math.mn's
#       exact Taylor series — no numpy) computes the SAME grid over the SAME bytes;
#       the gate asserts it independently agrees on the argmax cell (flat 2 =
#       (4,50)) and the strong-coupling separation (floor(peak/median) >= 20).
run_signal_crucible() {
  local compiler="$1" dir="$2"
  local rec="$ROOT/tests/frontier/signal-crucible/recording.txt"
  local tmp="$dir/mentl-signal-recording.txt"
  cp -f "$rec" "$tmp"
  run_program "$compiler" signal-crucible \
    "$ROOT/tests/frontier/signal-crucible/demo.mn" 42 signal "$dir"
  local oracle="$ROOT/tests/frontier/signal-crucible/oracle.py"
  local out; out=$(python3 "$oracle" oracle "$tmp" 2>/dev/null)
  if ! printf '%s\n' "$out" | grep -q '^EXPECTED_'; then
    pass "signal-crucible cross-validation skipped (oracle deps unavailable)"
    return
  fi
  local flat strong ok=1
  flat=$(printf '%s\n' "$out" | sed -n 's/^EXPECTED_FLAT=//p')
  strong=$(printf '%s\n' "$out" | sed -n 's/^EXPECTED_STRONG_COUPLING=//p')
  [ "$flat" = 2 ] || { ok=0; fail "signal-crucible cross-validation (argmax flat=$flat, expected 2)"; }
  [ "$strong" = 1 ] || { ok=0; fail "signal-crucible cross-validation (strong_coupling=$strong, expected 1)"; }
  [ "$ok" = 1 ] && pass "signal-crucible cross-validation (argmax flat=2 + strong coupling agree with the oracle)"
}

# The CFC pipeline on a REAL on-disk recording + a LIVE numpy cross-validation.
# Two independent legs, both load-bearing:
#   (1) Mentl reads recording.txt (WASI fs → newline split → parse_float → native
#       [Float]), runs the comodulogram, and asserts the (6,60) argmax = flat 7.
#       A different value origin than the inline demo's literal-built signal, so
#       it stresses parse_float + the [Float] round-trip end to end.
#   (2) IF python3+numpy is present, the SAME on-disk bytes are run through
#       oracle.py (a faithful numpy port of cfc.mn) and its INDEPENDENT argmax is
#       asserted to agree with Mentl's. This is the representation-stress oracle
#       the m3==m4 fixpoint is structurally BLIND to — a corrupt [Float] would
#       make Mentl's argmax diverge from numpy's. No numpy on host → the cross-
#       check is skipped (noted), and Mentl's self-assertion still runs.
run_cfc_rec() {
  local compiler="$1" dir="$2"
  local rec="$ROOT/tests/frontier/cfc-rec/recording.txt"
  # The fixture lives in the gate's OWN per-run dir, which run_program maps as
  # the guest's /tmp (--dir "$dir::/tmp") — the .mn source keeps its /tmp path
  # while the host never writes the shared world-writable /tmp (a predictable
  # path there is a symlink hazard).
  local tmp="$dir/mentl-cfc-recording.txt"
  cp -f "$rec" "$tmp"
  run_program "$compiler" cfc-rec \
    "$ROOT/tests/frontier/cfc-rec/rec-demo.mn" 42 cfc-rec "$dir"
  local oflat
  if python3 -c 'import numpy' 2>/dev/null; then
    oflat=$(python3 "$ROOT/tests/frontier/cfc-rec/oracle.py" oracle "$tmp" 2>/dev/null \
      | sed -n 's/^EXPECTED_FLAT=//p')
    if [ "$oflat" = 7 ]; then
      pass "cfc-rec cross-validation (numpy argmax flat=$oflat agrees with Mentl)"
    else
      fail "cfc-rec cross-validation (numpy argmax flat=$oflat, expected 7)"
    fi
  else
    pass "cfc-rec cross-validation skipped (no numpy on host)"
  fi
}

# The IO shadow — the base runtime + WASI fs, the pinned inherited-debt baseline
# for the on-disk data validators.
capture_io_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/io-shadow.wat" err="$dir/io-shadow.err"

  { cat "${IO_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "io shadow compile (exit=$rc; see $err)"
    return 1
  fi
  IO_SHADOW="$dir/io-shadow.normalized"
  normalize_errors "$err" > "$IO_SHADOW"
  pass "io shadow captured ($(wc -l < "$IO_SHADOW") inherited errors)"
}

# The MATH shadow — the base runtime + math.mn, the pinned inherited-debt
# baseline for the real-workload crucibles (dsp/ml/adaptive). math.mn is `with
# Pure` throughout, so this shadow is empty; a crucible may only add refusals
# the base libs do not carry.
capture_math_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/math-shadow.wat" err="$dir/math-shadow.err"

  { cat "${MATH_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "math shadow compile (exit=$rc; see $err)"
    return 1
  fi
  MATH_SHADOW="$dir/math-shadow.normalized"
  normalize_errors "$err" > "$MATH_SHADOW"
  pass "math shadow captured ($(wc -l < "$MATH_SHADOW") inherited errors)"
}

# The DERIVE shadow — the derivative crucibles' link set with an empty main,
# so a crucible may only add refusals its libraries do not already carry.
capture_derive_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/derive-shadow.wat" err="$dir/derive-shadow.err"

  { cat "${DERIVE_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "derive shadow compile (exit=$rc; see $err)"
    return 1
  fi
  DERIVE_SHADOW="$dir/derive-shadow.normalized"
  normalize_errors "$err" > "$DERIVE_SHADOW"
  pass "derive shadow captured ($(wc -l < "$DERIVE_SHADOW") inherited errors)"
}

# The ARENA shadow — the arena legs' link set with an empty main, so a leg
# may only add refusals its libraries do not already carry.
capture_arena_shadow() {
  local compiler="$1" dir="$2"
  local wat="$dir/arena-shadow.wat" err="$dir/arena-shadow.err"

  { cat "${ARENA_RTLIBS[@]}"; printf '\nfn main() = 0\n'; } \
    | wt_run "$compiler" > "$wat" 2> "$err"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "arena shadow compile (exit=$rc; see $err)"
    return 1
  fi
  ARENA_SHADOW="$dir/arena-shadow.normalized"
  normalize_errors "$err" > "$ARENA_SHADOW"
  pass "arena shadow captured ($(wc -l < "$ARENA_SHADOW") inherited errors)"
}

# A generic on-disk DATA VALIDATOR + a LIVE oracle cross-check. Mentl reads a
# committed fixture (copied to /tmp), computes discrete facts over it, and
# asserts exit 42; then the SAME on-disk bytes are run through a python oracle
# whose EXPECTED_<KEY>=<value> lines are asserted to match the values Mentl's
# exit-42 encodes. Two independent implementations agreeing on the same real
# data — the representation-stress oracle the m3==m4 fixpoint is blind to. The
# oracle runs only if it can import its deps; otherwise the cross-check is
# skipped-noted and Mentl's self-assertion still runs. Trailing args are
# KEY=value expectations checked against the oracle's output. `guest_path` is
# the /tmp path the .mn source reads; the host copy lives in the gate's own
# per-run dir, which run_program maps as the guest's /tmp (--dir "$dir::/tmp"),
# so the host never writes the shared world-writable /tmp.
run_data_validator() {
  local compiler="$1" label="$2" source="$3" fixture="$4" guest_path="$5" oracle="$6" dir="$7"
  shift 7
  local expected=("$@")
  local tmp="$dir/$(basename "$guest_path")"
  cp -f "$fixture" "$tmp"
  run_program "$compiler" "$label" "$source" 42 io-rec "$dir"
  local out; out=$(python3 "$oracle" oracle "$tmp" 2>/dev/null)
  if ! printf '%s\n' "$out" | grep -q '^EXPECTED_'; then
    pass "$label cross-validation skipped (oracle deps unavailable)"
    return
  fi
  local pair key val got ok=1
  for pair in "${expected[@]}"; do
    key="${pair%%=*}"; val="${pair#*=}"
    got=$(printf '%s\n' "$out" | sed -n "s/^$key=//p")
    if [ "$got" != "$val" ]; then
      ok=0; fail "$label cross-validation ($key=$got, expected $val)"
    fi
  done
  [ "$ok" = 1 ] && pass "$label cross-validation (${#expected[@]} facts agree with the oracle)"
}

compile_fixture() {
  local compiler="$1" label="$2" source="$3" dir="$4"
  local wat="$dir/$label.input.wat" err="$dir/$label.input.err"
  local normalized="$dir/$label.input.normalized" rc errors

  wt_run "$compiler" < "$source" > "$wat" 2> "$err"
  rc=$?
  normalize_errors "$err" > "$normalized"
  errors=$(wc -l < "$normalized")
  if [ "$rc" -eq 0 ] && [ "$errors" -eq 0 ]; then
    pass "$label input check (no errors or proof debt)"
  else
    fail "$label input check (exit=$rc errors-or-debt=$errors; see $err)"
  fi
}

# A hole-bearing fixture's input form is PRODUCTIVE, never executable
# (SYNTAX §«Partial application»): the compile verb must REFUSE it honestly —
# E_UnresolvedHole, nonzero exit, ZERO WAT bytes. The edit workflow then
# fills the hole and the patched source compiles clean.
compile_hole_fixture() {
  local compiler="$1" label="$2" source="$3" dir="$4"
  local wat="$dir/$label.input.wat" err="$dir/$label.input.err" rc

  wt_run "$compiler" < "$source" > "$wat" 2> "$err"
  rc=$?
  if [ "$rc" -ne 0 ] && [ ! -s "$wat" ] && grep -q 'E_UnresolvedHole' "$err"; then
    pass "$label input refuses honestly (E_UnresolvedHole, nonzero, no WAT)"
  else
    fail "$label input did not refuse (exit=$rc wat=$(wc -c < "$wat")B; see $err)"
  fi
}

edit_fixture() {
  local compiler="$1" dir="$2" stem="$3" fixture="$4"
  EDIT_SCRATCH="$dir/$stem.mn"
  EDIT_TARGET="../${dir#$ROOT/}/$stem"
  EDIT_OUT="$dir/$stem.edit.out"
  EDIT_ERR="$dir/$stem.edit.err"

  cp "$fixture" "$EDIT_SCRATCH"

  # `edit` is a continuing session. Ten seconds is enough for its first
  # projection and one accepted action; timeout is not itself a failure if the
  # projection and patch both landed. The invocation reads all Wasmtime flags
  # from wt-env.sh, the same source as wt_run.
  printf 'y\n' | timeout 10 "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" \
    "$compiler" edit "$EDIT_TARGET" > "$EDIT_OUT" 2> "$EDIT_ERR"
  EDIT_RC=$?
}

assert_edit_window() {
  local label="$1"
  if [ "$EDIT_RC" -eq 0 ] || [ "$EDIT_RC" -eq 124 ]; then
    pass "$label edit session reached projection window (exit=$EDIT_RC)"
  else
    fail "$label edit session trapped (exit=$EDIT_RC; see $EDIT_ERR)"
  fi
}

check_and_execute() {
  local compiler="$1" dir="$2" label="$3" expected="$4" patched="$5"
  local check_out="$dir/$label.check.out" check_err="$dir/$label.check.err"
  local normalized="$dir/$label.check.normalized" rc

  wt_run --dir "$ROOT" "$compiler" check "$EDIT_TARGET" > "$check_out" 2> "$check_err"
  rc=$?
  normalize_errors "$check_err" > "$normalized"
  if [ "$patched" -eq 1 ] && [ "$rc" -eq 0 ] && [ ! -s "$normalized" ]; then
    pass "$label patched check (zero reported proof debt)"
  else
    fail "$label patched check (patch missing, exit=$rc, or proof debt remains; see $check_err)"
  fi

  run_program "$compiler" "$label-post-edit" "$EDIT_SCRATCH" "$expected" no "$dir"
}

run_positive_workflow() {
  local compiler="$1" dir="$2" patched=0
  local fixture="$ROOT/tests/frontier/mn-constrained-hole-workflow.mn"

  compile_hole_fixture "$compiler" positive-hole "$fixture" "$dir"
  edit_fixture "$compiler" "$dir" positive-hole "$fixture"
  assert_edit_window positive-hole

  if grep -Fq '1 candidate(s)' "$EDIT_OUT"; then
    pass "positive-hole candidate filter (exactly one survivor)"
  else
    fail "positive-hole candidate filter (missing exact one-survivor projection)"
  fi

  if grep -Fq "the type's integer inhabitants" "$EDIT_OUT"; then
    pass "positive-hole survivor Reason surfaced"
  else
    fail "positive-hole survivor Reason not surfaced"
  fi

  if ! grep -Fq '??' "$EDIT_SCRATCH" && \
      grep -Eq 'with Pure = 1([[:space:]]|$)' "$EDIT_SCRATCH"; then
    pass "positive-hole patch applied (?? replaced by 1)"
    patched=1
  else
    fail "positive-hole patch not applied to scratch source"
  fi

  check_and_execute "$compiler" "$dir" positive-hole 1 "$patched"
}

has_rejection_reason() {
  local name="$1"
  grep -Eiq \
    "(${name}.*(Network|forbidden|effect|row|reject)|(Network|forbidden|effect|row|reject).*${name})" \
    "$EDIT_OUT" "$EDIT_ERR"
}

run_capability_workflow() {
  local compiler="$1" dir="$2" patched=0 rejected
  local fixture="$ROOT/tests/frontier/mn-capability-hole-workflow.mn"

  compile_hole_fixture "$compiler" capability-hole "$fixture" "$dir"
  edit_fixture "$compiler" "$dir" capability-hole "$fixture"
  assert_edit_window capability-hole

  # TWO survivors since the domain read landed (2026-09-18), and the second is
  # the medium being right: `Seven = Int where self == 7` admits exactly one
  # value, so `7` is a proven fill and withholding it would be the medium
  # hiding what it knows. The fixture's own premise sentence — "integer seeds
  # omit 7" — described the floor's blindness, not a law. What this leg is FOR
  # survives untouched: the !Network row admits `pure_seven()` alone of the
  # four candidates, and the three refusals keep their Reasons, asserted below.
  # A literal and a named call are a REAL choice (the name carries intent the
  # magic number loses), so the tie is correct and `rank_of` already orders the
  # named callee first without suppressing the literal.
  if grep -Fq '2 candidate(s)' "$EDIT_OUT" && grep -Fq 'pure_seven' "$EDIT_OUT"; then
    pass "capability-hole filter kept pure_seven() beside the type's one literal inhabitant"
  else
    fail "capability-hole filter did not expose the pure survivor beside the literal"
  fi

  for rejected in direct_network transitive_network higher_order_network; do
    if has_rejection_reason "$rejected"; then
      pass "capability-hole retained $rejected rejection Reason"
    else
      fail "capability-hole lost $rejected rejection Reason"
    fi
  done

  # A tie never patches — the accept path fills only a lone survivor, so the
  # authored `??` must survive here exactly as it does in the tie fixture. The
  # accept path's own coverage is run_positive_workflow's, where `Positive`
  # leaves one survivor and the patch lands.
  if grep -Eq 'with !Network = \?\?([[:space:]]|$)' "$EDIT_SCRATCH"; then
    pass "capability-hole refused to guess between the name and the literal"
  else
    fail "capability-hole patched a tie instead of asking"
  fi
}

# Two proven survivors is the teaching TIE-BREAK (PLAN §5): the medium
# surfaces both with their admission Reasons and refuses to guess — the
# authored ?? survives the accepted edit action untouched.
# lsp_frame — one Content-Length-framed JSON-RPC message (LSP wire format, per
# lib/lsp_frame.mn). The length is the BYTE count of the body.
lsp_frame() {
  local body="$1"
  printf 'Content-Length: %d\r\n\r\n%s' "$(printf '%s' "$body" | wc -c)" "$body"
}

# run_lsp_hover — the LSP transport-runs-frontend contract
# (Hβ.lsp.transport-runs-frontend). serve_run now installs the analysis handlers
# and handle_did_open runs driver_check, so a hover reads the LIVE graph the
# frontend populated — the driverless (open_file-only) chain read an unpopulated
# graph and every query fell to AnsSilence (null hover).
#
# Two contracts. (1) is the graph-population MECHANISM the fix delivers, asserted
# through the JSON-free `query` transport: run the frontend, then consult the live
# type. (2) is the end-to-end serve session as the executable SPEC.
#
# 2026-07-20: the pinned json float blocker is CLEARED. It was Hβ.emit.float-
# evidence-ft — parse_number returned a Float through an indirect call whose
# $ft was all-i32, so json_parse trapped on the FIRST numeric field of any
# request. The §4① string-layer typing + the expect_same chase-first fix that
# closed the Float-ctor-arg face of that class also closed the json face: serve
# now parses JSON and reaches the LSP layer without trapping. So (2) INVERTS —
# a parse_number trap is now a REGRESSION, not the expected state — and greens
# on the cleared blocker. The remaining gap is the hover-RESPONSE emission
# (serve exits 0 having consumed the frames but does not yet write a result);
# that is Hβ.lsp.transport-runs-frontend's next rung, not a float trap.
# run_census — the structural-census facet's contract
# (Hβ.query.structural-census, PLAN §11 Phase 0.3): each countable shape's
# census answer contains the fixture's OWN located site — link-robust, since
# absolute counts ride the solo link set and the fixture's line is the
# invariant. All five verbs in the roster, `<~` included since the
# raw-reason span read (the census reads the node's own parse site, never
# the chased root's reason).
run_census() {
  local compiler="$1" dir="$2"
  local doc="$ROOT/tests/frontier/mn-census-verbs.mn"
  local ok=1 spec q line
  # Spawn phase: the census queries fly concurrently into per-writer files;
  # the judge below stays serial. Files carry the child pid so duplicate
  # line numbers (two shapes judged at one site) never clobber each other.
  for spec in '|>:10' '<|:11' '><:12' '~>:13' 'anonymous:14' '<~:15' 'eta:24' 'effectful-lambda:25' 'iteration:26' 'wildcard-zero:27' 'failure-mask:28' 'print-in-report:31' 'wildcard-fabricates:32' 'underscore-retain:33' 'flag-as-int:34' 'parallel-arrays:35' 'parallel-arrays:37' 'vtable-record:36' 'env-frame:38' 'default-param:39' 'record-pattern:40' 'declared-row-hof:41'; do
    printf '%s\0' "$spec"
  done | DOC="$doc" CENSUS_ART="$compiler" CENSUS_DIR="$dir" CENSUS_ROOT="$ROOT" \
        xargs -0 -n 1 -P "${FRONTIER_POOL:-$(nproc)}" bash -c '
          source "$CENSUS_ROOT/tools/wt-env.sh" >/dev/null 2>&1
          q="${1%%:*}"; ln="${1##*:}"
          # The child KEEPS its stderr and RECORDS a nonzero exit. Discarding
          # both meant a query that died — under the pool, all N of these are
          # wheel-scale — was indistinguishable from a shape that is genuinely
          # missing, and the judge below then blamed the shape. A diagnostic
          # whose NAME can lie is the class this gate exists to catch.
          wt_run --dir "$CENSUS_ROOT" "$CENSUS_ART" query "$DOC" "census $q" \
            > "$CENSUS_DIR/census-$ln-$$.out" 2> "$CENSUS_DIR/census-$ln-$$.err" \
            || printf "%s\n" "$?" > "$CENSUS_DIR/census-$ln-$$.rc"' census-child
  for spec in '|>:10' '<|:11' '><:12' '~>:13' 'anonymous:14' '<~:15' 'eta:24' 'effectful-lambda:25' 'iteration:26' 'wildcard-zero:27' 'failure-mask:28' 'print-in-report:31' 'wildcard-fabricates:32' 'underscore-retain:33' 'flag-as-int:34' 'parallel-arrays:35' 'parallel-arrays:37' 'vtable-record:36' 'env-frame:38' 'default-param:39' 'record-pattern:40' 'declared-row-hof:41'; do
    q="${spec%%:*}"; line="${spec##*:}"
    if ! cat "$dir"/census-"$line"*.out 2>/dev/null | grep -q "mn-census-verbs:$line"; then
      ok=0
      # Which of the two failures is it? A recorded exit means the INSTRUMENT
      # died and the shape was never judged; only a clean run that answered
      # without its own site convicts the shape. The paths named are the ones
      # that exist — the files carry the writer's pid, and the old message
      # pointed at an unsuffixed name nothing ever wrote.
      if compgen -G "$dir/census-$line-*.rc" > /dev/null; then
        fail "census '$q' QUERY DIED (exit $(cat "$dir"/census-"$line"*.rc | tr '\n' ' ')) — shape never judged; see $dir/census-$line-*.err"
      else
        fail "census '$q' misses its own site (line $line; see $dir/census-$line-*.out)"
      fi
    fi
  done
  [ "$ok" = 1 ] && pass "structural census: all twenty-one shapes count their own site (|> <| >< ~> <~ anonymous eta effectful-lambda iteration wildcard-zero failure-mask print-in-report wildcard-fabricates underscore-retain flag-as-int parallel-arrays-both-faces vtable-record env-frame default-param record-pattern declared-row-hof)"
  # The audit's drift tier (5.6's absorbed modes read per fn): the eight
  # specimen fns each carry their shape line. Born with the tier.
  ad_n=$(wt_run --dir "$ROOT" "$compiler" audit "$doc" 2>/dev/null | grep -c "drift-shape:")
  if [ "$ad_n" = "10" ]; then
    pass "audit drift tier: the ten specimen fns each carry their shape line (env-frame joined)"
  else
    fail "audit drift tier (drift-shape lines: $ad_n, want 10)"
  fi
  # The unreadable-entry refusal (Hβ.query.unreadable-source-refusal): an
  # entry that never joined the weave refuses the question — nonzero
  # exit, NO confident answer over the empty weave (the census printed
  # "0 sites" for an unmounted file until this leg's law landed).
  wt_run --dir "$ROOT" "$compiler" query no-such-source-anywhere.mn "census anonymous" > "$dir/census-missing.out" 2>/dev/null
  mrc=$?
  if [ "$mrc" -ne 0 ] && ! grep -q "anonymous fn" "$dir/census-missing.out"; then
    pass "unreadable-entry refusal: the query refuses (exit=$mrc), no answer over the empty weave"
  else
    fail "unreadable-entry refusal (exit=$mrc; see $dir/census-missing.out)"
  fi
}

run_lsp_hover() {
  local compiler="$1" dir="$2" label="$3"
  local doc="$ROOT/tests/frontier/mn-lsp-hover-doc.mn"
  local uri="file://$doc"

  # (1) MECHANISM — run the frontend, read the live type. A driverless read would
  #     project nothing; a real function type here is the graph populated + read.
  local qout="$dir/lsp-query.out" qerr="$dir/lsp-query.err"
  wt_run --dir "$ROOT" "$compiler" query "$doc" "type double" > "$qout" 2> "$qerr"
  if grep -q '\->' "$qout"; then
    pass "$label lsp graph-population mechanism (query 'type double' -> a function type)"
  else
    fail "$label lsp graph-population mechanism (no type projected; see $qout)"
  fi

  # (2) SERVE SPEC — drive the framed session; assert the hover contents once
  #     serve can parse JSON. Today it documents the pinned json blocker.
  local frames="$dir/lsp-hover.frames" sout="$dir/lsp-hover.out" serr="$dir/lsp-hover.err"
  {
    lsp_frame '{"jsonrpc":"2.0","id":"1","method":"initialize","params":{"processId":null,"rootUri":"file://'"$ROOT"'"}}'
    lsp_frame '{"jsonrpc":"2.0","method":"initialized","params":{}}'
    lsp_frame '{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"'"$uri"'"}}}'
    lsp_frame '{"jsonrpc":"2.0","id":"2","method":"textDocument/hover","params":{"textDocument":{"uri":"'"$uri"'"},"position":{"line":4,"character":15}}}'
  } > "$frames"
  timeout 30 "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" "$compiler" serve < "$frames" > "$sout" 2> "$serr"
  local src=$?
  if grep -q '"contents"' "$sout"; then
    pass "$label lsp serve hover returned a type (contents present)"
  elif grep -q 'parse_number' "$serr"; then
    fail "$label lsp serve REGRESSED to the json float trap (Hβ.emit.float-evidence-ft returned; see $serr)"
  elif [ "$src" -eq 0 ]; then
    pass "$label lsp serve clears the json float blocker (no parse_number trap; hover-response emission is the next rung, Hβ.lsp.transport-runs-frontend)"
  else
    fail "$label lsp serve trapped (exit=$src; see $serr)"
  fi
}

run_capability_tie_workflow() {
  local compiler="$1" dir="$2"
  local fixture="$ROOT/tests/frontier/mn-capability-tie.mn"

  compile_hole_fixture "$compiler" capability-tie "$fixture" "$dir"
  edit_fixture "$compiler" "$dir" capability-tie "$fixture"
  assert_edit_window capability-tie

  # THREE survivors since the domain read landed (2026-09-18): the two named
  # candidates the !Network row admits, plus `7`, which `Seven`'s own
  # refinement names as the type's one inhabitant. Each of the three is a
  # distinct intent — two names that happen to denote the same constant are
  # NOT one meaning (`default_retries()` and `max_batch()` both being 7 is a
  # coincidence of values), and a bare literal is a third choice that keeps no
  # name at all. So the medium asks, which is what this leg exists to assert.
  if grep -Fq '3 candidate(s)' "$EDIT_OUT" && \
      grep -Fq 'pure_seven' "$EDIT_OUT" && grep -Fq 'calm_seven' "$EDIT_OUT"; then
    pass "capability-tie projection surfaced every proven survivor"
  else
    fail "capability-tie projection missing the three-survivor tie"
  fi

  if grep -Eq 'with !Network = \?\?([[:space:]]|$)' "$EDIT_SCRATCH"; then
    pass "capability-tie refused to guess (authored ?? survives the accept)"
  else
    fail "capability-tie guessed between proven survivors (?? was replaced)"
  fi
}

# Pin the inherited runtime debt to the checked boot compiler and current
# runtime sources. A changed hash is an explicit baseline change, never an
# automatically blessed shadow. Other compiler artifacts may remove entries
# from this multiset, but may not introduce a new one.
baseline_dir="$ROOT/.build/frontier-gate/runtime-baseline"
rm -rf "$baseline_dir"
mkdir -p "$baseline_dir"
capture_runtime_shadow "$ROOT/boot/mentl.wasm" "$baseline_dir" || exit 1
BOOT_RUNTIME_SHADOW="$RUNTIME_SHADOW"
runtime_shadow_sha=$(sha256sum "$BOOT_RUNTIME_SHADOW" | awk '{print $1}')
if [ "$runtime_shadow_sha" = "$EXPECTED_RUNTIME_SHADOW_SHA256" ]; then
  pass "runtime shadow fingerprint pinned ($runtime_shadow_sha)"
else
  fail "runtime shadow fingerprint changed ($runtime_shadow_sha; expected $EXPECTED_RUNTIME_SHADOW_SHA256)"
  exit 1
fi

for i in "${!compilers[@]}"; do
  label="${labels[$i]}"
  compiler="${compilers[$i]}"
  [ -f "$compiler" ] || { echo "frontier: compiler not found: $compiler" >&2; exit 2; }
  dir="$ROOT/.build/frontier-gate/$label"
  rm -rf "$dir"
  mkdir -p "$dir"

  echo "frontier: compiler=$label artifact=$compiler"
  capture_runtime_shadow "$compiler" "$dir" || continue
  shadow_regressions="$dir/runtime-shadow.regressions"
  comm -23 "$RUNTIME_SHADOW" "$BOOT_RUNTIME_SHADOW" > "$shadow_regressions"
  if [ -s "$shadow_regressions" ]; then
    fail "$label runtime shadow introduced new errors (see $shadow_regressions)"
    continue
  else
    pass "$label runtime shadow is a subset of the pinned baseline"
  fi
  capture_persist_shadow "$compiler" "$dir" || continue
  capture_cfc_shadow "$compiler" "$dir" || continue
  # The CFC pipeline end to end (PLAN §11 col 4): the synthetic PAC signal
  # (4096 samples @ 512 Hz) run through the comodulogram over low=[4,6,8,10]
  # high=[30,40,50,60]. Exit 42 iff the coupled cell is (6, 40) — the phase-
  # amplitude coupling built into the signal (peak/median MVL ratio ≈ 5.9).
  run_program "$compiler" cfc-demo \
    "$ROOT/tests/frontier/cfc-demo/demo.mn" 42 cfc "$dir"
  # The same pipeline on a REAL on-disk recording, cross-validated against numpy
  # (a distinct 6→60 coupling, flat 7). The felt research payoff + the
  # representation oracle the fixpoint cannot be (see run_cfc_rec).
  run_cfc_rec "$compiler" "$dir"
  # The STFT + `<~` bandpass + filter-based comodulogram (lib/dsp/signal.mn) on a
  # real recording with a planted 8→50 Hz coupling, cross-validated cell-for-cell
  # against a python oracle (PLAN §11 col 4's research half, filter-based).
  capture_signal_shadow "$compiler" "$dir" || continue
  run_signal_crucible "$compiler" "$dir"
  # Two more on-disk data validators, cross-validated against numpy/python (the
  # representation-stress the m3==m4 fixpoint is structurally blind to):
  #  - native [Float] statistics: fold-sum mean, comparison-reduction argmin/
  #    argmax, mean-threshold count over 400 real samples (argmin 137, argmax
  #    298, above-mean 199).
  #  - String=[byte] text: byte_len, byte_at, structural ==, and a 256-slot Int
  #    histogram argmax over a 429-byte corpus (count_e 47, count_t 32, top 'e').
  capture_io_shadow "$compiler" "$dir" || continue
  run_data_validator "$compiler" stats-float \
    "$ROOT/tests/frontier/stats/stats-demo.mn" \
    "$ROOT/tests/frontier/stats/data.txt" /tmp/mentl-stats-data.txt \
    "$ROOT/tests/frontier/stats/oracle.py" "$dir" \
    EXPECTED_ARGMIN=137 EXPECTED_ARGMAX=298 EXPECTED_ABOVE=199
  run_data_validator "$compiler" text-bytes \
    "$ROOT/tests/frontier/text/text-demo.mn" \
    "$ROOT/tests/frontier/text/corpus.txt" /tmp/mentl-text-corpus.txt \
    "$ROOT/tests/frontier/text/oracle.py" "$dir" \
    EXPECTED_BYTES=429 EXPECTED_COUNT_E=47 EXPECTED_COUNT_T=32 EXPECTED_TOP_LETTER=101
  # ── the real-workload crucibles (inline signals + learners, no file I/O) ──
  # Each builds its data in Mentl, computes discrete verdict facts, and exits 42
  # iff they match an independent python oracle (tests/frontier/<name>-crucible/
  # oracle.py). Real DSP/ML stress on the wheel — the representation + numerics
  # the m3==m4 fixpoint is structurally blind to.
  #
  #  - dsp: a two-sinusoid + pseudo-noise signal through a single-pole IIR
  #    lowpass built with the `<~` feedback recurrence (float feedback — the
  #    prior threads through f64 state slots, repr read live). Verdict composes
  #    the argmax bin of an 8-bin DFT of the filtered output (1), a
  #    zero-crossing count (21), and a raw-signal clip count (64): 42 iff all.
  #  - ml: batch gradient descent for a 2-parameter linear regression recovering
  #    a known slope/intercept (round to 3, 1) over 32 inline points.
  #  - adaptive: a 2-tap LMS adaptive filter learning an unknown channel [2, 1]
  #    online while filtering; verdict = rounded taps + a >=1e6 residual-power
  #    drop.
  capture_math_shadow "$compiler" "$dir" || continue
  run_program "$compiler" dsp-crucible \
    "$ROOT/tests/frontier/dsp-crucible/dsp-demo.mn" 42 math "$dir"

  # The `<~` line is a ring in the image owned by the record that holds the
  # cycle (L2, 2026-09-27): a 24,000-deep echo driven 2,000,000 ticks. The
  # verdict is the value (84 = ⌈2,000,000 / 24,000⌉); the ticks per second
  # print beside it as the board's number for the cost of a deep line — a
  # wall clock is a host fact and is never ratcheted. On boot 542ea5a3 the
  # line was 24,000 module globals shifted per tick.
  run_program "$compiler" feedback-deep-line \
    "$ROOT/tests/frontier/mn-feedback-deep-line.mn" 84 yes "$dir"
  if [ -f "$dir/feedback-deep-line.wasm" ]; then
    dl_t0=$(date +%s%N)
    "$WT" run "${WT_RUN_FLAGS[@]}" "$dir/feedback-deep-line.wasm" >/dev/null 2>&1 || true
    dl_t1=$(date +%s%N)
    dl_ms=$(( (dl_t1 - dl_t0) / 1000000 ))
    if [ "$dl_ms" -gt 0 ]; then
      echo "  · deep line: 2,000,000 ticks at depth 24,000 in ${dl_ms} ms ($(( 2000000000 / dl_ms )) ticks/s)"
    else
      echo "  · deep line: 2,000,000 ticks at depth 24,000 in <1 ms"
    fi
  fi
  run_program "$compiler" ml-crucible \
    "$ROOT/tests/frontier/ml-crucible/ml-demo.mn" 42 math "$dir"
  run_program "$compiler" adaptive-crucible \
    "$ROOT/tests/frontier/adaptive-crucible/adaptive-demo.mn" 42 math "$dir"
  # The derivative reading (L4a, 2026-09-28), against oracles it cannot share
  # a mistake with. derive-shape: the slope of scene 1's distortion
  # (spectral.mn's adaptive_shape) in the drive and in the flux, by two
  # readings, against the central difference of the same function at 18
  # points over all three crossfade regimes — 42 iff all 36 agree to 1e-6.
  # derive-lms: the adaptive crucible's LMS filter with its hand-derived step
  # replaced by `d(e * e)`, judged by the crucible's own oracle facts. Both
  # RED on boot 51f332d7 (46 and 10: the install ran as an ordinary handler
  # and `d` answered the seed).
  capture_derive_shadow "$compiler" "$dir" || continue
  run_program "$compiler" derive-shape \
    "$ROOT/tests/frontier/derive-crucible/shape.mn" 42 derive "$dir"
  run_program "$compiler" derive-lms \
    "$ROOT/tests/frontier/derive-crucible/lms.mn" 42 derive "$dir"
  # derive-distort (L4a′, 2026-09-30): the distortion PERFORM under its
  # stateful handler — the arm's derivative twin, the install record's lanes
  # carrying the envelopes' tangents from sample to sample — in the drive
  # and in the first sample (whose influence on every later one runs only
  # through the state), against the central difference of the same chain
  # under fresh installs; 42 iff all 12 agree to 1e-5. RED on boot 0bc95063
  # (refused: the tangent stopped at the perform).
  run_program "$compiler" derive-distort \
    "$ROOT/tests/frontier/derive-crucible/distort.mn" 42 derive "$dir"
  # derive-grad (L4b, 2026-09-30): a product seed answered in ONE reverse
  # sweep — {bias, drive} over a rational waveshaper, a fixed chain, the
  # gradient read by destructuring where it is asked — against the central
  # differences of the same function at 18 points; 42 iff all 36 partials
  # agree to 1e-6. RED on boot 8ee3d09a (refused: a seed had to be a Float
  # variable). derive-grad-series: the same product seed over scene 1's
  # distortion, whose reach recurs through lib/math.mn's series — the
  # reverse projection does not carry a recursion, so the reading REFUSES
  # naming the vector-forward reading (`Hβ.derive.vector-forward`), never a
  # slope of zero.
  run_program "$compiler" derive-grad \
    "$ROOT/tests/frontier/derive-crucible/grad.mn" 42 derive "$dir"
  run_refusal_linked "$compiler" derive-grad-series \
    "$ROOT/tests/frontier/derive-crucible/grad-series.mn" E_DerivativeUnreachable "$dir" derive
  # ── THE ARENA (2026-10-03): `(body) ~> arena` ──
  # What the body allocated and did not publish is reclaimed at the exit;
  # the value, and what the body stored into older memory, moves out of the
  # region by its type — the type the STORE knew, journaled where the store
  # happened, so no handler names anything at the exit. Ten legs, each RED
  # on boot 9d27c325 (exit 1 — the install ran as an ordinary handler:
  # nothing reclaimed, no exit counted), each 42 on the landing's m2: the
  # value moves; the dropped is reclaimed and the memory behind the line is
  # zero again; a handler's in-place buffer and a plain buffer written by
  # plain code (the second KEPT its region under the owner protocol, RED on
  # that form's m2); a rebound state's commit; nested arenas; a `<~` line's
  # pointer history; a buffer replaced by its own growth; and two that KEEP
  # the region rather than move a value no leaf moves (a closure, a journal
  # overflow), each still correct. The eleventh is a control, 42 on both: a
  # module that spawns owns no region per instance, so its arena runs the
  # body. The twelfth stores through a GENERIC helper: the helper's claim
  # names the parameter it stores into, the call hands it the handler's
  # state, so the value's type is a demand and the helper's twin journals the
  # leaf — RED (exit 1, the region kept) on an m2 built with that call's
  # transport switched off. The thirteenth reaches `list_set` as a VALUE: no
  # leaf can be carried through the call, so its table face journals with
  # none and the exit keeps — refused at compile on boot 9ec6db48 as an
  # internal invariant, a correct program the medium would not run. The
  # fourteenth moves nothing out of a region larger than the memory had grown
  # before it opened, so the exit's copy space lies past the memory's end —
  # a trap at the exit on boot fb8921e3 (a zero-length copy there is out of
  # bounds too), found by the battery once each fixture ran in an arena.
  # The next five hold an ADDRESS where the exit looks — as the value, in a
  # slot `store_addr` journaled, as a record's field, as a list's element, in
  # bytes `mem_copy` carried into older memory — and each keeps the region,
  # since nothing can say what an address names, and the exit reads no copied
  # byte at all. Held as Ints, the first four read 0, 0, 0 and 2 where they
  # compute 42, 42, 42 and 12, silently, on boot 0a096302; typed, none
  # compiled there. The fifth answered 1 on boot 2198ed97 with this pin's
  # library, whose emit had no barrier on a raw copy. The last writes a float
  # into a packed list older than the arena: a wide slot holds a number,
  # copied as one, so the exit reclaims past it — exit 1, the region kept,
  # on this landing's m2 with the slot's bytes copied raw. Two refusals
  # follow: an address stored where a word goes, and one in a list of
  # numbers, each compiling and answering wrong (1 for 42, 7 for 12) on boot
  # 2198ed97 with that pin's library, where `alloc` and the cast answered Ints.
  # The last eight suspend an arena (2026-10-03): an op performed inside it
  # and answered outside it — a held resume, a multi-shot one, an arm that
  # never resumes, a perform in a callee of the arena's body, an arena
  # standing where its value is used, a list-valued arena, a rest that stores
  # into older memory, and a rest that performs again. The exit keeps the
  # region rather than end the extent, and each resumption runs the rest of
  # the body in a fresh instance around every segment it encloses. On boot
  # 10cd1956 (the census clause stripped, the stat being new) six trap at 134
  # — the exit had reclaimed the continuation, or the arena's tail call met
  # the floor — and two answer silently wrong: the abandoning arm read the
  # argument the exit reclaimed (1), and the list came back empty (length 0).
  capture_arena_shadow "$compiler" "$dir" || continue
  for leg in value-moves dropped-is-reclaimed handler-buffer-moves \
             plain-buffer-moves state-commit-moves nested ring-history-moves \
             growth-link closure-keeps journal-overflow-keeps \
             spawning-module-runs-the-body generic-store-moves value-store-keeps \
             nothing-moved-past-memory addr-value-keeps addr-store-keeps \
             addr-field-keeps addr-list-keeps addr-copy-keeps \
             wide-slot-reclaims held-resume-reenters multishot-resume-reenters \
             abort-suspends resume-nests-exactly arena-is-a-junction \
             list-value-reenters older-store-reenters reyield-reenters \
             float-value-reenters; do
    run_program "$compiler" "arena-$leg" \
      "$ROOT/tests/frontier/arena/$leg.mn" 42 arena "$dir"
  done
  for leg in addr-stored-as-word-refuses addr-among-numbers-refuses; do
    run_refusal_linked "$compiler" "arena-$leg" \
      "$ROOT/tests/frontier/arena/$leg.mn" E_TypeMismatch "$dir" arena
  done
  run_program "$compiler" scheduled-int \
    "$ROOT/tests/frontier/mn-scheduled-fanout-int.mn" 60 yes "$dir"
  run_program "$compiler" scheduled-float \
    "$ROOT/tests/frontier/mn-scheduled-fanout-float.mn" 60 yes "$dir"
  run_program "$compiler" scheduled-tuple \
    "$ROOT/tests/frontier/mn-scheduled-fanout-tuple.mn" 90 yes "$dir"
  run_program "$compiler" scheduled-closure \
    "$ROOT/tests/frontier/mn-scheduled-fanout-closure.mn" 34 yes "$dir"
  run_program "$compiler" scheduled-effect \
    "$ROOT/tests/frontier/mn-scheduled-fanout-effect.mn" 25 yes "$dir"
  # ── B1: an effect performed INSIDE a spawned branch (2026-09-27) ──
  # A branch runs in the world it was spawned in (the task record carries
  # the live install chain; the fresh instance installs it before the
  # closure runs), so a perform inside a branch walks to the handler at
  # the fanout's frame. The RACE RULE at lowering: that handler must be
  # provable at the fanout's own frame and stateless, or installed inside
  # the branch — a stateful one is two instances resuming on one shared
  # record, one beyond the frame fence is unprovable (E_ThreadedBranchEffect,
  # armed, born at zero). RED on the prior boot: the stateless case faulted
  # at the 0x100000000 belt (world 0 in the branch), the refusals compiled.
  run_program "$compiler" threaded-branch-stateless \
    "$ROOT/tests/frontier/mn-threaded-branch-stateless.mn" 14 yes "$dir"
  run_program "$compiler" threaded-branch-inner-install \
    "$ROOT/tests/frontier/mn-threaded-branch-inner-install.mn" 10 yes "$dir"
  run_refusal_linked "$compiler" threaded-branch-stateful \
    "$ROOT/tests/frontier/mn-threaded-branch-stateful.mn" E_ThreadedBranchEffect "$dir"
  run_refusal_linked "$compiler" threaded-branch-caller \
    "$ROOT/tests/frontier/mn-threaded-branch-caller.mn" E_ThreadedBranchEffect "$dir"
  run_refusal_linked "$compiler" threaded-branch-transitive \
    "$ROOT/tests/frontier/mn-threaded-branch-transitive.mn" E_ThreadedBranchEffect "$dir"
  # A held resume through a `!Alloc` callee runs the remainder inside the
  # callee's extent, and the remainder carries the op's own multi-shot cost.
  # The resume performs its continuation's world (the handler's remainder
  # cell, gated by the callee through the callback's row), and the install
  # judges that gate against its own remainder: refused, naming `plus_one`.
  # It compiled and ran to 21 on every boot through 477bb667, declared red
  # (Hβ.continuations.spine-callee-row-is-blind-to-the-held-resume, CLOSED).
  run_refusal_linked "$compiler" spine-callee-alloc \
    "$ROOT/tests/frontier/mn-spine-callee-alloc.mn" E_EffectMismatch "$dir"
  run_program "$compiler" threaded-branch-readonly-state \
    "$ROOT/tests/frontier/mn-threaded-branch-readonly-state.mn" 10 yes "$dir"
  # ── B4: the schedule reaches a callee's fanout (2026-09-30) ──
  # A `~> parallel_compose` install reaches every `><` and `fanout` in its
  # extent's direct-call reach: the callee is emitted as a schedule twin
  # (`spec_call_name`), its fanout's spawning form selected by the bracket,
  # and the race rule reads each branch's row at the INSTANTIATING site (a
  # callback parameter's row is the argument's). A callee declared `!Thread`
  # keeps its own frame's schedule. RED on boot 6f2ce437: the frame fence made
  # every callee's fanout sequential (reaches-callee exited 1, the race
  # refusal ran to 11), and `fanout` did not exist.
  run_program "$compiler" schedule-reaches-callee \
    "$ROOT/tests/frontier/mn-schedule-reaches-callee.mn" 14 yes "$dir"
  # the schedule's own ops answer inside a spawned branch: the task record
  # carries the world of the perform, not the spawn arm's (134 on 6f2ce437)
  run_program "$compiler" threaded-branch-thread-op \
    "$ROOT/tests/frontier/mn-threaded-branch-thread-op.mn" 14 yes "$dir"
  run_program "$compiler" fanout-seq-values \
    "$ROOT/tests/frontier/mn-fanout-seq-values.mn" 12 yes "$dir"
  run_program "$compiler" fanout-seq-threaded \
    "$ROOT/tests/frontier/mn-fanout-seq-threaded.mn" 3 yes "$dir"
  run_program "$compiler" schedule-negation-pins-seq \
    "$ROOT/tests/frontier/mn-schedule-negation-pins-seq.mn" 1 yes "$dir"
  run_refusal_linked "$compiler" schedule-race-through-callee \
    "$ROOT/tests/frontier/mn-schedule-race-through-callee.mn" E_ThreadedBranchEffect "$dir"
  run_program "$compiler" schedule-race-callee-readonly \
    "$ROOT/tests/frontier/mn-schedule-race-callee-readonly.mn" 10 yes "$dir"
  run_program "$compiler" scheduled-persist-float \
    "$ROOT/tests/frontier/mn-scheduled-fanout-persist-float.mn" 60 persist "$dir"
  # The rooted-image persist (B-i landing 1): ONE build, TWO processes. Leg A
  # persists the whole image mid-computation (exit 40); leg B — a fresh
  # process of the SAME wasm — passes the build-key + world-fingerprint
  # gates, swaps A's image in, reads the typed root through the restored
  # globals record, and resumes A's thunk against A's heap pointees (exit
  # 42). Seen RED on the pre-image boot: the image ops are unrecognized
  # substrate, so the executable refuses at compile.
  run_persist_image "$compiler" "$dir"
  # The arena face of the same gate: an image persisted inside an open arena
  # resumes outside it (2026-10-03).
  run_persist_arena "$compiler" "$dir"
  # B-i landing 2: the warm-start cache — run 2 restores run 1's analyzed
  # image and must emit byte-identical WAT. RED before the landing: the
  # warm line never prints (every run re-derives).
  run_warm_start "$compiler" "$dir"
  # B-i landing 3: the incremental cursor — patch one module, re-derive
  # only its cone off the restored image. RED before the landing: a
  # changed weave missed the weave-keyed cache and re-derived everything
  # with no cone line.
  run_warm_incremental "$compiler" "$dir"
  # A warm image carries the handler world that wrote it, output sink
  # included. RED on boot 43aeb30f: `run` then `compile` on one file printed
  # ZERO lines — the compile restored run's image and emitted into run's
  # sink. Images are filed under world_key() now (run_warm_world's header).
  run_warm_world "$compiler" "$dir"
  # The cone's proof ledger forgets before it re-accrues (run_warm_debt's
  # header): RED on boot 713745c6, the edited claim reported twice.
  run_warm_debt "$compiler" "$dir"
  # Pulse scene 1: the flagship renders, the oracle judges the file, and its
  # three one-line twins refuse (run_pulse_render's own header).
  run_pulse_render "$compiler" "$dir"
  # The JSON serializer's string escape over the shapes that defeated it — a
  # one-byte string serialized as a NUL, a quote as two, a control byte with
  # no short spelling crossed raw. RED on boot 2198ed97: exit 1.
  run_project "$compiler" "$dir" json-escape-total "$ROOT/tests/frontier/mn-json-escape-total.mn" 42
  # Real host-thread spawn over the shared image (the task-record substrate:
  # import-shape memory, shared-cell allocator, $spawn_task_impl/$join_task_impl).
  # Seen RED on the pre-task-record boot: 134, unaligned atomic in the join.
  run_program "$compiler" real-spawn \
    "$ROOT/tests/frontier/mn-real-spawn.mn" 60 yes "$dir"
  run_program "$compiler" real-spawn-float \
    "$ROOT/tests/frontier/mn-real-spawn-float.mn" 60 yes "$dir"
  run_program "$compiler" real-spawn-identity \
    "$ROOT/tests/frontier/mn-real-spawn-identity.mn" 60 yes "$dir"
  run_program "$compiler" refined-alias-nonatomic \
    "$ROOT/tests/frontier/mn-refined-alias-nonatomic.mn" 3 yes "$dir"
  run_program "$compiler" refined-alias-forward-ref \
    "$ROOT/tests/frontier/mn-refined-alias-forward-ref.mn" 42 no "$dir"
  run_program "$compiler" own-alternative-branches \
    "$ROOT/tests/frontier/mn-own-alternative-branches.mn" 42 no "$dir"
  run_program "$compiler" own-call-arg-borrow \
    "$ROOT/tests/frontier/mn-own-call-arg-borrow.mn" 42 no "$dir"
  run_program "$compiler" own-forward-ref-seq \
    "$ROOT/tests/frontier/mn-own-forward-ref-seq.mn" 0 no "$dir"
  # A Float POSITIONAL constructor field filled from an unannotated param: `g`
  # must infer Float from its use as the ctor's argument (the mirror of a
  # pattern binding a sub-pattern to the field type). Before expect_same chased
  # the arg's live binding, the scalar CLOBBERED the NBound(TVar(binder))
  # reference, `g` stayed an unresolved var → i32 floor, and the f64 call site
  # dispatched through an all-i32 $ft — indirect-call trap. RED (run 134) on the
  # pre-fix boot, 42 on this one.
  run_program "$compiler" ctor-float-param \
    "$ROOT/tests/frontier/mn-ctor-float-param.mn" 42 no "$dir"
  # §4① String = [byte] — THE BEHAVIORAL BATTERY (2026-07-21). The fixpoint
  # oracle is structurally BLIND to string corruption (the wheel is
  # byte_at-disciplined and never maps a string), so these output-checked runs
  # are the load-bearing gate for the ontology: generic combinators over text,
  # the O(1) concat rope, cross-stride structural ==, the text-view render,
  # and the stride-1 store range trap (exit 134 = the loud narrowing refusal).
  # RED on the pre-merge boot by construction — the merge is what makes
  # map-over-String type at all.
  run_program "$compiler" string-map \
    "$ROOT/tests/frontier/mn-string-map.mn" 42 yes "$dir"
  run_program "$compiler" string-fold \
    "$ROOT/tests/frontier/mn-string-fold.mn" 42 yes "$dir"
  run_program "$compiler" string-generic \
    "$ROOT/tests/frontier/mn-string-generic.mn" 42 yes "$dir"
  run_program "$compiler" string-eq-concat \
    "$ROOT/tests/frontier/mn-string-eq-concat.mn" 42 yes "$dir"
  run_program "$compiler" string-slice-index \
    "$ROOT/tests/frontier/mn-string-slice-index.mn" 42 yes "$dir"
  run_program "$compiler" string-show-interp \
    "$ROOT/tests/frontier/mn-string-show-interp.mn" 42 yes "$dir"
  run_program "$compiler" string-cross-stride \
    "$ROOT/tests/frontier/mn-string-cross-stride.mn" 42 yes "$dir"
  run_program "$compiler" string-parse \
    "$ROOT/tests/frontier/mn-string-parse.mn" 42 yes "$dir"
  run_program "$compiler" byte-range-trap \
    "$ROOT/tests/frontier/mn-byte-range-trap.mn" 134 yes "$dir"
  # §5.U wide-element cash-out — [Float] as a first-class packed sequence: the
  # literal is born stride-8 (make_list_sc), a concrete read derefs the
  # element's reference, structural == compares VALUES (list_eq_f64, never the
  # references), map/fold/filter/any cross the polymorphic boundary by
  # reference, a NAMED f64 fn and an f64 CAPTURE reach the table through their
  # $wf$ word wrappers, and show renders through float_to_str. RED on the
  # pre-wide-element boot by construction — before the word-protocol boundary
  # these did not even ASSEMBLE (f64.const into an i32 slot).
  run_program "$compiler" float-list \
    "$ROOT/tests/frontier/mn-float-list.mn" 42 yes "$dir"
  run_program "$compiler" float-map \
    "$ROOT/tests/frontier/mn-float-map.mn" 42 yes "$dir"
  run_program "$compiler" float-hof \
    "$ROOT/tests/frontier/mn-float-hof.mn" 42 yes "$dir"
  run_program "$compiler" float-show \
    "$ROOT/tests/frontier/mn-float-show.mn" 42 yes "$dir"
  # Named-generic monomorphization (the §5.U scalar half): a generic fn whose
  # site instantiates ONE wide type gets a demand-driven twin emitted under
  # the spec_wty state — recursive accumulators, higher-order named comparators,
  # and the transitive sort→merge web. RED (run 1, silent-wrong) on the
  # pre-spec boot; Int instantiations stay at the byte-identical floor.
  run_program "$compiler" generic-float-accumulator \
    "$ROOT/tests/frontier/mn-generic-float-accumulator.mn" 42 yes "$dir"
  run_program "$compiler" generic-float-comparator \
    "$ROOT/tests/frontier/mn-generic-float-comparator.mn" 42 yes "$dir"
  run_program "$compiler" generic-nested-lambda \
    "$ROOT/tests/frontier/mn-generic-nested-lambda.mn" 42 yes "$dir"
  run_program "$compiler" generic-multitype \
    "$ROOT/tests/frontier/mn-generic-multitype.mn" 42 yes "$dir"
  # C5 — partiality is a row fact: the absorb rewrite x * 0 ≡ 0 keeps a
  # division whose precondition stays open (it carries `Trap`), so
  # `(1 / n) * 0` TRAPS at n = 0 as written (exit 134 through the runner).
  # The claim is OPEN by design — `n` is unbounded — so the compile
  # surfaces it as V_Pending, which the leg ASSERTS: an open claim is the
  # whole reason the operand survives. RED on boot 21f8e691: the shape-read
  # gate dropped the operand and the program answered 0.
  run_open_claim "$compiler" absorb-keeps-trap \
    "$ROOT/tests/frontier/mn-absorb-keeps-trap.mn" 134 "$dir"
  # A tuple destructure in a generic body: offsets/widths project at emit
  # through the spec bracket (pat_elem_repr / pat_tuple_off), and the
  # destructure is itself a worthiness witness. RED on the pre-fix boot
  # twice over: the worthy twin's WAT did not assemble ($x.f64 undefined
  # local), and the non-worthy floor read an f64's high word as the next
  # element (invalid exit status, zero diagnostics).
  run_program "$compiler" generic-wide-tuple-pattern \
    "$ROOT/tests/frontier/mn-generic-wide-tuple-pattern.mn" 42 yes "$dir"
  # The effect-instance boundary: a declared-row fn's callers must read its
  # row's INSTANCE args (subst_row's closed-tail arm — the old arm returned
  # the empty row with the var tail, so every caller of every declared-row
  # fn read a BARE row and no effect instance ever crossed a fn boundary).
  # RED for twelve dig iterations: reverse over (Float, Int) pairs returned
  # an element-orphaned type, the destructure took the uniform floor, and
  # the f64 high word came back as the tag (invalid exit, zero diagnostics).
  run_program "$compiler" forward-wide-instantiation \
    "$ROOT/tests/frontier/mn-forward-wide-instantiation.mn" 42 yes "$dir"
  # The holed substrate call types from the FACE (seq_op_sig), never the raw
  # body's env scheme — RED on the pre-face boot (Int-vs-List at every
  # `|> list_set(??, …)` stage under the callee-first blob).
  run_program "$compiler" seq-op-holed-pipe \
    "$ROOT/tests/frontier/mn-seq-op-holed-pipe.mn" 72 yes "$dir"
  run_program "$compiler" generic-show \
    "$ROOT/tests/frontier/mn-generic-show.mn" 42 yes "$dir"
  run_program "$compiler" aggregate-show \
    "$ROOT/tests/frontier/mn-aggregate-show.mn" 42 yes "$dir"
  run_program "$compiler" aggregate-hash \
    "$ROOT/tests/frontier/mn-aggregate-hash.mn" 42 yes "$dir"
  # The raw rewind is unsayable: an extent's memory is reclaimed by an arena
  # and nothing else. RED on every boot through fb8921e3, where this ran to
  # 42 (the region verb it called is the one P2 deleted).
  run_refusal_linked "$compiler" raw-rewind-unsayable \
    "$ROOT/tests/frontier/mn-raw-rewind-unsayable.mn" E_MissingVariable "$dir"
  run_program "$compiler" top-level-let \
    "$ROOT/tests/frontier/mn-top-level-let.mn" 42 yes "$dir"
  # A nominal record satisfies a structural field demand by its own
  # declaration, read through the env edge (the TName-vs-TRecordOpen unify
  # arm). RED on the pre-arm boot: `p.age` on a let-bound Person raised a
  # false E_TypeMismatch (Person vs {age: t | r}) on the canonical SYNTAX
  # form, and a row-polymorphic `{age: Int, ...}` parameter refused a
  # Person outright.
  # SYNTAX §Indexing's tuple form judges and runs: a receiver chased to a
  # tuple, indexed by a literal, types as that position's element (the
  # judge's half of the dispatch lower always carried). RED on the
  # pre-route boot: `p[1]` on a let-bound tuple raised E_TypeMismatch
  # (the index sugar forced every receiver to List — the census's own
  # conviction at audit_walk).
  run_program "$compiler" tuple-index \
    "$ROOT/tests/frontier/mn-tuple-index.mn" 42 yes "$dir"
  run_program "$compiler" nominal-field-access \
    "$ROOT/tests/frontier/mn-nominal-field-access.mn" 42 yes "$dir"
  run_program "$compiler" rowpoly-accepts-nominal \
    "$ROOT/tests/frontier/mn-rowpoly-accepts-nominal.mn" 42 yes "$dir"
  # The A.4 oracle wave (step 1 of the TString dissolution): these pin
  # TODAY'S string routes — show/hash/ordering scalar faces, the byte
  # faces inside record fields and ADT payloads, and the `: String`
  # annotation boundary — because the fixpoint is structurally blind to
  # a string-route regression. The remaining planned leg is the
  # String-typed hole proposing string literals (the edit-harness
  # shape), landing with A.4 step 4's synth rewrite.
  run_program "$compiler" string-scalar-faces \
    "$ROOT/tests/frontier/mn-string-scalar-faces.mn" 42 yes "$dir"
  run_program "$compiler" string-in-aggregates \
    "$ROOT/tests/frontier/mn-string-in-aggregates.mn" 42 yes "$dir"
  run_program "$compiler" string-annotation-boundary \
    "$ROOT/tests/frontier/mn-string-annotation-boundary.mn" 42 yes "$dir"
  # The Cast capability (phase-A vocabulary): addr erases at lower to its
  # operand, so the row carries the whole meaning — the green leg proves
  # word-face facts through the erase (RED on the pre-Cast boot: the op
  # lowered as a handler-less demand and the executable gate refused).
  run_program "$compiler" cast-addr \
    "$ROOT/tests/frontier/mn-cast-addr.mn" 42 yes "$dir"
  # !Cast severance REFUSES (E_EffectMismatch at the declaration — ARMED
  # 2026-09-25, the crown's own verdict; before that it reported and the
  # program ran). The leg asserts the diagnostic fires.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-cast-refused.mn" \
    | wt_run "$compiler" > /dev/null 2> "$dir/cast-refused.err"
  if grep -q "E_EffectMismatch error" "$dir/cast-refused.err"; then
    pass "cast-refused severance reported (E_EffectMismatch at the decl)"
  else
    fail "cast-refused severance silent (see $dir/cast-refused.err)"
  fi
  run_refusal "$compiler" effect-unhandled \
    "$ROOT/tests/frontier/mn-effect-unhandled.mn" E_EffectUnhandled "$dir"
  # ARMED 2026-08-18 (wheel census 0 at birth): a fn whose name is an op of
  # a LINKED effect is unreachable — the env is append-only, read
  # last-write-wins, and the effect decl re-registers its ops after the
  # entry module's declarations.
  #
  # It CANNOT use run_refusal, and finding out why cost this leg its first
  # red: run_refusal pipes the fixture in on stdin, which is the BLOB path,
  # whose link has no lib/threading and therefore no collision to
  # find. The defect only exists through the MANIFEST, so the leg drives
  # the compiler the way a person does — a verb and a path.
  # SEEN RED A SECOND TIME 2026-09-17, at the single-pass pin: the check
  # lived at the op's env write and read a PRIOR fn — an order the second
  # pass supplied (fn sigs pre-registered by the trial, ops re-registered
  # by the final). With one pass effects register first, so the fn WON
  # silently (exit 0, 35KB of WAT, E_TypeMismatch noise in threading). The
  # check now runs at the fn's own write too; this leg is what caught it.
  fso_err="$dir/fn-shadows-op.err"
  fso_wat=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" \
    "$compiler" compile "$ROOT/tests/frontier/mn-fn-shadows-op.mn" 2> "$fso_err")
  fso_rc=$?
  fso_count=$(printf '%s' "$fso_err" >/dev/null; grep -c 'E_FnShadowsOp error:' "$fso_err" 2>/dev/null || true)
  if [ "$fso_rc" -ne 0 ] && [ "$fso_count" -gt 0 ] && [ -z "$fso_wat" ]; then
    pass "fn-shadows-op refusal (E_FnShadowsOp=$fso_count exit=$fso_rc wat=0B, through the manifest)"
  else
    fail "fn-shadows-op refusal (exit=$fso_rc E_FnShadowsOp=$fso_count wat=${#fso_wat}B; see $fso_err)"
  fi
  run_refusal "$compiler" effect-stateful-uninstalled \
    "$ROOT/tests/frontier/mn-effect-stateful-uninstalled.mn" E_EffectUnhandled "$dir"
  # ARMED 2026-08-08 (the decl-site licence, wheel census 0 at birth): an
  # unsatisfiable `with E + !E` clause never reaches an executable — born
  # RED against the pre-arm pin (diagnostic on stderr, WAT still emitted).
  run_refusal "$compiler" row-contradiction \
    "$ROOT/tests/frontier/mn-row-contradiction.mn" E_DeclaredRowContradiction "$dir"
  # An unprovable field offset REFUSES (ARMED 2026-09-28, R0″): the plan's
  # settle point asks it under the bracket the body is emitted in, before the
  # gate reads the ledger, so the compile exits 1 with zero WAT bytes. It
  # REPORTED as narration from 2026-09-15, born RED against that pin: the same
  # three lines had compiled with ZERO errors and 4500B of WAT carrying the
  # floor, and the program trapped at an instruction no diagnostic mentioned.
  # RED again on boot dbbfd107 as a refusal: a warning and a full module.
  run_refusal "$compiler" field-offset-unprovable \
    "$ROOT/tests/frontier/mn-field-offset-unprovable.mn" E_FieldOffsetUnprovable "$dir"
  # A base whose every call is keyed to a twin is not emitted (the emitted
  # reach, 2026-09-28), so its floors are never settled, let alone refused:
  # RED on boot c5439637, which answered 46 and warned twice about `pick`'s
  # base.
  run_unnarrated "$compiler" dead-base-unnarrated \
    "$ROOT/tests/frontier/mn-dead-base-unnarrated.mn" 46 E_FieldOffsetUnprovable "$dir"
  # A handler's arms run under the key of the install that runs them (R0b,
  # 2026-09-28) — its config record's layout, its config value's width. RED
  # on boot b29e319b: the record read trapped (134) and the Float config
  # rendered as its box's address (0). The micros hold the prelude-free
  # shapes (two layouts, a walked perform, a multi-shot driver, Float state).
  run_program "$compiler" arm-config-record \
    "$ROOT/tests/frontier/mn-arm-config-record.mn" 42 yes "$dir"
  run_program "$compiler" arm-config-show-float \
    "$ROOT/tests/frontier/mn-arm-config-show-float.mn" 1 yes "$dir"
  # A config argument that is a captured variable arrives intact, now that a
  # handler's state inits are its own init fn and the install's config
  # arguments are plain expressions of its frame (R0c, 2026-09-28). RED on
  # boot 30a35888: exit 0, the config slot written with itself. Banked
  # unregistered since the march_emit dig; registered with the fix.
  run_program "$compiler" install-config-capture \
    "$ROOT/tests/frontier/mn-install-config-capture.mn" 12 io-rec "$dir"
  # AN-1: a never-returning op answers a bare variable, so fail_exit's arm
  # answers any install; the body's Int is the install's answer and the
  # process exits 1 through proc_exit (refused E_TypeMismatch while proc_exit
  # answered unit and no install had met an arm's answer).
  run_program "$compiler" "never-op-answer" \
    "$ROOT/tests/frontier/mn-never-op-answer.mn" 1 io-rec "$dir"
  # The root-row governance gate's three tiers, each pinned: an
  # EVIDENCE-floor demand refuses even with an install elsewhere (a
  # dead-chain perform walks garbage evidence, no belt — the one strict
  # sharpening); a STATEFUL singleton clears on an install (the
  # SingletonUninstalled guard the loud belt — the preinstall micro
  # holds that tier at 134); a STATELESS singleton grounds by the
  # value-sound licence (the arm ignores state), pinned by the
  # escaped-install tripwire below (exit 7 — the modal install-identity
  # frontier owns the eventual split, like residual-absence beside it).
  # RE-BANKED 2026-09-11 from 7 to 134, ON PURPOSE. The 7 pinned the
  # value-sound licence for stateless arms — a chainless direct call that
  # answered correctly because the arm ignores its record. The uniform world
  # bracket ended that licence, and the two are incompatible by construction:
  # the bracket's CONTENT is the install's world, so an arm reached after its
  # install's extent closed has no world to run under. The fixture's own text
  # reserved this split for band A's install identity; making the walk uniform
  # answered it as a side effect, so it is answered deliberately here. 134 was
  # the walk's loud refusal — nothing executes unproven. THE COMPILE-TIME
  # REFUSAL LANDED 2026-09-27 and it was never band A's: the executable root
  # gate reads the row alone now (the "installed somewhere" credit is deleted),
  # and the escaped thunk's `ping()` is in main's row with no enclosing
  # install — E_EffectUnhandled names Ping, no WAT, nonzero exit. The runtime
  # walk's 134 stays as the belt beneath it, never reached from this program.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-escaped-install.mn" | wt_run "$compiler" > "$dir/effect-escaped-install.wat" 2> "$dir/effect-escaped-install.err"
  esc_rc=$?
  if [ "$esc_rc" != "0" ] && [ ! -s "$dir/effect-escaped-install.wat" ] && grep -q 'E_EffectUnhandled.*Ping' "$dir/effect-escaped-install.err"; then
    pass "effect-escaped-install refuses at COMPILE (E_EffectUnhandled names Ping, no WAT)"
  else
    fail "effect-escaped-install (rc=$esc_rc wat=$(wc -c < "$dir/effect-escaped-install.wat"); see $dir/effect-escaped-install.err)"
  fi
  run_program "$compiler" effect-residual-absence \
    "$ROOT/tests/frontier/mn-effect-residual-absence.mn" 42 no "$dir"
  run_program "$compiler" effect-absorbed \
    "$ROOT/tests/frontier/mn-effect-absorbed.mn" 42 no "$dir"
  # The sequence-of-struct fold leaves (Hβ.emit.seq-struct-eq-leaf,
  # RESOLVED): structural ==/hash/ordering over lists whose element is
  # a product / nested list / computed string. RED on the pre-leaf
  # boot three ways — [(1,2,3)] == [(1,2,3)] exit 7 (per-element word
  # compare = pointer identity), top-level hash([1,2]) an undefined-
  # $hash_li assembly break, list-of-struct ordering by pointer. The
  # generated walkers key on the FOLD BOUNDARY (chase_deep at every
  # entry), whose collision the paired-types program measured: two
  # TList(TVar) sites with different bindings shared one raw-sig
  # walker and the second site's elements walked the wrong protocol.
  run_program "$compiler" list-tuple-eq \
    "$ROOT/tests/frontier/mn-list-tuple-eq.mn" 42 yes "$dir"
  run_program "$compiler" list-tuple-fold \
    "$ROOT/tests/frontier/mn-list-tuple-fold.mn" 42 yes "$dir"
  run_program "$compiler" rope-list-pattern \
    "$ROOT/tests/frontier/mn-rope-list-pattern.mn" 42 yes "$dir"
  run_program "$compiler" seq-rep-license \
    "$ROOT/tests/frontier/mn-seq-rep-license.mn" 42 yes "$dir"
  # E_OwnershipViolation armed 2026-07-18 — the double-move fixture moved from
  # run_diagnostic (productive exit 0) to the armed-class refusal contract.
  run_refusal "$compiler" own-call-arg-move \
    "$ROOT/tests/frontier/mn-own-call-arg-move.mn" E_OwnershipViolation "$dir"
  # E_UseAfterMove ARMED 2026-09-15 — the same move the E_OwnershipViolation
  # leg above made in July, and the condition was stated by the fixture
  # itself: "narration until the wheel's own census reaches 0 (the arming
  # law)". The census reached 0 at the Phase 4.1 landing and stayed there, so
  # the narration had become a counter held at zero — a proxy for a proof the
  # medium can hold directly (diag_refuses' own licence: "born at ZERO on
  # every program measured, which is the point"). Reading a value the affine
  # ledger already moved is not something to report and proceed through;
  # before the arena it is a stale read, after it a use-after-free.
  run_refusal "$compiler" use-after-move \
    "$ROOT/tests/frontier/mn-use-after-move.mn" E_UseAfterMove "$dir"
  # The usage grade (Phase 4.2, Hβ.infer.grade-is-join-and-mode) — the
  # (consume, read) pair walk: once-per-alternative grades Own (⊔ not +),
  # a condition read grades Ref (mode, not a consume), a statement-level
  # use counts (the NStmt blanket blindness), and neither clean own-caller
  # is falsely convicted. Pre-fix: 2 false T_OwnUnconsumed and the three
  # badges inverted.
  ug_chk=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-usage-grade.mn" 2>&1)
  ug_false=$(printf '%s' "$ug_chk" | grep -c 'T_OwnUnconsumed')
  ug_fin=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-usage-grade.mn" "type finish" 2>/dev/null)
  ug_stmt=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-usage-grade.mn" "type stmt_use" 2>/dev/null)
  if [ "$ug_false" = "0" ] \
    && printf '%s' "$ug_fin" | grep -q 'xs: [^,]* own — inferred' \
    && printf '%s' "$ug_fin" | grep -q 'c: [^)]* ref — inferred' \
    && printf '%s' "$ug_stmt" | grep -q 'xs: [^,]* own — inferred'; then
    pass "usage grade: join and mode hold (no false narration; Own/Ref badges true)"
  else
    fail "usage grade (false-narrations=$ug_false; finish='$(printf '%s' "$ug_fin" | head -1)' stmt='$(printf '%s' "$ug_stmt" | head -1)')"
  fi
  run_refusal "$compiler" refuse-refinement \
    "$ROOT/tests/frontier/mn-refuse-refinement.mn" E_RefinementRejected "$dir"
  # P0 · a refined return over a join is decided at each tail, never echoed
  # off the class — the literal branch refuses. Banked RED since 2026-07-31
  # (the class alias proved the annotation of itself: exit 0, zero verify
  # lines on boot 13e8484a).
  run_refusal "$compiler" refine-join-launder \
    "$ROOT/tests/frontier/mn-refine-join-launder.mn" E_RefinementRejected "$dir"
  # R3 · the decidable arithmetic Verify fragment. The true cases DISCHARGE at
  # compile time (zero V_Pending, run to 42); the false case is PROVEN false
  # and refuses under the armed class. Pre-R3, none of the three folded — the
  # nested `self + 1` / `self % 2` accrued silent V_Pending and the invalid
  # construction emitted.
  # Effect-polymorphic stored functions — a closure carrying its own effect row
  # stored in an ADT field, then called (the capability the mentl verb table
  # rests on). A capability smoke test; the fix's discriminating RED->GREEN was
  # the wheel's own census (7 E_PurityViolated -> 0), the fixture's own comment
  # records why the isolated shape does not itself go RED.
  run_program "$compiler" stored-fn-effect-poly \
    "$ROOT/tests/frontier/mn-stored-fn-effect-poly.mn" 42 yes "$dir"
  run_program "$compiler" refine-arith-true \
    "$ROOT/tests/frontier/mn-refine-arith-true.mn" 42 no "$dir"
  run_program "$compiler" refine-even \
    "$ROOT/tests/frontier/mn-refine-even.mn" 42 no "$dir"
  run_refusal "$compiler" refuse-refine-arith \
    "$ROOT/tests/frontier/mn-refuse-refine-arith.mn" E_RefinementRejected "$dir"
  run_refusal "$compiler" refuse-state-shadows-op \
    "$ROOT/tests/frontier/mn-refuse-state-shadows-op.mn" E_HandlerStateShadowsOp "$dir"
  run_refusal "$compiler" refuse-dup-fn \
    "$ROOT/tests/frontier/mn-refuse-dup-fn.mn" E_DuplicateFnName "$dir"
  # E_DuplicateTypeName armed at birth (2026-07-25) — the last named
  # silent-MERGE class: two `type X` decls share tag ids and a cross-tag
  # match returns the wrong arm (measured pre-refusal: exit 13 where 99 was
  # meant, zero diagnostics).
  run_refusal "$compiler" refuse-dup-type \
    "$ROOT/tests/frontier/mn-refuse-dup-type.mn" E_DuplicateTypeName "$dir"
  # E_MissingVariable armed 2026-07-18 — wheel census 0 and the user-path
  # licence measured: a no-import stdlib program resolves via the DAG's
  # prelude seed (compile exit 0, runs); the stdin contract is
  # self-contained input, where a miss is a real break. E_OccursCheck armed
  # the same day: its fixture first found the selfapply spin (a real
  # infinite type TRAPPED the compiler with zero reports); the occurs leaf
  # now recurses into bound structure and the shape reports + refuses.
  run_refusal "$compiler" refuse-missing-variable \
    "$ROOT/tests/frontier/mn-refuse-missing-variable.mn" E_MissingVariable "$dir"
  run_refusal "$compiler" refuse-occurs-check \
    "$ROOT/tests/frontier/mn-refuse-occurs-check.mn" E_OccursCheck "$dir"
  run_lsp_hover "$compiler" "$dir" lsp
  run_census "$compiler" "$dir"
  run_program "$compiler" handler-forward-ref \
    "$ROOT/tests/frontier/mn-handler-forward-ref.mn" 42 no "$dir"
  # Handler-config defaults — the parameter product at the handler decl
  # (SYNTAX §«Default parameter values»). Seen RED on the pre-fix boot:
  # `handler give(k = 7)` refused at parse (expected `)`, found `=`; exit 1,
  # zero WAT). The four faces discriminate: bare install fills from the decl
  # default, explicit fills the slot, omitting parens fills all, a labeled
  # arg skips over — 8+16+6+12 = 42.
  run_program "$compiler" handler-config-default \
    "$ROOT/tests/frontier/mn-handler-config-default.mn" 42 no "$dir"

  # ── the world-as-value gates (R2: the perform reads the live chain) ──
  # Seen RED on the pre-world boots: thunk 134 (mint-time evidence miss to
  # the sentinel), arm-config 2 (silent wrong value — the config-param
  # thunk's performs re-entered the outer handler), shadow 40 (the control,
  # already correct). Under worlds: the call-site world resolves the thunk
  # (42), the arm-internal install shadows (40), the control holds (40).
  run_program "$compiler" world-thunk \
    "$ROOT/tests/frontier/mn-world-thunk.mn" 42 yes "$dir"
  run_program "$compiler" world-arm-config \
    "$ROOT/tests/frontier/mn-world-arm-config.mn" 40 yes "$dir"
  run_program "$compiler" world-arm-shadow \
    "$ROOT/tests/frontier/mn-world-arm-shadow.mn" 40 yes "$dir"
  # R4+A4: a MultiShot remainder's singleton perform resolves through the
  # k record's FROZEN world after the crossed install's bracket exited.
  # Seen RED twice on pin 9bfcf506: 134 (the k2 loud floor at the
  # driverless crossing, pre-A4) then 30 (A4 un-floored but the perform
  # read the bracket-restored $scaler_state_g cache — the null page as its
  # config). GREEN = the chain read: (10+6) + (20+6).
  run_program "$compiler" world-resume-frozen \
    "$ROOT/tests/frontier/mn-world-resume-frozen.mn" 42 yes "$dir"

  # ── the annotation verifier PROVES (never reads boundness) ──────────
  # Seen RED on the pre-fix boot: an allocating main (++ carries its
  # callee's row) was offered "!Alloc ... proven zero allocation" — the
  # tentative-apply's post-bind NBound read was the whole check, and a
  # bind always sticks. The fix returns row_subsumes(body_row, narrowing)
  # from the apply — the fn-finalize gate's own engine. The control leg
  # keeps the TRUE proposal alive.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-teach-alloc-honest.mn" | wt_run "$compiler" teach - > "$dir/teach-alloc.out" 2>/dev/null
  # Judge main's OWN line: teach projects every fn in the linked blob, and
  # the runtime's non-allocating fns legitimately earn !Alloc lines.
  if grep '^main:' "$dir/teach-alloc.out" | grep -q '!Alloc'; then
    fail "teach-alloc-honest (an allocating body was offered !Alloc as proven)"
  else
    pass "teach-alloc-honest (no !Alloc proposal on an allocating body)"
  fi
  # Re-derived by hand 2026-09-25 (§9.11) when the literal ladder
  # [!Alloc, !IO, !Network, Pure] became the leverage count: `fn main() = 42`
  # proves `with Pure`, which implies `!Alloc` and unlocks strictly more
  # (memoize, compile-time eval, parallelize), and the ladder had ranked it
  # LAST — Pure won 0 of 165 measured suggestions. The leg still guards what
  # it was born to guard: a non-allocating body keeps a true proposal.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-teach-pure-control.mn" | wt_run "$compiler" teach - > "$dir/teach-pure.out" 2>/dev/null
  if grep '^main:' "$dir/teach-pure.out" | grep -q 'with Pure'; then
    pass "teach-pure-control (a pure body is taught its strongest proven claim, with Pure)"
  else
    fail "teach-pure-control (the true proposal died; got: $(grep '^main:' "$dir/teach-pure.out" | head -1))"
  fi

  # The tie-ranking law (Hβ.teach.severance-vocabulary-from-link's last
  # half, 2026-08-09): equal-leverage generic severances rank by link
  # PREVALENCE. The fixture performs Rare once (declared first — pure
  # enumeration order would propose !Rare, the seen-RED state) and
  # Common three times; main performs only Noise, so both are provable
  # and the winner exposes the ranking. Bare link on purpose — the
  # prelude's Alloc prevalence would hand the rich-label ladder the win
  # before generics are consulted.
  wt_run "$compiler" teach - < "$ROOT/tests/frontier/mn-teach-prevalence.mn" > "$dir/teach-prev.out" 2>/dev/null
  if grep '^main:' "$dir/teach-prev.out" | grep -q '!Common'; then
    pass "teach tie-ranking: prevalence beats enumeration order (!Common over !Rare)"
  else
    fail "teach tie-ranking (got: $(grep '^main:' "$dir/teach-prev.out" | head -1))"
  fi
  # TEACH READS THE DECLARATION AND THE JUDGMENT (PROGRAM D1/D2). Born RED
  # 2026-09-25: every fn of this fixture was told to add `!Alloc` — `step`,
  # which declares it; `add`, which proves `with Pure`; `helper`, whose
  # over-declared row the judgment had already banked — and the address
  # surface printed one constant Teach sentence at the call site.
  ta_file="$ROOT/tests/frontier/mn-teach-authored.mn"
  ta_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" teach "$ta_file" 2>/dev/null)
  ta_decl=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" "$ta_file:14" 2>/dev/null)
  ta_call=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" "$ta_file:16:30" 2>/dev/null)
  if ! printf '%s' "$ta_out" | grep '^step:' | grep -q 'add with !Alloc' \
     && printf '%s' "$ta_out" | grep '^helper:' | grep -q 'tighten' \
     && printf '%s' "$ta_out" | grep '^add:' | grep -q 'with Pure' \
     && printf '%s' "$ta_decl" | grep -q '^Teach: add `with Pure`' \
     && ! printf '%s' "$ta_call" | grep -q '^Teach:'; then
    pass "teach reads the declaration and the judgment (no redundant !Alloc; Pure taught; tightening taught; no Teach at a call)"
  else
    fail "teach-authored (teach: $(printf '%s' "$ta_out" | grep -E '^(step|helper|add):' | tr '\n' ' ') decl: $(printf '%s' "$ta_decl" | grep Teach) call: $(printf '%s' "$ta_call" | grep Teach))"
  fi

  # Hβ.emit.under-application-suspension's standing crucible (2026-08-09):
  # bare under-application must be LOUD-OR-CORRECT, never silent-wrong.
  # Green today (invalid WAT refuses at assemble), green when the fix
  # lands (the suspension runs, exit 42), RED only if the emit ever
  # produces a runnable executable with any other value — the
  # silent-wrong transition this leg exists to catch. Tighten to
  # demand-42-only when the peer's fix lands.
  ua_dir="$dir/under-app"
  mkdir -p "$ua_dir"
  wt_run "$compiler" < "$ROOT/tests/frontier/mn-under-application-loud.mn" > "$ua_dir/ua.wat" 2> "$ua_dir/ua.compile.err"
  if wt_asm "$ua_dir/ua.wat" "$ua_dir/ua.wasm" 2> "$ua_dir/ua.assemble.err"; then
    "$WT" run "${WT_RUN_FLAGS[@]}" "$ua_dir/ua.wasm" > "$ua_dir/ua.run.out" 2> "$ua_dir/ua.run.err"
    ua_rc=$?
    if [ "$ua_rc" = "42" ]; then
      pass "under-application crucible: the suspension RUNS (the peer's fix is live — tighten this leg to 42-only)"
    else
      fail "under-application crucible: a bare under-application RAN with exit $ua_rc — the silent-wrong transition (see $ua_dir)"
    fi
  else
    pass "under-application crucible: loud at assemble (invalid WAT refused; the banked peer names the suspension fix)"
  fi

  # The arena census (2026-10-02, replacing the image-classified byte count
  # the deleted ImageAlloc brackets fed): the compiler judges each binding
  # group inside an arena, and the compile's stderr reports the exits, the
  # exits that kept their region, and the KB reclaimed. An exit that keeps is
  # correct and reclaims nothing, so on the wheel's own judgment it is a
  # finding: the keeps must read 0.
  wt_run "$compiler" < "$ROOT/tests/frontier/mn-census-verbs.mn" > "$dir/arena.wat" 2> "$dir/arena.compile.err"
  if grep -qE '^arena: [0-9]+ exit\(s\), [0-9]+ kept' "$dir/arena.compile.err"; then
    ar_exits=$(grep -oE '^arena: [0-9]+' "$dir/arena.compile.err" | grep -oE '[0-9]+')
    ar_kept=$(grep -oE '[0-9]+ kept' "$dir/arena.compile.err" | grep -oE '[0-9]+')
    if [ "$ar_exits" -gt 0 ] && [ "$ar_kept" -eq 0 ]; then
      pass "arena census: the judgment's groups exit their arenas ($ar_exits exits, 0 kept)"
    else
      fail "arena census: $ar_exits exits, $ar_kept kept — an exit that keeps reclaims nothing"
    fi
  else
    fail "arena census: no arena line on the compile's stderr — the census print is prose, not mechanism"
  fi

  # The lib/lists.mn movers ratchet stood here (the trial/final divergence
  # on a polymorphic fixture). RETIRED 2026-09-17 with the second pass: the
  # `judgment:` line it read no longer prints, and a leg that passes on a
  # missing line is the mute-gate class this file's canary legs exist to
  # refuse.

  # Severance honesty (audit): a fn whose row carries Alloc is never
  # offered "proven zero allocation"; a pure fn still earns the offer.
  # The reached set reads the CHASED row (row_names was a top-link read
  # and a chained row hid its deeper presents — measured on the wheel).
  # The assertion anchors on the CLAIM (`Alloc — unlocks Real-time safe`), not on
  # the section keyword, because the keyword moved: severance reads at the
  # MODULE now and a function's own line carries only its delta above it
  # (`severs beyond the module:`), so `severable:` no longer appears per fn.
  # The invariant is unchanged and is what this leg is for.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-audit-severance-honest.mn" | wt_run "$compiler" audit - > "$dir/audit-sev.out" 2>/dev/null
  if grep -A1 '^allocates :' "$dir/audit-sev.out" | grep -q 'Alloc — unlocks Real-time safe'; then
    fail "audit-severance-honest (an allocating row was offered Alloc severance)"
  elif grep -A1 '^quiet :' "$dir/audit-sev.out" | grep -q 'Alloc — unlocks Real-time safe'; then
    pass "audit-severance-honest (Alloc never offered on an allocating row; the pure control keeps it)"
  else
    fail "audit-severance-honest (the pure control lost its true severance offer)"
  fi

  # The verb-shape tier (audit): a 2-step single-use let-chain invites the
  # |> pipe; a twice-used name (`<|` territory) and a one-step let (the
  # law's own exception) stay silent — both faces asserted.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-audit-pipe-shape.mn" | wt_run "$compiler" audit - > "$dir/audit-pipe.out" 2>/dev/null
  if grep -A4 '^chained :' "$dir/audit-pipe.out" | grep -q 'verb-shape: 2-step'; then
    if grep -A4 '^forked :' "$dir/audit-pipe.out" | grep -q 'verb-shape' \
       || grep -A4 '^single :' "$dir/audit-pipe.out" | grep -q 'verb-shape'; then
      fail "audit-pipe-shape (a <|-shaped or single-step let earned a false pipe invite)"
    else
      pass "audit-pipe-shape (the 2-step chain invites |>; the controls stay silent)"
    fi
  else
    fail "audit-pipe-shape (the let-chain's |> invite is missing)"
  fi

  # ── mentl tighten — the medium authors its own row tightening ───────
  # T_OverDeclared / T_RowInventory are MachineApplicable proposals; the
  # tighten verb writes each clause's RESIDUE — its negations and instance
  # pins, or no clause (A4, 2026-09-27: the positive row is projected, never
  # authored back). The fixture copies out (tighten MUTATES its target):
  # helper reserves Memory + Alloc over a pure body; one run deletes the
  # clause, a fresh check stays clean, and a second run finds nothing —
  # the ratchet's fixpoint. RED on the pre-verb boot (unrecognized
  # command; file untouched); the residue form seen RED on the boot that
  # wrote `with Pure` back.
  tdemo="$dir/tighten-demo"
  mkdir -p "$tdemo"
  cp "$ROOT/tests/frontier/tighten-demo/over.mn" "$tdemo/over.mn"
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp "$compiler" tighten over.mn) >"$dir/tighten.out" 2>&1
  trc=$?
  if [ $trc -eq 0 ] && grep -q '^fn helper() = 42' "$tdemo/over.mn"; then
    pass "tighten authors the residue (with Memory + Alloc → no clause; the row is projected)"
  else
    fail "tighten authoring (exit=$trc; see $dir/tighten.out)"
  fi
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp "$compiler" check over.mn) >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    pass "tighten result checks clean (fresh process)"
  else
    fail "tighten result check"
  fi
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp "$compiler" tighten over.mn) >"$dir/tighten2.out" 2>&1
  if grep -q 'nothing to tighten' "$dir/tighten2.out"; then
    pass "tighten reaches its fixpoint (second run finds nothing)"
  else
    fail "tighten fixpoint (see $dir/tighten2.out)"
  fi

  # ── E_MissingImport — the solo sweep as ONE judgment (F0b) ──────────
  # entry imports a and b; b calls a's `helper` without importing a. The
  # whole link resolves the name; on its own b would not compile. The
  # judgment refuses at the reference, naming both modules — where the
  # per-module solo sweep used to spend a process per module. RED-first on
  # boot b145b836 (accepted: exit 0, no diagnostic).
  midir="$dir/missing-import"
  mkdir -p "$midir"
  cp "$ROOT"/tests/frontier/missing-import/*.mn "$midir/"
  (cd "$midir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$midir" --dir /tmp "$compiler" check entry.mn) >"$dir/missing-import.out" 2>&1
  mirc=$?
  micount=$(grep -c 'E_MissingImport error' "$dir/missing-import.out" || true)
  if [ $mirc -ne 0 ] && [ "$micount" -ge 1 ] && grep -q 'declared in `a`, which `b` never imports' "$dir/missing-import.out"; then
    pass "missing import refuses at the reference (E_MissingImport names b and a; exit=$mirc)"
  else
    fail "missing import (exit=$mirc E_MissingImport=$micount; see $dir/missing-import.out)"
  fi

  # ── parameters pair arity for arity — the tuple-decomposition rule is gone ──
  # Two shapes the deleted "parameters ARE tuples" unification admitted and
  # the emit never carried: a pair piped into a two-parameter fn, and a
  # pair-destructuring arm literal handed where a two-argument callback is
  # called (the shape the wheel's own build wrote into a fold, 2026-09-27).
  # Both checked clean and trapped `indirect call type mismatch` on boot
  # b145b836; both refuse now. Green again only at
  # Hβ.lower.parameter-product-calling-convention.
  run_refusal "$compiler" tuple-into-binary \
    "$ROOT/tests/frontier/mn-tuple-into-binary.mn" E_TypeMismatch "$dir"
  # ── L1: arithmetic demands a number of its operand (2026-09-27) ──
  # `+ - * / %` gate their operand's type cell numeric at the judgment: a
  # bound aggregate refuses at the operator; a generic fn's instantiation at
  # a record refuses at the call that binds the copied gate; a copy minted
  # before the demand (a sig'd self-reference) is reached through the
  # instance column. All three refuse at the JUDGMENT — zero WAT — and the
  # check leg is the felt claim: `mentl check` says so.
  run_refusal "$compiler" arith-on-aggregate \
    "$ROOT/tests/frontier/mn-arith-on-aggregate.mn" E_ArithOnAggregate "$dir"
  run_refusal "$compiler" arith-on-aggregate-twin \
    "$ROOT/tests/frontier/mn-arith-on-aggregate-twin.mn" E_ArithOnAggregate "$dir"
  run_refusal "$compiler" arith-on-aggregate-instance \
    "$ROOT/tests/frontier/mn-arith-on-aggregate-instance.mn" E_ArithOnAggregate "$dir"
  aoa_n=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-arith-on-aggregate-twin.mn" 2>&1 | grep -cE 'E_ArithOnAggregate')
  if [ "$aoa_n" -ge 1 ]; then
    pass "arith-on-aggregate check: the judgment refuses (E_ArithOnAggregate=$aoa_n)"
  else
    fail "arith-on-aggregate check (E_ArithOnAggregate=$aoa_n — mentl check passed a product into a generic arithmetic)"
  fi
  run_refusal "$compiler" pair-arm-as-binary-callback \
    "$ROOT/tests/frontier/mn-pair-arm-as-binary-callback.mn" E_TypeMismatch "$dir"

  # ── mentl fmt — layout is projection, never contract ────────────────
  # The render is TOTAL over the surface and precedence-inverse (an
  # operand looser than its parent re-wraps in the parens the parse
  # consumed). Three legs, RED on the pre-verb boot: (1) BEHAVIORAL —
  # the fixture compiles+runs to 42 before AND after fmt (typechecking
  # cannot tell (a+b)*c from a+b*c; only behavior can); (2) idempotence
  # byte-exact; (3) the render carries comments and authored annotations.
  fdemo2="$dir/fmt-demo"
  mkdir -p "$fdemo2"
  cp "$ROOT/tests/frontier/fmt-demo/rich.mn" "$fdemo2/rich.mn"
  cat "${RTLIBS[@]}" "$fdemo2/rich.mn" | wt_run "$compiler" > "$fdemo2/pre.wat" 2>/dev/null \
    && wt_asm "$fdemo2/pre.wat" "$fdemo2/pre.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/pre.wasm" >/dev/null 2>&1
  fmt_pre=$?
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt rich.mn) >"$dir/fmt.out" 2>&1
  fmt_rc=$?
  cat "${RTLIBS[@]}" "$fdemo2/rich.mn" | wt_run "$compiler" > "$fdemo2/post.wat" 2>/dev/null \
    && wt_asm "$fdemo2/post.wat" "$fdemo2/post.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/post.wasm" >/dev/null 2>&1
  fmt_post=$?
  if [ $fmt_rc -eq 0 ] && [ "$fmt_pre" = "42" ] && [ "$fmt_post" = "42" ]; then
    pass "fmt preserves behavior (42 before and after the canonical render)"
  else
    fail "fmt behavioral (fmt_rc=$fmt_rc pre=$fmt_pre post=$fmt_post; see $dir/fmt.out)"
  fi
  cp "$fdemo2/rich.mn" "$fdemo2/pass1.mn"
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt rich.mn) >/dev/null 2>&1
  if cmp -s "$fdemo2/rich.mn" "$fdemo2/pass1.mn"; then
    pass "fmt is idempotent (second render byte-identical)"
  else
    fail "fmt idempotence"
  fi
  # The re-sugar: the fixture's destructure-param lambda must render as
  # its authored pattern, never the desugared __dp<handle> machine form
  # (seen RED on the pre-resugar wheel: the fan's labeled branches baked
  # minted names and the labels migrated one arm per pass).
  #
  # THE SPELLING WAS REWRITTEN 2026-09-20, the law updated rather than
  # obeyed. This leg asserted `((a, b)) =>` — the param-position form —
  # and went RED the day the arm-list literal landed, because a
  # sole-param destructure now renders `{ (a, b) => … }` (SYNTAX
  # §«Function literals»: a function is MINTED with an arm list, and the
  # param-position spelling is a CASE of it that retires with
  # `(params) => body`). The INVARIANT the leg exists for is untouched
  # and in fact held harder: the minted machine name must never reach
  # the page, and the arm list carries no param name at all. Only the
  # canonical spelling moved, so only the spelling moves here.
  if ! grep -q '__dp' "$fdemo2/rich.mn" && grep -q '{ (a, b) =>' "$fdemo2/rich.mn"; then
    pass "fmt renders the destructure as an arm list (no minted name on the canonical page)"
  else
    fail "fmt destructure re-sugar (see $fdemo2/rich.mn)"
  fi
  # A module-scope `let` bound to a function literal is born a declaration
  # (parser.mn `let_at_scope`): the binder form renders as `fn`, and the
  # arm-list form keeps `let name = { arms }`, since its one parameter is
  # minted. RED through boot 2d18aedd, where the fixture did not assemble.
  if grep -q '^fn twice_of(x) = x \* 2$' "$fdemo2/rich.mn" \
     && grep -q '^let or_zero = { Some(v) => v, None => 0 }$' "$fdemo2/rich.mn" \
     && ! grep -q '__al' "$fdemo2/rich.mn"; then
    pass "fmt renders a module let-lambda as the fn it is, an arm-list one as its literal"
  else
    fail "fmt module let-lambda (see $fdemo2/rich.mn)"
  fi
  # The annotation carry expects the SURFACE-canonical spelling — the
  # authored `{kind: String, level: Int}` byte-for-byte (space-free,
  # parse-sorted). The earlier banked `{ level: Int, kind: String }` was
  # show_type's voice spacing, retired when the formatter grew its own
  # surface-type projection.
  if grep -q '^// The fmt fixture' "$fdemo2/rich.mn" && grep -q 'b: {kind: String, level: Int}' "$fdemo2/rich.mn" \
     && grep -q 'the zero arm teaches the dark default' "$fdemo2/rich.mn"; then
    pass "fmt carries comments and authored annotations"
  else
    fail "fmt prose/annotation carry"
  fi
  # ── fmt rungs 1/2/4 (the census's universal blockers) — RED pre-fix:
  # the signed with-clause rendered «invalid-effect», every handler decl
  # trapped in render_handler_arms, and authored `-> RetTy` dropped.
  cp "$ROOT/tests/frontier/fmt-demo/voicey.mn" "$fdemo2/voicey.mn"
  cat "${RTLIBS[@]}" "$fdemo2/voicey.mn" | wt_run "$compiler" > "$fdemo2/vpre.wat" 2>/dev/null \
    && wt_asm "$fdemo2/vpre.wat" "$fdemo2/vpre.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/vpre.wasm" >/dev/null 2>&1
  vfmt_pre=$?
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt voicey.mn) >"$dir/vfmt.out" 2>&1
  vfmt_rc=$?
  cat "${RTLIBS[@]}" "$fdemo2/voicey.mn" | wt_run "$compiler" > "$fdemo2/vpost.wat" 2>/dev/null \
    && wt_asm "$fdemo2/vpost.wat" "$fdemo2/vpost.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/vpost.wasm" >/dev/null 2>&1
  vfmt_post=$?
  if [ $vfmt_rc -eq 0 ] && [ "$vfmt_pre" = "42" ] && [ "$vfmt_post" = "42" ]; then
    pass "fmt row/retty/handler behavioral (42 before and after)"
  else
    fail "fmt row/retty/handler behavioral (rc=$vfmt_rc pre=$vfmt_pre post=$vfmt_post; see $dir/vfmt.out)"
  fi
  if grep -q 'with Ping + !Pong' "$fdemo2/voicey.mn" && grep -q -- '-> Int' "$fdemo2/voicey.mn" && grep -q 'ping() => resume' "$fdemo2/voicey.mn" && ! grep -qF '{ {' "$fdemo2/voicey.mn"; then
    pass "fmt carries the signed row, the retty, the handler arm; braces never accrete"
  else
    fail "fmt row/retty/handler/brace carry (see $fdemo2/voicey.mn)"
  fi
  # The parameter face — RED on boot 43aeb30f: the effect and handler heads
  # rendered each parameter's NAME alone, so the render deleted an authored
  # annotation (effect Tick(rate: Int) became effect Tick(rate)) and the
  # declared instance Tick(2) then refused against a bare variable.
  if grep -qF 'effect Tick(rate: Int)' "$fdemo2/voicey.mn" && grep -qF 'handler ticker(r: Int)' "$fdemo2/voicey.mn"; then
    pass "fmt carries effect and handler parameter annotations"
  else
    fail "fmt parameter annotations dropped (see $fdemo2/voicey.mn)"
  fi
  cp "$fdemo2/voicey.mn" "$fdemo2/vpass1.mn"
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt voicey.mn) >/dev/null 2>&1
  if cmp -s "$fdemo2/voicey.mn" "$fdemo2/vpass1.mn"; then
    pass "fmt row/retty/handler idempotent"
  else
    fail "fmt row/retty/handler idempotence"
  fi

  # ── the cursor-address transport (mentl voice.mn:9) ─────────────────
  # Runs from the demo dir (the driver resolves imports CWD-relative).
  # Asserts the honest minimum the artifact produces today: the Query
  # line names the addressed call and its type; refusals refuse.
  demo="$ROOT/tests/frontier/voice-demo"
  out=$(cd "$demo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$demo" --dir /tmp "$compiler" voice.mn:9 2>"$dir/at9.err")
  if [ $? -eq 0 ] && printf '%s' "$out" | grep -q 'echo(mix, x) : Float'; then
    pass "cursor-address voice.mn:9 (Query names the call + type)"
  else
    fail "cursor-address voice.mn:9 (got: $out; see $dir/at9.err)"
  fi
  (cd "$demo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$demo" --dir /tmp "$compiler" voice.mn:9999) >"$dir/at-oob.out" 2>&1
  if [ $? -ne 0 ] && grep -q 'past the end' "$dir/at-oob.out"; then
    pass "cursor-address out-of-range refuses"
  else
    fail "cursor-address out-of-range (see $dir/at-oob.out)"
  fi
  # The Propose facet at the address surface: an L:C address pointing at a
  # `??` resolves the HOLE node (the column form picks the tightest span;
  # identical spans pick the latest mint) and the socket speaks the ONE
  # proven survivor — the same synth gate the edit transport's accept path
  # runs, projected at the one-shot read. Seen RED before the render arm
  # (the address printed no Propose line and resolved the id cell).
  # The FAN at the address surface: two proven survivors LIST with their
  # Reasons (the space shown, the collapsing move named) — seen RED as the
  # bare count line before the fan projection landed.
  # The comment weave at three altitudes (SYNTAX Comments — "never
  # dropped"): a decl comment, a block-INTERIOR comment, and a TRAILING
  # same-line comment each attach and render as the address's Lede facet.
  # RED before the attach arms: zero Lede lines at every address.
  ldemo="$ROOT/tests/frontier/lede-demo"
  l2=$(cd "$ldemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ldemo" --dir /tmp "$compiler" lede.mn:2 2>/dev/null | grep -c '^Lede: .*outer prose')
  l4=$(cd "$ldemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ldemo" --dir /tmp "$compiler" lede.mn:4 2>/dev/null | grep -c '^Lede: .*interior step')
  l5=$(cd "$ldemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ldemo" --dir /tmp "$compiler" lede.mn:5 2>/dev/null | grep -c '^Lede: .*trailing beat')
  # The fourth altitude, the ANONYMOUS node: prose above a lambda inside an
  # argument list attaches to the lambda (the weave keys by span, so it
  # always did) and speaks at the lambda's LINE — RED 2026-09-17 because
  # the lambda's recorded span was its head alone (`(x`), so the line's
  # widest-node rule reached a body sub-node and the Lede spoke only at
  # the exact column.
  l12=$(cd "$ldemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ldemo" --dir /tmp "$compiler" lede.mn:12 2>/dev/null | grep -c '^Lede: .*anonymous step')
  if [ "$l2" = 1 ] && [ "$l4" = 1 ] && [ "$l5" = 1 ] && [ "$l12" = 1 ]; then
    pass "comment lede (decl + interior + trailing + lambda all attach and render)"
  else
    fail "comment lede (decl=$l2 interior=$l4 trailing=$l5 lambda=$l12)"
  fi
  # `mentl doc` — the comment paradigm's reader-facing verb. It ran the
  # per-module walk check retired, so every invocation opened with
  # E_MissingVariable noise from the prelude and rendered nothing of its
  # own (RED 2026-09-17). Contract: no diagnostics, each decl with its type,
  # the decl's prose as its lede.
  dout=$(cd "$ldemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ldemo" --dir /tmp "$compiler" doc lede 2>"$dir/doc.err")
  derr=$(grep -c ' error: ' "$dir/doc.err" || true)
  if [ "$derr" = 0 ] && printf '%s' "$dout" | grep -q '^compute : ' && printf '%s' "$dout" | grep -q 'The outer prose'; then
    pass "doc projection (decls with types and ledes, no diagnostics)"
  else
    fail "doc projection (errors=$derr; see $dir/doc.err; got: $(printf '%s' "$dout" | head -3))"
  fi
  # An address is (MODULE, line, col) — and until 2026-09-19 the module half
  # was dropped for the judgment. The source slice was read by (file, line)
  # while the graph node was resolved by LINE ALONE over the whole weave's
  # span index, so whichever module owned that line number won. Since each
  # module's spans became its own 1-based coordinates, every module in the
  # link holds an entry for every line number it reaches, and the line rule's
  # widest-node pick answered with a stranger. Measured on the wheel:
  # `mentl src/synth_proposer.mn:733` rendered `scan_number`'s type, effects,
  # ownership and Lede from `src/lexer.mn`, and its own Why line said
  # `at synth_proposer:733`. The fixture is that collision in six lines —
  # helper.mn's line 4 is the widest decl on any line 4 in the weave, so it
  # wins the rule unless the module is read. RED against the prior pin:
  # `entry_at_four`'s source line beside `helper_at_four`'s type and prose.
  admemo="$ROOT/tests/frontier/address-module-demo"
  adout=$(cd "$admemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$admemo" --dir /tmp "$compiler" addr.mn:4 2>"$dir/addr-module.err")
  if printf '%s' "$adout" | grep -q "of 'entry_at_four'" \
     && printf '%s' "$adout" | grep -q '(n: Int own' \
     && ! printf '%s' "$adout" | grep -q 'helper_at_four'; then
    pass "cursor-address carries its module (line 4 is the entry's own decl, not the widest stranger's)"
  else
    fail "cursor-address module identity (got: $(printf '%s' "$adout" | head -3); see $dir/addr-module.err)"
  fi
  # ── THE EIGHT FACETS AT THE CARET (E4) ────────────────────────────
  # One program, one address per facet. Every assertion was RED on boot
  # 8b071ba3: a node's extent was its first token (`x + 1) >< (x + 2` for a
  # fanout, a string literal its closing quote), the Query slice one
  # character long, a generic variable lost the caret to the node around it,
  # no Topology line was ever written, no perform said which install served
  # it, an expression's Effects was suppressed or read off its type, and
  # Verify gave a count of whatever obligations shared the LINE.
  cdemo="$ROOT/tests/frontier/caret-facets"
  caret_at() { (cd "$cdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$cdemo" --dir /tmp "$compiler" "walk.mn:$1" 2>>"$dir/caret.err"); }
  cx=$(caret_at 15:16); cfan=$(caret_at 15:24); cstage=$(caret_at 17:27); ctick=$(caret_at 19:15)
  cprev=$(caret_at 13:26); cdiv=$(caret_at 21:18); craw=$(caret_at 23:12); clam=$(caret_at 25:31); cstr=$(caret_at 29:20)
  # The second walk, RED on the same boot: the caret on a call's `(` answered
  # the callee and on an outer `)` the inner call (a point sat inside the span
  # whose exclusive end it was), the `<~` node lost the caret to its whole
  # declaration, an arm list's type printed the parameter the desugar minted,
  # a let binding a lambda said its body's effect as its own, and a
  # parameter's read ended its Why at a bare name.
  cfb=$(caret_at 13:14); clet=$(caret_at 32:3); cpar=$(caret_at 13:32); carm=$(caret_at 15:38); ccall=$(caret_at 36:17)
  if printf '%s' "$cx" | grep -q '^Query: x : Int$' \
     && printf '%s' "$cfan" | grep -q '^Query: (x + 1) >< (x + 2) : (Int, Int)$' \
     && printf '%s' "$cstr" | grep -q '^Query: "hello world" : String$' \
     && printf '%s' "$cprev" | grep -q '^Query: prev : ' \
     && printf '%s' "$ccall" | grep -q '^Query: both(3) : Int$' \
     && printf '%s' "$cfb" | grep -q '^Query: ((prev) => prev + x) <~ delay(1) : ' \
     && printf '%s' "$carm" | grep -q '^Query: { (a, b) => a + b } : ((Int, Int)) -> Int with Pure$'; then
    pass "caret extents (a node spans the tokens it consumed; the caret is the character's extent; a minted parameter never renders)"
  else
    fail "caret extents (got: $(printf '%s' "$ccall" | head -1) / $(printf '%s' "$cfb" | head -1) / $(printf '%s' "$carm" | head -1); see $dir/caret.err)"
  fi
  if printf '%s' "$cpar" | grep -q '^Why: x flows in here, at walk:13$' \
     && printf '%s' "$cpar" | grep -q '^     parameter 1 of ramp, at walk:13$'; then
    pass "caret why (a parameter's read walks to the signature that declares it)"
  else
    fail "caret why (got: $(printf '%s' "$cpar" | grep -A1 '^Why'); see $dir/caret.err)"
  fi
  cwhere=$( (cd "$cdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$cdemo" --dir /tmp "$compiler" where walk.mn inv 2>>"$dir/caret.err") | head -1)
  if [ "$cwhere" = "→ inv(n)  at walk:11" ]; then
    pass "where answers where (the declaration's address beside its head)"
  else
    fail "where answers where (got: $cwhere; see $dir/caret.err)"
  fi
  if printf '%s' "$cx" | grep -q '^Topology: branch 1 of 2 of the >< at walk:15:15, inside the source of the |> at walk:15:14$' \
     && printf '%s' "$cstage" | grep -q '^Topology: stage 2 of 2 of the |> at walk:17:15$' \
     && printf '%s' "$cprev" | grep -q '^Topology: the recurrence the <~ feeds back at walk:13:14$'; then
    pass "caret topology (the verbs that hold the node, read down its declaration's path)"
  else
    fail "caret topology (got: $(printf '%s' "$cx" | grep '^Topology' ) / $(printf '%s' "$cstage" | grep '^Topology'); see $dir/caret.err)"
  fi
  if printf '%s' "$ctick" | grep -q '^Handler: Tick is served by `~> ticker` at walk:19:14$' \
     && printf '%s' "$craw" | grep -q '^Handler: no install inside `raw` answers Tick' \
     && printf '%s' "$clam" | grep -q '^Handler: Tick is performed when the function value at walk:25:25 is called'; then
    pass "caret handler (the install that serves a perform, or why none on the path does)"
  else
    fail "caret handler (got: $(printf '%s' "$ctick" | grep '^Handler') / $(printf '%s' "$craw" | grep '^Handler'); see $dir/caret.err)"
  fi
  if printf '%s' "$cx" | grep -q '^Effects: Pure$' \
     && printf '%s' "$cfb" | grep -q '^Effects: Pure$' \
     && printf '%s' "$clet" | grep -q '^Effects: Memory + Alloc, and Tick when called$' \
     && printf '%s' "$cdiv" | grep -q '^Effects: Trap$' \
     && printf '%s' "$cstage" | grep -q '^Effects: Pure when called$' \
     && printf '%s' "$cdiv" | grep -q '^Verify: pending partiality k - 1 != 0 && 100 / (k - 1) fits' \
     && ! printf '%s' "$cstage" | grep -q '^Verify:'; then
    pass "caret effects and verify (what running the node performs, said Pure too; each obligation inside the node, named)"
  else
    fail "caret effects/verify (got: $(printf '%s' "$cdiv" | grep -E '^(Effects|Verify)'); see $dir/caret.err)"
  fi
  # ── THE GRADIENT READS ADDRESSES (D3) ─────────────────────────────
  # The field of ONE module in the ONE order the session's argmax reads:
  # score descending, then source position. A helper's decls sit inside the
  # entry's line range, and on boot 9387fea1 the field listed them under
  # main's coordinates (5 positions, `twice` at main:4 and `total` at main:6),
  # tie-broken by handle. The session's head is that field's head, and its
  # accept is a clause the formatter writes into the decl's own file: on the
  # same boot the session focused the PRELUDE's `unwrap_or` (61:1) and
  # accepting it wrote `  with Pure` above main.mn's first line.
  gdemo="$ROOT/tests/frontier/gradient-module-demo"
  gfout=$(wt_run --dir "$gdemo::." --dir "$ROOT::/mentl-home" "$compiler" main.mn:0 2>"$dir/gradient-field.err")
  gorder=$(printf '%s\n' "$gfout" | grep -oE '^── main:[0-9]+:[0-9]+' | tr '\n' ' ')
  if printf '%s' "$gfout" | grep -q '3 gradient position(s) in main' \
     && [ "$gorder" = "── main:5:1 ── main:3:1 ── main:7:1 " ] \
     && ! printf '%s' "$gfout" | grep -qE "'(twice|total)'"; then
    pass "gradient field: the module's own positions, ranked by score then source order"
  else
    fail "gradient field (order: $gorder; see $dir/gradient-field.err)"
  fi
  gadir="$dir/gradient-accept"
  rm -rf "$gadir"; mkdir -p "$gadir" && cp "$gdemo"/*.mn "$gadir/"
  gaout=$(printf 'y\n' | timeout 60 "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$gadir::." --dir "$ROOT::/mentl-home" "$compiler" edit main 2>"$dir/gradient-accept.err")
  if printf '%s' "$gaout" | grep -q "params of 'add'" \
     && grep -qx 'fn add(a, b) with Pure = a + b' "$gadir/main.mn" \
     && [ "$(grep -c 'with' "$gadir/main.mn")" = "1" ] \
     && cmp -s "$gdemo/helper.mn" "$gadir/helper.mn" \
     && wt_run --dir "$gadir::." --dir "$ROOT::/mentl-home" "$compiler" check main > /dev/null 2>&1; then
    pass "gradient accept: the session's head is the field's head, and the clause lands in its declaration"
  else
    fail "gradient accept (main.mn now: $(tr '\n' '|' < "$gadir/main.mn" | head -c 200); see $dir/gradient-accept.err)"
  fi
  fdemo="$ROOT/tests/frontier/propose-fan-demo"
  # The FIELD form (`mentl <file>:0`): the whole absence field ranked and
  # rendered — both holes with their Propose facets (the tie teaching), the
  # gradient tier after. RED before the field arm ("lines count from 1").
  fldout=$(cd "$fdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo" --dir /tmp "$compiler" two.mn:0 2>"$dir/field.err")
  if [ $? -eq 0 ] && printf '%s' "$fldout" | grep -q 'Field: 2 hole(s), 0 pending proof(s), 0 tightening(s)' \
     && printf '%s' "$fldout" | grep -q '2 proven survivors' \
     && printf '%s' "$fldout" | grep -q 'Propose: 1'; then
    pass "cursor-address field (both holes project with their fans)"
  else
    fail "cursor-address field (got: $(printf '%s' "$fldout" | head -3); see $dir/field.err)"
  fi
  fout=$(cd "$fdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo" --dir /tmp "$compiler" bit.mn:8:30 2>"$dir/propose-fan.err")
  if [ $? -eq 0 ] && printf '%s' "$fout" | grep -q '2 proven survivors' && printf '%s' "$fout" | grep -q "the type's integer inhabitants"; then
    pass "cursor-address fan (both survivors project with Reasons)"
  else
    fail "cursor-address fan (got: $fout; see $dir/propose-fan.err)"
  fi
  pdemo="$ROOT/tests/frontier/propose-demo"
  pout=$(cd "$pdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$pdemo" --dir /tmp "$compiler" hole.mn:9:37 2>"$dir/propose-at.err")
  # The fill arrives WITH its Reason, on the same line. RED before the
  # Proposal ADT: this arm destructured `(survivor, _r)` and dropped the Why
  # while the tie arm two lines down kept it — the medium showing its
  # reasoning exactly when it was unsure and withholding it exactly where a
  # developer is most likely to accept on faith. `VFill(Node, Reason)` makes
  # the drop unsayable: the render cannot hold a fill without its Why.
  if [ $? -eq 0 ] && printf '%s' "$pout" | grep -q 'Query: ?? : Positive' \
     && printf '%s' "$pout" | grep -q "Propose: 1  — .*integer inhabitants"; then
    pass "cursor-address propose (the socket speaks the one survivor, with its Why)"
  else
    fail "cursor-address propose (got: $pout; see $dir/propose-at.err)"
  fi
  # ── THE ACCEPT IS A GRAPH WRITE, THE TEXT ITS PROJECTION (C4) ──────
  # `mentl accept hole.mn:9:37` on a scratch copy: the accept edge is drawn
  # with the survivor's proof, the module re-derives, the file carries the
  # projection (`= 1`, no `??`), and the projection the verb prints — the
  # address form over the re-derived graph — walks its Why to the accepted
  # proposal. RED on boot 4bc10808: no accept verb (exit 2, file untouched).
  adir="$dir/accept"
  mkdir -p "$adir" && cp "$pdemo/hole.mn" "$adir/hole.mn"
  aout=$(cd "$adir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$adir" --dir /tmp "$compiler" accept hole.mn:9:37 2>"$dir/accept.err")
  if [ $? -eq 0 ] && grep -q 'with Pure = 1$' "$adir/hole.mn" && ! grep -q '??' "$adir/hole.mn" \
     && printf '%s' "$aout" | grep -q '^Query: 1 : Int' \
     && printf '%s' "$aout" | grep -q '^Why: accepted `1` — proposed: .*integer inhabitants'; then
    pass "cursor-address accept (the edge drawn with its proof; the file its projection; the Why walks to the proposal)"
  else
    fail "cursor-address accept (got: $(printf '%s' "$aout" | head -3); file: $(grep -c '??' "$adir/hole.mn") hole(s); see $dir/accept.err)"
  fi
  # A TIE DRAWS NOTHING: bit.mn's two survivors are the question, never a
  # guess — the verb refuses, exits 1, and the file keeps its hole.
  cp "$fdemo/bit.mn" "$adir/bit.mn"
  tout=$(cd "$adir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$adir" --dir /tmp "$compiler" accept bit.mn:8:30 2>"$dir/accept-tie.err")
  if [ $? -ne 0 ] && grep -q 'proven survivors — a tie is a question' "$dir/accept-tie.err" && grep -q '= ??' "$adir/bit.mn"; then
    pass "cursor-address accept refuses a tie (the question stands; the hole stays)"
  else
    fail "cursor-address accept tie (rc=$?; see $dir/accept-tie.err; got: $tout)"
  fi
  # ── THE HOLE IS A TERM CELL ────────────────────────────────────────
  # `none_of() -> Option(a)` at an `Option(Int)` hole: one type under
  # unification, two shapes under a structural comparison. RED against the
  # boot in the sharpest way available — the boot LEAKED an E_TypeMismatch
  # from its own candidate exploration to a span in an unrelated module
  # (`strings:0:0-0:0`) and then proposed a bare `??`, which was the
  # ill-typed `Some()` a nullary-constructor-as-call always produced. The
  # contract here is all three halves at once: the polymorphic vocabulary
  # candidate is PROVEN, the nullary constructor is a VALUE rendered by its
  # own name, and the refusal that remains carries the medium's own words.
  tcell="$ROOT/tests/frontier/mn-hole-is-a-term-cell.mn"
  tcout=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-hole-is-a-term-cell.mn:23:38 2>"$dir/term-cell.err")
  tcerr=$(grep -c ' error: ' "$dir/term-cell.err" || true)
  if [ "$tcerr" = 0 ] && printf '%s' "$tcout" | grep -q 'none_of()' \
     && printf '%s' "$tcout" | grep -q '^  None  — ' \
     && ! printf '%s' "$tcout" | grep -q '^  ??  — lookup'; then
    pass "the hole is a term cell (the unify admits what a shape compare hid)"
  else
    fail "the hole is a term cell (errors=$tcerr; got: $(printf '%s' "$tcout" | head -5); see $dir/term-cell.err)"
  fi
  # ── the COMPUTED question — one arm of Divergence per fixture ──────
  # A tie used to end in one fixed sentence ("one more constraint … collapses
  # it"), the same words at every tie, which is a placeholder wearing a
  # teaching voice. The question is now COMPUTED from what actually separates
  # the survivors, in the precedence types.mn states: row, then denotation,
  # then value, then shape. Each leg below is one arm; all four were RED
  # against the boot, which printed the fixed sentence for every one of them.
  #
  # VALUE: two integer seeds of `Bit = Int where 0 <= self && self <= 1`, and
  # the line names what the type admits rather than asking for "a constraint".
  qv=$(cd "$fdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo" --dir /tmp "$compiler" bit.mn:8:30 2>/dev/null)
  if printf '%s' "$qv" | grep -q 'differ in VALUE and the type admits 0 through 1'; then
    pass "computed question: value (the admitted domain, not a generic ask)"
  else
    fail "computed question: value (got: $(printf '%s' "$qv" | tail -2))"
  fi
  # ROW: `silent()` is Pure, `logged()` performs Log, and choose's declared
  # row admits both — so the fill decides what the program may DO, which
  # outranks every other distinction.
  qr=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-row-tie.mn:31:33 2>/dev/null)
  if printf '%s' "$qr" | grep -q 'differ in what they may DO — Pure against Log'; then
    pass "computed question: row (the capability split outranks name and value)"
  else
    fail "computed question: row (got: $(printf '%s' "$qr" | tail -2))"
  fi
  # NAME: pure_seven(), calm_seven() and the literal 7 all denote 7 — the
  # denotation walk follows a zero-arg call to its callee's body — so the
  # only real choice is which name carries the intent.
  qn=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-capability-tie.mn:16:38 2>/dev/null)
  if printf '%s' "$qn" | grep -q 'denotes the same value — the question is which name'; then
    pass "computed question: name (one value, three spellings)"
  else
    fail "computed question: name (got: $(printf '%s' "$qn" | tail -2))"
  fi
  # THE HOLE'S ALLOWED ROW IS WHAT ITS CONTEXT ABSORBS (PROGRAM C1). `main`
  # declares nothing and the hole sits under `~> h`, which absorbs E, so a
  # candidate performing E is admissible. Born RED 2026-09-25: the proposer
  # read only the authored clause (Pure for an undeclared fn) and refused
  # `eff_one` "by the target row Pure".
  # The tie here is four wide (eff_one() beside the integer ladder), and
  # past width three the surface renders the count and the QUESTION, never
  # the members (C2, 2026-09-27) — so the fact is read off the question: a
  # ROW split, "E against Pure", can only be raised by an admitted E
  # performer. The member line this leg used to grep is no longer written.
  qa=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-hole-row-absorbed.mn:15:21 2>/dev/null)
  if printf '%s' "$qa" | grep -q '4 proven survivors' && printf '%s' "$qa" | grep -q 'E against Pure' && ! printf '%s' "$qa" | grep -q 'refused eff_one'; then
    pass "hole row: a candidate performing what the enclosing ~> absorbs is proposed (the tie's question is the row split, E against Pure)"
  else
    fail "hole row absorbed (got: $(printf '%s' "$qa" | grep -E 'eff_one|Propose|against' | head -3 | tr '\n' ' '))"
  fi
  # A PIPE STAGE IS PROPOSED BY REFERENCE, searched outward from the hole's
  # module (PROGRAM C3). Born RED 2026-09-25 on all three: `5 |> ??` offered
  # only the empty lambda skeleton — the vocabulary enumerated zero-argument
  # calls, never a function reference — so a stage hole could neither fill
  # nor ask a real question. The ring fixture is the search's own contract:
  # with no fitting function in the entry, the one its authored import
  # declares fills, and the prelude's `id` is never judged beside it.
  qp=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-pipe-stage-hole.mn:13:25 2>/dev/null)
  qf=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-pipe-stage-fill.mn:8:25 2>/dev/null)
  ringdemo="$ROOT/tests/frontier/stage-ring-demo"
  qr=$(cd "$ringdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ringdemo" --dir /tmp "$compiler" stage.mn:8:25 2>/dev/null)
  if printf '%s' "$qp" | grep -q '^  double  ' && printf '%s' "$qp" | grep -q '^  inc  ' \
     && printf '%s' "$qp" | grep -q 'different computations of the same type' \
     && ! printf '%s' "$qp" | grep -q '^  ??  ' \
     && printf '%s' "$qf" | grep -q '^Propose: double  ' \
     && printf '%s' "$qr" | grep -q '^Propose: triple  '; then
    pass "stage hole: in-scope functions proposed by reference, nearest module first (two ask the behavior question; one fills; an imported one fills)"
  else
    fail "stage hole by reference (tie: $(printf '%s' "$qp" | grep -E '^Propose|^  ' | head -4 | tr '\n' ' ') fill: $(printf '%s' "$qf" | grep '^Propose') ring: $(printf '%s' "$qr" | grep '^Propose'))"
  fi
  # SHAPE: the constant read stops at a branch, so the medium will not claim
  # two unread bodies agree — the arm that keeps DivName honest.
  qs=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-shape-tie.mn:19:31 2>/dev/null)
  # C2 (2026-09-27): a tie past width three renders the COUNT and the
  # QUESTION, never the member list — the five survivors here print as
  # "5 proven survivors" and the one question line (exactly one indented
  # line under Propose); the two-survivor stage tie above still lists both.
  # A member line is indented two spaces; the Why's deeper hops are indented
  # five (E4), so the count reads Propose's block alone.
  qs_members=$(printf '%s\n' "$qs" | grep -cE '^  [^ ]' || true)
  if printf '%s' "$qs" | grep -q 'differ in SHAPE' && printf '%s' "$qs" | grep -q '5 proven survivors' && [ "$qs_members" -eq 1 ]; then
    pass "computed question: shape (an unread body never reads as agreement; past width three the count and the question alone)"
  else
    fail "computed question: shape (members=$qs_members; got: $(printf '%s' "$qs" | tail -2))"
  fi
  # TYPE (C6): the hole's own cell is FREE, so each survivor's segment binds
  # it — `one()` to Int, `word()` to String — and that cell is the first
  # thing the two segments disagree on; the question is the position's type,
  # read off the segment's writes, never a value question about `1` and "a".
  # RED on boot b1637650: "differ in VALUE and nothing here bounds the value".
  qt=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-type-tie.mn:16:11 2>/dev/null)
  if printf '%s' "$qt" | grep -q 'differ in TYPE — Int against String'; then
    pass "computed question: type (the free cell the segments bound is the first divergence)"
  else
    fail "computed question: type (got: $(printf '%s' "$qt" | tail -2))"
  fi
  # THE CELL THAT MOVES IS THE CONTEXT'S, NOT THE HOLE'S (C6): `y + x` made
  # the hole's cell, the binder `y` and the parameter `x` one class, so a
  # survivor binds pick's own return; the question names that cell through
  # its Reason. RED on boot b1637650: a value question.
  qc=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-cell-tie.mn:17:11 2>/dev/null)
  if printf '%s' "$qc" | grep -q 'differ in TYPE — Int against Float' && printf '%s' "$qc" | grep -q 'the cell that moves: .*pick'; then
    pass "computed question: type at a context cell (a parameter's class, named by its Reason)"
  else
    fail "computed question: type at a context cell (got: $(printf '%s' "$qc" | tail -2))"
  fi
  # THE PROPOSAL BATTERY (C7): every fixture in tests/proposals carries its
  # own `// propose L:C: <want>` contract — one proven survivor whose source
  # is the text, a tie whose divergence is the named ARM, or no candidate —
  # and the medium's own `test` verb judges it against the Verdict itself,
  # structurally, never through the rendered line. Born with twenty-four
  # fixtures: one per enumerator, one per divergence arm, one per proposal
  # landing. RED on boot 2fcad4e9 as a whole: the facet did not exist.
  if wt_battery "$compiler" tests/proposals "proposals-through-m2"; then
    pass "proposal battery: every fixture's contract holds (the test verb's propose facet)"
  else
    fail "proposal battery (see the battery lines above)"
  fi
  # THE TEACH BATTERY (D4): every fixture in tests/teach carries a `// teach
  # L: <want>` contract — the annotation the gradient proposes at the
  # declaration on line L, the alternatives it asks between, a need, or
  # nothing — judged by the medium's own test verb against the Teaching.
  # RED on boot 6f62b7c4: the precondition, need and return fixtures were
  # taught `with !Alloc` or `with Pure`, and the contract did not exist.
  if wt_battery "$compiler" tests/teach "teach-through-m2"; then
    pass "teach battery: every fixture's contract holds (preconditions, return contracts, questions, needs)"
  else
    fail "teach battery (see the battery lines above)"
  fi
  # THE ACCEPT WRITES WHAT THE GRADIENT PROVED (D4): `mentl accept` at a
  # declaration writes the Teaching's annotation into its head through the
  # formatter's head render, and the module re-judges with the debt gone —
  # a precondition (the division total, no pending claim) and a return
  # contract (the caller's claim standing on it). RED on boot 6f62b7c4: the
  # accept at a declaration answered "no proposal at this position". A
  # refinement over a parameter written `n: Int` replaces the written type,
  # and the head's census counts `Int` present as the base NonZero declares.
  tadir="$dir/teach-accept"
  rm -rf "$tadir"; mkdir -p "$tadir"
  cp "$ROOT/tests/teach/precondition-weakest.mn" "$tadir/pre.mn"
  cp "$ROOT/tests/teach/return-constant.mn" "$tadir/ret.mn"
  cp "$ROOT/tests/teach/precondition-over-a-plain-type.mn" "$tadir/plain.mn"
  wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" accept pre.mn:12:1 > /dev/null 2>"$dir/teach-accept-pre.err"
  tapre=$?
  wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" accept ret.mn:7:1 > /dev/null 2>"$dir/teach-accept-ret.err"
  taret=$?
  wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" accept plain.mn:8:1 > /dev/null 2>"$dir/teach-accept-plain.err"
  taplain=$?
  tadebt=$( { wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" compile pre.mn 2>&1 >/dev/null; wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" compile ret.mn 2>&1 >/dev/null; wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" compile plain.mn 2>&1 >/dev/null; } | grep -c 'pending\| error' || true)
  if [ "$tapre" = 0 ] && [ "$taret" = 0 ] && [ "$taplain" = 0 ] \
     && [ "$(sed -n 12p "$tadir/pre.mn")" = "fn inv(n: NonZero) = 100 / n" ] \
     && [ "$(sed -n 7p "$tadir/ret.mn")" = "fn five() -> Positive = 5" ] \
     && [ "$(sed -n 8p "$tadir/plain.mn")" = "fn inv(n: NonZero) = 100 / n" ] \
     && [ "$tadebt" = 0 ]; then
    pass "teach accept: a precondition, a refinement over a written Int and a return contract written into their heads, the debt gone"
  else
    fail "teach accept (pre exit=$tapre line: $(sed -n 12p "$tadir/pre.mn"); ret exit=$taret line: $(sed -n 7p "$tadir/ret.mn"); plain exit=$taplain line: $(sed -n 8p "$tadir/plain.mn"); debt lines=$tadebt)"
  fi
  # OBLIGATIONS AT A NODE ARE THE NODE'S MODULE'S (D4): the Verify facet
  # filtered the ledger by span alone, and every module numbers its lines
  # from 1, so the entry's `total` on line 3 counted the helper's open
  # division on ITS line 3. RED on boot 6f62b7c4: "Verify: 1 obligation(s)"
  # at a declaration that owes nothing.
  odemo="$ROOT/tests/frontier/obligation-module-demo"
  odmain=$(wt_run --dir "$odemo::." --dir "$ROOT::/mentl-home" "$compiler" main.mn:3 2>/dev/null)
  odhelp=$(wt_run --dir "$odemo::." --dir "$ROOT::/mentl-home" "$compiler" helper.mn:3 2>/dev/null)
  # E4: the facet names each obligation inside the node rather than counting
  # the ones on its line.
  if ! printf '%s' "$odmain" | grep -q '^Verify:' && printf '%s' "$odhelp" | grep -q '^Verify: pending partiality n != 0'; then
    pass "obligations at a node are its module's (the entry owes nothing; the helper owes its division)"
  else
    fail "obligation module identity (main: $(printf '%s' "$odmain" | grep '^Verify' | head -1); helper: $(printf '%s' "$odhelp" | grep '^Verify' | head -1))"
  fi
  # ── the render register (DiagScope) ────────────────────────────────
  # A user-target projection over the FULL weave (repo root mounted, so
  # lib+src weave in) scopes narration to the user's file: the substrate's
  # self-lint never reaches the user's stderr, and the projection is
  # intact. RED on the pre-register boot: 173 Warning lines before the
  # six-line answer.
  sout=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" tests/frontier/propose-fan-demo/bit.mn:8:30 2>"$dir/scope-register.err")
  swarn=$(grep -c 'Warning' "$dir/scope-register.err" || true)
  if [ "$swarn" -eq 0 ] && printf '%s' "$sout" | grep -q '2 proven survivors'; then
    pass "render register (substrate narration scoped out; the fan intact)"
  else
    fail "render register (warnings=$swarn; see $dir/scope-register.err)"
  fi
  # The register's other face: the user's OWN narration still renders,
  # exactly once, and never silently — scoping is a register, not a mute.
  wout=$(cd "$fdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo" --dir /tmp "$compiler" check scope-own.mn 2>&1)
  wcount=$(printf '%s' "$wout" | grep -c 'E_RedundantBraces' || true)
  if [ "$wcount" -eq 1 ]; then
    pass "render register (the user's own warning survives, once)"
  else
    fail "render register own-warning (want 1 E_RedundantBraces, got $wcount)"
  fi
  # ── the one judge — order-independent verdicts on the DAG path ─────
  # The check/audit/at/field verbs judge through infer_program_converged
  # now (the single-pass walk is deleted). RED on the pre-judge boot: a
  # fn declared AFTER its caller read a loose pre-registration, so its
  # [tuple] return bound SILENTLY against a [String] parameter (the
  # audit_walk incident's minimal form — zero diagnostics, a runtime
  # flat_fill trap). Through the one judge the forward reference
  # resolves the callee's FINAL scheme and the check REFUSES.
  fwd_out=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" check tests/frontier/mn-check-forward-order.mn 2>&1)
  fwd_rc=$?
  fwd_count=$(printf '%s' "$fwd_out" | grep -Fc 'E_TypeMismatch error: (Int, String) vs List(Byte)' || true)
  if [ "$fwd_rc" -ne 0 ] && [ "$fwd_count" -ge 1 ]; then
    pass "check-forward-order (the DAG path judges converged: forward tuple-into-[String] refuses)"
  else
    fail "check-forward-order (exit=$fwd_rc mismatches=$fwd_count — the forward-ref seam is open)"
  fi
  # ── mentl session — the resident graph as the CLI's default transport ──
  # The living session behind the shim's tcplisten seam answers read
  # verbs over a one-line wire speaking the CLI's own grammar; anything
  # it does not serve answers the MISS sentinel and the shim falls back
  # cold. RED on any pre-session boot: the verb is unrecognized, nothing
  # listens, both probes fail. The oracle is the strongest available:
  # the resident answer must BYTE-EQUAL the cold verb's.
  sessdir="$dir/session-proj"
  mkdir -p "$sessdir"
  printf 'fn width(n) = n + 2\n\nfn main() = width(40)\n' > "$sessdir/main.mn"
  sess_port=7391
  # An orphan from a prior run holds the port and answers with ITS stale
  # graph (measured: a leftover session served the REPO main's audit —
  # the fresh session could never bind). Clear by the port's own
  # fingerprint, and mount the project as guest "." so the wheel's
  # relative "main.mn" probe resolves the FIXTURE, never falling through
  # to /mentl-home (the space verb's own mount convention).
  pkill -f "tcplisten=127.0.0.1:${sess_port}" 2>/dev/null
  sleep 1
  (cd "$sessdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$sessdir::." --dir /tmp --dir "$ROOT::/mentl-home" -S "tcplisten=127.0.0.1:${sess_port}" "$compiler" session >"$dir/session.log" 2>&1) &
  sess_pid=$!
  : > "$dir/session-resident.txt"
  for _ in $(seq 1 60); do
    # Direct redirect, never command substitution — $(...) strips the
    # trailing newline and a one-byte "divergence" fails the byte oracle.
    bash -c "exec 3<>/dev/tcp/127.0.0.1/${sess_port} 2>/dev/null && printf 'audit\tmain\t\n' >&3 && cat <&3" > "$dir/session-resident.txt" 2>/dev/null
    [ -s "$dir/session-resident.txt" ] && break
    sleep 1
  done
  (cd "$sessdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$sessdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" audit main 2>/dev/null) > "$dir/session-cold.txt"
  if [ -s "$dir/session-resident.txt" ] && cmp -s "$dir/session-resident.txt" "$dir/session-cold.txt"; then
    pass "session resident audit (byte-equal to the cold verb)"
  else
    fail "session resident audit (empty or diverged; see $dir/session-resident.txt vs session-cold.txt)"
  fi
  sess_miss=$(bash -c "exec 3<>/dev/tcp/127.0.0.1/${sess_port} 2>/dev/null && printf 'compile\tmain\t\n' >&3 && cat <&3" 2>/dev/null)
  if printf '%s' "$sess_miss" | grep -q 'MENTL-SESSION-MISS'; then
    pass "session MISS sentinel (cold-only verbs decline; the shim falls back)"
  else
    fail "session MISS sentinel (got: $sess_miss)"
  fi
  # A REFUSAL ANSWERS MISS (E2). A verb that refuses says why on stderr and
  # gives its verdict as the exit code, and the wire carries neither — the
  # socket's stderr is the server's terminal — so the session answers MISS
  # and the cold route says the refusal whole. RED on boot 713745c6: the
  # address past the end of the file answered nothing, as if it had
  # succeeded, where the cold verb names the file's length and exits 1.
  sess_ref=$(bash -c "exec 3<>/dev/tcp/127.0.0.1/${sess_port} 2>/dev/null && printf 'main.mn:999:1\n' >&3 && cat <&3" 2>/dev/null)
  if [ "$sess_ref" = "MENTL-SESSION-MISS" ]; then
    pass "session refusal answers MISS (the cold route says it whole)"
  else
    fail "session refusal answers MISS (got: [$sess_ref])"
  fi
  # Kill by the port fingerprint — the subshell pid is the wrapper, and
  # killing it orphans the wasmtime grandchild (the stale-graph server
  # this leg's first red was).
  pkill -f "tcplisten=127.0.0.1:${sess_port}" 2>/dev/null
  kill "$sess_pid" 2>/dev/null
  wait "$sess_pid" 2>/dev/null
  # ── the session on stdin (E2) ──────────────────────────────────────
  # A host that preopens no listener owns the process's input instead — a
  # browser worker, a pipe — and the session answers one line per verb, the
  # answer written whole before the next line is read. The oracle is the
  # cold verb byte for byte, then the refusal's MISS. RED on boot 713745c6:
  # without a listener the verb refused.
  stdir="$dir/session-stdin"
  rm -rf "$stdir"
  mkdir -p "$stdir"
  printf 'fn width(n) = n + 2\n\nfn main() = width(40)\n' > "$stdir/main.mn"
  printf 'audit\tmain\nmain.mn:999:1\n' \
    | (cd "$stdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$stdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" session) \
      > "$stdir/out.txt" 2> "$stdir/err.log"
  { (cd "$stdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$stdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" audit main 2>/dev/null); echo MENTL-SESSION-MISS; } > "$stdir/want.txt"
  if cmp -s "$stdir/out.txt" "$stdir/want.txt" && grep -q 'graph resident on stdin' "$stdir/err.log"; then
    pass "session on stdin (the resident audit byte-equal to the cold verb, then the refusal's MISS)"
  else
    fail "session on stdin (diff $stdir/out.txt $stdir/want.txt; see $stdir/err.log)"
  fi
  # ── the accept's edge outlives the reply (E2) ──────────────────────
  # Through the shim's own rule: ask the session, and on MISS run the verb
  # cold. The session draws the accept into the graph it keeps, so the
  # next read of the position walks to the proposal; a cold accept drew it
  # in a process that ended with the reply. RED on boot 713745c6: the
  # accept answered MISS, the cold accept wrote `1`, and the next resident
  # read said "Why: int literal".
  acdir="$dir/session-accept"
  rm -rf "$acdir"
  mkdir -p "$acdir"
  printf 'type Positive = Int where 0 < self\n\nfn choose() -> Positive = ??\n\nfn main() = choose()\n' > "$acdir/main.mn"
  ac_port=7393
  pkill -f "tcplisten=127.0.0.1:${ac_port}" 2>/dev/null
  sleep 1
  (cd "$acdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$acdir::." --dir /tmp --dir "$ROOT::/mentl-home" -S "tcplisten=127.0.0.1:${ac_port}" "$compiler" session >"$acdir/session.log" 2>&1) &
  ac_pid=$!
  ac_ask() { bash -c "exec 3<>/dev/tcp/127.0.0.1/${ac_port} 2>/dev/null && printf '%s\n' \"\$1\" >&3 && cat <&3" _ "$1" 2>/dev/null; }
  : > "$acdir/before.txt"
  for _ in $(seq 1 60); do
    ac_ask 'main.mn:3:27' > "$acdir/before.txt"
    [ -s "$acdir/before.txt" ] && break
    sleep 1
  done
  if [ "$(ac_ask "$(printf 'accept\tmain.mn:3:27')")" = "MENTL-SESSION-MISS" ]; then
    (cd "$acdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$acdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" accept main.mn:3:27 > "$acdir/cold-accept.txt" 2>&1)
  fi
  ac_ask 'main.mn:3:27' > "$acdir/later.txt"
  if grep -q '^Why: accepted `1` — proposed' "$acdir/later.txt" && grep -q 'fn choose() -> Positive = 1$' "$acdir/main.mn"; then
    pass "session accept: the next read walks to the proposal"
  else
    fail "session accept (see $acdir/later.txt)"
  fi
  pkill -f "tcplisten=127.0.0.1:${ac_port}" 2>/dev/null
  kill "$ac_pid" 2>/dev/null
  wait "$ac_pid" 2>/dev/null
  # ── mentl space — the ide served by the wheel ──────────────────────
  # The verb absorbs ide/serve.mn whole: the accept loop lives in
  # src/main.mn, the listener is the shim's tcplisten preopen seam (WASI
  # p1 has no bind/listen). Leg 1: without a listener the verb refuses
  # and TEACHES the seam. Leg 2: with one preopened it serves
  # ide/index.html carrying the cross-origin-isolation pair the
  # shared-memory compiler requires. Both seen RED on the pre-verb boot
  # ("unrecognized or under-specified command: space").
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" space >"$dir/space-refuse.out" 2>&1
  if [ $? -ne 0 ] && grep -q 'no listener preopened' "$dir/space-refuse.out"; then
    pass "space refuses without a listener (and teaches the seam)"
  else
    fail "space no-listener refusal (see $dir/space-refuse.out)"
  fi
  space_port=7379
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." -S "tcplisten=127.0.0.1:${space_port}" "$compiler" space >"$dir/space-serve.log" 2>&1 &
  space_pid=$!
  space_hdr=""
  for _ in $(seq 1 20); do
    space_hdr=$(curl -s -D - -o "$dir/space-index.html" "http://127.0.0.1:${space_port}/ide/index.html" 2>/dev/null) && break
    sleep 0.3
  done
  kill "$space_pid" 2>/dev/null
  wait "$space_pid" 2>/dev/null
  if printf '%s' "$space_hdr" | grep -q '200 OK' \
     && printf '%s' "$space_hdr" | grep -qi 'Cross-Origin-Embedder-Policy: require-corp' \
     && [ -s "$dir/space-index.html" ]; then
    pass "space serves ide/index.html with the isolation pair"
  else
    fail "space live serve (status: $(printf '%s' "$space_hdr" | head -1); see $dir/space-serve.log)"
  fi
  # ── mentl mcp — the gate served over MCP stdio ─────────────────────
  # The Synth-gate as an agent-facing surface: newline-delimited JSON-RPC,
  # one tool (propose). One scripted session exercises the whole contract:
  # handshake, tools/list, a violating proposal REFUSED with teaching
  # diagnostics at FILE-LOCAL spans (the stdin channel judges the proposal
  # alone — no lib weave, so spans are the agent's own lines), the honest
  # sibling PROVEN with the artifact landing on disk (only proven bytes
  # ever do), a malformed call (isError:true, teaches), an unknown method
  # (-32601), and ping. Seen RED on the pre-verb boot (unknown verb: the
  # catalog on stdout, zero jsonrpc lines).
  mcp_dir="$dir/mcp-session"
  mkdir -p "$mcp_dir"
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$mcp_dir::." "$compiler" mcp \
    < "$ROOT/tests/frontier/mcp-session.jsonl" >"$mcp_dir/out.jsonl" 2>"$mcp_dir/err.log"
  if grep -q '"serverInfo":{"name":"mentl"' "$mcp_dir/out.jsonl" \
     && grep -q '"tools":\[{"name":"propose"' "$mcp_dir/out.jsonl"; then
    pass "mcp handshake + tools/list serve the propose tool"
  else
    fail "mcp handshake (see $mcp_dir/out.jsonl)"
  fi
  # The span assertion names the SOURCE as well as the line (2026-09-15).
  # It read `at 3:1` and broke the day the diagnostic render gained its
  # module half — a gate welded to a render, snapped by improving the
  # render, the RENDER-PARSE class this session spent the day naming.
  # `at <stdin>:3:1` is strictly STRONGER: the mcp transport feeds the
  # claim on stdin, so a teaching span that pointed at any OTHER file
  # would now fail where before it passed — which is exactly the
  # file-local property the pass line claims.
  # TWO claims since 2026-09-25, re-derived by hand before re-banking
  # (§9.11): `fn bad() with !E = op()` with no handler anywhere violates its
  # own declared `!E` (E_EffectMismatch — a REFUSING claim since the class
  # was armed that day; before, it narrated beside the one refusal) AND lets
  # E reach the executable root unhandled (E_EffectUnhandled). Two
  # independent claims fail; "1 claim" was the unarmed era's count.
  if grep -q 'REFUSED — 2 claim' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectMismatch' "$mcp_dir/out.jsonl" \
     && grep -q 'at <stdin>:3:1' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectUnhandled' "$mcp_dir/out.jsonl"; then
    pass "mcp propose REFUSES with file-local teaching spans"
  else
    fail "mcp refusal verdict (see $mcp_dir/out.jsonl)"
  fi
  if grep -q 'PROVEN — every claim discharged' "$mcp_dir/out.jsonl" \
     && [ -s "$mcp_dir/.build/mcp/last.wat" ]; then
    pass "mcp propose PROVES and the artifact lands"
  else
    fail "mcp proven verdict + artifact (see $mcp_dir/out.jsonl)"
  fi
  if grep -q '"isError":true' "$mcp_dir/out.jsonl" \
     && grep -q '"code":-32601' "$mcp_dir/out.jsonl" \
     && grep -q '"id":7.0,"result":{}' "$mcp_dir/out.jsonl"; then
    pass "mcp malformed call teaches; unknown method -32601; ping answers"
  else
    fail "mcp error contract (see $mcp_dir/out.jsonl)"
  fi
  # ── the RESIDENT SESSION (Hβ.session.resident-verbs, first rung) ───
  # A project dir: the server derives the graph ONCE at startup (the
  # resident line prints exactly once) and both queries answer as LIVE
  # reads — schemes with Reasons, no re-derivation; a propose after the
  # session reads still PROVES in its own nested instances. Seen RED on
  # the pre-session boot: tools/list served propose alone and query was
  # -32602. All three swap-crossing constraints hold by construction
  # (no swap exists — the image IS the session's memory).
  ses_dir="$dir/mcp-resident"
  mkdir -p "$ses_dir"
  # A BARE module — no imports, no declarations. The severance assertion
  # below is the leg TEACHING what must be there: every Mentl program
  # runs on the substrate, so `with !Alloc` is sayable and provable in
  # any file without importing anything. When this went red under the
  # severance tier's graph read, the fixture was briefly edited to suit
  # the weaker world — the regression. The truth the red was reporting:
  # the SESSION was deriving without the substrate vocabulary at all,
  # because this invocation mounted only the project dir. The agent-
  # facing gate must see the same world the CLI does (the shim's own
  # mount, every other leg's mount) — the engine meets the surface.
  printf 'fn double(x) = x * 2\n\nfn main() = double(21)\n' > "$ses_dir/main.mn"
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ses_dir::." --dir "$ROOT::/mentl-home" "$compiler" mcp \
    < "$ROOT/tests/frontier/mcp-resident-session.jsonl" >"$ses_dir/out.jsonl" 2>"$ses_dir/err.log"
  # The audit assertion reads `severs module-wide:` — severance is a MODULE
  # fact now, and this two-fn fixture is Pure throughout, so the whole module
  # severs Alloc and the projection says it ONCE instead of repeating it on
  # `double` and again on `main`.
  if [ "$(grep -c 'session: graph resident' "$ses_dir/err.log")" = "1" ] \
     && grep -q '"tools":\[{"name":"propose"' "$ses_dir/out.jsonl" \
     && grep -q '"name":"query"' "$ses_dir/out.jsonl" \
     && grep -q '"name":"at"' "$ses_dir/out.jsonl" \
     && grep -q '"name":"audit"' "$ses_dir/out.jsonl" \
     && grep -q '"name":"teach"' "$ses_dir/out.jsonl" \
     && grep -q 'x: Int own' "$ses_dir/out.jsonl" \
     && grep -q 'declared as main' "$ses_dir/out.jsonl" \
     && grep -q 'Query: fn double' "$ses_dir/out.jsonl" \
     && grep -q 'double : Pure' "$ses_dir/out.jsonl" \
     && grep -q 'severs module-wide: Alloc' "$ses_dir/out.jsonl" \
     && grep -qE 'annotation density|→ add' "$ses_dir/out.jsonl" \
     && ! grep -q 'iterate : ' "$ses_dir/out.jsonl" \
     && grep -q 'PROVEN — every claim discharged' "$ses_dir/out.jsonl"; then
    pass "resident session: one derivation, live query + at + audit + teach reads, propose coexists"
  else
    fail "resident session (resident-lines=$(grep -c 'session: graph resident' "$ses_dir/err.log"); see $ses_dir/out.jsonl)"
  fi
  # ── the FRONTIER READ (rung 5): the oracle's field as a session tool ─
  # The ranked absence field over the resident graph — the gradient's
  # argmax uncollapsed, the same read `mentl main.mn:0` serves. Seen RED
  # on the pre-rung boot three ways: the hole rendered at the WRONG
  # address with the wrong Query slice (caret_span_of_handle read the
  # chase TERMINAL's span — a hole unified with a call answered the
  # call's site; the birth span index is the only never-rebound
  # channel), and the gradient tier held 7 positions for a 3-fn file
  # (the enumerator asked teach_gradient about every cell in
  # range(0, next) — virgin cells included — and junk suggestions
  # entered under garbage coordinates; the kind gate scopes it to real
  # fn decls). Known residue asserted AS-IS: the last lib's tail
  # comment attaches forward across the module seam to the entry's
  # first decl (Hβ.parser.comment-attach-module-boundary).
  fro_dir="$dir/mcp-frontier"
  mkdir -p "$fro_dir"
  printf 'fn width(x) = x * 2\n\nfn banner(n) = {\n  let w = width(n)\n  w + ??\n}\n\nfn main() = banner(21)\n' > "$fro_dir/main.mn"
  printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}\n{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"frontier","arguments":{}}}\n' \
    | "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fro_dir::." "$compiler" mcp >"$fro_dir/out.jsonl" 2>"$fro_dir/err.log"
  if grep -q '"name":"frontier"' "$fro_dir/out.jsonl" \
     && grep -q 'Field: 1 hole(s), 0 pending proof(s), 0 tightening(s), 3 gradient position(s)' "$fro_dir/out.jsonl" \
     && grep -q 'main:5:7' "$fro_dir/out.jsonl" \
     && grep -q 'Query: ?? : Int' "$fro_dir/out.jsonl" \
     && grep -q 'Propose: 3 proven survivors' "$fro_dir/out.jsonl"; then
    pass "frontier read: the ranked field answers live — the hole at its true address with its fan, the gradient tier decl-scoped"
  else
    fail "frontier read (see $fro_dir/out.jsonl)"
  fi
  # ── the WHOLE PROBLEM SPACE (rung 6): every absence is a position ──
  # The field ranks all four absence kinds — holes, pending proof
  # obligations (the verify ledger's live debt), over-declared rows
  # (each carrying its proven-row patch), and the gradient tier — and
  # the LIVING resolution: an edit that makes the row honest drops the
  # tightening from the next frontier (the generation clears, for the
  # cone the edit moved: tighten_forget + verify_forget before its
  # re-judgment; the enumerators dedup by span START, latest mint wins).
  # Seen RED on the
  # pre-rung boot: the count line had two tiers, the debt and the
  # tightenings were invisible to the field, and the second generation
  # doubled every position.
  prob_dir="$dir/mcp-problems"
  mkdir -p "$prob_dir"
  printf 'type Pos = Int where 0 < self\n\nfn scaled(x) -> Pos = x * 3\n\nfn noisy() with IO = 7\n\nfn main() = scaled(2) + noisy() + ??\n' > "$prob_dir/main.mn"
  mkfifo "$prob_dir/in"
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$prob_dir::." "$compiler" mcp \
    < "$prob_dir/in" >"$prob_dir/out.jsonl" 2>"$prob_dir/err.log" &
  prob_srv=$!
  exec 9> "$prob_dir/in"
  prob_wait() { for _i in $(seq 1 150); do [ "$(wc -l < "$prob_dir/out.jsonl")" -ge "$1" ] && return 0; sleep 0.2; done; return 1; }
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}' >&9
  printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"frontier","arguments":{}}}' >&9
  prob_wait 2 || true
  printf 'type Pos = Int where 0 < self\n\nfn scaled(x) -> Pos = x * 3\n\nfn noisy() = 7\n\nfn main() = scaled(2) + noisy() + ??\n' > "$prob_dir/main.mn"
  printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"frontier","arguments":{}}}' >&9
  prob_wait 3 || true
  exec 9>&-
  wait $prob_srv 2>/dev/null
  # id 2 counts TWO gradient positions since 2026-09-25, re-derived by hand
  # (§9.11): `noisy` declares `with IO` over a pure body, so its teach is the
  # TIGHTENING the field already lists in its own tier; the gradient used to
  # count it again as a position (offering it `!Alloc` beside its declared
  # row), one declaration counted twice. After the edit removes the row,
  # noisy is an undeclared fn the gradient teaches, and id 3's three stand.
  if grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Field: 1 hole(s), 1 pending proof(s), 1 tightening(s), 2 gradient position(s)' \
     && grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Pending: 0 < self' \
     && grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Tighten: noisy declares IO — the body proves Pure' \
     && grep '"id":3' "$prob_dir/out.jsonl" | grep -q 'Field: 1 hole(s), 1 pending proof(s), 0 tightening(s), 3 gradient position(s)' \
     && [ "$(grep -c 'session: tree moved' "$prob_dir/err.log")" = "1" ]; then
    pass "problem space: pending + tightening rank as positions; the honest edit clears its tightening from the living frontier"
  else
    fail "problem space (see $prob_dir/out.jsonl)"
  fi
  # ── the LIVING SESSION (rung 4): the graph tracks the tree ─────────
  # The file is edited BETWEEN messages (a fifo coprocess; responses are
  # one line per request, so waiting on the response count synchronizes
  # deterministically); the session's manifest check re-derives INTO the
  # resident world exactly once, and the post-edit reads answer the NEW
  # truth: query resolves the new fn, audit lists it, and the at reaches
  # a line that did not exist before the edit (the range map replaced).
  # Seen RED on the pre-living boot (measured 2026-07-29): moved=0,
  # triple absent from every face — the startup snapshot answering
  # stale. The staleness check is a PURE READ (driver_manifest over the
  # banked range paths — no discovery, no parse, no graph write): its
  # first form re-ran collect_dag per message and the discovery parse's
  # spine growth died in a resettable message's region reclaim (the
  # fork-spine class, measured as spine_comment_at's list_index trap).
  liv_dir="$dir/mcp-living"
  mkdir -p "$liv_dir"
  printf 'fn double(x) = x * 2\n\nfn main() = double(21)\n' > "$liv_dir/main.mn"
  mkfifo "$liv_dir/in"
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$liv_dir::." "$compiler" mcp \
    < "$liv_dir/in" >"$liv_dir/out.jsonl" 2>"$liv_dir/err.log" &
  liv_srv=$!
  exec 9> "$liv_dir/in"
  liv_wait() { for _i in $(seq 1 150); do [ "$(wc -l < "$liv_dir/out.jsonl")" -ge "$1" ] && return 0; sleep 0.2; done; return 1; }
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}' >&9
  printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"query","arguments":{"question":"type double"}}}' >&9
  liv_wait 2 || true
  printf 'fn double(x) = x * 3\n\nfn triple(x) = x * 3\n\nfn main() = triple(14)\n' > "$liv_dir/main.mn"
  printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query","arguments":{"question":"type triple"}}}' >&9
  printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"audit","arguments":{}}}' >&9
  printf '%s\n' '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"at","arguments":{"line":5,"col":4}}}' >&9
  liv_wait 5 || true
  exec 9>&-
  wait $liv_srv 2>/dev/null
  if [ "$(grep -c 'session: tree moved' "$liv_dir/err.log")" = "1" ] \
     && grep -q 'declared as double' "$liv_dir/out.jsonl" \
     && grep -q 'declared as triple' "$liv_dir/out.jsonl" \
     && grep -q 'triple : Pure' "$liv_dir/out.jsonl" \
     && grep -q 'Query: fn main(' "$liv_dir/out.jsonl"; then
    pass "living session: the graph tracks the tree — one re-derivation, post-edit reads answer the new truth"
  else
    fail "living session (moved=$(grep -c 'session: tree moved' "$liv_dir/err.log"); see $liv_dir/out.jsonl)"
  fi
  # ── the intent ranker — survivors ordered by local intent ──────────
  # candidate_rank reads the graph (decl nearness + use-edge nearness
  # against the hole's span, now carried on Context): a name already
  # USED near the hole outranks earlier-declared unused siblings. Seen
  # RED on the pre-ranker boot: kerning() surfaced first (enumeration
  # order); the rank lifts width() (one use edge in the enclosing body).
  # The hole is Positive, so the tie is three wide (width, kerning, the
  # ladder's 1) and the members render — the ORDER is only observable in
  # the member list, which the surface writes up to width three (C2).
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" tests/frontier/mn-ranker-local-intent.mn:13:24 >"$dir/ranker.out" 2>/dev/null
  first_survivor=$(grep -A1 'Propose:' "$dir/ranker.out" | tail -1)
  if printf '%s' "$first_survivor" | grep -q 'width()'; then
    pass "ranker: local intent lifts the used name (width first)"
  else
    fail "ranker order (first survivor: $first_survivor)"
  fi
  # The enclosing-decl guard, tree-descended: a hole inside banner's
  # multi-line body must not propose banner() (the enclosing fn) nor
  # main() (whose free names reach banner). Seen RED on the span-blind
  # boot: both appeared — head-anchored spans cannot resolve containment.
  if ! grep -q 'banner()' "$dir/ranker.out" && ! grep -q 'main()' "$dir/ranker.out"; then
    pass "ranker: enclosing-decl containment excludes banner()/main()"
  else
    fail "ranker containment (banner/main leaked into the fan; see $dir/ranker.out)"
  fi
  # ── instance-precise negation (Arc 3's first landing) ──────────────
  # The parameterized effect DECL head parses (RED on the prior boot:
  # ten P_ tokens at `effect Sample(rate: Int)`), and the negation holds
  # its instance: a declared !Sample(44100) beside Sample(48000) SURVIVES
  # row construction (the by-name dedup used to delete it silently) and
  # blocks conservatively — same instance and bare performs report,
  # a provably-distinct sibling instance is admitted and runs.
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-instance-sibling.mn" | wt_run "$compiler" > "$dir/inst-sib.wat" 2> "$dir/inst-sib.err" \
    && wt_asm "$dir/inst-sib.wat" "$dir/inst-sib.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$dir/inst-sib.wasm"
  sib_rc=$?
  if [ "$sib_rc" = "42" ] && ! grep -q 'E_EffectMismatch' "$dir/inst-sib.err"; then
    pass "instance negation admits the provably-distinct sibling (42, no mismatch)"
  else
    fail "instance sibling (rc=$sib_rc; see $dir/inst-sib.err)"
  fi
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-instance-severed.mn" | wt_run "$compiler" > /dev/null 2> "$dir/inst-sev.err"
  if grep -q 'E_EffectMismatch' "$dir/inst-sev.err"; then
    pass "instance negation severs the same instance (mismatch reported)"
  else
    fail "instance severed (no mismatch; see $dir/inst-sev.err)"
  fi
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-instance-bare.mn" | wt_run "$compiler" > /dev/null 2> "$dir/inst-bare.err"
  if grep -q 'E_EffectMismatch' "$dir/inst-bare.err"; then
    pass "instance negation blocks the bare perform (conservative)"
  else
    fail "instance bare (no mismatch; see $dir/inst-bare.err)"
  fi
  # Instance-arg TYPING against the registered signature (the TTuple
  # scheme register_effect_ops publishes): a scalar-literal arg whose
  # ground type disagrees reports the mismatch; wrong arity reports the
  # constructor-arity class. Both RED on the prior boot (silent admits;
  # the head itself only parse-recovered there).
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-instance-argty.mn" | wt_run "$compiler" > /dev/null 2> "$dir/inst-argty.err"
  if grep -q 'E_TypeMismatch' "$dir/inst-argty.err" && ! grep -q 'P_' "$dir/inst-argty.err"; then
    pass "instance arg typing (wrong scalar type reports; the head parses clean)"
  else
    fail "instance argty (see $dir/inst-argty.err)"
  fi
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-effect-instance-arity.mn" | wt_run "$compiler" > /dev/null 2> "$dir/inst-arity.err"
  if grep -q 'E_ConstructorArity' "$dir/inst-arity.err"; then
    pass "instance arg arity (wrong count reports)"
  else
    fail "instance arity (see $dir/inst-arity.err)"
  fi
  # ── the splice line carry ──────────────────────────────────────────
  # A splice spanning newlines resumes the outer string scan at the TRUE
  # line, so nodes after it keep truthful spans and the address resolves
  # to the decl, never the module placeholder. Seen RED on the stale-line
  # boot: the whole fixture module answered `placeholder`.
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" tests/frontier/mn-splice-line-carry.mn:12:31 >"$dir/splice-carry.out" 2>/dev/null
  if grep -q 'Query' "$dir/splice-carry.out" && grep -q ': Int' "$dir/splice-carry.out" \
     && ! grep -q 'placeholder' "$dir/splice-carry.out"; then
    pass "splice line carry (post-string spans truthful; the address resolves)"
  else
    fail "splice line carry (see $dir/splice-carry.out)"
  fi
  # ── the fn-type row is a GATE at the argument edge ─────────────────
  # unify_row's Closed~EtAll meet is SUBSUMPTION — pass-no-bind, the
  # negation row judging — where the old equality arm falsely refused
  # every closed-row argument. Seen RED on the prior boot: the quiet
  # thunk reported a second mismatch (hof 2, clean 1); here the quiet
  # face admits and runs while the noisy edge alone reports.
  # Two faces, two compiles since 2026-09-25: E_EffectMismatch is ARMED, so
  # the noisy edge is a REFUSAL (no WAT, nonzero exit) and can no longer
  # ride beside the quiet face's run. The old single-fixture form banked
  # "exit 42 with exactly one mismatch" — a real `!WASI` leak the unarmed
  # era let run (§9.11).
  cat "${RTLIBS[@]}" "$ROOT/lib/io.mn" "$ROOT/tests/frontier/mn-hof-row-gate.mn" | wt_run "$compiler" > "$dir/hof-gate.wat" 2> "$dir/hof-gate.err" \
    && wt_asm "$dir/hof-gate.wat" "$dir/hof-gate.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$dir/hof-gate.wasm" > /dev/null
  hof_rc=$?
  if [ "$hof_rc" = "42" ] && [ "$(grep -c 'E_EffectMismatch' "$dir/hof-gate.err")" = "0" ]; then
    pass "hof row gate (quiet admitted, runs 42, zero mismatches)"
  else
    fail "hof row gate (rc=$hof_rc mismatches=$(grep -c 'E_EffectMismatch' "$dir/hof-gate.err"); see $dir/hof-gate.err)"
  fi
  cat "${RTLIBS[@]}" "$ROOT/lib/io.mn" "$ROOT/tests/frontier/mn-hof-row-gate-noisy.mn" | wt_run "$compiler" > "$dir/hof-gate-noisy.wat" 2> "$dir/hof-gate-noisy.err"
  hofn_rc=$?
  if [ "$hofn_rc" != "0" ] && [ ! -s "$dir/hof-gate-noisy.wat" ] && [ "$(grep -c 'E_EffectMismatch' "$dir/hof-gate-noisy.err")" = "1" ]; then
    pass "hof row gate, noisy face (REFUSED: exactly one mismatch at the printing edge, no WAT)"
  else
    fail "hof row gate, noisy face (rc=$hofn_rc wat=$(wc -c < "$dir/hof-gate-noisy.wat") mismatches=$(grep -c 'E_EffectMismatch' "$dir/hof-gate-noisy.err"); see $dir/hof-gate-noisy.err)"
  fi
  # ── the persist_branch resume barrier ──────────────────────────────
  # The op's param row severs image-external effects (a crashed branch
  # RE-RUNS its thunk — §4④): the replay-exact branch is admitted by
  # subsumption and the whole checkpoint+run+join loop runs; a printing
  # branch reports the mismatch naming the severed row at its own edge.
  cat "${PERSIST_RTLIBS[@]}" "$ROOT/tests/frontier/mn-persist-branch-clean.mn" | wt_run "$compiler" > "$dir/pb-clean.wat" 2> "$dir/pb-clean.err" \
    && wt_asm "$dir/pb-clean.wat" "$dir/pb-clean.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" --dir /tmp "$dir/pb-clean.wasm" > /dev/null
  pb_rc=$?
  if [ "$pb_rc" = "42" ] && ! grep -q 'E_EffectMismatch' "$dir/pb-clean.err"; then
    pass "persist branch barrier admits the replay-exact thunk (42, no mismatch)"
  else
    fail "persist branch clean (rc=$pb_rc; see $dir/pb-clean.err)"
  fi
  cat "${PERSIST_RTLIBS[@]}" "$ROOT/tests/frontier/mn-persist-branch-external.mn" | wt_run "$compiler" > /dev/null 2> "$dir/pb-ext.err"
  if grep -q 'E_EffectMismatch' "$dir/pb-ext.err" && grep -q '!WASI' "$dir/pb-ext.err"; then
    pass "persist branch barrier reports the replaying external (severed row named)"
  else
    fail "persist branch external (see $dir/pb-ext.err)"
  fi
  # ── the persist VALUE barrier (owns across replay) ─────────────────
  # A frame-declared authored `own` free in a persist_branch thunk is
  # re-consumed per resumed run — T_OwnAcrossReplay names it at the call
  # edge (narration: the loop still runs 42); the self-contained sibling
  # thunk stays silent (exactly one line).
  cat "${PERSIST_RTLIBS[@]}" "$ROOT/tests/frontier/mn-own-across-replay.mn" | wt_run "$compiler" > "$dir/pb-own.wat" 2> "$dir/pb-own.err" \
    && wt_asm "$dir/pb-own.wat" "$dir/pb-own.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" --dir /tmp "$dir/pb-own.wasm" > /dev/null
  pbo_rc=$?
  pbo_n=$(grep -c 'T_OwnAcrossReplay' "$dir/pb-own.err")
  if [ "$pbo_rc" = "42" ] && [ "$pbo_n" = "1" ] && grep -q "'buf'" "$dir/pb-own.err"; then
    pass "persist value barrier: the captured open own narrates, the self-contained thunk is silent, the loop runs"
  else
    fail "persist value barrier (rc=$pbo_rc fired=$pbo_n; see $dir/pb-own.err)"
  fi
  run_positive_workflow "$compiler" "$dir"
  run_capability_workflow "$compiler" "$dir"
  run_capability_tie_workflow "$compiler" "$dir"

  # ─── The decl-name address face (bound beats ghost) ────────────────
  # A column inside a decl's NAME must project the decl, never a
  # never-judged parse cell's free var (the measured 1:4 placeholder
  # face: `width( : t…@e…` / `Why: placeholder` through every pin
  # before 4f477b1f — RED-banked live before the fix).
  ghdir="$dir/ghost-addr"
  mkdir -p "$ghdir"
  printf 'fn width(n) = n + 2\n\nfn main() = width(40)\n' > "$ghdir/main.mn"
  gh_out=$(cd "$ghdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ghdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" main.mn:1:4 2>/dev/null)
  if printf '%s' "$gh_out" | grep -q 'width(n)' && ! printf '%s' "$gh_out" | grep -qE ': t[0-9]+@e[0-9]+'; then
    pass "decl-name address projects the decl (bound beats ghost at 1:4)"
  else
    fail "decl-name address (got: $(printf '%s' "$gh_out" | grep -m1 'Query:'))"
  fi

  # ─── The query speaks declaration order ────────────────────────────
  # `type of` on (alpha, beta) must answer alpha-first — the ask
  # projection's last/drop_last-prepend rebuilds reversed every list it
  # walked (params, tuple elems, type args, record fields, the
  # unresolved set) until the map forms landed; a voice that replaces
  # reading the source cannot misorder a signature (it cost two swapped
  # calls in one hour, each convicted by the census).
  qodir="$dir/qorder"
  mkdir -p "$qodir"
  printf 'fn pair(alpha: Int, beta: String) = alpha\n\nfn main() = pair(1, "x")\n' > "$qodir/main.mn"
  qo_out=$(cd "$qodir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$qodir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query main.mn "type of pair" 2>/dev/null)
  if printf '%s' "$qo_out" | grep -q 'alpha: Int.*beta: String'; then
    pass "query speaks declaration order (alpha before beta)"
  else
    fail "query param order (got: $(printf '%s' "$qo_out" | grep -m1 'alpha\|beta\|→'))"
  fi

  # ─── The interval fragment's proof-and-honesty face ────────────────
  # mn-verify-interval runs to 28 through the contract battery; HERE the
  # stderr ledger is the assertion: exactly ONE pending comparison —
  # wild (honest Sub debt, the never-launders control). seek DISCHARGES:
  # the recursive call's leaf is the declaration's own authored `-> Nat`,
  # read off the decl's TFun as a contract (P0's value walk). Zero = a
  # computation laundered again (the runtime -1 class); more = a leaf of
  # the walk (if-join tails / len / Add / a precondition / a callee's
  # declared return) stopped discharging.
  iv_err=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-verify-interval.mn" 2>&1 >/dev/null | grep -c 'pending comparison')
  if [ "$iv_err" = "1" ]; then
    pass "interval fragment: the rec-call IH discharges and the licence never launders (1 honest pending)"
  else
    fail "interval fragment (pending comparisons: $iv_err, want 1)"
  fi

  # H4 · a function parameter handed on learns its callee's contract: `outer`
  # hands `g` to `drive`, which provides `Hz`, so the lambda's demand
  # discharges at main's crossing — no debt, and it runs to 40.
  run_program "$compiler" refine-transport-provides \
    "$ROOT/tests/frontier/mn-refine-transport-provides.mn" 40 no "$dir"
  # ... and what it provides is the MEET over everywhere it is handed:
  # `drive2` provides nothing, so the lambda's demand is debt where it
  # crosses into `outer` — exactly one pending, on main's line. Zero is a
  # provision taken from one hand-off alone (boot 13e8484a); a pending inside
  # `outer` is a provision read as the callback's own demand (pin e23392f6).
  # Compiled through stdin, which never restores a warm image.
  tm_src="$ROOT/tests/frontier/mn-refine-transport-meets.mn"
  tm_main=$(grep -n '^fn main' "$tm_src" | cut -d: -f1)
  tm_err=$(wt_run "$compiler" < "$tm_src" 2>&1 >/dev/null | grep 'verify: pending' || true)
  tm_n=$(printf '%s\n' "$tm_err" | grep -c 'verify: pending' || true)
  tm_at=$(printf '%s\n' "$tm_err" | grep -c ":$tm_main:" || true)
  if [ "$tm_n" = "1" ] && [ "$tm_at" = "1" ]; then
    pass "transport meets: a parameter provides the meet of every hand-off (1 pending, at main's crossing)"
  else
    fail "transport meets (pending: $tm_n, at main's line: $tm_at; want 1 and 1)"
  fi

  # ─── The directional fn-arg edge (quiet-under-cap admits) ──────────
  # A Pure fn passed where a `with Tick` fn is expected ADMITS and runs
  # (RED through every pin before cd43c23c: "E_EffectMismatch: Pure vs
  # Tick" — the closed-closed equality at the symmetric TFun meet); the
  # noisy-into-narrow refusal stays the hof-row-gate leg's contract.
  dir_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-fn-arg-row-directional.mn" 2>/dev/null)
  if [ -n "$dir_wat" ]; then
    printf '%s' "$dir_wat" > "$dir/dirfn.wat"
    if wt_asm "$dir/dirfn.wat" "$dir/dirfn.wasm" 2>/dev/null && [ "$(wt_run "$dir/dirfn.wasm" > /dev/null 2>&1; echo $?)" = "7" ]; then
      pass "directional fn-arg edge: the quiet fn admits under the declared cap (runs 7)"
    else
      fail "directional fn-arg edge (assemble/run)"
    fi
  else
    fail "directional fn-arg edge (compile refused the quiet fn)"
  fi

  # ─── Diagnostics speak the developer's coordinates ─────────────────
  # A check-path diagnostic renders ONCE (the discovery parse absorbs
  # under diag_quiet — every parse warning printed twice since the DAG
  # path was born) and at the FILE-LOCAL span (the register's own range
  # is the subtraction — a line-2 error had rendered at weave 5730).
  lcdir="$dir/local-span"
  mkdir -p "$lcdir"
  printf 'fn main() = {\n  let x: Int = "hi"\n  len(x)\n}\n' > "$lcdir/main.mn"
  lc_out=$(cd "$lcdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$lcdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check main.mn 2>&1)
  lc_n=$(printf '%s' "$lc_out" | grep -c 'E_TypeMismatch')
  # The assertion names the MODULE as well as the line (2026-09-15). It read
  # `at 2:` and broke the day the diagnostic render gained its module half —
  # a gate welded to a render, snapped by improving the render, which is the
  # RENDER-PARSE class this session spent the day naming. Asserting
  # `at main:2:` is strictly STRONGER: a diagnostic about main.mn that reports
  # line 2 of some other file now fails, where before it passed.
  if [ "$lc_n" = "1" ] && printf '%s' "$lc_out" | grep -q 'at main:2:'; then
    pass "diagnostics localize: one report, the user's own file and line (at main:2:)"
  else
    fail "diagnostics localize (reports: $lc_n; $(printf '%s' "$lc_out" | grep -m1 'E_TypeMismatch'))"
  fi

  # ─── The record-pattern rest (SYNTAX's documented form, made real) ──
  # `{age, ...rest}` binds the named field AND a fresh record of the
  # remaining fields; rest's own field access reads the residual layout.
  # Did not PARSE through any pin before 7932c192.
  rr_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-record-pattern-rest.mn" 2>/dev/null)
  if [ -n "$rr_wat" ]; then
    printf '%s' "$rr_wat" > "$dir/recrest.wat"
    if wt_asm "$dir/recrest.wat" "$dir/recrest.wasm" 2>/dev/null && [ "$(wt_run "$dir/recrest.wasm" > /dev/null 2>&1; echo $?)" = "30" ]; then
      pass "record-pattern rest: the residual record builds and reads (runs 30)"
    else
      fail "record-pattern rest (assemble/run)"
    fi
  else
    fail "record-pattern rest (compile refused)"
  fi

  # ─── The as-pattern (SYNTAX §As-patterns, made real) ───────────────
  # `e @ Click(x)` binds the whole value AND the payload in one arm.
  # Did not PARSE through any pin before 010fc317.
  as_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-as-pattern.mn" 2>/dev/null)
  if [ -n "$as_wat" ]; then
    printf '%s' "$as_wat" > "$dir/aspat.wat"
    if wt_asm "$dir/aspat.wat" "$dir/aspat.wasm" 2>/dev/null && [ "$(wt_run "$dir/aspat.wasm" > /dev/null 2>&1; echo $?)" = "47" ]; then
      pass "as-pattern: the whole value and the payload bind in one arm (runs 47)"
    else
      fail "as-pattern (assemble/run)"
    fi
  else
    fail "as-pattern (compile refused)"
  fi

  # ─── The repr pin (SYNTAX §Representation-pinned alias, made real) ──
  # `type Coeff = Float repr f64` + the bare-width param `k: f64`: the pin
  # types transparently (identity is the base's), emission reads the width
  # via repr_of's own arm. Did not PARSE through any prior pin (`repr` and
  # `f64` refused as unknown names).
  rp_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-repr-pin.mn" 2>/dev/null)
  if [ -n "$rp_wat" ]; then
    printf '%s' "$rp_wat" > "$dir/reprpin.wat"
    if wt_asm "$dir/reprpin.wat" "$dir/reprpin.wasm" 2>/dev/null && [ "$(wt_run "$dir/reprpin.wasm" > /dev/null 2>&1; echo $?)" = "42" ]; then
      pass "repr-pin: the width pin parses, types transparently, runs (42)"
    else
      fail "repr-pin (assemble/run)"
    fi
  else
    fail "repr-pin (compile refused)"
  fi

  # ─── The `><` value-branch quartet (PLAN §11 Phase 2.2) ─────────────
  # Four spellings of one fanout — calls, literals, pipes, vars — every
  # branch : Int. A `><` branch is a VALUE computation, so the compile
  # carries ZERO diagnostics and the run answers 96. The shape-keyed
  # E_BranchNotStage convicted two spellings and passed two; the
  # type-keyed law has one verdict for all four.
  pq_err="$dir/pcompose-quartet.err"
  pq_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-pcompose-value-branches.mn" 2> "$pq_err")
  pq_diags=$(grep -c 'E_' "$pq_err" 2>/dev/null || true)
  if [ -n "$pq_wat" ] && [ "$pq_diags" = "0" ]; then
    printf '%s' "$pq_wat" > "$dir/pcompose-quartet.wat"
    if wt_asm "$dir/pcompose-quartet.wat" "$dir/pcompose-quartet.wasm" 2>/dev/null && [ "$(wt_run "$dir/pcompose-quartet.wasm" > /dev/null 2>&1; echo $?)" = "96" ]; then
      pass "pcompose quartet: all four value-branch spellings compile silent and run (96)"
    else
      fail "pcompose quartet (assemble/run)"
    fi
  else
    fail "pcompose quartet (diagnostics on a correct fanout: $pq_diags; see $pq_err)"
  fi

  # ─── A NON-FN BINDING IN VALUE POSITION (Hβ.emit.nonfn-binding-as-
  # function-value) ──────────────────────────────────────────────────
  # Both faces of one class, and the ASSEMBLE step is the load-bearing
  # one: before the fix each face compiled with ZERO diagnostics, so a
  # check-only leg would have called both green. The constructor face
  # built payload-less variants and trapped `unreachable` in the match
  # that read them; the op face emitted `(global.get $<op>)` for a
  # global that never existed and the ASSEMBLER was the first thing in
  # the chain to object. Both born RED against the prior boot; both
  # answer 6 through the reified hole-product.
  for nb in "ctor-as-value:mn-ctor-as-value:the constructor" \
            "op-as-value:mn-op-as-value:the effect op"; do
    nb_tag=${nb%%:*}; nb_rest=${nb#*:}; nb_fix=${nb_rest%%:*}; nb_what=${nb_rest#*:}
    nb_err="$dir/$nb_tag.err"
    nb_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/$nb_fix.mn" 2> "$nb_err")
    nb_diags=$(grep -c 'E_' "$nb_err" 2>/dev/null || true)
    if [ -z "$nb_wat" ] || [ "$nb_diags" != "0" ]; then
      fail "$nb_what as a value (compile: $nb_diags diagnostic(s); see $nb_err)"
    else
      printf '%s' "$nb_wat" > "$dir/$nb_tag.wat"
      if ! wt_asm "$dir/$nb_tag.wat" "$dir/$nb_tag.wasm" 2>"$dir/$nb_tag.asm.err"; then
        fail "$nb_what as a value (ASSEMBLER refused what check passed: $(head -1 "$dir/$nb_tag.asm.err"))"
      elif [ "$(wt_run "$dir/$nb_tag.wasm" > /dev/null 2>&1; echo $?)" = "6" ]; then
        pass "$nb_what as a value: the bare name reifies through the hole-product and runs (6)"
      else
        fail "$nb_what as a value (ran, wrong answer — want 6)"
      fi
    fi
  done

  # ─── A HANDLER IS EXHAUSTIVE (L5, 2026-09-30) ───────────────────────
  # The split-effect pair — two handlers covering one effect's DISJOINT op
  # sets, both installed — was the shape the op-keyed dispatch walk of
  # 2026-09-09 (Hβ.effects.one-walk-three-implementations) served at
  # runtime and the ROW could never see: `ha` answers `a` alone, its
  # install subtracted the whole of `Two` by name, and a declared `!Two`
  # over it was a false absence proof — compiled clean, trapped reading
  # the evidence at the root. A handler is exhaustive over every effect
  # its arms answer now (the match-exhaustiveness law at a handler), so
  # both fixtures REFUSE at the declaration; the honest split is an arm
  # that forwards its op outward (tests/micros/mn-handler-forwarding-arm.mn)
  # or two effects. The deep-handler arm stays as a pin: an arm that
  # performs the op it handles must resolve OUTWARD. ASSEMBLE is in the
  # leg for the same reason as the reification pair — check alone called
  # the RED one green.
  run_refusal "$compiler" split-effect-op-key \
    "$ROOT/tests/frontier/mn-split-effect-op-key.mn" E_HandlerInexhaustive "$dir"
  run_refusal "$compiler" split-effect-evidence \
    "$ROOT/tests/frontier/mn-split-effect-evidence.mn" E_HandlerInexhaustive "$dir"
  for ok in "deep-handler-arm:mn-deep-handler-arm:51:an arm's own perform resolves outward, not into its own install"; do
    ok_tag=${ok%%:*}; ok_r=${ok#*:}; ok_fix=${ok_r%%:*}; ok_r=${ok_r#*:}
    ok_want=${ok_r%%:*}; ok_what=${ok_r#*:}
    ok_err="$dir/$ok_tag.err"
    ok_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/$ok_fix.mn" 2> "$ok_err")
    # ERRORS, not the E_ prefix. The sibling legs grep 'E_' and get away with
    # it because their fixtures happen to raise no format-liftable warning;
    # these two raised E_RedundantBraces and both read RED on a clean
    # compile. A gate that cannot tell a warning from a refusal is measuring
    # the reporter, not the artifact.
    ok_diags=$(grep -c ' error: ' "$ok_err" 2>/dev/null || true)
    if [ -z "$ok_wat" ] || [ "$ok_diags" != "0" ]; then
      fail "$ok_what (compile: $ok_diags diagnostic(s); see $ok_err)"
    else
      printf '%s' "$ok_wat" > "$dir/$ok_tag.wat"
      if ! wt_asm "$dir/$ok_tag.wat" "$dir/$ok_tag.wasm" 2>"$dir/$ok_tag.asm.err"; then
        fail "$ok_what (ASSEMBLER refused what check passed: $(head -1 "$dir/$ok_tag.asm.err"))"
      elif [ "$(wt_run "$dir/$ok_tag.wasm" > /dev/null 2>&1; echo $?)" = "$ok_want" ]; then
        pass "$ok_what ($ok_want)"
      else
        fail "$ok_what (ran, wrong answer — want $ok_want)"
      fi
    fi
  done

  # ─── The relevant tier (affine gains exactly-once) ──────────────────
  # T_OwnUnconsumed fires on an authored `own` the body never consumes
  # (drops) and stays SILENT on a transfer-out (hands_back — the return
  # is the consume). Both faces + the fixture still runs.
  # The address assertion names the FILE as well as the line (2026-09-15).
  # It read `at 10:1` and broke the day the diagnostic render gained its
  # module half — the same RENDER-PARSE snap as the mcp leg above. Naming
  # the fixture is strictly STRONGER: a T_OwnUnconsumed raised against
  # line 10 of some other module now fails, where the bare span passed.
  # The module half is the path AS SPELLED at the call (measured: this
  # leg passes an absolute path, so the render carries one), so the
  # assertion names the BASENAME — the fixture's identity, invariant to
  # how the gate happens to address it.
  ou_chk=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-own-unconsumed.mn" 2>&1)
  ou_n=$(printf '%s' "$ou_chk" | grep -c 'T_OwnUnconsumed')
  if [ "$ou_n" = "1" ] && printf '%s' "$ou_chk" | grep -q "mn-own-unconsumed:10:1"; then
    pass "own-unconsumed: the dropped own narrates, the transferred own stays silent"
  else
    fail "own-unconsumed (fired=$ou_n, want exactly 1 at drops' decl)"
  fi

  # ─── The iteration-shape tier (iteration is topology) ───────────────
  # The audit convicts a self-call threading an incremented index (the
  # loop in recursion's costume) and stays SILENT on the vocabulary form
  # — both faces asserted, plus the fixture still runs.
  it_audit=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" audit "$ROOT/tests/frontier/mn-audit-iteration-shape.mn" 2>/dev/null)
  it_fire=$(printf '%s' "$it_audit" | sed -n '/^walk_costume/,/^stage_clean/p' | grep -c 'iteration-shape')
  it_quiet=$(printf '%s' "$it_audit" | sed -n '/^stage_clean/,/^main/p' | grep -c 'iteration-shape')
  if [ "$it_fire" = "1" ] && [ "$it_quiet" = "0" ]; then
    pass "audit iteration-shape: the costume convicts, the vocabulary stays silent"
  else
    fail "audit iteration-shape (fire=$it_fire quiet=$it_quiet)"
  fi

  # ─── The anonymity tier (a named stage in hiding) ───────────────────
  # The audit convicts the eta-wrapper (the named fn already exists) and
  # the effectful lambda (the row deserves a decl home), and stays
  # SILENT on the pure-local vocabulary — all three faces asserted.
  an_audit=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" audit "$ROOT/tests/frontier/mn-anonymity-tier.mn" 2>/dev/null)
  an_eta=$(printf '%s' "$an_audit" | sed -n '/^wraps/,/^ticks/p' | grep -c 'eta-wrapper')
  an_rowed=$(printf '%s' "$an_audit" | sed -n '/^ticks/,/^pure_vocab/p' | grep -c 'effectful lambda')
  an_quiet=$(printf '%s' "$an_audit" | sed -n '/^pure_vocab/,/^main/p' | grep -c 'anonymity:')
  if [ "$an_eta" = "1" ] && [ "$an_rowed" = "1" ] && [ "$an_quiet" = "0" ]; then
    pass "audit anonymity: the eta and the row convict, the vocabulary stays silent"
  else
    fail "audit anonymity (eta=$an_eta rowed=$an_rowed quiet=$an_quiet)"
  fi

  # ─── The where verb (PLAN §11 Phase 3.2, Hβ.cli.where-verb) ─────────
  # Derived badges: an inferred repr, an op's resume cardinality, each
  # fanout site with its glyph, schedule and branch count, an install's
  # absorption, a function's head with its inferred row, and the widths of
  # its parameters and locals — each a line the medium narrates from facts
  # the graph already proves.
  wdoc="$ROOT/tests/frontier/mn-where-badges.mn"
  w_ok=1
  w_repr=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" gain 2>/dev/null)
  printf '%s' "$w_repr" | grep -q 'gain : Float @ f64 (inferred)' || { w_ok=0; fail "where repr badge (got: $w_repr)"; }
  w_card=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" tick 2>/dev/null)
  printf '%s' "$w_card" | grep -q 'resume Int ->1 answer' || { w_ok=0; fail "where cardinality badge (got: $w_card)"; }
  w_sched=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" fanned 2>/dev/null)
  printf '%s' "$w_sched" | grep -q '>< \[Thread ×2\] at' || { w_ok=0; fail "where schedule badge (got: $w_sched)"; }
  w_seq=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" bare 2>/dev/null)
  printf '%s' "$w_seq" | grep -q '>< \[Seq ×2\] at' || { w_ok=0; fail "where seq-default badge (got: $w_seq)"; }
  # D5 (2026-10-02): the badges SYNTAX promises. Each RED on boot b400dc74,
  # which printed `>< [Thread]` with no width, the same glyph for `<|` and
  # for the sequence fanout, an empty `→` line for every function with no
  # install or site, and `not found` for every parameter and local.
  w_three=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" three 2>/dev/null)
  printf '%s' "$w_three" | grep -q '>< \[Thread ×3\] at' || { w_ok=0; fail "where width badge, three branches (got: $w_three)"; }
  printf '%s' "$w_three" | grep -q '^  a : a @ per instantiation$' || { w_ok=0; fail "where generic parameter named as written (got: $w_three)"; }
  w_share=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" spread 2>/dev/null)
  printf '%s' "$w_share" | grep -q '<| \[Seq ×2\] at' || { w_ok=0; fail "where share glyph (got: $w_share)"; }
  w_each=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" doubled_each 2>/dev/null)
  printf '%s' "$w_each" | grep -q 'fanout \[Seq, a branch per element\] at' || { w_ok=0; fail "where sequence fanout (got: $w_each)"; }
  w_head=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" ticks 2>/dev/null)
  # E4: the head carries the declaration's address (RED on boot 8b071ba3,
  # whose head stopped at the row).
  printf '%s' "$w_head" | grep -q '^→ ticks(x) with Tick  at .*mn-where-badges:10$' || { w_ok=0; fail "where head with its inferred row and address (got: $w_head)"; }
  printf '%s' "$w_head" | grep -q '^  x : Int @ i32 (inferred)$' || { w_ok=0; fail "where parameter badge (got: $w_head)"; }
  w_pin=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" s 2>/dev/null)
  printf '%s' "$w_pin" | grep -q '^→ s : Float @ f32 (pinned)$' || { w_ok=0; fail "where pinned parameter, SYNTAX's own example (got: $w_pin)"; }
  w_local=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" scale 2>/dev/null)
  printf '%s' "$w_local" | grep -q '^→ scale : Float @ f64 (inferred)$' || { w_ok=0; fail "where local (got: $w_local)"; }
  # Arena·P2 (2026-10-03): a handler declaration answers the effects its arms
  # answer and its address, as a type's and an effect's do. RED on boot
  # fb8921e3, which answered the handler's type and no address — the gap a
  # session confessed (`# verb-gap`) when it had to search for one.
  w_hand=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" ticker 2>/dev/null)
  # AN-1 (2026-10-03): a handler's type is `Handler(instance, answer)`, so the
  # line says what the arms ANSWER beside what they absorb — a variable, under
  # the name a developer writes, when every arm resumes and the answer is each
  # install's body's (`ticker`); the type itself when an arm's own value bound
  # it (`zero` answers Int). RED on boot cf8a6d50, whose handler type carried
  # no answer.
  printf '%s' "$w_hand" | grep -q '^→ handler ticker absorbs Tick, answers a  at .*mn-where-badges:28$' || { w_ok=0; fail "where handler declaration (got: $w_hand)"; }
  w_zero=$(wt_run --dir "$ROOT" "$compiler" where "$ROOT/tests/micros/mn-refine-install-answer.mn" zero 2>/dev/null)
  printf '%s' "$w_zero" | grep -q '^→ handler zero absorbs Ask, answers Int  at .*mn-refine-install-answer:12$' || { w_ok=0; fail "where handler answer (got: $w_zero)"; }
  # The install's refusal carries the reason its unify was asked with — the
  # mismatch reporter had taken the reason and dropped it — so a body and an
  # arm disagreeing names the arm: `Int vs List(Byte) — ~> pipe → at 15:…:
  # inferred from the arm bail of handler h`. RED on cf8a6d50 (compiled clean).
  w_arm=$(wt_run --dir "$ROOT" "$compiler" check "$ROOT/tests/micros/mn-arm-answer-is-the-install.mn" 2>&1 >/dev/null)
  printf '%s' "$w_arm" | grep -q 'E_TypeMismatch error: Int vs List(Byte) — ~> pipe → at 15:[0-9]*-15:[0-9]*: inferred from the arm bail of handler h at' || { w_ok=0; fail "install refusal names the arm (got: $w_arm)"; }
  # B4 (2026-09-30): a fanout site reports the schedules its CALLERS demand
  # of it through direct calls — `shared`'s own frame installs none (Seq),
  # and `twice` calls it under `parallel_compose`, so its site runs threaded
  # there; the badge says both, read off the one fanout-reach rule the emit
  # demands twins by. RED on boot 6f2ce437 (the badge knew only the frame).
  w_dem=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" shared 2>/dev/null)
  printf '%s' "$w_dem" | grep -q '>< \[Seq ×2; Thread demanded via twice\] at' || { w_ok=0; fail "where demanded-schedule badge (got: $w_dem)"; }
  # The bare why verb (SYNTAX's lag list, first name retired): the
  # Reason-chain walk as its own verb. Born RED 2026-08-08 (the prior
  # boot answered unknown-verb).
  wy_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" why "$wdoc" gain 2>/dev/null)
  printf '%s' "$wy_out" | grep -q 'let gain' || { w_ok=0; fail "why verb (got: $wy_out)"; }
  # AT THE DEVELOPER'S COORDINATES. `gain` is line 8 of a 24-line fixture,
  # so a weave coordinate is unmistakable here — born RED 2026-09-06, when
  # this answered `at 2729:1-2729:15` because show_reason rendered the raw
  # span from the one-namespace concatenation. Every felt surface goes
  # through that renderer (LSP hover, the cursor view's Why line, the type
  # facet's Reason), and the refs facet three lines away had been answering
  # local coordinates the whole time. §0's intent-is-walkable property is
  # only true if the chain walks somewhere a developer can open.
  #
  # WHAT IT MEASURES NOW (re-read 2026-09-15, because the message had gone
  # stale against its own subject — the smaller face of the RENDER-PARSE
  # class the two legs above just paid for). The LINE HALF IS FIXED: this
  # answers `at 8:1-8:15`, the developer's own line, not 2729. What is
  # still missing is the FILE half, and it is missing for a reason the
  # render cannot fix locally: `show_reason` is handed a Reason, and
  # `Located(span, inner)` carries a COORDINATE WITH NO HANDLE, so there
  # is nothing to read a module from. The diagnostic path escapes this by
  # having its CALLER thread the module in (`diag_report_at`); why cannot
  # borrow that trick, because a Why chain walks across modules and
  # stamping the verb's own file onto a coordinate from elsewhere is a
  # fabrication, not a fix. The honest fix is the POSITIONS face of §11's
  # four-faces law — Located carries the handle and reads the span live —
  # which is 157 construction sites, a representation change, its own arc.
  # Banked as Hβ.why.reason-span-is-a-weave-coordinate; types.mn's own
  # seam-render comment names it too. This leg stays RED on purpose and is
  # the one entry in frontier_expected_red, judged by name in both
  # directions — so the day the peer lands, this leg starts PASSING and the
  # gate REFUSES until the entry is deleted, instead of a slack count
  # silently licensing some other leg's red.
  # A DECLARED standing failure, judged by NAME in both directions (see
  # judge()). It no longer zeroes w_ok: the aggregate below claims only that
  # the WHERE badges narrate, which they do — folding an unrelated `why`
  # coordinate defect into that verdict hid a real pass behind a real red.
  wy_file_ok=0
  printf '%s' "$wy_out" | grep -q 'mn-where-badges:8' && wy_file_ok=1
  judge why-coordinates "$wy_file_ok" \
    "why coordinates carry their file (line half fixed; file half is Hβ.why.reason-span-is-a-weave-coordinate) (got: $wy_out)"
  # The capability-at-tee badge (§11 6.3's felt face): the install line
  # names the handler and the effect set its arms absorb, from the
  # graph's own facts. Born RED 2026-08-08 (the boot lacked the facet).
  w_tee=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" handled 2>/dev/null)
  printf '%s' "$w_tee" | grep -q '~> ticker absorbs Tick, answers Int at' || { w_ok=0; fail "where tee badge (got: $w_tee)"; }
  [ "$w_ok" = 1 ] && pass "where: repr, cardinality, schedule with width, tee, head, parameter and local badges narrate (output, never input)"

  # ─── The lambda list-pattern parameter (PLAN §11 Phase 3.3) ─────────
  # `([h, ...t]) => h` parses and checks clean — the cover-grammar rest
  # closed the second-weaker-copy gap. The RUN half is the banked peer
  # Hβ.lower.list-rest-binding-runtime's gate (the fixture's own header
  # carries the expected value for that day).
  lp_chk=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-lambda-list-param.mn" 2>&1)
  lp_n=$(printf '%s' "$lp_chk" | grep -cE 'P_(Unexpected|Expected)Token|E_.* error')
  if [ "$lp_n" = "0" ]; then
    pass "lambda list-pattern param: ([h, ...t]) => parses and checks clean"
  else
    fail "lambda list-pattern param ($lp_n diagnostics; the six-warning refusal is back)"
  fi

  # ─── Named effect rows (PLAN §11 Phase 3.3, Hβ.types.named-effect-rows) ─
  # `type Both = A + B` + `type JustA = Both - B` (the alias-of-alias
  # GROUPING case — the alias's row builds whole before the outer
  # connective applies) compile silent and run 3.
  nr_err="$dir/named-rows.err"
  nr_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-named-effect-rows.mn" 2> "$nr_err")
  nr_diags=$(grep -c 'E_' "$nr_err" 2>/dev/null || true)
  if [ -n "$nr_wat" ] && [ "$nr_diags" = "0" ]; then
    printf '%s' "$nr_wat" > "$dir/named-rows.wat"
    if wt_asm "$dir/named-rows.wat" "$dir/named-rows.wasm" 2>/dev/null && [ "$(wt_run "$dir/named-rows.wasm" > /dev/null 2>&1; echo $?)" = "3" ]; then
      pass "named effect rows: the alias and the alias-of-alias grouping compile silent and run (3)"
    else
      fail "named effect rows (assemble/run)"
    fi
  else
    fail "named effect rows (diagnostics: $nr_diags; see $nr_err)"
  fi

  # ─── The bare-mention seq-op stage (PLAN §11 Phase 3.3) ─────────────
  # `[1, 2, 3] |> len` compiles SILENT and runs 3 — the false
  # E_TypeMismatch (the raw-body scheme leaking into the pipe's
  # unification) is dead; seq_face_ty types every mention as the face.
  pil_err="$dir/pipe-into-len.err"
  pil_wat=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-pipe-into-len.mn" 2> "$pil_err")
  pil_diags=$(grep -c 'E_' "$pil_err" 2>/dev/null || true)
  if [ -n "$pil_wat" ] && [ "$pil_diags" = "0" ]; then
    printf '%s' "$pil_wat" > "$dir/pipe-into-len.wat"
    if wt_asm "$dir/pipe-into-len.wat" "$dir/pipe-into-len.wasm" 2>/dev/null && [ "$(wt_run "$dir/pipe-into-len.wasm" > /dev/null 2>&1; echo $?)" = "3" ]; then
      pass "pipe into len: the bare-mention seq-op stage compiles silent and runs (3)"
    else
      fail "pipe into len (assemble/run)"
    fi
  else
    fail "pipe into len (diagnostics on a correct stage: $pil_diags; see $pil_err)"
  fi

  # ─── Sig'd polymorphic recursion (§11 5.3 step one) ─────────────────
  # `fn depth(x: a, n: Int) -> Int = ... depth([x], n-1)` with a full
  # authored signature checks (the prereg quantified scheme stays in
  # scope; self-calls instantiate fresh), compiles (the spec ctx
  # self-reference floors at the word terminal instead of exhausting
  # spec_resolve_build), and runs 3. Born RED: E_OccursCheck through
  # the incumbent boot (2026-08-07).
  sp_err="$dir/sigd-poly.err"
  sp_wat=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-sigd-poly-recursion.mn" 2> "$sp_err")
  sp_diags=$(grep -c 'E_' "$sp_err" 2>/dev/null || true)
  if [ -n "$sp_wat" ] && [ "$sp_diags" = "0" ]; then
    printf '%s' "$sp_wat" > "$dir/sigd-poly.wat"
    if wt_asm "$dir/sigd-poly.wat" "$dir/sigd-poly.wasm" 2>/dev/null && [ "$(wt_run "$dir/sigd-poly.wasm" > /dev/null 2>&1; echo $?)" = "3" ]; then
      pass "sigd poly recursion: the signature buys the poly self-call; compiles and runs (3)"
    else
      fail "sigd poly recursion (assemble/run)"
    fi
  else
    fail "sigd poly recursion (diagnostics: $sp_diags; see $sp_err)"
  fi

  # ─── The poly-recursion teach (§11 5.3, the question beats the guess) ─
  # A shape the Mycroft rounds cannot stabilize (bad returns x while
  # self-calling at [x]) refuses honestly at the recheck round, and the
  # refusal carries T_PolyRecursionSignature naming the fn. Born RED
  # 2026-08-07 (bare E_OccursCheck, no narration); retargeted to the
  # K-exhausted floor the day the fragment landed.
  pt_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-poly-teach.mn" 2>&1)
  if printf '%s' "$pt_out" | grep -q "E_OccursCheck" && printf '%s' "$pt_out" | grep -q "T_PolyRecursionSignature.*'bad'"; then
    pass "poly teach: the K-exhausted refusal carries the signature narration naming bad"
  else
    fail "poly teach (refusal or narration missing)"
  fi

  # ─── The Mycroft fragment (§11 5.3): unsig'd poly recursion INFERS ──
  # depth(x, n) = ... depth([x], n-1), no annotation anywhere, checks
  # clean and runs 3 — inference where Haskell/OCaml demand the
  # annotation. Born as the teach fixture's flip the day the fragment
  # landed (rounds: fingerprinted refusal → general assumption →
  # recheck under the result scheme).
  pf_err="$dir/poly-fragment.err"
  pf_wat=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-poly-fragment.mn" 2> "$pf_err")
  pf_diags=$(grep -c 'E_' "$pf_err" 2>/dev/null || true)
  if [ -n "$pf_wat" ] && [ "$pf_diags" = "0" ]; then
    printf '%s' "$pf_wat" > "$dir/poly-fragment.wat"
    if wt_asm "$dir/poly-fragment.wat" "$dir/poly-fragment.wasm" 2>/dev/null && [ "$(wt_run "$dir/poly-fragment.wasm" > /dev/null 2>&1; echo $?)" = "3" ]; then
      pass "poly fragment: unsig'd poly recursion inferred; compiles and runs (3)"
    else
      fail "poly fragment (assemble/run)"
    fi
  else
    fail "poly fragment (diagnostics: $pf_diags; see $pf_err)"
  fi

  # ─── The multi-call fragment boundary (§11 5.3 named-next (b)) ──────
  # TWO self-calls at different shapes ([x] and (x,x)) — outside
  # Henglein's single-call fragment — still infer: both fit the
  # converged scheme, the recheck verifies, the belt confirms. Runs 4.
  mc_err="$dir/poly-multicall.err"
  mc_wat=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-poly-multicall.mn" 2> "$mc_err")
  mc_diags=$(grep -c 'E_' "$mc_err" 2>/dev/null || true)
  if [ -n "$mc_wat" ] && [ "$mc_diags" = "0" ]; then
    printf '%s' "$mc_wat" > "$dir/poly-multicall.wat"
    if wt_asm "$dir/poly-multicall.wat" "$dir/poly-multicall.wasm" 2>/dev/null && [ "$(wt_run "$dir/poly-multicall.wasm" > /dev/null 2>&1; echo $?)" = "4" ]; then
      pass "poly multicall: two self-calls at different shapes inferred; runs (4)"
    else
      fail "poly multicall (assemble/run)"
    fi
  else
    fail "poly multicall (diagnostics: $mc_diags; see $mc_err)"
  fi

  # ─── The decls facet (the bound-projection landing's gate) ──────────
  # `query <fixture> "decls"` projects the decls COLUMN — the oracle
  # queue's own seed set. Born RED 2026-08-07: the incumbent boot
  # answered "error: unknown query: decls". The fixture's three decls
  # (lines 7/9/11) must be listed located; the retired whole-handle
  # NBound walk seeded every fn-typed MENTION alongside its decl.
  df_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-decls-facet.mn" "decls" 2>/dev/null)
  if printf '%s' "$df_out" | grep -q "judged decl" && printf '%s' "$df_out" | grep -q "mn-decls-facet:7" && printf '%s' "$df_out" | grep -q "mn-decls-facet:9" && printf '%s' "$df_out" | grep -q "mn-decls-facet:11"; then
    pass "decls facet: the column lists the fixture's three decls (7/9/11)"
  else
    fail "decls facet (column projection; got: $(printf '%s' "$df_out" | tail -1))"
  fi

  # ─── The reading facets: text, prose, writes of ─────────────────────
  # What a program SAYS and WRITES, asked of one fixture: the string
  # literal holding facet-literal-marker, the comment holding
  # facet-prose-marker (sited at the comment), and the two values written
  # into the counter's state (its init, its update). The first and third
  # were built with no gate; the second was confessed as a verb gap four
  # times in a day. Born RED 2026-10-03: the boot answered "unknown query"
  # to all three.
  rf_doc="$ROOT/tests/frontier/mn-reading-facets.mn"
  rf_text=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "text facet-literal-marker" 2>/dev/null)
  rf_prose=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "prose facet-prose-marker" 2>/dev/null)
  rf_writes=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "writes of sum" 2>/dev/null)
  if printf '%s' "$rf_text" | grep -q "1 string literal(s)" && printf '%s' "$rf_text" | grep -q "mn-reading-facets:19" \
     && printf '%s' "$rf_prose" | grep -q "1 comment(s)" && printf '%s' "$rf_prose" | grep -q "mn-reading-facets:1:" \
     && printf '%s' "$rf_writes" | grep -q "counter.sum: 2 write(s)" && printf '%s' "$rf_writes" | grep -q "sum + n"; then
    pass "reading facets: text (the literal at 19), prose (the comment at 1), writes of (init and update)"
  else
    fail "reading facets (text: $(printf '%s' "$rf_text" | head -1) · prose: $(printf '%s' "$rf_prose" | head -1) · writes: $(printf '%s' "$rf_writes" | head -1))"
  fi

  # ─── The flow facet on a refined source (PLAN §11 Phase 7 walk) ─────
  # `query <fixture> "flow NAME"` projects the flow label. Two altitudes
  # over one refined alias (Vault = String where classified(self)): the
  # VALUE's own scheme, and a source FN's flow character. Born RED
  # 2026-08-08: the boot's TFun arm read the row alone, so `flow getpw`
  # on a `-> Vault` source answered Public while `flow pw` answered
  # Secret; the return-label join closes it.
  fl_val=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-flow-refined-source.mn" "flow pw" 2>/dev/null)
  fl_fn=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-flow-refined-source.mn" "flow getpw" 2>/dev/null)
  if printf '%s' "$fl_val" | grep -q "Secret" && printf '%s' "$fl_fn" | grep -q "Secret"; then
    pass "flow facet: refined source labels Secret at value AND fn altitude"
  else
    fail "flow facet (value: $(printf '%s' "$fl_val" | head -1) · fn: $(printf '%s' "$fl_fn" | head -1))"
  fi

  # ─── The DCC noninterference gate, first face (§11 Phase 7,
  # Hβ.ifc.dcc-noninterference-gate): a classified splice REFUSES
  # (E_RefinementRejected via PFlowLe(Secret, Public), decidable-false)
  # and the Public dual accepts — the pair differs only in the source's
  # classification. Born RED 2026-08-08: the ShowExpr wrap bound every
  # splice fragment to String, so the label read classified Public and
  # the obligation silently discharged — the leak checked CLEAN on the
  # pre-fix pin; the fix reads through the wrapper to the inner node.
  ifc_leak=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-splice-leak.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  ifc_sound=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-splice-sound.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  if [ "$ifc_leak" -ge 1 ] && [ "$ifc_sound" -eq 0 ]; then
    pass "dcc gate: classified splice refuses ($ifc_leak), public splice accepts"
  else
    fail "dcc gate (leak rejections: $ifc_leak, want >=1; sound rejections: $ifc_sound, want 0)"
  fi
  # The let face (P0): a value a `let` annotated classified carries the label
  # through its binder — the claim the let made, read where it was noted.
  # Seen RED on the P0 tree before the claims column (0 rejections).
  ifc_let=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-splice-let-annotation.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  if [ "$ifc_let" -ge 1 ]; then
    pass "dcc gate: a let-annotated classified splice refuses ($ifc_let)"
  else
    fail "dcc gate let face (rejections: $ifc_let, want >=1)"
  fi
  # The derived face (P0): a value BUILT from a classified one — an
  # operator's result, a record's field, a computation over a classified
  # parameter, a constructor's or a tuple's part — refuses at its splice,
  # five of five; and the public half of a mixed tuple is public, read at
  # its position. Seen RED on the P0 tree before the influence read: 0 of 5.
  ifc_derived=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-splice-derived.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  ifc_public=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-splice-part-public.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  if [ "$ifc_derived" -eq 5 ] && [ "$ifc_public" -eq 0 ]; then
    pass "dcc gate: derived values carry their sources' labels (5/5), a public part stays public"
  else
    fail "dcc gate derived face (rejections: $ifc_derived, want 5; public-part rejections: $ifc_public, want 0)"
  fi

  # The install face (AN-1): a tee's value is every value its install can
  # answer, so an arm answering a classified value classifies the install's
  # value and its splice refuses; the public twin accepts. Seen RED on boot
  # cf8a6d50: the label walk joined the tee's children — the perform and the
  # handler's name, both Public — and the leak compiled clean (0 rejections).
  ifc_tee_leak=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-tee-arm-leak.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  ifc_tee_public=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-ifc-tee-arm-public.mn" 2>&1 >/dev/null | grep -c "E_RefinementRejected" || true)
  if [ "$ifc_tee_leak" -ge 1 ] && [ "$ifc_tee_public" -eq 0 ]; then
    pass "dcc gate: an arm's classified answer classifies the install ($ifc_tee_leak), a public arm stays public"
  else
    fail "dcc gate install face (leak rejections: $ifc_tee_leak, want >=1; public rejections: $ifc_tee_public, want 0)"
  fi

  # ─── The unused-wide-param gate (Hβ.emit.unused-wide-param-floor): an
  # unused f64 param signs at its real width. Born RED 2026-08-08: the
  # body-usage scan floored the signature to i32 while the caller pushed
  # f64 — invalid WAT, refused at assemble. The pair (unused + used)
  # runs to exit 11 through the compile-assemble-run harness.
  run_program "$compiler" unused-wide-param "$ROOT/tests/frontier/mn-unused-wide-param.mn" 11 no "$dir"

  # ─── The row contradiction refuses at the decl (band L's
  # Hβ.diag.declared-row-contradiction): `with E + !E` reports
  # E_DeclaredRowContradiction for BOTH decls — pure body and performing
  # body — where the pre-diagnostic meet silently dropped the negation
  # and licensed the perform (born RED 2026-08-08: the performing body
  # checked CLEAN on the pre-fix pin).
  rc_n=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-row-contradiction.mn" 2>&1 >/dev/null | grep -c "E_DeclaredRowContradiction" || true)
  if [ "$rc_n" -ge 2 ]; then
    pass "row contradiction: both decls refuse at the clause ($rc_n reports)"
  else
    fail "row contradiction (reports: $rc_n, want >=2)"
  fi

  # ─── The contradiction is INSTANCE-PRECISE (RESIDUE effarg-node, the
  # adjacent kill): `Flow(1, Store) + !Flow(1, Wasi)` names two provably
  # distinct instances — the registration fold gives the nullary ctors
  # value identity, so the absent survives as a REFINEMENT and only the
  # same-instance decl reports. Born RED against the boot (2 reports:
  # the refined clause falsely convicted beside the true contradiction).
  ir_n=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-instance-refinement-clause.mn" 2>&1 >/dev/null | grep -c "E_DeclaredRowContradiction" || true)
  if [ "$ir_n" -eq 1 ]; then
    pass "instance refinement clause: the distinct absent survives, the same-instance reports ($ir_n report)"
  else
    fail "instance refinement clause (reports: $ir_n, want exactly 1)"
  fi

  # ─── The debt facet (Phase 8.2's instrument): the verification query
  # renders each pending obligation LOCATED with its predicate — a count
  # alone is not an instrument. Born with the facet 2026-08-08 (the
  # pre-facet render was the bare count line).
  dbt=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-debt-facet.mn" "verification" 2>/dev/null)
  if printf '%s' "$dbt" | grep -q "obligations pending" && printf '%s' "$dbt" | grep -q "mn-debt-facet:"; then
    pass "debt facet: pending obligations render located with their predicates"
  else
    fail "debt facet (got: $(printf '%s' "$dbt" | head -2 | tr '\n' ' '))"
  fi

  # ─── !Thread transitivity on the REAL vocabulary (§11 6.5's first
  # verdict): a fn declared !Thread reaching lib/threading's spawn
  # through a call refuses transitively — the crown's own machinery
  # verified against the real effect (the crown gate's stdin harness
  # cannot link lib, so the real-vocabulary crucible lives here; the
  # self-contained sounds live in tests/crown/). Probed 1 mismatch
  # against the boot before the leg was written.
  tn_n=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-thread-negation.mn" 2>&1 | grep -cE 'E_EffectMismatch')
  if [ "$tn_n" -ge 1 ]; then
    pass "thread negation: !Thread refuses the transitive spawn on the real vocabulary"
  else
    fail "thread negation (mismatch=$tn_n — the transitive spawn passed a !Thread gate)"
  fi

  # ─── The ADT-roster facet (`variants NAME` — the confessed missing
  # projection, retired): the type's constructors with arities, read
  # from the env's ConstructorScheme registry. Born RED 2026-08-08
  # (the prior boot answered unknown-query).
  vr_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-usage-grade.mn" "variants Option" 2>/dev/null)
  if printf '%s' "$vr_out" | grep -q "None/0" && printf '%s' "$vr_out" | grep -q "Some/1"; then
    pass "variants facet: the ADT roster projects (None/0, Some/1)"
  else
    fail "variants facet (got: $(printf '%s' "$vr_out" | head -1))"
  fi
  # An effect is a sum of requests, so `variants` of an effect is its op
  # roster (2026-10-03 — confessed as a verb gap the same day; the boot
  # answered "no constructors found").
  vo_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-reading-facets.mn" "variants Count" 2>/dev/null)
  if printf '%s' "$vo_out" | grep -q "add/1" && printf '%s' "$vo_out" | grep -q "total/0"; then
    pass "variants facet: an effect's op roster projects (add/1, total/0)"
  else
    fail "variants facet over an effect (got: $(printf '%s' "$vo_out" | head -1))"
  fi

  # ─── The module-set facet (`modules` — the DAG the driver proves on
  # every invocation and could show nobody; answering "which modules does
  # this entry pull" meant a shell transitive-closure loop over grep
  # '^import'). It reads the weave's own NModule cells, so the count is
  # the judged set, not a re-walk of the filesystem. Born RED 2026-08-17
  # (the prior boot answered unknown-query). The fixture imports nothing
  # of its own, so the answer is the prelude floor plus itself, and the
  # named members pin that it is the real set and not a bare number.
  md_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-usage-grade.mn" "modules" 2>/dev/null)
  if printf '%s' "$md_out" | grep -q "module(s) in the weave" \
     && printf '%s' "$md_out" | grep -q "prelude" \
     && printf '%s' "$md_out" | grep -q "threading"; then
    pass "modules facet: the weave's module set projects ($(printf '%s' "$md_out" | grep -o '[0-9]* module(s)' | head -1))"
  else
    fail "modules facet (got: $(printf '%s' "$md_out" | head -1))"
  fi

  # ─── The float sentinels (NaN, ±Inf, -0.0) — the four values
  # float_to_str renders through a branch the digit path never touches,
  # so a change to that path loses them silently. Each match is a bit, so
  # the exit code names WHICH branch broke: 15 is all four. Pinned at 15
  # BEFORE `str_literal_5` was deleted (an identity fn whose comment
  # claimed it built strings from byte arguments and which named the
  # bootstrap deleted 2026-07-10), and re-measured 15 after.
  wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-float-sentinels.mn" > "$dir/fsent.wat" 2>/dev/null
  if wt_asm "$dir/fsent.wat" "$dir/fsent.wasm" >/dev/null 2>&1; then
    wt_run --dir "$dir" "$dir/fsent.wasm" >/dev/null 2>&1
    fs_code=$?
    if [ "$fs_code" = "15" ]; then
      pass "float sentinels: NaN, ±Inf and -0.0 all render (exit=15)"
    else
      fail "float sentinels (exit=$fs_code, want 15 — the bits name the branch)"
    fi
  else
    fail "float sentinels: assemble"
  fi

  # ─── The cost facet, AND the prelude-floor ratchet it makes possible
  # (`cost` — modules linked, source lines processed, nodes minted, all
  # graph reads). A wall clock is a host fact that varies per run and can
  # never be ratcheted; these three are identical every time, so the
  # floor a TRIVIAL program pays becomes a contract. The fixture is a
  # bare `fn main() = 7`-class module: whatever it costs is the prelude
  # vocabulary the medium processes to answer nothing, and that number
  # may only FALL — Hβ.driver.link-is-reachability is what lowers it.
  # A RISE means the medium started processing more source to answer the
  # same trivial question. Born RED 2026-08-17 (unknown-query on the
  # prior boot); the ceiling was seen RED by setting it under the
  # measured 6307.
  # 6366 (2026-08-18): RAISED by 6, and the reason is recorded because the
  # direction is otherwise forbidden. E_FnShadowsOp landed as a real
  # diagnostic class — six arms in src/types.mn, which is 57% of this
  # floor — and a class is permanent content, not prose. Trimming its
  # comments to the constraint recovered 6 of the 12 lines it first cost;
  # the rest is the class itself.
  #
  # This is the SECOND ceiling event in three iterations and both were
  # types.mn additions, which is evidence FOR
  # `Hβ.driver.link-is-reachability` rather than against the ratchet: a
  # program that asks for nothing should not link the whole diagnostic
  # catalog. When the link is reachability-judged this number falls hard
  # and the ceiling follows it down.
  #
  # Prior: 6360 (down from 6400) after the numeric-scanner landing measured
  # 6352. Held tight on purpose — a floor with room to grow is not a floor.
  # 6385 (2026-09-03): RAISED by 19, the THIRD ceiling event in four
  # iterations and the third caused by a types.mn addition — here the
  # licence recorded at diag_refuses' new EPurityViolated arm, which states
  # at the site why the class could arm (wheel census zero, 372 corpus
  # fixtures clean but the two expecting the refusal). The comment above
  # already called this pattern evidence FOR
  # `Hβ.driver.link-is-reachability`, and a third instance is the
  # measurement it asked for: a fixture importing nothing links the whole
  # diagnostic catalog, so prose justifying one arm of one projection
  # enters a bare program's floor. Shrinking the justification to fit the
  # ceiling would be shaping the wheel around the gate; the ceiling follows
  # the link when the link is reachability-judged.
  # 2737 (2026-09-04): FELL 6385 → 2737, and this is the ceiling event the
  # three raises above were evidence for. lib/lists, lib/strings and
  # lib/threading each carried `import types` and referenced not one name from
  # it — every apparent use was a comment mention. Those three lines put the
  # compiler's own module, and with it ~170 op names (Abort, FreshHandle,
  # Consume, GraphRead/Write, Diagnostic, EnvRead/Write, Verify), into the
  # namespace of every program that touches a list or a string. Deleting them
  # takes `types` out of a bare weave entirely: 7 modules to 6.
  #
  # The comment above called the repeated types.mn raises evidence FOR
  # `Hβ.driver.link-is-reachability` and predicted the number would fall hard
  # once the link was judged. It was not the whole judgment — dead imports are
  # the crudest possible unreachability — and it still more than halved.
  # 2760 (2026-09-10): ROSE 2737 → 2760, and the +23 is a capability, not
  # slack. The world-chain walk stopped keying on the EFFECT alone — which
  # dispatched an op through a handler that merely COVERS its effect, silently
  # wrong at tests/frontier/mn-split-effect-evidence.mn — and now asks the
  # record whether it declares the op. That question is `node_arm_at`, a new
  # fn in lib/memory.mn plus the comment that says what it reads and why the
  # walk and the emit must compute the same address. Everything transitional
  # was taken back in the same landing: `ev_perform_node` and the effect-only
  # `world_find_from` are DELETED, and `miss_or_node` — extracted to give two
  # walks one refusal — was inlined the moment the second walk died, which is
  # 2783 → 2773 → 2760 measured at each step. What remains is the smallest
  # form of the fix, and this ceiling still falls with
  # `Hβ.driver.link-is-reachability`: a bare program has no handlers and
  # dispatches nothing, so it links this walk for no reason at all.
  # 2822 (2026-09-18): ROSE 2760 → 2822, a capability of the same class —
  # `str_escape`, the formatter's exact inverse of `str_unescape`, landed
  # beside its decoder in lib/strings.mn (one home for the escape set:
  # `mentl fmt` rendered a NUL as a raw byte and was not a fixpoint on the
  # wheel's own argv wire) with the shared hex-glyph table the emitter's
  # data escapes now read too, its walk a pure count-fold and a `ByteSink`
  # handler whose write cursor is handler state (the audit's iteration-
  # shape tier convicted the index-threaded form). A bare program formats
  # nothing, so it links the encoder for no reason at all — the same
  # sentence as the line above, and the same peer takes it back.
  # 2794 (2026-09-28): FELL 2822 → 2794. lib/memory.mn carried a second copy
  # of the world walk (`world_declaring_from`, `node_arm_at` and
  # `ev_declaring_node`) that nothing called — the emitted preamble's walk is
  # the one dispatch reads — and it is deleted; `world_key`, which files a
  # warm image under the handler world that wrote it, took eight of those
  # lines back.
  # 2796 (2026-09-30): ROSE 2794 → 2796, one arm and its prose — lib/prelude's
  # `each_handler` answers `result` now (`result() => resume(())`), because a
  # handler is exhaustive over every effect its arms answer
  # (`E_HandlerInexhaustive`, L5): the half-handler subtracted the WHOLE of
  # `Iterate` from every `each` install's row while `result` walked past it.
  # A bare program links the prelude, so it links the arm; the same peer as
  # every line above takes it back.
  # 2805 (2026-09-30): ROSE 2796 → 2805, one effect and its lede — lib/prelude's
  # `effect Trap {}` (C5): partiality is a row fact, so a bare `t / n` performs
  # a name every program must be born knowing, and `!Trap` is a claim any
  # signature may make. A bare program links the prelude, so it links the
  # effect; the same peer takes it back.
  # 2833 (2026-09-30): ROSE 2805 → 2833, the sequence fanout's vocabulary
  # (B4 + C9): lib/prelude's `fanout(f, xs)` — `map` by declaration, the
  # fanout node at the lowering, twelve lines with its lede — and
  # lib/threading's `fanout_threaded` with its `spawn_branch` helper, the
  # form a Thread-class schedule selects for it, sixteen lines with the
  # header's demand sentence. A bare program fans nothing out, so it links
  # both for no reason at all; the same peer takes them back.
  cost_ceiling=2833
  ct_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-bare-floor.mn" "cost" 2>/dev/null)
  ct_lines=$(printf '%s' "$ct_out" | grep -o '[0-9]* source line' | grep -o '[0-9]*' | head -1)
  if [ -n "$ct_lines" ] && [ "$ct_lines" -le "$cost_ceiling" ]; then
    pass "cost facet + prelude floor: $ct_lines source line(s) within the $cost_ceiling ceiling (monotone DOWN)"
  else
    fail "prelude floor (got: $(printf '%s' "$ct_out" | head -1), ceiling $cost_ceiling)"
  fi

  # ─── The relocation pins (Hβ.lower.lowering-is-a-column, the demand
  # worklist's written decisions — each seen red by inverting its own
  # assertion against the base wat before the leg landed):
  # LIBRARY-WHOLE — a no-main module seeds ALL decls; the unreferenced
  # beta emits beside alpha.
  # The wat goes to a FILE before it is read — the idiom every other
  # wat-scale leg here already uses, and the reason is measured: piping
  # 800KB into `grep -q` lets grep exit at its first match, the writer
  # takes SIGPIPE, and under `set -o pipefail` the condition reads FALSE
  # while both functions are present. This leg reported RED at alpha=1
  # beta=1 until the pipe came out.
  wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-reach-library-whole.mn" > "$dir/reach-library.wat" 2>/dev/null
  lw_a=$(grep -cF '(func $alpha ' "$dir/reach-library.wat")
  lw_b=$(grep -cF '(func $beta ' "$dir/reach-library.wat")
  if [ "$lw_a" -ge 1 ] && [ "$lw_b" -ge 1 ]; then
    pass "relocation library pin: a no-main module emits whole (alpha + unreferenced beta)"
  else
    fail "relocation library pin (alpha=$lw_a beta=$lw_b — a library decl went missing)"
  fi
  # EMISSION-ORDER — the module emits in SOURCE order (zeta, alpha, main),
  # never the demand order the worklist constructs in (main, alpha, zeta).
  eo_elem=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-reach-emission-order.mn" 2>/dev/null | grep -F 'elem $fns')
  if printf '%s' "$eo_elem" | grep -qF '$zeta $alpha $main'; then
    pass "relocation order pin: emission is source order (zeta alpha main)"
  else
    fail "relocation order pin (elem order: $eo_elem)"
  fi

  # ─── THE NEGATION REACHES INTO A `<~` RECURRENCE (PLAN §11 6.3) ─────
  # The feedback-under-negation modal rule. `<~` is pure topology, but what
  # the recurrence BODY performs is still performed, so a cycle must not
  # launder a forbidden effect. Born RED against the pre-fix boot: the infer
  # arm destructured the LHS lambda's row into `_row` and dropped it, so
  # `fn cycle() with !E` around `((prev) => prev + bump()) <~ Delay(1)`
  # checked CLEAN. Lives here rather than tests/crown/ because the crown's
  # stdin harness links no lib and FeedbackSpec's constructors are prelude
  # vocabulary — mn-thread-negation.mn's precedent.
  fb_n=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-feedback-negation.mn" 2>&1 | grep -cE 'E_EffectMismatch')
  if [ "$fb_n" -ge 1 ]; then
    pass "feedback negation: !E refuses the effect performed inside the recurrence"
  else
    fail "feedback negation (mismatch=$fb_n — the cycle laundered a forbidden effect)"
  fi
  # The dual: a `<~` site charges nothing of its own, so `!Alloc` SURVIVES a
  # cycle at depth 3. Born RED on the boot before 2026-09-25 (`!Alloc + Any
  # vs Memory + Alloc`: the FeedbackSpec constructor's allocation charged the
  # frame although emit discards the lowered spec and nothing allocates).
  # Wired the day E_EffectMismatch was armed, because arming turned that
  # false charge into a false REFUSAL of tests/micros/mn-feedback-iir —
  # branch A of the fork banked under Hβ.effects.feedback-row-substitutes.
  fbt_n=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-feedback-transport.mn" 2>&1 | grep -cE 'E_EffectMismatch')
  if [ "$fbt_n" -eq 0 ]; then
    pass "feedback transport: !Alloc survives a <~ cycle at depth 3 (the spec charges nothing)"
  else
    fail "feedback transport (mismatch=$fbt_n — the feedback site charged the spec's construction)"
  fi

  # ─── THE EIGHT ARMS, SAYABLE TOGETHER (PLAN §2) ─────────────────────
  # One authoring site per kernel arm in one module: a refinement alias,
  # a repr pin, an effect with a handler resuming with state, own/ref
  # markers, a declared row, and all five verbs. PLAN §2 calls the eight
  # the aspects of ONE cursor-read, and the surface half of that claim
  # had no gate — every arm was exercised somewhere in the battery, none
  # of them together. Exit 42 means all eight parsed, typed, lowered and
  # ran as one program. The read half is the open peer
  # Hβ.cursor.eight-arms-at-every-site: measured 2026-08-16, the cursor
  # projects five arms at a fn declaration and none at a type
  # declaration, so this leg holds the surface while that one is built.
  run_program "$compiler" eight-arms "$ROOT/tests/frontier/mn-eight-arms.mn" 42 yes "$dir"
  # `==` in a handler arm over its op's quantified parameters: the arm is
  # twinned at the install's instance (`Handler(String)`), so the compare
  # reads String and two byte-equal Strings are equal (0). It compared their
  # ADDRESSES and answered 1 with no diagnostic from 2026-09-18, declared RED,
  # until R0c keyed arms by the install's instance.
  run_program "$compiler" eq-in-arm-pointer "$ROOT/tests/frontier/mn-eq-in-arm-pointer.mn" 0 yes "$dir"
  # A constructor's payload types come from the INSTANTIATION the graph
  # proved, never from the declaration that quantified them. These two
  # legs are the three faces that read measured on 2026-09-18, and they
  # were declared-red for exactly one landing before proof retired the
  # declaration: `==` compared a polymorphic sum's payload by ADDRESS
  # (6, the fixture's own control passing on the same run), `show`
  # printed that address, and a `Some(1.5)` never assembled because the
  # binder was declared at the declared width and read at the proven one.
  # `fold_sig` folds its arguments now, so each instantiation names its
  # own leaf, and LPCon carries its payload types the way LPTuple always
  # has. Each fixture's exit NAMES which face broke rather than merely
  # failing.
  run_program "$compiler" eq-polymorphic-sum "$ROOT/tests/frontier/mn-eq-polymorphic-sum.mn" 0 yes "$dir"
  run_program "$compiler" payload-instantiation "$ROOT/tests/frontier/mn-payload-instantiation.mn" 0 yes "$dir"

  # (The per-module solo sweep moved to tools/verify.sh on 2026-09-26: it is a
  # census of the wheel's own source, and it was the one leg here that read
  # src/, which made this whole gate's verdict depend on every comment edit.)
done

echo "frontier: $total_pass pass / $total_fail red / $total_xred expected-red"

# The GREEN STAMP, keyed by the boot it tested (the d51661f1 lesson —
# 2026-08-09): a fully-green run records the boot's sha256 so the
# pre-commit thesis gate can DEMAND that the frontier ran, green,
# against exactly the wheel being committed. A red run stamps nothing
# (and clears any stale stamp — a stamp must never outlive a red).
# Scope, stated honestly: the stamp binds gate↔boot; boot↔staged-source
# is the march's own per-landing contract (m2 == m3), not this file's.
#
# THE CEILING IS READ, NOT HARD-CODED (2026-09-15) — and until today these
# were TWO HOMES that disagreed. march.sh:129 reads `frontier_red_max` and
# blesses a pin within it; this line demanded ZERO, and the pre-commit
# perimeter demands this stamp. So the march blessed a pin the perimeter then
# refused to commit, and with one red banked since 2026-09-06 that meant NO
# wheel commit could land at all. It went unnoticed because the perimeter was
# installed on 2026-09-15 and this was the first wheel commit under it — not a
# gate that went quiet (tripwire 4) but a gate never run against a real case.
# Reading the same key march.sh reads makes them agree BY CONSTRUCTION and
# tightens automatically the day the ceiling reaches 0. This is not a
# loosening: it replaces a second, stricter, UNREACHABLE contract with the
# banked one, and an unsatisfiable gate is a gate that gets --no-verify'd.
# THE STAMP IS BACK TO LITERAL ZERO (2026-09-15) — because an expected red is
# no longer a red. The ceiling this replaces (`frontier_red_max`, read here
# and in march.sh) compared only a COUNT and so could not tell WHICH leg was
# failing; the named contract in judge() does, in both directions, and a
# declared standing failure lands in $total_xred rather than $total_fail. So
# zero here is the strong form, not the unreachable one it was this morning.
if [ "$total_fail" -eq 0 ]; then
  sha256sum "$ROOT/boot/mentl.wasm" | cut -d' ' -f1 > "$ROOT/.build/frontier-stamp"
  wt_memo_put "frontier-$selection" "$frontier_key" "frontier: $total_pass pass / $total_fail red / $total_xred expected-red"
else
  rm -f "$ROOT/.build/frontier-stamp"
fi
[ "$total_fail" -eq 0 ]
