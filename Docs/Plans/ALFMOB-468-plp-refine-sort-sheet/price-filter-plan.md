---
status: completed
ticket: ALFMOB-475 (map) → delivered on ALFMOB-468 / PR #103
complexity: high
---

> **Done.** All 9 phases landed; `verify.sh --skip-integration` passes. Deviations and findings
> recorded at the bottom under "Outcome".

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

---

## Outcome

### Calls made during implementation
- **Remove All when nothing is filtered** — hidden, not disabled (ALFMOB-486 left this open).
  Present on both the panel and sub-screen headers per Figma, with distinct accessibility ids
  since both sit in the hierarchy while a sub-screen is pushed.
- **Price row on the search-driven PLP** — hidden. `categoryPriceRange` is keyed by collection
  handle, so search has no bounds; 477's no-dead-ends rule says no row rather than a dead one.
- **A category whose price range collapses to one whole unit** yields no bounds, so no Price row —
  there is nothing to narrow.

### Correction to ALFMOB-479's premise
479 states "SharedUI has no text input at all today". It does: `ThemedInput`
(`SharedUI/Theme/Inputs/`), used by eight DebugMenu call sites. It is the *legacy*-design input —
legacy `Primitives` palette, focus bar, status-label row — and restyling it would have changed
those screens, so the new `TextInput` was still the right call. The two now coexist; a follow-up
should decide whether `ThemedInput` is retired once the modern design lands more widely.

### Pre-existing failure fixed in passing
Four PLP snapshot baselines were stale: recorded at `81458a4` (main), while `83bf544` / `8f9153c`
on this branch changed the filter-bar height and added the chip row without re-recording. They
failed on the untouched branch too (verified by stashing). Re-recorded after confirming the only
diff is the intended ALFMOB-467 chip row. Note this contradicts ALFMOB-488's "PLP has no snapshot
coverage at all" — it does, added by 467 on this branch.

### Not verified
The sheet has not been exercised in the simulator — the tool needs device access the user has not
granted. Build, unit tests and snapshots pass; gesture behaviour and the visual states of
`RangeSlider` / `TextInput` are covered by neither unit tests nor snapshots (accepted by 488), so
they remain unverified by anything but `#Preview`.
