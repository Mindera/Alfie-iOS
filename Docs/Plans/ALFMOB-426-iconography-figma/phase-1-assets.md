## Phase 1: Asset pipeline + catalog (foundation)

### Goal
Bundle every in-scope Figma icon (Arrows & System 14 + E-commerce 34, incl. Fill + iOS OS variants)
as a vector asset in a new SharedUI catalog. App still builds; assets not yet referenced.

### Acceptance criteria
- [ ] `SharedUI/Theme/Icons/Icons.xcassets` exists with one imageset per in-scope Figma icon, named per Figma vocabulary (kebab-case: `chevron-down`, `home-fill`, `grid-2`, `alert-fill`, `share`, …).
- [ ] Each imageset: single SVG, **Render As: Template Image**, **Preserve Vector Data: true**, universal.
- [ ] Fill variants bundled as their own assets (`home-fill`, `wishlist-fill`, `account-fill`, `bag-fill`, `grid-1-fill`, `grid-2-fill`, `star-fill`, `star-half-fill`, `alert-fill`).
- [ ] OS-specific: bundle the **iOS** variant only — `share` (node 3820:43441); `back` = iOS form (reuses chevron-left; bundle `back` asset).
- [ ] `verify.sh --skip-integration` green (catalog compiles into the SharedUI resource bundle).

### Steps
1. **Export SVGs from Figma** (size: M) — `mcp__figma__download_figma_images` batched over the node-ID map in `scope.md` (fileKey `PWVgEoKrIw9Hv7QlOCcUoq`). Save to a temp dir, then move renamed into imagesets. Verify count = expected (48 files).
2. **Create catalog + imagesets** (file: `SharedUI/Theme/Icons/Icons.xcassets/**`, size: L→mechanical, one imageset per icon) — top-level `Contents.json` + per-icon `<name>.imageset/{Contents.json, <name>.svg}` with `"template-rendering-intent":"template"` and `"preserves-vector-representation":true`.
3. **Wire the resource** (file: `Alfie/AlfieKit/Package.swift`, size: XS) — add `.process("Theme/Icons/Icons.xcassets")` to the SharedUI target's `resources:` array (resources are explicitly enumerated there, e.g. existing `ThemedImages.xcassets`/`Fonts.xcassets` — NOT auto-discovered). Package.swift is a normal manifest edit; do NOT touch `project.pbxproj`.
4. **Sanity check** (size: XS) — build; confirm the catalog is in the SharedUI resource bundle, no stray/empty SVGs, count = 48.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh --skip-integration` passes (build-only OK here; no logic yet)
- [ ] 48 imagesets present, correctly named, template + preserve-vector
- [ ] Manual: none

### Depends on
none
