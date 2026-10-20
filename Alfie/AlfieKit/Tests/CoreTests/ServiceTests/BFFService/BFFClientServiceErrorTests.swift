import AlicerceLogging
@testable import Core
import Foundation
import Mocks
import Model
import XCTest

final class BFFClientServiceErrorTests: XCTestCase {
    private var reporter: SpyErrorReporter!
    private var sut: BFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        reporter = SpyErrorReporter()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubGraphQLProtocol.self]
        sut = BFFClientService(
            url: try XCTUnwrap(URL(string: "https://www.endpoint.com/")),
            sessionConfiguration: configuration,
            logRequests: false,
            dependencies: BFFClientDependencyContainer(
                reachabilityService: MockReachabilityService(),
                restNetworkClient: NetworkClient(log: Log.DummyLogger()),
                apiKeyService: MockBFFApiKeyService(),
                errorReporter: reporter
            ),
            log: Log.DummyLogger()
        )
    }

    override func tearDownWithError() throws {
        StubGraphQLProtocol.response = nil
        sut = nil
        reporter = nil
        try super.tearDownWithError()
    }

    func test_get_cart_not_found_status_throws_and_reports_cart_not_found() async {
        StubGraphQLProtocol.response = .graphQL(#"{"data":null,"errors":[{"message":"gone","extensions":{"status":404}}]}"#)

        let error = await capturedError { try await self.sut.getCart(cartId: "c1") }

        XCTAssertEqual(error?.type, .cart(.cartNotFound))
        XCTAssertEqual(reporter.reports.map(\.type), [.cart(.cartNotFound)])
        XCTAssertEqual(reporter.reports.map(\.operationName), ["CartQuery"])
    }

    func test_create_cart_not_found_status_stays_generic_rather_than_cart_not_found() async {
        StubGraphQLProtocol.response = .graphQL(#"{"data":null,"errors":[{"message":"gone","extensions":{"status":404}}]}"#)

        let error = await capturedError { try await self.sut.createCart(lines: []) }

        XCTAssertEqual(error?.type, .generic)
        XCTAssertEqual(reporter.reports.map(\.type), [.generic])
    }

    func test_rate_limited_code_throws_and_reports_rate_limited() async {
        StubGraphQLProtocol.response = .graphQL(#"{"data":null,"errors":[{"message":"slow","extensions":{"code":"RATE_LIMITED"}}]}"#)

        let error = await capturedError { try await self.sut.productByBarcode("123") }

        XCTAssertEqual(error?.type, .rateLimited(retryAfter: nil))
        XCTAssertEqual(reporter.reports.map(\.graphqlErrorCode), ["RATE_LIMITED"])
    }

    func test_transport_timeout_throws_timeout() async {
        StubGraphQLProtocol.response = .failure(URLError(.timedOut))

        let error = await capturedError { try await self.sut.productByBarcode("123") }

        XCTAssertEqual(error?.type, .timeout)
    }

    func test_graphql_errors_alongside_data_throw_rather_than_return_the_data() async {
        StubGraphQLProtocol.response = .graphQL(#"{"data":{"productByBarcode":null},"errors":[{"message":"partial"}]}"#)

        let error = await capturedError { try await self.sut.productByBarcode("123") }

        XCTAssertEqual(error?.type, .generic)
    }

    func test_successful_response_reports_nothing() async throws {
        StubGraphQLProtocol.response = .graphQL(#"{"data":{"productByBarcode":null}}"#)

        let match = try await sut.productByBarcode("123")

        XCTAssertNil(match)
        XCTAssertTrue(reporter.reports.isEmpty)
    }

    private func capturedError(_ operation: () async throws -> some Any) async -> BFFRequestError? {
        do {
            _ = try await operation()
            XCTFail("Expected a BFFRequestError")
            return nil
        } catch {
            return error as? BFFRequestError
        }
    }
}

private final class SpyErrorReporter: BFFErrorReporterProtocol {
    struct Report {
        let type: BFFRequestError.BFFRequestErrorType
        let operationName: String
        let graphqlErrorCode: String?
    }

    private(set) var reports: [Report] = []

    func report(error: BFFRequestError, operationName: String, httpStatus: Int?, graphqlErrorCode: String?) {
        reports.append(Report(type: error.type, operationName: operationName, graphqlErrorCode: graphqlErrorCode))
    }
}

private final class StubGraphQLProtocol: URLProtocol {
    enum Response {
        case graphQL(String)
        case failure(Error)
    }

    static var response: Response?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let client else { return }
        switch Self.response {
        case .graphQL(let body):
            let httpResponse = HTTPURLResponse(
                url: request.url ?? URL(fileURLWithPath: "/"),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )
            if let httpResponse {
                client.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            }
            client.urlProtocol(self, didLoad: Data(body.utf8))
            client.urlProtocolDidFinishLoading(self)

        case .failure(let error):
            client.urlProtocol(self, didFailWithError: error)

        case nil:
            client.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
        }
    }

    override func stopLoading() { }
}
