import BFFGraphAPI
import Common
import Foundation
import Models

extension BFFGraphAPI.GetProductQuery.Data.Product {
    public func convertToProduct() -> Product {
        fragments.productFragment.convertToProduct()
    }
}

extension BFFGraphAPI.ProductFragment {
    func convertToProduct() -> Product {
        let colors: [Product.Colour] = colours?.map { $0.fragments.colourFragment.convertToColour() } ?? []

        return Product(
            id: id,
            styleNumber: styleNumber,
            name: name,
            brand: brand.fragments.brandFragment.convertToBrand(),
            shortDescription: shortDescription,
            longDescription: longDescription,
            slug: slug,
            priceRange: priceRange?.fragments.priceRangeFragment.convertToPriceRange(),
            attributes: attributes?.map(\.fragments.attributesFragment).convertToAttributeCollection(),
            defaultVariant: defaultVariant.fragments.variantFragment.convertToVariant(colours: colors),
            variants: variants.map { $0.fragments.variantFragment.convertToVariant(colours: colors) },
            colours: colors
        )
    }
}
