import Foundation
import Model
import Navigation
import SharedUI

enum Screen: ScreenProtocol {
    case tab(_ tab: TabScreen)
    case webView(url: URL, title: String)
    case webFeature(_ feature: WebFeature)
    case account
    case wishlist
    case search(transition: SearchBarTransition?)
    case recentSearches
    case forceAppUpdate
    case debugMenu
    case productDetails(configuration: ProductDetailsConfiguration)
    case productListing(configuration: ProductListingScreenConfiguration)
    case categoryList(_ categories: [NavigationItem], title: String)

    var id: Screen {
        self
    }
}

enum TabScreen: ScreenProtocol {
    case home(_ config: HomeTabConfig? = nil)
    case shop(tab: ShopViewTab? = nil)
    case wishlist
    case bag

    var id: TabScreen {
        self
    }

    static let allCases: [TabScreen] = [.home(), .shop(), .wishlist, .bag]
}

enum HomeTabConfig: Hashable {
    case loggedIn(username: String, memberSince: Int)
    case loggedOut
}

enum ProductDetailsConfiguration: Hashable {
    case id(_ id: String)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}

struct ProductListingScreenConfiguration: Hashable {
    let category: String?
    let searchText: String?
    let urlQueryParameters: [String: String]?
    let mode: ProductListingViewMode
}
