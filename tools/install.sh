#!/usr/bin/env bash
# tools/install.sh — the `mentl` command, anywhere, always current.
#
# Writes ~/.local/bin/mentl: a POINTER to this repo's live pinned boot
# (boot/mentl.wasm — the fixpoint compiler, provenance in
# boot/PROVENANCE.md). Never a copy, never a version: the pin IS the
# release, so every `tools/march.sh` re-pin is instantly the global CLI
# with zero sync. The shim preopens the caller's cwd (so `mentl foo check`
# works beside foo.mn in any directory) and maps the repo to the
# well-known guest path /mentl-home (so user projects' vocabulary imports —
# and their transitive substrate imports — resolve with zero
# configuration: an address, not an env var; the resolver's home chain,
# src/driver.mn driver_module_path).
#
# Override the bin dir with MENTL_BIN_DIR. Re-running is idempotent.
set -euo pipefail

MENTL_HOME="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="${MENTL_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/mentl" <<SHIM
#!/usr/bin/env bash
# mentl — a pointer to the live pinned boot (written by tools/install.sh;
# provenance: \$MENTL_HOME/boot/PROVENANCE.md). Re-pinning the boot updates
# this command with zero action — the shim never copies.
MENTL_HOME="$MENTL_HOME"
source "\$MENTL_HOME/tools/wt-env.sh"
# A path argument OUTSIDE the standing mounts (cwd, /tmp, the repo at
# /mentl-home) has no guest route — the read fails and, before the
# driver's refusal landed, every verb answered EMPTY at exit 0. The shim
# owns the mount seam, so it derives one more preopen from the first
# path-shaped argument (address forms path:L and path:L:C included).
mentl_arg_dir() {
  local p="\$1"
  [ -e "\$p" ] || p="\${p%:*}"
  [ -e "\$p" ] || p="\${p%:*}"
  [ -e "\$p" ] || return 1
  ( cd "\$(dirname "\$p")" 2>/dev/null && pwd )
}
# MENTL_COMPILER — WHICH compiler answers. \`boot\` (the default) is the pinned
# fixpoint; \`fresh\` is the compiler THIS checkout's source builds (the keyed
# .build/m2cache, rebuilt under the heavy-run lease when the source has moved,
# so an answer is never read from a compiler the tree has left behind); any
# other value is a path to a module. A landing in flight is questioned through
# its own compiler this way, not through a hand-assembled runner command — the
# "ceremony one layer down" CLAUDE.md names. A non-boot compiler bypasses the
# resident session, which serves the pin.
#
# \`march\` is the candidate the last march produced (.build/march/m3.wasm) —
# the new wheel compiled by ITSELF, the one to ask whether its own tooling
# behaves before a repin. \`fresh\` cannot answer that: m2's code was compiled
# by the OLD boot, so a fix to the compiler's judgment is absent from m2's own
# fmt/check (measured 2026-09-23: three frontier REDs that were m2's, not the
# wheel's). The march records the source key it compiled; a stale m3 refuses.
#
# MENTL_WASM is not an input, and it is REFUSED rather than ignored: set
# in its place, it once sent four runs to the old boot while they were read
# as the candidate's, and a phantom miscompile was chased through emit-diff.
if [ -n "\${MENTL_WASM:-}" ]; then
  echo "mentl: MENTL_WASM is not an input — MENTL_COMPILER=<boot|fresh|march|path> selects the compiler" >&2
  exit 2
fi
mentl_compiler() {
  case "\${MENTL_COMPILER:-boot}" in
    boot) printf '%s' "\$MENTL_HOME/boot/mentl.wasm" ;;
    march)
      if [ ! -s .build/march/m3.wasm ] || [ "\$(cat .build/march/key 2>/dev/null)" != "\$(wt_m2_key)" ]; then
        echo "mentl: MENTL_COMPILER=march — no m3 for this source (the last march compiled other bytes); run bash tools/march.sh" >&2
        return 2
      fi
      printf '%s' "\$PWD/.build/march/m3.wasm" ;;
    fresh)
      if [ ! -f boot/mentl.wasm ] || [ ! -d src ]; then
        echo "mentl: MENTL_COMPILER=fresh answers from a checkout root, and \$PWD is not one" >&2
        return 2
      fi
      if [ "\$(cat .build/m2cache/key 2>/dev/null)" != "\$(wt_m2_key)" ] || [ ! -s .build/m2cache/m2.wasm ]; then
        bash "\$MENTL_HOME/tools/heavy-lock.sh" acquire >&2 || return 2
        local rc=0
        wt_m2_ensure > /dev/null || rc=\$?
        bash "\$MENTL_HOME/tools/heavy-lock.sh" release >&2
        if [ "\$rc" -ne 0 ]; then
          echo "mentl: the fresh compile failed — read .build/m2cache/m2.err" >&2
          return 2
        fi
      fi
      printf '%s' "\$PWD/.build/m2cache/m2.wasm" ;;
    *)
      if [ ! -f "\$MENTL_COMPILER" ]; then
        echo "mentl: no compiler module at \$MENTL_COMPILER" >&2
        return 2
      fi
      printf '%s' "\$MENTL_COMPILER" ;;
  esac
}
COMPILER="\$(mentl_compiler)" || exit \$?
mentl_wasm() {
  local extra=()
  local a d
  for a in "\$@"; do
    case "\$a" in */*) ;; *) continue ;; esac
    if d="\$(mentl_arg_dir "\$a")"; then
      [ "\$d" != "\$PWD" ] && [ "\$d" != "/tmp" ] && extra=(--dir "\$d")
      break
    fi
  done
  "\$WT" run "\${WT_RUN_FLAGS[@]}" \\
    --dir "\$PWD" --dir /tmp --dir "\$MENTL_HOME::/mentl-home" "\${extra[@]}" \\
    "\$COMPILER" "\$@"
}
# `mentl run` is the WHEEL's verb: compile, stream the module to the runner
# through the Process seam, execute it there, answer the program's own exit
# (src/main.mn run_run ~> process_host; tools/runner mentl_host.exec). The
# shim owned this seam as compile → wat2wasm → wasmtime with a content-keyed
# run cache; it falls through to the wheel like every other verb now, and the
# warm image restore is the compile's own cache.
if [ "\${1:-}" = "session" ]; then
  # session = the resident graph. The listener is a HOST resource the
  # runner owns (-S tcplisten=, the p1 socket protocol lib/net.mn speaks);
  # the wheel derives once and answers read verbs over one-line
  # connections speaking the CLI's own grammar. Port override:
  # MENTL_SESSION_PORT.
  exec "\$WT" run "\${WT_RUN_FLAGS[@]}" \\
    --dir "\$PWD" --dir /tmp --dir "\$MENTL_HOME::/mentl-home" \\
    -S "tcplisten=127.0.0.1:\${MENTL_SESSION_PORT:-7377}" \\
    "\$COMPILER" session
fi
# Resident-first: when a session lives, EVERY verb is offered to it —
# a tab-joined argv line over /dev/tcp, the answer streamed back. The
# shim is a TRANSPORT, never a policy: WHICH verbs the session serves
# is the medium's own dispatch (session_answer, mcp.mn — the one
# home); anything it declines answers the MISS sentinel, and MISS or
# a dead port falls through to the cold exec below. Resident and cold
# run the same projections, so the answers agree byte-for-byte.
mentl_session_try() {
  local port="\${MENTL_SESSION_PORT:-7377}" out
  { exec 3<>"/dev/tcp/127.0.0.1/\$port"; } 2>/dev/null || return 1
  printf '%s\t' "\$@" >&3
  printf '\n' >&3
  out="\$(cat <&3)"
  exec 3<&- 3>&-
  case "\$out" in MENTL-SESSION-MISS*) return 1 ;; esac
  printf '%s' "\$out"
  return 0
}
if [ -n "\${1:-}" ] && [ "\${MENTL_COMPILER:-boot}" = "boot" ]; then
  if mentl_session_try "\$@"; then exit 0; fi
fi
if [ "\${1:-}" = "space" ]; then
  # space = the ide, served by the wheel. A listener is a HOST resource
  # (WASI p1 has no bind/listen — the wheel's find_listener only reads the
  # preopen table), so the runner owns this seam exactly as it owns the
  # exec seam. The repo maps at guest "." so the verb serves ide/ from any
  # directory. Port override: MENTL_SPACE_PORT.
  # (No backticks in this heredoc: it is unquoted, so they would run as
  # command substitution at install time — which is exactly what they did.)
  exec "\$WT" run "\${WT_RUN_FLAGS[@]}" \\
    --dir "\$MENTL_HOME::." --dir /tmp \\
    -S "tcplisten=127.0.0.1:\${MENTL_SPACE_PORT:-7378}" \\
    "\$COMPILER" space
fi
exec_rc=0
mentl_wasm "\$@" || exec_rc=\$?
exit "\$exec_rc"
SHIM
chmod +x "$BIN_DIR/mentl"

echo "installed: $BIN_DIR/mentl -> $MENTL_HOME/boot/mentl.wasm (live pointer)"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "note: $BIN_DIR is not on your PATH — add it to use mentl from anywhere" ;;
esac
