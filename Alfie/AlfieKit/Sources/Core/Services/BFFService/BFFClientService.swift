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
        // ALFMOB-331: BFF schema migration in progress. Header nav query is gone from the
        // new schema; this stub keeps the build green until a follow-up ticket rewires it.
        throw BFFRequestError(type: .generic)
    }

    public func getProduct(handle: String, platform: BFFPlatform) async throws -> Product {
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

    public func productListing(
        after: String?,
        limit: Int,
        categoryId: String?,
        query: String?,
        sort: String?,
        filters: ProductFilterInput?
    ) async throws -> ProductListing {
        // `productList` requires a `collectionHandle`. The PLP screen can be entered in
        // `.searchResults` mode with `categoryId == nil` — that path needs to call the
        // BFF's `searchProducts` query instead, which is owned by ALFMOB-333. Until that
        // lands we surface a typed "no products" error rather than firing a request the
        // BFF will reject.
        guard let collectionHandle = categoryId, !collectionHandle.isEmpty else {
            log.error("productList called without a collectionHandle (search-mode wiring pending ALFMOB-333); returning noProducts.")
            throw BFFRequestError(type: .product(.noProducts(category: categoryId, query: query, sort: sort)))
        }

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

    public func getBrands() async throws -> [Brand] {
        // ALFMOB-331: BFF schema migration. The new schema removed the brands query;
        // a follow-up will reintroduce/replace it.
        throw BFFRequestError(type: .generic)
    }

    public func getSearchSuggestion(term: String) async throws -> SearchSuggestion {
        // ALFMOB-331: BFF schema migration. Search migration is tracked by ALFMOB-333.
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

