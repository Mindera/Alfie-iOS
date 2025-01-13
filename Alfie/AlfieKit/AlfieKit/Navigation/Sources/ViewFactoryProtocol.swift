import SwiftUI

public protocol ViewFactoryProtocol<Screen>: ObservableObject {
    associatedtype Screen: ScreenProtocol
    associatedtype ViewForScreen: View
    init()
    @ViewBuilder
    func view(for screen: Screen) -> ViewForScreen
}
