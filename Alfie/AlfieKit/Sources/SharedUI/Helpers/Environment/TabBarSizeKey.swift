import SwiftUI

private struct TabBarSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

public extension EnvironmentValues {
    var tabBarSize: CGSize {
        get { self[TabBarSizeKey.self] }
        set { self[TabBarSizeKey.self] = newValue }
    }
}
