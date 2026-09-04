#!/bin/bash

# Test script for AI agents to verify code changes
# Selects an iPhone simulator on the pinned iOS major so snapshot references stay comparable

set -o pipefail  # Ensure pipe returns the exit code of the failing command

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Alfie/Alfie.xcodeproj"
SCHEME="Alfie"
TEST_LOG="/tmp/alfie_test.log"
# Coverage bundle at a fixed path, so tooling can find it without parsing this script. xcodebuild
# refuses to overwrite an existing bundle, so it is removed before each run. The sidecar records
# which commit the coverage describes, and whether snapshot tests ran (they are what cover SwiftUI
# view bodies) -- without that line an unexercised body is indistinguishable from a skipped suite.
RESULT_BUNDLE="/tmp/alfie_test.xcresult"
RESULT_BUNDLE_SHA="$RESULT_BUNDLE.sha"
# Snapshot references are recorded on this exact iOS version. A major-only pin is not enough: glyph
# antialiasing differs between minors (26.2 vs 26.4 drifts ~24 px/screen, enough to fail precision 1.0),
# so a machine holding several 26.x runtimes could otherwise record against one and assert on another.
# Keep in lockstep with SCAN_DEVICE in fastlane/.env.default. Overridable per run, but changing it
# means re-recording every reference.
SNAPSHOT_OS_VERSION="${SNAPSHOT_OS_VERSION:-26.4}"

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

# A filtered run covers a subset of the suite, so it gets its own bundle rather than destroying a
# stamped full-run one. The sidecar here is never written: the stamp is guarded on an unfiltered run.
if [ -n "$TEST_FILTER" ]; then
    RESULT_BUNDLE="/tmp/alfie_test_filtered.xcresult"
    RESULT_BUNDLE_SHA="$RESULT_BUNDLE.sha"
fi

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
# assertion anyway, but catching it here costs a second instead of a full test run. Covers the
# common spellings: record: true/.all/.failed, withSnapshotTesting(record:), and an isRecording
# flag set true (with or without a `: Bool` annotation). Scans both test roots.
# Set SNAPSHOT_ALLOW_RECORD=1 to bypass while intentionally re-recording a reference through this script.
SNAPSHOT_TEST_ROOTS=("$PROJECT_DIR/Alfie/AlfieKit/Tests" "$PROJECT_DIR/Alfie/AlfieTests")
if [ "${SNAPSHOT_ALLOW_RECORD:-0}" != "1" ]; then
    for root in "${SNAPSHOT_TEST_ROOTS[@]}"; do
        [ -d "$root" ] || continue
        if grep -rnE --include='*.swift' \
                'record:[[:space:]]*(true|\.all|\.failed)|withSnapshotTesting\(record:|isRecording[[:space:]]*(:[[:space:]]*Bool)?[[:space:]]*=[[:space:]]*true' \
                "$root"; then
            echo ""
            echo "❌ ERROR: A snapshot test is committed in record mode (see matches above)"
            echo "Set it back to false and re-run so the test asserts against the committed reference."
            echo "To record intentionally through this script, re-run with SNAPSHOT_ALLOW_RECORD=1."
            exit 1
        fi
    done
fi

