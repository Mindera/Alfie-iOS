# Grill: App shell, tab bar & navigation chrome restyle (AppFeature)
**Plan**: Docs/Plans/ALFMOB-438-app-shell-nav-chrome/plan.md   **Ticket**: ALFMOB-438   **Date**: 2026-07-17   **Branch**: feat/ALFMOB-438-app-shell-nav-chrome

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| Q1 | How to satisfy the "regenerate snapshot baselines" AC | Unit test, defer snapshots | Unit test, defer snapshots | Testing Strategy + AC3 confirmed; PR notes AC re-interpretation |
| Q2 | Remove the selected-tab underline to match Figma | Remove | Remove | Phase 1 step 1 confirmed; selection = bold label + semantic colour |

## Answered by the codebase / ticket (not asked)
- Q3 (selected-icon shade neutrals900 → semantic) — settled by AC2 ("no raw `Primitives.Colours.*`
  at colour sites"); `neutrals900` has no semantic token, so `Theme.contentContentPrimary` (neutrals800)
  is forced.
- Q4 (Store vs Shop label) — settled by ticket Out of Scope ("visual redesign only"; per-screen
  content/copy excluded). Leave "Shop".
- Shared nav-bars/toolbars restyle — settled by scope.md: the shell (`AppFeatureView`/`RootTabView`)
  owns no nav bar/toolbar; each feature flow sets its own. Nothing to change in this ticket.
- 5th "Account" tab / tab reorder — settled by ticket Out of Scope (no tab-set/structure change);
  `Model.Tab` has 4 cases and tab order is set by the composition root, not this module.

## Assumptions surfaced (now explicit)
- The tab bar is already `Primitives.*`-token-based; the ticket's "replace bespoke hardcoded styling"
  premise is only partly live — the real work is semantic `Theme.*` + `theme.font.label` adoption.
- "Match Figma" for selection state is achieved without ALFMOB-426 iconography: bold label + colour,
  keeping the existing template-tinted SF Symbol icons (filled variants deferred).

## Still open (owner)
- None blocking. Filled selected icons remain with ALFMOB-426 (iconography, upstream); tab-title
  L10n + AccessibilityID-enum migration remain as separate pre-existing-debt tickets.
