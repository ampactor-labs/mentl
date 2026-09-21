#!/usr/bin/env bash
# THE CONSULT GATE — no write to wheel source the medium was not asked about.
#
# The logic lives here, in the tracked tree, because .claude/ is gitignored:
# the hooks that call this are local wiring, and an enforcement that exists
# only in one working copy is not an enforcement. Two entry points, both
# driven by the Claude Code hook contract:
#
#   record <command>   a medium verb ran — mark every wheel path it named
#   require <path>     about to write <path> — exit 2 unless it was marked
#
# OFF THE BOARD BY DESIGN, AND THE COST IS REAL. tools/state.sh does not run
# this and must not: it is not a gate over the tree, it is a per-edit hook
# with two entry points the Claude Code contract calls. But the wiring that
# calls it lives in .claude/, which is gitignored — so on a FRESH CLONE this
# file is present and inert, and the enforcement its own header calls "not an
# enforcement" when it exists in one working copy is exactly what a new
# checkout gets. Measured 2026-09-21 on a container clone: no .claude/ at all.
# The absence is named here rather than discovered again; the fix is the hook
# contract landing in the tracked tree, not this file moving to the board.
#
# THE LAW: an edit to src/**.mn or lib/**.mn is refused until a medium verb
# has named that path this session. Any verb satisfies it — check, audit,
# query, tighten, a cursor address — and one that answers WITH ERRORS still
# counts, because the requirement is that the question was PUT. Demanding a
# clean answer would deadlock a mid-refactor file that does not yet compile.
#
# WHY IT EXISTS: the pre-edit hook used to print the eight interrogations and
# its own header read "never blocks — audit is POST-edit". Ten iterations
# edited wheel files without once asking `mentl audit` what it already knew;
# the first run answered in one command what hand-reading had not, and the
# first `mentl tighten` exposed a verb that wrote an unresolved handle into
# source. PLAN §0's argument — discipline in prose cannot enforce itself —
# applied to the scaffold that was supposed to enforce it.
#
# PRICED BEFORE IMPOSED (2026-08-18): `mentl check` costs 0.65s/208MB on
# types.mn, 0.73s/227MB on lexer.mn, 2.53s/725MB on infer.mn — once per file
# per session, not per edit. Running the audit ITSELF at the edit is a
# different question, priced at 4.91s/777MB and gated on the module image
# (`Hβ.audit.at-the-edit-is-image-gated`).
#
# ITS OWN DESTINY IS DELETION, like every scaffold here: when the graph
# persists across runs, the medium audits its own construction at the moment
# of construction and a ledger of "was it asked" has nothing left to track.
set -uo pipefail

ledger="${CLAUDE_PROJECT_DIR:-.}/.build/consult"

case "${1:-}" in
  record)
    mkdir -p "$ledger" 2>/dev/null || true
    for p in $(printf '%s' "${2:-}" | grep -oE '(src|lib)/[A-Za-z0-9_/.-]+\.mn' | sort -u || true); do
      touch "$ledger/$(printf '%s' "$p" | tr '/' '%')" 2>/dev/null || true
    done
    exit 0 ;;

  require)
    rel="${2:-}"
    rel="${rel#"${CLAUDE_PROJECT_DIR:-}/"}"
    case "$rel" in
      src/*.mn|lib/*.mn) ;;
      # tests, docs and the seed keep the reminder alone — the law is about
      # editing the medium without asking it.
      *) exit 0 ;;
    esac
    [ -e "$ledger/$(printf '%s' "$rel" | tr '/' '%')" ] && exit 0
    cat >&2 <<REFUSE
mentl-first: edit to $rel refused — the medium has not been asked about this
file in this session. Ask it first, then edit:

  mentl check $rel      diagnostics, the cheapest consult
  mentl audit $rel      rows, severances, iteration shapes, drift shapes
  mentl query $rel "type NAME"
  mentl $rel:<line>     the node at a position

A verb that answers WITH ERRORS still satisfies this — the requirement is
that the question was put, not that the answer was clean.
REFUSE
    exit 2 ;;

  reset)
    rm -rf "$ledger" 2>/dev/null || true
    exit 0 ;;

  *)
    echo "usage: consult-gate.sh record <command> | require <path> | reset" >&2
    exit 64 ;;
esac
