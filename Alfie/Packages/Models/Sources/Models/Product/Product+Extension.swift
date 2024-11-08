public extension Product {
    var priceType: PriceType {
        if let range = priceRange {
            guard let high = range.high else { return .default(price: range.low.amountFormatted) }
            return .range(lowerBound: range.low.amountFormatted, upperBound: high.amountFormatted, separator: "-")
        } else {
            guard let salePreviousPrice = defaultVariant.price.was else {
                return .default(price: defaultVariant.price.amount.amountFormatted)
            }
            return .sale(
                fullPrice: salePreviousPrice.amountFormatted,
                finalPrice: defaultVariant.price.amount.amountFormatted
            )
        }
    }
}
