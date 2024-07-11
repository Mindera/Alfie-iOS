import BFFGraphApi
import Common
import Foundation
import Models

extension GetProductQuery.Data.Product {
    public func convertToProduct() -> Product {
        fragments.productFragment.convertToProduct()
    }
}

extension ProductFragment {
    func convertToProduct() -> Product {
        let colors: [Product.Colour] = colours?.map { $0.fragments.colourFragment.convertToColour() } ?? []

        return Product(id: id,
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
                       colours: colors)
    }
}

// MARK: - Privates

// MARK: Variants

private extension VariantFragment {
    /// Transforms a `VariantFragment` into a local model `Product.Variant`
    /// - Parameters:
    ///   - colours: the aggregation of all available colours from all variants.
    func convertToVariant(colours: [Product.Colour]) -> Product.Variant {
        Product.Variant(sku: sku,
                        size: size?.fragments.sizeTreeFragment.convertToSize(),
                        colour: colours.first { $0.id == colour?.id },
                        attributes: attributes?.map(\.fragments.attributesFragment).convertToAttributeCollection(),
                        stock: stock,
                        price: price.fragments.priceFragment.convertToPrice())
    }
}

// MARK: Sizes

private extension SizeTreeFragment {
    func convertToSize() -> Product.ProductSize {
        Product.ProductSize(id: id,
                            value: value,
                            scale: scale,
                            description: description,
                            sizeGuide: sizeGuide?.convertToSizeGuide())
    }
}

private extension SizeTreeFragment.SizeGuide {
    func convertToSizeGuide() -> Product.SizeGuide {
        Product.SizeGuide(id: id,
                          name: name,
                          description: description,
                          sizes: sizes.map { $0.convertToSizeGuideSizes() })
    }
}

private extension SizeTreeFragment.SizeGuide.Size {
    func convertToSizeGuideSizes() -> Product.ProductSize {
        Product.ProductSize(id: id,
                            value: value,
                            scale: scale,
                            description: description,
                            sizeGuide: nil)
    }
}

// MARK: Colour

private extension ColourFragment {
    func convertToColour() -> Product.Colour {
        Product.Colour(id: id,
                       swatch: swatch?.fragments.imageFragment.convertToImage(),
                       name: name,
                       media: media?.compactMap { $0.fragments.mediaFragment.convertToMedia() })
    }
}
