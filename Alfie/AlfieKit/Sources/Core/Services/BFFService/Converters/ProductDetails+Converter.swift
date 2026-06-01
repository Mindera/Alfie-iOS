import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.ProductDetailsFragment {
    func convertToProduct() -> Product {
        let fragmentVariants = (variants ?? []).compactMap { $0 }
        let domainVariants = fragmentVariants.map { $0.convertToVariant() }

        // `defaultVariantId` is matched against the BFF variant `id`, which the domain
        // `Product.Variant` does not carry — so resolve the default by index here, while we
        // still have the fragment variants, then map to the converted domain variant.
        let defaultVariant: Product.Variant
        if let index = defaultVariantIndex(in: fragmentVariants) {
            defaultVariant = domainVariants[index]
        } else {
            defaultVariant = syntheticDefaultVariant()
        }

        let lowMoney = priceRange.minVariantPrice.fragments.moneyFragment.toDomainMoney()
        let highMoneyRaw = priceRange.maxVariantPrice.fragments.moneyFragment.toDomainMoney()
        // Only expose a price range when the variants actually span different prices. For a single
        // effective price, leave `priceRange` nil so `Product.priceType` falls through to its `.sale`
        // branch (struck-through `was` price) instead of being forced to `.default`/`.range`.
        let domainPriceRange: Model.PriceRange? = highMoneyRaw == lowMoney
            ? nil
            : Model.PriceRange(low: lowMoney, high: highMoneyRaw)

        let colours = aggregateColours(from: domainVariants)

        return Product(
            id: id,
            styleNumber: "",
            name: name,
            brand: Brand(name: brandName ?? "", slug: ""),
            shortDescription: "",
            longDescription: descriptionHtml?.strippingHTML(),
            slug: slug,
            priceRange: domainPriceRange,
            attributes: nil,
            defaultVariant: defaultVariant,
            variants: domainVariants,
            colours: colours.isEmpty ? nil : colours
        )
    }

    // MARK: - Default variant

    /// Resolution rule: the variant whose `id` matches `defaultVariantId`; else the first
    /// in-stock variant; else the first variant. Returns nil only when there are no variants.
    private func defaultVariantIndex(in variants: [BFFGraphAPI.ProductDetailsFragment.Variant]) -> Int? {
        if
            let defaultVariantId,
            let index = variants.firstIndex(where: { $0.id == defaultVariantId })
        {
            return index
        }
        if let index = variants.firstIndex(where: { ($0.inventory?.available ?? 0) > 0 }) {
            return index
        }
        return variants.isEmpty ? nil : 0
    }

    /// Fallback when the BFF returns no variants: synthesise one from product-level fields so
    /// `Product.defaultVariant` (non-optional) is always satisfiable.
    private func syntheticDefaultVariant() -> Product.Variant {
        let colour: Product.Colour? = primaryImage.flatMap { image in
            URL(string: image.url).map { url in
                Product.Colour(
                    swatch: nil,
                    name: "",
                    media: [.image(MediaImage(alt: image.altText, mediaContentType: .image, url: url))]
                )
            }
        }

        return Product.Variant(
            sku: "",
            size: nil,
            colour: colour,
            attributes: nil,
            stock: inventoryTotal ?? 0,
            price: Price(amount: priceRange.minVariantPrice.fragments.moneyFragment.toDomainMoney(), was: nil)
        )
    }

    // MARK: - Colours

    /// Distinct colours across variants, preserving the order the BFF returned them in.
    private func aggregateColours(from variants: [Product.Variant]) -> [Product.Colour] {
        var result: [Product.Colour] = []
        variants.forEach { variant in
            guard
                let colour = variant.colour,
                !result.contains(where: { $0.id == colour.id })
            else {
                return
            }
            result.append(colour)
        }
        return result
    }
}

extension BFFGraphAPI.ProductDetailsFragment.Variant {
    func convertToVariant() -> Product.Variant {
        let domainMedia: [Media] = (media ?? []).compactMap { $0?.toDomainMedia() }

        // Reconstruct typed colour/size from the generic `optionValues[]` by matching the
        // option name case-insensitively. Unknown option names fall through to nil so the
        // selectors simply don't render for that dimension.
        let colour: Product.Colour? = optionValues
            .first { $0.name.isColourOptionName }
            .map { option in
                Product.Colour(
                    id: option.value,
                    swatch: domainMedia.first?.asImage,
                    name: option.value,
                    media: domainMedia
                )
            }

        let size: Product.ProductSize? = optionValues
            .first { $0.name.isSizeOptionName }
            .map { option in
                Product.ProductSize(
                    id: option.value,
                    value: option.value,
                    scale: nil,
                    description: nil,
                    sizeGuide: nil
                )
            }

        let was = compareAtPrice?.fragments.moneyFragment.toDomainMoney()

        return Product.Variant(
            sku: sku,
            size: size,
            colour: colour,
            attributes: nil,
            stock: inventory?.available ?? 0,
            price: Model.Price(amount: price.fragments.moneyFragment.toDomainMoney(), was: was)
        )
    }
}

extension BFFGraphAPI.ProductDetailsFragment.Variant.Medium {
    func toDomainMedia() -> Media? {
        guard let url = URL(string: url) else { return nil }
        return .image(MediaImage(alt: altText, mediaContentType: .image, url: url))
    }
}

private extension String {
    var isColourOptionName: Bool {
        let name = lowercased()
        return name == "color" || name == "colour"
    }

    var isSizeOptionName: Bool {
        lowercased() == "size"
    }
}
