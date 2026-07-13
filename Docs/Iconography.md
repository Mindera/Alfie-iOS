# Iconography

The Alfie icon set is defined on the Figma **Iconography** page and mirrored into iOS as bundled
vector assets. This doc explains the model and how to re-export / add icons.

- **Figma source of truth:** [Alfie Design System → Iconography](https://www.figma.com/design/PWVgEoKrIw9Hv7QlOCcUoq/Alfie---Design-System?node-id=3001-7582)
  (file key `PWVgEoKrIw9Hv7QlOCcUoq`, page node `3001-7582`). Built on **Tabler Icons** (MIT), 24dp grid.
- **iOS scope (ALFMOB-426):** only the **Arrows & System** + **E-commerce** categories are integrated.
  The other categories (Food & Nature, Care Guide, House & Furniture, Accommodations) are not needed yet.

## How icons resolve

`SharedUI/Theme/Icons/Icon.swift` is a `String`-raw enum. Each case is one of:

- **Asset-backed** (in-scope Figma icon) — raw value = the bundled asset name (kebab-case, Figma
  vocabulary). Rendered via `Image(rawValue, bundle: .module)` from `Icons.xcassets`.
- **SF Symbol fallback** — raw value = an SF Symbol name. Rendered via `Image(systemName:)`. Used only
  for icons with **no** in-scope Figma equivalent (see `Icon.systemSymbolFallbacks`).

`Icon.image` / `Icon.uiImage` pick the path automatically. Assets are configured **Render As: Template
Image** + **Preserve Vector Data**, so they tint via `foregroundStyle`/`tint`.

Prefer **`ThemedIcon(_:size:tint:)`** over `Icon.x.image` at call sites — it binds size to the
`Sizing.iconsIcon{Small,Medium,Large,Xlarge}` (16/24/32/40) tokens and applies the template tint, so
components don't hardcode points/colours.

## Re-exporting from Figma

Assets are **not** design tokens (the DTCG export doesn't emit glyph artwork), so they are exported
manually and committed. Two ways:

### A. MCP (used for the initial import)
With the Figma MCP server connected, export a component node to SVG:
`download_figma_images(fileKey: "PWVgEoKrIw9Hv7QlOCcUoq", nodes: [{ nodeId, fileName: "<name>.svg" }])`.
Export the **`[COMPONENT]`** node (or, for Back/Share, the per-OS variant — iOS only).

### B. Manual
In Figma, select the icon component → Export → SVG (1×) → save as `<name>.svg`.

### Then bundle it
For each `<name>.svg`, create `SharedUI/Theme/Icons/Icons.xcassets/<name>.imageset/` containing the
SVG and a `Contents.json` with:
```json
{
  "images" : [ { "filename" : "<name>.svg", "idiom" : "universal" } ],
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "preserves-vector-representation" : true, "template-rendering-intent" : "template" }
}
```
`Icons.xcassets` is wired into the SharedUI target `resources` in `Alfie/AlfieKit/Package.swift`
(`.process(...)`) — a new catalog dir is picked up automatically, but new/renamed **imagesets** just
need the `Contents.json` above.

### To add or re-map an icon
1. Export the SVG (above) and create its imageset.
2. In `Icon.swift`: add a case (or change an existing case's raw value) to the asset name.
3. If it replaces an SF Symbol fallback, remove that case from `Icon.systemSymbolFallbacks` and update
   `IconTests` (`test_fallbackSet_matchesDesignApprovedList`, `test_iconSetComposition`).
4. Run `./Alfie/scripts/verify.sh`.

## Variants

- **Fill** variants are separate Figma components (`… (Fill)`) → separate assets/cases
  (`homeFill` → `home-fill`, etc.).
- **OS-specific** (Back, Share) are the only component *sets* (`OS=iOS`/`OS=Android`). iOS bundles the
  **iOS** form only: `back` = the iOS left-chevron glyph; `share` = the iOS share glyph.

## In-scope Figma node map

Asset name → Figma component node id (file `PWVgEoKrIw9Hv7QlOCcUoq`).

### Arrows & System
`chevron-down` 561:13054 · `chevron-up` 561:13055 · `chevron-left` 709:5218 · `chevron-right` 709:5217 ·
`back` 4526:110029 (iOS = chevron-left 709:5218) · `forward` 3453:7036 · `add` 555:7882 ·
`minus` 3160:89010 · `close` 626:8093 · `clear` 3350:3989 · `check` 3126:86708 · `more` 3659:49289 ·
`download` 3701:37064 · `share` 3820:43441 (iOS variant of set 4526:110031).

### E-commerce
`home` 3023:7875 · `home-fill` 3689:24269 · `menu` 3023:7877 · `menu-alt` 4609:41184 ·
`wishlist` 563:13638 · `wishlist-fill` 3286:36845 · `account` 3023:7884 · `account-fill` 3689:21715 ·
`bag` 3023:7886 · `bag-fill` 3689:21736 · `search` 563:13637 · `notification` 3561:21934 ·
`delete` 555:8951 · `refine` 3023:11176 · `settings` 3023:11147 · `exit` 697:8722 ·
`grid-1` 3023:10806 · `grid-1-fill` 3023:10855 · `grid-2` 3023:10807 · `grid-2-fill` 3023:10854 ·
`loading` 3231:7857 · `help` 3024:3555 · `alert-fill` 3640:28755 · `fast-delivery` 3659:55100 ·
`refund` 3659:55138 · `credit-card` 3659:55139 · `return` 3659:55140 · `package` 3659:55141 ·
`profile-id` 3914:106950 · `star` 4612:41206 · `star-fill` 4612:41205 · `star-half-fill` 4612:41204 ·
`gift` 5963:4795 · `pencil` 5966:6779.

## SF Symbols still in use (fallbacks — no in-scope Figma glyph)

`aCircle` (a.circle), `zCircle` (z.circle), `arrowLeft` (arrow.left),
`chartUpTrend` (chart.line.uptrend.xyaxis), `chartDownTrend` (chart.line.downtrend.xyaxis),
`chat2` (note.text), `location` (mappin.circle.fill), `logIn` (ipad.and.arrow.forward),
`rewards` (rosette), `store` (storefront).
