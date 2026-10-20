#!/bin/bash

# The only entry point to SwiftLint. See Docs/CodeStyle.md §Running SwiftLint.

set -euo pipefail

ALFIE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SWIFTLINT="$ALFIE_DIR/Tools/swiftlint"
CONFIG=".swiftlint.yml"
FIX_HINT="Auto-fix with: ./Alfie/scripts/lint.sh --fix"

fail() {
    echo "" >&2
    echo "❌ $1" >&2
    exit "${2:-1}"
}

if [ ! -f "$SWIFTLINT" ] || [ ! -x "$SWIFTLINT" ]; then
    fail "SwiftLint binary missing or not executable: $SWIFTLINT
   Restore it with: git checkout -- Alfie/Tools/swiftlint && chmod +x Alfie/Tools/swiftlint" 2
fi

lint() {
    "$SWIFTLINT" lint --strict --quiet --config "$CONFIG" "$@"
}

config_paths() {
    awk -v key="$1" '
        { sub(/^#.*$/, ""); sub(/[[:space:]]+#.*$/, ""); sub(/[[:space:]]+$/, "") }
        $0 == key ":" { in_list = 1; next }
        in_list && /^[[:space:]]*-/ {
            sub(/^[[:space:]]*-[[:space:]]*/, ""); gsub(/["'\'']/, ""); print; next
        }
        in_list && NF { exit }
    ' "$ALFIE_DIR/$CONFIG"
}

matches_any() {
    local path="$1" root
    while IFS= read -r root; do
        case "$path" in "$root" | "$root"/*) return 0 ;; esac
    done
    return 1
}

is_in_scope() {
    matches_any "$1" < <(config_paths included) && ! matches_any "$1" < <(config_paths excluded)
}

lint_staged() {
    local repo_root alfie_prefix files=() path relative
    repo_root="$(git -C "$ALFIE_DIR" rev-parse --show-toplevel)"
    alfie_prefix="${ALFIE_DIR#"$repo_root"/}"

    while IFS= read -r -d '' path; do
        relative="${path#"$alfie_prefix"/}"
        if [ "$relative" != "$path" ] && is_in_scope "$relative"; then
            files+=("$relative")
        fi
    done < <(git -C "$repo_root" diff --cached --name-only --diff-filter=ACMR -z -- '*.swift')

    if [ ${#files[@]} -eq 0 ]; then
        exit 0
    fi

    local snapshot
    snapshot="$(mktemp -d)"
    trap "rm -rf '$snapshot'" EXIT

    (
        cd "$repo_root"
        git checkout-index --prefix="$snapshot/" -- "$alfie_prefix/$CONFIG"
        for path in "${files[@]}"; do
            git checkout-index --prefix="$snapshot/" -- "$alfie_prefix/$path"
        done
    )

    cd "$snapshot/$alfie_prefix"
    lint --force-exclude "${files[@]}" | sed "s|^\(/private\)\{0,1\}$snapshot/||" \
        || fail "SwiftLint failed on staged files. $FIX_HINT"
}

cd "$ALFIE_DIR"

case "${1:-}" in
    "")
        lint || fail "SwiftLint failed. $FIX_HINT"
        ;;
    --staged)
        lint_staged
        ;;
    --fix)
        "$SWIFTLINT" lint --fix --quiet --config "$CONFIG"
        lint || fail "Violations remain that auto-fix can't correct."
        ;;
    *)
        echo "Usage: $(basename "$0") [--staged | --fix]" >&2
        exit 64
        ;;
esac
