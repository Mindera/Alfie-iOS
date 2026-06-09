## Phase 2: Converters — route `toDomainMoney()` through `CurrencyFormatter`

### Goal
Replace the naive `String(format:)` + hardcoded `*100` with the Decimal-based path using `CurrencyFormatter`.
Fixes AC1 (display) and AC2 (scaling).

### Steps

1. **Rewrite `toDomainMoney()`** (file: `AlfieKit/Sources/Core/Services/BFFService/Converters/ProductListing+Converter.swift:68-80`)
   - Current:
     ```swift
     extension BFFGraphAPI.MoneyFragment {
         func toDomainMoney() -> Money {
             let minorUnits = Int((amount * 100).rounded())
             return Money(
                 currencyCode: currencyCode,
                 amount: minorUnits,
                 amountFormatted: String(format: "%.2f %@", amount, currencyCode)
             )
         }
     }
     ```
   - New:
     ```swift
     import Model   // ensure Model imported for CurrencyFormatter (Core already depends on Model)

     extension BFFGraphAPI.MoneyFragment {
         func toDomainMoney() -> Money {
             // BFF amount is a major-unit Double; parse once to a clean Decimal to avoid binary-float noise.
             let decimal = Decimal(string: String(amount)) ?? Decimal(amount)
             let digits = CurrencyFormatter.minorUnitDigits(for: currencyCode)
             let minorUnits = NSDecimalNumber(
                 decimal: (decimal * pow(10, digits)).rounded(0, .plain)   // or compute via NSDecimalNumber rounding
             ).intValue
             return Money(
                 currencyCode: currencyCode,
                 amount: minorUnits,
                 amountFormatted: CurrencyFormatter.string(amount: decimal, currencyCode: currencyCode)
             )
         }
     }
     ```
   - Implementation note on rounding: use `Decimal` rounding (`NSDecimalNumber.rounding(accordingToBehavior:)` or `var d; NSDecimalRound(&result, &d, 0, .plain)`) rather than `Int(Double)` to keep it exact. Keep it simple — a small private helper is fine; do NOT add a new public API for it.
   - Why: AC1 (`£10.23` via `.currency`) + AC2 (`pow(10, digits)` instead of `*100`).

2. **Confirm single definition & shared use** (file: `ProductDetails+Converter.swift`)
   - `ProductDetails+Converter.swift` calls `…moneyFragment.toDomainMoney()` (lines 25, 26, 88, 147) — it does **not** redefine it. So Step 1 covers both converters.
   - Action: grep `func toDomainMoney` across `Sources/` to confirm exactly one definition. If a second exists, apply the same change.

3. **Sanity-check the sale comparison** (file: `ProductDetails+Converter.swift:152`)
   - `(compareAt?.amount ?? 0) > amount.amount` operates on the new minor-unit `Int`. Scaling is consistent across both operands → comparison semantics unchanged. No edit needed; note in PR.

### Verification
- `./Alfie/scripts/verify.sh`.
- Existing `ProductListingConverterTests` `.amount` assertions (AUD 2dp: 2500/1000/5000) must still pass (×100 == ×10^2).
- Manual (optional): run app, confirm PLP shows `£x.xx`.

### Estimated Effort
S–M
