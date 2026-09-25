#!/usr/bin/env bash
# the IDE gate — the browser leg of the runner migration, held green.
#
# Leg 1: the node twin (ide/test-shim.mjs) drives ide/wheel-worker.js — the
#   SAME execution host the page uses — through four faces: the stub-spawn
#   RED control (the pre-worker shim must REFUSE the spawning boot), the
#   compile-stdin through real spawned tasks, the address CursorView, and
#   the ?? Propose socket.
# Leg 2: the browser itself — mentl space serves the page, headless chrome
#   loads /ide/?smoke, and the page's own console wire reports the compile
#   verdict (exit, spawned task count, wat lines). Skipped, loudly, when
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

if [ -n "$browser" ] && command -v mentl >/dev/null 2>&1; then
  echo "── ide gate · leg 2: the browser (mentl space + headless chrome) ──"
  port="${MENTL_IDE_GATE_PORT:-7397}"
  MENTL_SPACE_PORT="$port" mentl space >/dev/null 2>&1 &
  sp=$!
  sleep 2
  echo "  browser: $browser"
  line=$(timeout 150 "$browser" --headless=new --disable-gpu --no-sandbox \
    --enable-logging=stderr "http://127.0.0.1:$port/ide/?smoke" 2>&1 | grep -m1 -oE 'SMOKE[^"]*')
  kill "$sp" 2>/dev/null
  echo "  $line"
  case "$line" in
    "SMOKE exit=0 "*)
      tasks=$(echo "$line" | grep -oE 'tasks=[0-9]+' | cut -d= -f2)
      if [ "${tasks:-0}" -gt 0 ]; then
        echo "  browser leg: PASS — the spawning wheel compiled through $tasks worker tasks"
      else
        echo "  browser leg: FAIL — compiled but spawned nothing (the stub era's shape)"; fail=1
      fi ;;
    *) echo "  browser leg: FAIL"; fail=1 ;;
  esac
else
  echo "── ide gate · leg 2 SKIPPED (no browser found — set MENTL_CHROME — or the mentl shim missing) ──"
fi

if [ $fail -eq 0 ]; then echo "ide gate: GREEN"; else echo "ide gate: RED"; fi
exit $fail
