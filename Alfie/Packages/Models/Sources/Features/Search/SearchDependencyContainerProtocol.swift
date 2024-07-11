import Foundation

public protocol SearchDependencyContainerProtocol {
    var executionQueue: DispatchQueue { get }
    var recentsService: RecentsServiceProtocol? { get }
    var searchService: SearchServiceProtocol { get }
}
