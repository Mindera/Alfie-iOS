import Foundation
import Model
import MyAccount
import ProductDetails
import ProductListing
import Web
import Wishlist

public enum CategorySelectorRoute: Hashable {
    case categorySelector
    case myAccount(MyAccountRoute)
    case productDetails(ProductDetailsRoute)
    case productListing(ProductListingRoute)
    case subCategories(subCategories: [NavigationItem], parent: NavigationItem)
    case web(url: URL, title: String)
    case wishlist(WishlistRoute)
}
