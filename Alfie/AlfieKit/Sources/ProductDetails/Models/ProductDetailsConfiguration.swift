import Foundation
import Model

public enum ProductDetailsConfiguration: Hashable {
    case id(_ id: String)
    /// Fetch by handle: `handle` is the product slug used as the BFF handle. Named for the deep
    /// link that was its first caller, but it is the general slug-keyed entry — the bag opens a
    /// line's product through it too, using the slug the cart line carries.
    case deepLink(handle: String)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}
