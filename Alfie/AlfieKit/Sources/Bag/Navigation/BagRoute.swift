import Foundation
import ProductDetails

public enum BagRoute: Hashable {
    case bag
    case productDetails(ProductDetailsRoute)
}
