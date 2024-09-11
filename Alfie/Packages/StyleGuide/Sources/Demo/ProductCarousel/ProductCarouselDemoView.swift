import Models
import SwiftUI

struct ProductCarouselDemoView: View {
    var body: some View {
        VStack(spacing: Spacing.space0) {
            DemoHelper.demoSectionHeader(title: "Product Carousel")
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, Spacing.space400)

            ProductCarouselView(
                data: Product.fixtures,
                header: {
                    ProductCarouselHeader(
                        title: "New In",
                        subtitle: "Get a latest in fashion",
                        ctaTitle: "See All",
                        ctaStyle: .underline
                    )
                },
                content: { product in productCard(product) }
            )

            DemoHelper.demoSectionHeader(title: "Product Carousel - Left alignment / No action / No Progress Bar")
                .padding(.horizontal, Spacing.space200)
                .padding(.vertical, Spacing.space400)

            ProductCarouselView(
                data: Array(Product.fixtures.prefix(2)),
                header: {
                    ProductCarouselHeader(
                        title: "New In",
                        subtitle: "Get a latest in fashion"
                    )
                },
                content: { product in productCard(product) }
            )

            DemoHelper.demoSectionHeader(title: "Product Carousel - No description")
                .padding(.horizontal, Spacing.space200)
                .padding(.vertical, Spacing.space400)

            ProductCarouselView(
                data: Product.fixtures,
                header: {
                    ProductCarouselHeader(
                        title: "New In",
                        ctaTitle: "See All"
                    )
                },
                content: { product in productCard(product) }
            )
        }
    }

    @ViewBuilder
    private func productCard(_ product: Product) -> some View {
        VerticalProductCard(configuration: .init(size: .small), product: product) { _, _ in }
    }
}

#Preview {
    ScrollView {
        ProductCarouselDemoView()
    }
}
