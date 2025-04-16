// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  class ProductListingQuery: GraphQLQuery {
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

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Query }
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

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.ProductListing }
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

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Pagination }
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

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Product }
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

          public typealias Brand = ProductFragment.Brand

          public typealias PriceRange = ProductFragment.PriceRange

          public typealias Attribute = ProductFragment.Attribute

          public typealias DefaultVariant = ProductFragment.DefaultVariant

          public typealias Variant = ProductFragment.Variant

          public typealias Colour = ProductFragment.Colour
        }
      }
    }
  }

}