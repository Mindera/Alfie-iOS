import Foundation
import Model

public final class MockNavigationService: NavigationServiceProtocol {
    public init() { }

    public private(set) var lastForceRefresh: Bool?
    public var onGetNavigationItemsCalled: ((NavigationItemsScreen) throws -> [NavigationItem])?
    public func getNavigationItems(for screen: NavigationItemsScreen, forceRefresh: Bool) async throws -> [NavigationItem] {
        lastForceRefresh = forceRefresh
        return try onGetNavigationItemsCalled?(screen) ?? []
    }
}
