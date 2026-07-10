---
title: Refactor Chip to use design tokens (semantic Theme.* + border token + tests)
ticket: ALFMOB-273
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-07-10
---

## Overview
`Chip` already sources colors/spacing/radius/typography from generated tokens (the ticket's
"references legacy `Colors/Spacing/CornerRadius`" premise is stale). User-approved scope: (1) adopt
semantic `Theme.*` color aliases where the alias name genuinely matches the usage, (2) source
`borderNormal` width from `Primitives.Border.borderWeightDefault` (mirrors Badge ALFMOB-269), and
(3) add the missing unit-test coverage. Refactor is **visually a no-op** — every `Theme.*` alias
resolves to the same primitive Chip uses today.

## Acceptance Criteria
- [ ] Chip sources all *available* token values (colors via `Theme.*` where a clean alias exists, else raw `Primitives.Colours.*`; border-normal width via `Primitives.Border.borderWeightDefault`).
- [ ] Selected / unselected / disabled states render **identically** to current `main` (no pixel change).
- [ ] No call-site changes (public API `Chip(configuration:)` / `ChipConfiguration` / `ChipType` unchanged; only `#Preview` + `ChipsDemoView` use Chip).
- [ ] State→style mapping + counter-label logic covered by SPM unit tests (snapshots excluded — suite disabled repo-wide).

## Approach
Mirror the Badge pattern: extract a small **`ChipStyle`** value type (à la `BadgeHelper`) that
computes `borderColor`, `textColor`, `backgroundColor`, `borderWidth`, and `counterLabel` from
`(type, isSelected, isDisabled, counter)`. `Chip.body` consumes it. This puts the semantic-color
mapping in a plain, `@testable`-reachable type instead of private `View` computed props — the only
clean way to satisfy the coverage AC without snapshots. XCTest + `@testable import SharedUI` to
match the neighbouring `BadgeHelperTests`.

### Semantic color mapping (the crux — DECISIONS for grill)
Chip's colors are all `Primitives.Colours.neutrals*`. Proposed mapping (migrate only where a
`Theme.*` alias name matches the role; else keep raw primitive):

| # | Usage / state | Current | Final (grilled) | Note |
|---|---|---|---|---|
| D1 | border, unselected | `neutrals200` | `Theme.borderSoft` | ✅ clean border alias |
| D2 | border, selected | `neutrals800` | `Theme.contentContentPrimary` | name-mismatch alias accepted |
| D3 | border, disabled | `neutrals100` | `Theme.surfaceForegroundPrimary` | user chose alias over raw |
| D4 | text, default | `neutrals600` | keep raw `neutrals600` | **forced** — NO `Theme` alias at 600 |
| D5 | text, disabled | `neutrals400` | `Theme.contentContentPrimaryDisabled` | ✅ content-disabled |
| D6 | background, default | `neutrals0` | `Theme.surfaceBackgroundPrimary` | ✅ surfaceBackground |
| D7 | background, disabled | `neutrals100` | `Theme.surfaceForegroundPrimary` | user chose alias over raw |
| D8 | border-normal width | `1.0` literal | `CGFloat(Primitives.Border.borderWeightDefault)` | ✅ Badge precedent |

Every `Theme.*` alias resolves to the exact primitive used today → **zero visual change**.
7 of 8 go through `Theme`; only D4 stays a raw primitive — `Theme` has no alias at `neutrals600`,
so routing it through the semantic layer is impossible without adding a generated token (out of scope).

### Structure & tests (grilled)
- **D9 — RESOLVED:** extract an `internal struct ChipStyle` (mirrors `BadgeHelper`) as the `@testable` seam.
- **D10 — RESOLVED:** XCTest + `@testable import SharedUI`, matching `BadgeHelperTests.swift`.

## Phases
Single vertical slice (one file + its test). See `phase-1-chip-tokens.md`.

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Alfie/AlfieKit/Sources/SharedUI/Components/Chips/Chip.swift` | SharedUI | edit | Extract `ChipStyle`; apply `Theme.*` aliases (D1/D5/D6) + border-weight token (D8) | - |
| `Alfie/AlfieKit/Tests/SharedUITests/ChipStyleTests.swift` | SharedUITests | new | Unit tests for state→style mapping + counter-label logic | - |

## Feature Flag
n/a — pure component-internal refactor, no behavior change.

## Testing Strategy
- **Unit (XCTest, `@testable import SharedUI`):** for each state combination assert `ChipStyle`
  returns the expected token value — border (unselected/selected/disabled), text (default/disabled),
  background (default/disabled), border width (normal/selected), height (small/large), and
  `counterLabel` boundaries (`nil`→nil, `1`→"1", `99`→"99", `100`→"99+").
- **Snapshot:** OUT — suite is disabled repo-wide (no target membership / refs).
- **Manual:** `#Preview` + `ChipsDemoView` visually unchanged.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Semantic alias resolves to a *different* primitive → visual change | Low | Aliases verified against `Theme+Generated.swift`; tests assert exact token; only migrate exact-value matches |
| Partial migration looks inconsistent | Med | Documented per-case rationale; grill confirms; consistency with Badge's raw-primitive idiom |
| `Color` equality flaky in tests | Low | Aliases ARE the same static primitives → equality holds; assert against the primitive value |
| Extracting `ChipStyle` changes public API | Low | `ChipStyle` is `internal`; `Chip`/`ChipConfiguration`/`ChipType` signatures untouched |

## Out of Scope
- Tokenizing `borderSelected` (2.0), `heightSmall/Large` (36/44), close-icon size (12) — no token equivalents exist.
- Any call-site or public-API change.
- Snapshot tests.

## Open Questions
None — all decisions (D1–D10) resolved at grill. See `grill.md`.
