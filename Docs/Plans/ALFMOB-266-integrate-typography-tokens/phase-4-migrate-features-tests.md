## Phase 4: Migrate feature modules

### Goal
Migrate the remaining feature-module call sites (13 files: ProductListing, ProductDetails, Search,
Home, CategorySelector, MyAccount, Web, AppFeature) to the new `theme.font.<group>.<style>` API.
(Unit tests are owned by dev-1 in Phase 1 — they live in SharedUI's test target.)

### Acceptance criteria
- [ ] No feature-module file references `theme.font.header/paragraph/small/tiny`.
- [ ] `.withSize`/UIFont sites use `<group>.<style>.uiFont` (e.g. `ProductListingFilter`).
- [ ] Feature modules compile.

### Steps
1. **Migrate features** (files: the 13 feature files per grep, size: M → batches ≤5) — apply mapping;
   insert `.uiFont` at UIFont-typed sites (compiler-guided).
2. **Grep gate** — no `font\.(header|paragraph|small|tiny)` across feature modules.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] No legacy font references in feature modules.

### Depends on
Phase 1
