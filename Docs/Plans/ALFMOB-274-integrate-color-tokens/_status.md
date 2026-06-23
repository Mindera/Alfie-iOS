# ALFMOB-274 — Integrate color tokens from design token JSON

- **Ticket:** [ALFMOB-274](https://mindera.atlassian.net/browse/ALFMOB-274) (Story)
- **Base branch:** main (branched off `ALFMOB-272-design-token-codegen` tip `2bb3eb1`)
- **Working branch:** `ALFMOB-274-integrate-color-tokens`
- **Depends on:** ALFMOB-272 (design token parser & codegen)

## Goal
Wire generated color token structs into the existing iOS color system, replacing hardcoded
`PrimaryColors` / `SecondaryColors` values with token-generated values. Recommended approach:
Option B (code-based `Color` from tokens, single source of truth).

## Decision (2026-06-23)
Replace the existing color palette **entirely** with generated design tokens (remove `Colors.xcassets` +
hardcoded `Primary/SecondaryColors`; re-point onto `Primitives.Colours.*` / semantic `Theme.*`). Token
export lacks blue/yellow/orange and the 10-shade brand green/red — production green/red are semantic
(success/error) so map to `semantic*`; blue = `ThemedDivider` only; yellow/orange = DebugMenu demos only.
367 call sites. Mapping table to be hardened in grill. See scope.md.

## Phase checklist
- [x] 1. Resolve input (ticket fetched)
- [x] 2. Init branch + status
- [x] 3. Scout (scope.md)
- [x] 4. Plan (plan.md + 4 phase files)
- [x] 4.5 Grill (harden plan → grill.md, mapping.md)
- [x] PLAN APPROVAL GATE — APPROVED (mechanism: **adopt design-token names** at call sites)
- [x] 5. Implement (ios-execute, solo) — verify ✅ FULL VERIFICATION PASSED · review ✅ APPROVED (0 crit)
- [x] 6. Commit (8b8fc0b impl · 48298bf docs)
- [ ] 7. PR  ← awaiting user go-ahead (outward-facing; ticket is partial)
- [ ] 8. Ticket transition
- [ ] 9. Report

## Follow-up (deferred per decision)
- blue/yellow/orange families: no design-token equivalent → review one-by-one (see mapping.md §B). Production shipping usage = none (DebugMenu demos + 1 SwiftUI #Preview only). Needs new upstream tokens in Mindera/Alfie-Mobile-Design-Tokens.
- Design sign-off on the wire-now shade mappings (mapping.md §A) via snapshots on the PR.
