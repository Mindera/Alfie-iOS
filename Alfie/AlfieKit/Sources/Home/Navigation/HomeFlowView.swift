import Search
import SwiftUI

public struct HomeFlowView: View {
    @ObservedObject var viewModel: HomeFlowViewModel

    public init(viewModel: HomeFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            HomeView2(viewModel: viewModel.makeHomeViewModel())
                .navigationDestination(for: HomeRoute.self) { route in
                    route.destination(
                        homeViewModel: viewModel.makeHomeViewModel,
                        accountViewModel: viewModel.makeAccountViewModel,
                        productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                        webViewModel: viewModel.makeWebViewModel(feature:),
                        productListingViewModel: viewModel.makeProductListingViewModel(configuration:),
                        myAccountIntentViewBuilder: viewModel.myAccountIntentViewBuilder(for:),
                        wishlistViewModel: viewModel.makeWishlistViewModelForMyAccount
                    )
                }
        }
    }
}
