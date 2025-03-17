import Foundation
import Models
import Navigation
import StyleGuide

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
    case productDetails(_ type: ThemedProductDetailsScreen)
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

enum HomeTabConfig: Equatable, Hashable {
    case loggedIn(username: String, memberSince: Int)
    case loggedOut
}

enum ThemedProductDetailsScreen: Equatable, Hashable {
    case id(_ id: String)
    case product(_ product: Product)
    case selectedProduct(_ selectedProduct: SelectedProduct)
}

struct ProductListingScreenConfiguration: Equatable, Hashable {
    let category: String?
    let searchText: String?
    let urlQueryParameters: [String: String]?
    let mode: ProductListingViewMode
}
