# Scout Report: Badge component styling (ALFMOB-269)

**Branch**: ALFMOB-269-refactor-badge-tokens   **Agents**: 0 (direct read — single module, 3 small files)

## Relevant Files
### Package: SharedUI (component under refactor)
- `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeViewModifier.swift` — capsule/indicator overlay badge; `Constants` enum holds hardcoded sizing; public `View.badgeView(...)`.
- `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeTabViewModifier.swift` — UITabBarItem badge appearance; public `View.tabItemBadge(...)`.
- `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeHelper.swift` — label/visibility logic (maxVal=99 → "99+"). No styling. Out of scope.

### Generated tokens (READ-ONLY — never edit)
- `SharedUI/GeneratedTokens/Sizing+Generated.swift` — `radiusRounded=1000`, `radiusSoft=4`, `radiusStrong=16`, `iconsIconSmall=16`, icon/interactive sizes.
- `SharedUI/GeneratedTokens/Primitives+Generated.swift` — `Primitives.Spacing.spacing{0,2,4,8,12,14,16,...}`, `Primitives.Colours.*`.
- `SharedUI/GeneratedTokens/Theme+Generated.swift` — semantic layer (surface/content/button/link). Relevant: `surfaceBackgroundDestructive`(=semanticError600), `contentContentInvertedPrimary`(=neutrals0), `surfaceBackgroundPrimary`(=neutrals0).
- `SharedUI/GeneratedTokens/Typography+Generated.swift` — `theme.font.body.small` already used.

### Call sites (public API — must NOT change; AC #4)
- `SharedUI/Components/Toolbar/ThemedToolbarButton.swift:69,74` — `.badgeView(badgeValue:)`
- `AppFeature/UI/TabBarItemView.swift:42` — `.badgeView(badgeValue:)`
- `DebugMenu/UI/Demo/Indicators/BadgeDemoView.swift` (×11) — demo/preview only
- `tabItemBadge(...)` — **no production call sites found** (only the modifier itself). Keep per AC #2 ("both variants work"), but note it's currently unreferenced.

### Tests
- `Alfie/AlfieKit/Tests/SharedUITests/BadgeHelperTests.swift` — covers `BadgeHelper` label/visibility logic only. No styling/appearance tests exist.

## Patterns Observed — IMPORTANT (ticket premise is partly stale)
The badges are **already partially token-migrated**, contrary to the ticket's "Current styling: directly references `Colors.*` and hardcoded sizing":
- **Colors**: already `Primitives.Colours.semanticError600` (bg) and `Primitives.Colours.neutrals0` (text + stroke). No legacy `Colors.*` references remain.
- **Typography**: already `theme.font.body.small` (SwiftUI) / `theme.font.body.small.uiFont` (UIKit tab).
- **Corner radius**: already `Sizing.radiusRounded`.

**Actual remaining work = the hardcoded `Constants` sizing in `BadgeViewModifier`:**
| Constant | Value | Candidate token |
|---|---|---|
| `badgeHeight` | 16 | `Primitives.Spacing.spacing16` (or `Sizing.iconsIconSmall`) |
| `textPadding` | 4 | `Primitives.Spacing.spacing4` |
| `indicatorHeight` | 12 | `Primitives.Spacing.spacing12` |
| `indicatorWidth` | 12 | `Primitives.Spacing.spacing12` |
| `borderLineWidth` | 1 | no token (no spacing1) — keep literal |
| `capsuleOffsetXFactor` | 3 | layout multiplier, not a token — keep literal |
| `badgePadding` | 4 | **UNUSED dead constant** |

## Unresolved Questions (for plan/grill)
1. **Semantic vs primitive colors**: elevate `Primitives.Colours.*` → semantic `Theme.*` (`surfaceBackgroundDestructive`, `contentContentInvertedPrimary`)? Memory note prefers the semantic layer for component refactors. Values are identical, so no visual change.
2. **Dead `badgePadding`**: remove while refactoring the `Constants` enum, or leave (pre-existing dead code)?
3. **No-token values** (`borderLineWidth=1`, `capsuleOffsetXFactor=3`): leave as literals — no matching token.
4. **Verification of AC #2** ("renders correctly with 1/9/99/999+"): no snapshot suite (disabled repo-wide per memory). How to assert appearance — SPM unit tests on token wiring, or rely on `BadgeHelper` label tests + build?
