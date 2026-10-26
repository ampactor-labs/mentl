#!/usr/bin/env bash
# tools/state.sh — THE BOARD, and `mentl land` (--land). It only SEQUENCES;
# each check has one home (verify.sh: micros + census, stamped; march.sh: the
# cost ratchets and the fixed point; the frontier, proof-exactness, crown,
# effect-identity, instrument, thread and ide gates). --quick runs verify only.
#
# --land judges the CANDIDATE the tree compiles to, cheapest first, stopping
# at the first red — self-check, format, the board's bounds (a count that fell
# stops it there: lowering its ceiling moves the wheel every memo keys), the
# march's ratchets and fixed point, the batteries, every gate the board holds
# — and blesses it once, last. The board then reads each leg back from the
# memo its candidate run left (a memo keys the bytes a leg judges, not the
# compiler's name). A candidate that already is the boot goes to the board.
set -u
cd "$(dirname "$0")/.." || exit 2
source tools/wt-env.sh

reds=0

# Run one gate: green → its cost lines + its last line; red → its RED lines +
# last line (the march's `· cost:` and `· image:` are printed either way).
gate() {
  local label="$1"; shift
  echo "▸ $label"
  local out rc
  out=$("$@" 2>&1); rc=$?; GATE_OUT=$out
  GATE_LAST=$(echo "$out" | tail -1)
  if [ "$rc" -eq 0 ]; then
    echo "$out" | grep -E "^· cost:|^· image:|FELL|TIGHTENED" | sed 's/^ */    /'
    echo "    ${GATE_LAST:-✓ (green, silent)}"
  else
    echo "$out" | grep -E "RED|✗|FAIL" | head -8 | sed 's/^/    /'
    echo "    $GATE_LAST"
    reds=$((reds + 1))
  fi
  return "$rc"
}

# A gate with no memo of its own answers from one keyed by its compiler and all
# a gate reads: the wheel, library, fixtures, page, programs, script, baseline.
memo_gate() {  # memo_gate <label> <leg> <compiler> <script> <cmd…>
  local label="$1" leg="$2" compiler="$3" script="$4" key v; shift 4
  key=$(wt_memo_key_run "$compiler" src lib tests ide examples "$script" tools/verify-baseline.txt)
  if v=$(wt_memo_hit "$leg" "$key"); then echo "▸ $label"; echo "    $v (memo: these bytes already ran green)"; return 0; fi
  gate "$label" "$@" && wt_memo_put "$leg" "$key" "$GATE_LAST"
}

if [ "${1:-}" = "--land" ]; then
  C=$(wt_m2_ensure) && wt_m2_place "$C" .build/probe || { echo "✗ the candidate does not build — read .build/m2cache/m2.err"; exit 1; }
  cand="$PWD/.build/probe/m2.wasm"
  if cmp -s "$cand" boot/mentl.wasm; then
    echo "▸ LAND: the boot is this tree's fixed point — the board judges it"
  else
    step() { gate "$@" || { echo "▸ LAND STOPPED at the first red: the work is what it measures."; exit 1; }; }
    mstep() { memo_gate "$@" || { echo "▸ LAND STOPPED at the first red: the work is what it measures."; exit 1; }; }
    mstep "SELF-CHECK (the candidate judges its own source)" self-check "$cand" =self-check env MENTL_BOOT="$cand" mentl check src/main.mn
    mstep "FORMAT" format "$cand" =format env MENTL_BOOT="$cand" mentl fmt --check src lib examples
    step "BOUNDS (the candidate's census and the board's bounds)" env MENTL_BOOT="$cand" mentl verify
    fell=$(echo "$GATE_OUT" | awk '/ — within / && $2 + 0 < $NF + 0')
    [ -z "$fell" ] || { printf '%s\n' "$fell" "▸ LAND STOPPED: lower each fallen ceiling in src/board.mn (a dated reason), then run \`mentl land\` again."; exit 1; }
    step "MARCH (the cost ratchets and the fixed point)" bash tools/march.sh
    for d in micros syntax proposals teach; do step "BATTERY tests/$d" wt_battery "$cand" "tests/$d"; done
    step "CROWN" env MENTL_BOOT="$cand" bash tools/crown-gate.sh
    step "PROOF-EXACTNESS" bash tools/proof-exactness-gate.sh fresh
    step "FRONTIER" bash tools/frontier-gate.sh --compiler fresh
    step "EFFECT IDENTITY" env MENTL_BOOT="$cand" bash tools/effect-identity-gate.sh
    mstep "INSTRUMENT" instrument "$cand" tools/instrument-gate.sh env MENTL_BOOT="$cand" bash tools/instrument-gate.sh
    mstep "THREADS" threads "$cand" tools/thread-gate.sh env MENTL_BOOT="$cand" bash tools/thread-gate.sh
    mstep "IDE" ide "$cand" tools/ide-gate.sh env MENTL_IDE_WASM="$cand" bash tools/ide-gate.sh
    step "REPIN (the march blesses the candidate)" env MARCH_REPIN=1 bash tools/march.sh
    if grep -q 'NARRATIVE UNWRITTEN' boot/PROVENANCE.md; then
      echo "▸ LANDED at boot $(sha256sum boot/mentl.wasm | cut -c1-12): write the pin's narrative line in boot/PROVENANCE.md"
      echo "  (what landed, the property a person sees, the verb that shows it); \`mentl land\` then reads the board back."
      exit 0
    fi
  fi
