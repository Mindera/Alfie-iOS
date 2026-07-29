@testable import Core
import Model
import XCTest

final class NavigationHandleMenuTests: XCTestCase {
    func test_header_maps_to_product_category_menu_handle() {
        XCTAssertEqual(NavigationHandle.header.bffMenuHandle, "product-category")
    }

    func test_other_handles_fall_back_to_raw_value() {
        XCTAssertEqual(NavigationHandle.footer.bffMenuHandle, "footer")
        XCTAssertEqual(NavigationHandle.social.bffMenuHandle, "social")
        XCTAssertEqual(NavigationHandle.topbar.bffMenuHandle, "topbar")
    }
}
