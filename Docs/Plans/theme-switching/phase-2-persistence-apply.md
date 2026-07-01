## Phase 2: Persistence + apply mechanism

### Goal
The selected theme is persisted and applied app-wide at launch and on change (soft-reboot), driven
by a `ThemeService`. No UI yet — validated via tests + a temporary trigger.

### Acceptance criteria
- [ ] `ThemeService` persists the selected theme id and returns it (default = alfie) across launches.
- [ ] At launch (`AppDelegate.bootstrap`), the persisted theme is applied to `ThemeColours.current`
      before the first render (and re-applied on each reboot).
- [ ] Changing the theme applies the palette, re-runs `DesignSystem.shared.setupAppearance()` (UIKit
      chrome), and triggers `rebootApp()` so the whole UI re-renders in the new theme.
- [ ] `ThemeService` unit tests pass; `./Alfie/scripts/verify.sh` passes.

### Steps
1. **ThemeService protocol** (file: `.../Model/Services/Theme/ThemeServiceProtocol.swift`, size: XS)
   — `var selectedThemeID: String { get }`, `func set(_ id: String)`. (Model stays SharedUI-free.)
2. **ThemeService impl** (file: `.../Model/Services/Theme/ThemeService.swift`, size: S) — UserDefaults
   provider mirroring `ProductListingStyleProvider`: read id at init (fallback to alfie), `set` writes
   + updates in-memory. Test: default, round-trip, fallback on missing/unknown.
3. **Storage key** (file: `Alfie/Alfie/Helpers/StorageKey.swift`, size: XS) — add `selectedTheme`.
4. **DI exposure** (file: `.../Model/Services/ServiceProviderProtocol.swift`, size: XS) — add
   `var themeService: ThemeServiceProtocol { get }`.
5. **DI instantiation** (file: `Alfie/Alfie/Service/ServiceProvider.swift`, size: S) — build
   `ThemeService(userDefaults:)` in `init()`.
6. **Apply at launch** (file: `Alfie/Alfie/Delegate/AppDelegate.swift`, size: S) — in `bootstrap()`,
   after `serviceProvider` is created and before UI, call `ThemeColours.apply(id:
   serviceProvider.themeService.selectedThemeID)`. Since `bootstrap` also runs inside `rebootApp()`,
   this re-applies on reboot automatically.
7. **Apply-on-change action** (file: app layer; e.g. a small helper on `AppDelegate` or a closure the
   composition root vends, size: S) — `applyTheme(id:)` = `themeService.set(id)` +
   `ThemeColours.apply(id:)` + `DesignSystem.shared.setupAppearance()` + `rebootApp()`. This closure
   is what Phase 3 injects into DebugMenu (keeps DebugMenu free of AppDelegate coupling).

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria above all met.
- [ ] Manual (temporary): forcing a non-default id in `set(...)` then relaunch shows selfFridge colours.

### Depends on
Phase 1
