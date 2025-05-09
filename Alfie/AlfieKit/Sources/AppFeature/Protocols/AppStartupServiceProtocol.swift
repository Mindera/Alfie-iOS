import Foundation

public protocol AppStartupServiceProtocol: ObservableObject {
    var currentScreen: AppStartupScreen { get }
}
