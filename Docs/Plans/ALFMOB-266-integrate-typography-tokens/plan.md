---
title: Token-driven typography provider (Figma names) + full call-site migration
ticket: ALFMOB-266
status: completed
complexity: HIGH
mode: hard
blockedBy: []
blocks: []
relates: [ALFMOB-267]
created: 2026-06-29
---

## Overview
Replace the hardcoded legacy typography system with a token-driven one. Keep the middle-layer
`ThemeProvider.font` provider (DI, mockable) — UI never touches the generated `Typography.*` enum
directly — but rebuild its surface around the **Figma token names** (`theme.font.display/heading/
body/label/link.*`), source every value from the generated tokens, bundle the brand font, delete
the legacy `header/paragraph/small/tiny` system, and migrate all ~80 files / ~250 call sites.
This intentionally absorbs most of ALFMOB-267. Per the user, **visual breakage is acceptable but
the package MUST compile** (`verify.sh` green) at every phase boundary.

## Acceptance Criteria
- [ ] AC1 — Typography font family/size/weight/line-height/letter-spacing are sourced from the
  generated tokens (no hardcoded `withSize(36/24/20/16/14/12)` left).
- [ ] AC2 — The provider exposes the Figma token groups verbatim (`display/heading/body/label/
  link`); the legacy `header/paragraph/small/tiny` types are deleted.
- [ ] AC3 — `ThemeProvider.shared.font` remains the single typography entry point (DI/mockable);
  UI code uses only `theme.font.*`, never `Typography.*` directly.
- [ ] AC4 — `AttributedString`/`Text.build` output still applies font/size/weight/lineHeight/
  kerning + underline/strike where requested.
- [ ] AC5 — `UIFont` integration points (UIKit appearance, `.font(Font(...))`, `.withSize`) use
  token-derived fonts via `<group>.<style>.uiFont`.
- [ ] AC6 — Libre Baskerville (brand, SIL OFL 1.1) bundled + registered via `FontManager`;
  `Display.*` resolves to it.
- [ ] AC7 — All ~250 call sites migrated; **`./Alfie/scripts/verify.sh` passes**; new unit tests
  assert provider values == token values.
- [ ] (ALFMOB-267 overlap) — Typography/Label and the other touched components compile & render
  via the new token API. Pixel-parity & snapshot refresh are explicitly NOT required this story.

## Approach
**Additive-then-remove**, so the build stays green throughout and the parallel migration branches
fork off a compiling base:
1. **Foundation (additive):** add the `TypographyStyle → UIFont` / `AttributedString.build(style:)`
   bridge, bundle+register the brand font, and add the new Figma-named groups to the provider
   **alongside** the legacy ones (both compile). `Typography.*` is wrapped, never exposed to UI.
2. **Migrate per module (parallel):** rewrite call sites from `theme.font.header/paragraph/small/
   tiny.*` to `theme.font.<group>.<style>` using the mapping below. Legacy API still present →
   each module compiles independently.
3. **Remove legacy (last):** once no call site references them, delete the legacy protocols/classes
   and the legacy group properties; point `setupAppearance()` at `heading.small.uiFont`.

**Provider design** (cuts the variant-matrix boilerplate): each token style is a small value type
with `callAsFunction`:
```swift
public struct ThemedTypographyStyle {
    public let style: TypographyStyle
    public var uiFont: UIFont { style.uiFont }            // bridge
    public func callAsFunction(_ s: String, underline: Bool = false, strike: Bool = false) -> AttributedString
}
```
> Only the `String` overload — L10n is `String`-typed (`L10n.tr → String`); no call site passes a
> `LocalizedStringResource`, and a second trailing-default overload is an ambiguity trap (red-team H1).
Provider groups expose `var large: ThemedTypographyStyle { .init(style: Typography.Heading.large) }`,
so `theme.font.heading.large("x")`, `theme.font.heading.large.uiFont`, and
`theme.font.body.medium("x", underline: true)` all read naturally. One protocol per group preserves
mockability under the existing `TypographyProviderProtocol`.

