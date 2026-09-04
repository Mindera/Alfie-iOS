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
    private static let graphqlRateLimitedCodes: Set<String> = ["RATE_LIMITED", "THROTTLED"]

    private let apolloClient: ApolloClient
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
            logRequests: logRequests,
            log: log
        )
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url.appending(path: BFFEndpoint.graphQL.rawValue)
        )
        self.apolloClient = ApolloClient(networkTransport: transport, store: store)
    }

    // MARK: - BFFClientServiceProtocol

    public func getHeaderNav(handle: NavigationHandle) async throws -> [NavigationItem] {
        let menuHandle = handle.bffMenuHandle
        log.info("menu → handle=\(menuHandle)")

        do {
            // The menu is never served from cache: the normalized cache has no TTL, so a cached menu
            // would hide merchandising changes until an app relaunch. Always fetch fresh.
            let items = try await executeFetch(
                BFFGraphAPI.MainMenuQuery(handle: menuHandle),
                cachePolicy: .fetchIgnoringCacheData
            ).menu.convertToNavigationItems()
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
            let product = try await executeFetch(
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
            let response = try await executeFetch(
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
            let response = try await executeFetch(
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
            let response = try await executeFetch(
                BFFGraphAPI.CategoryPriceRangeQuery(collectionHandle: collectionHandle)
            ).categoryPriceRange

            log.info("categoryPriceRange ← \(response == nil ? "nil" : "range")")

            return response?.convertToPriceRange()
        } catch {
            log.error("categoryPriceRange failed: \(error)")
            throw error
        }
    }

    public func getWebViewConfig() async throws -> WebViewConfiguration {
        let url = baseUrl.appending(path: BFFEndpoint.webviewConfig.rawValue)
        do {
            return try await dependencies.restNetworkClient.getData(from: url, authenticationToken: nil)
        } catch {
            throw BFFRequestError(type: .generic)
        }
    }

    public func createCart(lines: [CartLineInput]) async throws -> Cart {
        log.info("createCart → lines=\(lines.count)")

        do {
            let cart = try await executeMutation(
                BFFGraphAPI.CreateCartMutation(
                    input: BFFGraphAPI.CreateCartInput(lines: .some(lines.map(BFFGraphAPI.CartLineInput.init(domain:))))
                )
            ).createCart.fragments.cartFragment.convertToCart()

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
            let cart = try await executeMutation(
                BFFGraphAPI.AddToCartMutation(
                    input: BFFGraphAPI.AddToCartInput(cartId: cartId, lines: lines.map(BFFGraphAPI.CartLineInput.init(domain:)))
                )
            ).addToCart.fragments.cartFragment.convertToCart()

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
            let cart = try await executeMutation(
                BFFGraphAPI.RemoveFromCartMutation(cartId: cartId, lineId: lineId)
            ).removeFromCart.fragments.cartFragment.convertToCart()

            log.info("removeFromCart ← lines=\(cart.lines.count) quantity=\(cart.totalQuantity)")
            logUnrepresentableAmounts(in: cart, operation: "removeFromCart")
            return cart
        } catch {
            log.error("removeFromCart failed: \(error)")
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
            let cart = try await executeFetch(
                BFFGraphAPI.CartQuery(cartId: cartId),
                cachePolicy: .fetchIgnoringCacheCompletely
            ).cart.fragments.cartFragment.convertToCart()

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

    private func executeFetch<Query: GraphQLQuery>(
        _ query: Query,
        cachePolicy: CachePolicy = .default
    ) async throws -> Query.Data {
        try await execute(operationName: Query.operationName) { [apolloClient] resultHandler in
            apolloClient.fetch(query: query, cachePolicy: cachePolicy, resultHandler: resultHandler)
        }
    }

    private func executeMutation<Mutation: GraphQLMutation>(_ mutation: Mutation) async throws -> Mutation.Data {
        try await execute(operationName: Mutation.operationName) { [apolloClient] resultHandler in
            apolloClient.perform(mutation: mutation, resultHandler: resultHandler)
        }
    }

    private func execute<Data: RootSelectionSet>(
        operationName: String,
        perform: @escaping (@escaping (Result<GraphQLResult<Data>, Error>) -> Void) -> Cancellable
    ) async throws -> Data {
        try Task.checkCancellation()

        // Capture Apollo's `Cancellable` in a thread-safe box so the cancellation
        // handler can abort the in-flight request if the caller's task is cancelled
        // (e.g. user backs out of PLP mid-fetch). Without this we'd leak a network
        // round-trip and silently drop the response.
        let box = CancellableBox()
        do {
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
                    box.setResumeOnCancel { continuation.resume(throwing: CancellationError()) }
                    let cancellable = perform { result in
                        box.resumeOnce {
                            if let failure = Self.resultAsFailure(result) {
                                continuation.resume(throwing: failure)
                                return
                            }
                            guard let data = Self.resultAsSuccess(result)?.data else {
                                continuation.resume(throwing: BFFRequestError(type: .generic))
                                return
                            }
                            continuation.resume(returning: data)
                        }
                    }
                    box.set(cancellable)
                }
            } onCancel: {
                box.cancel()
            }
        } catch let error as BFFRequestError {
            reportError(error, operationName: operationName)
            throw error
        } catch {
            throw error
        }
    }

    private func reportError(_ error: BFFRequestError, operationName: String) {
        guard let reporter = dependencies.errorReporter else { return }
        let httpStatus: Int? = {
            switch error.type {
            case .serverError(let status): return status
            default: return nil
            }
        }()
        reporter.report(
            error: error,
            operationName: operationName,
            httpStatus: httpStatus,
            graphqlErrorCode: error.graphqlErrorCode
        )
    }

    private static func resultAsFailure<Data: RootSelectionSet>(_ result: Result<GraphQLResult<Data>, Error>) -> BFFRequestError? {
        switch result {
        case .success(let result):
            guard
                let errors = result.errors,
                !errors.isEmpty
            else {
                return nil
            }

            let code = errors.first?.extensions?["code"] as? String
            let message = errors.first?.message
            let type: BFFRequestError.BFFRequestErrorType = {
                if let code, graphqlRateLimitedCodes.contains(code) {
                    return .rateLimited(retryAfter: nil)
                }
                return .generic
            }()
            return BFFRequestError(type: type, message: message, graphqlErrorCode: code)

        case .failure(let error):
            if let bffError = error as? BFFRequestError { return bffError }
            if let urlError = error as? URLError, urlError.code == .timedOut {
                return BFFRequestError(type: .timeout, error: error)
            }
            return BFFRequestError(type: .generic, error: error)
        }
    }

    private static func resultAsSuccess<Data: RootSelectionSet>(_ result: Result<GraphQLResult<Data>, Error>) -> GraphQLResult<Data>? {
        guard
            case .success(let success) = result,
            success.errors == nil || success.errors?.isEmpty == true
        else {
            return nil
        }

        return success
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

