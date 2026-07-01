## Phase 1: Neutrals (mono / black / white)

### Goal
Migrate the primary family to generated `Primitives.Colours.neutrals*` — the bulk (~300 call sites).
App stays green; `Colors.xcassets` still present (secondary + review-list families remain).

### Acceptance criteria
- [ ] Every `Colors.primary.mono*` / `.white` / `.black` call site now references `Primitives.Colours.neutrals*` per `mapping.md §A` (mechanism per gate).
- [ ] mono/black/white members removed from `PrimaryColors` (or, fallback mechanism: bodies re-pointed to tokens, names kept).
- [ ] No `Color("Mono*"|"Black"|"White", bundle:)` lookups remain.
- [ ] `ThemeProvider.setupAppearance()` `.ui` calls still resolve.

### Steps
1. **Apply the neutrals mapping** (table: `mapping.md §A`, size: M — scripted per token) — replace each `Colors.primary.monoNNN` with its `Primitives.Colours.neutralsNNN`; `white→neutrals0`; `black→neutrals900`. Why: adopt design-token names (Decision 1).
2. **Strip migrated members** (file: `Theme/Color/PrimaryColors.swift:20`, `Color.swift`, size: S) — remove mono/black/white from struct + protocol + `Colors.primary` facade. Why: source of truth is now tokens.
3. **Verify UIKit bridge** (file: `Theme/ThemeProvider.swift:28,34,38,45,73`, size: XS) — update `Colors.primary.*.ui` → `Primitives.Colours.*.ui`; confirm compiles. Why: appearance proxy must survive.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes
- [ ] Acceptance criteria above all met
- [ ] Manual: primary-heavy screen + ProductDetails color sheet snapshot diff reviewed (not blindly recorded)

### Depends on
none
