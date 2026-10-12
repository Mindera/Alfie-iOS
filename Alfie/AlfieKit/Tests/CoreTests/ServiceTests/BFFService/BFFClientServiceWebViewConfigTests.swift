import AlicerceLogging
@testable import Core
import Foundation
import Mocks
import Model
import XCTest

final class BFFClientServiceWebViewConfigTests: XCTestCase {
    private var networkClient: RecordingNetworkClient!
    private var mockApiKeyService: MockBFFApiKeyService!
    private var sut: BFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkClient = RecordingNetworkClient()
        mockApiKeyService = MockBFFApiKeyService()
        sut = BFFClientService(
            url: try XCTUnwrap(URL(string: "https://www.endpoint.com/")),
            logRequests: false,
            dependencies: BFFClientDependencyContainer(
                reachabilityService: MockReachabilityService(),
                restNetworkClient: networkClient,
                apiKeyService: mockApiKeyService
            ),
            log: Log.DummyLogger()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        networkClient = nil
        mockApiKeyService = nil
        try super.tearDownWithError()
    }

    func test_the_web_view_config_request_carries_the_current_api_key() async {
        mockApiKeyService.currentApiKey = "abc-123"

        _ = try? await sut.getWebViewConfig()

        XCTAssertEqual(networkClient.receivedTokens, ["abc-123"])
    }

    func test_the_web_view_config_request_carries_no_key_when_there_is_none() async {
        mockApiKeyService.currentApiKey = nil

        _ = try? await sut.getWebViewConfig()

        XCTAssertEqual(networkClient.receivedTokens, [nil])
    }
}

private final class RecordingNetworkClient: NetworkClientProtocol {
    private(set) var receivedTokens: [String?] = []

    func getData<T: Decodable>(from url: URL, authenticationToken: String?) async throws -> T {
        receivedTokens.append(authenticationToken)
        throw URLError(.badServerResponse)
    }

    func sendData<T: Encodable>(_ data: T, to url: URL, authenticationToken: String?) async throws {
        receivedTokens.append(authenticationToken)
    }
}
