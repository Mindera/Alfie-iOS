import Combine
import Core
#if DEBUG
import Common
import Mocks
#endif
import Models
import OrderedCollections
import StyleGuide
import SwiftUI

struct ProductDetailsView<ViewModel: ProductDetailsViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var coordinator: Coordinator
    @State private var currentMediaIndex = 0
    @State private var isMediaFullScreen = false
    @State private var showColorSheet = false
    @State private var showSizeSheet = false
    @State private var showDetailsSheet = false
    @State private var shouldAnimateCurrentMediaIndex = true
    @State private var carouselSize: CGSize = .zero
    @State private var viewSize: CGSize = .zero
    @State private var colorSelectorSize: CGSize = .zero
    @State private var bottomSheetCurrentDetent = PresentationDetent.height(0)
    // store the detents before navigation to restore afterwards
    @State private var bottomSheetDetentBeforeNavigation: PresentationDetent?
    @State private var bottomSheetDetents: OrderedSet<PresentationDetent> = [PresentationDetent.height(0)]
    @State private var currentDescriptionTabIndex = 0
    @State private var showFailureState: Bool
    @State private var hasSpaceForSizeSelector = true
    @State private var colorSheetSearchText = ""

    // There are multiple types of color pickers, but they all depend on the same conditions
    private var canShowColorPickers: Bool {
        viewModel.colorSelectionConfiguration.items.count > 1
    }

    private var canShowSizePickers: Bool {
        viewModel.sizingSelectionConfiguration.items.count > 6
    }

    private var canShowSizeSelector: Bool {
        viewModel.sizingSelectionConfiguration.items.count >= 1
    }

    // TODO: remove showFailureState (created for snapshot purposes)
    init(viewModel: ViewModel, showFailureState: Bool = false) {
        _showFailureState = State(initialValue: showFailureState)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if showFailureState {
                errorView
                    .padding(.horizontal, horizontalPadding)
            } else {
                pdpView
                    .writingSize(to: $viewSize)
            }
        }
        .withToolbar(for: .productDetails(.id(viewModel.productId)))
        .toolbar {
            if !viewModel.state.didFail {
                ToolbarItem(placement: .principal) {
                    ThemedToolbarTitle(style: .text(viewModel.productTitle))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarItemProvider.shareItem(configuration: viewModel.shareConfiguration)
                }
            }
        }
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
            if newValue {
                // give the sheet time to dismiss in case we catch it in the middle of the presentation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showDetailsSheet = false
                    showFailureState = true
                }
            } else {
                showFailureState = false
            }
        }
    }

    @ViewBuilder private var pdpView: some View {
        if isIpad {
            legacyPDPView
        } else {
            if #available(iOS 16.4, *) {
                iPhonePDPView
            } else {
                legacyPDPView
            }
        }
    }

    @ViewBuilder private var paginatedControl: some View {
        if viewModel.shouldShowMediaPaginatedControl {
            PaginatedControl(
                configuration: .init(),
                itemsCount: viewModel.productImageUrls.count,
                selectedIndex: $currentMediaIndex
            )
            .frame(maxHeight: Spacing.space200)
            .shimmering(
                while: shimmeringBinding(for: .mediaCarousel),
                animateOnStateTransition: false,
                cornerRadius: CornerRadius.m
            )
        }
    }

    @available(iOS 16.4, *)
    // swiftlint:disable:next attributes
    private var iPhonePDPView: some View {
        VStack {
            mediaCarousel
            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .task {
            showDetailsSheet = true
        }
        .onAppear {
            if let bottomSheetDetentBeforeNavigation {
                bottomSheetCurrentDetent = bottomSheetDetentBeforeNavigation
                showDetailsSheet = true
            }
        }
        .onChange(of: viewSize) { newValue in
            if newValue != .zero {
                setupDetents(with: newValue)
            }
        }
        .sheet(isPresented: $showDetailsSheet) {
            popupView
                .sheet(isPresented: $showColorSheet, onDismiss: { colorSheetSearchText = "" }, content: {
                    colorSheet
                        .presentationBackgroundInteraction(.enabled)
                })
                .sheet(isPresented: $showSizeSheet) {
                    sizeSheet
                        .presentationBackgroundInteraction(.enabled)
                }
                .fullScreenCover(isPresented: $isMediaFullScreen) {
                    fullscreenMediaCarousel
                }
        }
    }

    private var legacyPDPView: some View {
        VStack {
            ScrollView {
                mediaCarousel
                complementaryViews
                    .padding(.horizontal, horizontalPadding)
            }
            addToBag
        }
        .fullScreenCover(isPresented: $isMediaFullScreen) {
            fullscreenMediaCarousel
        }
        .sheet(isPresented: $showColorSheet, onDismiss: { colorSheetSearchText = "" }, content: {
            colorSheet
        })
    }

    // MARK: - Helpers

    private func setupDetents(with viewSize: CGSize) {
        let collapsedDetent = PresentationDetent.height(viewSize.height + TabBarView.size.height - carouselSize.height)
        let expandedDetent = PresentationDetent.height(viewSize.height + TabBarView.size.height)

        bottomSheetDetents = [
            collapsedDetent,
            expandedDetent,
        ]

        bottomSheetCurrentDetent = collapsedDetent
    }

    private func shimmeringBinding(for section: ProductDetailsSection) -> Binding<Bool> {
        .init(get: { viewModel.shouldShowLoading(for: section) }, set: { _ in })
    }

    private var horizontalPadding: CGFloat {
        isIpad ? Spacing.space500 : Spacing.space200
    }

    private func complementaryInfoTitle(for type: ProductDetailsComplementaryInfoType) -> String {
        // swiftlint:disable vertical_whitespace_between_cases
        switch type {
        case .delivery:
            return LocalizableProductDetails.$complementaryInfoDelivery
        case .paymentOptions:
            return LocalizableProductDetails.$complementaryInfoPayment
        case .returns:
            return LocalizableProductDetails.$complementaryInfoReturns
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
            return LocalizableProductDetails.$errorGenericMessage
        case .notFound:
            return LocalizableProductDetails.$errorNotFoundMessage
        }
        // swiftlint:enable vertical_whitespace_between_cases
    }
}

