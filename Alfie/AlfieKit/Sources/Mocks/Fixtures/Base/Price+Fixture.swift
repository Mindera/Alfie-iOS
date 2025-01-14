import Foundation
import Models

extension Price {
    public static func fixture(amount: Money = .fixture(),
                               was: Money? = nil) -> Price {
        .init(amount: amount, was: was)
    }
}

extension PriceRange {
    public static func fixture(low: Money = .fixture(),
                               high: Money? = .fixture()) -> PriceRange {
        .init(low: low, high: high)
    }
}

extension Money {
    public static func fixture(currencyCode: String = "AUD",
                               amount: Int = 123,
                               amountFormatted: String = "$1.23") -> Money {
        .init(currencyCode: currencyCode,
              amount: amount,
              amountFormatted: amountFormatted)
    }
}
