import Mocks
import Model
import SharedUI
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Bag

/// No line carries an image URL. `RemoteImage` races between its placeholder and failure branches,
/// and `defaultImage()` compares at full precision — the same reason the listing suite avoids them.
/// A line with no URL still reserves its image tile, so these references show the plain tile.
final class BagViewSnapshotTests: XCTestCase {
    private let isRecording = false

    func test_bagView_withLines() {
        let sut = BagView(viewModel: MockBagViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [
                .fixture(id: "line-1", name: "Silk Shirt", quantity: 2, lineTotal: money("£59.00")),
                .fixture(id: "line-2", name: "Wool Overcoat", quantity: 1, lineTotal: money("£180.00")),
                .fixture(
                    id: "line-3",
                    name: "Double-Breasted Recycled Cashmere Blend Tailored Coat",
                    quantity: 1,
                    lineTotal: money("£420.00")
                ),
            ],
            grandTotal: money("£664.99")
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_withALineTheServerCouldNotPrice() {
        // A non-finite line total renders an em dash. £0.00 would read as "this item is free".
        let sut = BagView(viewModel: MockBagViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [.fixture(id: "line-1", name: "Silk Shirt", quantity: 2, lineTotal: nil)],
            grandTotal: money("£59.00")
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    /// `CartItem.name` and `CartItem.image` are both nullable, and this fixture has neither:
    /// the row keeps its tile and its quantity and price, rather than disappearing.
    /// Snapshotted outside `BagView`: `List` resolved this row's height 1pt differently on CI than
    /// on the recording machine, and the claim is about the row, which lays out deterministically.
    func test_bagLineRow_withALineTheServerCouldNotName() {
        let row = BagLineRow(
            line: .fixture(
                id: "line-1",
                name: nil,
                quantity: 1,
                lineTotal: money("£29.50")
            ),
            onTap: {}
        )
        // `BagLineRow` carries its own horizontal inset, so the reference frames the row exactly as
        // the bag draws it. The `Spacer` only pins it to the top of the container and is not part of
        // what this asserts.
        let sut = VStack(spacing: 0) {
            row
            Spacer()
        }

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bag_view_with_an_unpriceable_total_shows_the_dash() {
        // The em dash covers every amount on the screen, not just the line total. The grand total
        // is the number a shopper checks before checking out, so a fabricated £0.00 is the worst
        // place of all to state a price they are not being charged.
        let sut = BagView(viewModel: MockBagViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [.fixture(id: "line-1", name: "Silk Shirt", quantity: 2, lineTotal: nil)],
            grandTotal: nil
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_empty() {
        let sut = BagView(viewModel: MockBagViewModel(state: .success(nil)))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_loading() {
        let sut = BagView(viewModel: MockBagViewModel(state: .loading))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_genericError() {
        let sut = BagView(viewModel: MockBagViewModel(state: .error(.init(type: .generic))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_offlineError() {
        let sut = BagView(viewModel: MockBagViewModel(state: .error(.init(type: .noInternet))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    // MARK: - Helpers

    /// The bag renders `amountFormatted` and never the numeric amount, so these fixtures carry the
    /// string that has to appear in the reference image and leave `amount` at its default. Nothing
    /// in a snapshot asserts on it.
    private func money(_ formatted: String) -> Money {
        .fixture(currencyCode: "GBP", amount: 0, amountFormatted: formatted)
    }
}
