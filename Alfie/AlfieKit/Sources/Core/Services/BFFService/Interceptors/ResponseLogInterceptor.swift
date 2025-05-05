import AlicerceLogging
import Apollo
import BFFGraphAPI
import Foundation

final class ResponseLogInterceptor: ApolloInterceptor {
    enum ResponseLogError: Error {
        case notYetReceived
    }

    public var id: String = UUID().uuidString
    private let log: Logger

    init(log: Logger) {
        self.log = log
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        defer {
            // Even if we can't log, we still want to keep going.
            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
        }

        guard let receivedResponse = response else {
            chain.handleErrorAsync(
                ResponseLogError.notYetReceived,
                request: request,
                response: response,
                completion: completion
            )
            return
        }

        log.debug("[GraphQL] HTTP Response: \(receivedResponse.httpResponse)")

        guard let stringData = String(bytes: receivedResponse.rawData, encoding: .utf8) else {
            log.error("[GraphQL] Could not convert response data to string")
            return
        }

        log.verbose("[GraphQL] Response Data: \(stringData)")
    }
}
