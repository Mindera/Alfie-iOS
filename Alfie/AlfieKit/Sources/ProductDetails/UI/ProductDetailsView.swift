import AccessibilityIdentifiers
import Combine
import Core
#if DEBUG
import Mocks
#endif
import Model
import SharedUI
import SwiftUI
import Utils

public struct ProductDetailsView<ViewModel: ProductDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @State private var currentMediaIndex = 0
    @State private var isMediaFullScreen = false
    @State private var showFailureState: Bool
    @State private var addToBagSnackbarConfig: SnackbarViewConfiguration?

    private var colourLayout: ProductDetailsLayoutRules.ColourLayout {
        ProductDetailsLayoutRules.colourLayout(forColourCount: viewModel.variantSelection.colours.count)
    }

    // showFailureState is driven by the view model; the flag lets the error-state snapshot render it.
    public init(viewModel: ViewModel, showFailureState: Bool = false) {
        _showFailureState = State(initialValue: showFailureState)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        Group {
            if showFailureState {
                errorView
                    .padding(.horizontal, horizontalPadding)
            } else {
                pdpView
            }
        }
        // Figma titles the header with the product name; the brand stays in the info block, which
        // otherwise repeated it in both places and never named the product in the header.
        .toolbarView(
            productTitle: viewModel.productName,
            shareConfiguration: viewModel.shareConfiguration,
            didFail: viewModel.state.didFail
        )
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onChange(of: viewModel.productImageUrls) { _ in
            currentMediaIndex = 0
        }
        .onChange(of: viewModel.state.didFail) { newValue in
            showFailureState = newValue
        }
        .snackbarView(configuration: $addToBagSnackbarConfig)
        // The add-to-bag outcome is transient and never leaves the product page. Dismissing the
        // Snackbar clears the outcome so an identical later one re-presents cleanly.
        .onChange(of: viewModel.addToBagFeedback) { feedback in
            guard let feedback else {
                addToBagSnackbarConfig = nil
                return
            }
            let snackbar = feedback.snackbar
            addToBagSnackbarConfig = .init(
                type: snackbar.type,
                text: snackbar.text,
                showCloseButton: true,
                icon: snackbar.icon,
                // From the top: the PDP pins the add-to-bag CTA to the bottom, and the default
                // bottom placement lands the Snackbar squarely on top of it — covering both the
                // button and the price. `ProductListingView` can use the default; it has no
                // sticky bottom bar.
                showFromTop: true,
                onDismiss: viewModel.didDismissAddToBagFeedback
            )
        }
    }

    private var pdpView: some View {
        ScrollView {
            VStack(spacing: theme.sizing.spacingSpacingNone) {
                // The gallery is full-bleed, so the gutter belongs to the content below it.
                mediaCarousel
                complementaryViews
                    .padding(.horizontal, horizontalPadding)
                    // Same bound as the gallery, so the two stay in one column on a wide screen.
                    .frame(maxWidth: Constants.maxContentWidth)
                    .frame(maxWidth: .infinity)
                    // Opaque, so nothing from the gallery can render through the product info.
                    // No rule between the two — the design runs the panel straight off the image.
                    .background(theme.color.surfaceBackgroundPrimary)
            }
        }
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $isMediaFullScreen) {
            fullscreenMediaCarousel
        }
    }

    /// The design draws the selected indicator as a wider pill, so the dots come from
    /// `ThemedPageControl`'s custom-control path rather than its default circles.
    @ViewBuilder private var paginatedControl: some View {
        if viewModel.shouldShowMediaPaginatedControl {
            let configuration = ThemedPageControlConfiguration(
                color: theme.color.borderMedium,
                // White, not primary: the indicators overlay the image rather than sit below it.
                selectedColor: theme.color.contentContentInvertedPrimary,
                size: Constants.indicatorSize,
                spacing: theme.sizing.spacingSpacingXs,
                padding: theme.sizing.spacingSpacingNone
            )
            ThemedPageControl(
                data: viewModel.productImageUrls,
                selectedIndex: $currentMediaIndex,
                configuration: configuration
            ) { _, isSelected in
                RoundedRectangle(cornerRadius: theme.sizing.radiusRounded)
                    .fill(isSelected ? configuration.selectedColor : configuration.color)
                    .frame(
                        width: isSelected ? Constants.selectedIndicatorWidth : Constants.indicatorSize,
                        height: Constants.indicatorSize
                    )
                    .animation(.linear(duration: configuration.animationDuration), value: isSelected)
            }
            // Decorative: the carousel carries the accessible paging affordance, not the dots.
            .accessibilityHidden(true)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Helpers

    private func shimmeringBinding(for section: ProductDetailsSection) -> Binding<Bool> {
        .init(get: { viewModel.shouldShowLoading(for: section) }, set: { _ in })
    }

    private func stepMediaIndex(by offset: Int) {
        let imageCount = viewModel.productImageUrls.count
        guard imageCount > 1 else { return }
        currentMediaIndex = (currentMediaIndex + offset + imageCount) % imageCount
    }

    private var horizontalPadding: CGFloat {
        isIpad ? theme.sizing.spacingSpacing2xl : theme.sizing.spacingSpacingMd
    }

    /// The gallery when there is imagery, otherwise one empty slot while the product loads. An empty
    /// set reserves a square rather than showing nothing, so the information block does not jump the
    /// moment the images arrive. It cannot reserve with a url-less `RemoteImage`: that resolves to
    /// the failure branch, which paints the inverted surface — a black block, not a neutral
    /// placeholder.
    @ViewBuilder private var galleryPages: some View {
        let urls = viewModel.productImageUrls
        if urls.isEmpty {
            theme.color.surfaceForegroundPrimary
                .aspectRatio(1, contentMode: .fit)
                .tag(0)
        } else {
            // Keyed by index, not url: the index is also the `.tag` the `TabView` selects by, and a
            // variant may list the same image twice — which as an identity would be a duplicate.
            ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                RemoteImage(
                    url: url,
                    success: { image in
                        image
                            .resizable()
                            // Fit at the full width: height follows the image's intrinsic ratio,
                            // and nothing is cropped or stretched.
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture { isMediaFullScreen = true }
                    },
                    // Neither has an intrinsic size, so both hold a square while the image resolves.
                    // A loading reservation, not a design ratio.
                    placeholder: {
                        theme.color.surfaceForegroundPrimary.aspectRatio(1, contentMode: .fit)
                    },
                    failure: { _ in
                        theme.color.surfaceBackgroundInvertedPrimary.aspectRatio(1, contentMode: .fit)
                    }
                )
                .tag(index)
            }
        }
    }

    private func complementaryInfoTitle(for type: ProductDetailsComplementaryInfoType) -> String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .delivery:
            return L10n.Pdp.ComplementaryInfo.Delivery.title
        case .paymentOptions:
            return L10n.Pdp.ComplementaryInfo.Payment.title
        case .returns:
            return L10n.Pdp.ComplementaryInfo.Returns.title
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var errorMessage: String {
        viewModel.state.failure?.message ?? ""
    }

    private var errorTitle: String {
        viewModel.state.failure?.title ?? L10n.Pdp.ErrorView.title
    }
}

