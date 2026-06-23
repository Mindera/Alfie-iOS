## Phase 4: Partial xcassets retirement + snapshot rebaseline

### Goal
Delete only the **migrated** colorsets (Mono/Black/White/Green/Red); keep Blue/Yellow/Orange until the
review list is resolved. Prove no migrated-color asset access remains, then rebaseline shifted snapshots.

### Acceptance criteria
- [ ] `Mono*`, `Black`, `White`, `Green*`, `Red*` colorsets deleted from `Colors.xcassets`; Blue/Yellow/Orange retained.
- [ ] `Package.swift` resource entry kept (catalog still holds review-list families).
- [ ] Repo-wide grep confirms no `Color("Mono*|Black|White|Green*|Red*")` / `UIColor(named:)` for migrated families remain.
- [ ] Snapshot suites updated where token hex ≠ old asset hex; intentional diffs recorded, unexpected ones investigated.
- [ ] Dead `Bundle.module` lets removed only if both structs no longer need them (blue/yellow/orange still do → likely retained).

### Steps
1. **Grep-verify migrated families gone** (size: S) — `Grep 'Color("(Mono|Black|White|Green|Red)'` + `UIColor(named:` across `Alfie/Alfie` + `AlfieKit/Sources`; re-point stragglers. Why: safe deletion.
2. **Delete migrated colorsets** (file: `Theme/Color/Colors.xcassets/*`, size: S) — remove only the migrated `.colorset` dirs; do NOT touch Blue/Yellow/Orange; do NOT hand-edit `project.pbxproj`. Why: partial retirement.
3. **Rebaseline snapshots** — **N/A this ticket.** The snapshot suites are **not in the AlfieTests target membership** (each file has only a pbxproj file-reference, no build-phase entry — matches the `ProductDetailsColorSheetSnapshotTests` "Re-add Target Membership" TODO) and have **zero committed baselines**. So they do not run in `verify.sh` and there is nothing to rebaseline. When they are re-enabled later, fresh baselines will capture the new token colors. Recorded here so it isn't a silent gap.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (✅ FULL VERIFICATION PASSED)
- [ ] Acceptance criteria above all met
- [ ] Manual: full-app visual spot-check; dark mode unaffected

### Depends on
Phase 1, Phase 2, Phase 3
