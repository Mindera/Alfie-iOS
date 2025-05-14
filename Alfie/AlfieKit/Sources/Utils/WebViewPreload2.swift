import Foundation
import WebKit

// Trick to fix an issue where the WKWebView takes too long to load on the first use
// So we call this one on app startup and it seems to help speedup the actual WebView usage later
// https://stackoverflow.com/questions/74301868/wkwebview-ios-slow-on-first-launch

public enum WebViewPreload2 {
    public static func preloadWebView() {
        Task.detached {
            let webView = await WKWebView()
            await webView.loadHTMLString("", baseURL: nil)
//            log.debug("Preloaded WebView")
        }
    }
}
