import Mocks
import Models
import XCTest
@testable import Alfie

final class WebViewModelTests: XCTestCase {
    private var sut: WebViewModel!
    private var mockDeepLinkService: MockDeepLinkService!
    private var mockWebViewConfigurationService: MockWebViewConfigurationService!
    private var mockWebUrlProvider: MockWebUrlProvider!
    private var mockDependencies: WebDependencyContainerProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDeepLinkService = MockDeepLinkService()
        mockWebViewConfigurationService = MockWebViewConfigurationService()
        mockWebUrlProvider = MockWebUrlProvider()
        mockDependencies = WebDependencyContainer(
            deepLinkService: mockDeepLinkService,
            webViewConfigurationService: mockWebViewConfigurationService,
            webUrlProvider: mockWebUrlProvider
        )
        // The view model is initialized in each test individually
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDependencies = nil
        mockDeepLinkService = nil
        mockWebViewConfigurationService = nil
        mockWebUrlProvider = nil
        try super.tearDownWithError()
    }

    func test_sets_empty_state_on_init() {
        let baseUrl = URL(string: "http://some.url")!
        sut = .init(url: baseUrl, dependencies: mockDependencies, urlChangeHandler: nil)
        XCTAssertEqual(sut.state.isEmpty, true)
    }

    func test_url_to_display_is_updated_when_view_appears_for_url_initialization() {
        let url = URL(string: "http://some.url")
        sut = .init(url: url, dependencies: mockDependencies)

        XCTAssertNil(sut.state.url)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.url?.absoluteString, url?.absoluteString)
    }

    func test_url_to_display_is_updated_when_view_appears_for_webfeature_initialization() {
        let url = URL(string: "http://some.url")
        mockWebViewConfigurationService.onUrlForFeatureCalled = { _ in
            url
        }
        sut = .init(webFeature: .addresses, dependencies: mockDependencies)

        XCTAssertNil(sut.state.url)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.url?.absoluteString, url?.absoluteString)
    }

    func test_state_is_loading_when_webview_starts_first_loading() {
        let url = URL(string: "http://some.url")
        sut = .init(url: url, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewStarted()
        })

        XCTAssertEqual(sut.state.isLoading, true)
    }

    func test_state_is_generic_error_when_webview_reports_failure() {
        let url = URL(string: "http://some.url")
        sut = .init(url: url, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewFailed()
        })

        XCTAssertEqual(sut.state.failure, .generic)
    }

    func test_state_is_loaded_when_webview_finishes() {
        let url = URL(string: "http://some.url")
        sut = .init(url: url, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewFinished()
        })

        XCTAssertEqual(sut.state.isLoaded, true)
    }

    func test_url_to_display_is_updated_on_try_again() {
        let url = URL(string: "http://some.url")
        sut = .init(url: url, dependencies: mockDependencies)

        XCTAssertNil(sut.state.url)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.tryAgain()
        })

        XCTAssertEqual(sut.state.url?.absoluteString, url?.absoluteString)
    }

    func test_cannot_open_url_if_its_the_same_thats_already_loaded() {
        let url = URL(string: "http://some.url")!
        sut = .init(url: url, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let result = sut.canOpenUrl(url)
        XCTAssertFalse(result)
    }

    func test_cannot_open_url_if_unrecognized() {
        let baseUrl = URL(string: "http://some.url")
        sut = .init(url: baseUrl, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let testUrl = URL(string: "http://other.url")!
        mockDeepLinkService.onDeepLinkTypeCalled = { url in
            XCTAssertEqual(url.absoluteString, testUrl.absoluteString)
            return nil
        }

        let result = sut.canOpenUrl(testUrl)
        XCTAssertFalse(result)
    }

    func test_cannot_open_url_if_its_of_unknown_type() {
        let baseUrl = URL(string: "http://some.url")
        sut = .init(url: baseUrl, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let testUrl = URL(string: "http://other.url")!
        mockDeepLinkService.onDeepLinkTypeCalled = { url in
            XCTAssertEqual(url.absoluteString, testUrl.absoluteString)
            return .unknown
        }

        let result = sut.canOpenUrl(testUrl)
        XCTAssertFalse(result)
    }

    func test_cannot_open_url_if_its_of_webview_type() {
        let baseUrl = URL(string: "http://some.url")
        sut = .init(url: baseUrl, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let testUrl = URL(string: "http://other.url")!
        mockDeepLinkService.onDeepLinkTypeCalled = { url in
            XCTAssertEqual(url.absoluteString, testUrl.absoluteString)
            return .webView(url: url)
        }

        let result = sut.canOpenUrl(testUrl)
        XCTAssertFalse(result)
    }

    func test_can_open_url_if_different_not_unknown_and_not_webview_type() {
        let baseUrl = URL(string: "http://some.url")
        sut = .init(url: baseUrl, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        let testUrl = URL(string: "http://other.url")!
        mockDeepLinkService.onDeepLinkTypeCalled = { url in
            XCTAssertEqual(url.absoluteString, testUrl.absoluteString)
            return .account
        }

        let result = sut.canOpenUrl(testUrl)
        XCTAssertTrue(result)
    }

    func test_forwards_links_to_deeplink_handler() {
        let url = URL(string: "http://some.url")!

        let expectation = expectation(description: "Wait for handler call")
        mockDeepLinkService.onOpenUrlsCalled = { urls in
            XCTAssertEqual(urls.count, 1)
            XCTAssertEqual(urls[0].absoluteString, url.absoluteString)
            expectation.fulfill()
        }

        sut = .init(url: url, dependencies: mockDependencies)
        sut.handleLink(withUrl: url)
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_forwards_links_to_deeplink_handler_on_url_change() {
        let baseUrl = URL(string: "http://some.url")!
        let testUrl = URL(string: "http://test.url")!

        let expectation = expectation(description: "Wait for handler call")
        mockDeepLinkService.onDeepLinkTypeCalled = { _ in
            return .account
        }

        mockDeepLinkService.onOpenUrlsCalled = { urls in
            XCTAssertEqual(urls.count, 1)
            XCTAssertEqual(urls[0].absoluteString, testUrl.absoluteString)
            expectation.fulfill()
        }

        sut = .init(url: baseUrl, dependencies: mockDependencies)
        sut.webViewUrlChanged(testUrl)
        wait(for: [expectation], timeout: defaultTimeout)
    }

    func test_navigates_back_if_url_change_is_handled_by_external_handler() {
        let baseUrl = URL(string: "http://some.url")!
        sut = .init(url: baseUrl, dependencies: mockDependencies, urlChangeHandler: { url in
            XCTAssertEqual(url.absoluteString, baseUrl.absoluteString)
            return true
        })
     
        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewUrlChanged(baseUrl)
        })

        XCTAssertEqual(sut.shouldNavigateBack, true)
    }

    func test_navigates_back_if_url_change_is_handled_by_deeplink_handler() {
        let baseUrl = URL(string: "http://some.url")!
        let testUrl = URL(string: "http://other.url")!
        mockDeepLinkService.onDeepLinkTypeCalled = { _ in
            return .account
        }

        sut = .init(url: baseUrl, dependencies: mockDependencies, urlChangeHandler: nil)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewUrlChanged(testUrl)
        })

        XCTAssertEqual(sut.shouldNavigateBack, true)
    }

    func test_does_not_navigate_back_if_url_change_is_not_handled() {
        let baseUrl = URL(string: "http://some.url")!
        sut = .init(url: baseUrl, dependencies: mockDependencies, urlChangeHandler: nil)

        let result = assertNoEvent(from: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.webViewUrlChanged(baseUrl)
        })
        XCTAssertTrue(result)
    }

    func test_does_not_report_should_navigate_back_withou_valid_navigation_operation() {
        let baseUrl = URL(string: "http://some.url")!
        sut = .init(url: baseUrl, dependencies: mockDependencies, urlChangeHandler: nil)
        XCTAssertEqual(sut.shouldNavigateBack, false)
    }

    func test_state_is_no_url_error_after_update_if_no_url_or_feature_is_supplied_on_init() {
        sut = .init(url: nil, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.failure, .noUrl)
    }

    func test_state_is_loading_when_updating_url_for_feature() {
        sut = .init(webFeature: .addresses, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.isLoading, true)
    }

    func test_state_is_no_url_error_if_no_url_is_available_for_feature() {
        mockWebViewConfigurationService.onUrlForFeatureCalled = { _ in
            nil
        }
        sut = .init(webFeature: .addresses, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.didFail }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.failure, .noUrl)
    }

    func test_state_is_ready_if_url_is_available_for_feature() {
        let url = URL(string: "http://some.url")
        mockWebViewConfigurationService.onUrlForFeatureCalled = { _ in
            url
        }
        sut = .init(webFeature: .addresses, dependencies: mockDependencies)

        _ = captureEvent(fromPublisher: sut.$state.drop(while: { !$0.isReady }).eraseToAnyPublisher(), afterTrigger: {
            sut.viewDidAppear()
        })

        XCTAssertEqual(sut.state.isReady, true)
    }
}
