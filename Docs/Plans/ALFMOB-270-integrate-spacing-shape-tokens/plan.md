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
Make the ALFMOB-272 generated design tokens the source of truth for Alfie's spacing and corner-radius
values. Per the epic blueprint (`260618-1552-ALFMOB-264-design-system-tokens/phase-4-spacing-shape.md`)
use **option (a)**: keep the hand-written `enum Spacing` / `enum CornerRadius`, but set each
`public static let` = the corresponding generated symbol. **Design-token JSON is the source of truth;
on conflict, the JSON wins** (user decision). Near-zero call-site churn (108 files / ~494 spacing + ~54
radius sites keep `Spacing.space200` / `CornerRadius.s` verbatim). One deliberate production change:
`space075` 6→8pt (no `spacing-6` token), confirmed at the gate, design signs off on the PR.

## Acceptance Criteria
- [ ] Every spacing value sourced from a generated token (`Primitives.Spacing.*`) — **no numeric literals remain**.
- [ ] Every corner-radius value sourced from a generated radius token — call sites use `Sizing.radiusSoft/Strong/Rounded` directly; the `CornerRadius` alias type is removed.
- [ ] `Spacing.*` access patterns unchanged (same names except the deleted `space900`, same `CGFloat` type). Corner-radius consumers migrated to `Sizing.radius*`; sibling P5 stories (ALFMOB-271/268/273…) adopt the same when they land.
- [ ] `space075` conformed to the nearest token: `Primitives.Spacing.spacing8` (6→8pt) — a deliberate +2pt shift in `HorizontalProductCard`/`SortByView`, design sign-off on PR.
- [ ] `space900` (72pt, no token, demo-only) deleted, incl. its `SpacingDemoView` row.
- [ ] New value-pinning unit tests assert each public constant resolves to its expected CGFloat and equals its generated source.
- [ ] `./Alfie/scripts/verify.sh` → ✅ FULL VERIFICATION PASSED.

## Approach
**Forward the existing enums to generated symbols (option a).** Smallest diff, preserves the public
API + doc-comments + `swiftlint:disable` pragma, keeps sibling P5 component refactors compiling. The
literal numbers move out of the theme files into the generated files (the design source of truth), so
"no hardcoded numeric" is met for every constant.

**Deliberate divergence from epic phase-4 step 1** (which suggested emitting new
`Spacing+Generated.swift` / `Radius+Generated.swift`): we do **NOT** extend the generator. The needed
spacing scale already exists as `Primitives.Spacing.spacingN`; radius as `Sizing.radius*`. Adding
dedicated emit files would mean changing `Tools/DesignTokenGen/Emitter.swift` + inventing token inputs
that don't exist, for zero functional gain (YAGNI/DRY). Reusing the existing primitives satisfies every
AC with no generator risk; the generator's separate test suite stays untouched.

### Decisions (grilled — see `grill.md`)
1. **Radius source = radius tokens only** (post-review user decision, supersedes the original
   semantic-where-available mapping): corner radii must come from the design system's radius tokens,
   not spacing primitives. The JSON defines only `radiusSoft`=4 and `radiusStrong`=16 for finite radii,
   so each case maps by size — **<10pt → `Sizing.radiusSoft`, ≥10pt → `Sizing.radiusStrong`**:
   `xxs/xs/s → radiusSoft`, `m/l/xl → radiusStrong`. `full → Sizing.radiusRounded` (**pending design/team
   confirmation**). `none → 0` (absence of a radius; no token). **This shifts pixels:** `xxs 2→4`, `s 8→4`,
   `m 12→16`, `xl 24→16` (affects Snackbar, ThemedButton, ProgressBar, …) — design signs off on PR.
2. **Off-token spacing conformed in-ticket** (JSON has no `spacing-6`/`spacing-72`): `space075`→`spacing8`
   (6→8pt, nearest-up, safer tap targets; **design sign-off on PR**); `space900` **deleted** (demo-only)
   incl. its demo row. No off-token literals remain.
3. **PR base = `ALFMOB-274-integrate-color-tokens`** (stacked; `main` lacks the generated tokens). Confirmed by user.

