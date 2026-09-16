#!/usr/bin/env bash
# micro-battery.sh — THE micro battery loop, one home.
#
# verify.sh (pinned boot) and march-gate.sh --micros (the candidate m2)
# both walked tests/micros/mn-*.mn with their own hand-rolled loops —
# two implementations of one judgment, drifting apart in grammar coverage
# (march-gate's reader knew the refuse contract, verify's skipped it).
# The loop lives here now; the compiler under test is the first argument.
#
# THE COMPILE HAPPENS ONCE, IN THE MEDIUM (2026-09-16). This script used to
# call run-micro.sh per fixture, which spawns THREE processes each — compile,
# assemble, run — and the compile was one the medium had already performed:
# verify runs `mentl test` beside this loop, and that verb compiles all 149 in
# ONE process and WRITES each module to .build/test/<stem>.wat. Two channels
# paid for the same judgment. Measured end to end on the pinned boot, whole
# battery rather than a single fixture extrapolated (a first pass quoted
# ~343s from one timed micro and was wrong by 60% — shell startup amortizes):
#
#     bash loop, 3 spawns per fixture ......... 215s   (1.44s each)
#     `mentl test`, one process ............... 76s    (0.51s each)
#     the compiler compiling its own 60k lines . ~15s
#     a bare `fn main() = 7` .................. 0.886s
#     the same + the four runtime libs ........ 1.228s
#
# The compiler was never the slow part (§5.O at the gate layer: an operation
# whose cost grows while its ANSWER did not change is the law violated), and
# verify paid for BOTH channels while the repin gate paid for the bash half
# again.
#
# The two sides link the IDENTICAL set, same order — battery_libs() in
# src/main.mn reads lib/memory.mn ++ lib/strings.mn ++ lib/lists.mn ++
# lib/prelude.mn, and MENTL_RT_LIBS in wt-env.sh is those four. The WAT on
# disk is exactly what this loop would have produced; the reuse is sound
# rather than an approximation, and that equality is the thing to re-check if
# either side's link ever changes.
#
# run-micro.sh keeps its whole-pipeline form: it is the single-fixture harness
# a person invokes by hand, and it must stay able to compile. This battery
# simply stops routing through it.
#
# Usage: tools/micro-battery.sh <compiler.wasm> [label]
set -u
COMPILER="$1"; LABEL="${2:-micros}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$(dirname "$0")/wt-env.sh"
base_dir="${TMPDIR:-/tmp}"

# ── PHASE 1 · one process compiles and judges every fixture's compile side ──
# The verb's own verdicts: MICRO (compiled; run it), REFUSE (the judgment
# reported the named class — the refuse contract judges the JUDGMENT, so
# there is nothing left to execute), FAILC/FAILR/NOEXPECT (compile-side
# failures, already final).
tout="$base_dir/micro-battery.$$.out"; terr="$base_dir/micro-battery.$$.err"
wt_run --dir "$ROOT" "$COMPILER" test tests/micros > "$tout" 2> "$terr"
trc=$?

# THE EXIT CODE AND THE COUNT ARE PART OF THE CONTRACT. `mentl test` trapped
# at fixture 118 of 149 for a day while the gate that read it counted FAILC
# lines and reported green, because a crash prints none (pin 88ad0b6b). A
# battery that reads a dead process for the absence of a string cannot fail.
want_n=$(ls tests/micros/mn-*.mn 2>/dev/null | wc -l)
seen_n=$(grep -cE '^(MICRO|REFUSE|FAILC|FAILR|NOEXPECT) ' "$tout" || true)
if [ "$trc" -ne 0 ] || [ "$seen_n" -ne "$want_n" ]; then
  echo "✗ battery: the compile phase did not finish — exit=$trc, $seen_n/$want_n fixtures judged"
  [ "$trc" -ne 0 ] && { echo "  the verb itself failed; its stderr:"; tail -6 "$terr"; }
  [ "$seen_n" -lt "$want_n" ] && echo "  it stopped early: everything after the last judged fixture went unchecked."
  rm -f "$tout" "$terr"
  exit 1
fi

