import Foundation

public enum ProductListingViewErrorType: Error, CaseIterable {
    case generic
    case noConnection
    case noResults
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductListingViewErrorType {
        if (error as? BFFRequestError)?.isNotFound == true {
            return .noResults
        }
        return .init(FailureKind(error: error))
    }

    private init(_ kind: FailureKind) {
        switch kind {
        case .serverError:
            self = .serverError

        case .rateLimited:
            self = .rateLimited

        case .noConnection:
            self = .noConnection

        case .generic:
            self = .generic
        }
    }
}
