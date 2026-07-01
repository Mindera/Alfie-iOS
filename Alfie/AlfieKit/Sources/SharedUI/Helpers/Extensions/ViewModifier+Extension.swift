import SwiftUI

public extension ViewModifier {
    // Always returns `DesignSystem.shared`. To honour an injected theme, declare
    // `@Environment(\.theme) var theme` in the view instead (it shadows this accessor).
    var theme: DesignSystemProtocol { DesignSystem.shared }
}
