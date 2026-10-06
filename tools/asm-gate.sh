#!/usr/bin/env bash
# tools/asm-gate.sh — the medium assembles its own output (L-F, 2026-10-06).
#
# `mentl asm` (src/asm.mn) projects the emitter's WAT to the module's bytes.
# This gate holds the projection to four things, each a leg that can fail:
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
#      gates assembled m2.wasm to; with WABT present, to wat2wasm's bytes too.
#   4. fixpoint — that projected module instantiates and compiles the wheel
#      to exactly the text m2.wasm compiles it to (the march's m3).
#
# Usage: bash tools/asm-gate.sh [m2|boot|<compiler.wasm>]   (default m2: the
# candidate's own assembler — the wheel this checkout compiles to). The
# pinned boot serves no `asm` verb until the boot carrying this landing is
# pinned, which is the leg's RED: `bash tools/asm-gate.sh boot` refuses at
# the verb.
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
if [ "$WT_ASM_SEAM" = 1 ]; then
  echo "· the pinned boot predates \`mentl asm\`: the gates assemble through WABT for this generation (Hβ.asm.bootstrap-seam)"
else
  echo "· the gates assemble through the pinned boot's \`mentl asm\`"
fi

# asm_with <assembler.wasm> <in.wat> <out.wasm> <err> — one projection, timed.
asm_with() {
  /usr/bin/time -f '%e %M' -o "$3.time" "$WT" run "${WT_RUN_FLAGS[@]}" "$1" asm < "$2" > "$3" 2> "$4"
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
    echo "✓ self: identical to the m2.wasm the gates run"
  else
    echo "✗ self: differs from the m2.wasm the gates run ($(cmp "$D/m2.asm.wasm" "$M2/m2.wasm" 2>&1 | head -1))"; fail=1
  fi
  if command -v wat2wasm >/dev/null 2>&1; then
    if "${W2W[@]}" "$M2/m2.wat" -o "$D/m2.wabt.wasm" 2>/dev/null && cmp -s "$D/m2.asm.wasm" "$D/m2.wabt.wasm"; then
      echo "✓ self: identical to wat2wasm's (the cross-check WABT is optional for)"
    else
      echo "✗ self: differs from wat2wasm's"; fail=1
    fi
  fi
else
  echo "✗ self: the assembler refused or trapped on m2.wat: $(grep -v '^ ' "$D/m2.asm.err" | head -2)"; fail=1
fi

# ── 4 · fixpoint: the projected module compiles the wheel ─────────────────
if [ -s "$D/m2.asm.wasm" ] && [ "$fail" = 0 ]; then
  ref="$D/m3.ref.wat"
  timeout 9000 "$WT" run "${WT_RUN_FLAGS[@]}" "$M2/m2.wasm" < "$M2/wheel.mn" > "$ref" 2> "$D/m3.ref.err"
  /usr/bin/time -f '%e %M' -o "$D/m3.asm.time" timeout 9000 "$WT" run "${WT_RUN_FLAGS[@]}" "$D/m2.asm.wasm" < "$M2/wheel.mn" > "$D/m3.asm.wat" 2> "$D/m3.asm.err"
  rc=$?
  read -r secs kb < "$D/m3.asm.time"
  if [ "$rc" = 0 ] && [ -s "$D/m3.asm.wat" ] && cmp -s "$D/m3.asm.wat" "$ref"; then
    echo "✓ fixpoint: the projected m2 compiles the wheel to the same $(wc -l < "$ref") lines (${secs}s, peak ${kb} KB)"
  else
    echo "✗ fixpoint: the projected m2 (exit $rc) compiled the wheel to different text than m2.wasm does"; fail=1
  fi
fi

if [ "$fail" = 0 ]; then
  echo "asm-gate: GREEN — the medium assembles its own output ($(basename "$A"))"
else
  echo "asm-gate: RED"
fi
exit "$fail"