// MARK: - Sections
extension ProductDetailsView {
    @available(iOS 16.4, *)
    // swiftlint:disable:next attributes
    private var popupView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                complementaryViews
                    .padding([.horizontal, .top], Spacing.space200)
            }

            addToBag
        }
        .presentationDetents(Set(bottomSheetDetents), selection: $bottomSheetCurrentDetent)
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
        .persistentSystemOverlays(.hidden)
    }

    /// contains every view except the media carousel
    private var complementaryViews: some View {
        VStack(alignment: .leading, spacing: Spacing.space100) {
            titleHeader

            colorSelector

            sizeSelector

            descriptionTab
                .padding(.vertical, Spacing.space200)

            complementaryInfo

            Spacer()
        }
    }

    var mediaCarousel: some View {
        VStack(spacing: Spacing.space200) {
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
                        placeholder: { Colors.primary.mono050 },
                        failure: { _ in Colors.primary.black }
                    )
                    .cornerRadius(CornerRadius.s)
                }
            }
            .padding(.top, Spacing.space200)
            .padding(.bottom, viewModel.hasSingleImage ? Spacing.space200 : Spacing.space0)
            .disabled(isMediaFullScreen)
            paginatedControl
                .padding(.bottom, Spacing.space200)
        }
        .writingSize(to: $carouselSize)
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
                    placeholder: { Colors.primary.mono050 },
                    failure: { _ in Colors.primary.black }
                )
            }
        }
    }

    @ViewBuilder private var titleHeader: some View {
        if viewModel.shouldShow(section: .titleHeader) {
            HStack(spacing: Spacing.space0) {
                Text.build(theme.font.paragraph.normal(viewModel.productName))
                    .foregroundStyle(Colors.primary.black)
                    .frame(maxWidth: .infinity, minHeight: Constants.minTitleHeight, alignment: .leading)
                    .shimmering(while: shimmeringBinding(for: .titleHeader), animateOnStateTransition: false)
                // TODO: Add a spacer and the price here in a future ticket
            }
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
                VStack(alignment: .leading, spacing: Spacing.space150) {
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
                                arrangement: .horizontal(itemSpacing: Spacing.space100, scrollable: false),
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
            } else if canShowColorPickers {
                if let selectedColor = viewModel.colorSelectionConfiguration.selectedItem {
                    PickerMenu(isModalPresented: $showColorSheet) {
                        HStack(spacing: Spacing.space100) {
                            ColorSwatchView(item: selectedColor, swatchSize: .normal, isSelected: false)
                            Text.build(theme.font.small.normal(selectedColor.name.capitalized))
                                .foregroundStyle(Colors.primary.mono900)
                        }
                    }
                    .id(selectedColor.id)
                }
            }
        }
    }

    @ViewBuilder private var sizeSelector: some View {
        if viewModel.shouldShow(section: .sizeSelector) {
            VStack(alignment: .leading, spacing: Spacing.space150) {
                if canShowSizeSelector {
                    ColorAndSizingSelectorHeaderView(
                        configuration: viewModel.sizingSelectionConfiguration,
                        isExpandable: canShowSizePickers
                    ) {
                        showSizeSheet = true
                    }

                    if !canShowSizePickers {
                        SizingSelectorComponentView(
                            configuration: viewModel.sizingSelectionConfiguration,
                            layoutConfiguration: .init(arrangement: .grid(columns: 3, columnWidth: 60))
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder private var complementaryInfo: some View {
        if viewModel.shouldShow(section: .complementaryInfo) {
            VStack(spacing: Spacing.space0) {
                ForEach(Array(viewModel.complementaryInfoToShow.enumerated()), id: \.0) { index, type in
                    complementaryInfoCell(type: type, showTopDivider: index == 0)
                }
            }
        }
    }

    @ViewBuilder private var descriptionTab: some View {
        if viewModel.shouldShow(section: .productDescription) {
            VStack(alignment: .leading, spacing: Spacing.space200) {
                TabControl(
                    theme: .dark,
                    configuration: .fixedSize(horizontalMargins: Spacing.space200),
                    options: [TabControl.TabOption(title: LocalizableProductDetails.$productDescription)],
                    currentIndex: $currentDescriptionTabIndex
                )

                Text.build(theme.font.paragraph.normal(viewModel.productDescription))
                    .foregroundStyle(Colors.primary.black)
            }
        }
    }

    @ViewBuilder private var addToBag: some View {
        if viewModel.shouldShow(section: .addToBag) {
            VStack(spacing: Spacing.space0) {
                let addToBagText = LocalizableProductDetails.$addToBag
                let outOfStockText = LocalizableProductDetails.$outOfStock

                ThemedButton(
                    text: viewModel.productHasStock ? addToBagText : outOfStockText,
                    isDisabled: .init(
                        get: { !viewModel.productHasStock },
                        set: { _ in }
                    ),
                    isFullWidth: true
                ) { viewModel.didTapAddToBag() }
            }
            .padding(.vertical, Spacing.space100)
            .padding(.horizontal, Spacing.space200)
        }
    }

    @ViewBuilder private var errorView: some View {
        // TODO: properly implement the error views in a future ticket (with the refresh CTA and proper labels)
        VStack(spacing: Spacing.space500) {
            Circle()
                .fill(Colors.primary.mono200)
                .frame(width: Constants.errorViewCircleSize, height: Constants.errorViewCircleSize)
            Text.build(theme.font.header.h2(LocalizableProductDetails.errorTitle))
                .foregroundStyle(Colors.primary.black)
            Text.build(theme.font.paragraph.normal(errorMessage))
                .foregroundStyle(Colors.primary.mono600)
            ThemedButton(text: LocalizableProductDetails.$errorButtonBackLabel, isFullWidth: true) {
                coordinator.didTapBackButton()
            }
        }
    }

    private func complementaryInfoCell(type: ProductDetailsComplementaryInfoType, showTopDivider: Bool) -> some View {
        VStack(spacing: Spacing.space0) {
            if showTopDivider {
                ThemedDivider.horizontalThin
            }

            HStack(spacing: Spacing.space0) {
                HStack(spacing: Spacing.space0) {
                    Text.build(theme.font.paragraph.normal(complementaryInfoTitle(for: type)))
                        .foregroundStyle(Colors.primary.black)
                        .padding(.leading, Spacing.space100)
                    Spacer()
                    Icon.chevronRight.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.chevronSize, height: Constants.chevronSize)
                        .foregroundStyle(Colors.primary.black)
                        .padding(.trailing, Spacing.space100)
                }
                .shimmering(while: shimmeringBinding(for: .complementaryInfo), animateOnStateTransition: false)
            }
            .frame(minHeight: Constants.complementaryInfoCellMinHeight)
            .modifier(
                TapHighlightableModifier {
                    guard let feature = viewModel.complementaryInfoWebFeature(for: type) else { return }
                    showDetailsSheet = false
                    bottomSheetDetentBeforeNavigation = bottomSheetCurrentDetent
                    coordinator.open(webFeature: feature)
                }
            )

            ThemedDivider.horizontalThin
        }
        .disabled(viewModel.shouldShowLoading(for: .complementaryInfo))
    }
}

private enum Constants {
    static let minTitleHeight = 20.0
    static let minColorSelectorHeight = 26.0
    static let chevronSize: CGFloat = 16
    static let sheetCloseIconSize: CGFloat = 16
    static let complementaryInfoCellMinHeight: CGFloat = 72
    static let errorViewCircleSize: CGFloat = 210
    static let colorChevronSize: CGFloat = 16
}

#if DEBUG
#Preview("Loaded") {
    ProductDetailsView(
        viewModel: MockProductDetailsViewModel(
            state: .success(.init(product: .fixture(), selectedVariant: .fixture())),
            productName: "Nolita SW Signature Loafer",
            productImageUrls: [
                URL.fromString("https://www.alfieproj.com/productimages/thumb/2/2666503_22841458_13891527.jpg"),
                URL.fromString("https://www.alfieproj.com/productimages/thumb/2/2666503_22841458_13891527.jpg"),
            ],
            productDescription: "A short-sleeved dress in a slim fit by BOSS Womenswear. Featuring a wrap-over bodice and a tiered skirt, this V-neck dress is crafted in metallic fabric with lining underneath.", // swiftlint:disable:this line_length
            colorSelectionConfiguration: .init(
                items: [
                    .init(name: "", type: .url(URL.fromString("https://www.alfieproj.com/productimages/thumb/3/2479864_22579704_13941430.jpg"))),
                    .init(name: "", type: .url(URL.fromString("https://www.alfieproj.com/productimages/thumb/3/2479864_22005770_9866399.jpg"))),
                    .init(name: "", type: .color(.green), isDisabled: true),
                    .init(name: "", type: .color(.red)),
                ]
            ),
            complementaryInfoToShow: [.paymentOptions, .returns]
        )
    )
    .environmentObject(Coordinator())
}

#Preview("Loading") {
    ProductDetailsView(
        viewModel: MockProductDetailsViewModel(
            complementaryInfoToShow: [.paymentOptions, .returns],
            onShouldShowLoadingForSectionCalled: { _ in true },
            onShouldShowSectionCalled: { section in section != .addToBag }
        )
    )
    .environmentObject(Coordinator())
}

#Preview("Error - Not found") {
    ProductDetailsView(viewModel: MockProductDetailsViewModel(state: .error(.notFound)))
    .environmentObject(Coordinator())
}

#Preview("Error - Generic") {
    ProductDetailsView(viewModel: MockProductDetailsViewModel(state: .error(.generic)))
    .environmentObject(Coordinator())
}
#endif // swiftlint:disable:this file_length