# Snapshot references are pinned to an exact iOS version, so resolve an iPhone on that runtime rather
# than accepting whatever generic destination xcodebuild picks (which may be another minor).
SIMULATOR_ID=$(xcrun simctl list devices available --json | \
    SNAPSHOT_OS_VERSION="$SNAPSHOT_OS_VERSION" /usr/bin/python3 -c '
import json, os, re, sys

wanted = os.environ["SNAPSHOT_OS_VERSION"].replace(".", "-")
for runtime, devices in json.load(sys.stdin)["devices"].items():
    match = re.search(r"iOS-(\d+-\d+)", runtime)
    if not match or match.group(1) != wanted:
        continue
    for device in devices:
        if "iPhone" in device["name"]:
            print(device["udid"])
            sys.exit(0)
')

SNAPSHOT_SKIP_ARGS=()

if [ -n "$SIMULATOR_ID" ]; then
    SIMULATOR_OS_LABEL="iOS $SNAPSHOT_OS_VERSION"
else
    # No iPhone on the pinned iOS version. Rather than block the whole suite, fall back to the newest
    # available iPhone and skip the snapshot classes: their references are pinned to iOS
    # $SNAPSHOT_OS_VERSION and would fail on another version, but every non-snapshot test still runs.
    FALLBACK=$(xcrun simctl list devices available --json | /usr/bin/python3 -c '
import json, re, sys

best = None
for runtime, devices in json.load(sys.stdin)["devices"].items():
    match = re.search(r"iOS-(\d+)-(\d+)", runtime)
    if not match:
        continue
    version = (int(match.group(1)), int(match.group(2)))
    for device in devices:
        if "iPhone" in device["name"] and (best is None or version > best[0]):
            best = (version, device["udid"], "%s.%s" % (match.group(1), match.group(2)))
if best:
    print("%s %s" % (best[1], best[2]))
')
    SIMULATOR_ID="${FALLBACK%% *}"
    FALLBACK_OS="${FALLBACK##* }"
    FALLBACK_OS_MAJOR="${FALLBACK_OS%%.*}"

    if [ -z "$SIMULATOR_ID" ]; then
        echo "❌ ERROR: No iPhone simulator is available"
        echo "Install an iOS $SNAPSHOT_OS_VERSION iPhone simulator via Xcode > Settings > Components,"
        echo "or override for this run: SNAPSHOT_OS_VERSION=<major.minor> ./Alfie/scripts/verify.sh"
        exit 1
    fi

    # Discover snapshot test classes (any file that calls assertSnapshot) and skip them by target/class,
    # so new snapshot suites are covered without maintaining a hard-coded list here. Scans the same roots
    # as the record guard; derives the target from either the AlfieKit SPM layout or the AlfieTests app target.
    while IFS= read -r file; do
        case "$file" in
            */AlfieKit/Tests/*) target=$(printf '%s\n' "$file" | sed -E 's#.*/AlfieKit/Tests/([^/]+)/.*#\1#') ;;
            */AlfieTests/*)     target="AlfieTests" ;;
            *)                  target="" ;;
        esac
        class=$(grep -oE 'class[[:space:]]+[A-Za-z0-9_]+' "$file" | head -1 | awk '{print $2}')
        [ -n "$target" ] && [ -n "$class" ] && SNAPSHOT_SKIP_ARGS+=("-skip-testing:$target/$class")
    done < <(grep -rlE 'assertSnapshot\(' --include='*.swift' "${SNAPSHOT_TEST_ROOTS[@]}" 2>/dev/null)

    echo "⚠️  No iPhone on iOS $SNAPSHOT_OS_VERSION — falling back to iOS $FALLBACK_OS and SKIPPING snapshot tests."
    echo "⚠️  Snapshot references are pinned to iOS $SNAPSHOT_OS_VERSION; asserting them on iOS $FALLBACK_OS would fail on rendering differences."
    echo "⚠️  To run snapshots: install an iOS $SNAPSHOT_OS_VERSION simulator, or set SNAPSHOT_OS_VERSION=$FALLBACK_OS and re-record every reference."
    [ ${#SNAPSHOT_SKIP_ARGS[@]} -gt 0 ] && echo "⚠️  Skipping: ${SNAPSHOT_SKIP_ARGS[*]//-skip-testing:/}"
    echo ""
    SIMULATOR_OS_LABEL="iOS $FALLBACK_OS (fallback — snapshots skipped)"
fi

SIMULATOR_NAME=$(xcrun simctl list devices available | \
    grep "$SIMULATOR_ID" | \
    sed -E 's/^[[:space:]]+(.+) \([A-F0-9-]+\).*/\1/')

echo "📱 Using simulator: $SIMULATOR_NAME ($SIMULATOR_ID) — $SIMULATOR_OS_LABEL"
echo ""

rm -rf "$RESULT_BUNDLE" "$RESULT_BUNDLE_SHA"

xcodebuild -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -destination "id=$SIMULATOR_ID" \
    -resultBundlePath "$RESULT_BUNDLE" \
    $FILTER_ARG \
    "${SNAPSHOT_SKIP_ARGS[@]}" \
    $TEST_ACTION 2>&1 | tee "$TEST_LOG"

TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -eq 0 ]; then
    # Only stamp the bundle for an unfiltered run: a filtered run's coverage describes a subset of
    # the suite, and a consumer keying off the commit alone would read it as complete.
    if [ -z "$TEST_FILTER" ] && [ -d "$RESULT_BUNDLE" ]; then
        {
            git -C "$PROJECT_DIR" rev-parse HEAD
            if [ ${#SNAPSHOT_SKIP_ARGS[@]} -gt 0 ]; then
                echo "snapshots=skipped"
            else
                echo "snapshots=included"
            fi
        } > "$RESULT_BUNDLE_SHA"
    fi
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
