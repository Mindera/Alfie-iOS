import Foundation

public enum ProductListingViewErrorType: Error, CaseIterable, FailureKindRepresentable {
    case generic
    case noConnection
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductListingViewErrorType {
        from(error: error, notFound: .noResults)
    }
}
