# Sourced, not run. What CI adds to a run: extra xcodebuild flags (ALFIE_XCODEBUILD_ARGS), stage
# output folded in the GitHub Actions job log, stage and phase durations in the log, and the runner's
# size plus a stage result table in its job summary.
# shellcheck disable=SC2034
read -r -a XCODEBUILD_ARGS <<< "${ALFIE_XCODEBUILD_ARGS:-}"

log_group() { [ -z "$GITHUB_ACTIONS" ] || echo "::group::$1"; }
log_endgroup() { [ -z "$GITHUB_ACTIONS" ] || echo "::endgroup::"; }

load_average() { uptime | sed 's/.*load average/load average/'; }

log_runner() {
    local runner
    runner="🖥️  Runner: $(sysctl -n hw.ncpu) CPU, $(($(sysctl -n hw.memsize) / 1073741824)) GB RAM, $(load_average)"
    echo "$runner"
    [ -z "${GITHUB_STEP_SUMMARY:-}" ] || printf '%s\n' "$runner" >> "$GITHUB_STEP_SUMMARY"
}

# log_elapsed <label> <value of $SECONDS when it started>
log_elapsed() { echo "⏱️  $1: $((SECONDS - $2))s ($(load_average))"; }

# run_logged <group title> <log file> <command...>: returns the command's exit code and prints how
# long the command took, with the second each xcodebuild milestone was first printed at.
run_logged() {
    local title="$1" log="$2" result started=$SECONDS milestones
    shift 2
    log_group "$title"
    "$@" 2>&1 | tee "$log" | MILESTONES="$log.milestones" perl -ne '
        BEGIN {
            $| = 1;
            $started = time;
            @milestones = (
                ["xcodebuild started", qr/^Command line invocation:/],
                ["package resolution started", qr/^Resolve Package Graph/],
                ["packages resolved", qr/^Resolved source packages:/],
                ["compile started", qr/^note: Building targets in dependency order/],
                ["first test suite started", qr/^Test Suite .* started/],
            );
        }
        print;
        for $m (@milestones) { $at{$m->[0]} //= time - $started if /$m->[1]/ }
        END {
            open F, ">", $ENV{MILESTONES};
            print F join ", ", map { "$_->[0] at $at{$_->[0]}s" } grep { defined $at{$_->[0]} } @milestones;
        }'
    result=${PIPESTATUS[0]}
    log_endgroup
    milestones="$(cat "$log.milestones" 2>/dev/null)"
    rm -f "$log.milestones"
    echo "⏱️  $title: $((SECONDS - started))s${milestones:+ ($milestones)}, $(load_average)"
    return "$result"
}

# summarize_stage <stage> <exit code | skipped | not-run> [<seconds>]
summarize_stage() {
    [ -n "${GITHUB_STEP_SUMMARY:-}" ] || return 0
    local result
    case "$2" in
        0) result="✅ passed" ;;
        skipped) result="⏭️ skipped" ;;
        not-run) result="❌ did not run" ;;
        *) result="❌ failed" ;;
    esac
    grep -q '^| Stage | Result | Duration |$' "$GITHUB_STEP_SUMMARY" 2>/dev/null ||
        printf '\n| Stage | Result | Duration |\n| --- | --- | --- |\n' >> "$GITHUB_STEP_SUMMARY"
    echo "| $1 | $result | ${3:+$3s} |" >> "$GITHUB_STEP_SUMMARY"
}
