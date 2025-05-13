import SwiftUI

public struct BagFlowView: View {
    @ObservedObject var viewModel: BagFlowViewModel

    public init(viewModel: BagFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            BagView2(viewModel: viewModel.makeBagViewModel())
                .navigationDestination(for: BagRoute.self) { route in
                    route.destination(
                        bagViewModel: viewModel.makeBagViewModel,
                        accountViewModel: viewModel.makeAccountViewModel,
                        productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                        webViewModel: viewModel.makeWebViewModel(feature:),
                        wishlistViewModel: viewModel.makeWishlistViewModel,
                        myAccountIntentViewBuilder: viewModel.myAccountIntentViewBuilder
                    )
                }
        }
    }
}
