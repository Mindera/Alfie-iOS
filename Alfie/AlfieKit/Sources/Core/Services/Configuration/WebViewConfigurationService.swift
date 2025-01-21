import Common
import Foundation
import Models

public final class WebViewConfigurationService: WebViewConfigurationServiceProtocol {
    private let bffClient: BFFClientServiceProtocol
    private var configuration: WebViewConfiguration?

    public init(bffClient: BFFClientServiceProtocol) {
        self.bffClient = bffClient

        Task {
            await fetchConfiguration()
        }
    }

    // MARK: - WebViewConfigurationServiceProtocol

    public func url(for feature: WebFeature) async -> URL? {
        if configuration == nil {
            await fetchConfiguration()
        }

        return configuration?.url(for: feature)
    }

    // MARK: - Private

    private func fetchConfiguration() async {
        do {
            configuration = try await bffClient.getWebViewConfig()
        } catch {
            logError("Error fetching webview configuration: \(error)")
        }
    }
}
