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

All snapshot tests have been migrated out of the `AlfieTests` app target into their module test targets.
SPM test targets have no "Target Membership" setting — every file under `Tests/<Target>/` is automatically
a member, so tests can no longer silently fall out of the build.

| Test file | Target | `@testable import` | Tests |
|---|---|---|---|
| `SearchViewSnapshotTests` | `SearchTests` | `Search` | 2 |
| `RecentSearchesSnapshotTests` | `SearchTests` | `Search` | 3 |
| `BrandsViewSnapshotTests` | `CategorySelectorTests` | `CategorySelector` | 3 |
| `CategoriesViewSnapshotTests` | `CategorySelectorTests` | `CategorySelector` | 3 |
| `ShopViewSnapshotTests` | `CategorySelectorTests` | `CategorySelector` | 8 |
| `ProductDetailsViewSnapshotTests` | `ProductDetailsTests` | `ProductDetails` | 7 |
| `ProductDetailsColorSheetSnapshotTests` | `ProductDetailsTests` | `ProductDetails` | 1 |

**27 snapshot tests, 27 committed reference images.** The `membershipExceptions` set that used to exclude
them from `AlfieTests` has been removed from `project.pbxproj`, along with the empty `AlfieTests/Snapshots/`
folder.

### Adding a snapshot test to a new module

1. Ensure the module's test target depends on `TestUtils` (most already do).
2. `import TestUtils` and `@testable import <Module>`.
3. Use `embededInContainer()` / `embededInFullHeightContainer()` and `.defaultImage()`.
4. Record → inspect → assert → commit the PNGs.

### API drift encountered during migration

These tests predated several refactors. For reference, what the migration had to fix:

- **`ColorSwatch` gained a required `id:`** — `ColorSwatch(id: "red", name: "Red", type: .color(.red))`.
- **`ProductDetailsColorSheet` was renamed to `ProductDetailsColorAndSizeSheet`** and gained a `type:`
  parameter (`.color` / `.size`), since one component now serves both sheets.
- **`ShopView.init` gained `isRoot`, `isWishlistEnabled`, `activeShopTabPublisher` and `navigate`.** The test
  uses a private `makeSut(initialTab:)` factory so the six construction sites stay readable.
- The Search pair needed only the import swap.
