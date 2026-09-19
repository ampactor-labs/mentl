#!/usr/bin/env bash
# instrument-gate.sh — can the board go RED?
#
# The fleet's completeness critic found the thing that governs the whole bar:
# THIRTY roster items were independently refuted for having a gate that cannot
# fail. Thirty authors do not make the same mistake by coincidence — "a good
# design has a gate" is a pattern, so thirty agents emitted gate-shaped text
# without ever checking it could go red. Its verdict: "a green board that cannot
# go red is the most expensive artifact in the repo."
#
# The cause was one line: diagnostics_handler saw every diagnostic, printed it,
# and threw the severity away. So `mentl check` on a missing module printed
# E_MissingModule and exited 0, and a program with a live E_TypeMismatch emitted
# 77 lines of WAT. Every downstream gate degenerated to "does wat2wasm accept the
# bytes."
#
# This gate guards the INSTRUMENT itself — the thing every other gate reads
# through. Each leg was demonstrated RED against the unfixed tree before its fix
# landed (the discipline the critic's meta-gate demands: run it against the
# broken tree and confirm it fails, or it is evidence of nothing).
#
# The NEGATIVE CONTROLS are the load-bearing half: a clean program must still
# check 0 and still emit bytes. Without them this gate would pass by refusing
# everything, which is the same vacuity one layer up.
#
# Usage: tools/instrument-gate.sh
# Exit:  0 the instrument reads, 1 it lies.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tools/wt-env.sh"

# ABSOLUTE. This gate cd's into a temp dir, so a relative boot path resolves to
# nothing, wasmtime fails to load the module, and EVERY refusal leg passes
# because nothing ran — the gate against vacuous gates, vacuous. That is not a
# hypothetical: it is what this script did on its first run, and only the
# clean-program negative control exposed it. Keep the controls.
BOOT="${INSTRUMENT_BOOT:-$ROOT/boot/mentl.wasm}"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
printf 'fn main() = 7\n'                                   > "$T/ok.mn"
printf 'import totally/absent\nfn main() = 7\n'            > "$T/missing.mn"
printf 'fn f(xs: List) -> Int = 1\nfn main() = f([1,2])\n' > "$T/typeerr.mn"

m() { "$WT" run "${WT_RUN_FLAGS[@]}" --dir "$T" --dir /tmp --dir "$ROOT::/mentl-home" "$BOOT" "$@"; }
fail=0
ck() { # name, actual, wanted
  if [ "$2" = "$3" ]; then echo "  ✓ $1: $2"; else echo "  ✗ $1: $2 (want $3)"; fail=1; fi
}

cd "$T"
# check's exit code IS the diagnostic ledger, read live.
m check missing >/dev/null 2>&1; ck "check <missing module> refuses" "$?" "1"
m check typeerr >/dev/null 2>&1; ck "check <type error> refuses"     "$?" "1"
m check ok      >/dev/null 2>&1; ck "check <clean> accepts"          "$?" "0"

# The emit refuses on an ARMED class (diag_refuses; E_MissingModule armed
# 2026-07-17 because its census on the wheel is 0).
b=$(m compile missing 2>/dev/null | wc -c); ck "emit refuses armed class (0 bytes)" "$b" "0"
m compile missing >/dev/null 2>&1;          ck "  and exits nonzero"                "$?" "1"

# THE BOARD — `mentl verify` must be able to say NOTHING WAS MEASURED.
# Its first run reported twelve bounds holding on a graph that held no source:
# the driver it used judged without leaving the weave the census walks, so every
# shape counted zero and the verb answered green. That is this gate's own class
# one layer up — a board that measures nothing while still being reported — so
# it is pinned here rather than remembered. A target that never joined the weave
# REFUSES; the wheel itself still answers with real counts.
m verify missing >/dev/null 2>&1; ck "verify <unread weave> refuses" "$?" "1"
bl=$(cd "$ROOT" && m verify src/main.mn 2>/dev/null | grep -c 'within\|ROSE')
if [ "$bl" -gt 0 ]; then echo "  ✓ verify still measures the wheel: $bl bound(s)"; else echo "  ✗ verify measured nothing on the wheel — the board is vacuous"; fail=1; fi

# NEGATIVE CONTROL — the gate must not pass by refusing everything.
b=$(m compile ok 2>/dev/null | wc -c)
if [ "$b" -gt 0 ]; then echo "  ✓ clean program still emits: $b bytes"; else echo "  ✗ clean program emits nothing — over-refusal"; fail=1; fi

cd "$ROOT"
if [ "$fail" -ne 0 ]; then
  echo "✗ THE INSTRUMENT LIES — a gate reading through it is evidence of nothing."
  exit 1
fi
echo "· the instrument reads: refusals refuse, clean passes."
exit 0
