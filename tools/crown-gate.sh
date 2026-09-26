#!/usr/bin/env bash
# crown-gate.sh — the `!E`-soundness gate (the crown). The exit-code micro
# battery cannot express this: a forbidden-effect rejection is a compile-time
# DIAGNOSTIC (E_EffectMismatch), productive-under-error, not an exit code. So the
# crown asserts the diagnostic directly — each crucible compiled SOLO (no lib, so
# the prelude's own positive-path noise doesn't mask the signal) through the
# compiler-under-test.
#
#   leak-*   MUST emit E_EffectMismatch (a body performs a forbidden effect)
#   sound-*  MUST NOT (the gate must not over-reject)
#
# Compiler-under-test: $GATE_WASM (default the keyed boot->m2 artifact), or point
# MENTL_BOOT at any wheel. Pre-L1 shape of `mentl verify --crown`.
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

# The memo (Hβ.tools.gate-stamp-is-uniform): the verdict is a function of the
# compiler bytes and the crucibles, so a green run on exactly these answers
# again without recompiling sixty programs. FORCE_GATES=1 re-runs.
crown_key=$(wt_memo_key_run "$M" tests/crown tools/crown-gate.sh)
if crown_memo=$(wt_memo_hit crown "$crown_key"); then
  printf '%s\n' "$crown_memo"
  echo "  (memo: this compiler already judged these crucibles green — FORCE_GATES=1 re-runs)"
  exit 0
fi

pass=0; fail=0
for f in tests/crown/*.mn; do
  name=$(basename "$f" .mn)
  err=$("$WT" run "${WT_RUN_FLAGS[@]}" "$M" < "$f" 2>&1 >/dev/null)
  n=$(printf '%s' "$err" | grep -c 'E_EffectMismatch')
  case "$name" in
    leak-*)  want="reject"; ok=$([ "$n" -ge 1 ] && echo 1 || echo 0);;
    sound-*) want="accept"; ok=$([ "$n" -eq 0 ] && echo 1 || echo 0);;
    *)         want="?";      ok=0;;
  esac
  if [ "$ok" = 1 ]; then echo "✓ crown $name ($want, mismatch=$n)"; pass=$((pass+1))
  else echo "✗ crown $name (want $want, mismatch=$n)"; fail=$((fail+1)); fi
done
echo "── crown: $pass pass / $fail fail ──"
[ "$fail" -eq 0 ] && wt_memo_put crown "$crown_key" "── crown: $pass pass / $fail fail ──"
[ "$fail" -eq 0 ]
