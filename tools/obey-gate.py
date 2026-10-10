#!/usr/bin/env python3
"""The obey gate: a red gate is obeyed by fixing what it measures, never
satisfied by moving the gate.

Run by .githooks/pre-commit against the staged tree. It compares what is
staged with HEAD and refuses the six moves that turn a red gate green
without changing what it measures:

  1. a ceiling raised        — src/board.mn `Bound({ceiling: N, …})`, and every
                               `*_max:` line of tools/verify-baseline.txt
  2. a bound deleted         — the same entries, gone, unless the ceiling was 0
                               (a class held at zero retires when it is armed)
  3. a red leg declared      — a new `frontier_expected_red:` entry
  4. a gate silenced         — more `drift-audit: ignore` markers in the tree
  5. a defect parked         — more OPEN entries in RESIDUE.md
  6. a landing claimed in part — more "landed in part" claims in PLAN.md,
                               RESIDUE.md, LEDGER.md or docs/: the target
                               rewritten to what was built (CLAUDE.md ⚖,
                               "truing is not moving the goalposts")

There is no flag that lets a commit through. A bound whose measurement a
correct landing must raise is a gate of the wrong shape: it is reshaped, by
the human, in this file's company — never raised to fit. When this refuses,
the work is the thing the gate measures.
"""
import re
import subprocess
import sys


WORKTREE = "--worktree" in sys.argv


def show(rev, path):
    """The file at `rev` (HEAD, or ':' for the index — the working tree under
    --worktree, which the march reads before anything is staged), or ''."""
    if rev == ":" and WORKTREE:
        try:
            return open(path).read()
        except OSError:
            return ""
    spec = f"{rev}:{path}" if rev != ":" else f":{path}"
    r = subprocess.run(["git", "show", spec], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else ""


def board_bounds(text):
    out = {}
    for m in re.finditer(r"Bound\(\{ceiling: (\d+), question: (.+?)\}\)", text):
        out[m.group(2).strip()] = int(m.group(1))
    return out


def baseline_maxes(text):
    out = {}
    for line in text.splitlines():
        m = re.match(r"^([a-z0-9_]+_max):\s*(\d+)\s*$", line)
        if m:
            out[m.group(1)] = int(m.group(2))
    return out


def expected_red(text):
    return {m.group(1).strip() for m in re.finditer(r"^frontier_expected_red:\s*(\S+)", text, re.M)}


def open_residue(text):
    return len(re.findall(r"^### .*— OPEN", text, re.M))


PARTIAL = re.compile(r"\b(landed in part|partially landed|landed partially)\b", re.I)
RECORDS = ["PLAN.md", "RESIDUE.md", "LEDGER.md"]


def partial_claims(rev):
    """Every claim that a landing landed in part, across the records and the
    design documents — a landing is landed or it is not."""
    paths = list(RECORDS)
    r = subprocess.run(["git", "ls-files", "--", "docs"], capture_output=True, text=True)
    paths += [p for p in r.stdout.split() if p.endswith(".md")]
    return sum(len(PARTIAL.findall(show(rev, p))) for p in paths)


def silencers(rev):
    """The markers the drift audit obeys — in .mn source, the only place one
    silences anything; a document naming the marker is prose."""
    args = ["git", "grep", "-c", "drift-audit: ignore"]
    if rev != ":":
        args += [rev]
    elif not WORKTREE:
        args += ["--cached"]
    args += ["--", "*.mn"]
    r = subprocess.run(args, capture_output=True, text=True)
    total = 0
    for line in r.stdout.splitlines():
        total += int(line.rsplit(":", 1)[1])
    return total


def main():
    refusals = []

    for path, read in (("src/board.mn", board_bounds), ("tools/verify-baseline.txt", baseline_maxes)):
        head, staged = read(show("HEAD", path)), read(show(":", path))
        for key, was in head.items():
            if key not in staged:
                if was != 0:
                    refusals.append(f"{path}: the bound on `{key}` (ceiling {was}) is gone")
            elif staged[key] > was:
                refusals.append(f"{path}: `{key}` raised {was} -> {staged[key]}")

    added = expected_red(show(":", "tools/verify-baseline.txt")) - expected_red(show("HEAD", "tools/verify-baseline.txt"))
    for leg in sorted(added):
        refusals.append(f"tools/verify-baseline.txt: `{leg}` declared an expected red")

    was, now = silencers("HEAD"), silencers(":")
    if now > was:
        refusals.append(f"`drift-audit: ignore` markers {was} -> {now}")

    was, now = open_residue(show("HEAD", "RESIDUE.md")), open_residue(show(":", "RESIDUE.md"))
    if now > was:
        refusals.append(f"RESIDUE.md: OPEN entries {was} -> {now}")

    was, now = partial_claims("HEAD"), partial_claims(":")
    if now > was:
        refusals.append(f"a landing claimed in part {was} -> {now} — build what it states, or record it NOT LANDED")

    if refusals:
        print("✗ OBEY GATE — a red gate is obeyed by fixing what it measures:")
        for r in refusals:
            print(f"  {r}")
        print("  Fix the thing measured (lower the count, close the peer, make the leg pass,")
        print("  remove the cause the marker hides). A bound a correct landing must raise is")
        print("  the wrong shape: reshape it — a raise is never the fix.")
        sys.exit(1)
    print("✓ obey gate: no ceiling raised, no bound dropped, no red declared, nothing silenced, parked or claimed in part")


if __name__ == "__main__":
    main()
