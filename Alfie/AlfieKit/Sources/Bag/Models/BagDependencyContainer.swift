import Core
import Model

final class BagDependencyContainer {
    let bagService: BagServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(bagService: BagServiceProtocol, analytics: AlfieAnalyticsTracker) {
        self.bagService = bagService
        self.analytics = analytics
    }
}
