import StyleGuide

enum SortByHelper {
    static let options: [SortByItemProtocol] = [
        SortByItem(value: .priceDesc, title: L10n.sortByPriceHighToLowTitle, icon: .chartDownTrend),
        SortByItem(value: .priceAsc, title: L10n.sortByPriceLowToHigh, icon: .chartUpTrend),
        SortByItem(value: .alphaAsc, title: L10n.sortByAlphaAscTitle, icon: .aCircle),
        SortByItem(value: .alphaDesc, title: L10n.sortByAlphaDescTitle, icon: .zCircle),
    ]
}
