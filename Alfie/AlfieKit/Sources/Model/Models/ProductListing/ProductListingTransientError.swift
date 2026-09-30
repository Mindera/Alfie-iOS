import Foundation

public struct ProductListingTransientError: Equatable {
    public enum Request: Equatable {
        case refresh
        case nextPage

        public init?(_ pageRequest: ProductListingPageRequest) {
            switch pageRequest {
            case .refresh: self = .refresh
            case .nextPage: self = .nextPage
            case .firstPage: return nil
            }
        }

        public var pageRequest: ProductListingPageRequest {
            switch self {
            case .refresh: .refresh
            case .nextPage: .nextPage
            }
        }
    }

    public let request: Request
    public let error: ProductListingViewErrorType

    public init(request: Request, error: ProductListingViewErrorType) {
        self.request = request
        self.error = error
    }
}
