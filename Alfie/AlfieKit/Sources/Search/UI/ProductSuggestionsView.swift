import AccessibilityIdentifiers
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct ProductSuggestionsView: View {
    private let products: [ProductSuggestion]
    private let onSelect: (ProductSuggestion) -> Void
    private let onMoreProducts: () -> Void

    init(
        products: [ProductSuggestion],
        onSelect: @escaping (ProductSuggestion) -> Void,
        onMoreProducts: @escaping () -> Void
    ) {
        self.products = products
        self.onSelect = onSelect
        self.onMoreProducts = onMoreProducts
    }

    var body: some View {
        VStack(spacing: theme.sizing.spacingSpacingMd) {
            SearchSectionHeader(title: L10n.Search.Screen.SuggestionsProducts.Header.title)

            LazyVGrid(columns: columns, spacing: theme.sizing.spacingSpacingMd) {
                ForEach(products) { product in
                    Button(action: { onSelect(product) }, label: {
                        VerticalProductCard(viewModel: cardViewModel(for: product)) { _, _ in }
                            .fixedSize(horizontal: false, vertical: true)
                            .contentShape(Rectangle())
                    })
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(AccessibilityID.Search.productSuggestion(id: product.id))
                }
            }

            ThemedButton(
                text: L10n.Search.Screen.Suggestions.More.Button.cta,
                style: .secondary,
                action: onMoreProducts
            )
            .accessibilityIdentifier(AccessibilityID.Search.moreProductsButton)
        }
        .padding(.horizontal, theme.sizing.spacingSpacingMd)
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: theme.sizing.spacingSpacingXs, alignment: .top),
            count: Constants.columnCount
        )
    }

    private func cardViewModel(for product: ProductSuggestion) -> VerticalProductCardViewModel {
        VerticalProductCardViewModel(
            configuration: .init(size: .medium, hidePrice: product.price == nil, hideAction: true),
            productId: product.id,
            image: product.imageURL,
            designer: product.brandName ?? "",
            name: product.name,
            priceType: .default(price: product.price?.amountFormatted ?? "")
        )
    }
}

private enum Constants {
    static let columnCount = 2
}

#if DEBUG
#Preview {
    ProductSuggestionsView(
        products: [
            .fixture(id: "1"),
            .fixture(id: "2", brandName: nil),
            .fixture(id: "3", price: nil),
        ],
        onSelect: { _ in },
        onMoreProducts: {}
    )
}
#endif
