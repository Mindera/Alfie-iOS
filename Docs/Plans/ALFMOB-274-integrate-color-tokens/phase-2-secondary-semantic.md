## Phase 2: Semantic green / red

### Goal
Migrate `green*`→`Primitives.Colours.semanticSuccess*` and `red*`→`semanticError*` per `mapping.md §A`.
Production consumers are semantic (success/error), so the semantic tokens are the correct source.

### Acceptance criteria
- [ ] All `Colors.secondary.green*` / `.red*` call sites reference `semanticSuccess*` / `semanticError*` per `mapping.md §A`.
- [ ] green/red members removed from `SecondaryColors` + protocol; blue/yellow/orange **retained**.
- [ ] No `Color("Green*"|"Red*", bundle:)` lookups remain.
- [ ] Semantic UI (badge dot, snackbar variants, price strikethrough, input error) renders correctly.

### Steps
1. **Apply green/red mapping** (table: `mapping.md §A`, files: `Components/Indicators/BadgeViewModifier.swift`, `BadgeTabViewModifier.swift`, `Components/Snackbar/SnackbarView.swift`, `Components/Price/PriceComponentView.swift`, `Theme/Inputs/ThemedInput.swift`, size: S) — swap call sites to `semantic*`. Why: semantic tokens are the source.
2. **Strip green/red members** (file: `Theme/Color/SecondaryColors.swift:55-86`, size: S) — remove green/red from struct + protocol; keep blue/yellow/orange. Why: migrated.
3. **Note 10→8 shade collapses** — verify the two collapsed shades per family (`mapping.md §A`) look acceptable; flag for design. Why: semantic export has fewer shades.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes
- [ ] Acceptance criteria above all met
- [ ] Manual: success + error snackbar, input validation error, sale price — colors correct

### Depends on
Phase 1
