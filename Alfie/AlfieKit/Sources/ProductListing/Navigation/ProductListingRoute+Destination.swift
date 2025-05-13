import Model
import ProductDetails
import SwiftUI
import Web

public extension ProductListingRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (ProductDetailsConfiguration2) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2,
        productListingViewModel: (ProductListingScreenConfiguration2) -> some ProductListingViewModelProtocol2
    ) -> some View {
        switch self {
        case .productDetails(let productDetailsRoute):
            productDetailsRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel
            )

        case .productListing(let configuration):
            ProductListingView2(viewModel: productListingViewModel(configuration))
        }
    }
}
