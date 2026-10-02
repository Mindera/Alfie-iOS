import SwiftUI

public struct TabOverlay {
    public let view: AnyView
    public let hidesTabBar: Bool

    public init(view: AnyView, hidesTabBar: Bool) {
        self.view = view
        self.hidesTabBar = hidesTabBar
    }
}
