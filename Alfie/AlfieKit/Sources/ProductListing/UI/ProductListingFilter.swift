import Combine
import Model
import SharedUI
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
        VStack(spacing: Primitives.Spacing.spacing8) {
            header
            ThemedDivider.horizontalThin
            VStack(spacing: Primitives.Spacing.spacing24) {
                listStyleView
                sortView
            }.padding(.vertical, Primitives.Spacing.spacing16)
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
                    .foregroundStyle(Primitives.Colours.neutrals900)
            })
            Spacer()
            ThemedToolbarTitle(style: .text(L10n.Plp.RefineAndSort.title))
            Spacer()
        }
        .padding(.horizontal, Primitives.Spacing.spacing24)
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
                .foregroundStyle(Primitives.Colours.neutrals800)
            Spacer()
            ProductListingListStyleSelector(selectedStyle: $listStyle)
        }
        .padding(.horizontal, Primitives.Spacing.spacing16)
    }

    private enum Constants {
        static let listStyleFontSize: CGFloat = 18
        static let listStyleFont = DesignSystem.shared.font.body.medium.uiFont.withSize(Constants.listStyleFontSize).font
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
