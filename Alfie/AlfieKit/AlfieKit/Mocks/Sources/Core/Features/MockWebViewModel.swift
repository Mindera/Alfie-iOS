import Foundation
import Models

public class MockWebViewModel: WebViewModelProtocol {
    public var state: WebViewState
    public var shouldReload: Bool = false
    public var shouldNavigateBack: Bool = false
    public var title: String = ""

    public init(state: WebViewState = .empty) {
        self.state = state
    }

    public var onViewDidAppearCalled: (() -> Void)?
    public func viewDidAppear() {
        onViewDidAppearCalled?()
    }
    
    public var onWebViewStartedCalled: (() -> Void)?
    public func webViewStarted() {
        onWebViewStartedCalled?()
    }
    
    public var onWebViewFailedCalled: (() -> Void)?
    public func webViewFailed() {
        onWebViewFailedCalled?()
    }
    
    public var onWebViewFinishedCalled: (() -> Void)?
    public func webViewFinished() {
        onWebViewFinishedCalled?()
    }
    
    public var onTryAgainCalled: (() -> Void)?
    public func tryAgain() {
        onTryAgainCalled?()
    }
    
    public var onCanOpenUrlCalled: ((URL) -> Bool)?
    public func canOpenUrl(_ url: URL) -> Bool {
        onCanOpenUrlCalled?(url) ?? false
    }
    
    public var onHandleLinkCalled: ((URL) -> Void)?
    public func handleLink(withUrl url: URL) {
        onHandleLinkCalled?(url)
    }
    
    public var onWebViewUrlChangedCalled: ((URL) -> Void)?
    public func webViewUrlChanged(_ url: URL) {
        onWebViewUrlChangedCalled?(url)
    }
}
