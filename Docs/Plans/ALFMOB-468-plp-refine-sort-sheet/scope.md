# Scope — ALFMOB-468 PLP Refine & Sort sheet restyle

Visual-only token migration. Confirmed premise is **accurate** (legacy refs present).

## Files to change

### 1. `Alfie/AlfieKit/Sources/ProductListing/UI/ProductListingFilter.swift` (the sheet)
Legacy refs found:
- `Primitives.Spacing.spacing8/24/16` — lines 32, 35, 38, 64, 83 → `theme.spacing.space*`
- `Primitives.Colours.neutrals900` — line 56 (close icon tint) → semantic `Theme.*` content
- `Primitives.Colours.neutrals800` — line 79 (list-style label) → semantic `Theme.*` content
- `Constants.listStyleFontSize: CGFloat = 18` + `DesignSystem.shared.font...withSize(18)` — lines 86-89 → theme font ramp (remove hardcoded size)
- Already consumes `ThemedDivider`, `ThemedButton`, `ThemedIcon`, `ThemedToolbarTitle`. ✅

### 2. `Alfie/AlfieKit/Sources/SharedUI/Components/SortBy/SortByView.swift` (sort list rendered in sheet)
Legacy refs found:
- `Primitives.Spacing.spacing8/12/16` — lines 24, 27, 35, 43, 44, 48, 49, 50, 64 → `theme.spacing.space*`
- `Primitives.Colours.neutrals800 / neutrals100` — lines 21, 42, 47, 72 → semantic `Theme.*`
- `Constants.titleFontSize` + `DesignSystem.shared.font...withSize(...)` — line 79 → theme font ramp
- **Blast radius:** only production consumer is this sheet; also used by `DebugMenu/DemoSortByView` (debug demo) + its own `#Preview`. Low risk.

### Not touched
- `Helpers/SortByHelper.swift` — pure data (icons/titles), no styling. No change needed despite ticket mention.
- PLP grid / filter bar, filter/sort logic, dark mode — explicitly out of scope.

## Reference
- Token API: `@Environment(\.theme)` for `theme.spacing.*`; static `Theme.*` semantic colours (content/surface/button layers). Follow mapping used in ALFMOB-437/438/439 (commits 5661457 / 797cf1a / f934ba0).
- Figma: https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=168-43764
