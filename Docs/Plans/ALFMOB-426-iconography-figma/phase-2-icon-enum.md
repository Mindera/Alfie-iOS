## Phase 2: Hybrid Icon enum + asset-aware rendering

### Goal
`Icon` renders in-scope cases from the bundled Figma assets and everything else from SF Symbols,
with no breaking rename. Every in-scope Figma icon has a case.

### Acceptance criteria
- [ ] In-scope existing cases have raw value = **asset name** per plan.md D1 (e.g. `heart = "wishlist"`, `warning = "alert-fill"`, `filter = "refine"`, `grid = "grid-2"`, `listplp = "grid-1"`, `chevronDown = "chevron-down"`).
- [ ] New asset-backed cases added (plan.md D1): `back, homeFill, accountFill, bagFill, grid1Fill, grid2Fill, starFill, starHalfFill, fastDelivery, refund, creditCard, orderReturn, package, profileID, gift`.
- [ ] Deleted cases (plan.md D3 — 31): 26 unused + 5 demo-only (calendar, camera, chat, saleTag, eye); named refs in the 4 DebugMenu demo views trimmed.
- [ ] Asset-aware rendering: `Icon.image`/`uiImage` resolve in-scope cases via `Image(rawValue, bundle:)` / `UIImage(named:in:)`; fallback cases via `Image(systemName:)`.
- [ ] Fallback cases = exactly the D2 list of 10 (`aCircle, zCircle, arrowLeft, chartUpTrend, chartDownTrend, chat2, location, logIn, rewards, store`) → still SF Symbols.
- [ ] Existing call sites for retained name-referenced cases compile **unchanged** (case names stable).
- [ ] Unit tests prove resolution (in-scope → asset, fallback → symbol).
- [ ] `verify.sh` green.

### Steps
1. **Model asset vs system per case** (file: `SharedUI/Theme/Icons/Icon.swift`, size: M) — set raw
   values to asset names for in-scope cases (D1); add the 15 new cases; **delete the 31 cases (D3)**;
   add a private `isAssetBacked` set (or a `source` computed prop). Add `Icon`-level `image`/`uiImage`
   overriding the protocol default: asset-backed → `Image(rawValue, bundle: .module)` (template
   rendering set in catalog), else → `Image(systemName: rawValue)`. Keep `literalName` = rawValue.
1b. **Trim demo refs to deleted cases** (files: `DebugMenu/.../InputDemoView.swift` (default `.eye`),
   `DividerDemoView.swift` (calendar/camera/chat), `DemoSortByView.swift` (saleTag),
   `ToolbarDemoView.swift` (chat), size: S) — swap to a surviving case or remove the row.
2. **Verify no protocol break** (file: `IconRepresentable.swift`, size: XS) — leave the protocol's
   default `image` (systemName) for `ThemedImage`/`ButtonIcon`; `Icon` provides its own. Confirm
   `ThemedImage`/`ButtonIcon` untouched.
3. **Resolution unit tests** (file: `AlfieKit/Tests/SharedUITests/IconTests.swift`, size: S) —
   `for icon in Icon.inScope`: `UIImage(named: icon.rawValue, in: .module, ...) != nil` and NOT a
   valid systemName; `for icon in Icon.fallback`: `UIImage(systemName:) != nil`; `allCases` guard.
   (Establish the `inScope`/`fallback` test fixtures from the mapping in `plan.md`.)

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes (unit tests green)
- [ ] DebugMenu `IconographyDemoView` renders in-scope icons from assets (manual visual)
- [ ] No call-site edits required (case names stable) — confirm by build

### Depends on
Phase 1
