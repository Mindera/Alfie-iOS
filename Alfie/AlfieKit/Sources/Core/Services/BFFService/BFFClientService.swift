import AlicerceLogging
import Apollo
import BFFGraph
import Foundation
import Model

private enum BFFEndpoint: String {
    case graphQL = "graphql"
    case webviewConfig = "config/webviews"
}

public final class BFFClientService: BFFClientServiceProtocol {
    private let executor: BFFOperationExecutor
    private let dependencies: BFFClientDependencyContainer
    private let baseUrl: Foundation.URL
    private let log: Logger

    public init(
        url: Foundation.URL,
        sessionConfiguration: URLSessionConfiguration = .default,
        logRequests: Bool = true,
        dependencies: BFFClientDependencyContainer,
        log: Logger
    ) {
        self.dependencies = dependencies
        self.baseUrl = url
        self.log = log

        // Enforce explicit timeouts so BFF calls can't hang the UI. `.default` inherits
        // a 60s request / 7-day resource budget, which is far too lax for mobile.
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.timeoutIntervalForResource = 60

        let client = URLSessionClient(sessionConfiguration: sessionConfiguration)
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(
            client: client,
            store: store,
            reachabilityService: dependencies.reachabilityService,
            apiKeyService: dependencies.apiKeyService,
            logRequests: logRequests,
            log: log
        )
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url.appending(path: BFFEndpoint.graphQL.rawValue)
        )
        self.executor = BFFOperationExecutor(
            apolloClient: ApolloClient(networkTransport: transport, store: store),
            dependencies: dependencies
        )
    }

    // MARK: - BFFClientServiceProtocol

    public func getHeaderNav(handle: NavigationHandle) async throws -> [NavigationItem] {
        let menuHandle = handle.bffMenuHandle
        log.info("menu → handle=\(menuHandle)")

        do {
            // The menu is never served from cache: the normalized cache has no TTL, so a cached menu
            // would hide merchandising changes until an app relaunch. Always fetch fresh.
            let response = try await executor.fetch(
                BFFGraphAPI.MainMenuQuery(handle: menuHandle),
                cachePolicy: .fetchIgnoringCacheData
            )
            let items = response.menu.convertToNavigationItems()
            if items.isEmpty {
                // Menu returned but nothing was actionable — no recognizable collection links.
                // Surfaces an otherwise-silent empty Shop screen.
                log.error("menu ← 0 actionable categories (no recognizable collection links)")
            } else {
                log.info("menu ← items=\(items.count)")
            }
            return items
        } catch {
            log.error("menu failed: \(error)")
            throw error
        }
    }

    public func getProduct(handle: String) async throws -> Product {
        log.info("productDetails → handle=\(handle)")

        do {
            let product = try await executor.fetch(
                BFFGraphAPI.ProductDetailsQuery(handle: handle)
            ).productDetails

            guard let product else {
                log.error("productDetails ← null for handle=\(handle)")
                throw BFFRequestError(type: .product(.noProduct))
            }

            return product.fragments.productDetailsFragment.convertToProduct()
        } catch {
            log.error("productDetails failed: \(error)")
            throw error
        }
    }

    public func productByBarcode(_ barcode: String) async throws -> BarcodeMatch? {
        log.info("productByBarcode → barcode=\(barcode)")

        do {
            let match = try await executor.fetch(
                BFFGraphAPI.ProductByBarcodeQuery(barcode: barcode)
            ).productByBarcode

            log.info(
                "productByBarcode ← productId=\(match?.id ?? "nil") handle=\(match?.slug ?? "nil") "
                    + "variantId=\(match?.variantId ?? "nil")"
            )

            return match.map { BarcodeMatch(handle: $0.slug, variantId: $0.variantId) }
        } catch {
            log.error("productByBarcode failed: \(error)")
            throw error
        }
    }

    public func productList(
        collectionHandle: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        let resolvedSort = BFFGraphAPI.ProductSortEnum.from(sortOption: sort)
        let resolvedFilters = BFFGraphAPI.ProductFilterInput.from(domain: filters)
        log.info("productList → collectionHandle=\(collectionHandle) after=\(after ?? "nil") limit=\(limit) sort=\(resolvedSort.rawValue) filters=\(filters.map(String.init(describing:)) ?? "nil")")

        do {
            let response = try await executor.fetch(
                BFFGraphAPI.ProductListQuery(
                    collectionHandle: collectionHandle,
                    after: after.map { .some($0) } ?? .none,
                    limit: limit,
                    filters: resolvedFilters,
                    sort: .some(.case(resolvedSort))
                )
            ).productList

            log.info("productList ← totalCount=\(response.totalCount ?? -1) products=\(response.products.count) hasNextPage=\(response.pageInfo?.hasNextPage == true) endCursor=\(response.pageInfo?.endCursor ?? "nil")")

            return response.convertToProductListing()
        } catch {
            log.error("productList failed: \(error)")
            throw error
        }
    }

    public func searchProducts(
        searchTerm: String,
        after: String?,
        limit: Int,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        let resolvedSort = BFFGraphAPI.ProductSortEnum.from(sortOption: sort)
        let resolvedFilters = BFFGraphAPI.ProductFilterInput.from(domain: filters)
        log.info("searchProducts → searchTerm=\(searchTerm) after=\(after ?? "nil") limit=\(limit) sort=\(resolvedSort.rawValue) filters=\(filters.map(String.init(describing:)) ?? "nil")")

        do {
            let response = try await executor.fetch(
                BFFGraphAPI.SearchProductsQuery(
                    searchTerm: searchTerm,
                    after: after.map { .some($0) } ?? .none,
                    limit: limit,
                    filters: resolvedFilters,
                    sort: .some(.case(resolvedSort))
                )
            ).searchProducts

            log.info("searchProducts ← totalCount=\(response.totalCount ?? -1) products=\(response.products.count) hasNextPage=\(response.pageInfo?.hasNextPage == true) endCursor=\(response.pageInfo?.endCursor ?? "nil")")

            return response.convertToProductListing()
        } catch {
            log.error("searchProducts failed: \(error)")
            throw error
        }
    }

    public func categoryPriceRange(collectionHandle: String) async throws -> PriceRange? {
        log.info("categoryPriceRange → collectionHandle=\(collectionHandle)")

        do {
            let response = try await executor.fetch(
                BFFGraphAPI.CategoryPriceRangeQuery(collectionHandle: collectionHandle)
            ).categoryPriceRange

            log.info("categoryPriceRange ← \(response == nil ? "nil" : "range")")

            return response?.convertToPriceRange()
        } catch {
            log.error("categoryPriceRange failed: \(error)")
            throw error
        }
    }

    public func relatedProducts(handle: String, limit: Int) async throws -> [Product] {
        log.info("relatedProducts → handle=\(handle) limit=\(limit)")

        do {
            let products = try await executor.fetch(
                BFFGraphAPI.RelatedProductsQuery(handle: handle, limit: limit)
            ).relatedProducts

            log.info("relatedProducts ← products=\(products.count)")

            return products.map { $0.fragments.productListItemFragment.convertToProduct() }
        } catch {
            log.error("relatedProducts failed: \(error)")
            throw error
        }
    }

    public func getWebViewConfig() async throws -> WebViewConfiguration {
        let url = baseUrl.appending(path: BFFEndpoint.webviewConfig.rawValue)
        do {
            return try await dependencies.restNetworkClient.getData(
                from: url,
                authenticationToken: dependencies.apiKeyService.currentApiKey
            )
        } catch {
            throw BFFRequestError(type: .generic)
        }
    }

    /// Alone among the cart operations this does not map a not-found to `.cart(.cartNotFound)`: it
    /// names no cart, so a 404 from it cannot mean "that cart is gone" and would send `CartService`
    /// into a recovery that has nothing to recover.
    public func createCart(lines: [CartLineInput]) async throws -> Cart {
        log.info("createCart → lines=\(lines.count)")

        do {
            let response = try await executor.perform(
                BFFGraphAPI.CreateCartMutation(
                    input: BFFGraphAPI.CreateCartInput(lines: .some(lines.map(BFFGraphAPI.CartLineInput.init(domain:))))
                )
            )
            let cart = response.createCart.fragments.cartFragment.convertToCart()

            log.info("createCart ← id=\(cart.id) lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "createCart")
            return cart
        } catch {
            log.error("createCart failed: \(error)")
            throw error
        }
    }

    public func addToCart(cartId: String, lines: [CartLineInput]) async throws -> Cart {
        log.info("addToCart → cartId=\(cartId) lines=\(lines.count)")

        do {
            let response = try await executor.perform(
                BFFGraphAPI.AddToCartMutation(
                    input: BFFGraphAPI.AddToCartInput(
                        cartId: cartId,
                        lines: lines.map(BFFGraphAPI.CartLineInput.init(domain:))
                    )
                ),
                mapError: { $0.mappingCartNotFound() }
            )
            let cart = response.addToCart.fragments.cartFragment.convertToCart()

            log.info("addToCart ← lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "addToCart")
            return cart
        } catch {
            log.error("addToCart failed: \(error)")
            throw error
        }
    }

    public func removeFromCart(cartId: String, lineId: String) async throws -> Cart {
        log.info("removeFromCart → cartId=\(cartId) lineId=\(lineId)")

        do {
            let response = try await executor.perform(
                BFFGraphAPI.RemoveFromCartMutation(cartId: cartId, lineId: lineId),
                mapError: { $0.mappingCartNotFound() }
            )
            let cart = response.removeFromCart.fragments.cartFragment.convertToCart()

            log.info("removeFromCart ← lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "removeFromCart")
            return cart
        } catch {
            log.error("removeFromCart failed: \(error)")
            throw error
        }
    }

    public func updateCart(cartId: String, lines: [CartLineUpdate]) async throws -> Cart {
        log.info("updateCart → cartId=\(cartId) lines=\(lines.count)")

        do {
            let response = try await executor.perform(
                BFFGraphAPI.UpdateCartMutation(
                    input: BFFGraphAPI.UpdateCartInput(
                        cartId: cartId,
                        lines: lines.map(BFFGraphAPI.UpdateCartLineInput.init(domain:))
                    )
                ),
                mapError: { $0.mappingCartNotFound() }
            )
            let cart = response.updateCart.fragments.cartFragment.convertToCart()

            log.info("updateCart ← lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "updateCart")
            return cart
        } catch {
            log.error("updateCart failed: \(error)")
            throw error
        }
    }

    public func getCart(cartId: String) async throws -> Cart {
        log.info("getCart → cartId=\(cartId)")

        do {
            // The cart never touches the cache, in either direction: a stale bag is worse than no
            // bag, and every mutation already returns the authoritative cart. `Completely` rather
            // than `.fetchIgnoringCacheData`, which skips the read but still writes — that write
            // is one nobody reads, and it leaves a stale cart for the next caller to trip over.
            let response = try await executor.fetch(
                BFFGraphAPI.CartQuery(cartId: cartId),
                cachePolicy: .fetchIgnoringCacheCompletely,
                mapError: { $0.mappingCartNotFound() }
            )
            let cart = response.cart.fragments.cartFragment.convertToCart()

            log.info("getCart ← lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "getCart")
            return cart
        } catch {
            log.error("getCart failed: \(error)")
            throw error
        }
    }

    // MARK: - Private

    /// Reports any amount the BFF sent in a form this app cannot represent. Logged at `error`
    /// because it means the BFF has a defect: the shopper only sees a `—` in place of the price,
    /// which nobody reports, so this log is the only way we find out.
    private func logUnrepresentableAmounts(in cart: Cart, operation: String) {
        let fields = cart.unrepresentableAmountFields
        guard !fields.isEmpty else { return }
        log.error("\(operation) ← unrepresentable amount(s) cartId=\(cart.id) fields=\(fields.joined(separator: ","))")
    }
}

extension NavigationHandle {
    // The Shop Categories screen maps to the curated "product-category" menu (collections-only);
    // other slots fall back to their raw name.
    var bffMenuHandle: String {
        switch self {
        case .header:
            return "product-category"
        case .footer, .social, .topbar:
            return rawValue
        }
    }
}
