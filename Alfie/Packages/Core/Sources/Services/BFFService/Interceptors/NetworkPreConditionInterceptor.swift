import Apollo
import BFFGraphApi
import Foundation
import Models

final class NetworkPreConditionInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString
    let reachabilityService: ReachabilityServiceProtocol

    init(reachabilityService: ReachabilityServiceProtocol) {
        self.reachabilityService = reachabilityService
    }

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        guard reachabilityService.isNetworkAvailable else {
            chain.handleErrorAsync(BFFRequestError(type: .noInternet, error: nil), request: request, response: response, completion: completion)
            return
        }

        chain.proceedAsync(request: request,
                           response: response,
                           interceptor: self,
                           completion: completion)
    }
}
