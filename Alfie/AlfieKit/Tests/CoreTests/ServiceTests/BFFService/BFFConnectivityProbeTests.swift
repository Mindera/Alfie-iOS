import AlicerceLogging
import Mocks
import XCTest
@testable import Core

final class BFFConnectivityProbeTests: XCTestCase {
    private let baseUrl = URL(string: "http://192.168.0.10:3000")!

    func test_probesTheGraphQLEndpointOfTheConfiguredBase() async {
        var sentRequest: URLRequest?
        let sut = makeSut { request in
            sentRequest = request
            return (Data(), self.response(status: 200))
        }

        await sut.run()

        XCTAssertEqual(sentRequest?.url?.absoluteString, "http://192.168.0.10:3000/graphql")
        XCTAssertEqual(sentRequest?.httpMethod, "POST")
    }

    func test_aSuccessfulResponseIsLoggedAsConnected() async {
        let sut = makeSut { _ in (Data(), self.response(status: 200)) }

        await sut.run()

        XCTAssertTrue(logs.contains { $0.level == .info && $0.message.contains("connected: HTTP 200") })
    }

    func test_anUnexpectedStatusIsLoggedAsAnError() async {
        let sut = makeSut { _ in (Data(), self.response(status: 404)) }

        await sut.run()

        XCTAssertTrue(logs.contains { $0.level == .error && $0.message.contains("HTTP 404") })
    }

    func test_aTransportFailureIsLoggedWithItsCause() async {
        let sut = makeSut { _ in throw URLError(.notConnectedToInternet) }

        await sut.run()

        XCTAssertTrue(logs.contains {
            $0.level == .error && $0.message.contains("cannot connect") && $0.message.contains("-1009")
        })
    }

    func test_aBlockedNetworkPathIsLoggedWithTheSystemReason() async {
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

    private var logs: [(level: Log.Level, message: String)] = []

    private func makeSut(fetch: @escaping BFFConnectivityProbe.Fetch) -> BFFConnectivityProbe {
        let log = MockLogger()
        log.onLogCalled = { [weak self] level, message in self?.logs.append((level, message)) }
        return BFFConnectivityProbe(baseUrl: baseUrl, fetch: fetch, log: log)
    }

    private func response(status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: baseUrl, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
