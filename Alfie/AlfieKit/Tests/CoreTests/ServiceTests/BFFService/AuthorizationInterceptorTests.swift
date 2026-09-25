import Apollo
import ApolloAPI
import BFFGraph
@testable import Core
import Foundation
import Mocks
import XCTest

/// The BFF rejects every request without a `Bearer` credential, so the header this interceptor adds
/// is what makes the app work at all. It reads the key per request rather than capturing it at init,
/// which is what lets a key typed into the debug menu take effect without rebooting the app.
final class AuthorizationInterceptorTests: XCTestCase {
    private var mockApiKeyService: MockBFFApiKeyService!
    private var chain: MockRequestChain!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockApiKeyService = MockBFFApiKeyService()
        chain = MockRequestChain()
    }

    override func tearDownWithError() throws {
        mockApiKeyService = nil
        chain = nil
        try super.tearDownWithError()
    }

    func test_a_stored_key_is_sent_as_a_bearer_credential() {
        mockApiKeyService.currentApiKey = "abc-123"
        let request = InterceptorTestHelpers.makeRequest()

        makeSut().interceptAsync(chain: chain, request: request, response: nil) { _ in }

        XCTAssertEqual(request.additionalHeaders["Authorization"], "Bearer abc-123")
    }

    func test_no_stored_key_sends_no_authorization_header() {
        mockApiKeyService.currentApiKey = nil
        let request = InterceptorTestHelpers.makeRequest()

        makeSut().interceptAsync(chain: chain, request: request, response: nil) { _ in }

        XCTAssertNil(
            request.additionalHeaders["Authorization"],
            "An empty credential must be absent, not sent as `Bearer `"
        )
    }

    /// The reason the key is read inside `interceptAsync`: a tester pasting a new key into the debug
    /// menu expects the next request to carry it, and only the endpoint change reboots the app.
    func test_a_key_changed_after_init_is_used_by_the_next_request() {
        mockApiKeyService.currentApiKey = "first-key"
        let sut = makeSut()
        let firstRequest = InterceptorTestHelpers.makeRequest()
        sut.interceptAsync(chain: chain, request: firstRequest, response: nil) { _ in }
        mockApiKeyService.updateApiKey("second-key")
        let secondRequest = InterceptorTestHelpers.makeRequest()

        sut.interceptAsync(chain: chain, request: secondRequest, response: nil) { _ in }

        XCTAssertEqual(firstRequest.additionalHeaders["Authorization"], "Bearer first-key")
        XCTAssertEqual(secondRequest.additionalHeaders["Authorization"], "Bearer second-key")
    }

    func test_the_request_travels_down_the_chain_whether_or_not_a_key_was_added() {
        mockApiKeyService.currentApiKey = nil

        makeSut().interceptAsync(chain: chain, request: InterceptorTestHelpers.makeRequest(), response: nil) { _ in }

        XCTAssertEqual(chain.proceedCount, 1, "A missing key must not stop the request being sent")
    }

    private func makeSut() -> AuthorizationInterceptor {
        AuthorizationInterceptor(apiKeyService: mockApiKeyService)
    }
}
