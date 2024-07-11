import Combine
import Core
import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

struct CategoriesView<ViewModel: CategoriesViewModelProtocol>: View {
    private let ignoreLocalNavigation: Bool
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var tabCoordinator: TabCoordinator

    /// Initializes a CategoriesView with a view model and a bool controling if local tab navigation should be ignored (i.e., shop links like Brands and Service)
    /// so that they can be handled by the parent shop view
    init(viewModel: ViewModel, ignoreLocalNavigation: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.ignoreLocalNavigation = ignoreLocalNavigation
    }

    var body: some View {
        ScrollView {
            if !viewModel.state.didFail {
                LazyVStack(spacing: Spacing.space0) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        if viewModel.state.isLoading {
                            placeholderView(category)
                        } else {
                            categoryView(category)
                                .accessibilityIdentifier(AccessibilityId.categoryItem)
                        }
                    }
                    Spacer()
                }
            } else {
                // Something other than an empty view so that the overlay shown on top of the scroll view has a layout base
                Rectangle()
                    .fill(.clear)
            }
        }
        .overlay(alignment: .center) {
            if viewModel.state.didFail {
                errorView
            }
        }
        .modifier(CategoriesToolbarModifier(showToolbar: viewModel.shouldShowToolbar, title: viewModel.title))
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onReceive(viewModel.openCategoryPublisher.receive(on: DispatchQueue.main), perform: { destination in
            switch destination {
                case .plp(let category):
                    coordinator.openProductListing(configuration: .init(category: category,
                                                                        searchText: nil,
                                                                        urlQueryParameters: nil,
                                                                        mode: .listing))
                case .web(let url, let title):
                    coordinator.open(url: url, title: title)
                case .services:
                    if !ignoreLocalNavigation {
                        coordinator.openStoreServices()
                    }
                case .brands:
                    if !ignoreLocalNavigation {
                        coordinator.openBrands()
                    }
                case .subCategories(let subCategories, let parent):
                    coordinator.openCategories(subCategories, title: parent.title)
            }
        })
    }

    // MARK: - Subviews

    private func categoryView(_ category: NavigationItem) -> some View {
        categoriesListItem(for: category.title,
                           isShimmering: false,
                           foregroundColor: Colors.primary.mono800)
            .modifier(TapHighlightableModifier(action: {
                withAnimation(.standard) {
                    viewModel.didSelectCategory(category)
                }
            }))
    }

    private func placeholderView(_ category: NavigationItem) -> some View {
        categoriesListItem(for: category.title,
                           isShimmering: true,
                           foregroundColor: Colors.primary.mono300)
    }

    private var errorView: some View {
        // TODO: Remove this after implementing reusable error views
        VStack(spacing: Spacing.space200) {
            Spacer()
            Icon.warning.image
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Colors.primary.black)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .aspectRatio(contentMode: .fit)
            Text.build(theme.font.paragraph.bold(LocalizableCategories.errorTitle))
                .foregroundStyle(Colors.primary.black)
            Text.build(theme.font.small.normal(LocalizableCategories.errorMessage))
                .foregroundStyle(Colors.primary.black)
            Spacer()
        }
    }

    private func categoriesListItem(for text: String,
                                    isShimmering: Bool,
                                    foregroundColor: Color) -> some View {
        VStack(spacing: Spacing.space0) {
            HStack {
                Text.build(theme.font.paragraph.normal(text))
                    .foregroundStyle(foregroundColor)
                    .shimmering(while: .constant(isShimmering))
                Spacer()
                Icon.chevronRight.image
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(foregroundColor)
                    .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: Constants.categoryViewHeight)

            ThemedDivider.horizontalThin
        }
        .padding(.horizontal, Spacing.space200)
    }
}

private enum AccessibilityId {
    static let categoryItem = "category-item"
}

private enum Constants {
    static let segmentedControlHeight: CGFloat = 46
    static let chevronSize: CGFloat = 16
    static let iconSize: CGFloat = 48
    static let categoryViewHeight: CGFloat = 56
}

// MARK: - CategoriesToolbarModifier

private struct CategoriesToolbarModifier: ViewModifier {
    private var showToolbar: Bool
    private var title: String?

    public init(showToolbar: Bool, title: String?) {
        self.showToolbar = showToolbar
        self.title = title
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if showToolbar, let title {
            content
                .withToolbar(for: .categoryList([], title: title))
        } else {
            content
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Success") {
    CategoriesView(viewModel: MockCategoriesViewModel(state: .success(.init(categories: [])),
                                                             categories: NavigationItem.fixtures))
        .environmentObject(Coordinator())
}

#Preview("Loading") {
    CategoriesView(viewModel: MockCategoriesViewModel(state: .loading, categories: NavigationItem.fixtures))
        .environmentObject(Coordinator())
}

#Preview("Error") {
    CategoriesView(viewModel: MockCategoriesViewModel(state: .error(.generic)))
        .environmentObject(Coordinator())
}
#endif
