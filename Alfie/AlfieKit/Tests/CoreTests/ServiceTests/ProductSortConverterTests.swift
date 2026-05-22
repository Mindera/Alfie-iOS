import BFFGraph
@testable import Core
import XCTest

final class ProductSortConverterTests: XCTestCase {
    func test_maps_price_high_to_low() {
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: "HIGH_TO_LOW"), .priceDesc)
    }

    func test_maps_price_low_to_high() {
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: "LOW_TO_HIGH"), .priceAsc)
    }

    func test_maps_alpha_ascending() {
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: "A_Z"), .nameAsc)
    }

    func test_alpha_descending_falls_back_to_newest_pending_bff_support() {
        // BFF doesn't yet expose NAME_DESC — Z_A intentionally falls back to NEWEST until
        // the BFF team adds the enum case.
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: "Z_A"), .newest)
    }

    func test_nil_falls_back_to_newest() {
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: nil), .newest)
    }

    func test_unknown_value_falls_back_to_newest() {
        XCTAssertEqual(BFFGraphAPI.ProductSortEnum.from(sortOption: "BOGUS"), .newest)
    }
}
