#!/usr/bin/env python3
"""The obey gate: a red gate is obeyed by fixing what it measures, and a
capability grows in the medium, never in a sidecar beside it.

Run by .githooks/pre-commit on the staged tree, and by the march with
--worktree before anything is staged. It compares that tree with HEAD and
refuses, with no flag that lets a commit through:

  1. a ceiling raised     — src/board.mn `Bound({ceiling: N, …})` and every
                            `*_max:` line of tools/verify-baseline.txt
  2. a bound deleted      — the same entries, gone, unless the ceiling was 0
                            or the human reshaped it into a bound born in the
                            same commit (`reshaped: old -> new` in the staged
                            file, refused in any later one), never raised
  3. a red leg declared   — a new `frontier_expected_red:` entry
  4. a gate silenced      — more `drift-audit: ignore` markers in .mn source
  5. work left unfinished — more "landed in part" or "NOT LANDED" records in
                            the documents: a landing is committed whole
  6. a sidecar grown      — a new script (.sh .py .js .mjs .ts) outside ide/,
                            a new .md document, or more text lines under
                            tools/: a capability belongs in the medium's own
                            source, and the scaffolds only shrink
"""
import os
import re
import subprocess
import sys

WORKTREE = "--worktree" in sys.argv


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def show(rev, path):
    """The text of `path` at `rev` (HEAD, or ':' for the index — the working
    tree under --worktree), or '' when it is absent or not text."""
    if rev == ":" and WORKTREE:
        try:
            data = open(path, "rb").read()
        except OSError:
            return ""
    else:
        r = subprocess.run(["git", "show", f"{rev}:{path}" if rev != ":" else f":{path}"], capture_output=True)
        data = r.stdout if r.returncode == 0 else b""
    try:
        return data.decode()
    except UnicodeDecodeError:
        return ""


def tracked(rev):
    """The paths at `rev`: HEAD's tree, the index, or under --worktree every
    file of the working tree git would track."""
    if rev == "HEAD":
        return set(git("ls-tree", "-r", "--name-only", "HEAD").split("\n")) - {""}
    found = set(git("ls-files", "--cached", *(["--others", "--exclude-standard"] if WORKTREE else [])).split("\n")) - {""}
    return {p for p in found if not WORKTREE or os.path.isfile(p)}


def board_bounds(text):
    return {m.group(2).strip(): int(m.group(1)) for m in re.finditer(r"Bound\(\{ceiling: (\d+), question: (.+?)\}\)", text)}


def baseline_maxes(text):
    return {m.group(1): int(m.group(2)) for m in re.finditer(r"^([a-z0-9_]+_max):\s*(\d+)\s*$", text, re.M)}


def expected_red(text):
    return {m.group(1).strip() for m in re.finditer(r"^frontier_expected_red:\s*(\S+)", text, re.M)}


def silencers(rev):
    args = ["grep", "-c", "drift-audit: ignore"] + ([rev] if rev != ":" else [] if WORKTREE else ["--cached"])
    return sum(int(line.rsplit(":", 1)[1]) for line in git(*args, "--", "*.mn").splitlines())


PARTIAL = re.compile(r"\b(landed in part|partially landed|landed partially)\b", re.I)
NOT_LANDED = re.compile(r"\bNOT LANDED\b")
RESHAPED = re.compile(r"^reshaped: ([a-z0-9_]+) -> ([a-z0-9_]+)$", re.M)


def unfinished(rev, paths):
    texts = [show(rev, p) for p in paths if p.endswith(".md")]
    return sum(len(PARTIAL.findall(t)) + len(NOT_LANDED.findall(t)) for t in texts)


def tool_lines(rev, paths):
    return sum(show(rev, p).count("\n") for p in paths if p.startswith("tools/"))


SCRIPT = re.compile(r"\.(sh|py|js|mjs|ts)$")


def main():
    refusals = []
    for path, read in (("src/board.mn", board_bounds), ("tools/verify-baseline.txt", baseline_maxes)):
        texts = show("HEAD", path), show(":", path)
        head, staged = map(read, texts)
        was_moved, moved = (dict(RESHAPED.findall(t)) for t in texts)
        refusals += [f"{path}: the reshape record of `{k}` outlived its commit" for k in moved.keys() & was_moved.keys()]
        for key, was in head.items():
            if key not in staged and was != 0 and moved.get(key) not in staged.keys() - head.keys():
                refusals.append(f"{path}: the bound on `{key}` (ceiling {was}) is gone")
            elif key in staged and staged[key] > was:
                refusals.append(f"{path}: `{key}` raised {was} -> {staged[key]}")
    added = expected_red(show(":", "tools/verify-baseline.txt")) - expected_red(show("HEAD", "tools/verify-baseline.txt"))
    refusals += [f"tools/verify-baseline.txt: `{leg}` declared an expected red" for leg in sorted(added)]

    head_paths, paths = tracked("HEAD"), tracked(":")
    for what, was, now in (
        ("`drift-audit: ignore` markers", silencers("HEAD"), silencers(":")),
        ("unfinished work recorded — commit a landing whole; open work is PLAN §11's alone",
         unfinished("HEAD", head_paths), unfinished(":", paths)),
        ("text lines under tools/ — the scaffolds only shrink as the medium absorbs them",
         tool_lines("HEAD", head_paths), tool_lines(":", paths)),
    ):
        if now > was:
            refusals.append(f"{what}: {was} -> {now}")
    for p in sorted(paths - head_paths):
        if SCRIPT.search(p) and not p.startswith("ide/"):
            refusals.append(f"{p}: a new script — grow the medium (a verb in src/), not a sidecar")
        if p.endswith(".md") and p != "MENTL_MEMORY.md":
            refusals.append(f"{p}: a new document — the read path is MENTL_MEMORY.md, CLAUDE.md, PLAN.md and docs/SYNTAX.md")

    if refusals:
        print("✗ OBEY GATE — a red gate is obeyed by fixing what it measures:")
        for r in refusals:
            print(f"  {r}")
        print("  Fix the thing measured (lower the count, make the leg pass, remove the cause")
        print("  the marker hides, build the capability in the medium). A bound a correct")
        print("  landing must raise is the wrong shape: reshape it — a raise is never the fix.")
        sys.exit(1)
    print("✓ obey gate: no ceiling raised, no bound dropped, no red declared, nothing silenced, unfinished or grown beside the medium")


if __name__ == "__main__":
    main()
