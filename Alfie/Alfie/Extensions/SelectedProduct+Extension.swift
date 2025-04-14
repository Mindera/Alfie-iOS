import Foundation
import Model

extension SelectedProduct {
    var sizeText: String {
        var sizeValue: String = ""
        if let size {
            sizeValue = size.value
            if let scale = size.scale {
                sizeValue += " \(scale)"
            }
        }

        return sizeValue
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
