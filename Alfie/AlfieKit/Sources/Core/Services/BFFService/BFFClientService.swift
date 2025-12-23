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

    public init(
        url: Foundation.URL,
        sessionConfiguration: URLSessionConfiguration = .default,
        logRequests: Bool = true,
        dependencies: BFFClientDependencyContainer,
        log: Logger
    ) {
        self.dependencies = dependencies
        self.baseUrl = url

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
        let navigation = try await executeFetch(
            BFFGraphAPI.GetHeaderNavQuery(
                handle: handle.rawValue,
                fetchMedia: includeMedia,
                fetchSubItems: includeSubItems
            )
        ).navigation

        return navigation.convertToNavigationItems()
    }

    public func getProduct(id: String) async throws -> Product {
        guard let product = try await executeFetch(BFFGraphAPI.GetProductQuery(productId: id)).product else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return product.convertToProduct()
    }

    public func productListing(
        offset: Int,
        limit: Int,
        categoryId: String?,
        query: String?,
        sort: String?
    ) async throws -> ProductListing {
        guard let productList = try await executeFetch(
            BFFGraphAPI.ProductListingQuery(
                offset: offset,
                limit: limit,
                categoryId: categoryId.map { .some($0) } ?? .none,
                query: query.map { .some($0) } ?? .none,
                sort: sort.map { .some(.case(.init(rawValue: $0) ?? .aZ )) } ?? .none
            )
        ).productListing
        else {
            throw BFFRequestError(type: .emptyResponse)
        }
        return productList.convertToProductListing()
    }

    public func getBrands() async throws -> [Brand] {
        let brands = try await executeFetch(BFFGraphAPI.BrandsQuery()).brands
        return brands.convertToBrands()
    }

    public func getSearchSuggestion(term: String) async throws -> SearchSuggestion {
        try await executeFetch(BFFGraphAPI.GetSuggestionsQuery(term: term)).suggestion.convertToSearchSuggestion()
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
