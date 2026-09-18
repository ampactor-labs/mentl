#!/usr/bin/env bash
# march-gate.sh — the rung + micro battery through the WHEEL-emitted m2.
#
# The road is walked in rungs: m2 := boot(wheel) must compile ever-larger
# inputs END-TO-END (compile → assemble → run → correct exit). Each rung
# that regresses names the dig site; each rung that clears extends the road.
#
#   bash tools/march-gate.sh                     # m2 (cached), run all rungs
#   bash tools/march-gate.sh --no-build          # reuse .build/probe/m2.wasm
#   bash tools/march-gate.sh --micros            # rungs, THEN the full micro
#                                                 # battery compiled through m2
#   bash tools/march-gate.sh --no-build --micros # reuse m2.wasm, rungs + micros
#
# The --micros tier runs EVERY tests/micros/mn-NAME.mn through m2, reading
# each micro's own `// expect: N` first-line oracle (the same header
# verify.sh reads — the expectation lives ON the artifact it gates, never in
# a side-table; the baseline's `micro:` registry was a second home that sat
# EMPTY for its whole life, so this tier gated nothing until 2026-07-24).
# The claim upgrades from "boot compiles and runs it" (verify.sh) to "m2 —
# the wheel compiled by the fixpoint wheel — compiles and runs it". It is a
# SCOREBOARD, not a gate:
# a ✗ here names a dig
# site for the next session, never a wheel bug to chase inline (CLAUDE.md ⟲
# — census, don't chase moles). Same RT link set as the +rt rungs
# (memory+strings+lists+prelude) for every micro — m2 has reachability-from-
# main, so an unused vocabulary fn drops silently; withholding it would be the
# harness lying, not a regression (verify.sh's own reasoning, carried here).
#
# Reading a FAIL:
#   compile-trap → wasmtime backtrace names the m2 fn; binary-patch probe it
#     (see memory handoff: patch .build/probe/m2.wat, print via
#     `call $eprint_string (i32.const 0) s` / `call $int_to_str (i32.const 0) n`,
#     separator = a REAL interned string const — offsets shift per build).
#   assemble-fail → the wheel's EMIT is wrong (undeclared local / missing
#     $ftN / bad WAT) — fix src/backends/wasm.mn. (This line used to end "mirror
#     the seed if shared"; the seed was deleted 7401c4b, so there is nothing to
#     mirror — the wheel's emit is the only home.)
#   run-wrong-exit → a silent miscompile — the worst class; bisect the rung's
#     source, then WABT-diff the emitted fn (wasm-objdump -d, wt_func).
#
# First-light PASSED (2026-07-10, m3 == m4); the destiny is absorption into
# `mentl march` (the ⟳ absorption queue) — the script stays as the battery's
# bash tail meanwhile.
set -u
cd "$(dirname "$0")/.." || exit 2
source "$(dirname "$0")/wt-env.sh"
OUT="${PROBE_OUT:-$(pwd)/.build/probe}"; mkdir -p "$OUT"
export TMPDIR="$OUT"
G="$OUT/gate"; mkdir -p "$G"

DO_BUILD=1
DO_MICROS=0
for a in "$@"; do
  case "$a" in
    --no-build) DO_BUILD=0 ;;
    --micros)   DO_MICROS=1 ;;
    *) echo "march-gate: unknown flag '$a' (want --no-build / --micros)" >&2; exit 2 ;;
  esac
done

