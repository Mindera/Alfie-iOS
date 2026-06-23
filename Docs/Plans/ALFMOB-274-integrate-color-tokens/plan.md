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
`mono`/`green`/`red` names). Colors that have a token family are migrated **now**; colors with **no**
token family (`blue`, `yellow`, `orange`) go on a **review list** (`mapping.md §B`) to be resolved
one-by-one later. The asset catalog is therefore only *partially* retired this ticket.

## Scope split (from grill — see `mapping.md`)
- **Wire now (has a token family):** `mono*`→`neutrals*`, `green*`→`semanticSuccess*`, `red*`→`semanticError*`, `white`=`neutrals0` (exact), `black`≈`neutrals900`. ~32 colors / ~335 call sites. Exact shade table in `mapping.md §A` (engineering best-fit, **design confirms via snapshots**).
- **Review list (no token family):** `blue` (10), `yellow` (6), `orange` (6) = 22 colors. Production use: `blue` → only `ThemedDivider`; `yellow`/`orange` → only DebugMenu demos. Stay on `Colors.xcassets` until design provides replacements (likely new upstream tokens). `mapping.md §B`.

## Acceptance Criteria
- [ ] `mono*`, `white`, `black`, `green*`, `red*` sourced from `Primitives.Colours.*` — no asset lookups for these families.
- [ ] Call sites reference the design-token names (per Decision 1) — `Colors.primary.mono*`/`secondary.green*`/`red*` no longer used.
- [ ] `blue`/`yellow`/`orange` left intact on xcassets + recorded in `mapping.md §B` review list (NOT force-mapped).
- [ ] `ThemeProvider` UIKit appearance still resolves after the migrated colorsets are removed.
- [ ] Migrated colorsets (`Mono*`,`Black`,`White`,`Green*`,`Red*`) deleted from `Colors.xcassets`; `Package.swift` resource entry kept (catalog still holds blue/yellow/orange).
- [ ] Snapshot tests pass (rebaselined where token hex ≠ old asset hex — flagged, not auto-passed).
- [ ] `./Alfie/scripts/verify.sh` → ✅ FULL VERIFICATION PASSED.
- [ ] (Deferred, tracked) "no hardcoded hex remains" for blue/yellow/orange — follow-up ticket once review list resolved.

## Approach
**Adopt design-token names; migrate family-by-family; defer the no-token families.** For each wire-now
family, replace `Colors.primary.*` / `Colors.secondary.*` call sites with the corresponding
`Primitives.Colours.*` token (table in `mapping.md §A`), remove the migrated members from
`PrimaryColors`/`SecondaryColors`, and delete the now-dead colorsets. `blue`/`yellow`/`orange` members,
their colorsets, and `ThemedDivider`'s blue usage are left untouched and logged for review.

**Migration mechanism (confirm at approval gate):** recommended = adopt token names at call sites
(Decision 1, "design names are source of truth"). Lower-churn fallback if preferred: keep the
`Colors.primary/secondary` facade but re-point member *values* to the tokens (values-from-tokens, names
unchanged) — satisfies "sourced from tokens / no hardcoded hex" with zero call-site churn but keeps the
old names. **The exact shade correspondence is engineering best-fit pending design sign-off** regardless
of mechanism.

Sliced by family so the app stays green after every phase; xcassets is only partially deleted (blue/
yellow/orange remain) in the final phase.

## Phases
1. **Neutrals (mono/black/white)** — the bulk (~300 call sites). `phase-1-primary-neutrals.md`
2. **Semantic green/red** — `semanticSuccess`/`semanticError`, mostly validation UI. `phase-2-secondary-semantic.md`
3. **Review-list isolation (blue/yellow/orange)** — confirm these are self-contained; record list; no migration. `phase-3-no-token-families.md`
4. **Partial xcassets retirement + snapshot rebaseline** — delete migrated colorsets only. `phase-4-retire-assets.md`

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| ~300 call sites under `Alfie/Alfie` + `AlfieKit/Sources` | both | edit | `Colors.primary.mono*`→`Primitives.Colours.neutrals*` per `mapping.md §A` (mechanism per gate) | - |
| green/red call sites (badges, snackbar, price, input) | SharedUI | edit | →`semanticSuccess*`/`semanticError*` | - |
| `Theme/Color/PrimaryColors.swift` | SharedUI | edit | Remove mono/black/white members (migrated) | - |
| `Theme/Color/SecondaryColors.swift` | SharedUI | edit | Remove green/red members; **keep** blue/yellow/orange | - |
| `Theme/Color/Color.swift` | SharedUI | edit | Shrink/adjust `Colors` facade to surviving members | - |
| `Theme/Color/Colors.xcassets` | SharedUI | partial delete | Remove `Mono*`,`Black`,`White`,`Green*`,`Red*` colorsets; keep Blue/Yellow/Orange | - |
| `Components/Dividers/ThemedDivider.swift` | SharedUI | keep | blue stays (review list) — no change | - |
| `DebugMenu/UI/Demo/Colors/ColorsDemoView.swift` (+ other demos) | DebugMenu | edit | Update swatches to surviving palette where they referenced migrated members | - |
| `Alfie/AlfieTests/Snapshots/*` | AlfieTests | rebaseline | Re-record where token hex ≠ asset hex | - |

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
