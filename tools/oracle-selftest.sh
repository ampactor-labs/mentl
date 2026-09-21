#!/usr/bin/env bash
# tools/oracle-selftest.sh — the oracle-selftest loop, v1.
#
# RUN BY HAND, NOT BY THE BOARD, and that is a statement about this file's
# destiny rather than a permission. Nothing invokes it — not tools/state.sh,
# not a hook, not tools/ci/run-board.sh — which was measured 2026-09-21 in
# the same audit that found tools/ide-gate.sh off the board while PLAN called
# it green. The difference is that ide-gate is a CONTRACT (a terminal bar a
# phase is measured against) and belongs on the board, while this is an
# INSTRUMENT: it runs the proposer over a corpus and BANKS crucibles, so a
# failure is a find rather than a refusal and a board that refused on it would
# be refusing on discovery. Its destiny is absorption — `mentl test` growing
# the propose-over-a-corpus leg — not a board row.
#
# The medium is its own test generator: its Synth proposer generates the program
# variations (PLAN §11 col 2, "the oracle IS the test generator"). This loop drives that
# through the ADDRESS/edit transport over a corpus of hand-authored skeletons —
# each a complete program with ONE authored `??` in a typed position — then
# compiles, assembles, and runs whatever the medium proposed, and CLASSIFIES the
# outcome. A trapping or non-assemblable result is a banked crucible, not a loop
# failure: the loop found a real gap. We do not fix compiler code here; we bank.
#
# For each skeleton:
#   (a) run `edit` non-interactively against a SCRATCH COPY (printf 'y\n' accepts
#       the top survivor; the medium patches the file in place, or refuses to
#       guess and leaves the `??`);
#   (b) compile the patched file through the compiler via stdin, assemble with
#       wt_asm, run with the canonical flags;
#   (c) classify: edit-trap / compile-error / assemble-fail / runtime-trap /
#       refuse-unfilled / clean-run — one line per case to a results TSV;
#   (d) on a finding (edit-trap / compile-error / assemble-fail / runtime-trap)
#       save the reproducer into tests/selftest/crucibles/<stem>/ with a README
#       naming the classification and the site;
#   (e) on a runtime-trap, wire and RUN wasm-tools shrink (predicate: the trap
#       still fires) to bank a minimal reproducer.
#
# Idempotent, no network, every guest invocation bounded by a timeout.
#
# Residue (honest, v1): the SHAPE of each program is hand-authored — this loop
# varies programs only through the medium's own hole-proposals over fixed
# skeletons. Whole-program (decl-level) generation is not a capability the medium
# exposes yet; when `enumerate_inhabitants` gains a real driver it becomes the
# program generator and this corpus becomes its seed set.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
source "$ROOT/tools/wt-env.sh"

COMPILER="$ROOT/boot/mentl.wasm"
EDIT_TIMEOUT=15
COMPILE_TIMEOUT=60
RUN_TIMEOUT=15
SHRINK_TIMEOUT=60

