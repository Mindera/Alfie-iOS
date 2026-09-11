import Foundation
import Model

public final class NavigationService: NavigationServiceProtocol {
    private let bffClient: BFFClientServiceProtocol

    // MARK: - Public

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient
    }

    /// Temporarily returns hardcoded categories instead of the BFF menu, so the Shop screen has
    /// known-good entries to drive. Restore the `bffClient.getHeaderNav` call to go back to the
    /// real menu.
    public func getNavigationItems(for screen: NavigationItemsScreen) async throws -> [NavigationItem] {
        [.women, .men, .shoes, .sale]
    }
}

private extension NavigationItem {
    /// The categories the Shop screen shows while the BFF menu is bypassed. Their titles are
    /// store-facing category names like every other menu title — those arrive from the BFF
    /// unlocalized — so they stay literals rather than `L10n` keys.
    static let women = NavigationItem(
        id: "women-1",
        type: .listing,
        title: "Women",
        // Matches the converter's shape for a collection link: leading slash, handle only.
        url: "/women-1",
        media: nil,
        items: nil,
        attributes: nil
    )

    static let men = NavigationItem(
        id: "men-2",
        type: .listing,
        title: "Men",
        url: "/men-2",
        media: nil,
        items: nil,
        attributes: nil
    )

    static let shoes = NavigationItem(
        id: "shoes-76",
        type: .listing,
        title: "Shoes",
        url: "/shoes-76",
        media: nil,
        items: nil,
        attributes: nil
    )

    static let sale = NavigationItem(
        id: "sale-23",
        type: .listing,
        title: "Sale",
        url: "/sale-23",
        media: nil,
        items: nil,
        attributes: nil
    )
}

private extension NavigationItemsScreen {
    var handle: NavigationHandle {
        switch self {
        case .shop:
            return .header
        }
    }
}
