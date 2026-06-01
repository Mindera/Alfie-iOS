## Phase 4: Tests

### Goal
Cover the converter mapping logic and the new fetch/default-variant behaviour. Keep the existing 73
PDP ViewModel tests green after the signature change.

### Steps

1. **Converter tests** (file: `Tests/CoreTests/ServiceTests/ProductDetailsConverterTests.swift` — new)
   - Build `BFFGraphAPI.ProductDetailsFragment` fixtures via generated `Mock` (`BFFGraph/Mocks/`) — do
     not hand-edit mocks, instantiate them.
   - Cases:
     - colour option named `"Color"`, `"colour"`, mixed case → mapped to `Product.Colour`.
     - size option `"Size"` → `Product.ProductSize`.
     - unknown option name (e.g. `"material"`) → colour/size nil, no crash.
     - `defaultVariantId` matches a variant → that variant is `defaultVariant`.
     - `defaultVariantId` nil / not found → first in-stock variant chosen.
     - all variants out of stock → first variant chosen.
     - `inventory.available` → `Variant.stock`; nil → 0.
     - `brandName`/`descriptionHtml` mapped; HTML stripped to plaintext.
     - empty `variants` → synthesised placeholder default variant (no crash).

2. **ProductServiceTests** (file: `Tests/CoreTests/ServiceTests/ProductServiceTests.swift`)
   - Update existing `getProduct` tests to the `handle:platform:` signature.
   - Assert client called with the passed handle/platform (via `MockBFFClientService` closure).
   - Keep `.noProduct` / `.generic` error-mapping cases.
   - **Do NOT** add PDP `ViewErrorType` mapping tests or retry/telemetry tests — `ViewErrorTypeMappingTests`,
     `RetryInterceptorTests`, `BFFErrorReporterTests` (all from 334) already cover those.

3. **ProductDetailsViewModelTests** (file: `Tests/ProductDetailsTests/ProductDetailsViewModelTests.swift`)
   - Update `MockProductService.onGetProductCalled` usages to new signature.
   - Add: on load, default variant pre-selects colour (not size); price/stock reflect selected variant;
     selecting a colour/size swaps the variant and updates price/stock.
   - Confirm `isAddToBagEnabled` logic still holds with converter-produced data.

4. **UITest sanity** (file: `Alfie/AlfieUITests/Pages/ProductDetailsPage.swift`)
   - No locator changes (`colourSelector`/`sizeSelector` AccessibilityIDs unchanged). Confirm any
     launch-arg/mock fixture feeding the PDP still resolves; full integration test = ALFMOB-335.

### Verification
- `./Alfie/scripts/verify.sh` → **"✅ FULL VERIFICATION PASSED"** (build + all tests).
- New converter tests fail first (red) before Phase 2 logic, then pass — confirm the loop.

### Estimated Effort
M
