import StyleGuide

enum SortByHelper {
    static let options: [SortByItemProtocol] = [
        SortByItem(value: .priceDesc, title: L10n.SortBy.PriceHighToLow.title, icon: .chartDownTrend),
        SortByItem(value: .priceAsc, title: L10n.SortBy.PriceLowToHigh.title, icon: .chartUpTrend),
        SortByItem(value: .alphaAsc, title: L10n.SortBy.AlphaAsc.title, icon: .aCircle),
        SortByItem(value: .alphaDesc, title: L10n.SortBy.AlphaDesc.title, icon: .zCircle),
    ]
}
