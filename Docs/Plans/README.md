# Docs/Plans

Working directory for implementation plans created by the `/alfie-plan` skill and consumed by `/alfie-cook`.

## Lifecycle

1. **Create** — `/alfie-plan ALFMOB-NNN` writes `Docs/Plans/{YYMMDD-HHMM}-ALFMOB-NNN-{slug}/plan.md` (plus per-phase files for 3+ phase plans).
2. **Develop** — `/alfie-cook` reads the plan, implements, and ticks off phase checkboxes inline as work progresses. The plan is committed alongside code so the team can see WIP context on the branch.
3. **Remove at PR time** — `/create-pr` deletes the matching plan directory (`git rm -rf`) and includes the removal in the final commit before opening the PR. `main` should never accumulate completed plan dirs.

## Archive (optional)

If a plan is worth preserving as a decision record after merge, run `/alfie-plan archive` *before* `/create-pr`. That moves it to `Docs/Plans/_archive/{YYMM}/` with a journal entry. `_archive/` is the only subdirectory that persists across PRs.

## Don't commit

- Long-lived plans on `main` (other than `_archive/`)
- Plans for abandoned work — delete them, don't archive

## Related

- `/alfie-plan` — create / red-team / validate / archive plans
- `/alfie-cook` — execute a plan
- `/create-pr` — removes the plan dir as part of opening the PR
