import Foundation

public enum NavigationItemsScreen {
    case shop
}

public protocol NavigationServiceProtocol {
    func getNavigationItems(for screen: NavigationItemsScreen) async throws -> [NavigationItem]
}
