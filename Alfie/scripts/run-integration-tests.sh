#!/bin/bash

# Builds and boots the Mock BFF, runs one build-for-testing, then the AlfieIntegration and AlfieUI
# test plans against it without rebuilding, and tears the BFF down on exit. --skip-build reuses the
# products of an earlier build-for-testing (verify.sh's build step).
# ALFIE_BFF_START_CMD overrides the start command (e.g. a Live BFF platform); set
# ALFIE_BFF_PLATFORM=mock alongside it if the override still boots the Mock BFF.
# Every run writes the BFF checkout's node_modules and dist (yarn install + build); its git refs are
# never touched.

set -o pipefail
set -m  # job control: backgrounded BFF becomes its own process group leader so we can kill the whole tree

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
BUILD_LOG="/tmp/alfie_bff_tests_build.log"

SKIP_BUILD=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-build) SKIP_BUILD=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

source "$(dirname "${BASH_SOURCE[0]}")/simulator.sh"

BFF_PATH="${ALFIE_BFF_PATH:-$PROJECT_DIR/../Alfie-BFF}"
export ALFIE_BFF_BASE_URL="${ALFIE_BFF_BASE_URL:-http://localhost:3000}"  # origin only; service appends /graphql
ALFIE_BFF_BASE_URL="${ALFIE_BFF_BASE_URL%/}"  # drop any trailing slash so we never build `//graphql`
# Port for the stale-server preflight: explicit :port if present, else the scheme default.
_hostport="${ALFIE_BFF_BASE_URL#*://}"  # strip scheme
_hostport="${_hostport%%/*}"            # strip any path
case "$_hostport" in
    *:*) BFF_PORT="${_hostport##*:}" ;;
    *)   case "$ALFIE_BFF_BASE_URL" in https://*) BFF_PORT=443 ;; *) BFF_PORT=80 ;; esac ;;
esac
GRAPHQL_URL="$ALFIE_BFF_BASE_URL/graphql"
READINESS_TIMEOUT=60

fail() { echo "❌ $1"; exit 1; }

warn_if_bff_checkout_differs_from_main() {
    git -C "$BFF_PATH" rev-parse --git-dir >/dev/null 2>&1 || return 0

    local branch
    branch="$(git -C "$BFF_PATH" symbolic-ref --short -q HEAD || echo "detached HEAD")"
    if [ "$branch" != "main" ]; then
        echo "⚠️  BFF checkout at $BFF_PATH is on '$branch', not main; CI tests against main."
    fi

    local remote_main
    remote_main="$(GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=5" \
        git -C "$BFF_PATH" ls-remote origin refs/heads/main 2>/dev/null | cut -f1)"
    if [ -n "$remote_main" ] && ! git -C "$BFF_PATH" merge-base --is-ancestor "$remote_main" HEAD 2>/dev/null; then
        echo "⚠️  BFF checkout at $BFF_PATH is behind origin/main ($remote_main); CI tests against main."
    fi
}

# --- Prerequisites -----------------------------------------------------------
command -v node >/dev/null 2>&1 || fail "node not found — install Node to run the BFF."
command -v yarn >/dev/null 2>&1 || fail "yarn not found — install it (corepack enable, or brew install yarn) to build the BFF."
[ -d "$BFF_PATH" ] || fail "BFF repo not found at '$BFF_PATH'. Clone Alfie-BFF as a sibling or set ALFIE_BFF_PATH."

if [ -n "$ALFIE_BFF_START_CMD" ]; then
    BFF_START_CMD="$ALFIE_BFF_START_CMD"
    ALFIE_BFF_PLATFORM="${ALFIE_BFF_PLATFORM:-custom}"
else
    command -v openssl >/dev/null 2>&1 || fail "openssl not found — needed for the Mock BFF's throwaway JWT secret."
    # Auth disabled and a throwaway JWT secret: no customer can log in on the mock, so nothing is
    # signed that outlives the run. Explicit env wins over the BFF's own .env.
    BFF_JWT_SECRET="$(openssl rand -hex 32)"
    [ -n "$BFF_JWT_SECRET" ] || fail "openssl rand produced no JWT secret."
    export BFF_JWT_SECRET
    BFF_START_CMD="PLATFORM=mock AUTH_DISABLED=true PORT=$BFF_PORT MOCK_ASSETS_BASE_URL=$(printf '%q' "$ALFIE_BFF_BASE_URL") node dist/main"
    ALFIE_BFF_PLATFORM=mock
fi
export TEST_RUNNER_ALFIE_BFF_PLATFORM="$ALFIE_BFF_PLATFORM"

warn_if_bff_checkout_differs_from_main
echo "🔖 BFF: $(git -C "$BFF_PATH" rev-parse HEAD 2>/dev/null || echo unknown) ($BFF_PATH)"
echo "🧩 BFF platform: $ALFIE_BFF_PLATFORM"

