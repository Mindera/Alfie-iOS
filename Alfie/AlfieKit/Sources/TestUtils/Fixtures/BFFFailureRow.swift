import Foundation
import Model

public struct BFFFailureRow {
    public let name: String
    public let error: Error
    public let kind: FailureKind
    public let plp: ProductListingViewErrorType
    public let pdp: ProductDetailsViewErrorType
    public let categories: CategoriesViewErrorType
}

extension BFFFailureRow {
    public static let all: [BFFFailureRow] = [
        .init(
            name: "server error",
            error: BFFRequestError(type: .serverError(status: 503), retryCount: 2),
            kind: .serverError,
            plp: .serverError,
            pdp: .serverError,
            categories: .serverError
        ),
        .init(
            name: "rate limited",
            error: BFFRequestError(type: .rateLimited(retryAfter: 5)),
            kind: .rateLimited,
            plp: .rateLimited,
            pdp: .rateLimited,
            categories: .rateLimited
        ),
        .init(
            name: "rate limited without retry-after",
            error: BFFRequestError(type: .rateLimited(retryAfter: nil)),
            kind: .rateLimited,
            plp: .rateLimited,
            pdp: .rateLimited,
            categories: .rateLimited
        ),
        .init(
            name: "no connection",
            error: BFFRequestError(type: .noInternet),
            kind: .noConnection,
            plp: .noConnection,
            pdp: .noConnection,
            categories: .noConnection
        ),
        .init(
            name: "timeout",
            error: BFFRequestError(type: .timeout),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "generic",
            error: BFFRequestError(type: .generic),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "cart not found",
            error: BFFRequestError(type: .cart(.cartNotFound)),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
        .init(
            name: "empty response",
            error: BFFRequestError(type: .emptyResponse),
            kind: .generic,
            plp: .noResults,
            pdp: .notFound,
            categories: .noResults
        ),
        .init(
            name: "product not found",
            error: BFFRequestError(type: .product(.noProduct)),
            kind: .generic,
            plp: .noResults,
            pdp: .notFound,
            categories: .noResults
        ),
        .init(
            name: "non-BFF error",
            error: URLError(.badServerResponse),
            kind: .generic,
            plp: .generic,
            pdp: .generic,
            categories: .generic
        ),
    ]
}
