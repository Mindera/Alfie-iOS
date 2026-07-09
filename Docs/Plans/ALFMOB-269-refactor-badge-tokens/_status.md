# ALFMOB-269 — Refactor Badge component to use design tokens

- **Ticket:** [ALFMOB-269](https://mindera.atlassian.net/browse/ALFMOB-269) (Story)
- **Base:** main
- **Branch:** ALFMOB-269-refactor-badge-tokens
- **Type:** feat

## Summary
Migrate `BadgeViewModifier` and `BadgeTabViewModifier` from hardcoded `Colors.*` / sizing / font
values to design-token-generated colors, typography, and spacing/shape tokens. Call sites must be
unchanged.

## Acceptance Criteria
- [ ] Badge uses token values for all visual properties (color, text color, sizing, typography)
- [ ] Badge renders correctly with different count values (1, 9, 99, 999+)
- [ ] Both view modifier variants work correctly
- [ ] Existing call sites do not need changes

## Phase checklist
- [x] 0. Load profile
- [x] 1. Resolve input (ticket fetched)
- [x] 2. Init (branch + status)
- [x] 3. Scout → scope.md
- [x] 4. Plan → plan.md
- [x] 4.5 Grill → hardened plan
- [x] GATE: approval ✓ approved 2026-07-09
- [x] 5. Implement (ios-execute) ✓ verify PASSED, review APPROVED
- [ ] 6. Commit ← next
- [ ] 7. PR
- [ ] 8. Ticket transition
- [ ] 9. Report
