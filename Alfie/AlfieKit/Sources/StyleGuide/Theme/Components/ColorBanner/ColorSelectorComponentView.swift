import Models
import SwiftUI

public struct ColorSelectorComponentView: View {
    @ObservedObject private var configuration: ColorAndSizingSelectorConfiguration<ColorSwatch>
    private let layoutConfiguration: SwatchLayoutConfiguration
    private let swatchesSize: ColorSwatchView.SwatchSize
    private var frameSize: Binding<CGSize>?

    /// - Parameters:
    ///   - size: ReadOnly
    public init(
        configuration: ColorAndSizingSelectorConfiguration<ColorSwatch>,
        swatchesSize: ColorSwatchView.SwatchSize = .large,
        layoutConfiguration: SwatchLayoutConfiguration,
        frameSize: Binding<CGSize>? = nil
    ) {
        self.configuration = configuration
        self.swatchesSize = swatchesSize
        self.layoutConfiguration = layoutConfiguration
        self.frameSize = frameSize
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space150) {
            if !layoutConfiguration.hideOnSingleColor || configuration.items.count > 1 {
                container
            }
        }
    }

    @ViewBuilder private var container: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        switch layoutConfiguration.arrangement {
        case .horizontal(let itemSpacing, let scrollable):
            horizontalSwatches(itemSpacing: itemSpacing, scrollable: scrollable)
        case .chips(let horizontalSpacing, let verticalSpacing):
            chipsSwatches(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
        case .grid(let columns, let columnWidth):
            gridSwatches(columns: columns, columnWidth: columnWidth)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private func gridSwatches(columns: Int, columnWidth: CGFloat) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(minimum: columnWidth), alignment: .topLeading), count: columns)
        ) {
            swatches()
        }
    }

    private func chipsSwatches(horizontalSpacing: CGFloat, verticalSpacing: CGFloat) -> some View {
        ChipsStackLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            swatches()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func horizontalSwatches(itemSpacing: CGFloat, scrollable: Bool) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: itemSpacing) {
                swatches()
            }
            .padding(Spacing.space025)
            .writingSize(to: frameSize ?? .constant(.zero))
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(!scrollable)
    }

    @ViewBuilder
    private func swatches() -> some View {
        ForEach(configuration.items) { item in
            ColorSwatchView(item: item, swatchSize: swatchesSize, isSelected: configuration.selectedItem == item)
                .onTapGesture {
                    configuration.selectedItem = item
                }
        }
    }
}

#Preview("Grid") {
    ColorSelectorComponentView(
        configuration: .init(
            selectedTitle: "Color:",
            items: [
                .init(id: "1", name: "Black", type: .color(Colors.primary.black)),
                .init(id: "2", name: "Gray", type: .color(.gray)),
                .init(id: "3", name: "Red", type: .color(.red)),
                .init(id: "4", name: "Green", type: .color(.green)),
                .init(id: "5", name: "Blue", type: .color(.blue)),
                .init(id: "6", name: "Yellow", type: .color(.yellow)),
            ]
        ),
        layoutConfiguration: .init(arrangement: .grid(columns: 5, columnWidth: 44))
    )
}

#Preview("Grid - No title") {
    ColorSelectorComponentView(
        configuration: .init(
            selectedTitle: "Color:",
            items: [
                .init(id: "1", name: "Black", type: .color(Colors.primary.black)),
                .init(id: "2", name: "Gray", type: .color(.gray)),
                .init(id: "3", name: "Red", type: .color(.red)),
                .init(id: "4", name: "Green", type: .color(.green)),
                .init(id: "5", name: "Blue", type: .color(.blue)),
                .init(id: "6", name: "Yellow", type: .color(.yellow)),
            ]
        ),
        layoutConfiguration: .init(arrangement: .grid(columns: 5, columnWidth: 44), hideSelectionTitle: true)
    )
}

#Preview("Chips") {
    ColorSelectorComponentView(
        configuration: .init(
            selectedTitle: "Color:",
            items: [
                .init(id: "1", name: "Black", type: .color(Colors.primary.black)),
                .init(id: "2", name: "Gray", type: .color(.gray)),
                .init(id: "3", name: "Red", type: .color(.red)),
                .init(id: "4", name: "Green", type: .color(.green)),
                .init(id: "5", name: "Blue", type: .color(.blue)),
                .init(id: "6", name: "Yellow", type: .color(.yellow)),
            ]
        ),
        layoutConfiguration: .init(
            arrangement: .chips(itemHorizontalSpacing: Spacing.space200, itemVerticalSpacing: Spacing.space200)
        )
    )
}

#Preview("Scrollable Single Row") {
    ColorSelectorComponentView(
        configuration: .init(
            selectedTitle: "Color:",
            items: [
                .init(id: "1", name: "Black", type: .color(Colors.primary.black)),
                .init(id: "2", name: "Gray", type: .color(.gray)),
                .init(id: "3", name: "Red", type: .color(.red)),
                .init(id: "4", name: "Green", type: .color(.green)),
                .init(id: "5", name: "Blue", type: .color(.blue)),
                .init(id: "6", name: "Yellow", type: .color(.yellow)),
            ]
        ),
        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Spacing.space200))
    )
}
