import Foundation
import Models

extension SearchSuggestion {
    var isEmpty: Bool {
        brands.isEmpty && keywords.isEmpty && products.isEmpty
    }
}

extension SearchSuggestionProduct {
    func convertToProduct() -> Product {
        let color = Product.Colour(swatch: nil, name: "", media: media)
        let variant = Product.Variant(sku: "", size: nil, colour: color, attributes: nil, stock: 0, price: price)
        return Product(
            id: id,
            styleNumber: "",
            name: name,
            brand: .init(name: brandName, slug: ""),
            shortDescription: "",
            longDescription: "",
            slug: slug,
            priceRange: nil,
            attributes: nil,
            defaultVariant: variant,
            variants: [variant],
            colours: [color]
        )
    }
}
