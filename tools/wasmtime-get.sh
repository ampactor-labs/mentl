#!/usr/bin/env bash
# tools/wasmtime-get.sh — fetch the pinned engine: the off-the-shelf wasmtime
# binary that hosts boot/mentl.wasm in the terminal — and PROBE an engine for
# what it hosts, which is how the pin is decided.
#
#   bash tools/wasmtime-get.sh                   # → .build/wasmtime/wasmtime-v<ver>-x86_64-linux/wasmtime
#   bash tools/wasmtime-get.sh probe [<engine>]  # the capability table (the pinned engine by default)
#
# ONE engine, pinned by version AND by the release tarball's sha256, because
# a gate's verdict is a function of the engine's bytes (tools/wt-env.sh reads
# the version below — the pin has one home — and keys its memos on the
# binary). THE PIN IS DECIDED BY THE PROBE, not by recency and not by effort:
# `probe` runs one module per capability and prints what the engine answers.
# Measured 2026-10-05 on 36.0.17 and 49.0.2, both released 2026-10-02:
#
#   capability                        36.0.17 (LTS)   49.0.2
#   WASI preview1 · tail calls ·      yes             yes
#     shared memory + atomics
#   wasi-threads spawn                yes             NO — `-S threads` "no longer
#     (what a `><` under a Thread                       supported" (48 LTS too), and
#     schedule emits: `wasi.thread-                      a module importing it cannot
#     spawn` beside a shared                             instantiate at all
#     `env.memory`)
#   memory64                          yes             yes
#   exceptions (try_table / throw)    no (fails to    yes (exit 7) — also hosted by
#                                       compile)      V8 (node 22, Chromium 141, the
#                                                     page's host) and assembled by
#                                                     WABT 1.0.39 `--enable-exceptions`
#   stack switching (cont.new /       no (panics:     yes (exit 37)
#     suspend / resume)                 "not implemented, yet")
#
# So the line is 36 — the LAST LTS that hosts a spawning Mentl program (36 is
# supported 24 months from 2025-08; 48, the next LTS, removed wasi-threads
# with nothing a core module can call in its place: 49's wat parser rejects
# `thread.spawn_ref`, and its `-W component-model-threading` is a COMPONENT's
# facility). The frontier's threaded legs, the thread gate and every
# `~> parallel_compose` need the spawn, so 49 would turn measured capability
# into skipped gates. What 49 adds is real and is NOT a reason to move:
# stack switching is an engine-owned stack outside the image — a suspended
# continuation there cannot be persisted by memcpy, forked or diffed, which
# is the whole of PLAN §4④ — so it is the representation the medium refuses
# (frames in the image, NATIVE.md keystone 1); exceptions are the honest
# unlock (`Hβ.emit.unwind-by-engine-exceptions`: AN-2's flag protocol is 2,661
# boundary checks the engine's unwinder makes free) and are a BACKEND target
# (`~> Backend`, one emission per target, never an engine-keyed fork of one
# module), buildable once the wheel assembles its own output (L-F) and
# sequenced behind the thread host's move — because the only terminal host
# for a spawning module is this line, which has no exceptions. The thread
# host's horizon and its successor are `Hβ.threads.terminal-host-horizon`
# (RESIDUE.md). Moving the pin is an explicit in-commit act carrying the
# probe's table — a patch within the line (36.0.2 → 36.0.17, same table) as
# much as a line.
#
# Nothing of Mentl is in this engine. It satisfies the two imports the wheel
# can ask for — WASI preview1, and wasi-threads for a module that spawns —
# exactly as the browser's worker does (ide/wheel-worker.js): two hosts, one
# contract, no code of ours in any language but WAT. The terminal's final
# host is the native backend (PLAN §11, Phase 10) — Mentl emitting an
# executable that hosts itself — and this script dissolves with it.
set -euo pipefail
cd "$(dirname "$0")/.."

ver=36.0.17
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)  arch=x86_64-linux;  sha=18a8c2880d15d81f3d0979f39237aea2fb5f862023eb26db6b96c9a69de30fb8 ;;
  *) echo "wasmtime-get: no pinned digest for $(uname -s)-$(uname -m); fetch wasmtime v$ver for it from" >&2
     echo "  https://github.com/bytecodealliance/wasmtime/releases/tag/v$ver" >&2
     echo "  and point MENTL_WASMTIME at the binary (then add its sha256 here)." >&2
     exit 2 ;;
esac
dir=.build/wasmtime
tar="$dir/wasmtime-v$ver-$arch.tar.xz"
bin="$dir/wasmtime-v$ver-$arch/wasmtime"

fetch() {
  if [ -x "$bin" ]; then
    echo "wasmtime-get: $bin ($("$bin" --version))"
    return 0
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
}

