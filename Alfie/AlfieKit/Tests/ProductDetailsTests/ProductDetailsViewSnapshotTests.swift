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
        // The gallery renders empty: its images are remote, and loading them would make the
        // baseline network-dependent. The carousel still reserves its height, so the layout below
        // it — which is what this ticket changes — is positioned exactly as in the real screen.
        viewModel.shouldShowMediaPaginatedControl = false
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
