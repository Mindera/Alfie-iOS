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

    var isSingleSizeProduct: Bool {
        let variantsForSelectedColor = variants.filter { $0.colour?.id == defaultVariant.colour?.id }
        return !variantsForSelectedColor.contains { $0.size != nil }
    }

    var sizeText: String {
        defaultVariant.size?.displayName ?? ""
    }
}

public extension Product.ProductSize {
    /// How a size reads wherever it is shown — the PDP chip, the product card, and the size text
    /// persisted with a Bag or Wishlist row. One rule, so those three cannot drift apart.
    var displayName: String {
        guard let scale else {
            return value
        }
        return "\(value) \(scale)"
    }
}
