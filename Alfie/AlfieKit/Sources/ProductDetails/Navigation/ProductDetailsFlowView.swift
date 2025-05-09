import SwiftUI

public struct ProductDetailsFlowView: View {
    @ObservedObject var viewModel: ProductDetailsFlowViewModel

    public init(viewModel: ProductDetailsFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ProductDetailsView2(viewModel: viewModel.makeProductDetailsViewModel())
                .navigationDestination(for: ProductDetailsRoute.self) { route in
                    route.destination(
                        productDetailsViewModel: viewModel.makeProductDetailsViewModel(productID:product:),
                        webViewModel: viewModel.makeWebViewModel(feature:)
                    )
                }
        }
    }
}
