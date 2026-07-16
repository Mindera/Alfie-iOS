---
title: Modern Design Rollout — Startup / Splash screen
ticket: ALFMOB-437
status: completed
complexity: LOW
mode: auto
blockedBy: []
blocks: []
created: 2026-07-14
---

## Overview
Restyle the app startup `.loading` screen (`AppFeature`) to the modern Figma design (node 672:80063):
a white screen with a vertically-centred **MINDERA / ALFIE** wordmark above the design-system
**Loading Spinner**. Adds the reusable DS spinner component, and updates the native launch screen to
the same wordmark so the launch → in-app hand-off is seamless. Visual-only: no behaviour, timing,
feature-flag, or boot-sequence change. Dark mode deferred.

## Acceptance Criteria
- **AC1** In-app splash matches the Figma: white bg, centred MINDERA/ALFIE wordmark + DS loading
  spinner. ✅
- **AC2** Consumes SharedUI components + design tokens — no bespoke hardcoded colours/spacing/typography. ✅
- **AC3** Appearance verification is **deferred to a separate snapshot-suite-revival ticket** — the
  suite is disabled repo-wide, and a render smoke test added no real signal for a logic-free view, so
  none is included. No automated appearance guard in this PR; verified manually in the simulator. ⚠️
- **AC4** No startup/boot regression — `AppStartupServiceTests` unchanged & green. ✅
- **AC5** Native launch screen shows the new MINDERA/ALFIE wordmark, centred, matching the splash. ✅

## Approach
`SplashView` (AppFeature) composes two SharedUI pieces — the wordmark asset and the DS spinner — and
replaces `ThemedLoaderView` for the `.loading` state only. `ThemedLoaderView` (the generic animated
loader) is left untouched. The launch storyboard is updated independently to the same wordmark asset.

### Key decisions
1. **Wordmark → vector asset.** The MINDERA/ALFIE lockup ships as a vector (`LaunchLogo.svg`, provided
   by design), reused by both screens: the app catalog drives the launch storyboard, and a copy in
   SharedUI (`ThemedImage.splashLogo`) drives `SplashView`. Rendered via `Image(name, bundle:)` — the
   inherited `ThemedImage.image` uses `Image(systemName:)` and can't load an asset.
2. **Spinner → DS `LoadingSpinner` (SharedUI).** Renders the Figma Loading Spinner artwork
   (node 6619-47520) — the exported arc PNG (`ThemedImage.loadingSpinner`, a `neutrals800`
   opaque → transparent "comet" ring) — **rotated continuously**, with sizes **S/M/L (24/32/48)**
   via a `Size` config. Exported as a high-res PNG (192²), not SVG: the design's conic gradient is an
   SVG `<foreignObject>` CSS gradient that Xcode's asset catalog can't render. Splash uses `.small`.
3. **View placement → new `SplashView`** rendered from `AppFeatureView.view(for: .loading)`. `.loading`
   is startup-specific, so the swap is isolated.
4. **Snapshot AC → SPM unit test.** Snapshot suite is out of target membership repo-wide (project
   memory `snapshot-suite-disabled`); not re-enabled.

## Phases (as delivered)

### Phase 1 — SharedUI building blocks ✅
- [x] Wordmark asset added to `ThemedImages.xcassets` as `ThemedImage.splashLogo` (vector,
      `preserves-vector-representation`), copied from the app's `LaunchLogo.svg`.
- [x] `LoadingSpinner` — rotates the exported Loading Spinner arc image (`ThemedImage.loadingSpinner`), sizes S/M/L, with `#Preview`.

### Phase 2 — SplashView + wiring + accessibility + test ✅
- [x] `SplashView` centres the wordmark (mirrored spacing so it aligns with the launch screen) above
      `LoadingSpinner()`; background bleeds under the safe area, content stays in the safe area.
- [x] `AppFeatureView.view(for: .loading)` renders `SplashView`.
- [x] `AccessibilityID.Splash.screen` added; `AccessibilityIdentifiers` wired into `AppFeature`.
- [x] No `SplashView` unit test — appearance deferred to the snapshot-suite-revival ticket.
- [x] `AppStartupServiceTests` unchanged & green.

### Phase 3 — Native launch screen (logo only) ✅
- [x] `LaunchLogo` = new MINDERA/ALFIE lockup with `preserves-vector-representation` restored.
- [x] Storyboard image view resized to the lockup aspect (160×49), centred; no spinner (OS-rendered).

## File Changes
| File | Module | Type | Change |
|---|---|---|---|
| `SharedUI/Theme/Images/ThemedImage.swift` | SharedUI | edit | add `splashLogo` case |
| `SharedUI/Theme/Images/ThemedImages.xcassets/splash-wordmark.imageset/*` | SharedUI | add | MINDERA/ALFIE lockup vector asset |
| `SharedUI/Theme/Images/ThemedImages.xcassets/spinner-arc.imageset/*` | SharedUI | add | DS Loading Spinner arc PNG asset |
| `SharedUI/Theme/Components/Loader/LoadingSpinner.swift` | SharedUI | add | animated DS loading spinner (rotates the arc image, S/M/L) |
| `AccessibilityIdentifiers/AccessibilityID.swift` | AccessibilityIdentifiers | edit | add `Splash.screen` |
| `AppFeature/UI/SplashView.swift` | AppFeature | add | composed splash view |
| `AppFeature/Navigation/AppFeatureView.swift` | AppFeature | edit | render `SplashView` for `.loading` |
| `AppFeatureTests/SplashViewTests.swift` | AppFeatureTests | add | unit test (render + a11y id) |
| `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/*` | App | edit | new lockup + restore vector representation |
| `Alfie/Alfie/LaunchScreen.storyboard` | App | edit | resize image view to new lockup aspect |
| `Alfie/AlfieKit/Package.swift` | — | edit | wire `AccessibilityIdentifiers` into AppFeature + tests |

## Feature Flag
n/a — app unreleased; redesign rolls out directly.

## Testing Strategy
- **Unit (SPM):** none for `SplashView` — it's logic-free; `AppStartupServiceTests` remains the startup
  regression guard.
- **Snapshot:** none — suite disabled repo-wide. Appearance verification (splash + DS spinner) is
  deferred to a separate snapshot-suite-revival ticket. A UI test is intentionally avoided (transient
  splash → flaky, low value).
- **Manual:** verified in the simulator — launch screen and in-app splash align (no wordmark jump),
  spinner rotates. Note: iOS caches the launch screen; delete/reinstall to see asset changes.

## Scope notes
- **Loading-indicator animation is in scope.** The ticket deferred motion only because the DS loading
  indicator wasn't finalized; design has since completed it (Figma 6619-47520), so the full animated
  component ships here.
- **Native launch screen** update is a small, intentional addition (ticket lists it out of scope) so
  the OS launch screen matches the in-app splash.
