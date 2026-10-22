#!/bin/bash

# See docs/CodeStyle.md §Running SwiftLint.

set -euo pipefail

# Hooks in a linked worktree export GIT_DIR, which makes `git -C` report ALFIE_DIR as the top level.
unset GIT_DIR GIT_WORK_TREE

ALFIE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
REPO_ROOT="$(git -C "$ALFIE_DIR" rev-parse --show-toplevel)"
ALFIE_PREFIX="${ALFIE_DIR#"$REPO_ROOT"/}"
SWIFTLINT="$ALFIE_DIR/Tools/swiftlint"
CONFIG=".swiftlint.yml"
FIX_HINT="Auto-fix with: ./$ALFIE_PREFIX/scripts/$(basename "$0") --fix"

fail() {
    echo "" >&2
    echo "❌ $1" >&2
    exit "${2:-1}"
}

if [ ! -f "$SWIFTLINT" ] || [ ! -x "$SWIFTLINT" ]; then
    fail "SwiftLint binary missing or not executable: $SWIFTLINT
   Restore it with: git checkout -- $ALFIE_PREFIX/Tools/swiftlint && chmod +x $ALFIE_PREFIX/Tools/swiftlint" 2
fi

swiftlint() {
    "$SWIFTLINT" lint --quiet --config "$CONFIG" "$@"
}

lint() {
    swiftlint --strict "$@"
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
        [ -n "$root" ] || continue
        case "$path" in "$root" | "$root"/*) return 0 ;; esac
    done <<< "$2"
    return 1
}

lint_staged() {
    local included excluded files=() snapshot_paths=() path relative snapshot
    included="$(config_paths included)"
    excluded="$(config_paths excluded)"

    while IFS= read -r -d '' path; do
        relative="${path#"$ALFIE_PREFIX"/}"
        if [ "$relative" != "$path" ] && matches_any "$relative" "$included" && ! matches_any "$relative" "$excluded"; then
            files+=("$relative")
            snapshot_paths+=("$path")
        fi
    done < <(git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMR -z -- '*.swift')

    if [ ${#files[@]} -eq 0 ]; then
        exit 0
    fi

    snapshot="$(mktemp -d)"
    trap "rm -rf '$snapshot'" EXIT
    git -C "$REPO_ROOT" checkout-index --prefix="$snapshot/" -- "$ALFIE_PREFIX/$CONFIG" "${snapshot_paths[@]}"

    cd "$snapshot/$ALFIE_PREFIX"
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
        swiftlint --fix || fail "SwiftLint auto-fix failed."
        lint || fail "Violations remain that auto-fix can't correct."
        ;;
    *)
        fail "Usage: $(basename "$0") [--staged | --fix]" 64
        ;;
esac
