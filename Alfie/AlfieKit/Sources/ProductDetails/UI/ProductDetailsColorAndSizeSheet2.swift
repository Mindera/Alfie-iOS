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

enum SheetType {
    case color
    case size
}

struct ProductDetailsColorAndSizeSheet2<ViewModel: ProductDetailsViewModelProtocol2>: View {
    @StateObject private var viewModel: ViewModel
    @Binding private var isPresented: Bool
    @Binding private var searchText: String

    private let type: SheetType

    private var title: String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .color:
            L10n.Product.Color.title
        case .size:
            L10n.Product.Size.title
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    internal init(viewModel: ViewModel, type: SheetType, isPresented: Binding<Bool>, searchText: Binding<String> = Binding.constant("")) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isPresented = isPresented
        self._searchText = searchText
        self.type = type
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(Font(theme.font.paragraph.normal.withSize(18)))
                    .foregroundStyle(Colors.primary.mono900)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Icon.close.image
                        .resizable()
                        .scaledToFit()
                        .frame(size: Constants.sheetCloseIconSize)
                        .foregroundStyle(Colors.primary.mono900)
                }
            }
            .padding([.top, .horizontal], Spacing.space200)

            ThemedDivider.horizontalThin
                .padding(.bottom, Spacing.space100)

            itemsView
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

private extension ProductDetailsColorAndSizeSheet2 {
    @ViewBuilder var itemsView: some View {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .color:
            colorItemsView
        case .size:
            sizeItemsView
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    @ViewBuilder var colorItemsView: some View {
        ScrollView {
            ForEach(viewModel.colorSwatches(filteredBy: searchText)) { item in
                VStack {
                    Button {
                        viewModel.colorSelectionConfiguration.selectedItem = item
                        isPresented = false
                    } label: {
                        HStack(spacing: Spacing.space200) {
                            ColorSwatchView(
                                item: item,
                                swatchSize: .normal,
                                isSelected: viewModel.colorSelectionConfiguration.selectedItem == item
                            )

                            Text.build(theme.font.paragraph.normal(item.name.capitalized))

                            Spacer()

                            if viewModel.colorSelectionConfiguration.selectedItem == item {
                                checkmark
                            }
                        }
                    }
                    .tint(Colors.primary.black)

                    ThemedDivider.horizontalThin
                }
            }
            .padding(.horizontal, Spacing.space200)
            .padding(.vertical, Spacing.space100)
        }
        .searchable(
            placeholder: L10n.Pdp.SearchColors.placeholder,
            placeholderOnFocus: L10n.Pdp.SearchColors.placeholder,
            searchText: $searchText,
            theme: .soft,
            dismissConfiguration: .init(type: .cancel(title: L10n.SearchBar.cancel)),
            verticalSpacing: Spacing.space200
        )
    }

    @ViewBuilder var sizeItemsView: some View {
        ScrollView {
            ForEach(viewModel.sizingSelectionConfiguration.items) { item in
                VStack {
                    Button {
                        viewModel.sizingSelectionConfiguration.selectedItem = item
                        isPresented = false
                    } label: {
                        HStack(spacing: Spacing.space200) {
                            Text.build(theme.font.paragraph.normal(item.name.capitalized))

                            Spacer()

                            if viewModel.sizingSelectionConfiguration.selectedItem == item {
                                checkmark
                            }
                        }
                    }
                    .padding(.vertical, Spacing.space100)
                    .tint(Colors.primary.black)

                    ThemedDivider.horizontalThin
                }
            }
            .padding(.horizontal, Spacing.space200)
            .padding(.vertical, Spacing.space100)
        }
    }

    @ViewBuilder var checkmark: some View {
        Icon.checkmark.image
            .resizable()
            .scaledToFit()
            .frame(size: Constants.colorCheckmarkSize)
    }
}

//#if DEBUG
//#Preview {
//    ProductDetailsColorAndSizeSheet2(
//        viewModel: MockProductDetailsViewModel(),
//        type: .color,
//        isPresented: .constant(true),
//        searchText: .constant("")
//    )
//}
//#endif
