import XCTest
import Models

final class BFFRequestErrorTests: XCTestCase {
    func test_bffrequesterror_is_not_found_for_no_product_error() {
        let sut = BFFRequestError(type: .product(.noProduct))
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_notfound_for_no_products_error() {
        let sut = BFFRequestError(type: .product(.noProducts(category: nil, query: nil, sort: nil)))
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_generic_products_error() {
        let sut = BFFRequestError(type: .product(.generic))
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_found_for_empty_response_error() {
        let sut = BFFRequestError(type: .emptyResponse)
        XCTAssertTrue(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_no_internet_error() {
        let sut = BFFRequestError(type: .noInternet)
        XCTAssertFalse(sut.isNotFound)
    }

    func test_bffrequesterror_is_not_notfound_for_generic_error() {
        let sut = BFFRequestError(type: .generic)
        XCTAssertFalse(sut.isNotFound)
    }
}