# ── PHASE 2 · assemble and run only what compiled ──────────────────────────
pass=0; fail=0; dtot=0; dfix=""; done_n=0; dknown=1
# STDIN IS REDIRECTED ON EVERY CHILD BELOW. The loop reads its verdicts from
# fd 0, and a child that inherits it consumes the remaining lines — the
# fixtures after it are then never judged and nothing says so. `< /dev/null`
# on each spawn is what keeps the list intact.
while read -r verdict stem f1 f2 f3; do
  done_n=$((done_n+1))
  case "$verdict" in
    REFUSE)
      # f1 = the class the judgment named. Compile-side and complete.
      echo "✓ micro ${stem#mn-}: refuses $f1"; pass=$((pass+1)) ;;
    MICRO)
      wat="$f1"; exp="$f2"; d="$f3"
      m="${stem#mn-}"
      # A COMPILER OLDER THAN THE nerr FIELD REPORTS "?", NEVER 0. The count
      # rides the MICRO line from src/main.mn, so a boot pinned before that
      # landing prints three fields and not four — and defaulting the missing
      # one to zero would make the summary claim "0 error(s) reported" on the
      # strength of a field that was never sent. Unknown says unknown; the
      # total goes unavailable rather than wrong, and it self-heals at the
      # repin that puts the field in the boot.
      if [ -z "$d" ]; then d="?"; dknown=0; else
        dtot=$((dtot + d)); [ "$d" -gt 0 ] && dfix="$dfix $m"
      fi
      b="$base_dir/$stem"
      if ! wt_asm "$wat" "$b.wasm" < /dev/null 2> "$b.w2e"; then
        echo "✗ micro $m: FAIL(wat) $(head -1 "$b.w2e")"; fail=$((fail+1)); continue
      fi
      wt_run "$b.wasm" < /dev/null > "$b.out" 2> "$b.run-err"; rexit=$?
      if [ "$rexit" -ne "$exp" ]; then
        echo "✗ micro $m: FAIL(run) exit=$rexit expected=$exp diags=$d"
        # The 1 is the ceiling, not the computation. Say so, or the next reader
        # "fixes" the expectation to 1 and banks a gate that asserts nothing.
        if [ "$rexit" -eq 1 ] && [ "$exp" -gt 125 ]; then
          echo "  the exit channel caps at 125: any value above it arrives as 1, so this"
          echo "  1 is the channel and not the program. Expect <= 125, or 134 for a trap."
        fi
        tail -4 "$b.run-err"; fail=$((fail+1))
      else
        echo "✓ micro $m: exit=$rexit (expected $exp) diags=$d"; pass=$((pass+1))
      fi ;;
    FAILC|FAILR|NOEXPECT)
      echo "✗ micro ${stem#mn-}: $verdict $rest"; fail=$((fail+1)) ;;
  esac
done < "$tout"
rm -f "$tout" "$terr"

# THE SECOND HALF OF THE SAME CONTRACT. Phase 1 proves the medium judged every
# fixture; this proves the exec loop consumed every verdict it was handed. A
# count checked at one end only is the hole the stdin bug walks through, and
# "it went quiet" is the failure mode this whole landing exists to answer.
if [ "$done_n" -ne "$seen_n" ]; then
  echo "✗ battery: the exec loop consumed $done_n of $seen_n verdicts — the rest went unjudged."
  echo "  a child inheriting the loop's stdin eats the remaining lines; every spawn needs < /dev/null."
  fail=$((fail+1))
fi

# The per-micro count is printed on every line and summed here, because a
# number nobody totals is a number nobody reads. It rides the medium's own
# MICRO line now (src/main.mn) rather than being re-grepped out of a second
# compile's stderr — the count was always the judgment's, never bash's.
if [ "$dknown" -eq 1 ]; then
  echo "── $LABEL: $pass pass / $fail fail · $dtot error(s) reported across${dfix:- none} ──"
else
  echo "── $LABEL: $pass pass / $fail fail · error counts UNAVAILABLE (this compiler predates the nerr field on the MICRO line) ──"
fi
[ "$fail" -eq 0 ]
