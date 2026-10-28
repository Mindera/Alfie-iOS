import Model
import SharedUI
import SwiftUI

struct ProductCardDemoView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var orientation = UIDeviceOrientation.unknown

    var body: some View {
        ScrollView {
            VStack {
                DemoHelper.demoSectionHeader(title: "Product Card - XS")
                    .padding(.bottom, theme.sizing.spacingSpacingXl)
                productCardListXS
                    .padding(.trailing, -theme.sizing.spacingSpacingMd)

                DemoHelper.demoSectionHeader(title: "Product Card - Small")
                    .padding(.bottom, theme.sizing.spacingSpacingMd)
                    .padding(.top, theme.sizing.spacingSpacingXs)
                productCardListS

                DemoHelper.demoSectionHeader(title: "Product Card - Medium")
                    .padding(.vertical, theme.sizing.spacingSpacingMd)
                productCardListMedium

                DemoHelper.demoSectionHeader(title: "Product Card - Large")
                    .padding(.vertical, theme.sizing.spacingSpacingMd)
                productCardListLarge
            }
            .padding(.horizontal, theme.sizing.spacingSpacingMd)
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

extension ProductCardDemoView {
    private var productCardListXS: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingMd) {
            ForEach(Product.fixtures) { product in
                HorizontalProductCard(viewModel: .init(product: product, colorTitle: "Color:", sizeTitle: "Size:"))
            }
        }
    }

    @ViewBuilder private var productCardListS: some View {
        ProgressableHorizontalScrollView(
            scrollViewConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacingNone),
            progressBarConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacing2xl)
        ) {
            HStack(alignment: .top, spacing: theme.sizing.spacingSpacingSm) {
                ForEach(Product.fixtures) { product in
                    VerticalProductCard(
                        viewModel: .init(configuration: .init(size: .small), product: product)
                    ) { _, _ in }
                }
            }
        }
    }

    @ViewBuilder private var productCardListMedium: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        let columns = switch horizontalSizeClass {
        case .regular:
            orientation.isLandscape ? 4 : 3
        default:
            2
        }
        // swiftlint:enable vertical_whitespace_between_cases
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: theme.sizing.spacingSpacingMd, alignment: .top),
                count: columns
            ),
            spacing: theme.sizing.spacingSpacingMd
        ) {
            ForEach(Product.fixtures) { product in
                VerticalProductCard(viewModel: .init(configuration: .init(size: .medium), product: product)) { _, _ in }
            }
        }
    }

    @ViewBuilder private var productCardListLarge: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        let columns = switch horizontalSizeClass {
        case .regular:
            orientation.isLandscape ? 3 : 2
        default:
            1
        }
        // swiftlint:enable vertical_whitespace_between_cases
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: theme.sizing.spacingSpacingMd, alignment: .top),
                count: columns
            ),
            spacing: theme.sizing.spacingSpacingMd
        ) {
            ForEach(Product.fixtures) { product in
                VerticalProductCard(viewModel: .init(configuration: .init(size: .large), product: product)) { _, _ in }
            }
        }
    }
}

#Preview {
    ProductCardDemoView()
}
