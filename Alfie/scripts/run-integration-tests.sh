#!/bin/bash

# Boots a local BFF, runs the BFFIntegrationTests target against it, and tears the BFF down on exit.
# ALFMOB-335.

set -o pipefail
set -m  # job control: backgrounded BFF becomes its own process group leader so we can kill the whole tree

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
TEST_PLAN="AlfieIntegration"
TEST_LOG="/tmp/alfie_integration_test.log"

# BFF location + boot command. Override ALFIE_BFF_START_CMD once the BFF team confirms the canonical
# local-run command (TBD per ALFMOB-335 Open Q #1; `npm run start:dev` is the current assumption).
BFF_PATH="${ALFIE_BFF_PATH:-$PROJECT_DIR/../Alfie-BFF}"
BFF_START_CMD="${ALFIE_BFF_START_CMD:-npm run start:dev}"
export ALFIE_BFF_BASE_URL="${ALFIE_BFF_BASE_URL:-http://localhost:3000}"  # origin only; service appends /graphql
ALFIE_BFF_BASE_URL="${ALFIE_BFF_BASE_URL%/}"  # drop any trailing slash so we never build `//graphql`
BFF_PORT="${ALFIE_BFF_BASE_URL##*:}"
GRAPHQL_URL="$ALFIE_BFF_BASE_URL/graphql"
READINESS_TIMEOUT=60

fail() { echo "❌ $1"; exit 1; }

# --- Prerequisites -----------------------------------------------------------
command -v node >/dev/null 2>&1 || fail "node not found — install Node to run the BFF."
command -v npm  >/dev/null 2>&1 || fail "npm not found — install Node/npm to run the BFF."
[ -d "$BFF_PATH" ] || fail "BFF repo not found at '$BFF_PATH'. Clone Alfie-BFF as a sibling or set ALFIE_BFF_PATH."

if [ ! -d "$BFF_PATH/node_modules" ]; then
    echo "📦 Installing BFF dependencies (npm ci) in $BFF_PATH..."
    ( cd "$BFF_PATH" && npm ci ) || fail "npm ci failed in $BFF_PATH"
fi

# --- Pre-flight: refuse to reuse a stale server ------------------------------
if lsof -i ":$BFF_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    fail "Port $BFF_PORT is already in use. Stop the process holding it before running integration tests."
fi

# --- Boot the BFF in its own process group -----------------------------------
echo "🚀 Booting BFF: $BFF_START_CMD (cwd: $BFF_PATH)"
( cd "$BFF_PATH" && exec $BFF_START_CMD ) &
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

# --- Discover a simulator (same approach as test-for-verification.sh) ---------
DESTINATION='platform=iOS Simulator,name=Any iOS Simulator Device'
echo "🧪 Running $TEST_PLAN test plan..."
xcodebuild test \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -testPlan "$TEST_PLAN" \
    -destination "$DESTINATION" 2>&1 | tee "$TEST_LOG"
TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -ne 0 ] && grep -q "Unable to find a device matching the provided destination" "$TEST_LOG"; then
    echo "⚠️  Generic destination failed, trying a specific iPhone simulator..."
    SIMULATOR_ID=$(xcrun simctl list devices available | grep -E "iPhone" | grep -v "unavailable" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    [ -n "$SIMULATOR_ID" ] || fail "No iPhone simulator found. Install one via Xcode."
    echo "📱 Using simulator: $SIMULATOR_ID"
    xcodebuild test \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -testPlan "$TEST_PLAN" \
        -destination "id=$SIMULATOR_ID" 2>&1 | tee "$TEST_LOG"
    TEST_RESULT=${PIPESTATUS[0]}
fi

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ INTEGRATION TESTS PASSED"
else
    echo "❌ INTEGRATION TESTS FAILED (log: $TEST_LOG)"
fi
exit $TEST_RESULT
