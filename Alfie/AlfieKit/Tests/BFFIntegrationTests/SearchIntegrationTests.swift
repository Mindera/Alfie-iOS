import Model
import TestSeed
import XCTest

/// Exercises the real `searchProducts` operation against a running BFF.
final class SearchIntegrationTests: IntegrationTestCase {
    func test_searchProducts_happyPath_returnsResults() async throws {
        let listing = try await sut.searchProducts(
            searchTerm: SeedAnchors.SearchTerms.many,
            after: nil,
            limit: 10,
            sort: nil,
            filters: nil
        )

        XCTAssertFalse(listing.products.isEmpty, "Seed BFF returned no results for '\(SeedAnchors.SearchTerms.many)'")
        for product in listing.products {
            XCTAssertFalse(product.id.isEmpty)
            XCTAssertFalse(product.name.isEmpty)
        }
    }

    func test_searchProducts_pagination_secondPageDiffersFromFirst() async throws {
        let firstPage = try await sut.searchProducts(
            searchTerm: SeedAnchors.SearchTerms.many,
            after: nil,
            limit: 2,
            sort: nil,
            filters: nil
        )

        XCTAssertTrue(firstPage.pagination.hasNextPage, "Seed should span more than one page")
        let cursor = try XCTUnwrap(firstPage.pagination.endCursor, "hasNextPage but no endCursor")

        let secondPage = try await sut.searchProducts(
            searchTerm: SeedAnchors.SearchTerms.many,
            after: cursor,
            limit: 2,
            sort: nil,
            filters: nil
        )

        // Assert the cursor advanced — page 2 brings at least one new result — rather than strict
        // disjointness, which a valid BFF can break at a page boundary (duplicate sort key).
        let firstIDs = Set(firstPage.products.map(\.id))
        let secondIDs = Set(secondPage.products.map(\.id))
        XCTAssertFalse(secondPage.products.isEmpty, "Second page should return results")
        XCTAssertFalse(secondIDs.subtracting(firstIDs).isEmpty, "Second page should contain at least one result not on the first page")
    }
}
