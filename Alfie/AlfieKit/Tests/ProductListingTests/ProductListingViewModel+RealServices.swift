import Core
import Mocks
import Model
@testable import ProductListing

extension ProductListingViewModel {
    static func onRealServices(
        bffClient: MockBFFClientService,
        category: String? = nil,
        searchText: String? = nil,
        mode: ProductListingViewMode
    ) -> ProductListingViewModel {
        .init(
            dependencies: ProductListingDependencyContainer(
                productListingService: ProductListingService(
                    productService: ProductService(bffClient: bffClient),
                    searchService: SearchService(bffClient: bffClient),
                    configuration: .init(type: .plp)
                ),
                plpStyleListProvider: ProductListingStyleProvider(userDefaults: MockUserDefaults()),
                wishlistService: MockWishlistService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker(),
                configurationService: MockConfigurationService(),
                log: MockLogger()
            ),
            category: category,
            searchText: searchText,
            mode: mode,
            navigate: { _ in },
            searchNavigation: mode == .listing ? .listing(openSearch: {}) : .searchResults(goBack: {}, editSearchTerm: {})
        )
    }
}
