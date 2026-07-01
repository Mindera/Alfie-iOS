---
title: Theme switching — second design-token colour theme (selfFridge) + runtime switch
ticket: n/a
status: completed
complexity: MEDIUM
mode: auto
blockedBy: []
blocks: []
created: 2026-07-01
---

## Overview
Add a second design-token colour theme, **selfFridge** (values from the validated 1:1 "slate" token
file), and let the user switch themes at runtime. Colours become swappable at the generated-token
layer; switching applies via the existing `AppDelegate.rebootApp()` soft-reboot; the selection
persists across launches; the picker lives in the Debug menu first.

## Acceptance Criteria
- [ ] A second colour theme "selfFridge" exists, generated from a 1:1 token file (same 58 token names as Alfie).
- [ ] Switching the active theme changes app colours across the whole UI (SwiftUI + UIKit chrome).
- [ ] The selected theme persists across app launches.
- [ ] A Debug-menu "Theme" screen lists available themes, shows the current one, and applies a selection.
- [ ] `./Alfie/scripts/verify.sh` passes; no changes to the ~429 existing `Primitives.Colours.*` call sites.

## Approach
Colours are `static let` today (computed once, cached) → nothing changes at runtime. Fix: make
`Primitives.Colours.*` computed `var`s reading from an active palette holder (`ThemeColours.current`)
that is set at launch and swapped on selection, then `rebootApp()` rebuilds the SwiftUI tree. Only
the colour **primitives** vary per theme; the semantic `Theme`/`Sizing`/`Typography` generated layers
already reference primitives by symbol, so they auto-follow with **zero call-site edits**.

Module boundaries are forced by the package graph (**SharedUI → Model**, Model → nothing):
- **SharedUI (generated):** `ColourPalette` struct + per-theme instances + `ThemeColours.current`
  holder + `AppTheme: String, CaseIterable` (id + `palette` + `displayName`).
- **Model:** `ThemeService` persists the selected **id string** only (no SharedUI import → no cycle),
  mirroring `ProductListingStyleProvider`.
- **App layer (AppDelegate / ServiceProvider):** bridges — applies the palette at launch and, on
  change, does apply → `DesignSystem.shared.setupAppearance()` → `rebootApp()`; passed into DebugMenu
  via a closure (matching the FlowViewModel-closure convention).

See `scope.md` for file:line anchors and `../theme-switching/scope.md` research provenance.

## Phases
1. **Codegen + second theme (foundation)** — `phase-1-codegen-second-theme.md`
2. **Persistence + apply mechanism** — `phase-2-persistence-apply.md`
3. **Debug-menu picker UI** — `phase-3-debug-picker.md`

Order is dependency-driven: Phase 1 is the shared foundation both later slices need; Phase 2 wires
persistence + the launch/reboot apply path; Phase 3 adds the user-facing entry point.

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `Tools/DesignTokenGen/Sources/DesignTokenGenCore/TokenLoader.swift` | codegen | edit | Parse hex colour strings → components; load `.primitives.*` modes into per-theme palettes | - |
| `Tools/DesignTokenGen/Sources/DesignTokenGenCore/Emitter.swift` | codegen | edit | Emit `ColourPalette`/`AppTheme`/`ThemeColours`; `Primitives.Colours` → computed vars | - |
| `Tools/DesignTokenGen/Tests/DesignTokenGenCoreTests/*` | codegen | edit | Tests for hex parsing + multi-theme emission | - |
| `.../SharedUI/DesignTokens/.primitives.selffridge-theme.tokens.json` | SharedUI | add | selfFridge colour primitives (1:1 names, slate values) | - |
| `.../SharedUI/DesignTokens/manifest.json` | SharedUI | edit | Add `selffridge-theme` mode under `.primitives` | - |
| `.../SharedUI/GeneratedTokens/*+Generated.swift` | SharedUI | regen | Regenerated output (never hand-edited) | - |
| `.../Model/Services/Theme/ThemeServiceProtocol.swift` | Model | add | Protocol: selected id, set(id), available ids | - |
| `.../Model/.../Theme/ThemeService.swift` | Model | add | UserDefaults-backed impl (provider pattern) | - |
| `Alfie/Alfie/Helpers/StorageKey.swift` | Alfie | edit | Add `selectedTheme` key | - |
| `.../Model/Services/ServiceProviderProtocol.swift` | Model | edit | Expose `themeService` | - |
| `Alfie/Alfie/Service/ServiceProvider.swift` | Alfie | edit | Instantiate `themeService` | - |
| `Alfie/Alfie/Delegate/AppDelegate.swift` | Alfie | edit | Apply theme in `bootstrap()` before first render | - |
| `.../DebugMenu/UI/DebugMenuView.swift` | DebugMenu | edit | `.theme` nav case + row + destination | - |
| `.../DebugMenu/UI/Theme/ThemePickerView.swift` + `ViewModel` | DebugMenu | add | Picker view + view model (protocol) | - |
| `.../DebugMenu/UI/DebugMenuViewModel.swift` | DebugMenu | edit | Inject `themeService` + apply closure | - |
| `.../AccessibilityIdentifiers/AccessibilityID.swift` | AccessibilityIdentifiers | edit | IDs for theme row + options | - |

## Feature Flag
n/a (Debug-menu-only tool this iteration).

## Testing Strategy
- **Unit (codegen):** hex parsing; multi-theme emission produces `AppTheme.allCases` + distinct palettes.
- **Unit (Model):** `ThemeService` default, persistence round-trip, unknown-id fallback.
- **Snapshot/UI (optional):** `ThemePickerView` rows + selected state, using `AccessibilityID`.
- Gate each phase on `./Alfie/scripts/verify.sh`.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Computed-var colours cost a `Color` init per access (429 sites) | LOW | `Color` init is cheap; sanity-check build + runtime; palette held as a struct in memory |
| Hand-editing a generated path | MED | Only edit the codegen tool; regenerate via script; review `git diff` of generated output |
| UIKit chrome doesn't refresh on switch (singleton) | MED | Explicitly re-run `DesignSystem.shared.setupAppearance()` before reboot |
| `TokenLoader` last-writer-wins clobbers two primitive modes | MED | Load primitive modes into separate palettes; alfie remains the base for non-colour tokens |
| SharedUI↔Model dependency cycle | LOW | Keep `ThemeService` id-string only in Model; palettes/ids in SharedUI; bridge in app layer |

## Out of Scope
- Settings/Account "Theme" page (later).
- True live hot-swap via `@Environment` migration of the 429 sites.
- The brand-yellow Selfridges variant (not 1:1) — slate values used under the selfFridge name.

## Open Questions
- Theme display names: hardcoded in the app/SharedUI layer ("Alfie"/"Selfridges"), matching existing
  hardcoded Debug-menu strings — L10n deferred (debug-only). (Recommended, assumed.)
- PR base branch confirmed as `ALFMOB-266-integrate-typography-tokens`.
