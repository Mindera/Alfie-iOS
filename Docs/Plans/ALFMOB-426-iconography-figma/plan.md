---
title: Iconography — reconcile icon set with Figma
ticket: ALFMOB-426
status: completed
complexity: MEDIUM
mode: auto
blockedBy: []
blocks: []
created: 2026-07-13
---

## Overview
Replace SF-Symbol-backed rendering with the Figma **Tabler-based** icon set for the
**Arrows & System** (14) + **E-commerce** (34) categories only. Export those glyphs as vector
assets, bundle them in a new SharedUI `.xcassets`, make `Icon` a **hybrid** enum (in-scope cases
resolve to bundled assets; every other case stays an SF-Symbol fallback, which the AC permits),
add a token-bound icon view so size/tint come from generated tokens, and document the re-export.

**De-risking note:** the architecture is decoupled from the exact name→glyph mapping. After the
pipeline + hybrid enum exist, changing any mapping = re-export one SVG + edit one raw-value string.
So provisional design mappings (below) are safe to build against and cheap to correct later.

## Acceptance Criteria (feature-level → mapped to phases)
- AC1 Every in-scope Figma icon has a bundled asset named per Figma vocabulary → **P1**
- AC2 `Icon` cases resolve to bundled assets, no SF raw values for in-scope icons (design-approved fallbacks allowed) → **P2**
- AC3 Fill + OS-specific (Back, Share) variants represented; iOS keeps native form → **P1/P2**
- AC4 Icon size + tint sourced from tokens; no hardcoded points/colours in refactored components → **P3**
- AC5 Figma→repo re-export process documented → **P4**
- AC6 Appearance coverage of the in-scope set (via SPM unit tests — snapshots disabled repo-wide) → **P2/P4**

## Approach
**Hybrid, additive `Icon` enum + asset-aware rendering, minimal call-site churn.**
- Keep `Icon: String, IconRepresentable, CaseIterable` and keep **existing Swift case names stable**
  (avoids editing the 36 name-referenced call sites); change each in-scope case's **raw value to the
  bundled asset name** and add asset-aware `image`/`uiImage` on `Icon`. Asset names carry the Figma
  vocabulary → satisfies "Figma names + resolve to assets" without a breaking rename.
- Non-covered cases keep their SF-Symbol raw value → fall through to `Image(systemName:)`.
- Assets get **Render As: Template + Preserve Vector Data** so `.foregroundStyle` tinting works.
- New in-scope Figma icons with no current case are **added** as new asset-backed cases.
- A new token-bound `ThemedIcon` view maps a size token (`Sizing.iconsIcon*`) + tint to the render
  path; in-scope components migrate to it (bounded — not a full 25-site sweep).

Rationale: additive + stable-names = smallest safe diff on a shared SharedUI type used app-wide;
keeps `ThemedImage`/`ButtonIcon` untouched (out of scope); each phase leaves the app green.

## Phases (vertical slices, dependency order)
1. **P1 — Asset pipeline + catalog** (foundation). Export 48 in-scope SVGs from Figma; create
   `Icons.xcassets` (template + preserve-vector), Figma-named. App still builds (assets unused). → `phase-1-assets.md`
2. **P2 — Hybrid Icon enum + asset-aware rendering.** Point in-scope cases at assets, add new
   in-scope cases, add asset-aware `image`/`uiImage`, keep fallbacks; unit tests for resolution. → `phase-2-icon-enum.md`
3. **P3 — Token-bound `ThemedIcon` view + migrate in-scope components.** Size from `Sizing.iconsIcon*`,
   tint param; migrate the in-scope components off hardcoded frame/colour. → `phase-3-themed-icon-view.md`
