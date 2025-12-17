#!/bin/bash

# Build script for AI agents to verify code changes
# Works across different developer machines by automatically selecting an available simulator

set -e  # Exit on error

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"

echo "🔨 Building Alfie iOS project..."
echo "📂 Project: $PROJECT_FILE"
echo "📱 Scheme: $SCHEME"
echo ""

# Try to build with generic iOS Simulator destination (most portable)
echo "🎯 Attempting build with generic iOS Simulator destination..."
if xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=Any iOS Simulator Device' \
    build 2>&1 | tee /tmp/alfie_build.log; then
    echo ""
    echo "✅ BUILD SUCCEEDED"
    exit 0
fi

# If generic destination fails, try to find first available iPhone simulator
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

# Build with specific simulator
xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination "id=$SIMULATOR_ID" \
    build 2>&1 | tee /tmp/alfie_build.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCEEDED"
    exit 0
else
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
fi
