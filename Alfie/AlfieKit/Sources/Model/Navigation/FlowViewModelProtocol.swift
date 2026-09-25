import Combine
import Foundation
import SwiftUI

public protocol FlowViewModelProtocol: ObservableObject {
    associatedtype Route: Hashable

    var path: NavigationPath { get set }
    var overlayPublisher: AnyPublisher<TabOverlay?, Never> { get }

    func navigate(_ route: Route)
    func popToRoot()
    func pop()
    func dismissOverlay()
}

public extension FlowViewModelProtocol where Self: ObservableObject {
    var overlayPublisher: AnyPublisher<TabOverlay?, Never> { Empty<TabOverlay?, Never>().eraseToAnyPublisher() }

    func navigate(_ route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        path.removeLast()
    }

    func dismissOverlay() {}
}
