#!/usr/bin/env bash
# ═══ Mentl first-light march — the binary-arbiter gate in ONE command ════════
# boot → m2 → m3 (→ m4), with structured trap / probe reporting, so a
# diagnostic cycle is a single invocation instead of a hand-typed pipeline.
# Pairs with tools/verify.sh (micros + census, stamped green).
#
#   bash tools/march.sh             # boot → m2 → m3, ASSERT the fixpoint ratchet
#   bash tools/march.sh --fixpoint  # force the m4 leg even on a clean m2 == m3
#
# The ratchet arbitrates ITSELF: m2 == m3 is the fixpoint; on m2 ≠ m3 the march
# runs the m4 leg automatically and rules TRANSITION (m3 == m4 — an emit/import
# change crossed one generation; re-pin boot from m3) vs BROKEN (m3 ≠ m4). The
# m2 leg reads the ONE keyed boot(wheel) artifact (wt_m2_ensure, .build/m2cache
# — shared with verify's census and march-gate), so gates never re-derive the
# same ~13-minute compile.
#
# Artifacts land in .build/march (luks-backed, per PLAN §8), NEVER /tmp — /tmp is
# RAM-backed tmpfs here, and a 50MB objdump + 12MB m2.wat × repeated runs OOMs the
# box (it did, 2026-06-30). .build is on disk; override with MARCH_OUT=<dir>.
set -u
cd "$(dirname "$0")/.." || exit 2
source "$(dirname "$0")/wt-env.sh"   # WT, WT_RUN_FLAGS, W2W — the one home
OUT="${MARCH_OUT:-$(pwd)/.build/march}"; mkdir -p "$OUT"
WHEEL="$OUT/wheel.mn"
# Boot from the PINNED FIXPOINT WHEEL (boot/mentl.wasm — boot/PROVENANCE.md).
# m2 := boot(wheel) is wheel-emitted, so m2 == m3 IS the fixed point. The
# hand-WAT seed is DELETED (7401c4b); the cold-ladder recipe lives at tag
# first-light (band J archaeology).
FIXPOINT=0
for a in "$@"; do case "$a" in
  --fixpoint)  FIXPOINT=1 ;;
  *) echo "march: unknown arg '$a'" >&2; exit 2 ;;
esac; done

# trap signatures: a wasmtime runtime trap OR a name-section frame of the known
# trap site. Empty match = the gate is GREEN.
trap_lines() { grep -nE 'out of bounds|wasm trap|undefined element|unreachable|op_each_handler_yield' "$1" 2>/dev/null; }
# timeout execs a real binary (not the wt_run function), so it uses the same
# constants wt_run projects from — WT + WT_RUN_FLAGS, the one home (wt-env.sh).
# 9000s: pass-2 measured ~2h-class on the seed-idiom m2 (2026-07-05 —
# ~300 wheel-lines/min, ~19MB/min; the profile is Hβ.m2.compile-alloc-profile,
# instantiate tree-clones the prime suspect). The old 480s cap predates the
# union_row-divergence fix, when every long run meant the infinite loop.
# Every leg runs MEASURED (§5.O cost-on-the-board; the arena's build step 0):
# GNU time writes `<wall-s> <peak-rss-KB>` beside the wat, the march prints
# it, the pin's mechanical block carries it, and selfcompile_peak_kb_max in
# tools/verify-baseline.txt ratchets the peak — raising the ceiling is an
# explicit in-commit act with a fixed-input justification.
gen() { /usr/bin/time -f '%e %M' -o "${2%.wat}.time" timeout 9000 "$WT" run -D coredump="$OUT/$(basename "$2" .wat).coredump" "${WT_RUN_FLAGS[@]}" "$1" < "$WHEEL" > "$2" 2> "$3"; }  # coredump: one trap buys the whole heap autopsy (face 7 lesson)  # gen <wasm> <out.wat> <out.err>

