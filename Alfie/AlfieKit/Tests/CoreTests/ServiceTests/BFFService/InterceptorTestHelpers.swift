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
        headers: [String: String] = [:],
        bodyJSON: String = ""
    ) -> HTTPResponse<BFFGraphAPI.ProductListQuery> {
        let http = HTTPURLResponse(
            url: endpoint,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
        return HTTPResponse<BFFGraphAPI.ProductListQuery>(
            response: http,
            rawData: bodyJSON.data(using: .utf8) ?? Data(),
            parsedResponse: nil
        )
    }
}

extension InterceptorTestHelpers {
    static func makeMutationRequest() -> HTTPRequest<BFFGraphAPI.AddToCartMutation> {
        let operation = BFFGraphAPI.AddToCartMutation(
            input: BFFGraphAPI.AddToCartInput(
                cartId: "cart-1",
                lines: [BFFGraphAPI.CartLineInput(productId: .some("prod-1"), variantId: "var-1")]
            )
        )
        return HTTPRequest<BFFGraphAPI.AddToCartMutation>(
            graphQLEndpoint: endpoint,
            operation: operation,
            contentType: "application/json",
            clientName: "test",
            clientVersion: "test",
            additionalHeaders: [:]
        )
    }

    static func makeMutationResponse(status: Int) -> HTTPResponse<BFFGraphAPI.AddToCartMutation> {
        let http = HTTPURLResponse(
            url: endpoint,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!
        return HTTPResponse<BFFGraphAPI.AddToCartMutation>(
            response: http,
            rawData: Data(),
            parsedResponse: nil
        )
    }
}
