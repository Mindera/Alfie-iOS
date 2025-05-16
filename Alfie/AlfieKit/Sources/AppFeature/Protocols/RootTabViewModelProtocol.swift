import Bag
import CategorySelector
import Foundation
import Home
import Model
import SwiftUI
import Wishlist

public protocol RootTabViewModelProtocol: ObservableObject {
    associatedtype BagFlowViewModel: BagFlowViewModelProtocol
    associatedtype CategorySelectorFlowViewModel: CategorySelectorFlowViewModelProtocol
    associatedtype HomeFlowViewModel: HomeFlowViewModelProtocol
    associatedtype WishlistFlowViewModel: WishlistFlowViewModelProtocol

    var tabs: [Model.Tab] { get }
    var selectedTab: Model.Tab { get set }
    var isOverlayVisible: Bool { get }
    var isReadyForNavigation: Bool { get set }
    var overlayView: AnyView? { get }

    var bagFlowViewModel: BagFlowViewModel { get }
    var categorySelectorFlowViewModel: CategorySelectorFlowViewModel { get }
    var homeFlowViewModel: HomeFlowViewModel { get }
    var wishlistFlowViewModel: WishlistFlowViewModel { get }

    func popToRoot(in tab: Model.Tab)
    func navigate(_ route: TabRoute)
}