usage() {
  cat <<'EOF'
usage: tools/oracle-selftest.sh [--compiler boot|PATH]

  boot   pinned boot/mentl.wasm (default)
  PATH   an explicit compiler artifact (e.g. a fresh wt_m2_ensure m2.wasm)
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --compiler)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      case "$2" in
        boot) COMPILER="$ROOT/boot/mentl.wasm" ;;
        /*)   COMPILER="$2" ;;
        *)    COMPILER="$ROOT/$2" ;;
      esac
      shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "oracle-selftest: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -f "$COMPILER" ] || { echo "oracle-selftest: compiler not found: $COMPILER" >&2; exit 2; }

SKEL_DIR="$ROOT/tests/selftest/skeletons"
CRUCIBLE_DIR="$ROOT/tests/selftest/crucibles"
WORK="$ROOT/.build/oracle-selftest"
RESULTS="$WORK/results.tsv"

mkdir -p "$WORK"
# Crucibles are LOOP OUTPUT — regenerated every run, so a graduated finding (a
# skeleton the medium now handles) leaves the dir and a fresh finding enters it.
rm -rf "$CRUCIBLE_DIR"   # protocol-skip: regenerating my own banked crucibles under tests/selftest/
mkdir -p "$CRUCIBLE_DIR"

printf 'stem\tshape\tedit_rc\tfilled\tclass\texpect\tmatch\tdetail\n' > "$RESULTS"

# read_directive <file> <key> — the value after `// <key>:` (self-describing
# skeletons carry their own shape and expected class; one home, the file itself).
read_directive() {
  grep -m1 -oE "// $2: *[A-Za-z0-9_-]+" "$1" 2>/dev/null | sed -E "s|// $2: *||"
}

# wheel_frames <errfile> — the top wheel functions on a guest backtrace, the
# site an edit/compile trap fires at (never grep the minified emit — read the
# name section the backtrace already resolves).
wheel_frames() {
  grep -oE '<unknown>!(\?\?_)?[a-zA-Z0-9_]+' "$1" 2>/dev/null \
    | sed 's/<unknown>!//' | grep -v '^_start$' | head -3 | paste -sd, -
}

trap_message() {
  grep -oE 'wasm trap: .*' "$1" 2>/dev/null | head -1
}

# bank_crucible <stem> <class> <detail> <srcdir> [artifact...]
# artifact = a filename in <srcdir> to copy into the crucible.
bank_crucible() {
  local stem="$1" class="$2" detail="$3" srcdir="$4"; shift 4
  local cru="$CRUCIBLE_DIR/$stem"
  mkdir -p "$cru"
  cp -f "$SKEL_DIR/$stem.mn" "$cru/$stem.mn"
  local a
  for a in "$@"; do [ -f "$srcdir/$a" ] && cp -f "$srcdir/$a" "$cru/"; done
  {
    echo "$stem — classification: $class"
    echo
    echo "$detail"
    echo
    echo "Reproduce (from repo root):"
    echo "  source tools/wt-env.sh"
    echo "  d=\$(mktemp -d /tmp/cru_XXXX); cp tests/selftest/crucibles/$stem/$stem.mn \$d/"
    case "$class" in
      edit-trap)
        echo "  printf 'y\\n' | \"\$WT\" run \"\${WT_RUN_FLAGS[@]}\" --dir \"\$d\" boot/mentl.wasm edit $stem"
        echo "  # traps in the compiler (boot) while projecting the cursor — see $stem.edit.err" ;;
      compile-error)
        echo "  wt_run boot/mentl.wasm < \$d/$stem.mn   # see $stem.compile.err" ;;
      assemble-fail)
        echo "  wt_run boot/mentl.wasm < \$d/$stem.mn > \$d/$stem.wat"
        echo "  wt_asm \$d/$stem.wat \$d/$stem.wasm   # wat2wasm rejects the emit — see $stem.assemble.err" ;;
      runtime-trap)
        echo "  wt_run boot/mentl.wasm < \$d/$stem.mn > \$d/$stem.wat"
        echo "  wt_asm \$d/$stem.wat \$d/$stem.wasm && wt_run \$d/$stem.wasm   # traps at runtime" ;;
    esac
  } > "$cru/README"
}

# shrink_crucible <stem> <srcdir> <wasm> <trapmsg> — mechanical minimal repro.
# Predicate: the candidate module still traps with the SAME message under the
# canonical flags. Banks the shrunk module (as WAT) + the log into the crucible.
shrink_crucible() {
  local stem="$1" srcdir="$2" wasm="$3" trapmsg="$4"
  local cru="$CRUCIBLE_DIR/$stem"
  local pred="$cru/shrink-predicate.sh"
  cat > "$pred" <<PRED
#!/usr/bin/env bash
# exit 0 iff the candidate ($stem.wasm) still traps: $trapmsg
WT="$WT"
out=\$("\$WT" run ${WT_RUN_FLAGS[*]} "\$1" 2>&1)
printf '%s' "\$out" | grep -qF '$trapmsg'
PRED
  chmod +x "$pred"
  local shrunk="$srcdir/$stem.shrunk.wasm" log="$cru/shrink.log"
  if timeout "$SHRINK_TIMEOUT" wasm-tools shrink "$pred" "$wasm" -o "$shrunk" > "$log" 2>&1; then
    local before after
    before=$(wc -c < "$wasm")
    after=$(wc -c < "$shrunk" 2>/dev/null || echo '?')
    wasm2wat "${WABT_FEATURE_FLAGS[@]}" "$shrunk" -o "$cru/$stem.shrunk.wat" 2>/dev/null
    {
      echo
      echo "Shrunk with wasm-tools ${before}B -> ${after}B (predicate: still traps '$trapmsg')."
      echo "  wasm-tools shrink ./shrink-predicate.sh $stem.wasm -o $stem.shrunk.wasm"
      echo "Minimal reproducer: $stem.shrunk.wat"
    } >> "$cru/README"
    echo "shrunk ${before}B->${after}B"
  else
    { echo; echo "shrink did not converge within ${SHRINK_TIMEOUT}s (see shrink.log)."; } >> "$cru/README"
    echo "shrink-timeout"
  fi
}

run_skeleton() {
  local skel="$1"
  local stem; stem="$(basename "$skel" .mn)"
  local shape expect
  shape="$(read_directive "$skel" selftest-shape)"; shape="${shape:-unknown}"
  expect="$(read_directive "$skel" selftest-expect)"; expect="${expect:-?}"

  local d; d="$(mktemp -d /tmp/selftest_run_XXXX)"
  cp "$skel" "$d/$stem.mn"

  # ── (a) EDIT: the address transport proposes into the hole and (if a single
  #    survivor) patches in place. `printf 'y\n'` accepts the top candidate.
  local edit_rc
  printf 'y\n' | timeout "$EDIT_TIMEOUT" "$WT" run "${WT_RUN_FLAGS[@]}" \
    --dir "$d" "$COMPILER" edit "$stem" > "$d/$stem.edit.out" 2> "$d/$stem.edit.err"
  edit_rc=$?

  local filled=no
  grep -q '??' "$d/$stem.mn" || filled=yes

  local class detail

  # A guest trap during edit (rc not clean-0 and not timeout-124) is a finding:
  # the medium's own projection/synthesis crashed on this input.
  if [ "$edit_rc" -ne 0 ] && [ "$edit_rc" -ne 124 ]; then
    class="edit-trap"
    detail="edit rc=$edit_rc; $(trap_message "$d/$stem.edit.err"); frames: $(wheel_frames "$d/$stem.edit.err")"
    bank_crucible "$stem" "$class" "$detail" "$d" "$stem.edit.err"
  else
    # ── (b) COMPILE the (possibly patched) file through the compiler via stdin.
    local crc watbytes
    timeout "$COMPILE_TIMEOUT" "$WT" run "${WT_RUN_FLAGS[@]}" "$COMPILER" \
      < "$d/$stem.mn" > "$d/$stem.wat" 2> "$d/$stem.compile.err"
    crc=$?
    watbytes=$(wc -c < "$d/$stem.wat")

    if [ "$crc" -ne 0 ] || [ "$watbytes" -eq 0 ]; then
      if grep -q 'E_UnresolvedHole' "$d/$stem.compile.err"; then
        # The medium refused to guess (tie / no survivor) — correct behavior,
        # the executable gate held. Not a finding.
        class="refuse-unfilled"
        detail="hole left authored; executable gate refused (E_UnresolvedHole)"
      else
        class="compile-error"
        detail="compile rc=$crc watbytes=$watbytes; $(grep -m1 -E '[EWVTP]_[A-Za-z0-9_]+' "$d/$stem.compile.err" | sed 's/^ *//')"
        bank_crucible "$stem" "$class" "$detail" "$d" "$stem.compile.err"
      fi
    else
      # ── have WAT; assemble it.
      if wt_asm "$d/$stem.wat" "$d/$stem.wasm" 2> "$d/$stem.assemble.err"; then
        # ── run it; a trap message on stderr is a runtime-trap, any other
        #    exit code is the program's intended exit.
        local rrc
        timeout "$RUN_TIMEOUT" "$WT" run "${WT_RUN_FLAGS[@]}" "$d/$stem.wasm" \
          > "$d/$stem.run.out" 2> "$d/$stem.run.err"
        rrc=$?
        local tmsg; tmsg="$(trap_message "$d/$stem.run.err")"
        if [ -n "$tmsg" ]; then
          class="runtime-trap"
          detail="filled fill ran and trapped: $tmsg (exit=$rrc)"
          # Bank the emit as WAT (text) + the shrunk minimal repro; the raw
          # .wasm is the shrink INPUT (transient in $d), regenerable from the
          # .mn via the README's reproduce steps — never committed as a binary.
          bank_crucible "$stem" "$class" "$detail" "$d" "$stem.wat"
          local sres; sres="$(shrink_crucible "$stem" "$d" "$d/$stem.wasm" "${tmsg#wasm trap: }")"
          detail="$detail; $sres"
        else
          class="clean-run"
          detail="exit=$rrc"
        fi
      else
        class="assemble-fail"
        detail="wat2wasm rejected the emit: $(head -1 "$d/$stem.assemble.err" | sed -E 's/\x1b\[[0-9;]*m//g')"
        bank_crucible "$stem" "$class" "$detail" "$d" "$stem.wat" "$stem.assemble.err"
      fi
    fi
  fi

  local match="—"
  if [ "$expect" != "?" ]; then
    if [ "$expect" = "$class" ]; then match="MATCH"; else match="CHANGED"; fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$stem" "$shape" "$edit_rc" "$filled" "$class" "$expect" "$match" "$detail" >> "$RESULTS"
  printf '  %-22s %-18s %-14s %-8s %s\n' "$stem" "$shape" "$class" "$match" "$detail"
}

