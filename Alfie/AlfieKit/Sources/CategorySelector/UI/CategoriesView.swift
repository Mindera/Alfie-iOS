import AccessibilityIdentifiers
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
                LazyVStack(spacing: theme.spacing.space0) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        if viewModel.state.isLoading {
                            placeholderView(category)
                        } else {
                            categoryView(category)
                                .accessibilityIdentifier(AccessibilityId.categoryItem)
                        }
                    }
                }
            } else {
                // Something other than an empty view so that the overlay shown on top of the scroll view has a layout base
                Rectangle()
                    .fill(.clear)
            }
        }
    }

    // Root (level 1) menu uses the larger body style; drill-down levels step down to body medium (Figma).
    private var rowFont: ThemedTypographyStyle {
        viewModel.isRoot ? theme.font.body.large : theme.font.body.medium
    }

    private func categoryView(_ category: NavigationItem) -> some View {
        // Chevron signals a drill-down; leaves (no sub-menu) go straight to the PLP, so hide it.
        categoriesListItem(
            for: category.title,
            font: rowFont,
            isShimmering: false,
            foregroundColor: Theme.contentContentPrimary,
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
        categoriesListItem(for: category.title, font: rowFont, isShimmering: true, foregroundColor: Theme.contentContentPrimaryDisabled, showChevron: true)
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
        // A retry gives the error state a recovery path — pull-to-refresh can't be relied on here
        // (the error sits in an overlay above the scroll view's gesture).
        return ErrorView(
            title: title,
            message: message,
            buttons: [
                .init(cta: L10n.Shop.Categories.ErrorView.Button.cta, accessibilityId: AccessibilityID.Categories.retryButton) {
                    Task { await viewModel.retry() }
                },
            ]
        )
    }

    private func categoriesListItem(for text: String, font: ThemedTypographyStyle, isShimmering: Bool, foregroundColor: Color, showChevron: Bool) -> some View {
        HStack {
            Text.build(font(text))
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
                    // Decorative drill-down affordance — the row Button already announces the title.
                    .accessibilityHidden(true)
            }
        }
        .frame(height: Constants.categoryViewHeight)
        .padding(.horizontal, theme.spacing.space200)
    }
}

private enum AccessibilityId {
    static let categoryItem = "category-item"
}

private enum Constants {
    static let chevronSize: CGFloat = 24
    static let categoryViewHeight: CGFloat = 48
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
