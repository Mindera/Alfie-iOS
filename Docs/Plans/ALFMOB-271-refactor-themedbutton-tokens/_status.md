# ALFMOB-271 — Refactor ThemedButton to use design tokens

- **Ticket:** ALFMOB-271 (Story, Epic ALFMOB-264) — https://mindera.atlassian.net/browse/ALFMOB-271
- **Base branch (PR target):** feat/ALFMOB-264-adopt-design-tokens
- **Work branch:** ALFMOB-271-refactor-themedbutton-tokens
- **High-rigor:** no

## Summary
Update `ThemedButton` / `ButtonTheme` to read all styling (colors, typography, spacing,
corner radius, border) from generated design tokens instead of hardcoded references.
Keep the public `ThemedButton` API unchanged. Cover 4 styles × 3 sizes × states with snapshots.

Files: `Alfie/AlfieKit/Sources/SharedUI/Theme/Buttons/{ThemedButton.swift,ButtonTheme.swift,ThemedButton+Extension.swift}`

## Phase checklist
- [x] SCOUT   → scope.md
- [x] PLAN    → plan.md
- [x] GRILL   → grill.md + hardened plan.md
- [x] APPROVAL gate  ← approved 2026-07-09
- [x] IMPLEMENT (ios-execute: verify ✅ + review APPROVED)
- [ ] COMMIT
- [ ] PR → feat/ALFMOB-264-adopt-design-tokens
- [ ] TICKET → In Review
