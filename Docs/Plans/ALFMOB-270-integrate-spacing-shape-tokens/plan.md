---
title: Integrate spacing & shape tokens from design token JSON
ticket: ALFMOB-270
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-06-24
---

## Overview
Make the ALFMOB-272 generated design tokens the **single source of truth** for Alfie's spacing and
corner-radius. The hand-written `enum Spacing` and `enum CornerRadius` were thin layers over the
generated tokens, so — per the user's decision that the design-token JSON is authoritative and the app's
spacing/shape system is being replaced by it — **both are deleted** and call sites use the generated
tokens directly (`Primitives.Spacing.spacingN`, `Sizing.radius*`). This mirrors how colours are consumed
(ALFMOB-274 uses `Primitives.Colours.*` directly, no facade). On conflict, the JSON wins.

> Evolution: this started as "forward the enums to tokens (option a, zero churn)" per the epic
> blueprint, then — at the user's direction — moved to full token adoption (delete the facades). The
> per-phase files (`phase-1-spacing.md`, `phase-2-corner-radius.md`) and `grill.md` capture that history.

## Acceptance Criteria
- [x] Every spacing value comes from a generated token — call sites use `Primitives.Spacing.spacingN` directly; `enum Spacing` deleted; no numeric spacing literals in theme.
- [x] Every corner-radius value comes from a generated token — call sites use `Sizing.radiusSoft/Strong/Rounded` directly; `enum CornerRadius` deleted.
- [x] `space075` conformed 6→8pt (`spacing8`; no `spacing-6` token); `space900` (72pt) removed (no token). Both pixel/structure changes flagged for design.
- [x] Corner radii collapsed onto the 2 finite radius tokens (`<10→radiusSoft`, `≥10→radiusStrong`) + `radiusRounded` pill; `none` removed (no radius = no modifier).
- [x] Hand-written pin tests removed with their types (nothing hand-written left to pin; generator tests cover token values).
- [x] `./Alfie/scripts/verify.sh --skip-integration` → ✅ build + unit pass.

## Approach
**Adopt the generated tokens directly; delete the hand-written facades.** Same mechanism colours used.
Spacing is a 1:1-by-value inline (`Spacing.space200` → `Primitives.Spacing.spacing16`); corner radius
required a collapse (8 t-shirt names → the 3 radii the design system actually defines) because the JSON
has only `radiusSoft`/`radiusStrong`/`radiusRounded`. The generator is **not** extended — the needed
tokens already exist; we just consume them.

### Decisions (see `grill.md` for the trail)
1. **Design-token JSON is the source of truth** (user). The app's spacing/shape system is being replaced
   by it, so the hand-written `Spacing`/`CornerRadius` layers are removed rather than kept as aliases.
2. **Corner radius collapses to `radiusSoft`(4)/`radiusStrong`(16)/`radiusRounded`(1000)** — `<10→soft`,
   `≥10→strong`. Pixel shifts: `xxs 2→4`, `s 8→4`, `m 12→16`, `xl 24→16`. `none` removed. **`radiusRounded`
   pending team confirmation.**
3. **Spacing `space075` conformed 6→8** (no `spacing-6` token; now equals `space100`→`spacing8`);
   **`space900` (72pt) removed** (no `spacing-72` token). All other spacing values map 1:1 by value.
4. **PR base = `ALFMOB-274-integrate-color-tokens`** (stacked; `main` lacks the generated tokens).

## Value mapping
### Spacing → `Primitives.Spacing.*` (enum deleted, ~540 sites inlined across ~108 files)
`space0→spacing0 · space025→spacing2 · space050→spacing4 · space075→spacing8 (6→8) · space100→spacing8 ·
space150→spacing12 · space200→spacing16 · space250→spacing20 · space300→spacing24 · space400→spacing32 ·
space500→spacing40 · space600→spacing48 · space700→spacing56 · space800→spacing64 · space1000→spacing80`
· `space900` removed.
### CornerRadius → `Sizing.radius*` (enum deleted, ~34 sites across 23 files)
`xxs/xs/s → radiusSoft (4)` · `m/l/xl → radiusStrong (16)` · `full → radiusRounded (1000, pending)` ·
`none → removed`.

## File Changes (Summary)
| File | Module | Type | Change |
|---|---|---|---|
| `Theme/Spacing/Spacing.swift` | SharedUI | **delete** | Enum facade removed; consumers use `Primitives.Spacing.*` |
| `Theme/CornerRadius/CornerRadius.swift` | SharedUI | **delete** | Enum facade removed; consumers use `Sizing.radius*` |
| `Tests/SharedUITests/SpacingTokenTests.swift` | SharedUITests | **delete** | No hand-written spacing type left to pin |
| `Tests/SharedUITests/CornerRadiusTokenTests.swift` | SharedUITests | **delete** | No hand-written radius type left to pin |
| ~540 spacing + ~34 radius call sites (~110 files) | SharedUI + features | edit | Inline `Primitives.Spacing.spacingN` / `Sizing.radius*` |
| `Demo/Spacing/SpacingDemoView.swift`, `Demo/CornerRadius/CornerRadiusDemoView.swift` | DebugMenu | edit | Repointed to generated tokens |

**No change:** `Shape/*` (pure geometry), `Shadow/ShadowViewModifier.swift` (no shadow tokens upstream), the generator.

## Testing Strategy
- **Build/unit:** `./Alfie/scripts/verify.sh --skip-integration` → ✅ (build + unit; SharedUI change has no BFF surface).
- **Pin tests:** removed — there is no hand-written spacing/radius type to pin anymore; the generator's
  own suite (run via `generate-design-tokens.sh`) covers token values. Consistent with colours (no facade, no pin test).
- **Snapshot:** N/A — `Alfie/AlfieTests/Snapshots/*` not wired into the target, no reference PNGs. Visual deltas (radius collapse, `space075` 6→8) flagged for design.
- **Manual:** DebugMenu → StyleGuide → Spacing + CornerRadius demos; spot-check radius-heavy components.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Radius collapse (xxs/s/m/xl) + `space075` 6→8 shift pixels, no snapshot catches it | Med | Flagged in PR for **design sign-off**; manual check |
| `radiusRounded` not the right pill token | Med | **Pending team confirm**; ~9 sites if changed |
| ~540-site spacing inline conflicts with in-flight sibling P5 branches (ALFMOB-271/268/273) | Med | Mechanical; siblings rebase onto direct token usage |
| Lossy `space075`/`space100` collision (both `spacing8`) | Low | Accepted — a future upstream `spacing-6` re-separates at those call sites |
| Stacked base (274 not in main) | Low | PR targets the 274 branch |

## Out of Scope
- Adding `spacing-6` / `spacing-72` upstream (`Mindera/Alfie-Mobile-Design-Tokens`) — would let `space075`/`space900` values exist as tokens.
- Shadow/elevation tokens (none exist upstream) — `ShadowViewModifier` literals stay.
- Relabeling the Spacing demo's "Base Unit Multiplier" copy (debug-only, cosmetic).

## Open Questions
- **`radiusRounded`** — team to confirm the pill radius token. Design sign-off on the radius/`space075` pixel shifts at PR review.
