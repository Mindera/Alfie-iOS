import AlicerceLogging
import TestUtils
import Mocks
import Models
import XCTest
@testable import Core

final class DeepLinkServiceTests: XCTestCase {
    private var sut: DeepLinkService!
    private var testUrl: URL!
    private var configuration: LinkConfigurationProtocol!
    private var log: Logger!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        testUrl = URL(string: "http://some.link")
        configuration = MockLinkConfiguration()
        log = Log.DummyLogger()
    }

    override func tearDownWithError() throws {
        testUrl = nil
        configuration = nil
        log = nil
        try super.tearDownWithError()
    }

    // MARK: - Can Handle URL

    func test_cant_handle_url_if_no_parsers_are_available() {
        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in
            true
        }

        sut = .init(parsers: [], handlers: [handler], configuration: configuration, log: log)
        let result = sut.canHandleUrl(testUrl)
        XCTAssertFalse(result)
    }

    func test_cant_handle_url_if_no_handlers_are_available() {
        let parser = MockDeepLinkParser(configuration: configuration)
        parser.onParseUrlCalled = { _ in
            DeepLink(type: .webView(url: self.testUrl), fullUrl: self.testUrl)
        }

        sut = .init(parsers: [parser], configuration: configuration, log: log)
        let result = sut.canHandleUrl(testUrl)
        XCTAssertFalse(result)
    }

    func test_calls_all_parsers_if_necessary_when_checking_if_can_handle_url() {
        let expectation = expectation(description: "wait for parser call")
        expectation.expectedFulfillmentCount = 3
        let parser1 = MockDeepLinkParser(configuration: configuration)
        parser1.onParseUrlCalled = { _ in
            expectation.fulfill()
            return nil
        }

        let parser2 = MockDeepLinkParser(configuration: configuration)
        parser2.onParseUrlCalled = { _ in
            expectation.fulfill()
            return nil
        }

        let parser3 = MockDeepLinkParser(configuration: configuration)
        parser3.onParseUrlCalled = { _ in
            expectation.fulfill()
            return nil
        }

        sut = .init(parsers: [parser1, parser2, parser3], configuration: configuration, log: log)
        let result = sut.canHandleUrl(testUrl)
        wait(for: [expectation], timeout: .default)
        XCTAssertFalse(result)
    }

    func test_uses_first_valid_parser_result_when_checking_if_can_handle_url() {
        let calledExpectation = expectation(description: "wait for valid parser call")
        let parser1 = MockDeepLinkParser(configuration: configuration)

        parser1.onParseUrlCalled = { _ in
            calledExpectation.fulfill()
            return DeepLink(type: .webView(url: self.testUrl), fullUrl: self.testUrl)
        }

        let notCalledExpectation = expectation(description: "wait for invalid parser call")
        notCalledExpectation.isInverted = true
        let parser2 = MockDeepLinkParser(configuration: configuration)
        parser2.onParseUrlCalled = { _ in
            notCalledExpectation.fulfill()
            return DeepLink(type: .home, fullUrl: self.testUrl)
        }

        sut = .init(parsers: [parser1, parser2], configuration: configuration, log: log)
        let result = sut.canHandleUrl(testUrl)

        wait(for: [calledExpectation, notCalledExpectation], timeout: .inverted)
        XCTAssertFalse(result, "Expected canHandleUrl to return false because no handlers were added.")
    }

    func test_can_handle_url_if_at_least_one_capable_handler_and_parser_are_available() {
        let parser = MockDeepLinkParser(configuration: configuration)
        parser.onParseUrlCalled = { _ in
            DeepLink(type: .webView(url: self.testUrl), fullUrl: self.testUrl)
        }

        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in
            true
        }

        sut = .init(parsers: [parser], handlers: [handler], configuration: configuration, log: log)
        let result = sut.canHandleUrl(testUrl)
        XCTAssertTrue(result)
    }

    // MARK: - Open URL

    func test_does_nothing_when_opening_empty_url_list() {
        let expectation = expectation(description: "wait for parser or handler call")
        expectation.isInverted = true

        let parser = MockDeepLinkParser(configuration: configuration)
        parser.onParseUrlCalled = { _ in
            expectation.fulfill()
            return DeepLink(type: .webView(url: self.testUrl), fullUrl: self.testUrl)
        }

        let handler = MockDeepLinkHandler()
        handler.onHandleDeepLinkCalled = { _ in
            expectation.fulfill()
        }

        sut = .init(parsers: [parser], handlers: [handler], configuration: configuration, log: log)
        sut.openUrls([])
        wait(for: [expectation], timeout: .inverted)
    }

    func test_uses_fallback_link_when_opening_url_if_no_parsers_are_available() {
        let expectation = expectation(description: "wait for handler call")
        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in
            return true
        }
        handler.onHandleDeepLinkCalled = { deepLink in
            expectation.fulfill()
            guard case .webView(let url) = deepLink.type else {
                XCTFail("Unexpected deeplink type \(deepLink)")
                return
            }
            XCTAssertEqual(url.absoluteString, self.testUrl.absoluteString)
        }

        sut = .init(parsers: [], handlers: [handler], configuration: configuration, log: log)
        sut.openUrls([testUrl])
        wait(for: [expectation], timeout: .default)
    }

    func test_does_nothing_when_opening_url_if_no_capable_handlers_are_available() {
        let expectation = expectation(description: "wait for handler call")
        expectation.isInverted = true

        let handler = MockDeepLinkHandler()
        handler.onCanHandleDeepLinkCalled = { _ in
            return false
        }

        handler.onHandleDeepLinkCalled = { _ in
            expectation.fulfill()
        }

        sut = .init(parsers: [], handlers: [handler], configuration: configuration, log: log)
        sut.openUrls([testUrl])
        wait(for: [expectation], timeout: .inverted)
    }

    func test_uses_first_valid_parser_result_when_opening_url() {
        let calledExpectation = expectation(description: "wait for valid parser call")
        let parser1 = MockDeepLinkParser(configuration: configuration)

        parser1.onParseUrlCalled = { _ in
            calledExpectation.fulfill()
            return DeepLink(type: .home, fullUrl: self.testUrl)
        }

        let notCalledExpectation = expectation(description: "wait for invalid parser call")
        notCalledExpectation.isInverted = true
        let parser2 = MockDeepLinkParser(configuration: configuration)

        parser2.onParseUrlCalled = { _ in
            notCalledExpectation.fulfill()
            return DeepLink(type: .webView(url: self.testUrl), fullUrl: self.testUrl)
        }

        let handlerCallExpectation = expectation(description: "wait for handler call")
        let handler = MockDeepLinkHandler()

        handler.onCanHandleDeepLinkCalled = { _ in
            return true
        }

        handler.onHandleDeepLinkCalled = { deepLink in
            XCTAssertEqual(deepLink.type, .home)
            XCTAssertEqual(deepLink.fullUrl.absoluteString, self.testUrl.absoluteString)
            handlerCallExpectation.fulfill()
        }

        sut = .init(parsers: [parser1, parser2], handlers: [handler], configuration: configuration, log: log)
        sut.openUrls([testUrl])

        wait(for: [calledExpectation, notCalledExpectation, handlerCallExpectation], timeout: .inverted)
    }

    func test_uses_first_capable_handler_when_opening_url() {
        let calledExpectation = expectation(description: "wait for handler call")
        let handler1 = MockDeepLinkHandler()

        handler1.onCanHandleDeepLinkCalled = { _ in
            true
        }
        handler1.onHandleDeepLinkCalled = { deepLink in
            guard case .webView(let url) = deepLink.type else {
                XCTFail("Unexpected deeplink type \(deepLink)")
                calledExpectation.fulfill()
                return
            }
            XCTAssertEqual(url.absoluteString, self.testUrl.absoluteString)
            calledExpectation.fulfill()
        }

        let notCalledExpectation = expectation(description: "wait handler call")
        notCalledExpectation.isInverted = true
        let handler2 = MockDeepLinkHandler()
        handler2.onCanHandleDeepLinkCalled = { _ in
            true
        }
        handler2.onHandleDeepLinkCalled = { _ in
            notCalledExpectation.fulfill()
        }

        sut = .init(parsers: [], handlers: [handler1, handler2], configuration: configuration, log: log)
        sut.openUrls([testUrl])
        wait(for: [calledExpectation, notCalledExpectation], timeout: .inverted)
    }
}
