import Apollo
import BFFGraphApi
import Common
import Foundation

final class RequestLogInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        log("[GraphQL] Outgoing request: \(request)")
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
