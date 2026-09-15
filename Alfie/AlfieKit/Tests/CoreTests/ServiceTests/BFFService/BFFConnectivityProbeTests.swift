import AlicerceLogging
import Mocks
import XCTest
@testable import Core

final class BFFConnectivityProbeTests: XCTestCase {
    private let baseUrl = URL(string: "http://192.168.0.10:3000")!
    private var logs: [(level: Log.Level, message: String)] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        logs = []
    }

    override func tearDownWithError() throws {
        logs = []
        try super.tearDownWithError()
    }

    func test_run_posts_to_graphql_endpoint_of_configured_base() async {
        var sentRequest: URLRequest?
        let sut = makeSut { request in
            sentRequest = request
            return (Data(), self.response(status: 200))
        }

        await sut.run()

        XCTAssertEqual(sentRequest?.url?.absoluteString, "http://192.168.0.10:3000/graphql")
        XCTAssertEqual(sentRequest?.httpMethod, "POST")
    }

    func test_run_with_http_200_logs_connected() async {
        let sut = makeSut { _ in (Data(), self.response(status: 200)) }

        await sut.run()

        XCTAssertTrue(logs.contains { $0.level == .info && $0.message.contains("connected: HTTP 200") })
    }

    func test_run_with_unexpected_status_logs_error() async {
        let sut = makeSut { _ in (Data(), self.response(status: 404)) }

        await sut.run()

        XCTAssertTrue(logs.contains { $0.level == .error && $0.message.contains("HTTP 404") })
    }

    func test_run_with_non_http_response_logs_error_rather_than_connected() async {
        let sut = makeSut { _ in
            (Data(), URLResponse(url: self.baseUrl, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
        }

        await sut.run()

        XCTAssertTrue(logs.contains { $0.level == .error && $0.message.contains("HTTP -1") })
        XCTAssertFalse(logs.contains { $0.message.contains("connected") })
    }

    func test_run_with_transport_failure_logs_error_with_its_cause() async {
        let sut = makeSut { _ in throw URLError(.notConnectedToInternet) }

        await sut.run()

        XCTAssertTrue(logs.contains {
            $0.level == .error && $0.message.contains("cannot connect") && $0.message.contains("-1009")
        })
    }

    func test_run_on_blocked_network_path_logs_system_reason() async {
        let underlying = NSError(
            domain: kCFErrorDomainCFNetwork as String,
            code: -1009,
            userInfo: ["_NSURLErrorNWPathKey": "unsatisfied (Local network prohibited)"]
        )
        let sut = makeSut { _ in
            throw URLError(.notConnectedToInternet, userInfo: [NSUnderlyingErrorKey: underlying])
        }

        await sut.run()

        XCTAssertTrue(logs.contains {
            $0.level == .error
                && $0.message.contains("URLError -1009")
                && $0.message.contains("path: unsatisfied (Local network prohibited)")
        })
    }

    // MARK: - Helpers

    private func makeSut(fetch: @escaping BFFConnectivityProbe.Fetch) -> BFFConnectivityProbe {
        let log = MockLogger()
        log.onLogCalled = { [weak self] level, message in self?.logs.append((level, message)) }
        return BFFConnectivityProbe(baseUrl: baseUrl, fetch: fetch, log: log)
    }

    private func response(status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: baseUrl, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
