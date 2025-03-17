import Foundation

public class BagProduct: SelectedProduct {
    // MARK: Lifecycle

    public init(selectedProduct: SelectedProduct) {
        super.init(product: selectedProduct.product, selectedVariant: selectedProduct.selectedVariant)
    }
}
