## Phase 1: Foundation — bridge + brand font + Figma provider (additive)

### Goal
Stand up the token-driven typography surface **alongside** the legacy one so nothing breaks yet:
the `TypographyStyle→UIFont`/`AttributedString.build(style:)` bridge, the registered brand font,
and the new `theme.font.display/heading/body/label/link.*` groups built on tokens.

### Acceptance criteria
- [ ] `TypographyStyle.uiFont` → `UIFont` with `pointSize == fontSize`, weight per D5;
  `fontFamily == Primitives.Typography.fontFamilyPrimaryIos` ("SF Pro") → `systemFont(ofSize:weight:)`
  (NOT `UIFont(name:)`); `== fontFamilyBrand` ("Libre Baskerville") → `FontNames.libreBaskerville`
  custom font (safe fallback, no crash).
- [ ] `AttributedString.build(style:underline:strike:)` delegates to existing
  `build(font:lineHeight:letterSpacing:…)`, passing `style.lineHeight` into the `lineHeight` slot
  (existing convention → `paragraphStyle.lineSpacing`).
- [ ] `ThemedTypographyStyle` supports `callAsFunction(String, underline:, strike:)` (String only —
  no `LocalizedStringResource` overload) and `.uiFont`.
- [ ] Provider exposes `display/heading/body/label/link` (each style → `ThemedTypographyStyle`),
  **legacy `header/paragraph/small/tiny` still present**; `theme.font.heading.large("x")` etc. work.
- [ ] Libre Baskerville Regular bundled; **registered at runtime via the existing
  `AlfieApp.swift:24 FontManager.registerAll()` launch hook** (adding the `FontNames` case suffices —
  do NOT rely on the preview-gated `TypographyProvider.init` call). Unit test registers then resolves
  `UIFont(name: <PostScript>)` non-nil.
- [ ] `./Alfie/scripts/verify.sh` green (both APIs compile; no call sites changed yet).
- [ ] No external conformers to `TypographyProviderProtocol`/legacy sub-protocols exist (confirmed by
  red-team) → adding the 5 group members to the protocol + concrete `TypographyProvider` in one commit
  is safe; no mocks to update.

### Steps
1. **Bridge** (file: `…/Helpers/TypographyStyle+Font.swift`, size: M) — `UIFont.Weight(tokenWeight:)`;
   `TypographyStyle.uiFont` (switch on `fontFamily`: `Primitives.Typography.fontFamilyPrimaryIos` →
   systemFont; brand → `FontNames.libreBaskerville.withSize`); `AttributedString.build(style:…)`.
   TDD: write `TypographyStyleFontTests` first.
2. **Brand font** (files: `…/Helpers/FontNames.swift`, `…/Resources/`, `Fonts.xcassets`, size: M) —
   download Libre Baskerville Regular (OFL 1.1) from `github.com/impallari/Libre-Baskerville` (or
   Google Fonts); add `.ttf` + `.dataset` (mirror `SF-Pro-Display-Medium.dataset` + `Contents.json`)
   + `OFL.txt`; add `case libreBaskerville = "<PostScript name>"`. Registration is already wired:
   `AlfieApp.swift:24` calls `FontManager.registerAll()` (loops `allCases`) at launch, so the new case
   auto-registers in the real app — confirm that hook, don't touch the preview-gated init. Verify the
   PostScript name (Font Book / `fc-scan`).
3. **ThemedTypographyStyle** (file: `…/Typography/ThemedTypographyStyle.swift`, size: S) — value type
   per design in plan.md.
4. **Figma groups** (file: `…/Specifications/TypographyGroups.swift`, size: M) — one protocol +
   concrete impl per group (`TypographyDisplayProtocol` {large,medium,small}, `…Heading`
   {large,medium,small,xSmall}, `…Body` {large,medium,mediumStrikethrough,small}, `…Label`
   {small,smallBold}, `…Link` {medium,small}); each property returns `ThemedTypographyStyle(style:
   Typography.<Group>.<style>)`.
5. **Provider** (file: `…/TypographyProvider.swift`, size: S) — extend `TypographyProviderProtocol`
   + `TypographyProvider` with the 5 group accessors (keep legacy props for now).
6. **Unit tests** (files: `AlfieKit/Tests/SharedUITests/Typography/TypographyStyleFontTests.swift` +
   `TypographyProviderTokenTests.swift`, size: S; XCTest, plain `import SharedUI`) — bridge
   (pointSize/weight; "SF Pro"→`systemFont`, negative-assert no `UIFont(name:)`; brand→registered &
   `UIFont(name:)` non-nil after `registerAll()`; `Text.build` lineSpacing = `lineHeight - pointSize`
   ≥ 0 for every token) + provider==token equality.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria met; new API usable, legacy intact.

### Depends on
none
