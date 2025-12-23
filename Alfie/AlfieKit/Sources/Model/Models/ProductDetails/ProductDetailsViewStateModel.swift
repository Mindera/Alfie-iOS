import Foundation

public struct ProductDetailsViewStateModel {
    public let product: Product
    public let selectedVariant: Product.Variant

    public init(product: Product, selectedVariant: Product.Variant) {
        self.product = product
        self.selectedVariant = selectedVariant
    }
}
