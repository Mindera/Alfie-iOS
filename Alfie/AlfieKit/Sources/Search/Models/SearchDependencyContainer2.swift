import CombineSchedulers
import Core
import Foundation
import Model

public final class SearchDependencyContainer2 {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let recentsService: RecentsServiceProtocol?
    let searchService: SearchServiceProtocol
    let analytics: AlfieAnalyticsTracker

    public init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        recentsService: RecentsServiceProtocol?,
        searchService: SearchServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.scheduler = scheduler
        self.recentsService = recentsService
        self.searchService = searchService
        self.analytics = analytics
    }
}