# WABT disassembly, cached on the wasm's mtime (objdump on 1.7MB is slow; the
# 500k-line dump is reused across runs until m2.wasm is rebuilt). PLAN §8: pin the
# trap with the binary toolkit, NEVER grep the minified emit.
disasm() {  # disasm <in.wasm> → echoes the cached .dis path
  local w="$1" d="${1%.wasm}.dis"
  [ -f "$d" ] && [ "$d" -nt "$w" ] || wasm-objdump -d "$w" > "$d" 2>/dev/null
  echo "$d"
}
# ── emit_provenance — the pin's MECHANICAL facts, machine-written ────
# The march HOLDS the sha, the verdict, the generation, the line count
# and the census at the moment it repins; a human retyping any of them
# later is the fabrication class (caught live twice — a sha tail
# completed from memory, CLAUDE.md ⊕). So the march writes them, read
# from the artifact it just copied, and the AUTHOR writes only the
# narrative. The unwritten narrative is a literal placeholder, so an
# unblessed pin is MECHANICALLY visible (doc-truth refuses while it
# stands) instead of resting on the discipline of remembering.
# The first executed rung of ledger-as-projection (PLAN §7's own
# destiny: state as a projection, never a hand-kept prose ledger).
# The board is captured, never remembered. A pin records EVERY gate it
# owns — and a gate this march did not run is written `NOT RUN`, because
# an omission is invisible while a blank is not. Paid for 2026-08-05: the
# crown (`!E` soundness) went unreported for ELEVEN consecutive ledger
# entries and a higher-order leak rode the whole arc; the block had
# recorded census and lines, so nothing on the page was false — the gate
# had simply stopped being mentioned. emit_provenance runs the three fast
# soundness gates against the boot it just wrote (crown, proof-exactness,
# effect-identity); the slow ones report what the caller measured or say
# NOT RUN. Any red leaves a ‹BOARD RED› marker, which doc-truth refuses
# exactly as it refuses an unwritten narrative.
# The gates THIS march ran itself, and the only lines whose verdict may
# refuse a pin. Kept separate from the caller-reported lines below because a
# substring test cannot tell a VERDICT from a DESCRIPTION: the ‹BOARD RED›
# marker used to scan the whole block, so a frontier line that says
# "born RED, banked as <peer>" — the discipline's own way of recording a
# measured silent-wrong — blocked its own pin, while "1 red" in lower case
# sailed through every pin before it. Whether a red frontier LEG blesses a
# pin is settled by precedent and not by spelling: the standing
# why-coordinates red has ridden many pins.
board_self_run() {
  local out="" name script rc
  for name in crown proof-exactness effect-identity; do
    script="tools/${name}-gate.sh"
    [ -x "$script" ] || script="tools/${name}.sh"
    if [ -x "$script" ]; then
      if bash "$script" >/dev/null 2>&1; then rc="green"; else rc="RED"; fi
    else
      rc="NOT RUN (no $script)"
    fi
    out="${out}  - ${name}: ${rc}"$'\n'
  done
  printf '%s' "$out"
}

board_reported() {  # what the caller measured — recorded verbatim, never parsed
  printf '%s\n%s' \
    "  - frontier: ${MARCH_FRONTIER:-NOT RUN (run tools/frontier-gate.sh)}" \
    "  - micros+census: ${MARCH_VERIFY:-NOT RUN (run tools/verify.sh)}"
}

