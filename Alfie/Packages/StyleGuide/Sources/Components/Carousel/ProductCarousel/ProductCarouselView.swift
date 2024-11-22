import Models
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
        VStack(spacing: Spacing.space0) {
            header()
                .padding(.horizontal, Spacing.space200)
                .padding(.bottom, Spacing.space200)
            ProgressableHorizontalScrollView(
                scrollViewConfiguration: .init(horizontalPadding: Spacing.space200),
                progressBarConfiguration: .init(horizontalPadding: Spacing.space200)
            ) {
                HStack(alignment: .top, spacing: Spacing.space150) {
                    ForEach(data, id: \.id) { item in
                        content(item)
                    }
                }
            }
        }
        .padding(.vertical, Spacing.space200)
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
