import Model
import SwiftUI
import Web

public extension ProductDetailsRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (String, Product?) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2
    ) -> some View {
        switch self {
        case .productDetails(let productID, let product):
            ProductDetailsView2(viewModel: productDetailsViewModel(productID, product))

        case .webFeature(let feature):
            WebView2(viewModel: webViewModel(feature))
        }
    }
}
