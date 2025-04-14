import Foundation
import Model

public final class MockNavigationService: NavigationServiceProtocol {
    public init() { }

    public var onGetNavigationItemsCalled: ((NavigationItemsScreen) throws -> [NavigationItem])?
    public func getNavigationItems(for screen: NavigationItemsScreen) async throws -> [NavigationItem] {
        try onGetNavigationItemsCalled?(screen) ?? []
    }
}