// MARK: - Sections
extension ProductDetailsView {
    /// contains every view except the media carousel
    private var complementaryViews: some View {
        VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
            productInfo

            // Figma: one row — Add to Bag fills, the wishlist is a 40pt square beside it.
            HStack(spacing: theme.sizing.spacingSpacingXs) {
                addToBag
                addToWishlist
            }
            .padding(.vertical, theme.sizing.spacingSpacingXs)

            colorSelector

            sizeSelector

            availabilityNote

            descriptionSection
                .padding(.vertical, theme.sizing.spacingSpacingMd)

            complementaryInfo

            relatedProducts
        }
    }

    /// Full-bleed: the images fill the screen width, so there is no item spacing and no corner
    /// radius. The gutter belongs to the content below.
    ///
    /// The height is the design's 3:4 gallery ratio (Figma: the Image component's default variant),
    /// not the imagery's. Images keep `.fit` inside the box, so nothing is cropped; anything other
    /// than 3:4 letterboxes. A paged `TabView` does not take its height from its pages, so the ratio
    /// is imposed here and the pager fills what it is given.
    var mediaCarousel: some View {
        GeometryReader { proxy in
            TabView(selection: $currentMediaIndex) {
                galleryPages
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(Constants.galleryAspectRatio, contentMode: .fit)
        .shimmering(while: shimmeringBinding(for: .mediaCarousel))
        .frame(maxWidth: Constants.maxContentWidth)
        .frame(maxWidth: .infinity)
        .disabled(isMediaFullScreen)
        .overlay(alignment: .bottom) {
            paginatedControl
                .padding(.bottom, theme.sizing.spacingSpacingSm)
        }
        .padding(.bottom, theme.sizing.spacingSpacingMd)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Pdp.Gallery.accessibilityLabel)
        .accessibilityValue(
            L10n.Pdp.Gallery.accessibilityValue(currentMediaIndex + 1, viewModel.productImageUrls.count)
        )
        .accessibilityHint(L10n.Pdp.Gallery.accessibilityHint)
        // The reserved slot is a placeholder, not an image — announcing "image 1 of 0" would be
        // worse than announcing nothing.
        .accessibilityHidden(viewModel.productImageUrls.isEmpty)
        // The image's tap gesture is not reachable once the carousel is a single element.
        .accessibilityAction { isMediaFullScreen = true }
        // The carousel pages by drag, which assistive technologies cannot perform. The adjustable
        // action serves VoiceOver; the named actions serve Voice Control, Switch Control and Full
        // Keyboard Access, which the replaced chevron control used to cover with real buttons.
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                stepMediaIndex(by: 1)

            case .decrement:
                stepMediaIndex(by: -1)

            @unknown default:
                break
            }
        }
        .accessibilityAction(named: Text(L10n.Accessibility.nextPage)) { stepMediaIndex(by: 1) }
        .accessibilityAction(named: Text(L10n.Accessibility.previousPage)) { stepMediaIndex(by: -1) }
        .accessibilityIdentifier(AccessibilityID.ProductDetails.productImage)
    }

    private var fullscreenMediaCarousel: some View {
        ZoomableCarousel(currentIndex: $currentMediaIndex, configuration: .init(isPresented: $isMediaFullScreen)) {
            viewModel.productImageUrls.map { url in
                RemoteImage(
                    url: url,
                    success: { image in
                        image
                            .resizable()
                            .scaledToFit()
                    },
                    placeholder: { theme.color.surfaceForegroundPrimary },
                    failure: { _ in theme.color.surfaceBackgroundInvertedPrimary }
                )
            }
        }
    }

    /// Brand, product name and price, with the colour summary pinned to the trailing edge.
    private var productInfo: some View {
        HStack(alignment: .top, spacing: theme.sizing.spacingSpacingXs) {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
                brandName

                titleHeader

                price
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            colorSummary
        }
    }

    @ViewBuilder private var brandName: some View {
        // Fixtures and the no-variant fallback can produce an empty brand; omit the line rather than
        // leaving blank space above the product name.
        if viewModel.shouldShow(section: .titleHeader), !viewModel.productTitle.isEmpty {
            Text.build(theme.font.label.small(viewModel.productTitle))
                .foregroundStyle(theme.color.contentContentSecondary)
                .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.brandName)
        }
    }

    @ViewBuilder private var titleHeader: some View {
        if viewModel.shouldShow(section: .titleHeader) {
            HStack(spacing: theme.sizing.spacingSpacingNone) {
                Text.build(theme.font.body.medium(viewModel.productName))
                    .foregroundStyle(theme.color.contentContentPrimary)
                    .frame(maxWidth: .infinity, minHeight: Constants.minTitleHeight, alignment: .leading)
                    .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.productName)
            }
        }
    }

    @ViewBuilder private var colorSummary: some View {
        let selection = viewModel.variantSelection
        let remainingCount = ProductDetailsLayoutRules.colourSummaryRemainingCount(
            forColourCount: selection.colours.count,
            hasSelection: selection.selectedColour != nil
        )
        if viewModel.shouldShow(section: .colorSelector), let colour = selection.selectedColour, let remainingCount {
            ColorSummaryView(selectedItem: colour, remainingCount: remainingCount)
                .shimmering(while: shimmeringBinding(for: .colorSelector), animateOnStateTransition: false)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.colourSummary)
        }
    }

    @ViewBuilder private var price: some View {
        if let priceType = viewModel.priceType {
            PriceComponentView(
                type: priceType,
                // `.large` is the 16pt that `body/medium-bold` defines; `.small` would override the
                // token down to 14pt.
                configuration: .init(preferredDistribution: .horizontal, size: .large, textAlignment: .leading)
            )
        }
    }

    @ViewBuilder private var colorSelector: some View {
        if viewModel.shouldShow(section: .colorSelector) {
            // Loading needs its own branch: the colours arrive with the product, so until they do an
            // empty item list would read as a single-colour product and the section would occupy no
            // space at all, then shove the page down when it appears.
            if viewModel.shouldShowLoading(for: .colorSelector) {
                colourSelectorTitle
                    .shimmering(while: shimmeringBinding(for: .colorSelector), animateOnStateTransition: false)
            } else {
                switch colourLayout {
                case .inlineGrid:
                    VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingSm) {
                        colourSelectorTitle

                        ColorCardGridView(
                            configuration: .init(
                                items: viewModel.variantSelection.colours,
                                selectedItem: viewModel.variantSelection.selectedColour,
                                onSelect: viewModel.didSelectColour
                            ),
                            columns: Constants.colourGridColumns
                        )
                    }
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.colourSelector)

                case .summaryOnly:
                    EmptyView()
                }
            }
        }
    }

    private var colourSelectorTitle: some View {
        Text.build(theme.font.heading.xSmall(L10n.Pdp.ColourSelector.title))
            .foregroundStyle(theme.color.contentContentPrimary)
    }

    @ViewBuilder private var sizeSelector: some View {
        if viewModel.shouldShow(section: .sizeSelector) {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingSm) {
                switch viewModel.variantSelection.sizeDisplay {
                case .selector:
                    sizeSelectorHeader

                    SizingSelectorComponentView(
                        configuration: .init(
                            items: viewModel.variantSelection.sizes,
                            selectedItem: viewModel.variantSelection.selectedSize,
                            onSelect: viewModel.didSelectSize
                        ),
                        arrangement: .grid(columns: Constants.sizeGridColumns)
                    )

                case .single(let name):
                    selectedSizeLabel(name)

                case .oneSize:
                    selectedSizeLabel(L10n.Product.OneSize.title)
                }
            }
            .shimmering(while: shimmeringBinding(for: .sizeSelector), animateOnStateTransition: false)
            .accessibilityIdentifier(AccessibilityID.ProductDetails.sizeSelector)
        }
    }

    private var sizeSelectorHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.sizing.spacingSpacingXs) {
            Text.build(theme.font.heading.xSmall(L10n.Pdp.SizeSelector.title))
                .foregroundStyle(theme.color.contentContentPrimary)

            Spacer()

            // The design draws the link with no destination behind it; slice 5 makes it live. Until
            // then it renders as designed but offers no tap target and no accessibility action.
            Text.build(theme.font.link.medium(L10n.Pdp.SizeGuide.link, underline: true))
                .foregroundStyle(theme.color.linkLinkPrimaryDefault)
                .allowsHitTesting(false)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.sizeGuideLink)
        }
    }

    /// The availability the colour and size selectors show is an **online** aggregate: the BFF exposes
    /// `Inventory { available: Int }` with no location dimension, and neither commerce adapter queries
    /// location-scoped inventory. Without this line a shopper standing in a store reads a crossed-out
    /// size chip as "not in this shop" — which is not what it means, and not something the stack can say.
    ///
    /// This is the visible half. The spoken half rides on the swatches' own out-of-stock
    /// `accessibilityValue` — "Out of stock online" — rather than an `accessibilityHint` here: Speak
    /// Hints is user-toggleable, and Braille and Switch Control never surface hints at all, so a hint
    /// is the first thing dropped. A value is always announced, and it lands on the one element whose
    /// availability actually needs qualifying.
    @ViewBuilder private var availabilityNote: some View {
        if viewModel.shouldShow(section: .availabilityNote) {
            Text.build(theme.font.label.small(L10n.Pdp.Availability.onlineNote))
                .foregroundStyle(theme.color.contentContentTerciary)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.availabilityNote)
        }
    }

    private func selectedSizeLabel(_ size: String) -> some View {
        Text.build(theme.font.body.medium(L10n.Product.Size.selected(size)))
            .foregroundStyle(theme.color.contentContentPrimary)
    }

    @ViewBuilder private var complementaryInfo: some View {
        if viewModel.shouldShow(section: .complementaryInfo) {
            VStack(spacing: theme.sizing.spacingSpacingNone) {
                ForEach(Array(viewModel.complementaryInfoToShow.enumerated()), id: \.0) { index, type in
                    complementaryInfoCell(type: type, showTopDivider: index == 0)
                }
            }
        }
    }

    @ViewBuilder private var relatedProducts: some View {
        if viewModel.shouldShow(section: .relatedProducts) {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
                Text.build(theme.font.body.mediumBold(L10n.Pdp.RelatedProducts.title))
                    .foregroundStyle(theme.color.contentContentPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.relatedProductsTitleLabel)

                LazyVGrid(
                    columns: relatedProductsColumns,
                    alignment: .leading,
                    spacing: theme.sizing.spacingSpacingMd
                ) {
                    if viewModel.shouldShowLoading(for: .relatedProducts) {
                        ForEach(Product.skeletons(count: Constants.relatedProductsSkeletonCount)) { product in
                            relatedProductCard(product, isSkeleton: true)
                        }
                    } else {
                        ForEach(viewModel.relatedProducts) { product in
                            relatedProductCard(product, isSkeleton: false)
                                .accessibilityIdentifier(AccessibilityID.ProductDetails.relatedProductCard(id: product.id))
                        }
                    }
                }
            }
            .padding(
                .top,
                viewModel.shouldShow(section: .complementaryInfo)
                    ? theme.sizing.spacingSpacingMd
                    : theme.sizing.spacingSpacingNone
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityID.ProductDetails.relatedProductsSection)
        }
    }

    private var relatedProductsColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: theme.sizing.spacingSpacingXs, alignment: .top),
            count: Constants.relatedProductsColumns
        )
    }

    private func relatedProductCard(_ product: Product, isSkeleton: Bool) -> some View {
        VerticalProductCard(
            viewModel: .init(
                configuration: .init(size: .medium, hideAction: !viewModel.isWishlistEnabled),
                product: product
            ),
            onUserAction: { _, type in
                guard case .wishlist(let isFavorite) = type else { return }
                viewModel.didTapWishlist(for: product, isFavorite: isFavorite)
            },
            isSkeleton: .constant(isSkeleton),
            isFavorite: viewModel.isFavoriteState(for: product),
            actionAccessibilityIdentifier: AccessibilityID.ProductDetails.relatedProductWishlistButton(id: product.id)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.didSelectRelatedProduct(product)
        }
        .allowsHitTesting(!isSkeleton)
    }

    @ViewBuilder private var descriptionSection: some View {
        let showDescription = viewModel.shouldShow(section: .productDescription)
        // Gated apart from the description: the colour and reference are what a shopper quotes to
        // customer service, and a product without marketing copy still has both.
        let metadata = ProductDetailsLayoutRules.descriptionMetadata(
            colourName: viewModel.selectedColourName,
            reference: viewModel.productReference
        )

        if showDescription || metadata != nil {
            VStack(alignment: .leading, spacing: theme.sizing.spacingSpacingXs) {
                if showDescription {
                    Text.build(theme.font.body.medium(viewModel.productDescription))
                        .foregroundStyle(theme.color.contentContentPrimary)
                        .accessibilityIdentifier(AccessibilityID.ProductDetails.productDescription)
                }

                if let metadata {
                    Text.build(theme.font.label.small(metadata.display))
                        .foregroundStyle(theme.color.contentContentTerciary)
                        .accessibilityLabel(metadata.accessibilityLabel)
                        .accessibilityIdentifier(AccessibilityID.ProductDetails.descriptionMetadata)
                }
            }
        }
    }

    @ViewBuilder private var addToBag: some View {
        if viewModel.shouldShow(section: .addToBag) {
            if viewModel.bagQuantity > 0 {
                QuantityStepper(
                    quantity: viewModel.bagQuantity,
                    bounds: 0...viewModel.maxBagQuantity,
                    isDisabled: viewModel.isUpdatingBagQuantity,
                    cornerRadius: Constants.ctaCornerRadius,
                    accessibility: .init(
                        value: .init(
                            label: L10n.Product.Quantity.accessibilityLabel(viewModel.bagQuantity),
                            identifier: AccessibilityID.ProductDetails.bagQuantityValue
                        ),
                        decrease: .init(
                            label: viewModel.bagQuantity == 1
                                ? L10n.Product.Quantity.Remove.accessibilityLabel
                                : L10n.Product.Quantity.Decrease.accessibilityLabel,
                            identifier: AccessibilityID.ProductDetails.bagQuantityDecreaseButton
                        ),
                        increase: .init(
                            label: L10n.Product.Quantity.Increase.accessibilityLabel,
                            identifier: AccessibilityID.ProductDetails.bagQuantityIncreaseButton
                        )
                    ),
                    onDecrease: { viewModel.didTapDecreaseBagQuantity() },
                    onIncrease: { viewModel.didTapIncreaseBagQuantity() }
                )
                .frame(maxWidth: .infinity)
            } else {
                addToBagButton
            }
        }
    }

    @ViewBuilder private var addToBagButton: some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            let addToBagText = L10n.Product.AddToBag.Button.cta
            let outOfStockText = L10n.Product.OutOfStock.Button.cta

            ThemedButton(
                text: viewModel.addToBagState == .outOfStock ? outOfStockText : addToBagText,
                isDisabled: .init(
                    // Disabled for the duration of the write, not merely showing a spinner:
                    // `ThemedButton` stays hit-testable while loading, and a tappable spinner
                    // reads to VoiceOver as an ordinary button.
                    get: { viewModel.addToBagState != .ready || viewModel.isAddingToBag },
                    set: { _ in }
                ),
                isLoading: .init(
                    get: { viewModel.isAddingToBag },
                    set: { _ in }
                ),
                isFullWidth: true,
                cornerRadius: Constants.ctaCornerRadius
            ) {
                viewModel.didTapAddToBag()
            }
            .accessibilityIdentifier(AccessibilityID.ProductDetails.addToBagButton)
        }
    }

    /// Icon-only in the design, so the label it used to carry becomes the accessibility label —
    /// otherwise VoiceOver reaches an unnamed button.
    @ViewBuilder private var addToWishlist: some View {
        if viewModel.shouldShow(section: .addToWishlist) {
            ThemedButton(
                text: "",
                style: .secondary,
                leadingAsset: viewModel.isInWishlist ? .heartFill : .heart,
                cornerRadius: Constants.ctaCornerRadius,
                // Figma: a 24pt glyph in the 40pt square, not the 16pt a label-with-icon uses.
                iconSize: theme.sizing.iconsIconMedium
            ) {
                viewModel.didTapAddToWishlist()
            }
            .frame(width: theme.sizing.iconsIconXlarge, height: theme.sizing.iconsIconXlarge)
            .accessibilityLabel(
                viewModel.isInWishlist ? L10n.Accessibility.removeFromWishlist : L10n.Product.AddToWishlist.Button.cta
            )
            .accessibilityIdentifier(AccessibilityID.ProductDetails.addToWishlistButton)
        }
    }

    @ViewBuilder private var errorView: some View {
        ErrorView(
            spacing: theme.sizing.spacingSpacing2xl,
            iconSize: Constants.errorViewIconSize,
            title: theme.font.heading.medium(errorTitle),
            message: theme.font.body.medium(errorMessage),
            buttons: [
                .init(
                    cta: L10n.Pdp.ErrorView.Retry.Button.cta,
                    accessibilityId: AccessibilityID.ProductDetails.errorRetryButton,
                    action: viewModel.didTapRetry
                ),
                .init(cta: L10n.Pdp.ErrorView.GoBack.Button.cta) {
                    viewModel.didTapBackButton()
                },
            ]
        )
    }

    private func complementaryInfoCell(type: ProductDetailsComplementaryInfoType, showTopDivider: Bool) -> some View {
        VStack(spacing: theme.sizing.spacingSpacingNone) {
            if showTopDivider {
                ThemedDivider.horizontalThin
            }

            HStack(spacing: theme.sizing.spacingSpacingNone) {
                HStack(spacing: theme.sizing.spacingSpacingNone) {
                    // No inset of its own: the panel's gutter already positions the row, and the
                    // extra 8pt pushed these titles out of line with the description above them.
                    Text.build(theme.font.body.medium(complementaryInfoTitle(for: type)))
                        .foregroundStyle(theme.color.contentContentPrimary)
                    Spacer()
                    Icon.chevronRight.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                        .foregroundStyle(theme.color.contentContentPrimary)
                }
                .shimmering(while: shimmeringBinding(for: .complementaryInfo), animateOnStateTransition: false)
            }
            .frame(minHeight: Constants.complementaryInfoCellMinHeight)
            .modifier(
                TapHighlightableModifier {
                    // A pushed screen, not an embedded web view: one per row inside this scroll
                    // view means nested scrolling and a height nothing can know up front.
                    guard let feature = viewModel.complementaryInfoWebFeature(for: type) else { return }
                    viewModel.openWebFeature(feature)
                }
            )

            ThemedDivider.horizontalThin
        }
        .disabled(viewModel.shouldShowLoading(for: .complementaryInfo))
    }
}

