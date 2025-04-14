import SwiftUI

struct CornerRadiusDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.space250) {
                DemoHelper.demoSectionHeader(title: "Rounded Corners")

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Spacing.space400) {
                    cornerRadiusView(label: "None", radius: CornerRadius.none)
                    cornerRadiusView(label: "XXS", radius: CornerRadius.xxs)
                    cornerRadiusView(label: "XS", radius: CornerRadius.xs)
                    cornerRadiusView(label: "S", radius: CornerRadius.s)
                    cornerRadiusView(label: "M", radius: CornerRadius.m)
                    cornerRadiusView(label: "L", radius: CornerRadius.l)
                    cornerRadiusView(label: "XL", radius: CornerRadius.xl)
                    cornerRadiusView(label: "Full", radius: CornerRadius.full)
                }
                .padding(.bottom, Spacing.space400)

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: Spacing.space400) {
                    cornerRadiusView(label: "None", radius: CornerRadius.none, isSquare: true)
                    cornerRadiusView(label: "XXS", radius: CornerRadius.xxs, isSquare: true)
                    cornerRadiusView(label: "XS", radius: CornerRadius.xs, isSquare: true)
                    cornerRadiusView(label: "S", radius: CornerRadius.s, isSquare: true)
                    cornerRadiusView(label: "M", radius: CornerRadius.m, isSquare: true)
                    cornerRadiusView(label: "L", radius: CornerRadius.l, isSquare: true)
                    cornerRadiusView(label: "XL", radius: CornerRadius.xl, isSquare: true)
                    cornerRadiusView(label: "Full", radius: CornerRadius.full, isSquare: true)
                }
                .padding(.bottom, Spacing.space400)

                DemoHelper.demoSectionHeader(title: "Nested Corners")

                Text.build(theme.font.small.normal("Inner: M, Outer: L"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.m)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 200, height: 40)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.l)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 220, height: 60)
                    )

                Text.build(theme.font.small.normal("Inner: XS, Outer: S"))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 200, height: 40)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.s)
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
