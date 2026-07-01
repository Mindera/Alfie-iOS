## Phase 3: Debug-menu picker UI

### Goal
A "Theme" screen in the Debug menu lists available themes, shows the current selection, and switches
the app theme end-to-end.

### Acceptance criteria
- [ ] Debug menu has a "Theme" row that pushes a picker screen.
- [ ] The picker lists `AppTheme.allCases` with display names and marks the current theme.
- [ ] Selecting a theme persists + applies it and the app re-renders (soft-reboot) in the new theme.
- [ ] All interactive elements use `AccessibilityID` constants (no hardcoded locator strings).
- [ ] `./Alfie/scripts/verify.sh` passes.

### Steps
1. **Nav case + row** (file: `.../DebugMenu/UI/DebugMenuView.swift`, size: S) — add `case theme` to
   `DebugNavigation`; `link(for: .theme, text: "Theme")`; `case .theme:` in `navigateTo` building
   `ThemePickerView(...)` wrapped in `ContainerDemoViewModifier(headerTitle: "Theme")`.
2. **Picker VM** (file: `.../DebugMenu/UI/Theme/ThemePickerViewModel.swift`, size: S) — protocol +
   impl: `themes: [AppTheme]` (= `.allCases`), `currentThemeID`, `select(_:)` → calls the injected
   apply closure (from Phase 2). Depends only on Model `ThemeService` + the closure, not AppDelegate.
3. **Picker view** (file: `.../DebugMenu/UI/Theme/ThemePickerView.swift`, size: M) — a `List` of rows
   (display name + checkmark for current), tap → `viewModel.select(theme)`. Follow `FeatureToggleView`
   styling + `theme.font.*` usage.
4. **DI wiring** (file: `.../DebugMenu/UI/DebugMenuViewModel.swift` + `ServiceProvider`/Home flow that
   builds it, size: M) — inject `themeService` + the `applyTheme(id:)` closure into `DebugMenuViewModel`
   so the picker can be constructed (mirror how `apiEndpointService` / `closeMenuAction` are passed).
5. **Accessibility IDs** (file: `.../AccessibilityIdentifiers/AccessibilityID.swift`, size: XS) — add a
   `DebugMenu`/`ThemePicker` enum: `themeRow`, `screen`, and `option(id:)` (derived from theme id, not
   index), per the module's convention.

### Checkpoint
- [ ] `./Alfie/scripts/verify.sh` passes.
- [ ] Acceptance criteria above all met.
- [ ] Manual: Debug → Theme → pick selfFridge → app reboots into slate colours; relaunch keeps it;
      pick Alfie → back to default.

### Depends on
Phase 1, Phase 2