private enum Constants {
    /// The design draws the call-to-action and wishlist buttons square, unlike the 4pt default.
    static let ctaCornerRadius: CGFloat = 0
    static let indicatorSize: CGFloat = 6
    /// The design lays the size chips out three to a row, the last row keeping that width.
    static let sizeGridColumns = 3
    /// The colour cards follow the size chips: three to a row.
    static let colourGridColumns = 3
    static let minTapTargetSize: CGFloat = 44
    static let selectedIndicatorWidth: CGFloat = 12
    /// Bounds the whole screen on a wide device: the gallery hugs its image, so at an iPad's full
    /// width it would be taller than the screen and push the information block below the fold.
    /// Applied to the gallery and the content block alike so they stay in one aligned column.
    static let maxContentWidth: CGFloat = 500
    static let minTitleHeight = 20.0
    /// Figma: the gallery Image component's default variant is `Ratio=3:4` (375x500).
    static let galleryAspectRatio: CGFloat = 0.75
    static let chevronSize: CGFloat = 16
    static let complementaryInfoCellMinHeight: CGFloat = 72
    static let errorViewIconSize: CGFloat = 210
    static let relatedProductsColumns = 2
    static let relatedProductsSkeletonCount = 6
}

#if DEBUG
#Preview("Loaded") {
    ProductDetailsView(
        viewModel: MockProductDetailsViewModel(
            state: .success(.init(product: .fixture())),
            productName: "Nolita SW Signature Loafer",
            productImageUrls: [
                URL.fromString("https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                URL.fromString("https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            ],
            productDescription: "A short-sleeved dress in a slim fit by BOSS Womenswear. Featuring a wrap-over bodice and a tiered skirt, this V-neck dress is crafted in metallic fabric with lining underneath.", // swiftlint:disable:this line_length
            variantSelection: .init(
                colours: [
                    .init(id: "1", name: "", type: .url(URL.fromString("URL.fromString(https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"))),
                    .init(id: "2", name: "", type: .url(URL.fromString("URL.fromString(https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"))),
                    .init(id: "3", name: "", type: .color(.green), isDisabled: true),
                    .init(id: "4", name: "", type: .color(.red)),
                ]
            ),
            complementaryInfoToShow: [.paymentOptions, .returns]
        )
    )
}

