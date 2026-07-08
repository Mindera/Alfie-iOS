# Status — ALFMOB-267

**Title:** [iOS] Refactor Typography/Label components to use design tokens
**Ticket:** https://mindera.atlassian.net/browse/ALFMOB-267 (Story)
**Base:** claude/affectionate-hodgkin-b608a2 (carries fontWeight/fontFamily token typing; not on main)
**Branch:** ALFMOB-267-typography-label-tokens

## Acceptance Criteria
- [ ] All text rendering uses token-generated typography
- [ ] No hardcoded font sizes, weights, or family names in typography utilities
- [ ] AttributedString builders produce correctly styled text
- [ ] UIFont mappings reflect token values
- [ ] All typography levels render correctly (h1, h2, h3, paragraph, small, tiny)

## Phase checklist
- [x] 1. Resolve input (ticket fetched)
- [x] 2. Init (branch created off base)
- [x] 3. Scout → scope.md
- [x] 4. Plan → plan.md
- [x] 4.5 Grill → hardened plan.md
- [x] GATE: approval
- [x] 5. Implement (ios-execute)
- [x] 6. Commit
- [ ] 7. PR
- [ ] 8. Ticket transition
- [ ] 9. Report
