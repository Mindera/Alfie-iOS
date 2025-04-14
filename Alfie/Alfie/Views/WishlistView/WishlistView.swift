import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct WishlistView<ViewModel: WishlistViewModelProtocol>: View {
    @EnvironmentObject var coordinador: Coordinator
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top),
                    count: 2
                ),
                spacing: Spacing.space200
            ) {
                ForEach(viewModel.products) { product in
                    Button(
                        action: { coordinador.openDetails(for: product) },
                        label: {
                            VerticalProductCard(
                                viewModel: viewModel.productCardViewModel(for: product)
                            ) { _, type in
                                handleUserAction(forProduct: product, actionType: type)
                            }
                        }
                    )
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                }
            }
            .padding(.horizontal, Spacing.space200)
        }
        .padding(.vertical, Spacing.space200)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

// MARK: - Private Methods

private extension WishlistView {
    func handleUserAction(forProduct product: SelectedProduct, actionType: VerticalProductCard.ProductUserActionType) {
        // swiftlint:disable vertical_whitespace_between_cases
        switch actionType {
        case .remove:
            viewModel.didSelectDelete(for: product)
        case .addToBag:
            viewModel.didTapAddToBag(for: product)
        case .wishlist:
            return
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

#if DEBUG
#Preview {
    WishlistView(
        viewModel: WishlistViewModel(
            dependencies: WishlistDependencyContainer(
                wishlistService: MockWishlistService(),
                bagService: MockBagService(),
                analytics: MockAnalyticsTracker().eraseToAnyAnalyticsTracker()
            )
        )
    )
        .environmentObject(Coordinator())
}
#endif
