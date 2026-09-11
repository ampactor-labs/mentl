# tools/wt-env.sh — THE ONE HOME for the wasm toolchain invocation.
#
# Carried-Truth at the tooling layer: the wasmtime run-flags and the wat2wasm
# assemble-flags are a FACT with exactly one home. Every script sources this;
# nobody hand-types `-W threads=y …` again (the flag-split footgun that cost a
# session). The instant `mentl run` / `mentl asm` exist as real subcommands,
# this file dissolves — like every bootstrap-era scaffold.
#
#   Usage (source, never execute):   source "$(dirname "$0")/wt-env.sh"
#   Then:  wt_run <wasm> [args…]              # run with the canonical flags
#          wt_asm <in.wat> <out.wasm>         # assemble with the canonical flags
#          wt_validate <wasm>                 # validate with the canonical flags
#          wt_func <wasm> <fn-name>           # WABT disasm of ONE function
#          wt_offsets <wat> <fn> <local>      # field-load offsets for a local
#          wt_wheel <src|lib> [src|lib] > f   # canonical wheel input (find-order)
#
# The four constants — WT, WT_RUN_FLAGS, W2W, WT_WABT — are the single source of
# truth. Override the binary via WASMTIME_BIN. Nothing here re-derives; every
# helper is a projection of the four constants.

# The threads/shared-memory/tail-call quartet is load-bearing: the wheel's
# modules use wasi-threads shared memory (the wasi_thread_spawn substrate) and
# return_call_indirect (opcode 0x13). Drop any one flag → the module refuses to
# instantiate. This quartet is the invariant, proven across the whole toolchain.
# The SPELLING is version-dependent: wasmtime 36 LTS folds shared-memory into
# -W threads=y and rejects the separate flag; 43 requires it explicitly. Probe
# once at source time so both run (validated 2026-07-23: wheel self-compile
# byte-identical and battery 113/113 through BOTH binaries —
# Hβ.ops.wasmtime-runner-migration step 1).
# THE EMBEDDED RUNNER IS THE DEFAULT ENGINE, because the CLI is a DEAD END:
# measured 2026-09-06, the same spawning module answers exit 60 through
# wasmtime 36's CLI and `Error: the -Sthreads flag is no longer supported`
# through 47's. The CLI cannot execute Mentl's own output past 36, so the LTS
# pin was never a stability preference — it was a CEILING, and every release
# above it was unreachable while the CLI ran the gates. tools/runner registers
# wasi.thread-spawn itself and creates the shared memory, so it needs no flag
# to do what the CLI removed.
#
# The fallback is NAMED, never silent (a silent fallback is the betrayal, at
# the exact moment it is cheapest): with no runner built, this says so on
# stderr and uses the CLI, where the flag probe below still has to run.
#
# NOT YET ON THE RUNNER, and the split is deliberate: `mentl space` and
# `mentl session` LISTEN, and wasmtime-wasi 47's p1 adapter does not implement
# sockets at all (sock_accept returns Notsock), while 47's CLI refuses
# --tcplisten outright. Those two verbs stay on 36 until the runner owns the
# p1 socket surface the way it already owns thread-spawn
# (`Hβ.ops.runner-owns-the-p1-socket`). No gate listens, so the board is
# unaffected — which is why this half could move first.
#
# One capability the runner drops: `-D coredump=` is parsed and ignored, so a
# trapped m3 leg writes no coredump for the autopsy. Named here rather than
# discovered at the next trap; it rides the same peer.
# WT_CLI / WT_CLI_FLAGS are ALWAYS the wasmtime CLI, computed whether or not
# the runner is in use, because two verbs still need it: `space` and `session`
# LISTEN, and the runner consumes `-S tcplisten=` and DROPS it. Pointing them
# at $WT would have started a server that silently never listens — the exact
# silent-fallback shape this file's own fallback notice exists to avoid, and a
# regression the engine swap would otherwise have introduced in the same edit
# that fixed a different one. The listening verbs name WT_CLI explicitly, so
# the split is visible at the call site rather than implied here.
_wt_cli="${WASMTIME_BIN:-$HOME/.wasmtime/bin/wasmtime}"
# The probe reads the CLI's OWN WORDS, never a pipeline's exit status. This
# file is SOURCED, so it inherits the caller's shell options, and the former
# `… 2>&1 | grep -q` form asked a question whose answer changed with them:
# wasmtime exits nonzero on the probe either way, so under `set -o pipefail`
# (which tools/verify.sh sets, and an interactive source does not) the pipeline
# reported failure though grep had MATCHED — the probe then added the very flag
# 36 LTS rejects and every run under that gate trapped with "unknown -W option:
# shared-memory". It was invisible on 43, which wants the flag regardless, so
# the wrong branch and the right behaviour coincided there: the defect could
# only fire on the version this repo pins. Captured string + `case` has no exit
# status to inherit, so the verdict is the same from every caller.
WT_SHM_PROBE="$("$_wt_cli" run -W shared-memory=y /nonexistent.wasm 2>&1 || true)"
case "$WT_SHM_PROBE" in
  *"unknown -W"*) WT_CLI_FLAGS=(-W threads=y -W tail-call=y -S threads=y) ;;
  *)              WT_CLI_FLAGS=(-W threads=y -W shared-memory=y -W tail-call=y -S threads=y) ;;
