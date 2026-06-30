import SharedUI
import SwiftUI

public enum DemoHelper {
    public static func demoHeader(title: String) -> some View {
        Text.build(DesignSystem.shared.font.body.small(title))
    }

    public static func demoSectionHeader(title: String) -> some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
            HStack {
                Text.build(DesignSystem.shared.font.body.medium(title))
                Spacer()
            }
            ThemedDivider.horizontalThick
                .padding(.top, Primitives.Spacing.spacing8)
        }
    }
}
