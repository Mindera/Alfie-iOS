# Grill: Iconography — reconcile icon set with Figma
**Plan**: Docs/Plans/ALFMOB-426-iconography-figma/plan.md   **Ticket**: ALFMOB-426   **Date**: 2026-07-13   **Branch**: feat/ALFMOB-426-iconography-figma

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | Design dependency (mappings flagged "resolve at refinement") | Proceed w/ full provisional mapping (decoupled → cheap to re-map) | User drove the mapping per-icon | D1 mapping finalized by user |
| 2 | Bucket B ambiguous mappings | grid→Grid1, listplp→Grid2, list→MenuAlt, info→Help, closeCircleFill→Clear, logOut→Exit, arrowRight→Forward, refresh/reload→Loading | **grid→Grid 2, listplp→Grid 1** (swapped); rest as recommended | D1 |
| 3 | Unused SF cases | check usage; delete if unused | Delete 26 unused + 5 demo-only (incl. eye) = 31 | D3 + Phase 2 step 1/1b |
| 4 | Retained SF fallbacks | keep production-used only | 10 kept (aCircle,zCircle,arrowLeft,chartUp/DownTrend,chat2,location,logIn,rewards,store) | D2 |
| 5 | Asset format / breadth / fill / naming / coverage | SVG+template / minimal migration / separate cases / stable names / unit tests | Accepted as recommended | D4 |
| 6 | PR must list remaining SF symbols | — | User requested: include D2 fallback list in PR body | PR note added |

## Answered by the codebase (not asked)
- SharedUI resources are explicitly enumerated in `Alfie/AlfieKit/Package.swift` (`.process(...)`); new `Icons.xcassets` must be added there — not auto-discovered. (Package.swift ≠ project.pbxproj → editable.)
- `SharedUITests` target + `Alfie/AlfieKit/Tests/SharedUITests/` dir exist → test home confirmed.
- Icon size tokens `Sizing.iconsIcon{Small,Medium,Large,Xlarge}` = 16/24/32/40 already exist, unused.
- Snapshot suite disabled repo-wide → coverage via SPM unit tests (project fact).
- 36 cases referenced by name, 40 only via `allCases`, no tests reference Icon (scope.md).
- Bucket C usage verified by grep; false positives (`.store(in:)`, `NSLock.lock()`, `.tabViewStyle(.page)`, `URLSession.upload`) excluded.

## Assumptions surfaced
- iOS keeps native Back (=chevron-left) & Share (iOS glyph); Android variants not bundled.
- `info`+`help` share the `help` asset; `refresh`+`reload` share the `loading` asset (two cases → one glyph, allowed).
- Deleting cases only trims `Icon.allCases` (demo grids) — no app-UI impact; 4 demo files need small edits.

## Still open (owner)
- **Design sign-off on the mapping** (esp. semantic ones: heart→Wishlist, warning→Alert, filter→Refine, list→Menu Alt, logOut→Exit). Deferred to design review of the PR; architecture makes re-mapping cheap (re-export 1 SVG + edit 1 raw value).
