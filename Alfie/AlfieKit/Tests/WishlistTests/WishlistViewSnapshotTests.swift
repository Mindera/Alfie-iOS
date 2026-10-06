import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Wishlist

/// No Variant carries an image URL: `RemoteImage` races between its placeholder and failure
/// branches, and `defaultImage()` compares at full precision.
final class WishlistViewSnapshotTests: XCTestCase {
    private let isRecording = false

    func test_wishlistView_populated() {
        let sut = NavigationStack {
            WishlistView(viewModel: MockWishlistViewModel(products: [
                selectedProduct(id: "1", name: "Structured Leather Crossbody Bag"),
                selectedProduct(id: "2", name: "Capucines BB"),
                selectedProduct(id: "3", name: "Low Key Hobo", stock: 0),
                selectedProduct(id: "4", name: "Double-Breasted Recycled Cashmere Blend Tailored Coat"),
            ]))
        }

        assertSnapshot(of: sut.embededInFullHeightContainer(), as: .defaultImage(), record: isRecording)
    }

    // MARK: - Helpers

    private func selectedProduct(id: String, name: String, stock: Int = 1) -> SelectedProduct {
        let variant = Product.Variant.fixture(sku: "sku-\(id)", stock: stock)
        return SelectedProduct(
            product: .fixture(
                id: id,
                name: name,
                brand: .fixture(name: "Mindera Test Store"),
                defaultVariant: variant,
                variants: [variant]
            )
        )
    }
}
