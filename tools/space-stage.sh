#!/usr/bin/env bash
# tools/space-stage.sh — stage Mentl Space: the page and every file it fetches.
#
#   bash tools/space-stage.sh [out=.build/space] [project-dir...]
#
# ide/space.manifest is the ONE home of what the site is: the page reads it
# to know what to fetch, this script copies exactly those files beside the
# page, and the deploy workflow and the IDE gate both serve THIS directory —
# so a file the page needs and the deploy lacks is a red gate, never a 404
# found in production. The manifest's `root` line names where the page finds
# its files: `..` in the repo (the page lives in ide/), `.` once staged (the
# files are copied beside it).
#
# A `project <dir>` line names a folder of modules — a program of several
# files (examples/pulse/render), the session's entry its main.mn and the
# rest its imports — and a static host cannot list a folder, so staging
# EXPANDS it: the folder's .mn files are copied at their paths and the
# staged manifest carries one `member <path>` line per module under the
# project line. A directory given on the command line (`mentl space <dir>`)
# is staged the same way, under project/<its name>.
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-.build/space}"
[ $# -gt 0 ] && shift
rm -rf "$out"
mkdir -p "$out"
cp -r ide/. "$out"/
stage_file() {  # stage_file <path> — one file the page fetches, at its own path
  [ -f "$1" ] || { echo "space-stage: $1 is not a file" >&2; exit 1; }
  mkdir -p "$out/$(dirname "$1")"
  cp "$1" "$out/$1"
}
stage_project() {  # stage_project <staged-dir> <source-dir> — the folder's modules, one member line each
  local dir="$1" src="$2" f n=0
  [ -d "$src" ] || { echo "space-stage: $src is not a directory" >&2; exit 1; }
  echo "project $dir"
  while IFS= read -r f; do
    mkdir -p "$out/$dir"
    cp "$f" "$out/$dir/$(basename "$f")"
    echo "member $dir/$(basename "$f")"
    n=$((n + 1))
  done < <(find "$src" -maxdepth 1 -name '*.mn' | sort)
  [ "$n" -gt 0 ] || { echo "space-stage: $src holds no .mn module" >&2; exit 1; }
}
{
  while IFS= read -r line; do
    case "$line" in
      ''|'#'*) echo "$line" ;;
      'root '*) echo "root ." ;;
      'project '*) stage_project "${line#project }" "${line#project }" ;;
      *) echo "$line"; stage_file "${line#* }" ;;
    esac
  done < ide/space.manifest
  for d in "$@"; do stage_project "project/$(basename "$d")" "$d"; done
} > "$out/space.manifest"
echo "space-stage: $out ← ide/ + $(grep -cE '^(wasm|lib|program|member) ' "$out/space.manifest") files"
