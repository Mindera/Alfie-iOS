# ALFMOB-387 — Shop categories via BFF `mainMenu`

- **Ticket:** [ALFMOB-387](https://mindera.atlassian.net/browse/ALFMOB-387) — [iOS] Implement Shop categories (header-nav) via BFF — replace temporary mock (Story, Trivial)
- **Base:** main
- **Branch:** ALFMOB-387-shop-categories-mainmenu
- **BFF query:** `mainMenu(handle: String! = "main-menu", platform: String): Menu!` (on Alfie-BFF `origin/main`)

## Phase checklist
- [x] P1 — Sync schema + add `MainMenu.graphql` operation + Apollo codegen
- [x] P2 — `MainMenu+Converter.swift` (Menu/MenuItem → `[NavigationItem]`)
- [x] P3 — Rewire `BFFClientService.getHeaderNav`; remove temporary static mock
- [x] P4 — Navigation flow: chevron only when item has children (`CategoriesView`)
- [x] P5 — Converter unit tests (`BFFGraphTests`)
- [x] Verify — ✅ build + unit (integration skipped; needs local BFF/Node)
- [x] Review — 2 Important fixed (type simplification + query/fragment strip); nits accepted
- [ ] Commit + PR (awaiting user go-ahead)

**status: completed (pending commit/PR)**
