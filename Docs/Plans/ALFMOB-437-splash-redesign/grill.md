# Grill: Modern Design Rollout — Startup / Splash screen
**Plan**: Docs/Plans/ALFMOB-437-splash-redesign/plan.md   **Ticket**: ALFMOB-437   **Date**: 2026-07-14   **Branch**: feat/ALFMOB-437-splash-redesign

## Decisions
| # | Decision | Recommended | Chosen | Plan change |
|---|---|---|---|---|
| 1 | How to produce the MINDERA/ALFIE wordmark | Export vector asset | Export vector asset | Open Q1 resolved; Phase 1 Step 1 confirmed (add `ThemedImage.splashLogo`) |
| 2 | Where the static 24pt spinner lives | New SharedUI component | New SharedUI `ThemedSpinnerView` | Open Q2 resolved; Phase 1 Step 2 confirmed |

## Answered by the codebase / memory (not asked)
- Snapshot AC cannot be met literally — snapshot suite is out of target membership repo-wide, no
  committed refs (project memory `snapshot-suite-disabled`). Substitute an SPM unit test. → AC3/Risks.
- Spinner stroke colour + arc fraction — tuning detail resolvable against the Figma screenshot in
  execute; use a neutral token. Not a user decision.
- No feature flag — app unreleased, redesign rolls out directly (ticket).
- `.loading` is startup-specific; swapping its view content doesn't affect other loading surfaces
  (`AppFeatureView.view(for:)`, scope.md).

## Assumptions surfaced
- The redesigned splash differs from the native `LaunchScreen.storyboard` (which shows "ALFIE"
  only). That native launch chrome is explicitly out of scope; the two will look different by design.
- The wordmark asset is treated as brand imagery, so it does not itself consume typography tokens —
  AC2 ("no bespoke typography") still holds because bg/spacing/spinner use tokens.

## Still open (owner)
- None blocking. Exact spinner stroke token/arc will be finalised visually during execute.
