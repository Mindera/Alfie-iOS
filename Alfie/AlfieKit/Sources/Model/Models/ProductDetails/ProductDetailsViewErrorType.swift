import Foundation

public enum ProductDetailsViewErrorType: Error, CaseIterable, FailureKindRepresentable {
    case generic
    case noConnection
    case notFound
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductDetailsViewErrorType {
        from(error: error, notFound: .notFound)
    }
}
