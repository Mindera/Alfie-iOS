import Foundation

public enum ProductDetailsViewErrorType: Error, CaseIterable {
    case generic
    case noConnection
    case notFound
    case rateLimited
    case serverError

    public static func from(error: Error) -> ProductDetailsViewErrorType {
        if (error as? BFFRequestError)?.isNotFound == true {
            return .notFound
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
