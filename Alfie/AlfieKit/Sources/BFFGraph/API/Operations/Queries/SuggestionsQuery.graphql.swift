// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class SuggestionsQuery: GraphQLQuery {
    public static let operationName: String = "SuggestionsQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SuggestionsQuery($searchTerm: String!, $limit: Int!) { suggestion(query: $searchTerm, limit: $limit) { __typename ...SuggestionFragment } }"#,
        fragments: [ImageFragment.self, MoneyFragment.self, SuggestionFragment.self, SuggestionProductFragment.self]
      ))

    public var searchTerm: String
    public var limit: Int

    public init(
      searchTerm: String,
      limit: Int
    ) {
      self.searchTerm = searchTerm
      self.limit = limit
    }

    public var __variables: Variables? { [
      "searchTerm": searchTerm,
      "limit": limit
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("suggestion", Suggestion.self, arguments: [
          "query": .variable("searchTerm"),
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
          .fragment(SuggestionFragment.self),
        ] }

        public var brands: [Brand] { __data["brands"] }
        public var keywords: [Keyword] { __data["keywords"] }
        public var products: [Product] { __data["products"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var suggestionFragment: SuggestionFragment { _toFragment() }
        }

        public typealias Brand = SuggestionFragment.Brand

        public typealias Keyword = SuggestionFragment.Keyword

        public typealias Product = SuggestionFragment.Product
      }
    }
  }

}