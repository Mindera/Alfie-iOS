# Mutation testing on PR changes — evaluation

- **Ticket:** none. Agent-initiated exploration (GitHub Issues per `Docs/agents/issue-tracker.md`
  if this graduates to work).
- **Base:** `main`.
- **Branch:** `worktree-mutation-testing-plan` (this document only; no code).
- **Sizing:** evaluation first. The build depends on a bake-off, now in progress.
- **PR:** #131 (this document only).

## Scope
Decide whether Alfie adopts mutation testing on PR diffs, and if so by which mechanism.
No production code is touched by this phase.

## Phase checklist
- [x] Research the Swift mutation-testing landscape
- [x] Design session (`/grill-with-docs`) — decisions recorded in `design.md`
- [x] Record the agreed plan
- [~] Bake-off Arm A — agent, by hand (running)
- [~] Bake-off Arm B — Muter (running)
- [ ] Comparison report → `Docs/Reports/mutation-testing-bakeoff.md`
- [ ] Pick a winner; then ADR + vocabulary into `Docs/Testing.md`