emit_provenance() {  # emit_provenance <gen> <verdict> <lines> <census>
  local gen="$1" verdict="$2" lines="$3" census="$4" sha block tmp board redmark
  sha=$(sha256sum boot/mentl.wasm | awk '{print $1}')
  local selfrun
  selfrun=$(board_self_run)
  # $( ) strips the trailing newline board_self_run ends with, so the join
  # supplies it — without this the last self-run gate and the frontier line
  # share a line.
  board="${selfrun}"$'\n'"$(board_reported)"
  redmark=""
  case "$selfrun" in *RED*) redmark=$'\n- ‹BOARD RED — a gate above refuses this pin; fix it or restore the prior boot›';; esac
  block=$(cat <<EOF
- source: ‹NARRATIVE UNWRITTEN — replace this line: what landed and why,
  the §7 ledger entry of the same name carrying the arc›
- boot/mentl.wasm  sha256 $sha
  ($verdict; re-pinned from $gen per march.sh — $lines lines, census $census)
- cost: ${MARCH_COST:-NOT MEASURED (no .time beside the leg)}
- the board at this pin:
$board$redmark
- generated by: ${verdict%% *} (prior pin follows)

---
EOF
)
  tmp=$(mktemp)
  # An UNNARRATED head is a working step, not history: one landing may
  # march several times before it is right, so a repin SUPERSEDES a head
  # block whose narrative is still the placeholder instead of stacking a
  # second one (the machinery's own first lesson, 2026-07-30 — the chain
  # records blessed pins, and blessing is exactly what the narrative is).
  awk -v blk="$block" '
    /^- source: ‹NARRATIVE UNWRITTEN/ { drop=1 }
    drop && /^---$/ { drop=0; next }
    drop { next }
    { print }
    !done && /^Provenance, self-confirmed at pin time:$/ { print ""; print blk; done=1 }
  ' boot/PROVENANCE.md > "$tmp" && mv "$tmp" boot/PROVENANCE.md
  echo "· PROVENANCE: mechanical block written (sha, verdict, lines, census — read from the artifact)"
  echo "  the narrative line is a placeholder; doc-truth refuses the pin until it is written"
}

