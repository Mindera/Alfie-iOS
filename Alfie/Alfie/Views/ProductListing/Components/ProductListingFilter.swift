import Combine
import Models
import Navigation
import StyleGuide
import SwiftUI

struct ProductListingFilter: View {
    @State private var sort: SortByType
    @Binding private var listStyle: ProductListingListStyle
    @Binding private var sortOption: String?
    @Binding private var isVisible: Bool
    private let onFilter: () -> Void

    init(
        isVisible: Binding<Bool>,
        listStyle: Binding<ProductListingListStyle>,
        sortOption: Binding<String?>,
        onFilter: @escaping () -> Void
    ) {
        self._isVisible = isVisible
        self._listStyle = listStyle
        self._sortOption = sortOption
        self.onFilter = onFilter

        if let option = sortOption.wrappedValue, let sortType = SortByType(rawValue: option) {
            sort = sortType
        } else {
            sort = .alphaDesc
        }
    }

    var body: some View {
        VStack(spacing: Spacing.space100) {
            header
            ThemedDivider.horizontalThin
            VStack(spacing: Spacing.space300) {
                listStyleView
                sortView
            }.padding(.vertical, Spacing.space200)
            Spacer()
            ThemedButton(text: L10n.Plp.ShowResults.Button.cta) {
                onFilter()
            }
        }.onChange(of: sort) { sort in
            sortOption = sort.rawValue
        }
    }

    var header: some View {
        HStack {
            Button(action: {
                isVisible.toggle()
            }, label: {
                Icon.close.image
                    .foregroundStyle(Colors.primary.black)
            })
            Spacer()
            ThemedToolbarTitle(style: .text(L10n.Plp.RefineAndSort.title))
            Spacer()
        }
        .padding(.horizontal, Spacing.space300)
    }

    var sortView: some View {
        SortByView(
            sortBy: $sort,
            title: L10n.Plp.SortBy.Option.title,
            options: SortByHelper.options
        )
    }

    var listStyleView: some View {
        HStack {
            Text(L10n.Plp.ListStyle.Option.title)
                .font(Constants.listStyleFont)
                .foregroundStyle(Colors.primary.mono900)
            Spacer()
            ProductListingListStyleSelector(selectedStyle: $listStyle)
        }
        .padding(.horizontal, Spacing.space200)
    }

    private enum Constants {
        static let listStyleFontSize: CGFloat = 18
        static let listStyleFont = ThemeProvider.shared.font.paragraph.normal.withSize(Constants.listStyleFontSize).font
    }
}

#Preview {
    ProductListingFilter(
        isVisible: .constant(true),
        listStyle: .constant(.grid),
        sortOption: .constant("")
    ) {
    }
}
