#!/bin/bash

# Test script for AI agents to verify code changes
# Selects an iPhone simulator on the pinned iOS major so snapshot references stay comparable

set -o pipefail  # Ensure pipe returns the exit code of the failing command

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
TEST_LOG="/tmp/alfie_test.log"
# Snapshot references are recorded on this iOS major; asserting on another major shifts rendering.
SNAPSHOT_OS_MAJOR="26"

# Parse arguments
TEST_FILTER=""
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --filter|-f)
            TEST_FILTER="$2"
            shift 2
            ;;
        --skip-build|-s)
            SKIP_BUILD=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -f, --filter PATTERN   Run only tests matching PATTERN (e.g., 'CoreTests', 'LocalizationTests')"
            echo "  -s, --skip-build       Skip the build phase (test-without-building)"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Run all tests"
            echo "  $0 --filter CoreTests        # Run only CoreTests"
            echo "  $0 --filter 'test_wishlist'  # Run tests matching 'test_wishlist'"
            echo "  $0 --skip-build              # Run tests without rebuilding"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🧪 Running Alfie iOS tests..."
echo "📂 Project: $PROJECT_FILE"
echo "📱 Scheme: $SCHEME"
if [ -n "$TEST_FILTER" ]; then
    echo "🔍 Filter: $TEST_FILTER"
fi
if [ "$SKIP_BUILD" = true ]; then
    echo "⏭️  Skipping build phase"
fi
echo ""

# Build test action
if [ "$SKIP_BUILD" = true ]; then
    TEST_ACTION="test-without-building"
else
    TEST_ACTION="test"
fi

# Build filter argument
FILTER_ARG=""
if [ -n "$TEST_FILTER" ]; then
    FILTER_ARG="-only-testing:$TEST_FILTER"
fi

# Fail fast if a snapshot test was committed in record mode — record mode always fails the
# assertion anyway, but catching it here costs a second instead of a full test run.
if grep -rnE 'record:[[:space:]]*true|isRecording[[:space:]]*=[[:space:]]*true' \
        "$PROJECT_DIR/Alfie/AlfieKit/Tests" --include='*.swift' 2>/dev/null; then
    echo ""
    echo "❌ ERROR: A snapshot test is committed in record mode (see matches above)"
    echo "Set it back to false and re-run so the test asserts against the committed reference."
    exit 1
fi

# Snapshot references are pinned to an iOS major, so resolve an iPhone on that runtime rather
# than accepting whatever generic destination xcodebuild picks (which may be an older iOS).
SIMULATOR_ID=$(xcrun simctl list devices available --json | \
    SNAPSHOT_OS_MAJOR="$SNAPSHOT_OS_MAJOR" /usr/bin/python3 -c '
import json, os, re, sys

major = os.environ["SNAPSHOT_OS_MAJOR"]
for runtime, devices in json.load(sys.stdin)["devices"].items():
    match = re.search(r"iOS-(\d+)-", runtime)
    if not match or match.group(1) != major:
        continue
    for device in devices:
        if "iPhone" in device["name"]:
            print(device["udid"])
            sys.exit(0)
')

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ ERROR: No iPhone simulator running iOS $SNAPSHOT_OS_MAJOR was found"
    echo "Snapshot references are recorded on iOS $SNAPSHOT_OS_MAJOR — asserting on another major shifts rendering."
    echo "Install an iOS $SNAPSHOT_OS_MAJOR simulator via Xcode > Settings > Components."
    exit 1
fi

SIMULATOR_NAME=$(xcrun simctl list devices available | \
    grep "$SIMULATOR_ID" | \
    sed -E 's/^[[:space:]]+(.+) \([A-F0-9-]+\).*/\1/')

echo "📱 Using simulator: $SIMULATOR_NAME ($SIMULATOR_ID) — iOS $SNAPSHOT_OS_MAJOR"
echo ""

xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination "id=$SIMULATOR_ID" \
    $FILTER_ARG \
    $TEST_ACTION 2>&1 | tee "$TEST_LOG"

TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "✅ TESTS PASSED"
    exit 0
fi

# Tests failed
echo ""
echo "❌ TESTS FAILED"
echo ""
echo "📋 Test log saved to: $TEST_LOG"
echo ""
echo "Common issues to check:"
echo "  - Missing test mocks (check Mocks module)"
echo "  - Async test timeouts (increase wait time)"
echo "  - Snapshot test failures (update reference images)"
echo "  - Missing test data setup"
echo "  - Protocol conformance issues in mocks"
echo ""
echo "To view failed tests:"
echo "  grep -A 5 'failed' $TEST_LOG"
echo ""
exit 1
