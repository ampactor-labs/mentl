#!/usr/bin/env bash
# the IDE gate — the browser host, held green.
#
# Leg 1: the node twin (ide/test-shim.mjs) drives ide/wheel-worker.js — the
#   SAME execution host the page uses — through its faces: compile-stdin,
#   the stub-spawn RED control (armed only while the judgment spawns —
#   VACUOUS and said so otherwise: the judgment has spawned nothing since
#   pin 7c9dc538), the address CursorView, the ?? Propose socket, and the
#   resident session. The twin loads boot/mentl.wasm itself (2026-09-27).
# Leg 2: the browser itself — mentl space serves the page, headless chrome
#   loads /ide/?smoke, and the page's own console wire reports the compile
#   verdict (exit, wat lines, spawned task count — reported) and then the
#   resident session's (one open, one read, both timed, the read answered by
#   the session rather than a fresh instance). Skipped, loudly, when
#   no browser or the mentl shim is absent. The browser is FOUND, not
#   assumed: $MENTL_CHROME, then google-chrome / chromium /
#   chromium-browser on PATH, then a Playwright chromium under
#   $PLAYWRIGHT_BROWSERS_PATH. The leg tested for the literal command
#   `google-chrome` and skipped on every board until 2026-09-25, when a
#   container with Playwright's chromium ran it green on the first try.
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
  for c in "${PLAYWRIGHT_BROWSERS_PATH:-/opt/pw-browsers}"/chromium-*/chrome-linux/chrome; do
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
  line=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE exit')
  sline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-SESSION')
  pline=$(printf '%s\n' "$lines" | grep -m1 '^SMOKE-PRODUCT')
  printf '%s\n' "$lines" | grep -E '^(PAGE-ERROR|BROWSER-LEG-ERROR|SMOKE-BOOT-FAIL|SMOKE-TIMEOUT)' | sed 's/^/  /'
  echo "  $line"
  echo "  $sline"
  echo "  $pline"
  case "$line" in
    "SMOKE exit=0 "*)
      tasks=$(echo "$line" | grep -oE 'tasks=[0-9]+' | cut -d= -f2)
      watlines=$(echo "$line" | grep -oE 'watlines=[0-9]+' | cut -d= -f2)
      # The WAT is the verdict; the task count is a measurement (the judgment
      # spawns nothing by design since pin 7c9dc538 — judge once).
      if [ "${watlines:-0}" -gt 1 ]; then
        echo "  browser leg: PASS — the first lesson compiled in the page ($watlines wat lines; ${tasks:-0} worker tasks, reported)"
      else
        echo "  browser leg: FAIL — exit 0 but no WAT came back (watlines=${watlines:-0})"; fail=1
      fi ;;
    *) echo "  browser leg: FAIL"; fail=1 ;;
  esac
  # The resident session in the browser itself (E2): the page's own client
  # opens one instance and reads its graph; the read must be answered by
  # the session, not by a fresh instance, and must project.
  case "$sline" in
    *"resident=true query=true"*)
      echo "  session leg: PASS — the page's session kept its graph (open $(echo "$sline" | grep -oE 'open=[0-9]+' | cut -d= -f2) ms, read $(echo "$sline" | grep -oE 'read=[0-9.]+' | cut -d= -f2) ms)" ;;
    *) echo "  session leg: FAIL — ${sline:-no SMOKE-SESSION line}"; fail=1 ;;
  esac
  # The product — what the page RENDERS, measured in the browser: the
  # projection shows every character the hand typed (a lost space was live
  # in production for weeks), no \`undefined\` reaches the chrome, every
  # facet line the compiler printed has a real ring row, and the Lens holds
  # no telemetry dressed as a diagnostic.
  case "$pline" in
    *"fidelity=true undefined=false"*"lens-telemetry=false"*)
      facets=$(echo "$pline" | grep -oE 'facets=[0-9]+' | cut -d= -f2)
      ring=$(echo "$pline" | grep -oE 'ring-real=[0-9]+' | cut -d= -f2)
      if [ "${facets:-0}" -gt 0 ] && [ "${ring:-0}" -ge 8 ]; then
        echo "  product leg: PASS — fidelity, no undefined, $facets facet lines on 8 real rows, Lens clean; screenshots .build/space.png (obsidian, caret projected) and .build/space-parchment.png"
      else
        echo "  product leg: FAIL — facets=${facets:-0} ring-real=${ring:-0}"; fail=1
      fi ;;
    *) echo "  product leg: FAIL — ${pline:-no SMOKE-PRODUCT line}"; fail=1 ;;
  esac
else
  echo "── ide gate · leg 2 SKIPPED (no browser found — set MENTL_CHROME) ──"
fi

if [ $fail -eq 0 ]; then echo "ide gate: GREEN"; else echo "ide gate: RED"; fi
exit $fail
