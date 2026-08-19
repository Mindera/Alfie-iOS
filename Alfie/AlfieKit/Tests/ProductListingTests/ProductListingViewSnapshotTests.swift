import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import ProductListing

/// Deliberately no image URLs anywhere in this suite, matching the Product Details one. Any real URL
/// puts `RemoteImage` in a race between its empty and failure branches, which paint very different
/// colours over most of every card, and `defaultImage()` compares at full precision. The fixture's
/// default variant carries no colour and so no media, leaving the card's reserved image slot —
/// deterministic, and the grid geometry these tests exist to cover is unaffected.
final class ProductListingViewSnapshotTests: XCTestCase {
    private let isRecording = false

    /// The default `precision: 1.0` fails on a single mismatched pixel, and glyph rasterisation
    /// differs slightly between iOS minor versions — CI records against 26.2, a developer may be on
    /// 26.4. Measured drift on this suite was 159 pixels of 5.3M (0.003%) at up to 10% delta, which
    /// clears `perceptualPrecision`'s 5% budget. 0.99 leaves ~300x headroom over that noise while
    /// still failing loudly on a real regression: a dropped card moves whole percent of the frame.
    private let precision: Float = 0.99

    /// Names vary in length on purpose: a one-line name and a wrapping two-line name in the same
    /// row are what make a card-alignment regression visible.
    private func makeProducts(_ count: Int) -> [Product] {
        let names = [
            "Structured Leather Crossbody Bag",
            "Capucines BB",
            "Low Key Hobo",
            "Neverful MM",
        ]
        return (0..<count).map { index in
            .fixture(
                id: "\(index)",
                name: names[index % names.count],
                brand: .fixture(name: "Mindera Test Store")
            )
        }
    }

    private func makeViewModel(
        products: [Product],
        state: PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>? = nil
    ) -> MockProductListingViewModel {
        let viewModel = MockProductListingViewModel(
            state: state ?? .success(.init(title: "Bags", products: products)),
            products: products
        )
        viewModel.title = "Bags"
        return viewModel
    }

    /// The default two-per-row grid, and the info bar's item count above it.
    func test_productListingView_gridStyle() {
        let viewModel = makeViewModel(products: makeProducts(4))
        viewModel.style = .grid
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }

    /// The one-per-row arrangement, where the card switches to its large size.
    func test_productListingView_listStyle() {
        let viewModel = makeViewModel(products: makeProducts(3))
        viewModel.style = .list
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }

    /// First-page load: the cards render as skeletons and the info bar hides its count.
    func test_productListingView_loadingFirstPage() {
        let products = makeProducts(4)
        let viewModel = makeViewModel(
            products: products,
            state: .loadingFirstPage(.init(title: "Bags", products: products))
        )
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }

    /// Pagination: the grid stays put and a loader is appended beneath it.
    func test_productListingView_loadingNextPage() {
        let products = makeProducts(4)
        let viewModel = makeViewModel(
            products: products,
            state: .loadingNextPage(.init(title: "Bags", products: products))
        )
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }

    /// The error overlay sits on top of an intentionally empty scroll view, so pull-to-refresh and
    /// the Retry button both survive the failure.
    func test_productListingView_errorState() {
        let viewModel = makeViewModel(products: [], state: .error(.generic))
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }

    /// `serverError` is one of only two cases with copy of its own — `generic`, `noInternet` and
    /// `noResults` all fall through to the same strings, so this is the branch worth pinning.
    func test_productListingView_serverErrorState() {
        let viewModel = makeViewModel(products: [], state: .error(.serverError))
        let sut = ProductListingView(viewModel: viewModel)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(precision: precision),
                       record: isRecording)
    }
}
