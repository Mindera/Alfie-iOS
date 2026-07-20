# Scout Report: ALFMOB-426 Iconography reconcile with Figma

**Branch**: feat/ALFMOB-426-iconography-figma   **Agents**: 3 (SharedUI icon system, call sites, Figma inventory)

## Current iOS icon system

### Icon.swift — `SharedUI/Theme/Icons/Icon.swift`
- `public enum Icon: String, IconRepresentable, CaseIterable` — **flat, 76 cases**, raw value = SF Symbol name.
- Cases with no explicit raw value use the case name as the symbol (`bag`→`"bag"`).
- Fill variants exist only as **discrete cases** (`heartFill`, `closeCircleFill`, `location`=`mappin.circle.fill`, …) — no generic `.fill` modifier.
- No OS-specific (`#if`) handling.

### IconRepresentable.swift — `SharedUI/Theme/Icons/IconRepresentable.swift`
- `public protocol IconRepresentable: RawRepresentable` with `literalName: String`, `bundle: Bundle`.
- `var image: Image { Image(systemName: rawValue) }` — **rendering is SF-Symbol-only**. `uiImage` = `UIImage(systemName:)`.
- No token references. Size/tint are the caller's responsibility.
- Sibling `ThemedImage` enum uses the SAME protocol but is asset-backed (`logo-ht-l`) — proves the protocol can front assets, but the shared `image` getter still uses `systemName` (needs verifying — likely overridden).

### ButtonIcons.swift
- `enum ButtonIcon` (internal) — 6 checkbox/radio control-state icons. **Out of scope** (not Arrows & System or E-commerce).

### Asset catalogs
- **No icon asset catalog exists.** `ThemedImages.xcassets` holds only a background logo. `Fonts.xcassets` is fonts.
- New `.xcassets` for icons must be created in SharedUI.

### Size/tint tokens
- `Sizing.iconsIconSmall/Medium/Large/Xlarge` = **16 / 24 / 32 / 40 pt** exist (`GeneratedTokens/Sizing+Generated.swift`) but are **referenced nowhere** except their definitions.
- Every call site hand-applies size/tint: `.renderingMode(.template).resizable().scaledToFit().frame(width:height:)` + `.foregroundStyle(...)`, sizes hardcoded or via per-component `Constants`, tint via `Primitives.Colours.*`.
- **No centralized icon view.** ~25 duplicated call sites.
- No icon-specific tint token in theme JSON; tint would come from `Theme.*content*` / `Primitives.Colours.*`.

## Call sites (what a rename breaks)
- **36 `Icon` cases referenced by name** (renaming these requires updating call sites):
  `aCircle, arrowLeft, bag, bell, calendar, camera, chartDownTrend, chartUpTrend, chat, chat2, checkmark, chevronDown, chevronLeft, chevronRight, close, closeCircleFill, filter, grid, heart, heartFill, home, info, list, listplp, location, logIn, logOut, rewards, saleTag, search, settings, share, store, user, warning, zCircle`
- 40 cases reached **only via `Icon.allCases`** in 3 demo views (`IconographyDemoView`, `ButtonDemoView`, `InputDemoView`) — no per-name references.
- **No tests** reference Icon cases.
- Accessibility IDs on icon views are independent string IDs (not derived from case names) — safe.
- Two raw `Image(systemName:)` bypasses exist in DebugMenu only (`SpacingDemoView`).

## Figma inventory — Iconography page (file PWVgEoKrIw9Hv7QlOCcUoq, node 3001-7582)
Built on **Tabler Icons (MIT)**, 24dp grid. Six categories; **only Arrows & System + E-commerce in scope**.
Figma access via MCP is **confirmed working** (get_figma_data + download_figma_images available).

### Naming: Title Case with spaces (NOT kebab). Fill = ` (Fill)` suffix. OS = component-set `OS=iOS/Android` variant prop.

### Arrows & System (14) — component node IDs
Chevron Down `561:13054`, Chevron Up `561:13055`, Chevron Left `709:5218`, Chevron Right `709:5217`,
**Back** (SET `4526:110030`; iOS variant `4526:110029` = reuses Chevron Left; Android `626:12516`),
Forward `3453:7036`, Add `555:7882`, Minus `3160:89010`, Close `626:8093`, Clear `3350:3989`,
Check `3126:86708`, More `3659:49289`, Download `3701:37064`,
**Share** (SET `4526:110031`; iOS `3820:43441`, Android `3820:43440`).

