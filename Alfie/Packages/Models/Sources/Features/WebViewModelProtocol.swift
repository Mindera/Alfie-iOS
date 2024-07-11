import SwiftUI

public enum WebViewState {
    case empty
    case ready(URL)
    case loading
    case loaded
    case needsNavigation(WebViewNavigationOperation)
    case error(WebViewErrorType)
}

public extension WebViewState {
    var url: URL? {
        guard case let .ready(url) = self else {
            return nil
        }
        return url
    }

    var isEmpty: Bool {
        guard case .empty = self else {
            return false
        }
        return true
    }

    var isLoading: Bool {
        guard case .loading = self else {
            return false
        }
        return true
    }

    var isLoaded: Bool {
        guard case .loaded = self else {
            return false
        }
        return true
    }

    var isReady: Bool {
        guard case .ready = self else {
            return false
        }
        return true
    }

    var didFail: Bool {
        guard case .error = self else {
            return false
        }
        return true
    }

    var failure: WebViewErrorType? {
        guard case let .error(type) = self else {
            return nil
        }
        return type
    }

    var navigationOperation: WebViewNavigationOperation? {
        guard case let .needsNavigation(operation) = self else {
            return nil
        }
        return operation
    }
}

public enum WebViewErrorType: Error {
    case noUrl
    case generic
}

public enum WebViewNavigationOperation {
    case back
}

public protocol WebViewModelProtocol: ObservableObject {
    var state: WebViewState { get }
    var shouldNavigateBack: Bool { get }
    var title: String { get }

    func viewDidAppear()
    func webViewStarted()
    func webViewFailed()
    func webViewFinished()
    func tryAgain()
    func canOpenUrl(_ url: URL) -> Bool
    func handleLink(withUrl url: URL)
    func webViewUrlChanged(_ url: URL)
}
