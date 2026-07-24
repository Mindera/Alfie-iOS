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
        scrollContent
            // Only the root screen can refresh; drill-down screens are static, so gate the
            // affordance to avoid a spinner that never does anything (`canRefresh` is constant).
            .refreshableIf(viewModel.canRefresh) {
                await viewModel.refresh()
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

    private var scrollContent: some View {
        ScrollView {
            if !viewModel.state.didFail {
                LazyVStack(spacing: Primitives.Spacing.spacing0) {
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
    }

    private func categoryView(_ category: NavigationItem) -> some View {
        // Chevron signals a drill-down; leaves (no sub-menu) go straight to the PLP, so hide it.
        categoriesListItem(
            for: category.title,
            isShimmering: false,
            foregroundColor: Primitives.Colours.neutrals700,
            showChevron: category.hasSubCategories
        )
            .modifier(
                TapHighlightableModifier {
                    withAnimation(.standard) {
                        viewModel.didSelectCategory(category)
                    }
                }
            )
    }

    private func placeholderView(_ category: NavigationItem) -> some View {
        categoriesListItem(for: category.title, isShimmering: true, foregroundColor: Primitives.Colours.neutrals400, showChevron: true)
    }

    private var errorView: some View {
        let (title, message): (String, String) = {
            switch viewModel.state.failure {
            case .rateLimited:
                return (L10n.Shop.Categories.ErrorView.RateLimited.title, L10n.Shop.Categories.ErrorView.RateLimited.message)
            case .serverError:
                return (L10n.Shop.Categories.ErrorView.ServerError.title, L10n.Shop.Categories.ErrorView.ServerError.message)
            default:
                return (L10n.Shop.Categories.ErrorView.title, L10n.Shop.Categories.ErrorView.message)
            }
        }()
        return ErrorView(title: title, message: message)
    }

    private func categoriesListItem(for text: String, isShimmering: Bool, foregroundColor: Color, showChevron: Bool) -> some View {
        VStack(spacing: Primitives.Spacing.spacing0) {
            HStack {
                Text.build(theme.font.body.medium(text))
                    .foregroundStyle(foregroundColor)
                    .shimmering(while: .constant(isShimmering))
                Spacer()
                if showChevron {
                    Icon.chevronRight.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                        .foregroundStyle(foregroundColor)
                }
            }
            .frame(height: Constants.categoryViewHeight)

            ThemedDivider.horizontalThin
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
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

// MARK: - Conditional refresh

private extension View {
    // `enabled` must be constant for the view's lifetime — it changes the view tree, not just content.
    @ViewBuilder
    func refreshableIf(_ enabled: Bool, action: @escaping @Sendable () async -> Void) -> some View {
        if enabled {
            refreshable(action: action)
        } else {
            self
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
