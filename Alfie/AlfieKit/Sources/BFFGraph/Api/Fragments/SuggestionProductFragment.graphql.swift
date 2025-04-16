// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  struct SuggestionProductFragment: BFFGraphApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SuggestionProductFragment on SuggestionProduct { __typename id name brandName media { __typename ...MediaFragment } price { __typename ...PriceFragment } slug }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.SuggestionProduct }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", BFFGraphApi.ID.self),
      .field("name", String.self),
      .field("brandName", String.self),
      .field("media", [Medium].self),
      .field("price", Price.self),
      .field("slug", String.self),
    ] }

    /// Unique ID for the product.
    public var id: BFFGraphApi.ID { __data["id"] }
    /// The formal name of the product.
    public var name: String { __data["name"] }
    /// The name of the brand for the product.
    public var brandName: String { __data["brandName"] }
    /// Array of images and videos.
    public var media: [Medium] { __data["media"] }
    /// How much does it cost?
    public var price: Price { __data["price"] }
    /// For building a navigation link to the product.
    public var slug: String { __data["slug"] }

    /// Medium
    ///
    /// Parent Type: `Media`
    public struct Medium: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Unions.Media }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MediaFragment.self),
      ] }

      public var asImage: AsImage? { _asInlineFragment() }
      public var asVideo: AsVideo? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var mediaFragment: MediaFragment { _toFragment() }
      }

      /// Medium.AsImage
      ///
      /// Parent Type: `Image`
      public struct AsImage: BFFGraphApi.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SuggestionProductFragment.Medium
        public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Image }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          SuggestionProductFragment.Medium.self,
          MediaFragment.AsImage.self,
          ImageFragment.self
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

          public var mediaFragment: MediaFragment { _toFragment() }
          public var imageFragment: ImageFragment { _toFragment() }
        }
      }

      /// Medium.AsVideo
      ///
      /// Parent Type: `Video`
      public struct AsVideo: BFFGraphApi.InlineFragment, ApolloAPI.CompositeInlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = SuggestionProductFragment.Medium
        public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Video }
        public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          SuggestionProductFragment.Medium.self,
          MediaFragment.AsVideo.self
        ] }

        /// A description of the contents of the video for accessibility purposes.
        public var alt: String? { __data["alt"] }
        /// The media content type.
        public var mediaContentType: GraphQLEnum<BFFGraphApi.MediaContentType> { __data["mediaContentType"] }
        /// The sources for the video.
        public var sources: [Source] { __data["sources"] }
        /// A preview image for the video.
        public var previewImage: PreviewImage? { __data["previewImage"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var mediaFragment: MediaFragment { _toFragment() }
        }

        public typealias Source = MediaFragment.AsVideo.Source

        public typealias PreviewImage = MediaFragment.AsVideo.PreviewImage
      }
    }

    /// Price
    ///
    /// Parent Type: `Price`
    public struct Price: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Price }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(PriceFragment.self),
      ] }

      /// The current price.
      public var amount: Amount { __data["amount"] }
      /// If discounted, the previous price.
      public var was: Was? { __data["was"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var priceFragment: PriceFragment { _toFragment() }
      }

      public typealias Amount = PriceFragment.Amount

      public typealias Was = PriceFragment.Was
    }
  }

}