import SwiftUI

@available(iOS 17.0, *)
struct PageControlCarouselDemoView: View {
    private let smallColors: [Color] = [
        Colors.primary.mono200,
        Colors.primary.mono300,
        Colors.primary.mono400,
        Colors.primary.mono500,
    ]
    private let mediumColors: [Color] = [
        Colors.secondary.orange200,
        Colors.secondary.orange300,
        Colors.secondary.orange400,
        Colors.secondary.orange500,
    ]
    private let largeColors: [Color] = [
        Colors.secondary.blue200,
        Colors.secondary.blue300,
        Colors.secondary.blue400,
        Colors.secondary.blue500,
    ]
    private let customColors: [Color] = [
        Colors.secondary.green200,
        Colors.secondary.green300,
        Colors.secondary.green400,
        Colors.secondary.green500,
    ]

    @State private var smallSelectedIndex: Int? = 0
    @State private var mediumSelectedIndex: Int? = 0
    @State private var largeSelectedIndex: Int? = 0
    @State private var customSelectedIndex: Int? = 0

    var body: some View {
        VStack(spacing: Spacing.space250) {
            colorCarouselComponent(title: "Progress Indicators - Small Dots", colorIndex: $smallSelectedIndex, size: 8, colors: smallColors)
            colorCarouselComponent(title: "Progress Indicators - Medium Dots", colorIndex: $mediumSelectedIndex, size: 12, colors: mediumColors)
            colorCarouselComponent(title: "Progress Indicators - Large Dots", colorIndex: $largeSelectedIndex, size: 16, colors: largeColors)
            VStack(spacing: Spacing.space0) {
                DemoHelper.demoSectionHeader(title: "Progress Indicators - Custom Dots")
                    .padding(.bottom, Spacing.space400)
                carousel(colorIndex: $customSelectedIndex, colors: customColors)
                ThemedPageControl(data: customColors,
                                  selectedIndex: .init(
                                    get: { customSelectedIndex ?? 0 },
                                    set: { customSelectedIndex = $0 }),
                                  configuration: .init(spacing: 5), customControl: { _, isSelected in
                    let configuration = ThemedPageControlConfiguration(size: 16)
                    Rectangle()
                        .fill(isSelected ? configuration.selectedColor : configuration.color)
                        .frame(width: configuration.size, height: configuration.size)
                        .animation(.linear(duration: configuration.animationDuration),
                                   value: isSelected)
                })
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.space200)
    }

    private func carousel(colorIndex: Binding<Int?>, colors: [Color]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.space0) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    color
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition(.animated, axis: .horizontal) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0.8)
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 50)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: colorIndex)
    }

    private func colorCarouselComponent(title: String, colorIndex: Binding<Int?>, size: CGFloat, colors: [Color]) -> some View {
        VStack(spacing: Spacing.space0) {
            DemoHelper.demoSectionHeader(title: title)
                .padding(.bottom, Spacing.space400)
            carousel(colorIndex: colorIndex, colors: colors)
            ThemedPageControl(data: colors,
                              selectedIndex: Binding(colorIndex) ?? .constant(0),
                              configuration: .init(size: size, spacing: 5))
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PageControlCarouselDemoView()
}
