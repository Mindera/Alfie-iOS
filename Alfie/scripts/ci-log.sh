# Sourced, not run. Folds a stage's output in the GitHub Actions job log; prints nothing elsewhere.
log_group() { [ -z "$GITHUB_ACTIONS" ] || echo "::group::$1"; }
log_endgroup() { [ -z "$GITHUB_ACTIONS" ] || echo "::endgroup::"; }
