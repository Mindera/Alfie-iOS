import Foundation

public enum ProductListingViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductListingViewErrorType {
        guard let bff = error as? BFFRequestError else { return .generic }
        switch bff.type {
        case .rateLimited: return .rateLimited
        case .serverError: return .serverError
        case .noInternet: return .noInternet
        case .product(.noProduct), .product(.noProducts), .emptyResponse: return .noResults
        case .timeout, .product(.generic), .generic: return .generic
        }
    }
}
