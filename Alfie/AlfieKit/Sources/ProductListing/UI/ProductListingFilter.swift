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
        VStack(spacing: theme.spacing.space100) {
            header
            ThemedDivider.horizontalThin
            VStack(spacing: theme.spacing.space300) {
                listStyleView
                sortView
            }.padding(.vertical, theme.spacing.space200)
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
                ThemedIcon(
                    .close,
                    size: .medium,
                    tint: Theme.contentContentPrimary,
                    accessibilityLabel: L10n.Accessibility.close
                )
            })
            Spacer()
            ThemedToolbarTitle(style: .text(L10n.Plp.RefineAndSort.title))
            Spacer()
        }
        .padding(.horizontal, theme.spacing.space300)
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
            Text.build(theme.font.body.medium(L10n.Plp.ListStyle.Option.title))
                .foregroundStyle(Theme.contentContentPrimary)
            Spacer()
            ProductListingListStyleSelector(selectedStyle: $listStyle)
        }
        .padding(.horizontal, theme.spacing.space200)
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
