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

## Migration playbook — remaining files

`SearchTests` was migrated as the pilot. **5 files / 22 tests remain** in `Alfie/AlfieTests/Snapshots/`,
excluded from the app target via `membershipExceptions` in `project.pbxproj` (so they do not currently
compile or run).

| File | Destination target | `@testable import` | Tests |
|---|---|---|---|
| `BrandsViewSnapshotTests.swift` | `CategorySelectorTests` | `CategorySelector` | 3 |
| `CategoriesViewSnapshotTests.swift` | `CategorySelectorTests` | `CategorySelector` | 3 |
| `ShopViewSnapshotTests.swift` | `CategorySelectorTests` | `CategorySelector` | 8 |
| `ProductDetailsViewSnapshotTests.swift` | `ProductDetailsTests` | `ProductDetails` | 7 |
| `ProductDetailsColorSheetSnapshotTests.swift` | `ProductDetailsTests` | `ProductDetails` | 1 |

Both destination targets already depend on their module + `Mocks` + `TestUtils`, so **no `Package.swift`
change is expected**.

### Per file

1. `git mv` the file into `Alfie/AlfieKit/Tests/<Target>/`.
2. Replace `@testable import Alfie` with `@testable import <Module>`, add `import TestUtils`, and delete the
   stale `// TODO: Re-add Target Memebership …` comment.
3. Build. Fix API drift (below).
4. Record → inspect → assert → commit the `__Snapshots__/` PNGs.
5. Run `./Alfie/scripts/verify.sh --skip-integration` and confirm green.

### Known API drift

The pilot needed **only the import swap** — but it was the simplest module. Expect these:

- **`ColorSwatch` now requires `id:`** — `ColorSwatch(id: "red", name: "Red", type: .color(.red))`.
  Affects both ProductDetails files.
- **Constructor drift generally** — these tests predate several refactors; check each SUT's current
  initializer rather than assuming (e.g. `ProductDetailsView(viewModel:showFailureState:)`).
- **`import OrderedCollections`** (Brands, Shop) and **`import Model`** resolve transitively today. If a
  build fails on them, add the explicit dependency to the test target:
  `.product(name: "OrderedCollections", package: "swift-collections")`.
- `ShopViewSnapshotTests` uses `MockWebViewModel` (present in `Mocks`) — its generic signature is the widest
  of the set, so expect this file to need the most attention.

### Estimate

- Categories / Brands (3 tests each): small, likely import-swap only.
- ProductDetailsColorSheet (1 test): small, plus the `ColorSwatch(id:)` fix.
- ProductDetailsView (7 tests): medium — `ColorSwatch(id:)` plus possible constructor drift.
- ShopView (8 tests): largest — three generic parameters and the most mock setup.

Roughly one session per module (CategorySelector, ProductDetails).

### Final cleanup — after all files have moved

`project.pbxproj` still lists every snapshot file in `membershipExceptions`. Entries for already-moved files
are **stale no-ops** (the app target builds fine with them present). Once all 5 remaining files have moved,
remove the whole exception set in one deliberate change — note that `CLAUDE.md` forbids editing
`project.pbxproj` directly, so do it through Xcode.
