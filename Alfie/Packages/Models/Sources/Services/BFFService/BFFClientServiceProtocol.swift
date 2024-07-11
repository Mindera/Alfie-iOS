import Foundation

public protocol BFFClientServiceProtocol {
    func getHeaderNav(handle: NavigationHandle, includeSubItems: Bool, includeMedia: Bool) async throws -> [NavigationItem]
    func getProduct(id: String) async throws -> Product
    func productListing(offset: Int, limit: Int, categoryId: String?, query: String?) async throws -> ProductListing
    func getBrands() async throws -> [Brand]
    func getSearchSuggestion(term: String) async throws -> SearchSuggestion
    func getWebViewConfig() async throws -> WebViewConfiguration
}
