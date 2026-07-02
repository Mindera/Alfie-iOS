# ALFMOB-266 — dev-1 (SharedUI typography call-site migration)

Mechanical migration of every SharedUI call site off the legacy `theme.font.{header,paragraph,small,tiny}.*`
API onto the token-driven `theme.font.{heading,body,display,label,link}.*` API added in the foundation
commit. Branch: `ALFMOB-266-dev1-sharedui` (based on `ALFMOB-266-integrate-typography-tokens`).

## Result

- **29 files migrated** (entire SharedUI scope).
- **Grep gate passes**: `grep -rnE '\.font\.(header|paragraph|small|tiny)' Alfie/AlfieKit/Sources/SharedUI --include='*.swift'`
  returns nothing.
- **17 UIFont-typed sites** correctly carry `.uiFont`; **all function-call sites** rename cleanly to
  `callAsFunction`.
- Did NOT touch `Theme/Typography/` internals (foundation + legacy specs, owned/deleted elsewhere),
  DebugMenu, or feature modules.

## Mapping applied

| Legacy | New |
|---|---|
| `.header.h1` | `.heading.large` |
| `.header.h2` | `.heading.medium` |
| `.header.h3` | `.heading.small` |
| `.header.h3Underline(x)` | `.heading.small(x, underline: true)` |
| `.paragraph.normal/bold(x)` | `.body.medium(x)` |
| `.paragraph.boldUnderline(x)` | `.body.medium(x, underline: true)` |
| `.small.normal/bold(x)` | `.body.small(x)` |
| `.small.boldUnderline(x)` | `.body.small(x, underline: true)` |
| `.tiny.normal(x)` | `.body.small(x)` |
| UIFont site (bare / `.withSize` / `Font(...)` / `font:` param) | append `.uiFont` |

bold/italic distinctions dropped per spec (tokens carry weight); underline preserved via the param.

## Files changed (29)

Components: ForceAppUpdateView, ProductCarouselHeader, Chip, ErrorView, BadgeTabViewModifier,
BadgeViewModifier, PaginatedControl, PriceComponentView, HorizontalProductCard,
VerticalProductCardConfiguration+Extension, SnackbarView, SortByView, TabControl, Tag,
ThemedToolbarButton, ThemedToolbarTitle, MultilineShimmerEffectModifier.
Theme: AccordionView, ThemedButton, Checkbox, LoaderView, ThemedLoaderView, RadioButton,
ThemedSearchBarView, ColorAndSizingSelectorHeaderView, SizingSwatchView, ThemedInput, ThemedModal,
ThemedSegmentedView.

## Sites that needed judgment

1. **ErrorView.swift (lines 78, 80)** — legacy passed the typography method as a function reference
   to `Optional.flatMap` (`title.flatMap(ThemeProvider.shared.font.paragraph.bold)`). The new
   `ThemedTypographyStyle` is a callable value, not a `(String) -> AttributedString` function value,
   so it cannot be passed by reference. Rewrote as `title.map { ThemeProvider.shared.font.body.medium($0) }`.
   `title`/`message` are `String?`; target params are `AttributedString?`; `String?.map` over a
   `(String) -> AttributedString` closure yields `AttributedString?` — type-correct.

2. **VerticalProductCardConfiguration+Extension.swift (`smallTextFont`)** — after mapping, both the
   `.small/.medium` case (`.tiny.normal`) and the `.large` case (`.small.normal`) collapse to
   `.body.small.uiFont`, so the two switch arms are now identical. Left the switch structure intact
   (mechanical refactor; not redesigning). The integrate/cleanup step may choose to flatten it.

3. **Chained UIFont sites** — `.uiFont.withSize(n)` (ThemedToolbarButton, ThemedToolbarTitle,
   PriceComponentView ×2, SortByView) and `.uiFont.withSize(n).font` (SortByView) verified: `withSize`
   and `.font` are UIFont members, so `.uiFont` must come first.

## Nothing uncertain about types

All call args are `String`-typed (no `LocalizedStringResource` call sites in SharedUI), so the
String-only `callAsFunction` overload is sufficient — no missing-overload risk. Full build deferred to
the integrate step's `verify.sh` per instructions, but every site was type-checked by hand.
