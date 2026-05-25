import Model

public class MockBFFClientService: BFFClientServiceProtocol {
    public init() { }

    public var onGetHeaderNavCalled: ((NavigationHandle, Bool, Bool) throws -> [NavigationItem])?
    public func getHeaderNav(handle: NavigationHandle, includeSubItems: Bool, includeMedia: Bool) async throws -> [NavigationItem] {
        try onGetHeaderNavCalled?(handle, includeSubItems, includeMedia) ?? []
    }

    public var onGetProductCalled: ((String) throws -> Product)?
    public func getProduct(id: String) async throws -> Product {
        guard let product = try onGetProductCalled?(id) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product
    }

    public var onProductListingCalled: ((String?, Int, String?, String?, String?, ProductFilterInput?) throws -> ProductListing)?
    public func productListing(after: String?, limit: Int, categoryId: String?, query: String?, sort: String?, filters: ProductFilterInput?) async throws -> ProductListing {
        guard let productListing = try onProductListingCalled?(after, limit, categoryId, query, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }

    public var onGetBrandsCalled: (() throws -> [Brand])?
    public func getBrands() async throws -> [Brand] {
        guard let brands = try onGetBrandsCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return brands
    }

    public var onGetSearchSuggestionCalled: ((String) throws -> SearchSuggestion)?
    public func getSearchSuggestion(term: String) async throws -> SearchSuggestion {
        guard let suggestion = try onGetSearchSuggestionCalled?(term) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return suggestion
    }

    public var onGetWebViewConfigCalled: (() throws -> WebViewConfiguration)?
    public func getWebViewConfig() async throws -> WebViewConfiguration {
        guard let config = try onGetWebViewConfigCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return config
    }
}
