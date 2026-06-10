import Model

public class MockBFFClientService: BFFClientServiceProtocol {
    public init() { }

    public var onGetHeaderNavCalled: ((NavigationHandle, Bool, Bool) throws -> [NavigationItem])?
    public func getHeaderNav(handle: NavigationHandle, includeSubItems: Bool, includeMedia: Bool) async throws -> [NavigationItem] {
        try onGetHeaderNavCalled?(handle, includeSubItems, includeMedia) ?? []
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

    public var onGetBrandsCalled: (() throws -> [Brand])?
    public func getBrands() async throws -> [Brand] {
        guard let brands = try onGetBrandsCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return brands
    }

    public var onGetWebViewConfigCalled: (() throws -> WebViewConfiguration)?
    public func getWebViewConfig() async throws -> WebViewConfiguration {
        guard let config = try onGetWebViewConfigCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return config
    }
}
