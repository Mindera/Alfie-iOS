import Foundation

public protocol BFFClientServiceProtocol {
    func getHeaderNav(handle: NavigationHandle) async throws -> [NavigationItem]
    func getProduct(handle: String) async throws -> Product
    func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing
    func searchProducts(
        searchTerm: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing
    func categoryPriceRange(collectionHandle: String) async throws -> PriceRange?
    func getWebViewConfig() async throws -> WebViewConfiguration
    func createCart(lines: [CartLineInput]) async throws -> Cart
    func addToCart(cartId: String, lines: [CartLineInput]) async throws -> Cart
    func removeFromCart(cartId: String, lineId: String) async throws -> Cart
    func getCart(cartId: String) async throws -> Cart
}
