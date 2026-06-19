#!/bin/bash

# Regenerates the committed Swift design tokens from SharedUI/DesignTokens.
# Run after pull-design-tokens.sh whenever tokens change, then `git diff` the output and commit.
#
# NOTE: the generator package (Tools/DesignTokenGen) is intentionally OUTSIDE the AlfieKit graph,
# so verify.sh / CI never build or test it. Its unit tests are gated HERE — fail-fast before emit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATOR="$REPO_ROOT/Tools/DesignTokenGen"
INPUT="$REPO_ROOT/Alfie/AlfieKit/Sources/SharedUI/DesignTokens"
OUTPUT="$REPO_ROOT/Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens"

if [[ ! -f "$INPUT/manifest.json" ]]; then
  echo "❌ No tokens at $INPUT — run ./Alfie/scripts/pull-design-tokens.sh first."
  exit 1
fi

echo "🧪 Testing generator (not covered by verify.sh)…"
swift test --package-path "$GENERATOR"

echo "⚙️  Generating Swift tokens → $OUTPUT"
swift run --package-path "$GENERATOR" DesignTokenGen --input "$INPUT" --output "$OUTPUT"

echo "✅ Done. Review with: git diff -- '$OUTPUT'"
echo "   Commit the generated Swift only when tokens actually changed."
