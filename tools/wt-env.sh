# tools/wt-env.sh — THE ONE HOME for the wasm toolchain invocation.
#
# Carried-Truth at the tooling layer: the engine's run-flags and the wat2wasm
# assemble-flags are a FACT with exactly one home. Every script sources this;
# nobody hand-types `-W threads=y …` again (the flag-split footgun that cost a
# session). The file dissolves with the native backend (PLAN §11, Phase 10),
# where Mentl emits an executable that hosts itself and there is no engine —
# like every bootstrap-era scaffold.
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
# truth. Point WT at another engine via MENTL_WASMTIME. Nothing here re-derives;
# every helper is a projection of the four constants.

# THE ENGINE IS THE STOCK WASMTIME BINARY, and nothing of Mentl is in it
# (2026-10-05, L-H — Morgan: no Rust in the codebase, "at all!"). The boot
# imports WASI preview1 and nothing else and defines its own memory, so any
# preview1 engine hosts it; a program that spawns also asks for wasi-threads
# (the `wasi.thread-spawn` import beside a shared `env.memory`), which is
# where the PIN comes from: wasmtime 36 serves it through `-S threads=y` and
# 47 dropped the flag ("the -Sthreads flag is no longer supported", measured
# 2026-09-06), so 36.0.2 is pinned by version and digest in
# tools/wasmtime-get.sh and resolved here MENTL_WASMTIME → .build/wasmtime →
# PATH. A missing engine REFUSES, loudly, with the fetch command — never a
# silent downgrade. The flags are UNIFORM: `-S threads=y` runs a module that
# defines its memory exactly as one that imports it (measured on this
# landing's m2: the wheel compiled through the candidate byte-identical to
# the Rust runner it replaced, 549,192 lines, at 37.9 s / 492 MB), so no
# import scan chooses flags per module. The threads/tail-call pair is
# load-bearing — the wheel's modules use shared memory (atomics for the
# task join) and return_call_indirect (opcode 0x13); drop either and the
# module refuses to instantiate. `-C cache=y` is the engine's compilation
# cache, on by default in the CLI and stated here because it is the fact
# that makes the loop felt: the JIT of the 3 MB boot is paid once per pinned
# binary, not once per process — a `mentl help` is 0.06 s against the
# runner's 1.4–1.8 s, a `check` of the first lesson 0.35 s against ~1.9 s
# (measured 2026-10-05), and every gate that spawns hundreds of processes
# loses that floor.
#
# The Rust runner this replaced (2026-09-17 → 2026-10-05, tools/runner — an
# 800-line wasmtime embedding) existed for two seams the wheel performed and
# no stock engine defined: the exec seam (`mentl_host.wat_write`/`.exec`) and
# the p1 socket seam (`-S tcplisten=`). Both left the wheel: a compiled
# module is run by the mentl command (tools/install.sh) and by the battery's
# host loop below, and the session serves on stdio. RESIDUE.md carries the
# record under `Hβ.ops.runner-is-the-process-handler`.
_wt_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_wt_engine="${MENTL_WASMTIME:-}"
if [ -z "$_wt_engine" ]; then
  for _wt_cand in "$_wt_root"/.build/wasmtime/wasmtime-v36.0.2-*/wasmtime; do
    [ -x "$_wt_cand" ] && _wt_engine="$_wt_cand" && break
  done
fi
if [ -z "$_wt_engine" ] && command -v wasmtime >/dev/null 2>&1; then
  _wt_engine="$(command -v wasmtime)"
fi
if [ -z "$_wt_engine" ] || [ ! -x "$_wt_engine" ]; then
  echo "wt-env: no engine — bash tools/wasmtime-get.sh fetches the pinned wasmtime into .build/wasmtime (or set MENTL_WASMTIME, or put wasmtime 36 on PATH)" >&2
  return 2 2>/dev/null || exit 2
fi
WT="$_wt_engine"
WT_RUN_FLAGS=(-C cache=y -W threads=y -W tail-call=y -S threads=y)
# MENTL_WT_EXTRA — extra engine flags, word-split, appended to every wt_run and
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

