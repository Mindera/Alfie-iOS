import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import UIKit
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
        // Use a flat-colour placeholder asset instead of the photographic hero JPGs: the test covers
        // carousel layout, and a solid image keeps the reference PNG small and its diffs meaningful.
        mockViewModel.heroBanners = HomeHeroBanner.placeholders.map {
            HomeHeroBanner(id: $0.id, imageName: "test-hero-placeholder", title: $0.title)
        }
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

    // The carousel snapshot swaps in a placeholder, so it never renders hero-1/2/3. Guard that the
    // real assets still resolve in the Home bundle — otherwise renaming or dropping one ships a blank
    // hero (HomeHeroBannerView draws Image(name, bundle:)) with the whole suite staying green.
    func test_heroBannerAssets_resolveInHomeBundle() {
        for banner in HomeHeroBanner.placeholders {
            XCTAssertNotNil(
                UIImage(named: banner.imageName, in: BundleToken.bundle, with: nil),
                "Missing hero asset '\(banner.imageName)' in Home bundle"
            )
        }
    }
}
