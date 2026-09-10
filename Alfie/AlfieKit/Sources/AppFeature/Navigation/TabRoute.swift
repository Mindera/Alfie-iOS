import Bag
import CategorySelector
import Foundation
import Home
import Model
import MyAccount
import ProductDetails
import ProductListing
import Wishlist

public enum TabRoute: Hashable {
    case home(HomeRoute)
    case bag(BagRoute)
    case shop(CategorySelectorRoute)
    case wishlist(WishlistRoute)
    case account(MyAccountRoute)
}

extension TabRoute {
    /// Where a deep link lands. Kept apart from the navigating itself so it can be asserted as a
    /// value: navigating pushes the route into a `NavigationPath`, which cannot be read back, so a
    /// test driving `AppFeatureViewModel` can only see which tab was selected — never which screen.
    ///
    /// `nil` for a link that names no destination, which leaves the app where it stands.
    init?(deepLinkType: DeepLink.LinkType) {
        switch deepLinkType {
        case .home:
            self = .home(.home)

        case .shop:
            self = .shop(.categorySelector)

        case .bag:
            self = .bag(.bag)

        case .wishlist:
            self = .wishlist(.wishlist)

        case .account:
            // The account screen is reached through Home's own stack, not the Account tab.
            self = .home(.myAccount(.myAccount))

        case .productList(let paths, let searchText, let urlQueryParameters):
            self = .shop(
                .productListing(
                    .productListing(.init(
                        category: paths,
                        searchText: searchText,
                        urlQueryParameters: urlQueryParameters,
                        mode: .listing
                    ))
                )
            )

        case .productDetail(let handle, _, _):
            // The BFF resolves a product by its Handle, which is the whole path after the `/product/` prefix.
            self = .shop(.productDetails(.productDetails(.deepLink(handle: handle))))

        case .webView(let url):
            self = .shop(.web(url: url, title: ""))

        case .unknown:
            return nil
        }
    }

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

        case .account:
            return .account
        }
    }
}
