import SwiftUI

public struct CategorySelectorFlowView<ViewModel: CategorySelectorFlowViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ShopView(
                isRoot: true,
                isWishlistEnabled: viewModel.isWishlistEnabled,
                categoriesViewModel: viewModel.makeCategoriesViewModel(),
                brandsViewModel: viewModel.makeBrandsViewModel(),
                servicesViewModel: viewModel.isStoreServicesEnabled ? viewModel.makeServicesViewModel() : nil,
                activeShopTabPublisher: viewModel.activeShopTabPublisher
            ) {
                viewModel.navigate($0)
            }
            .navigationDestination(for: CategorySelectorRoute.self) { route in
                route.destination(
                    isRoot: false,
                    isWishlistEnabled: viewModel.isWishlistEnabled,
                    activeShopTabPublisher: viewModel.activeShopTabPublisher,
                    categoriesViewModel: viewModel.makeCategoriesViewModel,
                    brandsViewModel: viewModel.makeBrandsViewModel,
                    isStoreServicesEnabled: viewModel.isStoreServicesEnabled,
                    servicesViewModel: viewModel.makeServicesViewModel,
                    accountViewModel: viewModel.makeAccountViewModel,
                    myAccountIntentViewBuilder: viewModel.myAccountIntentViewBuilder,
                    productDetailsViewModel: viewModel.makeProductDetailsViewModel(configuration:),
                    productListingViewModel: viewModel.makeProductListingViewModel(configuration:),
                    subCategoriesViewModel: viewModel.makeSubCategoriesViewModel(subCategories:parent:),
                    webViewModel: viewModel.makeWebViewModel(feature:),
                    urlWebViewModel: viewModel.makeURLWebViewModel(url:title:),
                    wishlistViewModel: viewModel.makeWishlistViewModel,
                    navigate: viewModel.navigate(_:)
                )
            }
        }
    }
}
