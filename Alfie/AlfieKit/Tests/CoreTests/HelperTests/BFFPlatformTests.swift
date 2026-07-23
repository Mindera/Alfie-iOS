import XCTest
import Model

final class BFFPlatformTests: XCTestCase {
    private var savedOverride: String?

    override func setUp() {
        super.setUp()
        savedOverride = UserDefaults.standard.string(forKey: BFFPlatformDebugStore.userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: BFFPlatformDebugStore.userDefaultsKey)
    }

    override func tearDown() {
        if let savedOverride {
            UserDefaults.standard.set(savedOverride, forKey: BFFPlatformDebugStore.userDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: BFFPlatformDebugStore.userDefaultsKey)
        }
        super.tearDown()
    }

    func test_raw_values_match_bff_contract() {
        // These strings are the contract sent as the `platform` argument — a rename/casing change
        // would silently break every BFF request.
        XCTAssertEqual(BFFPlatform.shopify.rawValue, "shopify")
        XCTAssertEqual(BFFPlatform.bigCommerce.rawValue, "bigcommerce")
    }

    func test_all_cases_cover_both_platforms() {
        XCTAssertEqual(BFFPlatform.allCases, [.shopify, .bigCommerce])
    }

    func test_debug_store_defaults_to_shopify_when_unset() {
        XCTAssertEqual(BFFPlatformDebugStore.selected, .shopify)
    }

    func test_predefined_defaults_to_shopify() {
        XCTAssertEqual(BFFPlatform.predefined, .shopify)
    }

    func test_debug_store_persists_selection() {
        BFFPlatformDebugStore.selected = .bigCommerce
        XCTAssertEqual(BFFPlatformDebugStore.selected, .bigCommerce)
    }

    func test_predefined_reflects_debug_override_in_debug_builds() {
        // Tests build with DEBUG defined, so `predefined` honors the stored override.
        BFFPlatformDebugStore.selected = .bigCommerce
        XCTAssertEqual(BFFPlatform.predefined, .bigCommerce)
    }
}
