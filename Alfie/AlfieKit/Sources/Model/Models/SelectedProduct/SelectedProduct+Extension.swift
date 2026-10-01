import Foundation

public extension SelectedProduct {
    var sizeText: String {
        size?.displayName ?? ""
    }

    var priceType: PriceType {
        guard let salePreviousPrice = price.was else {
            return .default(price: price.amount.amountFormatted)
        }
        return .sale(
            fullPrice: salePreviousPrice.amountFormatted,
            finalPrice: price.amount.amountFormatted
        )
    }
}
