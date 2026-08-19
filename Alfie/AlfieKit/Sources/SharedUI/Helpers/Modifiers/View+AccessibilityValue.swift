import SwiftUI

extension View {
    /// Mirrors `accessibilityLabelOrHidden`: a state with nothing to announce leaves the value
    /// unset rather than setting it to an empty string.
    @ViewBuilder
    public func accessibilityValueOrNone(_ value: String?) -> some View {
        if let value {
            accessibilityValue(value)
        } else {
            self
        }
    }
}
