import SwiftUI

public struct PaginatedControlConfiguration {
    let backgroundColor: Color
    let tintColor: Color
    let textColor: Color
    let pageSeparator: String
    let infiniteScrollingEnabled: Bool

    public init(backgroundColor: Color = Colors.primary.white,
                tintColor: Color = Colors.primary.mono900,
                textColor: Color = Colors.primary.mono900,
                pageSeparator: String = "/",
                infiniteScrollingEnabled: Bool = true) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.textColor = textColor
        self.pageSeparator = pageSeparator
        self.infiniteScrollingEnabled = infiniteScrollingEnabled
    }
}
