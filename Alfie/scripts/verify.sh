#!/bin/bash

# Combined verification script for AI agents
# Runs both build and test verification after code changes
# This ensures code compiles AND business logic is preserved
#
# Scope: build + UNIT tests (BFF responses are mocked; no local server needed).
# Integration tests against a real local BFF live in run-integration-tests.sh.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Running full verification (build + tests)..."
echo "================================================"
echo ""

# Step 1: Build
echo "📦 STEP 1/2: Build Verification"
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

# Step 2: Tests
echo "🧪 STEP 2/2: Test Verification"
echo "-------------------------------"
"$SCRIPT_DIR/test-for-verification.sh" --skip-build "$@"
TEST_RESULT=$?

if [ $TEST_RESULT -ne 0 ]; then
    echo ""
    echo "❌ VERIFICATION FAILED at test step"
    echo "Fix failing tests before proceeding."
    exit 1
fi

echo ""
echo "================================================"
echo "✅ FULL VERIFICATION PASSED (build + tests)"
echo "================================================"
exit 0
