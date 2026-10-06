import Foundation
import ProductDetails

public enum WishlistRoute: Hashable {
    case productDetails(ProductDetailsRoute)
    case wishlist
}
