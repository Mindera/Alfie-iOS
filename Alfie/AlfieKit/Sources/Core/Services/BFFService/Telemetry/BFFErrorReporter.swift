import AlicerceLogging
import Foundation
import Model

public protocol BFFErrorReporterProtocol {
    func report(
        error: BFFRequestError,
        operationName: String,
        httpStatus: Int?,
        graphqlErrorCode: String?
    )
}

/// Reports BFF failures to Analytics (always) and Crashlytics (server / generic only).
/// Rate-limit, timeout, and network categories are expected operational signals — we
/// surface them as Analytics events but keep them out of Crashlytics breadcrumbs so
/// the dashboard signal stays meaningful.
public final class BFFErrorReporter: BFFErrorReporterProtocol {
    private let analytics: AlfieAnalyticsTracker
    private let log: Logger

    public init(analytics: AlfieAnalyticsTracker, log: Logger) {
        self.analytics = analytics
        self.log = log
    }

    public func report(
        error: BFFRequestError,
        operationName: String,
        httpStatus: Int?,
        graphqlErrorCode: String?
    ) {
        let category = Self.category(for: error.type)

        analytics.trackBFFError(
            operationName: operationName,
            category: category,
            httpStatus: httpStatus,
            retryCount: error.retryCount,
            graphqlErrorCode: graphqlErrorCode
        )

        if Self.shouldRecordAsNonFatal(error.type) {
            // FirebaseLogDestination forwards log.error to Crashlytics.log() — this
            // attaches breadcrumb context to the next crash and creates a queryable
            // signal in the Crashlytics dashboard.
            log.error("[BFF] \(operationName) failed: category=\(category) status=\(httpStatus.map(String.init) ?? "nil") retries=\(error.retryCount) graphql_code=\(graphqlErrorCode ?? "nil")")
        }
    }

    static func category(for type: BFFRequestError.BFFRequestErrorType) -> String {
        switch type {
        case .rateLimited: return "rate_limited"
        case .timeout: return "timeout"
        case .serverError: return "server_error"
        case .noInternet: return "network"
        case .product, .emptyResponse: return "graphql"
        case .generic: return "generic"
        }
    }

    static func shouldRecordAsNonFatal(_ type: BFFRequestError.BFFRequestErrorType) -> Bool {
        switch type {
        case .serverError, .generic:
            return true
        case .product, .emptyResponse, .rateLimited, .timeout, .noInternet:
            // "No products" and similar GraphQL-level signals are legitimate empty
            // states, not failures — keep them out of Crashlytics. Rate-limit /
            // timeout / network are operational signals tracked via Analytics only.
            return false
        }
    }
}
