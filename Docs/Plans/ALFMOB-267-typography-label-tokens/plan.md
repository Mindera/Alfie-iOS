---
title: Refactor Typography/Label components to use design tokens
ticket: ALFMOB-267
status: completed
complexity: MEDIUM
mode: auto
blockedBy: []
blocks: []
created: 2026-07-07
---

## Overview
Route the four typography spec classes (`TypographyHeader/Paragraph/Small/Tiny`) through the
generated `Typography.*` design tokens instead of hardcoded `FontNames.sfProMedium.withSize(N)`
literals, keeping the `header/paragraph/small/tiny` provider API stable so the ~78 call sites are
untouched. First unblock the build: the base branch shipped a broken generated token file caused by
a defect in the source token JSON.

## Acceptance Criteria (from ticket)
- [ ] All text rendering (header/paragraph/small/tiny) uses token-generated typography values.
- [ ] No hardcoded font sizes, weights, or family names in the typography utilities.
- [ ] AttributedString builders still produce correctly styled text (String + LocalizedStringResource).
- [ ] UIFont mappings reflect token values.
- [ ] All typography levels render correctly (h1/h2/h3, paragraph, small, tiny variants).

## Approach
The generated `TypographyStyle` exposes `fontFamily:String`, `fontWeight:Int`, `fontSize`,
`lineHeight`, `letterSpacing`. Add a **non-generated** `TypographyStyle → UIFont` bridge in SharedUI
(family+weight+size → `UIFont`), then re-point each spec's `UIFont` vars at the mapped token. The SF
Pro family maps to `UIFont.systemFont(ofSize:weight:)` (SF Pro *is* the system typeface), which
removes the `"SF Pro Display Medium"` string hardcode. `Display.*` tokens use the brand family
`"Libre Baskerville"` which is **not bundled** and is **not used** by these four specs → out of scope.

The token set does **not** cover the current scale 1:1 (no 36, no 14) — see Open Questions; the
scale→token mapping is the central decision and is resolved at the grill/approval gate.

## Phases (vertical slices, dependency order)
- **Phase 0 — Unblock build** (`phase-0-unblock-tokens.md`): fix the source-JSON defect + regenerate.
- **Phase 1 — TypographyStyle→UIFont bridge** (`phase-1-font-bridge.md`): the family+weight→UIFont
  resolver + SwiftUI `Font`, with unit tests. No behaviour change to specs yet.
- **Phase 2 — Migrate specs to tokens** (`phase-2-migrate-specs.md`): re-point Header/Paragraph/Small/
  Tiny at tokens via the bridge per the agreed mapping; remove hardcoded sizes/family; fix the
  pre-existing `h3(_ res:)`→`h2` bug; refresh snapshot baselines; update `TypographyDemoView` if needed.

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `SharedUI/DesignTokens/typography.styles.tokens.json` | SharedUI | edit | line 27 `-font-family` → `-font-weight` | - |
| `SharedUI/GeneratedTokens/Typography+Generated.swift` | SharedUI | regen | via `generate-design-tokens.sh` (do not hand-edit) | - |
| `SharedUI/Theme/Typography/Helpers/TypographyStyle+Font.swift` | SharedUI | **new** | `TypographyStyle`→`UIFont`/`Font` bridge | - |
| `SharedUI/Theme/Typography/Specifications/TypographyHeaderProtocol.swift` | SharedUI | edit | vars→tokens; fix `h3(_ res:)` bug | - |
| `SharedUI/Theme/Typography/Specifications/TypographyParagraphProtocol.swift` | SharedUI | edit | vars→tokens | - |
| `SharedUI/Theme/Typography/Specifications/TypographySmallProtocol.swift` | SharedUI | edit | vars→tokens | - |
| `SharedUI/Theme/Typography/Specifications/TypographyTinyProtocol.swift` | SharedUI | edit | vars→tokens | - |
| `SharedUI/Theme/Typography/Helpers/FontNames.swift` | SharedUI | edit | drop `sfProMedium` size hardcode if unused post-migration | - |
| `AlfieKit/Tests/SharedUITests/StyleGuideTests.swift` | SharedUITests | edit | add token-value assertions (file is empty today) | - |
| `AlfieTests/Snapshots/*ViewSnapshotTests.swift` | AlfieTests | regen | refresh baselines if rendering changes | - |

