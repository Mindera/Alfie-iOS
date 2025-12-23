#!/bin/bash

# Test script for AI agents to verify code changes
# Works across different developer machines by automatically selecting an available simulator

set -o pipefail  # Ensure pipe returns the exit code of the failing command

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
TEST_LOG="/tmp/alfie_test.log"

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

# Try to run tests with generic iOS Simulator destination (most portable)
echo "🎯 Attempting tests with generic iOS Simulator destination..."
xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' \
    $FILTER_ARG \
    $TEST_ACTION 2>&1 | tee "$TEST_LOG"

TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "✅ TESTS PASSED"
    exit 0
fi

# Check if it was a destination error
if grep -q "Unable to find a device matching the provided destination" "$TEST_LOG"; then
    echo "⚠️  Generic destination failed, trying specific iPhone simulator..."
    
    # Get first available iPhone simulator
    SIMULATOR_ID=$(xcrun simctl list devices available | \
        grep -E "iPhone" | \
        grep -v "unavailable" | \
        head -1 | \
        sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    
    if [ -z "$SIMULATOR_ID" ]; then
        echo "❌ ERROR: No iPhone simulator found"
        echo "Please install iPhone simulators via Xcode"
        exit 1
    fi
    
    SIMULATOR_NAME=$(xcrun simctl list devices available | \
        grep "$SIMULATOR_ID" | \
        sed -E 's/^[[:space:]]+(.+) \(.+\).*/\1/')
    
    echo "📱 Using simulator: $SIMULATOR_NAME ($SIMULATOR_ID)"
    echo ""
    
    # Run tests with specific simulator
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
