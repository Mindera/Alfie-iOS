import Foundation
import MyAccount
import ProductDetails

public enum WishlistRoute: Hashable {
    case myAccount(MyAccountRoute)
    case productDetails(ProductDetailsRoute)
    case wishlist
}
