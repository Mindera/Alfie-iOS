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
                    .padding(.bottom, Primitives.Spacing.spacing32)
                productCardListXS
                    .padding(.trailing, -Primitives.Spacing.spacing16)

                DemoHelper.demoSectionHeader(title: "Product Card - Small")
                    .padding(.bottom, Primitives.Spacing.spacing20)
                    .padding(.top, Primitives.Spacing.spacing8)
                productCardListS

                DemoHelper.demoSectionHeader(title: "Product Card - Medium")
                    .padding(.vertical, Primitives.Spacing.spacing20)
                productCardListMedium

                DemoHelper.demoSectionHeader(title: "Product Card - Large")
                    .padding(.vertical, Primitives.Spacing.spacing20)
                productCardListLarge
            }
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

extension ProductCardDemoView {
    private var productCardListXS: some View {
        VStack(alignment: .leading, spacing: Primitives.Spacing.spacing16) {
            ForEach(Product.fixtures) { product in
                HorizontalProductCard(viewModel: .init(product: product, colorTitle: "Color:", sizeTitle: "Size:"))
            }
        }
    }

    @ViewBuilder private var productCardListS: some View {
        ProgressableHorizontalScrollView(
            scrollViewConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing0),
            progressBarConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing64)
        ) {
            HStack(alignment: .top, spacing: Primitives.Spacing.spacing12) {
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
                repeating: GridItem(.flexible(), spacing: Primitives.Spacing.spacing16, alignment: .top),
                count: columns
            ),
            spacing: Primitives.Spacing.spacing16
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
                repeating: GridItem(.flexible(), spacing: Primitives.Spacing.spacing16, alignment: .top),
                count: columns
            ),
            spacing: Primitives.Spacing.spacing16
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
