// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProductListingQuery: GraphQLQuery {
  public static let operationName: String = "ProductListingQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ProductListingQuery($offset: Int!, $limit: Int!, $categoryId: String, $query: String, $sort: ProductListingSort) { productListing( offset: $offset limit: $limit categoryId: $categoryId query: $query sort: $sort ) { __typename title pagination { __typename ...PaginationFragment } products { __typename ...ProductFragment } } }"#,
      fragments: [AttributesFragment.self, BrandFragment.self, ColourFragment.self, ImageFragment.self, MediaFragment.self, MoneyFragment.self, PaginationFragment.self, PriceFragment.self, PriceRangeFragment.self, ProductFragment.self, SizeFragment.self, SizeGuideFragment.self, SizeGuideTreeFragment.self, SizeTreeFragment.self, VariantFragment.self]
    ))

  public var offset: Int
  public var limit: Int
  public var categoryId: GraphQLNullable<String>
  public var query: GraphQLNullable<String>
  public var sort: GraphQLNullable<GraphQLEnum<ProductListingSort>>

  public init(
    offset: Int,
    limit: Int,
    categoryId: GraphQLNullable<String>,
    query: GraphQLNullable<String>,
    sort: GraphQLNullable<GraphQLEnum<ProductListingSort>>
  ) {
    self.offset = offset
    self.limit = limit
    self.categoryId = categoryId
    self.query = query
    self.sort = sort
  }

  public var __variables: Variables? { [
    "offset": offset,
    "limit": limit,
    "categoryId": categoryId,
    "query": query,
    "sort": sort
  ] }

  public struct Data: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("productListing", ProductListing?.self, arguments: [
        "offset": .variable("offset"),
        "limit": .variable("limit"),
        "categoryId": .variable("categoryId"),
        "query": .variable("query"),
        "sort": .variable("sort")
      ]),
    ] }

    /// Retrieve a list of products
    public var productListing: ProductListing? { __data["productListing"] }

    /// ProductListing
    ///
    /// Parent Type: `ProductListing`
    public struct ProductListing: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.ProductListing }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("pagination", Pagination.self),
        .field("products", [Product].self),
      ] }

      /// Listing title
      public var title: String { __data["title"] }
      /// Pagination data
      public var pagination: Pagination { __data["pagination"] }
      /// Array of products
      public var products: [Product] { __data["products"] }

      /// ProductListing.Pagination
      ///
      /// Parent Type: `Pagination`
      public struct Pagination: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Pagination }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PaginationFragment.self),
        ] }

        /// Start point
        public var offset: Int { __data["offset"] }
        /// Records to return
        public var limit: Int { __data["limit"] }
        /// The total number of results
        public var total: Int { __data["total"] }
        /// Based on offset, how many pages are there?
        public var pages: Int { __data["pages"] }
        /// Which page are we on?
        public var page: Int { __data["page"] }
        /// Do we have a next page? (If null, no, else new offset)
        public var nextPage: Int? { __data["nextPage"] }
        /// Do we have a previous page? (If null, no, else new offset)
        public var previousPage: Int? { __data["previousPage"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var paginationFragment: PaginationFragment { _toFragment() }
        }
      }

      /// ProductListing.Product
      ///
      /// Parent Type: `Product`
      public struct Product: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Product }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductFragment.self),
        ] }

        /// Unique ID for the product and its variants.
        public var id: BFFGraphApi.ID { __data["id"] }
        /// App refers to products (including variants) as style numbers, so this is the product's unique identifier.
        public var styleNumber: String { __data["styleNumber"] }
        /// The formal name of the product.
        public var name: String { __data["name"] }
        /// The brand of the product.
        public var brand: Brand { __data["brand"] }
        /// For displaying a high and low price range if it exists.
        public var priceRange: PriceRange? { __data["priceRange"] }
        /// One-line description of the product.
        public var shortDescription: String { __data["shortDescription"] }
        /// Detailed description of the product.
        public var longDescription: String? { __data["longDescription"] }
        /// For building canonical URL to PDP.
        public var slug: String { __data["slug"] }
        /// Specific labels such as 'Bestseller' or 'New in'.
        @available(*, deprecated, message: "Unavailable from iSAMS, do not use")
        public var labels: [String]? { __data["labels"] }
        /// Product attributes common to all variants.
        public var attributes: [Attribute]? { __data["attributes"] }
        /// The 'default' variant.
        public var defaultVariant: DefaultVariant { __data["defaultVariant"] }
        /// All variants of the product, including the default one.
        public var variants: [Variant] { __data["variants"] }
        /// Aggregation of all available colours from all variants.
        public var colours: [Colour]? { __data["colours"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var productFragment: ProductFragment { _toFragment() }
        }

        /// ProductListing.Product.Brand
        ///
        /// Parent Type: `Brand`
        public struct Brand: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Brand }

          /// The ID for the brand
          public var id: BFFGraphApi.ID { __data["id"] }
          /// The display name of the brand
          public var name: String { __data["name"] }
          /// A slugified name for URL usage
          public var slug: String { __data["slug"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var brandFragment: BrandFragment { _toFragment() }
          }
        }

        /// ProductListing.Product.PriceRange
        ///
        /// Parent Type: `PriceRange`
        public struct PriceRange: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.PriceRange }

          /// The lowest price.
          public var low: Low { __data["low"] }
          /// The highest price if not a 'from' range.
          public var high: High? { __data["high"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var priceRangeFragment: PriceRangeFragment { _toFragment() }
          }

          /// ProductListing.Product.PriceRange.Low
          ///
          /// Parent Type: `Money`
          public struct Low: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

            /// The 3-letter currency code e.g. AUD.
            public var currencyCode: String { __data["currencyCode"] }
            /// The amount in minor units (e.g. for $1.23 this will be 123).
            public var amount: Int { __data["amount"] }
            /// The amount formatted according to the client locale (e.g. $1.23).
            public var amountFormatted: String { __data["amountFormatted"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }
          }

          /// ProductListing.Product.PriceRange.High
          ///
          /// Parent Type: `Money`
          public struct High: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

            /// The 3-letter currency code e.g. AUD.
            public var currencyCode: String { __data["currencyCode"] }
            /// The amount in minor units (e.g. for $1.23 this will be 123).
            public var amount: Int { __data["amount"] }
            /// The amount formatted according to the client locale (e.g. $1.23).
            public var amountFormatted: String { __data["amountFormatted"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }
          }
        }

        /// ProductListing.Product.Attribute
        ///
        /// Parent Type: `KeyValuePair`
        public struct Attribute: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }

          /// The key of the pair.
          public var key: String { __data["key"] }
          /// The value of the pair.
          public var value: String { __data["value"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var attributesFragment: AttributesFragment { _toFragment() }
          }
        }

        /// ProductListing.Product.DefaultVariant
        ///
        /// Parent Type: `Variant`
        public struct DefaultVariant: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Variant }

          /// A unique identifier for the variant.
          public var sku: BFFGraphApi.ID { __data["sku"] }
          /// Size, if applicable.
          public var size: Size? { __data["size"] }
          /// Colour, if applicable.
          public var colour: VariantFragment.Colour? { __data["colour"] }
          /// Attributes that are specific for this variant.
          public var attributes: [Attribute]? { __data["attributes"] }
          /// How many of this variant in stock?
          public var stock: Int { __data["stock"] }
          /// How much does it cost?
          public var price: Price { __data["price"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var variantFragment: VariantFragment { _toFragment() }
          }

          /// ProductListing.Product.DefaultVariant.Size
          ///
          /// Parent Type: `Size`
          public struct Size: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }

            /// Unique size ID.
            public var id: BFFGraphApi.ID { __data["id"] }
            /// The size value (e.g. XS).
            public var value: String { __data["value"] }
            /// The scale of the size (e.g. US).
            public var scale: String? { __data["scale"] }
            /// A description of the size (e.g. Extra Small).
            public var description: String? { __data["description"] }
            /// The size guide that includes this size.
            public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var sizeFragment: SizeFragment { _toFragment() }
              public var sizeTreeFragment: SizeTreeFragment { _toFragment() }
            }

            /// ProductListing.Product.DefaultVariant.Size.SizeGuide
            ///
            /// Parent Type: `SizeGuide`
            public struct SizeGuide: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

              /// Unique size guide ID.
              public var id: BFFGraphApi.ID { __data["id"] }
              /// The name of the size guide (e.g. Men's shoes size guide).
              public var name: String { __data["name"] }
              /// A description for the size guide.
              public var description: String? { __data["description"] }
              /// The ordered list of sizes that make up this size guide.
              public var sizes: [Size] { __data["sizes"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
                public var sizeGuideTreeFragment: SizeGuideTreeFragment { _toFragment() }
              }

              /// ProductListing.Product.DefaultVariant.Size.SizeGuide.Size
              ///
              /// Parent Type: `Size`
              public struct Size: BFFGraphApi.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }

                /// Unique size ID.
                public var id: BFFGraphApi.ID { __data["id"] }
                /// The size value (e.g. XS).
                public var value: String { __data["value"] }
                /// The scale of the size (e.g. US).
                public var scale: String? { __data["scale"] }
                /// A description of the size (e.g. Extra Small).
                public var description: String? { __data["description"] }
                /// The size guide that includes this size.
                public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var sizeFragment: SizeFragment { _toFragment() }
                }

                /// ProductListing.Product.DefaultVariant.Size.SizeGuide.Size.SizeGuide
                ///
                /// Parent Type: `SizeGuide`
                public struct SizeGuide: BFFGraphApi.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

                  /// Unique size guide ID.
                  public var id: BFFGraphApi.ID { __data["id"] }
                  /// The name of the size guide (e.g. Men's shoes size guide).
                  public var name: String { __data["name"] }
                  /// A description for the size guide.
                  public var description: String? { __data["description"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
                  }
                }
              }
            }
          }

          /// ProductListing.Product.DefaultVariant.Attribute
          ///
          /// Parent Type: `KeyValuePair`
          public struct Attribute: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }

            /// The key of the pair.
            public var key: String { __data["key"] }
            /// The value of the pair.
            public var value: String { __data["value"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var attributesFragment: AttributesFragment { _toFragment() }
            }
          }

          /// ProductListing.Product.DefaultVariant.Price
          ///
          /// Parent Type: `Price`
          public struct Price: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Price }

            /// The current price.
            public var amount: Amount { __data["amount"] }
            /// If discounted, the previous price.
            public var was: Was? { __data["was"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var priceFragment: PriceFragment { _toFragment() }
            }

            /// ProductListing.Product.DefaultVariant.Price.Amount
            ///
            /// Parent Type: `Money`
            public struct Amount: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

              /// The 3-letter currency code e.g. AUD.
              public var currencyCode: String { __data["currencyCode"] }
              /// The amount in minor units (e.g. for $1.23 this will be 123).
              public var amount: Int { __data["amount"] }
              /// The amount formatted according to the client locale (e.g. $1.23).
              public var amountFormatted: String { __data["amountFormatted"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var moneyFragment: MoneyFragment { _toFragment() }
              }
            }

            /// ProductListing.Product.DefaultVariant.Price.Was
            ///
            /// Parent Type: `Money`
            public struct Was: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

              /// The 3-letter currency code e.g. AUD.
              public var currencyCode: String { __data["currencyCode"] }
              /// The amount in minor units (e.g. for $1.23 this will be 123).
              public var amount: Int { __data["amount"] }
              /// The amount formatted according to the client locale (e.g. $1.23).
              public var amountFormatted: String { __data["amountFormatted"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var moneyFragment: MoneyFragment { _toFragment() }
              }
            }
          }
        }

        /// ProductListing.Product.Variant
        ///
        /// Parent Type: `Variant`
        public struct Variant: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Variant }

          /// A unique identifier for the variant.
          public var sku: BFFGraphApi.ID { __data["sku"] }
          /// Size, if applicable.
          public var size: Size? { __data["size"] }
          /// Colour, if applicable.
          public var colour: VariantFragment.Colour? { __data["colour"] }
          /// Attributes that are specific for this variant.
          public var attributes: [Attribute]? { __data["attributes"] }
          /// How many of this variant in stock?
          public var stock: Int { __data["stock"] }
          /// How much does it cost?
          public var price: Price { __data["price"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var variantFragment: VariantFragment { _toFragment() }
          }

          /// ProductListing.Product.Variant.Size
          ///
          /// Parent Type: `Size`
          public struct Size: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }

            /// Unique size ID.
            public var id: BFFGraphApi.ID { __data["id"] }
            /// The size value (e.g. XS).
            public var value: String { __data["value"] }
            /// The scale of the size (e.g. US).
            public var scale: String? { __data["scale"] }
            /// A description of the size (e.g. Extra Small).
            public var description: String? { __data["description"] }
            /// The size guide that includes this size.
            public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var sizeFragment: SizeFragment { _toFragment() }
              public var sizeTreeFragment: SizeTreeFragment { _toFragment() }
            }

            /// ProductListing.Product.Variant.Size.SizeGuide
            ///
            /// Parent Type: `SizeGuide`
            public struct SizeGuide: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

              /// Unique size guide ID.
              public var id: BFFGraphApi.ID { __data["id"] }
              /// The name of the size guide (e.g. Men's shoes size guide).
              public var name: String { __data["name"] }
              /// A description for the size guide.
              public var description: String? { __data["description"] }
              /// The ordered list of sizes that make up this size guide.
              public var sizes: [Size] { __data["sizes"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
                public var sizeGuideTreeFragment: SizeGuideTreeFragment { _toFragment() }
              }

              /// ProductListing.Product.Variant.Size.SizeGuide.Size
              ///
              /// Parent Type: `Size`
              public struct Size: BFFGraphApi.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Size }

                /// Unique size ID.
                public var id: BFFGraphApi.ID { __data["id"] }
                /// The size value (e.g. XS).
                public var value: String { __data["value"] }
                /// The scale of the size (e.g. US).
                public var scale: String? { __data["scale"] }
                /// A description of the size (e.g. Extra Small).
                public var description: String? { __data["description"] }
                /// The size guide that includes this size.
                public var sizeGuide: SizeGuide? { __data["sizeGuide"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var sizeFragment: SizeFragment { _toFragment() }
                }

                /// ProductListing.Product.Variant.Size.SizeGuide.Size.SizeGuide
                ///
                /// Parent Type: `SizeGuide`
                public struct SizeGuide: BFFGraphApi.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }

                  /// Unique size guide ID.
                  public var id: BFFGraphApi.ID { __data["id"] }
                  /// The name of the size guide (e.g. Men's shoes size guide).
                  public var name: String { __data["name"] }
                  /// A description for the size guide.
                  public var description: String? { __data["description"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public var sizeGuideFragment: SizeGuideFragment { _toFragment() }
                  }
                }
              }
            }
          }

          /// ProductListing.Product.Variant.Attribute
          ///
          /// Parent Type: `KeyValuePair`
          public struct Attribute: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }

            /// The key of the pair.
            public var key: String { __data["key"] }
            /// The value of the pair.
            public var value: String { __data["value"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var attributesFragment: AttributesFragment { _toFragment() }
            }
          }

          /// ProductListing.Product.Variant.Price
          ///
          /// Parent Type: `Price`
          public struct Price: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Price }

            /// The current price.
            public var amount: Amount { __data["amount"] }
            /// If discounted, the previous price.
            public var was: Was? { __data["was"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var priceFragment: PriceFragment { _toFragment() }
            }

            /// ProductListing.Product.Variant.Price.Amount
            ///
            /// Parent Type: `Money`
            public struct Amount: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

              /// The 3-letter currency code e.g. AUD.
              public var currencyCode: String { __data["currencyCode"] }
              /// The amount in minor units (e.g. for $1.23 this will be 123).
              public var amount: Int { __data["amount"] }
              /// The amount formatted according to the client locale (e.g. $1.23).
              public var amountFormatted: String { __data["amountFormatted"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var moneyFragment: MoneyFragment { _toFragment() }
              }
            }

            /// ProductListing.Product.Variant.Price.Was
            ///
            /// Parent Type: `Money`
            public struct Was: BFFGraphApi.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Money }

              /// The 3-letter currency code e.g. AUD.
              public var currencyCode: String { __data["currencyCode"] }
              /// The amount in minor units (e.g. for $1.23 this will be 123).
              public var amount: Int { __data["amount"] }
              /// The amount formatted according to the client locale (e.g. $1.23).
              public var amountFormatted: String { __data["amountFormatted"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var moneyFragment: MoneyFragment { _toFragment() }
              }
            }
          }
        }

        /// ProductListing.Product.Colour
        ///
        /// Parent Type: `Colour`
        public struct Colour: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Colour }

          /// Unique ID for the colour.
          public var id: BFFGraphApi.ID { __data["id"] }
          /// The name of the colour.
          public var name: String { __data["name"] }
          /// Image resolver for the colour swatch.
          public var swatch: Swatch? { __data["swatch"] }
          /// The product images for the colour
          public var media: [ColourFragment.Medium]? { __data["media"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var colourFragment: ColourFragment { _toFragment() }
          }

          /// ProductListing.Product.Colour.Swatch
          ///
          /// Parent Type: `Image`
          public struct Swatch: BFFGraphApi.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Image }

            /// A description of the contents of the image for accessibility purposes.
            public var alt: String? { __data["alt"] }
            /// The media content type.
            public var mediaContentType: GraphQLEnum<BFFGraphApi.MediaContentType> { __data["mediaContentType"] }
            /// The location of the image as a URL.
            ///
            /// If no transform options are specified, then the original image will be preserved.
            ///
            /// All transformation options are considered "best-effort". Any transformation that the original image type doesn't support will be ignored.
            ///
            /// If you need multiple variations of the same image, then you can use [GraphQL aliases](https://graphql.org/learn/queries/#aliases).
            public var url: BFFGraphApi.URL { __data["url"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var imageFragment: ImageFragment { _toFragment() }
            }
          }
        }
      }
    }
  }
}
