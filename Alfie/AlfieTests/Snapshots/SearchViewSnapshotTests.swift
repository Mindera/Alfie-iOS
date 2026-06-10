import Mocks
import Model
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class SearchViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: SearchView<MockSearchViewModel>!
    private var mockSearchViewModel: MockSearchViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSearchViewModel = .init()
        sut = .init(viewModel: mockSearchViewModel, transition: nil)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSearchViewModel = nil
        try super.tearDownWithError()
    }

    func test_searchView_emptyState() {
        mockSearchViewModel.state = .empty
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_searchView_recentSearchesState() {
        mockSearchViewModel.state = .recentSearches
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
