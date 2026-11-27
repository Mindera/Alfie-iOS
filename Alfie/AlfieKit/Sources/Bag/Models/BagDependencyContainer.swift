import AlicerceLogging
import Model

public final class BagDependencyContainer {
    let cartService: CartServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let log: Logger

    public init(
        cartService: CartServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        log: Logger
    ) {
        self.cartService = cartService
        self.analytics = analytics
        self.log = log
    }
}
