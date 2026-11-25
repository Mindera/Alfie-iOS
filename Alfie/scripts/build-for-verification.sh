#!/bin/bash

# Build script for AI agents to verify code changes
# Works across different developer machines by automatically selecting an available simulator
# ALFIE_XCODEBUILD_ARGS adds space-separated flags to the xcodebuild calls (CI's package flags).
# ALFIE_RESTORED_DERIVED_DATA names a DerivedData directory restored from a cache: a failed build
# deletes it and builds clean once, so a stale cache cannot fail a build that passes clean.

set -o pipefail  # Ensure pipe returns the exit code of the failing command

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
source "$(dirname "${BASH_SOURCE[0]}")/simulator.sh"
source "$(dirname "${BASH_SOURCE[0]}")/ci-log.sh"

echo "🔨 Building Alfie iOS project..."
echo "📂 Project: $PROJECT_FILE"
echo "📱 Scheme: $SCHEME"
echo ""

# Try to build test bundles with generic iOS Simulator destination (most portable)
echo "🎯 Attempting build-for-testing with generic iOS Simulator destination..."
run_logged "build-for-testing" /tmp/alfie_build.log \
    xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' \
    "${XCODEBUILD_ARGS[@]}" \
    build-for-testing
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCEEDED"
    exit 0
fi

# Check if it was a destination error (exit code 70 or specific error message)
if grep -q "Unable to find a device matching the provided destination" /tmp/alfie_build.log; then
    echo "⚠️  Generic destination failed, trying specific iPhone simulator..."
    
    SIMULATOR_ID="$(preferred_iphone_udid)"

    if [ -z "$SIMULATOR_ID" ]; then
        echo "❌ ERROR: No iPhone simulator found"
        echo "Please install iPhone simulators via Xcode"
        exit 1
    fi

    SIMULATOR_NAME="$(simulator_name "$SIMULATOR_ID")"

    echo "📱 Using simulator: $SIMULATOR_NAME ($SIMULATOR_ID)"
    echo ""
    
    # Build test bundles with specific simulator
    run_logged "build-for-testing ($SIMULATOR_NAME)" /tmp/alfie_build.log \
        xcodebuild -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "id=$SIMULATOR_ID" \
        "${XCODEBUILD_ARGS[@]}" \
        build-for-testing
    BUILD_RESULT=$?

    if [ $BUILD_RESULT -eq 0 ]; then
        echo ""
        echo "✅ BUILD SUCCEEDED"
        exit 0
    fi
fi

if [ -n "${ALFIE_RESTORED_DERIVED_DATA:-}" ] && [ -d "$ALFIE_RESTORED_DERIVED_DATA" ]; then
    echo ""
    echo "⚠️  Build failed on the restored DerivedData, deleting it and building clean..."
    rm -rf "$ALFIE_RESTORED_DERIVED_DATA"
    ALFIE_RESTORED_DERIVED_DATA="" exec "${BASH_SOURCE[0]}" "$@"
fi

# Build failed
echo ""
echo "❌ BUILD FAILED"
echo ""
echo "📋 Build log saved to: /tmp/alfie_build.log"
echo ""
echo "Common issues to check:"
echo "  - Missing imports (import Models, import StyleGuide, etc.)"
echo "  - Unresolved symbols (typos in L10n keys, missing enum cases)"
echo "  - Type mismatches (incorrect protocol conformance)"
echo "  - Missing exhaustive switch cases"
echo "  - Syntax errors"
echo ""
exit 1
