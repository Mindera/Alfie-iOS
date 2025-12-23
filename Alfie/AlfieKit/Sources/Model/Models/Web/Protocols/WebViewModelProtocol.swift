import Foundation

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
