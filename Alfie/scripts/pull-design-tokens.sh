#!/bin/bash

# Pulls the iOS-relevant subset of DTCG token files from Mindera/Alfie-Mobile-Design-Tokens into
# SharedUI/DesignTokens. Run this only when design tokens change, then run generate-design-tokens.sh.
#
# Source resolution:
#   DESIGN_TOKENS_SRC=/path/to/local/checkout  → copy from a local clone (no network)
#   otherwise                                   → shallow-clone DESIGN_TOKENS_REMOTE (SSH by default)
#
# Credentials are never echoed (no `set -x` around the clone) and only *.json we need is copied
# (never `cp -R` the clone, which could drag in .git/credentials).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST="$REPO_ROOT/Alfie/AlfieKit/Sources/SharedUI/DesignTokens"
TOKENS_REMOTE="${DESIGN_TOKENS_REMOTE:-git@github.com:Mindera/Alfie-Mobile-Design-Tokens.git}"

# iOS subset (mode-selected per the contract): System=ios, Screen Size=small; skip android/web,
# medium/large/wide, and the .documentation collection. typography.alfie-theme is kept because the
# composite styles reference its sub-tokens.
TOKEN_FILES=(
  "manifest.json"
  ".primitives.alfie-theme.tokens.json"
  "theme.alfie-theme.tokens.json"
  "sizing.alfie-theme.tokens.json"
  "typography.alfie-theme.tokens.json"
  "typography.styles.tokens.json"
  "system.ios.tokens.json"
  "screen-size.small-(s).tokens.json"
)
# Allow-lists live at the token repo root (not under design-tokens/).
ALLOWLIST_FILES=(
  ".cycle-allowlist.json"
  ".broken-ref-allowlist.json"
)

if [[ -n "${DESIGN_TOKENS_SRC:-}" ]]; then
  SRC="$DESIGN_TOKENS_SRC"
  echo "📂 Using local token checkout: $SRC"
else
  SRC="$(mktemp -d)"
  trap 'rm -rf "$SRC"' EXIT
  echo "⬇️  Cloning $TOKENS_REMOTE (auth not echoed)…"
  ( set +x; git clone --depth 1 "$TOKENS_REMOTE" "$SRC" >/dev/null )
fi

mkdir -p "$DEST"
# Clear any previously-pulled JSON first, so a changed file set can't leave stale tokens behind
# (`-name '*.json'` matches dot-prefixed names like .primitives.* / .cycle-allowlist.json too).
find "$DEST" -maxdepth 1 -type f -name '*.json' -delete
for f in "${TOKEN_FILES[@]}"; do
  cp "$SRC/design-tokens/$f" "$DEST/$f"
done
for f in "${ALLOWLIST_FILES[@]}"; do
  cp "$SRC/$f" "$DEST/$f"
done

echo "✅ Pulled $(( ${#TOKEN_FILES[@]} + ${#ALLOWLIST_FILES[@]} )) files into $DEST"
echo "   Next: ./Alfie/scripts/generate-design-tokens.sh"
