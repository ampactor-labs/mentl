#!/usr/bin/env bash
# drift-audit.sh — fluency-trap sentinel for Mentl.
#
# Scans given files (or all staged .mn files if none given) against the
# patterns in tools/drift-patterns.tsv. Each pattern is labeled with the
# drift-mode number it flags (1–9 from CLAUDE.md). Zero matches = clean.
# Any match = named drift mode, cited at file:line.
#
# Stand-in for `mentl audit` until Mentl's own audit handler lands.
# Patterns evolve: append rows to tools/drift-patterns.tsv. No script
# changes needed. The script is substrate-agnostic; it will outlive the
# bootstrap translator and any particular backend.
#
# Dependencies: bash, GNU grep. No ripgrep, no cargo, no bootstrap.
#
# Usage:
#   tools/drift-audit.sh [file1 file2 ...]
#   tools/drift-audit.sh                 # audits all staged .mn files
#
# Exit: 0 clean, 1 drift detected, 2 misuse.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PATTERNS="$SCRIPT_DIR/drift-patterns.tsv"

if [[ ! -f "$PATTERNS" ]]; then
    echo "drift-audit: patterns file not found at $PATTERNS" >&2
    exit 2
fi

# Collect files.
files=()
if [[ $# -gt 0 ]]; then
    for f in "$@"; do
        if [[ -f "$f" ]]; then
            files+=("$f")
        else
            echo "drift-audit: skipping missing file: $f" >&2
        fi
    done
else
    # Default: staged .mn files.
    if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        while IFS= read -r f; do
            [[ -n "$f" && -f "$REPO_ROOT/$f" ]] && files+=("$REPO_ROOT/$f")
        done < <(git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMR 2>/dev/null | grep -E '\.mn$' || true)
    fi
fi

if [[ ${#files[@]} -eq 0 ]]; then
    echo "drift-audit: no files to scan"
    exit 0
fi

total_hits=0
declare -A mode_hits
declare -A mode_names

# ── The code channel: string-literal and comment blindness, structural ──
# A code-channel pattern scans a STRIPPED twin of each file — string
# contents replaced by "" and // tails removed, line count preserved —
# so a keyword grep can never fire inside an emitted WAT string or a
# prose sentence again (the class that demanded ~17 hand markers).
# Comment-targeting rows (modes 9/14/37) declare channel `raw` and scan
# the original. Reports and the suppression walk always cite the
# ORIGINAL file; the twin is scan-substrate only.
STRIP_DIR=$(mktemp -d)
trap 'rm -rf "$STRIP_DIR"' EXIT
declare -A STRIPPED_OF
declare -A ORIG_OF
# Populates the two maps in the PARENT shell (a $() call would fork the
# writes away — measured as ORIG_OF unbound at the report map-back) and
# leaves the twin path in STRIPPED_LAST.
stripped_twin() {
    local orig="$1"
    if [[ -z "${STRIPPED_OF[$orig]:-}" ]]; then
        local flat="${orig//\//__}"
        local out="$STRIP_DIR/$flat"
        sed -E 's/"([^"\\]|\\.)*"/""/g; s|//.*$||' "$orig" > "$out"
        STRIPPED_OF[$orig]="$out"
        ORIG_OF[$out]="$orig"
    fi
    STRIPPED_LAST="${STRIPPED_OF[$orig]}"
}

# Read patterns: columns (tab-separated) = mode_num, mode_name, regex, scope, notes, channel
# (channel: empty/`code` = scan the stripped twin; `raw` = scan the original)
while IFS=$'\t' read -r mode_num mode_name regex scope notes channel; do
    [[ -z "${mode_num:-}" || "${mode_num:0:1}" == "#" ]] && continue
    [[ -z "${regex:-}" ]] && continue
    mode_names[$mode_num]="$mode_name"

    scan_files=()
    case "$scope" in
        ka)
            for f in "${files[@]}"; do [[ "$f" == *.mn ]] && scan_files+=("$f"); done
            ;;
        all|"")
            scan_files=("${files[@]}")
            ;;
        *)
            IFS=',' read -ra exts <<< "$scope"
            for f in "${files[@]}"; do
                for ext in "${exts[@]}"; do
                    [[ "$f" == *".${ext}" ]] && { scan_files+=("$f"); break; }
                done
            done
            ;;
    esac
    [[ ${#scan_files[@]} -eq 0 ]] && continue

    # GNU grep -E with line numbers. Suppressions: drop lines that carry
    # `drift-audit: ignore` on the same line, OR whose PREVIOUS line
    # carries the marker anywhere (the canonical layout renders a
    # trailing comment into leading position — either a marker-only line
    # or an arm-arrow line `X => // drift-audit: ignore …` with the body
    # on the next line — so the marker suppresses the line it precedes).
    # -H forces the filename prefix even for a SINGLE scanned file — without
    # it the suppression walk reads source text as its line number (measured:
    # a one-file scan fed the flagged line's own text into $((ml - 1))).
    # Code-channel rows scan the stripped twins; the match paths map back
    # to the originals so the report and the suppression walk read source.
    if [[ "${channel:-code}" != "raw" ]]; then
        twin_files=()
        for f in "${scan_files[@]}"; do stripped_twin "$f"; twin_files+=("$STRIPPED_LAST"); done
        matches=$(grep -nHE --color=never "$regex" "${twin_files[@]}" 2>/dev/null | while IFS=: read -r tf tl trest; do
            printf '%s:%s:%s\n' "${ORIG_OF[$tf]}" "$tl" "$trest"
        done || true)
    else
        matches=$(grep -nHE --color=never "$regex" "${scan_files[@]}" 2>/dev/null || true)
    fi
    [[ -z "$matches" ]] && continue

    filtered=$(printf '%s\n' "$matches" | grep -vE 'drift-audit:\s*ignore' | while IFS=: read -r mf ml mrest; do
        [[ -z "$mf" || -z "$ml" ]] && continue
        # Same-line suppression reads the ORIGINAL: a code-channel match
        # carries the stripped twin's text, where a trailing marker no
        # longer exists to be seen by the text filter above.
        if sed -n "${ml}p" "$mf" 2>/dev/null | grep -qE 'drift-audit:[[:space:]]*ignore'; then
            continue
        fi
        # Walk the contiguous attached-prose run above the flagged line
        # (comment lines, arm-arrow prose heads, list-continuation lines —
        # bounded at 15): the canonical layout merges a trailing marker
        # into that run, so a marker ANYWHERE in it suppresses the
        # statement the run precedes.
        suppressed=0
        prev=$((ml - 1)); steps=0
        while [[ $prev -ge 1 && $steps -lt 15 ]]; do
            pline=$(sed -n "${prev}p" "$mf" 2>/dev/null)
            if printf '%s' "$pline" | grep -qE 'drift-audit:[[:space:]]*ignore'; then
                suppressed=1; break
            fi
            # A line ending in `=` is a statement HEAD (fn/let) whose body the
            # canonical layout breaks onto the next line — the attached prose
            # (and its marker) sits ABOVE the head, so the head is transparent.
            if printf '%s' "$pline" | grep -qE '^[[:space:]]*(//|#)|(=>[[:space:]]*//)|(,[[:space:]]*$)|(\[[[:space:]]*$)|(\([[:space:]]*$)|(\{[[:space:]]*$)|(=[[:space:]]*$)'; then
                prev=$((prev - 1)); steps=$((steps + 1)); continue
            fi
            break
        done
        [[ $suppressed -eq 1 ]] && continue
        printf '%s:%s:%s\n' "$mf" "$ml" "$mrest"
    done || true)
    [[ -z "$filtered" ]] && continue

    count=$(printf '%s\n' "$filtered" | grep -c . || true)
    total_hits=$((total_hits + count))
    mode_hits[$mode_num]=$(( ${mode_hits[$mode_num]:-0} + count ))

    plural=""; [[ "$count" -ne 1 ]] && plural="s"
    echo "━━━ DRIFT MODE $mode_num — $mode_name ($count hit$plural)"
    [[ -n "${notes:-}" ]] && echo "    $notes"
    printf '%s\n' "$filtered" | sed 's/^/    /'
    echo
done < "$PATTERNS"

# ── THE QUIET GATE AT THE KEYSTROKE (2026-09-26) ──
# verify.sh ratchets the authored own/ref count in src/ (the Hylo bar: a
# marker the developer had to write is the ownership inference failing), and
# until today that ratchet fired LAST, after the march and the board — so two
# stray `ref` markers cost a second full board. The count per file is a text
# read, so the edit that raises it is refused here, against the file's own
# committed count, with the same pattern verify counts.
qg_pat_own='[(,] *own [a-z_]'
qg_pat_ref='[(,] *ref [a-z_]'
for f in "${files[@]}"; do
    rel="${f#"$REPO_ROOT"/}"
    case "$rel" in src/*.mn) ;; *) continue ;; esac
    was=$(git -C "$REPO_ROOT" show "HEAD:$rel" 2>/dev/null || true)
    # `|| true` inside: a file with no markers is the common case, and grep's
    # exit 1 would end the whole audit under pipefail.
    now_own=$( { grep -oE "$qg_pat_own" "$f" || true; } | wc -l)
    now_ref=$( { grep -oE "$qg_pat_ref" "$f" || true; } | wc -l)
    was_own=$( { printf '%s' "$was" | grep -oE "$qg_pat_own" || true; } | wc -l)
    was_ref=$( { printf '%s' "$was" | grep -oE "$qg_pat_ref" || true; } | wc -l)
    if [[ "$now_own" -gt "$was_own" || "$now_ref" -gt "$was_ref" ]]; then
        total_hits=$((total_hits + 1))
        mode_hits[quiet]=$(( ${mode_hits[quiet]:-0} + 1 ))
        echo "━━━ THE QUIET GATE — $rel raises its authored ownership markers"
        echo "    own $was_own -> $now_own, ref $was_ref -> $now_ref against HEAD. The inference grades"
        echo "    ownership; a marker written to satisfy it is the inference failing. Delete the"
        echo "    marker, or teach the inference — verify.sh refuses the same count later."
        echo
    fi
done

echo "════════════════════════════════════════════════════════════"
if [[ $total_hits -eq 0 ]]; then
    echo "drift-audit: CLEAN — ${#files[@]} file(s) scanned, 0 drift modes fired"
    exit 0
else
    echo "drift-audit: $total_hits match(es) across modes: ${!mode_hits[*]}"
    echo "Every flag is a drift mode firing. Do not rationalize — rewrite in residue form."
    echo "Suppress a single false positive with a trailing '# drift-audit: ignore' comment."
    exit 1
fi
