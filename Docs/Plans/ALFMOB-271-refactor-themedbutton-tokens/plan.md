---
title: Refactor ThemedButton to use design tokens
ticket: ALFMOB-271
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-07-09
---

## Overview
Move `ThemedButton` / `ButtonThemeSpec` styling onto the **semantic** generated token layer.
On this branch colors/spacing/radius already reference *primitive* generated tokens
(`Primitives.Colours.*`, `Primitives.Spacing.*`, `Sizing.radiusSoft`) — the ticket's premise of
hardcoded `Colors.primary.mono900` / `.white` is stale. The real work is (1) re-point the color
spec from raw neutrals to the semantic `Theme.button*` tokens (the single-source-of-truth the epic
intends), and (2) tokenize the last raw literals. Public `ThemedButton` API stays unchanged.

## Acceptance Criteria (feature-level)
- [ ] AC1 ThemedButton uses generated token values for all visual properties *for which a token exists* (colors via semantic `Theme.*`; icon size via `Sizing.*`; radius/spacing already tokenized). Gaps (button heights, 1pt border, pressed/underline colors) documented in Open Questions.
- [ ] AC2 All 4 style variants render correctly (Primary, Secondary, Tertiary, Underline).
- [ ] AC3 All 3 sizes render correctly (.small/.medium/.big).
- [ ] AC4 Loading, disabled, pressed states work correctly.
- [ ] AC5 Existing call sites do not need changes (public API byte-for-byte compatible).
- [ ] AC6 Appearance validated by tests. NOTE: repo-wide snapshot infra is currently disabled
      (see Open Q6); this plan validates via a token-mapping unit test and defers snapshot re-enable.

## Approach
Adopt the semantic `Theme.button{Primary,Secondary,Terciary,Destructive}{Background,Content,Stroke}…{Default,Disabled}`
tokens in `ButtonTheme.spec`. These encode the design team's intended values and are the correct
abstraction over the raw neutrals currently in use. Consequences (deltas vs. today) are real and are
the subject of the grill:
- Secondary/Tertiary bg `neutrals0` (opaque white) → `transparentTransparent`.
- Disabled shades shift: bg `neutrals100`→`neutrals300`, text/border `neutrals400`→`neutrals500`.
- Secondary border `neutrals800`→`neutrals900`.
- No semantic token for **pressed** (all variants) → pressed stays on `Primitives.Colours.*` w/ comment.
- **Underline** has no semantic button group → its text `default`/`disabled` adopt the semantic
  **link** tokens (`Theme.linkLinkPrimaryDefault`/`Disabled` — identical values today); pressed text
  and its (invisible) bg/border stay on `Primitives.Colours.*`.
Tokenize `iconSize = 16` → `Sizing.iconsIconSmall` (identical value, 16). Heights `36/44/52` and the
1pt stroke have no token → remain literals, documented.

Rejected: keeping the raw primitives untouched (would leave the button off the semantic layer the
epic is building — fails the spirit of AC1) and re-enabling the disabled snapshot suite / editing
`project.pbxproj` (out of scope, forbidden by rules_file, repo-wide concern).

## Phases
1. **Colors → semantic token layer** — re-point `ButtonThemeSpec` values to `Theme.button*`; lock with a token-mapping unit test.
2. **Sizing literals + gap documentation** — `iconSize` → `Sizing.iconsIconSmall`; comment remaining literal gaps.

(One vertical slice per phase; each leaves the package building & green. LOW complexity → ios-execute will run solo.)

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Alfie/AlfieKit/Sources/SharedUI/Theme/Buttons/ButtonTheme.swift` | SharedUI | edit | Map spec Default/Disabled colors to `Theme.button*`; keep pressed/underline on primitives w/ comment | - |
| `Alfie/AlfieKit/Sources/SharedUI/Theme/Buttons/ThemedButton.swift` | SharedUI | edit | `iconSize` → `Sizing.iconsIconSmall`; comment height/border-width gaps | - |
| `Alfie/AlfieKit/Tests/SharedUITests/ButtonThemeTests.swift` | SharedUITests | add | Assert `ButtonTheme.<case>.spec` maps to the expected `Theme.*` / `Primitives.*` tokens | - |

## Feature Flag
n/a — pure styling refactor, no behavior change, not gated.

## Testing Strategy
- **Unit (new):** `ButtonThemeTests` — for each of the 4 variants assert `spec.backgroundColor`,
  `textColor`, `borderColor` (+ disabled/pressed) equal the intended token constants. This is the
  runnable validation given snapshot infra is disabled; it locks the token wiring so future token
  regenerations that change a mapping are caught.
- **Snapshot (deferred):** documented in Open Q6 — infra is out of target membership repo-wide; not
  re-enabled here. If desired later, add `ThemedButtonSnapshotTests` in `AlfieTests/Snapshots/`
  mirroring `ProductDetailsViewSnapshotTests` (4 styles × 3 sizes × normal/disabled/loading).
- **Manual:** Xcode previews already enumerate all 4 variants × states — eyeball before PR.
- `verify_command`: `./Alfie/scripts/verify.sh` green (build + unit + integration).

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Semantic tokens change rendered appearance (transparent bg, shade shifts) | High (by design) | Surfaced in grill/approval; deltas are neutral-shade & on a dev integration branch; previews eyeballed |
| Secondary/Tertiary transparent bg looks wrong on non-white surfaces | Low | Buttons are placed on white surfaces today; note for QA |
| Pressed/underline left on primitives looks inconsistent with "all tokens" AC | Med | Documented gap; primitives ARE generated tokens, just not semantic; no semantic token exists |
| Token-mapping unit test couples test to generated values (brittle on regen) | Low | That's the point (catch unintended remaps); test references the same `Theme.*` constants, not literals |

## Out of Scope
- Re-enabling the repo-wide snapshot test suite / editing `project.pbxproj`.
- Adding new semantic tokens for pressed/underline (design-token JSON change — upstream).
- Any change to `ThemedButton` public API or call sites.
- Other components' token migration.

## Decisions (grilled 2026-07-09 — see grill.md)
1. **Adopt semantic `Theme.button*` layer** for Primary/Secondary/Tertiary Default+Disabled. ✅ DECIDED.
2. **Visual deltas accepted** as design-authoritative (disabled bg `neutrals100→300`, text/border `neutrals400→500`, Secondary stroke `neutrals800→900`, Secondary/Tertiary bg `neutrals0→transparentTransparent`). ✅ DECIDED.
3. **Pressed state** stays on `Primitives.Colours.*` (no semantic token) with an explanatory comment. ✅ DECIDED (code: no pressed token exists).
4. **Underline variant** text `default→Theme.linkLinkPrimaryDefault`, `disabled→Theme.linkLinkPrimaryDisabled` (semantic link layer). Pressed text + bg/border stay on `Primitives.Colours.*` (no link pressed/bg/border token). ✅ DECIDED.
5. **Snapshot AC (AC6):** satisfied via token-mapping unit test now; snapshot-suite re-enable is **out of scope** (repo-wide, needs forbidden `project.pbxproj` edit). No follow-up ticket. ✅ DECIDED.
6. **`iconSize → Sizing.iconsIconSmall`**; button heights `36/44/52` and 1pt stroke stay literals (no token exists), documented with comments. ✅ DECIDED (code: `Sizing.iconsIconSmall==16`, no height/stroke tokens).
