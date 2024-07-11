import Foundation
import Models

final class SearchDependencyContainer: SearchDependencyContainerProtocol {
    let executionQueue: DispatchQueue
    let recentsService: RecentsServiceProtocol?
    let searchService: SearchServiceProtocol

    init(executionQueue: DispatchQueue = DispatchQueue.main,
         recentsService: RecentsServiceProtocol?,
         searchService: SearchServiceProtocol) {
        self.executionQueue = executionQueue
        self.recentsService = recentsService
        self.searchService = searchService
    }
}
