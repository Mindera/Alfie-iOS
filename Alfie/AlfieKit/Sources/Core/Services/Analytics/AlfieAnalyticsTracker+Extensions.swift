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

    /// A scanner was opened. The denominator the other two scan events are read against: started
    /// against succeeded is the completion rate, started against failed is the failure rate.
    func trackScanStarted(source: ScanEntryPoint) {
        track(.action(.scanStarted, [.source: source.rawValue]))
    }

    /// An Alfie code resolved to a Product and navigation began. `hasSku` records whether the code
    /// named a Variant as well — the codes are printed both ways, and the SKU is parsed but not yet
    /// acted on, so this is how we see how much would change once it is.
    func trackScanSucceeded(handle: String, hasSku: Bool) {
        track(.action(.scanSucceeded, [.handle: handle, .hasSku: hasSku]))
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
