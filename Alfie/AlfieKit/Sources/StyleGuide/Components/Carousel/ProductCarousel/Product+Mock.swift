import Common
import Foundation
import Models

extension Product {
    public static let fixtures: [Product] = [
        .blazer,
        .hat,
        .neckDress,
        .necklace,
        .dress,
        .sandal,
        .jacket,
    ]

    public static func fixtures(includeMedia: Bool) -> [Product] {
        if includeMedia {
            fixtures
        } else {
            fixtures.map { fixture in
                Product(
                    id: fixture.id,
                    styleNumber: fixture.styleNumber,
                    name: fixture.name,
                    brand: fixture.brand,
                    shortDescription: fixture.shortDescription,
                    slug: fixture.shortDescription,
                    defaultVariant: Product.Variant(
                        sku: fixture.defaultVariant.sku,
                        size: fixture.defaultVariant.size,
                        colour: fixture.defaultVariant.colour?.replacing(media: nil),
                        attributes: fixture.defaultVariant.attributes,
                        stock: fixture.defaultVariant.stock,
                        price: fixture.defaultVariant.price
                    ),
                    variants: fixture.variants.map { variant in
                        Product.Variant(
                            sku: variant.sku,
                            size: variant.size,
                            colour: variant.colour?.replacing(media: nil),
                            attributes: variant.attributes,
                            stock: variant.stock,
                            price: variant.price
                        )
                    },
                    colours: fixture.colours?.map { $0.replacing(media: nil) }
                )
            }
        }
    }
}

private extension Product.Colour {
    func replacing(media: [Media]? = nil) -> Product.Colour {
        .init(id: id, swatch: swatch, name: name, media: media)
    }
}

extension Product {
    // MARK: - Necklace -

    public static let necklace = Product(
        id: "1",
        styleNumber: "26427344",
        name: "Sardinia Necklace",
        brand: .init(name: "Amber Sceats", slug: "amber-sceats"),
        shortDescription: "The Sardinia Necklace by Amber Sceats boasts a modern silhouette, featuring polished 24K Gold plated teardrop pendants.", // swiftlint:disable:this line_length
        slug: "amber-sceats-sardinia-necklace-26427344",
        defaultVariant: Self.necklaceVariant,
        variants: [Self.necklaceVariant],
        colours: [necklaceColor]
    )

