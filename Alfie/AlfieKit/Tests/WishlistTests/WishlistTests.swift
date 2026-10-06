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

    // MARK: - Undoing a removal

    func test_removing_a_variant_hides_it_and_offers_to_undo() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2")))

        remove("p1", from: sut)

        XCTAssertEqual(sut.state.value?.map(\.product.id), ["p2"])
        XCTAssertNotNil(sut.undoableRemoval)
    }

    func test_undo_restores_the_first_variant_at_the_first_position() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p1", from: sut)

        undoRemoval(in: sut, restoring: ["p1", "p2", "p3"])
    }

    func test_undo_restores_a_middle_variant_between_its_neighbours() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p2", from: sut)

        undoRemoval(in: sut, restoring: ["p1", "p2", "p3"])
    }

    func test_undo_restores_the_last_variant_at_the_last_position() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p3", from: sut)

        undoRemoval(in: sut, restoring: ["p1", "p2", "p3"])
    }

    func test_undo_restores_every_variant_of_the_removed_product_at_its_position() {
        let blue = Product.Variant.fixture(sku: "blue")
        let red = Product.Variant.fixture(sku: "red")
        let product = Product.fixture(id: "p1", defaultVariant: blue, variants: [blue, red])
        let content = [
            SelectedProduct(product: product, selectedVariant: blue),
            SelectedProduct(product: .fixture(id: "p2")),
            SelectedProduct(product: product, selectedVariant: red)
        ]
        let sut = makeSUT(wishlistService: MockWishlistService(products: content))
        remove("p1", from: sut)

        XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value == content },
            afterTrigger: { sut.didTapUndoRemoval() }
        )
    }

    func test_undo_no_longer_offers_to_undo() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2")))
        remove("p1", from: sut)

        undoRemoval(in: sut, restoring: ["p1", "p2"])

        XCTAssertNil(sut.undoableRemoval)
    }

    func test_undo_after_a_second_removal_restores_only_the_second() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p1", from: sut)
        remove("p3", from: sut)

        undoRemoval(in: sut, restoring: ["p2", "p3"])
    }

    func test_starting_a_second_removal_makes_the_first_final() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p1", from: sut)
        var isFirstStillUndoable = true

        XCTAssertEmitsValue(
            from: sut.$undoableRemoval,
            where: { $0 != nil },
            afterTrigger: {
                sut.didSelectDelete(for: SelectedProduct(product: .fixture(id: "p3")))
                isFirstStillUndoable = sut.undoableRemoval != nil
            }
        )

        XCTAssertFalse(isFirstStillUndoable)
    }

    func test_a_second_removal_is_a_new_removal_to_undo() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2", "p3")))
        remove("p1", from: sut)
        let first = sut.undoableRemoval

        remove("p3", from: sut)

        XCTAssertNotEqual(sut.undoableRemoval?.id, first?.id)
    }

    func test_a_removal_is_final_once_the_snackbar_dismisses() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1", "p2")))
        remove("p1", from: sut)

        sut.didDismissRemovalSnackbar()

        XCTAssertNil(sut.undoableRemoval)
    }

    func test_removing_the_last_variant_empties_the_wishlist_and_offers_to_undo() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1")))

        remove("p1", from: sut)

        XCTAssertEqual(sut.state.value, [])
        XCTAssertNotNil(sut.undoableRemoval)
    }

    func test_undo_of_the_last_variant_brings_the_grid_back() {
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1")))
        remove("p1", from: sut)

        undoRemoval(in: sut, restoring: ["p1"])
    }

    func test_undo_tracks_an_add_to_wishlist_with_the_product_id() {
        let analytics = MockAnalyticsTracker()
        let sut = makeSUT(wishlistService: MockWishlistService(products: saved("p1")), analytics: analytics)
        remove("p1", from: sut)

        undoRemoval(in: sut, restoring: ["p1"])

        XCTAssertEqual(analytics.trackedValues(of: .productID, for: .addToWishlist), ["p1"])
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

    private func saved(_ productIds: String...) -> [SelectedProduct] {
        productIds.map { SelectedProduct(product: .fixture(id: $0)) }
    }

    private func remove(
        _ productId: String,
        from sut: WishlistViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let removal = XCTAssertEmitsValue(
            from: sut.$undoableRemoval,
            where: { $0 != nil },
            afterTrigger: { sut.didSelectDelete(for: SelectedProduct(product: .fixture(id: productId))) }
        )
        XCTAssertNotNil(removal, file: file, line: line)
    }

    private func undoRemoval(
        in sut: WishlistViewModel,
        restoring productIds: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let restored = XCTAssertEmitsValue(
            from: sut.$state,
            where: { $0.value?.map(\.product.id) == productIds },
            afterTrigger: { sut.didTapUndoRemoval() }
        )
        XCTAssertNotNil(restored, file: file, line: line)
    }

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
