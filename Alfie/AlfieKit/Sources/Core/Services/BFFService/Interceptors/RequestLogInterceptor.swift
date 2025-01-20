import AlicerceLogging
import Apollo
import BFFGraphApi
import Foundation

final class RequestLogInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString
    private var log: Logger
    
    init(log: Logger) {
        self.log = log
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        log.debug("[GraphQL] Outgoing request: \(request)")
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
