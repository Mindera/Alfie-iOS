import Foundation

public protocol BFFClientServiceProtocol {
    func getHeaderNav(handle: NavigationHandle, includeSubItems: Bool, includeMedia: Bool) async throws -> [NavigationItem]
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
    func getBrands() async throws -> [Brand]
    func getWebViewConfig() async throws -> WebViewConfiguration
}
