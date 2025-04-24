import Apollo
import BFFGraphAPI
import Foundation

final class AuthorizationInterceptor: ApolloInterceptor {
    var id: String = UUID().uuidString

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        // TODO: Implement API authentication
        // Example: https://www.apollographql.com/docs/ios/networking/request-pipeline#usermanagementinterceptor
        // We'll need to add an AuthorizationService or similar as a dependency, just like we did with the NetworkPreConditionInterceptor
        // then check if the user is authenticated, if the token is expired, renew tokens, etc and add them to the request
        // with (for example): request.addHeader(name: "Authorization", value: "Bearer \(token)")

        chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
    }
}
