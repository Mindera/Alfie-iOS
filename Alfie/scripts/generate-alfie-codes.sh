#!/bin/bash

# Generates printable Alfie codes (QR codes for demo swing tags) from a list of product handles.
#
# NOTE: the generator package (Tools/AlfieCodeGen) is intentionally OUTSIDE the AlfieKit graph, so
# verify.sh / CI never build or test it. Its unit tests are gated HERE — fail-fast before printing.
#
# Usage:
#   ./Alfie/scripts/generate-alfie-codes.sh <handles.txt> [output-dir]
#
# The handle list is required on purpose: the products to print change per demo, and a default list
# would print a sheet of codes for products that are not in the catalogue. Copy
# Tools/AlfieCodeGen/handles.example.txt and edit it. Output defaults to build/AlfieCodes.
# See Tools/AlfieCodeGen/README.md for the list format and the printing checklist.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATOR="$REPO_ROOT/Tools/AlfieCodeGen"
INPUT="${1:-}"
OUTPUT="${2:-$REPO_ROOT/build/AlfieCodes}"

if [[ -z "$INPUT" ]]; then
  echo "usage: ./Alfie/scripts/generate-alfie-codes.sh <handles.txt> [output-dir]"
  echo "   Start from $GENERATOR/handles.example.txt, with handles from the live catalogue."
  exit 2
fi

if [[ ! -f "$INPUT" ]]; then
  echo "❌ No handle list at $INPUT"
  exit 1
fi

echo "🧪 Testing generator (not covered by verify.sh)…"
swift test --package-path "$GENERATOR"

echo "⚙️  Generating Alfie codes from $INPUT → $OUTPUT"
swift run --package-path "$GENERATOR" AlfieCodeGen --input "$INPUT" --output "$OUTPUT"

echo "🖨  Print at 100% scale — each code carries the DPI that lands it at 30mm square."
echo "   Check one with your phone camera before printing the sheet."
