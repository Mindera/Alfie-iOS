import Foundation

public enum FailureKind: Equatable {
    case serverError
    case rateLimited
    case noConnection
    case generic

    public init(error: Error) {
        switch (error as? BFFRequestError)?.type {
        case .serverError:
            self = .serverError

        case .rateLimited:
            self = .rateLimited

        case .noInternet:
            self = .noConnection

        case .generic, .emptyResponse, .product, .cart, .timeout, nil:
            self = .generic
        }
    }
}
