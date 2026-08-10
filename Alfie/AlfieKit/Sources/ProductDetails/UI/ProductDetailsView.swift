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
    @State private var showColorSheet = false
    @State private var showSizeSheet = false
    @State private var shouldAnimateCurrentMediaIndex = true
    @State private var colorSelectorSize: CGSize = .zero
    @State private var currentDescriptionTabIndex = 0
    @State private var showFailureState: Bool
    @State private var hasSpaceForSizeSelector = true
    @State private var colorSheetSearchText = ""

    // There are multiple types of color pickers, but they all depend on the same conditions
    private var canShowColorPickers: Bool {
        ProductDetailsLayoutRules.colourLayout(
            forColourCount: viewModel.colorSelectionConfiguration.items.count
        ) != .summaryOnly
    }

    private var canShowSizePickers: Bool {
        ProductDetailsLayoutRules.sizeLayout(
            forSizeCount: viewModel.sizingSelectionConfiguration.items.count
        ) == .verticalList
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
        .toolbarView(
            productTitle: viewModel.productTitle,
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
                mediaCarousel
                complementaryViews
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, horizontalPadding)
        .fullScreenCover(isPresented: $isMediaFullScreen) {
            fullscreenMediaCarousel
        }
        .sheet(isPresented: $showColorSheet, onDismiss: { colorSheetSearchText = "" }) {
            colorSheet
        }
        .sheet(isPresented: $showSizeSheet) {
            sizeSheet
        }
    }

    @ViewBuilder private var paginatedControl: some View {
        if viewModel.shouldShowMediaPaginatedControl {
            PaginatedControl(
                configuration: .init(),
                itemsCount: viewModel.productImageUrls.count,
                selectedIndex: $currentMediaIndex
            )
            .frame(maxHeight: theme.spacing.space200)
            .shimmering(
                while: shimmeringBinding(for: .mediaCarousel),
                animateOnStateTransition: false,
                cornerRadius: Sizing.radiusStrong
            )
        }
    }

    // MARK: - Helpers

    private func shimmeringBinding(for section: ProductDetailsSection) -> Binding<Bool> {
        .init(get: { viewModel.shouldShowLoading(for: section) }, set: { _ in })
    }

    private var horizontalPadding: CGFloat {
        isIpad ? theme.spacing.space500 : theme.spacing.space200
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
            titleHeader

            price

            VStack(spacing: theme.spacing.space100) {
                addToBag
                addToWishlist
            }
            .padding(.vertical, theme.spacing.space100)

            colorSelector

            if canShowSize {
                sizeSelector
            }

            descriptionTab
                .padding(.vertical, theme.spacing.space200)

            complementaryInfo
        }
    }

    var mediaCarousel: some View {
        VStack(spacing: theme.spacing.space200) {
            SnapCarousel(
                areItemsLoading: shimmeringBinding(for: .mediaCarousel),
                itemIndex: $currentMediaIndex,
                shouldAnimateRealIndexUpdate: $shouldAnimateCurrentMediaIndex
            ) {
                viewModel.productImageUrls.map { url in
                    RemoteImage(
                        url: url,
                        success: { image in
                            image
                                .resizable()
                                .onTapGesture { isMediaFullScreen = true }
                        },
                        placeholder: { Theme.surfaceForegroundPrimary },
                        failure: { _ in Theme.surfaceBackgroundInvertedPrimary }
                    )
                    .cornerRadius(Sizing.radiusSoft)
                }
            }
            .padding(.top, theme.spacing.space200)
            .padding(.bottom, viewModel.hasSingleImage ? theme.spacing.space200 : theme.spacing.space0)
            .disabled(isMediaFullScreen)
            paginatedControl
                .padding(.bottom, theme.spacing.space200)
        }
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
                    failure: { _ in Theme.contentContentPrimary }
                )
            }
        }
    }

    @ViewBuilder private var titleHeader: some View {
        if viewModel.shouldShow(section: .titleHeader) {
            HStack(spacing: theme.spacing.space0) {
                Text.build(theme.font.body.medium(viewModel.productName))
                    .foregroundStyle(Theme.contentContentPrimary)
                    .frame(maxWidth: .infinity, minHeight: Constants.minTitleHeight, alignment: .leading)
                    .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.productTitle)
            }
        }
    }

    @ViewBuilder private var price: some View {
        if let priceType = viewModel.priceType {
            PriceComponentView(
                type: priceType,
                configuration: .init(preferredDistribution: .horizontal, size: .small, textAlignment: .leading)
            )
        }
    }

    private var colorSheet: some View {
        ProductDetailsColorAndSizeSheet(
            viewModel: viewModel,
            type: .color,
            isPresented: $showColorSheet,
            searchText: $colorSheetSearchText
        )
    }

    private var sizeSheet: some View {
        ProductDetailsColorAndSizeSheet(viewModel: viewModel, type: .size, isPresented: $showSizeSheet)
    }

    @ViewBuilder private var colorSelector: some View {
        if viewModel.shouldShow(section: .colorSelector) {
            if hasSpaceForSizeSelector {
                VStack(alignment: .leading, spacing: theme.spacing.space150) {
                    ColorAndSizingSelectorHeaderView(
                        configuration: viewModel.colorSelectionConfiguration,
                        isExpandable: canShowColorPickers
                    ) {
                        showColorSheet = true
                    }

                    if canShowColorPickers {
                        ColorSelectorComponentView(
                            configuration: viewModel.colorSelectionConfiguration,
                            layoutConfiguration: .init(
                                arrangement: .horizontal(itemSpacing: theme.spacing.space100, scrollable: false),
                                hideSelectionTitle: true,
                                hideOnSingleColor: false
                            ),
                            frameSize: .init(
                                get: { .zero },
                                set: { colorSwatchesFrameSize in
                                    hasSpaceForSizeSelector = colorSwatchesFrameSize.width < colorSelectorSize.width
                                }
                            )
                        )
                        .frame(minHeight: Constants.minColorSelectorHeight, alignment: .leading)
                    }
                }
                .shimmering(while: shimmeringBinding(for: .colorSelector), animateOnStateTransition: false)
                .writingSize(to: $colorSelectorSize)
                .accessibilityIdentifier(AccessibilityID.ProductDetails.colourSelector)
            } else if canShowColorPickers {
                if let selectedColor = viewModel.colorSelectionConfiguration.selectedItem {
                    PickerMenu(isModalPresented: $showColorSheet) {
                        HStack(spacing: theme.spacing.space100) {
                            ColorSwatchView(item: selectedColor, swatchSize: .normal, isSelected: false)
                            Text.build(theme.font.body.small(selectedColor.name.capitalized))
                                .foregroundStyle(Theme.contentContentPrimary)
                        }
                    }
                    .id(selectedColor.id)
                }
            }
        }
    }

    @ViewBuilder private var sizeSelector: some View {
        if viewModel.shouldShow(section: .sizeSelector) {
            VStack(alignment: .leading, spacing: theme.spacing.space150) {
                if viewModel.canShowSizeSelector {
                    ColorAndSizingSelectorHeaderView(
                        configuration: viewModel.sizingSelectionConfiguration,
                        isExpandable: canShowSizePickers
                    ) {
                        showSizeSheet = true
                    }

                    if !canShowSizePickers {
                        SizingSelectorComponentView(
                            configuration: viewModel.sizingSelectionConfiguration,
                            layoutConfiguration: .init(arrangement: .grid(columns: 3))
                        )
                    }
                } else {
                    singleSizeView
                }
            }
            .shimmering(while: shimmeringBinding(for: .sizeSelector), animateOnStateTransition: false)
            .accessibilityIdentifier(AccessibilityID.ProductDetails.sizeSelector)
        }
    }

    @ViewBuilder private var singleSizeView: some View {
        let sizeText: String = isOneSize
            ? (viewModel.sizingSelectionConfiguration.items.first?.name ?? "")
            : L10n.Product.OneSize.title
        HStack {
            Text.build(theme.font.body.small(L10n.Product.Size.title + ":"))
                .foregroundStyle(Theme.contentContentPrimary)
            Text.build(theme.font.body.small(sizeText))
                .foregroundStyle(Theme.contentContentPrimary)
        }
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

    @ViewBuilder private var descriptionTab: some View {
        if viewModel.shouldShow(section: .productDescription) {
            VStack(alignment: .leading, spacing: theme.spacing.space200) {
                TabControl(
                    theme: .dark,
                    configuration: .fixedSize(horizontalMargins: theme.spacing.space200),
                    options: [TabControl.TabOption(title: L10n.Pdp.TabControl.DescriptionOption.title)],
                    currentIndex: $currentDescriptionTabIndex
                )

                Text.build(theme.font.body.medium(viewModel.productDescription))
                    .foregroundStyle(Theme.contentContentPrimary)
                    .accessibilityIdentifier(AccessibilityID.ProductDetails.productDescription)
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

    @ViewBuilder private var addToWishlist: some View {
        if viewModel.shouldShow(section: .addToWishlist) {
            VStack(spacing: theme.spacing.space0) {
                ThemedButton(
                    text: L10n.Product.AddToWishlist.Button.cta,
                    style: .secondary,
                    isFullWidth: true,
                    cornerRadius: Constants.ctaCornerRadius
                ) {
                    viewModel.didTapAddToWishlist()
                }
                .accessibilityIdentifier(AccessibilityID.ProductDetails.addToWishlistButton)
            }
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
    static let minTitleHeight = 20.0
    static let minColorSelectorHeight = 26.0
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
