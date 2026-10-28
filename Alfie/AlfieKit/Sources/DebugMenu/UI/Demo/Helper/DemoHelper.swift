import SharedUI
import SwiftUI

public enum DemoHelper {
    public static func demoHeader(title: String) -> some View {
        DemoHeader(title: title)
    }

    public static func demoSectionHeader(title: String) -> some View {
        DemoSectionHeader(title: title)
    }
}

private struct DemoHeader: View {
    let title: String

    var body: some View {
        Text.build(theme.font.body.small(title))
    }
}

private struct DemoSectionHeader: View {
    let title: String

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            HStack {
                Text.build(theme.font.body.medium(title))
                Spacer()
            }
            ThemedDivider.horizontalThick
                .padding(.top, theme.sizing.spacingSpacingXs)
        }
    }
}
