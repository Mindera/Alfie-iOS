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

    func test_a_wishlist_with_saved_variants_shows_the_grid() {
        let sut = NavigationStack {
            WishlistView(viewModel: MockWishlistViewModel(state: .success([
                selectedProduct(id: "1", name: "Structured Leather Crossbody Bag"),
                selectedProduct(id: "2", name: "Capucines BB"),
                selectedProduct(id: "3", name: "Low Key Hobo", stock: 0),
                selectedProduct(id: "4", name: "Double-Breasted Recycled Cashmere Blend Tailored Coat"),
            ])))
        }

        assertSnapshot(of: sut.embededInFullHeightContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_a_wishlist_after_a_removal_shows_the_removed_snackbar() {
        let sut = NavigationStack {
            WishlistView(
                viewModel: MockWishlistViewModel(
                    state: .success([
                        selectedProduct(id: "1", name: "Structured Leather Crossbody Bag"),
                        selectedProduct(id: "3", name: "Low Key Hobo", stock: 0),
                        selectedProduct(id: "4", name: "Double-Breasted Recycled Cashmere Blend Tailored Coat"),
                    ]),
                    undoableRemoval: WishlistRemoval(
                        productId: "2",
                        from: [selectedProduct(id: "2", name: "Capucines BB")]
                    )
                )
            )
        }

        assertSnapshot(of: sut.embededInFullHeightContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_a_wishlist_with_nothing_saved_shows_the_empty_state() {
        let sut = NavigationStack {
            WishlistView(viewModel: MockWishlistViewModel(state: .success([])))
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
