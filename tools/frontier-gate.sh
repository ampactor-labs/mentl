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
if frontier_memo=$(wt_memo_hit frontier "$frontier_key"); then
  printf '%s\n' "$frontier_memo"
  echo "  (memo: these compilers already ran every leg against these inputs green — FORCE_GATES=1 re-runs)"
  sha256sum "$ROOT/boot/mentl.wasm" | cut -d' ' -f1 > "$ROOT/.build/frontier-stamp"
  exit 0
fi

# The prelude edge is every link's (driver_seeded): its closure — memory,
# strings, lists, threading — needs no import of its own.
RTLIBS=()

# The persist fixture additionally needs the WASI fs layer and the Persist
# handler itself; its runs preopen /tmp for the checkpoint files.
PERSIST_RTLIBS=(
  "${RTLIBS[@]}"
  io
  persist
)

# The CFC pipeline links the DSP math substrate (math.mn), the comodulogram
# (dsp/cfc.mn, whose read_recording crosses the WASI boundary → io.mn), and
# the synthetic-signal generator (cfc_demo/gen.mn). The demo builds its
# signal inline, so its run preopens nothing.
CFC_RTLIBS=(
  "${RTLIBS[@]}"
  io
  math
  dsp/cfc
  tests/frontier/cfc_demo/gen
)

# The signal-crucible link set: the CFC substrate plus lib/dsp/signal.mn (the
# STFT + `<~` bandpass + filter-based comodulogram). signal.mn reuses cfc.mn's
# mean-vector-length, matrix readers, and file transport (import, never
# duplicate), so both are linked; its own demodulation columns, STFT, and `<~`
# bandpass sit on top. The run preopens /tmp for the recording.
SIGNAL_RTLIBS=(
  "${RTLIBS[@]}"
  io
  math
  dsp/cfc
  dsp/signal
)

# The data-validator lib set: the base runtime plus the WASI fs layer (io.mn),
# for the on-disk [Float]-statistics and String=[byte]-text validators. Their
# runs preopen /tmp for the fixture.
IO_RTLIBS=(
  "${RTLIBS[@]}"
  io
  fs
)

# The real-workload crucible lib set: the base runtime plus the transcendental
# float substrate (math.mn — sin/cos/sqrt/atan2). The dsp/ml/adaptive crucibles
# build their signals and learners inline (no file I/O), so their runs preopen
# nothing.
MATH_RTLIBS=(
  "${RTLIBS[@]}"
  math
)

# The derivative-reading lib set (L4a, 2026-09-28): the signal set plus the
# spectral distortion scene 1 renders and lib/ml/grad.mn's `Derivative` /
# `grad`, so the crucibles differentiate the library's own stages rather than
# copies of them.
DERIVE_RTLIBS=(
  "${SIGNAL_RTLIBS[@]}"
  dsp/spectral
  ml/grad
)

# The arena lib set (2026-10-03): the base runtime plus lib/arena.mn's
# `arena` handler and the `Arena` effect its install charges.
ARENA_RTLIBS=(
  "${RTLIBS[@]}"
  arena
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
# now compile in isolation with ZERO diagnostics. TRAP (2026-10-06) moved it
# once, on the record: every runtime index read whose bound nothing in sight
# proves is an open PInBounds claim, so the libs judged alone carry the one
# class V_Pending (the debt the row now states; #109's path read proves the
# guarded ones and returns this to the empty multiset).
EXPECTED_RUNTIME_SHADOW_SHA256="2c3b4947f8a331994032bdb27e1ff7ecb72e9450cb9d40eabe119ed969fae920"

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

  printf 'fn main() = 0\n' | wt_entry - "${RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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
      wt_entry "$source" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr" ;;
    persist)
      wt_entry "$source" "${PERSIST_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir /tmp) ;;
    cfc)
      wt_entry "$source" "${CFC_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr" ;;
    cfc-rec)
      wt_entry "$source" "${CFC_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    signal)
      wt_entry "$source" "${SIGNAL_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    io-rec)
      wt_entry "$source" "${IO_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr"
      run_flags=(--dir "$dir::/tmp") ;;
    math)
      wt_entry "$source" "${MATH_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr" ;;
    derive)
      wt_entry "$source" "${DERIVE_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr" ;;
    arena)
      wt_entry "$source" "${ARENA_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr" ;;
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

  wt_entry "$src" "${PERSIST_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$cerr"
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
  wt_entry "$src" "${PERSIST_RTLIBS[@]}" arena | wt_rooted "$compiler" > "$wat" 2> "$cerr"
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

# run_module <compiler> <project-dir> <module> <stdout-file> <stderr-file> —
# the host's three steps for a program the compiler emits: compile the
# module as a project (its imports resolved the way a developer's program
# resolves them), assemble it, run it with the project mounted as its ".".
# The program's exit is the answer; a module that did not compile answers
# 199 and one that did not assemble 198, both above any exit a program
# writes, so a leg's "want N" can never be met by a host fault. The exec
# seam left the wheel 2026-10-05: `mentl run` is the mentl command's, and
# here it is these three lines.
run_module() {
  local compiler="$1" pdir="$2" module="$3" out="$4" err="$5"
  wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" compile "$module" \
    > "$pdir/$module.wat" 2> "$err" || { echo "run_module: $module did not compile" >> "$err"; return 199; }
  wt_asm "$pdir/$module.wat" "$pdir/$module.wasm" 2>> "$err" \
    || { echo "run_module: $module did not assemble" >> "$err"; return 198; }
  wt_run --dir "$pdir::." "$pdir/$module.wasm" > "$out" 2>> "$err"
}

# The flagship program (Track G, Pulse scene 1): examples/pulse/render
# rendered through the compiler under test (run_module), and the WAV judged
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
  run_module "$compiler" "$pdir" main "$dir/$label.wav" "$dir/$label.err"
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

