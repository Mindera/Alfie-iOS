import Foundation
import Model

public enum SearchIntent: Hashable {
    case productDetails(productID: String, product: Product?)
    case productListing(searchTerm: String?, category: String?)
    case webFeature(WebFeature)
}
