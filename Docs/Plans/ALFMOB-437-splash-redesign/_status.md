# ALFMOB-437 — Modern Design Rollout: Startup / Splash screen

- **Ticket:** [ALFMOB-437](https://mindera.atlassian.net/browse/ALFMOB-437) (Story · Trivial · `design-system`)
- **Base:** main
- **Branch:** feat/ALFMOB-437-splash-redesign
- **Figma:** https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=672-80063

## Summary
Restyle the startup/splash view in `AppFeature` to the modern Figma design (centred MINDERA/ALFIE
wordmark + static loading indicator + background colour) using `SharedUI` design-system components
and tokens. Visual-only, no behaviour change, no feature flag, dark mode deferred.

## Phase checklist
- [x] 1. Resolve input (ticket fetched)
- [x] 2. Init (branch + status)
- [x] 3. Scout → scope.md
- [x] 4. Plan → plan.md
- [x] 4.5 Grill → hardened plan
- [x] GATE: approval (2026-07-15)
- [x] 5. Implement (ios-execute) — 3 phases, verify PASSED, review APPROVED
- [ ] 6. Commit
- [ ] 7. PR
- [ ] 8. Ticket transition
- [ ] 9. Report

## Notes
- Project memory: snapshot suite is disabled repo-wide (out of target membership, no committed
  refs) — the "regenerate snapshot baselines" AC likely cannot be satisfied literally; verify
  appearance via SPM unit tests instead. Confirm during scout.