**Legacy → Figma migration mapping** (tokens are source of truth; legacy bold/italic already
rendered as the single SF-Pro-Display-Medium face, so dropping the bold/italic distinction is no
real regression; underline/strike preserved as params):
| Legacy | New |
|---|---|
| `header.h1` | `heading.large` |
| `header.h2` | `heading.medium` |
| `header.h3` | `heading.small` |
| `header.h3Underline(x)` | `heading.small(x, underline: true)` |
| `paragraph.normal/italic/bold/boldItalic` | `body.medium` |
| `paragraph.normalUnderline/boldUnderline` | `body.medium(x, underline: true)` |
| `paragraph.normalStrike/boldStrike` | `body.medium(x, strike: true)` |
| `small.normal/italic/bold/boldItalic` | `body.small` |
| `small.normalUnderline/boldUnderline` | `body.small(x, underline: true)` |
| `small.normalStrike/boldStrike` | `body.small(x, strike: true)` |
| `tiny.*` (+ `boldUnderline`) | `body.small` (`body.small(x, underline: true)`) |
| any `…X` used as `UIFont` / `.withSize(n)` / `.font(Font(…X))` | `<group>.<style>.uiFont` (`.uiFont.withSize(n)`) |
| `ThemeProvider.setupAppearance` `font.header.h3` | `font.heading.small.uiFont` |

Note: `Body.mediumStrikethrough` token exists but is redundant given the `strike:` param — use the
param. `*Strike`/`*Underline` keep their effect; legacy "bold" emphasis is intentionally dropped
(it already rendered as the single Medium face — no real regression).

⚠ **Migration is not blind find/replace:** a site using the symbol as a `UIFont` needs `.uiFont`
appended; a site calling it `(…)` just renames. **Known chained `.withSize(...)/.font` UIFont sites
that must get `.uiFont` inserted** (red-team H2): `ModalDemoView.swift:29,55`,
`PriceComponentView.swift:158,209`, `ThemedToolbarTitle.swift:54`, `ThemedToolbarButton.swift:72`,
`ProductDetailsColorAndSizeSheet.swift:47`, `FeatureToggleView.swift:16`, plus
`NSAttributedString.fromHtml(font:)` / `hightlightedAttributedString(font:)` callers. The compiler
catches misses (type mismatch), so the build gate enforces this.

## Phases
- **Phase 1 — Foundation: bridge + brand font + Figma provider (additive)** — `phase-1-foundation.md` · dev-1 · blocks 2-4
- **Phase 2 — Migrate SharedUI (Components + Theme)** — `phase-2-migrate-sharedui.md` · dev-1
- **Phase 3 — Migrate DebugMenu + demos** — `phase-3-migrate-debugmenu.md` · dev-2
- **Phase 4 — Migrate feature modules + tests** — `phase-4-migrate-features-tests.md` · dev-3
- **Phase 5 — Remove legacy typography system** — `phase-5-remove-legacy.md` · dev-1 · after 2-4

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|------|--------|------|--------|-------|
| `SharedUI/Theme/Typography/Helpers/TypographyStyle+Font.swift` | SharedUI | new | bridge: `TypographyStyle.uiFont`, `UIFont.Weight(tokenWeight:)`, `AttributedString.build(style:)` | dev-1 |
| `SharedUI/Theme/Typography/ThemedTypographyStyle.swift` | SharedUI | new | `ThemedTypographyStyle` value type (callAsFunction) | dev-1 |
| `SharedUI/Theme/Typography/TypographyProvider.swift` | SharedUI | edit | add `display/heading/body/label/link` groups (keep legacy until Phase 5) | dev-1 |
| `SharedUI/Theme/Typography/Specifications/TypographyGroups.swift` | SharedUI | new | per-group protocols + concrete impls returning `ThemedTypographyStyle` | dev-1 |
| `SharedUI/Theme/Typography/Helpers/FontNames.swift` | SharedUI | edit | add `libreBaskerville` case + file mapping | dev-1 |
| `SharedUI/Theme/Typography/Resources/` (+`Fonts.xcassets`, `OFL.txt`) | SharedUI | new asset | bundle Libre Baskerville Regular | dev-1 |
| `SharedUI/Components/**`, `SharedUI/Theme/**` (31 files) | SharedUI | edit | migrate call sites (per mapping) | dev-1 |
| `DebugMenu/**` (36 files, incl. `TypographyDemoView`) | DebugMenu | edit | migrate call sites | dev-2 |
| `ProductListing/ProductDetails/Search/Home/CategorySelector/MyAccount/Web/AppFeature` (13 files) | features | edit | migrate call sites | dev-3 |
| `AlfieKit/Tests/SharedUITests/Typography/*` | Tests | new | bridge + provider==token + brand-font-registration unit tests (XCTest, plain `import SharedUI`) | dev-1 (Phase 1) |
| `SharedUI/Theme/Typography/Specifications/TypographyHeaderProtocol.swift` (+Paragraph/Small/Tiny) | SharedUI | delete | remove legacy system (Phase 5) | dev-1 |
| `SharedUI/Theme/ThemeProvider.swift` | SharedUI | edit | `setupAppearance` → `heading.small.uiFont` (Phase 5) | dev-1 |

