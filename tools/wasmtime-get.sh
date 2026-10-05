#!/usr/bin/env bash
# tools/wasmtime-get.sh — fetch the pinned engine: the off-the-shelf wasmtime
# binary that hosts boot/mentl.wasm in the terminal.
#
#   bash tools/wasmtime-get.sh     # → .build/wasmtime/wasmtime-v36.0.2-x86_64-linux/wasmtime
#
# ONE engine, pinned by version AND by the release tarball's sha256, because
# a gate's verdict is a function of the engine's bytes (tools/wt-env.sh keys
# its memos on the version it reports). The pin is 36, the LTS line, and not
# the current release — measured 2026-10-05: 36's `-S threads=y` hosts a
# spawning module (the wasi-threads convention a `><` under a Thread schedule
# emits), which 47 dropped ("the -Sthreads flag is no longer supported"), and
# the frontier's threaded legs need it. Raising the pin is an explicit
# in-commit act carrying the measurement that justifies it.
#
# Nothing of Mentl is in this engine. It satisfies the two imports the wheel
# can ask for — WASI preview1, and wasi-threads for a module that spawns —
# exactly as the browser's worker does (ide/wheel-worker.js): two hosts, one
# contract, no code of ours in any language but WAT. The terminal's final
# host is the native backend (PLAN §11, Phase 10) — Mentl emitting an
# executable that hosts itself — and this script dissolves with it.
set -euo pipefail
cd "$(dirname "$0")/.."

ver=36.0.2
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)  arch=x86_64-linux;  sha=b982d71407b70633707bab9b7bdcaa4a37b98cd2ed55094f864a9ec7bcf0c40d ;;
  *) echo "wasmtime-get: no pinned digest for $(uname -s)-$(uname -m); fetch wasmtime v$ver for it from" >&2
     echo "  https://github.com/bytecodealliance/wasmtime/releases/tag/v$ver" >&2
     echo "  and point MENTL_WASMTIME at the binary (then add its sha256 here)." >&2
     exit 2 ;;
esac
dir=.build/wasmtime
tar="$dir/wasmtime-v$ver-$arch.tar.xz"
bin="$dir/wasmtime-v$ver-$arch/wasmtime"

if [ -x "$bin" ]; then
  echo "wasmtime-get: $bin ($("$bin" --version))"
  exit 0
fi
mkdir -p "$dir"
if ! { [ -s "$tar" ] && printf '%s  %s\n' "$sha" "$tar" | sha256sum -c --status; }; then
  url="https://github.com/bytecodealliance/wasmtime/releases/download/v$ver/wasmtime-v$ver-$arch.tar.xz"
  echo "wasmtime-get: fetching $url"
  curl -fsSL -o "$tar" "$url"
fi
if ! printf '%s  %s\n' "$sha" "$tar" | sha256sum -c --status; then
  echo "wasmtime-get: $tar does not match the pinned sha256 ($sha) — refusing; the file is removed" >&2
  rm -f "$tar"
  exit 2
fi
tar -xJf "$tar" -C "$dir"
[ -x "$bin" ] || { echo "wasmtime-get: the tarball did not unpack to $bin" >&2; exit 2; }
echo "wasmtime-get: $bin ($("$bin" --version))"
