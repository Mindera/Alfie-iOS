import Models
import StyleGuide
import SwiftUI
#if DEBUG
import Mocks
#endif

private enum Constants {
    static let sheetCloseIconSize: CGFloat = 16
    static let colorCheckmarkSize: CGFloat = 16
}

struct ProductDetailsColorSheet<ViewModel: ProductDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Binding private var isPresented: Bool
    @Binding private var searchText: String

    internal init(viewModel: ViewModel, isPresented: Binding<Bool>, searchText: Binding<String>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isPresented = isPresented
        self._searchText = searchText
    }

    var body: some View {
        VStack {
            HStack {
                Text(LocalizableProductDetails.$color)
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
                                    Icon.checkmark.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(size: Constants.colorCheckmarkSize)
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
                placeholder: LocalizableProductDetails.$searchColors,
                placeholderOnFocus: LocalizableProductDetails.$searchColors,
                searchText: $searchText,
                theme: .soft,
                dismissConfiguration: .init(type: .cancel(title: LocalizableSearch.$cancel)),
                verticalSpacing: Spacing.space200
            )
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
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
