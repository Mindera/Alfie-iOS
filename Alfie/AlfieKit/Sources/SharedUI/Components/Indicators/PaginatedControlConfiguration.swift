import SwiftUI

public struct PaginatedControlConfiguration {
    let backgroundColor: Color
    let tintColor: Color
    let textColor: Color
    let pageSeparator: String
    let infiniteScrollingEnabled: Bool

    public init(
        backgroundColor: Color = DesignSystem.shared.color.surfaceBackgroundPrimary,
        tintColor: Color = DesignSystem.shared.color.contentContentPrimary,
        textColor: Color = DesignSystem.shared.color.contentContentPrimary,
        pageSeparator: String = "/",
        infiniteScrollingEnabled: Bool = true
    ) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.textColor = textColor
        self.pageSeparator = pageSeparator
        self.infiniteScrollingEnabled = infiniteScrollingEnabled
    }
}
