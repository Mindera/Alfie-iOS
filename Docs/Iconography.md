# Iconography

The Alfie icon set is defined on the Figma **Iconography** page and mirrored into iOS as bundled
vector assets. This doc explains the model and how to re-export / add icons.

- **Figma source of truth:** [Alfie Design System → Iconography](https://www.figma.com/design/PWVgEoKrIw9Hv7QlOCcUoq/Alfie---Design-System?node-id=3001-7582)
  (file key `PWVgEoKrIw9Hv7QlOCcUoq`, page node `3001-7582`). Built on **Tabler Icons** (MIT), 24dp grid.
- **iOS scope (ALFMOB-426):** the **Arrows & System** + **E-commerce** categories, plus the
  **SF Symbol - iOS** section (dedicated glyphs for icons that previously fell back to Apple SF
  Symbols). The other categories (Food & Nature, Care Guide, House & Furniture, Accommodations) are not
  needed yet.

## How icons resolve

`SharedUI/Theme/Icons/Icon.swift` is a `String`-raw enum. **Every** case is asset-backed — it resolves
to a bundled glyph via `assetName` (the raw value for most cases; aliased cases like `reload`→`loading`
keep a unique raw value but point at a shared asset). Rendered via `Image(assetName, bundle: .module)`
from `Icons.xcassets`. There are **no SF-Symbol fallbacks** — the Figma "SF Symbol - iOS" section
supplies bundled glyphs for the letter/chart/system icons that have no Tabler equivalent.

Assets are configured **Render As: Template Image** + **Preserve Vector Data**, so they tint via
`foregroundStyle`/`tint`.

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
(`.process(...)`). New/renamed **imagesets inside the already-processed `Icons.xcassets`** are picked
up automatically (they just need the `Contents.json` above). Adding a **new** catalog directory,
however, requires its own `.process(...)` entry in `Package.swift` — SharedUI resources are
enumerated explicitly, not auto-discovered.

### To add or re-map an icon
1. Export the SVG (above) and create its imageset.
2. In `Icon.swift`: add a case (or change an existing case's raw value) to the asset name.
3. Update `IconTests` (`test_iconSetCount`) if the case count changed.
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

### SF Symbol - iOS
Dedicated glyphs for the icons that previously fell back to Apple SF Symbols (section frame `6951:616`).
Figma labels them by SF Symbol name; asset names are the kebab-cased form.
`a-circle` 6951:614 · `z-circle` 6951:610 · `arrow-left` 6951:615 · `chart-line-uptrend-xyaxis` 6951:613 ·
`chart-line-downtrend-xyaxis` 6951:609 · `note-text` 6951:608 · `mappin-circle-fill` 6951:612 ·
`ipad-and-arrow-forward` 6951:607 · `storefront` 6951:611 · `xmark-circle-fill` 6951:606 ·
`info-circle` 6951:730 · `list-bullet` 6951:729.

## Accessibility

Bundled asset `Image`s expose their raw asset name to VoiceOver. So: icon-only buttons set an explicit
`.accessibilityLabel` (see `L10n.Accessibility.*`), and `ThemedIcon` is **decorative by default** —
pass `accessibilityLabel:` only for semantic icons, otherwise it is hidden from assistive tech.

## SF Symbols

**None.** Every `Icon` case now resolves to a bundled asset. The letter/chart/system icons that used to
fall back to SF Symbols (`a.circle`, `z.circle`, `arrow.left`, `chart.line.uptrend/downtrend.xyaxis`,
`note.text`, `mappin.circle.fill`, `ipad.and.arrow.forward`, `storefront`, `xmark.circle.fill`) are now
bundled from the "SF Symbol - iOS" section; `info` and `list` also moved to their dedicated
`info-circle` / `list-bullet` glyphs (previously approximated to `help` / `menu-alt`). `ButtonIcon`
(checkbox/radio) still uses SF Symbols but is out of this ticket's scope.
