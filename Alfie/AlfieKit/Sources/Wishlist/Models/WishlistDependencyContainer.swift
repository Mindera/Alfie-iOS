import Model

public final class WishlistDependencyContainer {
    let wishlistService: WishlistServiceProtocol
    let analytics: AlfieAnalyticsTracker

    public init(wishlistService: WishlistServiceProtocol, analytics: AlfieAnalyticsTracker) {
        self.wishlistService = wishlistService
        self.analytics = analytics
    }
}
