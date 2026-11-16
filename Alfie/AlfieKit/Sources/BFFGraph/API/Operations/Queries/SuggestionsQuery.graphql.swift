// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class SuggestionsQuery: GraphQLQuery {
    public static let operationName: String = "SuggestionsQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SuggestionsQuery($query: String!, $limit: Int!) { suggestion(query: $query, limit: $limit) { __typename brands { __typename key value } keywords { __typename value } products { __typename id name brandName slug price { __typename ...MoneyFragment } images { __typename ...ImageFragment } } } }"#,
        fragments: [ImageFragment.self, MoneyFragment.self]
      ))

    public var query: String
    public var limit: Int

    public init(
      query: String,
      limit: Int
    ) {
      self.query = query
      self.limit = limit
    }

    public var __variables: Variables? { [
      "query": query,
      "limit": limit
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("suggestion", Suggestion.self, arguments: [
          "query": .variable("query"),
          "limit": .variable("limit")
        ]),
      ] }

      public var suggestion: Suggestion { __data["suggestion"] }

      /// Suggestion
      ///
      /// Parent Type: `Suggestion`
      public struct Suggestion: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Suggestion }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("brands", [Brand].self),
          .field("keywords", [Keyword].self),
          .field("products", [Product].self),
        ] }

        public var brands: [Brand] { __data["brands"] }
        public var keywords: [Keyword] { __data["keywords"] }
        public var products: [Product] { __data["products"] }

        /// Suggestion.Brand
        ///
        /// Parent Type: `SuggestionBrand`
        public struct Brand: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionBrand }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("key", String.self),
            .field("value", String.self),
          ] }

          /// Opaque brand key, resolved per platform: pass it to `filters.brandNames` to list the brand. Not URL-safe on every platform; URL-encode it for deeplinks.
          public var key: String { __data["key"] }
          public var value: String { __data["value"] }
        }

        /// Suggestion.Keyword
        ///
        /// Parent Type: `SuggestionKeyword`
        public struct Keyword: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionKeyword }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("value", String.self),
          ] }

          public var value: String { __data["value"] }
        }

        /// Suggestion.Product
        ///
        /// Parent Type: `SuggestionProduct`
        public struct Product: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionProduct }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BFFGraphAPI.ID.self),
            .field("name", String.self),
            .field("brandName", String?.self),
            .field("slug", String.self),
            .field("price", Price?.self),
            .field("images", [Image].self),
          ] }

          public var id: BFFGraphAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var brandName: String? { __data["brandName"] }
          public var slug: String { __data["slug"] }
          public var price: Price? { __data["price"] }
          public var images: [Image] { __data["images"] }

          /// Suggestion.Product.Price
          ///
          /// Parent Type: `Money`
          public struct Price: BFFGraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Money }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }

            public var amount: Double { __data["amount"] }
            public var currencyCode: String { __data["currencyCode"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }
          }

          /// Suggestion.Product.Image
          ///
          /// Parent Type: `Image`
          public struct Image: BFFGraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Image }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ImageFragment.self),
            ] }

            public var url: String { __data["url"] }
            public var altText: String? { __data["altText"] }

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