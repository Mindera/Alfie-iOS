import Foundation

public struct SelectionProduct: Identifiable {
    public let id: String
    public let name: String
    public let brand: Brand
    public let size: Product.ProductSize?
    public let colour: Product.Colour?
    public let stock: Int
    public let price: Price

    public var media: [Media] {
        colour?.media ?? []
    }

    public init(product: Product, selectedVariant: Product.Variant? = nil) {
        let selectedVariant = selectedVariant ?? product.defaultVariant

        self.id = selectedVariant.sku
        self.name = product.name
        self.brand = product.brand
        self.size = selectedVariant.size
        self.colour = selectedVariant.colour
        self.stock = selectedVariant.stock
        self.price = selectedVariant.price
    }
}
