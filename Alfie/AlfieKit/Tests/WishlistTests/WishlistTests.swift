import Mocks
import Model
import ProductDetails
import TestUtils
import XCTest
@testable import Wishlist

final class WishlistTests: XCTestCase {
    // MARK: - WishlistViewModel.didTapAddToBag

    func test_didTapAddToBag_navigatesToProductDetailsWithSelectedProduct() {
        let colour = Product.Colour.fixture(id: "green", name: "Green")
        let variant = Product.Variant.fixture(size: .fixture(value: "M"), colour: colour)
        let product = Product.fixture(defaultVariant: variant, variants: [variant])
        let selected = SelectedProduct(product: product, selectedVariant: variant)
        var capturedRoutes: [WishlistRoute] = []
        let sut = makeSUT(navigate: { capturedRoutes.append($0) })

        sut.didTapAddToBag(for: selected)

        XCTAssertEqual(
            capturedRoutes,
            [.productDetails(.productDetails(.selectedProduct(selected)))]
        )
    }

    // MARK: - WishlistViewModel.didTapProduct

    func test_tapping_a_card_opens_product_details_for_that_variant() {
        let selected = SelectedProduct(product: .fixture(id: "product-1"))
        var capturedRoutes: [WishlistRoute] = []
        let sut = makeSUT(navigate: { capturedRoutes.append($0) })

        sut.didTapProduct(selected)

        XCTAssertEqual(
            capturedRoutes,
            [.productDetails(.productDetails(.selectedProduct(selected)))]
        )
    }

    // MARK: - WishlistViewModel.didSelectDelete

    func test_didSelectDelete_removesProductFromWishlistByProductId() {
        let blueVariant = Product.Variant.fixture(colour: .fixture(id: "blue", name: "Blue"))
        let redVariant = Product.Variant.fixture(colour: .fixture(id: "red", name: "Red"))
        let product = Product.fixture(id: "product-1", defaultVariant: redVariant, variants: [blueVariant, redVariant])
        let wishlistService = MockWishlistService(products: [
            SelectedProduct(product: product, selectedVariant: blueVariant),
            SelectedProduct(product: product, selectedVariant: redVariant)
        ])
        let sut = makeSUT(wishlistService: wishlistService)

        // The delete reloads `state` from the service; both variants share `product-1` so all go.
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isEmpty == true },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: product, selectedVariant: redVariant)) }
        )
    }

    func test_didSelectDelete_refreshesPublishedProducts() {
        let product = Product.fixture(id: "product-1")
        let wishlistService = MockWishlistService(products: [SelectedProduct(product: product)])
        let sut = makeSUT(wishlistService: wishlistService)

        XCTAssertEmitsValue(from: sut.$state, where: { $0.value?.count == 1 }, afterTrigger: { sut.viewDidAppear() })

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isEmpty == true },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: product)) }
        )
    }

    func test_removing_a_variant_tracks_the_removal_with_its_product_id() {
        let product = Product.fixture(id: "product-1")
        let analytics = MockAnalyticsTracker()
        let sut = makeSUT(
            wishlistService: MockWishlistService(products: [SelectedProduct(product: product)]),
            analytics: analytics
        )

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isEmpty == true },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: product)) }
        )

        XCTAssertEqual(analytics.trackedValues(of: .productID, for: .removeFromWishlist), ["product-1"])
    }

    // MARK: - WishlistViewModel.state

    func test_the_wishlist_is_loading_until_it_first_appears() {
        let sut = makeSUT()

        XCTAssertTrue(sut.state.isLoading)
    }

    func test_a_wishlist_with_nothing_saved_is_empty() {
        let sut = makeSUT()

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isEmpty == true },
            afterTrigger: { sut.viewDidAppear() }
        )
    }

    func test_a_variant_saved_elsewhere_shows_when_the_wishlist_appears_again() {
        let saved = SelectedProduct(product: .fixture(id: "product-1"))
        let wishlistService = MockWishlistService()
        let sut = makeSUT(wishlistService: wishlistService)
        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.isEmpty == true },
            afterTrigger: { sut.viewDidAppear() }
        )
        save(saved, in: wishlistService)

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value == [saved] },
            afterTrigger: { sut.viewDidAppear() }
        )
    }

    // MARK: - Helpers

    private func save(_ selectedProduct: SelectedProduct, in wishlistService: MockWishlistService) {
        let hasSaved = expectation(description: "The Variant is saved")
        Task {
            await wishlistService.addProduct(selectedProduct)
            hasSaved.fulfill()
        }
        wait(for: [hasSaved], timeout: .default)
    }

    private func makeSUT(
        wishlistService: WishlistServiceProtocol = MockWishlistService(),
        analytics: MockAnalyticsTracker = MockAnalyticsTracker(),
        navigate: @escaping (WishlistRoute) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> WishlistViewModel {
        let dependencies = WishlistDependencyContainer(
            wishlistService: wishlistService,
            analytics: analytics.eraseToAnyAnalyticsTracker()
        )
        let sut = WishlistViewModel(
            hasNavigationSeparator: false,
            dependencies: dependencies,
            navigate: navigate
        )
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
