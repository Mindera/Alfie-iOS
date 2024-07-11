import Mocks
import Models
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

    func test_searchView_loadingState() {
        mockSearchViewModel.state = .loading
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_searchView_noResultsState() {
        mockSearchViewModel.searchText = "polo"
        mockSearchViewModel.state = .noResults
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_search_view_success_state() {
        mockSearchViewModel.state = .success(suggestion: .fixture())
        mockSearchViewModel.searchText = "polo"
        mockSearchViewModel.suggestionTerms = [.fixture(term: "Polo shirt"), .fixture(term: "Apolo Denim"), .fixture(term: "Casual polos")]
        mockSearchViewModel.suggestionBrands = [.fixture(name: "Polo by Ralph Lauren"), .fixture(name: "Apolo Denim")]
        mockSearchViewModel.suggestionProducts = Product.fixtures(includeMedia: false)
        assertSnapshot(of: sut.embededInFullHeightContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_search_view_success_state_no_terms() {
        mockSearchViewModel.state = .success(suggestion: .fixture())
        mockSearchViewModel.searchText = "polo"
        mockSearchViewModel.suggestionBrands = [.fixture(name: "Polo by Ralph Lauren"), .fixture(name: "Apolo Denim")]
        mockSearchViewModel.suggestionProducts = Product.fixtures(includeMedia: false)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_search_view_success_state_no_brands() {
        mockSearchViewModel.state = .success(suggestion: .fixture())
        mockSearchViewModel.searchText = "polo"
        mockSearchViewModel.suggestionTerms = [.fixture(term: "Polo shirt"), .fixture(term: "Apolo Denim"), .fixture(term: "Casual polos")]
        mockSearchViewModel.suggestionProducts = Product.fixtures(includeMedia: false)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_search_view_success_state_no_products() {
        mockSearchViewModel.state = .success(suggestion: .fixture())
        mockSearchViewModel.searchText = "polo"
        mockSearchViewModel.suggestionTerms = [.fixture(term: "Polo shirt"), .fixture(term: "Apolo Denim"), .fixture(term: "Casual polos")]
        mockSearchViewModel.suggestionBrands = [.fixture(name: "Polo by Ralph Lauren"), .fixture(name: "Apolo Denim")]
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
