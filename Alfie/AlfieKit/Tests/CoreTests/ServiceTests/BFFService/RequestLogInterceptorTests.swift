import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import Mocks
import XCTest

final class RequestLogInterceptorTests: XCTestCase {
    private var mockLogger: MockLogger!
    private var chain: MockRequestChain!
    private var loggedMessages: [String]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        loggedMessages = []
        mockLogger = MockLogger()
        mockLogger.onLogCalled = { [unowned self] _, message in loggedMessages.append(message) }
        chain = MockRequestChain()
    }

    override func tearDownWithError() throws {
        mockLogger = nil
        chain = nil
        loggedMessages = nil
        try super.tearDownWithError()
    }

    func test_the_api_key_is_not_written_to_the_log() {
        let request = InterceptorTestHelpers.makeRequest()
        request.addHeader(name: "Authorization", value: "Bearer abc-123")

        makeSut().interceptAsync(chain: chain, request: request, response: nil) { _ in }

        XCTAssertEqual(loggedMessages.count, 1)
        XCTAssertFalse(loggedMessages.contains { $0.contains("abc-123") })
    }

    func test_other_headers_are_still_logged() {
        let request = InterceptorTestHelpers.makeRequest()
        request.addHeader(name: "Authorization", value: "Bearer abc-123")
        request.addHeader(name: "X-Trace", value: "trace-1")

        makeSut().interceptAsync(chain: chain, request: request, response: nil) { _ in }

        XCTAssertTrue(loggedMessages.contains { $0.contains("X-Trace: trace-1") })
    }

    func test_the_request_travels_down_the_chain_after_being_logged() {
        makeSut().interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: nil) { _ in }

        XCTAssertEqual(chain.proceedCount, 1)
    }

    private func makeSut() -> RequestLogInterceptor {
        RequestLogInterceptor(log: mockLogger)
    }
}
