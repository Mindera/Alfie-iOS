import Mocks
import Models
import XCTest
@testable import Alfie

final class DeepLinkHandlerTests: XCTestCase {
    private var sut: DeepLinkHandler!
    private var mockCoordinator: MockTabCoordinator!
    private var mockConfigurationService: MockConfigurationService!

    private let testUrl = URL(string: "http://some.link")!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCoordinator = .init()
        mockConfigurationService = MockConfigurationService()
        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            true
        }
        createSut()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCoordinator = nil
        mockConfigurationService = nil
        try super.tearDownWithError()
    }

    // MARK: - Can handle links

    func test_can_handle_home_links() {
        let deepLink = DeepLink(type: .home, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_shop_links() {
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
        let deepLink = DeepLink(type: .bag, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_wishlist_links() {
        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_account_links() {
        let deepLink = DeepLink(type: .account, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_can_handle_web_links() {
        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, true)
    }

    func test_cannot_handle_links_that_depend_on_a_feature_being_available() {
        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            false
        }

        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)
        let result = sut.canHandleDeepLink(deepLink)
        XCTAssertEqual(result, false)
    }

    // MARK: - Link handling

    func test_does_not_handle_unsupported_link() {
        mockConfigurationService.onIsFeatureEnabledCalled = { _ in
            false
        }
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        expectation.isInverted = true
        mockCoordinator.onNavigateToScreenCalled = { _ in
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .inverted)
    }

    func test_handles_home_links_when_ready() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .home, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.home()))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_web_links_when_ready() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .webView(url: self.testUrl, title: ""))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_shop_links_without_route() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .shop(route: nil), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.shop(tab: .categories)))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_shop_links_with_shop_route() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .shop(route: ThemedURL.shop.path), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.shop(tab: .categories)))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_shop_links_with_brands_route() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .shop(route: ThemedURL.brands.path), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.shop(tab: .brands)))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_shop_links_with_services_route() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .shop(route: ThemedURL.services.path), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.shop(tab: .services)))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_product_listing_links() {
        mockCoordinator.isReadyForNavigation = true
        let category = "category"
        let query = "query"
        let urlParameters = ["parameter": "value"]
        let deepLink = DeepLink(type: .productList(category: category, query: query, urlParameters: urlParameters), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            switch screen {
                case .productListing(let configuration):
                    XCTAssertEqual(configuration.category, category)
                    XCTAssertEqual(configuration.searchText, query)
                    XCTAssertEqual(configuration.urlQueryParameters, urlParameters)
                default:
                    XCTFail("Unexpected screen type")
            }

            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_product_details_links() {
        mockCoordinator.isReadyForNavigation = true
        let productId = "123456"
        let deepLink = DeepLink(type: .productDetail(id: productId, description: "", route: nil, query: nil), fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .productDetails(.id(productId)))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_bag_links() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .bag, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .tab(.bag))
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_wishlist_links() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .wishlist, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .wishlist)
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_account_links() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .account, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .account)
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .default)
    }

    func test_handles_but_ignores_unknown_links() {
        mockCoordinator.isReadyForNavigation = true
        let deepLink = DeepLink(type: .unknown, fullUrl: testUrl)

        let expectation = expectation(description: "wait for coordinator call")
        expectation.isInverted = true
        mockCoordinator.onNavigateToScreenCalled = { _ in
            expectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [expectation], timeout: .inverted)
    }

    // MARK: - Pending links

    func test_postpones_handling_home_links_until_it_becomes_ready() {
        // Create a new DeepLinkHandler instance otherwise the default value of true for the isReadyForNavigation will trigger the subscription and fail the test
        mockCoordinator.isReadyForNavigation = false
        createSut()

        let deepLink = DeepLink(type: .home, fullUrl: testUrl)

        let notCalledExpectation = expectation(description: "check for unexpected coordinator call")
        notCalledExpectation.isInverted = true
        mockCoordinator.onNavigateToScreenCalled = { _ in
            notCalledExpectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [notCalledExpectation], timeout: .inverted)

        let calledExpectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { _ in
            calledExpectation.fulfill()
        }

        mockCoordinator.isReadyForNavigation = true
        wait(for: [calledExpectation], timeout: .default)
    }

    func test_postpones_handling_web_links_until_it_becomes_ready() {
        // Create a new DeepLinkHandler instance otherwise the default value of true for the isReadyForNavigation will trigger the subscription and fail the test
        mockCoordinator.isReadyForNavigation = false
        createSut()

        let deepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)

        let notCalledExpectation = expectation(description: "check for unexpected coordinator call")
        notCalledExpectation.isInverted = true
        mockCoordinator.onNavigateToScreenCalled = { _ in
            notCalledExpectation.fulfill()
        }

        sut.handleDeepLink(deepLink)
        wait(for: [notCalledExpectation], timeout: .inverted)

        let calledExpectation = expectation(description: "wait for coordinator call")
        mockCoordinator.onNavigateToScreenCalled = { screen in
            XCTAssertEqual(screen, .webView(url: self.testUrl, title: ""))
            calledExpectation.fulfill()
        }

        mockCoordinator.isReadyForNavigation = true
        wait(for: [calledExpectation], timeout: .default)
    }

    func test_can_handle_multiple_pending_links() {
        // Create a new DeepLinkHandler instance otherwise the default value of true for the isReadyForNavigation will trigger the subscription and fail the test
        mockCoordinator.isReadyForNavigation = false
        createSut()

        let homeDeepLink = DeepLink(type: .shop(route: nil), fullUrl: testUrl)
        let externalDeepLink = DeepLink(type: .webView(url: testUrl), fullUrl: testUrl)

        sut.handleDeepLink(homeDeepLink)
        sut.handleDeepLink(externalDeepLink)

        let expectation = expectation(description: "wait for coordinator call")
        expectation.expectedFulfillmentCount = 2

        mockCoordinator.onNavigateToScreenCalled = { screen in
            if screen == .tab(.shop(tab: .categories)) {
                expectation.fulfill()
            } else if screen == .webView(url: self.testUrl, title: "") {
                expectation.fulfill()
            }
        }

        mockCoordinator.isReadyForNavigation = true
        wait(for: [expectation], timeout: .default)
    }

    // MARK: - Private

    private func createSut() {
        sut = .init(
            configurationService: mockConfigurationService,
            coordinator: mockCoordinator,
            scheduler: .immediate
        )
    }
}
