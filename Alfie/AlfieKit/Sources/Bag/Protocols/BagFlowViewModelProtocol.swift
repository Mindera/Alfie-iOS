import Foundation
import Model
import MyAccount
import ProductDetails
import SwiftUI

public protocol BagFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype BagViewModel: BagViewModelProtocol
    associatedtype AccountViewModel: AccountViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol
    associatedtype WishlistViewModel: WishlistViewModelProtocol

    func makeBagViewModel() -> BagViewModel
    func makeAccountViewModel() -> AccountViewModel
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
    func makeWishlistViewModel() -> WishlistViewModel
    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView
}
