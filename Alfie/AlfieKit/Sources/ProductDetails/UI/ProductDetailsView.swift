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
    @State private var shouldAnimateCurrentMediaIndex = true
    @State private var showFailureState: Bool

    private var colourLayout: ProductDetailsLayoutRules.ColourLayout {
        ProductDetailsLayoutRules.colourLayout(forColourCount: viewModel.colorSelectionConfiguration.items.count)
    }

    private var isOneSize: Bool {
        viewModel.sizingSelectionConfiguration.items.count == 1
    }

    private var canShowSize: Bool {
        guard !viewModel.sizingSelectionConfiguration.items.isEmpty else { return true }

        let productStockCount = viewModel.sizingSelectionConfiguration.items.reduce(into: 0) {
            $0 += ($1.state != .outOfStock ? 1 : 0)
        }

        return productStockCount != 0
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
            shouldAnimateCurrentMediaIndex = false
            currentMediaIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                shouldAnimateCurrentMediaIndex = true
            }
        }
        .onChange(of: viewModel.state.didFail) { newValue in
            showFailureState = newValue
        }
    }

    private var pdpView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.space0) {
                // The gallery is full-bleed, so the gutter belongs to the content below it.
                mediaCarousel
                complementaryViews
                    .padding(.horizontal, horizontalPadding)
                    // Same bound as the gallery, so the two stay in one column on a wide screen.
                    .frame(maxWidth: Constants.maxContentWidth)
                    .frame(maxWidth: .infinity)
                    // Opaque, so nothing from the gallery can render through the product info.
                    // No rule between the two — the design runs the panel straight off the image.
                    .background(Theme.surfaceBackgroundPrimary)
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
                color: Constants.unselectedIndicatorColor,
                // White, not primary: the indicators overlay the image rather than sit below it.
                selectedColor: Theme.contentContentInvertedPrimary,
                size: Constants.indicatorSize,
                spacing: theme.spacing.space100,
                padding: theme.spacing.space0
            )
            ThemedPageControl(
                data: viewModel.productImageUrls,
                selectedIndex: $currentMediaIndex,
                configuration: configuration
            ) { _, isSelected in
                RoundedRectangle(cornerRadius: theme.radius.rounded)
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
        isIpad ? theme.spacing.space500 : theme.spacing.space200
    }

    /// The gallery when there is imagery, otherwise one empty slot while the product loads: the
    /// carousel hugs its content, so with nothing to measure it would collapse and then shove the
    /// information block down the moment the images arrive.
    /// The gallery takes its height from its content, so with no images it would collapse to nothing
    /// and then shove the whole information block down once they arrive. An empty set reserves a
    /// square instead. It cannot reserve with a url-less `RemoteImage`: that resolves to the failure
    /// branch, which paints the inverted surface — a black block, not a neutral placeholder.
    private var galleryItems: [AnyView] {
        let urls = viewModel.productImageUrls
        guard !urls.isEmpty else {
            return [AnyView(Theme.surfaceForegroundPrimary.aspectRatio(1, contentMode: .fit))]
        }
        return urls.map { url in
            AnyView(
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
                        Theme.surfaceForegroundPrimary.aspectRatio(1, contentMode: .fit)
                    },
                    failure: { _ in
                        Theme.surfaceBackgroundInvertedPrimary.aspectRatio(1, contentMode: .fit)
                    }
                )
            )
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
        guard let failure = viewModel.state.failure else {
            return ""
        }

        // swiftlint:disable vertical_whitespace_between_cases
        switch failure {
        case .generic,
             .noInternet: // swiftlint:disable:this indentation_width
            return L10n.Pdp.ErrorView.Generic.message
        case .notFound:
            return L10n.Pdp.ErrorView.NotFound.message
        case .rateLimited:
            return L10n.Pdp.ErrorView.RateLimited.message
        case .serverError:
            return L10n.Pdp.ErrorView.ServerError.message
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }

    private var errorTitle: String {
        switch viewModel.state.failure {
        case .rateLimited:
            return L10n.Pdp.ErrorView.RateLimited.title
        case .serverError:
            return L10n.Pdp.ErrorView.ServerError.title
        default:
            return L10n.Pdp.ErrorView.title
        }
    }
}

