# Snapshot Testing

SwiftUI snapshot tests use [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) 1.18.3.
They live **in the AlfieKit module test targets** (not the `AlfieTests` app target) and run as part of
`./Alfie/scripts/verify.sh`.

---

## How it works

**Shared helpers** live in `TestUtils` (which links `SnapshotTesting`; add it to a module's test target in
`Package.swift` if that target doesn't already depend on it):

| Helper | Purpose |
|---|---|
| `View.embededInContainer()` | Wraps a view in a 393×852 `UIView` |
| `View.embededInFullHeightContainer()` | Same at 393×1500, for long screens |
| `Snapshotting.defaultImage(precision:perceptualPrecision:)` | Image strategy, defaults `1.0` / `0.95`, SRGB, `displayScale` 3 |

`defaultImage` pins `displayScale` to 3 via the strategy's traits, so rendering is @3x regardless of the host
simulator — the container no longer mutates `UIScreen.main`.

**Reference images** are committed alongside the tests in `__Snapshots__/<TestFileName>/`.

### Device / OS policy

References are pixel comparisons, so rendering must be comparable between recording and asserting.

- **Pinned to an exact iOS version.** `test-for-verification.sh` resolves an iPhone simulator on the
  pinned major.minor and runs the whole test suite against it. If no iPhone on that version exists, it
  falls back to the newest available iPhone with a loud warning and **skips the snapshot classes**
  (discovered as any file calling `assertSnapshot`), so a missing runtime costs snapshot coverage rather
  than blocking every other test.
- **Model is free; the iOS minor is not.** Device model does not matter — the container fixes the size in
  points and `defaultImage` pins `displayScale`, so an iPhone 17 Pro and a Pro Max render identically.
  The iOS **minor** does matter: glyph rasterisation changed between 26.2 and 26.4, drifting ~24 pixels
  per screen past `perceptualPrecision`'s budget — enough to fail `precision: 1.0`. Measured on
  `ProductListingViewSnapshotTests`, where 3 of 6 cases failed on CI purely from that gap.
- Record on **the pinned version**, not merely the pinned major.

`SNAPSHOT_OS_VERSION` (in `Alfie/scripts/test-for-verification.sh`, default `26.4`) pins the exact
iOS **major.minor** references are recorded on, and must stay in lockstep with `SCAN_DEVICE` in
`fastlane/.env.default` so CI asserts on the same runtime. Override per run —
`SNAPSHOT_OS_VERSION=26.5 ./Alfie/scripts/verify.sh` — but changing the pin for good means updating
both places **and** re-recording every reference; overriding without re-recording asserts against the
wrong OS. The `macos-26` runner image ships iOS 26.2, 26.4 and 26.5, so the pin must name one of those.

### Precision

`precision: 1.0` / `perceptualPrecision: 0.95` is the suite-wide default: every pixel must match, so a test
cannot pass with an element missing, while `perceptualPrecision` still absorbs anti-aliasing across devices.
A view with genuinely non-deterministic content (e.g. a time-driven animation) may lower `precision`:

```swift
assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(precision: 0.9), record: isRecording)
```

`SplashViewSnapshotTests` does exactly this — its `LoadingSpinner` rotates off wall-clock time, so it asserts
at `0.9` and covers only the static parts. Reach for an override only when the content is truly
non-deterministic; prefer re-recording over loosening precision to chase a rendering diff.

---

## Recording or updating a snapshot

1. Set `isRecording = true` in the test file.
2. Record the PNG. Either run the single test from Xcode, or run the script with the guard bypassed:
   `SNAPSHOT_ALLOW_RECORD=1 ./Alfie/scripts/verify.sh --skip-integration --filter <TestClass>`
   (record mode always *fails* — that's expected; it writes the PNG).
3. **Inspect the produced PNG** before trusting it.
4. Set `isRecording = false`, re-run to confirm it asserts green, and commit the PNG.

`verify.sh` refuses to run if any test is left in record mode — a grep guard fails in <1s with the
offending file:line, so a stray `isRecording = true` cannot land green. `SNAPSHOT_ALLOW_RECORD=1`
lifts the guard only for the deliberate record run in step 2.

---

## Where the tests live

Snapshot tests live in the AlfieKit module test targets. SPM test targets have no "Target Membership"
setting — every file under `Tests/<Target>/` is automatically a member, so tests cannot silently fall out
of the build.

| Test file | Target | Covers |
|---|---|---|
| `SplashViewSnapshotTests` | `AppFeatureTests` | Startup splash wordmark, placement, background |
| `HomeViewSnapshotTests` | `HomeTests` | Home search bar + hero carousel, with and without banners |
| `ProductDetailsViewSnapshotTests` | `ProductDetailsTests` | PDP colour/size variants, loading, out-of-stock, error |
| `ProductListingViewSnapshotTests` | `ProductListingTests` | PLP grid and list style, both loading states, both error states |

Screens mid Modern Design Rollout are deliberately uncovered — their references would churn on every
rollout PR. Add them per screen once the design settles, covering the full state matrix
(loading / loaded / error / empty), not just the happy path.

### Adding a snapshot test

1. Ensure the module's test target depends on `TestUtils` (most already do).
2. `import TestUtils` and `@testable import <Module>`.
3. Use `embededInContainer()` / `embededInFullHeightContainer()` and `.defaultImage()`.
4. Record → **inspect the PNG** → assert → commit.

## A test target must be in the test plan

Being an SPM test target is not enough — `verify.sh` runs `Alfie.xctestplan`, so a target missing from it
never runs silently. Add every new test target to it.

`BFFIntegrationTests` is deliberately excluded: it has its own `AlfieIntegration.xctestplan`.

## Beware: animated and time-driven views

The suite default is `precision: 1.0`, so a static screen cannot pass with an element missing. But a lower
precision has a sharp edge: any slack big enough to hide an animation's motion is also big enough to hide a
whole small element. Measured on the splash screen at `precision: 0.9`: with `LoadingSpinner` removed from
`SplashView`, the test still passed. And you can't just keep the default `1.0` for such a view — the same
test fails every run at `1.0`, because `LoadingSpinner` derives its rotation from wall-clock time and lands
on a different angle each capture.

So for any view containing animated or time-driven content:

- Lower `precision` on that test only (the suite stays tight at `1.0`), and say in a comment that the
  snapshot covers the **static** parts.
- Cover the animated component with a unit test instead.
- Don't lower precision to chase a *rendering* diff on a static view — re-record instead.
