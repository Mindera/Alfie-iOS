## Phase 3: Delete no-token families (blue / yellow / orange)

### Goal
These families have **no** design-token equivalent (`mapping.md §B`) and no production shipping usage
(only DebugMenu demos + 1 `#Preview`). Per the follow-up decision they were **deleted** — members removed
and the few demo/preview references re-pointed to the nearest generated token (or a platform color in
throwaway sample data).

### Acceptance criteria
- [x] `blue*` / `yellow*` / `orange*` members removed from `SecondaryColors`.
- [x] No `Colors.secondary.(blue|yellow|orange)` references remain anywhere.
- [x] Demo/preview references re-pointed (PageControl/Button/Motion/etc. → nearest token; ColorBanner sample swatches → platform colors).
- [x] App builds & `verify.sh` green.

### Steps
1. **Re-point demo/preview usages** (DebugMenu demos + `ThemedDivider` preview, size: S) — `blue→neutrals*`, `orange/yellow→semantic*` per `mapping.md §B`; ColorBanner sample swatches kept as platform colors to match siblings. Why: nothing customer-facing used these.
2. **Delete the members** (file: `Theme/Color/SecondaryColors.swift`, size: XS) — remove blue/yellow/orange from struct + protocol. With green/red already gone, the type is now empty → handled in Phase 4. Why: no token equivalent, no real usage.
3. **Record decision** (file: `mapping.md §B`, size: XS) — document the deletion + nearest-token mapping. Why: audit trail.

### Checkpoint
- [x] `./Alfie/scripts/verify.sh` passes
- [x] Acceptance criteria above all met
- [x] Manual: DebugMenu color demos render with the surviving palette

### Depends on
Phase 1, Phase 2
