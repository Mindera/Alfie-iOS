import BFFGraph
@testable import Core
import XCTest

final class ProductSortConverterTests: XCTestCase {
    func test_sort_option_mapping() {
        // The Refine sheet stores raw `SortByType` strings. We map each one (and any
        // missing/unknown value) into a BFF `ProductSortEnum` at the BFF boundary.
        let cases: [(input: String?, expected: BFFGraphAPI.ProductSortEnum, label: String)] = [
            ("HIGH_TO_LOW", .priceDesc, "price: high → low"),
            ("LOW_TO_HIGH", .priceAsc,  "price: low → high"),
            ("A_Z",         .nameAsc,   "alpha A → Z"),
            ("Z_A",         .newest,    "alpha Z → A falls back (BFF lacks NAME_DESC)"),
            (nil,           .newest,    "nil → default NEWEST"),
            ("BOGUS",       .newest,    "unknown raw value → default NEWEST")
        ]

        for (input, expected, label) in cases {
            XCTAssertEqual(
                BFFGraphAPI.ProductSortEnum.from(sortOption: input),
                expected,
                label
            )
        }
    }
}
