import Combine
import Foundation
import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI

public protocol CategorySelectorFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype CategoriesViewModel: CategoriesViewModelProtocol
    associatedtype BrandsViewModel: BrandsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol
    associatedtype AccountViewModel: AccountViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype ProductListingViewModel: ProductListingViewModelProtocol
    associatedtype WishlistViewModel: WishlistViewModelProtocol

    var isWishlistEnabled: Bool { get }
    var isStoreServicesEnabled: Bool { get }
    var activeShopTabPublisher: AnyPublisher<ShopViewTab, Never> { get }

    func makeCategoriesViewModel() -> CategoriesViewModel
    func makeBrandsViewModel() -> BrandsViewModel
    func makeServicesViewModel() -> WebViewModel
    func makeAccountViewModel() -> AccountViewModel
    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeProductListingViewModel(configuration: ProductListingScreenConfiguration) -> ProductListingViewModel
    func makeSubCategoriesViewModel(subCategories: [NavigationItem], parent: NavigationItem) -> CategoriesViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
    func makeURLWebViewModel(url: URL, title: String) -> WebViewModel
    func makeWishlistViewModel() -> WishlistViewModel

    func navigate(_ route: CategorySelectorRoute)
}