(One owner per file → clean merges. dev-1 owns SharedUI incl. foundation + unit tests + cleanup;
dev-2 DebugMenu; dev-3 feature modules. Phases 2-4 run in parallel off the Phase-1 base; Phase 5
after they merge. **dev-1 is the critical path** (Phase 1 → Phase 2 → Phase 5); dev-2/dev-3 have
slack. Wall-clock ≈ P1 + max(P2,P3,P4) + P5. Tests live in SharedUI's test target so dev-1 owns
them to avoid a same-target ownership overlap — red-team M3/M4.)

## Feature Flag
n/a — internal design-system refactor; risk managed by the additive-then-remove sequence + the
build-green checkpoint, not a runtime flag.

## Testing Strategy
- **Unit (XCTest, new, dev-1 / Phase 1):** `TypographyStyleFontTests` — uiFont.pointSize==fontSize;
  weight map; "SF Pro"→`systemFont` (negative: NOT `UIFont(name:)`); brand→registered after
  `FontManager.registerAll()` (`UIFont(name:<PostScript>)` non-nil); `build(style:)` sets kern +
  paragraph lineSpacing, with `Text.build` lineSpacing (`lineHeight - pointSize`) ≥ 0 for every token.
  `TypographyProviderTokenTests` — each `theme.font.<group>.<style>.uiFont`/AttributedString == mapped
  token. Pins AC1/AC4/AC5/AC6.
- **Snapshot:** `AlfieTests/Snapshots/*` target membership is currently disabled (TODOs); refreshing
  baselines is **out of scope** (visual breakage accepted). Note the broad visual delta for QA.
- **Manual:** DebugMenu `TypographyDemoView` renders all five groups.
- **Gate (every phase):** `./Alfie/scripts/verify.sh` (use `--skip-integration` while iterating;
  full run before PR).

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Huge blast radius (~80 files) → merge conflicts | High | One owner per module/file; additive base so branches compile independently; ff-only integrate |
| Build goes red mid-migration | High | Additive-then-remove: legacy API stays until Phase 5; each phase checkpoint = verify.sh green |
| UIFont-vs-builder sites mis-migrated (missing `.uiFont`) | High | Enumerated chained sites in mapping; compiler catches type mismatches; per-phase diff review + code-review gate |
| Lost bold/italic emphasis (tokens define weight) | Med | Accepted (legacy bold already==medium face); flag to QA; underline/strike preserved |
| Brand font not registered at runtime → `UIFont(name:)` fails (runtime, not caught by build) | Med | `AlfieApp.swift:24` already calls `FontManager.registerAll()` at launch → adding `FontNames.libreBaskerville` suffices (red-team C1). Verify PostScript name (Font Book/`fc-scan`); unit test registers then asserts `UIFont(name:)` non-nil |
| "SF Pro" mis-resolved via `UIFont(name:"SF Pro")` → blank font | Med | Bridge maps `fontFamilyPrimaryIos` → `systemFont(ofSize:weight:)`; negative test asserts no `UIFont(name:)` path (red-team M2) |
| Line-height now applied → spacing/RTL regressions | Med | Bridge reuses existing `lineHeight`→`paragraphStyle.lineSpacing` convention; all tokens have lineHeight>fontSize so `Text.build` lineSpacing ≥ 0 (test-pinned); RTL already handled; visual breakage accepted |
| Adding/removing protocol members breaks mocks | Low | **No external conformers exist** (only concrete `TypographyProvider`) — confirmed safe in one commit (red-team H3) |
| Scope creep into full 267 polish | Med | Out-of-scope list; pixel parity & snapshot refresh excluded |

## Out of Scope
- Pixel parity / snapshot baseline refresh / re-enabling snapshot target membership.
- Editing `GeneratedTokens/` or regenerating tokens (ALFMOB-272, done).
- Any non-typography component redesign beyond what migration requires to compile.
- Italic/bold *faces* beyond what tokens specify.
- Dynamic Type / `UIFontMetrics` scaling — unchanged (fixed point sizes, exactly as the legacy
  `withSize` path today).

## Decisions (resolved — see grill.md)
- **D1:** Adopt Figma names on the provider + migrate all call sites; delete legacy system; keep
  the middle-layer provider (no direct `Typography.*` in UI); build must stay green. (User confirmed.)
- **D2:** Follow tokens, no exceptions — `h1→heading.large` (36→32), `small→body.small` (14→12).
- **D3:** Bundle Libre Baskerville Regular (OFL 1.1, free) + register via FontManager.
- **D4:** "SF Pro" → `UIFont.systemFont(ofSize:weight:)` (no SF Pro asset bundled).
- **D5:** weight `Int→UIFont.Weight` (400→.regular, 500→.medium).
