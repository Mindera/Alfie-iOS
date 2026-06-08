import Foundation

public enum ProductDetailsViewErrorType: Error, CaseIterable {
    case generic
    case noInternet
    case notFound
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductDetailsViewErrorType {
        guard let bff = error as? BFFRequestError else { return .generic }
        switch bff.type {
        case .rateLimited: return .rateLimited
        case .serverError: return .serverError
        case .noInternet: return .noInternet
        case .product(.noProduct), .product(.noProducts), .emptyResponse: return .notFound
        case .timeout, .product(.generic), .generic: return .generic
        }
    }
}
