import SwiftUI

public struct PaginatedControlConfiguration {
    let backgroundColor: Color
    let tintColor: Color
    let textColor: Color
    let pageSeparator: String
    let infiniteScrollingEnabled: Bool

    public init(
        backgroundColor: Color = Primitives.Colours.neutrals0,
        tintColor: Color = Primitives.Colours.neutrals800,
        textColor: Color = Primitives.Colours.neutrals800,
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
