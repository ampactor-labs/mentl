#!/usr/bin/env bash
# audit-on-edit.sh — the PostToolUse hook on Edit/Write: the drift audit
# runs on every `.mn` file the model writes, and a drift is a refusal the
# model reads (exit 2 hands stderr back), never a finding left for review.
#
# CLAUDE.md said this hook existed ("tools/drift-audit.sh runs as a
# PostToolUse hook"); measured 2026-09-21, the session's hook configuration
# was `{}` and nothing ran. The claim is wired here so it is true.
set -u
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
payload="$(cat)"
file=$(python3 -c 'import json,sys
try:
    p = json.loads(sys.argv[1])
except Exception:
    print(""); sys.exit(0)
print((p.get("tool_input") or {}).get("file_path", "") or "")' "$payload")
case "$file" in
  *.mn)
    if ! out=$(bash "$root/tools/drift-audit.sh" "$file" 2>&1); then
      printf 'drift-audit refused the edit:\n%s\n' "$out" >&2
      exit 2
    fi
    ;;
esac
exit 0
