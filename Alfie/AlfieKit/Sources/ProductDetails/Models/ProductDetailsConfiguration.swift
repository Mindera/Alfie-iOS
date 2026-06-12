import Foundation
import Model

public enum ProductDetailsConfiguration: Hashable {
    case id(_ id: String)
    /// Deep-link entry: `handle` is the product slug taken straight from the URL and used as the BFF handle.
    case deepLink(handle: String)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}
