import SharedUI
import SwiftUI

struct ProgressBarDemoView: View {
    var body: some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
            DemoHelper.demoSectionHeader(title: "Progress Bar")
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing32)

            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing16),
                progressBarConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing64)
            ) {
                HStack {
                    ForEach(0..<40) { _ in
                        Rectangle()
                            .foregroundStyle(Primitives.Colours.neutrals400)
                            .cornerRadius(Sizing.radiusStrong)
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
