import Model

public final class MockProductListingStyleProvider: ProductListingStyleProviderProtocol {
    public var style: ProductListingListStyle
    public var onSetCalled: ((ProductListingListStyle) -> Void)?

    public init(style: ProductListingListStyle = .grid) {
        self.style = style
    }

    public func set(_ style: ProductListingListStyle) {
        onSetCalled?(style)
        self.style = style
    }
}
