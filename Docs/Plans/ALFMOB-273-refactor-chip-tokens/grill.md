# Grill: Refactor Chip to use design tokens

**Plan**: Docs/Plans/ALFMOB-273-refactor-chip-tokens/plan.md   **Ticket**: ALFMOB-273   **Date**: 2026-07-10   **Branch**: ALFMOB-273-refactor-chip-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| Q1 | How to make state→style logic unit-testable | Extract `ChipStyle` type (mirrors `BadgeHelper`) | Extract `ChipStyle` type | D9 resolved; phase-1 step 1 = extraction |
| Q2 | disabled `neutrals100` (border+bg): raw vs name-mismatched alias | Keep raw primitive | Use `Theme.surfaceForegroundPrimary` alias | D3 & D7 → `Theme.surfaceForegroundPrimary` |
| Q3 | selected border `neutrals800`: which Theme alias (principle = don't use Primitives directly) | `Theme.contentContentPrimary` | `Theme.contentContentPrimary` | D2 → `Theme.contentContentPrimary` (was raw) |

## Answered by the codebase (not asked)
- D1/D5/D6/D8 mappings — `Theme+Generated.swift:7,23,33` + `Primitives+Generated.swift:8` confirm each alias equals the exact primitive Chip uses today (`borderSoft`=neutrals200, `contentContentPrimaryDisabled`=neutrals400, `surfaceBackgroundPrimary`=neutrals0, `borderWeightDefault`=1) → zero visual change.
- D4 (default text neutrals600) stays raw — **no `Theme.*` alias exists at `neutrals600`** (grep of `Theme+Generated.swift` = 0 matches); routing it through the semantic layer would require a new generated token (out of scope). This is the sole remaining direct `Primitives` reference.
- D10 test framework = XCTest — `BadgeHelperTests.swift:2` uses XCTest + `@testable import SharedUI`; mirror the neighbour.
- "No call-site changes" achievable — scout: only `#Preview` + `ChipsDemoView.swift:17` construct `Chip`; public API untouched.
- Snapshots excluded — memory `project_snapshot_suite_disabled`: suite is out of target membership repo-wide.

## Assumptions surfaced
- The refactor is a pure semantic/naming change: every `Theme.*` alias is a static forwarder to the same `Primitives.Colours.*`, so appearance is provably unchanged; tests assert the state→token mapping as a regression guard.
- `ChipStyle` is `internal` (not public) — introducing it does not alter Chip's public surface.

## Still open (owner)
- None.
