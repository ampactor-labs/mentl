#!/usr/bin/env bash
# tools/state.sh — THE BOARD: ground in reality, then every gate the repo
# owns, one scoreboard. This file only SEQUENCES — each check lives in
# exactly one home (verify.sh: micros + census, stamped; march.sh: the
# fixpoint ratchet; frontier-gate.sh: the scheduled/authoring contracts;
# proof-exactness-gate.sh: hole-refuses/debt-surfaces/suspension-runs;
# crown-gate.sh: !E soundness; effect-identity-gate.sh: Fail≠Abort).
# The board's shape mirrors its successor — the medium's own verify verb
# (PLAN §6: the bash scaffolds dissolve at L1); until then this command IS
# "is everything true?". --quick runs verify only (the stamp makes an
# unchanged tree instant).
set -u
cd "$(dirname "$0")/.." || exit 2

reds=0

# Run one gate: green → its last line; red → its RED lines + last line.
gate() {
  local label="$1"; shift
  echo "▸ $label"
  local out rc
  out=$("$@" 2>&1); rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "$out" | tail -1 | sed 's/^/    /'
  else
    echo "$out" | grep -E "RED|✗" | head -8 | sed 's/^/    /'
    echo "$out" | tail -1 | sed 's/^/    /'
    reds=$((reds + 1))
  fi
}

echo "▸ GIT"
git log --oneline -3 | sed 's/^/    /'
sc=$(git status --short); echo "    uncommitted: $([ -z "$sc" ] && echo none || echo "$(echo "$sc" | wc -l) file(s)")"
[ -n "$sc" ] && echo "$sc" | sed 's/^/      /'

# ─── WHICH BOOT-SUITE GATES HAVE MEASURED THIS BOOT ───────────────────
# Runs in BOTH modes, before verify, because it is the cheapest true thing
# the board can say and --quick used to say nothing at all. Paid for
# 2026-08-18: an iteration grounded on `state.sh --quick`, read "verify
# green" as "the board is green", built, marched twice, and only then
# learned from the frontier that the prelude floor had gone RED — its own
# doing. Six pins in a row had recorded `frontier: NOT RUN` in
# PROVENANCE, a visible blank nobody was looking at, and the first thing
# an iteration runs was the right place to look.
#
# A stamp is the gate's word that it ran against THIS boot. Only the
# frontier keeps one today; the rest are named unstamped rather than
# silently omitted, because an unreported gate stops being run (PLAN §11
# tripwire 4 — the crown went eleven ledger entries unmentioned while a
# leak rode the whole arc).
echo "▸ STAMPS (which boot-suite gates have measured THIS boot)"
boot_sha=$(sha256sum boot/mentl.wasm 2>/dev/null | cut -d' ' -f1)
stamp=$(cat .build/frontier-stamp 2>/dev/null)
if [ -n "$boot_sha" ] && [ "$stamp" = "$boot_sha" ]; then
  echo "    frontier: green at this boot (${boot_sha:0:12})"
else
  echo "    frontier: NOT RUN at this boot — boot ${boot_sha:0:12}, stamp ${stamp:0:12}${stamp:+ (stale)}"
  echo "              bash tools/frontier-gate.sh  ·  the pre-commit perimeter refuses a"
  echo "              wheel commit without it, so this blank is a landing you cannot make"
fi
echo "    crown · proof-exactness · effect-identity · instrument · threads: no stamp"
echo "              kept — running them is the only way to know (Hβ.tools.gate-stamp-is-uniform)"

echo "▸ VERIFY (micros + census — stamped)"
bash tools/verify.sh || exit 1

if [ "${1:-}" != "--quick" ]; then
  gate "MARCH (the fixpoint ratchet)"                                    bash tools/march.sh
  gate "FRONTIER (scheduled matrix + the ?? authoring workflows)"        bash tools/frontier-gate.sh
  gate "PROOF-EXACTNESS (hole refuses · debt surfaces · suspension runs)" bash tools/proof-exactness-gate.sh
  gate "CROWN (!E soundness crucibles)"                                  bash tools/crown-gate.sh
  gate "EFFECT IDENTITY (Fail ≠ Abort)"                                  bash tools/effect-identity-gate.sh
  gate "INSTRUMENT (can the board go RED?)"                              bash tools/instrument-gate.sh
  gate "THREADS (is the concurrency width what the source says?)"        bash tools/thread-gate.sh

  if [ "$reds" -eq 0 ]; then
    echo "▸ THE BOARD IS WHOLE — every gate green."
  else
    echo "▸ BOARD: $reds gate(s) red."
    exit 1
  fi
fi