# wt_battery_host — the host's half of the battery. `mentl test` judges every
# fixture in one process and, for a run contract, hands the module over
# instead of running it: a RUN line names the fixture, the .wat the compiler
# wrote under .build/battery, the exit the contract wants and the error
# count it banked (the exec seam left the wheel 2026-10-05 — a compiled
# module is run by the host, in the battery exactly as at `mentl run`). This
# filter assembles and runs each one and writes PASS or FAIL(run) in the RUN
# line's place, so the verdict stream reads as it always did; every other
# line passes through. One process per run fixture again — the honest cost
# of a host with no code of ours in it, paid until `mentl asm` + native —
# measured at ~340 ms a fixture (wat2wasm + the engine's compile), so the
# runs go nproc-wide: each verdict is one short line appended atomically, and
# the verdicts come out sorted by fixture, so the stream is deterministic.
wt_battery_run_one() {  # wt_battery_run_one <stem> <wat> <want> <nerr> — one RUN line's verdict
  local stem="$1" path="$2" want="$3" nerr="$4" base exit
  base="${path%.wat}"
  # A program's exit is what the WASI host reports, and the stock engine
  # reports [0..126) — `proc_exit(200)` is "exit with invalid exit status
  # outside of [0..126)" at exit 1, which reads as a trap. A want the host
  # cannot report is a contract that cannot be judged, refused by name here
  # (measured 2026-10-05: one micro answered 200 through the Rust runner,
  # which passed any status through, and went red the day the stock engine
  # became the host). 134 is the trap's own exit and stays observable.
  if [ "$want" -ge 126 ] && [ "$want" -ne 134 ]; then
    echo "FAIL(contract) $stem: wants exit $want, which the WASI host cannot report (a program's exit is [0..126); a trap is 134) — answer below 126"
    return 0
  fi
  if ! wt_asm "$path" "$base.wasm" 2> "$base.asm.err"; then
    echo "FAIL(asm) $stem: the module did not assemble (see $base.asm.err)"
    return 0
  fi
  timeout 300 "$WT" run "${WT_RUN_FLAGS[@]}" --dir . "$base.wasm" < /dev/null > "$base.out" 2> "$base.run.err"
  exit=$?
  if [ "$exit" -eq "$want" ]; then
    echo "PASS $stem: exit=$exit (expected $want) diags=$nerr"
  else
    echo "FAIL(run) $stem: exit=$exit expected=$want diags=$nerr"
  fi
}
wt_battery_host() {
  local line stem path want nerr runs verdicts n max
  runs=$(mktemp) && verdicts=$(mktemp)
  while IFS= read -r line; do
    case "$line" in
      "RUN "*) printf '%s\n' "${line#RUN }" >> "$runs" ;;
      *) printf '%s\n' "$line" ;;
    esac
  done
  n=0; max=$(nproc 2>/dev/null || echo 2)
  while read -r stem path want nerr; do
    wt_battery_run_one "$stem" "$path" "$want" "$nerr" >> "$verdicts" &
    n=$((n + 1))
    if [ "$n" -ge "$max" ]; then wait -n; n=$((n - 1)); fi
  done < "$runs"
  wait
  sort "$verdicts"
  rm -f "$runs" "$verdicts"
}

