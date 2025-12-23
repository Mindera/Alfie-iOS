import Mocks
import Model
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class CategoriesViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: CategoriesView<MockCategoriesViewModel>!
    private var mockViewModel: MockCategoriesViewModel!

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

    func test_loaded_state() {
        mockViewModel.categories = NavigationItem.fixtures
        mockViewModel.state = .success(.init(categories: []))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_loading_state() {
        mockViewModel.categories = NavigationItem.fixtures
        mockViewModel.state = .loading
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_error_state() {
        mockViewModel.state = .error(.generic)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
