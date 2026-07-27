import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import Home

final class HomeViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var mockViewModel: MockHomeViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockViewModel = .init()
    }

    override func tearDownWithError() throws {
        mockViewModel = nil
        try super.tearDownWithError()
    }

    func test_homeView_withHeroBanners() {
        let sut = HomeView(viewModel: mockViewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_homeView_withoutHeroBanners() {
        mockViewModel.heroBanners = []
        let sut = HomeView(viewModel: mockViewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
