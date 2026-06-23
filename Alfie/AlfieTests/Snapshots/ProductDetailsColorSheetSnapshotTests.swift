import Foundation
import Mocks
import Model
import SnapshotTesting
import SwiftUI
import XCTest
import SharedUI
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class ProductDetailsColorSheetSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: ProductDetailsColorSheet<MockProductDetailsViewModel>!
    private var mockViewModel: MockProductDetailsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init(colorSelectionConfiguration: .init(items: [
            .init(name: "Color 1", type: .color(Primitives.Colours.neutrals400)),
            .init(name: "Color 2", type: .color(Primitives.Colours.neutrals500)),
            .init(name: "Color 3", type: .color(Primitives.Colours.neutrals600)),
            .init(name: "Color 4", type: .color(Primitives.Colours.neutrals800)),
        ]))
        sut = .init(viewModel: mockViewModel, isPresented: .constant(true), searchText: .constant(""))
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
