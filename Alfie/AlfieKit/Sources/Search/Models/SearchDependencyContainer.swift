import AlicerceLogging
import CombineSchedulers
import Foundation
import Model

public final class SearchDependencyContainer {
    let recentsService: RecentsServiceProtocol?
    let searchService: SearchServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let scheduler: AnySchedulerOf<DispatchQueue>
    let log: Logger

    public init(
        recentsService: RecentsServiceProtocol?,
        searchService: SearchServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        log: Logger
    ) {
        self.recentsService = recentsService
        self.searchService = searchService
        self.analytics = analytics
        self.scheduler = scheduler
        self.log = log
    }
}
