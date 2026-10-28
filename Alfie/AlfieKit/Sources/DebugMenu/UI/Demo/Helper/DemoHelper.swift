import SharedUI
import SwiftUI

public enum DemoHelper {
    public static func demoHeader(title: String) -> some View {
        Text.build(DesignSystem.shared.font.body.small(title))
    }

    public static func demoSectionHeader(title: String) -> some View {
        VStack(spacing: DesignSystem.shared.sizing.spacingSpacingNone) {
            HStack {
                Text.build(DesignSystem.shared.font.body.medium(title))
                Spacer()
            }
            ThemedDivider.horizontalThick
                .padding(.top, DesignSystem.shared.sizing.spacingSpacingXs)
        }
    }
}
