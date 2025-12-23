import Search
import SwiftUI

public struct HomeFlowView<ViewModel: HomeFlowViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            HomeView(viewModel: viewModel.makeHomeViewModel())
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