#Preview("Loading") {
    ProductDetailsView(
        viewModel: MockProductDetailsViewModel(
            complementaryInfoToShow: [.paymentOptions, .returns],
            onShouldShowLoadingForSectionCalled: { _ in true },
            onShouldShowSectionCalled: { section in section != .addToBag }
        )
    )
}

#Preview("Error - Not found") {
    ProductDetailsView(viewModel: MockProductDetailsViewModel(state: .error(.notFound)))
}

#Preview("Error - Generic") {
    ProductDetailsView(viewModel: MockProductDetailsViewModel(state: .error(.generic)))
}

#Preview("Error - No connection") {
    ProductDetailsView(viewModel: MockProductDetailsViewModel(state: .error(.noConnection)))
}
#endif

private extension AddToBagFeedback {
    struct Snackbar {
        let type: SnackbarViewConfiguration.SnackbarViewType
        let text: String
        let icon: Image
    }

    var snackbar: Snackbar {
        switch self {
        case .success:
            .init(type: .success, text: L10n.Product.AddToBag.Success.message, icon: Icon.checkmark.image)

        case .failure:
            .init(type: .error, text: L10n.Product.AddToBag.Error.message, icon: Icon.warning.image)

        case .quantityUpdateFailure:
            .init(type: .error, text: L10n.Product.Quantity.Error.message, icon: Icon.warning.image)
        }
    }
} // swiftlint:disable:this file_length
