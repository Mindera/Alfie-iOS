import SharedUI
import SwiftUI

@available(iOS 17.0, *)
struct PageControlCarouselDemoView: View {
    private var smallColors: [Color] {
        [theme.color.borderSoft, theme.color.borderMedium, theme.color.borderStrong, theme.color.contentContentTerciary]
    }
    private var mediumColors: [Color] {
        [
            theme.color.borderStrong,
            theme.color.contentContentNegative,
            theme.color.surfaceBackgroundDestructive,
            theme.color.contentContentPrimary,
        ]
    }
    private var largeColors: [Color] {
        [
            theme.color.surfaceForegroundPrimary,
            theme.color.contentContentTerciary,
            theme.color.contentContentSecondary,
            theme.color.contentContentPrimary,
        ]
    }
    private var customColors: [Color] {
        [
            theme.color.borderSoft,
            theme.color.contentContentPositive,
            theme.color.surfaceBackgroundPositive,
            theme.color.contentContentPrimary,
        ]
    }

    @State private var smallSelectedIndex: Int? = 0
    @State private var mediumSelectedIndex: Int? = 0
    @State private var largeSelectedIndex: Int? = 0
    @State private var customSelectedIndex: Int? = 0

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            colorCarouselComponent(
                title: "Progress Indicators - Small Dots",
                colorIndex: $smallSelectedIndex,
                size: 8,
                colors: smallColors
            )
            colorCarouselComponent(
                title: "Progress Indicators - Medium Dots",
                colorIndex: $mediumSelectedIndex,
                size: 12,
                colors: mediumColors
            )
            colorCarouselComponent(
                title: "Progress Indicators - Large Dots",
                colorIndex: $largeSelectedIndex,
                size: 16,
                colors: largeColors
            )
            VStack(spacing: theme.sizing.spacingSpacingNone) {
                DemoHelper.demoSectionHeader(title: "Progress Indicators - Custom Dots")
                    .padding(.bottom, theme.sizing.spacingSpacingXl)
                carousel(colorIndex: $customSelectedIndex, colors: customColors)
                ThemedPageControl(
                    data: customColors,
                    selectedIndex: .init(
                        get: { customSelectedIndex ?? 0 },
                        set: { customSelectedIndex = $0 }
                    ),
                    configuration: .init(spacing: 5)
                ) { _, isSelected in
                    let configuration = ThemedPageControlConfiguration(size: 16)
                    Rectangle()
                        .fill(isSelected ? configuration.selectedColor : configuration.color)
                        .frame(width: configuration.size, height: configuration.size)
                        .animation(.linear(duration: configuration.animationDuration), value: isSelected)
                }
            }
            Spacer()
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }

    private func carousel(colorIndex: Binding<Int?>, colors: [Color]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: theme.sizing.spacingSpacingNone) {
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
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            DemoHelper.demoSectionHeader(title: title)
                .padding(.bottom, theme.sizing.spacingSpacingXl)
            carousel(colorIndex: colorIndex, colors: colors)
            ThemedPageControl(
                data: colors,
                selectedIndex: Binding(colorIndex) ?? .constant(0),
                configuration: .init(size: size, spacing: 5)
            )
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PageControlCarouselDemoView()
}
