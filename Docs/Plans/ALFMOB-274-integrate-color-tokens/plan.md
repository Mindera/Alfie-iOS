---
title: Integrate color tokens from design token JSON
ticket: ALFMOB-274
status: completed
complexity: MEDIUM
mode: auto
blockedBy: []
blocks: []
created: 2026-06-23
---

## Overview
Make the ALFMOB-272 generated design tokens the source of truth for Alfie's colors. Per the grilled
decisions, the generated **`Primitives.Colours.*` names are adopted directly** (not hidden behind the old
`mono`/`green`/`red` names). Colors that have a token family are migrated to the token; colors with **no**
token family (`blue`, `yellow`, `orange`) were **deleted entirely** (follow-up decision — see below).
The `Colors` facade, `Primary`/`SecondaryColors`, and `Colors.xcassets` are **fully retired**.

## Scope split (from grill + follow-up — see `mapping.md`)
- **Migrated (has a token family):** `mono*`→`neutrals*`, `green*`→`semanticSuccess*`, `red*`→`semanticError*`, `white`=`neutrals0` (exact), `black`≈`neutrals900`. ~32 colors / ~335 call sites. Exact shade table in `mapping.md §A` (engineering best-fit, **design confirms via snapshots**).
- **Deleted (no token family):** `blue` (10), `yellow` (6), `orange` (6) = 22 colors. **Follow-up decision: deleted, not deferred** — no token equivalent and no production shipping usage (only DebugMenu demos + 1 `#Preview`). Members + colorsets removed; demo/preview refs re-pointed to nearest token. `mapping.md §B`.

## Acceptance Criteria
- [x] `mono*`, `white`, `black`, `green*`, `red*` sourced from `Primitives.Colours.*` — no asset lookups.
- [x] Call sites reference the design-token names (per Decision 1) — `Colors.primary/secondary.*` no longer used.
- [x] `blue`/`yellow`/`orange` **deleted** (no force-map); demo/preview refs re-pointed to nearest token (`mapping.md §B`).
- [x] `ThemeProvider` UIKit appearance still resolves after the colorsets are removed.
- [x] `Colors.xcassets` **fully deleted** + `.process(...)` removed from `Package.swift`; `Colors`/`Primary`/`SecondaryColors` types deleted.
- [x] Snapshot suites: not in the AlfieTests target → none run / nothing to rebaseline (recorded in `phase-4`).
- [x] `./Alfie/scripts/verify.sh` → ✅ FULL VERIFICATION PASSED.
- [x] "No hardcoded hex remains" — fully met (no deferral; whole palette is tokens now).

## Approach
**Adopt design-token names; migrate family-by-family; delete the no-token families.** For each wire-now
family, replace `Colors.primary.*` / `Colors.secondary.*` call sites with the corresponding
`Primitives.Colours.*` token (table in `mapping.md §A`). `blue`/`yellow`/`orange` had no token
equivalent and no production shipping usage, so — per the follow-up decision — they were **deleted**, not
deferred; their few demo/preview references were re-pointed to the nearest token (or to a platform color
in throwaway sample data). With every family migrated or deleted, `PrimaryColors`, `SecondaryColors`, the
`Colors` facade, and the entire `Colors.xcassets` were **removed**.

**Migration mechanism:** adopt token names at call sites (Decision 1, "design names are source of truth").
**The exact shade correspondence is engineering best-fit pending design sign-off.**

Sliced by family so the app stays green after every phase; the asset catalog is **fully retired** at the end.

