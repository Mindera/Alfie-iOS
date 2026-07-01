# Grill: Integrate color tokens from design token JSON
**Plan**: Docs/Plans/ALFMOB-274-integrate-color-tokens/plan.md   **Ticket**: ALFMOB-274   **Date**: 2026-06-23   **Branch**: ALFMOB-274-integrate-color-tokens

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | Mapping strategy for old→token | Index-aligned, proceed now | **Design-token names are the source of truth** — adopt the generated names, don't preserve old names / clever hex-match | Approach rewritten: migrate to `Primitives.Colours.*` names, not a mono/green facade |
| 2 | API reshape / what to migrate | Keep facade + map all | **Map what has a token equivalent NOW; list what doesn't for one-by-one review later** | Scope split into "wire now" (mono/green/red/white/black) + "review list" (blue/yellow/orange). xcassets retirement becomes partial |
| 3 | Reference layer: `Primitives.Colours.*` vs semantic `Theme.*` | Primitives (Theme too sparse) | **Primitives.Colours.\*** (resolved from code) | `Theme+Generated.swift` is 33 button/content/surface roles — cannot cover granular `mono*` usages |

## Answered by the codebase (not asked)
- **Reference layer** — `Theme+Generated.swift:6-38` exposes only 33 semantic roles (button/content/surface/link); no per-shade neutral coverage → call sites must reference `Primitives.Colours.*`. (Read directly.)
- **Which colors have a token family** — computed by nearest-hex over all 54 colorsets vs `Primitives+Generated.swift`: `mono→neutrals`, `green→semanticSuccess`, `red→semanticError`, `white=neutrals0` (exact), `black≈neutrals900` (Δ14). `blue`/`yellow`/`orange` have NO neutral/semantic family. Full table → `mapping.md`.
- **Production blast radius of the review-list families** — `blue` used only in `ThemedDivider` (+demos); `yellow`/`orange` only in DebugMenu demo views. (Usage grep in `scope.md`.)
- **`ThemeProvider.*.ui` survives asset removal** — `Color.ui` is `UIColor(self)`, a pure value conversion, no asset lookup (`Utils/Extensions/Color+Extension.swift:4`).

## Assumptions surfaced (now explicit)
- The two palettes are **different ramps**, not a rename: `mono900 #101010 ≈ neutrals800`, app `black #000 ≈ neutrals900`. A swap shifts mid-ramp grays (mono300/400/700 drift Δ24-28) and several green/red shades. Exact shade correspondence in `mapping.md` is **engineering's best-fit, pending design confirmation** on the PR.
- The token export has **fewer** green/red shades (8 semantic) than the brand scale (10) → 2 shades per family collapse onto a neighbour.
- ~~ALFMOB-274 will land partial (blue/yellow/orange deferred on xcassets)~~ → **superseded by follow-up decision:** blue/yellow/orange were **deleted** (no token equivalent, no production usage), so `Colors.xcassets` is **fully** retired and the "no hardcoded hex remains" AC is fully met. See `mapping.md §B`.

## Still open (owner)
- **Exact shade correspondence for the wire-now families** — owner: **Design**. `mapping.md §A` is the proposed table; confirm/adjust via snapshot review on the PR.
- **blue / yellow / orange replacements** — owner: **Design + khoi.nguyen**. `mapping.md §B` review list; decide one-by-one in a follow-up (likely needs new upstream tokens in `Mindera/Alfie-Mobile-Design-Tokens`).
- **Migration mechanism** (call-site rename to token names vs keep `Colors.*` facade with token-backed values) — surfaced at the approval gate for the user to confirm; recommendation = adopt token names per Decision 1.
