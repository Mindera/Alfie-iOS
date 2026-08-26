// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension BFFGraphAPI {
  class CartQuery: GraphQLQuery {
    public static let operationName: String = "CartQuery"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CartQuery($cartId: String!) { cart(cartId: $cartId) { __typename ...CartFragment } }"#,
        fragments: [CartFragment.self, CartItemFragment.self, MoneyFragment.self]
      ))

    public var cartId: String

    public init(cartId: String) {
      self.cartId = cartId
    }

    public var __variables: Variables? { ["cartId": cartId] }

    public struct Data: BFFGraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { BFFGraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("cart", Cart.self, arguments: ["cartId": .variable("cartId")]),
      ] }

      public var cart: Cart { __data["cart"] }

      /// Cart
      ///
      /// Parent Type: `Cart`
      public struct Cart: BFFGraphAPI.SelectionSet {
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