import Combine
import Models
import SharedUI
import SharedUI
import SwiftUI
import WebKit
#if DEBUG
import Common
import Mocks
#endif

struct WebView<ViewModel: WebViewModelProtocol>: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            if !viewModel.state.didFail {
                WebViewRepresentable(viewModel: viewModel)
                if viewModel.state.isLoading {
                    loadingView
                }
            } else {
                errorView
                    .padding(.horizontal, Spacing.space200)
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    // MARK: - Sections

    private var loadingView: some View {
        VStack {
            Spacer()
            LoaderView(circleDiameter: .defaultSmall)
            Spacer()
        }
    }

    private var errorView: some View {
        ErrorView(
            spacing: Spacing.space500,
            iconSize: Constants.errorViewIconSize,
            title: theme.font.header.h2(L10n.WebView.ErrorView.title),
            message: theme.font.paragraph.normal(L10n.WebView.ErrorView.Generic.message),
            messageColor: Colors.primary.mono600,
            buttons: [
                .init(cta: L10n.WebView.ErrorView.Button.cta) {
                    viewModel.tryAgain()
                },
            ]
        )
    }
}

private enum Constants {
    static let errorViewIconSize: CGFloat = 210
}

class CustomWebViewNoAccessory: WKWebView {
    override var inputAccessoryView: UIView? {
        nil
    }
}

private struct WebViewRepresentable<ViewModel: WebViewModelProtocol>: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        config.allowsInlineMediaPlayback = true

        let webView = CustomWebViewNoAccessory(frame: .zero, configuration: config)
        webView.backgroundColor = Colors.primary.white.ui
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        context.coordinator.webViewURLObserver = webView.observe(\.url, options: .new) { _, change in
            guard let newValue = change.newValue, let newValue else {
                return
            }
            viewModel.webViewUrlChanged(newValue)
        }

        disableAutoZoom(for: webView)

        if viewModel.state.isReady, let url = viewModel.state.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if viewModel.shouldNavigateBack {
            webView.goBack()
            return
        }

        if viewModel.state.isReady {
            if webView.url != nil {
                webView.reload()
            } else if let url = viewModel.state.url {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }

    private func disableAutoZoom(for webView: WKWebView) {
        let source = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }

    internal class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        var webViewURLObserver: NSKeyValueObservation?

        init(parent: WebViewRepresentable) {
            self.parent = parent
        }

        // MARK: - WKNavigationDelegate

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.webViewStarted()
        }

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.webViewFinished()
        }

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.webViewFailed()
        }

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.webViewFailed()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard
                let url = navigationAction.request.url,
                parent.viewModel.canOpenUrl(url)
            else {
                decisionHandler(.allow)
                return
            }

            parent.viewModel.handleLink(withUrl: url)
            decisionHandler(.cancel)
        }
    }
}

#if DEBUG
#Preview("Ready") {
    WebView(viewModel: MockWebViewModel(state: .ready(URL.fromString("https://www.alfieproj.com/"))))
        .environmentObject(Coordinator())
}

#Preview("Loading") {
    WebView(viewModel: MockWebViewModel(state: .loading))
        .environmentObject(Coordinator())
}

#Preview("Error - Generic") {
    WebView(viewModel: MockWebViewModel(state: .error(.generic)))
        .environmentObject(Coordinator())
}

#Preview("Error - No URL") {
    WebView(viewModel: MockWebViewModel(state: .error(.noUrl)))
        .environmentObject(Coordinator())
}
#endif
