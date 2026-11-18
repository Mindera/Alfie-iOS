import AccessibilityIdentifiers
import XCTest

final class SearchJourneyTests: AlfieUITestCase {
    /// `SeedAnchors.SearchTerms`, mirrored until the UI test target links `TestSeed` (#255).
    private enum SearchTerms {
        static let many = "shirt"
        static let none = "zzz-no-results"
    }

    func test_search_term_with_results_opens_a_product_from_the_results() throws {
        let search = SearchPage(app: app)
        let listing = ProductListingPage(app: app)
        let pdp = ProductDetailsPage(app: app)

        XCTContext.runActivity(named: "Search a term with results") { _ in
            openSearch(search, andType: SearchTerms.many)
            waitFor(search.moreProductsButton, "A term with results should suggest products")
            search.submit()
        }

        XCTContext.runActivity(named: "The results list products") { _ in
            waitFor(listing.firstLoadedProductCard, "A term with results should list at least one product")
        }

        XCTContext.runActivity(named: "The first result opens its product") { _ in
            listing.firstLoadedProductCard.tap()
            pdp.assertVisible(timeout: timeout)
            XCTAssertFalse(pdp.productName.label.isEmpty, "The product page should name the product")
        }
    }

    func test_search_term_with_no_matches_shows_the_no_results_state() throws {
        let search = SearchPage(app: app)

        openSearch(search, andType: SearchTerms.none)

        waitFor(search.noResults, "A term with no matches should show the no-results state")
    }

    private func openSearch(_ search: SearchPage, andType term: String) {
        waitFor(search.entryButton, "Home should show the search entry")
        search.open()
        waitFor(search.input, "Search should show its input")
        search.type(term)
        XCTAssertEqual(search.input.value as? String, term, "The input should hold the typed term")
    }
}
