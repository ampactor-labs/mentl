#!/usr/bin/env bash
# crown-gate.sh — the `!E`-soundness gate (the crown). The exit-code micro
# battery cannot express this: a forbidden-effect rejection is a compile-time
# DIAGNOSTIC (E_EffectMismatch), productive-under-error, not an exit code. So the
# crown asserts the diagnostic directly — each crucible compiled SOLO (no lib, so
# the prelude's own positive-path noise doesn't mask the signal) through the
# compiler-under-test.
#
#   leak-*   MUST emit E_EffectMismatch or E_PurityViolated (a body performs a forbidden effect)
#   sound-*  MUST NOT (the gate must not over-reject)
#
# Compiler-under-test: $GATE_WASM (default the keyed boot->m2 artifact), or point
# MENTL_BOOT at any wheel. Pre-L1 shape of `mentl verify`'s crown leg.
set -u
cd "$(dirname "$0")/.." || exit 2
source "$(dirname "$0")/wt-env.sh"

if [ -n "${GATE_WASM:-}" ]; then
  M="$GATE_WASM"
elif [ -n "${MENTL_BOOT:-}" ]; then
  M="$MENTL_BOOT"
else
  C=$(wt_m2_ensure) || { echo "✗ m2 generation trapped"; exit 2; }
  M="$C/m2.wasm"
fi

# A crucible the medium does not yet satisfy is DECLARED by name
# (`crown_expected_red: <name>` in tools/verify-baseline.txt) and judged in
# both directions, the frontier's law: declared and still failing is XRED,
# declared and now passing is RED until the declaration is deleted — so a
# measured false absence sits on the board the day it is found, and the
# declaration cannot outlive the fix.
expected_red_has() {
  grep -qE "^crown_expected_red:[[:space:]]*$1([[:space:]]|\$)" tools/verify-baseline.txt
}

pass=0; fail=0; xred=0
for f in tests/crown/*.mn; do
  name=$(basename "$f" .mn)
  err=$("$WT" run "${WT_RUN_FLAGS[@]}" "$M" < "$f" 2>&1 >/dev/null)
  # A breached ceiling is ONE refusal the medium names by the ceiling's
  # shape — E_PurityViolated when the bound is Pure, E_EffectMismatch
  # otherwise (graph.mn `row_violation`) — so both count, in both
  # directions: a sound crucible refused under either name is over-rejected.
  n=$(printf '%s' "$err" | grep -cE 'E_EffectMismatch|E_PurityViolated')
  case "$name" in
    leak-*)  want="reject"; ok=$([ "$n" -ge 1 ] && echo 1 || echo 0);;
    sound-*) want="accept"; ok=$([ "$n" -eq 0 ] && echo 1 || echo 0);;
    *)         want="?";      ok=0;;
  esac
  if expected_red_has "$name"; then
    if [ "$ok" = 1 ]; then
      echo "✗ crown $name: STALE EXPECTED-RED — it now holds ($want, mismatch=$n); delete"
      echo "    'crown_expected_red: $name' from tools/verify-baseline.txt"
      fail=$((fail+1))
    else
      echo "· crown $name (declared standing failure: want $want, mismatch=$n)"
      xred=$((xred+1))
    fi
  elif [ "$ok" = 1 ]; then echo "✓ crown $name ($want, mismatch=$n)"; pass=$((pass+1))
  else echo "✗ crown $name (want $want, mismatch=$n)"; fail=$((fail+1)); fi
done
echo "── crown: $pass pass / $fail fail / $xred expected-red ──"
[ "$fail" -eq 0 ]
