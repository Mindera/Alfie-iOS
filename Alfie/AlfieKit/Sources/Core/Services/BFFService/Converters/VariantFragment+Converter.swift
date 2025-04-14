import BFFGraphApi
import Model

extension BFFGraphApi.VariantFragment {
    /// Transforms a `VariantFragment` into a local model `Product.Variant`
    /// - Parameters:
    ///   - colours: the aggregation of all available colours from all variants.
    func convertToVariant(colours: [Product.Colour]) -> Product.Variant {
        Product.Variant(
            sku: sku,
            size: size?.fragments.sizeTreeFragment.convertToSize(),
            colour: colours.first { $0.id == colour?.id },
            attributes: attributes?.map(\.fragments.attributesFragment).convertToAttributeCollection(),
            stock: stock,
            price: price.fragments.priceFragment.convertToPrice()
        )
    }
}
