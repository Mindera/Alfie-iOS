import Model
import SwiftUI
import Web

public extension ProductDetailsRoute {
    @ViewBuilder
    func destination(
        productDetailsViewModel: (ProductDetailsConfiguration) -> some ProductDetailsViewModelProtocol,
        webViewModel: (WebFeature) -> some WebViewModelProtocol
    ) -> some View {
        switch self {
        case .productDetails(let configuration):
            ProductDetailsView(viewModel: productDetailsViewModel(configuration))

        case .webFeature(let feature):
            WebView(viewModel: webViewModel(feature))
                .toolbarView(title: feature.title)
        }
    }
}
