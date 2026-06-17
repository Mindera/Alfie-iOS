import AlicerceLogging
import Core
import Mocks
import Model
import XCTest

/// Base case for integration tests that exercise the **real** `BFFClientService` over HTTP against
/// a locally running BFF. See `Docs/Plans/260617-1348-ALFMOB-335-bff-integration-tests/`.
///
/// `ALFIE_BFF_BASE_URL` (default `http://localhost:3000`) is the BFF **origin** — it must NOT include
/// `/graphql`, because `BFFClientService` appends that path itself. When the BFF isn't answering as a
/// GraphQL endpoint, every test `XCTSkip`s in `setUp`, so an unattended full-scheme or CI run without a
/// server skips rather than fails.
///
/// Note: this hits `http://localhost` (cleartext). The iOS Simulator permits loopback HTTP in practice;
/// if a future runtime enforces ATS for loopback, add an `NSExceptionDomains`/`NSAllowsLocalNetworking`
/// exception to the test bundle. Confirm on the first run against a live BFF.
class IntegrationTestCase: XCTestCase {
    private static let defaultBaseURL = "http://localhost:3000"

    private(set) var sut: BFFClientServiceProtocol!
    private(set) var baseURL: URL!

    /// The BFF origin to test against. `ALFIE_BFF_BASE_URL` is forwarded into the simulator runner via
    /// `AlfieIntegration.xctestplan`; an empty or un-expanded (`$(…)`) value means "not overridden", so
    /// fall back to the default rather than silently building an invalid URL and skipping every test.
    private static var resolvedBaseURL: String {
        let value = ProcessInfo.processInfo.environment["ALFIE_BFF_BASE_URL"]
        if let value, !value.isEmpty, !value.hasPrefix("$(") {
            return value
        }
        return defaultBaseURL
    }

    override func setUp() async throws {
        try await super.setUp()

        guard let url = URL(string: Self.resolvedBaseURL) else {
            throw XCTSkip("Invalid ALFIE_BFF_BASE_URL: \(Self.resolvedBaseURL)")
        }
        baseURL = url

        try await skipUnlessBFFReady()

        // Fresh service per test → fresh Apollo in-memory cache, so a cached page/details response
        // can't leak into another test's pagination/sort/filter assertions.
        sut = BFFClientService(
            url: url,
            logRequests: false,
            dependencies: BFFClientDependencyContainer(
                reachabilityService: MockReachabilityService(),
                restNetworkClient: NetworkClient(logRequests: false, logResponses: false, log: Log.DummyLogger())
            ),
            log: Log.DummyLogger()
        )
    }

    /// Probes the GraphQL endpoint with a trivial query and skips the test unless it answers like a
    /// live GraphQL server (HTTP 200 + a JSON body containing `data` or `errors`). A POST is used
    /// deliberately: a GraphQL GET returns 200-landing/404/405 inconsistently, so only a POST proves
    /// the endpoint is actually GraphQL rather than some other process on the port.
    private func skipUnlessBFFReady() async throws {
        let endpoint = graphQLEndpoint
        var request = URLRequest(url: endpoint, timeoutInterval: 5)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(#"{"query":"{__typename}"}"#.utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            // Require a top-level `data`/`errors` *key* (not a substring of the body) so a non-GraphQL
            // process on the port — whose page might merely contain the word "data" — is rejected.
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard
                let http = response as? HTTPURLResponse, http.statusCode == 200,
                let json, json["data"] != nil || json["errors"] != nil
            else {
                throw XCTSkip("BFF at \(endpoint) did not respond as a GraphQL endpoint")
            }
        } catch let skip as XCTSkip {
            throw skip
        } catch {
            throw XCTSkip("BFF not reachable at \(endpoint): \(error.localizedDescription)")
        }
    }

    /// The probe must derive `/graphql` exactly as `BFFClientService` does, so the readiness check
    /// and the real requests target the same URL.
    private var graphQLEndpoint: URL {
        baseURL.appending(path: "graphql")
    }
}
