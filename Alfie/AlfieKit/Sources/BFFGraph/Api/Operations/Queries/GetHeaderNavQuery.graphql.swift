// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  class GetHeaderNavQuery: GraphQLQuery {
    public static let operationName: String = "GetHeaderNav"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetHeaderNav($handle: String!, $fetchMedia: Boolean!, $fetchSubItems: Boolean!) { navigation(handle: $handle) { __typename title type url media @include(if: $fetchMedia) { __typename ... on Image { ...ImageFragment } } items @include(if: $fetchSubItems) { __typename ...NavMenuItemFragment } attributes { __typename ...AttributesFragment } } }"#,
        fragments: [AttributesFragment.self, ImageFragment.self, NavMenuItemFragment.self]
      ))

    public var handle: String
    public var fetchMedia: Bool
    public var fetchSubItems: Bool

    public init(
      handle: String,
      fetchMedia: Bool,
      fetchSubItems: Bool
    ) {
      self.handle = handle
      self.fetchMedia = fetchMedia
      self.fetchSubItems = fetchSubItems
    }

    public var __variables: Variables? { [
      "handle": handle,
      "fetchMedia": fetchMedia,
      "fetchSubItems": fetchSubItems
    ] }

    public struct Data: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("navigation", [Navigation].self, arguments: ["handle": .variable("handle")]),
      ] }

      /// Retrieve a navigation menu by its handle.
      public var navigation: [Navigation] { __data["navigation"] }

      /// Navigation
      ///
      /// Parent Type: `NavMenuItem`
      public struct Navigation: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.NavMenuItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("title", String.self),
          .field("type", GraphQLEnum<BFFGraphApi.NavMenuItemType>.self),
          .field("url", String?.self),
          .field("attributes", [Attribute?]?.self),
          .include(if: "fetchMedia", .field("media", Media?.self)),
          .include(if: "fetchSubItems", .field("items", [Item]?.self)),
        ] }

        /// The menu item's title.
        public var title: String { __data["title"] }
        /// The menu item's type.
        public var type: GraphQLEnum<BFFGraphApi.NavMenuItemType> { __data["type"] }
        /// The menu item's URL.
        public var url: String? { __data["url"] }
        /// The menu item's media.
        public var media: Media? { __data["media"] }
        /// The menu item's child items.
        public var items: [Item]? { __data["items"] }
        /// The menu item's attributes, a dynamic list of key-value pairs.
        public var attributes: [Attribute?]? { __data["attributes"] }

        /// Navigation.Media
        ///
        /// Parent Type: `Media`
        public struct Media: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Unions.Media }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsImage.self),
          ] }

          public var asImage: AsImage? { _asInlineFragment() }

          /// Navigation.Media.AsImage
          ///
          /// Parent Type: `Image`
          public struct AsImage: BFFGraphApi.InlineFragment {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = GetHeaderNavQuery.Data.Navigation.Media
            public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Image }
            public static var __selections: [ApolloAPI.Selection] { [
              .fragment(ImageFragment.self),
            ] }

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

        /// Navigation.Item
        ///
        /// Parent Type: `NavMenuItem`
        public struct Item: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.NavMenuItem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(NavMenuItemFragment.self),
          ] }

          /// The menu item's title.
          public var title: String { __data["title"] }
          /// The menu item's type.
          public var type: GraphQLEnum<BFFGraphApi.NavMenuItemType> { __data["type"] }
          /// The menu item's URL.
          public var url: String? { __data["url"] }
          /// The menu item's media.
          public var media: Media? { __data["media"] }
          /// The menu item's attributes, a dynamic list of key-value pairs.
          public var attributes: [Attribute?]? { __data["attributes"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var navMenuItemFragment: NavMenuItemFragment { _toFragment() }
          }

          public typealias Media = NavMenuItemFragment.Media

          public typealias Attribute = NavMenuItemFragment.Attribute
        }

        /// Navigation.Attribute
        ///
        /// Parent Type: `KeyValuePair`
        public struct Attribute: BFFGraphApi.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.KeyValuePair }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(AttributesFragment.self),
          ] }

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
      }
    }
  }

}