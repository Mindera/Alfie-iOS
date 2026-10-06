import Mocks
import XCTest
@testable import Model

final class VerticalProductCardViewModelTests: XCTestCase {
    func test_card_for_a_saved_variant_in_stock_enables_add_to_bag() {
        let card = makeCard(stock: 3)

        XCTAssertFalse(card.isAddToBagDisabled)
    }

    func test_card_for_a_saved_variant_out_of_stock_disables_add_to_bag() {
        let card = makeCard(stock: 0)

        XCTAssertTrue(card.isAddToBagDisabled)
    }

    func test_card_for_a_saved_variant_shows_its_brand_and_product_name() {
        let card = makeCard(stock: 1)

        XCTAssertEqual(card.productId, "product-1-sku-1")
        XCTAssertEqual(card.designer, "Mindera")
        XCTAssertEqual(card.name, "Capucines BB")
    }

    // MARK: - Helpers

    private func makeCard(stock: Int) -> VerticalProductCardViewModel {
        let variant = Product.Variant.fixture(sku: "sku-1", stock: stock)
        return VerticalProductCardViewModel(
            configuration: .init(size: .medium),
            selectedProduct: SelectedProduct(
                product: .fixture(
                    id: "product-1",
                    name: "Capucines BB",
                    brand: .fixture(name: "Mindera"),
                    defaultVariant: variant,
                    variants: [variant]
                )
            ),
            addToBagTitle: "Add to Bag",
            outOfStockTitle: "Out of stock"
        )
    }
}
