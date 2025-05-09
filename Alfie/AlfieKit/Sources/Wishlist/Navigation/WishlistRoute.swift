import Foundation
import Model
import MyAccount
import ProductDetails

public enum WishlistRoute: Hashable {
    case myAccount(MyAccountRoute)
    case productDetails(ProductDetailsRoute)
    case wishlist
}
