import BFFGraphApi
import Foundation
import Models

public extension PriceRangeFragment {
    func convertToPriceRange() -> PriceRange {
        PriceRange(low: low.fragments.moneyFragment.convertToMoney(),
                   high: high?.fragments.moneyFragment.convertToMoney())
    }
}

public extension PriceFragment {
    func convertToPrice() -> Price {
        Price(amount: amount.fragments.moneyFragment.convertToMoney(),
              was: was?.fragments.moneyFragment.convertToMoney())
    }
}

public extension MoneyFragment {
    func convertToMoney() -> Money {
        Money(currencyCode: currencyCode,
              amount: amount,
              amountFormatted: amountFormatted)
    }
}
