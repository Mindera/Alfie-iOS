import Core
import Model

public final class WishlistDependencyContainer2 {
    let wishlistService: WishlistServiceProtocol
    let bagService: BagServiceProtocol
    let analytics: AlfieAnalyticsTracker

    public init(wishlistService: WishlistServiceProtocol, bagService: BagServiceProtocol, analytics: AlfieAnalyticsTracker) {
        self.wishlistService = wishlistService
        self.bagService = bagService
        self.analytics = analytics
    }
}
