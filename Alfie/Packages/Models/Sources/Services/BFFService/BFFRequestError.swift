import Foundation

public struct BFFRequestError: Error {
    public enum BFFRequestErrorType: Equatable {
        case generic
        case emptyResponse
        case noInternet
        case product(BFFProductRequestErrorType)
    }

    public enum BFFProductRequestErrorType: Equatable {
        case noProduct
        case noProducts(category: String?, query: String?)
        case generic
    }

    public let type: BFFRequestErrorType
    public let error: Error?
    public let errorMessage: String?

    public init(type: BFFRequestErrorType, error: Error? = nil, message: String? = nil) {
        self.type = type
        self.error = error
        self.errorMessage = message ?? error?.localizedDescription
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
