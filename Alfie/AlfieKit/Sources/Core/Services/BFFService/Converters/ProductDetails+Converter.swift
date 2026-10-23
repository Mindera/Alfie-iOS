import BFFGraph
import Foundation
import Model
import Utils

extension BFFGraphAPI.ProductDetailsFragment {
    func convertToProduct() -> Product {
        let fragmentVariants = (variants ?? []).compactMap { $0 }
        let gallery = images.compactMap { Media.image(url: $0.url, altText: $0.altText) }
        let primaryImageMedia = primaryImage.flatMap { Media.image(url: $0.url, altText: $0.altText) }
        let domainVariants = fragmentVariants.map {
            $0.convertToVariant(gallery: gallery, primaryImage: primaryImageMedia)
        }

        // Resolved by index on the fragment variants, which carry the `inventory` the in-stock
        // fallback needs, then mapped to the converted domain variant.
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
        if let defaultVariantId, let index = variants.firstIndex(where: { $0.id == defaultVariantId }) {
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
        let colour: Product.Colour? = primaryImage
            .flatMap { Media.image(url: $0.url, altText: $0.altText) }
            .map { Product.Colour(swatch: nil, name: "", media: [$0]) }

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
    func convertToVariant(gallery: [Media], primaryImage: Media?) -> Product.Variant {
        let variantImage = (media ?? []).lazy
            .compactMap { $0.flatMap { Media.image(url: $0.url, altText: $0.altText) } }
            .first
        let resolvedMedia = Media.colourMedia(gallery: gallery, variantImage: variantImage, primaryImage: primaryImage)

        // Reconstruct typed colour/size from the generic `optionValues[]` by matching the option
        // name case-insensitively. When there is no colour dimension (e.g. Shopify single-option
        // "Title" products) we still wrap the media in a nameless colour so it isn't lost — without
        // it `Product.Variant.media` (== `colour?.media`) would be empty and the carousel blank.
        let colour: Product.Colour?
        if let colourOption = optionValues.first(where: { $0.name.isColourOptionName }) {
            colour = Product.Colour(
                id: colourOption.value,
                swatch: resolvedMedia.first?.asImage,
                name: colourOption.value,
                media: resolvedMedia
            )
        } else if !resolvedMedia.isEmpty {
            colour = Product.Colour(id: "", swatch: resolvedMedia.first?.asImage, name: "", media: resolvedMedia)
        } else {
            colour = nil
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

        let amount = price.fragments.moneyFragment.toDomainMoney()
        // Only treat `compareAtPrice` as a genuine markdown ("was") when it is strictly higher than
        // the current price. A BFF value equal to or below `price` would otherwise render a bogus
        // sale (was ≤ now / a price increase).
        let compareAt = compareAtPrice?.fragments.moneyFragment.toDomainMoney()
        let was: Money? = (compareAt?.amount ?? 0) > amount.amount ? compareAt : nil

        return Product.Variant(
            id: id,
            sku: sku,
            size: size,
            colour: colour,
            attributes: nil,
            stock: inventory?.available ?? 0,
            price: Model.Price(amount: amount, was: was)
        )
    }
}

private extension Media {
    static func image(url: String, altText: String?) -> Media? {
        URL(string: url).map { .image(MediaImage(alt: altText, mediaContentType: .image, url: $0)) }
    }

    /// The Gallery, starting on the Variant image; without a Gallery, the Variant image, else `primaryImage`.
    static func colourMedia(gallery: [Media], variantImage: Media?, primaryImage: Media?) -> [Media] {
        guard !gallery.isEmpty else {
            return [variantImage ?? primaryImage].compactMap { $0 }
        }
        guard let variantImage else { return gallery }
        let variantImageURL = variantImage.asImage?.url
        let matchingPhoto = gallery.first { $0.asImage?.url == variantImageURL }
        return [matchingPhoto ?? variantImage] + gallery.filter { $0.asImage?.url != variantImageURL }
    }
}

private extension String {
    private var normalisedOptionName: String {
        trimmingCharacters(in: .whitespaces).lowercased()
    }

    var isColourOptionName: Bool {
        normalisedOptionName == "color" || normalisedOptionName == "colour"
    }

    var isSizeOptionName: Bool {
        normalisedOptionName == "size"
    }
}
