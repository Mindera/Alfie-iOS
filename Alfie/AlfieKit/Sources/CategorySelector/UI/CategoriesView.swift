import Combine
import Core
import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

struct CategoriesView<ViewModel: CategoriesViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
    }

    // MARK: - Subviews

    private func categoryView(_ category: NavigationItem) -> some View {
        categoriesListItem(for: category.title, isShimmering: false, foregroundColor: Colors.primary.mono800)
            .modifier(
                TapHighlightableModifier {
                    withAnimation(.standard) {
                        viewModel.didSelectCategory(category)
                    }
                }
            )
    }

    private func placeholderView(_ category: NavigationItem) -> some View {
        categoriesListItem(for: category.title, isShimmering: true, foregroundColor: Colors.primary.mono300)
    }

    private var errorView: some View {
        ErrorView(
            title: L10n.Shop.Categories.ErrorView.title,
            message: L10n.Shop.Categories.ErrorView.message
        )
    }

    private func categoriesListItem(for text: String, isShimmering: Bool, foregroundColor: Color) -> some View {
        VStack(spacing: Spacing.space0) {
            HStack {
                Text.build(theme.font.paragraph.normal(text))
                    .foregroundStyle(foregroundColor)
                    .shimmering(while: .constant(isShimmering))
                Spacer()
                Icon.chevronRight.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                    .foregroundStyle(foregroundColor)
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
                .subCategoriesToolbarView(title: title)
        } else {
            content
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Success") {
    CategoriesView(
        viewModel: MockCategoriesViewModel(state: .success(.init(categories: [])), categories: NavigationItem.fixtures)
    )
}

#Preview("Loading") {
    CategoriesView(viewModel: MockCategoriesViewModel(state: .loading, categories: NavigationItem.fixtures))
}

#Preview("Error") {
    CategoriesView(viewModel: MockCategoriesViewModel(state: .error(.generic)))
}
#endif
