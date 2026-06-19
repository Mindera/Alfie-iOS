import Foundation
import os

/// Locale-aware currency formatting. Stateless — the single source of truth for price strings.
public enum CurrencyFormatter {
    /// Formats a major-unit amount as a locale/currency-symbol-aware string.
    /// e.g. `(Decimal(10.23), "GBP", en_GB)` → `"£10.23"`.
    public static func string(
        amount: Decimal,
        currencyCode: String,
        locale: Locale = .current
    ) -> String {
        amount.formatted(.currency(code: currencyCode).locale(locale))
    }

    /// Minor-unit exponent for a currency (GBP=2, JPY=0, KWD=3), as reported by `NumberFormatter`
    /// for the given code. Unrecognised codes fall back to 2 (NumberFormatter's default).
    ///
    /// Memoised by currency code: `NumberFormatter` is expensive to build (loads ICU data) and a
    /// single PLP triggers dozens of calls for the same code. The cache is lock-protected because
    /// converters run off-main on the cooperative pool, so concurrent fetches can call this in parallel.
    public static func minorUnitDigits(for currencyCode: String) -> Int {
        minorUnitDigitsCache.withLock { cache in
            if let cached = cache[currencyCode] {
                return cached
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            let digits = formatter.maximumFractionDigits
            cache[currencyCode] = digits
            return digits
        }
    }

    private static let minorUnitDigitsCache = OSAllocatedUnfairLock<[String: Int]>(initialState: [:])

    /// Scales a major-unit amount to its integer minor-unit value using the currency's
    /// exponent (GBP £10.23 → 1023, JPY ¥5000 → 5000, KWD 19.999 → 19999).
    public static func minorUnits(of amount: Decimal, currencyCode: String) -> Int {
        let digits = minorUnitDigits(for: currencyCode)
        let scaled = NSDecimalNumber(decimal: amount)
            .multiplying(byPowerOf10: Int16(digits))
            .rounding(accordingToBehavior: minorUnitRoundingHandler)
        return Int(scaled.int64Value)
    }

    private static let minorUnitRoundingHandler = NSDecimalNumberHandler(
        roundingMode: .plain,
        scale: 0,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: false
    )
}
