import SharedUI
import SwiftUI

public enum DemoHelper {
    public static func demoHeader(title: String) -> some View {
        Text.build(ThemeProvider.shared.font.body.small(title))
    }

    public static func demoSectionHeader(title: String) -> some View {
        VStack(spacing: Spacing.space0) {
            HStack {
                Text.build(ThemeProvider.shared.font.body.medium(title))
                Spacer()
            }
            ThemedDivider.horizontalThick
                .padding(.top, Spacing.space075)
        }
    }
}
