#!/bin/bash

# Prints "true" when every file changed from <base> to HEAD is documentation (any *.md, anything
# under docs/), else "false". No base, an unreadable range or an empty range print "false", so the
# caller tests whenever the answer is in doubt.
# Usage: ci-docs-only.sh [<base>]

set -uo pipefail

BASE="${1:-}"

if [ -n "$BASE" ] &&
    CHANGED="$(git diff --name-only --no-renames "$BASE" HEAD -- 2>/dev/null)" &&
    [ -n "$CHANGED" ] &&
    ! grep -qvE '(\.md$|^docs/)' <<< "$CHANGED"; then
    echo true
else
    echo false
fi
