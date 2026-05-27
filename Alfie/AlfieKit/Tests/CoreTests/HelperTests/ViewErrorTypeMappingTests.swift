import Foundation
import Model
import XCTest

final class ProductListingViewErrorTypeMappingTests: XCTestCase {
    func test_maps_rate_limited() {
        let mapped = ProductListingViewErrorType.from(error: BFFRequestError(type: .rateLimited(retryAfter: 5)))
        XCTAssertEqual(mapped, .rateLimited)
    }

    func test_maps_server_error() {
        let mapped = ProductListingViewErrorType.from(error: BFFRequestError(type: .serverError(status: 503)))
        XCTAssertEqual(mapped, .serverError)
    }

    func test_maps_no_internet() {
        XCTAssertEqual(ProductListingViewErrorType.from(error: BFFRequestError(type: .noInternet)), .noInternet)
    }

    func test_maps_no_results_for_product_not_found() {
        XCTAssertEqual(ProductListingViewErrorType.from(error: BFFRequestError(type: .product(.noProduct))), .noResults)
        XCTAssertEqual(
            ProductListingViewErrorType.from(error: BFFRequestError(type: .product(.noProducts(category: nil, query: nil, sort: nil)))),
            .noResults
        )
    }

    func test_maps_timeout_to_generic() {
        XCTAssertEqual(ProductListingViewErrorType.from(error: BFFRequestError(type: .timeout)), .generic)
    }

    func test_maps_non_bff_to_generic() {
        struct OtherError: Error {}
        XCTAssertEqual(ProductListingViewErrorType.from(error: OtherError()), .generic)
    }
}

final class ProductDetailsViewErrorTypeMappingTests: XCTestCase {
    func test_maps_rate_limited() {
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .rateLimited(retryAfter: nil))), .rateLimited)
    }

    func test_maps_server_error() {
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .serverError(status: 502))), .serverError)
    }

    func test_maps_not_found_for_product_not_found() {
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .product(.noProduct))), .notFound)
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .emptyResponse)), .notFound)
    }

    func test_maps_no_internet() {
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .noInternet)), .noInternet)
    }

    func test_maps_generic() {
        XCTAssertEqual(ProductDetailsViewErrorType.from(error: BFFRequestError(type: .generic)), .generic)
    }
}

final class CategoriesViewErrorTypeMappingTests: XCTestCase {
    func test_maps_rate_limited() {
        XCTAssertEqual(CategoriesViewErrorType.from(error: BFFRequestError(type: .rateLimited(retryAfter: nil))), .rateLimited)
    }

    func test_maps_server_error() {
        XCTAssertEqual(CategoriesViewErrorType.from(error: BFFRequestError(type: .serverError(status: 500))), .serverError)
    }
}

final class BrandsViewErrorTypeMappingTests: XCTestCase {
    func test_maps_rate_limited() {
        XCTAssertEqual(BrandsViewErrorType.from(error: BFFRequestError(type: .rateLimited(retryAfter: nil))), .rateLimited)
    }

    func test_maps_server_error() {
        XCTAssertEqual(BrandsViewErrorType.from(error: BFFRequestError(type: .serverError(status: 500))), .serverError)
    }
}
