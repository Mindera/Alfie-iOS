import SwiftUI

public struct CategorySelectorFlowView: View {
    @ObservedObject var viewModel: CategorySelectorFlowViewModel

    public init(viewModel: CategorySelectorFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            ShopView2(
                isRoot: true,
                isWishlistEnabled: viewModel.isWishlistEnabled,
                categoriesViewModel: viewModel.makeCategoriesViewModel(),
                brandsViewModel: viewModel.makeBrandsViewModel(),
                servicesViewModel: viewModel.isStoreServicesEnabled ? viewModel.makeServicesViewModel() : nil
            ) {
                viewModel.navigate($0)
            }
            .navigationDestination(for: CategorySelectorRoute.self) { route in
                route.destination(
                    isRoot: false,
                    isWishlistEnabled: viewModel.isWishlistEnabled,
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
