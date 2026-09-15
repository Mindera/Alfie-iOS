import Foundation
import Model

public enum SearchIntent: Hashable {
    case productDetails(productID: String, product: Product?)
    case productListing(searchTerm: String?, category: String?)
    case webFeature(WebFeature)

    public static func productDetails(_ product: Product) -> SearchIntent {
        .productDetails(productID: product.id, product: product)
    }
}
