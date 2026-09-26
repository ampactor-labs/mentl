#!/usr/bin/env bash
# Exact effect-namespace gate. The runtime micro proves dispatch isolation;
# the declaration census prevents the flat wheel input from silently restoring
# either duplicate name before import-edge collision diagnostics are complete.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tools/wt-env.sh"

# The memo (Hβ.tools.gate-stamp-is-uniform): the declaration census reads src
# and lib, the micro runs through one compiler — a green run on exactly these
# answers again. FORCE_GATES=1 re-runs.
M="${GATE_WASM:-${MENTL_BOOT:-boot/mentl.wasm}}"
ei_key=$(wt_memo_key_run "$M" src lib tests/micros/mn-effect-identity.mn tools/run-micro.sh tools/effect-identity-gate.sh)
if ei_memo=$(wt_memo_hit effect-identity "$ei_key"); then
  printf '%s\n' "$ei_memo"
  echo "  (memo: these inputs already passed — FORCE_GATES=1 re-runs)"
  exit 0
fi

fail=0

expect_count() {
  local label="$1" expected="$2" pattern="$3"
  local count
  count=$(rg -n --glob '*.mn' "$pattern" src lib 2>/dev/null | wc -l)
  if [[ "$count" -eq "$expected" ]]; then
    printf 'PASS %s (%s)\n' "$label" "$count"
  else
    printf 'FAIL %s: got %s, expected %s\n' "$label" "$count" "$expected"
    rg -n --glob '*.mn' "$pattern" src lib 2>/dev/null || true
    fail=1
  fi
}

expect_count 'Abort declarations' 1 '^effect Abort\b'
expect_count 'Fail declarations' 1 '^effect Fail\b'
expect_count 'Alloc declarations' 1 '^effect Alloc\b'
expect_count 'fail_exit handlers' 1 '^handler fail_exit\b'
expect_count 'abort_exit handlers' 0 '^handler abort_exit\b'
expect_count 'DSP alloc_buffer residue' 0 '\balloc_buffer\b'

RTLIBS=(
  lib/memory.mn
  lib/strings.mn
  lib/lists.mn
  lib/prelude.mn
)
out=$(MENTL_BOOT="$M" tools/run-micro.sh \
  tests/micros/mn-effect-identity.mn 81 "${RTLIBS[@]}" 2>&1)
if [[ "$out" == PASS* ]]; then
  printf '%s\n' "$out"
else
  printf '%s\n' "$out"
  fail=1
fi

[[ "$fail" -eq 0 ]] && wt_memo_put effect-identity "$ei_key" "effect-identity: the declaration census and the dispatch micro pass"
exit "$fail"