4. **P4 — Docs + appearance coverage.** Re-export runbook in `Docs/`; finalize unit tests asserting
   every in-scope case resolves to a bundled asset (not `systemName`) + catalog completeness. → `phase-4-docs-coverage.md`

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `SharedUI/Theme/Icons/Icons.xcassets/**` | SharedUI | new | 48 imagesets (SVG, template, preserve-vector) + Contents.json | - |
| `AlfieKit/Package.swift` | (manifest) | edit | add `.process("Theme/Icons/Icons.xcassets")` to SharedUI `resources:` | - |
| `SharedUI/Theme/Icons/Icon.swift` | SharedUI | edit | hybrid raw values, +15 new asset cases, −31 deleted cases, asset-aware `image`/`uiImage` | - |
| DebugMenu demo views (`InputDemoView`, `DividerDemoView`, `DemoSortByView`, `ToolbarDemoView`) | DebugMenu | edit | drop named refs to deleted cases (eye/calendar/camera/chat/saleTag) | - |
| `SharedUI/Theme/Icons/IconRepresentable.swift` | SharedUI | edit (maybe) | keep default systemName path; asset path lives on `Icon` (no protocol break) | - |
| `SharedUI/Theme/Icons/ThemedIcon.swift` | SharedUI | new | token-bound icon view (size = `Sizing.iconsIcon*`, tint param) | - |
| in-scope components (Chip, Snackbar, PaginatedControl, Accordion, SearchBar, Tag, PickerMenu, SizingBanner, VerticalProductCard, ProductListing*) | various | edit | swap hardcoded `.frame`/`.foregroundStyle` for `ThemedIcon` | - |
| `AlfieKit/Tests/SharedUITests/IconTests.swift` | Tests | new | resolution + catalog-completeness unit tests | - |
| `Docs/Iconography.md` (or section in existing doc) | Docs | new | Figma→repo re-export runbook (node IDs, MCP export, catalog conventions) | - |

## Feature Flag
n/a — pure design-system refactor, no user-facing behavioural change gate. (Visual change is the
point; roll out via normal release. No RemoteConfig flag warranted — YAGNI.)

## Testing Strategy
- **Unit (SPM, SharedUI tests):** every in-scope `Icon` case → `uiImage` resolves via
  `UIImage(named:in:)` (asset present) and NOT via `systemName`; every fallback case → valid SF
  Symbol (`UIImage(systemName:) != nil`); `Icon.allCases` count guard; catalog completeness (each
  in-scope Figma name has an imageset). `ThemedIcon` maps each size token to expected point size.
- **Snapshot:** **substituted** — suite is disabled repo-wide (out of target membership, no committed
  refs). Appearance ACs met by the resolution/asset unit tests above instead. Called out explicitly.
- **UI (XCUITest):** none required (no new AccessibilityID surfaces; existing icon-view IDs unchanged).

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Name→glyph mappings not design-approved (ticket flags as "resolve at refinement") | High | Build against provisional mapping (Open Decisions §1); architecture decoupled → cheap to re-map post-hoc; flag for design sign-off |
| SVG rendering-mode wrong → icons don't tint | Med | Set Template + Preserve Vector Data in Contents.json; unit-assert renderingMode; visual check in DebugMenu IconographyDemoView |
| Shared `Icon` type used app-wide → regression | Med | Additive + stable case names (no rename); every phase ends green via `verify.sh` |
| Figma export volume (48 + fills + OS) tedious/incomplete | Med | Node-ID map already captured in scope.md; scripted `download_figma_images` batch; catalog-completeness test catches gaps |
| Latent `ThemedImage.logoBackground` uses systemName path (pre-existing) | Low | Out of scope; do not touch — note only |

## Out of Scope
- Food & Nature, Care Guide, House & Furniture, Accommodations categories.
- `ButtonIcon` (checkbox/radio control-state icons) — neither in-scope category.
- Icon **sizing/tint token definitions** (owned by parent epic ALFMOB-264; tokens already exist).
- Full 25-site call-site sweep — only in-scope components migrate (AC scopes to "refactored components").
- Android/Flutter/Web iconography (sibling tickets).
- Automated Figma export pipeline (manual/MCP export documented; automation deferred per ticket).

