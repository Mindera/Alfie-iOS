import Models
import SwiftUI

struct ProductCardDemoView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var orientation = UIDeviceOrientation.unknown

    var body: some View {
        ScrollView {
            VStack {
                DemoHelper.demoSectionHeader(title: "Product Card - XS")
                    .padding(.bottom, Spacing.space400)
                productCardListXS
                    .padding(.trailing, -Spacing.space200)

                DemoHelper.demoSectionHeader(title: "Product Card - Small")
                    .padding(.bottom, Spacing.space250)
                    .padding(.top, Spacing.space100)
                productCardListS

                DemoHelper.demoSectionHeader(title: "Product Card - Medium")
                    .padding(.vertical, Spacing.space250)
                productCardListMedium

                DemoHelper.demoSectionHeader(title: "Product Card - Large")
                    .padding(.vertical, Spacing.space250)
                productCardListLarge
            }
            .padding(.horizontal, Spacing.space200)
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}

extension ProductCardDemoView {
    private var productCardListXS: some View {
        VStack(alignment: .leading, spacing: Spacing.space200) {
            ForEach(Product.fixtures) { product in
                HorizontalProductCard(viewModel: .init(product: product, colorTitle: "Color:", sizeTitle: "Size:"))
            }
        }
    }

    @ViewBuilder private var productCardListS: some View {
        ProgressableHorizontalScrollView(
            scrollViewConfiguration: .init(horizontalPadding: Spacing.space0),
            progressBarConfiguration: .init(horizontalPadding: Spacing.space800)
        ) {
            HStack(alignment: .top, spacing: Spacing.space150) {
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
                repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                count: columns
            ),
            spacing: Spacing.space200
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
                repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                count: columns
            ),
            spacing: Spacing.space200
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
