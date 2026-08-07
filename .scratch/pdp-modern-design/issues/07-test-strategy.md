# Decide how ALFMOB-441 is verified, given the snapshot AC

Type: grilling
Status: resolved
Blocked by: 02

## Question

The ticket's AC says "Snapshot baselines regenerated and passing" — but PDP has **no snapshot tests today**. `Tests/ProductDetailsTests/` holds exactly one file, `ProductDetailsViewModelTests.swift` (~60 tests, view-model only). There are no baselines to regenerate.

Decide what "verified" actually means here:

- **Do we add the first PDP snapshot tests, or satisfy the AC another way?** The harness exists and needs no `Package.swift` change (`ProductDetailsTests` already depends on `TestUtils`, which links `SnapshotTesting`); `HomeTests/HomeViewSnapshotTests.swift` and `AppFeatureTests/SplashViewSnapshotTests.swift` are the templates, with `embededInFullHeightContainer()` (393×1500) the right container for a screen this long. But snapshot suites have historically been unreliable in this repo — confirm the current state before committing the AC to them.
- **The alternative pattern**: PLP shipped a pure style unit test instead (`ProductListingListStyleSelectorStyleTests.swift`, 29 lines) asserting an icon-for-state mapping with no rendering. Is that the better fit for the size-grid and colour-chip states?
- **What is snapshottable at all.** `ProductDetailsView` has a `showFailureState` init flag explicitly "created for snapshot purposes" (`:57`), and the iPhone path renders through a `.sheet` that a hosting controller will not capture. Ticket 02's outcome decides whether this stops being a problem — read its resolution first.
- **Whether the AC on ALFMOB-441 should be amended** rather than met as written.

Also settle the regression story for "No regression in PDP behaviour or navigation": which of the ~60 existing view-model tests must still pass untouched, and whether `AlfieUITests/Pages/ProductDetailsPage.swift` needs new `AccessibilityID.ProductDetails` entries (there is no `.screen` ID today, unlike PLP).

## Answer

**Both: XCTest style/unit tests for the state-to-appearance logic, plus snapshot tests as a layout regression net.**

### The facts that settle it

- **Snapshot references are committed and the suite genuinely runs.** Earlier notes claiming otherwise were stale. Verified this session: `./Alfie/scripts/test-for-verification.sh --filter HomeTests/HomeViewSnapshotTests` executed 3 tests against committed references on iOS 26, all passing. The harness landed in `c581f46`.
- **`ProductDetailsTests` needs no `Package.swift` change** — it already depends on `TestUtils`, which links `SnapshotTesting`. SwiftPM auto-discovers `Tests/ProductDetailsTests/**`.
- **Deleting the sheet ([ticket 02](02-inline-cta-layout.md)) is what makes this possible.** Today the interesting content renders inside a `.sheet`, which a hosting controller never captures.

### Two harness caveats the spec must carry

1. **Snapshots are pinned to an iOS major and skipped silently otherwise.** `test-for-verification.sh` sets `SNAPSHOT_OS_MAJOR=26`, resolves an iPhone on that runtime, and if none exists **falls back to the newest iPhone and skips every snapshot class** — discovered automatically by grepping for `assertSnapshot(`. A machine without an iOS 26 simulator gets a green `verify.sh` that asserted no snapshots at all. New PDP suites are picked up automatically, and so is the skip.
2. **PDP fixtures are empty where the redesign adds content.** `Brand.fixture(name: "")`, `Colour.fixture(name: "")`, `Variant.fixture(sku: UUID())`, and `MockProductDetailsViewModel` has no colour/SKU property. A naive snapshot would bake in blank brand and meta lines. Fixture work is a prerequisite, not an afterthought — see [ticket 06](06-description-meta-data.md).

### What to write

**Style unit tests** (the PLP pattern — `ProductListingListStyleSelectorStyleTests.swift`, 29 lines, no rendering). These carry the real assertions:

- `SizingSwatchView` state to appearance: available / selected / out-of-stock / unavailable — including that **selection is a border, not a fill**, which is a behavioural change to the swatch.
- Size layout selection: chip grid vs `.verticalList` at the size-count threshold.
- Colour layout selection: `+N` summary vs inline grid vs sheet.
- Low-stock string mapping: `available == 1` to "Only 1 item left!", `<= N` to "Last units".
- The out-of-stock bell and `Size Guide` link are **non-interactive** — assert no tap target / no accessibility action, so the inert treatment can't regress into a dead button.

**Snapshot tests** — deliberately few, to keep baseline maintenance cheap:

- One default-state full screen (`embededInFullHeightContainer()`, 393x1500 — PDP is long).
- One error state, reusing the existing `showFailureState` init flag (`ProductDetailsView.swift:57`, already "created for snapshot purposes").

**Regression:** all ~60 existing `ProductDetailsViewModelTests` must pass untouched, except `test_color_selection_swatch_is_black_by_default_for_invalid_swatch_urls`, which changes with the `Theme.*` migration of the fallback at `ProductDetailsViewModel.swift:311`.

**UI tests:** `AccessibilityID.ProductDetails` has 8 IDs and no `.screen` (unlike PLP). Add `.screen` plus IDs for the new elements, and resolve the naming collision where `titleHeader` renders `productName` under `AccessibilityID.ProductDetails.productTitle` while `productTitle` on the view model is the *brand*.

### The AC needs amending

ALFMOB-441 says "Snapshot baselines **regenerated** and passing". There are none to regenerate. Amend to "Snapshot baselines **added** and passing, plus unit tests covering size/colour state mapping" — and note in the Jira comment that CI must run on an iOS 26 simulator or the snapshot half is silently skipped.
