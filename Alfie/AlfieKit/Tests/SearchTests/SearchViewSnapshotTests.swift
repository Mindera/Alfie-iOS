import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Search

final class SearchViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var mockViewModel: MockSearchViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init()
    }

    override func tearDownWithError() throws {
        mockViewModel = nil
        try super.tearDownWithError()
    }

    func test_search_view_without_recent_searches_is_blank() {
        mockViewModel.state = .blank

        let sut = SearchView(viewModel: mockViewModel)

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_search_view_with_recent_searches_lists_them() {
        mockViewModel.state = .recentSearches
        mockViewModel.recentSearchesViewModel.recentSearches = [
            .text(value: "jeans"),
            .text(value: "linen"),
            .text(value: "t-shirt")
        ]

        let sut = SearchView(viewModel: mockViewModel)

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }
}
