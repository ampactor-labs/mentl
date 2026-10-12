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
# The host is the stock engine tools/wt-env.sh resolves (wasmtime, pinned by
# tools/wasmtime-get.sh) — nothing of Mentl runs in any language but WASM
# and WAT. Three verbs are the mentl command's rather than the wheel's,
# because each needs a host facility a WASI module has none of: `run`
# (a process to execute the module the compiler emits), `space` (a
# listening socket to serve the page), and the resident `session` the
# page's worker holds (a channel the process's own stdin is). Override
# the bin dir with MENTL_BIN_DIR. Re-running is idempotent.
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
    "\${MENTL_BOOT:-\$MENTL_HOME/boot/mentl.wasm}" "\$@"
}
if [ "\${1:-}" = "run" ] && [ -n "\${2:-}" ]; then
  # mentl run <module> [args…] — compile, assemble, execute, since a WASI
  # module has no process to hand its emission to. The compile and the
  # assembly are the wheel's (\`mentl compile\`, its warm image making a second
  # run of an unchanged program cheap, then \`mentl asm\` through wt_asm); the
  # run alone is the engine's, over the caller's cwd, with the program's own
  # args and its own exit. A hole or a refuted claim refuses at the compile
  # and nothing runs (the proof-exactness contract,
  # tools/proof-exactness-gate.sh).
  module="\$2"; shift 2
  stage="\$(mktemp -d "\${TMPDIR:-/tmp}/mentl-run.XXXXXX")"
  trap 'rm -rf "\$stage"' EXIT
  mentl_wasm compile "\$module" > "\$stage/module.wat" || exit \$?
  wt_asm "\$stage/module.wat" "\$stage/module.wasm" || exit \$?
  # Host access follows the medium's read-site roster. Required and optional
  # literal names are passed only when present in the shell or project .env.
  # A dynamic env_opt is explicitly marked as whole-environment access: its
  # name cannot be narrowed before execution, so the host passes its
  # environment plus .env values not already set in the shell. Only required
  # names are checked by the module's pre-main launch gate.
  envs=()
  env_keys=()
  env_add() {
    local add_name="\$1" add_value="\$2" existing
    [ -n "\$add_name" ] || return 0
    for existing in "\${env_keys[@]}"; do
      [ "\$existing" = "\$add_name" ] && return 0
    done
    env_keys+=("\$add_name")
    envs+=(--env "\$add_name=\$add_value")
  }
  dotenv="\$(mentl_arg_dir "\$module.mn" 2>/dev/null || mentl_arg_dir "\$module" 2>/dev/null || pwd)/.env"
  while IFS=\$'\t' read -r name mode; do
    [ -n "\$name" ] || continue
    if [ "\$mode" = "all optional" ]; then
      while IFS= read -r -d '' entry; do
        name="\${entry%%=*}"
        value="\${entry#*=}"
        env_add "\$name" "\$value"
      done < <(env -0)
      if [ -f "\$dotenv" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
          line="\${line#"\${line%%[![:space:]]*}"}"
          [[ -z "\$line" || "\$line" == \\#* || "\$line" != *=* ]] && continue
          name="\${line%%=*}"
          value="\${line#*=}"
          env_add "\$name" "\$value"
        done < "\$dotenv"
      fi
    elif [[ "\$name" =~ ^[A-Za-z_][A-Za-z0-9_]*\$ ]]; then
      if [ -n "\${!name+set}" ]; then
        env_add "\$name" "\${!name}"
      elif [ -f "\$dotenv" ]; then
        while IFS= read -r line || [ -n "\$line" ]; do
          line="\${line#"\${line%%[![:space:]]*}"}"
          [[ -z "\$line" || "\$line" == \\#* || "\$line" != *=* ]] && continue
          key="\${line%%=*}"
          if [ "\$key" = "\$name" ]; then
            env_add "\$name" "\${line#*=}"
            break
          fi
        done < "\$dotenv"
      fi
    fi
  done < <(mentl_wasm query "\$module" env 2>/dev/null | sed -n 's/^ *\\([^ ]*\\) \\[\\([^]]*\\)\\] read at .*/\\1\t\\2/p' | sort -u)
  "\$WT" run "\${WT_RUN_FLAGS[@]}" \${envs[@]+"\${envs[@]}"} --dir "\$PWD" --dir /tmp "\$stage/module.wasm" "\$@"
  exit \$?
fi
if [ "\${1:-}" = "space" ]; then
  # mentl space — the page: stage what ide/space.manifest names and serve the
  # staged directory with the two isolation headers (the browser needs a
  # cross-origin-isolated document for the shared memory the session's
  # channel is). Port override: MENTL_SPACE_PORT. The deployed page is the
  # same artifact, served by GitHub Pages.
  #
  # mentl space <file>:<line>[:<col>] is the WHEEL's: the View the page
  # paints, as JSON (src/space.mn). The bare verb and \`mentl space <dir>\`
  # (the page opened on that folder of modules, staged as a project) are the
  # host's to serve; an address passes through to the module below.
  case "\${2:-}" in
    *:[0-9]*) ;;
    *)
      extra=()
      if [ -n "\${2:-}" ]; then
        [ -d "\$2" ] || { echo "mentl space: \$2 is neither a folder to open nor an address (<file>:<line>[:<col>])" >&2; exit 2; }
        extra=("\$(cd "\$2" && pwd)")
      fi
      bash "\$MENTL_HOME/tools/space-stage.sh" "\$MENTL_HOME/.build/space" \${extra[@]+"\${extra[@]}"} || exit \$?
      echo "mentl space: http://127.0.0.1:\${MENTL_SPACE_PORT:-7397}/" >&2
      exec python3 "\$MENTL_HOME/tools/space-serve.py" "\$MENTL_HOME/.build/space" "\${MENTL_SPACE_PORT:-7397}"
      ;;
  esac
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
