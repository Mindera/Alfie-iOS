import Models
import Navigation
import SharedUI
import SharedUI
import SwiftUI

// MARK: - ToolbarItemProvider

enum ToolbarItemProvider {
    // TODO: Remove isPresentingDebugMenu for production versions
    public static func leadingItems(for screen: Screen, coordinator: Coordinator) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            switch screen {
            case .tab(.home(let configuration)):
                switch configuration {
                case .loggedIn(let username, let memberSince):
                    ThemedToolbarTitle(
                        style: .leftText(
                            L10n.Home.LoggedIn.title(username),
                            subtitle: L10n.Home.LoggedIn.subtitle("\(memberSince)")
                        ),
                        accessibilityId: AccessibilityId.titleHeader
                    )

                case .loggedOut, nil:
                    ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityId.titleHeader)
                }

            case .tab(.bag):
                ThemedToolbarTitle(
                    style: .leftText(L10n.Bag.title),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .tab(.shop):
                ThemedToolbarTitle(
                    style: .leftText(L10n.Shop.title),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .tab(.wishlist):
                ThemedToolbarTitle(
                    style: .leftText(L10n.Wishlist.title),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .webView,
                .webFeature,
                .account,
                .wishlist,
                .productDetails,
                .productListing,
                .categoryList:
                    EmptyView()

            default:
                EmptyView()
            }
        }
    }

    public static func principalItems(for screen: Screen, coordinator _: Coordinator) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            switch screen {
            case .tab(.shop),
                .tab(.bag),
                .tab(.wishlist),
                .tab(.home):
                Spacer()

            case .account:
                ThemedToolbarTitle(
                    style: .text(L10n.Account.title),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .wishlist:
                ThemedToolbarTitle(
                    style: .text(L10n.Wishlist.title),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .productDetails:
                EmptyView() // Set by the view, as the title depends on each individual product

            case .productListing(let configuration):
                ThemedToolbarTitle(
                    style: .text(configuration.category.orEmpty),
                    accessibilityId: AccessibilityId.titleHeader
                )

            case .webView(_, let title):
                ThemedToolbarTitle(style: .text(title), accessibilityId: AccessibilityId.titleHeader)

            case .webFeature(let feature):
                ThemedToolbarTitle(style: .text(feature.title), accessibilityId: AccessibilityId.titleHeader)

            case .categoryList(_, let title):
                ThemedToolbarTitle(style: .text(title), accessibilityId: AccessibilityId.titleHeader)

            default:
                ThemedToolbarTitle(style: .logo, accessibilityId: AccessibilityId.titleHeader)
            }
        }
    }

    public static func trailingItems(
        for screen: Screen,
        coordinator: Coordinator,
        isWishlistEnabled: Bool
    ) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            switch screen {
            case .tab(let tab):
                switch tab {
                case .home:
                    // TODO: Remove debug menu for production releases
                    debugMenuItem(with: coordinator, size: .big)
                    accountItem(with: coordinator, size: .big)

                case .shop,
                    .bag:
                    if isWishlistEnabled {
                        wishlistItem(with: coordinator, size: .big)
                    }
                    accountItem(with: coordinator, size: .big)

                case .wishlist:
                    accountItem(with: coordinator, size: .big)
                }

            default:
                EmptyView()
            }
        }
    }

    public static func shouldHideNavBar(for screen: Screen) -> Bool {
        switch screen {
        default:
            return false
        }
    }

    public static func shareItem(
        configuration: ShareConfiguration?,
        buttonSize: ToolBarButtonSize = .normal,
        sourceRect: CGRect = CGRect(
            x: UIScreen.main.bounds.width / 2 - 100,
            y: UIScreen.main.bounds.height / 2 - 100,
            width: 200,
            height: 200
        ),
        permittedArrowDirections: UIPopoverArrowDirection = []
    ) -> some View {
        ThemedToolbarButton(icon: .share, accessibilityId: AccessibilityId.shareBtn, toolBarButtonSize: buttonSize) {
            if let configuration {
                let activityVC = UIActivityViewController(
                    activityItems: [
                        configuration,
                        configuration.url,
                    ],
                    applicationActivities: nil
                )

                let keyWindow = UIApplication.shared.keyWindows?.first
                let rootVC = keyWindow?.rootViewController

                activityVC.popoverPresentationController?.sourceView = keyWindow
                activityVC.popoverPresentationController?.sourceRect = sourceRect
                activityVC.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
                (rootVC?.presentedViewController ?? rootVC)?.present(activityVC, animated: true, completion: nil)
            }
        }
        .disabled(configuration == nil)
    }

    public static func searchItem(with coordinator: Coordinator, size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .search, accessibilityId: AccessibilityId.searchBtn, toolBarButtonSize: size) {
            coordinator.openSearch()
        }
    }

    // MARK: - Private

    private static func rewardsItem(with _: Coordinator, size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .rewards, accessibilityId: AccessibilityId.rewardsBtn, toolBarButtonSize: size) {
            log.debug("REWARDS CARD PRESSED")
        }
    }

    private static func wishlistItem(with coordinator: Coordinator, size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .heart, accessibilityId: AccessibilityId.wishlistBtn, toolBarButtonSize: size) {
            coordinator.openWishlist()
        }
    }

    private static func listItem(with _: Coordinator, size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .list, accessibilityId: AccessibilityId.listBtn, toolBarButtonSize: size) {
            log.debug("LIST ICON PRESSED")
        }
    }

    private static func accountItem(with coordinator: Coordinator, size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .user, accessibilityId: AccessibilityId.accountBtn, toolBarButtonSize: size) {
            coordinator.openAccount()
        }
    }

    private static func debugMenuItem(
        with coordinator: Coordinator,
        size: ToolBarButtonSize = .normal
    ) -> some View {
        ThemedToolbarButton(icon: .settings, accessibilityId: AccessibilityId.settingsBtn, toolBarButtonSize: size) {
            coordinator.openDebugMenu()
        }
    }

    private static func backButton(with coordinator: Coordinator) -> some View {
        ThemedToolbarButton(icon: .arrowLeft, accessibilityId: AccessibilityId.backBtn) {
            coordinator.didTapBackButton()
        }
    }

    private static func iconSize(for buttonSize: ToolBarButtonSize) -> CGFloat {
        // swiftlint:disable vertical_whitespace_between_cases
        switch buttonSize {
        case .normal:
            return Constants.iconSizeNormal
        case .big:
            return Constants.iconSizeBig
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - AccessibilityId

private enum AccessibilityId {
    static let settingsBtn = "settings-btn"
    static let searchBtn = "search-btn"
    static let rewardsBtn = "rewards-btn"
    static let wishlistBtn = "wishlist-btn"
    static let listBtn = "list-btn"
    static let accountBtn = "account-btn"
    static let titleHeader = "title-header"
    static let backBtn = "back-btn"
    static let shareBtn = "share-btn"
}

// MARK: - Constants

private enum Constants {
    static let iconSizeNormal = 20.0
    static let iconSizeBig = 24.0
    static let buttonWidth = 44.0
    static let buttonHeight = 44.0
}
