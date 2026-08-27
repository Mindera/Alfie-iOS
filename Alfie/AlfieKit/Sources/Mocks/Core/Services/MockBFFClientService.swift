import Model

public class MockBFFClientService: BFFClientServiceProtocol {
    public init() { }

    public var onGetHeaderNavCalled: ((NavigationHandle) throws -> [NavigationItem])?
    public func getHeaderNav(handle: NavigationHandle) async throws -> [NavigationItem] {
        try onGetHeaderNavCalled?(handle) ?? []
    }

    public var onGetProductCalled: ((String) throws -> Product)?
    public func getProduct(handle: String) async throws -> Product {
        guard let product = try onGetProductCalled?(handle) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product
    }

    public var onProductListCalled: ((String, String?, Int, String?, ProductFilterInput?) throws -> ProductListing)?
    public func productList(collectionHandle: String, after: String?, limit: Int, sort: String?, filters: ProductFilterInput?) async throws -> ProductListing {
        guard let productListing = try onProductListCalled?(collectionHandle, after, limit, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }

    public var onSearchProductsCalled: ((String, String?, Int, String?, ProductFilterInput?) throws -> ProductListing)?
    public func searchProducts(searchTerm: String, after: String?, limit: Int, sort: String?, filters: ProductFilterInput?) async throws -> ProductListing {
        guard let productListing = try onSearchProductsCalled?(searchTerm, after, limit, sort, filters) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productListing
    }

    public var onCategoryPriceRangeCalled: ((String) throws -> PriceRange?)?
    public func categoryPriceRange(collectionHandle: String) async throws -> PriceRange? {
        try onCategoryPriceRangeCalled?(collectionHandle)
    }

    public var onGetWebViewConfigCalled: (() throws -> WebViewConfiguration)?
    public func getWebViewConfig() async throws -> WebViewConfiguration {
        guard let config = try onGetWebViewConfigCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return config
    }
}