# The course (examples/pulse/course): every lesson the compiler builds is
# rendered as its own project — the folder's modules beside it, the lesson
# the entry (run_module) — and its WAV judged by the oracle Pulse's render
# is judged by, with the lesson's own length and notes. Lesson 8 is accepted
# first: `accept` at its hole writes the one survivor into the copy, and a
# tie or a miss fails. A lesson the compiler refuses is the board's
# (`mentl verify`, the owed bounds), never this gate's expected red, so it
# is not rendered here. Then the twins, each the course with ONE line
# changed, so a twin can never drift from the lesson:
#   alloc  an allocation on lesson 5's per-sample path    → E_EffectMismatch
#   rate   rate.mn's `now` pinned at 44.1 kHz under play's `!Sample(44100)`
#                                                         → E_EffectMismatch
#   range  lesson 7's cutoff a constant past Nyquist      → E_RefinementRejected
#   teach  `accept` at lesson 7's division writes `notes: Positive`
run_course() {
  local compiler="$1" dir="$2" src="$ROOT/examples/pulse/course" spec lesson secs notes pdir rc
  for spec in "01-tone 3 220" "02-line 3 220" "03-bus 4 220,329.63" "04-rack 4 220,261.63,329.63,440" \
              "05-silence 4 220,261.63,329.63,440" "06-rate 3 220,277.18,329.63" \
              "07-bounds 4 220,261.63,329.63,440" "08-hole 3 220,329.63" "09-learn 3 220"; do
    set -- $spec; lesson=$1; secs=$2; notes=$3
    pdir="$dir/course-$lesson.proj"
    rm -rf "$pdir"; mkdir -p "$pdir"; cp "$src"/*.mn "$pdir"/
    if [ "$lesson" = 08-hole ] && ! wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" accept 08-hole.mn:50:76 > "$dir/course-08.accept" 2>&1; then
      fail "course 08-hole: accept at the stage hole (see $dir/course-08.accept)"; continue
    fi
    run_module "$compiler" "$pdir" "$lesson" "$dir/course-$lesson.wav" "$dir/course-$lesson.err"; rc=$?
    if [ "$rc" -ne 0 ] || [ ! -s "$dir/course-$lesson.wav" ]; then
      fail "course $lesson render (exit=$rc; see $dir/course-$lesson.err)"
    elif python3 "$ROOT/tests/frontier/pulse-render/oracle.py" "$dir/course-$lesson.wav" --seconds "$secs" --notes "$notes" > "$dir/course-$lesson.oracle" 2>&1; then
      pass "course $lesson: $secs s rendered, the oracle holds ($(grep -c '^PASS' "$dir/course-$lesson.oracle") checks)"
    else
      fail "course $lesson oracle ($(grep '^FAIL' "$dir/course-$lesson.oracle" | head -1); see $dir/course-$lesson.oracle)"
    fi
  done
  local twin file entry pattern replacement class tdir
  for twin in alloc rate range; do
    case "$twin" in
      alloc) file=05-silence.mn; entry=05-silence; pattern='^  let t = time()$'
             replacement='  let t = time()\n  let label = int_to_str(n)'; class=E_EffectMismatch;;
      rate)  file=rate.mn; entry=05-silence; pattern='^fn now() with Sample(48000) = current_sample()$'
             replacement='fn now() with Sample(44100) = current_sample()'; class=E_EffectMismatch;;
      range) file=07-bounds.mn; entry=07-bounds; pattern='^fn cutoff_at(t) -> Hz = 600.0 + 400.0 \* sin(two_pi() \* 0.5 \* t)$'
             replacement='fn cutoff_at(t) -> Hz = 30000.0'; class=E_RefinementRejected;;
    esac
    tdir="$dir/course-$twin.proj"; rm -rf "$tdir"; mkdir -p "$tdir"; cp "$src"/*.mn "$tdir"/
    if [ "$(grep -c "$pattern" "$src/$file")" != "1" ]; then
      fail "course-$twin: the patch no longer applies to $file (pattern: $pattern)"; continue
    fi
    sed -i "s/$pattern/$replacement/" "$tdir/$file"
    wt_run --dir "$tdir::." --dir "$ROOT::/mentl-home" "$compiler" check "$entry" > "$dir/course-$twin.out" 2> "$dir/course-$twin.err"; rc=$?
    if [ "$rc" -ne 0 ] && grep -q "$class" "$dir/course-$twin.err"; then
      pass "course-$twin refuses ($class)"
    else
      fail "course-$twin: expected $class and a refusal (exit=$rc; see $dir/course-$twin.err)"
    fi
  done
  tdir="$dir/course-teach.proj"; rm -rf "$tdir"; mkdir -p "$tdir"; cp "$src"/*.mn "$tdir"/
  if ! wt_run --dir "$tdir::." --dir "$ROOT::/mentl-home" "$compiler" accept 07-bounds.mn:48:1 > "$dir/course-teach.out" 2>&1 \
     && grep -q '`notes: Rate` or `notes: Positive`' "$dir/course-teach.out" && grep -q '^fn frames_per(notes)' "$tdir/07-bounds.mn"; then
    pass "course-teach: accept at lesson 7's division asks Rate or Positive and writes neither"
  else
    fail "course-teach: the accepted declaration reads '$(grep '^fn frames_per' "$tdir/07-bounds.mn")' (see $dir/course-teach.out)"
  fi
}

# Wasatch "Inversion" (examples/wasatch): the score renders from its readings
# module and the oracle hears the lake's pitch under everything else; its
# twin fetches one parameter on the per-sample path and refuses
# (E_EffectMismatch: the path is `!Network`).
run_wasatch() {
  local compiler="$1" dir="$2" src="$ROOT/examples/wasatch" pdir="$dir/wasatch.proj" rc
  rm -rf "$pdir"; mkdir -p "$pdir"; cp "$src"/*.mn "$pdir"/
  run_module "$compiler" "$pdir" inversion "$dir/wasatch.wav" "$dir/wasatch.err"; rc=$?
  if [ "$rc" -ne 0 ] || [ ! -s "$dir/wasatch.wav" ]; then
    fail "wasatch render (exit=$rc; see $dir/wasatch.err)"
  elif python3 "$ROOT/tests/frontier/pulse-render/oracle.py" "$dir/wasatch.wav" --seconds 16 --notes 76.27 > "$dir/wasatch.oracle" 2>&1; then
    pass "wasatch: sixteen seconds rendered, the lake's pitch stands ($(grep -c '^PASS' "$dir/wasatch.oracle") checks)"
  else
    fail "wasatch oracle ($(grep '^FAIL' "$dir/wasatch.oracle" | head -1); see $dir/wasatch.oracle)"
  fi
  local tdir="$dir/wasatch-network.proj" pattern='^  let lake = drone_hz(lake_elevation_ft)$'
  rm -rf "$tdir"; mkdir -p "$tdir"; cp "$src"/*.mn "$tdir"/
  if [ "$(grep -c "$pattern" "$src/inversion.mn")" != "1" ]; then
    fail "wasatch-network: the patch no longer applies to inversion.mn"; return
  fi
  sed -i "s/$pattern/  let lake = drone_hz(lake_elevation_ft)\n  let _ = fetch_param(\"lake\")/" "$tdir/inversion.mn"
  wt_run --dir "$tdir::." --dir "$ROOT::/mentl-home" "$compiler" check inversion > "$dir/wasatch-network.out" 2> "$dir/wasatch-network.err"; rc=$?
  if [ "$rc" -ne 0 ] && grep -q E_EffectMismatch "$dir/wasatch-network.err"; then
    pass "wasatch-network refuses (E_EffectMismatch: the per-sample path cannot reach the network)"
  else
    fail "wasatch-network: expected E_EffectMismatch and a refusal (exit=$rc; see $dir/wasatch-network.err)"
  fi
}

# A program that links library modules by import runs as a project — the
# compile resolves its imports the way a developer's program does, where a
# battery fixture is compiled over the runtime floor alone — and answers
# its expected exit.
run_project() {
  local compiler="$1" dir="$2" label="$3" source="$4" expected="$5"
  local pdir="$dir/$label.proj" rc
  rm -rf "$pdir"
  mkdir -p "$pdir"
  cp "$source" "$pdir/main.mn"
  run_module "$compiler" "$pdir" main "$dir/$label.run.out" "$dir/$label.run.err"
  rc=$?
  if [ "$rc" -eq "$expected" ]; then
    pass "$label: runs to $expected"
  else
    fail "$label: run exit=$rc, want $expected (see $dir/$label.run.err)"
  fi
}

# The environment protocol (E1): required reads refuse before main, while
# optional literal reads are narrowly passed and computed optional reads
# request the whole environment. Exercise the actual generated `mentl run`
# shim as well as the module gate and demand query. RED on boot 4228ff71: the
# program did not compile (the WASI root gate knew no environ op).
run_env_protocol() {
  local compiler="$1" dir="$2" label="env-protocol"
  local pdir="$dir/$label.proj" rc out shim
  rm -rf "$pdir"
  mkdir -p "$pdir"
  cp "$ROOT/tests/frontier/env-protocol/main.mn" "$pdir/main.mn"
  if ! wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
      > "$pdir/main.wat" 2> "$dir/$label.err" \
      || ! wt_asm "$pdir/main.wat" "$pdir/main.wasm" 2>> "$dir/$label.err"; then
    fail "$label: did not compile (see $dir/$label.err)"
    return
  fi
  out=$(wt_run --env MN_A=30 --env MN_B=12 --dir "$pdir::." "$pdir/main.wasm" 2>> "$dir/$label.err")
  rc=$?
  if [ "$rc" -eq 42 ] && [ "$out" = "sum 42" ]; then
    pass "$label: both variables set — runs to 42"
  else
    fail "$label: both set, exit=$rc out='$out', want 42 and 'sum 42'"
  fi
  # The refusal is fail_exit's, which speaks on stderr; main's own line
  # (`sum …`) must not appear on stdout.
  out=$(wt_run --env MN_A=30 --dir "$pdir::." "$pdir/main.wasm" 2> "$dir/$label.unset.err")
  rc=$?
  if [ "$rc" -eq 1 ] && grep -q '^MN_B is read at main:7:' "$dir/$label.unset.err" \
      && ! printf '%s\n' "$out" | grep -q '^sum'; then
    pass "$label: MN_B unset — the launch gate names it and its read site, nothing of main ran"
  else
    fail "$label: MN_B unset, exit=$rc out='$out' (see $dir/$label.unset.err)"
  fi
  wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" query main env > "$dir/$label.query" 2>/dev/null
  if grep -q '2 environment read(s)' "$dir/$label.query" && grep -q 'MN_A \[required\] read at main:7:' "$dir/$label.query" \
      && grep -q 'MN_B \[required\] read at main:7:' "$dir/$label.query"; then
    pass "$label: query env names both reads at their sites"
  else
    fail "$label: query env (see $dir/$label.query)"
  fi

  # Install into the gate's own scratch tree, pointing the shim at the exact
  # compiler under test. This covers the shell/.env projection and the start
  # gate together without touching the user's global `mentl` command.
  MENTL_BIN_DIR="$pdir/bin" bash "$ROOT/tools/install.sh" > "$dir/$label.install" 2>&1
  shim="$pdir/bin/mentl"
  out=$(env MN_A=30 MN_B=12 MENTL_BOOT="$compiler" "$shim" run "$pdir/main" 2> "$dir/$label.shim-set.err")
  rc=$?
  if [ "$rc" -eq 42 ] && [ "$out" = "sum 42" ]; then
    pass "$label: mentl run passes the literal roster from the shell"
  else
    fail "$label: mentl run with variables set, exit=$rc out='$out' (see $dir/$label.shim-set.err)"
  fi
  out=$(env -u MN_B MN_A=30 MENTL_BOOT="$compiler" "$shim" run "$pdir/main" 2> "$dir/$label.shim-unset.err")
  rc=$?
  if [ "$rc" -eq 1 ] && grep -Eq '^MN_B is read at .*/main:7:[0-9]+ \(in total\) and is not set$' "$dir/$label.shim-unset.err" \
      && ! printf '%s\n' "$out" | grep -q '^sum'; then
    pass "$label: mentl run preserves pre-main refusal for an unset required name"
  else
    fail "$label: mentl run with MN_B unset, exit=$rc out='$out' (see $dir/$label.shim-unset.err)"
  fi

  local opt="$dir/env-optional.proj"
  rm -rf "$opt"
  mkdir -p "$opt"
  cp "$ROOT/tests/frontier/env-optional/main.mn" "$opt/main.mn"
  if ! wt_run --dir "$opt::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
      > "$opt/main.wat" 2> "$dir/env-optional.compile.err" \
      || ! wt_asm "$opt/main.wat" "$opt/main.wasm" 2>> "$dir/env-optional.compile.err"; then
    fail "env-optional: did not compile (see $dir/env-optional.compile.err)"
    return
  fi
  wt_run --dir "$opt::." --dir "$ROOT::/mentl-home" "$compiler" query main env > "$dir/env-optional.query" 2>/dev/null
  if grep -q 'MN_OPTIONAL_FIXED \[optional\] read at main:' "$dir/env-optional.query" \
      && grep -q '\* \[all optional\] read at' "$dir/env-optional.query"; then
    pass "env-optional: query distinguishes literal and dynamic optional reads"
  else
    fail "env-optional: query demand (see $dir/env-optional.query)"
  fi
  printf 'MN_OPTIONAL_FIXED=20\nMN_OPTIONAL_DYNAMIC=22\n' > "$opt/.env"
  out=$(env -u MN_OPTIONAL_FIXED -u MN_OPTIONAL_DYNAMIC MENTL_BOOT="$compiler" "$shim" run "$opt/main" 2> "$dir/env-optional.dotenv.err")
  rc=$?
  if [ "$rc" -eq 42 ]; then
    pass "env-optional: mentl run supplies optional values from .env"
  else
    fail "env-optional: .env values, exit=$rc (see $dir/env-optional.dotenv.err)"
  fi
  rm -f "$opt/.env"
  out=$(env -u MN_OPTIONAL_FIXED -u MN_OPTIONAL_DYNAMIC MENTL_BOOT="$compiler" "$shim" run "$opt/main" 2> "$dir/env-optional.absent.err")
  rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "env-optional: absent optional values return None without refusing"
  else
    fail "env-optional: absent optional values, exit=$rc (see $dir/env-optional.absent.err)"
  fi

  local lit="$dir/env-optional-literal.proj"
  mkdir -p "$lit"
  cp "$ROOT/tests/frontier/env-optional-literal/main.mn" "$lit/main.mn"
  if ! wt_run --dir "$lit::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
      > "$lit/main.wat" 2> "$dir/env-optional-literal.compile.err" \
      || ! wt_asm "$lit/main.wat" "$lit/main.wasm" 2>> "$dir/env-optional-literal.compile.err"; then
    fail "env-optional-literal: did not compile (see $dir/env-optional-literal.compile.err)"
    return
  fi
  wt_run --dir "$lit::." --dir "$ROOT::/mentl-home" "$compiler" query main env > "$dir/env-optional-literal.query" 2>/dev/null
  if grep -q 'MN_OPTIONAL_LITERAL \[optional\] read at main:' "$dir/env-optional-literal.query" \
      && ! grep -q '\* \[all optional\]' "$dir/env-optional-literal.query"; then
    pass "env-optional-literal: query stays narrow"
  else
    fail "env-optional-literal: query demand (see $dir/env-optional-literal.query)"
  fi
  printf 'MN_OPTIONAL_LITERAL=42\n' > "$lit/.env"
  out=$(env -u MN_OPTIONAL_LITERAL MENTL_BOOT="$compiler" "$shim" run "$lit/main" 2> "$dir/env-optional-literal.dotenv.err")
  rc=$?
  if [ "$rc" -eq 42 ]; then
    pass "env-optional-literal: mentl run passes the named .env value"
  else
    fail "env-optional-literal: named .env value, exit=$rc (see $dir/env-optional-literal.dotenv.err)"
  fi
  rm -f "$lit/.env"
  out=$(env -u MN_OPTIONAL_LITERAL MENTL_BOOT="$compiler" "$shim" run "$lit/main" 2> "$dir/env-optional-literal.absent.err")
  rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "env-optional-literal: absence returns None without widening access"
  else
    fail "env-optional-literal: absent value, exit=$rc (see $dir/env-optional-literal.absent.err)"
  fi
}

# The warm world: a compile persists its analyzed image, and a second compile
# of the same file restores it and must still emit the WHOLE module — the
# contract that caught a restored image carrying a foreign world's output
# routing (2026-09-28: `run` then `compile` printed nothing; the image is
# filed under world_key() since). The program also runs, through the host.
run_warm_world() {
  local compiler="$1" dir="$2" label="warm-world"
  local wdir="$dir/$label.proj" rc lines
  rm -rf "$wdir"
  mkdir -p "$wdir/.build"
  printf 'fn main() = 9\n' > "$wdir/main.mn"
  run_module "$compiler" "$wdir" main "$dir/$label.run.out" "$dir/$label.run.err"
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
    pass "$label: the warm compile after a compile emits the module ($lines WAT lines)"
  else
    fail "$label: the warm compile emitted $lines WAT lines (exit=$rc; see $dir/$label.err)"
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
  if grep -q '^warm: re-judged 1 declaration(s) in 1 module(s)$' "$dir/$label.2.err" && [ "$n" = "1" ] \
     && grep -q '^verify: pending comparison 0 < self at main:5:13-5:36$' "$dir/$label.2.err"; then
    pass "$label: the warm compile reports the edited claim once, at its new span"
  else
    fail "$label: $n pending report(s) after one edit, want 1 at main:5:13-5:36 (see $dir/$label.2.err)"
  fi
}

# The incremental cursor gate: a three-module DAG, one edit, one truth.
run_warm_incremental() {
  local compiler="$1" dir="$2" label="warm-inc"
  local wdir="$dir/$label.proj" refdir="$dir/$label.ref" rc
  rm -rf "$wdir" "$refdir" && mkdir -p "$wdir/.build" "$refdir/.build"
  printf 'fn base() = 20\neffect Ab {\n  ab() -> Int\n}\n' > "$wdir/a.mn"
  printf 'import a\nhandler bail {\n  ab() => 5,\n}\nfn mid() = base() + 1\n' > "$wdir/b.mn"
  printf 'import a\nimport b\nfn main() = mid() * 2 + (ab() ~> bail)\n' > "$wdir/main.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.1.wat" 2> "$dir/$label.1.err"
  rc=$?
  if [ "$rc" -ne 0 ] || [ ! -s "$dir/$label.1.wat" ]; then
    fail "$label cold compile (exit=$rc; see $dir/$label.1.err)"
    return
  fi
  pass "$label cold compile"
  printf 'fn base() = 20\n// the op bail answers\neffect Ab {\n  ab() -> Int\n}\n' > "$wdir/a.mn"
  printf 'import a\nhandler bail {\n  ab() => 5,\n}\nfn mid() = base() + 2\n' > "$wdir/b.mn"
  wt_run --dir "$wdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.2.wat" 2> "$dir/$label.2.err"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$label incremental compile (exit=$rc; see $dir/$label.2.err)"
    return
  fi
  # The edit moves `Ab` and rewrites `mid`; `bail`'s arm and `main` read them,
  # so four declarations in three modules are judged again and `base` is kept.
  # A failure here does not return: the checks below read the same artifacts.
  if ! grep -q '^warm: re-judged 4 declaration(s) in 3 module(s)$' "$dir/$label.2.err"; then
    fail "$label cone line (want 'warm: re-judged 4 declaration(s) in 3 module(s)'; see $dir/$label.2.err)"
  else
    pass "$label cone counted (Ab, bail, mid and main judged again, base kept)"
  fi
  cp "$wdir/a.mn" "$wdir/b.mn" "$wdir/main.mn" "$refdir/"
  wt_run --dir "$refdir::." --dir "$ROOT::/mentl-home" "$compiler" compile main \
    > "$dir/$label.ref.wat" 2> "$dir/$label.ref.err"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$label cold reference (exit=$rc; see $dir/$label.ref.err)"
    return
  fi
  wt_asm "$dir/$label.2.wat" "$dir/$label.2.wasm" > /dev/null 2>&1 && wt_run --dir "$wdir::." "$dir/$label.2.wasm" > /dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 49 ] && cmp -s <(sed -E 's/[0-9]+/N/g' "$dir/$label.2.wat") <(sed -E 's/[0-9]+/N/g' "$dir/$label.ref.wat"); then
    pass "$label incremental runs to 49 and equals cold-of-patched up to handle numbers"
  else
    fail "$label incremental (exit=$rc, want 49; diff $dir/$label.2.wat $dir/$label.ref.wat)"
  fi
}

