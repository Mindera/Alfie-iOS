# ALFMOB-438 — App shell, tab bar & navigation chrome (AppFeature)

- **Ticket:** https://mindera.atlassian.net/browse/ALFMOB-438 (Story, labels: design-system)
- **Base branch:** feat/ALFMOB-437-splash-redesign
- **Working branch:** feat/ALFMOB-438-app-shell-nav-chrome
- **Type:** feat (visual redesign, visual-only)

## Ticket summary
Restyle app shell + tab bar + shared nav chrome in `AppFeature` to modern Figma design.
Replace bespoke styling with SharedUI tokens/components. Regenerate snapshot baselines.
No nav/routing behaviour change. Dark mode deferred.

Scope files: AppFeatureView, RootTabView, CustomTabBarView, TabBarItemView.

## Known caveats (from project memory — verify in scout)
- Snapshot suite disabled repo-wide (no committed refs) — "regenerate baselines" AC may not be literally satisfiable.
- Generated design-token colours largely dormant; app renders via legacy asset-catalog Colors.*.
- "Refactor to tokens" tickets have had stale premises before — read files first.

## Phase checklist
- [x] Ticket fetched
- [x] Branch created
- [x] Scout → scope.md
- [x] Plan → plan.md
- [x] Grill → hardened plan
- [x] Approval gate
- [x] Implement (ios-execute)
- [x] Commit
- [x] PR
