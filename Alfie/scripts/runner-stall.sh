# Sourced, not run. Evidence for a test runner that is slow to start or goes silent, the same
# locally and on CI: records the simulator's system log while a plan runs, samples the test process
# each time it prints nothing for ALFIE_RUNNER_SILENCE_THRESHOLD seconds, and reports the runner's
# start-up time. The evidence (/tmp/alfie_<stage>_simulator.log, /tmp/alfie_<stage>_xcodebuild_sample_<n>.log)
# is kept when start-up took over ALFIE_RUNNER_STARTUP_THRESHOLD seconds, a sample was taken or the
# plan failed, and deleted otherwise. Both thresholds default to 120. On GitHub Actions kept
# evidence of a passing plan also sets the step output runner_stalled=true, which the workflow
# uploads on.

STALL_STARTUP_FILE="/tmp/alfie_runner_startup"
STALL_STARTUP_THRESHOLD="${ALFIE_RUNNER_STARTUP_THRESHOLD:-120}"
STALL_SILENCE_THRESHOLD="${ALFIE_RUNNER_SILENCE_THRESHOLD:-120}"
STALL_RUNNER_STARTED_PATTERN="Runner\[.*Running tests\.\.\.|^Test Suite '.*' started"
STALL_PLAN=""
STALL_SIMULATOR_LOG=""
STALL_SAMPLE_PREFIX=""
STALL_SIMULATOR_LOG_PID=""
STALL_WATCH_PID=""
STALL_PLAN_STARTED_AT=0

watch_runner_start() {
    local log="$1" process="$2" parent="$3"
    local started=$SECONDS quiet_since=$SECONDS last_size=0 samples=0 size pid
    while sleep 1; do
        if [ ! -s "$STALL_STARTUP_FILE" ] && grep -qE "$STALL_RUNNER_STARTED_PATTERN" "$log" 2>/dev/null; then
            echo $((SECONDS - started)) > "$STALL_STARTUP_FILE"
        fi
        size="$(stat -f %z "$log" 2>/dev/null || echo 0)"
        if [ "$size" != "$last_size" ]; then
            last_size="$size"
            quiet_since=$SECONDS
        elif [ $((SECONDS - quiet_since)) -ge "$STALL_SILENCE_THRESHOLD" ]; then
            pid="$(pgrep -P "$parent" -x "$process" | head -n 1)"
            if [ -n "$pid" ]; then
                samples=$((samples + 1))
                sample "$pid" 5 -file "$STALL_SAMPLE_PREFIX$samples.log" >/dev/null 2>&1
            fi
            quiet_since=$SECONDS
        fi
    done
}

start_stall_capture() {
    local stage="$1" simulator="$3" log="$4"
    STALL_PLAN="$2"
    STALL_SIMULATOR_LOG="/tmp/alfie_${stage}_simulator.log"
    STALL_SAMPLE_PREFIX="/tmp/alfie_${stage}_xcodebuild_sample_"
    rm -f "$STALL_SIMULATOR_LOG" "$STALL_STARTUP_FILE" "$STALL_SAMPLE_PREFIX"*.log
    : > "$log"
    STALL_PLAN_STARTED_AT=$SECONDS
    xcrun simctl spawn "$simulator" log stream --level info --style compact \
        --predicate 'process != "apsd"' > "$STALL_SIMULATOR_LOG" 2>&1 &
    STALL_SIMULATOR_LOG_PID=$!
    watch_runner_start "$log" xcodebuild $$ &
    STALL_WATCH_PID=$!
}

kill_stall_capture() {
    local pid
    for pid in $STALL_WATCH_PID $STALL_SIMULATOR_LOG_PID; do
        kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
    done
    STALL_WATCH_PID=""
    STALL_SIMULATOR_LOG_PID=""
}

stop_stall_capture() {
    local plan_result="$1" elapsed=$((SECONDS - STALL_PLAN_STARTED_AT)) startup
    kill_stall_capture
    startup="$(cat "$STALL_STARTUP_FILE" 2>/dev/null)"
    rm -f "$STALL_STARTUP_FILE"
    if [ -n "$startup" ]; then
        echo "⏱️  $STALL_PLAN runner start-up: ${startup}s"
    else
        echo "⏱️  $STALL_PLAN runner did not start (${elapsed}s)"
        startup=$elapsed
    fi

    if [ "$startup" -gt "$STALL_STARTUP_THRESHOLD" ] || ls "$STALL_SAMPLE_PREFIX"*.log >/dev/null 2>&1; then
        echo "⚠️  $STALL_PLAN runner start-up over ${STALL_STARTUP_THRESHOLD}s or silent for ${STALL_SILENCE_THRESHOLD}s; evidence kept:"
        ls "$STALL_SIMULATOR_LOG" "$STALL_SAMPLE_PREFIX"*.log 2>/dev/null | sed 's/^/   /'
        [ -z "$GITHUB_OUTPUT" ] || echo "runner_stalled=true" >> "$GITHUB_OUTPUT"
    elif [ "$plan_result" -eq 0 ]; then
        rm -f "$STALL_SIMULATOR_LOG" "$STALL_SAMPLE_PREFIX"*.log
    fi
}
