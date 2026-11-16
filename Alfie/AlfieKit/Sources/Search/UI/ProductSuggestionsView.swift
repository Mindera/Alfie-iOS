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
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingMd) {
                Text.build(theme.font.heading.small(L10n.Search.Screen.SuggestionsProducts.Header.title))
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: columns, spacing: theme.sizing.spacingSpacingMd) {
                    ForEach(products) { product in
                        VerticalProductCard(viewModel: cardViewModel(for: product)) { _, _ in }
                            .fixedSize(horizontal: false, vertical: true)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(product) }
                            .accessibilityAddTraits(.isButton)
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
            .padding(theme.sizing.spacingSpacingMd)
        }
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
