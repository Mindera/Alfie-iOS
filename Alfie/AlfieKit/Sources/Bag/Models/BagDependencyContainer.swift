import AlicerceLogging
import Model

public final class BagDependencyContainer {
    let cartService: CartServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let log: Logger

    public init(
        cartService: CartServiceProtocol,
        configurationService: ConfigurationServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        log: Logger
    ) {
        self.cartService = cartService
        self.configurationService = configurationService
        self.analytics = analytics
        self.log = log
    }
}
