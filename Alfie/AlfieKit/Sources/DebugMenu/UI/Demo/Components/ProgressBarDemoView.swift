import SharedUI
import SwiftUI

struct ProgressBarDemoView: View {
    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            DemoHelper.demoSectionHeader(title: "Progress Bar")
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingXl)

            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacingMd),
                progressBarConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacing2xl)
            ) {
                HStack {
                    ForEach(0..<40) { _ in
                        Rectangle()
                            .foregroundStyle(theme.color.borderStrong)
                            .cornerRadius(theme.sizing.radiusStrong)
                            .frame(width: 120, height: 120)
                    }
                }
            }

            Spacer()
        }
    }
}

#Preview {
    ProgressBarDemoView()
}
