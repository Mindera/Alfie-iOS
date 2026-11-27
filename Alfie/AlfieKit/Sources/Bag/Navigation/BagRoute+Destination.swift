import Model
import ProductDetails
import SwiftUI
import Web

public extension BagRoute {
    @ViewBuilder
    func destination(
        bagViewModel: () -> some BagViewModelProtocol,
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol
    ) -> some View {
        switch self {
        case .bag:
            BagView(viewModel: bagViewModel())

        case .productDetails(let productDetailsRoute):
            productDetailsRoute.destination(
                productDetailsViewModel: productDetailsViewModel,
                webViewModel: webViewModel
            )
        }
    }
}
