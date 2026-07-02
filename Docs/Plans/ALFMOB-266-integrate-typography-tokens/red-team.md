# Red-team: ALFMOB-266 typography token migration
**Date**: 2026-06-29   **Verdict**: NEEDS-FIXES → fixes folded into plan.md/phases/grill.md

## Findings & resolutions
- **C1 — Brand-font registration model wrong in plan.** `Alfie/Alfie/Alfie/AlfieApp.swift:24`
  already calls `FontManager.registerAll()` **unconditionally** at launch; `registerAll` loops
  `FontNames.allCases`. → Adding `case libreBaskerville` is sufficient for runtime registration; the
  preview-gated call in `TypographyProvider.init:26` is redundant. **Fix:** Phase 1 documents the
  AlfieApp launch hook + adds a runtime registration test (register → `UIFont(name:)` non-nil).
- **C2 — plan.md vs grill.md D1 contradiction.** grill.md said "keep legacy"; plan.md/phases assume
  rename-now. **Fix:** grill.md D1 reconciled to the user-confirmed rename-now decision.
- **H1 — Drop `LocalizedStringResource` callAsFunction overload.** L10n is `String`-typed
  (`L10n+Generated.swift`); no call site passes a Resource. Two trailing-default overloads = ambiguity
  trap. **Fix:** keep only `callAsFunction(String, underline:, strike:)`.
- **H2 — Enumerate strike/boldUnderline + chained `.withSize().font` sites.** `*Strike →
  body.x(strike:true)`; `boldUnderline → body.x(underline:true)`. Chained UIFont sites need `.uiFont`
  inserted: `ModalDemoView.swift:29,55`, `PriceComponentView.swift:158,209`, `ThemedToolbarTitle.swift:54`,
  `ThemedToolbarButton.swift:72`, `ProductDetailsColorAndSizeSheet.swift:47`, `FeatureToggleView.swift:16`.
- **H3 — No mocks exist (de-risk).** No external conformers to `TypographyProviderProtocol` or the
  legacy sub-protocols; only concrete `TypographyProvider`. Adding/removing protocol members is safe in
  one commit. **Fix:** removed "(if any) mocks" hedging.
- **M1 — lineHeight→lineSpacing convention.** Bridge must pass token `lineHeight` into existing
  `build(font:lineHeight:)` slot (→ `paragraphStyle.lineSpacing`); all tokens have lineHeight>fontSize so
  `Text.build` `lineSpacing - pointSize ≥ 0`. **Fix:** test pins ≥0 for every token.
- **M2 — "SF Pro" must map to `systemFont`, not `UIFont(name:"SF Pro")`.** **Fix:** bridge compares
  `fontFamily == Primitives.Typography.fontFamilyPrimaryIos` → `systemFont(ofSize:weight:)`; negative test.
- **M3 — dev-1 is the critical path** (Phase 1 + Phase 2 + Phase 5, all SharedUI). Kept one-owner-per-
  module for clean merges; **Fix:** moved the two unit-test files to dev-1/Phase 1 (they live in SharedUI's
  test target); plan notes wall-clock = P1 + max(P2,P3,P4) + P5.
- **M4 — Test path valid.** `Tests/SharedUITests/` is glob-sourced (Package.swift), XCTest, plain
  `import SharedUI` (all surface public). No change needed.
- **L1** latent `h3(Resource)→h2` bug (`TypographyHeaderProtocol.swift:64`) dropped by deletion.
- **L2** Dynamic Type unchanged (fixed point sizes, as today) — out of scope; noted.
- **L3** snapshots disabled → visual changes have no automated coverage (accepted per AC).
