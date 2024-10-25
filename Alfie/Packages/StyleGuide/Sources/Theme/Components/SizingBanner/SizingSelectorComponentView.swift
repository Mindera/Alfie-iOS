import Models
import SwiftUI

public struct SizingSelectorComponentView: View {
    @ObservedObject private var configuration: SizingSelectorConfiguration
    private let layoutConfiguration: SwatchLayoutConfiguration

    public init(configuration: SizingSelectorConfiguration,
                layoutConfiguration: SwatchLayoutConfiguration) {
        self.configuration = configuration
        self.layoutConfiguration = layoutConfiguration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space150) {
            header

            if configuration.items.count > 1 {
                container
            }
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.space050) {
            Text.build(theme.font.paragraph.normal(configuration.selectedTitle))
                .foregroundStyle(Colors.primary.mono400)
            Text.build(theme.font.paragraph.normal(configuration.selectedItem?.name ?? ""))
                .foregroundStyle(Colors.primary.mono900)
        }
    }

    @ViewBuilder
    private var container: some View {
        switch layoutConfiguration.arrangement {
            case .horizontal(let itemSpacing, let scrollable):
                horizontalSwatches(itemSpacing: itemSpacing, scrollable: scrollable)
            case .chips(let horizontalSpacing, let verticalSpacing):
                chipsSwatches(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
            case .grid(let columns, let columnWidth):
                gridSwatches(columns: columns, columnWidth: columnWidth)
        }
    }

    private func gridSwatches(columns: Int, columnWidth: CGFloat) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns)) {
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
            .padding(.bottom, Spacing.space150)
        }
        .scrollDisabled(!scrollable)
    }

    @ViewBuilder
    private func swatches() -> some View {
        ForEach(configuration.items) { item in
            Group {
                SizingSwatchView(item: item, isSelected: configuration.selectedItem == item)
                    .onTapGesture {
                        configuration.selectedItem = item
                    }
            }
            .disabled(item.state != .available)
        }
    }
}

#Preview("Grid") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(name: "XS", state: .available),
                .init(name: "S", state: .outOfStock),
                .init(name: "M", state: .available),
                .init(name: "L", state: .available),
                .init(name: "XL", state: .unavailable),
                .init(name: "XXL", state: .outOfStock),
                .init(name: "XXXL", state: .unavailable),
                .init(name: "XXXXL", state: .available),
            ]),
        layoutConfiguration: .init(arrangement: .grid(columns: 4, columnWidth: 50))
    )
}

#Preview("Chips") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(name: "XS", state: .available),
                .init(name: "S", state: .outOfStock),
                .init(name: "M", state: .available),
                .init(name: "L", state: .available),
                .init(name: "XL", state: .unavailable),
                .init(name: "XXL", state: .outOfStock),
                .init(name: "XXXL", state: .unavailable),
                .init(name: "XXXXL", state: .available),
            ]),
        layoutConfiguration: .init(arrangement: .chips(
            itemHorizontalSpacing: Spacing.space200,
            itemVerticalSpacing: Spacing.space200))
    )
}

#Preview("Scrollable Single Row") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(name: "XS", state: .available),
                .init(name: "S", state: .outOfStock),
                .init(name: "M", state: .available),
                .init(name: "L", state: .available),
                .init(name: "XL", state: .unavailable),
                .init(name: "XXL", state: .outOfStock),
                .init(name: "XXXL", state: .unavailable),
                .init(name: "XXXXL", state: .available),
            ]),
        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Spacing.space200))
    )
}
