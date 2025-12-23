import Model
import ProductDetails
import SwiftUI
import Web

public extension ProductListingRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol,
        productListingViewModel: (ProductListingScreenConfiguration) -> some ProductListingViewModelProtocol
    ) -> some View {
        switch self {
        case .productDetails(let productDetailsRoute):
            productDetailsRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel
            )

        case .productListing(let configuration):
            ProductListingView(viewModel: productListingViewModel(configuration))
        }
    }
}
