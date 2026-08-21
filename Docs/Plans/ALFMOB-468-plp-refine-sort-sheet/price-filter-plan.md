---
status: in-progress
ticket: ALFMOB-475 (map) → delivered on ALFMOB-468 / PR #103
complexity: high
---

# PLP Price filter — execution plan (ALFMOB-475 build order)

Source of truth: the ALFMOB-475 wayfinder map + resolution comments on 476, 479, 481,
482, 483, 486, 487, 488. No decisions are re-opened here.

## Standing correctness constraint

`Money.amount` is **minor** units; `ProductFilterInput.minPrice/maxPrice` are **major**
units (`Float` on the wire). One conversion point only — `PriceFilterBounds`. Tested with
JPY (exponent 0) as well as GBP.

## Phases

### 1. `CurrencyFormatter.symbol(for:)` — ALFMOB-481
- `Model/Formatting/CurrencyFormatter.swift`: `symbol(for:locale:)`, memoised like
  `minorUnitDigits(for:)`.
- Test: `ModelTests/CurrencyFormatterTests.swift` — GBP `£`, JPY `¥`, USD `$`, unknown code.

### 2. `TextInput` SharedUI component — ALFMOB-479 #2, ALFMOB-481 #3/#6
- New `SharedUI/Components/TextInput/TextInput.swift`:
  `TextInputConfiguration` + `TextInput: View` + `TextInputStyle` (Chip idiom).
- Currency affix beside a plain numeric field; placeholder; error appearance
  (`Theme.contentContentNegative`); `.numberPad`; a11y id passthrough.
- Test: `SharedUITests/TextInputStyleTests.swift` — border/text/affix colour per state.

### 3. `RangeSlider` — finish the inputs half — ALFMOB-479
- Bindings become `Binding<Double?>`: **nil = unbounded on that side** (ALFMOB-481 #5).
  Thumb falls back to the corresponding bound; empty field ⇒ nil.
- `showInputs` flag gates the paired `TextInput`s (Figma `Show Inputs`).
- Extract `RangeSliderStyle` — pure value logic: fraction/offset geometry, stepping,
  clamping, min-rounds-down / max-rounds-up, collapsed-range tie-break.
- Keep the 44pt touch overlay and the commented Shadow-Sheer literal (no shadow token).
- Test: `SharedUITests/RangeSliderStyleTests.swift`.

### 4. `CategoryPriceRange` GraphQL + codegen + service
- `BFFGraph/CodeGen/Queries/Products/Queries.graphql`: add `CategoryPriceRangeQuery`
  (contract is `minVariantPrice` / `maxVariantPrice`, reusing `MoneyFragment`).
- `./Alfie/scripts/run-apollo-codegen.sh`.
- `ProductServiceProtocol.categoryPriceRange(collectionHandle:) -> PriceRange?`
  + `BFFClientService` impl + converter (reuses `MoneyFragment.toDomainMoney()`).
- `ProductListingServiceProtocol` passthrough + `ProductListingService` + Mock.

### 5. `PriceFilterBounds` + `RefineViewModel` — ALFMOB-476, 481, 486, 487
- `Model/Models/Product/PriceFilterBounds.swift` — **the single minor→major conversion**;
  min floors, max ceils. Test with GBP and JPY (`ModelTests/PriceFilterBoundsTests.swift`).
- `ProductListing/UI/Refine/RefineViewModel.swift` + protocol. Owns pending state:
  `pendingMinPrice: Double?`, `pendingMaxPrice: Double?`, `pendingSort: SortByType?`.
  `isPriceRangeInvalid`, `removeAll()` (filters only — Sort untouched), `filterInput`.
  Seeded from the applied state each time the sheet opens; discarded on dismiss.
- Test: `ProductListingTests/RefineViewModelTests.swift`.

### 6. Refine sheet restructure — ALFMOB-476, 477, 483
- `ProductListingFilter` becomes the sheet root: local `NavigationStack` + private
  `RefineRoute { price, sort }`. `.presentationDetents([.large])`.
- Root rows: **Price** (hidden when bounds are unknown — search PLP is out of scope, and
  477's no-dead-ends rule forbids a row that can't filter) and **Sort**. Page Style
  selector and the "Show results" CTA stay. Header gains **Remove All**.
- Sub-screens `RefinePriceView`, `RefineSortView` with a back chevron; back never commits.
- No count on the CTA (478), no count badges (485).
- `ProductListingViewModel`: fetch bounds once in `viewDidAppear`; `didApplyFilters` takes
  the pending values, sets `filters`/`sortOption` and **nils the cursor**.

### 7. `Z_A` removal + optional sort binding — ALFMOB-482
- Drop `.alphaDesc` from `SortByType` and `SortByHelper.options`; drop the `"Z_A"` arm and
  its TODO from `ProductSort+Converter` (`default:` still yields `.newest`).
- `SortByView.sortBy` → `Binding<SortByType?>`; nil path in `colorForOptionBorder`.
  3 call sites: `ProductListingFilter`, `DemoSortByView`, `#Preview`.
- `ProductSortConverterTests`: rename the `Z_A` case to an unknown-value fallback assertion.
- Keep the `z-circle` asset.

### 8. L10n + AccessibilityID
- New `plp.refine.*` keys in `L10n.xcstrings`; regenerate via
  `swift package --allow-writing-to-package-directory generate-code-for-resources`.
- New ids under `AccessibilityID.ProductListing`.

### 9. Verify
- `./Alfie/scripts/verify.sh`; then `ios-code-review --pending`.

## Test strategy — ALFMOB-488

Unit tests only. No snapshots for the new components, no XCUITest. AccessibilityIDs are
still added. Existing PLP snapshots must stay green (the sheet is not in them).

## Known non-functional UI

The PLP quick-filter chip row stays mocked and filters nothing (ALFMOB-480) — flag to QA.

## Reported token gap

No shadow token for Figma `Shadow-Sheer` (`0 1px 2px rgba(0,0,0,0.05)`) — commented
literal, not a substitute (ALFMOB-479).
