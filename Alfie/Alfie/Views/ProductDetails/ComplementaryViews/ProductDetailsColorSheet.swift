import SwiftUI
import StyleGuide
import Models
#if DEBUG
import Mocks
#endif

private enum Constants {
    static let sheetCloseIconSize: CGFloat = 16
    static let colorCheckmarkSize: CGFloat = 16
}

enum ModalSheetType {
    case color
    case size
}

struct ProductDetailsColorSheet<ViewModel: ProductDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @Binding private var isPresented: Bool
    @Binding private var searchText: String
    
    private let type: ModalSheetType

    internal init(viewModel: ViewModel, type: ModalSheetType, isPresented: Binding<Bool>, searchText: Binding<String>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isPresented = isPresented
        self._searchText = searchText
        self.type = type
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
                        .frame(size: Constants.sheetCloseIconSize)
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
                                ColorSwatchView(item: item,
                                                swatchSize: .normal,
                                                isSelected: viewModel.colorSelectionConfiguration.selectedItem == item)

                                Text.build(theme.font.paragraph.normal(item.name.capitalized))

                                Spacer()

                                if viewModel.colorSelectionConfiguration.selectedItem == item {
                                    Icon.checkmark.image
                                        .resizable()
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
            .searchable(placeholder: LocalizableProductDetails.$searchColors,
                        placeholderOnFocus: LocalizableProductDetails.$searchColors,
                        searchText: $searchText, theme: .soft,
                        dismissConfiguration: .init(type: .cancel(title: LocalizableSearch.$cancel)),
                        verticalSpacing: Spacing.space200)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

#if DEBUG
#Preview {
    ProductDetailsColorSheet(viewModel: MockProductDetailsViewModel(),
                             type: .color,
                             isPresented: .constant(true),
                             searchText: .constant(""))
}
#endif
