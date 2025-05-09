import Foundation
import MyAccount
import ProductListing
import Search
import Wishlist

public enum HomeRoute: Hashable {
    case myAccount(MyAccountRoute)
    case productListing(ProductListingRoute)
    case wishlist(WishlistRoute)
}
