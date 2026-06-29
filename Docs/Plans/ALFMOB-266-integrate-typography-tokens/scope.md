# Scope: ALFMOB-266 — Integrate typography tokens

**Branch:** ALFMOB-266-integrate-typography-tokens   **Base:** origin/main (HEAD = ALFMOB-272 codegen)   **Agents:** 3 (Explore)

## Generated token contract (already on main, DO NOT EDIT — `GeneratedTokens/`)
`SharedUI/GeneratedTokens/Typography+Generated.swift`
- `public struct TypographyStyle { fontFamily: String; fontWeight: Int; fontSize: CGFloat; lineHeight: CGFloat; letterSpacing: CGFloat }`
- `public enum Typography` with Figma-named groups → each a `static let` of `TypographyStyle`:
  - `Body`: large(18/400), medium(16/400), mediumStrikethrough(16/400), small(12/400)
  - `Display`: large(24/400), medium(20/400), small(18/400)  — **fontFamily = "Libre Baskerville" (brand)**
  - `Heading`: large(32/500), medium(24/500), small(20/500), xSmall(16/500)
  - `Label`: small(12/400), smallBold(12/500)
  - `Link`: medium(16/500), small(12/500)
- Sizes/lineHeights reference `Primitives.Spacing.spacingNN`; families/kerning reference `Primitives.Typography.*`.

`SharedUI/GeneratedTokens/Primitives+Generated.swift`
- `Primitives.Typography.fontFamilyBrand = "Libre Baskerville"`, `fontFamilyPrimaryIos = "SF Pro"` (also Android "Roboto", Web "Inter")
- `kerningNone = 0.0`, `kerningTight = -0.5`, `kerningSpacious = 1.0`
- Plus `fontSizeFontSize{12..56}` and `lineHeightLineHeight{16..48}` aliases.

DTCG JSON sources (regenerate via `./Alfie/scripts/generate-design-tokens.sh`):
- `SharedUI/DesignTokens/typography.alfie-theme.tokens.json` (atomic family/weight/size/line-height/kerning)
- `SharedUI/DesignTokens/typography.styles.tokens.json` (composite `$type:"typography"` styles; 14 active + 11 deprecated `~~doc-*`)

## Current font system (to wire) — `SharedUI/Theme/Typography/`
- `TypographyProvider.swift`
  - `protocol TypographyProviderProtocol { header; paragraph; small; tiny }` (each a sub-protocol type)
  - `class TypographyProvider`: `init(header:paragraph:small:tiny:)` w/ default impls; calls `FontManager.registerAll()` in preview mode.
- `Specifications/` — legacy protocols, **hardcoded** sizes, all use `FontNames.sfProMedium.withSize(...)`:
  - `TypographyHeaderProtocol`: h1=36, h2=24, h3=20 (+ `h3Underline`); `UIFont` props + `(String)->AttributedString` + LocalizedStringResource variants.
  - `TypographyParagraphProtocol`: normal/normalItalic/bold/boldItalic = 16; +Underline/+Strike variants.
  - `TypographySmallProtocol`: …=14; same variant set.
  - `TypographyTinyProtocol`: …=12; normal/italic/bold/boldItalic/boldUnderline.
- `Helpers/Font+Extensions.swift`
  - `AttributedString.build(font:UIFont, lineHeight:, letterSpacing:, strike:, isUnderlined:, foregroundColor:, backgroundColor:) -> AttributedString` — applies `.kern`, underline/strike, `NSParagraphStyle` lineHeight.
  - `UIFont.font` (`UIFont -> SwiftUI.Font`) bridge (~line 216).
- `Helpers/FontNames.swift`
  - `enum FontNames { case sfProMedium }` → name `"SF Pro Display Medium"`, file `"SF-Pro-Display-Medium"`; `withSize(_:) -> UIFont` via `UIFont(name:size:)`.
  - `enum FontManager { registerAll() throws; registerFont(named:) throws }` — loads `NSDataAsset`, `CTFontManagerRegisterGraphicsFont`.
- `Resources/` — `SF-Pro-Display-Medium.otf` (root + `Fonts.xcassets/SF-Pro-Display-Medium.dataset`).

## Exposure / injection — `SharedUI/Theme/ThemeProvider.swift`
- `protocol ThemeProviderProtocol { var font: TypographyProviderProtocol { get } ... }`
- `class ThemeProvider { static var shared; init(font: = TypographyProvider()) }`; `setupAppearance()` uses `font.header.h3`.
- Views access via `View+Extension.swift`: `var theme: ThemeProviderProtocol { ThemeProvider.shared }` (also ViewModifier+Extension). No scattered `@Environment`.

## Backward-compat surface (blast radius)
- **~250 usages of `theme.font.*` across ~73 files** (header/paragraph/small/tiny). DebugMenu/Demo ≈90; SharedUI/Components ≈80; Theme infra ≈40; feature modules ≈40.
- Central render path: `Text.build(...)` wrapper (50+) + `AttributedString.build(...)`.
- `.font(Font(theme.font.…))` SwiftUI modifiers (~30); `UIFont.withSize(...)` mutations (11 sites, e.g. PriceComponentView).
- `ThemeProvider.shared.font` direct refs (12); configuration-mediated injection in VerticalProductCard; ErrorView pre-wraps fonts.

## Tests
- **XCTest only** (no Swift Testing). `SnapshotTesting` present (`AlfieTests/Snapshots/*`, `Helpers/Snapshotting+Extension.swift` precision 0.9, iPhone 15 Pro) — but snapshot tests carry "target membership removed pending verification" TODOs.
- **No** existing tests for TypographyProvider / FontManager / generated tokens; **no** ThemeProvider/Typography mocks.

## Key open questions (for ios-plan / ios-grill / approval)
1. **API shape:** keep legacy `header/paragraph/small/tiny` protocols and source their values from `Typography.*` tokens (backward-compat, no call-site churn) vs. introduce Figma-named API now. Epic ADR (ALFMOB-293) wants Figma names; THIS story's AC says protocols keep working & "access patterns still work". Renaming = ALFMOB-267 territory (250 call sites).
2. **Size/family/weight mapping gaps:**
   - `header.h1 = 36pt` has **no** token (max Heading = 32). Map to `Heading.large`(32) or keep 36?
   - `small = 14pt` has **no** 14pt token. Map to which token?
   - Tokens use `"Libre Baskerville"` (Display/brand) — **not bundled** today (AC: must bundle+register). Is the OTF available in the design-tokens repo?
   - Tokens use `"SF Pro"` with weights 400/500; today only one custom `SF-Pro-Display-Medium.otf`. Map weights to system SF Pro (`UIFont.systemFont(weight:)`) or bundle additional faces?
3. **Weight type:** generated `fontWeight: Int` (400/500) → need Int→UIFont.Weight (or face) mapping helper.
4. **Test strategy:** add unit tests asserting provider values equal token values; snapshot infra exists but is currently disabled.
