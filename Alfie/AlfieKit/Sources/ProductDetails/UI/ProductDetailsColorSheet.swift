import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

private enum Constants {
    static let sheetCloseIconSize: CGFloat = 16
    static let colorCheckmarkSize: CGFloat = 16
}

/// Colour only: the size sheet is gone — every size renders inline on the page.
struct ProductDetailsColorSheet<ViewModel: ProductDetailsViewModelProtocol>: View {
    // Injected, not owned: `@StateObject` would pin the first view model this sheet ever saw and
    // silently ignore later ones.
    @ObservedObject private var viewModel: ViewModel
    @Binding private var isPresented: Bool
    @Binding private var searchText: String

    internal init(viewModel: ViewModel, isPresented: Binding<Bool>, searchText: Binding<String> = Binding.constant("")) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._isPresented = isPresented
        self._searchText = searchText
    }

    var body: some View {
        VStack {
            HStack {
                Text.build(theme.font.body.large(L10n.Product.Color.title))
                    .foregroundStyle(Theme.contentContentPrimary)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Icon.close.image
                        .resizable()
                        .scaledToFit()
                        .frame(size: Constants.sheetCloseIconSize)
                        .foregroundStyle(Theme.contentContentPrimary)
                }
                .accessibilityLabel(Text(L10n.Accessibility.close))
            }
            .padding([.top, .horizontal], theme.spacing.space200)

            ThemedDivider.horizontalThin
                .padding(.bottom, theme.spacing.space100)

            colorItemsView
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .backgroundInteractionEnabledIfAvailable()
    }
}

private extension View {
    /// The sheet is half-height, so the page stays visible behind it and must stay scrollable —
    /// the behaviour the removed wrapper sheet used to provide.
    @ViewBuilder func backgroundInteractionEnabledIfAvailable() -> some View {
        if #available(iOS 16.4, *) {
            presentationBackgroundInteraction(.enabled)
        } else {
            self
        }
    }
}

private extension ProductDetailsColorSheet {
    @ViewBuilder var colorItemsView: some View {
        ScrollView {
            ForEach(viewModel.colorSwatches(filteredBy: searchText)) { item in
                VStack {
                    Button {
                        viewModel.colorSelectionConfiguration.selectedItem = item
                        isPresented = false
                    } label: {
                        HStack(spacing: theme.spacing.space200) {
                            ColorSwatchView(
                                item: item,
                                swatchSize: .normal,
                                isSelected: viewModel.colorSelectionConfiguration.selectedItem == item
                            )

                            Text.build(theme.font.body.medium(item.name.capitalized))

                            Spacer()

                            if viewModel.colorSelectionConfiguration.selectedItem == item {
                                checkmark
                            }
                        }
                    }
                    .tint(Theme.contentContentPrimary)

                    ThemedDivider.horizontalThin
                }
            }
            .padding(.horizontal, theme.spacing.space200)
            .padding(.vertical, theme.spacing.space100)
        }
        .searchable(
            placeholder: L10n.Pdp.SearchColors.placeholder,
            placeholderOnFocus: L10n.Pdp.SearchColors.placeholder,
            searchText: $searchText,
            theme: .soft,
            dismissConfiguration: .init(type: .cancel(title: L10n.SearchBar.cancel)),
            verticalSpacing: theme.spacing.space200
        )
    }

    @ViewBuilder var checkmark: some View {
        Icon.checkmark.image
            .resizable()
            .scaledToFit()
            .frame(size: Constants.colorCheckmarkSize)
    }
}

#if DEBUG
#Preview {
    ProductDetailsColorSheet(
        viewModel: MockProductDetailsViewModel(),
        isPresented: .constant(true),
        searchText: .constant("")
    )
}
#endif
