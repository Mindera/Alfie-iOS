# ALFMOB-273 — Refactor Chip component to use design tokens

- **Ticket:** [ALFMOB-273](https://mindera.atlassian.net/browse/ALFMOB-273) (Story, Major)
- **Base:** main
- **Branch:** ALFMOB-273-refactor-chip-tokens
- **Worktree:** .claude/worktrees/ALFMOB-273-refactor-chip-tokens
- **Target file:** Alfie/AlfieKit/Sources/SharedUI/Components/Chips/Chip.swift

## Goal
Replace hardcoded `Colors.*`, `Spacing.*`, `CornerRadius.*`, and typography in `Chip` with
design-token-generated values. Selected/unselected states must render identically; no call-site
changes. Mirrors the Badge (ALFMOB-269) and ThemedButton (ALFMOB-271) token refactors.

## Scope decision (user)
Adopt semantic `Theme.*` color aliases where they map cleanly + border-width token + unit tests.
Ticket premise stale (Chip already token-based); real work = semantic color migration + `borderNormal`→token + tests.

## Phase checklist
- [x] Scout  → scope.md
- [x] Plan   → plan.md
- [x] Grill  → hardened plan.md + grill.md
- [x] Approval gate (approved 2026-07-10)
- [x] Implement (ios-execute: verify ✅ build+unit, review ✅ no Critical/Important)
- [x] Commit (e097ae6 impl + tests)
- [ ] PR → main
- [ ] Ticket transition → In Review
