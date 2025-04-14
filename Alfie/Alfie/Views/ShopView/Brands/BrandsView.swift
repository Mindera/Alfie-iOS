import Model
import OrderedCollections
import SharedUI
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct BrandsView<ViewModel: BrandsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @State private var selectedIndexTitle: String = ""
    @State private var showIndex = true

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        if viewModel.state.didFail {
            errorView
        } else if viewModel.state.isSuccess {
            brandsView
        } else {
            placeholdersView
                .onAppear {
                    viewModel.viewDidAppear()
                }
        }
    }

    // MARK: - Privates

    private var placeholdersView: some View {
        ScrollView(.vertical) {
            VStack(spacing: Spacing.space0) {
                ForEach(viewModel.brands(for: ""), id: \.id) { brand in
                    placeholderItemView(brand)
                }
                Spacer()
            }
        }
        .scrollDisabled(true)
    }

    @ViewBuilder private var searchBar: some View {
        if viewModel.state.isSuccess {
            // swiftlint:disable:next trailing_closure
            ThemedSearchBarView(
                searchText: $viewModel.searchText,
                placeholder: L10n.Shop.Brands.SearchBar.placeholder,
                theme: .soft,
                dismissConfiguration: .init(type: .cancel(title: L10n.SearchBar.cancel)),
                onFocusChange: { isFocused in
                    viewModel.searchFocusDidChange(isFocused: isFocused)
                }
            )
        }
    }

    private var brandsView: some View {
        VStack(spacing: Spacing.space0) {
            searchBar
                .padding(.horizontal, Spacing.space200)
                .padding(.vertical, Spacing.space025)
            if viewModel.sectionTitles.isEmpty {
                emptySearchResults
            } else {
                brandsList
            }
        }
        .onReceive(viewModel.indexVisibilityPublisher.receive(on: DispatchQueue.main)) { isVisible in
            withAnimation(.standardAccelerate) {
                showIndex = isVisible
            }
        }
    }

    private var brandsList: some View {
        GeometryReader { geoProxy in
            ScrollViewReader { scrollProxy in
                ZStack {
                    List(viewModel.sectionTitles, id: \.self) { section in
                        Section(
                            header: HeaderView(title: section)
                                .anchorPreference(key: VisiblePreferenceKey.self, value: .bounds) {
                                    [.init(item: section, anchor: $0)]
                                }
                        ) {
                            VStack(spacing: Spacing.space0) {
                                ForEach(viewModel.brands(for: section)) { brand in
                                    brandItemView(brand)
                                }
                                Spacer()
                            }
                            .id(section)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                    }
                    .onPreferenceChange(VisiblePreferenceKey.self) { items in
                        let local = geoProxy.frame(in: .local)
                        let stickyHeader = items
                            .filter { local.intersects(geoProxy[$0.anchor]) }
                            .map(\.item)
                            .min()

                        guard let stickyHeader, selectedIndexTitle != stickyHeader else { return }
                        selectedIndexTitle = stickyHeader
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .padding(.trailing, showIndex ? Spacing.space200 : Spacing.space0)

                    VStack(spacing: Spacing.space0) {
                        Spacer()
                        sectionIndexTitles(proxy: scrollProxy)
                        Spacer()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    private func brandItemView(_ brand: Brand) -> some View {
        BrandItemView(
            brand: brand,
            foregroundColor: { Colors.primary.mono800 },
            isLoading: .constant(false)
        )
        .modifier(
            TapHighlightableModifier {
                coordinator.openProductListing(
                    configuration: .init(
                        category: brand.slug,
                        searchText: nil,
                        urlQueryParameters: nil,
                        mode: .listing
                    )
                )
            }
        )
    }

    private func placeholderItemView(_ placeholder: Brand) -> some View {
        BrandItemView(brand: placeholder, foregroundColor: { Colors.primary.mono300 }, isLoading: .constant(true))
    }

    private func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: Spacing.space0) {
            if showIndex {
                SectionIndexTitles(
                    scrollProxy: proxy,
                    titles: viewModel.sectionTitles,
                    selectedIndexTitle: $selectedIndexTitle
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .animation(.standard, value: showIndex)
    }

    // MARK: Error View

    private var errorView: some View {
        ErrorView(
            title: L10n.Shop.Brands.ErrorView.title,
            message: L10n.Shop.Brands.ErrorView.message
        )
    }

    private var emptySearchResults: some View {
        ErrorView(
            icon: Icon.search.image,
            message: theme.font.small.normal(L10n.Shop.Brands.SearchBar.noResultsMessage) +
                theme.font.small.bold(" '\(viewModel.searchText)'")
        )
    }
}

// MARK: - Views

extension BrandsView {
    // MARK: List Header

    struct HeaderView: View, Equatable {
        let title: String

        var body: some View {
            HStack(alignment: .center, spacing: Spacing.space0) {
                Text(title)
                    .font(Font(theme.font.paragraph.bold))
                    .foregroundStyle(Colors.primary.mono900)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.space200)
            .frame(height: Constants.headerViewHeight)
            .background(Colors.primary.white)
        }
    }

    // MARK: List Content Item

    struct BrandItemView: View, Equatable {
        private let brand: Brand
        private let foregroundColor: () -> Color
        @Binding private var isLoading: Bool

        init(brand: Brand, foregroundColor: @escaping () -> Color, isLoading: Binding<Bool>) {
            self.brand = brand
            self.foregroundColor = foregroundColor
            self._isLoading = isLoading
        }

        var body: some View {
            VStack(spacing: Spacing.space0) {
                HStack(spacing: Spacing.space0) {
                    Text.build(theme.font.paragraph.normal(brand.name))
                        .foregroundStyle(foregroundColor())
                        .shimmering(while: $isLoading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: Constants.brandViewHeight)

                ThemedDivider.horizontalThin
            }
            .padding(.horizontal, Spacing.space200)
        }

        static func == (lhs: BrandsView<ViewModel>.BrandItemView, rhs: BrandsView<ViewModel>.BrandItemView) -> Bool {
            lhs.brand == rhs.brand
        }
    }

    // MARK: List Index

    struct SectionIndexTitles: View {
        private let scrollProxy: ScrollViewProxy
        private let titles: OrderedSet<String>
        @Binding private var selectedIndexTitle: String
        @GestureState private var dragLocation: CGPoint = .zero

        init(scrollProxy: ScrollViewProxy, titles: OrderedSet<String>, selectedIndexTitle: Binding<String>) {
            self.scrollProxy = scrollProxy
            self.titles = titles
            _selectedIndexTitle = selectedIndexTitle
        }

        var body: some View {
            VStack(spacing: Spacing.space0) {
                ForEach(titles, id: \.self) { title in
                    SectionIndexTitle(text: title, isSelected: selectedIndexTitle == title)
                        .padding(.horizontal, Spacing.space100)
                        .background(dragObserver(title: title))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .updating($dragLocation) { value, state, _ in
                        state = value.location
                    }
            )
        }

        private func dragObserver(title: String) -> some View {
            GeometryReader { geometry in
                dragObserver(geometry: geometry, title: title)
            }
        }

        private func dragObserver(geometry: GeometryProxy, title: String) -> some View {
            let emptyView = Rectangle().fill(Color.clear)

            guard title != selectedIndexTitle else { return emptyView }

            if geometry.frame(in: .global).contains(dragLocation) {
                DispatchQueue.main.async {
                    selectedIndexTitle = title
                    scrollProxy.scrollTo(title, anchor: .top)
                }
            }
            return emptyView
        }
    }

    private struct SectionIndexTitle: View {
        private let text: String
        private let isSelected: Bool

        init(text: String, isSelected: Bool) {
            self.text = text
            self.isSelected = isSelected
        }

        var body: some View {
            Text(text)
                .font(Font(theme.font.tiny.normal))
                .foregroundStyle(isSelected ? Colors.primary.white : Colors.primary.mono500)
                .frame(minWidth: Constants.sectionIndexSize, minHeight: Constants.sectionIndexSize)
                .background {
                    RoundedRectangle(cornerRadius: CornerRadius.xxs)
                        .foregroundStyle(isSelected ? Colors.primary.mono900 : Color.clear)
                }
        }
    }
}

// MARK: - Helpers

private struct VisibleItem: Equatable {
    let item: String
    let anchor: Anchor<CGRect>
}

private struct VisiblePreferenceKey: PreferenceKey {
    static var defaultValue: [VisibleItem] = []

    static func reduce(value: inout [VisibleItem], nextValue: () -> [VisibleItem]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Constants

private enum Constants {
    static let headerViewHeight: CGFloat = 40
    static let brandViewHeight: CGFloat = 56
    static let sectionIndexSize: CGFloat = 16
}

// MARK: - Preview

#if DEBUG
#Preview("Success") {
    let sections = ["A", "B", "C", "D", "E"]
    let brands: [Brand] = sections.flatMap { letter -> [Brand] in
        (1...5).map { instance in
            Brand(name: "\(letter) brand \(instance)", slug: "")
        }
    }

    return BrandsView(
        viewModel: MockBrandsViewModel(
            state: .success(
                OrderedDictionary(grouping: brands) {
                    guard let firstCharacter = $0.name.first else { return "" }
                    return String(firstCharacter)
                }
            ),
            sectionTitles: OrderedSet(sections)
        )
    )
    .environmentObject(Coordinator())
}

#Preview("Loading") {
    let viewModel = MockBrandsViewModel(state: .loading)
    viewModel.onBrandsCalled = { _ in
        Brand.fixtures
    }
    return BrandsView(viewModel: viewModel)
        .environmentObject(Coordinator())
}

#Preview("Error") {
    BrandsView(viewModel: MockBrandsViewModel(state: .error(.generic)))
        .environmentObject(Coordinator())
}
#endif
