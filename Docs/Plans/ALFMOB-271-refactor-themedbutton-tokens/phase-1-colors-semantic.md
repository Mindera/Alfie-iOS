## Phase 1: Colors → semantic token layer

### Goal
`ButtonThemeSpec` sources its Default/Disabled colors from the semantic `Theme.button*` tokens
instead of raw `Primitives.Colours.neutrals*`, locked by a unit test. App/package builds & green.

### Acceptance criteria
- [ ] Primary/Secondary/Tertiary Default + Disabled bg/text/border read from `Theme.button*` tokens.
- [ ] Underline text Default/Disabled read from `Theme.linkLinkPrimary*`; its pressed text + bg/border
      stay `Primitives.Colours.*`.
- [ ] Pressed colors (all variants) remain `Primitives.Colours.*` with a one-line comment (no semantic token).
- [ ] `ButtonThemeTests` asserts each variant's spec fields equal the intended token constants.
- [ ] `./Alfie/scripts/verify.sh` green; Xcode previews render all 4 variants unchanged in structure.

### Token mapping (from Theme+Generated.swift — DO NOT edit generated file)
| Variant | field | new token |
|---|---|---|
| primary | backgroundColor | `Theme.buttonPrimaryBackgroundPrimaryDefault` |
| primary | backgroundDisabledColor | `Theme.buttonPrimaryBackgroundPrimaryDisabled` |
| primary | textColor | `Theme.buttonPrimaryContentPrimaryDefault` |
| primary | textDisabledColor | `Theme.buttonPrimaryContentPrimaryDisabled` |
| primary | borderColor | `Theme.buttonPrimaryStrokePrimaryDefault` |
| primary | borderDisabledColor | `Theme.buttonPrimaryStrokePrimaryDisabled` |
| secondary | backgroundColor / Disabled | `Theme.buttonSecondaryBackgroundSecondaryDefault` / `…Disabled` |
| secondary | textColor / Disabled | `Theme.buttonSecondaryContentSecondaryDefault` / `…Disabled` |
| secondary | borderColor / Disabled | `Theme.buttonSecondaryStrokeSecondaryDefault` / `…Disabled` |
| tertiary | background/text/border Default+Disabled | `Theme.buttonTerciary…` (note generated spelling "Terciary") |
| underline | textColor | `Theme.linkLinkPrimaryDefault` |
| underline | textDisabledColor | `Theme.linkLinkPrimaryDisabled` |
| underline | textPressed + background/border (all states) | keep `Primitives.Colours.*` (no link pressed/bg/border token) |
| *pressed (all other variants)* | background/text/border Pressed | keep `Primitives.Colours.*` (no semantic token) |

### Steps
1. **Re-point Primary/Secondary/Tertiary Default+Disabled colors** (file: `ButtonTheme.swift:31-68`, size: XS) —
   swap the raw `Primitives.Colours.*` for the mapped `Theme.button*` constants per the table.
   Leave the three `*PressedColor` fields on `Primitives.Colours.*`. Add a `// no semantic pressed token`
   comment. Why: adopt the semantic layer (AC1) while preserving pressed behavior.
2. **Underline text → semantic link tokens** (file: `ButtonTheme.swift:70-81`, size: XS) — set
   `textColor: Theme.linkLinkPrimaryDefault`, `textDisabledColor: Theme.linkLinkPrimaryDisabled`;
   keep `textPressedColor` + all bg/border on `Primitives.Colours.*`. Add comment
   `// underline: no semantic button group → link tokens for text; primitives for pressed/bg/border`.
3. **Add token-mapping unit test** (file: `Alfie/AlfieKit/Tests/SharedUITests/ButtonThemeTests.swift`, size: S) —
   new `XCTestCase` (or Swift Testing `@Test`, match SharedUITests convention). For each variant assert
   `ButtonTheme.<case>.spec.<field> == <expected Theme.*/Primitives.* constant>`. `ButtonThemeSpec` is
   `internal` and tests are in the same package → `@testable import SharedUI` gives access. Colors are
   `Color`; compare against the same token constants (not literals) so intent, not pixels, is asserted.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria above all met.
- [ ] Manual: run the 4 `#Preview`s in ThemedButton.swift — layout/structure unchanged.

### Depends on
none
