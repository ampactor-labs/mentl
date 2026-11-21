#!/usr/bin/env bash
# The IDE gate checks the browser page (ide/index.html) on the pinned compiler.
# Leg 1 runs ide/test-shim.mjs, which drives ide/wheel-worker.js, the host the
#   page uses, from node: compiling, the session, proposals and the canvas.
# Leg 2 stages the site (tools/space-stage.sh), serves it with the isolation
#   headers (tools/space-serve.py) and opens it in headless Chrome at ?smoke.
#   The page prints one SMOKE line per check (smoke() in ide/index.html), and
#   this script judges each: the project, the View, what the page painted,
#   the sound lesson 1 writes, the canvas, and where a link opens. Leg 2 is
#   skipped, and says so, when no browser is found in $MENTL_CHROME, on PATH
#   or under $PLAYWRIGHT_BROWSERS_PATH.
set -u
cd "$(dirname "$0")/.."
fail=0

echo "── ide gate · leg 1: the node twin ──"
node ide/test-shim.mjs || fail=1

find_browser() {
  if [ -n "${MENTL_CHROME:-}" ] && [ -x "$MENTL_CHROME" ]; then echo "$MENTL_CHROME"; return; fi
  local c
  for c in google-chrome chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
  done
  for c in "${PLAYWRIGHT_BROWSERS_PATH:-/opt/pw-browsers}"/chromium-*/chrome-linux*/chrome; do
    if [ -x "$c" ]; then echo "$c"; return; fi
  done
}
browser=$(find_browser)

