import Foundation
import Model

public class MockAppDelegate: NSObject, AppDelegateProtocol {
    public var onRebootAppCalled: (() -> Void)?
    public func rebootApp() {
        onRebootAppCalled?()
    }

    public var onApplyThemeCalled: ((String) -> Void)?
    public func applyTheme(id: String) {
        onApplyThemeCalled?(id)
    }
}
