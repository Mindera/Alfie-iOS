public extension Product {
    var priceType: PriceType {
        if let range = priceRange {
            if let high = range.high {
                return .range(
                    lowerBound: range.low.amountFormatted,
                    upperBound: high.amountFormatted,
                    separator: "-"
                )
            } else {
                return .default(price: range.low.amountFormatted)
            }
        } else {
            if let salePreviousPrice = defaultVariant.price.was {
                return .sale(
                    fullPrice: salePreviousPrice.amountFormatted,
                    finalPrice: defaultVariant.price.amount.amountFormatted
                )
            } else {
                return .default(price: defaultVariant.price.amount.amountFormatted)
            }
        }
    }
}

