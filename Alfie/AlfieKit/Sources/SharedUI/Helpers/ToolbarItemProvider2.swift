import Model
import SwiftUI

public enum ToolbarItemProvider2 {
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

    public static func searchItem(
        size: ToolBarButtonSize = .normal,
        openSearchAction: @escaping () -> Void
    ) -> some View {
        ThemedToolbarButton(icon: .search, accessibilityId: AccessibilityId.searchBtn, toolBarButtonSize: .normal) {
            openSearchAction()
        }
    }

    // MARK: - Private

    private static func rewardsItem(size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .rewards, accessibilityId: AccessibilityId.rewardsBtn, toolBarButtonSize: size) {
            log.debug("REWARDS CARD PRESSED")
        }
    }

    private static func wishlistItem(
        size: ToolBarButtonSize = .normal,
        openWishlistAction: @escaping () -> Void
    ) -> some View {
        ThemedToolbarButton(icon: .heart, accessibilityId: AccessibilityId.wishlistBtn, toolBarButtonSize: size) {
            openWishlistAction()
        }
    }

    private static func listItem(size: ToolBarButtonSize = .normal) -> some View {
        ThemedToolbarButton(icon: .list, accessibilityId: AccessibilityId.listBtn, toolBarButtonSize: size) {
            log.debug("LIST ICON PRESSED")
        }
    }

    public static func accountItem(
        size: ToolBarButtonSize = .normal,
        openAccountAction: @escaping () -> Void
    ) -> some View {
        ThemedToolbarButton(icon: .user, accessibilityId: AccessibilityId.accountBtn, toolBarButtonSize: size) {
            openAccountAction()
        }
    }

    private static func debugMenuItem(
        size: ToolBarButtonSize = .normal,
        openDebugMenuAction: @escaping () -> Void
    ) -> some View {
        ThemedToolbarButton(icon: .settings, accessibilityId: AccessibilityId.settingsBtn, toolBarButtonSize: size) {
            openDebugMenuAction()
        }
    }

    private static func backButton(backButtonAction: @escaping () -> Void) -> some View {
        ThemedToolbarButton(icon: .arrowLeft, accessibilityId: AccessibilityId.backBtn) {
            backButtonAction()
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
