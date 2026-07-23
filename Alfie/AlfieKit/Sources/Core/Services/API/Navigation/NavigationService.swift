import Foundation
import Model

public final class NavigationService: NavigationServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    public func getNavigationItems(for screen: NavigationItemsScreen, forceRefresh: Bool) async throws -> [NavigationItem] {
        try await bffClient.getHeaderNav(
            handle: screen.handle,
            includeSubItems: true,
            includeMedia: false,
            forceRefresh: forceRefresh
        )
    }
}

private extension NavigationItemsScreen {
    var handle: NavigationHandle {
        switch self {
        case .shop:
            return .header
        }
    }
}
