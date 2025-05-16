import AlicerceLogging
import CombineSchedulers
import Mocks
import Model
import TestUtils
import XCTest
@testable import DeepLink

final class DeepLinkHandlerTests: XCTestCase {
    private var sut: DeepLinkHandler!
//    private var mockCoordinator: MockTabCoordinator!
    private var mockConfigurationService: MockConfigurationService!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    private let testUrl = URL(string: "http://some.link")!

    override func setUpWithError() throws {
        try super.setUpWithError()
//        mockCoordinator = .init()
        testScheduler = DispatchQueue.test
        mockConfigurationService = MockConfigurationService()
        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            true
        }
    }

    override func tearDownWithError() throws {
        sut = nil
//        mockCoordinator = nil
        testScheduler = nil
        mockConfigurationService = nil
        try super.tearDownWithError()
    }

    // MARK: - Can handle links

    func test_can_handle_home_links() {
        sut = sutWithoutNavigation()
        let deepLink = DeepLink(type: .home, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_shop_links() {
        sut = sutWithoutNavigation()
        var deepLink = DeepLink(type: .shop(route: nil), fullUrl: testUrl)
        var result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)

        deepLink = DeepLink(type: .shop(route: ThemedURL.brands.path), fullUrl: testUrl)
        result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)

        deepLink = DeepLink(type: .shop(route: ThemedURL.services.path), fullUrl: testUrl)
        result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_bag_links() {
        sut = sutWithoutNavigation()
        let deepLink = DeepLink(type: .bag, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_wishlist_links() {
        sut = sutWithoutNavigation()
        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_account_links() {
        sut = sutWithoutNavigation()
        let deepLink = DeepLink(type: .account, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_web_links() {
        sut = sutWithoutNavigation()
        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_cannot_handle_links_that_depend_on_a_feature_being_available() {
        sut = sutWithoutNavigation()
        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            false
        }

        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, false)
    }

    // MARK: - Link handling

    func test_does_not_handle_unsupported_link() {
        let expectation = expectation(description: "navigation closure called")
        expectation.isInverted = true

        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            false
        }

        sut = sutWithNavigation { _ in
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true
        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .inverted)
    }

    func test_handles_home_links_when_ready() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .home, fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .home)
    }

    func test_handles_web_links_when_ready() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .webView(url: testUrl))
    }

    func test_handles_shop_links_without_route() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .shop(route: nil), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .shop(route: nil))
    }

    func test_handles_shop_links_with_shop_route() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .shop(route: ThemedURL.shop.path), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .shop(route: ThemedURL.shop.path))
    }

    func test_handles_shop_links_with_brands_route() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .shop(route: ThemedURL.brands.path), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .shop(route: ThemedURL.brands.path))
    }

    func test_handles_shop_links_with_services_route() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .shop(route: ThemedURL.services.path), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .shop(route: ThemedURL.services.path))
    }

    func test_handles_product_listing_links() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let category = "category"
        let query = "query"
        let urlParameters = ["parameter": "value"]
        let deepLink = DeepLink(
            type: .productList(category: category, query: query, urlParameters: urlParameters),
            fullUrl: testUrl
        )
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .productList(category: category, query: query, urlParameters: urlParameters))
    }

    func test_handles_product_details_links() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let productId = "123456"
        let deepLink = DeepLink(
            type: .productDetail(id: productId, description: "", route: nil, query: nil),
            fullUrl: testUrl
        )
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .productDetail(id: productId, description: "", route: nil, query: nil))
    }

    func test_handles_bag_links() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .bag, fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .bag)
    }

    func test_handles_wishlist_links() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .wishlist)
    }

    func test_handles_account_links() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation = expectation(description: "navigation closure called")

        sut = sutWithNavigation { linkType in
            receivedLinkType = linkType
            expectation.fulfill()
        }
        sut.isReadyToHandleLinks = true

        let deepLink = DeepLink(type: .account, fullUrl: testUrl)
        sut.handleDeepLink(deepLink)

        wait(for: [expectation], timeout: .default)
        XCTAssertEqual(receivedLinkType, .account)
    }

    // MARK: - Pending links

    func test_postpones_handling_home_links_until_it_becomes_ready() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation1 = expectation(description: "navigation closure called")
        expectation1.isInverted = true
        let expectation2 = expectation(description: "navigation closure called")

        sut = sutWithNavigationAndTestScheduler { linkType in
            receivedLinkType = linkType
            expectation1.fulfill()
            expectation2.fulfill()
        }

        sut.isReadyToHandleLinks = false

        let deepLink = DeepLink(type: .home, fullUrl: testUrl)
        sut.handleDeepLink(deepLink)
        testScheduler.advance()

        wait(for: [expectation1], timeout: .inverted)

        sut.isReadyToHandleLinks = true
        testScheduler.advance()

        wait(for: [expectation2], timeout: .default)
        XCTAssertEqual(receivedLinkType, .home)
    }

    func test_postpones_handling_web_links_until_it_becomes_ready() {
        var receivedLinkType: DeepLink.LinkType?
        let expectation1 = expectation(description: "navigation closure called")
        expectation1.isInverted = true
        let expectation2 = expectation(description: "navigation closure called")

        sut = sutWithNavigationAndTestScheduler { linkType in
            receivedLinkType = linkType
            expectation1.fulfill()
            expectation2.fulfill()
        }

        sut.isReadyToHandleLinks = false

        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)
        sut.handleDeepLink(deepLink)
        testScheduler.advance()

        wait(for: [expectation1], timeout: .inverted)

        sut.isReadyToHandleLinks = true
        testScheduler.advance()

        wait(for: [expectation2], timeout: .default)
        XCTAssertEqual(receivedLinkType, .webView(url: testUrl))
    }

    func test_can_handle_multiple_pending_links() {
        let expectation = expectation(description: "navigation closure called")
        expectation.expectedFulfillmentCount = 2

        sut = sutWithNavigationAndTestScheduler { linkType in
            if linkType == .shop(route: nil) {
                expectation.fulfill()
            } else if linkType == .webView(url: self.testUrl) {
                expectation.fulfill()
            }
        }

        sut.isReadyToHandleLinks = false

        let homeDeepLink = DeepLink(type: .shop(route: nil), fullUrl: testUrl)
        let externalDeepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)
        sut.handleDeepLink(homeDeepLink)
        sut.handleDeepLink(externalDeepLink)
        testScheduler.advance()

        sut.isReadyToHandleLinks = true
        testScheduler.advance()

        wait(for: [expectation], timeout: .default)
    }

    // MARK: - Private

    private func sutWithoutNavigation() -> DeepLinkHandler {
        .init(
            configurationService: mockConfigurationService,
            log: Log.DummyLogger(),
            scheduler: .immediate
        ) { _ in }
    }

    private func sutWithNavigation(navigate: @escaping (DeepLink.LinkType) -> Void) -> DeepLinkHandler {
        .init(
            configurationService: mockConfigurationService,
            log: Log.DummyLogger(),
            scheduler: .immediate
        ) { navigate($0) }
    }

    private func sutWithNavigationAndTestScheduler(navigate: @escaping (DeepLink.LinkType) -> Void) -> DeepLinkHandler {
        .init(
            configurationService: mockConfigurationService,
            log: Log.DummyLogger(),
            scheduler: testScheduler.eraseToAnyScheduler()
        ) { navigate($0) }
    }
}
