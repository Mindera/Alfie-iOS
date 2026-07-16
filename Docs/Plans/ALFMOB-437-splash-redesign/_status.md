# ALFMOB-437 — Modern Design Rollout: Startup / Splash screen

- **Ticket:** [ALFMOB-437](https://mindera.atlassian.net/browse/ALFMOB-437) (Story · Trivial · `design-system`)
- **Base:** main
- **Branch:** feat/ALFMOB-437-splash-redesign
- **Figma:** https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=672-80063

## Summary
Restyled the startup/splash view in `AppFeature` to the modern Figma design (centred MINDERA/ALFIE
wordmark + design-system loading spinner) using `SharedUI` components and tokens, added the reusable
animated `ThemedSpinnerView`, and updated the native launch screen to the same wordmark. Visual-only,
no behaviour change, no feature flag, dark mode deferred. **Status: completed** — see `plan.md`.

## Phase checklist
- [x] 1. Resolve input (ticket fetched)
- [x] 2. Init (branch + status)
- [x] 3. Scout → scope.md
- [x] 4. Plan → plan.md
- [x] 4.5 Grill → hardened plan
- [x] GATE: approval (2026-07-15)
- [x] 5. Implement (ios-execute) — 3 phases, verify PASSED, review APPROVED
- [x] 6. Commit (d75c435 impl, 34b8751 docs)
- [x] 7. PR → https://github.com/Mindera/Alfie-iOS/pull/96
- [x] 8. Ticket transition → Review
- [x] 9. Report

## Notes
- Snapshot suite is disabled repo-wide (out of target membership, no committed refs) — the
  "regenerate snapshot baselines" AC was satisfied via an SPM unit test instead.
- Loading-indicator animation was implemented (DS spinner finalized by design); native launch
  screen updated for launch → in-app consistency. Both are noted in the PR.