## Phases
1. **Neutrals (mono/black/white)** — the bulk (~300 call sites). `phase-1-primary-neutrals.md`
2. **Semantic green/red** — `semanticSuccess`/`semanticError`, mostly validation UI. `phase-2-secondary-semantic.md`
3. **Delete no-token families (blue/yellow/orange)** — remove members; re-point demo/preview refs. `phase-3-no-token-families.md`
4. **Full xcassets retirement** — delete the whole catalog + `Package.swift` resource; delete `Colors`/`Primary`/`SecondaryColors`. `phase-4-retire-assets.md`

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| ~300 call sites under `Alfie/Alfie` + `AlfieKit/Sources` | both | edit | `Colors.primary.mono*`→`Primitives.Colours.neutrals*` per `mapping.md §A` (mechanism per gate) | - |
| green/red call sites (badges, snackbar, price, input) | SharedUI | edit | →`semanticSuccess*`/`semanticError*` | - |
| `Theme/Color/PrimaryColors.swift` | SharedUI | delete | All members migrated → file removed | - |
| `Theme/Color/SecondaryColors.swift` | SharedUI | delete | green/red migrated, blue/yellow/orange deleted → file removed | - |
| `Theme/Color/Color.swift` | SharedUI | delete | `Colors` facade no longer needed → file removed | - |
| `Theme/Color/Colors.xcassets` | SharedUI | delete | **Entire** catalog removed + `.process(...)` dropped from `Package.swift` | - |
| `Helpers/Extensions/Color+Extension.swift` | SharedUI | delete | `Color.black/.white` override removed (Copilot review) | - |
| `Components/Dividers/ThemedDivider.swift` | SharedUI | edit | mono→neutrals; preview orange→token | - |
| `DebugMenu/UI/Demo/Colors/ColorsDemoView.swift` (+ PageControl/Button/Motion/… demos) | DebugMenu | edit | Migrated swatches/accents; dropped blue/yellow/orange showcase rows | - |
| `ProductDetailsTests/ProductDetailsViewModelTests.swift` | tests | edit | Assert swatch default `neutrals900` (was `.black`) | - |

## Feature Flag
n/a — static palette refactor.

## Testing Strategy
- **Build/unit:** `./Alfie/scripts/verify.sh` per phase. No unit tests assert color values today.
- **Snapshot:** expect diffs where token hex ≠ old asset hex (`mapping.md §A` ΔRGB column predicts which). Review each; rebaseline intentional changes (`isRecording=true`, re-run, revert, commit refs). `ProductDetailsColorSheetSnapshotTests` most affected.
- **DesignTokenGen tests:** untouched (generator/tokens unchanged).
- **Manual:** spot-check primary-heavy screens, success/error snackbar, input validation, sale price, DebugMenu color demo. Dark mode unaffected (red-team m1).

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Token hex ≠ asset hex → visible shifts (mid-ramp grays Δ24-28; several green/red) | High | `mapping.md §A` ΔRGB flags worst offenders; snapshot review; **design sign-off before merge** |
| Large call-site diff if token-name migration chosen (~335 sites) | Med | Mechanical, scriptable per family; phase-by-phase keeps app green; or pick facade-values fallback at gate |
| Leaving blue/yellow/orange on xcassets = ticket partial | High (by design) | Explicit in ACs + `mapping.md §B`; tracked as follow-up; not a silent gap |
| `Color.ui` UIColor bridge breaks after asset removal | Low | Confirmed pure value conversion (`Color+Extension.swift:4`); Phase 4 verify |
| green/red 10→8 shade collapse changes a couple shades | Med | Per `mapping.md §A`; design confirms |

## Out of Scope
- Adding blue/yellow/orange (and 10-shade brand green/red, pure black) to upstream `Mindera/Alfie-Mobile-Design-Tokens` — design/upstream deliverable; unblocks the review list.
- Full migration to semantic `Theme.*` roles + deprecating the `Colors` API (sparse semantic layer; separate epic).
- Non-color tokens (spacing/typography/sizing).

## Open Questions  (resolved by grill — see `grill.md`)
- ✅ Source-of-truth = generated `Primitives.Colours.*` names (Decision 1).
- ✅ Map-now vs review-list split (Decision 2); reference layer = Primitives not Theme (Decision 3).
- ⏳ **Migration mechanism** (token-name migration [recommended] vs facade values-only) — confirm at approval gate.
- ⏳ **Exact shade table** for wire-now families — design sign-off on PR (`mapping.md §A`).
- ⏳ **blue/yellow/orange replacements** — design + khoi, one-by-one follow-up (`mapping.md §B`).
