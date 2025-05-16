import Foundation
import Model
import MyAccount
import ProductDetails
import SwiftUI

public protocol WishlistFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype WishlistViewModel: WishlistViewModelProtocol
    associatedtype AccountViewModel: AccountViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol

    func makeWishlistViewModel(isRoot: Bool) -> WishlistViewModel
    func makeAccountViewModel() -> AccountViewModel
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
    func myAccountIntentViewBuilder(for intent: MyAccountIntent) -> AnyView
}
