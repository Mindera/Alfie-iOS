# Grill: Integrate typography tokens into SharedUI font system
**Plan**: Docs/Plans/ALFMOB-266-integrate-typography-tokens/plan.md   **Ticket**: ALFMOB-266   **Date**: 2026-06-29   **Branch**: ALFMOB-266-integrate-typography-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| D1 | Public API shape for this story | Keep legacy protocols, re-source from tokens | **CONFIRMED (post-grill follow-up): rename NOW.** Keep the middle-layer provider, but adopt Figma token names (`theme.font.display/heading/body/label/link`), delete the legacy `header/paragraph/small/tiny` system, and migrate all ~250 call sites; build must stay green. Absorbs most of ALFMOB-267. (User: "use the token directly and get rid of the existing typography system"; "keep the current architecture, middle layer, change the detail to design token"; chose "Figma names + migrate all sites" + "parallel team".) | Full re-plan (5 phases, additive-then-remove) |
| D2a | `header.h1` = 36pt, no 36pt token | Map to `Heading.large` (32) | **Follow token → `Heading.large` (36→32)** | Mapping table + Header phase + Risks |
| D2b | `small.*` = 14pt, no 14pt token | Keep 14 as exception | **Follow token → `Body.small` (14→12)** (overrode my conservative rec) | Mapping table + Small phase + Risks (small/tiny converge at 12) |
| D3 | Brand font Libre Baskerville (AC6) | Defer to 267 | **Bundle now** — confirmed SIL OFL 1.1, free for commercial use; download from official source, register via FontManager | AC6, Phase 1 step 2, Risks |
| D4 | "SF Pro" resolution | `systemFont(ofSize:weight:)` | systemFont (decided-by-default, low ambiguity — not asked) | Phase 1 |
| D5 | Weight `Int → UIFont.Weight` | 400→.regular, 500→.medium; bold = weight-bump | as recommended (decided-by-default — not asked) | Phase 1/2 |

## Answered by the codebase (not asked)
- Libre Baskerville not in repo; DesignTokens package ships only JSON, no font binary — `find Alfie -iname '*baskerville*'` empty; `ls SharedUI/DesignTokens/` = JSON only. (Settled that D3 needs an external asset.)
- Test target path: `Alfie/AlfieKit/Tests/SharedUITests/` exists — plan's test path is valid.
- `build(font:lineHeight:letterSpacing:…)` already supports lineHeight (as paragraph lineSpacing, converted in `Text.build`) + kerning; legacy protocol methods currently pass neither → token integration newly applies them. (`Font+Extensions.swift:8,43`, `:162`)
- Today all variants resolve to one `SF-Pro-Display-Medium.otf` → bold/italic currently identical to normal; honoring token weights is a real (intended) change. (`TypographyHeaderProtocol.swift:31`, etc.)

## Assumptions surfaced
- "Follow the tokens" applies to **values**, not (yet) the public type **names** — renaming is ALFMOB-267. Surfaced explicitly in D1; to be confirmed at approval.
- Applying token lineHeight/kerning/weight is a deliberate visual change across all themed text, not just a value swap. Snapshot baselines will shift (snapshots currently disabled — out of scope to refresh).
- `small` and `tiny` legacy tiers collapse to one token (`Body.small` 12pt); acceptable for this story.

## Still open (owner)
- **D1 RESOLVED** (rename now — see table). No longer open.
- **Libre Baskerville exact face/PostScript name (impl detail):** Display tokens use weight 400 → bundle Regular; executor verifies PostScript name at implementation.
- **Brand-font runtime registration (resolved by red-team):** handled by existing `AlfieApp.swift:24 FontManager.registerAll()` once `FontNames.libreBaskerville` is added — see red-team.md C1.
