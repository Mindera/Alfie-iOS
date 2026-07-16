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
Restyle the app startup `.loading` screen (`AppFeature`) to match Figma node 672:80063: a white
screen with a vertically + horizontally centred column — a two-line **MINDERA / ALFIE** wordmark
lockup, a 16pt gap, then a small **24×24 static** loading spinner (partial circular arc). Today the
`.loading` state renders the shared animated `ThemedLoaderView` (100pt `spin.gif`, no wordmark).
Visual-only: no behaviour, timing, feature-flag, or boot-sequence change. Dark mode deferred.

## Acceptance Criteria (feature-level)
- **AC1** Splash matches the approved Figma (static layout): white bg, centred MINDERA/ALFIE wordmark
  + 16pt gap + 24pt static spinner. → Phase 2
- **AC2** Screen consumes SharedUI design-system components + tokens; no bespoke hardcoded
  colours/spacing/typography. → Phase 1 + 2
- **AC3** Appearance regression-guarded. Snapshot suite is disabled repo-wide (see Risks) → satisfied
  via an SPM unit test asserting the splash's structure/identifier instead of snapshot baselines. → Phase 2
- **AC4** No regression in startup/boot behaviour — `AppStartupServiceTests` state-machine tests still
  green; only the `.loading` view content changes. → Phase 2
- **AC5** (added) Native launch screen shows the new MINDERA/ALFIE wordmark centred on white, matching
  the in-app splash; no clipping. → Phase 3

## Approach
Add the two design-system building blocks the splash composes (Phase 1), then build a dedicated
`SplashView` in `AppFeature` that composes them and swap it in for the `.loading` case (Phase 2).
Do **not** modify the shared `ThemedLoaderView` — it is a generic loader reused elsewhere; the
splash gets its own view so the animated loader stays available for other screens.

### Resolved design decisions (recommendations — confirm at grill)
1. **Wordmark → vector asset (Option A, recommended).** No MINDERA+ALFIE lockup asset exists
   (`Logo.png`, `LaunchLogo.svg` are "ALFIE" only). Export the lockup from Figma as a
   vector PDF/SVG, add to `SharedUI/.../ThemedImages.xcassets` (`preserves-vector-representation`)
   and a new `ThemedImage` case (e.g. `splashLogo`). Mirrors the existing `logoBackground`/
   `LaunchLogo` asset pattern; guarantees pixel fidelity for a brand logotype.
   *Alternative B — reconstruct with `Text` + typography tokens (MINDERA bold display + ALFIE
   spaced label). Rejected as primary:* risk the DS fonts (LibreBaskerville / SF Pro Display) don't
   match the logotype; a lockup is legitimately imagery, not body copy. Fall back to B only if
   design requires live text.
2. **Spinner → small static SharedUI view (recommended).** Add `ThemedSpinnerView` (or similar) in
   SharedUI: a 24pt `Circle().trim(…).stroke(…, style: rounded)` arc using a design-system stroke
   colour token — **static, no animation** (per Out of Scope). Figma models this as a DS component,
   and AC2 wants SharedUI components, so it lives in SharedUI (tiny, previewable). Size defaults to
   `Sizing.iconsIconMedium` (24). *Rejected: restyling `ThemedLoaderView`* — that's the animated
   generic loader; keep it intact.
3. **View placement → new `SplashView` in `AppFeature`** composing the two DS pieces; render it from
   `AppFeatureView.view(for: .loading)` instead of `ThemedLoaderView`. `.loading` is startup-specific,
   so this swap is isolated.
4. **Snapshot AC → SPM unit test.** Snapshot suite is out of target membership repo-wide with no
   committed refs (project memory: "snapshot-suite-disabled"). Do **not** try to re-enable it. Add a
   plain XCTest in `AppFeatureTests` asserting `SplashView` builds and exposes its accessibility id;
   document the substitution in the PR.

## Phases (vertical, in dependency order)

### Phase 1: SharedUI building blocks (wordmark asset + static spinner)
**Goal:** the two design-system pieces the splash composes exist and build standalone.
**Acceptance criteria**
- [ ] MINDERA/ALFIE lockup asset added to `ThemedImages.xcassets` (vector, `preserves-vector-representation`)
      and exposed via a new `ThemedImage` case; `ThemedImage.<case>.image` returns it.
- [ ] `ThemedSpinnerView` renders a **static** 24pt partial-arc ring using token stroke colour +
      `Sizing`/`theme.spacing` for size; no animation; has a SwiftUI `#Preview`.
