#!/usr/bin/env bash
# audit-on-edit.sh — the PostToolUse hook on Edit/Write: every `.mn` file the
# model writes is audited for drift, then brought to its canonical render.
# A drift, a rewrite and a refusal each come back to the model (exit 2 hands
# stderr back); a canonical edit is silent.
#
# CLAUDE.md said this hook existed ("tools/drift-audit.sh runs as a
# PostToolUse hook"); measured 2026-09-21, the session's hook configuration
# was `{}` and nothing ran. The claim is wired here so it is true.
#
# CANONICAL ON WRITE (2026-09-24). The pre-commit hook used to format staged
# files, which is AFTER the march had pinned a boot from the unformatted
# source — so the committed text and the pinned text differed, and one landing
# paid four marches for it. Source is canonical as it is written now, and
# `mentl verify`'s off-canonical bound refuses a repin over any file that is
# not, whoever edited it.
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
  *.mn) ;;
  *) exit 0 ;;
esac

if ! out=$(bash "$root/tools/drift-audit.sh" "$file" 2>&1); then
  printf 'drift-audit refused the edit:\n%s\n' "$out" >&2
  exit 2
fi

# The file's OWN checkout — a worktree's edit is formatted by that worktree's
# wheel (the shim answers from the checkout it is invoked in). Fixtures under
# tests/ bank exact spans, so only the wheel's sources are canonicalized.
froot=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
rel="${file#"$froot"/}"
case "$rel" in
  src/*|lib/*) ;;
  *) exit 0 ;;
esac
command -v mentl >/dev/null 2>&1 || exit 0
before=$(sha256sum "$file" | cut -d' ' -f1)
fout=$(cd "$froot" && timeout 120 mentl fmt "$rel" 2>&1)
frc=$?
after=$(sha256sum "$file" | cut -d' ' -f1)
if [[ "$frc" -ne 0 ]]; then
  printf 'fmt did not write %s (exit %s) — the file stays as edited:\n%s\n' "$rel" "$frc" "$fout" >&2
  exit 2
fi
if [[ "$before" != "$after" ]]; then
  # THE AUDIT READS WHAT THE FILE KEEPS. fmt reflows prose, so a word the
  # audit passed mid-line can land at the head of a comment line where a
  # drift pattern matches — measured 2026-09-24, when a reflowed `until`
  # passed this hook, reached a repin, and was refused by the pre-commit's
  # audit of the same file, costing a march. Audit again after the render.
  if ! out=$(bash "$root/tools/drift-audit.sh" "$file" 2>&1); then
    printf 'fmt rewrote %s, and its canonical render fails the drift audit:\n%s\n' "$rel" "$out" >&2
    exit 2
  fi
  printf 'fmt rewrote %s to its canonical render — re-read it before the next edit.\n' "$rel" >&2
  exit 2
fi
exit 0
