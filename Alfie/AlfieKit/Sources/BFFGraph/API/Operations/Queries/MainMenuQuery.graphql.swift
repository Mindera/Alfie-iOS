// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class MainMenuQuery: GraphQLQuery {
    public static let operationName: String = "MainMenuQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MainMenuQuery($handle: String!, $platform: String) { mainMenu(handle: $handle, platform: $platform) { __typename handle title items { __typename id title url items { __typename id title url items { __typename id title url } } } } }"#
      ))

    public var handle: String
    public var platform: GraphQLNullable<String>

    public init(
      handle: String,
      platform: GraphQLNullable<String>
    ) {
      self.handle = handle
      self.platform = platform
    }

    public var __variables: Variables? { [
      "handle": handle,
      "platform": platform
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("mainMenu", MainMenu.self, arguments: [
          "handle": .variable("handle"),
          "platform": .variable("platform")
        ]),
      ] }

      public var mainMenu: MainMenu { __data["mainMenu"] }

      /// MainMenu
      ///
      /// Parent Type: `Menu`
      public struct MainMenu: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Menu }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("handle", String?.self),
          .field("title", String?.self),
          .field("items", [Item].self),
        ] }

        public var handle: String? { __data["handle"] }
        public var title: String? { __data["title"] }
        public var items: [Item] { __data["items"] }

        /// MainMenu.Item
        ///
        /// Parent Type: `MenuItem`
        public struct Item: BFFGraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.MenuItem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", BFFGraphAPI.ID.self),
            .field("title", String.self),
            .field("url", String?.self),
            .field("items", [Item?]?.self),
          ] }

          public var id: BFFGraphAPI.ID { __data["id"] }
          public var title: String { __data["title"] }
          public var url: String? { __data["url"] }
          public var items: [Item?]? { __data["items"] }

          /// MainMenu.Item.Item
          ///
          /// Parent Type: `MenuItem`
          public struct Item: BFFGraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.MenuItem }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", BFFGraphAPI.ID.self),
              .field("title", String.self),
              .field("url", String?.self),
              .field("items", [Item?]?.self),
            ] }

            public var id: BFFGraphAPI.ID { __data["id"] }
            public var title: String { __data["title"] }
            public var url: String? { __data["url"] }
            public var items: [Item?]? { __data["items"] }

            /// MainMenu.Item.Item.Item
            ///
            /// Parent Type: `MenuItem`
            public struct Item: BFFGraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.MenuItem }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", BFFGraphAPI.ID.self),
                .field("title", String.self),
                .field("url", String?.self),
              ] }

              public var id: BFFGraphAPI.ID { __data["id"] }
              public var title: String { __data["title"] }
              public var url: String? { __data["url"] }
            }
          }
        }
      }
    }
  }

}