## Decisions (grilled — see grill.md)

### D1 — Icon mapping (final, user-decided per icon)
**Convert to bundled asset (existing case → asset name):**
chevronDown→`chevron-down`, chevronUp→`chevron-up`, chevronLeft→`chevron-left`, chevronRight→`chevron-right`,
close→`close`, checkmark→`check`, plus→`add`, minus→`minus`, download→`download`, share→`share` (iOS),
ellipsis→`more`, home→`home`, bag→`bag`, user→`account`, heart→`wishlist`, heartFill→`wishlist-fill`,
search→`search`, settings→`settings`, bell→`notification`, trash→`delete`, filter→`refine`,
hamburguerMenu→`menu`, help→`help`, warning→`alert-fill`, star→`star`, edit→`pencil`,
**grid→`grid-2`**, **listplp→`grid-1`**, list→`menu-alt`, info→`help`, closeCircleFill→`clear`,
logOut→`exit`, arrowRight→`forward`, refresh→`loading`, reload→`loading`.
(Note: info & help share the `help` asset; refresh & reload share the `loading` asset — allowed.)

**New asset-backed cases to add** (in-scope Figma icons with no existing case — bundle + case each):
`back` (iOS Back = chevron-left glyph), `homeFill`, `accountFill`, `bagFill`, `grid1Fill`, `grid2Fill`,
`starFill`, `starHalfFill`, `fastDelivery`, `refund`, `creditCard`, `orderReturn`, `package`,
`profileID`, `gift`.

### D2 — SF-Symbol fallback list (FINAL — retained, still used in production; 10)
`aCircle`, `zCircle`, `arrowLeft`, `chartUpTrend`, `chartDownTrend`, `chat2`, `location`, `logIn`,
`rewards`, `store`. These have no in-scope Figma equivalent (would come from out-of-scope categories)
and stay `Image(systemName:)`. **→ This list must be reproduced in the PR description (see PR note).**

### D3 — Delete unused cases (user-requested cleanup; 31 total)
Verified zero production references. **Unused (26, only via `allCases`):** arrowDown, arrowUp,
authentication, bookmark, callCenter, clock, copy, expand, externalLink, eyeClosed, faceID, file,
history, inbox, lock, unlock, mail, microphone, page, receipt, shrink, sizeChart, support, upload,
zoomIn, zoomOut. **Demo-only (5, referenced only in DebugMenu — delete + trim those demos):**
calendar, camera, chat, saleTag, eye. Deleting is safe: no app-UI usage; demo views iterating
`allCases` still compile; `InputDemoView` default `.eye` + `DividerDemoView`/`DemoSortByView`/
`ToolbarDemoView` named refs get trimmed in the same phase.

### D4 — Other decisions
- **Asset format:** SVG + Render-As Template + Preserve Vector Data.
- **Call-site breadth:** add `ThemedIcon`, migrate only in-scope components; full sweep deferred.
- **Fill representation:** separate cases (matches existing `heartFill`), not a `.fill` modifier.
- **Case naming:** keep existing Swift case names stable (change raw values only) → no rename churn on
  the retained call sites; new cases use Figma-derived camelCase.
- **Appearance coverage:** SPM unit tests (resolution + catalog completeness), NOT snapshots (disabled).
- **SharedUI resource wiring:** new `Icons.xcassets` must be added to the `resources:` array in
  `Alfie/AlfieKit/Package.swift` via `.process(...)` (resources are enumerated, not auto-discovered).
  Package.swift is a normal hand-edited manifest (NOT the forbidden `project.pbxproj`).

## PR note (honor at ios-resolve Step 7)
The PR description MUST include the **list of SF Symbols still in use** after this change (the D2
fallback list of 10), so reviewers/design can see exactly what was not converted to Figma artwork.
