## Phase 3: Tests, fixtures & optional DRY

### Goal
Update existing tests/fixtures that encode the old `"x.xx CODE"` format, add per-currency converter coverage,
and (optionally) collapse the duplicate SharedUI formatting path.

### Steps

1. **Flip stale string assertions** (file: `AlfieKit/Tests/BFFGraphTests/ProductDetailsConverterTests.swift:212-213`)
   - `XCTAssertEqual(fullPrice, "50.00 GBP")` → `"£50.00"`; `"30.00 GBP"` → `"£30.00"`.
   - Pin the formatter `Locale` if the test asserts exact symbol (the converter uses `.current` → tests may need to set the test process locale, or the assertion should tolerate locale). **Preferred:** assert against `CurrencyFormatter.string(amount:currencyCode:locale:)` with an explicit `en_GB` locale to stay deterministic, OR assert `contains("£")` + value. Decide during impl; keep deterministic.
   - Scan the whole file for any other `" GBP"`/`String(format:` expectations and flip them.

2. **Add converter per-currency cases** (files: `ProductListingConverterTests.swift`, `ProductDetailsConverterTests.swift`)
   - GBP `19.99` → `amount == 1999`, formatted shows `£19.99`.
   - JPY `5000` → `amount == 5000` (0dp, ×1), formatted `¥5,000`.
   - KWD `19.999` → `amount == 19999` (3dp, ×1000).
   - Use the existing `makeResponse(amount:currencyCode:)` helpers (already parameterized — `currencyCode` defaults `GBP`/`AUD`).

3. **Reconcile fixtures** (file: `AlfieKit/Sources/Mocks/Fixtures/Base/Price+Fixture.swift:18-26`)
   - Current default: `currencyCode: "AUD", amount: 123, amountFormatted: "$1.23"` — internally consistent ($1.23 == 123 minor). Leave defaults UNLESS a test now asserts converter-produced formatting against a fixture.
   - Only change fixtures that feed assertions which now expect symbol-formatted output. Do NOT mass-rewrite static mock data (it's not converter output). (Surgical-changes rule.)
   - Check `Product+Mock.swift` hardcoded `amountFormatted` values are only used for previews/non-asserting paths; leave unless a test breaks.

4. **(Optional, DRY) Delegate SharedUI helpers** (file: `AlfieKit/Sources/SharedUI/Components/Price/PriceComponentView.swift:4-22`)
   - The unused `PriceType.formattedDefault/Sale/Range(... currencyCode:)` each call `Double.formatted(.currency)` independently.
   - Refactor to delegate to `CurrencyFormatter.string(amount: Decimal(...), currencyCode:)` → single formatting code path.
   - **Skip if** it expands scope or risks the build — these helpers are currently unused, so this is pure hygiene. Defer to a follow-up if time-boxed.

### Verification
- `./Alfie/scripts/verify.sh` → **✅ FULL VERIFICATION PASSED** (build + all tests).
- Confirm no remaining `String(format: "%.2f %@"` in `Sources/`.

### Estimated Effort
S
