#!/usr/bin/env bash
# The drift audit at the edit, not only at the commit: a PostToolUse hook
# that runs tools/drift-audit.sh on the .mn file an Edit or Write just
# changed. Exit 2 puts the named drift mode in front of the editor while the
# edit is still the one being made; .githooks/pre-commit refuses the same
# patterns again at the commit boundary.
set -uo pipefail
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
file=$(python3 -c 'import json,sys
try:
    print((json.load(sys.stdin).get("tool_input") or {}).get("file_path",""))
except ValueError:
    print("")')
case "$file" in
  *.mn) ;;
  *) exit 0 ;;
esac
[[ -f "$file" ]] || exit 0
out=$(bash "$root/tools/drift-audit.sh" "$file" 2>&1)
rc=$?
if [[ $rc -eq 1 ]]; then
  printf '%s\n' "$out" >&2
  exit 2
fi
exit 0
