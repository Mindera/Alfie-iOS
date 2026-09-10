import Foundation
import Model
import SwiftUI

public class MockScannerViewModel: ScannerViewModelProtocol {
    public var title: String = "Scan"
    public var guidance: String = "Point the camera at the Alfie code on the tag"
    /// A stand-in for the camera feed, so a preview or a test renders the chrome over something
    /// solid rather than over nothing.
    public var preview: AnyView = AnyView(Color.gray)

    public init() { }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }

    public var onViewDidDisappearCalled: (() -> Void)?
    public func viewDidDisappear() {
        onViewDidDisappearCalled?()
    }

    public var onDidChangeScenePhaseCalled: ((Bool) -> Void)?
    public func didChangeScenePhase(isActive: Bool) {
        onDidChangeScenePhaseCalled?(isActive)
    }

    public var onDidTapCloseCalled: (() -> Void)?
    public func didTapClose() {
        onDidTapCloseCalled?()
    }
}
