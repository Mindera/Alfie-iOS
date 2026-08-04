import SwiftUI

public struct CategorySelectorFlowView<ViewModel: CategorySelectorFlowViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ShopView(
                categoriesViewModel: viewModel.makeCategoriesViewModel(),
                didTapSearch: { viewModel.presentSearch() }
            )
            .navigationDestination(for: CategorySelectorRoute.self) { route in
                route.destination(
                    categoriesViewModel: viewModel.makeCategoriesViewModel,
                    accountViewModel: viewModel.makeAccountViewModel,
                    myAccountIntentViewBuilder: viewModel.myAccountIntentViewBuilder,
                    productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                    productListingViewModel: viewModel.makeProductListingViewModel(configuration:),
                    subCategoriesViewModel: viewModel.makeSubCategoriesViewModel(subCategories:parent:),
                    webViewModel: viewModel.makeWebViewModel(feature:),
                    urlWebViewModel: viewModel.makeURLWebViewModel(url:title:),
                    wishlistViewModel: viewModel.makeWishlistViewModel,
                    presentSearch: viewModel.presentSearch,
                    navigate: viewModel.navigate(_:)
                )
            }
        }
    }
}
