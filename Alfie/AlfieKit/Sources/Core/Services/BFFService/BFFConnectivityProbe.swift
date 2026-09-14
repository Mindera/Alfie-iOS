import AlicerceLogging
import Foundation

public struct BFFConnectivityProbe {
    public typealias Fetch = (URLRequest) async throws -> (Data, URLResponse)

    private let baseUrl: URL
    private let fetch: Fetch
    private let log: Logger

    public init(
        baseUrl: URL,
        fetch: @escaping Fetch = { try await URLSession.shared.data(for: $0) },
        log: Logger
    ) {
        self.baseUrl = baseUrl
        self.fetch = fetch
        self.log = log
    }

    public func run() async {
        let url = baseUrl.appending(path: "graphql")
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"{"query":"{ __typename }"}"#.utf8)

        log.info("BFF probe → POST \(url.absoluteString)")
        let start = Date()

        do {
            let (_, response) = try await fetch(request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let elapsed = Int(Date().timeIntervalSince(start) * 1000)
            if status == 200 {
                log.info("BFF probe ✅ connected: HTTP 200 in \(elapsed)ms")
            } else {
                log.error("BFF probe ⚠️ reached server but got HTTP \(status) in \(elapsed)ms")
            }
        } catch {
            log.error("BFF probe ❌ cannot connect to \(url.absoluteString): \(error)")
        }
    }
}
