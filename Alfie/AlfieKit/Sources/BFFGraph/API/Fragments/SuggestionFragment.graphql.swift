// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  struct SuggestionFragment: BFFGraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SuggestionFragment on Suggestion { __typename brands { __typename ...SuggestionBrandFragment } keywords { __typename ...SuggestionKeywordFragment } products { __typename ...SuggestionProductFragment } }"#
    }

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

    /// Brand
    ///
    /// Parent Type: `SuggestionBrand`
    public struct Brand: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionBrand }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(SuggestionBrandFragment.self),
      ] }

      /// Opaque brand key, resolved per platform: pass it to `filters.brandNames` to list the brand. Not URL-safe on every platform; URL-encode it for deeplinks.
      public var key: String { __data["key"] }
      public var value: String { __data["value"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var suggestionBrandFragment: SuggestionBrandFragment { _toFragment() }
      }
    }

    /// Keyword
    ///
    /// Parent Type: `SuggestionKeyword`
    public struct Keyword: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionKeyword }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(SuggestionKeywordFragment.self),
      ] }

      public var value: String { __data["value"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var suggestionKeywordFragment: SuggestionKeywordFragment { _toFragment() }
      }
    }

    /// Product
    ///
    /// Parent Type: `SuggestionProduct`
    public struct Product: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.SuggestionProduct }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(SuggestionProductFragment.self),
      ] }

      public var id: BFFGraphAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var brandName: String? { __data["brandName"] }
      public var slug: String { __data["slug"] }
      public var price: Price? { __data["price"] }
      public var images: [Image] { __data["images"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var suggestionProductFragment: SuggestionProductFragment { _toFragment() }
      }

      public typealias Price = SuggestionProductFragment.Price

      public typealias Image = SuggestionProductFragment.Image
    }
  }

}