- [ ] AC2 (no hardcoded colours/typography) holds for both pieces.
**Steps**
1. **Add wordmark asset + `ThemedImage` case** (file: `SharedUI/Theme/Images/ThemedImage.swift:3`
   + new `ThemedImages.xcassets/splash-wordmark.imageset`, size: S) — source artwork is the
   **user-provided** `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/LaunchLogo.svg` (MINDERA/ALFIE
   lockup, 160×49, `#111111`, transparent). Copy that SVG into the new SharedUI imageset with a
   `Contents.json` (`preserves-vector-representation: true`, mirror `LaunchLogo.imageset`), and add
   `case splashLogo = "splash-wordmark"`. Both screens then use identical artwork. No test (asset).
   *(Supersedes the earlier auto-assembled `assets/splash-wordmark.svg` — discard it.)*
2. **Add `ThemedSpinnerView`** (file: new `SharedUI/Theme/Components/Loader/ThemedSpinnerView.swift`,
   size: XS) — static arc: `Circle().trim(from:0, to:~0.75).stroke(theme.color.<neutral>, style:
   StrokeStyle(lineWidth: …, lineCap: .round))`, framed to a `size` param defaulting to 24
   (`Sizing.iconsIconMedium`). Add `#Preview`. Unit-light (visual); covered by Phase 2 test via SplashView.
**Checkpoint**
- [ ] `./Alfie/scripts/verify.sh --skip-integration` builds green (SharedUI compiles; previews resolve).
- [ ] Acceptance criteria above met.
**Depends on:** none

### Phase 2: SplashView + wiring + accessibility + test
**Goal:** startup `.loading` renders the redesigned splash (wordmark + gap + static spinner) on white.
**Acceptance criteria**
- [ ] `SplashView` composes `ThemedImage.splashLogo.image` + 16pt gap (`theme.spacing.space200`) +
      `ThemedSpinnerView()` in a centred `VStack`, on `theme.color.neutrals0` full-screen background.
- [ ] `AppFeatureView.view(for: .loading)` renders `SplashView` (not `ThemedLoaderView`).
- [ ] Splash root carries an `AccessibilityID` identifier (new `AccessibilityID.Splash.screen`).
- [ ] SPM unit test in `AppFeatureTests` asserts `SplashView` builds & exposes the identifier (AC3).
- [ ] `AppStartupServiceTests` unchanged & green (AC4).
**Steps**
1. **Add `AccessibilityID.Splash`** (file: `AccessibilityIdentifiers/AccessibilityID.swift`, size: XS) —
   `enum Splash { static let screen = "splash.screen" }` (follow existing convention).
2. **Create `SplashView`** (file: new `AppFeature/UI/SplashView.swift`, size: XS) — centred `VStack`
   composing the Phase-1 pieces; background `theme.color.neutrals0`; `.accessibilityIdentifier(AccessibilityID.Splash.screen)`;
   `#Preview`.
3. **Wire into startup** (file: `AppFeature/Navigation/AppFeatureView.swift:25`, size: XS) — replace
   `ThemedLoaderView(labelHidden: true, labelTitle: L10n.Loading.title)` with `SplashView()` in the
   `.loading` branch. Remove the now-unused `L10n.Loading.title` reference here only if orphaned.
4. **Add unit test** (file: new `AppFeatureTests/SplashViewTests.swift`, size: XS) — plain XCTest
   instantiating `SplashView`, asserting it builds; assert the `AccessibilityID.Splash.screen` string.
**Checkpoint**
- [ ] `./Alfie/scripts/verify.sh --skip-integration` → "✅ VERIFICATION PASSED (… integration skipped)".
- [ ] Manual: run app; startup shows centred MINDERA/ALFIE wordmark + static spinner on white.
- [ ] AC1–AC4 met.
**Depends on:** Phase 1

### Phase 3: Native launch screen (LaunchScreen.storyboard) — logo only
**Goal:** the OS launch screen shows the new MINDERA/ALFIE wordmark (matching the in-app splash),
so launch → in-app handoff is visually consistent. Static, no spinner (OS-rendered).
**Acceptance criteria**
- [ ] `LaunchLogo` asset is the new MINDERA/ALFIE lockup (already provided by user) with
      `preserves-vector-representation: true` restored in its `Contents.json`.
- [ ] Storyboard image view sized to the new lockup aspect (~3.27:1, e.g. 160×49), centred on the
      white `LaunchScreenBackground`; `scaleAspectFit`.
- [ ] No spinner on the launch screen (per decision — OS screen is static).
**Steps**
1. **Restore vector representation** (file: `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/Contents.json`,
   size: XS) — re-add `"properties": { "preserves-vector-representation": true }`.
2. **Update storyboard image view** (file: `Alfie/Alfie/LaunchScreen.storyboard`, size: XS) — change the
   `AbB-FK-wl1` imageView frame from 130×30 to the new lockup aspect (keep centerX/centerY, `scaleAspectFit`);
   update the `<image name="LaunchLogo" width height>` resource entry to match.
