#!/bin/bash

# Sets every tracked, unmodified file's modification date to the date of the last commit that
# changed it, so a DerivedData built on another checkout sees unchanged files as unchanged.
# Needs the full history (actions/checkout fetch-depth: 0). Used by CI before the build.

set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

if [ "$(git rev-parse --is-shallow-repository)" = true ]; then
    echo "❌ ERROR: shallow checkout, file dates cannot be restored"
    exit 1
fi

TRACKED="$(mktemp)"
MODIFIED="$(mktemp)"
trap 'rm -f "$TRACKED" "$MODIFIED"' EXIT
git ls-files -z > "$TRACKED"
git diff --name-only -z HEAD > "$MODIFIED"

git log --first-parent --diff-merges=first-parent --no-renames --format='%x01%ct' --name-only -z |
    /usr/bin/python3 -c '
import os, sys

def paths(file):
    return set(open(file, "rb").read().split(b"\0"))

pending = paths(sys.argv[1]) - paths(sys.argv[2])
restored = 0
date = None
for token in sys.stdin.buffer.read().split(b"\0"):
    token = token.lstrip(b"\n")
    if token.startswith(b"\x01"):
        date = int(token[1:])
    elif token in pending:
        pending.remove(token)
        if os.path.lexists(token):
            os.utime(token, (date, date), follow_symlinks=False)
            restored += 1
print("Restored the modification date of %d files" % restored)
' "$TRACKED" "$MODIFIED"