echo "oracle-selftest: compiler=$COMPILER"
echo "oracle-selftest: corpus=$SKEL_DIR"
echo

shopt -s nullglob
skels=("$SKEL_DIR"/*.mn)
shopt -u nullglob
if [ "${#skels[@]}" -eq 0 ]; then
  echo "oracle-selftest: no skeletons found in $SKEL_DIR" >&2
  exit 2
fi

for skel in $(printf '%s\n' "${skels[@]}" | sort); do
  run_skeleton "$skel"
done

echo
echo "oracle-selftest: classification counts"
awk -F'\t' 'NR>1 {c[$5]++} END {for (k in c) printf "  %-16s %d\n", k, c[k]}' "$RESULTS" | sort
echo
banked=$(find "$CRUCIBLE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
changed=$(awk -F'\t' 'NR>1 && $7=="CHANGED"' "$RESULTS" | wc -l | tr -d ' ')
echo "oracle-selftest: $banked crucible(s) banked in tests/selftest/crucibles/; results: $RESULTS"
if [ "$changed" -gt 0 ]; then
  echo "oracle-selftest: $changed skeleton(s) CHANGED class vs their selftest-expect (a finding graduated or regressed):"
  awk -F'\t' 'NR>1 && $7=="CHANGED" {printf "  %s: expected %s, got %s\n", $1, $6, $5}' "$RESULTS"
fi
# A run that completed is a success regardless of how many findings it banked —
# findings are the point. Only an infra failure (handled above) exits nonzero.
exit 0
