import Combine
import OrderedCollections
import Mocks
import Model
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest
@testable import CategorySelector

final class ShopViewSnapshotTests: XCTestCase {
    private let isRecording = false
    private var sut: ShopView<MockCategoriesViewModel, MockBrandsViewModel, MockWebViewModel>!
    private var mockCategoriesViewModel: MockCategoriesViewModel!
    private var mockBrandsViewModel: MockBrandsViewModel!
    private var mockServicesViewModel: MockWebViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCategoriesViewModel = .init()
        mockBrandsViewModel = .init()
        mockServicesViewModel = .init()
        sut = makeSut(initialTab: .categories)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockCategoriesViewModel = nil
        mockBrandsViewModel = nil
        mockServicesViewModel = nil
        try super.tearDownWithError()
    }

    private func makeSut(initialTab: ShopViewTab) -> ShopView<MockCategoriesViewModel, MockBrandsViewModel, MockWebViewModel> {
        .init(isRoot: true,
              isWishlistEnabled: true,
              categoriesViewModel: mockCategoriesViewModel,
              brandsViewModel: mockBrandsViewModel,
              servicesViewModel: mockServicesViewModel,
              initialTab: initialTab,
              activeShopTabPublisher: Empty<ShopViewTab, Never>().eraseToAnyPublisher(),
              navigate: { _ in })
    }

    // MARK: Categories

    func test_shopview_loaded_state() {
        mockCategoriesViewModel.categories = NavigationItem.fixtures
        mockCategoriesViewModel.state = .success(.init(categories: []))
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_shopview_loading_state() {
        mockCategoriesViewModel.categories = NavigationItem.fixtures
        mockCategoriesViewModel.state = .loading
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_shopview_error_state() {
        mockCategoriesViewModel.state = .error(.generic)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // MARK: Brands

    func test_shopview_brands_loading_state() {
        mockBrandsViewModel.onBrandsCalled = { _ in
            Brand.fixtures
        }
        sut = makeSut(initialTab: .brands)
        mockBrandsViewModel.state = .loading
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_shopview_brands_loaded_state() {
        sut = makeSut(initialTab: .brands)

        let sections = ["A", "B", "C", "D", "E"]
        let brands: [Brand] = sections.flatMap { letter -> [Brand] in
            (1...5).map { instance in
                Brand(name: "\(letter) brand \(instance)", slug: "")
            }
        }
        mockBrandsViewModel.state = .success(OrderedDictionary(grouping: brands, by: { String($0.name.first!) }))
        mockBrandsViewModel.sectionTitles = OrderedSet(sections)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_shopview_brands_searching_with_no_results() {
        sut = makeSut(initialTab: .brands)

        mockBrandsViewModel.state = .success(OrderedDictionary(grouping: [], by: { String($0.name.first!) }))
        mockBrandsViewModel.sectionTitles = OrderedSet([])
        mockBrandsViewModel.searchText = "query"

        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    func test_shopview_brands_error_state() {
        sut = makeSut(initialTab: .brands)

        mockBrandsViewModel.state = .error(.generic)
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }

    // MARK: Services

    func test_shopview_services_loading_state() {
        sut = makeSut(initialTab: .services)
        mockServicesViewModel.state = .loading
        assertSnapshot(of: sut.embededInContainer(),
                       as: .defaultImage(),
                       record: isRecording)
    }
}
