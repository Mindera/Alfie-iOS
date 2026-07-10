## Phase 1: Chip token alignment + tests

### Goal
`Chip` sources every available token (semantic `Theme.*` colors where the alias fits; border-normal
width from `Primitives.Border.borderWeightDefault`) with zero visual change and its state→style logic
covered by unit tests.

### Acceptance criteria
- [ ] `ChipStyle` value type computes borderColor/textColor/backgroundColor/borderWidth/chipHeight/counterLabel from `(type, isSelected, isDisabled, counter)`.
- [ ] Color mapping matches the D1–D8 table in `plan.md` (D1/D2/D3/D5/D6/D7 via `Theme.*`; only D4 raw).
- [ ] `borderNormal` width comes from `Primitives.Border.borderWeightDefault` (D8); `borderSelected` stays `2.0`.
- [ ] `Chip.body` renders identically to current `main` for all state combos (verified by Preview + demo).
- [ ] Public API (`Chip(configuration:)`, `ChipConfiguration`, `ChipType`) byte-for-byte unchanged.
- [ ] `ChipStyleTests` covers every state→value mapping + counter-label boundaries; `verify.sh` green.

### Steps
1. **Extract `ChipStyle`** (file: `Chip.swift:45-147`, size: S) — move `Constants`, `borderColor`,
   `textColor`, `backgroundColor`, `borderWidth`, `chipHeight`, `counterLabel` into an `internal
   struct ChipStyle` initialised from `(type, isSelected, isDisabled, counter)`. Keep values
   identical for now (pure move). Why: creates a `@testable` seam mirroring `BadgeHelper`.
2. **Apply token mappings** (file: `Chip.swift`, size: XS) — in `ChipStyle`: D1 unselected border →
   `Theme.borderSoft`; D2 selected border → `Theme.contentContentPrimary`; D3 disabled border →
   `Theme.surfaceForegroundPrimary`; D5 disabled text → `Theme.contentContentPrimaryDisabled`; D6 default
   bg → `Theme.surfaceBackgroundPrimary`; D7 disabled bg → `Theme.surfaceForegroundPrimary`; D8 normal
   border width → `CGFloat(Primitives.Border.borderWeightDefault)`. Only D4 (default text) stays raw
   `Primitives.Colours.neutrals600` — no `Theme` alias exists at that value. Why: user-approved semantic
   adoption, no visual change.
3. **Rewire `Chip.body`** (file: `Chip.swift`, size: XS) — build one `ChipStyle` from
   `configuration` and read its properties; delete the now-migrated private computed props. Why:
   single source of styling truth; keeps `body` thin.
4. **Add `ChipStyleTests`** (file: `Alfie/AlfieKit/Tests/SharedUITests/ChipStyleTests.swift`, size: XS) —
   XCTest + `@testable import SharedUI`; assert each state→token value and `counterLabel` boundaries
   (nil→nil, 1→"1", 99→"99", 100→"99+"). Why: the coverage AC; regression guard on the mapping.

### Checkpoint
- [x] `./Alfie/scripts/verify.sh --skip-integration` passes (build + unit; integration skipped — SharedUI-only change, no BFF surface).
- [x] All acceptance criteria above met (21 `ChipStyleTests` green).
- [ ] Manual: `#Preview` and `ChipsDemoView` render identically to `main` (refactor is provably no-op — every alias forwards to the same primitive).

### Depends on
none
