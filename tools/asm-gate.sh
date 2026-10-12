#!/usr/bin/env bash
# tools/asm-gate.sh — the medium assembles its own output (L-F, 2026-10-06).
#
# `mentl asm` (src/asm.mn) projects the emitter's WAT to the module's bytes.
# This gate holds the projection to three things, each a leg that can fail:
#
#   1. coverage — tests/asm/coverage.wat (every form the assembler's table
#      knows, folded and flat, and the literal edges of every number type)
#      assembles to tests/asm/coverage.wasm byte for byte: the module WABT
#      1.0.39 wrote from the same text, recorded once, so this leg needs no
#      WABT to run.
#   2. refusals — every tests/asm/refuse-*.wat refuses, and the refusal says
#      what its first line (`;; refuse: <text>`) names.
#   3. self — the assembler under test projects the boot's own m2.wat (the
#      wheel compiled by the pinned boot, .build/m2cache) to the bytes the
#      boot's assembler wrote m2.wasm as: a candidate assembles the wheel as
#      the generation before it did.
#
# A projected module byte-identical to m2.wasm compiles what m2.wasm compiles,
# so whether the assembled wheel reproduces itself is the march's question
# (m3 == m4), and the march assembles every generation through `mentl asm`.
#
# Usage: bash tools/asm-gate.sh [m2|boot|<compiler.wasm>]   (default m2: the
# candidate's own assembler — the wheel this checkout compiles to).
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
source "$ROOT/tools/wt-env.sh"

sel="${1:-m2}"
case "$sel" in
  m2)
    C=$(wt_m2_ensure) || { echo "✗ asm-gate: the m2 generation trapped"; exit 2; }
    A="$ROOT/$C/m2.wasm"
    ;;
  boot) A="$ROOT/boot/mentl.wasm" ;;
  /*) A="$sel" ;;
  *) A="$ROOT/$sel" ;;
esac
[ -f "$A" ] || { echo "✗ asm-gate: no assembler at $A"; exit 2; }

D="$ROOT/.build/asm-gate"
mkdir -p "$D"
fail=0

# asm_with <assembler.wasm> <in.wat> <out.wasm> <err> — one projection, timed.
asm_with() {
  /usr/bin/time -f '%e %M' -o "$3.time" "$WT" run "${WT_RUN_FLAGS[@]}" --dir . --dir /tmp --dir "$ROOT::/mentl-home" "$1" asm < "$2" > "$3" 2> "$4"
}

# ── 1 · coverage ───────────────────────────────────────────────────────────
if asm_with "$A" tests/asm/coverage.wat "$D/coverage.wasm" "$D/coverage.err" \
   && cmp -s "$D/coverage.wasm" tests/asm/coverage.wasm; then
  echo "✓ coverage: $(wc -c < tests/asm/coverage.wasm) bytes, identical to the recorded module"
else
  echo "✗ coverage: the projection of tests/asm/coverage.wat differs from tests/asm/coverage.wasm"
  head -3 "$D/coverage.err"
  cmp "$D/coverage.wasm" tests/asm/coverage.wasm 2>&1 | head -1
  fail=1
fi

# ── 2 · refusals ───────────────────────────────────────────────────────────
nref=0; bad=0
for f in tests/asm/refuse-*.wat; do
  nref=$((nref + 1))
  want=$(head -1 "$f" | sed 's/^;; refuse: //')
  if asm_with "$A" "$f" "$D/refuse.wasm" "$D/refuse.err"; then
    echo "  ✗ $(basename "$f"): assembled — it should refuse ($want)"; bad=$((bad + 1))
  elif ! grep -qF -- "$want" "$D/refuse.err"; then
    echo "  ✗ $(basename "$f"): refused without saying \"$want\": $(head -1 "$D/refuse.err")"; bad=$((bad + 1))
  fi
done
if [ "$bad" = 0 ] && [ "$nref" -gt 0 ]; then
  echo "✓ refusals: $nref/$nref refuse and name what they refuse"
else
  echo "✗ refusals: $bad of $nref broke their contract"; fail=1
fi

# ── 3 · self: the boot's own m2, projected ─────────────────────────────────
M2=$(wt_m2_ensure) || { echo "✗ self: the m2 generation trapped"; exit 1; }
if asm_with "$A" "$M2/m2.wat" "$D/m2.asm.wasm" "$D/m2.asm.err"; then
  read -r secs kb < "$D/m2.asm.wasm.time"
  echo "· self: $(wc -c < "$M2/m2.wat") bytes of WAT → $(wc -c < "$D/m2.asm.wasm") bytes in ${secs}s, peak ${kb} KB"
  if cmp -s "$D/m2.asm.wasm" "$M2/m2.wasm"; then
    echo "✓ self: identical to the m2.wasm the boot assembled"
  else
    echo "✗ self: differs from the m2.wasm the boot assembled ($(cmp "$D/m2.asm.wasm" "$M2/m2.wasm" 2>&1 | head -1))"; fail=1
  fi
else
  echo "✗ self: the assembler refused or trapped on m2.wat: $(grep -v '^ ' "$D/m2.asm.err" | head -2)"; fail=1
fi

if [ "$fail" = 0 ]; then
  echo "asm-gate: GREEN — the medium assembles its own output ($(basename "$A"))"
else
  echo "asm-gate: RED"
fi
exit "$fail"
