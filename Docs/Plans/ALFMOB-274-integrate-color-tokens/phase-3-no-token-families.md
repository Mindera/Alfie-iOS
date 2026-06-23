## Phase 3: Review-list isolation (blue / yellow / orange)

### Goal
These families have **no** design-token equivalent (`mapping.md §B`) → per the user's decision they are
**deferred for one-by-one review**, NOT migrated. This phase only confirms they are self-contained and
leaves them working on `Colors.xcassets`.

### Acceptance criteria
- [ ] `blue*` / `yellow*` / `orange* `members + colorsets remain intact and compile.
- [ ] `ThemedDivider` (only production blue) unchanged and rendering.
- [ ] `mapping.md §B` review list is complete and accurate (all blue/yellow/orange shades + their call sites).
- [ ] No accidental migration of these families.

### Steps
1. **Confirm isolation** (size: XS) — re-grep blue/yellow/orange usages; verify still only `ThemedDivider` (blue) + DebugMenu demos. Why: ensure deferral is safe.
2. **Keep facade subset** (file: `Theme/Color/SecondaryColors.swift`, `Color.swift`, size: XS) — ensure `SecondaryColors` still exposes only blue/yellow/orange after Phase 2 stripped green/red; `Colors.secondary` compiles. Why: surviving members must stay valid.
3. **Record review list** (file: `mapping.md §B`, size: XS) — already generated; cross-link from the follow-up ticket / PR description. Why: the deliverable the user asked for.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes
- [ ] Acceptance criteria above all met
- [ ] Manual: DebugMenu color demo + a screen with a blue divider still render

### Depends on
Phase 1, Phase 2
