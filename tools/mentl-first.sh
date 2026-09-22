#!/usr/bin/env bash
# mentl-first.sh — the PreToolUse hook on Bash AND on the Grep tool: the
# medium's projection FIRST.
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
# THE GREP TOOL WENT AROUND IT for a day (measured 2026-09-22: some thirty
# Grep-tool searches over `.mn` source and over captured compiler stderr in
# one dig, while this script refused every `grep` typed into Bash). The rule
# was never "don't type grep" — it is "ask the medium, and read what it says";
# a CLI answer that turns out wrong or thin is a FINDING, the facet to fix in
# the same landing. So the Grep tool meets the same refusal wherever the
# medium is the thing being searched:
#   - Mentl source (`*.mn`), anywhere — the address map answers it;
#   - the medium's own output (`*.wat`, `*.err`, anything under `.build/`) —
#     a verb's answer is read WHOLE, and a fact it buries is a line the VERB
#     should print (the march reports its own cost lines for that reason);
#   - a directory search that would reach either, unless a glob or type
#     confines it to other files.
# Prose and tooling (`*.md`, `*.sh`, `*.py`, transcripts) stay searchable: no
# verb projects them yet, and that absence is its own named peer
# (docs-as-projection, PLAN §11 Phase 10.3), not a license here.
#
# Refusals exit 2 (blocks the call; the message reaches the model):
#   Bash 1. grep / egrep / fgrep / rg / sed / awk / gawk anywhere in the command.
#   Bash 2. a `mentl` invocation piped into a filter (grep, head, tail, wc,
#           cut, sort, uniq, sed, awk, less, more): the answer is read WHOLE.
#   Grep 3. a search whose scope reaches the medium's source or output.
# There is no escape hatch on purpose. A question the medium cannot answer
# is the facet to grow in the same landing (CLAUDE.md ⟳, the address map).
#
# Wired by .claude/settings.json (PreToolUse, matcher Bash|Grep). Reads the
# tool input as JSON on stdin, as every Claude Code hook does.
set -u
# The payload arrives on THIS script's stdin; python's stdin is the heredoc,
# so the JSON rides in as an argument (the first draft read the heredoc as
# the payload and admitted everything — a hook that cannot fail is not a gate).
payload="$(cat)"
python3 - "$payload" <<'PY'
import json, os, re, sys
try:
    payload = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
tool = payload.get("tool_name", "") or ""
ti = payload.get("tool_input") or {}

VERBS = (
    "  mentl <file> refs of NAME   — every reference, module-qualified\n"
    "  mentl <file> doc            — the decl roster with types and ledes\n"
    "  mentl <file>:<line>[:<col>] — the node at an address, eight aspects\n"
    "  mentl <file> why NAME       — the Reason chain to root\n"
    "  mentl <file> row NAME       — a row as the algebra holds it\n"
    "  mentl <file> census <shape> — every site of a shape\n"
    "  mentl <file> decls | unreferenced | unreachable | performs | audit | cost\n"
    "  A question none of these answers is the facet to grow, in this\n"
    "  landing — never a grep absorbed into habit (CLAUDE.md ⟳).\n"
)

if tool == "Grep":
    path = ti.get("path") or payload.get("cwd") or os.getcwd()
    glob = ti.get("glob") or ""
    typ = ti.get("type") or ""

    def medium_file(p):
        return p.endswith((".mn", ".wat", ".err")) or "/.build/" in (p + "/")

    def filter_confines(g, t):
        # A glob confines the search only when its last segment names an
        # extension other than the medium's; a bare `*` / `**` / `dir/*`
        # reaches source like no glob at all.
        if t:
            return True
        if not g:
            return False
        last = g.rsplit("/", 1)[-1]
        if "." not in last:
            return False
        return not any(x in last for x in (".mn", ".wat", ".err"))

    def dir_reaches_medium(d):
        for root, dirs, files in os.walk(d):
            if "/.build" in root + "/" or os.path.basename(root) == ".build":
                return True
            if any(f.endswith((".mn", ".wat", ".err")) for f in files):
                return True
        return False

    refuse = False
    if os.path.isdir(path):
        if not filter_confines(glob, typ) and dir_reaches_medium(path):
            refuse = True
        elif "/.build/" in (path + "/"):
            refuse = True
    elif medium_file(path):
        refuse = True
    if refuse:
        sys.stderr.write(
            "mentl-first: the Grep tool over the medium's source or output is the\n"
            "  same hand tool the Bash refusal names — ask the medium instead:\n"
            + VERBS
        )
        sys.exit(2)
    sys.exit(0)

cmd = ti.get("command", "") or ""

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
        + VERBS
    )
    sys.exit(2)
sys.exit(0)
PY
