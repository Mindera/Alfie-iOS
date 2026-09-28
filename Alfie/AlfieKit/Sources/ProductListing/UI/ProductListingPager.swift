import Foundation
import Model

/// Commits page requests onto the loaded products. A failed page request never discards them: it
/// surfaces as a transient error while any are loaded.
struct ProductListingPager {
    typealias State = PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>

    struct Ticket {
        let request: ProductListingPageRequest
        let cursor: String?
        fileprivate let generation: Int
    }

    struct Commit {
        let state: State
        let transientError: ProductListingTransientError?
    }

    var state: State
    var pagination: ProductListing.Pagination?
    var generation = 0
    var isFetching = false

    init(state: State) {
        self.state = state
    }

    mutating func beginNextPage() -> Ticket? {
        guard !isFetching, pagination?.hasNextPage == true, case .success(let loaded) = state else { return nil }
        isFetching = true
        state = .loadingNextPage(loaded)
        return Ticket(request: .nextPage, cursor: pagination?.endCursor, generation: generation)
    }

    mutating func commit(_ result: Result<ProductListing?, Error>, for ticket: Ticket) -> Commit? {
        isFetching = false
        guard ticket.generation == generation, let loaded = state.value else { return nil }

        var transientError: ProductListingTransientError?
        switch result {
        case .success(let page?):
            pagination = page.pagination
            state = .success(.init(title: loaded.title, products: loaded.products + page.products))
        case .success(nil), .failure(is CancellationError):
            state = .success(loaded)
        case .failure(let error):
            state = .success(loaded)
            transientError = .init(request: ticket.request, error: .from(error: error))
        }
        return Commit(state: state, transientError: transientError)
    }

    mutating func resetResultSet() {
        pagination = nil
        generation += 1
        state = .loadingFirstPage(.init(title: "", products: []))
    }
}
