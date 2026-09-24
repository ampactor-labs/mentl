#!/usr/bin/env bash
# tools/verify.sh — the Mentl gate (proto-`mentl check`).
#
# Boot-era gate: the micro battery compiles-and-runs green through the pinned
# fixpoint wheel (boot/mentl.wasm), plus the census RATCHET — the medium's own
# verdict on its own source, which may never get worse (§3 below carries the
# re-founding). Green is STAMPED on wt_state_key, so re-runs on an unchanged
# tree (above all the pre-commit hook) answer instantly; FORCE_VERIFY=1 re-runs.
#
# Usage: tools/verify.sh
# Exit:  0 thesis holds, 1 thesis violated, 2 invocation error.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BASELINE="tools/verify-baseline.txt"
source "$ROOT/tools/wt-env.sh"   # WT, WT_RUN_FLAGS, W2W — the one home
# The runtime trio IS the vocabulary every real .mn program reaches for, so
# a micro compiled WITHOUT it is the abnormal case, not the default. Link it for
# every micro: a micro that calls str_concat/str_eq (strings) or ev_lookup (the
# keyed-evidence dispatch scan, memory.mn) gets its def; one that uses
# neither pays nothing (reachability-from-main drops the unused). A micro failing
# only because the vocabulary was withheld is the harness lying, not a regression.
RTLIBS=("${MENTL_RT_LIBS[@]}")

say() { printf '%s\n' "$*"; }
fail=0

[[ -f "$BASELINE" ]] || { say "verify: baseline missing: $BASELINE"; exit 2; }
[[ -x "$WT" ]] || { say "verify: the runner is not built at $WT (cargo build --release --manifest-path tools/runner/Cargo.toml)"; exit 2; }

# ── the GREEN STAMP — verify is idempotent on an unchanged tree ─────────────
# The verdict is a pure function of the gate-relevant state (wt_state_key:
# wheel sources + boot + micros + the gate scripts). A green run stamps that
# key; a re-run — above all the pre-commit hook, seconds after a green — answers
# from the stamp instead of re-paying the ~15-minute gate it just watched pass
# (the IC principle: the oracle is incremental computation plus one cached
# value). FORCE_VERIFY=1 re-runs regardless. The flock serializes concurrent
# gates — the second waits, re-checks the stamp, and usually exits instantly.
GATE_DIR=".build/gate"; GATE_STAMP="$GATE_DIR/verify.green"
STATE_KEY=$(wt_state_key)
if [[ "${FORCE_VERIFY:-0}" != 1 && "$(cat "$GATE_STAMP" 2>/dev/null)" == "$STATE_KEY" ]]; then
  say "verify: cached green — gate state unchanged since the last full run"
  say "        (stamp $GATE_STAMP; FORCE_VERIFY=1 re-runs the battery)"
  exit 0
fi
mkdir -p "$GATE_DIR"; exec 8>"$GATE_DIR/lock"; flock 8
if [[ "${FORCE_VERIFY:-0}" != 1 && "$(cat "$GATE_STAMP" 2>/dev/null)" == "$STATE_KEY" ]]; then
  say "verify: cached green (a concurrent gate finished while this one waited)"
  exit 0
fi

# 1. The compiler exists: the pinned fixpoint wheel (boot/ — first light
#    2026-07-10; boot/PROVENANCE.md). The hand-WAT seed is DELETED (7401c4b);
#    the cold-ladder recipe lives at tag first-light (band J archaeology).
BOOT="boot/mentl.wasm"
[[ -f "$BOOT" ]] || { say "verify: compiler missing: $BOOT"; exit 2; }
export MENTL_BOOT="$BOOT"
say "✓ compiler: $BOOT"

# 2. Micro battery — the medium's own `test` verb against the pinned boot:
#    every fixture compiled, run through the runner's exec seam and judged
#    against its own `// expect:` contract in ONE process (wt_battery reads
#    the verdict and holds the exit + every-fixture-judged contract).
say "· micro battery (tests/micros through the pinned boot)..."
if ! wt_battery "$BOOT" tests/micros "micros-through-boot"; then fail=1; fi

