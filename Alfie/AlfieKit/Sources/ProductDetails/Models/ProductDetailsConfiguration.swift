import Foundation
import Model

public enum ProductDetailsConfiguration: Hashable {
    case id(_ id: String)
    /// Fetch by handle: `handle` is the product slug used as the BFF handle. Named for the deep
    /// link that was its first caller, but it is the general slug-keyed entry — the bag opens a
    /// line's product through it too, using the slug the cart line carries. `sku` preselects the
    /// Variant it names, then `variantId` (a scanned Barcode), falling back to the default Variant
    /// when neither names one.
    case deepLink(handle: String, sku: String? = nil, variantId: String? = nil)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}
