#!/bin/bash

# Deletes every GitHub Actions cache on <ref> whose key starts with a given prefix, except the
# newest of each prefix, so a build's caches replace the previous build's instead of adding to the
# repository's 10 GB. Needs gh with a token that may write Actions (GH_TOKEN, GH_REPO on CI).
# Usage: prune-build-caches.sh <ref> <key prefix>...

set -euo pipefail

REF="${1:?ref missing}"
shift

for prefix in "$@"; do
    [ -n "$prefix" ] || { echo "❌ ERROR: empty key prefix"; exit 1; }
    gh cache list --ref "$REF" --key "$prefix" --sort created_at --order desc --limit 100 \
        --json id,key --jq '.[1:][] | "\(.id) \(.key)"' |
        while read -r id key; do
            echo "Deleting $key"
            gh cache delete "$id" || echo "⚠️  Could not delete $key"
        done
done