if [ "$DO_BUILD" = 1 ]; then
  # m2 := boot(wheel) — the pinned fixpoint wheel compiles the wheel
  # (boot/PROVENANCE.md), so every rung and micro below runs through a
  # WHEEL-emitted compiler. Reads the ONE keyed boot(wheel) artifact
  # (wt_m2_ensure, .build/m2cache — shared with verify's census and
  # march.sh): instant when another gate already compiled this state.
  echo "── m2 (boot — the pinned fixpoint wheel — compiles the wheel) ──"
  C=$(wt_m2_ensure) || { echo "✗ m2 generation TRAPPED (see $WT_M2CACHE/m2.err)"; tail -3 "$WT_M2CACHE/m2.err"; exit 1; }
  wt_m2_place "$C" "$OUT"; cp -f "$C/wheel.mn" "$OUT/wheel.mn"
  echo "m2: boot(wheel) via $C — $(wc -l < "$OUT/m2.wat") lines (key $(cut -c1-12 "$C/key"))"
  echo "✓ m2.wasm ($(stat -c%s "$OUT/m2.wasm") bytes)"
fi
[ -f "$OUT/m2.wasm" ] || { echo "✗ no m2.wasm — run without --no-build"; exit 1; }
# GATE_WASM: the compiler-under-test. Default m2 (boot-sparked wheel); point it
# at an assembled m3 to run the SAME rung+micro battery through the wheel's own
# child — the phase-3 correctness half (a buggy compiler self-reproduces to a
# WRONG fixpoint, so diff-empty alone proves nothing; PLAN §6).
GATE_WASM="${GATE_WASM:-$OUT/m2.wasm}"

# Every verdict names the binary it judged: a --no-build run reuses whatever
# .build/probe/m2.wasm holds, and a scoreboard against a STALE probe is the
# forensic-law trap (comparable only within one binary) — the resurrected
# micro tier's first-ever firing hit exactly that (a prior-pin probe re-ran
# the pre-fix 20-not-25). The sha line makes a stale verdict self-identifying.
gate_wasm_stamp() {
  [ -f "$GATE_WASM" ] && echo "── judging m2 sha $(sha256sum "$GATE_WASM" | cut -c1-16) ($GATE_WASM) ──"
}

# Ratchet (2026-07-04): the h=0 concat class is CLOSED — the str_concat-on-lists
# root (union_row's match binders) died with the seed's ctor-payload proof
# channel (b73748c). A proof-less list-`++` reappearing is a NEW silent-
# miscompile site; fail loud here, never let it rejoin the string default.
H0=$(grep -c 'W_ConcatUnproven h=0' "$OUT/m2.err" 2>/dev/null)
if [ "${H0:-0}" != "0" ]; then
  echo "✗ RATCHET: W_ConcatUnproven h=0 count=$H0 (must be 0 — a binder ++ lost its List/String proof)"
  exit 1
fi

# The trio + prelude: strings.mn's parse_int_base calls prelude's
# parse_int, so the honest link set includes it — m2 emits the whole
# input (no reachability-from-main yet, unlike the seed), so an
# under-linked dependency surfaces as an undefined global at assemble.
RT="${MENTL_RT_LIBS[*]}"
pass=0; fail=0
fail_m=0
# fail_m is the MICRO tier's counter and must exist outside the micros
# block (set -u) because the exit sums BOTH tiers — the 2026-07-31 leash
# proof caught the old `exit $fail` reading every all-rungs-green run as
# battery green while three micros sat red (the gate-that-cannot-fail
# class, fourth catch; the battery-gated repin trusted it and falsely
# blessed).
fail_m=0
gate_wasm_stamp

# rung <name> <expected-exit> <<'EOF' ... source ... EOF
rung() {
  local name="$1" want="$2" src="$G/$1.mn"
  cat > "$src"
  "$WT" run "${WT_RUN_FLAGS[@]}" "$GATE_WASM" < "$src" > "$G/$1.wat" 2> "$G/$1.err"
  local rc=$?
  if [ $rc -ne 0 ]; then
    echo "✗ $name: m2 COMPILE trap=$(grep -m1 -oE '!\S+' "$G/$1.err" | head -1) (backtrace: $G/$1.err)"
    fail=$((fail+1)); return
  fi
  if ! wt_asm "$G/$1.wat" "$G/$1.wasm" 2> "$G/$1.w2e"; then
    echo "✗ $name: ASSEMBLE — $(head -1 "$G/$1.w2e" | sed 's/.*error/error/')"
    fail=$((fail+1)); return
  fi
  "$WT" run "${WT_RUN_FLAGS[@]}" "$G/$1.wasm" > /dev/null 2> "$G/$1.run.err"
  local got=$?
  if [ "$got" = "$want" ]; then echo "✓ $name = $got"; pass=$((pass+1))
  else echo "✗ $name: RUN exit=$got want=$want"; fail=$((fail+1)); fi
}

