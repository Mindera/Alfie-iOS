## Phase 2: Migrate SharedUI (Components + Theme)

### Goal
Migrate all SharedUI call sites (31 files: Components/* + Theme/* — Chip, ProductCards, Price,
Toolbar, SortBy, ThemedInput, ThemedButton, ThemedModal, SearchBar, ErrorView, PaginatedControl,
etc.) from the legacy `theme.font.header/paragraph/small/tiny.*` to the new
`theme.font.<group>.<style>` API, per the plan mapping.

### Acceptance criteria
- [ ] No SharedUI file references `theme.font.header/paragraph/small/tiny` (verify by grep).
- [ ] `.withSize(...)` / `.font(Font(theme.font.…))` / UIKit `UIFont` sites use `<group>.<style>.uiFont`.
- [ ] SharedUI compiles; `theme.font` mocks (if any) still satisfy the protocol.

### Steps
1. **Migrate Components** (files: `SharedUI/Components/**` ~ per grep, size: L → migrate in small
   batches ≤5 files) — apply mapping; append `.uiFont` at UIFont-typed sites (compiler-guided).
2. **Migrate Theme components** (files: `SharedUI/Theme/**` excl. Typography internals, size: M) —
   ThemedInput/Button/Modal/SearchBar etc.
3. **Grep gate** — `grep -rE 'font\.(header|paragraph|small|tiny)' SharedUI` returns nothing
   (excluding the Typography internals scheduled for Phase-5 deletion).

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] No legacy font references remain in SharedUI call sites.
- [ ] Manual: spot-check a couple of migrated components in previews.

### Depends on
Phase 1
