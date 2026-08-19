import Model
import SharedUI
import SwiftUI
#if DEBUG
import Mocks
#endif

private enum Constants {
    static let sheetCloseIconSize: CGFloat = 16
    static let minTapTargetSize: CGFloat = 44
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
                Text.build(theme.font.heading.xSmall(L10n.Pdp.ColourSelector.title))
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
                // An out-of-stock colour cannot be the selection the row draws, matching the card
                // grid — otherwise the two surfaces disagree about the same colour.
                let isSelected = !item.isDisabled && viewModel.colorSelectionConfiguration.selectedItem == item

                VStack {
                    Button {
                        viewModel.colorSelectionConfiguration.selectedItem = item
                        isPresented = false
                    } label: {
                        // The design puts the name first and the swatch at the trailing edge, and
                        // marks the selection with the swatch's own border rather than a checkmark.
                        HStack(spacing: theme.spacing.space200) {
                            // Bold marks the selection, as it does on the card grid.
                            Text.build(
                                isSelected
                                    ? theme.font.body.mediumBold(item.name.capitalized)
                                    : theme.font.body.medium(item.name.capitalized)
                            )
                            .foregroundStyle(
                                item.isDisabled ? Theme.contentContentTerciary : Theme.contentContentPrimary
                            )

                            Spacer()

                            ColorSwatchView(item: item, swatchSize: .small, isSelected: isSelected)
                        }
                        // The 24pt swatch is the tallest thing in the row, so without this the
                        // button is 24pt; and the gap the Spacer opens takes no taps without a
                        // content shape.
                        .frame(minHeight: Constants.minTapTargetSize)
                        .contentShape(Rectangle())
                    }
                    // An out-of-stock colour is not selectable here either — the card grid disables
                    // it, and the same colour must not become selectable purely because the product
                    // carries enough colours to open the sheet instead.
                    .disabled(item.isDisabled)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    // "Dimmed" alone does not say why; the size chip announces the same reason.
                    .accessibilityValueOrNone(
                        item.isDisabled ? L10n.Pdp.Colour.OutOfStock.accessibilityValue : nil
                    )

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
