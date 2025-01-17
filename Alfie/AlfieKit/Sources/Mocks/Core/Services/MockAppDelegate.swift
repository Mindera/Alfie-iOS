import Foundation
import Models

public class MockAppDelegate: NSObject, AppDelegateProtocol {
    public var onRebootAppCalled: (() -> Void)?
    public func rebootApp() {
        onRebootAppCalled?()
    }
}
