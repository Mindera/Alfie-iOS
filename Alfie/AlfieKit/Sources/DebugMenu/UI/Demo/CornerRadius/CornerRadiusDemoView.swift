import SharedUI
import SwiftUI

struct CornerRadiusDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Primitives.Spacing.spacing20) {
                DemoHelper.demoSectionHeader(title: "Rounded Corners")

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Primitives.Spacing.spacing32) {
                    cornerRadiusView(label: "Soft", radius: Sizing.radiusSoft)
                    cornerRadiusView(label: "Strong", radius: Sizing.radiusStrong)
                    cornerRadiusView(label: "Rounded", radius: Sizing.radiusRounded)
                }
                .padding(.bottom, Primitives.Spacing.spacing32)

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Primitives.Spacing.spacing32) {
                    cornerRadiusView(label: "Soft", radius: Sizing.radiusSoft, isSquare: true)
                    cornerRadiusView(label: "Strong", radius: Sizing.radiusStrong, isSquare: true)
                    cornerRadiusView(label: "Rounded", radius: Sizing.radiusRounded, isSquare: true)
                }
                .padding(.bottom, Primitives.Spacing.spacing32)

                DemoHelper.demoSectionHeader(title: "Nested Corners")

                Text.build(theme.font.small.normal("Inner: Soft, Outer: Strong"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: Sizing.radiusSoft)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 200, height: 40)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Sizing.radiusStrong)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 220, height: 60)
                    )

                Spacer()
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
    }

    private func cornerRadiusView(label: String, radius: CGFloat, isSquare: Bool = false) -> some View {
        Text.build(theme.font.small.normal(label))
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
