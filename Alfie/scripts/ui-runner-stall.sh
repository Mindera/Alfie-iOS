# Sourced, not run. Evidence for a slow UI test runner start-up, the same locally and on CI:
# records the simulator's system log while the plan runs, samples the test process each time it
# prints nothing for ALFIE_UI_SILENCE_THRESHOLD seconds, and reports the runner's start-up time.
# The evidence is kept when start-up took over ALFIE_UI_STARTUP_THRESHOLD seconds or the plan
# failed, and deleted otherwise. Both thresholds default to 120. On GitHub Actions a slow start-up
# also sets the step output ui_runner_stalled=true, which the workflow uploads on.

UI_SIMULATOR_LOG="/tmp/alfie_ui_simulator.log"
UI_SAMPLE_PREFIX="/tmp/alfie_ui_xcodebuild_sample_"
UI_STARTUP_FILE="/tmp/alfie_ui_runner_startup"
UI_STARTUP_THRESHOLD="${ALFIE_UI_STARTUP_THRESHOLD:-120}"
UI_SILENCE_THRESHOLD="${ALFIE_UI_SILENCE_THRESHOLD:-120}"
UI_RUNNER_STARTED_PATTERN="Runner\[.*Running tests\.\.\.|^Test Suite '.*' started"
UI_SIMULATOR_LOG_PID=""
UI_WATCH_PID=""
UI_PLAN_STARTED_AT=0

watch_runner_start() {
    local log="$1" process="$2" parent="$3"
    local started=$SECONDS quiet_since=$SECONDS last_size=0 samples=0 size pid
    while sleep 1; do
        if [ ! -s "$UI_STARTUP_FILE" ] && grep -qE "$UI_RUNNER_STARTED_PATTERN" "$log" 2>/dev/null; then
            echo $((SECONDS - started)) > "$UI_STARTUP_FILE"
        fi
        size="$(stat -f %z "$log" 2>/dev/null || echo 0)"
        if [ "$size" != "$last_size" ]; then
            last_size="$size"
            quiet_since=$SECONDS
        elif [ $((SECONDS - quiet_since)) -ge "$UI_SILENCE_THRESHOLD" ]; then
            pid="$(pgrep -P "$parent" -x "$process" | head -n 1)"
            if [ -n "$pid" ]; then
                samples=$((samples + 1))
                sample "$pid" 5 -file "$UI_SAMPLE_PREFIX$samples.log" >/dev/null 2>&1
            fi
            quiet_since=$SECONDS
        fi
    done
}

# start_stall_capture <simulator udid> <test log> [process name]
start_stall_capture() {
    local simulator="$1" log="$2" process="${3:-xcodebuild}"
    rm -f "$UI_SIMULATOR_LOG" "$UI_STARTUP_FILE" "$UI_SAMPLE_PREFIX"*.log
    : > "$log"
    UI_PLAN_STARTED_AT=$SECONDS
    xcrun simctl spawn "$simulator" log stream --level info --style compact > "$UI_SIMULATOR_LOG" 2>&1 &
    UI_SIMULATOR_LOG_PID=$!
    watch_runner_start "$log" "$process" $$ &
    UI_WATCH_PID=$!
}

kill_stall_capture() {
    local pid
    for pid in $UI_WATCH_PID $UI_SIMULATOR_LOG_PID; do
        kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
    done
    UI_WATCH_PID=""
    UI_SIMULATOR_LOG_PID=""
}

# stop_stall_capture <plan name> <plan exit code>
stop_stall_capture() {
    local plan="$1" plan_result="$2" elapsed=$((SECONDS - UI_PLAN_STARTED_AT)) startup
    kill_stall_capture
    startup="$(cat "$UI_STARTUP_FILE" 2>/dev/null)"
    rm -f "$UI_STARTUP_FILE"
    if [ -n "$startup" ]; then
        echo "⏱️  $plan runner start-up: ${startup}s"
    else
        echo "⏱️  $plan runner did not start (${elapsed}s)"
        startup=$elapsed
    fi

    if [ "$startup" -gt "$UI_STARTUP_THRESHOLD" ]; then
        echo "⚠️  $plan runner start-up over ${UI_STARTUP_THRESHOLD}s; evidence kept:"
        ls "$UI_SIMULATOR_LOG" "$UI_SAMPLE_PREFIX"*.log 2>/dev/null | sed 's/^/   /'
        [ -z "$GITHUB_OUTPUT" ] || echo "ui_runner_stalled=true" >> "$GITHUB_OUTPUT"
    elif [ "$plan_result" -eq 0 ]; then
        rm -f "$UI_SIMULATOR_LOG" "$UI_SAMPLE_PREFIX"*.log
    fi
}
