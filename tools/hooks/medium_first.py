#!/usr/bin/env python3
"""The medium-first gate: a PreToolUse hook that refuses hand searches and
hand writes over .mn source while a projection of the medium answers them.

CLAUDE.md's verb map said this in prose, and prose caught none of it: a
session that knew the rule grepped src/*.mn for definitions and references
the medium had answered by edge for weeks. A law that can become a gate
must, so this is the gate. It reads the hook's JSON on stdin and exits 2
(refuse, the reason on stderr) or 0 (proceed).

Two refusals:
  1. A search over .mn source -- the Grep tool scoped to .mn, or a grep/rg
     segment of a Bash command whose own arguments name .mn source. A grep
     FILTERING another command's output (`mentl query ... | grep x`) reads
     no source and passes.
  2. A write to .mn source that is not the medium's or the Edit tool's -- a
     `sed -i`, a redirect, a `tee`, a python write. The drift audit fires on
     Edit-tool writes; a shell write edits the wheel outside its gate.

The confession: a Bash command carrying `verb-gap: <the facet that is
missing>` passes, and the line lands in .build/verb-gaps.log. A question no
verb answers is the facet to grow in the same landing, and the log is where
the landing finds it.
"""

import json
import os
import re
import shlex
import sys
import time

VERBS = """Ask the medium first:
  mentl query src/main.mn "refs of NAME"     every reference, by edge
  mentl where src/main.mn NAME               a declaration's head, row and widths
  mentl query src/main.mn decls              the declaration roster with spans
  mentl query src/main.mn unreachable        what nothing reaches
  mentl query src/main.mn "census <shape>"   a structural shape, counted
  mentl query src/main.mn census             the census roster, every shape with its count
  mentl query src/main.mn "text NEEDLE"      every string literal holding it (the emit's WAT)
  mentl query src/main.mn "prose NEEDLE"     every comment holding it, at the comment
  mentl query src/main.mn "writes of FIELD"  every value written into a handler state field
  mentl query src/main.mn "provider of OP"   every handler with an arm for it, at the arm
  mentl doc <module>                         a module's decls with types and ledes
  mentl <file:line[:col]>                    the eight aspects at a position
If no verb answers the question, that absence is the finding: run the search
through Bash with `# verb-gap: <the facet that is missing>`. It is logged to
.build/verb-gaps.log and the facet is grown in the same landing."""

SEARCHERS = {"grep", "egrep", "fgrep", "rg", "ag", "ack"}
WRAPPERS = {"env", "time", "timeout", "nice", "command", "xargs", "sudo"}


def project_dir():
    return os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()


def names_mn_source(token):
    """A path-ish token that names wheel or library source."""
    t = token.strip("'\"")
    if t.endswith(".mn") or ".mn " in t or "*.mn" in t or t.endswith(".mn}"):
        return True
    t = t.rstrip("/")
    root = project_dir().rstrip("/")
    if t.startswith(root + "/"):
        t = t[len(root) + 1:]
    t = t.lstrip("./")
    return t in ("src", "lib") or t.startswith("src/") or t.startswith("lib/")


def segments(command):
    """Split a shell command into simple-command segments at | ; && || and
    newlines, keeping quoted text intact."""
    out, cur, quote, i = [], [], None, 0
    while i < len(command):
        c = command[i]
        if quote:
            cur.append(c)
            if c == quote:
                quote = None
        elif c in ("'", '"'):
            quote = c
            cur.append(c)
        elif c in "|;&\n(":
            out.append("".join(cur))
            cur = []
        else:
            cur.append(c)
        i += 1
    out.append("".join(cur))
    return [s.strip() for s in out if s.strip()]


def words(segment):
    try:
        return shlex.split(segment, comments=True)
    except ValueError:
        return segment.split()


def head(ws):
    """The command a segment runs, past wrappers and assignments."""
    i = 0
    while i < len(ws):
        w = ws[i]
        if "=" in w and not w.startswith("-") and w.split("=")[0].isidentifier():
            i += 1
            continue
        if w in WRAPPERS:
            i += 1
            while i < len(ws) and ws[i].startswith("-"):
                i += 1
            if i < len(ws) and ws[i - 1] == "timeout" and re.match(r"^\d", ws[i]):
                i += 1
            continue
        return ws[i:]
    return []


# Options whose value is the next word, and the ones that supply the pattern
# (so the first operand is a path, not the pattern).
VALUE_OPTS = {"-A", "-B", "-C", "-m", "-e", "-f", "-g", "-t", "-T", "--max-count",
              "--include", "--exclude", "--type", "--type-not", "--glob", "--regexp",
              "--file", "--context", "--after-context", "--before-context"}
PATTERN_OPTS = {"-e", "-f", "--regexp", "--file"}
FILTER_OPTS = {"-g", "-t", "--include", "--type", "--glob"}


