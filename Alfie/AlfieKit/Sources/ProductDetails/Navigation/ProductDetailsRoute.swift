import Foundation
import Model

public enum ProductDetailsRoute: Hashable {
    case productDetails(productID: String, product: Product?)
    case webFeature(WebFeature)
}