# wt_battery <compiler.wasm> <fixture-dir> [label] — the fixture battery,
# judged BY THE MEDIUM: `mentl test <dir>` compiles every fixture in one
# process, judges each contract, and prints one verdict line per fixture
# (PASS / REFUSE / FAIL… / NOEXPECT), with a run contract's module handed to
# the host through a RUN line (wt_battery_host above). This helper reads the
# verdict and holds the two halves of the contract a crashed verb cannot
# print: the exit is 0 AND every fixture the directory holds was judged
# (`mentl test` once died at fixture 118 of 149 and a gate that counted
# FAIL lines said green). Dissolves with this file at `mentl verify`.
#
# A battery's verdict is a function of the compiler BYTES, not of which name
# the compiler goes by, so its memo key hashes the artifact and never the
# words "boot" or "m2". After a clean repin the new boot IS the m2 the
# contract battery already judged, and the post-repin run answers from that
# (the gate memo at the end of this file).
wt_battery() {
  local compiler="$1" dir="$2" label="${3:-$2}" out rc want seen bad key leg
  want=$(ls "$dir"/*.mn 2>/dev/null | wc -l)
  leg="battery-${dir//\//_}"
  key=$(wt_memo_key_run "$compiler" "$dir" lib)
  if wt_memo_hit "$leg" "$key" >/dev/null; then
    echo "✓ battery $label: $want/$want fixture contracts hold (memo — these compiler bytes already judged these fixtures)"
    return 0
  fi
  out=$(wt_run --dir . "$compiler" test "$dir" 2>/dev/null); rc=$?
  out=$(printf '%s\n' "$out" | wt_battery_host)
  seen=$(printf '%s\n' "$out" | grep -cE '^(PASS|REFUSE|FAIL[A-Za-z()]*|NOEXPECT) ' || true)
  bad=$(printf '%s\n' "$out" | grep -cE '^(FAIL[A-Za-z()]*|NOEXPECT) ' || true)
  if [ "$rc" -eq 0 ] && [ "$bad" -eq 0 ] && [ "$seen" -eq "$want" ]; then
    echo "✓ battery $label: $seen/$want fixture contracts hold (compiled, run and judged by the medium)"
    wt_memo_put "$leg" "$key" "green $seen/$want"
    return 0
  fi
  echo "✗ battery $label: exit=$rc, $bad broken contract(s), $seen/$want fixtures judged"
  printf '%s\n' "$out" | grep -E '^(FAIL[A-Za-z()]*|NOEXPECT) ' | head -12
  [ "$rc" -ne 0 ] && echo "  the verb itself failed — rerun it without 2>/dev/null and read the trap."
  [ "$seen" -lt "$want" ] && echo "  it stopped early: everything after the last judged fixture went unchecked."
  return 1
}

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
  # AND THE SCRIPTS ENTER WITHOUT THEIR PROSE (2026-09-15). "Over-inclusion is
  # a spurious re-run" was written by someone not paying for it: these four
  # scripts are hashed WHOLE, so adding a COMMENT to verify.sh or a note to
  # verify-baseline.txt is indistinguishable from moving a threshold, and it
  # discards a twelve-minute measurement of the compiler's behaviour. It did
  # exactly that four times in one landing, which is the cadence law broken by
  # the gate rather than by the hand. A `#` line cannot change what bash
  # executes and a comment in the baseline cannot change a ceiling, so they are
  # stripped before hashing — the key reads the CONTRACT (`name: value` lines,
  # executable lines) and not the prose about it. This is the Carried-Truth Law
  # at the gate layer: a measurement is re-derived only when its inputs changed,
  # and prose is not an input.
  # WHOLE-LINE COMMENTS ONLY, and the first draft of this got it wrong in the
  # direction the comment above forbids. Stripping TRAILING `#` truncates
  # `${#arr[@]}` and `${x#prefix}` mid-expression, so two behaviourally
  # different lines would hash the SAME — under-inclusion, the actual bug,
  # introduced while fixing over-inclusion. A line that is nothing but a
  # comment has no such hazard. Fixtures and the wheel stay WHOLE, because a
  # `.mn` comment IS graph content (SYNTAX §Comments) and can change a verdict.
  { wt_wheel lib src
    cat boot/mentl.wasm tests/micros/*.mn tests/syntax/*.mn tests/rows/*.mn \
        tests/floors/*.mn 2>/dev/null
    sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
        tools/verify.sh tools/run-micro.sh tools/wt-env.sh \
        tools/verify-baseline.txt 2>/dev/null
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

# ── THE UNIFORM GATE MEMO (Hβ.tools.gate-stamp-is-uniform) ─────────────────
# A gate leg's verdict is a pure function of what it reads: the compiler bytes
# it runs, the fixtures it feeds them, the scripts that judge them. A GREEN
# verdict is stored under the hash of exactly those inputs, and a later run
# with the same inputs answers from it instead of re-deriving it. Measured
# 2026-09-25: a repin whose compiler came out byte-identical to the pinned one
# still paid a second full board — the Carried-Truth Law broken at the process
# layer, the one place this project had not applied it. Only green is stored,
# so a red leg always re-runs; FORCE_GATES=1 bypasses every memo.
#
# The key names INPUTS, never outputs, and an input missing from a key is the
# one bug this can have (a stale green) — so each caller lists what its leg
# actually opens, and a directory contributes every file under it. Scripts and
# the baseline enter without whole-line comments, the rule wt_state_key already
# settled: prose cannot change what bash executes or what a ceiling is.
WT_MEMO_DIR=".build/gate/memo"
wt_memo_key() {  # wt_memo_key <input>... — a file, a directory, or =literal
  local x
  for x in "$@"; do
    case "$x" in
      =*) printf 'S %s\n' "${x#=}" ;;
      *.sh|*verify-baseline.txt)
        printf 'F %s\n' "$x"
        [ -f "$x" ] && sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$x" ;;
      *)
        if [ -d "$x" ]; then
          find "$x" -type f ! -path '*/node_modules/*' ! -path '*/target/*' -print0 \
            | LC_ALL=C sort -z | xargs -0 -r sha256sum
        elif [ -f "$x" ]; then
          # CONTENT ONLY for a named file: the same compiler bytes reached as
          # boot/mentl.wasm or as .build/m2cache/m2.wasm are one input.
          sha256sum < "$x"
        else
          printf 'M %s\n' "$x"
        fi ;;
    esac
  done | sha256sum | cut -d' ' -f1
}

wt_memo_hit() {  # wt_memo_hit <leg> <key> — prints the stored verdict when this key last ran green
  [ "${FORCE_GATES:-0}" = 1 ] && return 1
  local f="$WT_MEMO_DIR/$1"
  [ -f "$f" ] && [ "$(head -1 "$f")" = "$2" ] || return 1
  tail -n +2 "$f"
}

wt_memo_put() {  # wt_memo_put <leg> <key> <verdict text>
  mkdir -p "$WT_MEMO_DIR"
  { printf '%s\n' "$2"; printf '%s\n' "$3"; } > "$WT_MEMO_DIR/$1.tmp" && mv "$WT_MEMO_DIR/$1.tmp" "$WT_MEMO_DIR/$1"
}

# The key of a leg that RUNS a compiler: the standing inputs every such leg
# shares (the engine binary, its flags, this file) plus the caller's own — the
# compiler artifact and the fixtures it feeds it.
wt_memo_key_run() { wt_memo_key "$WT" "=${WT_RUN_FLAGS[*]}" tools/wt-env.sh "$@"; }
