import BFFGraphAPI
import Foundation
import Model

public extension BFFGraphAPI.PriceRangeFragment {
    func convertToPriceRange() -> PriceRange {
        PriceRange(
            low: low.fragments.moneyFragment.convertToMoney(),
            high: high?.fragments.moneyFragment.convertToMoney()
        )
    }
}

public extension BFFGraphAPI.PriceFragment {
    func convertToPrice() -> Price {
        Price(
            amount: amount.fragments.moneyFragment.convertToMoney(),
            was: was?.fragments.moneyFragment.convertToMoney()
        )
    }
}

public extension BFFGraphAPI.MoneyFragment {
    func convertToMoney() -> Money {
        Money(currencyCode: currencyCode, amount: amount, amountFormatted: amountFormatted)
    }
}
