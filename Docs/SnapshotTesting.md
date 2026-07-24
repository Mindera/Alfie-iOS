# Snapshot Testing

SwiftUI snapshot tests use [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) 1.18.3.
They live **in the AlfieKit module test targets** (not the `AlfieTests` app target) and run as part of
`./Alfie/scripts/verify.sh`.

---

## How it works

**Shared helpers** live in `TestUtils` (which links `SnapshotTesting` and is already a dependency of every
module test target):

| Helper | Purpose |
|---|---|
| `View.embededInContainer()` | Wraps a view in a 393×852 @3x `UIView` |
| `View.embededInFullHeightContainer()` | Same at 393×1500, for long screens |
| `Snapshotting.defaultImage(precision:perceptualPrecision:)` | Image strategy, defaults `0.9` / `0.95`, SRGB |

**Reference images** are committed alongside the tests in `__Snapshots__/<TestFileName>/`.

### Device / OS policy

References are pixel comparisons, so rendering must be comparable between recording and asserting.

- **Pinned to iOS major 26.** `test-for-verification.sh` resolves an iPhone simulator on iOS 26 and runs the
  whole test suite against it. If none exists, it fails with install instructions rather than asserting
  against the wrong OS.
- **Model and iOS minor are free.** Verified: references recorded on iPhone 17 Pro / iOS 26.5 assert green on
  iPhone 17 / iOS 26.4 and on iPhone 16. `perceptualPrecision: 0.95` absorbs anti-aliasing differences.
- Record on **any available iPhone at iOS major 26**.

To change the pinned major, edit `SNAPSHOT_OS_MAJOR` in `Alfie/scripts/test-for-verification.sh` — and
re-record every reference.

### Precision

`0.9` / `0.95` is the suite-wide default. A genuinely noisy test may override explicitly:

```swift
assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(precision: 0.98), record: isRecording)
```

Prefer re-recording over loosening precision. Watch for override drift across the suite in review.

---

## Recording or updating a snapshot

1. Set `isRecording = true` in the test file.
2. Run the test (record mode always *fails* — that's expected; it writes the PNG).
3. **Inspect the produced PNG** before trusting it.
4. Set `isRecording = false`, re-run to confirm it asserts green, and commit the PNG.

`verify.sh` refuses to run if any test is left in record mode — a grep guard fails in <1s with the
offending file:line, so a stray `isRecording = true` cannot land green.

---

## Where the tests live

Snapshot tests live in the AlfieKit module test targets. SPM test targets have no "Target Membership"
setting — every file under `Tests/<Target>/` is automatically a member, so tests cannot silently fall out
of the build.

| Test file | Target | Covers |
|---|---|---|
| `SplashViewSnapshotTests` | `AppFeatureTests` | Startup splash wordmark, placement, background |

The pre-existing suite (Search, CategorySelector, ProductDetails) was removed: those screens are mid
Modern Design Rollout, so their references would churn on every rollout PR. Re-add them per screen once a
design has settled.

### Adding a snapshot test

1. Ensure the module's test target depends on `TestUtils` (most already do).
2. `import TestUtils` and `@testable import <Module>`.
3. Use `embededInContainer()` / `embededInFullHeightContainer()` and `.defaultImage()`.
4. Record → **inspect the PNG** → assert → commit.

## Beware: animated and time-driven views

`precision: 0.9` means 10% of pixels may differ. A small element is well inside that budget, so a snapshot
can pass **even if that element is missing entirely**. This was measured on the splash screen: with
`LoadingSpinner` removed from `SplashView`, the test still passed.

Raising precision is not a free fix — at `precision: 1.0` the same test fails every run, because
`LoadingSpinner` derives its rotation from wall-clock time and lands on a different angle each capture.

So for any view containing animated or time-driven content:

- Treat the snapshot as covering the **static** parts, and say so in a comment on the test.
- Cover the animated component with a unit test instead.
- Don't raise precision to chase it — you trade a blind spot for a flake.
