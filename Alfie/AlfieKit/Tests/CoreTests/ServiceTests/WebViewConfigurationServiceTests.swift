@testable import Core
import Mocks
import Models
import XCTest

final class WebViewConfigurationServiceTests: XCTestCase {
    private var sut: WebViewConfigurationService!
    private var mockClientService: MockBFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        // The service is initialized in each test individually
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    func test_configuration_is_fetched_on_init() {
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onGetWebViewConfigCalled = {
            expectation.fulfill()
            return WebViewConfiguration(configuration: [:])
        }
        sut = .init(bffClient: mockClientService)
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_configuration_is_fetched_if_unavailable_when_url_is_requested() {
        // First init the service without configuration
        let firstExpectation = expectation(description: "Wait for service call")
        mockClientService.onGetWebViewConfigCalled = {
            firstExpectation.fulfill()
            throw BFFRequestError(type: .generic)
        }
        sut = .init(bffClient: mockClientService)
        wait(for: [firstExpectation], timeout: defaultTimeout)

        // Now prepare the mock to return a valid configuration
        let secondExpectation = expectation(description: "Wait for service call")
        mockClientService.onGetWebViewConfigCalled = {
            secondExpectation.fulfill()
            return WebViewConfiguration(configuration: [:])
        }

        Task {
            _ = await sut.url(for: .addresses)
        }
        wait(for: [secondExpectation], timeout: defaultTimeout)
    }

    func test_feature_url_is_returned_when_configuration_is_available() {
        let url = URL(string: "http://some.url")!
        let firstExpectation = expectation(description: "Wait for service call")
        mockClientService.onGetWebViewConfigCalled = {
            firstExpectation.fulfill()
            return WebViewConfiguration(configuration: [.addresses: url])
        }
        sut = .init(bffClient: mockClientService)
        wait(for: [firstExpectation], timeout: defaultTimeout)

        let secondExpectation = expectation(description: "Wait for return")
        Task {
            let result = await sut.url(for: .addresses)
            XCTAssertEqual(result?.absoluteString, url.absoluteString)
            secondExpectation.fulfill()
        }
        wait(for: [secondExpectation], timeout: defaultTimeout)
    }

    func test_feature_url_is_nil_when_configuration_is_not_available() {
        let firstExpectation = expectation(description: "Wait for service call")
        firstExpectation.expectedFulfillmentCount = 2
        mockClientService.onGetWebViewConfigCalled = {
            firstExpectation.fulfill()
            throw BFFRequestError(type: .generic)
        }
        sut = .init(bffClient: mockClientService)

        let secondExpectation = expectation(description: "Wait for return")
        Task {
            let result = await sut.url(for: .addresses)
            XCTAssertNil(result)
            secondExpectation.fulfill()
        }
        wait(for: [firstExpectation, secondExpectation], timeout: defaultTimeout)
    }
}