if [ -n "$browser" ]; then
  echo "── ide gate · leg 2: the browser (the STAGED site + headless chrome) ──"
  # The gate drives the site the deploy ships, staged and served as the deploy serves it.
  port="${MENTL_IDE_GATE_PORT:-7397}"
  stage=".build/space"
  bash tools/space-stage.sh "$stage" >/dev/null || { echo "  staging FAILED"; fail=1; }
  # A candidate (MENTL_IDE_WASM) replaces the staged boot, so a landing's page is judged before its repin.
  if [ -n "${MENTL_IDE_WASM:-}" ]; then cp "$MENTL_IDE_WASM" "$stage/boot/mentl.wasm" && echo "  candidate: $MENTL_IDE_WASM"; fi
  python3 tools/space-serve.py "$stage" "$port" &
  sp=$!
  sleep 1
  echo "  browser: $browser"
  # ide/browser-leg.mjs drives the browser over its debugging pipe and prints
  # the page's SMOKE and SPACE-READY lines (its header says why it is needed).
  lines=$(timeout 240 node ide/browser-leg.mjs "$browser" "http://127.0.0.1:$port/" .build 2>&1 | grep -E '^(SMOKE|SPACE-READY|PAGE-ERROR|BROWSER-LEG-ERROR)')
  kill "$sp" 2>/dev/null
  vline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-VIEW')
  jline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-PROJECT')
  pline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-PRODUCT')
  cline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-CANVAS')
  printf '%s\n' "$lines" | grep -E '^(PAGE-ERROR|BROWSER-LEG-ERROR|SMOKE-BOOT-FAIL|SMOKE-TIMEOUT)' | sed 's/^/  /'
  echo "  $vline"
  echo "  $jline"
  echo "  $pline"
  echo "  $cline"
  # THE PROJECT (L-C): a folder of modules the manifest names opens in the
  # same session — its main.mn the entry, every module editable under its
  # own name — and its View comes from the resident session, eight facts,
  # no refusing diagnostic (examples/pulse/render judges clean in the page).
  case "$jline" in
    "SMOKE-PROJECT "*"resident=true"*)
      pj_ring=$(echo "$jline" | grep -oE 'ring=[0-9]+' | cut -d= -f2); pj_ref=$(echo "$jline" | grep -oE 'refusing=-?[0-9]+' | cut -d= -f2)
      if [ "${pj_ring:-0}" -eq 8 ] && [ "${pj_ref:--1}" -eq 0 ]; then
        echo "  project leg: PASS — $(echo "$jline" | grep -oE 'dir=[^ ]+' | cut -d= -f2) opened in the session ($(echo "$jline" | grep -oE 'members=[0-9]+' | cut -d= -f2) modules), its View 8 facts, 0 refusing"
      else
        echo "  project leg: FAIL — ring=${pj_ring:-0} refusing=${pj_ref:--1}"; fail=1
      fi ;;
    *) echo "  project leg: FAIL — ${jline:-no SMOKE-PROJECT line}"; fail=1 ;;
  esac
  # THE VIEW (L-C): the first lesson's View arrived from the page's own
  # session — eight ring facts, no refusing diagnostic (the lesson judges
  # clean), the ledger present — and a second read of it was answered by
  # the session, not a fresh instance, with its size and time printed.
  field() { echo "$2" | grep -oE "$1=[^ ]+" | cut -d= -f2; }
  case "$vline" in
    "SMOKE-VIEW "*"resident=true"*)
      ring=$(field ring "$vline"); refusing=$(field refusing "$vline"); ledger=$(field ledger "$vline")
      if [ "${ring:-0}" -eq 8 ] && [ "${refusing:--1}" -eq 0 ] && [ "${ledger:--1}" -ge 0 ]; then
        echo "  view leg: PASS — the first lesson's View came from the session (open $(field open "$vline") ms, read $(field read "$vline") ms, $(field bytes "$vline") bytes; 8 ring facts, 0 refusing)"
      else
        echo "  view leg: FAIL — ring=${ring:-0} refusing=${refusing:--1} ledger=${ledger:--1}"; fail=1
      fi ;;
    *) echo "  view leg: FAIL — ${vline:-no SMOKE-VIEW line}"; fail=1 ;;
  esac
  # The product, what the page renders: every character the hand typed, no
  # `undefined` in the chrome, eight ring rows from the View, and a Warning
  # and a mismatch each shown at its own line.
  case "$pline" in
    *"fidelity=true undefined=false"*"lens-warning-at-line=true lens-mismatch-at-site=true"*)
      ring=$(field ring-real "$pline")
      if [ "${ring:-0}" -ge 8 ]; then
        echo "  product leg: PASS — fidelity, no undefined, 8 real rows from the View, the Lens structural; screenshots .build/space.png (obsidian, the canvas fixture, caret projected) and .build/space-parchment.png"
      else
        echo "  product leg: FAIL — ring-real=${ring:-0}"; fail=1
      fi ;;
    *) echo "  product leg: FAIL — ${pline:-no SMOKE-PRODUCT line}"; fail=1 ;;
  esac
  # The canvas, the text painted from the compiler's own spans: no tokenizer
  # in the page, every token and strip cell where the canvas puts it, frames
  # and marks drawn, references at a caret and a needle's listed, the
  # formatter's layout on idle, and an accept one step of the undo.
  num() { echo "$cline" | grep -oE "(^| )$1=[^ ]+" | head -1 | cut -d= -f2; }
  case "$cline" in
    "SMOKE-CANVAS no-page-lexer=true "*)
      tk=$(num tokens); sp=$(num spans); st=$(num strip); fr=$(num frames); mk=$(num marks)
      rc=$(num refs-at-caret); rd=$(num refs-drawn); nd=$(num needle); nl=$(num needle-listed)
      fmtv=$(num fmt); und=$(num undone); acc=$(num accepted); ct=$(num canvas-text)
      # canvas-text: the canvas counted was judged for the text on the page.
      if [ "${tk:-0}" -gt 0 ] && [ "$ct" = true ] && [[ "$sp" =~ ^[0-9]+$ ]] && [[ "$st" =~ ^[0-9]+$ ]] && [ "${fr:-0}" -gt 0 ] && [ "${mk:-0}" -gt 0 ] \
         && [ "${rc:--1}" -gt 0 ] && [ "${rd:-0}" -eq "${rc:--1}" ] && [ "${nd:--1}" -gt 0 ] && [ "${nl:-0}" -eq "${nd:--1}" ] \
         && [ "$fmtv" = true ] && [ "$acc" = true ] && [ "$und" = true ]; then
        echo "  canvas leg: PASS — $tk tokens from the wheel for the text on the page, $sp painted spans and $st strip cells faithful, $fr frames, $mk marks, $rc reference(s) at the caret drawn, $nd for the needle listed, fmt on idle, the accept one undo step"
      else
        echo "  canvas leg: FAIL — $cline"; fail=1
      fi ;;
    *) echo "  canvas leg: FAIL — ${cline:-no SMOKE-CANVAS line}"; fail=1 ;;
  esac
  # The sound leg: lesson 1, run by the page's Run function, wrote a WAV file
  # of 144,000 frames at 48,000 a second in 2 channels (3 seconds), whose
  # left channel crosses zero upward 220 times a second (a 220 Hz tone).
  sline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-SOUND'); echo "  $sline"; cps=$(field crossings-per-second "$sline")
  if [ "$(field wav "$sline")" = true ] && [ "$(field frames "$sline")" = 144000 ] && [ "$(field rate "$sline")" = 48000 ] \
     && [ "$(field channels "$sline")" = 2 ] && [ "$(printf '%.0f' "${cps:-0}" 2>/dev/null)" = 220 ]; then
    echo "  sound leg: PASS — lesson 1 wrote 144000 frames at 48000 a second in 2 channels; the left channel crosses zero upward $cps times a second"
  else echo "  sound leg: FAIL — ${sline:-no SMOKE-SOUND line}"; fail=1; fi
  # The link leg: a visit with no link opens lesson 1, and the address SYNTAX
  # gives lesson 3's share opens it at that caret, where the ring says what
  # `mentl examples/pulse/course/03-bus.mn:49:30` says.
  printf '%s\n' "$lines" | grep '^SPACE-READY' | sed 's/^/  /'
  case "$lines" in
    *"SPACE-READY "*"program=examples/pulse/course/01-tone.mn "*"SPACE-READY "*"program=examples/pulse/course/03-bus.mn at=examples/pulse/course/03-bus.mn:49:30 "*'topology="the <| shares `dry` with 2 branches, borrowed, so they cannot race"'*)
      echo "  link leg: PASS — lesson 1 opens first, and the link opens lesson 3 at 49:30 with the answer mentl gives there" ;;
    *) echo "  link leg: FAIL — the page did not open lesson 1 first, or the link did not open lesson 3 at 49:30 with that answer"; fail=1 ;;
  esac
  # The pin leg: the page names the compiler it loaded as boot/PROVENANCE.md does, or as a candidate (PLAN §4㉓).
  h=$(sha256sum "$stage/boot/mentl.wasm" | cut -c1-12); read -r _ pn ps < <(grep '^pin ' "$stage/space.manifest"); want=$([ "${ps:0:12}" = "$h" ] && [ "$pn" != - ] && echo "$pn:$h" || echo "candidate:$h")
  case "$lines" in *"SPACE-READY "*"pin=$want "*) echo "  pin leg: PASS — the page names the compiler it loaded, $want" ;; *) echo "  pin leg: FAIL — the page did not print pin=$want"; fail=1 ;; esac
else
  echo "── ide gate · leg 2 SKIPPED (no browser found — set MENTL_CHROME) ──"
fi

if [ $fail -eq 0 ]; then echo "ide gate: GREEN"; else echo "ide gate: RED"; fi
exit $fail