esac
WT_CLI="$_wt_cli"

_wt_runner="${MENTL_RUNNER:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/runner/target/release/mentl-runner}"
if [ -z "${WASMTIME_BIN:-}" ] && [ -x "$_wt_runner" ]; then
  WT="$_wt_runner"
  WT_RUN_FLAGS=(-W threads=y -W tail-call=y)
  WT_ENGINE="runner"
else
  [ -z "${WASMTIME_BIN:-}" ] && [ -n "${MENTL_RUNNER_NOTICE:-1}" ] && \
    echo "wt-env: no runner at $_wt_runner — falling back to the wasmtime CLI (capped at 36; build with: cargo build --release --manifest-path tools/runner/Cargo.toml)" >&2
  WT_ENGINE="cli"
WT="$_wt_cli"
  WT_RUN_FLAGS=("${WT_CLI_FLAGS[@]}")
fi
# MENTL_WT_EXTRA — extra runner flags, word-split, appended to every wt_run and
# every shim invocation. It exists for ONE thing the canonical flags cannot
# express and the shim therefore could not reach: attaching a profiler.
# PLAN §8 names host `perf` with --profile=perfmap as THE instrument for the
# self-compile, and getting it required hand-assembling the wasmtime command
# the shim already builds — the "ceremony one layer down" CLAUDE.md ⟳ calls a
# confession. Now:
#   MENTL_WT_EXTRA=--profile=perfmap perf record -g -- mentl check <file>
# Empty by default, so every gate and every march runs byte-identical flags.
# shellcheck disable=SC2206 — the split is the point; this file is sourced by bash.
if [ -n "${MENTL_WT_EXTRA:-}" ]; then
  WT_RUN_FLAGS+=($MENTL_WT_EXTRA)
fi
WABT_FEATURE_FLAGS=(--enable-threads --enable-tail-call)
W2W=(wat2wasm --debug-names "${WABT_FEATURE_FLAGS[@]}")

# MENTL_RT_LIBS — the runtime-link set every battery fixture concatenates.
# One home: verify.sh and march-gate.sh both linked the same four modules
# from their own definitions, the parallel-arrays drift at gate scale.
MENTL_RT_LIBS=(lib/memory.mn lib/strings.mn lib/lists.mn lib/prelude.mn)

# wt_run <wasm> [args…] — run a wasm module under the canonical flags. Stdin/
# stdout/stderr pass through untouched, so callers pipe the wheel in and capture
# the WAT out exactly as before.
wt_run() { "$WT" run "${WT_RUN_FLAGS[@]}" "$@"; }

# wt_asm <in.wat> <out.wasm> — assemble WAT→WASM under the canonical flags.
# Returns wat2wasm's own exit code; caller redirects stderr as it likes.
wt_asm() { "${W2W[@]}" "$1" -o "$2"; }

# wt_validate <wasm> — validate a WASM module under the same feature set used
# for assembly. Threads/tail-call are substrate facts, not per-script choices.
wt_validate() { wasm-validate "${WABT_FEATURE_FLAGS[@]}" "$1"; }

# ── WABT probes (the trap-pin workhorses; PLAN §8 — never grep the minified
#    emit). All read a *.wasm assembled by wt_asm, so the name section is live
#    (locals render as <__state>, <handle>, <tag>). ─────────────────────────

# wt_func <wasm> <fn-name> — disassemble exactly one function by its name-section
# name. The canonical replacement for hand-rolled `wasm-objdump -d | sed -n`.
wt_func() {
  wasm-objdump -d "$1" 2>/dev/null \
    | awk -v fn="<$2>:" '
        index($0, fn) { p = 1 }
        p { print }
        p && /^[0-9a-f]+ func\[/ && !index($0, fn) && NR > start { }
        p && /^[0-9a-f]+ func\[[0-9]+\] </ { if (seen++) exit } '
}

# wt_offsets <wat> <fn> <local> — the field-load offsets a given local is read
# at inside one function (the record-layout probe). Reads the readable WAT, not
# the binary, so field names/offsets are inline. Answers "what offset did
# `arm.body` resolve to?" without a global grep that matches every `arm`.
wt_offsets() {
  sed -n "/func \$$2 /,/^  (func \$/p" "$1" \
    | grep -oE "\\\$$3\)\(i32.load offset=[0-9]+" | sort | uniq -c
}

# wt_wheel <part…> — emit the canonical wheel input to stdout. Each part is
# `src` or `lib`; order is the argument order. `wt_wheel lib src` is the
# CANONICAL build order — callee-first at module scale: lib declares the
# vocabulary src consumes, so a src->lib reference is BACKWARD and reads the
# final scheme (the src-first blob left every such call on the loose
# pre-registered snapshot: 492 fully-bare published schemes, measured
# 2026-07-23 — the order-conditional class at its true size). Uses `find`,
# NEVER `cat src/*.mn` (PLAN §6 — cat omits backends/). Excludes lib/tutorial.
wt_wheel() {
  local part
  for part in "$@"; do
    case "$part" in
      src) find src -name '*.mn' | sort | xargs cat ;;
      lib) find lib -name '*.mn' -not -path '*/tutorial/*' | sort | xargs cat ;;
      *) echo "wt-env: wt_wheel: unknown part '$part' (want src|lib)" >&2; return 2 ;;
    esac
  done
}

