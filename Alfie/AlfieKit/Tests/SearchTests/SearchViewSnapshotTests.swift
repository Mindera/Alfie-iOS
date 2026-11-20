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

    // Covers only the static parts: LoadingSpinner rotates off wall-clock time, so the snapshot
    // asserts at 0.9 as SplashViewSnapshotTests does.
    func test_search_view_loading_suggestions_shows_spinner_alone() {
        mockViewModel.state = .suggestions(.loading)
        mockViewModel.searchText = "shirt"

        let sut = SearchView(viewModel: mockViewModel)

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(precision: 0.9), record: isRecording)
    }

    func test_search_view_with_product_suggestions_shows_grid_and_more_products() {
        let photos: [(url: URL, colour: UIColor)] = [
            (URL(string: "https://cdn.alfie.test/suggestion-0.jpg")!, .systemTeal),
            (URL(string: "https://cdn.alfie.test/suggestion-1.jpg")!, .systemOrange),
            (URL(string: "https://cdn.alfie.test/suggestion-2.jpg")!, .systemPurple)
        ]
        mockViewModel.searchText = "shirt"
        let products: [ProductSuggestion] = [
            .fixture(
                id: "1",
                name: "Oxford Shirt",
                brandName: "Alfie",
                price: .fixture(amountFormatted: "£45.00"),
                imageURL: photos[0].url
            ),
            .fixture(id: "2", name: "Linen Shirt With No Price", brandName: "Acme", price: nil, imageURL: photos[1].url),
            .fixture(
                id: "3",
                name: "Shirt With No Brand",
                brandName: nil,
                price: .fixture(amountFormatted: "£30.00"),
                imageURL: photos[2].url
            )
        ]
        mockViewModel.state = .suggestions(.success(.init(searchTerm: "shirt", sections: [.products(products)])))

        let sut = SearchView(viewModel: mockViewModel)
            .remoteImageFixtures(Dictionary(uniqueKeysWithValues: photos.map { ($0.url, UIImage.solid($0.colour)) }))

        assertSnapshot(of: sut.embededInFullHeightContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_search_view_with_keyword_suggestions_lists_them_above_products() {
        let photo = URL(string: "https://cdn.alfie.test/suggestion-0.jpg")!
        mockViewModel.searchText = "shirt"
        let sections: [SuggestionsSection] = [
            .keywords(
                [
                    .fixture(value: "linen shirt"),
                    .fixture(value: "Shirt dress with a shirt collar"),
                    .fixture(value: "oversized long sleeve cotton poplin shirt in washed sky blue stripe"),
                    .fixture(value: "polo")
                ]
            ),
            .products(
                [
                    .fixture(
                        id: "1",
                        name: "Oxford Shirt",
                        brandName: "Alfie",
                        price: .fixture(amountFormatted: "£45.00"),
                        imageURL: photo
                    )
                ]
            )
        ]
        mockViewModel.state = .suggestions(.success(.init(searchTerm: "shirt", sections: sections)))

        let sut = SearchView(viewModel: mockViewModel)
            .remoteImageFixtures([photo: UIImage.solid(.systemTeal)])

        assertSnapshot(of: sut.embededInFullHeightContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_search_view_without_suggestions_shows_no_results_message() {
        mockViewModel.searchText = "zzz"
        mockViewModel.state = .suggestions(.error(.noResults(searchTerm: "zzz")))

        let sut = SearchView(viewModel: mockViewModel)

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }

    func test_search_view_with_failed_suggestions_shows_error_with_try_again() {
        mockViewModel.searchText = "shirt"
        mockViewModel.state = .suggestions(.error(.generic(searchTerm: "shirt")))

        let sut = SearchView(viewModel: mockViewModel)

        assertSnapshot(of: sut.embededInContainer(), as: .defaultImage(), record: isRecording)
    }
}
