// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class RemoveFromCartMutation: GraphQLMutation {
    public static let operationName: String = "RemoveFromCartMutation"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RemoveFromCartMutation($cartId: String!, $lineId: String!) { removeFromCart(cartId: $cartId, lineId: $lineId) { __typename ...CartFragment } }"#,
        fragments: [CartFragment.self, CartItemFragment.self, MoneyFragment.self]
      ))

    public var cartId: String
    public var lineId: String

    public init(
      cartId: String,
      lineId: String
    ) {
      self.cartId = cartId
      self.lineId = lineId
    }

    public var __variables: Variables? { [
      "cartId": cartId,
      "lineId": lineId
    ] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("removeFromCart", RemoveFromCart.self, arguments: [
          "cartId": .variable("cartId"),
          "lineId": .variable("lineId")
        ]),
      ] }

      public var removeFromCart: RemoveFromCart { __data["removeFromCart"] }

      /// RemoveFromCart
      ///
      /// Parent Type: `Cart`
      public struct RemoveFromCart: BFFGraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Cart }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(CartFragment.self),
        ] }

        public var id: BFFGraphAPI.ID { __data["id"] }
        public var lineItems: [LineItem] { __data["lineItems"] }
        public var totals: Totals { __data["totals"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var cartFragment: CartFragment { _toFragment() }
        }

        public typealias LineItem = CartFragment.LineItem

        public typealias Totals = CartFragment.Totals
      }
    }
  }

}