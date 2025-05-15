import Foundation
import Model
import MyAccount
import ProductDetails
import ProductListing
import SwiftUI

public protocol HomeFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype HomeViewModel: HomeViewModelProtocol
    associatedtype AccountViewModel: AccountViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol
    associatedtype ProductListingViewModel: ProductListingViewModelProtocol
    associatedtype WishlistViewModel: WishlistViewModelProtocol

    func makeHomeViewModel() -> HomeViewModel
    func makeAccountViewModel() -> AccountViewModel
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
    func makeProductListingViewModel(configuration: ProductListingScreenConfiguration) -> ProductListingViewModel
    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView
    func makeWishlistViewModelForMyAccount() -> WishlistViewModel
}
