import SharedUI
import SwiftUI

struct BagDivider: View {
    var body: some View {
        ThemedDivider(configuration: .init(
            orientation: .horizontal,
            thickness: theme.sizing.borderBorderWeightDefault,
            color: theme.color.borderSoft
        ))
        .accessibilityHidden(true)
    }
}
