# ALFMOB-426 — [iOS] Iconography: reconcile icon set with Figma

- **Ticket:** ALFMOB-426 (Story, label `design-system`) — https://mindera.atlassian.net/browse/ALFMOB-426
- **Base branch:** main
- **Task branch:** feat/ALFMOB-426-iconography-figma
- **Started:** 2026-07-13

## Goal
Replace the SF Symbols-based `Icon` enum with the Figma Tabler-based icon set for the
**Arrows & System** + **E-commerce** categories. Bundle vector assets into a `SharedUI`
`.xcassets`, regenerate `Icon` to Figma vocabulary resolving to bundled assets, update
`IconRepresentable`, handle Fill + OS-specific (Back/Share) variants, wire size/tint to
tokens, document the re-export, add appearance coverage.

## Phase checklist
- [x] Scout — map current icon system (Icon.swift, IconRepresentable.swift, call sites) → scope.md
- [x] Plan — phased plan.md + 4 phase files + testing strategy (complexity MEDIUM)
- [x] Grill — decisions logged in grill.md (mappings, deletions, fallback list, PR note)
- [x] APPROVAL gate — approved 2026-07-13
- [x] Implement (ios-execute) — verify ✅ PASSED, review APPROVED
- [ ] Commit ← in progress
- [ ] PR → main
- [ ] Ticket transition
