# Phase 1 (Foundation) — dev summary

Token-driven typography surface added **alongside** the legacy one (additive). Legacy
`header/paragraph/small/tiny` remain untouched so the build stays green; they are removed in Phase 5.

## Verify banner

```
✅ VERIFICATION PASSED (build + unit tests; integration skipped)
```

Command: `./Alfie/scripts/verify.sh --skip-integration` (from worktree root). All 13 new typography
tests ran and passed.

## Libre Baskerville PostScript name

`LibreBaskerville-Regular` (also the `.dataset` file name and the `FontNames` rawValue).
Family name (`UIFont.familyName`): `Libre Baskerville` (== `Primitives.Typography.fontFamilyBrand`).
TTF sourced from Google Fonts (`fonts.gstatic.com`, OFL 1.1, v24), 106 KB, verified TrueType.

## Files added

- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Helpers/TypographyStyle+Font.swift`
  — `UIFont.Weight(tokenWeight:)`, `TypographyStyle.uiFont`, `AttributedString.build(style:underline:strike:foregroundColor:backgroundColor:)`.
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/ThemedTypographyStyle.swift`
  — `ThemedTypographyStyle` value type (`callAsFunction(String, underline:, strike:)`, `.uiFont`).
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Specifications/TypographyGroups.swift`
  — per-Figma-group protocols + concrete impls.
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Resources/Fonts.xcassets/LibreBaskerville-Regular.dataset/`
  (`LibreBaskerville-Regular.ttf` + `Contents.json`).
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Resources/LibreBaskerville-OFL.txt` (SIL OFL 1.1).
- `Alfie/AlfieKit/Tests/SharedUITests/Typography/TypographyStyleFontTests.swift`
- `Alfie/AlfieKit/Tests/SharedUITests/Typography/TypographyProviderTokenTests.swift`

## Files edited

- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/TypographyProvider.swift`
  — added `display/heading/body/label/link` to protocol + concrete provider (legacy members kept).
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Helpers/FontNames.swift`
  — added `case libreBaskerville = "LibreBaskerville-Regular"` (+ `fileName` mapping). `registerAll()`
    loops `allCases`, so it auto-registers via the existing `AlfieApp.swift:24` launch hook.
- `Alfie/AlfieKit/Package.swift`
  — added `.copy("Theme/Typography/Resources/LibreBaskerville-OFL.txt")`. (The `.dataset` lives inside
    the already-declared `.process(...Fonts.xcassets)` resource — no Package change needed for the TTF.)

## Caveats

- `FontNames.withSize(_:)` calls `assertionFailure` if the named font is not yet registered
  (pre-existing behaviour, also true for `sfProMedium`). Brand/legacy faces therefore must be
  registered before use; in the real app this happens at launch via `FontManager.registerAll()`
  (`AlfieApp.swift:24`). The unit tests call `FontManager.registerAll()` in `setUp`.
- Custom-font weight traits are not asserted for the brand (`Display`) styles — only for SF Pro —
  because a registered custom face carries its own descriptor weight.
- No `LocalizedStringResource` `callAsFunction` overload (red-team H1): L10n is `String`-typed.
- Visual/snapshot coverage is out of scope (accepted); no call sites migrated in this phase.

## New public symbols (for the migration team)

- `extension UIFont.Weight { init(tokenWeight: Int) }`
- `extension TypographyStyle { var uiFont: UIFont }`
- `extension AttributedString { func build(style:underline:strike:foregroundColor:backgroundColor:) -> AttributedString }`
- `struct ThemedTypographyStyle { let style: TypographyStyle; var uiFont: UIFont; func callAsFunction(_:underline:strike:) -> AttributedString }`
- Group protocols + concrete types:
  - `TypographyDisplayProtocol` / `TypographyDisplay` — `large, medium, small`
  - `TypographyHeadingProtocol` / `TypographyHeading` — `large, medium, small, xSmall`
  - `TypographyBodyProtocol` / `TypographyBody` — `large, medium, mediumStrikethrough, small`
  - `TypographyLabelProtocol` / `TypographyLabel` — `small, smallBold`
  - `TypographyLinkProtocol` / `TypographyLink` — `medium, small`
- `TypographyProviderProtocol` / `TypographyProvider` new accessors: `display, heading, body, label, link`
  (each returns the matching group; legacy `header, paragraph, small, tiny` unchanged).
- `FontNames.libreBaskerville` (rawValue `"LibreBaskerville-Regular"`).

Usage: `theme.font.heading.large("x")`, `theme.font.body.medium("x", underline: true)`,
`theme.font.display.large.uiFont`.
