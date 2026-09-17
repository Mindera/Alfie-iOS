import Foundation

public extension Product {
    static func skeletons(count: Int) -> [Product] {
        (0..<count).map { skeleton(id: "skeleton-\($0)") }
    }

    private static func skeleton(id: String) -> Product {
        let variant = Product.Variant(
            sku: "",
            size: nil,
            colour: nil,
            attributes: nil,
            stock: 0,
            price: .init(amount: .init(currencyCode: "AUD", amount: 0, amountFormatted: "$000,00"), was: nil)
        )
        return Product(
            id: id,
            styleNumber: "",
            name: "",
            brand: Brand(id: "", name: "", slug: ""),
            shortDescription: "",
            slug: "",
            defaultVariant: variant,
            variants: [variant],
            colours: nil
        )
    }
}
