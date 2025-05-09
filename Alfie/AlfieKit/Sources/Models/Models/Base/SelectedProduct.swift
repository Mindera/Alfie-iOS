import Foundation

public struct SelectedProduct {
    public let product: Product
    public let selectedVariant: Product.Variant

    public var name: String {
        product.name
    }

    public var brand: Brand {
        product.brand
    }

    public var size: Product.ProductSize? {
        selectedVariant.size
    }

    public var colour: Product.Colour? {
        selectedVariant.colour
    }

    public var stock: Int {
        selectedVariant.stock
    }

    public var price: Price {
        selectedVariant.price
    }

    public var media: [Media] {
        colour?.media ?? []
    }

    public init(product: Product, selectedVariant: Product.Variant? = nil) {
        self.product = product
        self.selectedVariant = selectedVariant ?? product.defaultVariant
    }
}

extension SelectedProduct: Identifiable, Hashable {
    public var id: String {
        "\(product.id)-\(selectedVariant.sku)"
    }
}
