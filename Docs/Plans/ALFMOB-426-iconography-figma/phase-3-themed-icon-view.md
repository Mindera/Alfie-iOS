## Phase 3: Token-bound ThemedIcon view + migrate in-scope components

### Goal
A reusable icon view binds size to `Sizing.iconsIcon*` tokens and tint to a colour param, so
in-scope components stop hardcoding `.frame(width:height:)` / `.foregroundStyle`.

### Acceptance criteria
- [ ] New `ThemedIcon` view (or view-modifier) in SharedUI takes `(Icon, size: IconSize, tint: Color)`
      where `IconSize` maps to `Sizing.iconsIconSmall/Medium/Large/Xlarge` (16/24/32/40). Applies
      `.renderingMode(.template).resizable().scaledToFit().frame(...)` + `.foregroundStyle(tint)` once.
- [ ] In-scope components migrated to `ThemedIcon` (no hardcoded points/colours at those call sites):
      at minimum Chip, Snackbar, PaginatedControl, Accordion, SearchBar, PickerMenu, SizingBanner,
      Tag, VerticalProductCard, ProductListing list-style/filter bar.
- [ ] Behaviour/appearance unchanged (same rendered size/tint as before — pick the nearest token).
- [ ] `ThemedIcon` size-mapping unit test.
- [ ] `verify.sh` green.

### Steps
1. **Add `ThemedIcon`** (file: `SharedUI/Theme/Icons/ThemedIcon.swift`, size: S) — enum `IconSize`
   → token; view composes the render modifiers once. Default tint = current default colour.
2. **Migrate in-scope components** (files: the components above, size: L → SPLIT into 2 sub-batches
   by module during execution; one owner per file) — replace inline `Icon.x.image.renderingMode…frame…foregroundStyle`
   with `ThemedIcon(.x, size: .small, tint: …)`. Match the existing pixel size to nearest token
   (16→.small, 24→.medium); if a size isn't a token value, keep closest + note.
3. **Size-mapping test** (file: `IconTests.swift` or new `ThemedIconTests.swift`, size: S) —
   assert each `IconSize` yields the token point value.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes
- [ ] Migrated components render identically (manual spot-check in DebugMenu / previews)
- [ ] `rg "\.frame\(width: *[0-9]" ` in migrated components → none for icon views

### Depends on
Phase 2
