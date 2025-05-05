import Foundation
import Model

final class WebViewModel: WebViewModelProtocol {
    private let webFeature: WebFeature?
    private let url: URL?
    let title: String
    private let dependencies: WebDependencyContainer
    @Published private(set) var state: WebViewState = .empty
    // Handler should return true if it handled the URL, false to allow the webview to handle it
    private let urlChangeHandler: ((URL) -> Bool)?

    var shouldNavigateBack: Bool {
        guard let operation = state.navigationOperation else {
            return false
        }

        return operation == .back
    }

    init(
        url: URL?,
        title: String? = nil,
        dependencies: WebDependencyContainer,
        urlChangeHandler: ((URL) -> Bool)? = nil
    ) {
        self.url = url
        self.webFeature = nil
        self.title = title ?? ""
        self.dependencies = dependencies
        self.urlChangeHandler = urlChangeHandler
    }

    init(
        webFeature: WebFeature,
        title: String? = nil,
        dependencies: WebDependencyContainer,
        urlChangeHandler: ((URL) -> Bool)? = nil
    ) {
        self.url = nil
        self.webFeature = webFeature
        self.title = title ?? ""
        self.dependencies = dependencies
        self.urlChangeHandler = urlChangeHandler
    }

    func viewDidAppear() {
        Task {
            await updateUrl()
        }
    }

    func webViewStarted() {
        state = .loading
    }

    func webViewFailed() {
        state = .error(.generic)
    }

    func webViewFinished() {
        state = .loaded
    }

    func tryAgain() {
        Task {
            await updateUrl()
        }
    }

    func canOpenUrl(_ url: URL) -> Bool {
        guard url.absoluteString != self.state.url?.absoluteString else {
            return false
        }

        guard let type = dependencies.deepLinkService.deepLinkType(url) else {
            return false
        }
        return type != .unknown && !type.isWebView
    }

    func handleLink(withUrl url: URL) {
        dependencies.deepLinkService.openUrls([url])
    }

    func webViewUrlChanged(_ url: URL) {
        // Do we have an external handler? Check if it allows the webview to handle the URL.
        if let urlChangeHandler {
            if urlChangeHandler(url) {
                Task.detached { @MainActor [weak self] in
                    self?.state = .needsNavigation(.back)
                }
            }
        } else if canOpenUrl(url) { // No external handler, can we handle the URL change ourselves?
            handleLink(withUrl: url)
            Task.detached { @MainActor [weak self] in
                self?.state = .needsNavigation(.back)
            }
        }
        // No handling available, let the webview handle the URL and navigate
    }

    // MARK: - Private

    @MainActor
    private func updateUrl() async {
        if let url {
            state = .ready(url)
            return
        }

        guard let webFeature else {
            state = .error(.noUrl)
            return
        }

        state = .loading

        let pageUrl = await dependencies.webViewConfigurationService.url(for: webFeature)

        guard let pageUrl else {
            state = .error(.noUrl)
            return
        }
        state = .ready(pageUrl)
    }
}
