import Foundation
import Model

/// Commits page requests onto the loaded products. A failed page request never discards them: it
/// surfaces as a transient error while any are loaded, and as a blocking error otherwise.
struct ProductListingPager {
    typealias State = PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>

    struct Ticket {
        let request: ProductListingPageRequest
        let cursor: String?
        fileprivate let generation: Int
        fileprivate let previousState: State
    }

    struct Commit {
        let transientError: ProductListingTransientError?
    }

    private static let noProducts = ProductListingViewStateModel(title: "", products: [])

    private(set) var state: State
    private(set) var pagination: ProductListing.Pagination?
    private var generation = 0
    private var inFlightGeneration: Int?

    var isFetching: Bool {
        inFlightGeneration == generation
    }

    init(state: State, pagination: ProductListing.Pagination? = nil) {
        self.state = state
        self.pagination = pagination
    }

    mutating func begin(_ request: ProductListingPageRequest) -> Ticket? {
        guard !isFetching else { return nil }
        let previousState = state
        let cursor: String?

        switch (request, state) {
        case (.refresh, _):
            cursor = nil
        case (.firstPage, .success), (.firstPage, .loadingNextPage):
            return nil
        case (.firstPage, .error):
            state = .loadingFirstPage(Self.noProducts)
            cursor = nil
        case (.firstPage, .loadingFirstPage):
            cursor = nil
        case (.nextPage, .success(let loaded)) where pagination?.hasNextPage == true:
            state = .loadingNextPage(loaded)
            cursor = pagination?.endCursor
        case (.nextPage, _):
            return nil
        }

        inFlightGeneration = generation
        return Ticket(request: request, cursor: cursor, generation: generation, previousState: previousState)
    }

    mutating func commit(_ result: Result<ProductListing?, Error>, for ticket: Ticket) -> Commit? {
        guard ticket.generation == generation else { return nil }
        inFlightGeneration = nil

        switch (result, ticket.request) {
        case (.success(let page?), _):
            pagination = page.pagination
            if ticket.request == .nextPage, case .success(let loaded) = ticket.previousState {
                state = .success(.init(title: loaded.title, products: loaded.products + page.products))
            } else {
                state = .success(.init(title: page.title, products: page.products))
            }
            return Commit(transientError: nil)
        case (.success(nil), .nextPage), (.failure(is CancellationError), _):
            if case .loadingFirstPage = ticket.previousState {
                return fail(with: .generic, for: ticket)
            }
            state = ticket.previousState
            return Commit(transientError: nil)
        case (.success(nil), _):
            return fail(with: .noResults, for: ticket)
        case (.failure(let error), _):
            return fail(with: .from(error: error), for: ticket)
        }
    }

    /// A filter or sort change (ALFMOB-487): drops the cursor and any page request in flight.
    mutating func resetResultSet() {
        pagination = nil
        generation += 1
        state = .loadingFirstPage(Self.noProducts)
    }

    private mutating func fail(with error: ProductListingViewErrorType, for ticket: Ticket) -> Commit {
        guard case .success(let loaded) = ticket.previousState, !loaded.products.isEmpty else {
            state = .error(error)
            return Commit(transientError: nil)
        }
        state = .success(loaded)
        return Commit(transientError: .init(request: ticket.request, error: error))
    }
}
