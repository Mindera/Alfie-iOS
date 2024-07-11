import Foundation
import SwiftUI

public protocol CoordinatorProtocol: ObservableObject {
    associatedtype Screen: ScreenProtocol
    init(navigationAdapter: NavigationAdapter<Screen>)
}
