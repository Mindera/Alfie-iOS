# ALFMOB-468 — [iOS] Modern Design Rollout — PLP: Refine & Sort sheet

- **Ticket:** https://mindera.atlassian.net/browse/ALFMOB-468 (Subtask of ALFMOB-440, slice 2/3)
- **Base:** ALFMOB-467-plp-modern-design (stacked — slice 1/3); PR targets 467, not main
- **Branch:** ALFMOB-468-plp-refine-sort-sheet
- **Sizing:** small — visual-only, single slice, established pattern (437/438/439). Wayfinder map skipped (small-task fall-through). Ticket = spec.

## Scope
- `Alfie/AlfieKit/Sources/ProductListing/UI/ProductListingFilter.swift` — Refine & Sort sheet.
- `Alfie/AlfieKit/Sources/ProductListing/Helpers/SortByHelper.swift` / `SortByView` styling surfaced in the sheet.

## Phase checklist
- [x] Resolve input (ticket fetched)
- [x] Init branch + status
- [x] Scout scope (scope.md)
- [x] Approval gate — approved
- [x] Implement (ios-execute) — 2 files, verify PASSED (unit; integration skipped), review APPROVED
- [x] Commit (53eec92 code, db24c1e plan)
- [x] PR → ALFMOB-467 (#103)
- [x] Ticket → Review
- [x] Report
