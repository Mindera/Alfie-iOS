import Core
import Model

final class BagDependencyContainer2 {
    let bagService: BagServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(bagService: BagServiceProtocol, analytics: AlfieAnalyticsTracker) {
        self.bagService = bagService
        self.analytics = analytics
    }
}
