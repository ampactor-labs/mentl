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
# rendered as its own project (the folder's modules beside it, the lesson
# the entry: run_module), its WAV judged by the oracle Pulse's render is
# judged by, with the lesson's own length and notes. Lesson 8 is accepted
# first (`accept` at its hole writes the one survivor; a tie or a miss
# fails), and lesson 12 runs twice, its second process resuming the first's
# image, its file equal to lesson 11's. A lesson the compiler refuses is
# the board's (the owed bounds), not rendered here. Then the twins, each the
# course with ONE line changed, so a twin can never drift from the lesson:
#   alloc  an allocation on lesson 5's per-sample path    → E_EffectMismatch
#   rate   rate.mn's `now` pinned at 44.1 kHz under play's `!Sample(44100)`
#                                                         → E_EffectMismatch
#   range  lesson 7's cutoff a constant past Nyquist      → E_RefinementRejected
#   teach  `accept` at lesson 7's division writes `notes: Positive`
run_course() {
  local compiler="$1" dir="$2" src="$ROOT/examples/pulse/course" spec lesson secs notes pdir rc
  for spec in "01-tone 3 220" "02-line 3 220" "03-bus 4 220,329.63" "04-rack 4 220,261.63,329.63,440" \
              "05-silence 4 220,261.63,329.63,440" "06-rate 3 220,277.18,329.63" \
              "07-bounds 4 220,261.63,329.63,440" "08-hole 3 220,329.63" "09-learn 3 220" "10-voices 4 220,261.63,329.63,440 chord" "11-footprint 4 220,261.63,329.63,440" "12-resume 4 220,261.63,329.63,440 resume"; do
    set -- $spec; lesson=$1; secs=$2; notes=$3; mode=${4:-}
    pdir="$dir/course-$lesson.proj"
    rm -rf "$pdir"; mkdir -p "$pdir"; cp "$src"/*.mn "$pdir"/
    if [ "$lesson" = 08-hole ] && ! wt_run --dir "$pdir::." --dir "$ROOT::/mentl-home" "$compiler" accept 08-hole.mn:50:76 > "$dir/course-08.accept" 2>&1; then
      fail "course 08-hole: accept at the stage hole (see $dir/course-08.accept)"; continue
    fi
    if [ "$mode" = resume ]; then run_module "$compiler" "$pdir" "$lesson" "$dir/course-$lesson.saved" "$dir/course-$lesson.err" && wt_run --dir "$pdir::." "$pdir/$lesson.wasm" resume > "$dir/course-$lesson.wav" 2>> "$dir/course-$lesson.err"; else run_module "$compiler" "$pdir" "$lesson" "$dir/course-$lesson.wav" "$dir/course-$lesson.err"; fi; rc=$?
    if [ "$rc" -ne 0 ] || [ ! -s "$dir/course-$lesson.wav" ]; then
      fail "course $lesson render (exit=$rc; see $dir/course-$lesson.err)"
    elif { [ "$mode" != resume ] || cmp -s "$dir/course-$lesson.wav" "$dir/course-11-footprint.wav" || { echo "FAIL the second process's file differs from lesson 11's" > "$dir/course-$lesson.oracle"; false; }; } && python3 "$ROOT/tests/frontier/pulse-render/oracle.py" "$dir/course-$lesson.wav" --seconds "$secs" --notes "$notes" $([ "$mode" = chord ] && echo --chord) > "$dir/course-$lesson.oracle" 2>&1; then
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
  sed -i "s/$pattern/  let lake = drone_hz(lake_elevation_ft)\n  let _ = fetch(\"lake\")/" "$tdir/inversion.mn"
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

# The program an accepted fill writes runs: the edit session's accept
# writes `1` into a copy of the positive fixture, and the copy runs to 1.
# What the session shows and writes is tests/frontier/edit.transcript;
# running a program is the host's.
run_accepted_fill() {
  local compiler="$1" dir="$2" copy="$2/positive-hole.mn"
  cp "$ROOT/tests/frontier/mn-constrained-hole-workflow.mn" "$copy"
  printf 'y\n' | "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" "$compiler" \
    edit "../${dir#$ROOT/}/positive-hole" > "$dir/positive-hole.edit.out" 2> "$dir/positive-hole.edit.err"
  run_program "$compiler" positive-hole-post-edit "$copy" 1 no "$dir"
}

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
  # distortion, whose reach runs through lib/math.mn's series, each a fixed
  # sequence of stages since 2026-11-04, so the reverse sweep carries them
  # and a branch whose value is a call ends in that value; 42 iff all 12
  # partials agree to 1e-6. RED on boot 627072cd (refused: a recursion).
  run_program "$compiler" derive-grad \
    "$ROOT/tests/frontier/derive-crucible/grad.mn" 42 derive "$dir"
  run_program "$compiler" derive-grad-series \
    "$ROOT/tests/frontier/derive-crucible/grad-series.mn" 42 derive "$dir"
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
  # The run's stdout, which a fixture contract cannot name yet, read off a
  # run of the leg's own.
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
  # it writes no live line. The only text after the last clear is the trap summary. RED on boot 30605949: 0 bytes at a terminal.
  live=$(cd "$ROOT" && script -qec "$WT run ${WT_RUN_FLAGS[*]} --dir . --dir $ROOT::/mentl-home $compiler check examples/pulse/course/01-tone.mn" /dev/null)
  piped=$(cd "$ROOT" && wt_run --dir . --dir "$ROOT::/mentl-home" "$compiler" check examples/pulse/course/01-tone.mn 2>&1 >/dev/null | grep -c $'\r')
  linked=$(printf '%s' "$live" | grep -o 'linked [0-9]* modules' | grep -o '[0-9]*')
  if [ -n "$linked" ] && [[ "$live" == *"parsing $linked/$linked modules"* && "$live" == *"judging 1/"* && "${live##*$'\e[K'}" == "verify: "* ]] && [ "$piped" = 0 ]; then
    pass "the compile says where it is: $linked modules linked and parsed, the judging drawn, its row cleared before the trap summary; a pipe gets no live line"
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
  run_lsp_hover "$compiler" "$dir" lsp

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

  # The deliberate trap is in the row: extract_chase traps at depth > 1000
  # by its own comment, and its row must say so.
  trap_where=$(wt_run --dir "$ROOT" "$compiler" where "$ROOT/src/main.mn" extract_chase 2>/dev/null | head -1)
  trap_row_ok=0
  printf '%s' "$trap_where" | grep -qE '^→ extract_chase\(.*\).* with .*\bTrap\b' && trap_row_ok=1
  judge trap-in-the-row "$trap_row_ok" "trap in the row (extract_chase's row carries Trap) (got: $trap_where)"

  # ── tighten and fmt write files; a program run keeps what they mean ──
  # What `mentl tighten` and `mentl fmt` write, and the checks around each,
  # are the transcripts tests/frontier/tighten.transcript and
  # tests/frontier/fmt.transcript. Running a program is the host's, so the
  # legs below write a copy on disk and run it: the rostered match runs to 5,
  # and a type check cannot tell (a+b)*c from a+b*c, so each fmt fixture
  # answers the same before and after its render.
  tdemo="$dir/tighten-demo"
  mkdir -p "$tdemo"
  cp "$ROOT/tests/frontier/tighten-demo/wild.mn" "$tdemo/wild.mn"
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" tighten wild.mn) >"$dir/wild-tighten.out" 2>&1
  # The wheel only emits; running is the mentl command's (run_module).
  run_module "$compiler" "$tdemo" wild "$dir/wild-run.out" "$dir/wild-run.err"
  wrun=$?
  if [ $wrun -eq 5 ]; then
    pass "the rostered match runs to 5"
  else
    fail "wildcard-over-sum run (exit=$wrun; see $dir/wild-run.err)"
  fi

  fdemo2="$dir/fmt-demo"
  mkdir -p "$fdemo2"
  for fx in rich voicey; do
    cp "$ROOT/tests/frontier/fmt-demo/$fx.mn" "$fdemo2/$fx.mn"
    wt_entry "$fdemo2/$fx.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/$fx-pre.wat" 2>/dev/null \
      && wt_asm "$fdemo2/$fx-pre.wat" "$fdemo2/$fx-pre.wasm" 2>/dev/null \
      && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/$fx-pre.wasm" >/dev/null 2>&1
    fmt_pre=$?
    (cd "$fdemo2" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$fdemo2" --dir /tmp "$compiler" fmt "$fx.mn") >"$dir/fmt-$fx.out" 2>&1
    fmt_rc=$?
    wt_entry "$fdemo2/$fx.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/$fx-post.wat" 2>/dev/null \
      && wt_asm "$fdemo2/$fx-post.wat" "$fdemo2/$fx-post.wasm" 2>/dev/null \
      && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/$fx-post.wasm" >/dev/null 2>&1
    fmt_post=$?
    if [ $fmt_rc -eq 0 ] && [ "$fmt_pre" = "42" ] && [ "$fmt_post" = "42" ]; then
      pass "fmt keeps what $fx.mn does (42 before and after the canonical render)"
    else
      fail "fmt behavioral $fx.mn (fmt=$fmt_rc pre=$fmt_pre post=$fmt_post; see $dir/fmt-$fx.out)"
    fi
  done
  wt_entry "$ROOT/tests/frontier/fmt-demo/lets.mn" "${RTLIBS[@]}" | wt_rooted "$compiler" > "$fdemo2/lets.wat" 2>/dev/null \
    && wt_asm "$fdemo2/lets.wat" "$fdemo2/lets.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$fdemo2/lets.wasm" >/dev/null 2>&1
  lets_run=$?
  if [ "$lets_run" = "22" ]; then
    pass "the destructuring lets fmt keeps as written run to 22"
  else
    fail "fmt destructuring let run (exit=$lets_run)"
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
    pass "user link: hello's check prints nothing (printing cannot trap; no library narration, no library debt)"
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
  # diagnostics at the proposal's own lines (the proposal is judged as a
  # module of the project, with the library, from .build/mcp), the honest
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
  # The span names the proposal's own module, so a span in any other file
  # fails. Two errors: `fn bad() with !E = op()` breaks its own `!E`
  # (E_EffectMismatch), and E reaches the top unhandled (E_EffectUnhandled).
  if grep -q 'REFUSED — 2 error' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectMismatch' "$mcp_dir/out.jsonl" \
     && grep -q 'at .build/mcp/proposal:3:1' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectUnhandled' "$mcp_dir/out.jsonl"; then
    pass "mcp propose REFUSES with file-local teaching spans"
  else
    fail "mcp refusal verdict (see $mcp_dir/out.jsonl)"
  fi
  if grep -q 'PROVEN — every claim in the program is proven' "$mcp_dir/out.jsonl" && [ -s "$mcp_dir/.build/mcp/last.wat" ]; then
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
  # The verdict's first line says what the gate did: a claim the verifier
  # could not decide reads PENDING, with the claim printed at its line, and a
  # refusal after a proven build says the artifact on disk is the earlier one.
  gv_dir="$dir/mcp-verdicts"; mkdir -p "$gv_dir"
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}' \
    '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"propose","arguments":{"source":"fn half(total, parts) = total / parts\n\nfn main() = half(10, len([1, 2]))\n"}}}' \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"propose","arguments":{"source":"fn double(x) = x * 2\n\nfn main() = double(21)\n"}}}' \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"propose","arguments":{"source":"effect E { op() -> Int }\nfn bad() with !E = op()\nfn main() = bad()\n"}}}' \
    | "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$gv_dir::." --dir "$ROOT::/mentl-home" "$compiler" mcp >"$gv_dir/out.jsonl" 2>"$gv_dir/err.log"
  if grep '"id":2' "$gv_dir/out.jsonl" | grep -q '"text":"PENDING — 1 claim(s)' && ! grep '"id":2' "$gv_dir/out.jsonl" | grep -q 'every claim in the program is proven' \
     && grep '"id":2' "$gv_dir/out.jsonl" | grep -q 'verify: pending partiality' && grep '"id":4' "$gv_dir/out.jsonl" | grep -q 'last.wat is the previous proven build, not this program'; then
    pass "mcp verdicts: an undecided claim reads PENDING at its line; a refusal names the earlier build"
  else
    fail "mcp verdicts (see $gv_dir/out.jsonl)"
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
  # nothing stands on is no longer taught. The first proposal proves, and so does the third, which only prints and is sent with a `é`; the second is PENDING, since joining its strings can trap inside the library.
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
     && [ "$(grep -c 'PROVEN — every claim in the program is proven, nothing in it can stop with a trap' "$ses_dir/out.jsonl")" = "2" ] && grep '"id":9,' "$ses_dir/out.jsonl" | grep -q 'PENDING — 0 claim(s) the verifier could not decide and 1 place(s) that can stop the program with a trap; the program was built' && grep '"id":10,' "$ses_dir/out.jsonl" | grep -q 'PROVEN — every claim in the program is proven, nothing in it can stop with a trap'; then
    pass "resident session: one derivation, live query + at + audit + teach reads, propose coexists and resolves the library"
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
  run_accepted_fill "$compiler" "$dir"

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

  wdoc="$ROOT/tests/frontier/mn-where-badges.mn"
  # The bare why verb (SYNTAX's lag list, first name retired): the
  # Reason-chain walk as its own verb. Born RED 2026-08-08 (the prior
  # boot answered unknown-verb).
  wy_out=$(wt_run --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" why "$wdoc" gain 2>/dev/null)
  printf '%s' "$wy_out" | grep -q 'let gain' && pass "why verb (the Reason chain of gain walks to its let)" || fail "why verb (got: $wy_out)"
  # The developer's coordinates: `gain` is line 8 of a 24-line fixture, so
  # the why verb's `at 8:1-8:15` is the line in the developer's own file,
  # which every surface that renders a Reason shares (hover, the caret's Why
  # line, the type facet).
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
  wy_file_ok=0
  printf '%s' "$wy_out" | grep -q 'mn-where-badges:9' && wy_file_ok=1
  judge why-coordinates "$wy_file_ok" \
    "why coordinates carry their file (line half fixed; file half is Hβ.why.reason-span-is-a-weave-coordinate) (got: $wy_out)"

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
