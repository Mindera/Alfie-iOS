import Model
import SwiftUI
import ProductDetails
import Web

public extension ProductListingRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (String, Product?) -> some ProductDetailsViewModelProtocol2,
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

        case .search:
            Text("TBD: Search")
        }
    }
}