pin_trap() {  # pin_trap <wasm> <err> — auto-disassemble the trap site from the backtrace
  local w="$1" e="$2" fn dis
  fn=$(grep -oE '<unknown>!\S+' "$e" 2>/dev/null | head -1 | sed 's/.*!//')
  [ -z "$fn" ] && fn=$(grep -oE 'op_[a-z_]+' "$e" 2>/dev/null | head -1)
  [ -z "$fn" ] && { echo "  (no named trap frame to pin)"; return; }
  dis=$(disasm "$w")
  echo "  ── WABT trap pin: <$fn> around its call_indirect ──"
  awk -v fn="<$fn>:" '
    index($0,fn){p=1}
    p{n++; print "    " $0}
    p && /call_indirect/{c++}
    p && c>=1 && n>4{exit}
    p && n>34{exit}' "$dis" | grep -E 'load|store|local|global|call|func\[' | head -18
}

# ── wheel input: `find`, NOT `cat src/*.mn` (PLAN §6 — cat omits backends/) ──
{ find lib -name '*.mn' -not -path '*/tutorial/*' | sort | xargs cat
  find src -name '*.mn' | sort | xargs cat; } > "$WHEEL"
echo "wheel: $(wc -l < "$WHEEL") lines"

BOOT=boot/mentl.wasm
[ -f "$BOOT" ] || { echo "✗ no $BOOT (boot/PROVENANCE.md)"; exit 1; }
echo "✓ boot: $BOOT (the pinned fixpoint wheel)"

# ── m2: the boot compiler compiles the wheel ──
# Reads the ONE keyed boot(wheel) artifact (wt_m2_ensure — shared with
# verify's census and march-gate; .build/m2cache): instant when another
# gate already compiled this exact state.
if C=$(wt_m2_ensure); then
  wt_m2_place "$C" "$OUT"; m2rc=0
  echo "m2: boot(wheel) via $C — $(wc -l < "$OUT/m2.wat") lines (key $(cut -c1-12 "$C/key"))"
else
  echo "✗ m2 generation TRAPPED (see $WT_M2CACHE/m2.err):"; trap_lines "$WT_M2CACHE/m2.err" | head -6; exit 1
fi
echo "✓ m2 assembles ($(stat -c%s "$OUT/m2.wasm") bytes)"
m2lines=$(wc -l < "$OUT/m2.wat" 2>/dev/null | tr -d ' ')

# VERB PARITY — this script's own successor has to be able to run.
#
# `mentl march` is what this file absorbs into (PLAN §11 10.3), and it was
# DEAD: its hand-copied handler chain had lost lower_handler_stack_ctx, so the
# frame fence's perform hit the unhandled floor on every march the verb ran.
# Nothing caught it for as long as it was broken, because the board calls this
# script and never the verb — a gate that stops being reported stops being run
# (§11 tripwire 4), one layer up, where the scaffold's own existence was the
# cover. The wheel is judged by its ability to judge itself.
#
# It runs HERE, right after the m2 leg and before any repin, because the verb
# runs BOOT: what it reproduces is boot's own output, which is the m2 leg. Two
# earlier placements were wrong and the leg said so both times — against m3 it
# called an honest TRANSITION a verb failure, and after the repin it ran a
# different binary than the one that wrote m2.wat. The line count is captured
# above rather than re-read, because the verb WRITES $OUT/m2.wat itself.
if [ "$m2rc" = 0 ]; then
  vm=$(timeout 9000 "$WT" run "${WT_RUN_FLAGS[@]}" --dir . boot/mentl.wasm march 2> "$OUT/verb.err")
  vrc=$?
  vlines=$(printf '%s\n' "$vm" | sed -n 's/^march: .* · \([0-9]*\) wat lines · census.*/\1/p')
  if [ "$vrc" != 0 ]; then
    echo "✗ VERB PARITY: \`mentl march\` exits $vrc — the medium cannot judge its own generation:"
    printf '%s\n' "$vm" | tail -3
    trap_lines "$OUT/verb.err" | head -6
    fixok=0
  elif [ "$vlines" != "$m2lines" ]; then
    echo "✗ VERB PARITY: \`mentl march\` emits ${vlines:-no} wat lines, the m2 leg $m2lines — the verb and the scaffold judge the same wheel differently"
    fixok=0
  else
    echo "✓ verb parity: \`mentl march\` reproduces the m2 leg ($m2lines wat lines)"
  fi
fi

if [ -n "${PROBE:-}" ]; then
  # closure record = [fn_ptr@0][nc@4][caps..][evs..], alloc = 8 + 4*(nc+ne).
  SZ=$(grep -oE "\(i32.const ([0-9]+)\)\(i32.add\)\(global.set \\\$heap_ptr\)\(local.get \\\$state_tmp\)\(global.get \\\$${PROBE}_idx\)" "$OUT/m2.wat" | grep -oE 'const [0-9]+' | grep -oE '[0-9]+' | head -1)
  NC=$(grep -oE "${PROBE}_idx\)\(i32.store offset=0\)\(local.get \\\$state_tmp\)\(i32.const [0-9]+\)" "$OUT/m2.wat" | grep -oE 'const [0-9]+' | grep -oE '[0-9]+' | head -1)
  if [ -n "$SZ" ]; then echo "  ${PROBE} closure: ${SZ}B frame, nc=${NC} caps, ne=$(( (SZ-8)/4 - ${NC:-0} )) evs"
  else echo "  ${PROBE} closure: <not found in m2.wat>"; fi
fi

# ── m3: m2 compiles the wheel — THE GATE (the trapping lambda executes here) ──
gen "$OUT/m2.wasm" "$OUT/m3.wat" "$OUT/m3.err"; m3rc=$?
echo "m3: exit=$m3rc, $(wc -l < "$OUT/m3.wat" 2>/dev/null) lines, census=$(grep -cE 'E_[A-Za-z]+ error' "$OUT/m3.err" 2>/dev/null)"
# ── the COST read + the peak ratchet (the self-compile's own footprint) ──
# The m3 leg IS the self-compile (the wheel compiling the wheel); its
# measured wall + peak RSS is the pin's cost line, and the peak checks
# against selfcompile_peak_kb_max (missing key = not yet enforced, the
# other ratchets' own -n guard). A breach refuses the REPIN, exactly as
# the battery does — the verdict stays a correctness fact.
costok=1
BASELINE=tools/verify-baseline.txt
read_cost() {  # read_cost <leg> — sets MARCH_COST from $OUT/<leg>.time, ratchets the peak
  local leg="$1" wall rss_kb peak_max
  [ -s "$OUT/$leg.time" ] || return 0
  read -r wall rss_kb < <(tail -1 "$OUT/$leg.time")
  MARCH_COST="$leg leg ${wall}s wall · $(( ${rss_kb:-0} / 1024 ))MB peak RSS (${rss_kb:-0} KB)"
  echo "· cost: $MARCH_COST"
  peak_max=$(grep -E '^selfcompile_peak_kb_max:' "$BASELINE" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
  [ -n "${peak_max:-}" ] || return 0
  [ "${rss_kb:-0}" -gt "$peak_max" ] || return 0
  # ── RE-MEASURE BEFORE CONVICTING (the march's own arbitration shape: the
  # fixpoint leg re-runs m4 ITSELF rather than ruling on one reading). Peak
  # RSS is not a symmetric measurement — allocator and OS jitter can only
  # push an OBSERVED peak ABOVE the true requirement, never below it — so a
  # single sample is biased HIGH and the MINIMUM is the honest estimator. A
  # genuine regression survives the min undiminished; only the jitter dies.
  # The extra legs are paid ONLY on a breach, so the green path is unchanged.
  # (Refused a repin at 2326460 vs a 2326000 ceiling — 0.02%, inside the
  # measured run-variance — which is the reading that named the defect. The
  # answer to a noisy gate is a better estimator, never a raised ceiling:
  # bumping it launders jitter as headroom and the ratchet stops meaning
  # anything. Hβ.tools.cost-ratchet-reads-one-sample.)
  local best="$rss_kb" i r_wall r_rss
  echo "· peak ${rss_kb}KB over the ${peak_max}KB ceiling — re-measuring before convicting"
  for i in 1 2; do
    gen "$OUT/m2.wasm" "$OUT/$leg-recheck.wat" "$OUT/$leg-recheck.err"
    if [ -s "$OUT/$leg-recheck.time" ]; then
      read -r r_wall r_rss < <(tail -1 "$OUT/$leg-recheck.time")
      echo "·   re-read $i: ${r_rss}KB"
      if [ "${r_rss:-0}" -lt "$best" ]; then best="$r_rss"; fi
    fi
  done
  if [ "$best" -gt "$peak_max" ]; then
    echo "✗ PEAK RATCHET: self-compile RSS ${best}KB (min of 3) > ${peak_max}KB ceiling — raising it is an"
    echo "  explicit in-commit act (fixed-input justification in $BASELINE); repin refused."
    costok=0
  else
    echo "✓ peak ratchet: ${best}KB (min of 3) inside the ${peak_max}KB ceiling — the lone sample was jitter"
    MARCH_COST="$leg leg ${wall}s wall · $(( best / 1024 ))MB peak RSS (${best} KB, min of 3)"
  fi
}
read_cost m3
# ── the CENSUS gate (the 25-divergence lesson, 2026-08-08): a repin with a
# rising census rode the TRANSITION path — verify's ratchet caught it only
# post-pin, after the boot was already blessed. The march reads the same
# count verify ratchets (the m3 leg IS the self-compile) and refuses the
# blessing on a rise; the reproduction verdict (CLEAN/TRANSITION) stays a
# separate fact. Missing baseline key = not yet enforced (the -n guard).
censusok=1
m3census=$(grep -cE 'E_[A-Za-z]+ error' "$OUT/m3.err" 2>/dev/null)
census_max=$(grep -E '^census_errors_max:' "$BASELINE" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')
if [ -n "${census_max:-}" ] && [ "${m3census:-0}" -gt "$census_max" ]; then
  echo "✗ CENSUS GATE: m3-leg census ${m3census} > ${census_max} baseline — the wheel makes"
  echo "  claims about its own source it does not believe; the repin is refused."
  censusok=0
fi
TRAP=$(trap_lines "$OUT/m3.err")
if [ -n "$TRAP" ]; then
  echo "✗ GATE: m3 TRAPPED —"; echo "$TRAP" | head -4
  pin_trap "$OUT/m2.wasm" "$OUT/m3.err"
else
  echo "✓ GATE: m3 clean (no trap)"
fi

# ── the FIXPOINT RATCHET ──
# m2 and m3 are BOTH wheel-emitted, so m2 == m3 is the fixed point —
# asserted on every run (the ratchet law: every wheel change holds
# m_n == m_{n+1}). --fixpoint extends the chain one more generation (m4)
# for the paranoid triple.
fixok=1; m4done=0
# SIZE-GUARD the compare (the empty-wat trap: two empty legs diff equal and a
# gate that cannot fail reads as a fixpoint — 2026-07-22's own lesson).
if [ ! -s "$OUT/m2.wat" ] || [ ! -s "$OUT/m3.wat" ]; then
  echo "✗ SIZE-GUARD: an empty wat leg (m2=$(wc -c < "$OUT/m2.wat" 2>/dev/null)B m3=$(wc -c < "$OUT/m3.wat" 2>/dev/null)B) — no verdict from empties"
  fixok=0
elif [ "$m3rc" = 0 ]; then
  if diff -q "$OUT/m2.wat" "$OUT/m3.wat" >/dev/null 2>&1; then
    echo "✓✓ FIXED POINT holds: m2 == m3"
    if [ "${MARCH_REPIN:-0}" = 1 ]; then
      # THE BATTERY GATES THE BLESSING (2026-07-31): a pin the micros have
      # not judged is not blessable — the OOM'd session repinned mid-gate
      # and three red micros (findtag/mapelem/mapfield) rode hidden into
      # the tree. The gate runs THROUGH the candidate (the repin changes
      # the m2cache key, so the battery re-derives against the new boot);
      # red restores the prior boot and refuses.
      cp boot/mentl.wasm "$OUT/boot.prev.wasm"
      cp "$OUT/m2.wasm" boot/mentl.wasm
      if [ "$costok" = 1 ] && [ "$censusok" = 1 ] && bash tools/march-gate.sh --micros > "$OUT/repin-battery.log" 2>&1; then
        # A repin is a new build: the warm-compile images were written by
        # the old one, and their $build_key (table+strings+globals) does
        # NOT move on a body-only change — a key-matching stale image
        # trapped the board twice (2026-08-07/08). Clearing at the bless
        # is the scaffold-tier fix; the key gaining the build identity is
        # the peer (Hβ.persist.image-key-compiler-build).
        rm -f .build/warm-compile-*.img
        echo "· REPIN (clean): boot ← m2  sha256 $(sha256sum boot/mentl.wasm | cut -c1-16)…  (battery green)"
        emit_provenance m2 "CLEAN m2 == m3" \
          "$(wc -l < "$OUT/m2.wat" 2>/dev/null)" \
          "$(grep -cE 'E_[A-Za-z]+ error' "$OUT/m3.err" 2>/dev/null)"
      else
        cp "$OUT/boot.prev.wasm" boot/mentl.wasm
        echo "✗ REPIN REFUSED: the cost ratchet or the micro battery refused the candidate (the ✗ above names which) — boot restored."
        tail -8 "$OUT/repin-battery.log"
        fixok=0
      fi
    fi
  else
    # THE TRANSITION FORM — native, never hand-driven. A change to the wheel's
    # own EMIT or import surface crosses one generation: m2 is the OLD emit
    # rendering the new source, m3 the NEW emit — different bytes by design
    # (PLAN §6's original rule, resurfacing whenever the emit itself moves).
    # The fixpoint then lands at m3 == m4, and blessing the wrong generation
    # (m2) is the classic trusting-trust mistake — so the march arbitrates
    # itself instead of leaving the m4 leg to a human.
    echo "· RATCHET: m2 ≠ m3 ($(diff "$OUT/m2.wat" "$OUT/m3.wat" 2>/dev/null | grep -c '^[<>]') diff lines) — testing the TRANSITION form (m3 == m4)"
    if "${W2W[@]}" "$OUT/m3.wat" -o "$OUT/m3.wasm" 2> "$OUT/m3w.err"; then
      gen "$OUT/m3.wasm" "$OUT/m4.wat" "$OUT/m4.err"; m4rc=$?; m4done=1
      echo "m4: exit=$m4rc, $(wc -l < "$OUT/m4.wat" 2>/dev/null) lines"
      read_cost m4
      if [ "$m4rc" = 0 ] && diff -q "$OUT/m3.wat" "$OUT/m4.wat" >/dev/null 2>&1; then
        echo "✓✓ TRANSITION: m3 == m4 — the NEW wheel reproduces itself; the m2/m3 diff was the emit change crossing one generation."
        if [ "${MARCH_REPIN:-0}" = 1 ]; then
          # The battery gates this blessing too (2026-07-31; see the clean
          # arm's comment) — through the candidate, restore-and-refuse on red.
          cp boot/mentl.wasm "$OUT/boot.prev.wasm"
          cp "$OUT/m3.wasm" boot/mentl.wasm
          if [ "$costok" = 1 ] && [ "$censusok" = 1 ] && bash tools/march-gate.sh --micros > "$OUT/repin-battery.log" 2>&1; then
            rm -f .build/warm-compile-*.img
            echo "· REPIN (transition): boot ← m3  sha256 $(sha256sum boot/mentl.wasm | cut -c1-16)…  (battery green; blessing m2 here is the trusting-trust mistake this arbitration exists to prevent)"
            emit_provenance m3 "TRANSITION m3 == m4" \
              "$(wc -l < "$OUT/m3.wat" 2>/dev/null)" \
              "$(grep -cE 'E_[A-Za-z]+ error' "$OUT/m3.err" 2>/dev/null)"
          else
            cp "$OUT/boot.prev.wasm" boot/mentl.wasm
            echo "✗ REPIN REFUSED: the cost ratchet or the micro battery refused the candidate (the ✗ above names which) — boot restored."
            tail -8 "$OUT/repin-battery.log"
            fixok=0
          fi
        else
          echo "   Re-pin to bless: cp $OUT/m3.wasm boot/mentl.wasm  (or rerun with MARCH_REPIN=1; then update boot/PROVENANCE.md — the recipe is in that file)"
        fi
      else
        echo "✗✗ BROKEN: m3 ≠ m4 ($(diff "$OUT/m3.wat" "$OUT/m4.wat" 2>/dev/null | grep -c '^[<>]') diff lines; m4 exit=$m4rc) — genuine non-reproduction, not a transition"
        fixok=0
      fi
    else
      echo "✗ m3 wat2wasm FAILED (transition leg cannot run):"; head -5 "$OUT/m3w.err"; fixok=0
    fi
  fi
fi
if [ "$FIXPOINT" = 1 ] && [ "$m3rc" = 0 ] && [ "$m4done" = 0 ]; then
  if "${W2W[@]}" "$OUT/m3.wat" -o "$OUT/m3.wasm" 2>/dev/null; then
    gen "$OUT/m3.wasm" "$OUT/m4.wat" "$OUT/m4.err"; m4rc=$?
    if [ "$m4rc" = 0 ] && diff -q "$OUT/m3.wat" "$OUT/m4.wat" >/dev/null 2>&1; then
      echo "✓✓ FIRST LIGHT: m3 == m4 (fixed point)"
    else
      echo "· m3 ≠ m4 ($(diff "$OUT/m3.wat" "$OUT/m4.wat" 2>/dev/null | grep -c '^[<>]') diff lines; m4 exit=$m4rc)"
      fixok=0
    fi
  fi
fi
# VERB PARITY — this script's own successor has to be able to run.
#
# `mentl march` is what this file absorbs into (PLAN §11 10.3), and it was
# DEAD: its hand-copied handler chain had lost lower_handler_stack_ctx, so the
# frame fence's perform hit the unhandled floor on every march the verb ran.
# Nothing caught it for as long as it was broken, because the board calls this
# script and never the verb — a gate that stops being reported stops being run
# (§11 tripwire 4), one layer up, where the scaffold's own existence was the
# cover. The wheel is judged by its ability to judge itself, so the verb runs
# here on the same generation and must agree with the m3 leg's line count.
[ -z "$TRAP" ] && [ "$m3rc" = 0 ] && [ "$fixok" = 1 ] && [ "$costok" = 1 ] && [ "$censusok" = 1 ]