### E-commerce (34) — component node IDs
Home `3023:7875` / Home (Fill) `3689:24269`, Menu `3023:7877`, Menu Alt `4609:41184`,
Wishlist `563:13638` / (Fill) `3286:36845`, Account `3023:7884` / (Fill) `3689:21715`,
Bag `3023:7886` / (Fill) `3689:21736`, Search `563:13637`, Notification `3561:21934`,
Delete `555:8951`, Refine `3023:11176`, Settings `3023:11147`, Exit `697:8722`,
Grid 1 `3023:10806` / (Fill) `3023:10855`, Grid 2 `3023:10807` / (Fill) `3023:10854`,
Loading `3231:7857`, Help `3024:3555`, Alert (Fill) `3640:28755` (fill-only, no outline),
Fast Delivery `3659:55100`, Refund `3659:55138`, Credit Card `3659:55139`, Return `3659:55140`,
Package `3659:55141`, Profile ID `3914:106950`,
Star `4612:41206` / (Fill) `4612:41205` / (Half Fill) `4612:41204`, Gift `5963:4795`, pencil `5966:6779`.

### Export mechanics
- Standard icon = single `[COMPONENT]` → export node directly as SVG.
- Fill variant = separate sibling component (its own node) → separate asset.
- OS icons (Back, Share) = only true component sets → export per-OS; iOS keeps its native form (Back iOS = chevron-left; Share iOS = square-and-arrow-up style).
- Figma guidance: "Use vector formats… path simplified and in a single layer." Letter-in-icon glyphs are discouraged by design.

## Coverage gap (in-scope Figma vs. code-referenced icons)
Load-bearing cases WITH an in-scope Figma equivalent (map to bundled asset): chevronDown/Left/Right,
close, checkmark→Check, bag, heart→Wishlist, heartFill→Wishlist(Fill), home, search, settings, share,
user→Account, warning→Alert(Fill), bell→Notification, filter→Refine, grid→Grid 1, listplp→Grid 2(?),
info→Help(?). (Some mappings are design decisions — see Unresolved.)

Load-bearing cases with **NO in-scope Figma equivalent → must stay SF Symbol fallback** (AC allows
"design-approved fallbacks"): `aCircle, zCircle` (letter icons, discouraged), `calendar, camera,
location, chat, chat2, logIn, logOut, store, chartUpTrend, chartDownTrend, rewards, saleTag, arrowLeft(?)`.

New Figma icons not currently used (become new asset-backed cases, available for future use): Forward,
Add, Minus, Clear, More, Download, Menu, Menu Alt, Delete, Exit, Grid 2 family, Loading, Fast Delivery,
Refund, Credit Card, Return, Package, Profile ID, Star family, Gift, pencil.

## Patterns Observed
- Design-token codegen already established (Primitives/Theme/Sizing/Typography +Generated.swift from DTCG JSON). Icon *artwork* is NOT a token — not emitted by codegen; must be bundled manually.
- `IconRepresentable` is the extension point; `ThemedImage` already fronts an asset via it.
- Verify via `./Alfie/scripts/verify.sh`. Snapshot suite is disabled repo-wide (out of target membership) — appearance coverage via SPM unit tests, not snapshots.

## Unresolved Questions (for grill / design)
1. **Exact SF-Symbol→Tabler name mappings** — semantic mappings (heart→Wishlist, warning→Alert, filter→Refine, info→Help, listplp→Grid 2) are design decisions; some are ambiguous (arrowLeft, closeCircleFill, list).
2. **SF fallback list** — which non-covered icons stay SF Symbols; AC says "confirm with design".
3. **Asset format** — SVG vs PDF in `.xcassets`; template rendering mode for tinting. (Xcode 15+ supports SVG with "preserve vector data" + template.)
4. **Call-site refactor breadth** — AC "no hardcoded points/colours at icon call sites in the refactored components" — full centralized `IconView`(size/tint token-bound) + migrate ~25 sites, or scope to a new token-bound icon view + migrate only components touched?
5. **Fill representation** — separate cases (`homeFill`) vs a `.fill` modifier / associated-value style on the enum.
6. **Enum breaking change** — renaming 36 referenced cases to Figma vocabulary vs. keeping Swift case names and only changing resolution to assets (less churn, keeps call sites stable).
7. **Appearance coverage** — snapshot suite disabled; substitute SPM unit tests asserting each in-scope case resolves to a bundled asset (not systemName).
