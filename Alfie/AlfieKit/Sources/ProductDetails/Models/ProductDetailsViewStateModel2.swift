import Foundation
import Model

public struct ProductDetailsViewStateModel2 {
    public let product: Product
    public let selectedVariant: Product.Variant

    public init(product: Product, selectedVariant: Product.Variant) {
        self.product = product
        self.selectedVariant = selectedVariant
    }
}
