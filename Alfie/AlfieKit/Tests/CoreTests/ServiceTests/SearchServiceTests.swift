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

    func test_searchProducts_passes_bff_errors_through_untouched() async {
        let underlying = URLError(.badServerResponse)
        let thrown = BFFRequestError(
            type: .serverError(status: 503),
            error: underlying,
            retryCount: 2,
            graphqlErrorCode: "INTERNAL_SERVER_ERROR",
            graphqlErrorStatus: 503
        )
        mockClientService.onSearchProductsCalled = { _, _, _, _, _ in throw thrown }

        do {
            _ = try await sut.searchProducts(searchTerm: "polo", after: nil, limit: 1, sort: nil, filters: nil)
            XCTFail("Expected a throw")
        } catch let error as BFFRequestError {
            XCTAssertEqual(error.type, .serverError(status: 503))
            XCTAssertEqual(error.retryCount, 2)
            XCTAssertEqual(error.graphqlErrorCode, "INTERNAL_SERVER_ERROR")
            XCTAssertEqual(error.graphqlErrorStatus, 503)
            XCTAssertEqual((error.error as? URLError)?.code, .badServerResponse)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_searchProducts_calls_bff_service() async throws {
        var captured: SearchCall?
        mockClientService.onSearchProductsCalled = { searchTerm, after, limit, sort, filters in
            captured = SearchCall(searchTerm: searchTerm, after: after, limit: limit, sort: sort, filters: filters)
            return ProductListing.fixture()
        }
        let filters = ProductFilterInput(brandNames: ["Acme"])

        _ = try await sut.searchProducts(
            searchTerm: "polo",
            after: "cursor-1",
            limit: 2,
            sort: "sort",
            filters: filters
        )

        let call = try XCTUnwrap(captured)
        XCTAssertEqual(call.searchTerm, "polo")
        XCTAssertEqual(call.after, "cursor-1")
        XCTAssertEqual(call.limit, 2)
        XCTAssertEqual(call.sort, "sort")
        XCTAssertEqual(call.filters, filters)
    }
}

// MARK: - Helpers

private struct SearchCall {
    let searchTerm: String
    let after: String?
    let limit: Int
    let sort: String?
    let filters: ProductFilterInput?
}
