#!/bin/bash

# Regenerates the committed SeedAnchors Swift from the Mock BFF's published seed anchors.
# Run when the BFF adds an anchor a test needs, then `git diff` the output and commit.
#
# Reads the sibling Alfie-BFF checkout; override with ALFIE_BFF_PATH (needed from a worktree).
#
# NOTE: the generator package (Tools/SeedAnchorGen) is intentionally OUTSIDE the AlfieKit graph,
# so verify.sh / CI never build or test it. Its unit tests are gated HERE — fail-fast before emit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATOR="$REPO_ROOT/Tools/SeedAnchorGen"
BFF_PATH="${ALFIE_BFF_PATH:-$REPO_ROOT/../Alfie-BFF}"
INPUT="$BFF_PATH/src/mock/fixtures/seed-anchors.json"
OUTPUT="$REPO_ROOT/Alfie/AlfieKit/Sources/TestSeed/SeedAnchors+Generated.swift"

if [[ ! -f "$INPUT" ]]; then
  echo "❌ No seed anchors at $INPUT — clone Alfie-BFF as a sibling (on an up-to-date main) or set ALFIE_BFF_PATH."
  exit 1
fi

echo "🧪 Testing generator (not covered by verify.sh)…"
swift test --package-path "$GENERATOR"

echo "⚙️  Generating seed anchors → $OUTPUT"
swift run --package-path "$GENERATOR" SeedAnchorGen --input "$INPUT" --output "$OUTPUT"

echo "✅ Done. Review with: git diff -- '$OUTPUT'"
echo "   Commit the generated Swift only when anchors actually changed."
