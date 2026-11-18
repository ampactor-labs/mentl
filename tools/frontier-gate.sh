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

total_pass=0
total_fail=0
# Declared standing failures (frontier_expected_red) — not reds. See judge().
total_xred=0

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

# The classes a compile reported, one line for each error and one for the
# summary of the claims it left open, sorted. A report names its module
# before its line (`at main:2:3-2:9`), which the span pattern below does not
# match, so each line holds a class alone.
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

# run_program <compiler> <label> <source> <expected> <dir> — a program read on
# the compiler's stdin, compiled, assembled and run. The compile reports no
# error and leaves no claim open, and the run answers the expected exit,
# judged by the leg's label.
run_program() {
  local compiler="$1" label="$2" source="$3" expected="$4" dir="$5"
  local wat="$dir/$label.wat" wasm="$dir/$label.wasm"
  local cerr="$dir/$label.compile.err" aerr="$dir/$label.assemble.err"
  local rout="$dir/$label.run.out" rerr="$dir/$label.run.err"
  local normalized="$dir/$label.normalized" rc diags errors

  wt_run "$compiler" < "$source" > "$wat" 2> "$cerr"
  rc=$?
  diags=$(grep -cE '(^|: )[EWVTP]_' "$cerr" 2>/dev/null || true)
  normalize_errors "$cerr" > "$normalized"
  errors=$(wc -l < "$normalized")
  if [ "$rc" -eq 0 ] && [ "$errors" -eq 0 ]; then
    pass "$label compile (diagnostics=$diags)"
  elif [ "$rc" -eq 0 ]; then
    fail "$label compile (new-errors-or-debt=$errors diagnostics=$diags; see $normalized)"
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

  wt_run "$wasm" > "$rout" 2> "$rerr"
  rc=$?
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

# The persist legs' baseline: what a program of nothing but the persist
# libraries reports, normalized. A persist leg's compile may report nothing
# beyond it.
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

# The signal crucible's oracle (tests/frontier/signal-crucible/oracle.py), an
# independent port of lib/dsp/signal.mn's pipeline using math.mn's Taylor
# series and no numpy, run over the recording the program reads. The
# program's own battery holds it to the cell flat 2 and a strong coupling; the
# oracle must find the same two facts.
run_signal_crucible() {
  local rec="$ROOT/tests/frontier/signal-crucible/recording.txt"
  local out flat strong ok=1
  out=$(python3 "$ROOT/tests/frontier/signal-crucible/oracle.py" oracle "$rec" 2>/dev/null)
  if ! printf '%s\n' "$out" | grep -q '^EXPECTED_'; then
    pass "signal-crucible cross-validation skipped (oracle deps unavailable)"
    return
  fi
  flat=$(printf '%s\n' "$out" | sed -n 's/^EXPECTED_FLAT=//p')
  strong=$(printf '%s\n' "$out" | sed -n 's/^EXPECTED_STRONG_COUPLING=//p')
  [ "$flat" = 2 ] || { ok=0; fail "signal-crucible cross-validation (argmax flat=$flat, expected 2)"; }
  [ "$strong" = 1 ] || { ok=0; fail "signal-crucible cross-validation (strong_coupling=$strong, expected 1)"; }
  [ "$ok" = 1 ] && pass "signal-crucible cross-validation (argmax flat=2 + strong coupling agree with the oracle)"
}

# The CFC recording's oracle (tests/frontier/cfc-rec/oracle.py), a numpy port
# of lib/dsp/cfc.mn, run over the recording the program reads. The program's
# own battery holds it to the cell flat 7; numpy must find the same cell. With
# no numpy on the host the leg is skipped.
run_cfc_rec() {
  local rec="$ROOT/tests/frontier/cfc-rec/recording.txt" oflat
  if python3 -c 'import numpy' 2>/dev/null; then
    oflat=$(python3 "$ROOT/tests/frontier/cfc-rec/oracle.py" oracle "$rec" 2>/dev/null \
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

# A data program's oracle: tests/frontier/<name>/oracle.py computes the same
# discrete facts over the file the program reads, and each
# EXPECTED_<KEY>=<value> line it prints must equal the value given here, the
# value the program's own battery holds it to. The oracle runs only if it can
# import its deps; otherwise the leg is skipped.
run_data_validator() {
  local label="$1" data="$2" oracle="$3"
  shift 3
  local expected=("$@")
  local out; out=$(python3 "$oracle" oracle "$data" 2>/dev/null)
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
  run_program "$compiler" positive-hole-post-edit "$copy" 1 "$dir"
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

# The data programs' oracles. Each program in tests/frontier/cfc-rec,
# signal-crucible, stats and text is the battery of its own directory, whose
# first line holds its run to the facts it computes over its file; each oracle,
# a python program that shares nothing with the medium, must compute the same
# facts over the same file. An oracle reads no compiler, so it runs once.
run_cfc_rec
run_signal_crucible
run_data_validator stats-float "$ROOT/tests/frontier/stats/data.txt" \
  "$ROOT/tests/frontier/stats/oracle.py" \
  EXPECTED_ARGMIN=137 EXPECTED_ARGMAX=298 EXPECTED_ABOVE=199
run_data_validator text-bytes "$ROOT/tests/frontier/text/corpus.txt" \
  "$ROOT/tests/frontier/text/oracle.py" \
  EXPECTED_BYTES=429 EXPECTED_COUNT_E=47 EXPECTED_COUNT_T=32 EXPECTED_TOP_LETTER=101

for i in "${!compilers[@]}"; do
  label="${labels[$i]}"
  compiler="${compilers[$i]}"
  [ -f "$compiler" ] || { echo "frontier: compiler not found: $compiler" >&2; exit 2; }
  dir="$ROOT/.build/frontier-gate/$label"
  rm -rf "$dir"
  mkdir -p "$dir"

  echo "frontier: compiler=$label artifact=$compiler"
  capture_persist_shadow "$compiler" "$dir" || continue
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
  run_lsp_hover "$compiler" "$dir" lsp

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
  # `mentl space` is the page — static files the mentl command stages and
  # serves (tools/space-stage.sh, tools/space-serve.py) — and its gate is
  # tools/ide-gate.sh's leg 2 over the staged artifact; the wheel serves no
  # socket since 2026-10-05.
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
