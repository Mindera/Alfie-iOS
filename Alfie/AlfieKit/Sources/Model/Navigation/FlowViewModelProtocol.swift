import Foundation
import SwiftUI

public protocol FlowViewModelProtocol: ObservableObject {
    associatedtype Route: Hashable
    var path: NavigationPath { get set }

    func navigate(_ route: Route)
    func popToRoot()
    func pop()
}

public extension FlowViewModelProtocol where Self: ObservableObject {
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
