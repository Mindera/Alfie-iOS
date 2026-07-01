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
- [x] Implement (ios-execute) — phases 1-3
- [x] Verify (`./Alfie/scripts/verify.sh --skip-integration`) — build + unit PASSED (integration env-blocked: no Alfie-BFF repo sibling)
- [x] Code review gate — 3 parallel lenses; 2 codegen fixes applied (empty-enum + collision guard), no Critical
- [x] Commit — 6 commits on feat/theme-switching
- [ ] PR → base ALFMOB-266-integrate-typography-tokens (awaiting user go)

## Follow-ups (non-blocking)
- Swift 6 migration: `ThemeColours.current` is a mutable non-isolated global — safe today (main-thread only); annotate `@MainActor` when SharedUI adopts Swift 6 / StrictConcurrency.
- Optional: add a dedicated `MockThemeService` for parity with sibling mocks (currently uses real ThemeService + MockAppDelegate/MockUserDefaults).

## Pre-settled decisions (from brainstorm)
1. Only `Primitives.Colours` varies per theme; semantic `Theme`/`Sizing`/`Typography` stay shared (selfFridge is 1:1 with Alfie's 58-token schema).
2. Apply switching via existing `AppDelegate.rebootApp()` soft-reboot — no call-site migration.
3. Theme picker entry point: Debug menu first (Settings page later).
4. Persist selection via `UserDefaultsProtocol` provider pattern + `ServiceProvider` DI.
