import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BagView<ViewModel: BagViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                Button(
                    action: { viewModel.didTapProduct(product) },
                    label: {
                        HorizontalProductCard(viewModel: viewModel.productCardViewModel(for: product))
                            .contentShape(Rectangle())
                    }
                )
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
            }
            .onDelete { offsets in
                for index in offsets.makeIterator() {
                    viewModel.didSelectDelete(for: viewModel.products[index])
                }
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal, Primitives.Spacing.spacing16)
        }
        .listStyle(.plain)
        .listRowSpacing(Primitives.Spacing.spacing16)
        .padding(.vertical, Primitives.Spacing.spacing16)
        .toolbarView(
            isWishlistEnabled: viewModel.isWishlistEnabled,
            openWishlistAction: viewModel.didTapWishlist,
            myAccountAction: viewModel.didTapMyAccount
        )
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

#if DEBUG
#Preview {
    BagView(
        viewModel: MockBagViewModel(
            products: [
                .init(product: Product.fixture())
            ]
        )
    )
}
#endif
