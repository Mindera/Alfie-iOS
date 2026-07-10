# Scout Report: Chip token refactor (ALFMOB-273)

**Branch**: ALFMOB-273-refactor-chip-tokens   **Agents**: 3

## ⚠️ Ticket premise is stale
Ticket says Chip "directly references `Colors.*`, `Spacing.*`, `CornerRadius.*` constants". It does **not**.
SharedUI already fully migrated off legacy enums. `Chip.swift` today already uses:
- Colors → `Primitives.Colours.neutrals*` (state-driven computed props)
- Spacing → `Primitives.Spacing.spacing0/8/16`
- Corner radius → `Sizing.radiusRounded`
- Typography → `theme.font.body.small(...)`

## Relevant Files
### Packages / modules
- `Alfie/AlfieKit/Sources/SharedUI/Components/Chips/Chip.swift` — the only impl; `Chip` + `ChipConfiguration` + `ChipType` all inline.
- `Alfie/AlfieKit/Sources/DebugMenu/UI/Demo/Components/ChipsDemoView.swift:17` — sole non-preview usage (debug demo).
- `Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens/{Primitives,Sizing,Theme,Typography}+Generated.swift` — token API (read-only, generated).
### Reference refactors (mirror these)
- `Alfie/AlfieKit/Sources/SharedUI/Components/Indicators/BadgeViewModifier.swift` (ALFMOB-269) — raw `Primitives.Colours.*`, `Sizing.radiusRounded`, border width from `Primitives.Border.borderWeightDefault`.
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Buttons/{ThemedButton,ButtonTheme}.swift` (ALFMOB-271) — per-state spec of primitives.
### Tests
- **None.** No unit or snapshot tests reference Chip. Snapshot suite is disabled repo-wide (no target membership / refs).

## Call sites — AC "no call-site changes" is trivially safe
- `Chip(` only appears in the in-file `#Preview` (12×) and `ChipsDemoView.swift:17`. **Zero feature/production call sites.**
- Public API (`Chip(configuration:)`, `ChipConfiguration`, `ChipType.small/.large`) is untouched by any refactor of private internals.

## Remaining hardcoded `Constants` (Chip.swift:45-53) vs token equivalents
| Constant | Value | Token equivalent? |
|---|---|---|
| `borderNormal` | 1.0 | ✅ `Primitives.Border.borderWeightDefault` (Int 1) — exact, mirrors Badge ALFMOB-269 |
| `borderSelected` | 2.0 | ❌ no token (would be an arbitrary `×2`) |
| `heightSmall / heightLarge` | 36 / 44 | ❌ no sizing token (icon sizes are 16/24/32/40) |
| `closeWidth / closeHeight` | 12 | ❌ no token (no `spacing12`; `iconsIconSmall` = 16) |
| `maxCounter` | 99 | n/a (logic, not styling) |

## Colors — semantic `Theme.*` alias fit (if we chose to adopt them)
- unselected border `neutrals200` = `Theme.borderSoft` ✅
- disabled text `neutrals400` = `Theme.contentContentPrimaryDisabled` ✅
- default bg `neutrals0` = `Theme.surfaceBackgroundPrimary` ✅
- **default text `neutrals600` → no Theme alias exists** ❌ (would force a partial/inconsistent migration)
- Badge/ThemedButton use raw `Primitives.Colours.*`, so raw primitives is the established idiom.

## Conclusion
Real remaining work is small: `borderNormal` → `borderWeightDefault` token (1 line, Badge precedent).
Everything else the ticket lists is already tokenized or has no token equivalent. Test coverage is zero.
