import Foundation
import Models

extension AlfieAnalyticsTracker {
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

    // MARK: - State Events

    func trackUserLogged(isLogged: Bool) {
        track(.state(.isUserLoggedIn(isLogged), nil))
    }
}