def search_operands(args):
    """A searcher's path operands and the file filters it was given. The
    pattern is not a path: it is the first operand unless -e or -f supplied
    it, and a pattern that merely mentions a `.mn` file searches nothing
    (refusing `grep 'prelude.mn' tools/*.sh` was this gate's first defect)."""
    operands, filters, pattern_given, i = [], [], False, 0
    while i < len(args):
        w = args[i]
        if w == "--":
            operands.extend(args[i + 1:])
            break
        if w.startswith("-") and len(w) > 1:
            name, _, inline = w.partition("=") if w.startswith("--") else (w[:2], "", w[2:])
            if name in PATTERN_OPTS:
                pattern_given = True
            if name in VALUE_OPTS:
                value = inline if inline else (args[i + 1] if i + 1 < len(args) else "")
                if name in FILTER_OPTS:
                    filters.append(value)
                if not inline:
                    i += 1
            i += 1
            continue
        operands.append(w)
        i += 1
    return (operands if pattern_given else operands[1:]), filters


def recursive(cmd, args):
    if cmd in ("rg", "ag", "ack"):
        return True
    return any(w in ("-r", "-R", "--recursive") or
               (w.startswith("-") and not w.startswith("--") and ("r" in w[1:] or "R" in w[1:]))
               for w in args)


def bash_search(segment):
    ws = head(words(segment))
    if not ws:
        return False
    if ws[0] == "git" and len(ws) > 1 and ws[1] == "grep":
        return any(names_mn_source(w) for w in ws[2:]) or "--" not in ws
    cmd = os.path.basename(ws[0])
    if cmd in SEARCHERS:
        paths, filters = search_operands(ws[1:])
        if paths:
            return any(names_mn_source(w) for w in paths)
        # No path: a recursive search reads the working directory, which is
        # source unless a filter keeps it to other files. A plain grep with no
        # path reads stdin, the filter form that passes.
        if not recursive(cmd, ws[1:]):
            return False
        if filters and not any(".mn" in f or f in ("*", "**", "**/*") for f in filters):
            return False
        return names_mn_source(os.getcwd()) or os.getcwd().rstrip("/") == project_dir().rstrip("/")
    return False


def bash_write(segment, command):
    ws = head(words(segment))
    if not ws:
        return False
    cmd = os.path.basename(ws[0])
    if cmd in ("sed", "perl") and any(w.startswith("-i") or w == "-pi" for w in ws[1:]):
        # The script is not a target: an expression that mentions a `.mn`
        # name edits whatever files follow it, not that name.
        targets, _ = search_operands([w for w in ws[1:] if not w.startswith("-i") and w != "-pi"])
        return any(names_mn_source(w) for w in targets)
    if cmd == "tee":
        return any(names_mn_source(w) for w in ws[1:] if not w.startswith("-"))
    if cmd in ("python", "python3") and re.search(
            r"open\(\s*[^)]*\.mn['\"]\s*,\s*['\"][wax+]|\.mn['\"]\s*\)\s*\.write_text", command):
        return True
    bare = re.sub(r"'[^']*'|\"(?:\\.|[^\"\\])*\"", "''", segment)
    redirect = re.findall(r"(?<![0-9&])>>?\s*([^\s;&|]+)", bare)
    return any(names_mn_source(t) for t in redirect)


def confess(command):
    m = re.search(r"verb-gap:\s*(.+)", command)
    if not m:
        return False
    os.makedirs(os.path.join(project_dir(), ".build"), exist_ok=True)
    with open(os.path.join(project_dir(), ".build", "verb-gaps.log"), "a") as log:
        log.write("%s\t%s\n" % (time.strftime("%Y-%m-%dT%H:%M:%S"), m.group(1).strip()))
    return True


def refuse(reason):
    sys.stderr.write("medium-first: %s\n%s\n" % (reason, VERBS))
    sys.exit(2)


def main():
    try:
        event = json.load(sys.stdin)
    except ValueError:
        sys.exit(0)
    tool = event.get("tool_name", "")
    args = event.get("tool_input", {}) or {}
    if tool == "Grep":
        glob = args.get("glob", "") or ""
        path = (args.get("path", "") or "").rstrip("/")
        if glob:
            scoped = ".mn" in glob or glob in ("*", "**", "**/*")
        elif args.get("type"):
            scoped = False
        elif path and path not in (".", project_dir().rstrip("/")):
            scoped = names_mn_source(path)
        else:
            scoped = True
        if scoped:
            refuse("the Grep tool is searching .mn source by hand.")
        sys.exit(0)
    if tool == "Bash":
        command = args.get("command", "") or ""
        segs = segments(command)
        writes = [s for s in segs if bash_write(s, command)]
        if writes:
            sys.stderr.write(
                "medium-first: a shell write to .mn source (%s). Edit .mn through the Edit\n"
                "tool, where the drift audit fires, or through a verb that writes its own\n"
                "fixpoint (mentl fmt, mentl tighten, mentl accept).\n" % writes[0][:80])
            sys.exit(2)
        if any(bash_search(s) for s in segs):
            if confess(command):
                sys.exit(0)
            refuse("this command searches .mn source by hand (%s)." %
                   next(s for s in segs if bash_search(s))[:80])
        sys.exit(0)
    sys.exit(0)


if __name__ == "__main__":
    main()
