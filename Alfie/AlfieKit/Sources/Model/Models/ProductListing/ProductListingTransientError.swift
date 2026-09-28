import Foundation

public struct ProductListingTransientError: Equatable {
    public let request: ProductListingPageRequest
    public let error: ProductListingViewErrorType

    public init(request: ProductListingPageRequest, error: ProductListingViewErrorType) {
        self.request = request
        self.error = error
    }
}
