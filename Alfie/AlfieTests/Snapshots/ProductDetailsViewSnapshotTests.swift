import Foundation
import Mocks
import Models
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class ProductDetailsViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: ProductDetailsView<MockProductDetailsViewModel>!
    private var mockViewModel: MockProductDetailsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init()
        sut = .init(viewModel: mockViewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockViewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Success

    func test_product_details_view_loaded_state() {
        buildDefaultMock()
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_loaded_state_with_single_media() {
        buildDefaultMock()
        mockViewModel.productImageUrls = [
            URL(filePath: ""),
        ]
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_loaded_state_with_no_media() {
        buildDefaultMock()
        mockViewModel.onShouldShowSectionCalled = { section in
            section != .mediaCarousel
        }
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_loaded_state_single_color() {
        buildDefaultMock()
        let swatches = [
            ColorSwatch(name: "Red", type: .color(.red)),
        ]
        mockViewModel.colorSelectionConfiguration = .init(items: swatches, selectedItem: swatches.first)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_loaded_state_many_many_colors() {
        buildDefaultMock()
        let swatches = Array.init(repeating: ColorSwatch(name: "Red", type: .color(.red)), count: 10)
        mockViewModel.colorSelectionConfiguration = .init(items: swatches, selectedItem: swatches.first)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // MARK: - Errpr

    func test_product_details_view_error_not_found() {
        mockViewModel.state = .error(.notFound)
        let sut = ProductDetailsView(viewModel: mockViewModel, showFailureState: true)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_product_details_view_error_generic() {
        mockViewModel.state = .error(.generic)
        let sut = ProductDetailsView(viewModel: mockViewModel, showFailureState: true)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // MARK: - Helper

    private func buildDefaultMock() {
        mockViewModel.productName = "Mock Product Name"
        mockViewModel.complementaryInfoToShow = [.paymentOptions, .returns]
        let swatches = [
            ColorSwatch(name: "Red", type: .color(.red)),
            ColorSwatch(name: "Green", type: .color(.green), isDisabled: true),
            ColorSwatch(name: "Blue", type: .color(.blue)),
        ]
        mockViewModel.colorSelectionConfiguration = .init(items: swatches, selectedItem: swatches.first)
        mockViewModel.productImageUrls = [
            URL(filePath: ""),
            URL(filePath: ""),
            URL(filePath: ""),
        ]
        mockViewModel.onShouldShowLoadingForSectionCalled = { _ in
            false
        }
        mockViewModel.onShouldShowSectionCalled = { _ in
            true
        }
        mockViewModel.productDescription = "A short-sleeved dress in a slim fit by BOSS Womenswear. Featuring a wrap-over bodice and a tiered skirt, this V-neck dress is crafted in metallic fabric with lining underneath. A side zip closure completes this piece."
    }
}
