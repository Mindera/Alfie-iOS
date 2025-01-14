// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSuggestionsQuery: GraphQLQuery {
  public static let operationName: String = "GetSuggestions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSuggestions($term: String!) { suggestion(query: $term) { __typename brands { __typename ...SuggestionBrandFragment } keywords { __typename ...SuggestionKeywordFragment } products { __typename ...SuggestionProductFragment } } }"#,
      fragments: [ImageFragment.self, MediaFragment.self, MoneyFragment.self, PriceFragment.self, SuggestionBrandFragment.self, SuggestionKeywordFragment.self, SuggestionProductFragment.self]
    ))

  public var term: String

  public init(term: String) {
    self.term = term
  }

  public var __variables: Variables? { ["term": term] }

  public struct Data: BFFGraphApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("suggestion", Suggestion.self, arguments: ["query": .variable("term")]),
    ] }

    /// Retrieve search suggestion data by custom query
    public var suggestion: Suggestion { __data["suggestion"] }

    /// Suggestion
    ///
    /// Parent Type: `Suggestion`
    public struct Suggestion: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.Suggestion }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("brands", [Brand].self),
        .field("keywords", [Keyword].self),
        .field("products", [Product].self),
      ] }

      /// An array of suggested brands.
      public var brands: [Brand] { __data["brands"] }
      /// An array of potential search terms.
      public var keywords: [Keyword] { __data["keywords"] }
      /// An array of suggested products.
      public var products: [Product] { __data["products"] }

      /// Suggestion.Brand
      ///
      /// Parent Type: `SuggestionBrand`
      public struct Brand: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SuggestionBrand }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(SuggestionBrandFragment.self),
        ] }

        /// Name of the brand.
        public var value: String { __data["value"] }
        /// Number of products matching the brand.
        public var results: Int { __data["results"] }
        /// Slugified name of the brand.
        public var slug: String { __data["slug"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var suggestionBrandFragment: SuggestionBrandFragment { _toFragment() }
        }
      }

      /// Suggestion.Keyword
      ///
      /// Parent Type: `SuggestionKeyword`
      public struct Keyword: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SuggestionKeyword }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(SuggestionKeywordFragment.self),
        ] }

        /// Value of the suggested search term.
        public var value: String { __data["value"] }
        /// Number of results that match the suggested search term.
        public var results: Int { __data["results"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var suggestionKeywordFragment: SuggestionKeywordFragment { _toFragment() }
        }
      }

      /// Suggestion.Product
      ///
      /// Parent Type: `SuggestionProduct`
      public struct Product: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { BFFGraphApi.Objects.SuggestionProduct }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(SuggestionProductFragment.self),
        ] }

        /// Unique ID for the product.
        public var id: BFFGraphApi.ID { __data["id"] }
        /// The formal name of the product.
        public var name: String { __data["name"] }
        /// The name of the brand for the product.
        public var brandName: String { __data["brandName"] }
        /// Array of images and videos.
        public var media: [SuggestionProductFragment.Medium] { __data["media"] }
        /// How much does it cost?
        public var price: Price { __data["price"] }
        /// For building a navigation link to the product.
        public var slug: String { __data["slug"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var suggestionProductFragment: SuggestionProductFragment { _toFragment() }
        }

        /// Suggestion.Product.Price
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

          /// Suggestion.Product.Price.Amount
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

          /// Suggestion.Product.Price.Was
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
    }
  }
}