# A refusal leg a function or loop drives: the fixture links lib/ (a schedule
# handler, the prelude) and must refuse — no WAT, nonzero exit, the class named
# at least once. A fixture of its own carries this as its contract instead
# (`// expect: refuse E_X`, judged by `mentl test tests/frontier`).
run_refusal_linked() {
  local compiler="$1" label="$2" source="$3" expected_code="$4" dir="$5"
  local link_runtime="${6:-yes}"
  local wat="$dir/$label.wat" err="$dir/$label.compile.err"
  local rc count size

  # The lib set is the program's, as run_program reads it: the runtime floor
  # by default, the derivative-reading set for a refusal the reading makes.
  case "$link_runtime" in
    derive)
      wt_entry "$source" "${DERIVE_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$err" ;;
    arena)
      wt_entry "$source" "${ARENA_RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$err" ;;
    *)
      wt_entry "$source" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$wat" 2> "$err" ;;
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

  printf 'fn main() = 0\n' | wt_entry - "${PERSIST_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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

  printf 'fn main() = 0\n' | wt_entry - "${CFC_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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

  printf 'fn main() = 0\n' | wt_entry - "${SIGNAL_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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
# 50 Hz-amplitude coupling — a DIFFERENT pair than cfc_demo (6->40) and cfc-rec
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

  printf 'fn main() = 0\n' | wt_entry - "${IO_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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

  printf 'fn main() = 0\n' | wt_entry - "${MATH_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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

  printf 'fn main() = 0\n' | wt_entry - "${DERIVE_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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

  printf 'fn main() = 0\n' | wt_entry - "${ARENA_RTLIBS[@]}" \
    | wt_rooted "$compiler" > "$wat" 2> "$err"
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
  for spec in '|>:11' '<|:12' '><:13' '~>:14' 'anonymous:15' '<~:16' 'eta:25' 'effectful-lambda:26' 'iteration:27' 'wildcard-zero:28' 'failure-mask:29' 'print-in-report:32' 'wildcard-fabricates:33' 'underscore-retain:34' 'flag-as-int:35' 'parallel-arrays:36' 'parallel-arrays:38' 'vtable-record:37' 'env-frame:39' 'default-param:40' 'record-pattern:41' 'declared-row-hof:42'; do
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
  for spec in '|>:11' '<|:12' '><:13' '~>:14' 'anonymous:15' '<~:16' 'eta:25' 'effectful-lambda:26' 'iteration:27' 'wildcard-zero:28' 'failure-mask:29' 'print-in-report:32' 'wildcard-fabricates:33' 'underscore-retain:34' 'flag-as-int:35' 'parallel-arrays:36' 'parallel-arrays:38' 'vtable-record:37' 'env-frame:39' 'default-param:40' 'record-pattern:41' 'declared-row-hof:42'; do
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
  ad_n=$(wt_run --dir "$ROOT" "$compiler" audit "$doc" 2>/dev/null | grep -c "shapes the census counts here:")
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
  # THE LEG PASSES ON CONTENTS AND NOTHING ELSE (G2). It used to pass on a
  # clean exit with no hover at all ("the next rung"), so the one thing it
  # names could vanish and the frontier stay green. A hover whose value is
  # empty is no hover.
  if grep -qE '"contents":\{"kind":"markdown","value":"[^"]+"' "$sout"; then
    pass "$label lsp serve hover returned a type (contents present)"
  elif grep -q 'parse_number' "$serr"; then
    fail "$label lsp serve REGRESSED to the json float trap (Hβ.emit.float-evidence-ft returned; see $serr)"
  else
    fail "$label lsp serve answered no hover contents (exit=$src; see $sout, $serr)"
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
  run_program "$compiler" cfc_demo \
    "$ROOT/tests/frontier/cfc_demo/demo.mn" 42 cfc "$dir"
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
             abort-exits resume-nests-exactly arena-is-a-junction \
             list-value-reenters older-store-reenters reyield-reenters \
             float-value-reenters abandon-through-arena; do
    run_program "$compiler" "arena-$leg" \
      "$ROOT/tests/frontier/arena/$leg.mn" 42 arena "$dir"
  done
  for leg in addr-stored-as-word-refuses addr-among-numbers-refuses; do
    run_refusal_linked "$compiler" "arena-$leg" \
      "$ROOT/tests/frontier/arena/$leg.mn" E_TypeMismatch "$dir" arena
  done
  # The refusal's words and the run's stdout — what a fixture contract cannot
  # name yet — read off a compile and a run of the leg's own.
  wt_entry "$ROOT/tests/frontier/mn-threaded-branch-state-store.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > /dev/null 2> "$dir/threaded-branch-state-store.compile.err"
  if grep -q 'an in-place store into `buf`' "$dir/threaded-branch-state-store.compile.err"; then
    pass "threaded-branch-state-store names the in-place store"
  else
    fail "threaded-branch-state-store refusal does not name the in-place store (see $dir/threaded-branch-state-store.compile.err)"
  fi
  wt_entry "$ROOT/tests/frontier/mn-threaded-branch-captured-store.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > /dev/null 2> "$dir/threaded-branch-captured-store.compile.err"
  if grep -q 'stores into memory older than itself at' "$dir/threaded-branch-captured-store.compile.err"; then
    pass "threaded-branch-captured-store names the store"
  else
    fail "threaded-branch-captured-store refusal does not name the store (see $dir/threaded-branch-captured-store.compile.err)"
  fi
  wt_entry "$ROOT/tests/frontier/mn-spawn-module-init-once.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$dir/spawn-module-init-once.wat" 2> /dev/null \
    && wt_asm "$dir/spawn-module-init-once.wat" "$dir/spawn-module-init-once.wasm" 2> /dev/null \
    && wt_run "$dir/spawn-module-init-once.wasm" > "$dir/spawn-module-init-once.run.out" 2> /dev/null
  init_lines=$(grep -c '^init$' "$dir/spawn-module-init-once.run.out" 2>/dev/null || true)
  if [ "${init_lines:-0}" -eq 1 ]; then
    pass "spawn-module-init-once: the init ran once across the root and both branches"
  else
    fail "spawn-module-init-once: the init ran ${init_lines:-0} time(s) — a spawned instance re-ran a module init"
  fi
  for leg in spawn-alloc-contention spawn-alloc-contention-seq; do
    if [ -f "$dir/$leg.wasm" ]; then
      t0=$(date +%s%N)
      wt_run "$dir/$leg.wasm" > /dev/null 2>&1
      t1=$(date +%s%N)
      echo "  time $leg: $(( (t1 - t0) / 1000000 )) ms"
    fi
  done
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
  # The course beside it: every lesson the compiler builds rendered and
  # judged, lesson 8 accepted first, the course's twins refusing (run_course's
  # own header); then Wasatch's score and its network twin (run_wasatch).
  run_course "$compiler" "$dir"
  run_wasatch "$compiler" "$dir"
  # The JSON serializer's string escape over the shapes that defeated it — a
  # one-byte string serialized as a NUL, a quote as two, a control byte with
  # no short spelling crossed raw. RED on boot 2198ed97: exit 1.
  run_project "$compiler" "$dir" json-escape-total "$ROOT/tests/frontier/mn-json-escape-total.mn" 42
  # Configuration is an effect and the demand is the manifest (E1,
  # run_env_protocol's header).
  run_env_protocol "$compiler" "$dir"
  # The compile says where it is (PLAN §11): at a terminal a check draws the
  # link, each module parsed and the judging, then clears its row; into a pipe
  # it writes no live line. RED on boot 30605949: 0 bytes at a terminal.
  live=$(cd "$ROOT" && script -qec "$WT run ${WT_RUN_FLAGS[*]} --dir . --dir $ROOT::/mentl-home $compiler check examples/pulse/course/01-tone.mn" /dev/null)
  piped=$(cd "$ROOT" && wt_run --dir . --dir "$ROOT::/mentl-home" "$compiler" check examples/pulse/course/01-tone.mn 2>&1 >/dev/null | grep -c $'\r')
  linked=$(printf '%s' "$live" | grep -o 'linked [0-9]* modules' | grep -o '[0-9]*')
  if [ -n "$linked" ] && [[ "$live" == *"parsing $linked/$linked modules"* && "$live" == *"judging 1/"* && "$live" == *$'\e[K' ]] && [ "$piped" = 0 ]; then
    pass "the compile says where it is: $linked modules linked and parsed, the judging drawn, its row cleared; a pipe gets no live line"
  else
    fail "the compile's live line (linked='$linked', carriage returns into a pipe=$piped)"
  fi
  # C5 — partiality is a row fact: the absorb rewrite x * 0 ≡ 0 keeps a
  # division whose precondition stays open (it carries `Trap`), so
  # `(1 / n) * 0` TRAPS at n = 0 as written (exit 134 through the engine).
  # The claim is OPEN by design — `n` is unbounded — so the compile
  # surfaces it as V_Pending, which the leg ASSERTS: an open claim is the
  # whole reason the operand survives. RED on boot 21f8e691: the shape-read
  # gate dropped the operand and the program answered 0.
  run_open_claim "$compiler" absorb-keeps-trap \
    "$ROOT/tests/frontier/mn-absorb-keeps-trap.mn" 134 "$dir"
  # A base whose every call is keyed to a twin is not emitted (the emitted
  # reach, 2026-09-28), so its floors are never settled, let alone refused:
  # RED on boot c5439637, which answered 46 and warned twice about `pick`'s
  # base.
  run_unnarrated "$compiler" dead-base-unnarrated \
    "$ROOT/tests/frontier/mn-dead-base-unnarrated.mn" 46 E_FieldOffsetUnprovable "$dir"
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
  wt_entry "$ROOT/tests/frontier/mn-effect-escaped-install.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$dir/effect-escaped-install.wat" 2> "$dir/effect-escaped-install.err"
  esc_rc=$?
  if [ "$esc_rc" != "0" ] && [ ! -s "$dir/effect-escaped-install.wat" ] && grep -q 'E_EffectUnhandled.*Ping' "$dir/effect-escaped-install.err"; then
    pass "effect-escaped-install refuses at COMPILE (E_EffectUnhandled names Ping, no WAT)"
  else
    fail "effect-escaped-install (rc=$esc_rc wat=$(wc -c < "$dir/effect-escaped-install.wat"); see $dir/effect-escaped-install.err)"
  fi
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
    && printf '%s' "$ug_fin" | grep -q 'own xs: ' \
    && printf '%s' "$ug_fin" | grep -q 'ref c: ' \
    && printf '%s' "$ug_stmt" | grep -q 'own xs: '; then
    pass "usage grade: join and mode hold (no false narration; Own/Ref badges true)"
  else
    fail "usage grade (false-narrations=$ug_false; finish='$(printf '%s' "$ug_fin" | head -1)' stmt='$(printf '%s' "$ug_stmt" | head -1)')"
  fi
  run_lsp_hover "$compiler" "$dir" lsp
  run_census "$compiler" "$dir"

  # ── the annotation verifier PROVES (never reads boundness) ──────────
  # Seen RED on the pre-fix boot: an allocating main (++ carries its
  # callee's row) was offered "!Alloc ... proven zero allocation" — the
  # tentative-apply's post-bind NBound read was the whole check, and a
  # bind always sticks. The fix returns row_subsumes(body_row, narrowing)
  # from the apply — the fn-finalize gate's own engine. Since T2
  # (2026-10-13) a lock is taught only where a clause stands on it, so the
  # fixture's g declares `!Trap` over a call to the allocating f: f's line
  # carries `!Trap` (stood on, proven) and never `!Alloc` (unprovable, and
  # nothing stands on it).
  wt_entry "$ROOT/tests/frontier/mn-teach-alloc-honest.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" teach - > "$dir/teach-alloc.out" 2>/dev/null
  # Judge f's OWN line: teach projects every fn in the linked blob.
  if grep '^f:' "$dir/teach-alloc.out" | grep -q '!Alloc'; then
    fail "teach-alloc-honest (an allocating body was offered !Alloc as proven)"
  elif grep '^f:' "$dir/teach-alloc.out" | grep -q '!Trap'; then
    pass "teach-alloc-honest (no !Alloc proposal on an allocating body; the !Trap its caller stands on is taught)"
  else
    fail "teach-alloc-honest (the stood-on lock died; got: $(grep '^f:' "$dir/teach-alloc.out" | head -1))"
  fi
  # A LOCK IS TAUGHT ONLY WHERE SOMETHING STANDS ON IT (T2, 2026-10-13).
  # `fn main() = 42` has no callers, so no clause rests on its purity and
  # nothing is taught. RED on boot c939f5b8, where this line read
  # `main: → add \`with Pure\` — locks Pure`: the strongest clause a body
  # proved was offered whether or not anything depended on it, 367 of 427
  # declarations across six wheel modules on 2026-10-06. The locks that ARE
  # stood on are the teach battery's lock-* fixtures (tests/teach).
  wt_entry "$ROOT/tests/frontier/mn-teach-pure-control.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" teach - > "$dir/teach-pure.out" 2>/dev/null
  if ! grep -q '^main:' "$dir/teach-pure.out" && grep -q 'nothing to unlock in .*\bmain\b' "$dir/teach-pure.out"; then
    pass "teach-claimless-none (a declaration no clause stands on is taught no lock)"
  else
    fail "teach-claimless-none (got: $(grep '^main:' "$dir/teach-pure.out" | head -1))"
  fi

  # TEACH READS THE DECLARATION AND THE JUDGMENT (PROGRAM D1/D2). Born RED
  # 2026-09-25: every fn of this fixture was told to add `!Alloc` — `step`,
  # which declares it; `add`, which proves `with Pure`; `helper`, whose
  # over-declared row the judgment had already banked — and the address
  # surface printed one constant Teach sentence at the call site. main
  # declares `with Pure` since T2, so its clause is what stands on add.
  ta_file="$ROOT/tests/frontier/mn-teach-authored.mn"
  ta_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" teach "$ta_file" 2>/dev/null)
  ta_decl=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" "$ta_file:16" 2>/dev/null)
  ta_call=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" "$ta_file:18:40" 2>/dev/null)
  if ! printf '%s' "$ta_out" | grep '^step:' | grep -q 'add with !Alloc' \
     && printf '%s' "$ta_out" | grep '^helper:' | grep -q 'tighten' \
     && printf '%s' "$ta_out" | grep '^add:' | grep -q 'with Pure' \
     && printf '%s' "$ta_decl" | grep -q '^Teach: add `with Pure`' \
     && ! printf '%s' "$ta_call" | grep -q '^Teach:'; then
    pass "teach reads the declaration and the judgment (no redundant !Alloc; Pure taught; tightening taught; no Teach at a call)"
  else
    fail "teach-authored (teach: $(printf '%s' "$ta_out" | grep -E '^(step|helper|add):' | tr '\n' ' ') decl: $(printf '%s' "$ta_decl" | grep Teach) call: $(printf '%s' "$ta_call" | grep Teach))"
  fi
  # AN ARGUMENT HOLE AT AN OPERAND IS A VALUE HOLE (2026-10-13). Nothing can
  # fill the field of `choose(??) + 1` later, so the call is applied and the
  # hole takes the slot's contract: `check` is clean (RED on boot c939f5b8:
  # the call was the product with a hole and `+` refused E_ArithOnAggregate),
  # the proposal battery fills `1` (tests/proposals/arg-slot-operand.mn), and
  # the executable still refuses the unfilled hole honestly.
  ho_file="$ROOT/tests/proposals/arg-slot-operand.mn"
  ho_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ho_file" 2>&1)
  ho_rc=$?
  if [ "$ho_rc" -eq 0 ] && [ -z "$ho_out" ]; then
    pass "hole-operand check (an argument hole at an operand is a value hole; the call applies)"
  else
    fail "hole-operand check (exit=$ho_rc: $(printf '%s' "$ho_out" | head -2 | tr '\n' ' '))"
  fi
  compile_hole_fixture "$compiler" hole-operand "$ho_file" "$dir"

  # Hβ.emit.under-application-suspension's crucible: a bare
  # under-application (one field absent, no ?? marker) is the partial it
  # names, and the program RUNS as the suspension, exit 42. Nothing else
  # passes (G2): the leg accepted "loud at assemble" as green for as long as
  # the fix was unbuilt, and kept accepting it after the fix landed, so the
  # suspension could regress to invalid WAT under a green frontier.
  ua_dir="$dir/under-app"
  mkdir -p "$ua_dir"
  wt_run "$compiler" < "$ROOT/tests/frontier/mn-under-application-loud.mn" > "$ua_dir/ua.wat" 2> "$ua_dir/ua.compile.err"
  if wt_asm "$ua_dir/ua.wat" "$ua_dir/ua.wasm" 2> "$ua_dir/ua.assemble.err"; then
    "$WT" run "${WT_RUN_FLAGS[@]}" "$ua_dir/ua.wasm" > "$ua_dir/ua.run.out" 2> "$ua_dir/ua.run.err"
    ua_rc=$?
    if [ "$ua_rc" = "42" ]; then
      pass "under-application: the suspension runs (exit 42)"
    else
      fail "under-application: a bare under-application RAN with exit $ua_rc, not 42 — the silent-wrong transition (see $ua_dir)"
    fi
  else
    fail "under-application: the suspension no longer assembles (see $ua_dir/ua.assemble.err)"
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
  # The assertion anchors on the CLAIM (`real-time safe`), not on
  # the section keyword, because the keyword moved: severance reads at the
  # MODULE now and a function's own line carries only its delta above it
  # (`severs beyond the module:`), so `severable:` no longer appears per fn.
  # The invariant is unchanged and is what this leg is for.
  wt_entry "$ROOT/tests/frontier/mn-audit-severance-honest.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" audit - > "$dir/audit-sev.out" 2>/dev/null
  if grep -A1 '^allocates ' "$dir/audit-sev.out" | grep -q 'real-time safe'; then
    fail "audit-severance-honest (an allocating row was offered Alloc severance)"
  elif grep -A1 '^quiet ' "$dir/audit-sev.out" | grep -q 'real-time safe'; then
    pass "audit-severance-honest (Alloc never offered on an allocating row; the pure control keeps it)"
  else
    fail "audit-severance-honest (the pure control lost its true severance offer)"
  fi

  # TRAP (2026-10-06): the deliberate trap is in the row. extract_chase traps
  # at depth > 1000 by its own comment, and its row must say so; the audit's
  # !Trap offer states what !Trap proves and never "Total". RED on boot
  # 4228ff71: `extract_chase(handle, depth) with Memory + GraphRead`, and the
  # audit offered "Total (proven never to trap)" over it.
  trap_where=$(wt_run --dir "$ROOT" "$compiler" where "$ROOT/src/main.mn" extract_chase 2>/dev/null | head -1)
  trap_row_ok=0
  printf '%s' "$trap_where" | grep -qE '^→ extract_chase\(.*\).* with .*\bTrap\b' && trap_row_ok=1
  judge trap-in-the-row "$trap_row_ok" "trap in the row (extract_chase's row carries Trap) (got: $trap_where)"
  trap_label_ok=1
  grep -q 'Total (proven' "$dir/audit-sev.out" && trap_label_ok=0
  judge trap-free-label "$trap_label_ok" "trap-free label (no \"Total\" offer on the audit while termination is unrowed)"

  # The verb-shape tier (audit): a 2-step single-use let-chain invites the
  # |> pipe; a twice-used name (`<|` territory) and a one-step let (the
  # law's own exception) stay silent — both faces asserted.
  wt_entry "$ROOT/tests/frontier/mn-audit-pipe-shape.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" audit - > "$dir/audit-pipe.out" 2>/dev/null
  if grep -A4 '^chained ' "$dir/audit-pipe.out" | grep -q 'a 2-step chain of lets'; then
    if grep -A4 '^forked ' "$dir/audit-pipe.out" | grep -q 'could be one |> pipe' \
       || grep -A4 '^single ' "$dir/audit-pipe.out" | grep -q 'could be one |> pipe'; then
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

  # ── the catch-all over a sum is the roster the author declined to write ──
  # (Morgan, 2026-10-13). wild.mn stands a `_` and a bare binder after other
  # arms over `Dot | Line(Int) | Box(Int, Int) | Blob`, and a `_` over an Int.
  # The judgment refuses the two over the sum, each naming its roster;
  # tighten writes the rosters — the binder's as the binder over the group,
  # the arm's comment kept; the result checks clean and runs to 5; the second
  # run finds nothing; the file is canonical. RED on boot eed49486: both
  # catch-alls accepted.
  cp "$ROOT/tests/frontier/tighten-demo/wild.mn" "$tdemo/wild.mn"
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check wild.mn) >"$dir/wild-refuse.out" 2>&1
  wref=$?
  if [ $wref -ne 0 ] && [ "$(grep -c 'E_CatchAllOverSum' "$dir/wild-refuse.out")" -eq 2 ] && grep -q 'other @ (Line(_) | Box(_, _) | Blob)' "$dir/wild-refuse.out"; then
    pass "the judgment refuses each catch-all over a sum, naming its roster"
  else
    fail "catch-all over a sum (exit=$wref; see $dir/wild-refuse.out)"
  fi
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" tighten wild.mn) >"$dir/wild-tighten.out" 2>&1
  wrc=$?
  if [ $wrc -eq 0 ] && grep -q '^  Box(_, _) | Blob => 4,' "$tdemo/wild.mn" && grep -q '^  // a box and a blob have four sides each$' "$tdemo/wild.mn" && grep -q '^  other @ (Line(_) | Box(_, _) | Blob) => "many",' "$tdemo/wild.mn" && grep -q '^  _ => 1,' "$tdemo/wild.mn"; then
    pass "tighten writes the roster each catch-all stood for, the binder over its group, the arm's comment and the word's complement kept"
  else
    fail "wildcard-over-sum tighten (exit=$wrc; see $dir/wild-tighten.out)"
  fi
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check wild.mn) >"$dir/wild-check.out" 2>&1
  if [ $? -eq 0 ] && [ ! -s "$dir/wild-check.out" ]; then
    pass "the rostered match checks clean"
  else
    fail "wildcard-over-sum check (see $dir/wild-check.out)"
  fi
  # The wheel only emits; running is the mentl command's (run_module).
  run_module "$compiler" "$tdemo" wild "$dir/wild-run.out" "$dir/wild-run.err"
  wrun=$?
  if [ $wrun -eq 5 ]; then
    pass "the rostered match runs to 5"
  else
    fail "wildcard-over-sum run (exit=$wrun; see $dir/wild-run.err)"
  fi
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" tighten wild.mn) >"$dir/wild-tighten2.out" 2>&1
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" fmt --check wild.mn) >"$dir/wild-fmt.out" 2>&1
  wfmt=$?
  if grep -q 'nothing to tighten' "$dir/wild-tighten2.out" && [ $wfmt -eq 0 ]; then
    pass "the roster is the fixpoint: a second run finds nothing and the file is canonical"
  else
    fail "wildcard-over-sum fixpoint (fmt=$wfmt; see $dir/wild-tighten2.out, $dir/wild-fmt.out)"
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
  wt_entry "$fdemo2/rich.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/pre.wat" 2>/dev/null \
    && wt_asm "$fdemo2/pre.wat" "$fdemo2/pre.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/pre.wasm" >/dev/null 2>&1
  fmt_pre=$?
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt rich.mn) >"$dir/fmt.out" 2>&1
  fmt_rc=$?
  wt_entry "$fdemo2/rich.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/post.wat" 2>/dev/null \
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
  # A destructuring let renders as the let the author wrote, never as the
  # one-arm match the parse makes of it (RED on boot 50da7612: every
  # let became a match one level deeper per destructure). The fixture is
  # canonical as written, and runs to 22.
  cp "$ROOT/tests/frontier/fmt-demo/lets.mn" "$fdemo2/lets.mn"
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt --check lets.mn) >"$dir/fmt-lets.out" 2>&1
  lets_rc=$?
  wt_entry "$fdemo2/lets.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/lets.wat" 2>/dev/null \
    && wt_asm "$fdemo2/lets.wat" "$fdemo2/lets.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/lets.wasm" >/dev/null 2>&1
  lets_run=$?
  if [ $lets_rc -eq 0 ] && [ "$lets_run" = "22" ]; then
    pass "fmt writes a destructuring let as a let (canonical as authored, runs to 22)"
  else
    fail "fmt destructuring let (check rc=$lets_rc run=$lets_run; see $dir/fmt-lets.out)"
  fi
  # A parse that recovered is never rendered: an unexpected token only
  # narrates, and fmt wrote the recovery's holes back over the author's
  # clause (RED on boot b2920932 and its candidate: `[e - E]` became
  # `+  = e - E` with two `??` lines; a keyword binder became `let _`, RED
  # since boot 21f8e691). The file stays byte for byte.
  for rec in recovered keyword-binder; do
    cp "$ROOT/tests/frontier/fmt-demo/$rec.mn" "$fdemo2/$rec.mn"
    (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt "$rec.mn") >"$dir/fmt-$rec.out" 2>&1
    if cmp -s "$ROOT/tests/frontier/fmt-demo/$rec.mn" "$fdemo2/$rec.mn"; then
      pass "fmt never writes a parse it recovered ($rec.mn stays as authored)"
    else
      fail "fmt wrote a recovered parse (see $fdemo2/$rec.mn, $dir/fmt-$rec.out)"
    fi
  done
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
  # ── a target that names no file and no module is refused, and no file
  # appears. RED on boot c0b2828c: the resolver answered a fabricated
  # `lib/<name>.mn` for a module with no file, and fmt wrote ANOTHER
  # module's render there (lib/--check.mn held lib/memory.mn's text).
  mkdir -p "$fdemo2/lib"
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt no_such_module) >"$dir/fmt-nothing.out" 2>&1
  nothing_rc=$?
  if [ $nothing_rc -ne 0 ] && [ ! -e "$fdemo2/lib/no_such_module.mn" ] && [ ! -e "$fdemo2/no_such_module.mn" ] \
     && grep -q 'no_such_module' "$dir/fmt-nothing.out"; then
    pass "fmt refuses a target that names nothing, and writes no file"
  else
    fail "fmt wrote or accepted a target that names nothing (rc=$nothing_rc; see $dir/fmt-nothing.out, $fdemo2/lib)"
  fi
  # ── fmt rungs 1/2/4 (the census's universal blockers) — RED pre-fix:
  # the signed with-clause rendered «invalid-effect», every handler decl
  # trapped in render_handler_arms, and authored `-> RetTy` dropped.
  cp "$ROOT/tests/frontier/fmt-demo/voicey.mn" "$fdemo2/voicey.mn"
  wt_entry "$fdemo2/voicey.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/vpre.wat" 2>/dev/null \
    && wt_asm "$fdemo2/vpre.wat" "$fdemo2/vpre.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/vpre.wasm" >/dev/null 2>&1
  vfmt_pre=$?
  (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt voicey.mn) >"$dir/vfmt.out" 2>&1
  vfmt_rc=$?
  wt_entry "$fdemo2/voicey.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/vpost.wat" 2>/dev/null \
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
  if [ "$derr" = 0 ] && printf '%s' "$dout" | grep -q '^compute(' && printf '%s' "$dout" | grep -q 'The outer prose'; then
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
     && printf '%s' "$adout" | grep -q '(own n: Int' \
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
  cshadow=$( (cd "$cdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$cdemo" --dir /tmp "$compiler" where walk.mn shadowed 2>>"$dir/caret.err") | head -1)
  if [ "$cwhere" = "→ inv(own n: Positive) -> Int  at walk:11" ] && [ "$cshadow" = "→ shadowed(xs: a) -> Int  at walk:38" ]; then
    pass "where answers where (the declaration's address beside its head; a parameter only a shadowing binder's spelling reads is unmarked — ref on boot 59f854f1)"
  else
    fail "where answers where (got: $cwhere / $cshadow; see $dir/caret.err)"
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
     && printf '%s' "$cfb" | grep -q '^Effects: Mutate$' \
     && printf '%s' "$clet" | grep -q '^Effects: Memory + Alloc, and Tick when called$' \
     && printf '%s' "$cdiv" | grep -q '^Effects: Trap$' \
     && printf '%s' "$cstage" | grep -q '^Effects: Pure when called$' \
     && printf '%s' "$cdiv" | grep -q '^Verify: pending partiality k - 1 != 0 && 100 / (k - 1) fits' \
     && ! printf '%s' "$cstage" | grep -q '^Verify:'; then
    pass "caret effects and verify (what running the node performs — a tick's store into its line included — said Pure too; each obligation inside the node, named)"
  else
    fail "caret effects/verify (got: $(printf '%s' "$cfb$cdiv" | grep -E '^(Effects|Verify)'); see $dir/caret.err)"
  fi
  # ── THE GRADIENT READS ADDRESSES (D3) ─────────────────────────────
  # The field of ONE module in the ONE order the session's argmax reads:
  # score descending, then source position. A helper's decls sit inside the
  # entry's line range, and on boot 9387fea1 the field listed them under
  # main's coordinates (5 positions, `twice` at main:4 and `total` at main:6),
  # tie-broken by handle. The session's head is that field's head, and its
  # accept is a clause the formatter writes into the decl's own file: on the
  # same boot the session focused the PRELUDE's `unwrap_or` (61:1) and
  # accepting it wrote `  with Pure` above main.mn's first line. Since T2
  # (2026-10-13) a lock is a position only where a clause stands on it: main
  # and quiet declare `!Fail`, so `add` (two clauses stand on it) ranks above
  # `build` (one), and main and quiet, authoring clauses, are no positions —
  # on boot c939f5b8 the field held three locks nothing stood on.
  gdemo="$ROOT/tests/frontier/gradient-module-demo"
  gfout=$(wt_run --dir "$gdemo::." --dir "$ROOT::/mentl-home" "$compiler" main.mn:0 2>"$dir/gradient-field.err")
  gorder=$(printf '%s\n' "$gfout" | grep -oE '^── main:[0-9]+:[0-9]+' | tr '\n' ' ')
  if printf '%s' "$gfout" | grep -q '2 gradient position(s) in main' \
     && [ "$gorder" = "── main:5:1 ── main:3:1 " ] \
     && printf '%s' "$gfout" | grep -q 'stand on it' \
     && ! printf '%s' "$gfout" | grep -qE "'(twice|total)'"; then
    pass "gradient field: the module's own positions, ranked by what stands on them then source order"
  else
    fail "gradient field (order: $gorder; see $dir/gradient-field.err)"
  fi
  gadir="$dir/gradient-accept"
  rm -rf "$gadir"; mkdir -p "$gadir" && cp "$gdemo"/*.mn "$gadir/"
  gaout=$(printf 'y\n' | timeout 60 "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$gadir::." --dir "$ROOT::/mentl-home" "$compiler" edit main 2>"$dir/gradient-accept.err")
  if printf '%s' "$gaout" | grep -q "params of 'add'" \
     && grep -qx 'fn add(a, b) with !Fail = a + b' "$gadir/main.mn" \
     && [ "$(grep -c 'with' "$gadir/main.mn")" = "3" ] \
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
  tcout=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-hole-is-a-term-cell.mn:24:38 2>"$dir/term-cell.err")
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
  # the line names the values it asks between and what the type admits rather
  # than asking for "a constraint" (the values since 2026-10-10: past three
  # members the question renders alone, and RED on boot d2bd58b4 it asked
  # "which one?" with no ones beside it).
  qv=$(cd "$fdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo" --dir /tmp "$compiler" bit.mn:8:30 2>/dev/null)
  if printf '%s' "$qv" | grep -q 'differ in VALUE — 0 or 1 — and the type admits 0 through 1'; then
    pass "computed question: value (the values asked between and the admitted domain, not a generic ask)"
  else
    fail "computed question: value (got: $(printf '%s' "$qv" | tail -2))"
  fi
  # ROW: `silent()` is Pure, `logged()` performs Log, and choose's declared
  # row admits both — so the fill decides what the program may DO, which
  # outranks every other distinction.
  qr=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-row-tie.mn:32:33 2>/dev/null)
  if printf '%s' "$qr" | grep -q 'differ in what they may DO — Pure against Log'; then
    pass "computed question: row (the capability split outranks name and value)"
  else
    fail "computed question: row (got: $(printf '%s' "$qr" | tail -2))"
  fi
  # NAME: pure_seven(), calm_seven() and the literal 7 all denote 7 — the
  # denotation walk follows a zero-arg call to its callee's body — so the
  # only real choice is which name carries the intent.
  qn=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-capability-tie.mn:17:38 2>/dev/null)
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
  qa=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-hole-row-absorbed.mn:16:21 2>/dev/null)
  if printf '%s' "$qa" | grep -q '4 proven survivors' && printf '%s' "$qa" | grep -q 'E against Pure' && ! printf '%s' "$qa" | grep -q 'refused eff_one'; then
    pass "hole row: a candidate performing what the enclosing ~> absorbs is proposed (the tie's question is the row split, E against Pure)"
  else
    fail "hole row absorbed (got: $(printf '%s' "$qa" | grep -E 'eff_one|Propose|against' | head -3 | tr '\n' ' '))"
  fi
  # ONE RENDERER FOR THE DEVELOPER'S EYE (render lane, 2026-10-06). `doc`
  # and `where` render every type through the formatter's projection with
  # free variables named by the render context: no forensic handle (`@e`),
  # no `_:` for a parameter nobody named, no `-> ()` on a unit result, and
  # no `WASI(a)` — the never type is quantified per perform, so an effect
  # with a `-> !` op carries no phantom parameter. RED on boot 4228ff71:
  # `doc` printed `Option : Option(t8090@e76)` and `unwrap : (opt:
  # Option(t11349@e7593) ref — inferred) -> … with Fail(t11349@e7593)`.
  rd=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" doc lib/prelude.mn 2>/dev/null)
  rf=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" where src/main.mn Filesystem 2>/dev/null)
  rr=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" where src/main.mn fmt_run 2>/dev/null)
  rall="$rd$rf$rr"
  if [[ -n "$rd" && -n "$rf" && -n "$rr" ]] && ! printf '%s' "$rall" | grep -qE '@e[0-9]|_: |-> \(\)( with [A-Za-z0-9_+!() ]*)?$|WASI\(a\)'; then
    pass "one renderer: doc and where print no handle, no _:, no -> () and no WASI(a)"
  else
    fail "one renderer (got: $(printf '%s' "$rall" | grep -E '@e[0-9]|_: |-> \(\)( with [A-Za-z0-9_+!() ]*)?$|WASI\(a\)' | head -3 | tr '\n' ' '))"
  fi
  # A PIPE STAGE IS PROPOSED BY REFERENCE, searched outward from the hole's
  # module (PROGRAM C3). Born RED 2026-09-25 on all three: `5 |> ??` offered
  # only the empty lambda skeleton — the vocabulary enumerated zero-argument
  # calls, never a function reference — so a stage hole could neither fill
  # nor ask a real question. The ring fixture is the search's own contract:
  # with no fitting function in the entry, the one its authored import
  # declares fills, and the prelude's `id` is never judged beside it. Since
  # T3 (2026-10-13) the rings are what the module sees — its own
  # declarations, its direct imports' and the prelude's — so helper's own
  # import deep, which declares a fitting `quadruple`, is never offered at
  # stage.mn: on boot c939f5b8 the imported ring was the transitive closure
  # and the two tied.
  qp=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-pipe-stage-hole.mn:14:25 2>/dev/null)
  qf=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-pipe-stage-fill.mn:9:25 2>/dev/null)
  ringdemo="$ROOT/tests/frontier/stage-ring-demo"
  qr=$(cd "$ringdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ringdemo" --dir /tmp "$compiler" stage.mn:12:25 2>/dev/null)
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
  qs=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-shape-tie.mn:20:31 2>/dev/null)
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
  qt=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-type-tie.mn:17:11 2>/dev/null)
  if printf '%s' "$qt" | grep -q 'differ in TYPE — Int against String'; then
    pass "computed question: type (the free cell the segments bound is the first divergence)"
  else
    fail "computed question: type (got: $(printf '%s' "$qt" | tail -2))"
  fi
  # THE CELL THAT MOVES IS THE CONTEXT'S, NOT THE HOLE'S (C6): `y + x` made
  # the hole's cell, the binder `y` and the parameter `x` one class, so a
  # survivor binds pick's own return; the question names that cell through
  # its Reason. RED on boot b1637650: a value question.
  qc=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." --dir /tmp "$compiler" tests/frontier/mn-cell-tie.mn:18:11 2>/dev/null)
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
  # THE TEACH BATTERY REFUSES A CONTRACT AT NO DECLARATION (Landing 3,
  # 2026-10-13): a `teach L: none` whose line L holds no declaration met the
  # view of whatever node the address resolved to, which teaches nothing, and
  # PASSED — a contract that drifted onto a blank line as its fixture's
  # comment grew went green on boot 1b59f63c. The battery reads the
  # declaration's name inside the judgment and refuses the line that has
  # none; this directory holds the one fixture that must FAIL.
  tbr_out=$(wt_run --dir . "$compiler" test tests/frontier/teach-battery-refuses 2>/dev/null)
  if printf '%s' "$tbr_out" | grep -q '^FAIL(teach) blank-line: no declaration at' \
     && ! printf '%s' "$tbr_out" | grep -q '^PASS'; then
    pass "teach battery refuses a contract at a line with no declaration"
  else
    fail "teach battery refuses a contract at no declaration (got: $(printf '%s' "$tbr_out" | head -2))"
  fi
  # THE ACCEPT WRITES WHAT THE GRADIENT PROVED (D4): `mentl accept` at a
  # declaration writes the Teaching's annotation into its head through the
  # formatter's head render, and the module re-judges with the debt gone —
  # a precondition (the division total, no pending claim). RED on boot 6f62b7c4: the
  # accept at a declaration answered "no proposal at this position". A
  # refinement over a parameter written `n: Int` replaces the written type,
  # and the head's census counts `Int` present as the base NonZero declares.
  tadir="$dir/teach-accept"
  rm -rf "$tadir"; mkdir -p "$tadir"
  cp "$ROOT/tests/teach/precondition-weakest.mn" "$tadir/pre.mn"
  cp "$ROOT/tests/teach/precondition-over-a-plain-type.mn" "$tadir/plain.mn"
  wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" accept pre.mn:12:1 > /dev/null 2>"$dir/teach-accept-pre.err"
  tapre=$?
  wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" accept plain.mn:8:1 > /dev/null 2>"$dir/teach-accept-plain.err"
  taplain=$?
  # The debt is the fixture's own. The file route's summary counts the
  # entry's own layer since 2026-10-12 (the user-link leg below holds it),
  # so a bare program's count over the same link is zero; it is still read
  # and subtracted, a no-op that keeps this leg honest should the summary
  # ever widen again. Any error counts outright.
  printf 'fn main() = 0\n' > "$tadir/bare.mn"
  ta_pending() { wt_run --dir "$tadir::." --dir "$ROOT::/mentl-home" "$compiler" compile "$1" 2>&1 >/dev/null \
    | awk '/ error/ {e++} /verification obligations pending/ {for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) p=$i} END {print (e+0) " " (p+0)}'; }
  read -r _ tabase <<<"$(ta_pending bare.mn)"
  tadebt=0
  for taf in pre.mn plain.mn; do
    read -r tae tap <<<"$(ta_pending "$taf")"
    tadebt=$((tadebt + tae + tap - tabase))
  done
  if [ "$tapre" = 0 ] && [ "$taplain" = 0 ] \
     && [ "$(sed -n 12p "$tadir/pre.mn")" = "fn inv(n: NonZero) = 100 / n" ] \
     && [ "$(sed -n 8p "$tadir/plain.mn")" = "fn inv(n: NonZero) = 100 / n" ] \
     && [ "$tadebt" = 0 ]; then
    pass "teach accept: a precondition and a refinement over a written Int written into their heads, the debt gone"
  else
    fail "teach accept (pre exit=$tapre line: $(sed -n 12p "$tadir/pre.mn"); plain exit=$taplain line: $(sed -n 8p "$tadir/plain.mn"); debt lines=$tadebt)"
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
  # ── the user's link is the user's (2026-10-12) ─────────────────────
  # A module's LAYER (User | Lib | Compiler) is read off the root that
  # resolved it and rides every report from its writer; on the file route
  # the register renders the modules of the entry's own layer and the debt
  # summary counts only them. RED on boot 454c3aaf: a clean program's check
  # printed the library's unresolved comment references (41 through main's
  # library, where lib/io.mn still imported src/types.mn; none through this
  # tree's), and a program owing ONE obligation reported the runtime
  # library's seventeen beside it (18). The fixtures are copied out so the
  # warm image a compile files under `.build/` never lands in the tree.
  uld="$dir/user-link"
  rm -rf "$uld"; mkdir -p "$uld"
  cp "$ROOT/tests/frontier/user-link/hello.mn" "$ROOT/tests/frontier/user-link/owes.mn" "$uld/"
  ulhello=$(wt_run --dir "$uld::." --dir "$ROOT::/mentl-home" "$compiler" check hello.mn 2>&1); ulrc=$?
  if [ "$ulrc" = 0 ] && [ -z "$ulhello" ]; then
    pass "user link: a clean program's check prints nothing (no library narration, no library debt)"
  else
    fail "user link hello (exit=$ulrc, $(printf '%s\n' "$ulhello" | grep -c .) line(s): $(printf '%s' "$ulhello" | head -1 | cut -c1-120))"
  fi
  ulowes=$(wt_run --dir "$uld::." --dir "$ROOT::/mentl-home" "$compiler" compile owes.mn 2>&1 >/dev/null); ulorc=$?
  ulpend=$(printf '%s\n' "$ulowes" | grep -c 'V_Pending' || true)
  ullines=$(printf '%s\n' "$ulowes" | grep -c . || true)
  if [ "$ulorc" = 0 ] && [ "$ulpend" = 1 ] && [ "$ullines" = 2 ] && printf '%s' "$ulowes" | grep -q ' 1 verification obligations pending at owes:'; then
    pass "user link: a program's debt summary counts its own obligation (1) and nothing of the library's"
  else
    fail "user link debt (exit=$ulorc V_Pending=$ulpend lines=$ullines: $(printf '%s' "$ulowes" | tail -1 | cut -c1-140))"
  fi
  # The shim's half: a path-shaped argument whose directory lies outside the
  # cwd is rewritten to its absolute form (a `:L:C` suffix kept), since the
  # guest opens it against the cwd preopen and WASI refuses `..` above it.
  # RED on the 454c3aaf shim: `mentl run ../owes.mn` was E_MissingModule.
  ulbin="$dir/user-link-bin"
  rm -rf "$ulbin"; mkdir -p "$ulbin/sub"
  MENTL_BIN_DIR="$ulbin" bash "$ROOT/tools/install.sh" >/dev/null 2>&1
  (cd "$ulbin/sub" && MENTL_BOOT="$compiler" "$ulbin/mentl" run ../../user-link/owes.mn >/dev/null 2>"$dir/user-link-shim.err"); ulsrc=$?
  if [ "$ulsrc" = 20 ]; then
    pass "user link: the shim runs a program above the cwd (\`mentl run ../owes.mn\` exits 20)"
  else
    fail "user link shim (exit=$ulsrc: $(grep -v '^verify:' "$dir/user-link-shim.err" | head -1 | cut -c1-140))"
  fi
  # Two spellings of one file — sub/c from the entry, c from its sibling in
  # sub/ — are one module (the walk keys the path it resolved, and a user
  # module's own folder is its first root), and one name spelling two files
  # — the program's lists.mn and the library's — is two: a module is a node
  # of the link, its imports edges to nodes. RED on boot 037aea22: the
  # library's `lists` was matched by name to the program's, E_MissingImport.
  cp -r "$ROOT/tests/frontier/user-link/nest" "$uld/"
  (cd "$uld" && MENTL_BOOT="$compiler" "$ulbin/mentl" run nest/a.mn >/dev/null 2>"$dir/user-link-nest.err"); ulnrc=$?
  if [ "$ulnrc" = 20 ] && ! grep -qv '^verify:' "$dir/user-link-nest.err"; then
    pass "user link: one file two spellings is one module, one name two files is two (nest/a.mn exits 20, silent)"
  else
    fail "user link nest (exit=$ulnrc: $(grep -v '^verify:' "$dir/user-link-nest.err" | head -1 | cut -c1-140))"
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
  fwd_count=$(printf '%s' "$fwd_out" | grep -Fc 'E_TypeMismatch error: (Int, String) vs [Byte]' || true)
  if [ "$fwd_rc" -ne 0 ] && [ "$fwd_count" -ge 1 ]; then
    pass "check-forward-order (the DAG path judges converged: forward tuple-into-[String] refuses)"
  else
    fail "check-forward-order (exit=$fwd_rc mismatches=$fwd_count — the forward-ref seam is open)"
  fi
  # ── a refusal names its cause (Landing 2, 2026-10-13) ───────────────
  # `fn quiet(x) with !WASI = helper(x)` reaches the host three calls down.
  # The refusal at the declaration carries the chain of sites the effect
  # enters through — helper, log_it, print_string, the library's write — read
  # off the charge every node notes, down to the op of WASI it ends at; and
  # `why quiet WASI` answers the same chain. RED on boot 6e35c6db: the message
  # ended at `declared as quiet` and the why verb ignored its third word.
  ent_out=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" check tests/frontier/mn-effect-enters.mn 2>&1)
  ent_rc=$?
  ent_why=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" query tests/frontier/mn-effect-enters.mn "why quiet WASI" 2>/dev/null)
  if [ "$ent_rc" -ne 0 ] \
     && printf '%s' "$ent_out" | grep -q 'quiet uses WASI: quiet calls `helper` at [a-z/-]*mn-effect-enters:20:[0-9]* → helper calls `log_it` at [a-z/-]*mn-effect-enters:16:[0-9]* → log_it calls `print_string` at [a-z/-]*mn-effect-enters:13:[0-9]* → print_string calls `fd_write_bytes` at io:' \
     && printf '%s' "$ent_out" | grep -q '`fd_write` is an operation of WASI, declared at io:' \
     && printf '%s' "$ent_why" | grep -q 'quiet uses WASI: quiet calls `helper` at [a-z/-]*mn-effect-enters:20:[0-9]*' \
     && printf '%s' "$ent_why" | grep -q 'is an operation of WASI, declared at'; then
    pass "effect-enters (the refusal's chain runs helper → log_it → print_string to the op of WASI, and why quiet WASI answers it)"
  else
    fail "effect-enters (exit=$ent_rc: $(printf '%s' "$ent_out" | grep -F 'E_EffectMismatch' | head -1 | cut -c1-200))"
  fi
  # An effect an install ABSORBS enters through the install: `quiet` declares
  # `!Log` over `work() ~> relog`, relog answers every `log` the body performs
  # and its own arm performs `log` again (resolving outside the install), so
  # the chain names the tee and relog's arm, never work's absorbed `log("a")`.
  # RED on boot 53213e36 (Landing 4 S1, 2026-10-13): the walk descended into
  # the tee's body because the body's note carried Log and answered
  # `through \`work\``.
  abs_out=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" check tests/frontier/mn-effect-enters-absorbed.mn 2>&1)
  abs_rc=$?
  abs_why=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" query tests/frontier/mn-effect-enters-absorbed.mn "why quiet Log" 2>/dev/null)
  if [ "$abs_rc" -ne 0 ] \
     && printf '%s' "$abs_out" | grep -q 'quiet uses Log: quiet installs `relog` at [a-z/-]*mn-effect-enters-absorbed:30:[0-9]* → relog calls `log` at [a-z/-]*mn-effect-enters-absorbed:16:[0-9]* → `log` is an operation of Log' \
     && ! printf '%s' "$abs_out" | grep -q 'calls `work`' \
     && printf '%s' "$abs_why" | grep -q 'installs `relog` at [a-z/-]*mn-effect-enters-absorbed:30:[0-9]* → relog calls `log` at [a-z/-]*mn-effect-enters-absorbed:16:[0-9]*' \
     && ! printf '%s' "$abs_why" | grep -q 'calls `work`'; then
    pass "effect-enters-absorbed (an absorbed effect enters through the install's arm, never the body it absorbs from)"
  else
    fail "effect-enters-absorbed (exit=$abs_rc: $(printf '%s' "$abs_out" | grep -F 'E_EffectMismatch' | head -1 | cut -c1-240))"
  fi
  # `!Mutate` refuses naming the store, through calls and through a partial handed to a callee (clean on boot 65e2f966).
  mut_out=$(cd "$ROOT" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp "$compiler" check tests/frontier/mn-mutate-enters.mn 2>&1)
  if printf '%s' "$mut_out" | grep -q 'relayed uses Mutate: relayed calls `relay` at [a-z/-]*mn-mutate-enters:12:[0-9]* → relay calls `fill` at [a-z/-]*mn-mutate-enters:8:[0-9]* → fill calls `list_set` at [a-z/-]*mn-mutate-enters:6:[0-9]* → at lists:[0-9:]*, `store_i32`, a store into memory older' \
     && printf '%s' "$mut_out" | grep -q 'handed uses Mutate: handed calls `apply` at [a-z/-]*mn-mutate-enters:14:[0-9]* → apply calls `fill` at [a-z/-]*mn-mutate-enters:14:[0-9]*'; then pass "mutate-enters (each !Mutate refusal names the store)"; else fail "mutate-enters ($(printf '%s' "$mut_out" | grep -F 'E_EffectMismatch' | head -1 | cut -c1-240))"; fi
  # ── the installed command keeps a path under the cwd as written ──────
  # The shim hands a path OUTSIDE the cwd to the guest absolute (a `..`
  # above the cwd preopen is refused), and a path under the cwd as the
  # developer spelled it, because the spelling is the module's identity:
  # `src/main.mn` is the compiler's own main, whose imports reach `src/`;
  # the same file spelled absolute is a user module whose imports probe its
  # own folder and the library, so src/backends/wasm.mn never reaches
  # src/types.mn. RED on the Landing 1 shim (2026-10-13): its test read "the
  # directory IS the cwd, or /tmp itself", every path in a subdirectory went
  # absolute, and `mentl check src/main.mn` from the repo root refused with
  # E_MissingModule for types.
  # The shim under test is installed from THIS tree into a bin of its own.
  shim_dir="$dir/shim-bin"
  rm -rf "$shim_dir"
  if MENTL_BIN_DIR="$shim_dir" bash "$ROOT/tools/install.sh" > "$dir/shim-install.out" 2>&1 \
     && shim_out=$(cd "$ROOT" && MENTL_BOOT="$compiler" "$shim_dir/mentl" check src/main.mn 2>&1) \
     && [ -z "$(printf '%s\n' "$shim_out" | grep -v '^verify: ')" ]; then
    pass "shim-path-under-cwd (the installed command checks src/main.mn from the repo root through the compiler's own layer)"
  else
    fail "shim-path-under-cwd ($(printf '%s' "$shim_out" | head -1 | cut -c1-160))"
  fi
  # ── the session on stdin (E2) — the resident graph, ONE transport ────
  # The host owns the process's input — a browser worker's channel, the
  # mentl command's pipe — and the session answers one line per verb, the
  # answer written whole before the next line is read; a verb it does not
  # serve, and a verb that refuses (its reason is stderr, its verdict the
  # exit code, and the wire carries neither), answers the MISS sentinel so
  # the cold route says it whole. The oracle is the cold verb byte for
  # byte, then the refusal's MISS. RED on boot 713745c6: without a listener
  # the verb refused. The listener it once served (a socket the host
  # preopened; `-S tcplisten=`) is gone with the socket seam, 2026-10-05.
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
  # One session, three lines on its stdin: a read of the hole, the accept,
  # the same read again. The session draws the accept into the graph it
  # keeps, so the next read of the position walks to the proposal — where a
  # cold accept drew it in a process that ended with the reply. RED on boot
  # 713745c6: the accept answered MISS, the cold accept wrote `1`, and the
  # next read said "Why: int literal". The first read must NOT walk to a
  # proposal (nothing has been accepted), so exactly one answer does.
  acdir="$dir/session-accept"
  rm -rf "$acdir"
  mkdir -p "$acdir"
  printf 'type Positive = Int where 0 < self\n\nfn choose() -> Positive = ??\n\nfn main() = choose()\n' > "$acdir/main.mn"
  printf 'main.mn:3:27\naccept\tmain.mn:3:27\nmain.mn:3:27\n' \
    | (cd "$acdir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$acdir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" session) \
      > "$acdir/answers.txt" 2> "$acdir/session.log"
  # Three answers, each opening with its Query line: the first read must not
  # walk to a proposal, the accept answers with the projection of the
  # accepted position exactly as the cold `mentl accept` does (its Why walks
  # to the proposal already), and the third read walks to it again off the
  # graph the session kept. RED on the first stock-engine march (2026-10-05):
  # this leg counted ONE accepted Why across all three answers and the accept's
  # own answer made it two — the contract was the leg's, not the wheel's.
  if awk '/^Query:/{n++} n==1 && /^Why: accepted/{bad=1} n==3 && /^Why: accepted `1` — proposed/{ok=1} END{exit !(ok && !bad)}' "$acdir/answers.txt" \
     && grep -q 'fn choose() -> Positive = 1$' "$acdir/main.mn"; then
    pass "session accept: the next read walks to the proposal"
  else
    fail "session accept (see $acdir/answers.txt and $acdir/session.log)"
  fi
  # ── an edit between two reads re-judges what it rewrote ────────────
  # The edit keeps `width`, adds `triple` and rewrites `main`, so the session
  # judges two declarations again, and its reports after the edit are the
  # cold verb's over the edited tree. RED on boot 6aaec713: the session read
  # the whole module again, and `reports` was no facet.
  eddir="$dir/session-edit"
  rm -rf "$eddir"; mkdir -p "$eddir"; mkfifo "$eddir/in"
  printf 'fn width(n) = n + 2\n\nfn main() = width(40)\n' > "$eddir/main.mn"
  (cd "$eddir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$eddir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" session < in > out.txt 2> err.log) &
  ed_srv=$!
  exec 8> "$eddir/in"
  ed_wait() { for _i in $(seq 1 150); do [ "$(grep -c '^→ ' "$eddir/out.txt")" -ge "$1" ] && return 0; sleep 0.2; done; return 1; }
  printf 'query\tmain\treports\n' >&8; ed_wait 1
  printf 'fn width(n) = n + 2\n\nfn triple(x) = x * 3\n\nfn main() = triple(true) + width(40)\n' > "$eddir/main.mn"
  printf 'query\tmain\treports\n' >&8; ed_wait 2
  exec 8>&-; wait $ed_srv 2>/dev/null
  (cd "$eddir" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$eddir::." --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query main.mn reports 2>/dev/null) > "$eddir/want.txt"
  if grep -q 'tree moved — re-judged 2 declaration(s) in 1 module(s)' "$eddir/err.log" \
     && tail -n +2 "$eddir/out.txt" | sort | cmp -s - <(sort "$eddir/want.txt"); then
    pass "session edit: two declarations judged again, the reports the cold verb's"
  else
    fail "session edit (see $eddir/out.txt, $eddir/want.txt and $eddir/err.log)"
  fi
  # `mentl space` is the page — static files the mentl command stages and
  # serves (tools/space-stage.sh, tools/space-serve.py) — and its gate is
  # tools/ide-gate.sh's leg 2 over the staged artifact; the wheel serves no
  # socket since 2026-10-05.
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
  # TWO errors, re-derived by hand (§9.11): `fn bad() with !E = op()` with
  # no handler anywhere violates its own declared `!E` (E_EffectMismatch)
  # AND lets E reach the executable root unhandled (E_EffectUnhandled), and
  # every error refuses.
  if grep -q 'REFUSED — 2 error' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectMismatch' "$mcp_dir/out.jsonl" \
     && grep -q 'at <stdin>:3:1' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectUnhandled' "$mcp_dir/out.jsonl"; then
    pass "mcp propose REFUSES with file-local teaching spans"
  else
    fail "mcp refusal verdict (see $mcp_dir/out.jsonl)"
  fi
  if grep -q 'PROVEN — every claim in the program is proven' "$mcp_dir/out.jsonl" \
     && [ -s "$mcp_dir/.build/mcp/last.wat" ]; then
    pass "mcp propose PROVES and the artifact lands"
  else
    fail "mcp proven verdict + artifact (see $mcp_dir/out.jsonl)"
  fi
  if grep -q '"isError":true' "$mcp_dir/out.jsonl" \
     && grep -q '"code":-32601' "$mcp_dir/out.jsonl" \
     && grep -q '"id":7,"result":{}' "$mcp_dir/out.jsonl"; then
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
  # main declares `with Pure` since T2 (2026-10-13), so its clause is what
  # stands on `double` and the teach read answers `→ add` for it; a lock
  # nothing stands on is no longer taught.
  printf 'fn double(x) = x * 2\n\nfn main() with Pure = double(21)\n' > "$ses_dir/main.mn"
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
     && grep -q 'own x: Int' "$ses_dir/out.jsonl" \
     && grep -q 'declared as main' "$ses_dir/out.jsonl" \
     && grep -q 'Query: fn double' "$ses_dir/out.jsonl" \
     && grep -q 'double performs no effect (Pure)' "$ses_dir/out.jsonl" \
     && grep -q 'Nothing in this module uses Alloc' "$ses_dir/out.jsonl" \
     && grep -qE 'annotation density|→ add' "$ses_dir/out.jsonl" \
     && ! grep -qE 'iterate (uses|performs) ' "$ses_dir/out.jsonl" \
     && grep -q 'PROVEN — every claim in the program is proven' "$ses_dir/out.jsonl"; then
    pass "resident session: one derivation, live query + at + audit + teach reads, propose coexists"
  else
    fail "resident session (resident-lines=$(grep -c 'session: graph resident' "$ses_dir/err.log"); see $ses_dir/out.jsonl)"
  fi
  # ── the FRONTIER READ (rung 5): the oracle's field as a session tool ─
  # The ranked absence field over the resident graph — the gradient's
  # argmax uncollapsed, the same read `mentl main.mn:0` serves: the hole at
  # its own address with its fan (the let `w` and the parameter `n` in scope
  # join the three literal seeds), and a gradient tier scoped to the real fn
  # declarations; main declares `!Alloc`, so the tier holds width and banner.
  fro_dir="$dir/mcp-frontier"
  mkdir -p "$fro_dir"
  printf 'fn width(x) = x * 2\n\nfn banner(n) = {\n  let w = width(n)\n  w + ??\n}\n\nfn main() with !Alloc = banner(21)\n' > "$fro_dir/main.mn"
  printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}\n{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"frontier","arguments":{}}}\n' \
    | "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fro_dir::." "$compiler" mcp >"$fro_dir/out.jsonl" 2>"$fro_dir/err.log"
  if grep -q '"name":"frontier"' "$fro_dir/out.jsonl" \
     && grep -q 'Field: 1 hole(s), 0 pending proof(s), 0 tightening(s), 2 gradient position(s)' "$fro_dir/out.jsonl" \
     && grep -q 'main:5:7' "$fro_dir/out.jsonl" \
     && grep -q 'Query: ?? : Int' "$fro_dir/out.jsonl" \
     && grep -q 'Propose: 5 proven survivors' "$fro_dir/out.jsonl" && grep -q 'values in scope here — w or n' "$fro_dir/out.jsonl"; then
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
  printf 'type Pos = Int where 0 < self\n\nfn scaled(x) -> Pos = x * 3\n\nfn noisy() with IO = 7\n\nfn main() with !Alloc = scaled(2) + noisy() + ??\n' > "$prob_dir/main.mn"
  mkfifo "$prob_dir/in"
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$prob_dir::." "$compiler" mcp \
    < "$prob_dir/in" >"$prob_dir/out.jsonl" 2>"$prob_dir/err.log" &
  prob_srv=$!
  exec 9> "$prob_dir/in"
  prob_wait() { for _i in $(seq 1 150); do [ "$(wc -l < "$prob_dir/out.jsonl")" -ge "$1" ] && return 0; sleep 0.2; done; return 1; }
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}' >&9
  printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"frontier","arguments":{}}}' >&9
  prob_wait 2 || true
  printf 'type Pos = Int where 0 < self\n\nfn scaled(x) -> Pos = x * 3\n\nfn noisy() = 7\n\nfn main() with !Alloc = scaled(2) + noisy() + ??\n' > "$prob_dir/main.mn"
  printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"frontier","arguments":{}}}' >&9
  prob_wait 3 || true
  exec 9>&-
  wait $prob_srv 2>/dev/null
  # id 2 counts ONE gradient position since T2 (2026-10-13), re-derived by
  # hand: `scaled`'s need (its parameter must make 0 < self hold); `noisy`
  # declares `with IO` over a pure body, so its teach is the TIGHTENING the
  # field lists in its own tier, and main authors a clause. After the edit
  # removes noisy's row, main's `!Alloc` stands on noisy and the lock appears
  # as a second gradient position — the living frontier in both directions.
  if grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Field: 1 hole(s), 1 pending proof(s), 1 tightening(s), 1 gradient position(s)' \
     && grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Pending: 0 < self' \
     && grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Tighten: noisy declares IO — the body proves Pure' \
     && grep '"id":3' "$prob_dir/out.jsonl" | grep -q 'Field: 1 hole(s), 1 pending proof(s), 0 tightening(s), 2 gradient position(s)' \
     && grep '"id":3' "$prob_dir/out.jsonl" | grep -q 'add `with !Alloc`.*`main` stands on it' \
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
  # a line that did not exist before the edit. The staleness check is a
  # pure read (driver_manifest) — no discovery, no parse, no graph write.
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
     && grep -q 'triple performs no effect (Pure)' "$liv_dir/out.jsonl" \
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
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" tests/frontier/mn-ranker-local-intent.mn:14:24 >"$dir/ranker.out" 2>/dev/null
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
  # Instance-arg TYPING against the registered signature (the TTuple
  # scheme register_effect_ops publishes): a scalar-literal arg whose
  # ground type disagrees reports the mismatch and the head parses clean
  # (no P_ beside it). The other faces are their fixtures' contracts.
  wt_entry "$ROOT/tests/frontier/mn-effect-instance-argty.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > /dev/null 2> "$dir/inst-argty.err"
  if grep -q 'E_TypeMismatch' "$dir/inst-argty.err" && ! grep -q 'P_' "$dir/inst-argty.err"; then
    pass "instance arg typing (wrong scalar type reports; the head parses clean)"
  else
    fail "instance argty (see $dir/inst-argty.err)"
  fi
  # ── the splice line carry ──────────────────────────────────────────
  # A splice spanning newlines resumes the outer string scan at the TRUE
  # line, so nodes after it keep truthful spans and the address resolves
  # to the decl, never the module placeholder. Seen RED on the stale-line
  # boot: the whole fixture module answered `placeholder`.
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" tests/frontier/mn-splice-line-carry.mn:13:31 >"$dir/splice-carry.out" 2>/dev/null
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
  wt_entry "$ROOT/tests/frontier/mn-hof-row-gate-noisy.mn" "${RTLIBS[@]}" io | wt_rooted "$compiler" > "$dir/hof-gate-noisy.wat" 2> "$dir/hof-gate-noisy.err"
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
  wt_entry "$ROOT/tests/frontier/mn-persist-branch-external.mn" "${PERSIST_RTLIBS[@]}" | wt_rooted "$compiler" > /dev/null 2> "$dir/pb-ext.err"
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
  wt_entry "$ROOT/tests/frontier/mn-own-across-replay.mn" "${PERSIST_RTLIBS[@]}" | wt_rooted "$compiler" > "$dir/pb-own.wat" 2> "$dir/pb-own.err" \
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
  it_fire=$(printf '%s' "$it_audit" | sed -n '/^walk_costume/,/^stage_clean/p' | grep -c 'could be a fold, each or iterate stage')
  it_quiet=$(printf '%s' "$it_audit" | sed -n '/^stage_clean/,/^main/p' | grep -c 'could be a fold, each or iterate stage')
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
  an_eta=$(printf '%s' "$an_audit" | sed -n '/^wraps/,/^ticks/p' | grep -c 'only wrap a call to a named function')
  an_rowed=$(printf '%s' "$an_audit" | sed -n '/^ticks/,/^pure_vocab/p' | grep -c 'have effects, and a named function')
  an_quiet=$(printf '%s' "$an_audit" | sed -n '/^pure_vocab/,/^main/p' | grep -c 'could name its function values')
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
  printf '%s' "$w_head" | grep -q '^→ ticks(own x: Int) -> Int with Tick  at .*mn-where-badges:11$' || { w_ok=0; fail "where head with its inferred row and address (got: $w_head)"; }
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
  printf '%s' "$w_hand" | grep -q '^→ handler ticker absorbs Tick, answers a  at .*mn-where-badges:29$' || { w_ok=0; fail "where handler declaration (got: $w_hand)"; }
  w_zero=$(wt_run --dir "$ROOT" "$compiler" where "$ROOT/tests/micros/mn-refine-install-answer.mn" zero 2>/dev/null)
  printf '%s' "$w_zero" | grep -q '^→ handler zero absorbs Ask, answers Int  at .*mn-refine-install-answer:12$' || { w_ok=0; fail "where handler answer (got: $w_zero)"; }
  # The install's refusal carries the reason its unify was asked with — the
  # mismatch reporter had taken the reason and dropped it — so a body and an
  # arm disagreeing names the arm: `Int vs [Byte] — ~> pipe → at 15:…:
  # inferred from the arm bail of handler h`. RED on cf8a6d50 (compiled clean).
  w_arm=$(wt_run --dir "$ROOT" "$compiler" check "$ROOT/tests/micros/mn-arm-answer-is-the-install.mn" 2>&1 >/dev/null)
  printf '%s' "$w_arm" | grep -q 'E_TypeMismatch error: Int vs \[Byte\] — ~> pipe → at 15:[0-9]*-15:[0-9]*: inferred from the arm bail of handler h at' || { w_ok=0; fail "install refusal names the arm (got: $w_arm)"; }
  # B4 (2026-09-30): a fanout site reports the schedules its CALLERS demand
  # of it through direct calls — `shared`'s own frame installs none (Seq),
  # and `twice` calls it under `parallel_compose`, so its site runs threaded
  # there; the badge says both, read off the one fanout-reach rule the emit
  # demands twins by. RED on boot 6f2ce437 (the badge knew only the frame).
  w_dem=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" shared 2>/dev/null)
  printf '%s' "$w_dem" | grep -q '>< \[Seq ×2; Thread demanded via twice\] at' || { w_ok=0; fail "where demanded-schedule badge (got: $w_dem)"; }
  # L-C (2026-10-06): a function's address and body are its own module-level
  # declaration's, never a block-level `let` that shares its name. The decls
  # column holds both, and the address was the first of either: RED on boot
  # d956687d, which put `heads` at line 6, the local in `one` (judged first,
  # since `heads` calls it); the function stands at line 10.
  w_shadow=$(wt_run --dir "$ROOT" "$compiler" where "$ROOT/tests/frontier/mn-where-shadowed-local.mn" heads 2>/dev/null)
  printf '%s' "$w_shadow" | grep -q '^→ heads(ref xs: \[a\]) -> Int with Memory  at .*mn-where-shadowed-local:11$' || { w_ok=0; fail "where address of a function a local shares its name with (got: $w_shadow)"; }
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
  printf '%s' "$wy_out" | grep -q 'mn-where-badges:9' && wy_file_ok=1
  judge why-coordinates "$wy_file_ok" \
    "why coordinates carry their file (line half fixed; file half is Hβ.why.reason-span-is-a-weave-coordinate) (got: $wy_out)"
  # The capability-at-tee badge (§11 6.3's felt face): the install line
  # names the handler and the effect set its arms absorb, from the
  # graph's own facts. Born RED 2026-08-08 (the boot lacked the facet).
  w_tee=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" handled 2>/dev/null)
  printf '%s' "$w_tee" | grep -q '~> ticker absorbs Tick, answers Int at' || { w_ok=0; fail "where tee badge (got: $w_tee)"; }
  [ "$w_ok" = 1 ] && pass "where: repr, cardinality, schedule with width, tee, head, parameter and local badges narrate (output, never input)"

  # ─── The lambda list-pattern parameter (PLAN §11 Phase 3.3) ─────────
  # A list pattern with a rest as a literal's parameter parses, checks clean AND RUNS to 7. The leg gated the
  # check alone (G2): the run half's peer (Hβ.lower.list-rest-binding-runtime)
  # closed and the leg never learned, so a regression in the binding would
  # have stayed green.
  lp_chk=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-lambda-list-param.mn" 2>&1)
  lp_n=$(printf '%s' "$lp_chk" | grep -cE 'P_(Unexpected|Expected)Token|E_.* error')
  lp_dir="$dir/lambda-list-param"
  mkdir -p "$lp_dir"
  lp_rc=x
  if wt_run --dir "$ROOT" "$compiler" compile "$ROOT/tests/frontier/mn-lambda-list-param.mn" > "$lp_dir/lp.wat" 2> "$lp_dir/lp.err" \
     && wt_asm "$lp_dir/lp.wat" "$lp_dir/lp.wasm" 2>> "$lp_dir/lp.err"; then
    "$WT" run "${WT_RUN_FLAGS[@]}" "$lp_dir/lp.wasm" > /dev/null 2>> "$lp_dir/lp.err"
    lp_rc=$?
  fi
  if [ "$lp_n" = "0" ] && [ "$lp_rc" = "7" ]; then
    pass "lambda list-pattern param: { [h, ...t] => h } parses, checks clean and runs to 7"
  else
    fail "lambda list-pattern param ($lp_n diagnostics, exit $lp_rc, want 0 and 7; see $lp_dir)"
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
  # `query <fixture> "decls"` projects the decls COLUMN: every name the
  # judged declarations declare, beside its declaration's site. Born RED
  # 2026-08-07: the incumbent boot answered "error: unknown query: decls".
  # Each of the fixture's three decls (lines 7/9/11) is listed ONCE, by
  # name at its line — the retired whole-handle NBound walk seeded every
  # fn-typed MENTION beside its decl, and the roster before 2026-10-06
  # answered addresses alone, so it could not say what it listed.
  df_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-decls-facet.mn" "decls" 2>/dev/null)
  df_once() { [ "$(printf '%s\n' "$df_out" | grep -cE "^  $1  at .*mn-decls-facet:$2:")" = 1 ]; }
  if printf '%s' "$df_out" | grep -q "declared name(s)" && df_once inc 8 && df_once twice 10 && df_once main 12; then
    pass "decls facet: each of the fixture's three decls listed once, by name at its line (8/10/12)"
  else
    fail "decls facet (each decl once, by name at its line; got: $(printf '%s' "$df_out" | grep -E 'declared name|mn-decls-facet' | tr '\n' ' '))"
  fi

  # ─── refs of follows the reference edge (M1, Hβ.lower.reach-edge-on-node)
  # A reference is linked to the declaration it resolved to, at the one
  # writer, and `refs of` reads the declaration's in-edges. The fixture's
  # function `width` is called twice on line 7; `shadowed` binds a `let
  # width` of its own and reads it on line 11, which is no reference to the
  # function. Born RED 2026-10-14: boot 16d5706e answered 3 references, the
  # local read among them, because the refs column was keyed by the name.
  re_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-refs-by-edge.mn" "refs of width" 2>/dev/null)
  if printf '%s' "$re_out" | grep -q "^→ 2 reference(s)" \
     && [ "$(printf '%s\n' "$re_out" | grep -cE "mn-refs-by-edge:8:[0-9]+-8:[0-9]+  call")" = 2 ] \
     && ! printf '%s' "$re_out" | grep -q "mn-refs-by-edge:12:"; then
    pass "refs by edge: the function's two calls (line 8), never the shadowing local's read (line 12)"
  else
    fail "refs by edge (want the 2 calls on line 8 and nothing on line 12; got: $(printf '%s' "$re_out" | tr '\n' ' '))"
  fi

  # ─── The imports facet reads the references that cross an import ────
  # An import is used when a reference standing in the importing module
  # links to a declaration the imported one makes. The fixture's entry reads
  # consts.mn's module value and nothing of unused.mn. Born RED 2026-10-14:
  # boots 16d5706e and 259f244e both answered the consts edge DEAD, since a
  # module value `let` was no declaration to the facet (PLAN §7's canon
  # finding, `Hβ.query.facets-read-the-link`).
  ie_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/imports-by-edge/main.mn" "imports" 2>/dev/null)
  if printf '%s' "$ie_out" | grep -qE "^ *used +.*imports-by-edge/main -> import consts" \
     && printf '%s' "$ie_out" | grep -qE "^ *DEAD +.*imports-by-edge/main -> import unused"; then
    pass "imports by edge: the module value's import used, the unreferenced module's DEAD"
  else
    fail "imports by edge (want consts used, unused DEAD; got: $(printf '%s' "$ie_out" | grep 'imports-by-edge/main ->' | tr '\n' ' '))"
  fi

  # ─── The reading facets: text, prose, writes of, reads of ───────────
  # What a program SAYS, WRITES and READS, asked of one fixture: the string
  # literal holding facet-literal-marker, the comment holding
  # facet-prose-marker (sited at its line, 4), the two values written
  # into the counter's state (its init, its update), and the one read of
  # the record field width (in area). The first and third were built with
  # no gate; the second was confessed as a verb gap four times in a day,
  # the fourth once (2026-10-13, when a record lost a field and its readers
  # were found by a shell search — a field is no declaration, so `refs of`
  # never reaches it). Born RED 2026-10-03: the boot answered "unknown
  # query" to the first three; boot c939f5b8 answered it to the fourth.
  rf_doc="$ROOT/tests/frontier/mn-reading-facets.mn"
  rf_text=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "text facet-literal-marker" 2>/dev/null)
  rf_prose=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "prose facet-prose-marker" 2>/dev/null)
  rf_writes=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "writes of sum" 2>/dev/null)
  rf_reads=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$rf_doc" "reads of width" 2>/dev/null)
  if printf '%s' "$rf_text" | grep -q "1 string literal(s)" && printf '%s' "$rf_text" | grep -q "mn-reading-facets:21" \
     && printf '%s' "$rf_prose" | grep -q "1 comment(s)" && printf '%s' "$rf_prose" | grep -q "mn-reading-facets:5:" \
     && printf '%s' "$rf_writes" | grep -q "counter.sum: 2 write(s)" && printf '%s' "$rf_writes" | grep -q "sum + n" \
     && printf '%s' "$rf_reads" | grep -q "1 read(s) of the field" && printf '%s' "$rf_reads" | grep -q "mn-reading-facets:25:"; then
    pass "reading facets: text (the literal at 20), prose (the comment line at 4), writes of (init and update), reads of (the field read at 24)"
  else
    fail "reading facets (text: $(printf '%s' "$rf_text" | head -1) · prose: $(printf '%s' "$rf_prose" | head -1) · writes: $(printf '%s' "$rf_writes" | head -1) · reads: $(printf '%s' "$rf_reads" | head -1))"
  fi

  # ─── Information flow (PLAN §4⑥): a label is an effect op over `self`
  # and a sink's demand is its absence. Each tests/micros/mn-flow-*
  # fixture's second line is its contract at the sink — `flow: refused at
  # L…` names every line a claim refuses at, `flow: proven` says none
  # refuses and none is owed — and the facet says what a source answers and
  # what an endorsement states. Seen RED on boot cb12aeea: every claim was
  # pending debt.
  fl_bad=""
  for fx in "$ROOT"/tests/micros/mn-flow-*.mn; do
    fl_want=$(sed -n 2p "$fx")
    fl_got=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$fx" 2>&1 >/dev/null | grep "E_RefinementRejected" | sed -n 's/.* at [^ ]*:\([0-9]*\):[0-9]*-[0-9]*:[0-9]*$/\1/p' | sort -n | tr '\n' ' ' | sed 's/ $//')
    fl_owed=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$fx" verification 2>/dev/null | grep -c "$(basename "$fx" .mn):" || true)
    case "$fl_want" in
      "// flow: proven") { [ -z "$fl_got" ] && [ "$fl_owed" -eq 0 ]; } || fl_bad="$fl_bad $(basename "$fx")" ;;
      *) [ "$fl_got" = "$(printf '%s' "${fl_want#// flow: refused at }" | tr ' ' '\n' | sort -n | tr '\n' ' ' | sed 's/ $//')" ] || fl_bad="$fl_bad $(basename "$fx")" ;;
    esac
  done
  fl_src=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/micros/mn-flow-explicit.mn" "flow of read_cmd" 2>/dev/null)
  fl_end=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/micros/mn-flow-endorse.mn" "flow of quote" 2>/dev/null)
  if [ -z "$fl_bad" ] && printf '%s' "$fl_src" | grep -q "answers untrusted" && printf '%s' "$fl_end" | grep -q "endorses"; then
    pass "information flow: every mn-flow contract holds at its sink; the facet names a source and an endorsement"
  else
    fail "information flow (broken:${fl_bad:- none} · source: $(printf '%s' "$fl_src" | tail -1) · endorse: $(printf '%s' "$fl_end" | tail -1))"
  fi

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

  # ─── The contradiction is INSTANCE-PRECISE: `Flow(1, Store) + !Flow(1, Wasi)` names two provably
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
  # '^import'). It reads the link node's own modules, so the count is
  # the judged set, not a re-walk of the filesystem. Born RED 2026-08-17
  # (the prior boot answered unknown-query). The fixture imports nothing
  # of its own, so the answer is the prelude floor plus itself, and the
  # named members pin that it is the real set and not a bare number.
  md_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-usage-grade.mn" "modules" 2>/dev/null)
  if printf '%s' "$md_out" | grep -q "module(s) in the link" \
     && printf '%s' "$md_out" | grep -q "prelude" \
     && printf '%s' "$md_out" | grep -q "threading"; then
    pass "modules facet: the link's module set projects ($(printf '%s' "$md_out" | grep -o '[0-9]* module(s)' | head -1))"
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

  # ─── The cost facet, and the prelude floor it makes a contract: the nodes
  # the medium mints to judge a bare `fn main() = 7`-class module — the
  # prelude vocabulary it processes to answer nothing. A count of nodes is
  # the same every run and moves with what the judgment does, never with the
  # layout the formatter projects; it may only FALL, and a landing that
  # raises it pays it down in the modules a bare program links. The ceiling
  # is `prelude_floor_nodes_max` in tools/verify-baseline.txt, where the
  # obey gate refuses a raise.
  cost_ceiling=$(grep -E '^prelude_floor_nodes_max:' "$ROOT/tools/verify-baseline.txt" | head -1 | cut -d: -f2 | tr -d ' ')
  ct_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" query "$ROOT/tests/frontier/mn-bare-floor.mn" "cost" 2>/dev/null)
  ct_nodes=$(printf '%s' "$ct_out" | grep -o '[0-9]* node(s) minted' | grep -o '[0-9]*' | head -1)
  if [ -n "$ct_nodes" ] && [ "$ct_nodes" -le "$cost_ceiling" ]; then
    pass "cost facet + prelude floor: $ct_nodes node(s) minted within the $cost_ceiling ceiling (monotone DOWN)"
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
  lw_a=$(grep -cE '\(func \$[^ ]*\.alpha ' "$dir/reach-library.wat")
  lw_b=$(grep -cE '\(func \$[^ ]*\.beta ' "$dir/reach-library.wat")
  if [ "$lw_a" -ge 1 ] && [ "$lw_b" -ge 1 ]; then
    pass "relocation library pin: a no-main module emits whole (alpha + unreferenced beta)"
  else
    fail "relocation library pin (alpha=$lw_a beta=$lw_b — a library decl went missing)"
  fi
  # EMISSION-ORDER — the module emits in SOURCE order (zeta, alpha, main),
  # never the demand order the worklist constructs in (main, alpha, zeta).
  eo_elem=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-reach-emission-order.mn" 2>/dev/null | grep -F 'elem $fns')
  if printf '%s' "$eo_elem" | grep -qE '\.zeta \$[^ ]*\.alpha \$[^ ]*\.main( |\))'; then
    pass "relocation order pin: emission is source order (zeta alpha main)"
  else
    fail "relocation order pin (elem order: $eo_elem)"
  fi


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
  wt_memo_put frontier "$frontier_key" "frontier: $total_pass pass / $total_fail red / $total_xred expected-red"
else
  rm -f "$ROOT/.build/frontier-stamp"
fi
[ "$total_fail" -eq 0 ]
