import Foundation

public struct BFFRequestError: Error {
    public enum BFFRequestErrorType: Equatable {
        case generic
        case emptyResponse
        case noInternet
        case product(BFFProductRequestErrorType)
        case cart(BFFCartRequestErrorType)
        case rateLimited(retryAfter: TimeInterval?)
        case timeout
        case serverError(status: Int)
    }

    public enum BFFProductRequestErrorType: Equatable {
        case noProduct
        case noProducts(category: String?, query: String?, sort: String?)
        case generic
    }

    public enum BFFCartRequestErrorType: Equatable {
        /// The stored cart id is unknown or expired. Discard it and start a new cart.
        case cartNotFound
    }

    public let type: BFFRequestErrorType
    public let error: Error?
    public let errorMessage: String?
    public let retryCount: Int
    /// GraphQL error `extensions.code` captured at the source. Surfaces to telemetry
    /// so we can observe what codes the BFF emits in production. `nil` for non-GraphQL
    /// failure paths (HTTP transport errors, timeouts, etc.).
    public let graphqlErrorCode: String?
    /// GraphQL error `extensions.status` captured at the source. This is where the 404-vs-500
    /// discrimination lives, and so the only thing that tells a cart the server has forgotten
    /// apart from a server having a bad day. `nil` on the same non-GraphQL failure paths as
    /// `graphqlErrorCode`.
    public let graphqlErrorStatus: Int?

    public init(
        type: BFFRequestErrorType,
        error: Error? = nil,
        message: String? = nil,
        retryCount: Int = 0,
        graphqlErrorCode: String? = nil,
        graphqlErrorStatus: Int? = nil
    ) {
        self.type = type
        self.error = error
        self.errorMessage = message ?? error?.localizedDescription
        self.retryCount = retryCount
        self.graphqlErrorCode = graphqlErrorCode
        self.graphqlErrorStatus = graphqlErrorStatus
    }

    public var isNotFound: Bool {
        switch type {
        case .product(let subType):
            // swiftlint:disable vertical_whitespace_between_cases
            switch subType {
            case .noProduct,
                .noProducts:
                return true
            default:
                return false
            }
            // swiftlint:enable vertical_whitespace_between_cases

        case .emptyResponse:
            return true

        default:
            return false
        }
    }

    /// Re-labels a cart the platform no longer knows — which the BFF reports as `extensions.status`
    /// 404 — as `.cart(.cartNotFound)`, and returns every other failure untouched.
    ///
    /// Applied by the cart operations that name a cart rather than in the shared GraphQL error
    /// mapping, because a 404 only means "this cart is gone" when the request carried a cart id to
    /// begin with. `createCart` carries none, so a 404 from it means something else entirely.
    public func mappingCartNotFound() -> BFFRequestError {
        guard graphqlErrorStatus == GraphQLErrorStatus.notFound else { return self }

        return BFFRequestError(
            type: .cart(.cartNotFound),
            error: error,
            message: errorMessage,
            retryCount: retryCount,
            graphqlErrorCode: graphqlErrorCode,
            graphqlErrorStatus: graphqlErrorStatus
        )
    }
}

/// Values the BFF sends in a GraphQL error's `extensions.status`. Named because the number alone
/// says nothing about which resource was not found — the operation supplies that.
private enum GraphQLErrorStatus {
    static let notFound = 404
}
