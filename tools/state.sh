#!/usr/bin/env bash
# tools/state.sh prints the board, and with --land it is `mentl land`. It only
# orders the checks; each check lives in its own script. --quick runs verify
# alone.
#
# --land builds the candidate this tree compiles to and judges it. The
# self-check, the format, the board's bounds and the march run one after
# another and stop at the first failure. The batteries and the gates that
# measure no time then run side by side, and the pin comes last. Afterwards
# the board reads each result back from the memo the candidate's run left,
# keyed by the bytes it judged.
set -u
cd "$(dirname "$0")/.." || exit 2
source tools/wt-env.sh

reds=0

# Run one gate and print its verdict, the lines that matter and its seconds.
gate() {
  local label="$1"; shift
  echo "▸ $label"
  local out rc t0=$SECONDS
  out=$("$@" 2>&1); rc=$?; GATE_OUT=$out
  GATE_LAST=$(echo "$out" | tail -1)
  if [ "$rc" -eq 0 ]; then
    echo "$out" | grep -E "^· cost:|^· image:|FELL|TIGHTENED" | sed 's/^ */    /'
    echo "    ${GATE_LAST:-✓ (green, silent)} · $((SECONDS - t0))s"
  else
    echo "$out" | grep -E "RED|✗|FAIL" | head -8 | sed 's/^/    /'
    echo "    $GATE_LAST · $((SECONDS - t0))s"
    reds=$((reds + 1))
  fi
  return "$rc"
}

# A gate with no memo of its own answers from one keyed by its compiler and all it reads.
memo_gate() {  # memo_gate <label> <leg> <compiler> <script> <cmd…>
  local label="$1" leg="$2" compiler="$3" script="$4" key v; shift 4
  key=$(wt_memo_key_run "$compiler" src lib tests ide examples "$script" tools/verify-baseline.txt)
  if v=$(wt_memo_hit "$leg" "$key"); then echo "▸ $label"; echo "    $v (memo: these bytes already ran green)"; return 0; fi
  gate "$label" "$@" && wt_memo_put "$leg" "$key" "$GATE_LAST"
}

# Run gates side by side. Each writes what it prints and its exit code to a
# file; `joined` waits, prints them in starting order and counts the failures.
SIDE=$(mktemp -d); nside=0; trap 'rm -rf "$SIDE"' EXIT
side() { nside=$((nside + 1)); ( "$@" > "$SIDE/$nside.out" 2>&1; echo $? > "$SIDE/$nside.rc" ) & }
joined() {
  local i t0=$SECONDS; wait
  for i in $(seq 1 "$nside"); do cat "$SIDE/$i.out"; [ "$(cat "$SIDE/$i.rc")" -eq 0 ] || reds=$((reds + 1)); done
  echo "▸ $nside checks side by side · $((SECONDS - t0))s"; nside=0
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
    # Batteries write modules under .build/battery by fixture name alone. micros and frontier
    # hold two fixtures of one name, so they share a lane, and effect-identity runs after.
    battery() { local d rc=0; for d in "$@"; do gate "BATTERY tests/$d" wt_battery "$cand" "tests/$d" || rc=1; done; return $rc; }
    side battery micros frontier; for d in syntax proposals teach crown; do side battery "$d"; done
    side gate "PROOF-EXACTNESS" bash tools/proof-exactness-gate.sh fresh
    side gate "FRONTIER" bash tools/frontier-gate.sh --compiler fresh
    side memo_gate "INSTRUMENT" instrument "$cand" tools/instrument-gate.sh env MENTL_BOOT="$cand" bash tools/instrument-gate.sh
    joined; [ "$reds" -eq 0 ] || { echo "▸ LAND STOPPED: $reds check(s) failed above. The work is what they measure."; exit 1; }
    step "EFFECT IDENTITY" env MENTL_BOOT="$cand" bash tools/effect-identity-gate.sh
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

# Whether the commit hook is installed, and which boot the gates last measured.
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
# Whether one compiler on one input writes the same bytes twice (m3 == m4).
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
  side gate "FRONTIER (scheduled matrix + the ?? authoring workflows)"        bash tools/frontier-gate.sh
  side gate "PROOF-EXACTNESS (hole refuses · debt surfaces · suspension runs)" bash tools/proof-exactness-gate.sh
  side gate "BATTERY tests/crown (!E soundness crucibles)"                    wt_battery "$boot" tests/crown
  side memo_gate "INSTRUMENT (can the board go RED?)" instrument "$boot" tools/instrument-gate.sh bash tools/instrument-gate.sh; joined
  gate "EFFECT IDENTITY (Fail ≠ Abort)"                                  bash tools/effect-identity-gate.sh
  memo_gate "THREADS (is the concurrency width what the source says?)" threads "$boot" tools/thread-gate.sh bash tools/thread-gate.sh
  # The browser leg of this gate skips, and says so, on a machine without one.
  memo_gate "IDE (the resident session — node twin + headless browser)" ide "$boot" tools/ide-gate.sh bash tools/ide-gate.sh

  if [ "$reds" -eq 0 ]; then
    echo "▸ THE BOARD IS WHOLE — every gate green."
  else
    echo "▸ BOARD: $reds gate(s) red."
    exit 1
  fi
fi
