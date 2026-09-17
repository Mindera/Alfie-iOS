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
        // Not asserting on `sku`: the seed store's variants may carry an empty one.
        // The default variant must surface media so the PDP carousel isn't blank
        // (see the media fallback in ProductDetails+Converter).
        XCTAssertFalse(product.defaultVariant.media.isEmpty,
                       "The default variant should surface media for the PDP carousel")
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

    // MARK: - Related products

    func test_related_products_for_handle_without_recommendations_are_empty() async throws {
        let products = try await sut.relatedProducts(
            handle: IntegrationSeed.handleWithoutRelatedProducts,
            limit: Constants.relatedProductsLimit
        )

        XCTAssertTrue(products.isEmpty)
    }

    func test_related_products_for_seeded_handle_are_complete_list_items_within_limit() async throws {
        let related = try await firstNonEmptyRelatedProducts()

        let products = try XCTUnwrap(related, "No seeded product in '\(IntegrationSeed.collectionHandle)' returned related products")

        XCTAssertLessThanOrEqual(products.count, Constants.relatedProductsLimit)
        XCTAssertFalse(products.contains { $0.id.isEmpty })
        XCTAssertFalse(products.contains { $0.name.isEmpty })
        XCTAssertFalse(products.contains { $0.slug.isEmpty })
    }

    // MARK: - Helpers

    private func firstNonEmptyRelatedProducts() async throws -> [Product]? {
        let listing = try await sut.productList(
            collectionHandle: IntegrationSeed.collectionHandle,
            after: nil,
            limit: Constants.relatedProductsCandidateCount,
            sort: nil,
            filters: nil
        )
        for candidate in listing.products {
            let products = try await sut.relatedProducts(handle: candidate.slug, limit: Constants.relatedProductsLimit)
            if !products.isEmpty {
                return products
            }
        }
        return nil
    }

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

private enum Constants {
    static let relatedProductsLimit = 3
    static let relatedProductsCandidateCount = 5
}
