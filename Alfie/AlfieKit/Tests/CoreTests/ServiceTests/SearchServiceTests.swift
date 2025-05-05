@testable import Core
import Mocks
import Model
import XCTest

final class SearchServiceTests: XCTestCase {
    private var sut: SearchService!
    private var mockClientService: MockBFFClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClientService = MockBFFClientService()
        sut = .init(bffClient: mockClientService)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClientService = nil
        try super.tearDownWithError()
    }

    func test_get_suggestion_calls_bff_service() {
        let searchTerm = "something"
        let expectation = expectation(description: "Wait for service call")
        mockClientService.onGetSearchSuggestionCalled = { term in
            XCTAssertEqual(term, searchTerm)
            expectation.fulfill()
            return .fixture()
        }

        Task {
            _ = try await sut.getSuggestion(term: searchTerm)
        }
        wait(for: [expectation], timeout: .default)
    }
}
