# Scout Report: Typography rendering system — ALFMOB-267

**Branch:** ALFMOB-267-typography-label-tokens   **Agents:** 2

## Core typography system (all under `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/`)
- `TypographyProvider.swift:5-34` — `TypographyProviderProtocol` (`header`/`paragraph`/`small`/`tiny`) + concrete provider instantiating the 4 spec classes.
- `Specifications/TypographyHeaderProtocol.swift:31-33` — **HARDCODED** `h1=withSize(36)`, `h2=24`, `h3=20`; plus AttributedString builders (:37-76).
- `Specifications/TypographyParagraphProtocol.swift:45-48` — **HARDCODED** normal/normalItalic/bold/boldItalic = 16; builders :52-134.
- `Specifications/TypographySmallProtocol.swift:41-44` — **HARDCODED** = 14; builders :48-130.
- `Specifications/TypographyTinyProtocol.swift:32-35` — **HARDCODED** = 12; builders :39-88.
- `Helpers/FontNames.swift:9` — **HARDCODED** single family `sfProMedium = "SF Pro Display Medium"`; `withSize(_:)` :18-24 builds `UIFont(name:size:)`, falls back to empty `UIFont()`.
- `Helpers/Font+Extensions.swift:8-41` — `AttributedString.build()` combines font/lineHeight/letterSpacing/strike/underline (`kern` :28-29, `lineSpacing` :37-39). `:67-123` `NSAttributedString.fromHtml()` with **hardcoded** lineHeight offset (`lineHeight ?? fontSize + 8.0` :87).

## Generated token API (READ-ONLY — do not edit `GeneratedTokens/`)
- `GeneratedTokens/Typography+Generated.swift` — `struct TypographyStyle { fontFamily: String; fontWeight: Int; fontSize: CGFloat; lineHeight: CGFloat; letterSpacing: CGFloat }`.
  Categories: `Typography.Body` (large/medium/mediumStrikethrough/small), `Typography.Display` (large/medium/small), `Typography.Heading` (large/medium/small/xSmall), `Typography.Label` (small/smallBold), `Typography.Link` (medium/small).
- `GeneratedTokens/Primitives+Generated.swift:63-88` — families: `fontFamilyBrand="Libre Baskerville"`, `fontFamilyPrimaryIos="SF Pro"`; weights: `fontWeightRegular=400`, `fontWeightMedium=500`; kerning none/tight/spacious; lineHeights aliased to Spacing.

## Consumers with hardcoded font sizes (app target + SharedUI)
- `SharedUI/.../ThemedToolbarTitle.swift:54` — `paragraph.normal.withSize(18)`.
- `SharedUI/.../ThemedToolbarButton.swift:72` (const :19 = 18.0).
- `SharedUI/.../PriceComponentView.swift:55-94,158,209` — 12/14/16 variants via `.withSize(textSize)`.
- `SharedUI/.../SortByView.swift:79` — `paragraph.normal.withSize(18)`.
- `Theme/HtmlText/ThemedHtmlText.swift:14-19` — NSAttributedString HTML parse, no token routing.

## ThemeProvider wiring
- `Theme/DesignSystem.swift:12,27,29,36,42` — `font: TypographyProviderProtocol` (default `TypographyProvider()`, swappable); `setupAppearance()` uses `font.header.h3`.

## Tests
- `AlfieKit/Tests/SharedUITests/StyleGuideTests.swift` — **empty placeholder** (no typography assertions).
- Snapshot tests (page-level, not typography-isolated): `AlfieTests/Snapshots/{ProductDetails,Brands,Categories,Search,Shop}ViewSnapshotTests.swift`; helper `AlfieTests/Helpers/View+Snapshots.swift`.
- `DebugMenu/UI/Demo/Typography/TypographyDemoView.swift` — renders every scale (visual verification).

## ⚠️ BLOCKER inherited from base branch (must fix to build)
- `GeneratedTokens/Typography+Generated.swift:40` — `Body.mediumStrikethrough` has `fontWeight: Primitives.Typography.fontFamilyPrimaryIos` (a `String`) assigned to the `Int fontWeight` field → **hard compile error in SharedUI**, blocks the whole build.
- **Source JSON is correct**: `typography.alfie-theme.tokens.json:54` `body-medium-strikethrough-font-weight` → `{typography-font-weight-regular}` (=400). The fault is in the **generator** `Tools/DesignTokenGen` (mis-resolves the strikethrough variant's font-weight to the family primitive). Generated files are do-not-edit → fix must be in the generator + `./Alfie/scripts/generate-design-tokens.sh` regenerate.
- Prerequisite phase for ALFMOB-267 (Phase 1 landed this broken file on `claude/affectionate-hodgkin-b608a2`).

## Key open questions / risks for planning
1. **Mapping is not 1:1.** Current scales (h1 36 / h2 24 / h3 20 / paragraph 16 / small 14 / tiny 12) don't map cleanly onto token categories (Heading large/medium/small/xSmall, Body large=18/…, Display, Label, Link). Token sizes differ from current hardcoded sizes (e.g. Body.large=18 vs paragraph.normal=16) → **migration will change rendered output**. Need an explicit scale→token map.
2. **UIFont construction from tokens.** `TypographyStyle` gives `fontFamily:String` + `fontWeight:Int`; current path is `UIFont(name:"SF Pro Display Medium")`. Need a family+weight→UIFont resolver (system font vs named). SF Pro is a system font; "SF Pro Display Medium" is a specific PostScript name.
3. **lineHeight & letterSpacing** exist in tokens but the spec `UIFont` vars don't carry them; they're applied only in `AttributedString.build()`. Decide whether specs expose full `TypographyStyle` or stay UIFont-only.
4. **Consumers using `.withSize(N)`** (toolbar 18, price 12/14/16) have no matching scale — decide keep-as-override vs map to a token.
5. **No unit tests** currently guard typography → add tests asserting specs read token values.
