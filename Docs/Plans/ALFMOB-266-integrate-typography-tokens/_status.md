# ALFMOB-266 — [iOS] Integrate typography tokens from design token JSON

- **Ticket:** https://mindera.atlassian.net/browse/ALFMOB-266 (Story, In Progress)
- **Epic:** ALFMOB-264 — Design System: Token Integration & Component Refactoring
- **Base branch:** main
- **Work branch / worktree:** ALFMOB-266-integrate-typography-tokens
- **Depends on:** color tokens (ALFMOB-274); codegen infra (ALFMOB-272 ✅ Done, on main)
- **Blocks:** ALFMOB-267 (component refactor)

## Key constraints (from epic ADR ALFMOB-293)
- Typography MUST use Figma token names verbatim (e.g. `Typography.display.large`,
  `heading.medium`, `body.small`) — NOT legacy iOS names (`Header.h1`, `Paragraph`).
- Generated Swift preserves token references (theme → primitives).
- `ThemeProvider.shared.font.*` access patterns must keep working; UIFont mappings reflect tokens.
- Generated tokens already exist on main: `SharedUI/GeneratedTokens/Typography+Generated.swift`.

## Phase checklist
- [x] 0. Profile loaded
- [x] 1. Input resolved (Jira ALFMOB-266 + epic ALFMOB-264)
- [x] 2. Init (branch + worktree + status)
- [x] 3. Scout → scope.md
- [x] 4. Plan → plan.md
- [x] 4.5 Grill (harden plan) — scope changed to full Figma-name migration; re-planned (5 phases) + red-teamed (red-team.md), fixes folded
- [x] APPROVAL GATE — approved 2026-06-29 (team, 3 devs)
- [ ] 5. Implement (ios-execute --team 3)  ← in progress
- [ ] 6. Commit
- [ ] 7. PR
- [ ] 8. Ticket transition
- [ ] 9. Report
