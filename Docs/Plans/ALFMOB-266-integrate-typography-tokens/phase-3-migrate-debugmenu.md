## Phase 3: Migrate DebugMenu + demos

### Goal
Migrate all DebugMenu call sites (36 files, incl. `Demo/Typography/TypographyDemoView` and the
many `Demo/**` views with `.withSize` usages) to the new `theme.font.<group>.<style>` API.

### Acceptance criteria
- [ ] No DebugMenu file references `theme.font.header/paragraph/small/tiny`.
- [ ] `TypographyDemoView` showcases the new groups (display/heading/body/label/link) — minimal
  edit acceptable; full demo redesign out of scope.
- [ ] DebugMenu compiles.

### Steps
1. **Migrate demo views** (files: `DebugMenu/UI/Demo/**`, size: L → batches ≤5) — apply mapping;
   `.uiFont` at UIFont sites (many `.withSize` here → `<group>.<style>.uiFont.withSize(n)`).
2. **Migrate non-demo DebugMenu** (files: `DebugMenu/UI/**` remainder, size: M).
3. **Update `TypographyDemoView`** (file: `DebugMenu/UI/Demo/Typography/TypographyDemoView.swift`,
   size: M) — list the five token groups; drop references to deleted legacy tiers.
4. **Grep gate** — no `font\.(header|paragraph|small|tiny)` in DebugMenu.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] No legacy font references remain in DebugMenu.
- [ ] Manual: open DebugMenu → Typography demo.

### Depends on
Phase 1
