import Foundation
import Models

public class MockSearchDependencyContainer: SearchDependencyContainerProtocol {
    public var executionQueue: DispatchQueue
    public var recentsService: RecentsServiceProtocol?
    public var searchService: SearchServiceProtocol

    public init(executionQueue: DispatchQueue = DispatchQueue.global(), 
                recentsService: MockRecentsService? = MockRecentsService(),
                searchService: SearchServiceProtocol = MockSearchService()) {
        self.executionQueue = executionQueue
        self.recentsService = recentsService
        self.searchService = searchService
    }
}