## Feature Flag
n/a — pure internal refactor of the shared typography layer. No user-facing toggle; not a
`high_rigor_domain`.

## Testing Strategy
- **Unit** (`StyleGuideTests`, currently empty): assert each spec's `UIFont.pointSize`/weight equals
  the mapped token's `fontSize`/`fontWeight`; assert the `TypographyStyle→UIFont` bridge maps
  400→`.regular`, 500→`.medium`, and SF Pro → system font.
- **Snapshot**: existing page-level snapshots (`ProductDetails/Brands/Categories/Search/Shop`) act as
  the visual regression guard; re-record baselines once the mapping is signed off.
- **Manual**: `TypographyDemoView` in the Debug menu renders every level for eyeball verification.
- Gate: `./Alfie/scripts/verify.sh` green after each phase.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Token JSON is a Figma export (`pull-design-tokens.sh`); the line-27 fix is clobbered on next pull | Med | Fix locally to unblock now **and** raise the defect against the Figma token source (out-of-repo follow-up) |
| Mapping changes rendered text (h1 36→32, paragraph weight 500→400, small 14→?) | High | Explicit mapping table signed off at grill/approval; refresh snapshots; keep provider API stable |
| `small`=14 and `h1`=36 have no matching token | High | Open Question — resolve at grill (map to nearest / add token upstream / keep size override) |
| Applying token `lineHeight`/`letterSpacing` via `.build()` double-counts (existing `Text.build` subtracts pointSize) | Med | Default: keep builders font-only this ticket; treat line-height/kerning application as a separate decision (Open Q) |
| Removing bundled `SF Pro Display Medium` font/registration breaks other consumers | Low | Only drop `FontNames.sfProMedium` if grep confirms zero remaining uses post-migration; else leave registration intact |

## Out of Scope
- `Display.*` (brand "Libre Baskerville") tokens — font not bundled, not used by these specs.
- Renaming the provider API to token role names (Body/Heading/Label/Link) — would touch ~78 call sites.
- Hardcoded `.withSize(N)` in consumers (`ThemedToolbarTitle/Button` 18, `PriceComponentView` 12/14/16,
  `SortByView` 18) — call-site overrides, not typography utilities; separate cleanup.
- `NSAttributedString.fromHtml` line-height heuristic (`fontSize + 8`) — HTML rendering, separate concern.

## Decisions (from grill — see grill.md)
1. **Faithful adoption** — specs read token values; visual changes are accepted (tokens are the new
   source of truth). Snapshots refreshed; PR flags the changes for design sign-off.
2. **Font only this ticket** — route family/weight/size through tokens; **defer** token
   line-height & letter-spacing to a follow-up (avoids the `Text.build()` double-subtraction risk).
3. **Edit JSON now + raise upstream** — correct the exported source JSON to unblock, and file the
   same fix against the Figma token source.
4. **Variants keep current behavior** — all variants of a scale (normal/italic/bold/boldItalic/
   underline/strike) read the **same** base token; no synthesized bold/italic (none exist in tokens).
   Matches today's rendering (variants are already visually identical).

### Final scale→token mapping (SF Pro family only; font metrics only)
| Current spec (size/weight) | Token | Token size/weight | Net change |
|---|---|---|---|
| `header.h1` (36/500) | `Typography.Heading.large` | 32 / 500 | size 36→32 |
| `header.h2` (24/500) | `Typography.Heading.medium` | 24 / 500 | none (kerning deferred) |
| `header.h3` (20/500) | `Typography.Heading.small` | 20 / 500 | none (kerning deferred) |
| `paragraph.*` (16/500) | `Typography.Body.medium` | 16 / 400 | weight 500→400 |
| `small.*` (14/500) | `Typography.Body.small` | 12 / 400 | size 14→12, weight 500→400 |
| `tiny.*` (12/500) | `Typography.Body.small` | 12 / 400 | weight 500→400 |

Note: `small` & `tiny` converge at 12/400 — an accepted consequence flagged for design.
