import Foundation

public class BagProduct: SelectedProduct {
    public init(selectedProduct: SelectedProduct) {
        super.init(product: selectedProduct.product, selectedVariant: selectedProduct.selectedVariant)
    }
}