// MARK: - Sections
extension ProductDetailsView {
    /// contains every view except the media carousel
    private var complementaryViews: some View {
        VStack(alignment: .leading, spacing: theme.spacing.space100) {
            productInfo

            // Figma: one row — Add to Bag fills, the wishlist is a 40pt square beside it.
            HStack(spacing: theme.spacing.space100) {
                addToBag
                addToWishlist
            }
            .padding(.vertical, theme.spacing.space100)

            colorSelector

            if canShowSize {
                sizeSelector
            }

            descriptionSection
                .padding(.vertical, theme.spacing.space200)

            complementaryInfo
        }
    }

    /// Full-bleed: the images fill the screen width, so there is no item spacing, no slice of the
    /// neighbouring image, and no corner radius. The gutter belongs to the content below.
    ///
    /// The height is the design's 3:4 gallery ratio (Figma: the Image component's default variant),
    /// not the imagery's. Hugging the content was tried and shipped, but in the app the carousel
    /// settled on the reserved placeholder's square and a taller photo drew past the frame, over the
    /// product info beneath it. The measurement is not obviously at fault — `SnapCarouselHeightTests`
    /// pins the hug path growing correctly for a declared ratio, a resizable image, an item-set swap
    /// and an item that grows in place — so the cause is unresolved and a fixed ratio is the
    /// deterministic choice rather than the diagnosed one. Images keep `.fit` inside the box, so
    /// nothing is cropped; anything other than 3:4 letterboxes.
    var mediaCarousel: some View {
        SnapCarousel(
            areItemsLoading: shimmeringBinding(for: .mediaCarousel),
            itemAspectRatio: Constants.galleryAspectRatio,
            itemIndex: $currentMediaIndex,
            shouldAnimateRealIndexUpdate: $shouldAnimateCurrentMediaIndex,
            showsAdjacentItemPeek: false
        ) {
            galleryItems
        }
        .frame(maxWidth: Constants.maxContentWidth)
        .frame(maxWidth: .infinity)
        .disabled(isMediaFullScreen)
        .overlay(alignment: .bottom) {
            paginatedControl
                .padding(.bottom, theme.spacing.space150)
        }
        .padding(.bottom, theme.spacing.space200)
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
                    placeholder: { Theme.surfaceForegroundPrimary },
                    failure: { _ in Theme.surfaceBackgroundInvertedPrimary }
                )
            }
        }
    }

    /// Brand, product name and price, with the colour summary pinned to the trailing edge.
    private var productInfo: some View {
        HStack(alignment: .top, spacing: theme.spacing.space100) {
            VStack(alignment: .leading, spacing: theme.spacing.space100) {
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
                // TOKEN GAP (G2): the design's #2B2B2B has no `content/secondary` alias upstream, so
                // the brand line renders at primary weight — flatter than designed — until it lands.
                .foregroundStyle(Theme.contentContentPrimary)
                .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.brandName)
        }
    }

    @ViewBuilder private var titleHeader: some View {
        if viewModel.shouldShow(section: .titleHeader) {
            HStack(spacing: theme.spacing.space0) {
                Text.build(theme.font.body.medium(viewModel.productName))
                    .foregroundStyle(Theme.contentContentPrimary)
                    .frame(maxWidth: .infinity, minHeight: Constants.minTitleHeight, alignment: .leading)
                    .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.productName)
            }
        }
    }

    @ViewBuilder private var colorSummary: some View {
        let configuration = viewModel.colorSelectionConfiguration
        let remainingCount = ProductDetailsLayoutRules.colourSummaryRemainingCount(
            forColourCount: configuration.items.count,
            hasSelection: configuration.selectedItem != nil
        )
        if viewModel.shouldShow(section: .colorSelector),
           let selectedItem = configuration.selectedItem,
           let remainingCount {
            // Informational: with the grid always inline there is nowhere left for a tap to go.
            ColorSummaryView(selectedItem: selectedItem, remainingCount: remainingCount) {}
                .allowsHitTesting(false)
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
                    VStack(alignment: .leading, spacing: theme.spacing.space150) {
                        colourSelectorTitle

                        ColorCardGridView(
                            configuration: viewModel.colorSelectionConfiguration,
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
            .foregroundStyle(Theme.contentContentPrimary)
    }

    @ViewBuilder private var sizeSelector: some View {
        if viewModel.shouldShow(section: .sizeSelector) {
            VStack(alignment: .leading, spacing: theme.spacing.space150) {
                if viewModel.canShowSizeSelector {
                    sizeSelectorHeader

                    SizingSelectorComponentView(
                        configuration: viewModel.sizingSelectionConfiguration,
                        layoutConfiguration: .init(arrangement: .grid(columns: Constants.sizeGridColumns))
                    )
                } else {
                    singleSizeView
                }
            }
            .shimmering(while: shimmeringBinding(for: .sizeSelector), animateOnStateTransition: false)
            .accessibilityIdentifier(AccessibilityID.ProductDetails.sizeSelector)
        }
    }

    private var sizeSelectorHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.space100) {
            Text.build(theme.font.heading.xSmall(L10n.Pdp.SizeSelector.title))
                .foregroundStyle(Theme.contentContentPrimary)

            Spacer()

            // The design draws the link with no destination behind it; slice 5 makes it live. Until
            // then it renders as designed but offers no tap target and no accessibility action.
            Text.build(theme.font.link.medium(L10n.Pdp.SizeGuide.link, underline: true))
                .foregroundStyle(Theme.linkLinkPrimaryDefault)
                .allowsHitTesting(false)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.sizeGuideLink)
        }
    }

    private var singleSizeView: some View {
        let sizeText: String = isOneSize
            ? (viewModel.sizingSelectionConfiguration.items.first?.name ?? "")
            : L10n.Product.OneSize.title
        return Text.build(theme.font.body.medium(L10n.Product.Size.selected(sizeText)))
            .foregroundStyle(Theme.contentContentPrimary)
    }

    @ViewBuilder private var complementaryInfo: some View {
        if viewModel.shouldShow(section: .complementaryInfo) {
            VStack(spacing: theme.spacing.space0) {
                ForEach(Array(viewModel.complementaryInfoToShow.enumerated()), id: \.0) { index, type in
                    complementaryInfoCell(type: type, showTopDivider: index == 0)
                }
            }
        }
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
            VStack(alignment: .leading, spacing: theme.spacing.space100) {
                if showDescription {
                    Text.build(theme.font.body.medium(viewModel.productDescription))
                        .foregroundStyle(Theme.contentContentPrimary)
                        .accessibilityIdentifier(AccessibilityID.ProductDetails.productDescription)
                }

                if let metadata {
                    Text.build(theme.font.label.small(metadata.display))
                        .foregroundStyle(Theme.contentContentTerciary)
                        .accessibilityLabel(metadata.accessibilityLabel)
                        .accessibilityIdentifier(AccessibilityID.ProductDetails.descriptionMetadata)
                }
            }
        }
    }

    @ViewBuilder private var addToBag: some View {
        if viewModel.shouldShow(section: .addToBag) {
            VStack(spacing: theme.spacing.space0) {
                let addToBagText = L10n.Product.AddToBag.Button.cta
                let outOfStockText = L10n.Product.OutOfStock.Button.cta

                ThemedButton(
                    text: viewModel.productHasAnyStock ? addToBagText : outOfStockText,
                    isDisabled: .init(
                        get: { !viewModel.isAddToBagEnabled },
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
    }

    /// Icon-only in the design, so the label it used to carry becomes the accessibility label —
    /// otherwise VoiceOver reaches an unnamed button.
    @ViewBuilder private var addToWishlist: some View {
        if viewModel.shouldShow(section: .addToWishlist) {
            ThemedButton(
                text: "",
                style: .secondary,
                leadingAsset: .heart,
                cornerRadius: Constants.ctaCornerRadius
            ) {
                viewModel.didTapAddToWishlist()
            }
            .frame(width: Sizing.iconsIconXlarge, height: Sizing.iconsIconXlarge)
            .accessibilityLabel(L10n.Product.AddToWishlist.Button.cta)
            .accessibilityIdentifier(AccessibilityID.ProductDetails.addToWishlistButton)
        }
    }

    @ViewBuilder private var errorView: some View {
        ErrorView(
            spacing: theme.spacing.space500,
            iconSize: Constants.errorViewIconSize,
            title: theme.font.heading.medium(errorTitle),
            message: theme.font.body.medium(errorMessage),
            // No Theme alias maps to neutrals600 (#4A4A4A) — see token-requests.md G3. Matches the
            // other 16 consumers of this value, including WebView's error message.
            messageColor: Primitives.Colours.neutrals600,
            buttons: [
                .init(cta: L10n.Pdp.ErrorView.GoBack.Button.cta) {
                    viewModel.didTapBackButton()
                },
            ]
        )
    }

    private func complementaryInfoCell(type: ProductDetailsComplementaryInfoType, showTopDivider: Bool) -> some View {
        VStack(spacing: theme.spacing.space0) {
            if showTopDivider {
                ThemedDivider.horizontalThin
            }

            HStack(spacing: theme.spacing.space0) {
                HStack(spacing: theme.spacing.space0) {
                    Text.build(theme.font.body.medium(complementaryInfoTitle(for: type)))
                        .foregroundStyle(Theme.contentContentPrimary)
                        .padding(.leading, theme.spacing.space100)
                    Spacer()
                    Icon.chevronRight.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                        .foregroundStyle(Theme.contentContentPrimary)
                        .padding(.trailing, theme.spacing.space100)
                }
                .shimmering(while: shimmeringBinding(for: .complementaryInfo), animateOnStateTransition: false)
            }
            .frame(minHeight: Constants.complementaryInfoCellMinHeight)
            .modifier(
                TapHighlightableModifier {
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
    /// TOKEN GAP (G1): the design's unselected indicator is #CDCDCD. The theme has no *border*
    /// alias at that value — only `surfaceBackgroundTerciary`, a surface token — so a semantic
    /// `border/border-strong` alias is requested upstream. Held on the primitive meanwhile.
    static let unselectedIndicatorColor = Primitives.Colours.neutrals300
    static let minTitleHeight = 20.0
    /// Figma: the gallery Image component's default variant is `Ratio=3:4` (375x500).
    static let galleryAspectRatio: CGFloat = 0.75
    static let chevronSize: CGFloat = 16
    static let complementaryInfoCellMinHeight: CGFloat = 72
    static let errorViewIconSize: CGFloat = 210
}

#if DEBUG
#Preview("Loaded") {
    ProductDetailsView(
        viewModel: MockProductDetailsViewModel(
            state: .success(.init(product: .fixture(), selectedVariant: .fixture())),
            productName: "Nolita SW Signature Loafer",
            productImageUrls: [
                URL.fromString("https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                URL.fromString("https://images.pexels.com/photos/9077817/pexels-photo-9077817.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            ],
            productDescription: "A short-sleeved dress in a slim fit by BOSS Womenswear. Featuring a wrap-over bodice and a tiered skirt, this V-neck dress is crafted in metallic fabric with lining underneath.", // swiftlint:disable:this line_length
            colorSelectionConfiguration: .init(
                items: [
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
#endif // swiftlint:disable:this file_length
