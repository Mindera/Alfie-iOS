# Scout Report: ALFMOB-270 — Spacing & shape token integration

**Branch**: `ALFMOB-270-integrate-spacing-shape-tokens` (base = `ALFMOB-274-integrate-color-tokens`, stacked: 272 codegen → 274 colors → 270)
**Agents**: 2 Explore + direct reads + epic docs

## Epic context (reuse — don't reinvent)
- Epic **ALFMOB-264** plan dir: `Docs/Plans/260618-1552-ALFMOB-264-design-system-tokens/`.
  - **`phase-4-spacing-shape.md` is the blueprint for THIS ticket.** It prefers **option (a)**:
    keep `enum Spacing` / `enum CornerRadius`, set each `static let` = the generated value
    (smallest diff, preserves doc-comments + swiftlint pragma, **zero call-site churn**).
- `Docs/DesignTokens.md` — pipeline overview (pull → generate → commit). Generated Swift is
  AUTO-GENERATED + swiftlint-disabled; never hand-edit.
- ALFMOB-274 (`Docs/Plans/ALFMOB-274-integrate-color-tokens/`) is the **mirror**, but colors took the
  *opposite* mechanism (adopt token names at ~335 call sites, delete the facade) because token hex ≠
  asset hex. Spacing/radius differ — see "Key difference" below.

## Relevant Files
### Theme types to change (the whole ticket, essentially 2 files)
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Spacing/Spacing.swift:6` — `public enum Spacing`, 16 `static let spaceNNN: CGFloat` (0–80pt). Public API callers depend on (`Spacing.space200` → CGFloat).
- `Alfie/AlfieKit/Sources/SharedUI/Theme/CornerRadius/CornerRadius.swift:7` — `public enum CornerRadius`, 8 `static let` (`none/xxs/xs/s/m/l/xl/full` = 0/2/4/8/12/16/24/1000). **No `.value` accessor** — used bare as CGFloat. Carries `swiftlint:disable discouraged_none_name identifier_name`.

### Generated token symbols to forward TO (do NOT edit — generated)
- `GeneratedTokens/Primitives+Generated.swift:39` — `Primitives.Spacing.spacingN` concrete CGFloats. Values present: **0,2,4,8,12,14,16,18,20,24,28,32,40,48,56,64,80,96,124,220**.
- `GeneratedTokens/Sizing+Generated.swift:6` — `Sizing.radiusSoft`(=spacing4), `radiusStrong`(=spacing16), `radiusRounded`(=1000). Only 3 semantic radius tokens.

### Shape / shadow (likely NO change — YAGNI)
- `Theme/Shape/ShapeProviderProtocol.swift` — protocol only exposes `unavailableCrossedOutShape()`. No border-width / shadow surface.
- `Theme/Shape/DefaultShapeProvider.swift` — default impl; no token-derived borders/shadows to source. Tokens add no border/shadow surface → **no change** (epic phase-4 step 3).
- `Theme/Shadow/ShadowViewModifier.swift` — verify whether it hardcodes shadow values; tokens don't define shadows → out of scope unless trivially present.

### Generator (only touched if we choose to extend it — see Decision 1)
- `Tools/DesignTokenGen/Sources/DesignTokenGenCore/Emitter.swift:22-29` — emits exactly 4 files (Primitives/Theme/Sizing/Typography); output names are hardcoded keys, NOT data-driven. Spacing has no dedicated semantic output; radius lives in `Sizing`.
- Generator has its own unit tests run via `Alfie/scripts/generate-design-tokens.sh` (**NOT** verify.sh; outside AlfieKit graph).

### Demos (already exist — update only if names/values change)
- `DebugMenu/UI/Demo/Spacing/SpacingDemoView.swift` — iterates every `Spacing.spaceNNN`.
- `DebugMenu/UI/Demo/CornerRadius/CornerRadiusDemoView.swift` — iterates every `CornerRadius.*`.

### Tests
- **No** unit test asserts spacing/radius numeric values (`StyleGuideTests.swift` is an empty stub).
- Snapshot tests in `Alfie/AlfieTests/Snapshots/*` (7 files) are **NOT wired into the test target** (TODO + `isRecording=false`) and **zero reference PNGs are committed** → nothing runs, nothing to rebaseline. Same situation as ALFMOB-274.

## Exact value mapping
### Spacing → `Primitives.Spacing.*` (14 of 16 exact)
`space0→spacing0, space025→spacing2, space050→spacing4, space100→spacing8, space150→spacing12, space200→spacing16, space250→spacing20, space300→spacing24, space400→spacing32, space500→spacing40, space600→spacing48, space700→spacing56, space800→spacing64, space1000→spacing80` — all numerically identical.
### CornerRadius → generated (all 8 mappable)
`none→spacing0(0), xxs→spacing2, xs→spacing4(=radiusSoft), s→spacing8, m→spacing12, l→spacing16(=radiusStrong), xl→spacing24, full→Sizing.radiusRounded(1000)`.

## ⚠️ Gaps (no generated primitive) — mirrors 274's no-token-family split
- **`space075` = 6pt** — used in **production** (`HorizontalProductCard.swift` ×3, `SortByView.swift`); no `spacing6` primitive.
- **`space900` = 72pt** — used **only** in `SpacingDemoView` (DebugMenu); no `spacing72` primitive.
- Generated primitives also expose 14/18/28/96/124/220 which the hand-written scale doesn't use.

## Key difference vs ALFMOB-274 (colors)
Spacing/radius primitives are **numerically identical** to the current hardcoded values (16pt == 16pt),
so — for the 14+8 mapped constants — **no visual diff is expected**. This is a pure value-sourcing
refactor, NOT a re-shade. Snapshot rebaselining (the colors' main risk) does not apply here.

## Patterns Observed
- Theme types are bare `enum` namespaces of `public static let … : CGFloat`. Callers use `Spacing.space200` / `CornerRadius.s` directly as CGFloat. **Preserve this exact shape** (option a).
- Generated tokens preserve the reference graph (`Sizing.radiusSoft = Primitives.Spacing.spacing4`).

## Unresolved Questions (for ios-plan / ios-grill)
1. **Radius source style**: forward CornerRadius uniformly via `Primitives.Spacing.*` (+ `Sizing.radiusRounded` for `full`), OR use semantic `Sizing.radius*` for the 3 that exist (xs/l/full) and `Primitives.Spacing.*` for the other 5 (mixed)? (Recommend: prefer semantic `Sizing.radius*` where it exists, primitives otherwise — most meaning-preserving.)
2. **Spacing gaps (`space075`=6, `space900`=72)**: no primitive. Leave as documented hardcoded literals (honest deferral like 274's no-token families), or delete `space900` (demo-only) + push 6/72 upstream? (Recommend: keep both as documented literals; do not break production `space075`; log as follow-up. AC "no hardcoded numeric remains" is then *partially* met — same honest gap 274 logged.)
3. **PR base**: target `ALFMOB-274-integrate-color-tokens` (stacked) vs `main`. (Recommend: the 274 branch — main lacks the generated tokens.)