fi

echo "▸ GIT"
git log --oneline -3 | sed 's/^/    /'
sc=$(git status --short); echo "    uncommitted: $([ -z "$sc" ] && echo none || echo "$(echo "$sc" | wc -l) file(s)")"
[ -n "$sc" ] && echo "$sc" | sed 's/^/      /'

# The cheapest true things the board can say, in both modes: whether the gate
# that refuses commits is installed, and which boot the frontier and the
# determinism probe last measured.
echo "▸ STAMPS (which boot-suite gates have measured THIS boot)"
hookspath=$(git config core.hooksPath 2>/dev/null)
if [ "$hookspath" = ".githooks" ]; then
  echo "    perimeter: pre-commit INSTALLED (core.hooksPath → .githooks)"
else
  echo "    perimeter: ✗ RED — pre-commit NOT INSTALLED (core.hooksPath='${hookspath:-unset}')"
  echo "               every gate below is advisory until it is on: bash tools/setup-git-hooks.sh"
fi
boot_sha=$(sha256sum boot/mentl.wasm 2>/dev/null | cut -d' ' -f1)
stamp=$(cat .build/frontier-stamp 2>/dev/null)
if [ -n "$boot_sha" ] && [ "$stamp" = "$boot_sha" ]; then
  echo "    frontier: green at this boot (${boot_sha:0:12})"
else
  echo "    frontier: NOT RUN at this boot — boot ${boot_sha:0:12}, stamp ${stamp:0:12}${stamp:+ (stale)}"
  echo "              the pre-commit perimeter refuses a wheel commit without it"
fi
# m2 == m3 is the fixed point; whether the same wasm on the same input emits
# the same bytes is a separate question, probed on a cadence, not per landing.
det=$(cat .build/gate/fixpoint-stamp 2>/dev/null)
if [ -n "$boot_sha" ] && [ "$det" = "$boot_sha" ]; then
  echo "    determinism: m3 == m4 confirmed at this boot (${boot_sha:0:12})"
else
  echo "    determinism: NOT PROBED at this boot — bash tools/march.sh --fixpoint"
fi

echo "▸ VERIFY (micros + census — stamped)"
bash tools/verify.sh || exit 1

if [ "${1:-}" != "--quick" ]; then
  boot="$PWD/boot/mentl.wasm"
  memo_gate "MARCH (the fixpoint ratchet)" march "$boot" tools/march.sh bash tools/march.sh
  gate "FRONTIER (scheduled matrix + the ?? authoring workflows)"        bash tools/frontier-gate.sh
  gate "PROOF-EXACTNESS (hole refuses · debt surfaces · suspension runs)" bash tools/proof-exactness-gate.sh
  gate "CROWN (!E soundness crucibles)"                                  bash tools/crown-gate.sh
  gate "EFFECT IDENTITY (Fail ≠ Abort)"                                  bash tools/effect-identity-gate.sh
  memo_gate "INSTRUMENT (can the board go RED?)" instrument "$boot" tools/instrument-gate.sh bash tools/instrument-gate.sh
  memo_gate "THREADS (is the concurrency width what the source says?)" threads "$boot" tools/thread-gate.sh bash tools/thread-gate.sh
  # The resident session's gate (node twin + headless browser); its browser
  # leg skips loudly on a machine without one.
  memo_gate "IDE (the resident session — node twin + headless browser)" ide "$boot" tools/ide-gate.sh bash tools/ide-gate.sh

  if [ "$reds" -eq 0 ]; then
    echo "▸ THE BOARD IS WHOLE — every gate green."
  else
    echo "▸ BOARD: $reds gate(s) red."
    exit 1
  fi
fi
