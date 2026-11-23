import TestSeed
import XCTest

final class SearchJourneyTests: AlfieUITestCase {
    func testSearchJourney() throws {
        let search = SearchPage(app: app)
        let listing = ProductListingPage(app: app)
        let pdp = ProductDetailsPage(app: app)

        XCTContext.runActivity(named: "Search a term with many results") { _ in
            openSearch(search)
            search.type(SeedAnchors.SearchTerms.many).submit()
        }

        XCTContext.runActivity(named: "The results list products") { _ in
            waitFor(
                listing.productCards.firstMatch,
                timeout: .bffRead,
                "Submitting the search should list at least one product"
            )
        }

        XCTContext.runActivity(named: "The first result opens its product") { _ in
            listing.tapFirstProduct()
            pdp.assertVisible()
        }
    }

    func testSearchWithNoResultsShowsNoResultsState() throws {
        let search = SearchPage(app: app)

        openSearch(search)
        search.type(SeedAnchors.SearchTerms.none)

        waitFor(search.noResults, timeout: .bffRead, "A term that matches nothing should show the no-results state")
    }

    private func openSearch(_ search: SearchPage) {
        waitFor(search.homeEntryButton, "Home should show the search bar")
        search.open()
        waitFor(search.input, "Tapping the search bar should open Search")
    }
}
