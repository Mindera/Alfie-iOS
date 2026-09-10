import Foundation
import Model

public extension AlfieAnalyticsTracker {
    // MARK: - Action Events

    func trackAddToBag(productID: String) {
        track(.action(.addToBag, [.productID: productID]))
    }

    func trackRemoveFromBag(productID: String) {
        track(.action(.removeFromBag, [.productID: productID]))
    }

    func trackAddToWishlist(productID: String) {
        track(.action(.addToWishlist, [.productID: productID]))
    }

    func trackRemoveFromWishlist(productID: String) {
        track(.action(.removeFromWishlist, [.productID: productID]))
    }

    func trackSearch(term: String) {
        track(.action(.search, [.searchTerm: term]))
    }

    /// Every way a scan ends without a Product, under one event: the reasons are read against each
    /// other — a store whose shoppers mostly meet a refused camera needs a different fix from one
    /// whose shoppers mostly scan the wrong codes.
    func trackScanFailed(reason: ScanFailureReason) {
        track(.action(.scanFailed, [.reason: reason.rawValue]))
    }

    // MARK: - State Events

    func trackUser(isSignedIn: Bool) {
        track(.state(.isUserSignedIn(isSignedIn), nil))
    }

    // MARK: - BFF Telemetry

    func trackBFFError(
        operationName: String,
        category: String,
        httpStatus: Int?,
        retryCount: Int,
        graphqlErrorCode: String?
    ) {
        var parameters: [AnalyticsParameter: Any] = [
            .operationName: operationName,
            .errorCategory: category,
            .retryCount: retryCount,
        ]
        if let httpStatus { parameters[.httpStatus] = httpStatus }
        if let graphqlErrorCode { parameters[.graphqlErrorCode] = graphqlErrorCode }
        track(.action(.bffError, parameters))
    }
}
