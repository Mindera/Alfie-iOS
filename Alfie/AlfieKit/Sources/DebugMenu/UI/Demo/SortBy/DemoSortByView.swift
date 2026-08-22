import SwiftUI

import SharedUI
struct DemoSortByView: View {
    @State private var sortBy: SortByType?
    private var list: [SortByItem] = [
        .init(value: .priceDesc, title: "Price - High to Low", icon: .chartDownTrend),
        .init(value: .priceAsc, title: "Price - Low to High", icon: .chartUpTrend),
        .init(value: .alphaAsc, title: "A-Z"),
    ]

    var body: some View {
        VStack {
            DemoHelper.demoSectionHeader(title: "Sort By")
                .padding(.vertical, Primitives.Spacing.spacing32)
                .padding(.horizontal, Primitives.Spacing.spacing16)
            SortByView(sortBy: $sortBy, title: "Sort By", options: list)
        }
    }
}

#Preview {
    DemoSortByView()
}
