import Mocks
import Model
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class RecentSearchesViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: RecentSearchesView<MockRecentSearchesViewModel>!
    private var mockViewModel: MockRecentSearchesViewModel!

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

    func test_recentSearchesView_withTwoItems() {
        mockViewModel.recentSearches = [.recentSearch1, .recentSearch2]
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_recentSearchesView_withFiveItems() {
        mockViewModel.recentSearches = [
            .recentSearch1, 
            .recentSearch2,
            .recentSearch3,
            .recentSearch4,
            .recentSearch5
        ]
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_recentSearchesView_withoutItems() {
        mockViewModel.recentSearches = []
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
