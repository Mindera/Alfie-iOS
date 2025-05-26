import Foundation

public class WishlistProduct: SelectedProduct {
    override public var id: String { "\(product.id)-\(colour?.id ?? "no colour")" }

    public init(selectedProduct: SelectedProduct) {
        let updatedVariant = Product.Variant(
            sku: selectedProduct.selectedVariant.sku,
            size: nil, // Forcing size to not be included
            colour: selectedProduct.selectedVariant.colour,
            attributes: selectedProduct.selectedVariant.attributes,
            stock: selectedProduct.selectedVariant.stock,
            price: selectedProduct.selectedVariant.price
        )

        super.init(product: selectedProduct.product, selectedVariant: updatedVariant)
    }

    public init(product: Product) {
        let updatedVariant = Product.Variant(
            sku: product.defaultVariant.sku,
            size: nil, // Forcing size to not be included
            colour: product.defaultVariant.colour,
            attributes: product.defaultVariant.attributes,
            stock: product.defaultVariant.stock,
            price: product.defaultVariant.price
        )

        super.init(product: product, selectedVariant: updatedVariant)
    }
}
