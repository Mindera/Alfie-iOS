import Model
import XCTest

/// Exercises the real `productList` operation against a running BFF. Assertions are structural
/// (decoding correctness, pagination/cursor behavior) rather than seed-specific values.
final class ProductListIntegrationTests: IntegrationTestCase {
    func test_productList_happyPath_returnsWellFormedProducts() async throws {
        let listing = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: 10,
            sort: nil,
            filters: nil
        )

        try XCTSkipUnless(!listing.products.isEmpty, "Seed BFF returned no products for \(IntegrationSeed.collectionHandle)")
        for product in listing.products {
            XCTAssertFalse(product.id.isEmpty)
            XCTAssertFalse(product.name.isEmpty)
        }
    }

    func test_productList_pagination_secondPageDiffersFromFirst() async throws {
        let firstPage = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: 2,
            sort: nil,
            filters: nil
        )

        try XCTSkipUnless(firstPage.pagination.hasNextPage, "Not enough seed data for a second page")
        let cursor = try XCTUnwrap(firstPage.pagination.endCursor, "hasNextPage but no endCursor")

        let secondPage = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: cursor,
            limit: 2,
            sort: nil,
            filters: nil
        )

        // Assert the cursor advanced — page 2 brings at least one new product — rather than strict
        // disjointness, which a valid BFF can break at a page boundary (duplicate sort key).
        let firstIDs = Set(firstPage.products.map(\.id))
        let secondIDs = Set(secondPage.products.map(\.id))
        XCTAssertFalse(secondPage.products.isEmpty, "Second page should return products")
        XCTAssertFalse(secondIDs.subtracting(firstIDs).isEmpty, "Second page should contain at least one product not on the first page")
    }

    func test_productList_sort_returnsWellFormedPage() async throws {
        // Assert the sorted request round-trips and decodes; order semantics aren't contracted here.
        let listing = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: 10,
            sort: IntegrationSeed.sortLowToHigh,
            filters: nil
        )

        XCTAssertTrue(listing.products.allSatisfy { !$0.id.isEmpty })
    }

    func test_productList_filter_returnsWellFormedPage() async throws {
        // A filter may legitimately narrow results to empty; only require a well-formed, decodable page.
        let listing = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: 10,
            sort: nil,
            filters: ProductFilterInput(inventory: true)
        )

        XCTAssertTrue(listing.products.allSatisfy { !$0.id.isEmpty })
    }
}