**Checkpoint**
- [ ] `./Alfie/scripts/verify.sh --skip-integration` green.
- [ ] Manual: cold-launch shows centred MINDERA/ALFIE wordmark on white (no clipping/letterboxing).
**Depends on:** none (independent of Phases 1–2; can land in parallel)

## File Changes (Summary Table)
| File | Module | Type | Change | Owner |
|---|---|---|---|---|
| `SharedUI/Theme/Images/ThemedImage.swift` | SharedUI | edit | add `splashLogo` case | - |
| `SharedUI/Theme/Images/ThemedImages.xcassets/<name>.imageset/*` | SharedUI | add | MINDERA/ALFIE lockup vector asset | - |
| `SharedUI/Theme/Components/Loader/ThemedSpinnerView.swift` | SharedUI | add | static 24pt arc spinner | - |
| `AccessibilityIdentifiers/AccessibilityID.swift` | AccessibilityIdentifiers | edit | add `Splash.screen` | - |
| `AppFeature/UI/SplashView.swift` | AppFeature | add | composed splash view | - |
| `AppFeature/Navigation/AppFeatureView.swift` | AppFeature | edit | render `SplashView` for `.loading` | - |
| `AppFeatureTests/SplashViewTests.swift` | AppFeatureTests | add | unit test (build + a11y id) | - |
| `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/LaunchLogo.svg` | App | (done) | new MINDERA/ALFIE lockup — provided by user | - |
| `Alfie/Alfie/Assets.xcassets/LaunchLogo.imageset/Contents.json` | App | edit | restore `preserves-vector-representation: true` | - |
| `Alfie/Alfie/LaunchScreen.storyboard` | App | edit | resize image view to new lockup aspect | - |

## Feature Flag
n/a — app unreleased; redesign rolls out directly (per ticket).

## Testing Strategy
- **Unit (SPM):** `SplashViewTests` — instantiate `SplashView`, assert build + accessibility id constant.
  Keep `AppStartupServiceTests` untouched (startup state machine regression guard).
- **Snapshot:** none — suite disabled repo-wide (no committed refs); substituted by the unit test above.
- **UI:** none required (visual-only, no new interaction). Accessibility id added for future UI tests.

## Risks & Mitigations
| Risk | Likelihood | Mitigation |
|---|---|---|
| Snapshot AC can't be met literally (suite disabled) | High (known) | Substitute SPM unit test; document in PR; don't re-enable suite |
| Wordmark asset fidelity | Low (resolved) | Lockup SVG assembled from Figma glyph vectors + verified against the Figma screenshot; staged in `assets/splash-wordmark.svg` |
| Spinner arc fraction/stroke doesn't match Figma exactly | Med | Compare to Figma screenshot; tune trim fraction + lineWidth; it's static so no motion mismatch |
| Removing `ThemedLoaderView` at call site affects other startup states | Low | Only `.loading` branch changes; other cases untouched; verify build |

## Out of Scope
DS foundations (ALFMOB-264/426); splash/launch **timing & boot behaviour**; dark mode.
**Loading-indicator animation — now in scope.** The ticket originally deferred motion because the
design-system loading indicator wasn't finalized yet. Design has since completed the DS Loading
Spinner (Figma 6619-47520), so the full animated component is implemented here rather than in a
later story.
**Scope expansion (user-requested, beyond ticket):** the native `LaunchScreen.storyboard` — the ticket
lists it as out of scope, but the user asked to also update it to the new wordmark for launch→in-app
consistency (Phase 3, logo only, no spinner). Called out in the PR.

## Open Questions — RESOLVED (grill 2026-07-14)
1. **Wordmark → export vector asset (Option A).** DECIDED. Export MINDERA/ALFIE lockup from Figma
   node 492:16699 as a vector; add to `ThemedImages.xcassets` + `ThemedImage.splashLogo`.
2. **Spinner → new SharedUI `ThemedSpinnerView`.** DECIDED. Implemented as the full DS Loading
   Spinner component (Figma 6619-47520): angular-gradient "comet" ring (`neutrals800`), sizes
   **S/M/L (24/32/48)**, **continuously rotating**. Splash uses `.small`.
   *(Update 2026-07-16: animation brought forward at the user's request — see scope note below.)*
3. Spinner stroke colour token + arc fraction — implementation detail; tune against the Figma
   screenshot during execute using a neutral token (no user decision needed).
4. Snapshot-AC substitution (SPM unit test) — accepted; forced by disabled snapshot suite
   (project memory `snapshot-suite-disabled`). Documented in AC3 + Risks.
