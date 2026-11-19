#!/usr/bin/env bash
# The IDE gate checks the browser page (ide/index.html) on the pinned compiler.
# Leg 1 runs ide/test-shim.mjs, which drives ide/wheel-worker.js, the host the
#   page uses, from node: compiling, the session, proposals and the canvas.
# Leg 2 stages the site (tools/space-stage.sh), serves it with the isolation
#   headers (tools/space-serve.py) and opens it in headless Chrome at ?smoke.
#   The page prints one SMOKE line per check (smoke() in ide/index.html), and
#   this script judges each: the project, the View, what the page painted,
#   the sound lesson 1 writes, and the canvas. The page parses nothing the
#   compiler printed. Leg 2 is skipped, and says so, when no browser is found
#   in $MENTL_CHROME, on PATH or under $PLAYWRIGHT_BROWSERS_PATH.
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
  # The site the gate drives is the site the deploy ships: ide/space.manifest
  # staged by tools/space-stage.sh and served with the two isolation headers
  # by tools/space-serve.py — never the repo root, so a file the page needs
  # and the manifest lacks is red here before it is a 404 in production.
  port="${MENTL_IDE_GATE_PORT:-7397}"
  stage=".build/space"
  bash tools/space-stage.sh "$stage" >/dev/null || { echo "  staging FAILED"; fail=1; }
  # A candidate compiler (MENTL_IDE_WASM — the twin's seam too) replaces the
  # staged boot, so a wheel landing's page is judged against the wheel it
  # carries before the repin makes that wheel the boot.
  if [ -n "${MENTL_IDE_WASM:-}" ]; then cp "$MENTL_IDE_WASM" "$stage/boot/mentl.wasm" && echo "  candidate: $MENTL_IDE_WASM"; fi
  python3 tools/space-serve.py "$stage" "$port" &
  sp=$!
  sleep 1
  echo "  browser: $browser"
  # ide/browser-leg.mjs drives the browser over its debugging pipe: it loads
  # ?smoke, prints the page's SMOKE lines as the console wire carries them,
  # captures .build/space.png once the product leg has run and
  # .build/space-parchment.png once the other ground says SPACE-READY. (A
  # --screenshot with a virtual-time budget never returns on this page — the
  # session's worker blocks inside the wheel's own read — and without one it
  # captures the load event, before the wheel has booted.)
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
  # The product — what the page RENDERS, measured in the browser: the
  # projection shows every character the hand typed (a lost space was live
  # in production for weeks), no \`undefined\` reaches the chrome, eight real
  # ring rows painted from the View, and the Lens STRUCTURAL — a Warning
  # lands as a Warning at its own line and a mismatch at its own site (the
  # page's regexes had both wrong: lowercase kinds only, and the first
  # address in a message — a Reason's — over the diagnostic's span).
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
  # THE CANVAS (L-D) — the text painted from the wheel's own projection:
  # no tokenizer in the page; every painted token the source sliced at the
  # span the canvas names (a count, never "some"); every strip cell painted
  # the View's own cell at its line; frames and proof marks drawn from the
  # canvas; the references at a caret drawn where the View puts them, and a
  # needle's listed; the formatter's canon on idle; the accept one step of
  # the native undo. RED on the page before L-D: it carried its own lexer
  # and printed no canvas line; and with the pinned boot under the new page,
  # tokens=0 and no refs (the boot answers no canvas).
  num() { echo "$cline" | grep -oE "(^| )$1=[^ ]+" | head -1 | cut -d= -f2; }
  case "$cline" in
    "SMOKE-CANVAS no-page-lexer=true "*)
      tk=$(num tokens); sp=$(num spans); st=$(num strip); fr=$(num frames); mk=$(num marks)
      rc=$(num refs-at-caret); rd=$(num refs-drawn); nd=$(num needle); nl=$(num needle-listed)
      fmtv=$(num fmt); und=$(num undone); acc=$(num accepted); ct=$(num canvas-text)
      # canvas-text: the canvas the line counts was judged for the text on the
      # page. The smoke used to read whatever canvas the page held when its
      # settle window closed — tokens=0 on a loaded machine, and 26 (a smaller
      # step's program) where the fixture's own canvas has 115 — so a green
      # here could measure the wrong canvas (2026-10-13).
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
else
  echo "── ide gate · leg 2 SKIPPED (no browser found — set MENTL_CHROME) ──"
fi

if [ $fail -eq 0 ]; then echo "ide gate: GREEN"; else echo "ide gate: RED"; fi
exit $fail
