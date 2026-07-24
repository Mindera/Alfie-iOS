import Foundation
import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
import SharedUI
@testable import ProductDetails

final class ProductDetailsColorSheetSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: ProductDetailsColorAndSizeSheet<MockProductDetailsViewModel>!
    private var mockViewModel: MockProductDetailsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init(colorSelectionConfiguration: .init(items: [
            .init(id: "color1", name: "Color 1", type: .color(Primitives.Colours.neutrals400)),
            .init(id: "color2", name: "Color 2", type: .color(Primitives.Colours.neutrals500)),
            .init(id: "color3", name: "Color 3", type: .color(Primitives.Colours.neutrals600)),
            .init(id: "color4", name: "Color 4", type: .color(Primitives.Colours.neutrals800)),
        ]))
        sut = .init(viewModel: mockViewModel, type: .color, isPresented: .constant(true), searchText: .constant(""))
    }

    override func tearDownWithError() throws {
        sut = nil
        mockViewModel = nil
        try super.tearDownWithError()
    }

    func test_product_details_color_sheet() {
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