echo "📦 Installing and building the BFF (yarn)..."
( cd "$BFF_PATH" && yarn install --frozen-lockfile && yarn build ) || fail "yarn install/build failed in $BFF_PATH"

# --- Pre-flight: refuse to reuse a stale server ------------------------------
if lsof -i ":$BFF_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    fail "Port $BFF_PORT is already in use. Stop the process holding it before running integration tests."
fi

# --- Boot the BFF in its own process group -----------------------------------
echo "🚀 Booting BFF: $BFF_START_CMD (cwd: $BFF_PATH)"
# Run via `bash -c` so ALFIE_BFF_START_CMD overrides with quoting/compound commands work; for a
# single command bash execs it directly, so it still becomes the process-group leader.
( cd "$BFF_PATH" && exec bash -c "$BFF_START_CMD" ) &
BFF_PGID=$!
# Kill the whole process group (npm spawns child node procs that a plain `kill $PID` would orphan).
trap 'echo "🧹 Stopping BFF..."; kill -- -"$BFF_PGID" 2>/dev/null' EXIT INT TERM

# --- Wait for GraphQL readiness ----------------------------------------------
echo "⏳ Waiting for GraphQL at $GRAPHQL_URL (timeout ${READINESS_TIMEOUT}s)..."
ready=false
for _ in $(seq 1 "$READINESS_TIMEOUT"); do
    if ! kill -0 "$BFF_PGID" 2>/dev/null; then
        fail "BFF process exited before becoming ready. Check the BFF logs."
    fi
    # A POST with a trivial query uniquely identifies a live GraphQL endpoint (a GET returns
    # 200-landing/404/405 inconsistently).
    body="$(curl -s -X POST "$GRAPHQL_URL" \
        -H 'Content-Type: application/json' \
        --data '{"query":"{__typename}"}' 2>/dev/null)"
    if echo "$body" | grep -q '"data"\|"errors"'; then
        ready=true
        break
    fi
    sleep 1
done
[ "$ready" = true ] || fail "BFF did not become ready at $GRAPHQL_URL within ${READINESS_TIMEOUT}s."
echo "✅ BFF is ready."

# --- Simulator: the pinned iPhone unit tests use, else the newest -----------
SIMULATOR_ID="$(preferred_iphone_udid)"
[ -n "$SIMULATOR_ID" ] || fail "No iPhone simulator found. Install one via Xcode."
DESTINATION="id=$SIMULATOR_ID"
echo "📱 Using simulator: $(simulator_name "$SIMULATOR_ID") ($SIMULATOR_ID)"

if [ "$SKIP_BUILD" = true ]; then
    echo "⏭️  Skipping build-for-testing (reusing the earlier build)"
else
    echo "🔨 build-for-testing (log: $BUILD_LOG)..."
    xcodebuild build-for-testing \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" 2>&1 | tee "$BUILD_LOG"
    [ "${PIPESTATUS[0]}" -eq 0 ] || fail "build-for-testing failed (log: $BUILD_LOG)"
fi

# Guards against a false green: xcodebuild exits 0 when every test XCTSkips, so zero executed test
# cases fails the plan.
run_plan() {
    local plan="$1" log="$2" bundle="$3"
    echo ""
    echo "🧪 Running $plan test plan (test-without-building)..."
    rm -rf "$bundle"
    xcodebuild test-without-building \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -testPlan "$plan" \
        -destination "$DESTINATION" \
        -resultBundlePath "$bundle" 2>&1 | tee "$log"
    local result=${PIPESTATUS[0]}

    if [ "$result" -ne 0 ]; then
        echo "❌ $plan TESTS FAILED (log: $log, results: $bundle)"
        return "$result"
    fi
    local executed
    executed=$(grep -cE "Test Case '.*' (passed|failed)" "$log" || true)
    if [ "$executed" -eq 0 ]; then
        echo "❌ $plan TESTS DID NOT RUN — 0 tests executed (all skipped)."
        echo "   Every test skipped; see the skip reasons in $log."
        return 1
    fi
    echo "✅ $plan TESTS PASSED ($executed executed)"
}

run_plan AlfieIntegration /tmp/alfie_integration_test.log /tmp/alfie_integration_test.xcresult
INTEGRATION_RESULT=$?
# A cold-booting simulator refuses to launch the UI test runner ("Busy: Application failed preflight
# checks"), so wait for the boot to finish first.
if xcrun simctl bootstatus "$SIMULATOR_ID" -b >/dev/null; then
    run_plan AlfieUI /tmp/alfie_ui_test.log /tmp/alfie_ui_test.xcresult
    UI_RESULT=$?
else
    echo "❌ Simulator $SIMULATOR_ID did not boot; AlfieUI not run."
    UI_RESULT=1
fi

[ "$INTEGRATION_RESULT" -eq 0 ] && [ "$UI_RESULT" -eq 0 ] && exit 0
exit 1
