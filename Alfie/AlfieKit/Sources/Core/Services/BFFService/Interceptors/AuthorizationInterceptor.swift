import Apollo
import BFFGraph
import Foundation
import Model

final class AuthorizationInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString

    private let apiKeyService: BFFApiKeyServiceProtocol

    init(apiKeyService: BFFApiKeyServiceProtocol) {
        self.apiKeyService = apiKeyService
    }

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        // Read per request rather than capturing at init: the key is editable in the debug menu, and
        // unlike the endpoint it takes effect without rebooting the app.
        if let apiKey = apiKeyService.currentApiKey {
            request.addHeader(name: "Authorization", value: "Bearer \(apiKey)")
        }

        chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
    }
}
