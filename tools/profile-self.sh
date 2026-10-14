#!/usr/bin/env bash
# profile-self.sh [compiler.wasm] [out.json] — the self-compile under
# wasmtime's guest profiler, summarized. The march verb returns from `main`
# rather than ending through `proc_exit`, so the profiler writes its dump.
# The compiler defaults to the candidate the gates last built
# (.build/m2cache/m2.wasm); pass boot/mentl.wasm to profile the pinned wheel.
# Read the result with tools/guest-profile.py (its --callers FN names who
# reaches a hot function).
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/wt-env.sh >/dev/null 2>&1
wasm=$(realpath "${1:-.build/m2cache/m2.wasm}")
out=$(realpath -m "${2:-.build/profile/self.json}")
mkdir -p "$(dirname "$out")" .build
root=$(mktemp -d "$(realpath .build)/wheel-root.XXXXXX")
trap 'rm -rf "$root"' EXIT
cp -r src lib "$root"/
( cd "$root" && "$WT" run "${WT_RUN_FLAGS[@]}" --profile="guest,$out,10ms" --dir . "$wasm" march > /dev/null 2> "$out.err" )
python3 tools/guest-profile.py "$out" 30
