import Apollo
import ApolloAPI
import BFFGraph
import Foundation

enum InterceptorTestHelpers {
    static let endpoint = URL(string: "https://example.test/graphql")!

    static func makeRequest() -> HTTPRequest<BFFGraphAPI.ProductListQuery> {
        let operation = BFFGraphAPI.ProductListQuery(
            collectionHandle: "test",
            after: .none,
            limit: 1,
            filters: .none
        )
        return HTTPRequest<BFFGraphAPI.ProductListQuery>(
            graphQLEndpoint: endpoint,
            operation: operation,
            contentType: "application/json",
            clientName: "test",
            clientVersion: "test",
            additionalHeaders: [:]
        )
    }

    static func makeResponse(
        status: Int,
        headers: [String: String] = [:]
    ) -> HTTPResponse<BFFGraphAPI.ProductListQuery> {
        let http = HTTPURLResponse(
            url: endpoint,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
        return HTTPResponse<BFFGraphAPI.ProductListQuery>(
            response: http,
            rawData: Data(),
            parsedResponse: nil
        )
    }
}
