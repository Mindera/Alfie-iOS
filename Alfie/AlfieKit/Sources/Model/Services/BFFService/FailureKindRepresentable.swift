import Foundation

public protocol FailureKindRepresentable {
    static var generic: Self { get }
    static var noConnection: Self { get }
    static var rateLimited: Self { get }
    static var serverError: Self { get }
}

extension FailureKindRepresentable {
    init(_ kind: FailureKind) {
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

    static func from(error: Error, notFound: Self) -> Self {
        if (error as? BFFRequestError)?.isNotFound == true {
            return notFound
        }
        return .init(FailureKind(error: error))
    }
}
