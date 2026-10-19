import Foundation
import Model

/// Commits page requests onto the loaded products. A failed page request never discards them: it
/// surfaces as a transient error while any are loaded, and as a blocking error otherwise.
struct ProductListingPager {
    typealias State = PaginatedViewState<ProductListingViewStateModel, ProductListingViewErrorType>

    struct Ticket {
        let request: ProductListingPageRequest
        let cursor: String?
        let generation: Int
    }

    struct Commit {
        let transientError: ProductListingTransientError?
    }

    private struct InFlight {
        let generation: Int
        let previousState: State
    }

    private static let noProducts = ProductListingViewStateModel(title: "", products: [])

    private(set) var state: State
    private(set) var pagination: ProductListing.Pagination?
    private var generation = 0
    private var inFlight: InFlight?

    var isFetching: Bool {
        inFlight?.generation == generation
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

        inFlight = InFlight(generation: generation, previousState: previousState)
        return Ticket(request: request, cursor: cursor, generation: generation)
    }

    mutating func commit(_ result: Result<ProductListing?, Error>, for ticket: Ticket) -> Commit? {
        guard ticket.generation == generation, let previousState = inFlight?.previousState else { return nil }
        inFlight = nil

        switch (result, ticket.request) {
        case (.success(let page?), _):
            pagination = page.pagination
            if ticket.request == .nextPage, case .success(let loaded) = previousState {
                state = .success(.init(title: loaded.title, products: loaded.products + page.products))
            } else {
                state = .success(.init(title: page.title, products: page.products))
            }
            return Commit(transientError: nil)

        case (.success(nil), .nextPage), (.failure(is CancellationError), _):
            if case .loadingFirstPage = previousState {
                return fail(with: .generic, for: ticket.request, from: previousState)
            }
            state = previousState
            return Commit(transientError: nil)

        case (.success(nil), _):
            return fail(with: .noResults, for: ticket.request, from: previousState)

        case (.failure(let error), _):
            return fail(with: .from(error: error), for: ticket.request, from: previousState)
        }
    }

    /// A filter or sort change (ALFMOB-487): drops the cursor and any page request in flight.
    mutating func resetResultSet() {
        pagination = nil
        generation += 1
        state = .loadingFirstPage(Self.noProducts)
    }

    private mutating func fail(
        with error: ProductListingViewErrorType,
        for pageRequest: ProductListingPageRequest,
        from previousState: State
    ) -> Commit {
        guard
            let request = ProductListingTransientError.Request(pageRequest),
            case .success(let loaded) = previousState,
            !loaded.products.isEmpty
        else {
            state = .error(error)
            return Commit(transientError: nil)
        }
        state = .success(loaded)
        return Commit(transientError: .init(request: request, error: error))
    }
}
