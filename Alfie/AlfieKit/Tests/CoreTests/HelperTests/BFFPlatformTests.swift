import XCTest
import Model

final class BFFPlatformTests: XCTestCase {
    func test_raw_values_match_bff_contract() {
        // These strings are the contract sent as the `productDetails(platform:)` argument —
        // a rename/casing change would silently break every product fetch.
        XCTAssertEqual(BFFPlatform.shopify.rawValue, "shopify")
        XCTAssertEqual(BFFPlatform.bigCommerce.rawValue, "bigcommerce")
    }

    func test_predefined_platform_is_shopify() {
        XCTAssertEqual(BFFPlatform.predefined, .shopify)
    }
}
