import Model

extension ProductDetailsViewModel {
    public func shouldShowLoading(for section: ProductDetailsSection) -> Bool {
        switch section {
        case .titleHeader:
            return state.isLoading && productName.isEmpty

        case .colorSelector, .sizeSelector, .mediaCarousel, .complementaryInfo:
            return state.isLoading

        case .productDescription, .addToBag, .addToWishlist, .availabilityNote:
            return false

        case .relatedProducts:
            return state.isSuccess && relatedProductsState.isLoading
        }
    }

    public func shouldShow(section: ProductDetailsSection) -> Bool {
        switch section {
        case .titleHeader, .colorSelector, .sizeSelector:
            return true

        case .complementaryInfo:
            return !complementaryInfoToShow.isEmpty

        case .mediaCarousel:
            return state.isLoading || !productImageUrls.isEmpty

        case .productDescription:
            return !productDescription.isEmpty

        // The note qualifies what the selectors' availability means, so it only belongs on screen
        // once there is real availability to qualify: while loading the swatches are shimmer
        // placeholders, and a failure draws no selectors at all. Same gate as the CTA.
        case .addToBag, .availabilityNote:
            return state.isSuccess

        case .addToWishlist:
            return state.isSuccess && isWishlistEnabled

        case .relatedProducts:
            return state.isSuccess && (relatedProductsState.isLoading || relatedProductsState.value?.isEmpty == false)
        }
    }

    public func complementaryInfoWebFeature(for type: ProductDetailsComplementaryInfoType) -> WebFeature? {
        switch type {
        case .delivery:
            return nil

        case .paymentOptions:
            return .paymentOptions

        case .returns:
            return .returnOptions
        }
    }
}
