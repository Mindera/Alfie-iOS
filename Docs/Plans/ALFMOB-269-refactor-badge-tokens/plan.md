---
title: Refactor Badge component to use design tokens
ticket: ALFMOB-269
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-07-09
---

## Overview
Finish migrating the SharedUI Badge overlay (`BadgeViewModifier`) and tab-item badge
(`BadgeTabViewModifier`) onto the generated design-token system. Colors, typography, and corner
radius are **already** token-based; the remaining gap is the hardcoded numeric sizing in
`BadgeViewModifier.Constants`. This plan also elevates the color references from raw `Primitives.*`
to the semantic `Theme.*` layer (identical values → zero visual change), the layer the design
system intends component code to consume. Public API (`badgeView`, `tabItemBadge`) is unchanged,
so no call site changes (AC #4).

## Acceptance Criteria (feature-level)
- [ ] AC1 — Badge uses token values for all visual properties: background, text color, border, sizing, typography.
- [ ] AC2 — Badge renders correctly across count values (1, 9, 99, >99 → "99+"). *(label logic; already covered by `BadgeHelperTests`)*
- [ ] AC3 — Both variants (`BadgeViewModifier` capsule/indicator + `BadgeTabViewModifier` tab) work correctly.
- [ ] AC4 — Existing call sites do not need changes (public modifier API unchanged).

## Approach
Single vertical slice — a styling-token substitution across two files in one module. No state,
navigation, networking, DI, or localization surface. Values map 1:1 so there is **no intended
visual change**; correctness = "compiles, existing tests green, call sites untouched, values
identical."

**Token mapping**

*Sizing* (`BadgeViewModifier.Constants`, currently raw literals) → `Primitives.Spacing.*`
(there are no badge-specific semantic `Sizing.*` tokens; `Sizing` itself is defined in terms of
`Primitives.Spacing`, so consuming spacing primitives for raw dimensions is consistent):
| Constant | Value | Token |
|---|---|---|
| `badgeHeight` | 16 | `Primitives.Spacing.spacing16` |
| `textPadding` | 4 | `Primitives.Spacing.spacing4` |
| `indicatorHeight` | 12 | `Primitives.Spacing.spacing12` |
| `indicatorWidth` | 12 | `Primitives.Spacing.spacing12` |
| `borderLineWidth` | 1 | **no token** (no `spacing1`) — keep literal `1.0` |
| `capsuleOffsetXFactor` | 3 | layout multiplier, not a design value — keep literal `3` |
| `badgePadding` | 4 | **unused dead constant** — remove (recommended) |

*Colors* — elevate `Primitives.*` → semantic `Theme.*` (identical underlying values):
| Element | Current | Proposed `Theme.*` | Underlying |
|---|---|---|---|
| Badge/indicator fill | `Primitives.Colours.semanticError600` | `Theme.surfaceBackgroundDestructive` | semanticError600 |
| Badge text | `Primitives.Colours.neutrals0` | `Theme.contentContentInvertedPrimary` | neutrals0 |
| Border stroke | `Primitives.Colours.neutrals0` | `Theme.surfaceBackgroundPrimary` | neutrals0 |
| Tab badge color (UIKit) | `Primitives.Colours.semanticError600.ui` | `Theme.surfaceBackgroundDestructive.ui` | semanticError600 |
| Tab badge text (UIKit) | `Primitives.Colours.neutrals0.ui` | `Theme.contentContentInvertedPrimary.ui` | neutrals0 |

*Typography / radius* — already token-based (`theme.font.body.small`, `Sizing.radiusRounded`);
no change.

## Phases
Single phase — see `phase-1-badge-tokens.md`.

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeViewModifier.swift` | SharedUI | edit | Sizing constants → `Primitives.Spacing.*`; colors → `Theme.*`; drop dead `badgePadding` | - |
| `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeTabViewModifier.swift` | SharedUI | edit | UIKit badge colors → `Theme.*.ui` | - |
| `Alfie/AlfieKit/Tests/SharedUITests/BadgeHelperTests.swift` | SharedUITests | edit (optional) | add explicit `1` and `9` label cases to trace AC2 enumeration | - |

## Feature Flag
n/a — pure styling refactor of a shared component; no behavioral change, no rollout risk.

## Testing Strategy
- **Unit**: existing `BadgeHelperTests` (label logic) must stay green. Optionally add `1`/`9`
  label cases so AC2's enumeration is literally traceable (marginal value; label logic already
  covered at boundaries).
- **Snapshot**: none — snapshot suite is disabled repo-wide with no committed refs (project
  memory). Not introducing one for a zero-value-change substitution.
- **UI**: none needed — no new accessibility surface, public API unchanged.
- **Manual/visual**: `DebugMenu/UI/Demo/Indicators/BadgeDemoView.swift` (11 badge variants) via
  SwiftUI preview / debug menu — confirm badge + indicator render identically before/after.
- **Gate**: `./Alfie/scripts/verify.sh` green (build + unit; `--skip-integration` acceptable —
  no BFF surface touched).

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Semantic `Theme.*` token drifts from badge intent later (e.g. `surfaceBackgroundDestructive` remapped) and silently changes the badge | Low | Values identical today; badge already coupled to `semanticError*`. Documented mapping. Revisit only if a badge-specific token is added. |
| `spacing12`/`spacing16` differ subtly from the old literals | None | Verified equal: `spacing12`=12.0, `spacing16`=16.0, `spacing4`=4.0. |
| Removing `badgePadding` breaks a hidden reference | None | Grepped — zero references (dead constant). |

## Out of Scope
- Changing the 99-cap behavior. AC lists "999+" but the badge intentionally shows "99+" for any
  value >99 (`BadgeHelper.maxVal=99`). Token refactor must not alter this.
- Adding snapshot infrastructure.
- Touching `BadgeHelper.swift` (pure logic, no styling).
- `borderLineWidth`/`capsuleOffsetXFactor` (no matching tokens).

## Decisions (grilled 2026-07-09 — see grill.md)
1. **Elevate to `Theme.*`.** ✓ Migrate colors to the semantic layer (matches ALFMOB-271
   ThemedButton precedent + project memory; zero visual change).
2. **Border-stroke → `Theme.surfaceBackgroundPrimary`.** ✓ The ring reads as the surface behind
   the badge (resolves to neutrals0, identical to today).
3. **Remove dead `badgePadding`.** ✓ Orphan inside the enum being refactored; removal authorized.
4. **No extra label tests.** Value-below-max (99→"99") and above-max (147/1000→"99+") paths are
   already covered by `BadgeHelperTests`; `1`/`9` hit the identical branch. Step 4 of phase-1 dropped.
