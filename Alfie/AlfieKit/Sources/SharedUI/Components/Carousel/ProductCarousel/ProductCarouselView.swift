import Model
import SwiftUI

public struct ProductCarouselView<Header: View, Content: View, DataType: Identifiable>: View {
    private let data: [DataType]
    private let header: () -> Header
    private let content: (DataType) -> Content

    public init(
        data: [DataType],
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping (DataType) -> Content
    ) {
        self.data = data
        self.header = header
        self.content = content
    }

    public var body: some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
            header()
                .padding(.horizontal, Primitives.Spacing.spacing16)
                .padding(.bottom, Primitives.Spacing.spacing16)
            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing16),
                progressBarConfiguration: .init(horizontalPadding: Primitives.Spacing.spacing16)
            ) {
                HStack(alignment: .top, spacing: Primitives.Spacing.spacing12) {
                    ForEach(data, id: \.id) { item in
                        content(item)
                    }
                }
            }
        }
        .padding(.vertical, Primitives.Spacing.spacing16)
    }
}

#Preview {
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
        content: { product in
            VerticalProductCard(viewModel: .init(configuration: .init(size: .small), product: product)) { _, _ in }
        }
    )
}
