// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphApi {
  struct SizeGuideTreeFragment: BFFGraphApi.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment SizeGuideTreeFragment on SizeGuide { __typename ...SizeGuideFragment sizes { __typename ...SizeFragment sizeGuide { __typename ...SizeGuideFragment } } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("sizes", [Size].self),
      .fragment(SizeGuideFragment.self),
    ] }

    /// The ordered list of sizes that make up this size guide.
    public var sizes: [Size] { __data["sizes"] }
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

    /// Size
    ///
    /// Parent Type: `Size`
    public struct Size: BFFGraphApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.Size }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("sizeGuide", SizeGuide?.self),
        .fragment(SizeFragment.self),
      ] }

      /// The size guide that includes this size.
      public var sizeGuide: SizeGuide? { __data["sizeGuide"] }
      /// Unique size ID.
      public var id: BFFGraphApi.ID { __data["id"] }
      /// The size value (e.g. XS).
      public var value: String { __data["value"] }
      /// The scale of the size (e.g. US).
      public var scale: String? { __data["scale"] }
      /// A description of the size (e.g. Extra Small).
      public var description: String? { __data["description"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var sizeFragment: SizeFragment { _toFragment() }
      }

      /// Size.SizeGuide
      ///
      /// Parent Type: `SizeGuide`
      public struct SizeGuide: BFFGraphApi.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphApi.Objects.SizeGuide }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(SizeGuideFragment.self),
        ] }

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