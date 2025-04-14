import Mocks
import Model
import OrderedCollections
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Alfie

// TODO: Re-add Target Memebership once Snapshot tests are checked for working properly
final class BrandsViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: BrandsView<MockBrandsViewModel>!
    private var mockViewModel: MockBrandsViewModel!

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
        let sections = ["A", "B", "C", "D", "E"]
        let brands: [Brand] = sections.flatMap { letter -> [Brand] in
            (1...5).map { instance in
                Brand(name: "\(letter) brand \(instance)", slug: "")
            }
        }
        mockViewModel = MockBrandsViewModel(state: .success(OrderedDictionary(grouping: brands, by: { String($0.name.first!) })),
                                            sectionTitles: OrderedSet(sections))
        sut = .init(viewModel: mockViewModel)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_loading_state() {
        mockViewModel.onBrandsCalled = { _ in
            Brand.fixtures
        }
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
