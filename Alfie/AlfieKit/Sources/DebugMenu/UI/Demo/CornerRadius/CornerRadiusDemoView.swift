import SharedUI
import SwiftUI

struct CornerRadiusDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Rounded Corners")

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Spacing.space400) {
                    cornerRadiusView(label: "Soft", radius: CornerRadius.soft)
                    cornerRadiusView(label: "Strong", radius: CornerRadius.strong)
                    cornerRadiusView(label: "Rounded", radius: CornerRadius.rounded)
                }
                .padding(.bottom, Spacing.space400)

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Spacing.space400) {
                    cornerRadiusView(label: "Soft", radius: CornerRadius.soft, isSquare: true)
                    cornerRadiusView(label: "Strong", radius: CornerRadius.strong, isSquare: true)
                    cornerRadiusView(label: "Rounded", radius: CornerRadius.rounded, isSquare: true)
                }
                .padding(.bottom, Spacing.space400)

                DemoHelper.demoSectionHeader(title: "Nested Corners")

                Text.build(theme.font.small.normal("Inner: Soft, Outer: Strong"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.soft)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 200, height: 40)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.strong)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 220, height: 60)
                    )

                Spacer()
            }
            .padding(.horizontal, Spacing.space200)
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
