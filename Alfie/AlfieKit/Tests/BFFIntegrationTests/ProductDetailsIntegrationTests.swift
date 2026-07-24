import Model
import XCTest

/// Exercises the real `getProduct` operation. A product handle is discovered by chaining off
/// `productList` (resolving by `slug`) so the test stays seed-agnostic.
final class ProductDetailsIntegrationTests: IntegrationTestCase {
    func test_getProduct_happyPath_returnsProduct() async throws {
        let slug = try await firstProductSlug()

        let product = try await sut.getProduct(handle: slug)

        XCTAssertFalse(product.id.isEmpty)
        XCTAssertFalse(product.name.isEmpty)
        XCTAssertFalse(product.brand.name.isEmpty)
        XCTAssertEqual(product.slug, slug)
    }

    func test_getProduct_variantsSurface() async throws {
        let slug = try await firstProductSlug()

        let product = try await sut.getProduct(handle: slug)

        XCTAssertFalse(product.variants.isEmpty, "Product details should expose at least one variant")
        // Not asserting on `sku`: every variant in the seed store has an empty one.
        XCTAssertTrue(product.variants.contains(product.defaultVariant),
                      "The default variant should be one of the product's variants")
    }

    func test_getProduct_unknownHandle_throwsBFFRequestError() async throws {
        do {
            _ = try await sut.getProduct(handle: "alfie-integration-nonexistent-slug-000")
            XCTFail("Expected an error for an unknown product handle")
        } catch is BFFRequestError {
            // Expected: the typed catch is the assertion. Sub-type (no-product vs GraphQL-errors vs
            // HTTP) is BFF-dependent, so we don't pin it.
        } catch {
            XCTFail("Expected BFFRequestError, got \(type(of: error)): \(error)")
        }
    }

    // MARK: - Helpers

    /// Fetches the first available product's slug, skipping the test when the seed BFF has no products.
    private func firstProductSlug() async throws -> String {
        let listing = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: 1,
            sort: nil,
            filters: nil
        )
        try XCTSkipUnless(!listing.products.isEmpty, "Seed BFF returned no products to fetch details for")
        return try XCTUnwrap(listing.products.first).slug
    }
}