# ── the ONE wheel-compile + the gate stamp — Carried-Truth for the tools ────
# boot(wheel) is DETERMINISTIC (the monotonic bump image: determinism =
# fixpoint; every byte-exact m2 == m3 assert is the empirical proof), so the
# compile is a pure function of (wheel bytes, boot bytes, run flags). It costs
# ~13 minutes, and three gates used to re-derive it independently — verify's
# census, march's m2, march-gate's m2. ONE keyed home now: .build/m2cache.
# Consumers call wt_m2_ensure and READ; nobody re-derives. verify.sh stamps
# its green verdict keyed on wt_state_key, so the pre-commit hook answers
# instantly on an unchanged tree instead of re-paying the full gate it just
# watched pass. Placement into a consumer dir COPIES (never hardlinks — every
# tool overwrites its own output paths, and a hardlink would write back into
# the cache inode). Dissolves with this file at `mentl verify` (the IC cursor
# makes caching the semantics, not a bolt-on).

wt_state_key() {  # the gate-relevant tree state, hashed. Over-inclusion is a
                  # spurious re-run; under-inclusion is the bug — include every
                  # file whose change can change the verdict.
  # EVERY fixture directory a verify leg reads belongs here, and three were
  # missing: tests/syntax (the declared-form battery), tests/rows (the
  # residual mark) and tests/floors (the unprovable-offset contract). Each
  # arrived with its leg and none extended this key, so the stamp answered
  # green for a tree whose battery had grown — measured 2026-08-18 by
  # mutating a syntax fixture and reading the same hash back. The comment
  # above already named it: under-inclusion is the bug.
  { wt_wheel lib src
    cat boot/mentl.wasm tests/micros/*.mn tests/syntax/*.mn tests/rows/*.mn \
        tests/floors/*.mn tools/verify.sh tools/run-micro.sh \
        tools/wt-env.sh tools/verify-baseline.txt 2>/dev/null
    printf '%s' "${WT_RUN_FLAGS[*]}"
  } | sha256sum | cut -d' ' -f1
}

wt_m2_key() {  # what the cached boot(wheel) artifact depends on — nothing more
  { wt_wheel lib src; cat boot/mentl.wasm; printf '%s' "${WT_RUN_FLAGS[*]}"; } \
    | sha256sum | cut -d' ' -f1
}

WT_M2CACHE=".build/m2cache"
wt_m2_ensure() {  # fill $WT_M2CACHE/{wheel.mn,m2.wat,m2.wasm,m2.err} for the
                  # CURRENT tree; instant on a key hit. flock serializes
                  # concurrent gates (the second waits, then reads). Echoes the
                  # cache dir; returns 1 on a trapped/failed compile.
  mkdir -p "$WT_M2CACHE"
  local key; key=$(wt_m2_key)
  if [ "$(cat "$WT_M2CACHE/key" 2>/dev/null)" != "$key" ] || [ ! -s "$WT_M2CACHE/m2.wasm" ]; then
    (
      exec 9>"$WT_M2CACHE/lock"; flock 9
      # re-check under the lock — a concurrent gate may have just filled it
      [ "$(cat "$WT_M2CACHE/key" 2>/dev/null)" = "$key" ] && [ -s "$WT_M2CACHE/m2.wasm" ] && exit 0
      : > "$WT_M2CACHE/key"   # invalidate before rebuilding (empty never matches a sha)
      wt_wheel lib src > "$WT_M2CACHE/wheel.mn"
      timeout 9000 "$WT" run -D coredump="$WT_M2CACHE/m2.coredump" "${WT_RUN_FLAGS[@]}" \
        boot/mentl.wasm < "$WT_M2CACHE/wheel.mn" > "$WT_M2CACHE/m2.wat" 2> "$WT_M2CACHE/m2.err" || exit 1
      wt_asm "$WT_M2CACHE/m2.wat" "$WT_M2CACHE/m2.wasm" 2> "$WT_M2CACHE/m2w.err" || exit 1
      printf '%s' "$key" > "$WT_M2CACHE/key"
    ) || return 1
  fi
  echo "$WT_M2CACHE"
}

wt_m2_place() {  # copy the cached m2 trio into a consumer's dir so its
                 # downstream paths (diffs, pin_trap, err censuses) read as before
  local C="$1" D="$2" f
  for f in m2.wat m2.wasm m2.err; do cp -f "$C/$f" "$D/$f"; done
}
