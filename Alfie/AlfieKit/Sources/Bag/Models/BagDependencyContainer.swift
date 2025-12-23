import Model

public final class BagDependencyContainer {
    let bagService: BagServiceProtocol
    let configurationService: ConfigurationServiceProtocol
    let analytics: AlfieAnalyticsTracker

    public init(
        bagService: BagServiceProtocol,
        configurationService: ConfigurationServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.bagService = bagService
        self.configurationService = configurationService
        self.analytics = analytics
    }
}
