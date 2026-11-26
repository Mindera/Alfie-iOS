# Sourced, not run. What CI adds to a run: extra xcodebuild flags (ALFIE_XCODEBUILD_ARGS), stage
# output folded in the GitHub Actions job log and a stage result table in its job summary.
# shellcheck disable=SC2034
read -r -a XCODEBUILD_ARGS <<< "${ALFIE_XCODEBUILD_ARGS:-}"

log_group() { [ -z "$GITHUB_ACTIONS" ] || echo "::group::$1"; }
log_endgroup() { [ -z "$GITHUB_ACTIONS" ] || echo "::endgroup::"; }

# run_logged <group title> <log file> <command...>: returns the command's exit code.
run_logged() {
    local title="$1" log="$2" result
    shift 2
    log_group "$title"
    "$@" 2>&1 | tee "$log"
    result=${PIPESTATUS[0]}
    log_endgroup
    return "$result"
}

summarize_stage() {
    [ -n "${GITHUB_STEP_SUMMARY:-}" ] || return 0
    local result
    case "$2" in
        0) result="✅ passed" ;;
        skipped) result="⏭️ skipped" ;;
        not-run) result="❌ did not run" ;;
        *) result="❌ failed" ;;
    esac
    grep -q '^| Stage | Result |$' "$GITHUB_STEP_SUMMARY" 2>/dev/null ||
        printf '| Stage | Result |\n| --- | --- |\n' >> "$GITHUB_STEP_SUMMARY"
    echo "| $1 | $result |" >> "$GITHUB_STEP_SUMMARY"
}
