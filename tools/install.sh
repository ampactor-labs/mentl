#!/usr/bin/env bash
# tools/install.sh — the `mentl` command, anywhere, always current.
#
# Writes ~/.local/bin/mentl: a POINTER to this repo's live pinned boot
# (boot/mentl.wasm — the fixpoint compiler, provenance in
# boot/PROVENANCE.md). Never a copy, never a version: the pin IS the
# release, so every `tools/march.sh` re-pin is instantly the global CLI
# with zero sync. The shim preopens the caller's cwd (so `mentl check foo`
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
    "\$MENTL_HOME/boot/mentl.wasm" "\$@"
}
if [ "\${1:-}" = "run" ] && [ -n "\${2:-}" ]; then
  # run = compile -> assemble -> execute. The execute half is the process
  # boundary the wasm cannot cross (WASI has no exec — the wheel's run
  # verb names this exact seam); the shim owns it. The compile half keeps
  # the executable gate's refusal law: a hole or a broken program exits
  # nonzero with zero WAT, and the shim stops there.
  src="\$2"; shift 2
  tmp="\$(mktemp -d)"
  out_wat="\$tmp/out.wat"; out_wasm="\$tmp/out.wasm"
  mentl_wasm compile "\$src" > "\$out_wat"; rc=\$?
  if [ "\$rc" -ne 0 ] || [ ! -s "\$out_wat" ]; then rm -rf "\$tmp"; exit "\$rc"; fi
  "\${W2W[@]}" "\$out_wat" -o "\$out_wasm" || { rm -rf "\$tmp"; exit 1; }
  "\$WT" run "\${WT_RUN_FLAGS[@]}" --dir "\$PWD" --dir /tmp "\$out_wasm" "\$@"
  rc=\$?
  rm -rf "\$tmp"
  exit "\$rc"
fi
if [ "\${1:-}" = "session" ]; then
  # session = the resident graph. The listener is a HOST resource (the
  # space seam's twin); the wheel derives once and answers read verbs
  # over one-line connections speaking the CLI's own grammar. Port
  # override: MENTL_SESSION_PORT.
  # WT_CLI, not WT: this verb LISTENS, and the embedded runner consumes
  # -S tcplisten= and drops it — a server that silently never listens. The
  # runner cannot own this yet because wasmtime-wasi's p1 adapter implements
  # no sockets at all (Hβ.ops.runner-owns-the-p1-socket); until it does, the
  # listening verbs are the one place still pinned to the CLI, and they say so.
  exec "\$WT_CLI" run "\${WT_CLI_FLAGS[@]}" \\
    --dir "\$PWD" --dir /tmp --dir "\$MENTL_HOME::/mentl-home" \\
    -S "tcplisten=127.0.0.1:\${MENTL_SESSION_PORT:-7377}" \\
    "\$MENTL_HOME/boot/mentl.wasm" session
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
if [ -n "\${1:-}" ]; then
  if mentl_session_try "\$@"; then exit 0; fi
fi
if [ "\${1:-}" = "space" ]; then
  # space = the ide, served by the wheel. A listener is a HOST resource
  # (WASI p1 has no bind/listen — the wheel's find_listener only reads the
  # preopen table), so the shim owns this seam exactly as it owns run's
  # exec seam. The repo maps at guest "." so the verb serves ide/ from any
  # directory. Port override: MENTL_SPACE_PORT.
  # WT_CLI, not WT — the listening seam, same as the session verb above.
  # (No backticks in this heredoc: it is unquoted, so they would run as
  # command substitution at install time — which is exactly what they did.)
  exec "\$WT_CLI" run "\${WT_CLI_FLAGS[@]}" \\
    --dir "\$MENTL_HOME::." --dir /tmp \\
    -S "tcplisten=127.0.0.1:\${MENTL_SPACE_PORT:-7378}" \\
    "\$MENTL_HOME/boot/mentl.wasm" space
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
