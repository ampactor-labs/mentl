#!/usr/bin/env bash
# tools/clean.sh — the .build retention rules, executable.
#
# Build artifacts never accumulate past their use (Morgan, 2026-07-22). Every
# .build subdir is one of three kinds, and this script IS the rule set — run
# it anytime; nothing here is load-bearing state:
#
#   keyed cache           m2cache/ — a SINGLE slot keyed by
#                         sha256(wheel+boot+flags), overwritten in place by
#                         wt_m2_ensure, so it cannot accumulate. KEPT: it is
#                         the ~13-minute boot-compile every gate reads.
#   regenerated-per-run   gate/ march/ frontier-gate/ proof-exactness-gate/
#                         oracle-selftest/ solo/ — deleted whole; the next
#                         gate run rewrites what it needs. (`mentl test`
#                         writes nothing here: every fixture streams to the
#                         runner and runs in-process.)
#   session scratch       everything else under .build (a dig's named
#                         scratch, e.g. triple/) — deleted whole; a live dig
#                         re-derives its scratch from source in one ladder.
#
# CLEAN_KEEP_CACHE=0 drops m2cache too (full scorch; next gate pays the
# rebuild).
set -euo pipefail
cd "$(dirname "$0")/.."

for d in .build/*/; do
  base="$(basename "$d")"
  case "$base" in
    m2cache) [ "${CLEAN_KEEP_CACHE:-1}" = 0 ] && rm -rf "$d" ;;
    *) rm -rf "$d" ;;
  esac
done
rm -f .build/wheel-blob.mn

echo "clean: $(du -sh .build 2>/dev/null | cut -f1) retained in .build"
