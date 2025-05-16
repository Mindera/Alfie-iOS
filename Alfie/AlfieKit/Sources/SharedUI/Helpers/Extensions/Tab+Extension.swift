import Foundation
import Model

public extension Model.Tab {
    var title: String {
        switch self {
        case .bag:
            return "Bag"

        case .home:
            return "Home"

        case .shop:
            return "Shop"

        case .wishlist:
            return "Wishlist"
        }
    }

    var icon: Icon {
        switch self {
        case .home:
            .home

        case .shop:
            .store

        case .bag:
            .bag

        case .wishlist:
            .heart
        }
    }

    var accessibilityId: String {
        switch self {
        case .home:
            "home-tab"

        case .shop:
            "shop-tab"

        case .bag:
            "bag-tab"

        case .wishlist:
            "wishlist-tab"
        }
    }
}
