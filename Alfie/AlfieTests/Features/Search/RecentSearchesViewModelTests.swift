import Combine
import Model
import Mocks
import XCTest
@testable import Alfie
@testable import Search

final class RecentSearchesViewModelTests: XCTestCase {
    private var mockRecentsService: MockRecentsService!
    private var sut: RecentSearchesViewModel!

    override func setUp() {
        super.setUp()
        mockRecentsService = MockRecentsService()
        mockRecentsService.recentSearchesPublisher = Just([
            .recentSearch1,
            .recentSearch2,
            .recentSearch3,
            .recentSearch4
        ]).eraseToAnyPublisher()
        sut = RecentSearchesViewModel(recentsService: mockRecentsService) { _ in }
    }

    override func tearDown() {
        sut = nil
        mockRecentsService = nil
        super.tearDown()
    }

    func test_OnInit_RecentSearches_ReturnsCorrectValue() {
        XCTAssertEqual(sut.recentSearches, [.recentSearch1, .recentSearch2, .recentSearch3, .recentSearch4])
    }

    func test_DidTapRemove_InRecentsService_CallsRemoveRecentSearch() {
        let expectation = expectation(description: "DidTapRemove_InRecentsService_CallsRemoveRecentSearch")
        mockRecentsService.onRemove = { recentSearch in
            XCTAssertEqual(recentSearch, .recentSearch2)
            expectation.fulfill()
        }
        sut.didTapRemove(on: .recentSearch2)
        waitForExpectations(timeout: .default)
    }

    func test_DidTapClearAll_InRecentsService_CallsRemoveAll() {
        let expectation = expectation(description: "DidTapClearAll_InRecentsService_CallsRemoveAll")
        mockRecentsService.onRemoveAll = {
            expectation.fulfill()
        }
        sut.didTapClearAll()
        waitForExpectations(timeout: .default)
    }

    func test_OnViewDidDisappear_InRecentsService_CallsSave() {
        let expectation = expectation(description: "OnViewDidDisappear_InRecentsService_CallsSave")
        mockRecentsService.onSave = {
            expectation.fulfill()
        }
        sut.viewDidDisappear()
        waitForExpectations(timeout: .default)
    }
}
