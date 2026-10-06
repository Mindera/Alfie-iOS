import Foundation
import Model
import ProductDetails
import SwiftUI

public protocol WishlistFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype WishlistViewModel: WishlistViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol

    func makeWishlistViewModel(isRoot: Bool) -> WishlistViewModel
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
}
