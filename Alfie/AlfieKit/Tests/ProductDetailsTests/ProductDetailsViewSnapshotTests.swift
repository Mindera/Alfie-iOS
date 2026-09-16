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
        let viewModel = MockProductDetailsViewModel(
            state: .success(.init(product: .fixture(), selectedVariant: .fixture())),
            productId: "0273393",
            productTitle: "Tommy Hilfiger",
            productName: "Nolita SW Signature Loafer",
            productDescription: "A refined loafer in soft nappa leather with a signature hardware detail.",
            selectedColourName: "Black",
            productReference: "0273/393",
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
        viewModel.onShouldShowSectionCalled = { $0 != .relatedProducts }
        return viewModel
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
        //
        // This is also the reference that pins the availability note below the size chips: at
        // `precision: 1.0` the case cannot pass with that line missing.
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

    /// The size run that wraps: every size stays inline whatever the count, so the second and third
    /// rows keep the first row's chip width, and each chip state renders at once.
    func test_productDetailsView_withManySizes() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.sizingSelectionConfiguration = .init(
            items: [
                .init(id: "1", name: "XS", state: .available),
                .init(id: "2", name: "S", state: .available),
                .init(id: "3", name: "M", state: .outOfStock),
                .init(id: "4", name: "L", state: .available),
                .init(id: "5", name: "XL", state: .unavailable),
                .init(id: "6", name: "XXL", state: .available),
                .init(id: "7", name: "XXXL", state: .available),
                .init(id: "8", name: "XXXXL", state: .outOfStock),
            ],
            selectedItem: .init(id: "2", name: "S", state: .available)
        )
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Past the inline limit the cards give way to the summary, which opens the sheet — so with a
    /// colour selected the page body carries no colour section at all.
    func test_productDetailsView_withManyColours() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.colorSelectionConfiguration = .init(
            items: (1...7).map { .init(id: "\($0)", name: "Colour \($0)", type: .color(.black)) },
            selectedItem: .init(id: "1", name: "Colour 1", type: .color(.black))
        )
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The state that had no colour affordance at all: past the inline limit the grid is gone, and
    /// with no selected colour the summary has no swatch to draw — so the heading itself must open
    /// the sheet.
    func test_productDetailsView_withManyColoursAndNoSelection() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.colorSelectionConfiguration = .init(
            items: (1...7).map { .init(id: "\($0)", name: "Colour \($0)", type: .color(.black)) },
            selectedItem: nil
        )
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// A product with no marketing copy still shows the colour and reference — they are what a
    /// shopper quotes to customer service.
    func test_productDetailsView_withoutDescription() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.productDescription = ""
        viewModel.onShouldShowSectionCalled = { $0 != .productDescription && $0 != .relatedProducts }
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Every section shimmering at once — the state a shopper sees before the product resolves.
    /// The availability note is absent: it qualifies availability, and until the product resolves the
    /// swatches are shimmer placeholders with no availability to qualify. The mock defaults every
    /// section to visible, so the real view model's gating has to be restated here.
    func test_productDetailsView_loadingState() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.onShouldShowLoadingForSectionCalled = { _ in true }
        viewModel.onShouldShowSectionCalled = { $0 != .availabilityNote }
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// Every size out of stock: `canShowSize` drops the whole selector rather than offering a grid
    /// where nothing is buyable.
    func test_productDetailsView_withEverySizeOutOfStock() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.sizingSelectionConfiguration = .init(
            items: [
                .init(id: "1", name: "S", state: .outOfStock),
                .init(id: "2", name: "M", state: .outOfStock),
                .init(id: "3", name: "L", state: .outOfStock),
            ],
            selectedItem: nil
        )
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// The add-to-bag CTA mid-write. The in-flight state is the whole point of the ticket that
    /// introduced it, and it is the one CTA state no other snapshot reaches.
    func test_productDetailsView_addingToBag() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.isAddingToBag = true
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_with_six_related_products() {
        assertRelatedProductsSnapshot(state: .success(relatedProducts(count: 6)))
    }

    func test_product_details_view_with_three_related_products() {
        assertRelatedProductsSnapshot(state: .success(relatedProducts(count: 3)))
    }

    func test_product_details_view_while_related_products_load_shows_skeleton() {
        assertRelatedProductsSnapshot(state: .loading)
    }

    private func assertRelatedProductsSnapshot(
        state: ViewState<[Product], ProductDetailsViewErrorType>,
        testName: String = #function
    ) {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.onShouldShowSectionCalled = { _ in true }
        viewModel.onShouldShowLoadingForSectionCalled = { $0 == .relatedProducts && state.isLoading }
        viewModel.relatedProductsState = state
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInContainer(height: Constants.relatedProductsSnapshotHeight),
                       as: .defaultImage(),
                       record: isRecording,
                       testName: testName)
    }

    private func relatedProducts(count: Int) -> [Product] {
        (1...count).map { .fixture(id: "related-\($0)") }
    }

    /// The CTA once the bag already holds the variant: the stepper stands in its place, at the same
    /// height and squared corners, so the row below it does not shift when the swap happens.
    func test_productDetailsView_withItemInBag() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.bagQuantity = 2
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// At the server's per-line ceiling the increase is greyed and the decrease is not — the one
    /// state where the stepper's two halves differ.
    func test_productDetailsView_atMaximumBagQuantity() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.bagQuantity = viewModel.maxBagQuantity
        let sut = ProductDetailsView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    /// A quantity change in flight: both halves greyed, so a second tap has no affordance behind it.
    func test_productDetailsView_whileChangingBagQuantity() {
        let viewModel = makeViewModel()
        viewModel.priceType = .default(price: "£450.00")
        viewModel.bagQuantity = 2
        viewModel.isUpdatingBagQuantity = true
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

private enum Constants {
    static let relatedProductsSnapshotHeight: CGFloat = 2400
}
