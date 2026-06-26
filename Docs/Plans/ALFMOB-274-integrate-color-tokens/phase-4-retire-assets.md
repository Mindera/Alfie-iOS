## Phase 4: Full xcassets retirement

### Goal
With every family migrated (mono/green/red) or deleted (blue/yellow/orange), nothing reads the asset
catalog. Delete `Colors.xcassets` **entirely**, drop its `Package.swift` resource entry, and remove the
now-unused `Colors` facade + `PrimaryColors`/`SecondaryColors` types. Prove no asset color access remains.

### Acceptance criteria
- [x] `Colors.xcassets` **fully deleted** (all colorsets) and `.process("Theme/Color/Colors.xcassets")` removed from `Package.swift`.
- [x] `Color.swift` (`Colors` enum), `PrimaryColors.swift`, `SecondaryColors.swift` deleted — the whole `Theme/Color/` folder is gone.
- [x] Repo-wide grep confirms no `Color("…")` / `UIColor(named:)` color-asset access remains.
- [x] No `Colors.` / `Primary`/`SecondaryColors` references remain anywhere.
- [x] Snapshot suites: not in the AlfieTests target → none run / nothing to rebaseline (see note below).

### Steps
1. **Grep-verify no asset/facade refs** (size: S) — `Grep 'Color("'`, `'UIColor(named:'`, `'\bColors\.'` across `Alfie/Alfie` + `AlfieKit/Sources`; re-point stragglers first. Why: safe deletion.
2. **Delete catalog + facade + types** (files: `Theme/Color/*`, `AlfieKit/Package.swift`, size: S) — remove the whole `Colors.xcassets`, `Color.swift`, `PrimaryColors.swift`, `SecondaryColors.swift`, and the `.process(...)` line. Do NOT hand-edit `project.pbxproj`. Why: full retirement.

### Note — snapshots
Rebaseline is **N/A this ticket.** The snapshot suites are **not in the AlfieTests target membership**
(each file has only a pbxproj file-reference, no build-phase entry — matches the
`ProductDetailsColorSheetSnapshotTests` "Re-add Target Membership" TODO) and have **zero committed
baselines**, so they don't run in `verify.sh`. When re-enabled later, fresh baselines will capture the
new token colors. Recorded here so it isn't a silent gap.

### Checkpoint
- [x] `./Alfie/scripts/verify.sh` passes (✅ FULL VERIFICATION PASSED)
- [x] Acceptance criteria above all met
- [x] Manual: full-app visual spot-check; dark mode unaffected

### Depends on
Phase 1, Phase 2, Phase 3
