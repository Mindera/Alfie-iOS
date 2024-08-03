import Foundation

public struct Price {
    /// The current price.
    public let amount: Money
    /// If discounted, the previous price.
    public let was: Money?

    public init(amount: Money, was: Money?) {
        self.amount = amount
        self.was = was
    }
}

public struct PriceRange {
    /// The lowest price.
    public let low: Money
    /// The highest price if not a 'from' range.
    public let high: Money?

    public init(low: Money, high: Money?) {
        self.low = low
        self.high = high
    }
}

public struct Money {
    /// The 3-letter currency code  e.g. AUD.
    public let currencyCode: String
    /// The amount in minor units (e.g. for $1.23 this will be 123).
    public let amount: Int
    /// The amount formatted according to the client locale (e.g. $1.23).
    public let amountFormatted: String

    public init(currencyCode: String, amount: Int, amountFormatted: String) {
        self.currencyCode = currencyCode
        self.amount = amount
        self.amountFormatted = amountFormatted
    }
}
