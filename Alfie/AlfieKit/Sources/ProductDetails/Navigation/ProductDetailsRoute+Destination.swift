import Model
import SwiftUI
import Web

public extension ProductDetailsRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (ProductDetailsConfiguration2) -> some ProductDetailsViewModelProtocol2,
        webViewModel: (WebFeature) -> some WebViewModelProtocol2
    ) -> some View {
        switch self {
        case .productDetails(let configuration):
            ProductDetailsView2(viewModel: productDetailsViewModel(configuration))

        case .webFeature(let feature):
            WebView2(viewModel: webViewModel(feature))
        }
    }
}
