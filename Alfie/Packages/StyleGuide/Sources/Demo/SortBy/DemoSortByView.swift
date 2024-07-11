import SwiftUI

struct DemoSortByView: View {
    @State private var sortBy: SortByType = .mostPopular
    private var list: [SortByItem] = [
        .init(value: .mostPopular, title: "Most Popular", icon: .heart),
        .init(value: .priceHighToLow, title: "Price-High to Low", icon: .saleTag),
        .init(value: .priceLowToHigh, title: "Price - Low to High", icon: .saleTag),
        .init(value: .newIn, title: "New-in"),
        .init(value: .alphaAsc, title: "A-Z"),
        .init(value: .alphDesc, title: "Z-A"),
    ]

    var body: some View {
        VStack {
            DemoHelper.demoSectionHeader(title: "Sort By")
                .padding(.vertical, Spacing.space400)
                .padding(.horizontal, Spacing.space200)
            SortByView(sortBy: $sortBy, title: "Sort By", options: list)
        }
    }
}

#Preview {
    DemoSortByView()
}