## Value mapping
### Spacing → `Primitives.Spacing.*`
`space0→spacing0 · space025→spacing2 · space050→spacing4 · space075→spacing8 (6→8, conformed) ·
space100→spacing8 · space150→spacing12 · space200→spacing16 · space250→spacing20 · space300→spacing24 ·
space400→spacing32 · space500→spacing40 · space600→spacing48 · space700→spacing56 · space800→spacing64 ·
space1000→spacing80` · **`space900` (72) → DELETED**
### CornerRadius → DELETED; use `Sizing.radius*` directly
The hand-written `CornerRadius` type was a pure alias over the generated radius tokens, so it was
**deleted entirely** and call sites now use `Sizing.radiusSoft` / `radiusStrong` / `radiusRounded`
directly — consistent with how colours are consumed (ALFMOB-274 uses `Primitives.Colours.*` directly,
no facade). Final call-site mapping (~34 sites, value-preserving): `xxs/xs/s → Sizing.radiusSoft`,
`m/l/xl → Sizing.radiusStrong`, `full → Sizing.radiusRounded`, `none → removed` (no radius = no
modifier). `CornerRadiusTokenTests` was removed with the type (nothing hand-written left to pin; the
generator's own tests cover token values). `radiusRounded` is **pending team confirmation** (~9 sites).

## Phases
One file per vertical slice; each leaves the app building & green.
1. **Spacing** — forward `Spacing.swift` (incl. `space075`→spacing8, delete `space900`), update `SpacingDemoView`, pin tests. `phase-1-spacing.md`
2. **CornerRadius** — forward `CornerRadius.swift` to `Sizing.radius*`/`Primitives.Spacing.*`, pin tests. `phase-2-corner-radius.md`

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Theme/Spacing/Spacing.swift` | SharedUI | edit | Each `space*` = `Primitives.Spacing.*`; `space075`→spacing8; remove `space900` | - |
| `DebugMenu/UI/Demo/Spacing/SpacingDemoView.swift` | DebugMenu | edit | Delete the `space900` demo row | - |
| `Theme/CornerRadius/CornerRadius.swift` | SharedUI | **delete** | Pure alias over radius tokens — removed; consumers use `Sizing.radius*` directly | - |
| `Tests/SharedUITests/CornerRadiusTokenTests.swift` | SharedUITests | **delete** | No hand-written radius type left to pin (generator tests cover token values) | - |
| ~34 `CornerRadius.*` call sites across 23 files | SharedUI + features | edit | `xxs/xs/s→Sizing.radiusSoft`, `m/l/xl→Sizing.radiusStrong`, `full→Sizing.radiusRounded` (value-preserving) | - |
| `DebugMenu/UI/Demo/CornerRadius/CornerRadiusDemoView.swift` | DebugMenu | edit | Demo the 3 radii via `Sizing.radius*` + a soft/strong nested example | - |
| `Tests/SharedUITests/SpacingTokenTests.swift` | SharedUITests | add | Pin every `Spacing.space*` to expected CGFloat (`space075==8`) + equal generated source; assert `space900` gone | - |
| `Tests/SharedUITests/CornerRadiusTokenTests.swift` | SharedUITests | add | Pin every `CornerRadius.*` to expected CGFloat + equal generated source | - |

**No change:** `Shape/DefaultShapeProvider.swift`, `Shape/ShapeProviderProtocol.swift` (pure geometry),
`Shadow/ShadowViewModifier.swift` (no shadow/elevation tokens upstream), all 108 spacing/radius call-site
files (names/values stable), `CornerRadiusDemoView` (unchanged), the generator.

## Feature Flag
n/a — static theme-value refactor.

## Testing Strategy
- **Build/unit:** `./Alfie/scripts/verify.sh` per phase. SwiftLint runs as a build phase (opt-in all) — hand-edited theme files must lint clean; preserve `CornerRadius.swift`'s pragma.
- **New unit tests:** value-pin every public `Spacing.*` / `CornerRadius.*` constant to its expected
  CGFloat AND assert it equals its generated source — catches a wrong-token wiring (`space200 = spacing18`)
  and pins the contract callers rely on. (`StyleGuideTests.swift` is an empty stub; no value tests exist.)
- **Snapshot:** N/A — `Alfie/AlfieTests/Snapshots/*` are not wired into the target and zero reference PNGs
  are committed; nothing runs / nothing to rebaseline. The only visual delta (`space075` 6→8) is therefore
  **not auto-covered** → flagged for design sign-off + manual check.
- **Generator:** untouched → `generate-design-tokens.sh` not needed.
- **Manual:** DebugMenu → StyleGuide → Spacing demo (space075 row now 8pt; space900 gone) + CornerRadius demo (unchanged). Spot-check HorizontalProductCard / SortBy spacing.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| `space075` 6→8 visibly shifts HorizontalProductCard/SortBy and no snapshot catches it | Med | Explicit AC + `// 6→8` comment; manual check; **design sign-off on PR** before merge |
| Wrong-token wiring silently shifts a value | Low | Value-pin unit tests assert exact CGFloat per constant |
| Deleting `space900` breaks a non-demo usage | Low | Scout found only `SpacingDemoView`; executor re-greps before deleting |
| Reviewer wants the 5 non-token radii collapsed to the 3 sanctioned tokens | Low | Out of scope (design-led redesign, ~54 call sites); noted below |
| Stacked base (274 not in main) complicates PR | Low | PR targets the 274 branch; noted in PR body |

## Out of Scope
- Adding `spacing-6` / `spacing-72` (and dedicated `Spacing+/Radius+Generated.swift`) to the upstream
  `Mindera/Alfie-Mobile-Design-Tokens` repo — design/upstream deliverable. (`space075` is conformed to
  `spacing8` here instead of waiting for an upstream `spacing-6`.)
- Collapsing `CornerRadius` to only the 3 JSON-sanctioned radii (soft/strong/rounded) — a design-led
  redesign across ~54 call sites; out of scope. We source the other five from their spacing primitives.
- Shadow/elevation tokens (none exist upstream) — `ShadowViewModifier` literals stay.
- Migrating call sites to new names — option (a) keeps existing names.

## Open Questions
- None outstanding. Design sign-off on the `space075` 6→8 shift happens at PR review (tracked as a Risk).