# 2b. The contract battery — the medium enforcing every fixture's own
#     contract (run AND refuse grammars) in one process. A FAILC / FAILR /
#     NOEXPECT line is a broken contract; the run-values above stay the
#     exec-side check until the exec seam itself absorbs.
#
#     THE COMPILER IS THE ONE THIS GATE OWNS, never the installed pointer.
#     The shim resolves MENTL_HOME to the repo it was installed from, so in
#     a worktree `mentl test` judged THIS tree's fixtures with MAIN's boot —
#     a fixture gating a brand-new diagnostic reported FAILR while the
#     worktree's own compiler judged it correctly (measured 2026-08-12, a
#     full dig spent chasing a detector that was firing the whole time).
#     Every sibling leg below already reads $C/m2.wasm; this one re-derived
#     the compiler from an install pointer instead, which is the
#     Carried-Truth Law at the scaffold. Read the wheel the gate just built.
#     wt_m2_ensure is the ONE keyed artifact the census leg reads too, so
#     asking for it here costs a cache hit, not a build.
if C=$(wt_m2_ensure); then
  # THE EXIT CODE AND THE COUNT ARE PART OF THE CONTRACT, and leaving them
  # out cost this gate its meaning. It used to pipe straight into
  # `grep -cE '^(FAILC|FAILR|NOEXPECT) '` and pass on zero — so when the verb
  # TRAPPED partway, it printed no failure line and the gate said every
  # fixture's contract holds. Measured 2026-09-16: `mentl test` died at
  # fixture 118 of 149 (exit 134, a dangling banked diagnostic line — the
  # GateLedger record in src/mcp.mn) and this leg was green through it, with
  # the 31 fixtures after the crash point never judged at all. A gate that
  # reads a crashed process for the ABSENCE of a string cannot fail.
  # So: capture the status, and require the verb to have judged every fixture
  # it was handed.
  if ! wt_battery "$C/m2.wasm" tests/micros "contract battery (this tree's wheel)"; then fail=1; fi
  # 2c. The SYNTAX conformance battery (PLAN §11 Phase 0.4) — fixtures for
  #     forms SYNTAX declares and the WHEEL NEVER WRITES. That is the whole
  #     point: every other leg on this board measures what the wheel does, so
  #     a declared form the wheel avoids is invisible to all of them (§11
  #     tripwire 3, whose standing counter-measure this is). The seed set is
  #     what has been measured, never a claim of coverage; it grows as
  #     surfaces are probed, and a surface found BROKEN banks a named peer
  #     with its repro rather than a fixture canonizing the wrong answer
  #     (§9.11's nine payload micros did exactly that).
  #
  #     IT RUNS EACH FIXTURE THROUGH THE BLOB LINK, and the reason recorded
  #     here for years was the WRONG ONE. It read: "`mentl test` ... does not
  #     execute, so a wrong `// expect: N` passes it silently. The first draft
  #     read only that verb, went green against a deliberately wrong
  #     expectation, and was a gate that could not fail (Law 11)." That was a
  #     real measurement the day it was written. Then the wheel gained exec
  #     and nothing came back to re-ask.
  #     MEASURED 2026-09-21, both directions, because retracting a limitation
  #     is a claim and Law 11 applies to it too:
  #       `mentl test tests/syntax`  → PASS arm-list-literal: exit=34 (expected 34)
  #       the same with the header edited to `// expect: 99` →
  #                                    FAIL(run) arm-list-literal: exit=34 expected=99
  #     The verb executes and it refuses a wrong expectation. The old reason
  #     is dead.
  #     THE REAL RETIREMENT CONDITION IS THE LINK, and it is why run-micro.sh
  #     stays: this loop pipes RTLIBS concatenated — the BLOB link, which is
  #     the wheel's own build path — while `mentl test <dir>` compiles each
  #     fixture through its own imports, the MANIFEST link. The leg below
  #     exists precisely to compare the two, so swapping this one onto the
  #     verb would leave both halves reading the same link and quietly delete
  #     the agreement contract. That swap was written and REVERTED on the day
  #     this comment was corrected, which is the whole lesson: a stale reason
  #     hides a live one, and removing the stale reason is not permission to
  #     act — it is permission to look for the real one.
  #     `Hβ.test.blob-link-has-no-verb` is the actual gap: the verb has no
  #     blob-link battery, and when it grows one this loop dies for a reason
  #     that is true.
  syn_n=0; syn_bad=0
  for sf in tests/syntax/*.mn; do
    [[ -e "$sf" ]] || continue
    syn_n=$((syn_n+1))
    s=$(basename "$sf" .mn)
    swant=$(sed -n '1s|^// expect: \([0-9]\+\)$|\1|p' "$sf")
    if [[ -z "$swant" ]]; then
      say "✗ syntax $s: no '// expect: N' header"; syn_bad=$((syn_bad+1)); continue
    fi
    # The VERDICT line, not the last line: run-micro.sh prints FAIL(...) and
    # then tails the run's stderr, so `tail -1` on a failure hands back a
    # backtrace frame and the leg reports "no output" for a real breakage.
    sout=$(tools/run-micro.sh "$sf" "$swant" "${RTLIBS[@]}" 2>/dev/null | grep -E '^(PASS|FAIL)' | tail -1)
    [[ "$sout" == PASS* ]] || { say "✗ syntax $s: ${sout:-no output}"; syn_bad=$((syn_bad+1)); }
  done
  # THE SAME FIXTURES THROUGH THE MANIFEST. The battery above concatenates
  # RTLIBS — four modules — and pipes the result in; a real program links
  # seven through its import DAG, threading among them. So the battery built
  # for surfaces the wheel never writes had a blind spot of its own, and it
  # was hiding a broken fixture: tests/syntax/labeled-args.mn declared
  # `fn spawn_task`, which is an op of WasiThreads, so through the manifest
  # its function was unreachable and the op ran instead. It passed here for
  # months because the blob omits threading (found 2026-08-18, the day
  # E_FnShadowsOp armed — the class's first outing).
  #
  # The contract is agreement: a declared form that behaves differently in
  # the two links is a finding either way. This leg can only CHECK (the raw
  # wheel has no `run` verb — that is the shim), which is enough: a
  # diagnostic through the manifest on a fixture that runs clean in the blob
  # is exactly the divergence.
  man_bad=0
  for sf in tests/syntax/*.mn; do
    [[ -e "$sf" ]] || continue
    mout=$(wt_run --dir . "$C/m2.wasm" "$sf" check 2>&1 | grep -cE ' error: ' || true)
    if [[ "$mout" -gt 0 ]]; then
      say "✗ syntax(manifest) $(basename "$sf" .mn): $mout diagnostic(s) the blob link never sees"
      man_bad=$((man_bad+1))
    fi
  done
  if [[ "$man_bad" -gt 0 ]]; then
    say "✗ syntax battery through the MANIFEST: $man_bad fixture(s) diverge between the two links"
    fail=1
  else
    say "✓ syntax battery through the manifest: $syn_n fixture(s) check clean in the real link too"
  fi
  if [[ "$syn_n" -eq 0 ]]; then
    say "✗ syntax battery: no fixtures — the directory PLAN §11 0.4 names is empty"
    fail=1
  elif [[ "$syn_bad" -eq 0 ]]; then
    say "✓ syntax battery: $syn_n declared-form fixture(s) run true (surfaces the wheel never writes)"
  else
    say "✗ syntax battery: $syn_bad of $syn_n fixture(s) broke their contract"
    fail=1
  fi

  # 2c. THE FLOOR CONTRACT — an unprovable field offset REFUSES, and says
  #     which. Two halves, because either alone is a gate that cannot fail:
  #     the trap (never a guessed offset 0 reading a foreign field) and the
  #     marker's TEXT (the selector and the receiver's live row). The text
  #     half is what turns a floor census from a count into an inventory,
  #     and this arc re-derived the blocking row by hand four times before
  #     the emit was asked to speak it.
  flr_n=0; flr_bad=0
  for ff in tests/floors/*.mn; do
    [[ -e "$ff" ]] || continue
    flr_n=$((flr_n+1))
    f=$(basename "$ff" .mn)
    fwant=$(sed -n '1s|^// expect: \([0-9]\+\)$|\1|p' "$ff")
    fout=$(tools/run-micro.sh "$ff" "$fwant" "${RTLIBS[@]}" 2>/dev/null | grep -E '^(PASS|FAIL)' | tail -1)
    if [[ "$fout" != PASS* ]]; then
      say "✗ floor $f: ${fout:-no output}"; flr_bad=$((flr_bad+1)); continue
    fi
    fwat="${TMPDIR:-/tmp}/$f.wat"
    if ! grep -q "field offset unprovable: field '" "$fwat"; then
      say "✗ floor $f: the marker does not name its selector"; flr_bad=$((flr_bad+1)); continue
    fi
    grep -q "field offset unprovable: field '[^']*' on " "$fwat" \
      || { say "✗ floor $f: the marker does not name the receiver's row"; flr_bad=$((flr_bad+1)); }
  done
  if [[ "$flr_n" -eq 0 ]]; then
    say "✗ floor contract: no fixtures — an emit floor with no gate is a marker nobody reads"
    fail=1
  elif [[ "$flr_bad" -eq 0 ]]; then
    say "✓ floor contract: $flr_n unprovable-offset fixture(s) refuse and name what blocked them"
  else
    say "✗ floor contract: $flr_bad of $flr_n fixture(s) broke their contract"
    fail=1
  fi

  # 2d. THE RESIDUAL MARK — the projection must say which KIND of remainder
  #     it holds, and each fixture declares the kind it expects on a
  #     `// residual: proven|assumed` header. Both readings are gated,
  #     because a projection saying "assumed" everywhere or nowhere passes a
  #     one-sided check.
  #
  #     The header replaced a bare "must contain assumed" on 2026-09-03, and
  #     the reason is the finding rather than a convenience: the mark that
  #     check asserted was itself manufactured. absorb_into_residual bound
  #     `[] assumed` onto cells that knew nothing, so a decl's own row
  #     rendered "assumed" because a guess had been written on it. With that
  #     write gone a decl's unclosed row projects FREE — honestly — and a
  #     residual the call proves projects its fields. The gate now tests the
  #     projection's honesty in whichever state the graph is actually in.
  rm_n=0; rm_bad=0
  for rf in tests/rows/*.mn; do
    [[ -e "$rf" ]] || continue
    rm_n=$((rm_n+1))
    r=$(basename "$rf" .mn)
    rwant=$(sed -n '1s|^// expect: \([0-9]\+\)$|\1|p' "$rf")
    rkind=$(sed -nE 's#^// residual: (proven|assumed|free)$#\1#p' "$rf" | head -1)
    if [[ -z "$rkind" ]]; then
      say "✗ row $r: no '// residual: proven|assumed|free' header — the expected mark is the gate"
      rm_bad=$((rm_bad+1)); continue
    fi
    rout=$(tools/run-micro.sh "$rf" "$rwant" "${RTLIBS[@]}" 2>/dev/null | grep -E '^(PASS|FAIL)' | tail -1)
    [[ "$rout" == PASS* ]] || { say "✗ row $r: ${rout:-no output}"; rm_bad=$((rm_bad+1)); continue; }
    rproj=$(wt_run --dir . "$C/m2.wasm" "$rf" type pick 2>/dev/null)
    # The mark lives on the TYPE line; the Reason line below it names the
    # declaring node's file since 2026-09-23, and this fixture's own file is
    # `mn-assumed-residual` — matching the whole answer read the file name as
    # the mark.
    rproj="${rproj%%$'\n'*}"
    # Three states, not two. A remainder is PROVEN (rendered as its fields),
    # ASSUMED (rendered with the mark), or genuinely FREE — and the third was
    # invisible while absorb_into_residual stamped `[] assumed` onto cells that
    # knew nothing, which is what made "assumed" look like the only unproven
    # state there was.
    case "$rkind:$rproj" in
      assumed:*assumed*) ;;
      assumed:*) say "✗ row $r: declares an assumed remainder, projection does not mark one"; rm_bad=$((rm_bad+1)) ;;
      proven:*assumed*) say "✗ row $r: declares a proven remainder, projection marks it assumed"; rm_bad=$((rm_bad+1)) ;;
      proven:*'|'*) say "✗ row $r: declares a proven remainder, projection still shows an open row"; rm_bad=$((rm_bad+1)) ;;
      proven:*) ;;
      free:*assumed*) say "✗ row $r: declares a free remainder, projection marks it assumed — a guess was written on it"; rm_bad=$((rm_bad+1)) ;;
      free:*'|'*) ;;
      free:*) say "✗ row $r: declares a free remainder, projection shows it resolved"; rm_bad=$((rm_bad+1)) ;;
    esac
  done
  ctl=$(wt_run --dir . "$C/m2.wasm" tests/micros/mn-findtag.mn type pick 2>/dev/null)
  ctl="${ctl%%$'\n'*}"
  case "$ctl" in
    *assumed*) say "✗ row control: findtag's proven residual is marked assumed"; rm_bad=$((rm_bad+1)) ;;
    *region_id*) ;;
    *) say "✗ row control: findtag's residual did not project at all"; rm_bad=$((rm_bad+1)) ;;
  esac
  if [[ "$rm_n" -eq 0 ]]; then
    say "✗ residual mark: no fixtures — proven and assumed remainders need both sides"
    fail=1
  elif [[ "$rm_bad" -eq 0 ]]; then
    say "✓ residual mark: $rm_n assumed remainder(s) project as assumed; the proven control does not"
  else
    say "✗ residual mark: $rm_bad check(s) failed"
    fail=1
  fi
else
  say "✗ contract battery: the wheel did not build"
  fail=1
fi

# 3. The census — the medium's own verdict on its own source, RATCHETED.
#
#    Its meaning INVERTED at first light and the prose did not follow for six
#    days. The old justification (baseline, 2026-06-22): "a SHADOW, reported
#    not enforced ... the disposable seed's weaker inference lags, so a rising
#    count is the seed catching up to the wheel, expected progress" — and
#    "census_max no longer exists; it is read by nothing". THE SEED WAS DELETED
#    (7401c4b, 2026-07-10). boot IS the wheel. So m2.err is not a seed's shadow
#    of the wheel; it is the WHEEL's diagnostics about the WHEEL's OWN SOURCE —
#    every line a claim the medium makes about itself and does not believe.
#    Filed under the expired justification, that number hid a real dead-code bug
#    for six days: format.mn matched `NPipeExpr`, a constructor declared nowhere
#    (the real one is `PipeExpr`, types.mn:917), so format_chain's five arms
#    never matched and every chain fell to the `_` catch-all. The compiler said
#    so, exactly, with a span, six times.
#
#    So the census RATCHETS: errors may never RISE. This is the transport toward
#    the refusal law (PLAN §11), not its replacement — the endpoint is `mentl
#    check` on the wheel exiting 0, at which point emit can refuse on any error
#    and this counter DISSOLVES (§6's scaffold tier: it exists to be deleted).
#    Warnings are reported, not ratcheted: they are the format-lift backlog, and
#    the formatter erases them by construction.
#    Reads the ONE keyed boot(wheel) artifact (wt_m2_ensure — shared with
#    march/march-gate, .build/m2cache).
if C=$(wt_m2_ensure); then
  errors=$(grep -cE '(^|: )E_[A-Za-z_]+ error: ' "$C/m2.err")    # the wheel prefixes stages ('infer: E_…')
  warns=$(grep -cE '(^|: )(E_|W_|P_)[A-Za-z_]+ Warning: ' "$C/m2.err")
  max=$(grep -E '^census_errors_max:' "$BASELINE" | head -1 | cut -d: -f2 | tr -d ' ')
  say "· census: $errors errors / $warns warnings — the medium's own verdict on its own source"
  if [[ -n "$max" && "$errors" -gt "$max" ]]; then
    say "✗ census RATCHET: errors rose $max -> $errors. Every one is a claim the medium"
    say "  makes about its own source and does not believe. Fix them, or — if the rise is"
    say "  real and understood — raise census_errors_max in $BASELINE with the reason."
    fail=1
  elif [[ -n "$max" && "$errors" -lt "$max" ]]; then
    say "  ↓ census FELL $max -> $errors — lower census_errors_max in $BASELINE to hold it."
  fi
  # THE COMMENT-REFERENCE, FIELD-OFFSET AND UNPROVABLE-COMPARISON RATCHETS
  # LEFT THIS FILE on 2026-09-24, with the quiet gate below them. Each is a
  # bound in src/board.mn now, read by `mentl verify` off the compile's own
  # tally — the verb runs the compile's remainder, so it sees what emit
  # reports — and the repin runs that verb. Here they ran only at commit,
  # after the repin had blessed the wheel: one landing's repin passed and its
  # commit then refused five of them, and the cost was a fourth march
  # (`Hβ.board.verify-ratchets-live-beside-the-board`).
  # THE USE-AFTER-MOVE RATCHET IS RETIRED (2026-09-15) — the class is ARMED.
  # It counted T_UseAfterMove narrations on the wheel's own compile and held
  # them at ZERO so that diag_refuses' wheel-zero arming licence stayed
  # mechanical. The licence was satisfied at the Phase 4.1 landing and held
  # every board since, so the counter had become what it was waiting to
  # authorise: E_UseAfterMove refuses now, and a wheel carrying one cannot
  # compile at all. There is nothing left to count — a ratchet beside an
  # armed class is a weaker second copy of the refusal (the mode-33
  # precedent: the grep dies, the projection is the check).
  # PIN FRESHNESS (Hβ.march.boot-drifts-behind-clean-landings, 2026-08-17).
  # boot IS the pinned fixpoint, so when it matches current source
  # sha256(boot(wheel)) == sha256(boot) — the m2 this gate just built is the
  # boot binary again. When source moves ahead the two diverge, and that
  # divergence IS "boot is behind".
  #
  # This REPORTS, it does not refuse. A CLEAN m2 == m3 landing is correct and
  # genuinely needs no repin, so drift is legitimate; what was not legitimate
  # was that it stayed INVISIBLE. Boot sat four landings behind while every
  # gate in the frontier's BOOT suite printed green about a wheel that no
  # longer existed in source — §11 tripwire 4's worse sibling, since a green
  # reading of a stale artifact reads as evidence rather than as silence. One
  # line here is the whole counter-measure: the boot suite's verdict now says
  # which wheel it is a verdict ABOUT.
  if [ -f "$C/m2.wasm" ]; then
    pin_boot=$(sha256sum boot/mentl.wasm | cut -d' ' -f1)
    pin_m2=$(sha256sum "$C/m2.wasm" | cut -d' ' -f1)
    if [ "$pin_boot" = "$pin_m2" ]; then
      say "· pin freshness: boot IS the fixpoint of current source — boot-suite gates measure this wheel"
    else
      say "· pin freshness: boot is BEHIND current source (${pin_boot:0:8} vs m2 ${pin_m2:0:8})"
      say "  every boot-suite gate below is a verdict on the OLD wheel; repin to measure this one"
    fi
  fi
  # THE SCAFFOLD RATCHET (CLAUDE.md ⟳ — every scaffold's destiny is ABSORPTION
  # into a verb, never permanence). The loop prompt is imperative prose telling
  # an agent how to behave, which is the one thing PLAN §0 proves cannot
  # enforce itself; so what is measured is how much of the loop is still NOT
  # the medium's: the count of distinct tools/*.sh scripts the prompt must name
  # to run one iteration. Monotone DOWN, and it falls only when a VERB actually
  # replaces a script — rewording cannot move it, which is why this is the
  # metric and a line count is not. At zero the medium runs its own loop and
  # tools/loop-prompt.md is deleted rather than archived.
  csref=$(grep -ohE 'tools/[a-z0-9_-]+\.(sh|py)' tools/loop-prompt.md | sort -u | wc -l)
  srmax=$(grep -E '^loop_scaffold_refs_max:' "$BASELINE" | head -1 | cut -d: -f2 | tr -d ' ')
  say "· loop scaffolds: $csref script(s) the loop still needs — the medium's un-absorbed remainder"
  if [[ -n "$srmax" && "$csref" -gt "$srmax" ]]; then
    say "✗ scaffold RATCHET: rose $srmax -> $csref — the loop leans on MORE shell, not less;"
    say "  absorb the step into a verb or drop the reference."
    fail=1
  elif [[ -n "$srmax" && "$csref" -lt "$srmax" ]]; then
    say "  ↓ loop scaffolds FELL $srmax -> $csref — lower loop_scaffold_refs_max in $BASELINE to hold it."
  fi
  # The EFFECT-SEAM gate (Hβ.io.fs-close-op-is-bypassed, closed 2026-09-04).
  # An effect exists so a handler can intercept the operation. A caller that
  # reaches past the op to the implementation keeps the behaviour and loses
  # the seam — and loses it INVISIBLY, because the impls charge WASI while
  # the capability the handler names is Filesystem. So `with !Filesystem`
  # held over routes that created, wrote, renamed and unlinked files, and
  # the severance the handler's own comment promises ("drops path_open /
  # fd_close from that binary") would have qualified a file-writing binary.
  # Every fs_*_impl reference must be inside the handler that owns it
  # (pipeline) or its own definition (io). Anything else is a bypass.
  # SEEN RED at 3 before the fix: fs_close_impl answered main:425,
  # main:1826, mcp:128 beside its one legitimate site at pipeline:757.
  # The count is the medium's own refs answer, never a grep — a grep cannot
  # tell a call from a name written in a comment, which is the lesson the
  # imports facet already paid for.
  fsbp=0
  for impl in fs_exists_impl fs_read_file_impl fs_write_file_impl fs_mkdir_impl \
              fs_open_impl fs_create_impl fs_close_impl fs_unlink_impl fs_rename_impl; do
    n=$(wt_run --dir . "$C/m2.wasm" src/main.mn refs of "$impl" 2>/dev/null \
        | grep -oE '^  at [a-z_/]+:' | grep -vcE '^  at (pipeline|io):' || true)
    fsbp=$((fsbp + n))
  done
  fsmax=$(grep -E '^fs_impl_bypass_max:' "$BASELINE" | head -1 | cut -d: -f2 | tr -d ' ')
  say "· effect seam: $fsbp filesystem impl call(s) outside the handler that owns them"
  if [[ -n "$fsmax" && "$fsbp" -gt "$fsmax" ]]; then
    say "✗ effect-seam RATCHET: impl bypasses rose $fsmax -> $fsbp — a caller reached past the op; the handler can no longer see the operation and the row stops naming it."
    fail=1
  elif [[ -n "$fsmax" && "$fsbp" -lt "$fsmax" ]]; then
    say "  ↓ effect seam TIGHTENED $fsmax -> $fsbp — lower fs_impl_bypass_max in $BASELINE to hold it."
  fi
  # The SUGAR VOCABULARY contract (Hβ.driver.link-is-reachability's seed).
  # The prelude names the compiler MINTS as literals are the seed set a
  # demand-link must carry: reachability from written names alone would miss
  # them, so the day that set changes is the day the seed must change with
  # it. This is the SIZE of the intersection between what lib/ publishes and
  # what the five desugar-capable modules quote, held EXACT.
  # WHAT IT CATCHES, stated precisely because the first draft of this comment
  # oversold it and the RED tests said so: a name ENTERING or LEAVING the
  # vocabulary — a new name-keyed dependency on the prelude that nobody
  # reviewed (seen RED: 43 -> 44), or the last mint of a name going away.
  # WHAT IT DOES NOT CATCH: one broken mint among several of the same name,
  # because this is set membership, not occurrence counting (measured — a
  # deliberately corrupted "list_to_flat" left the count at 43). And a
  # prelude decl RENAMED outright breaks the wheel's own compile long before
  # this line runs, so that case never reaches here either.
  # The set is complete as a literal scan: all 55 SPLICED names were measured
  # compiler-synthesized (__hstate_, __fb_, lambda_, tuple_{handle} …), none
  # able to collide with prelude vocabulary.
  sv_pre=$(mktemp); sv_min=$(mktemp)
  { grep -hoE '^fn [a-z_][A-Za-z0-9_]*' lib/prelude.mn lib/*.mn | sed 's/^fn //'
    grep -hoE '^type [A-Z][A-Za-z0-9_]*|^  = [A-Z][A-Za-z0-9_]*|^  \| [A-Z][A-Za-z0-9_]*' lib/prelude.mn lib/*.mn | sed -E 's/^(type|  = |  \| )//'
  } | sort -u > "$sv_pre"
  grep -hoE '"[A-Za-z_][A-Za-z0-9_]*"' src/lower.mn src/backends/wasm.mn src/parser.mn src/infer.mn src/pipeline.mn | tr -d '"' | sort -u > "$sv_min"
  csugar=$(comm -12 "$sv_pre" "$sv_min" | wc -l)
  rm -f "$sv_pre" "$sv_min"
  svmax=$(grep -E '^desugar_vocabulary:' "$BASELINE" | head -1 | cut -d: -f2 | tr -d ' ')
  say "· sugar vocabulary: $csugar prelude name(s) minted by the desugar — the lowering's name-keyed contract with lib/"
  if [[ -n "$svmax" && "$csugar" != "$svmax" ]]; then
    say "✗ sugar-vocabulary CONTRACT: $svmax -> $csugar — the demand-link's seed set changed. A prelude name entered or left the desugar vocabulary; re-derive the set, decide whether the seed follows it, and move the baseline in the same commit."
    fail=1
  fi
  # THE BOARD — the medium's own standing bounds, read from its own graph.
  #
  # This was TWELVE invocations of the medium: `query src/main.mn "census
  # eta"`, `"census effectful-lambda"`, the nine drift shapes, the open
  # receiver — each a whole wheel judgment thrown away after a regex read one
  # integer out of its rendering, each compared against a number grepped from
  # verify-baseline.txt. Three re-derivations of one fact, twelve times over.
  # `mentl verify` judges ONCE and reads every count off that graph, with each
  # bound and its justification living together in src/board.mn where
  # `mentl why` can walk them. MEASURED at the landing: 3.63s against 42.37s,
  # and the 11.7x is the side effect — the law is that twelve compiles were
  # twelve re-derivations of one graph.
  #
  # The verb REFUSES on a breach (nonzero exit) and refuses on an unread weave
  # rather than reporting twelve confident zeros — the vacuity it was caught
  # committing on its first run, which is `Hβ.query.unreadable-source-refusal`
  # at a second surface.
  bout=$(wt_run --dir . "$C/m2.wasm" src/main.mn verify 2>/dev/null)
  brc=$?
  printf '%s\n' "$bout" | sed -n 's/^  /· board /p'
  if [[ "$brc" -ne 0 ]]; then
    say "✗ BOARD: a bound the medium keeps about itself was breached (mentl verify exit $brc)."
    fail=1
  elif ! printf '%s' "$bout" | grep -q 'bound(s) hold'; then
    say "✗ BOARD: mentl verify answered nothing — the projection is broken, not clean."
    fail=1
  fi
  # (The manifest gate — `mentl check` on the wheel, grepped for
  # E_MissingVariable — is absorbed: the board above REFUSES a weave that
  # does not judge clean, which holds every error class at zero on the import
  # DAG rather than one of them. The canon.mn class it was born for, a module
  # imported by nobody, is an E_MissingVariable that refusal already sees.)
else
  say "✗ compiler TRAPPED compiling the wheel (tail $WT_M2CACHE/m2.err):"; tail -3 "$WT_M2CACHE/m2.err"; fail=1
fi

# 5. Doc-truth — the docs' claims that CAN be checked against the artifact
#    ARE (pin shas, ledger pins, named commands). Prose drifts; this is the
#    mechanical floor under it (tools/doc-truth.sh; dissolves into
#    docs-as-projection + mentl audit).
if ! bash tools/doc-truth.sh >/dev/null 2>&1; then
  say "✗ doc-truth: a doc claims what the artifact refutes —"
  bash tools/doc-truth.sh 2>&1 | sed 's/^/  /'
  fail=1
else
  say "· doc-truth: pin shas, ledger pins, and named commands verify against the artifact"
fi

if [[ "$fail" -ne 0 ]]; then
  say ""
  say "verify: the gate failed — a micro regressed, the wheel did not compile, or the"
  say "census ratchet caught the medium making more claims about itself that it does"
  say "not believe. Fix it (carry the handle, read live; rewrite in residue form)."
  exit 1
fi
say "verify: thesis invariants hold."
# Stamp the green — keyed on the state captured at ENTRY, so an edit made
# while the battery ran invalidates (the next run sees a different key).
printf '%s' "$STATE_KEY" > "$GATE_STAMP"
say "· stamped $GATE_STAMP (re-runs on this exact state answer instantly)"
exit 0
