import AlicerceLogging
import Apollo
import BFFGraph
import Model

final class NetworkInterceptorProvider: InterceptorProvider {
    private let store: ApolloStore
    private let client: URLSessionClient
    private let reachabilityService: ReachabilityServiceProtocol
    private let logRequests: Bool
    private let log: Logger

    init(
        client: URLSessionClient,
        store: ApolloStore,
        reachabilityService: ReachabilityServiceProtocol,
        logRequests: Bool,
        log: Logger
    ) {
        self.store = store
        self.client = client
        self.reachabilityService = reachabilityService
        self.logRequests = logRequests
        self.log = log
    }

    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = [ApolloInterceptor]()

        // Order is very important, check the default request chain here:
        // https://www.apollographql.com/docs/ios/networking/request-pipeline#default-interceptors

        // MaxRetryInterceptor stays at the front as a safety cap on total retry passes.
        // BackoffRetryInterceptor enforces the business retry budget (3 attempts) and
        // calls chain.retry(), which re-enters MaxRetryInterceptor — so its limit must
        // exceed BackoffRetryInterceptor.Configuration.maxRetries.
        interceptors.append(MaxRetryInterceptor(maxRetriesAllowed: 5))
        interceptors.append(CacheReadInterceptor(store: self.store))
        interceptors.append(NetworkPreConditionInterceptor(reachabilityService: self.reachabilityService)) // Custom
        interceptors.append(AuthorizationInterceptor()) // Custom
        if logRequests {
            interceptors.append(RequestLogInterceptor(log: log)) // Custom
        }
        interceptors.append(NetworkFetchInterceptor(client: self.client))
        if logRequests {
            interceptors.append(ResponseLogInterceptor(log: log)) // Custom
        }
        // BackoffRetryInterceptor handles all retryable transient failures
        // (5xx subset + 429 / 430) and, on give-up, emits a typed BFFRequestError
        // carrying the observed retry count. ResponseCode catches everything else.
        interceptors.append(BackoffRetryInterceptor()) // Custom
        interceptors.append(ResponseCodeInterceptor())
        interceptors.append(MultipartResponseParsingInterceptor())
        interceptors.append(JSONResponseParsingInterceptor())
        interceptors.append(AutomaticPersistedQueryInterceptor())
        interceptors.append(CacheWriteInterceptor(store: self.store))

        return interceptors
    }
}
