import SwiftUI

public enum WebViewState2 {
    case empty
    case ready(URL)
    case loading
    case loaded
    case needsNavigation(WebViewNavigationOperation2)
    case error(WebViewErrorType2)
}

public extension WebViewState2 {
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

    var failure: WebViewErrorType2? {
        guard case .error(let type) = self else {
            return nil
        }
        return type
    }

    var navigationOperation: WebViewNavigationOperation2? {
        guard case .needsNavigation(let operation) = self else {
            return nil
        }
        return operation
    }
}
