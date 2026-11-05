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
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            header()
                .padding(.horizontal, theme.sizing.spacingSpacingMd)
                .padding(.bottom, theme.sizing.spacingSpacingMd)
            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacingMd),
                progressBarConfiguration: .init(horizontalPadding: theme.sizing.spacingSpacingMd)
            ) {
                HStack(alignment: .top, spacing: theme.sizing.spacingSpacingSm) {
                    ForEach(data, id: \.id) { item in
                        content(item)
                    }
                }
            }
        }
        .padding(.vertical, theme.sizing.spacingSpacingMd)
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
