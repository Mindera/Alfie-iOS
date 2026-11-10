#!/bin/bash

# Combined verification script for AI agents
# Runs both build and test verification after code changes
# This ensures code compiles AND business logic is preserved
#
# Scope (default): one build + UNIT tests (mocked BFF) + INTEGRATION then UI tests against the Mock
# BFF, all from that build (delegates to run-integration-tests.sh; needs Node, yarn + the Alfie-BFF repo).
# Pass --skip-integration to run only build + unit tests (fast, server-free) — use this when the
# local BFF / Node toolchain isn't available.
#
# Usage: verify.sh [--skip-integration] [args passed through to test-for-verification.sh, e.g. --filter X]

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse our own flags; pass everything else through to the unit-test runner.
RUN_INTEGRATION=true
TEST_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-integration) RUN_INTEGRATION=false; shift ;;
        *) TEST_ARGS+=("$1"); shift ;;
    esac
done

if [ "$RUN_INTEGRATION" = true ]; then
    echo "🔄 Running full verification (build + unit tests + integration and UI tests)..."
else
    echo "🔄 Running verification (build + unit tests, integration skipped)..."
fi
echo "================================================"
echo ""

# Step 1: Build
echo "📦 STEP 1: Build Verification"
echo "--------------------------------"
"$SCRIPT_DIR/build-for-verification.sh"
BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
    echo ""
    echo "❌ VERIFICATION FAILED at build step"
    echo "Fix build errors before proceeding."
    exit 1
fi

echo ""
echo ""

# Step 2: Unit tests (mocked BFF)
echo "🧪 STEP 2: Unit Test Verification"
echo "-------------------------------"
"$SCRIPT_DIR/test-for-verification.sh" --skip-build "${TEST_ARGS[@]}"
TEST_RESULT=$?

if [ $TEST_RESULT -ne 0 ]; then
    echo ""
    echo "❌ VERIFICATION FAILED at unit test step"
    echo "Fix failing tests before proceeding."
    exit 1
fi

if [ "$RUN_INTEGRATION" = true ]; then
    echo ""
    echo ""
    echo "🌐 STEP 3: Integration + UI Test Verification (Mock BFF)"
    echo "-------------------------------"
    "$SCRIPT_DIR/run-integration-tests.sh" --skip-build
    INTEGRATION_RESULT=$?

    if [ $INTEGRATION_RESULT -ne 0 ]; then
        echo ""
        echo "❌ VERIFICATION FAILED at integration/UI test step"
        echo "(Re-run with --skip-integration if the local BFF is unavailable.)"
        exit 1
    fi
fi

echo ""
echo "================================================"
if [ "$RUN_INTEGRATION" = true ]; then
    echo "✅ FULL VERIFICATION PASSED (build + unit + integration + UI)"
else
    echo "✅ VERIFICATION PASSED (build + unit tests; integration skipped)"
fi
echo "================================================"
exit 0
