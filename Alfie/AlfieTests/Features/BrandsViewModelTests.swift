import TestUtils
import OrderedCollections
import Mocks
import Models
import XCTest
@testable import Alfie

final class BrandsViewModelTests: XCTestCase {
    private var sut: BrandsViewModel!
    private var mockBrandsService: MockBrandsService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockBrandsService = MockBrandsService()
        sut = .init(brandsService: mockBrandsService)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockBrandsService = nil
        try super.tearDownWithError()
    }

    // MARK: - State

    func test_initial_state_is_loading() {
        XCTAssertTrue(sut.state.isLoading)
    }

    func test_sets_loading_state_when_fetching_items() {
        mockBrandsService.onGetBrandsCalled = {
            []
        }

        XCTAssertEmitsValue(
            from: sut.$state,
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.state.didFail)

        mockBrandsService.onGetBrandsCalled = {
            [.fixture(name: "Brand 1")]
        }

        XCTAssertEmitsValue(
            from: sut.$state,
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.state.isLoading)
    }

    func test_does_not_set_loading_state_when_fetching_items_if_already_loading() {
        mockBrandsService.onGetBrandsCalled = {
            [.fixture(name: "Brand 1")]
        }

        XCTAssertEmitsValue(
            from: sut.$state,
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertFalse(sut.state.isLoading)
        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_sets_success_state_after_fetching_items() {
        mockBrandsService.onGetBrandsCalled = {
            [Brand.fixture(name: "brand")]
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.state.isSuccess)
    }

    func test_sets_proper_error_state_if_no_items_are_available() {
        mockBrandsService.onGetBrandsCalled = {
            []
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .noResults)
    }

    func test_sets_proper_error_state_if_service_call_fails() {
        mockBrandsService.onGetBrandsCalled = {
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.state.didFail)
        XCTAssertEqual(sut.state.failure, .generic)
    }

    // MARK: - Service calls

    func test_loads_brands_from_service_when_view_appears() {
        let expectation = expectation(description: "Wait for service call")
        mockBrandsService.onGetBrandsCalled = {
            expectation.fulfill()
            return []
        }

        sut.viewDidAppear()
        wait(for: [expectation], timeout: `default`)
    }

    func test_ignores_load_brands_when_view_appears_but_brands_were_loaded_before() {
        let firstExpectation = expectation(description: "Wait for service call")
        let secondExpectation = expectation(description: "Wait for success state")
        mockBrandsService.onGetBrandsCalled = {
            firstExpectation.fulfill()
            return [Brand.fixture(name: "brand")]
        }

        let cancellable = sut.$state.eraseToAnyPublisher()
            .sink { state in
                if state.isSuccess {
                    secondExpectation.fulfill()
                }
            }

        sut.viewDidAppear()
        wait(for: [firstExpectation, secondExpectation], timeout: `default`)

        let thirdExpectation = expectation(description: "Wait for no service call")
        thirdExpectation.isInverted = true
        mockBrandsService.onGetBrandsCalled = {
            thirdExpectation.fulfill()
            return [Brand.fixture()]
        }

        sut.viewDidAppear()
        wait(for: [thirdExpectation], timeout: inverted)
        cancellable.cancel()
    }

    // MARK: - Brands

    func test_brands_are_available_after_loading() {
        let fixtures: [Brand] = [.fixture(name: "A brand 1"), .fixture(name: "A brand 2"), .fixture(name: "B brand")]
        mockBrandsService.onGetBrandsCalled = {
            fixtures
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.sectionTitles.count, 2)
        XCTAssertEqual(sut.state.value?.keys.count, sut.sectionTitles.count)
        XCTAssertEqual(sut.state.value?.values.count, 2)
    }

    func test_brands_are_not_available_after_failure() {
        mockBrandsService.onGetBrandsCalled = {
            throw BFFRequestError(type: .generic)
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertTrue(sut.sectionTitles.isEmpty)
        XCTAssertTrue(sut.state.didFail)
    }

    func test_brand_sections_are_sorted() {
        let fixtures: [Brand] = [.fixture(name: "C brand"), .fixture(name: "B brand"), .fixture(name: "A brand")]
        mockBrandsService.onGetBrandsCalled = {
            fixtures
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        let expectedSections = OrderedSet(arrayLiteral: "A", "B", "C")
        XCTAssertEqual(sut.sectionTitles.count, 3)
        XCTAssertEqual(sut.sectionTitles, expectedSections)
    }

    func test_brands_are_grouped_by_sections() {
        let fixtures: [Brand] = [
            .fixture(id: "1", name: "A brand", slug: ""),
            .fixture(id: "2", name: "B brand", slug: ""),
            .fixture(id: "3", name: "A brand", slug: ""),
            .fixture(id: "4", name: "C brand", slug: ""),
        ]
        mockBrandsService.onGetBrandsCalled = {
            fixtures
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.brands(for: "A").count, 2)
        XCTAssertEqual(sut.brands(for: "B").count, 1)
        XCTAssertEqual(sut.brands(for: "C").count, 1)
        XCTAssertEqual(sut.brands(for: "D").count, 0)
    }

    // MARK: - Search

    func test_brands_are_not_filtered_with_blank_search_query() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.sectionTitles, OrderedSet(arrayLiteral: "A", "B", "C"))

        sut.searchText = " "
        XCTAssertEqual(sut.sectionTitles, OrderedSet(arrayLiteral: "A", "B", "C"))
        XCTAssertEqual(sut.brands(for: "A").count, 5)
        XCTAssertEqual(sut.brands(for: "B").count, 1)
        XCTAssertEqual(sut.brands(for: "C").count, 1)
    }

    func test_brands_are_filtered_with_search_query() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        XCTAssertEqual(sut.sectionTitles, OrderedSet(arrayLiteral: "A", "B", "C"))

        sut.searchText = "Alfie"
        XCTAssertEqual(sut.sectionTitles, OrderedSet(arrayLiteral: "A"))
        XCTAssertEqual(sut.brands(for: "A").count, 2)
    }

    func test_brands_are_filtered_with_search_query_with_trailing_blank_space() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        sut.searchText = "Alfie "
        XCTAssertEqual(sut.sectionTitles, OrderedSet(arrayLiteral: "A"))
        XCTAssertEqual(sut.brands(for: "A").count, 1)
    }

    // MARK: Index Visibility
    
    func test_brands_index_visible_with_unfocused_search_and_no_query() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        let indexVisibilityPublisher = XCTAssertEmitsValue(
            from: sut.indexVisibilityPublisher,
            afterTrigger: {
                sut.searchText = ""
                sut.searchFocusDidChange(isFocused: false)
            }
        )

        XCTAssertEqual(indexVisibilityPublisher, true)
    }

    func test_brands_index_hidden_with_focused_search_and_no_query() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        let indexVisibilityPublisher = XCTAssertEmitsValue(
            from: sut.indexVisibilityPublisher,
            afterTrigger: {
                sut.searchText = ""
                sut.searchFocusDidChange(isFocused: true)
            }
        )

        XCTAssertEqual(indexVisibilityPublisher, false)
    }

    func test_brands_index_hidden_with_unfocused_search_but_with_query() {
        mockBrandsService.onGetBrandsCalled = {
            .mockBrands
        }

        XCTAssertEmitsValue(
            from: sut.$state.drop(while: { $0.isLoading }),
            afterTrigger: { sut.viewDidAppear() }
        )

        let indexVisibilityPublisher = XCTAssertEmitsValue(
            from: sut.indexVisibilityPublisher,
            afterTrigger: {
                sut.searchText = "query"
                sut.searchFocusDidChange(isFocused: false)
            }
        )

        XCTAssertEqual(indexVisibilityPublisher, false)
    }

    // MARK: - Placeholders

    func test_brand_placeholders_are_available_while_loading() {
        XCTAssertTrue(sut.state.isLoading)

        let placeholders = sut.brands(for: "")
        XCTAssertEqual(placeholders.count, 10)
    }
}

private extension Collection where Element == Brand {
    static var mockBrands: [Brand] {
        [
            .fixture(id: "1", name: "Abelard", slug: ""),
            .fixture(id: "2", name: "Ami", slug: ""),
            .fixture(id: "3", name: "Apple", slug: ""),
            .fixture(id: "4", name: "Balmain", slug: ""),
            .fixture(id: "5", name: "Cacharel", slug: ""),
            .fixture(id: "6", name: "Alfie", slug: ""),
            .fixture(id: "6", name: "Alfie Alt", slug: "")
        ]
    }
}
