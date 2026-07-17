# Scout Report: ALFMOB-438 — App shell, tab bar & navigation chrome

**Branch:** feat/ALFMOB-438-app-shell-nav-chrome (off feat/ALFMOB-437-splash-redesign)
**Method:** direct reads (small surface) + token/icon/snapshot scan

## Relevant Files

### App target — AppFeature module (the restyle surface)
- `Alfie/AlfieKit/Sources/AppFeature/UI/CustomTabBarView.swift` — tab bar container. `VStack{Divider(); HStack{ TabBarItemView }}`, `.background(Primitives.Colours.neutrals0)`, `frame(width: UIScreen.main.bounds.width)`.
- `Alfie/AlfieKit/Sources/AppFeature/UI/TabBarItemView.swift` — per-item. Selected = matchedGeometry **underline** (`neutrals800`, height 2) + icon tinted `neutrals900`/`neutrals400`, label tinted `neutrals800`/`neutrals500`, font `theme.font.body.small` (same weight both states). Constants: lineHeight 2, iconSize 24×24.
- `Alfie/AlfieKit/Sources/AppFeature/Navigation/RootTabView.swift` — hosts `TabView` + overlays `CustomTabBarView`. `.accentColor(Primitives.Colours.neutrals900)`, `.padding(.bottom, Primitives.Spacing.spacing12)`.
- `Alfie/AlfieKit/Sources/AppFeature/Navigation/AppFeatureView.swift` — top-level screen switch (loading/error/forceUpdate/landing). Minimal styling.
- `Alfie/AlfieKit/Sources/AppFeature/Navigation/RootTabViewModel.swift` — `tabs: [Model.Tab]` injected by composition root; order set by caller.

### Supporting (cross-module)
- `Alfie/AlfieKit/Sources/Model/Models/Navigation/Tab.swift` — `enum Tab { bag, home, shop, wishlist }` — **4 tabs**.
- `Alfie/AlfieKit/Sources/SharedUI/Helpers/Extensions/Tab+Extension.swift` — `title` (**hardcoded EN**: Bag/Home/Shop/Wishlist — no L10n), `icon` (`.home/.store/.bag/.heart`), `accessibilityId` (**hardcoded** strings).
- `Alfie/AlfieKit/Sources/SharedUI/Theme/Icons/Icon.swift` — `enum Icon: String` backed by **SF Symbols** (`.store="storefront"`, `.user="person"`, `.heart`, `.heartFill`, `.home="house"`, `.bag`).
- `Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens/Theme+Generated.swift` — **semantic `Theme.*` layer** (GENERATED — do not edit): `contentContentPrimary`=neutrals800, `contentContentPrimaryDisabled`=neutrals400, `contentContentTerciary`=neutrals500, `surfaceBackgroundPrimary`=neutrals0, `surfaceBackgroundPrimaryActive`=neutrals800, `borderSoft`=neutrals200, etc.
- `Alfie/AlfieKit/Sources/SharedUI/GeneratedTokens/Primitives+Generated.swift` — primitive Colours/Spacing (GENERATED).

### Tests
- `Alfie/AlfieKit/Tests/AppFeatureTests/AppStartupServiceTests.swift` — only test in the target. **No snapshot tests, no UI tests here.**
- `Alfie/AlfieKit/Package.swift:304,334` — `AppFeatureTests` target links `SnapshotTesting` product, but contains no `assertSnapshot` calls.
- `Alfie/AlfieTests/Snapshots/*SnapshotTests.swift` — snapshot tests exist only in the **app target** bundle (Shop/Search/PDP/etc.), not AppFeature.
- **No `__Snapshots__` directories anywhere in the repo** → no committed reference images.

## Patterns Observed
- Tab bar **already token-based** via `Primitives.*` + `theme.font.*`. The "replace hardcoded colours/spacing/typography" premise is largely already satisfied at the primitive level.
- `theme` accessed as an env-injected value; typography via `Text.build(theme.font.body.small(...))`.
- Established redesign convention (from ALFMOB-437, our base): add small components under `SharedUI/Theme/Components/`, asset-catalog assets, `AccessibilityID` enum entries; plan/scope/grill/_status docs per ticket.

## Figma (Bottom Navigation — node 671:77971, iOS)
- 5 tabs shown: **Home, Store, Wishlist, Bag, Account** — icon over label; selected (Home) = **filled/dark icon + bold black label**; unselected = outline/grey icon + grey regular label; thin top divider; NO underline indicator.

## Gaps: Figma vs current code
1. **Underline** — code shows a selected-tab underline (matchedGeometry); Figma has none.
2. **Selected label weight** — Figma bold; code same weight both states (colour-only).
3. **Selected icon fill** — Figma looks filled; code tints one template symbol.
4. **Primitive → semantic tokens** — code uses `Primitives.Colours.neutralsXXX` directly; semantic `Theme.*` layer is the intended target and maps cleanly.
5. Minor: selected icon uses `neutrals900` (no exact semantic equal; closest `contentContentPrimary`=neutrals800).

## Out-of-scope discrepancies (ticket says visual-only; no tab-set/structure/routing changes)
- Figma adds a **5th "Account" tab** — code has 4. Adding it = tab-set change → OUT.
- Figma **tab order** (Home, Store, Wishlist, Bag) differs from enum order → reorder = structure → OUT (also set by composition root, not this module).
- Figma labels shop tab **"Store"**; code title = **"Shop"** — copy change (+ these titles aren't L10n). Borderline; likely OUT / separate.

## Unresolved Questions (for grill)
- **Snapshots:** no baselines exist and AppFeatureTests has no snapshot tests. Literally "regenerate baselines" is impossible. Add new SPM/snapshot tests, or defer appearance verification per project convention?
- **Underline:** remove it to match Figma (visual change) — confirm that's wanted vs. keep current selection affordance.
- **Selected label bold + filled icon:** in scope now, or gated on ALFMOB-426 iconography?
- **Semantic token migration depth:** migrate only the 5 tab-bar colour sites, or also `RootTabView.accentColor`/padding?
- **"Store" vs "Shop" label:** touch it or leave to a copy/L10n ticket?
