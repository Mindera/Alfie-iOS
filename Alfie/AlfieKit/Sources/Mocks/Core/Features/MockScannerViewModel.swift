import Foundation
import Model
import SwiftUI

/// The copy here is placeholder, not shipped copy, and deliberately so: `SharedUI` depends on
/// `Mocks`, so `Mocks` cannot reach `L10n` without a dependency cycle. A caller that needs the real
/// wording — a snapshot test asserting a layout for text the app actually shows — passes it in.
public class MockScannerViewModel: ScannerViewModelProtocol {
    public var title: String
    @Published public var state: ViewState<ScannerViewStateModel, ScannerViewErrorType>
    /// A stand-in for the camera feed, so a preview or a test renders the chrome over something
    /// solid rather than over nothing.
    public var preview: AnyView
    public var guidance: String? { state.value?.guidance }
    public var notice: ScannerNotice? { state.value?.notice }

    public init(
        title: String = "Scan",
        state: ViewState<ScannerViewStateModel, ScannerViewErrorType> = .success(
            .init(guidance: "Point the camera at the Alfie code on the tag")
        ),
        preview: AnyView = AnyView(Color.gray)
    ) {
        self.title = title
        self.state = state
        self.preview = preview
    }

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

    public var onDidDismissNoticeCalled: (() -> Void)?
    public func didDismissNotice() {
        onDidDismissNoticeCalled?()
    }

    public var onDidTapOpenSettingsCalled: (() -> Void)?
    public func didTapOpenSettings() {
        onDidTapOpenSettingsCalled?()
    }
}
