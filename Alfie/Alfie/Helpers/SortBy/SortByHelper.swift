import StyleGuide

enum SortByHelper {
    static let options: [SortByItemProtocol] = [
        SortByItem(value: .priceDesc, title: LocalizableSortBy.priceHighToLow, icon: .chartDownTrend),
        SortByItem(value: .priceAsc, title: LocalizableSortBy.priceLowToHigh, icon: .chartUpTrend),
        SortByItem(value: .alphaAsc, title: LocalizableSortBy.alphaAsc, icon: .aCircle),
        SortByItem(value: .alphaDesc, title: LocalizableSortBy.alphDesc, icon: .zCircle),
    ]
}
