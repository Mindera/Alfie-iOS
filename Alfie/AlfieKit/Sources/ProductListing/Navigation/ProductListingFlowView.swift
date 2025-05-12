import SwiftUI

public struct ProductListingFlowView: View {
    @ObservedObject var viewModel: ProductListingFlowViewModel

    public init(viewModel: ProductListingFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ProductListingView2(viewModel: viewModel.makeProductListingViewModel())
                .navigationDestination(for: ProductListingRoute.self) { route in
                    route.destination(
                        productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                        webViewModel: viewModel.makeWebViewModel(feature:),
                        productListingViewModel: viewModel.makeProductListingViewModel(configuration:)
                    )
                }
        }
    }
}
