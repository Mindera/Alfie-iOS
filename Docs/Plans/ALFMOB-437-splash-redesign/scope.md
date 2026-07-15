# Scout Report: Startup / Splash screen (ALFMOB-437)

**Branch**: feat/ALFMOB-437-splash-redesign   **Agents**: 2

## Key finding
There is **no bespoke splash view** in `AppFeature`. The startup `.loading` state renders the
shared `ThemedLoaderView` (SharedUI) — an **animated `spin.gif` spinner only, no wordmark**.
The ticket wants a centred **MINDERA/ALFIE wordmark + static loading indicator + background**.

## Relevant Files
### App target (AppFeature)
- `Alfie/AlfieKit/Sources/AppFeature/Navigation/AppFeatureView.swift:22-40` — `view(for:)` maps startup screens; `.loading` → `ThemedLoaderView(labelHidden: true, labelTitle: L10n.Loading.title)` at line 25; `.animation(.emphasized, value:)` at 14.
- `Alfie/AlfieKit/Sources/AppFeature/Models/AppStartupScreen.swift:3` — `enum AppStartupScreen { case loading, forceUpdate, error, landing }`.
- `Alfie/AlfieKit/Sources/AppFeature/Navigation/AppFeatureViewModel.swift:21` — `currentScreen: AppStartupScreen = .loading`; clears after `startupCompletionDelay = 2s` (lines 49, 172-174).
- `Alfie/AlfieKit/Sources/AppFeature/Protocols/AppFeatureViewModelProtocol.swift:7` — exposes `currentScreen`.

### SharedUI (design system)
- `SharedUI/Theme/Components/Loader/ThemedLoaderView.swift:3` — current splash content. `VStack(spacing: Primitives.Spacing.spacing12)`; `AnimatedGifImage("spin")` at 100×100, `animationTime 0.85`; optional label `Text.build(theme.font.body.medium(...))` + `Primitives.Colours.neutrals900`; no background set. **Already uses tokens** except `logoSize=100`, `animationTime`, `"spin"` literal.
- `SharedUI/Theme/Components/Loader/LoaderView.swift:3` — alt dots-animation loader (`style: .dark/.light`).
- `SharedUI/Theme/Images/ThemedImage.swift:4` — `enum ThemedImage`, single case `.logoBackground = "logo-ht-l"` → `.image`. Asset in `ThemedImages.xcassets`. **No MINDERA/ALFIE wordmark asset exists in SharedUI.**
- `SharedUI/Theme/Components/Toolbar/ThemedToolbarTitle.swift:30` — `.logo` style renders app-level `Image("Logo")` at 100×23.2.

### Tokens / typography (how callers reference)
- Colour: `theme.color.neutrals0` (white bg), `theme.color.neutrals900`, `theme.color.transparent`; semantic `Theme.surfaceBackgroundPrimary`.
- Spacing: `theme.spacing.space0…space1000` (e.g. `space200`=16, `space400`=32).
- Radius: `theme.radius.soft/strong/rounded`. Sizing: `Sizing.iconsIconSmall/Medium/Large/Xlarge`.
- Typography: `theme.font.display/heading/body/label/link.*`; applied via `Text.build(theme.font.<group>.<style>("…"))`. Figma-named `Typography.*` also generated. Fonts: LibreBaskerville + SF Pro Display.
- Icons: `Icon` enum (SF Symbols). No spinner icon.

### Tests
- `Alfie/AlfieKit/Tests/AppFeatureTests/AppStartupServiceTests.swift` — **plain XCTest**, covers VM state machine only (`test_initial_screen_is_loading`, etc.). **No snapshot tests anywhere.**

## Patterns Observed
- State machine via `@Published currentScreen` + `OrderedDictionary` conditions; view switch in `AppFeatureView.view(for:)`.
- Design tokens accessed through `theme` (`DesignSystem.shared` / `@Environment(\.theme)`).

## Figma design spec (node 672:80063)
White screen; a single vertically+horizontally **centred** column:
1. **MINDERA / ALFIE wordmark** — two-line lockup: "MINDERA" (bold) over "ALFIE" (spaced caps).
   Vector art in Figma; laid out ~160×49 (natural 215×66).
2. gap **16pt** (`spacing/spacing-s` = 16).
3. **Loading Spinner** — Size=Small, **24×24**, a static circular arc/ellipse (partial ring).
   References Alfie Design-System component (node 6619-47283). Static — no animation.
Tokens referenced by the frame: bg `Colours/Neutrals/Neutrals-0 (White)` #ffffff → `theme.color.neutrals0`;
`spacing/spacing-s` 16 → `theme.spacing.space200`; content/black `#111111`.
(Status bar + home indicator are device chrome, not app UI.)

## Asset reality check
- `Alfie/Alfie/Assets.xcassets/Logo.imageset/Logo.png` (1200×278) = **"ALFIE" only**.
- `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/LaunchLogo.svg` (vector, native LaunchScreen) = **"ALFIE" only**.
- `SharedUI/.../ThemedImages.xcassets/logo-ht-l` (31×34) = tiny colour hexagon mark (Mindera glyph).
- **No combined MINDERA+ALFIE lockup asset exists.** → must add one (export from Figma) OR reconstruct with typography.
- Native `Alfie/Alfie/LaunchScreen.storyboard` shows `LaunchLogo` centred on white — out of scope (pre-app launch chrome), but note the two splashes differ visually.
- No existing 24pt static arc spinner in SharedUI (`ThemedLoaderView` = 100pt animated GIF; `LoaderView` = dots).

## Unresolved Questions (for planning / grill)
1. **Figma fidelity** — need the exact node-672-80063 layout: is the MINDERA/ALFIE "wordmark" an image asset or text set in typography tokens? Background colour? Indicator placement/size? (pull Figma next.)
2. **Wordmark asset** — none in SharedUI. Does foundations (ALFMOB-264/426) ship one, or is app-level `Image("Logo")` the wordmark? May need a new asset or text.
3. **Static indicator** — current loader is an animated GIF; ticket wants static. Replace GIF with a static styled indicator (which token/shape?).
4. **Snapshot AC** — snapshot suite is disabled repo-wide (no committed refs); "regenerate baselines" AC cannot be met literally → substitute SPM unit test(s) on the new view. Flag to user.
5. Should the splash be a new dedicated view in `AppFeature` (e.g. `SplashView`) or a restyle of `ThemedLoaderView`? `ThemedLoaderView` is reused elsewhere as a generic loader — a splash-specific view is likely cleaner.
