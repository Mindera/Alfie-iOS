## Phase 1: TypographyStyle → UIFont bridge
### Goal
Provide a single, tested place that turns a generated `TypographyStyle` into a `UIFont` (and SwiftUI
`Font`), so specs can read token values instead of hardcoded `FontNames.sfProMedium.withSize(N)`.

### Acceptance criteria
- [ ] `TypographyStyle` → `UIFont` maps `fontWeight` 400→`.regular`, 500→`.medium` and uses
      `fontSize` from the token.
- [ ] SF Pro family (`fontFamilyPrimaryIos` = "SF Pro") resolves via `UIFont.systemFont(ofSize:weight:)`.
- [ ] A convenience `var font: Font` (SwiftUI) is available (mirrors existing `UIFont.font`).
- [ ] Unit tests cover the weight mapping and size passthrough.

### Steps
1. **Add bridge** (file: `Alfie/AlfieKit/Sources/SharedUI/Theme/Typography/Helpers/TypographyStyle+Font.swift`, **new**, size: S)
   — `extension TypographyStyle { var uiFont: UIFont { … } }`: map `fontWeight` Int →
   `UIFont.Weight` (400 `.regular`, 500 `.medium`, sensible default otherwise); for the SF Pro family
   return `UIFont.systemFont(ofSize: fontSize, weight: …)`. Keep a named-font fallback
   (`UIFont(name:size:)`) for any non-system family (guards future brand-font use) but do **not**
   hardcode a family string. Add `var font: Font { .init(uiFont) }`.
2. **Unit tests** (file: `Alfie/AlfieKit/Tests/SharedUITests/StyleGuideTests.swift`, size: S)
   — assert `Typography.Body.medium.uiFont.pointSize == 16`, weight mapping for a 400 and a 500 token,
   and that a known token yields the expected system font.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (new tests green).
- [ ] No spec behaviour changed yet (bridge is additive).

### Depends on
Phase 0
