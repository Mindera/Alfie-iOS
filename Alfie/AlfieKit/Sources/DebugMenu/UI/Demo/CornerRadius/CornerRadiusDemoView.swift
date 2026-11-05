import SharedUI
import SwiftUI

struct CornerRadiusDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingMd) {
                DemoHelper.demoSectionHeader(title: "Rounded Corners")

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: theme.sizing.spacingSpacingXl) {
                    cornerRadiusView(label: "Soft", radius: theme.sizing.radiusSoft)
                    cornerRadiusView(label: "Strong", radius: theme.sizing.radiusStrong)
                    cornerRadiusView(label: "Rounded", radius: theme.sizing.radiusRounded)
                }
                .padding(.bottom, theme.sizing.spacingSpacingXl)

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: theme.sizing.spacingSpacingXl) {
                    cornerRadiusView(label: "Soft", radius: theme.sizing.radiusSoft, isSquare: true)
                    cornerRadiusView(label: "Strong", radius: theme.sizing.radiusStrong, isSquare: true)
                    cornerRadiusView(label: "Rounded", radius: theme.sizing.radiusRounded, isSquare: true)
                }
                .padding(.bottom, theme.sizing.spacingSpacingXl)

                DemoHelper.demoSectionHeader(title: "Nested Corners")

                Text.build(theme.font.body.small("Inner: Soft, Outer: Strong"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.sizing.radiusSoft)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 200, height: 40)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.sizing.radiusStrong)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 220, height: 60)
                    )

                Spacer()
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
    }

    private func cornerRadiusView(label: String, radius: CGFloat, isSquare: Bool = false) -> some View {
        Text.build(theme.font.body.small(label))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: isSquare ? 70 : 90, height: isSquare ? 70 : 60)
            )
    }
}

#Preview {
    CornerRadiusDemoView()
}
