import Foundation

public struct Price: Equatable, Hashable {
    /// The current price.
    public let amount: Money
    /// If discounted, the previous price.
    public let was: Money?

    public init(amount: Money, was: Money?) {
        self.amount = amount
        self.was = was
    }

    public static func == (lhs: Price, rhs: Price) -> Bool {
        lhs.amount == rhs.amount
        && lhs.was == rhs.was
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(amount)
        hasher.combine(was)
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

public struct Money: Equatable, Hashable {
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

    public static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.currencyCode == rhs.currencyCode
        && lhs.amount == rhs.amount
        && lhs.amountFormatted == rhs.amountFormatted
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(currencyCode)
        hasher.combine(amount)
        hasher.combine(amountFormatted)
    }
}
