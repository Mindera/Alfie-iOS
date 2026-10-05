import SharedUI
import SwiftUI

struct BagDivider: View {
    var body: some View {
        ThemedDivider(configuration: .init(
            orientation: .horizontal,
            thickness: Sizing.borderBorderWeightDefault,
            color: Theme.borderSoft
        ))
        .accessibilityHidden(true)
    }
}