    private static let necklaceColor: Product.Colour = .init(
        swatch: nil,
        name: "24K Gold Plate",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/6858599/pexels-photo-6858599.jpeg?auto=compress&cs=tinysrgb&w=600")
                )
            ),
        ]
    )

    private static let necklaceVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: nil,
        colour: necklaceColor,
        attributes: nil,
        stock: 1,
        price: .init(amount: .init(currencyCode: "AUD", amount: 27900, amountFormatted: "$279.00"), was: nil)
    )

    // MARK: - Blazer -

    public static let blazer = Product(
        id: "2",
        styleNumber: "26533700",
        name: "June Double Breasted Blazer",
        brand: .init(name: "Reiss", slug: "reiss"),
        shortDescription: "This double-breasted june blazer in blue is crafted from a tencel blend for enhanced durability and a soft woven texture.", // swiftlint:disable:this line_length
        slug: "reiss-june-double-breasted-blazer-26533700",
        defaultVariant: Self.blazerVariant,
        variants: [Self.blazerVariant],
        colours: [blazerColor]
    )

    private static let blazerColor: Product.Colour = .init(
        swatch: nil,
        name: "June Blue",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/27008317/pexels-photo-27008317/free-photo-of-an-elegant-woman-wearing-brown-heels-and-holding-a-brown-bag.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let blazerVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "10", scale: "AU", description: nil, sizeGuide: nil),
        colour: blazerColor,
        attributes: nil,
        stock: 1,
        price: .init(
            amount: .init(currencyCode: "AUD", amount: 29900, amountFormatted: "$299.00"),
            was: .init(currencyCode: "AUD", amount: 49500, amountFormatted: "$495.00")
        )
    )

    // MARK: - Dress -

    public static let dress = Product(
        id: "3",
        styleNumber: "26320534",
        name: "Tie front shirt dress",
        brand: .init(name: "Gucci", slug: "gucci"),
        shortDescription: "This midi length shirt dress features a tie waist, voluminous skirt and full button down placket.", // swiftlint:disable:this line_length
        slug: "gucci-tie-front-shirt-dress-26320534",
        defaultVariant: Self.dressVariant,
        variants: [Self.dressVariant],
        colours: [dressColor]
    )

    private static let dressColor: Product.Colour = .init(
        swatch: nil,
        name: "Blue Stripe",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/4428388/pexels-photo-4428388.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let dressVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "16", scale: "AU", description: nil, sizeGuide: nil),
        colour: dressColor,
        attributes: nil,
        stock: 1,
        price: .init(
            amount: .init(currencyCode: "AUD", amount: 9900, amountFormatted: "$99.00"),
            was: .init(currencyCode: "AUD", amount: 15900, amountFormatted: "$159.00")
        )
    )

    // MARK: - Hat -

    public static let hat = Product(
        id: "4",
        styleNumber: "26626706",
        name: "Baseball hat with Gucci print | Baseball hat with Gucci print | Baseball hat with Gucci print",
        brand: .init(name: "Gucci", slug: "gucci"),
        shortDescription: "Well-known prints of the House constantly evolve to tell a unique narrative. ",
        longDescription: "An essential storytelling element of the Cruise 2024 collection, the 'Gucci Made in Italy' print defines this beige canvas baseball hat with a light brown leather trim.", // swiftlint:disable:this line_length
        slug: "gucci-baseball-hat-with-gucci-print-26626706",
        priceRange: .init(
            low: .init(currencyCode: "AUD", amount: 75000, amountFormatted: "$750.00"),
            high: .init(currencyCode: "AUD", amount: 85000, amountFormatted: "$850.00")
        ),
        defaultVariant: Self.hatVariant,
        variants: [Self.hatVariant],
        colours: [hatColor]
    )

    private static let hatColor: Product.Colour = .init(
        swatch: nil,
        name: "White",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/9558689/pexels-photo-9558689.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let hatVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "L", scale: "INT", description: nil, sizeGuide: nil),
        colour: hatColor,
        attributes: nil,
        stock: 1,
        price: .init(amount: .init(currencyCode: "AUD", amount: 29900, amountFormatted: "$299.00"), was: nil)
    )

    // MARK: - Neck Dress -

    public static let neckDress = Product(
        id: "5",
        styleNumber: "26203353",
        name: "Admiral Crepe Funnel Neck Dress",
        brand: .init(name: "Theory", slug: "theory"),
        shortDescription: "Introducing our stylish Admiral Crepe Funnel Neck Dress, the epitome of chic and contemporary elegance.", // swiftlint:disable:this line_length
        slug: "theory-admiral-crepe-funnel-neck-dress-26203353",
        defaultVariant: Self.neckDressVariant,
        variants: [Self.neckDressVariant],
        colours: [neckDressColor]
    )

    private static let neckDressColor: Product.Colour = .init(
        swatch: nil,
        name: "Black",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/14993680/pexels-photo-14993680/free-photo-of-young-woman-in-a-dress.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let neckDressVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "14", scale: "AU", description: nil, sizeGuide: nil),
        colour: neckDressColor,
        attributes: nil,
        stock: 1,
        price: .init(
            amount: .init(currencyCode: "AUD", amount: 47500, amountFormatted: "$475.00"),
            was: .init(currencyCode: "AUD", amount: 57000, amountFormatted: "$570.00")
        )
    )

    // MARK: - Sandal -

    public static let sandal = Product(
        id: "6",
        styleNumber: "26241404",
        name: "Women's Verona Sandal",
        brand: .init(name: "Alias Mae", slug: "alias-mae"),
        shortDescription: "Alias Mae Verona sandal in natural raffia with chunky sole, crossover vamp and ankle strap with buckle.", // swiftlint:disable:this line_length
        slug: "alias-mae-womens-verona-sandal-26241404",
        defaultVariant: Self.sandalVariant,
        variants: [Self.sandalVariant],
        colours: [sandalColor]
    )

    private static let sandalColor: Product.Colour = .init(
        swatch: nil,
        name: "Natural/Raffia",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/10283296/pexels-photo-10283296.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let sandalVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "37", scale: "EU", description: nil, sizeGuide: nil),
        colour: sandalColor,
        attributes: nil,
        stock: 1,
        price: .init(amount: .init(currencyCode: "AUD", amount: 26995, amountFormatted: "$269.95"), was: nil)
    )

    // MARK: - Jacket -

    public static let jacket = Product(
        id: "7",
        styleNumber: "26630621",
        name: "Maltese Rain Jacket",
        brand: .init(name: "C&M Camilla & Marc | C&M Camilla & Marc", slug: "c-and-m-camilla-and-marc"),
        shortDescription: "CAMILLA AND MARC Maltese Rain Jacket in Black.",
        slug: "candm-camilla-and-marc-maltese-rain-jacket-26630621",
        defaultVariant: Self.jacketVariant,
        variants: [Self.jacketVariant],
        colours: [jacketColor]
    )

    private static let jacketColor: Product.Colour = .init(
        swatch: nil,
        name: "Black",
        media: [
            .image(
                MediaImage(
                    alt: nil,
                    mediaContentType: .image,
                    url: URL.fromString("https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
                )
            ),
        ]
    )

    private static let jacketVariant: Product.Variant = .init(
        sku: UUID().uuidString,
        size: .init(value: "S-M", scale: "INT", description: nil, sizeGuide: nil),
        colour: jacketColor,
        attributes: nil,
        stock: 1,
        price: .init(amount: .init(currencyCode: "AUD", amount: 65000, amountFormatted: "$650.00"), was: nil)
    )
}
