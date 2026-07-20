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

## Post-review addition (icons)
Reported in-app: tab icons didn't match Figma. Root cause: ALFMOB-426 iconography was on
`main` but not in this branch (based on 437, which predates the 426 merge). Fix:
- Merged `origin/main` in → brings `Icons.xcassets` (Tabler glyphs) + new `Icon` enum
  (`Icon.image` → `Image(assetName, bundle:)`), and `Sizing.iconsIconMedium` for icon size.
- Added `Model.Tab.icon(isSelected:)` in `Tab+Extension` → filled glyph on selected
  (home/bag/wishlist have `-fill`; shop/store has no fill variant → outline).
- OPEN: Figma "Store" glyph reads as list+magnifier; code maps shop→`.store`=`storefront`
  (awning). Which glyph the tab uses is ALFMOB-426 vocabulary — flag for design confirmation.
- NOTE: PR base is still 437, so the merge makes PR #97 diff noisy until 437 gets main
  (or retarget PR base to main).

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
