// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class GetProductQuery: GraphQLQuery {
    public static let operationName: String = "GetProduct"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetProduct($productId: ID!) { product(id: $productId) { __typename ...ProductFragment } }"#,
        fragments: [AttributesFragment.self, BrandFragment.self, ColourFragment.self, ImageFragment.self, MediaFragment.self, MoneyFragment.self, PriceFragment.self, PriceRangeFragment.self, ProductFragment.self, SizeFragment.self, SizeGuideFragment.self, SizeGuideTreeFragment.self, SizeTreeFragment.self, VariantFragment.self]
      ))

    public var productId: ID

    public init(productId: ID) {
      self.productId = productId
    }

    public var __variables: Variables? { ["productId": productId] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("product", Product?.self, arguments: ["id": .variable("productId")]),
      ] }

      /// Retrieve a product by its ID.
      public var product: Product? { __data["product"] }

      /// Product
      ///
      /// Parent Type: `Product`
      public struct Product: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Product }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProductFragment.self),
        ] }

        /// Unique ID for the product and its variants.
        public var id: BFFGraphAPI.ID { __data["id"] }
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