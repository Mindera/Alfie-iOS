#!/bin/bash

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

git -C "$REPO_ROOT" config core.hooksPath .githooks
echo "✅ Git hooks installed (core.hooksPath=.githooks). Skip once with: git commit --no-verify"
