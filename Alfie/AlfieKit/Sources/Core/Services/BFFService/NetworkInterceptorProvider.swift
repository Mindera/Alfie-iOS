import Apollo
import BFFGraphApi
import Models

final class NetworkInterceptorProvider: InterceptorProvider {
    private let store: ApolloStore
    private let client: URLSessionClient
    private let reachabilityService: ReachabilityServiceProtocol
    private let logRequests: Bool

    init(
        client: URLSessionClient,
        store: ApolloStore,
        reachabilityService: ReachabilityServiceProtocol,
        logRequests: Bool
    ) {
        self.store = store
        self.client = client
        self.reachabilityService = reachabilityService
        self.logRequests = logRequests
    }

    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = [ApolloInterceptor]()

        // Order is very important, check the default request chain here:
        // https://www.apollographql.com/docs/ios/networking/request-pipeline#default-interceptors

        interceptors.append(MaxRetryInterceptor())
        interceptors.append(CacheReadInterceptor(store: self.store))
        interceptors.append(NetworkPreConditionInterceptor(reachabilityService: self.reachabilityService)) // Custom
        interceptors.append(AuthorizationInterceptor()) // Custom
        if logRequests {
            interceptors.append(RequestLogInterceptor()) // Custom
        }
        interceptors.append(NetworkFetchInterceptor(client: self.client))
        if logRequests {
            interceptors.append(ResponseLogInterceptor()) // Custom
        }
        interceptors.append(ResponseCodeInterceptor())
        interceptors.append(MultipartResponseParsingInterceptor())
        interceptors.append(JSONResponseParsingInterceptor())
        interceptors.append(AutomaticPersistedQueryInterceptor())
        interceptors.append(CacheWriteInterceptor(store: self.store))

        return interceptors
    }
}
