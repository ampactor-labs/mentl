#!/usr/bin/env bash
# The consult gate's hook wiring (G2): tools/consult-gate.sh holds the law and
# the ledger; this reads the Claude Code hook payload on stdin and calls it.
#
#   consult.sh record    PostToolUse on Bash — a `mentl` verb ran; mark every
#                        wheel path its command named
#   consult.sh require   PreToolUse on Edit|Write|MultiEdit — refuse an edit
#                        to src/**.mn or lib/**.mn the medium was not asked
#                        about this session (exit 2 is the refusal)
#
# The gate was wired by nothing from its birth until G2: .claude/ was
# gitignored when it was written, so a fresh clone carried the law and no
# caller. The settings file is tracked now, and so is this.
set -uo pipefail
payload=$(cat)
field() { printf '%s' "$payload" | python3 -c "import json,sys; d=json.load(sys.stdin); print((d.get('tool_input') or {}).get('$1',''))" 2>/dev/null; }
gate="${CLAUDE_PROJECT_DIR:-.}/tools/consult-gate.sh"
case "${1:-}" in
  record)
    cmd=$(field command)
    case "$cmd" in
      *mentl\ *) bash "$gate" record "$cmd" ;;
    esac
    exit 0 ;;
  require)
    path=$(field file_path)
    [ -n "$path" ] || exit 0
    # A file that does not exist yet has nothing the medium could be asked.
    [ -e "$path" ] || exit 0
    bash "$gate" require "$path" ;;
  *)
    echo "usage: consult.sh record | require  (hook payload on stdin)" >&2
    exit 64 ;;
esac
