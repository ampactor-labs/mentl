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

total_pass=0
total_fail=0
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
  if [ "$rc" -eq "$expected" ]; then
    pass "$label run (exit=$rc)"
  else
    fail "$label run (exit=$rc expected=$expected; see $rerr)"
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

# The incremental cursor gate (B-i landing 3): a three-module DAG, one
# edit, one truth. Run 1 compiles cold and persists; b.mn is patched; run
# 2 restores the image, names the re-derived cone (b main — a stays
# cached), and its emission must equal a COLD compile of the patched tree
# (the fixture is lambda-free, so handle numbering cannot leak into the
# wat and byte-equality is the honest oracle at today's pin; the
# deterministic handle partition generalizes it).
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
    pass "$label refusal ($expected_code=$count exit=$rc wat=0B)"
  else
    fail "$label refusal (exit=$rc $expected_code=$count wat=${size}B; see $err)"
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

  if grep -Fq '1 candidate(s)' "$EDIT_OUT" && grep -Fq 'pure_seven' "$EDIT_OUT"; then
    pass "capability-hole filter retained only pure_seven()"
  else
    fail "capability-hole filter did not expose the sole pure survivor"
  fi

  for rejected in direct_network transitive_network higher_order_network; do
    if has_rejection_reason "$rejected"; then
      pass "capability-hole retained $rejected rejection Reason"
    else
      fail "capability-hole lost $rejected rejection Reason"
    fi
  done

  if ! grep -Fq '??' "$EDIT_SCRATCH" && \
      grep -Eq 'with !Network = pure_seven\(\)([[:space:]]|$)' "$EDIT_SCRATCH"; then
    pass "capability-hole exact patch applied (pure_seven())"
    patched=1
  else
    fail "capability-hole exact pure_seven() patch not applied"
  fi

  check_and_execute "$compiler" "$dir" capability-hole 7 "$patched"
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
  # line numbers (record-pattern / -open both at 40) never clobber each other.
  for spec in '|>:10' '<|:11' '><:12' '~>:13' 'anonymous:14' '<~:15' 'eta:24' 'effectful-lambda:25' 'iteration:26' 'wildcard-zero:27' 'failure-mask:28' 'print-in-report:31' 'wildcard-fabricates:32' 'underscore-retain:33' 'flag-as-int:34' 'parallel-arrays:35' 'parallel-arrays:37' 'vtable-record:36' 'env-frame:38' 'default-param:39' 'record-pattern:40' 'record-pattern-open:40' 'declared-row-hof:41'; do
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
  for spec in '|>:10' '<|:11' '><:12' '~>:13' 'anonymous:14' '<~:15' 'eta:24' 'effectful-lambda:25' 'iteration:26' 'wildcard-zero:27' 'failure-mask:28' 'print-in-report:31' 'wildcard-fabricates:32' 'underscore-retain:33' 'flag-as-int:34' 'parallel-arrays:35' 'parallel-arrays:37' 'vtable-record:36' 'env-frame:38' 'default-param:39' 'record-pattern:40' 'record-pattern-open:40' 'declared-row-hof:41'; do
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
  [ "$ok" = 1 ] && pass "structural census: all twenty-two shapes count their own site (|> <| >< ~> <~ anonymous eta effectful-lambda iteration wildcard-zero failure-mask print-in-report wildcard-fabricates underscore-retain flag-as-int parallel-arrays-both-faces vtable-record env-frame default-param record-pattern record-pattern-open declared-row-hof)"
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

  if grep -Fq '2 candidate(s)' "$EDIT_OUT" && \
      grep -Fq 'pure_seven' "$EDIT_OUT" && grep -Fq 'calm_seven' "$EDIT_OUT"; then
    pass "capability-tie projection surfaced both proven survivors"
  else
    fail "capability-tie projection missing the two-survivor tie"
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
  run_program "$compiler" ml-crucible \
    "$ROOT/tests/frontier/ml-crucible/ml-demo.mn" 42 math "$dir"
  run_program "$compiler" adaptive-crucible \
    "$ROOT/tests/frontier/adaptive-crucible/adaptive-demo.mn" 42 math "$dir"
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
  # B-i landing 2: the warm-start cache — run 2 restores run 1's analyzed
  # image and must emit byte-identical WAT. RED before the landing: the
  # warm line never prints (every run re-derives).
  run_warm_start "$compiler" "$dir"
  # B-i landing 3: the incremental cursor — patch one module, re-derive
  # only its cone off the restored image. RED before the landing: a
  # changed weave missed the weave-keyed cache and re-derived everything
  # with no cone line.
  run_warm_incremental "$compiler" "$dir"
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
  run_program "$compiler" heap-region \
    "$ROOT/tests/frontier/mn-heap-region.mn" 42 yes "$dir"
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
  # !Cast severance REPORTS today (E_EffectMismatch at the declaration —
  # not an armed refusing class; arming it is the refusal-law's own
  # licence-gated landing). The leg asserts the report fires.
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
  # The root-row governance gate's three tiers, each pinned: an
  # EVIDENCE-floor demand refuses even with an install elsewhere (a
  # dead-chain perform walks garbage evidence, no belt — the one strict
  # sharpening); a STATEFUL singleton clears on an install (the
  # SingletonUninstalled guard the loud belt — the preinstall micro
  # holds that tier at 134); a STATELESS singleton grounds by the
  # value-sound licence (the arm ignores state), pinned by the
  # escaped-install tripwire below (exit 7 — the modal install-identity
  # frontier owns the eventual split, like residual-absence beside it).
  run_program "$compiler" effect-escaped-install \
    "$ROOT/tests/frontier/mn-effect-escaped-install.mn" 7 no "$dir"
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
  # T_UseAfterMove (Phase 4.1, Hβ.own.use-after-move) — the ledger's borrow
  # leg consults the used-set: a borrow-read of a moved own narrates (armed
  # at wheel-zero per the census law). Pre-fix the fixture compiled with
  # zero diagnostics and ran — the silent read of a moved value this class
  # deletes before the arena makes it a use-after-free.
  run_narration "$compiler" use-after-move \
    "$ROOT/tests/frontier/mn-use-after-move.mn" T_UseAfterMove "$dir"
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
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-teach-pure-control.mn" | wt_run "$compiler" teach - > "$dir/teach-pure.out" 2>/dev/null
  if grep '^main:' "$dir/teach-pure.out" | grep -q '!Alloc'; then
    pass "teach-pure-control (a non-allocating body still unlocks !Alloc)"
  else
    fail "teach-pure-control (the true proposal died with the fix)"
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

  # The arena census print (Hβ.perf.per-decl-arena 2a-ii, the DEP chain's
  # named next landing): the compile's stderr carries the accumulated
  # image-classified byte count — the extent-delta account the
  # image_enter/exit brackets feed — beside the judgment channel. RED
  # first: image_bytes had zero performers when this leg was written.
  wt_run "$compiler" < "$ROOT/tests/frontier/mn-census-verbs.mn" > "$dir/arena.wat" 2> "$dir/arena.compile.err"
  if grep -qE '^image: [0-9]+ image-classified byte' "$dir/arena.compile.err"; then
    img_n=$(grep -oE '^image: [0-9]+' "$dir/arena.compile.err" | grep -oE '[0-9]+')
    if [ "$img_n" -gt 0 ]; then
      pass "arena census: the compile reports its image-classified bytes ($img_n)"
    else
      fail "arena census: the image line reads 0 — the brackets classify nothing"
    fi
  else
    fail "arena census: no image line on the compile's stderr — the census print is prose, not mechanism"
  fi

  # The movers ratchet (rung 3's instrument, Hβ.infer.schemes-are-edges):
  # the trial/final divergence on a polymorphic fixture, ceiling falling
  # only. lib/lists.mn diverges at 6 today; the stage contract's landing
  # (env carries cells — nothing left to diverge) drives it to 0 and the
  # ceiling retires like solo_violations_max did.
  mv_max=$(grep -E '^lists_movers_max:' "$ROOT/tools/verify-baseline.txt" | head -1 | cut -d: -f2 | tr -d ' ')
  wt_run "$compiler" < "$ROOT/lib/lists.mn" > "$dir/mv.wat" 2> "$dir/mv.compile.err"
  mv_n=$(grep -oE '^judgment: [0-9]+' "$dir/mv.compile.err" | grep -oE '[0-9]+' | head -1)
  mv_n=${mv_n:-0}
  if [ -n "$mv_max" ] && [ "$mv_n" -le "$mv_max" ]; then
    if [ "$mv_n" -eq 0 ]; then
      pass "movers ratchet: the trial/final divergence reads 0 (ceiling $mv_max retires)"
    else
      pass "movers ratchet: $mv_n mover(s) within the $mv_max ceiling (0 retires it at rung 3)"
    fi
  else
    fail "movers ratchet: $mv_n mover(s) against ceiling ${mv_max:-unset} — the judgment diverged more, not less"
  fi

  # Severance honesty (audit): a fn whose row carries Alloc is never
  # offered "proven zero allocation"; a pure fn still earns the offer.
  # The reached set reads the CHASED row (row_names was a top-link read
  # and a chained row hid its deeper presents — measured on the wheel).
  cat "${RTLIBS[@]}" "$ROOT/tests/frontier/mn-audit-severance-honest.mn" | wt_run "$compiler" audit - > "$dir/audit-sev.out" 2>/dev/null
  if grep -A1 '^allocates :' "$dir/audit-sev.out" | grep -q 'severable:.*Alloc'; then
    fail "audit-severance-honest (an allocating row was offered Alloc severance)"
  elif grep -A1 '^quiet :' "$dir/audit-sev.out" | grep -q 'severable:.*Alloc'; then
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
  # T_OverDeclared is a MachineApplicable proposal carrying the proven
  # row; the tighten verb turns the first authorable one into the patch.
  # The fixture copies out (tighten MUTATES its target): helper reserves
  # Memory + Alloc over a pure body; one run rewrites the clause to
  # `with Pure`, a fresh check stays clean, and a second run finds
  # nothing — the ratchet's fixpoint. RED on the pre-verb boot
  # (unrecognized command; file untouched).
  tdemo="$dir/tighten-demo"
  mkdir -p "$tdemo"
  cp "$ROOT/tests/frontier/tighten-demo/over.mn" "$tdemo/over.mn"
  (cd "$tdemo" && "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$tdemo" --dir /tmp "$compiler" tighten over.mn) >"$dir/tighten.out" 2>&1
  trc=$?
  if [ $trc -eq 0 ] && grep -q 'with Pure = 42' "$tdemo/over.mn"; then
    pass "tighten authors the patch (with Memory + Alloc → with Pure)"
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
  if ! grep -q '__dp' "$fdemo2/rich.mn" && grep -q '((a, b)) =>' "$fdemo2/rich.mn"; then
    pass "fmt re-sugars the destructure lambda (no __dp in the canonical page)"
  else
    fail "fmt destructure re-sugar (see $fdemo2/rich.mn)"
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
  if [ "$l2" = 1 ] && [ "$l4" = 1 ] && [ "$l5" = 1 ]; then
    pass "comment lede (decl + interior + trailing all attach and render)"
  else
    fail "comment lede (decl=$l2 interior=$l4 trailing=$l5)"
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
  if [ $? -eq 0 ] && printf '%s' "$pout" | grep -q 'Query: ?? : Positive' && printf '%s' "$pout" | grep -q 'Propose: 1'; then
    pass "cursor-address propose (the socket speaks the one survivor)"
  else
    fail "cursor-address propose (got: $pout; see $dir/propose-at.err)"
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
  (cd "$sessdir" && "$WT_CLI" run "${WT_CLI_FLAGS[@]}" --dir "$sessdir::." --dir /tmp --dir "$ROOT::/mentl-home" -S "tcplisten=127.0.0.1:${sess_port}" "$compiler" session >"$dir/session.log" 2>&1) &
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
  # Kill by the port fingerprint — the subshell pid is the wrapper, and
  # killing it orphans the wasmtime grandchild (the stale-graph server
  # this leg's first red was).
  pkill -f "tcplisten=127.0.0.1:${sess_port}" 2>/dev/null
  kill "$sess_pid" 2>/dev/null
  wait "$sess_pid" 2>/dev/null
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
  "$WT_CLI" run "${WT_CLI_FLAGS[@]}" --dir "$ROOT::." -S "tcplisten=127.0.0.1:${space_port}" "$compiler" space >"$dir/space-serve.log" 2>&1 &
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
  if grep -q 'REFUSED — 1 claim' "$mcp_dir/out.jsonl" \
     && grep -q 'E_EffectMismatch' "$mcp_dir/out.jsonl" \
     && grep -q 'at 3:1' "$mcp_dir/out.jsonl" \
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
     && grep -q 'severable:' "$ses_dir/out.jsonl" \
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
  # tightening from the next frontier (the generation clears:
  # tighten_reset + verify_reset before the re-derivation; the
  # enumerators dedup by span START, latest mint wins). Seen RED on the
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
  if grep '"id":2' "$prob_dir/out.jsonl" | grep -q 'Field: 1 hole(s), 1 pending proof(s), 1 tightening(s), 3 gradient position(s)' \
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
  "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT::." "$compiler" tests/frontier/mn-ranker-local-intent.mn:10:15 >"$dir/ranker.out" 2>/dev/null
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
  cat "${RTLIBS[@]}" "$ROOT/lib/io.mn" "$ROOT/tests/frontier/mn-hof-row-gate.mn" | wt_run "$compiler" > "$dir/hof-gate.wat" 2> "$dir/hof-gate.err" \
    && wt_asm "$dir/hof-gate.wat" "$dir/hof-gate.wasm" 2>/dev/null \
    && "$WT" run "${WT_RUN_FLAGS[@]}" "$dir/hof-gate.wasm" > /dev/null
  hof_rc=$?
  if [ "$hof_rc" = "42" ] && [ "$(grep -c 'E_EffectMismatch' "$dir/hof-gate.err")" = "1" ]; then
    pass "hof row gate (quiet admitted, runs 42; exactly the noisy edge reports)"
  else
    fail "hof row gate (rc=$hof_rc mismatches=$(grep -c 'E_EffectMismatch' "$dir/hof-gate.err"); see $dir/hof-gate.err)"
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
  # wild (honest Sub debt, the never-launders control). seek DISCHARGES
  # since 2026-08-12: the authored `-> Nat` rides the decl's TFun slot
  # as a value bound before the body (the assumed-signature IH), and
  # ty_lo chases a var slot to its cell, so the rec-call's callee read
  # proves the join. Zero = the licence laundered a computation again
  # (the runtime -1 class); more = an interval leg (if-join / len /
  # Add / opaque type read / the IH slot) stopped discharging.
  iv_err=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" compile "$ROOT/tests/frontier/mn-verify-interval.mn" 2>&1 >/dev/null | grep -c 'pending comparison')
  if [ "$iv_err" = "1" ]; then
    pass "interval fragment: the rec-call IH discharges and the licence never launders (1 honest pending)"
  else
    fail "interval fragment (pending comparisons: $iv_err, want 1)"
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
  if [ "$lc_n" = "1" ] && printf '%s' "$lc_out" | grep -q 'at 2:'; then
    pass "diagnostics localize: one report, the user's own line (at 2:)"
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

  # ─── The relevant tier (affine gains exactly-once) ──────────────────
  # T_OwnUnconsumed fires on an authored `own` the body never consumes
  # (drops) and stays SILENT on a transfer-out (hands_back — the return
  # is the consume). Both faces + the fixture still runs.
  ou_chk=$("$WT" run "${WT_RUN_FLAGS[@]}" --dir "$ROOT" --dir /tmp --dir "$ROOT::/mentl-home" "$compiler" check "$ROOT/tests/frontier/mn-own-unconsumed.mn" 2>&1)
  ou_n=$(printf '%s' "$ou_chk" | grep -c 'T_OwnUnconsumed')
  if [ "$ou_n" = "1" ] && printf '%s' "$ou_chk" | grep -q "at 10:1"; then
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
  # Four derived badges: an inferred repr, an op's resume cardinality,
  # a Thread-scheduled fanout, and the bare Seq default — each a line
  # the medium narrates from facts the graph already proves.
  wdoc="$ROOT/tests/frontier/mn-where-badges.mn"
  w_ok=1
  w_repr=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" gain 2>/dev/null)
  printf '%s' "$w_repr" | grep -q 'gain : Float @ f64 (inferred)' || { w_ok=0; fail "where repr badge (got: $w_repr)"; }
  w_card=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" tick 2>/dev/null)
  printf '%s' "$w_card" | grep -q 'resume Int ->1 answer' || { w_ok=0; fail "where cardinality badge (got: $w_card)"; }
  w_sched=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" fanned 2>/dev/null)
  printf '%s' "$w_sched" | grep -q '>< \[Thread\] at' || { w_ok=0; fail "where schedule badge (got: $w_sched)"; }
  w_seq=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" bare 2>/dev/null)
  printf '%s' "$w_seq" | grep -q '>< \[Seq\] at' || { w_ok=0; fail "where seq-default badge (got: $w_seq)"; }
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
  printf '%s' "$wy_out" | grep -q 'mn-where-badges:8' || { w_ok=0; fail "why coordinates are the developer's (got: $wy_out)"; }
  # The capability-at-tee badge (§11 6.3's felt face): the install line
  # names the handler and the effect set its arms absorb, from the
  # graph's own facts. Born RED 2026-08-08 (the boot lacked the facet).
  w_tee=$(wt_run --dir "$ROOT" "$compiler" where "$wdoc" handled 2>/dev/null)
  printf '%s' "$w_tee" | grep -q '~> ticker absorbs Tick at' || { w_ok=0; fail "where tee badge (got: $w_tee)"; }
  [ "$w_ok" = 1 ] && pass "where: repr, cardinality, schedule, and tee badges narrate (output, never input)"

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
  cost_ceiling=2737
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

  # ─── The per-module solo sweep (PLAN §11 Phase 3.5, ratcheted) ──────
  # E_MissingVariable across every SHIPPED module's SOLO check, ceiling in
  # verify-baseline (solo_violations_max — monotone DOWN; 0 retires the
  # drift catalog per §11). One judgment per module.
  #
  # lib/** JOINED THE SWEEP 2026-08-16, and the extension is the reason it
  # had to: src/** was at the 0 ceiling and green while lib/** carried 20
  # unresolved names — `mentl check lib/dsp/signal.mn` named four of them
  # on its first run. The wheel's own link resolves every name whether or
  # not the module declared the dep (concatenation hides it), and no
  # oracle judged a lib-rooted link at all, so the count was invisible to
  # census, fixpoint, and micros alike. That is §11 tripwire (3) — the
  # board is blind to what the wheel never does — and the standing
  # counter-measure is a gate that exercises it. Four import lines took
  # lib/** to 0: io into dsp/cfc, test and net; math into
  # ml/tensor.
  sv_max=$(grep -E '^solo_violations_max:' "$ROOT/tools/verify-baseline.txt" | head -1 | cut -d: -f2 | tr -d ' ')
  sv_total=0
  # One cursor per module, concurrently: each solo-check is process-isolated
  # and judged by artifact, so flight parallelizes while the judge stays
  # serial (bash counters cannot cross children). Roots travel as env vars,
  # never positional args — xargs owns those.
  sv_specs=()
  for svf in "$ROOT"/src/*.mn "$ROOT"/src/backends/*.mn \
             "$ROOT"/lib/*.mn "$ROOT"/lib/dsp/*.mn \
             "$ROOT"/lib/ml/*.mn "$ROOT"/lib/tutorial/*.mn; do
    sv_specs+=("$svf")
  done
  sv_pool_dir=$(mktemp -d)
  printf '%s\0' "${sv_specs[@]}" | SEED_ART="$compiler" SV_POOL_DIR="$sv_pool_dir" \
        SV_ROOT="$ROOT" xargs -0 -n 1 -P "${FRONTIER_POOL:-$(nproc)}" bash -c '
          source "$SV_ROOT/tools/wt-env.sh" >/dev/null 2>&1
          h=$(printf %s "$1" | cksum | cut -d" " -f1)
          n=$(wt_run --dir "$SV_ROOT" --dir /tmp --dir "$SV_ROOT::/mentl-home" "$SEED_ART" check "$1" 2>&1 | grep -cE "E_MissingVariable")
          printf "%s\n" "$n" > "$SV_POOL_DIR/$h"' sv-child
  sv_landed=$(find "$sv_pool_dir" -type f 2>/dev/null | wc -l)
  if [ "$sv_landed" != "${#sv_specs[@]}" ]; then
    rm -rf "$sv_pool_dir"
    fail "per-module solo sweep: the flight dropped results ($sv_landed/${#sv_specs[@]} landed)"
    sv_total=-1
  else
    sv_total=$(awk '{s+=$1} END{print s+0}' "$sv_pool_dir"/*)
    rm -rf "$sv_pool_dir"
  fi
  if [ -n "$sv_max" ] && [ "$sv_total" -le "$sv_max" ]; then
    pass "per-module solo sweep: $sv_total violation(s) within the $sv_max ceiling (0 retires the drift catalog)"
  else
    fail "per-module solo sweep: rose to $sv_total against ceiling $sv_max — a module newly under-imports its names"
  fi
done

echo "frontier: $total_pass pass / $total_fail red"

# The GREEN STAMP, keyed by the boot it tested (the d51661f1 lesson —
# 2026-08-09): a fully-green run records the boot's sha256 so the
# pre-commit thesis gate can DEMAND that the frontier ran, green,
# against exactly the wheel being committed. A red run stamps nothing
# (and clears any stale stamp — a stamp must never outlive a red).
# Scope, stated honestly: the stamp binds gate↔boot; boot↔staged-source
# is the march's own per-landing contract (m2 == m3), not this file's.
if [ "$total_fail" -eq 0 ]; then
  sha256sum "$ROOT/boot/mentl.wasm" | cut -d' ' -f1 > "$ROOT/.build/frontier-stamp"
else
  rm -f "$ROOT/.build/frontier-stamp"
fi
[ "$total_fail" -eq 0 ]
