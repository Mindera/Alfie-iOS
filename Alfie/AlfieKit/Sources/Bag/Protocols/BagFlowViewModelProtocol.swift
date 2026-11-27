import Foundation
import Model
import ProductDetails
import SwiftUI

public protocol BagFlowViewModelProtocol: ObservableObject, FlowViewModelProtocol {
    associatedtype BagViewModel: BagViewModelProtocol
    associatedtype ProductDetailsViewModel: ProductDetailsViewModelProtocol
    associatedtype WebViewModel: WebViewModelProtocol

    func makeBagViewModel() -> BagViewModel
    func makeProductDetailsViewModel(configuration: ProductDetailsConfiguration) -> ProductDetailsViewModel
    func makeWebViewModel(feature: WebFeature) -> WebViewModel
}
