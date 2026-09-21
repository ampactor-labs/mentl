#!/usr/bin/env bash
# mentl-first.sh — the PreToolUse hook on Bash: the medium's projection FIRST.
#
# Morgan, 2026-09-21: "just stop using grep and sed… make a hook that
# intercepts anytime you try to use one of those kinds of tools and literally
# just points you at 'use Mentl and read all of what it returns'". Measured
# the same day, in one session: dozens of grep/sed/awk calls over `.mn`
# source where `mentl <file> refs of NAME`, `mentl <file> doc`,
# `mentl <file:line>` and `mentl <file> census <shape>` already answered — and
# every `mentl … | grep -v … | tail` hid the very gate (W_CommentRefUnresolved)
# that was refusing the author's own comments. CLAUDE.md ⟳ says "a hand tool
# is a CONFESSION that a projection is missing"; this hook makes the
# confession a refusal instead of a habit.
#
# Two refusals, exit 2 (blocks the call; the message reaches the model):
#   1. grep / egrep / fgrep / rg / sed / awk / gawk anywhere in the command.
#   2. a `mentl` invocation piped into a filter (grep, head, tail, wc, cut,
#      sort, uniq, sed, awk, less, more): the medium's answer is read WHOLE.
# There is no escape hatch on purpose. A question the medium cannot answer
# is the facet to grow in the same landing (CLAUDE.md ⟳, the address map).
#
# Wired by .claude/settings.json (PreToolUse, matcher Bash). Reads the tool
# input as JSON on stdin, as every Claude Code hook does.
set -u
# The payload arrives on THIS script's stdin; python's stdin is the heredoc,
# so the JSON rides in as an argument (the first draft read the heredoc as
# the payload and admitted everything — a hook that cannot fail is not a gate).
payload="$(cat)"
python3 - "$payload" <<'PY'
import json, re, sys
try:
    payload = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
cmd = (payload.get("tool_input") or {}).get("command", "") or ""

tools = re.compile(r"(^|[\s;|&(`])(grep|egrep|fgrep|rg|sed|awk|gawk)(\s|$)")
# An INVOCATION of the verb — `mentl` at a command position, followed by its
# arguments — piped into a filter. Not the word inside a path: the project
# lives at /home/user/mentl, so the first form (`\bmentl\b`) refused
# `cd /home/user/mentl && … | sort` and `cat …/mentl/… | tail`, commands
# that never ran the medium at all (measured 2026-09-21, twice in one hour).
filtered = re.compile(r"(^|[\s;|&(`])mentl\s[^|\n]*\|\s*(grep|egrep|fgrep|rg|head|tail|wc|cut|sort|uniq|sed|awk|less|more)\b")

if filtered.search(cmd):
    sys.stderr.write(
        "mentl-first: a mentl answer is read WHOLE — never piped into a filter.\n"
        "  Read all of what it returns; what the filter drops is where the gate\n"
        "  refuses your own work (measured 2026-09-21: `| grep -v` hid four\n"
        "  W_CommentRefUnresolved on the author's own comments).\n"
    )
    sys.exit(2)
m = tools.search(cmd)
if m:
    sys.stderr.write(
        f"mentl-first: `{m.group(2)}` is a hand tool over the source; use the medium.\n"
        "  mentl <file> refs of NAME   — every reference, module-qualified\n"
        "  mentl <file> doc            — the decl roster with types and ledes\n"
        "  mentl <file>:<line>[:<col>] — the node at an address, eight aspects\n"
        "  mentl <file> why NAME       — the Reason chain to root\n"
        "  mentl <file> census <shape> — every site of a shape\n"
        "  mentl <file> decls | unreferenced | unreachable | performs | audit\n"
        "  A question none of these answers is the facet to grow, in this\n"
        "  landing — never a grep absorbed into habit (CLAUDE.md ⟳).\n"
    )
    sys.exit(2)
sys.exit(0)
PY
