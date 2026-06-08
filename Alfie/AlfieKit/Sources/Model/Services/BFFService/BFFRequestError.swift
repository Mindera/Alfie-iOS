import Foundation

public struct BFFRequestError: Error {
    public enum BFFRequestErrorType: Equatable {
        case generic
        case emptyResponse
        case noInternet
        case product(BFFProductRequestErrorType)
        case rateLimited(retryAfter: TimeInterval?)
        case timeout
        case serverError(status: Int)
    }

    public enum BFFProductRequestErrorType: Equatable {
        case noProduct
        case noProducts(category: String?, query: String?, sort: String?)
        case generic
    }

    public let type: BFFRequestErrorType
    public let error: Error?
    public let errorMessage: String?
    public let retryCount: Int
    /// GraphQL error `extensions.code` captured at the source. Surfaces to telemetry
    /// so we can observe what codes the BFF emits in production. `nil` for non-GraphQL
    /// failure paths (HTTP transport errors, timeouts, etc.).
    public let graphqlErrorCode: String?

    public init(
        type: BFFRequestErrorType,
        error: Error? = nil,
        message: String? = nil,
        retryCount: Int = 0,
        graphqlErrorCode: String? = nil
    ) {
        self.type = type
        self.error = error
        self.errorMessage = message ?? error?.localizedDescription
        self.retryCount = retryCount
        self.graphqlErrorCode = graphqlErrorCode
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
}
