#!/bin/bash

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
HOOKS_PATH=".githooks"
DEFAULT_HOOKS_DIR="$(git -C "$REPO_ROOT" rev-parse --path-format=absolute --git-common-dir)/hooks"

current="$(git -C "$REPO_ROOT" config --get core.hooksPath || true)"
if [ -n "$current" ] && [ "$current" != "$HOOKS_PATH" ]; then
    echo "⚠️  Replacing core.hooksPath=$current for this repo: hooks there stop running here."
fi

custom_hooks="$(find "$DEFAULT_HOOKS_DIR" -type f ! -name '*.sample' 2>/dev/null || true)"
if [ -n "$custom_hooks" ]; then
    echo "⚠️  These hooks stop running (core.hooksPath replaces $DEFAULT_HOOKS_DIR):"
    echo "$custom_hooks" | sed 's/^/   /'
fi

git -C "$REPO_ROOT" config core.hooksPath "$HOOKS_PATH"
echo "✅ Git hooks installed (core.hooksPath=$HOOKS_PATH). Skip once with: git commit --no-verify"
