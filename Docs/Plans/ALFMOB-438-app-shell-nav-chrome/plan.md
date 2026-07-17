---
title: App shell, tab bar & navigation chrome restyle (AppFeature)
ticket: ALFMOB-438
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-07-17
---

## Overview
Visual-only restyle of the AppFeature tab bar to the modern Figma "Bottom Navigation" design,
migrating its colour/typography from raw `Primitives.*` to the semantic `Theme.*` / `theme.font.label`
layers. No navigation, routing, tab-set, or behaviour change. Single module (`AppFeature`), ~2 small files.

## Acceptance Criteria (feature-level)
- AC1: Tab bar matches the approved Figma design (selection shown by bold label + darker icon/label;
  no underline indicator; top divider retained).
- AC2: Tab-bar shell consumes `SharedUI` semantic design tokens — no bespoke hardcoded
  colours/spacing/typography, and no raw `Primitives.Colours.*` at the colour call sites.
- AC3: Appearance is covered by tests that pass (see Testing Strategy — snapshot-baseline AC
  re-interpreted; see Open Questions Q1).
- AC4: No regression in navigation, tab selection, or deep-link routing.

## Approach
The tab-bar code is already token-based at the *primitive* level, so this is a **semantic-token
adoption + Figma-selection-treatment** change, not a hardcode cleanup (the ticket's "replace
bespoke styling" premise is only partly live — documented in scope.md).

Two real visual departures from the current build, both to match Figma:
1. **Remove the selected-tab underline** (`matchedGeometryEffect`) — Figma has none.
2. **Bold the selected label** — switch labels `theme.font.body.small` → `theme.font.label.small`
   (unselected) / `theme.font.label.smallBold` (selected). Selection is then conveyed by weight +
   colour, replacing the underline affordance.

Colour sites migrate to the semantic layer (clean mapping verified in scope.md):
| Site | Current | New (semantic) |
|---|---|---|
| Tab bar background | `Primitives.Colours.neutrals0` | `Theme.surfaceBackgroundPrimary` |
| Selected label | `neutrals800` | `Theme.contentContentPrimary` |
| Unselected label | `neutrals500` | `Theme.contentContentTerciary` |
| Selected icon | `neutrals900` | `Theme.contentContentPrimary` (neutrals800 — see Q3) |
| Unselected icon | `neutrals400` | `Theme.contentContentPrimaryDisabled` |
| Top divider | default `Divider()` | `Theme.borderSoft` overlay/tint |

**Deferred (out of scope):** filled selected icons (needs ALFMOB-426 iconography); the 5th
"Account" tab, tab reorder, and "Store" label (nav structure / copy — ticket says visual-only);
dark mode. Shared nav-bars/toolbars are **not owned by the shell** (each feature flow sets its own),
so there is no shell-level nav-chrome to restyle here — noted, nothing to change.

## Phases

### Phase 1: Tab bar restyle to Figma + semantic tokens (single vertical slice)
**Goal:** The bottom tab bar renders per Figma (bold selected label, darker selected icon/label,
no underline, divider retained) using semantic `Theme.*` + `theme.font.label` tokens, with unit
coverage for the selected/unselected styling logic.

**Acceptance criteria:**
- [ ] `TabBarItemView` uses `theme.font.label.smallBold` for the selected label and
  `theme.font.label.small` for unselected; no `theme.font.body.*` remains in the file.
- [ ] The `matchedGeometryEffect` underline (and its `Constants.effectID/lineHeight/offsetLineSelected`)
  is removed; the view still builds and animates selection changes without it.
- [ ] All colour call sites in `TabBarItemView` + `CustomTabBarView` use `Theme.*` semantic tokens;
  no `Primitives.Colours.*` remains at those sites.
- [ ] Top divider retained and coloured via `Theme.borderSoft`.
- [ ] A unit test asserts the token/typography chosen for selected vs unselected state
  (extract the state→style decision so it is testable without rendering).
- [ ] `./Alfie/scripts/verify.sh --skip-integration` passes; no change to `Model.Tab`, tab order,
  routing, or `RootTabViewModel`.

**Steps:**
1. **Restyle `TabBarItemView`** (file: `Alfie/AlfieKit/Sources/AppFeature/UI/TabBarItemView.swift`,
   size: S) — remove underline branch + `namespace`/`matchedGeometryEffect` + unused `Constants`;
   apply `label.small`/`label.smallBold`; migrate icon/label colours to `Theme.*`. Keep icon
   `.renderingMode(.template)` (filled variants deferred). Preserve `accessibilityIdentifier`,
   badge, tap/pop-to-root, and `.animation(value: currentTab)`.
2. **Restyle `CustomTabBarView`** (file: `Alfie/AlfieKit/Sources/AppFeature/UI/CustomTabBarView.swift`,
   size: S) — background → `Theme.surfaceBackgroundPrimary`; divider colour → `Theme.borderSoft`.
   Remove the now-unused `@Namespace`/`namespace` plumbing passed into `TabBarItemView`.
3. **Add unit test** (file: `Alfie/AlfieKit/Tests/AppFeatureTests/` new
   `TabBarItemStyleTests.swift`, size: S) — cover the extracted selected/unselected style mapping
   (colour + typography token) for each `Model.Tab`. Swift Testing (`import Testing`).

**Checkpoint:**
- [ ] `./Alfie/scripts/verify.sh --skip-integration` passes (build + unit; integration needs local BFF).
- [ ] Acceptance criteria above all met.
- [ ] Manual: run app / SwiftUI preview → tab bar matches Figma; selecting each tab bolds its label,
  darkens its icon, no underline; deep-link/pop-to-root still work.

**Depends on:** none

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `AppFeature/UI/TabBarItemView.swift` | AppFeature | edit | Remove underline; label.small/smallBold; semantic colours | - |
| `AppFeature/UI/CustomTabBarView.swift` | AppFeature | edit | Semantic background/divider; drop namespace plumbing | - |
| `AppFeatureTests/TabBarItemStyleTests.swift` | AppFeatureTests | add | Unit test for state→style mapping | - |

## Feature Flag
n/a — visual restyle, no rollout gating requested by the ticket.

## Testing Strategy
- **Unit (primary):** `TabBarItemStyleTests` over the selected/unselected style decision — the
  verifiable substitute for the (non-existent) snapshot baselines.
- **Snapshot:** No committed baselines exist for AppFeature and the suite has no refs repo-wide
  (scope.md). Not adding record-only snapshots (they pass trivially on first run = no signal).
  See Open Questions Q1 — grill to confirm defer vs. add.
- **UI:** existing tab AccessibilityIDs (`home-tab` etc.) unchanged → no XCUITest changes needed;
  AC4 (no routing regression) covered by the unchanged navigation wiring + manual check.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Removing underline reduces selection clarity | Med | Bold label + darker colour replace it (Figma parity); manual check |
| Selected-icon neutrals900→800 shifts shade slightly | Low | Accept (semantic parity) or keep primitive — Q3 |
| "Regenerate snapshots" AC unmet as literally written | High | Re-interpret via unit test; document in PR + Q1 |
| Divider tint differs from system default | Low | Use `Theme.borderSoft`; verify against Figma |

## Out of Scope
- 5th "Account" tab, tab reorder, "Store" vs "Shop" label — nav structure/copy (ticket: visual-only).
- Filled selected icons / iconography — ALFMOB-426 (upstream dep).
- Dark mode — deferred by ticket.
- Per-screen nav bars/toolbars — owned by feature flows, not the shell.
- Tab title L10n / AccessibilityID-enum migration — pre-existing debt, separate ticket.

## Decisions (grilled 2026-07-17 — see grill.md)
- **Q1 (Snapshots): DECIDED — unit test, defer snapshots.** Appearance AC satisfied by
  `TabBarItemStyleTests`; snapshot baselines NOT added (none exist repo-wide, suite disabled).
  PR must note the AC re-interpretation.
- **Q2 (Underline): DECIDED — remove it.** Selection = `label.smallBold` + `Theme.contentContentPrimary`
  icon/label. Matches Figma.
- **Q3 (Selected icon shade): DECIDED — semantic.** `neutrals900` → `Theme.contentContentPrimary`
  (neutrals800), forced by AC2 (no raw `Primitives.Colours.*` at colour sites).
- **Q4 (Store/Shop label): DECIDED — leave "Shop".** Copy/content out of scope (ticket: visual only).
