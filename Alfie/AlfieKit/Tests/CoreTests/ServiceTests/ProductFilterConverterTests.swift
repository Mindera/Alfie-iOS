import ApolloAPI
import BFFGraph
@testable import Core
import Model
import XCTest

final class ProductFilterConverterTests: XCTestCase {
    func test_nil_domain_collapses_to_none() {
        let result = BFFGraphAPI.ProductFilterInput.from(domain: nil)

        guard case .none = result else {
            XCTFail("Expected .none for nil domain input, got \(result)")
            return
        }
    }

    func test_full_filter_forwards_all_fields() throws {
        let metafield = MetafieldFilterInput(key: "k", namespace: "ns", value: "v")
        let domain = ProductFilterInput(
            brandNames: ["Acme", "Globex"],
            inventory: true,
            maxPrice: 500.0,
            metafields: [metafield],
            minPrice: 10.0,
            productTypes: ["Shoes"]
        )

        let result = BFFGraphAPI.ProductFilterInput.from(domain: domain)

        guard case .some(let bff) = result else {
            XCTFail("Expected .some, got \(result)")
            return
        }
        XCTAssertEqual(bff.brandNames.unwrapped, ["Acme", "Globex"])
        XCTAssertEqual(bff.inventory.unwrapped, true)
        XCTAssertEqual(bff.maxPrice.unwrapped, 500.0)
        XCTAssertEqual(bff.minPrice.unwrapped, 10.0)
        XCTAssertEqual(bff.productTypes.unwrapped, ["Shoes"])

        let mappedMetafields = try XCTUnwrap(bff.metafields.unwrapped)
        XCTAssertEqual(mappedMetafields.count, 1)
        XCTAssertEqual(mappedMetafields.first?.key, "k")
        XCTAssertEqual(mappedMetafields.first?.namespace, "ns")
        XCTAssertEqual(mappedMetafields.first?.value, "v")
    }

    func test_partial_filter_omits_unset_dimensions() {
        let domain = ProductFilterInput(brandNames: ["Acme"])

        let result = BFFGraphAPI.ProductFilterInput.from(domain: domain)

        guard case .some(let bff) = result else {
            XCTFail("Expected .some, got \(result)")
            return
        }
        XCTAssertEqual(bff.brandNames.unwrapped, ["Acme"])
        XCTAssertNil(bff.inventory.unwrapped)
        XCTAssertNil(bff.maxPrice.unwrapped)
        XCTAssertNil(bff.minPrice.unwrapped)
        XCTAssertNil(bff.metafields.unwrapped)
        XCTAssertNil(bff.productTypes.unwrapped)
    }
}

// MARK: - GraphQLNullable test helpers

private extension GraphQLNullable {
    var unwrapped: Wrapped? {
        if case .some(let value) = self { return value }
        return nil
    }
}
