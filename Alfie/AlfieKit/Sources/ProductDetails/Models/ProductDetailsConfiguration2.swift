import Foundation
import Model

public enum ProductDetailsConfiguration2: Hashable {
    case id(_ id: String)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}
