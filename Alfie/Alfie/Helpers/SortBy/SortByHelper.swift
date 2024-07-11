import StyleGuide

enum SortByHelper {
    static let options: [SortByItemProtocol] = [
        SortByItem(value: .mostPopular, title: LocalizableSortBy.mostPopular, icon: .heart),
        SortByItem(value: .priceHighToLow, title: LocalizableSortBy.priceHighToLow, icon: .saleTag),
        SortByItem(value: .priceLowToHigh, title: LocalizableSortBy.priceLowToHigh, icon: .saleTag),
        SortByItem(value: .newIn, title: LocalizableSortBy.newIn, icon: .saleTag),
        SortByItem(value: .alphaAsc, title: LocalizableSortBy.alphaAsc, icon: .saleTag),
        SortByItem(value: .alphDesc, title: LocalizableSortBy.alphDesc, icon: .saleTag),
    ]
}
