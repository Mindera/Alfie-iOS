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
            return "Store"

        case .wishlist:
            return "Wishlist"

        case .account:
            return "Account"
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

        case .account:
            .user
        }
    }

    // Selected tabs use the filled glyph where the design system provides one; shop has no fill variant.
    func icon(isSelected: Bool) -> Icon {
        guard isSelected else {
            return icon
        }
        switch self {
        case .home:
            return .homeFill

        case .bag:
            return .bagFill

        case .wishlist:
            return .heartFill

        case .account:
            return .accountFill

        case .shop:
            return .store
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

        case .account:
            "account-tab"
        }
    }
}
