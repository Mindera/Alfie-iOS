import Core
import Models
import SharedUI
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

// MARK: - Constants

private enum Constants {
    /// Layout Grid Struct Items Per Row
    static let iPhoneGridRows = 2
    static let iPhoneListRows = 1
    static let iPadGridRows = 3
    static let iPadListRows = 2
}

// MARK: - ProductListingView

struct ProductListingView<ViewModel: ProductListingViewModelProtocol>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel: ViewModel
    @State private var orientation = UIDeviceOrientation.unknown

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Spacing.space0) {
            if viewModel.state.didFail {
                errorView
            } else {
                ScrollView(.vertical) {
                    infoFilterBarView
                    productCardList
                        .animation(.standardDecelerate, value: viewModel.style)
                }
                .animation(.standardDecelerate, value: viewModel.style)
                .disabled(viewModel.state.isLoadingFirstPage)
            }
        }
        .withToolbar(
            for: .productListing(
                configuration: .init(
                    category: viewModel.title,
                    searchText: nil,
                    urlQueryParameters: nil,
                    mode: .listing
                )
            )
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.showSearchButton {
                    ToolbarItemProvider.searchItem(with: coordinator)
                }
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    @ViewBuilder private var productCardList: some View {
        LazyVGrid(columns: gridStruct, spacing: Spacing.space200) {
            ForEach(viewModel.products) { product in
                VerticalProductCard(
                    viewModel: .init(
                        configuration: .init(
                            size: viewModel.style == .list ? .large : .medium,
                            hideAction: !coordinator.isWishlistEnabled
                        ),
                        product: product
                    ),
                    onUserAction: { _, type in
                        handleUserAction(forProduct: product, actionType: type)
                    },
                    isSkeleton: .init(
                        get: { viewModel.state.isLoadingFirstPage },
                        set: { _ in }
                    ),
                    isFavorite: viewModel.isFavoriteState(for: product)
                )
                .onTapGesture {
                    coordinator.openDetails(for: product)
                }
                .onAppear {
                    viewModel.didDisplay(product)
                }
            }
        }
        .padding(Spacing.space200)

        if viewModel.state.isLoadingNextPage {
            LoaderView(circleDiameter: .defaultSmall, style: .dark, labelHidden: false)
                .padding(.bottom, Spacing.space400)
        }
    }

    @ViewBuilder private var infoFilterBarView: some View {
        ProductListingFilterBar(
            style: $viewModel.style,
            total: viewModel.totalNumberOfProducts,
            isLoading: viewModel.state.isLoadingFirstPage
        ) {
            viewModel.showRefine.toggle()
        }
        .onChange(of: viewModel.style, perform: viewModel.setListStyle)
        .sheet(isPresented: $viewModel.showRefine) {
            ProductListingFilter(
                isVisible: $viewModel.showRefine,
                listStyle: $viewModel.style,
                sortOption: $viewModel.sortOption,
                onFilter: viewModel.didApplyFilters
            )
        }
    }

    private var gridStruct: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.space200, alignment: .top), count: numberOfCardsPerRow)
    }

    private var numberOfCardsPerRow: Int {
        switch horizontalSizeClass {
        case .regular:
            // swiftlint:disable vertical_whitespace_between_cases
            switch viewModel.style {
            case .grid:
                return Constants.iPadGridRows
            case .list:
                return Constants.iPadListRows
            }
            // swiftlint:enable vertical_whitespace_between_cases

        default:
            // swiftlint:disable vertical_whitespace_between_cases
            switch viewModel.style {
            case .grid:
                return Constants.iPhoneGridRows
            case .list:
                return Constants.iPhoneListRows
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    private var errorView: some View {
        ErrorView(
            title: L10n.Plp.ErrorView.title,
            message: L10n.Plp.ErrorView.message
        )
    }
}

// MARK: - Private Methods

private extension ProductListingView {
    func handleUserAction(forProduct product: Product, actionType: VerticalProductCard.ProductUserActionType) {
        guard case .wishlist(let isFavorite) = actionType else { return }
        viewModel.didTapAddToWishlist(for: product, isFavorite: isFavorite)
    }
}

#if DEBUG
#Preview("Success") {
    ProductListingView(
        viewModel: MockProductListingViewModel(
            state: .success(.init(title: "Success", products: Product.fixtures)),
            products: Product.fixtures
        )
    )
    .environmentObject(Coordinator())
}

#Preview("Loading") {
    ProductListingView(
        viewModel: MockProductListingViewModel(
            state: .loadingFirstPage(.init(title: "Loading", products: Product.fixtures)),
            products: Product.fixtures
        )
    )
    .environmentObject(Coordinator())
}

#Preview("Error") {
    ProductListingView(
        viewModel: MockProductListingViewModel(
            state: .error(.generic), products: []
        )
    )
    .environmentObject(Coordinator())
}
#endif
