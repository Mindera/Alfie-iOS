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
        guard case .ready(let url) = self else {
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
        guard case .error(let type) = self else {
            return nil
        }
        return type
    }

    var navigationOperation: WebViewNavigationOperation? {
        guard case .needsNavigation(let operation) = self else {
            return nil
        }
        return operation
    }
}
