import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Bag

/// No line carries an image URL. `RemoteImage` races between its placeholder and failure branches,
/// and `defaultImage()` compares at full precision — the same reason the listing suite avoids them.
final class BagViewSnapshotTests: XCTestCase {
    private let isRecording = false

    func test_bagView_withLines() {
        let sut = BagView(viewModel: makeViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [
                .fixture(id: "line-1", name: "Silk Shirt", quantity: 2, unitPrice: money("£29.50"), lineTotal: money("£59.00")),
                .fixture(id: "line-2", name: "Wool Overcoat", quantity: 1, unitPrice: money("£180.00"), lineTotal: money("£180.00")),
            ],
            subtotal: money("£239.00"),
            grandTotal: money("£244.99")
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_withALineTheServerCouldNotPrice() {
        // A non-finite line total renders an em dash. £0.00 would read as "this item is free" (Q36).
        let sut = BagView(viewModel: makeViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [.fixture(id: "line-1", name: "Silk Shirt", quantity: 2, unitPrice: money("£29.50"), lineTotal: nil)],
            subtotal: money("£59.00"),
            grandTotal: money("£59.00")
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_withALineTheServerCouldNotName() {
        // `CartItem.name` is nullable. The row renders without a name rather than disappearing.
        let sut = BagView(viewModel: makeViewModel(state: .success(.fixture(
            id: "cart-1",
            lines: [.fixture(id: "line-1", name: nil, quantity: 1, unitPrice: money("£29.50"), lineTotal: money("£29.50"))],
            subtotal: money("£29.50"),
            grandTotal: money("£29.50")
        ))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_empty() {
        // No retry button: nothing has gone wrong (Q28/Q34).
        let sut = BagView(viewModel: makeViewModel(state: .success(nil)))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_loading() {
        let sut = BagView(viewModel: makeViewModel(state: .loading))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_genericError() {
        let sut = BagView(viewModel: makeViewModel(state: .error(.init(type: .generic))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_bagView_offlineError() {
        let sut = BagView(viewModel: makeViewModel(state: .error(.init(type: .noInternet))))

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    // MARK: - Helpers

    private func makeViewModel(state: ViewState<Cart?, BFFRequestError>) -> MockBagViewModel {
        MockBagViewModel(state: state)
    }

    private func money(_ formatted: String) -> Money {
        .fixture(currencyCode: "GBP", amount: 0, amountFormatted: formatted)
    }
}
