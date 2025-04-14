import Foundation
import Model
import Navigation
import UIKit

final class Coordinator: ObservableObject, CoordinatorProtocol {
    let navigationAdapter: NavigationAdapter<Screen>
    let isWishlistEnabled: Bool

    init(navigationAdapter: NavigationAdapter<Screen>, isWishlistEnabled: Bool) {
        self.navigationAdapter = navigationAdapter
        self.isWishlistEnabled = isWishlistEnabled
    }

    convenience init() {
        self.init(navigationAdapter: .init(), isWishlistEnabled: false)
    }

    // MARK: - Public

    // MARK: Generic

    public func didTapBackButton() {
        navigationAdapter.pop()
    }

    public func popToRoot() {
        navigationAdapter.popToRoot()
    }

    public func canPop() -> Bool {
        navigationAdapter.canPop()
    }

    // MARK: Search

    public func openSearch() {
        navigationAdapter.presentFullscreenOverlay(with: .search(transition: .growFromTrailingIcon))
    }

    // MARK: - Account

    public func openAccount() {
        navigationAdapter.push(.account)
    }

    // MARK: - Wishlist

    public func openWishlist() {
        navigationAdapter.push(.wishlist)
    }

    // MARK: - Search

    public func closeSearch() {
        navigationAdapter.dismissFullScreenOverlay()
    }

    public func onSubmit(_ searchTerm: String) {
        let configuration = ProductListingScreenConfiguration(
            category: nil,
            searchText: searchTerm,
            urlQueryParameters: nil,
            mode: .searchResults
        )
        navigationAdapter.push(.productListing(configuration: configuration))
    }

    public func didTap(_ recentSearch: RecentSearch) {
        let configuration = ProductListingScreenConfiguration(
            category: nil,
            searchText: recentSearch.value,
            urlQueryParameters: nil,
            mode: .searchResults
        )
        navigationAdapter.push(.productListing(configuration: configuration))
    }

    public func didTap(_ suggestedKeyword: SearchSuggestionKeyword) {
        let configuration = ProductListingScreenConfiguration(
            category: nil,
            searchText: suggestedKeyword.term,
            urlQueryParameters: nil,
            mode: .searchResults
        )
        navigationAdapter.push(.productListing(configuration: configuration))
    }

    public func didTap(_ suggestedBrand: SearchSuggestionBrand) {
        let configuration = ProductListingScreenConfiguration(
            category: suggestedBrand.slug,
            searchText: nil,
            urlQueryParameters: nil,
            mode: .searchResults
        )
        navigationAdapter.push(.productListing(configuration: configuration))
    }

    // MARK: - Product Listing

    public func openProductListing(configuration: ProductListingScreenConfiguration) {
        navigationAdapter.push(.productListing(configuration: configuration))
    }

    // MARK: - App Update

    public func openForceAppUpdate() {
        navigationAdapter.presentFullScreenCover(.forceAppUpdate)
    }

    // MARK: - Debug Menu

    public func openDebugMenu() {
        navigationAdapter.presentFullScreenCover(.debugMenu)
    }

    public func closeDebugMenu() {
        navigationAdapter.dismissModal()
    }

    public func closeEndpointSelection() {
        navigationAdapter.dismissModal()
    }

    // MARK: - URL

    public func open(url: URL, title: String) {
        navigationAdapter.push(.webView(url: url, title: title))
    }

    public func open(webFeature: WebFeature) {
        navigationAdapter.push(.webFeature(webFeature))
    }

    // MARK: - Product Details

    public func openDetails(for productId: String) {
        navigationAdapter.push(.productDetails(configuration: .id(productId)))
    }

    public func openDetails(for product: Product) {
        navigationAdapter.push(.productDetails(configuration: .product(product)))
    }

    public func openDetails(for selectedProduct: SelectedProduct) {
        navigationAdapter.push(.productDetails(configuration: .selectedProduct(selectedProduct)))
    }

    // MARK: - Brands

    public func openBrands() {
        guard let url = ThemedURL.brands.internalUrl else {
            return
        }
        UIApplication.shared.open(url)
    }

    // MARK: - Categories

    public func openCategories(_ categories: [NavigationItem], title: String) {
        navigationAdapter.push(.categoryList(categories, title: title))
    }

    // MARK: - Shop / Services Tab

    public func openStoreServices() {
        guard let url = ThemedURL.services.internalUrl else {
            return
        }
        UIApplication.shared.open(url)
    }
}
