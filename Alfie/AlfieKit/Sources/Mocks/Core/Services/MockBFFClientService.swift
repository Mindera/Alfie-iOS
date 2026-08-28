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

    public var onGetWebViewConfigCalled: (() throws -> WebViewConfiguration)?
    public func getWebViewConfig() async throws -> WebViewConfiguration {
        guard let config = try onGetWebViewConfigCalled?() else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return config
    }

    public var onCreateCartCalled: (([CartLineInput]) async throws -> Cart)?
    public func createCart(lines: [CartLineInput]) async throws -> Cart {
        guard let cart = try await onCreateCartCalled?(lines) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return cart
    }

    public var onAddToCartCalled: ((String, [CartLineInput]) async throws -> Cart)?
    public func addToCart(cartId: String, lines: [CartLineInput]) async throws -> Cart {
        guard let cart = try await onAddToCartCalled?(cartId, lines) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return cart
    }

    public var onRemoveFromCartCalled: ((String, String) throws -> Cart)?
    public func removeFromCart(cartId: String, lineId: String) async throws -> Cart {
        guard let cart = try onRemoveFromCartCalled?(cartId, lineId) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return cart
    }

    public var onGetCartCalled: ((String) throws -> Cart)?
    public func getCart(cartId: String) async throws -> Cart {
        guard let cart = try onGetCartCalled?(cartId) else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return cart
    }
}
