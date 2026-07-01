# Status — Theme Switching (second design-token colour theme + runtime switch)

- **Task:** Add a second design-token colour theme ("selfFridge", values from the validated 1:1 slate token file) and runtime switching between Alfie default and selfFridge.
- **Ticket:** none (free-form) — Jira project ALFMOB
- **Base branch:** `ALFMOB-266-integrate-typography-tokens` (feature stacks on the design-token system, NOT `main`)
- **Branch / worktree:** `ALFMOB-theme-switching`
- **Mode:** TBD (set by plan complexity)

## Phase checklist
- [x] Scout → scope.md (from prior brainstorm/research)
- [x] Plan → plan.md (+ phase-1/2/3)
- [x] Grill (skipped — decisions pre-settled)
- [x] Approval gate (approved: base=ALFMOB-266-integrate-typography-tokens; display names hardcoded)
- [ ] Implement (ios-execute)
- [ ] Verify (`./Alfie/scripts/verify.sh`)
- [ ] Code review gate
- [ ] Commit
- [ ] PR → base

## Pre-settled decisions (from brainstorm)
1. Only `Primitives.Colours` varies per theme; semantic `Theme`/`Sizing`/`Typography` stay shared (selfFridge is 1:1 with Alfie's 58-token schema).
2. Apply switching via existing `AppDelegate.rebootApp()` soft-reboot — no call-site migration.
3. Theme picker entry point: Debug menu first (Settings page later).
4. Persist selection via `UserDefaultsProtocol` provider pattern + `ServiceProvider` DI.
