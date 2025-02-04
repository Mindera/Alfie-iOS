import Core
import Foundation
import Models

final class SearchDependencyContainer {
    let executionQueue: DispatchQueue
    let recentsService: RecentsServiceProtocol?
    let searchService: SearchServiceProtocol
    let analytics: AlfieAnalyticsTracker

    init(
        executionQueue: DispatchQueue = DispatchQueue.main,
        recentsService: RecentsServiceProtocol?,
        searchService: SearchServiceProtocol,
        analytics: AlfieAnalyticsTracker
    ) {
        self.executionQueue = executionQueue
        self.recentsService = recentsService
        self.searchService = searchService
        self.analytics = analytics
    }
}
