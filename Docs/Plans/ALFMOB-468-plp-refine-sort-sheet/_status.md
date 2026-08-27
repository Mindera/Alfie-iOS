# ALFMOB-468 — [iOS] Modern Design Rollout — PLP: Refine & Sort sheet

- **Ticket:** https://mindera.atlassian.net/browse/ALFMOB-468 (Subtask of ALFMOB-440, slice 2/3)
- **Base:** `main`. (Originally stacked on ALFMOB-467; that branch was replayed onto main, and its
  two remaining commits now ride along in this PR.)
- **Branch:** ALFMOB-468-plp-refine-sort-sheet
- **Sizing:** started small (visual-only restyle, ticket = spec). **Re-scoped by ALFMOB-475** into
  the full Refine architecture plus a working Price filter — see `price-filter-plan.md`.

## Scope
- `Alfie/AlfieKit/Sources/ProductListing/UI/ProductListingFilter.swift` — Refine & Sort sheet.
- `Alfie/AlfieKit/Sources/ProductListing/Helpers/SortByHelper.swift` / `SortByView` styling surfaced in the sheet.

## Phase checklist
- [x] Resolve input (ticket fetched)
- [x] Init branch + status
- [x] Scout scope (scope.md)
- [x] Approval gate — approved
- [x] Implement the restyle (ios-execute) — 2 files, verify PASSED, review APPROVED
- [x] Implement the price filter (ALFMOB-475 build order) — verify PASSED incl. integration
- [x] Address PR #103 review — 1 critical (`Int(Double)` crash), 5 important, 2 nits
- [x] Commit (53eec92 code, db24c1e plan)
- [x] PR → ALFMOB-467 (#103)
- [x] Ticket → Review
- [x] Report
