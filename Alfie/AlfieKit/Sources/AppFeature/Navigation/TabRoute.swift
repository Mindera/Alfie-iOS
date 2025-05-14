import Bag
import CategorySelector
import Foundation
import Home
import Model
import Wishlist

enum TabRoute: Hashable {
    case home(HomeRoute)
    case bag(BagRoute)
    case shop(CategorySelectorRoute)
    case wishlist(WishlistRoute)
}

extension TabRoute {

    var tab: Model.Tab {
        switch self {
        case .home:
            return .home
        case .bag:
            return .bag
        case .shop:
            return .shop
        case .wishlist:
            return .wishlist
        }
    }
}
