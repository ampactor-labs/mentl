#!/usr/bin/env bash
# Red contracts for executable refusal and context-sensitive hole classification.
# This stays separate from frontier-gate.sh until the proof transaction lands.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
source "$ROOT/tools/wt-env.sh"

selection="${1:-boot}"
case "$selection" in
  boot)
    compiler="$ROOT/boot/mentl.wasm"
    label=boot
    ;;
  fresh)
    cache=$(wt_m2_ensure) || exit 2
    compiler="$ROOT/$cache/m2.wasm"
    label=fresh
    ;;
  *)
    case "$selection" in
      /*) compiler="$selection" ;;
      *) compiler="$ROOT/$selection" ;;
    esac
    label=explicit
    ;;
esac

[ -f "$compiler" ] || {
  echo "proof-exactness: compiler not found: $compiler" >&2
  exit 2
}

# The memo (Hβ.tools.gate-stamp-is-uniform): the fixtures through one
# compiler; a green run on exactly these bytes answers again. FORCE_GATES=1
# re-runs.
pe_key=$(wt_memo_key_run "$compiler" tests/frontier/mn-hole-executable-refusal.mn \
  tests/frontier/mn-proof-debt-surfaced.mn tests/frontier/mn-partial-hole-executable.mn \
  tests/frontier/mn-refine-join-discharges.mn tests/frontier/mn-refine-join-refuses.mn \
  tests/frontier/mn-refine-join-pending.mn tests/frontier/mn-refine-fn-result-refuses.mn \
  tests/frontier/mn-refine-fn-result-discharges.mn tests/frontier/mn-refine-fn-param-pending.mn \
  tests/frontier/mn-refine-fn-param-discharges.mn \
  lib tools/proof-exactness-gate.sh)
if pe_memo=$(wt_memo_hit "proof-exactness-$label" "$pe_key"); then
  printf '%s\n' "$pe_memo"
  echo "  (memo: this compiler already judged these fixtures green — FORCE_GATES=1 re-runs)"
  exit 0
fi

dir="$ROOT/.build/proof-exactness-gate/$label"
rm -rf "$dir"
mkdir -p "$dir"

passes=0
reds=0

pass() {
  echo "  PASS $*"
  passes=$((passes + 1))
}

red() {
  echo "  RED  $*"
  reds=$((reds + 1))
}

expect_refusal() {
  local stem="$1" fixture="$2" diagnostic="$3"
  local wat="$dir/$stem.wat" err="$dir/$stem.err" rc

  wt_run "$compiler" < "$fixture" > "$wat" 2> "$err"
  rc=$?

  if [ "$rc" -ne 0 ]; then
    pass "$stem returned nonzero"
  else
    red "$stem returned zero"
  fi

  if [ ! -s "$wat" ]; then
    pass "$stem emitted no WAT bytes"
  else
    red "$stem emitted $(wc -c < "$wat") WAT bytes"
  fi

  if grep -Eq "$diagnostic" "$err"; then
    pass "$stem preserved $diagnostic"
  else
    red "$stem lost $diagnostic (see $err)"
  fi
}

expect_executable() {
  local stem="$1" fixture="$2" expected="$3"
  local wat="$dir/$stem.wat" wasm="$dir/$stem.wasm"
  local cerr="$dir/$stem.compile.err" aerr="$dir/$stem.assemble.err"
  local rout="$dir/$stem.run.out" rerr="$dir/$stem.run.err" rc

  wt_run "$compiler" < "$fixture" > "$wat" 2> "$cerr"
  rc=$?
  if [ "$rc" -eq 0 ] && ! grep -Eq '(^|: )(E_|V_?Pending)' "$cerr"; then
    pass "$stem compiled without errors or proof debt"
  else
    red "$stem compile failed or reported debt (exit=$rc; see $cerr)"
    return
  fi

  if wt_asm "$wat" "$wasm" 2> "$aerr"; then
    pass "$stem assembled"
  else
    red "$stem assembly failed (see $aerr)"
    return
  fi

  wt_run "$wasm" > "$rout" 2> "$rerr"
  rc=$?
  if [ "$rc" -eq "$expected" ]; then
    pass "$stem ran (exit=$rc)"
  else
    red "$stem ran with exit=$rc, expected=$expected (see $rerr)"
  fi
}

# Honest verification debt SURFACES and compiles — the sound-incomplete
# choice (PLAN §0/§4: undecidable residue accrues visibly, never assume-true,
# never a blanket refusal: the wheel's own self-compile carries structurally
# undecidable obligations, so refuse-on-pending would refuse the medium).
# Contract: exit 0, WAT emitted, the V_Pending projection on stderr.
expect_surfaced() {
  local stem="$1" fixture="$2" diagnostic="$3"
  local wat="$dir/$stem.wat" err="$dir/$stem.err" rc

  wt_run "$compiler" < "$fixture" > "$wat" 2> "$err"
  rc=$?

  if [ "$rc" -eq 0 ]; then
    pass "$stem compiled (exit=0 — honest debt is not a refusal)"
  else
    red "$stem refused (exit=$rc)"
  fi

  if [ -s "$wat" ]; then
    pass "$stem emitted a module"
  else
    red "$stem emitted no WAT"
  fi

  if grep -Eq "$diagnostic" "$err"; then
    pass "$stem surfaced $diagnostic"
  else
    red "$stem lost $diagnostic (see $err)"
  fi
}

echo "proof-exactness: compiler=$label artifact=$compiler"
expect_refusal \
  unresolved-hole \
  "$ROOT/tests/frontier/mn-hole-executable-refusal.mn" \
  'E_UnresolvedHole'
expect_surfaced \
  proof-debt \
  "$ROOT/tests/frontier/mn-proof-debt-surfaced.mn" \
  'V_?Pending'
expect_executable \
  partial-hole \
  "$ROOT/tests/frontier/mn-partial-hole-executable.mn" \
  42
# A claim over a JOIN decides as the AND of the claim over each tail: every
# tail constant and inside the bound discharges (no debt), one tail outside
# refuses, one tail not constant stays honest debt — the three verdicts of
# one distribution (src/verify.mn decide_with_self).
expect_executable \
  join-discharges \
  "$ROOT/tests/frontier/mn-refine-join-discharges.mn" \
  40
expect_refusal \
  join-refuses \
  "$ROOT/tests/frontier/mn-refine-join-refuses.mn" \
  'E_RefinementRejected'
expect_surfaced \
  join-pending \
  "$ROOT/tests/frontier/mn-refine-join-pending.mn" \
  'V_?Pending'
# A FUNCTION crossing an argument edge carries its refinements both ways
# (src/infer.mn fun_refinement_crossing): the RESULT the callee demands is
# judged on the lambda's own body — refused or discharged there — and a
# PARAMETER refinement the callee never proves is honest debt at the edge.
# Every leg read green-by-silence on boot 43aeb30f: the refusal compiled and
# the debt never surfaced.
expect_refusal \
  fn-result-refuses \
  "$ROOT/tests/frontier/mn-refine-fn-result-refuses.mn" \
  'E_RefinementRejected'
expect_executable \
  fn-result-discharges \
  "$ROOT/tests/frontier/mn-refine-fn-result-discharges.mn" \
  40
expect_surfaced \
  fn-param-pending \
  "$ROOT/tests/frontier/mn-refine-fn-param-pending.mn" \
  'V_?Pending'
expect_executable \
  fn-param-discharges \
  "$ROOT/tests/frontier/mn-refine-fn-param-discharges.mn" \
  40

echo "proof-exactness: $passes pass / $reds red"
[ "$reds" -eq 0 ] && wt_memo_put "proof-exactness-$label" "$pe_key" "proof-exactness: $passes pass / $reds red"
[ "$reds" -eq 0 ]
