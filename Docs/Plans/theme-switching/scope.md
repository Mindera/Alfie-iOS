# Scope — Theme Switching

Synthesized from brainstorm + 4 parallel research agents + direct verification reads
(not a fresh ios-scout; findings below carry file:line anchors).

## Goal
Add a second design-token colour theme ("selfFridge", values = validated 1:1 slate tokens) and let
the user switch themes at runtime (soft-reboot), persisted across launches, from a Debug-menu entry.

## Design-token pipeline (the core of the change)
- **Codegen tool (editable):** `Tools/DesignTokenGen/` — Swift package.
  - `Sources/DesignTokenGenCore/TokenLoader.swift` — reads `manifest.json`, flattens DTCG files to a
    `name → Token` map (last-writer-wins across modes). `parseValue(type:"color")` only accepts
    `{components:[…]}` (+ optional `alpha`) — **no hex support** (`TokenLoader.swift` ~line 120).
    `modeForCollection` pins only `system→ios`, `screen-size→small-(s)`.
  - `Sources/DesignTokenGenCore/Emitter.swift` — emits 4 files. `emitPrimitives()` groups by first
    name segment and writes `public static let <id> = <literal>` for each (colours as
    `Color(.sRGB, …)`). `emitTheme()` writes semantic tokens as `static let` refs to `Primitives.*`.
  - `main.swift` CLI; run via `./Alfie/scripts/generate-design-tokens.sh` (regenerates into
    `SharedUI/GeneratedTokens/`). `pull-design-tokens.sh` fetches JSON from the design-tokens repo.
- **Token source:** `Alfie/AlfieKit/Sources/SharedUI/DesignTokens/`
  - `manifest.json` — collections→modes. `.primitives`, `theme`, `sizing`, `typography` each have a
    single `alfie-theme` mode today.
  - `.primitives.alfie-theme.tokens.json` (27 colours as components) · `theme.alfie-theme.tokens.json`
    (31 semantic refs) · `sizing.*` · `typography.*`.
- **Generated output (DO NOT hand-edit — generated_paths):**
  `SharedUI/GeneratedTokens/{Primitives,Theme,Sizing,Typography}+Generated.swift`.
  - `Primitives.Colours.*` = `static let` Color literals (computed once, cached).
  - `Theme.*` = `static let` referencing `Primitives.Colours.*` (auto-follows a primitive swap).

## Second theme input
- Source values: `~/Downloads/theme.slate-theme.tokens.json` — verified **1:1** with Alfie:
  exactly 58 keys, identical names, 0 extra/missing. Only colour VALUES differ (cool blue-grey
  neutrals; crimson error; emerald success). Uses **hex strings** (`"#F5F6F8"`, `"#FFFFFF00"`).
  Two semantic tokens (`button-destructive-background/stroke-destructive-default`) reference
  `{colours-semantic-error-600}` directly vs Alfie's `{surface-background-destructive}` — resolves to
  the same colour; normalize to match Alfie so the semantic layer stays theme-independent.

## Colour consumption (why only Primitives must vary)
- ~429 direct `Primitives.Colours.*` sites + `DesignSystem.shared.color` (ColorProvider forwards to
  Primitives). Semantic `Theme.*` also forwards to Primitives. So swapping the active **primitive
  palette** reskins everything with zero call-site edits.
- `SharedUI/Theme/DesignSystem.swift` — `DesignSystem.shared` singleton; `color/spacing/radius` are
  fixed `let` forwarders, `font` is the only swappable provider. `@Environment(\.theme)` seam exists
  but is shadowed by the `View.theme` convenience (unused) — do NOT rely on it for this feature.
  `setupAppearance()` sets UIKit chrome (nav/tab/bar-button) from `Primitives.Colours.*` — re-runs on
  reboot, so it auto-follows.

## Switch mechanism (soft-reboot)
- `Alfie/Alfie/Delegate/AppDelegate.swift:44 rebootApp()` — resets services, re-bootstraps, bumps
  `AppState.shared.sessionID` to rebuild the SwiftUI tree. Already used for config/feature-flag
  changes. Setting the active palette + calling `rebootApp()` re-renders the whole app in the new
  theme. **Requirement:** `Primitives.Colours.*` must read from a mutable holder (computed `var`),
  not `static let`, or the cached literals won't change.

## Persistence + DI
- `Model/Services/Persistence/UserDefaultsProtocol.swift` — `set/value/remove<T>(for:)`.
- Provider pattern to mimic: `ProductListing/Models/ProductListingStyleProvider.swift`
  (reads at init from UserDefaults, `set(_:)` writes + updates in-memory).
- `Model/Services/ServiceProviderProtocol.swift` + `Alfie/Alfie/Service/ServiceProvider.swift`
  (`init()` builds all services; created in `AppDelegate.bootstrap()`).
- Storage keys: `Alfie/Alfie/Helpers/StorageKey.swift` (enum: rawValue keys).
- Launch: `Alfie/Alfie/AlfieApp.swift` (@main) builds `AppFeatureViewModel(serviceProvider:)` lazily;
  `AppDelegate.bootstrap()` runs before UI. Read persisted theme early → set active palette before
  first render.

## Debug menu (entry point)
- `Alfie/AlfieKit/Sources/DebugMenu/UI/DebugMenuView.swift` — SwiftUI `List`; `DebugNavigation`
  enum + `link(for:text:)` rows; destination built in a `switch`. Feature-Toggle row is the closest
  pattern to copy for a simple picker. Reached from Home toolbar (`Home/Toolbar/Home+Toolbar.swift`).
- Needs an `AccessibilityID` (AccessibilityIdentifiers module) for the new row + picker (UI-test rule).

## Out of scope (this iteration)
- Settings/Account "Theme" page (later).
- True live hot-swap via `@Environment` migration of ~429 sites.
- Brand-yellow Selfridges variant (not 1:1); slate values used under the selfFridge name.
- Filling missing Selfridges shade steps (N/A — slate is complete).

## Key risks
- Codegen change touches a generated_path output — must regenerate via script, never hand-edit.
- Making `Primitives.Colours` computed `var` could have perf implications at 429 call sites (Color
  struct init per access) — validate build + basic runtime; consider caching the active palette.
- `TokenLoader` last-writer-wins means two primitive modes would clobber — codegen must load themes
  into separate palettes, not merge.
