import Model
import SwiftUI

public struct SizingSelectorComponentView: View {
    @ObservedObject private var configuration: ColorAndSizingSelectorConfiguration<SizingSwatch>
    private let layoutConfiguration: SwatchLayoutConfiguration

    public init(configuration: ColorAndSizingSelectorConfiguration<SizingSwatch>, layoutConfiguration: SwatchLayoutConfiguration) {
        self.configuration = configuration
        self.layoutConfiguration = layoutConfiguration
    }

    public var body: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        switch layoutConfiguration.arrangement {
        case .horizontal(let itemSpacing, let scrollable):
            horizontalSwatches(itemSpacing: itemSpacing, scrollable: scrollable)
        case .chips(let horizontalSpacing, let verticalSpacing):
            chipsSwatches(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
        case .grid(let columns, _):
            gridSwatches(columns: columns)
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private func gridSwatches(columns: Int) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: theme.spacing.space100), count: columns),
            spacing: theme.spacing.space100
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
            .padding(.bottom, Primitives.Spacing.spacing12)
        }
        .scrollDisabled(!scrollable)
    }

    @ViewBuilder
    private func swatches() -> some View {
        ForEach(configuration.items) { item in
            // A `Button`, not a tap gesture: the swatch is the only way to choose a size, and only a
            // button carries the trait, VoiceOver activation and Voice/Switch/keyboard reachability.
            Button {
                configuration.selectedItem = item
            } label: {
                SizingSwatchView(item: item, isSelected: configuration.selectedItem == item)
                    // The design draws a 40pt chip, 4pt under the minimum target. Outset the hit
                    // region rather than the frame, so the drawn box and the row gaps stay put.
                    .contentShape(Rectangle().inset(by: -theme.spacing.space025))
            }
            .buttonStyle(SizingSwatchButtonStyle())
            .disabled(item.state != .available)
        }
    }
}

/// Renders the label and nothing else. The built-in styles dim a disabled label, which would stack
/// on top of the dimming the design already specifies for unavailable sizes.
private struct SizingSwatchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview("Grid") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(id: "1", name: "XS", state: .available),
                .init(id: "2", name: "S", state: .outOfStock),
                .init(id: "3", name: "M", state: .available),
                .init(id: "4", name: "L", state: .available),
                .init(id: "5", name: "XL", state: .unavailable),
                .init(id: "6", name: "XXL", state: .outOfStock),
                .init(id: "7", name: "XXXL", state: .unavailable),
                .init(id: "8", name: "XXXXL", state: .available),
            ]
        ),
        layoutConfiguration: .init(arrangement: .grid(columns: 4))
    )
}

#Preview("Chips") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(id: "1", name: "XS", state: .available),
                .init(id: "2", name: "S", state: .outOfStock),
                .init(id: "3", name: "M", state: .available),
                .init(id: "4", name: "L", state: .available),
                .init(id: "5", name: "XL", state: .unavailable),
                .init(id: "6", name: "XXL", state: .outOfStock),
                .init(id: "7", name: "XXXL", state: .unavailable),
                .init(id: "8", name: "XXXXL", state: .available),
            ]
        ),
        layoutConfiguration: .init(
            arrangement: .chips(itemHorizontalSpacing: Primitives.Spacing.spacing16, itemVerticalSpacing: Primitives.Spacing.spacing16)
        )
    )
}

#Preview("Scrollable Single Row") {
    SizingSelectorComponentView(
        configuration: .init(
            selectedTitle: "Size:",
            items: [
                .init(id: "1", name: "XS", state: .available),
                .init(id: "2", name: "S", state: .outOfStock),
                .init(id: "3", name: "M", state: .available),
                .init(id: "4", name: "L", state: .available),
                .init(id: "5", name: "XL", state: .unavailable),
                .init(id: "6", name: "XXL", state: .outOfStock),
                .init(id: "7", name: "XXXL", state: .unavailable),
                .init(id: "8", name: "XXXXL", state: .available),
            ]
        ),
        layoutConfiguration: .init(arrangement: .horizontal(itemSpacing: Primitives.Spacing.spacing16))
    )
}
