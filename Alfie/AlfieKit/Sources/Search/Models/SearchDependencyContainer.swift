import AlicerceLogging
import CombineSchedulers
import Foundation
import Model

public final class SearchDependencyContainer {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let recentsService: RecentsServiceProtocol?
    let searchService: SearchServiceProtocol
    let analytics: AlfieAnalyticsTracker
    let log: Logger

    public init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        recentsService: RecentsServiceProtocol?,
        searchService: SearchServiceProtocol,
        analytics: AlfieAnalyticsTracker,
        log: Logger
    ) {
        self.scheduler = scheduler
        self.recentsService = recentsService
        self.searchService = searchService
        self.analytics = analytics
        self.log = log
    }
}
