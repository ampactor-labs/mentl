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
# A stamp is the gate's word that it ran against THIS boot. The frontier
# keeps one; the board legs memoize by their inputs (below); the gates with
# neither are named rather than silently omitted, because an unreported gate
# stops being run (PLAN §11 tripwire 4 — the crown went eleven ledger entries
# unmentioned while a leak rode the whole arc).
echo "▸ STAMPS (which boot-suite gates have measured THIS boot)"
# THE PERIMETER ITSELF IS A GATE, and it was the one nobody reported. Every
# line below asks whether a gate has RUN; none asked whether the gate that
# refuses commits is INSTALLED. Measured 2026-09-14: core.hooksPath was unset
# and .git/hooks/pre-commit did not exist, so .githooks/pre-commit — whose own
# comment claims it "survives any editor, any model, any future tooling
# change" — had run on ZERO commits, while the frontier line below asserted
# "the pre-commit perimeter refuses a wheel commit without it". Tripwire 4 one
# level deeper: not a gate that stopped being reported, a gate that was never
# switched on, and a board that spoke of it as though it were.
hookspath=$(git config core.hooksPath 2>/dev/null)
if [ "$hookspath" = ".githooks" ]; then
  echo "    perimeter: pre-commit INSTALLED (core.hooksPath → .githooks)"
else
  echo "    perimeter: ✗ RED — pre-commit NOT INSTALLED (core.hooksPath='${hookspath:-unset}')"
  echo "               drift-audit and verify refuse nothing at commit time; every"
  echo "               gate below is advisory until this is on. bash tools/setup-git-hooks.sh"
fi
boot_sha=$(sha256sum boot/mentl.wasm 2>/dev/null | cut -d' ' -f1)
stamp=$(cat .build/frontier-stamp 2>/dev/null)
if [ -n "$boot_sha" ] && [ "$stamp" = "$boot_sha" ]; then
  echo "    frontier: green at this boot (${boot_sha:0:12})"
else
  echo "    frontier: NOT RUN at this boot — boot ${boot_sha:0:12}, stamp ${stamp:0:12}${stamp:+ (stale)}"
  echo "              bash tools/frontier-gate.sh  ·  the pre-commit perimeter refuses a"
  echo "              wheel commit without it, so this blank is a landing you cannot make"
fi
# Since 2026-09-26 the march's board legs memoize their green under the sha of
# exactly what they read (.build/gate/memo, tools/wt-env.sh wt_memo_*), so
# running one costs nothing when nothing it reads changed — the honest
# answer to "has it run?" is to run it.
echo "    crown · proof-exactness · effect-identity · frontier: memoized by what they read —"
echo "              a run answers in ~0s when its inputs are unchanged (.build/gate/memo)"
echo "    instrument · threads · ide: no memo kept — running them is the only way to know"
# DETERMINISM IS NOT ON THIS BOARD, and saying so is the whole point of the line.
# `march.sh` asserts m2 == m3, which IS the fixed point in the boot era. On a
# CLEAN march the m4 leg is deductively redundant — if m2 == m3 byte-for-byte
# then m3 IS m2, so m4 = m3(src) = m2(src) = m3 follows. What does NOT follow is
# that the same wasm on the same input produces the same bytes, and
# `--fixpoint` is the only thing that tests it. Measured 2026-09-21: nothing
# invoked that flag, and the last twelve pins were all CLEAN — so the leg had
# not run in twelve landings. Tripwire 4 one layer down: a leg that only runs on
# FAILURE has never been exercised on SUCCESS. It is reported here rather than
# run here, because a determinism probe is a cadence (every Nth pin, or on
# demand) and not a per-landing cost — and an unreported absence is how the
# crown went eleven entries unmentioned.
det=$(cat .build/gate/fixpoint-stamp 2>/dev/null)
if [ -n "$boot_sha" ] && [ "$det" = "$boot_sha" ]; then
  echo "    determinism: m3 == m4 confirmed at this boot (${boot_sha:0:12})"
else
  echo "    determinism: NOT PROBED at this boot — m2 == m3 is the fixpoint and holds;"
  echo "              this is the separate question of whether the same wasm on the same"
  echo "              input emits the same bytes. bash tools/march.sh --fixpoint"
fi

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
  # THE STANDING CURSOR'S OWN TERMINAL GATE, and it was not on this board.
  # PLAN §11 Arc E names `ide-gate green Node + headless Chrome` as the bar the
  # whole Space spine is measured against, and §11.2 asserts the resident
  # session is "verified green across Node and headless Chrome
  # (tools/ide-gate.sh)" — while NOTHING invoked the script: not this file, not
  # a hook, not tools/ci/run-board.sh. Tripwire 4 exactly ("a gate that stops
  # being reported stops being run"), standing on the arc the plan calls the
  # production target, with a green claim already written over it. Its leg 2
  # skips loudly without chrome, which is the honest shape for a board that
  # runs on machines that may not have one.
  gate "IDE (the resident session — node twin + headless browser)"       bash tools/ide-gate.sh

  if [ "$reds" -eq 0 ]; then
    echo "▸ THE BOARD IS WHOLE — every gate green."
  else
    echo "▸ BOARD: $reds gate(s) red."
    exit 1
  fi
fi