echo "── rungs (each: m2-compile → wat2wasm → run → exit) ──"
rung one-main 7 <<'EOF'
fn main() = 7
EOF

rung call 7 <<'EOF'
fn id(x) = x
fn main() = id(7)
EOF

rung two-lets 3 <<'EOF'
let a = 1
let b = 2
fn main() = a + b
EOF

rung branch 9 <<'EOF'
fn pick(x) = if x > 3 { 9 } else { 1 }
fn main() = pick(5)
EOF

rung match-adt 4 <<'EOF'
type Opt = Some(Int) | Nothing
fn get(o) = match o {
  Some(v) => v,
  Nothing => 0
}
fn main() = get(Some(4))
EOF

# rungs below carry the runtime trio (the vocabulary — every real
# program links it; verify.sh RTLIBS convention)
rungrt() {
  local name="$1" want="$2" src="$G/$1.mn"
  { cat $RT; cat; } > "$src"
  "$WT" run "${WT_RUN_FLAGS[@]}" "$GATE_WASM" < "$src" > "$G/$1.wat" 2> "$G/$1.err"
  local rc=$?
  if [ $rc -ne 0 ]; then
    echo "✗ $name(+rt): m2 COMPILE trap=$(grep -m1 -oE '!\S+' "$G/$1.err" | head -1)"
    fail=$((fail+1)); return
  fi
  if ! wt_asm "$G/$1.wat" "$G/$1.wasm" 2> "$G/$1.w2e"; then
    echo "✗ $name(+rt): ASSEMBLE — $(head -1 "$G/$1.w2e" | sed 's/.*error/error/')"
    fail=$((fail+1)); return
  fi
  "$WT" run "${WT_RUN_FLAGS[@]}" "$G/$1.wasm" > /dev/null 2> "$G/$1.run.err"
  local got=$?
  if [ "$got" = "$want" ]; then echo "✓ $name(+rt) = $got"; pass=$((pass+1))
  else echo "✗ $name(+rt): RUN exit=$got want=$want"; fail=$((fail+1)); fi
}

rungrt pipe-hole 15 <<'EOF'
fn add(a, b) = a + b
fn main() = 5 |> add(??, 10)
EOF

rungrt handler 5 <<'EOF'
effect W { emit(s: String) }
handler w { emit(s) => resume() }
fn main() = { emit("x")
 5 } ~> w
EOF

rungrt hof-map 6 <<'EOF'
fn main() = {
  let xs = map((x) => x * 2, [1, 2])
  list_index(xs, 0) + list_index(xs, 1)
}
EOF

echo "── scoreboard: $pass pass / $fail fail ──"
if [ $fail = 0 ]; then
  echo "ALL RUNGS CLEAR — next gate: the micro battery through m2, then full pass-2:"
  echo "  bash tools/march-gate.sh --no-build --micros"
  echo "  bash tools/march.sh   # the m2→m3 fixed-point march"
fi

# ── micros-through-m2 — the promoted stress tier (--micros only) ──────────
# ONE battery, one home: the medium's own `test` verb compiles, runs and
# judges every fixture in one process (wt_battery reads its verdict). This
# gate contributes the compiler under test — the candidate m2, not the
# pinned boot.
if [ "$DO_MICROS" = 1 ]; then
  echo "── micros-through-m2 (one process: m2 compiles, runs and judges each fixture) ──"
  wt_battery "$GATE_WASM" tests/micros "micros-through-m2" || fail_m=1
fi

exit $((fail + fail_m))
