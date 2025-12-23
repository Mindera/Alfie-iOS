import Foundation
import MyAccount
import ProductDetails
import Wishlist

public enum BagRoute: Hashable {
    case bag
    case myAccount(MyAccountRoute)
    case productDetails(ProductDetailsRoute)
    case wishlist(WishlistRoute)
}
