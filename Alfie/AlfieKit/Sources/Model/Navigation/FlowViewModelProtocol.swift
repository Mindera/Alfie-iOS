import Combine
import Foundation
import SwiftUI

public protocol FlowViewModelProtocol: ObservableObject {
    associatedtype Route: Hashable

    var path: NavigationPath { get set }
    var overlayViewPublisher: AnyPublisher<AnyView?, Never> { get }

    func navigate(_ route: Route)
    func popToRoot()
    func pop()
}

public extension FlowViewModelProtocol where Self: ObservableObject {
    var overlayViewPublisher: AnyPublisher<AnyView?, Never> { Empty<AnyView?, Never>().eraseToAnyPublisher() }

    func navigate(_ route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        path.removeLast()
    }
}
