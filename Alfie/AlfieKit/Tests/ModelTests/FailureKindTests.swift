import Model
import TestUtils
import XCTest

final class FailureKindTests: XCTestCase {
    func test_every_bff_failure_maps_to_its_failure_kind() {
        for row in BFFFailureRow.all {
            XCTAssertEqual(FailureKind(error: row.error), row.kind, row.name)
        }
    }

    func test_plp_shows_no_results_for_not_found_and_the_failure_kind_otherwise() {
        for row in BFFFailureRow.all {
            XCTAssertEqual(ProductListingViewErrorType.from(error: row.error), row.plp, row.name)
        }
    }

    func test_pdp_shows_not_found_for_not_found_and_the_failure_kind_otherwise() {
        for row in BFFFailureRow.all {
            XCTAssertEqual(ProductDetailsViewErrorType.from(error: row.error), row.pdp, row.name)
        }
    }

    func test_categories_show_the_failure_kind() {
        for row in BFFFailureRow.all {
            XCTAssertEqual(CategoriesViewErrorType.from(error: row.error), row.categories, row.name)
        }
    }
}
