import Mocks
import Model
import XCTest
@testable import Alfie

final class CategoriesViewModelTests: XCTestCase {
    private var sut: CategoriesViewModel!
    private var mockNavigationService: MockNavigationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNavigationService = MockNavigationService()
        sut = .init(navigationService: mockNavigationService)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockNavigationService = nil
        try super.tearDownWithError()
    }

    // MARK: - State

    func test_initial_state_is_loading() {
        XCTAssertTrue(sut.state.isLoading)
    }

    func test_sets_loading_state_when_fetching_items() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            []
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)

        mockNavigationService.onGetNavigationItemsCalled = { _ in
            NavigationItem.fixtures
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isLoading)
    }

    func test_does_not_set_loading_state_when_fetching_items_if_already_loading() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            NavigationItem.fixtures
        }

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertFalse(sut.state.isLoading)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_sets_success_state_after_fetching_items() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            NavigationItem.fixtures
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_sets_proper_error_state_if_no_items_are_available() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            []
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .noResults)
    }

    func test_sets_proper_error_state_if_service_call_fails() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    // MARK: - Service calls

    func test_loads_items_from_service_when_view_appears() {
        let expectation = expectation(description: "Wait for service call")
        mockNavigationService.onGetNavigationItemsCalled = { screen in
            XCTAssertEqual(screen, .shop)
            expectation.fulfill()
            return []
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: .default)
    }

    func test_ignores_load_items_when_view_appears_but_items_were_loaded_before() {
        let firstExpectation = expectation(description: "Wait for service call")
        let secondExpectation = expectation(description: "Wait for success state")
        mockNavigationService.onGetNavigationItemsCalled = { screen in
            XCTAssertEqual(screen, .shop)
            firstExpectation.fulfill()
            return NavigationItem.fixtures
        }

        let cancellable = sut.$state.eraseToAnyPublisher()
            .sink { state in
                if state.isSuccess {
                    secondExpectation.fulfill()
                }
            }

        sut.viewDidAppear()
        wait(for: [firstExpectation, secondExpectation], timeout: .default)

        let thirdExpectation = expectation(description: "Wait for no service call")
        thirdExpectation.isInverted = true
        mockNavigationService.onGetNavigationItemsCalled = { screen in
            XCTAssertEqual(screen, .shop)
            thirdExpectation.fulfill()
            return NavigationItem.fixtures
        }

        sut.viewDidAppear()
        wait(for: [thirdExpectation], timeout: .inverted)
        cancellable.cancel()
    }

    func test_ignores_loads_items_from_service_when_view_appears_if_categories_init_is_used() {
        sut = .init(categories: [], title: "")

        let expectation = expectation(description: "Wait for no service call")
        expectation.isInverted = true
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            expectation.fulfill()
            return []
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: .inverted)
    }

    // MARK: - Categories

    func test_categories_are_available_immediately_on_categories_init() {
        let fixtures = NavigationItem.fixtures
        sut = .init(categories: fixtures, title: "")
        XCTAssertEqual(sut.categories.count, fixtures.count)
    }

    func test_categories_are_available_after_loading() {
        let fixtures = NavigationItem.fixtures
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            return fixtures
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertEqual(sut.categories.count, fixtures.count)
    }

    func test_categories_are_not_available_after_failure() {
        mockNavigationService.onGetNavigationItemsCalled = { _ in
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(from: sut.$state.drop(while: \.isLoading), afterTrigger: { self.sut.viewDidAppear() })

        XCTAssertTrue(sut.categories.isEmpty)
    }

    // MARK: - Category selection

    func test_triggers_navigation_when_category_without_subcategories_is_selected() {
        let path = "/something"
        let fixture = NavigationItem.fixture(type: .page, url: path)

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination, case .web(let url, _) = destination else {
            XCTFail("Unexpected destination type: \(String(describing: destination))")
            return
        }

        XCTAssertEqual(url.absoluteString.contains(path), true)
    }

    func test_triggers_navigation_to_web_when_page_item_is_selected() {
        let path = "/something"
        let itemTitle = "Something"
        let fixture = NavigationItem.fixture(type: .page, title: itemTitle, url: path)

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination, case .web(let url, let title) = destination else {
            XCTFail("Unexpected destination type: \(String(describing: destination))")
            return
        }

        XCTAssertEqual(url.absoluteString.contains(path), true)
        XCTAssertEqual(title, itemTitle)
    }

    func test_triggers_navigation_to_plp_when_listing_item_is_selected() {
        let path = "/clothing"
        let fixture = NavigationItem.fixture(type: .listing, url: path)

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination, case .plp(let category) = destination else {
            XCTFail("Unexpected destination type: \(String(describing: destination))")
            return
        }

        XCTAssertEqual(category, "clothing")
    }

    func test_sets_error_state_when_category_with_invalid_url_is_selected() {
        let fixture = NavigationItem.fixture(url: nil)

        XCTAssertEmitsValue(from: sut.$state, afterTrigger: { self.sut.didSelectCategory(fixture) })

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }


    func test_triggers_navigation_when_category_with_subcategories_is_selected() {
        let parentTitle = "Parent"
        let subFixtures = NavigationItem.fixtures
        let fixture = NavigationItem.fixture(title: parentTitle, items: subFixtures)

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination, case .subCategories(let subCategories, let parentCategory) = destination else {
            XCTFail("Unexpected destination type: \(String(describing: destination))")
            return
        }

        XCTAssertEqual(subCategories, subFixtures)
        XCTAssertEqual(parentCategory.title, parentTitle)
    }

    func test_triggers_navigation_when_special_services_category_is_selected() {
        let fixture = NavigationItem.fixture(type: .page, url: "/store-services")

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination else {
            XCTFail("Unexpected nil destination")
            return
        }

        switch destination {
            case .services:
                // Nothing else to check
                return
            default:
                XCTFail("Unexpected destination: \(destination)")
        }
    }

    func test_triggers_navigation_when_special_brands_category_is_selected() {
        let fixture = NavigationItem.fixture(type: .page, url: "/brands")

        let destination = XCTAssertEmitsValue(
            from: sut.openCategoryPublisher,
            afterTrigger: { self.sut.didSelectCategory(fixture) }
        )

        guard let destination else {
            XCTFail("Unexpected nil destination")
            return
        }

        switch destination {
            case .brands:
                // Nothing else to check
                return
            default:
                XCTFail("Unexpected destination: \(destination)")
        }
    }

    // MARK: - Title

    func test_title_is_available_when_passed_on_categories_init() {
        let title = "Some Title"
        sut = .init(categories: [], title: title)
        XCTAssertEqual(sut.title, title)
    }

    func test_title_is_empty_when_state_is_not_success() {
        XCTAssertEqual(sut.title, "")
    }

    // MARK: - Toolbar

    func test_show_toolbar_is_properly_set_on_init() {
        sut = .init(categories: [], title: "", showToolbar: true)
        XCTAssertTrue(sut.shouldShowToolbar)

        sut = .init(categories: [], title: "", showToolbar: false)
        XCTAssertFalse(sut.shouldShowToolbar)

        sut = .init(navigationService: mockNavigationService, showToolbar: true)
        XCTAssertTrue(sut.shouldShowToolbar)

        sut = .init(navigationService: mockNavigationService, showToolbar: false)
        XCTAssertFalse(sut.shouldShowToolbar)
    }

    // MARK: - Placeholders

    func test_category_placeholders_are_available_while_loading() {
        XCTAssertTrue(sut.state.isLoading)
        XCTAssertEqual(sut.categories.count, 10)
    }
}
