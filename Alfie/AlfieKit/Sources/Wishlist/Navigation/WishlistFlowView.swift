import SwiftUI

public struct WishlistFlowView<ViewModel: WishlistFlowViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            WishlistView(viewModel: viewModel.makeWishlistViewModel(isRoot: true))
                .navigationDestination(for: WishlistRoute.self) { route in
                    route.destination(
                        accountViewModel: viewModel.makeAccountViewModel,
                        productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                        webViewModel: viewModel.makeWebViewModel(feature:),
                        wishlistViewModel: { viewModel.makeWishlistViewModel(isRoot: false) },
                        myAccountIntentViewBuilder: viewModel.myAccountIntentViewBuilder
                    )
                }
        }
    }
}
