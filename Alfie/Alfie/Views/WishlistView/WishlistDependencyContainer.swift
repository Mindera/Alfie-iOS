import Core
import Models

final class WishlistDependencyContainer {
    let wishlistService: WishlistServiceProtocol
    let bagService: BagServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(
        wishlistService: WishlistServiceProtocol,
        bagService: BagServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.wishlistService = wishlistService
        self.bagService = bagService
        self.analytics = analytics
    }
}
