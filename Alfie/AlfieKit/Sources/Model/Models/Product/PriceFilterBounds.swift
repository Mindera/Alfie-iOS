import Foundation

/// The category's price range, expressed in the units the filter speaks.
///
/// This is the **single** place minor units become major units. `Money.amount` is minor
/// (`£10.23 → 1023`) while `ProductFilterInput.minPrice`/`maxPrice` are major (`10.23`); passing
/// one for the other yields a filter 100× too large on GBP and silently *correct* on JPY, whose
/// exponent is 0. Everything downstream of here holds major units.
public struct PriceFilterBounds: Hashable {
    public let currencyCode: String
    /// Major units, rounded **down** so the bound never excludes a product sitting on it.
    public let minimum: Double
    /// Major units, rounded **up**, for the same reason.
    public let maximum: Double

    public init(currencyCode: String, minimum: Double, maximum: Double) {
        self.currencyCode = currencyCode
        self.minimum = minimum
        self.maximum = maximum
    }

    /// Converts a BFF-supplied range. Returns `nil` when there is nothing to filter on: an absent
    /// upper bound, or a range that collapses to a single whole unit — a category priced at one
    /// point cannot be narrowed, so the Price row has no work to do and is not shown.
    public init?(priceRange: PriceRange) {
        guard let high = priceRange.high else { return nil }

        let currencyCode = priceRange.low.currencyCode
        let minimum = Self.majorUnits(of: priceRange.low, rounding: .down)
        let maximum = Self.majorUnits(of: high, rounding: .up)

        guard maximum > minimum else { return nil }

        self.init(currencyCode: currencyCode, minimum: minimum, maximum: maximum)
    }

    public var range: ClosedRange<Double> {
        minimum...maximum
    }

    private static func majorUnits(of money: Money, rounding: NSDecimalNumber.RoundingMode) -> Double {
        let digits = CurrencyFormatter.minorUnitDigits(for: money.currencyCode)
        let major = Decimal(money.amount) / pow(Decimal(10), digits)
        let handler = NSDecimalNumberHandler(
            roundingMode: rounding,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return NSDecimalNumber(decimal: major).rounding(accordingToBehavior: handler).doubleValue
    }
}
