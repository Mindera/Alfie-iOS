import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import ProductDetails

final class ProductDetailsViewSnapshotTests: XCTestCase {
    private let isRecording = false

    private func makeViewModel() -> MockProductDetailsViewModel {
        .init(
            state: .success(.init(product: .fixture(), selectedVariant: .fixture())),
            productId: "0273393",
            productTitle: "Tommy Hilfiger",
            productName: "Nolita SW Signature Loafer",
            productDescription: "A refined loafer in soft nappa leather with a signature hardware detail.",
            colorSelectionConfiguration: .init(
                items: [
                    .init(id: "1", name: "Black", type: .color(.black)),
                    .init(id: "2", name: "Tan", type: .color(.brown)),
                ],
                selectedItem: .init(id: "1", name: "Black", type: .color(.black))
            ),
            sizingSelectionConfiguration: .init(
                items: [
                    .init(id: "1", name: "S", state: .available),
                    .init(id: "2", name: "M", state: .available),
                    .init(id: "3", name: "L", state: .outOfStock),
                ],
                selectedItem: .init(id: "1", name: "S", state: .available)
            ),
            complementaryInfoToShow: [.delivery, .paymentOptions, .returns]
        )
    }

    func test_productDetailsView_defaultState() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        // Deliberately no image URLs. Any real URL puts `RemoteImage` in a race between its empty
        // and failure branches — which paint very different colours over a third of the frame — and
        // `defaultImage()` compares at full precision. With none, the gallery renders its reserved
        // placeholder slot: a solid square, no network, no animation, so the full-bleed band and
        // everything positioned below it are covered deterministically.
        // Still NOT covered: the pagination indicators, which need one image per dot.
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The hiding half of both new elements: no brand line, and no colour summary for a
    /// single-colour product.
    func test_productDetailsView_withoutBrandOrColourChoice() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.productTitle = ""
        viewModel.colorSelectionConfiguration = .init(
            items: [.init(id: "1", name: "Black", type: .color(.black))],
            selectedItem: .init(id: "1", name: "Black", type: .color(.black))
        )
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_productDetailsView_errorState() {
        let viewModel = makeViewModel()
        viewModel.state = .error(.generic)
        let sut = ProductDetailsView(viewModel: viewModel, showFailureState: true)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
