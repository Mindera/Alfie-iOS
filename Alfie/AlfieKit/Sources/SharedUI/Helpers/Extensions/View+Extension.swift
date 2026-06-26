import SwiftUI

public extension View {
    // Always returns `DesignSystem.shared`. To honour an injected theme, declare
    // `@Environment(\.theme) var theme` in the view instead (it shadows this accessor).
    var theme: DesignSystemProtocol { DesignSystem.shared }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        whenTrue ifTransform: (Self) -> TrueContent,
        whenFalse elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    func runWithoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
