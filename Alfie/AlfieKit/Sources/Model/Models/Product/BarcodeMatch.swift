import Foundation

public struct BarcodeMatch: Equatable {
    /// The Handle, not the id: `productDetails(handle:)` is what the PDP deep link resolves against,
    /// and on SCAYLE a Handle carries the Product name as well as the numeric id.
    public let handle: String
    public let variantId: String?

    public init(handle: String, variantId: String?) {
        self.handle = handle
        self.variantId = variantId
    }
}
