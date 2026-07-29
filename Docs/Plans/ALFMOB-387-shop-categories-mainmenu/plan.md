# Plan — ALFMOB-387: Shop categories via BFF `mainMenu`

**complexity:** low-moderate (1 new query + 1 converter + wiring + tests; single feature slice)
**Feature flag:** n/a  ·  **HIGH-RIGOR:** no (not checkout/payment/auth/PII/bag)

## Goal
Replace the temporary static category tree in `BFFClientService.getHeaderNav` with a real
BFF call to the new `mainMenu` query, mapping `Menu`/`MenuItem` → `[NavigationItem]` at the
boundary (DTO→domain), mirroring the existing `ProductListing`/`ProductDetails` converters.

## BFF contract (Alfie-BFF origin/main)
```graphql
mainMenu(handle: String! = "main-menu", platform: String): Menu!
type Menu     { handle: String  id: ID  items: [MenuItem!]!  title: String }
type MenuItem { id: ID!  items: [MenuItem]  title: String!  url: String }   # recursive
```
BFF passes Shopify menu-item `url` through verbatim; BFF unit fixtures use relative paths
(`/`, `/shop`, `/shop/new`, `/shop/new/dresses`).

## Domain target
`NavigationItem { id, type: NavigationItemType, title, url: String?, media: Media?, items: [NavigationItem]?, attributes }`
Consumer (`CategoriesViewModel.didSelectCategory`):
- item **with children** → shows sub-categories (type-agnostic).
- **leaf** `.listing` → strips leading `/` from `url` and uses the remainder as the Shopify
  **collectionHandle** for `productList`.

## DECISIONS (resolved)
- **Sub-menu model:** single-call nested tree (Shopify caps menus at 3 levels; BFF returns all
  3 in one `mainMenu` call). No lazy per-tap re-fetch — `MenuItem` has no handle and Shopify
  sub-menus aren't separately addressable. Drill-down uses the nested `items` already fetched.
- **Chevron (navigation-flow change):** show the disclosure chevron **only when
  `item.items` is non-empty**; hide it for leaves. Tapping a parent drills into its children;
  tapping a leaf opens the PLP (existing `didSelectCategory` already branches this way).

## URL → collection handle
`didSelectCategory` uses a leaf's `url` (minus leading `/`) directly as the collection handle,
so a multi-segment menu path like `/shop/new/dresses` would break `productList`.
**Rule:** converter sets each leaf's `NavigationItem.url = "/" + <last non-empty path component
of MenuItem.url>` (`/shop/new/dresses` → `/dresses`, `/collections/women` → `/women`,
`/women` → `/women`). Last path component == Shopify collection handle. Parent nodes keep their
children and recurse; items with no `url` **and** no children are dropped.
*Risk:* exact real Shopify menu URL format unconfirmed; the integration-test path (live BFF)
validates it. Heuristic is the best available default.

## Type mapping
- **All items → `.listing`** (ticket: leaves resolve to a collection handle → existing PLP flow).
  URL→type inference was dropped in review (YAGNI + it routed exotic types into a broken webview
  branch). Parents drill in via `items` regardless of type.
- Handle extraction: last path segment, sans `?`query/`#`fragment, lowercased. `/` (no segment) → dropped.
- `media: nil`, `attributes: nil` (BFF menu exposes neither).

## Phases

### P1 — Schema + operation + codegen
- Add `Sources/BFFGraph/CodeGen/Queries/Navigation/MainMenu.graphql`:
  `query MainMenu($handle: String!, $platform: String) { mainMenu(handle:$handle, platform:$platform) { handle title items { id title url items { id title url items { id title url } } } } }`
  (3 levels — matches the BFF's `get-menu.query.gql` and Shopify's 3-level menu cap.)
- Sync schema: `ALFIE_BFF_PATH=/Users/admin.khoi.nguyen/Workspace/Alfie-BFF ./Alfie/scripts/sync-bff-schema.sh`
  (copies BFF `src/schema.gql` → `schema.graphqls`, runs `run-apollo-codegen.sh`).
- **verify:** `BFFGraphAPI.MainMenuQuery` + `Menu`/`MenuItem` selection types + mocks generated; package builds.

### P2 — Converter
- New `Sources/Core/Services/BFFService/Converters/MainMenu+Converter.swift`:
  `extension BFFGraphAPI.MainMenuQuery.Data.MainMenu { func convertToNavigationItems() -> [NavigationItem] }`
  + private recursive `MenuItem → NavigationItem?` applying the URL→handle + type mapping above.
- **verify:** compiles; pure/deterministic, no I/O.

### P3 — Wire + remove mock
- Rewrite `BFFClientService.getHeaderNav` body:
  map `NavigationHandle` → Shopify handle string (`.header`→`"main-menu"`, others → rawValue),
  `executeFetch(BFFGraphAPI.MainMenuQuery(handle:…, platform: BFFPlatform.predefined.rawValue))`,
  return `.mainMenu.convertToNavigationItems()`. Delete the static `categories` array + TEMPORARY comment.
- Keep protocol signature (`includeSubItems`/`includeMedia`) unchanged; menu returns the full tree.
- **verify:** no refs to the mock remain (`grep TEMPORARY` clean); builds.

### P4 — Navigation flow: conditional chevron
- `CategorySelector/UI/CategoriesView.swift` (`categoriesListItem`): show `Icon.chevronRight`
  **only when the item has children** (`item.items?.isEmpty == false`); hide for leaves.
  Thread a `hasChildren`/`showChevron` bool into the row builder (currently the chevron is
  unconditional and the row builder only gets `title`/shimmer/color). Same view renders every
  drill-down level, so all levels get the conditional chevron.
- **verify:** builds; parents show chevron, leaves don't.

### P5 — Tests
- New `Tests/BFFGraphTests/MainMenuConverterTests.swift` (mirror `ProductListingConverterTests`):
  build `MainMenuQuery.Data.MainMenu` via generated `Mock`, assert:
  leaf → `.listing` with `/<handle>`; multi-segment path → last-segment handle; nesting preserved
  (3 levels); nil-url leaf dropped; special urls → correct `NavigationItemType`; empty menu → `[]`;
  parent with children keeps `items` (drives chevron).
- **verify:** `./Alfie/scripts/verify.sh` → build + unit (integration if BFF/Node available).

## Testing strategy
Unit-only (converter is pure). Snapshot suite is disabled repo-wide — not used. Integration
test path exercises the real `mainMenu` if the local BFF is up (validates the URL→handle heuristic).

## Out of scope
- BFF schema changes (already shipped on BFF main).
- Deep-link handle/slug follow-up → ALFMOB-386.

## File changes
| File | Change |
|---|---|
| `Sources/BFFGraph/CodeGen/Queries/Navigation/MainMenu.graphql` | new operation |
| `Sources/BFFGraph/CodeGen/Schema/schema.graphqls` | synced from BFF (generated input) |
| `Sources/BFFGraph/API/**`, `Sources/BFFGraph/Mocks/**` | regenerated (do not hand-edit) |
| `Sources/Core/Services/BFFService/Converters/MainMenu+Converter.swift` | new converter |
| `Sources/Core/Services/BFFService/BFFClientService.swift` | rewire `getHeaderNav`, remove mock |
| `Sources/CategorySelector/UI/CategoriesView.swift` | chevron only when item has children |
| `Tests/BFFGraphTests/MainMenuConverterTests.swift` | new tests |
