import AlicerceLogging
import Combine
import CombineSchedulers
import Mocks
import Model
import TestUtils
import XCTest
@testable import ProductDetails

final class ProductDetailsViewModelBagTests: XCTestCase {
    private var sut: ProductDetailsViewModel!
    private var mockCartService: MockCartService!
    private var mockAnalytics: MockAnalyticsTracker!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsTracker()
        scheduler = DispatchQueue.test
        sut = ProductDetailsViewModel(
            configuration: .product(twoColourProduct()),
            dependencies: ProductDetailsDependencyContainer(
                scheduler: scheduler.eraseToAnyScheduler(),
                productService: MockProductService(),
                webUrlProvider: MockWebUrlProvider(),
                cartService: mockCartService,
                wishlistService: MockWishlistService(),
                configurationService: MockConfigurationService(),
                analytics: mockAnalytics.eraseToAnyAnalyticsTracker(),
                log: Log.DummyLogger()
            ),
            goBackAction: {},
            openWebfeatureAction: { _ in },
            openProductAction: { _ in }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCartService = nil
        mockAnalytics = nil
        scheduler = nil
        try super.tearDownWithError()
    }

    func test_a_cart_change_notifies_the_view_models_observers() {
        var notifications = 0
        let subscription = sut.objectWillChange.sink { notifications += 1 }

        holdInBag(quantity: 3)

        XCTAssertGreaterThan(notifications, 0)
        XCTAssertEqual(sut.bagQuantity, 3)
        subscription.cancel()
    }

    func test_bag_quantity_step_tracks_the_product_tapped_even_when_the_colour_changes_before_the_write() {
        mockCartService.onSetQuantityCalled = { _, quantity in self.cartHolding(quantity: quantity) }
        holdInBag(quantity: 1)
        sut.didTapIncreaseBagQuantity()

        sut.didSelectColour(sut.variantSelection.colours[1])
        scheduler.advance(by: .milliseconds(500))

        XCTAssertEmitsValueEqualTo(from: sut.$isUpdatingBagQuantity, expectedValue: false)
        XCTAssertEqual(mockAnalytics.trackedProductIDs(for: .addToBag), ["product-1-sku-a"])
    }

    private func holdInBag(quantity: Int) {
        mockCartService.send(cart: cartHolding(quantity: quantity))
        scheduler.advance()
    }

    private func cartHolding(quantity: Int) -> Cart {
        .fixture(lines: [.fixture(id: "line-1", variantId: "variant-a", quantity: quantity)])
    }

    private func twoColourProduct() -> Product {
        let size = Product.ProductSize.fixture(id: "s", value: "S")
        let colourA = Product.Variant.fixture(
            id: "variant-a",
            sku: "sku-a",
            size: size,
            colour: .fixture(id: "a", name: "Colour A"),
            stock: 5
        )
        let colourB = Product.Variant.fixture(
            id: "variant-b",
            sku: "sku-b",
            size: size,
            colour: .fixture(id: "b", name: "Colour B"),
            stock: 5
        )
        return Product.fixture(id: "product-1", defaultVariant: colourA, variants: [colourA, colourB])
    }
}
