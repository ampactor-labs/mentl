#!/usr/bin/env bash
# tools/space-stage.sh — stage Mentl Space: the page and every file it fetches.
#
#   bash tools/space-stage.sh [out=.build/space]
#
# ide/space.manifest is the ONE home of what the site is: the page reads it
# to know what to fetch, this script copies exactly those files beside the
# page, and the deploy workflow and the IDE gate both serve THIS directory —
# so a file the page needs and the deploy lacks is a red gate, never a 404
# found in production. The manifest's `root` line names where the page finds
# its files: `..` in the repo (the page lives in ide/), `.` once staged (the
# files are copied beside it).
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-.build/space}"
rm -rf "$out"
mkdir -p "$out"
cp -r ide/. "$out"/
sed -i 's/^root .*/root ./' "$out/space.manifest"
while read -r kind path; do
  case "$kind" in ''|'#'*|root) continue ;; esac
  [ -f "$path" ] || { echo "space-stage: $path (manifest: $kind) is not a file" >&2; exit 1; }
  mkdir -p "$out/$(dirname "$path")"
  cp "$path" "$out/$path"
done < ide/space.manifest
echo "space-stage: $out ← ide/ + $(grep -cvE '^(#|root|$)' ide/space.manifest) manifest files"
