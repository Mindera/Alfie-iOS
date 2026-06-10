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

    public func getHeaderNav(
        handle: NavigationHandle,
        includeSubItems: Bool,
        includeMedia: Bool
    ) async throws -> [NavigationItem] {
        // TEMPORARY: the header-nav query was removed from the new BFF schema, so the Shop Categories
        // screen has no BFF data source yet. Until the BFF exposes a real categories/navigation query
        // we return a static, in-memory tree so the Categories → PLP → PDP flow works. Each leaf is a
        // `.listing` whose url is a real Shopify collection handle, so `productList` resolves it.
        // Tracked for replacement/removal by ALFMOB-387.
        let categories: [(title: String, handle: String)] = [
            ("Women", "women"),
            ("Men", "men"),
            ("Featured", "frontpage"),
            ("Tops", "womens-tops"),
            ("Beauty", "spring-summer"),
            ("Bags", "womens-bags"),
            ("Dresses", "dresses"),
            ("Jackets", "womens-jackets"),
            ("Jeans", "womens-jeans"),
        ]
        return categories.map { category in
            NavigationItem(
                type: .listing,
                title: category.title,
                url: "/\(category.handle)",
                media: nil,
                items: nil,
                attributes: nil
            )
        }
    }

    public func getProduct(handle: String) async throws -> Product {
        // `platform` is a predefined, app-level choice (see `BFFPlatform`) — not a per-request
        // argument — so it's resolved here rather than threaded through the call chain.
        let platform = BFFPlatform.predefined
        log.info("productDetails → handle=\(handle) platform=\(platform.rawValue)")

        do {
            let product = try await executeFetch(
                BFFGraphAPI.ProductDetailsQuery(handle: handle, platform: platform.rawValue)
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
        // Unlike `productList` (which the BFF defaults to Shopify when no platform is sent),
        // `searchProducts` rejects a request with no platform — so send the predefined one.
        let platform = BFFPlatform.predefined
        log.info("searchProducts → searchTerm=\(searchTerm) platform=\(platform.rawValue) after=\(after ?? "nil") limit=\(limit) sort=\(resolvedSort.rawValue) filters=\(filters.map(String.init(describing:)) ?? "nil")")

        do {
            let response = try await executeFetch(
                BFFGraphAPI.SearchProductsQuery(
                    searchTerm: searchTerm,
                    platform: platform.rawValue,
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

    public func getBrands() async throws -> [Brand] {
        // ALFMOB-331: BFF schema migration. The new schema removed the brands query;
        // a follow-up will reintroduce/replace it.
        throw BFFRequestError(type: .generic)
    }

    public func getWebViewConfig() async throws -> WebViewConfiguration {
        let url = baseUrl.appending(path: BFFEndpoint.webviewConfig.rawValue)
        do {
            return try await dependencies.restNetworkClient.getData(from: url, authenticationToken: nil)
        } catch {
            throw BFFRequestError(type: .generic)
        }
    }

    // MARK: - Private

    private func executeFetch<Query: GraphQLQuery>(_ query: Query) async throws -> Query.Data {
        try Task.checkCancellation()

        // Capture Apollo's `Cancellable` in a thread-safe box so the cancellation
        // handler can abort the in-flight request if the caller's task is cancelled
        // (e.g. user backs out of PLP mid-fetch). Without this we'd leak a network
        // round-trip and silently drop the response.
        let box = CancellableBox()
        do {
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Query.Data, Error>) in
                    let cancellable = apolloClient.fetch(query: query) { result in
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
                    box.set(cancellable)
                }
            } onCancel: {
                box.cancel()
            }
        } catch let error as BFFRequestError {
            reportError(error, operationName: Query.operationName)
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

