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

    public func getProduct(id: String) async throws -> Product {
        // ALFMOB-331: BFF schema migration. PDP migration is tracked by ALFMOB-332.
        throw BFFRequestError(type: .generic)
    }

    public func productListing(
        after: String?,
        limit: Int,
        categoryId: String?,
        query: String?,
        sort: String?
    ) async throws -> ProductListing {
        // ALFMOB-331 AC 2: cursor-based pagination via BFF's `productList`. Sort and filter
        // wiring land in subsequent ACs — for now we always use the default sort and no
        // filters.
        guard let collectionHandle = categoryId, !collectionHandle.isEmpty else {
            log.error("productList called without a collectionHandle; aborting.")
            throw BFFRequestError(type: .generic)
        }

        log.info("productList → collectionHandle=\(collectionHandle) after=\(after ?? "nil") limit=\(limit)")

        do {
            let response = try await executeFetch(
                BFFGraphAPI.ProductListQuery(
                    collectionHandle: collectionHandle,
                    after: after.map { .some($0) } ?? .none,
                    limit: limit,
                    filters: .none
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
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(with: .failure(BFFRequestError(type: .generic)))
                return
            }

            self.apolloClient.fetch(query: query, queue: DispatchQueue.main) { result in
                if let failure = Self.resultAsFailure(result) {
                    continuation.resume(with: .failure(failure))
                    return
                }

                guard let data = Self.resultAsSuccess(result)?.data else {
                    continuation.resume(with: .failure(BFFRequestError(type: .generic)))
                    return
                }

                continuation.resume(returning: data)
            }
        }
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

            return BFFRequestError(type: .generic, message: errors.first?.message)

        case .failure(let error):
            guard let bffError = error as? BFFRequestError else { return BFFRequestError(type: .generic, error: error) }
            return bffError
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
