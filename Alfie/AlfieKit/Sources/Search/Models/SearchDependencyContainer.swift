import AlicerceLogging
import Foundation
import Model

public final class SearchDependencyContainer {
    let recentsService: RecentsServiceProtocol?
    let analytics: AlfieAnalyticsTracker
    let log: Logger

    public init(
        recentsService: RecentsServiceProtocol?,
        analytics: AlfieAnalyticsTracker,
        log: Logger
    ) {
        self.recentsService = recentsService
        self.analytics = analytics
        self.log = log
    }
}