# THE PROBE. One module per capability, each answering a distinct exit code
# through proc_exit, so "hosts it" is the engine answering that number and
# nothing else — a compile error, a panic, a refused flag and a wrong value
# all read as "no", with the engine's first line as the reason. Every module
# is written here, beside the pin, because the table is the pin's reason.
probe() {
  local E=$1 d; d="$(mktemp -d)"
  cat > "$d/p1.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") 1)
  (func $three (result i32) (i32.const 3))
  (func (export "_start") (call $exit (call $three))))
WAT
  cat > "$d/tail.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") 1)
  (func $four (param i32) (result i32)
    (if (result i32) (i32.eqz (local.get 0)) (then (i32.const 4))
      (else (return_call $four (i32.sub (local.get 0) (i32.const 1))))))
  (func (export "_start") (call $exit (call $four (i32.const 100000)))))
WAT
  cat > "$d/atomics.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") 1 1 shared)
  (func (export "_start")
    (i32.atomic.store (i32.const 0) (i32.const 5))
    (call $exit (i32.atomic.load (i32.const 0)))))
WAT
  cat > "$d/spawn.wat" <<'WAT'
(module
  (import "env" "memory" (memory 1 1 shared))
  (export "memory" (memory 0))
  (import "wasi" "thread-spawn" (func $spawn (param i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (func (export "wasi_thread_start") (param $tid i32) (param $arg i32)
    (i32.atomic.store (i32.const 0) (i32.const 6)))
  (func (export "_start")
    (drop (call $spawn (i32.const 0)))
    (loop $w (br_if $w (i32.eqz (i32.atomic.load (i32.const 0)))))
    (call $exit (i32.atomic.load (i32.const 0)))))
WAT
  cat > "$d/m64.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") i64 1)
  (func (export "_start")
    (i64.store (i64.const 8) (i64.const 11))
    (call $exit (i32.wrap_i64 (i64.load (i64.const 8))))))
WAT
  cat > "$d/exn.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") 1)
  (tag $e (param i32))
  (func (export "_start")
    (call $exit
      (block $h (result i32)
        (try_table (catch $e $h)
          (throw $e (i32.const 7)))
        (i32.const 1)))))
WAT
  cat > "$d/ss.wat" <<'WAT'
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
  (memory (export "memory") 1)
  (type $ft (func (result i32)))
  (type $ct (cont $ft))
  (type $ft2 (func (param i32) (result i32)))
  (type $ct2 (cont $ft2))
  (tag $yield (param i32) (result i32))
  (func $gen (type $ft) (suspend $yield (i32.const 5)))
  (elem declare func $gen)
  (func (export "_start")
    (local $k (ref null $ct2))
    (block $on_yield (result i32 (ref $ct2))
      (resume $ct (on $yield $on_yield) (cont.new $ct (ref.func $gen)))
      (call $exit)
      (unreachable))
    (local.set $k)
    (drop)
    (resume $ct2 (i32.const 37) (local.get $k))
    (call $exit)))
WAT
  # a flag the engine does not know is passed only when it knows it (49 needs
  # `-W shared-memory=y` for a shared memory; 36 folds that into threads)
  local shm=""; "$E" run -W help 2>&1 | grep -q ' shared-memory\[' && shm="-W shared-memory=y"
  echo "probe: $("$E" --version)"
  local ok=1
  row() { # row <label> <module> <want> <flags…>
    local label=$1 mod=$2 want=$3; shift 3
    local out rc; out="$("$E" run "$@" "$d/$mod" 2>&1)"; rc=$?
    if [ "$rc" = "$want" ]; then printf '  %-34s yes\n' "$label"
    else printf '  %-34s no   (%s)\n' "$label" "$(printf '%s' "$out" | grep -v '^$' | head -1 | cut -c1-90)"; return 1; fi
  }
  row "WASI preview1"                  p1.wat      3  || ok=0
  row "tail calls"                     tail.wat    4  -W tail-call=y || ok=0
  row "shared memory + atomics"        atomics.wat 5  -W threads=y $shm || ok=0
  row "wasi-threads spawn"             spawn.wat   6  -W threads=y $shm -S threads=y || ok=0
  row "memory64"                       m64.wat    11  -W memory64=y || true
  row "exceptions (try_table)"         exn.wat     7  -W exceptions=y || true
  row "stack switching (cont/resume)"  ss.wat     37  -W stack-switching=y -W function-references=y -W exceptions=y || true
  rm -rf "$d"
  if [ "$ok" = 1 ]; then echo "  hosts what the wheel emits: yes (the first four rows)"
  else echo "  hosts what the wheel emits: NO — a gate that needs the missing row cannot run here"; return 1; fi
}

case "${1:-}" in
  "")    fetch ;;
  probe) if [ -n "${2:-}" ]; then probe "$2"; else fetch >/dev/null; probe "$bin"; fi ;;
  *)     echo "usage: bash tools/wasmtime-get.sh [probe [<engine>]]" >&2; exit 2 ;;
esac
