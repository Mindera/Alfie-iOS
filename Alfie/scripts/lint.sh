#!/bin/bash

# The only entry point to SwiftLint: strict, committed binary, Alfie/.swiftlint.yml.
#
# Usage:
#   lint.sh            Lint the whole repo
#   lint.sh --staged   Lint the staged content of staged Swift files
#   lint.sh --fix      Autocorrect, then lint the whole repo

set -euo pipefail

ALFIE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFTLINT="$ALFIE_DIR/Tools/swiftlint"
CONFIG=".swiftlint.yml"
FIX_HINT="Auto-fix with: Alfie/scripts/lint.sh --fix"

if [ ! -f "$SWIFTLINT" ] || [ ! -x "$SWIFTLINT" ]; then
    echo "❌ SwiftLint binary missing or not executable: $SWIFTLINT" >&2
    echo "   Restore it with: git checkout -- Alfie/Tools/swiftlint && chmod +x Alfie/Tools/swiftlint" >&2
    exit 2
fi

lint() {
    "$SWIFTLINT" lint --strict --quiet --config "$CONFIG" "$@"
}

config_paths() {
    awk -v key="$1:" '
        $0 == key { in_list = 1; next }
        in_list && /^[[:space:]]*-/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); print; next }
        in_list { exit }
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
    local repo_root alfie_prefix staged=() files=() path relative
    repo_root="$(git -C "$ALFIE_DIR" rev-parse --show-toplevel)"
    alfie_prefix="${ALFIE_DIR#"$repo_root"/}"

    while IFS= read -r -d '' path; do
        staged+=("$path")
    done < <(git -C "$repo_root" diff --cached --name-only --diff-filter=ACMR -z -- '*.swift')

    for path in ${staged[@]+"${staged[@]}"}; do
        relative="${path#"$alfie_prefix"/}"
        [ "$relative" != "$path" ] && is_in_scope "$relative" && files+=("$relative")
    done

    if [ ${#files[@]} -eq 0 ]; then
        exit 0
    fi

    local snapshot
    snapshot="$(mktemp -d)"
    trap 'rm -rf "$snapshot"' EXIT

    (
        cd "$repo_root"
        git checkout-index --prefix="$snapshot/" -- "$alfie_prefix/$CONFIG"
        for path in "${files[@]}"; do
            git checkout-index --prefix="$snapshot/" -- "$alfie_prefix/$path"
        done
    )

    cd "$snapshot/$alfie_prefix"
    local status=0
    lint --force-exclude "${files[@]}" | sed "s|^\(/private\)\{0,1\}$snapshot/||" || status=$?
    if [ "$status" -ne 0 ]; then
        echo "" >&2
        echo "❌ SwiftLint failed on staged files. $FIX_HINT" >&2
    fi
    exit "$status"
}

cd "$ALFIE_DIR"

case "${1:-}" in
    "")
        lint || { echo "" >&2; echo "❌ SwiftLint failed. $FIX_HINT" >&2; exit 1; }
        ;;
    --staged)
        lint_staged
        ;;
    --fix)
        "$SWIFTLINT" lint --fix --quiet --config "$CONFIG"
        lint || { echo "" >&2; echo "❌ Violations remain that auto-fix can't correct." >&2; exit 1; }
        ;;
    *)
        echo "Usage: $(basename "$0") [--staged | --fix]" >&2
        exit 64
        ;;
esac
